
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                M E N U  -  3
;
;                               UëivatelskÇ menu
;
; =============================================================================
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeMnu  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeMnu,ds:Data

; *****************************************************************************
;                                  UserMenu
;                              uëivatelskÇ menu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

UserMenu PROC      FAR

; ------ sestaven° implicitn°ho jmÇna souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset UserMFil
         cmp       byte ptr ds:[di],0       ; je jmÇno souboru zad†no ?
         jne       UserMnu2                 ; jmÇno souboru je zad†no
         mov       si,offset UserMNam       ; implicitn° jmÇno
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ otev©en° okna menu

UserMnu2:mov       si,offset UserMFil
         call      UserOpen                 ; otev©en° okna menu
         jnc       UserMnu3
UserMn29:jmp       UserMn99                 ; byla nàjak† chyba

; ------ nastaven° aktivn° poloëky p©i n†vratu z podmenu stiskem levÇho tlaá°tka

UserMn30:test      byte ptr ds:[MouseKey],bit0 ; je levÇ tlaá°tko ?
         jz        UserMnu3                 ; nen° levÇ tlaá°tko
         call      UserMGet                 ; definice aktivn°ho menu
         jc        UserMn29                 ; nen° otev©eno ë†dnÇ menu
         mov       bx,MousXKod+MousXMov     ; p©°znak posunu
         call      far ptr MouseMnu         ; test, zda je my® v menu
         jnc       UserMn56                 ; nastaven° aktivn° poloëky menu
         jmp       UserMnu7                 ; jinak p©eru®en° menu

; ------ adresa aktivn°ho menu -> DS:SI, ES

UserMnu3:call      UserMGet                 ; definice aktivn°ho menu
         jc        UserMn29                 ; nen° otev©eno ë†dnÇ menu

; ------ nastaven° intenzity displeje

         test      byte ptr es:[UMenPrm1],bit1 ; je intenzita uráena ?
         jz        UserMnu5                 ; nen° uráena
         mov       al,1                     ; intenzivn° pozad°
         test      byte ptr es:[UMenPrm1],bit2 ; je intenzivn° pozad° ?
         jnz       UserMnu4                 ; je intenzivn° pozad°
         mov       al,0
UserMnu4:call      far ptr Intens           ; nastaven° intenzity displeje

; ------ obsluha menu

UserMnu5:call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         test      byte ptr ds:[ParMenu],bit4 ; je automatickÇ vno©en° do menu ?
         jz        UserMn54                 ; nen° automatickÇ vno©en° do menu

         call      UserMGet                 ; definice aktivn°ho menu
         mov       bx,es:[UMenLinK]         ; ©†dek s kurzorem
         cmp       bx,es:[UMenLinN]         ; je to platnò ©†dek ?
         jae       UserMn54                 ; nen° to platnò ©†dek
         add       bx,es:[UMenParI]         ; parametr ©†dku
         test      byte ptr es:[bx],bit6    ; je navazuj°c° podmenu ?
         mov       bx,1c0dh                 ; kl†vesa ENTER
         jnz       UserMn56                 ; je navazuj°c° podmenu
         and       byte ptr ds:[ParMenu],not bit4 ; ukonáen° automat. vno©en°

UserMn54:call      far ptr InpChar          ; vstup znaku z kl†vesnice
         jc        UserMnu7                 ; p©eru®en° ESC

; ------ p©eru®en° menu stiskem pravÇho tlaá°tka nebo stiskem mimo ©†dek

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       UserMn56                 ; nen° k¢d my®i
         and       bl,not bit6              ; zru®en° p©°znaku dvoj°ho stisku
         cmp       bl,MousXRP               ; stisk pravÇho tlaá°tka ?
         je        UserMnu7                 ; p©eru®en° pravòm tlaá°tkem my®i
         call      far ptr MouseMnu         ; test, zda je okno menu
         jnc       UserMn56                 ; je to v oknà
         test      bl,bit2+bit3             ; je stisk nàkterÇho tlaá°tka ?
         jnz       UserMnu7                 ; p©eru®en° stiskem mimo okno

; ------ editace menu

UserMn56:push      cs
         call      near ptr EditCMnu        ; editace menu
         jnc       UserMnu6                 ; byla provedena volba
         or        bx,bx
         jnz       UserMnu5                 ; kl†vesa neobslouëena
         call      far ptr DispMnu          ; novÇ zobrazen° menu
UserMn58:jmp       short UserMnu5

UserMnu6:call      far ptr DispMnu          ; menu se je®tà jednou zobraz°
         test      byte ptr ds:[ParMenu2],bit0 ; m† se navracet menu ?
         jz        UserMn62                 ; menu se nem† navracet
         or        byte ptr ds:[ParMenu2],bit1 ; poëadavek o navr†cen°
UserMn62:jmp       UserExec                 ; proveden° volby

UserMnu7:test      byte ptr ds:[ParMenu],bit7 ; je z†kaz opu®tàn° menu ?
         jz        UserMn72                 ; nen° z†kaz opu®tàn° menu
         cmp       word ptr ds:[NumUserM],1 ; je jië posledn° menu ?
         je        UserMn58                 ; z†kaz posledn°ho menu

UserMn72:call      UserClos                 ; uzav©en° menu
         jmp       UserMn30                 ; obsluha p©ede®lÇho menu

UserMn99:and       byte ptr ds:[ParMenu2],not bit1 ; zru®en° poëadavku opakov†n°
UserM992:call      UserClsA                 ; uzav©en° v®ech menu
         jmp       far ptr Main0

UserMenu ENDP

; -----------------------------------------------------------------------------
;        proveden° p©°kazu z funkán° kl†vesy BX (nen°-li kl†vesa, vr†t° se)
; -----------------------------------------------------------------------------
;˛
UserFnc  PROC      FAR

; ------ vyhled†n° kl†vesy

         cld
         mov       ax,bx
         mov       di,offset UserFnT1       ; tabulka kl†ves
         push      cs
         pop       es
         mov       cx,offset(UserFnT2-UserFnT1)/2 ; poáet kl†ves
         repne     scasw                    ; nalezen° k¢du kl†vesy
         je        UserFnc2                 ; kl†vesa nalezena OK

; ------ test, zda je funkán° kl†vesa

         mov       al,bh                    ; AL <- SCAN k¢d kl†vesy
         sub       al,5eh-1                 ; offset kl†vesy
         jbe       UserFn19                 ; neplatn† kl†vesa
         cmp       al,2*10                  ; maxim†ln° k¢d kl†vesy
         ja        UserFn19                 ; neplatn† kl†vesa

; ------ á°slo funkán° kl†vesy

         cmp       al,10
         jbe       UserFn13
         sub       al,10

; ------ p©esmykaá

UserFn13:or        al,bit4+bit5             ; Ctrl-Shift
         cmp       bl,4
         je        UserFn22
         xor       al,(bit6+bit4) XOR (bit5+bit4) ; Alt-Shift
         cmp       bl,5
         je        UserFn22
         xor       al,(bit6+bit5) XOR (bit6+bit4) ; Ctrl-Alt
         cmp       bl,6
         je        UserFn22

; ------ kl†vesa nenalezena - n†vrat

UserFn19:ret

; ------ k¢d nalezenÇ kl†vesy

UserFnc2:add       sp,4                     ; zru®en° n†vratovÇ adresy

         sub       di,offset UserFnT1+2
         shr       di,1
         mov       al,cs:[di+UserFnT2]      ; k¢d kl†vesy

; ------ p©°prava oznaáen° kl†vesy (AL=á°slo, bit4=SHIFT, bit5=CTRL, bit6=ALT)

UserFn22:mov       di,offset HotKFT+1
         push      ds
         pop       es
         mov       ah,al

         push      ax
         mov       cl,4
         shr       ah,cl

         shr       ah,1
         jnc       UserFn23
         mov       al,"S"
         stosb

UserFn23:shr       ah,1
         jnc       UserFn24
         mov       al,"C"
         stosb

UserFn24:shr       ah,1
         jnc       UserFn25
         mov       al,"A"
         stosb

UserFn25:mov       al,"F"
         stosb

         pop       ax
         and       al,0fh
         add       al,"0"
         stosb                              ; á°slo kl†vesy
         cmp       al,"9"
         jbe       UserFn26
         sub       al,10
         mov       byte ptr ds:[di-1],"1"
         stosb

UserFn26:sub       di,offset HotKFT+1
         xchg      ax,di
         mov       ds:[HotKFT],al

; ------ otev©en° skupiny

         mov       si,offset HotKeyT        ; skupina [HotKey]
         call      far ptr OpenGIni         ; otev©en° skupiny parametrñ
         jc        UserFnc9                 ; nàjak† chyba

; ------ nalezen° parametru

         mov       si,offset HotKFT         ; jmÇno parametru
         call      far ptr OpenPIni         ; otev©en° parametru
         jc        UserFnc8                 ; parametr nenalezen

; ------ proveden° p©°kazu

UserFnc3:mov       si,di                    ; SI <- adresa ©†dku
         mov       word ptr ds:[NumUserM],0 ; nen° ë†dnÇ menu
         mov       ax,ds:[SegmIni]          ; segment INI souboru
         mov       ds:[MnuSegmX],ax         ; n†hradn° segment
;         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         jmp       UserExc0                 ; proveden° p©°kazu

; ------ uzav©en° inicializaán°ho souboru

UserFnc8:call      far ptr ClosIni          ; uzav©en° inicializaán°ho souboru

UserFnc9:jmp       far ptr Main0

UserFnc  ENDP

; ------ á°sla funkán°ch kl†ves

UserFnT1 dw        6a00h                    ; Alt-F3
         dw        6b00h                    ; Alt-F4
         dw        8500h                    ; F11
         dw        8600h                    ; F12
         dw        8700h                    ; Shift-F11
         dw        8800h                    ; Shift-F12
         dw        8900h                    ; Ctrl-F11
         dw        8a00h                    ; Ctrl-F12
         dw        8b00h                    ; Alt-F11
         dw        8c00h                    ; Alt-F12
         dw        8904h                    ; Ctrl-Shift-F11
         dw        8a04h                    ; Ctrl-Shift-F12
         dw        8b05h                    ; Alt-Shift-F11
         dw        8c05h                    ; Alt-Shift-F12
         dw        8b06h                    ; Ctrl-Alt-F11
         dw        8c06h                    ; Ctrl-Alt-F12

; ------ parametry funkán°ch kl†ves (bit4=SHIFT, bit5=CTRL, bit6=ALT)

UserFnT2 db        3+bit6                   ; Alt-F3
         db        4+bit6                   ; Alt-F4
         db        11                       ; F11
         db        12                       ; F12
         db        11+bit4                  ; Shift-F11
         db        12+bit4                  ; Shift-F12
         db        11+bit5                  ; Ctrl-F11
         db        12+bit5                  ; Ctrl-F12
         db        11+bit6                  ; Alt-F11
         db        12+bit6                  ; Alt-F12
         db        11+bit4+bit5             ; Ctrl-Shift-F11
         db        12+bit4+bit5             ; Ctrl-Shift-F12
         db        11+bit4+bit6             ; Alt-Shift-F11
         db        12+bit4+bit6             ; Alt-Shift-F12
         db        11+bit5+bit6             ; Ctrl-Alt-F11
         db        12+bit5+bit6             ; Ctrl-Alt-F12

; -----------------------------------------------------------------------------
;        proveden° p©°kazu pro oznaáenÇ soubory
; -----------------------------------------------------------------------------
;˛
SelcExec label     FAR

; ------ inicializace ukazatelñ

         call      UserExIn                 ; inicializace ukazatelñ

; ------ test, zda je aktivn° okno

         call      far ptr TestAAWn         ; je aktivn° okno ?
         jc        SelcEx12                 ; nen° aktivn° okno

; ------ zad†n° p©°kazu k proveden°

         mov       word ptr ds:[SPOMLPlL],0 ; nen° p©edvolba
         mov       al,ds:[LineCNum]         ; poáet zadanòch znakñ
         cmp       al,0                     ; je nàco zad†no ?
         je        SelcExc1                 ; nen° nic zad†no
         inc       byte ptr ds:[SPOMLPlL]   ; je 1 p©edvolba
         mov       byte ptr ds:[SPOMLPlN],al ; dÇlka p©edvolby

SelcExc1:mov       si,offset SPOMLin        ; zadanò p©°kaz
         call      far ptr Lin0Menu         ; zad†n° p©°kazu
         jc        SelcEx12                 ; p©eru®en°
         cmp       byte ptr ds:[LinNum],0   ; bylo nàco zad†no ?
         je        SelcEx12                 ; nebylo nic zad†no

; ------ inicializace vyhled†v†n° souborñ

         call      far ptr GetAAWin         ; poskytnut° adresy aktivn°ho okna
         cmp       word ptr es:[AWinSNum],0 ; je nàco oznaáeno ?
         jne       SelcEx10                 ; je nàco oznaáeno
         mov       bx,es:[AWinKurz]         ; soubor s kurzorem
         call      far ptr GetESPol         ; kurzor okna
         cmp       byte ptr es:[si+FileName],"." ; je to adres†© ".." ?
         mov       al,bit2+bit7             ; v®echny soubory
         je        SelcEx11                 ; oznaáen° v®ech poloëek
SelcEx10:mov       al,bit1+bit7             ; oznaáenÇ soubory
SelcEx11:call      far ptr InitFFil         ; inicializace vyhled†v†n°
SelcEx12:jc        SelcExc9                 ; nen° ë†dn† poloëka
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek

; ------ nalezen° dal®°ho souboru pro operaci -> ES:SI/CX

SelcExc2:call      far ptr GetFFil          ; nalezen° jmÇna souboru
         jc        SelcExc4                 ; nen° dal®° soubor

; ------ dek¢dov†n° jednoho p©°kazu do bufferu

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset LinBuff        ; buffer zadanÇho p©°kazu
         mov       bl,ds:[LinNum]           ; dÇlka zadanÇho p©°kazu
         mov       bh,0
         mov       ds:[si+bx],bh            ; oznaáen° konce textu
         call      far ptr UserDekX         ; dek¢dov†n° ©†dku pro p©°kaz
         or        byte ptr ds:[UserSwcM],bit7 ; p©°znak prvn°ho p©°kazu

; ------ vytvo©en° povelovÇho souboru $DOSMAN$.BAT

         mov       ax,ds:[DBatIdnt]         ; identifik†tor $DOSMAN$.BAT
         or        ax,ax
         jnz       SelcExc3                 ; soubor je jië vytvo©en
         call      far ptr OpenBPth         ; otev©en° souboru $DOSMAN$.BAT
         jc        SelcExc4                 ; chyba
         mov       ds:[DBatIdnt],ax         ; £schova identifik†toru

; ------ z†pis ©†dku "ECHO OFF"

         push      ds
         pop       es
         mov       si,offset EchoTxt        ; text k z†pisu
         mov       cx,offset(EchoTxt0-EchoTxt)
         call      far ptr WritFile         ; z†pis ©†dku do souboru

; ------ z†pis ©†dku do $DOSMAN$.BAT

SelcExc3:call      WritUBat                 ; z†pis ©†dku do souboru
         jnc       SelcExc2                 ; dal®° p©°kaz

; ------ uzav©en° reëimu hled†n° souborñ

SelcExc4:call      far ptr ClosFFil         ; ukonáen° reëimu hled†n°

; ------ obsluha p©°kazu s $DOSMAN$.BAT

         test      byte ptr ds:[UserSwcM],bit7 ; je p©°kaz ?
         jz        SelcExc9                 ; nen° p©°kaz
         cmp       word ptr ds:[DBatIdnt],0 ; je $DOSMAN$.BAT ?
         je        SelcExc9                 ; nen° $DOSMAN$.BAT
         jmp       UserEx81                 ; proveden° p©°kazu

SelcExc9:jmp       far ptr Main0            ; nen° aktivn° okno

; -----------------------------------------------------------------------------
;        dek¢dov†n° p©°kazovÇho ©†dku podle p©°pony
; -----------------------------------------------------------------------------
;˛
Extens   label     FAR

; ------ inicializace ukazatelñ pro operaci

         call      UserExIn                 ; inicializace ukazatelñ

; ------ otev©en° skupiny parametrñ "Extension"

         mov       si,offset ExtnsTxt       ; skupina p©°pon
         call      far ptr OpenGIni         ; otev©en° skupiny parametrñ
         jnc       Extens1
Extens0: jmp       Extens8                  ; nen° skupina nebo chyba

; ------ p©°prava k vyhled†n° definice

Extens1: mov       ax,ds:[SegmIni]          ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        Extens0                  ; chyba
         mov       di,ds:[GroupAdr]         ; adresa nalezenÇ skupiny
         mov       bx,es:[InitByts]         ; konec dat
         cld

; ------ test, zda je konec skupiny

Extens2: cmp       di,bx
         jae       Extens0                  ; je konec dat
         cmp       byte ptr es:[di],"["     ; je dal®° skupina ?
         je        Extens0                  ; je dal®° skupina

; ------ test, zda je platnò ©†dek

         cmp       byte ptr es:[di]," "
         jbe       Extens22
         cmp       byte ptr es:[di],";"
         je        Extens22
         cmp       byte ptr es:[di],":"
         je        Extens22

; ------ test, zda hledanò soubor odpov°d†

         call      TestExt                  ; text p©°pony, zda odpov°d†
         jnc       Extens24                 ; p©°pona nalezena

; ------ nalezen° dal®°ho ©†dku

Extens22:inc       di                       ; zvò®en° ukazatele dat
         cmp       di,bx                    ; je konec dat ?
         jae       Extens0                  ; je konec dat
         cmp       byte ptr es:[di-1],LF    ; nalezen dal®° ©†dek ?
         jne       Extens22                 ; nalezen° dal®°ho ©†dku
         jmp       short Extens2            ; test dal®°ho ©†dku

; ------ proveden° p©°kazu

Extens24:mov       si,di                    ; SI <- adresa ©†dku
         mov       byte ptr ds:[LineCNum],0 ; nen° nic v p©°kazovÇm ©†dku
         mov       word ptr ds:[NumUserM],0 ; nen° ë†dnÇ menu
         mov       ax,ds:[SegmIni]          ; segment INI souboru
         mov       ds:[MnuSegmX],ax         ; n†hradn° segment
         jmp       UserEx12                 ; proveden° p©°kazu

; ------ uzav©en° inicializaán°ho souboru

Extens8: mov       byte ptr ds:[LineCNum],0 ; nen° nic v p©°kazovÇm ©†dku
         call      far ptr ClosIni          ; uzav©en° inicializaán°ho souboru
         jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        test p©°pony, zda odpov°d† ES:DI (BX=konec) (CY=neodpov°d†) -> DI=konec
; -----------------------------------------------------------------------------

TestExt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      es

; ------ p©enesen° textu do bufferu LINBUFF

         mov       si,offset LinBuff
         xor       cx,cx
TestExt1:cmp       di,bx
         jae       TestExt3
         mov       al,es:[di]
         cmp       al,TAB
         jne       TestExt2
         mov       al," "
TestExt2:cmp       al," "
         jb        TestExt3
         cmp       al,";"
         je        TestExt3
         inc       di
         cmp       al,":"
         je        TestExt3
         mov       ds:[si],al
         inc       si
         inc       cx
         cmp       cl,255
         jb        TestExt1

; ------ normalizace textu masky

TestExt3:mov       ds:[LinNum],cl           ; dÇlka textu
         call      far ptr RedLMnu          ; redukce ©†dku textu
         stc
         mov       cl,ds:[LinNum]           ; nov† dÇlka textu
         jcxz      TestExt9                 ; nen° ë†dnò platnò znak

; ------ adresa poloëky pod kurzorem -> ES:SI

         call      far ptr GetAKurz         ; poskytnut° poloëky pod kurzorem
         jc        TestExt9                 ; nen° ë†dn† poloëka
         inc       si                       ; zaá†tek jmÇna poloëky

; ------ porovn†n° poloëky s maskou -> CF

         push      di
         mov       di,offset LinBuff        ; buffer textu masky
         call      far ptr TestMask         ; porovn†n° jmÇna souboru
         pop       di

; ------ n†vrat registrñ

TestExt9:pop       es
         pop       si
         pop       cx
         pop       ax
         ret

TestExt  ENDP

; -----------------------------------------------------------------------------
;        vykon†n° volby menu
; -----------------------------------------------------------------------------
;˛
; ------ £schova kurzoru

UserExec:call      UserMGet                 ; adresa menu
         mov       ax,es:[UMenVolK]         ; volba s kurzorem
         mov       si,ds:[NumUserM]         ; á°slo aktivn°ho menu
         or        si,si
         jz        UserEx04                 ; nen° ë†dnÇ menu (?)
         dec       si                       ; offset á°sla menu
         shl       si,1                     ; offset menu v tabulce
         cmp       ax,ds:[si+UserLast]      ; volba zmànàna ?
         je        UserEx04                 ; kurzor zñst†v†
UserEx02:mov       ds:[si+UserLast],ax      ; £schova novÇho kurzoru
         xor       ax,ax                    ; AX <- 0 nulov†n° dal®°ho menu
         inc       si
         inc       si                       ; dal®° poloëka
         cmp       si,2*MaxUserM            ; konec tabulky ?
         jb        UserEx02                 ; dal®° poloëka

; ------ adresa ©†dku zaá†tku volby ES:SI

UserEx04:call      UserMGet                 ; poskytnut° adresy menu
         mov       si,es:[UMenLinK]         ; ©†dek s kurzorem
         shl       si,1                     ; offset v tabulce indexñ
         add       si,es:[UMenLinI]         ; adresa indexu
         mov       si,es:[si]               ; offset ©†dku v souboru
         add       si,es:[UMenAdrF]         ; adresa ©†dku v bufferu

; ------ p©°prava ukazatelñ

UserExc0:call      UserExIn                 ; inicializace ukazatelñ

; ------ nalezen° dal®°ho ©†dku

UserExc1:call      ReadUML                  ; nalezen° dal®°ho ©†dku
         jnc       UserEx12
UserEx11:jmp       UserExc7                 ; nen° dal®° ©†dek

; ------ vypu®tàn° mezer ze zaá†tku ©†dku

UserEx12:mov       ah,0bh
         int       21h                      ; obsluha p©eru®en° z kl†vesnice
         call      far ptr TestBreak        ; test p©eru®en° funkce
         jnc       UserEx13
UsrEx122:jmp       UserExc9                 ; p©eru®en°

UserEx13:cmp       word ptr es:[si],CR+LF*HI
         je        UserExc1                 ; pr†zdnò ©†dek - dal®° ©†dek
         cmp       byte ptr es:[si],LF
         je        UserExc1                 ; pr†zdnò ©†dek - dal®° ©†dek

         call      UserSpcL                 ; vypu®tàn° mezer z prvn°ho ©†dku
         jnc       UserExc3                 ; je platnò ©†dek p©°kazu

; ------ test, zda je ©°dic° ©†dek

         cmp       word ptr es:[si],"?#"
         je        UserExc1                 ; n†povàda - p©eskoáen°
         cmp       word ptr es:[si],"*#"
         je        UserEx11                 ; podnadpis - konec
         cmp       word ptr es:[si],".#"
         je        UserExc2

; ------ test, zda je ©†dek platnò

         call      TestBlok                 ; test blokov†n°
         jne       UserExc1                 ; je blokov†n° tàla FOR

; ------ vno©en° do podmenu

         cmp       byte ptr es:[si],"#"
         jne       UserExc7                 ; je dal®° volba - konec
         inc       si                       ; p©eskoáen° znaku "#"
         call      UserSubM                 ; vno©en° do podmenu
UserEx18:jmp       UserMnu3                 ; obsluha vno©enÇho menu

UserEx19:jmp       short UserExc1

; ------ test, zda je ©†dek platnò

UserExc2:call      TestBlok                 ; test blokov†n°
         jne       UserEx22                 ; je blokov†n° tàla FOR

; ------ obsluha ©°dic°ho ©†dku "#."

         call      ReadUPS                  ; naáten° promànnÇ SET, VAL a GET
         jc        UserEx18                 ; p©eru®en° operace
         call      ReadUDB                  ; obsluha prohl°ëeáe DBF
         call      ReadUNO                  ; obsluha editoru NOT
         call      ReadUNT                  ; obsluha editoru TAB

UserEx22:call      ReadUPM                  ; naáten° parametru z ©†dku

         cmp       word ptr ds:[AdresFor],0 ; je n†vrat adresy cyklu ?
         je        UserEx19                 ; nen° n†vrat adresy cyklu
         xor       si,si                    ; SI <- p©°znak neplatnosti adresy
         xchg      si,ds:[AdresFor]         ; n†vrat adresy cyklu FOR
         jmp       UserEx12

; ------ test, zda je to pr†zdnò ©†dek

UserExc3:;cmp       byte ptr es:[si],CR
         ;je        UserExc1                 ; pr†zdnò ©†dek - dal®° ©†dek
         ;cmp       byte ptr es:[si],LF
         ;je        UserExc1                 ; pr†zdnò ©†dek - dal®° ©†dek

; ------ test, zda je ©†dek platnò

         call      TestBlok                 ; test blokov†n°
         jne       UserEx62                 ; je blokov†n° tàla FOR

; ------ test, zda je to prvn° p©°kaz

         test      byte ptr ds:[UserSwcM],bit7 ; byl jië prvn° p©°kaz ?
         jz        UserExc6                 ; nebyl je®tà prvn° p©°kaz

; ------ vytvo©en° povelovÇho souboru $DOSMAN$.BAT

         mov       ax,ds:[DBatIdnt]         ; identifik†tor $DOSMAN$.BAT
         or        ax,ax
         jnz       UserExc4                 ; soubor je jië vytvo©en
         call      far ptr OpenBPth         ; otev©en° souboru $DOSMAN$.BAT
         jc        UserEx80                 ; chyba
         mov       ds:[DBatIdnt],ax         ; £schova identifik†toru

; ------ z†pis ©†dku do $DOSMAN$.BAT

UserExc4:call      WritUBat                 ; z†pis ©†dku do souboru
         jc        UserEx80                 ; chyba

; ------ dek¢dov†n° dal®°ho p©°kazu do bufferu

UserExc6:call      far ptr UserDekX         ; dek¢dov†n° ©†dku pro p©°kaz
         jc        UserEx62                 ; nen° nic v p©°kaz. ©†dku
         or        byte ptr ds:[UserSwcM],bit7 ; p©°znak prvn°ho p©°kazu
UserEx62:jmp       UserExc1                 ; dal®° ©†dek

; ------ konec - test, zda byl proveden nàjakò p©°kaz

UserExc7:test      byte ptr ds:[UserSwcM],bit7 ; byl nàjakò p©°kaz ?
         jnz       UserExc8                 ; byl nàjakò p©°kaz

         test      byte ptr ds:[UserSwcM],bit1 ; byl povel "!" ?
         jz        UserEx74                 ; nebyl povel "!"
         test      byte ptr ds:[UserSwcM],bit2 ; je m¢d spou®tàn° BAT ?
         jz        UserEx74                 ; nen° m¢d spou®tàn° BAT
         jmp       far ptr Konec            ; zad†n konec programu

UserEx74:;call      far ptr UserClsA         ; uzav©en° v®ech oken menu
;         call      UserMGet                 ; definice aktivn°ho menu
;         call      far ptr DispMnu          ; menu se je®tà jednou zobraz°
         jmp       UserMnu3                 ; n†vrat do menu

;         jmp       UserM992

; ------ z†pis posledn°ho ©†dku do $DOSMAN$.BAT

UserExc8:mov       ax,ds:[DBatIdnt]         ; identifik†tor $DOSMAN$.BAT
         or        ax,ax
         jz        UserEx82                 ; soubor nen° vytvo©en
         call      WritUBat                 ; z†pis posledn°ho ©†dku do souboru
UserEx80:jc        UserExc9                 ; chyba z†pisu
UserEx81:call      far ptr TestBreak        ; je p©eru®en° ?
         jc        UserExc9                 ; je p©eru®en° operace
         call      ClosUBat                 ; uzav©en° souboru $DOSMAN$.BAT

; ------ sestaven° p©°kazu $DOSMAN$.BAT (zniá° registry ES a SI !)

         push      ds
         pop       es
         mov       di,offset LineCBuf
         mov       si,offset DosmBat
         call      far ptr TempFile         ; sestaven° jmÇna souboru
         sub       di,offset LineCBuf
         xchg      ax,di
         mov       ds:[LineCNum],al         ; dÇlka p©°kazu
         or        byte ptr ds:[ProgSwc],bit7 ; je $DOSMAN$.BAT

; ------ sestaven° seznamu oznaáenòch souborñ (niá° registry !)

UserEx82:test      byte ptr ds:[UserSwcM],bit0 ; generuje se seznam ?
         jz        UserEx84                 ; seznam se negeneruje
         call      UserSezn                 ; vygenerov†n° seznamu souborñ

; ------ uzav©en° oken a skok na proveden° p©°kazu

UserEx84:call      far ptr UserClsA         ; uzav©en° v®ech oken menu
         or        byte ptr ds:[ProgSwc2],bit0 ; je p©°kaz z EXTENSION/MENU
         and       byte ptr ds:[StartPar],not bit1 ; nen° aktualizace INI souboru
         jmp       far ptr ProgrExe         ; proveden° p©°kazu


; ------ chyba z†pisu do souboru $DOSMAN$.BAT

UserExc9:mov       byte ptr ds:[LineCNum],0 ; nen° nic v p©°kazovÇm ©†dku
         call      ClosUBat                 ; uzav©en° souboru $DOSMAN$.BAT
         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         jmp       UserMn99



; ------ uzav©en° souboru $DOSMAN$.BAT

ClosUBat:mov       ax,ds:[DBatIdnt]         ; identifik†tor souboru $DOSMAN$.BAT
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ds:[DBatIdnt],ax         ; oznaáen°, ëe soubor je zru®enò
         ret

; ------ z†pis ©†dku do souboru $DOSMAN$.BAT

WritUBat:push      ax
         push      cx
         push      si
         push      es

         mov       ax,ds:[DBatIdnt]         ; identifik†tor souboru
         push      ds
         pop       es
         mov       si,offset LineCBuf       ; buffer
         mov       ch,0
         mov       cl,ds:[LineCNum]
         inc       cx
         inc       cx                       ; váetnà koncovÇho CR/LF
         call      far ptr WritFile         ; z†pis ©†dku do souboru

         pop       es
         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        test blokov†n° (NZ=je blokov†n°)
; -----------------------------------------------------------------------------

TestBlok PROC      NEAR

         cmp       word ptr ds:[BlokFor],0  ; je blokov†n° tàla FOR ?
         jne       TestBlk2                 ; ©†dek neplat°
TestBlk1:cmp       word ptr ds:[LevelCAS],0 ; je ©†dek vypnut ?
         jne       TestBlk2                 ; ©†dek neplat°
         cmp       word ptr ds:[LevelIF],0  ; je ©†dek vypnut ?
TestBlk2:ret

TestBlok ENDP

; -----------------------------------------------------------------------------
;        nulov†n° ukazatelñ pro menu
; -----------------------------------------------------------------------------

UserExIn PROC      NEAR

         and       byte ptr ds:[ProgSwc],not bit7 ; nen° $DOSMAN$.BAT
         mov       byte ptr ds:[UserSwcM],0 ; p©°znaky
         xor       ax,ax
         mov       ds:[BlokFor],ax          ; blokov†n° tàla FOR
         mov       ds:[LevelIF],ax          ; á°taá vno©en° IF
         mov       ds:[LevelCAS],ax         ; á°taá vno©en° CASE
         dec       ax                       ; AX <- -1
         mov       ds:[UMnCaseN],ax         ; nen° ©etàzec CASE
         mov       byte ptr ds:[UParmFor],bit0 ; FOR se obsluhuje
         call      far ptr NulBreak
         ret

UserExIn ENDP

; -----------------------------------------------------------------------------
;        obsluha intern°ho prohl°ëeáe DBF
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text ©†dku (zaá°n† #.)
; VùSTUP: ES=novò segment menu (pokud byl zmànàn)
; -----------------------------------------------------------------------------

ReadUDB  PROC      NEAR

         push      ax
         push      si

         inc       si                       ; p©eskoáen° znaku "#"

; ------ nalezen° zaá†tku parametru (vypu®tàn° mezer)

ReadUDB1:inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         cmp       al," "                   ; mezera ?
         je        ReadUDB1                 ; mezera se p©eskoá°
         cmp       al,TAB                   ; tabul†tor ?
         je        ReadUDB1                 ; tabul†tor se p©eskoá°

; ------ test, zda je parametr DBF

         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"D"
         jne       ReaUDB12                 ; nen° parametr DBF

         inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"B"
         jne       ReaUDB12                 ; nen° parametr DBF

         inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         call      far ptr UpCase           ; konvzerze na velkÇ p°smeno
         cmp       al,"F"
         je        ReaUDB14                 ; je to parametr DBF
ReaUDB12:jmp       ReadUDB9

; ------ £schova registrñ

ReaUDB14:push      bx
         push      cx
         push      dx
         push      di
         push      bp
         mov       bp,sp
         sub       sp,FileMax + 30

; ------ nalezen° zaá†tku parametru (vypu®tàn° mezer)

ReadUDB2:inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         cmp       al," "                   ; mezera ?
         je        ReadUDB2                 ; mezera se p©eskoá°
         cmp       al,TAB                   ; tabul†tor ?
         je        ReadUDB2                 ; tabul†tor se p©eskoá°

; ------ dek¢dov†n° jmÇna souboru do bufferu

         mov       dx,es                    ; DX <- segment textu
         push      ss
         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
         mov       di,sp                    ; buffer p©°kazovÇho ©†dku
         mov       ch,0                     ; ukazatel pozice na ©†dku
         mov       cl,FileMax               ; maxim†ln° dÇlka textu
         xor       ax,ax                    ; nen° barva
         call      far ptr DekPLine         ; dek¢dov†n° textovÇho ©†dku
         mov       byte ptr es:[di],0       ; oznaáen° konce textu

; ------ normalizace jmÇna souboru

         mov       cx,di                    ; konec textu
         mov       si,sp                    ; SI <- zaá†tek textu
         sub       cx,si                    ; dÇlka textu
         call      far ptr NormFile         ; normalizace jmÇna souboru
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru
         mov       di,si                    ; DI <- jmÇno souboru

; ------ obsluha editoru DBF (adresa jmÇna ES:DI, dÇlka CX)

         mov       byte ptr ds:[SRSMnPl4],0 ; nen° jmÇno souboru
         mov       byte ptr ds:[LinNum],0   ; nen° koment†© k souboru

         push      bp
         call      far ptr ViewDBF          ; obsluha prohl°ëeáe DBF
         pop       bp

; ------ nov† adresa segmentu menu -> ES

         call      UserMGet                 ; poskytnut° segmentu menu
         mov       sp,bp
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx

ReadUDB9:pop       si
         pop       ax
         ret

ReadUDB  ENDP

; -----------------------------------------------------------------------------
;        obsluha intern°ho prohl°ëeáe NOT
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text ©†dku (zaá°n† #.)
; VùSTUP: ES=novò segment menu (pokud byl zmànàn)
; -----------------------------------------------------------------------------

ReadUNO  PROC      NEAR

         push      ax
         push      si

         inc       si                       ; p©eskoáen° znaku "#"

; ------ nalezen° zaá†tku parametru (vypu®tàn° mezer)

ReadUNO1:inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         cmp       al," "                   ; mezera ?
         je        ReadUNO1                 ; mezera se p©eskoá°
         cmp       al,TAB                   ; tabul†tor ?
         je        ReadUNO1                 ; tabul†tor se p©eskoá°

; ------ test, zda je parametr NOT

         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"N"
         jne       ReaUNO12                 ; nen° parametr NOT

         inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"O"
         jne       ReaUNO12                 ; nen° parametr NOT

         inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         call      far ptr UpCase           ; konvzerze na velkÇ p°smeno
         cmp       al,"T"
         je        ReaUNO14                 ; je to parametr NOT
ReaUNO12:jmp       ReadUNO9

; ------ £schova registrñ

ReaUNO14:push      bx
         push      cx
         push      dx
         push      di
         push      bp
         mov       bp,sp
         sub       sp,FileMax + 30

; ------ nalezen° zaá†tku parametru (vypu®tàn° mezer)

ReadUNO2:inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         cmp       al," "                   ; mezera ?
         je        ReadUNO2                 ; mezera se p©eskoá°
         cmp       al,TAB                   ; tabul†tor ?
         je        ReadUNO2                 ; tabul†tor se p©eskoá°

; ------ dek¢dov†n° jmÇna souboru do bufferu

         mov       dx,es                    ; DX <- segment textu
         push      ss
         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
         mov       di,sp                    ; buffer p©°kazovÇho ©†dku
         mov       ch,0                     ; ukazatel pozice na ©†dku
         mov       cl,FileMax               ; maxim†ln° dÇlka textu
         xor       ax,ax                    ; nen° barva
         call      far ptr DekPLine         ; dek¢dov†n° textovÇho ©†dku
         mov       byte ptr es:[di],0       ; oznaáen° konce textu

; ------ normalizace jmÇna souboru

         mov       cx,di                    ; CX <- konec textu
         mov       si,sp                    ; SI <- zaá†tek textu
         sub       cx,si                    ; CX <- dÇlka textu
         call      far ptr NormFile         ; normalizace jmÇna souboru
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru
         mov       di,si                    ; DI <- jmÇno souboru

; ------ obsluha editoru NOT (adresa jmÇna ES:DI, dÇlka CX)

         mov       byte ptr ds:[SRSMnPl4],0 ; nen° jmÇno souboru
         mov       byte ptr ds:[LinNum],0   ; nen° koment†© k souboru
         mov       byte ptr ds:[ZapsTypI],2 ; nezn†mò typ textu

         push      bp
         call      far ptr EditNOT          ; obsluha editoru NOT
         pop       bp

; ------ nov† adresa segmentu menu -> ES

         call      UserMGet                 ; poskytnut° segmentu menu
         mov       sp,bp
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx

ReadUNO9:pop       si
         pop       ax
         ret

ReadUNO  ENDP

; -----------------------------------------------------------------------------
;        obsluha intern°ho prohl°ëeáe TAB
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text ©†dku (zaá°n† #.)
; VùSTUP: ES=novò segment menu (pokud byl zmànàn)
; -----------------------------------------------------------------------------

ReadUNT  PROC      NEAR

         push      ax
         push      si

         inc       si                       ; p©eskoáen° znaku "#"

; ------ nalezen° zaá†tku parametru (vypu®tàn° mezer)

ReadUNT1:inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         cmp       al," "                   ; mezera ?
         je        ReadUNT1                 ; mezera se p©eskoá°
         cmp       al,TAB                   ; tabul†tor ?
         je        ReadUNT1                 ; tabul†tor se p©eskoá°

; ------ test, zda je parametr TAB

         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"T"
         jne       ReaUNT12                 ; nen° parametr TAB

         inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"A"
         jne       ReaUNT12                 ; nen° parametr TAB

         inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         call      far ptr UpCase           ; konvzerze na velkÇ p°smeno
         cmp       al,"B"
         je        ReaUNT14                 ; je to parametr TAB
ReaUNT12:jmp       ReadUNT9

; ------ £schova registrñ

ReaUNT14:push      bx
         push      cx
         push      dx
         push      di
         push      bp
         mov       bp,sp
         sub       sp,FileMax + 30

; ------ nalezen° zaá†tku parametru (vypu®tàn° mezer)

ReadUNT2:inc       si                       ; p©eskoáen° znaku
         mov       al,es:[si]               ; dal®° znak
         cmp       al," "                   ; mezera ?
         je        ReadUNT2                 ; mezera se p©eskoá°
         cmp       al,TAB                   ; tabul†tor ?
         je        ReadUNT2                 ; tabul†tor se p©eskoá°

; ------ dek¢dov†n° jmÇna souboru do bufferu

         mov       dx,es                    ; DX <- segment textu
         push      ss
         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
         mov       di,sp                    ; buffer p©°kazovÇho ©†dku
         mov       ch,0                     ; ukazatel pozice na ©†dku
         mov       cl,FileMax               ; maxim†ln° dÇlka textu
         xor       ax,ax                    ; nen° barva
         call      far ptr DekPLine         ; dek¢dov†n° textovÇho ©†dku
         mov       byte ptr es:[di],0       ; oznaáen° konce textu

; ------ normalizace jmÇna souboru

         mov       cx,di                    ; CX <- konec textu
         mov       si,sp                    ; SI <- zaá†tek textu
         sub       cx,si                    ; CX <- dÇlka textu
         call      far ptr NormFile         ; normalizace jmÇna souboru
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru
         mov       di,si                    ; DI <- jmÇno souboru

; ------ obsluha editoru TAB (adresa jmÇna ES:DI, dÇlka CX)

         mov       byte ptr ds:[SRSMnPl4],0 ; nen° jmÇno souboru
         mov       byte ptr ds:[LinNum],0   ; nen° koment†© k souboru

         push      word ptr ds:[TablPTH0]
         mov       word ptr ds:[TablPTH0],3 ; inicializaán° dÇlka cesty
         push      bp
         call      far ptr ViewTBL          ; obsluha editoru TAB
         pop       bp
         pop       word ptr ds:[TablPTH0]

; ------ nov† adresa segmentu menu -> ES

         call      UserMGet                 ; poskytnut° segmentu menu
         mov       sp,bp
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx

ReadUNT9:pop       si
         pop       ax
         ret

ReadUNT  ENDP

; -----------------------------------------------------------------------------
;        naáten° promànnÇ SET, VAL a GET
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text ©†dku (zaá°n† #.)
; VùSTUP: ES=novò segment menu (pokud byl zmànàn)
;        niá° registr AX !!!!
;        CY=p©eru®en° operace (uëivatelem p©i GET)
; -----------------------------------------------------------------------------

ReadUPS  PROC      NEAR

         push      si
         inc       si                       ; p©eskoáen° znaku "#"
         inc       si                       ; p©eskoáen° znaku "."
         and       byte ptr ds:[UserSwcM],not bit5+bit6 ; nen° VAL ani GET

; ------ nalezen° zaá†tku parametru

         call      ReaUPSM                  ; vypu®tàn° mezer

; ------ p©°prava prvn°ch 2 znakñ

         call      far ptr UpCase           ; konverze prvn°ho znaku na velkÇ p°smeno
         mov       ah,al                    ; AH <- £schova prvn°ho znaku
         inc       si                       ; p©eskoáen° prvn°ho znaku
         mov       al,es:[si]               ; naáten° druhÇho znaku
         call      far ptr UpCase           ; konverze druhÇho znaku na velkÇ p°smeno
         inc       si                       ; zvò®en° ukazatele textu

; ------ test, zda je parametr VAL

         cmp       ax,"VA"
         jne       ReaUPS11                 ; nen° parametr VAL
         mov       al,es:[si]               ; t©et° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"L"
         jne       ReaUPS13
         or        byte ptr ds:[UserSwcM],bit5 ; p©°znak p©°kazu VAL
         jmp       short ReaUPS14

; ------ test, zda je parametr GET

ReaUPS11:cmp       ax,"GE"
         jne       ReaUPS12                 ; nen° parametr GET
         mov       al,es:[si]               ; t©et° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"T"
         jne       ReaUPS13
         or        byte ptr ds:[UserSwcM],bit6 ; p©°znak p©°kazu GET
         jmp       short ReaUPS14

; ------ test, zda je parametr SET

ReaUPS12:cmp       ax,"SE"
         jne       ReaUPS13                 ; nen° parametr SET
         mov       al,es:[si]               ; t©et° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"T"
         je        ReaUPS14
ReaUPS13:clc                                ; p©°znak operace OK
         jmp       ReadUPS9

; ------ £schova registrñ

ReaUPS14:inc       si                       ; p©eskoáen° t©et°ho znaku

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp
         mov       bp,sp
         sub       sp,256 + 130             ; buffer pro text + parametr

; ------ dek¢dov†n° ©†dku do bufferu

ReadUPS2:mov       di,sp                    ; buffer v z†sobn°ku
         mov       dx,es                    ; DX <- segment bufferu s textem
         push      ss
         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
         mov       ch,0                     ; ukazatel pozice na ©†dku
         mov       cl,255                   ; maxim†ln° dÇlka textu
         xor       ax,ax                    ; nen° barva
         call      far ptr DekPLine         ; dek¢dov†n° textovÇho ©†dku
         mov       byte ptr es:[di],0       ; oznaáen° konce textu

; ------ nalezen° zaá†tku jmÇna promànnÇ -> ES:SI

         mov       si,sp                    ; buffer v z†sobn°ku
         call      ReaUPSM                  ; vypu®tàn° mezer
         cmp       al,"="
         jne       ReaUPS32
ReaUPS30:clc                                ; p©°znak operace OK
ReaUPS31:jmp       ReadUPS8

; ------ zji®tàn° dÇlky jmÇna promànnÇ -> CX

ReaUPS32:xor       cx,cx
         mov       di,si                    ; BX <- zaá†tek jmÇna promànnÇ
ReadUPS4:inc       cx
ReadUP42:inc       di
         cmp       byte ptr es:[di]," "
         jb        ReaUPS30                 ; konec textu
         je        ReadUP42                 ; mezera se nepoá°t†
         cmp       byte ptr es:[di],"="
         jne       ReadUPS4

; ------ dek¢dov†n° parametru GET

         test      byte ptr ds:[UserSwcM],bit6 ; je p©°kaz GET ?
         jz        ReadUP43                 ; nen° p©°kaz GET

         push      cx
         push      si
         push      di

; ------ nalezen° zaá†tku textu hl†®en° -> ES:SI

         push      si
         inc       di                       ; p©eskoáen° znaku "="
         mov       si,di                    ; SI <- ukazatel textu
ReaUP421:call      ReaUPSM                  ; vypu®tàn° mezer
         cmp       al,'"'
         jne       ReaUP422
         inc       si                       ; p©eskoáen° znaku "
ReaUP422:mov       word ptr ds:[GetMLPl1+1],si ; offset adresy textu hl†®en°
         mov       word ptr ds:[GetMLPl1+3],ss ; segment adresy textu hl†®en°

; ------ stanoven° dÇlky textu hl†®en°

         dec       si                       ; p©ednastaven°
ReaUP423:inc       si                       ; zvò®en° ukazatele textu
         mov       al,es:[si]               ; p©ipravenò znak
         cmp       al," "
         jb        ReaUP424                 ; konec textu
         cmp       al,'"'
         jne       ReaUP423                 ; nalezen° konce textu
ReaUP424:xchg      ax,si                    ; AX <- konec textu
         sub       ax,word ptr ds:[GetMLPl1+1] ; dÇlka textu
         mov       ds:[GetMLPl1],al         ; dÇlka textu
         pop       si

; ------ adresa a dÇlka promànnÇ pro p©edvolbu

         call      far ptr GetEnv           ; nalezen° promànnÇ
         mov       word ptr ds:[GetMLPlN],0 ; dÇlka parametru = 0
         mov       word ptr ds:[GetMLPlN+2],si ; offset adresy p©edvolby
         mov       word ptr ds:[GetMLPlN+4],es ; segment adresy p©edvolby
         jc        ReaUP426                 ; promànn† nenalezena
ReaUP425:lods      byte ptr es:[si]         ; naáten° znaku
         cmp       al," "                   ; je konec textu ?
         jb        ReaUP426                 ; je konec textu
         inc       word ptr ds:[GetMLPlN]   ; zvò®en° á°taáe dÇlky promànnÇ
         jmp       short ReaUP425           ; dal®° znak

; ------ zad†n° novÇ hodnoty promànnÇ (niá° registry BX a DX !)

ReaUP426:mov       si,offset GetMLin        ; menu pro zad†n°
         call      far ptr Lin0Menu         ; zad†n° novÇ hodnoty promànnÇ
         push      ss
         pop       es                       ; ES <- obnoven° adresy zasobn°ku
         jnc       ReaUP427                 ; nen° p©eru®en° operace
         call      far ptr SetBreak         ; nastaven° p©°znaku p©eru®en°
         jmp       short ReaUP429           ; p©eru®en° operace

; ------ uloëen° zadanÇ hodnoty do bufferu ES:DI

ReaUP427:cld
         mov       ax,'"'                   ; £vod textu + koncov† 0
         stosb
         mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka zadanÇho textu
         mov       si,offset LinBuff        ; buffer s textem
         rep       movsb                    ; uloëen° textu
         stosw                              ; z†vàr textu (+ koncov† 0)
                                        ;* zde je NC
ReaUP429:pop       di
         pop       si
         pop       cx
         jnc       ReadUP43                 ; zad†n° OK
         jmp       ReaUPS31                 ; p©eru®en° operace

; ------ dek¢dov†n° parametru VAL (niá° registry AX, BX a DX !)

ReadUP43:test      byte ptr ds:[UserSwcM],bit5 ; je p©°kaz VAL ?
         jz        ReaUPS46                 ; nen° p©°kaz VAL

         push      si
         push      di

         inc       di                       ; zaá†tek textu
         mov       si,di                    ; SI <- zaá†tek textu
         call      ReadUNum                 ; naáten° vòrazu ES:SI -> BX
         cld
         mov       al,'"'
         stosb
         or        bx,bx
         jns       ReaUPS44
         mov       al,"-"
         stosb
         neg       bx
ReaUPS44:xchg      ax,bx                    ; AX <- á°slo
         xor       dx,dx
         xor       bx,bx
         call      far ptr DekNum           ; dek¢dov†n° vòsledku do bufferu
         mov       ax,'"'                   ; z†vàr textu + koncov† 0
         cld
         stosw                              ; koncovÇ '"' a 0

         pop       di
         pop       si

; ------ nalezen° zaá†tku parametru

ReaUPS46:xor       bx,bx                    ; dÇlka = 0
ReadUPS5:inc       di
         cmp       byte ptr es:[di]," "
         jb        ReadUPS7                 ; konec - nen° parametr
         cmp       byte ptr es:[di],"'"
         je        ReadUP52
         cmp       byte ptr es:[di],'"'
         je        ReadUP52

; ------ obsluha extern°ho modulu

         cmp       byte ptr es:[di],"!"
         jne       ReadUP51
         call      ReadUPXx                 ; spu®tàn° extern°ho modulu
         jmp       short ReadUPS7           ; nastaven° hodnoty promànnÇ

; ------ obsluha extern°ho souboru

ReadUP51:cmp       byte ptr es:[di],"#"
         jne       ReadUPS5
         call      ReadUPEx                 ; naáten° extern°ho parametru
         jmp       short ReadUPS7           ; nastaven° hodnoty promànnÇ

ReadUP52:inc       di

; ------ zji®tàn° dÇlky parametru

         dec       bx
ReadUPS6:inc       bx
         cmp       byte ptr es:[di+bx]," "
         jb        ReadUPS7
         cmp       byte ptr es:[di+bx],"'"
         je        ReadUPS7
         cmp       byte ptr es:[di+bx],'"'
         jne       ReadUPS6

; ------ nastaven° novÇ hodnoty promànnÇ ES:SI/CX na hodnotu DX:DI/BX

ReadUPS7:mov       dx,es                    ; je to ve stejnÇm segmentu
         call      far ptr SetEnv           ; nastaven° hodnoty parametru

; ------ nov† adresa segmentu menu (CY=p©eru®en° operace)

ReadUPS8:pushf
         call      UserMGet                 ; poskytnut° segmentu menu
         popf

         mov       sp,bp
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax

ReadUPS9:pop       si
         ret

ReadUPS  ENDP

; ------ vypu®tàn° mezer -> AL=p©ipravenò znak (CY=konec textu)

ReaUPSM: cld
ReaUPSM2:lods      byte ptr es:[si]         ; naáten° znaku
         cmp       al,TAB
         je        ReaUPSM2                 ; tabul†tor se vypust°
         cmp       al," "
         je        ReaUPSM2                 ; mezera se vypust°
         dec       si                       ; n†vrat ukazatele textu
         ret

; -----------------------------------------------------------------------------
;        naáten° hodnoty promànnÇ ze souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=buffer se jmÇnem souboru-1 (mñëe bòt zakonáeno mezerou atd.),
;              souáasnà tÇë buffer o min. velikosti 50 bajtñ k naáten° souboru
;        BX=0
;        DS=datovò segment
; VùSTUP: ES:DI=zaá†tek textu promànnÇ v tomto bufferu
;         BX=dÇlka textu promànnÇ (mñëe bòt i 0, nap©. nen°-li soubor nalezen)
; -----------------------------------------------------------------------------
; niá° registr AX
; -----------------------------------------------------------------------------

ReadUPEx PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si

; ------ nalezen° zaá†tku jmÇna souboru (p©eskoá° se i poá†teán° znak "#")

         mov       si,di                    ; SI <- ukazatel textu
ReadUPE1:inc       si                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[si]," "     ; je mezera ?
         je        ReadUPE1                 ; mezera se vypust°

; ------ oznaáen° konce jmÇna souboru

         push      si
         dec       si                       ; p©ednastaven°
ReadUPE2:inc       si                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[si]," "     ; je konec jmÇna souboru ?
         ja        ReadUPE2                 ; nen° konec jmÇna souboru
         mov       byte ptr es:[si],0       ; oznaáen° konce jmÇna souboru
         pop       si

; ------ otev©en° souboru (p©i chybà zñst†v† nastaven BX=0)

         call      far ptr OpenR            ; otev©en° souboru
         jc        ReadUPE9                 ; soubor nenalezen (BX=0)

; ------ naáten° souboru -> CX=poáet bajtñ (p©i chybà je CX=0)

         mov       cx,50                    ; dÇlka bufferu
         call      far ptr ReadFile         ; naáten° souboru do bufferu

; ------ uzav©en° souboru

         call      far ptr ClosFile         ; uzav©en° souboru

; ------ oznaáen° konce textu v bufferu

         mov       si,di                    ; SI <- zaá†tek bufferu
         add       si,cx                    ; SI <- konec bufferu
         mov       byte ptr es:[si],0       ; oznaáen° konce textu v bufferu

; ------ nalezen° zaá†tku textu (vypu®tàn° mezer)

         dec       di                       ; p©ednastaven°
ReadUPE3:inc       di                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[di],TAB     ; tabul†tor se vypust°
         je        ReadUPE3
         cmp       byte ptr es:[di]," "     ; mezera se vypust°
         je        ReadUPE3

; ------ nalezen° konce ©†dku s parametrem (BX=0)

         dec       bx                       ; p©ednastaven°
ReadUPE4:inc       bx                       ; zvò®en° á°taáe dÇlky
         cmp       byte ptr es:[di+bx],TAB  ; je tabul†tor ?
         jne       ReadUPE5                 ; nen° tabul†tor
         mov       byte ptr es:[di+bx]," "  ; n†hrada mezerou
ReadUPE5:cmp       byte ptr es:[di+bx]," "  ; je konec ©†dku ?
         jae       ReadUPE4                 ; nen° konec ©†dku - dal®° znak

; ------ vypu®tàn° mezer za parametrem

         inc       bx                       ; p©ednastaven°
ReadUPE6:dec       bx                       ; sn°ëen° dÇlky parametru
         jz        ReadUPE9                 ; je zaá†tek parametru
         cmp       byte ptr es:[di+bx-1]," " ; je koncov† mezera ?
         je        ReadUPE6                 ; mezera z konce se vypust°

; ------ n†vrat registrñ

ReadUPE9:pop       si
         pop       cx
         ret

ReadUPEx ENDP

; -----------------------------------------------------------------------------
;        spu®tàn° extern°ho modulu s p©ed†n°m n†vratovÇho k¢du
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=buffer se jmÇnem programu-1 (mñëe bòt zakonáeno mezerou atd.),
;       (ES=SS !!!!!)
;        DS=datovò segment
; VùSTUP: ES:DI=zaá†tek textu promànnÇ v tomto bufferu
;         BX=dÇlka textu á°sla
; -----------------------------------------------------------------------------
; niá° registr AX
; -----------------------------------------------------------------------------
;˛
ReadUPXx PROC      NEAR

; ------ £schova registrñ

         call      far ptr MouseOff         ; vypnut° kurzoru my®i
         push      ax
         push      cx
         push      dx
         push      si
         push      di                       ; mus° bòt jako posledn° !!!

         call      far ptr GetKurz          ; poskytnut° kurzoru
         mov       cs:[ReaXUPKU],dx         ; £schova kurzoru
         xor       dx,dx                    ; DX <- 0
         call      far ptr SetKurz          ; nastaven° kurzoru do rohu

; ------ nalezen° zaá†tku jmÇna programu (p©eskoá° se i poá†teán° znak "!")

         mov       si,di                    ; SI <- ukazatel textu
ReadUPX1:inc       si                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[si]," "     ; je mezera ?
         je        ReadUPX1                 ; mezera se vypust°

; ------ p©enesen° jmÇna programu

         mov       di,offset ExecPath       ; cesta k programu
         mov       cx,FileMax-1             ; max. dÇlka jmÇna programu
ReadUPX2:mov       al,es:[si]               ; p©ipravenò znak
         cmp       al," "                   ; je konec jmÇna programu ?
         jbe       ReadUPX3                 ; je konec jmÇna programu
         mov       ds:[di],al               ; uloëen° znaku
         inc       si
         inc       di
         loop      ReadUPX2                 ; dal®° znak
ReadUPX3:mov       byte ptr ds:[di],0       ; oznaáen° konce programu

; ------ p©°prava paketu pro spu®tàn° programu

         mov       ax,ds:[EnvSegm]          ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu segmentu -> ES
         mov       ds:[ExecPckE],ax         ; segment prost©ed°

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       di,80h                   ; buffer p©°kazovÇho ©†dku
         mov       ds:[ExecPck0],di         ; offset p©°kazovÇho ©†dku
         mov       ds:[ExecPck1],es         ; segment p©°kazovÇho ©†dku

; ------ p©enesen° parametrñ programu

         cld
         mov       al,0
         stosb                              ; nen° text
ReadUPX4:mov       al,ss:[si]               ; p©ipravenò znak
         cmp       al," "                   ; je konec ?
         jb        ReadUPX5                 ; je konec textu
         inc       si
         stosb                              ; uloëen° znaku
         inc       byte ptr es:[80h]        ; zvò®en° á°taáe dÇlky
         cmp       byte ptr es:[80h],125    ; asi tak maxim†ln° dÇlka
         jb        ReadUPX4                 ; dÇlka je je®tà OK
ReadUPX5:mov       al,CR
         stosb                              ; ukonáovac° znak CR

; ------ zmen®en° bloku pamàti

         mov       bx,ds:[FreeSeg]          ; konec dat v pamàti
         add       bx,800h/16               ; rezerva 2 KB
         cmp       bx,ds:[EndSeg]           ; je za koncem ?
         jbe       ReadUPX6
         mov       bx,ds:[EndSeg]           ; omezen° konce
ReadUPX6:mov       ds:[EndSeg],bx           ; je to konec pamàti
         sub       bx,ds:[TopSeg]           ; to bude nov† velikost bloku
         mov       es,ds:[TopSeg]           ; alokaán° datovò blok pamàti
         mov       ah,4ah
         int       21h                      ; zmen®en° bloku pamàti

; ------ start programu

         push      bp

         mov       cs:[ReaXUPSS],ss         ; £schova registru SS
         mov       cs:[ReaXUPSP],sp         ; £schova registru SP

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       dx,offset ExecPath       ; cesta k programu
         mov       bx,offset ExecPack       ; paket parametrñ
         mov       ax,4b00h
         int       21h                      ; start programu

         mov       ss,cs:[ReaXUPSS]         ; n†vrat registru SS
         mov       sp,cs:[ReaXUPSP]         ; n†vrat registru SP

         pop       bp

; ------ obnoven° registrñ

         mov       ax,SEG Data              ; datovò segment
         mov       ds,ax                    ; DS <- datovò segment
         mov       es,ds:[SegPSP]           ; segment PSP
         mov       byte ptr es:[80h],0      ; nen° nic v p©°kazovÇm ©†dku

; ------ naáten° n†vratovÇho k¢du

         mov       ax,256                   ; n†vratovò k¢d p©i chybà
         jc        ReadUPX7                 ; byla chyba operace
         mov       ah,4dh
         int       21h                      ; naáten° n†vratovÇho k¢du
         mov       ah,0                     ; jen LOW bajt

; ------ dek¢dov†n° n†vratovÇho k¢du do bufferu (DI naspodu z†sobn°ku !)

ReadUPX7:push      ss
         pop       es                       ; ES <- segment v z†sobn°ku

         pop       di                       ; DI <- adresa bufferu
         push      di
         mov       si,di                    ; SI <- £schova zaá†tku bufferu
         xor       bx,bx                    ; BX <- nen° oddàlovaá
         call      far ptr DekNumW          ; dek¢dov†n° á°sla
         mov       al,0                     ; koncov† 0
         cld
         stosb                              ; uloëen° koncovÇ 0
         sub       di,si                    ; DI <- dÇlka á°sla
         dec       di                       ; bez koncovÇ 0

; ------ zvàt®en° alokaán°ho bloku pamàti na maximum

         push      di                       ; DI <- dÇlka á°sla

         mov       bx,ds:[EndSeg]           ; adresa konce bufferu
         mov       cx,-1                    ; p©°rustek
ReaUPX82:mov       ds:[EndSeg],bx           ; je to novò konec dat
ReaUPX83:shr       cx,1                     ; sn°ëen° velikosti p©°rustku
         jcxz      ReaUPX88                 ; konec
         add       bx,cx                    ; p©iáten° p©°rustku
         jc        ReaUPX84                 ; bylo by p©eteáen° pamàti
         push      bx
         sub       bx,ds:[TopSeg]           ; poëadovan† velikost bloku
         mov       es,ds:[TopSeg]           ; alokaán° datovò blok pamàti
         mov       ah,4Ah
         int       21h                      ; nastaven° novÇ velikosti pamàti
         pop       bx
         jnc       ReaUPX82                 ; velikost bloku je platn†
ReaUPX84:sub       bx,cx                    ; n†vrat konce bloku
         jmp       short ReaUPX83           ; dal®° pokus


ReaUPX88:call      far ptr DispAll          ; novÇ zobrazen° obrazovky

         mov       dx,cs:[ReaXUPKU]         ; uschovanò kurzor
         call      far ptr SetKurz          ; n†vrat kurzoru

         pop       bx                       ; BX <- dÇlka á°sla
         push      ss
         pop       es                       ; ES <- SS

; ------ n†vrat registrñ

         pop       di                       ; mus° bòt jako posledn° !
         pop       si
         pop       dx
         pop       cx
         pop       ax
         call      far ptr MouseOn          ; zapnut° kurzoru my®i
         ret

ReadUPXx ENDP

ReaXUPSS dw        0                        ; uschovanò registr SS
ReaXUPSP dw        0                        ; uschovanò registr SP
ReaXUPKU dw        0                        ; uschovanò kurzor

; -----------------------------------------------------------------------------
;        naáten° á°selnÇho vòrazu ES:SI -> BX (hladina souátñ)
; -----------------------------------------------------------------------------

ReadUNum PROC      NEAR

         push      ax

         call      ReadU1Nm                 ; naáten° operac° n†soben°

ReadUNu1:call      ReadUNC                  ; naáten° znaku
         jc        ReadUNu9                 ; nen° dal®° znak
         cmp       al,")"                   ; konec vòrazu ?
         je        ReadUNu9                 ; konec vòrazu

         cmp       al,"+"                   ; p©iáten° ?
         jne       ReadUNu2
         xchg      ax,bx                    ; AX <- st©adaá
         call      ReadU1Nm                 ; naáten° dal®° sekce n†soben°
         add       bx,ax                    ; p©iáten° dal®°ho sá°tance
         jmp       short ReadUNu1

ReadUNu2:cmp       al,"-"                   ; odeáten° ?
         jne       ReadUNu3
         xchg      ax,bx                    ; AX <- st©adaá
         call      ReadU1Nm                 ; naáten° dal®° sekce n†soben°
         sub       ax,bx                    ; odeáten° od st©adaáe
         xchg      ax,bx                    ; BX <- novò st©adaá
         jmp       short ReadUNu1

ReadUNu3:cmp       al,";"                   ; konec vòrazu ?
         jne       ReadUNu1                 ; nen° konec - dal®° znak

ReadUNu9:pop       ax
         ret

ReadUNum ENDP

; -----------------------------------------------------------------------------
;        naáten° operac° n†soben° a dàlen° ES:SI -> BX (hladina n†soben°)
; -----------------------------------------------------------------------------

ReadU1Nm:push      ax
         push      dx

         call      ReadUNm                  ; naáten° prvn°ho operandu

ReadU1N1:call      ReadUNC                  ; dal®° znak
         jc        ReadU1N9                 ; nen° dal®° znak
         cmp       al,"*"                   ; je n†soben° ?
         jne       ReadU1N2                 ; nen°

         xchg      ax,bx                    ; AX <- st©adaá
         call      ReadUNm                  ; naáten° dal®°ho á°sla
         imul      bx                       ; vyn†soben° st©adaáe á°slem
         xchg      ax,bx                    ; BX <- novò st©adaá
         jmp       short ReadU1N1

ReadU1N2:cmp       al,"/"                   ; je dàlen° ?
         jne       ReadU1N4                 ; nen°

         xchg      ax,bx                    ; AX <- st©adaá
         call      ReadUNm                  ; naáten° dal®°ho á°sla
         cwd                                ; p©evod na dvojslovo
         or        bx,bx                    ; je dàlitel = 0 ?
         jz        ReadU1N1                 ; dàlitel = 0
         idiv      bx                       ; vydàlen° á°sla
         xchg      ax,bx                    ; BX <- novò st©adaá
         jmp       short ReadU1N1

ReadU1N4:dec       si

ReadU1N9:pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        naáten° operandu ES:SI -> BX (CY=nen°, BX=0)
; -----------------------------------------------------------------------------

ReadUNm: push      ax
         push      dx

         xor       bx,bx                    ; BX <- st©adaá
ReadUNm0:call      ReadUNC                  ; naáten° dal®°ho znaku
         jc        ReadUNm8

         cmp       al,"+"
         je        ReadUNm0

         cmp       al,"("
         jne       ReadUNm1

         cmp       sp,MinSP                 ; minim†ln° adresa SP
         jb        ReadUNm8                 ; chyba

         pop       dx
         pop       ax
         jmp       ReadUNum                 ; naáten° á°sla

ReadUNm1:cmp       al,"-"
         jne       ReadUNm3
         cmp       sp,MinSP                 ; minim†ln° adresa SP
         jb        ReadUNm8                 ; chyba
         call      ReadUNm                  ; naáten° á°sla
         jc        ReadUNm8                 ; chyba
         neg       bx                       ; negace
         jmp       short ReadUNm7

ReadUNm3:call      ReadUN0                  ; test prvn° á°slice AL
         jc        ReadUNm8                 ; nen° á°slo

ReadUNm4:mov       ah,0
         push      ax
         mov       ax,10
         mul       bx                       ; vyn†soben° st©adaáe
         pop       bx

         add       bx,ax                    ; p©iáten° ke st©adaái
         js        ReadUNm5                 ; je p©eteáen°
         adc       dx,dx                    ; p©enos
         jz        ReadUNm6                 ; nen° p©eteáen°
ReadUNm5:mov       bx,7fffh                 ; omezen° velikosti á°sla
ReadUNm6:call      ReadUN                   ; naáten° dal®° á°slice
         jnc       ReadUNm4                 ; je dal®° á°slice

ReadUNm7:clc                                ; p©°znak, ëe je á°slo OK

ReadUNm8:pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        naáten° á°slice ES:SI -> AL (CY=nen°)
; -----------------------------------------------------------------------------

ReadUN:  call      ReadUNC
         jc        ReadUN2

ReadUN0: cmp       al,"9"
         ja        ReadUN1
         sub       al,"0"
         jae       ReadUN2

ReadUN1: dec       si
         stc
ReadUN2: ret

; -----------------------------------------------------------------------------
;        naáten° znaku ES:SI -> AL (CY=konec)
; -----------------------------------------------------------------------------

ReadUNC: mov       al,es:[si]
         inc       si
         cmp       al,","
         je        ReadUNC
         cmp       al,"."
         je        ReadUNC
         cmp       al,'"'
         je        ReadUNC
         cmp       al," "
         je        ReadUNC

         call      far ptr UpCase

         cmp       al,0
         clc
         jne       ReadUNC8
         dec       si
         stc
ReadUNC8:ret

; -----------------------------------------------------------------------------
;        generov†n° seznamu oznaáenòch souborñ (neuchov†v† registry)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) identifik†tor souboru seznamu
; -----------------------------------------------------------------------------

UserSezn PROC      NEAR

; ------ test, zda je otev©eno aktivn° okno

         call      far ptr TestAAWn
         jnc       UserSzn1                 ; aktivn° okno je otev©eno OK
         ret

; ------ sestaven° jmÇna souboru seznamu

UserSzn1:mov       bp,sp
         sub       sp,FileMax+30            ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       si,offset ListMNam       ; jmÇno souboru
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ vytvo©en° souboru

         mov       word ptr ss:[bp-2],0     ; nen° soubor
         test      byte ptr ds:[TempDirP],bit0 ; je z†kaz z†pisu ?
         jz        UserSz10                 ; nen° z†kaz z†pisu
         stc                                ; p©°znak chyby
UsrSz101:jmp       UserSzn3                 ; je z†kaz z†pisu
UserSz10:mov       si,sp
         call      far ptr CreatFil         ; vytvo©en° souboru
         jc        UsrSz101                 ; chyba vytvo©en° seznamu
         mov       ss:[bp-2],ax             ; identifik†tor souboru

; ------ je-li oznaáen° v neaktivn°m oknà, ale v aktivn°m nic, je jen neaktivn° okno

         call      far ptr GetAAWin         ; poskytnut° aktivn°ho okna
         cmp       word ptr es:[AWinSNum],0 ; je nàco oznaáeno ?
         jne       UserSz11                 ; je nàco oznaáeno
         test      byte ptr ds:[UserSwM2],bit4 ; zak†z†no druhÇ okno ?
         jnz       UsrSz102                 ; druhÇ okno je zak†z†no
         call      far ptr TestNAWn         ; test zapnut° neaktivn°ho okna
         jc        UsrSz102                 ; neaktivn° okno nen° zapnuto
         call      far ptr GetNAWin         ; poskytnut° neaktivn°ho okna
         cmp       word ptr es:[AWinSNum],0 ; je nàco oznaáeno ?
         jne       UserSz4A                 ; je nàco oznaáeno

UsrSz102:call      far ptr GetAAWin         ; poskytnut° adresy aktivn°ho okna
         mov       bx,es:[AWinKurz]         ; soubor s kurzorem
         call      far ptr GetESPol         ; kurzor okna
         cmp       byte ptr es:[si+FileName],"." ; je to adres†© ".." ?
         je        UsrSz112                 ; oznaáen° v®ech poloëek

; ------ inicializace vyhled†v†n° souborñ

UserSz11:mov       al,bit1+bit6+bit7        ; oznaáenÇ soubory+adres†©e+vno©en°
         test      byte ptr ds:[UserSwM2],bit5 ; v®echny soubory ?
         jz        UserSz12                 ; nejsou v®echny soubory
UsrSz112:mov       al,bit2+bit6+bit7        ; v®echny soubory+adres†©e+vno©en°

UserSz12:test      byte ptr ds:[UserSwM2],bit2 ; z†kaz vno©en° do adres†©ñ ?
         jz        UserSz14                 ; nen° z†kaz vno©en° do adres†©ñ
         and       al,not bit7              ; z†kaz vno©en° do adres†©ñ

UserSz14:test      byte ptr ds:[UserSwM2],bit3 ; povoleny adres†©e ?
         jz        UserSz16                 ; nen° z†kaz adres†©ñ
         and       al,not bit6              ; z†kaz adres†©ñ

UserSz16:call      far ptr InitFFil         ; inicializace vyhled†v†n°
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek

; ------ nalezen° jmÇna souboru

UserSzn2:call      SeznGZkr                 ; nalezen° dal®°ho souboru
         jc        UserSzn4                 ; nen° dal®° soubor
         test      byte ptr ds:[UserSwM2],bit1 ; je z†kaz souborñ ?
         jz        UserSz26                 ; nen° z†kaz souborñ
         test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jz        UserSzn3                 ; je to soubor - z†kaz

; ------ kopie jmÇna souboru do bufferu v z†sobn°ku

UserSz26:mov       di,sp
         push      cx
         push      ds

         push      es
         pop       ds                       ; DS <- segment jmÇna souboru
         push      ss
         pop       es                       ; ES <- segment bufferu
         cld
         rep       movsb                    ; £schova jmÇna souboru
         mov       word ptr es:[di],CR + LF*HI

         pop       ds
         pop       cx

; ------ z†pis jmÇna souboru do souboru

         inc       cx
         inc       cx                       ; váetnà koncovÇho CR/LF
         mov       si,sp
         mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr WritFile         ; z†pis ©†dku do souboru
UserSzn3:jnc       UserSzn2                 ; dal®° soubor
         jmp       UserSz54                 ; chyba z†pisu

UserSzn4:call      far ptr ClosFFil         ; ukonáen° reëimu hled†n°

; ------ test, zda je zapnuto neaktivn° okno

UserSz4A:test      byte ptr ds:[UserSwM2],bit4 ; zak†z†no druhÇ okno ?
         jnz       UserSz40                 ; druhÇ okno je zak†z†no
         call      far ptr TestNAWn         ; test zapnut° neaktivn°ho okna
         jc        UserSz40                 ; neaktivn° okno nen° zapnuto

; ------ test, zda je v neaktivn°m oknà nàco oznaáeno

         call      far ptr GetNAWin         ; poskytnut° neaktivn°ho okna
         cmp       word ptr es:[AWinSNum],0 ; je nàco oznaáeno ?
         jne       UserSz41                 ; je nàzo oznaáeno
UserSz40:jmp       UserSzn7                 ; nen° nic oznaáeno

; ------ p©epnut° aktivn°ho okna

UserSz41:mov       ax,ds:[SegmAkt]          ; aktivn° okno
         xchg      ax,ds:[SegmNAkt]         ; z†màna oken
         mov       ds:[SegmAkt],ax          ; novÇ aktivn° okno
         xor       byte ptr ds:[WindPar],bit0 ; zmàna p©°znaku aktivn°ho okna
         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e

; ------ inicializace vyhled†v†n° souborñ

         mov       al,bit1+bit6+bit7        ; oznaáenÇ soubory+adres†©e+vno©en°
         test      byte ptr ds:[UserSwM2],bit5 ; v®echny soubory ?
         jz        UserSz42                 ; oznaáenÇ soubory
         mov       al,bit2+bit6+bit7        ; v®echny soubory+adres†©e+vno©en°

UserSz42:test      byte ptr ds:[UserSwM2],bit2 ; z†kaz vno©en° do adres†©ñ ?
         jz        UserSz44                 ; nen° z†kaz vno©en° do adres†©ñ
         and       al,not bit7              ; z†kaz vno©en° do adres†©ñ

UserSz44:test      byte ptr ds:[UserSwM2],bit3 ; povoleny adres†©e ?
         jz        UserSz46                 ; nen° z†kaz adres†©ñ
         and       al,not bit6              ; z†kaz adres†©ñ

UserSz46:call      far ptr InitFFil         ; inicializace vyhled†v†n°
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek

; ------ nalezen° jmÇna souboru

UserSzn5:call      SezXGZkr                 ; nalezen° dal®°ho souboru
         jc        UserSzn6                 ; nen° dal®° soubor
         test      byte ptr ds:[UserSwM2],bit1 ; je z†kaz souborñ ?
         jz        UserSz52                 ; nen° z†kaz souborñ
         test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jz        UserSzn5                 ; je to soubor - z†kaz

; ------ kopie jmÇna souboru do bufferu v z†sobn°ku

UserSz52:mov       di,sp
         push      cx
         push      ds

         push      es
         pop       ds                       ; DS <- segment jmÇna souboru
         push      ss
         pop       es                       ; ES <- segment bufferu
         cld
         rep       movsb                    ; £schova jmÇna souboru
         mov       word ptr es:[di],CR + LF*HI

         pop       ds
         pop       cx

; ------ z†pis jmÇna souboru do souboru

         inc       cx
         inc       cx                       ; váetnà koncovÇho CR/LF
         mov       si,sp
         mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr WritFile         ; z†pis ©†dku do souboru
UserSz54:jc        UserSzn8                 ; chyba z†pisu
         jmp       short UserSzn5           ; dal®° soubor

UserSzn6:call      far ptr ClosFFil         ; ukonáen° reëimu hled†n°

; ------ p©epnut° aktivn°ho okna zpàt

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         xchg      ax,ds:[SegmNAkt]         ; z†màna oken
         mov       ds:[SegmAkt],ax          ; novÇ aktivn° okno
         xor       byte ptr ds:[WindPar],bit0 ; zmàna p©°znaku aktivn°ho okna
         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e
UserSzn7:jmp       short UserSz86

; ------ chybovÇ hl†®en° - chyba z†pisu

UserSzn8:

; ------ uzav©en° souboru seznamu

UserSz86:mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru seznamu

UserSzn9:mov       sp,bp
         ret

UserSezn ENDP

; -----------------------------------------------------------------------------
;        zkr†cen° adres†©e ES:SI/CX -> ES:SI/CX
; -----------------------------------------------------------------------------

SeznGZk0:push      di
         jmp       short SeznGZk2

; -----------------------------------------------------------------------------
;        poskytnut° zkr†cenÇho jmÇna seznamu -> ES:SI/CX
; -----------------------------------------------------------------------------

SeznGZkr PROC      NEAR

; ------ £schova registrñ

         push      di

; ------ nalezen° dal®°ho souboru pro operaci -> ES:SI/CX

         call      far ptr GetFFil          ; nalezen° jmÇna souboru
         jc        SeznGZk8                 ; nen° dal®° soubor

; ------ test, zda je v aktivn°m adres†©i

SeznGZk2:push      si
         push      cx

         mov       di,si                    ; DI <- zaá†tek jmÇna souboru
         mov       cx,ds:[AktPathN]         ; dÇlka aktivn°ho adres†©e
         mov       si,offset AktPath        ; aktivn° adres†©
         cld
         repe      cmpsb                    ; porovn†n° adres†©e

SeznGZk4:pop       cx
         pop       si

         jne       SeznGZk7                 ; nen° aktivn° adres†©
         cmp       byte ptr es:[di-1],"\"   ; byl to ROOT ?
         je        SeznGZk6                 ; byl to ROOT
         cmp       byte ptr es:[di],0       ; konec cesty ?
         je        SeznGZk6                 ; konec cesty
         cmp       byte ptr es:[di],"\"     ; je konec cesty ?
         jne       SeznGZk7                 ; nen° konec cesty
         inc       di                       ; p©eskoáen° znaku "\"

SeznGZk6:sub       cx,di
         add       cx,si                    ; oprava dÇlky jmÇna souboru
         mov       si,di                    ; SI <- zaá†tek jmÇna souboru
SeznGZk7:clc                                ; p©°znak nalezen° dal®°ho souboru

; ------ n†vrat registrñ

SeznGZk8:pop       di
         ret

SeznGZkr ENDP

; -----------------------------------------------------------------------------
;    poskytnut° zkr†cenÇho jmÇna seznamu -> ES:SI/CX, zkr†ceno neaktivn°m oknem
; -----------------------------------------------------------------------------

SezXGZkr PROC      NEAR

; ------ £schova registrñ

         push      di

; ------ nalezen° dal®°ho souboru pro operaci -> ES:SI/CX

         call      far ptr GetFFil          ; nalezen° jmÇna souboru
         jc        SeznGZk8                 ; nen° dal®° soubor

; ------ test, zda je v neaktivn°m adres†©i

         push      si
         push      cx
         push      ds

         push      es
         call      far ptr GetNAWin         ; poskytnut° neaktivn°ho okna
         push      es
         pop       ds                       ; DS <- neaktivn° okno
         pop       es

         mov       di,si                    ; DI <- zaá†tek jmÇna souboru
         mov       cx,ds:[AWinDNum]         ; dÇlka neaktivn°ho adres†©e
         mov       si,AWinDir               ; neaktivn° adres†©
         cld
         repe      cmpsb                    ; porovn†n° adres†©e

         pop       ds
         jmp       short SeznGZk4

SezXGZkr ENDP

; -----------------------------------------------------------------------------
;        vno©en° do podmenu (CY=chyba)
; -----------------------------------------------------------------------------

UserSubM PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,FileMax

         mov       dx,es                    ; DX <- segment bufferu s textem
         push      ss
         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
         mov       di,sp                    ; buffer p©°kazovÇho ©†dku
         mov       ch,0                     ; ukazatel pozice na ©†dku
         mov       cl,FileMax               ; maxim†ln° dÇlka textu
         xor       ax,ax                    ; nen° barva
         push      cs
         call      near ptr DekPLine        ; dek¢dov†n° textovÇho ©†dku
         mov       byte ptr es:[di],0

         mov       si,sp
         call      UserOpen                 ; otev©en° okna menu

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UserSubM ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° p©°kazu ES:SI do p©°kazovÇho ©†dku (CY=pr†zdnò ©†dek)
; -----------------------------------------------------------------------------

UserDekX PROC      FAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         mov       dx,es                    ; DX <- segment bufferu s textem
         push      ds
         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
         mov       di,offset LineCBuf       ; buffer p©°kazovÇho ©†dku
         mov       ch,0                     ; ukazatel pozice na ©†dku
         mov       cl,ds:[LineCMax]         ; maxim†ln° dÇlka p©°kaz. ©†dku
         cmp       cl,253                   ; maxim†ln° dÇlka ©†dku
         jbe       UserDkX2
         mov       cl,253                   ; omezen° dÇlky ©†dku
UserDkX2:xor       ax,ax                    ; nen° barva
         push      cs
         call      near ptr DekPLine        ; dek¢dov†n° textovÇho ©†dku
         mov       word ptr ds:[di],CR + LF*HI ; oznaáen° konce ©†dku
         sub       di,offset LineCBuf
         xchg      ax,di
         mov       ds:[LineCNum],al         ; dÇlka p©°kazu

         cmp       al,1                     ; je nàjakò text ?

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UserDekX ENDP

; -----------------------------------------------------------------------------
;        Vypu®tàn° mezer ze zaá†tku ©†dku ES:SI (CY=nejsou mezery)
; -----------------------------------------------------------------------------

UserSpcL PROC      NEAR

         mov       al,es:[si]
         cmp       al," "
         je        UsrSpL44
         cmp       al,TAB
         je        UsrSpL44
         cmp       al,"@"
         je        UsrSpcL7
         cmp       al,"!"
         je        UsrSpcL4
         stc
         ret

UsrSpcL4:call      TestBlok                 ; test blokov†n°
         jnz       UsrSpL42                 ; je blokov†n°
         and       byte ptr ds:[UserSwcM],not bit3+bit4
         or        byte ptr ds:[UserSwcM],bit1+bit2 ; p©°znak povelu s "!"
UsrSpL42:inc       si                       ; p©eskoáen° znaku "!"
         mov       al,es:[si]               ; dal®° znak
         call      far ptr UpCase
         cmp       al,"L"
         je        UsrSpcL6                 ; m¢d LOADER
         cmp       al,"P"
         je        UsrSpcL5                 ; m¢d PERMANENT
         cmp       al,"B"
         je        UsrSpcL8                 ; m¢d BAT
         dec       si                       ; n†vrat znaku
UsrSpL44:jmp       short UsrSpcL8

UsrSpcL5:call      TestBlok                 ; test blokov†n°
         jnz       UsrSpcL8                 ; je blokov†n°
         xor       byte ptr ds:[UserSwcM],bit2+bit4 ; m¢d PERMANENT
         jmp       short UsrSpcL8

UsrSpcL6:call      TestBlok                 ; test blokov†n°
         jnz       UsrSpcL8                 ; je blokov†n°
         xor       byte ptr ds:[UserSwcM],bit2+bit3 ; m¢d LOADER
         jmp       short UsrSpcL8

UsrSpcL7:call      TestBlok                 ; test blokov†n°
         jnz       UsrSpL71                 ; je blokov†n°
         or        byte ptr ds:[UserSwcM],bit0 ; p©°znak generov†n° seznamu
         and       byte ptr ds:[UserSwM2],not bit1+bit2+bit3+bit4+bit5 ; nulov†n° p©ep°naáñ
UsrSpL71:inc       si                       ; zvò®en° ukazatele textu
         mov       al,es:[si]               ; p©ipravenò znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno

         mov       ah,bit1                  ; z†kaz souborñ
         cmp       al,"F"                   ; z†kaz souborñ
         je        UsrSpL76                 ; je z†kaz souborñ

         mov       ah,bit2                  ; z†kaz vno©en°
         cmp       al,"S"                   ; z†kaz vno©ov†n°
         je        UsrSpL76                 ; je z†kaz vno©ov†n°

         mov       ah,bit3                  ; z†kaz adres†©ñ
         cmp       al,"D"                   ; z†kaz adres†©ñ
         je        UsrSpL76                 ; je z†kaz adres†©ñ

         mov       ah,bit5                  ; hled†n° v®ech souborñ
         cmp       al,"@"                   ; hled†n° v®eho ?
         je        UsrSpL76                 ; je hled†n° v®eho

         cmp       al,"2"                   ; z†kaz druhÇho okna
         jne       UsrSpL82                 ; nen° z†kaz druhÇho okna
         mov       ah,bit4                  ; z†kaz druhÇho okna

UsrSpL76:call      TestBlok                 ; test blokov†n°
         jnz       UsrSpL71                 ; je blokov†n°
         or        ds:[UserSwM2],ah         ; nastaven° z†kazu
         jmp       short UsrSpL71           ; dal®° znak

UsrSpcL8:inc       si
UsrSpL82:mov       al,es:[si]
         cmp       al," "
         je        UsrSpcL8
         cmp       al,TAB
         je        UsrSpcL8
         clc
         ret

UserSpcL ENDP

; -----------------------------------------------------------------------------
;                    otev©en° okna uëivatelskÇho menu
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru k otev©en° (mñëe bòt ukonáen i LF, mezerou apod.)
; VùSTUP: DS:SI=definice novÇho menu (p©i chybà SI nedefinov†n)
;         CY=chyba, menu neotev©eno (chyba ohl†®ena uëivateli)
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice menu
;                   SS:[BP-4] (2) á°slo segmentu menu (0=nen° vytvo©en)
;                   SS:[BP-6] (2) identifik†tor souboru (0=nen° otev©en)
; -----------------------------------------------------------------------------
;˛
UserOpen PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,6+3*FileMax           ; buffer k £schovà jmÇna souboru

; ------ vypu®tàn° mezer ze zaá†tku jmÇna souboru -> ES:SI

         dec       si
UserOp04:inc       si
         cmp       byte ptr es:[si]," "
         je        UserOp04
         cmp       byte ptr es:[si],TAB
         je        UserOp04

; ------ £schova jmÇna souboru do z†sobn°ku

         mov       di,sp                    ; buffer v z†sobn°ku
         push      ds

         push      es
         pop       ds                       ; DS <- segment jmÇna souboru
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku

         mov       cx,FileMax-1             ; max. dÇlka jmÇna souboru
         cld
         mov       bx,di                    ; BX <- p©°padnò konec jmÇna
UserOp12:lodsb                              ; znak jmÇna souboru
         cmp       al," "                   ; je mezera ?
         jb        UserOp14                 ; konec jmÇna souboru
         stosb                              ; uloëen° znaku jmÇna souboru
         je        UserOp13                 ; mezera - mohl by to bòt konec
         mov       bx,di                    ; BX <- mezi£schova p©°padnÇho konce
UserOp13:loop      UserOp12                 ; dal®° znak
UserOp14:mov       di,bx                    ; DI <- nalezenò konec jmÇna souboru
         mov       cx,di                    ; CX <- £schova konce jmÇna souboru
         mov       al,0                     ; ukonáovac° 0
         stosb                              ; oznaáen° konce jmÇna souboru

         pop       ds

; ------ test, zda je jië maxim†ln° poáet menu

         mov       word ptr ss:[bp-6],0     ; soubor nen° otev©en
         mov       word ptr ss:[bp-4],0     ; segment menu nen° vytvo©en
         cmp       word ptr ds:[NumUserM],MaxUserM ; je jië max. poáet menu ?
         jae       UserOp02                 ; je jië maxim†ln° poáet menu

; ------ otev©en° souboru zadanÇho jmÇna

         mov       si,sp                    ; jmÇno souboru v z†sobn°ku
         sub       cx,si                    ; dÇlka jmÇna souboru
         mov       ds:[FndUsMP2],cl         ; dÇlka jmÇna souboru
         mov       word ptr ds:[FndUsMP2+1],si ; offset jmÇna souboru
         mov       word ptr ds:[FndUsMP2+3],ss ; segment jmÇna souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jnc       UserOpn1                 ; soubor otev©en OK

; ------ otev©en° jako lok†ln° menu
;˛˛˛˛˛˛˛
         cld
UserO111:mov       di,si                    ; zaá†tek jmÇna souboru
UserO112:lods      byte ptr ss:[si]         ; naáten° znaku
         cmp       al,":"
         je        UserO111                 ; je oddàlovaá diskñ
         cmp       al,"\"
         je        UserO111                 ; je oddàlovaá cesty
         cmp       al," "
         ja        UserO112
         mov       si,di                    ; zaá†tek lok†ln°ho jmÇna
         call      far ptr OpenR            ; otev©en° souboru jako lok†ln°
         jnc       UserOpn1                 ; soubor otev©en OK

; ------ otev©en° v datovÇm adres†©i

         cld
         mov       di,sp
         add       di,FileMax+2             ; buffer jmÇna v datovÇm adres†©i

         push      di

         push      si
         mov       cx,ds:[TempDirN]         ; dÇlka p©echodnÇho adres†©e
         mov       si,offset TempDir        ; p©echodnò adres†©e
         rep       movsb                    ; p©enos textu do bufferu
         pop       si

         mov       al,"\"                   ; oddàlovaá adres†©ñ
         dec       di
         scasb                              ; koná° adres†© znakem "\" ?
         je        UserO116                 ; koná° znakem "\"
         stosb                              ; oddàlovac° znak "\"

UserO116:lods      byte ptr ss:[si]
         stosb
         cmp       al,0
         jne       UserO116

         pop       si
         call      far ptr OpenR            ; otev©en° souboru jako lok†ln°
         jnc       UserOpn1                 ; soubor otev©en OK

; ------ chyba - menu nenalezeno

         mov       si,offset FndUsrMn       ; hl†®en° - soubor nenalezen
UserOpn0:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        UserOp02                 ; je p©eru®en° operace
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
UserOp02:mov       ax,ss:[bp-4]             ; á°slo segmentu menu
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ax,ss:[bp-6]             ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         and       byte ptr ds:[ParMenu],not bit4 ; ukonáen° automat. vno©en°
         stc                                ; p©°znak chyby operace
         jmp       UserOpn9

; ------ £schova identifik†toru souboru

UserOpn1:mov       ss:[bp-6],ax             ; identifik†tor souboru

; ------ vytvo©en° definice novÇho menu

         cld
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,MnuCSumm              ; poáet bajtñ na menu
         mov       ax,ds:[NumUserM]         ; poáet otev©enòch menu
         mul       cx                       ; offset v tabulce definic
         mov       si,offset MnuUserM       ; adresa prvn°ho menu
         add       ax,si                    ; adresa definice menu
         mov       ss:[bp-2],ax             ; adresa definice menu
         xchg      ax,di                    ; DI <- adresa definice menu
         rep       movsb                    ; kopie definice z†kladn°ho menu

; ------ vytvo©en° segmentu novÇho menu

         mov       bx,UMenSumm+200          ; asi tak minim†ln° velikost
         call      far ptr CreatDat         ; vytvo©en° novÇho segmentu
UserOpn2:mov       si,offset SizUsrMn       ; hl†®en° - soubor nelze naá°st
         jc        UserOpn0                 ; chyba pamàti
         mov       ss:[bp-4],ax             ; segment s definic° menu
         call      far ptr GetDat           ; adresa segmentu
         mov       es:[UMenByts],bx         ; velikost segmentu

; ------ nulov†n° ukazatelñ menu

         xor       ax,ax                    ; AX <- 0
         mov       di,UMenByts+2
         mov       cx,(UMenSumm+1-2)/2      ; velikost standardn° definice
         cld
         rep       stosw                    ; vynulov†n° ukazatelñ

; ------ p©enesen° definice barev

         mov       di,UMenCol1
         mov       si,offset UMnuCol1
         mov       cl,11                    ; poáet bajtñ barev
         rep       movsb                    ; inicializace barev

; ------ p©enesen° jmÇna souboru

         mov       si,sp                    ; buffer v z†sobn°ku
         push      ds
         push      ss
         pop       ds                       ; DS <- segment jmÇna souboru
         mov       di,UMenFile              ; buffer jmÇna souboru
         mov       cl,FileMax/2             ; dÇlka bufferu jmÇna souboru
         rep       movsw                    ; p©enos jmÇna souboru
         pop       ds

; ------ kurzor

         mov       si,ds:[NumUserM]         ; á°slo aktivn°ho menu
         shl       si,1
         mov       ax,ds:[si+UserLast]      ; posledn° zvolen† poloëka
         mov       es:[UMenVolK],ax         ; p©ednastaven° kurzoru menu

; ------ inicializace ukazatelñ

         mov       ax,UMenSumm              ; velikost standardn° tabulky
         mov       es:[UMenAdrF],ax         ; adresa souboru
         mov       es:[UMenNadI],ax         ; adresa indexñ nadpisu
         mov       es:[UMenLinI],ax         ; adresa indexñ zobrazenòch ©†dkñ
         mov       es:[UMenParI],ax         ; adresa indexñ parametrñ ©†dkñ
         mov       es:[UMenHlpI],ax         ; adresa indexñ n†povàd
         mov       word ptr es:[UMenMPoz],-1 ; pozice menu nezad†na

; ------ naáten° souboru do bufferu

         xchg      ax,di                    ; DI <- adresa k naáten° souboru
         mov       cx,es:[0]                ; velikost bufferu
         dec       cx                       ; 1 bajt na konci je rezerva
         sub       cx,di                    ; volnÇ m°sto k naáten° souboru
         mov       ax,ss:[bp-6]             ; identifik†tor souboru
         mov       dx,cx                    ; £schova velikosti bufferu
         dec       dx
         call      far ptr ReadFile         ; naáten° dat
UserOpn3:jc        UserOpn2                 ; chyba
         cmp       dx,cx                    ; je p©eteáen° ?
         jb        UserOpn2                 ; je p©eteáen°

; ------ uzav©en° souboru

         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ss:[bp-6],ax             ; oznaáen°, ëe soubor je uzav©en

; ------ oznaáen° konce souboru

         add       di,cx                    ; nov† adresa konce dat
         cmp       byte ptr es:[di-1],EOF   ; je jië oznaáen konec souboru ?
         je        UserOpn4                 ; je jië oznaáen konec souboru
         mov       byte ptr es:[di],EOF     ; oznaáen° konce souboru
         inc       di
UserOpn4:mov       es:[0],di                ; nov† velikost dat

; ------ nastaven° velikosti bufferu

         mov       bx,di                    ; velikost dat v bufferu
         mov       ax,ss:[bp-4]             ; segment bufferu
         call      far ptr ModiSegS         ; nastaven° novÇ velikosti bufferu

; ------ test, zda je identifik†tor n†rodn°ho k¢du

         mov       di,UMenSumm              ; zaá†tek textu v bufferu
         mov       si,offset IdntISwT       ; p©ep°naá
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        UserOpn6                 ; nen° p©ep°naá

; ------ naáten° n†rodn°ho k¢du

         mov       si,offset KodISwcT       ; n†rodn° k¢d
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        UserOpn5                 ; nen° p©ep°naá
         cmp       al,ds:[CodePagK]         ; je pot©eba zmànit k¢d ?
         je        UserOpn5                 ; nen° pot©eba zmànit k¢d
         cmp       al,0                     ; je k¢d zn†mò ?
         je        UserOpn5                 ; nen° zn†mò
         cmp       byte ptr ds:[CodePagK],0
         je        UserOpn5                 ; k¢d nen° zn†mò

; ------ konverze n†rodn°ho k¢du

         xchg      ax,cx                    ; CL <- aktu†ln° k¢d
         mov       dl,bit1                  ; p©°prava
         shl       dl,cl                    ; DL = aktu†ln° k¢d
         mov       cl,ds:[CodePagK]         ; poëadovan† k¢dov† str†nka
         mov       dh,bit1                  ; p©°prava
         shl       dh,cl                    ; DH = poëadovanò k¢d
         mov       si,di                    ; SI <- zaá†tek textu
         mov       cx,es:[0]                ; poáet bajtñ v bufferu
         sub       cx,si                    ; CX <- dÇlka textu
         call      far ptr KonvFnt          ; konverze fontñ

; ------ vypu®tàn° identifikaán°ho ©†dku ES:DI

UserOpn5:mov       ax,ss:[bp-4]             ; AX <- á°slo segmentu
         call      far ptr DelLISwc         ; zru®en° ©†dku s parametry

; ------ inicializace ukazatelñ menu

UserOpn6:mov       ax,ss:[bp-4]             ; segment bufferu
         mov       si,ss:[bp-2]             ; adresa definice menu
         mov       ds:[si+MnuCSegm],ax      ; á°slo segmentu menu
         inc       word ptr ds:[NumUserM]   ; zvò®en° á°taáe poátu otev©enòch menu
         call      PrepUMnu                 ; p©°prava ukazatelñ menu
         jnc       UserOpn7                 ; v®e OK
         dec       word ptr ds:[NumUserM]   ; sn°ëen° á°taáe poátu otev©enòch menu
         jmp       UserOpn3                 ; chyba - nedostatek pamàti

; ------ otev©en° okna menu

UserOpn7:call      far ptr OpenMnu          ; otev©en° okna menu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

UserOpn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UserOpen ENDP

; -----------------------------------------------------------------------------
;        uzav©en° v®ech oken uëivatelskòch menu
; -----------------------------------------------------------------------------

UserClsA:call      UserClos
         jnc       UserClsA
         call      far ptr ClosIni          ; uzav©en° inicializaán°ho souboru
         ret

; -----------------------------------------------------------------------------
;        uzav©en° jednoho okna uëivatelskÇho menu (CY=nen° dal®° okno)
; -----------------------------------------------------------------------------

UserClos PROC      NEAR

         push      ax
         push      si
         push      es

         and       byte ptr ds:[ParMenu],not bit4 ; ukonáen° automat. vno©en°
         call      UserMGet                 ; poskytnut° aktivn°ho menu
         jc        UserCls9                 ; menu nen° otev©eno

         mov       ax,ds:[si+MnuCSegm]      ; segment s definic° menu
         call      far ptr DelSeg           ; zru®en° segmentu
         call      far ptr ClosMnu

         dec       word ptr ds:[NumUserM]   ; sn°ëen° poátu otev©enòch menu
         clc                                ; p©°znak operace OK

UserCls9:pop       es
         pop       si
         pop       ax
         ret

UserClos ENDP

; -----------------------------------------------------------------------------
;        poskytnut° definice aktivn°ho uëivatelskÇho menu -> DS:SI a ES (CY=nen°)
; -----------------------------------------------------------------------------

UserMGet PROC      NEAR

         push      ax
         push      dx

         mov       ax,ds:[NumUserM]         ; poáet otev©enòch menu
         or        ax,ax                    ; je nàjakÇ menu ?
         jnz       UserMGt1                 ; je nàjakÇ menu

         mov       ax,ds:[MnuSegmX]         ; n†hradn° segment
         call      far ptr GetDat           ; adresa n†hradn°ho segmentu
         stc                                ; p©°znak, ëe nen° ë†dnò segment
         jmp       short UserMGt2           ; nen° otev©enÇ ë†dnÇ menu

UserMGt1:mov       dx,MnuCSumm              ; poáet bajtñ na menu
         mul       dx                       ; offset v tabulce definic
         add       ax,offset MnuUserM-MnuCSumm ; adresa definice menu
         xchg      ax,si                    ; SI <- adresa definice menu

         mov       ax,ds:[si+MnuCSegm]      ; segment menu
         call      far ptr GetDat           ; adresa menu

UserMGt2:pop       dx
         pop       ax
         ret

UserMGet ENDP

; -----------------------------------------------------------------------------
;        inicializace ukazatelñ menu DS:SI (soubor je naáten -> CY=chyba)
; -----------------------------------------------------------------------------

PrepUMnu PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ adresa bufferu -> ES

         mov       ax,ds:[si+MnuCSegm]      ; segment menu
         call      far ptr GetDat           ; adresa segmentu

; ------ zru®en° staròch popisovaáñ

         mov       di,UMenSumm              ; konec popisovaáe
         mov       cx,es:[UMenAdrF]         ; adresa souboru v bufferu
         sub       cx,di                    ; poáet bajtñ k vypu®tàn°
         call      far ptr DelDat           ; zru®en° indexovòch tabulek
         xchg      ax,bp                    ; BP <- £schova á°sla segmentu

; ------ inicializace popisovaáñ

         xor       ax,ax                    ; AX <- 0
         mov       es:[UMenAdrF],di         ; adresa souboru v bufferu
         mov       es:[UMenNadI],di         ; adresa indexñ z†hlav°
         mov       es:[UMenNadN],ax         ; poáet ©†dkñ z†hlav°
         mov       es:[UMenLinI],di         ; adresa indexñ zobraz. ©†dkñ
         mov       es:[UMenLinN],ax         ; poáet zobrazenòch ©†dkñ
         mov       es:[UMenParI],di         ; adresa parametrñ ©†dkñ
         mov       es:[UMenVolN],ax         ; poáet ©†dkñ voleb
         mov       es:[UMenHlpI],di         ; adresa indexñ n†povàd
         mov       es:[UMenMSir],ax         ; ®°©ka a vò®ka menu nezad†na
         mov       ds:[LevelIF],ax          ; á°taá vno©en° IF
         mov       ds:[BlokFor],ax          ; blokov†n° tàla FOR
         mov       ds:[LevelCAS],ax         ; á°taá vno©en° CASE
         dec       ax                       ; AX <- -1
         mov       ds:[UMnCaseN],ax         ; nen° ©etàzec CASE
         mov       es:[UMenMPoz],ax         ; ©†dek a pozice menu nezad†ny
         mov       byte ptr ds:[UParmFor],0 ; FOR se neobsluhuje

;; ------ test, zda je form†t DOSMAN 2.00

         mov       si,es:[UMenAdrF]         ; adresa souboru

;
;         and       byte ptr es:[UMenPrm1],not bit0 ; nen° DOSMAN 2
;         mov       di,es:[UMenAdrF]         ; adresa souboru
;         mov       si,offset UserMIde       ; vzorek identifik†toru
;         mov       cx,offset(UserMId0-UserMIde)
;         cld
;         push      di
;         repe      cmpsb                    ; porovn†n° ©etàzcñ
;         pop       si                       ; zaá†tek textu souboru
;         jne       PrepUMn3                 ; nen° form†t DOSMAN 2
;         call      ReadUML                  ; dal®° ©†dek
;         or        byte ptr es:[UMenPrm1],bit0 ; je DOSMAN 2

PrepUMn3:call      ReadUML0                 ; vypu®tàn° ©†dku koment†©e

; ------ test ©†dku, zda je to ©†dek nadpisu

         mov       di,UMenSumm              ; adresa k uloëen° tabulky indexñ
         cmp       byte ptr es:[si],EOF     ; je konec textu ?
         je        PrepUM33                 ; konec textu
PrepUM32:cmp       byte ptr es:[si]," "
         je        PrepUM34                 ; je ©†dek nadpisu
         cmp       byte ptr es:[si],TAB
         je        PrepUM34                 ; je ©†dek nadpisu
         cmp       byte ptr es:[si],LF
         je        PrepUM31                 ; pr†zdnò ©†dek se p©eskoá°
         cmp       byte ptr es:[si],CR
         je        PrepUM31                 ; pr†zdnò ©†dek se p©eskoá°
         cmp       word ptr es:[si],".#"    ; je zvl†®tn° ©°dic° ©†dek ?
         jne       PrepUM33                 ; nen° ©°dic° ©†dek - nen° nadpis

; ------ p©°kazy SET, VAL a GET na zaá†tku menu

         call      TestBlk1                 ; test blokov†n°
         jne       PrepUM30                 ; ©†dek neplat°
         call      ReadUPS                  ; naáten° promànnÇ SET
         jc        PrpUM372                 ; p©eru®en° operace

PrepUM30:call      ReadUPM                  ; naáten° parametru z ©†dku
PrepUM31:call      ReadUML                  ; nalezen° dal®°ho ©†dku
         jnc       PrepUM32                 ; je dal®° ©†dek OK
PrepUM33:jmp       short PrepUM39

; ------ nalezen° zaá†tku textu ©†dku

PrepUM34:call      TestBlk1                 ; test blokov†n°
         jne       PrepUM31                 ; ©†dek neplat°
PrepUM35:inc       si
         cmp       byte ptr es:[si]," "
         je        PrepUM35                 ; vypu®tàn° mezer
         cmp       byte ptr es:[si],TAB
         je        PrepUM35                 ; vypu®tàn° tabul†torñ

; ------ za©azen° ©†dku do tabulky (adresa DI)

PrepUM37:mov       cx,2                     ; poáet bajtñ k vloëen°
         mov       ax,bp                    ; AX <- segment bufferu
         call      far ptr InsDat           ; vytvo©en° m°sta pro index
         jnc       PrepUM38                 ; operace OK
PrpUM372:jmp       PrepUMn9                 ; chyba pamàti

PrepUM38:add       si,cx                    ; oprava adresy textu
         add       es:[UMenLinI],cx         ; oprava adresy indexñ ©†dkñ
         add       es:[UMenParI],cx         ; oprava adresy indexñ parametrñ
         add       es:[UMenHlpI],cx         ; oprava adresy indexñ n†povàd
         add       es:[UMenAdrF],cx         ; oprava adresy adresy souboru
         mov       ax,si                    ; adresa textu ©†dku
         sub       ax,es:[UMenAdrF]         ; offset ©†dku v souboru
         cld
         stosw                              ; uloëen° indexu ©†dku
         inc       word ptr es:[UMenNadN]   ; zvò®en° á°taáe ©†dkñ
PrepUM3A:call      ReadUML                  ; nalezen° dal®°ho ©†dku
         jc        PrepUM39                 ; nen° dal®° ©†dek
         jmp       PrepUM32                 ; dal®° ©†dek

; ------ test ©†dku, zda je to platnò (zobrazenò) ©†dek

PrepUM39:cmp       byte ptr es:[si],EOF     ; je konec souboru ?
         jne       PrepUMn4                 ; nen° konec souboru
         jmp       PrepUMn7                 ; konec souboru

PrepUMn4:mov       al,es:[si]               ; znak na pozici kurzoru
         cmp       al," "                   ; zaá°n† ©†dek mezerou ?
         ja        PrepUM42                 ; nezaá°n† mezerou
PrepUM41:jmp       PrepUMn6                 ; dal®° ©†dek
PrepUM42:cmp       al,"@"
         je        PrepUM41                 ; nen° zobrazenò ©†dek
         cmp       al,"!"
         je        PrepUM41                 ; nen° zobrazenò ©†dek
         mov       dl,bit7                  ; p©°znak - je ©†dek volby
         cmp       al,"#"
         jne       PrepUMn5                 ; je zobrazenò ©†dek OK

         cmp       byte ptr es:[si+1],"."   ; je to p©ep°naá ?
         jne       PrepUM43                 ; nen° to p©ep°naá
         call      ReadUPM                  ; naáten° parametru z ©†dku
         jmp       short PrepUM41           ; dal®° ©†dek

PrepUM43:call      TestBlk1                 ; test blokov†n°
         jne       PrepUM41                 ; ©†dek neplat°
         cmp       byte ptr es:[si+1],"?"   ; je ©†dek n†povàdy ?
         jne       PrepUM44                 ; nen° ©†dek n†povàdy

         mov       di,es:[UMenVolN]         ; poáet voleb
         or        di,di                    ; jsou jië nàjakÇ volby ?
         jz        PrepUM41                 ; nejsou je®tà ë†dnÇ volby
         shl       di,1                     ; offset v tabulce indexñ
         add       di,es:[UMenHlpI]         ; offset v tabulce indexñ
         cmp       word ptr es:[di-2],0     ; je n†povàda jië vytvo©ena ?
         jne       PrepUM41                 ; n†povàda je jië vytvo©ena
         mov       ax,si                    ; offset ©†dku
         inc       ax
         inc       ax                       ; zaá†tek textu ©†dku
         sub       ax,es:[UMenAdrF]         ; offset ©†dku
         mov       es:[di-2],ax             ; index ©†dku n†povàdy
         jmp       short PrepUM41

PrepUM44:cmp       byte ptr es:[si+1],"*"   ; je pomocnò nadpis ?
         je        PrepUM46                 ; je pomocnò nadpis

         mov       di,es:[UMenLinN]         ; poáet zobrazenòch ©†dkñ
         or        di,di                    ; je jië nàjakò ©†dek ?
         jz        PrepUM41                 ; nen° je®tà ë†dnò ©†dek
         add       di,es:[UMenParI]         ; adresa v tabulce indexñ
         test      byte ptr es:[di-1],bit7  ; byl to ©†dek volby ?
         jz        PrepUM41                 ; nebyl to ©†dek volby
         or        byte ptr es:[di-1],bit6  ; je navazuj°c° menu
PrepUM45:jmp       short PrepUM41           ; nen° pomocnò nadpis - nen° ©†dek

PrepUM46:mov       dl,0                     ; p©°znak pomocnÇho ©†dku
         inc       si
         inc       si                       ; p©eskoáen° indik†toru

; ------ za©azen° ©†dku do tabulky indexñ zobrazenòch ©†dkñ

PrepUMn5:call      TestBlk1                 ; test blokov†n°
         jne       PrepUM45                 ; ©†dek neplat°
         mov       di,es:[UMenLinN]         ; poáet zobrazenòch ©†dkñ
         shl       di,1                     ; offset v tabulce indexñ
         add       di,es:[UMenLinI]         ; adresa konce tabulky indexñ
         mov       cx,2                     ; vkl†daj° se 2 bajty
         mov       ax,bp                    ; AX <- segment bufferu
         call      far ptr InsDat           ; vytvo©en° m°sta pro index
         jnc       PrepUM51
PrepUM50:jmp       PrepUMn9                 ; chyba pamàti

PrepUM51:add       si,cx                    ; oprava adresy textu
         add       es:[UMenAdrF],cx         ; oprava adresy souboru
         add       es:[UMenParI],cx         ; oprava adresy indexñ parametrñ
         add       es:[UMenHlpI],cx         ; oprava adresy indexñ n†povàd
         mov       ax,si                    ; adresa textu ©†dku
         sub       ax,es:[UMenAdrF]         ; offset ©†dku v souboru
         cld
         mov       bx,di                    ; £schova indexu ©†dku
         stosw                              ; uloëen° indexu ©†dku

; ------ za©azen° ©†dku do tabulky indexñ parametrñ

         mov       di,es:[UMenLinN]         ; poáet zobrazenòch ©†dkñ
         inc       word ptr es:[UMenLinN]   ; zvò®en° á°taáe ©†dkñ
         add       di,es:[UMenParI]         ; adresa v tabulce indexñ
         mov       cl,1                     ; vkl†d† se 1 bajt
         mov       ax,bp                    ; AX <- segment bufferu
         call      far ptr InsDat           ; vytvo©en° m°sta pro bajt
         jc        PrepUM50                 ; chyba pamàti
         add       si,cx                    ; oprava adresy textu
         add       es:[UMenAdrF],cx         ; oprava adresy souboru
         add       es:[UMenHlpI],cx         ; oprava adresy indexñ n†povàd
         mov       al,dl                    ; ukl†danò parametr
         cld
         stosb                              ; uloëen° parametru
         test      al,bit7                  ; je to ©†dek volby ?
         jz        PreUM514                 ; nen° to ©†dek volby

; ------ vytvo©en° indexu n†povàdy

         push      di
         mov       di,es:[UMenVolN]         ; poáet voleb
         inc       word ptr es:[UMenVolN]   ; zvò®en° á°taáe voleb
         shl       di,1                     ; offset v tabulce indexñ n†povàd
         add       di,es:[UMenHlpI]         ; adresa v tabulce indexñ n†povàd
         mov       cl,2                     ; vkl†daj° se 2 bajty
         mov       ax,bp                    ; AX <- segment bufferu
         call      far ptr InsDat           ; vytvo©en° m°sta pro bajt
         jc        PreUM511                 ; chyba pamàti
         mov       word ptr es:[di],0       ; nen° n†povàda
         add       es:[UMenAdrF],cx         ; oprava adresy souboru
         add       si,cx                    ; oprava adresy ukazatele textu
         clc                                ; p©°znak operace OK
PreUM511:pop       di
         jc        PrepUMn9                 ; chyba pamàti

; ------ test, zda se kl†vesa m† zobrazit

         mov       al,es:[si]               ; n†sleduj°c° znak
         cmp       al,"_"                   ; je platn† kl†vesa ?
         jne       PrepUM52                 ; je asi platn† kl†vesa
         inc       word ptr es:[bx]         ; p©eskoáen° znaku "_"
PreUM514:jmp       short PrepUMn6           ; nen° platn† kl†vesa

; ------ zji®tàn° dÇlky textu horkÇ kl†vesy

PrepUM52:inc       byte ptr es:[di-1]       ; dÇlka horkÇ kl†vesy = 1

; ------ vyhled†n° textu v tabulce

         mov       bx,offset TabUMnuF       ; tabulka textñ kl†ves
PrepUM53:mov       dh,0
         mov       dl,cs:[bx]               ; dÇlka textu z tabulky
         mov       cx,dx                    ; CX <- dÇlka textu kl†vesy
         jcxz      PrepUMn6                 ; konec, text nenalezen
         inc       bx                       ; zaá†tek textu kl†vesy

         push      si
         dec       si
         dec       bx
PrepUM54:inc       si
         inc       bx
         mov       al,es:[si]               ; znak textu
         call      far ptr UpCase           ; konverze na velk† p°smena
         cmp       al,cs:[bx]
         loope     PrepUM54                 ; dal®° znak
         pop       si
         je        PrepUM56                 ; text nalezen OK

         inc       bx
         add       bx,cx                    ; posun adresy
         jmp       short PrepUM53

; ------ test, zda n†sleduje á°slo 1 aë 12

PrepUM56:add       si,dx                    ; posun ukazatele textu
         mov       al,es:[si]               ; dal®° p©ipravenò znak
         cmp       al,"1"
         jb        PrepUMn6                 ; nen° á°slice
         cmp       al,"9"
         ja        PrepUMn6                 ; nen° á°slice
         inc       si
                                            ; 1 znak je jië zapoá°t†n do dÇlky !

         cmp       al,"1"                   ; mñëe bòt druh† á°slice ?
         jne       PrepUM58                 ; nebude druh† á°slice
         mov       al,es:[si]               ; dal®° á°slice
         cmp       al,"0"
         jb        PrepUM58                 ; nen° á°slice
         cmp       al,"2"
         ja        PrepUM58
         inc       dx                       ; á°taá p©°davnÇ dÇlky

PrepUM58:add       es:[di-1],dl             ; zvò®en° dÇlky textu kl†vesy

; ------ nalezen° adresy dal®°ho ©†dku

PrepUMn6:call      ReadUML                  ; nalezen° dal®°ho ©†dku
         jc        PrepUMn7                 ; nen° dal®° ©†dek
         jmp       PrepUMn4                 ; je dal®° ©†dek OK
PrepUMn7:clc

; ------ n†vrat registrñ

PrepUMn9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PrepUMnu ENDP

TabUMnuF label     byte
         db        2,'*F'
         db        2,'^F'
         db        2,'/F'
TabUMnFS db        7,'SHIFT-F'
TabUMnFC db        6,'CTRL-F'
TabUMnFA db        5,'ALT-F'
TabUMnF  db        1,'F'
         db        0

; -----------------------------------------------------------------------------
;        nalezen° dal®°ho ©†dku ES:SI (vypou®t° se koment†©e -> CY=konec)
; -----------------------------------------------------------------------------

ReadUML  PROC      NEAR

         dec       si
ReadUML1:inc       si
         cmp       byte ptr es:[si],CR
         je        ReadUML1                 ; znak CR se ignoruje
         cmp       byte ptr es:[si],LF
         je        ReadUML4                 ; konec ©†dku
         cmp       byte ptr es:[si],EOF
         jne       ReadUML1                 ; nen° konec souboru - dal®° znak
ReadUML2:stc                                ; p©°znak konce souboru
         ret

; ------ vypu®tàn° ©†dku koment†©e

ReadUML0:dec       si
ReadUML4:inc       si
         cmp       byte ptr es:[si],CR
         je        ReadUML4                 ; vypu®tàn° CR
         cmp       byte ptr es:[si],";"     ; je koment†© ?
         je        ReadUML1                 ; je koment†© - dal®° ©†dek
         cmp       byte ptr es:[si],EOF
         je        ReadUML2                 ; je konec souboru
         clc
         ret

ReadUML  ENDP

; -----------------------------------------------------------------------------
;        naáten° ©†dku parametru ES:SI (parametr #.)
; -----------------------------------------------------------------------------
;˛
ReadUPM  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©°prava k vyhled†n° parametru

         mov       ds:[AdresAkt],si         ; aktu†ln° adresa ©†dku

         inc       si
ReadUMP0:inc       si                       ; p©eskoáen° indik†toru "#."
         cmp       byte ptr es:[si]," "
         je        ReadUMP0                 ; p©eskoáen° mezer
         cmp       byte ptr es:[si],TAB
         je        ReadUMP0                 ; p©eskoáen° tabul†torñ
         mov       di,offset UMenUPar       ; tabulka parametrñ
         mov       ch,0

; ------ test, zda je jië konec tabulky

ReadUPM1:mov       cl,ds:[di]               ; dÇlka textu parametru
         jcxz      ReadUPM9                 ; konec tabulky - nenalezeno
         inc       di                       ; zaá†tek textu parametru

; ------ porovn†n° jednoho parametru

         push      si
         push      di
         push      cx

ReadUPM2:mov       al,es:[si]               ; znak ze souboru
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,ds:[di]               ; je shodnò znak ?
         jne       ReadUPM6                 ; nen° shodnò znak
         inc       si
         inc       di
         loop      ReadUPM2                 ; porovn†n° dal®°ho znaku

; ------ test, zda je konec textu parametru

         mov       al,es:[si]               ; dal®° znak
         cmp       al,"_"
         je        ReadUPM6                 ; pokraáuje
         cmp       al,"0"
         jb        ReadUPM3                 ; nen° platnò znak jmÇna
         cmp       al,"9"
         jbe       ReadUPM6                 ; je á°slice
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"A"
         jb        ReadUPM3
         cmp       al,"Z"
         jbe       ReadUPM6

; ------ nalezen parametr - skok na obsluhu

ReadUPM3:call      word ptr ds:[di]         ; skok na obsluhu
         pop       cx
         pop       di
         pop       si
         jmp       short ReadUPM9

; ------ text nen° shodnò - p©°prava k dal®°mu heslu

ReadUPM6:pop       cx
         pop       di
         pop       si

         add       di,cx                    ; konec textu
         inc       di
         inc       di                       ; p©eskoáen° adresy
         jmp       short ReadUPM1           ; test dal®°ho slova

; ------ n†vrat registrñ

ReadUPM9:test      byte ptr ds:[UParmFor],bit1 ; nutn† zmàna adresy ?
         jz        ReadUPMA                 ; nen° nutn† zmàna adresy
         call      UserMGet                 ; poskytnut° segmentu menu
         and       byte ptr ds:[UParmFor],not bit1 ; nulov†n° poëadavku

ReadUPMA:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadUPM  ENDP

; ------ nastaven° rozmàrñ menu

UPMenus: xor       cx,cx                    ; nen° korekce
         mov       di,UMenMSir              ; ®°©ka
         call      ReadUPMN                 ; naáten° ®°©ky
         mov       di,UMenMVys              ; vò®ka
         call      ReadUPMN                 ; naáten° vò®ky
         inc       cx                       ; korekce 1
         mov       di,UMenMPoz              ; pozice
         call      ReadUPMN                 ; naáten° pozice
         mov       di,UMenMRad              ; ©†dek
         call      ReadUPMN                 ; naáten° ©†dku
         ret

; ------ intenzivn° pozad° znakñ

UPIntens:call      ReadUPMS                 ; vypu®tàn° mezer
         call      ReadUPMC                 ; naáten° znaku
         cmp       al,"N"                   ; nen° intenzivn° pozad° ?
         je        UPInten1                 ; nen° intenzivn° pozad°
         cmp       al,"Y"                   ; je intenzivn° pozad° ?
         jne       UPInten2                 ; nezad†no pozad°
         or        byte ptr es:[UMenPrm1],bit1+bit2 ; intenzivn° pozad°
         jmp       short UPInten2
UPInten1:or        byte ptr es:[UMenPrm1],bit1 ; intenzita uráena
         and       byte ptr es:[UMenPrm1],not bit2 ; nen° intenzivn° pozad°
UPInten2:ret

; ------ barva r†mu

UPColRam:mov       di,UMenClR1              ; barva r†mu - tmav†
         test      byte ptr ds:[MonoMod],bit0+bit1 ; je MONO m¢d ?
         jnz       UPColRm2                 ; je MONO m¢d
         call      ReadUPMB                 ; naáten° barvy r†mu - tmav†
         mov       di,UMenClR2              ; barva r†mu - svàtl†
UPColRm1:test      byte ptr ds:[MonoMod],bit0+bit1 ; je MONO m¢d ?
         jnz       UPColRm2                 ; je MONO m¢d
         call      ReadUPMB                 ; naáten° barvy r†mu
UPColRm2:ret

; ------ barva titulku

UPColTit:mov       di,UMenColT              ; barva titulku
         jmp       short UPColRm1

; ------ barva z†hlav°

UPColHea:mov       di,UMenColH              ; barva z†hlav°
         test      byte ptr ds:[MonoMod],bit0+bit1 ; je MONO m¢d ?
         jnz       UPColRm2                 ; je MONO m¢d
         call      ReadUPMB                 ; naáten° barvy z†hlav°
         mov       di,UMenClH2              ; zvò®en† barva z†hlav°
         jmp       short UPColRm1

; ------ barva textu

UPColTxt:mov       di,UMenCol1              ; bàën† barva
         test      byte ptr ds:[MonoMod],bit0+bit1 ; je MONO m¢d ?
         jnz       UPColRm2                 ; je MONO m¢d
         call      ReadUPMB                 ; naáten° bàënÇ barvy textu
         mov       di,UMenCol2              ; zvòraznàn† barva
         jmp       short UPColRm1

; ------ barva kurzoru

UPColCur:mov       di,UMenCol3              ; barva kurzoru
         test      byte ptr ds:[MonoMod],bit0+bit1 ; je MONO m¢d ?
         jnz       UPColRm2                 ; je MONO m¢d
         call      ReadUPMB                 ; naáten° bàënÇ barvy kurzoru
         mov       di,UMenCol4              ; zvòraznàn† barva kurzoru
         jmp       short UPColRm1

; ------ barva n†povàdy

UPColHlp:mov       di,UMenColP              ; barva n†povàdy
         test      byte ptr ds:[MonoMod],bit0+bit1 ; je MONO m¢d ?
         jnz       UPColRm2                 ; je MONO m¢d
         call      ReadUPMB                 ; naáten° bàënÇ barvy n†povàdy
         mov       di,UMenClP2              ; zvòraznàn† barva n†povàdy
         jmp       short UPColRm1

; ------ ELSE

UPELSE:  cmp       word ptr ds:[LevelIF],1  ; je vàtev IF vypnuta ?
         ja        UPELSE1                  ; je vypnut† podvàtev - ignoruje se
         je        UPELSE2                  ; byla vypnut† vàtev IF, teÉ se zapne
         inc       word ptr ds:[LevelIF]    ; druh† á†st podm°nky - vypnout
UPELSE1: ret

UPELSE2: dec       word ptr ds:[LevelIF]    ; druh† á†st podm°nky - zapnout
         ret

; ------ ENDIF

UPENDIF: cmp       word ptr ds:[LevelIF],0  ; bylo vypnut° podm°nky ?
         je        UPENDIF2                 ; nebylo vypnut°
         dec       word ptr ds:[LevelIF]    ; sn°ëen° £rovnà vypnut°
UPENDIF2:ret

; ------ IF

UPIF:    cmp       word ptr ds:[LevelIF],0  ; je jië vàtev vypnuta ?
         jne       UPIF1                    ; je vypnuta - vno©en°
         call      TestCond                 ; test podm°nky ES:SI
         jnc       UPIF2                    ; podm°nka splnàna - zñst†v† zapnuto
UPIF1:   inc       word ptr ds:[LevelIF]    ; á°taá vno©en° vypnut° IF
UPIF2:   ret

; ------ CASE

UPCCASE: cmp       word ptr ds:[LevelCAS],0 ; je vypnut° CASE ?
         jne       UPCCASE2                 ; je jië vypnut° CASE
         call      UPGetCs                  ; naáten° ©etàzce pro prvn° CASE

UPCCASE2:inc       word ptr ds:[LevelCAS]   ; zvò®en° á°taáe hloubky CASE
UPCCASE4:ret

; ------ IN

UPIN:    cmp       word ptr ds:[LevelCAS],1 ; je to z†kladn° vàtev CASE ?
         ja        UPCCASE4                 ; je hlubokÇ vno©en°
         jb        UPCCASE2                 ; dal®° sekce IN zak†z†na

         cmp       word ptr ds:[UMnCaseN],-1 ; byl jië ©etàzec nalezen ?
         je        UPCCASE4                 ; ©etàzec byl jië nalezen
         call      UPTstCs                  ; test ©etàzce CASE
         jc        UPCCASE4                 ; ©etàzec neodpov°d† - zñst†v† vyp.
UPIN3:   dec       word ptr ds:[LevelCAS]   ; sekce povolena
         mov       word ptr ds:[UMnCaseN],-1 ; zru®en° ©etàzce
         ret

; ------ OUT

UPOUT:   cmp       word ptr ds:[LevelCAS],1 ; je prvn° sekce ?
         ja        UPCCASE4                 ; je hlubokÇ vno©en° - zñst†v†
         jb        UPCCASE2                 ; dal®° sekce zak†z†na

         cmp       word ptr ds:[UMnCaseN],-1 ; byl ©etàzec nalezen ?
         je        UPCCASE4                 ; ©etàzec byl nalezen - vypnuto
         jmp       short UPIN3              ; zapnut° sekce OUT

; ------ ENDCASE

UPENDCS: cmp       word ptr ds:[LevelCAS],0 ; byla sekce CASE zapnuta ?
         je        UPENDCS2                 ; nebyla zapnuta
         dec       word ptr ds:[LevelCAS]   ; ukonáen° z†kazu sekce
         jnz       UPENDCS2                 ; byla to z†kladn° hladina ?
         mov       word ptr ds:[UMnCaseN],-1 ; zru®en° ©etàzce
UPENDCS2:ret

; ------ FOR

UPFOR:   test      byte ptr ds:[UParmFor],bit0 ; obsluhuje se FOR ?
         jz        UPFOR9                   ; FOR se neobsluhuje (=inicializace)
         cmp       word ptr ds:[BLokFor],0  ; je blokov†n° tàla FOR ?
         je        UPFOR8                   ; nen° blokov†n° tàla FOR
         inc       word ptr ds:[BlokFor]    ; zvò®en° á°taáe blokov†n°
         jmp       short UPFOR9

UPFOR8:  call      UPSetFor                 ; nastaven° cyklu FOR
UPFOR9:  and       byte ptr ds:[UParmFor],not bit2 ; nen° opakovanò vstup
         ret

; ------ EXITON

UPEXIT:  test      byte ptr ds:[UParmFor],bit0 ; obsluhuje se FOR ?
         jz        UPEXIT9                  ; FOR se neobsluhuje
         cmp       word ptr ds:[BlokFor],0  ; je blokov†n° tàla FOR ?
         jne       UPEXIT9                  ; je jië blokov†n° tàla FOR
         cmp       word ptr ds:[LevelFor],0 ; je zah†jen nàjakò cyklus FOR ?
         je        UPEXIT9                  ; nen° zah†jen ë†dnò cyklus FOR
         call      TestCond                 ; test podm°nky ES:SI
         jc        UPEXIT9                  ; podm°nka nesplnàna - pokraáov†n°
         inc       word ptr ds:[BlokFor]    ; blokov†n° zbytku tàla FOR
UPEXIT9: ret

; ------ ENDFOR

UPENDFR: test      byte ptr ds:[UParmFor],bit0 ; obsluhuje se FOR ?
         jz        UPENDF9                  ; FOR se neobsluhuje

         cmp       word ptr ds:[BlokFor],0  ; je blokov†n° tàla FOR ?
         jne       UPENDF7                  ; je blokov†n° tàla FOR

         mov       ax,ds:[LevelFOR]         ; poáet vno©en° FOR
         or        ax,ax                    ; je otev©en nàjakò FOR ?
         jz        UPENDF9                  ; nen° zah†jen cyklus FOR
         cmp       ax,MaxUFors              ; p©ekroáen poáet cyklñ FOR ?
         ja        UPENDF8                  ; p©ekroáen poáet cyklñ FOR
         mov       bx,ax                    ; BX <- á°slo cyklu FOR
         shl       ax,1
         add       bx,ax                    ; BX <- offset v tabulce FOR
         cmp       byte ptr es:[bx+UMenFors-3+2],0 ; je obsluha souborñ ?
         je        UPENDF5                  ; je obsluha souborñ
         inc       byte ptr es:[bx+UMenFors-3+2] ; zvò®en° á°sla ©etàzce

UPENDF5: mov       ax,es:[bx+UMenFors-3]    ; adresa zaá†tku cyklu
         mov       ds:[AdresFor],ax         ; adresa opakov†n° cyklu
         or        byte ptr ds:[UParmFor],bit2 ; opakovanò vstup do cyklu
         ret

UPENDF7: dec       word ptr ds:[BlokFor]    ; sn°ëen° á°taáe blokov†n° FOR
UPENDF8: dec       word ptr ds:[LevelFOR]   ; ukonáen° cyklu
UPENDF9: ret

; -----------------------------------------------------------------------------
;        obsluha zaá†tku cyklu FOR (ES:SI)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment definice menu
;                   SS:[BP-4] (2) adresa popisovaáe cyklu
;                   SS:[BP-6] (2) adresa zaá†tku jmÇna promànnÇ (v z†sobn°ku)
;                   SS:[BP-8] (2) dÇlka jmÇna promànnÇ
; -----------------------------------------------------------------------------

UPSetFor PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,256+8
         or        byte ptr ds:[UParmFor],bit1 ; nutn† zmàna adresy

; ------ adresa popisovaáe cyklu

         mov       ss:[bp-2],es             ; segment okna
         mov       ax,ds:[LevelFor]         ; hloubka
         shl       ax,1
         add       ax,ds:[LevelFor]         ; hloubka * 3
         add       ax,UMenFors-3            ; adresa popisovaáe
         mov       ss:[bp-4],ax             ; adresa definice cyklu

; ------ vytvo©en° novÇho p©°znaku cyklu

         test      byte ptr ds:[UParmFor],bit2   ; je opakovanò vstup do cyklu ?
         jnz       UPSetFr2                 ; je opakovanò vstup do cyklu
         inc       word ptr ds:[LevelFor]   ; zvò®en° á°taáe hloubky
         add       word ptr ss:[bp-4],3     ; zvò®en° ukazatele popisovaáe
         cmp       word ptr ds:[LevelFor],MaxUFors ; je jië maxim†ln° hloubka ?
         jbe       UPSetFr1                 ; nen° je®tà maxim†ln° hloubka

         inc       word ptr ds:[BlokFor]    ; zvò®en° á°taáe blokov†n°
         jmp       UPSetFr9                 ; p©ekroáena hloubka cyklñ

UPSetFr1:mov       bx,ss:[bp-4]             ; adresa popisovaáe
         mov       ax,ds:[AdresAkt]         ; aktu†ln° adresa ©†dku
         mov       es:[bx],ax               ; £schova aktu†ln° adresy ©†dku
         mov       byte ptr es:[bx+2],1     ; bude se obsluhovat 1. ©etàzec

; ------ dek¢dov†n° ©†dku do bufferu

UPSetFr2:mov       di,sp                    ; DI <- adresa bufferu
         xor       ax,ax                    ; barva nen°
         mov       dx,es                    ; segment adresy textu
         mov       cx,255                   ; CH=pozice, CL=velikost bufferu
         push      ss
         pop       es                       ; ES <- segment bufferu
         push      cs
         call      near ptr DekPLine        ; dek¢dov†n° textu ©†dku
         mov       byte ptr es:[di],0       ; oznaáen° konce textu

; ------ nalezen° zaá†tku jmÇna promànnÇ

         cld
         mov       si,sp                    ; buffer v z†sobn°ku
UPSetFr3:lods      byte ptr es:[si]         ; naáten° znaku
         cmp       al," "
         je        UPSetFr3
         cmp       al,TAB
         je        UPSetFr3
         dec       si                       ; n†vrat zaá†tku
         mov       ss:[bp-6],si             ; £schova adresy jmÇna promànnÇ
         cmp       al,";"
         je        UPSetF33                 ; nekoneánò cyklus
         cmp       al,0
         jne       UPSetF34                 ; je nàjakÇ jmÇno

; ------ nezad†no nic - je nekoneánò cyklus

UPSetF33:mov       bx,ss:[bp-4]             ; adresa popisovaáe cyklu
         mov       es,ss:[bp-2]             ; adresa menu
         mov       byte ptr es:[bx+2],1     ; p©°znak nekoneánÇho cyklu
         jmp       UPSetFr9

UPSetF32:jmp       UPSetFr8                 ; promànn† nezad†na - chyba

; ------ zji®tàn° dÇlky jmÇna promànnÇ

UPSetF34:xor       cx,cx                    ; CX <- á°taá dÇlky jmÇna promànnÇ
UPSetFr4:lods      byte ptr es:[si]         ; naáten° znaku
         inc       cx                       ; zvò®en° á°taáe dÇlky jmÇna
         cmp       al,"="                   ; konec ?
         je        UPSetF44                 ; konec jmÇna promànnÇ
         cmp       al," "                   ; konec ?
         ja        UPSetFr4                 ; dal®° platnò znak
UPSetF44:dec       si                       ; n†vrat znaku
         dec       cx                       ; n†vrat á°taáe dÇlky
         mov       ss:[bp-8],cx             ; dÇlka jmÇna promànnÇ

; ------ test, zda je jië reëim souborñ

         mov       es,ss:[bp-2]             ; segment okna
         mov       bx,ss:[bp-4]             ; adresa popisovaáe cyklui
         mov       cl,es:[bx+2]             ; á°taá á°sla ©etàzce
         mov       ch,0
         or        cx,cx
         jnz       UPSetF46
         jmp       UPSetFr7                 ; je reëim souborñ

; ------ nalezen° zaá†tku promànnÇ á°slo CX

UPSetF46:push      ss
         pop       es                       ; ES <- seg
UPSetFr5:lods      byte ptr es:[si]         ; naáten° znaku
         cmp       al," "
         je        UPSetFr5                 ; vypu®tàn° mezery
         cmp       al,TAB
         je        UPSetFr5                 ; vypu®tàn° tabul†toru
         cmp       al,"="
         je        UPSetFr5                 ; vypu®tàn° "="

         cmp       al,0                     ; konec ©†dku
         je        UPSetF32                 ; nen° dal®° parametr - blokov†n°
         cmp       al,";"
         je        UPSetF32                 ; nen° dal®° parametr - blokov†n°
         cmp       al,"@"
         je        UPSetF66                 ; otev©en° reëimu souborñ

; ------ zji®tàn° dÇlky promànnÇ -> BX, CX, AH

         push      cx
         push      ds

         push      es
         pop       ds                       ; DS <- segment textu
         call      Tst1CLen                 ; stanoven° dÇlky ©etàzce
         mov       di,bx                    ; DI <- zaá†tek textu promànnÇ
         mov       bx,cx                    ; BX <- dÇlka textu promànnÇ

         call      TestCSpc                 ; vypu®tàn° mezer
         lodsb                              ; naáten° znaku

         pop       ds
         pop       cx

; ------ dal®° promànn†

         cmp       al,","                   ; je oddàlovaá parametrñ ?
         je        UPSetFr6                 ; vypu®tàn° oddàlovaáe
         or        bx,bx                    ; pr†zdnò ©etàzec ?
         jz        UPSetFr6                 ; to byl asi neplatnò oddàlovaá
         dec       si                       ; n†vrat znaku
UPSetFr6:loop      UPSetFr5                 ; hled†n° dal®° promànnÇ

; ------ konverze parametru na velk† p°smena

         mov       cx,bx                    ; CX <- dÇlka textu parametru
         jcxz      UPSetF64                 ; nen° parametr
         cmp       ah,'"'                   ; bude konverze ?
         je        UPSetF64                 ; nebude konverze
         mov       si,di                    ; SI <- zaá†tek textu parametru
UPSetF62:lods      byte ptr es:[si]         ; naáten° znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         mov       byte ptr es:[si-1],al    ; uloëen° znaku
         loop      UPSetF62
UPSetF64:jmp       UPSetF72                 ; uloëen° hodnoty promànnÇ

; ------ otev©en° reëimu souborñ

UPSetF66:test      byte ptr ds:[UParmFor],bit3 ; je jië reëim souborñ ?
         jz        UPStF661
         jmp       UPSetFr8                 ; je jië reëim souborñ

UPStF661:push      bx
         push      si
         push      es
         call      far ptr GetAAWin         ; poskytnut° adresy aktivn°ho okna
         cmp       word ptr es:[AWinSNum],0 ; je nàco oznaáeno ?
         jne       UPStF660                 ; je nàco oznaáeno
         mov       bx,es:[AWinKurz]         ; soubor s kurzorem
         call      far ptr GetESPol         ; kurzor okna
         cmp       byte ptr es:[si+FileName],"." ; je to adres†© ".." ?
UPStF660:pop       es
         pop       si
         pop       bx
         cld
         mov       ah,bit2+bit6+bit7        ; v®echny soubory+adres†©e+vno©en°
         je        UPStF662                 ; oznaáen° v®ech poloëek

         mov       ah,bit1+bit6+bit7        ; oznaáenÇ soubory + adres†©e + vno©en°
UPStF662:lods      byte ptr es:[si]         ; naáten° znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"D"                   ; z†kaz adres†©ñ ?
         jne       UPStF663                 ; nen° z†kaz adres†©ñ
         and       ah,not bit6              ; z†kaz adres†©ñ
         jmp       short UPStF662

UPStF663:cmp       al,"S"                   ; z†kaz vno©en° ?
         jne       UPStF664                 ; nen° z†kaz vno©en°
         and       ah,not bit7              ; z†kaz vno©en°
         jmp       short UPStF662

UPStF664:cmp       al,"@"                   ; je hled†n° v®eho ?
         jne       UPStF666                 ; nen° hled†n° v®eho
         and       ah,not bit1              ; nen° hled†n° oznaáenòch
         or        ah,bit2                  ; je hled†n° v®eho
         jmp       short UPStF662

UPStF666:dec       si                       ; n†vrat znaku

         call      far ptr TestAAWn         ; je okno zapnuto ?
         jc        UPSetFr8                 ; okno nen° zapnuto
         mov       al,ah                    ; p©°znaky pro otev©en°
         call      far ptr InitFFil         ; inicializace vyhled†v†n°
         call      UserMGet                 ; poskytnut° segmentu menu -> ES
         mov       ss:[bp-2],es             ; adresa menu
         mov       bx,ss:[bp-4]             ; adresa popisovaáe cyklu
         mov       byte ptr es:[bx+2],0     ; reëim obsluhy souborñ
         or        byte ptr ds:[UParmFor],bit3 ; p©°znak hled†n° souborñ
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek

; ------ nalezen° dal®°ho souboru

UPSetFr7:;call      far ptr GetFFil          ; nalezen° jmÇna souboru

         call      SeznGZkr                 ; nalezen° dal®°ho souboru

         call      far ptr AktPth0L         ; aktualizace cesty v oknà

         jc        UPSetFr8                 ; nen° dal®° soubor

         mov       di,si                    ; DI <- zaá†tek promànnÇ
         mov       bx,cx                    ; BX <- dÇlka textu promànnÇ

; ------ nastaven° hodnoty parametru (hodnota DX:DI, dÇlka BX)

UPSetF72:mov       dx,es                    ; DX <- segment parametru
         push      ss
         pop       es
         mov       si,ss:[bp-6]             ; adresa jmÇna promànnÇ
         mov       cx,ss:[bp-8]             ; dÇlka jmÇna promànnÇ
         jcxz      UPSetFr9                 ; nen° promànn†
         call      far ptr SetEnv           ; nastaven° promànnÇ
         jnc       UPSetFr9                 ; operace OK

; ------ blokov†n° cyklu

UPSetFr8:inc       word ptr ds:[BlokFor]    ; á°taá blokov†n° cyklñ FOR
         call      UserMGet                 ; poskytnut° segmentu menu -> ES
         mov       bx,ss:[bp-4]             ; adresa popisovaáe cyklu
;         mov       es,ss:[bp-2]             ; adresa menu
         cmp       byte ptr es:[bx+2],0     ; byla obsluha souborñ ?
         jne       UPSetFr9                 ; nebyla obsluha souborñ

         call      far ptr ClosFFil         ; ukonáen° reëimu hled†n°
         and       byte ptr ds:[UParmFor],not bit3 ; zru®en° reëimu souborñ

; ------ n†vrat registrñ

UPSetFr9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UPSetFor ENDP

; -----------------------------------------------------------------------------
;        p©°prava ©etàzce ES:SI pro CASE
; -----------------------------------------------------------------------------

UPGetCs  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,256                   ; m°sto pro buffer

; ------ dek¢dov†n° textu do bufferu

         mov       di,sp                    ; DI <- adresa bufferu
         push      es                       ; segment menu
         xor       ax,ax                    ; barva nen°
         mov       dx,es                    ; segment adresy textu
         mov       cx,255                   ; CH=pozice, CL=velikost bufferu
         push      ss
         pop       es                       ; ES <- segment bufferu
         push      cs
         call      near ptr DekPLine        ; dek¢dov†n° textu ©†dku
         pop       es                       ; segment menu

; ------ stanoven° dÇlky ©etàzce -> CX, BX, AH

         cld
         mov       si,sp                    ; ukazatel textu
         push      ds

         push      ss
         pop       ds                       ; DS <- segment textu
         mov       byte ptr ds:[di],0       ; oznaáen° konce textu
         call      Tst1CLen                 ; stanoven° dÇlky ©etàzce

; ------ p©enesen° ©etàzce

         push      cx
         mov       si,bx                    ; zaá†tek ©etàzce
         mov       di,UMenCase              ; buffer k uloëen° textu CASE
         rep       movsb                    ; £schova ©etàzce
         pop       cx

; ------ uloëen° dÇlky ©etàzce

         pop       ds

         mov       ds:[UMnCaseN],cx         ; dÇlka ©etàzce CASE
         mov       ds:[UMnCaseC],ah         ; £vodn° znak ©etàzce

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UPGetCs  ENDP

; -----------------------------------------------------------------------------
;        porovn†n° ©etàzce ES:SI pro IN v CASE (CY=neodpov°d†)
; -----------------------------------------------------------------------------

UPTstCs  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         push      ds
         mov       bp,sp
         sub       sp,256                   ; m°sto pro buffer

; ------ dek¢dov†n° textu do bufferu

         mov       di,sp                    ; DI <- adresa bufferu
         push      es                       ; segment menu
         xor       ax,ax                    ; barva nen°
         mov       dx,es                    ; segment adresy textu
         mov       cx,255                   ; CH=pozice, CL=velikost bufferu
         push      ss
         pop       es                       ; ES <- segment bufferu
         push      cs
         call      near ptr DekPLine        ; dek¢dov†n° textu ©†dku
         pop       es                       ; segment menu

; ------ p©°prava k porovn†n° ©etàzce

         cld
         mov       si,sp                    ; SI <- ukazatel textu

         push      bp

         mov       dl,ds:[UMnCaseC]         ; £vodn° znak referenán°ho ©etàzce
         mov       bp,ds:[UMnCaseN]         ; dÇlka referenán°ho ©etàzce
         push      ss
         pop       ds                       ; segment textu
         mov       byte ptr ds:[di],0       ; oznaáen° konce textu

; ------ stanoven° dÇlky porovn†vanÇho ©etàzce DS:SI -> CX, BX, AH

UPTstCs1:call      Tst1CLen                 ; stanoven° dÇlky ©etàzce 1

; ------ porovn†n° ©etàzcñ

         mov       di,UMenCase              ; adresa referenán°ho ©etàzce
         call      Tst1Cmp                  ; porovn†n° ©etàzcñ
         test      al,bit0                  ; jsou ©etàzce shodnÇ ?
         jnz       UPTstCs9                 ; nalezen shodnò ©etàzec

; ------ test, zda bude dal®° ©etàzec seznamu

         call      TestCSpc                 ; vypu®tàn° mezer
         lodsb                              ; naáten° dal®°ho znaku
         cmp       al,","                   ; bude dal®° ©etàzec ?
         je        UPTstCs1                 ; bude dal®° ©etàzec
         dec       si                       ; n†vrat znaku
         stc                                ; p©°znak neshody ©etàzcñ

; ------ n†vrat registrñ

UPTstCs9:pop       bp

         mov       sp,bp
         pop       ds
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UPTstCs  ENDP

; -----------------------------------------------------------------------------
;        test podm°nky ©†dku ES:SI (CY=podm°nka nesplnàna)
; -----------------------------------------------------------------------------

TestCond PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         push      ds
         mov       bp,sp
         sub       sp,256                   ; m°sto pro buffer

; ------ dek¢dov†n° textu do bufferu

         xor       ax,ax                    ; barva nen°
         mov       dx,es                    ; segment adresy textu
         mov       cx,255                   ; CH=pozice, CL=velikost bufferu
         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; DI <- adresa bufferu
         push      cs
         call      near ptr DekPLine        ; dek¢dov†n° textu ©†dku

; ------ vyhodnocen° podm°nky (zde je ES=SS)

         mov       si,sp                    ; ukazatel textu
         push      ss
         pop       ds                       ; DS <- segment textu
         mov       byte ptr ds:[di],0       ; oznaáen° konce textu
         cld
         push      bp
         call      TstOCnd                  ; vyhodnocen° podm°nky (hladina OR)
         pop       bp

; ------ n†vrat registrñ

         mov       sp,bp
         pop       ds
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TestCond ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer v textu podm°nky -> AL=p©ipravenò znak, CY=konec textu
; -----------------------------------------------------------------------------

TestCSpc PROC      NEAR

; ------ vypu®tàn° mezer

TestCSp2:lodsb                              ; naáten° znaku
         cmp       al," "
         je        TestCSp2
         cmp       al,TAB
         je        TestCSp2
         dec       si                       ; n†vrat znaku

; ------ test, zda je konec ©†dku

         cmp       al,LF
         je        TestCSp4                 ; konec textu
         cmp       al,";"
         je        TestCSp4                 ; koment†© - konec textu
         cmp       al,0
         jne       TestCSp6                 ; nen° konec textu (je NC)
TestCSp4:stc                                ; CY = p©°znak konce textu
TestCSp6:ret

TestCSpc ENDP

; -----------------------------------------------------------------------------
;        vyhodnocen° hladiny OR (CY=podm°nka nesplnàna)
; -----------------------------------------------------------------------------

TstOCnd  PROC      NEAR

; ------ vyhodnocen° hladiny AND - nalezen° splnànÇ podm°nky

TstOCnd1:call      TstACnd                  ; vyhodnocen° prvn° hladiny AND
         jnc       TstOCnd3                 ; podm°nka splnàna

; ------ podm°nka nesplnàna - nalezen° dal®°ho operandu

TstOCnd2:call      TestCSpc                 ; vypu®tàn° mezer
         jc        TstOCnd9                 ; nen° dal®° operand - nesplnàno
         cmp       al,")"                   ; konec vòrazu ?
         stc
         je        TstOCnd9                 ; konec vòrazu
         lodsb                              ; naáten° znaku
         cmp       al,"|"
         je        TstOCnd2                 ; vypu®tàn° oddàlovaáe "|"
         dec       si                       ; n†vrat znaku
         jmp       short TstOCnd1           ; test dal®°ho operandu

; ------ podm°nka splnàna - p©eskoáen° ostatn°ch operandñ

TstOCnd3:call      TestCSpc                 ; vypu®tàn° mezer
         jc        TstOCnd6                 ; nen° dal®° operand
         cmp       al,")"                   ; konec vòrazu ?
         je        TstOCnd6                 ; konec vòrazu
         lodsb                              ; naáten° znaku
         cmp       al,"|"                   ; bude dal®° operand ?
         je        TstOCnd3                 ; vypu®tàn° oddàlovaáe "|"
         dec       si                       ; n†vrat znaku
         call      TstACnd                  ; vyhodnocen° dal®° hladiny AND
         jmp       short TstOCnd3           ; p©eskoáen° dal®°ho operandu

TstOCnd6:clc                                ; p©°znak splnàn° podm°nky
TstOCnd9:ret

TstOCnd  ENDP

; -----------------------------------------------------------------------------
;        vyhodnocen° hladiny AND (CY=podm°nka nesplnàna)
; -----------------------------------------------------------------------------

TstACnd  PROC      NEAR

; ------ vyhodnocen° jednoho operandu - nalezen° nesplnànÇ podm°nky

TstACnd1:call      Tst1Cnd                  ; vyhodnocen° operandu
         jc        TstACnd3                 ; podm°nka nesplnàna

; ------ podm°nka splnàna - test, zda je oddàlovaá "&"

         call      TestCSpc                 ; vypu®tàn° mezer
         cmp       al,"&"                   ; bude dal®° operand ?
         clc                                ; p©°znak splnàn° podm°nky
         jne       TstACnd9                 ; podm°nka splnàna

; ------ test, zda bude dal®° operand (a vypu®tàn° dal®°ch znakñ "&")

TstACnd2:inc       si                       ; p©eskoáen° znaku "&"
         call      TestCSpc                 ; vypu®tàn° mezer
         cmc
         jnc       TstACnd9                 ; nen° dal®° operand
         cmp       al,"&"
         je        TstACnd2                 ; p©eskoáen° znaku "&"
         jmp       short TstACnd1           ; test dal®°ho operandu

; ------ podm°nka nesplnàna - p©eskoáen° ostatn°ch operandñ

TstACnd3:call      TestCSpc                 ; vypu®tàn° mezer
         cmp       al,"&"                   ; bude dal®° operand ?
         jne       TstACnd6                 ; nebude dal®° operand
         inc       si                       ; p©eskoáen° znaku "&"
         call      Tst1Cnd                  ; vyhodnocen° dal®°ho operandu
         jmp       short TstACnd3           ; p©eskoáen° dal®°ho operandu

TstACnd6:stc                                ; p©°znak nesplnàn° podm°nky
TstACnd9:ret

TstACnd  ENDP

; -----------------------------------------------------------------------------
;        vyhodnocen° jednoho operandu podm°nky (CY=podm°nka nesplnàna)
; -----------------------------------------------------------------------------

Tst1Cnd  PROC      NEAR

; ------ vypu®tàn° mezer

         call      TestCSpc                 ; vypu®tàn° mezer p©ed vòrazem
         jc        Tst1Cn32                 ; nen° dal®° znak

; ------ vno©enò vòraz v z†vorce

         cmp       al,"("                   ; je vno©enò vòraz ?
         jne       Tst1Cnd4                 ; nen° vno©enò vòraz
         inc       si                       ; p©eskoáen° znaku "("
         cmp       sp,MinSP                 ; minim†ln° adresa SP
         jb        Tst1Cnd2                 ; chyba
         call      TstOCnd                  ; vyhodnocen° hladiny OR
Tst1Cnd2:pushf
         call      TestCSpc                 ; vypu®tàn° mezer
         cmp       al,")"                   ; je ukonáovac° z†vorka ?
         jne       Tst1Cnd3                 ; nen° ukonáovac° z†vorka
         inc       si                       ; p©eskoáen° z†vorky
Tst1Cnd3:popf
Tst1Cn32:ret

; ------ negace podm°nky

Tst1Cnd4:cmp       al,"!"                   ; je negace ?
         jne       Tst1Cnd6                 ; nen° negace
         inc       si                       ; p©eskoáen° znaku "!"
         cmp       sp,MinSP                 ; minim†ln° adresa SP
         jb        Tst1Cnd5                 ; chyba
         call      Tst1Cnd                  ; vyhodnocen° operandu
Tst1Cnd5:cmc                                ; negace vòsledku
         ret

; ------ stanoven° dÇlky ©etàzce 1 -> dÇlka BP, adresa DI, znak DL

Tst1Cnd6:call      Tst1CLen                 ; stanoven° dÇlky ©etàzce 1
         mov       dh,0                     ; DH <- 0 nen° oddàlovac° znak
Tst1Cn62:mov       bp,cx                    ; BP <- dÇlka ©etàzce 1
         mov       di,bx                    ; DI <- zaá†tek ©etàzce 1
         mov       dl,ah                    ; DL <- £vodn° znak ©etàzce 1
         and       dh,not bit0+bit1+bit2+bit3+bit4

; ------ oddàlovac° znaky mezi ©etàzci

Tst1Cnd7:call      TestCSpc                 ; vypu®tàn° mezer
         lodsb                              ; naáten° znaku
         cmp       al,"="
         jne       Tst1Cn71
         or        dh,bit0                  ; bit 0 = shoda
         jmp       short Tst1Cnd7

Tst1Cn71:cmp       al,">"
         jne       Tst1Cn72
         or        dh,bit1                  ; bit 1 = vàt®°
         jmp       short Tst1Cnd7

Tst1Cn72:cmp       al,"<"
         jne       Tst1Cn73
         or        dh,bit2                  ; bit 2 = men®°
         jmp       short Tst1Cnd7

Tst1Cn73:cmp       al,"!"
         jne       Tst1Cn74
         xor       dh,bit3                  ; bit 3 = inverze
         jmp       short Tst1Cnd7

Tst1Cn74:dec       si                       ; n†vrat znaku
         test      dh,bit0+bit1+bit2        ; nàco zad†no ?
         jz        Tst1Cnd8                 ; nebylo nic zad†no

; ------ stanoven° parametrñ ©etàzce 2 -> dÇlka CX, adresa BX, znak AH

Tst1Cn75:call      Tst1CLen                 ; stanoven° parametrñ ©etàzce 2

; ------ porovn†n° textñ ©etàzcñ

         call      Tst1Cmp                  ; porovn†n° ©etàzcñ

; ------ p©°znak splnàn° podm°nky

         and       al,dh                    ; test splnàn° podm°nky
         mov       al,bit4                  ; p©°znak splnàn° podm°nky
         jnz       Tst1Cn76                 ; podm°nka splnàna OK
         mov       al,0                     ; p©°znak nesplnàn° podm°nky
Tst1Cn76:test      dh,bit3                  ; je inverze podm°nky ?
         jz        Tst1Cn77                 ; nen° inverze podm°nky
         xor       al,bit4                  ; inverze podm°nky
Tst1Cn77:or        dh,al                    ; p©°znak splnàn° podm°nky

; ------ test, zda bude dal®° ©etàzec seznamu

         call      TestCSpc                 ; vypu®tàn° mezer
         lodsb                              ; naáten° znaku
         cmp       al,","                   ; bude dal®° ©etàzec ?
         je        Tst1Cn75                 ; porovn†n° dal®°ho ©etàzce
         dec       si                       ; n†vrat znaku

         test      dh,bit4                  ; vyhovoval nàkterò pod©etàzec ?
         jnz       Tst1Cn78                 ; vyhovoval
         or        dh,bit5                  ; p©°znak nesplnàn° podm°nky
Tst1Cn78:jmp       short Tst1Cn62           ; nebude dal®° ©etàzec seznamu

; ------ test splnàn° podm°nky

Tst1Cnd8:test      dh,bit5                  ; podm°nka splnàna ?
         jz        Tst1Cnd9                 ; podm°nka splnàna
         stc                                ; p©°znak nesplnàn° podm°nky
Tst1Cnd9:ret

Tst1Cnd  ENDP

; -----------------------------------------------------------------------------
;   porovn†n° ©etàzcñ ES:DI/BP (typ DL) a DS:BX/CX (typ AH) -> AL (b0= b1> b2<)
; -----------------------------------------------------------------------------

Tst1Cmp  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      di
         push      dx
         push      cx                       ; CX mus° bòt posledn° !

; ------ p©°prava dÇlky ©etàzce (krat®° z dÇlek) -> CX

         cmp       bp,cx                    ; dÇlka ©etàzce 1 = dÇlka ©etàzce 2?
         jne       Tst1Cmp5                 ; nen° shoda - plat° porovn†n° dÇlek

;         jae       Tst1Cmp1                 ; dÇlka 1 >= dÇlka 2
;         mov       cx,bp                    ; CX <- krat®° je ©etàzec 1

; ------ dÇlka = 0

Tst1Cmp1:or        cx,cx                    ; dÇlka = 0 ? (nastaven° ZY)
         jz        Tst1Cmp5                 ; ©etàzce shodnÇ (nastaveno ZY a NC)

; ------ naáten° znaku ©etàzce 1 -> AL

Tst1Cmp2:mov       al,es:[di]               ; naáten° znaku ©etàzce 1
         inc       di                       ; zvò®en° ukazatele textu

; ------ konverze na velkÇ p°smeno

         cmp       dl,'"'                   ; nahrazuje se ?
         je        Tst1Cmp3                 ; nenahrazuje se
         cmp       al,"a"
         jb        Tst1Cmp3                 ; nen° malÇ p°smeno
         cmp       al,"z"
         ja        Tst1Cmp3                 ; nen° malÇ p°smeno
         sub       al,32                    ; konverze na velkÇ p°smeno

; ------ naáten° znaku ©etàzce 2 -> DH

Tst1Cmp3:mov       dh,ds:[bx]               ; znak ©etàzce 2
         inc       bx                       ; zvò®en° ukazatele textu

; ------ konverze na velkÇ p°smeno

         cmp       ah,'"'                   ; nahrazuje se ?
         je        Tst1Cmp4                 ; nenahrazuje se
         cmp       dh,"a"
         jb        Tst1Cmp4                 ; nen° malÇ p°smeno
         cmp       dh,"z"
         ja        Tst1Cmp4                 ; nen° malÇ p°smeno
         sub       dh,32                    ; konverze na velkÇ p°smeno

; ------ porovn†n° znakñ 1 a 2

Tst1Cmp4:cmp       al,dh                    ; porovn†n° znakñ
         loope     Tst1Cmp2                 ; p©i shodà dal®° znak

; ------ rozli®en° vòsledku porovn†n°

Tst1Cmp5:
;         ja        Tst1Cmp6                 ; ©etàzec 1 > ©etàzec 2
         jb        Tst1Cmp7                 ; ©etàzec 1 < ©etàzec 2

; ------ p©i shodà porovn†n° dÇlek 1 a 2

;         pop       cx                       ; dÇlka ©etàzce 2
;         push      cx
;         cmp       bp,cx                    ; porovn†n° dÇlek 1 ? 2
;         jb        Tst1Cmp7                 ; ©etàzec 1 < ©etàzec 2
         mov       al,bit0                  ; shodnÇ
         je        Tst1Cmp8                 ; ©etàzce shodnÇ

; ------ ©etàzce 1 > ©etàzec 2

Tst1Cmp6:mov       al,bit1                  ; vàt®°
         jmp       short Tst1Cmp8

; ------ ©etàzec 1 < ©etàzec 2

Tst1Cmp7:mov       al,bit2                  ; men®°

; ------ n†vrat registrñ

Tst1Cmp8:pop       cx
         pop       dx
         pop       di
         pop       bx
         ret

Tst1Cmp  ENDP

; -----------------------------------------------------------------------------
;        stanoven° dÇlky ©etàzce DS:SI -> CX=dÇlka, AH=£vodn° znak, BX=adresa
; -----------------------------------------------------------------------------

Tst1CLen PROC      NEAR

; ------ vypu®tàn° mezer

         call      TestCSpc                 ; vypu®tàn° mezer

; ------ ohraniáuj°c° znak ©etàzce -> AL

         lodsb                              ; naáten° znaku
         cmp       al,"'"
         je        Tst1CLn2                 ; je ©etàzec v ' '
         cmp       al,'"'
         je        Tst1CLn2                 ; je ©etàzec v " "
         dec       si                       ; n†vrat znaku
         mov       al,0                     ; nen° ohraniáen° uvozovkami

; ------ p©°prava ke stanoven° dÇlky ©etàzce

Tst1CLn2:mov       ah,al                    ; AH <- £schova poá†teán°ho znaku
         mov       bx,si                    ; BX <- adresa poá†tku ©etàzce
         xor       cx,cx                    ; CX <- 0 á°taá dÇlky

; ------ naáten° znaku ©etàzce

Tst1CLn4:lodsb                              ; naáten° znaku
         inc       cx                       ; zvò®en° á°taáe dÇlky ©etàzce

; ------ test, zda je konec textu

         cmp       al,0                     ; konec textu ?
         je        Tst1CLn8                 ; konec textu
         cmp       al,LF                    ; konec ©†dku ?
         je        Tst1CLn8                 ; konec ©†dku

; ------ test, zda je ohraniáen° uvozovkami

         or        ah,ah                    ; ohraniáen° uvozovkami ?
         jz        Tst1CLn6                 ; nen° ohraniáen° uvozovkami

; ------ konec ©etàzce, je-li ohraniáen° uvozovkami

         cmp       al,ah                    ; konec ©etàzce ?
         jne       Tst1CLn4                 ; nen° konec ©etàzce - dal®° znak
         jmp       short Tst1CLn9           ; konec ©etàzce

; ------ konec ©etàzce, nen°-li ohraniáen° uvozovkami

Tst1CLn6:cmp       al,";"
         je        Tst1CLn8
         cmp       al," "
         je        Tst1CLn8
         cmp       al,TAB
         je        Tst1CLn8
         cmp       al,")"
         je        Tst1CLn8
         cmp       al,"("
         je        Tst1CLn8
         cmp       al,"!"
         je        Tst1CLn8
         cmp       al,"&"
         je        Tst1CLn8
         cmp       al,"|"
         je        Tst1CLn8
         cmp       al,","
         je        Tst1CLn8
         cmp       al,"<"
         je        Tst1CLn8
         cmp       al,">"
         je        Tst1CLn8
         cmp       al,"="
         jne       Tst1CLn4                 ; nen° konec ©etàzce

; ------ korekce dÇlky ©etàzce

Tst1CLn8:dec       si                       ; n†vrat znaku
Tst1CLn9:dec       cx                       ; oprava dÇlky ©etàzce
         ret

Tst1CLen ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla (bajt) do DI (korekce CX - odeáte se od á°sla)
; -----------------------------------------------------------------------------

ReadUPMN:call      ReadUPMM                 ; naáten° á°sla do AX
         jc        ReaUPMN4                 ; á°slo nebylo zad†no
         sub       ax,cx                    ; odeáten° korekce
         jnc       ReaUPMN1                 ; nen° podteáen°
         xor       ax,ax                    ; omezen° p©i podteáen° na 0
ReaUPMN1:or        ah,ah                    ; je to v°ce neë 1 bajt ?
         jz        ReaUPMN2                 ; á°slo je OK
         mov       al,255                   ; omezen° p©i p©eteáen°
ReaUPMN2:mov       es:[di],al               ; uloëen° zadanÇ hodnoty
ReaUPMN4:call      ReadUPMO                 ; vypu®tàn° á†rky
         ret

; -----------------------------------------------------------------------------
;        naáten° barvy do ES:DI (2 znaky HEX)
; -----------------------------------------------------------------------------

ReadUPMB:mov       ah,es:[di]               ; pñvodn° barva
         call      ReadUPMS                 ; vypu®tàn° mezer
         jc        ReaUPMB2                 ; konec ©†dku

         call      ReadUPMH                 ; naáten° prvn°ho znaku HEX
         jc        ReaUPMB2                 ; nen° prvn° znak
         and       ah,0f0h                  ; z pñvodn° barvy se ponech† pozad°
         or        ah,al                    ; nov† je barva pop©ed°
         jnz       ReaUPMB1                 ; barva je OK
         mov       ah,70h                   ; n†hradn° barva - áern† na b°lÇ

ReaUPMB1:call      ReadUPMH                 ; naáten° druhÇho znaku HEX
         jc        ReaUPMB2                 ; nen° druhò znak
         shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1                     ; barva pozad°
         or        ah,al                    ; p©id† se barva pop©ed°
         jnz       ReaUPMB2                 ; barva je OK
         mov       ah,8                     ; n†hradn° barva - ®ed† na áernÇ

ReaUPMB2:mov       es:[di],ah               ; uloëen° novà naátenÇ barvy
         call      ReadUPMO                 ; vypu®tàn° á†rky
         ret

; -----------------------------------------------------------------------------
;        naáten° dekadickÇho á°sla do AX (CY=nen° á°slo)
; -----------------------------------------------------------------------------

ReadUPMM:push      bx
         push      dx

         xor       bx,bx                    ; BX <- 0 st©adaá á°sla
         call      ReadUPMS                 ; vypu®tàn° mezer
         call      ReadUPMD                 ; naáten° prvn° á°slice
         jc        ReaUPMM8                 ; nen° á°slo

ReaUPMM2:mov       ah,0                     ; AX = naáten† á°slice
         push      ax
         mov       ax,10                    ; n†sobitel
         mul       bx                       ; vyn†soben° st©adaáe á°sla
         pop       bx                       ; naáten† á°slice

         add       bx,ax                    ; p©iáten° á°sla ke st©adaái
         adc       dx,dx                    ; je p©eteáen° ?
         jz        ReaUPMM4                 ; nen° p©eteáen° á°sla
         mov       bx,-1                    ; omezen° p©i p©eteáen°
ReaUPMM4:call      ReadUPMD                 ; naáten° dal®° á°slice
         jnc       ReaUPMM2                 ; je dal®° á°slice
         clc                                ; p©°znak operace OK

ReaUPMM8:xchg      ax,bx                    ; AX <- naátenÇ á°slo
         pop       dx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        naáten° znaku dekadickÇ á°slice (CY=nen°) -> AL
; -----------------------------------------------------------------------------

ReadUPMD:call      ReadUPMC                 ; naáten° znaku
         jc        ReaUPMD4                 ; nen° platnò znak
         cmp       al,"9"
         ja        ReaUPMD3                 ; nen° platn† á°slice
         sub       al,"0"
         jae       ReaUPMD4                 ; je platn† á°slice OK
ReaUPMD3:dec       si                       ; n†vrat neplatnÇho znaku
         stc                                ; p©°znak neplatnÇho znaku
ReaUPMD4:ret

; -----------------------------------------------------------------------------
;        naáten° znaku parametru HEX (CY=nen°) -> AL
; -----------------------------------------------------------------------------

ReadUPMH:call      ReadUPMC                 ; naáten° znaku
         jc        ReaUPMH4                 ; nen° dal®° znak
         cmp       al,"0"
         jb        ReaUPMH3                 ; nen° platnò znak HEX
         cmp       al,"9"
         jbe       ReaUPMH2                 ; je platn† á°slice OK
         cmp       al,"F"
         ja        ReaUPMH3                 ; nen° platnò znak HEX
         cmp       al,"A"
         jb        ReaUPMH3                 ; nen° platnò znak HEX
         sub       al,7
ReaUPMH2:sub       al,"0"                   ; korekce na á°slo
         ret

ReaUPMH3:dec       si                       ; n†vrat neplatnÇho znaku
         stc                                ; p©°znak neplatnÇho znaku HEX
ReaUPMH4:ret

; -----------------------------------------------------------------------------
;        naáten° znaku oddàlovac° á†rky (CY=nen° á†rka)
; -----------------------------------------------------------------------------

ReadUPMO:call      ReadUPMS                 ; vypu®tàn° mezer
         jc        ReaUPMO2                 ; konec
         call      ReadUPMC                 ; naáten° znaku
         cmp       al,","                   ; je oddàlovac° á†rka ?
         je        ReaUPMO2                 ; je á†rka OK
         dec       si                       ; n†vrat znaku
         stc                                ; p©°znak - nen° á†rka
ReaUPMO2:ret

; -----------------------------------------------------------------------------
;        nalezen° zaá†tku parametru (CY=nen°) -> AL p©ipravenò znak
; -----------------------------------------------------------------------------

ReadUPMS:call      ReadUPMC                 ; naáten° znaku
         je        ReadUPMS                 ; p©eskoáen° mezery
         jb        ReaUPMS2                 ; je konec ©†dku
         dec       si                       ; n†vrat ukazatele na platnò znak
ReaUPMS2:ret

; -----------------------------------------------------------------------------
;        naáten° znaku ES:SI (CY=nen°, ZY=mezera)
; -----------------------------------------------------------------------------

ReadUPMC:mov       al,es:[si]               ; znak
         inc       si                       ; zvò®en° ukazatele textu
         cmp       al,CR                    ; je CR ?
         je        ReadUPMC                 ; ignorov†n° CR

         cmp       al,TAB                   ; je tabul†tor ?
         jne       ReaUPMC2                 ; nen° tabul†tor
         mov       al," "                   ; n†hrada tabul†toru mezerou

ReaUPMC2:cmp       al,";"                   ; je koment†© ?
         jne       ReaUPMC3                 ; nen° koment†©
         mov       al,LF                    ; n†hrada koncem ©†dku

ReaUPMC3:call      far ptr UpCase           ; konverze na velkÇ p°smeno

         cmp       al," "                   ; je konec ©†dku ?
         jae       ReaUPMC5                 ; nen° konec ©†dku
         dec       si                       ; n†vrat ukazatele na konec ©†dku
ReaUPMC5:ret

; *****************************************************************************
;                                InitCMnu
;                     inicializace uëivatelskÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

InitCMnu PROC      FAR

         push      ax
         push      cx
         push      si
         push      es

         mov       ax,ds:[si+MnuCSegm]      ; á°slo segmentu menu
         call      far ptr GetDat           ; adresa segmentu menu

         mov       ax,es:[UMenNadN]         ; poáet ©†dkñ z†hlav° a titulku
         or        ax,ax                    ; jsou nàjakÇ ©†dky ?
         jz        InitCMn1                 ; nejsou ë†dnÇ ©†dky
         dec       ax                       ; bez ©†dku titulku

InitCMn1:cmp       word ptr es:[UMenLinN],0 ; jsou nàjakÇ ©†dky ?
         je        InitCMn2                 ; nejsou ë†dnÇ ©†dky
         or        ax,ax
         jz        InitCM12                 ; nejsou ©†dky z†hlav°
         inc       ax                       ; váetnà oddàlovac° á†ry
InitCM12:add       ax,es:[UMenLinN]         ; p©iáten° zobrazenòch ©†dkñ

InitCMn2:inc       ax
         inc       ax                       ; váetnà okrajñ

InitCMn3:mov       ch,0
         mov       cl,ds:[Radku]            ; poáet ©†dkñ na displeji
         sub       cl,3                     ; asi tolik ©†dkñ jako rezerva

         cmp       ax,cx
         jb        InitCMn4                 ; vò®ka okna nep©ekroáena
         xchg      ax,cx                    ; omezen° vò®ky okna

InitCMn4:cmp       byte ptr es:[UMenMVys],0 ; je vò®ka okna zad†na ?
         je        InitCM44                 ; vò®ka okna nen° zad†na
         mov       al,es:[UMenMVys]         ; zadan† vò®ka okna
         cmp       al,ds:[MaxRow]           ; p©ekroáena vò®ka okna ?
         jbe       InitCM44                 ; vò®ka okna nen° p©ekroáena
         mov       al,ds:[MaxRow]           ; omezen° vò®ky okna

InitCM44:cmp       al,5                     ; minim†ln° vò®ka okna
         ja        InitCMn5
         mov       al,5

InitCMn5:mov       ds:[si+MnuVys],al        ; vò®ka okna

; ------ poá†teán° ©†dek okna

         mov       al,ds:[Radku]            ; poáet ©†dkñ
         dec       ax
         sub       al,ds:[si+MnuVys]        ; zbytek na okraje
         jnc       InitCMn6
         mov       al,0
InitCMn6:shr       al,1
         cmp       byte ptr es:[UMenMRad],-1 ; zad†n poá†teán° ©†dek ?
         je        InitCM64                 ; poá†teán° ©†dek nezad†n
         mov       al,es:[UMenMRad]         ; zadanò poá†teán° ©†dek
         mov       ah,ds:[MaxRow]           ; poáet ©†dkñ okna-1
         sub       ah,ds:[si+MnuVys]        ; maxim†ln° poá†teán° ©†dek
         cmp       al,ah
         jbe       InitCM64                 ; poá†teán° ©†dek je OK
         mov       al,ah                    ; omezen° poá†teán°ho ©†dku
InitCM64:mov       ds:[si+MnuRad],al        ; poá†teán° ©†dek okna

; ------ ®°©ka okna

         mov       al,ds:[Pozic]
         sub       al,5                     ; bez okrajñ
         cmp       byte ptr es:[UMenMSir],0 ; zad†na ®°©ka okna ?
         je        InitCM65                 ; ®°©ka okna nezad†na
         mov       al,es:[UMenMSir]         ; zadan† ®°©ka okna
         cmp       al,ds:[Pozic]            ; maxim†ln° ®°©ka okna
         jbe       InitCM65                 ; ®°©ka okna je OK
         mov       al,ds:[Pozic]            ; omezen° ®°©ky okna
InitCM65:cmp       al,10                    ; minim†ln° ®°©ka okna
         jae       InitCM66                 ; ®°©ka okna je OK
         mov       al,10                    ; minim†ln° ®°©ka okna
InitCM66:mov       ds:[si+MnuSir],al        ; ®°©ka okna

; ------ poá†teán° pozice okna

InitCMn8:mov       al,ds:[Pozic]
         sub       al,ds:[si+MnuSir]
         jnc       InitCMn9
         mov       al,0
InitCMn9:shr       al,1
         cmp       byte ptr es:[UMenMPoz],-1 ; zad†na poá†teán° pozice okna ?
         je        InitCM94                 ; poá†teán° pozice nezad†na
         mov       al,es:[UMenMPoz]         ; zadan† poá†teán° pozice okna
         mov       ah,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       ah,ds:[si+MnuSir]        ; maxim†ln° pozice okna
         cmp       al,ah                    ; p©ekroáena maxim†ln° pozice ?
         jbe       InitCM94                 ; poá†teán° pozice je OK
         mov       al,ah                    ; omezen° poá†teán° pozice
InitCM94:mov       ds:[si+MnuPoz],al        ; poá†teán° pozice okna

; ------ posun ukazatele kurzoru menu na zaá†tek

         mov       word ptr es:[UMenLinT],0 ; poá†teán° zobrazenò ©†dek
         xor       ax,ax                    ; AX <- 0
         xchg      ax,es:[UMenVolK]         ; p©ednastavenò kurzor
         inc       ax                       ; p©ednastaven° + 1
         cmp       ax,es:[UMenVolN]         ; je kurzor OK ?
         jbe       InitCMnD                 ; kurzor je OK
         mov       ax,es:[UMenVolN]         ; omezen° á°sla kurzoru

InitCMnD:mov       word ptr es:[UMenLinK],0 ; ©†dek s kurzorem
         mov       cx,es:[UMenLinN]         ; poáet zobrazenòch ©†dkñ
         mov       si,es:[UMenParI]         ; tabulka parametrñ ©†dkñ
         jcxz      InitCMnC                 ; nen° ë†dnò ©†dek
InitCMnA:test      byte ptr es:[si],bit7    ; je ©†dek volby ?
         jz        InitCMnB                 ; nen° to ©†dek volby
         dec       ax                       ; je to hledan† volba ?
         jz        InitCMnC                 ; je to hledan† volba
         inc       word ptr es:[UMenVolK]   ; zvò®en° ukazatele kurzoru
InitCMnB:inc       si                       ; zvò®en° ukazatele v tabulce
         inc       word ptr es:[UMenLinK]   ; zvò®en° ukazatele á°sla ©†dku
         loop      InitCMnA                 ; dal®° ©†dek

; ------ n†vrat registrñ

InitCMnC:pop       es
         pop       si
         pop       cx
         pop       ax
         ret

InitCMnu ENDP

; *****************************************************************************
;                                DispCMnu
;                    zobrazen° uëivatelskÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice menu
;                   SS:[BP-4] (2) á°slo segmentu menu
;                   SS:[BP-6] (2) adresa segmentu menu
;                   SS:[BP-7] (1) ukazatel á°sla ©†dku
;                   SS:[BP-8] (1) ukazatel á°sla pozice
;                   SS:[BP-10] (2) hladina k zobrazen°
;                   SS:[BP-11] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-12] (1) vnit©n° ®°©ka okna
;
;                   SS:[BP-13] (1) zvòraznàn† barva z†hlav°
;                   SS:[BP-14] (1) barva z†hlav°
;                   SS:[BP-15] (1) barva titulku
;                   SS:[BP-16] (1) barva r†mu - tmav†
;                   SS:[BP-17] (1) zvòraznàn† barva kurzoru
;                   SS:[BP-18] (1) barva kurzoru
;                   SS:[BP-19] (1) zvòraznàn† bàën† barva
;                   SS:[BP-20] (1) bàën† barva
;
;                   SS:[BP-22] (2) á°taá ©†dkñ z†hlav°
;                   SS:[BP-24] (2) ukazatel á°sla ©†dku z†hlav°
;                   SS:[BP-26] (2) adresa p©echodnÇho dek¢d. bufferu (255 B)
;                   SS:[BP-28] (2) datovò segment DS
;                   SS:[BP-30] (2) á°taá zobrazenòch ©†dkñ
;                   SS:[BP-32] (2) ukazatel á°sla zobrazenÇho ©†dku
;                   SS:[BP-34] (2) á°taá zobrazenÇho ©†dku s kurzorem
;                   SS:[BP-35] (1) ukazatel pozice na ©†dku menu
;                   SS:[BP-36] (1) parametry dek¢dovanÇho ©†dku
;                                    bit 0 aë bit 3: dÇlka textu horkÇ kl†vesy
;                                    bit 6: 1=je navazuj°c° menu
;                                    bit 7: 1=©†dek volby (kurzor)
;                   SS:[BP-37] (1) barva r†mu - svàtl†
;                   SS:[BP-38] (1)
;                   SS:[BP-40] (2) segment dek¢dovac° tabulky fontñ
;                   SS:[BP-42] (2) offset dek¢dovac° tabulky fontñ
; *****************************************************************************
;˛
DispCMnu PROC      FAR

         call      NormCMnu                 ; normalizace menu

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,42 + 2*255

; ------ inicializace lok†ln°ch promànnòch

         mov       ss:[bp-2],si             ; adresa definice menu
         mov       ax,ds:[si+MnuCSegm]      ; segment okna
         mov       ss:[bp-4],ax             ; á°slo segmentu menu
         call      far ptr GetDat           ; adresa definice okna
         mov       ss:[bp-6],es             ; adresa definice okna
         mov       ax,word ptr ds:[si+MnuPoz] ; ©†dek a pozice
         mov       ss:[bp-8],ax             ; ©†dek a pozice
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen°
         mov       ah,0
         mov       ss:[bp-10],ax            ; hladina k zobrazen° menu
         mov       ax,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna
         sub       al,2                     ; vnit©n° ®°©ka okna
         dec       ah                       ; vò®ka okna - spodn° ©†dek
         mov       ss:[bp-12],ax            ; ®°©ka a vò®ka okna

         mov       ss:[bp-26],sp            ; adresa p©echodnÇho dek¢d. bufferu
         mov       ah,0
         inc       ax
         inc       ax                       ; rezerva pro okraje
         shl       ax,1                     ; velikost bufferu v bajtech
         sub       sp,ax                    ; 2. buffer pro p©°pravu ©etàzcñ

         mov       ax,es:[UMenCol1]         ; bàën† a zvòraznàn† barva
         mov       ss:[bp-20],ax            ; bàën† a zvòraznàn† barva
         mov       ax,es:[UMenCol3]         ; barva kurzoru
         mov       ss:[bp-18],ax            ; barva kurzoru
         mov       al,es:[UMenClR1]         ; barva r†mu tmav†
         mov       ah,es:[UMenColT]         ; barva titulku
         mov       ss:[bp-16],ax            ; barva r†mu a titulku
         mov       al,es:[UMenClR2]         ; barva r†mu svàtl†
         mov       ss:[bp-37],al            ; barva r†mu svàtl†
         mov       ax,es:[UMenColH]         ; barva z†hlav°
         mov       ss:[bp-14],ax            ; barva z†hlav°

         mov       cl,ss:[bp-11]            ; vò®ka okna (+ 1 ©†dek na titulek)
         mov       ch,0
         mov       ax,es:[UMenNadN]         ; poáet ©†dkñ z†hlav°
         cmp       word ptr es:[UMenLinN],0 ; jsou nàjakÇ zobrazenÇ ©†dky ?
         je        DispCM12                 ; nejsou zobrazenÇ ©†dky
         dec       cx                       ; rezerva pro oddàlovac° á†ru
         dec       cx                       ; rezerva pro zobrazenÇ ©†dky
DispCM12:cmp       ax,cx                    ; je mnoho ©†dkñ z†hlav° ?
         jbe       DispCM13                 ; poáet ©†dkñ z†hlav° je OK
         mov       ax,cx                    ; omezen° poátu ©†dkñ z†hlav°
DispCM13:mov       ss:[bp-22],ax            ; á°taá ©†dkñ z†hlav°

         mov       word ptr ss:[bp-24],1    ; ukazatel á°sla ©†dku z†hlav°
         mov       ss:[bp-28],ds            ; £schova datovÇho segmentu
         mov       ax,es:[UMenLinN]         ; poáet zobrazenòch ©†dkñ
         sub       ax,es:[UMenLinT]         ; poáet zbylòch ©†dkñ k zobrazen°
         mov       ss:[bp-30],ax            ; á°taá zobrazenòch ©†dkñ
         mov       ax,es:[UMenLinT]         ; poá†teán° zobrazenò ©†dek
         mov       ss:[bp-32],ax            ; ukazatel á°sla zobrazenÇho ©†dku
         mov       ax,es:[UMenLinK]         ; zobrazenò ©†dek s kurzorem
         sub       ax,es:[UMenLinT]         ; offset od poá†teán°ho ©†dku
         inc       ax                       ; p©ednastaven° á°taáe
         mov       ss:[bp-34],ax            ; á°taá zobrazenÇho ©†dku s kurzorem

; ------ p©°prava dek¢dovac° tabulky

         mov       ax,SEG CodeDek           ; segment tabulek
         mov       ss:[bp-40],ax            ; segment tabulky
         mov       al,ds:[CodePagK]         ; k¢d souboru (0=nic, 1=KAM, 2=LAT)
         mov       ah,5                     ; dÇlka pro jeden k¢d
         mul       ah
         or        ax,ax                    ; je k¢d ?
         jz        DispCM14                 ; nen° k¢d
         add       al,ds:[CodePage]         ; + k¢d displeje
         shl       ax,1                     ; * 2
         xchg      ax,bx                    ; BX <- offset tabulky
         mov       ax,ds:[bx+CodePagT-10]   ; adresa tabulky
DispCM14:mov       ss:[bp-42],ax            ; offset adresy tabulky

; ------ dek¢dov†n° horn° linky

         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         push      ss
         pop       es
         cld
         mov       ah,ss:[bp-16]            ; barva r†mu tmav†
         mov       al,"⁄"                   ; "⁄" levò horn° okraj okna menu
         stosw                              ; uloëen° levÇho horn°ho okraje
         mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         mov       ch,0
         mov       cl,ss:[bp-12]            ; vnit©n° ®°©ka okna
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       ah,ss:[bp-37]            ; barva r†mu svàtl†
         mov       al,"ø"                   ; "ø" pravò horn° roh okna menu
         stosw                              ; uloëen° pravÇho horn°ho okraje

; ------ test, zda je ©†dek titulku

         cmp       word ptr ss:[bp-22],0    ; je nàjakò ©†dek titulku ?
         je        DispCM31                 ; nen° ©†dek titulku
         dec       word ptr ss:[bp-22]      ; sn°ëen° á°taáe ©†dkñ

; ------ dek¢dov†n° ©†dku titulku

         mov       es,ss:[bp-6]             ; adresa segmentu menu
         mov       si,es:[UMenNadI]         ; adresa indexu
         mov       si,es:[si]               ; offset ©†dku v souboru
         add       si,es:[UMenAdrF]         ; adresa ©†dku v bufferu
         mov       al,ss:[bp-15]            ; barva titulku
         mov       ah,al
         mov       byte ptr ss:[bp-35],0    ; ukazatel pozice na ©†dku
         call      DispCMT                  ; dek¢dov†n° textu ©†dku do bufferu

; ------ p©enos textu do bufferu ©†dku

         mov       di,sp                    ; DI <- buffer k zobrazen°
         inc       di
         inc       di
         mov       al,ss:[bp-12]            ; vnit©n° ®°©ka okna
         mov       ah,0
         dec       ax
         dec       ax                       ; bez 2 mezer
         cmp       cl,al                    ; je text del®° ?
         jbe       DispCM30                 ; text nen° del®° neë ©†dek
         mov       cl,al                    ; omezen° dÇlky textu
DispCM30:sub       ax,cx                    ; zbytek ©†dku
         shl       ax,1                     ; odsazen° zaá†tku
         add       di,ax                    ; zaá†tek k uloëen° textu
         mov       si,ss:[bp-26]            ; adresa p©echodnÇho bufferu
         cld
         mov       ah,ss:[bp-15]            ; AH <- barva titulku
         mov       al," "
         stosw                              ; uloëen° £vodn° mezery
         call      DispCMK                  ; p©enos s k¢dov†n°m
         stosw                              ; uloëen° z†vàreánÇ mezery

; ------ zobrazen° horn°ho okraje

DispCM31:call      DispCMDs                 ; zobrazen° horn°ho ©†dku

; ------ test, zda se zobraz° ©†dky z†hlav°

         cmp       word ptr ss:[bp-22],0    ; jsou ©†dky z†hlav° ?
         jne       DispCM32                 ; jsou nàjakÇ ©†dky
         jmp       DispCM38                 ; nejsou ©†dky z†hlav°

; ------ vymaz†n° jednoho ©†dku z†hlav°

DispCM32:mov       di,sp
         mov       ah,ss:[bp-16]            ; barva r†mu tmav†
         mov       al,"≥"                   ; "≥" levò okraj
         cld
         stosw
         mov       cl,ss:[bp-12]            ; vnit©n° ®°©ka okna
         mov       ch,0
         mov       al," "
         mov       ah,ss:[bp-14]            ; barva z†hlav°
         rep       stosw                    ; vymaz†n° ©†dku
         mov       ah,ss:[bp-37]            ; barva r†mu svàtl†
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw

; ------ dek¢dov†n° textu v jednom ©†dku z†hlav° -> CX znakñ

         mov       si,ss:[bp-24]            ; á°slo ©†dku k dek¢dov†n°
         shl       si,1                     ; offset v tabulce indexñ
         mov       es,ss:[bp-6]             ; adresa segmentu menu
         add       si,es:[UMenNadI]         ; adresa indexu
         mov       si,es:[si]               ; offset ©†dku v souboru
         add       si,es:[UMenAdrF]         ; adresa ©†dku v bufferu
         mov       ax,ss:[bp-14]            ; barva z†hlav°
         mov       byte ptr ss:[bp-35],0    ; ukazatel pozice na ©†dku
         call      DispCMT                  ; dek¢dov†n° textu ©†dku do bufferu

; ------ p©enos textu do bufferu ©†dku

         mov       di,sp                    ; buffer ©†dku k zobrazen°
         inc       di
         inc       di
         mov       al,ss:[bp-12]            ; vnit©n° ®°©ka okna
         mov       ah,0
         cmp       al,cl                    ; je text del®° ?
         jae       DispCM34                 ; dÇlka textu vyhovuje
         mov       cl,al                    ; omezen° dÇlky textu
DispCM34:sub       ax,cx                    ; zbytek na okraje
         and       al,not bit0              ; levò okraj
         add       di,ax                    ; adresa k uloëen° textu
         mov       si,ss:[bp-26]            ; adresa p©echodnÇho bufferu
         call      DispCMK                  ; p©enos s k¢dov†n°m

; ------ zobrazen° jednoho ©†dku z†hlav°

         call      DispCMDs                 ; zobrazen° ©†dku z†hlav°
         jz        DispCM38                 ; nen° volnò dal®° ©†dek

; ------ p©°prava pro dal®° ©†dek z†hlav°

         inc       word ptr ss:[bp-24]      ; ukazatel á°sla ©†dku z†hlav°
         dec       word ptr ss:[bp-22]      ; á°taá ©†dkñ z†hlav°
         jnz       DispCM32                 ; obsluha dal®°ho ©†dku

; ------ zobrazen° oddàlovac° linky

         cmp       word ptr ss:[bp-30],0    ; jsou nàjakÇ ©†dky ?
         je        DispCM38                 ; nejsou ë†dnÇ ©†dky k zobrazen°
         cld
         mov       di,sp                    ; DI <- buffer ©†dku k zobrazen°
         mov       ah,ss:[bp-16]            ; barva r†mu tmav†
         mov       al,"√"                   ; "√" levò okraj
         stosw
         mov       cl,ss:[bp-12]            ; vnit©n° ®°©ka okna
         mov       ch,0
         mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         rep       stosw                    ; vymaz†n° ©†dku
         mov       al,"¥"                   ; "¥" pravò okraj
         mov       ah,ss:[bp-37]            ; barva r†mu svàtl†
         stosw
         call      DispCMDs                 ; zobrazen° ©†dku oddàlovac° linky

; ------ test, zda se m† nàco zobrazit

DispCM38:cmp       byte ptr ss:[bp-11],0    ; zbyly nàjakÇ ©†dky ?
         jne       DispCMn4                 ; jsou dal®° ©†dky
         jmp       DispCMn9                 ; nezbyly ë†dnÇ ©†dky

; ------ vymaz†n° jednoho ©†dku voleb

DispCMn4:mov       di,sp
         mov       ah,ss:[bp-16]            ; barva r†mu tmav†
         mov       al,"≥"                   ; "≥" levò okraj
         cld
         stosw
         mov       cl,ss:[bp-12]            ; vnit©n° ®°©ka okna
         mov       ch,0
         mov       al," "
         mov       ah,ss:[bp-20]            ; bàën† barva textu
         rep       stosw                    ; vymaz†n° ©†dku
         mov       ah,ss:[bp-37]            ; barva r†mu svàtl†
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw

; ------ test, zda je dal®° ©†dek k zobrazen°

         cmp       word ptr ss:[bp-30],0    ; jsou nàjakÇ ©†dky ?
         jne       DispCM40                 ; jsou nàjakÇ ©†dky
         jmp       DispCMn8                 ; nen° dal®° ©†dek
DispCM40:dec       word ptr ss:[bp-30]      ; sn°ëen° á°taáe ©†dkñ

; ------ p©°prava barvy textu ©†dku

         mov       ax,ss:[bp-18]            ; barva kurzoru
         dec       word ptr ss:[bp-34]      ; á°taá kurzoru
         jz        DispCM41                 ; je to kurzor
         mov       ax,ss:[bp-20]            ; bàën† barva

; ------ uloëen° £vodn° mezery

DispCM41:mov       di,sp                    ; DI <- buffer ©†dku
         inc       di
         inc       di                       ; p©eskoáen° levÇho okraje
         push      ax
         mov       ah,al                    ; bàën† barva
         mov       al," "
         stosw                              ; £vodn° mezera
         pop       ax

; ------ stanoven° dÇlky textu horkÇ kl†vesy

         mov       dl,ss:[bp-12]            ; vnit©n° ®°©ka okna
         dec       dx                       ; bez £vodn° mezery
         mov       es,ss:[bp-6]             ; adresa segmentu menu
         mov       si,ss:[bp-32]            ; á°slo ©†dku k dek¢dov†n°
         add       si,es:[UMenParI]         ; adresa v tabulce parametrñ
         mov       cl,es:[si]               ; dÇlka textu horkÇ kl†vesy
         mov       ss:[bp-36],cl            ; £schova parametrñ ©†dku
         and       cx,bit0+bit1+bit2+bit3   ; dÇlka textu horkÇ kl†vesy

; ------ adresa textu ©†dku

         mov       si,ss:[bp-32]            ; á°slo ©†dku k dek¢dov†n°
         inc       word ptr ss:[bp-32]      ; zvò®en° ukazatele á°sla ©†dku
         shl       si,1                     ; offset v tabulce indexñ
         add       si,es:[UMenLinI]         ; adresa indexu
         mov       si,es:[si]               ; offset ©†dku v souboru
         add       si,es:[UMenAdrF]         ; adresa ©†dku v bufferu

; ------ dek¢dov†n° textu horkÇ kl†vesy

         mov       ss:[bp-35],cl            ; poá†teán° pozice textu
         jcxz      DispCM48                 ; nen° hork† kl†vesa
         sub       dl,cl                    ; sn°ëen° dÇlky zbytku ©†dku
         push      ax
DispCM42:mov       al,es:[si]               ; znak kl†vesy
         inc       si
         mov       ss:[di],ax               ; uloëen° znaku horkÇ kl†vesy
         inc       di
         inc       di
         loop      DispCM42                 ; dal®° znak
         pop       ax

; ------ dek¢dov†n° textu ©†dku voleb -> CX znakñ

DispCM48:push      dx                       ; DL=zbylÇ znaky
         push      di                       ; ukl†dac° adresa do bufferu
         call      DispCMT                  ; dek¢dov†n° textu ©†dku do bufferu
         pop       di
         pop       dx
         cmp       dl,cl                    ; je text del®° neë zbytek ©†dku ?
         jae       DispCMn6                 ; nen° del®°
         mov       cl,dl                    ; omezen° dÇlky textu
DispCMn6:sub       dl,cl                    ; zbytek ©†dku

; ------ p©enos textu do bufferu ©†dku

         mov       si,ss:[bp-26]            ; adresa p©echodnÇho bufferu
         call      DispCMK                  ; p©enos s k¢dov†n°m

; ------ vymaz†n° zbytku ©†dku

         mov       cl,dl                    ; CL <- zbytek ©†dku
         mov       al," "
         rep       stosw                    ; vymaz†n° zbytku ©†dku mezerami

; ------ p©°znak podmenu

         test      byte ptr ss:[bp-36],bit6 ; je navazuj°c° podmenu ?
         jz        DispCMn8                 ; nen° podmenu
         mov       byte ptr es:[di-2],16    ; p©°znak podmenu

; ------ zobrazen° jednoho ©†dku

DispCMn8:call      DispCMDs                 ; zobrazen° ©†dku voleb
         jz        DispCMn9                 ; jsou jië v®echny ©†dky
         jmp       DispCMn4                 ; zobrazen° dal®°ho ©†dku voleb

; ------ zobrazen° spodn° linky

DispCMn9:mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       ah,ss:[bp-16]            ; barva r†mu tmav†
         mov       al,"¿"                   ; "¿" levò doln° okraj okna menu
         cld
         stosw                              ; uloëen° levÇho horn°ho okraje
         mov       ah,ss:[bp-37]            ; barva r†mu svàtl†
         mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         mov       ch,0
         mov       cl,ss:[bp-12]            ; vnit©n° ®°©ka okna
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       al,"Ÿ"                   ; "Ÿ" pravò doln° roh okna menu
         stosw                              ; uloëen° pravÇho horn°ho okraje
         call      DispCMDs                 ; zobrazen° spodn° linky voleb

; ------ p©°prava k zobrazen° n†povàdy

         mov       si,ss:[bp-2]             ; adresa definice menu
         cmp       si,ds:[AktMenu]          ; je to aktivn° menu ?
         jne       DispCMA9                 ; nen° to aktivn° menu
         test      byte ptr ds:[InfoPar],bit0 ; zobrazen informaán° ©†dek ?
         jnz       DispCMA9                 ; je informaán° ©†dek

; ------ dek¢dov†n° textu n†povàdy

         mov       es,ss:[bp-6]             ; adresa segmentu menu
         mov       ah,es:[UMenColP]         ; bàën† barva n†povàdy
         xor       cx,cx                    ; dÇlka textu
         cmp       word ptr es:[UMenVolN],0 ; jsou nàjakÇ volby ?
         je        DispCMA6                 ; nejsou ë†dnÇ volby
         mov       si,es:[UMenVolK]         ; volba s kurzorem
         shl       si,1                     ; offset v tabulce indexñ
         add       si,es:[UMenHlpI]         ; adresa v tabulce indexñ
         mov       si,es:[si]               ; offset indexu
         or        si,si                    ; je n†povàda ?
         jz        DispCMA6                 ; nen° n†povàda
         add       si,es:[UMenAdrF]         ; adresa textu n†povàdy
         mov       al,ah
         mov       ah,es:[UMenClP2]         ; vysv°cen† barva n†povàdy
         mov       byte ptr ss:[bp-35],0    ; ukazatel pozice na ©†dku
         call      DispCMT                  ; dek¢dov†n° textu n†povàdy

         mov       si,ss:[bp-26]            ; adresa bufferu
         mov       di,si
         push      ss
         pop       es                       ; ES <- segment bufferu
         push      cx
         call      DispCMK                  ; p©ek¢dov†n° k¢du souboru
         pop       cx

; ------ vymaz†n° zbytku ©†dku (CL=dÇlka textu)

DispCMA6:mov       di,ss:[bp-26]            ; adresa p©echodnÇho bufferu
         mov       al,255                   ; dÇlka bufferu
         sub       al,cl                    ; zbytek do konce bufferu
         add       di,cx
         add       di,cx                    ; adresa konce textu
         mov       cl,al
         mov       al," "                   ; mazac° znak mezery
         push      ss
         pop       es
         cld
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ zobrazen° ©†dku n†povàdy

         mov       dl,0                     ; poá†teán° pozice
         mov       dh,ds:[MaxRow]           ; posledn° ©†dek na displeji
         mov       cl,ds:[Pozic]            ; dÇlka ©†dku (pozic)
         mov       si,ss:[bp-26]            ; adresa p©echodnÇho bufferu
         xor       ax,ax                    ; z†kladn° hladina
         call      far ptr DispMStr         ; zobrazen° n†povàdy

; ------ n†vrat registrñ

DispCMA9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispCMnu ENDP

; -----------------------------------------------------------------------------
;        p©enos textu s k¢dov†n°m
; -----------------------------------------------------------------------------

DispCMK  PROC      NEAR

         push      ax
         push      bx
         push      ds

         cld
         jcxz      DispCMK8                 ; nen° ë†dnò znak
         push      ss
         pop       ds                       ; DS <- segment textu
DispCMK2:lodsw                              ; naáten° znaku
         cmp       al,250                   ; je pevn† mezera ?
         jne       DispCMK3                 ; nen° pevn† mezera
         mov       al," "                   ; n†hrada bàënou mezerou
DispCMK3:cmp       al,128                   ; bude konverze ?
         jb        DispCMK6                 ; nebude konverze
         lds       bx,ss:[bp-42]            ; adresa tabulky
         or        bx,bx                    ; bude k¢dov†n° ?
         jz        DispCMK4                 ; nebude k¢dov†n°
         sub       al,128                   ; korekce znaku
         xlat                               ; p©ek¢dov†n° znaku
DispCMK4:push      ss
         pop       ds                       ; DS <- segment textu
DispCMK6:stosw                              ; uloëen° znaku
         loop      DispCMK2                 ; dal®° znak

DispCMK8:pop       ds
         pop       bx
         pop       ax
         ret

DispCMK  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho ©†dku menu (ZY jsou jië v®echny ©†dky)
; -----------------------------------------------------------------------------

DispCMDs PROC      NEAR

         mov       dx,ss:[bp-8]             ; ukazatel ©†dku a pozice
         mov       ax,ss:[bp-10]            ; hladina k zobrazen°
         mov       cl,ss:[bp-12]            ; vnit©n° ®°©ka okna
         inc       cx
         inc       cx
         mov       si,sp
         inc       si
         inc       si                       ; p©eskoáen° n†vratovÇ adresy
         call      far ptr DispMStr         ; zobrazen° ©†dku
         inc       byte ptr ss:[bp-7]       ; zvò®en° ukazatele ©†dku
         dec       byte ptr ss:[bp-11]      ; sn°ëen° á°taáe ©†dkñ
         cld
         ret

DispCMDs ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° textu SI do bufferu (barva AX -> CX=dÇlka textu, AH=barva)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice menu
;                   SS:[BP-4] (2) á°slo segmentu menu
;                   SS:[BP-6] (2) adresa segmentu menu
;                   SS:[BP-7] (1) ukazatel á°sla ©†dku
;                   SS:[BP-8] (1) ukazatel á°sla pozice
;                   SS:[BP-10] (2) hladina k zobrazen°
;                   SS:[BP-11] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-12] (1) vnit©n° ®°©ka okna
;
;                   SS:[BP-13] (1) zvòraznàn† barva z†hlav°
;                   SS:[BP-14] (1) barva z†hlav°
;                   SS:[BP-15] (1) barva titulku
;                   SS:[BP-16] (1) barva r†mu
;                   SS:[BP-17] (1) zvòraznàn† barva kurzoru
;                   SS:[BP-18] (1) barva kurzoru
;                   SS:[BP-19] (1) zvòraznàn† bàën† barva
;                   SS:[BP-20] (1) bàën† barva
;
;                   SS:[BP-22] (2) á°taá ©†dkñ z†hlav°
;                   SS:[BP-24] (2) ukazatel á°sla ©†dku z†hlav°
;                   SS:[BP-26] (2) adresa p©echodnÇho dek¢d. bufferu (255 B)
;                   SS:[BP-28] (2) datovò segment DS
;                   SS:[BP-30] (2) á°taá zobrazenòch ©†dkñ
;                   SS:[BP-32] (2) ukazatel á°sla zobrazenÇho ©†dku
;                   SS:[BP-34] (2) á°taá zobrazenÇho ©†dku s kurzorem
;                   SS:[BP-35] (1) ukazatel pozice na ©†dku menu
;                   SS:[BP-36] (1) parametry dek¢dovanÇho ©†dku
;                                    bit 0 aë bit 3: dÇlka textu horkÇ kl†vesy
;                                    bit 6: 1=je navazuj°c° menu
;                                    bit 7: 1=©†dek volby (kurzor)
;                   SS:[BP-37] (1) barva r†mu - svàtl†
;                   SS:[BP-38] (1)
;                   SS:[BP-40] (2) segment dek¢dovac° tabulky fontñ
;                   SS:[BP-42] (2) offset dek¢dovac° tabulky fontñ
; -----------------------------------------------------------------------------

DispCMT  PROC      NEAR

         push      ss
         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
         mov       di,ss:[bp-26]            ; adresa bufferu
         mov       dx,ss:[bp-6]             ; segment bufferu s textem
         mov       ch,ss:[bp-35]            ; ukazatel pozice na ©†dku
         mov       cl,255                   ; maxim†ln° poáet znakñ k uloëen°
         push      cs
         call      near ptr DekPLine        ; dek¢dov†n° textovÇho ©†dku
         sub       di,ss:[bp-26]            ; dÇlka textu * 2
         mov       cx,di                    ; CX <- dÇlka textu * 2
         shr       cx,1                     ; dÇlka textu
         mov       ah,al                    ; bàën† barva
         ret

DispCMT  ENDP

; -----------------------------------------------------------------------------
;        normalizace uëivatelskÇho menu DS:SI
; -----------------------------------------------------------------------------

NormCMnu PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      es

; ------ adresa bufferu menu

         mov       ax,ds:[si+MnuCSegm]      ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu

; ------ poáet zobrazenòch ©†dkñ v oknà

         mov       cl,ds:[si+MnuVys]        ; vò®ka okna menu
         mov       ch,0
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ax,es:[UMenNadN]         ; poáet ©†dkñ z†hlav°
         cmp       ax,1                     ; je z†hlav° ?
         jbe       NormCMn1                 ; nen° z†hlav°
         sub       cx,ax                    ; odeáten° z†hlav°
         ja        NormCMn1                 ; je to OK
         mov       cx,1                     ; zobraz° se 1 ©†dek

; ------ nalezen° minim†ln°ho prvn°ho ©†dku (podle ©†dku nadpisu)

NormCMn1:mov       ax,es:[UMenLinK]         ; ©†dek s kurzorem
         mov       si,ax                    ; SI <- ©†dek s kurzorem
         add       si,es:[UMenParI]         ; adresa v tabulce parametrñ
         or        ax,ax                    ; je kurzor na prvn°m ©†dku ?
         jz        NormCMn3                 ; kurzor je jië na prvn°m ©†dku
         cmp       cl,3                     ; zobraz° se alespo§ 3 ©†dky ?
         jb        NormCMn2                 ; je m†lo ©†dkñ - nen° rezerva
         dec       si
         dec       ax                       ; 1 ©†dek je rezerva
         test      byte ptr es:[si],bit7    ; je to ©†dek s volbou ?
         jnz       NormCMn3                 ; je to ©†dek s volbou
         or        ax,ax
         jz        NormCMn3
NormCMn2:dec       si                       ; sn°ëen° ukazatele v tabulce param.
         test      byte ptr es:[si],bit7    ; je p©°®t° ©†dek jië volba ?
         jnz       NormCMn3                 ; p©°®t° ©†dek je jië volba
         dec       ax                       ; sn°ëen° ukazatele á°sla ©†dku
         jnz       NormCMn2                 ; dal®° ©†dek

; ------ omezen° poá†teán°ho ©†dku zdola

NormCMn3:mov       bx,es:[UMenLinT]         ; poá†teán° zobrazenò ©†dek
         cmp       ax,bx                    ; je kurzor pod poá†teán°m ©†dkem ?
         ja        NormCMn4                 ; nen° pod poá†teán°m ©†dkem
         xchg      ax,bx                    ; omezen° poá†teán°ho ©†dku

; ------ omezen° poá†teán°ho ©†dku shora

NormCMn4:mov       ax,es:[UMenLinK]         ; ©†dek s kurzorem
         cmp       cl,3                     ; je zobrazeno mÇnà neë 3 ©†dky ?
         jb        NormCMn5                 ; je zobrazeno mÇnà neë 3 ©†dky
         inc       ax                       ; 1 ©†dek je rezerva nad kurzorem
NormCMn5:inc       ax                       ; korekce na posledn° ©†dek
         sub       ax,cx                    ; maxim†ln° á°slo poá†teán°ho ©†dku
         ja        NormCMn6                 ; á°slo ©†dku je OK
         xor       ax,ax                    ; omezen° á°sla ©†dku na 0
NormCMn6:cmp       bx,ax                    ; je kurzor za koncem okna ?
         ja        NormCMn7                 ; kurzor nen° za koncem okna
         xchg      ax,bx                    ; omezen° poá†tku shora

; ------ omezen° maxim†ln°ho poá†teán°ho ©†dku

NormCMn7:mov       ax,es:[UMenLinN]         ; celkovò poáet ©†dkñ
         sub       ax,cx                    ; maxim†ln° zobrazitelnò ©†dek
         jnc       NormCMn8
         xor       ax,ax                    ; omezen° p©i malÇm poátu ©†dkñ
NormCMn8:cmp       bx,ax
         jb        NormCMn9
         xchg      ax,bx                    ; omezen° maxim†ln°ho ©†dku
NormCMn9:mov       es:[UMenLinT],bx         ; uloëen° novÇho poá†teán°ho ©†dku

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

NormCMnu ENDP

; *****************************************************************************
;                                   EditCMnu
;                         editace uëivatelskÇho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl†vesa
;        DS=datovò segment
; VùSTUP: BX=0 kl†vesa obslouëena
;         CY=nen° provedena volba, obsluha pokraáuje
;         NC=byla provedena volba
; *****************************************************************************
;˛
EditCMnu PROC      FAR

; ------ p©echodnÇ vypnut° menu

         call      far ptr MCtrlO           ; p©echodnÇ vypnut° menu
         jnc       EditCMn0                 ; nebyla funkce Ctrl-O
         ret

; ------ £schova registrñ

EditCMn0:push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ adresa definice menu

         mov       ax,ds:[si+MnuCSegm]      ; segment s definic° menu
         call      far ptr GetDat           ; adresa segmentu

; ------ p©°prava registrñ

         mov       ax,es:[UMenVolK]         ; ©†dek voleb s kurzorem
         mov       dx,es:[UMenLinK]         ; zobrazenò ©†dek s kurzorem
         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
         mov       ch,0
         dec       cx
         dec       cx                       ; bez okrajñ
         cmp       word ptr es:[UMenNadN],1 ; je z†hlav° ?
         jbe       EditCM02                 ; nen° z†hlav°
         sub       cx,es:[UMenNadN]         ; odeáten° ©†dkñ z†hlav°
         ja        EditCM02
         mov       cx,1                     ; zobraz° se 1 ©†dek

EditCM02:call      far ptr JumpBX

         dw        5000h,EditCM11           ; dolñ
         dw        4800h,EditCM13           ; nahoru

         dw        4700h,EditCM12           ; Home
         dw        4f00h,EditCM14           ; End
         dw        7700h,EditCM12           ; Ctrl-Home
         dw        7500h,EditCM14           ; Ctrl-End

         dw        4900h,EditCMn2           ; PageUp
         dw        5100h,EditCMn3           ; PageDown
         dw        8400h,EditCM12           ; Ctrl-PageUp
         dw        7600h,EditCM14           ; Ctrl-PageDown

         dw        1c0dh,EdiCM109           ; ENTER proveden° volby

         dw        MousXKod+MousXLR,EditCM03 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,EditCM04 ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXLH,EditCM04 ; drëen° levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,EditCM04 ; posun my®i

         dw        0,EditCM10

; ------ uvolnàn° levÇho tlaá°tka my®i

EditCM03:call      far ptr MouseMnu         ; test, zda je my® v oknà
         jnc       EdiCM109                 ; je v oknà - jako ENTER

; ------ posun my®i

EditCM04:test      byte ptr ds:[MouseKey],bit1 ; je pouze levÇ tlaá°tko ?
         jnz       EdiCM104                 ; nen° jen levÇ tlaá°tko
         call      UserMPol                 ; poloëka menu z my®i
         jmp       EditCMn8

; ------ nalezen° horkÇ kl†vesy v menu

EditCM10:call      EditCMK                  ; obsluha horkÇ kl†vesy menu
         jnc       EdiCM108                 ; kl†vesa nalezena
EdiCM104:jmp       EditCM88                 ; kl†vesa neobslouëena

EdiCM108:mov       es:[UMenVolK],ax         ; ©†dek voleb s kurzorem
         mov       es:[UMenLinK],dx         ; zobrazenò ©†dek s kurzorem

; ------ ENTER - proveden° volby

EdiCM109:xor       bx,bx                    ; p©°znak proveden° volby
         jmp       EditCMn9

; ------ kurzor dolñ

EditCM11:call      IncCUMnu                 ; posun kurzoru dolñ
         jnc       EditCM18                 ; byl dal®° ©†dek
         cmp       cx,es:[UMenLinN]         ; zobraz° se v®echny ©†dky ?
         jb        EditCM18                 ; nezobraz° se v®echny ©†dky

; ------ prvn° ©†dek

EditCM12:call      DecCUMnu                 ; posun kurzoru nahoru
         jnc       EditCM12                 ; dal®° ©†dek
         jmp       short EditCM18

; ------ kurzor nahoru

EditCM13:call      DecCUMnu                 ; posun kurzoru nahoru
         jnc       EditCM18                 ; byl dal®° ©†dek
         cmp       cx,es:[UMenLinN]         ; zobraz° se v®echny ©†dky ?
         jb        EditCM18                 ; nezobraz° se v®echny ©†dky

; ------ posledn° ©†dek

EditCM14:call      IncCUMnu                 ; posun kurzoru dolñ
         jnc       EditCM14                 ; dal®° ©†dek
EditCM18:jmp       short EditCMn8

; ------ str†nka nahoru

EditCMn2:dec       cx                       ; zobrazenò poáet ©†dkñ - 1
         cmp       cx,es:[UMenLinT]         ; lze se posunout o celÇ okno ?
         jb        EditCM21
         mov       cx,es:[UMenLinT]         ; omezen° posunu na zbytek ©†dkñ
EditCM21:jcxz      EditCM12                 ; je jië poá†tek okna
         inc       dx
         cmp       dx,es:[UMenLinN]         ; je to posledn° zobrazenò ©†dek ?
         dec       dx
         jb        EditCM22                 ; nen° to posledn° zobrazenò ©†dek
         call      DecCUMnu                 ; posun o jeden ©†dek nav°c
EditCM22:mov       bx,dx                    ; zobrazenò ©†dek s kurzorem
         sub       bx,es:[UMenLinT]         ; offset od poá†teán°ho ©†dku
         mov       di,dx                    ; DI <- zobrazenò ©†dek s kurzorem
         sub       di,cx                    ; DI <- novò zobrazenò ©†dek
         jnc       EditCM24
         xor       di,di                    ; poëadovanò poá†tek
EditCM24:call      DecCUMnu                 ; posun kurzoru nahoru
         jc        EditCM34
         cmp       dx,di                    ; je jië poëadovanò ©†dek ?
         ja        EditCM24                 ; je®tà nen° poëadovanò ©†dek
         jmp       short EditCM34

; ------ str†nka dolñ

EditCMn3:mov       bx,es:[UMenLinN]         ; poáet zobrazenòch ©†dkñ
         sub       bx,cx                    ; maxim†ln° poá†tek
         jc        EditCM14                 ; je m†lo ©†dkñ
         sub       bx,es:[UMenLinT]         ; poáet ©†dkñ k posunu
         jbe       EditCM14                 ; je jië konec menu
         dec       cx                       ; vò®ka okna - 1
         cmp       cx,bx                    ; zbòv† dost ©†dkñ ?
         jbe       EditCM31                 ; zbòv† v°ce ©†dkñ neë je t©eba
         mov       cx,bx                    ; omezen° posunu
EditCM31:jcxz      EditCM31                 ; je jië konec menu
         or        dx,dx                    ; je to prvn° zobrazenò ©†dek ?
         jnz       EditCM32                 ; nen° to prvn° zobrazenò ©†dek
         call      IncCUMnu                 ; posun o jeden ©†dek nav°c
EditCM32:mov       bx,dx                    ; BX <- ©†dek s kurzorem
         sub       bx,es:[UMenLinT]         ; offset od poá†teán°ho ©†dku
         mov       di,dx                    ; DI <- ©†dek s kurzorem
         add       di,cx                    ; poëadovanò ©†dek
EditCM33:call      IncCUMnu                 ; posun kurzoru dolñ
         jc        EditCM34
         cmp       dx,di                    ; je jië poëadovanò ©†dek ?
         jb        EditCM33                 ; nen° je®tà poëadovanò ©†dek

EditCM34:mov       es:[UMenLinT],dx         ; ©†dek s kurzorem
         sub       es:[UMenLinT],bx         ; poá†teán° ©†dek
         jnc       EditCMn8                 ; nen° p©eteáen°
         mov       word ptr es:[UMenLinT],0 ; oprava p©i p©eteáen°

; ------ operace OK, nen° provedena volba

EditCMn8:mov       es:[UMenVolK],ax         ; ©†dek voleb s kurzorem
         mov       es:[UMenLinK],dx         ; zobrazenò ©†dek s kurzorem
         xor       bx,bx                    ; p©°znak obsluhy kl†vesy
EditCM88:stc                                ; p©°znak, ëe nen° provedena volba

; ------ n†vrat registrñ

EditCMn9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditCMnu ENDP

; -----------------------------------------------------------------------------
;        poloëka podle kurzoru my®i -> DX,AX
; -----------------------------------------------------------------------------

UserMPol PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx

; ------ kontrola kurzoru

         call      UserMPD                  ; vzd†lenost od kurzoru my®i
UserMPl2:mov       bl,cl                    ; BL <- £schova vzd†lenosti
         je        UserMPl8                 ; kurzor je OK
         jb        UserMPl4                 ; mus° bòt posun dolñ

; ------ posun kurzoru nahoru

         call      DecCUMnu                 ; posun kurzoru nahoru
         jc        UserMPl8                 ; nen° dal®° ©†dek

; ------ nov† kontrola posunu

         call      UserMPD                  ; nov† vzd†lenost kurzoru
         jae       UserMPl2                 ; bude dal®° posun

; ------ porovn†n° krat®° vzd†lenosti

         neg       cl                       ; oprava vzd†lenosti
         cmp       bl,cl                    ; kter† je krat®° ?
         ja        UserMPl8                 ; teÉ je lep®° vzd†lenost
         call      IncCUMnu                 ; n†vrat kurzoru
         jmp       short UserMPl8

; ------ posun kurzoru dolñ

UserMPl4:call      IncCUMnu                 ; posun kurzoru dolñ
         jc        UserMPl8                 ; nen° dal®° ©†dek

; ------ nov† kontrola posunu

         call      UserMPD                  ; nov† vzd†lenost kurzoru
         jbe       UserMPl2                 ; bude dal®° posun

; ------ porovn†n° krat®° vzd†lenosti

         neg       bl                       ; oprava vzd†lenosti
         cmp       bl,cl                    ; kter† je krat®° ?
         jae       UserMPl8                 ; teÉ je lep®° vzd†lenost
         call      DecCUMnu                 ; n†vrat kurzoru

; ------ n†vrat registrñ

UserMPl8:pop       cx
         pop       bx
         ret

UserMPol ENDP

; ------ vzd†lenost kurzoru menu od my®i -> CL

UserMPD: mov       cx,dx                    ; zobrazenò ©†dek s kurzorem menu
         sub       cx,es:[UMenLinT]         ; vzd†lenost od poá†tku
         inc       cx                       ; + horn° okraj
         cmp       word ptr es:[UMenNadN],1 ; je z†hlav° ?
         jbe       UserMPD2                 ; nen° z†hlav°
         add       cx,es:[UMenNadN]         ; + ©†dky z†hlav° a titulku
UserMPD2:add       cl,ds:[si+MnuRad]        ; ©†dek na obrazovce
         sub       cl,byte ptr ds:[MousePoz+1] ; vzd†lenost od kurzoru my®i
         ret

; -----------------------------------------------------------------------------
;        zvò®en° ukazatele kurzoru AX/DX, segment ES (CY=nen° dal®° ©†dek)
; -----------------------------------------------------------------------------

IncCUMnu PROC      NEAR

         push      si

         inc       ax                       ; zvò®en° á°sla ©†dku
         cmp       ax,es:[UMenVolN]         ; je dal®° ©†dek ?
         dec       ax
         cmc
         jc        IncCUMn9                 ; nen° dal®° ©†dek volby
         inc       ax

         mov       si,dx                    ; zobrazenò ©†dek s kurzorem
         add       si,es:[UMenParI]         ; adresa v tabulce parametrñ
IncCUMn2:inc       dx                       ; zvò®en° ukazatele kurzoru
         inc       si                       ; zvò®en° ukazatele v tabulce
         test      byte ptr es:[si],bit7    ; je platnò ©†dek ?
         jz        IncCUMn2                 ; nalezen° platnÇho ©†dku
                                          ;* zde je NC !
IncCUMn9:pop       si
         ret

IncCUMnu ENDP

; -----------------------------------------------------------------------------
;        sn°ëen° ukazatele kurzoru AX/DX, segment ES (CY=nen° dal®° ©†dek)
; -----------------------------------------------------------------------------

DecCUMnu PROC      NEAR

         push      si

         or        ax,ax                    ; je jië prvn° volba ?
         stc
         jz        DecCUMn9                 ; nen° dal®° ©†dek volby

         dec       ax

         mov       si,dx                    ; zobrazenò ©†dek s kurzorem
         add       si,es:[UMenParI]         ; adresa v tabulce parametrñ
DecCUMn2:dec       dx                       ; sn°ëen° ukazatele kurzoru
         dec       si                       ; sn°ëen° ukazatele v tabulce
         test      byte ptr es:[si],bit7    ; je platnò ©†dek ?
         jz        DecCUMn2                 ; nalezen° platnÇho ©†dku
                                          ;* zde je NC !
DecCUMn9:pop       si
         ret

DecCUMnu ENDP

; -----------------------------------------------------------------------------
;        obsluha horkÇ kl†vesy uëivatelskÇho menu
; -----------------------------------------------------------------------------
; VSTUP: BX=zadan† kl†vesa
;        ES=segment definice menu
; VùSTUP: CY=kl†vesa v menu nenalezena (AX a BX nedefinov†no)
;         AX=á°slo volby s nalezenou kl†vesou (p©i CY nedefinov†no)
;         DX=á°slo zobrazenÇho ©†dku s nalezenou kl†vesou (p©i CY nedefinov†no)
; lok†ln° promànnÇ: SS:[BP-9] (9) zkr†cenò text kl†vesy
;                   SS:[BP-10] (1) dÇlka zkr†cenÇho textu kl†vesy
;                   SS:[BP-29] (19) plnò text kl†vesy
;                   SS:[BP-30] (1) dÇlka plnÇho textu kl†vesy
; -----------------------------------------------------------------------------
;˛
EditCMK  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
         sub       sp,30                    ; buffer k dek¢dov†n° kl†vesy

; ------ p©°prava registrñ

         push      es
         pop       ds                       ; DS <- segment bufferu menu
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld

; ------ dek¢dov†n° kl†vesy ASCII jako 1 znak

         cmp       word ptr ds:[UMenVolN],0 ; jsou nàjakÇ volby ?
         je        EditCMK0                 ; nejsou ë†dnÇ volby
         xchg      ax,bx                    ; AX <- k¢d kl†vesy
         cmp       al,0
         je        EditCMK2                 ; je ©°dic° kl†vesa
         cmp       al," "
         ja        EditCMK1                 ; kl†vesa je platn† OK
EditCMK0:jmp       EditCMK8                 ; neplatn† kl†vesa
EditCMK1:call      far ptr UpCase           ; konverze na velkÇ p°smeno
         mov       byte ptr ss:[bp-30],1    ; dÇlka plnÇho textu kl†vesy
         mov       ss:[bp-29],al            ; plnò text kl†vesy
         mov       byte ptr ss:[bp-10],1    ; dÇlka zkr†cenÇho textu kl†vesy
         mov       ss:[bp-9],al             ; zkr†cenò text kl†vesy
         jmp       EditCMK5                 ; nalezen° kl†vesy

; ------ rozli®en° funkán° kl†vesy

EditCMK2:mov       al,ah                    ; AL <- k¢d kl†vesy

         sub       al,3ah                   ; F1
         jbe       EditCMK0                 ; nen° funkán° kl†vesa
         mov       ah,0                     ; nen° prefix
         cmp       al,44h-3ah
         jbe       EditCMK3                 ; je z†kladn° funkán° kl†vesa

         sub       al,53h-3ah
         jbe       EditCMK0                 ; nen° funkán° kl†vesa
         mov       ah,"*"                   ; kl†vesy se SHIFT
         cmp       al,5dh-53h
         jbe       EditCMK3                 ; je kl†vesa se SHIFT

         sub       al,5dh-53h
         mov       ah,"^"                   ; kl†vesa s Ctrl-
         cmp       al,67h-5dh
         jbe       EditCMK3                 ; je kl†vesa s Ctrl-

         sub       al,67h-5dh
         mov       ah,"/"                   ; kl†vesa s Alt-
         cmp       al,71h-67h
         jbe       EditCMK3

         sub       al,85h-67h
         jb        EditCMK0
         cmp       al,8ch-85h
         ja        EditCMK0                 ; nen° funkán° kl†vesa
         add       al,11

         mov       ah,0
         cmp       al,12
         jbe       EditCMK3
         sub       al,2
         mov       ah,"*"
         cmp       al,12
         jbe       EditCMK3
         sub       al,2
         mov       ah,"^"
         cmp       al,12
         jbe       EditCMK3
         mov       ah,"/"
         sub       al,2

; ------ dek¢dov†n° zkr†cenÇho textu funkán° kl†vesy

EditCMK3:lea       di,ss:[bp-9]             ; buffer zkr†cenÇho textu
         xor       cx,cx                    ; á°taá dÇlky textu
         push      ax
         xchg      al,ah                    ; AL <- prefix
         cmp       al,0
         je        EdiCMK32                 ; nen° prefix
         stosb                              ; uloëen° znaku prefixu
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
EdiCMK32:mov       al,"F"
         stosb                              ; oznaáen° funkán° kl†vesy
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
         mov       al,ah
         aam                                ; dekadick† korekce
         add       ax,"00"                  ; ASCII znaky
         xchg      al,ah                    ; AL <- des°tky
         cmp       al,"0"
         je        EdiCMK34
         stosb                              ; uloëen° á°slice des°tek
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
EdiCMK34:mov       al,ah                    ; á°slice jednotek
         stosb
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
         mov       ss:[bp-10],cl            ; dÇlka zkr†cenÇho textu kl†vesy
         pop       ax

; ------ p©°prava adresy textu prefixu

         push      ax
         mov       si,offset TabUMnF+1
         mov       al,ah
         cmp       al,0
         je        EditCMK4
         mov       si,offset TabUMnFS+1
         cmp       al,"*"
         je        EditCMK4
         mov       si,offset TabUMnFC+1
         cmp       al,"^"
         je        EditCMK4
         mov       si,offset TabUMnFA+1

; ------ dek¢dov†n° plnÇho textu funkán° kl†vesy

EditCMK4:lea       di,ss:[bp-29]            ; buffer textu kl†vesy
         xor       cx,cx                    ; CX <- 0 á°taá dÇlky textu kl†vesy
EdiCMK42:mov       al,cs:[si]
         inc       si
         cmp       al," "
         jb        EdiCMK44
         stosb
         inc       cx
         jmp       short EdiCMK42

EdiCMK44:pop       ax
         aam                                ; dekadick† korekce
         add       ax,"00"                  ; ASCII znaky
         xchg      al,ah                    ; AL <- des°tky
         cmp       al,"0"
         je        EdiCMK46
         stosb                              ; uloëen° á°slice des°tek
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
EdiCMK46:mov       al,ah                    ; á°slice jednotek
         stosb
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
         mov       ss:[bp-30],cl            ; dÇlka plnÇho textu kl†vesy

; ------ p©°prava k vyhled†n° horkÇ kl†vesy

EditCMK5:mov       bx,ds:[UMenParI]         ; adresa parametrñ ©†dkñ
         xor       dx,dx                    ; ukazatel á°sla ©†dku volby

; ------ test, zda je to ©†dek volby

EdiCMK51:test      byte ptr ds:[bx],bit7    ; je ©†dek volby ?
         jz        EditCMK6                 ; nen° ©†dek volby

; ------ test, zda souhlas° dÇlka plnÇho textu kl†vesy

         mov       al,ds:[bx]               ; dÇlka textu
         and       al,bit0+bit1+bit2+bit3   ; dÇlka textu
         cmp       al,ss:[bp-30]            ; souhlas° dÇlka textu ?
         jne       EdiCMK55                 ; nesouhlas° dÇlka textu

; ------ porovn†n° plnÇho textu kl†vesy

         mov       ah,0
         xchg      ax,cx                    ; CX <- dÇlka textu kl†vesy
         mov       si,bx                    ; adresa parametru
         sub       si,ds:[UMenParI]         ; á°slo ©†dku
         shl       si,1                     ; offset v tabulce indexñ
         add       si,ds:[UMenLinI]         ; adresa v tabulce indexñ
         mov       si,ds:[si]               ; index v souboru
         add       si,ds:[UMenAdrF]         ; adresa v souboru
         lea       di,ss:[bp-29]            ; adresa plnÇho textu kl†vesy

EdiCMK52:lodsb
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         scasb                              ; porovn†n° znaku
         loope     EdiCMK52                 ; dal®° znak
         je        EditCMK7                 ; kl†vesa nalezena OK

; ------ test, zda souhlas° dÇlka zkr†cenÇho textu kl†vesy

EdiCMK55:mov       al,ds:[bx]               ; dÇlka textu
         and       al,bit0+bit1+bit2+bit3   ; dÇlka textu
         cmp       al,ss:[bp-10]            ; souhlas° dÇlka textu ?
         jne       EdiCMK58                 ; nesouhlas° dÇlka textu

; ------ porovn†n° zkr†cenÇho textu kl†vesy

         mov       ah,0
         xchg      ax,cx                    ; CX <- dÇlka textu kl†vesy
         mov       si,bx                    ; adresa parametru
         sub       si,ds:[UMenParI]         ; á°slo ©†dku
         shl       si,1                     ; offset v tabulce indexñ
         add       si,ds:[UMenLinI]         ; adresa v tabulce indexñ
         mov       si,ds:[si]               ; index v souboru
         add       si,ds:[UMenAdrF]         ; adresa v souboru
         lea       di,ss:[bp-9]             ; adresa zkr†cenÇho textu kl†vesy

EdiCMK56:lodsb
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         scasb                              ; porovn†n° znaku
         loope     EdiCMK56                 ; dal®° znak
         je        EditCMK7                 ; kl†vesa nalezena OK

; ------ p©°prava pro dal®° ©†dek

EdiCMK58:inc       dx                       ; zvò®en° á°sla ©†dku volby
EditCMK6:inc       bx                       ; zvò®en° ukazatele v tabulce
         cmp       dx,ds:[UMenVolN]         ; jsou jië v®echny ©†dky voleb ?
         jb        EdiCMK51                 ; nejsou v®echny ©†dky - dal®°
         jmp       short EditCMK8

; ------ kl†vesa nalezena OK

EditCMK7:xchg      ax,dx                    ; AX <- á°slo ©†dku volby
         sub       bx,ds:[UMenParI]         ; á°slo zobrazenÇho ©†dku
         mov       dx,bx                    ; DX <- á°slo zobrazenÇho ©†dku
         clc                                ; p©°znak operace OK
         jmp       short EditCMK9

; ------ n†vrat registrñ

EditCMK8:stc                                ; p©°znak nenalezen° kl†vesy
EditCMK9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

EditCMK  ENDP

; *****************************************************************************
;                             DekPLine
;               Dek¢dov†n° ©†dku textovÇho parametru menu
; -----------------------------------------------------------------------------
; VSTUP: AL=bàën† barva textu (0=barva se neukl†d†)
;        AH=zvòraznàn† barva textu (0=barva se neukl†d†)
;        DX:SI=adresa textovÇho ©†dku k dek¢dov†n° (ukonáen LF, EOF, 0)
;        CH=ukazatel pozice na ©†dku (kvñli TAB)
;        CL=maxim†ln° poáet znakñ k uloëen° (velikost bufferu)
;        DS=datovò segment
;        ES:DI=buffer k uloëen° dek¢dovanÇho textu
; VùSTUP: DI=nov† ukl†dac° adresa
;         SI=nov† átec° adresa (konec ©†dku)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) datovò segment
;                   SS:[BP-4] (2) segment textovÇho ©†dku
;                   SS:[BP-6] (2) segment bufferu k ukl†d†n°
;                   SS:[BP-7] (1) neaktivn° barva
;                   SS:[BP-8] (1) bàën† barva
; *****************************************************************************
;˛
DekPLine PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      es
         push      ds
         mov       bp,sp
         sub       sp,8

; ------ inicializace lok†ln°ch promànnòch

         mov       ss:[bp-2],ds             ; datovò segment
         mov       ss:[bp-4],dx             ; segment textovÇho ©†dku
         mov       ss:[bp-6],es             ; segment bufferu k ukl†d†n°
         mov       ss:[bp-8],ax             ; bàën† a zvòraznàn† barva textu
         mov       ah,al                    ; bàën† barva textu
         mov       ds,dx                    ; DS <- segment textovÇho ©†dku
         mov       dx,cx                    ; DL=max. znakñ, DH=ukazatel pozice
         cld

; ------ naáten° jednoho znaku

DekPLin1:lodsb                              ; naáten° znaku
DekPLn11:cmp       al,CR
         je        DekPLin1                 ; znak CR se ignoruje

; ------ test, zda je konec textu

         cmp       al,0
         je        DekPLn15
         cmp       al,LF
         je        DekPLn15
         cmp       al,EOF
         je        DekPLn15

; ------ test, zda je p©ep°naá parametrñ

         cmp       al,"%"
         je        DekPLn19                 ; je p©ep°naá parametrñ

; ------ test, zda je znak tabul†toru

         cmp       al,TAB                   ; je tabul†tor ?
         je        DekPLn16                 ; je tabul†tor

; ------ uloëen° znaku

DekPLn12:call      DekPLnCh                 ; uloëen° znaku
         jnz       DekPLin1                 ; dal®° znak
DekPLn13:jmp       DekPLin9                 ; konec dek¢dov†n°

; ------ konec textu - n†vrat posledn°ho znaku

DekPLn15:dec       si
         jmp       short DekPLn13

; ------ uloëen° znaku tabul†toru

DekPLn16:mov       al," "                   ; n†hradn° znak mezery
DekPLn17:call      DekPLnCh                 ; uloëen° znaku mezery
         jz        DekPLn13                 ; konec dek¢dov†n°
         test      dh,7                     ; je tabulaán° pozice ?
         jnz       DekPLn17                 ; uloëen° po tabulaán° pozici
         jmp       short DekPLin1           ; dal®° znak

; ------ test, zda je zdvojenò znak "%"

DekPLn19:lodsb                              ; naáten° dal®°ho znaku
         cmp       al,"%"                   ; je zdvojenò znak "%" ?
         je        DekPLn12                 ; je zdvojenò znak "%"
         cmp       al," "                   ; je platnò znak ?
         jbe       DekPLn11                 ; toto nen° platnò parametr

; ------ test, zda je á°selnò parametr "%0" aë "%9"

DekPLin2:cmp       al,"0"
         jb        DekPL200                 ; nen° á°selnò parametr
         cmp       al,"9"
         jbe       DekPL201                 ; je to á°selnò parametr OK
DekPL200:jmp       DekPLin3

; ------ £schova registrñ p©ed dek¢dov†n°m á°selnÇho parametru

DekPL201:push      si
         push      ds
         mov       ds,ss:[bp-2]             ; datovò segment

; ------ parametr "%0" - specifikace programu DOSMAN

         cmp       al,"0"
         jne       DekPLn21

         mov       si,offset DosmPath       ; specifikace programu DOSMAN
DekPL202:lodsb
         cmp       al,0
         je        DekPL204
         call      DekPLnCh                 ; uloëen° znaku
         jnz       DekPL202
DekPL204:jmp       DekPLn2A

; ------ parametr "%1" - jmÇno souboru pod kurzorem s p©°ponou

DekPLn21:cmp       al,"1"
         jne       DekPLn22

;         call      DekLTZK                  ; zkr†cen† cesta
         call      DekLTFA                  ; soubor v aktivn°m oknà s p©°ponou
         jmp       short DekPLn2A

; ------ parametr "%2" - adres†© neaktu†ln°ho okna

DekPLn22:cmp       al,"2"
         jne       DekPLn23

         call      DekLTDN                  ; disk neaktivn°ho okna
         mov       al,":"
         call      DekPLnCh                 ; oddàlovaá disku
         mov       al,"\"
         call      DekPLnCh                 ; £vodn° "\"
         call      DekLTPN                  ; cesta k neaktivn°mu oknu
         jmp       short DekPL272           ; uloëen° koncovÇho znaku "\"

; ------ parametr "%3" - adres†© domovskÇho adres†©e

DekPLn23:cmp       al,"3"
         jne       DekPLn24

         call      DekLTDH                  ; disk domovskÇho adres†©e
         mov       al,":"
         call      DekPLnCh                 ; oddàlovaá disku
         mov       al,"\"
         call      DekPLnCh                 ; £vodn° "\"
         call      DekLTPH                  ; cesta k domovskÇmu adres†©i
         jmp       short DekPL272           ; uloëen° koncovÇho znaku "\"

; ------ parametr "%4" - jmÇno souboru pod kurzorem

DekPLn24:cmp       al,"4"
         jne       DekPLn25

;         call      DekLTZK                  ; zkr†cen† cesta
         call      DekLTNA                  ; jmÇno v aktivn°m oknà bez p©°pony
         jmp       short DekPLn2A

; ------ parametr "%5" - p©°pona jmÇna souboru pod kurzorem

DekPLn25:cmp       al,"5"
         jne       DekPLn26

         call      DekLTEA                  ; p©°pona v aktivn°m oknà
         jmp       short DekPLn2A

; ------ parametr "%6" - adres†© p©echodnÇho adres†©e

DekPLn26:cmp       al,"6"
         jne       DekPLn27

         call      DekLTDT                  ; disk p©echodnÇho adres†©e
         mov       al,":"
         call      DekPLnCh                 ; oddàlovaá disku
         mov       al,"\"
         call      DekPLnCh                 ; £vodn° "\"
         call      DekLTPT                  ; cesta k p©echodnÇmu adres†©i
         jmp       short DekPL272           ; uloëen° koncovÇho znaku "\"

; ------ parametr "%7" - aktivn° adres†©

DekPLn27:cmp       al,"7"
         jne       DekPLn28

         call      DekLTDA                  ; disk aktivn°ho adres†©e
         mov       al,":"
         call      DekPLnCh                 ; oddàlovaá disku
         mov       al,"\"
         call      DekPLnCh                 ; £vodn° "\"
         call      DekLTPA                  ; cesta k aktivn°mu adres†©i
DekPL272:cmp       al,"\"                   ; byl posledn° znak "\" ?
         je        DekPLn2A                 ; byl jië znak "\"
         mov       al,"\"
         call      DekPLnCh                 ; uloëen° znaku "\"
         jmp       short DekPLn2A

DekPLn28:

; ------ n†vrat registrñ po dek¢dov†n° á°selnÇho parametru

DekPLn2A:pop       ds
         pop       si
         jmp       DekPLn89                 ; dal®° znak


; ====== ©°dic° k¢d "%{...}"

; ------ test, zda je ©°dic° k¢d "%{...}"

DekPLin3:cmp       al,"{"
         je        DekPLn30
         jmp       DekPLin8                 ; nen° ©°dic° k¢d "%{...}"

; ------ nastaven° barvy textu "%{*..}"

DekPLn30:lodsb                              ; dal®° znak
         cmp       al,"*"                   ; je nastaven° barvy textu ?
         jne       DekPLin4                 ; nen° nastaven° barvy textu
         or        ah,ah                    ; je barva textu ?
         jz        DekPLn38                 ; nen° barva textu

         cmp       byte ptr ds:[si],"}"     ; pouze zmàna barvy ?
         jne       DekPLn32                 ; nen° jen zmàna barvy
         xchg      ah,ss:[bp-7]             ; p©epnut° barvy
         jmp       short DekPLn38

DekPLn32:cmp       byte ptr ds:[si]," "     ; konec parametru ?
         jb        DekPLn38                 ; je konec parametru
         lodsb                              ; naáten° znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"N"                   ; norm†ln° barva ?
         jne       DekPL322
         mov       ah,ss:[bp-8]             ; norm†ln° barva
         jmp       short DekPLn38

DekPL322:cmp       al,"A"
         jb        DekPLn33
         sub       al,7
DekPLn33:sub       al,"0"
         jb        DekPLn38
         cmp       al,15
         ja        DekPLn38
         and       ah,0f0h
         or        ah,al                    ; nastaven° barvy pop©ed°
         jnz       DekPLn34                 ; nen° barva 0
         mov       ah,70h                   ; n†hradn° barva

DekPLn34:cmp       byte ptr ds:[si],"}"     ; konec parametru ?
         je        DekPLn38                 ; konec parametru
         cmp       byte ptr ds:[si]," "
         jb        DekPLn38                 ; konec parametru
         lodsb                              ; naáten° dal®°ho znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"A"
         jb        DekPLn35
         sub       al,7
DekPLn35:sub       al,"0"
         jb        DekPLn38
         cmp       al,15
         ja        DekPLn38
         shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1
         or        ah,al
         jnz       DekPLn38                 ; barva je OK
         mov       al,8                     ; n†hradn° barva
DekPLn38:jmp       DekPLin7                 ; nalezen° konce parametru

DekPLin4:

; ------ specifikace souborñ a adres†©ñ %{$text}

DekPLin6:cmp       al,"$"
         je        DekPLn60
         jmp       DekPLin7                 ; neplatnò parametr

DekPLn60:cld
         lodsb                              ; naáten° znaku parametru
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"D"
         jne       DekPLn63                 ; nen° disk

; ------ disk

         lodsb                              ; p©°®t° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno

         push      ds
         push      si                       ; (SI mus° bòt jako posledn° !)
         mov       ds,ss:[bp-2]             ; datovò segment

         cmp       al,"N"                   ; neaktivn° disk
         jne       DekPL622
         call      DekLTDN                  ; neaktivn° disk
         jmp       short DekPL629

DekPL622:cmp       al,"H"                   ; domovskò disk
         jne       DekPL623
         call      DekLTDH                  ; domovskò disk
         jmp       short DekPL629

DekPL623:cmp       al,"T"                   ; p©echodnò disk
         jne       DekPL624
         call      DekLTDT                  ; p©echodnò disk
         jmp       short DekPL629

DekPL624:cmp       al,"A"
         je        DekPL628                 ; aktivn°
         pop       si
         dec       si                       ; n†vrat znaku
         push      si
DekPL628:call      DekLTDA                  ; aktivn° disk

DekPL629:pop       si
         pop       ds
DekPL62A:jmp       short DekPLn60           ; dal®° parametr

; ------ cesta

DekPLn63:cmp       al,"P"
         jne       DekPLn64

         lodsb                              ; p©°®t° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno

         push      ds
         push      si                       ; (SI mus° bòt jako posledn° !)
         mov       ds,ss:[bp-2]             ; datovò segment

         cmp       al,"N"                   ; neaktivn° cesta
         jne       DekPL632
         call      DekLTPN                  ; neaktivn° cesta
         jmp       short DekPL639

DekPL632:cmp       al,"H"                   ; domovsk† cesta
         jne       DekPL633
         call      DekLTPH                  ; domovsk† cesta
         jmp       short DekPL639

DekPL633:cmp       al,"T"                   ; p©echodn† cesta
         jne       DekPL634
         call      DekLTPT                  ; p©echodn† cesta
         jmp       short DekPL639

DekPL634:cmp       al,"A"
         je        DekPL638                 ; aktivn°
         pop       si
         dec       si                       ; n†vrat znaku
         push      si
DekPL638:call      DekLTPA                  ; aktivn° cesta

DekPL639:jmp       short DekPL629

; ------ jmÇno souboru pod kurzorem

DekPLn64:cmp       al,"N"
         jne       DekPLn65

         lodsb                              ; p©°®t° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno

         push      ds
         push      si                       ; (SI mus° bòt jako posledn° !)
         mov       ds,ss:[bp-2]             ; datovò segment

         cmp       al,"N"                   ; neaktivn°
         jne       DekPL644
         call      DekLTNN                  ; neaktivn° jmÇno
         jmp       short DekPL649

DekPL644:cmp       al,"A"
         je        DekPL648                 ; aktivn°
         pop       si
         dec       si                       ; n†vrat znaku
         push      si
DekPL648:call      DekLTNA                  ; aktivn° jmÇno

DekPL649:jmp       short DekPL639

; ------ p©°pona jmÇna souboru pod kurzorem

DekPLn65:cmp       al,"E"
         jne       DekPLn66

         lodsb                              ; p©°®t° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno

         push      ds
         push      si                       ; (SI mus° bòt jako posledn° !)
         mov       ds,ss:[bp-2]             ; datovò segment

         cmp       al,"N"
         jne       DekPL654
         call      DekLTEN                  ; neaktivn° p©°pona
         jmp       short DekPL659

DekPL654:cmp       al,"A"
         je        DekPL658                 ; aktivn°
         pop       si
         dec       si                       ; n†vrat znaku
         push      si
DekPL658:call      DekLTEA                  ; aktivn° p©°pona

DekPL659:jmp       short DekPL649

; ------ test, zda je konec ©†dku

DekPLn66:cmp       al," "
         jb        DekPLn71                 ; konec parametru
         cmp       al,"}"
         je        DekPLn72                 ; konec parametru

; ------ ochrana p©ed zdvojen°m znaku "\"

         cmp       al,"\"
         jne       DekPLn68

         or        ah,ah                    ; ukl†d† se barva ?
         jnz       DekPLn67                 ; ukl†d† se barva
         cmp       byte ptr es:[di-1],al    ; byl posledn° znak "\" ?
         je        DekPL682                 ; byl jië znak "\"
         jmp       short DekPLn68

DekPLn67:cmp       byte ptr es:[di-2],al    ; byl posledn° znak "\" ?
         je        DekPL682                 ; byl jië znak "\"

; ------ jinò znak se uloë° beze zmàny

DekPLn68:call      DekPLnch                 ; uloëen° znaku
         jz        DekPLn69                 ; konec bufferu
DekPL682:jmp       DekPLn60                 ; dal®° znak

DekPLn69:jmp       DekPLin9                 ; konec


; ------ nalezen° konce parametru

DekPLin7:lodsb
         cmp       al,"}"
         je        DekPLn72
         cmp       al,TAB
         je        DekPLin7
         cmp       al," "
         jae       DekPLin7
DekPLn71:dec       si
DekPLn72:jmp       DekPLin1                 ; dal®° znak


; ====== systÇmov† promànn† DOS "%jmÇno%"

; ------ stanoven° dÇlky jmÇna promànnÇ DOS (v AL je prvn° znak) -> CX

DekPLin8:push      si
         xor       cx,cx                    ; á°taá dÇlky jmÇna promànnÇ
DekPLn81:lodsb                              ; naáten° dal®°ho znaku
         inc       cx                       ; zvò®en° á°taáe dÇlky jmÇna
         cmp       al," "
         jb        DekPLn82                 ; konec jmÇna
         cmp       al,"%"
         jne       DekPLn81                 ; nen° konec - dal®° znak
DekPLn82:pop       si
         dec       si                       ; n†vrat prvn°ho znaku jmÇna

; ------ nalezen° promànnÇ DS:SI/CX v prost©ed° -> DS:SI

         push      si                       ; adresa promànnÇ
         push      cx                       ; dÇlka promànnÇ

         push      es                       ; segment bufferu

         push      ds
         pop       es                       ; ES <- segment hledanÇho textu
         mov       ds,ss:[bp-2]             ; datovò segment

         call      far ptr GetIEnv          ; nalezen° intern° promànnÇ
         jnc       DekPLn84                 ; intern° promànn† nalezena
         call      far ptr GetEnv           ; nalezen° ©etàzce v prost©ed°

DekPLn84:push      es
         pop       ds                       ; DS <- segment nalezenÇho ©etàzce

         pop       es                       ; segment bufferu k dek¢dov†n°
         cld
         jc        DekPLn88                 ; promànn† nenalezena

; ------ p©enesen° textu promànnÇ

DekPLn87:lodsb                              ; naáten° znaku z prost©ed°
         cmp       al,0                     ; je konec textu parametru ?
         je        DekPLn88                 ; je konec textu parametru
         call      DekPLnCh                 ; uloëen° znaku
         jnz       DekPLn87                 ; dal®° znak promànnÇ

; ------ p©°prava k pokraáov†n° po dek¢dov†n° promànnÇ DOS

DekPLn88:pop       cx                       ; dÇlka promànnÇ
         pop       si                       ; adresa promànnÇ
         add       si,cx                    ; p©eskoáen° jmÇna promànnÇ
         mov       ds,ss:[bp-4]             ; segment textovÇho ©†dku
         lodsb                              ; znak za jmÇnem promànnÇ
         cmp       al,"%"                   ; konáil znakem "%" ?
         je        DekPLn89                 ; konáil znakem "%"
         dec       si                       ; byl asi konec ©†dku - n†vrat
DekPLn89:or        dl,dl                    ; zbylo m°sto v bufferu ?
         jz        DekPLin9                 ; nen° dal®° m°sto v bufferu
         jmp       DekPLin1                 ; dal®° znak

; ------ n†vrat registrñ

DekPLin9:mov       sp,bp
         pop       ds
         pop       es
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekPLine ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %FN - soubor v neaktivn°m oknà s p©°ponou
; -----------------------------------------------------------------------------

DekLTFN  PROC      NEAR

; ------ £schova registrñ

         push      es
         push      ds

; ------ adresa poloëky pod kurzorem

         push      es
         call      far ptr TestNAWn         ; test neaktivn°ho okna
         jc        DekLTFA1                 ; neaktivn° okno vypnuto
         call      far ptr GetNKurz         ; poskytnut° poloëky pod kurzorem
         jmp       short DekLTFA2

DekLTFN  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %FA, %1 - soubor v aktivn°m oknà s p©°ponou
; -----------------------------------------------------------------------------

DekLTFA  PROC      NEAR

; ------ £schova registrñ

         push      es
         push      ds

; ------ adresa poloëky pod kurzorem

         push      es
DekLTFA1:call      far ptr GetAKurz         ; poskytnut° poloëky pod kurzorem
DekLTFA2:push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- segment bufferu
         jc        DekLTFA9                 ; nen° ë†dn† poloëka

; ------ dek¢dov†n° jmÇna

         inc       si                       ; zaá†tek jmÇna souboru
         mov       cl,8                     ; dÇlka jmÇna souboru
         call      DekLNam                  ; dek¢dov†n° jmÇna

; ------ oddàlovac° teáka

         cmp       word ptr ds:[si],".."    ; je poloëka ".." ?
         je        DekLTFA9                 ; nebude teáka
         mov       al,"."
         call      DekPLnCh                 ; uloëen° oddàlovac° teáky

; ------ dek¢dov†n° p©°pony

         add       si,FileExt-FileName      ; zaá†tek p©°pony souboru
         mov       cl,3                     ; dÇlka p©°pony jmÇna souboru
         call      DekLNam                  ; dek¢dov†n° p©°pony

; ------ n†vrat registrñ

DekLTFA9:pop       ds
         pop       es
         ret

DekLTFA  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %NN - jmÇno souboru pod kurzorem bez p©°pony
; -----------------------------------------------------------------------------

DekLTNN  PROC      NEAR

; ------ £schova registrñ

         push      es
         push      ds

; ------ adresa poloëky pod kurzorem

         push      es
         call      far ptr TestNAWn         ; test neaktivn°ho okna
         jc        DekLTNA1                 ; neaktivn° okno vypnuto
         call      far ptr GetNKurz         ; poskytnut° poloëky pod kurzorem
         jmp       short DekLTNA2

DekLTNN  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %NA, %4 - jmÇno souboru pod kurzorem bez p©°pony
; -----------------------------------------------------------------------------

DekLTNA  PROC      NEAR

; ------ £schova registrñ

         push      es
         push      ds

; ------ adresa poloëky pod kurzorem

         push      es
DekLTNA1:call      far ptr GetAKurz         ; poskytnut° poloëky pod kurzorem
DekLTNA2:push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- segment bufferu
         jc        DekLTNA9                 ; nen° ë†dn† poloëka

; ------ dek¢dov†n° jmÇna

         inc       si                       ; zaá†tek jmÇna souboru
         mov       cl,8                     ; dÇlka jmÇna souboru
         call      DekLNam                  ; dek¢dov†n° jmÇna

; ------ n†vrat registrñ

DekLTNA9:pop       ds
         pop       es
         ret

DekLTNA  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %EN - p©°pona souboru pod kurzorem
; -----------------------------------------------------------------------------

DekLTEN  PROC      NEAR

; ------ £schova registrñ

         push      es
         push      ds

; ------ adresa poloëky pod kurzorem

         push      es
         call      far ptr TestNAWn         ; test neaktivn°ho okna
         jc        DekLTEA1                 ; neaktivn° okno vypnuto
         call      far ptr GetNKurz         ; poskytnut° poloëky pod kurzorem
         jmp       short DekLTEA2

DekLTEN  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %EA, %5 - p©°pona souboru pod kurzorem
; -----------------------------------------------------------------------------

DekLTEA  PROC      NEAR

; ------ £schova registrñ

         push      es
         push      ds

; ------ adresa poloëky pod kurzorem

         push      es
DekLTEA1:call      far ptr GetAKurz         ; poskytnut° poloëky pod kurzorem
DekLTEA2:push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- segment bufferu
         jc        DekLTEA9                 ; nen° ë†dn† poloëka

; ------ dek¢dov†n° p©°pony jmÇna

         add       si,FileExt               ; zaá†tek p©°pony souboru
         mov       cl,3                     ; dÇlka p©°pony souboru
         call      DekLNam                  ; dek¢dov†n° p©°pony

; ------ n†vrat registrñ

DekLTEA9:pop       ds
         pop       es
         ret

DekLTEA  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á†sti jmÇna DS:SI (CL znakñ)
; -----------------------------------------------------------------------------

DekLNam  PROC      NEAR

; ------ zji®tàn° dÇlky platnÇ á†sti jmÇna/p©°pony -> CX

         mov       ch,0
         push      si
         add       si,cx                    ; nastaven° ukazatele na konec + 1
DekLNam1:dec       si                       ; nastaven° na dal®° znak
         cmp       byte ptr ds:[si]," "     ; je oddàlovac° mezera ?
         jne       DekLNam2                 ; nen° mezera - je platnò znak
         loop      DekLNam1                 ; nalezen° jinÇho znaku neë mezera
DekLNam2:pop       si

; ------ p©enos platnÇ á†sti jmÇna/p©°pony

         jcxz      DekLNam4                 ; nen° ë†dnò znak
         push      si                       ; £schova zaá†tku
DekLNam3:cld
         lodsb                              ; znak k uloëen°
         call      DekPLnCh                 ; uloëen° znaku
         loop      DekLNam3                 ; dal®° znak
         pop       si
DekLNam4:ret

DekLNam  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %DH - disk domovskÇho adres†©e
; -----------------------------------------------------------------------------

DekLTDH  PROC      NEAR

         mov       al,ds:[HomeDir]          ; disk domovskÇho adres†©e
         jmp       short DekLTDA2

DekLTDH  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %DT - disk p©echodnÇho adres†©e
; -----------------------------------------------------------------------------

DekLTDT  PROC      NEAR

         mov       al,ds:[TempDir]          ; disk p©echodnÇho adres†©e
         jmp       short DekLTDA2

DekLTDT  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %DA - disk v aktivn°m oknà
; -----------------------------------------------------------------------------

DekLTDA  PROC      NEAR

DekLTDA1:push      es
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
DekLTDA4:mov       al,es:[AWinDir]          ; disk adres†©e
         pop       es
DekLTDA2:call      DekPLnCh                 ; uloëen° oznaáen° disku
         ret

DekLTDA  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametru %DN - disk v neaktivn°m oknà
; -----------------------------------------------------------------------------

DekLTDN  PROC      NEAR

         call      far ptr TestNAWn         ; test neaktivn°ho okna
         jc        DekLTDA1                 ; neaktivn° okno vypnuto - je aktivn°
         push      es
         call      far ptr GetNAWin         ; adresa neaktivn°ho okna
         jmp       short DekLTDA4

DekLTDN  ENDP

; -----------------------------------------------------------------------------
;        parametr %PT - cesta k p©echodnÇmu adres†©i -> AL posledn° znak
; -----------------------------------------------------------------------------

DekLTPT  PROC      NEAR

         mov       si,offset TempDir+3      ; konfiguraán° a datovò adres†©
         mov       cx,ds:[TempDirN]         ; dÇlka adres†©e
         jmp       short DekLTPH2

DekLTPT  ENDP

; -----------------------------------------------------------------------------
;        parametr %PH - cesta k domovskÇmu adres†©i -> AL posledn° znak
; -----------------------------------------------------------------------------

DekLTPH  PROC      NEAR

         mov       si,offset HomeDir+3      ; domovskò programovò adres†©
         mov       cx,ds:[HomeDirN]         ; dÇlka adres†©e
DekLTPH2:sub       cx,3                     ; bez disku a ROOT
         jbe       DekLTPH9                 ; je to ROOT
DekLTPH3:cld
         lodsb                              ; naáten° znaku
         call      DekPLnCh                 ; uloëen° znaku
         loop      DekLTPH3                 ; dal®° znak
DekLTPH9:ret

DekLTPH  ENDP

; -----------------------------------------------------------------------------
;        parametr %PA - cesta k aktivn°mu adres†©i (bez disku) -> AL posledn° znak
; -----------------------------------------------------------------------------

DekLTPA  PROC      NEAR

         push      ds

         push      es
         call      far ptr GetAAWin         ; aktivn° okno
         jmp       short DekLTPN1

DekLTPA  ENDP

; -----------------------------------------------------------------------------
;        parametr %PN - cesta k neaktivn°mu oknu (bez disku) -> AL posledn° znak
; -----------------------------------------------------------------------------

DekLTPN  PROC      NEAR

         call      far ptr TestNAWn         ; test neaktivn°ho okna
         jc        DekLTPA                  ; neaktivn° okno vypnuto

         push      ds

         push      es
         call      far ptr GetNAWin         ; neaktivn° okno
DekLTPN1:push      es
         pop       ds                       ; DS <- segment okna
         pop       es                       ; ES <- segment bufferu k uloëen°

         mov       si,AWinDir+3             ; zaá†tek cesty
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         sub       cx,3                     ; bez oznaáen° disku
         jbe       DekLTPN8                 ; je ROOT

DekLTPN2:cld
         lodsb                              ; naáten° znaku
         call      DekPLnCh                 ; uloëen° znaku
         loop      DekLTPN2                 ; dal®° znak

DekLTPN8:pop       ds
         ret

DekLTPN  ENDP

;; -----------------------------------------------------------------------------
;;        dek¢dov†n° zkr†cenÇ cesty k souboru
;; -----------------------------------------------------------------------------
;
;DekLTZK  PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ds
;
;; ------ test, zda je poloëka v aktivn°m oknà
;
;         push      es
;         call      far ptr GetAKurz         ; poskytnut° poloëky pod kurzorem
;         pop       es
;         jc        DekLTZK9                 ; nen° poloëka pod kurzorem
;
;; ------ cesta v aktivn°m oknà -> DS:SI/CX
;
;         push      es
;         call      far ptr GetAAWin         ; aktivn° okno
;         mov       si,offset AWinDir        ; aktivn° adres†©
;         mov       cx,es:[AWinDNum]         ; dÇlka aktivn°ho adres†©e
;         call      SeznGZk0                 ; zkr†cen° cesty
;         push      es
;         pop       ds                       ; DS <- segment okna
;         pop       es                       ; ES <- segment bufferu k uloëen°
;
;; ------ p©enesen° cesty
;
;         jcxz      DekLTZK9                 ; je aktivn° adres†©
;DekLTZK6:cld
;         lodsb                              ; naáten° znaku
;         call      DekPLnCh                 ; uloëen° znaku
;         loop      DekLTZK6                 ; dal®° znak
;         mov       al,"\"                   ; oddàlovaá cesty
;         call      DekPLnCh                 ; uloëen° oddàlovaáe cesty
;
;; ------ n†vrat registrñ
;
;DekLTZK9:pop       ds
;         ret
;
;DekLTZK  ENDP

; -----------------------------------------------------------------------------
;        uloëen° znaku AL/AH (ZY=konec bufferu)
; -----------------------------------------------------------------------------

DekPLnCh PROC      NEAR

         or        dl,dl
         jz        DekPLnC8

; ------ uloëen° znaku bez barvy

         cld
         or        ah,ah                    ; ukl†d† se barva ?
         jnz       DekPLnC4                 ; barva se ukl†d†
         stosb                              ; uloëen° znaku do bufferu
         inc       dh                       ; zvò®en° ukazatele pozice
         dec       dl                       ; sn°ëen° á°taáe znakñ
         ret

; ------ uloëen° znaku s barvou

DekPLnC4:stosw                              ; uloëen° znaku s barvou
         inc       dh                       ; zvò®en° ukazatele pozice
         dec       dl                       ; sn°ëen° á°taáe znakñ
DekPLnC8:ret

DekPLnCh ENDP

CodeMnu  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; -----------------------------------------------------------------------------
;        Zad†n° p©°kazu pro oznaáenÇ soubory
; -----------------------------------------------------------------------------

SPOMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SPOMLPol                 ; zaá†tek definice poloëek menu
         dw        SPOMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuSpusteniprogramu ; á°slo str†nky velkÇ n†povàdy
         dw        SPOMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SPOMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        8                        ; vò®ka okna

SPOMLinM dw        115                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        HistComm                 ; identifik†tor historie
SPOMLPlL db        1                        ; poáet p©edvoleb

SPOMLPlN dw        0                        ; dÇlka p©edvolby
         dd        LineCBuf                 ; p©edvolba

; ------ poloëky voleb

SPOMLPol db        bit6,41,'Zadejte p©°kaz k v°cen†sobnÇmu proveden°:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        1,6,'N†vrat'

SPOMLBlk db        0,0,0                    ; blokovac° tabulka

SPOMLTit db        18,'v°cen†sobnò p©°kaz'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SPOMLHlp db        84,'Zadejte p©°kaz k proveden° (%1=soubor, %2=neakt. okno, %4=jmÇno, %5=p©°pona)'
         db        26,'Proveden° zadanÇho p©°kazu'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Zad†n° parametru menu GET
; -----------------------------------------------------------------------------

GetMLin  label     byte
         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        GetMLPol                 ; zaá†tek definice poloëek menu
         dw        GetMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuSpusteniprogramu ; á°slo str†nky velkÇ n†povàdy
         dw        GetMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        GetMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        71                       ; ®°©ka okna
         db        8                        ; vò®ka okna

GetMLinM dw        120                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        2,0,'"    '              ; zak†zanÇ znaky

         db        HistMenu                 ; identifik†tor historie
         db        1                        ; poáet p©edvoleb

GetMLPlN dw        0                        ; dÇlka p©edvolby
         dd        0                        ; p©edvolba

; ------ poloëky voleb

GetMLPol db        bit6,8,0,4,3
GetMLPl1 db        0
         dd        0
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D†le'
         db        1,9,'P©eru®en°'

GetMLBlk db        0,0,0                    ; blokovac° tabulka

GetMLTit db        16,'zad†n° parametru'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
GetMLHlp db        24,'Zadejte parametr operace'
         db        26,'Pokraáov†n° d†le v operaci'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - soubor uëivatelskÇho menu nenalezen
; -----------------------------------------------------------------------------

FndUsrMn label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        FndUsrMP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@UzivatelskeMenu      ; á°slo str†nky velkÇ n†povàdy
         dw        FndUsrMB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        FndUsrMT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
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

; ------ poloëky voleb

FndUsrMP db        bit6,6,0,'CHYBA'
         db        bit6,37,'Soubor uëivatelskòch voleb nenalezen:'
         db        bit6,7,0,3
FndUsMP2 db        0                        ; dÇlka jmÇna souboru
         dd        0                        ; adresa jmÇna souboru
         db        bit6+bit7,0
         db        1,6,'N†vrat'

FndUsrMB db        0

FndUsrMT db        16,'soubor nenalezen'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - soubor velkò k naáten° do pamàti
; -----------------------------------------------------------------------------

SizUsrMn label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        4                        ; celkovò poáet poloëek menu

         dw        SizUsrMP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@UzivatelskeMenu      ; á°slo str†nky velkÇ n†povàdy
         dw        FndUsrMB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SizUsrMT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

SizUsrMP db        bit6,6,0,'CHYBA'
         db        bit6,36,'Soubor nelze naá°st celò do pamàti !'
         db        bit6+bit7,0
         db        1,6,'N†vrat'

SizUsrMT db        17,'nedostatek pamàti'

; -----------------------------------------------------------------------------
;        obsluha horkòch kl†ves
; -----------------------------------------------------------------------------

HotKeyT  db        6,'HotKey'               ; skupina
HotKFT   db        6,'SCAF12'               ; oznaáen° funkán° kl†vesy


ExtnsTxt db        9,'Extension'            ; skupina definice p©°pon

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

LevelIF  dw        0                        ; á°taá £rovnà vypnut° IF
                                            ;   (0=©†dky povoleny)
LevelCAS dw        0                        ; á°taá £rovnà vypnut° CASE
UMnCaseN dw        -1                       ; dÇlka ©etàzece CASE (-1=nen°)
UMnCaseC db        0                        ; £vodn° znak ©etàzce CASE

LevelFor dw        0                        ; poáet vno©enòch cyklñ FOR

BlokFor  dw        0                        ; hloubka blokov†n° tàla FOR

AdresAkt dw        0                        ; adresa aktu†ln°ho ©†dku s "#."

AdresFor dw        0                        ; adresa pro opakov†n° FOR (0=nen°)
UParmFor db        0                        ; parametry aktivn°ho cyklu FOR
                                            ;   bit 0: 1=FOR se obsluhuje (prov†dàn°)
                                            ;   bit 1: 1=nutn† zmàna segmentu menu
                                            ;   bit 2: 1=opakovanò vstup do FOR
                                            ;   bit 3: 1=pouëit cyklus souborñ

; ------ parametry p©i inicializaci menu

UMenUPar label     byte
         db        4,'MENU'                 ; definice rozmàrñ menu
         dw        UPMenus
         db        6,'INTENS'               ; nastaven° intenzity
         dw        UPIntens
         db        6,'COLRAM'               ; barva r†mu
         dw        UPColRam
         db        6,'COLTIT'               ; barva titulku
         dw        UPColTit
         db        6,'COLHEA'               ; barva z†hlav°
         dw        UPColHea
         db        6,'COLTXT'               ; barva textu
         dw        UPColTxt
         db        6,'COLCUR'               ; barva kurzoru
         dw        UPColCur
         db        6,'COLHLP'               ; barva n†povàdy
         dw        UPColHlp
         db        2,'IF'                   ; podm°nka
         dw        UPIF
         db        4,'ELSE'                 ; IF nesplnàno
         dw        UPELSE
         db        5,'ENDIF'                ; konec IF
         dw        UPENDIF
         db        4,'CASE'                 ; vàtven° p©°padñ
         dw        UPCCASE
         db        2,'IN'                   ; p©°pad splnàn
         dw        UPIN
         db        3,'OUT'                  ; ë†dnò p©°pad nesplnàn
         dw        UPOUT
         db        7,'ENDCASE'              ; konec CASE
         dw        UPENDCS
         db        3,'FOR'                  ; cyklus FOR
         dw        UPFOR
         db        6,'ENDFOR'               ; konec FOR
         dw        UPENDFR
         db        6,'EXITON'               ; p©eru®en° cyklu
         dw        UPEXIT
         db        0

EchoTxt  db        '@ECHO OFF',13,10
EchoTxt0 label     byte

ListMNam db        12,'$DOSMAN$.LST'
UserMNam db        10,'DOSMAN.MNU'          ; implicitn° jmÇno souboru menu
UserMFil label     byte
         db        FileMax dup(0)           ; jmÇno souboru hlavn°ho menu

NumUserM dw        0                        ; poáet uëivatelskòch menu

; ------ definice otev©enòch uëivatelskòch menu

MnuUserM db        18                       ; typ menu - uëivatelskÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        4                        ; celkovò poáet poloëek menu

         dw        0                        ; zaá†tek definice poloëek menu
         dw        0                        ; adresa tabulky textñ n†povàdy
         dw        Hlp@UzivatelskeMenu      ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        0                        ; adresa titulu okna
         dw        0                        ; tabulka obsluh voleb menu
         dw        0                        ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        5                        ; poá†teán° pozice okna
         db        2                        ; poá†teán° ©†dek okna
         db        70                       ; ®°©ka okna
         db        20                       ; vò®ka okna

         dw        0                        ; segment s definic° menu

         db        (MaxUserM-1)*MnuCSumm dup(0) ; buffer pro ostatn° menu

MnuSegmX dw        0                        ; n†hradn° segment menu - INIT

UserSwcM db        0                        ; p©ep°naáe z volby uëiv. menu
                                            ;   bit 0: 1=generuje se seznam
                                            ;   bit 1: 1=zad†n povel s "!"
                                            ;   bit 2:  1=m¢d spou®tàn° BAT
                                            ;   bit 3:  1=m¢d spou®tàn° LOADER
                                            ;   bit 4:  1=m¢d spou®tàn° PERMAN
                                            ;   bit 5: 1=je p©°kaz VAL ƒø0=SET
                                            ;   bit 6: 1=je p©°kaz GET ƒŸ
                                            ;   bit 7: 1=byl jië prvn° p©°kaz

UserSwM2 db        0                        ; p©ep°naáe menu 2 - seznam
                                            ;   bit 0:
                                            ;   bit 1: 1="F" ne soubory
                                            ;   bit 2: 1="S" nevno©ovat se
                                            ;   bit 3: 1="D" ne adres†©e
                                            ;   bit 4: 1="2" ne druhÇ okno
                                            ;   bit 5: 1="@" v®echny soubory

DBatIdnt dw        0                        ; identifik†tor $DOSMAN$.BAT

; ------ standardn° definice barev menu

;UMnuCol1 db        70h                      ; (1) bàën† barva menu
;UMnuCol2 db        74h                      ; (1) zvòraznàn† barva menu
;UMnuCol3 db        30h                      ; (1) bàën† barva kurzoru menu
;UMnuCol4 db        34h                      ; (1) zvòraznàn† barva kurzoru menu
;UMnuClR1 db        70h                      ; (1) barva r†mu menu - tmav†
;UMnuClR2 db        7fh                      ; (1) barva r†mu menu - svàtl†
;UMnuColT db        70h                      ; (1) barva titulku okna
;UMnuColH db        1Fh                      ; (1) barva z†hlav° menu
;UMnuClH2 db        1Eh                      ; (1) zvòraznàn† barva z†hlav° menu
;UMnuColP db        30h                      ; (1) barva n†povàdy menu
;UMnuClP2 db        34h                      ; (1) zvòraznàn† barva n†povàdy

Data     ENDS
         END

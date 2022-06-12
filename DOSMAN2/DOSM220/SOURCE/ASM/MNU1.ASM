

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 M E N U  -  1
;
;                     Obsluha voleb - hlavn° a vertik†ln° menu
;
; =============================================================================
;
;        OpenMnu  (FAR) - otev©en° menu
;        ClosMnu  (FAR) - uzav©en° posledn°ho menu
;        ClosMnuA (FAR) - uzav©en° v®ech menu
;        DispMnu  (FAR) - zobrazen° menu
;        CentMenu (FAR) - centrov†n° menu
;        MCtrlO   (FAR) - obsluha p©echodnÇho vypnut° menu
;        EditMEnt (FAR) - obsluha volby poloëky menu
;        TestMSwc (FAR) - test, zda je poloëka p©ep°naá
;        TestMnu  (FAR) - test, zda je zadanÇ menu otev©eno
;        DispTim0 (FAR) - nepodm°nànÇ zobrazen° áasu
;        DispTime (FAR) - podm°nànÇ zobrazen° áasu
;        SrcHotA  (FAR) - nalezen° poloëky podle horkÇ kl†vesy s Alt-
;        SrcHotM  (FAR) - nalezen° poloëky podle horkÇ kl†vesy
;        GetSwch  (FAR) - poskytnut° stavu p©ep°naáñ menu
;        SetSwch  (FAR) - nastaven° stavu p©ep°naáñ menu
;
;        DispRamM (FAR) - zobrazen° horn°ho a doln°ho okraje r†mu okna menu
;        DispCarM (FAR) - zobrazen° vodorovnÇ linky v oknà menu
;        DispTxtM (FAR) - zobrazen° textovÇ poloëky v oknà menu
;        DispTxtR (FAR) - zobrazen° v°ce textovòch poloëek v oknà menu
;        DispMStr (FAR) - zobrazen° ©etàzce s maskov†n°m p©es okna menu
;        KorPozM  (FAR) - korekce pozice menu (omezen° p©i p©eteáen°)
;
;        MainMenu (FAR) - obsluha voleb hlavn°ho menu
;        InitMMnu (FAR) - inicializace hlavn°ho menu p©ed otev©en°m
;        DispMMnu (FAR) - zobrazen° hlavn°ho menu
;        EditMMnu (FAR) - editace hlavn°ho menu
;
;        VertMenu (FAR) - obsluha voleb vertik†ln°ho menu
;        InitVMnu (FAR) - inicializace vertik†ln°ho menu p©ed otev©en°m
;        DispVMnu (FAR) - zobrazen° vertik†ln°ho menu
;        EditVMnu (FAR) - editace vertik†ln°ho menu
;        MenuNum  (FAR) - zad†n° á°selnÇ poloëky ve vertik†ln°m menu
;
;        NumMenu  (WORD) - poáet otev©enòch oken menu
;        TabMenu  (WORD) - tabulka otev©enòch oken menu
;        PozMenu  (WORD) - tabulka poá†teán°ch pozic otev©enòch oken menu
;        SirMenu  (WORD) - tabulka rozmàrñ otev©enòch oken menu
;        AktMenu  (WORD) - adresa aktu†ln°ho menu
;        ParMenu  (BYTE) - parametry menu
;
;        ColTime  (BYTE) - barva textu áasu v hlavn°m menu
;        ColDate  (BYTE) - barva textu data a informaán°ho textu v hlavn°m menu
;        ColMnu1  (BYTE) - bàën† barva textu menu
;        ColMnu2  (BYTE) - vysv°cen† barva textu menu
;        ColMnu3  (BYTE) - bàën† barva kurzoru v menu
;        ColMnu4  (BYTE) - vysv°cen† barva kurzoru v menu
;        ColMnu5  (BYTE) - bàën† barva zak†zanÇ poloëky
;        ColMnu6  (BYTE) - barva kurzoru zak†zanÇ poloëky
;        ColMnuN  (BYTE) - barva editovanÇ á°selnÇ poloëky v oknà vertik. menu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeMnu  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeMnu,ds:Data

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                  ObecnÇ procedury pro obsluhu menu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                  OpenMnu
;                            otev©en° okna menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

OpenMnu  PROC      FAR

         and       byte ptr ds:[ParMenu],not bit5 ; zru®en° p©°znaku vyno©en°

; ------ inicializace parametrñ menu DS:SI

         push      bx
         mov       bl,ds:[si+MnuTyp]        ; typ menu
         mov       bh,0
         shl       bx,1
         shl       bx,1                     ; offset v tabulce adres menu
         call      dword ptr cs:[bx+InitAdrT] ; inicializace parametrñ menu

; ------ uloëen° adresy definice novÇho menu

         mov       bx,ds:[NumMenu]          ; poáet otev©enòch oken menu
         shl       bx,1                     ; poáet menu * 2
         mov       ds:[TabMenu+bx],si       ; uloëen° adresy definice menu

; ------ uloëen° sou©adnic menu

         push      ax
         mov       ax,word ptr ds:[si+MnuPoz]        ; poá†teán° pozice a ©†dek menu
         mov       ds:[PozMenu+bx],ax       ; £schova pozice a ©†dku menu
         mov       ax,word ptr ds:[si+MnuSir]        ; ®°©ka a vò®ka okna menu
         mov       ds:[SirMenu+bx],ax       ; £schova ®°©ky a vò®ky menu
         mov       ax,ds:[NumMenu]          ; poáet otev©enòch oken menu
         inc       ax                       ; zvò®en° á°taáe menu v tabulce
         mov       ds:[NumMenu],ax          ; novò poáet oken menu
         mov       ds:[si+MnuLev],al        ; hladina okna menu
         pop       ax
         mov       ds:[AktMenu],si          ; je to souáasnà aktivn° menu

; ------ nastaven° p©°znaku zobrazen° hlavn°ho menu

         or        byte ptr ds:[ParMenu],bit2 ; p©°znak zobrazen° menu
         cmp       byte ptr ds:[si+MnuTyp],0 ; je to hlavn° menu ?
         jne       OpenMnu3                 ; nen° to hlavn° menu
         or        byte ptr ds:[ParMenu],bit1 ; p©°znak zobrazen° hlavn°ho menu

; ------ zobrazen° novÇho menu

OpenMnu3:pop       bx
         call      far ptr DispAll          ; zobrazen° v®eho
         ret

OpenMnu  ENDP

; ------ adresy obsluh inicializace jednotlivòch menu

InitAdrT label     dword
         dd        InitMMnu                 ;  0: hlavn° menu
         dd        InitVMnu                 ;  1: vertik†ln° menu hlavn°
         dd        InitVMnu                 ;  2: vertik†ln° podmenu
         dd        InitLMnu                 ;  3: ©†dkovÇ menu
         dd        InitDMnu                 ;  4: menu volby diskñ
         dd        InitAMnu                 ;  5: ASCII tabulka
         dd        InitTMnu                 ;  6: hodiny
         dd        InitTBMn                 ;  7: tabulka
         dd        InitRMnu                 ;  8: kalend†©
         dd        InitSMnu                 ;  9: vòbàr souborñ
         dd        InitBMnu                 ; 10: editor datab†ze
         dd        InitUMnu                 ; 11: obnoven° souborñ
         dd        InitOMnu                 ; 12: form†tov†n° disket
         dd        InitPMnu                 ; 13: mapa disku
         dd        InitZMnu                 ; 14: zobrazen° disku
         dd        InitBMMn                 ; 15: modifikace datab†ze
         dd        InitEMnu                 ; 16: editor textñ v bufferu
         dd        InitGMnu                 ; 17: funkán° kl†vesy
         dd        InitCMnu                 ; 18: uëivatelskÇ menu
         dd        InitCDMn                 ; 19: CD disk
         dd        InitHMnu                 ; 20: n†povàda

; *****************************************************************************
;                              ClosMnu
;                     uzav©en° okna aktivn°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:DS:SI=adresa definice novÇho menu (SI=0 nen° dal®° menu)
; *****************************************************************************

ClosMnu  PROC      FAR

; ------ sn°ëen° poátu menu

         mov       si,ds:[NumMenu]          ; poáet otev©enòch oken menu
         or        si,si                    ; je nàjakÇ menu ?
         jz        ClosMnu9                 ; nen° ë†dnÇ menu
         dec       si                       ; sn°ëen° poátu menu
         mov       ds:[NumMenu],si          ; novò poáet menu

; ------ zru®en° p©°znakñ zobrazen° menu

         shl       si,1                     ; á°slo menu * 2
         mov       si,ds:[TabMenu+si-2]     ; adresa p©edch†zej°c°ho menu
         jnz       ClosMnu7                 ; je dal®° menu
         and       byte ptr ds:[ParMenu],not bit1 + bit2 ; zru®en° p©°znakñ menu
         xor       si,si                    ; SI <- 0 nen° dal®° menu

; ------ adresa novÇho aktivn°ho menu (0=nen° dal®°)

ClosMnu7:mov       ds:[AktMenu],si          ; novÇ aktivn° menu

; ------ novÇ zobrazen° obrazovky

         call      far ptr DispAll          ; novÇ zobrazen° obrazovky
ClosMnu9:ret

ClosMnu  ENDP

; *****************************************************************************
;                            ClosMnuA
;                      uzav©en° v®ech oken menu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ClosMnuA PROC      FAR

         mov       word ptr ds:[AktMenu],0  ; neplatnÇ aktivn° menu
         and       byte ptr ds:[ParMenu],not bit1 + bit2 ; zru®en° p©°znakñ menu
         cmp       word ptr ds:[NumMenu],0  ; je otev©eno nàjakÇ menu ?
         je        ClosMnA2                 ; nen° otev©eno ë†dnÇ menu
         mov       word ptr ds:[NumMenu],0  ; zru®en° v®ech menu
         call      far ptr DispAll          ; novÇ zobrazen° obrazovky
ClosMnA2:ret

ClosMnuA ENDP

; *****************************************************************************
;                               DispMnu
;                           zobrazen° menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

DispMnu  PROC      FAR

; ------ blokov†n° zobrazen° menu p©i p©echodnÇm vypnut° Ctrl-O

         test      byte ptr ds:[ParMenu],bit3 ; je p©echodnÇ vypnut° ?
         jnz       DispMnu9                 ; je p©echodnÇ vypnut° menu

; ------ zobrazen° menu DS:SI

         push      bx
         mov       bl,ds:[si+MnuTyp]        ; typ menu
         mov       bh,0
         shl       bx,1
         shl       bx,1                     ; offset v tabulce adres menu
         call      dword ptr cs:[bx+DispAdrT] ; zobrazen° menu
         pop       bx

; ------ zobrazen° n†povàdy k menu (pouze je-li to aktivn° menu)

         cmp       si,ds:[AktMenu]          ; je to aktivn° menu ?
         jne       DispMnu9                 ; nen° to aktivn° menu
         cmp       byte ptr ds:[si+MnuTyp],18 ; je to uëivatelskÇ menu ?
         je        DispMnu9                 ; uëivatelskÇ menu-vlastn° n†povàda
         call      far ptr DispMHlp         ; zobrazen° n†povàdy menu
DispMnu9:ret

DispMnu  ENDP

; ------ adresy obsluh zobrazen° jednotlivòch menu

DispAdrT label     dword                    ; tabulka adres zobrazen° menu
         dd        DispMMnu                 ;  0: hlavn° menu
         dd        DispVMnu                 ;  1: vertik†ln° menu hlavn°
         dd        DispVMnu                 ;  2: vertik†ln° podmenu
         dd        DispLMnu                 ;  3: ©†dkovÇ menu
         dd        DispDMnu                 ;  4: menu volby diskñ
         dd        DispAMnu                 ;  5: ASCII tabulka
         dd        DispTMnu                 ;  6: hodiny
         dd        DispTBMn                 ;  7: tabulka
         dd        DispRMnu                 ;  8: kalend†©
         dd        DispSMnu                 ;  9: vòbàr souborñ
         dd        DispBMnu                 ; 10: editor datab†ze
         dd        DispUMnu                 ; 11: obnoven° souborñ
         dd        DispOMnu                 ; 12: form†tov†n° disket
         dd        DispPMnu                 ; 13: mapa disku
         dd        DispZMnu                 ; 14: zobrazen° disku
         dd        DispBMMn                 ; 15: modifikace datab†ze
         dd        DispEMnu                 ; 16: editor textñ v bufferu
         dd        DispGMnu                 ; 17: funkán° kl†vesy
         dd        DispCMnu                 ; 18: uëivatelskÇ menu
         dd        DispCDMn                 ; 19: CD disk
         dd        DispHMnu                 ; 20: n†povàda

; *****************************************************************************
;                              CentMenu
;                      centrov†n° menu (v obou smàrech)
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

CentMenu PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ vertik†ln° vyst©edàn° menu

         mov       al,ds:[MaxRow]           ; maxim†ln° ©†dek na displeji
;         dec       ax                       ; poáet ©†dkñ okna - 2
         sub       al,ds:[si+MnuVys]        ; odeáten° vò®ky okna
         jnc       CentMnu1                 ; nen° p©eteáen°
         mov       al,0                     ; omezen° poá†teán°ho ©†dku
CentMnu1:shr       al,1                     ; polovina - poá†tek (trochu naho©e)
;         jnz       CentMnu2                 ; nen° ©†dek 0
;         inc       ax                       ; minim†ln° ©†dek 1
CentMnu2:mov       ds:[si+MnuRad],al        ; poá†teán° ©†dek okna

; ------ horizont†ln° vyst©edàn° menu

         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       al,ds:[si+MnuSir]        ; zbytek na okraje
         jnc       CentMnu3                 ; nen° p©eteáen°
         mov       al,0                     ; omezen° poá†teán° pozice
CentMnu3:shr       al,1                     ; poá†teán° pozice
         mov       ds:[si+MnuPoz],al        ; poá†teán° pozice okna

; ------ n†vrat registrñ

         pop       ax
         ret

CentMenu ENDP

; *****************************************************************************
;                                MCtrlO
;                      p©echodnÇ vypnut° menu Ctrl-O
; -----------------------------------------------------------------------------
; VSTUP: BX=kl†vesa
;        DS=datovò segment
; VùSTUP:BX=0 byla kl†vesa Ctrl-O
;        CY=byla kl†vesa Ctrl-O
; *****************************************************************************

MCtrlO   PROC      FAR

; ------ test, zda je kl†vesa Ctrl-O

         cmp       bx,180fh                 ; je kl†vesa Ctrl-O ?
         clc
         jne       MCtrlO9                  ; nen° kl†vesa Ctrl-O

; ------ obsluha kl†vesy Ctrl-O

         or        byte ptr ds:[ParMenu],bit3 ; p©°znak p©echodnÇho vypnut°
         call      far ptr DispAll          ; zobrazen° oken bez menu
         push      si
         mov       si,offset CtrlOTxt       ; text n†povàdy
         call      far ptr DispHTxt         ; zobrazen° textu n†povàdy
         pop       si
         call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr InpChar          ; áek†n° na stisk kl†vesy
         and       byte ptr ds:[ParMenu],not bit3 ; zru®en° p©°znaku vypnut°
         call      far ptr DispAll          ; zobrazen° oken s menu
         xor       bx,bx                    ; p©°znak obsluhy kl†vesy
         stc

MCtrlO9: ret

MCtrlO   ENDP

; *****************************************************************************
;                               EditMEnt
;                      proveden° volby menu ENTER
; -----------------------------------------------------------------------------
; VSTUP: AX=zvolen† poloëka (1...)
;        BX=kl†vesa, kter† vyvolala volbu
;        DS:SI=definice volby
; VùSTUP: CY=poloëka nen° povolena, volba nebyla provedena, BX=0 kl†vesa OK
;         NC=volba provedena, BX nezmànàno
; *****************************************************************************

EditMEnt PROC      FAR

         mov       ds:[si+MnuAkt],ax        ; nov† aktivn° poloëka
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         push      si
         mov       si,ds:[si+MnuBlk]        ; adresa blokovac° tabulky
         add       si,ax                    ; adresa poloëky + 1
         cmp       byte ptr ds:[si-1],0     ; je poloëka povolena ?
         pop       si
         je        EditMEn2                 ; poloëka je povolena OK
         xor       bx,bx                    ; p©°znak obsluhy kl†vesy
         stc                                ; p©°znak z†kazu volby
EditMEn2:ret

EditMEnt ENDP

; *****************************************************************************
;                                TestMSwc
;                    test, zda poloëka je p©ep°naá
; -----------------------------------------------------------------------------
; VSTUP: AX=poëadovan† poloëka (1...)
;        DS:SI=definice volby
; VùSTUP: CY=poloëka nen° p©ep°naá
;         NC=poloëka je p©ep°naá, NZ=p©ep°naá je nastaven
; *****************************************************************************

TestMSwc PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ nalezen° poëadovanÇ poloëky

         mov       bx,ds:[si+MnuSwch]       ; tabulka p©ep°naáñ
         mov       si,ds:[si+MnuPol]        ; definice poloëek
         mov       ch,0                     ; CH <- 0
TestMSw1:test      byte ptr ds:[si+MnuParm],bit6 ; je to platn† poloëka ?
         jnz       TestMSw2                 ; nen° to platn† poloëka
         dec       ax                       ; á°taá hledanÇ poloëky
         jz        TestMSw3                 ; nalezena poëadovan† poloëka
         test      byte ptr ds:[si+MnuParm],bit7 ; je to p©ep°naá ?
         jz        TestMSw2                 ; nen° to p©ep°naá
         inc       bx                       ; zvò®en° ukazatele p©ep°naáñ
TestMSw2:inc       si
         mov       cl,ds:[si+MnuDelk-1]     ; dÇlka textu poloëky
         inc       si                       ; zaá†tek textu poloëky
         add       si,cx                    ; adresa dal®° poloëky
         jmp       short TestMSw1           ; test dal®° poloëky
TestMSw3:test      byte ptr ds:[si+MnuParm],bit7 ; je to p©ep°naá ?
         stc                                ; p©°znak, ëe to nen° p©ep°naá
         jz        TestMSw4                 ; nen° to p©ep°naá
         cmp       byte ptr ds:[bx],0       ; test stavu p©ep°naáe

; ------ n†vrat registrñ

TestMSw4:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

TestMSwc ENDP

; *****************************************************************************
;                               TestMnu
;                    test, zda je menu otev©eno
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; VùSTUP: CY=menu nen° otev©eno
; *****************************************************************************

TestMnu  PROC      FAR

; ------ £schova registrñ

         push      cx
         push      di
         push      es

; ------ nalezen° definice menu v tabulce

         cld
         push      ds
         pop       es
         mov       cx,ds:[NumMenu]          ; poáet menu v tabulce
         jcxz      TestMnu8                 ; nen° ë†dnÇ okno
         mov       di,offset TabMenu        ; tabulka definic menu
         xchg      ax,si                    ; AX <- definice hledanÇho menu
         repne     scasw                    ; je okno menu otev©eno ?
         xchg      ax,si
         je        TestMnu9                 ; okno menu je otev©eno
TestMnu8:stc                                ; p©°znak - menu nen° otev©eno

; ------ n†vrat registrñ

TestMnu9:pop       es
         pop       di
         pop       cx
         ret

TestMnu  ENDP

; *****************************************************************************
;                             DispTim0
;            okamëitÇ zobrazen° aktu†ln°ho systÇmovÇho áasu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispTim0 PROC      FAR

         mov       byte ptr ds:[LastTime],-1 ; zru®en° posledn° á°slice
                                          ;* pokraáuje procedura DispTime !

DispTim0 ENDP

; *****************************************************************************
;                                 DispTime
;                   zobrazen° aktu†ln°ho systÇmovÇho áasu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispTime PROC      FAR

; ------ kontrola, zda se áas zobraz°

         test      byte ptr ds:[DarkParm],bit1 ; je ztmaven displej ?
         jnz       DispTm12                 ; je ztmaven displej
         test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ hlavn° menu ?
         jnz       DispTim2                 ; je trvalÇ hlavn° menu
         test      byte ptr ds:[ParMenu],bit3 ; je p©echodnÇ vypnut° menu ?
         jnz       DispTim1                 ; je p©echodnÇ vypnut° menu
         test      byte ptr ds:[ParMenu],bit1 ; je zobrazeno hlavn° menu ?
         jnz       DispTim2                 ; je zobrazeno hlavn° menu

         push      cx
         push      si
         mov       si,offset PozMenu-2+1    ; tabulka pozic menu
         mov       cx,ds:[NumMenu]          ; poáet menu
         or        si,si                    ; nastaven° p©°znaku NZ
         jcxz      DispTm04                 ; nen° ë†dnÇ menu
DispTm02:inc       si
         inc       si
         cmp       byte ptr ds:[si],0       ; je ©†dek 0 ?
         loopne    DispTm02
DispTm04:pop       si
         pop       cx
         je        DispTim2                 ; je menu s ©†dkem 0

         test      byte ptr ds:[WindPar],bit6 ; je editace souborñ ?
         jz        DispTim1                 ; nen° editace souborñ
         test      byte ptr ds:[EditPar2],bit7 ; zobraz° se áas ?
         jz        DispTm12                 ; áas se nezobraz°
         jmp       short DispTim2           ; jinak se zobraz°

DispTim1:call      far ptr TestRAWn         ; test, zda je pravÇ okno zobrazeno
         jnc       DispTim2
DispTm12:ret                                ; pravÇ okno nezobrazeno - nen° áas

; ------ £schova registrñ

DispTim2:push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,10*2                  ; vytvo©en° bufferu v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         call      far ptr GetRAWin         ; adresa pravÇho okna

; ------ dek¢dov†n° £daje áasu

         mov       dh,0                     ; ©†dek k zobrazen° áasu
         mov       dl,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       dl,8                     ; pozice k zobrazen° áasu
         mov       ah,ds:[ColTime]          ; barva textu áasu pro menu

         test      byte ptr ds:[HelpPar],bit4 ; je n†povàda ?
         jz        DispTm20                 ; nen° n†povàda
         cmp       byte ptr ds:[HelpMenu+MnuRad],0 ; je ©†dek 0 ?
         je        DispTm21                 ; je ©†dek 0

DispTm20:cmp       byte ptr ds:[NumMenu],0  ; je nàjakÇ menu ?
         je        DispT201                 ; nen° menu
         test      byte ptr ds:[ParMenu],bit1 ; je hlavn° menu ?
         jnz       DispT201                 ; zobrazeno hlavn° menu
         cmp       byte ptr ds:[PozMenu+1],0 ; je ©†dek 0 (pro prvn° menu) ?
         je        DispTm21                 ; je ©†dek 0

DispT201:test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ hlavn° menu ?
         jnz       DispTim4                 ; je trvalÇ hlavn° menu
         test      byte ptr ds:[ParMenu],bit3 ; p©echodnÇ vypnut° menu ?
         jnz       DispTim3                 ; p©echodnÇ vypnut° menu
         test      byte ptr ds:[ParMenu],bit1 ; je hlavn° menu ?
         jnz       DispTim4                 ; zobrazeno hlavn° menu

DispTm21:mov       ah,ds:[ColMnu1R]         ; bàën† barva menu - levò okraj r†mu
         mov       cx,ds:[NumMenu]          ; poáet menu
         jcxz      DispTim3                 ; nen° dal®° menu
         mov       si,cx                    ; SI <- poáet menu
         shl       si,1                     ; offset konce v tabulce menu
         dec       dx
DispTm22:dec       si
         dec       si
         cmp       byte ptr ds:[si+PozMenu+1],0 ; je ©†dek 0 ?
         jne       DispTm24                 ; nen° ©†dek 0

         mov       dl,byte ptr ds:[si+PozMenu] ; pozice menu
         add       dl,byte ptr ds:[si+SirMenu] ; konec menu
         sub       dl,9                     ; pozice k zobrazen° áasu
         mov       si,ds:[si+TabMenu]       ; adresa menu
         cmp       byte ptr ds:[si+MnuTyp],20 ; je to n†povàda ?
         jne       DispTim4                 ; nen° to n†povàda
         mov       ah,ds:[ColHlp9]          ; r†m - st°n
         jmp       short DispTim4

DispTm24:loop      DispTm22
         inc       dx

DispTim3:mov       ah,ds:[ColAWin3]         ; barva pro okno
         dec       dx
         test      byte ptr ds:[WindPar],bit6 ; je editace souborñ ?
         jnz       DispTim4                 ; je editace souborñ
         inc       dx

         mov       ah,ds:[ColLWin3]
         test      byte ptr es:[AWinPrm1],bit5 ; seznam ?
;         test      byte ptr ds:[ParamR],bit3
         jnz       DispTm32
         mov       ah,ds:[ColTWin3]
         test      byte ptr es:[AWinPrm1],bit4 ; strom ?
;         test      byte ptr ds:[ParamR],bit2
         jnz       DispTm32
DispTm31:mov       ah,ds:[ColAWin3]         ; barva pro okno

DispTm32:cmp       dl,71
         mov       dl,31                    ; pozice pro mÇnà neë 80 znakñ
         jb        DispTim4                 ; je mÇnà neë 80 znakñ na ©†dek
         mov       dl,ds:[Pozic]
         shr       dl,1
         add       dl,40-9

DispTim4:push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         call      far ptr DekSTime         ; dek¢dov†n° systÇmovÇho áasu

; ------ zobrazen° textu áasu

         mov       cl,8                     ; poáet znakñ
         mov       si,sp                    ; zaá†tek textu v bufferu
         mov       al,es:[si+7*2]           ; posledn° á°slice áasu
         mov       ah,al                    ; £schova á°slice
         xchg      al,ds:[LastTime]         ; uloëen° á°slice
         cmp       al,ah                    ; zmànila se á°slice ?
         mov       al,0
         je        DispTim5                 ; nebyla zmàna
;         xor       ax,ax
         mov       al,255                   ; maxim†ln° hladina k zobrazen°
         call      far ptr DispMStr         ; z†pis ©etàzce na displej

         call      far ptr KurzInv          ; p©°znak neplatnÇho kurzoru

; ------ £schova p©°znaku zmàny data

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[470h]             ; p©°znak p©eteáen° dne
         pop       ds

; ------ obsluha zobrazen° okna hodin

         test      byte ptr ds:[ParZvl],bit1 ; jsou zapnuty hodiny ?
         jz        DispTim5                 ; nejsou zapnuty hodiny

         mov       si,offset ZHMnuLin       ; menu - hodiny
;         push      cs
;         call      near ptr TestMnu         ; test, zda je menu otev©eno
;         jc        DispTim5                 ; menu nen° otev©eno
         push      cs
         call      near ptr DispMnu         ; obsluha zobrazen° hodin

; ------ test, zda byla zmàna data

DispTim5:push      ds
         xor       cx,cx
         mov       ds,cx
         or        al,ds:[470h]             ; je p©eteáen° dne ?
         pop       ds
         jz        DispTim8                 ; nen° zmàna data

; ------ test, zda m† bòt datum zobrazeno

         cmp       byte ptr ds:[NumMenu],1  ; je pouze hlavn° menu ?
         ja        DispTim8                 ; je v°ce menu - nen° áas
         je        DispTim6                 ; je pouze jedno menu
         test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ hlavn° menu ?
         jnz       DispTim7                 ; je trvalÇ hlavn° menu
         jmp       short DispTim8           ; jinak nezobrazeno
DispTim6:test      byte ptr ds:[ParMenu],bit3 ; p©echodnÇ vypnut° menu ?
         jnz       DispTim8                 ; p©echodnÇ vypnut° menu
         test      byte ptr ds:[ParMenu],bit1 ; je hlavn° menu ?
         jz        DispTim8                 ; nen° zobrazeno hlavn° menu

; ------ zobrazen° data

DispTim7:mov       ah,ds:[ColDate]          ; barva textu áasu pro menu
         mov       di,sp                    ; buffer v z†sobn°ku
         call      far ptr DekSDate         ; dek¢dov†n° data
         mov       dl,0                     ; poá†teán° pozice
         mov       cl,10                    ; dÇlka data
         mov       si,sp
         xor       ax,ax
         call      far ptr DispMStr         ; z†pis ©etàzce na displej

; ------ n†vrat registrñ

DispTim8:add       sp,10*2
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispTime ENDP

; *****************************************************************************
;                              SrcHotA
;                  nalezen° horkÇ kl†vesy menu s Alt-
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BL=hledanò ASCII znak
; VùSTUP:AX=á°slo nalezenÇ poloëky (1...)
;        CY=poloëka nenalezena (AX=pñvodn° aktivn° poloëka)
; *****************************************************************************

SrcHotA  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      di

; ------ test, zda je kl†vesa s Alt-

         cmp       bl,0
         stc                                ; p©°znak - nen° kl†vesa s Alt-
         jne       SrcHotA9                 ; nen° kl†vesa s ALT-

; ------ nalezen° SCAN k¢du kl†vesy v tabulce

         mov       di,offset TabScan        ; tabulka SCAN k¢dñ kl†ves s ALT-
SrcHotA2:cmp       bh,ds:[di]               ; souhlas° SCAN k¢d kl†vesy ?
         je        SrcHotA3                 ; kl†vesa nalezena OK
         inc       di
         inc       di
         cmp       byte ptr ds:[di],1       ; je jië konec tabulky ?
         jae       SrcHotA2                 ; nen° je®tà konec - dal®° poloëka
         jmp       short SrcHotA9           ; k¢d kl†vesy nenalezen

; ------ nalezen° horkÇ kl†vesy v menu

SrcHotA3:mov       bl,ds:[di+1]             ; ASCII hodnota znaku
         call      far ptr SrcHotM          ; nalezen° horkÇ kl†vesy v menu

; ------ n†vrat registrñ

SrcHotA9:pop       di
         pop       bx
         ret

SrcHotA  ENDP

; *****************************************************************************
;                                  SrcHotM
;                         nalezen° horkÇ kl†vesy menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BL=hledanò ASCII znak
; VùSTUP:AX=á°slo nalezenÇ poloëky (1...)
;        CY=poloëka nenalezena (AX=pñvodn° aktivn° poloëka)
; *****************************************************************************

SrcHotM  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si                       ; (SI mus° bòt posledn° !)

; ------ p©°prava registrñ

         cmp       bh,MousXKod/HI           ; je to k¢d my®i ?
         je        SrcHotM5                 ; je to my®
         mov       al,bl                    ; hledanò znak
         call      far ptr UpCase           ; p©evod na velkÇ p°smeno
         mov       ah,al                    ; £schova hledanÇho znaku
         xor       dx,dx                    ; ukazatel á°sla poloëky
         xor       bx,bx                    ; BX <- 0
         mov       cx,ds:[si+MnuSum]        ; celkovò poáet poloëek menu
         mov       si,ds:[si+MnuPol]        ; adresa definice poloëek menu
         jcxz      SrcHotM5                 ; nen° ë†dn† poloëka

; ------ test, zda je platn† poloëka

SrcHotM2:mov       bl,ds:[si+MnuParm]       ; parametry poloëky
         test      bl,bit6                  ; je to platn† poloëka ?
         jnz       SrcHotM4                 ; nen° poloëka - je text

; ------ porovn†n° horkÇho znaku jednÇ poloëky

         inc       dx                       ; zvò®en° ukazatele poloëky
         and       bl,not bit6 + bit7       ; pozice horkÇho znaku
         jz        SrcHotM4                 ; nen° horkò znak
         mov       al,ds:[si+bx+MnuTxt-1]   ; horkò znak
         call      far ptr UpCase           ; p©evod na velkÇ p°smeno
         cmp       al,ah                    ; je to hledanÇ p°smeno ?
         je        SrcHotM8                 ; poloëka nalezena OK

; ------ adresa dal®° poloëky

SrcHotM4:mov       bl,ds:[si+MnuDelk]       ; dÇlka textu poloëky
         inc       si
         inc       si                       ; adresa zaá†tku textu poloëky
         add       si,bx                    ; adresa dal®° poloëky
         loop      SrcHotM2                 ; test dal®° poloëky

; ------ poloëka nenalezena - n†vrat pñvodn° aktivn° poloëky

SrcHotM5:pop       si
         mov       dx,ds:[si+MnuAkt]        ; pñvodn° aktivn° poloëka
         push      si
         stc                                ; p©°znak - poloëka nenalezena

; ------ n†vrat registrñ

SrcHotM8:xchg      ax,dx                    ; AX <- á°slo nalezenÇ poloëky
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

SrcHotM  ENDP

; *****************************************************************************
;                                  GetSwch
;                       poskytnut° tabulky p©ep°naáñ
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; VùSTUP:DX=tabulka p©ep°naáñ
; *****************************************************************************

GetSwch  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ p©°prava registrñ

         xor       ax,ax                    ; AX <- 0
         mov       cx,ds:[si+MnuSum]        ; celkovò poáet poloëek menu
         mov       dx,8000h                 ; p©ednastaven°
         jcxz      GetSwch8                 ; nen° ë†dn† poloëka menu
         mov       bx,ds:[si+MnuSwch]       ; adresa tabulky p©ep°naáñ
         mov       si,ds:[si+MnuPol]        ; adresa definice poloëek
         or        bx,bx                    ; je tabulka p©ep°naáñ ?
         jz        GetSwch9                 ; nen° tabulka p©ep°naáñ

; ------ test poloëky, zda je to p©ep°naá

GetSwch1:test      byte ptr ds:[si+MnuParm],bit6 ; je to platn† poloëka ?
         jnz       GetSwch3                 ; nen° to platn† poloëka
         test      byte ptr ds:[si+MnuParm],bit7 ; je to p©ep°naá ?
         jz        GetSwch3                 ; nen° to p©ep°naá

; ------ nastaven° p©°znaku p©ep°naáe

         cmp       byte ptr ds:[bx],1       ; je p©ep°naá nastaven ?
         cmc                                ; CY=p©ep°naá je nastaven
         rcr       dx,1                     ; rotace p©°znaku
         jc        GetSwch9                 ; je jië 16 p©ep°naáñ
         inc       bx                       ; zvò®en° ukazatele v tabulce p©ep.

; ------ adresa dal®° poloëky

GetSwch3:mov       al,ds:[si+MnuDelk]       ; dÇlka textu poloëky
         inc       si
         inc       si                       ; zaá†tek textu poloëky
         add       si,ax                    ; adresa dal®° poloëky
         loop      GetSwch1                 ; dal®° poloëka

; ------ oprava tabulky p©ep°naáñ

GetSwch8:shr       dx,1                     ; rotace vpravo o 1 bit
         jnc       GetSwch8                 ; nen° je®tà p©°znak konce p©ep°naáñ

; ------ n†vrat registrñ

GetSwch9:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

GetSwch  ENDP

; *****************************************************************************
;                               SetSwch
;                    nastaven° tabulky p©ep°naáñ
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DX=tabulka p©ep°naáñ
; *****************************************************************************

SetSwch  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava registrñ

         xor       ax,ax                    ; AX <- 0
         mov       cx,ds:[si+MnuSum]        ; celkovò poáet poloëek menu
         jcxz      SetSwch9                 ; nen° ë†dn† poloëka menu
         mov       bx,ds:[si+MnuSwch]       ; adresa tabulky p©ep°naáñ
         mov       si,ds:[si+MnuPol]        ; adresa definice poloëek
         or        bx,bx                    ; je tabulka p©ep°naáñ ?
         jz        SetSwch9                 ; nen° tabulka p©ep°naáñ

; ------ test poloëky, zda je to p©ep°naá

SetSwch1:test      byte ptr ds:[si+MnuParm],bit6 ; je to platn† poloëka ?
         jnz       SetSwch3                 ; nen° to platn† poloëka
         test      byte ptr ds:[si+MnuParm],bit7 ; je to p©ep°naá ?
         jz        SetSwch3                 ; nen° to p©ep°naá

; ------ nastaven° p©°znaku p©ep°naáe

         mov       al,0                     ; st©adaá p©°znaku
         shr       dx,1                     ; rotace tabulky
         sbb       al,0                     ; je-li nastaven, je -1
         mov       ds:[bx],al               ; nastaven° p©°znaku p©ep°naáe
         inc       bx                       ; zvò®en° ukazatele v tabulce p©ep.

; ------ adresa dal®° poloëky

SetSwch3:mov       al,ds:[si+MnuDelk]       ; dÇlka textu poloëky
         inc       si
         inc       si                       ; zaá†tek textu poloëky
         add       si,ax                    ; adresa dal®° poloëky
         loop      SetSwch1                 ; dal®° poloëka

; ------ n†vrat registrñ

SetSwch9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetSwch  ENDP

; *****************************************************************************
;                                DispRamM
;              zobrazen° horn°ho a doln°ho okraje okna menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

DispRamM PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©°prava registrñ

         mov       ah,0
         mov       al,ds:[si+MnuLev]        ; AX <- vòstupn° hladina okna
         mov       bp,ax                    ; BP <- £schova á°sla hladiny okna
         mov       bx,word ptr ds:[si+MnuSir]        ; ®°©ka a vò®ka okna
         mov       ch,0
         mov       cl,bl                    ; ®°©ka okna
         sub       sp,cx
         sub       sp,cx                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       dx,word ptr ds:[si+MnuPoz]        ; pozice k zobrazen° okna
         cld

; ------ dek¢dov†n° horn° linky

         mov       ah,ds:[ColMnu1R]         ; bàën† barva menu - levò okraj r†mu
         cmp       byte ptr ds:[si+MnuTyp],20 ; n†povàda ?
         jne       DispRM02                 ; nen° n†povàda
         mov       ah,ds:[ColHlp9]          ; r†m - st°n
DispRM02:mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       al,"⁄"                   ; "⁄" levò horn° okraj okna menu

         push      ax

         stosw                              ; uloëen° levÇho horn°ho okraje
         mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         dec       cx
         dec       cx                       ; vnit©n° ®°©ka okna menu
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       al,"ø"                   ; "ø" pravò horn° roh okna menu
         mov       ah,ds:[ColMnu1L]
         cmp       byte ptr ds:[si+MnuTyp],20 ; n†povàda ?
         jne       DispRM03                 ; nen° n†povàda
         mov       ah,ds:[ColHlp8]          ; r†m - svàtlo
DispRM03:stosw                              ; uloëen° pravÇho horn°ho okraje

         pop       ax

; ------ dek¢dov†n° áasu, je-li prvn° ©†dek

         cmp       byte ptr ds:[si+MnuRad],0 ; je ©†dek 0 ?
         jne       DispRmM1                 ; nen° ©†dek 0
         cmp       byte ptr ds:[si+MnuSir],30 ; je dost velk† ®°©ka ?
         jb        DispRmM1                 ; je mal† ®°©ka

         test      byte ptr ds:[ParInt24],bit3 ; je z†kaz DOS ?
         jnz       DispRmM0                 ; je z†kaz DOS

         push      di
         mov       di,sp
         add       di,2 + 2                 ; 1 pozice + z†sobn°k DI
         call      far ptr DekDDat0         ; dek¢dov†n° systÇmovÇho data (bez konverze)
         pop       di

DispRmM0:push      di
         sub       di,9*2
         mov       byte ptr es:[di-2]," "   ; £vodn° mezera
         call      far ptr DekSTime         ; dek¢dov†n° systÇmovÇho áasu
         pop       di

; ------ korekce ukl†dac° adresy, aby byl titul uprost©ed

         push      ax

         mov       al,bl                    ; AL <- ®°©ka okna
         mov       ah,0
         sub       al,4                     ; odeáten° okrajñ
         push      si
         mov       si,ds:[si+MnuTitl]       ; titul okna
         sub       al,ds:[si]               ; odeáten° dÇlky titulu
         pop       si
         or        si,si                    ; je titul ?
         jz        DispRM06                 ; nen° titul
         and       al,not bit0              ; zarovn†n°
         sub       di,ax                    ; korekce ukl†dac° adresy

DispRM06:pop       ax

; ------ dek¢dov†n° titulu menu (AH=barva r†mu)

DispRmM1:push      si
         push      ax

         mov       ah,ds:[ColMnu1R]         ; bàën† barva menu - levò okraj r†mu
         cmp       byte ptr ds:[si+MnuTyp],20 ; n†povàda ?
         jne       DispRM12                 ; nen° n†povàda
         mov       ah,ds:[ColHlpA]          ; r†m - titulek

DispRM12:mov       si,ds:[si+MnuTitl]       ; titul menu
         or        si,si                    ; je titul definov†n ?
         jz        DispRmM3                 ; titul nen° definov†n
         lodsb                              ; dÇlka textu titulu
         mov       cl,al                    ; dÇlka textu titulu
         jcxz      DispRmM3                 ; nen° titul
         add       al,4                     ; p©iáten° okrajñ
         cmp       al,bl                    ; je titul p©°li® dlouhò ?
         ja        DispRmM3                 ; titul je p©°li® dlouhò
         sub       di,cx
         sub       di,cx                    ; odeáten° dÇlky pro titul
         sub       di,3*2                   ; odeáten° okrajñ
         mov       al," "                   ; £vodn° mezera
         stosw                              ; uloëen° £vodn° mezery
DispRmM2:lodsb                              ; znak titulu k zobrazen°
         stosw                              ; uloëen° znaku titulu
         loop      DispRmM2                 ; dal®° znak titulu
         mov       al," "                   ; z†vàreán† mezera
         stosw                              ; uloëen° z†vàreánÇ mezery

DispRmM3:pop       ax
         pop       si

; ------ korekce pro kalend†©

         cmp       byte ptr ds:[si+MnuTyp],8 ; je kalend†© ?
         jne       DispRmM4                 ; nen° kalend†©
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       byte ptr es:[di+2*37],"¬" ; dàl°c° á†ra

; ------ test, zda se zobraz° á°slo znaku pod kurzorem ©†dkovÇho menu

DispRmM4:cmp       byte ptr ds:[si+MnuTyp],3 ; je ©†dkovÇ menu ?
         jne       DispRmM5                 ; nen° ©†dkovÇ menu
         cmp       word ptr ds:[si+LMnuDis],0 ; jsou editovanÇ ©†dky ?
         je        DispRmM5                 ; nejsou editovanÇ ©†dky
         cmp       word ptr ds:[si+MnuAkt],1 ; jsou ©†dky aktivn° ?
         jne       DispRmM5                 ; ©†dky nejsou aktivn°
         cmp       byte ptr ds:[LinTop],-1  ; zapoáata editace ©†dku ?
         je        DispRmM5                 ; nen° editace ©†dku

; ------ dek¢dov†n° pozice kurzoru

         mov       di,sp                    ; buffer v z†sobn°ku
         inc       di
         inc       di                       ; adresa k dek¢dov†n° á°sla znaku

         push      bx

         mov       al," "
         stosw                              ; uloëen° £vodn° mezery
         xchg      ax,bx

         mov       al,ds:[LinKur]           ; pozice kurzoru
         mov       ah,0
         inc       ax                       ; korekze pozice
         call      far ptr DekNumW          ; dek¢dov†n° pozice kurzoru

         xchg      ax,bx                    ; n†vrat znaku mezery
         cld
         stosw                              ; uloëen° znaku mezery

         pop       bx

; ------ dek¢dov†n° á°sla znaku pod kurzorem

         mov       al,ds:[LinKur]           ; kurzor na ©†dku
         cmp       al,ds:[LinNum]           ; je kurzor na platnÇm znaku ?
         jae       DispRmM5                 ; kurzor nen° na platnÇm znaku

         push      si
         push      bx

         mov       si,ax                    ; kurzor na ©†dku
         and       si,0ffh                  ; offset kurzoru na ©†dku

         mov       al,"("
         stosw                              ; uloëen° £vodn° mezery

         mov       al,ds:[si+LinBuff]       ; buffer textu ©†dku
         call      far ptr DekNumB          ; dek¢dov†n° á°sla znaku

         cld
         mov       al,")"
         stosw                              ; uloëen° z†vàreánÇ mezery
         mov       al," "
         stosw                              ; koncov† mezera

         pop       bx
         pop       si

; ------ zobrazen° horn° linky okna menu

DispRmM5:mov       ax,sp                    ; AX <- buffer v z†sobn°ku
         push      si
         xchg      ax,si                    ; SI <- buffer v z†sobn°ku
         mov       cl,bl                    ; ®°©ka okna
         mov       ax,bp                    ; vòstupn° hladina k zobrazen°
         call      far ptr DispKStr         ; zobrazen° horn° linky okna
         pop       si
         sub       dl,bl                    ; n†vrat poá†teán° pozice okna

; ------ p©°prava registrñ pro doln° linku menu

         add       dh,bh                    ; + vò®ka
         dec       dh                       ; posledn° ©†dek okna
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         cld

; ------ dek¢dov†n° doln° linky

         mov       ah,ds:[ColMnu1R]         ; bàën† barva menu
         cmp       byte ptr ds:[si+MnuTyp],20 ; n†povàda ?
         jne       DispRM50                 ; nen° n†povàda
         mov       ah,ds:[ColHlp9]          ; r†m - st°n

DispRM50:mov       al,"¿"                   ; "¿" levò doln° okraj okna menu
         stosw                              ; uloëen° levÇho doln°ho okraje

         mov       ah,ds:[ColMnu1L]         ; pravò okraj
         cmp       byte ptr ds:[si+MnuTyp],20 ; n†povàda ?
         jne       DispRM51                 ; nen° n†povàda
         mov       ah,ds:[ColHlp8]          ; r†m - svàtlo

DispRM51:mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         dec       cx
         dec       cx                       ; vnit©n° ®°©ka okna menu
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       al,"Ÿ"                   ; "Ÿ" pravò doln° roh okna menu
         stosw                              ; uloëen° pravÇho doln°ho okraje

; ------ korekce pro kalend†©

         cmp       byte ptr ds:[si+MnuTyp],8 ; je kalend†© ?
         jne       DispR512                 ; nen° kalend†©
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       byte ptr es:[di+2*37],"¡" ; dàl°c° á†ra

; ------ test, zda je menu disku

DispR512:cmp       byte ptr ds:[si+MnuTyp],4 ; je menu volby disku ?
         je        DispRm55

; ------ dek¢dov†n° ©†dku pro ASCII tabulku

         cmp       byte ptr ds:[si+MnuTyp],5 ; je to ASCII tabulka ?
         jne       DispRm52                 ; nen° to ASCII tabulka
         mov       di,sp
         call      DispRMA                  ; inicializace pro ASCII tabulku
DispRm52:cmp       byte ptr ds:[si+MnuTyp],20 ; je to n†povàda ?
         jne       DspRm522                 ; nen° to n†povàda
         mov       di,sp
         call      DispRMH                  ; korekce pro n†povàdu
DspRm522:cmp       byte ptr ds:[si+MnuTyp],9 ; je vòbàr souborñ ?
         jne       DispRm53                 ; nen° vòbàr souborñ
         mov       di,sp
         call      DispRMS                  ; inicializace pro vòbàr souborñ
DispRm53:cmp       byte ptr ds:[si+MnuTyp],7 ; je to tabulkovò kalkul†tor ?
         je        DspRm532                 ; tabulkovò kalkul†tor
         cmp       byte ptr ds:[si+MnuTyp],16 ; je editor textñ ?
         jne       DispRm54
DspRm532:mov       di,sp
         call      DispRME                  ; korekce pro editor
DispRm54:jmp       DispRmM9                 ; nen° menu volby disku

; ------ adresa koment†©e

DispRm55:mov       ax,ds:[DiskInfS]         ; á°slo bufferu
         call      far ptr GetDat           ; adresa bufferu
         mov       di,ds:[DiskInfA]         ; adresa koment†©e

; ------ dÇlka koment†©e

         mov       cl,es:[di]               ; dÇlka textu koment†©e
         mov       ch,0
         inc       di                       ; zaá†tek textu koment†©e
         jcxz      DispRm54                 ; nen° ë†dnò text

; ------ omezen° dÇlky textu

         mov       ah,0
         mov       al,bl                    ; ®°©ka okna
         sub       al,4                     ; odeáten° okrajñ
         cmp       cx,ax                    ; p©ekroáena dÇlka ©†dku ?
         jb        DispRm85                 ; dÇlka textu je OK
         mov       cx,ax                    ; omezen° dÇlky textu

; ------ adresa v bufferu k uloëen° textu

DispRm85:add       al,4-2                   ; n†vrat okrajñ - 2 mezery
         sub       al,cl                    ; zbytek na okraje
         mov       bh,al                    ; zbytek na okraje
         shr       bh,1                     ; offset poá†tku textu
         and       al,not 1                 ; zarovn†n° na sudou adresu
         add       ax,sp                    ; AX <- adresa v bufferu

; ------ p©enesen° textu do bufferu

         push      si
         push      dx

         add       dl,bh
         inc       dx

         xchg      ax,si                    ; SI <- adresa k uloëen° do bufferu
         mov       ah,ds:[ColMnu1]
         mov       al,"{"
         mov       ss:[si],ax               ; £vodn° mezera
         inc       si
         inc       si
         jcxz      DispRm88
         mov       ah,ds:[ColMnu2]          ; barva textu
DispRm86:mov       al,es:[di]               ; znak textu
         mov       ss:[si],ax
         cmp       di,ds:[DiskInfK]         ; je to kurzor ?
         jne       DispRm87                 ; nen° to kurzor
         test      byte ptr ds:[DiskInfP],bit1
         jz        DispRm87                 ; nen° editace
         call      far ptr SetKurz          ; zobrazen° kurzoru
DispRm87:inc       di
         inc       si
         inc       si
         inc       dx
         loop      DispRm86

DispRm88:cmp       di,ds:[DiskInfK]         ; je to kurzor ?
         jne       DispRm89                 ; nen° to kurzor
         test      byte ptr ds:[DiskInfP],bit1
         jz        DispRm89                 ; nen° editace
         call      far ptr SetKurz          ; zobrazen° kurzoru

DispRm89:mov       ah,ds:[ColMnu1]
         mov       al,"}"
         mov       ss:[si],ax               ; koncov† mezera

         pop       dx
         pop       si

; ------ zobrazen° doln° linky okna menu

DispRmM9:push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,bl                    ; ®°©ka okna
         mov       ax,bp                    ; vòstupn° hladina k zobrazen°
         push      cs
         call      near ptr DispKStr        ; zobrazen° doln° linky okna

; ------ n†vrat registrñ

         mov       ch,0
         add       sp,cx
         add       sp,cx                    ; n†vrat ukazatele z†sobn°ku
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispRamM ENDP

; -----------------------------------------------------------------------------
;        korekce spodn°ho ©†dku ES:DI pro ASCII tabulku (je CLD)
; -----------------------------------------------------------------------------

DispRMA  PROC      NEAR

         add       di,9*2
         test      byte ptr ds:[AscTbSw2],bit0 ; jsou barvy ?
         jz        DispRMA1                 ; nejsou
         add       di,8*2
DispRMA1:mov       ax,"0"
DispRMA2:stosw
         inc       ax
         cmp       al,"9"+1
         jne       DispRMA3
         mov       al,"A"
DispRMA3:inc       ah
         cmp       al,"F"+1
         jne       DispRMA2
         ret

DispRMA  ENDP

; -----------------------------------------------------------------------------
;        korekce spodn°ho ©†dku ES:DI pro vòbàr souborñ (je CLD)
; -----------------------------------------------------------------------------

DispRMS  PROC      NEAR

         push      ax

         mov       al,"¡"
         mov       byte ptr es:[di+2*11],al ; "¡" spoj áar

         push      bx
         push      cx
         push      dx
         push      si

; ------ dek¢dov†n° rychlovyhled†v†n°

         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jz        DispRMS0                 ; nen° rychlovyhled†v†n°

         push      di
         push      si
         cld
         mov       si,offset QSrcBuff       ; buffer rychlovyhled†v†n°
         inc       di
         inc       di
         mov       ah,ds:[ColMnu1]          ; bàën† barva okna
         mov       al,"["
         stosw
         push      di
         mov       cx,8
         mov       al,"."
         rep       stosw
         mov       al,"]"
         stosw
         pop       di
         mov       cl,8
         cmp       cl,ds:[QSrcNum]
         jbe       DspRMS02
         mov       cl,ds:[QSrcNum]
         jcxz      DspRMS03
DspRMS02:lodsb
         stosw
         loop      DspRMS02

DspRMS03:pop       si
         pop       di

; ------ dek¢dov†n° data souboru

DispRMS0:
;         push      si
;         push      di
         push      ds

         push      ds
         mov       ax,ds:[si+SMnuSeg]       ; datovò segment souborñ
         call      far ptr GetSgAdr         ; adresa segmentu
         mov       ah,ds:[ColMnu1]
         mov       ds,dx                    ; DS <- segment okna
         pop       dx                       ; DX <- datovò segment

         add       di,2*13                  ; adresa k dek¢dov†n° data
         mov       bx,ds:[AWinKurz]         ; kurzor
         push      es
         push      ds
         pop       es
         call      far ptr GetESPol
         push      es
         pop       ds
         pop       es
         jc        DispRMS1                 ; nen° platn† poloëka
         test      byte ptr ds:[si+FileAtr],DIR ; je to adres†© ?
         jnz       DispRMS1                 ; je to adres†©

         mov       byte ptr es:[di-2]," "   ; £vodn° mezera
         call      far ptr DekA4Dat         ; dek¢dov†n° data
         mov       byte ptr es:[di]," "     ; koncov† mezera

         add       di,2*33
         mov       byte ptr es:[di-2]," "   ; £vodn° mezera
         call      far ptr DekATim          ; dek¢dov†n° áasu
         mov       byte ptr es:[di]," "     ; koncov† mezera

DispRMS1:pop       ds
;         pop       di
;         pop       si

;; ------ adresa k dek¢dov†n° volnÇho m°sta
;
;         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
;         mov       ah,0
;         sub       al,5                     ; mezera pro text na konci
;         shl       ax,1
;         add       di,ax                    ; adresa konce bufferu
;
;         push      es
;         mov       ax,ds:[si+SMnuSeg]       ; datovò segment souborñ
;         call      far ptr GetDat           ; adresa segmentu
;         mov       si,word ptr es:[AWinDFre] ; voln† kapacita LOW
;         mov       ax,word ptr es:[AWinDFre+2] ; voln† kapacita HIGH
;         pop       es
;         jc        DispRMS6
;
;         mov       bx,1000                  ; dàlitel
;         xor       dx,dx                    ; DX <- 0
;         div       bx                       ; vydàlen° volnÇ kapacity HIGH
;         xchg      ax,si                    ; voln† kapacita LOW
;         div       bx                       ; vydàlen° volnÇ kapacity LOW
;         mov       dx,si                    ; voln† kapacita HIGH
;
;         mov       byte ptr es:[di]," "
;         mov       byte ptr es:[di+2],"K"
;         mov       byte ptr es:[di+4],"B"   ; oznaáen° "KB"
;         mov       byte ptr es:[di+6]," "
;
;;         mov       bl,ds:[OddelRad]         ; oddàlovaá ©†dñ
;         mov       bl,0
;         mov       bh,ds:[ColMnu1]          ; bàën† barva menu
;         call      far ptr DekNumD          ; dek¢dov†n° á°sla do bufferu
;
;DispRMS3:dec       di
;         dec       di
;         cmp       byte ptr es:[di-2],128   ; "ƒ"
;         jb        DispRMS3                 ; nalezen° zaá†tku á°sla
;
;         mov       si,offset VolDTxt1
;         sub       di,offset(VolDTxt2-VolDTxt1)*2
;         mov       cx,offset(VolDTxt2-VolDTxt1)
;         cld
;DispRMS4:movsb
;         inc       di
;         loop      DispRMS4

DispRMS6:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispRMS  ENDP

; -----------------------------------------------------------------------------
;        korekce spodn°ho ©†dku ED:DI pro n†povàdu (je CLD)
; -----------------------------------------------------------------------------

DispRMH  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      si

         mov       bx,ds:[HlpAStrn]         ; aktivn° str†nka
         inc       bx                       ; korekce á°sla str†nky + 1
         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         mov       ah,0
         sub       ax,14                    ; asi tak odsun
         cmp       bx,1000                  ; je 1000 a v°ce ?
         jae       DispRMH1                 ; je 1000 a v°ce
         inc       ax                       ; zkr†cen° o pozici
         cmp       bx,100                   ; je 100 a v°ce ?
         jae       DispRMH1                 ; je 100 a v°ce
         inc       ax                       ; zkr†cen° o pozici
         cmp       bl,10                    ; je 10 a v°ce ?
         jae       DispRMH1                 ; je 10 a v°ce
         inc       ax                       ; zkr†cen° o pozici

DispRMH1:shl       ax,1
         add       di,ax

         mov       ah,ds:[ColHlp9]          ; r†m - st°n
         mov       si,offset StrnHTxt       ; text
         mov       cx,offset(StrnHTx0-StrnHTxt) ; dÇlka textu
DispRMH2:lodsb
         stosw
         loop      DispRMH2

         mov       al,0                     ; nen° oddàlvaá ©†dñ
         xchg      ax,bx                    ; BH <- barva, AX <- aktivn° str†nka
         call      far ptr DekNumW          ; dek¢dov†n° á°sla str†nky
         xchg      ax,bx
         cld
         mov       al," "
         stosw                              ; koncov† mezera

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispRMH  ENDP

; -----------------------------------------------------------------------------
;        korekce spodn°ho ©†dku ES:DI pro editor (je CLD)
; -----------------------------------------------------------------------------

DispRME  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      si

         mov       al,ds:[si+MnuSir]        ; ®°©ka okna
         mov       ah,0
         sub       ax,17                    ; asi tak odsun
         shl       ax,1
         add       di,ax

         push      si
         mov       ah,ds:[ColMnu1]
         mov       si,offset VolETxt1
         mov       cx,offset(VolETxt2-VolETxt1)
DispRME1:lodsb
         stosw
         loop      DispRME1
         pop       si

         call      far ptr GetDFree         ; voln† kapacita
         push      es
         mov       ax,ds:[si+EdMnuSeg]
         call      far ptr GetDat
         mov       ax,es:[0]                ; velikost bufferu
         add       ax,bx
         jnc       DispRME2
         mov       ax,-1
DispRME2:cmp       ax,-512                  ; asi tak je®tà rezerva
         jbe       DspRME24                 ; je to OK
         mov       ax,-512                  ; omezen° konce pamàti

DspRME24:sub       ax,es:[0]
         jnc       DspRME26
         xor       ax,ax                    ; oprava p©i p©eteáen°
DspRME26:pop       es

         mov       bl,0
         mov       bh,ds:[ColMnu1]
         call      far ptr DekNumW

         cld
         mov       ah,ds:[ColMnu1]
         mov       si,offset VolETxt2
         mov       cx,3
DispRME3:lodsb
         stosw
         loop      DispRME3

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispRME  ENDP

; *****************************************************************************
;                               DispCarM
;                zobrazen° oddàlovac° á†ry v oknà menu
; -----------------------------------------------------------------------------
; VSTUP: AX=vòstupn° hladina k zobrazen° menu
;        CL=®°©ka okna menu
;        DL=pozice k zobrazen° á†ry
;        DH=©†dek k zobrazen° á†ry
;        DS=datovò segment
; *****************************************************************************

DispCarM PROC      FAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en° bufferu v z†sobn°ku

         mov       ch,0                     ; CX = ®°©ka okna menu
         sub       sp,cx
         sub       sp,cx                    ; vytvo©en° bufferu v z†sobn°ku
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es
         cld

; ------ dek¢dov†n° oddàlovac° á†ry

         push      ax
         push      cx
         mov       ah,ds:[ColMnu1R]         ; bàën† barva menu
         mov       al,"√"                   ; "√" levò okraj
         stosw
         mov       ah,ds:[ColMnu1]
         mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         dec       cx
         dec       cx                       ; vnit©n° ®°©ka okna menu
         rep       stosw
         mov       al,"¥"                   ; "¥" pravò okraj
         mov       ah,ds:[ColMnu1L]
         stosw
         pop       cx
         pop       ax

; ------ zobrazen° oddàlovac° á†ry

         mov       si,sp                    ; dek¢dovanò text
         push      cs
         call      near ptr DispKStr        ; zobrazen° ©etàzce

; ------ n†vrat registrñ

         add       sp,cx
         add       sp,cx
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

DispCarM ENDP

; *****************************************************************************
;                              DispTxtM
;         zobrazen° textovÇho ©†dku menu (bez posunu ukazatele menu)
; -----------------------------------------------------------------------------
; VSTUP: AX=vòstupn° hladina k zobrazen° menu
;        CL=®°©ka okna menu (minim†lnà 2 !)
;        DL=pozice k zobrazen° textu
;        DH=©†dek k zobrazen° textu
;        DS:SI=definice poloëky
;        DS=datovò segment
; 0=zmàna barvy, 1=vno©enò text (n†sleduje slovo=adresa ©etàzce s dÇlkou 1 bajt),
; 2=mezery (n†sleduje bajt=poáet mezer), 3=vno©enò text (n†sleduje bajt dÇlky
; a dvojslovo adresy), 4=p©ep°naá k¢dov†n° fontñ
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) vòstupn° hladina k zobrazen° menu
;                   SS:[BP-4] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-5] (1) vnit©n° znak mezery nebo á†ry
;                   SS:[BP-6] (1) ®°©ka okna
;                   SS:[BP-7] (1) levò okraj
;                   SS:[BP-8] (1) pravò okraj
;                   SS:[BP-10] (2) segment k¢dovac° tabulky fontñ
; *****************************************************************************
;˛
DispTxtM PROC      FAR

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

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,10
         mov       ss:[bp-2],ax             ; vòstupn° hladina k zobrazen°
         mov       ss:[bp-4],dx             ; pozice a ©†dek k zobrazen°
         mov       word ptr ss:[bp-8],"≥≥"  ; levò a pravò okraj, je-li mezera
         mov       ch," "                   ; mezera
         test      byte ptr ds:[si+MnuParm],bit7 ; je oddàlovac° á†ra ?
         jz        DispTxM1                 ; nen° oddàlovac° á†ra
         mov       word ptr ss:[bp-8],"√¥"  ; levò a pravò okraj, je-li á†ra
         mov       ch,"ƒ"                   ; znak oddàlovac° á†ry
DispTxM1:mov       ss:[bp-6],cx             ; ®°©ka okna a znak mezery
         mov       ch,0                     ; CX = ®°©ka okna menu
         sub       sp,cx
         sub       sp,cx
         sub       sp,cx
         sub       sp,cx                    ; vytvo©en° bufferu v z†sobn°ku
         mov       bx,ds:[KodFntTb]         ; adresa k¢dovac° tabulky
         mov       word ptr ss:[bp-10],SEG CodeDek ; segment k¢dovac° tabulky

; ------ p©°prava k dek¢dov†n° textu (CL=®°©ka ©†dku okna, CH=0)

         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld
         mov       dl,cl                    ; DL <- ®°©ka ©†dku okna
         dec       dx
         dec       dx                       ; DL <- maxim†ln° dÇlka textu
         inc       si
         mov       cl,ds:[si+MnuDelk-1]     ; CL <- dÇlka textu poloëky
         inc       si                       ; SI <- zaá†tek textu poloëky
         mov       ah,ds:[ColMnu1]          ; AH <- bàën† barva textu
         mov       dh,ds:[ColMnu2]          ; DH <- zvòraznàn† barva textu

; ------ naáten° dal®°ho znaku

DispTxM2:jcxz      DispTxM8                 ; nen° dal®° znak k dek¢dov†n°
         lodsb                              ; znak textu
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ

; ------ 0: p©ep°naá zmàny barvy

         cmp       al,0                     ; je p©ep°naá barvy ?
         jne       DispTxM3                 ; nen° p©ep°naá barvy
         xchg      ah,dh                    ; zmàna barvy
         jmp       short DispTxM2           ; dal®° znak

; ------ 1: dek¢dov†n° vno©enÇho textu (k¢d 1)

DispTxM3:cmp       al,1                     ; je vno©enò parametr ?
         jne       DispTxM4                 ; nen° vno©enò parametr

         push      cx                       ; á°taá zbylòch znakñ
         push      si                       ; ukazatel textu

         mov       si,ds:[si]               ; SI <- adresa textu
         lodsb                              ; AL <- dÇlka textu
         mov       cl,al                    ; CL <- dÇlka textu

DspTxM32:jcxz      DspTxM36                 ; nen° dal®° znak
         lodsb                              ; znak textu
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al,0                     ; je p©ep°naá barvy ?
         jne       DspTxM34                 ; nen° p©ep°naá barvy
         xchg      ah,dh                    ; zmàna barvy
         jmp       short DspTxM32           ; dal®° znak

DspTxM34:call      DispTxtU                 ; uloëen° znaku AL
         jmp       short DspTxM32           ; dal®° znak

DspTxM36:pop       si
         pop       cx

         inc       si
         inc       si                       ; p©eskoáen° adresy textu
         dec       cx
DspTxM38:dec       cx
         jmp       short DispTxM2           ; dal®° znak

; ------ 2: dek¢dov†n° mezer (k¢d 2)

DispTxM4:cmp       al,2                     ; jsou mezery ?
         jne       DispTxM5                 ; nejsou mezery

         lodsb                              ; poáet mezer
         push      cx
         mov       cl,al                    ; poáet mezer
         mov       al," "                   ; znak mezery

         jcxz      DspTxM44                 ; nejsou dal®° mezery

DspTxM42:call      DispTxtU                 ; uloëen° znaku AL
         loop      DspTxM42

DspTxM44:pop       cx
         jmp       short DspTxM38

; ------ 3: dek¢dov†n° vno©enÇho textu s adresac° 2slovo (k¢d 3)
; (Neobsluhovat p©ep°naáe barvy - pouë°v† se nap©. k zobrazen° hledanÇho textu)

DispTxM5:cmp       al,3
         jne       DispTxM6

         push      si
         push      cx
         push      ds

         mov       cl,ds:[si]               ; CL <- dÇlka textu
         lds       si,ds:[si+1]             ; DS:SI <- adresa textu

         jcxz      DspTxM54                 ; nen° dal®° znak
DspTxM52:lodsb                              ; naáten° znaku
         call      DispTxtU                 ; uloëen° znaku AL
         loop      DspTxM52                 ; dal®° znak

DspTxM54:pop       ds
         pop       cx
         pop       si

         add       si,5                     ; zvò®en° ukazatele textu
         sub       cx,5                     ; sn°ëen° á°taáe dÇlky dat
         jmp       short DispTxM2

; ------ 4 = p©ep°naá k¢dov†n° znakñ

DispTxM6:cmp       al,4
         jne       DispTxM7                 ; nen° p©ep°naá k¢dov†n° znakñ
         xor       bx,ds:[KodFntTb]         ; zmàna k¢dovac° tabulky
         jmp       short DispTxM2

; ------ uloëen° bàënÇho znaku

DispTxM7:call      DispTxtU                 ; uloëen° znaku AL
         jmp       short DispTxM2

; ------ dÇlka dek¢dovanÇho textu -> CX

DispTxM8:mov       si,sp                    ; buffer v z†sobn°ku
         sub       di,si                    ; dÇlka textu * 2
         shr       di,1                     ; dÇlka textu
         mov       cx,di                    ; CX <- dÇlka dek¢dovanÇho textu

; ------ adresa druhÇho bufferu v z†sobn°ku -> DI

         mov       dh,0
         mov       dl,ss:[bp-6]             ; DX <- ®°©ka okna
         mov       di,si                    ; DI <- prvn° buffer v z†sobn°ku
         add       di,dx
         add       di,dx                    ; druhò buffer v z†sobn°ku

; ------ vymaz†n° ©†dku v bufferu

         push      di                       ; zaá†tek druhÇho bufferu
         push      cx                       ; dÇlka dek¢dovanÇho textu
         mov       cl,dl                    ; ®°©ka okna menu
         mov       ah,ds:[ColMnu1R]         ; bàën† barva textu
         mov       al,ss:[bp-7]             ; "√" levò okraj
         stosw
         mov       ah,ds:[ColMnu1]
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       al,ss:[bp-5]             ; vnit©n° znak mezery nebo á†ry
         rep       stosw                    ; vymaz†n° ©†dku
         mov       al,ss:[bp-8]             ; "¥" pravò okraj
         mov       ah,ds:[ColMnu1L]
         stosw                              ; pravò okraj
         pop       cx                       ; dÇlka dek¢dovanÇho textu
         pop       di                       ; zaá†tek druhÇho bufferu

; ------ p©enesen° textu do bufferu

         push      di                       ; zaá†tek druhÇho bufferu
         push      ds

         push      ss
         pop       ds                       ; DS <- segment bufferu 1
         mov       ax,dx                    ; AX <- ®°©ka okna
         sub       ax,cx                    ; zbytek na okraje ©†dku
         and       al,not 1                 ; zarovn†n°
         add       di,ax                    ; adresa k uloëen° textu
         rep       movsw                    ; p©enos textu do bufferu

         pop       ds
         pop       si                       ; zaá†tek druhÇho bufferu

; ------ zobrazen° textu

         mov       cx,dx                    ; ®°©ka okna menu
         mov       ax,ss:[bp-2]             ; vòstupn° hladina k zobrazen°
         mov       dx,ss:[bp-4]             ; pozice a ©†dek k zobrazen°
         call      far ptr DispMStr         ; zobrazen° textu

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

DispTxtM ENDP

; ------ uloëen° znaku AL

DispTxtU:or        dl,dl                    ; je dal®° m°sto ?
         jz        DispTxU8                 ; nen° dal®° m°sto

         cmp       al,128                   ; k¢duje se znak ?
         jb        DispTxU6                 ; nek¢duje se
         or        bx,bx                    ; je k¢dovac° tabulka ?
         jz        DispTxU6                 ; nen° k¢dovac° tabulka

         push      ds
         sub       al,128
         mov       ds,ss:[bp-10]            ; segment k¢dovac° tabulky
         xlat                               ; konverze znaku
         pop       ds

DispTxU6:stosw                              ; uloëen° znaku
         dec       dx                       ; sn°ëen° á°taáe znakñ
DispTxU8:ret

; *****************************************************************************
;                                  DispTxtR
;                     zobrazen° v°ce textovòch ©†dkñ menu
; -----------------------------------------------------------------------------
; VSTUP: AX=vòstupn° hladina k zobrazen° menu
;        BX=zbylò poáet poloëek menu
;        CL=®°©ka okna menu
;        DL=pozice k zobrazen° textu
;        DH=©†dek k zobrazen° textu
;        DS:SI=definice poloëky
;        DS=datovò segment
; VùSTUP:BX=novò zbylò poáet poloëek menu
;        DH=novò ©†dek
;        DS:SI=adresa dal®° poloëky
; *****************************************************************************

DispTxtR PROC      FAR

; ------ test, zda je dal®° ©†dek k zobrazen°

         or        bx,bx                    ; je nàjak† dal®° poloëka ?
         jz        DispTxR9                 ; nezbyla dal®° poloëka
DispTxR1:test      byte ptr ds:[si+MnuParm],bit6 ; je textov† poloëka ?
         jz        DispTxR9                 ; nen° dal®° textov† poloëka

; ------ zobrazen° textovÇho ©†dku

         call      far ptr DispTxtM         ; zobrazen° jednoho ©†dku textu

; ------ adresa dal®° poloëky menu

         push      ax
         mov       ah,0
         mov       al,ds:[si+MnuDelk]       ; dÇlka textu poloëky
         inc       si
         inc       si                       ; zaá†tek textu poloëky
         add       si,ax                    ; adresa dal®° poloëky
         pop       ax

; ------ dal®° poloëka menu

         inc       dh                       ; zvò®en° ukazatele na displeji
         dec       bx                       ; sn°ëen° á°taáe zbylòch poloëek
         jnz       DispTxR1                 ; zobrazen° dal®° poloëky

DispTxR9:ret

DispTxtR ENDP

; *****************************************************************************
;                              DispKStr
;             Zobrazen° textovÇho ©etàzce s p©ek¢dov†n°m fontñ
; -----------------------------------------------------------------------------
; VSTUP:  AL=po©adovÇ á°slo menu - hladina pro zobrazen° (0=podklad+okna)
;         CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (1 znak = 2 bajty = znak a atribut)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispKStr PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ p©°prava registrñ

         mov       ch,0                     ; CX = poáet znakñ ©etàzce
         jcxz      DispKSt9                 ; nen° ë†dnò znak
         mov       bx,ds:[KodFntTb]         ; adresa k¢dovac° tabulky
         or        bx,bx                    ; prov†d° se konverze ?
         jz        DispKSt9                 ; konverze se neprov†d°

; ------ p©ek¢dov†n° ©etàzce

         push      ds
         mov       ax,SEG CodeDek
         mov       ds,ax                    ; DS <- segment k¢dovac° tabulky
DispKSt7:mov       al,es:[si]               ; znak k p©ek¢dov†n°
         sub       al,128                   ; je to n†rodn° k¢d ?
         jc        DispKSt8                 ; nen° to n†rodn° k¢d
         xlat                               ; p©ek¢dov†n° znaku
         mov       es:[si],al               ; uloëen° znaku
DispKSt8:inc       si
         inc       si                       ; zvò®en° ukazatele znakñ
         loop      DispKSt7                 ; dal®° znak
         pop       ds

; ------ n†vrat registrñ

DispKSt9:pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax

; ------ POKRAÄUJE PROCEDURA DISPMSTR !!!!!

DispKStr ENDP

; *****************************************************************************
;                                  DispMStr
;              Zobrazen° textovÇho ©etàzce s maskov†n°m p©es okna menu
; -----------------------------------------------------------------------------
; VSTUP:  AL=po©adovÇ á°slo menu - hladina pro zobrazen° (0=podklad+okna)
;         CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (1 znak = 2 bajty = znak a atribut)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispMStr PROC      FAR

; ------ test, zda bude okno filtrov†no

         test      byte ptr ds:[ParMenu],bit3 ; je p©echodnÇ vypnut° oken ?
         jnz       DispMSt0                 ; je p©echodnÇ vypnut° oken
         cmp       al,byte ptr ds:[NumMenu] ; je to aktivn° menu ?
         jb        DispMSt1                 ; okno bude filtrov†no
DispMSt0:jmp       far ptr DispStr          ; bàënÇ zobrazen° ©etàzce

; ------ p©°prava ukazatele okna v tabulce

DispMSt1:push      di
         push      bx

         mov       di,ax                    ; po©adovÇ á°slo okna
         and       di,0ffh                  ; hladina
         shl       di,1                     ; offset v definián° tabulce
         inc       ax                       ; zvò®en° ukazatele £rovnà okna

; ------ test, zda ©etàzec leë° nad oknem

         mov       bl,byte ptr ds:[di+PozMenu+1] ; poá†teán° ©†dek okna
         cmp       dh,bl                    ; je ©etàzec nad oknem ?
         jb        DispMSt6                 ; ©etàzec leë° celò nad oknem

; ------ okno s vò®kou 1 ©†dek je hlavn° menu - nen° jako maska (nem† st°n)

         mov       bh,byte ptr ds:[di+SirMenu+1] ; vò®ka okna
         cmp       bh,1                     ; je to hlavn° menu ?
         je        DispMSt6                 ; je to hlavn° menu - nefiltruje se

; ------ test, zda ©etàzec leë° pod oknem

         add       bl,bh                    ; ©†dek pod oknem
         cmp       dh,bl                    ; leë° ©†dek pod oknem ?
         ja        DispMSt6                 ; ©†dek leë° pod oknem
         mov       bl,byte ptr ds:[di+PozMenu] ; poá†teán° pozice okna
         mov       bh,byte ptr ds:[di+SirMenu] ; ®°©ka okna
         jb        DispMSt7                 ; ©†dek leë° uvnit© okna

         cmp       dh,ds:[MaxRow]           ; je to posledn° ©†dek displeje ?
         je        DispMSt6                 ; na posledn°m ©†dku nen° st°n

; ------ ©etàzec leë° tàsnà pod oknem - stanoven° parametrñ ke generov†n° st°nu

         add       bl,2                     ; posun poá†tku o 2 pozice vpravo
         add       bh,bl                    ; koncov† pozice okna (+1)
         sub       bh,dl                    ; offset konce st°nu od poá†tku ©et.
         jbe       DispMSt6                 ; konec okna p©ed zaá†tkem ©etàzce
         sub       bl,dl                    ; offset poá†tku st°nu od poá. ©et.
         jnc       DispMSt2                 ; poá†tek okna za poá†tkem ©etàzce
         mov       bl,0                     ; omezen° offsetu poá†tku okna
DispMSt2:cmp       cl,bl                    ; je ©etàzec celò vlevo ?
         jbe       DispMSt6                 ; ©etàzec je celò vlevo
         sub       bh,bl                    ; dÇlka st°nu k z†pisu

; ------ generov†n° st°nu v ©etàzci

         push      cx
         push      si
         mov       ch,0
         sub       cl,bl                    ; dÇlka zbytku ©†dku
         cmp       cl,bh                    ; je st°n krat®° neë zbytek ©†dku ?
         jb        DispMSt3                 ; zbytek ©†dku je krat®°
         mov       cl,bh                    ; omezen° dÇlky st°nu
DispMSt3:jcxz      DispMSt5
         mov       bh,0
         add       si,bx
         add       si,bx                    ; poá†teán° adresa v ©etàzci
DispMSt4:inc       si
         mov       byte ptr es:[si],7       ; uloëen° st°nu
         inc       si
         loop      DispMSt4
DispMSt5:pop       si
         pop       cx

; ------ filtrace celÇho ©etàzce vy®®° £rovn°

DispMSt6:pop       bx
         pop       di
         push      cs
         call      near ptr DispMStr        ; filtrace dal®° £rovn° okna
         dec       ax                       ; n†vrat ukazatele £rovnà
         ret

; ------ ©etàzec leë° na £rovn° ©†dkñ okna - p©°prava parametrñ k zobrazen°

DispMSt7:add       bh,bl                    ; koncov† pozice okna (+1)
         sub       bh,dl                    ; offset konce okna od poá†tku ©et.
         jbe       DispMSt6                 ; konec okna p©ed zaá†tkem ©etàzce
         sub       bl,dl                    ; offset poá†tku st°nu od poá. ©et.
         jnc       DispMSt8                 ; poá†tek okna za poá†tkem ©etàzce
         mov       bl,0                     ; omezen° offsetu poá†tku okna
DispMSt8:cmp       cl,bl                    ; je ©etàzec celò vlevo ?
         jbe       DispMSt6                 ; ©etàzec je celò vlevo

; ------ zobrazen° levÇ á†sti ©etàzce

         cmp       bl,0                     ; je lev† á†st ©etàzce ?
         je        DispMSt9                 ; nen° lev† á†st ©etàzce
         push      cx
         push      dx
         mov       cl,bl                    ; omezen° dÇlky ©etàzce
         push      cs
         call      near ptr DispMStr        ; zobrazen° levÇ á†sti ©etàzce
         pop       dx
         pop       cx

; ------ zobrazen° pravÇ á†sti ©etàzce

DispMSt9:cmp       cl,bh                    ; sn°ëen° dÇlky ©etàzce
         jbe       DispMStB                 ; nezbyl ë†dnò ©etàzec

         push      si
         push      cx
         push      dx

         add       dl,bh                    ; zvò®en° poá†teán° pozice
         sub       cl,bh
         mov       bl,bh
         mov       bh,0
         add       si,bx
         add       si,bx                    ; adresa poá†tku ©etàzce
         cmp       dh,byte ptr ds:[di+PozMenu+1] ; je poá†teán° ©†dek okna ?
         je        DispMStA                 ; poá†teán° ©†dek okna nem† st°n
         mov       byte ptr es:[si+1],7     ; prvn° znak st°nu
         cmp       cl,2                     ; jsou 2 znaky ?
         jb        DispMStA                 ; nejsou 2 znaky
         mov       byte ptr es:[si+3],7     ; druhò znak st°nu
DispMStA:push      cs
         call      near ptr DispMStr        ; zobrazen° pravÇ á†sti ©etàzce

         pop       dx
         pop       cx
         pop       si

DispMStB:pop       bx
         pop       di
         dec       ax
         add       dl,cl
         ret

DispMStr ENDP

; *****************************************************************************
;                                KorPozM
;              korekce pozice menu p©i p©eteáen° displeje
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

KorPozM  PROC      FAR

; ------ £schova registrñ

         push      ax

;; ------ korekce ©†dku hlavn°ho podmenu
;
;         cmp       byte ptr ds:[si+MnuTyp],1
;         jne       KorPozM1
;         mov       byte ptr ds:[si+MnuRad],1 ; je to vëdy ©†dek 1

; ------ kontrola maxim†ln° pozice

KorPozM1:mov       al,ds:[si+MnuPoz]        ; poá†teán° pozice okna menu
         add       al,ds:[si+MnuSir]        ; pozice konce okna menu
         add       al,2                     ; 2 pozice rezerva pro st°n
         sub       al,ds:[Pozic]            ; p©esah p©es konec okna
         jbe       KorPozM2                 ; pozice je OK
         sub       ds:[si+MnuPoz],al        ; korekce poá†tku okna
         jnc       KorPozM2                 ; poá†tek je OK
         mov       byte ptr ds:[si+MnuPoz],0 ; oprava poá†tku

; ------ kontrola maxim†ln°ho ©†dku

KorPozM2:mov       al,ds:[si+MnuRad]        ; poá†teán° ©†dek okna menu
         add       al,ds:[si+MnuVys]        ; ©†dek konce okna menu
         inc       ax                       ; 1 ©†dek rezerva pro st°n
         sub       al,ds:[Radku]            ; p©esah p©es konec okna
         jbe       KorPozM4                 ; ©†dek je OK
         sub       ds:[si+MnuRad],al        ; korekce ©†dku okna
         ja        KorPozM4                 ; ©†dek je OK
         mov       byte ptr ds:[si+MnuRad],1 ; oprava poá†tku

; ------ n†vrat registrñ

KorPozM4:pop       ax
         ret

KorPozM  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                Hlavn° menu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                               MainMenu
;                        obsluha hlavn°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice hlavn°ho menu
;        DS=datovò segment
; p©eru®en° volby: DS:SI=adresa p©edch†zej°c°ho menu
;                  BX=adresa definice hlavn°ho menu
; proveden° volby, je adresa navazuj°c°ho menu: DS:SI=adresa novÇho menu
;                                               BX=kl†vesa, kter† provedla volbu
;                                               DX=stav p©ep°naáñ menu
;                                               n†vratov† adresa do novÇho menu
; proveden° volby, nen° adresa dal®°ho menu: DS:SI=adresa tohoto hlavn°ho menu
;                                            BX=kl†vesa, kter† provedla volbu
;                                            DX=stav p©ep°naáñ menu
; *****************************************************************************

MainMenu PROC      FAR

; ------ £schova n†vratovÇ adresy z menu

         pop       word ptr ds:[si+MnuBreak] ; £schova n†vratovÇ adresy z menu
         pop       word ptr ds:[si+MnuBreak+2]

; ------ otev©en° hlavn°ho menu

         call      far ptr OpenMnu          ; otev©en° menu

; ------ automatickÇ vno©en° do menu

         mov       bx,1c0dh                 ; kl†vesa Enter
         test      byte ptr ds:[ParMenu],bit4 ; je automatickÇ vno©en° ?
         jnz       MainMnu2                 ; je automatickÇ vno©en° do menu

; ------ nastaven° aktivn° poloëky, je-li stisknutÇ levÇ tlaá°tko my®i

MainMnu0:test      byte ptr ds:[MouseKey],bit0 ; je levÇ tlaá°tko ?
         jz        MainMnu1                 ; nen° levÇ tlaá°tko
         mov       bx,MousXKod+MousXMov     ; p©°znak posunu
         cmp       byte ptr ds:[MousePoz+1],0 ; je ©†dek hlavn°ho menu ?
         jne       MainMn19                 ; nen° ©†dek menu
         jmp       short MainMnu2           ; nastaven° aktivn° poloëky menu

; ------ áek†n° na stisk kl†vesy

MainMnu1:call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr InpChar          ; vstup kl†vesy
         jc        MainMn19                 ; p©eru®en° kl†vesou ESC

; ------ p©eru®en° menu stiskem pravÇho tlaá°tka nebo stiskem mimo ©†dek

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       MainMnu2                 ; nen° k¢d my®i
         and       bl,not bit6              ; zru®en° p©°znaku dvoj°ho stisku
         cmp       bl,MousXRP               ; stisk pravÇho tlaá°tka ?
         je        MainMn19                 ; p©eru®en° pravòm tlaá°tkem my®i
         test      bl,bit2+bit3             ; stisk nàkterÇho tlaá°tka ?
         jz        MainMnu2                 ; nen° stisk tlaá°tka
         cmp       byte ptr ds:[MousePoz+1],0 ; je ©†dek menu ?
         je        MainMnu2                 ; nen° p©eru®en°

; ------ p©eru®en° volby ESC

MainMn19:mov       bx,si                    ; £schova adresy definice menu
         call      far ptr ClosMnu          ; uzav©en° hlavn°ho menu
         jmp       dword ptr ds:[bx+MnuBreak] ; n†vrat z obsluhy p©i p©eru®en°

; ------ áek†n° na proveden° volby

MainMnu2:call      far ptr EditMMnu         ; editace hlavn°ho menu
         jc        MainMnu1                 ; áek†n° na potvrzen° volby

; ====== extern° vstupn° bod - vstupuje se sem z vertik. menu (vlevo/vpravo)

; ------ adresa obsluhy volby

MainMnu3:push      bx
         mov       bx,ds:[si+MnuAkt]        ; aktivn° poloëka volby
         shl       bx,1                     ; á°slo volby
         shl       bx,1                     ; á°slo volby * 4
         add       bx,ds:[si+MnuExec]       ; adresa obsluhy
         mov       dx,ds:[bx-4]             ; adresa obsluhy - offset
         mov       word ptr cs:[MainMen0],dx ; offset adresy obsluhy
         mov       dx,ds:[bx-2]             ; adresa obsluhy - segment
         mov       word ptr cs:[MainMen0+2],dx ; segment adresy obsluhy
         or        dx,dx                    ; je adresa obsluhy ?
         pop       bx
         jz        MainMnu0                 ; nen° obsluha

; ------ poskytnut° stavu p©ep°naáñ menu

MainMnu4:push      cs
         call      near ptr GetSwch         ; poskytnut° stavu p©ep°naáñ

; ------ rozli®en°, zda je navazuj°c° menu

         push      bx
         mov       bx,ds:[si+MnuAkt]        ; aktivn° poloëka volby
         shl       bx,1                     ; á°slo volby * 2
         add       bx,ds:[si+MnuMnu]        ; adresa tabulky podmenu
         cmp       word ptr ds:[bx-2],0     ; je navazuj°c° podmenu ?
         je        MainMnu8                 ; nen° navazuj°c° podmenu

; ------ adresa definice podmenu, £schova n†vratovÇ adresy

         mov       si,ds:[bx-2]             ; adresa definice podmenu
         mov       word ptr ds:[si+MnuBreak],offset MainMnu1 ; n†vratov† adresa - offset
         mov       word ptr ds:[si+MnuBreak+2],cs    ; n†vratov† adresa - segment

; ------ skok na obsluhu volby

MainMnu8:pop       bx                       ; kl†vesa
         call      dword ptr cs:[MainMen0]  ; obsluha volby
         jmp       MainMnu0                 ; pokraáov†n° volby

MainMenu ENDP

MainMen0 dd        0                        ; adresa obsluhy provedenÇ volby

; -----------------------------------------------------------------------------
;        vòpoáet aktivn° poloëky z pozice my®i -> AX
; -----------------------------------------------------------------------------

MainMPol PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      di

         mov       bx,1
         mov       al,byte ptr ds:[MousePoz] ; pozice my®i
         mov       dl,11*2+1                ; levò okraj * 2
         sub       dl,ds:[si+MMnuOdd]       ; - oddàlovac° mezera
         sar       dl,1                     ; polovina oddàlovac° mezery
         add       dl,ds:[si+MMnuLft]       ; + levò okraj
         sub       al,dl
         jbe       MainMPl8
         mov       cx,ds:[si+MnuNum]        ; poáet platnòch poloëek
         mov       di,ds:[si+MnuPol]        ; definice poloëek

         dec       bx
         mov       dh,0
MainMPl1:inc       bx
         inc       di                       ; p©eskoáen° parametrñ poloëky
         mov       dl,ds:[di+MnuDelk-1]     ; dÇlka textu poloëky
         inc       di                       ; p©eskoáen° dÇlky poloëky
         add       di,dx                    ; adresa dal®° poloëky
         cmp       dl,ds:[si+MMnuMax]       ; p©ekroáena dÇlka poloëky ?
         jbe       MainMPl2                 ; dÇlka je OK
         mov       dl,ds:[si+MMnuMax]       ; omezen° dÇlky poloëky
MainMPl2:add       dl,ds:[si+MMnuSpc]       ; okraj poloëky
         add       dl,ds:[si+MMnuSpc]
         add       dl,ds:[si+MMnuOdd]       ; oddàlovac° mezera
         sub       al,dl
         jb        MainMPl8
         loop      MainMPl1

MainMPl8:xchg      ax,bx
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

MainMPol ENDP

; *****************************************************************************
;                              InitMMnu
;                     inicializace hlavn°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

InitMMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ nalezen° nejdel®° poloëky

         mov       di,ds:[si+MnuPol]        ; adresa definice poloëek menu
         mov       cx,ds:[si+MnuNum]        ; poáet platnòch poloëek menu
         xor       ax,ax                    ; AX <- 0
         xor       dx,dx                    ; DL <- 0 nejdel®° nalezen† poloëka
InitMMn1:inc       di
         mov       al,ds:[di]               ; dÇlka textu poloëky
         inc       di                       ; zaá†tek textu poloëky
         cmp       al,dl                    ; je del®° poloëka ?
         jb        InitMMn2                 ; nen° del®° poloëka
         mov       dl,al                    ; nov† nejdel®° poloëka
InitMMn2:add       di,ax                    ; adresa dal®° poloëky
         loop      InitMMn1                 ; test dal®° poloëky

; ------ inicializace ukazatelñ na standardn° hodnoty

         mov       ds:[si+MMnuMax],dl       ; omezen° dÇlky poloëky
         mov       byte ptr ds:[si+MMnuLft],1 ; levò okraj
         mov       byte ptr ds:[si+MMnuSpc],1 ; mezera na okraji poloëky
         mov       byte ptr ds:[si+MMnuOdd],1 ; oddàlovac° mezera poloëek
         mov       byte ptr ds:[si+MMnuRght],1 ; pravò okraj poloëek
         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       al,10+1+1+8              ; odeáten° okrajñ
         mov       ds:[si+MnuSir],al        ; ®°©ka menu

; ------ test nastaven° menu

         call      TestMMnu                 ; test nastaven° menu
         jb        InitMMn4                 ; menu je krat®° neë ©†dek
         je        InitMMn5                 ; menu je OK

; ------ je p©esah - zru®en° levÇho okraje

         dec       byte ptr ds:[si+MMnuLft] ; zru®en° levÇho okraje
         dec       ax                       ; p©esah
         jz        InitMMn5                 ; jië je to OK

; ------ zru®en° pravÇho okraje

         dec       byte ptr ds:[si+MMnuRght] ; zru®en° pravÇho okraje
         dec       ax                       ; p©esah
         jz        InitMMn5                 ; jië je to OK

; ------ zru®en° mezery mezi poloëkami

         dec       byte ptr ds:[si+MMnuOdd] ; zru®en° oddàlovac° mezery
         call      TestMMnu                 ; test nastaven° menu
         jb        InitMMn4                 ; menu je krat®° neë ©†dek
         je        InitMMn5                 ; menu je OK

; ------ zru®en° okraje poloëek

         inc       byte ptr ds:[si+MMnuOdd] ; n†vrat oddàlovac° mezery
         dec       byte ptr ds:[si+MMnuSpc] ; zru®en° okraje poloëek
         call      TestMMnu                 ; test nastaven° menu
         jb        InitMMn4                 ; menu je krat®° neë ©†dek
         je        InitMMn5                 ; menu je OK

; ------ omezen° maxim†ln° dÇlky poloëky p©i p©esahu menu

InitMMn3:call      TestMMnu                 ; test nastaven° menu
         jb        InitMMn4                 ; menu je krat®° neë ©†dek
         je        InitMMn5                 ; menu je OK
         dec       byte ptr ds:[si+MMnuMax] ; sn°ëen° omezen° dÇlky poloëky
         jnz       InitMMn3                 ; novò test
         inc       byte ptr ds:[si+MMnuMax] ; minim†ln° dÇlka 1 znak
         mov       byte ptr ds:[si+MMnuOdd],0 ; zru®en° oddàlovac° mezery
         call      TestMMnu                 ; test nastaven° menu
         jae       InitMMn5                 ; menu je OK nebo nelze v°c zkr†tit

; ------ p©i kr†tkÇm menu vòpoáet pravÇho okraje

InitMMn4:neg       ax                       ; poáet chybàj°c°ch pozic
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[si+MnuNum]  ; rozdàlen° mezer na poloëky
         add       word ptr ds:[si+MMnuRght],dx      ; zvàt®en° pravÇho okraje

; ------ vòpoáet oddàlovac°ch mezer

         xor       dx,dx                    ; DX <- 0
         mov       cx,3                     ; dàlitel
         div       cx                       ; rozdàlen° mezery na okraje
         add       ds:[si+MMnuLft],al       ; zvò®en° levÇho okraje
         add       ds:[si+MMnuSpc],al       ; zvò®en° okraje poloëky
         add       ds:[si+MMnuOdd],al       ; zvò®en° oddàlovac° poloëky
         mov       dh,dl
         shr       dl,1                     ; rozdàlen° p©ebytku mezer
         adc       byte ptr ds:[si+MMnuOdd],0 ; lich† mezera do oddàlovac° mez.
         shr       dh,1
         adc       byte ptr ds:[si+MMnuLft],0 ; to stejnÇ na levou mezeru
         add       byte ptr ds:[si+MMnuSpc],dl ; zbytek na okraj poloëek

; ------ p©i dlouhÇm ©†dku zmen®en° mezer

         cmp       byte ptr ds:[si+MMnuSpc],3
         jbe       InitMMn5                 ; dÇlka mezer vyhovuje
         dec       byte ptr ds:[si+MMnuLft] ; sn°ëen° levÇho okraje o 1
         dec       byte ptr ds:[si+MMnuSpc] ; sn°ëen° okraje poloëek o 1
         sub       byte ptr ds:[si+MMnuOdd],2 ; sn°ëen° oddàlovac° mezery o 2
         call      TestMMnu                 ; test nastaven° menu
         neg       ax                       ; chybàj°c° mezery
         add       ds:[si+MMnuRght],al      ; mezery se p©idaj° na pravò okraj

; ------ p©°prava ke korekci odvozenòch menu

InitMMn5:mov       cx,ds:[si+MnuNum]        ; poáet poloëek menu
         mov       di,ds:[si+MnuMnu]        ; tabulka adres odvozenòch menu
         mov       al,11-1                  ; poá†tek hlavn°ho menu - korekce
         mov       bx,word ptr ds:[si+MMnuSpc]       ; BL <- okraj poloëky, BH <- mezera
         add       al,ds:[si+MMnuLft]       ; p©iáten° levÇho okraje
         mov       ah,ds:[si+MMnuMax]       ; omezen° dÇlky poloëky
         mov       si,ds:[si+MnuPol]        ; definice poloëek
         mov       dh,0

; ------ uloëen° poá†teán° pozice odvozenÇho menu

InitMMn6:mov       bp,ds:[di]               ; adresa odvozenÇho menu
         push      ax
         mov       dl,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       dl,2                     ; 2 pozice pro st°n
         sub       dl,ds:[bp+MnuSir]        ; odeáten° ®°©ky okna
         cmp       al,dl                    ; p©ekroáena maxim†ln° pozice ?
         jb        InitMMn7                 ; poá†teán° pozice je OK
         mov       al,dl                    ; omezen° maxim†ln° pozice
InitMMn7:mov       ds:[bp+MnuPoz],al        ; poá†teán° pozice menu
         pop       ax

; ------ vòpoáet pozice n†sleduj°c° poloëky

         inc       si
         mov       dl,ds:[si]               ; dÇlka poloëky
         inc       si
         add       si,dx                    ; adresa dal®° poloëky
         cmp       dl,ah                    ; p©ekroáena maxim†ln° dÇlka ?
         jb        InitMMn8                 ; dÇlka poloëky je OK
         mov       dl,ah                    ; omezen° dÇlky poloëky
InitMMn8:add       al,dl                    ; p©iáten° dÇlky poloëky
         add       al,bl                    ; p©iáten° pravÇho okraje poloëky
         add       al,bh                    ; p©iáten° mezery
         add       al,bl                    ; p©iáten° levÇho okraje poloëky
         inc       di
         inc       di                       ; zvò®en° ukazatele poloëek
         loop      InitMMn6                 ; adresa dal®° poloëky

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitMMnu ENDP

; -----------------------------------------------------------------------------
;        test hlavn°ho menu DS:SI, zda jië vyhovuje (-> AX=poáet znakñ p©es)
; -----------------------------------------------------------------------------

TestMMnu PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©°prava parametrñ menu

         mov       ax,10+1+1+8              ; okraje kolem menu
         add       al,ds:[si+MMnuLft]       ; p©iáten° levÇho okraje menu
         mov       ch,0
         mov       cl,byte ptr ds:[si+MnuNum]        ; poáet poloëek menu
         mov       di,cx                    ; poáet poloëek menu
         mov       bx,word ptr ds:[si+MMnuSpc]       ; BL <- okraj poloëky, BH <- mezera
         mov       dx,word ptr ds:[si+MMnuRght]      ; DL <- pravò okraj, DH <- omezen°
         mov       si,ds:[si+MnuPol]        ; adresa definice poloëek

; ------ spoáten° dÇlky textu

TestMMn1:inc       si                       ; p©eskoáen° bajtu parametrñ
         mov       cl,ds:[si]               ; dÇlka textu poloëky
         inc       si                       ; p©eskoáen° bajtu dÇlky
         add       si,cx                    ; adresa dal®° poloëky
         cmp       cl,dh                    ; p©ekroáena maxim†ln° dÇlka ?
         jb        TestMMn2                 ; dÇlka poloëky je OK
         mov       cl,dh                    ; omezen° dÇlky poloëky
TestMMn2:add       cl,bl                    ; p©iáten° levÇho okraje
         add       cl,bl                    ; p©iáten° pravÇho okraje
         add       cl,bh                    ; p©iáten° oddàlovac° mezery
         add       ax,cx                    ; p©iáten° poloëky ke st©adaái
         dec       di                       ; á°taá poloëek
         jnz       TestMMn1                 ; p©iáten° dal®° poloëky

; ------ korekce vòsledku

         sub       dl,bh                    ; korekce pravÇho okraje o mezeru
         mov       dh,0
         sbb       dh,0                     ; p©enos
         add       ax,dx                    ; p©iáten° pravÇho okraje
         mov       dl,ds:[Pozic]            ; poáet pozic na ©†dek
         mov       dh,0
         sub       ax,dx                    ; p©eteáen° p©es okraj

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

TestMMnu ENDP

; *****************************************************************************
;                                DispMMnu
;                        zobrazen° hlavn°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice hlavn°ho menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2]  (2) á°taá aktivn° poloëky
;                   SS:[BP-4]  (2) á°taá poloëek
;                   SS:[BP-6]  (2) ukazatel adresy poloëky
;                   SS:[BP-7]  (1) pravò okraj
;                   SS:[BP-8]  (1) okraj poloëky
;                   SS:[BP-9]  (1) oddàlovac° mezera mezi poloëkami
;                   SS:[BP-10] (1) p©°znaky: bit 0 - je kurzor, bit 1 - aktivn°
;                   SS:[BP-11] (1) omezen° dÇlky poloëky
; *****************************************************************************

DispMMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp                    ; £schova ukazatele z†sobn°ku

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,12                    ; lok†ln° promànnÇ
         sub       sp,ds:[ByteRow]          ; vytvo©en° bufferu v z†sobn°ku
         mov       di,sp                    ; adresa bufferu v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld

; ------ p©°prava registrñ pro dek¢dov†n° menu

         mov       bx,ds:[si+MnuBlk]        ; blokovac° tabulka
         mov       ax,ds:[si+MnuAkt]        ; á°slo aktivn° poloëky menu
         mov       ss:[bp-2],ax             ; á°taá aktivn° poloëky
         mov       ax,ds:[si+MnuNum]        ; poáet poloëek v menu
         mov       ss:[bp-4],ax             ; á°taá poloëek
         mov       al,ds:[si+MMnuRght]      ; pravò okraj
         mov       ss:[bp-7],al             ; pravò okraj
         mov       al,ds:[si+MMnuSpc]       ; mezera na okraji poloëky
         mov       ss:[bp-8],al             ; mezera na okraji poloëky
         mov       al,ds:[si+MMnuOdd]       ; oddàlovac° mezera mezi poloëkami
         mov       ss:[bp-9],al             ; oddàlovac° mezera mezi poloëkami
         mov       al,ds:[si+MMnuMax]       ; omezen° dÇlky poloëky
         mov       ss:[bp-11],al            ; omezen° dÇlky poloëky
         mov       ch,0
         mov       cl,ds:[si+MMnuLft]       ; levò okraj

; ------ p©°prava p©°znakñ pro zobrazen°

         mov       al,0                     ; p©°znaky - ani kurzor, ani aktivn°
         test      byte ptr ds:[ParMenu],bit1 ; je hlavn° menu zobrazeno ?
         jz        DispMMn0                 ; nen° zobrazeno
         test      byte ptr ds:[ParMenu],bit3 ; je p©echodnÇ vypnut° oken ?
         jnz       DispMMn0                 ; je vypnut° oken Ctrl-O
         or        al,bit0                  ; p©°znak zobrazen° kurzoru
         cmp       si,ds:[AktMenu]          ; je to aktivn° menu ?
         jne       DispMMn0                 ; nen° to atkivn° menu
         or        al,bit1                  ; p©°znak aktivn°ho menu
DispMMn0:mov       ss:[bp-10],al            ; p©°znaky pro zobrazen°

; ------ ukazatel adresy poloëky

         mov       si,ds:[si+MnuPol]        ; zaá†tek definice poloëek
         mov       ss:[bp-6],si             ; zaá†tek definice poloëek

; ------ dek¢dov†n° systÇmovÇho data na £vod nebo informaán°ho textu

         mov       ah,ds:[ColDate]          ; barva £daje data
         mov       si,offset InfTxt2        ; text pro INT 24h ("chyba")
         test      byte ptr ds:[ParInt24],bit5 ; je obsluha INT 24h ?
         jnz       DispMM12                 ; prob°h† obsluha INT 24h
         mov       si,offset InfTxt1        ; text bàhem operace ("áekejte")
         test      byte ptr ds:[InfoPar],bit0 ; zobrazen informaán° ©†dek ?
         jnz       DispMM12                 ; je informaán° ©†dek
         test      byte ptr ds:[ParInt24],bit3
         jnz       DispMM12                 ; je je®tà obsluha INT 24h

         cmp       byte ptr ss:[bp-10],bit0 ; jsou i jin† menu neë hlavn° ?
         jne       DispMM14                 ; nejsou dal®° menu

         mov       si,offset InfTxt         ; informaán° text
DispMM12:call      far ptr DekTText         ; dek¢dov†n° textu
         jmp       short DispMM13

DispMM14:call      far ptr DekSDate         ; dek¢dov†n° systÇmovÇho data
         add       di,2*10                  ; konec za datem

; ------ oddàlovac° á†ra

DispMM13:cld
         mov       ah,ds:[ColMnu1]          ; bàën† barva menu
         mov       al,"≥"                   ; oddàlovac° á†ra
         stosw

; ------ uloëen° £vodn°ch mezer (levò okraj)

         mov       al," "                   ; oddàlovac° mezera
         rep       stosw                    ; uloëen° £vodn°ch mezer

; ------ p©°prava ukazatele pro dal®° poloëku

DispMMn1:mov       si,ss:[bp-6]             ; adresa zaá†tku definice poloëky
         mov       al,ds:[si+MnuDelk]       ; dÇlka textu poloëky
         mov       ah,0
         inc       ax
         inc       ax                       ; p©iáten° pomocnòch poloëek
         add       ax,si                    ; adresa n†sleduj°c° poloëky
         mov       ss:[bp-6],ax             ; adresa n†sleduj°c° poloëky

; ------ p©°prava atributñ barvy poloëky s rozli®en°m podle kurzoru

         mov       dl,byte ptr ds:[ColMnu1] ; barva bàënÇho textu menu
         mov       dh,byte ptr ds:[ColMnu2] ; vysv°cen† barva textu
         mov       cl,ds:[ColMnu5]          ; bàën† zak†zan† poloëka
         dec       word ptr ss:[bp-2]       ; sn°ëen° á°taáe aktivn° poloëky
         jnz       DispMMn2                 ; poloëka nen° aktivn°
         test      byte ptr ss:[bp-10],bit0 ; je zobrazen kurzor ?
         jz        DispMMn2                 ; nen° zobrazen kurzor - neaktivn°
         mov       dl,byte ptr ds:[ColMnu3] ; barva poloëky s kurzorem
         mov       dh,byte ptr ds:[ColMnu4] ; vysv°cen† barva kurzoru
         mov       cl,ds:[ColMnu6]          ; zak†zan† poloëka - kurzor

; ------ korekce barvy poloëky pro zak†zanÇ poloëky

DispMMn2:cmp       byte ptr ds:[bx],0       ; je poloëka povolen† ?
         je        DispMMn3                 ; poloëka je povolen†
         mov       dl,cl                    ; zak†zan† poloëka - bàën†
         mov       dh,cl                    ; zak†zan† poloëka - vysv°cen†
DispMMn3:inc       bx                       ; zvò®en° ukazatele poloëek
         test      byte ptr ss:[bp-10],bit1 ; je hlavn° menu aktivn° ?
         jnz       DispMMn4                 ; hlavn° menu je aktivn°
         mov       dh,dl                    ; neaktivn° - nen° zvòraznànò text

; ------ uloëen° £vodn°ch mezer poloëky

DispMMn4:mov       cl,ss:[bp-8]             ; poáet mezer na okraji poloëky
         mov       ah,dl                    ; bàën† barva textu
         mov       al," "                   ; znak mezery
         rep       stosw                    ; uloëen° £vodn°ch mezer poloëky

; ------ dek¢dov†n° textu poloëky

         mov       cl,ds:[si+MnuDelk]       ; dÇlka textu poloëky
         push      cx
         mov       ch,ds:[si+MnuParm]       ; parametry poloëky
         and       ch,not bit6 + bit7       ; pozice horkÇho znaku
         inc       si
         inc       si                       ; zaá†tek textu poloëky
         push      si
         cmp       cl,ss:[bp-11]            ; omezen° dÇlky textu
         jb        DispMMn5                 ; dÇlka textu je OK
         mov       cl,ss:[bp-11]            ; omezen° dÇlky textu
DispMMn5:lodsb                              ; naáten° znaku k dek¢dov†n°
         mov       ah,dl                    ; bàën† barva
         dec       ch                       ; á°taá horkÇho znaku
         jnz       DispMMn6                 ; nen° horkò znak
         mov       ah,dh                    ; zvòraznàn† barva
DispMMn6:stosw                              ; uloëen° znaku do textu
         dec       cl                       ; á°taá znakñ
         jnz       DispMMn5                 ; dek¢dov†n° dal®°ho znaku
         pop       si
         pop       cx
         add       si,cx                    ; adresa dal®° poloëky

; ------ z†vàreán† mezera poloëky

         mov       cl,ss:[bp-8]             ; poáet mezer na okraji poloëky
         mov       ah,dl                    ; bàën† barva textu
         mov       al," "                   ; znak mezery
         rep       stosw                    ; uloëen° £vodn°ch mezer poloëky

; ------ p©°davn† oddàlovac° mezera poloëky

         mov       ah,ds:[ColMnu1]          ; bàën† barva textu menu
         dec       word ptr ss:[bp-4]       ; sn°ëen° á°taáe poloëek
         jz        DispMMn7                 ; nen° jië dal®° poloëka
         mov       cl,ss:[bp-9]             ; dÇlka mezimezery
         rep       stosw                    ; uloëen° dopl§uj°c°ch mezer
         jmp       DispMMn1                 ; dal®° poloëka

; ------ dopl§uj°c° mezery za menu

DispMMn7:mov       cl,ss:[bp-7]             ; poáet z†vàreánòch mezer
         mov       al," "                   ; znak mezery
         rep       stosw                    ; vymaz†n° zbytku textu

; ------ oddàlovac° linka

         mov       al,"≥"
         stosw                              ; okraj

; ------ dek¢dov†n° systÇmovÇho áasu

         mov       ah,ds:[ColTime]          ; barva k zobrazen° áasu
         call      far ptr DekSTime         ; dek¢dov†n° systÇmovÇho áasu

; ------ zobrazen° textu hlavn°ho menu

         mov       si,sp                    ; zaá†tek textu v bufferu
         mov       cl,ds:[Pozic]            ; poáet pozic na ©†dek
         xor       dx,dx                    ; poá†teán° pozice k zobrazen°
         xor       ax,ax                    ; vòstupn° hladina 0
         call      far ptr DispKStr         ; z†pis ©etàzce na displej

; ------ n†vrat registrñ

         mov       sp,bp                    ; n†vrat ukazatele z†sobn°ku
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispMMnu ENDP

; *****************************************************************************
;                                EditMMnu
;                        editace hlavn°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl†vesa
; kl†vesa neobslouëena: CY=p©°znak pokraáov†n° editace, BX nezmànàno
; kl†vesa OK, nen° volba: CY=p©°znak pokraáov†n° editace, BX=0
; provedena volba: NC=p©°znak proveden° editace, BX=á°slo volby
; *****************************************************************************

EditMMnu PROC      FAR

; ------ p©echodnÇ vypnut° menu

         call      far ptr MCtrlO           ; p©echodnÇ vypnut° menu
         jnc       EditMMn0                 ; nebyla funkce Ctrl-O
         ret

; ------ £schova registrñ

EditMMn0:push      ax

; ------ nalezen° horkÇ kl†vesy

         call      far ptr SrcHotM          ; nalezen° horkÇ kl†vesy
         jc        EditMMn2                 ; poloëka nenalezena

; ------ proveden° volby (zvolena poloëka AX)

EditMMn1:call      far ptr EditMEnt        ; obsluha volby menu
         jmp       short EditMMn9

; ------ nalezen° horkÇ kl†vesy s Alt-

EditMMn2:call      far ptr SrcHotA          ; nalezen° horkÇ kl†vesy s Alt-
         jnc       EditMMn7                 ; kl†vesa nalezena OK

; ------ obsluha ©°dic° kl†vesy (AX=aktivn° poloëka)

         call      far ptr JumpBX

         dw        1c0dh,EditMMn1           ; ENTER
         dw        5000h,EditMMn1           ; DOWN
         dw        4b00h,EditMMn3           ; LEFT
         dw        1f13h,EditMMn3           ; Ctrl-S vlevo

         dw        0f00h,EditMMn3           ; *TAB
         dw        4f00h,EditMMn4           ; END
         dw        4d00h,EditMMn5           ; RIGHT
         dw        2004h,EditMMn5           ; Ctrl-D vpravo

         dw        0f09h,EditMMn5           ; TAB
         dw        4700h,EditMMn6           ; HOME

         dw        MousXKod+MousXLR,EditMMn1 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,EditMM22 ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,EditMM22 ; posun my®i

         dw        0,EditMMn8

; ------ posun my®i

EditMM22:test      byte ptr ds:[MouseKey],bit1 ; je pouze levÇ tlaá°tko ?
         jnz       EditMMn8                 ; nen° jen levÇ tlaá°tko
         cmp       byte ptr ds:[MousePoz+1],0 ; je ©†dek 0 ?
         jne       EditMM24                 ; nen° ©†dek 0
         call      MainMPol                 ; poloëka hlavn°ho menu z my®i
         jmp       short EditMMn7

EditMM24:mov       bx,1c0dh                 ; kl†vesa Enter
         jmp       short EditMMn1           ; proveden° volby

; ------ posun kurzoru vlevo

EditMMn3:dec       ax
         jnz       EditMMn7

; ------ posledn° poloëka

EditMMn4:mov       ax,ds:[si+MnuNum]
         jmp       short EditMMn7

; ------ posun kurzoru vpravo

EditMMn5:inc       ax
         cmp       ax,ds:[si+MnuNum]
         jbe       EditMMn7

; ------ posun na prvn° poloëku

EditMMn6:mov       ax,1                     ; prvn° poloëka menu

; ------ nastaven° novÇ pozice kurzoru

EditMMn7:mov       ds:[si+MnuAkt],ax        ; nov† aktivn° poloëka
         push      cs
         call      near ptr DispMnu         ; novÇ zobrazen° menu
         xor       bx,bx                    ; p©°znak obsluhy kl†vesy
EditMMn8:stc                                ; p©°znak pokraáuj°c° volby

; ------ n†vrat registrñ

EditMMn9:pop       ax
         ret

EditMMnu ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              Vertik†ln° menu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                               VertMenu
;                        obsluha vertik†ln°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice vertik†ln°ho menu
;        DS=datovò segment
; p©eru®en° volby: DS:SI=adresa p©edch†zej°c°ho menu
;                  BX=adresa definice tohoto menu
; proveden° volby, je adresa navazuj°c°ho menu: DS:SI=adresa novÇho menu
;                                               BX=kl†vesa, kter† provedla volbu
;                                               DX=stav p©ep°naáñ menu
;                                               n†vratov† adresa do novÇho menu
; proveden° volby, nen° adresa dal®°ho menu: DS:SI=adresa tohoto menu
;                                            BX=kl†vesa, kter† provedla volbu
;                                            DX=stav p©ep°naáñ menu
; *****************************************************************************

VertMenu PROC      FAR

; ------ £schova n†vratovÇ adresy z menu

         pop       word ptr ds:[si+MnuBreak] ; £schova n†vratovÇ adresy z menu
         pop       word ptr ds:[si+MnuBreak+2]

; ------ otev©en° vertik†ln°ho menu

         push      cs
         call      near ptr KorPozM         ; korekce pozice okna menu
         push      cs
         call      near ptr OpenMnu         ; otev©en° menu

; ------ automatickÇ vno©en° do menu

         test      byte ptr ds:[ParMenu],bit4 ; je automatickÇ vno©en° do menu ?
         jz        VertMnu1                 ; nen° automatickÇ vno©en° do menu
         mov       bl,byte ptr ds:[si+MnuAkt]        ; aktivn° poloëka menu
         mov       bh,0
         shl       bx,1                     ; offset v tabulce podmenu + 2
         add       bx,ds:[si+MnuMnu]        ; adresa poloëky podmenu + 2
         cmp       word ptr ds:[bx-2],0     ; je podmenu ?
         mov       bx,1c0dh                 ; kl†vesa Enter
         je        VertMn04
         jmp       VertMnu2                 ; je podmenu
VertMn04:and       byte ptr ds:[ParMenu],not bit4 ; ukonáen° automat. vno©en°
         jmp       short VertMnu1

; ------ nastaven° aktivn° poloëky, je-li stisknutÇ levÇ tlaá°tko my®i

VertMnu0:test      byte ptr ds:[MouseKey],bit0 ; je levÇ tlaá°tko ?
         jz        VertMnu1                 ; nen° levÇ tlaá°tko
         mov       bx,MousXKod+MousXMov     ; p©°znak posunu
         call      far ptr MouseMnu         ; test, zda je my® v menu
         jnc       VertMnu2                 ; nastaven° aktivn° poloëky menu
         jmp       short VertMn12           ; jinak p©eru®en° menu

; ------ vstup znaku z kl†vesnice

VertMnu1:call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr InpChar          ; vstup znaku s dynamickou obsluhou
         jc        VertMn12                 ; je p©eru®en° menu ESC

; ------ p©eru®en° menu stiskem pravÇho tlaá°tka nebo stiskem mimo ©†dek

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       VertMnu2                 ; nen° k¢d my®i
         and       bl,not bit6              ; zru®en° p©°znaku dvoj°ho stisku
         cmp       bl,MousXRP               ; stisk pravÇho tlaá°tka ?
         je        VertMn12                 ; p©eru®en° pravòm tlaá°tkem my®i
         test      bl,bit2+bit3             ; stisk nàkterÇho tlaá°tka ?
         jnz       VertMn11                 ; je stisk tlaá°tka
         test      byte ptr ds:[MouseKey],bit0 ; je levÇ tlaá°tko ?
         jz        VertMnu2                 ; nen° stisk tlaá°tka
         cmp       byte ptr ds:[si+MnuTyp],1 ; je hlavn° podmenu ?
         jne       VertMnu2                 ; nen° hlavn° podmenu
         cmp       byte ptr ds:[MousePoz+1],0 ; je ©†dek 0 ?
         je        VertMn12
         jmp       short VertMnu2

VertMn11:call      far ptr MouseMnu         ; test, zda je okno menu
         jnc       VertMnu2                 ; nen° p©eru®en°

; ------ p©eru®en° volby ESC

VertMn12:mov       bx,si                    ; £schova adresy definice menu
         push      cs
         call      near ptr ClosMnu         ; uzav©en° hlavn°ho menu
         jmp       dword ptr ds:[bx+MnuBreak] ; n†vrat z obsluhy p©i p©eru®en°

; ------ posun menu vlevo/vpravo, je-li hlavn° vertik†ln° menu

VertMnu2:call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         cmp       byte ptr ds:[si+MnuTyp],1 ; je to hlavn° vert. menu ?
         jne       VertMnu4                 ; nen° hlavn° vertik†ln° menu

         cmp       bx,4d00h
         je        VertMn22
         cmp       bx,4b00h
         jne       VertMnu4

VertMn22:mov       byte ptr ds:[NumMenu],1  ; zru®en° vertik†ln°ho menu
         mov       si,ds:[TabMenu]          ; novÇ hlavn° menu
         mov       ds:[AktMenu],si          ; je to novÇ aktivn° menu

VertMnu3:cmp       bh,4bh                   ; vlevo
         jne       VertMn31
         dec       byte ptr ds:[si+MnuAkt]  ; sn°ëen° aktivn° poloëky
         jnz       VertMn33
         push      ax
         mov       al,byte ptr ds:[si+MnuNum]
         mov       byte ptr ds:[si+MnuAkt],al
         pop       ax
         jmp       short VertMn33

VertMn31:inc       byte ptr ds:[si+MnuAkt]  ; zvò®en° aktivn° poloëky
         push      ax
         mov       al,byte ptr ds:[si+MnuNum]
         cmp       byte ptr ds:[si+MnuAkt],al
         jbe       VertMn32
         mov       byte ptr ds:[si+MnuAkt],1
VertMn32:pop       ax

VertMn33:push      bx
         mov       bx,ds:[si+MnuAkt]        ; aktivn° poloëka
         add       bx,ds:[si+MnuBlk]        ; blokovac° tabulka
         cmp       byte ptr ds:[bx-1],0     ; je poloëka povolena ?
         pop       bx
         jne       VertMnu3                 ; poloëka nen° povolena - dal®°

         mov       bx,1c0dh                 ; kl†vesa ENTER
         jmp       MainMnu3                 ; otev©en° novÇho menu

VertMn38:jmp       VertMnu1

; ------ áek†n° na proveden° volby

VertMnu4:cmp       bx,4b00h
         je        VertMn12                 ; kurzor vlevo - je jako ESC
         push      cs
         call      near ptr EditVMnu        ; editace vertik†ln°ho menu
         jc        VertMn38                 ; áek†n° na potvrzen° volby

; ------ adresa obsluhy volby

         push      bx
         mov       bx,ds:[si+MnuAkt]        ; aktivn° poloëka volby
         shl       bx,1                     ; á°slo volby
         shl       bx,1                     ; á°slo volby * 4
         add       bx,ds:[si+MnuExec]       ; adresa obsluhy
         mov       dx,ds:[bx-4]             ; adresa obsluhy - offset
         mov       word ptr cs:[VertMen0],dx ; offset adresy obsluhy
         mov       dx,ds:[bx-2]             ; adresa obsluhy - segment
         mov       word ptr cs:[VertMen0+2],dx ; segment adresy obsluhy
         or        dx,dx                    ; je obsluha ?
         pop       bx
         jz        VertMn38                 ; nen° obsluha

; ------ poskytnut° stavu p©ep°naáñ menu

VertMnu6:push      cs
         call      near ptr GetSwch         ; poskytnut° stavu p©ep°naáñ

; ------ rozli®en°, zda je navazuj°c° menu

         push      bx
         mov       bx,ds:[si+MnuAkt]        ; aktivn° poloëka volby
         shl       bx,1                     ; á°slo volby * 2
         add       bx,ds:[si+MnuMnu]        ; adresa tabulky podmenu
         cmp       word ptr ds:[bx-2],0     ; je navazuj°c° podmenu ?
         je        VertMnu8                 ; nen° navazuj°c° podmenu

; ------ adresa definice podmenu, £schova n†vratovÇ adresy

         mov       si,ds:[bx-2]             ; adresa definice podmenu
         mov       word ptr ds:[si+MnuBreak],offset VertMnu1 ; n†vratov† adresa - offset
         mov       word ptr ds:[si+MnuBreak+2],cs    ; n†vratov† adresa - segment

; ------ skok na obsluhu volby

VertMnu8:pop       bx                       ; kl†vesa
         call      dword ptr cs:[VertMen0]  ; obsluha volby
VertMnu9:jmp       VertMnu0                 ; pokraáov†n° volby

VertMenu ENDP

VertMen0 dd        0                        ; adresa obsluhy provedenÇ volby

; -----------------------------------------------------------------------------
;        aktivn° poloëka podle my®i -> AX
; -----------------------------------------------------------------------------

VertMPol PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si

         xor       bx,bx                    ; ukazatel á°sla poloëky
         mov       al,byte ptr ds:[MousePoz+1] ; ©†dek my®i
         sub       al,ds:[si+MnuRad]        ; ©†dek relativnà
         jbe       VertMPl8                 ; je horn° okraj okna
         mov       cx,ds:[si+MnuSum]
         mov       si,ds:[si+MnuPol]
         mov       dh,0

VertMPl1:test      byte ptr ds:[si+MnuParm],bit6 ; je platn† poloëka ?
         jnz       VertMPl2                 ; nen° platn† poloëka
         inc       bx                       ; zvò®en° á°sla poloëky
VertMPl2:sub       al,1
         jz        VertMPl8
         inc       si
         mov       dl,ds:[si+MnuDelk-1]
         inc       si
         add       si,dx
         loop      VertMPl1

VertMPl8:xchg      ax,bx                    ; AX <- kurzor
         or        ax,ax                    ; minim†ln° poloëka 1
         jnz       VertMPl9
         inc       ax

VertMPl9:pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

VertMPol ENDP

; *****************************************************************************
;                              InitVMnu
;                     inicializace vertik†ln°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

InitVMnu PROC      FAR

         ret

InitVMnu ENDP

; *****************************************************************************
;                                   DispVMnu
;                         zobrazen° vertik†ln°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) ukazatel ©†dku na displeji
;                   SS:[BP-2] (1) poá†teán° pozice menu
;                   SS:[BP-3] (1) á°taá vnit©n°ch ©†dkñ k zobrazen°
;                   SS:[BP-4] (1) ®°©ka okna
;                   SS:[BP-6] (2) parametry: bit 0 - menu je aktivn°
;                   SS:[BP-8] (2) á°taá aktivn° poloëky
;                   SS:[BP-10] (2) ukazatel definice poloëek
;                   SS:[BP-12] (2) ukazatel blokovac° tabulky
;                   SS:[BP-14] (2) ukazatel tabulky p©ep°naáñ
;                   SS:[BP-16] (2) hladina k zobrazen° menu
; *****************************************************************************

DispVMnu PROC      FAR

         call      far ptr DispRamM         ; zobrazen° horn° a doln° linky

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

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,16                    ; m°sto pro lok†ln° promànnÇ
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         sub       sp,ds:[ByteRow]          ; vytvo©en° bufferu pro jeden ©†dek

; ------ inicializace lok†ln°ch promànnòch

         mov       ax,word ptr ds:[si+MnuPoz]        ; pozice a ©†dek
         inc       ah                       ; poá†teán° ©†dek k zobrazen°
         mov       ss:[bp-2],ax             ; pozice a ©†dek
         mov       ax,word ptr ds:[si+MnuSir]        ; ®°©ka a vò®ka
         sub       ah,2                     ; vnit©n° vò®ka okna
         mov       ss:[bp-4],ax             ; ®°©ka a vò®ka
         xor       ax,ax                    ; AX <- 0
         cmp       si,ds:[AktMenu]          ; je to aktivn° menu ?
         jne       DispVMn0                 ; nen° to aktivn° menu
         or        al,bit0                  ; p©°znak aktivn°ho menu
DispVMn0:mov       ss:[bp-6],ax             ; parametry menu
         mov       ax,ds:[si+MnuAkt]        ; aktivn° poloëka
         mov       ss:[bp-8],ax             ; á°taá aktivn° poloëky
         mov       ax,ds:[si+MnuPol]        ; adresa definice poloëek
         mov       ss:[bp-10],ax            ; ukazatel definice poloëek
         mov       ax,ds:[si+MnuBlk]        ; adresa blokovac° tabulky
         mov       ss:[bp-12],ax            ; ukazatel blokovac° tabulky
         mov       ax,ds:[si+MnuSwch]       ; adresa tabulky p©ep°naáñ
         mov       ss:[bp-14],ax            ; ukazatel tabulky p©ep°naáñ
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen° menu
         mov       ah,0
         mov       ss:[bp-16],ax            ; hladina k zobrazen° menu
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku

; ------ zobrazen° textovÇho ©†dku

DispVMn1:mov       si,ss:[bp-10]            ; adresa definice poloëky
         test      byte ptr ds:[si+MnuParm],bit6 ; je to poloëka ?
         jz        DispVMn2                 ; je to platn† poloëka
         mov       ax,ss:[bp-16]            ; hladina k zobrazen° menu
         mov       cl,ss:[bp-4]             ; ®°©ka okna
         mov       dx,ss:[bp-2]             ; ©†dek a pozice
         push      cs
         call      near ptr DispTxtM        ; zobrazen° textovÇho ©†dku
         jmp       DispVMn8                 ; dal®° ©†dek

; ------ levò okraj ©†dku s poloëkou

DispVMn2:mov       di,sp                    ; adresa bufferu v z†sobn°ku
         cld
         mov       al,"≥"                   ; "≥" levò okraj
         mov       ah,ds:[ColMnu1R]         ; bàën† barva textu
         stosw                              ; uloëen° levÇho okraje

; ------ p©°prava k dek¢dov†n° jednoho ©†dku

         mov       ah,ds:[ColMnu1]
         lodsb                              ; parametry poloëky
         mov       bh,al                    ; parametry
         lodsb                              ; dÇlka textu poloëky
         mov       cl,al                    ; dÇlka textu poloëky
         mov       bl,ss:[bp-4]             ; ®°©ka okna
         sub       bl,3                     ; vnit©n° ®°©ka ©†dku (bez mezery)

; ------ omezen° dÇlky textu poloëky

         cmp       cl,bl                    ; p©ekroáena dÇlka textu ?
         jb        DispVMn3                 ; dÇlka textu je OK
         mov       cl,bl                    ; omezen° dÇlky textu
DispVMn3:sub       bl,cl                    ; zbylò poáet znakñ ©†dku

; ------ p©°prava barvy ©†dku s poloëkou

         mov       dl,ds:[ColMnu1]          ; bàën† barva
         mov       dh,ds:[ColMnu2]          ; zvòraznàn† barva
         mov       ch,ds:[ColMnu5]          ; zak†zan† poloëka
         dec       word ptr ss:[bp-8]       ; á°taá aktivn° poloëky
         jnz       DispVMn4                 ; nen° aktivn° poloëka
         mov       dl,ds:[ColMnu3]          ; bàën† barva kurzoru
         mov       dh,ds:[ColMnu4]          ; zvòraznàn† barva kurzoru
         mov       ch,ds:[ColMnu6]          ; zak†zan† poloëka - kurzor

; ------ oprava barvy zak†zanÇ poloëky podle blokovac° tabulky

DispVMn4:push      bx                       ; parametry poloëky
         mov       bx,ss:[bp-12]            ; ukazatel blokovac° tabulky
         inc       word ptr ss:[bp-12]      ; zvò®en° ukazat. blokovac° tabulky
         cmp       byte ptr ds:[bx],0       ; je to zak†zan† poloëka ?
         pop       bx                       ; parametry poloëky
         je        DispVMn5                 ; nen° to zak†zan† poloëka
         mov       dl,ch                    ; bàën† barva - zak†zan†
         mov       dh,ch                    ; zvòraznàn† barva - zak†zan†

; ------ oprava barvy, nen°-li menu aktivn°

DispVMn5:test      byte ptr ss:[bp-6],bit0  ; je menu aktivn° ?
         jnz       DispVMn6                 ; menu je aktivn°
         mov       dh,dl                    ; zvòraznàn† barva stejn† jako bàën†

; ------ £vodn° mezera na zaá†tku poloëky

DispVMn6:mov       al," "                   ; £vodn° mezera
         mov       ah,dl                    ; bàën† barva textu
         stosw                              ; uloëen° £vodn° mezery

; ------ dek¢dov†n° textu poloëky

         mov       ch,0                     ; CX = dÇlka textu poloëky
         jcxz      DispVM66                 ; nen° text poloëky
         push      bx                       ; parametry poloëky
         and       bh,not bit6 + bit7       ; BH = á°taá horkÇho znaku
DispVM62:lodsb                              ; znak k zobrazen°
;         cmp       al,16                    ; je znak dal®°ho menu ?
;         jne       DispVM63
;         mov       al,ds:[ZnakNxtM]         ; znak dal®°ho menu
DispVM63:mov       ah,dh                    ; barva horkÇho znaku
         dec       bh                       ; á°taá horkÇho znaku
         jz        DispVM64                 ; je horkò znak
         mov       ah,dl                    ; bàën† barva textu
DispVM64:stosw                              ; uloëen° znaku poloëky
         loop      DispVM62                 ; dek¢dov†n° dal®°ho znaku
         pop       bx                       ; parametry poloëky

; ------ vymaz†n° zbytku ©†dku

DispVM66:mov       al," "                   ; znak mezery k vymaz†n°
         mov       ah,dl                    ; bàën† barva textu
         mov       cl,bl                    ; zbylò poáet pozic
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ zobrazen° p©ep°naáe poloëky

         test      bh,bit7                  ; je to p©ep°naá ?
         jz        DispVMn7                 ; nen° to p©ep°naá
         mov       bx,ss:[bp-14]            ; ukazatel tabulky p©ep°naáñ
         inc       word ptr ss:[bp-14]      ; zvò®en° ukazatele p©ep°naáñ
         mov       al,ds:[ZnakSwch+1]       ; "-" p©ep°naá nenastaven
         cmp       byte ptr ds:[bx],0       ; je p©ep°naá nastaven ?
         je        DispVM68                 ; p©ep°naá nen° nastaven
         mov       al,ds:[ZnakSwch]         ; znak p©ep°naáe menu
DispVM68:mov       es:[di-4],al             ; znak p©ep°naáe

; ------ pravò okraj ©†dku

DispVMn7:mov       al,"≥"                   ; "≥" pravò okraj
         mov       ah,ds:[ColMnu1L]         ; bàën† barva textu
         stosw                              ; uloëen° pravÇho okraje

; ------ zobrazen° ©†dku menu

         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,ss:[bp-4]             ; vnit©n° ®°©ka ©†dku
         mov       dx,ss:[bp-2]             ; pozice k zobrazen° ©†dku
         mov       ax,ss:[bp-16]            ; hladina k zobrazen° menu
         push      cs
         call      near ptr DispKStr         ; zobrazen° ©†dku menu

; ------ p©°prava pro dal®° ©†dek

DispVMn8:mov       si,ss:[bp-10]            ; adresa definice poloëky
         cld
         inc       si                       ; p©eskoáen° bajtu parametrñ
         lodsb                              ; dÇlka textu poloëky
         mov       ah,0
         add       si,ax                    ; adresa dal®° poloëky
         mov       ss:[bp-10],si            ; adresa dal®° poloëky
         inc       byte ptr ss:[bp-1]       ; zvò®en° ukazatele ©†dkñ
         dec       byte ptr ss:[bp-3]       ; sn°ëen° á°taáe ©†dkñ
         jz        DispVMn9                 ; jsou jië v®echny ©†dky
         jmp       DispVMn1                 ; dek¢dov†n° dal®°ho ©†dku

; ------ n†vrat registrñ

DispVMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispVMnu ENDP

; *****************************************************************************
;                                EditVMnu
;                        editace vertik†ln°ho menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl†vesa
; VùSTUP:BX=0 kl†vesa byla obslouëena
;        NC=provedena volba poloëky
;        CY=nen° volba, pokraáuje editace
; *****************************************************************************

EditVMnu PROC      FAR

; ------ p©echodnÇ vypnut° menu

         call      far ptr MCtrlO           ; p©echodnÇ vypnut° menu
         jnc       EditVMn0                 ; nebyla funkce Ctrl-O
         ret

; ------ £schova registrñ

EditVMn0:push      ax

; ------ nalezen° horkÇ kl†vesy

         call      far ptr SrcHotM          ; nalezen° horkÇ kl†vesy
         jc        EditVMn2                 ; nenalezena - obsluha kl†vesy

; ------ proveden° volby (zvolena poloëka AX)

EditVMn1:push      cs
         call      near ptr EditMEnt        ; proveden° volby
         jmp       EditVMn9                 ; kl†vesa byla obslouëena OK

; ------ ovl†d†n° p©ep°naáe - mezera

EditVM11:push      cs
         call      near ptr TestMSwc        ; test, zda je to p©ep°naá
         jnc       EditVMn1                 ; proveden° volby p©ep°naáe
         jmp       short EditVM77           ; jinak se nic nedàje

; ------ obsluha kl†vesy "+" - zapnut° p©ep°naáe

EditVMn2:cmp       bl,"+"                   ; je kl†vesa "+" ?
         jne       EditVM24                 ; nen° kl†vesa "+"
         mov       bx,3920h                 ; n†hrada mezerou
         push      cs
         call      near ptr TestMSwc        ; test stavu p©ep°naáe
         jc        EditVM77                 ; nen° to p©ep°naá
         je        EditVMn1                 ; p©ep°naá je vypnutò - OK
EditVM77:jmp       EditVMn7

; ------ obsluha kl†vesy "-"- vypnut° p©ep°naáe

EditVM24:cmp       bl,"-"                   ; je kl†vesa "-" ?
         jne       EditVM26                 ; nen° kl†vesa "-"
         mov       bx,3920h                 ; n†hrada mezerou
         push      cs
         call      near ptr TestMSwc        ; test stavu p©ep°naáe
         jc        EditVM77                 ; nen° to p©ep°naá
         jne       EditVMn1                 ; p©ep°naá je zapnutò - OK
         jmp       short EditVM77

; ------ nalezen° horkÇ kl†vesy s Alt-

EditVM26:push      cs
         call      near ptr SrcHotA         ; nalezen° horkÇ kl†vesy s Alt-
         jnc       EditVM77                 ; kl†vesa nalezena OK

; ------ obsluha ©°dic° kl†vesy (AX=aktivn° poloëka)

         call      far ptr JumpBX           ; obsluha kl†vesy BX

         dw        1c0dh,EditVMn1           ; ENTER
         dw        3920h,EditVM11           ; MEZERA

         dw        4800h,EditVMn3           ; UP
         dw        1205h,EditVMn3           ; Ctrl-E nahoru

         dw        0f00h,EditVMn3           ; *TAB

         dw        5000h,EditVMn5           ; DOWN
         dw        2d18h,EditVMn5           ; Ctrl-X dolñ

         dw        0f09h,EditVMn5           ; TAB

         dw        4700h,EditVMn6           ; HOME
         dw        4900h,EditVMn6           ; PAGEUP
         dw        8400h,EditVMn6           ; ^PAGEUP

         dw        4f00h,EditVMn4           ; END
         dw        5100h,EditVMn4           ; PAGEDOWN
         dw        7600h,EditVMn4           ; ^PAGEDOWN

         dw        MousXKod+MousXLR,EditVM27 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,EditVM28 ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,EditVM28 ; posun my®i

         dw        0,EditVMn8               ; ostatn° kl†vesy - nen° obsluha

; ------ uvolnàn° levÇho tlaá°tka my®i

EditVM27:call      far ptr MouseMnu         ; test, zda je my® v oknà
         jc        EditVMn8                 ; nen° v oknà - nic se nedàje
         mov       bx,1c0dh                 ; kl†vesa Enter
         jmp       EditVMn1

; ------ posun my®i

EditVM28:test      byte ptr ds:[MouseKey],bit1 ; je pouze levÇ tlaá°tko ?
         jnz       EditVMn8                 ; nen° jen levÇ tlaá°tko
         call      far ptr MouseMnu         ; je my® v oknà ?
         jc        EditVMn8                 ; nen° v oknà
         call      VertMPol                 ; poloëka menu z my®i
         jmp       short EditVMn7

; ------ posun kurzoru nahoru

EditVMn3:dec       ax                       ; sn°ëen° á°sla aktivn° poloëky
         jnz       EditVMn7                 ; nebyla to prvn° poloëka

; ------ posledn° poloëka

EditVMn4:mov       ax,ds:[si+MnuNum]        ; poáet platnòch poloëek v menu
         jmp       short EditVMn7

; ------ posun kurzoru dolñ

EditVMn5:inc       ax                       ; zvò®en° á°sla aktivn° poloëky
         cmp       ax,ds:[si+MnuNum]        ; je á°slo poloëky OK ?
         jbe       EditVMn7                 ; á°slo poloëky je OK

; ------ posun na prvn° poloëku

EditVMn6:mov       ax,1                     ; prvn° poloëka

; ------ nastaven° novÇ pozice kurzoru AX

EditVMn7:mov       ds:[si+MnuAkt],ax        ; nov† aktivn° poloëka
         push      cs
         call      near ptr DispMnu         ; novÇ zobrazen° menu
         xor       bx,bx                    ; p©°znak obsluhy kl†vesy
EditVMn8:stc                                ; p©°znak pokraáuj°c° volby

; ------ n†vrat registrñ

EditVMn9:pop       ax
         ret

EditVMnu ENDP

; *****************************************************************************
;                                  MenuNum
;                         zad†n° á°sla ve volbà menu
;              po ukonáen° volby je nutno znovu zobrazit menu !
; -----------------------------------------------------------------------------
; VSTUP: BX=maxim†ln° hodnota á°sla
;        CH=minim†ln° hodnota á°sla
;        CL=dÇlka textu ©†dku (poáet pozic)
;        DL=pozice k zobrazen° textu
;        DH=©†dek k zobrazen° textu
;        ES:DI=adresa bufferu s textem á°sla
;        DS:SI=text n†povàdy
;        DS=datovò segment
; VùSTUP:AX=nov† hodnota á°sla (p©i p©eru®en° CY pñvodn° hodnota á°sla)
;        CY=p©eru®en° operace, n†vrat pñvodn° hodnoty
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) pñvodn° hodnota á°sla
;                   SS:[BP-4] (2) souáasn† hodnota á°sla
;                   SS:[BP-6] (2) maxim†ln° hodnota á°sla
;                   SS:[BP-8] (2) minim†ln° hodnota á°sla
;                   SS:[BP-9] (1) ©†dek na displeji k zobrazen°
;                   SS:[BP-10] (1) pozice ©†dku k zobrazen°
;                   SS:[BP-12] (2) adresa bufferu k dek¢dov†n° textu á°sla
;                   SS:[BP-13] (1) dÇlka textu ©†dku (pozic)
;                   SS:[BP-14] (1) p©°znaky: bit 1 = p©eru®en° editace
;                                            bit 2 = byla zah†jena editace
; *****************************************************************************

MenuNum  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ inicializace lok†ln°ch promànnòch

         sub       sp,14                    ; m°sto pro lok†ln° promànnÇ
         mov       ss:[bp-6],bx             ; maxim†ln° hodnota á°sla
         mov       ss:[bp-13],cl            ; dÇlka ©†dku
         mov       cl,ch                    ; minim†ln° hodnota á°sla
         mov       ch,0
         mov       ss:[bp-8],cx             ; minim†ln° hodnota á°sla
         mov       ss:[bp-10],dx            ; pozice a ©†dek k zobrazen°
         mov       ss:[bp-12],di            ; adresa bufferu textu
         mov       ss:[bp-14],ch            ; p©°znaky <- 0

; ------ zobrazen° textu n†povàdy

         call      far ptr DispHTxt         ; zobrazen° textu n†povàdy

; ------ dek¢dov†n° á°sla z bufferu textu (CH=0 !)

MenuNum1:mov       si,ss:[bp-12]            ; adresa bufferu s textem á°sla
         cld
         xor       di,di                    ; st©adaá á°sla
         mov       cl,ss:[bp-13]            ; dÇlka ©†dku (pozic)
         mov       bh,0                     ; BH <- 0
MenuNm12:mov       bl,es:[si]               ; znak z bufferu
         sub       bl,"0"                   ; korekce na á°slici
         cmp       bl,9                     ; je to platn† á°slice ?
         ja        MenuNm13                 ; nen° to platn† á°slice
         mov       ax,10                    ; n†sobitel st©adaáe
         mul       di                       ; vyn†soben° st©adaáe 10x
         or        dx,dx                    ; p©eteáen° á°sla ?
         jnz       MenuNm14                 ; p©eteáen° á°sla
         add       ax,bx                    ; p©iáten° novÇ á°slice
         jnc       MenuNm15                 ; nen° p©eteáen° á°sla
MenuNm14:mov       ax,0ffffh                ; omezen° velikosti á°sla
MenuNm15:xchg      ax,di                    ; DI <- nov† hodnota st©adaáe
MenuNm13:inc       si                       ; zvò®en° ukazatele textu
         loop      MenuNm12                 ; dek¢dov†n° dal®° á°slice

; ------ uloëen° dek¢dovanÇho á°sla

         mov       ss:[bp-4],di             ; souáasn† hodnota á°sla
         test      byte ptr ss:[bp-14],bit2 ; byla zah†jena editace á°sla ?
         jnz       MenuNm18                 ; byla zah†jena editace á°sla
         mov       ss:[bp-2],di             ; pñvodn° hodnota á°sla

; ------ zobrazen° textu v bufferu

MenuNm18:mov       dx,ss:[bp-10]            ; pozice a ©†dek k zobrazen° textu
         mov       cl,ss:[bp-13]            ; dÇlka textu bufferu
         mov       ah,ds:[ColMnuN]          ; barva textu p©i zad†v†n° á°sla
         mov       si,ss:[bp-12]            ; adresa bufferu textu
         call      far ptr DispTxt          ; zobrazen° textu

; ------ áek†n° na zad†n° znaku (CH=0 !)

MenuNum3:mov       dx,ss:[bp-10]            ; pozice a ©†dek k zobrazen° textu
         mov       cl,ss:[bp-13]            ; dÇlka bufferu á°sla
         add       dl,cl                    ; pozice konce textu
         dec       dx                       ; pozice posledn°ho znaku textu
         call      far ptr SetKurz          ; nastaven° pozice kurzoru
         call      far ptr InpChar          ; vstup znaku z kl†vesnice
         call      far ptr JumpBX           ; obsluha kl†vesy

         dw        011bh,MenuNum4           ; p©eru®en° editace ESC
         dw        1c0dh,MenuNum5           ; ukonáen° editace ENTER
         dw        0e08h,MenuNum6           ; zru®en° znaku BS
         dw        5300h,MenuNum6           ; zru®en° znaku DELETE
         dw        4800h,MenuNm74           ; nahoru - zvò®en° hodnoty á°sla
         dw        5000h,MenuNm77           ; dolñ - sn°ëen° hodnoty á°sla
         dw        MousXKod+MousXLR,MenuNum5 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXRP,MenuNum4 ; stisk pravÇho tlaá°tka my®i
         dw        0,MenuNum7               ; jin† kl†vesa

; ------ p©eru®en° operace Esc

MenuNum4:mov       ax,ss:[bp-2]             ; pñvodn° hodnota á°sla
         mov       ss:[bp-4],ax             ; aktu†ln° hodnota á°sla
         or        byte ptr ss:[bp-14],bit1 ; p©°znak p©eru®en° volby

; ------ ukonáen° operace Enter - omezen° zadanÇho á°sla

MenuNum5:mov       ax,ss:[bp-4]             ; á°slo
         mov       bx,ss:[bp-8]             ; minim†ln° hodnota á°sla
         cmp       ax,bx                    ; je á°slo OK ?
         ja        MenuNm52                 ; á°slo je OK
         mov       ax,bx                    ; omezen° á°sla
MenuNm52:mov       bx,ss:[bp-6]             ; maxim†ln° hodnota á°sla
         cmp       ax,bx                    ; je á°slo OK ?
         jb        MenuNm54                 ; á°slo je OK
         mov       ax,bx                    ; omezen° á°sla
MenuNm54:mov       ss:[bp-4],ax             ; novÇ á°slo

; ------ dek¢dov†n° novÇho á°sla do bufferu (CX=dÇlka bufferu !)

         push      ax                       ; dek¢dovanÇ á°slo
         mov       di,ss:[bp-12]            ; adresa bufferu á°sla
         mov       al," "                   ; mazac° znak mezery
         cld
         rep       stosb                    ; vymaz†n° bufferu á°sla
         pop       ax
         xor       dx,dx                    ; DX <- 0
         xor       bx,bx                    ; barvy ani oddàlovaá se neukl†daj°
         call      far ptr DekNumD          ; dek¢dov†n° á°sla do bufferu
         jmp       short MenuNum8

; ------ zru®en° posledn°ho znaku DELETE, BS (CX=dÇlka bufferu !)

MenuNum6:mov       al," "
         mov       si,ss:[bp-12]            ; adresa bufferu á°sla
MenuNm62:xchg      al,es:[si]               ; posun textu v bufferu
         inc       si                       ; zvò®en° ukazatele textu
         loop      MenuNm62                 ; dal®° znak v bufferu
MenuNm66:or        byte ptr ss:[bp-14],bit2 ; p©°znak zah†jen° editace
         jmp       MenuNum1                 ; novÇ zobrazen° á°sla

; ------ zad†n° novÇ á°slice (CX=dÇlka bufferu !)

MenuNum7:cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         je        MenuNm70                 ; je k¢d my®i
         cmp       bl,"0"
         jb        MenuNm70
         cmp       bl,"9"
         jbe       MenuNm71                 ; je á°slice
MenuNm70:jmp       MenuNum3                 ; dal®° kl†vesa

MenuNm71:test      byte ptr ss:[bp-14],bit2 ; byla prvn° editace ?
         jnz       MenuNm72                 ; byla prvn° editace
         push      cx
         mov       di,ss:[bp-12]            ; buffer textu á°sla
         mov       al," "                   ; mazac° znak mezery
         cld
         rep       stosb                    ; vymaz†n° bufferu á°sla
         pop       cx
MenuNm72:mov       si,ss:[bp-12]            ; buffer textu á°sla
         add       si,cx                    ; adresa konce textu
MenuNm73:dec       si                       ; posun adresy v bufferu
         xchg      bl,es:[si]               ; uloëen° znaku
         loop      MenuNm73                 ; dal®° znak
         jmp       short MenuNm66           ; novÇ zobrazen° á°sla

; ------ zvò®en° hodnoty á°sla (®ipka nahoru)

MenuNm74:mov       si,ss:[bp-12]            ; buffer textu á°sla
         add       si,cx                    ; adresa konce textu
MenuNm75:dec       si                       ; posun adresy v bufferu
         inc       byte ptr es:[si]         ; zvò®en° hodnoty á°sla
         cmp       byte ptr es:[si],"0"
         jae       MenuNm76                 ; á°slo je OK
         mov       byte ptr es:[si],"1"
MenuNm76:cmp       byte ptr es:[si],"9"
         jbe       MenuNm66                 ; á°slo je OK
         mov       byte ptr es:[si],"0"
         loop      MenuNm75
         jmp       short MenuNm66

; ------ sn°ëen° hodnoty á°sla (®ipka dolñ)

MenuNm77:mov       si,ss:[bp-12]            ; buffer textu á°sla
         add       si,cx                    ; adresa konce textu
MenuNm78:dec       si                       ; posun adresy v bufferu
         dec       byte ptr es:[si]         ; sn°ëen° hodnoty á°sla
         cmp       byte ptr es:[si],"0"     ; je p©eteáen° ?
         jae       MenuNm66                 ; á°slo je OK
         mov       byte ptr es:[si],"9"     ; p©eteáen°
         loop      MenuNm78                 ; dal®° á°slo
         jmp       short MenuNm66

; ------ nastaven° p©°znaku p©eru®en° operace

MenuNum8:call      far ptr KurzOff          ; vypnut° kurzoru
         mov       ax,ss:[bp-4]             ; zadan† hodnota
         test      byte ptr ss:[bp-14],bit1 ; bylo p©eru®en° volby ?
         jz        MenuNum9                 ; nebylo p©eru®en° volby
         stc                                ; p©°znak p©eru®en° volby

; ------ n†vrat registrñ

MenuNum9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

MenuNum  ENDP

; *****************************************************************************
;                                  MenBHex
;                     zad†n° bajtu v HEX k¢du ve volbà menu
;              po ukonáen° volby je nutno znovu zobrazit menu !
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice k zobrazen° textu
;        DH=©†dek k zobrazen° textu
;        ES:DI=adresa bufferu s textem á°sla
;        DS:SI=text n†povàdy
;        DS=datovò segment
; VùSTUP:AL=nov† hodnota á°sla (p©i p©eru®en° CY pñvodn° hodnota á°sla)
;        CY=p©eru®en° operace, n†vrat pñvodn° hodnoty
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) pñvodn° hodnota á°sla
;                   SS:[BP-2] (1) souáasn† hodnota á°sla
;                   SS:[BP-3] (1) ©†dek na displeji k zobrazen°
;                   SS:[BP-4] (1) pozice ©†dku k zobrazen°
;                   SS:[BP-6] (2) adresa bufferu k dek¢dov†n° textu á°sla
;                   SS:[BP-7] (1) relativn° pozice kurzoru na ©†dku
; *****************************************************************************

MenBHex  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ inicializace lok†ln°ch promànnòch

         sub       sp,8                     ; m°sto pro lok†ln° promànnÇ
         mov       ss:[bp-4],dx             ; pozice a ©†dek k zobrazen°
         mov       ss:[bp-6],di             ; adresa bufferu textu
         mov       byte ptr ss:[bp-7],0     ; relativn° pozice kurzoru

; ------ zobrazen° textu n†povàdy

         call      far ptr DispHTxt         ; zobrazen° textu n†povàdy

; ------ dek¢dov†n° vòchoz° hodnoty á°sla

         mov       si,ss:[bp-6]             ; adresa bufferu s textem á°sla
         mov       cx,2                     ; 2 znaky
         call      MenHRead                 ; naáten° á°sla z bufferu
         mov       ss:[bp-1],dl             ; pñvodn° hodnota á°sla

; ------ dek¢dov†n° aktu†ln° hodnoty á°sla

MenBHex1:mov       si,ss:[bp-6]             ; adresa bufferu s textem á°sla
         mov       cx,2                     ; 2 znaky
         call      MenHRead                 ; naáten° á°sla z bufferu
         mov       ss:[bp-2],dl             ; aktu†ln° hodnota á°sla

; ------ zobrazen° textu v bufferu

         mov       dx,ss:[bp-4]             ; pozice a ©†dek k zobrazen° textu
         mov       cl,2                     ; dÇlka textu bufferu
         mov       ah,ds:[ColMnuN]          ; barva textu p©i zad†v†n° á°sla
         mov       si,ss:[bp-6]             ; adresa bufferu textu
         call      far ptr DispTxt          ; zobrazen° textu

; ------ áek†n° na zad†n° znaku

MenBHex2:mov       dx,ss:[bp-4]             ; pozice a ©†dek k zobrazen° textu
         add       dl,ss:[bp-7]             ; pozice kurzoru
         call      far ptr SetKurz          ; nastaven° pozice kurzoru
         call      far ptr InpChar          ; vstup znaku z kl†vesnice
         call      far ptr JumpBX

         dw        011bh,MenBHex7           ; ESC
         dw        1c0dh,MenBHex8           ; ENTER
         dw        4b00h,MenBHex6           ; vlevo
         dw        4d00h,MenBHex5           ; vpravo
         dw        4700h,MenBHex6           ; Home
         dw        4f00h,MenBHex5           ; End
         dw        MousXKod+MousXLR,MenBHex8 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXRP,MenBHex7 ; stisk pravÇho tlaá°tka my®i
         dw        0,MenBHex3

; ------ zad†n° znaku

MenBHex3:xchg      ax,bx
         cmp       ah,MousXKod/HI           ; je k¢d my®i ?
         je        MenBHex2                 ; je k¢d my®i
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"0"
         jb        MenBHex2
         cmp       al,"9"
         jbe       MenBHex4
         cmp       al,"A"
         jb        MenBHex2
         cmp       al,"F"
         ja        MenBHex2
MenBHex4:mov       bl,ss:[bp-7]
         mov       bh,0
         add       bx,ss:[bp-6]             ; adresa v bufferu
         mov       es:[bx],al               ; uloëen° á°sla do bufferu

; ------ kurzor vpravo

MenBHex5:cmp       byte ptr ss:[bp-7],1
         je        MenBHx52
         inc       byte ptr ss:[bp-7]
MenBHx52:jmp       MenBHex1

; ------ kurzor vlevo

MenBHex6:cmp       byte ptr ss:[bp-7],0
         je        MenBHex2
         dec       byte ptr ss:[bp-7]
         jmp       short MenBHex2

; ------ p©eru®en° operace Esc - n†vrat pñvodn°ho á°sla

MenBHex7:mov       al,ss:[bp-1]             ; pñvodn° hodnota á°sla
         mov       ah,0                     ; barva nen°
         mov       di,ss:[bp-6]             ; adresa bufferu
         call      far ptr DekHByte         ; dek¢dov†n° bajtu
         call      far ptr KurzOff          ; vypnut° kurzoru
         stc                                ; p©°znak p©eru®en° volby
         jmp       short MenBHex9

; ------ ukonáen° operace Enter

MenBHex8:mov       al,ss:[bp-2]             ; zadanÇ á°slo
         call      far ptr KurzOff          ; vypnut° kurzoru
         clc

; ------ n†vrat registrñ

MenBHex9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         xchg      ax,bx
         pop       ax
         mov       al,bl
         pop       bx
         ret

MenBHex  ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla HEX z bufferu ES:SI -> DX (CX pozic)
; -----------------------------------------------------------------------------

MenHRead PROC      NEAR

         cld
         xor       dx,dx                    ; DL = st©adaá á°sla
MenHRea1:mov       al,es:[si]               ; znak z bufferu
         inc       si
         cmp       al,"A"
         jb        MenHRea2
         sub       al,7
MenHRea2:sub       al,"0"                   ; korekce na á°slici
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         or        dl,al                    ; p©iáten° á°sla
         loop      MenHRea1                 ; dek¢dov†n° dal®° á°slice
         ret

MenHRead ENDP

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

KodFntTb dw        TbKamCS0                 ; konverzn° tabulka k¢dñ

; ------ tabulka evidenc° otev©enòch menu

NumMenu  dw        0                        ; poáet otev©enòch oken menu

TabMenu  label     word
         dw        MenuMax dup(0)           ; tabulka otev©enòch oken menu

PozMenu  label     word
         dw        MenuMax dup(0)           ; poá†teán° pozice otev©enòch menu
SirMenu  label     word
         dw        MenuMax dup(0)           ; velikosti oken otev©enòch menu

AktMenu  dw        0                        ; adresa aktivn°ho menu

;ParMenu  db        0                        ; parametry menu
;                                            ;  bit 0: 1=je trvalÇ hlavn° menu
;                                            ;  bit 1: 1=zobrazeno hlavn° menu
;                                            ;  bit 2: 1=zobrazeno nàjakÇ menu
;                                            ;  bit 3: 1=p©echodnÇ vypnut° oken
;                                            ;  bit 4: 1=autom. vno©en° do menu

LastTime db        0                        ; uschovan† posledn° á°slice áasu
;ColTime  db        74h                      ; barva £daje áasu
;ColDate  db        74h                      ; barva £daje data

InfTxt   db        10,'verze '             ; informaán° text hlavn°ho menu
         db        DMVerze1+"0",".",DMVerze2+"0",DMVerze3+"0" ; á°slo verze

InfTxt1  db        10,'Äekejte...'          ; informaán° text bàhem operace
InfTxt2  db        10,' CHYBA !! '          ; informaán° text p©i INT 24h

;ColMnu1  db        70h                      ; barva textu menu
;ColMnu2  db        74h                      ; barva vysv°cenÇho znaku menu

;ColMnu3  db        30h                      ; text menu - kurzor
;ColMnu4  db        34h                      ; vysv°cenò znak menu - kurzor
;
;ColMnu5  db        71h                      ; barva textu menu - zak†zan† volba
;ColMnu6  db        31h                      ; zak†zan† volba menu - kurzor
;
;ColMnuN  db        0fh                      ; text p©i zad†v†n° á°sla v menu

HelpS    SEGMENT   BYTE PUBLIC
CtrlOTxt db        32,'Stisknàte libovolnou kl†vesu....'; n†povàda funkce Ctrl-O
HelpS    ENDS

VolDTxt1 db        ' volnÇ '
VolDTxt2 label     byte

VolETxt1 db        ' volnÇ '
VolETxt2 db        ' B '

StrnHTxt db        ' strana '
StrnHTx0 label     byte

Data     ENDS

         END

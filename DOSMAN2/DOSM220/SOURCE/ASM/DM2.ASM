
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                    D  M   2
;
;                        hlavn° procedura DOS Manaëeru
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

Code     SEGMENT   WORD PUBLIC
         ASSUME    cs:Code,ds:Data

; *****************************************************************************
;                               StorBCnf
;      uloëen° parametrñ do konfiguraán°ch souboru CNF (n†vrat z BAT)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

StorBCnf PROC      FAR

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
         sub       sp,FileMax

; ------ sestaven° jmÇna souboru

         push      ss
         pop       es                       ; ES <- segment v z†sobn°ku
         mov       si,offset DosmCnf        ; konfiguraán° soubor
         mov       di,sp                    ; ukl†dac° adresa
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ vytvo©en° souboru

         test      byte ptr ds:[TempDirP],bit0 ; je z†kaz z†pisu ?
         jnz       StorBCn9                 ; je z†kaz z†pisu
         mov       si,sp
         call      far ptr CreatFil         ; otev©en° souboru pro áten°
         jc        StorBCn9                 ; chyba - soubor nenalezen

; ------ nastaven° kontroln°ho souátu souboru

         call      far ptr StoPCnf          ; uloëen° konfigurace
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset ConfBeg        ; poá†tek dat
         call      far ptr TestDSum         ; vòpoáet kontroln°ho souátu
         mov       ds:[ConfSumm],dx         ; uloëen° kontroln°ho souátu

; ------ z†pis dat

         mov       cx,offset ConfEnd        ; konec konfigurace
         sub       cx,offset ConfBeg        ; dÇlka konfiguraán°ch dat
         mov       si,di                    ; zaá†tek dat
         call      far ptr WritFile         ; z†pis dat

; ------ uzav©en° souboru

         call      far ptr ClosFile         ; uzav©en° souboru

; ------ n†vrat registrñ

StorBCn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StorBCnf ENDP

; *****************************************************************************
;                               RetPCnf
;              n†vrat parametrñ pro naáten° konfiguraán°ch dat
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

RetPCnf  PROC      FAR

; ------ povolen° pouze adres†©ovòch oken nebo stromu

         and       byte ptr ds:[ParamL],not bit3 ; z†kaz seznamu
         test      byte ptr ds:[ParamL],bit1+bit2 ; je adres†© nebo strom ?
         jnz       RetPCnf1                 ; je to OK
         or        byte ptr ds:[ParamL],bit1 ; povolen adres†©

RetPCnf1:and       byte ptr ds:[ParamR],not bit3
         test      byte ptr ds:[ParamR],bit1+bit2
         jnz       RetPCnf2
         or        byte ptr ds:[ParamR],bit1

RetPCnf2:

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di

;; ------ modul DBF
;
;         mov       al,ds:[SeznPth1]
;         mov       byte ptr ds:[SeznPthN],al
;         mov       al,ds:[SeznPth2]
;         mov       byte ptr ds:[SeznPth0],al

;; ------ modul ZAP
;
;         mov       al,ds:[ZapsPth1]
;         mov       byte ptr ds:[ZapsPthN],al
;         mov       al,ds:[ZapsPth2]
;         mov       byte ptr ds:[ZapsPth0],al

; ------ n†vrat nastaven° voleb menu

         mov       bx,offset TabAMenu       ; tabulka adres
         mov       si,offset UschMenu
RetPCnf3:mov       di,ds:[bx]
         or        di,di
         jz        RetPCnf4
         mov       al,ds:[si]
         mov       byte ptr ds:[di+MnuAkt],al
         inc       si
         inc       bx
         inc       bx
         jmp       short RetPCnf3

RetPCnf4:

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

RetPCnf  ENDP

; *****************************************************************************
;                              StoPCnf
;                uloëen° parametrñ do konfiguraán°ch dat
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

StoPCnf  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ modul DBF

;         mov       al,byte ptr ds:[SeznPthN]
;         mov       ds:[SeznPth1],al
;         mov       al,byte ptr ds:[SeznPth0]
;         mov       ds:[SeznPth2],al

;; ------ modul ZAP
;
;         mov       al,byte ptr ds:[ZapsPthN]
;         mov       ds:[ZapsPth1],al
;         mov       al,byte ptr ds:[ZapsPth0]
;         mov       ds:[ZapsPth2],al

; ------ £schova nastaven° voleb menu

         mov       bx,offset TabAMenu       ; tabulka adres
         mov       si,offset UschMenu
StoPCnf1:mov       di,ds:[bx]
         or        di,di
         jz        StoPCnf2
         mov       al,byte ptr ds:[di+MnuAkt]
         mov       ds:[si],al
         inc       si
         inc       bx
         inc       bx
         jmp       short StoPCnf1

; ------ £schova adres†©e neaktivn°ho okna

StoPCnf2:call      far ptr GetNAWin         ; neaktivn° okno
         mov       si,AWinDir
         mov       di,offset NWinPath       ; neaktivn° okno
StoPCnf3:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         cmp       al,0
         jne       StoPCnf3
         sub       di,offset NWinPath+1
         mov       ds:[NWinPthN],di

; ------ £schova kurzoru aktivn°ho okna

         call      far ptr GetAAWin
         mov       ax,es:[AWinKurz]
         sub       ax,es:[AWinFrst]
         mov       ds:[AWinKOff],ax

         call      far ptr GetAKurz         ; kurzor aktivn°ho okna
         mov       di,offset AWinKFil
         mov       byte ptr ds:[di+1],0     ; soubor neplatnò
;         mov       word ptr ds:[AWinKOff],-1
         jc        StoPCn34
         mov       cx,FileSumm
StoPCn32:mov       al,es:[si]
         mov       ds:[di],al
         inc       di
         inc       si
         loop      StoPCn32

; ------ £schova kurzoru neaktivn°ho okna

StoPCn34:call      far ptr GetNAWin
         mov       ax,es:[AWinKurz]
         sub       ax,es:[AWinFrst]
         mov       ds:[NWinKOff],ax

         call      far ptr GetNKurz         ; kurzor neaktivn°ho okna
         mov       di,offset NWinKFil
         mov       byte ptr ds:[di+1],0
;         mov       word ptr ds:[NWinKOff],-1
         jc        StoPCn38
         mov       cx,FileSumm
StoPCn36:mov       al,es:[si]
         mov       ds:[di],al
         inc       di
         inc       si
         loop      StoPCn36

; ------ n†vrat registrñ

StoPCn38:
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StoPCnf  ENDP

; *****************************************************************************
;                                GetCPar
;                   nalezen° parametru v p©°kazovÇm ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text parametru (velk† p°smena, 1. bajt = dÇlka)
;        DS=datovò segment
; VùSTUP: ES:DI=zaá†tek dat za nalezenòm parametrem
;         CY=parametr nenalezen
; *****************************************************************************

GetCPar  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ p©°prava p©°kazovÇho ©†dku

         cld
         mov       es,ds:[SegPSP]           ; segment PSP
         mov       di,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       bh,0
         mov       bl,es:[di-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       es:[di+bx],bh            ; oznaáen° konce p©°kaz. ©†dku

; ------ nalezen° zaá†tku parametru

GetCPar1:mov       al,es:[di]               ; znak z p©°kazovÇho ©†dku
         inc       di
         cmp       al,TAB
         je        GetCPar1                 ; tabul†tor
         cmp       al," "
         je        GetCPar1                 ; mezera
         jb        GetCPar8                 ; konec p©°kazovÇho ©†dku
         cmp       al,"/"
         jne       GetCPar1                 ; nalezen° zaá†tku parametru

; ------ porovn†n°, zda je to hledanò parametr

         push      si
         push      di

         mov       ah,0
         lodsb                              ; dÇlka textu parametru
         dec       si                       ; p©ednastaven° - 1
         xchg      ax,cx                    ; CX <- dÇlka textu parametru
GetCPar2:mov       al,es:[di]               ; znak z p©°kazovÇho ©†dku
         inc       di
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         inc       si
         cmp       ds:[si],al               ; porovn†n° znaku
         loope     GetCPar2                 ; porovn†n° dal®°ho znaku
         jne       GetCPar4                 ; nen° to hledanò parametr

; ------ test, zda je parametr celò (nesm° n†sledovat p°smeno)

         mov       al,es:[di]               ; dal®° p©ipravenò znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"Z"
         ja        GetCPar7                 ; je konec parametru OK
         cmp       al,"A"
         jb        GetCPar7                 ; je konec parametru OK

; ------ parametr nesouhlas° - test, zda to byl posledn° parametr "/C"

GetCPar4:pop       di
         pop       si
         mov       ax,es:[di]               ; prvn° a druhò znak parametru
         cmp       ax," c"
         je        GetCPar6                 ; parametr "/c" je posledn°
         cmp       ax," C"
         jne       GetCPar1                 ; dal®° parametr
GetCPar6:stc                                ; p©°znak nenalezen° parametru
         jmp       short GetCPar8

; ------ parametr nalezen OK

GetCPar7:pop       si                       ; zru®en° adresy DI
         pop       si
         clc                                ; p©°znak nalezen° parametru

; ------ n†vrat registrñ

GetCPar8:pop       cx
         pop       bx
         pop       ax
         ret

GetCPar  ENDP

; *****************************************************************************
;                                 TestDSum
;                test kontroln°ho souátu datovÇho modulu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa datovÇho modulu
; VùSTUP: DX=kontroln° souáet datovÇho modulu
;         CY=kontroln° souáet nesouhlas° nebo z†hlav° nesouhlas°
; *****************************************************************************

TestDSum PROC      FAR

; ------ £schova registrñ

         push      cx
         push      di

; ------ kontroln° souáet dat

         add       di,6                     ; zaá†tek dat
         mov       cx,offset ConfEnd        ; konec konfigurace
         sub       cx,offset ConfBeg+6      ; dÇlka konfiguraán°ch dat
         mov       dx,2a3eh                 ; vòchoz° konstanta st©adaáe CRC
TestDSm2:rol       dx,1                     ; rotace st©adaáe CRC
         xor       dl,es:[di]               ; p©id†n° dal®°ho bajtu
         inc       di                       ; zvò®en° ukazatele dat
         loop      TestDSm2                 ; dal®° bajt

; ------ n†vrat registrñ

         pop       di
         pop       cx

; ------ kontrola kontroln°ho souátu

         cmp       es:[di+4],dx             ; souhlas° kontroln° souáet ?
         jne       TestDSm8                 ; kontroln° souáet nesouhlas°

; ------ kontrola z†hlav°

         cmp       word ptr es:[di],(DMVerze1 XOR 21h)*HI + "D"
         jne       TestDSm8
         cmp       word ptr es:[di+2],(DMVerze3 XOR 83h)*HI + (DMVerze2 XOR 46h)
         je        TestDSm9                 ; v®e souhlas° OK
TestDSm8:stc                                ; chyba dat
TestDSm9:ret

TestDSum ENDP

; *****************************************************************************
;                                  InitIFHl
;                       naáten° n†povàdy ke kl†vese
; -----------------------------------------------------------------------------
; VSTUP: BX=poá†teán° á°slo n†povàdy v bufferu n†povàd (0, 12, 24, ...)
;        SI=buffer textñ n†povàdy ke kl†ves†m (12 kl†ves po 7 znac°ch)
;        ES:DI=text parametru
; *****************************************************************************

InitIFHl PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp
         mov       bp,bx                    ; BP <- á°slo n†povàdy

; ------ adresa dek¢dovac° tabulky fontñ -> BX

         mov       bx,offset TbLatKam       ; konverze Latin 2 -> Kamenickòch
         cmp       byte ptr ds:[Cod0PagK],2 ; je k¢d Latin 2 ?
         je        InitIFH0                 ; je k¢d Latin 2
         xor       bx,bx                    ; nen° konverze

; ------ nalezen° zaá†tku textu kl†vesy

InitIFH0:mov       dx,12                    ; max. kl†ves
InitIFH1:mov       cx,7                     ; á°taá dÇlky textu kl†vesy
         dec       di
IniIFH12:inc       di
         cmp       byte ptr es:[di],TAB
         je        IniIFH12
         cmp       byte ptr es:[di]," "
         je        IniIFH12

; ------ p©enesen° textu kl†vesy

InitIFH2:mov       al,es:[di]
         cmp       al," "
         jb        InitIFH3
         inc       di
         cmp       al,","
         je        InitIFH3
         jcxz      InitIFH2

         cmp       al,128                   ; je pot©eba p©ek¢dovat ?
         jb        IniIFH22                 ; nen° pot©eba p©ek¢dovat
         or        bx,bx                    ; je konverze ?
         jz        IniIFH22                 ; nen° konverze

         push      ds
         push      cx
         mov       cx,SEG CodeDek           ; segment tabulky
         mov       ds,cx
         sub       al,128
         xlat                               ; konverze znaku
         pop       cx
         pop       ds

IniIFH22:mov       ds:[si],al
         inc       si
         dec       cx
         jmp       short InitIFH2

; ------ vymaz†n° zbytku bufferu kl†vesy

InitIFH3:jcxz      InitIFH4
IniIFH32:mov       byte ptr ds:[si]," "
         inc       si
         loop      IniIFH32

; ------ p©°prava pro dal®° kl†vesu

InitIFH4:dec       dx                       ; á°taá kl†ves
         jnz       InitIFH1

; ------ adresa bufferu n†povàd -> ES

         mov       ax,ds:[HelpFSeg]         ; segment n†povàd
         call      far ptr GetDat           ; adresa bufferu

; ------ ukl†dac° adresa do bufferu -> SI

         mov       si,2                     ; poá†teán° adresa v bufferu
         or        bp,bp                    ; je prvn° n†povàda ?
         jz        IniIFH52                 ; je prvn° n†povàda
         mov       ah,0
InitIFH5:lods      byte ptr es:[si]
         add       si,ax
         dec       bp
         jnz       InitIFH5
IniIFH52:mov       dx,12                    ; max. n†povàd

; ------ zru®en° starÇho textu n†povàdy

InitIFH6:inc       si
         push      di
         mov       di,si
         mov       ax,ds:[HelpFSeg]         ; segment n†povàd
         call      far ptr GetDat           ; adresa bufferu
         xor       cx,cx
         xchg      cl,es:[di-1]
         jcxz      IniIFH61
         call      far ptr DelDat           ; zru®en° starÇho textu
IniIFH61:pop       di

; ------ adresa inicializaán°ho bufferu -> ES

         push      cs
         call      near ptr GetDIni         ; adresa inicializaán°ho bufferu

; ------ nalezen° konce ©†dku -> DI (AX)

         dec       di
IniIFH62:inc       di
         cmp       byte ptr es:[di],TAB
         je        IniIFH62
         cmp       byte ptr es:[di]," "
         jae       IniIFH62
         mov       ax,di                    ; £schova konce ©†dku

; ------ nalezen° zaá†tku dal®°ho ©†dku -> DI

         mov       cx,es:[InitByts]         ; poáet bajtñ v bufferu
         dec       di
IniIFH64:inc       di
         cmp       di,cx                    ; jsou dal®° data ?
         jae       InitIFH8                 ; nejsou dal®° data
         cmp       byte ptr es:[di],TAB
         je        IniIFH66
         cmp       byte ptr es:[di]," "
         jb        IniIFH64
         ja        InitIFH8                 ; nen° dal®° ©†dek n†povàdy

; ------ nalezen° zaá†tku textu ©†dku -> DI

IniIFH66:dec       di
IniIFH67:inc       di
         cmp       byte ptr es:[di],TAB
         je        IniIFH67
         cmp       byte ptr es:[di]," "
         je        IniIFH67

; ------ stanoven° dÇlky textu

         xor       cx,cx                    ; á°taá dÇlky textu
         push      di
         dec       di
         dec       cx
IniIFH68:inc       di
         inc       cx
         cmp       byte ptr es:[di]," "
         jae       IniIFH68
         pop       di

; ------ vytvo©en° m°sta k vloëen° textu do bufferu

         cmp       cx,255
         jb        IniIFH69
         mov       cx,255                   ; omezen° dÇlky textu
IniIFH69:mov       ax,ds:[HelpFSeg]         ; segment n†povàd
         push      di
         mov       di,si
         call      far ptr InsDat           ; vytvo©en° m°sta k vloëen° param.
         pop       di
         jc        InitIFH9                 ; chyba pamàti

; ------ p©enesen° textu parametru

         push      ds

         push      dx
         call      far ptr GetSgAdr         ; adresa segmentu n†povàd
         push      cs
         call      near ptr GetDIni         ; adresa inicializaán°ho bufferu
         mov       ds,dx                    ; DS <- segment inic. souboru
         pop       dx

         mov       ds:[si-1],cl             ; dÇlka textu n†povàdy
         jcxz      IniIFH74
InitIFH7:mov       al,es:[di]

         cmp       al,128                   ; je pot©eba p©ek¢dovat ?
         jb        IniIFH72                 ; nen° pot©eba p©ek¢dovat
         or        bx,bx                    ; je konverze ?
         jz        IniIFH72                 ; nen° konverze

         push      ds
         push      cx
         mov       cx,SEG CodeDek           ; segment tabulky
         mov       ds,cx
         sub       al,128
         xlat                               ; konverze znaku
         pop       cx
         pop       ds

IniIFH72:mov       ds:[si],al
         inc       si
         inc       di
         loop      InitIFH7

IniIFH74:pop       ds

; ------ p©°prava pro dal®° ©†dek

         dec       dx
         jz        IniIFH76
         jmp       InitIFH6

IniIFH76:xchg      ax,di
InitIFH8:xchg      ax,di

; ------ n†vrat registrñ

InitIFH9:push      cs
         call      near ptr GetDIni         ; adresa inicializaán°ho bufferu

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitIFHl ENDP

;; *****************************************************************************
;;                            GetYPIni
;;        poskytnut° parametru p©ep°naáe YES/NO (mus° bòt otev©ena skupina)
;; -----------------------------------------------------------------------------
;; VSTUP: DS:SI=text jmÇna parametru (1. bajt = dÇlka textu)
;;        DS=datovò segment
;; VùSTUP: CY=parametr nedefinov†n nebo chyba pamàti
;;         CX=stav p©ep°naáe (1=YES, 0=NO)
;; *****************************************************************************
;
;GetYPIni PROC      FAR
;
;         push      bx
;         push      di
;
;         xor       cx,cx
;         mov       di,offset YNIniTxt       ; tabulka YES/NO
;         call      far ptr GetSPIni         ; poskytnut° stavu p©ep°naáe
;         jc        GetYPIn2
;         dec       bx
;         jnz       GetYPIn2                 ; NO
;         inc       cx                       ; YES
;
;GetYPIn2:pop       di
;         pop       bx
;         ret
;
;GetYPIni ENDP
;
;; *****************************************************************************
;;                               GetSPIni
;;           poskytnut° parametru p©ep°naáe (mus° bòt otev©ena skupina)
;; -----------------------------------------------------------------------------
;; VSTUP: DS:SI=text jmÇna parametru (1. bajt = dÇlka textu)
;;        DS:DI=tabulka stavñ p©ep°naáe (slova, 1.bajt=dÇlka slova, 0=konec)
;;        DS=datovò segment
;; VùSTUP: CY=parametr nedefinov†n nebo chyba pamàti
;;         BX=á°slo parametru (0=nedefinov†n nebo chyba)
;; *****************************************************************************
;
;GetSPIni PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      es
;
;; ------ nalezen° poëadovanÇho parametru
;
;         push      di                       ; tabulka slov p©ep°naáe
;         call      far ptr OpenPIni         ; otev©en° parametru
;         pop       si                       ; tabulka slov p©ep°naáe
;         jc        GetSPIn8                 ; chyba pamàti
;
;; ------ nalezen° zaá†tku parametru
;
;         dec       di                       ; p©ednastaven°
;GetSPIn1:inc       di                       ; zvò®en° ukazatele textu
;         mov       al,es:[di]               ; znak parametru
;         cmp       al,";"
;         je        GetSPIn8                 ; nen° parametr
;         cmp       al,","
;         je        GetSPIn8                 ; nen° parametr
;         cmp       al,TAB
;         je        GetSPIn1                 ; tabul†tor se p©eskoá°
;         cmp       al," "
;         je        GetSPIn1                 ; mezera se p©eskoá°
;         jb        GetSPIn8                 ; konec ©†dku - parametr nenalezen
;
;; ------ p©°prava k porovn†n° jednoho parametru
;
;         cld
;         mov       ch,0
;         xor       bx,bx                    ; p©°prava á°taáe parametrñ
;GetSPIn2:mov       cl,ds:[si]               ; dÇlka jednoho slova
;         jcxz      GetSPIn8                 ; konec - p©ep°naá nenalezen
;         inc       si                       ; zaá†tek slova parametru
;         inc       bx                       ; á°slo parametru
;
;; ------ porovn†n° jednoho parametru
;
;         push      si
;         push      cx
;         push      di
;
;GetSPIn3:lodsb                              ; naáten° znaku p©ep°naáe
;         cmp       al,"a"
;         jb        GetSPIn4
;         cmp       al,"z"
;         ja        GetSPIn4
;         sub       al,32                    ; konverze na velkÇ p°smeno
;
;GetSPIn4:mov       ah,es:[di]
;         inc       di
;         cmp       ah,"a"
;         jb        GetSPIn5
;         cmp       ah,"z"
;         ja        GetSPIn5
;         sub       ah,32                    ; konverze na velkÇ p°smeno
;
;GetSPIn5:cmp       al,ah                    ; je shoda ?
;         loope     GetSPIn3                 ; shoda - dal®° znak
;         jne       GetSPIn6                 ; nen° shoda
;
;         mov       al,es:[di]               ; n†sleduj°c° znak
;         cmp       al,","
;         je        GetSPIn6                 ; konec parametru
;         cmp       al,";"
;         je        GetSPIn6                 ; konec parametru
;         cmp       al," "
;         ja        GetSPIn6                 ; to nen° konec parametru
;         cmp       al,al                    ; p©°znak ZY, ëe je konec parametru
;
;GetSPIn6:pop       di
;         pop       cx
;         pop       si
;         je        GetSPIn9                 ; p©ep°naá nalezen OK
;
;; ------ p©°prava pro dal®° parametr
;
;         add       si,cx                    ; dal®° p©ep°naá
;         jmp       short GetSPIn2           ; dal®° p©ep°naá
;
;; ------ parametr nenalezen nebo nepovolenÇ nastaven° p©ep°naáe
;
;GetSPIn8:xor       bx,bx                    ; nen° parametr
;         stc                                ; p©°znak neplatnÇho parametru
;
;; ------ n†vrat registrñ
;
;GetSPIn9:pop       es
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;GetSPIni ENDP
;
;; *****************************************************************************
;;                              GetBPIni
;;        poskytnut° numerickÇho parametru - bajt (mus° bòt otev©ena skupina)
;; -----------------------------------------------------------------------------
;; VSTUP: DS:SI=text jmÇna parametru (1. bajt = dÇlka textu)
;;        DS=datovò segment
;; VùSTUP: CY=parametr nedefinov†n nebo chyba pamàti
;;         AL=naátenÇ á°slo
;; *****************************************************************************
;
;GetBPIni PROC      FAR
;
;         push      dx
;         mov       dl,ah
;         call      far ptr GetWPIni         ; naáten° parametru - slovo
;         jc        GetBPIn9                 ; chyba
;         or        ah,ah                    ; je v°ce neë 255 ?
;         jz        GetBPIn9                 ; nen° v°c neë 255
;         mov       al,-1                    ; omezen° velikosti á°sla
;GetBPIn9:mov       ah,dl
;         pop       dx
;         ret
;
;GetBPIni ENDP
;
;; *****************************************************************************
;;                              GetWPIni
;;        poskytnut° numerickÇho parametru - slovo (mus° bòt otev©ena skupina)
;; -----------------------------------------------------------------------------
;; VSTUP: DS:SI=text jmÇna parametru (1. bajt = dÇlka textu)
;;        DS=datovò segment
;; VùSTUP: CY=parametr nedefinov†n nebo chyba pamàti
;;         AX=naátenÇ á°slo
;; *****************************************************************************
;
;GetWPIni PROC      FAR
;
;         push      dx
;         call      far ptr GetNPIni         ; naáten° á°selnÇho parametru
;         jc        GetWPIn9                 ; chyba
;         or        dx,dx                    ; je > 64 KB ?
;         jz        GetWPIn9                 ; nen° v°c
;         mov       ax,-1                    ; omezen° velikosti á°sla
;GetWPIn9:pop       dx
;         ret
;
;GetWPIni ENDP
;
;; *****************************************************************************
;;                              GetNPIni
;;        poskytnut° numerickÇho parametru (mus° bòt otev©ena skupina)
;; -----------------------------------------------------------------------------
;; VSTUP: DS:SI=text jmÇna parametru (1. bajt = dÇlka textu)
;;        DS=datovò segment
;; VùSTUP: CY=parametr nedefinov†n nebo chyba pamàti
;;         DX:AX=naátenÇ á°slo
;; *****************************************************************************
;
;GetNPIni PROC      FAR
;
;; ------ £schova registrñ
;
;         push      bx
;         push      cx
;         push      di
;         push      es
;
;; ------ nalezen° poëadovanÇho parametru
;
;         call      far ptr OpenPIni         ; otev©en° parametru
;         jc        GetNPIn9                 ; chyba pamàti
;
;; ------ p©°prava k dek¢dov†n° parametru
;
;         xor       bx,bx                    ; st©adaá á°sla HIGH
;         xor       cx,cx                    ; st©adaá á°sla LOW
;
;; ------ nalezen° zaá†tku parametru (a naáten° prvn° á°slice)
;
;GetNPIn1:mov       al,es:[di]               ; znak
;         inc       di                       ; zvò®en° ukazatele znakñ
;         cmp       al,TAB
;         je        GetNPIn1                 ; tabel†tor se ignoruje
;         cmp       al," "
;         je        GetNPIn1                 ; mezera se ignoruje
;         sub       al,"0"                   ; je platnò znak á°slice ?
;         jb        GetNPIn9                 ; nen° platnò znak á°slice
;         cmp       al,9+1
;         cmc
;         jc        GetNPIn9                 ; nen° platnò znak á°slice
;
;; ------ p©iáten° á°slice ke st©adaái
;
;GetNPIn2:mov       ah,0
;         push      ax                       ; nov† á°slice
;         mov       ax,10
;         mul       cx                       ; vyn†soben° st©adaáe LOW
;         xchg      ax,cx                    ; CX <- novò st©adaá LOW
;         mov       ax,10
;         xchg      ax,dx                    ; AX <- novò st©adaá HIGH
;         xchg      ax,bx                    ; AX <- st©adaá HIGH, BX<-novò HIGH
;         mul       dx                       ; vyn†soben° st©adaáe HIGH
;         add       bx,ax                    ; BX <- novò st©adaá HIGH
;         adc       dx,dx                    ; p©iáten° p©enosu
;         pop       ax                       ; p©id†van† á°slice
;         add       cx,ax                    ; p©iáten° novÇ á°slice
;         adc       bx,dx                    ; p©enos HIGH (DX m† bòt = 0 !)
;         adc       dx,dx                    ; je p©eteáen° ?
;         jz        GetNPIn3                 ; nen° p©eteáen° á°sla
;
;         mov       bx,-1                    ; omezen° á°sla HIGH
;         mov       cx,bx                    ; omezen° á°sla LOW
;
;; ------ naáten° dal®° á°slice
;
;GetNPIn3:mov       al,es:[di]               ; znak
;         inc       di                       ; zvò®en° ukazatele znakñ
;         sub       al,"0"                   ; je platnò znak á°slice ?
;         jb        GetNPIn5                 ; nen° platnò znak á°slice
;         cmp       al,9
;         jbe       GetNPIn2                 ; je platnò znak á°slice
;GetNPIn5:clc                                ; p©°znak operace OK
;
;; ------ n†vrat registrñ
;
;GetNPIn9:xchg      ax,cx                    ; naátenÇ á°slo LOW
;         mov       dx,bx                    ; naátenÇ á°slo HIGH
;         pop       es
;         pop       di
;         pop       cx
;         pop       bx
;         ret
;
;GetNPIni ENDP

; *****************************************************************************
;                            OpenPIni
;    otev©en° parametru v inicializaán°m souboru (mus° bòt otev©ena skupina)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text jmÇna parametru (1. bajt = dÇlka textu)
;        DS=datovò segment
; VùSTUP: CY=parametr nenalezen
;         ES:DI=zaá†tek argumentu parametru (adresa za znakem "=")
; *****************************************************************************

OpenPIni PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ adresa segmentu

         mov       ax,ds:[SegmIni]          ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu

; ------ p©°prava k nalezen° parametru

         mov       di,ds:[GroupAdr]         ; adresa zaá†tku skupiny
         mov       ch,0
         mov       cl,ds:[si]               ; dÇlka textu parametru
         inc       si                       ; zaá†tek textu parametru
         mov       bx,es:[InitByts]         ; adresa konce souboru
         mov       dx,di                    ; £schova adresy platnÇho ©†dku
         cld

; ------ test, zda je konec skupiny

OpenPIn2:cmp       di,bx                    ; je konec souboru ?
         jae       OpenPIn5                 ; je konec souboru
         cmp       byte ptr es:[di],";"     ; je koment†© ?
         je        OpenPIn4                 ; je koment†©
         cmp       byte ptr es:[di]," "     ; je platnò ©†dek ?
         jbe       OpenPIn4                 ; nen° platnò ©†dek
         cmp       byte ptr es:[di],"["     ; je dal®° skupina ?
         je        OpenPIn5                 ; je dal®° skupina
         mov       dx,di                    ; p©°padn† adresa k vytvo©en° param.

; ------ porovn†n° textu parametru

         push      si
         push      di
         push      cx

OpenPIn3:lodsb                              ; znak jmÇna skupiny
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         xchg      al,ah
         mov       al,es:[di]
         inc       di
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         xchg      al,ah
         cmp       al,ah                    ; souhlas° znak ?
         loope     OpenPIn3                 ; znak souhlas° OK
         jne       OpenPI36                 ; text nesouhlas°

OpenPI35:mov       al,es:[di]
         inc       di
         cmp       al,"="
         je        OpenPIn7
         cmp       al,TAB
         je        OpenPI35                 ; tabul†tor se p©eskoá°
         cmp       al," "
         je        OpenPI35                 ; mezera se p©eskoá°
         dec       di                       ; jinò znak - navr†cen°
         jmp       short OpenPIn7

OpenPI36:pop       cx
         pop       di
         pop       si

; ------ nen° poëadovanò parametr - nalezen° dal®°ho ©†dku

OpenPIn4:inc       di                       ; zvò®en° ukazatele ©†dku
         cmp       di,bx                    ; je konec dat ?
         jae       OpenPIn5                 ; je konec dat
         cmp       byte ptr es:[di-1],LF    ; nalezen dal®° ©†dek ?
         jne       OpenPIn4                 ; nalezen° dal®°ho ©†dku
         jmp       short OpenPIn2           ; test dal®°ho ©†dku

; ------ vytvo©en° m°sta k vloëen° parametru

OpenPIn5:
;         mov       di,dx                    ; adresa k vytvo©en° parametru
;         add       cx,3                     ; oddàlovaá "=" a CR/LF
;         mov       ax,ds:[SegmIni]          ; segment s bufferem
;         call      far ptr InsDat           ; vytvo©en° m°sta k vloëen° param.
;         jc        OpenPIn9                 ; chyba
;
;; ------ p©enesen° textu parametru
;
;         cld
;         sub       cx,3
;         rep       movsb                    ; p©enesen° jmÇna parametru
;         mov       al,"="
;         stosb
;         mov       word ptr es:[di],CR+LF*HI ; konec ©†dku
         stc
         jmp       short OpenPIn9

; ------ text nalezen OK

OpenPIn7:add       sp,2*3                   ; zru®en° registrñ v z†sobn°ku
OpenPIn8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

OpenPIn9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenPIni ENDP

; *****************************************************************************
;                              OpenGIni
;     Otev©en° skupiny v inicializaán°m souboru (nen° t©eba otev°rat soubor)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text jmÇna skupiny (1. bajt = dÇlka textu)
;        DS=datovò segment
; VùSTUP: CY=nedostatek pamàti nebo soubor neexistuje
; *****************************************************************************

OpenGIni PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en° segmentu

         call      far ptr OpenIni          ; otev©en° souboru
         jnc       OpenGIn1
         jmp       OpenGIn9                 ; chyba

; ------ adresa segmentu

OpenGIn1:mov       ax,ds:[SegmIni]          ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu

; ------ p©°prava k vyhled†n° skupiny

         mov       ch,0
         mov       cl,ds:[si]               ; dÇlka jmÇna skupiny
         inc       si                       ; zaá†tek textu jmÇna skupiny
         mov       di,InitData              ; zaá†tek dat
         mov       bx,es:[InitByts]         ; konec dat
         cld

; ------ test, zda je konec dat

OpenGIn2:cmp       di,bx                    ; je konec dat ?
         jae       OpenGIn6                 ; je konec dat

; ------ test, zda je ©†dek skupiny

         cmp       byte ptr es:[di],"["     ; je ©†dek skupiny ?
         jne       OpenGIn4                 ; nen° ©†dek skupiny

; ------ porovn†n° textu skupiny

         push      si
         push      di
         push      cx

OpenGIn3:lodsb                              ; znak jmÇna skupiny
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         inc       di
         xchg      al,ah
         mov       al,es:[di]
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         xchg      al,ah
         cmp       al,ah                    ; souhlas° znak ?
         loope     OpenGIn3                 ; znak souhlas° OK
         jne       OpenGI36                 ; text nesouhlas°
         cmp       byte ptr es:[di+1],"]"   ; je konec jmÇna skupiny ?

OpenGI36:pop       cx
         pop       di
         pop       si
         je        OpenGIn5                 ; text nalezen OK

; ------ ©†dek nesouhlas° - nalezen° dal®°ho ©†dku

OpenGIn4:inc       di                       ; zvò®en° ukazatele dat
         cmp       di,bx                    ; je konec dat ?
         jae       OpenGIn6                 ; je konec dat
         cmp       byte ptr es:[di-1],LF    ; nalezen dal®° ©†dek ?
         jne       OpenGIn4                 ; nalezen° dal®°ho ©†dku
         jmp       short OpenGIn2           ; test dal®°ho ©†dku

; ------ skupina nalezena OK - nalezen° zaá†tku dal®°ho ©†dku

OpenGIn5:inc       di                       ; zvò®en° ukazatele dat
         cmp       di,bx                    ; je konec dat ?
         jae       OpenGIn7                 ; je konec dat
         cmp       byte ptr es:[di-1],LF    ; nalezen dal®° ©†dek ?
         jne       OpenGIn5                 ; nalezen° dal®°ho ©†dku
         jmp       short OpenGIn7

; ------ skupina nenalezena - vytvo©en° novÇ skupiny

OpenGIn6:mov       di,bx                    ; konec dat v bufferu
         add       cx,4                     ; p©iáten° okrajñ
         mov       ax,ds:[SegmIni]          ; segment bufferu
         call      far ptr InsDat           ; zaloëen° novÇ skupiny
         jc        OpenGIn9                 ; chyba pamàti

; ------ p©enesen° textu skupiny

         cld
         mov       al,"["
         stosb
         sub       cx,4
         rep       movsb                    ; p©enesen° jmÇna skupiny
         mov       al,"]"
         stosb
         mov       ax,CR + LF*HI
         stosw                              ; konec ©†dku

; ------ adresa je platn†

OpenGIn7:mov       ds:[GroupAdr],di         ; adresa skupiny
         clc                                ; operace OK

; ------ n†vrat registrñ

OpenGIn9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenGIni ENDP

; *****************************************************************************
;                               InitIBNm
;                      naáten° parametru - bajt
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel parametru
; VùSTUP: AL=naátenÇ á°slo
;         CY=nen° platnÇ á°slo
; *****************************************************************************

InitIBNm PROC      FAR

         push      dx
         push      ax

         push      cs
         call      near ptr InitIWNm
         jc        InitIBN9
         or        ah,ah
         jz        InitIBN9
         mov       al,-1
InitIBN9:xchg      ax,dx

         pop       ax
         mov       al,dl
         pop       dx
         ret

InitIBNm ENDP

; *****************************************************************************
;                               InitIWNm
;                      naáten° parametru - slovo
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel parametru
; VùSTUP: AX=naátenÇ á°slo
;         CY=nen° platnÇ á°slo
; *****************************************************************************

InitIWNm PROC      FAR

         push      dx

         push      cs
         call      near ptr InitINum
         jc        InitIWN9
         or        dx,dx
         jz        InitIWN9
         mov       ax,-1

InitIWN9:pop       dx
         ret

InitIWNm ENDP

; *****************************************************************************
;                             InitINum
;                    naáten° á°sla - dvojslovo
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel parametru
; VùSTUP: DX:AX=naátenÇ á°slo
;         CY=nen° platnÇ á°slo
; *****************************************************************************

InitINum PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx

; ------ p©°prava st©adaáe

         xor       cx,cx                    ; st©adaá LOW
         xor       bx,bx                    ; st©adaá HIGH

; ------ test prvn° á°slice

         call      InitINNm                 ; naáten° prvn° á°slice
         jc        InitINm9

; ------ vyn†soben° st©adaáe 10x

InitINm1:push      ax
         mov       ax,10
         mul       bx
         xchg      ax,bx
         mov       ax,10
         mul       cx
         xchg      ax,cx
         add       bx,dx
         pop       ax

; ------ p©id†n° á°slice ke st©adaái

         mov       ah,0
         add       cx,ax
         adc       bx,0

; ------ naáten° dal®° á°slice

         call      InitINNm
         jnc       InitINm1
         clc

; ------ n†vrat registrñ

InitINm9:xchg      ax,cx                    ; AX <- naátenÇ á°slo LOW
         mov       dx,bx                    ; DX <- naátenÇ á°slo HIGH
         pop       cx
         pop       bx
         ret

InitINum ENDP

; -----------------------------------------------------------------------------
;        naáten° dekadickÇ á°slice z ES:DI -> AL, CY=nen° á°slice
; -----------------------------------------------------------------------------

InitINNm PROC      NEAR

         mov       al,es:[di]
         cmp       al,"9"+1
         cmc
         jc        IniINNm9
         sub       al,"0"
         jc        IniINNm9
         inc       di
IniINNm9:ret

InitINNm ENDP

; *****************************************************************************
;                                  InitIBHx
;                             naáten° bajtu HEX
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel parametru
; VùSTUP: AL=naátenÇ á°slo
;         CY=nen° platnÇ á°slo
; *****************************************************************************

InitIBHx PROC      FAR

         cmp       byte ptr es:[di],"$"
         stc
         jne       InitIBH9
         inc       di

; ------ naáten° HEX znaku bez prefixu

InitIBH1 LABEL     FAR

         call      InitINHx
         jc        InitIBH9
         mov       ah,al

         call      InitINHx
         jc        InitIBH3
         shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1
         or        ah,al
InitIBH3:mov       al,ah
         clc

InitIBH9:ret

InitIBHx ENDP

; -----------------------------------------------------------------------------
;        naáten° á°slice HEX
; -----------------------------------------------------------------------------

InitINHx PROC      NEAR

         mov       al,es:[di]
         inc       di
         call      far ptr UpCase

         cmp       al,"9"
         jbe       IniINHx4
         cmp       al,"F"
         ja        IniINHx8
         cmp       al,"A"
         jb        IniINHx8
         sub       al,7
IniINHx4:sub       al,"0"
         jnc       IniINHx9

IniINHx8:dec       di
         stc
IniINHx9:ret

InitINHx ENDP

; *****************************************************************************
;                                 InitIPCh
;                     naáten° parametru - definice znaku
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel na parametr
; VùSTUP: CY=nen° platn† definice
;         AL=definice znaku
; *****************************************************************************

InitIPCh PROC      FAR

; ------ interpretace jako á°slo

         push      cs
         call      near ptr InitIBNm        ; naáten° á°sla
         jnc       IniIPCh9                 ; je to á°slo OK

; ------ intepretace jako HEX á°slo

         push      cs
         call      near ptr InitIBHx        ; naáten° bajtu HEX
         jnc       IniIPCh9

; ------ interpretace jako ASCII znak

         cmp       byte ptr es:[di],'"'
         stc
         jne       IniIPCh9
         inc       di
         mov       al,es:[di]
         inc       di
         clc

IniIPCh9:ret

InitIPCh ENDP

; *****************************************************************************
;                                 InitIOdd
;                     Naáten° znaku oddàlovaáe data, áasu atd.
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel na parametr
; VùSTUP: CY=nen° oddàlovaá
;         AL=znak oddàlovaáe
; *****************************************************************************

InitIOdd PROC      FAR

         mov       al,es:[di]
         inc       di
         cmp       al,"."
         je        InitIOd9
         cmp       al,":"
         je        InitIOd9
         cmp       al,"/"
         je        InitIOd9
         cmp       al,","
         je        InitIOd9
         cmp       al,"-"
         je        InitIOd9
         dec       di
         stc
InitIOd9:ret

InitIOdd ENDP

; *****************************************************************************
;                                InitIPYN
;                       test, zda je parametr Y nebo N
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel na parametr
; VùSTUP: CY=nen° Y ani N
;         CX=stav p©ep°naáe (-1=YES, 0=NO)
; *****************************************************************************

InitIPYN PROC      FAR

         push      ax
         xor       cx,cx                    ; nen° p©ep°naá
         mov       al,es:[di]               ; p©ipravenò znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"N"
         je        IniIPYN9                 ; je "NO"
         dec       cx
         cmp       al,"Y"
         je        IniIPYN9                 ; je "YES"
         stc                                ; p©°znak chybnÇho p©ep°naáe
IniIPYN9:pop       ax
         ret

InitIPYN ENDP

; *****************************************************************************
;                               InitIPFl
;                         naáten° jmÇna souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=zaá†tek parametru (nejsou mezery)
;        DS:SI=buffer k uloëen° jmÇna souboru (dÇlka FileMax)
; VùSTUP: CY=nen° parametr
;         DS:SI=adresa konce textu
;         CX=dÇlka textu
; *****************************************************************************

InitIPFl PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ naáten° znaku

         xor       cx,cx                    ; CX <- 0 á°taá dÇlky jmÇna souboru
InitIPF2:mov       al,es:[di]               ; naáten° znaku
         inc       di

; ------ test, zda je konec ©†dku

         cmp       al,";"
         je        InitIPF4
         cmp       al," "
         jb        InitIPF4

; ------ uloëen° znaku

         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       cl,FileMax-1
         jae       InitIPF2                 ; je jië plnò buffer
         mov       ds:[si],al               ; uloëen° znaku
         inc       si                       ; zvò®en° ukl†dac° adresy
         inc       cx                       ; zvò®en° á°taáe dÇlky
         jmp       short InitIPF2

; ------ vypu®tàn° mezer na konci textu

InitIPF4:dec       di                       ; n†vrat neplatnÇho znaku
InitIPF5:stc
         jcxz      InitIPF9                 ; nen° dal®° znak - nen° jmÇno
         cmp       byte ptr ds:[si-1]," "
         jne       InitIPF6
         dec       si
         dec       cx
         jmp       short InitIPF5

; ------ oznaáen° konce textu

InitIPF6:mov       byte ptr ds:[si],0
         clc

; ------ n†vrat registrñ

InitIPF9:pop       ax
         ret

InitIPFl ENDP

; *****************************************************************************
;                            InitICar
;                     vypu®tàn° á†rky mezi parametry
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel textu
; *****************************************************************************

InitICar PROC      FAR

         push      cs
         call      near ptr InitISpc        ; vypu®tàn° mezer
         cmp       byte ptr es:[di],","
         jne       InitICr4
         inc       di
         push      cs
         call      near ptr InitISpc        ; vypu®tàn° mezer
InitICr4:ret

InitICar ENDP

; *****************************************************************************
;                                 InitISpc
;                              vypu®tàn° mezer
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel textu
; *****************************************************************************

InitISpc PROC      FAR

         dec       di
IniISpc2:inc       di
         cmp       byte ptr es:[di]," "
         je        IniISpc2
         cmp       byte ptr es:[di],TAB
         je        IniISpc2
         ret

InitISpc ENDP

; *****************************************************************************
;                               JumpPShd
;            Skok na obsluhu parametru v ©†dku s á†steánou shodou
; -----------------------------------------------------------------------------
;   Procedura se vol† instrukc° CALL FAR JumpLIni, za kterou n†sleduje tabulka
;   skokñ. Procedura zmàn° svou n†vratovou adresu na adresu podle nalezenÇ
;   poloëky v tabulce (nebo podle poloëky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa textu jmÇna parametru
;        v z†sobn°ku 2 slova (n†vratov† adresa FAR) = zaá†tek tabulky skokñ
;             stuktura tabulky: 1 bajt = dÇlka jmÇna parametru
;                               x bajtñ = jmÇno parametru (velk† p°smena)
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 bajt = 0 (p©°znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen° k¢du
; VùSTUP: ES:DI=ukazatel textu ihned za jmÇnem parametru
;         AX=po©adovÇ á°slo poloëky 1... (0=nenalezeno)
; *****************************************************************************

JumpPShd PROC      FAR

; ------ £schova registrñ
                                            ; SS:[BP+16] CS
                                            ; SS:[BP+14] IP
         push      bx                       ; SS:[BP+12] BX
         push      cx                       ; SS:[BP+10] CX
         push      si                       ; SS:[BP+ 8] SI
         push      di                       ; SS:[BP+ 6] DI
         push      bp                       ; SS:[BP+ 4] BP
         push      ds                       ; SS:[BP+ 2] DS
         push      es                       ; SS:[BP+ 0] ES
         mov       bp,sp
         sub       sp,40                    ; buffer pro text jmÇna parametru

; ------ dek¢dov†n° textu parametru do bufferu

         xor       cx,cx                    ; CX <- 0 á°taá dÇlky textu
         mov       si,sp                    ; SI <- buffer v z†sobn°ku
         mov       ah,0                     ; 0 = nebyl znak "="
JumpPSh1:mov       al,es:[di]               ; znak jmÇna parametru
         cmp       al," "
         jbe       JumpPSh2                 ; konec jmÇna parametru
         cmp       al,"="
         je        JumpPSh2
         cmp       al,"]"
         je        JumpPSh2
         cmp       al,"/"
         je        JumpPSh2
         inc       di                       ; zvò®en° ukazatele textu
         cmp       cl,40                    ; maxim†ln° dÇlka textu
         jae       JumpPSh2
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         mov       ss:[si],al               ; uloëen° znaku do bufferu
         inc       si
         inc       cx
         jmp       short JumpPSh1

; ------ p©°prava k vyhled†n° parametru

JumpPSh2:cld
         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
         lds       si,ss:[bp+14]            ; ukazatel tabulky
         push      ss
         pop       es
         mov       ah,0
         cmp       byte ptr ds:[si],90h     ; je NOP pro TASM 3.x ?
         jne       JumpPSh4
         inc       si                       ; p©eskoáen° instrukce NOP

; ------ dÇlka jmÇna dal®°ho parametru

JumpPSh4:inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         lodsb                              ; naáten° dÇlky jmÇna
         cmp       al,0                     ; je konec tabulky ?
         je        JumpPSh7                 ; je konec tabulky

; ------ porovn†n° jednoho textu parametru

         cmp       al,cl                    ; souhlas° dÇlka jmÇna ?
         ja        JumpPSh5                 ; dÇlka jmÇna nesouhlas°
         mov       di,sp                    ; jmÇno promànnÇ v z†sobn°ku
         push      si
         push      cx
         mov       cl,al
         repe      cmpsb                    ; porovn†n° textu parametru
         pop       cx
         pop       si
         je        JumpPSh8                 ; parametr nalezen OK

; ------ parametr nesouhlas° - dal®° parametr

JumpPSh5:add       si,ax                    ; adresa dal®°ho parametru
         inc       si
         inc       si                       ; p©eskoáen° adresy skoku
         jmp       short JumpPSh4           ; test dal®°ho parametru

; ------ adresa skoku

JumpPSh7:xor       bx,bx                    ; BX <- 0 poloëka nenalezena
JumpPSh8:add       si,ax                    ; p©eskoáen° jmÇna poloëky
         add       ss:[bp+6],ax             ; posun adresy textu
         lodsw                              ; adresa skoku
         mov       ss:[bp+14],ax            ; adresa skoku na obsluhu parametru
         xchg      ax,bx                    ; AX <- po©adovÇ á°slo poloëky

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

JumpPShd ENDP

; *****************************************************************************
;                               JumpPTxt
;                    Skok na obsluhu parametru v ©†dku
; -----------------------------------------------------------------------------
;   Procedura se vol† instrukc° CALL FAR JumpLIni, za kterou n†sleduje tabulka
;   skokñ. Procedura zmàn° svou n†vratovou adresu na adresu podle nalezenÇ
;   poloëky v tabulce (nebo podle poloëky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa textu jmÇna parametru
;        v z†sobn°ku 2 slova (n†vratov† adresa FAR) = zaá†tek tabulky skokñ
;             stuktura tabulky: 1 bajt = dÇlka jmÇna parametru
;                               x bajtñ = jmÇno parametru (velk† p°smena)
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 bajt = 0 (p©°znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen° k¢du
; VùSTUP: ES:DI=ukazatel hodnoty parametru (za znakem =, ], mezerami)
;         AX=po©adovÇ á°slo poloëky 1... (0=nenalezeno)
; *****************************************************************************

JumpPTxt PROC      FAR

; ------ £schova registrñ
                                            ; SS:[BP+16] CS
                                            ; SS:[BP+14] IP
         push      bx                       ; SS:[BP+12] BX
         push      cx                       ; SS:[BP+10] CX
         push      si                       ; SS:[BP+ 8] SI
         push      di                       ; SS:[BP+ 6] DI
         push      bp                       ; SS:[BP+ 4] BP
         push      ds                       ; SS:[BP+ 2] DS
         push      es                       ; SS:[BP+ 0] ES
         mov       bp,sp
         sub       sp,40                    ; buffer pro text jmÇna parametru

; ------ dek¢dov†n° textu parametru do bufferu

         xor       cx,cx                    ; CX <- 0 á°taá dÇlky textu
         mov       si,sp                    ; SI <- buffer v z†sobn°ku
         mov       ah,0                     ; 0 = nebyl znak "="
JumpPTx1:mov       al,es:[di]               ; znak jmÇna parametru
         cmp       al," "
         jbe       JumpPTx2                 ; konec jmÇna parametru
         cmp       al,"="
         je        JumpPTx2
         cmp       al,"]"
         je        JumpPTx2
         cmp       al,";"
         je        JumpPTx2
         cmp       al,"/"
         je        JumpPTx2
         inc       di                       ; zvò®en° ukazatele textu
         cmp       cl,40                    ; maxim†ln° dÇlka textu
         jae       JumpPTx1
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         mov       ss:[si],al               ; uloëen° znaku do bufferu
         inc       si
         inc       cx
         jmp       short JumpPTx1

; ------ nalezen° zaá†tku hodnoty parametru

JumpPT12:mov       ah,al                    ; AH <- byl znak "=" (pop©. "]")
JumpPTx2:mov       al,es:[di]
         cmp       al,LF
         je        JumpPTx3
         cmp       al,CR
         je        JumpPTx3
         cmp       al,";"
         je        JumpPTx3
         cmp       al,0
         je        JumpPTx3
         cmp       al,"/"
         je        JumpPTx3
         cmp       al,"("
         je        JumpPTx3
         cmp       al,ah
         je        JumpPTx3                 ; tento znak jië jednou byl
         inc       di
         cmp       al,"]"
         je        JumpPT12
         cmp       al,"="
         je        JumpPT12
         cmp       al," "
         jbe       JumpPTx2
         dec       di
JumpPTx3:mov       ss:[bp+6],di

; ------ p©°prava k vyhled†n° parametru

         cld
         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
         lds       si,ss:[bp+14]            ; ukazatel tabulky
         push      ss
         pop       es
         mov       ah,0
         cmp       byte ptr ds:[si],90h     ; je NOP pro TASM 3.x ?
         jne       JumpPTx4
         inc       si                       ; p©eskoáen° instrukce NOP

; ------ dÇlka jmÇna dal®°ho parametru

JumpPTx4:inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         lodsb                              ; naáten° dÇlky jmÇna
         cmp       al,0                     ; je konec tabulky ?
         je        JumpPTx7                 ; je konec tabulky

; ------ porovn†n° jednoho textu parametru

         cmp       al,cl                    ; souhlas° dÇlka jmÇna ?
         jne       JumpPTx5                 ; dÇlka jmÇna nesouhlas°
         mov       di,sp                    ; jmÇno promànnÇ v z†sobn°ku
         repe      cmpsb                    ; porovn†n° textu parametru
         je        JumpPTx8                 ; parametr nalezen OK
         xchg      ax,cx                    ; CX <- dÇlka jmÇna; AX <- zbytek

; ------ parametr nesouhlas° - dal®° parametr

JumpPTx5:add       si,ax                    ; adresa dal®°ho parametru
         inc       si
         inc       si                       ; p©eskoáen° adresy skoku
         jmp       short JumpPTx4           ; test dal®°ho parametru

; ------ adresa skoku

JumpPTx7:xor       bx,bx                    ; BX <- 0 poloëka nenalezena
JumpPTx8:lodsw                              ; adresa skoku
         mov       ss:[bp+14],ax            ; adresa skoku na obsluhu parametru
         xchg      ax,bx                    ; AX <- po©adovÇ á°slo poloëky

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

JumpPTxt ENDP

; *****************************************************************************
;                             NextGIni
;               Nalezen° dal®° skupiny inicializaán°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel v bufferu inicializaán°ho souboru
; VùSTUP: ES:DI=nov† adresa v bufferu
;         CY=nen° dal®° skupina
; *****************************************************************************

NextGIni PROC      FAR

NextGIn1:push      cs
         call      near ptr NextLIni        ; nalezen° dal®°ho ©†dku
         jc        NextGIn2                 ; nen° dal®° ©†dek
         cmp       byte ptr es:[di],"["     ; je skupina ?
         jne       NextGIn1                 ; dal®° ©†dek
NextGIn2:ret

NextGIni ENDP

; *****************************************************************************
;                               NextLIni
;              Nalezen° dal®°ho ©†dku inicializaán°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel v bufferu inicializaán°ho souboru
; VùSTUP: ES:DI=nov† adresa v bufferu
;         CY=nen° dal®° ©†dek
; *****************************************************************************

NextLIni PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      ds

; ------ p©°prava registrñ

         push      es
         pop       ds
         mov       cx,ds:[InitByts]         ; poáet bajtñ v bufferu
         xchg      si,di
         cld

; ------ test, zda jsou dal®° data

NextLIn1:cmp       si,cx
         jae       NextLIn8

; ------ nalezen° konce ©†dku

NextLIn2:lodsb
         cmp       al,CR
         je        NextLIn3
         cmp       al,EOF
         je        NextLIn8                 ; konec souboru
         cmp       al,LF
         jne       NextLIn2

; ------ vypu®tàn° znakñ konce ©†dku

NextLIn3:cmp       si,cx
         jae       NextLIn8
         lodsb
         cmp       al,CR
         je        NextLIn3
         cmp       al,LF
         je        NextLIn3

; ------ test, zda je to platnò ©†dek

         cmp       al," "
         jbe       NextLIn1                 ; nen° platnò ©†dek
         cmp       al,";"
         je        NextLIn1                 ; pozn†mka
         dec       si                       ; n†vrat ukazatele textu
         stc                                ; p©°znak platnÇho ©†dku

; ------ n†vrat registrñ

NextLIn8:cmc
         xchg      si,di
         pop       ds
         pop       cx
         pop       ax
         ret

NextLIni ENDP

; *****************************************************************************
;                               NextTIni
;        Nalezen° dal®°ho ©†dku inicializaán°ho souboru - i s mezerami
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel v bufferu inicializaán°ho souboru
; VùSTUP: ES:DI=nov† adresa v bufferu (mñëe zaá°nat i mezerou a tabul†torem)
;         CY=nen° dal®° ©†dek
; *****************************************************************************

NextTIni PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      ds

; ------ p©°prava registrñ

         push      es
         pop       ds
         mov       cx,ds:[InitByts]         ; poáet bajtñ v bufferu
         xchg      si,di
         cld

; ------ test, zda jsou dal®° data

NextTIn1:cmp       si,cx
         jae       NextTIn8

; ------ nalezen° konce ©†dku

NextTIn2:lodsb
         cmp       al,CR
         je        NextTIn3
         cmp       al,LF
         jne       NextTIn2

; ------ vypu®tàn° znakñ konce ©†dku

NextTIn3:cmp       si,cx
         jae       NextTIn8
         lodsb
         cmp       al,CR
         je        NextTIn3
         cmp       al,LF
         je        NextTIn3

; ------ test, zda je to platnò ©†dek

         cmp       al,";"
         je        NextTIn1                 ; pozn†mka
         cmp       al,TAB
         je        NextTIn4
         cmp       al," "
         jb        NextTIn1                 ; nen° platnò ©†dek
NextTIn4:dec       si                       ; n†vrat ukazatele textu
         stc                                ; p©°znak platnÇho ©†dku

; ------ n†vrat registrñ

NextTIn8:cmc
         xchg      si,di
         pop       ds
         pop       cx
         pop       ax
         ret

NextTIni ENDP

; *****************************************************************************
;                             GetDIni
;       Poskytnut° adresy bufferu inicializaán°ho souboru (mus° existovat)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: ES=adresa bufferu inicializaán°ho souboru
; *****************************************************************************

GetDIni  PROC      FAR

         push      ax
         mov       ax,ds:[SegmIni]
         call      far ptr GetDat
         pop       ax
         ret

GetDIni  ENDP

; *****************************************************************************
;                                 OpenIni
;                      Otev©en° inicializaán°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti (segment nevytvo©en)
; *****************************************************************************

OpenIni  PROC      FAR

; ------ test, zda je segment jië vytvo©en

         cmp       word ptr ds:[SegmIni],0  ; je segment jië vytvo©en ?
         je        OpenIni1                 ; segment nen° je®tà vytvo©en
         ret

; ------ £schova registrñ

OpenIni1:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en° segmentu

         mov       al,ds:[CodePagK]         ; k¢dov† str†nka
         mov       ds:[Cod0PagK],al         ; £schova k¢dovÇ str†nky

         mov       bx,InitData+100          ; inicializaán° velikost
         call      far ptr CreatDat         ; vytvo©en° datovÇho bloku
         jnc       OpenIni2
         jmp       OpenIni9                 ; nedostatek pamàti
OpenIni2:mov       ds:[SegmIni],ax          ; á°slo segmentu

; ------ inicializace dat segmentu

         call      far ptr GetDat           ; adresa segmentu
         mov       word ptr es:[InitParm],0 ; parametry

; ------ sestaven° jmÇna souboru

         mov       di,InitPath              ; buffer k uloëen° jmÇna souboru
         mov       si,offset DosmIni        ; jmÇno souboru DOSMAN.INI
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ otev©en° souboru

         mov       si,InitPath              ; jmÇno souboru
         xor       cx,cx                    ; nejsou ë†dn† data
         call      far ptr OpenR            ; otev©en° alespo§ pro áten°
         jc        OpenIni5                 ; soubor nenalezen

; ------ naáten° souboru do pamàti

         mov       di,InitData              ; buffer k naáten° dat
         sub       bx,InitData+3            ; volnÇ m°sto v bufferu + rezerva
         mov       cx,bx                    ; volnÇ m°sto v bufferu
         call      far ptr ReadFile         ; naáten° souboru
         jc        OpenIni3                 ; chyba áten°
         cmp       cx,bx                    ; je soubor naáten celò ?
         jb        OpenIni4                 ; soubor naáten celò
         mov       cx,bx
OpenIni3:or        byte ptr es:[InitParm],bit1 ; z†kaz z†pisu

; ------ uzav©en° souboru

OpenIni4:call      far ptr ClosFile         ; uzav©en° souboru

; ------ adresa konce souboru

OpenIni5:mov       bx,InitData              ; velikost popisovaáe
         add       bx,cx                    ; konec dat v souboru
         jcxz      OpenIni7                 ; nejsou ë†dn† data

; ------ p©echodnÇ odstranàn° EOF na konci souboru

         cmp       byte ptr es:[bx-1],EOF
         jne       OpenIni6
         dec       bx

; ------ zaji®tàn° CR/LF na konci souboru

OpenIni6:cmp       byte ptr es:[bx-1],LF
         je        OpenIni7
         cmp       byte ptr es:[bx-1],CR
         je        OpenIni7
         mov       word ptr es:[bx],CR + LF*HI
         inc       bx
         inc       bx                       ; zvò®en° velikosti dat v bufferu

; ------ zaji®tàn° EOF na konci souboru

OpenIni7:mov       byte ptr es:[bx],EOF
         inc       bx

; ------ zmen®en° velikosti segmentu na BX bajtñ dat

         mov       es:[InitByts],bx         ; poáet bajtñ v segmentu
         mov       ax,ds:[SegmIni]          ; segment bufferu
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu

; ------ test, zda je identifik†tor n†rodn°ho k¢du

         mov       di,InitData              ; zaá†tek textu v bufferu
         mov       si,offset IdntISwT       ; p©ep°naá
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        OpenIni8                 ; nen° p©ep°naá

; ------ naáten° n†rodn°ho k¢du

         mov       si,offset KodISwcT       ; n†rodn° k¢d
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        OpenIni8                 ; nen° p©ep°naá
         cmp       al,ds:[CodePagK]         ; je pot©eba zmànit k¢d ?
         je        OpenIni8                 ; nen° pot©eba zmànit k¢d

; ------ konverze n†rodn°ho k¢du

         xchg      ax,cx                    ; CL <- aktu†ln° k¢d
         mov       dl,bit1                  ; p©°prava
         shl       dl,cl                    ; DL = aktu†ln° k¢d
         mov       cl,ds:[CodePagK]         ; poëadovan† k¢dov† str†nka
         cmp       cl,0                     ; je k¢d zn†mò ?
         jne       OpenIn72                 ; k¢d je zn†mò
         mov       cl,1                     ; implicitn° k¢d Kamenickòch
OpenIn72:mov       dh,bit1                  ; p©°prava
         shl       dh,cl                    ; DH = poëadovanò k¢d
         mov       si,di                    ; SI <- zaá†tek textu
         mov       cx,es:[0]                ; poáet bajtñ v bufferu
         sub       cx,si                    ; CX <- dÇlka textu
         call      far ptr KonvFnt          ; konverze fontñ
OpenIni8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

OpenIni9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenIni  ENDP

; *****************************************************************************
;                                  ClosIni
;                      uzav©en° inicializaán°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba (nelze uloëit zmàny)
; *****************************************************************************

ClosIni  PROC      FAR

; ------ test, zda je segment jië uzav©en

         cmp       word ptr ds:[SegmIni],0  ; je jië uzav©en ?
         jne       ClosIni1                 ; nen° je®tà uzav©en
         ret

; ------ £schova registrñ

ClosIni1:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,FileMax               ; m°sto pro jmÇno souboru

; ------ adresa segmentu

         mov       ax,ds:[SegmIni]
         call      far ptr GetDat           ; adresa segmentu

; ------ test, zda byl soubor modifikov†n

         test      byte ptr es:[InitParm],bit0 ; byl soubor modifikov†n ?
         jz        ClosIni8                 ; soubor nebyl modifikov†n
         test      byte ptr es:[InitParm],bit1 ; je z†kaz z†pisu ?
         jnz       ClosIni8                 ; je z†kaz z†pisu

; ------ p©°prava jmÇna souboru do bufferu

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       si,InitPath              ; jmÇno souboru
         push      es

         push      di
         push      ds
         push      es
         push      ss
         pop       es
         pop       ds
         mov       cx,FileMax
         cld
         rep       movsb                    ; p©enesen° textu do z†sobn°ku
         pop       ds
         pop       si

; ------ vytvo©en° vòstupn°ho souboru

         call      far ptr CreatPF          ; vytvo©en° p©echodnÇho souboru
         pop       es
         jc        ClosIni9                 ; chyba

; ------ z†pis dat do souboru

         mov       cx,es:[InitByts]         ; velikost bufferu
         mov       si,InitData              ; zaá†tek dat
         sub       cx,si                    ; velikost dat v bufferu
         jcxz      ClosIni4
         push      si
         add       si,cx                    ; adresa konce dat
         cmp       byte ptr es:[si-1],EOF   ; je EOF na konci souboru ?
         pop       si
         jne       ClosIni4                 ; nen° EOF
         dec       cx                       ; odstranàn° koncovÇho EOF
ClosIni4:call      far ptr WritFile         ; z†pis dat do bufferu

; ------ uzav©en° souboru

         pushf
         call      far ptr ClosFile         ; uzav©en° souboru
         popf
         jc        ClosIn72                 ; chyba z†pisu

; ------ zru®en° pñvodn°ho souboru

         mov       si,InitPath
         call      far ptr DelFile          ; zru®en° pñvodn°ho souboru

; ------ p©ejmenov†n° souboru

         mov       dx,es                    ; segment novÇho jmÇna
         mov       di,InitPath
         push      ss
         pop       es                       ; ES <- segment souáasnÇho jmÇna
         mov       si,sp                    ; souáasnÇ jmÇno
         jc        ClosIni7                 ; chyba zru®en° souboru
         call      far ptr RenFile          ; p©ejmenov†n° souboru
         jmp       short ClosIni8

; ------ chyba zru®en° pñvodn°ho souboru - pokus o p©ejmenov†n°

ClosIni7:call      far ptr RenFile          ; p©ejmenov†n° souboru
         jnc       ClosIni8                 ; operace OK

; ------ p©i chybà zru®en° novÇho souboru

ClosIn72:push      ss
         pop       es
         mov       si,sp
         call      far ptr DelFile
         stc
         jmp       short ClosIni9

; ------ zru®en° segmentu

ClosIni8:mov       ax,ds:[SegmIni]          ; segment
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[SegmIni],ax          ; zru®en° segmentu
         clc

; ------ n†vrat registrñ

ClosIni9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ClosIni  ENDP

;IFDEF    DEBUG
;; -----------------------------------------------------------------------------
;;        zobrazen° stop bodu p©i ladàn°
;; -----------------------------------------------------------------------------
;
;StopBod  PROC      FAR
;
;         pushf
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;         push      ds
;
;         mov       ax,0b800h
;         mov       ds,ax
;         mov       word ptr ds:[0],"@" + 74h*HI
;
;         mov       ah,0
;         int       16h
;
;         pop       ds
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         popf
;         ret
;
;StopBod  ENDP
;
;ENDIF

; -----------------------------------------------------------------------------
;        zobrazen° DEMO hl†®en°
; -----------------------------------------------------------------------------

DispDemo PROC      FAR

         pushf
         test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         jz        DispDem8                 ; nen° DEMO verze

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

         mov       si,offset DemoMenu
         call      far ptr Lin0Menu
         dec       bx                       ; je volba 1 ?
         jz        DispDem2                 ; je volba 1
         js        DispDem2                 ; je p©eru®en° operace

         mov       ax,Hlp@LegalniSoftware   ; hlavn° str†nka
         call      far ptr HelpF            ; n†povàda

DispDem2:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
DispDem8:popf
         ret

DispDemo ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;           Inicializace parametrñ programu z konfiguraán°ho souboru
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; *****************************************************************************
;                                 InitIni
;                inicializace podle konfiguraán°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************
;˛
InitIni  PROC      NEAR

; ------ otev©en° inicializaán°ho souboru

         call      far ptr OpenIni          ; otev©en° inicializaán°ho souboru
         jnc       InitIn02                 ; operace OK
         ret                                ; chyba

InitIni8:call      far ptr ClosIni          ; uzav©en° inicializaán°ho souboru
InitIni9:ret

; ------ test, zda je prvn° ©†dek parametr

InitIn02:call      far ptr GetDIni          ; adresa bufferu souboru
         mov       di,InitData              ; zaá†tek dat
InitIni0:cmp       di,es:[InitByts]
         jae       InitIni8
         cmp       byte ptr es:[di],"["
         je        InitIni2

; ------ nalezen° dal®° skupiny parametrñ

InitIni1:call      far ptr NextGIni         ; dal®° skupina parametrñ
         jc        InitIni8                 ; konec parametrñ
InitIni2:inc       di                       ; p©eskoáen° znaku "["

         call      far ptr JumpPTxt

         db        6,'DOSMAN'
         dw        InitIni3

         db        6,'WINDOW'
         dw        InitIni4

         db        7,'DISPLAY'
         dw        InitIni5

         db        4,'DISK'
         dw        InitIni6

         db        5,'COLOR'
         dw        InitIni7

         db        4,'MONO'
         dw        InitIn72

         db        6,'EDITOR'
         dw        InitIn74

         db        0
         dw        InitIni1

InitIni3:call      InitIDos                 ; skupina "DosMan"
         jmp       short InitIni0

InitIni4:call      far ptr InitIWin         ; skupina "Window"
         jmp       short InitIni0

InitIni5:call      far ptr InitIDis         ; skupina "Display"
         jmp       short InitIni0

InitIni6:call      far ptr InitIDsk         ; skupina "Disk"
         jmp       short InitIni0

InitIni7:mov       bx,offset ColColo        ; barvy pro barevnò m¢d
InitIn71:call      InitICol                 ; inicializace barev
         jmp       short InitIni0

InitIn72:mov       bx,offset ColMono        ; barvy pro áernob°lò m¢d
         jmp       short InitIn71

InitIn74:call      far ptr InitIEdi         ; skupina "Editor"
         jmp       InitIni0

InitIni  ENDP

; *****************************************************************************
;                                InitICol
;                          inicializace barev
; -----------------------------------------------------------------------------
; VSTUP: BX=adresa tabulky barev (COLOR nebo MONO)
;        DS=datovò segment
; *****************************************************************************

InitICol PROC      NEAR

; ------ nalezen° dal®°ho parametru

InitICl1:call      far ptr NextLIni         ; dal®° ©†dek
         jnc       InitICl2                 ; je dal®° ©†dek OK
IniICl12:ret

InitICl2:cmp       byte ptr es:[di],"["
         je        IniICl12
         call      far ptr JumpPTxt

; ------ nemànit po©ad° - pouë°v† se á°slo volby !

         db        7,'DBFSTAT'              ; 1: nadpis okna DBF
         dw        InitICl3

         db        7,'DBFBROW'              ; 2: ©†dkovò reëim DBF
         dw        InitICl3

         db        7,'DBFPAGE'              ; 3: str†nkovò reëim DBF
         dw        InitICl3

         db        7,'DBFVIEW'              ; 4: rychlò prohl°ëeá DBF
         dw        InitICl3

         db        4,'FORM'                 ; 5: form†tov†n°
         dw        InitICl3

         db        5,'VERIF'                ; 6: verifikace
         dw        InitICl3

         db        5,'CDISK'                ; 7: CD disk
         dw        InitICl3

         db        8,'DISKEDIT'             ; 8: editor disku
         dw        InitICl3

         db        4,'EDIT'                 ; 9: textovò editor
         dw        InitICl3

         db        4,'INFO'                 ; 10: informaán° ©†dek
         dw        InitICl3

         db        5,'MHELP'                ; 11: mal† n†povàda
         dw        InitICl3

         db        7,'COMLINE'              ; 12: p©°kazovò ©†dek
         dw        InitICl3

         db        4,'FIND'                 ; 13: hled†n°
         dw        InitICl3

         db        4,'MENU'                 ; 14: menu
         dw        InitICl3

         db        8,'USERMENU'             ; 15: uëivatelskÇ menu
         dw        InitICl3

         db        5,'UNDEL'                ; 16: obnoven° souborñ
         dw        InitICl3

         db        6,'DIRWIN'               ; 17: adres†©ovÇ okno
         dw        InitICl3

         db        8,'GROUPCOL'             ; 18: skupiny souborñ
         dw        InitICl3

         db        4,'TREE'                 ; 19: strom
         dw        InitICl3

         db        5,'NOTES'                ; 20: z†pisn°k
         dw        InitICl3

         db        5,'ASCII'                ; 21: ASCII tabulka
         dw        InitICl3

         db        5,'CLOCK'                ; 22: hodiny
         dw        InitICl3

         db        4,'HELP'                 ; 23: n†povàda
         dw        InitICl3

         db        5,'TABLE'                ; 24: tabulka
         dw        InitICl3

         db        4,'DIAR'                 ; 25: kalend†©
         dw        InitICl3

         db        0
         dw        InitICl1

; ------ adresy sady barev
;˛
InitIClT label     word
         dw        ColDBF1-ColsBeg          ; 1: nadpis okna DBF
         dw        ColDBF2-ColsBeg          ; 2: ©†dkovò reëim DBF
         dw        ColDBF12-ColsBeg         ; 3: str†nkovò reëim DBF
         dw        ColDBF7-ColsBeg          ; 4: rychlò prohl°ëeá DBF
         dw        ColFRam-ColsBeg          ; 5: form†tov†n°
         dw        ColDMapS-ColsBeg         ; 6: verifikace a mapa
         dw        CDColInd-ColsBeg         ; 7: CD disk
         dw        ColDZob0-ColsBeg         ; 8: editor disku
         dw        ColEdi1-ColsBeg          ; 9: textovò editor
         dw        InfoCol1-ColsBeg         ; 10: informaán° ©†dek
         dw        HelpColN-ColsBeg         ; 11: mal† n†povàda
         dw        LinePCol-ColsBeg         ; 12: p©°kazovò ©†dek
         dw        ColLWin1-ColsBeg         ; 13: hled†n° souborñ
         dw        ColTime-ColsBeg          ; 14: menu
         dw        UMnuCol1-ColsBeg         ; 15: uëivatelskÇ menu
         dw        ColUnd1-ColsBeg          ; 16: obnoven° souborñ
         dw        ColAWin1-ColsBeg         ; 17: adres†©ovÇ okno
         dw        ColAWinT-ColsBeg         ; 18: skupiny souborñ
         dw        ColTWin1-ColsBeg         ; 19: strom
         dw        ColText1-ColsBeg         ; 20: z†pisn°k
         dw        ColT1-ColsBeg            ; 21: ASCII tabulka
         dw        ColHod-ColsBeg           ; 22: hodiny
         dw        ColHlp1-ColsBeg          ; 23: n†povàda
         dw        ColTBLRm-ColsBeg         ; 24: tabulka
         dw        DiarColV-ColsBeg         ; 25: kalend†©

; ------ poáty barev v sadà barev

InitIClN label     byte
         db        2                        ; 1: nadpis okna DBF
         db        7                        ; 2: ©†dkovò reëim DBF
         db        4                        ; 3: str†novò reëim DBF
         db        1                        ; 4: rychlò prohl°ëeá DBF
         db        5                        ; 5: form†tov†n°
         db        6                        ; 6: verifkace a mapa disku
         db        1                        ; 7: CD disk
         db        5                        ; 8: editor disku
         db        7                        ; 9: textovò editor
         db        2                        ; 10: informaán° ©†dek
         db        6                        ; 11: mal† n†povàda
         db        3                        ; 12: p©°kazovò ©†dek
         db        6                        ; 13: hled†n° souborñ
         db        19                       ; 14: menu
         db        11                       ; 15: uëivatelskÇ menu
         db        4                        ; 16: obnoven° souborñ
         db        4                        ; 17: adres†©ovÇ okno
         db        14                       ; 18: skupiny souborñ
         db        7                        ; 19: strom
         db        6                        ; 20: z†pisn°k
         db        4                        ; 21: ASCII tabulka
         db        1                        ; 22: hodiny
         db        11                       ; 23: n†povàda
         db        13                       ; 24: tabulka
         db        1                        ; 25: kalend†©

; ------ obsluha sady barev AX

InitICl3:xchg      ax,si                    ; SI <- á°slo sady barev
         mov       ch,0
         mov       cl,cs:[InitIClN+si-1]    ; CX <- poáet barev
         shl       si,1                     ; á°slo sady * 2
         mov       si,cs:[InitIClT+si-2]    ; SI <- offset sady barev
         add       si,bx                    ; SI <- adresa sady barev

         call      far ptr InitISpc         ; vypu®tàn° mezer
InitICl4:call      far ptr InitIBH1         ; naáten° bajtu HEX
         jc        InitICl5                 ; bajt nedefinov†n
         or        al,al                    ; je to platn† hodnota ?
         jz        InitICl5                 ; nen° to platn† hodnota
         mov       ds:[si],al               ; uloëen° hodnoty bajtu
InitICl5:inc       si                       ; zvò®en° ukazatele textu
         call      far ptr InitICar         ; vypu®tàn° p©°padnÇ á†rky
         loop      InitICl4                 ; dal®° parametr
         jmp       InitICl1

InitICol ENDP

; *****************************************************************************
;                                   InitIDos
;                    inicializace z†kladn°ch parametrñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InitIDos PROC      NEAR

; ------ nalezen° dal®°ho parametru

InitIDs1:call      far ptr NextLIni         ; dal®° ©†dek
         jnc       InitIDs2                 ; je dal®° ©†dek OK
IniIDs12:ret

InitIDs2:cmp       byte ptr es:[di],"["
         je        IniIDs12
         call      far ptr JumpPTxt

; Neposouvat á°sla poloëek - pouë°vaj° se (-> á°slo historie) !

         db        6,'HELPFN'               ; 1: n†povàda k funkán°m kl†ves†m
         dw        InitIDs6

         db        7,'HELPSFN'              ; 2: n†povàda k Shift-FN
         dw        InitIDs6

         db        7,'HELPCFN'              ; 3: n†povàda k Ctrl-FN
         dw        InitIDs6

         db        7,'HELPAFN'              ; 4: n†povàda k Alt-FN
         dw        InitIDs6

         db        8,'HELPSCFN'             ; 5: n†povàda k Shift-Ctrl-FN
         dw        InitIDs6

         db        8,'HELPSAFN'             ; 6: n†povàda k Shift-Alt-FN
         dw        InitIDs6

         db        8,'HELPCAFN'             ; 7: n†povàda k Ctrl-Alt-FN
         dw        InitIDs6

         db        8,'PERMMENU'             ; 8:
         dw        IniIDs31

         db        6,'FNHELP'               ; 9:
         dw        IniIDs33

         db        4,'FN12'                 ; 10:
         dw        IniIDs34

         db        7,'LINECOM'              ; 11:
         dw        IniIDs35

         db        8,'FORMDATE'             ; 12:
         dw        IniIDs38

         db        8,'CHARDATE'             ; 13:
         dw        IniIDs41

         db        8,'CHARTIME'             ; 14:
         dw        IniIDs42

         db        7,'CHARNUM'              ; 15:
         dw        IniIDs43

         db        6,'DARKER'               ; 16:
         dw        IniIDs44

         db        10,'PATHPROMPT'          ; 17:
         dw        IniIDs45

         db        7,'ENVSIZE'              ; 18:
         dw        IniIDs46

         db        10,'GRAPHMOUSE'          ; 19:
         dw        IniIDs47

         db        8,'CODEPAGE'             ; 20:
         dw        IniIDs48

         db        7,'EXECCOM'              ; 21:
         dw        IniIDs49

         db        8,'USERMENU'             ; 22:
         dw        IniIDs51

         db        7,'DARKEXE'              ; 23:
         dw        IniIDs52

         db        7,'EXECMOD'              ; 24:
         dw        IniIDs53

         db        8,'HISTFILE'             ; 25: !!!!! - pouë°v† se abs. á°slo
         dw        IniIDs54

         db        7,'HISTEXE'              ; 26:
         dw        IniIDs54

         db        8,'HISTFIND'             ; 27:
         dw        IniIDs54

         db        8,'HISTSWCH'             ; 28:
         dw        IniIDs54

         db        7,'HISTSEL'              ; 29:
         dw        IniIDs54

         db        7,'HISTADR'              ; 30:
         dw        IniIDs54

         db        7,'HISTATR'              ; 31:
         dw        IniIDs54

         db        7,'HISTCOM'              ; 32:
         dw        IniIDs54

         db        7,'HISTNUM'              ; 33:
         dw        IniIDs54

         db        7,'HISTMNU'              ; 34:
         dw        IniIDs54

         db        9,'OLDNUMKEY'
         dw        IniIDs55

         db        7,'ALTQEND'
         dw        IniIDs56

         db        7,'AUTODIR'
         dw        IniIDs57

         db        7,'CALCHEX'
         dw        IniIDs58

         db        7,'CALCRAD'
         dw        IniIDs59

         db        7,'CALCDEC'
         dw        IniIDs5A

         db        7,'CALCTHS'
         dw        IniIDs5B

         db        6,'NOTINI'
         dw        IniIDs62

         db        6,'NOTSPC'
         dw        IniIDs63

         db        6,'NOTRGH'
         dw        IniIDs64

         db        6,'NOTTAB'
         dw        IniIDs65

         db        6,'NOTPAG'
         dw        IniIDs66

         db        7,'CHARDEC'
         dw        IniID432

         db        7,'CHARENT'
         dw        IniID434

         db        8,'LONGFILE'
         dw        IniID435

         db        7,'EDITINI'
         dw        IniID436

         db        7,'EDITMNU'
         dw        IniID437

         db        6,'DELDIR'
         dw        IniID438

         db        7,'NULFILE'
         dw        IniID439

         db        7,'UNDFILE'
         dw        IniID43A

         db        9,'MOUSEXCHG'
         dw        IniID43B

         db        0
         dw        InitIDs1

; ------ permanentn° menu

IniIDs31:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        IniIDs32                 ; parametr nedefinov†n
         and       byte ptr ds:[ParMenu],not bit0 ; nen° trvalÇ menu
         jcxz      IniIDs32                 ; nen° trvalÇ menu
         or        byte ptr ds:[ParMenu],bit0 ; je trvalÇ menu
IniIDs32:jmp       InitIDs1

; ------ mal† n†povàda

IniIDs33:test      byte ptr ds:[StartPar],bit2 ; je opakovanò start ?
         jnz       IniIDs32                 ; je opakovanò start
         call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        IniIDs32                 ; parametr nedefinov†n
         and       byte ptr ds:[HelpPar],not bit0 ; nen° mal† n†povàda
         jcxz      IniIDs32                 ; nen° mal† n†povàda
         or        byte ptr ds:[HelpPar],bit0 ; je mal† n†povàda
         jmp       short IniIDs32

; ------ 12 funkán°ch kl†ves

IniIDs34:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        IniIDs32                 ; parametr nedefinov†n
         and       byte ptr ds:[HelpPar],not bit1 ; nen° 12 kl†ves
         jcxz      IniIDs32                 ; je 10 kl†ves
         or        byte ptr ds:[HelpPar],bit1 ; je 12 kl†ves
         jmp       short IniIDs32

; ------ poáet ©†dkñ p©°kazovÇho ©†dku

IniIDs35:call      far ptr InitIBNm         ; naáten° parametru - bajt
         jc        IniIDs32
         cmp       al,2
         jbe       IniIDs36
         mov       al,2
IniIDs36:mov       ds:[LineCVys],al
         jmp       short IniIDs32

; ------ form†t zobrazen° data

IniIDs38:call      far ptr JumpPTxt

         db        3,'MDY'
         dw        IniID382                 ; USA

         db        3,'DMY'
         dw        IniID382                 ; EVROPA

         db        3,'YMD'                  ; JAPONSKO
         dw        IniID382

         db        0
         dw        InitIDs1

IniID382:dec       ax
         mov       ds:[FormDat],al
IniIDs40:jmp       short IniIDs32

; ------ oddàlovac° znak data

IniIDs41:call      far ptr InitIPCh         ; naáten° parametru - znak
         jc        IniIDs40
         mov       ds:[ZnakDat],al          ; oddàlovac° znak data
         jmp       short IniIDs40

; ------ oddàlovac° znak áasu

IniIDs42:call      far ptr InitIPCh         ; naáten° parametru - znak
         jc        IniIDs40
         mov       ds:[ZnakTim],al          ; oddàlovac° znak áasu
         jmp       short IniIDs40

; ------ oddàlovac° znak ©†dñ á°sel

IniIDs43:call      far ptr InitIPCh         ; naáten° parametru - znak
         jc        IniIDs40
         mov       ds:[OddelRad],al         ; oddàlovac° znak ©†dñ á°sel
         jmp       short IniIDs40

; ------ oddàlovac° znak desetinnòch m°st

IniID432:call      far ptr InitIPCh         ; naáten° parametru - znak
         jc        IniIDs40
         mov       ds:[OddelDes],al         ; oddàlovac° znak desetin
         jmp       short IniIDs40

; ------ oddàlovac° znak poloëek

IniID434:call      far ptr InitIPCh         ; naáten° parametru - znak
         jc        IniIDs40
         mov       ds:[OddelPol],al         ; oddàlovac° znak poloëek v datech
         jmp       short IniIDs40

; ------ z†kaz dlouhòch jmen

IniID435:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        IniIDs40                 ; parametr nedefinov†n
         or        cx,cx                    ; je z†kaz ?
         jnz       IniIDs40                 ; nen° z†kaz
         or        byte ptr ds:[Win95Par],bit2 ; z†kaz dlouhòch jmen
InID4352:jmp       short IniIDs40

; ------ povolen° editace konfiguraán°ho souboru

IniID436:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        InID4352                 ; parametr nedefinov†n
         or        byte ptr ds:[ZNMnVA13+2],bit0 ; z†kaz modifikace
         jcxz      InID4352
         and       byte ptr ds:[ZNMnVA13+2],not bit0 ; modifikace povolena
         jmp       short InID4352

; ------ povolen° editace hlavn°ho menu

IniID437:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        InID4352                 ; parametr nedefinov†n
         or        byte ptr ds:[ZNMnVA13+3],bit0 ; z†kaz modifikace
         jcxz      InID4352
         and       byte ptr ds:[ZNMnVA13+3],not bit0
         jmp       short InID4352

; ------ povolen° ru®en° nepr†zdnòch adres†©ñ

IniID438:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        InID4352                 ; parametr nedefinov†n
         or        word ptr ds:[SR8MnBlk],bit0 + bit0*HI ; z†kaz ru®en°
         jcxz      InID4352
         and       word ptr ds:[SR8MnBlk],not bit0 + bit0*HI
         jmp       short InID4352

; ------ povolen° nulov†n° souborñ

IniID439:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        InID4352                 ; parametr nedefinov†n
         and       word ptr ds:[SRMnVBlk+1],not bit0 + HI*bit0 ; nulov†n° povoleno
         or        cx,cx
         jnz       InID4352                 ; nulov†n° povoleno
         or        word ptr ds:[SRMnVBlk+1],bit0 + HI*bit0 ; z†kaz nulov†n°
         mov       word ptr ds:[SRMnVSwc],0ff00h ; jenom ru®en°
         jmp       short InID4352

; ------ povolen° obnoven° souborñ

IniID43A:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        InID4352                 ; parametr nedefinov†n
         or        byte ptr ds:[SMnuVBlk+9],bit0 ; obnovov†n° zak†z†no
         jcxz      InID4352
         and       byte ptr ds:[SMnuVBlk+9],not bit0 ; obnovov†n° povoleno
         jmp       short InID4352

; ------ z†màna tlaá°tek my®i

IniID43B:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        InID43B2                 ; parametr nedefinov†n
         and       byte ptr ds:[ParMous2],not bit7 ; nen° z†màna
         jcxz      InID43B2                 ; nen° z†màna
         or        byte ptr ds:[ParMous2],bit7 ; je z†màna
InID43B2:jmp       InitIDS1

; ------ ztmavov†n° displeje

IniIDs44:call      far ptr InitIWNm         ; naáten° parametru
         jc        IniID442
         mov       dx,1092                  ; poáet impulsñ na minutu
         mul       dx                       ; p©epoáet na poáet impulsñ
         or        dx,dx                    ; je p©eteáen° ?
         jnz       IniID444                 ; je p©eteáen°
         mov       ds:[DarkTime],ax         ; áas pro stm°v†n°

IniID442:call      far ptr InitIOdd         ; oddàlovaá á°sel
         jc        IniID443
         call      far ptr InitIBNm         ; naáten° sekund
         jc        IniID443
         mov       ah,18                    ; poáet impulsñ na sekundu
         mul       ah                       ; p©epoáet na poáet impulsñ
         add       ds:[DarkTime],ax
         jc        IniID444

IniID443:mov       ax,ds:[DarkTime]
         cmp       ax,-22                   ; maxim†ln° hodnota á°sla
         jb        IniID445
IniID444:mov       ax,-22
IniID445:mov       ds:[DarkTime],ax
         or        byte ptr ds:[DarkParm],bit0
         or        ax,ax
         jnz       IniID446
         and       byte ptr ds:[DarkParm],not bit0 ; funkce vypnuta
IniID446:jmp       IniIDs40

; ------ zobraz° se cesta v promptu

IniIDs45:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        IniID446                 ; parametr nedefinov†n
         or        byte ptr ds:[LineCPar],bit0 ; nen° cesta
         jcxz      IniID446                 ; nen° cesta
         and       byte ptr ds:[LineCPar],not bit0 ; je cesta
         jmp       short IniID446

; ------ velikost prost©ed°

IniIDs46:call      far ptr InitIWNm         ; naáten° parametru
         jc        IniID446
         or        ax,ax
         jz        IniID464
         cmp       ax,160                   ; minim†ln° hodnota parametru
         ja        IniID462
         mov       ax,160                   ; minim†ln° hodnota parametru
IniID462:cmp       ax,32768                 ; maxim†ln° hodnota parametru
         jb        IniID464                 ; hodnota parametru je OK
         mov       ax,32768                 ; maxim†ln° hodnota parametru
IniID464:mov       ds:[EnvSize],ax          ; velikost prost©ed°
         jmp       short IniID446

; ------ grafickò kurzor my®i

IniIDs47:call      far ptr JumpPTxt

         db        1,'Y'
         dw        IniID472

         db        1,'N'
         dw        IniID474

         db        5,'MOUSE'
         dw        IniID476

         db        0
         dw        InitiDs1

IniID472:or        byte ptr ds:[ParMouse],bit3 ; je grafickò kurzor
         and       byte ptr ds:[ParMouse],not bit6 ; nen° my®ka
         jmp       short IniID446

IniID474:and       byte ptr ds:[ParMouse],not bit3 ; nen° grafickò kurzor
         jmp       short IniID446

IniID476:or        byte ptr ds:[ParMouse],bit3+bit6 ; obr†zek my®ky
         jmp       short IniID446

; ------ k¢dov† str†nka displeje

IniIDs48:call      far ptr JumpPTxt

         db        2,'NO'                   ; nen° áe®tina
         dw        IniID482

         db        3,'IBM'                  ; omezen† áe®tina
         dw        IniID482

         db        7,'KEYBCS2'              ; Kamenickòch
         dw        IniID482

         db        6,'LATIN2'               ; Latin 2
         dw        IniID482

         db        0
         dw        InitIDs1

IniID482:cmp       byte ptr ds:[CodePag0],0 ; je k¢dov† str†nka uráena ?
         je        IniID483                 ; nen° uráena
         mov       al,ds:[CodePag0]         ; uráen† k¢dov† str†nka
IniID483:mov       ds:[CodePage],al         ; k¢dov† str†nka
         mov       byte ptr ds:[CodePagK],1 ; je k¢d Kamenickòch
         cmp       al,3                     ; je Kamenickòch ?
         je        IniID488                 ; je Kamenickòch
         inc       byte ptr ds:[CodePagK]   ; je Latin 2
         cmp       al,4                     ; je Latin 2 ?
         je        IniID488                 ; je Latin 2
         mov       byte ptr ds:[CodePagK],0 ; k¢d neuráen
IniID488:jmp       InitIDs1

; ------ programy COM, EXE a BAT se po ENTER spou®tàj° bàënà (bez p©°pon)

IniIDs49:call      far ptr InitIPYN         ; naáten° parametru Y/N
         jc        IniID488                 ; parametr nedefinov†n
         and       byte ptr ds:[ProgSwc],not bit6 ; jsou p©°pony
         jcxz      IniID488                 ; volba "N"
         or        byte ptr ds:[ProgSwc],bit6 ; je bàënà spou®tàn° bez p©°pon
         jmp       short IniID488

; ------ jmÇno souboru uëivatelskÇho menu

IniIDs51:mov       si,offset UserMFil       ; buffer jmÇna souboru
         call      far ptr InitIPFl         ; naáten° jmÇna souboru
         jmp       short IniID488

; ------ p©°kaz pro extern° stm°vaá

IniIDs52:mov       si,offset DarkExec       ; buffer p©°kazu
         mov       word ptr ds:[DarkExeN],0 ; dÇlka p©°kazu
IniID522:mov       al,es:[di]
         inc       di
         cmp       al," "
         jb        IniID524
         cmp       si,offset DarkExec+126
         jae       IniID522
         mov       ds:[si],al
         inc       si
         inc       word ptr ds:[DarkExeN]
         jmp       short IniID522
IniID524:dec       di
         mov       byte ptr ds:[si],0
         jmp       short IniID488

; ------ m¢d spou®tàn° programu

IniIDs53:call      far ptr JumpPTxt

         db        3,'BAT'
         dw        IniID532

         db        4,'LOAD'
         dw        IniID533

         db        4,'PERM'
         dw        IniID534

         db        0
         dw        InitIDs1

IniID532:mov       al,bit0
         jmp       short IniID536

IniID533:mov       al,bit1
         jmp       short IniID536

IniID534:mov       al,bit2

IniID536:test      byte ptr ds:[StartPar],bit2 ; je opakovanò start ?
         jnz       IniID538                 ; je opakovanò start ?
         and       byte ptr ds:[ProgSwc],not bit0+bit1+bit2
         or        ds:[ProgSwc],al
IniID538:jmp       short IniID488

; ------ velikosti histori°

IniIDs54:sub       ax,25
         shl       ax,1
         add       ax,offset HistSizT
         xchg      ax,bx                    ; BX <- adresa velikosti historie
         call      far ptr InitIWNm         ; naáten° á°sla
         jc        IniID538
         cmp       ax,50
         jae       IniID542
         mov       ax,50                   ; minim†ln° velikost
IniID542:cmp       ax,10000
         jb        IniID543
         mov       ax,10000
IniID543:mov       ds:[bx],ax               ; velikost historie
         jmp       short IniID538

; ------ starò vòznam kl†ves + - *

IniIDs55:push      cs
         call      near ptr InitIPYN        ; naáten° parametru Y/N
         jc        IniID538                 ; parametr nedefinov†n
         and       byte ptr ds:[StartPar],not bit5 ; nen° starò vòznam kl†ves
         jcxz      IniID538                 ; volba "N"
         or        byte ptr ds:[StartPar],bit5 ; je starò vòznam kl†ves + - *
         jmp       short IniID538

; ------ ukonáen° rychlovyhled†v†n° po uvolnàn° Alt-

IniIDs56:push      cs
         call      near ptr InitIPYN        ; naáten° parametru Y/N
         jc        IniID538                 ; parametr nedefinov†n
         and       byte ptr ds:[WindPar2],not bit4 ; nen° ukonáen° QSRC
         jcxz      IniID538                 ; volba "N"
         or        byte ptr ds:[WindPar2],bit4 ; je ukonáen° QSRC
         jmp       short IniID538

; ------ automatick† zmàna adres†©e ve stromu

IniIDs57:push      cs
         call      near ptr InitIPYN        ; naáten° parametru Y/N
         jc        InitID61                 ; parametr nedefinov†n
         and       byte ptr ds:[WindPar2],not bit5 ; nen° autodir
         jcxz      InitID61                 ; volba "N"
         or        byte ptr ds:[WindPar2],bit5 ; je autodir
         jmp       short InitID61

; ------ HEX m¢d kalkul†toru

IniIDs58:push      cs
         call      near ptr InitIPYN        ; naáten° parametru Y/N
         jc        InitID61                 ; parametr nedefinov†n
         and       byte ptr ds:[KalParm],not bit0 ; nen° HEX
         jcxz      InitID61                 ; volba "N"
         or        byte ptr ds:[KalParm],bit0 ; je HEX
         jmp       short InitID61

; ------ RAD m¢d kalkul†toru

IniIDs59:push      cs
         call      near ptr InitIPYN        ; naáten° parametru Y/N
         jc        InitID61                 ; parametr nedefinov†n
         and       byte ptr ds:[KalParm],not bit1 ; nen° RAD
         jcxz      InitID61                 ; volba "N"
         or        byte ptr ds:[KalParm],bit1 ; je RAD
         jmp       short InitID61

; ------ desetinnòch m°st kalkul†toru

IniIDs5A:push      cs
         call      near ptr InitIBNm        ; naáten° sekund
         jc        InitID61
         cmp       al,100
         jae       InitID61
         mov       byte ptr ds:[KalkMist],al ; poáet desetinnòch m°st
         jmp       short InitID61

; ------ odsazen° tis°cñ kalkul†toru

IniIDs5B:push      cs
         call      near ptr InitIPYN        ; naáten° parametru Y/N
         jc        InitID61                 ; parametr nedefinov†n
         and       byte ptr ds:[KalParm],not bit2 ; nen° odsazen°
         jcxz      InitID61                 ; volba "N"
         or        byte ptr ds:[KalParm],bit2 ; je odsazen°
         jmp       short InitID61

; ------ n†povàda k funkán°m kl†ves†m (©ada AX)

InitIDs6:dec       ax                       ; á°slo ©ady
         mov       ah,12
         mul       ah                       ; poá†teán° á°slo kl†vesy
         xchg      ax,bx                    ; BX <- poá†teán° á°slo kl†vesy
         mov       ax,7
         mul       bx
         add       ax,offset HelpKeyA
         xchg      ax,si                    ; SI <- buffer n†povàdy ke kl†ves†m
         push      cs
         call      near ptr InitIFHl        ; n†povàda k funkán°m kl†ves†m
InitID61:jmp       InitIDs1

; ------ inicializaán° ©etàzec z†pisn°ku

IniIDs62:mov       byte ptr ds:[ZZMnTIni],0 ; nen° ë†dnò bajt
IniID622:call      far ptr InitICar         ; vypu®tàn° á†rky
         call      far ptr InitIBNm         ; naáten° á°sla
         jc        InitID61                 ; nen° dal®° platnÇ á°slo
         mov       bl,ds:[ZZMnTIni]         ; poáet parametrñ
         mov       bh,0
         cmp       bl,20                    ; maxim†ln° poáet znakñ
         jae       InitID61                 ; je jië maxim†ln° poáet znakñ
         mov       ds:[ZZMnTIni+1+bx],al    ; uloëen° znaku
         inc       byte ptr ds:[ZZMnTIni]   ; zvò®en° á°taáe parametrñ
         jmp       short IniID622           ; dal®° parametr

; ------ poáet £vodn°ch mezer z†pisn°ku

IniIDs63:call      far ptr InitIBNm         ; naáten° á°sla
         jc        InitID61                 ; nen° á°slo
         cmp       al,99                    ; maxim†ln° poáet mezer
         ja        InitID61                 ; chyba
         mov       byte ptr ds:[ZZMnTLft],al ; levò okraj tisku
         jmp       short InitID61

; ------ pravò okraj z†pisn°ku

IniIDs64:call      far ptr InitIWNm         ; naáten° á°sla
         jc        InitID61                 ; chyba
         or        ax,ax                    ; minim†lnà 1
         jz        InitID61                 ; chyba
         cmp       ax,9999                  ; maxim†lnà
         ja        InitID61                 ; chyba
         mov       ds:[TexIEOkr],ax         ; pravò okraj
         jmp       short InitID61

; ------ poáet pozic na tabul†tor z†pisn°ku

IniIDs65:call      far ptr InitIWNm         ; naáten° á°sla
         jc        InitID61                 ; chyba
         or        ax,ax                    ; minim†lnà 1
         jz        InitID61                 ; chyba
         cmp       ax,9999                  ; maxim†lnà
         ja        InitID61                 ; chyba
         mov       ds:[TexIETab],ax         ; poáet pozic na tabul†tor
         jmp       short InitID61

; ------ dÇlka str†nky z†pisn°ku

IniIDs66:call      far ptr InitIWNm         ; naáten° á°sla
         jc        InitID61                 ; chyba
         or        ax,ax                    ; minim†lnà 1
         jz        InitID61                 ; chyba
         cmp       ax,9999                  ; maxim†lnà
         ja        InitID61                 ; chyba
         mov       ds:[TexIEStr],ax         ; poáet ©†dkñ na str†nku
         jmp       short InitID61

InitIDos ENDP

Code     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT   BYTE PUBLIC

; -----------------------------------------------------------------------------
;        barvy
; -----------------------------------------------------------------------------
;˛
ColsBeg  label     byte                     ; zaá†tek barev

; ------ DBF - nadpis okna

ColDBF1  db        71h                      ; stavovò ©†dek - bàën† barva
ColDBF11 db        74h                      ; stavovò ©†dek - nadpis

; ------ DBF - ©†dkovò reëim

ColDBF2  db        0fh                      ; ©†dek se jmÇny poloëek
ColDBF22 db        4fh                      ; poloëka s nastavovanou ®°©kou
ColDBF3  db        1bh                      ; bàënò z†znam
ColDBF4  db        30h                      ; bàënò z†znam s kurzorem
ColDBF42 db        0fh                      ; barva editovanÇ poloëky
ColDBF5  db        1eh                      ; oznaáenò z†znam
ColDBF6  db        3eh                      ; oznaáenò z†znam s kurzorem

; ------ DBF - str†nkovò reëim

ColDBF12 db        70h                      ; jmÇna poloëek + podklad
ColDBF13 db        1bh                      ; poloëky z†znamu
ColDBF14 db        0fh                      ; barva aktivn° editovanÇ poloëky
ColDBF15 db        74h                      ; vysv°cen† jmÇna poloëek

; ------ DBF - rychlò prohl°ëeá

ColDBF7  db        1bh                      ; bavra textu rychlÇho prohl°ëen°

; ------ DISK - barvy okna form†tov†n°

ColFRam  db        70h                      ; barva r†mu mapy form†tov†n°
ColFNul  db        7                        ; barva pr†zdnÇho pole
ColFForm db        1eh                      ; znaáka form†tov†n°
ColFOK   db        0ah                      ; barva OK
ColFErr  db        4eh                      ; barva chyby

; ------ DISK - barvy okna verifikace a mapy

ColDMapS db        34h                      ; barva systÇmovÇ pozice
ColDMapF db        7                        ; barva volnÇ pozice
ColDMapC db        30h                      ; barva obsazenÇ pozice
ColDMapB db        4eh                      ; barva vadnÇ pozice
ColDMapV db        1eh                      ; barva verifikace
ColDMapP db        3                        ; barva á†steánà obsazenÇ pozice

; ------ indik†tor operace CD

CDColInd db        02h                      ; barva indik†toru CD

; ------ DISK - barvy pro zobrazen° disku

ColDZob0 db        17h                      ; barva oddàlovac° á†ry
ColDZob1 db        1bh                      ; barva textu editace disku
ColDZob2 db        1eh                      ; barva textu rozd°lnòch dat
ColDZob3 db        4fh                      ; barva kurzoru
ColDZob4 db        4eh                      ; barva kurzoru na rozd°lnòch datech

; ------ EDI - barvy editoru/prohl°ëeáe

ColEdi1  db        30h                      ; barva informaán°ho ©†dku
ColEdi2  db        3eh                      ; informaán° ©†dek zvòraznànò
ColEdi3  db        1bh                      ; bàënò text
ColEdi4  db        1dh                      ; ©°dic° znaky
ColEdi5  db        1eh                      ; indikace p©ekroáen° ©†dku
ColEdi6  db        70h                      ; blok v textu
ColEdi7  db        4fh                      ; neaktivn° kurzor

; ------ FIL - informaán° ©†dek

InfoCol1 db        70h                      ; bàën† barva informaán°ho ©†dku
InfoCol2 db        74h                      ; zvòraznàn† barva inform. ©†dku

; ------ HLP - mal† n†povàda

HelpColN db        7                        ; barva á°sla kl†vesy
HelpColM db        70h                      ; barva menu kl†ves
HelpColT db        30h                      ; barva textu n†povàdy kl†vesy
HelpColK db        4eh                      ; barva kurzoru funkán°ch kl†ves
HelpColH db        30h                      ; barva textu n†povàdy k volb†m
HelpClH2 db        34h                      ; vysv°cen† barva n†povàdy

; ------ LIN - p©°kazovò ©†dek

LinePCol db        0fh                      ; barva textu promptu
LineCCol db        7                        ; barva textu p©°kaz. ©†dku
LineOCol db        0eh                      ; barva znaku p©eteáen°

;; ------ LST - hled†n° souborñ
;
;LstCol0  db        1bh                      ; barva r†mu okna
;LstCol1  db        1bh                      ; neoznaáenò soubor
;LstCol2  db        1eh                      ; oznaáenò soubor
;LstCol3  db        30h                      ; neoznaáenò soubor - kurzor
;LstCol4  db        3eh                      ; oznaáenò soubor - kurzor
;LstCol5  db        0fh                      ; ©†dek s adres†©em

; ------ MNU

ColTime  db        74h                      ; barva £daje áasu
ColDate  db        74h                      ; barva £daje data
ColMnu1  db        70h                      ; barva textu menu
ColMnu2  db        74h                      ; barva vysv°cenÇho znaku menu
ColMnu1L db        7fh                      ; barva r†mu menu, lev† hrana
ColMnu1R db        70h                      ; barva r†mu menu, prav† hrana

ColMnu3  db        30h                      ; text menu - kurzor
ColMnu4  db        34h                      ; vysv°cenò znak menu - kurzor
ColMnu3L db        3fh                      ; barva r†mu kurzoru, lev† hrana
ColMnu3R db        30h                      ; barva r†mu kurzoru, prav† hrana

ColMnu5  db        71h                      ; barva textu menu - zak†zan† volba
ColMnu6  db        31h                      ; zak†zan† volba menu - kurzor

ColMnuN  db        0fh                      ; text p©i zad†v†n° á°sla v menu

ColMnu7  db        70h                      ; editovanÇ ©†dky - bàënÇ
ColMnu8  db        30h                      ; editovanÇ ©†dky - kurzor
ColMnu9  db        71h                      ; editovanÇ ©†dky - editace
ColMnuA  db        0eh                      ; p©eteáen° ©†dku (= barva pop©ed°)
ColMnuB  db        74h                      ; ©†dek se z†kazem z†pisu
ColMnuC  db        34h                      ; ©†dek se z†kazem - kurzor

; ------ MNU - uëivatelskÇ menu

UMnuCol1 db        70h                      ; (1) bàën† barva menu
UMnuCol2 db        74h                      ; (1) zvòraznàn† barva menu
UMnuCol3 db        30h                      ; (1) bàën† barva kurzoru menu
UMnuCol4 db        34h                      ; (1) zvòraznàn† barva kurzoru menu
UMnuClR1 db        70h                      ; (1) barva r†mu menu - tmav†
UMnuClR2 db        7fh                      ; (1) barva r†mu menu - svàtl†
UMnuColT db        70h                      ; (1) barva titulku okna
UMnuColH db        1Fh                      ; (1) barva z†hlav° menu
UMnuClH2 db        1Eh                      ; (1) zvòraznàn† barva z†hlav° menu
UMnuColP db        30h                      ; (1) barva n†povàdy menu
UMnuClP2 db        34h                      ; (1) zvòraznàn† barva n†povàdy

; ------ UND - obnoven° souborñ

ColUnd1  db        0fh                      ; ©†dek nadpisu
ColUnd2  db        7                        ; ©†dek nadpisu - oddàlovac° á†ry
ColUnd3  db        1bh                      ; bàën† barva poloëky
ColUnd4  db        30h                      ; barva kurzoru

; ------ WIN - adres†©ovÇ okno

ColAWin1 db        1bh                      ; bàën† barva adres†©ovÇho okna
ColAWin2 db        1eh                      ; vysv°cen† barva adres†©. okna
ColAWin3 db        30h                      ; barva kurzoru adres†©. okna
ColAWin4 db        3eh                      ; kurzor - vysv°cen† barva

;ColAWin5 db        1fh                      ; barva adres†©ñ (b°l†)
;ColAWin6 db        1dh                      ; barva programñ (purpurov†)
;ColAWin7 db        1fh                      ; barva archivñ (b°l†)
;ColAWin8 db        1ah                      ; barva textñ (zelen†)
;ColAWin9 db        17h                      ; barva pomocnòch souborñ (®ed†)

; ------ skupiny souborñ

ColAWinT label     byte
         db        07h                      ; barva poloëky ".."
         db        1bh                      ; barva adres†©ñ
         db        13h                      ; barva HID/SYS
         db        1fh                      ; barva programñ

         db        FileTMax dup(1dh)        ; uëivatelskÇ typy souborñ

; ------ barvy seznamu

ColLWin1 db        3fh                      ; bàën† barva adres†©ovÇho okna
ColLWin2 db        3eh                      ; vysv°cen† barva adres†©. okna
ColLWin3 db        1fh                      ; barva kurzoru adres†©. okna
ColLWin4 db        1eh                      ; kurzor - vysv°cen† barva
ColLWin5 db        5eh                      ; barva cesty - seznam
ColLWin6 db        1eh                      ; barva cesty - kurzor

; ------ barvy stromu

ColTWin1 db        2fh                      ; bàën† barva adres†©ovÇho okna
ColTWin2 db        2eh                      ; vysv°cen† barva adres†©. okna
ColTWin3 db        0fh                      ; barva kurzoru adres†©. okna
ColTWin4 db        0eh                      ; kurzor - vysv°cen† barva
ColTre1  db        2ch                      ; identifikaán° znaáka adres†©e
ColTre2  db        0ch                      ; identif. znaáka s kurzorem
ColTre3  db        2bh                      ; barva nenaátenÇ poloëky stromu

; ------ ZAP - z†pisn°k

ColText1 db        1bh                      ; bàën† barva textu
ColText2 db        70h                      ; barva bloku
ColText3 db        71h                      ; bàën† barva nadpisu
ColText4 db        74h                      ; barva nadpisu
ColText5 db        6eh                      ; barva okraje
ColText6 db        74h                      ; barva p©elomu str†nky

; ------ ZVL - ASCII tabulka

ColT1    db        70h                      ; bàën† barva tabulky
ColT2    db        30h                      ; barva kurzoru okna
ColT3    db        07h                      ; barva informaán°ho ©†dku
ColT4    db        0fh                      ; barva á°sel informaán°ho ©†dku

; ------ ZVL - hodiny

ColHod   db        0ah                      ; barva textu áasu

; ------ ZVL - kalkul†tor

;ColKalI  db        0ch                      ; indik†tory na displeji
;ColKal1  db        70h                      ; barva podkladu kalkul†toru
;ColKal2  db        03h                      ; r†m displeje
;ColKal3  db        0ah                      ; barva displeje
;ColKal4  db        0fh                      ; bàënÇ kl†vesy
;ColKal5  db        1eh                      ; speci†ln° kl†vesy
;ColKal6  db        4eh                      ; kl†vesa C

; ------ HLP - n†povàda

ColHlp1  db        2fh                      ; bàën† barva
ColHlp2  db        2eh                      ; zvòraznàn†
ColHlp3  db        2Bh                      ; kl†vesa
ColHlp4  db        70h                      ; volba menu
ColHlp5  db        74h                      ; volba menu zvòraznàn†
ColHlp6  db        1Fh                      ; odkaz
ColHlp7  db        4eh                      ; odkaz s kurzorem
ColHlp8  db        2ch                      ; r†m - svàtlo
ColHlp9  db        24h                      ; r†m - st°n
ColHlpA  db        2eh                      ; r†m - titulek
ColHlpB  db        07h                      ; barva st°nu

; ------ TAB - tabulka

ColTBLRm db        4eh                      ; barva r†mu tabulky (á°sla bunàk)
ColTBLRS db        4ah                      ; barva p©ep°naáñ v r†mu tabulky
ColTBLSt db        0ah                      ; editaán° ©†dek na spodu tabulky
ColTBL1  db        71h                      ; stavovò ©†dek - bàën† barva
ColTBL11 db        74h                      ; stavovò ©†dek - nadpis
ColTBL2  db        0fh                      ; barva á°sel v tabulce
ColTBL3  db        1fh                      ; barva kurzoru na á°slech
ColTBL4  db        0bh                      ; barva textu v tabulce (+pr†zdnÇ)
ColTBL5  db        1bh                      ; barva kurzoru na textu (+pr†zdnÇ)
ColTBL6  db        0dh                      ; barva vòrazu v tabulce
ColTBL7  db        1dh                      ; barva kurzoru na vòrazu
ColTBL8  db        30h                      ; barva bloku
ColTBL9  db        60h                      ; barva kurzoru v bloku

; ------ ZVL - kalend†©

DiarColV db        4fh                      ; zvòraznànò den kalend†©e
;DiarCol1 db        70h                      ; z†kladn° barva okna
;DiarCol2 db        74h                      ; vysv°cen† barva okna
;DiarCol3 db        30h                      ; barva kurzoru
;DiarCol4 db        34h                      ; vysv°cenò kurzor

ColsEnd  label     byte                     ; konec barev

; -----------------------------------------------------------------------------
;        barvy - barevnò m¢d
; -----------------------------------------------------------------------------

ColColo  label     byte                     ; zaá†tek barev - barevnò m¢d

; ------ DBF

         db        71h                      ; stavovò ©†dek - bàën† barva
         db        74h                      ; stavovò ©†dek - nadpis
                                          ;* barvy v ©†dkovÇm oknà
         db        0fh                      ; ©†dek se jmÇny poloëek
         db        4fh                      ; poloëka s nastavovanou ®°©kou
         db        1bh                      ; bàënò z†znam
         db        30h                      ; bàënò z†znam s kurzorem
         db        0fh                      ; barva editovanÇ poloëky

         db        1eh                      ; oznaáenò z†znam
         db        3eh                      ; oznaáenò z†znam s kurzorem

                                          ;* barvy ve str†nkovÇm oknà
         db        70h                      ; jmÇna poloëek + podklad
         db        1bh                      ; poloëky z†znamu
         db        0fh                      ; barva aktivn° editovanÇ poloëky
         db        74h                      ; vysv°cen† jmÇna poloëek
         db        1bh                      ; bavra textu rychlÇho prohl°ëen°

; ------ DISK - barvy okna form†tov†n°

         db        70h                      ; barva r†mu mapy form†tov†n°
         db        7                        ; barva pr†zdnÇho pole
         db        1eh                      ; znaáka form†tov†n°
         db        0ah                      ; barva OK
         db        4eh                      ; barva chyby

; ------ DISK - barvy okna verifikace, mapy a CD

         db        34h                      ; barva systÇmovÇ pozice
         db        7                        ; barva volnÇ pozice
         db        30h                      ; barva obsazenÇ pozice
         db        4eh                      ; barva vadnÇ pozice
         db        1eh                      ; barva verifikace
         db        3                        ; barva á†steánà obsazenÇ pozice
         db        02h                      ; barva indik†toru CD

; ------ DISK - barvy pro zobrazen° disku

         db        17h                      ; barva oddàlovac° á†ry
         db        1bh                      ; barva textu editace disku
         db        1eh                      ; barva textu rozd°lnòch dat
         db        4fh                      ; barva kurzoru
         db        4eh                      ; barva kurzoru na rozd°lnòch datech

; ------ EDI - barvy editoru/prohl°ëeáe

         db        30h                      ; barva informaán°ho ©†dku
         db        3eh                      ; informaán° ©†dek zvòraznànò
         db        1bh                      ; bàënò text
         db        1dh                      ; ©°dic° znaky
         db        1eh                      ; indikace p©ekroáen° ©†dku
         db        70h                      ; blok v textu
         db        4fh                      ; neaktivn° kurzor

; ------ FIL

         db        70h                      ; bàën† barva informaán°ho ©†dku
         db        74h                      ; zvòraznàn† barva inform. ©†dku

; ------ HLP

         db        7                        ; barva á°sla kl†vesy
         db        70h                      ; barva menu kl†ves
         db        30h                      ; barva textu n†povàdy kl†vesy
         db        4eh                      ; barva kurzoru funkán°ch kl†ves

         db        30h                      ; barva textu n†povàdy k volb†m
         db        34h                      ; vysv°cen† barva n†povàdy

; ------ LIN

         db        0fh                      ; barva textu promptu
         db        7                        ; barva textu p©°kaz. ©†dku
         db        0eh                      ; barva znaku p©eteáen°

;; ------ LST
;
;         db        1bh                      ; barva r†mu okna
;         db        1bh                      ; neoznaáenò soubor
;         db        1eh                      ; oznaáenò soubor
;         db        30h                      ; neoznaáenò soubor - kurzor
;         db        3eh                      ; oznaáenò soubor - kurzor
;         db        0fh                      ; ©†dek s adres†©em

; ------ MNU

         db        74h                      ; barva £daje áasu
         db        74h                      ; barva £daje data
         db        70h                      ; barva textu menu
         db        74h                      ; barva vysv°cenÇho znaku menu
         db        7fh                      ; barva r†mu menu, lev† hrana
         db        70h                      ; barva r†mu menu, prav† hrana

         db        30h                      ; text menu - kurzor
         db        34h                      ; vysv°cenò znak menu - kurzor
         db        3fh                      ; barva r†mu kurzoru, lev† hrana
         db        30h                      ; barva r†mu kurzoru, prav† hrana

         db        71h                      ; barva textu menu - zak†zan† volba
         db        31h                      ; zak†zan† volba menu - kurzor

         db        0fh                      ; text p©i zad†v†n° á°sla v menu

         db        70h                      ; editovanÇ ©†dky - bàënÇ
         db        30h                      ; editovanÇ ©†dky - kurzor
         db        71h                      ; editovanÇ ©†dky - editace
         db        0eh                      ; p©eteáen° ©†dku (= barva pop©ed°)
         db        74h                      ; ©†dek se z†kazem z†pisu
         db        34h                      ; ©†dek se z†kazem - kurzor

; ------ MNU - uëivatelskÇ menu

         db        70h                      ; (1) bàën† barva menu
         db        74h                      ; (1) zvòraznàn† barva menu
         db        30h                      ; (1) bàën† barva kurzoru menu
         db        34h                      ; (1) zvòraznàn† barva kurzoru menu
         db        70h                      ; (1) barva r†mu menu - tmav†
         db        7fh                      ; (1) barva r†mu menu - svàtl†
         db        70h                      ; (1) barva titulku okna
         db        1Fh                      ; (1) barva z†hlav° menu
         db        1Eh                      ; (1) zvòraznàn† barva z†hlav° menu
         db        30h                      ; (1) barva n†povàdy menu
         db        34h                      ; (1) zvòraznàn† barva n†povàdy

; ------ UND

         db        0fh                      ; ©†dek nadpisu
         db        7                        ; ©†dek nadpisu - oddàlovac° á†ry
         db        1bh                      ; bàën† barva poloëky
         db        30h                      ; barva kurzoru

; ------ WIN

         db        1bh                      ; bàën† barva adres†©ovÇho okna
         db        1eh                      ; vysv°cen† barva adres†©. okna
         db        30h                      ; barva kurzoru adres†©. okna
         db        3eh                      ; kurzor - vysv°cen† barva

;         db        1bh                      ; barva adres†©ñ
;         db        1fh                      ; barva programñ (b°l†)
;         db        1dh                      ; barva archivñ (purpurov†)
;         db        1ah                      ; barva textñ (zelen†)
;         db        17h                      ; barva pomocnòch souborñ (®ed†)

         db        17h                      ; barva poloëky ".."
         db        1bh                      ; barva adres†©ñ
         db        13h                      ; barva HID/SYS
         db        1fh                      ; barva programñ

         db        1dh                      ; archiv (fialov†)
         db        1ah                      ; texty (zelen†)
         db        1ch                      ; programy - zdroje (áerven†)
         db        19h                      ; obr†zky (modr†)
         db        19h                      ; zvuk (modr†)
         db        17h                      ; p©echodnÇ soubory (®ed†)
         db        1Fh                      ; rezerva 1 (hnàd†)
         db        07h                      ; rezerva 2 (®ed†)
         db        FileTMax-8 dup(1bh)      ; uëivatelskÇ typy souborñ

; ------ barvy seznamu

         db        3fh                      ; bàën† barva adres†©ovÇho okna
         db        3eh                      ; vysv°cen† barva adres†©. okna
         db        1fh                      ; barva kurzoru adres†©. okna
         db        1eh                      ; kurzor - vysv°cen† barva

         db        5eh                      ; barva cesty - seznam
         db        1eh                      ; barva cesty - kurzor

; ------ barvy stromu

         db        2fh                      ; bàën† barva adres†©ovÇho okna
         db        2eh                      ; vysv°cen† barva adres†©. okna
         db        0fh                      ; barva kurzoru adres†©. okna
         db        0eh                      ; kurzor - vysv°cen† barva
         db        2ch                      ; identifikaán° znaáka adres†©e
         db        0ch                      ; identif. znaáka s kurzorem
         db        2bh                      ; barva nenaátenÇ poloëky stromu

; ------ ZAP

         db        1bh                      ; bàën† barva textu
         db        70h                      ; barva bloku
         db        71h                      ; bàën† barva nadpisu
         db        74h                      ; barva nadpisu
         db        6eh                      ; barva okraje
         db        74h                      ; barva p©elomu str†nky

; ------ ZVL - ASCII tabulka

         db        70h                      ; bàën† barva tabulky
         db        30h                      ; barva kurzoru okna
         db        07h                      ; barva informaán°ho ©†dku
         db        0fh                      ; barva á°sel informaán°ho ©†dku

; ------ ZVL - hodiny

         db        0ah                      ; barva textu áasu

; ------ ZVL - kalkul†tor

;         db        0ch                      ; indik†tory na displeji
;         db        70h                      ; barva podkladu kalkul†toru
;         db        03h                      ; r†m displeje
;         db        0ah                      ; barva displeje
;         db        0fh                      ; bàënÇ kl†vesy
;         db        1eh                      ; speci†ln° kl†vesy
;         db        4eh                      ; kl†vesa C

; ------ HLP - n†povàda

         db        2fh                      ; bàën† barva
         db        2eh                      ; zvòraznàn†
         db        2bh                      ; kl†vesa
         db        70h                      ; volba menu
         db        74h                      ; volba menu zvòraznàn†
         db        1fh                      ; odkaz
         db        4eh                      ; odkaz s kurzorem
         db        2ch                      ; r†m - svàtlo
         db        24h                      ; r†m - st°n
         db        2eh                      ; r†m - titulek
         db        07h                      ; barva st°nu

; ------ TAB - tabulka

         db        4eh                      ; barva r†mu tabulky (á°sla bunàk)
         db        4ah                      ; barva p©ep°naáñ v r†mu tabulky
         db        0ah                      ; editaán° ©†dek na spodu tabulky
         db        71h                      ; stavovò ©†dek - bàën† barva
         db        74h                      ; stavovò ©†dek - nadpis
         db        0fh                      ; barva á°sel v tabulce
         db        1fh                      ; barva kurzoru na á°slech
         db        0bh                      ; barva textu v tabulce (+pr†zdnÇ)
         db        1bh                      ; barva kurzoru na textu (+pr†zdnÇ)
         db        0dh                      ; barva vòrazu v tabulce
         db        1dh                      ; barva kurzoru na vòrazu
         db        30h                      ; barva bloku
         db        60h                      ; barva kurzoru v bloku

; ------ ZVL - kalend†©

         db        4fh                      ; zvòraznànò den kalend†©e
;         db        70h                      ; z†kladn° barva okna
;         db        74h                      ; vysv°cen† barva okna
;         db        30h                      ; barva kurzoru
;         db        34h                      ; vysv°cenò kurzor

; -----------------------------------------------------------------------------
;        barvy - MONO m¢d
; -----------------------------------------------------------------------------

ColMono  label     byte                     ; zaá†tek barev - MONO m¢d

; ------ DBF

         db        70h                      ; stavovò ©†dek - bàën† barva
         db        70h                      ; stavovò ©†dek - nadpis
                                          ;* barvy v ©†dkovÇm oknà
         db        0fh                      ; ©†dek se jmÇny poloëek
         db        70h                      ; poloëka s nastavovanou ®°©kou
         db        0fh                      ; bàënò z†znam
         db        70h                      ; bàënò z†znam s kurzorem
         db        0fh                      ; barva editovanÇ poloëky

         db        0fh                      ; oznaáenò z†znam
         db        70h                      ; oznaáenò z†znam s kurzorem

                                          ;* barvy ve str†nkovÇm oknà
         db        70h                      ; jmÇna poloëek + podklad
         db        0fh                      ; poloëky z†znamu
         db        0fh                      ; barva aktivn° editovanÇ poloëky
         db        70h                      ; vysv°cen† jmÇna poloëek
         db        07h                      ; bavra textu rychlÇho prohl°ëen°

; ------ DISK - barvy okna form†tov†n°

         db        70h                      ; barva r†mu mapy form†tov†n°
         db        07h                      ; barva pr†zdnÇho pole
         db        0fh                      ; znaáka form†tov†n°
         db        0fh                      ; barva OK
         db        0fh                      ; barva chyby

; ------ DISK - barvy okna verifikace, mapy a CD

         db        70h                      ; barva systÇmovÇ pozice
         db        07h                      ; barva volnÇ pozice
         db        70h                      ; barva obsazenÇ pozice
         db        0fh                      ; barva vadnÇ pozice
         db        0fh                      ; barva verifikace
         db        07h                      ; barva á†steánà obsazenÇ pozice

         db        07h                      ; barva indik†toru CD

; ------ DISK - barvy pro zobrazen° disku

         db        07h                      ; barva oddàlovac° á†ry
         db        0fh                      ; barva textu editace disku
         db        0fh                      ; barva textu rozd°lnòch dat
         db        0fh                      ; barva kurzoru
         db        0fh                      ; barva kurzoru na rozd°lnòch datech

; ------ EDI - barvy editoru/prohl°ëeáe

         db        70h                      ; barva informaán°ho ©†dku
         db        70h                      ; informaán° ©†dek zvòraznànò
         db        0fh                      ; bàënò text
         db        0fh                      ; ©°dic° znaky
         db        0fh                      ; indikace p©ekroáen° ©†dku
         db        70h                      ; blok v textu
         db        70h                      ; neaktivn° kurzor

; ------ FIL

         db        70h                      ; bàën† barva informaán°ho ©†dku
         db        70h                      ; zvòraznàn† barva inform. ©†dku

; ------ HLP

         db        07h                      ; barva á°sla kl†vesy
         db        70h                      ; barva menu kl†ves
         db        70h                      ; barva textu n†povàdy kl†vesy
         db        0fh                      ; barva kurzoru funkán°ch kl†ves

         db        70h                      ; barva textu n†povàdy k volb†m
         db        70h                      ; vysv°cen† barva n†povàdy

; ------ LIN

         db        0fh                      ; barva textu promptu
         db        07h                      ; barva textu p©°kaz. ©†dku
         db        0fh                      ; barva znaku p©eteáen°

;; ------ LST
;
;         db        0fh                      ; barva r†mu okna
;         db        0fh                      ; neoznaáenò soubor
;         db        0fh                      ; oznaáenò soubor
;         db        70h                      ; neoznaáenò soubor - kurzor
;         db        7fh                      ; oznaáenò soubor - kurzor
;         db        0fh                      ; ©†dek s adres†©em

; ------ MNU

         db        70h                      ; barva £daje áasu
         db        70h                      ; barva £daje data
         db        70h                      ; barva textu menu
         db        0fh                      ; barva vysv°cenÇho znaku menu
         db        70h                      ; barva r†mu menu, lev† hrana
         db        70h                      ; barva r†mu menu, prav† hrana

         db        07h                      ; text menu - kurzor
         db        0fh                      ; vysv°cenò znak menu - kurzor
         db        0fh                      ; barva r†mu kurzoru, lev† hrana
         db        07h                      ; barva r†mu kurzoru, prav† hrana

         db        70h                      ; barva textu menu - zak†zan† volba
         db        07h                      ; zak†zan† volba menu - kurzor

         db        0fh                      ; text p©i zad†v†n° á°sla v menu

         db        70h                      ; editovanÇ ©†dky - bàënÇ
         db        07h                      ; editovanÇ ©†dky - kurzor
         db        07h                      ; editovanÇ ©†dky - editace
         db        0fh                      ; p©eteáen° ©†dku (= barva pop©ed°)
         db        70h                      ; ©†dek se z†kazem z†pisu
         db        0fh                      ; ©†dek se z†kazem - kurzor

; ------ MNU - uëivatelskÇ menu

         db        70h                      ; (1) bàën† barva menu
         db        0fh                      ; (1) zvòraznàn† barva menu
         db        07h                      ; (1) bàën† barva kurzoru menu
         db        0fh                      ; (1) zvòraznàn† barva kurzoru menu
         db        70h                      ; (1) barva r†mu menu - tmav†
         db        70h                      ; (1) barva r†mu menu - svàtl†
         db        70h                      ; (1) barva titulku okna
         db        70h                      ; (1) barva z†hlav° menu
         db        0fh                      ; (1) zvòraznàn† barva z†hlav° menu
         db        70h                      ; (1) barva n†povàdy menu
         db        0fh                      ; (1) zvòraznàn† barva n†povàdy

; ------ UND

         db        0fh                      ; ©†dek nadpisu
         db        07h                      ; ©†dek nadpisu - oddàlovac° á†ry
         db        0fh                      ; bàën† barva poloëky
         db        70h                      ; barva kurzoru

; ------ WIN

         db        07h                      ; bàën† barva adres†©ovÇho okna
         db        0fh                      ; vysv°cen† barva adres†©. okna
         db        70h                      ; barva kurzoru adres†©. okna
         db        70h                      ; kurzor - vysv°cen† barva

;         db        0fh                      ; barva adres†©ñ (b°l†)
;         db        07h                      ; barva programñ (purpurov†)
;         db        0fh                      ; barva archivñ (b°l†)
;         db        07h                      ; barva textñ (zelen†)
;         db        07h                      ; barva pomocnòch souborñ (®ed†)

         db        07h                      ; barva poloëky ".."
         db        0fh                      ; barva adres†©ñ
         db        07h                      ; barva HID/SYS
         db        0fh                      ; barva programñ

         db        FileTMax dup(07h)        ; uëivatelskÇ typy souborñ

; ------ barvy seznamu

         db        07h                      ; bàën† barva adres†©ovÇho okna
         db        0fh                      ; vysv°cen† barva adres†©. okna
         db        70h                      ; barva kurzoru adres†©. okna
         db        70h                      ; kurzor - vysv°cen† barva

         db        0fh                      ; barva cesty - seznam
         db        70h                      ; barva cesty - kurzor

; ------ barvy stromu

         db        07h                      ; bàën† barva adres†©ovÇho okna
         db        0fh                      ; vysv°cen† barva adres†©. okna
         db        70h                      ; barva kurzoru adres†©. okna
         db        70h                      ; kurzor - vysv°cen† barva
         db        0fh                      ; identifikaán° znaáka adres†©e
         db        0fh                      ; identif. znaáka s kurzorem
         db        07h                      ; barva nenaátenÇ poloëky stromu

; ------ ZAP

         db        0fh                      ; bàën† barva textu
         db        70h                      ; barva bloku
         db        70h                      ; bàën† barva nadpisu
         db        70h                      ; barva nadpisu
         db        70h                      ; barva okraje
         db        70h                      ; barva p©elomu str†nky

; ------ ZVL - ASCII tabulka

         db        70h                      ; bàën† barva tabulky
         db        0fh                      ; barva kurzoru okna
         db        07h                      ; barva informaán°ho ©†dku
         db        0fh                      ; barva á°sel informaán°ho ©†dku

; ------ ZVL - hodiny

         db        0fh                      ; barva textu áasu

; ------ ZVL - kalkul†tor

;         db        0fh                      ; indik†tory na displeji
;         db        70h                      ; barva podkladu kalkul†toru
;         db        07h                      ; r†m displeje
;         db        0fh                      ; barva displeje
;         db        0fh                      ; bàënÇ kl†vesy
;         db        0fh                      ; speci†ln° kl†vesy
;         db        0fh                      ; kl†vesa C

; ------ HLP - n†povàda

         db        07h                      ; bàën† barva
         db        07h                      ; zvòraznàn†
         db        07h                      ; kl†vesa
         db        70h                      ; volba menu
         db        70h                      ; volba menu zvòraznàn†
         db        0fh                      ; odkaz
         db        70h                      ; odkaz s kurzorem
         db        70h                      ; r†m - svàtlo
         db        70h                      ; r†m - st°n
         db        70h                      ; r†m - titulek
         db        07h                      ; barva st°nu

; ------ TAB - tabulka

         db        70h                      ; barva r†mu tabulky (á°sla bunàk)
         db        70h                      ; barva p©ep°naáñ v r†mu tabulky
         db        07h                      ; editaán° ©†dek na spodu tabulky
         db        70h                      ; stavovò ©†dek - bàën† barva
         db        70h                      ; stavovò ©†dek - nadpis
         db        0fh                      ; barva á°sel v tabulce
         db        70h                      ; barva kurzoru na á°slech
         db        07h                      ; barva textu v tabulce (+pr†zdnÇ)
         db        70h                      ; barva kurzoru na textu (+pr†zdnÇ)
         db        07h                      ; barva vòrazu v tabulce
         db        70h                      ; barva kurzoru na vòrazu
         db        70h                      ; barva bloku
         db        07h                      ; barva kurzoru v bloku

; ------ ZVL - kalend†©

         db        0fh                      ; zvòraznànò den kalend†©e
;         db        70h                      ; z†kladn° barva okna
;         db        70h                      ; vysv°cen† barva okna
;         db        70h                      ; barva kurzoru
;         db        70h                      ; vysv°cenò kurzor

Data     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Konec programu (n†sleduje segment n†povàd)
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Konec0S  SEGMENT   PARA PUBLIC

Konec0S  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                          Konec programu
;
; Tento segment p©edstavuje adresu konce programu a mus° bòt p©ilinkov†n jako
; £plnà posledn° segment programu. Slouë° k uráen° velikosti alokaán°ho bloku
; pamàti programu p©i jeho startu.
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

KonecS   SEGMENT   PARA PUBLIC

KonecS   ENDS

         END       Start

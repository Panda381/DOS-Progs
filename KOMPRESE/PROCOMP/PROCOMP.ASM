
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               Komprese program–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INSTRJMP EQU       0e9h                     ; k¢d instrukce JMP NEAR


; ------ definice k¢dovac¡ tabulky

MAXOFFS  EQU       1fffh                    ; maxim ln¡ offset ©etˆzce
MAXLENX  EQU       25                       ; min. d‚lka dlouh‚ho ©etˆzce
MAXLEN   EQU       MAXLENX+254              ; maxim ln¡ d‚lka ©etˆzce

SUBSTLEN EQU       7                        ; d‚lka nahrazen  dlouh˜m k¢dem


Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ p©¡prava p©¡kazov‚ho © dku

Start:   mov       bl,ds:[80h]              ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       byte ptr ds:[bx+81h],0   ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ inicializace segmentov˜ch registr–

         sti                                ; p©eru¨en¡ povoleno
         mov       ax,cs                    ; datov˜ segment
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       ds:[SegPSP],es           ; segment PSP
         mov       es,ax                    ; ES <- datov˜ segment

; ------ zobrazen¡ £vodn¡ho textu

         mov       si,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ rozbor zad n¡ jmen soubor–

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       di,offset Soub1          ; buffer jm‚na vstupn¡ho souboru
         call      RozbFil                  ; rozbor jm‚na souboru
         jc        Start2                   ; jm‚no souboru nezad no
         mov       di,offset Soub2          ; buffer jm‚na v˜stupn¡ho souboru
         call      RozbFil                  ; rozbor jm‚na souboru
         jnc       Start4                   ; jm‚no souboru zad no OK

; ------ chyba zad n¡ - zobrazen¡ n povˆdy

Start2:  mov       si,offset HelpTxt        ; text n povˆdy
Start3:  call      DispTxt                  ; zobrazen¡ textu n povˆdy

; ------ chybov˜ n vrat

Start31: mov       ax,4c01h
         int       21h

; ------ otev©en¡ vstupn¡ho souboru

Start4:  mov       dx,offset Soub1          ; jm‚no vstupn¡ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ vstupn¡ho souboru
         mov       si,offset Soub1Txt       ; text - chybn‚ zad n¡
         jc        Start3                   ; chybn‚ zad n¡ vstupn¡ho souboru
         mov       ds:[Soub1I],ax           ; identifik tor vstupn¡ho souboru

; ------ datum a ‡as souboru

         mov       bx,ax
         mov       ax,5700h
         int       21h
         mov       ds:[FilDate],dx          ; datum
         mov       ds:[FilTime],cx          ; ‡as

; ------ test, zda v˜stupn¡ soubor existuje

         mov       dx,offset BitBuff+2
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA
         mov       dx,offset Soub2
         mov       ax,3d02h
         int       21h                      ; test, zda soubor existuje
         jc        Start41

; ------ v˜stupn¡ soubor existuje

         mov       bx,ax
         mov       ah,3eh
         int       21h
         mov       si,offset ExisTxt1
         call      DispTxt
         mov       si,offset Soub2
         call      DispTxt0
         mov       si,offset ExisTxt2
         call      DispTxt

         mov       ah,1
         int       21h
         call      UpCase
         mov       si,offset CRTxt
         call      DispTxt

         cmp       al,"A"
         jne       Start31

; ------ otev©en¡ v˜stupn¡ho souboru

Start41: mov       dx,offset Soub2          ; jm‚no v˜stupn¡ho souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         mov       si,offset Soub2Txt       ; text - chybn‚ zad n¡
         jc        Start3                   ; chybn‚ zad n¡ v˜stupn¡ho souboru
         mov       ds:[Soub2I],ax           ; identifik tor v˜stupn¡ho souboru

; ------ obsluha p©eru¨en¡

         push      ds
         push      cs
         pop       ds
         mov       dx,offset Navrat0
         mov       ax,2523h
         int       21h
         pop       ds

; ------ na‡ten¡ vstupn¡ho souboru

         push      ds
         mov       bx,ds:[Soub1I]           ; identifik tor vstupn¡ho souboru
         xor       dx,dx                    ; po‡ te‡n¡ offset
         mov       ah,3fh
         mov       cx,-1                    ; maxim ln¡ velikost souboru
         mov       ds,ds:[InpSegm]          ; DS <- vstupn¡ buffer
         int       21h                      ; na‡ten¡ vstupn¡ho souboru
         pop       ds
         mov       si,offset ReadTxt        ; text - chyba ‡ten¡
         jc        Chyba1                   ; chyba ‡ten¡ ze souboru

; ------ velikost souboru

         mov       ds:[InpNum],ax           ; po‡et bajt– ve vstupn¡m bufferu
         mov       si,offset CompTxt        ; text - nelze zkomprimovat
         cmp       ax,offset(LCOMBeg-LCOMEnd)-1220h ; maxim ln¡ velikost soub.
         ja        Chyba1                   ; chyba - soubor nelze zkomprimovat

; ------ kontrola, zda je EXE

         push      ds
         mov       ds,ds:[InpSegm]
         cmp       word ptr ds:[0],"MZ"
         je        Start47
         cmp       word ptr ds:[0],"ZM"
Start47: pop       ds
         je        Chyba1                   ; je EXE

; ------ zobrazen¡ hl ¨en¡ o komprimaci souboru

         mov       si,offset TextComp
         call      DispTxt

         mov       si,offset Soub1
         call      DispTxt0

Start54: mov       dl," "
         mov       ah,2
         int       21h

; ------ komprimace dat souboru

         call      Komprim                  ; komprimace dat souboru

         mov       si,offset TextSpc
         call      DispTxt                  ; vymaz n¡ procent

; ------ kontrola, zda byl soubor zkr cen

         mov       ax,ds:[OutNum]           ; nov  velikost souboru
         sub       ax,ds:[InpNum]           ; byl soubor zkr cen ?
         jb        Start61                  ; soubor byl zkr cen OK

         mov       si,offset Comp0Txt

Chyba1:  jmp       short Chyba

; ------ procento zkr cen¡ souboru

Start61: mov       si,offset TextNum2
         call      DispTxt

         neg       ax
         mov       cx,1000
         mul       cx
         mov       cx,ds:[InpNum]
         div       cx
         xor       dx,dx
         mov       cx,10
         div       cx
         add       byte ptr ds:[TextNum3+3],dl
         xor       dx,dx
         div       cx
         add       byte ptr ds:[TextNum3+1],dl
         add       al,"0"
         cmp       al,"0"
         mov       si,offset TextNum3+1
         je        Start62
         mov       byte ptr ds:[TextNum3],al
         dec       si
Start62:
         call      DispTxt

; ------ z pis zkomprimovan‚ho souboru na disk

         push      ds
         mov       bx,ds:[Soub2I]
         mov       cx,ds:[OutNum]
         xor       dx,dx
         mov       ds,ds:[OutSegm]
         mov       ah,40h
         int       21h                      ; ulo‘en¡ souboru na disk
         pop       ds
         mov       si,offset WritTxt        ; text - chyba z pisu
         jc        Chyba
         cmp       ax,cx                    ; bylo ulo‘eno v¨e ?
         mov       al,0
         je        Navrat                   ; v¨e OK

; ------ chyba

Chyba:   call      DispTxt
Navrat0: mov       al,1                     ; p©¡znak chyby

; ------ uzav©en¡ soubor–

Navrat:  push      ax

;         call      DispOfs

         push      cs
         pop       ds
         mov       bx,ds:[Soub1I]           ; identifik tor vstupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ vstupn¡ho souboru

         mov       bx,ds:[Soub2I]           ; identifik tor v˜stupn¡ho souboru
         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; velikost souboru
         push      ax

         mov       cx,ds:[FilTime]
         mov       dx,ds:[FilDate]
         mov       ax,5701h
         int       21h                      ; nastaven¡ data a ‡asu souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ v˜stupn¡ho souboru

         pop       ax
         or        ax,ax
         jnz       Navrat3

         mov       dx,offset Soub2
         mov       ah,41h
         int       21h                      ; zru¨en¡ souboru
Navrat3:
         pop       ax

; ------ konec programu

         mov       ah,4ch
         int       21h

; ------ chyba komprimace - nelze zkomprimovat

ChybComp:
         mov       si,offset CompTxt        ; text - nelze zkomprimovat
         jmp       short Chyba


; *****************************************************************************
;
;                          Komprimace dat souboru
;
; *****************************************************************************

; -----------------------------------------------------------------------------
; Diagram k¢dov n¡          (1 bit)
; ----------------         ÚÄÄÄÂÄÄÄ¿
;                          ³ 0 ³ 1 ³
;                          ÀÄÂÄÁÄÂÄÙ
;       ÚÄÄÄÄÄ(1 bajt)ÄÄÄÄÄÄÄÙ   ÀÄÄÄÄ(2 bity)ÄÄÄ¿
;ÚÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ p©enos bajtu ³   ÚÄÄÁÄÄÄ¿                  (1 bit) (stav 1,2,3)
;³  beze zmˆny  ³   ³stav 0³            ÚÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   ÀÄÄÂÄÄÄÙ      ÚÄÄÄÄÄÁÄÄÄÄÄ¿      stav 6,7    ÚÄÄÄÄÁÄÄÄÄÄ¿
;                ÚÄÄÄÄÄÁÄÄÄÄÄÄ¿   ³stav 2,3,4 ³     (1 bit)      ³ stav 5   ³
;                ³ d‚lka = 2  ³   ÀÄÄÄÄÄÂÄÄÄÄÄÙ  ÚÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿ÀÄÄÄÄÂÄÄÄÄÄÙ
;                ÀÄÄÄÄÄÂÄÄÄÄÄÄÙ ÚÄÄÄÄÄÄÄÁÄÄÄÄÄÄ¿ ³d‚lka = 6 a‘ 9³     ³
;                      ³        ³d‚lka = 3,4,5 ³ ÀÄÄÄÄÄÄÂÄÄÄÄÄÄÄÙ  (1 bajt)
;                      ³        ÀÄÄÄÄÄÄÄÂÄÄÄÄÄÄÙ        ³    ÚÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿
;                      ³                ³               ³    ³d‚lka 10 a‘ 265 ³
;      d‚lka = 265     ³                ³               ³    ÀÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÙ
;   ÚÄÄÄÄÄÄÄÄÄÄÄ<ÄÄÄÄÄ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   ³                                   ³
;   ³       ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   ³       ³       (1 bit)  ÚÄÄÄÄÄÄÄ¿
;   ³       ³          ³     ³    (3 bity)
;   ³       ³      ÚÄÄÄÅÄÄÄ¿ ³       ÃÄÄÄÄÄÄÄÄÄÄÄ¿
;   ³       ³      ³ 1 ³ 0 ³ ³ ÚÄÄÄÄÄÁÄÄÄÄ¿   (1 bit)
;   ³       ³      ÀÄÂÄÁÄÂÄÙ ³ ³stav 0, 1 ³      ÃÄÄÄÄÄÄÄÄÄÄ¿
;   ³       ³        ³   ÀÄÄÄÙ ÀÄÄÄÄÄÂÄÄÄÄÙÚÄÄÄÄÄÁÄÄÄÄÄÄÄ¿  ³
;   ³       ³        ³         ÚÄÄÄÄÄÁÄÄÄÄ¿³ stav 4 a‘ 7 ³  ³
;   ³       ³        ³         ³HIGH = 1,2³ÀÄÄÄÄÄÄÂÄÄÄÄÄÄÙ  ³
;   ³       ³   ÚÄÄÄÄÁÄÄÄÄÄ¿   ÀÄÄÄÄÄÂÄÄÄÄÙÚÄÄÄÄÄÄÁÄÄÄÄÄÄ¿  ³
;   ³       ³   ³ HIGH = 0 ³         ³     ³HIGH = 3 a‘ 6³(1 bit)
;   ³       ³   ÀÄÄÄÄÂÄÄÄÄÄÙ         ³     ÀÄÄÄÄÄÄÂÄÄÄÄÄÄÙ  ÃÄÄÄÄÄÄÄÄÄ¿
;   ³ ÚÄÄÄÄÄÁÄÄÄÄÄ¿  ³               ³            ³ ÚÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿ ³
;   ³ ³ d‚lka = 2 ³  ³               ³            ³ ³stav 10h a‘ 16h³ ³
;   ³ ³ HIGH  = 0 ³  ³               ³            ³ ÀÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÙ ³
;   ³ ÀÄÄÄÄÄÂÄÄÄÄÄÙ  ³               ³            ³ ÚÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿ ³
;   ³       ³        ³               ³            ³ ³HIGH = 7 a‘ 0dh³ ³
;   ³       ³        ³               ³            ³ ÀÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÙ ³
;   ³       ³        ³               ³            ³         ³      (1 bit)
;   ³       ³        ³               ³            ³         ³         ³
;   ³       ³        ³               ³            ³         ³ ÚÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿
;   ³       ³        ³               ³            ³         ³ ³HIGH=0eh a‘ 1fh³
;   ³       ³        ³               ³            ³         ³ ÀÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÙ
;   ³       ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ
;   ³                            ³
;   ³                  (1 bajt) = offset LOW
;   ³                            ³
;   ³                  ÚÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ¿
;   ³                  ³ opakov n¡ ©etˆzce ³
;   ³                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
; konec
;
; -----------------------------------------------------------------------------
;þ
Komprim  PROC      NEAR

; ------ inicializace tabulky odkaz–

         push      es
         mov       es,ds:[Inx0Segm]
         xor       di,di
         mov       ax,-1                    ; inicializa‡n¡ slovo
         mov       cx,8000h                 ; d‚lka tabulky (slov)
         cld
         rep       stosw                    ; vymaz n¡ tabulky
         pop       es

; ------ z pis zavadˆ‡e COM do bufferu

         mov       ax,ds:[InpNum]
         add       word ptr cs:[LCOMReg1+2],ax
         add       word ptr cs:[LCOMReg2+1],ax
         add       word ptr cs:[LCOMReg3],ax
         add       word ptr cs:[LCOMReg6+1],ax

         mov       si,offset LCOMBeg
         mov       cx,offset(LCOMEnd-LCOMBeg)
         push      es
         push      ds
         mov       ds:[OutNum],cx
         mov       es,ds:[OutSegm]
         push      cs
         pop       ds
         xor       di,di
         cld
         rep       movsb
         pop       ds
         pop       es

; ------ inicializace ukazatel–

         mov       word ptr ds:[BuffEnd],0
         xor       si,si                    ; ukazatel dat v bufferu

; ------ inicializace buffer– pro dal¨¡ blok (SI=ukazatel v bloku)

Kompr1:  push      si
         mov       si,ds:[BuffEnd]          ; star˜ konec
         mov       cx,si                    ; za‡ tek bufferu
         add       cx,41f0h                 ; konec bufferu
         jnc       Kompr13
         mov       cx,0ffffh                ; konec bufferu
Kompr13: cmp       cx,ds:[InpNum]           ; je ji‘ konec dat ?
         jbe       Kompr14                  ; nen¡ je¨tˆ konec dat
         mov       cx,ds:[InpNum]           ; omezen¡ na data v bufferu
Kompr14: mov       ds:[BuffEnd],cx          ; konec bufferu

         sub       cx,si                    ; d‚lka bufferu
         call      InitInd                  ; inicializace buffer– komprese
         pop       si

; ------ d‚lka zbytku dat v bufferu

Kompr2:  mov       cx,ds:[InpNum]
         sub       cx,si                    ; d‚lka dat
         ja        Kompr22                  ; jsou dal¨¡ data
         jmp       Kompr7                   ; konec dat
Kompr22: cmp       cx,1
         jne       Kompr24                  ; nen¡ 1 bajt

Kompr221:push      ds
         mov       ds,ds:[InpSegm]
         mov       al,ds:[si]
         pop       ds
         mov       cx,1
         jmp       short Kompr25

; ------ nalezen¡ shodn‚ho ©etˆzce

Kompr24:
Kompr23: call      FindStr                  ; nalezen¡ ©etˆzce

; ------ test, zda se bude hledat v˜hodnˆj¨¡ ©etˆzec

Kompr232:cmp       cx,2                     ; d‚lka 2 znaky ?
         jb        Kompr25                  ; ©etˆzec nenalezen
         ja        Kompr242                 ; je del¨¡ ©etˆzec

         cmp       ax,100h                  ; je bli‘¨¡ ©etˆzec ne‘ 256 ?
         jb        Kompr242

         push      ds
         mov       ds,ds:[InpSegm]
         mov       al,ds:[si]
         mov       cx,1
         pop       ds

         jmp       short Kompr25

; ------ pokus o nalezen¡ v˜hodnˆj¨¡ho ©etˆzce

Kompr242:
         mov       bx,cx                    ; £schova d‚lky
         mov       dx,ax                    ; £schova offsetu
         inc       si                       ; zv˜¨en¡ adresy

Kompr24a:
         call      FindStr                  ; pokus o nalezen¡ dal¨¡ho ©etˆzce

         cmp       cx,bx                    ; je del¨¡ ?
         jbe       Kompr247                 ; nen¡ del¨¡
         inc       bx                       ; star˜ ©etˆzec + 1
         cmp       cx,bx                    ; je del¨¡ o 1 bajt ?
         ja        Kompr243                 ; je del¨¡ o v¡ce ne‘ 1 bajt

         cmp       dx,128                   ; je bli‘¨¡ ne‘ 128 znak– ?
         jbe       Kompr246                 ; byl bli‘¨¡ - nevyplat¡ se

; ------ z pis rozd¡ln‚ho znaku

Kompr243:
;         push      ds
;         mov       ds,ds:[InpSegm]
;         mov       dl,ds:[si-1]
;         mov       bx,2
;         pop       ds

         push      ax
         push      cx

         push      ds
         mov       ds,ds:[InpSegm]
         mov       al,ds:[si-1]             ; rozd¡ln˜ znak
         pop       ds
         mov       cx,1                     ; z pis 1 znaku
         call      WritStr

         pop       cx
         pop       ax

         cmp       si,ds:[BuffEnd]
         jae       Kompr26

         mov       dx,ds:[InpNum]
         sub       dx,si                    ; d‚lka dat
         ja        Kompr222                 ; jsou dal¨¡ data
         jmp       Kompr7                   ; konec dat
Kompr222:cmp       dx,1
         je        Kompr221                 ; je 1 bajt
         jmp       short Kompr232

; ------ n vrat p–vodn¡ho nalezen‚ho ©etˆzce

Kompr246:dec       bx
Kompr247:mov       cx,bx
         mov       ax,dx
         dec       si

; ------ vysl n¡ ©etˆzce

Kompr25: add       si,cx                    ; zv˜¨en¡ adresy v bufferu
         call      WritStr                  ; vysl n¡ ©etˆzce

         sub       ds:[DispCit],cx          ; ‡¡ta‡ k zobrazen¡
         jnc       Kompr255

         push      si

         mov       ax,si
         mov       cx,100
         mul       cx
         mov       cx,ds:[InpNum]
         jcxz      Kompr253
         div       cx
         mov       cl,10
         div       cl
         add       ax,"00"
         mov       word ptr ds:[TextNum+1],ax

Kompr253:mov       si,offset TextNum
         call      DispTxt
         sti
         mov       ah,0bh
         int       21h

         pop       si
         mov       word ptr ds:[DispCit],800h

Kompr255:
         cmp       si,ds:[BuffEnd]
         jae       Kompr26

         jmp       Kompr2

Kompr26:
         jmp       Kompr1

; ------ vysl n¡ k¢du pro ukon‡en¡ souboru

Kompr7:
         mov       ax,ds:[MAXLKOD]          ; data k¢du
         mov       cl,ds:[MAXLLEN]          ; d‚lka k¢du
         call      WritBit                  ; vysl n¡ k¢du pro ukon‡en¡
         mov       al,0ffh                  ; k¢d pro ukon‡en¡
         mov       bx,ds:[BitNum]           ; po‡et bajt– v bufferu
         mov       ds:[bx+BitBuff],al       ; ulo‘en¡ k¢du do bufferu
         inc       word ptr ds:[BitNum]     ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu

; ------ vypr zdnˆn¡ vyrovn vac¡ho bufferu

         call      WritBBuf                 ; vypr zdnˆn¡ vyrovn vac¡ho bufferu

Komp9:
         push      ds
         mov       ax,ds:[OutNum]
         mov       ds,ds:[OutSegm]
         inc       ax
         and       ax,not 1

;IFDEF    PKLITE
;
;         sub       ax,1c0h
;         mov       ds:[4],ax
;ELSE
         sub       ax,offset(LCOMEnd-LCOMBeg)
         add       ds:[LCOMReg4-LCOMBeg+1],ax
         sub       ds:[LCOMReg6-LCOMBeg+1],ax

         shr       ax,1
         mov       ds:[LCOMReg5-LCOMBeg+1],ax

;ENDIF
         pop       ds
         ret

Komprim  ENDP


; -----------------------------------------------------------------------------
;         Za‡lenˆn¡ £seku vstupn¡ho bufferu do tabulky index–
; -----------------------------------------------------------------------------
; VSTUP: SI=za‡ tek dat v kruhov‚m bufferu
;        CX=po‡et bajt– v kruhov‚m bufferu k inicializaci
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

InitInd  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ za‡lenˆn¡ ©etˆzc– do tabulky

         jcxz      InitInd3                 ; d‚lka bufferu = 0
         mov       dx,ds:[Inx0Segm]         ; segment inicializa‡n¡ch index–
         mov       bp,ds:[InxSegm]          ; segment index–
         mov       ds,ds:[InpSegm]          ; DS <- vstupn¡ buffer
         cld
         mov       di,si                    ; adresa ve vstupn¡m bufferu
         shl       di,1                     ; ukazatel v tabulce index–

InitInd1:mov       ax,si                    ; adresa ©etˆzce
         mov       es,dx                    ; segment inicializa‡n¡ch index–

         mov       bl,ds:[si]               ; 1. bajt dat
         inc       si                       ; zv˜¨en¡ ukazatele v bufferu
         jz        InitInd5                 ; je adresa 0ffffh
InitInd2:mov       bh,ds:[si]               ; 2.bajt dat
         shl       bx,1                     ; offset v inicial. tabulce index–

         xchg      ax,es:[bx]               ; ulo‘en¡ adresy

         mov       es,bp                    ; segment index–
         stosw                              ; adresa dal¨¡ho ©etˆzce
         loop      InitInd1                 ; dal¨¡ bajt

; ------ n vrat registr–

InitInd3:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitInd  ENDP

; ------ je adresa 0ffffh - obej¡t¡ t‚to adresy

InitInd5:mov       ax,es:[bx]               ; plat¡ star  adresa
         jmp       short InitInd2

; -----------------------------------------------------------------------------
;        hled n¡ ©etˆzce v kruhov‚m bufferu
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa hledan‚ho ©etˆzce v bufferu
;        DS=datov˜ segment
; VSTUP:CX=d‚lka shody (1=nenalezen)
;        AX=z porn˜ offset od hledan‚ho ©etˆzce (nebo AL=znak, nen¡-li nalezen)
; -----------------------------------------------------------------------------

FindStr  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ p©¡prava registr–

         mov       ds,ds:[InpSegm]          ; adresa vstupn¡ho bufferu
         mov       cs:[AdrStr],si           ; p©ednastaven¡ adresy ©etˆzce
         mov       bp,1                     ; p©ednastaven¡ d‚lky

; ------ p©¡prava d‚lky ©etˆzce

         mov       cx,cs:[InpNum]
         sub       cx,si                    ; d‚lka dat
         cmp       cx,cs:[MaxDel]           ; je d‚lka ©etˆzce OK ?
         jae       FindSt01                 ; d‚lka ©etˆzce je OK
         mov       cs:[MaxDel],cx           ; omezen¡ d‚lky ©etˆzce
         sub       cx,1
         jnc       FindSt02
         xor       cx,cx
FindSt02:mov       cs:[MaxDel0],cx
FindSt01:cld

; ------ stanoven¡ adresy navazuj¡c¡ho ©etˆzce

         lodsb                              ; 1. bajt se nekontroluje
         mov       di,si                    ; v˜choz¡ adresa pro hled n¡
FindStr1:shl       di,1                     ; offset v tabulce index–
         mov       es,cs:[InxSegm]          ; segment index–
         mov       di,es:[di-2]             ; adresa n sleduj¡c¡ho ©etˆzce
         inc       di                       ; je konec ?
         jz        FindStr9                 ; je konec
         mov       dx,si                    ; adresa ©etˆzce + 1
         sub       dx,di                    ; offset od ©etˆzce
         cmp       dx,MAXOFFS               ; je ji‘ konec ?
         ja        FindStr9                 ; je ji‘ konec

; ------ porovn n¡ ©etˆzce

         mov       ah,ds:[si+bp-2]
         cmp       ah,ds:[di+bp-2]
         jne       FindStr1

         push      si
         push      di
         push      ds
         pop       es
         mov       cx,cs:[MaxDel0]          ; d‚lka k porovn n¡

         inc       cx
         dec       si
         dec       di

         repe      cmpsb                    ; porovn n¡ ©etˆzc–
         pop       di
         pop       si

; ------ vyhodnocen¡ v˜sledku porovn n¡

         je        FindStr4                 ; ©etˆzce jsou cel‚ shodn‚
         sub       cx,cs:[MaxDel0]          ; d‚lka shody ©etˆzce
         neg       cx
         cmp       cx,bp                    ; je del¨¡ ©etˆzec ?
         jbe       FindStr1                 ; nen¡ del¨¡ - dal¨¡
         dec       di                       ; adresa ©etˆzce
         mov       cs:[AdrStr],di           ; adresa ©etˆzce
         mov       bp,cx                    ; d‚lka ©etˆzce
         inc       di
         jmp       short FindStr1           ; hled n¡ dal¨¡ho ©etˆzce

; ------ ©etˆzce jsou cel‚ shodn‚ - nen¡ dal¨¡ hled n¡

FindStr4:mov       bp,cs:[MaxDel]           ; d‚lka shody ©etˆzce
         dec       di                       ; adresa za‡ tku ©etˆzce
         mov       cs:[AdrStr],di           ; £schova adresy ©etˆzce
         jmp       short FindStr9           ; konec hled n¡

; ------ n vrat registr–

FindStr9:mov       cx,bp                    ; d‚lka nalezen‚ho ©etˆzce
         cmp       cx,1                     ; ©etˆzec nalezen ?
         je        FindStrA                 ; ©etˆzec nenalezen

         mov       ax,si                    ; adresa hledan‚ho ©etˆzce
         dec       ax
         sub       ax,cs:[AdrStr]

FindStrA:
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       bx
         ret

FindStr  ENDP

; -----------------------------------------------------------------------------
;        z pis ©etˆzce do vyrovn vac¡ho bufferu
; -----------------------------------------------------------------------------
; VSTUP: AX=offset ©etˆzce nebo AL=znak (offset je z porn˜ 0e000h a‘ 0ffffh)
;        CX=d‚lka ©etˆzce (bajt–)
; -----------------------------------------------------------------------------

WritStr  PROC      NEAR

; ------ £schova registr–

;         cmp       si,3a0h
;         jb        wr
;         nop
;wr:
         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         mov       dx,ax                    ; offset ©etˆzce nebo znak k z pisu
         mov       si,cx                    ; d‚lka ©etˆzce

;         push      bx
;         cmp       cx,1
;         jbe       wr2
;         mov       bl,ah
;         cmp       bl,31
;         jbe       wr1
;         mov       bl,31
;wr1:     mov       bh,0
;         shl       bx,1
;         inc       word ptr cs:[bx+DelTab]
;wr2:
;         pop       bx

; ------ z pis bajtu beze zmˆny

         xor       ax,ax                    ; zap¡¨e se bit "0"
         cmp       cx,1                     ; d‚lka ©etˆzce 1 bajt ?
         je        WritStr7                 ; z pis bajtu beze zmˆny
         mov       bx,cx                    ; £schova d‚lky ©etˆzce

; ------ z pis k¢du pro dlouh˜ ©etˆzec

         cmp       bx,MAXLENX               ; je dlouh˜ ©etˆzec ?
         jb        WritStr2                 ; nen¡ dlouh˜ ©etˆzec
         mov       ax,ds:[MAXLKOD]          ; k¢d ©etˆzce
         mov       cl,ds:[MAXLLEN]          ; d‚lka k¢du
         call      WritBit                  ; vysl n¡ k¢du pro nastaven¡ d‚lky
         mov       al,bl                    ; d‚lka ©etˆzce
         sub       al,MAXLENX               ; offset od maxim ln¡ d‚lky
         mov       bx,ds:[BitNum]           ; po‡et bajt– v bufferu
         mov       ds:[bx+BitBuff],al       ; ulo‘en¡ d‚lky do bufferu
         inc       word ptr ds:[BitNum]     ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
         jmp       short WritStr5

; ------ z pis k¢du d‚lky

WritStr2:mov       cl,ds:[bx+TabLKod-2]     ; po‡et bit– k vysl n¡
         shl       bx,1                     ; d‚lka * 2
         mov       ax,ds:[bx+TabDKod-4]     ; data k vysl n¡
         call      WritBit                  ; vysl n¡ k¢du pro nastaven¡ d‚lky

; ------ z pis offsetu ©etˆzce HIGH

WritStr5:cmp       si,2                     ; byla d‚lka 2 ?
         je        WritStr9                 ; je d‚lka 2 bajty (2 bity)
         mov       bh,0
         mov       bl,dh                    ; offset ©etˆzce HIGH
         mov       al,ds:[bx+TabODKod]      ; bity k z pisu
         mov       cl,ds:[bx+TabOLKod]      ; po‡et bit– k z pisu
         mov       ah,0
WritStr7:call      WritBit                  ; z pis k¢du do stavov‚ho slova

; ------ ulo‘en¡ offsetu ©etˆzce LOW nebo znaku do bufferu

WritStr9:mov       bx,ds:[BitNum]           ; po‡et bajt– v bufferu
         mov       ds:[bx+BitBuff],dl       ; ulo‘en¡ offsetu LOW nebo znaku
         inc       word ptr ds:[BitNum]     ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritStr  ENDP

; -----------------------------------------------------------------------------
;        z pis skupiny bit– do p©¡znakov‚ho slova
; -----------------------------------------------------------------------------
; VSTUP: AX=data k z pisu
;        CL=po‡et bit– k z pisu
; -----------------------------------------------------------------------------

WritBit  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ p©¡prava registr–

         mov       bx,ax                    ; £schova dat k z pisu
         mov       ch,cl                    ; £schova po‡tu bit– k z pisu

; ------ ulo‘en¡ ni‘¨¡ ‡ sti bit– do stavov‚ho slova

         mov       cl,ds:[BitBit]           ; po‡et bit– ve stavov‚m slovˆ
         shl       ax,cl                    ; rotace dat na pozici
         or        word ptr ds:[BitBuff],ax ; z pis bit– do bufferu
         add       cl,ch                    ; zv˜¨en¡ po‡tu bit– ve slovˆ

; ------ test, zda byly zaps ny v¨echny bity

         cmp       cl,16                    ; je p©ete‡en¡ po‡tu bit– ?
         jbe       WritBit7                 ; po‡et bit– je OK

; ------ vypr zdnˆn¡ vyrovn vac¡ho bufferu

         call      WritBBuf                 ; vypr zdnˆn¡ vyrovn vac¡ho bufferu

; ------ z pis zbyl˜ch bit– dat

         sub       cl,16                    ; po‡et neulo‘en˜ch bit–
         xchg      ch,cl
         sub       cl,ch                    ; po‡et ji‘ ulo‘en˜ch bit–
         shr       bx,cl                    ; vypu¨tˆn¡ ji‘ ulo‘en˜ch bit–
         mov       word ptr ds:[BitBuff],bx ; ulo‘en¡ zbyl˜ch bit–
         mov       cl,ch                    ; CL <- po‡et zbyl˜ch bit–

; ------ nov˜ po‡et bit– v bufferu

WritBit7:mov       ds:[BitBit],cl           ; nov˜ po‡et bit– v bufferu

; ------ n vrat registr–

         pop       cx
         pop       bx
         pop       ax
         ret

WritBit  ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ vyrovn vac¡ho bitov‚ho bufferu
; -----------------------------------------------------------------------------

WritBBuf PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      es

; ------ zv˜¨en¡ po‡tu bajt– ve v˜stupn¡m bufferu, kontrola p©ete‡en¡

         mov       cx,ds:[BitNum]           ; po‡et bajt– ve vyrovn vac¡m buff.
         mov       di,ds:[OutNum]           ; po‡et bajt– ve v˜stupn¡m bufferu
         add       word ptr ds:[OutNum],cx  ; zv˜¨en¡ po‡tu bajt– ve v˜stup.buf.
         jc        WritBBf9                 ; chyba - p©ete‡en¡ bufferu

; ------ p©esun dat do bufferu

         cld
         mov       si,offset BitBuff        ; vyrovn vac¡ buffer
         mov       es,ds:[OutSegm]          ; v˜stupn¡ buffer
         shr       cx,1                     ; p©evod d‚lky na slova
         rep       movsw                    ; p©esun dat do bufferu
         adc       cx,cx                    ; lich˜ bit
         rep       movsb                    ; p©enos lich‚ho bitu

; ------ inicializace vyrovn vac¡ho bufferu

         mov       word ptr ds:[BitNum],2   ; po‡et slov v bufferu

; ------ n vrat registr–

WritBBf3:pop       es
         pop       di
         pop       si
         pop       cx
         ret

WritBBuf ENDP

WritBBf9:jmp       ChybComp                 ; chyba - nelze zkomprimovat

;; -----------------------------------------------------------------------------
;;
;; -----------------------------------------------------------------------------
;
;DispOfs  PROC      NEAR
;
;         push      cs
;         pop       ds
;         push      ds
;         pop       es
;         mov       di,offset DelTxt0+5
;         mov       si,offset DelTab
;         mov       cx,32
;DispOff1:cld
;         lodsw
;         xor       dx,dx
;         call      DekNum
;         add       di,5
;         loop      DispOff1
;
;         mov       dx,offset DelTxt
;         mov       ah,9
;         int       21h
;
;         ret
;
;DispOfs  ENDP
;
; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla DX:AX od adresy ES:DI dol–
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ dek¢dov n¡ jedn‚ ‡¡slice

         mov       cx,10
DekNum1: mov       bx,ax                    ; £schova LOW
         xchg      ax,dx                    ; ‡¡slo HIGH
         xor       dx,dx
         div       cx                       ; vydˆlen¡ HIGH
         xchg      ax,bx                    ; n vrat LOW
         div       cx                       ; vydˆlen¡ LOW
         add       dl,"0"                   ; korekce na ‡¡slici
         dec       di
         mov       es:[di],dl               ; ulo‘en¡ ‡¡slice
         mov       dx,bx                    ; n vrat HIGH

; ------ test, zda je ‡¡slo ji‘ 0

         or        bx,ax                    ; je ‡¡slo ji‘ 0 ?
         jnz       DekNum1                  ; nen¡ je¨tˆ 0

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu SI
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      dx

         mov       dx,si
         mov       ah,9
         int       21h

         pop       dx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ
; -----------------------------------------------------------------------------

DispTxt0 PROC      NEAR

         push      ax
         push      dx
         push      si

DispTx01:cld
         lodsb
         cmp       al,0
         je        DispTx02
         mov       dl,al
         mov       ah,2
         int       21h
         jmp       short DispTx01

DispTx02:pop       si
         pop       dx
         pop       ax
         ret

DispTxt0 ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ zadan‚ho jm‚na souboru (ES:DI=buffer, CY=nezad n)
; -----------------------------------------------------------------------------

RozbFil  PROC      NEAR

; ------ nalezen¡ za‡ tku zad n¡ souboru

         call      RozbSpc                  ; vypu¨tˆn¡ mezer p©ed jm‚nem
         jc        RozbFil9                 ; nen¡ nic zad no

; ------ p©enesen¡ textu a‘ po konec jm‚na

RozbFil2:call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jbe       RozbFil5                 ; konec © dku nebo mezera
         call      UpCase                   ; p©evod znaku na velk‚ p¡smeno
         cld
         stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short RozbFil2           ; dek¢dov n¡ dal¨¡ho znaku

; ------ ozna‡en¡ konce textu

RozbFil5:mov       byte ptr es:[di],0       ; ukon‡ovac¡ 0
         clc                                ; p©¡znak operace OK

RozbFil9:ret

RozbFil  ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku SI (CY=konec, AL=p©ipraven˜ znak)
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         jc        RozbSpc3                 ; je konec p©¡kazov‚ho © dku
         je        RozbSpc                  ; je mezera - dal¨¡ znak
         dec       si                       ; jinak n vrat posledn¡ho znaku
RozbSpc3:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku SI (CY=nen¡ dal¨¡, AL=znak)
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

         push      ds

; ------ vstup znaku z p©¡kazov‚ho © dku

         mov       ds,ds:[SegPSP]           ; segment PSP
         cld
         lodsb                              ; na‡ten¡ znaku z p©¡kazov‚ho © dku

; ------ n hrada tabel toru mezerou

         cmp       al,9                     ; je tabel tor ?
         jne       RozbChr2                 ; nen¡ tabel tor
         mov       al," "                   ; n hrada tabel toru mezerou

; ------ test, zda je platn˜ znak

RozbChr2:cmp       al," "                   ; je platn˜ znak ?
         jae       RozbChr3                 ; je platn˜ znak
         dec       si                       ; n vrat ukazatele p©i konci © dku

RozbChr3:pop       ds
         ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        p©evod znaku na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              Zavadˆ‡ COM
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;InstrJmp:jmp       Start                    ; instrukce skoku

         EVEN

LCOMBeg  LABEL     NEAR

; -----------------------------------------------------------------------------
;        zavadˆ‡ - vlastn¡ form t
; -----------------------------------------------------------------------------

;þ

; ------ kontrola pamˆti

LCOMReg1:cmp       sp,offset(LCOMEnd-LCOMBeg)+100h+1200h ; kontrola konce
         jb        LCOM1                    ; nedostatek pamˆti

; ------ p©esun zavadˆ‡e na vrchol pamˆti (pro z sobn¡k 200h B, rezerva 1000h B)

LCOMReg2:mov       di,offset(LCOMEnd-LCOMBeg)+100h+1000h-2 ; ukl dac¡ adresa
         mov       cx,offset(LCOMEnd-LCOM2)/2 ; d‚lka zavadˆ‡e ve slovech
         mov       si,offset(LCOMEnd-LCOMBeg)+100h-2 ; za‡ tek zavadˆ‡e
         std                                ; smˆr dol–
         rep       movsw                    ; p©esun zavadˆ‡e nahoru
         db        0e9h                     ; instrukce JMP NEAR
LCOMReg3:dw        offset(LCOM2-LCOMTxt)+1000h ; offset skoku na zavadˆ‡

LCOMTxt  db        'Chyba pameti',7,'$'

; ------ chyba - nedostatek pamˆti

LCOM1:   mov       ah,9
         mov       dx,offset(LCOMTxt-LCOMBeg)+100h ; chybov‚ hl ¨en¡
         int       21h                      ; zobrazen¡ chybov‚ho hl ¨en¡
         int       20h

; ------ odsun dat nahoru

         EVEN                               ; mus¡ b˜t sud  adresa !!!!

LCOM2:
LCOMReg4:mov       si,offset(LCOMEnd-LCOMBeg)+100h-2 ; adresa konce dat
LCOMReg5:mov       cx,0                     ; d‚lka dat ve slovech
         rep       movsw                    ; p©esun dat nahoru

; ------ p©¡prava k dek¢dov n¡

         cld
LCOMReg6:mov       si,100h+1000h+offset(LCOM2-LCOMBeg) ; za‡ tek zkomprimovan˜ch dat
         mov       di,100h                  ; za‡ tek k ukl d n¡ dat
         push      di                       ; adresa skoku do programu
         stc
         jmp       short LCOM311

; ------ p©enos bajtu beze zmˆny

LCOM30:  movsb

; ------ prvn¡ p©¡znakov˜ bit

LCOM31:  shr       ax,1
         jnz       LCOM312
LCOM311: lodsw
         rcr       ax,1
LCOM312: jnc       LCOM30                   ; p©enos bajtu beze zmˆny

; ------ p©¡prava k opakov n¡ ©etˆzce

         xor       bx,bx                    ; offset ©etˆzce k opakov n¡
         xor       cx,cx                    ; d‚lka ©etˆzce k opakov n¡

; -----------------------------------------------------------------------------
;        stanoven¡ d‚lky ©etˆzce
; -----------------------------------------------------------------------------

; ------ na‡ten¡ prvn¡ho bitu d‚lky

         shr       ax,1
         jnz       LCOM321
         lodsw
         rcr       ax,1
LCOM321: rcl       cx,1                     ; stav CX=0 nebo 1

; ------ zv˜¨en¡ ‡¡ta‡e d‚lky

LCOM322: inc       cx
         inc       cx                       ; stav CX=2 nebo 3

; ------ na‡ten¡ p©¡znaku konce k¢du

         shr       ax,1
         jnz       LCOM323
         lodsw
         rcr       ax,1
LCOM323: jnc       LCOM38                   ; je konec k¢du

; ------ p©¡padn‚ prokra‡ov n¡ k¢du

         cmp       cl,MAXLENX-4+1           ; je ji‘ maxim ln¡ d‚lka ?
         jb        LCOM322                  ; pokra‡ov n¡ k¢du
         inc       cx
         inc       cx                       ; korekce posledn¡ch 2 k¢d–

; ------ korekce pro n hradn¡ k¢d

LCOM38:  cmp       cl,SUBSTLEN              ; je n hradn¡ d‚lka ?
         jb        LCOM41                   ; d‚lka je OK
         ja        LCOM382                  ; je dlouh  d‚lka

; ------ dlouh‚ opakov n¡

         mov       cl,ds:[si]               ; d‚lka (stav 0 a‘ 255)
         cmp       cl,255                   ; konec ?
         je        LCOM5                    ; konec dek¢dov n¡
         inc       si                       ; zv˜¨en¡ ukazatele dat
         add       cx,MAXLENX+1             ; zv˜¨en¡ d‚lky

; ------ korekce d‚lky pro dlouh˜ k¢d

LCOM382: dec       cx                       ; korekce dlouh‚ d‚lky

; -----------------------------------------------------------------------------
;        stanoven¡ offsetu ©etˆzce
; -----------------------------------------------------------------------------

; ------ d‚lka 2 nem  offset HIGH

LCOM41:  cmp       cx,2                     ; je d‚lka 2 ?
         je        LCOM483                  ; nen¡ offset HIGH

; ------ prvn¡ bit offsetu ©etˆzce

         shr       ax,1
         jnz       LCOM411
         lodsw
         rcr       ax,1
LCOM411: jc        LCOM483                  ; offset HIGH je 0

; ------ druh˜ bit offsetu ©etˆzce

         shr       ax,1
         jnz       LCOM421
         lodsw
         rcr       ax,1
LCOM421: rcl       bh,1                     ; bit offsetu (stav 0,1)

; ------ t©et¡ bit offsetu ©etˆzce

         shr       ax,1
         jnz       LCOM431
         lodsw
         rcr       ax,1
LCOM431: rcl       bh,1                     ; bit offsetu (stav 0 a‘ 3)

; ------ ‡tvrt˜ bit offsetu ©etˆzce

         shr       ax,1
         jnz       LCOM441
         lodsw
         rcr       ax,1
LCOM441: rcl       bh,1                     ; bit offsetu (stav 0 a‘ 7)

; ------ stav 0,1: offset HIGH=1,2

         cmp       bh,1                     ; je stav 0,1 ?
         jbe       LCOM482                  ; offset HIGH je 1,2
                                            ; jinak stav 2 a‘ 7

; ------ p t˜ bit offsetu ©etˆzce

         shr       ax,1
         jnz       LCOM451
         lodsw
         rcr       ax,1
LCOM451: rcl       bh,1                     ; bit offsetu (stav 4 a‘ 15)

; ------ stav 4 a‘ 7: offset HIGH=3 a‘ 6

         dec       bh                       ; stav 3 a‘ 14
         cmp       bh,6                     ; je stav 3 a‘ 6 ?
         jbe       LCOM483                  ; je offset 3 a‘ 6
                                            ; jinak stav 7 a‘ 14

; ------ ¨est˜ bit p©¡znak–

         shr       ax,1
         jnz       LCOM461
         lodsw
         rcr       ax,1
LCOM461: rcl       bh,1                     ; bit offsetu (stav 14 a‘ 29)

; ------ stav 14 a‘ 23: offset HIGH=7 a‘ 13

         sub       bh,7                     ; stav 7 a‘ 22
         cmp       bh,13
         jbe       LCOM483                  ; offset 7 a‘ 13
                                            ; jinak stav 14 a‘ 22

; ------ sedm˜ bit p©¡znak–, offset HIGH=14 a‘ 31

         shr       ax,1
         jnz       LCOM471
         lodsw
         rcr       ax,1
LCOM471: rcl       bh,1                     ; bit offsetu (stav 28 a‘ 45)
         sub       bh,15                    ; stav 13 a‘ 30

; ------ offset ©etˆzce LOW

LCOM482: inc       bh                       ; korekce BH
LCOM483: mov       bl,ds:[si]               ; offset d‚lky LOW
         inc       si                       ; zv˜¨en¡ ukazatele

; ------ p©enos ©etˆzce

         mov       dx,si                    ; £schova SI
         mov       si,di                    ; sou‡asn˜ ukazatel
         sub       si,bx                    ; posun za‡ tku ©etˆzce
         rep       movsb                    ; kopie ©etˆzce
         mov       si,dx                    ; n vrat SI
         jmp       LCOM31                   ; dal¨¡ dek¢dov n¡

; ------ skok do programu

LCOM5:   xor       ax,ax
         xor       bx,bx
         xor       cx,cx
         xor       dx,dx
         xor       si,si
         xor       di,di
         ret                                ; skok na adresu 100h

         EVEN                               ; zarovn n¡ na sudou adresu !!!

LCOMEnd  LABEL     NEAR


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                  Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Param    db        0                        ; parametry
                                            ;  bit 0: 1=je program COM
                                            ;  bit 1: 1=je program EXE mal˜
                                            ;  bit 2: 1=je program EXE velk˜
                                            ;  bit 3: 1=textov˜ soubor

; ------ hl ¨en¡ programu

UvTxt    db        'PROCOMP V1.00 - komprese programu COM; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte jmeno vstupniho i vystupniho souboru COM !',13,10,'$'

Soub1Txt db        'Chybne zadani vstupniho souboru !',13,10,'$'
Soub2Txt db        'Chybne zadani vystupniho souboru !',13,10,'$'

ReadTxt  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'

Comp0Txt db        13,10
CompTxt  db        'Soubor nelze zkomprimovat !'
CRTxt    db        13,10,'$'

ExisTxt1 db        'Soubor $'
ExisTxt2 db        ' jiz existuje !',13,10,'Chete jej prepsat (A=ano) ? $'

TextSpc  db        '     ',8,8,8,8,8,'$'
TextNum  db        '(00%)',8,8,8,8,8,'$'
TextNum2 db        '.... zkracen o $'
TextNum3 db        ' 0.0%',13,10,'$'

TextComp db        'Komprimuji soubor $'

; ------ tabulky pro vysl n¡ d‚lek ©etˆzce

                                          ;* tabulka d‚lek k¢d–
TabLKod  db        3,3                      ; 2,3
         db        4,4                      ; 4,5
         db        5                        ; 6
         db        6,6                      ; 7,8
         db        7,7                      ; 9,10
         db        8,8                      ; 11,12
         db        9,9                      ; 13,14
         db        10,10                    ; 15,16
         db        11,11                    ; 17,18
         db        12,12                    ; 19,20
         db        13,13,13,13              ; 21,22,23,24

MAXLLEN  db        5                        ; 25 a v¡ce

                                          ;* tabulka dat k¢d–
TabDKod  dw        001,011b                   ; 2,3
         dw        0101b,0111b                ; 4,5
         dw        01101b                     ; 6
         dw        011101b,011111b            ; 7,8
         dw        0111101b,0111111b          ; 9,10
         dw        01111101b,01111111b        ; 11,12
         dw        011111101b,011111111b      ; 13,14
         dw        0111111101b,0111111111b    ; 15,16
         dw        01111111101b,01111111111b  ; 17,18
         dw        011111111101b,011111111111b ; 19,20
         dw        0111111111101b,0111111111111b,1111111111101b,1111111111111b ; 21,22,23,24

MAXLKOD  dw        01111b                   ; 25 a v¡ce

; ------ tabulky pro vysl n¡ offsetu ©etˆzce

                                          ;* tabulka po‡tu bit– k z pisu
TabOLKod            db     1                ; 0
                    db     4,4              ; 1,2
                    db     5,5,5,5          ; 3,4,5,6
                    db     6,6,6,6,6,6,6    ; 7,8,9,0ah,0bh,0ch,0dh
                    db     7,7,7,7,7,7      ; 0eh a‘ 1fh
                    db     7,7,7,7,7,7
                    db     7,7,7,7,7,7

                                          ;* tabulka bit– k z pisu
TabODKod            db     1                ; 0
                    db     0,8              ; 1,2
                    db     4,14h,0ch,1ch    ; 3,4,5,6
                    db     2,22h,12h,32h,0ah,2ah,1ah ; 7,8,9,0ah,0bh,0ch,0dh
                    db     3ah,7ah,6,46h,26h,66h ; 0eh a‘ 1fh
                    db     16h,56h,36h,76h,0eh,4eh
                    db     2eh,6eh,1eh,5eh,3eh,7eh

;DelTxt   db        13,10,'    0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F',13,10
;DelTxt0  db        160 dup(" ")
;         db        13,10,'$'
;DelTab   dw        80h dup(0)

SegPSP   dw        0                        ; adresa PSP

FilDate  dw        0                        ; datum souboru
FilTime  dw        0                        ; ‡as souboru

InxSegm  dw        SEG InxSeg               ; segment indexov‚ tabulky
Inx0Segm dw        SEG Inx0Seg              ; segment inicializa‡n¡ch index–

InpSegm  dw        SEG InpSeg               ; vstupn¡ segment
InpNum   dw        0                        ; po‡et bajt– ve vstupn¡m bufferu

OutSegm  dw        SEG OutSeg               ; v˜stupn¡ segment
OutNum   dw        3                        ; po‡et bajt– ve v˜stupn¡m bufferu

; ------ komprimace

BitBit   db        0                        ; po‡et bit– ve stavov‚m slovˆ
BitNum   dw        2                        ; po‡et bajt– ve vyrovn vac¡m buff.
BitBuff  db        100 dup(0)               ; vyrovn vac¡ v˜stupn¡ buffer

AdrStr   dw        0                        ; adresa nalezen‚ho ©etˆzce
MaxDel0  dw        MAXLEN-1                 ; max. d‚lka ©etˆzce - 1
MaxDel   dw        MAXLEN                   ; max. d‚lka ©etˆzce

BuffAdr  dw        0                        ; za‡ tek kruhov‚ho bufferu
BuffEnd  dw        0                        ; konec kruhov‚ho bufferu

DispCit  dw        0                        ; ‡¡ta‡ k zobrazen¡ procent

SoubSiz2 dw        0                        ; velikost v˜stupn¡ho souboru

; ------ soubory

Soub1    db        128 dup(?)               ; jm‚no vstupn¡ho souboru
Soub1I   dw        ?                        ; identifik tor vstupn¡ho souboru

Soub2    db        128 dup(?)               ; jm‚no v˜stupn¡ho souboru
Soub2I   dw        ?                        ; identifik tor v˜stupn¡ho souboru

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                   Tabulka inicializa‡n¡ch index–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Inx0Seg  SEGMENT
         db        0ffffh dup(?)            ; tabulka inicializa‡n¡ch index–
Inx0Seg  ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       Tabulka index– n vaznosti
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

InxSeg   SEGMENT
         db        0ffffh dup(?)            ; tabulka adres n vaznosti
InxSeg   ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           Vstupn¡ buffer
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

InpSeg   SEGMENT
         db        0ffffh dup(?)            ; vstupn¡ buffer
InpSeg   ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           V˜stupn¡ buffer
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

OutSeg   SEGMENT
         db        0ffffh dup(?)            ; v˜stupn¡ buffer
OutSeg   ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasob    SEGMENT   STACK
         dw        1000h dup(?)             ; z sobn¡k
Zasob    ENDS

         END       Start

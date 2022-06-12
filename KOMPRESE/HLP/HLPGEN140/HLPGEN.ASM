
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                          Komprese soubor– n povˆdy
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INSTRJMP EQU       0e9h                     ; k¢d instrukce JMP NEAR

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
         call      RozbPar                  ; rozbor parametr–
         jc        Start2                   ; chyba zad n¡
         mov       di,offset Soub1          ; buffer jm‚na vstupn¡ho souboru
         call      RozbFil                  ; rozbor jm‚na souboru
         jc        Start2                   ; jm‚no souboru nezad no
         call      RozbPar                  ; rozbor parametr–
         jc        Start2                   ; chyba zad n¡
         mov       di,offset Soub2          ; buffer jm‚na v˜stupn¡ho souboru
         call      RozbFil                  ; rozbor jm‚na souboru
         jc        Start2                   ; chyba zad n¡
         call      RozbPar                  ; rozbor parametr–
         jnc       Start4                   ; parametry zad ny OK

; ------ chyba zad n¡ - zobrazen¡ n povˆdy

Start2:  mov       si,offset HelpTxt        ; text n povˆdy
Start3:  call      DispTxt                  ; zobrazen¡ textu n povˆdy

; ------ chybov˜ n vrat

Start31: mov       ax,4c01h
         int       21h

; ------ zad n¡ hesla pro zak¢dov n¡ souboru

Start4:  call      ZadHesl                  ; zad n¡ hesla

; ------ otev©en¡ vstupn¡ho souboru

         mov       dx,offset Soub1          ; jm‚no vstupn¡ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ vstupn¡ho souboru
         mov       si,offset Soub1Txt       ; text - chybn‚ zad n¡
         jc        Start3                   ; chybn‚ zad n¡ vstupn¡ho souboru
         mov       ds:[Soub1I],ax           ; identifik tor vstupn¡ho souboru
         mov       bx,ax

; ------ atributy souboru

         mov       ax,4300h
         int       21h                      ; poskytnut¡ atribut– souboru
         mov       ds:[FilAtr],cx           ; atributy souboru

; ------ datum a ‡as souboru

         mov       ax,5700h
         int       21h
         mov       ds:[FilDate],dx          ; datum
         mov       ds:[FilTime],cx          ; ‡as

; ------ stanoven¡ velikosti souboru

         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h                      ; vystaven¡ ukazatele na konec
         mov       word ptr ds:[Soub1S],ax
         mov       word ptr ds:[Soub1S+2],dx ; velikost souboru
         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h                      ; resetov n¡ ukazatele souboru

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
         je        Start41
         jmp       Start31

; ------ otev©en¡ v˜stupn¡ho souboru

Start41: mov       dx,offset Soub2          ; jm‚no v˜stupn¡ho souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         mov       si,offset Soub2Txt       ; text - chybn‚ zad n¡
         jnc       Start42
         jmp       Start3                   ; chybn‚ zad n¡ v˜stupn¡ho souboru
Start42: mov       ds:[Soub2I],ax           ; identifik tor v˜stupn¡ho souboru

; ------ obsluha p©eru¨en¡

         push      ds
         push      cs
         pop       ds
         mov       dx,offset Navrat0
         mov       ax,2523h
         int       21h
         pop       ds

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

; ------ z pis zkomprimovan‚ho souboru na disk

         call      Zakod                    ; zak¢dov n¡ bufferu

         push      ds
         mov       bx,ds:[Soub2I]
         mov       cx,ds:[OutNum]
         add       word ptr ds:[Soub2S],cx
         adc       word ptr ds:[Soub2S+2],0
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

         mov       dx,offset Soub2          ; jm‚no v˜stupn¡ho souboru
         mov       cx,ds:[FilAtr]           ; atributy souboru
         mov       ax,4301h
         int       21h                      ; nastaven¡ atribut– souboru

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

; *****************************************************************************
;
;                          Komprimace dat souboru
;
; *****************************************************************************

; -----------------------------------------------------------------------------
; Diagram k¢dov n¡          (1 bit)
; ----------------         ÚÄÄÄÂÄÄÄ¿
;                          ³ 0 ³ 1 ³
;                          ÀÄÂÄÁÄÂÄÙ                DIAGRAM DLKY NESOUHLAS‹ !!!
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

; ------ z pis identifik toru souboru do bufferu

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

         xor       si,si                    ; ukazatel dat v bufferu

; ------ inicializace buffer– pro dal¨¡ blok

Kompr1:  push      si
         mov       si,ds:[BuffOld]          ; star˜ konec v bufferu
         mov       cx,4000h                 ; d‚lka dat k inicializaci
         call      InitInd                  ; inicializace buffer– komprese
         add       ds:[BuffOld],cx          ; posun adresy bufferu
         cmp       cx,4000h                 ; byl cel˜ blok ?
         jb        Kompr13                  ; nebyl cel˜ blok
         sub       cx,1f0h                  ; rezerva v bufferu
Kompr13: add       si,cx                    ; konec dat v bufferu
         mov       ds:[BuffEnd],si          ; konec dat v bufferu
         pop       si

; ------ nalezen¡ shodn‚ho ©etˆzce

Kompr2:
         cmp       word ptr ds:[soub0s],4
         jne       kompr23t
         cmp       si,0cb70h
         jb        kompr23t
tst:     nop
kompr23t:


         cmp       si,ds:[BuffOld]
         js        Kompr24
         jmp       Kompr7

Kompr24:
Kompr23: call      FindStr                  ; nalezen¡ ©etˆzce

; ------ test, zda se bude hledat v˜hodnˆj¨¡ ©etˆzec

Kompr232:cmp       cx,2                     ; d‚lka 2 znaky ?
         jb        Kompr25                  ; ©etˆzec nenalezen

; ------ pokus o nalezen¡ v˜hodnˆj¨¡ho ©etˆzce

Kompr242:mov       bx,cx                    ; £schova d‚lky
         mov       dx,ax                    ; £schova offsetu
         inc       si                       ; zv˜¨en¡ adresy

Kompr24a:call      FindStr                  ; pokus o nalezen¡ dal¨¡ho ©etˆzce

         cmp       cx,bx                    ; je del¨¡ ?
         jbe       Kompr247                 ; nen¡ del¨¡
         inc       bx                       ; star˜ ©etˆzec + 1
         cmp       cx,bx                    ; je del¨¡ o 1 bajt ?
         ja        Kompr243                 ; je del¨¡ o v¡ce ne‘ 1 bajt

         cmp       dx,128                   ; je bli‘¨¡ ne‘ 128 znak– ?
         jbe       Kompr246                 ; byl bli‘¨¡ - nevyplat¡ se

; ------ z pis rozd¡ln‚ho znaku

Kompr243:push      ax
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
         jns       Kompr26
         jmp       short Kompr232

; ------ n vrat p–vodn¡ho nalezen‚ho ©etˆzce

Kompr246:dec       bx
Kompr247:mov       cx,bx
         mov       ax,dx
         dec       si

; ------ vysl n¡ ©etˆzce

Kompr25: add       si,cx                    ; zv˜¨en¡ adresy v bufferu
         jnc       Kompr252
         inc       word ptr ds:[Soub0S]     ; citac dat HIGH
Kompr252:call      WritStr                  ; vysl n¡ ©etˆzce


         sub       ds:[DispCit],cx          ; ‡¡ta‡ k zobrazen¡
         jnc       Kompr255

         call      DispProc                 ; zobrazeni procent


         mov       word ptr ds:[DispCit],800h


Kompr255:
         cmp       si,ds:[BuffEnd]
         jns       Kompr26

         jmp       Kompr2

Kompr26:
         cmp       si,ds:[BuffOld]
         jns       Kompr7                   ; je konec souboru

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
         ret

Komprim  ENDP

; -----------------------------------------------------------------------------
;        zobrazeni procent operace
; -----------------------------------------------------------------------------

DispProc PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       ax,si
         mov       dx,ds:[Soub0S]           ; velikost zpracovane casti

         mov       bx,word ptr ds:[Soub1S+2]
         mov       cx,word ptr ds:[Soub1S]  ; velikost souboru

DispPrc1:mov       si,dx
         or        bx,bx
         jz        DispPrc2
         shr       dx,1
         rcr       ax,1
         shr       bx,1
         rcr       cx,1
         jmp       short DispPrc1

DispPrc2:mov       bx,100
         mul       bx
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

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispProc ENDP

; -----------------------------------------------------------------------------
;         Za‡lenˆn¡ £seku vstupn¡ho bufferu do tabulky index–
; -----------------------------------------------------------------------------
; VSTUP: SI=za‡ tek dat v kruhov‚m bufferu (buffer nesmi presahnout prelom)
;        CX=po‡et bajt– v kruhov‚m bufferu k na‡ten¡ a inicializaci
;        DS=datov˜ segment
; VSTUP:CX=po‡et na‡ten˜ch bajt– ze souboru (CX=0 konec souboru)
; -----------------------------------------------------------------------------

InitInd  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ vyjmut¡ star˜ch ©etˆzc– z tabulky inicializa‡n¡ch index–

         mov       es,ds:[Inx0Segm]         ; tabulka inicializa‡n¡ch index–
         xor       di,di                    ; offset v tabulce index–
         mov       bx,-1                    ; nulovac¡ slovo
InitIn01:mov       ax,es:[di]               ; index z tabulky
         sub       ax,si                    ; offset od ©etˆzce
         cmp       ax,cx                    ; je v nov‚ tabulce ?
         jae       InitIn02                 ; nen¡ v tabulce
         mov       es:[di],bx               ; zru¨en¡ indexu
InitIn02:inc       di
         inc       di                       ; zv˜¨en¡ ukazatele v tabulce
         jnz       InitIn01                 ; dal¨¡ index v tabulce

;; ------ vyjmut¡ star˜ch ©etˆzc– z tabulky index–
;
;         mov       es,ds:[InxSegm]          ; tabulka index–
;InitIn05:mov       ax,es:[di]               ; index z tabulky
;         sub       ax,si                    ; offset od ©etˆzce
;         cmp       ax,cx                    ; je v nov‚ tabulce ?
;         jae       InitIn06                 ; nen¡ v tabulce
;         mov       es:[di],bx               ; zru¨en¡ indexu
;InitIn06:inc       di
;         inc       di                       ; zv˜¨en¡ ukazatele v tabulce
;         jnz       InitIn05                 ; dal¨¡ index v tabulce

; ------ na‡ten¡ bloku dat ze souboru

         mov       bx,ds:[Soub1I]           ; identifik tor souboru
         mov       ds,ds:[InpSegm]          ; DS <- vstupn¡ buffer
         mov       dx,si                    ; adresa k na‡ten¡ dat
         mov       ah,3fh
         int       21h                      ; na‡ten¡ bloku dat ze souboru
         jnc       InitInd0                 ; operace OK
         xor       ax,ax                    ; nena‡tena ‘ dn  data
InitInd0:add       dx,cx                    ; adresa za na‡ten˜mi daty
         mov       cx,ax                    ; po‡et na‡ten˜ch bajt– dat
         jcxz      InitInd3                 ; nejsou ji‘ dal¨¡ data

; ------ na‡ten¡ n sleduj¡c¡ho bajtu ze souboru

         push      cx
         mov       cx,1                     ; 1 bajt k na‡ten¡
         mov       ah,3fh
         int       21h                      ; na‡ten¡ p©¡¨t¡ho bajtu
         jc        InitIn03                 ; chyba
         cmp       ax,cx                    ; byl bajt na‡ten ?
         jne       InitIn03                 ; nebyl na‡ten ‘ dn˜ bajt
         mov       dx,0ffffh                ; offset LOW = - 1
         mov       cx,dx                    ; offset HIGH = -1
         mov       ax,4201h
         int       21h                      ; ukazatel o 1 bajt zpˆt
InitIn03:pop       cx

; ------ za‡lenˆn¡ ©etˆzc– do tabulky

         mov       dx,cs:[Inx0Segm]         ; segment inicializa‡n¡ch index–
         mov       bp,cs:[InxSegm]          ; segment index–
         cld
         mov       di,si                    ; adresa ve vstupn¡m bufferu
         shl       di,1                     ; ukazatel v tabulce index–

         push      cx

InitInd1:mov       ax,si                    ; adresa ©etˆzce
         mov       es,dx                    ; segment inicializa‡n¡ch index–

         mov       bl,ds:[si]               ; 1. bajt dat
         inc       si                       ; zv˜¨en¡ ukazatele v bufferu
         mov       bh,ds:[si]               ; 2.bajt dat
         shl       bx,1                     ; offset v inicial. tabulce index–
         or        si,si                    ; je p©elom bufferu ?
         jz        InitInd5                 ; je p©elom bufferu

         xchg      ax,es:[bx]               ; ulo‘en¡ adresy

InitInd2:mov       es,bp                    ; segment index–
         stosw                              ; adresa dal¨¡ho ©etˆzce
         loop      InitInd1                 ; dal¨¡ bajt

         pop       cx

; ------ n vrat registr–

InitInd3:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
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

;         mov       ds:[AdrStr],si           ; p©ednastaven¡ adresy ©etˆzce
         mov       ds,ds:[InpSegm]          ; adresa vstupn¡ho bufferu
         mov       bp,1                     ; p©ednastaven¡ d‚lky

; ------ p©¡prava d‚lky ©etˆzce

         mov       cx,cs:[BuffOld]          ; konec na‡ten˜ch dat v bufferu
         sub       cx,si                    ; d‚lka zbytku dat
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

;         inc       cx
;         dec       si
;         dec       di

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

FindStr9:dec       si                       ; n vrat adresy ©etˆzce
         mov       cx,bp                    ; d‚lka nalezen‚ho ©etˆzce
         cmp       cx,2                     ; ©etˆzec nalezen ?
         jb        FindStrC                 ; d‚lka = 1
         ja        FindStrB

; ------ d‚lka 2 - offset >= 100h se ji‘ nevyplat¡

         mov       ax,si
         sub       ax,cs:[AdrStr]
         cmp       ax,100h
         jb        FindStrA

; ------ ©etˆzec nenalezen

FindStrC:mov       cx,1
         mov       al,ds:[si]               ; prvn¡ znak ©etˆzce
         jmp       short FindStrA

; ------ offset nalezen‚ho ©etˆzce

FindStrB:mov       ax,si                    ; adresa hledan‚ho ©etˆzce
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

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         mov       dx,ax                    ; offset ©etˆzce nebo znak k z pisu
         mov       si,cx                    ; d‚lka ©etˆzce

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
;        zak¢dov n¡ v˜stupn¡ho bufferu p©ed z pisem do souboru
; -----------------------------------------------------------------------------

Zakod    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ test, zda se m  buffer zak¢dovat

         test      byte ptr ds:[LCOMPrep],4 ; je zad no heslo ?
         jz        Zakod9                   ; nen¡ zad no heslo
         mov       dx,ds:[OutNum]           ; po‡et bajt– v bufferu
         or        dx,dx
         jz        Zakod9                   ; nejsou ‘ dn  data

; ------ ukazatel v k¢dovac¡m kl¡‡i

         mov       ax,word ptr ds:[Soub2S]
         xor       bx,bx
         mov       bl,al                    ; f ze v k¢dovac¡ tabulce
         mov       es,ds:[OutSegm]          ; v˜stupn¡ buffer
         xor       di,di                    ; ukazatel dat v bufferu
         cld

; ------ korekce pro po‡ tek souboru

         cmp       word ptr ds:[Soub2S+2],0
         jne       Zakod2                   ; nen¡ za‡ tek souboru
         or        ax,ax
         jnz       Zakod2
         mov       di,offset(LCOMEnd-LCOMBeg)
         sub       dx,offset(LCOMEnd-LCOMBeg)
         jbe       Zakod9
         mov       bl,offset(LCOMEnd-LCOMBeg)

; ------ zak¢dov n¡ dat

Zakod2:  mov       cx,word ptr ds:[bx+Klic]
         mov       al,es:[di]               ; bajt k zak¢dov n¡
         and       cl,7
         rol       al,cl
         xor       al,ch                    ; zak¢dov n¡ bajtu
         stosb
         inc       bl
         dec       dx
         jnz       Zakod2                   ; dal¨¡ bajt dat

; ------ n vrat registr–

Zakod9:  pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Zakod    ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ vyrovn vac¡ho bitov‚ho bufferu
; -----------------------------------------------------------------------------

WritBBuf PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      es

; ------ vyprazdneni bufferu

         mov       cx,ds:[OutNum]
         cmp       cx,0fe00h
         jb        WritBBf2

         call      Zakod                    ; zak¢dov n¡ bufferu p©ed z pisem

         push      ax
         push      bx
         push      dx
         push      ds

         add       word ptr ds:[Soub2S],cx
         adc       word ptr ds:[Soub2S+2],0

         xor       dx,dx
         mov       bx,ds:[Soub2I]
         mov       ds,ds:[OutSegm]
         mov       ah,40h
         int       21h

         jnc       WritBBf1
         cmp       ax,cx
WritBBf1:pop       ds
         pop       dx
         pop       bx
         pop       ax
         mov       word ptr ds:[OutNum],0
         jnc       WritBBf2

         mov       si,offset WritTxt
         jmp       Chyba

; ------ zv˜¨en¡ po‡tu bajt– ve v˜stupn¡m bufferu, kontrola p©ete‡en¡

WritBBf2:mov       cx,ds:[BitNum]           ; po‡et bajt– ve vyrovn vac¡m buff.
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

WritBBf9:mov       si,offset ConvTxt
         jmp       Chyba                     ; chyba - nelze zkomprimovat

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
;        zobrazen¡ znaku DOS
; -----------------------------------------------------------------------------

DispCh   PROC      NEAR

         push      ax
         push      dx
         mov       dl,al
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispCh   ENDP

; -----------------------------------------------------------------------------
;        zad n¡ hesla
; -----------------------------------------------------------------------------

ZadHesl  PROC      NEAR

; ------ test, zda m  b˜t heslo zad no

         test      byte ptr ds:[LCOMPrep],4 ; m  b˜t heslo zad no ?
         jz        ZadHesl9                 ; nem  b˜t zad no
         cmp       byte ptr ds:[HesloN],0   ; je ji‘ heslo zad no ?
         jnz       ZadHesl2                 ; heslo je ji‘ zad no

; ------ zobrazen¡ v˜zvy k zad n¡ hesla

         mov       si,offset HesloTxt
         call      DispTxt                  ; v˜zva k zad n¡ hesla

; ------ zad n¡ textu hesla

         mov       dx,offset HesloBuf       ; buffer k zad n¡ hesla
         mov       ah,0ah
         int       21h                      ; zad n¡ textu hesla

; ------ vymaz n¡ © dku s heslem

         mov       al,13
         call      DispCh                   ; n vrat na za‡ tek © dku
         mov       cx,78                    ; po‡et znak– k vymaz n¡
         mov       al," "
ZadHesl1:call      DispCh                   ; vymaz n¡ znaku
         loop      ZadHesl1
         mov       al,13
         call      DispCh

; ------ stanoven¡ d‚lky textu a konverze na velk  p¡smena

ZadHesl2:xor       bx,bx                    ; ukazatel v bufferu
ZadHesl3:cmp       bl,ds:[HesloN]           ; jsou ji‘ v¨echny znaky ?
         jae       ZadHesl4                 ; jsou ji‘ v¨echny znaky
         mov       al,ds:[bx+Heslo]         ; znak z bufferu
         cmp       al,13
         je        ZadHesl4                 ; konec textu
         call      UpCase                   ; konverze na velk‚ p¡smeno
         mov       ds:[bx+Heslo],al         ; ulo‘en¡ znaku
         inc       bx                       ; zv˜¨en¡ ukazatele znak–
         jmp       short ZadHesl3           ; dal¨¡ znak hesla
ZadHesl4:mov       ds:[HesloN],bl           ; skute‡n  d‚lka hesla

; ------ oprava, je-li d‚lka hesla = 0

ZadHesl5:or        bx,bx                    ; je nˆco zad no ?
         jnz       ZadHesl6                 ; je nˆco zad no OK
         and       byte ptr ds:[LCOMPrep],not 4 ; zru¨en¡ p©¡znaku zad n¡ hesla
         jmp       short ZadHesl9

; ------ sestaven¡ k¢dovac¡ho kl¡‡e

ZadHesl6:mov       cx,bx                    ; d‚lka textu hesla
         mov       di,offset Klic           ; k¢dovac¡ kl¡‡
         mov       bx,257                   ; d‚lka k¢dovac¡ho kl¡‡e
         mov       dx,-1                    ; v˜choz¡ hodnota k¢du

; ------ v˜po‡et k¢dovac¡ho kl¡‡e

ZadHesl7:mov       si,offset Heslo          ; buffer s textem hesla
         call      CheckSum                 ; kontroln¡ sou‡et kl¡‡e
         mov       ds:[di],dl               ; ni‘¨¡ bajt kontroln¡ho sou‡tu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy v kl¡‡i
         dec       bx                       ; ‡¡ta‡ d‚lky kl¡‡e
         jnz       ZadHesl7                 ; dal¨¡ znak kl¡‡e

ZadHesl9:
         ret

ZadHesl  ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ parametr– (CY=chyba zad n¡)
; -----------------------------------------------------------------------------

RozbPar  PROC      NEAR

; ------ vstup znaku p©¡znaku p©ep¡na‡e "/"

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        RozbPar8                 ; nen¡ nic zad no - OK
         cmp       al,"/"                   ; je p©ep¡na‡ ?
         jne       RozbPar8                 ; nen¡ p©ep¡na‡
         call      RozbChr                  ; vstup znaku "/"

; ------ vstup druh‚ho znaku parametru

         call      RozbChr                  ; na‡ten¡ znaku p©ep¡na‡e
         jc        RozbPar9                 ; nen¡ znak - chyba
         call      UpCase                   ; p©evod na velk‚ p¡smeno

; ------ parametr "/K" - k¢d Kamenick˜ch

         mov       ah,0                     ; k¢d Kamenick˜ch
         cmp       al,"K"                   ; je k¢d Kamenick˜ch ?
         je        RozbPar2                 ; je k¢d Kamenick˜ch

; ------ parametr "/L" - k¢d Latin 2

         mov       ah,1                     ; k¢d Latin 2
         cmp       al,"L"                   ; je k¢d Latin 2 ?
         je        RozbPar2                 ; je k¢d Latin 2

; ------ parametr "/I" - k¢d KOI 8

         mov       ah,2                     ; k¢d KOI 8
         cmp       al,"I"                   ; je k¢d KOI 8 ?
         je        RozbPar2                 ; je k¢d KOI 8

; ------ parametr "/B" - k¢d IBM, nen¡ n rodn¡ k¢d

         cmp       al,"B"                   ; je k¢d IBM ?
         jne       RozbPar3                 ; nen¡ k¢d IBM
         mov       ah,3
RozbPar2:and       byte ptr ds:[LCOMPrep],not 3 ; nulov n¡ bit–
         or        byte ptr ds:[LCOMPrep],ah ; p©¡znak k¢du
         jmp       short RozbPar            ; dal¨¡ parametr

; ------ parametr "/G" - uzam‡en¡ souboru heslem

RozbPar3:cmp       al,"G"                   ; uzam‡en¡ heslem ?
         jne       RozbPar4                 ; nen¡ heslo
         or        byte ptr ds:[LCOMPrep],4 ; p©¡znak zad n¡ hesla
         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        RozbPar8                 ; nen¡ heslo zad no
         cmp       al,'"'                   ; je text hesla ?
         jne       RozbPar                  ; nen¡ heslo - dal¨¡ parametr
         call      RozbChr                  ; zru¨en¡ znaku "
         xor       bx,bx                    ; ukazatel
RozbPr32:call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jc        RozbPar8                 ; konec textu
         cmp       al,'"'                   ; konec hesla ?
         je        RozbPar8                 ; konec hesla
         call      UpCase                   ; konverze na velk‚ p¡smeno
         cmp       bl,40                    ; max. d‚lka hesla
         jae       RozbPr33                 ; buffer pln˜
         mov       ds:[bx+Heslo],al         ; ulo‘en¡ znaku do bufferu
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e znak–
         mov       ds:[HesloN],bl           ; nov  d‚lka hesla
RozbPr33:jmp       short RozbPr32


RozbPar4:

RozbPar7:stc                                ; p©¡znak chybn‚ho parametru
         ret

RozbPar8:clc
RozbPar9:ret

RozbPar  ENDP

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

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
;        DX=vstupn¡ hodnota kontroln¡ho sou‡tu
; VSTUP:DX=v˜stupn¡ hodnota kontroln¡ho sou‡tu
; -----------------------------------------------------------------------------

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di
         jcxz      CheckSm2                 ; nejsou ‘ dn  data
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       CheckSm1                 ; dal¨¡ bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSum ENDP


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              Identifik tor souboru
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

         EVEN

LCOMBeg  LABEL     NEAR

         db        27,'XCD'                 ; identifik tor souboru
LCOMPrep dw        0                        ; p©ep¡na‡e
                                            ;  bit 0,1: 0=k¢d Kamenickych
                                            ;           1=k¢d Latin 2
                                            ;           2=k¢d KOI 8
                                            ;           3=k¢d IBM
                                            ;  bit 2: 1=zad no heslo

         EVEN                               ; sud  d‚lka !

LCOMEnd  LABEL     NEAR


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                  Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; ------ hl ¨en¡ programu

UvTxt    db        'HLPGEN V1.40 - generovani souboru napovedy HLP; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte jmeno vstupniho i vystupniho souboru !',13,10
         db        'Prepinace: /K ... soubor v kodu Kamenickych (implicitne)',13,10
         db        '           /L ... soubor v kodu Latin 2',13,10
         db        '           /I ... soubor v kodu KOI 8',13,10
         db        '           /B ... soubor v kodu IBM (=neni narodni kod)',13,10
         db        '           /G ["heslo"] ... uzamceni souboru heslem',13,10
         db        '$'

Soub1Txt db        'Chybne zadani vstupniho souboru !',13,10,'$'
Soub2Txt db        'Chybne zadani vystupniho souboru !',13,10,'$'

ReadTxt  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'

CRTxt    db        13,10,'$'

ConvTxt  db        'Soubor nelze zkonvertovat !',13,10,'$'

ExisTxt1 db        'Soubor $'
ExisTxt2 db        ' jiz existuje !',13,10,'Chete jej prepsat (A=ano) ? $'

TextSpc  db        '     ',8,8,8,8,8,'$'
TextNum  db        '(00%)',8,8,8,8,8,'$'

TextComp db        'Konvertuji soubor $'

HesloBuf db        41                       ; buffer pro zad n¡ textu hesla
HesloN   db        0                        ; d‚lka hesla
Heslo    db        41 dup(0)                ; text hesla

HesloTxt db        'Zadejte text hesla (max. 40 znaku): $'

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


SegPSP   dw        0                        ; adresa PSP

FilDate  dw        0                        ; datum souboru
FilTime  dw        0                        ; ‡as souboru
FilAtr   dw        0                        ; atributy souboru

InxSegm  dw        SEG InxSeg               ; segment indexov‚ tabulky
Inx0Segm dw        SEG Inx0Seg              ; segment inicializa‡n¡ch index–

InpSegm  dw        SEG InpSeg               ; vstupn¡ segment
;InpNum   dw        0                        ; po‡et bajt– ve vstupn¡m bufferu

OutSegm  dw        SEG OutSeg               ; v˜stupn¡ segment
OutNum   dw        3                        ; po‡et bajt– ve v˜stupn¡m bufferu

; ------ komprimace

BitBit   db        0                        ; po‡et bit– ve stavov‚m slovˆ
BitNum   dw        2                        ; po‡et bajt– ve vyrovn vac¡m buff.
BitBuff  db        100 dup(0)               ; vyrovn vac¡ v˜stupn¡ buffer

AdrStr   dw        0                        ; adresa nalezen‚ho ©etˆzce
MaxDel0  dw        MAXLEN-1                 ; max. d‚lka ©etˆzce - 1
MaxDel   dw        MAXLEN                   ; max. d‚lka ©etˆzce

BuffEnd  dw        0                        ; adresa konce dat v bufferu
BuffOld  dw        0                        ; star˜ za‡ tek bufferu

DispCit  dw        0                        ; ‡¡ta‡ k zobrazen¡ procent

Soub1S   dd        0                        ; velikost vstupn¡ho souboru
Soub0S   dw        0                        ; citac zpracovane casti HIGH

Soub2S   dd        0                        ; velikost v˜stupn¡ho souboru

Klic     db        257 dup(?)               ; k¢dovac¡ kl¡‡ hesla

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
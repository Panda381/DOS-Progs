
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                          QTIME v 1.0 (c) Miroslav N늤e놽k
;                             nastaven� p쯥sn괿o 놹su
;
; Pozn쟭ka: Je nutn� aktivace vys죐쟮� 놹su ? Klidn� by to mohlo vys죐at
;           nep쯥tr멼t� bez v쁹vy - u쮍t쯫l by se vys죐ac� dr쟴
;           (programu je to jedno)
;
; Jsou na눀t쟮y i setiny sekundy kv뻦i kompatibilit� s pæpadn쁬i pæ쮝죑i
; verzemi 놹sov� jednotky - posta눀, kdy� se budou vys죐at 2 nuly.
; -----------------------------------------------------------------------------
; Ovl쟡쟮� editoru KONTEXT:
;
;   Ctrl-F1 .......... zdrojov� text programu QTIME
;                         F10 ... ulo멷n� textu na disk (+ ENTER = konec)
;   Ctrl-F2 .......... n쟰ov늕a k port뻧 COM
;   Ctrl-F3 .......... n쟰ov늕a k ovl쟡쟮� data a 놹su pomoc� DOS
;   Alt-F8 ........... nastaven� zna뇃y v textu
;   Alt-F9/Alt-F10 ... p쯥de쮔�/n쟳leduj죅� zna뇃a
;   ESC .............. menu programu KONTEXT
;   F9 ............... definice makrokl쟶esy programu KONTEXT
; -----------------------------------------------------------------------------
; Komunika뇆� protokol:
;
;   1.- Program vys죐� na port COM znak v쁹vy VYZVA (nap�. "?") a�
;       do chv죐e, dokud nep쯫jme synchroniza뇆� znak SYNCHRO (nap�. "=")
;   2.- Ignoruje pæpadn� dalÆ znaky "SYNCHRO".
;   3.- P쯫j죑� text zpr쟶y - 16 눀slic v po쯠d�:   RRRRMMDDhhmmssxx
;        (RRRR=rok/MM=m늮죅/DD=den/hh=hodina/mm=minuta/ss=sekunda/xx=setina)
;   5.- P쯫 neplatn� zpr쟶� se pokouÆ o nov� p쯥nos a� do doby TIME-OUT
;
; Komunika뇆� znaky jsou voleny tak, 멷 je lze k줰ovat 4-bitov� (je mo몁� pou몼t
; p쯥nos i pomoc� 4 bit� paraleln죋o portu).
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

; ------ nastaven� parametr� programu

VYZVA    EQU       "?"                      ; znak v쁹vy pro vysl쟮� zpr쟶y
SYNCHRO  EQU       "="                      ; synchroniza뇆� znak p쯥d zpr쟶ou
                                            ; (je mo몁� vyslat i v죅e ne� 1)

TIMEOUT  EQU       2 * 18                   ; TIME-OUT pæjmu (v 1/18 sekundy)
                                            ; (povolen� rozsah 1 a� 65534)
                                            ; (lze p쯥ru쮑t t굫 Ctrl-Break)

; V cel굆 programu se uchov쟶� CS=DS=ES !

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ rozbor pækazov괿o 찤dku (mus� b쁳 nic nebo znak "1" a� "4")

Start:   mov       si,81h                   ; za뇿tek pækazov괿o 찤dku
         mov       cl,ds:[si-1]             ; d굃ka zadan괿o textu
         mov       ch,0
         cld
Rozbor1: mov       al,0                     ; implicitn� port COM 1
         jcxz      Rozbor2                  ; nen� dalÆ znak
         lodsb                              ; na뇍en� znaku z pækazov괿o 찤dku
         dec       cx                       ; sn죷en� 눀ta놽 zbyl쁟h znak�
         cmp       al," "                   ; mezera nebo ædic� znak ?
         jbe       Rozbor1                  ; mezera nebo tabul쟴or se ignoruje
         mov       ds:[TOutTxt1],al         ; ozna놽n� portu COM
         mov       ds:[COMTxt1],al          ; ozna놽n� portu COM
         sub       al,"1"                   ; korekce na 눀slo portu
         cmp       al,3                     ; je platn� 눀slo portu COM ?
         jbe       Rozbor2                  ; je to platn� 눀slo portu COM

; ------ chyba zad쟮� parametr� - zobrazen� n쟰ov늕y

         mov       dx,offset HelpTxt        ; text n쟰ov늕y
Chyba:   mov       ah,9
         int       21h                      ; zobrazen� textu n쟰ov늕y
         mov       ax,4c01h
         int       21h                      ; konec programu s chybou 1

; ------ adresa portu COM

Rozbor2: push      ds
         mov       ah,0                     ; AX = 눀slo portu COM 0 a� 3
         xchg      ax,bx                    ; BX <- 눀slo portu COM 0 a� 3
         shl       bx,1                     ; offset v tabulce BIOS
         mov       ax,40h
         mov       ds,ax                    ; DS <- datov� segment BIOS
         mov       ax,ds:[bx]               ; adresa portu COM
         or        ax,ax                    ; je port COM platn� ?
         pop       ds
         mov       dx,offset COMTxt         ; text - port neplatn�
         jz        Chyba                    ; port COM nen� platn�
         mov       ds:[AdrPort],ax          ; adresa portu COM

; ------ pæprava po뇿te뇆죋o 놹su pro TIME-OUT

         call      GetBTime                 ; na뇍en� 눀ta놽 놹su BIOS
         sub       ax,1                     ; mal� korekce pro pæpad, 멷 눀ta�
         sbb       dx,0                     ;   je zastaven a cykluje +1-1+1-1
         mov       word ptr ds:[OldBTime],ax ; 즧chova po뇿te뇆죋o 놹su LOW
         mov       word ptr ds:[OldBTime+2],dx ; 즧chova po뇿te뇆죋o 놹su HIGH

; ------ obsluha TIME-OUT

Prijem1: call      TestTOut                 ; test TIME-OUT

; ------ test, zda je

Prijem2:












; ------ vysl쟮� v쁹vy k vysl쟮� zpr쟶y

Prijem1: mov       al,VYZVA                 ; znak v쁹vy k vysl쟮�
         call      OutCChr                  ; vysl쟮� znaku v쁹vy na port

; ------ 놽k쟮� na synchroniza뇆� znak

         call      InpCChr                  ; pæjem znaku
         cmp       al,SYNCHRO               ; je synchroniza뇆� znak ?
         jne       Prijem1                  ; 놽k쟮� na synchroniza뇆� znak

; ------ vypu쮝늧� dalÆch synchroni


; ------ pæjem dat

         mov       si,offset TabDat         ; tabulka dat k pæjmu
Prijem2: mov       cx,ds:[si+6]             ; po놽t 눀slic polo멾y
         call      InpCNum                  ; na뇍en� 눀sla
         jc        Prijem1                  ; chyba
         cmp       ax,ds:[si+2]             ; minim쟫n� hodnota polo멾y
         jb        Prijem1                  ; chyba
         cmp       ax,ds:[si+4]             ; maxim쟫n� hodnota polo멾y
         ja        Prijem1                  ; chyba
         mov       ds:[si],ax               ; ulo멷n� na뇍en� hodnoty
         add       si,8                     ; dalÆ polo멾a
         cmp       si,offset TabDat0        ; je konec tabulky ?
         jb        Prijem2                  ; nen� je쮝� konec tabulky

; ------ nastaven� syst굆ov괿o 놹su (je p쯥d datem, aby to bylo p쯥sn늞i)

         mov       ah,2ch                   ; slu멳a pro nastaven� 놹su
         mov       ch,byte ptr ds:[Hodina]  ; hodina
         mov       cl,byte ptr ds:[Minuta]  ; minuta
         mov       dh,byte ptr ds:[Sekunda] ; sekunda
         mov       dl,byte ptr ds:[Setina]  ; setina sekundy
         int       21h                      ; nastaven� syst굆ov괿o 놹su

; ------ nastaven� syst굆ov괿o data

         mov       ah,2bh                   ; slu멳a pro nastaven� data
         mov       cx,ds:[Rok]              ; rok
         mov       dh,byte ptr ds:[Mesic]   ; m늮죅
         mov       dl,byte ptr ds:[Den]     ; den
         int       21h                      ; nastaven� syst굆ov괿o data

; ------ konec programu

         mov       ax,4c00h                 ; n쟶ratov� k줰 0 = operace OK
         int       21h

; -----------------------------------------------------------------------------
;        na뇍en� 눀sla z portu COM
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
;        CX=po놽t 눀slic k na뇍en�
; V쒾TUP: AX=na뇍en� 눀slo
;         CY=nep쯫jata platn� 눀slice
; -----------------------------------------------------------------------------

InpCNum  PROC      NEAR

; ------ 즧chova registr�

         push      bx
         push      cx
         push      dx
         xor       bx,bx                    ; BX <- 0 st쯠da� 눀sla

; ------ na뇍en� 눀sla

InpCNum2:call      InpCNm                   ; na뇍en� jedn� 눀slice
         jc        InpCNum9                 ; chyba - p쯫jat neplatn� znak
         mov       ah,0                     ; AX = p쯫jat� 눀slice
         xchg      ax,bx                    ; AX <- st쯠da�, BX <- 눀slice
         mov       dx,10                    ; n쟳obitel 찤du
         mul       dx                       ; st쯠da� * 10
         add       bx,ax                    ; st쯠da� + 눀slice
         loop      InpCNum2                 ; na뇍en� dalÆ 눀slice

         clc                                ; pæznak operace OK
         xchg      ax,bx                    ; AX <- na뇍en� 눀slo

; ------ n쟶rat registr�

InpCNum9:pop       dx
         pop       cx
         pop       bx
         ret

InpCNum  ENDP

; -----------------------------------------------------------------------------
;        na뇍en� 눀slice z portu COM
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
; V쒾TUP: AL=na뇍en� 눀slice bin쟲n�
;         CY=nep쯫jata platn� 눀slice
; -----------------------------------------------------------------------------

InpCNm   PROC      NEAR

         call      InpCChr                  ; pæjem znaku z portu COM
         cmp       al,"0"                   ; je to platn� 눀slice ?
         jb        InpCNm2                  ; nen� to platn� 눀slice
         cmp       al,"9"                   ; je to platn� 눀slice ?
         ja        InpCNm2                  ; nen� to platn� 눀slice
         sub       al,"0"                   ; korekce na bin쟲n� 눀slici
         ret

InpCNm2: call      RetCChr                  ; navr쟠en� znaku do bufferu
         stc                                ; pæznak - neplatn� 눀slice
         ret

InpCNm   ENDP

; -----------------------------------------------------------------------------
;        navr쟠en� neplatn괿o p쯫jat괿o znaku do bufferu
; -----------------------------------------------------------------------------

RetCChr  PROC      NEAR

         mov       ds:[BuffChr],al          ; navr쟠en� znaku do bufferu
         ret

RetCChr  ENDP

; -----------------------------------------------------------------------------
;        pæjem znaku z portu COM (5 bit�)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
; V쒾TUP: AL=p쯫jat� znak z COM (bity 5, 6 a 7 jsou vynulovan�)
;         neuchov쟶� obsah registru AH !
; -----------------------------------------------------------------------------

InpCChr  PROC      NEAR

; ------ 즧chova registr�

         push      dx

; ------ na뇍en� znaku z bufferu

         mov       al,0                     ; pæznak neplatnosti znaku
         xchg      al,ds:[BuffChr]          ; na뇍en� znaku z bufferu
         or        al,al                    ; je znak z bufferu platn� ?
         jnz       InpCChr8                 ; znak z bufferu je platn�

; ------ obsluha TIME-OUT

         mov       dx,ds:[AdrPort]          ; adresa portu COM
InpCChr2:call      TestTOut                 ; test TIME-OUT

; ------ na뇍en� stavov괿o registru COM

         add       dx,5                     ; stavov� registr linky
         in        al,dx                    ; na뇍en� stavov괿o registru
         sub       dx,5                     ; datov� registr COM
         mov       ah,al                    ; AH <- 즧chova stavov괿o registru

; ------ test, zda je vys죐ac� registr COM pr쟺dn�

         test      al,20h                   ; je vys죐ac� registr pr쟺dn� ?
         jz        InpCChr4                 ; vys죐ac� registr nen� pr쟺dn�

; ------ vysl쟮� znaku v쁹vy na port

         mov       al,VYZVA                 ; znak v쁹vy pro vysl쟮� zpr쟶y
         out       dx,al                    ; vysl쟮� znaku na port COM

; ------ test, zda je p쯫jat n늞ak� znak

InpCChr4:test      ah,1                     ; je p쯫praven znak ?
         jz        InpCChr2                 ; znak nen� p쯫praven

; ------ na뇍en� p쯫jat괿o znaku

         in        al,dx                    ; na뇍en� p쯫jat괿o znaku z COM
         and       al,3fh                   ; maskov쟮� pæp. paritn죅h bit�

; ------ n쟶rat registr�

InpCChr8:pop       dx
         ret

InpCChr  ENDP

; -----------------------------------------------------------------------------
;        test p쯥te놽n� TIME-OUT (p쯫 TIME-OUT se program p쯥ruÆ)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
;        uchov쟶� registr pæznak� !
; -----------------------------------------------------------------------------

TestTOut PROC      NEAR

; ------ 즧chova registr�

         pushf
         push      ax
         push      dx

; ------ test u멼vatelsk괿o p쯥ru쮍n� z kl쟶esnice Ctrl-Break

         sti                                ; p쯥ru쮍n� mus� b쁳 povoleno
         mov       ah,0bh
         int       21h                      ; obsluha p쯥ru쮍n� Ctrl-Break

; ------ uplynul� 놹s od po뇿tku b늜u programu

         call      GetBTime                 ; na뇍en� syst굆ov괿o 눀ta놽 놹su
         sub       ax,word ptr ds:[OldBTime] ; dosud uplynul� 놹s
         sbb       dx,word ptr ds:[OldBTime+2]
         jnc       TestTOu2                 ; nen� p쯥te놽n� p쯥s p뻦noc

; ------ oprava p쯫 p쯥chodu p쯥s p뻦noc

         mov       word ptr ds:[OldBTime],0 ; inicializace po뇿te뇆죋o 놹su
         mov       word ptr ds:[OldBTime+2],0
         call      GetBTime                 ; na뇍en� nov괿o 놹su

; ------ kontrola, zda ji� ub늜l 놹s pro TIME-OUT

TestTOu2:or        dx,dx                    ; je p쯥te놽n� 놹su ?
         jnz       TestTOu4                 ; je p쯥te놽n� 놹su
         cmp       ax,TIMEOUT+1             ; 놹s pro TIME-OUT
         jb        TestTOu9                 ; nen� je쮝� TIME-OUT

; ------ je TIME-OUT pæjmu zpr쟶y

TestTOu4:mov       dx,offset TOutTxt        ; text hl젴en� chyby
         jmp       Chyba                    ; chybov� n쟶rat z programu

; ------ n쟶rat registr�

TestTOu9:pop       dx
         pop       ax
         popf
         ret

TestTOut ENDP

; -----------------------------------------------------------------------------
;        na뇍en� 놹su ze syst굆ov괿o 눀ta놽 BIOS
; -----------------------------------------------------------------------------
; V쒾TUP: DX:AX=syst굆ov� 눀ta� 놹su BIOS (눀t� po pærustc죅h asi 55 ms)
; -----------------------------------------------------------------------------

GetBTime PROC      NEAR

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; syst굆ov� 눀ta� 놹su LOW
         mov       dx,ds:[46ch+2]           ; syst굆ov� 눀ta� 놹su HIGH
         pop       ds
         ret

GetBTime ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

HelpTxt  db        'QTIME v1.0 - nastaveni presneho casu; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr programu cislo portu COM 1 az 4 !',13,10
         db        '$'

TOutTxt  db        'Chyba TIME-OUT: Zkontrolujte pripojeni jednotky k portu COM'
TOutTxt1 db        '1: !',13,10,'$'
COMTxt   db        'Zvoleny port COM'
COMTxt1  db        '1: neni pritomen !',13,10,'$'

; ------ data k na뇍en� (zachovat po쯠d� !)
; Struktura jedn� polo멾y (d굃ka polo멾y 8 bajt�):
;            0: (2) na뇍en� hodnota
;            2: (2) minim쟫n� hodnota
;            4: (2) maxim쟫n� hodnota
;            6: (2) po놽t 눀slic polo멾y

TabDat   label     byte
Rok      dw        0,1980,2100,4            ; rok
Mesic    dw        0,1,12,2                 ; m늮죅
Den      dw        0,1,31,2                 ; den
Hodina   dw        0,0,23,2                 ; hodina
Minuta   dw        0,0,63,2                 ; minuta
Sekunda  dw        0,0,63,2                 ; sekunda
Setina   dw        0,0,99,2                 ; setina sekundy
TabDat0  label     byte

OldBTime dd        0                        ; uschovan� 놹s po뇿tku pro TIME-OUT

AdrPort  dw        0                        ; adresa portu COM
BuffChr  db        0                        ; uschovan� navr쟠en� p쯫jat� znak

Code     ENDS
         END       Start

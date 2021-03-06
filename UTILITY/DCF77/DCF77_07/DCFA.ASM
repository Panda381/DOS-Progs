
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                         DCFA v 1.0 - verze s ASCII komunikac�
;                               nastaven� p쯥sn괿o 놹su
;
; Nen�-li nutn� v쁹va k vysl쟮� 놹su, nen� pot쯥ba vys죐ac� sign쟫 zapojovat.
; Program pracuje bez ohledu na vys죐쟮� v쁹vy
;
; Jako parametr p쯫 spu쮝늧� programu se zad쟶� 눀slo 1 a� 4 = 눀slo portu COM.
;
; Komunika뇆� port COM mus� b쁳 nastaven na po멲dovan� p쯥nosov� parametry
; (pækazem MODE nebo MODE+SETCOM).
;
; Na portu COM posta눀 p쯫pojit pouze p쯫j죑ac� sign쟫 (a pæp. vys죐ac�),
; na ostatn죅h sign쟫ech nez쟫e몼.
;
; P쯫 p쯥nosu se pou몼vaj� pouze nejni뫅� 4 bity dat, ostatn� bity se ignoruj�.
; Lze proto pou몼t nap�. 5-bitov� p쯥nos nebo data transponovat (nap�. OR 30h).
;
; Program navrac� n쟶ratov� k줰 1 p쯫 chyb�, 0 p쯫 operaci OK
; -----------------------------------------------------------------------------
; Ovl쟡쟮� editoru KONTEXT:
;
;   Ctrl-F1 .......... zdrojov� text programu DCFA (ASCII komunikace)
;                         F10 ... ulo멷n� textu na disk (+ ENTER = konec)
;   Ctrl-F2 .......... zdrojov� text programu DCFB (bin쟲n� komunikace)
;                         F10 ... ulo멷n� textu na disk (+ ENTER = konec)
;   Ctrl-F3 .......... n쟰ov늕a k port뻧 COM
;   Ctrl-F4 .......... n쟰ov늕a k ovl쟡쟮� data a 놹su pomoc� DOS
;   Alt-F8 ........... nastaven� zna뇃y v textu
;   Alt-F9/Alt-F10 ... p쯥de쮔�/n쟳leduj죅� zna뇃a
;   ESC .............. menu programu KONTEXT
;   F9 ............... definice makrokl쟶esy programu KONTEXT
; -----------------------------------------------------------------------------
;
;                            Komunika뇆� protokol
;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;�                 program:               �       jednotka zdroje 놹su:        �
;쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� vys죐� na COM znaky v쁹vy (nap�. "?"), � dokon뇎je p쯥de쮔� vys죐쟮�,       �
;� 놽k� na odd늢ovac� znak (cokoliv jin괿o� pæpadn� po멲davky v쁹vy ignoruje  �
;� ne� 눀slice)                           �                                    �
;쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� do뇃al se odd늢ovac죋o znaku           � vy쮔e odd늢ovac� znak (nap�. "=")  �
;�                                        � jako za뇿tek dalÆ zpr쟶y          �
;쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� vys죐� na COM znaky v쁹vy (nap�. "?"), � znaky v쁹vy b늜em vys죐쟮�         �
;� 놽k� na prvn� platnou 눀slici          � ignoruje                           �
;쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� p쯫j죑� zpr쟶u - 14 눀slic             � vys죐� zpr쟶u - 14 눀slic          �
;� v po쯠d� RRRRMMDDhhmmss                � v po쯠d� RRRRMMDDhhmmss            �
;�       (RRRR=rok/MM=m늮죅/DD=den/hh=hodina/mm=minuta/ss=sekunda)             �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;      P쯫 neplatn� zpr쟶� se pokouÆ o nov� p쯥nos a� do doby TIME-OUT
;
; Program vys죐� znaky v쁹vy b늜em p쯥nosu neust쟫e (pro pæpad ztr쟴y spojen�
; uprost쯥d zpr쟶y). To m뼇e vyu몼t jednotka zdroje 놹su k aktivaci vys죐쟮�
; jednotliv쁟h znak� p쯫 p쯥nosu. Tento zp뻮ob bude nutno pou몼t u rezidentn�
; verze programu - program bude moct p쯫j죑at nejrychleji 18 bajt� za sekundu,
; znaky v쁹vy by proto mohly b쁳 pou멼ty jako potvrzen� p쯫pravenosti k pæjmu
; dalÆho znaku.
; -----------------------------------------------------------------------------
;
;              Zapojen� nulov괿o modemu (pro tuto aplikaci nen�
;               pot쯥ba zapojovat sign쟫y RTS->CTS a DTR->DSR)
;
;   Canon         Canon                    Canon
;   9 pin        25 pin                   25 pin
;  �袴袴�        �袴袴�                   �袴袴�
;  �  5 픔컴컴   �  7 픔컴컴컴컴컴컴컴컴컴�  7 �  GND   zem 0 V
;  �  2 픔컴컴   �  3 픔컴컴컴�\ /컴컴컴컴�  3 �  RxD   p쯫j죑an� data
;  �  3 픔컴컴   �  2 픔컴컴컴�/ \컴컴컴컴�  2 �  TxD   vys죐an� data
;  �  7 픔커     �  4 픔커             旼캘  4 �  RTS   몺dost vys죐a놽
;  �  8 �<켸     �  5 �<켸             읕>�  5 �  CTS   vys죐쟮� povoleno
;  �  6 �<커     �  6 �<커             旼>�  6 �  DSR   p쯥nos povolen
;  �  4 픔켸     � 20 픔켸             읕캘 20 �  DTR   kan쟫 p쯫praven
;  �  9 �        � 22 �                   � 22 �  RI    v쁹va
;  �  1 �        �  8 �                   �  8 �  DCD   즦ove� sign쟫u
;  훤袴暠        훤袴暠                   훤袴暠
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

; ------ nastaven� parametr� programu

VYZVA    EQU       "?"                      ; znak v쁹vy pro vysl쟮� zpr쟶y

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

; ------ adresa portu COM (AL=눀slo portu COM 0 a� 3)

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
         mov       word ptr ds:[OldBTime],ax ; 즧chova po뇿te뇆죋o 놹su LOW
         mov       word ptr ds:[OldBTime+2],dx ; 즧chova po뇿te뇆죋o 놹su HIGH

; ------ 놽k쟮� na odd늢ovac� znak

Prijem1: call      InpCChr                  ; pæjem znaku
         cmp       al,10                    ; je odd늢ovac� znak ?
         jb        Prijem1                  ; 놽k쟮� na odd늢ovac� znak

; ------ vypu쮝늧� dalÆch odd늢ovac죅h znak�

Prijem2: call      InpCChr                  ; pæjem znaku
         cmp       al,10                    ; je to platn� znak ?
         jae       Prijem2                  ; 놽k쟮� na platn� znak
         call      RetCChr                  ; navr쟠en� znaku do bufferu
         mov       word ptr ds:[AdrTOut],offset StruTxt ; bude chyba struktury

; ------ pæjem zpr쟶y

         mov       si,offset TabDat         ; tabulka dat k pæjmu
Prijem3: mov       cx,ds:[si+6]             ; po놽t 눀slic polo멾y
         call      InpCNum                  ; na뇍en� 눀sla
         jc        Prijem1                  ; chyba
         cmp       ax,ds:[si+2]             ; minim쟫n� hodnota polo멾y
         jb        Prijem1                  ; chyba
         cmp       ax,ds:[si+4]             ; maxim쟫n� hodnota polo멾y
         ja        Prijem1                  ; chyba
         mov       ds:[si],ax               ; ulo멷n� na뇍en� hodnoty
         add       si,8                     ; dalÆ polo멾a
         cmp       si,offset TabDat0        ; je konec tabulky ?
         jb        Prijem3                  ; nen� je쮝� konec tabulky

; ------ nastaven� syst굆ov괿o 놹su

         mov       ah,2dh                   ; slu멳a pro nastaven� 놹su
         mov       ch,byte ptr ds:[Hodina]  ; hodina
         mov       cl,byte ptr ds:[Minuta]  ; minuta
         mov       dh,byte ptr ds:[Sekunda] ; sekunda
         mov       dl,0                     ; setina sekundy
         int       21h                      ; nastaven� syst굆ov괿o 놹su
         cmp       al,0
         jne       Prijem1                  ; chyba - neplatn� 놹s

; ------ nastaven� syst굆ov괿o data

         mov       ah,2bh                   ; slu멳a pro nastaven� data
         mov       cx,ds:[Rok]              ; rok
         mov       dh,byte ptr ds:[Mesic]   ; m늮죅
         mov       dl,byte ptr ds:[Den]     ; den
         int       21h                      ; nastaven� syst굆ov괿o data
         cmp       al,0
         jne       Prijem1                  ; chyba - neplatn� datum

; ------ pæprava dne pro hl젴en�

         mov       al,byte ptr ds:[Den]     ; nastaven� den
         mov       di,offset DatTxtD        ; den
         call      DekNm                    ; dek줰ov쟮� 눀sla dne

; ------ pæprava m늮죅e pro hl젴en�

         mov       al,byte ptr ds:[Mesic]   ; nastaven� m늮죅
         mov       di,offset DatTxtM        ; m늮죅
         call      DekNm                    ; dek줰ov쟮� 눀sla m늮죅e

; ------ pæprava roku pro hl젴en�

         mov       ax,ds:[Rok]              ; nastaven� rok
         mov       cl,100
         div       cl                       ; rozd늢en� na stolet� a rok
         mov       di,offset DatTxtR        ; rok - stolet�
         call      DekNm                    ; dek줰ov쟮� stolet� roku
         xchg      al,ah
         mov       di,offset DatTxtR+2      ; rok
         call      DekNm                    ; dek줰ov쟮� roku

; ------ pæprava hodiny pro hl젴en�

         mov       al,byte ptr ds:[Hodina]  ; nastaven� hodina
         mov       di,offset DatTxtH        ; hodina
         call      DekNm                    ; dek줰ov쟮� 눀sla hodiny

; ------ pæprava minuty pro hl젴en�

         mov       al,byte ptr ds:[Minuta]  ; nastaven� minuta
         mov       di,offset DatTxtMI       ; minuta
         call      DekNm                    ; dek줰ov쟮� 눀sla minuty

; ------ pæprava sekundy pro hl젴en�

         mov       al,byte ptr ds:[Sekunda] ; nastaven� sekunda
         mov       di,offset DatTxtS        ; sekunda
         call      DekNm                    ; dek줰ov쟮� 눀sla sekundy

; ------ zobrazen� hl젴en� o nastaven� data a 놹su

         mov       dx,offset DatTxt         ; text hl젴en�
         mov       ah,9
         int       21h                      ; zobrazen� hl젴en�

; ------ konec programu

         mov       ax,4c00h                 ; n쟶ratov� k줰 0 = operace OK
         int       21h

; -----------------------------------------------------------------------------
;        dek줰ov쟮� 눀sla AL pro hl젴en� do bufferu DS:DI
; -----------------------------------------------------------------------------

DekNm    PROC      NEAR

         push      ax
         aam                                ; rozd늢en� na 눀slice
         or        ax,"00"                  ; korekce na ASCII 눀slice
         mov       ds:[di+1],al             ; ni뫅� 눀slice
         cmp       ah,"0"                   ; je to platn� 눀slice ?
         je        DekNm2                   ; je to nev쁹namn� nula
         mov       ds:[di],ah               ; ulo멷n� vyĿ� 눀slice
DekNm2:  pop       ax
         ret

DekNm    ENDP

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
         cmp       al,10                    ; je to platn� 눀slice ?
         cmc
         jnc       InpCNm2                  ; je to platn� 눀slice
         call      RetCChr                  ; navr쟠en� znaku do bufferu
InpCNm2: ret

InpCNm   ENDP

; -----------------------------------------------------------------------------
;        navr쟠en� neplatn괿o p쯫jat괿o znaku do bufferu (uchov쟶� pæznaky)
; -----------------------------------------------------------------------------

RetCChr  PROC      NEAR

         mov       ds:[BuffChr],al          ; navr쟠en� znaku do bufferu
         ret

RetCChr  ENDP

; -----------------------------------------------------------------------------
;        pæjem znaku z portu COM (4 bity)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
; V쒾TUP: AL=p쯫jat� znak z COM (bity 4, 5, 6 a 7 jsou vynulovan�)
;         neuchov쟶� obsah registru AH !
; -----------------------------------------------------------------------------

InpCChr  PROC      NEAR

; ------ 즧chova registr�

         push      dx

; ------ na뇍en� znaku z bufferu

         mov       al,-1                    ; pæznak neplatnosti znaku
         xchg      al,ds:[BuffChr]          ; na뇍en� znaku z bufferu
         cmp       al,-1                    ; je znak z bufferu platn� ?
         jne       InpCChr8                 ; znak z bufferu je platn�

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
         and       al,1111b                 ; nulov쟮� nepot쯥bn쁟h bit�

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

TestTOu4:mov       dx,ds:[AdrTOut]          ; text hl젴en� chyby
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

AdrTOut  dw        TOutTxt                  ; adresa hl젴en� pro TIME-OUT

HelpTxt  db        'DCFA v1.0 - nastaveni presneho casu; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr programu cislo portu COM 1 az 4 !',13,10
         db        '$'

TOutTxt  db        'Chyba TIME-OUT: Zkontrolujte pripojeni jednotky casu k portu COM'
TOutTxt1 db        '1: !',13,10,'$'
StruTxt  db        'Chyba TIME-OUT: Chybna struktura dat od jednotky casu !',13,10,'$'
COMTxt   db        'Zvoleny port COM'
COMTxt1  db        '1: neni pritomen !',13,10,'$'

; ------ text pro hl젴en� p쯫 operaci OK

DatTxt   db        'Datum: '
DatTxtD  db        ' 1.'
DatTxtM  db        ' 1.'
DatTxtR  db        '0000, cas: '
DatTxtH  db        ' 1:'
DatTxtMI db        '00:'
DatTxtS  db        '00'
         db        13,10,'$'

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
Minuta   dw        0,0,59,2                 ; minuta
Sekunda  dw        0,0,59,2                 ; sekunda
TabDat0  label     byte

OldBTime dd        0                        ; uschovan� 놹s po뇿tku pro TIME-OUT

AdrPort  dw        0                        ; adresa portu COM
BuffChr  db        -1                       ; uschovan� navr쟠en� p쯫jat� znak
                                            ;   -1 = pæznak, 멷 nen� znak

Code     ENDS
         END       Start


; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                               KODPRN
;               k줰ov쟮� n쟲odn죅h font� pro tisk쟲nu
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

HI       EQU       256
bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
bit8     EQU       100h
bit9     EQU       200h
bit10    EQU       400h
bit11    EQU       800h
bit12    EQU       1000h
bit13    EQU       2000h
bit14    EQU       4000h
bit15    EQU       8000h


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; start a inicializace

; *****************************************************************************
;
;                         data rezidentn� 뇿sti
;
; *****************************************************************************

; ------ identifikace programu v pam늯i

Ident    db        'KODPRN V1.11'
Ident0   label     byte
SegRez   dw        0                        ; segment rezidentn� 뇿sti

; ------ p뻱odn� adresy obsluh p쯥ru쮍n�

Old17    dd        0                        ; p뻱odn� adresa INT 17h

; ------ stav tisku, konfigurace

PortLPT  dw        0                        ; 눀slo portu LPT

InOutKod label     word                     ; k줰y jako slovo
InKod    db        0ffh                     ; vstupn� k줰
                                            ;   0=bez diakritiky
                                            ;   1=Kamenickych
                                            ;   2=Latin 2
                                            ;   3=KOI 8

OutKod   db        0ffh                     ; v쁲tupn� k줰
                                            ;   0=bez diakritiky
                                            ;   1=Kamenickych
                                            ;   2=Latin 2
                                            ;   3=KOI 8

; ------ monitorov쟮� ESC sekvenc�

EscAdr   dw        0                        ; adresa pokra뇇v쟮� obsluhy ESC

; -----------------------------------------------------------------------------
;        obsluha INT 17h
; -----------------------------------------------------------------------------


Int17    PROC      FAR

; ------ kontrola, zda je obsluhovan� tisk쟲na

         cmp       dx,cs:[PortLPT]          ; je to obsluhovan� tisk쟲na ?
         jne       Int179                   ; nen� to obsluhovan� tisk쟲na

; ------ obsluha funkce 2 - dotaz na stav tisk쟲ny

         cmp       ah,2
         jne       Int172
         call      TestInst                 ; test instalace

; ------ obsluha funkce 0 - vysl쟮� bajtu na tisk쟲nu

Int172:  or        ah,ah                    ; vysl쟮� znaku na tisk쟲nu ?
         jnz       Int179                   ; nen� vysl쟮� znaku na tisk쟲nu

; ------ konverze znaku

         call      Konvert                  ; konverze znaku

; ------ p뻱odn� obsluha tisk쟲ny

Int179:  jmp       dword ptr cs:[Old17]     ; p뻱odn� obsluha INT 17h

Int17    ENDP

; -----------------------------------------------------------------------------
;        test instalace programu (ES:DI=adresa identifika뇆죋o textu)
; -----------------------------------------------------------------------------

TestInst PROC      NEAR

         cmp       di,offset Ident          ; adresa identifika뇆죋o textu
         jne       TestIns5                 ; nen� dotaz na instalaci

; ------ 즧chova registr�

         push      si
         push      di
         push      cx
         push      ds

; ------ porovn쟮� text�

         push      cs
         pop       ds                       ; DS <- CS
         mov       si,di                    ; adresa identifika뇆죋o textu
         mov       cx,offset(Ident0-Ident)  ; d굃ka textu
         cld                                ; sm늭 nahoru
         repe      cmpsb                    ; porovn쟮� text�
         jne       TestIns2                 ; nen� shoda text�
         mov       es:[SegRez],cs           ; rezidentn� segment

; ------ n쟶rat registr�

TestIns2:pop       ds
         pop       cx
         pop       di
         pop       si
TestIns5:ret

TestInst ENDP

; -----------------------------------------------------------------------------
;        konverze znak�
; -----------------------------------------------------------------------------

Konvert  PROC      NEAR

         push      bx
         push      ds
         push      cs
         pop       ds

; ------ kontrola, zda je obsluha ESC

         cmp       word ptr ds:[EscAdr],0   ; 놽k� se na obsluhu ESC ?
         jne       Konvert2                 ; 놽k� se na obsluhu ESC
         cmp       al,28                    ; je znak FS ?
         je        Konvert1                 ; je FS
         cmp       al,27                    ; je znak ESC ?
         jne       Konvert7                 ; nen� znak ESC
Konvert1:mov       word ptr ds:[EscAdr],offset Escape ; z쟪ladn� obsluha ESC
         jmp       short Konvert9

Konvert2:xor       bx,bx
         xchg      bx,ds:[EscAdr]
         call      bx                       ; pokra뇇v쟮� obsluhy ESC
         jmp       short Konvert9

; ------ kontrola, zda se konverze prov쟡�

Konvert7:cmp       al,128
         jb        Konvert9                 ; konverze se neprov쟡�

; ------ konverze znaku podle tabulky

         xor       bx,bx
         mov       bl,ds:[OutKod]           ; v쁲tupn� k줰
         shl       bx,1
         shl       bx,1
         or        bl,ds:[InKod]            ; vstupn� k줰
         shl       bx,1
         mov       bx,ds:[AdrTab+bx]        ; adresa p쯥vodn� tabulky
         or        bx,bx                    ; je tabulka definovan� ?
         jz        Konvert9                 ; nen� p쯥vodn� tabulka
         sub       al,128                   ; korekce znaku na offset
         xlat                               ; konverze znaku podle tabulky

Konvert9:pop       ds
         pop       bx
         ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;             z쟪ladn� obsluha ESC k줰�
; -----------------------------------------------------------------------------

Escape   PROC      NEAR

; ------ k줰y pro ignorov쟮� 1 znaku

         mov       bx,offset Esc1           ; obsluha ignorov쟮� 1 bajtu
         cmp       al,"J"
         je        Escape8
         cmp       al,"j"
         je        Escape8
         cmp       al,"3"
         je        Escape8
         cmp       al,"A"
         je        Escape8
         cmp       al,"c"
         je        Escape8
         cmp       al,"N"
         je        Escape8
         cmp       al," "
         je        Escape8
         cmp       al,"Q"
         je        Escape8
         cmp       al,"l"
         je        Escape8
         cmp       al,"!"
         je        Escape8
         cmp       al,"R"
         je        Escape8
         cmp       al,"k"
         je        Escape8


; ------ k줰 "ESC B n n n ... 0"

         mov       bx,offset EscTab
         cmp       al,"B"
         je        Escape8
         cmp       al,"D"
         je        Escape8

; ------ k줰 "ESC b c n n n ... 0"

         mov       bx,offset EscTab1
         cmp       al,"b"
         je        Escape8


; ------ k줰 "ESC C 0 n" nebo "ESC C n"

         mov       bx,offset EscC0n
         cmp       al,"C"
         je        Escape8

; ------ k줰y se 2 znaky - ignoruj� se n쟳leduj죅� 2 bajty

         mov       bx,offset EscF1n
         cmp       al,"f"
         je        Escape8
         cmp       al,"e"
         je        Escape8
         cmp       al,"$"
         je        Escape8
         cmp       al,"\"
         je        Escape8
         cmp       al,"X"
         je        Escape8
         cmp       al,"*"
         je        Escape8
         cmp       al,"K"
         je        Escape8
         cmp       al,"L"
         je        Escape8
         cmp       al,"Y"
         je        Escape8
         cmp       al,"Z"
         je        Escape8
         cmp       al,"?"
         je        Escape8
         cmp       al,"^"
         jne       Escape9

; ------ bude dalÆ obsluha

Escape8: mov       ds:[EscAdr],bx           ; adresa dalÆ obsluhy

Escape9: ret

Escape   ENDP

; -----------------------------------------------------------------------------
;        ignorov쟮� 1 bajtu - nebude se konvertovat
; -----------------------------------------------------------------------------

Esc1     PROC      NEAR

         ret

Esc1     ENDP

; -----------------------------------------------------------------------------
;        k줰 "ESC f 1 n", "ESC e 1 n", "ESC f 0 n"
; -----------------------------------------------------------------------------

EscF1n   PROC      NEAR

         mov       word ptr ds:[EscAdr],offset Esc1
EscF1n9: ret

EscF1N   ENDP

; -----------------------------------------------------------------------------
;        k줰 "ESC C 0 n"
; -----------------------------------------------------------------------------

EscC0n   PROC      NEAR

         or        al,al
         jnz       EscC0n1
         mov       word ptr ds:[EscAdr],offset Esc1
EscC0n1: ret

EscC0n   ENDP

; -----------------------------------------------------------------------------
;        tabel쟴ory
; -----------------------------------------------------------------------------

EscTab1  PROC      NEAR

         mov       word ptr ds:[EscAdr],offset EscTab
         ret

EscTab1  ENDP

; -----------------------------------------------------------------------------
;        k줰 - tabel쟴ory
; -----------------------------------------------------------------------------

EscTab   PROC      NEAR

         or        al,al
         jz        EscTab9                  ; konec tabel쟴or�
         mov       word ptr ds:[EscAdr],offset EscTab
EscTab9: ret

EscTab   ENDP

; -----------------------------------------------------------------------------
;        p쯥vodn� tabulky
; -----------------------------------------------------------------------------

AdrTab   label     word
         dw        0                        ; 00: ----
         dw        offset TbKamCs0          ; K0: Kamenickych -> bez
         dw        offset TbLatCs0          ; L0: Latin 2 -> bez
         dw        offset TbKoiCs0          ; I0: KOI 8 -> bez

         dw        0                        ; 0K: ----
         dw        0                        ; KK: ----
         dw        offset TbLatKam          ; LK: Latin 2 -> Kamenick쁟h
         dw        offset TbKoiKam          ; IK: KOI 8 -> Kamenick쁟h

         dw        0                        ; 0L: ----
         dw        offset TbKamLat          ; KL: Kamenick쁟h -> Latin 2
         dw        0                        ; LL: ----
         dw        offset TbKoiLat          ; IL: KOI 8 -> Latin 2

         dw        0                        ; 0I: ----
         dw        offset TbKamKoi          ; KI: Kamenick쁟h -> KOI 8
         dw        offset TbLatKoi          ; LI: Latin 2 -> KOI 8
         dw        0                        ; II: ----

; ------ konverzn� tabulka z k줰u Kamenick쁟h na k줰 bez diakritiky

TbKamCS0 label     byte
         db        'CuedaDTceELIllAA'
         db        'EzZooOuUyOUSLYRt'
         db        'aiounNUOsrrR',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn� tabulka z k줰u Latin 2 na k줰 bez diakritiky

TbLatCS0 label     byte
         db        'CueaauccleOoiZAC'
         db        'ELlooLlSsOUTtLxc'
         db        'aiouAaZzEerzCs',174,175
         db        176,177,178,179,180,'AAES',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,207
         db        'dDDEdNIIe',217,218,219,220,'TU',223
         db        'O',225,'ONnnSsRUrUyYt',239
         db        240,241,242,243,244,245,246,247,248,249,250,'uRr',254,255

; ------ konverzn� tabulka z k줰u KOI 8 na k줰 bez diakritiky

TbKoiCS0 label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,'a',194,'cder',199,'uiullono'
         db        'oarstu',214,'eayz',219,220,221,222,223
         db        224,'A',226,'CDER',231,'UIULLONO'
         db        'OARSTU',246,'EAYZ',251,252,253,254,255

; ------ konverzn� tabulka z k줰u Latin 2 na k줰 Kamenick쁟h

TbLatKam label     byte
         db        'C걗a꽄ccle솕iZ랢'
         db        '릨뜐뵜똕s솞넖Lx�'
         db        '젩∀Aa뮂Ee퓕�s��'
         db        176,177,178,179,180,'뢅뎂',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,'x'
         db        'dD꿄깷딬�',217,218,219,220,'T�',223
         db        '�',225,'쬛n쩁Œ뿪슆쓙',39
         db        '-".""��,�"',250,'걻�',254,255

; ------ konverzn� tabulka z k줰u KOI 8 na k줰 Kamenick쁟h

TbKoiKam label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        '�졓뇘닼훮죾뜉뵥�'
         db        '뱞ŀ윢횂젞뫢',220,39,248,'�'
         db        '퓦��뀎コ쉵쫲쐷쪜'
         db        '쭖옕넇킄룤뮺',252,'^',254,255

; ------ konverzn� tabulka z k줰u Kamenick쁟h na k줰 Latin 2

TbKamLat label     byte
         db        172,'걗',212,'�',210,155,159,216,183,145,214,150,146,'�',181
         db        '�',167,166,'뱮',224,133,233,236,'솞',230,149,237,252,156
         db        '젩∀',229,213,222,226,231,253,234,232,'/',245,174,175
         db        176,177,178,179,180,179,186,187,191,185,186,187,188,188,217,191
         db        192,193,194,195,196,197,179,186,200,201,202,203,204,205,206,205
         db        188,205,196,200,192,218,201,186,205,217,218,219,220,219,219,223
         db        'a',225,'G','p','S','s','m','t','f','T','O','d','0','/','E','N'
         db        '=','+','>','<',218,217,246,'=',248,250,250,'V','n','2',254,255

; ------ konverzn� tabulka z k줰u KOI 8 na k줰 Latin 2

TbKoiLat label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        '�','�','�',159,212,216,234,'�',129,'�',133,146,150,148,229,'�'
         db        147,132,253,231,156,'�','�','�','�',236,167,'�',243, 39,248,'�'
         db        '�',181,'�',172,210,183,232,'�','�',214,222,145,149,'�',213,224
         db        226,142,252,230,155,233,'�','�',181,237,166,'�',249,'^',254,255

; ------ konverzn� tabulka z k줰u Kamenick쁟h na k줰 KOI 8

TbKamKoi label     byte
         db        227,200,215,196,209,228,244,195,197,229,235,233,204,203,241,225
         db        247,218,250,208,205,239,202,245,217,237,232,243,236,249,242,212
         db        193,201,207,213,206,238,234,240,211,210,198,230,131,173,174,175
         db        176,177,178,231,246,246,246,224,224,246,231,224,226,226,226,224
         db        194,251,219,214,199,223,214,214,194,192,251,219,214,199,223,251
         db        251,219,219,194,194,192,192,223,223,226,192,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn� tabulka z k줰u Latin 2 na k줰 KOI 8

TbLatKoi label     byte
         db        128,200,215,'a',209,202,'c','c','l','e',237,208,'i','Z',241,'C'
         db        247,235,203,208,205,236,204,'S','s',237,232,244,212,'L','x',195
         db        193,201,207,213,'A','a',250,218,'E','e',224,'z',227,'s',174,175
         db        176,177,178,231,246,225,'A',229,'S',246,231,224,226,'Z','z',224
         db        194,251,219,214,199,223,'A','a',194,192,251,219,213,199,223,'x'
         db        'd','D',228,'E',196,238,233,'I',197,226,192,219,220,'T',234,223
         db        239,225,240,'N','n',206,243,211,230,245,198,232,217,249,'t', 39
         db        '-',252,'.',220,220,131,':',',',222,252,254,200,242,210,254,255


; *****************************************************************************
;
;                         start programu (instalace)
;
; *****************************************************************************

Init:

; ------ zobrazen� 즪odn죋o textu

         mov       dx,offset UvTxt          ; 즪odn� text
         mov       ah,9
         int       21h                      ; zobrazen� 즪odn죋o textu

; ------ pæprava k dek줰ov쟮� parametr�

         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po놽t znak�
         cld

; ------ nalezen� platn괿o znaku

Init1:   jcxz      Init4                    ; nen� 몺dn� dalÆ znak
         lodsb                              ; na뇍en� znaku
         dec       cx                       ; sn죷en� 눀ta놽 znak�
         cmp       al," "                   ; je mezera ?
         je        Init1                    ; je mezera - p쯥sko놽n�
         cmp       al,9                     ; je tabel쟴or ?
         je        Init1                    ; je tabel쟴or - p쯥sko놽n�

; ------ konverze znaku na velk� p죛meno

         cmp       al,"a"
         jb        Init12
         cmp       al,"z"
         ja        Init12
         sub       al,32

; ------ parametr "!" - odinstalov쟮� programu

Init12:  cmp       al,"!"
         jne       Init2                    ; nen� parametr "!"
         mov       byte ptr ds:[DInsPar],1  ; po멲davek odinstalov쟮� programu
         jmp       short Init1

; ------ parametr 1 a� 4 - volba 눀sla portu

Init2:   cmp       al,"1"
         jb        Init3                    ; nen� 눀slo portu
         cmp       al,"4"
         ja        Init3                    ; nen� 눀slo portu
         sub       al,"1"
         mov       byte ptr ds:[PortLPT],al ; 눀slo portu LPT
         jmp       short Init1

; ------ zad쟮� k줰u

Init3:   mov       ah,0                     ; 0=bez diakritiky
         cmp       al,"0"
         je        Init32                   ; bez diakritiky
         inc       ah                       ; 1=Kamenickych
         cmp       al,"K"
         je        Init32                   ; Kamenickych
         inc       ah                       ; 2=Latin 2
         cmp       al,"L"
         je        Init32                   ; Latin 2
         inc       ah
         cmp       al,"I"
         jne       ChybZad                  ; nen� ani KOI 8

; ------ ulo멷n� po멲dovan괿o k줰u

Init32:  cmp       byte ptr ds:[InKod],0ffh ; byl zad쟮 vstupn� k줰 ?
         jne       Init33                   ; vstupn� k줰 byl ji� zad쟮
         mov       byte ptr ds:[InKod],ah   ; jako prvn� zad쟮 vstupn� k줰
         jmp       short Init1
Init33:  mov       byte ptr ds:[OutKod],ah  ; zad쟮 v쁲tupn� k줰
         jmp       short Init1

; ------ chyba zad쟮� parametr�

ChybZad: mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
         int       20h

; ------ ozna놽n� 눀sla portu do text�

Init4:   mov       al,byte ptr ds:[PortLPT] ; instalovan� port
         add       al,"1"                   ; korekce na znak ASCII
         mov       ds:[DeInsTx1],al
         mov       ds:[DInsTxt1],al
         mov       ds:[KonvTxt1],al
         mov       ds:[NoInsTx1],al

; ------ test stavu instalace programu KODPRN (mus� b쁳 ES=CS)

         mov       ds:[SegRez],ds           ; tento program
         mov       di,offset Ident          ; identifika뇆� text
         mov       dx,ds:[PortLPT]          ; port LPT
         mov       ah,2                     ; funkce dotazu na stav
         int       17h                      ; dotaz na stav - test instalace

; ------ p쯥nesen� parametr� do rezidentn죋o modulu

         mov       es,ds:[SegRez]           ; rezidentn� modul
         mov       al,ds:[InKod]            ; vstupn� k줰
         cmp       al,0ffh
         je        Init5                    ; vstupn� k줰 nebyl zad쟮
         mov       es:[InKod],al            ; p쯥nesen� vstupn죋o k줰u
Init5:   mov       al,ds:[OutKod]           ; v쁲tupn� k줰
         cmp       al,0ffh
         je        Init51                   ; nebyl zad쟮
         mov       es:[OutKod],al
         mov       word ptr es:[EscAdr],0

; ------ stanoven� implicitn죅h k줰�

Init51:  cmp       byte ptr es:[OutKod],0ffh
         jne       Init52
         mov       byte ptr es:[OutKod],0   ; implicitn� v쁲tupn� k줰 bez diakr.
Init52:  cmp       byte ptr es:[InKod],0ffh
         jne       Init53
         mov       byte ptr es:[InKod],1    ; implicitn� vstupn� k줰 Kamenick쁟h

; ------ pæpadn� odinstalov쟮� programu

Init53:  cmp       byte ptr ds:[DInsPar],0  ; po멲duje se odinstalov쟮� ?
         je        Init6                    ; nepo멲duje se odinstalov쟮�
         jmp       OdInst                   ; odinstalov쟮� programu

; ------ nen�-li program nainstalov쟮, jeho nainstalov쟮�

Init6:   call      Hlaseni                  ; zobrazen� hl젴en� o k줰ov쟮�
         mov       ax,cs                    ; tento program
         cmp       ax,ds:[SegRez]
         jne       Init7                    ; v쮍 je OK
         jmp       Instal                   ; prvn� instalace programu

Init7:   int       20h

; ------ chyba - zobrazen� n쟰ov늕y

         mov       dx,offset HelpTxt
         mov       ah,9
         int       21h

; -----------------------------------------------------------------------------
;        zobrazen� hl젴en� o prov쟡늧� konverzi
; -----------------------------------------------------------------------------

Hlaseni  PROC      NEAR

; ------ zobrazen� prvn� 뇿sti hl젴en�

         mov       dx,offset KonvTxt
         mov       ah,9
         int       21h

; ------ hl젴en�, 멷 funkce je vypnuta

         mov       dx,offset KonvTxt6
         mov       ax,es:[InOutKod]         ; vstupn� a v쁲tupn� k줰
         or        al,al                    ; je vstupn� k줰 bez diakritiky ?
         jz        Hlaseni7                 ; vstupn� k줰 bez diakritiky
         cmp       al,ah                    ; je stejn� k줰 ?
         je        Hlaseni7                 ; je stejn� k줰 - funkce vypnuta

; ------ zobrazen� vstupn죋o k줰u

         mov       al,es:[InKod]
         call      Hlas0                    ; zji쮝늧� adresy textu
         mov       ah,9
         int       21h

; ------ zobrazen� odd늢ovac� 쮑pky

         mov       dx,offset KonvTxt7
         mov       ah,9
         int       21h

; ------ zobrazen� v쁲tupn죋o k줰u

         mov       al,es:[OutKod]
         call      Hlas0                    ; zji쮝늧� adresy text
Hlaseni7:mov       ah,9
         int       21h

; ------ zobrazen� zbytku textu hl젴en�

         mov       dx,offset KonvTxt8
         mov       ah,9
         int       21h
         ret

Hlaseni  ENDP

; -----------------------------------------------------------------------------
;        dek줰ov쟮� textu k줰u AL
; -----------------------------------------------------------------------------

Hlas0    PROC      NEAR

         mov       dx,offset KonvTxt2       ; Kamenick쁟h
         dec       al
         jz        Hlas04
         mov       dx,offset KonvTxt3       ; Latin 2
         dec       al
         jz        Hlas04
         mov       dx,offset KonvTxt4       ; KOI 8
         dec       al
         jz        Hlas04
         mov       dx,offset KonvTxt5       ; bez diakritiky
Hlas04:  ret

Hlas0    ENDP

; -----------------------------------------------------------------------------
;        odinstalov쟮� programu (DS=CS)
; -----------------------------------------------------------------------------

OdInst   PROC      NEAR

; ------ kontrola, zda byl program nainstalov쟮

         mov       dx,offset NoInsTxt       ; text - nebyl nainstalov쟮
         mov       ax,ds                    ; tento segment
         cmp       ax,ds:[SegRez]           ; byl nainstalov쟮 ?
         je        OdInst8                  ; program nebyl nainstalov쟮

; ------ kontrola INT 17h

         mov       dx,offset DInsTxt        ; hl젴en� - nelze odinstalovat
         mov       ax,3517h
         int       21h                      ; poskytnut� adresy INT 17h
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8                  ; program nelze odinstalovat

; ------ n쟶rat adresy INT 17h

         push      ds
         lds       dx,es:[Old17]            ; p뻱odn� adresa INT 17h
         mov       ax,2517h
         int       21h                      ; n쟶rat adresy INT 17h
         pop       ds

; ------ uvoln늧� segmentu programu

         mov       ah,49h
         int       21h                      ; uvoln늧� segmentu programu
         mov       dx,offset DeInsTxt       ; hl젴en� - byl odinstalov쟮

; ------ chybov� a koncov� hl젴en�

OdInst8: mov       ah,9
         int       21h                      ; zobrazen� textu chybov괿o hl젴en�
         int       20h

OdInst   ENDP

; -----------------------------------------------------------------------------
;        instalace programu (DS=CS)
; -----------------------------------------------------------------------------

Instal   PROC      NEAR

; ------ 즧chova adresy INT 17h

         mov       ax,3517h
         int       21h                      ; poskytnut� adresy INT 17h
         mov       word ptr ds:[Old17],bx   ; offset INT 17h
         mov       word ptr ds:[Old17+2],es ; segment INT 17h

; ------ instalace INT 17h

         mov       dx,offset Int17
         mov       ax,2517h
         int       21h                      ; instalace INT 17h

; ------ uvoln늧� segmentu prost쯥d�

         mov       es,ds:[2ch]              ; segment prost쯥d�
         mov       ah,49h
         int       21h                      ; uvoln늧� segmentu prost쯥d�

; ------ instalace programu

         mov       dx,offset Init           ; konec rezidentn� 뇿sti
         int       27h                      ; instalace programu

Instal   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

DInsPar  db        0                        ; pæznak po멲davku odinstalov쟮�

UvTxt    db        'KODPRN V1.11 - konverze fontu tiskarny; (c) Miroslav Nemecek'
         db        13,10,'$'

DeInsTxt db        'KODPRN byl odinstalovan z portu LPT'
DeInsTx1 db        '1.',13,10,'$'

DInsTxt  db        'KODPRN nelze odinstalovat z portu LPT'
DInsTxt1 db        '1 !',13,10,'$'

NoInsTxt db        'KODPRN nebyl dosud pro LPT'
NoInsTx1 db        '1 nainstalovan !',13,10,'$'

KonvTxt  db        'Konverze pro LPT'
KonvTxt1 db        '1: $'
KonvTxt2 db        'Kamenickych$'
KonvTxt3 db        'Latin 2$'
KonvTxt4 db        'KOI 8$'
KonvTxt5 db        'bez diakritiky$'
KonvTxt6 db        'neprovadi se$'
KonvTxt7 db        ' -> $'
KonvTxt8 db        '.',13,10,'$'

HelpTxt  db        'Zadejte: 1 az 4  - konverze znaku pro LPT1 az LPT4',13,10
         db        '         K,L,I,0 - vstupni (1.znak) a vystupni (2.znak) kod:',13,10
         db        '                      K - kod Kamenickych',13,10
         db        '                      L - kod Latin 2',13,10
         db        '                      I - kod KOI 8',13,10
         db        '                      0 - bez diakritiky',13,10
         db        '         !       - odinstalovani programu z pameti',13,10
         db        '         ?       - tato napoveda',13,10
         db        '$'

Code     ENDS
         END       Start

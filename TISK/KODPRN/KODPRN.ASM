
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               KODPRN
;               k¢dov n¡ n rodn¡ch font– pro tisk rnu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

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
;                         data rezidentn¡ ‡ sti
;
; *****************************************************************************

; ------ identifikace programu v pamˆti

Ident    db        'KODPRN V1.11'
Ident0   label     byte
SegRez   dw        0                        ; segment rezidentn¡ ‡ sti

; ------ p–vodn¡ adresy obsluh p©eru¨en¡

Old17    dd        0                        ; p–vodn¡ adresa INT 17h

; ------ stav tisku, konfigurace

PortLPT  dw        0                        ; ‡¡slo portu LPT

InOutKod label     word                     ; k¢dy jako slovo
InKod    db        0ffh                     ; vstupn¡ k¢d
                                            ;   0=bez diakritiky
                                            ;   1=Kamenickych
                                            ;   2=Latin 2
                                            ;   3=KOI 8

OutKod   db        0ffh                     ; v˜stupn¡ k¢d
                                            ;   0=bez diakritiky
                                            ;   1=Kamenickych
                                            ;   2=Latin 2
                                            ;   3=KOI 8

; ------ monitorov n¡ ESC sekvenc¡

EscAdr   dw        0                        ; adresa pokra‡ov n¡ obsluhy ESC

; -----------------------------------------------------------------------------
;        obsluha INT 17h
; -----------------------------------------------------------------------------


Int17    PROC      FAR

; ------ kontrola, zda je obsluhovan  tisk rna

         cmp       dx,cs:[PortLPT]          ; je to obsluhovan  tisk rna ?
         jne       Int179                   ; nen¡ to obsluhovan  tisk rna

; ------ obsluha funkce 2 - dotaz na stav tisk rny

         cmp       ah,2
         jne       Int172
         call      TestInst                 ; test instalace

; ------ obsluha funkce 0 - vysl n¡ bajtu na tisk rnu

Int172:  or        ah,ah                    ; vysl n¡ znaku na tisk rnu ?
         jnz       Int179                   ; nen¡ vysl n¡ znaku na tisk rnu

; ------ konverze znaku

         call      Konvert                  ; konverze znaku

; ------ p–vodn¡ obsluha tisk rny

Int179:  jmp       dword ptr cs:[Old17]     ; p–vodn¡ obsluha INT 17h

Int17    ENDP

; -----------------------------------------------------------------------------
;        test instalace programu (ES:DI=adresa identifika‡n¡ho textu)
; -----------------------------------------------------------------------------

TestInst PROC      NEAR

         cmp       di,offset Ident          ; adresa identifika‡n¡ho textu
         jne       TestIns5                 ; nen¡ dotaz na instalaci

; ------ £schova registr–

         push      si
         push      di
         push      cx
         push      ds

; ------ porovn n¡ text–

         push      cs
         pop       ds                       ; DS <- CS
         mov       si,di                    ; adresa identifika‡n¡ho textu
         mov       cx,offset(Ident0-Ident)  ; d‚lka textu
         cld                                ; smˆr nahoru
         repe      cmpsb                    ; porovn n¡ text–
         jne       TestIns2                 ; nen¡ shoda text–
         mov       es:[SegRez],cs           ; rezidentn¡ segment

; ------ n vrat registr–

TestIns2:pop       ds
         pop       cx
         pop       di
         pop       si
TestIns5:ret

TestInst ENDP

; -----------------------------------------------------------------------------
;        konverze znak–
; -----------------------------------------------------------------------------

Konvert  PROC      NEAR

         push      bx
         push      ds
         push      cs
         pop       ds

; ------ kontrola, zda je obsluha ESC

         cmp       word ptr ds:[EscAdr],0   ; ‡ek  se na obsluhu ESC ?
         jne       Konvert2                 ; ‡ek  se na obsluhu ESC
         cmp       al,28                    ; je znak FS ?
         je        Konvert1                 ; je FS
         cmp       al,27                    ; je znak ESC ?
         jne       Konvert7                 ; nen¡ znak ESC
Konvert1:mov       word ptr ds:[EscAdr],offset Escape ; z kladn¡ obsluha ESC
         jmp       short Konvert9

Konvert2:xor       bx,bx
         xchg      bx,ds:[EscAdr]
         call      bx                       ; pokra‡ov n¡ obsluhy ESC
         jmp       short Konvert9

; ------ kontrola, zda se konverze prov d¡

Konvert7:cmp       al,128
         jb        Konvert9                 ; konverze se neprov d¡

; ------ konverze znaku podle tabulky

         xor       bx,bx
         mov       bl,ds:[OutKod]           ; v˜stupn¡ k¢d
         shl       bx,1
         shl       bx,1
         or        bl,ds:[InKod]            ; vstupn¡ k¢d
         shl       bx,1
         mov       bx,ds:[AdrTab+bx]        ; adresa p©evodn¡ tabulky
         or        bx,bx                    ; je tabulka definovan  ?
         jz        Konvert9                 ; nen¡ p©evodn¡ tabulka
         sub       al,128                   ; korekce znaku na offset
         xlat                               ; konverze znaku podle tabulky

Konvert9:pop       ds
         pop       bx
         ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;             z kladn¡ obsluha ESC k¢d–
; -----------------------------------------------------------------------------

Escape   PROC      NEAR

; ------ k¢dy pro ignorov n¡ 1 znaku

         mov       bx,offset Esc1           ; obsluha ignorov n¡ 1 bajtu
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


; ------ k¢d "ESC B n n n ... 0"

         mov       bx,offset EscTab
         cmp       al,"B"
         je        Escape8
         cmp       al,"D"
         je        Escape8

; ------ k¢d "ESC b c n n n ... 0"

         mov       bx,offset EscTab1
         cmp       al,"b"
         je        Escape8


; ------ k¢d "ESC C 0 n" nebo "ESC C n"

         mov       bx,offset EscC0n
         cmp       al,"C"
         je        Escape8

; ------ k¢dy se 2 znaky - ignoruj¡ se n sleduj¡c¡ 2 bajty

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

; ------ bude dal¨¡ obsluha

Escape8: mov       ds:[EscAdr],bx           ; adresa dal¨¡ obsluhy

Escape9: ret

Escape   ENDP

; -----------------------------------------------------------------------------
;        ignorov n¡ 1 bajtu - nebude se konvertovat
; -----------------------------------------------------------------------------

Esc1     PROC      NEAR

         ret

Esc1     ENDP

; -----------------------------------------------------------------------------
;        k¢d "ESC f 1 n", "ESC e 1 n", "ESC f 0 n"
; -----------------------------------------------------------------------------

EscF1n   PROC      NEAR

         mov       word ptr ds:[EscAdr],offset Esc1
EscF1n9: ret

EscF1N   ENDP

; -----------------------------------------------------------------------------
;        k¢d "ESC C 0 n"
; -----------------------------------------------------------------------------

EscC0n   PROC      NEAR

         or        al,al
         jnz       EscC0n1
         mov       word ptr ds:[EscAdr],offset Esc1
EscC0n1: ret

EscC0n   ENDP

; -----------------------------------------------------------------------------
;        tabel tory
; -----------------------------------------------------------------------------

EscTab1  PROC      NEAR

         mov       word ptr ds:[EscAdr],offset EscTab
         ret

EscTab1  ENDP

; -----------------------------------------------------------------------------
;        k¢d - tabel tory
; -----------------------------------------------------------------------------

EscTab   PROC      NEAR

         or        al,al
         jz        EscTab9                  ; konec tabel tor–
         mov       word ptr ds:[EscAdr],offset EscTab
EscTab9: ret

EscTab   ENDP

; -----------------------------------------------------------------------------
;        p©evodn¡ tabulky
; -----------------------------------------------------------------------------

AdrTab   label     word
         dw        0                        ; 00: ----
         dw        offset TbKamCs0          ; K0: Kamenickych -> bez
         dw        offset TbLatCs0          ; L0: Latin 2 -> bez
         dw        offset TbKoiCs0          ; I0: KOI 8 -> bez

         dw        0                        ; 0K: ----
         dw        0                        ; KK: ----
         dw        offset TbLatKam          ; LK: Latin 2 -> Kamenick˜ch
         dw        offset TbKoiKam          ; IK: KOI 8 -> Kamenick˜ch

         dw        0                        ; 0L: ----
         dw        offset TbKamLat          ; KL: Kamenick˜ch -> Latin 2
         dw        0                        ; LL: ----
         dw        offset TbKoiLat          ; IL: KOI 8 -> Latin 2

         dw        0                        ; 0I: ----
         dw        offset TbKamKoi          ; KI: Kamenick˜ch -> KOI 8
         dw        offset TbLatKoi          ; LI: Latin 2 -> KOI 8
         dw        0                        ; II: ----

; ------ konverzn¡ tabulka z k¢du Kamenick˜ch na k¢d bez diakritiky

TbKamCS0 label     byte
         db        'CuedaDTceELIllAA'
         db        'EzZooOuUyOUSLYRt'
         db        'aiounNUOsrrR',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn¡ tabulka z k¢du Latin 2 na k¢d bez diakritiky

TbLatCS0 label     byte
         db        'CueaauccleOoiZAC'
         db        'ELlooLlSsOUTtLxc'
         db        'aiouAaZzEerzCs',174,175
         db        176,177,178,179,180,'AAES',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,207
         db        'dDDEdNIIe',217,218,219,220,'TU',223
         db        'O',225,'ONnnSsRUrUyYt',239
         db        240,241,242,243,244,245,246,247,248,249,250,'uRr',254,255

; ------ konverzn¡ tabulka z k¢du KOI 8 na k¢d bez diakritiky

TbKoiCS0 label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,'a',194,'cder',199,'uiullono'
         db        'oarstu',214,'eayz',219,220,221,222,223
         db        224,'A',226,'CDER',231,'UIULLONO'
         db        'OARSTU',246,'EAYZ',251,252,253,254,255

; ------ konverzn¡ tabulka z k¢du Latin 2 na k¢d Kamenick˜ch

TbLatKam label     byte
         db        'C‚a„–ccle™”iZŽC'
         db        'Š“”œŒSs™š†ŸLx‡'
         db        ' ¡¢£Aa’‘Ee¿z€s®¯'
         db        176,177,178,179,180,'A‰S',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,'x'
         db        'dD…Eƒ¥‹Iˆ',217,218,219,220,'T¦',223
         db        '•',225,'§Nn¤›¨«—ªš˜t',39
         db        '-".""­ö,ø"',250,'ž©',254,255

; ------ konverzn¡ tabulka z k¢du KOI 8 na k¢d Kamenick˜ch

TbKoiKam label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        'Ú À‡ƒˆªÄ¡–Œ”¤¢'
         db        '“„©¨Ÿ£Ã‚ ˜‘Â',220,39,248,'Å'
         db        '¿Ù€…‰«³š‹¦Šœ™¥•'
         db        '§Žž›†—´’Á',252,'^',254,255

; ------ konverzn¡ tabulka z k¢du Kamenick˜ch na k¢d Latin 2

TbKamLat label     byte
         db        172,'‚',212,'„',210,155,159,216,183,145,214,150,146,'Ž',181
         db        '',167,166,'“”',224,133,233,236,'™š',230,149,237,252,156
         db        ' ¡¢£',229,213,222,226,231,253,234,232,'/',245,174,175
         db        176,177,178,179,180,179,186,187,191,185,186,187,188,188,217,191
         db        192,193,194,195,196,197,179,186,200,201,202,203,204,205,206,205
         db        188,205,196,200,192,218,201,186,205,217,218,219,220,219,219,223
         db        'a',225,'G','p','S','s','m','t','f','T','O','d','0','/','E','N'
         db        '=','+','>','<',218,217,246,'=',248,250,250,'V','n','2',254,255

; ------ konverzn¡ tabulka z k¢du KOI 8 na k¢d Latin 2

TbKoiLat label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        'Ú',' ','À',159,212,216,234,'Ä',129,'¡',133,146,150,148,229,'¢'
         db        147,132,253,231,156,'£','Ã','‚',' ',236,167,'Â',243, 39,248,'Å'
         db        '¿',181,'Ù',172,210,183,232,'³','š',214,222,145,149,'™',213,224
         db        226,142,252,230,155,233,'´','',181,237,166,'Á',249,'^',254,255

; ------ konverzn¡ tabulka z k¢du Kamenick˜ch na k¢d KOI 8

TbKamKoi label     byte
         db        227,200,215,196,209,228,244,195,197,229,235,233,204,203,241,225
         db        247,218,250,208,205,239,202,245,217,237,232,243,236,249,242,212
         db        193,201,207,213,206,238,234,240,211,210,198,230,131,173,174,175
         db        176,177,178,231,246,246,246,224,224,246,231,224,226,226,226,224
         db        194,251,219,214,199,223,214,214,194,192,251,219,214,199,223,251
         db        251,219,219,194,194,192,192,223,223,226,192,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn¡ tabulka z k¢du Latin 2 na k¢d KOI 8

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

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ p©¡prava k dek¢dov n¡ parametr–

         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak–
         cld

; ------ nalezen¡ platn‚ho znaku

Init1:   jcxz      Init4                    ; nen¡ ‘ dn˜ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; je mezera ?
         je        Init1                    ; je mezera - p©esko‡en¡
         cmp       al,9                     ; je tabel tor ?
         je        Init1                    ; je tabel tor - p©esko‡en¡

; ------ konverze znaku na velk‚ p¡smeno

         cmp       al,"a"
         jb        Init12
         cmp       al,"z"
         ja        Init12
         sub       al,32

; ------ parametr "!" - odinstalov n¡ programu

Init12:  cmp       al,"!"
         jne       Init2                    ; nen¡ parametr "!"
         mov       byte ptr ds:[DInsPar],1  ; po‘adavek odinstalov n¡ programu
         jmp       short Init1

; ------ parametr 1 a‘ 4 - volba ‡¡sla portu

Init2:   cmp       al,"1"
         jb        Init3                    ; nen¡ ‡¡slo portu
         cmp       al,"4"
         ja        Init3                    ; nen¡ ‡¡slo portu
         sub       al,"1"
         mov       byte ptr ds:[PortLPT],al ; ‡¡slo portu LPT
         jmp       short Init1

; ------ zad n¡ k¢du

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
         jne       ChybZad                  ; nen¡ ani KOI 8

; ------ ulo‘en¡ po‘adovan‚ho k¢du

Init32:  cmp       byte ptr ds:[InKod],0ffh ; byl zad n vstupn¡ k¢d ?
         jne       Init33                   ; vstupn¡ k¢d byl ji‘ zad n
         mov       byte ptr ds:[InKod],ah   ; jako prvn¡ zad n vstupn¡ k¢d
         jmp       short Init1
Init33:  mov       byte ptr ds:[OutKod],ah  ; zad n v˜stupn¡ k¢d
         jmp       short Init1

; ------ chyba zad n¡ parametr–

ChybZad: mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
         int       20h

; ------ ozna‡en¡ ‡¡sla portu do text–

Init4:   mov       al,byte ptr ds:[PortLPT] ; instalovan˜ port
         add       al,"1"                   ; korekce na znak ASCII
         mov       ds:[DeInsTx1],al
         mov       ds:[DInsTxt1],al
         mov       ds:[KonvTxt1],al
         mov       ds:[NoInsTx1],al

; ------ test stavu instalace programu KODPRN (mus¡ b˜t ES=CS)

         mov       ds:[SegRez],ds           ; tento program
         mov       di,offset Ident          ; identifika‡n¡ text
         mov       dx,ds:[PortLPT]          ; port LPT
         mov       ah,2                     ; funkce dotazu na stav
         int       17h                      ; dotaz na stav - test instalace

; ------ p©enesen¡ parametr– do rezidentn¡ho modulu

         mov       es,ds:[SegRez]           ; rezidentn¡ modul
         mov       al,ds:[InKod]            ; vstupn¡ k¢d
         cmp       al,0ffh
         je        Init5                    ; vstupn¡ k¢d nebyl zad n
         mov       es:[InKod],al            ; p©enesen¡ vstupn¡ho k¢du
Init5:   mov       al,ds:[OutKod]           ; v˜stupn¡ k¢d
         cmp       al,0ffh
         je        Init51                   ; nebyl zad n
         mov       es:[OutKod],al
         mov       word ptr es:[EscAdr],0

; ------ stanoven¡ implicitn¡ch k¢d–

Init51:  cmp       byte ptr es:[OutKod],0ffh
         jne       Init52
         mov       byte ptr es:[OutKod],0   ; implicitn¡ v˜stupn¡ k¢d bez diakr.
Init52:  cmp       byte ptr es:[InKod],0ffh
         jne       Init53
         mov       byte ptr es:[InKod],1    ; implicitn¡ vstupn¡ k¢d Kamenick˜ch

; ------ p©¡padn‚ odinstalov n¡ programu

Init53:  cmp       byte ptr ds:[DInsPar],0  ; po‘aduje se odinstalov n¡ ?
         je        Init6                    ; nepo‘aduje se odinstalov n¡
         jmp       OdInst                   ; odinstalov n¡ programu

; ------ nen¡-li program nainstalov n, jeho nainstalov n¡

Init6:   call      Hlaseni                  ; zobrazen¡ hl ¨en¡ o k¢dov n¡
         mov       ax,cs                    ; tento program
         cmp       ax,ds:[SegRez]
         jne       Init7                    ; v¨e je OK
         jmp       Instal                   ; prvn¡ instalace programu

Init7:   int       20h

; ------ chyba - zobrazen¡ n povˆdy

         mov       dx,offset HelpTxt
         mov       ah,9
         int       21h

; -----------------------------------------------------------------------------
;        zobrazen¡ hl ¨en¡ o prov dˆn‚ konverzi
; -----------------------------------------------------------------------------

Hlaseni  PROC      NEAR

; ------ zobrazen¡ prvn¡ ‡ sti hl ¨en¡

         mov       dx,offset KonvTxt
         mov       ah,9
         int       21h

; ------ hl ¨en¡, ‘e funkce je vypnuta

         mov       dx,offset KonvTxt6
         mov       ax,es:[InOutKod]         ; vstupn¡ a v˜stupn¡ k¢d
         or        al,al                    ; je vstupn¡ k¢d bez diakritiky ?
         jz        Hlaseni7                 ; vstupn¡ k¢d bez diakritiky
         cmp       al,ah                    ; je stejn˜ k¢d ?
         je        Hlaseni7                 ; je stejn˜ k¢d - funkce vypnuta

; ------ zobrazen¡ vstupn¡ho k¢du

         mov       al,es:[InKod]
         call      Hlas0                    ; zji¨tˆn¡ adresy textu
         mov       ah,9
         int       21h

; ------ zobrazen¡ oddˆlovac¡ ¨ipky

         mov       dx,offset KonvTxt7
         mov       ah,9
         int       21h

; ------ zobrazen¡ v˜stupn¡ho k¢du

         mov       al,es:[OutKod]
         call      Hlas0                    ; zji¨tˆn¡ adresy text
Hlaseni7:mov       ah,9
         int       21h

; ------ zobrazen¡ zbytku textu hl ¨en¡

         mov       dx,offset KonvTxt8
         mov       ah,9
         int       21h
         ret

Hlaseni  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ textu k¢du AL
; -----------------------------------------------------------------------------

Hlas0    PROC      NEAR

         mov       dx,offset KonvTxt2       ; Kamenick˜ch
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
;        odinstalov n¡ programu (DS=CS)
; -----------------------------------------------------------------------------

OdInst   PROC      NEAR

; ------ kontrola, zda byl program nainstalov n

         mov       dx,offset NoInsTxt       ; text - nebyl nainstalov n
         mov       ax,ds                    ; tento segment
         cmp       ax,ds:[SegRez]           ; byl nainstalov n ?
         je        OdInst8                  ; program nebyl nainstalov n

; ------ kontrola INT 17h

         mov       dx,offset DInsTxt        ; hl ¨en¡ - nelze odinstalovat
         mov       ax,3517h
         int       21h                      ; poskytnut¡ adresy INT 17h
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8                  ; program nelze odinstalovat

; ------ n vrat adresy INT 17h

         push      ds
         lds       dx,es:[Old17]            ; p–vodn¡ adresa INT 17h
         mov       ax,2517h
         int       21h                      ; n vrat adresy INT 17h
         pop       ds

; ------ uvolnˆn¡ segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu programu
         mov       dx,offset DeInsTxt       ; hl ¨en¡ - byl odinstalov n

; ------ chybov‚ a koncov‚ hl ¨en¡

OdInst8: mov       ah,9
         int       21h                      ; zobrazen¡ textu chybov‚ho hl ¨en¡
         int       20h

OdInst   ENDP

; -----------------------------------------------------------------------------
;        instalace programu (DS=CS)
; -----------------------------------------------------------------------------

Instal   PROC      NEAR

; ------ £schova adresy INT 17h

         mov       ax,3517h
         int       21h                      ; poskytnut¡ adresy INT 17h
         mov       word ptr ds:[Old17],bx   ; offset INT 17h
         mov       word ptr ds:[Old17+2],es ; segment INT 17h

; ------ instalace INT 17h

         mov       dx,offset Int17
         mov       ax,2517h
         int       21h                      ; instalace INT 17h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ instalace programu

         mov       dx,offset Init           ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu

Instal   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

DInsPar  db        0                        ; p©¡znak po‘adavku odinstalov n¡

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
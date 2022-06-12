
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               CONS212
;                   ovlada‡ tisk rny CONSUL 212
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

Ident    db        'CONS212 V1.0'
Ident0   label     byte
SegRez   dw        0                        ; segment rezidentn¡ ‡ sti

; ------ p–vodn¡ adresy obsluh p©eru¨en¡

Old17    dd        0                        ; p–vodn¡ adresa INT 17h

; ------ stav tisku, konfigurace

PortLPT  dw        0                        ; ‡¡slo portu LPT

InKod    db        0ffh                     ; vstupn¡ k¢d
                                            ;   1=Kamenickych
                                            ;   2=Latin 2
                                            ;   3=KOI 8

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

; ------ konverze znak– v z kladn¡ sadˆ

         cmp       al,"^"
         jne       Konvert5
         mov       al,163
         jmp       short Konvert9

; ------ konverze znaku podle tabulky

Konvert5:cmp       al,128
         jb        Konvert9                 ; konverze se neprov d¡
         sub       al,128                   ; korekce znaku na offset
         mov       bx,offset TabKam         ; konverzn¡ tabulka
         xlat                               ; konverze znaku podle tabulky

Konvert9:pop       ds
         pop       bx
         ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        p©evodn¡ tabulka
; -----------------------------------------------------------------------------

; ------ konverzn¡ tabulka z k¢du Kamenick˜ch

TabKam   label     byte
         db        227,200,215,196,209,228,244,195,197,229,235,233,204,203,241,225
         db        247,218,250,208,205,239,202,245,217,237,232,243,236,249,242,212
         db        193,201,207,213,206,238,234,240,211,210,198,230,'/',220,'<','>'
         db        ' ',' ',' ','|','|','|','|','+','+','|','|','+','+','+','+','+'
         db        '+','-','-','|','-','+','|','|','+','+','-','-','|','-','+','-'
         db        '+','-','-','+','+','+','+','+','+','+','+',' ',' ',' ',' ',' '
         db        'a',223,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
         db        '=','+','>','<','|','|',':','=',170,167,167,'V','n','2',167,' '

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

Init3:   mov       ah,1                     ; 1=Kamenick˜ch
         cmp       al,"K"
         je        Init32                   ; Kamenick˜ch
         inc       ah                       ; 2=Latin 2
         cmp       al,"L"
         je        Init32                   ; Latin 2
         inc       ah
         cmp       al,"I"
         jne       ChybZad                  ; nen¡ ani KOI 8
Init32:  mov       byte ptr ds:[InKod],ah   ; vstupn¡ k¢d
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

; ------ test stavu instalace programu CONS212 (mus¡ b˜t ES=CS)

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
; ------ stanoven¡ implicitn¡ch k¢d–

Init5:   cmp       byte ptr es:[InKod],0ffh
         jne       Init53
         mov       byte ptr es:[InKod],1    ; implicitn¡ vstupn¡ k¢d Kamenick˜ch

; ------ p©enesen¡ fontu

Init53:  mov       si,offset TabKam
         cmp       byte ptr es:[InKod],1
         je        Init54
         mov       si,offset TabLat
         cmp       byte ptr es:[InKod],2
         je        Init54
         mov       si,offset TabKoi
Init54:  mov       di,offset TabKam
         mov       cx,128
         cld
         rep       movsb                    ; p©enesen¡ fontu

; ------ p©¡padn‚ odinstalov n¡ programu

         cmp       byte ptr ds:[DInsPar],0  ; po‘aduje se odinstalov n¡ ?
         je        Init6                    ; nepo‘aduje se odinstalov n¡
         jmp       OdInst                   ; odinstalov n¡ programu

; ------ nen¡-li program nainstalov n, jeho nainstalov n¡

Init6:   call      Hlaseni                  ; zobrazen¡ hl ¨en¡ o k¢dov n¡
         mov       ax,cs                    ; tento program
         cmp       ax,ds:[SegRez]
         jne       Init7                    ; v¨e je OK
         jmp       Instal                   ; prvn¡ instalace programu

Init7:   int       20h


; -----------------------------------------------------------------------------
;        zobrazen¡ hl ¨en¡ o tisknut‚m k¢du
; -----------------------------------------------------------------------------

Hlaseni  PROC      NEAR

; ------ zobrazen¡ prvn¡ ‡ sti hl ¨en¡

         mov       dx,offset KonvTxt
         mov       ah,9
         int       21h

; ------ zobrazen¡ vstupn¡ho k¢du

         mov       al,es:[InKod]
         mov       dx,offset KonvTxt2       ; Kamenick˜ch
         dec       al
         jz        Hlaseni7
         mov       dx,offset KonvTxt3       ; Latin 2
         dec       al
         jz        Hlaseni7
         mov       dx,offset KonvTxt4       ; KOI 8
Hlaseni7:mov       ah,9
         int       21h

; ------ zobrazen¡ zbytku textu hl ¨en¡

         mov       dx,offset KonvTxt8
         mov       ah,9
         int       21h
         ret

Hlaseni  ENDP

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

UvTxt    db        'CONS212 V1.0 - ovladac tiskarny CONSUL 212; (c) Miroslav Nemecek'
         db        13,10,'$'

DeInsTxt db        'Ovladac CONS212 byl odinstalovan z portu LPT'
DeInsTx1 db        '1.',13,10,'$'

DInsTxt  db        'Ovladac CONS212 nelze odinstalovat z portu LPT'
DInsTxt1 db        '1 !',13,10,'$'

NoInsTxt db        'Ovladac CONS212 nebyl dosud pro LPT'
NoInsTx1 db        '1 nainstalovan !',13,10,'$'

KonvTxt  db        'Tisk na LPT'
KonvTxt1 db        '1 v kodu $'
KonvTxt2 db        'Kamenickych$'
KonvTxt3 db        'Latin 2$'
KonvTxt4 db        'KOI 8$'
KonvTxt8 db        '.',13,10,'$'

HelpTxt  db        'Zadejte: 1 az 4  - tiskarna pripojena na port LPT1 az LPT4',13,10
         db        '         K,L,I   - tisk textu v kodu:',13,10
         db        '                      K - kod Kamenickych',13,10
         db        '                      L - kod Latin 2',13,10
         db        '                      I - kod KOI 8',13,10
         db        '         !       - odinstalovani ovladace z pameti',13,10
         db        '         ?       - tato napoveda',13,10
         db        '$'

; ------ konverzn¡ tabulka z k¢du Latin 2

TabLat   label     byte
         db        'C',200,215,'a',209,202,'c','c','l',214,253,221,'i','Z',241,'C'
         db        247,235,203,208,205,236,204,'S','s',237,232,244,212,'L','x',195
         db        193,201,207,213,'A','a',250,218,'E','e','-','z',227,'s','<','>'
         db        ' ',' ',' ','|','|',225,'A',229,'S','|','|','+','+','Z','z','+'
         db        '+','-','-','|','-','+',226,194,'+','+','-','-','|','-','+','x'
         db        'd','D',228,246,196,238,233,'I',197,'+','+',' ',' ','T',234,' '
         db        239,223,240,'N','n',206,243,211,230,245,198,248,217,249,'t',162
         db        '-',173,174,175,176,220,':',171,170,168,167,200,242,210,167,' '

; ------ konverzn¡ tabulka z k¢du KOI 8

TabKoi   label     byte
         db        'C',213,215,220,223,' ',' ',' ',' ',' ',' ','a','i',' ','$',207
         db        201,'P','i','N',' ','n',' ',' ',' ','|','+','+','+','+','-',' '
         db        '=','+','>','<','|','|',':','=',170,'V','2','/','/',220,'<','>'
         db        ' ',223,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
         db        '+',193,'+',195,196,197,198,'-',200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,'|',215,192,217,218,'-',175,162,170,'+'
         db        '+',225,'+',227,228,229,230,'|',232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,'+',247,224,249,250,'+',168,163,167,' '

Code     ENDS
         END       Start


; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                               CONS212
;                   ovlada� tisk쟲ny CONSUL 212
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

Ident    db        'CONS212 V1.0'
Ident0   label     byte
SegRez   dw        0                        ; segment rezidentn� 뇿sti

; ------ p뻱odn� adresy obsluh p쯥ru쮍n�

Old17    dd        0                        ; p뻱odn� adresa INT 17h

; ------ stav tisku, konfigurace

PortLPT  dw        0                        ; 눀slo portu LPT

InKod    db        0ffh                     ; vstupn� k줰
                                            ;   1=Kamenickych
                                            ;   2=Latin 2
                                            ;   3=KOI 8

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

; ------ konverze znak� v z쟪ladn� sad�

         cmp       al,"^"
         jne       Konvert5
         mov       al,163
         jmp       short Konvert9

; ------ konverze znaku podle tabulky

Konvert5:cmp       al,128
         jb        Konvert9                 ; konverze se neprov쟡�
         sub       al,128                   ; korekce znaku na offset
         mov       bx,offset TabKam         ; konverzn� tabulka
         xlat                               ; konverze znaku podle tabulky

Konvert9:pop       ds
         pop       bx
         ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        p쯥vodn� tabulka
; -----------------------------------------------------------------------------

; ------ konverzn� tabulka z k줰u Kamenick쁟h

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

Init3:   mov       ah,1                     ; 1=Kamenick쁟h
         cmp       al,"K"
         je        Init32                   ; Kamenick쁟h
         inc       ah                       ; 2=Latin 2
         cmp       al,"L"
         je        Init32                   ; Latin 2
         inc       ah
         cmp       al,"I"
         jne       ChybZad                  ; nen� ani KOI 8
Init32:  mov       byte ptr ds:[InKod],ah   ; vstupn� k줰
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

; ------ test stavu instalace programu CONS212 (mus� b쁳 ES=CS)

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
; ------ stanoven� implicitn죅h k줰�

Init5:   cmp       byte ptr es:[InKod],0ffh
         jne       Init53
         mov       byte ptr es:[InKod],1    ; implicitn� vstupn� k줰 Kamenick쁟h

; ------ p쯥nesen� fontu

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
         rep       movsb                    ; p쯥nesen� fontu

; ------ pæpadn� odinstalov쟮� programu

         cmp       byte ptr ds:[DInsPar],0  ; po멲duje se odinstalov쟮� ?
         je        Init6                    ; nepo멲duje se odinstalov쟮�
         jmp       OdInst                   ; odinstalov쟮� programu

; ------ nen�-li program nainstalov쟮, jeho nainstalov쟮�

Init6:   call      Hlaseni                  ; zobrazen� hl젴en� o k줰ov쟮�
         mov       ax,cs                    ; tento program
         cmp       ax,ds:[SegRez]
         jne       Init7                    ; v쮍 je OK
         jmp       Instal                   ; prvn� instalace programu

Init7:   int       20h


; -----------------------------------------------------------------------------
;        zobrazen� hl젴en� o tisknut굆 k줰u
; -----------------------------------------------------------------------------

Hlaseni  PROC      NEAR

; ------ zobrazen� prvn� 뇿sti hl젴en�

         mov       dx,offset KonvTxt
         mov       ah,9
         int       21h

; ------ zobrazen� vstupn죋o k줰u

         mov       al,es:[InKod]
         mov       dx,offset KonvTxt2       ; Kamenick쁟h
         dec       al
         jz        Hlaseni7
         mov       dx,offset KonvTxt3       ; Latin 2
         dec       al
         jz        Hlaseni7
         mov       dx,offset KonvTxt4       ; KOI 8
Hlaseni7:mov       ah,9
         int       21h

; ------ zobrazen� zbytku textu hl젴en�

         mov       dx,offset KonvTxt8
         mov       ah,9
         int       21h
         ret

Hlaseni  ENDP

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

; ------ konverzn� tabulka z k줰u Latin 2

TabLat   label     byte
         db        'C',200,215,'a',209,202,'c','c','l',214,253,221,'i','Z',241,'C'
         db        247,235,203,208,205,236,204,'S','s',237,232,244,212,'L','x',195
         db        193,201,207,213,'A','a',250,218,'E','e','-','z',227,'s','<','>'
         db        ' ',' ',' ','|','|',225,'A',229,'S','|','|','+','+','Z','z','+'
         db        '+','-','-','|','-','+',226,194,'+','+','-','-','|','-','+','x'
         db        'd','D',228,246,196,238,233,'I',197,'+','+',' ',' ','T',234,' '
         db        239,223,240,'N','n',206,243,211,230,245,198,248,217,249,'t',162
         db        '-',173,174,175,176,220,':',171,170,168,167,200,242,210,167,' '

; ------ konverzn� tabulka z k줰u KOI 8

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
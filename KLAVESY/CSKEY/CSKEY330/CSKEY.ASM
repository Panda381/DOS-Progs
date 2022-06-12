
KLIC1    EQU       4d6ah                    ; kl°á 1 (AX)
KLIC2    EQU       8e4ah                    ; kl°á 2 (BX)
KLIC3    EQU       0a6e3h                   ; kl°á 3 (CX)
KLIC4    EQU       342eh                    ; kl°á 4 (BX vòstup)

KORIG    EQU       5ch-103h                 ; korekce adres

; *****************************************************************************
;
;                      Ovladaá áeskÇ kl†vesnice
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; start programu

ZacRez   LABEL     NEAR                     ; zaá†t rezidentn° á†sti programu

; -----------------------------------------------------------------------------
;                          Rezidentn° data
; -----------------------------------------------------------------------------

Old09    dd        0                        ; pñvodn° obsluha INT 09h
Old16    dd        0                        ; pñvodn° obsluha INT 16h

Klaves   db        1                        ; á°slo kl†vesnice 1 aë 7

Prepin   db        11h                      ; p©ep°naáe
                                            ; bit 0-1: 0=Kamenickòch
                                            ;          1=Latin 2
                                            ;          2=KOI 8
                                            ;          3=ISO 8859/2 (ISO L2)
                                            ; bit 2:   1=sloven®tina
                                            ; bit 3:   1=z†màna Y a Z kromà p°s.
                                            ; bit 4:   1=z†màna Y a Z p°sa©sk†
                                            ; bit 5:   1=v numer. poli carka
                                            ;          0=v numer. poli tecka
                                            ; bit 6: (1=bit 2 á°sla kl†vesnice)
                                            ;          4=WINDOWS (ISO 8859)
                                            ; bit 7:   1=byl prefix

PrefKey1 dw        "``"                     ; prefixy pro norm†ln° a prog. kl†v.
PrefKey2 dw        "+="                     ; prefixy pro p°sa©skou kl†vesnici

AdrTab00 dw        Tab00+KORIG              ; adresa tabulky fontñ

ZnakZ    dw        3920h                    ; poslednà vloëenò znak

; -----------------------------------------------------------------------------
;               Obsluha p©eru®en° od kl†vesnice INT 09H
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registrñ 1

         push      bx
         push      ds

; ------ £schova ukl†dac° adresy do bufferu kl†vesnice

         mov       bx,40h                   ; segment dat BIOS
         mov       ds,bx                    ; DS <- segment dat BIOS 0040h
         mov       bx,word ptr ds:[1ch]     ; ukl†dac° adresa do bufferu

; ------ vol†n° pñvodn° obsluhy kl†vesnice

         pushf                              ; simulace vol†n° INT
         call      dword ptr cs:[old09+KORIG]; pñvodn° obsluha kl†vesnice

; ------ test, zda byl p©ijat znak

         cmp       bx,word ptr ds:[1ch]     ; byl p©ijat znak ?
         jne       Int091                   ; byl p©ijat znak

; ------ nebyl p©ijat znak - n†vrat z obsluhy

         pop       ds
         pop       bx
         iret

; ------ £schova registrñ 2

Int091:  push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         push      cs
         pop       es                       ; ES <- segment programu
         cld

; ====== obsluha kreslen° r†meákñ

; ------ test, zda jsou p©esmykaáe <Alt>-<Ctrl>

         mov       al,ds:[17h]              ; status p©esmykaáñ
         and       al,0ch                   ; p©°znaky <Ctrl> a <Alt>
         cmp       al,0ch                   ; je <Alt>-<Ctrl> ?
         jne       Int093                   ; je jin† kombinace p©esmykaáñ

; ------ test, zda je kurzorov† kl†vesa

         mov       ax,ds:[bx]               ; p©ijatò k¢d kl†vesy
         cmp       ah,98h                   ; je kurzorov† kl†vesa nahoru ?
         je        Int0921                  ; je kurzorov† kl†vesa nahoru
         cmp       ah,0a0h                  ; je kurzorov† kl†vesa dolñ ?
         je        Int0921                  ; je kurzorov† kl†vesa dolñ
         cmp       ah,9bh                   ; je kurzorov† kl†vesa vlevo ?
         je        Int0921                  ; je kurzorov† kl†vesa vlevo
         cmp       ah,9dh                   ; je kurzorov† kl†vesa vpravo ?
         jne       Int093                   ; nen° kurzorov† kl†vesa vpravo

; ------ pro kurzor vpravo pouze n†hrada pñvodn°m znakem

         mov       ax,cs:[ZnakZ+KORIG]      ; poslednà zadanò znak ASCII
         mov       ds:[bx],ax               ; n†hrada poslednà zadanòm znakem
         jmp       short Int0923            ; ukonáen° obsluhy

; ------ vloëen° znaku, krok zpàt a pñvodn° kurzorov† kl†vesa

Int0921: mov       ax,cs:[ZnakZ+KORIG]      ; poslednà zadanò znak ASCII
         cmp       ah,53h                   ; je klavesa <Delete> ?
         xchg      ax,ds:[bx]               ; n†hrada poslednà zadanòm znakem
         je        Int0922                  ; je klavesa <Delete>
         push      ax
         mov       ax,4b00h                 ; k¢d kurzoru vlevo
         call      InsKey                   ; vloëen° k¢du kurzoru vlevo
         pop       ax
Int0922: sub       ah,50h                   ; korekce na norm†ln° k¢d kl†vesy
         mov       al,0
         call      InsKey                   ; vloëen° pñvodn°ho k¢du kl†vesy
Int0923: jmp       Int098                   ; konec obsluhy

; ====== obsluha zru®en° prefixu kl†vesou Delete nebo BS

Int093:  test      byte ptr cs:[Prepin+KORIG],80h ; byl prefix ?
         jz        Int094                   ; nebyl prefix
         cmp       byte ptr [bx+1],0eh      ; je kl†vesa <BS> ?
         je        Int0934                  ; je kl†vesa <BS>
         cmp       byte ptr [bx+1],53h      ; je kl†vesa <Delete> ?
         jne       Int094                   ; nebyla kl†vesa <Delete>
Int0934: and       byte ptr cs:[Prepin+KORIG],not 80h ; zru®en° p©°znaku prefixu
Int0935: mov       ds:[1ch],bx              ; zru®en° kl†vesy
         jmp       short Int0923            ; konec obsluhy

; ====== obsluha kl†vesy prefixu

; ------ test, zda je prefixov† kl†vesa

Int094:  cmp       byte ptr ds:[bx+1],36h   ; maxim†ln° povolenò znak
         ja        Int095                   ; nen° povolen† kl†vesa
         mov       dx,cs:[PrefKey1+KORIG]   ; prefixy norm†ln° kl†vesnice
         cmp       byte ptr cs:[Klaves+KORIG],3 ; je kl†vesnice 3 ?
         jne       Int0942                  ; nen° kl†vesnice 3
         mov       dx,cs:[PrefKey2+KORIG]   ; prefixy p°sa©skÇ kl†vesnice
Int0942: mov       si,offset Tab003+KORIG   ; korekán° tabulka pro á†rku
         cmp       byte ptr ds:[bx],dl      ; je prefix pro á†rku ?
         je        Int0944                  ; je prefix pro á†rku
         cmp       byte ptr ds:[bx],dh      ; je prefix pro h†áek ?
         jne       Int095                   ; nen° ani prefix pro h†áek
         mov       si,offset Tab004+KORIG   ; korekán° tabulka pro h†áek

; ------ p©°prava pro optim†ln° kl†vesnici (prefixy jsou stejnÇ)

Int0944: cmp       dh,dl                    ; jsou stejnÇ prefixy ?
         jne       Int0945                  ; nen° optim†ln° kl†vesnice
         mov       si,offset Tab001+KORIG   ; áesk† optim†ln°
         test      byte ptr cs:[Prepin+KORIG],4 ; je sloven®tina ?
         jz        Int0945                  ; je áe®tina
         mov       si,offset Tab002+KORIG   ; slovensk† optim†ln°

; ------ p©enos korekc° do tabulky

Int0945: mov       cx,offset(Tab002-Tab001) ; poáet poloëek v tabulce
         push      ds
         push      cs
         pop       ds                       ; DS <- segment programu
         mov       di,offset Tab0+1+KORIG   ; ukl†dac° adresa korekc°
Int0946: movsb
         inc       di
         loop      Int0946
         pop       ds

; ------ zmàna p©°znaku prefixu a p©°p. zru®en° prefixu z bufferu

         xor       byte ptr cs:[Prepin+KORIG],80h ; zmàna p©°znaku prefixu
         test      byte ptr cs:[Prepin+KORIG],80h ; byl prefix nastaven ?
         jnz       Int0935                  ; nebyl nastaven, zru®en° kl†vesy
                                            ; jinak je z nàj platn† kl†vesa

; ====== obsluha p©ep°naáe funkc° kl†vesnice

; ------ test, zda byl zad†n prefix

Int095:  test      byte ptr cs:[Prepin+KORIG],80h ; byl zad†n prefix ?
         jz        Int096                   ; nebyl zad†n prefix

; ------ test, zda je zadan† á°slice po prefixu

         mov       al,[bx]                  ; p©ijatò k¢d kl†vesy
         sub       al,"1"                   ; korekce na á°slo 0..
         cmp       al,7                     ; je platnÇ á°slo ?
         jae       int096                   ; nen° platnò znak pro p©ep°naá

; ------ nastaven° novÇ kl†vesnice

         inc       ax
         mov       cs:[Klaves+KORIG],al     ; novÇ á°slo kl†vesnice
         jmp       short Int0934            ; zru®en° kl†vesy a prefixu

; ====== p©ek¢dov†n° k¢du kl†vesy

; ------ test, zda m† bòt z†màna Y a Z

Int096:  cmp       byte ptr cs:[Klaves+KORIG],3 ; je p°sa©sk† kl†vesnice ?
         je        Int0962                  ; je p°sa©sk† kl†vesnice
         test      byte ptr cs:[Prepin+KORIG],8 ; z†màna u bàënÇ kl†vesnice ?
         jz        Int0965                  ; nen° z†màna Y a Z
         jmp       short Int0963            ; z†màna Y a Z
Int0962: test      byte ptr cs:[Prepin+KORIG],10h ; z†màna u p°sa©skÇ kl†vesnice ?
         jz        Int0965                  ; nen° z†màna Y a Z

; ------ z†màna Y a Z

Int0963: mov       ax,ds:[bx]               ; kl†vesa
         cmp       ah,2ch                   ; je kl†vesa "Z" ?
         je        Int0964                  ; je kl†vesa "Z" - z†màna
         cmp       ah,15h                   ; je kl†vesa "Y" ?
         jne       Int0965                  ; nen° kl†vesa "Y"
Int0964: xor       ah,2Ch XOR 15h           ; zmàna SCAN k¢du Y <-> Z
         cmp       al,0                     ; je kl†vesa Alt-Y, Alt-Z ?
         je        Int09642                 ; nië®° bajt se nedek¢duje
Int09641:xor       al,1Ah XOR 19h           ; zmàna k¢du znaku Y <-> Z
Int09642:mov       ds:[bx],ax               ; novò k¢d kl†vesy

; ------ á†rka v numerickÇm poli

Int0965: mov       ah,0
         mov       al,cs:[Klaves+KORIG]     ; á°slo kl†vesnice

         cmp       al,3                     ; je graficka klavesnice ?
         ja        Int09650                 ; je graficka klavesnice
         test      byte ptr cs:[Prepin+KORIG],20h ; je carka ?
         jz        Int09650                 ; neni carka
         cmp       word ptr ds:[bx],532eh   ; je tecka ?
         jne       Int09650                 ; neni tecka
         mov       word ptr ds:[bx],332ch   ; zmena na carku

; ------ p©°prava á°sla kl†vesnice

Int09650:test      byte ptr cs:[Prepin+KORIG],80h ; byl zad†n prefix ?
         jz        Int09651                 ; nebyl zad†n prefix

; ------ p°sa©sk† kl†vesnice - po prefixu se nep©ek¢dov†v† znak "\"

         and       byte ptr cs:[Prepin+KORIG],not 80h ; zru®en° p©°znaku prefixu
         cmp       al,3                     ; je p°sa©sk† kl†vesnice ?
         mov       al,0                     ; á°slo kl†vesnice 0 = prefixov†
         jne       Int09651                 ; nen° p°sa©sk† kl†vesnice
         cmp       byte ptr ds:[bx],"\"     ; je znak "\" ?
         je        Int097                   ; znak "\" se nep©ek¢dov†v†

; ------ stanoven° tabulky adres

Int09651:mov       si,offset AdrTab1+KORIG  ; tab. adres s vypnutòm <Caps Lock>
         test      byte ptr ds:[17h],40h    ; je zapnut <Caps Lock> ?
         jz        Int09652                 ; <Caps Lock> je vypnut
         mov       si,offset AdrTab2+KORIG  ; tab. adres se zapnutòm <Caps Lock>

; ------ adresa p©°slu®nÇ k¢dovac° kl†vesnice

Int09652:shl       al,1                     ; á°slo kl†vesnice * 2
         add       si,ax                    ; poloëka adresy tabulky
         mov       di,cs:[si]               ; adresa k¢dovac° tabulky
         or        di,di                    ; je kl†vesnice definovan† ?
         jz        int097                   ; kl†vesnice nen° definovan†

; ------ p©°prava k prohl°ëen° jednÇ á†sti tabulky

         mov       ax,ds:[bx]               ; hledanò k¢d kl†vesy
Int09653:mov       ch,0                     ; CH <- 0
         mov       cl,cs:[di]               ; poáet k¢dñ kl†ves v tabulce
         mov       dl,cl                    ; £schova p©°znaku 2-bajtovÇho k¢du
         and       cl,7fh                   ; zru®en° p©°znaku 2-bajtovòch k¢dñ
         jcxz      Int097                   ; konec tabulky
         inc       di                       ; zaá†tek tabulky

; ------ vyhled†n° kl†vesy - slovo

         test      dl,80h                   ; je 2-bajtovò k¢d ?
         jz        Int09655                 ; je 1-bajtovò k¢d
Int09654:scasw                              ; porovn†n° kl†vesy (slovo)
         je        Int09656                 ; k¢d kl†vesy nalezen
         inc       di                       ; p©eskoáen° novÇho k¢du znaku
         loop      Int09654                 ; test dal®°ho k¢du kl†vesy
         jmp       short int09653           ; dal®° á†st tabulky

; ------ porovn†n° kl†vesy - bajt

Int09655:scasb                              ; porovn†n° kl†vesy (bajt)
         je        Int09656                 ; k¢d kl†vesy nalezen
         inc       di                       ; p©eskoáen° novÇho k¢du znaku
         loop      Int09655                 ; test dal®°ho k¢du kl†vesy
         jmp       short int09653           ; dal®° á†st tabulky

; ------ kl†vesa nalezena - n†hrada novòm znakem

Int09656:mov       ah,0                     ; AH <- 0
         mov       al,cs:[di]               ; novò k¢d znaku
         mov       [bx],ax                  ; n†hrada novòm znakem

; ------ £schova naposledny vygenerovanÇho platnÇho znaku

Int097:  mov       ax,[bx]                  ; znak v bufferu
         or        ax,ax                    ; kl†vesa Ctrl-Break ?
         jz        Int098                   ; Ctrl-Break se neuchov†
         cmp       ah,0                     ; novà vygenerovanò znak ?
         je        Int0972                  ; £schova vygenerovanÇho znaku
         cmp       ah,53h                   ; kl†vesa Delete
         je        Int0972                  ; £schova kl†vesy Delete
         cmp       al,0e0h                  ; zvl†®tn° ©°dic° kl†vesa ?
         je        Int098                   ; kl†vesa se neuchov†
         cmp       al,0f0h                  ; zvl†®tn° ©°dic° kl†vesa
         je        Int098                   ; kl†vesa se neuchov†
         cmp       al,20h                   ; je ©°dic° kl†vesa ?
         jb        Int098                   ; kl†vesa se neuchov†
         cmp       al,7fh                   ; znak Ctrl-BS ?
         je        Int098                   ; znak Ctrl-BS se neuchov†
Int0972: mov       cs:[ZnakZ+KORIG],ax      ; £schova posledn°ho znaku

; ------ n†vrat registrñ 2

Int098:  pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax

; ------ n†vrat registrñ 1

         pop       ds
         pop       bx
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;     vloëen° znaku AX do bufferu kl†vesnice (DS:BX=posledn° znak) (niá° AX !)
; -----------------------------------------------------------------------------

InsKey   PROC      NEAR

; ------ £schova registrñ

         push      bx

; ------ zvò®en° ukazatele v bufferu

         mov       bl,ds:[1ch]              ; n†sleduj°c° adresa
         inc       bx
         inc       bx                       ; zvò®en° ukazatele v bufferu
         cmp       bl,3eh                   ; p©eteáen° konce bufferu ?
         jb        InsKey2                  ; nen° p©eteáen° konce bufferu
         mov       bl,1eh                   ; posun na zaá†tek bufferu

; ------ test, zda by se buffer jië zaplnil

InsKey2: cmp       bl,ds:[1ah]              ; bylo by p©eteáen° bufferu ?
         jne       InsKey3                  ; nebylo by p©eteáen° bufferu
         pop       bx                       ; n†vrat BX - nelze uloëit
         ret

; ------ uloëen° znaku do bufferu

InsKey3: xchg      bl,ds:[1ch]              ; nov† ukl†dac° adresa do bufferu
         mov       ds:[bx],ax               ; uloëen° znaku do bufferu
         pop       ax                       ; zru®en° BX ze z†sobn°ku
         ret

InsKey   ENDP

; -----------------------------------------------------------------------------
;        test instalace programu
; -----------------------------------------------------------------------------

Int16    PROC      FAR

; ------ test instalace programu

         pushf
         cmp       ax,KLIC1
         jne       Int162
         cmp       bx,KLIC2
         jne       Int162
         cmp       cx,KLIC3
         jne       Int162
         popf
         mov       bx,KLIC4                 ; vòstupn° kl°á
         push      cs
         pop       es                       ; ES <- segment rezidentn° á†sti
         sti
         ret       2

Int162:  popf
         jmp       dword ptr cs:[Old16+KORIG]; pokraáov†n° v obsluze INT 16h

Int16    ENDP

; *****************************************************************************
;
;                             Tabulky znakñ
;
; *****************************************************************************
                                          ;* <Caps Lock> je vypnut
AdrTab1  dw        Tab0+KORIG               ; 0:tabulka po prefixu
         dw        0                        ; 1:pñvodn° kl†vesnice IBM
         dw        Tab21+KORIG              ; 2:program†torsk† kl†vesnice mal†
         dw        Tab31+KORIG              ; 3:p°sa©sk† kl†vesnice mal†
         dw        Tab4+KORIG               ; 4:grafick† kl†vesnice 1
         dw        Tab5+KORIG               ; 5:grafick† kl†vesnice 2
         dw        Tab6+KORIG               ; 6:grafick† kl†vesnice 3
         dw        Tab7+KORIG               ; 7:grafick† kl†vesnice 4

                                          ;* <Caps Lock> je zapnut
AdrTab2  dw        Tab0+KORIG               ; 0:tabulka po prefixu
         dw        0                        ; 1:pñvodn° kl†vesnice IBM
         dw        Tab22+KORIG              ; 2:program†torsk† kl†vesnice velk†
         dw        Tab32+KORIG              ; 3:p°sa©sk† kl†vesnice velk†
         dw        Tab4+KORIG               ; 4:grafick† kl†vesnice 1
         dw        Tab5+KORIG               ; 5:grafick† kl†vesnice 2
         dw        Tab6+KORIG               ; 6:grafick† kl†vesnice 3
         dw        Tab7+KORIG               ; 7:grafick† kl†vesnice 4

Tab001   db        'bBqQwWeErRtTyYuUiIoOpPaAsSdDfFhHjJkKlLzZcCnNmM,.\' ; optim.á
Tab002   db        'bBqQwWeEfFtTyYuUiIoOpPaAsSdDrRhHjJkKlLzZcCnNmM,.\' ; optim.s
Tab003   db        'bBqQwWeEfFtTyYuUiIoOpPaAsSdDrRhHjJkKmMzZcCnNlL,.\' ; á†rka
Tab004   db        'bBaAeEwWrRtTyYjJiIkKpPqQsSdDfFhHuUoOlLzZcCnNmM,.\' ; h†áek

;˛
Tab00    label     byte                   ;* adresa zaá†tku tabulek

Tab0     label     byte                   ;* tabulka po prefixu
         db        49
         db        "b",225                  ; "·"
         db        "B",225                  ; "·"
         db        "q",132                  ; "Ñ"
         db        "Q",142                  ; "é"
         db        "w",216                  ; "à"
         db        "W",183                  ; "â"
         db        "e",130                  ; "Ç"
         db        "E",144                  ; "ê"
         db        "r",253                  ; "©"
         db        "R",252                  ; "û"
         db        "t",156                  ; "ü"
         db        "T",155                  ; "Ü"
         db        "y",236                  ; "ò"
         db        "Y",237                  ; "ù"
         db        "u",163                  ; "£"
         db        "U",233                  ; "ó"
         db        "i",161                  ; "°"
         db        "I",214                  ; "ã"
         db        "o",162                  ; "¢"
         db        "O",224                  ; "ï"
         db        "p",148                  ; "î"
         db        "P",153                  ; "ô"
         db        "a",160                  ; "†"
         db        "A",181                  ; "è"
         db        "s",231                  ; "®"
         db        "S",230                  ; "õ"
         db        "d",212                  ; "É"
         db        "D",210                  ; "Ö"
         db        "f",234                  ; "™"
         db        "F",232                  ; "´"
         db        "h",129                  ; "Å"
         db        "H",154                  ; "ö"
         db        "j",133                  ; "ñ"
         db        "J",222                  ; "¶"
         db        "k",147                  ; "ì"
         db        "K",226                  ; "ß"
         db        "l",150                  ; "å"
         db        "L",149                  ; "ú"
         db        "z",167                  ; "ë"
         db        "Z",166                  ; "í"
         db        "c",159                  ; "á"
         db        "C",172                  ; "Ä"
         db        "n",229                  ; "§"
         db        "N",213                  ; "•"
         db        "m",146                  ; "ç"
         db        "M",145                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",245                  ; "≠"
         db        0

Tab21    label     byte                   ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,133                ; "ñ"
         db        32h,3,216                ; "à"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,253                ; "©"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

Tab22    label     byte                   ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,222                ; "¶"
         db        32h,3,183                ; "â"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,252                ; "û"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

Tab31    label     byte                   ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,216                ; "à"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,253                ; "©"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",163                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",133                  ; "ñ"
         db        ":",34                   ; "'"
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",229                  ; "§"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

Tab32    label     byte                   ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,183                ; "â"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,252                ; "û"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",233                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",222                  ; "¶"
         db        ":",34
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",213                  ; "•"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

Tab4     label     byte                   ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

Tab5     label     byte                   ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

Tab6     label     byte                   ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

Tab7     label     byte                   ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

Tab00x   label     byte                     ; adresa konce tabulek

; zde je konec rezidentn° á†sti programu

; *****************************************************************************
;
;                        Instalace programu
;
; *****************************************************************************
;˛
; ------ zobrazen° £vodn°ho textu

Init:    mov       dx,offset UvTxt          ; £vodn° text
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ £schova p©°kazovÇho ©†dku

         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       ch,0
         mov       cl,ds:[si-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       di,offset Command        ; bufferu k £schovà p©°kaz. ©†dku
         cld
         rep       movsb                    ; £schova p©°kazovÇho ©†dku
         mov       al,0                     ; ukonáovac° 0
         stosb                              ; oznaáen° konce ©†dku

; ------ posun rezidentn° á†sti programu dolñ

         mov       si,offset ZacRez         ; zaá†tek rezidentn° á†sti programu
         mov       di,offset ZacRez+KORIG   ; nov† ukl†dac° adresa programu
         mov       cx,offset(Init-ZacRez)   ; dÇlka p©esouvanÇ á†sti
         cld
         rep       movsb                    ; p©esun programu dolñ

; ------ test, zda je program rezidentn° (ES <- segment rezidentn° á†sti)

         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         int       16h                      ; test instalace programu
         cmp       bx,KLIC4
         je        Init1
         push      cs
         pop       es                       ; ES <= nen° rezidnetn°
         or        byte ptr ds:[ParamIni],1 ; p©°znak prvn° instalace

; ------ dek¢dov†n° p©°kazovÇho ©†dku

Init1:   mov       si,offset Command        ; buffer s p©°kazovòm ©†dkem
         cld
Init2:   call      ParSpc                   ; nalezen° zaá†tku parametru
         jc        Init3                    ; konec textu
         call      ParChr                   ; naáten° znaku
         cmp       al,"/"                   ; je to znak "/" ?
         je        Init2                    ; znak "/" se ignoruje
         call      Param                    ; dek¢dov†n° jednoho parametru
         jnc       Init2                    ; parametr OK - dal®° parametr

; ------ chyba

         mov       dx,offset HelpTxt        ; text n†povàdy
Chyba:   mov       ah,9
         int       21h                      ; zobrazen° n†povàdy
Chyba0:  int       20h                      ; konec programu

; ------ test, zda m† bòt odinstalov†n° programu

Init3:   test      byte ptr ds:[ParamIni],2 ; je poëadov†no odinstalov†n° ?
         jz        Init5                    ; nen° poëadov†no odinstalov†n°

; ------ test, zda je program nainstalov†n

         mov       dx,offset NeniTxt        ; text - nebyl dosud nainstalov†n
         test      byte ptr ds:[ParamIni],1 ; je program nainstalov†n ?
         jnz       Chyba                    ; chyba - nebyl dosud nainstalov†n

; ------ test, zda lze program odinstalovat

         call      TestDIns                 ; test, zda lze odinstalovat
         mov       dx,offset NelzeTxt       ; text - nelze odinstalovat
         jc        Chyba                    ; chyba - nelze odinstalovat

; ------ odinstalov†n° programu

         call      DeInst                   ; odinstalov†n° programu
         mov       dx,offset DInsTxt        ; text - byl odinstalov†n
         jmp       short Chyba              ; hl†®en° OK

; ------ test, zda je program jië nainstalov†n

Init5:   test      byte ptr ds:[ParamIni],1 ; je jië nainstalov†n ?
         jnz       Init6                    ; program nen° nainstalov†n
         call      DispSet                  ; zobrazen° stavu programu
         jmp       short Chyba0             ; je jië nainstalov†n - konec

; ------ zobrazen° hl†®en° o instalaci

Init6:   mov       dx,offset InstTxt        ; text - byl nainstalov†n
         mov       ah,9
         int       21h                      ; zobrazen° hl†®en° o instalaci

; ------ £schova vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut° adresy INT 09h
         mov       word ptr ds:[Old09+KORIG],bx
         mov       word ptr ds:[Old09+2+KORIG],es

; ------ £schova vektoru INT 16h

         mov       ax,3516h
         int       21h                      ; poskytnut° adresy INT 16h
         mov       word ptr ds:[Old16+KORIG],bx
         mov       word ptr ds:[Old16+2+KORIG],es

; ------ instalace obsluhy INT 09h

         mov       ax,2509h
         mov       dx,offset INT09+KORIG
         int       21h                      ; instalace INT 09h

; ------ instalace obsluhy INT 16h

         mov       ax,2516h
         mov       dx,offset INT16+KORIG
         int       21h                      ; instalace INT 16h

; ------ uvolnàn° segmentu prost©ed°

         mov       es,ds:[2ch]              ; segment prost©ed°
         mov       ah,49h
         int       21h                      ; uvolnàn° segmentu prost©ed°

; ------ instalace programu

         mov       dx,offset Init+KORIG
         int       27h                      ; instalace do pamàti

; -----------------------------------------------------------------------------
;        test, zda lze program odinstalovat (ES=rez. segment)
; -----------------------------------------------------------------------------

TestDIns PROC      NEAR

; ------ £schova registrñ

         push      es
         mov       dx,es                    ; £schova ES

; ------ test adresy INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut° adresy INT 09h
         mov       ax,es
         cmp       ax,dx                    ; souhlas° segment ?
         jne       TestDIn8                 ; chyba - nesouhlas°

; ------ test adresy INT 16h

         mov       ax,3516h
         int       21h                      ; poskytnut° adresy INT 16h
         mov       ax,es
         cmp       ax,dx                    ; souhlas° segment
         je        TestDIn9                 ; adresa souhlas° - v®e je OK

; ------ n†vrat registrñ

TestDIn8:stc                                ; p©°znak chyby - nelze odinstalovat
TestDIn9:pop       es
         ret

TestDIns ENDP

; -----------------------------------------------------------------------------
;        odinstalov†n° programu z pamàti (segment ES)
; -----------------------------------------------------------------------------

DeInst   PROC      NEAR

; ------ £schova registrñ

         push      ds

; ------ n†vrat adresy INT 09h

         lds       dx,es:[Old09+KORIG]      ; pñvodn° adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n†vrat adresy INT 09h

; ------ n†vrat adresy INT 16h

         lds       dx,es:[Old16+KORIG]      ; pñvodn° adresa INT 16h
         mov       ax,2516h
         int       21h                      ; n†vrat adresy INT 16h

; ------ zru®en° alokaán°ho bloku pamàti

         mov       ah,49h
         int       21h                      ; uvolnàn° alokaán°ho bloku pamàti

; ------ n†vrat registrñ

         pop       ds
         ret

DeInst   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° jednoho parametru (prvn° znak AL)
; -----------------------------------------------------------------------------

Param    PROC      NEAR

; ------ konverze znaku na velkÇ p°smeno

         cmp       al,"a"
         jb        Param1
         cmp       al,"z"
         ja        Param1
         sub       al,32                    ; konverze na velkÇ p°smeno

; ------ parametr "1" aë "7" - nastaven° typu kl†vesnice

Param1:  cmp       al,"1"
         jb        Param2                   ; nen° typ kl†vesnice
         cmp       al,"7"
         ja        Param2                   ; nen° typ kl†vesnice
         sub       al,"0"
         mov       es:[Klaves+KORIG],al     ; novÇ á°slo kl†vesnice
         ret

; ------ parametr "P" - nastaven° prefixovòch kl†ves

Param2:  cmp       al,"P"                   ; definice prefixovòch kl†ves ?
         jne       Param4                   ; nen° parametr "P"
         call      ParChr                   ; naáten° dal®°ho znaku
         jbe       Param3                   ; nen° dal®° platnò znak
         mov       byte ptr es:[PrefKey1+KORIG],al; prvn° prefix
         call      ParChr                   ; naáten° dal®°ho znaku
         jbe       Param3                   ; nen° dal®° platnò znak
         mov       byte ptr es:[PrefKey1+1+KORIG],al ; druhò prefix
         call      ParChr                   ; naáten° dal®°ho znaku
         jbe       Param3                   ; nen° dal®° platnò znak
         mov       byte ptr es:[PrefKey2+KORIG],al; t©et° prefix
         call      ParChr                   ; naáten° dal®°ho znaku
         jbe       Param3                   ; nen° dal®° platnò znak
         mov       byte ptr es:[PrefKey2+1+KORIG],al ; átvrtò prefix
Param3:  clc                                ; p©°znak operace OK
         ret

; ------ parametr "K" - nastaven° k¢du Kamenickòch

Param4:  mov       ah,0                     ; á°slo k¢du Kamenickòch
         cmp       al,"K"                   ; je parametr "K" ?
         je        Param5                   ; je parametr "K"

; ------ parametr "L" - nastaven° k¢du Latin 2

         mov       ah,1                     ; á°slo k¢du Latin 2
         cmp       al,"L"                   ; je parametr "L" ?
         je        Param5                   ; je parametr "L"

; ------ parametr "W" - nastaven° k¢du WINDOWS (ISO 8859)

         mov       ah,40h+0                 ; á°slo k¢du WINDOWS
         cmp       al,"W"                   ; je parametr "W" ?
         je        Param5                   ; je parametr "W"

; ------ parametr "O" - nastaven° k¢du ISO 8859/2 - ISO LATIN 2

         mov       ah,3                     ; á°slo k¢du ISO 8859/2
         cmp       al,"O"                   ; je parametr "O" ?
         je        Param5                   ; je parametr "O"

; ------ parametr "I" - nastaven° k¢du KOI 8

         mov       ah,2                     ; á°slo k¢du KOI 8
         cmp       al,"X"
         je        Param5                   ; starò parametr "X"
         cmp       al,"I"                   ; je parametr "I" ?
         jne       Param7                   ; nen° parametr "I"
Param5:  and       byte ptr es:[Prepin+KORIG],not 3+40h ; zru®en° starÇho k¢du
         or        es:[Prepin+KORIG],ah     ; nastaven° novÇho k¢du
Param6:  call      KonvK                    ; p©enos fontñ
         clc                                ; p©°znak operace OK
         ret

; ------ parametr "C" - áesk† kl†vesnice

Param7:  cmp       al,"C"                   ; je parametr "C" ?
         jne       Param8                   ; nen° parametr "C"
         and       byte ptr es:[Prepin+KORIG],not 4 ; p©°znak áeskÇ kl†vesnice
         jmp       short Param6             ; konverze fontñ

; ------ parametr "S" - slovensk† kl†vesnice

Param8:  cmp       al,"S"                   ; je parametr "S" ?
         jne       Param9                   ; nen° parametr "S"
         or        byte ptr es:[Prepin+KORIG],4 ; p©°znak slovenskÇ kl†vesnice
         jmp       short Param6             ; konverze fontñ

; ------ v numerickem poli carka

Param9:  cmp       al,"T"                   ; je tecka ?
         jne       Param91
         and       byte ptr es:[Prepin+KORIG],not 20h ; je tecka
         ret

Param91: cmp       al,"D"                   ; je carka ?
         jne       Param92
         or        byte ptr es:[Prepin+KORIG],20h ; je carka
         ret

; ------ parametr "Z" - z†màna kl†ves Y a Z

Param92: cmp       al,"Z"                   ; je parametr "Z" ?
         jne       ParamA                   ; nen° parametr "Z"
         call      ParChr                   ; naáten° dal®°ho znaku
         jc        ParamX                   ; nen° dal®° znak - chyba
         sub       al,"0"                   ; á°slice
         cmp       al,3                     ; je platnò znak ?
         ja        ParamX                   ; chyba zad†n°
         shl       al,1
         shl       al,1
         shl       al,1                     ; rotace na pozici
         and       byte ptr es:[Prepin+KORIG],not 18h ; zru®en° staròch p©°znakñ
         or        es:[Prepin+KORIG],al     ; novÇ nastaven° p©°znakñ
         ret

; ------ parametr "!" - odinstalov†n° z pamàti

ParamA:  cmp       al,"!"                   ; je parametr "!" ?
         jne       ParamX                   ; nen° parametr "!"
         or        byte ptr ds:[ParamIni],2 ; poëadavek odinstalov†n°
         ret

; ------ chyba zad†n° parametrñ

ParamX:  stc                                ; p©°znak chyby
         ret

Param    ENDP

; -----------------------------------------------------------------------------
;        konverze fontñ kl†vesnice (ES=segment rezidentn°ho programu)
; -----------------------------------------------------------------------------

KonvK    PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di

; ------ p©enos fontu

         mov       si,word ptr es:[Prepin+KORIG] ; k¢d kl†vesnice
         and       si,7                     ; k¢d kl†vesnice
         test      byte ptr es:[Prepin+KORIG],40h ; je sada 2 ?
         jz        KonvK2                   ; je sada 1
         add       si,8                     ; korekce á°sla kl†vesnice
KonvK2:  shl       si,1                     ; k¢d kl†vesnice * 2
         mov       si,ds:[si+AdrKod]        ; adresa k¢du
         mov       di,es:[AdrTab00+KORIG]   ; adresa k uloëen° fontu
         mov       cx,offset(Tab00x-Tab00)  ; dÇlka tabulky
         cld
         rep       movsb                    ; p©enos tabulky

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         ret

KonvK    ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; naáten° znaku z p©°kazovÇho ©†dku
         jc        ParSpc2                  ; konec p©°kazovÇho ©†dku
         je        ParSpc                   ; mezera - vypu®tàn°
         dec       si                       ; n†vrat platnÇho znaku
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ naáten° znaku

         cld
         lodsb

; ------ n†hrada tabel†toru mezerou

         cmp       al,9
         jne       ParChr2
         mov       al," "

; ------ test, zda je konec p©°kazovÇho ©†dku

ParChr2: cmp       al," "
         jae       ParChr3                  ; je platnò znak
         dec       si                       ; n†vrat ukazatele textu

ParChr3: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° aktu†ln°ho nastaven° parametrñ (ES=rezidentn° segment)
; -----------------------------------------------------------------------------

DispSet  PROC      NEAR

         mov       di,offset TestSet0       ; buffer k dek¢dov†n° parametrñ

; ------ typ kl†vesnice

         mov       al,es:[Klaves+KORIG]     ; á°slo aktu†ln° kl†vesnice
         add       al,"0"                   ; korekce na znak ASCII
         mov       ds:[di],al               ; typ aktu†ln° kl†vesnice

; ------ rozloëen° kl†vesnice

         mov       al,es:[Prepin+KORIG]     ; parametry
         mov       ah,"C"                   ; áesk† kl†vesnice
         test      al,4                     ; je slovensk† kl†vesnice ?
         jz        DispSet1                 ; je áesk† kl†vesnice
         mov       ah,"S"                   ; slovensk† kl†vesnice
DispSet1:mov       ds:[di+7],ah             ; rozloëen° kl†vesnice

; ------ n†rodn° k¢d

         and       al,40h+3                 ; aktu†ln° n†rodn° k¢d
         mov       ah,"K"                   ; k¢d Kamenickòch
         jz        DispSet2                 ; je k¢d Kamenickòch
         mov       ah,"L"                   ; k¢d Latin 2
         cmp       al,1                     ; je k¢d Latin 2 ?
         je        DispSet2                 ; je Latin 2
         mov       ah,"I"                   ; k¢d KOI 8
         cmp       al,2                     ; je k¢d KOI 8 ?
         je        DispSet2                 ; je KOI 8
         mov       ah,"W"                   ; k¢d WINDOWS
         cmp       al,40h+0                 ; je k¢d WINDOWS ?
         je        DispSet2                 ; je WINDOWS
         mov       ah,"O"                   ; jinak k¢d ISO 8859/2
DispSet2:mov       ds:[di+2],ah             ; n†rodn° k¢d

; ------ z†màna Y a Z

         mov       al,es:[Prepin+KORIG]     ; p©ep°naáe
         shr       al,1
         shr       al,1
         shr       al,1                     ; stav Y a Z
         and       al,3
         add       al,"0"                   ; korekce na znak ASCII
         mov       ds:[di+5],al             ; stav z†màny Y a Z

; ------ v numerickem poli carka

         mov       byte ptr ds:[di+9],"T"  ; je tecka
         test      byte ptr es:[Prepin+KORIG],20h ; je carka ?
         jz        DispSet3                 ; neni carka
         mov       byte ptr ds:[di+9],"D"  ; je carka

; ------ prefixovÇ kl†vesy

DispSet3:mov       ax,es:[PrefKey1+KORIG]   ; prefixovÇ kl†vesy norm†ln°
         mov       ds:[di+12],ax            ; prefixovÇ kl†vesy norm†ln°
         mov       ax,es:[PrefKey2+KORIG]   ; prefix kl†vesnice 3
         mov       ds:[di+14],ax            ; prefix kl†vesnice 3

; ------ zobrazen° textu

         mov       dx,offset TextSetP       ; text aktu†ln°ho stavu
         mov       ah,9
         int       21h                      ; zobrazen° textu stavu
         ret

DispSet  ENDP

; -----------------------------------------------------------------------------
;                            data pro instalaci
; -----------------------------------------------------------------------------
;˛
adrkod   label     word                     ; tabulka adres k¢dñ
         dw        offset tabkc             ; k¢d Kamenickòch - áe®tina
         dw        offset tablc             ; k¢d Latin 2 - áe®tina
         dw        offset tabxc             ; k¢d TEXT602 - áe®tina
         dw        offset taboc             ; k¢d ISO 8859/2 - áe®tina
         dw        offset tabks             ; k¢d Kamenickòch - sloven®tina
         dw        offset tabls             ; k¢d Latin 2 - sloven®tina
         dw        offset tabxs             ; k¢d TEXT602 - sloven®tina
         dw        offset tabos             ; k¢d ISO 8859/2 - sloven®tina

         dw        offset tabwc             ; k¢d WINDOWS - áe®tina
         dw        offset tabkc
         dw        offset tabkc
         dw        offset tabkc
         dw        offset tabws             ; k¢d WINDOWS - sloven®tina
         dw        offset tabks
         dw        offset tabks
         dw        offset tabks

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze Kamenickòch
; -----------------------------------------------------------------------------
tabkc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49                       ; poáet dvojic
         db        "b·"                     ; "·"
         db        "B·"                     ; "·"
         db        "qÑ"                     ; "Ñ"
         db        "Qé"                     ; "é"
         db        "wà"                     ; "à"
         db        "Wâ"                     ; "â"
         db        "eÇ"                     ; "Ç"
         db        "Eê"                     ; "ê"
         db        "r©"                     ; "©"
         db        "Rû"                     ; "û"
         db        "tü"                     ; "ü"
         db        "TÜ"                     ; "Ü"
         db        "yò"                     ; "ò"
         db        "Yù"                     ; "ù"
         db        "u£"                     ; "£"
         db        "Uó"                     ; "ó"
         db        "i°"                     ; "°"
         db        "Iã"                     ; "ã"
         db        "o¢"                     ; "¢"
         db        "Oï"                     ; "ï"
         db        "pî"                     ; "î"
         db        "Pô"                     ; "ô"
         db        "a†"                     ; "†"
         db        "Aè"                     ; "è"
         db        "s®"                     ; "®"
         db        "Sõ"                     ; "õ"
         db        "dÉ"                     ; "É"
         db        "DÖ"                     ; "Ö"
         db        "f™"                     ; "™"
         db        "F´"                     ; "´"
         db        "hÅ"                     ; "Å"
         db        "Hö"                     ; "ö"
         db        "jñ"                     ; "ñ"
         db        "J¶"                     ; "¶"
         db        "kì"                     ; "ì"
         db        "Kß"                     ; "ß"
         db        "lå"                     ; "å"
         db        "Lú"                     ; "ú"
         db        "zë"                     ; "ë"
         db        "Zí"                     ; "í"
         db        "cá"                     ; "á"
         db        "CÄ"                     ; "Ä"
         db        "n§"                     ; "§"
         db        "N•"                     ; "•"
         db        "mç"                     ; "ç"
         db        "Mä"                     ; "ä"
         db        ",Æ"                     ; "Æ"
         db        ".Ø"                     ; "Ø"
         db        "\≠"                     ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,150                ; "ñ"
         db        32h,3,136                ; "à"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,169                ; "©"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,166                ; "¶"
         db        32h,3,137                ; "â"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,158                ; "û"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,136                ; "à"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,169                ; "©"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";ñ"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\§"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,137                ; "â"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,158                ; "û"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";¶"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\•"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        212                      ; "‘"
         dw        5032h                    ; [2]
         db        207                      ; "œ"
         dw        5133h                    ; [3]
         db        190                      ; "æ"
         dw        4b34h                    ; [4]
         db        198                      ; "∆"
         dw        4c35h                    ; [5]
         db        216                      ; "ÿ"
         dw        4d36h                    ; [6]
         db        181                      ; "µ"
         dw        4737h                    ; [7]
         db        213                      ; "’"
         dw        4838h                    ; [8]
         db        209                      ; "—"
         dw        4939h                    ; [9]
         db        184                      ; "∏"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0                        

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        211                      ; "”"
         dw        5032h                    ; [2]
         db        208                      ; "–"
         dw        5133h                    ; [3]
         db        189                      ; "Ω"
         dw        4b34h                    ; [4]
         db        199                      ; "«"
         dw        4c35h                    ; [5]
         db        215                      ; "◊"
         dw        4d36h                    ; [6]
         db        182                      ; "∂"
         dw        4737h                    ; [7]
         db        214                      ; "÷"
         dw        4838h                    ; [8]
         db        210                      ; "“"
         dw        4939h                    ; [9]
         db        183                      ; "∑"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze Latin 2
; -----------------------------------------------------------------------------
tablc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",225                  ; "·"
         db        "B",225                  ; "·"
         db        "q",132                  ; "Ñ"
         db        "Q",142                  ; "é"
         db        "w",216                  ; "à"
         db        "W",183                  ; "â"
         db        "e",130                  ; "Ç"
         db        "E",144                  ; "ê"
         db        "r",253                  ; "©"
         db        "R",252                  ; "û"
         db        "t",156                  ; "ü"
         db        "T",155                  ; "Ü"
         db        "y",236                  ; "ò"
         db        "Y",237                  ; "ù"
         db        "u",163                  ; "£"
         db        "U",233                  ; "ó"
         db        "i",161                  ; "°"
         db        "I",214                  ; "ã"
         db        "o",162                  ; "¢"
         db        "O",224                  ; "ï"
         db        "p",148                  ; "î"
         db        "P",153                  ; "ô"
         db        "a",160                  ; "†"
         db        "A",181                  ; "è"
         db        "s",231                  ; "®"
         db        "S",230                  ; "õ"
         db        "d",212                  ; "É"
         db        "D",210                  ; "Ö"
         db        "f",234                  ; "™"
         db        "F",232                  ; "´"
         db        "h",129                  ; "Å"
         db        "H",154                  ; "ö"
         db        "j",133                  ; "ñ"
         db        "J",222                  ; "¶"
         db        "k",147                  ; "ì"
         db        "K",226                  ; "ß"
         db        "l",150                  ; "å"
         db        "L",149                  ; "ú"
         db        "z",167                  ; "ë"
         db        "Z",166                  ; "í"
         db        "c",159                  ; "á"
         db        "C",172                  ; "Ä"
         db        "n",229                  ; "§"
         db        "N",213                  ; "•"
         db        "m",146                  ; "ç"
         db        "M",145                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",245                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,133                ; "ñ"
         db        32h,3,216                ; "à"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,253                ; "©"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,222                ; "¶"
         db        32h,3,183                ; "â"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,252                ; "û"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,216                ; "à"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,253                ; "©"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",163                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",133                  ; "ñ"
         db        ":",34                   ; "'"
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",229                  ; "§"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,183                ; "â"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,252                ; "û"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",233                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",222                  ; "¶"
         db        ":",34
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",213                  ; "•"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze TEXT602
; -----------------------------------------------------------------------------
tabxc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",177                  ; "·"
         db        "B",177                  ; "·"
         db        "q",209                  ; "Ñ"
         db        "Q",241                  ; "é"
         db        "w",197                  ; "à"
         db        "W",229                  ; "â"
         db        "e",215                  ; "Ç"
         db        "E",247                  ; "ê"
         db        "r",210                  ; "©"
         db        "R",242                  ; "û"
         db        "t",212                  ; "ü"
         db        "T",244                  ; "Ü"
         db        "y",217                  ; "ò"
         db        "Y",249                  ; "ù"
         db        "u",213                  ; "£"
         db        "U",245                  ; "ó"
         db        "i",201                  ; "°"
         db        "I",233                  ; "ã"
         db        "o",207                  ; "¢"
         db        "O",239                  ; "ï"
         db        "p",205                  ; "î"
         db        "P",237                  ; "ô"
         db        "a",193                  ; "†"
         db        "A",225                  ; "è"
         db        "s",211                  ; "®"
         db        "S",243                  ; "õ"
         db        "d",196                  ; "É"
         db        "D",228                  ; "Ö"
         db        "f",198                  ; "™"
         db        "F",230                  ; "´"
         db        "h",200                  ; "Å"
         db        "H",232                  ; "ö"
         db        "j",202                  ; "ñ"
         db        "J",234                  ; "¶"
         db        "k",208                  ; "ì"
         db        "K",240                  ; "ß"
         db        "l",204                  ; "å"
         db        "L",236                  ; "ú"
         db        "z",218                  ; "ë"
         db        "Z",250                  ; "í"
         db        "c",195                  ; "á"
         db        "C",227                  ; "Ä"
         db        "n",206                  ; "§"
         db        "N",238                  ; "•"
         db        "m",203                  ; "ç"
         db        "M",235                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",131                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,202                ; "ñ"
         db        32h,3,197                ; "à"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,210                ; "©"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,234                ; "¶"
         db        32h,3,229                ; "â"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,242                ; "û"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,197                ; "à"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,210                ; "©"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",213                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",202                  ; "ñ"
         db        ":",34                   ; "'"
         db        "'",131                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",206                  ; "§"
         db        "?_"
         db        "|;"
         db        "~",222                  ; "¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,229                ; "â"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,242                ; "û"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",245                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",234                  ; "¶"
         db        ":",34
         db        "'",131                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",238                  ; "•"
         db        "?_"
         db        "|;"
         db        "~",222                  ; "¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;*˛

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze ISO 8859/2 - ISO LATIN 2
; -----------------------------------------------------------------------------
taboc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",223                  ; "·"
         db        "B",223                  ; "·"
         db        "q",228                  ; "Ñ"
         db        "Q",196                  ; "é"
         db        "w",236                  ; "à"
         db        "W",204                  ; "â"
         db        "e",233                  ; "Ç"
         db        "E",201                  ; "ê"
         db        "r",248                  ; "©"
         db        "R",216                  ; "û"
         db        "t",187                  ; "ü"
         db        "T",171                  ; "Ü"
         db        "y",253                  ; "ò"
         db        "Y",221                  ; "ù"
         db        "u",250                  ; "£"
         db        "U",218                  ; "ó"
         db        "i",237                  ; "°"
         db        "I",205                  ; "ã"
         db        "o",243                  ; "¢"
         db        "O",211                  ; "ï"
         db        "p",246                  ; "î"
         db        "P",214                  ; "ô"
         db        "a",225                  ; "†"
         db        "A",193                  ; "è"
         db        "s",185                  ; "®"
         db        "S",169                  ; "õ"
         db        "d",239                  ; "É"
         db        "D",207                  ; "Ö"
         db        "f",224                  ; "™"
         db        "F",192                  ; "´"
         db        "h",252                  ; "Å"
         db        "H",220                  ; "ö"
         db        "j",249                  ; "ñ"
         db        "J",217                  ; "¶"
         db        "k",244                  ; "ì"
         db        "K",212                  ; "ß"
         db        "l",181                  ; "å"
         db        "L",165                  ; "ú"
         db        "z",190                  ; "ë"
         db        "Z",174                  ; "í"
         db        "c",232                  ; "á"
         db        "C",200                  ; "Ä"
         db        "n",242                  ; "§"
         db        "N",210                  ; "•"
         db        "m",229                  ; "ç"
         db        "M",197                  ; "ä"
         db        ",",060                  ; "<"          ; "Æ"
         db        ".",062                  ; ">"          ; "Ø"
         db        "\",167                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,249                ; "ñ"
         db        32h,3,236                ; "à"
         db        33h,4,185                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,248                ; "©"
         db        36h,7,190                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,217                ; "¶"
         db        32h,3,204                ; "â"
         db        33h,4,169                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,216                ; "û"
         db        36h,7,174                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,236                ; "à"
         db        33h,4,185                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,248                ; "©"
         db        36h,7,190                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",250                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",249                  ; "ñ"
         db        ":",34                   ; "'"
         db        "'",167                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",242                  ; "§"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,204                ; "â"
         db        33h,4,169                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,216                ; "û"
         db        36h,7,174                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",218                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",217                  ; "¶"
         db        ":",34
         db        "'",167                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",210                  ; "•"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze WINDOWS (ISO 8859)
; -----------------------------------------------------------------------------
tabwc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",223                  ; "·"
         db        "B",223                  ; "·"
         db        "q",228                  ; "Ñ"
         db        "Q",196                  ; "é"
         db        "w",236                  ; "à"
         db        "W",204                  ; "â"
         db        "e",233                  ; "Ç"
         db        "E",201                  ; "ê"
         db        "r",248                  ; "©"
         db        "R",216                  ; "û"
         db        "t",157                  ; "ü"
         db        "T",141                  ; "Ü"
         db        "y",253                  ; "ò"
         db        "Y",221                  ; "ù"
         db        "u",250                  ; "£"
         db        "U",218                  ; "ó"
         db        "i",237                  ; "°"
         db        "I",205                  ; "ã"
         db        "o",243                  ; "¢"
         db        "O",211                  ; "ï"
         db        "p",246                  ; "î"
         db        "P",214                  ; "ô"
         db        "a",225                  ; "†"
         db        "A",193                  ; "è"
         db        "s",154                  ; "®"
         db        "S",138                  ; "õ"
         db        "d",239                  ; "É"
         db        "D",207                  ; "Ö"
         db        "f",224                  ; "™"
         db        "F",192                  ; "´"
         db        "h",252                  ; "Å"
         db        "H",220                  ; "ö"
         db        "j",249                  ; "ñ"
         db        "J",217                  ; "¶"
         db        "k",244                  ; "ì"
         db        "K",212                  ; "ß"
         db        "l",190                  ; "å"
         db        "L",188                  ; "ú"
         db        "z",158                  ; "ë"
         db        "Z",142                  ; "í"
         db        "c",232                  ; "á"
         db        "C",200                  ; "Ä"
         db        "n",242                  ; "§"
         db        "N",210                  ; "•"
         db        "m",229                  ; "ç"
         db        "M",197                  ; "ä"
         db        ",",060                  ; "<"          ; "Æ"
         db        ".",062                  ; ">"          ; "Ø"
         db        "\",167                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,249                ; "ñ"
         db        32h,3,236                ; "à"
         db        33h,4,154                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,248                ; "©"
         db        36h,7,158                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,217                ; "¶"
         db        32h,3,204                ; "â"
         db        33h,4,138                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,216                ; "û"
         db        36h,7,142                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,236                ; "à"
         db        33h,4,154                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,248                ; "©"
         db        36h,7,158                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",250                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",249                  ; "ñ"
         db        ":",34                   ; "'"
         db        "'",167                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",242                  ; "§"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,204                ; "â"
         db        33h,4,138                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,216                ; "û"
         db        36h,7,142                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",218                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",217                  ; "¶"
         db        ":",34
         db        "'",167                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",210                  ; "•"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        152                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        152                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0

;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        157                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        152                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - slovensk† verze Kamenickòch
; -----------------------------------------------------------------------------
tabks    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",225                  ; "·"
         db        "B",225                  ; "·"
         db        "qÑ"                     ; "Ñ"
         db        "Qé"                     ; "é"
         db        "wà"                     ; "à"
         db        "Wâ"                     ; "â"
         db        "eÇ"                     ; "Ç"
         db        "Eê"                     ; "ê"
         db        "f©"                     ; "©"
         db        "Fû"                     ; "û"
         db        "tü"                     ; "ü"
         db        "TÜ"                     ; "Ü"
         db        "yò"                     ; "ò"
         db        "Yù"                     ; "ù"
         db        "u£"                     ; "£"
         db        "Uó"                     ; "ó"
         db        "i°"                     ; "°"
         db        "Iã"                     ; "ã"
         db        "o¢"                     ; "¢"
         db        "Oï"                     ; "ï"
         db        "pî"                     ; "î"
         db        "Pô"                     ; "ô"
         db        "a†"                     ; "†"
         db        "Aè"                     ; "è"
         db        "s®"                     ; "®"
         db        "Sõ"                     ; "õ"
         db        "dÉ"                     ; "É"
         db        "DÖ"                     ; "Ö"
         db        "r™"                     ; "™"
         db        "R´"                     ; "´"
         db        "hÅ"                     ; "Å"
         db        "Hö"                     ; "ö"
         db        "jñ"                     ; "ñ"
         db        "J¶"                     ; "¶"
         db        "kì"                     ; "ì"
         db        "Kß"                     ; "ß"
         db        "lå"                     ; "å"
         db        "Lú"                     ; "ú"
         db        "zë"                     ; "ë"
         db        "Zí"                     ; "í"
         db        "cá"                     ; "á"
         db        "CÄ"                     ; "Ä"
         db        "n§"                     ; "§"
         db        "N•"                     ; "•"
         db        "mç"                     ; "ç"
         db        "Mä"                     ; "ä"
         db        ",Æ"                     ; "Æ"
         db        ".Ø"                     ; "Ø"
         db        "\≠"                     ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,147                ; "ì"
         db        32h,3,140                ; "å"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,159                ; "ü"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,167                ; "ß"
         db        32h,3,156                ; "ú"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,134                ; "Ü"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,140                ; "å"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,159                ; "ü"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[£"
         db        "{/"
         db        "]Ñ"
         db        "}("
         db        ";ì"
         db        ":",34
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\§"
         db        "?_"
         db        "|≠"
         db        "~™"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,156                ; "ú"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,134                ; "Ü"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[ó"
         db        "{/"
         db        "]é"
         db        "}("
         db        ";ß"
         db        ":",34
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\•"
         db        "?_"
         db        "|≠"
         db        "~´"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        212                      ; "‘"
         dw        5032h                    ; [2]
         db        207                      ; "œ"
         dw        5133h                    ; [3]
         db        190                      ; "æ"
         dw        4b34h                    ; [4]
         db        198                      ; "∆"
         dw        4c35h                    ; [5]
         db        216                      ; "ÿ"
         dw        4d36h                    ; [6]
         db        181                      ; "µ"
         dw        4737h                    ; [7]
         db        213                      ; "’"
         dw        4838h                    ; [8]
         db        209                      ; "—"
         dw        4939h                    ; [9]
         db        184                      ; "∏"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0                        

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        211                      ; "”"
         dw        5032h                    ; [2]
         db        208                      ; "–"
         dw        5133h                    ; [3]
         db        189                      ; "Ω"
         dw        4b34h                    ; [4]
         db        199                      ; "«"
         dw        4c35h                    ; [5]
         db        215                      ; "◊"
         dw        4d36h                    ; [6]
         db        182                      ; "∂"
         dw        4737h                    ; [7]
         db        214                      ; "÷"
         dw        4838h                    ; [8]
         db        210                      ; "“"
         dw        4939h                    ; [9]
         db        183                      ; "∑"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - slovensk† verze Latin 2
; -----------------------------------------------------------------------------
tabls    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",225                  ; "·"
         db        "B",225                  ; "·"
         db        "q",132                  ; "Ñ"
         db        "Q",142                  ; "é"
         db        "w",216                  ; "à"
         db        "W",183                  ; "â"
         db        "e",130                  ; "Ç"
         db        "E",144                  ; "ê"
         db        "f",253                  ; "©"
         db        "F",252                  ; "û"
         db        "t",156                  ; "ü"
         db        "T",155                  ; "Ü"
         db        "y",236                  ; "ò"
         db        "Y",237                  ; "ù"
         db        "u",163                  ; "£"
         db        "U",233                  ; "ó"
         db        "i",161                  ; "°"
         db        "I",214                  ; "ã"
         db        "o",162                  ; "¢"
         db        "O",224                  ; "ï"
         db        "p",148                  ; "î"
         db        "P",153                  ; "ô"
         db        "a",160                  ; "†"
         db        "A",181                  ; "è"
         db        "s",231                  ; "®"
         db        "S",230                  ; "õ"
         db        "d",212                  ; "É"
         db        "D",210                  ; "Ö"
         db        "r",234                  ; "™"
         db        "R",232                  ; "´"
         db        "h",129                  ; "Å"
         db        "H",154                  ; "ö"
         db        "j",133                  ; "ñ"
         db        "J",222                  ; "¶"
         db        "k",147                  ; "ì"
         db        "K",226                  ; "ß"
         db        "l",150                  ; "å"
         db        "L",149                  ; "ú"
         db        "z",167                  ; "ë"
         db        "Z",166                  ; "í"
         db        "c",159                  ; "á"
         db        "C",172                  ; "Ä"
         db        "n",229                  ; "§"
         db        "N",213                  ; "•"
         db        "m",146                  ; "ç"
         db        "M",145                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",245                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,147                ; "ì"
         db        32h,3,150                ; "å"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,156                ; "ü"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,226                ; "ß"
         db        32h,3,149                ; "ú"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,155                ; "Ü"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,150                ; "å"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,156                ; "ü"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",163                  ; "£"
         db        "{/"
         db        "]",132                  ; "Ñ"
         db        "}("
         db        ";",147                  ; "ì"
         db        ":",34                   ; '"'
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",229                  ; "§"
         db        "?_"
         db        "|",245                  ; "≠"
         db        "~",234                  ; "™"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,149                ; "ú"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,155                ; "Ü"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",233                  ; "ó"
         db        "{/"
         db        "]",142                  ; "é"
         db        "}("
         db        ";",226                  ; "ß"
         db        ":",34
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",213                  ; "•"
         db        "?_"
         db        "|",245                  ; "≠"
         db        "~",232                  ; "´"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - slovensk† verze TEXT602
; -----------------------------------------------------------------------------
tabxs    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",177                  ; "·"
         db        "B",177                  ; "·"
         db        "q",209                  ; "Ñ"
         db        "Q",241                  ; "é"
         db        "w",197                  ; "à"
         db        "W",229                  ; "â"
         db        "e",215                  ; "Ç"
         db        "E",247                  ; "ê"
         db        "f",210                  ; "©"
         db        "F",242                  ; "û"
         db        "t",212                  ; "ü"
         db        "T",244                  ; "Ü"
         db        "y",217                  ; "ò"
         db        "Y",249                  ; "ù"
         db        "u",213                  ; "£"
         db        "U",245                  ; "ó"
         db        "i",201                  ; "°"
         db        "I",233                  ; "ã"
         db        "o",207                  ; "¢"
         db        "O",239                  ; "ï"
         db        "p",205                  ; "î"
         db        "P",237                  ; "ô"
         db        "a",193                  ; "†"
         db        "A",225                  ; "è"
         db        "s",211                  ; "®"
         db        "S",243                  ; "õ"
         db        "d",196                  ; "É"
         db        "D",228                  ; "Ö"
         db        "r",198                  ; "™"
         db        "R",230                  ; "´"
         db        "h",200                  ; "Å"
         db        "H",232                  ; "ö"
         db        "j",202                  ; "ñ"
         db        "J",234                  ; "¶"
         db        "k",208                  ; "ì"
         db        "K",240                  ; "ß"
         db        "l",204                  ; "å"
         db        "L",236                  ; "ú"
         db        "z",218                  ; "ë"
         db        "Z",250                  ; "í"
         db        "c",195                  ; "á"
         db        "C",227                  ; "Ä"
         db        "n",206                  ; "§"
         db        "N",238                  ; "•"
         db        "m",203                  ; "ç"
         db        "M",235                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",131                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,208                ; "ì"
         db        32h,3,204                ; "å"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,212                ; "ü"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,240                ; "ß"
         db        32h,3,236                ; "ú"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,244                ; "Ü"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,204                ; "å"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,212                ; "ü"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",213                  ; "£"
         db        "{/"
         db        "]",209                  ; "Ñ"
         db        "}("
         db        ";",208                  ; "ì"
         db        ":",34                   ; "'"
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",206                  ; "§"
         db        "?_"
         db        "|",131                  ; "≠"
         db        "~",198                  ; "™"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,236                ; "ú"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,244                ; "Ü"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",245                  ; "ó"
         db        "{/"
         db        "]",241                  ; "é"
         db        "}("
         db        ";",240                  ; "ß"
         db        ":",34
         db        "'",131                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",238                  ; "•"
         db        "?_"
         db        "|",131                  ; "≠"
         db        "~",230                  ; "´"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;*˛

; -----------------------------------------------------------------------------
;                     K¢dy - slovensk† verze ISO 8859/2 - ISO LATIN 2
; -----------------------------------------------------------------------------
tabos    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",223                  ; "·"
         db        "B",223                  ; "·"
         db        "q",228                  ; "Ñ"
         db        "Q",196                  ; "é"
         db        "w",236                  ; "à"
         db        "W",204                  ; "â"
         db        "e",233                  ; "Ç"
         db        "E",201                  ; "ê"
         db        "f",248                  ; "©"
         db        "F",216                  ; "û"
         db        "t",187                  ; "ü"
         db        "T",171                  ; "Ü"
         db        "y",253                  ; "ò"
         db        "Y",221                  ; "ù"
         db        "u",250                  ; "£"
         db        "U",218                  ; "ó"
         db        "i",237                  ; "°"
         db        "I",205                  ; "ã"
         db        "o",243                  ; "¢"
         db        "O",211                  ; "ï"
         db        "p",246                  ; "î"
         db        "P",214                  ; "ô"
         db        "a",225                  ; "†"
         db        "A",193                  ; "è"
         db        "s",185                  ; "®"
         db        "S",169                  ; "õ"
         db        "d",239                  ; "É"
         db        "D",207                  ; "Ö"
         db        "r",224                  ; "™"
         db        "R",192                  ; "´"
         db        "h",252                  ; "Å"
         db        "H",220                  ; "ö"
         db        "j",249                  ; "ñ"
         db        "J",217                  ; "¶"
         db        "k",244                  ; "ì"
         db        "K",212                  ; "ß"
         db        "l",181                  ; "å"
         db        "L",165                  ; "ú"
         db        "z",190                  ; "ë"
         db        "Z",174                  ; "í"
         db        "c",232                  ; "á"
         db        "C",200                  ; "Ä"
         db        "n",242                  ; "§"
         db        "N",210                  ; "•"
         db        "m",229                  ; "ç"
         db        "M",197                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",167                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,244                ; "ì"
         db        32h,3,181                ; "å"
         db        33h,4,185                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,187                ; "ü"
         db        36h,7,190                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,212                ; "ß"
         db        32h,3,165                ; "ú"
         db        33h,4,169                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,171                ; "Ü"
         db        36h,7,174                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,181                ; "å"
         db        33h,4,185                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,187                ; "ü"
         db        36h,7,190                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",250                  ; "£"
         db        "{/"
         db        "]",228                  ; "Ñ"
         db        "}("
         db        ";",244                  ; "ì"
         db        ":",34                   ; '"'
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",242                  ; "§"
         db        "?_"
         db        "|",167                  ; "≠"
         db        "~",224                  ; "™"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,165                ; "ú"
         db        33h,4,169                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,171                ; "Ü"
         db        36h,7,174                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",218                  ; "ó"
         db        "{/"
         db        "]",196                  ; "é"
         db        "}("
         db        ";",212                  ; "ß"
         db        ":",34
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",210                  ; "•"
         db        "?_"
         db        "|",167                  ; "≠"
         db        "~",192                  ; "´"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        138                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        130                      ; "¿"
         dw        5032h                    ; [2]
         db        134                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        135                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        133                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        132                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        137                      ; "≥"
         dw        0e02fh                   ; [/]
         db        139                      ; "∞"
         dw        372ah                    ; [*]
         db        141                      ; "±"
         dw        4a2dh                    ; [-]
         db        142                      ; "≤"
         dw        4e2bh                    ; [+]
         db        143                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - slovensk† verze WINDOWS (ISO 8859)
; -----------------------------------------------------------------------------
tabws    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",223                  ; "·"
         db        "B",223                  ; "·"
         db        "q",228                  ; "Ñ"
         db        "Q",196                  ; "é"
         db        "w",236                  ; "à"
         db        "W",204                  ; "â"
         db        "e",233                  ; "Ç"
         db        "E",201                  ; "ê"
         db        "f",248                  ; "©"
         db        "F",216                  ; "û"
         db        "t",157                  ; "ü"
         db        "T",141                  ; "Ü"
         db        "y",253                  ; "ò"
         db        "Y",221                  ; "ù"
         db        "u",250                  ; "£"
         db        "U",218                  ; "ó"
         db        "i",237                  ; "°"
         db        "I",205                  ; "ã"
         db        "o",243                  ; "¢"
         db        "O",211                  ; "ï"
         db        "p",246                  ; "î"
         db        "P",214                  ; "ô"
         db        "a",225                  ; "†"
         db        "A",193                  ; "è"
         db        "s",154                  ; "®"
         db        "S",138                  ; "õ"
         db        "d",239                  ; "É"
         db        "D",207                  ; "Ö"
         db        "r",224                  ; "™"
         db        "R",192                  ; "´"
         db        "h",252                  ; "Å"
         db        "H",220                  ; "ö"
         db        "j",249                  ; "ñ"
         db        "J",217                  ; "¶"
         db        "k",244                  ; "ì"
         db        "K",212                  ; "ß"
         db        "l",190                  ; "å"
         db        "L",188                  ; "ú"
         db        "z",158                  ; "ë"
         db        "Z",142                  ; "í"
         db        "c",232                  ; "á"
         db        "C",200                  ; "Ä"
         db        "n",242                  ; "§"
         db        "N",210                  ; "•"
         db        "m",229                  ; "ç"
         db        "M",197                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",167                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,244                ; "ì"
         db        32h,3,190                ; "å"
         db        33h,4,154                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,157                ; "ü"
         db        36h,7,158                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,212                ; "ß"
         db        32h,3,188                ; "ú"
         db        33h,4,138                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,141                ; "Ü"
         db        36h,7,142                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,190                ; "å"
         db        33h,4,154                ; "®"
         db        34h,5,232                ; "á"
         db        35h,6,157                ; "ü"
         db        36h,7,158                ; "ë"
         db        37h,8,253                ; "ò"
         db        38h,9,225                ; "†"
         db        39h,10,237               ; "°"
         db        30h,11,233               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",250                  ; "£"
         db        "{/"
         db        "]",228                  ; "Ñ"
         db        "}("
         db        ";",244                  ; "ì"
         db        ":",34                   ; '"'
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",242                  ; "§"
         db        "?_"
         db        "|",167                  ; "≠"
         db        "~",224                  ; "™"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,188                ; "ú"
         db        33h,4,138                ; "õ"
         db        34h,5,200                ; "Ä"
         db        35h,6,141                ; "Ü"
         db        36h,7,142                ; "í"
         db        37h,8,221                ; "ù"
         db        38h,9,193                ; "è"
         db        39h,10,205               ; "ã"
         db        30h,11,201               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        25
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",218                  ; "ó"
         db        "{/"
         db        "]",196                  ; "é"
         db        "}("
         db        ";",212                  ; "ß"
         db        ":",34
         db        "')"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "\",210                  ; "•"
         db        "?_"
         db        "|",167                  ; "≠"
         db        "~",192                  ; "´"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        152                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        152                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        152                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        173                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        144                      ; "¿"
         dw        5032h                    ; [2]
         db        136                      ; "¡"
         dw        5133h                    ; [3]
         db        131                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        136                      ; "√"
         dw        4c35h                    ; [5]
         db        136                      ; "≈"
         dw        4d36h                    ; [6]
         db        136                      ; "¥"
         dw        4737h                    ; [7]
         db        128                      ; "⁄"
         dw        4838h                    ; [8]
         db        136                      ; "¬"
         dw        4939h                    ; [9]
         db        129                      ; "ø"
         dw        532eh                    ; [.]
         db        152                      ; "≥"
         dw        0e02fh                   ; [/]
         db        "/"                      ; "∞"
         dw        372ah                    ; [*]
         db        "*"                      ; "±"
         dw        4a2dh                    ; [-]
         db        "-"                      ; "≤"
         dw        4e2bh                    ; [+]
         db        "+"                      ; "€"
         db        0

InstTxt  db        '  CSKEY byl nainstalovan do pameti.',13,10,'$'

NelzeTxt db        'CSKEY nelze odinstalovat z pameti.',13,10
         db        'Odinstalujte nejdrive programy nainstalovane pozdeji.',13,10,'$'

DInsTxt  db        'CSKEY byl odinstalovan z pameti.',13,10,'$'

NeniTxt  db        'CSKEY nebyl dosud nainstalovan.',13,10,'$'

UvTxt    db        'CSKEY V 3.30 - ovladac CS klavesnice; (c) Miroslav Nemecek',13,10,'$'

;*˛

HelpTxt  db        '…ÕÕÕÕÕÕ TYP KLAVESNICE ÕÕÕÕÕÕÀÕÕÕÕÕÕ NARODNI KOD ÕÕÕÕÕÕÕÕª',13,10
         db        '∫ 1 standardni               ∫ K kod bratri Kamenickych  ∫',13,10
         db        '∫ 2 programatorska           ∫    (áernò kñ§ bàë°)       ∫',13,10
         db        '∫ 3 pisarska                 ∫ L kod Latin 2             ∫',13,10
         db        '∫ 4 graficka Õ ∫             ∫    (üernÏ kÖÂ bÿß°)       ∫',13,10
         db        '∫ 5 graficka     ƒ ≥         ∫ I kod KOI8 (TEXT 602)     ∫',13,10
         db        '∫ 6 graficka         Õ ≥     ∫    (√ernŸ k Œ b≈⁄…)       ∫',13,10
         db        '∫ 7 graficka             ƒ ∫ ∫ W kod WINDOWS (ISO 8859)  ∫',13,10
         db        'ÃÕÕ CARKA V NUMERICKEM POLI Õπ    (Ëern˝ k˘Ú bÏûÌ)       ∫',13,10
         db        '∫ T v numerickem poli tecka  ∫ O kod ISO 8859/2 (ISO L2) ∫',13,10
         db        '∫ D v numerickem poli carka  ∫    (Ëern˝ k˘Ú bÏæÌ)       ∫',13,10
         db        'ÃÕÕÕ ZAMENA KLAVES Y A Z ÕÕÕÕŒÕÕ ROZLOZENI KLAVESNICE ÕÕÕπ',13,10
         db        '∫ Z0 nikdy                   ∫ C ceska      S slovenska  ∫',13,10
         db        '∫ Z1 krome pisarske klavesn. ÃÕÕÕÕÕ VOLBA PREFIXU ÕÕÕÕÕÕÕπ',13,10
         db        '∫ Z2 jen pisarska klavesnice ∫ Pabcd ... ab=ostatni klav.∫',13,10
         db        '∫ Z3 vzdy                    ∫           cd=pisarska kl. ∫',13,10
         db        '»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ! odinstalovani z pameti ÕÕÕÕÕÕÕÕÕÕÕÕÕÕº',13,10
         db        '$'

TextSetP db        'Soucasne nastaveni parametru: CSKEY '
TestSet0 db        '1 L Z2 C T P``=+',13,10,'$'

ParamIni db        0                        ; parametry pro inicializaci
                                            ;   bit 0: 1=je prvn° instalace
                                            ;   bit 1: 1=poëadavek odinstalov†n°

Command  db        128 dup(?)               ; buffer p©°kazovÇho ©†dku

Code     ENDS

         END       Start

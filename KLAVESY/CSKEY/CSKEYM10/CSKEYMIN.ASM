
; *****************************************************************************
;
;                         Ovladaá áeskÇ kl†vesnice
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:   jmp       init                     ; instalace programu

old09    dd        0                        ; pñvodn° obsluha INT 09h

switch   db        00000000b                ; p©°znaky kl†vesnice
                                            ; bit 0 = byl prefix

int09:                                      ; program obsluhy kl†vesnice

         push      ax
         push      bx                       ; £schova registru BX
         push      cx
         push      si
         push      ds                       ; £schova registru DS
         mov       bx,40h                   ; segment dat BIOS
         mov       ds,bx                    ; DS <- segment dat BIOS 0040h
         mov       bx,word ptr ds:[1ch]     ; ukl†dac° adresa znakñ
         pushf                              ; simulace vol†n° INT
         call      dword ptr cs:[old09]     ; pñvodn° obsluha kl†vesnice
         cmp       bx,word ptr ds:[1ch]     ; byl p©ijat znak ?
         je        konec                    ; nebyl p©ijat znak z kl†vesnice
         mov       ax,ds:[bx]               ; p©ijat† kl†vesa

                                          ;* obsluha zadani prefixu
         test      byte ptr cs:[switch],1   ; byl jië nàkterò prefix ?
         jnz       int092                   ; byl zadan prefix
         cmp       al,"`"                   ; je prefix ` (á†rka vlevo) ?
         je        int091                   ; je prefix `
         cmp       al,"'"                   ; je prefix ' (á†rka vpravo) ?
         jne       konec                    ; nen° ani prefix ' - znak se necha
int091:  or        byte ptr cs:[switch],1   ; nastaven° prefixu ` nebo '
         mov       word ptr ds:[1ch],bx     ; zru®en° kl†vesy z bufferu
         jmp       short konec

                                          ;* zru®en° prefixu kl†vesou <Delete>
int092:  cmp       ah,0eh                   ; je kl†vesa <BS> ?
         je        int093                   ; je kl†vesa <BS>
         cmp       ah,53h                   ; je kl†vesa <Delete> ?
         jne       int094                   ; nebyla kl†vesa <Delete>
int093:  mov       ds:[1ch],bx              ; zru®en° kl†vesy
         jmp       short konec1             ; zruseni priznaku prefixu

                                          ;* prekodovani klavesy
int094:  mov       si,offset dektab-2       ; dek¢dovac° tabulka
         mov       cx,offset(dektab0-dektab)/2 ; dÇlka tabulky
int095:  add       si,2                     ; nastaven° na dal®° znak v tabulce
         cmp       al,cs:[si]               ; je to hledanò znak ?
         loopne    int095                   ; nen° to hledanò znak - dal®° pokus
         jne       konec1                   ; znak nenalezen
                                          ;* p©ek¢dov†vanò znak nalezen
         mov       al,cs:[si+1]             ; novò k¢d znaku
         mov       [bx],ax                  ; n†hrada novòm znakem

konec1:  and       byte ptr cs:[switch],not 1; zru®en° p©°znaku prefixu

konec:   pop       ds
         pop       si
         pop       cx
         pop       bx
         pop       ax
         iret


dektab   label     byte                   ;* dek¢dovac° tabulka - Kamenickòch

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

dektab0  label     byte

; *****************************************************************************
;
;                        Instalace programu
;
; *****************************************************************************
init:                                     ;* instalace programu

         mov       dx,offset uvtxt          ; hl†®en° o instalaci programu
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn°ho textu

                                          ;* nalezen° parametru
         cld
         xor       cx,cx
         mov       cl,ds:[80h]
         mov       si,81h
         jcxz      error
init1:   lodsb
         and       al,not 20h               ; prevod na velke pismeno
         cmp       al,"K"
         je        init5                    ; je kod Kamenickych
         cmp       al,"L"
         je        init4                    ; je kod Latin 2
         loop      init1                    ; dalsi znak

                                          ;* chyba zadani parametru
error:   mov       dx,offset errtxt
         mov       ah,9
         int       21h                      ; zobrazeni chyboveho textu
         int       20h                      ; konec programu

init4:   mov       si,offset dektabl        ; tabulka Latin 2
         mov       di,offset dektab         ; tabulka klavesnice
         mov       cx,offset(dektab0-dektab); delka tabulky
         rep       movsb                    ; prenos tabulky

init5:                                    ;* instalace programu
         mov       ax,3509h                 ; p©eáten° vektoru p©eru®en° 09h
         int       21h
         mov       word ptr [old09],bx      ; uloëen° pñvodn°ho vekt. p©eru®en°
         mov       word ptr [old09+2],es    ; segment nad©azenÇ instalace
         mov       dx,offset int09          ; adresa vlastn° obsluhy INT 09h
         mov       ax,2509h
         int       21h                      ; nastaven° novÇ adresy INT 09H
         mov       dx,offset init           ; konec rezidentn° á†sti
         int       27h                      ; instalace do pamàti


dektabl  label     byte                   ;* dek¢dovac° tabulka - Latin 2

         db        "qÑ"                     ; "Ñ"
         db        "Qé"                     ; "é"
         db        "wÿ"                     ; "à"
         db        "W∑"                     ; "â"
         db        "eÇ"                     ; "Ç"
         db        "Eê"                     ; "ê"
         db        "r˝"                     ; "©"
         db        "R¸"                     ; "û"
         db        "tú"                     ; "ü"
         db        "Tõ"                     ; "Ü"
         db        "yÏ"                     ; "ò"
         db        "YÌ"                     ; "ù"
         db        "u£"                     ; "£"
         db        "UÈ"                     ; "ó"
         db        "i°"                     ; "°"
         db        "I÷"                     ; "ã"
         db        "o¢"                     ; "¢"
         db        "O‡"                     ; "ï"
         db        "pî"                     ; "î"
         db        "Pô"                     ; "ô"
         db        "a†"                     ; "†"
         db        "Aµ"                     ; "è"
         db        "sÁ"                     ; "®"
         db        "SÊ"                     ; "õ"
         db        "d‘"                     ; "É"
         db        "D“"                     ; "Ö"
         db        "fÍ"                     ; "™"
         db        "FË"                     ; "´"
         db        "hÅ"                     ; "Å"
         db        "Hö"                     ; "ö"
         db        "jÖ"                     ; "ñ"
         db        "Jﬁ"                     ; "¶"
         db        "kì"                     ; "ì"
         db        "K‚"                     ; "ß"
         db        "lñ"                     ; "å"
         db        "Lï"                     ; "ú"
         db        "zß"                     ; "ë"
         db        "Z¶"                     ; "í"
         db        "cü"                     ; "á"
         db        "C¨"                     ; "Ä"
         db        "nÂ"                     ; "§"
         db        "N’"                     ; "•"
         db        "mí"                     ; "ç"
         db        "Më"                     ; "ä"
         db        ",Æ"                     ; "Æ"
         db        ".Ø"                     ; "Ø"
         db        "\ı"                     ; "≠"

uvtxt    db        'CS klavesnice Mini;  (c) Miroslav Nemecek',13,10,'$'

errtxt   db        'Zadejte: K - kod Kamenickych, L - Latin 2',13,10,'$'

code     ENDS

         END       start                    ; startovac° adresa

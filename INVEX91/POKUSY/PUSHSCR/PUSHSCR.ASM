
; *****************************************************************************
;
;                                P U S H S C R
;
;                         Sn°m†n° obrazovek do souborñ
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

Start:   jmp       Instal

Ident    db        'PUSHSCR V1.1'           ; identifikaán° text
Ident0   label     byte                     ; konec identifikaán°ho textu

SegIns   dw        0                        ; segment s instalovanòm programem

Param    db        0                        ; bit 0: 1=data v kompresnim tvaru
                                            ; bit 1: 1=je vò©ez obrazovky

                                            ; bit 6: 1=poëadavek £schovy displ.
                                            ; bit 7: 1=prob°h† £schova displeje

Old08    dd        0                        ; pñvodn° adresa INT 08h
Old09    dd        0                        ; pñvodn° adresa INT 09h
Old28    dd        0                        ; pñvodn° adresa INT 28h

Soubor   db        128 dup(0)               ; pracovn° soubor

; -----------------------------------------------------------------------------
;        Obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         jmp       dword ptr cs:[Old08]     ; pñvodn° obsluha INT 08h

Int08    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

         jmp       dword ptr cs:[Old09]     ; pñvodn° adresa INT 09h

Int09    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

                                          ;* kontrola, zda je dotaz na instalaci
         cmp       ax,3546h                 ; identifikaán° slovo 1
         jne       Int282                   ; slovo nesouhlas°
         cmp       bx,4523h                 ; identifikaán° slovo 2
         jne       Int282                   ; slovo nesouhlas°

         pushf
         push      si
         push      di
         push      cx
         push      es
         push      cs
         pop       es
         mov       si,offset Ident
         mov       di,si
         mov       cx,offset(Ident-Ident0)
         cld
         repe      cmpsb                    ; kontrola, zda je to PUSHSCR
         pop       es
         pop       cx
         pop       di
         pop       si
         jne       Int281                   ; nesouhlas°
         mov       ds:[SegIns],cs           ; segment rezidentn°ho modulu
Int281:  popf

Int282:  jmp       dword ptr cs:[Old28]     ; pñvodn° obsluha INT 28h

; *****************************************************************************
;
;                  Instalace/odinstalov†n° programu PUSHSCR
;
; *****************************************************************************

Instal:  mov       dx,offset UvTxt          ; £vodn° text
         call      DispTxt                  ; zobrazen° £vodn°ho textu

                                          ;* nalezen° rezidentn°ho modulu
         mov       ds:[SegIns],ds           ; segment tohoto programu
         mov       ax,3546h                 ; identifikaán° slovo 1
         mov       bx,4523h                 ; identifikaán° slovo 2
         int       28h                      ; dotaz na instalaci
         mov       es,ds:[SegIns]           ; segment s programem PUSHSCR

                                          ;* p©°prava k rozboru zad†n°
         cld                                ; smàr nahoru
         mov       si,81h                   ; zaá†tek textu zad†n°
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[80h]              ; poáet znakñ
Inst1:   jcxz      Chyba                    ; nen° nic zad†no - n†povàda
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al,9                     ; je tabel†tor ?
         je        Inst1                    ; je tabel†tor - ignorov†n°
         cmp       al," "                   ; je mezera ?
         je        Inst1                    ; je mezera - ignorov†n°
         cmp       al,"/"                   ; je parametr ?
         jne       Inst3                    ; nen° parametr

                                          ;* kontrola, zda je odinstalov†n°
         lodsb
         or        al,20h                   ; p©evod na malÇ p°smeno
         cmp       al,"u"                   ; je odinstalov†n° ?
         jne       Chyba                    ; ne - chyba zad†n°
         jmp       UnInst                   ; odinstalov†n° programu

                                          ;* uloëen° jmÇna souboru
         mov       di,offset Soubor         ; jmÇno souboru
         mov       dx,si                    ; zaá†tek jmÇna souboru
Inst3:   jcxz      Inst42
         stosb
         lodsb                              ; naáten° dal®°ho znaku jmÇna
         dec       cx
         cmp       al," "                   ; je mezera ?
         je        Inst41                   ; konec textu
         cmp       al,9                     ; je tabel†tor ?
         je        Inst41                   ; tabel†tor - konec
         cmp       al,"/"
         jne       Inst3                    ; dal®° znak
Inst41:  dec       si                       ; n†vrat posledn°ho znaku
Inst42:  mov       byte ptr ds:[si],0       ; ukonáovac° 0

                                          ;* vytvo©en° souboru





                                          ;* instalace programu





Chyba:   mov       dx,offset HlpTxt         ; text n†povàdy
         call      DispTxt                  ; zobrazen° textu n†povàdy
         int       20h                      ; konec programu

                                          ;* instalace programu
Inst6:


; -----------------------------------------------------------------------------
;        Odinstalov†n° programu
; -----------------------------------------------------------------------------

UnInst:  mov       cx,es                    ; segment odinstalov†vanÇho progr.
         mov       ax,cs                    : segment tohoto programu
         cmp       ax,cx                    ; je nainstalov†n ?
         je        UnInst5                  ; nebyl nainstalov†n

                                          ;* kontrola, zda jsou vektory OK
         mov       ax,3508h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       dx,es
         cmp       dx,cx                    ; souhlas° segment ?
         jne       UnInst4                  ; segment nesouhlas°
         mov       ax,3509h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       dx,es
         cmp       dx,cx                    ; souhlas° segment ?
         jne       UnInst4                  ; segment nesouhlas°
         mov       ax,3528h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       dx,es
         cmp       dx,cx                    ; souhlas° segment ?
         jne       UnInst4                  ; segment nesouhlas°

                                          ;* program lze odinstalovat
         mov       es,cx                    ; n†vrat segmentu k odinstalov†n°
         mov       ax,



                                          ;* chyba - program nelze odinstalovat
UnInst4: mov       dx,offset DeinsErr       ; text chyby - nelze odinstalovat
         call      DispTxt                  ; zobrazen° textu chyby
UnInst5: int       20h                      ; konec programu

;
;
;
;                                           ;* instalace obsluh p©eru®en°
;         cli                                ; z†kaz p©eru®en°
;         mov       ax,3508h                 ; funkce poskytnut° adresy INT 08h
;         int       21h                      ; poskytnut° adresy INT 08h
;         mov       word ptr [old8],bx       ; uloëen° offsetu adresy
;         mov       word ptr [old8+2],es     ; uloëen° segmentu adresy
;         mov       dx,offset int8           ; vlastn° obsluha INT 08h
;         mov       ax,2508h                 ; funkce nastaven° adresy INT 08h
;         int       21h                      ; nastaven° adresy INT 08h
;
;         mov       ax,3509h                 ; funkce poskytnut° adresy INT 09h
;         int       21h                      ; poskytnut° adresy INT 09h
;         mov       word ptr [old9],bx       ; uloëen° offsetu adresy
;         mov       word ptr [old9+2],es     ; uloëen° segmentu adresy
;         mov       dx,offset int9           ; vlastn° obsluha INT 09h
;         mov       ax,2509h                 ; funkce nastaven° adresy INT 09h
;         int       21h                      ; nastaven° adresy INT 09h
;
;         mov       ax,3513h                 ; funkce poskytnut° adresy INT 13h
;         int       21h                      ; poskytnut° adresy INT 13h
;         mov       word ptr [old13],bx      ; uloëen° offsetu adresy
;         mov       word ptr [old13+2],es    ; uloëen° segmentu adresy
;         mov       dx,offset int13          ; vlastn° obsluha INT 13h
;         mov       ax,2513h                 ; funkce nastaven° adresy INT 13h
;         int       21h                      ; nastaven° adresy INT 13h
;
;         mov       ax,3516h                 ; funkce poskytnut° adresy INT 16h
;         int       21h                      ; poskytnut° adresy INT 16h
;         mov       word ptr [old16],bx      ; uloëen° offsetu adresy
;         mov       word ptr [old16+2],es    ; uloëen° segmentu adresy
;         mov       dx,offset int16          ; vlastn° obsluha INT 16h
;         mov       ax,2516h                 ; funkce nastaven° adresy INT 16h
;         int       21h                      ; nastaven° adresy INT 16h
;
;         mov       ax,3521h                 ; funkce poskytnut° adresy INT 21h
;         int       21h                      ; poskytnut° adresy INT 21h
;         mov       word ptr [old21],bx      ; uloëen° offsetu adresy
;         mov       word ptr [old21+2],es    ; uloëen° segmentu adresy
;         mov       dx,offset int21          ; vlastn° obsluha INT 21h
;         mov       ax,2521h                 ; funkce nastaven° adresy INT 21h
;         int       21h                      ; nastaven° adresy INT 21h
;
;         mov       ah,34h
;         int       21h                      ; poskytnut° p©°znaku aktivity DOS
;         mov       word ptr [akt21],bx      ; adresa p©°znaku aktivity DOS
;         mov       word ptr [akt21+2],es    ; segment p©°znaku aktivity DOS
;
;         sti                                ; povolen° p©eru®en°
;
;         mov       dx,offset uvtxt + 1      ; konec programu
;
;;         JMP       $
;
;         int       27h                      ; rezidentn° ukonáen° programu
;
;
;
;
;
;         int       20h
;


DispTxt  PROC      NER

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP

; *****************************************************************************
;
;                                   Data
;
; *****************************************************************************

UvTxt    db        'PUSHSCR V1.2 - snimani obrazovky; (c) Miroslav Nemecek',13,10,'$'

HlpTxt   db        '======================================================',13,10
         db        'Zadejte: soubor - soubor k ukladani obrazovek',13,10
         db        '         /U     - odinstalovani programu z pameti',13,10
         db        '$'

AdrErr   db        'Chybne zadani adresare !',13,10,'$'
SoubErr  db        'Chybne zadani souboru !',13,10,'$'
ExistErr db        'Soubor jiz existuje - obrazovky budou pripisovany.',13,10,'$'
DeinsErr db        'Program nelze odinstalovat - odinstalujte',13,10
         db        'nejdrive programy nainstalovane za nim !',13,10,'$'

code     ENDS
         END       Start










akt21    dd        0                        ; adresa p©°znaku aktivity DOS

aktint   db        80h                      ; aktivn° p©eru®en°
                                            ; bit 0 = 1 - aktivn° INT 16h
                                            ; bit 1 = 1 - aktivn° INT 09h
                                            ; bit 2 = 1 - aktivn° INT 13h
                                            ; but 3 = 1 - aktivn° INT 21h
                                            ; bit 6 = 1 - prob°h† COPYSCR
                                            ; bit 7 = 0 - poëadavek COPYSCR

old8     dd        0                        ; adresa pñvodn° obsluhy INT 08h
old9     dd        0                        ; adresa pñvodn° obsluhy INT 09h
old13    dd        0                        ; adresa pñvodn° obsluhy INT 13h
old16    dd        0                        ; adresa pñvodn° obsluhy INT 16h
old21    dd        0                        ; adresa pñvodn° obsluhy INT 21h

counter  db        0                        ; odeá°taá áasu

int8:                                       ; obsluha p©eru®en° INT 08h
         pushf
         pushf
         call      dword ptr cs:[old8]      ; pñvodn° obsluha INT 08h
         cmp       byte ptr cs:[counter],0  ; je nàjak† hodnota v á°taái ?
         je        int80                    ; á°taá je pr†zdnò
         dec       byte ptr cs:[counter]    ; sn°ëen° á°taáe
int80:   test      cs:[aktint],0ffh         ; m† probàhnout COPYSCR ?
         jnz       int81                    ; neprobàhne COPYSCR
         push      es                       ; £schova ES
         push      bx                       ; £schova BX
         les       bx,cs:[akt21]            ; adresa p©°znaku aktivity DOS
         cmp       byte ptr es:[bx],0       ; je DOS aktivn° ?
         pop       bx                       ; n†vrat BX
         pop       es                       ; n†vrat ES
         jnz       int81                    ; DOS je aktivn°
         or        cs:[aktint],0c0h         ; p©°znak, ëe prob°h† COPYSCR
         push      ax
         mov       al,cs:[hkey]             ; startovac° kl†vesa
         mov       cs:[pared],al            ; p©°znak editace
         pop       ax
         sti                                ; povolen° p©eru®en°
         call      copyscr                  ; uloëen° obsahu obrazovky
         cli                                ; z†kaz p©eru®en°
         and       cs:[aktint],0bfh         ; p©°znak, ëe neprob°h† COPYSCR
int81:   popf
retfar   proc      far
         sti
         ret       2
retfar   endp


int9:                                       ; obsluha p©eru®en° INT 09h
         pushf
         or        cs:[aktint],2            ; nastaven° p©°znaku obsluhy INT 09h
         push      bx                       ; £schova BX
         push      ds                       ; £schova DS
         push      ax                       ; £schova AX
         mov       bx,40h                   ; segment dat BIOS
         mov       ds,bx                    ; segment dat BIOS
         mov       bx,word ptr ds:[1ch]     ; ukl†dac° adresa do bufferu znakñ
         mov       byte ptr cs:[hotkey],1   ; p©°znak - nen° <Print Screen>
         in        al,[60h]                 ; áten° k¢du kl†vesy
         cmp       al,37h                   ; je kl†vesa <Print Screen> ?
         jne       int90                    ; nen° kl†vesa <Print Screen>
         test      byte ptr ds:[17h],4      ; je p©esmykaá <Ctrl> ?
         jz        int90                    ; nen° p©esmykaá <Ctrl>
         inc       byte ptr cs:[hotkey]     ; p©°znak - <Ctrl>-<Print Screen>
         test      byte ptr ds:[17h],3      ; je nàkterò <Shift> ?
         jz        int90                    ; nen° ë†dnò <Shift>
         inc       byte ptr cs:[hotkey]     ; = <Ctrl>-<Shift>-<Print Screen>
int90:   pushf
         call      dword ptr cs:[old9]      ; pñvodn° obsluha INT 09h
         cmp       bx,word ptr ds:[1ch]     ; byl p©ijat znak ?
         je        int91                    ; nebyl p©ijat ë†dnò znak
         dec       byte ptr cs:[hotkey]     ; kl†vesa <Ctrl>-<Print Screen> ?
         jz        int91                    ; nebylo <Ctrl>-<Print Screen>
         mov       al,cs:[hotkey]           ; k¢d kl†vesy
         dec       al
         mov       cs:[hkey],al             ; £schova parametru kl†ves
         and       cs:[aktint],7fh          ; nastaven° poëadavku COPYSCR
         mov       word ptr ds:[1ch],bx     ; zru®en° p©ijatÇ kl†vesy
int91:   pop       ax                       ; n†vrat AX
         pop       ds                       ; n†vrat DS
         pop       bx                       ; n†vrat BX
         and       cs:[aktint],0fdh         ; zru®en° p©°znaku obsluhy INT 09h
         jmp       int80

hotkey   db        0                        ; 1=je kl†vesa <Print Screen>
hkey     db        0                        ; £schova parametru HOTKEY

int13:                                      ; obsluha p©eru®en° INT 13h
         or        cs:[aktint],4            ; nastaven° p©°znaku obsluhy INT 13h
         pushf
         call      dword ptr cs:[old13]     ; pñvodn° obsluha INT 13h
         pushf
         and       cs:[aktint],0fbh         ; zru®en° p©°znaku oblsluhy INT 13h
         jmp       int80

int16:                                      ; obsluha p©eru®en° INT 16h
         or        byte ptr cs:[aktint],1   ; nastaven° p©°znaku obsluhy INT 16h
         pushf
         call      dword ptr cs:[old16]     ; pñvodn° obsluha INT 16h
         pushf
         and       byte ptr cs:[aktint],0feh ; zru®en° p©°znaku oblsluhy INT 16h
         jmp       int80

int21:                                      ; obsluha p©eru®en° INT 21h
         or        byte ptr cs:[aktint],8   ; nastaven° p©°znaku obsluhy INT 21h
         pushf
         call      dword ptr cs:[old21]     ; pñvodn° obsluha INT 21h
         pushf
         and       byte ptr cs:[aktint],0f7h ; zru®en° p©°znaku oblsluhy INT 21h
         jmp       int80

edit:                                       ; editace vò©ezu okna
                                            ; VùSTUP: CY=p©eru®en° s <ESC>
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         push      cs
         pop       ds

         mov       ax,ds:[maxsir]           ; ®°©ka obrazu
         cmp       ax,ds:[sircut]           ; kontrola ®°©ky vò©ezu
         jb        edit00
         cmp       ax,ds:[pozcut]           ; kontrola pozice vò©ezu
         jb        edit00
         cmp       ds:[sircut],0
         je        edit00                   ; ®°©ka = 0
         mov       ax,ds:[maxvys]           ; vò®ka obrazu
         cmp       ax,ds:[vyscut]           ; kontrola vò®ky vò©ezu
         jb        edit00
         cmp       ax,ds:[radcut]           ; kontrola ©†dku vò©ezu
         jb        edit00
         cmp       ds:[vyscut],0            ; vò®ka = 0
         jne       edit01
edit00:
         mov       ax,ds:[maxsir]           ; ®°©ka obrazu
         shr       ax,1                     ; AX/2
         mov       ds:[sircut],ax           ; ®°©ka vò©ezu
         shr       ax,1                     ; AX/4
         mov       ds:[pozcut],ax           ; pozice vò©ezu

         mov       ax,ds:[maxvys]           ; vò®ka obrazu
         shr       ax,1                     ; AX/2
         mov       ds:[vyscut],ax           ; vò®ka vò©ezu
         shr       ax,1                     ; AX/4
         mov       ds:[radcut],ax           ; ©†dek vò©ezu

edit01:                                     ; kontrola mez° vò©ezu
         cmp       ds:[pozcut],0            ; kontrola poá†teán° pozice
         jnl       edit011                  ; nen° z†porn†
         mov       ds:[pozcut],0
edit011: cmp       ds:[radcut],0            ; kontrola ©†dku vò©ezu
         jnl       edit012                  ; nen° z†pornò
         mov       ds:[radcut],0
edit012: cmp       ds:[sircut],1            ; kontrola ®°©ky vò©ezu
         jnl       edit013                  ; nen° z†porn†
         mov       ds:[sircut],1
edit013: cmp       ds:[vyscut],1            ; kontrola vò®ky vò©ezu
         jnl       edit014                  ; nen° z†porn†
         mov       ds:[vyscut],1

edit014: mov       ax,ds:[maxsir]           ; maxim†ln° pozice
         cmp       ds:[pozcut],ax           ; kontrola pozice
         jl        edit015
         mov       ds:[pozcut],ax
         dec       word ptr ds:[pozcut]
edit015: sub       ax,ds:[pozcut]
         cmp       ds:[sircut],ax           ; kontrola ®°©ky
         jle       edit016
         mov       ax,ds:[maxsir]
         sub       ax,ds:[sircut]
         jge       edit0151
         xor       ax,ax
edit0151:mov       ds:[pozcut],ax
         mov       ax,ds:[maxsir]
         cmp       ds:[sircut],ax
         jle       edit016
         mov       ds:[sircut],ax
edit016: mov       ax,ds:[maxvys]           ; vò®ka obrazu
         cmp       ax,ds:[radcut]           ; kontrola ©†dku
         jnl       edit017
         mov       ds:[radcut],ax
         dec       word ptr ds:[radcut]
edit017: sub       ax,ds:[radcut]
         cmp       ds:[vyscut],ax           ; kontrola vò®ky vò©ezu
         jle       edit018
         mov       ax,ds:[maxvys]
         sub       ax,ds:[vyscut]
         jge       edit0171
         xor       ax,ax
edit0171:mov       ds:[radcut],ax
         mov       ax,ds:[maxvys]
         cmp       ds:[vyscut],ax
         jle       edit018
         mov       ds:[vyscut],ax
edit018:

edit1:   cmp       byte ptr [counter],0     ; je jië dosaëeno 0 ?
         jne       edit2                    ; nen° je®tà 0
         call      kurzor                   ; zapnut° kurzoru
         mov       byte ptr [counter],2     ; doba pro vypnutò displej
         cmp       byte ptr [setkurz],0     ; je kurzor nastaven ?
         je        edit2                    ; nen° nastaven
         mov       byte ptr [counter],12    ; doba pro rozsv°cenò displej
edit2:   mov       ah,11h
         int       16h
         jz        edit1                    ; nen° stisknuta ë†dn† kl†vesa
         mov       ah,10h                   ; funkce vstupu znaku z kl†vesnice
         int       16h                      ; vstup znaku z kl†vesnice
edit20:  push      ax
         mov       cx,16
edit21:  mov       ah,1
         int       16h
         jz        edit22
         xor       ah,ah
         int       16h
edit22:  loop      edit21                   ; vypr†zdnàn° bufferu kl†vesnice
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[417h]             ; statut p©esmykaáñ
         pop       ds
         mov       ds:[setshf],al           ; nastaven° p©esmykaáñ
         pop       ax
         mov       byte ptr [counter],0     ; zastaven° mà©en° áasu
         cmp       byte ptr [setkurz],0     ; je kurzor zobrazen ?
         je        edit3                    ; kurzor nen° zobrazen
         call      kurzor
edit3:   mov       cx,1                     ; p©°rustek pro posuv
         test      byte ptr ds:[setshf],4   ; je stisknut <Ctrl> ?
         jz        edit300                  ; nen° <Ctrl>
         mov       cx,10                    ; p©°rustek s <Ctrl>
edit300: cmp       ah,8dh                   ; je kurzor nahoru ?
         je        edit302
         cmp       ah,48h                   ; je kurzor nahoru ?
         jne       edit30                   ; nen° kurzor nahoru
edit302: test      byte ptr ds:[setshf],3   ; je nastaven <Shift> ?
         jz        edit301                  ; nen° <Shift>
         sub       ds:[vyscut],cx
         jmp       edit01
edit301: sub       ds:[radcut],cx           ; sn°ëen° okna
         jmp       edit01
edit30:  cmp       ah,91h                   ; je kurzor dolñ ?
         je        edit303
         cmp       ah,50h                   ; je kurzor dolñ ?
         jne       edit31                   ; nen° kurzor dolñ
edit303: test      byte ptr ds:[setshf],3   ; je nastaven <Shift> ?
         jz        edit311                  ; nen° <Shift>
         add       ds:[vyscut],cx
         jmp       edit01
edit311: add       ds:[radcut],cx           ; zvò®en° okna
         jmp       edit01
edit31:  cmp       ah,73h                   ; kurzor vlevo ?
         je        edit310
         cmp       ah,4bh                   ; kurzor vlevo ?
         jne       edit32
edit310: test      byte ptr ds:[setshf],3   ; je nastaven <Shift> ?
         jz        edit321                  ; nen° <Shift>
         sub       ds:[sircut],cx
         jmp       edit01
edit321: sub       ds:[pozcut],cx           ; zkr†cen° okna
         jmp       edit01
edit32:  cmp       ah,74h                   ; kurzor vpravo ?
         je        edit320
         cmp       ah,4dh                   ; kurzor vpravo ?
         jne       edit33
edit320: test      byte ptr ds:[setshf],3   ; je nastaven <Shift> ?
         jz        edit331                  ; nen° <Shift>
         add       ds:[sircut],cx
         jmp       edit01
edit331: add       ds:[pozcut],cx           ; prodlouëen° okna
         jmp       edit01
edit33:

edit4:   cmp       al,13                    ; je kl†vesa <Enter> ?
         je        edit9
         cmp       al,27                    ; je kl†vesa <Esc> ?
         stc
         je        edit9
         jmp       edit01

edit9:   mov       ax,ds:[sircut]           ; ®°©ka vò©ezu
         mov       ds:[sirka],ax
         mov       ax,ds:[vyscut]
         mov       ds:[vyska],ax
         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

setkurz  db        0                        ; p©°znak: 1=je zobrazen kurzor
setshf   db        0                        ; nastaven° p©esmykaáñ
                                            ;  bit 0 - pravò <Shift>
                                            ;  bit 1 - levò <Shift>
                                            ;  bit 2 - <Ctrl>
                                            ;  bit 3 - <Alt>

kurzor:                                     ; zapnut°/vypnut° zobrazen° kurzoru
         mov       bx,ds:[radcut]           ; poá†teán° ©†dek vò©ezu
         call      linex                    ; horn° horizont†ln° linka
         cmp       ds:[vyscut],1
         jna       kurzor1
         add       bx,ds:[vyscut]           ; koneánò ©†dek vò©ezu
         dec       bx
         call      linex                    ; spodn° horizont†ln° linka
kurzor1: mov       dx,ds:[pozcut]           ; poá†teán° pozice vò©ezu
         call      liney                    ; levò sloupce
         cmp       ds:[sircut],1
         jna       kurzor2
         add       dx,ds:[sircut]           ; koneán† pozice vò©ezu
         dec       dx
         call      liney
kurzor2: xor       byte ptr [setkurz],1     ; zmàna kurzoru
         ret

linex:                                      ; vykreslen° horizont†ln° linky
                                            ; VSTUP: BX=©†dek
         cmp       cs:[mod],3               ; je videom¢d 3 nebo men®° ?
         ja        linexg                   ; nen° textovò m¢d
         push      ax
         push      bx
         push      cx
         push      dx
         push      es
         mov       dx,ds:[pozcut]           ; poá†teán° pozice vò©ezu okna
         mov       cx,ds:[sircut]           ; ®°©ka vò©ezu
         or        cx,cx
         jne       linex0
         inc       cx
linex0:  mov       ax,0b800h                ; segment VRAM
         mov       es,ax
         mov       di,ds:[adrvideo]         ; poá†teán° adresa displeje
         or        bx,bx                    ; je ©†dek 0 ?
         jz        linex2                   ; je ©†dek
linex1:  add       di,ds:[maxsir]           ; ®°©ka obrazu
         add       di,ds:[maxsir]           ; ®°©ka obrazu
         dec       bx
         jnz       linex1                   ; dal®° ©†dek
linex2:  add       di,dx
         add       di,dx                    ; poá†teán° pozice vò©ezu
         inc       di                       ; adresa atributu
linex3:  mov       al,es:[di]               ; atribut
         rol       al,1
         rol       al,1
         rol       al,1
         rol       al,1
         stosb
         inc       di
         loop      linex3
         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

linexg:                                     ; vykreslen° graf. horizont. linky
                                            ; VSTUP: BX=©†dek

         cmp       cs:[mod],13              ; je videom¢d 13 nebo vàt®° ?
         jb        linexx                   ; nen° m¢d EGA
         cmp       cs:[mod],16              ; je videom¢d 16 nebo men®° ?
         ja        linexx                   ; nen° m¢d EGA
         push      ax
         push      bx
         push      cx
         push      dx
         push      es
         mov       dx,ds:[pozcut]           ; poá†teán° pozice vò©ezu okna
         mov       cx,ds:[sircut]           ; ®°©ka vò©ezu
         or        cx,cx
         jne       linexg0
         inc       cx
linexg0: mov       ax,0a000h                ; segment VRAM
         mov       es,ax
         mov       di,ds:[adrvideo]         ; poá†teán° adresa displeje
         or        bx,bx                    ; je ©†dek 0 ?
         jz        linexg2                  ; je ©†dek
linexg1: add       di,ds:[maxsir]           ; ®°©ka obrazu
         dec       bx
         jnz       linexg1                  ; dal®° ©†dek
linexg2: add       di,dx                    ; poá†teán° pozice vò©ezu
linexg3: call      invb                     ; inverze bajtu
         inc       di
         loop      linexg3
         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

linexx:  ret


invb:                                       ; inverze bajtu v grafice
                                            ; VSTUP: ES:DI=adresa bajtu

         mov       ah,1                     ; rovina 0
         xor       bl,bl
         call      invmap                   ; inverze bodu na str†nce
         mov       ah,2                     ; rovina 1
         inc       bl
         call      invmap                   ; inverze bodu na str†nce
         cmp       cs:[mod],15              ; je videom¢d 2 barvy ?
         je        invb0                    ; je videom¢d 2 barvy
         mov       ah,4                     ; rovina 2
         inc       bl
         call      invmap                   ; inverze bodu na str†nce
         mov       ah,8                     ; rovina 3
         inc       bl
         call      invmap                   ; inverze bodu na str†nce
invb0:   ret


invmap:                                     ; inverze bajtu na str†nce VRAM
         cli

         mov       dx,03c4h
         mov       al,2
         out       dx,al                    ; registr maskovac° mapy
         inc       dx
         mov       al,ah
         out       dx,al                    ; maska pro z†pis

         mov       dx,03ceh
         mov       al,0
         out       dx,al                    ; registr m¢du áten° a z†pisu
         inc       dx
         mov       al,ah
         out       dx,al                    ; m¢d 0 pro áten°

;         dec       dx
;         mov       al,1
;         out       dx,al                    ; registr m¢du áten° a z†pisu
;         inc       dx
;         mov       al,0
;         out       dx,al                    ; m¢d 0 pro áten°

;         dec       dx
;         mov       al,2
;         out       dx,al                    ; registr m¢du áten° a z†pisu
;         inc       dx
;         mov       al,ah
;         out       dx,al                    ; m¢d 0 pro áten°

         dec       dx
         mov       al,3
         out       dx,al                    ; registr m¢du áten° a z†pisu
         inc       dx
         mov       al,0
         out       dx,al                    ; m¢d 0 pro áten°

         dec       dx
         mov       al,4
         out       dx,al                    ; registr átec° mapy
         inc       dx
         mov       al,bl
         out       dx,al                    ; á°slo mapy pro áten°

         dec       dx
         mov       al,5
         out       dx,al                    ; registr m¢du áten° a z†pisu
         inc       dx
         mov       al,0
         out       dx,al                    ; m¢d 0 pro áten°

         dec       dx
         mov       al,8
         out       dx,al                    ; registr m¢du áten° a z†pisu
         inc       dx
         mov       al,0ffh
         out       dx,al                    ; m¢d 0 pro áten°

         nop
         xor       byte ptr es:[di],0ffh

         sti
         ret




liney:                                      ; vykreslen° vertik†ln° linky
                                            ; VSTUP: DX=pozice
         cmp       cs:[mod],3               ; je videom¢d 3 nebo men®° ?
         ja        lineyg                   ; nen° textovò m¢d
         push      ax
         push      bx
         push      cx
         push      dx
         push      es
         mov       bx,ds:[radcut]           ; poá†teán° ©†dek vò©ezu okna
         inc       bx
         mov       cx,ds:[vyscut]           ; vò®ka vò©ezu
         jcxz      liney4
         dec       cx
         jcxz      liney4
         dec       cx
         jcxz      liney4
         mov       ax,0b800h                ; segment VRAM
         mov       es,ax
         mov       di,ds:[adrvideo]         ; poá†teán° adresa displeje
         or        bx,bx                    ; je ©†dek 0 ?
         jz        liney2                   ; je ©†dek 0
liney1:  add       di,ds:[maxsir]           ; ®°©ka obrazu
         add       di,ds:[maxsir]           ; ®°©ka obrazu
         dec       bx
         jnz       liney1                   ; dal®° ©†dek
liney2:  add       di,dx
         add       di,dx                    ; poá†teán° pozice vò©ezu
         inc       di                       ; adresa atributu
liney3:  mov       al,es:[di]               ; atribut
         rol       al,1
         rol       al,1
         rol       al,1
         rol       al,1
         stosb
         dec       di
         add       di,ds:[maxsir]
         add       di,ds:[maxsir]
         loop      liney3
liney4:  pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

lineyg:                                     ; vykreslen° graf. vertik†ln° linky
                                            ; VSTUP: BX=©†dek

         cmp       cs:[mod],13              ; je videom¢d 13 nebo vàt®° ?
         jb        lineyx                   ; nen° m¢d EGA
         cmp       cs:[mod],16              ; je videom¢d 16 nebo men®° ?
         ja        lineyx                   ; nen° m¢d EGA
         push      ax
         push      bx
         push      cx
         push      dx
         push      es
         mov       bx,ds:[radcut]           ; poá†teán° ©†dek vò©ezu okna
         inc       bx
         mov       cx,ds:[vyscut]           ; vò®ka vò©ezu
         jcxz      lineyg4
         dec       cx
         jcxz      lineyg4
         dec       cx
         jcxz      lineyg4
         mov       ax,0a000h                ; segment VRAM
         mov       es,ax
         mov       di,ds:[adrvideo]         ; poá†teán° adresa displeje
         or        bx,bx                    ; je ©†dek 0 ?
         jz        lineyg2                  ; je ©†dek 0
lineyg1: add       di,ds:[maxsir]           ; ®°©ka obrazu
         dec       bx
         jnz       lineyg1                  ; dal®° ©†dek
lineyg2: add       di,dx                    ; poá†teán° pozice vò©ezu
lineyg3: call      invb                     ; inverze bajtu
         add       di,ds:[maxsir]
         loop      lineyg3
lineyg4: pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

lineyx:  ret

pared    db        0                        ; 1=parametr, ëe je editace
                                           ;* parametry aktu†ln°ho vò©ezu
pozcut   dw        0                        ; poá†teán° pozice vò©ezu
sircut   dw        0                        ; ®°©ka vò©ezu
radcut   dw        0                        ; poá†teán° ©†dek vò©ezu
vyscut   dw        0                        ; vò®ka vò©ezu




copyscr:                                    ; kopie displeje do souboru
         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si
         push      di
         push      ds
         push      es

         mov       ax,0                     ; segment 0
         mov       ds,ax                    ; segment 0
         mov       al,ds:[449h]             ; aktivn° videom¢d
         and       al,7fh
         mov       cs:[mod],al              ; aktivn° videom¢d
         mov       ax,ds:[44eh]             ; poá†teán° adresa displeje
         push      cs
         pop       ds                       ; DS <- CS
         mov       [adrvideo],ax            ; poá†teán° adresa displeje
                                           ;* nastaven° parametrñ v tabulce
         mov       si,offset tabdim         ; tabulka rozmàrñ displeje
         xor       bh,bh                    ; BH <- 00
         mov       bl,ds:[mod]              ; videom¢d
         cmp       bl,16                    ; kontrola max. á°sla videom¢du
         jna       open20                   ; je zn†mò videom¢d
         mov       bl,3                     ; je nezn†mò videom¢d
open20:  add       bx,bx                    ; BX * 2
         add       bx,bx                    ; BX * 4
         add       si,bx                    ; adresa videom¢du
         lodsw                              ; horizont†ln° rozmàr
         mov       [sirka],ax               ; ®°©ka displeje
         mov       [maxsir],ax              ; maxim†ln° ®°©ka ©†dku
         lodsw                              ; vertik†ln° rozmàr
         mov       [vyska],ax               ; vò®ka displeje
         mov       [maxvys],ax              ; maxim†ln° vò®ka displeje
         mov       word ptr [pozcut],0      ; poá†teán° pozice vò©ezu
         mov       word ptr [radcut],0      ; poá†teán° ©†dek vò©ezu
                                            ;* zvukov† signalizace
         mov       cx,6
copsc1:  push      cx
         in        al,[61h]
         or        al,3
         out       [61h],al
         mov       cx,8000
         loop      $
         and       al,0fch
         out       [61h],al
         mov       cx,15000
         cmp       byte ptr [pared],0
         je        copsc3
         mov       cx,40000
copsc3:  loop      $
         pop       cx
         loop      copsc1

         mov       ax,'RC'
         mov       word ptr [soubor0-3],ax  ; pñvodn° jmÇno souboru

         cmp       byte ptr [pared],0       ; je m¢d editace ?
         je        open                     ; nen° editace
         call      edit                     ; editace
         jnc       open                     ; editace OK
         jmp       copsc9                   ; p©eru®en° funkce

open:    mov       ah,4eh                   ; nalezen° souboru
         mov       cx,0                     ; atributy souboru
         mov       dx,offset soubor         ; jmÇno souboru
         int       21h                      ; otev©en° souboru
         jc        open2                    ; soubor nenalezen - OK
         mov       si,offset soubor0 - 1    ; konec jmÇna souboru
open1:   call      incsoub                  ; zvò®en° á°slice souboru
         jc        open1                    ; p©enos na dal®° znak
         cmp       byte ptr [si],"0"        ; je prvn° z á°slic 0 ?
         jne       open                     ; nen° á°slice "0"
         mov       byte ptr [si],"1"        ; nastaven° na á°slici "1"
         jmp       short open               ; test, zda je soubor v adres†©i
open2:   mov       ah,3ch                   ; funkce vytvo©en° souboru
         mov       cx,0                     ; atributy souboru
         mov       dx,offset soubor         ; specifikace souboru
         int       21h                      ; vytvo©en° souboru
         jnc       open200                  ; nen° chyba otev©en° souboru
         jmp       copsc9                   ; chyba vytvo©en° souboru
open200: mov       ds:[idents],ax           ; identifik†tor souboru

         mov       ah,40h                   ; funkce z†pisu do souboru
         mov       dx,offset ident          ; identifikace souboru
         mov       cx,konhl - ident         ; dÇlka z†hlav° souboru
         mov       bx,ds:[idents]           ; identifik†tor souboru
         int       21h                      ; z†pis z†hlav° do souboru
         mov       byte ptr ds:[pareq],0    ; p©°znak - je norm†ln° m¢d
         mov       byte ptr ds:[kompc],0    ; nulov†n° bufferu
         mov       byte ptr ds:[citeq],0    ; nulov†n° bufferu shodnòch bajtñ

         mov       al,ds:[mod]              ; videom¢d
         cmp       al,3                     ; je textovò m¢d ?
         ja        zap1                     ; nen° textovò m¢d
                                           ;* z†pis standardn°ho textovÇho m¢du
         push      ds
         mov       ax,0b800h
         mov       ds,ax                    ; segment videopamàti
         call      writet                   ; z†pis textovÇ obrazovky
         jmp       copsc8                   ; konec z†pisu do souboru


zap1:
         cmp       al,16
         ja        zap3
         cmp       al,13
         jb        zap3                     ; nen° videom¢d 13
open21:
         push      ds                       ; £schova DS
         mov       ax,0a000h                ; segment videopamàti
         mov       ds,ax                    ; segment videopamàti
         xor       bl,bl
         call      writemap                 ; z†pis str†nky do souboru
         mov       bl,1
         call      writemap                 ; z†pis str†nky do souboru
         cmp       cs:[mod],15              ; je videom¢d 2 barvy ?
         je        copsc8                   ; je videom¢d 2 barvy
         mov       bl,2
         call      writemap                 ; z†pis str†nky do souboru
         mov       bl,3
         call      writemap                 ; z†pis str†nky do souboru
         jmp       copsc8

zap3:
         jmp       copsc80

copsc8:  stc                                ; p©°znak konce dat
         call      writek                   ; vypr†zdnàn° bufferu dat
         pop       ds                       ; n†vrat DS
copsc80: mov       ah,3eh                   ; funkce uzav©en° identifik†toru
         mov       bx,ds:[idents]           ; identifik†tor souboru
         int       21h                      ; uzav©en° souboru
copsc9:
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


incsoub:                                    ; zvò®en° jmÇna souboru
                                            ; VSTUP: DS:SI=ukazatel znaku

         dec       si                       ; sn°ëen° ukazatele
         cmp       si,offset soubor0 - 5    ; je ukazatel na zak†zanÇ pozici ?
         jne       incsou0                  ; ukazatel nen° na zak†zanÇ pozici
         dec       si                       ; p©eskoáen° pozice
incsou0: mov       al,[si]                  ; znak k zvò®en°
         cmp       al,"0"                   ; je platn† á°slice ?
         cmc                                ; negace CF
         ja        incsou1                  ; je znak men®° neë "0"
         cmp       al,"9"                   ; je platn† á°slice nebo "9" ?
         ja        incsou1                  ; je znak vàt®° neë "9"
         inc       al                       ; zvò®en° á°slice
         cmp       al,"9"                   ; zñstala platn† á°slice ?
         je        incsou2                  ; je á°slice "9" - OK
         cmc                                ; negace CF
         ja        incsou2                  ; je platn† á°slice
incsou1: mov       al,"0"                   ; nov† á°slice
incsou2: mov       [si],al                  ; uloëen° novÇho znaku
         ret                                ; CY=je p©enos na vy®®° á°slici

writemap:                                   ; z†pis str†nky do souboru
         mov       dx,03ceh
         mov       al,4
         out       dx,al                    ; registr átec° mapy
         inc       dx
         mov       al,bl                    ; rovina ke áten°
         out       dx,al

         push      si
         push      cx
         mov       si,cs:[adrvideo]         ; poá†teán° adresa obr†zku
         mov       cx,cs:[radcut]           ; poá†teán° ©†dek vò©ezu
         jcxz      writem01
writem00:add       si,cs:[maxsir]
         loop      writem00
writem01:add       si,cs:[pozcut]           ; poá†teán° pozice vò©ezu
         pop       cx
         call      writesc                  ; z†pis obrazovky
         pop       si
         ret


writet:                                     ; z†pis textovÇ obrazovky

         push      cx
         push      si
         mov       si,cs:[adrvideo]         ; poá†teán° adresa obr†zku
         mov       cx,cs:[radcut]           ; poá†teán° ©†dek vò©ezu
         jcxz      writet01
writet00:add       si,cs:[maxsir]
         add       si,cs:[maxsir]
         loop      writet00
writet01:add       si,cs:[pozcut]           ; poá†teán° pozice vò©ezu
         add       si,cs:[pozcut]

         mov       cx,cs:[vyska]            ; poáet linek k z†pisu
writet1: push      si                       ; £schova SI - ukazatel dat
         push      cx                       ; £schova á°taáe linek
         mov       cx,cs:[sirka]            ; poáet bajtñ na ©†dek
writet2: lodsb                              ; bajt k z†pisu
         inc       si                       ; zvò®en° adresy o atribut
         clc                                ; nulov†n° p©°znaku CF
         call      writek                   ; z†pis bajtu do souboru
         loop      writet2                  ; dal®° bajt k z†pisu
         pop       cx                       ; n†vrat á°taáe linek
         pop       si                       ; n†vrat ukazatele dat SI
         add       si,cs:[maxsir]           ; adresa dal®° linky
         add       si,cs:[maxsir]           ; dal®° linka
         loop      writet1                  ; z†pis dal®° linky
         pop       si                       ; adresa obrazovky

         push      si
         mov       si,cs:[adrvideo]         ; poá†teán° adresa obr†zku
         mov       cx,cs:[radcut]           ; poá†teán° ©†dek vò©ezu
         jcxz      writet21
writet20:add       si,cs:[maxsir]
         add       si,cs:[maxsir]
         loop      writet20
writet21:add       si,cs:[pozcut]           ; poá†teán° pozice vò©ezu
         add       si,cs:[pozcut]

         inc       si                       ; poá†teán° adresa + 1
         mov       cx,cs:[vyska]            ; poáet linek k z†pisu
writet3: push      si                       ; £schova SI - ukazatel dat
         push      cx                       ; £schova á°taáe linek
         mov       cx,cs:[sirka]            ; poáet bajtñ na ©†dek
writet4: lodsb                              ; bajt k z†pisu
         inc       si                       ; zvò®en° adresy o atribut
         clc                                ; nulov†n° p©°znaku CF
         call      writek                   ; z†pis bajtu do souboru
         loop      writet4                  ; dal®° bajt k z†pisu
         pop       cx                       ; n†vrat á°taáe linek
         pop       si                       ; n†vrat ukazatele dat SI
         add       si,cs:[maxsir]           ; adresa dal®° linky
         add       si,cs:[maxsir]           ; dal®° linka
         loop      writet3                  ; z†pis dal®° linky
         pop       si
         pop       cx
         ret

writesc:                                    ; z†pis grafickÇ obrazovky
                                            ; VSTUP: DS:SI=adresa obrazu
         push      si
         push      cx
         mov       cx,cs:[vyska]            ; poáet linek k z†pisu
writes1: push      si                       ; £schova SI - ukazatel dat
         push      cx                       ; £schova á°taáe linek
         mov       cx,cs:[sirka]            ; poáet bajtñ na ©†dek
writes2: lodsb                              ; bajt k z†pisu
         clc                                ; nulov†n° p©°znaku CF
         call      writek                   ; z†pis bajtu do souboru
         loop      writes2                  ; dal®° bajt k z†pisu
         pop       cx                       ; n†vrat á°taáe linek
         pop       si                       ; n†vrat ukazatele dat SI
         add       si,cs:[maxsir]           ; adresa dal®° linky
         loop      writes1                  ; z†pis dal®° linky
         pop       cx
         pop       si
         ret


writek:                                     ; z†pis bajtu v kompresn°m m¢du
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;        CY=nen° dal®° bajt

         jc        writek0                  ; vypr†zdnàn° bufferñ
         test      byte ptr cs:[verze],1    ; je kompresn° m¢d ?
         jnz       writek1                  ; je kompresn° m¢d
         jmp       writeb                   ; z†pis bajtu bez komprese

writek0: test      byte ptr cs:[verze],1    ; je kompresn° m¢d ?
         stc
         jnz       writek1                  ; je kompresn° m¢d
         jmp       writeb                   ; z†pis bajtu bez komprese
writek1: push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         jnc       writek5                  ; nen° vypr†zdnàn° bufferu
                                           ;* vyppr†zdnàn° bufferñ
         call      flush                    ; vypr†zdnàn° obou bufferñ
         stc                                ; p©°znak nulov†n° bufferñ
         call      writeb                   ; nulov†n° bufferu
         jmp       writek8                  ; n†vrat z obsluhy

writek5: cmp       byte ptr ds:[citeq],0    ; je nàjakò shodnò bajt ?
         jne       writek2                  ; v bufferu je jië nàjakò bajt
         mov       byte ptr ds:[byteeq],al  ; uloëen° shodnÇho bajtu
         inc       byte ptr ds:[citeq]      ; zvò®en° á°taáe shodnòch bajtñ
         jmp       writek8                  ; n†vrat

writek2: cmp       byte ptr ds:[byteeq],al  ; je shoda bajtu ?
         jne       writek3                  ; nen° shodnò bajt
         inc       byte ptr ds:[citeq]      ; zvò®en° poátu shodnòch bajtñ
         cmp       byte ptr ds:[citeq],255  ; je dosaëeno plnÇho poátu bajtñ ?
         jnz       writek8                  ; nen° je®tà dosaëeno poátu bajtñ
         call      flush                    ; vypr†zdnàn° obou bufferñ
         jmp       short writek8            ; n†vrat

writek3: cmp       byte ptr ds:[citeq],3    ; je dostateánò poáet bajtñ ?
         jb        writek30                 ; nen° dostateánò poáet bajtñ
         call      flush                    ; vypr†zdnàn° obou bufferñ
         jmp       short writek32           ; uloëen° novÇho bajtu
writek30:call      transeq                  ; vypr†zdnàn° bufferu shodnòch dat
writek32:mov       ds:[byteeq],al           ; uloëen° novÇho bajtu
         inc       byte ptr ds:[citeq]      ; zvò®en° á°taáe shodnòch bajtñ
writek8: pop       es
         pop       ds
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

transeq:                                    ; p©evod shodnòch bajtñ do bufferu
         push      ax
         push      di
         push      cx
         xor       cx,cx
         mov       cl,byte ptr ds:[citeq]   ; poáet shodnòch bajtñ
         jcxz      transe3                  ; nen° ë†dnò bajt v bufferu
         mov       al,ds:[byteeq]           ; shodnò bajt
transe0: call      storb                    ; uloëen° bajtu AL do bufferu
         loop      transe0                  ; dal®° bajt
         mov       byte ptr ds:[citeq],cl   ; nulov†n° poátu shodnòch bajtñ
transe3: pop       cx
         pop       di
         pop       ax
         ret

storb:                                      ; uloëen° bajtu AL do bufferu
         push      di
         mov       di,word ptr ds:[kompc]   ; poáet bajtñ v bufferu
         and       di,0ffh
         add       di,offset kompb          ; adresa k uloëen° bajtu
         stosb                              ; uloëen° bajtu do bufferu
         inc       byte ptr ds:[kompc]      ; zvò®en° á°taáe bajtñ v bufferu
         cmp       byte ptr ds:[kompc],255  ; dosaëeno plnÇho bufferu ?
         jne       storb0                   ; nen° je®tà plnò buffer
         call      flushb                   ; vypr†zdnàn° bufferu
storb0:  pop       di
         ret

flush:                                      ; vypr†zdnàn° obou bufferñ
         call      flushb                   ; vypr†zdnàn° norm†ln°ho bufferu
                                            ; n†sleduje vypr†zdnàn° bufferu
                                            ; shodnòch bajtñ

flusheq:                                    ; vypr†zdnàn° bufferu shodnòch bajtñ
         push      ax
         cmp       byte ptr ds:[citeq],0    ; je nàjakò bajt v bufferu ?
         je        flushe2                  ; v bufferu nen° ë†dnò bajt
         cmp       byte ptr ds:[pareq],1    ; je kompresn° m¢d ?
         je        flushe0                  ; je kompresn° m¢d
         xor       al,al
         call      writeb                   ; z†pis bajtu pro p©epnut° m¢du
flushe0: mov       al,ds:[citeq]            ; poáet shodnòch bajtñ
         mov       byte ptr ds:[pareq],1    ; p©°znak - je kompresn° m¢d
         cmp       al,255                   ; je trvalò m¢d ?
         je        flushe1                  ; je trvalò m¢d
         dec       byte ptr ds:[pareq]      ; p©°znak - je norm†ln° m¢d
flushe1: clc
         call      writeb                   ; z†pis poátu bajtñ
         mov       al,ds:[byteeq]           ; shodnò bajt
         clc
         call      writeb                   ; z†pis shodnÇho bajtu
         mov       byte ptr ds:[citeq],0    ; vynulov†n° bufferu shodnòch bajtñ
flushe2: pop       ax
         ret

flushb:                                     ; vypr†zdnàn° bufferu bajtñ
         push      ax
         push      si
         push      cx
         xor       cx,cx
         mov       cl,ds:[kompc]            ; poáet bajtñ v bufferu
         jcxz      flushb3                  ; v bufferu nen° ë†dnò bajt
         cmp       byte ptr ds:[pareq],0    ; je norm†ln° m¢d ?
         je        flushb0                  ; je norm†ln° m¢d
         xor       al,al
         call      writeb                   ; z†pis bajtu pro p©epnut° m¢du
flushb0: mov       byte ptr ds:[pareq],0    ; p©°znak - je norm†ln° m¢d
         cmp       cl,255                   ; je trvalò m¢d ?
         je        flushb1                  ; nen° trvalò m¢d
         inc       byte ptr ds:[pareq]      ; p©°znak - je kompresn° m¢d
flushb1: mov       si,offset kompc          ; poáet bajtñ + buffer bajtñ dat
         inc       cx                       ; + poáet bajtñ
flushb2: lodsb                              ; bajt k vòstupu
         clc
         call      writeb                   ; z†pis bajtu do souboru
         loop      flushb2                  ; z†pis dal®°ho bajtu
         mov       byte ptr ds:[kompc],0    ; vynulov†n° bufferu shodnòch bajtñ
flushb3: pop       cx
         pop       si
         pop       ax
         ret


citeq    db        0                        ; á°taá shodnòch bajtñ
byteeq   db        0                        ; uschovanò shodnò bajt

pareq    db        0                        ; parametr 1=je kompresn° m¢d

kompc    db        0                        ; á°taá rozd°lnòch bajtñ v bufferu
                                            ; 0 = zmàna m¢du - nen° ë†dnò bajt
                                            ; 1 aë 254 = zmàna m¢du s daty
                                            ;  - v norm. m¢du poáet n†sl. bajtñ
                                            ;  - v kompr. m¢du poáet opakov†n°
                                            ;    n†sleduj°c°ho bajtu
                                            ; 255 = n†sleduje 255 bajtñ beze
                                            ;  zmàny stavu (jinak jako 1 aë 255)
                                            ; (data zaá°naj° norm†ln°m stavem)

kompb    db        255 dup(0)               ; buffer rozd°lnòch bajtñ dat
                                            ; (mus° n†sledovat za KOMPC)

writeb:                                     ; z†pis bajtu do souboru
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;        CY=nen° dal®° bajt

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         mov       di,ds:[adrbyte]          ; adresa k uloëen° bajtu
         jc        writeb1                  ; je konec dat - uloëen°
         inc       word ptr ds:[adrbyte]    ; zvò®en° adresy k uloëen° bajtu
         stosb                              ; uloëen° bajtu
         cmp       di,offset sektor0        ; je konec bufferu ?
         jb        writeb3                  ; nen° je®tà konec bufferu - n†vrat
writeb1: sub       di,offset sektor         ; poá†teán° adresa bufferu
         jz        writeb3                  ; nen° ë†dnò bajt k uloëen°
         mov       cx,di                    ; poáet bajtñ k z†pisu
         mov       bx,ds:[idents]           ; identifikace souboru
         mov       dx,offset sektor         ; adresa bufferu s daty
         mov       ah,40h                   ; funkce z†pisu do souboru
         int       21h                      ; z†pis sektoru do souboru
         mov       di,offset sektor         ; zaá†tek bufferu dat
         mov       ds:[adrbyte],di          ; nov† adresa k ukl†d†n° dat
writeb3: pop       es
         pop       ds
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

adrbyte  dw        sektor                   ; adresa k uloëen° bajtu
sektor   db        512 dup(0)               ; buffer sektoru
sektor0:                                    ; konec bufferu sektoru

ident    db        'SCR'                    ; identifikace souboru displeje
verze    db        1                        ; verze souboru
                                            ;  bit 0 = je kompresn° m¢d
mod      db        0                        ; aktu†ln° videom¢d displeje
sirka    dw        40                       ; ®°©ka ©†dku displeje (znakñ)
vyska    dw        200                      ; vò®ka displeje (linek)
konhl:                                      ; konec z†hlav° souboru

adrvideo dw        0                        ; poá†teán° adresa zobrazenÇ str†nky
maxsir   dw        0                        ; maxim†ln° ®°©ka ©†dku (znakñ)
maxvys   dw        0                        ; maxim†ln° vò®ka ©†dku
rovin    db        0                        ; poáet rovin

soubor   db        'SCREEN.SCR',0           ; jmÇno souboru
soubor0:                                    ; konec jmÇna souboru

idents   dw        0                        ; identifikace vòstupn°ho souboru

tabdim:                                     ; tabulka rozmàrñ videom¢dñ
         dw        40,25                    ; 0 = text 40x25/16 (B800h)
         dw        40,25                    ; 1 = text 40x25/16,8 (B800h)
         dw        80,25                    ; 2 = text 80x25/16 (B800h)
         dw        80,25                    ; 3 = text 80x25/16,8 (B800h)
         dw        40,200                   ; 4 = grafika 320x200/4 (B800h)
         dw        40,200                   ; 5 = grafika 320x200/4 (B800h)
         dw        80,200                   ; 6 = grafika 640x200/2 (B800h)
         dw        80,25                    ; 7 = text 80x25/2 (B000h)
         dw        20,200                   ; 8 = grafika 160x200/16 (B000h)
         dw        40,200                   ; 9 = grafika 320x200/16 (B000h)
         dw        80,200                   ; 10 = grafika 640x200/4 (B000h)
         dw        80,25                    ; 11 = rezervov†no
         dw        80,25                    ; 12 = rezervov†no
         dw        40,200                   ; 13 = grafika 320x200/16 (A000h)
         dw        80,200                   ; 14 = grafika 640x200/16 (A000h)
         dw        80,350                   ; 15 = grafika 640x350/2 (A000h)
         dw        80,350                   ; 16 = grafika 640x350/16 (A000h)




uvtxt    db        'Driver pro uloëen° obsahu videopamàti do souboru.',13,10
         db        'Aktivace kl†vesami <Ctrl>-<Print Screen> nebo',13,10
         db        '<Shift>-<Ctrl>-<Print Screen> (vò©ez obrazovky).',13,10,10
         db        'Vò©ez: kurzorovÇ kl†vesy+<Shift>+<Ctrl>;<Enter>;<Esc>'
         db        13,10,10,'$'

ask      db        13,10,'Ukl†dat data v kompresn°m tvaru (1=ano) ?',13,10,'$'

code     ENDS


         END       start                    ; startovac° adresa

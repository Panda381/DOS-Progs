
; *****************************************************************************
;
;                        Z mek pro diskov‚ jednotky
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:   jmp       Instal                   ; instalace programu

Identif  db        'DISKLOCK V1.10'         ; identifika‡n¡ text
Identif0 label     byte                     ; konec identifika‡n¡ho textu

RezSeg   dw        0                        ; adresa rezidentn¡ instalace

; -----------------------------------------------------------------------------

Flop     db        1                        ; Floppy: 0 = neblokovano
                                            ;         1 = zapis do BOOT
                                            ;         2 = zapis
                                            ;         3 = pristup na disk

Winch    db        1                        ; Winchst:0 = neblokovano
                                            ;         1 = zapis do BOOT
                                            ;         2 = zapis
                                            ;         3 = pristup na disk

Klav     db        1                        ; p©¡znak zapnut¡ kl vesnice

Zvuk     db        1                        ; p©¡znak zapnut¡ zvuku

; -----------------------------------------------------------------------------

Old09    dd        0                        ; p–vodn¡ adresa INT 09h
Old13    dd        0                        ; p–vodn¡ adresa INT 13h
Old40    dd        0                        ; p–vodn¡ adresa INT 40h

; -----------------------------------------------------------------------------

Int09    PROC      FAR

         push      bx
         push      ds
         mov       bx,40h
         mov       ds,bx
         mov       bx,ds:[1ch]

         pushf
         call      dword ptr cs:[old09]

         cmp       byte ptr cs:[Klav],1     ; je povoleno ovl d n¡ kl vesnic¡ ?
         jne       Int093                   ; nen¡ povoleno ovl d n¡ kl vesnic¡

         cmp       bx,ds:[1ch]              ; byla nˆjak  kl vesa ?
         je        Int093                   ; nebyla ‘ dn  kl vesa

                                          ;* test p©esmyka‡– Shft-Alt
         test      byte ptr ds:[17h],3      ; je p©esmyka‡ SHIFT ?
         jz        Int093                   ; nen¡ p©esmyka‡ SHIFT
         test      byte ptr ds:[17h],8      ; je p©esmyka‡ ALT ?
         jz        Int093                   ; nen¡ p©esmyka‡ ALT

                                          ;* test kl ves Alt-F1 a‘ Alt-F8
         cmp       byte ptr ds:[bx+1],68h   ; je kl vesa Alt-F1 ?
         jb        Int093                   ; nen¡ platn  kl vesa
         cmp       byte ptr ds:[bx+1],6fh   ; je kl vesa Alt-F8 ?
         ja        Int093                   ; nen¡ platn  kl vesa
         mov       ds:[1ch],bx              ; zru¨en¡ kl vesy z bufferu

                                          ;* nastaven¡ k¢du kl vesy
         mov       bx,ds:[bx]               ; k¢d kl vesy
         sub       bh,68h                   ; korekce na ‡¡slo 0 a‘ 7
         cmp       bh,4                     ; nastaven¡ pro pevn˜ disk ?
         jae       Int092                   ; nastaven¡ pro pevn˜ disk
         call      Beep                     ; zvukov  signalizace odezvy
         mov       cs:[Flop],bh             ; k¢d pro diskety
         jmp       short Int093
Int092:  sub       bh,4                     ; nastaven¡ pro pevn˜ disk
         call      Beep                     ; zvukov  signalizace odezvy
         mov       cs:[Winch],bh            ; k¢d pro pevn˜ disk

Int093:  pop       ds
         pop       bx
         iret

Int09    ENDP

; -----------------------------------------------------------------------------

Beep     PROC      NEAR

         cmp       byte ptr cs:[Zvuk],1
         jne       Beep2

         push      ax
         push      bx
         push      cx

         mov       cx,35000

         mov       al,0b6h
         out       [43h],al
         mov       al,6
         sub       al,bh
         out       [42h],al
         out       [42h],al

         in        al,[61h]
         push      ax
         or        al,3
         out       [61h],al

         loop      $

         pop       ax
         out       [61h],al

         pop       cx
         pop       bx
         pop       ax

Beep2:   RET

Beep     ENDP

; -----------------------------------------------------------------------------

Int13    PROC      FAR

         pushf

         cmp       ah,8
         jne       Int133
         cmp       dl,26h                   ; kontroln¡ ‡¡slo disku
         jne       Int133

         push      cx
         push      si
         push      di
         push      es

         push      cs
         pop       es
         cld
         mov       cx,offset(Identif0-Identif) ; d‚lka textu
         mov       si,offset Identif        ; identifika‡n¡ text
         mov       di,si
         repe      cmpsb                    ; porovn n¡ text–

         pop       es
         pop       di
         pop       si
         pop       cx
         jne       Int133                   ; text nesouhlas¡
         mov       ds:[RezSeg],cs           ; rezidentn¡ segment

Int133:  popf

         call      Blok                     ; test blokov n¡ funkce
         jmp       dword ptr cs:[Old13]

Int13    ENDP

; -----------------------------------------------------------------------------

Int40    PROC      FAR

         call      Blok
         jmp       dword ptr cs:[Old40]

Int40    ENDP

; -----------------------------------------------------------------------------

                                          ;* test blokov n¡ funkce
                                          ;* - v z sobn¡ku nesm¡ b˜t nic jin‚ho
                                          ;*   ne‘ n vratov  adresa NEAR !

Blok     PROC      NEAR

                                            ; SS:[BP+8] = F
                                            ; SS:[BP+6] = CS
                                            ; SS:[BP+4] = IP
                                            ; SS:[BP+2] = IP

         push      bp                       ; £schova BP SS:[BP+0]
         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         push      ax                       ; £schova AX SS:[BP-2]

                                          ;* povolen‚ funkce
         cmp       ah,1                     ; je reset diskov‚ho syst‚mu ?
         jbe       Blok7                    ; reset disk– nebo dotaz na stav
         cmp       ah,8                     ; je poskytnut¡ parametr– ?
         je        Blok7                    ; poskytnut¡ parametr– - OK
         cmp       ah,9                     ; inic. tabulky pevn‚ho disku ?
         je        Blok7                    ; inic. tabulky pevn‚ho disku - OK
         cmp       ah,0dh                   ; reset disku ?
         jae       Blok7                    ; slu‘ba se nekontroluje

                                          ;* p©¡znak stavu disku
         mov       al,cs:[Flop]             ; p©¡znaky FLOPPY
         or        dl,dl                    ; je p©¡stup na FLOPPY ?
         jns       Blok1                    ; je p©¡stup na FLOPPY
         mov       al,cs:[Winch]            ; p©¡znaky pevn‚ho disku

                                          ;* disk nen¡ blokov n
Blok1:   or        al,al                    ; je nˆjak‚ blokov n¡ ?
         jz        Blok7                    ; disk nen¡ blokov n - n vrat

                                          ;* zak z n z pis do BOOT sektoru
         dec       al                       ; je z kaz z pisu do BOOT ?
         jnz       Blok2                    ; nen¡ z kaz z pisu do BOOT

         cmp       ah,3                     ; je z pis sektor– na disk ?
         je        Blok11                   ; je z pis na disk
         cmp       ah,0bh                   ; je dlouh˜ z pis ?
         je        Blok11                   ; je dlouh˜ z pis
         cmp       ah,5                     ; form tov n¡ stopy ?
         je        Blok13                   ; form tov n¡
         cmp       ah,6
         je        Blok13                   ; form tov n¡ s ozna‡en¡m
         cmp       ah,7
         jne       Blok7                    ; nen¡ form tov n¡ disku
Blok13:  jmp       short Blok12             ; nekontroluje se sektor

                                          ;* kontrola sektoru p©i z pisu BOOT
Blok11:  mov       al,cl                    ; ‡¡slo sektoru
         and       al,3fh                   ; ‡¡slo sektoru
         dec       al
         jnz       Blok7                    ; nen¡ BOOT sektor - OK

                                          ;* kontrola v lce a hlavy BOOT
Blok12:  or        ch,ch                    ; ni‘¨¡ slovo v lce = 0 ?
         jnz       Blok7                    ; nen¡ z pis na stopu 0
         or        dh,dh                    ; hlava = 0 ?
         jnz       Blok7                    ; nen¡ z pis na stopu 0
         mov       al,cl                    ; vy¨¨¡ ‡ st ‡¡sla v lce
         and       al,0c0h                  ; nejvy¨¨¡ 2 bity ‡¡sla v lce
         jnz       Blok7                    ; nen¡ stopa 0
         jmp       short Blok31             ; je z pis do BOOT sektoru - chyba

                                          ;* p©¡stup na disk blokov n
Blok4:   mov       ah,80h                   ; k¢d chyby - disk nep©ipraven
         jmp       short Blok32             ; n vrat s chybou


Blok7:   pop       ax
         pop       bp
         ret

                                          ;* zak z n z pis na disk
Blok2:   dec       al                       ; je z kaz z pisu na disk ?
         jnz       Blok4                    ; nen¡ z kaz z pisu na disk
         cmp       ah,3                     ; je funkce z pisu na disk ?
         je        Blok31                   ; je funkce z pisu na disk - z kaz
         cmp       ah,5                     ; je funkce form tov n¡ ?
         jb        Blok7                    ; nen¡ form tov n¡ - OK
         cmp       ah,7                     ; je form tov n¡ ?
         jbe       Blok31                   ; je form tov n¡ - z kaz
         cmp       ah,0bh                   ; je dlouh˜ z pis
         jne       Blok7                    ; nen¡ dlouh˜ z pis - OK

                                          ;* chyba - ochrana proti z pisu
Blok31:  mov       ah,3                     ; k¢d chyby - ochrana proti z pisu

                                          ;* chyba - p©¡stup nepovolen
Blok32:  xor       al,al                    ; ‘ dn˜ sektor
         mov       word ptr ss:[bp-2],ax    ; n vratov˜ k¢d chyby

         or        word ptr ss:[bp+8],201h  ; p©¡znak p©eru¨en¡ a chyby CY

                                          ;* ulo‘en¡ k¢du chyby do pamˆti BIOS
         push      ds
         push      bx
         xor       bx,bx
         mov       ds,bx                    ; DS <- BX
         or        dl,dl
         js        Blok37                   ; je pevn˜ disk
         mov       ds:[441h],ah             ; stav pro disketov‚ jednotky
         jmp       short Blok38
Blok37:  mov       ds:[474h],ah             ; stav pro pevn˜ disk
Blok38:  pop       bx
         pop       ds

                                          ;* zvukov  signalizace
         cmp       byte ptr cs:[Zvuk],1
         jne       Blok35

         push      cx
         mov       cx,18000
         mov       al,0b6h
         out       [43h],al
         mov       al,2
         out       [42h],al
         out       [42h],al
         in        al,[61h]
         mov       ah,al
         or        al,3
         out       [61h],al
         loop      $
         mov       al,ah
         out       [61h],al
         pop       cx
Blok35:
         pop       ax                       ; n vrat AX
         pop       bp                       ; n vrat BP
         add       sp,2                     ; zru¨en¡ n vratov‚ adresy
         iret                               ; n vrat z obsluhy


Blok     ENDP

; -----------------------------------------------------------------------------
;        Instalace programu
; -----------------------------------------------------------------------------

                                          ;* zobrazen¡ £vodn¡ho textu
Instal:  mov       dx,offset uvtxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

                                          ;* nalezen¡ rezidentn¡ instalace
         mov       ds:[RezSeg],ds           ; segment rezidentn¡ ‡ sti
         mov       dl,26h                   ; kontroln¡ ‡¡slo disku
         mov       ah,8                     ; funkce poskytnut¡ parametr–
         int       13h                      ; test stavu instalace
         mov       es,ds:[RezSeg]           ; segment s rezidentn¡ ‡ st¡

                                          ;* p©¡prava pro rozbor zad n¡
         mov       si,81h                   ; za‡ tek p©¡kaz. © dku
         xor       bx,bx                    ; BH <- 0
         mov       bl,ds:[80h]              ; po‡et znak– textu
         mov       byte ptr ds:[si+bx],0    ; ozna‡en¡ konce textu

                                          ;* na‡ten¡ prvn¡ho znaku
Instal1: call      InpCh                    ; vstup znaku z parametr–
         jc        Instal4                  ; konec textu - instalace
         je        Instal1                  ; ignorov n¡ mezer

                                          ;* parametr "Kn" - nastav. kl vesnice
         cmp       al,"K"                   ; je parametr "K" ?
         jne       Instal13                 ; nen¡ parametr "K"
         call      InpCh                    ; na‡ten¡ znaku parametru
         jbe       Instal3                  ; chyba zad n¡ parametru
         sub       al,"0"                   ; korekce na ‡¡slo
         jc        Instal3                  ; chyba zad n¡
         cmp       al,1
         ja        Instal3                  ; chyba zad n¡
         mov       es:[Klav],al             ; p©¡znak kl vesnice
         jmp       short Instal1            ; dek¢dov n¡ dal¨¡ho parametru


                                          ;* parametr "Sn" - zvuk. signal.
Instal13:cmp       al,"S"                   ; je parametr "S" ?
         jne       Instal14                 ; nen¡ parametr "S"
         call      InpCh                    ; na‡ten¡ znaku parametru
         jbe       Instal3                  ; chyba zad n¡ parametru
         sub       al,"0"                   ; korekce na ‡¡slo
         jc        Instal3                  ; chyba zad n¡
         cmp       al,1
         ja        Instal3                  ; chyba zad n¡
         mov       es:[Zvuk],al             ; p©¡znak signalizac
         jmp       short Instal1            ; dek¢dov n¡ dal¨¡ho parametru

                                          ;* volba "X" - odinstalovani programu
Instal14:cmp       al,"X"                   ; je parametr "X" ?
         jne       Instal17
         jmp       Odinstal                 ; odinstalovani programu z pameti

                                          ;* ‡¡slo 1 a‘ 8 (p©ep¡na‡)
Instal17:sub       al,"1"                   ; korekce na ‡¡slo
         jc        Instal3                  ; chyba zad n¡
         cmp       al,8
         jae       Instal3                  ; chyba zad n¡
         cmp       al,4
         jae       Instal15                 ; je pevn˜ disk
         mov       es:[Flop],al             ; nastaven¡ disket. mechanik
         jmp       short Instal1            ; dal¨¡ parametr
Instal15:sub       al,4
         mov       es:[Winch],al            ; pevn˜ disk
         jmp       short Instal1            ; dal¨¡ parametr

                                          ;* je zobrazen¡ n povˆdy
Instal3: mov       dx,offset HelpTxt        ; text n povˆdy
         mov       ah,9
         int       21h                      ; zobrazen¡ n povˆdy
Instal5: int       20h                      ; program se neinstaluje


                                          ;* hl ¨en¡ o stavu instalace
Instal4: mov       al,es:[Flop]             ; p©¡znak pro FLOPPY
         add       byte ptr ds:[HelpT1],al  ; ‡¡slo pro FLOPPY
         mov       al,es:[Winch]            ; p©¡znak pro pevn˜ disk
         add       byte ptr ds:[HelpT1+2],al; ‡¡slo pro FLOPPY
         mov       al,es:[Klav]             ; p©¡znak aktivity kl vesnice
         add       byte ptr ds:[HelpT1+5],al; aktivita kl vesnice
         mov       al,es:[Zvuk]             ; pr¡znak aktivity zvuku
         add       byte ptr ds:[HelpT1+8],al; aktivita zvukov‚ signalizace
         mov       dx,offset HelpTxt1       ; text n povˆdy
         mov       ah,9
         int       21h                      ; zobrazen¡ n povˆdy

         mov       ax,ds
         mov       bx,es
         cmp       ax,bx                    ; je to prvn¡ instalace ?
         jne       Instal5                  ; nen¡ to prvn¡ instalace - konec

                                          ;* instalace obsluhy INT 09h
         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es
         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

                                          ;* instalace obsluhy INT 13h
         mov       ax,3513h
         int       21h
         mov       word ptr ds:[Old13],bx
         mov       word ptr ds:[Old13+2],es
         mov       dx,offset Int13
         mov       ax,2513h
         int       21h

                                          ;* instalace obsluhy INT 40h
         mov       ax,3540h
         int       21h
         mov       word ptr ds:[Old40],bx
         mov       word ptr ds:[Old40+2],es
         mov       dx,offset Int40
         mov       ax,2540h
         int       21h

         mov       ah,49h
         mov       es,ds:[2ch]
         int       21h                      ; uvolnˆn¡ bloku prost©ed¡

         mov       dx,offset Instal
         int       27h

; -----------------------------------------------------------------------------

                                          ;* odinstalovani programu z pameti
Odinstal:
                                          ;* kontrola, zda jsou vektory OK
         mov       dx,es                    ; £schova ES
         mov       ax,cs
         cmp       ax,dx
         je        OdInst7                  ; nebyl nainstalov n

         push      es
         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       cx,es                    ; segment adresy INT 09h
         pop       es
         cmp       cx,dx                    ; souhlas¡ segment adresy ?
         jne       Odinst8                  ; adresa nesouhlas¡

         push      es
         mov       ax,3513h
         int       21h                      ; poskytnut¡ adresy INT 13h
         mov       cx,es                    ; segment adresy INT 13h
         pop       es
         cmp       cx,dx                    ; souhlas¡ segment adresy ?
         jne       Odinst8                  ; adresa nesouhlas¡

         push      es
         mov       ax,3540h
         int       21h                      ; poskytnut¡ adresy INT 40h
         mov       cx,es                    ; segment adresy INT 40h
         pop       es
         cmp       cx,dx                    ; souhlas¡ segment adresy ?
         jne       Odinst8                  ; adresa nesouhlas¡

                                          ;* program lze odinstalovat
         lds       dx,es:[Old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h
         lds       dx,es:[Old13]            ; p–vodn¡ adresa INT 13h
         mov       ax,2513h
         int       21h                      ; n vrat adresy INT 13h
         lds       dx,es:[Old40]            ; p–vodn¡ adresa INT 40h
         mov       ax,2540h
         int       21h                      ; n vrat adresy INT 40h
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ aloka‡n¡ho bloku pamˆti
         mov       dx,offset UvolTxt
         jmp       short Odinst9            ; hl ¨en¡ o odinstalov n¡

                                          ;* program nebyl nainstalov n
OdInst7: mov       dx,offset Uvol1Txt
         jmp       short OdInst9

                                          ;* program nelze odinstalovat
Odinst8: mov       dx,offset Uvol0Txt
Odinst9: push      cs
         pop       ds
         mov       ah,9
         int       21h
         int       20h

; -----------------------------------------------------------------------------

InpCh    PROC      NEAR

         mov       al,ds:[si]               ; znak z textu tad n¡

                                          ;* korekce na velk  p¡smena
         cmp       al,"a"
         jb        InpCh1                   ; nen¡ mal‚ p¡smeno
         cmp       al,"z"
         ja        InpCh1                   ; nen¡ mal‚ p¡smeno
         sub       al,32                    ; korekce na velk‚ p¡smeno

                                          ;* n hrada tabel toru mezerou
InpCh1:  cmp       al,9
         jne       InpCh2
         mov       al," "

                                          ;* kontrola, zda je konec textu
InpCh2:  cmp       al," "
         jb        InpCh3
         inc       si                       ; zv˜¨en¡ ukazatele textu
         cmp       al," "

InpCh3:  ret

InpCh    ENDP

; -----------------------------------------------------------------------------

UvTxt    db        'DISKLOCK V 1.10 - uzamceni disku;  (c) Miroslav Nemecek',13,10
         db        '$'

HelpTxt  db        '=======================================================',13,10
         db        'ÚÄÄ diskety ÄÄÄÂÄ pevny disk ÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '³ Shift-Alt-F1 ³ Shift-Alt-F5 ³ plny pristup na disk  ³',13,10
         db        '³ Shift-Alt-F2 ³ Shift-Alt-F6 ³ zakaz modifikace BOOT ³',13,10
         db        '³ Shift-Alt-F3 ³ Shift-Alt-F7 ³ zakaz zapisu na disk  ³',13,10
         db        '³ Shift-Alt-F4 ³ Shift-Alt-F8 ³ disk nepristupny      ³',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
         db        'Zadejte:   1 az 8 = jako klavesy Shift-Alt-F1 ... F8',13,10
         db        '           K0, K1 = ovladani z klavesnice VYP, ZAP',13,10
         db        '           S0, S1 = zvukova signalizace VYP, ZAP',13,10
         db        '           X      = odinstalovani programu DISKLOCK',13,10
         db        '$'

HelpTxt1 db        'Soucasne nastaveni: DISKLOCK '
HelpT1   db        '1 5 K0 S0   (? = napoveda)',13,10
         db        '$'

UvolTxt  db        'DISKLOCK byl odinstalovan z pameti.',13,10,'$'
Uvol0Txt db        'DISKLOCK nelze odinstalovat - odinstalujte nejdrive',13,10
         db        '         programy nainstalovane po nem.',13,10,'$'
Uvol1Txt db        'DISKLOCK nebyl dosud nainstalovan !',13,10,'$'

code     ends
         end       start

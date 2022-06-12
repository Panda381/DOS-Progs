
; *****************************************************************************
;
;                             S  H  O  W  S
;                         gener tor demonstrac¡
;
; *****************************************************************************

KodExt0  EQU       0                        ; roz¨¡©en˜ k¢d 0
KodExt1  EQU       0e0h                     ; roz¨¡©en˜ k¢d 1
KodExt2  EQU       0f0h                     ; roz¨¡©en˜ k¢d 2
KodDel   EQU       7fh                      ; kl vesa Delete

KodSpeed EQU       0fch                     ; k¢d pro nastaven¡ rychlosti
KodDelay EQU       0fdh                     ; k¢d pro prodlevu
KodRep   EQU       0feh                     ; k¢d pro opakov n¡ znaku
KodAlt   EQU       0ffh                     ; k¢d zadan˜ s Alt- (vy¨¨¡ bajt=0)
                                            ; sou‡asnˆ k¢d pro p©esmyka‡e

code     segment
         assume    cs:code,ds:code
         org       100h

Start:   jmp       Instal                   ; start a instalace programu

Ident    db        'SHOWS V1.10'
Ident0   label     byte

SegRez   dw        0                        ; segment rezidentn¡ ‡ sti

; -----------------------------------------------------------------------------
old08    dd        0                        ; p–vodn¡ adresa INT 08h
old09    dd        0                        ; p–vodn¡ adresa INT 09h
old16    dd        0                        ; p–vodn¡ adresa INT 16h

SizBuff  dw        0                        ; velikost bufferu
AdrBuf   dw        offset Buffer            ; adresa bufferu
MaxBuf   dw        0                        ; po‡et bajt– v bufferu
UkazBuf  dw        0                        ; ukazatel bajt– v bufferu

CitDem   dw        0                        ; ‡¡ta‡ demonstrac¡
Progr    db        0                        ; 1=p©¡znak programov n¡
Demons   db        0                        ; 1=p©¡znak demonstrac¡
Real     db        0                        ; 1=p©¡znak re ln‚ho re‘imu

Presmyk  db        0ffh                     ; uschovan˜ stav p©esmyka‡–

CitRep   db        0                        ; ‡¡ta‡ opakov n¡ znak–
CharRep  dw        0                        ; poslednˆ zadan˜ znak

Cekej    db        0                        ; p©¡znak mˆ©en¡ ‡ek n¡
Citac    db        0                        ; ‡¡ta‡ prodlevy

Speed    db        0                        ; celkov  rychlost

; -----------------------------------------------------------------------------
;        Obsluha INT 16h - test stavu instalace
; -----------------------------------------------------------------------------

Int16    PROC      FAR

         cmp       ax,3217h
         jne       Int162

         pushf
         push      cx
         push      si
         push      di
         push      es
         push      cs
         pop       es
         mov       si,offset Ident          ; identifika‡n¡ text
         mov       di,si
         mov       cx,offset(Ident0-Ident)  ; d‚lka identifika‡n¡ho textu
         cld
         repe      cmpsb                    ; porovn n¡ text–
         jne       Int161                   ; texty nejsou shodn‚
         mov       ds:[SegRez],cs           ; segment rezidentn¡ ‡ sti
Int161:  pop       es
         pop       di
         pop       si
         pop       cx
         popf

Int162:  jmp       dword ptr cs:[Old16]     ; p–vodn¡ obsluha INT 16h

Int16    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         push      ax
         push      bx
         push      ds


         cmp       byte ptr cs:[Real],0     ; je re ln˜ re‘im ?
         je        Int0801                  ; nen¡ re ln˜ re‘im

                                          ;* zah jen¡ mˆ©en¡ doby ‡ek n¡
         cmp       byte ptr cs:[Cekej],1    ; prob¡h  mˆ©en¡ prodlevy ?
         je        Int0801                  ; prob¡h  mˆ©en¡ prodlevy
         mov       byte ptr cs:[Cekej],1    ; p©¡znak ‡ek n¡
         mov       byte ptr cs:[Citac],0    ; inicializace ‡¡ta‡e prodlevy

Int0801: cmp       byte ptr cs:[Cekej],1    ; prob¡h  mˆ©en¡ doby prodlevy ?
         jne       Int0809                  ; neprob¡h  mˆ©en¡ doby prodlevy

         inc       byte ptr cs:[Citac]      ; zv˜¨en¡ ‡¡ta‡e ‡asu
         jnz       Int0803                  ; nen¡ p©ete‡en¡ ‡¡ta‡e
         inc       byte ptr cs:[Citac]      ; inicializace ‡¡ta‡e na 1
         mov       ax,0ff00h + KodDelay     ; konstanta pro maxim ln¡ ‡as
         call      UlozKex                  ; ulo‘en¡ k¢du znaku
Int0803: jmp       Int089

                                          ;* obsluha ‡¡ta‡e ‡ek n¡
Int0809: cmp       byte ptr cs:[Citac],0    ; je ‡¡ta‡ ji‘ = 0 ?
         je        int081                   ; ‡¡ta‡ je ji‘ = 0
         dec       byte ptr cs:[Citac]
         jnz       Int0803                  ; m  se je¨tˆ ‡ekat

                                          ;* test, zda je demonstrace
int081:  cmp       byte ptr cs:[Demons],1   ; je demonstrace ?
         jne       Int0803                  ; nen¡ demonstrace

                                          ;* test, zda m–‘e b˜t dal¨¡ znak
         mov       bx,40h
         mov       ds,bx                    ; segment BIOS
         mov       bx,ds:[1ch]              ; ukl dac¡ adresa do bufferu
         cmp       bx,ds:[1ah]              ; je buffer pr zdn˜ ?
         je        Int082                   ; buffer je pr zdn˜ - m–‘e b˜t znak
         cmp       byte ptr cs:[Speed],0    ; je rychlost = 0 ?
         jne       Int0803                  ; nen¡ rychlost 0
Int084:  push      bx
         call      IncKey                   ; zv˜¨en¡ ukazatele v bufferu kl v.
         cmp       bx,ds:[1ah]              ; bude ji‘ p©eplnˆn¡ bufferu ?
         je        Int0844                  ; zaplnˆn¡ bufferu
         call      IncKey                   ; zv˜¨en¡ ukazatele v bufferu kl v.
         cmp       bx,ds:[1ah]              ; bude ji‘ p©eplnˆn¡ bufferu ?
         je        Int0844                  ; zaplnˆn¡ bufferu
         call      IncKey                   ; zv˜¨en¡ ukazatele v bufferu kl v.
         cmp       bx,ds:[1ah]              ; bude ji‘ p©eplnˆn¡ bufferu ?
Int0844: pop       bx
         je        Int0803                  ; bylo by p©eplnˆn¡ bufferu

                                          ;* m–‘e b˜t dal¨¡ znak
Int082:  call      GetKex                   ; poskytnut¡ kl vesy
         jnc       Int085                   ; je dal¨¡ kl vesa

         mov       bx,cs:[UkazBuf]          ; ukazatel v bufferu
         cmp       bx,cs:[MaxBuf]           ; je na konci bufferu ?
         jb        Int0899                  ; nen¡ na konci bufferu
         cmp       byte ptr cs:[CitRep],0   ; je nˆjak˜ znak k opakov n¡ ?
         jne       Int0899                  ; je je¨tˆ nˆjak˜ znak

         and       byte ptr ds:[17h],not 7fh ; nulov n¡ p©esmyka‡–
         cmp       word ptr cs:[CitDem],1   ; je 1 nebo ‘ dn  demonstrace ?
         jbe       Int0822                  ; jsou ji‘ v¨echny demonstrace

         dec       word ptr cs:[CitDem]     ; sn¡‘en¡ ‡¡ta‡e demonstrac¡
         mov       word ptr cs:[UkazBuf],0  ; ukazatel v bufferu zase na za‡ tek
         mov       bx,ds:[1ch]              ; ukl dac¡ adresa do bufferu
         jmp       short Int082             ; vstup nov‚ kl vesy

Int0822: mov       byte ptr cs:[Demons],0   ; zru¨en¡ p©¡znaku demonstrace
         call      Beep                     ; indika‡n¡ p¡pnut¡
Int0899: jmp       short Int089

Int085:
         mov       ds:[bx],ax               ; ulo‘en¡ k¢du kl vesy
         call      IncKey                   ; zv˜¨en¡ ukazatele v bufferu
         mov       ds:[1ch],bx              ; nov  ukl dac¡ adresa do bufferu

         push      cx
         in        al,[61h]
         or        al,3
         out       [61h],al
         mov       cx,2000                  ; prodleva pro lupnut¡
         loop      $
         and       al,not 3
         out       [61h],al
         pop       cx

         cmp       byte ptr cs:[Speed],0    ; je rychlost 0 ?
         jne       int08802
         jmp       Int084                   ; opakov n¡ a‘ do zaplnˆn¡ bufferu

int08802:mov       al,cs:[Speed]            ; rychlost
         mov       cs:[Citac],al            ; nov  doba pro ‡¡ta‡

int089:
         pop       ds
         pop       bx
         pop       ax

         jmp       dword ptr cs:[old08]

Int08    ENDP


; -----------------------------------------------------------------------------
;        Zv˜¨en¡ ukazatele v bufferu kl vesnice
; -----------------------------------------------------------------------------

IncKey   PROC      NEAR

         inc       bx
         inc       bx
         cmp       bx,3eh                   ; je ji‘ konec bufferu ?
         jb        IncKey1                  ; nen¡ je¨tˆ konec bufferu
         mov       bx,1eh                   ; ukazatel na za‡ tek bufferu
IncKey1: ret

IncKey   ENDP

; -----------------------------------------------------------------------------
;        Vyjmut¡ kl vesy z bufferu s rozk¢dov n¡m (CY=nen¡ nic)
; -----------------------------------------------------------------------------

GetKex   PROC      NEAR


         cmp       byte ptr cs:[CitRep],0   ; je nˆjak˜ znak v bufferu ?
         je        GetKex1                  ; nen¡ ‘ dn˜ znak v bufferu

         mov       ax,cs:[CharRep]          ; znak z bufferu
         dec       byte ptr cs:[CitRep]     ; sn¡‘en¡ ‡¡ta‡e opakov n¡
         jmp       short GetKex11           ; dek¢dov n¡ kl vesy

GetKex1: call      GetKey                   ; vyjmut¡ kl vesy z bufferu
         jc        GetKex7                  ; nen¡ kl vesa

                                          ;* p©esmyka‡e
GetKex11:cmp       al,KodAlt                ; je kl vesa s Alt- ?
         jne       GetKex2                  ; nen¡ kl vesa s Alt-

         cmp       ah,127
         ja        GetKex13                 ; je platn˜ znak
         and       byte ptr ds:[17h],not 7fh ; nulov n¡ p©esmyka‡–
         or        ds:[17h],ah              ; nov˜ stav p©esmyka‡–
         jmp       short GetKex             ; dal¨¡ znak

                                          ;* kl vesa s k¢dem Alt-
GetKex13:mov       al,ah                    ; ASCII k¢d kl vesy
         mov       ah,0                     ; vy¨¨¡ bajt = 0
         jmp       short GetKex5

                                          ;* k¢d pro opakov n¡ znaku
GetKex2: cmp       al,KodRep                ; je k¢d pro opakov n¡ ?
         jne       GetKex3                  ; nen¡ k¢d pro opakov n¡
         mov       byte ptr cs:[CitRep],ah  ; po‡et opakov n¡ znaku
         call      GetKey                   ; poskytnut¡ dal¨¡ kl vesy
         jc        GetKex7                  ; chyba - nen¡ dal¨¡ znak
         mov       cs:[CharRep],ax          ; £schova k¢du kl vesy
         jmp       short GetKex             ; nov‚ dek¢dov n¡ znaku

                                          ;* k¢d pro prodlevu
GetKex3: cmp       al,KodDelay              ; je k¢d pro prodlevu ?
         jne       GetKex4                  ; nen¡ k¢d pro prodlevu
         mov       byte ptr cs:[Citac],ah   ; nastaven¡ doby pro ‡ek n¡
         or        ah,ah                    ; je nˆjak‚ ‡ek n¡ ?
         jz        GetKex                   ; nen¡ ‡ek n¡ - dal¨¡ znak
         stc                                ; p©¡znak, ‘e nen¡ ‘ dn  kl vesa
         jmp       short GetKex7

                                          ;* k¢d pro nastaven¡ rychlosti
GetKex4: cmp       al,KodSpeed              ; je k¢d pro nastaven¡ rychlosti ?
         jne       GetKex5                  ; nen¡ k¢d pro nastaven¡ rychlosti
         mov       byte ptr cs:[Speed],ah   ; £schova k¢du rychlosti
         jmp       short GetKex             ; ‡ten¡ dal¨¡ho znaku

GetKex5: clc

GetKex7: ret

GetKex   ENDP

; -----------------------------------------------------------------------------
;        Vyjmut¡ kl vesy z bufferu (CY=nen¡ nic)
; -----------------------------------------------------------------------------

GetKey   PROC      NEAR

         xor       ax,ax                    ; AX <- 0 p©ednastaven¡
         call      Get                      ; vyjmut¡ ni‘¨¡ho bajtu kl vesy
         jc        GetKey2                  ; nen¡ k¢d
         call      TestExt                  ; je k¢d 2 bajty ?
         cmc
         jnc       GetKey2                  ; je k¢d 1 bajt

         mov       ah,al                    ; £schova ni‘¨¡ho bajtu
         call      Get                      ; na‡ten¡ vy¨¨¡ho bajtu
         xchg      ah,al                    ; n vrat bajt–
         cmp       ax,0a0dh                 ; je od© dkov n¡ textu CR/LF ?
         je        GetKey                   ; je CR/LF - to se ignoruje
         clc

GetKey2: ret

GetKey   ENDP

; -----------------------------------------------------------------------------
;        Vyjmut¡ bajtu z bufferu (CY=nen¡ nic)
; -----------------------------------------------------------------------------

Get      PROC      NEAR

         push      bx
         mov       bx,cs:[UkazBuf]          ; ukazatel bajt– v bufferu
         cmp       bx,cs:[MaxBuf]           ; je ji‘ na konci bufferu ?
         cmc
         jc        Get2                     ; je ji‘ na konci bufferu

         mov       al,cs:[bx+Buffer]        ; vyjmut¡ znaku z bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele
         mov       cs:[UkazBuf],bx          ; nov  hodnota ukazatele

Get2:    pop       bx
         ret

Get      ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

         push      ax
         push      bx
         push      ds

         mov       bx,40h
         mov       ds,bx
         mov       bx,ds:[1ch]              ; p–vodn¡ ukazatel
         pushf
         call      dword ptr cs:[old09]     ; p–vodn¡ obsluha INT 09h

                                          ;* ulo‘en¡ zmˆny p©esmyka‡–
         cmp       byte ptr cs:[Progr],1    ; je programov n¡ ?
         jne       Int0913                  ; nen¡ programov n¡
         mov       al,ds:[17h]              ; stav p©esmyka‡–
         and       al,7fh
         cmp       al,cs:[Presmyk]          ; byly p©esmyka‡e zmˆnˆny ?
         je        Int0913                  ; nebyla zmˆna p©esmyka‡–
         mov       cs:[Presmyk],al          ; £schova nov‚ho stavu

         cmp       byte ptr cs:[Cekej],1    ; prob¡halo mˆ©en¡ prodlevy ?
         jne       Int0911                  ; neprob¡halo mˆ©en¡ prodlevy
         mov       byte ptr cs:[Cekej],0    ; konec mˆ©en¡ prodlevy
         mov       ah,cs:[Citac]            ; namˆ©en  doba
         mov       al,KodDelay              ; k¢d prodlevy
         cmp       ah,0
         je        Int0911

         call      UlozKex                  ; ulo‘en¡ k¢du
Int0911:
         mov       ah,cs:[Presmyk]          ; stav p©esmyka‡–
         mov       al,KodAlt                ; k¢d kl vesy s Alt-, p©esmyka‡e
         call      UlozKex                  ; ulo‘en¡ p©esmyka‡– do bufferu

Int0913: cmp       bx,ds:[1ch]              ; byla stisknuta nˆjak  kl vesa ?
         jne       Int0915                  ; byla nˆjak  kl vesa - konec mˆ©en¡

         cmp       byte ptr cs:[Real],0     ; je re ln˜ re‘im ?
         jne       Int0914                  ; je re ln˜ re‘im - mˆ©en¡ ‡asu

                                          ;* test, zda je stisknuto
         call      TestAlt                  ; test stisku kl ves Shift-Alt
         jc        Int0915                  ; nen¡ stisknuto Shift-Alt
         test      byte ptr ds:[17h],4      ; je Ctrl- ?
         jz        Int0915                  ; nen¡ Ctrl-

                                          ;* zah jen¡ mˆ©en¡ doby ‡ek n¡
Int0914: cmp       byte ptr cs:[Cekej],1    ; prob¡h  mˆ©en¡ prodlevy ?
         je        Int0919                  ; neprob¡h  mˆ©en¡ prodlevy
         mov       byte ptr cs:[Cekej],1    ; p©¡znak ‡ek n¡
         mov       byte ptr cs:[Citac],0    ; inicializace ‡¡ta‡e prodlevy
         jmp       short int0919

                                          ;* nen¡ Ctrl-Shift-Alt
Int0915: cmp       byte ptr cs:[Cekej],1    ; prob¡halo mˆ©en¡ prodlevy ?
         jne       Int0919                  ; neprob¡halo mˆ©en¡ prodlevy
         mov       byte ptr cs:[Cekej],0    ; konec mˆ©en¡ prodlevy
         mov       ah,cs:[Citac]            ; namˆ©en  doba
         mov       al,KodDelay              ; k¢d prodlevy
         cmp       ah,0
         je        Int0919

         call      UlozKex                  ; ulo‘en¡ k¢du

Int0919: cmp       bx,ds:[1ch]              ; byla stisknuta nˆjak  kl vesa ?
         jne       Int092                   ; byla nˆjak  kl vesa

                                          ;* nebyla stisknuta ‘ dn  kl vesa

         jmp       Int099



                                          ;* test zah jen¡ a p©eru¨en¡ funkce
Int092:  mov       ax,ds:[bx]               ; stisknut  kl vesa
         call      TestAlt                  ; test stisku kl ves Shift-Alt
         jnc       Int09223                 ; je Shift-Alt
         jmp       Int093                   ; nen¡ Shift-Alt

                                          ;* p©eru¨en¡ funkce Shift-Alt-F10
Int09223:cmp       ah,71h                   ; je kl vesa Alt-F10 ?
         jne       Int0922                  ; nen¡ kl vesa Alt-F10

         mov       byte ptr cs:[Real],0     ; zru¨en¡ re‘imu REAL

         cmp       byte ptr cs:[Progr],1    ; je programov n¡ ?
         jne       Int09221                 ; nen¡ programov n¡

         xor       ax,ax
         call      UlozKex                  ; vypr zdnˆn¡ bufferu
         mov       byte ptr cs:[CitRep],0   ; v bufferu nen¡ ‘ dn˜ znak
         mov       byte ptr cs:[Progr],0    ; zru¨en¡ p©¡znaku programov n¡
         jmp       short Int0999

Int09221:cmp       byte ptr cs:[Demons],1   ; je demonstrace ?
         je        Int099c                  ; je demonstrace
Int099ab:jmp       Int099a                  ; nen¡ demonstrace

Int099c:
         mov       byte ptr cs:[CitRep],0   ; zru¨en¡ znak– v bufferu
         mov       byte ptr cs:[Demons],0   ; zru¨en¡ p©¡znaku demonstrace
         jmp       short Int0999            ; konec obsluhy

                                          ;* zah jen¡ demonstrace Shift-Alt-F9
Int0922: cmp       ah,70h                   ; je Shift-Alt-F9 ?
         jne       Int0923                  ; nen¡ Shift-Alt-F9
         cmp       byte ptr cs:[Progr],1    ; je re‘im programov n¡ ?
         je        Int099b                  ; je programov n¡ - chyba
         mov       byte ptr cs:[Real],0
         cmp       byte ptr cs:[Demons],1   ; jede ji‘ demonstrace ?
         je        Int099a                  ; demonstrace ji‘ jede
         cmp       word ptr cs:[MaxBuf],0   ; je v–bec nˆco v bufferu ?
         je        Int099a                  ; v bufferu nic nen¡ - nen¡ demo
         mov       byte ptr cs:[Demons],1   ; nastaven¡ p©¡znaku demonstrace
         mov       word ptr cs:[CitDem],1   ; bude 1 demonstrace
         mov       ax,cs:[UkazBuf]          ; ukazatel v bufferu
         cmp       ax,cs:[MaxBuf]           ; je ji‘ konec bufferu ?
         jb        Int0999                  ; nen¡ je¨tˆ konec - je je¨tˆ nˆco
         mov       word ptr cs:[UkazBuf],0  ; ukazatel na za‡ tek bufferu
Int0999: mov       ds:[1ch],bx              ; zru¨en¡ kl vesy
         call      Beep                     ; indika‡n¡ p¡pnut¡
Int099b: jmp       short Int099             ; konec obsluhy

                                          ;* zah jen¡ programov n¡
Int0923: cmp       ah,68h                   ; je men¨¡ kl vesa ne‘ Shift-Alt-F1 ?
Int09333:jb        Int093                   ; nen¡ hork  kl vesa
         cmp       ah,6fh                   ; je vˆt¨¡ kl vesa ne‘ Shift-Alt-F8 ?
         ja        Int093                   ; nen¡ hork  kl vesa
         sub       ah,68h                   ; p©evod na ‡¡slo 0 a‘ 7
         mov       byte ptr cs:[Real],0     ; nen¡ re ln˜ re‘im
         cmp       ah,7                     ; je F8 ?
         jne       Int09334                 ; nen¡ F8
         inc       byte ptr cs:[Real]       ; p©¡znak re ln‚ho re‘imu
         mov       ah,0                     ; n hradn¡ k¢d
Int09334:
         cmp       byte ptr cs:[Demons],1   ; jede demonstrace ?
         je        Int099a                  ; jede ji‘ demonstrace
         mov       al,KodSpeed              ; k¢d pro nastaven¡ rychlosti
         call      UlozKex                  ; ulo‘en¡ k¢du kl vesy
         mov       ds:[1ch],bx              ; zru¨en¡ kl vesy
         cmp       byte ptr cs:[Progr],1    ; je ji‘ programov n¡ ?
         je        Int099                   ; je ji‘ programov n¡
         mov       byte ptr cs:[Progr],1    ; nastaven¡ p©¡znaku programov n¡
         call      Beep                     ; indika‡n¡ p¡pnut¡
         jmp       short Int099             ; konec obsluhy


                                          ;* p©i demonstraci zru¨en¡ kl vesy
Int093:  cmp       byte ptr cs:[Demons],1   ; prob¡h  demonstrace ?
         jne       Int094                   ; neprob¡h  demonstrace
Int099a: mov       ds:[1ch],bx              ; zru¨en¡ kl vesy z bufferu
         jmp       short Int099             ; konec obsluhy

                                          ;* test, zda je programov n¡
Int094:  cmp       byte ptr cs:[Progr],1    ; prob¡h  programov n¡ ?
         jne       Int099                   ; neprob¡h  programov n¡ - konec

                                          ;* p©i programov n¡ ulo‘en¡ kl vesy
         cmp       al,0fch                  ; je zak zan˜ k¢d kl vesy ?
         jb        Int095                   ; k¢d kl vesy je OK
         mov       ah,al                    ; ASCII k¢d kl vesy
         mov       al,KodAlt                ; k¢d kl vesy s Alt-
Int095:  call      UlozKex                  ; ulo‘en¡ kl vesy do bufferu

int099:  pop       ds
         pop       bx
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        Test, zda je stisknuta kombinace Shift-Alt (DS=40h)
; -----------------------------------------------------------------------------

TestAlt  PROC      NEAR

         test      byte ptr ds:[17h],3      ; je stisknuto Shift- ?
         jz        TestAlt1                 ; nen¡ stisknuto Shift-
         test      byte ptr ds:[17h],8      ; je stisknuto Alt- ?
         jnz       TestAlt2                 ; je stisknuto Alt-
TestAlt1:stc                                ; p©¡znak chyby - nen¡ Shift-Alt-
TestAlt2:ret

TestAlt  ENDP

; -----------------------------------------------------------------------------
;        Test, zda je 2-bajtov˜ k¢d kl vesy (CY=je 1 bajt, NC=jsou 2 bajty)
; -----------------------------------------------------------------------------

TestExt  PROC      NEAR

         cmp       al,KodExt0               ; roz¨¡©en¡ k¢d 0 ?
         je        TestExt2                 ; jsou 2 bajty
         cmp       al,KodExt1               ; roz¨¡©en˜ k¢d 1 ?
         je        TestExt2
         cmp       al,KodExt2               ; roz¨¡©en˜ k¢d 2 ?
         je        TestExt2
         cmp       al,KodDel                ; je kl vesa Delete
         je        TestExt2
         cmp       al," "                   ; je ©¡dic¡ kl vesa ?
         cmc
         jnc       TestExt2                 ; jsou ©¡dic¡ kl vesy
         cmp       al,0fch                  ; jsou speci ln¡ k¢dy ?

TestExt2:ret

TestExt  ENDP

; -----------------------------------------------------------------------------
;        Ulo‘en¡ kl vesy AX se zak¢dov n¡m
; -----------------------------------------------------------------------------

UlozKex  PROC      NEAR

         push      ax
         push      dx

                                          ;* kontrola, zda je st le stejn˜ znak
         cmp       ax,cs:[CharRep]          ; je st le stejn˜ znak ?
         jne       UlozKex1                 ; nen¡ stejn˜ znak

                                          ;* zv˜¨en¡ ‡¡ta‡e znak–
         inc       byte ptr cs:[CitRep]     ; zv˜¨en¡ ‡¡ta‡e znak–
         jnz       UlozKex4                 ; nen¡ je¨tˆ p©ekro‡en¡ po‡tu znak–
         dec       byte ptr cs:[CitRep]     ; n vrat ‡¡ta‡e znak–

                                          ;* vypr zdnˆn¡ bufferu se znakem
UlozKex1:xchg      ax,cs:[CharRep]          ; nov  kl vesa do bufferu
         mov       dl,cs:[CitRep]           ; po‡et znak– p–vodn¡ kl vesy
         mov       byte ptr cs:[CitRep],1   ; v bufferu je nyn¡ 1 kl vesa

                                          ;* rozhodnut¡, zda bude komprese
         or        dl,dl                    ; byl ji‘ nˆjak˜ znak ?
         jz        UlozKex4                 ; nebyl je¨tˆ ‘ dn˜ znak
         cmp       dl,2                     ; byl 1 nebo 2 znaky ?
         jb        UlozKex3                 ; byl 1 znak
         ja        UlozKex2                 ; bylo v¡ce znak– - bude komprese

                                          ;* byly 2 znaky
         call      UlozKey                  ; ulo‘en¡ 1 znaku
         jmp       short UlozKex3           ; ulo‘en¡ druh‚ho znaku

                                          ;* ulo‘en¡ k¢du pro opakov n¡
UlozKex2:push      ax                       ; £schova k¢du kl vesy
         mov       ah,dl                    ; po‡et znak– v bufferu
         mov       al,KodRep                ; k¢d pro opakov n¡ znaku
         call      UlozKey                  ; ulo‘en¡ k¢du pro opakov n¡
         pop       ax                       ; n vrat k¢du kl vesy

                                          ;* ulo‘en¡ k¢du kl vesy
UlozKex3:call      UlozKey                  ; ulo‘en¡ k¢du kl vesy

UlozKex4:pop       dx
         pop       ax
         ret

UlozKex  ENDP



UlozKey  PROC      NEAR

         push      ax
         call      TestExt                  ; test, zda je k¢d 2 bajty
         jc        UlozKey1                 ; je k¢d 1 bajt

         call      Uloz                     ; ulo‘en¡ ni‘¨¡ho znaku bajtu
         mov       al,ah                    ; vy¨¨¡ bajt znaku
UlozKey1:call      Uloz                     ; ulo‘en¡ vy¨¨¡ho bajtu znaku

         pop       ax
         ret

UlozKey  ENDP

; -----------------------------------------------------------------------------
;        Ulo‘en¡ bajtu AL do bufferu
; -----------------------------------------------------------------------------

Uloz     PROC      NEAR

         push      bx
         mov       bx,cs:[UkazBuf]          ; ukazatel bajt– v bufferu
         cmp       bx,cs:[SizBuff]          ; kontrola p©ete‡en¡ bufferu
         jb        uloz1                    ; nen¡ p©ete‡en¡ bufferu

         call      beep                     ; chyba - p©ete‡en¡ bufferu
         jmp       short uloz2

uloz1:   mov       cs:[bx+Buffer],al        ; ulo‘en¡ bajtu do bufferu
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         mov       cs:[UkazBuf],bx          ; nov˜ ukazatel v bufferu
         mov       cs:[MaxBuf],bx           ; po‡et bajt– v bufferu

uloz2:   pop       bx
         ret

Uloz     ENDP

; -----------------------------------------------------------------------------

Beep:    push      ax
         push      cx

         in        al,[61h]
         or        al,3
         out       [61h],al
         xor       cx,cx
         loop      $
         and       al,not 3
         out       [61h],al

         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Tabulka k¢d– kl ves ASCII
; -----------------------------------------------------------------------------

;kody     label     byte
;         db        0                        ; 00h
;         db        1eh                      ; 01h (Ctrl-A)
;         db        30h                      ; 02h (Ctrl-B)
;         db        2eh                      ; 03h (Ctrl-C)
;         db        20h                      ; 04h (Ctrl-D)
;         db        12h                      ; 05h (Ctrl-E)
;         db        21h                      ; 06h (Ctrl-F)
;         db        22h                      ; 07h (Ctrl-G)
;         db        23h                      ; 08h (Ctrl-H)
;         db        17h                      ; 09h (Ctrl-I)
;         db        24h                      ; 0ah (Ctrl-J)
;         db        25h                      ; 0bh (Ctrl-K)
;         db        26h                      ; 0ch (Ctrl-L)
;         db        32h                      ; 0dh (Ctrl-M)
;         db        31h                      ; 0eh (Ctrl-N)
;         db        18h                      ; 0fh (Ctrl-O)
;         db        19h                      ; 10h (Ctrl-P)
;         db        10h                      ; 11h (Ctrl-Q)
;         db        13h                      ; 12h (Ctrl-R)
;         db        1fh                      ; 13h (Ctrl-S)
;         db        14h                      ; 14h (Ctrl-T)
;         db        16h                      ; 15h (Ctrl-U)
;         db        2fh                      ; 16h (Ctrl-V)
;         db        11h                      ; 17h (Ctrl-W)
;         db        2dh                      ; 18h (Ctrl-X)
;         db        15h                      ; 19h (Ctrl-Y)
;         db        2ch                      ; 1ah (Ctrl-Z)
;         db        01h                      ; 1bh (Esc)
;         db        2bh                      ; 1ch (Ctrl-\)
;         db        1bh                      ; 1dh (Ctrl-])
;         db        07h                      ; 1eh (Ctrl-^)
;         db        0ch                      ; 1fh (Ctrl-_)
;         db
;


buffer   label     byte                     ; za‡ tek bufferu kl ves


; -----------------------------------------------------------------------------
;        Start a instalace programu
; -----------------------------------------------------------------------------

Instal:
                                          ;* zobrazen¡ £vodn¡ho textu
         mov       dx,offset uvtxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

                                          ;* nalezen¡ rezidentn¡ instalace
         mov       ds:[SegRez],ds           ; segment rezidentn¡ ‡ sti = CS
         mov       ax,3217h                 ; identifika‡n¡ slovo
         int       16h                      ; test stavu instalace
         mov       es,ds:[SegRez]           ; segment rezidentn¡ instalace

                                          ;* p©¡prava p©¡kaz. © dku k rozboru
         mov       si,81h                   ; za‡ tek textu
         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[80h]              ; BX = d‚lka textu
         mov       byte ptr ds:[bx+si],0    ; ozna‡en¡ konce textu

                                          ;* test, zda je v–bec nˆco zad no
         call      InpSpc                   ; vypustˆn¡ oddˆlova‡– z textu
         jnc       Instal1                  ; je nˆjak˜ znak - OK

                                          ;* chyba zad n¡ - n povˆda
Napoveda:mov       dx,offset HelpTxt        ; text n povˆdy
Napoved3:call      DispTxt                  ; zobrazen¡ textu n povˆdy
         int       20h                      ; konec programu

                                          ;* rozli¨en¡, zda je prvn¡ instalace
Instal1: mov       cx,es                    ; rezidentn¡ segment
         mov       bx,cs                    ; tento segment
         cmp       cx,bx                    ; je prvn¡ instalace ?
         je        Instal2
         jmp       Instal3                  ; nen¡ to prvn¡ instalace

                                          ;* parametry pro prvn¡ instalaci
Instal2: call      InpCh                    ; na‡ten¡ znaku z p©¡kazov‚ho © dku

                                          ;* test p©ed‡asn‚ho parametru
         cmp       al,"L"
         je        Instal21
         cmp       al,"S"
         je        Instal21
         cmp       al,"C"
         je        Instal21
         cmp       al,"D"
         je        Instal21
         cmp       al,"U"
         jne       Instal22

                                          ;* chybn˜ parametr
Instal21:mov       dx,offset Par1Txt        ; hl ¨en¡ - nejd©¡ve nainstalujte
         jmp       short Napoved3           ; hl ¨en¡

Instal22:cmp       al,"B"                   ; je parametr "B" ?
         jne       Napoveda                 ; chyba zad n¡ parametru
         call      InpNum                   ; vstup ‡¡sla
         jc        Napoveda                 ; chyba zadani velikosti bufferu
         or        ax,1                     ; t¡mto se zabr n¡ nulov‚mu bufferu
         cmp       ax,60000                 ; maxim ln¡ velikost bufferu
         jbe       Instal23                 ; velikost bufferu OK
         mov       ax,60000                 ; omezen¡ velikosti bufferu
Instal23:mov       ds:[SizBuff],ax          ; velikost bufferu
         call      InpSpc                   ; vypustˆn¡ dal¨¡ch oddˆlova‡–
         jnc       Instal2                  ; je je¨tˆ nˆco zad no

; -----------------------------------------------------------------------------
;        Prvn¡ instalace programu
; -----------------------------------------------------------------------------

                                          ;* nainstalov n¡ programu
         mov       ax,3508h
         int       21h
         mov       word ptr ds:[old08],bx
         mov       word ptr ds:[old08+2],es
         mov       dx,offset int08
         mov       ax,2508h
         int       21h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[old09+2],es
         mov       dx,offset int09
         mov       ax,2509h
         int       21h

         mov       ax,3516h
         int       21h
         mov       word ptr ds:[old16],bx
         mov       word ptr ds:[old16+2],es
         mov       dx,offset int16
         mov       ax,2516h
         int       21h

                                          ;* zru¨en¡ segmentu prost©ed¡
         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

         mov       dx,offset KeyTxt         ; n povˆda ke kl ves m
         call      DispTxt                  ; zobrazen¡ n povˆdy ke kl ves m

                                          ;* instalace jako rezidentn¡
         mov       dx,offset instal         ; konec rezidentn¡ ‡ sti
         add       dx,ds:[SizBuff]          ; p©i‡ten¡ velikosti bufferu
         int       27h


; -----------------------------------------------------------------------------
;        Nastaven¡ parametr– programu
; -----------------------------------------------------------------------------

                                          ;* nalezen¡ prvn¡ho parametru
Instal3: call      InpSpc                   ; vypustˆn¡ oddˆlova‡– z textu
         jnc       Instal30

         jmp       Instal9                  ; nen¡ dal¨¡ znak v © dku

Instal30:call      InpCh                    ; na‡ten¡ znaku z p©¡kazov‚ho © dku

                                          ;* parametr "B" - chyba
         cmp       al,"B"                   ; je parametr "B" ?
         jne       Instal32                 ; nen¡ parametr "B"
         mov       dx,offset Par2Txt        ; hl ¨en¡ - odinstalujte
         call      DispTxt                  ; zobrazen¡ textu
         int       20h

                                          ;* parametr "L" - ‡ten¡ definice
Instal32:cmp       al,"L"                   ; je parametr "L" ?
         jne       Instal4                  ; nen¡ parametr "L"
         call      Load                     ; na‡ten¡ souboru do pamˆti
         jnc       Instal3                  ; dal¨¡ parametr
         mov       dx,offset LoadTxt        ; chyba ‡ten¡ souboru
         call      DispTxt
         int       20h

                                          ;* parametr "S" - ulo‘en¡ definice
Instal4: cmp       al,"S"                   ; je parametr "S" ?
         jne       Instal5                  ; nen¡ parametr "S"
         call      Save                     ; ulo‘en¡ definice do souboru
         jnc       Instal3                  ; dal¨¡ parametr
         mov       dx,offset SaveTxt        ; chyba ulo‘en¡ souboru
         call      DispTxt
         int       20h

                                          ;* parametr "C" - vymaz n¡ bufferu
Instal5: cmp       al,"C"                   ; je parametr "C" ?
         jne       Instal6                  ; nen¡ parametr "C"
         mov       word ptr es:[MaxBuf],0   ; po‡et bajt– v bufferu = 0
         mov       word ptr es:[UkazBuf],0  ; ukazatel bajt– v bufferu
         mov       byte ptr es:[Progr],0    ; zru¨en¡ p©¡znaku programov n¡
         mov       byte ptr es:[Demons],0   ; zru¨en¡ p©¡znaku demonstrace
Instal35:jmp       short Instal3            ; dal¨¡ parametr


                                          ;* parametr "D" - po‡et demonstrac¡
Instal6: cmp       al,"D"                   ; je parametr "D" ?
         jne       Instal8                  ; nen¡ parametr "D"
         call      InpNum                   ; vstup ‡¡sla
         jc        Napoved2                 ; chyba zadani velikosti bufferu
         mov       es:[CitDem],ax           ; po‡et opakov n¡ demonstrace
         cmp       byte ptr es:[Progr],1    ; prob¡h  programov n¡ ?
         je        Instal3                  ; prob¡h  programov n¡ - ignorov n¡
         mov       byte ptr es:[Demons],1   ; p©¡znak demonstrace (start)
         mov       byte ptr es:[UkazBuf],0  ; inicializace ukazatele bufferu
         jmp       short Instal35           ; dal¨¡ parametr

                                          ;* parametr "U" - oinstalov n¡
Instal8: cmp       al,"U"                   ; je parametr "U" ?
         jne       Napoved2                 ; nen¡ parametr "U" - chyba zad n¡
         mov       byte ptr ds:[DeInst],1   ; p©¡znak odinstalov n¡
         jmp       short Instal35           ; dal¨¡ parametr

Napoved2:jmp       Napoveda                 ; chyba - zobrazen¡ n povˆdy

; -----------------------------------------------------------------------------
;        Konec programu - odinstalov n¡ z pamˆti
; -----------------------------------------------------------------------------
Instal9:
                                          ;* test, zda se m  prov‚st odinstalace
         cmp       byte ptr ds:[DeInst],1   ; m  se prov‚st deinstalace ?
         jne       Instalc                  ; nem  se prov‚st deinstalace

                                          ;* kontrola, zda je mo‘n  deinstalace
         mov       cx,es                    ; rezidentn¡ segment

         mov       ax,3508h
         int       21h                      ; poskytnut¡ vektoru INT 08h
         mov       ax,es                    ; segment INT 08h
         cmp       ax,cx                    ; souhlas¡ segment ?
         jne       Instala                  ; nelze odinstalovat

         mov       ax,3509h
         int       21h                      ; poskytnut¡ vektoru INT 09h
         mov       ax,es                    ; segment INT 09h
         cmp       ax,cx                    ; souhlas¡ segment ?
         jne       Instala                  ; nelze odinstalovat

         mov       ax,3516h
         int       21h                      ; poskytnut¡ vektoru INT 16h
         mov       ax,es                    ; segment INT 16h
         cmp       ax,cx                    ; souhlas¡ segment ?
         jne       Instala                  ; nelze odinstalovat

                                          ;* odinstalov n¡ programu
         mov       cx,es                    ; rezidentn¡ segment
         mov       ax,2508h
         lds       dx,es:[Old08]            ; p–vodn¡ adresa INT 08h
         int       21h                      ; n vrat adresy INT 08h

         mov       ax,2509h
         lds       dx,es:[Old09]            ; p–vodn¡ adresa INT 09h
         int       21h                      ; n vrat adresy INT 09h

         mov       ax,2516h
         lds       dx,es:[Old16]            ; p–vodn¡ adresa INT 16h
         int       21h                      ; n vrat adresy INT 16h

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku pamˆti

                                          ;* instalace probˆhla £spˆ¨nˆ
         mov       dx,offset DIns2Txt
         jmp       short Instald            ; hl ¨en¡ - program byl odinstalov n

                                          ;* deinstalace nen¡ mo‘n 
Instala: mov       dx,offset DeInsTxt       ; hl ¨en¡ - nelze odinstalovat
Instald: call      DispTxt                  ; zobrazen¡ chybov‚ho textu

Instalc: int       20h

; -----------------------------------------------------------------------------
;        Na‡ten¡ souboru definice do pamˆti
; -----------------------------------------------------------------------------

Load     PROC      NEAR

         call      InpSoub                  ; dek¢dov n¡ jm‚na souboru
         jc        Load3                    ; chyba zad n¡ jm‚na souboru
         mov       ax,3d00h                 ; funkce otev©en¡ soub. pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        Load3                    ; chybn‚ zad n¡ jm‚na souboru
         mov       bx,ax                    ; identifik tor souboru

         cmp       word ptr es:[MaxBuf],0   ; je nˆco v bufferu ?
         je        Load2                    ; v bufferu nic nen¡

         mov       dx,offset DataTxt        ; hl ¨en¡, ‘e nˆco je ji‘ v pamˆti
         call      Dotaz                    ; dotaz na dal¨¡ postup
         cmc
         jnc       Load3                    ; p©eru¨en¡ operace - nic se ne‡te
         jne       Load2                    ; data se p©ipoj¡
         mov       word ptr es:[MaxBuf],0   ; zru¨en¡ dat v bufferu
         mov       word ptr es:[UkazBuf],0  ; nastaven¡ ukazatele na 0

Load2:   push      ds
         mov       ds,ds:[SegRez]           ; segment rezidentn¡ ‡ sti
         mov       dx,es:[AdrBuf]           ; adresa bufferu rezid. ‡ sti
         add       dx,es:[MaxBuf]           ; nastaven¡ na konec bufferu
         mov       cx,es:[SizBuff]          ; velikost bufferu
         sub       cx,es:[MaxBuf]           ; voln  ‡ st bufferu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do pamˆti
         pop       ds
         pushf
         push      ax
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         pop       ax
         popf
         jc        Load3                    ; chyba ‡ten¡ dat
         add       es:[MaxBuf],ax           ; po‡et na‡ten˜ch bajt– do bufferu

Load3:   ret

Load     ENDP

; -----------------------------------------------------------------------------
;        Ulo‘en¡ definice do souboru
; -----------------------------------------------------------------------------

Save     PROC      NEAR

         call      InpSoub                  ; dek¢dov n¡ jm‚na souboru
         jc        Save3                    ; chyba zad n¡ jm‚na souboru

                                          ;* test, zda soubor ji‘ existuje
         mov       ax,3d01h
         int       21h                      ; otev©en¡ souboru pro z pis
         jc        Save1                    ; soubor nenalezen - vytvo©en¡
         mov       ah,3eh
         int       21h                      ; soubor se zase uzav©e

         push      dx                       ; £schova jm‚na souboru
         mov       dx,offset ExistTxt       ; hl ¨en¡, ‘e soubor existuje
         call      Dotaz                    ; dotaz na dal¨¡ postup
         pop       dx                       ; n vrat jm‚na souboru
         cmc
         jnc       Save3                    ; p©eru¨en¡
         je        Save1                    ; soubor se p©ep¡¨e

                                          ;* bude p©id n¡ k souboru
         mov       ax,3d01h                 ; otev©en¡ pro z pis
         int       21h                      ; otev©en¡ souboru pro z pis
         jc        Save3                    ; chyba
         mov       bx,ax                    ; identifik tor souboru

         mov       ax,4202h
         xor       dx,dx
         xor       cx,cx
         int       21h                      ; nastaven¡ na konec souboru
         jc        Save3                    ; chyba
         jmp       short Save2

Save1:   mov       ah,3ch                   ; funkce vytvo©en¡ souboru
         xor       cx,cx                    ; atributy
         int       21h                      ; vytvo©en¡ souboru
         jc        Save3                    ; chybn‚ zad n¡ jm‚na souboru
         mov       bx,ax                    ; identifik tor souboru
Save2:   push      ds
         mov       ds,ds:[SegRez]           ; segment rezidentn¡ ‡ sti
         mov       dx,es:[AdrBuf]           ; adresa bufferu rezid. ‡ sti
         mov       cx,es:[MaxBuf]           ; po‡et bajt– v bufferu
         mov       ah,40h
         int       21h                      ; z pis definice do souboru
         pop       ds
         pushf
         push      ax
         xor       cx,cx
         mov       ah,40h
         int       21h                      ; o©ez n¡ souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         pop       ax
         popf
         jc        Save3                    ; chyba z pisu do souboru
         cmp       ax,cx                    ; je disk pln˜ ? (CY=je pln˜)

Save3:   ret

Save     ENDP

; -----------------------------------------------------------------------------
;        Dotaz na dal¨¡ postup (ZY=prepsat, NZ=pripojit, CY=prerusit)
; -----------------------------------------------------------------------------

Dotaz    PROC      NEAR

         push      ax
         push      dx
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu
         mov       dx,offset DotazTxt       ; text dotazu
         call      DispTxt                  ; zobrazen¡ dotazu
         mov       ah,8
         int       21h                      ; vstup z kl vesnice bez echa
         push      ax                       ; £schova kl vesy
         mov       dx,offset CrTxt          ; text od© dkov n¡
         call      DispTxt                  ; od© dkov n¡ textu
         pop       ax                       ; n vrat k¢du kl vesy

         cmp       al," "                   ; mezera
         je        Dotaz1                   ; p©ipojen¡

         and       al,not 20h               ; p©evod na velk‚ p¡smeno
         cmp       al,13                    ; Enter
         je        Dotaz2
         cmp       al,"A"
         je        Dotaz2                   ; Ano
         cmp       al,"P"                   ; Pripojeni
         stc
         jne       Dotaz2                   ; jinak je p©eru¨en¡

Dotaz1:  or        al,al                    ; p©¡znak NZ
Dotaz2:  pop       dx
         pop       ax
         ret

Dotaz    ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ zad n¡ jm‚na souboru
; -----------------------------------------------------------------------------

InpSoub  PROC      NEAR

         call      InpSpc                   ; vypu¨tˆn¡ mezer z textu
         jc        InpSoub3                 ; chyba - nen¡ nic zad no
         mov       dx,si                    ; £schova za‡ tku textu
InpSoub1:call      InpCh                    ; na‡ten¡ dal¨¡ho znaku
         ja        InpSoub1                 ; je platn˜ znak - p©esko‡en¡
         je        InpSoub2                 ; je oddˆlova‡ - ozna‡en¡ konce

         clc
         mov       byte ptr ds:[si],0       ; ozna‡en¡ konce textu
         ret

InpSoub2:mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce textu
InpSoub3:ret

InpSoub  ENDP

; -----------------------------------------------------------------------------
;        Vstup ‡¡sla z p©¡kazov‚ho © dku AX
; -----------------------------------------------------------------------------

InpNum   PROC      NEAR

         push      dx
         push      bx
         call      InpSpc                   ; vypu¨tˆn¡ mezer z textu
         xor       bx,bx
         call      InpNm                    ; vstup prvn¡ ‡¡slice
         jc        InpNum2                  ; nen¡ platn  ‡¡slice

InpNum1: push      ax
         mov       ax,10
         mul       bx
         pop       bx
         xor       bh,bh
         add       bx,ax
         call      InpNm
         jnc       InpNum1
         clc

InpNum2: mov       ax,bx
         pop       bx
         pop       dx
         ret

InpNum   ENDP

; -----------------------------------------------------------------------------

InpNm    PROC      NEAR

         call      InpCh                    ; ‡ten¡ znaku z p©¡kazov‚ho © dku
         jc        InpNm2                   ; nen¡ dal¨¡ znak
         sub       al,"0"                   ; p©evod na bin rn¡ ‡¡slo
         jc        InpNm1                   ; chyba - nen¡ ‡¡slice
         cmp       al,10
         cmc
         jnc       InpNm2                   ; je platn  ‡¡slice
InpNm1:  dec       si                       ; n vrat posledn¡ho znaku
InpNm2:  ret

InpNm    ENDP

; -----------------------------------------------------------------------------
;        Vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

InpSpc   PROC      NEAR

         call      InpCh                    ; ‡ten¡ znaku z p©¡kazov‚ho © dku
         je        InpSpc                   ; je oddˆlova‡ - vypu¨tˆn¡
         jb        InpSpc1                  ; byl konec textu
         dec       si                       ; n vrat posledn¡ho znaku
InpSpc1: ret

InpSpc   ENDP

; -----------------------------------------------------------------------------
;        Vstup znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

InpCh    PROC      NEAR

         cld                                ; smˆr nahoru
         lodsb                              ; na‡ten¡ znaku z p©¡kaz. © dku

                                          ;* p©evod na velk‚ p¡smeno
         cmp       al,"a"
         jb        InpCh1                   ; nen¡ mal‚ p¡smeno
         cmp       al,"z"
         ja        InpCh1
         sub       al,32                    ; p©evod na velk‚ p¡smeno

                                          ;* n hrada tabel toru mezerou
InpCh1:  cmp       al,"/"
         je        InpCh4
         cmp       al,9                     ; je to tabel tor ?
         jne       InpCh2                   ; nen¡ to tabel tor
InpCh4:  mov       al," "                   ; n hrada mezerou

                                          ;* kontrola konce textu
InpCh2:  cmp       al," "                   ; je to oddˆlova‡ ?
         jae       InpCh3                   ; je platn˜ znak
         dec       si                       ; n vrat ukazatele na konec © dku

InpCh3:  ret

InpCh    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      ds
         push      cs
         pop       ds
         mov       ah,9
         int       21h
         pop       ds
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;                       Data pro inicializaci
; -----------------------------------------------------------------------------

DeInst   db        0                        ; 1=p©¡znak odinstalov n¡

UvTxt    db        'SHOWS V1.10 - generator demonstraci; (c) Miroslav Nemecek',13,10
         db        '$'

HelpTxt  db        '========================================================',13,10
         db        '   Instalace:    B cislo ...... velikost bufferu',13,10
         db        '   Po instalaci: L soubor ..... nacteni definice',13,10
         db        '                 S soubor ..... ulozeni definice',13,10
         db        '                 C ............ vymazani bufferu',13,10
         db        '                 D cislo ...... start demo (pocet)',13,10
         db        '                 U ............ odinstalovani',13,10
         db        '$'

KeyTxt   db        '========================================================',13,10
         db        '------- Program SHOWS byl nainstalovan do pameti -------',13,10
         db        '  DEMONSTRACE            start .... Shift-Alt-F9',13,10
         db        '                     preruseni .... Shift-Alt-F10',13,10
         db        '  PROGRAMOVANI rychlost, start .... Shift-Alt-F1...F7',13,10
         db        '                  realny rezim .... Shift-Alt-F8',13,10
         db        '                      prodleva .... Ctrl-Shift-Alt',13,10
         db        '                     preruseni .... Shift-Alt-F10',13,10
         db        '$'

DataTxt  db        'V pameti jiz nejaka data jsou - chcete je prepsat ?',13,10,'$'
ExistTxt db        'Soubor jiz existuje - chcete jej prepsat ?',13,10,'$'
DotazTxt db        'A (Enter) = prepsat, P (Mezera) = pridat, jinak prerusit: $'


LoadTxt  db        'Soubor nenalezen nebo chyba cteni !'
CrTxt    db        13,10,'$'

SaveTxt  db        'Chybne zadani jmena souboru nebo chyba zapisu !',13,10,'$'

Par1Txt  db        'Program nejdrive nainstalujte (zadejte: B velikost_bufferu) !',13,10,'$'

Par2Txt  db        'Chcete-li zmenit velikost bufferu, musite program',13,10
         db        'nejdrive odinstalovat z pameti (parametr U) !',13,10,'$'

DeInsTxt db        'Odinstalovani programu neni mozne - odinstalujte',13,10
         db        'nejdrive programy instalovane po programu SHOWS !',13,10
         db        '$'

DIns2Txt db        'Program byl odinstalovan z pameti.',13,10,'$'

code     ends
         end       start


; *****************************************************************************
;
;                               A N I M I
;
;                     animaán° program - interpreter
;
; *****************************************************************************


Code     SEGMENT
         ASSUME    cs:Code,ds:Code,ss:Stack

         db        'XX'                     ; prvn° poloëka bude na offsetu 2

         dw        SEG SegProg              ; segment animaán°ho programu

         db        'ANIM - graficka animace; (c) Miroslav Nemecek',13,10

Start:

; ------ p©edefinov†n° z†sobn°ku na vrchol pamàti

         mov       ax,ds:[2]                ; segment s koncem pamàti
         sub       ax,1000h                 ; rezerva 64 KB
         mov       ss,ax                    ; segment z†sobn°ku
         mov       sp,0fff8h                ; offset z†sobn°ku

; ------ nastaven° p©°znaku karty EGA

         mov       ah,12h                   ; funkce poskytnut° informac° EGA
         mov       bx,05e10h                ; podfunkce informac°
         call      Int10                    ; poskytnut° informac° EGA/VGA
         cmp       bh,2                     ; m¢d displeje 0 nebo 1
         jae       Start2                   ; chyba - neplatnò obsah registru
         cmp       bl,5                     ; maxim†ln° velikost pamàti 1 MB
         jbe       Start3                   ; velikost pamàti OK
Start2:  mov       byte ptr cs:[EgaVga],0   ; p©°znak, ëe nen° karta EGA/VGA

; ------ £schova videom¢du

Start3:  mov       ah,0fh
         call      Int10                    ; poskytnut° aktivn°ho videom¢du
         mov       cs:[OldVMod],al          ; £schova aktivn°ho videom¢du

; ------ uráen° segmentñ jednotlivòch blokñ

         mov       cl,4                     ; poáet rotac° pro p©evod
         mov       ax,SEG SegProg           ; segment s daty programu
         mov       ds,ax                    ; segment datovÇho modulu
         mov       bx,ds:[0]                ; dÇlka datovÇho modulu
         mov       cs:[DatNum],bx           ; poáet bajtñ datovÇho modulu
         add       bx,15                    ; zaokrouhlen° na odstavec
         shr       bx,cl                    ; p©epoáet na odstavce
         add       ax,bx                    ; adresa segmentu s programem
         mov       cs:[ProgMem],ax          ; segment s programem
         mov       ds,ax                    ; segment s programem
         mov       bx,ds:[0]                ; dÇlka segmentu s programem
         add       bx,15                    ; zaokrouhlen° na odstavec
         shr       bx,cl                    ; p©epoáet na odstavce
         add       ax,bx                    ; adresa segmentu s objekty
         mov       cs:[ObjMem],ax           ; segment s objekty

; ------ uráen° adresy konce tabulky blokñ

         mov       word ptr cs:[TopMem],-1  ; p©ednastaven° - zru®en° konce
         xor       ax,ax                    ; hledanò blok 0
         call      SrcObj                   ; nalezen° objektu 0 (=koncovò)
         mov       cs:[TopMem],dx           ; novò konec pamàti

; ------ £schova k¢du p©ipravenÇ kl†vesy

         push      cs
         pop       ds

         xor       ax,ax
Start4:  push      ax
         mov       ah,1
         int       16h                      ; dotaz na stav kl†vesnice
         pop       ax
         jz        Start5                   ; nen° p©ipraven ë†dnò znak
         mov       ah,0
         int       16h                      ; vstup znaku z kl†vesnice
         jmp       short Start4             ; test dal®°ho znaku
Start5:  mov       ds:[KeyBuf],ax           ; uloëen° p©°padnÇho k¢du kl†vesy

; ------ definice obsluh p©eru®en° INT xx

         mov       ax,2523h
         mov       dx,offset Prerus         ; obsluha INT 23h
         int       21h                      ; adresa p©eru®en° programu

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es
         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es
         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

         mov       ax,3500h
         int       21h
         mov       word ptr ds:[Old00],bx
         mov       word ptr ds:[Old00+2],es
         mov       dx,offset Int00
         mov       ax,2500h
         int       21h

         mov       ax,351Bh
         int       21h
         mov       word ptr ds:[Old1B],bx
         mov       word ptr ds:[Old1B+2],es
         mov       dx,offset Int1B
         mov       ax,251Bh
         int       21h

; ------ inicializace gener†toru n†hody

         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         mov       dx,ds:[46eh]
         mov       word ptr cs:[RandNum],ax
         mov       word ptr cs:[RandNum+2],dx

; ------ interpretace programu

         mov       ds,cs:[ProgMem]          ; segment s programem
         mov       es,cs:[DatMem]           ; segment s daty programu
         mov       si,ds:[2]                ; startovac° adresa programu
         sti                                ; povoleno p©eru®en°
         cld                                ; smàr nahoru
         call      Anim                     ; interpretace programu (procedury)
         mov       byte ptr cs:[RetKod],al  ; n†vratovò k¢d programu

; ------ ukonáen° programu (nebo p©eru®en°)

Prerus:  mov       al,cs:[OldVMod]          ; pñvodn° videom¢d
         mov       ah,0
         call      Int10                    ; n†vrat videom¢du

; ------ n†vrat obsluhy p©eru®en° INT 08h

Prerus2: lds       dx,cs:[Old08]
         mov       ax,2508h
         int       21h                      ; n†vrat adresy obsluhy INT 08h

; ------ n†vrat obsluhy p©eru®en° INT 09h

         lds       dx,cs:[Old09]
         mov       ax,2509h
         int       21h                      ; n†vrat adresy obsluhy INT 09h

; ------ n†vrat obsluhy p©eru®en° INT 00h

         lds       dx,cs:[Old00]
         mov       ax,2500h
         int       21h                      ; n†vrat adresy obsluhy INT 00h

; ------ n†vrat obsluhy p©eru®en° INT 1Bh

         lds       dx,cs:[Old1B]
         mov       ax,251Bh
         int       21h                      ; n†vrat adresy obsluhy INT 1Bh

; ------ vypnut° zvukovÇho gener†toru

         in        al,[61h]                 ; vòstup na reproduktor
         and       al,not 3
         out       [61h],al                 ; vypnut° vòstupu na reproduktor

; ------ n†vrat z programu

         mov       al,cs:[RetKod]           ; n†vratovò k¢d z programu
         mov       ah,4ch
         int       21h                      ; ukonáen° programu

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 08h (obsluha hodin a zvukovÇho gener†toru)
; -----------------------------------------------------------------------------

Citac    dw        0                        ; á°taá áasu
Old08    dd        0                        ; pñvodn° adresa INT 08h

UkazMel  dw        0                        ; ukazatel melodie
NumMel   dw        0                        ; poáet zbylòch znakñ melodie

CitTon   db        0                        ; á°taá zbylÇ doby trv†n° t¢nu

public   int08
INT08    PROC      FAR

         inc       word ptr cs:[Citac]
         jnz       Int082                   ; nen° p©eteáen°
         dec       word ptr cs:[Citac]      ; n†vrat á°sla -1
Int082:


; ------ obsluha á°taáe doby jednoho t¢nu

         cmp       byte ptr cs:[CitTon],0   ; je á°taá doby t¢nu vynulov†n ?
         je        Int084                   ; je jië = 0 - dal®° melodie
         dec       byte ptr cs:[CitTon]     ; sn°ëen° á°taáe doby t¢nu
         jnz       Int089                   ; dal®° áek†n°

; ------ konec t¢nu - vypnut° zvukovÇho gener†toru

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut° gener†toru
         pop       ax

; ------ test, zda je p©ipraven dal®° t¢n melodie

Int084:  cmp       word ptr cs:[NumMel],0   ; je dal®° t¢n melodie ?
         je        Int089                   ; nen° dal®° t¢n melodie

; ------ nastaven° dal®°ho t¢nu melodie

         push      ax
         push      bx
         push      ds

         dec       word ptr cs:[NumMel]     ; sn°ëen° á°taáe t¢nñ melodie
         mov       ds,cs:[ProgMem]          ; segment s naátenòm programem
         mov       bx,cs:[UkazMel]          ; ukazatel melodie
         add       word ptr cs:[UkazMel],2  ; zvò®en° ukazatele melodie
         mov       bx,ds:[bx]               ; dal®° t¢n melodie a jeho dÇlka
         mov       cs:[CitTon],bh           ; á°taá dÇlky jednoho t¢nu
         mov       bh,0                     ; BX=á°slo t¢nu
         shl       bx,1                     ; á°slo t¢nu * 2
         mov       bx,cs:[bx+TabTon-2]      ; dàlic° konstanta t¢nu
         jz        Int085                   ; je prodleva

         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al
         in        al,[61h]
         or        al,3
         out       [61h],al
Int085:
         pop       ds
         pop       bx
         pop       ax

Int089:  jmp       dword ptr cs:[Old08]     ; pokraáov†n° v obsluze INT 08h

Int08    ENDP


TabTon   label     word                     ; tabulka pro nastaven° t¢nñ
         dw        36485,34437,32505,30680,28958,27333 ; okt†va 0
         dw        25799,24351,22984,21694,20477,19327
         dw        18243,17219,16252,15340,14479,13667 ; okt†va 1
         dw        12899,12175,11492,10847,10238,9664
         dw        9121,8609,8126,7670,7240,6833       ; okt†va 2
         dw        6450,6088,5746,5424,5119,4832
         dw        4561,4305,4063,3835,3620,3417       ; okt†va 3
         dw        3225,3044,2873,2712,2560,2416
         dw        2280,2152,2032,1918,1810,1708       ; okt†va 4
         dw        1612,1522,1437,1356,1280,1208
         dw        1140,1076,1016,959,905,854          ; okt†va 5
         dw        806,761,718,678,640,604
         dw        570,538,508,479,452,427             ; okt†va 6
         dw        403,380,359,339,320,302
         dw        285,269,254,240,226,214             ; okt†va 7
         dw        202,190,180,169,160,151
         dw        143,135,127,120,113,107             ; okt†va 8
         dw        101,95,90,85,80,75
         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt†va 9

; -----------------------------------------------------------------------------
;        Obsluha kl†vesnice INT 09h
; -----------------------------------------------------------------------------

Old09    dd        0                        ; pñvodn° obsluha INT 09h

ExtKey   dw        0                        ; povolen° reëimu roz®°©. kl†vesnice
KeyBuf   dw        0                        ; buffer posledn° kl†vesy

Int09    PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      ds

; ------ p©°prava datovÇho segmentu BIOS

         mov       bx,40h
         mov       ds,bx                    ; datovò segment BIOS

; ------ áten° k¢du stisknutÇ kl†vesy, kontrola k¢du kl†vesy

         in        al,[60h]                 ; áten° k¢du kl†vesy
         mov       bx,ax                    ; k¢d kl†vesy
         and       bx,7fh                   ; k¢d kl†vesy bez bitu 7
         jz        Int097                   ; je k¢d 0 - nepovolen† kl†vesa
         cmp       bl,60h                   ; je povolenò k¢d kl†vesy ?
         jae       Int097                   ; tento k¢d kl†vesy je nezn†mò

; ------ nastaven° ukazatele kl†vesy v bufferu

         cmp       byte ptr cs:[ExtKey],0   ; je povolena roz®°©en† kl†vesnice ?
         je        Int093                   ; roz®°©en† kl†vesnice nepovolena
         test      byte ptr ds:[496h],2     ; je roz®°©enò k¢d kl†vesy ?
         jz        Int093                   ; nen° roz®°©enò k¢d kl†vesy
         cmp       bl,47h                   ; je kl†vesa v numerickÇm poli ?
         jb        Int092                   ; nen° kl†vesa v numerickÇm poli
         cmp       bl,53h                   ; max. kl†vesa v num. poli
         ja        Int092                   ; nen° kl†vesa v numerickÇm poli
         add       bl,60h-47h               ; posun k¢du
         jmp       short Int093
Int092:  cmp       bl,1ch                   ; je Enter ?
         jne       Int0922                  ; nen° Enter
         mov       bl,6fh                   ; je Enter v numerickÇm poli
         jmp       short Int093
Int0922: cmp       bl,1dh                   ; je Ctrl ?
         jne       Int0923                  ; nen° Ctrl
         mov       bl,6dh                   ; je pravò Ctrl
         jmp       short Int093
Int0923: cmp       bl,38h                   ; je Alt ?
         jne       Int0924                  ; nen° Alt
         mov       bl,64h                   ; je pravò Alt
         jmp       short Int093
Int0924: cmp       bl,35h                   ; je / ?
         jne       Int0925                  ; nen° /
         mov       bl,70h                   ; je [/] v numerickÇm poli
Int0925:

; ------ rozli®en° stisku a uvolnàn°

Int093:  mov       cs:[TabKey],bl           ; £schova k¢du posledn° kl†vesy
         test      al,80h                   ; je stisk kl†vesy ?
         jz        Int094                   ; je stisk kl†vesy

; ------ je uvolnàn° kl†vesy

         mov       byte ptr cs:[bx+TabKey],0 ; oznaáen° kl†vesy za uvolnànou
         jmp       short Int097

; ------ je stisk kl†vesy

Int094:  inc       byte ptr cs:[bx+TabKey]  ; zvò®en° á°taáe stisku kl†vesy
         jnz       Int097                   ; nen° p©eteáen°
         dec       byte ptr cs:[bx+TabKey]  ; navr†t° se na 0ffh

; ------ standardn° obsluha kl†vesnice

Int097:  mov       bx,ds:[1ch]              ; £schova ukl†dac° adresy do bufferu
         pushf
         call      dword ptr cs:[Old09]     ; vol†n° standardn° obsluhy BIOS

; ------ kontrola, zda je v bufferu nàjakò znak

         cmp       bx,ds:[1ch]              ; zmànila se ukl†dac° adresa ?
         je        Int099                   ; nezmànila se - nen° novò znak

; ------ vyjmut° novÇho znaku z bufferu

         mov       ax,ds:[bx]               ; vyjmut° novÇho znaku
         mov       cs:[KeyBuf],ax           ; £schova znaku do bufferu
         mov       ds:[1ch],bx              ; n†vrat ukl†dac° adresy
         mov       ds:[1ah],bx              ; zru®en° átec° adresy

; ------ n†vrat registrñ

Int099:  pop       ds
         pop       bx
         pop       ax
         iret

Int09    ENDP

TabKey   label     byte                     ; tabulka p©°znakñ kl†ves

         db        0                        ; 00h: poslednà stisknut† kl†vesa
         db        0                        ; 01h: Esc
         db        0                        ; 02h: 1 !
         db        0                        ; 03h: 2 @
         db        0                        ; 04h: 3 #
         db        0                        ; 05h: 4 $
         db        0                        ; 06h: 5 %
         db        0                        ; 07h: 6 ^
         db        0                        ; 08h: 7 &
         db        0                        ; 09h: 8 *
         db        0                        ; 0ah: 9 (
         db        0                        ; 0bh: 0 )
         db        0                        ; 0ch: - _
         db        0                        ; 0dh: = +
         db        0                        ; 0eh: <- (Back Space)
         db        0                        ; 0fh: Tab
         db        0                        ; 10h: Q
         db        0                        ; 11h: W
         db        0                        ; 12h: E
         db        0                        ; 13h: R
         db        0                        ; 14h: T
         db        0                        ; 15h: Y
         db        0                        ; 16h: U
         db        0                        ; 17h: I
         db        0                        ; 18h: O
         db        0                        ; 19h: P
         db        0                        ; 1ah: [ {
         db        0                        ; 1bh: ] }
         db        0                        ; 1ch: Enter
         db        0                        ; 1dh: Ctrl
         db        0                        ; 1eh: A
         db        0                        ; 1fh: S
         db        0                        ; 20h: D
         db        0                        ; 21h: F
         db        0                        ; 22h: G
         db        0                        ; 23h: H
         db        0                        ; 24h: J
         db        0                        ; 25h: K
         db        0                        ; 26h: L
         db        0                        ; 27h: ; :
         db        0                        ; 28h: ' "
         db        0                        ; 29h: ` ~
         db        0                        ; 2ah: levò Shift
         db        0                        ; 2bh: \ |
         db        0                        ; 2ch: Z
         db        0                        ; 2dh: X
         db        0                        ; 2eh: C
         db        0                        ; 2fh: V
         db        0                        ; 30h: B
         db        0                        ; 31h: N
         db        0                        ; 32h: M
         db        0                        ; 33h: , <
         db        0                        ; 34h: . >
         db        0                        ; 35h: / ?
         db        0                        ; 36h: pravò Shift
         db        0                        ; 37h: [*] Print Screen
         db        0                        ; 38h: Alt
         db        0                        ; 39h: mezern°k
         db        0                        ; 3ah: Caps Lock
         db        0                        ; 3bh: F1
         db        0                        ; 3ch: F2
         db        0                        ; 3dh: F3
         db        0                        ; 3eh: F4
         db        0                        ; 3fh: F5
         db        0                        ; 40h: F6
         db        0                        ; 41h: F7
         db        0                        ; 42h: F8
         db        0                        ; 43h: F9
         db        0                        ; 44h: F10
         db        0                        ; 45h: Num Lock
         db        0                        ; 46h: Scroll Lock
         db        0                        ; 47h: [7] Home
         db        0                        ; 48h: [8] kurzor nahoru
         db        0                        ; 49h: [9] Page Up
         db        0                        ; 4ah: [-]
         db        0                        ; 4bh: [4] kurzor vlevo
         db        0                        ; 4ch: [5]
         db        0                        ; 4dh: [6] kurzor vpravo
         db        0                        ; 4eh: [+]
         db        0                        ; 4fh: [1] End
         db        0                        ; 50h: [2] kurzor dolñ
         db        0                        ; 51h: [3] Page Down
         db        0                        ; 52h: [0] Insert
         db        0                        ; 53h: [.] Delete
         db        0                        ; 54h: (SysRq - pouze AT 84 kl†ves)
         db        0                        ; 55h:
         db        0                        ; 56h: \ | (AT 102 kl†ves)
         db        0                        ; 57h: F11 (AT 101 a 102 kl†ves)
         db        0                        ; 58h: F12 (AT 101 a 102 kl†ves)
         db        0                        ; 59h:
         db        0                        ; 5ah:
         db        0                        ; 5bh:
         db        0                        ; 5ch:
         db        0                        ; 5dh:
         db        0                        ; 5eh:
         db        0                        ; 5fh:

                                          ;* zde zaá°naj° zdvojenÇ kl†vesy
         db        0                        ; 60h: Home
         db        0                        ; 61h: kurzor nahoru
         db        0                        ; 62h: Page Up
         db        0                        ; 63h:
         db        0                        ; 64h: kurzor vlevo
         db        0                        ; 65h: [5]
         db        0                        ; 66h: kurzor vpravo
         db        0                        ; 67h:
         db        0                        ; 68h: End
         db        0                        ; 69h: kurzor dolñ
         db        0                        ; 6ah: Page Down
         db        0                        ; 6bh: Insert
         db        0                        ; 6ch: Delete
         db        0                        ; 6dh: pravò Ctrl
         db        0                        ; 6eh: pravò Alt
         db        0                        ; 6fh: [Enter]
         db        0                        ; 70h: [/]

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 00h
; -----------------------------------------------------------------------------

Old00    dd        0                        ; pñvodn° adresa INT 00h

INT00    PROC      FAR

         iret

INT00    ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 1Bh
; -----------------------------------------------------------------------------

ParBreak db        0                        ; p©°znak uëivatelskÇho p©eru®en°
Old1B    dd        0                        ; pñvodn° adresa INT 1Bh

INT1B    PROC      FAR

         mov       byte ptr cs:[ParBreak],1 ; p©°znak p©eru®en°
         mov       byte ptr cs:[AdrBrk+1],0 ; n†silnÇ ukonáen° programu
         mov       byte ptr cs:[AdrBrk2+1],0 ; n†silnÇ ukonáen° vòpoátu vòrazu
         iret

INT1B    ENDP

; -----------------------------------------------------------------------------
;        Interpretace procedury programu (po p©°kaz ENDPROC nebo RETURN)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel programu
;        ES=datovò segment
; VùSTUP: AX=n†vratovò k¢d
; -----------------------------------------------------------------------------

PUBLIC   Anim
Anim:    lodsb                              ; identifik†tor povelu
         mov       bl,al                    ; identifik†tor povelu
         mov       bh,0                     ; BX = á°slo povelu
         shl       bx,1                     ; á°slo povelu * 2
         call      word ptr cs:[TabFnc+bx]  ; vyvol†n° obsluhy funkce
AdrBrk:  jmp       short Anim               ; dal®° p©°kaz

; ------ n†sleduj°c° procedura se bude prov†dàt p©i p©eru®en° programu

         xor       ax,ax                    ; n†vratovò k¢d p©i p©eru®en°
         ret                                ; p©eru®en° programu

; -----------------------------------------------------------------------------
;        Vòpoáet hodnoty vòrazu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel programu
;        ES=datovò segment
; VùSTUP:AX=hodnota vòrazu
;        DS:SI=novò ukazatel programu
; -----------------------------------------------------------------------------

PUBLIC   Vyraz
Vyraz:
         xor       ax,ax                    ; vòchoz° hodnota vòrazu

; ------ vnit©n° oper†tor vòrazu

Vyraz1:  mov       bl,ds:[si]               ; identifik†tor oper†toru
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; á°slo oper†toru * 2
         call      word ptr cs:[TabOper+bx] ; obsluha oper†toru
AdrBrk2: jnc       Vyraz1                   ; zpracov†n° dal®°ho operandu
         clc
         ret                                ; konec vòrazu

; -----------------------------------------------------------------------------
;        Konec vòrazu
; -----------------------------------------------------------------------------

PUBLIC   OpKonec
OpKonec:
         stc                                ; p©°znak konce vòrazu
         ret

; -----------------------------------------------------------------------------
;        Prav† z†vorka
; -----------------------------------------------------------------------------

PUBLIC   OpRght
OpRght:  stc                                ; p©°znak konce vòrazu
         ret

; -----------------------------------------------------------------------------
;        ^ mocnina
; -----------------------------------------------------------------------------

PUBLIC   OpMoc
OpMoc:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu
         mov       cx,ax                    ; druhò operand

; ------ test, zda je mocnàn° na 0

         pop       ax                       ; prvn° operand
         jcxz      OpMoc3                   ; umocnàno na 0

; ------ umocnàn° á°sla (n†soben° á°slem BX)

         dec       cx                       ; sn°ëen° á°taáe mocniny
         jcxz      OpMoc2                   ; je mocnàno na 1 - konec
         mov       bx,ax                    ; t°mto á°slem se bude n†sobit
OpMoc1:  imul      bx                       ; vyn†soben° operandem
         loop      OpMoc1                   ; dal®° mocnàn°
OpMoc2:  clc                                ; p©°znak operace OK
         ret

; ------ á°slo je umocnàno na 0

OpMoc3:  mov       ax,1                     ; vòsledek operace mocnàn° na 0
         clc                                ; p©°znak operace OK
         ret

; -----------------------------------------------------------------------------
;        * n†soben°
; -----------------------------------------------------------------------------

PUBLIC   OpMul
OpMul:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ vyn†soben° operandñ

         pop       cx                       ; prvn° operand
         imul      cx                       ; n†sobek
         clc                                ; p©°znak operace OK
         ret

; -----------------------------------------------------------------------------
;        / dàlen°
; -----------------------------------------------------------------------------

PUBLIC   OpDiv
OpDiv:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ vydàlen° operandñ

         mov       cx,ax                    ; druhò operand
         pop       ax                       ; n†vrat prvn°ho operandu
         jcxz      OpDiv1                   ; byla by chyba dàlen° (p©eteáen°)
         cwd                                ; p©evod na dvojslovo
         idiv      cx                       ; dàlen°
         clc                                ; p©°znak operace OK
         ret

; ------ dàlen° nulou

OpDiv1:  mov       ax,8000h                 ; p©eteáen°
         clc                                ; p©°znak operace OK
         ret

; -----------------------------------------------------------------------------
;        MOD
; -----------------------------------------------------------------------------

PUBLIC   OpMod
OpMod:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ vydàlen° operandñ

         mov       cx,ax                    ; druhò operand
         pop       ax                       ; n†vrat prvn°ho operandu
         jcxz      OpMod1                   ; byla by chyba dàlen° nulou
         cwd                                ; p©evod na dvojslovo
         idiv      cx                       ; dàlen°
         mov       ax,dx                    ; zbytek po dàlen°
         clc                                ; p©°znak operace OK
         ret

; ------ dàlen° nulou

OpMod1:  xor       ax,ax                    ; p©eteáen°
         ret

; -----------------------------------------------------------------------------
;        <<
; -----------------------------------------------------------------------------

PUBLIC   OpShl
OpShl:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ rotace operandu

         mov       cx,ax                    ; druhò operand
         pop       ax                       ; n†vrat prvn°ho operandu
         cmp       cx,16
         jbe       OpShl1
         mov       cl,16
OpShl1:  shl       ax,cl
         clc                                ; p©°znak operace OK
         ret

; -----------------------------------------------------------------------------
;        >>
; -----------------------------------------------------------------------------

PUBLIC   OpShr
OpShr:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ rotace operandu

         mov       cx,ax                    ; druhò operand
         pop       ax                       ; n†vrat prvn°ho operandu
         cmp       cx,16
         jbe       OpShr1
         mov       cl,16
OpShr1:  shr       ax,cl
         clc                                ; p©°znak operace OK
         ret

; -----------------------------------------------------------------------------
;        +
; -----------------------------------------------------------------------------

PUBLIC   OpAdd
OpAdd:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ souáet operandñ

         pop       cx                       ; n†vrat prvn°ho operandu
         add       ax,cx                    ; souáet operandñ
         clc
         ret

; -----------------------------------------------------------------------------
;        -
; -----------------------------------------------------------------------------

PUBLIC   OpSub
OpSub:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ rozd°l operandñ

         mov       cx,ax                    ; druhò operand
         pop       ax                       ; n†vrat prvn°ho operandu
         sub       ax,cx                    ; rozd°l operandñ
         clc
         ret

; -----------------------------------------------------------------------------
;        =
; -----------------------------------------------------------------------------

PUBLIC   OpEqu
OpEqu:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ porovn†n° operandñ

         pop       cx                       ; n†vrat prvn°ho operandu
         cmp       ax,cx                    ; je shoda operandñ ?
         mov       ax,-1                    ; p©°znak shody operandñ
         je        OpEqu1                   ; operandy jsou shodnÇ
         xor       ax,ax                    ; p©°znak neshody operandñ
OpEqu1:  ret

; -----------------------------------------------------------------------------
;        <>
; -----------------------------------------------------------------------------

PUBLIC   OpNeq
OpNeq:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ porovn†n° operandñ

         pop       cx                       ; n†vrat prvn°ho operandu
         sub       ax,cx                    ; je shoda operandñ ?
         je        OpNeq1                   ; operandy jsou shodnÇ - nesplnàno
         mov       ax,-1                    ; p©°znak neshody operandñ
         clc                                ; p©°znak operace OK
OpNeq1:  ret

; -----------------------------------------------------------------------------
;        <
; -----------------------------------------------------------------------------

PUBLIC   OpLt
OpLt:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ porovn†n° operandñ

         pop       cx                       ; n†vrat prvn°ho operandu
         cmp       cx,ax                    ; je prvn° operand men®° ?
         mov       ax,-1                    ; p©°znak splnàn° podm°nky
         jl        OpLt1                    ; prvn° operand je men®° - OK
         xor       ax,ax                    ; p©°znak nesplnàn° podm°nky
OpLt1:   clc
         ret

; -----------------------------------------------------------------------------
;        >
; -----------------------------------------------------------------------------

PUBLIC   OpGt
OpGt:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ porovn†n° operandñ

         pop       cx                       ; n†vrat prvn°ho operandu
         cmp       cx,ax                    ; je prvn° operand vàt®° ?
         mov       ax,-1                    ; p©°znak splnàn° podm°nky
         jg        OpGt1                    ; prvn° operand je vàt®° - OK
         xor       ax,ax                    ; p©°znak nesplnàn° podm°nky
OpGt1:   clc
         ret

; -----------------------------------------------------------------------------
;        <=
; -----------------------------------------------------------------------------

PUBLIC   OpLte
OpLte:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ porovn†n° operandñ

         pop       cx                       ; n†vrat prvn°ho operandu
         cmp       cx,ax                    ; je prvn° operand men®°/shodnò ?
         mov       ax,-1                    ; p©°znak splnàn° podm°nky
         jle       OpLte1                   ; prvn° operand je men®°/shodnò - OK
         xor       ax,ax                    ; p©°znak nesplnàn° podm°nky
OpLte1:  clc
         ret

; -----------------------------------------------------------------------------
;        >=
; -----------------------------------------------------------------------------

PUBLIC   OpGte
OpGte:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ porovn†n° operandñ

         pop       cx                       ; n†vrat prvn°ho operandu
         cmp       cx,ax                    ; je prvn° operand vàt®°/shodnò ?
         mov       ax,-1                    ; p©°znak splnàn° podm°nky
         jge       OpGte1                   ; prvn° operand je vàt®°/shodnò - OK
         xor       ax,ax                    ; p©°znak nesplnàn° podm°nky
OpGte1:  clc
         ret

; -----------------------------------------------------------------------------
;        NOT
; -----------------------------------------------------------------------------

PUBLIC   OpNot
OpNot:

; ------ vòpoáet n†sleduj°c°ho operandu

         xor       ax,ax                    ; p©ednastaven° st©adaáe
         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ inverze operandu

         not       ax
         clc
         ret

; -----------------------------------------------------------------------------
;        AND
; -----------------------------------------------------------------------------

PUBLIC   OpAnd
OpAnd:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ operace AND

         pop       cx                       ; n†vrat prvn°ho operandu
         and       ax,cx                    ; operace AND mezi operandy
         ret

; -----------------------------------------------------------------------------
;        OR
; -----------------------------------------------------------------------------

PUBLIC   OpOr
OpOr:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ operace OR

         pop       cx                       ; n†vrat prvn°ho operandu
         or        ax,cx                    ; operace OR mezi operandy
         ret

; -----------------------------------------------------------------------------
;        XOR
; -----------------------------------------------------------------------------

PUBLIC   OpXor
OpXor:
         push      ax                       ; £schova st©adaáe vòsledku

; ------ vòpoáet n†sleduj°c°ho operandu

         mov       bl,ds:[si]               ; identifik†tor operandu
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor operandu * 2
         call      word ptr cs:[TabOper+bx] ; stanoven° operandu

; ------ operace XOR

         pop       cx                       ; n†vrat prvn°ho operandu
         xor       ax,cx                    ; operace XOR mezi operandy
         ret

; -----------------------------------------------------------------------------
;        Konstanta
; -----------------------------------------------------------------------------

PUBLIC   OpKonst
OpKonst: lodsw
         clc
         ret

; -----------------------------------------------------------------------------
;        Intern° procedura - funkce
; -----------------------------------------------------------------------------

PUBLIC   OpInter
OpInter:
         mov       bl,ds:[si]               ; identifik†tor procedury
         inc       si                       ; zvò®en° ukazatele programu
         mov       bh,0
         shl       bx,1                     ; identifik†tor procedury * 2
         call      word ptr cs:[TabFnc+bx]  ; vyvol†n° obsluhy intern° funkce
         clc
         ret

; -----------------------------------------------------------------------------
;        Uëivatelsk† funkce
; -----------------------------------------------------------------------------

PUBLIC   OpUsr
OpUsr:
         lodsw                              ; adresa uëivatelskÇ funkce
         push      si                       ; £schova ukazatele pogramu
         mov       si,ax                    ; nov† adresa programu (procedura)
         call      Anim                     ; proveden° obsluhy procedury
         pop       si                       ; n†vrat ukazatele programu
         clc
         ret

; -----------------------------------------------------------------------------
;        promànn† BYTE
; -----------------------------------------------------------------------------

PUBLIC   OpByte
OpByte:
         lodsw                              ; adresa promànnÇ
         mov       bx,ax                    ; adresa promànnÇ
         mov       al,es:[bx]               ; hodnota promànnÇ
         cbw                                ; p©evod na slovo
         clc
         ret

; -----------------------------------------------------------------------------
;        promànn† WORD
; -----------------------------------------------------------------------------

PUBLIC   OpWord
OpWord:
         lodsw                              ; adresa promànnÇ
         mov       bx,ax                    ; adresa promànnÇ
         mov       ax,es:[bx]               ; hodnota promànnÇ
         clc
         ret

; -----------------------------------------------------------------------------
;        promànn† BYTE s indexem
; -----------------------------------------------------------------------------

PUBLIC   OpByteI
OpByteI:
         lodsw                              ; adresa promànnÇ
         push      ax                       ; £schova adresy promànnÇ
         call      Vyraz                    ; vòpoáet indexu
         pop       bx                       ; adresa promànnÇ
         add       bx,ax                    ; p©iáten° indexu
         mov       al,es:[bx]
         cbw                                ; p©evod na slovo
         clc
         ret

; -----------------------------------------------------------------------------
;        promànn† WORD s indexem
; -----------------------------------------------------------------------------

PUBLIC   OpWordI
OpWordI:
         lodsw                              ; adresa promànnÇ
         push      ax                       ; £schova adresy promànnÇ
         call      Vyraz                    ; vòpoáet indexu
         shl       ax,1                     ; index * 2
         pop       bx                       ; adresa promànnÇ
         add       bx,ax                    ; p©iáten° indexu
         mov       al,es:[bx]               ; nië®° bajt promànnÇ
         mov       ah,es:[bx+1]             ; vy®®° bajt promànnÇ
         clc
         ret

; -----------------------------------------------------------------------------
;        Nalezen° objektu AX v pamàti -> DX (CY=objekt nenalezen)
; -----------------------------------------------------------------------------

PUBLIC   SrcObj

SrcObj:
         push      ds                       ; £schova DS
         mov       dx,cs:[ObjMem]           ; segment s objekty

; ------ test, zda je to hledanò objekt

SrcObj2: mov       ds,dx                    ; segment objektu
         cmp       ax,ds:[0]                ; je to hledanò objekt ?
         je        SrcObj3                  ; objekt nalezen
         add       dx,ds:[2]                ; zvò®en° adresy segmentu
         cmp       dx,cs:[TopMem]           ; dosaëeno konce pamàti ?
         jb        SrcObj2                  ; nen° je®tà konec pamàti - dal®°

; ------ chyba - objekt nenalezen

SrcObj4: stc                                ; p©°znak, ëe objekt nebyl nalezen
         pop       ds                       ; n†vrat DS
         ret

; ------ objekt nalezen OK (DX=adresa objektu)

SrcObj3: pop       ds                       ; n†vrat DS
         ret


; -----------------------------------------------------------------------------
;        Zru®en° objektu z pamàti (DX=adresa objektu)
; -----------------------------------------------------------------------------

PUBLIC   DelObj

DelObj:  push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         sti                                ; mus° bòt povoleno p©eru®en°
         cld                                ; smàr nahoru
         mov       es,dx                    ; c°lovò segment k p©esunu
         mov       cx,es:[2]                ; velikost objektu
         add       dx,cx                    ; adresa dal®°ho objektu
         mov       bx,cs:[TopMem]           ; konec pamàti s objekty
         sub       cs:[TopMem],cx           ; sn°ëen° konce pamàti
         sub       bx,dx                    ; velikost zbytku dat
         jz        DelObj5                  ; nejsou ë†dn† data k p©esunu
         mov       ds,dx                    ; zdrojov† adresa p©esunu
         jmp       short DelObj3

; ------ P©enos dal®°ho bloku dat

DelObj2: mov       cx,es                    ; c°lovò segment
         add       cx,1000h                 ; zvò®en° o 1 segment 64 KB
         mov       es,cx                    ; novò c°lovò segment
         mov       cx,ds                    ; zdrojovò segment
         add       cx,1000h                 ; zvò®en° o 1 segment 64 KB
         mov       ds,cx                    ; novò zdrojovò segment

; ------ Nastaven° velikosti p©en†®enÇho bloku

DelObj3: mov       cx,1000h                 ; omezen° na 64 KB
         cmp       bx,cx                    ; je blok vàt®° neë 1 segment ?
         jae       DelObj4                  ; je velkò segment
         mov       cx,bx                    ; velikost bloku v odstavc°ch
DelObj4: shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod odstavcñ na slova

; ------ P©enos jednoho bloku dat

         xor       si,si
         xor       di,di
         rep       movsw                    ; p©enos jednoho segmentu
         sub       bx,1000h                 ; je dal®° segment k p©enosu ?
         ja        DelObj2                  ; p©enos dal®°ho segmentu

DelObj5: pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Normalizace adresy DS:SI
; -----------------------------------------------------------------------------

PUBLIC   NormDSSI
NormDSSI:push      ax
         push      cx
         mov       ax,si                    ; offset adresy
         mov       cl,4                     ; poáet rotac° pro p©evod
         shr       ax,cl                    ; p©epoáet na odstavce
         mov       cx,ds                    ; souáasnò segment
         add       ax,cx                    ; normalizovanò segment
         mov       ds,ax                    ; normalizovanò segment
         and       si,0fh                   ; normalizovanò offset
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Poskytnut° adresy tabulky videom¢du
; -----------------------------------------------------------------------------

PUBLIC   GetTabMod
GetTabMod:
         push      ax
         push      dx

         xor       ax,ax
         mov       al,cs:[VMod]             ; aktu†ln° videom¢d
         mov       bp,offset(TabMod0-TabMod); dÇlka jednÇ poloëky tabulky
         mul       bp                       ; offset v tabulce
         add       ax,offset TabMod         ; tabulka parametrñ displeje
         mov       bp,ax                    ; adresa parametrñ displeje

         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Poskytnut° adresy vòstupn° videostr†nky ES:DI
; -----------------------------------------------------------------------------

PUBLIC   GetVRAM
GetVRAM:
         push      ax
         push      dx
         mov       ah,0
         mov       al,cs:[Page2]            ; vòstupn° videostr†nka
         mul       word ptr cs:[DelVRAM]    ; vòpoáet offsetu videostr†nky
         mov       di,ax                    ; offset adresy videostr†nky
         mov       es,cs:[SegVRAM]          ; segment videopamàti
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Omezen° rozmàrñ obrazce (CY=obrazec se nezobraz°)
; -----------------------------------------------------------------------------
; VSTUP: ObjLD, ObjUD, ObjS, ObjV, Wind1, Wind2, Wind3, Wind4
; VùSTUP: ObjLO, ObjUO, màn° ObjS, ObjV, ObjLD, ObjUD
; -----------------------------------------------------------------------------

PUBLIC   Omez
Omez:

; ------ £schova a p©°prava registrñ

         push      ax
         push      bx
         push      bp
         push      ds
         push      cs
         pop       ds
         call      GetTabMod                ; adresa tabulky videom¢du BP

; ------ omezen° levÇho okraje

         mov       word ptr ds:[ObjLO],0    ; p©ednastaven° poá†tku v objektu
         mov       bx,ds:[ObjLD]            ; poëadovanò levò okraj
         mov       ax,ds:[Wind1]            ; levò okraj okna
         or        ax,ax                    ; je levò okraj z†pornò ?
         jns       Omez1                    ; levò okraj nen° zapornò
         xor       ax,ax                    ; omezen° levÇho okraje na 0
Omez1:   cmp       ax,bx                    ; je levò okraj p©ed poá†tkem ?
         jle       Omez2                    ; levò okraj je p©ed poá†tkem OK
         mov       ds:[ObjLD],ax            ; novò levò okraj zaá†tku zobrazen°
         sub       ax,bx                    ; posun poá†tku
         mov       ds:[ObjLO],ax            ; poá†teán° pozice v objektu
         sub       ds:[ObjS],ax             ; sn°ëen° ®°©ky obrazce
         jbe       OmezXX                   ; chyba - nen° nic k zobrazen°

; ------ omezen° horn°ho okraje

Omez2:   mov       word ptr ds:[ObjUO],0    ; p©ednastaven° poá†tku v objektu
         mov       bx,ds:[ObjUD]            ; poëadovanò horn° okraj
         mov       ax,ds:[Wind2]            ; horn° okraj okna
         or        ax,ax                    ; je horn° okraj z†pornò ?
         jns       Omez3                    ; horn° okraj nen° z†pornò
         xor       ax,ax                    ; omezen° horn°ho okraje na 0
Omez3:   cmp       ax,bx                    ; je horn° okraj nad horn° likou ?
         jle       Omez4                    ; horn° okraj je nad horn° linkou OK
         mov       ds:[ObjUD],ax            ; novò horn° okraj zaá†tku zobrazen°
         sub       ax,bx                    ; posun horn°ho okraje
         mov       ds:[ObjUO],ax            ; poá†teán° linka v objektu
         sub       ds:[ObjV],ax             ; sn°ëen° vò®ky obrazce
OmezXX:  jbe       OmezX                    ; chyba - nen° nic k zobrazen°

; ------ omezen° ®°©ky obrazce

Omez4:   mov       ax,ds:[Wind3]            ; pravò okraj okna
         or        ax,ax                    ; je pravò okraj z†pornò ?
         js        OmezX                    ; chyba - pravò okraj je z†pornò
         inc       ax                       ; pravò okraj + 1
         jns       Omez5                    ; nen° p©eteáen°
         dec       ax                       ; oprava na 32767
Omez5:   cmp       ax,ds:[bp+ModSir]        ; p©ekroáen maxim†ln° pravò okraj ?
         jle       Omez6                    ; maxim†ln° pravò okraj nep©ekroáen
         mov       ax,ds:[bp+ModSir]        ; pravò okraj + 1
Omez6:   sub       ax,ds:[ObjLD]            ; maxim†ln° ®°©ka obrazce
         jle       OmezX                    ; chyba-pravò okraj je p©ed poá†tkem
         cmp       ax,ds:[ObjS]             ; je max. ®°©ka men®° ?
         jae       Omez7                    ; ®°©ka je dostateán† - OK
         mov       ds:[ObjS],ax             ; omezen° ®°©ky obrazce

; ------ omezen° vò®ky objektu

Omez7:   mov       ax,ds:[Wind4]            ; spodn° okraj okna
         or        ax,ax                    ; je spodn° okraj z†pornò ?
         js        OmezX                    ; chyba - spodn° okraj je z†pornò
         inc       ax                       ; spodn° okraj + 1
         jns       Omez8                    ; nen° p©eteáen°
         dec       ax                       ; oprava na 32767
Omez8:   cmp       ax,ds:[bp+ModVys]        ; p©ekroáen maxim†ln° spodn° okraj ?
         jle       Omez9                    ; maxim†ln° spodn° okraj nep©ekroáen
         mov       ax,ds:[bp+ModVys]        ; spodn° okraj + 1
Omez9:   sub       ax,ds:[ObjUD]            ; maxim†ln° vò®ka obrazce
         jle       OmezX                    ; chyba-spodn° okraj je nad zaá†tkem
         cmp       ax,ds:[ObjV]             ; je max. vò®ka men®° ?
         jae       Omeza                    ; vò®ka je dostateán† - OK
         mov       ds:[ObjV],ax             ; omezen° vò®ky obrazce

; ------ ovà©en°, zda nezñstala ®°©ka nebo vò®ka = 0

Omeza:   cmp       word ptr ds:[ObjS],0     ; poëaduje se ®°©ka 0 ?
         je        OmezX                    ; chyba - je ®°©ka 0
         cmp       word ptr ds:[ObjV],0     ; poëaduje se vò®ka 0 ?
         clc                                ; p©°znak - operace OK
         jne       Omezb                    ; vò®ka nen° 0 = OK

; ------ n†vrat registrñ

OmezX:   stc                                ; p©°znak - obrazec se nezobraz°
Omezb:   pop       ds
         pop       bp
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Vymaz†n° obdÇln°ku v textovÇm m¢du (ES:DI=videopamàü, AX=barva)
; -----------------------------------------------------------------------------

PUBLIC   ClrTXT

ClrTxt:

         mov       bx,ds:[bp+ModSirB]       ; poáet pozic na ©†dek

; ------ vòpoáet poá†teán° adresy ve videopamàti

         push      ax                       ; £schova poëadovanÇ barvy
         mov       ax,ds:[ObjUD]            ; poëadovanò poá†teán° ©†dek
         mul       bx                       ; p©epoáet ©†dku na pozice
         add       ax,ds:[ObjLD]            ; p©iáten° poá†teán° pozice
         add       di,ax
         add       di,ax                    ; poá†teán° adresa
         pop       ax                       ; poëadovan† barva k vymaz†n°

; ------ stanoven° mazac°ho znaku

         xchg      ah,al                    ; AH<-barva
         cmp       al,0                     ; je stanovenò mazac° znak ?
         jne       ClrTxt1                  ; znak je stanovenò
         mov       al,219                   ; mazac° znak - plnò znak

; ------ vymaz†n° obdÇln°ku

ClrTxt1: cld
         shl       bx,1                     ; poáet bajtñ na ©†dek
         mov       cx,ds:[ObjV]             ; vò®ka obdÇln°ku (©†dkñ)
ClrTxt2: push      di                       ; £schova ukl†dac° adresy
         push      cx                       ; £schova á°taáe ©†dkñ
         mov       cx,ds:[ObjS]             ; ®°©ka obdÇln°ku (pozic)
         rep       stosw                    ; vymaz†n° jednoho ©†dku
         pop       cx                       ; n†vrat á°taáe ©†dkñ
         pop       di                       ; n†vrat ukl†dac° adresy
         add       di,bx                    ; zvò®en° ukl†dac° adresy
         loop      ClrTxt2                  ; z†pis dal®°ho ©†dku

         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° objektu v textovÇm reëimu
; -----------------------------------------------------------------------------
; VSTUP: DS=CS
;        ES:DI=poá†teán° adresa videopamàti
;        kromà SI a BP nemus° uchov†vat registry
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=poá†teán° adresa pro zobrazen° objektu
; -----------------------------------------------------------------------------

PUBLIC   PrepTxt
PrepTxt:

; ------ nastaven° poátu bajtñ na ©†dek

         mov       ax,ds:[Sirka]            ; ®°©ka vò©ezu (znakñ)
         mov       ds:[SirkaB],ax           ; ®°©ka ©†dku v batech

; ------ vòpoáet poátu bajtñ na rovinu

         mul       word ptr ds:[Vyska]      ; poáet bajtñ na rovinu
         mov       ds:[RovinaB],ax          ; poáet bajtñ na rovinu

; ------ vòpoáet poá†teán° adresy ve videopamàti

         mov       ax,ds:[ObjUD]            ; hodn° okraj poá†tku k zobrazen°
         mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
         add       ax,ds:[ObjLD]            ; p©iáten° poá†teán°ho offsetu
         add       di,ax
         add       di,ax                    ; poá†teán° adresa k zobrazen°
         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° roviny v textovÇm m¢du
; -----------------------------------------------------------------------------
; VSTUP: BL=rovina
;        DS:SI=poá†teán° adresa prvn° linky
; -----------------------------------------------------------------------------
; VùSTUP: DS:SI=poá†teán° adresa k zobrazen°
;        kromà BP a ES:DI nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   SetTXT
SetTXT:

; ------ korekce adresy ve videopamàti podle displeje

         mov       bh,0
         add       di,bx                    ; korekce pro rovinu barev 1
         ret


; -----------------------------------------------------------------------------
;        Zobrazen° linky v textovÇm m¢du
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispTXT

DispTXT: push      di
         mov       ch,0
         mov       cl,byte ptr cs:[ObjS]    ; ®°©ka objektu (poáet znakñ)

DispTXT1:movsb
         inc       di
         loop      DispTXT1

         pop       di
         add       di,cs:[bp+ModSirB]       ; zvò®en° adresy
         add       di,cs:[bp+ModSirB]
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° á†ry v m¢du TXT
; -----------------------------------------------------------------------------

LineTxt:
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° bodu v m¢du TXT (AX=barva, BX=pozice, DX=©†dek)
; -----------------------------------------------------------------------------

PointTXT:

; ------ vòpoáet poá†teán° adresy ve videopamàti

         push      ax                       ; £schova poëadovanÇ barvy
         mov       ax,ds:[bp+ModSirB]       ; poáet znakñ na ©†dek
         mul       dx                       ; p©epoáet ©†dku na pozice
         add       ax,bx                    ; p©iáten° poá†teán° pozice
         shl       ax,1                     ; p©evod pozic na bajty
         add       di,ax                    ; poá†teán° adresa
         pop       ax                       ; poëadovan† barva k vymaz†n°

; ------ stanoven° znaku

         xchg      ah,al                    ; AH<-barva
         cmp       al,0                     ; je stanovenò mazac° znak ?
         jne       PoiTxt1                  ; znak je stanovenò
         mov       al,219                   ; mazac° znak - plnò znak

; ------ z†pis znaku na displej

PoiTxt1: stosw                              ; uloëen° znaku
         ret

; -----------------------------------------------------------------------------
;        Vymaz†n° obdÇln°ku v m¢du CGA4 (ES:DI=videopamàü, DS:BP=tab., AX=barva)
; -----------------------------------------------------------------------------

PUBLIC   ClrCG4
ClrCG4:
         mov       bx,ax                    ; poëadovan† barva
         and       bx,303h                  ; maskov†n° barvy

; ------ vòpoáet prvn° masky objektu (levò okraj)

         mov       cl,byte ptr ds:[ObjLD]   ; levò okraj zaá†tku zobrazen°
         and       cl,3                     ; pozice 0 aë 3
         mov       al,0ffh                  ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo
         shr       al,cl                    ; je®tà jednou rotace (2 bity/bod)
         mov       ds:[MaskFrst],al         ; maska prvn°ho bajtu

; ------ vòpoáet poátu zbylòch bodñ

         mov       dl,4                     ; poáet bodñ na bajt
         sub       dl,cl                    ; poáet bodñ v prvn°m bajtu (1 aë 4)
         mov       dh,0                     ; BX=poáet bodñ zobrazenòch vlevo
         mov       ax,ds:[ObjS]             ; ®°©ka pro zobrazen° objektu
         sub       ax,dx                    ; poáet zbylòch bodñ
         js        ClrCG41                  ; je malò poáet bodñ

; ------ vòpoáet poátu celòch bajtñ

         mov       dx,ax                    ; £schova poátu zbylòch bodñ
         shr       ax,1
         shr       ax,1                     ; poáet celòch vnit©n°ch bajtñ
         mov       ds:[MaskNum],al          ; poáet vnit©n°ch bajtñ

; ------ vòpoáet masky pravÇho okraje

         and       dl,3                     ; poáet zbylòch bodñ vpravo (0 aë 3)
         mov       cl,4                     ; poáet bodñ na bajt
         sub       cl,dl                    ; poáet nezobraz. bodñ vpravo (1-4)
         mov       al,0ffh                  ; maska pravÇho okraje
         shl       al,cl                    ; vòpoáet masky pravÇho okraje
         shl       al,cl                    ; je®tà jednou rotace (2 bity/bod)
         mov       ds:[MaskLst],al          ; maska pravÇho okraje (00 - FC)
         jmp       short ClrCG42

; ------ oprava prvn° masky pro malò poáet bodñ

ClrCG41: add       cl,byte ptr ds:[ObjS]    ; koncov† bitov† pozice+1 (1 aë 3)
         mov       al,4                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
         mov       al,0ffh                  ; maska
         shl       al,cl                    ; rotace korekán° masky
         shl       al,cl                    ; je®tà jednou rotace (2 bity/bod)
         and       ds:[MaskFrst],al         ; oprava prvn° masky
         mov       byte ptr ds:[MaskLst],0  ; nen° prav† maska
         mov       byte ptr ds:[MaskNum],0  ; nen° ë†dnò vnit©n° bajt

; ------ vòpoáet poá†teán° adresy ve videopamàti

ClrCG42: mov       ax,ds:[ObjUD]            ; hodn° okraj poá†tku k zobrazen°
         shr       ax,1                     ; pouze kaëd† sud† linka
         jnc       ClrCG43                 ; je sud† linka
         xor       di,2000h                 ; korekce pro lichou linku
ClrCG43: mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
         add       di,ax                    ; poá†teán° adresa linky
         mov       dx,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
         shr       dx,1
         shr       dx,1                     ; p©epoáet na offset v bajtech
         add       di,dx                    ; poá†teán° adresa k zobrazen°

; ------ stanoven° vzorku vòplnà

         mov       si,ds:[ObjUD]            ; poá†teán° linka
         and       si,7                     ; opakov†n° po 8 link†ch
         add       si,offset Pattern        ; adresa v tabulce vòpln°

; ------ z†pis obdÇln°ku do jednÇ roviny

         mov       cx,ds:[ObjV]             ; vò®ka obdÇln°ku v link†ch
ClrCG44: push      cx                       ; £schova á°taáe linek
         push      di                       ; £schova ukl†dac° adresy
         call      FilCG4                   ; z†pis jednÇ linky
         pop       di                       ; ukl†dac° adresa
         pop       cx                       ; n†vrat á°taáe linek
         test      di,2000h                 ; je sud† linka ?
         jz        ClrCG45                  ; je sud† linka
         add       di,ds:[bp+ModSirB]       ; zvò®en° adresy ve videopamàti
ClrCG45: xor       di,2000h
         loop      ClrCG44                  ; zobrazen° dal®° linky

         ret

; -----------------------------------------------------------------------------
;        Vymaz†n° linku v m¢du CGA - 4 a 5
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa vzorku
;        BL=barva pop©ed°
;        BH=barva pozad°
; VùSTUP: DS:SI=adresa dal®°ho vzorku
; zniáenÇ registry: AX, DX, DI, CX
; -----------------------------------------------------------------------------

PUBLIC   FilCG4
FilCG4:

; ------ stanoven° vzorku vòplnà

         mov       ah,ds:[si]               ; vzorek vòplnà
         mov       cx,8                     ; poáet bitñ vzorku
FilCG41: shl       dx,1
         shl       dx,1                     ; posun st©adaáe barvy
         shl       ah,1                     ; je pop©ed° nebo pozad° ?
         jnc       FilCG42                  ; je pozad°
         or        dl,bl                    ; barva pop©ed°
         jmp       short FilCG43
FilCG42: or        dl,bh                    ; je barva pozad°
FilCG43: loop      FilCG41                  ; dal®° bit vzorku
         test      di,1                     ; je lich† ukl†dac° adresa ?
         jz        FilCG44                  ; je sud† adresa
         xchg      dh,dl                    ; lich† adresa - bude nië®° á†st

; ------ zobrazen° prvn°ho bajtu linky

FilCG44: mov       ah,cs:[MaskFrst]         ; maska prvn°ho bajtu
         mov       al,dh                    ; prvn° bajt k z†pisu
         and       al,ah                    ; zamaskov†n° prvn°ho bajtu
         not       ah                       ; inverze masky
         and       es:[di],ah               ; maskov†n° starÇho bajtu
         or        es:[di],al               ; z†pis novÇho bajtu
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
         mov       ch,0                     ; CX=poáet bajtñ
         shr       cx,1                     ; poáet bajtñ / 2
         mov       ax,dx                    ; vzorek k z†pisu
         rep       stosw                    ; z†pis vnit©n°ch bajtñ
         jnc       FilCG45                  ; byl sudò poáet bajtñ
         stosb                              ; z†pis lichÇho bajtu
         xchg      dh,dl                    ; jako dal®° bude vy®®° bajt

; ------ zobrazen° posledn°ho bajtu linky

FilCG45: mov       ah,cs:[MaskLst]          ; maska posledn°ho bajtu
         mov       al,dl                    ; posledn° bajt k z†pisu
         and       al,ah                    ; zamaskov†n° posledn°ho bajtu
         not       ah                       ; inverze masky
         and       es:[di],ah               ; maskov†n° starÇho bajtu
         or        es:[di],al               ; z†pis novÇho bajtu

; ------ nastaven° ukazatele na dal®° vzorek vòplnà

         inc       si                       ; zvò®en° adresy vòplnà
         cmp       si,offset Pattern+8      ; p©ekroáen konec tabulky ?
         jb        FilCG46                  ; konec tabulky nep©ekroáen
         mov       si,offset Pattern        ; ukazatel na zaá†tek tabulky
FilCG46: ret

; -----------------------------------------------------------------------------
;        Vymaz†n° displeje CGA - m¢dy 6 a 17
; -----------------------------------------------------------------------------

PUBLIC   ClrCG6
ClrCG6:
         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° objektu v CGA (2 bity na bod)
; -----------------------------------------------------------------------------
; VSTUP: DS=CS
;        ES:DI=poá†teán° adresa videopamàti
;        kromà SI a BP nemus° uchov†vat registry
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=poá†teán° adresa pro zobrazen° objektu
; -----------------------------------------------------------------------------
; ˛
PUBLIC   PrepCG4
PrepCG4:

; ------ vòpoáet poátu bajtñ na linku

         mov       ax,ds:[Sirka]            ; ®°©ka vò©ezu (bodñ)
         add       ax,3                     ; zaokrouhlen° na 4 body
         shr       ax,1
         shr       ax,1                     ; p©evod na bajty
         mov       ds:[SirkaB],ax           ; ®°©ka linky v batech

; ------ vòpoáet poátu bajtñ na rovinu

         mul       word ptr ds:[Vyska]      ; poáet bajtñ na rovinu
         mov       ds:[RovinaB],ax          ; poáet bajtñ na rovinu

; ------ vòpoáet prvn° masky objektu (levò okraj)

         mov       cl,byte ptr ds:[ObjLD]   ; levò okraj zaá†tku zobrazen°
         and       cl,3                     ; pozice 0 aë 3
         mov       al,0ffh                  ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo
         shr       al,cl                    ; je®tà jednou rotace (2 bity/bod)
         mov       ds:[MaskFrst],al         ; maska prvn°ho bajtu

; ------ vòpoáet rotace objektu

         mov       ax,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
         sub       ax,ds:[ObjLO]            ; teoretickò levò okraj objektu
         and       al,3                     ; rozd°l f†ze v bodech
         shl       al,1                     ; rotace objektu vpravo
         mov       ds:[MaskRot],al          ; rotace objektu vpravo (v bitech)

; ------ vòpoáet poátu zbylòch bodñ

         mov       bl,4                     ; poáet bodñ na bajt
         sub       bl,cl                    ; poáet bodñ v prvn°m bajtu (1 aë 4)
         mov       bh,0                     ; BX=poáet bodñ zobrazenòch vlevo
         mov       ax,ds:[ObjS]             ; ®°©ka pro zobrazen° objektu
         sub       ax,bx                    ; poáet zbylòch bodñ
         js        PrepCG43                 ; je malò poáet bodñ

; ------ vòpoáet poátu celòch bajtñ

         mov       bx,ax                    ; £schova poátu zbylòch bodñ
         shr       ax,1
         shr       ax,1                     ; poáet celòch vnit©n°ch bajtñ
         mov       ds:[MaskNum],al          ; poáet vnit©n°ch bajtñ

; ------ vòpoáet masky pravÇho okraje

         and       bl,3                     ; poáet zbylòch bodñ vpravo (0 aë 3)
         mov       cl,4                     ; poáet bodñ na bajt
         sub       cl,bl                    ; poáet nezobraz. bodñ vpravo (1-4)
         mov       al,0ffh                  ; maska pravÇho okraje
         shl       al,cl                    ; vòpoáet masky pravÇho okraje
         shl       al,cl                    ; je®tà jednou rotace (2 bity/bod)
         mov       ds:[MaskLst],al          ; maska pravÇho okraje (00 - FC)
         jmp       short PrepCG44

; ------ oprava prvn° masky pro malò poáet bodñ

PrepCG43:add       cl,byte ptr ds:[ObjS]    ; koncov† bitov† pozice+1 (1 aë 3)
         mov       al,4                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
         mov       al,0ffh                  ; maska
         shl       al,cl                    ; rotace korekán° masky
         shl       al,cl                    ; je®tà jednou rotace (2 bity/bod)
         and       ds:[MaskFrst],al         ; oprava prvn° masky
         mov       byte ptr ds:[MaskLst],0  ; nen° prav† maska
         mov       byte ptr ds:[MaskNum],0  ; nen° ë†dnò vnit©n° bajt

; ------ vòpoáet poá†teán° adresy ve videopamàti

PrepCG44:mov       ax,ds:[ObjUD]            ; hodn° okraj poá†tku k zobrazen°
         shr       ax,1                     ; pouze kaëd† sud† linka
         jnc       PrepCG45                 ; je sud† linka
         xor       di,2000h                 ; korekce pro lichou linku
PrepCG45:mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
         add       di,ax                    ; poá†teán° adresa linky
         mov       bx,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° adresy obsluhy zobrazen° linky

         test      byte ptr ds:[Param],8    ; je maska ?
         jz        PrepCG48                 ; nen° maska
         mov       word ptr ds:[bp+ModDisp],offset DispCG3 ; maska bez rotace
         cmp       byte ptr ds:[MaskRot],0  ; je rotace ?
         je        PrepCG49                 ; nen° rotace
         mov       word ptr ds:[bp+ModDisp],offset DispCG4 ; maska s rotac°
         jmp       short PrepCG49

PrepCG48:mov       word ptr ds:[bp+ModDisp],offset DispCG2 ; rotace bez masky
         cmp       byte ptr ds:[MaskRot],0  ; je rotace ?
         jne       PrepCG49                 ; je rotace
         mov       word ptr ds:[bp+ModDisp],offset DispCG1 ; bez rotace i masky
PrepCG49:
         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° objektu v CGA (2 bity na bod)
; -----------------------------------------------------------------------------
; VSTUP: DS=CS
;        ES:DI=poá†teán° adresa videopamàti
;        kromà SI a BP nemus° uchov†vat registry
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=poá†teán° adresa pro zobrazen° objektu
; -----------------------------------------------------------------------------

PUBLIC   PrepCG6
PrepCG6:

         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° roviny CGA
; -----------------------------------------------------------------------------
; VSTUP: BL=rovina
;        DS:SI=poá†teán° adresa prvn° linky
; -----------------------------------------------------------------------------
; VùSTUP: DS:SI=poá†teán° adresa k zobrazen°
;        kromà BP a ES:DI nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   SetCG4
SetCG4:

; ------ nastaven° poá†teán° adresy roviny

         mov       ax,cs:[ObjLO]            ; levò okraj poá†tku v objektu
         shl       ax,1                     ; p©evod na bity
         add       al,cs:[MaskRot]          ; posun o masku
         adc       ah,0                     ; p©enos do vy®®°ho bajtu
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na bajty
         add       si,ax                    ; adresa poá†tku linky
         add       word ptr cs:[MaskAdr],ax ; poá†teán° adresa masky
         ret


; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° roviny CGA
; -----------------------------------------------------------------------------
; VSTUP: BL=rovina
;        DS:SI=poá†teán° adresa prvn° linky
; -----------------------------------------------------------------------------
; VùSTUP: DS:SI=poá†teán° adresa k zobrazen°
;        kromà BP a ES:DI nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   SetCG6
SetCG6:

; ------ nastaven° poá†teán° adresy roviny

         mov       ax,cs:[ObjLO]            ; levò okraj poá†tku v objektu
         add       al,cs:[MaskRot]          ; posun o masku
         adc       ah,0                     ; p©enos do vy®®°ho bajtu
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na bajty
         add       si,ax                    ; adresa poá†tku linky
         add       word ptr cs:[MaskAdr],ax ; poá†teán° adresa masky
         ret


; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du CGA - bez masky i bez rotace
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispCG1

; ------ £schova registrñ

DispCG1: push      di

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         mov       ch,0
         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky

; ------ zobrazen° prvn°ho bajtu linky
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         mov       dl,cs:[MaskFrst]         ; maska prvn°ho bajtu
         lodsb                              ; rovina
         and       al,dl                    ; maskov†n° bajtu
         not       dl                       ; inverze masky
         mov       ah,es:[di]               ; pñvodn° bajt
         and       ah,dl                    ; maskov†n° prvn°ho bajtu
         or        al,ah                    ; nastaven° novÇho bajtu
         stosb                              ; uloëen° novÇho bajtu

; ------ zobrazen° vnit©n°ch bajtñ linky
                                            ; CX=poáet bajtñ
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         rep       movsb                    ; p©enos vnit©n°ch bajtñ

; ------ zobrazen° posledn°ho bajtu linky
                                            ; CL=rotace bajtu vpravo
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         mov       dl,cs:[MaskLst]          ; maska posledn°ho bajtu
         lodsb                              ; rovina
         and       al,dl                    ; maskov†n° bajtu
         not       dl                       ; inverze masky
         mov       ah,es:[di]               ; pñvodn° bajt
         and       ah,dl                    ; maskov†n° prvn°ho bajtu
         or        al,ah                    ; nastaven° novÇho bajtu
         stosb                              ; uloëen° novÇho bajtu

; ------ zvò®en° adresy displeje

         pop       di
         cmp       byte ptr cs:[VMod],17    ; je videom¢d 17 (MCGA) ?
         je        DispCG18                 ; je videom¢d 17 (MCGA)
         xor       di,2000h
         test      di,2000h                 ; je sud† linka ?
         jnz       DispCG19                 ; je lich† linka
DispCG18:add       di,80                    ; p©iáten° poátu bajtñ na ©†dek

DispCG19:ret

; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du CGA - rotace bez masky
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispCG2

; ------ £schova registrñ

DispCG2: push      di

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskRot]          ; poáet rotac° bajtu
         mov       ch,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky

; ------ zobrazen° prvn°ho bajtu linky
                                            ; CL=rotace bajtu vpravo
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         mov       dl,cs:[MaskFrst]         ; maska prvn°ho bajtu
         mov       ah,ds:[si-1]
         mov       al,ds:[si]               ; rovina
         ror       ax,cl                    ; rotace na pozici
         and       al,dl                    ; maskov†n° bajtu
         not       dl                       ; inverze masky
         mov       ah,es:[di]               ; pñvodn° bajt
         and       ah,dl                    ; maskov†n° prvn°ho bajtu
         or        al,ah                    ; nastaven° novÇho bajtu
         stosb                              ; uloëen° novÇho bajtu

; ------ zobrazen° vnit©n°ch bajtñ linky
                                            ; CL=rotace vpravo
                                            ; CH=poáet bajtñ
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         or        ch,ch                    ; je nàjakò vnit©n° bajt ?
         jz        DispCG23                 ; nen° ë†dnò vnit©n° bajt
DispCG22:mov       ah,ds:[si]               ; rovina
         mov       al,ds:[si+1]
         inc       si                       ; zvò®en° adresy roviny
         ror       ax,cl                    ; rotace na pozici
         stosb                              ; z†pis bajtu na displej
         dec       ch                       ; sn°ëen° á°taáe bajtñ
         jnz       DispCG22                 ; z†pis dal®°ho bajtu

; ------ zobrazen° posledn°ho bajtu linky
                                            ; CL=rotace bajtu vpravo
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

DispCG23:mov       dl,cs:[MaskLst]          ; maska posledn°ho bajtu
         mov       ah,ds:[si]
         mov       al,ds:[si+1]             ; rovina
         ror       ax,cl                    ; rotace na pozici
         and       al,dl                    ; maskov†n° bajtu
         not       dl                       ; inverze masky
         mov       ah,es:[di]               ; pñvodn° bajt
         and       ah,dl                    ; maskov†n° prvn°ho bajtu
         or        al,ah                    ; nastaven° novÇho bajtu
         stosb                              ; uloëen° novÇho bajtu

; ------ zvò®en° adresy displeje

         pop       di
         cmp       byte ptr cs:[VMod],17    ; je videom¢d 17 (MCGA) ?
         je        DispCG28                 ; je videom¢d 17 (MCGA)
         xor       di,2000h
         test      di,2000h                 ; je sud† linka ?
         jnz       DispCG29                 ; je lich† linka
DispCG28:add       di,80                    ; p©iáten° poátu bajtñ na ©†dek

DispCG29:ret


; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du CGA - rotace s maskou
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispCG4

DispCG3:

; ------ £schova registrñ

DispCG4: push      di
         push      bp

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskRot]          ; poáet rotac° bajtu
         mov       ch,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
         mov       bx,word ptr cs:[MaskAdr] ; offset adresy masky
         mov       bp,word ptr cs:[MaskAdr+2] ; segment adresy masky

; ------ zobrazen° prvn°ho bajtu linky
                                            ; CL=rotace bajtu vpravo
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa
                                            ; BP:BX=adresa masky

         push      ds
         mov       ds,bp                    ; segment masky
         mov       dh,ds:[bx-1]             ; p©edchoz° bajt masky
         mov       dl,ds:[bx]               ; nië®° bajt masky
         pop       ds
         ror       dx,cl                    ; rotace masky na pozici
         and       dl,cs:[MaskFrst]         ; maska prvn°ho bajtu

         mov       ah,ds:[si-1]
         mov       al,ds:[si]               ; rovina
         ror       ax,cl                    ; rotace na pozici
         and       al,dl                    ; maskov†n° bajtu
         not       dl                       ; inverze masky
         mov       ah,es:[di]               ; pñvodn° bajt
         and       ah,dl                    ; maskov†n° prvn°ho bajtu
         or        al,ah                    ; sestaven° novÇho bajtu
         stosb                              ; uloëen° novÇho bajtu

; ------ zobrazen° vnit©n°ch bajtñ linky
                                            ; CL=rotace vpravo
                                            ; CH=poáet bajtñ
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa
                                            ; BP:BX=adresa masky

         or        ch,ch                    ; je nàjakò vnit©n° bajt ?
         jz        DispCG43                 ; nen° ë†dnò vnit©n° bajt
DispCG42:
         push      ds
         mov       ds,bp                    ; segment masky
         mov       dh,ds:[bx]               ; prvn° bajt masky
         mov       dl,ds:[bx+1]             ; druhò bajt masky
         inc       bx                       ; zvò®en° ukazatele masky
         pop       ds
         ror       dx,cl                    ; rotace masky na pozici

         mov       ah,ds:[si]               ; rovina
         mov       al,ds:[si+1]
         inc       si                       ; zvò®en° adresy roviny
         ror       ax,cl                    ; rotace na pozici
         and       al,dl                    ; maskov†n° novÇho bajtu
         not       dl                       ; inverze masky
         mov       ah,es:[di]               ; pñvodn° bajt
         and       ah,dl                    ; maskov†n° pñvodn°ho bajtu
         or        al,ah                    ; sestaven° novÇho bajtu
         stosb                              ; z†pis bajtu na displej
         dec       ch                       ; sn°ëen° á°taáe bajtñ
         jnz       DispCG42                 ; z†pis dal®°ho bajtu

; ------ zobrazen° posledn°ho bajtu linky
                                            ; CL=rotace bajtu vpravo
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa
                                            ; BP:BX=adresa masky
DispCG43:
         push      ds
         mov       ds,bp                    ; segment masky
         mov       dh,ds:[bx]               ; prvn° bajt masky
         mov       dl,ds:[bx+1]             ; druhò bajt masky
         pop       ds
         ror       dx,cl                    ; rotace masky na pozici
         and       dl,cs:[MaskLst]          ; maska posledn°ho bajtu

         mov       ah,ds:[si]               ; rovina
         mov       al,ds:[si+1]
         ror       ax,cl                    ; rotace na pozici
         and       al,dl                    ; maskov†n° novÇho bajtu
         not       dl                       ; inverze masky
         mov       ah,es:[di]               ; pñvodn° bajt
         and       ah,dl                    ; maskov†n° pñvodn°ho bajtu
         or        al,ah                    ; sestaven° novÇho bajtu
         stosb                              ; z†pis bajtu na displej

; ------ zvò®en° adresy displeje

         pop       bp
         pop       di

         cmp       byte ptr cs:[VMod],17    ; je videom¢d 17 (MCGA) ?
         je        DispCG48                 ; je videom¢d 17 (MCGA)
         xor       di,2000h
         test      di,2000h                 ; je sud† linka ?
         jnz       DispCG49                 ; je lich† linka
DispCG48:add       di,80                    ; p©iáten° poátu bajtñ na ©†dek

DispCG49:ret

; -----------------------------------------------------------------------------
;        Zobrazen° á†ry v m¢du CGA 4
; -----------------------------------------------------------------------------

LineCG4:
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° á†ry v m¢du CGA 6
; -----------------------------------------------------------------------------

LineCG6:
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° bodu v m¢du CGA 4
; -----------------------------------------------------------------------------

PointCG4:
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° bodu v m¢du CGA 6
; -----------------------------------------------------------------------------

PointCG6:
         ret

; -----------------------------------------------------------------------------
;        Vymaz†n° obdÇln°ku v m¢du EGA (ES:DI=videopamàü, DS:BP=tab., AX=barva)
; -----------------------------------------------------------------------------
; ˛
PUBLIC   ClrEGA
ClrEGA:
         mov       bx,ax                    ; poëadovan† barva (£schova)

; ------ korekce, pokud nen° ë†dnÇ pozad°

         cmp       byte ptr cs:[AndPatt],0ffh ; je nàjakÇ pozad° ?
         jne       ClrEGA0                  ; je nàjakÇ pozad°
         mov       bh,bl                    ; barva pozad° stejn† jako pop©ed°

; ------ inicializace registrñ videokarty EGA

ClrEGA0: call      InitREGA                 ; inicializace registrñ EGA

; ------ nastaven° barvy pro stejnÇ roviny pop©ed° i pozad°

         mov       dx,3ceh
         mov       al,0
         out       dx,al
         inc       dx
         mov       al,bl                    ; barva pop©ed°
         out       dx,al                    ; shodn† barva pop©ed° i pozad°
         dec       dx

; ------ maska stejnòch rovin pop©ed° i pozad°

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,bl                    ; barva pop©ed°
         xor       al,bh                    ; porovn†n° s pozad°m
         not       al                       ; maska stejnòch rovin
         out       dx,al                    ; nastaven° masky stejnòch rovin

; ------ nastaven° masky rovin pro prvn° f†zi zobrazen°

         or        al,bl                    ; stejnÇ roviny a pop©ed°
         mov       ah,al                    ; £schova masky rovin
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; registr masky
         inc       dx
         mov       al,ah                    ; maska pro prvn° f†zi
         out       dx,al                    ; nastaven° masky rovin prvn° f†ze

; ------ vòpoáet prvn° masky objektu (levò okraj)

         mov       cl,byte ptr ds:[ObjLD]   ; levò okraj zaá†tku zobrazen°
         and       cl,7                     ; poá†teán° bitov† pozice (0 aë 7)
         mov       al,0ffh                  ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (FF aë 01)
         mov       ds:[MaskFrst],al         ; maska prvn°ho bajtu

; ------ vòpoáet poátu zbylòch bodñ

         mov       dl,8                     ; poáet bodñ na bajt
         sub       dl,cl                    ; poáet necelòch bodñ vlevo (1 aë 8)
         mov       dh,0                     ; BX=poáet bodñ zobrazenòch vlevo
         mov       ax,ds:[ObjS]             ; ®°©ka pro zobrazen° objektu
         sub       ax,dx                    ; poáet zbylòch bodñ
         js        ClrEGA1                  ; je malò poáet bodñ

; ------ vòpoáet poátu celòch bajtñ

         mov       dx,ax                    ; £schova poátu zbylòch bodñ
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; poáet celòch vnit©n°ch bajtñ
         mov       ds:[MaskNum],al          ; poáet vnit©n°ch bajtñ

; ------ vòpoáet masky pravÇho okraje

         and       dl,7                     ; poáet zbylòch bodñ vpravo (0 aë 7)
         mov       cl,8                     ; poáet bodñ na bajt
         sub       cl,dl                    ; poáet nezobraz. bodñ vpravo (1-8)
         mov       al,0ffh                  ; maska pravÇho okraje
         shl       al,cl                    ; vòpoáet masky pravÇho okr. (00-FE)
         mov       ds:[MaskLst],al          ; maska pravÇho okraje (00 - FE)
         jmp       short ClrEGA2

; ------ oprava prvn° masky pro malò poáet bodñ

ClrEGA1: add       cl,byte ptr ds:[ObjS]    ; koncov† bitov† pozice+1 (1 aë 6)
         mov       al,8                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
         mov       al,0ffh                  ; maska
         shl       al,cl                    ; rotace korekán° masky
         and       ds:[MaskFrst],al         ; oprava prvn° masky
         mov       byte ptr ds:[MaskLst],0  ; nen° prav† maska
         mov       byte ptr ds:[MaskNum],0  ; nen° ë†dnò vnit©n° bajt

; ------ vòpoáet poá†teán° adresy ve videopamàti

ClrEGA2: mov       ax,ds:[ObjUD]            ; hodn° okraj poá†tku k zobrazen°
         mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
         add       di,ax                    ; poá†teán° adresa linky
         mov       dx,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; p©epoáet na offset v bajtech
         add       di,dx                    ; poá†teán° adresa k zobrazen°

; ------ stanoven° vzorku vòplnà

         mov       si,ds:[ObjUD]            ; poá†teán° linka
         and       si,7                     ; opakov†n° po 8 link†ch
         add       si,offset Pattern        ; adresa v tabulce vòpln°

; ------ nastaven° registry masky

         mov       dx,3ceh                  ; ©°dic° registr
         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky

; ------ z†pis obdÇln°ku

         push      si
         push      di

         mov       cx,ds:[ObjV]             ; vò®ka obdÇln°ku v link†ch
ClrEGA4: push      cx                       ; £schova á°taáe linek
         push      di                       ; £schova ukl†dac° adresy
         mov       ah,ds:[si]
         call      FilEGA                   ; z†pis jednÇ linky
         pop       di                       ; ukl†dac° adresa
         pop       cx                       ; n†vrat á°taáe linek
         add       di,ds:[bp+ModSirB]       ; zvò®en° adresy ve videopamàti
         loop      ClrEGA4                  ; zobrazen° dal®° linky

         pop       di
         pop       si

; ------ stanoven° masky pro opravu pozad°

         xor       bl,bh                    ; porovn†n° pop©ed° a pozad°
         and       bl,bh                    ; maska rovin pozad°
         jz        ClrEGA9                  ; nezbyla ë†dn† rovina

; ------ volba rovin pro opravu pozad°

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,bl                    ; maska rovin pro opravu pozad°
         out       dx,al

; ------ p©°prava registru masky 8

         mov       dx,3ceh
         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky

; ------ z†pis opravy pozad° obdÇln°ku

         mov       cx,ds:[ObjV]             ; vò®ka obdÇln°ku v link†ch
ClrEGA5: mov       ah,ds:[si]
         not       ah                       ; pozad°
         push      cx                       ; £schova á°taáe linek
         push      di                       ; £schova ukl†dac° adresy
         call      FilEGA                   ; z†pis jednÇ linky
         pop       di                       ; ukl†dac° adresa
         pop       cx                       ; n†vrat á°taáe linek
         add       di,ds:[bp+ModSirB]       ; zvò®en° adresy ve videopamàti
         loop      ClrEGA5                  ; zobrazen° dal®° linky

; ------ n†vrat registrñ

ClrEGA9: mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
         dec       dx
         mov       al,1
         out       dx,al
         inc       dx
         xor       al,al
         out       dx,al
         ret




;         mov       bx,ax                    ; poëadovan† barva
;
;; ------ inicializace registrñ videokarty EGA
;
;         call      InitREGA                 ; inicializace registrñ EGA
;
;; ------ vòpoáet prvn° masky objektu (levò okraj)
;
;         mov       cl,byte ptr ds:[ObjLD]   ; levò okraj zaá†tku zobrazen°
;         and       cl,7                     ; poá†teán° bitov† pozice (0 aë 7)
;         mov       al,0ffh                  ; inicializaán° maska
;         shr       al,cl                    ; rotace masky vpravo (FF aë 01)
;         mov       ds:[MaskFrst],al         ; maska prvn°ho bajtu
;
;; ------ vòpoáet poátu zbylòch bodñ
;
;         mov       dl,8                     ; poáet bodñ na bajt
;         sub       dl,cl                    ; poáet necelòch bodñ vlevo (1 aë 8)
;         mov       dh,0                     ; BX=poáet bodñ zobrazenòch vlevo
;         mov       ax,ds:[ObjS]             ; ®°©ka pro zobrazen° objektu
;         sub       ax,dx                    ; poáet zbylòch bodñ
;         js        ClrEGA1                  ; je malò poáet bodñ
;
;; ------ vòpoáet poátu celòch bajtñ
;
;         mov       dx,ax                    ; £schova poátu zbylòch bodñ
;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; poáet celòch vnit©n°ch bajtñ
;         mov       ds:[MaskNum],al          ; poáet vnit©n°ch bajtñ
;
;; ------ vòpoáet masky pravÇho okraje
;
;         and       dl,7                     ; poáet zbylòch bodñ vpravo (0 aë 7)
;         mov       cl,8                     ; poáet bodñ na bajt
;         sub       cl,dl                    ; poáet nezobraz. bodñ vpravo (1-8)
;         mov       al,0ffh                  ; maska pravÇho okraje
;         shl       al,cl                    ; vòpoáet masky pravÇho okr. (00-FE)
;         mov       ds:[MaskLst],al          ; maska pravÇho okraje (00 - FE)
;         jmp       short ClrEGA2
;
;; ------ oprava prvn° masky pro malò poáet bodñ
;
;ClrEGA1: add       cl,byte ptr ds:[ObjS]    ; koncov† bitov† pozice+1 (1 aë 6)
;         mov       al,8                     ; poáet bodñ na bajt
;         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
;         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
;         mov       al,0ffh                  ; maska
;         shl       al,cl                    ; rotace korekán° masky
;         and       ds:[MaskFrst],al         ; oprava prvn° masky
;         mov       byte ptr ds:[MaskLst],0  ; nen° prav† maska
;         mov       byte ptr ds:[MaskNum],0  ; nen° ë†dnò vnit©n° bajt
;
;; ------ vòpoáet poá†teán° adresy ve videopamàti
;
;ClrEGA2: mov       ax,ds:[ObjUD]            ; hodn° okraj poá†tku k zobrazen°
;         mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
;         add       di,ax                    ; poá†teán° adresa linky
;         mov       dx,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
;         shr       dx,1
;         shr       dx,1
;         shr       dx,1                     ; p©epoáet na offset v bajtech
;         add       di,dx                    ; poá†teán° adresa k zobrazen°
;
;; ------ stanoven° vzorku vòplnà
;
;         mov       si,ds:[ObjUD]            ; poá†teán° linka
;         and       si,7                     ; opakov†n° po 8 link†ch
;         add       si,offset Pattern        ; adresa v tabulce vòpln°
;
;; ------ p©°prava registrñ pro nastaven° barevnÇ roviny
;
;         mov       ch,ds:[bp+ModRov]        ; poáet barevnòch rovin
;         mov       cl,1                     ; bit masky roviny
;
;; ------ nastaven° barevnÇ roviny
;
;ClrEGA3: mov       dx,3c4h                  ; port pro nastaven° barevnÇ roviny
;         mov       al,2
;         out       dx,al                    ; registr 0 - volba barevnÇ roviny
;         inc       dx
;         mov       al,cl                    ; maska roviny
;         out       dx,al                    ; volba barevnÇ roviny
;
;; ------ nastaven° registry masky
;
;         mov       dx,3ceh                  ; ©°dic° registr
;         mov       al,8
;         out       dx,al                    ; volba registru 8 - reg. masky
;         inc       dx                       ; 3cfh - adresa registru masky
;
;; ------ z†pis obdÇln°ku do jednÇ roviny
;
;         push      cx                       ; £schova á°taáe rovin
;         push      di                       ; £schova adresy videopamàti
;         push      si                       ; £schova ukazatele vzorkñ
;         mov       cx,ds:[ObjV]             ; vò®ka obdÇln°ku v link†ch
;ClrEGA4: push      cx                       ; £schova á°taáe linek
;         push      di                       ; £schova ukl†dac° adresy
;         call      FilEGA                   ; z†pis jednÇ linky
;         pop       di                       ; ukl†dac° adresa
;         pop       cx                       ; n†vrat á°taáe linek
;         add       di,ds:[bp+ModSirB]       ; zvò®en° adresy ve videopamàti
;         loop      ClrEGA4                  ; zobrazen° dal®° linky
;         pop       si                       ; n†vrat ukazatele vzorkñ
;         pop       di                       ; n†vrat adresy videopamàti
;         pop       cx                       ; n†vrat á°taáe rovin
;
;; ------ zvò®en° ukazatele roviny
;
;         shr       bx,1                     ; posun barev na dal®° rovinu
;         shl       cl,1                     ; posun bitu masky roviny
;         dec       ch                       ; sn°ëen° á°taáe rovin
;         jnz       ClrEGA3                  ; z†pis dal®° roviny
;
;; ------ n†vrat registrñ
;
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° masky pro v®echny bity
;         ret

; -----------------------------------------------------------------------------
;        Inicializace registrñ EGA
; -----------------------------------------------------------------------------

PUBLIC   InitREGA
InitREGA:
         push      ax
         push      dx

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         mov       al,0fh
         inc       dx
         out       dx,al                    ; z†pis do v®ech rovin

         mov       dx,3ceh
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; z†pisovò m¢d 0
         dec       dx

         mov       al,0
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al                    ; v®echny roviny pro z†pis
         dec       dx

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; ë†dn† rovina pro XOR
         dec       dx

         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; funkce z†pisu beze zmàny dat

         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Vymaz†n° linku v m¢du EGA (pro jednu rovinu)
; -----------------------------------------------------------------------------
; VSTUP: AH=vzorek
;        ES:DI=ukl†dac° adresa
;        DS:SI=adresa vzorku
;        DX=adresa registru 3cfh (nastaven registr 8)
; VùSTUP: DS:SI=adresa dal®°ho vzorku
; zniáenÇ registry: AL, DI, CX
; -----------------------------------------------------------------------------

PUBLIC   FilEGA
FilEGA:

; ------ zobrazen° prvn°ho bajtu linky

         mov       al,cs:[MaskFrst]         ; maska prvn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ah                    ; vzorek vòplnà
         xchg      al,es:[di]               ; z†pis prvn°ho bajtu linky
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
         mov       ch,0                     ; CX=poáet bajtñ
         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° z†pisu pro v®echny bity
         mov       al,ah                    ; vzorek vòplnà

; ------ z†pis vnit©n°ch bajtñ rychlej®° metodou

FilEGA2: test      di,1                     ; je lich† adresa ?
         jnz       FilEGA5                  ; je lich† adresa

                                          ;* je sud† adresa
         shr       cx,1                     ; poáet bajtñ / 2
FilEGA6: rep       stosw                    ; z†pis vnit©n°ch bajtñ
         jnc       FilEGA7                  ; byl sudò poáet bajtñ
         stosb                              ; z†pis lichÇho bajtu
         jmp       short FilEGA7

                                          ;* je lich† adresa
FilEGA5: shr       cx,1                     ; poáet bajtñ / 2
         jnc       FilEGA4                  ; je sudò poáet bajtñ
         stosb                              ; z†pis lichÇho bajtu
FilEGA4: rep       stosw                    ; z†pis vnit©n°ch bajtñ

; ------ zobrazen° posledn°ho bajtu linky

FilEGA7: mov       al,cs:[MaskLst]          ; maska posledn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ah                    ; vzorek vòplnà
         xchg      al,es:[di]               ; z†pis posledn°ho bajtu linky

; ------ nastaven° ukazatele na dal®° vòpl§

         inc       si                       ; zvò®en° adresy vòplnà
         cmp       si,offset Pattern+8      ; p©ekroáen konec tabulky ?
         jb        FilEGA3                  ; konec tabulky nep©ekroáen
         mov       si,offset Pattern        ; ukazatel na zaá†tek tabulky
FilEGA3: ret



;
;; ------ stanoven° vzorku vòplnà
;
;         mov       ah,0                     ; p©ednastaven° - nen° ë†dn† barva
;         test      bh,1                     ; je pozad° ?
;         jz        FilEGA1                  ; pozad° nen°
;         mov       ah,ds:[si]               ; vzorek vòplnà
;         not       ah                       ; negace - plat° bity 0
;FilEGA1: test      bl,1                     ; je pop©ed° ?
;         jz        FilEGA2                  ; nen° pop©ed°
;         or        ah,ds:[si]               ; nastaven° bitñ pro pop©ed°
;
;; ------ zobrazen° prvn°ho bajtu linky
;
;FilEGA2: mov       al,cs:[MaskFrst]         ; maska prvn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         mov       al,ah                    ; vzorek pro vòpl§
;         xchg      al,es:[di]               ; z†pis prvn°ho bajtu linky
;         inc       di                       ; zvò®en° ukl†dac° adresy
;
;; ------ zobrazen° vnit©n°ch bajtñ linky
;
;         cld                                ; smàr nahoru
;         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
;         mov       ch,0                     ; CX=poáet bajtñ
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° z†pisu pro v®echny bity
;         mov       al,ah                    ; vzorek pro z†pis
;
;         test      di,1                     ; je lich† adresa ?
;         jnz       FilEGA5                  ; je lich† adresa
;
;                                          ;* je sud† adresa
;         shr       cx,1                     ; poáet bajtñ / 2
;FilEGA6: rep       stosw                    ; z†pis vnit©n°ch bajtñ
;         jnc       FilEGA7                  ; byl sudò poáet bajtñ
;         stosb                              ; z†pis lichÇho bajtu
;         jmp       short FilEGA7
;
;                                          ;* je lich† adresa
;FilEGA5: shr       cx,1                     ; poáet bajtñ / 2
;         jnc       FilEGA4                  ; je sudò poáet bajtñ
;         stosb                              ; z†pis lichÇho bajtu
;FilEGA4: rep       stosw                    ; z†pis vnit©n°ch bajtñ
;
;; ------ zobrazen° posledn°ho bajtu linky
;
;FilEGA7: mov       al,cs:[MaskLst]          ; maska posledn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         mov       al,ah                    ; vzorek
;         xchg      al,es:[di]               ; z†pis posledn°ho bajtu linky
;
;; ------ nastaven° ukazatele na dal®° vòpl§
;
;         inc       si                       ; zvò®en° adresy vòplnà
;         cmp       si,offset Pattern+8      ; p©ekroáen konec tabulky ?
;         jb        FilEGA3                  ; konec tabulky nep©ekroáen
;         mov       si,offset Pattern        ; ukazatel na zaá†tek tabulky
;FilEGA3: ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° objektu v EGA
; -----------------------------------------------------------------------------
; VSTUP: DS=CS
;        ES:DI=poá†teán° adresa videopamàti
;        kromà SI a BP nemus° uchov†vat registry
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=poá†teán° adresa pro zobrazen° objektu
; -----------------------------------------------------------------------------

PUBLIC   PrepEGA
PrepEGA:

; ------ inicializace registrñ

         call      InitREGA                 ; inicializace registrñ EGA

; ------ vòpoáet poátu bajtñ na linku

         mov       ax,ds:[Sirka]            ; ®°©ka vò©ezu (bodñ)
         add       ax,7                     ; zaokrouhlen°
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na bajty
         mov       ds:[SirkaB],ax           ; ®°©ka linky v batech

; ------ vòpoáet poátu bajtñ na rovinu

         mul       word ptr ds:[Vyska]      ; poáet bajtñ na rovinu
         mov       ds:[RovinaB],ax          ; poáet bajtñ na rovinu

; ------ vòpoáet prvn° masky objektu (levò okraj)

         mov       cl,byte ptr ds:[ObjLD]   ; levò okraj zaá†tku zobrazen°
         and       cl,7                     ; poá†teán° bitov† pozice (0 aë 7)
         mov       al,0ffh                  ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (FF aë 01)
         mov       ds:[MaskFrst],al         ; maska prvn°ho bajtu

; ------ vòpoáet rotace objektu

         mov       ax,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
         sub       ax,ds:[ObjLO]            ; teoretickò levò okraj objektu
         and       al,7                     ; rotace objektu vpravo (0 aë 7)
         mov       ds:[MaskRot],al          ; rotace objektu vpravo

; ------ vòpoáet poátu zbylòch bodñ

         mov       bl,8                     ; poáet bodñ na bajt
         sub       bl,cl                    ; poáet necelòch bodñ vlevo (1 aë 8)
         mov       bh,0                     ; BX=poáet bodñ zobrazenòch vlevo
         mov       ax,ds:[ObjS]             ; ®°©ka pro zobrazen° objektu
         sub       ax,bx                    ; poáet zbylòch bodñ
         js        PrepEGA3                 ; je malò poáet bodñ

; ------ vòpoáet poátu celòch bajtñ

         mov       bx,ax                    ; £schova poátu zbylòch bodñ
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; poáet celòch vnit©n°ch bajtñ
         mov       ds:[MaskNum],al          ; poáet vnit©n°ch bajtñ

; ------ vòpoáet masky pravÇho okraje

         and       bl,7                     ; poáet zbylòch bodñ vpravo (0 aë 7)
         mov       cl,8                     ; poáet bodñ na bajt
         sub       cl,bl                    ; poáet nezobraz. bodñ vpravo (1-8)
         mov       al,0ffh                  ; maska pravÇho okraje
         shl       al,cl                    ; vòpoáet masky pravÇho okr. (00-FE)
         mov       ds:[MaskLst],al          ; maska pravÇho okraje (00 - FE)
         jmp       short PrepEGA4

; ------ oprava prvn° masky pro malò poáet bodñ

PrepEGA3:add       cl,byte ptr ds:[ObjS]    ; koncov† bitov† pozice+1 (1 aë 6)
         mov       al,8                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
         mov       al,0ffh                  ; maska
         shl       al,cl                    ; rotace korekán° masky
         and       ds:[MaskFrst],al         ; oprava prvn° masky
         mov       byte ptr ds:[MaskLst],0  ; nen° prav† maska
         mov       byte ptr ds:[MaskNum],0  ; nen° ë†dnò vnit©n° bajt

; ------ vòpoáet poá†teán° adresy ve videopamàti

PrepEGA4:mov       ax,ds:[ObjUD]            ; hodn° okraj poá†tku k zobrazen°
         mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
         add       di,ax                    ; poá†teán° adresa linky
         mov       bx,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° adresy obsluhy zobrazen° linky

         test      byte ptr ds:[Param],8    ; je maska ?
         jz        PrepEGA5                 ; nen° maska
         mov       word ptr ds:[bp+ModDisp],offset DispEG3 ; maska bez rotace
         cmp       byte ptr ds:[MaskRot],0  ; je rotace ?
         je        PrepEGA6                 ; nen° rotace
         mov       word ptr ds:[bp+ModDisp],offset DispEG4 ; maska s rotac°
         jmp       short PrepEGA6

PrepEGA5:mov       word ptr ds:[bp+ModDisp],offset DispEG2 ; rotace bez masky
         cmp       byte ptr ds:[MaskRot],0  ; je rotace ?
         jne       PrepEGA6                 ; je rotace
         mov       word ptr ds:[bp+ModDisp],offset DispEG1 ; bez rotace i masky
PrepEGA6:
         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° roviny EGA
; -----------------------------------------------------------------------------
; VSTUP: BL=rovina
;        DS:SI=poá†teán° adresa prvn° linky
; -----------------------------------------------------------------------------
; VùSTUP: DS:SI=poá†teán° adresa k zobrazen°
;        kromà BP a ES:DI nemus° uchov†vat registry
; -----------------------------------------------------------------------------
; ˛
PUBLIC   SetEGA
SetEGA:

; ------ uráen° vòstupn° roviny

         mov       cl,bl                    ; á°slo roviny
         mov       al,1
         shl       al,cl                    ; rotace na pozici
         mov       cl,al                    ; á°slo roviny (bitov† maska)

; ------ nastaven° roviny pro vòstup

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; registr 0 - volba barevnÇ roviny
         inc       dx
         mov       al,cl                    ; maska roviny
         out       dx,al                    ; volba barevnÇ roviny

; ------ nastaven° v®ech bitñ pro z†pis

         mov       dx,3ceh
         mov       al,8
         out       dx,al                    ; registr 8 - maska pro z†pis
         inc       dx
         mov       al,0ffh
         out       dx,al                    ; z†pis moëny pro v®echny body

; ------ nastaven° poá†teán° adresy roviny

         mov       ax,cs:[ObjLO]            ; levò okraj poá†tku v objektu
         add       al,cs:[MaskRot]          ; posun o masku
         adc       ah,0                     ; p©enos do vy®®°ho bajtu
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na bajty
         add       si,ax                    ; adresa poá†tku linky
         add       word ptr cs:[MaskAdr],ax ; poá†teán° adresa masky

         ret

; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du EGA - bez rotace a bez masky
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispEG1

; ------ £schova registrñ

DispEG1: push      di

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
         mov       ch,0                     ; CX=poáet bajtñ
         mov       dx,3cfh                  ; registr masky

; ------ zobrazen° prvn°ho bajtu linky

         mov       al,cs:[MaskFrst]         ; maska prvn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         lodsb
         xchg      al,es:[di]
         inc       di

; ------ zobrazen° vnit©n°ch bajtñ linky

         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° z†pisu pro v®echny bity
         rep       movsb                    ; p©enos vnit©n°ch bajtñ

; ------ zobrazen° posledn°ho bajtu linky

         mov       al,cs:[MaskLst]          ; maska posledn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         lodsb
         xchg      al,es:[di]

; ------ n†vrat registrñ

         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
         pop       di
         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
         ret


; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du EGA - rotace bez masky
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispEG2

; ------ £schova registrñ

DispEG2: push      di
         push      bp

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskRot]          ; poáet rotac° bajtu
         mov       ch,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
         mov       dx,3cfh                  ; registr masky

; ------ zobrazen° prvn°ho bajtu linky
                                            ; CL=rotace bajtu vpravo
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         mov       al,cs:[MaskFrst]         ; maska prvn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       ah,ds:[si-1]
         mov       al,ds:[si]               ; rovina
         ror       ax,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z†pis bajtu na displej
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky
                                            ; CL=rotace vpravo
                                            ; CH=poáet bajtñ
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         or        ch,ch                    ; je nàjakò vnit©n° bajt ?
         jz        DispEG23                 ; nen° ë†dnò vnit©n° bajt
         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
DispEG22:mov       ah,ds:[si]               ; rovina
         mov       al,ds:[si+1]
         inc       si                       ; zvò®en° adresy roviny
         ror       ax,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z†pis bajtu na displej
         inc       di                       ; zvò®en° ukl†dac° adresy
         dec       ch                       ; sn°ëen° á°taáe bajtñ
         jnz       DispEG22                 ; z†pis dal®°ho bajtu

; ------ zobrazen° posledn°ho bajtu linky
                                            ; CL=rotace bajtu vpravo
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

DispEG23:mov       al,cs:[MaskLst]          ; maska posledn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ds:[si+1]
         mov       ah,ds:[si]               ; rovina
         ror       ax,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z†pis bajtu na displej

; ------ n†vrat registrñ

         pop       bp
         pop       di
         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity

         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du EGA - maska bez rotace
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispEG3

; ------ £schova registrñ

DispEG3: push      di
         push      bp

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
         mov       ch,0                     ; CX=poáet vnit©n°ch bajtñ linky
         mov       bx,word ptr cs:[MaskAdr] ; offset adresy masky
         mov       bp,word ptr cs:[MaskAdr+2] ; segment adresy masky
         mov       dx,3cfh                  ; registr masky

; ------ zobrazen° prvn°ho bajtu linky
                                            ; BP:BX=adresa masky
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         push      ds                       ; £schova DS
         mov       ds,bp                    ; segment masky
         mov       al,ds:[bx]               ; maska
         inc       bx
         pop       ds                       ; n†vrat DS
         and       al,cs:[MaskFrst]         ; zamaskov†n° prvn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         lodsb                              ; rovina
         xchg      al,es:[di]               ; z†pis bajtu na displej
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky
                                            ; BP:BX=adresa masky
                                            ; CX=poáet bajtñ
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         jcxz      DispEG33                 ; nen° ë†dnò vnit©n° bajt
DispEG32:push      ds                       ; £schova DS
         mov       ds,bp                    ; segment masky
         mov       al,ds:[bx]               ; maska
         inc       bx                       ; zvò®en° ukazatele masky
         pop       ds                       ; n†vrat DS
         out       dx,al                    ; nastaven° masky pro z†pis
         lodsb                              ; rovina
         xchg      al,es:[di]               ; z†pis bajtu na displej
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      DispEG32                 ; z†pis dal®°ho bajtu

; ------ zobrazen° posledn°ho bajtu linky
                                            ; BP:BX=adresa masky
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

DispEG33:push      ds                       ; £schova DS
         mov       ds,bp                    ; segment masky
         mov       al,ds:[bx]               ; maska
         pop       ds                       ; n†vrat DS
         and       al,cs:[MaskLst]          ; zamaskov†n° posledn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         lodsb                              ; rovina
         xchg      al,es:[di]               ; z†pis bajtu na displej

; ------ n†vrat registrñ

         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
         pop       bp
         pop       di

         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
         ret


; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du EGA - rotace i maska
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        DS:SI=adresa obr†zku
; -----------------------------------------------------------------------------
; VùSTUP: ES:DI=nov† ukl†dac° adresa
;        kromà BP a DS nemus° uchov†vat registry
; -----------------------------------------------------------------------------

PUBLIC   DispEG4

; ------ £schova registrñ

DispEG4: push      di
         push      bp

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         mov       cl,cs:[MaskRot]          ; poáet rotac° bajtu
         mov       ch,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
         mov       bx,word ptr cs:[MaskAdr] ; offset adresy masky
         mov       bp,word ptr cs:[MaskAdr+2] ; segment adresy masky
         mov       dx,3cfh                  ; registr masky

; ------ zobrazen° prvn°ho bajtu linky
                                            ; BP:BX=adresa masky
                                            ; CL=rotace bajtu vpravo
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         push      ds                       ; £schova DS
         mov       ds,bp                    ; segment masky
         mov       ah,ds:[bx-1]
         mov       al,ds:[bx]               ; maska
         pop       ds                       ; n†vrat DS
         ror       ax,cl                    ; rotace na pozici
         and       al,cs:[MaskFrst]         ; zamaskov†n° prvn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       ah,ds:[si-1]
         mov       al,ds:[si]               ; rovina
         ror       ax,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z†pis bajtu na displej
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky
                                            ; BP:BX=adresa masky
                                            ; CL=rotace vpravo
                                            ; CH=poáet bajtñ
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

         or        ch,ch                    ; je nàjakò vnit©n° bajt ?
         jz        DispEG43                 ; nen° ë†dnò vnit©n° bajt
DispEG42:push      ds                       ; £schova DS
         mov       ds,bp                    ; segment masky
         mov       ah,ds:[bx]
         mov       al,ds:[bx+1]             ; maska
         inc       bx                       ; zvò®en° ukazatele masky
         pop       ds                       ; n†vrat DS
         ror       ax,cl                    ; rotace na pozici
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       ah,ds:[si]
         mov       al,ds:[si+1]             ; rovina
         inc       si                       ; zvò®en° adresy roviny
         ror       ax,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z†pis bajtu na displej
         inc       di                       ; zvò®en° ukl†dac° adresy
         dec       ch                       ; sn°ëen° á°taáe bajtñ
         jnz       DispEG42                 ; z†pis dal®°ho bajtu

; ------ zobrazen° posledn°ho bajtu linky
                                            ; BP:BX=adresa masky
                                            ; CL=rotace bajtu vpravo
                                            ; DX=adresa portu masky (03cfh)
                                            ; DS:SI=adresa zdroje (roviny)
                                            ; ES:DI=vòstupn° adresa

DispEG43:push      ds                       ; £schova DS
         mov       ds,bp                    ; segment masky
         mov       al,ds:[bx+1]
         mov       ah,ds:[bx]               ; maska
         pop       ds                       ; n†vrat DS
         ror       ax,cl                    ; rotace na pozici
         and       al,cs:[MaskLst]          ; zamaskov†n° posledn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ds:[si+1]
         mov       ah,ds:[si]               ; rovina
         ror       ax,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z†pis bajtu na displej

; ------ n†vrat registrñ

         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
         pop       bp
         pop       di

         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
         ret


; -----------------------------------------------------------------------------
;        Zobrazen° á†ry v m¢du EGA (AX=barva)
; -----------------------------------------------------------------------------

LineEGA:

         mov       ch,al                    ; poëadovan† barva (£schova)

; ------ inicializace registrñ videokarty EGA

         call      InitREGA                 ; inicializace registrñ EGA

; ------ vòpoáet poá†teán° adresy ve videopamàti

         mov       ax,ds:[bp+ModSirB]
         mov       ds:[LineB],ax
         mul       word ptr ds:[LineY1]     ; vòpoáet poá†teán°ho offsetu linky
         add       di,ax                    ; poá†teán° adresa linky
         mov       bx,ds:[LineX1]
         mov       cl,bl                    ; pozice bodu - nië®° slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° registru rovin (podle barvy)

         mov       dx,3ceh
         mov       al,0
         out       dx,al
         inc       dx
         mov       al,ch
         out       dx,al                    ; barva
         dec       dx

; ------ nastaven° registru rovin XOR

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al
         dec       dx

; ------ maskovac° bit zaá†tku

         and       cl,7                     ; poá†teán° bitov† pozice v bajtu
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,80h
         shr       al,cl

; ------ rozd°l sou©adnic Y (je zaji®tàno, ëe Y2 >= Y1)

         mov       si,ds:[LineY2]
         sub       si,ds:[LineY1]

; ------ rozd°l sou©adnic X a rozli®en°, zda jde shora vlevo nebo vpravo)

         mov       bx,ds:[LineX2]
         sub       bx,ds:[LineX1]           ; rozd°l sou©adnic X
         js        Lin3EGA                  ; jde smàrem vlevo

; ------ á†ra jde shora vpravo

; ------ rozli®en°, zda jde strmà vpravo

         cmp       bx,si                    ; je vàt®° p©°rustek ve smàru X ?
         jb        Lin2EGA                  ; jde strmà vpravo dolñ

; ------ á†ra jde m°rnà vpravo dolñ

         mov       cx,bx                    ; uráuj°c° je p©°rustek X
         inc       cx                       ; poáet krokñ á†ry
         shl       si,1                     ; rozd°l sou©adnic dY*2
         mov       bp,si                    ; £schova dY*2
         sub       bp,bx                    ; dY*2 - dX
         shl       bx,1                     ; dX*2
         sub       si,bx                    ; dY*2 - dX*2
         add       bx,si                    ; dX*2 + dY*2 - dX*2 = dY*2
         mov       ah,al                    ; maska poá†teán°ho bitu
Lin1EGA1:or        al,ah
         or        bp,bp
         jns       Lin1EGA2
         add       bp,bx
         jmp       short Lin1EGA3
Lin1EGA2:out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,ds:[LineB]
         add       bp,si
         ror       ah,1
         adc       di,0
         jmp       short Lin1EGA4
Lin1EGA3:ror       ah,1
         jnc       Lin1EGA4
         out       dx,al
         xchg      al,es:[di]
         inc       di
         xor       al,al
Lin1EGA4:loop      Lin1EGA1
         out       dx,al
         xchg      al,es:[di]
         jmp       LinEGA9

; ------ á†ra jde strmà vpravo dolñ

Lin2EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
         out       dx,al
Lin2EGA1:xchg      ah,es:[di]
         or        bp,bp
         jns       Lin2EGA3
         add       bp,si
         jmp       short Lin2EGA4
Lin2EGA3:ror       al,1
         adc       di,0
         out       dx,al
         add       bp,bx
Lin2EGA4:add       di,ds:[LineB]
         loop      Lin2EGA1
         jmp       LinEGA9

; ------ á†ra jde shora vlevo

Lin3EGA: neg       bx
         cmp       bx,si
         jb        Lin4EGA

; ------ á†ra jde m°rnà vlevo

         mov       cx,bx
         inc       cx
         shl       si,1
         mov       bp,si
         sub       bp,bx
         shl       bx,1
         sub       si,bx
         add       bx,si
         mov       ah,al
Lin3EGA1:or        al,ah
         or        bp,bp
         jns       Lin3EGA3
         add       bp,bx
         jmp       short Lin3EGA4
Lin3EGA3:out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,ds:[LineB]
         add       bp,si
         rol       ah,1
         sbb       di,0
         jmp       short Lin3EGA5
Lin3EGA4:rol       ah,1
         jnb       Lin3EGA5
         out       dx,al
         xchg      al,es:[di]
         dec       di
         xor       al,al
Lin3EGA5:loop      Lin3EGA1
         out       dx,al
         xchg      al,es:[di]
         jmp       LinEGA9

; ------ á†ra jde strmà vlevo

Lin4EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
         out       dx,al
Lin4EGA1:xchg      ah,es:[di]
         or        bp,bp
         jns       Lin4EGA2
         add       bp,si
         jmp       short Lin4EGA3
Lin4EGA2:rol       al,1
         sbb       di,0
         out       dx,al
         add       bp,bx
Lin4EGA3:add       di,ds:[LineB]
         loop      Lin4EGA1

; ------ konec

LinEGA9:
         mov       al,0ffh
         out       dx,al
         dec       dx
         mov       al,1
         out       dx,al
         inc       dx
         xor       al,al
         out       dx,al

         ret


; -----------------------------------------------------------------------------
;        Zobrazen° bodu v m¢du EGA (BX=pozice, DX=linka, AX=barva)
; -----------------------------------------------------------------------------

PointEGA:

         mov       ch,al                    ; poëadovan† barva (£schova)

; ------ inicializace registrñ videokarty EGA

         call      InitREGA                 ; inicializace registrñ EGA

; ------ vòpoáet adresy ve videopamàti

         mov       ax,dx                    ; linka bodu
         mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
         add       di,ax                    ; poá†teán° adresa linky
         mov       cl,bl                    ; pozice bodu - nië®° slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° registru rovin (podle barvy)

         mov       dx,3ceh
         mov       al,0
         out       dx,al
         inc       dx
         mov       al,ch
         out       dx,al                    ; barva
         dec       dx

; ------ nastaven° registru rovin XOR

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al
         dec       dx

; ------ nastaven° registru masky

         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky
         and       cl,7                     ; bitov† pozice (0 aë 7)
         mov       al,80h                   ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (80h aë 01h)
         out       dx,al                    ; nastaven° masky bodu

; ------ z†pis bodu

         xchg      al,es:[di]               ; z†pis bodu do roviny

; ------ n†vrat registrñ

         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
         dec       dx
         mov       al,1
         out       dx,al
         inc       dx
         xor       al,al
         out       dx,al
         ret

; -----------------------------------------------------------------------------
;        Vymaz†n° displeje MCGA
; -----------------------------------------------------------------------------

ClrMCG:
         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° objektu MCGA
; -----------------------------------------------------------------------------

PrepMCG:
         ret

; -----------------------------------------------------------------------------
;        P©°prava pro zobrazen° jednÇ roviny MCGA
; -----------------------------------------------------------------------------

SetMCG:

         ret

; -----------------------------------------------------------------------------
;        Zobrazen° linky v m¢du MCGA
; -----------------------------------------------------------------------------

DispMCG:
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° á†ry v m¢du MCGA
; -----------------------------------------------------------------------------

LineMCG:
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° bodu v m¢du MCGA
; -----------------------------------------------------------------------------

PointMCG:
         ret



ClrPCJ:
         ret

PrepPCJ:
         ret

SetPCJ:
         ret

DispPCJ:
         ret

LinePCJ:
         ret

PointPCJ:
         ret



; -----------------------------------------------------------------------------
;        NOP - ë†dn† funkce
; -----------------------------------------------------------------------------

PUBLIC   XNop
XNop:    xor       ax,ax
         ret

; -----------------------------------------------------------------------------
;        ENDPROC
; -----------------------------------------------------------------------------

PUBLIC   XEndProc
XEndProc:pop       ax                       ; zru®en° n†vratovÇ adresy
         xor       ax,ax                    ; n†vratovò k¢d - 0
         ret                                ; n†vrat z procedury

; -----------------------------------------------------------------------------
;        RETURN
; -----------------------------------------------------------------------------

PUBLIC   XReturn
XReturn:
         pop       ax                       ; zru®en° n†vratovÇ adresy
         call      Vyraz                    ; vòpoáet hodnoty vòrazu
         ret                                ; n†vrat z procedury

; -----------------------------------------------------------------------------
;        EXEC
; -----------------------------------------------------------------------------

PUBLIC   XExec
XExec:
         ret

; -----------------------------------------------------------------------------
;        IF
; -----------------------------------------------------------------------------

PUBLIC   XIf
XIf:     call      Vyraz                    ; vòpoáet vòrazu
         or        ax,ax                    ; je podm°nk† splnàna ?
         lodsw                              ; adresa, pokud podm°nka nesplnàna
         jz        XIf2                     ; podm°nka nesplnàna - p©eskoáen°
         ret                                ; podm°nka splnàna - d†le

XIf2:    mov       si,ax                    ; jinak ELSE resp. ENDIF
         ret

; -----------------------------------------------------------------------------
;        ELSE
; -----------------------------------------------------------------------------

PUBLIC   XElse
XElse:   mov       si,ds:[si]                ; vàtev s ELSE se p©eskoá°
         ret

; -----------------------------------------------------------------------------
;        FOR
; -----------------------------------------------------------------------------

PUBLIC   XFor
XFor:
         ret

; -----------------------------------------------------------------------------
;        ON
; -----------------------------------------------------------------------------

PUBLIC   XOn
XOn:     call      Vyraz                    ; vòpoáet vòrazu
         or        ax,ax                    ; je podm°nka splnàna ?
         lodsw                              ; adresa, pokud podm°nka splnàna
         jnz       XOn1                     ; podm°nka splnàna - ENDDO
         ret

XOn1:    mov       si,ax                    ; adresa za ENDDO
         ret

; -----------------------------------------------------------------------------
;        ENDDO
; -----------------------------------------------------------------------------

PUBLIC   XEndDo
XEndDo:  mov       si,ds:[si]               ; nepodm°nànò skok na DO
         ret

; -----------------------------------------------------------------------------
;        CASE
; -----------------------------------------------------------------------------

PUBLIC   XCase
XCase:   call      Vyraz                    ; testovanò vòraz
         mov       bx,ax                    ; testovanò vòraz

; ------ naáten° parametrñ vàtve IN

XCase1:  lodsb                              ; áten° bajtu IN
         cmp       al,21                    ; je k¢d IN ?
         jne       XCase5                   ; nen° dal®° podm°nka IN
         lodsw                              ; spodn° mez intervalu
         mov       cx,ax                    ; spodn° mez intervalu
         lodsw                              ; horn° mez intervalu
         mov       dx,ax                    ; horn° mez intervalu
         lodsw                              ; adresa p©i nesplnànÇ podm°nce
         cmp       cx,dx                    ; je spodn° mez pod horn° ?
         ja        XCase2                   ; spodn° mez je nad horn° - znamÇnko

; ------ porovn†n° á°sel bez znamÇnka

         cmp       bx,cx                    ; porovn†n° se spodn° mez° intervalu
         jb        XCase4                   ; nen° v intervalu
         cmp       bx,dx                    ; porovn†n° s horn° mez° intervalu
         ja        XCase4                   ; nen° v intervalu
         ret                                ; podm°nka splnàna - pokraáov†n°

; ------ porovn†n° á°sel se znamÇnkem (nebo obr†cenÇ po©ad°)

XCase2:  cmp       bx,cx                    ; porovn†n° se spodn° mez° intervalu
         jae       XCase8                   ; á°slo je v intervalu
         cmp       bx,dx                    ; porovn†n° s horn° mez° intervalu
         jbe       XCase8                   ; je v intervalu

; ------ podm°nka nesplnàna - nastaven° na dal®° vàtev IN

XCase4:  mov       si,ax                    ; adresa dal®°ho p©°kazu IN
         jmp       short XCase1             ; dal®° p©°kaz IN

; ------ vàtev IN nenalezena - p©°padnÇ pokraáov†n° povelem OUT

XCase5:  cmp       al,22                    ; je vàtev OUT ?
         je        XCase6                   ; je vàtev OUT
         dec       si                       ; n†vrat k¢du dal®°ho povelu
         ret                                ; pokraáov†n° v programu

XCase6:  add       si,2                     ; p©eskoáen° adresy konce CASE v OUT
XCase8:  ret

; -----------------------------------------------------------------------------
;        IN
; -----------------------------------------------------------------------------

PUBLIC   XIn
XIn:     add       si,4                     ; p©eskoáen° mez° IN
         mov       si,ds:[si]               ; adresa pokraáov†n° v programu
         ret

; -----------------------------------------------------------------------------
;        OUT
; -----------------------------------------------------------------------------

PUBLIC   XOut
XOut:    mov       si,ds:[si]               ; adresa pokraáov†n° v programu
         ret

; -----------------------------------------------------------------------------
;        VAL
; -----------------------------------------------------------------------------

PUBLIC   XVal
XVal:
         ret

; -----------------------------------------------------------------------------
;        STR
; -----------------------------------------------------------------------------

PUBLIC   XStr
XStr:
         ret

; -----------------------------------------------------------------------------
;        LEN
; -----------------------------------------------------------------------------

PUBLIC   XLen
XLen:
         ret

; -----------------------------------------------------------------------------
;        CARD
; -----------------------------------------------------------------------------

PUBLIC   XCard
XCard:
         mov       ah,0
         mov       al,cs:[EgaVga]           ; p©°znak karty EGA/VGA
         ret

; -----------------------------------------------------------------------------
;        VIDEO
; -----------------------------------------------------------------------------

PUBLIC   XVideo
XVideo:

; ------ zji®tàn° poëadovanÇho videom¢du

         call      Vyraz                    ; áten° á°sla videom¢du
         cmp       ax,8000h                 ; nastavuje se videom¢d ?
         je        XVideo1                  ; nem† se nastavovat

; ------ kontrola, zda se poëaduje opr†vnànà videom¢d EGA/VGA

         push      ax
         and       al,7fh
         cmp       al,7
         pop       ax
         jbe       XVideo0                  ; nepoëaduje se videom¢d EGA/VGA
         cmp       byte ptr cs:[EgaVga],0   ; je karta EGA/VGA ?
         jne       XVIdeo0                  ; je karta EGA/VGA OK

; ------ chyba - videom¢d nelze nastavit

         push      cs
         pop       ds

         mov       al,ds:[OldVMod]          ; pñvodn° videom¢d
         mov       ah,0
         call      Int10                    ; n†vrat videom¢du

         mov       dx,offset KartTxt        ; chybovÇ hl†®en°
         mov       ah,9
         int       21h                      ; zobrazen° zbytku hl†®en°
         jmp       Prerus2                  ; n†vrat z programu

; ------ nastaven° poëadovanÇho videom¢du

XVideo0: mov       ah,0                     ; funkce nastaven° videom¢du
         call      Int10                    ; nastaven° videom¢du
XVideo1: mov       ah,0fh                   ; funkce poskytnut° videom¢du
         call      Int10                    ; poskytnut° videom¢du
         mov       cs:[VMod],al             ; £schova videom¢du

; ------ stanoven° adresy videostr†nky

         mov       bx,0b800h
         cmp       al,7
         jb        XVideo2
         mov       bh,0b0h
         cmp       al,13
         jb        XVideo2
         mov       bh,0a0h
XVideo2: mov       cs:[SegVRAM],bx          ; segment videopamàti

; ------ stanoven° dÇlky videostr†nky, poáet znakñ na ©†dek a poáet ©†dkñ

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[44ah]             ; poáet pozic na ©†dek
         mov       cs:[MaxPoz],al           ; poáet pozice na ©†dek
         mov       al,ds:[484h]             ; á°slo posledn°ho ©†dku
         mov       byte ptr cs:[MaxRad],25  ; p©ednastaven° 25 ©†dkñ
         cmp       al,15                    ; je rozumnò £daj ?
         jb        XVideo3                  ; nen° spr†vnò £daj
         inc       al                       ; poáet ©†dkñ
         mov       cs:[MaxRad],al           ; poáet ©†dkñ
XVideo3: mov       ax,ds:[44ch]             ; dÇlka videostr†nky
         pop       ds
         mov       cs:[DelVRAM],ax          ; dÇlka videostr†nky

; ------ nastaven° aktivn° videostr†nky

         mov       al,cs:[Page1]            ; aktivn° videostr†nka
         mov       bh,al
         mov       ah,5
         call      Int10                    ; nastaven° aktivn° str†nky displeje

; ------ nastaven° pñvodn° pozice kurzoru

         mov       dx,cs:[KurzPoz]          ; aktu†ln° pozice kurzoru
         mov       ah,2
         call      Int10                    ; nastaven° pñvodn° pozice kurzoru

; ------ stanoven° n†vratovÇho k¢du (á°slo videom¢du)

         mov       ah,0
         mov       al,cs:[VMod]             ; aktu†ln° videom¢d
         ret

; -----------------------------------------------------------------------------
;        MODE
; -----------------------------------------------------------------------------

PUBLIC   XMode
XMode:
         call      Vyraz                    ; zji®tàn° m¢du displeje
         jc        XMode8                   ; nepoëaduje se nastaven°
         mov       cs:[BitDisp],ax          ; p©°znakovÇ bity

         cmp       byte ptr cs:[VMod],4
         je        XMode1
         cmp       byte ptr cs:[VMod],5
         jne       XMode3
XMode1:
         mov       dx,3d9h
         out       dx,al                    ; nastaven° m¢du

         jmp       short XMode8


XMode3:

XMode8:  mov       ax,cs:[BitDisp]
         ret

; -----------------------------------------------------------------------------
;        PAGE
; -----------------------------------------------------------------------------

PUBLIC   XPage
XPage:

; ------ zji®tàn° á°sel novòch videostr†nek

         call      Vyraz                    ; áten° slova
         cmp       ax,8000h
         je        XPage1                   ; nenastavuje se
         mov       byte ptr cs:[Page1],al   ; aktivn° videostr†nka
XPage1:  call      Vyraz
         cmp       ax,8000h
         je        XPage2                   ; nenastavuje se
         mov       byte ptr cs:[Page2],al   ; vòstupn° videostr†nka

; ------ nastaven° novÇ aktivn° videostr†nky

XPage2:  mov       al,cs:[Page1]
         mov       bh,al
         call      SetPage                  ; nastaven° videostr†nky AL
;         mov       ah,5
;         call      Int10                    ; nastaven° aktivn° str†nky displeje

; ------ nastaven° pñvodn° pozice kurzoru

         mov       dx,cs:[KurzPoz]          ; aktu†ln° pozice kurzoru
         mov       ah,2
;         call      Int10                    ; nastaven° pñvodn° pozice kurzoru

; ------ navr†cen° aktivn° videostr†nky

         mov       ah,0
         mov       al,cs:[Page1]            ; aktivn° videostr†nka
         ret

; -----------------------------------------------------------------------------
;        XPAGE
; -----------------------------------------------------------------------------

PUBLIC   XXPage
XXPage:

; ------ z†màna videostr†nek

         mov       ax,word ptr cs:[Page1]
         xchg      ah,al                    ; z†màna videostr†nek
         mov       word ptr cs:[Page1],ax

; ------ nastaven° novÇ aktivn° videostr†nky

         mov       al,cs:[Page1]
         mov       bh,al
         call      SetPage                  ; nastaven° videostr†nky AL
;         mov       ah,5
;         call      Int10                    ; nastaven° aktivn° str†nky displeje

; ------ nastaven° pñvodn° pozice kurzoru

         mov       dx,cs:[KurzPoz]          ; aktu†ln° pozice kurzoru
         mov       ah,2
;         call      Int10                    ; nastaven° pñvodn° pozice kurzoru

; ------ navr†cen° vòstupn° videostr†nky

         mov       ah,0
         mov       al,cs:[Page2]            ; vòstupn° videostr†nka
         ret

; -----------------------------------------------------------------------------
;        Nastaven° videostr†nky AL
; -----------------------------------------------------------------------------

SetPage:

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx

; ------ nastaven° novÇho á°sla videostr†nky v RAM BIOS

         push      ds
         xor       dx,dx
         mov       ds,dx                    ; DS <- 0
         mov       ds:[462h],al             ; £schova aktivn° str†nky displeje

; ------ vòpoáet adresy videostr†nky

         mov       ah,0                     ; AX=á°slo videostr†nky
         mul       word ptr cs:[DelVRAM]    ; vòpoáet adresy videostr†nky
         mov       bx,ax                    ; £schova adresy videostr†nky
         mov       ds:[44eh],ax             ; £schova adresy videostr†nky
         pop       ds

; ------ pro textovò videom¢d polovián° dÇlka

         cmp       byte ptr cs:[VMod],7
         je        SetPage2
         cmp       byte ptr cs:[VMod],3
         ja        SetPage3
SetPage2:shr       dx,1
         rcr       bx,1
SetPage3:

; ------ synchronizace na sn°mkovò zpàtnò bàh

         call      GetPort                  ; poskytnut° adresy stav. registru
;SetPage4:in        al,dx
;         test      al,8
;         jnz       SetPage4                 ; áek†n° na konec p©°padnÇho impulsu
;SetPage1:in        al,dx                    ; áten° stavu ©adiáe
;         test      al,8                     ; je sn°mkovò zpàtnò bàh ?
;         jz        SetPage1                 ; áek†n° na sn°mkovò zpàtnò bàh
         sub       dx,6                     ; adresa ©°dic°ho registru CRT

; ------ nastaven° adresy videostr†nky

         mov       al,0dh                   ; registr nië®°ho bajtu adresy
         out       dx,al                    ; nastaven° registru 0dh
         inc       dx                       ; data ©°dic°ho registru
         mov       al,bl                    ; nië®° bajt adresy
         out       dx,al                    ; nastaven° nië®°ho bajtu adresy

         dec       dx                       ; á°slo registru

         mov       al,0ch                   ; registr vy®®°ho bajtu adresy
         out       dx,al                    ; nastaven° registru 0ch
         inc       dx                       ; data ©°dic°ho registru
         mov       al,bh                    ; vy®®° bajt adresy
         out       dx,al                    ; nastaven° vy®®°ho bajtu adresy

; ------ n†vrat registrñ

         pop       dx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        WINDOW
; -----------------------------------------------------------------------------

PUBLIC   XWind
XWind:   mov       di,offset Wind1          ; levò okraj okna
         mov       cx,4                     ; poáet parametrñ

; ------ dek¢dov†n° jednotlivòch parametrñ

XWind1:  push      cx
         push      di
         call      Vyraz                    ; parametr - rozmàr okna
         pop       di
         pop       cx
         cmp       ax,8000h
         je        XWind2                   ; parametr se nenastavuje
         mov       cs:[di],ax               ; nastaven° parametru
XWind2:  add       di,2                     ; zvò®en° adresy
         loop      XWind1                   ; dal®° parametr

; ------ kontrola po©ad° horn°ho a doln°ho okraje

         mov       ax,cs:[Wind2]            ; horn° okraj
         cmp       ax,cs:[Wind4]            ; je spr†vnà nad doln°m okrajem ?
         jle       XWind3                   ; je spr†vnà nad doln°m okrajem
         xchg      ax,cs:[Wind4]            ; z†màna s doln°m okrajem
         mov       cs:[Wind2],ax            ; novò horn° okraj

; ------ kontrola po©ad° levÇho a pravÇho okraje

XWind3:  mov       ax,cs:[Wind1]            ; lev† pozice
         cmp       ax,cs:[Wind3]            ; je spr†vnà p©ed pravou pozic° ?
         jle       XWind4                   ; je spr†vnà p©ed pravou pozic°
         xchg      ax,cs:[Wind3]            ; z†màna s pravou pozic°
         mov       cs:[Wind1],ax            ; nov† lev† pozice
XWind4:  ret

; -----------------------------------------------------------------------------
;        PALETE
; -----------------------------------------------------------------------------

PUBLIC   XPal
XPal:
         mov       di,offset TabPal         ; tabulka palet
         mov       cx,17                    ; poáet palet v definici

; ------ vòpoáet hodnot paletovòch registrñ

XPal1:   push      cx
         push      di
         call      Vyraz                    ; áten° hodnoty registru
         pop       di
         pop       cx
         cmp       ax,8000h
         je        XPal2                    ; hodnota se nemàn°
         mov       cs:[di],al               ; definice palety
XPal2:   inc       di
         loop      XPal1                    ; dal®° registr

; ------ p©°prava registrñ pro p©edefinov†n° palet

         push      si
         push      ds

         push      cs
         pop       ds
         mov       si,offset TabPal         ; ukazatel tabulky palet
         mov       cx,16                    ; poáet palet k p©edefinov†n°
         mov       ah,0                     ; á°slo registru 0
         cld                                ; smàr nahoru
         call      GetPort                  ; poskytnut° adresy stav. registru

; ------ synchronizace na zaá†tek vertik†ln°ho synchronizaán°ho impulsu

         sti
XPal4:   in        al,dx
         test      al,8
         jnz       XPal4                   ; áek†n° na konec synchroimpulsu
XPal5:   in        al,dx
         test      al,8
         jz        XPal5                   ; áek†n° na zaá†tek synchoimpulsu

; ------ definice v®ech paletovòch registrñ

         cli
         mov       dx,3c0h                  ; adresa portu ©adiáe
XPal6:   mov       al,ah                    ; á°slo registru
         out       dx,al                    ; nastaven° á°sla registru
         lodsb                              ; poëadovan† paleta registru
         out       dx,al                    ; definice palety
         inc       ah                       ; zvò®en° á°sla registru
         loop      XPal6                   ; definice dal®°ho registru

; ------ p©edefinov†n° paletovÇho registru pozad°

         mov       al,11h                   ; á°slo registru palety pozad°
         out       dx,al                    ; nastaven° á°sla registru
         lodsb                              ; poëadovan† paleta registru
         out       dx,al                    ; definice palety registru pozad°

; ------ opàtovnÇ zapnut° videosign†lu

         mov       al,20h                   ; ukonáovac° bajt
         out       dx,al                    ; zapnut° videosign†lu
         sti

         pop       ds
         pop       si

         ret

; -----------------------------------------------------------------------------
;        XCOLOR
; -----------------------------------------------------------------------------

PUBLIC   XXCol
XXCol:
         ret

; -----------------------------------------------------------------------------
;        SETCURS
; -----------------------------------------------------------------------------

PUBLIC   XSetCur
XSetCur:
         call      Vyraz                    ; pozice kurzoru
         jc        XSetCur1
         mov       byte ptr cs:[KurzPoz],al ; pozice
XSetCur1:call      Vyraz                    ; ©†dek kurzoru
         jc        XSetCur2
         mov       byte ptr cs:[KurzPoz+1],al ; ©†dek

XSetCur2:mov       dx,cs:[KurzPoz]          ; aktu†ln° pozice kurzoru
         mov       ah,2
         mov       bh,cs:[Page1]
         call      Int10                    ; nastaven° pñvodn° pozice kurzoru

         mov       ah,0
         mov       al,byte ptr cs:[KurzPoz] ; souáasn† pozice
         ret

; -----------------------------------------------------------------------------
;        CURSOFF
; -----------------------------------------------------------------------------

PUBLIC   XCurOff
XCurOff:
         mov       dh,cs:[MaxRad]           ; maxim†ln° poáet ©†dkñ
         mov       dl,0
         mov       ah,2
         mov       bh,cs:[Page1]
         call      Int10
         mov       ah,0
         mov       al,cs:[MaxRad]           ; ©†dek, na kterÇm je kurzor
         ret

; -----------------------------------------------------------------------------
;        LOAD
; -----------------------------------------------------------------------------

PUBLIC   XLoad
XLoad:

; ------ pokud objekt existuje, jeho zru®en°

         lodsw                              ; áten° á°sla objektu
         call      SrcObj                   ; nalezen° objektu v pamàti
         jc        XLoad1                   ; objekt nen° v pamàti
         call      DelObj                   ; zru®en° objektu DX z pamàti

; ------ otev©en° poëadovanÇho souboru

XLoad1:  mov       di,ax                    ; £schova á°sla objektu
         mov       dx,si                    ; ukazatel na jmÇno programu
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
         jnc       XLoad6                   ; soubor otev©en OK

; ------ chyba - soubor nenalezen

         mov       al,cs:[OldVMod]          ; pñvodn° videom¢d
         mov       ah,0
         call      Int10                    ; n†vrat videom¢du

         push      ds
         push      cs
         pop       ds
         mov       dx,offset FndTxt         ; text - "Soubor"
         mov       ah,9
         int       21h                      ; zobrazen° prvn° á†sti hl†®en°
         pop       ds

XLoad2:  lodsb
         or        al,al
         jz        XLoad3                   ; konec textu
         mov       dl,al
         mov       ah,2
         int       21h                      ; zobrazen° znaku jmÇna souboru
         jmp       short XLoad2

XLoad3:  mov       dx,offset Fnd2Txt        ; text "nenalezen"
XLoad4:  push      cs
         pop       ds
         mov       ah,9
         int       21h                      ; zobrazen° zbytku hl†®en°

         jmp       Prerus2                  ; n†vrat z programu

; ------ chyba - nedostatek pamàti

XLoad5:  mov       al,cs:[OldVMod]          ; pñvodn° videom¢d
         mov       ah,0
         call      Int10                    ; n†vrat videom¢du

         mov       dx,offset MemTxt         ; text - nedostatek pamàti
         jmp       short XLoad4


; ------ zji®tàn° volnÇho m°sta pro jeden blok

XLoad6:  mov       dx,cs:[TopMem]           ; adresa k naáten° bloku
XLoad7:  mov       cx,ss                    ; konec pamàti
         add       cx,0d00h                 ; rezerva pro z†sobn°k 12 KB
         sub       cx,cs:[TopMem]           ; volnò prostor v pamàti
         jbe       XLoad5                   ; nen° voln† pamàü
         cmp       cx,0f00h                 ; je blok vàt®° neë 0f000h bajtñ ?
         jbe       XLoad8                   ; nen° vàt®°
         mov       cx,0f00h                 ; omezen° na 0f000h bajtñ

; ------ naáten° jednoho bloku ze souboru

XLoad8:  shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod na bajty
         push      ds
         push      dx
         mov       ds,dx                    ; segment k naáten° bloku souboru
         xor       dx,dx                    ; offset ke áten° souboru
         mov       ah,3fh
         int       21h                      ; naáten° bloku ze souboru
         pop       dx
         pop       ds
         jc        XLoada                   ; chyba áten° - konec

; ------ zvò®en° adresy segmentu

         cmp       ax,cx                    ; navr†ceno v°ce bajtñ neë bylo ?
         jbe       XLoad9                   ; £daj je OK
         mov       ax,cx                    ; omezen° na poëadovanÇ bajty
XLoad9:  add       ax,15                    ; zaokrouhlen°
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         add       dx,ax                    ; zvò®en° segmentu
         or        ax,ax                    ; bylo nàco naáteno ?
         jnz       XLoad7                   ; bylo nàco naáteno - dal®°

; ------ inicializace ukazatelñ objektu a pamàti

XLoada:  mov       ax,dx                    ; segment konce dat
         sub       ax,cs:[TopMem]           ; velikost novÇho bloku
         push      ds
         mov       ds,cs:[TopMem]           ; zaá†tek novÇho bloku
         mov       ds:[0],di                ; á°slo objektu
         mov       ds:[2],ax                ; velikost bloku
         pop       ds
         mov       cs:[TopMem],dx           ; novò konec pamàti

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ nalezen° konce textu v programu

         cld
XLoadb:  lodsb                              ; áten° znaku
         or        al,al
         jnz       XLoadb                   ; nen° konec textu - dal®° znak
         ret

; -----------------------------------------------------------------------------
;        OBJECT
; -----------------------------------------------------------------------------

PUBLIC   XObj
XObj:

; ------ zji®tàn° á°sla objektu

         lodsw                              ; á°slo objektu
         push      ax                       ; £schova á°sla objektu

; ------ uráen° pozice k um°stàn° objektu

         call      Vyraz                    ; áten° slova - pozice X
         mov       cs:[ObjLD],ax            ; poëadovan† poá†teán° pozice
         call      Vyraz                    ; áten° slova - linka Y
         mov       cs:[ObjUD],ax            ; poëadovan† poá†teán° linka

         pop       ax                       ; á°slo objektu

; ------ £schova registrñ

         push      si
         push      ds
         push      es

; ------ nalezen° z†hlav° objektu

         call      SrcObj                   ; nalezen° adresy objektu
         mov       ds,dx                    ; segment objektu
         jc        Objekt0                  ; objekt nenalezen

; ------ £schova parametrñ objektu

         push      cs
         pop       es                       ; ES <- CS
         mov       si,4                     ; adresa ®°©ky objektu
         mov       di,offset Sirka          ; buffer k £schovà parametrñ
         mov       cx,6                     ; dÇlka (slov)
         cld
         rep       movsw                    ; £schova z†hlav° objektu
         call      GetTabMod                ; adresa tabulky videom¢du

; ------ nastaven° parametrñ objektu

         mov       ax,cs:[Sirka]            ; poëadovan† ®°©ka objektu
         mov       cs:[ObjS],ax             ; poëadovan† ®°©ka objektu
         mov       ax,cs:[Vyska]            ; poëadovan† vò®ka objektu
         mov       cs:[ObjV],ax             ; poëadovan† vò®ka objektu
         call      Omez                     ; omezen° rozmàrñ objektu
Objekt0: jc        Objekt9                  ; objekt se nezobraz° - je mimo

; ------ p©°prava ukazatelñ pro zobrazen° objektu

         call      GetVRAM                  ; poskytnut° adresy VRAM
         push      ds
         push      cs
         pop       ds
         call      word ptr cs:[bp+ModPrep] ; p©°prava pro zobrazen° objektu
         pop       ds
         call      NormDSSI                 ; normalizace adresy (SI=16)
         xor       bx,bx                    ; BX=ukazatel rovin

; ------ je maskov†n° obr†zku - p©eskoáen° masky

         test      byte ptr cs:[Param],8    ; je maska obr†zku ?
         jz        Objekt1                  ; nen° maska

         mov       word ptr cs:[MaskAdr+2],ds ; segment masky pozad° (offset=0)
         add       si,cs:[RovinaB]          ; adresa dal®° roviny
         call      NormDSSI                 ; normalizace zdrojovÇ adresy

; ------ zobrazen° jednÇ roviny obr†zku

Objekt1: cld
         push      bx                       ; £schova á°sla roviny
         push      si                       ; £schova adresy obr†zku
         push      di                       ; £schova adresy ve videopamàti
         mov       ax,cs:[SirkaB]           ; ®°©ka objektu v bajtech
         mul       word ptr cs:[ObjUO]      ; poá†teán° offset v bajtech
         mov       word ptr cs:[MaskAdr],ax ; poá†teán° offset adresy masky
         add       si,ax                    ; poá†teán° offset linky
         call      word ptr cs:[bp+ModSet]  ; p©°prava pro zobrazen° roviny
         mov       cx,cs:[ObjV]             ; vò®ka objektu k zobrazen°
Objekt2: push      cx                       ; £schova á°taáe poátu linek
         push      si                       ; £schova zdrojovÇ adresy
         call      word ptr cs:[bp+ModDisp] ; zobrazen° jednÇ linky
         pop       si                       ; n†vrat zdrojovÇ adresy
         pop       cx                       ; n†vrat á°taáe linek
         mov       ax,cs:[SirkaB]           ; ®°©ka linky v bajtech
         add       si,ax                    ; zvò®en° zdrojovÇ adresy linky
         add       word ptr cs:[MaskAdr],ax ; zvò®en° adresy masky
         loop      Objekt2                  ; zobrazen° dal®° linky
Objekt4: pop       di                       ; n†vrat adresy ve videopamàti
         pop       si                       ; n†vrat adresy obr†zku
         pop       bx                       ; n†vrat á°sla roviny

; ------ zvò®en° adres na dal®° linku

         add       si,cs:[RovinaB]          ; zvò®en° adresy na dal®° rovinu
         call      NormDSSI                 ; normalizace adresy
         inc       bx                       ; zvò®en° á°sla roviny
         cmp       bx,cs:[Rovin]            ; jsou jië v®echny roviny ?
         jae       Objekt9                  ; jsou jië v®echny roviny
         test      byte ptr cs:[Param],4    ; je paraleln° uloëen° barev ?
         jz        Objekt1                  ; nen° paraleln° uloëen° barev-dal®°

; ------ n†vrat registrñ

Objekt9: pop       es
         pop       ds
         pop       si
         cld
         sti
         ret

; -----------------------------------------------------------------------------
;        UNLOAD
; -----------------------------------------------------------------------------

PUBLIC   XUnld
XUnld:
         lodsw                              ; áten° á°sla objektu
         call      SrcObj                   ; nalezen° objektu v pamàti
         jc        XUnld2                   ; objekt nen° v pamàti
         call      DelObj                   ; zru®en° objektu DX z pamàti
XUnld2:  ret

; -----------------------------------------------------------------------------
;        TEXT
; -----------------------------------------------------------------------------

PUBLIC   XText
XText:
         call      Vyraz                    ; barva textu
         push      ax                       ; £schova barvy
         call      Vyraz                    ; sou©adnice X
         push      ax                       ; £schova sou©adnice X
         call      Vyraz                    ; sou©adnice Y
         pop       dx                       ; DL=sou©adnice X
         mov       dh,al                    ; sou©adnice Y
         pop       bx                       ; BL=barva

; ------ nastaven° pozice kurzoru

XDisp1:  push      dx
         push      bx
         mov       ah,2
         mov       bh,cs:[Page2]            ; vòstupn° str†nka
         call      Int10                    ; nastaven° pozice kurzoru
         pop       bx
         pop       dx

; ------ zobrazen° jednoho znaku

         cld
         lodsb                              ; áten° dal®°ho znaku
         cmp       al,0
         je        XDisp2                   ; konec textu

         cmp       dl,cs:[MaxPoz]           ; dosaëeno maxim†ln° pozice ?
         jae       XDisp1                   ; je maxim†ln° pozice

         push      dx
         push      bx
         mov       ah,9
         mov       cx,1
         mov       bh,cs:[Page2]            ; vòstupn° str†nka
         call      Int10                    ; zobrazen° znaku
         pop       bx
         pop       dx

; ------ zvò®en° pozice kurzoru

         inc       dl                       ; zvò®en° pozice na ©†dku
         jmp       short XDisp1             ; zobrazen° dal®°ho znaku

XDisp2:  ret

; -----------------------------------------------------------------------------
;        POINT
; -----------------------------------------------------------------------------

PUBLIC   XPoint
XPoint:

         call      Vyraz                    ; barva bodu
         push      ax
         call      Vyraz                    ; X
         push      ax
         call      Vyraz                    ; Y
         mov       dx,ax                    ; Y
         pop       bx                       ; X
         pop       ax                       ; barva

         call      GetTabMod                ; poskytnut° tabulky videom¢du

; ------ kontrola sou©adnic

XPoint1: cmp       bx,cs:[bp+ModSir]        ; p©ekroáen maxim†ln° pravò okraj ?
         jae       XPoint9                  ; maxim†ln° pravò okraj p©ekroáen
         cmp       dx,cs:[bp+ModVys]        ; p©ekroáen doln° okraj ?
         jae       XPoint9                  ; p©ekroáen doln° okraj
         cmp       bx,cs:[Wind1]
         jl        XPoint9
         cmp       dx,cs:[Wind2]
         jl        XPoint9
         cmp       bx,cs:[Wind3]
         jg        XPoint9
         cmp       dx,cs:[Wind4]
         jg        XPoint9

; ------ zobrazen° bodu (barva AX)

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

         push      cs
         pop       ds

         call      GetVRAM                  ; poskytnut° adresy VRAM
         call      word ptr ds:[bp+ModPoint] ; zobrazen° bodu barvy AX,
                                            ; linka DX, pozice BX

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
XPoint9:
         ret

; -----------------------------------------------------------------------------
;        LINE
; -----------------------------------------------------------------------------

PUBLIC   XLine
XLine:

; ------ zad†n° barvy a sou©adnic

         call      Vyraz                    ; barva á†ry
         push      ax
         call      Vyraz                    ; X1
         mov       cs:[LineX1],ax           ; X1
         call      Vyraz                    ; Y1
         mov       cs:[LineY1],ax           ; Y1
         call      Vyraz                    ; X2
         mov       cs:[LineX2],ax           ; X2
         call      Vyraz                    ; Y2
         mov       cs:[LineY2],ax           ; Y2

; ------ kontrola po©ad°, zda je Y2 vàt®° neë Y1

         cmp       ax,cs:[LineY1]
         jge       XLine2                   ; po©ad° je OK
         xchg      ax,cs:[LineY1]           ; oprava po©ad° Y
         mov       cs:[LineY2],ax
         mov       ax,cs:[LineX1]
         xchg      ax,cs:[LineX2]           ; oprava po©ad° X
         mov       cs:[LineX1],ax
XLine2:  pop       ax                       ; barva



         call      GetTabMod                ; poskytnut° tabulky videom¢du

; ------ zobrazen° á†ry (barva AX)

         push      si
         push      es
         push      ds

         push      cs
         pop       ds

         call      GetVRAM                  ; poskytnut° adresy VRAM
         call      word ptr ds:[bp+ModLine] ; zobrazen° á†ry barvy AX

         pop       ds
         pop       es
         pop       si

         ret

; -----------------------------------------------------------------------------
;        RLINE
; -----------------------------------------------------------------------------

PUBLIC   XRLine
XRLine:
         ret

; -----------------------------------------------------------------------------
;        BOX
; -----------------------------------------------------------------------------

PUBLIC   XBox
XBox:
         ret

; -----------------------------------------------------------------------------
;        FBOX - plnò obdÇln°k
; -----------------------------------------------------------------------------

PUBLIC   XFBox
XFBox:
         call      GetTabMod                ; poskytnut° tabulky videom¢du

; ------ zji®tàn° barvy

         call      Vyraz                    ; áten° slova - barva
         push      ax                       ; £schova barvy

; ------ poá†teán° pozice X

         call      Vyraz                    ; poá†teán° pozice X
         mov       cs:[ObjLD],ax            ; levò okraj zaá†tku zobrazen°

; ------ poá†teán° linka Y

         call      Vyraz                    ; poá†teán° linka Y
         mov       cs:[ObjUD],ax            ; horn° okraj zaá†tku zobrazen°

; ------ ®°©ka obdÇln°ku

         call      Vyraz                    ; koncov† pozice X
         cmp       ax,cs:[ObjLD]            ; je p©ed poá†teán° pozic° ?
         jge       XFBox1                   ; pozice je OK
         xchg      ax,cs:[ObjLD]            ; oprava po©ad° pozic
XFBox1:  sub       ax,cs:[ObjLD]            ; vòpoáet ®°©ky obdÇln°ku
         inc       ax                       ; ®°©ka obdÇln°ku (jednotek)
         mov       cs:[ObjS],ax             ; £schova ®°©ky obdÇln°ku

; ------ vò®ka obdÇln°ku

         call      Vyraz                    ; koncov† linka Y
         cmp       ax,cs:[ObjUD]            ; je nad horn° linkou ?
         jge       XFBox2                   ; nen° nad horn° linkou
         xchg      ax,cs:[ObjUD]            ; oprava po©ad° linek
XFBox2:  sub       ax,cs:[ObjUD]            ; vòpoáet vò®ky obdÇln°ku
         inc       ax                       ; vò®ka obdÇln°ku (jednotek)
         mov       cs:[ObjV],ax             ; £schova vò®ky obdÇln°ku

; ------ p©°prava ukazatelñ pro zobrazen° objektu

         call      Omez                     ; omezen° rozmàrñ obdÇln°ku
         pop       ax                       ; n†vrat poëadovanÇ barvy
         jc        XFBox9                   ; obdÇln°k se nezobraz° - je mimo

; ------ zobrazen° obdÇln°ku

         push      si
         push      es
         push      ds
         push      cs
         pop       ds
         call      GetVRAM                  ; poskytnut° adresy VRAM
         call      word ptr ds:[bp+ModCLR]  ; vymaz†n° displeje zadanou barvou
         pop       ds
         pop       es
         pop       si

XFBox9:  ret

; -----------------------------------------------------------------------------
;        CIRC - kruënice
; -----------------------------------------------------------------------------
;˛
PUBLIC   XCirc
XCirc:

; ------ z°sk†n° parametrñ

         call      Vyraz                    ; barva bodu
         push      ax                       ; barva
         call      Vyraz                    ; X
         push      ax                       ; X
         call      Vyraz                    ; Y
         push      ax                       ; Y
         call      Vyraz                    ; polomàr
         mov       di,ax                    ; polomàr
         mov       cx,ax                    ; á°taá
         shr       ax,1
         shr       ax,1                     ; polomàr / 4
         sub       cx,ax                    ; odeáten° 1/4 poátu bodñ
         shr       ax,1
         shr       ax,1
         shr       ax,1
         sub       cx,ax                    ; odeáten° je®tà 1/32 bodñ
         pop       dx                       ; Y
         pop       bx                       ; X
         pop       ax                       ; barva
         or        di,di                    ; polomàr
         jg        XCirc1                   ; je nàjakò polomàr - OK
         jmp       XCirc9                   ; polomàr = 0

XCirc1:
         call      GetTabMod                ; poskytnut° tabulky videom¢du

; ------ vòpoáet hodnoty kruënice

XCirc3:  push      si

         push      ax
         push      bx
         push      cx
         push      dx

         xor       dx,dx
         mov       ax,cx                    ; stav á°taáe
         shl       ax,1
         rcl       dx,1

         shl       ax,1
         rcl       dx,1

         shl       ax,1
         rcl       dx,1

         shl       ax,1
         rcl       dx,1                     ; á°slo * 16

         div       di                       ; stav relativnà
         mov       cx,dx                    ; £schova zbytku (*16)

         mov       si,ax
         shl       si,1
         mov       ax,cs:[si+TabCirc]
         mul       di
         mov       al,ah
         mov       ah,dl

         mov       dx,cs:[si+TabCirc]
         sub       dx,cs:[si+TabCirc+2]
         mov       si,ax

         mov       ax,cx                    ; zbytek * 16
         mul       dx                       ;
         add       ax,128
         adc       dx,0
         mov       al,ah
         mov       ah,dl
         sub       si,ax

         pop       dx
         pop       cx
         pop       bx
         pop       ax

; ------ zobrazen° osmice bodñ:
;
;            AX=barva
;            BX=pozice st©edu
;            CX=á°taá (pozice dolñ)
;            DX=linka st©edu
;            SI=hodnota
;            DI=polomàr

; ------ zprava nahoru

         push      bx
         push      dx
         sub       dx,cx                    ; Y
         add       bx,si                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

; ------ zprava dolñ

         push      bx
         push      dx
         add       dx,cx                    ; Y
         add       bx,si                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

; ------ zleva nahoru

         push      bx
         push      dx
         sub       dx,cx                    ; Y
         sub       bx,si                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

; ------ zleva dolñ

         push      bx
         push      dx
         add       dx,cx                    ; Y
         sub       bx,si                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

; ------ shora vlevo

         push      bx
         push      dx
         sub       dx,si                    ; Y
         sub       bx,cx                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

; ------ shora vpravo

         push      bx
         push      dx
         sub       dx,si                    ; Y
         add       bx,cx                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

; ------ zdola vlevo

         push      bx
         push      dx
         add       dx,si                    ; Y
         sub       bx,cx                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

; ------ zdola vpravo

         push      bx
         push      dx
         add       dx,si                    ; Y
         add       bx,cx                    ; X
         call      XPoint1                  ; zobrazen° bodu
         pop       dx
         pop       bx

         pop       si

         sub       cx,1
         jc        XCirc9
         jmp       XCirc3

XCirc9:

         ret


TabCirc  dw        256                      ; 0
         dw        255                      ; 1
         dw        254                      ; 2
         dw        251                      ; 3
         dw        248                      ; 4
         dw        243                      ; 5
         dw        237                      ; 6
         dw        230                      ; 7
         dw        222                      ; 8
         dw        212                      ; 9
         dw        200                      ; 10
         dw        186                      ; 11
         dw        169                      ; 12
         dw        149                      ; 13
         dw        124                      ; 14
         dw        89                       ; 15
         dw        0                        ; 16

; -----------------------------------------------------------------------------
;        FCIRC
; -----------------------------------------------------------------------------

PUBLIC   XFCirc
XFCirc:
         ret

; -----------------------------------------------------------------------------
;        PRESS
; -----------------------------------------------------------------------------

PUBLIC   XPress
XPress:  call      Vyraz                    ; zji®tàn° k¢du poëadovanÇ kl†vesy
         cmp       ax,70h                   ; je povolenò k¢d kl†vesy ?
         jbe       XPress2                  ; k¢d kl†vesy je povolenò
         xor       ax,ax                    ; n†hradn° k¢d 0
XPress2: cmp       al,60h                   ; je roz®°©en† kl†vesnice ?
         jb        XPress3                  ; nen° roz®°©en† kl†vesnice
         mov       byte ptr cs:[ExtKey],1   ; p©°znak roz®°©enÇ kl†vesnice
XPress3: mov       bx,ax                    ; offset v tabulce
         mov       al,cs:[bx+TabKey]        ; stav poëadovanÇ kl†vesy
         ret

; -----------------------------------------------------------------------------
;        TESTKEY
; -----------------------------------------------------------------------------

PUBLIC   XTstKey
XTstKey: mov       ax,cs:[KeyBuf]           ; k¢d p©ipravenÇ kl†vesy
         ret

; -----------------------------------------------------------------------------
;        GETKEY
; -----------------------------------------------------------------------------

PUBLIC   XGtKey
XGtKey:  sti                                ; p©eru®en° mus° bòt povoleno
         xor       ax,ax                    ; AX <- 0
         xchg      ax,cs:[KeyBuf]           ; k¢d p©ipravenÇ kl†vesy
         or        ax,ax                    ; je to platn† kl†vesa ?
         jz        XGtKey                   ; áek†n° na p©°chod kl†vesy
         ret

; -----------------------------------------------------------------------------
;        STATKEY
; -----------------------------------------------------------------------------
; VùSTUP: AX = bit 0: 1=pravò Shift stisknut
;              bit 1: 1=levò Shift stisknut
;              bit 2: 1=kl†vesa Ctrl stisknuta
;              bit 3: 1=kl†vesa Alt stisknuta
;              bit 4: 1=Scroll Lock zapnut
;              bit 5: 1=Num Lock zapnut
;              bit 6: 1=Caps Lock zapnut
;              bit 7: 1=Insert zapnut
;
;              bit 8: 1=prav† kl†vesa Ctrl stisknuta  ƒø
;              bit 9: 1=prav† kl†vesa Alt stisknuta    √ pouze AT 101/102
;              bit 10: 1=kl†vesa Sys Rq stisknuta     ƒŸ
;              bit 11: 1=je roz®°©en† kl†vesnice AT 101/102 kl†ves
;              bit 12: 1=kl†vesa Scroll Lock stisknuta
;              bit 13: 1=kl†vesa Num Lock stisknuta
;              bit 14: 1=kl†vesa Caps Lock stisknuta
;              bit 15: 1=kl†vesa Insert stisknuta
; -----------------------------------------------------------------------------

PUBLIC   XStatKey
XStatKey:
         push      ds
         mov       ax,40h
         mov       ds,ax
         mov       ax,ds:[17h]              ; statut p©esmykaáñ
         and       ah,not 8                 ; zru®en° bitu 3 (p©°znak Pause)
         test      byte ptr ds:[96h],10h    ; instalov†na kl†vesnice 101/102 ?
         jz        XStatK1                  ; nen° kl†vesnice 101/102 kl†ves
         or        ah,8                     ; p©°znak kl†vesnice 101/102
XStatK1: ret

; -----------------------------------------------------------------------------
;        INPUT
; -----------------------------------------------------------------------------

PUBLIC   XInp
XInp:
         ret

; -----------------------------------------------------------------------------
;        SOUND
; -----------------------------------------------------------------------------

PUBLIC   XSound
XSound:
         call      Vyraz                    ; áten° slova
         or        ax,ax                    ; vypnut° gener†toru ?
         jnz       Sound2                   ; nen° vypnut° gener†toru

         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut° gener†toru
         ret


Sound2:  mov       bx,ax
         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al
         in        al,[61h]
         or        al,3
         out       [61h],al

         ret

; -----------------------------------------------------------------------------
;        TON
; -----------------------------------------------------------------------------

PUBLIC   XTon
XTon:
         ret

; -----------------------------------------------------------------------------
;        MUSIC
; -----------------------------------------------------------------------------

PUBLIC   XMusic
XMusic:


         cli                                ; mus° bòt zak†z†no p©eru®en°
         cld
         lodsw                              ; poáet slov melodie
         mov       cs:[UkazMel],si          ; ukazatel zaá†tku melodie
         mov       cs:[NumMel],ax           ; poáet zbylòch t¢nñ melodie
         sti
         shl       ax,1                     ; poáet bajtñ
         add       si,ax                    ; zvò®en° adresy v programu
         ret

; -----------------------------------------------------------------------------
;        MUSICSTOP
; -----------------------------------------------------------------------------

PUBLIC   XMStop
XMStop:
         mov       word ptr cs:[NumMel],0   ; zru®en° á°taáe znakñ melodie
         mov       byte ptr cs:[CitTon],0   ; inicializace á°taáe t¢nu
         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut° gener†toru
         ret

; -----------------------------------------------------------------------------
;        MUSICGET
; -----------------------------------------------------------------------------

PUBLIC   XMusGet
XMusGet:
         mov       ax,cs:[NumMel]           ; poáet zbylòch znakñ melodie
         ret

; -----------------------------------------------------------------------------
;        WAIT
; -----------------------------------------------------------------------------

PUBLIC   XWait
XWait:   push      word ptr cs:[Citac]      ; £schova pñvodn°ho stavu á°taáe
         call      Vyraz                    ; áten° slova
         or        ax,ax                    ; je z†pornÇ á°slo ?
         js        XWait2                   ; je z†pornÇ á°slo - neplat°
         sti                                ; povolen° p©eru®en°
XWait1:  cmp       byte ptr cs:[ParBreak],0 ; je uëivatelskÇ p©eru®en° ?
         jne       XWait2                   ; je uëivatelskÇ p©eru®en°
         cmp       word ptr cs:[Citac],ax
         jb        XWait1                   ; nen° je®tà dosaëen áas
         mov       word ptr cs:[Citac],0    ; inicializace á°taáe
XWait2:  pop       ax                       ; pñvodn° stav á°taáe
         ret

; -----------------------------------------------------------------------------
;        TIME
; -----------------------------------------------------------------------------

PUBLIC   XTime
XTime:
         ret

; -----------------------------------------------------------------------------
;        DATE
; -----------------------------------------------------------------------------

PUBLIC   XDate
XDate:
         ret

; -----------------------------------------------------------------------------
;        XMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XXMous
XXMous:
         ret

; -----------------------------------------------------------------------------
;        YMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XYMous
XYMous:
         ret

; -----------------------------------------------------------------------------
;        GETMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XKMous
XKMous:
         ret

; -----------------------------------------------------------------------------
;        MOUSEON
; -----------------------------------------------------------------------------

PUBLIC   XMon
XMon:
         ret

; -----------------------------------------------------------------------------
;        MOUSEOFF
; -----------------------------------------------------------------------------

PUBLIC   XMoff
XMoff:
         ret

; -----------------------------------------------------------------------------
;        CURMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XDefm
XDefm:
         ret

; -----------------------------------------------------------------------------
;        WINMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XWinm
XWinm:
         ret

; -----------------------------------------------------------------------------
;        RND
; -----------------------------------------------------------------------------

PUBLIC   XRnd
XRnd:    call      Vyraz                    ; poëadovanò interval
         mov       bx,ax                    ; interval
         or        ax,ax
         jz        XRnd2

         mov       ax,word ptr cs:[RandNum]
         mov       di,word ptr cs:[RandNum+2]
         rol       ax,1
         rol       di,1
         xor       al,ss:[di]
         xor       ah,ss:[di+1]
         xor       di,ax
         mov       word ptr cs:[RandNum],ax
         mov       word ptr cs:[RandNum+2],di

         xor       dx,dx
         div       bx
         mov       ax,dx

XRnd2:   ret

RandNum  dd        0

; -----------------------------------------------------------------------------
;        REGISTER - nastaven° registru video©adiáe
; -----------------------------------------------------------------------------

XReg:    call      GetPort                  ; poskytnut° adresy stav. registru
         sub       dx,6                     ; adresa ©°dic°ho registru
         push      dx
         call      Vyraz                    ; poëadovanò registr
         pop       dx
         out       dx,al                    ; nastaven° á°sla registru
         inc       dx                       ; data registru
         push      dx
         call      Vyraz                    ; poëadovan† hodnota registru
         pop       dx
         out       dx,al                    ; nastaven° registru
         ret

; -----------------------------------------------------------------------------
;        HSYN - horizont†ln° synchronizace
; -----------------------------------------------------------------------------

XHSyn:

; ------ zji®tàn° poëadovanÇho poátu impulsñ, p©°prava registrñ

         call      Vyraz                    ; poëadovanò poáet impulsñ
         mov       cx,ax                    ; poëadovanò poáet impulsñ
         call      GetPort                  ; poskytnut° adresy stav. registru
         jcxz      XHSyn3                   ; nepoëaduje se synchronizace
         or        cx,cx                    ; je z†pornÇ á°slo ?
         js        XHSyn3                   ; z†pornÇ á°slo - nen° synchronizace

; ------ áek†n° na konec p©°padnÇho impulsu

         sti                                ; mus° bòt povoleno p©eru®en°
XHSyn1:  cmp       byte ptr cs:[ParBreak],0 ; je uëivatelskÇ p©eru®en° ?
         jne       XHSyn4                   ; je p©eru®en°
         in        al,dx                    ; áten° stavovÇho registru
         shr       al,1                     ; je horizont†ln° impuls ?
         jc        XHSyn1                   ; áek†n° na konec impulsu

; ------ áek†n° na zaá†tek horizont†ln°ho impulsu

XHSyn2:  cmp       byte ptr cs:[ParBreak],0 ; je uëivatelskÇ p©eru®en° ?
         jne       XHSyn4                   ; je p©eru®en°
         in        al,dx                    ; áten° stavovÇho registru
         shr       al,1                     ; je horizont†ln° impuls ?
         jnc       XHSyn2                   ; áek†n° na zaá†tek impulsu
         loop      XHSyn1                   ; áek†n° na dal®° impuls
         jmp       short XHSyn4

; ------ zji®tàn° stavu horizont†ln°ho impulsu

XHSyn3:  in        al,dx                    ; áten° stavu portu
         and       ax,1                     ; prob°h† horizont†n° impuls ?
         jz        XHSyn5                   ; neprob°h†
XHSyn4:  mov       ax,-1                    ; p©°znak, ëe je horiz. impuls
XHSyn5:  ret

; -----------------------------------------------------------------------------
;        VSyn - Vertik†ln° synchronizace
; -----------------------------------------------------------------------------

XVSyn:

; ------ zji®tàn° poëadovanÇho poátu impulsñ, p©°prava registrñ

         call      Vyraz                    ; poëadovanò poáet impulsñ
         mov       cx,ax                    ; poëadovanò poáet impulsñ
         call      GetPort                  ; poskytnut° adresy stav. registru
         jcxz      XVSyn3                   ; nepoëaduje se synchronizace
         or        cx,cx                    ; je z†pornÇ á°slo ?
         js        XVSyn3                   ; z†pornÇ á°slo - nen° synchronizace

; ------ áek†n° na konec p©°padnÇho impulsu

         sti                                ; mus° bòt povoleno p©eru®en°
XVSyn1:  cmp       byte ptr cs:[ParBreak],0 ; je uëivatelskÇ p©eru®en° ?
         jne       XVSyn4                   ; je p©eru®en°
         in        al,dx                    ; áten° stavovÇho registru
         test      al,8                     ; je vertik†ln° impuls ?
         jnz       XVSyn1                   ; áek†n° na konec impulsu

; ------ áek†n° na zaá†tek vertik†ln°ho impulsu

XVSyn2:  cmp       byte ptr cs:[ParBreak],0 ; je uëivatelskÇ p©eru®en° ?
         jne       XVSyn4                   ; je p©eru®en°
         in        al,dx                    ; áten° stavovÇho registru
         test      al,8                     ; je vertik†ln° impuls ?
         jz        XVSyn2                   ; áek†n° na zaá†tek impulsu
         loop      XVSyn1                   ; áek†n° na dal®° impuls
         jmp       short XVSyn4

; ------ zji®tàn° stavu horizont†ln°ho impulsu

XVSyn3:  in        al,dx                    ; áten° stavu portu
         and       ax,8                     ; prob°h† horizont†n° impuls ?
         jz        XVSyn5                   ; neprob°h†
XVSyn4:  mov       ax,-1                    ; p©°znak, ëe je horiz. impuls
XVSyn5:  ret

; -----------------------------------------------------------------------------
;        PATTERN - definice vòplnà
; -----------------------------------------------------------------------------

PUBLIC   XPatt
XPatt:
         mov       di,offset Pattern        ; tabulka definice vòplnà
         mov       cx,8                     ; poáet bajtñ k definici

; ------ stanoven° hodnot vòplnà

XPatt1:  push      cx
         push      di
         call      Vyraz                    ; áten° hodnoty pro vòpl§
         pop       di
         pop       cx
         cmp       ax,8000h                 ; nastavuje se hodnota ?
         je        XPatt2                   ; hodnota se nemàn°
         mov       cs:[di],al               ; definice vòplnà
XPatt2:  mov       al,cs:[di]               ; vòpl§
         or        cs:[OrPatt],al           ; logickò souáet vòplnà
         and       cs:[AndPatt],al          ; logickò souáin vòplnà
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      XPatt1                   ; dal®° bajt definice
         mov       ax,word ptr cs:[Pattern] ; prvn° dva bajty definice
         ret

; -----------------------------------------------------------------------------
;        STICK - joystickovò vstup
; -----------------------------------------------------------------------------
; VùSTUP: AX:  0=nen° ë†dnò smàr
;              1=nahoru                        8    /\ 1  2
;              2=vpravo nahoru                   \      /
;              3=vpravo
;              4=vpravo dolñ                 7 <---    ---> 3
;              5=dolñ
;              6=vlevo dolñ                    6 /      \  4
;              7=vlevo                              \/
;              8=vlevo nahoru                         5
; -----------------------------------------------------------------------------

PUBLIC   XStick
XStick:

         mov       bh,0
         mov       ax,40
         cli
                                          ;* 1 - nahoru
         mov       bl,48h
         mov       dh,-18
         mov       dl,0
         call      XStickX
                                          ;* 2 - vpravo nahoru
         mov       bl,49h
         mov       dh,-9
         mov       dl,1
         call      XStickX
                                          ;* 3 - vpravo
         mov       bl,4dh
         mov       dh,0
         mov       dl,2
         call      XStickX
                                          ;* 4 - vpravo dolñ
         mov       bl,51h
         mov       dh,9
         mov       dl,1
         call      XStickX
                                          ;* 5 - dolñ
         mov       bl,50h
         mov       dh,18
         mov       dl,0
         call      XStickX
                                          ;* 6 - vlevo dolñ
         mov       bl,4fh
         mov       dh,9
         mov       dl,-1
         call      XStickX
                                          ;* 7 - vlevo
         mov       bl,4bh
         mov       dh,0
         mov       dl,-2
         call      XStickX
                                          ;* 8 - vlevo nahoru
         mov       bl,47h
         mov       dh,-9
         mov       dl,-1
         call      XStickX

         mov       bx,ax
         mov       al,cs:[TabSmer+bx]

         sti
         ret


                                          ;* test, zda je nastaven smàr BX
XStickX: cmp       byte ptr cs:[KeyBuf+1],bl
         jne       XStickX0
         mov       word ptr cs:[KeyBuf],0
         jmp       short XStickX1
XStickX0:cmp       byte ptr cs:[TabKey+bx],0 ; je poëadovanò smàr ?
         jne       XStickX1                 ; poëadovanò smàr je
         cmp       byte ptr cs:[TabKey+bx+60h-47h],0 ; je zdvojen† kl†vesa ?
         je        XStickX2                 ; smàr nen°
XStickX1:add       al,dl
         add       al,dh
XStickX2:ret


TabSmer  label     byte
         db        8,8,8,1,1,1,1,2,2
         db        8,8,8,1,1,1,2,2,2
         db        7,8,8,8,1,1,2,2,2
         db        7,7,7,8,1,2,2,3,3
         db        7,7,7,7,0,3,3,3,3
         db        7,7,6,6,5,4,3,3,3
         db        6,6,6,5,5,4,4,4,3
         db        6,6,6,5,5,5,4,4,4
         db        6,6,5,5,5,5,4,4,4


; 8         1   2
;  b7    /\ b0 b1
;     \      /
;7
;b6 <---    --->b2 3
;
; 6 b5/      \ b3
;        \/      4
;         b4
;          5

;TabSmer  label     byte                   ;* tabulka smàrñ Joysticku
;         db        0,1,2,1,3,2,2,2,4,2,3,2,3,3,3,2 ; b4=0, b5=0, b6=0, b7=0
;         db        5,0,3,2,4,3,3,2,4,3,4,3,4,3,3,3 ; b4=1, b5=0, b6=0, b7=0
;         db        6,7,0,8,4,2,2,2,5,5,4,1,4,3,3,2 ; b4=0, b5=1, b6=0, b7=0
;         db        5,6,5,0,5,5,4,2,5,5,4,5,4,4,4,3 ; b4=1, b5=1, b6=0, b7=0
;
;         db        0,1,2,1,3,2,2,2,4,2,3,2,3,3,3,2 ; b4=0, b5=0, b6=1, b7=0
;         db        5,0,3,2,4,3,3,2,4,3,4,3,4,3,3,3 ; b4=1, b5=0, b6=1, b7=0
;         db        6,7,0,8,4,2,2,2,5,5,4,1,4,3,3,2 ; b4=0, b5=1, b6=1, b7=0
;         db        5,6,5,0,5,5,4,2,5,5,4,5,4,4,4,3 ; b4=1, b5=1, b6=1, b7=0

; -----------------------------------------------------------------------------
;        TRIG - aktivaán° vstup z joysticku
; -----------------------------------------------------------------------------

PUBLIC   XTrig
XTrig:
         mov       ax,-1
         cmp       byte ptr cs:[TabKey+39h],0    ; je mezern°k ?
         jne       XTrig1                   ; je mezern°k
         cmp       byte ptr cs:[TabKey+4ch],0
         jne       XTrig1
         cmp       byte ptr cs:[TabKey+65h],0
         jne       XTrig1
         xor       ax,ax
XTrig1:  ret

; -----------------------------------------------------------------------------
;        COS
; -----------------------------------------------------------------------------
;˛
PUBLIC   XCos
XCos:    call      Vyraz

; ------ korekce - £prava na SIN

XCosin:  add       ax,4000h                 ; p©iáten° kvadrantu - nyn° jako SIN
         jmp       short XSinus             ; d†le jako SIN

; -----------------------------------------------------------------------------
;        SIN
; -----------------------------------------------------------------------------

PUBLIC   XSin
XSin:    call      Vyraz

; ------ absolutn° hodnota á°sla

XSinus:  mov       di,ax                    ; £schova znamÇnka á°sla
         or        ax,ax
         jns       XSin2
         neg       ax

; ------ druhò kvadrant bude stejnò jako prvn°

XSin2:   cmp       ax,4000h                 ; je druhò kvadrant ?
         jb        XSin3                    ; je prvn° kvadrant - OK
         sub       ax,8000h                 ; p©evr†cen° na prvn° kvadrant
         neg       ax                       ; oprava znamÇnka

; ------ p©evod £hlu na hodnotu

XSin3:   shl       ax,1                     ; hodnota * 2
         mov       bl,ah
         xor       bh,bh
         shl       bx,1
         mov       cx,cs:[SinTab+bx]        ; prozatimn° hodnota

; ------ up©esnàn° hodnoty

         mov       dx,cs:[SinTab+bx+2]      ; n†sleduj°c° hodnota
         sub       dx,cx                    ; rozd°l hodnot
         xor       ah,ah                    ; AX = zbytek hodnoty
         mul       dx                       ; vyn†soben° zbytkem
         mov       al,ah
         mov       ah,dl                    ; AX = oprava vòsledku
         add       ax,cx                    ; vòsledek

; ------ oprava znamÇnka vòsledku

         or        di,di
         jns       XSin5
         neg       ax
XSin5:   ret



SinTab   label     word
         dw        0                        ; 0
;         dw        201                      ; 1
         dw        402                      ; 2
;         dw        603                      ; 3
         dw        804                      ; 4
;         dw        1005                     ; 5
         dw        1206                     ; 6
;         dw        1407                     ; 7
         dw        1608                     ; 8
;         dw        1809                     ; 9
         dw        2009                     ; 10
;         dw        2210                     ; 11
         dw        2410                     ; 12
;         dw        2611                     ; 13
         dw        2811                     ; 14
;         dw        3012                     ; 15
         dw        3212                     ; 16
;         dw        3412                     ; 17
         dw        3612                     ; 18
;         dw        3811                     ; 19
         dw        4011                     ; 20
;         dw        4210                     ; 21
         dw        4410                     ; 22
;         dw        4609                     ; 23
         dw        4808                     ; 24
;         dw        5007                     ; 25
         dw        5205                     ; 26
;         dw        5404                     ; 27
         dw        5602                     ; 28
;         dw        5800                     ; 29
         dw        5998                     ; 30
;         dw        6195                     ; 31
         dw        6393                     ; 32
;         dw        6590                     ; 33
         dw        6786                     ; 34
;         dw        6983                     ; 35
         dw        7179                     ; 36
;         dw        7375                     ; 37
         dw        7571                     ; 38
;         dw        7767                     ; 39
         dw        7962                     ; 40
;         dw        8157                     ; 41
         dw        8351                     ; 42
;         dw        8545                     ; 43
         dw        8739                     ; 44
;         dw        8933                     ; 45
         dw        9126                     ; 46
;         dw        9319                     ; 47
         dw        9512                     ; 48
;         dw        9704                     ; 49
         dw        9896                     ; 50
;         dw        10087                    ; 51
         dw        10278                    ; 52
;         dw        10469                    ; 53
         dw        10659                    ; 54
;         dw        10849                    ; 55
         dw        11039                    ; 56
;         dw        11228                    ; 57
         dw        11417                    ; 58
;         dw        11605                    ; 59
         dw        11793                    ; 60
;         dw        11980                    ; 61
         dw        12167                    ; 62
;         dw        12353                    ; 63
         dw        12539                    ; 64
;         dw        12725                    ; 65
         dw        12910                    ; 66
;         dw        13094                    ; 67
         dw        13279                    ; 68
;         dw        13462                    ; 69
         dw        13645                    ; 70
;         dw        13828                    ; 71
         dw        14010                    ; 72
;         dw        14191                    ; 73
         dw        14372                    ; 74
;         dw        14553                    ; 75
         dw        14732                    ; 76
;         dw        14912                    ; 77
         dw        15090                    ; 78
;         dw        15269                    ; 79
         dw        15446                    ; 80
;         dw        15623                    ; 81
         dw        15800                    ; 82
;         dw        15976                    ; 83
         dw        16151                    ; 84
;         dw        16325                    ; 85
         dw        16499                    ; 86
;         dw        16673                    ; 87
         dw        16846                    ; 88
;         dw        17018                    ; 89
         dw        17189                    ; 90
;         dw        17360                    ; 91
         dw        17530                    ; 92
;         dw        17700                    ; 93
         dw        17869                    ; 94
;         dw        18037                    ; 95
         dw        18204                    ; 96
;         dw        18371                    ; 97
         dw        18537                    ; 98
;         dw        18703                    ; 99
         dw        18868                    ; 100
;         dw        19032                    ; 101
         dw        19195                    ; 102
;         dw        19357                    ; 103
         dw        19519                    ; 104
;         dw        19680                    ; 105
         dw        19841                    ; 106
;         dw        20000                    ; 107
         dw        20159                    ; 108
;         dw        20317                    ; 109
         dw        20475                    ; 110
;         dw        20631                    ; 111
         dw        20787                    ; 112
;         dw        20942                    ; 113
         dw        21096                    ; 114
;         dw        21250                    ; 115
         dw        21403                    ; 116
;         dw        21554                    ; 117
         dw        21705                    ; 118
;         dw        21856                    ; 119
         dw        22005                    ; 120
;         dw        22154                    ; 121
         dw        22301                    ; 122
;         dw        22448                    ; 123
         dw        22594                    ; 124
;         dw        22739                    ; 125
         dw        22884                    ; 126
;         dw        23027                    ; 127
         dw        23170                    ; 128
;         dw        23312                    ; 129
         dw        23452                    ; 130
;         dw        23592                    ; 131
         dw        23731                    ; 132
;         dw        23870                    ; 133
         dw        24007                    ; 134
;         dw        24143                    ; 135
         dw        24279                    ; 136
;         dw        24413                    ; 137
         dw        24547                    ; 138
;         dw        24680                    ; 139
         dw        24811                    ; 140
;         dw        24942                    ; 141
         dw        25072                    ; 142
;         dw        25201                    ; 143
         dw        25329                    ; 144
;         dw        25456                    ; 145
         dw        25582                    ; 146
;         dw        25708                    ; 147
         dw        25832                    ; 148
;         dw        25955                    ; 149
         dw        26077                    ; 150
;         dw        26198                    ; 151
         dw        26319                    ; 152
;         dw        26438                    ; 153
         dw        26556                    ; 154
;         dw        26674                    ; 155
         dw        26790                    ; 156
;         dw        26905                    ; 157
         dw        27019                    ; 158
;         dw        27133                    ; 159
         dw        27245                    ; 160
;         dw        27356                    ; 161
         dw        27466                    ; 162
;         dw        27575                    ; 163
         dw        27683                    ; 164
;         dw        27790                    ; 165
         dw        27896                    ; 166
;         dw        28001                    ; 167
         dw        28105                    ; 168
;         dw        28208                    ; 169
         dw        28310                    ; 170
;         dw        28411                    ; 171
         dw        28510                    ; 172
;         dw        28609                    ; 173
         dw        28706                    ; 174
;         dw        28803                    ; 175
         dw        28898                    ; 176
;         dw        28992                    ; 177
         dw        29085                    ; 178
;         dw        29177                    ; 179
         dw        29268                    ; 180
;         dw        29358                    ; 181
         dw        29447                    ; 182
;         dw        29535                    ; 183
         dw        29621                    ; 184
;         dw        29706                    ; 185
         dw        29791                    ; 186
;         dw        29874                    ; 187
         dw        29956                    ; 188
;         dw        30037                    ; 189
         dw        30117                    ; 190
;         dw        30195                    ; 191
         dw        30273                    ; 192
;         dw        30349                    ; 193
         dw        30424                    ; 194
;         dw        30498                    ; 195
         dw        30571                    ; 196
;         dw        30643                    ; 197
         dw        30714                    ; 198
;         dw        30783                    ; 199
         dw        30852                    ; 200
;         dw        30919                    ; 201
         dw        30985                    ; 202
;         dw        31050                    ; 203
         dw        31113                    ; 204
;         dw        31176                    ; 205
         dw        31237                    ; 206
;         dw        31297                    ; 207
         dw        31356                    ; 208
;         dw        31414                    ; 209
         dw        31470                    ; 210
;         dw        31526                    ; 211
         dw        31580                    ; 212
;         dw        31633                    ; 213
         dw        31685                    ; 214
;         dw        31736                    ; 215
         dw        31785                    ; 216
;         dw        31833                    ; 217
         dw        31880                    ; 218
;         dw        31926                    ; 219
         dw        31971                    ; 220
;         dw        32014                    ; 221
         dw        32057                    ; 222
;         dw        32098                    ; 223
         dw        32137                    ; 224
;         dw        32176                    ; 225
         dw        32213                    ; 226
;         dw        32250                    ; 227
         dw        32285                    ; 228
;         dw        32318                    ; 229
         dw        32351                    ; 230
;         dw        32382                    ; 231
         dw        32412                    ; 232
;         dw        32441                    ; 233
         dw        32469                    ; 234
;         dw        32495                    ; 235
         dw        32521                    ; 236
;         dw        32545                    ; 237
         dw        32567                    ; 238
;         dw        32589                    ; 239
         dw        32609                    ; 240
;         dw        32628                    ; 241
         dw        32646                    ; 242
;         dw        32663                    ; 243
         dw        32678                    ; 244
;         dw        32692                    ; 245
         dw        32705                    ; 246
;         dw        32717                    ; 247
         dw        32728                    ; 248
;         dw        32737                    ; 249
         dw        32745                    ; 250
;         dw        32752                    ; 251
         dw        32757                    ; 252
;         dw        32761                    ; 253
         dw        32765                    ; 254
;         dw        32766                    ; 255
         dw        32767                    ; 256


; -----------------------------------------------------------------------------
;        TAN
; -----------------------------------------------------------------------------

PUBLIC   XTan
XTan:    call      Vyraz
         ret

; -----------------------------------------------------------------------------
;        ABS
; -----------------------------------------------------------------------------

PUBLIC   XAbs
XAbs:    call      Vyraz
         or        ax,ax                    ; je z†pornÇ á°slo ?
         jns       XAbs2                    ; je kladnÇ á°slo
         neg       ax                       ; negace z†pornÇho á°sla na kladnÇ
XAbs2:   ret

; -----------------------------------------------------------------------------
;        ATN
; -----------------------------------------------------------------------------

PUBLIC   XAtn
XAtn:    call      Vyraz
         ret

; -----------------------------------------------------------------------------
;        SQR
; -----------------------------------------------------------------------------

PUBLIC   XSqr
XSqr:    call      Vyraz

XSqr0:   push      ax                       ; £schova á°sla

; ------ absolutn° hodnota á°sla

         or        ax,ax                    ; je z†pornÇ á°slo ?
         jns       XSqr1
         neg       ax
XSqr1:   cmp       ax,1                     ; je á°slo 0 nebo 1 ?
         jbe       XSqr4                    ; á°slo je n°zkÇ - vòsledek stejnò

; ------ cyklus vòpoátu odmocniny

         mov       cx,ax                    ; £schova á°sla
         mov       bx,ax
XSqr2:   mov       di,bx                    ; mezi£schova starÇho vòsledku
         mov       bx,ax                    ; novò mezivòsledek
         mov       ax,cx                    ; AX <- poá°tanÇ á°slo
         xor       dx,dx                    ; DX:AX=vòchoz° operand
         div       bx
         add       ax,bx
         shr       ax,1                     ; novò mezivòsledek
         cmp       ax,bx                    ; zmànil se vòsledek ?
         je        XSqr3                    ; vòsledek se jië nemàn°
         cmp       ax,di                    ; zacyklil se vòpoáet ?
         jne       XSqr2                    ; dal®° cyklus

XSqr3:   add       ax,bx
         inc       ax
         shr       ax,1                     ; oprava hodnoty

; ------ n†vrat znamÇnka á°sla

XSqr4:   pop       di
         or        di,di
         jns       XSqr5
         neg       ax
XSqr5:
         ret

; -----------------------------------------------------------------------------
;        BYTE
; -----------------------------------------------------------------------------

PUBLIC   XUsrByte
XUsrByte:lodsw                              ; adresa promànnÇ
         push      ax
         call      Vyraz                    ; vòpoáet vòrazu
         pop       bx
         mov       es:[bx],al               ; nastaven° promànnÇ BYTE
         ret

; -----------------------------------------------------------------------------
;        WORD
; -----------------------------------------------------------------------------

PUBLIC   XUsrWord
XUsrWord:lodsw                              ; adresa promànnÇ
         push      ax
         call      Vyraz                    ; vòpoáet vòrazu
         pop       bx
         mov       es:[bx],ax               ; nastaven° promànnÇ WORD
         ret

; -----------------------------------------------------------------------------
;        BYTE index
; -----------------------------------------------------------------------------

PUBLIC   XUsrBytI
XUsrBytI:lodsw                              ; adresa promànnÇ
         push      ax
         call      Vyraz                    ; vòpoáet indexu
         push      ax
         call      Vyraz                    ; vòpoáet vòrazu
         pop       bx                       ; index v promànnÇ
         pop       cx                       ; adresa promànnÇ
         add       bx,cx                    ; adresa poloëky
         cmp       bx,cs:[DatNum]           ; p©ekroáen konec dat ?
         jae       XUsrBtI2                 ; p©ekroáen konec datovÇho modulu
         mov       es:[bx],al               ; nastaven° promànnÇ BYTE
XUsrBtI2:ret

; -----------------------------------------------------------------------------
;        WORD index
; -----------------------------------------------------------------------------

PUBLIC   XUsrWorI
XUsrWorI:lodsw                              ; adresa promànnÇ
         push      ax                       ; adresa promànnÇ
         call      Vyraz                    ; vòpoáet vòrazu
         shl       ax,1                     ; offset poloëky
         push      ax                       ; offset poloëky
         call      Vyraz                    ; vòpoáet vòrazu
         pop       bx                       ; offset poloëky
         pop       cx                       ; adresa promànnÇ
         add       bx,cx                    ; adresa poloëky
         cmp       bx,cs:[DatNum]           ; p©ekroáen konec dat ?
         jae       XUsrWrI2                 ; p©ekroáen konec datovÇho modulu
         mov       es:[bx],ax               ; nastaven° promànnÇ WORD
XUsrWrI2:ret

; -----------------------------------------------------------------------------
;        Uëivatelsk† procedura
; -----------------------------------------------------------------------------

PUBLIC   XUser
XUser:   lodsw                              ; adresa uëivatelskÇ procedury
         push      si                       ; £schova n†vratovÇ adresy
         mov       si,ax                    ; nov† adresa programu (procedura)
         call      Anim                     ; proveden° obsluhy procedury
         pop       si                       ; n†vrat ukazatele programu
         ret

; -----------------------------------------------------------------------------
;        Poskytnut° adresy stavovÇho registru CRT
; -----------------------------------------------------------------------------

GetPort:
         push      ds
         xor       dx,dx                    ; DX <- 0
         mov       ds,dx
         mov       dx,ds:[463h]             ; adresa ©°dic°ho registru CRT
         pop       ds
         add       dx,6                     ; stavovò registr CRT
         ret

; *****************************************************************************
;
;                          Obsluhy funkc° BIOS
;
; *****************************************************************************

PUBLIC   Int10
Int10:   pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

; *****************************************************************************
;
;                         Datovò segment
;
; *****************************************************************************

TabOper  label     word                   ;* tabulka obsluh oper†torñ

         dw        offset OpKonec           ; 0: konec vòrazu
         dw        offset Vyraz             ; 1: (
         dw        offset OpRght            ; 2: )
         dw        offset OpMoc             ; 3: ^
         dw        offset OpMul             ; 4: *
         dw        offset OpDiv             ; 5: /
         dw        offset OpMod             ; 6: MOD
         dw        offset OpShl             ; 7: <<
         dw        offset OpShr             ; 8: >>
         dw        offset OpAdd             ; 9: +
         dw        offset OpSub             ; 10: -
         dw        offset OpEqu             ; 11: =
         dw        offset OpNeq             ; 12: <>
         dw        offset OpLt              ; 13: <
         dw        offset OpGt              ; 14: >
         dw        offset OpLte             ; 15: <=
         dw        offset OpGte             ; 16: >=
         dw        offset OpNot             ; 17: NOT
         dw        offset OpAnd             ; 18: AND
         dw        offset OpOr              ; 19: OR
         dw        offset OpXor             ; 20: XOR

         dw        81h - 20 - 1 dup(offset OpKonec)

         dw        offset OpKonst           ; 81h: á°seln† konstanta
         dw        offset OpInter           ; 82h: intern° procedura
         dw        offset OpUsr             ; 83h: uëivatelsk† procedura
         dw        offset OpByte            ; 84h: promànn† BYTE
         dw        offset OpWord            ; 85h: promànn† WORD
         dw        offset OpByteI           ; 86h: promànn† BYTE s indexem
         dw        offset OpWordI           ; 87h: promànn† WORD s indexem


TabFnc   label     word                   ;* tabulka intern°ch funkc°

         dw        offset XNop              ; 0   (LINK), tÇë pr†zdnò p©°kaz NOP
         dw        offset XNop              ; 1   (INCLUDE)
         dw        offset XNop              ; 2   (BYTE)
         dw        offset XNop              ; 3   (WORD)
         dw        offset XNop              ; 4   (STRING)
         dw        offset XNop              ; 5   (PROC)
         dw        offset XEndProc          ; 6 ENDPROC
         dw        offset XReturn           ; 7 RETURN
         dw        offset XExec             ; 8 EXEC
         dw        offset XIf               ; 9 IF
         dw        offset XNop              ; 10   (THEN)
         dw        offset XElse             ; 11   ELSE
         dw        offset XNop              ; 12   (ENDIF)
         dw        offset XFor              ; 13 FOR
         dw        offset XNop              ; 14   (TO)
         dw        offset XNop              ; 15   (STEP)
         dw        offset XNop              ; 16   (DO)
         dw        offset XOn               ; 17 ON
         dw        offset XEndDo            ; 18 ENDDO
         dw        offset XNop              ; 19   (EXIT)
         dw        offset XCase             ; 20 CASE
         dw        offset XIn               ; 21 IN
         dw        offset XOut              ; 22 OUT
         dw        offset XNop              ; 23   (ENDCASE)
         dw        offset XVal              ; 24 VAL
         dw        offset XStr              ; 25 STR
         dw        offset XLen              ; 26 LEN
         dw        offset XCard             ; 27 CARD
         dw        offset XVideo            ; 28 VIDEO
         dw        offset XNop              ; 29   (GVIDEO)
         dw        offset XMode             ; 30 MODE
         dw        offset XPage             ; 31 PAGE
         dw        offset XXPage            ; 32 XPAGE
         dw        offset XWind             ; 33 WINDOW
         dw        offset XPal              ; 34 PALETE
         dw        offset XXCol             ; 35 XCOLOR
         dw        offset XSetCur           ; 36 SETCURS
         dw        offset XCurOff           ; 37 CURSOFF
         dw        offset XLoad             ; 38 LOAD
         dw        offset XObj              ; 39 OBJECT
         dw        offset XUnld             ; 40 UNLOAD
         dw        offset XText             ; 41 TEXT
         dw        offset XPoint            ; 42 POINT
         dw        offset XLine             ; 43 LINE
         dw        offset XRLine            ; 44 RLINE
         dw        offset XBox              ; 45 BOX
         dw        offset XFBox             ; 46 FBOX
         dw        offset XCirc             ; 47 CIRC
         dw        offset XFCirc            ; 48 FCIRC
         dw        offset XPress            ; 49 PRESS
         dw        offset XTstKey           ; 50 TESTKEY
         dw        offset XGtKey            ; 51 GETKEY
         dw        offset XStatKey          ; 52 STATKEY
         dw        offset XInp              ; 53 INPUT
         dw        offset XSound            ; 54 SOUND
         dw        offset XTon              ; 55 TON
         dw        offset XMusic            ; 56 MUSIC
         dw        offset XMStop            ; 57 MUSICSTOP
         dw        offset XMusGet           ; 58 MUSICGET
         dw        offset XWait             ; 59 WAIT
         dw        offset XTime             ; 60 TIME
         dw        offset XDate             ; 61 DATE
         dw        offset XXMous            ; 62 XMOUSE
         dw        offset XYMous            ; 63 YMOUSE
         dw        offset XKMous            ; 64 GETMOUSE
         dw        offset XMon              ; 65 MOUSEON
         dw        offset XMoff             ; 66 MOUSEOFF
         dw        offset XDefm             ; 67 CURMOUSE
         dw        offset XWinm             ; 68 WINMOUSE
         dw        offset XRnd              ; 69 XRND
         dw        offset XReg              ; 70 REGISTER
         dw        offset XHSyn             ; 71 HSYN
         dw        offset XVSyn             ; 72 VSYN
         dw        offset XPatt             ; 73 PATTERN
         dw        offset XStick            ; 74 STICK
         dw        offset XTrig             ; 75 TRIG
         dw        offset XSin              ; 76 SIN
         dw        offset XCos              ; 77 COS
         dw        offset XTan              ; 78 TAN
         dw        offset XAbs              ; 79 ABS
         dw        offset XAtn              ; 80 ATN
         dw        offset XSqr              ; 81 SQR

         dw        0f8h - 81 - 1 dup(offset XNop)

         dw        offset XUsrByte          ; f8h BYTE
         dw        offset XUsrWord          ; f9h WORD
         dw        offset XUsrBytI          ; fah BYTE index
         dw        offset XUsrWorI          ; fbh WORD index

         dw        3 dup(offset XNop)

         dw        offset XUser             ; ffh uëivatelsk† procedura



; Struktura objektñ:
;                     0 (2) = á°slo objektu
;                     2 (2) = velikost bloku pamàti (v odstavc°ch)
;                     4 (2) = rozmàry X
;                     6 (2) = rozmàry Y
;                     8 (2) = poáet barevnòch rovin
;                    10 (2) = barva pozad°
;                    12 (2) = poáet bajtñ definice palet
;                    14 (1) = videom¢d
;                    15 (1) = parametry
;                                bit 0: 1=komprese
;                                bit 1: 1=textovò m¢d
;                                bit 2: 1=paraleln° uloëen° barev
;                    10h    = data

ModSir   EQU       0                        ; ®°©ka ©†dku (jednotek)
ModVys   EQU       2                        ; vò®ka ©†dku (jednotek)
ModSirB  EQU       4                        ; ®°©ka ©†dku (bajtñ)
ModRov   EQU       6                        ; poáet barevnòch rovin
ModCLR   EQU       8                        ; obsluha vymaz†n° displeje
ModPrep  EQU       10                       ; p©°prava parametrñ pro zobrazen°
ModSet   EQU       12                       ; nastaven° pro zobrazen° roviny AX
ModDisp  EQU       14                       ; obsluha zobrazen° linky
ModLine  EQU       16                       ; obsluha zobrazen° á†ry
ModPoint EQU       18                       ; zobrazen° bodu


TabMod   label     word                   ;* tabulka videom¢dñ

                                          ;* 0: 40x25 text
         dw        40                       ; ®°©ka (jednotek)
         dw        25                       ; vò®ka (linek)
         dw        40                       ; ®°©ka ©†dku (bajtñ)
         dw        2                        ; poáet barevnòch rovin
         dw        offset ClrTXT            ; vymaz†n° nastavenou barvou
         dw        offset PrepTxt           ; p©°prava parametrñ pro zobrazen°
         dw        offset SetTXT            ; nastaven° pro zobrazen° roviny AX
         dw        offset DispTxt           ; zobrazen° linky
         dw        offset LineTxt           ; zobrazen° á†ry
         dw        offset PointTxt          ; zobrazen° bodu

TabMod0  label     word                     ; n†và®t° pro vòpoáet dÇlky poloëky

                                          ;* 1: 40x25 text
         dw        40,25,40,2
         dw        offset ClrTXT
         dw        offset PrepTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset LineTxt
         dw        offset PointTxt

                                          ;* 2: 80x25 text
         dw        80,25,80,2
         dw        offset ClrTXT
         dw        offset PrepTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset LineTxt
         dw        offset PointTxt

                                          ;* 3: 80x25 text
         dw        80,25,80,2
         dw        offset ClrTXT
         dw        offset PrepTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset LineTxt
         dw        offset PointTxt

                                          ;* 4: 320x200/4 graf
         dw        320,200,80,2
         dw        offset ClrCG4
         dw        offset PrepCG4
         dw        offset SetCG4
         dw        offset DispCG4
         dw        offset LineCG4
         dw        offset PointCG4

                                          ;* 5: 320x200/4 graf
         dw        320,200,80,2
         dw        offset ClrCG4
         dw        offset PrepCG4
         dw        offset SetCG4
         dw        offset DispCG4
         dw        offset LineCG4
         dw        offset PointCG4

                                          ;* 6: 640x200/2 graf
         dw        640,200,80,1
         dw        offset ClrCG6
         dw        offset PrepCG6
         dw        offset SetCG6
         dw        offset DispCG4
         dw        offset LineCG6
         dw        offset PointCG6

                                          ;* 7: 80x25 text
         dw        80,25,80,2
         dw        offset ClrTXT
         dw        offset PrepTXT
         dw        offset SetTXT
         dw        offset DispTXT
         dw        offset LineTxt
         dw        offset PointTxt

                                          ;* 8: 160x200/16 graf.
         dw        160,200,80,4
         dw        offset ClrPCJ
         dw        offset PrepPCJ
         dw        offset SetPCJ
         dw        offset DispPCJ
         dw        offset LinePCJ
         dw        offset PointPCJ

                                          ;* 9: 320x200/16 graf.
         dw        320,200,160,4
         dw        offset ClrPCJ
         dw        offset PrepPCJ
         dw        offset SetPCJ
         dw        offset DispPCJ
         dw        offset LinePCJ
         dw        offset PointPCJ

                                          ;* 10: 640x200/4 graf.
         dw        640,200,160,4
         dw        offset ClrPCJ
         dw        offset PrepPCJ
         dw        offset SetPCJ
         dw        offset DispPCJ
         dw        offset LinePCJ
         dw        offset PointPCJ

                                          ;* 11: intern°
         dw        80,25,80,2
         dw        offset ClrTXT
         dw        offset PrepTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset LineTxt
         dw        offset PointTxt

                                          ;* 12: intern°
         dw        80,25,80,2
         dw        offset ClrTXT
         dw        offset PrepTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset LineTxt
         dw        offset PointTxt

                                          ;* 13: 320x200/16 graf
         dw        320,200,40,4
         dw        offset ClrEGA
         dw        offset PrepEGA
         dw        offset SetEGA
         dw        offset DispEG3
         dw        offset LineEGA
         dw        offset PointEGA

                                          ;* 14: 640x200/16 graf
         dw        640,200,80,4
         dw        offset ClrEGA
         dw        offset PrepEGA
         dw        offset SetEGA
         dw        offset DispEG3
         dw        offset LineEGA
         dw        offset PointEGA

                                          ;* 15: 640x350/2 graf
         dw        640,350,80,1
         dw        offset ClrEGA
         dw        offset PrepEGA
         dw        offset SetEGA
         dw        offset DispEG3
         dw        offset LineEGA
         dw        offset PointEGA

                                          ;* 16: 640x350/16 graf
         dw        640,350,80,4
         dw        offset ClrEGA
         dw        offset PrepEGA
         dw        offset SetEGA
         dw        offset DispEG3
         dw        offset LineEGA
         dw        offset PointEGA

                                          ;* 17: 640x480/2 graf
         dw        640,480,80,1
         dw        offset ClrCG6
         dw        offset PrepCG6
         dw        offset SetCG6
         dw        offset DispCG4
         dw        offset LineCG6
         dw        offset PointCG6

                                          ;* 18: 640x480/16 graf
         dw        640,480,80,4
         dw        offset ClrEGA
         dw        offset PrepEGA
         dw        offset SetEGA
         dw        offset DispEG3
         dw        offset LineEGA
         dw        offset PointEGA

                                          ;* 19: 320x200/256 graf
         dw        320,200,320,8
         dw        offset ClrMCG
         dw        offset PrepMCG
         dw        offset SetMCG
         dw        offset DispMCG
         dw        offset LineMCG
         dw        offset PointMCG

TabPal   db        0,1,2,3,4,5,14h,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0 ; palety

; ------ parametry pro zobrazen° objektñ

                                          ;* parametry ze z†hlav° objektu (12 B)
Sirka    dw        0                        ; ®°©ka vò©ezu (pozic)
Vyska    dw        0                        ; vò®ka vò©ezu (linek)
Rovin    dw        0                        ; poáet barevnòch rovin
Pozadi   dw        0                        ; barva pozad°
Palet    dw        0                        ; poáet bajtñ palet
Mod      db        0                        ; videom¢d displeje
Param    db        0                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textovò videom¢d
                                            ;  bit 2: 1=paraleln° uloëen° barev
                                            ;  bit 3: 1=je maska pozad°

                                          ;* rozmàry vòstupn°ho okna
Wind1    dw        8000h                    ; levò okraj okna
Wind2    dw        8000h                    ; horn° okraj okna
Wind3    dw        7fffh                    ; pravò okraj okna
Wind4    dw        7fffh                    ; spodn° okraj okna

                                          ;* parametry okna (rozmàry)
ObjLD    dw        0                        ; levò okraj zaá†tku zobrazen°
ObjUD    dw        0                        ; horn° okraj zaá†tku zobrazen°
ObjLO    dw        0                        ; levò okraj poá†tku v objektu
ObjUO    dw        0                        ; horn° okraj poá†tku v objektu
ObjS     dw        0                        ; ®°©ka vò©ezu k zobrazen°
ObjV     dw        0                        ; vò®ka vò©ezu k zobrazen°

                                          ;* parametry pro zobrazen° á†ry
LineX1   dw        0                        ; poá†teán° sou©adnice X1
LineY1   dw        0                        ; poá†teán° sou©adnice Y1
LineX2   dw        0                        ; poá†teán° sou©adnice X2
LineY2   dw        0                        ; poá†teán° sou©adnice Y2
LineB    dw        0                        ; poáet bajtñ na linku


                                          ;* pracovn° parametry pro zobrazen°
SirkaB   dw        0                        ; ®°©ka vò©ezu (bajtñ)
RovinaB  dw        0                        ; poáet bajtñ na rovinu
MaskAdr  dd        0                        ; adresa masky
MaskRot  db        0                        ; poáet rotac° bajtu p©i zobrazen°
MaskNum  db        0                        ; poáet vnit©n°ch bajtñ linky
MaskFrst db        0ffh                     ; maska prvn°ho bajtu linky
MaskLst  db        0ffh                     ; maska posledn°ho bajtu linky

Pattern  db        8 dup(0ffh)              ; vzorek pro vòpl§
AndPatt  db        0ffh                     ; logickò souáin vzorkñ vòplnà
OrPatt   db        0ffh                     ; logickò souáet vzorkñ vòplnà

; ------ obsluha kl†vesnice

Keys     dw        0                        ; posledn° znak z kl†vesnice

; ------ parametry pro pr†ci s pamàt°

DatNum   dw        0                        ; poáet bajtñ datovÇho modulu
DatMem   dw        SEG SegProg              ; segment s daty programu
ProgMem  dw        0                        ; segment s naátenòm programem
ObjMem   dw        0                        ; segment s prvn°m objektem
TopMem   dw        0                        ; segment zaá†tku volnÇ pamàti

; ------ parametry displeje

BitDisp  dw        0                        ; m¢d displeje (p©°znakovÇ bity)
OldVMod  db        3                        ; pñvodn° videom¢d
VMod     db        3                        ; aktu†ln° videom¢d
SegVRAM  dw        0b800h                   ; segment videopamàti
DelVRAM  dw        2000h                    ; dÇlka videostr†nky
EgaVga   db        1                        ; p©°znak karty EGA/VGA
KurzPoz  dw        0                        ; aktu†ln° pozice kurzoru
MaxPoz   db        80                       ; maxim†ln° poáet pozic
MaxRad   db        25                       ; maxim†ln° poáet ©†dkñ

Page1    db        0                        ; aktivnà zobrazen† str†nka
Page2    db        0                        ; vòstupn° str†nka

; ------ ChybovÇ texty

MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'
KartTxt  db        'Program vyzaduje grafickou kartu EGA nebo VGA !',13,10,'$'

FndTxt   db        'Chyba - soubor $'
Fnd2Txt  db        ' nenalezen !',13,10,'$'

RetKod   db        -1                       ; n†vrat. k¢d z programu (=p©eru®.)
SegPSP   dw        0                        ; £schova adresy PSP


Code     ENDS

; *****************************************************************************
;
;                  P©echodnò z†sobn°k pro interpreter
;
; *****************************************************************************

Stack    SEGMENT   stack para

         db        20h dup(0)

Stack    ENDS

; *****************************************************************************
;
;                       Segment programu
;
; *****************************************************************************

SegProg  SEGMENT PARA


SegProg  ENDS

         END       Start

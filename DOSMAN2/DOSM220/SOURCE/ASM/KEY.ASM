

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              K E Y B O A R D
;
;         Obsluha vstupu z kl†vesnice, editace ©†dku, obsluha my®i
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeKey  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeKey,ds:Data

; -----------------------------------------------------------------------------
;   zahr†n° melodie ES:SI (bajty: DêLKA (0=konec), TïN (0=mezera)) (BREAK !)
; -----------------------------------------------------------------------------

PlayMus  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      si

; ------ zahr†n° jednoho t¢nu

         cld
PlayMus2:lods      word ptr es:[si]         ; naáten° jednoho t¢nu
         cmp       al,0                     ; je konec melodie ?
         je        PlayMus3                 ; je konec melodie
         push      cs
         call      near ptr PlayTon         ; zahr†n° jednoho t¢nu
         jmp       short PlayMus2           ; dal®° t¢n

; ------ n†vrat registrñ

PlayMus3:pop       si
         pop       ax
         ret

PlayMus  ENDP

; -----------------------------------------------------------------------------
;        zahr†n° t¢nu AH (1 aë 120, 0=mezera), dÇlka AL (lze p©eru®it BREAK !!!)
; -----------------------------------------------------------------------------

PlayTon  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      es

; ------ test, zda je p©eru®en°

         call      far ptr TestBEsc         ; nen° p©eru®en° ?
         jc        PlayTon6                 ; je p©eru®en°

; ------ nastaven° dàliáky pro zadanò t¢n

         mov       bh,0
         mov       bl,ah                    ; BX <- zadanò t¢n
         shl       bx,1                     ; á°slo t¢nu * 2
         jz        PlayTon1                 ; je mezera
         mov       bx,cs:[bx+TabTon-2]      ; dàlic° konstanta
         push      cs
         call      near ptr SoundOn         ; zapnut° zvukovÇho gener†toru

; ------ p©°prava k á°t†n° áasu

PlayTon1:xor       cx,cx                    ; CX <- 0
         mov       es,cx                    ; ES <- 0
         mov       cl,al                    ; CX <- dÇlka t¢nu
         jcxz      PlayTon6                 ; dÇlka = 0

; ------ áek†n° po zadanou dobu

PlayTon2:mov       bx,es:[46ch]             ; aktu†ln° áasovaá
PlayTon3:sti                                ; p©eru®en° povoleno
         call      far ptr TestBEsc         ; nen° p©eru®en° ?
         jc        PlayTon6                 ; je p©eru®en°
         cmp       bx,es:[46ch]             ; je zmàna hodin ?
         je        PlayTon3                 ; áek†n° na zmànu hodin
         loop      PlayTon2                 ; dal®° impuls

; ------ vypnut° t¢nu (je pot©eba i pro malò lupanec mezi t¢ny)

PlayTon6:push      cs
         call      near ptr SoundOff        ; vypnut° zvukovÇho gener†toru

; ------ n†vrat registrñ

         pop       es
         pop       cx
         pop       bx
         ret

PlayTon  ENDP

; -----------------------------------------------------------------------------
;        zapnut° vòstupu na reproduktor - dàlic° konstanta BX
; -----------------------------------------------------------------------------

SoundOn  PROC      FAR

; ------ £schova registrñ

         cli
         push      ax

; ------ nastaven° frekvence

         mov       al,0b6h                  ; povel pro nastaven° dàliáky
         out       [43h],al                 ; nastaven° m¢du dàliáky

         mov       al,bl                    ; dàlic° konstanta LOW
         out       [42h],al                 ; nastaven° konstanty LOW
         mov       al,bh                    ; dàlic° konstanta HIGH
         out       [42h],al                 ; nastaven° konstanty HIGH

; ------ zapnut° vòstupu na reproduktor

         in        al,[61h]
         or        al,bit0+bit1             ; zapnut° vòstupu na reproduktor
         out       [61h],al

; ------ n†vrat registrñ

         pop       ax
         sti
         ret

SoundOn  ENDP

; -----------------------------------------------------------------------------
;        vypnut° vòstupu na reproduktor
; -----------------------------------------------------------------------------

SoundOff PROC      FAR

; ------ £schova registrñ

         cli
         push      ax

; ------ vypnut° vòstupu na reproduktor

         in        al,[61h]
         and       al,not bit0+bit1
         out       [61h],al                 ; vypnut° vòstupu na reproduktor

; ------ nastaven° standardn° frekvence gener†toru

         mov       al,0b6h                  ; povel pro nastaven° dàliáky
         out       [43h],al                 ; nastaven° m¢du dàliáky
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n°ë®° bajt
         out       [42h],al                 ; konstanta - vy®®° bajt

; ------ n†vrat registrñ

         pop       ax
         sti
         ret

SoundOff ENDP

; -----------------------------------------------------------------------------
;        tabulka dàlic°ch konstant t¢nñ
; -----------------------------------------------------------------------------

TabTon   label     word                     ; tabulka pro nastaven° t¢nñ
         dw        36485,34437,32505,30680,28958,27333 ; okt†va 0 (1 aë 12)
         dw        25799,24351,22984,21694,20477,19327
         dw        18243,17219,16252,15340,14479,13667 ; okt†va 1 (13 aë 24)
         dw        12899,12175,11492,10847,10238,9664
         dw        9121,8609,8126,7670,7240,6833       ; okt†va 2 (25 aë 36)
         dw        6450,6088,5746,5424,5119,4832
         dw        4561,4305,4063,3835,3620,3417       ; okt†va 3 (37 aë 48)
         dw        3225,3044,2873,2712,2560,2416
         dw        2280,2152,2032,1918,1810,1708       ; okt†va 4 (49 aë 60)
         dw        1612,1522,1437,1356,1280,1208
         dw        1140,1076,1016,959,905,854          ; okt†va 5 (61 aë 72)
         dw        806,761,718,678,640,604
         dw        570,538,508,479,452,427             ; okt†va 6 (73 aë 84)
         dw        403,380,359,339,320,302
         dw        285,269,254,240,226,214             ; okt†va 7 (85 aë 96)
         dw        202,190,180,169,160,151
         dw        143,135,127,120,113,107             ; okt†va 8 (97 aë 108)
         dw        101,95,90,85,80,75
         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt†va 9 (109 aë 120)

; *****************************************************************************
;                              FlushEsc
;              vypr†zdnàn° bufferu kl†vesnice p©i p©eru®en°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

FlushEsc PROC      FAR

         pushf
         push      ax

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        FlshEsc2                 ; je p©eru®en° operace
         call      far ptr TestChar         ; je p©ipraven nàjakò znak ?
         jc        FlshEsc4                 ; nen° p©ipraven ë†dnò znak
         cmp       ax,11bh                  ; je to kl†vesa ESC ?
         jne       FlshEsc4                 ; nen° to kl†vesa ESC

FlshEsc2:push      cs
         call      near ptr FlushChr        ; vypr†zdnàn° bufferu kl†vesnice

FlshEsc4:pop       ax
         popf
         ret

FlushEsc ENDP

; *****************************************************************************
;                               FlushChr
;                     vypr†zdnàn° bufferu kl†vesnice
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

FlushChr PROC      FAR

         push      ax
FlushCh1:push      cs
         call      near ptr TestChar        ; test, zda je p©ipraven znak
         jc        FlushCh2                 ; nen° p©ipraven znak z kl†vesnice
         push      cs
         call      near ptr InputChar       ; zru®en° znaku z kl†vesnice
         jmp       short FlushCh1           ; test dal®°ho znaku
FlushCh2:pop       ax
         ret

FlushChr ENDP

; *****************************************************************************
;                           TestChar
;             test, zda je p©ipraven znak z kl†vesnice
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=nen° p©ipraven znak z kl†vesnice
;        AX=k¢d p©ipravenÇ kl†vesy
; *****************************************************************************

TestCh1: call      far ptr InputChar        ; zru®en° znaku z kl†vesnice

TestChar PROC      FAR

; ------ nulov†n° p©°znaku kl†vesy INSERT

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[418h],not bit7
         pop       ds

; ------ test znaku v p©echodnÇm bufferu

         mov       ax,ds:[KeyBuff]          ; kl†vesa v bufferu
         or        ax,ax                    ; je p©ipraven znak ?
         jnz       TestCh3                  ; je p©ipravena kl†vesa

; ------ test znaku v DOS m¢du

         test      byte ptr ds:[MonoMod],bit4 ; je ANSI ovladaá ?
         jz        TestCh4                  ; nen° ANSI

         mov       ah,0bh
         int       21h                      ; test znaku z konzoly
         mov       ah,0
         cmp       al,0                     ; 0=nen° znak
         jmp       short TestCh42

; ------ test znaku v bufferu kl†vesnice

TestCh4: sti
         mov       ah,1
         int       16h                      ; test stavu kl†vesnice
         sti
TestCh42:jz        TestCh2                  ; nen° p©ipravena ë†dn† kl†vesa

; ------ kl†vesa je p©ipravena

TestCh3: test      byte ptr ds:[DarkParm],bit1 ; je displej ztmaven ?
         call      far ptr DarkNul          ; nulov†n° ztmaven° displeje
         jnz       TestCh1                  ; displej je ztmaven
;         clc                                ; p©°znak, ëe je kl†vesa
         ret

; ------ kl†vesa nen° p©ipravena

TestCh2: stc
         ret

TestChar ENDP

; *****************************************************************************
;                              InputChar
;                      vstup znaku z kl†vesnice
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:AX=k¢d kl†vesy
; *****************************************************************************

InputChar PROC     FAR

; ------ vstup znaku z p©echodnÇho bufferu

         xor       ax,ax                    ; AX <- 0
         xchg      ax,ds:[KeyBuff]          ; vyjmut° znaku z p©echodnÇho buff.
         or        ax,ax                    ; byl v bufferu znak ?
         jz        InpCh6
;         jnz       InpCh2                   ; v bufferu byl p©ipraven znak
         ret

; ------ vstup znaku v DOS m¢du

InpCh6:  test      byte ptr ds:[MonoMod],bit4 ; je ANSI ovladaá ?
         jz        InpCh5                   ; nen° ANSI
         mov       ah,7
         int       21h                      ; vstup znaku

         mov       ah,0
         cmp       al," "
         jae       InpCh4

         push      bx
         mov       bx,ax
         mov       ah,cs:[bx+TabCtrls]
         pop       bx

         cmp       al,1fh
         je        InpCh62                  ; speci†ln° p©ep°naá
         cmp       al,0
         jne       InpCh4

InpCh62: mov       ah,7
         int       21h                      ; vstup SCAN k¢du
         mov       ah,al
         mov       al,0
         cmp       ah,0ch
         jne       InpCh4
         mov       al,1fh                   ; Ctrl-_
         jmp       short InpCh4

; ------ vstup znaku z kl†vesnice

InpCh5:  sti
         mov       ah,0
         int       16h
         sti

         cmp       ax,185h                  ; F11
         jb        InpCh502
         cmp       ax,18ch                  ; Alt-F12
         ja        InpCh502
         mov       ah,al                    ; oprava pro x-F11 a x-F12
         mov       al,0

InpCh502:cmp       al,0
         jne       InpCh4

         push      bx
         push      ax

         push      cs
         call      near ptr InpPres0        ; vstup p©esmykaáñ

         xchg      ax,bx
         pop       ax
         mov       al,bl
         pop       bx

         and       al,bit0+bit1+bit2

; ------ korekce pro makro z CSKEY Ctrl-Alt-kurzory

         cmp       al,5                     ; Alt-Shift-
         je        InpCh50                  ; je Alt-Shift-
         cmp       al,6                     ; je Ctrl-Alt ?
         jne       InpCh51                  ; nen° Ctrl-Alt

InpCh50: cmp       ah,48h                   ; nahoru
         je        InpCh52
         cmp       ah,4bh                   ; vlevo
         je        InpCh52
         cmp       ah,4dh                   ; vpravo
         je        InpCh52
         cmp       ah,50h                   ; dolñ
         je        InpCh52
         cmp       ah,53h                   ; Delete
         je        InpCh52

InpCh51: cmp       al,4                     ; n†sobnò p©esmykaá
         jae       InpCh4
InpCh52: mov       al,0                     ; norm†ln° p©esmykaá

InpCh4:  cmp       ax,12fh
         jne       InpCh3
         mov       ax,0e02fh

InpCh3:  cmp       ax,320dh                 ; Ctrl-M
         jne       InpCh32
         mov       ah,1ch                   ; Enter

InpCh32: cmp       ax,1709h                 ; Ctrl-I
         jne       InpCh34
         mov       ah,0fh                   ; Tab

InpCh34: cmp       ax,1a1bh                 ; Ctrl-]
         jne       InpCh36
         mov       ah,1                     ; Esc

InpCh36: cmp       ax,2308h                 ; Ctrl-H
         jne       InpCh37
         mov       ah,0eh                   ; BS

InpCh37: cmp       ax,194h                  ; Ctrl-Tab
         jne       InpCh38
         mov       ax,9                     ; n†hrada Alt-9

InpCh38:
         cmp       ax,11bh
         je        InpCh1
         cmp       ah,1
         jne       InpCh1
         mov       ah,al
         xor       al,al
InpCh1:

InpCh2:  ret

InputChar ENDP

TabCtrls label     byte                     ; tabulka SCAN k¢dñ CTRL-
         db        3                        ; 0: Ctrl-@
         db        1eh                      ; 1: Ctrl-A
         db        30h                      ; 2: Ctrl-B
         db        2eh                      ; 3: Ctrl-C
         db        20h                      ; 4: Ctrl-D
         db        12h                      ; 5: Ctrl-E
         db        21h                      ; 6: Ctrl-F
         db        22h                      ; 7: Ctrl-G
         db        23h                      ; 8: Ctrl-H
         db        17h                      ; 9: Ctrl-I
         db        24h                      ; 10: Ctrl-J
         db        25h                      ; 11: Ctrl-K
         db        26h                      ; 12: Ctrl-L
         db        32h                      ; 13: Ctrl-M
         db        31h                      ; 14: Ctrl-N
         db        18h                      ; 15: Ctrl-O
         db        19h                      ; 16: Ctrl-P
         db        10h                      ; 17: Ctrl-Q
         db        13h                      ; 18: Ctrl-R
         db        1fh                      ; 19: Ctrl-S
         db        14h                      ; 20: Ctrl-T
         db        16h                      ; 21: Ctrl-U
         db        2fh                      ; 22: Ctrl-V
         db        11h                      ; 23: Ctrl-W
         db        2dh                      ; 24: Ctrl-X
         db        15h                      ; 25: Ctrl-Y
         db        2ch                      ; 26: Ctrl-Z
         db        1ah                      ; 27: Ctrl-[
         db        2bh                      ; 28: Ctrl-\
         db        1bh                      ; 29: Ctrl-]
         db        7                        ; 30: Ctrl-^
         db        0ch                      ; 31: Ctrl-_

; *****************************************************************************
;                              InpPres0
;              vstup stavu p©esmykaáñ kl†vesnice bez £schovy
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:AX=aktu†ln° stav p©esmykaáñ (bit4: Shift-, bit5: Ctrl-, bit6: Alt-)
;        NZ=je p©esmykaá Shift-
; *****************************************************************************

; Chyba - ve WINDOWS 95 ukazoval procesor velkÇ zat°ëen°. Bylo zji®tàno,
;         ëe zat°ëen° se objevuje v p©°padà, ëe od p©edchoz°ch procedur
;         je na zaá†tku tÇto funkce INT 16h vynulov†n p©°znak ZF. Proto
;         je zde doplnàna instrukce XOR AX,AX.

InpPres0 PROC      FAR

; ------ dotaz na stav p©esmykaáñ

         xor       ax,ax
;         inc       ax                       ; tato instrukce by zpñsobila p©et°ëen°

         sti
         mov       ah,2
         int       16h                      ; poskytnut° stavu p©esmykaáñ

; ------ konverze form†tu bajtu p©esmykaáñ

         shr       al,1                     ; vypu®tàn° p©°znaku RShift-
         jnc       InpPres4                 ; nebyl p©esmykaá RShift-
         or        al,1                     ; nastaven° p©°znaku Shift-

; ------ korekce p©esmykaáñ

InpPres4:and       al,bit0+bit1+bit2
         mov       ah,al
         cmp       al,3
         jne       InpPres5
         mov       al,4
         jmp       short InpPres6

InpPres5:cmp       al,4
         jne       InpPres6
         mov       al,3

InpPres6:shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1
         or        al,ah

; ------ stav p©esmykaáñ

         mov       ah,0
         test      al,bit4                  ; test stavu Shift-
         ret

InpPres0 ENDP

; *****************************************************************************
;                            InpPresm
;                 vstup stavu p©esmykaáñ kl†vesnice
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:AX=aktu†ln° stav p©esmykaáñ
;        CY=stav p©esmykaáñ nebyl zmànàn od posledn° obsluhy
; *****************************************************************************

InpPresm PROC      FAR

; ------ dotaz na stav p©esmykaáñ

         push      cs
         call      near ptr InpPres0        ; vstup stavu p©esmykaáñ

; ------ uschov†n° stavu p©esmykaáñ

         cmp       al,ds:[Presmyk]          ; je zmàna stavu ?
         mov       ds:[Presmyk],al          ; uschov†n° novÇho stavu
         stc                                ; p©°znak, ëe nen° zmàna stavu
         je        InpPres8                 ; nen° zmàna stavu
         push      cs
         call      near ptr DarkNul         ; nulov†n° ztmaven° displeje
         clc                                ; p©°znak zmàny stavu
InpPres8:ret

InpPresm ENDP

; *****************************************************************************
;                             InitMous
;                inicializace obsluhy my®i (my® je vypnuta)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

RIniMous label     FAR                      ; reinicializace

         push      cs
         call      near ptr MouseOff        ; vypnut° kurzoru my®i
         call      MousRGr                  ; navr†cen° definice fontñ my®i

InitMous PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ pro okno WINDOWS je standardn° obsluha my®i

         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknà WINDOWS ?
         jz        InitMo01                 ; nen° m¢d v oknà WINDOWS
         or        byte ptr ds:[ParMous2],bit2 ; standardn° obsluha my®i

; ------ p©°prava p©°znaku grafickÇho m¢du my®i

InitMo01:and       byte ptr ds:[ParMous2],not bit0 ; nen° grafickò m¢d my®i
         test      byte ptr ds:[ParMouse],bit3 ; je grafickò m¢d my®i ?
         jz        InitMo03                 ; nen° grafickò m¢d my®i
         cmp       byte ptr ds:[EgaVga],0   ; je displej EGA/VGA ?
         je        InitMo03                 ; nen° displej EGA/VGA
         test      byte ptr ds:[ParMous2],bit1+bit3+bit4+bit5 ; je z†kaz grafickÇ my®i ?
         jnz       InitMo03                 ; je z†kaz grafickÇ my®i
         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknà WINDOWS ?
         jnz       InitMo03                 ; je m¢d v oknà WINDOWS
         test      byte ptr ds:[ParMous2],bit2 ; standardn° obsluha my®i ?
         jnz       InitMo03                 ; je standardn° obsluha my®i
         or        byte ptr ds:[ParMous2],bit0 ; je grafick† my®

; ------ kontrola, zda lze my® testovat

InitMo03:test      byte ptr ds:[ParMouse],bit1 ; byla jië instalace my®i ?
         jnz       IniMous1                 ; byla jië instalace my®i
         and       byte ptr ds:[ParMouse],not bit2 ; zru®en° p©°znaku my®i
         mov       byte ptr ds:[MouseKey],0 ; zru®en° tlaá°tek my®i
         test      byte ptr ds:[ParMouse],bit0   ; je my® povolena ?
         jnz       InMous99                 ; pouëit° my®i je zak†z†no
         test      byte ptr ds:[MonoMod],bit4 ; je vòstup v ANSI m¢du ?
         jnz       InMous99                 ; pouëit° my®i pro ANSI zak†z†no
         mov       ax,3533h
         int       21h                      ; poskytnut° adresy INT 33h
         mov       ax,es
         cmp       ax,60h                   ; je segment OK ?
         jb        InMous99                 ; my® asi nen°
         cmp       bx,0ffe0h
         jae       InMous99                 ; my® asi nen°

; ------ test instalace my®i

         mov       al,0
         call      Int33
         inc       ax                       ; je my® nainstalovan† ?
         jz        IniMous0                 ; my® je nainstalov†na OK
InMous99:jmp       IniMous9                 ; my® nen° nainstalovan†

IniMous0:or        byte ptr ds:[ParMouse],bit2 ; p©°znak nainstalov†n° my®i

; ------ definice vertik†ln°ch rozmàrñ okna

IniMous1:test      byte ptr ds:[ParMouse],bit2 ; je my® nainstalov†na ?
         jz        InMous99                 ; my® nen° nainstalov†na
         xor       cx,cx                    ; minim†ln° ©†dek
         mov       dh,0
         mov       dl,ds:[MaxRow]           ; maxim†ln° ©†dek okna
         shl       dx,1
         shl       dx,1
         shl       dx,1                     ; ©†dek * 8

         test      byte ptr ds:[ParMous2],bit0 ; je grafickò m¢d my®i ?
         jz        IniMou21                 ; nen° grafickò m¢d my®i
         add       dx,6                     ; o trochu nav°c

IniMou21:mov       ds:[MouseYM],dx          ; maxim†ln° pozice Y
         mov       al,8
         call      Int33                    ; definice ©†dkñ okna

; ------ definice horizont†ln°ch rozmàrñ okna

         xor       cx,cx                    ; minim†ln° pozice
         mov       dh,0
         mov       dl,ds:[MaxPoz]           ; maxim†ln° pozice okna
         shl       dx,1
         shl       dx,1
         shl       dx,1                     ; pozice * 8

         test      byte ptr ds:[ParMous2],bit0 ; je grafickò m¢d my®i ?
         jz        IniMou22                 ; nen° grafickò m¢d my®i
         add       dx,6                     ; o trochu nav°c

IniMou22:and       byte ptr ds:[ParMouse],not bit4 ; p©evod sou©adnic X 8*
         cmp       byte ptr ds:[MaxPoz],60  ; je mÇnà neë 60 znakñ na ©†dek ?
         jae       IniMous2                 ; je v°ce neë 60 znakñ na ©†dek
         or        byte ptr ds:[ParMouse],bit4 ; p©°znak p©evodu sou©. X 16*
         shl       dx,1                     ; p©evod sou©adnic 16*

IniMous2:mov       ds:[MouseXM],dx          ; maxim†ln° pozice X
         mov       al,7
         call      Int33                    ; definov†n° pozic okna

; ------ nastaven° pozice kurzoru my®i

         mov       ch,0
         mov       cl,byte ptr ds:[MousePoz] ; uschovan† pozice kurzoru my®i
         cmp       cl,ds:[MaxPoz]
         jbe       IniMou23
         mov       cl,ds:[MaxPoz]           ; omezen° pozice kurzoru my®i
         mov       byte ptr ds:[MousePoz],cl; zkorigovan† pozice kurzoru
IniMou23:shl       cx,1
         shl       cx,1
         shl       cx,1                     ; pozice kurzoru graficky

         mov       dh,0
         mov       dl,byte ptr ds:[MousePoz+1] ; uschovanò ©†dek kurzoru my®i
         cmp       dl,ds:[MaxRow]
         jbe       IniMou24
         mov       dl,ds:[MaxRow]           ; omezen° ©†dku kurzoru my®i
         mov       byte ptr ds:[MousePoz+1],dl ; zkorigovanò ©†dek kurzoru
IniMou24:shl       dx,1
         shl       dx,1
         shl       dx,1                     ; ©†dek kurzoru graficky

         test      byte ptr ds:[ParMouse],bit4 ; je p©evod sou©adnic 16* ?
         jz        IniMous3                 ; je p©evod sou©adnic 8*
         shl       cx,1                     ; korekce sou©adnice X
IniMous3:mov       ds:[MouseX],cx           ; pozice kurzoru X
         mov       ds:[MouseY],dx           ; pozice kurzoru Y
         mov       al,4
         call      Int33                    ; nastaven° pozice kurzoru my®i

; ------ definice textovÇho kurzoru

         test      byte ptr ds:[ParMous2],bit2 ; standardn° obsluha my®i ?
         jz        IniMous9                 ; nen° standardn° obsluha my®i
         mov       al,10
         xor       bx,bx                    ; BX <- 0 softwarovò kurzor
         mov       cx,-1                    ; maska pro AND
         mov       dx,7700h                 ; maska pro XOR
         call      Int33                    ; definice textovÇho kurzoru

; ------ n†vrat registrñ

IniMous9:or        byte ptr ds:[ParMouse],bit1 ; p©°znak proveden° instalace
         mov       byte ptr ds:[MouseLev],1 ; my® vypnuta
         push      cs
         call      near ptr MouseOn         ; zapnut° kurzoru my®i
         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         push      cs
         call      near ptr MouseInt        ; naáten° stavu my®i
         and       byte ptr ds:[MouseKey],bit0+bit1+bit2 ; zru®en° stiskñ tlaá°tek
         and       byte ptr ds:[ParMouse],not bit7 ; nebyl stisk tlaá°tka
         sti
         ret

InitMous ENDP

; *****************************************************************************
;                             MouseOn
;                      zapnut° kurzoru my®i
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

MouseOn  PROC      FAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

         test      byte ptr ds:[ParMouse],bit2 ; je my® nainstalov†na ?
         jz        MouseOn5                 ; my® nen° nainstalov†na
         dec       byte ptr ds:[MouseLev]   ; sn°ëen° £rovnà vypnut°
         jnz       MouseOn5                 ; nen° je®tà zapnut° my®i

         test      byte ptr ds:[ParMous2],bit2 ; standardn° obsluha my®i ?
         jz        MouseOn2                 ; nen° standardn° obsluha my®i

         mov       al,1
         call      Int33                    ; zapnut° kurzoru my®i
         jmp       short MouseOn5

MouseOn2:mov       bx,ds:[MousePoz]         ; pozice kurzoru na displeji
         mov       cx,bx                    ; £schova pozice kurzoru
         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         mul       bh                       ; p©epoáet ©†dku na offset
         mov       bh,0
         add       ax,bx                    ; p©iáten° pozice
         shl       ax,1                     ; offset
         les       bx,ds:[AdrVRAM]          ; adresa videopamàti
         add       bx,ax                    ; adresa ve videopamàti

         mov       ax,es:[bx]               ; pñvodn° znak
         mov       ds:[MouseChr],ax         ; £schova pñvodn°ho znaku

         test      byte ptr ds:[ParMous2],bit0 ; je grafickò m¢d my®i ?
         jnz       MouseOn6                 ; je grafickò m¢d my®i

MouseOn4:xor       byte ptr es:[bx+1],77h   ; oznaáen° textovÇho kurzoru
MouseOn5:jmp       short MouseOn8

MouseOn6:mov       ax,es:[bx+2]             ; 2. znak
         mov       ds:[MouseChr+2],ax       ; 2. znak
         xchg      ax,dx                    ; £schova 2. znaku
         push      bx
         add       bx,ds:[ByteRow]          ; adresa dal®°ho ©†dku
         mov       ax,es:[bx]               ; 3. znak
         mov       ds:[MouseChr+4],ax       ; 3. znak
         mov       ax,es:[bx+2]             ; 4. znak
         mov       ds:[MouseChr+6],ax       ; 4. znak
         pop       bx
         mov       dh,al                    ; £schova 4. znaku

         call      MouseGr                  ; definice grafickÇho kurzoru my®i

         mov       al,ds:[MouseKCh]         ; 1. znak kurzoru
         mov       es:[bx],al

         cmp       cl,ds:[MaxPoz]           ; je posledn° pozice na ©†dku ?
         jae       MouseOn7                 ; je posledn° pozice na ©†dku

         mov       al,ds:[MouseKCh+4]       ; 2. znak kurzoru - textovò
         cmp       dl,0c0h
         jb        MousOn62                 ; je textovò znak
         cmp       dl,0e0h
         jae       MousOn62                 ; je textovò znak
         mov       al,ds:[MouseKCh+1]       ; 2. znak kurzoru - grafickò
MousOn62:mov       es:[bx+2],al

MouseOn7:cmp       ch,ds:[MaxRow]           ; je posledn° ©†dek ?
         jae       MouseOn8                 ; je posledn° ©†dek

         add       bx,ds:[ByteRow]          ; adresa dal®°ho ©†dku
         mov       al,ds:[MouseKCh+2]       ; 3. znak kurzoru
         mov       es:[bx],al

         cmp       cl,ds:[MaxPoz]           ; je posledn° pozice na ©†dku ?
         jae       MouseOn8                 ; je posledn° pozice na ©†dku

         mov       al,ds:[MouseKCh+5]       ; 4. znak kurzoru - textovò
         cmp       dh,0c0h
         jb        MousOn72                 ; je textovò znak
         cmp       dh,0e0h
         jae       MousOn72                 ; je textovò znak
         mov       al,ds:[MouseKCh+3]       ; 4. znak kurzoru - grafickò
MousOn72:mov       es:[bx+2],al

MouseOn8:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax

MouseOn9:ret

MouseOn  ENDP

; *****************************************************************************
;                             MouseOff
;                      vypnut° kurzoru my®i
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

MouseOff PROC      FAR

         test      byte ptr ds:[ParMouse],bit2 ; je my® nainstalov†na ?
         jz        MouseOf9                 ; my® nen° nainstalov†na

         inc       byte ptr ds:[MouseLev]   ; zvò®en° ukazatele £rovnà vypnut°
         cmp       byte ptr ds:[MouseLev],1 ; byl kurzor my®i zapnut ?
         jne       MouseOf9                 ; kurzor my®i nebyl zapnut

         push      ax
         push      bx
         push      cx
         push      es

         test      byte ptr ds:[ParMous2],bit2 ; standardn° obsluha my®i ?
         jz        MouseOf2                 ; nen° standardn° obsluha my®i

         mov       al,2
         push      dx
         call      Int33                    ; vypnut° kurzoru my®i
         pop       dx
         jmp       short MouseOf8

MouseOf2:mov       bx,ds:[MousePoz]         ; pozice kurzoru na displeji
         mov       cx,bx                    ; £schova pozice kurzoru
         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         mul       bh                       ; p©epoáet ©†dku na offset
         mov       bh,0
         add       ax,bx                    ; p©iáten° pozice
         shl       ax,1                     ; p©evod na offset
         les       bx,ds:[AdrVRAM]          ; adresa videopamàti
         add       bx,ax                    ; adresa ve videopamàti

         mov       ax,ds:[MouseChr]         ; uschovanò znak pod kurzorem
         mov       es:[bx],ax               ; n†vrat pñvodn°ho znaku

         test      byte ptr ds:[ParMous2],bit0 ; je grafickò m¢d my®i ?
         jz        MouseOf8                 ; nen° grafickò m¢d my®i

         cmp       cl,ds:[MaxPoz]           ; je posledn° pozice na ©†dku ?
         jae       MouseOf4                 ; je posledn° pozice na ©†dku

         mov       ax,ds:[MouseChr+2]       ; 2. znak
         mov       es:[bx+2],ax             ; 2. znak

MouseOf4:cmp       ch,ds:[MaxRow]           ; je posledn° ©†dek ?
         jae       MouseOf8                 ; je posledn° ©†dek

         add       bx,ds:[ByteRow]          ; adresa dal®°ho ©†dku
         mov       ax,ds:[MouseChr+4]       ; 3. znak
         mov       es:[bx],ax               ; 3. znak

         cmp       cl,ds:[MaxPoz]           ; je posledn° pozice na ©†dku ?
         jae       MouseOf8                 ; je posledn° pozice na ©†dku

         mov       ax,ds:[MouseChr+6]       ; 4. znak
         mov       es:[bx+2],ax             ; 4. znak

MouseOf8:pop       es
         pop       cx
         pop       bx
         pop       ax

MouseOf9:ret

MouseOff ENDP

; -----------------------------------------------------------------------------
;        navr†cen° definice fontñ kurzoru my®i
; -----------------------------------------------------------------------------

MousRGr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ test, zda se fonty maj° vracet

         test      byte ptr ds:[ParMous2],bit0 ; je grafickò m¢d my®i ?
         jz        MousRGr9                 ; nen° grafickò m¢d my®i
         test      byte ptr ds:[ParDisp],bit3 ; jsou uschovanÇ fonty ?
         jz        MousRGr9                 ; nejsou uschovanÇ fonty
         test      byte ptr ds:[ParDisp3],bit2 ; jsou nadefinov†ny znaky my®i ?
         jz        MousRGr9                 ; nejsou znaky my®i

; ------ adresa bufferu fontñ

         mov       ax,ds:[FontSegm]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        MousRGr9                 ; nàjak† chyba

; ------ p©edefinov†n° znakñ

         mov       di,offset MouseKCh       ; znaky kurzoru my®i
         mov       cx,6                     ; poáet znakñ k navr†cen°
MousRGr2:mov       al,ds:[di]               ; znak k p©edefinov†n°
         inc       di                       ; zvò®en° ukazatele znakñ
         push      ax
         sub       al,128
         mov       ah,32
         mul       ah
         xchg      ax,si                    ; SI <- adresa znaky
         pop       ax
         call      far ptr SetFont          ; navr†cen° definice znaku
         loop      MousRGr2                 ; dal®° znak
         and       byte ptr ds:[ParDisp3],not bit2 ; nejsou znaky my®i

; ------ n†vrat registrñ

MousRGr9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

MousRGr  ENDP

; -----------------------------------------------------------------------------
;        definice grafickÇho kurzoru my®i
; -----------------------------------------------------------------------------

MouseGr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,4 * 32                ; buffer pro 4 znaky

; ------ naáten° definice pñvodn°ch znakñ

         push      ss
         pop       es
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       al,byte ptr ds:[MouseChr] ; uschovanò znak 1
         call      far ptr GetFont          ; naáten° definice fontu znaku 1
         mov       al,byte ptr ds:[MouseChr+2] ; uschovanò znak 2
         call      far ptr GetFont          ; naáten° definice fontu znaku 2
         mov       al,byte ptr ds:[MouseChr+4] ; uschovanò znak 3
         call      far ptr GetFont          ; naáten° definice fontu znaku 3
         mov       al,byte ptr ds:[MouseChr+6] ; uschovanò znak 4
         call      far ptr GetFont          ; naáten° definice fontu znaku 4

; ------ ukl†dac° adresa do bufferu (z linky kurzoru) -> DI

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       al,byte ptr ds:[MouseY]  ; pozice kurzoru vertik†lnà
         and       al,7
         mul       byte ptr ds:[LineFont]   ; offset Y * vò®ka znaku
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; /8 = vertik†ln° offset kurzoru
         mov       bh,ds:[LineFont]         ; poáet linek na font
         sub       bh,al                    ; zbylò poáet linek znaku
         add       di,ax                    ; adresa v bufferu

; ------ obr†zek kurzoru my®i -> SI, linek BL

         mov       bl,14                    ; poáet linek kurzoru
         mov       si,offset MouseSip       ; definice kurzoru - ®ipka
         test      byte ptr ds:[ParMouse],bit6 ; je obr†zek my®i ?
         jz        MousGr21                 ; nen° obr†zek my®i
         mov       si,offset MouseMou       ; definice kurzoru - my®ka
MousGr21:cmp       byte ptr ds:[LineFont],12
         ja        MousGr22                 ; je 13 a v°ce linek
         mov       bl,12
         add       si,2*14                  ; definice kurzoru pro 12 linek
MousGr22:cmp       bl,ds:[LineFont]
         jb        MousGr23
         mov       bl,ds:[LineFont]         ; omezen° poátu linek kurzoru

; ------ poáet rotac° obr†zku (z pozice X) -> CL

MousGr23:mov       ax,ds:[MouseX]           ; pozice kurzoru X
         test      byte ptr ds:[ParMouse],bit4 ; je p©evod sou©adnic 16* ?
         jz        MousGr24                 ; je p©evod sou©adnic 8*
         shr       ax,1                     ; korekce / 2
MousGr24:mov       cl,7
         sub       cl,al                    ; pozice kurzoru horizont†lnà
         and       cl,7
         inc       cx                       ; poáet rotac° obr†zku

; ------ z†pis obr†zku kurzoru

MouseGr3:mov       ah,es:[di]               ; bajt levÇho znaku
         mov       al,es:[di+32]            ; bajt pravÇho znaku

         mov       dh,0ffh                  ; maska HIGH
         mov       dl,ds:[si+14]            ; maska kurzoru
         rol       dx,cl                    ; rotace masky na pozici
         and       ax,dx                    ; maskov†n° znaku

         mov       dh,0                     ; obr†zek HIGH
         mov       dl,ds:[si]               ; znak kurzoru
         shl       dx,cl                    ; rotace bajtu na pozici
         or        ax,dx                    ; p©id†n° znaku kurzoru

         mov       es:[di],ah               ; uloëen° definice levÇho bajtu
         mov       es:[di+32],al            ; uloëen° definice pravÇho bajtu

         inc       di                       ; zvò®en° ukl†dac° adresy
         inc       si                       ; zvò®en° adresy definice znaku
         dec       bh                       ; á°taá zmàny ukl†dac° adresy
         jnz       MouseGr4                 ; nen° je®tà zmàna adresy

         mov       di,sp                    ; DI <- buffer definice znakñ
         add       di,64                    ; spodn° znaky

MouseGr4:dec       bl                       ; á°taá linek k zobrazen°
         jnz       MouseGr3                 ; zobrazen° dal®° linky kurzoru

; ------ nastaven° novÇ definice znakñ

         mov       si,sp                    ; SI <- buffer definice znakñ
         mov       al,ds:[MouseKCh]         ; znak kurzoru my®i 1
         call      far ptr SetFont          ; nastaven° definice fontu znaku 1

         push      si
         mov       al,ds:[MouseKCh+1]       ; znak kurzoru my®i 2 - grafickò
         call      far ptr SetFont          ; nastaven° definice fontu znaku 2
         pop       si
         mov       al,ds:[MouseKCh+4]       ; znak kurzoru my®i 2 - textovò
         call      far ptr SetFont          ; nastaven° definice fontu znaku 2

         mov       al,ds:[MouseKCh+2]       ; znak kurzoru my®i 3
         call      far ptr SetFont          ; nastaven° definice fontu znaku 3

         push      si
         mov       al,ds:[MouseKCh+3]       ; znak kurzoru my®i 4 - grafickò
         call      far ptr SetFont          ; nastaven° definice fontu znaku 4
         pop       si
         mov       al,ds:[MouseKCh+5]       ; znak kurzoru my®i 4 - textovò
         call      far ptr SetFont          ; nastaven° definice fontu znaku 4
         or        byte ptr ds:[ParDisp3],bit2 ; nadefinov†ny znaky my®i

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MouseGr  ENDP

; *****************************************************************************
;                               MouseGet
;                       test, zda je zmàna my®i
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° ë†dn† zmàna my®i
;         BX=identifik†tor stavu (MousXKod + p©°znaky)
;              levÇ + pravÇ tlaá°tko = st©edn°
;    MousXKod + bit 0: 1=je levÇ tlaá°tko
;               bit 1: 1=je pravÇ tlaá°tko
;               bit 2: 1=levÇ tlaá°tko stisk
;               bit 3: 1=pravÇ tlaá°tko stisk
;               bit 4: 1=levÇ tlaá°tko uvolnàn°
;               bit 5: 1=pravÇ tlaá°tko uvolnàn°
;               bit 6: 1=je 2. stisk tlaá°tka
;               bit 7: 1=byl posun my®i s drëen°m tlaá°tka (taëen°)
;                 Je-li posun my®i, nejsou tlaá°tka sn°m†na (ponech†v† se starò stav !)
; pouze drëen† tlaá°tka - rolov†n° kurzoru
; *****************************************************************************

MouseGet PROC      FAR

         xchg      ax,bx                    ; BX <- £schova AX

; ------ stav my®i

         mov       al,ds:[MouseKey]         ; stav tlaá°tek my®i

; ------ test, zda je zmàna tlaá°tek

         test      al,bit2+bit3+bit4+bit5   ; je zmàna tlaá°tek ?
         jnz       MousGet9                 ; byla nàjak† zmàna tlaá°tek

; ------ test, zda se drë° tlaá°tka

         test      al,bit0+bit1             ; drë° se nàkterÇ tlaá°tko ?
         jz        MousGet8                 ; nedrë° se ë†dnÇ tlaá°tko

; ------ posun my®i s taëen°m

         test      al,bit7                  ; je posun my®i ?
         mov       al,bit7                  ; n†hradn° k¢d
         jnz       MousGet9                 ; je posun my®i

; ------ test, zda je áas pro rolov†n°

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; aktu†ln° stav hodin
         pop       ds
         sub       ax,ds:[MousRTim]         ; uplynulò áas
         js        MousGet7                 ; nen° je®tà poëadovanò áas

; ------ rolov†n° kurzoru

         inc       ax                       ; p©°®t° impuls
         add       ds:[MousRTim],ax         ; áas p©°®t°ho impulsu
         mov       al,ds:[MouseKey]         ; tlaá°tka my®i
         and       al,bit0+bit1             ; stav drëen° tlaá°tek
         jmp       short MousGet9

; ------ nen° ë†dn† zmàna

MousGet7:mov       al,ds:[MouseKey]         ; tlaá°tka my®i
MousGet8:and       al,bit0+bit1             ; pouze p©°znak stisku tlaá°tek
         stc                                ; p©°znak - nen° ë†dn† zmàna
MousGet9:mov       ah,MousXKod / HI         ; identifik†tor my®i HIGH
         xchg      ax,bx                    ; BX <- stav my®i
         ret

MouseGet ENDP

; *****************************************************************************
;                                MouseTst
;                  test, zda je stisk nàkterÇho tlaá°tka v oknà
; -----------------------------------------------------------------------------
; VSTUP: DL=poá†teán° pozice okna
;        DH=poá†teán° ©†dek okna
;        CL=®°©ka okna
;        CH=vò®ka okna
;        DS=datovò segment
; VùSTUP: CY=nen° stisk tlaá°tka my®i v oknà
;         AL=stav tlaá°tek my®i
;              levÇ + pravÇ tlaá°tko = st©edn°
;               bit 0: 1=je levÇ tlaá°tko
;               bit 1: 1=je pravÇ tlaá°tko
;               bit 2: 1=levÇ tlaá°tko stisk
;               bit 3: 1=pravÇ tlaá°tko stisk
;               bit 4: 1=levÇ tlaá°tko uvolnàn°
;               bit 5: 1=pravÇ tlaá°tko uvolnàn°
;               bit 6: 1=je 2. stisk tlaá°tka
;               bit 7: 1=byl posun my®i
;                 Je-li posun my®i, nejsou
;                 tlaá°tka sn°m†na (ponech†v†
;                 se starò stav !)
; *****************************************************************************

MouseTst PROC      FAR

; ------ test, zda je kurzor my®i v oknà

         mov       al,ds:[MouseKey]         ; stav tlaá°tek my®i
         call      far ptr MouseWin         ; test, zda je my® v oknà
         jc        MousTst9                 ; my® nen° v oknà

; ------ test, zda je stisknuto nàkterÇ tlaá°tko

         test      al,bit2+bit3             ; je stisk tlaá°tka ?
         jnz       MousTst9                 ; je stisk tlaá°tka
         stc                                ; p©°znak, ëe nen° stisk tlaá°tka
MousTst9:ret

MouseTst ENDP

; *****************************************************************************
;                              MouseMnu
;                   test, zda je kurzor my®i v oknà menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; VùSTUP: CY=kurzor my®i nen° v oknà menu
; *****************************************************************************

MouseMnu PROC      FAR

         push      dx
         push      cx

         mov       cx,word ptr ds:[si+MnuSir]
         mov       dx,word ptr ds:[si+MnuPoz]
         call      far ptr MouseWin

         pop       cx
         pop       dx
         ret

MouseMnu ENDP

; *****************************************************************************
;                                 MouseWin
;                      test, zda je kurzor my®i v oknà
; -----------------------------------------------------------------------------
; VSTUP: DL=poá†teán° pozice okna
;        DH=poá†teán° ©†dek okna
;        CL=®°©ka okna
;        CH=vò®ka okna
;        DS=datovò segment
; VùSTUP: CY=kurzor my®i nen° v testovanÇm oknà
; *****************************************************************************

MouseWin PROC      FAR

; ------ £schova registrñ

         push      dx

; ------ kontrola poá†teán° pozice

         cmp       dl,byte ptr ds:[MousePoz]
         ja        MouseWn8

; ------ kontrola koncovÇ pozice

         add       dl,cl
         cmp       dl,byte ptr ds:[MousePoz]
         jbe       MouseWn8

; ------ kontrola poá†teán°ho ©†dku

         cmp       dh,byte ptr ds:[MousePoz+1]
         ja        MouseWn8

; ------ kontrola koncovÇho ©†dku

         add       dh,ch
         cmp       dh,byte ptr ds:[MousePoz+1]
         ja        MouseWn9                 ; je OK

; ------ nen° v oknà

MouseWn8:stc                                ; p©°znak, ëe nen° v oknà

; ------ n†vrat registrñ

MouseWn9:pop       dx
         ret

MouseWin ENDP

; *****************************************************************************
;                                 MousBrea
;                 test p©eru®en° operace my®° (pravòm tlaá°tkem)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=je p©eru®en° operace my®°
; *****************************************************************************

MousBrea PROC      FAR

         call      far ptr MouseInt         ; obsluha p©eru®en° od my®i
         call      far ptr TestBEsc         ; test p©eru®en° operace
         jc        MousBre9                 ; je jië p©eru®en° operace
         test      byte ptr ds:[MouseKey],bit3 ; je stisk pravÇho tlaá°tka ?
         jz        MousBre9                 ; nen° stisk pravÇho tlaá°tka
         call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en° ESC
MousBre9:ret

MousBrea ENDP

; *****************************************************************************
;                              MouseInt
;                      obsluha p©eru®en° od my®i
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

MouseInt PROC      FAR

; ------ test, zda je my®

         test      byte ptr ds:[ParMouse],bit2 ; je my® nainstalov†na ?
         jnz       MouseIn2                 ; my® je nainstalov†na
MouseIn1:ret

; ------ £schova registrñ

MouseIn2:push      ax
         push      bx
         push      cx
         push      dx

; ------ p©°prava p©°znaku pohybu my®i

         and       byte ptr ds:[MouseKey],bit0+bit1 ; p©°znaky kl†ves
         or        byte ptr ds:[MouseKey],bit7 ; p©°znak pohybu my®i

; ------ standardn° obsluha my®i (okno WINDOWS)

         test      byte ptr ds:[ParMous2],bit2 ; standardn° obsluha my®i ?
         jz        MousIn28                 ; nen° standardn° obsluha my®i

         mov       al,3
         call      Int33                    ; naáten° pozice my®i
         cmp       cx,ds:[MouseX]           ; zmàna pozice ?
         jne       MousIn22                 ; je zmàna pozice
         cmp       dx,ds:[MouseY]           ; zmàna ©†dku ?
         je        MousIn29                 ; nen° zmàna my®i

MousIn22:mov       ds:[MouseX],cx           ; pozice
         mov       ds:[MouseY],dx           ; ©†dek
         xchg      ax,dx                    ; AX <- ©†dek
         jmp       short MousIn36

; ------ áten° pohybu my®i od posledn°ho vol†n°

MousIn28:xor       cx,cx                    ; p©ednastaven°
         xor       dx,dx
         mov       al,0bh
         call      Int33                    ; test pohybu my®i

; ------ test, zda byla my® posunuta

         or        dx,dx                    ; byl vertik†ln° pohyb ?
         jnz       MouseIn3                 ; byl vertik†ln° pohyb
         or        cx,cx
         jnz       MouseIn3                 ; byl horizont†ln° pohyb
MousIn29:jmp       MousIn98                 ; nebyl posun my®i

; ------ nov† pozice my®i X

MouseIn3:mov       ax,ds:[MouseX]           ; pozice my®i X
         add       ax,cx                    ; p©iáten° posunu X
         jns       MousIn31                 ; nen° podteáen°
         xor       ax,ax                    ; omezen° p©i podteáen°
MousIn31:cmp       ax,ds:[MouseXM]          ; je p©eteáen° ?
         jbe       MousIn32                 ; nen° p©eteáen°
         mov       ax,ds:[MouseXM]          ; omezen° p©i p©eteáen°
MousIn32:mov       ds:[MouseX],ax           ; nov† pozice kurzoru my®i X
         xchg      ax,cx                    ; CX <- nov† pozice kurzoru X

; ------ novò ©†dek my®i Y

         mov       ax,ds:[MouseY]           ; pozice my®i Y
         add       ax,dx                    ; p©iáten° posunu Y
         jns       MousIn34                 ; nen° podteáen°
         xor       ax,ax                    ; omezen° p©i podteáen°
MousIn34:cmp       ax,ds:[MouseYM]          ; je p©eteáen° ?
         jbe       MousIn35                 ; nen° p©eteáen°
         mov       ax,ds:[MouseYM]          ; omezen° p©i p©eteáen°
MousIn35:mov       ds:[MouseY],ax           ; nov† pozice kurzoru my®i Y

; ------ vòpoáet ©†dku a pozice kurzoru my®i na obrazovce -> AX

MousIn36:test      byte ptr ds:[ParMouse],bit4 ; je p©evod sou©adnic X 16* ?
         jz        MousIn37                 ; ne - je p©evod 8*
         shr       cx,1                     ; korekce pozice / 2

MousIn37:shr       ax,1
         shr       ax,1
         shr       ax,1                     ; ©†dek / 8
         mov       ah,al                    ; ©†dek kurzoru

         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; pozice / 8
         mov       al,cl                    ; pozice kurzoru

; ------ rozsv°cen° obrazovky, je-li ztmavena

         mov       bx,ds:[MousePoz]         ; star† pozice my®i
         test      byte ptr ds:[ParMouse],bit5 ; je ztmaven° pravòm rohem ?
         jz        MouseIn5                 ; nen° ztmaven° pravòm rohem
         cmp       ax,bx                    ; zmànàna pozice ?
         je        MouseIn6                 ; pozice nezmànàna
         cmp       al,ds:[MaxPoz]
         jae       MouseIn6                 ; je pravò okraj - nic se nedàje
MouseIn5:call      far ptr DarkNul          ; nulov†n° ztmaven° displeje

; ------ p©i vypnutÇm kurzoru jen uloëen° novòch sou©adnic

MouseIn6:cmp       byte ptr ds:[MouseLev],0 ; je kurzor my®i zapnut ?
         je        MouseIn7                 ; kurzor my®i je zapnut
         mov       ds:[MousePoz],ax         ; uloëen° novòch sou©adnic
         jmp       short MouseIn8

; ------ novÇ zobrazen° kurzoru

MouseIn7:call      far ptr MouseOff         ; vypnut° kurzoru my®i
         mov       ds:[MousePoz],ax         ; uloëen° novòch sou©adnic
         call      far ptr MouseOn          ; zapnut° kurzoru na novÇ pozici

; ------ nastaven° pozice kurzoru my®i na novòch sou©adnic°ch

MouseIn8:test      byte ptr ds:[ParMous2],bit2 ; standardn° obsluha my®i ?
         jnz       MousIn82                 ; je standardn° obsluha my®i

         mov       al,4
         mov       cx,ds:[MouseX]
         mov       dx,ds:[MouseY]
         push      bx
         call      Int33                    ; nastaven° pozice kurzoru my®i
         pop       bx

; ------ ztmaven° displeje, je-li v pravÇm horn°m rohu

MousIn82:mov       ax,ds:[MousePoz]         ; pozice kurzoru my®i
         inc       ax                       ; 1 pozice rezerva
         cmp       al,ds:[MaxPoz]           ; je pravò okraj ?
         jb        MousIn94                 ; nen° pravò okraj
         or        ah,ah                    ; je horn° ©†dek ?
         jnz       MousIn94                 ; nen° horn° ©†dek

         test      byte ptr ds:[ParMouse],bit5 ; bylo jië setmàn° pravòm rohem ?
         jnz       MousIn96                 ; bylo jië setmàn°

         call      far ptr GetCTime         ; naáten° systÇmovÇho áasovaáe
         sub       ax,ds:[DarkTime]         ; fiktivn° poá†tek
         sbb       dx,0
         jnc       MousIn84
         add       ax,0b0h
         adc       dx,18h                   ; korekce
MousIn84:mov       word ptr ds:[DarkBeg],ax ; okamëitÇ ztmaven° displeje
         mov       word ptr ds:[DarkBeg+2],dx
         or        byte ptr ds:[ParMouse],bit5 ; bylo jië setmàn° pravòm rohem
         jmp       short MousIn96

MousIn94:and       byte ptr ds:[ParMouse],not bit5 ; nebylo setmàn° pravòm rohem

; ------ my® nebyla posunuta - obsluha tlaá°tek my®i

MousIn96:cmp       bx,ds:[MousePoz]         ; byla pozice zmànàna ?
         jne       MouseIn9                 ; byla zmànàna
MousIn98:call      MousIntK                 ; obsluha tlaá°tek my®i

; ------ n†vrat registrñ

MouseIn9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MouseInt ENDP

; -----------------------------------------------------------------------------
;        obsluha tlaá°tek my®i (niá° registry AX, BX, CX a DX)
; -----------------------------------------------------------------------------

MousIntK PROC      NEAR

; ------ test, zda mñëe bòt druhò stisk tlaá°tka my®i

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; aktu†ln° stav hodin
         pop       ds
         test      byte ptr ds:[ParMouse],bit7 ; byl 1. stisk tlaá°tka ?
         jz        MousInK2                 ; nebyl 1. stisk tlaá°tka
         mov       bx,ax                    ; BX <- aktu†ln° stav hodin
         sub       bx,ds:[MouseTim]         ; áas od posledn°ho stisku tlaá°tka
         cmp       bx,6                     ; asi tak 1/3 sekundy
         jbe       MousInK3                 ; je®tà mñëe bòt druhò stisk
         and       byte ptr ds:[ParMouse],not bit7 ; je jië pozdà na 2. stisk
MousInK2:mov       ds:[MouseTim],ax         ; áas posledn°ho stisku tlaá°tka

; ------ naáten° tlaá°tek my®i

MousInK3:mov       al,3
         call      Int33                    ; naáten° tlaá°tek my®i
         xchg      ax,bx                    ; AL <- stav tlaá°tek my®i

; ------ korekce st©edn°ho tlaá°tka

         test      al,bit2                  ; je st©edn° tlaá°tko ?
         jz        MousInK4                 ; nen° st©edn° tlaá°tko
         mov       al,bit0+bit1             ; fiktivn° st©edn° tlaá°tko

; ------ z†màna tlaá°tek my®i

MousInK4:test      byte ptr ds:[ParMous2],bit7 ; je z†màna tlaá°tek ?
         jz        MousIK40                 ; nen° z†màna tlaá°tek
         mov       ah,al
         shr       ah,1
         shl       al,1
         or        al,ah

; ------ starò a novò stav tlaá°tek

MousIK40:and       al,bit0+bit1             ; pouze platn† tlaá°tka
         mov       ah,al                    ; AH <- £schova novòch tlaá°tek
         mov       al,ds:[MouseKey]         ; AL <- starò stav tlaá°tek
         and       al,bit0+bit1             ; stisknut† tlaá°tka

; ------ korekce p©i uvolnàn° st©edn°ho tlaá°tka

         cmp       al,bit0+bit1             ; bylo st©edn° tlaá°tko ?
         jne       MousIK41                 ; nebylo st©edn° tlaá°tko
         cmp       ah,0                     ; je teÉ uvolnàn° ?
         je        MousIK41                 ; teÉ je uvolnàn° OK
         mov       ah,bit0+bit1             ; st†le je je®tà stisk

; ------ korekce p©i stisku st©edn°ho tlaá°tka

MousIK41:cmp       ah,bit0+bit1             ; je st©edn° tlaá°tko ?
         jne       MousIK42                 ; nen° stisk st©edn°ho tlaá°tka
         cmp       al,bit0+bit1             ; bylo st©edn° tlaá°tko ?
         je        MousIK42                 ; bylo st©edn° tlaá°tko
         mov       al,0                     ; jinak nebylo nic
         and       byte ptr ds:[ParMouse],not bit7 ; to nen° 2. stisk tlaá°tka

; ------ korekce, aby nebyla opaán† zmàna tlaá°tek

MousIK42:cmp       ax,bit0*HI + bit1        ; levÇ stisk, pravÇ uvolnàn°
         je        MousIK43                 ; chyba
         cmp       ax,bit1*HI + bit0        ; pravÇ stisk, levÇ uvolnàn°
         jne       MousIK44                 ; v®e je OK
MousIK43:mov       ah,0                     ; nen° je®tà nic stisknuto
MousIK44:mov       ds:[MouseKey],ah         ; uloëen° novÇho stavu tlaá°tek

; ------ p©°znak stisku tlaá°tek

         push      ax
         not       al                       ; pñvodnà nestisknut† tlaá°tka
         and       al,ah                    ; novà stisknut† tlaá°tka
         and       al,bit0+bit1             ; pouze pot©ebnÇ bity
         shl       al,1
         shl       al,1                     ; rotace na pozici
         or        ds:[MouseKey],al         ; novà stisknut† tlaá°tka
         pop       ax

; ------ p©°znak uvolnàn° tlaá°tek

         not       ah                       ; novà uvolnàn† tlaá°tka
         and       al,ah                    ; novà uvolnàn† tlaá°tka
         and       al,bit0+bit1             ; pouze pot©ebnÇ bity
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1                     ; rotace na pozici
         or        ds:[MouseKey],al         ; novà uvolnàn† tlaá°tka

; ------ test, zda byl 2. stisk tlaá°tek

         test      byte ptr ds:[MouseKey],bit2+bit3 ; bylo nàco stisknuto ?
         jz        MousInK6                 ; nebylo nic stisknuto

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; aktu†ln° stav hodin
         pop       ds
         add       ax,9                     ; £vodn° prodleva
         mov       ds:[MousRTim],ax         ; áas pro rolov†n° kurzoru

         test      byte ptr ds:[ParMouse],bit7 ; byl jië 1. stisk tlaá°tka ?
         jz        MousInK5                 ; nebyl je®tà 1. stisk tlaá°tka
         or        byte ptr ds:[MouseKey],bit6 ; p©°znak 2. stisku tlaá°tek
MousInK5:xor       byte ptr ds:[ParMouse],bit7 ; zmàna 1. stisku tlaá°tka
MousInK6:ret

MousIntK ENDP

; *****************************************************************************
;                                Int33
;                 vol†n° obsluhy INT 33h (obsluha my®i)
; -----------------------------------------------------------------------------
; *****************************************************************************

Int33    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es
         sti
         mov       ah,0
         int       33h
         sti
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Int33    ENDP

; -----------------------------------------------------------------------------
;        nulov†n° á°taáe stm°v†n° displeje (uchov†v† registr p©°znakñ !)
; -----------------------------------------------------------------------------

DarkNul  PROC      FAR

         pushf

; ------ rozsv°cen° displeje, pokud je ztmaven

         test      byte ptr ds:[DarkParm],bit1 ; je displej ztmaven ?
         jz        DarkNul1                 ; displej nen° ztmaven
         call      far ptr MouseOn          ; zapnut° kurzoru my®i
         and       byte ptr ds:[DarkParm],not bit1 ; displej nen° ztmaven
         call      far ptr DispAll          ; novÇ zobrazen° celÇ obrazovky

; ------ £schova á°taáe áasu

DarkNul1:push      ax
         push      dx

         call      far ptr GetCTime         ; naáten° systÇmovÇho áasu
         mov       word ptr ds:[DarkBeg],ax ; £schova áasu zaá†tku ztm°v†n°
         mov       word ptr ds:[DarkBeg+2],dx

         pop       dx
         pop       ax

         popf
         ret

DarkNul  ENDP

; -----------------------------------------------------------------------------
;        obsluha stm°v†n° displeje
; -----------------------------------------------------------------------------
;˛
Darker   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

         xor       ax,ax
         mov       es,ax                    ; ES <- 0

; ------ test, zda je funkce zapnuta

         test      byte ptr ds:[MonoMod],bit4 ; je vòstup v ANSI m¢du ?
         jnz       Darker0                  ; pro ANSI je stm°v†n° zak†z†no
         test      byte ptr ds:[ParInt24],bit3 ; je obsluha INT 24h ?
         jnz       Darker0                  ; pro INT 24h je stm°v†n° zak†z†no
         test      byte ptr ds:[DarkParm],bit0 ; je funkce zapnuta ?
         jz        Darker4                  ; funkce nen° zapnuta
         test      byte ptr ds:[ParZvl],bit1 ; jsou hodiny ?
Darker0: jnz       Darker4                  ; jsou hodiny - funkce vypnuta

; ------ test, zda je displej jië ztmaven

         test      byte ptr ds:[DarkParm],bit1 ; je displej jië ztmaven ?
         jnz       Darker5                  ; displej je jië ztmaven

; ------ test, zda je jië dosaëeno poëadovanÇ doby

         mov       ax,word ptr ds:[DarkBeg] ; áas poá†tku LOW
         mov       dx,word ptr ds:[DarkBeg+2] ; áas poá†tku HIGH
         call      far ptr GetCDelt         ; test uplynulÇho áasu
         cmp       ax,ds:[DarkTime]         ; je jië dosaëeno poëadovanÇ doby ?
         jb        Darker4                  ; nen° je®tà poëadovan† doba

; ------ test, zda je z†kaz stm°v†n° my®° (v levÇm horn°m rohu)

         cmp       word ptr ds:[MousePoz],1 ; je levò horn° roh ?
         jbe       Darker4                  ; nebude ztmaven° displeje

; ------ ztmaven° displeje extern°m stm°vaáem

         cmp       word ptr ds:[DarkExeN],0 ; je extern° stm°vaá definov†n ?
         je        Darker23                 ; extern° stm°vaá nen° definov†n
         test      byte ptr ds:[DarkParm],bit3 ; je moënÇ extern° stmaven° ?
         jz        Darker23                 ; nen° moënÇ extern° stmaven°
         test      byte ptr ds:[ParamL],bit3 ; seznam ?
         jnz       Darker23                 ; seznam - zak†z†no
         test      byte ptr ds:[ParamR],bit3 ; seznam ?
         jnz       Darker23                 ; seznam - zak†z†no
         or        byte ptr ds:[DarkParm],bit2 ; poëadavek extern°ho stm°vaáe
         push      cs
         call      near ptr DarkNul         ; nulov†n° á°taáe ztmavov†n°
         jmp       short Darker4

; ------ ztmaven° displeje

Darker23:call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr MouseOff         ; vypnut° kurzoru my®i
         or        byte ptr ds:[DarkParm],bit1 ; displej je ztmaven

         mov       al,ds:[Radku]
         mul       byte ptr ds:[Pozic]      ; poáet pozic na obrazovku
         xchg      ax,cx                    ; CX <- poáet znakñ
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       ax," " + 7*HI
         cld
         rep       stosw
Darker4: jmp       Darker9

; ------ á°t†n° doby pro proveden° kroku animace

Darker5: mov       ax,es:[46ch]             ; á°taá áasu
         sub       ax,word ptr ds:[DarkBeg] ; rozd°l áasu
         cmp       ax,2;3                     ; poëadovan† doba
         jb        Darker4                  ; mal† doba
         add       word ptr ds:[DarkBeg],ax ; £schova novÇ doby

; ------ p©°prava velikosti videopamàti

         mov       al,ds:[Radku]
         mul       byte ptr ds:[Pozic]      ; poáet pozic na obrazovku
         xchg      ax,cx                    ; CX <- poáet znakñ

; ------ p©°prava MONO korekce

         mov       byte ptr cs:[DarkMask],0 ; nen° MONO korekce
         cmp       byte ptr ds:[MonoMod],0
         je        Darker50
         mov       byte ptr cs:[DarkMask],7 ; je MONO korekce

; ------ vygenerov†n° novÇho znaku

Darker50:les       si,ds:[AdrVRAM]          ; adresa videopamàti
         mov       di,si
         mov       dx,3
Darker51:push      si
Darker52:call      far ptr Random           ; n†hodn† adresa
         mov       bh,ah
         and       ah,1fh
         cmp       ax,cx
         jae       Darker52
         shr       bh,1
         shr       bh,1
         shr       bh,1
         shr       bh,1
         shr       bh,1
         or        bh,cs:[DarkMask]
         shl       ax,1
         add       si,ax                    ; SI <- adresa novÇho znaku
         mov       ah,bh

         or        ah,8

         mov       al,ds:[DarkMap]
         mov       es:[si],ax
         pop       si
         dec       dx
         jnz       Darker51

; ------ vyhled†n° znaku k posunu

         cld
Darker53:jcxz      Darker9
         mov       ax," " + 7*HI
         repe      scasw
         je        Darker9                  ; jsou jië v®echny znaky

; ------ posun znaku

         mov       ax,es:[di-2]

         cmp       ah,8
;         je        Darker54

         jae       Darkr542
         mov       ah,8
         jmp       short Darker54
Darkr542:

         mov       ah,7
Darker54:mov       si,offset DarkMap-2
Darker55:cmp       byte ptr ds:[si+2]," "
         je        Darker56
         inc       si
         inc       si
         cmp       ax,ds:[si]
         jne       Darker55
Darker56:mov       ax,ds:[si+2]
         cmp       ah,8
;         je        Darker57
         je        Darker58
         cmp       al," "
         je        Darker57
         mov       ah,es:[di-1]

         or        ah,8

Darker57:mov       es:[di-2],ax
         jmp       short Darker53

Darker58:mov       ah,es:[di-1]
         and       ah,not 8
         jmp       short Darker57

; ------ n†vrat registrñ

Darker9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

Darker   ENDP

DarkMask db        0                        ; maska pro MONO (barva -> b°l†)

; -----------------------------------------------------------------------------
;        uplynul† doba od áasu DX:AX -> DX:AX
; -----------------------------------------------------------------------------

GetCDelt PROC      FAR

         push      bx
         push      cx

         xchg      ax,cx                    ; CX <- áas poá†tku LOW
         mov       bx,dx                    ; BX <- áas poá†tku HIGH

         call      far ptr GetCTime         ; naáten° aktu†ln°ho áasu -> DX:AX
         sub       ax,cx                    ; uplynulò áas LOW
         sbb       dx,bx                    ; uplynulò áas HIGH
         jnc       GetCDel2                 ; nen° p©eteáen° p©es pñlnoc

         add       ax,0b0h                  ; korekce p©es pñlnoc
         adc       dx,18h

GetCDel2:pop       cx
         pop       bx
         ret

GetCDelt ENDP

; -----------------------------------------------------------------------------
;        naáten° áasu systÇmovÇho áasovaáe 46Ch -> DX:AX
; -----------------------------------------------------------------------------

GetCTime PROC      FAR

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; systÇmovò áasovaá LOW
         mov       dx,ds:[46ch+2]           ; systÇmovò áasovaá HIGH
         pop       ds
         ret

GetCTime ENDP

CodeKey  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

MousRTim dw        0                        ; áas pro rolov†n° kurzoru

MouseTim dw        0                        ; áas posledn°ho stisku my®i
MouseKey db        0                        ; posledn° stav tlaá°tek my®i
                                            ;  levÇ + pravÇ tlaá°tko = st©edn°
                                            ;   bit 0: 1=je levÇ tlaá°tko
                                            ;   bit 1: 1=je pravÇ tlaá°tko
                                            ;   bit 2: 1=levÇ tlaá°tko stisk
                                            ;   bit 3: 1=pravÇ tlaá°tko stisk
                                            ;   bit 4: 1=levÇ tlaá°tko uvolnàn°
                                            ;   bit 5: 1=pravÇ tlaá°tko uvolnàn°
                                            ;   bit 6: 1=je 2. stisk tlaá°tka
                                            ;   bit 7: 1=byl posun my®i
                                            ;     Je-li posun my®i, nejsou
                                            ;     tlaá°tka sn°m†na (ponech†v†
                                            ;     se starò stav !)

MouseChr label     word                     ; uschovanò znak kurzoru my®i
         dw        4 dup(0)                 ; (buffer pro 4 znaky kurzoru)

MouseX   dw        0                        ; pozice kurzoru X
MouseXM  dw        0                        ; maxim†ln° pozice kurzoru X

MouseY   dw        0                        ; pozice kurzoru Y
MouseYM  dw        0                        ; maxim†ln° pozice kurzoru Y

MouseMou db        00000000b                ; znak kurzoru my®i (13-... linek)
         db        00100000b
         db        00110000b
         db        00111100b
         db        01111100b
         db        01111110b
         db        00111110b
         db        00111110b
         db        00011100b
         db        00000100b
         db        00000010b
         db        00110010b
         db        01001100b
         db        00000000b

         db        10011111b                ; maska kurzoru my®i (13-... linek)
         db        10101111b
         db        10110011b
         db        10111101b
         db        01111101b
         db        01111110b
         db        10111110b
         db        10111110b
         db        11011101b
         db        11100101b
         db        11001010b
         db        10110010b
         db        01001101b
         db        10110011b

         db        00100000b                ; znak kurzoru my®i (...-12 linek)
         db        00111000b
         db        00111100b
         db        00111100b
         db        00011100b
         db        00000010b
         db        00110010b
         db        01001100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        10100111b                ; maska kurzoru my®i (...-12 linek)
         db        10111001b
         db        10111101b
         db        10111101b
         db        11011101b
         db        11000010b
         db        10110010b
         db        01001101b
         db        10110011b
         db        11111111b
         db        11111111b
         db        11111111b

MouseSip db        00000000b                ; znak kurzoru my®i (13-... linek)
         db        00000000b
         db        01000000b
         db        01100000b
         db        01110000b
         db        01111000b
         db        01111100b
         db        01111110b
         db        01111000b
         db        01001100b
         db        00000100b
         db        00000110b
         db        00000000b
         db        00000000b

         db        01111111b                ; maska kurzoru my®i (13-... linek)
         db        00111111b
         db        01011111b
         db        01101111b
         db        01110111b
         db        01111011b
         db        01111101b
         db        01111110b
         db        01111000b
         db        01001101b
         db        00100101b
         db        11110110b
         db        11111000b
         db        11111111b

         db        00000000b                ; znak kurzoru my®i (...-12 linek)
         db        01000000b
         db        01100000b
         db        01110000b
         db        01111000b
         db        01111100b
         db        01010000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00111111b                ; maska kurzoru my®i (...-12 linek)
         db        01011111b
         db        01101111b
         db        01110111b
         db        01111011b
         db        01111101b
         db        01010000b
         db        00011011b
         db        11100011b
         db        11111111b
         db        11111111b
         db        11111111b

;MousePoz dw        0                        ; uschovan† pozice a ©†dek kurzoru

; -- Je p©ednastaveno setmàn° pravòm rohem kvñli n†vratu z extern°ho stm°vaáe
ParMouse db        bit5                     ; parametry my®i
                                            ;  bit 0: 1=pouëit° my®i zak†z†no
                                            ;  bit 1: 1=probàhla instalace
                                            ;  bit 2: 1=my® je nainstalov†na
                                            ;  bit 3: 1=grafickò m¢d my®i moënò
                                            ;  bit 4: 1=p©evod sou©adnic X 16*
                                            ;  bit 5: 1=bylo setmàn° pravòm rohem
                                            ;  bit 6: 1=obr†zek my®ky
                                            ;  bit 7: 1=byl 1. stisk tlaá°tka

ParMous2 db        0                        ; parametry my®i 2 - z†kazy
                                            ;  bit 0: 1=je grafickò m¢d my®i
                                            ;  bit 1: 1=z†kaz grafickÇ my®i od ASCII tabulky
                                            ;  bit 2: 1=standardn° obsluha my®i
                                            ;  bit 3: 1=z†kaz graf. my®i od disk. editoru
                                            ;  bit 4: 1=z†kaz od editoru okno 1
                                            ;  bit 5: 1=z†kaz od editoru okno 2

                                            ;  bit 7: 1=z†màna tlaá°tek my®i

MouseLev db        1                        ; £rove§ vypnut° my®i (0=zapnuto)

DarkParm db        bit0+bit5                ; parametry stm°v†n° displeje
                                            ;       bit 0: 1=funkce zapnuta
                                            ;       bit 1: 1=displej ztmaven
                                            ;       bit 2: 1=poëadavek pro start
                                            ;                extern°ho stm°vaáe
                                            ;       bit 3: 1=je moënÇ extern°
                                            ;                ztmaven° displeje

DarkTime dw        1092*5                   ; doba pro ztmaven° displeje (pulsñ)
DarkBeg  dd        0                        ; uschovanò áas zaá†tku stm°v†n°

;DarkChar dw        "*" + 7*HI               ; znak pro stm°vaá

DarkExeN dw        0                        ; dÇlka p©°kazu pro stm°vaá
DarkExec label     byte
         db        126 dup(0)               ; p©°kaz pro stm°vaá

KeyBuff  dw        0                        ; uschovan† kl†vesa z tabulky ASCII

Presmyk  db        -1                       ; uschovanò stav p©esmykaáñ
                                            ;     bit 0 aë bit 2: p©esmykaáe
                                            ;           0 = bez
                                            ;           1 = Shift-
                                            ;           2 = Ctrl-
                                            ;           3 = Alt-
                                            ;           4 = Shift-Ctrl-
                                            ;           5 = Shift-Alt-
                                            ;           6 = Ctrl-Alt-
                                            ;           7 = Shift-Ctrl-Alt-
                                            ;     bit 4: 1=Shift-
                                            ;     bit 5: 1=Ctrl-
                                            ;     bit 6: 1=Alt-

Data     ENDS

         END

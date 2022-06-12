
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           I N T E R R U P T
;                           obsluha p©eru®en°
;
; =============================================================================
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeInt  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeInt,ds:Data

;; *****************************************************************************
;;                                 InstTInt
;;                     instalace p©echodnòch obsluh p©eru®en°
;; -----------------------------------------------------------------------------
;; zniáenÇ registry: AX, BX, DX, ES
;; *****************************************************************************
;
;InstTInt PROC      FAR
;
;; ------ £schova pñvodn° adresy obsluhy INT 1Bh
;
;         mov       ax,351Bh
;         int       21h                      ; poskytnut° pñvodn° obsluhy INT 1Bh
;         mov       word ptr ds:[Old1B],bx   ; offset pñvodn° adresy INT 1Bh
;         mov       word ptr ds:[Old1B+2],es ; segment pñvodn° adresy INT 1Bh
;
;; ------ £schova pñvodn° adresy obsluhy INT 22h
;
;         mov       ax,3522h
;         int       21h                      ; poskytnut° pñvodn° obsluhy INT 22h
;         mov       word ptr ds:[Old22],bx   ; offset pñvodn° adresy INT 22h
;         mov       word ptr ds:[Old22+2],es ; segment pñvodn° adresy INT 22h
;
;; ------ £schova pñvodn° adresy obsluhy INT 23h
;
;         mov       ax,3523h
;         int       21h                      ; poskytnut° pñvodn° obsluhy INT 23h
;         mov       word ptr ds:[Old23],bx   ; offset pñvodn° adresy INT 23h
;         mov       word ptr ds:[Old23+2],es ; segment pñvodn° adresy INT 23h
;
;; ------ £schova pñvodn° adresy obsluhy INT 24h
;
;         mov       ax,3524h
;         int       21h                      ; poskytnut° pñvodn° obsluhy INT 24h
;         mov       word ptr ds:[Old24],bx   ; offset pñvodn° adresy INT 24h
;         mov       word ptr ds:[Old24+2],es ; segment pñvodn° adresy INT 24h
;
;; ------ instalace obsluhy INT 1Bh
;
;         push      ds                       ; £schova DS
;         mov       ax,SEG CodeLod
;         mov       ds,ax
;         mov       dx,offset Int023         ; offset novÇ obsluhy INT 1Bh
;         mov       ax,251Bh
;         int       21h                      ; instalace novÇ obsluhy INT 1Bh
;
;; ------ instalace INT 23h
;
;         mov       dx,offset Int023
;         mov       ax,2523h
;         int       21h
;
;; ------ instalace INT 24h
;
;         mov       dx,offset Int024
;         mov       ax,2524h
;         int       21h
;
;         pop       ds                       ; n†vrat DS
;         ret
;
;InstTInt ENDP
;
;; *****************************************************************************
;;                           DInsTInt
;;              odinstalov†n° p©echodnòch obsluh p©eru®en°
;; -----------------------------------------------------------------------------
;; zniáenÇ registry: AX, DX
;; *****************************************************************************
;
;DInsTInt PROC      FAR
;
;; ------ n†vrat adresy obsluhy INT 1Bh
;
;         push      ds                       ; £schova DS
;         lds       dx,ds:[Old1B]            ; pñvodn° adresa obsluhy INT 1Bh
;         mov       ax,251Bh
;         int       21h                      ; n†vrat adresy INT 1Bh
;         pop       ds                       ; n†vrat DS
;
;; ------ n†vrat adresy obsluhy INT 23h
;
;         push      ds                       ; £schova DS
;         lds       dx,ds:[Old23]            ; pñvodn° adresa obsluhy INT 23h
;         mov       ax,2523h
;         int       21h                      ; n†vrat adresy INT 23h
;         pop       ds                       ; n†vrat DS
;
;; ------ n†vrat adresy obsluhy INT 24h
;
;         push      ds                       ; £schova DS
;         lds       dx,ds:[Old24]            ; pñvodn° adresa obsluhy INT 24h
;         mov       ax,2524h
;         int       21h                      ; n†vrat adresy INT 24h
;         pop       ds                       ; n†vrat DS
;         ret
;
;DInsTInt ENDP

; *****************************************************************************
;                            InstInt
;                     instalace obsluh p©eru®en°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; zniáenÇ registry: AX, BX, DX, ES
; *****************************************************************************

InstInt  PROC      FAR

; ------ instalace p©ep°naáe p©eru®en°

         mov       ax,3300h
         int       21h                      ; poskytnut° BREAK
         mov       ds:[OldBreak],dl         ; £schova p©ep°naáe BREAK

         mov       dl,1                     ; BREAK zapnut
         mov       ax,3301h
         int       21h                      ; p©echodnÇ zapnut° p©ep°naáe BREAK

         mov       ah,0bh
         int       21h                      ; test p©eru®en° BREAK

         mov       ah,0bh
         int       21h                      ; test p©eru®en° BREAK

         mov       dl,0                     ; BREAK je vypnut
         mov       ax,3301h
         int       21h                      ; vypnut° p©ep°naáe BREAK

; ------ £schova pñvodn° adresy obsluhy INT 09h

         cli
         mov       ax,3509h
         int       21h                      ; poskytnut° pñvodn° obsluhy INT 09h
         mov       word ptr cs:[Old09],bx   ; offset pñvodn° adresy INT 09h
         mov       word ptr cs:[Old09+2],es ; segment pñvodn° adresy INT 09h

; ------ £schova pñvodn° adresy obsluhy INT 1Bh

         mov       ax,351Bh
         int       21h                      ; poskytnut° pñvodn° obsluhy INT 1Bh
         mov       word ptr ds:[Old1B],bx   ; offset pñvodn° adresy INT 1Bh
         mov       word ptr ds:[Old1B+2],es ; segment pñvodn° adresy INT 1Bh

; ------ £schova pñvodn° adresy obsluhy INT 22h

         mov       ax,3522h
         int       21h                      ; poskytnut° pñvodn° obsluhy INT 22h
         mov       word ptr ds:[Old22],bx   ; offset pñvodn° adresy INT 22h
         mov       word ptr ds:[Old22+2],es ; segment pñvodn° adresy INT 22h

; ------ £schova pñvodn° adresy obsluhy INT 23h

         mov       ax,3523h
         int       21h                      ; poskytnut° pñvodn° obsluhy INT 23h
         mov       word ptr ds:[Old23],bx   ; offset pñvodn° adresy INT 23h
         mov       word ptr ds:[Old23+2],es ; segment pñvodn° adresy INT 23h

; ------ £schova pñvodn° adresy obsluhy INT 24h

         mov       ax,3524h
         int       21h                      ; poskytnut° pñvodn° obsluhy INT 24h
         mov       word ptr ds:[Old24],bx   ; offset pñvodn° adresy INT 24h
         mov       word ptr ds:[Old24+2],es ; segment pñvodn° adresy INT 24h

; ------ instalace obsluhy INT 09h

         push      ds                       ; £schova DS

         push      cs
         pop       ds                       ; DS <- CS segment obsluhy INT 1Bh
         mov       dx,offset Int09          ; offset novÇ obsluhy INT 09h
         mov       ax,2509h
         int       21h                      ; instalace novÇ obsluhy INT 09h

; ------ instalace obsluhy INT 1Bh

         mov       dx,offset Int23          ; offset novÇ obsluhy INT 1Bh
         mov       ax,251Bh
         int       21h                      ; instalace novÇ obsluhy INT 1Bh

; ------ instalace INT 23h

         mov       dx,offset Int23
         mov       ax,2523h
         int       21h

; ------ instalace INT 24h

         mov       dx,offset Int24
         mov       ax,2524h
         int       21h

         pop       ds                       ; n†vrat DS

         sti
         ret

InstInt  ENDP

; *****************************************************************************
;                  Instalace obsluh p©eru®en° - 2. f†ze
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; zniáenÇ registry: AX, BX, DX, ES
; *****************************************************************************

Inst2Int PROC      FAR

; ------ test, zda je povolena instalace INT 13h a zda je®tà nen° nainstalov†n

         test      byte ptr cs:[Rez13Par],bit7+bit6 ; m† se INT 13 instalovat ?
         jnz       Inst2In2                 ; z†kaz instalace INT 13h

; ------ £schova pñvodn° adresy INT 13h

         mov       ax,3513h
         int       21h                      ; poskytnut° adresy INT 13h
         mov       word ptr cs:[Old13],bx   ; £schova adresy INT 13h
         mov       word ptr cs:[Old13+2],es

; ------ instalace novÇ obsluhy INT 13h

         push      ds
         push      cs
         pop       ds                       ; DS <- CS
         mov       dx,offset Int13
         mov       ax,2513h
         int       21h                      ; instalace obsluhy INT 13h
         pop       ds
         or        byte ptr cs:[Rez13Par],bit6 ; p©°znak instalace obsluhy

Inst2In2:ret

Inst2Int ENDP

; *****************************************************************************
;                           DeInsInt
;                  odinstalov†n° obsluh p©eru®en°
; -----------------------------------------------------------------------------
; zniáenÇ registry: AX, DX
; *****************************************************************************

DeInsInt PROC      FAR

; ------ n†vrat adresy obsluhy INT 09h

         push      ds                       ; £schova DS
         lds       dx,cs:[Old09]            ; pñvodn° adresa obsluhy INT 09h
         mov       ax,2509h
         int       21h                      ; n†vrat adresy INT 09h
         pop       ds                       ; n†vrat DS

; ------ n†vrat adresy obsluhy INT 1Bh

         push      ds                       ; £schova DS
         lds       dx,ds:[Old1B]            ; pñvodn° adresa obsluhy INT 1Bh
         mov       ax,251Bh
         int       21h                      ; n†vrat adresy INT 1Bh
         pop       ds                       ; n†vrat DS

; ------ n†vrat obsluhy INT 13h

         test      byte ptr cs:[Rez13Par],bit6 ; nainstalov†na obsluha ?
         jz        DeInsIn2                 ; obsluha nen° nainstalov†na
         push      ds
         lds       dx,cs:[Old13]            ; pñvodn° adresa obsluhy INT 13h
         mov       ax,2513h
         int       21h                      ; n†vrat adresy INT 13h
         pop       ds
         and       byte ptr cs:[Rez13Par],not bit6

; ------ n†vrat p©°znaku BREAK

DeInsIn2:mov       dl,ds:[OldBreak]         ; uschovanò p©ep°naá BREAK
         mov       ax,3301h
         int       21h                      ; n†vrat p©ep°naáe BREAK
         ret

DeInsInt ENDP

; *****************************************************************************
;                            Int09
;               obsluha p©eru®en° od kl†vesnice INT 09h
; -----------------------------------------------------------------------------
; *****************************************************************************

Old09    dd        ?                        ; pñvodn° obsluha INT 09h

Int09    PROC      FAR

; ------ p©°prava registrñ

         push      ax
         push      bx
         push      ds
         mov       bx,40h
         mov       ds,bx                    ; datovò segment BIOS
         mov       bx,ds:[1ch]              ; ukazatel ukl†dac° adresy

; ------ ochrana p©ed zahlcen°m kl†vesnice

         mov       ax,bx                    ; souáasn† ukl†dac° adresa
         inc       ax
         inc       ax                       ; n†sleduj°c° ukl†dac° kl†vesa
         cmp       ax,3eh                   ; je konec bufferu ?
         jne       Int0901                  ; nen° konec bufferu
         mov       ax,1eh                   ; oprava na zaá†tek bufferu
Int0901: cmp       ax,ds:[1ah]              ; je rovno átec° adrese ?
         jne       Int090                   ; nebude je®tà zahlcen°
         cmp       bx,1eh                   ; je zaá†tek bufferu ?
         jne       Int0902                  ; nen° zaá†tek bufferu
         mov       bx,3eh                   ; oprava na konec bufferu
Int0902: dec       bx
         dec       bx                       ; sn°ëen° ukl†dac° adresy
         mov       ds:[1ch],bx              ; nov† ukl†dac° adresa

; ------ pñvodn° obsluha kl†vesnice

Int090:  pushf                              ; simulace vol†n° INT xx
         call      dword ptr cs:[Old09]     ; pñvodn° obsluha INT 09h

; ------ kontrola, zda byl p©ijat nàjakò znak

         cmp       bx,ds:[1ch]              ; zmànila se ukl†dac° adresa ?
         je        Int099                   ; nebyl p©ijat ë†dnò znak

; ------ test, zda je p©eru®en° Ctrl-Break

         mov       ax,SEG Data
         cmp       word ptr ds:[bx],0       ; je p©eru®en° BREAK ?
         jne       Int0911                  ; nen° p©eru®en° BREAK
         push      ds
         mov       ds,ax
         or        byte ptr ds:[ParInt24],bit1 ; p©°znak p©eru®en° BREAK
         pop       ds

; ------ test, zda je p©eru®en° ESC

Int0911: cmp       word ptr ds:[bx],11bh    ; je p©eru®en° ESC ?
         jne       Int0912                  ; nen° p©eru®en° ESC
         push      ds
         mov       ds,ax
         or        byte ptr ds:[ParInt24],bit2 ; p©°znak p©eru®en° ESC
         pop       ds

; ------ znaky generovanÇ s ALT-á°slo se nemàn°

Int0912: cmp       byte ptr ds:[bx+1],0
         je        Int094

; ------ korekce roz®°©enÇho znaku E0,F0 na norm†ln°

         cmp       byte ptr ds:[bx],0e0h
         je        Int091
         cmp       byte ptr ds:[bx],0f0h
         jne       Int092
Int091:  mov       byte ptr ds:[bx],0

; ------ p©egenerov†n° roz®°©enÇho znaku > 7fh na bàënò znak

Int092:  cmp       byte ptr ds:[bx],0
         jne       Int093                   ; nen° ©°dic° kl†vesa
         cmp       byte ptr ds:[bx+1],85h
         jb        Int093                   ; k¢d znaku je OK
         mov       al,ds:[bx+1]
         mov       ds:[bx],al
         mov       byte ptr ds:[bx+1],1     ; p©°znak roz®°©enÇho znaku

; ------ n†hrada znaku "[/]" speci†ln°m znakem "/"

Int093:  cmp       word ptr ds:[bx],0e02fh
         jne       Int094
         mov       word ptr ds:[bx],12fh
Int094:

; ------ n†vrat registrñ

Int099:  pop       ds
         pop       bx
         pop       ax
         iret

Int09    ENDP

; *****************************************************************************
;                             Int13
;                 obsluha roz®°©enòch form†tñ disket
; *****************************************************************************

Rez13Par db        0                        ; parametry rezidentn°ho modulu
                                            ;   bit 6: 1=INT 13 nainstalov†n
                                            ;   bit 7: 1=z†kaz instalace

Int13    PROC      FAR

; ------ kontrola, zda to je mechanika A: nebo B:

         cmp       dl,1                     ; maxim†ln° á°slo diskety
         ja        Int13Exe                 ; pokraáov†n° pñvodn° obsluhou

; ------ kontrola, zda je funkce 2 aë 4 (áten°, z†pis, verifikace)

         cmp       ah,4
         ja        Int13Exe                 ; nen° funkce 2 aë 4
         cmp       ah,2
         jb        Int13Exe                 ; nen° funkce 2 aë 4

; ------ £schova registrñ

         push      es
         push      cx
         push      bx
         push      ax

; ------ zvò®en° poátu sektorñ na stopu

         xor       bx,bx                    ; BX <- 0
         mov       es,bx                    ; ES <- 0
         les       bx,es:[bx+4*1eh]         ; adresa tabulky INT 1Eh
         cmp       byte ptr es:[bx+4],46    ; je jië nàjakÇ velkÇ á°slo ?
         jae       Int132                   ; je jië nàco vàt®°ho
         mov       byte ptr es:[bx+4],46    ; zvò®en° poátu sektorñ na stopu

; ------ inicializace registrñ na data BIOS

Int132:  mov       bx,40h                   ; BX <- 40h
         mov       es,bx                    ; ES <- 40h

; ------ test, zda je mÇdium jië uráeno

         add       bl,dl                    ; korekce na á°slo disku
         test      byte ptr es:[bx-40h+90h],10h ; je mÇdium jië uráeno ?
         jnz       Int138                   ; je jië uráeno

; ------ mÇdium uráeno

         or        byte ptr es:[bx-40h+90h],10h ; teÉ jië je uráeno

; ------ test, zda je rychlost nastavena OK (nyn° je ES=40h, BX=40h aë 41h)

         mov       cx,200h                  ; CH <- stopa, CL <- sektor
Int133:  inc       cx                       ; CL <- zvò®en° á°sla sektoru
         mov       ax,401h                  ; verifikace 1 sektoru
         push      bx                       ; £schova offsetu v BIOS
         push      cx                       ; £schova stopy a sektoru
         push      dx                       ; £schova disku a strany
         push      es

         pushf                              ; simulace instrukce INT ...
         push      cs                       ; simulace instrukce CALL FAR ...
         call      Int13Exe                 ; verifikace sektoru

         pop       es
         pop       dx                       ; n†vrat disku a strany
         pop       cx                       ; n†vrat stopy a sektoru
         pop       bx                       ; n†vrat offsety v BIOS
         jnc       Int138                   ; rychlost detekov†na OK

; ------ chyba vòmàny mÇdia nebo disk nep©ipraven - okamëitÇ ukonáen°

         cmp       ah,6
         je        Int139                   ; vòmàna diskety
         or        ah,ah                    ; chyba 80h ?
         js        Int139                   ; mechanika nep©ipravena

; ------ zvò®en° rychlosti (cyklus 500 > 300 > 250 > 1000)

         add       byte ptr es:[bx-40h+90h],40h ; zvò®en° rychlosti
         test      cl,3                     ; je sektor 4 nebo 8 ?
         jnz       Int133                   ; nen° sektor 4 ani 8

; ------ zmàna krokov†n° (p©i sektorech 4 a 8) (dvojitÇ a jednoduchÇ)
; Krokov†n° se màn° aë po zmàn†ch rychlosti, aby po©†d nevystavovala mechanika

         xor       byte ptr es:[bx-40h+90h],20h ; zmàna krokov†n°
         cmp       cl,8                     ; je jië maximum testñ ?
         jb        Int133                   ; nen° je®tà maximum testñ

; ------ mÇdium neuráeno

         and       byte ptr es:[bx-40h+90h],not 10h ; mÇdium neuráeno

; ------ n†vrat registrñ

Int138:  pop       ax
         pop       bx
         pop       cx
         pop       es

; ------ pokraáov†n° pñvodn° obsluhou

Int13Exe:db        0eah                     ; instrukce JMP FAR
Old13    dd        0                        ; pñvodn° adresa INT 13h

; ------ n†vrat p©i chybà 6 (vòmàna diskety) a 80h (nen° vloëena disketa)

Int139:  and       byte ptr es:[bx-40h+90h],not 10h ; mÇdium neuráeno
         pop       bx                       ; ponech† se reg. AX - chybovò k¢d
         pop       bx
         pop       cx
         pop       es
         stc                                ; p©°znak chyby
         ret       2                        ; tento n†vrat pouë°v† i BIOS

Int13    ENDP

; *****************************************************************************
;                             GetBreak
;                   poskytnut° p©°znaku p©eru®en°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: AL=p©°znaky p©eru®en°
;               bit 1: 1=p©eru®en° BREAK
;               bit 2: 1=p©eru®en° ESC
; *****************************************************************************

GetBreak PROC      FAR

         mov       al,ds:[ParInt24]         ; p©°znaky p©eru®en°
         and       al,bit1 + bit2
         ret

GetBreak ENDP

; *****************************************************************************
;                            SetBreak
;                nastaven° p©°znaku p©eru®en° Break
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY (p©°znak p©eru®en°)
; *****************************************************************************

SetBreak PROC      FAR

         or        byte ptr ds:[ParInt24],bit1   ; p©°znak p©eru®en° Break
         stc
         ret

SetBreak ENDP

; *****************************************************************************
;                            SetEsc
;                nastaven° p©°znaku p©eru®en° ESC
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY (p©°znak p©eru®en°)
; *****************************************************************************

SetEsc   PROC      FAR

         or        byte ptr ds:[ParInt24],bit2   ; p©°znak p©eru®en° ESC
         stc
         ret

SetEsc   ENDP

; *****************************************************************************
;                              NulBreak
;           nulov†n° p©°znaku p©eru®en° BREAK a ESC (a z†kazu p©eru®en°)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

NulBreak PROC      FAR

         and       byte ptr ds:[ParInt24],not bit1 + bit2 + bit6
         ret

NulBreak ENDP

; *****************************************************************************
;                                 ZapKrit
;         zapnut° p©°znaku kritickÇ operace (z†kaz p©eru®en° funkc°)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ZapKrit  PROC      FAR

         or        byte ptr ds:[ParInt24],bit6   ; p©°znak z†kazu p©eru®en°
         ret

ZapKrit  ENDP

; *****************************************************************************
;                              VypKrit
;               vypnut° p©°znaku kritickÇ operace
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; Uchov†v† registr p©°znakñ !
; *****************************************************************************

VypKrit  PROC      FAR

         pushf
         and       byte ptr ds:[ParInt24],not bit6 ; p©°znak z†kazu p©eru®en°
         popf
         ret

VypKrit  ENDP

; *****************************************************************************
;                              TestBEsc
;               Test p©eru®en° operace chybou, Ctrl-BREAK nebo ESC
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=je p©eru®en° operace
; *****************************************************************************

TestBEsc PROC     FAR

         test      byte ptr ds:[ParInt24],bit6 ; je z†kaz p©eru®en° ?
         jnz       TestBEs2                 ; je z†kaz p©eru®en°
         test      byte ptr ds:[ParInt24],bit1+bit2 ; je p©eru®en° BREAK/ESC ?
         jz        TestBEs2                 ; nen° p©eru®en° BREAK ani ESC
         stc                                ; p©°znak p©eru®en° operace
TestBEs2:ret

TestBEsc ENDP

; *****************************************************************************
;                              TestBreak
;               Test p©eru®en° operace chybou nebo Ctrl-BREAK
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=je p©eru®en° operace BREAK
; *****************************************************************************

TestBreak PROC     FAR

         test      byte ptr ds:[ParInt24],bit6 ; je z†kaz p©eru®en° ?
         jnz       TestBrk2                 ; je z†kaz p©eru®en°
         test      byte ptr ds:[ParInt24],bit1 ; je p©eru®en° BREAK ?
         jz        TestBrk2                 ; nen° p©eru®en° BREAK
         stc                                ; p©°znak p©eru®en° BREAK
TestBrk2:ret

TestBreak ENDP

; *****************************************************************************
;                            TestEsc
;                   Test p©eru®en° operace Esc
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=je p©eru®en° operace ESC
; *****************************************************************************

TestEsc  PROC      FAR

         test      byte ptr ds:[ParInt24],bit6 ; je z†kaz p©eru®en° ?
         jnz       TestEsc9                 ; je z†kaz p©eru®en°
         test      byte ptr ds:[ParInt24],bit2 ; je p©eru®en° operace ESC ?
         jz        TestEsc9                 ; nen° p©eru®en° ESC
         stc                                ; p©°znak p©eru®en° ESC
TestEsc9:ret

TestEsc  ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 23h a INT 1Bh (Break)
; -----------------------------------------------------------------------------

Int23    PROC      FAR

         push      ax
         push      ds
         mov       ax,SEG Data
         mov       ds,ax
         or        byte ptr ds:[ParInt24],bit1 ; p©°znak p©eru®en° operace BREAK
         pop       ds
         pop       ax
         iret

Int23    ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru®en° INT 24h
; -----------------------------------------------------------------------------

Int24    PROC      FAR

; ------ test, zda je jië p©eru®en° operace nebo se chyby ignoruj°

         push      bx
         push      ds
         mov       bx,SEG Data
         mov       ds,bx
         test      byte ptr ds:[ParInt24],bit0+bit1+bit2+bit3+bit4 ; p©er./ign.
         jz        Int241                   ; nen° p©eru®en°/ignorov†n°
         mov       al,0                     ; p©°znak ignorov†n° chyby
         pop       ds
         pop       bx
         iret
;˛
; ------ £schova registrñ
; VSTUP INT 24h:
; -------------
; AX=dopl§uj°c° informace o chybà
;     bit 15: 1=chybovò k¢d v DI (znak. za©°zen°) nebo chyba FAT (blok.za©°zen°)
;                    ostatn° bity AX nedefinov†ny
;             0=diskov† chyba, bity 0 aë 14 AX jsou platnÇ
;     bit 14: (rezervov†n, m† hodnotu 0)                        ƒƒƒøplatnÇ jen
;     bit 13: 1=ignorov†n° povoleno (DOS 3.00+)                    ≥pro bit 15=0
;     bit 12: 1=opakov†n° povoleno (DOS 3.00+)                     ≥
;     bit 11: 1=ohl†®en° chyby povoleno (DOS 3.00+)                ≥
;     bit 9-10: diskovò prostor 0=systÇm DOS, 1=FAT, 2=ROOT, 3=data≥
;     bit 8: 0=chyba áten°, 1=chyba z†pis                          ≥
;     bit 0 aë 7: á°slo disku (0=A, ...)                        ƒƒƒŸ
; BP:SI=z†hlav° za©°zen°
; DI=chybovò k¢d - jen nië®° bajt (bity 0 aë 7) (je-li bit 15 AX = 1)
;     0=pokus o z†pis na disk chr†nànò proti z†pisu (ochrana proti z†pisu)
;     1=neplatn† diskov† jednotka
;     2=diskov† jednotka nen° p©ipraven
;     3=neplatnò povel pro za©°zen° (neobsluhovan† funkce za©°zen°)
;     4=chyba dat (chyba kontroln°ho souátu CRC)
;     5=chybn† dÇlka struktury poëadavku na za©°zen°
;     6=chyba vystaven° disku
;     7=nezn†mò typ mÇdia
;     8=sektor nenalezen
;     9=v tisk†rnà nen° pap°r
;    10=chyba p©i z†pisu
;    11=chyba áten°
;    12=v®eobecn†, bl°ëe nespecifikovateln† chyba
;    13=poru®eno sd°len° souborñ
;    14=poru®eno uzamáen° souborñ  (DOS 3.0+) lock violation
;    15=nepovolen† vòmàna disku
;    16=nen° volnò FCB
;    17=p©eteáen° bufferu sd°len° souborñ
;    18=neplatn† k¢dov† str†nka (DOS 4.0+) code page mismatch
;    19=nejsou vstupn° data (DOS 4.0+) out of input
;    20=nedostatek m°sta na disku

Int241:  or        byte ptr ds:[ParInt24],bit3+bit5 ; p©°znak obsluhy INT 24h
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ rozli®en° disku/za©°zen°

         mov       word ptr ds:[I24MnPl3],offset I24MnPl6 ; chyba za©°zen°
         or        ax,ax                    ; je to znakovÇ za©°zen° ?
         js        Int242                   ; je to znakovÇ za©°zen°
         cmp       al,DiskMax               ; je platnÇ á°slo disku ?
         jae       Int242                   ; nen° disk, je za©°zen°
         mov       word ptr ds:[I24MnPl3],offset I24MnPl7 ; chyba disku
         add       al,"A"                   ; oznaáen° disku
         mov       byte ptr ds:[I24MnPl8],al ; oznaáen° disku

; ------ p©°prava textu hl†®en° (DS=datovò segment)

Int242:  push      ds

         call      far ptr GetErDOS         ; poskytnut° chyby DOS
         mov       ds:[I24MnPl1],cl         ; dÇlka textu
         mov       word ptr ds:[I24MnPl2],si ; adresa textu
         mov       word ptr ds:[I24MnPl2+2],es

         pop       es                       ; ES <- datovò segment

; ------ inicializace registrñ

         call      far ptr DispAll          ; zobrazen° podkladu
         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         mov       si,offset Int24Mnu       ; definice menu
         call      far ptr LineMenu         ; obsluha ©†dkovÇho menu
         jmp       short Int2472            ; p©eru®en° operace

; ------ n†vrat z obsluhy

Int247:  add       sp,4                     ; zru®en° n†vratovÇ adresy
         mov       ax,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         call      far ptr ClosMnu          ; uzav©en° okna menu
         cmp       al,3                     ; je ignorov†n° chyb ?
         je        Int2474                  ; je ignorov†n° chyb
         cmp       al,2                     ; je p©eru®en° operace ?
         jne       Int248                   ; nen° p©eru®en°
Int2472: or        byte ptr ds:[ParInt24],bit1 ; p©°znak p©eru®en° operace
Int2474: mov       al,0                     ; p©°znak ignorov†n° chyby

Int248:  and       byte ptr ds:[ParInt24],not bit5 ; zru®en° p©°znaku zobrazen°
         call      far ptr DispAll          ; obnoven° zobrazen°

; ------ n†vrat registrñ

Int249:  and       byte ptr ds:[ParInt24],not bit3 ; zru®en° p©°znaku INT 24h
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx

         pop       ds
         pop       bx
         iret

; Navr†ceno:
;  AL: 0=ignorov†n° chyby a pokraáov†n° v operaci
;      1=opakov†n° operace
;      2=p©eru®en° programu jako p©i INT 21h/AH=4Ch (resp. INT 23h)
;      3=navr†cen° chyby (DOS 3.00+)

Int24    ENDP

; *****************************************************************************
;                               InstA08
;            instalace obsluhy nastaven° data a áasu adres†©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        CX=poëadovanò áas ve tvaru souborñ
;        DX=poëadovanÇ datum ve tvaru souborñ
; -----------------------------------------------------------------------------
;˛
InstA08  PROC      FAR

; ------ test, zda je obsluha jië nainstalov†na

         test      byte ptr ds:[ParA08],bit0 ; je obsluha jië nainstalov†na ?
         jz        InstA081                 ; nen° nainstalov†na
         ret

; ------ £schova registrñ

InstA081:push      ax
         push      bx
         push      cx
         push      dx

; ------ £schova poëadovanòch sekund

         xchg      ax,cx                    ; AX <- poëadovanò áas
         push      ax
         and       al,bit0+bit1+bit2+bit3+bit4 ; sekunda / 2
         shl       al,1                     ; sekunda
         cmp       al,58
         jbe       InstA082
         mov       al,58                    ; omezen° poátu sekund
InstA082:mov       bh,al                    ; poëadovan† sekunda
         mov       bl,0                     ; setiny sekundy = 0
         pop       ax

; ------ £schova poëadovanòch minut

         mov       cl,5
         shr       ax,cl
         push      ax
         and       al,(bit5+bit6+bit7+bit8+bit9+bit10)/bit5 ; minuta
         cmp       al,59
         jbe       InstA083
         mov       al,59                    ; omezen° poátu minut
InstA083:mov       ch,al                    ; poëadovan† minuta
         pop       ax

; ------ £schova poëadovanòch hodin

         mov       cl,11-5                  ; poáet rotac°
         shr       ax,cl                    ; AL <- hodina
         cmp       al,23
         jbe       InstA084
         mov       al,23                    ; omezen° poátu hodin
InstA084:mov       cl,ch                    ; CL <- minuta
         mov       ch,al                    ; poëadovan† nov† hodina

; ------ p©epoáet áasu na setiny sekundy

         push      dx                       ; datum
         call      GetTSet0                 ; p©epoáet na setiny sekundy
         add       ax,20                    ; trochu korekce
         adc       dx,0

         mov       word ptr ds:[NewA08T],ax ; £schova áasu LOW
         mov       word ptr ds:[NewA08T+2],dx ; £schova áasu HIGH
         pop       ax                       ; AX <- datum

; ------ £schova poëadovanÇho dne

         push      ax
         and       al,bit0+bit1+bit2+bit3+bit4 ; den
         jnz       InstA085                 ; den je OK
         inc       ax                       ; minim†ln° den = 1
InstA085:mov       ds:[NewA08D],al          ; £schova poëadovanÇho novÇho dne
         pop       ax

; ------ £schova poëadovanÇho màs°ce

         mov       cl,5
         shr       ax,cl
         push      ax
         and       al,(bit5+bit6+bit7+bit8)/bit5 ; màs°c
         jnz       InstA086                 ; nen° = 0
         inc       ax                       ; minim†ln° màs°c 1
InstA086:cmp       al,12                    ; maxim†ln° màs°c
         jbe       InstA087                 ; màs°c je OK
         mov       al,12                    ; omezen° màs°ce na 12
InstA087:mov       ds:[NewA08M],al          ; £schova poëadovanÇho màs°ce
         pop       ax

; ------ £schova poëadovanÇho roku

         mov       cl,9-5
         shr       ax,cl                    ; rok - 1980
         add       ax,1980                  ; rok
         mov       ds:[NewA08R],ax          ; £schova poëadovanÇho roku

; ------ £schova aktu†ln°ho áasu a data

         cli                                ; aby nenastala zmàna data
         mov       bx,offset OldA08T        ; pñvodn° datum a áas
         call      InsA08G                  ; £schova data a áasu

; ------ nastaven° novÇho poëadovanÇho áasu

         mov       bx,offset NewA08T        ; novò datum a áas
         call      InsA08S                  ; nastaven° novÇho data a áasu

; ------ pro p©°pad ne£spàchu nastaven° zpàtnÇ naáten° skuteánÇho stavu

         call      InsA08G                  ; zpàtnÇ nastaven° skuteánÇho stavu
         or        byte ptr ds:[ParA08],bit0 ; p©°znak instalace p©eru®en°

; ------ n†vrat registrñ

         sti                                ; p©eru®en° opàt povoleno
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InstA08  ENDP

; *****************************************************************************
;                               DInsA08
;         odinstalov†n° obsluhy nastaven° data a áasu adres†©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        uchov†v† registr p©°znakñ !
; *****************************************************************************

DInsA08  PROC      FAR

; ------ £schova registrñ

         pushf
         push      ax
         push      bx
         push      cx
         push      dx

; ------ test, zda je obsluha jië odinstalov†na

         cli                                ; z†kaz p©eru®en° bàhem operace
         test      byte ptr ds:[ParA08],bit0 ; je obsluha nainstalov†na ?
         jz        DInsA089                 ; obsluha nen° nainstalov†na

; ------ vòpoáet ubàhlÇho áasu -> DX:AX (1 den = 24*60*60*100 = 8640000)

         call      GetTSet                  ; poskytnut° áasu v setin†ch
         sub       ax,word ptr ds:[NewA08T] ; ubàhlò áas LOW
         sbb       dx,word ptr ds:[NewA08T+2] ; ubàhlò áas HIGH
         jnc       DInsA082                 ; nen° podteáen°
         add       ax,54784                 ; korekce pro p©elom dne
         adc       dx,131

; ------ oprava starÇho áasu

DInsA082:add       word ptr ds:[OldA08T],ax ; oprava starÇho áasu
         adc       word ptr ds:[OldA08T+2],dx

; ------ test, zda je p©eteáen° p©es pñlnoc

         cmp       word ptr ds:[OldA08T+2],131
         jne       DInsA084
         cmp       word ptr ds:[OldA08T],54784
DInsA084:jb        DInsA086                 ; nen° p©eteáen° p©es pñlnoc

; ------ oprava áasu a data p©i p©eteáen° p©es pñlnoc

         sub       word ptr ds:[OldA08T],54784
         sbb       word ptr ds:[OldA08T+2],131
         inc       byte ptr ds:[OldA08D]    ; zvò®en° á°sla dne

; Zde se ignoruje p©eteáen° p©es pñlnoc na konci màs°ce - nezn†me poáet dnñ

; ------ n†vrat pñvodn°ho data a áasu

DInsA086:mov       bx,offset OldA08T        ; pñvodn° datum a áas
         call      InsA08S                  ; n†vrat pñvodn°ho data a áasu

; ------ n†vrat registrñ

DInsA089:sti                                ; p©eru®en° povoleno
         and       byte ptr ds:[ParA08],not bit0 ; zru®en° p©°znaku instalace
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

DInsA08  ENDP

; -----------------------------------------------------------------------------
;        £schova data a áasu od adresy BX
; -----------------------------------------------------------------------------

InsA08G  PROC      NEAR

; ------ £schova aktu†ln°ho áasu

         call      GetTSet                  ; poskytnut° áasu v setin†ch
         mov       ds:[bx],ax               ; £schova áasu LOW
         mov       ds:[bx+2],dx             ; £schova áasu HIGH

; ------ £schova aktu†ln°ho data

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         mov       ds:[bx+4],dl             ; den
         mov       ds:[bx+5],dh             ; màs°c
         mov       ds:[bx+6],cx             ; rok
         ret

InsA08G  ENDP

; -----------------------------------------------------------------------------
;        nastaven° data a áasu od adresy BX
; -----------------------------------------------------------------------------

InsA08S  PROC      NEAR

; ------ nastaven° novÇho áasu

         mov       ax,ds:[bx]               ; setiny sekund LOW
         mov       dx,ds:[bx+2]             ; setiny sekund HIGH
         call      SetTSet                  ; nastaven° áasu

; ------ nastaven° novÇho data

         mov       dl,ds:[bx+4]             ; den
         mov       dh,ds:[bx+5]             ; màs°c
         mov       cx,ds:[bx+6]             ; rok
         mov       ah,2bh
         int       21h                      ; nastaven° systÇmovÇho data
         ret

InsA08S  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° áasu v setin†ch sekundy -> DX:AX (niá° CX)
; -----------------------------------------------------------------------------

GetTSet0:push      bx
         push      si
         jmp       short GetTSet2


GetTSet  PROC      NEAR

         push      bx
         push      si

         mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         mov       bx,dx                    ; BX <- sekundy a setiny

GetTSet2:mov       al,60                    ; poáet minut na hodinu
         mul       ch                       ; p©epoáet hodin na minuty (<=1380)
         mov       ch,0
         add       ax,cx                    ; p©iáten° minut (<=1439)

         mov       cl,60                    ; poáet sekund na minutu
         mul       cx                       ; p©epoáet minut na sekundy(<=86340)
         mov       cl,bh                    ; sekundy
         add       ax,cx                    ; p©iáten° sekund
         adc       dx,0                     ; p©enos         (<=86399)

         xchg      ax,si                    ; SI <- sekund LOW
         xchg      ax,dx                    ; AX <- sekund HIGH
         mov       cl,100                   ; poáet setin na sekundu
         mul       cx                       ; p©epoáet sekund HIGH na setiny
         xchg      ax,si                    ; AX <- sekund LOW, SI <- setin HIGH
         mul       cx                       ; p©epoáet sekund LOW na setiny
         mov       bh,0                     ; BX = setiny
         add       ax,bx                    ; p©iáten° setin
         adc       dx,si                    ; p©iáten° setin HIGH

         pop       si
         pop       bx
         ret

GetTSet  ENDP

; -----------------------------------------------------------------------------
;        nastaven° áasu v setin†ch sekund DX:AX (niá° AX, CX, DX)
; -----------------------------------------------------------------------------

SetTSet  PROC      NEAR

         push      bx
         push      si

         mov       si,100                   ; poáet setin na sekundu
         xchg      ax,cx                    ; CX <- setin LOW
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- setin HIGH, DX <- 0
         div       si                       ; p©epoáet na sekundy HIGH
         xchg      ax,cx                    ; AX <- setin LOW, CX <- sekund HIGH
         div       si                       ; p©epoáet na sekundy LOW
         mov       bl,dl                    ; BL <- setin sekund

         mov       si,60                    ; poáet sekund na minutu
         mov       dx,cx                    ; DX <- sekund HIGH, AX=sekund LOW
         cmp       dx,2                     ; asi tak maximum
         jbe       SetTSet2
         mov       dx,2                     ; ochrana proti p©eteáen°
SetTSet2:div       si                       ; p©epoáet na minuty
         mov       bh,dl                    ; BH <- sekundy

         xor       dx,dx                    ; DX <- 0
         div       si                       ; p©epoáet na hodiny
         mov       ch,al                    ; CH <- hodina
         mov       cl,dl                    ; CL <- minuta
         mov       dx,bx                    ; DX <- sekundy a setiny sekund

         mov       ah,2dh
         int       21h                      ; nastaven° áasu

         pop       si
         pop       bx
         ret

SetTSet  ENDP

; *****************************************************************************
;                                TestTDis
;                       test áasovanÇho zobrazov†n°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° je®tà pot©eba zobrazen°
; *****************************************************************************

TestTDis PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ aktu†ln° systÇmovò áasovaá

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; áasovaá
         pop       ds

; ------ test, zda je jië pot©eba zobrazen°

         sub       ax,ds:[OldTDis]          ; uplynulò áas
         cmp       ax,2;3                     ; 3 tiky = 6x za sekundu
         jb        TestTDs9                 ; nen° je®tà pot©eba zobrazen°
         add       ds:[OldTDis],ax          ; £schova novÇho aktu†ln°ho áasu
         clc                                ; p©°znak pot©eby zobrazen°

; ------ n†vrat registrñ

TestTDs9:pop       ax
         ret

TestTDis ENDP

; *****************************************************************************
;                               InitQVw
;                      inicializace rychloprohl°ëen°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InitQVw  PROC      FAR

         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]

         pop       ds
         mov       ds:[OldTQVw],ax
         or        byte ptr ds:[ParA08],bit7 ; poëadavek QuickView
         pop       ax
         ret

InitQVw  ENDP

; *****************************************************************************
;                                  TestQVw
;                            test rychloprohl°ëen°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° pot©eba zobrazen°
; *****************************************************************************

TestQVw  PROC      FAR

         test      byte ptr ds:[ParA08],bit7 ; je poëadavek QuickView ?
         stc
         jz        TestQVw9                 ; nen° poëadavek QuickView

         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]

         pop       ds
         sub       ax,ds:[OldTQVw]          ; ubàhlò áas
         cmp       ax,2                     ; asi takovò áas
         pop       ax
         jb        TestQVw9                 ; nen° je®tà pot©ebn† doba

         and       byte ptr ds:[ParA08],not bit7 ; zru®en° poëadavku

TestQVw9:ret

TestQVw  ENDP

; *****************************************************************************
;                     poskytnut° informace o chybà DOS
; -----------------------------------------------------------------------------
; VSTUP: DI=k¢d chyby podle INT 24h (jen je-li pot©ebnò k¢d pro DOS < 3.00)
;        DS=datovò segment
; VùSTUP: AX=k¢d chyby (pro DOS 3.00+ je platnÇ jen je-li platnò obsah DI)
;         CX=dÇlka textu chyby
;         ES:SI=adresa textu chyby
;         CY=funkce nepodporovan† (verze DOS je nië®° neë 3.00)
; *****************************************************************************

GetErDOS PROC      FAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      di
         push      bp
         push      ds

; ------ k¢d chyby pro nië®° verzi DOS

         xchg      ax,di                    ; AX <- k¢d chyby
         add       ax,19                    ; korekce na novò m¢d
         cmp       word ptr ds:[VerzeOS],300h ; minim†ln° verze 3.00
         jb        GetErDS2                 ; je n°zk† verze systÇmu

; ------ dotaz na chybu

         xor       bx,bx                    ; BX <- 0
         mov       ah,59h
         int       21h                      ; dotaz na chybu -> AX
         clc                                ; p©°znak operace OK

; ------ adresa textu chyby -> ES:SI

GetErDS2:mov       ah,0                     ; vy®®° bajt je neplatnò

         pushf

         push      cs
         pop       es                       ; ES <- segment tohoto modulu

         cmp       ax,104                   ; maxim†ln° á°slo chyby
         ja        GetErDS5                 ; nezn†m† chyba

         mov       si,offset ErrTxTab       ; tabulka textñ chyb
         mov       cx,ax                    ; CX <- á°slo chyby
         jcxz      GetErDS4                 ; je chyba 0

         push      ax
GetErDS3:mov       al,cs:[si]               ; dÇlka textu
         inc       si
         add       si,ax                    ; adresa dal®°ho textu
         loop      GetErDS3                 ; dal®° text
         pop       ax

GetErDS4:cmp       byte ptr cs:[si],0       ; je text platnò ?
         jne       GetErDS6                 ; text je platnò OK

GetErDS5:mov       si,offset ErrTxTb0       ; nedefinovan† chyba

; ------ dek¢dov†n° á°sla chyby pro hl†®en°

GetErDS6:push      ax
         aam                                ; rozdàlen° na á°slice
         xchg      al,ah                    ; oprava po©ad° á°slic
         add       ax,"00"
         mov       word ptr cs:[ErrTxTb1],ax ; á°slo chyby
         pop       ax

; ------ korekce

         mov       cl,cs:[si]               ; dÇlka textu
         mov       ch,0
         inc       si                       ; zaá†tek textu

         popf

; ------ n†vrat registrñ

         pop       ds
         pop       bp
         pop       di
         pop       dx
         pop       bx
         ret

GetErDOS ENDP

; Funkce 59h:
; ----------
; AX=chybovò k¢d:
;     0=nen° chyba
;     1=neplatnÇ á°slo funkce (asi poëadavek na za©°zen°)
;     2=soubor nenalezen
;     3=cesta nenalezena
;     4=p©°li® mnoho otev©enòch souborñ (nen° volnò identifik†tor souboru)
;     5=p©°stup nepovolen (poëadavek odm°tnut)
;     6=neplatnò identifik†tor souboru (asi za©°zen° nebo souboru)
;     7=po®kozen ©°dic° blok pamàti (po®kozena struktura pamàti DOS)
;     8=nedostatek pamàti
;     9=neplatn† adresa pamàüovÇho bloku
;    10=neplatnÇ prost©ed° (je vàt®° neë 32 KB)
;    11=neplatnò form†t
;    12=neplatnò p©°stupovò k¢d
;    13=neplatn† data
;    14= (rezervov†no)
;    15=neplatnò disk
;    16=pokus o zru®en° aktu†ln°ho adres†©e
;    17=nen° shodnÇ za©°zen° (not same device)
;    18=nejsou dal®° soubory
;    ------------------------
;    19=pokus o z†pis na disk chr†nànò proti z†pisu (ochrana disku proti z†pisu)
;    20=neplatn† (nezn†m†) diskov† jednotka
;    21=diskov† jednotka nen° p©ipravena (disk nen° p©ipraven)
;    22=neplatnò (nezn†mò) povel pro za©°zen° (neobsluhovan† funkce za©°zen°)
;    23=chyba dat (chyba kontroln°ho souátu CRC)
;    24=chybn† dÇlka struktury poëadavku na za©°zen°
;    25=chyba vystaven° disku
;    26=nezn†mò typ mÇdia (nen° DOSovskò disk)
;    27=sektor nenalezen
;    28=v tisk†rnà nen° pap°r
;    29=chyba p©i z†pisu
;    30=chyba áten°
;    31=v®eobecn†, bl°ëe nespecifikovateln† chyba (celkov† chyba)
;    ----------------------
;    32=poru®eno sd°len° souborñ
;    33=poru®en° uzamyk†n° souborñ  (lock violation)
;    34=nepovolen† vòmàna disku (ES:DI -> identifikaán° struktura disku)
;           (vloëte zpàt disk "label", sÇriovÇ á°slo xxxx)
;               ES:DI=adresa       0 (12) ASCIIZ jmÇno poëadovanÇho disku
;                                 12 (4) sÇriovÇ á°slo disku (DOS 4.0+)
;    35=nen° volnò FCB
;    36=p©eteáen° vyrovn†vac° pamàti pro sd°len° souborñ
;    37=neplatn† k¢dov† str†nka (code page mismatch)
;    38=nelze dokonáit operaci se souborem, nejsou vstupn° data (out of input)
;    39=nedostatek m°sta na disku
;    40..49= (rezervov†no)
;    50=s°üovò poëadavek nepodporov†n
;    51=vzd†lenò poá°taá nep©ij°m†
;    52=duplikovanÇ s°üovÇ jmÇno
;    53=s°üovÇ jmÇno nenalezeno
;    54=s°ü zanepr†zdnàna
;    55=s°üovÇ za©°zen° jië nad†le neexistuje
;    56=omezen° povelñ s°üovÇho BIOS p©ekroáeno
;    57=chyba hardware s°üovÇho adaptÇru
;    58=chybn† odpovàÉ ze s°tà
;    59=neoáek†van† s°üov† chyba
;    60=nekomptaibiln° vzd†lenò s°üovò adaptÇr
;    61=tiskov† fronta je pln†
;    62=nedostatek prostoru k vytisknut° souboru (tiskov† fronta nen° pln†)
;    63=tisknutò soubor byl zru®en (nedostatek prostoru k vyti®tàn° souboru)
;    64=s°üovÇ jmÇno bylo zru®eno
;    65=s°üovò p©°stup nepovolen (poëadavek odm°tnut)
;    66=nespr†vnò typ s°üovÇho za©°zen°
;    67=s°üovÇ jmÇno nenalezeno
;    68=p©ekroáeno omezen° s°üovòch jmen
;    69=p©ekroáeno omezen° smàrñ s°üovÇho BIOS (network BIOS session limit exceeded)
;    70=p©echodnÇ pozastaven°
;    71=poëadavek pro pr†ci v siti nep©ijat
;    72=p©esmàrov†n° s°üovÇho za©°zen° pozastaveno (network print/disk redirection paused)
;    73=s°üovò software nenainstalov†n (nebo neplatn† verze)
;    74=neoáek†vanÇ uzav©en° adaptÇru (áas vypr®el)
;    75=heslo znep©°stupnàno (p©estalo bòt platnÇ)
;    76=p©°stup p©estal bòt pro toto p©ihl†®en° platnò
;    77=p©ekroáen poáet diskñ na s°üovÇm uzlu
;    78=nep©ihl†®en do s°üovÇho uzlu
;    79= (rezervov†no)
;    80=soubor jië existuje
;    81= (rezervov†no)
;    82=adres†© nelze vytvo©it
;    83=chyba na INT 24h
;    84=p©°li® mnoho p©esmàrov†n°
;    85=(zdvojenÇ) duplikovanÇ p©esmàrov†n°
;    86=neplatnÇ p©°stupovÇ heslo
;    87=neplatnò parametr
;    88=chyba s°üovÇho z†pisu
;    89=funkce nen° v s°ti podporovan†
;    90=nenainstalov†ny poëadovanÇ systÇmovÇ komponenty
;    91..99= (rezervov†no)
;   100=nezn†m† chyba CD jednotky
;   101=CD jednotka nep©ipravena
;   102=pamàü EMS pro CD jednotku nep©°stupn†
;   103=CD disk nem† platnò form†t "High Sierra" nebo "ISO-9660"
;   104=CD jednotka nen° uzav©ena
;
; BH=t©°da chyby
;     1=p©eteáen° p©esmàrov†n° (m°sto k uloëen° nebo I/O kan†l atd.)
;     2=p©echodn† situace (soubor nebo z†znam uzamáen) - zkuste po chv°li znovu
;     3=opr†vnàn° (nepovolen p©°stup)  (neopr†vnànò p©°stup) (mus° bòt vy®®° p©°stupov† pr†va)
;     4=vnit©n° (chyba systÇmovÇho software)
;     5=chyba hardware
;     6=chyba systÇmu (chyb° nebo nespr†vnò konfiguraán° soubor CONFIG.SYS)
;     7=chyba aplikaán°ho programu
;     8=nenalezen poëadovanò prvek
;     9=chybnò form†t (nerozpoznatelnò disk nebo soubor)
;    10=uzamáen (prvek vnit©nà uzamáen)
;    11=chyba mÇdia
;    12=prvek jië existuje
;    13=nezn†m† chyba
;
; BL=doporuáen† akce
;     1=opakovat
;     2=opakovat po chv°li
;     3=poë†dat uëivatele o opakov†n° vstupn°ho zad†n°
;     4=p©eru®it po £klidu (vyklizen°, uzav©en° souborñ)
;     5=okamëitÇ p©eru®en° (bez uzav°r†n° souborñ)
;     6=ignorov†n°
;     7=opakovat po uëivatelskÇm zakroáen° (napraven° z†vady)
;
; CH=zdroj chyby (za©°zen°, kterÇho se to tòk†)
;     1=nezn†mÇ nebo nevhodnÇ (nep©imà©enÇ)
;     2=blokovÇ za©°zen° (diskov† chyba)
;     3=vztaëenÇ k s°ti
;     4=sÇriovÇ za©°zen° (timeout) (znakovÇ za©°zen°)
;     5=vztaëeno k pamàti

; -----------------------------------------------------------------------------
;        chybov† hl†®en° INT 24h a DOS
; -----------------------------------------------------------------------------

ErrTxTab label     byte
         db        0                                                      ; 0
         db        34,'Poëadovan† funkce nen° podporovan†'                ; 1
         db        16,'Soubor nenalezen'                                  ; 2
         db        16,'Cesta nenalezena'                                  ; 3
         db        32,'Je otev©eno p©°li® mnoho souborñ'                  ; 4
         db        18,'Poëadavek odm°tnut'                                ; 5
         db        30,'Neplatnò identifik†tor souboru'                    ; 6
         db        30,'Po®kozena struktura pamàti DOS'                    ; 7
         db        37,'Nedostatek pamàti k proveden° operace'             ; 8
         db        32,'Neplatn† adresa pamàüovÇho bloku'                  ; 9
         db        26,'NeplatnÇ prost©ed° systÇmu'                        ; 10
         db        15,'Neplatnò form†t'                                   ; 11
         db        23,'Neplatnò p©°stupovò k¢d'                           ; 12
         db        13,'Neplatn† data'                                     ; 13
         db        0                                                      ; 14
         db        24,'P©°stup na neplatnò disk'                          ; 15
         db        35,'Pokus o zru®en° aktu†ln°ho adres†©e'               ; 16
         db        21,'Za©°zen° se neshoduje'                             ; 17
         db        20,'Nejsou dal®° soubory'                              ; 18
         db        46,'Chcete zapisovat na disk chr†nànò proti z†pisu'    ; 19
         db        38,'P©°stup na neplatnou diskovou jednotku'            ; 20
         db        42,'Diskov† jednotka nen° p©ipravena k provozu'        ; 21
         db        39,'Za©°zen° nepodporuje poëadovanou funkci'           ; 22
         db        45,'Vadnò sektor disku (chyba kontroln°ho souátu)'     ; 23
         db        44,'Chybn† dÇlka struktury poëadavku na za©°zen°'      ; 24
         db        26,'Chyba vystaven° hlav disku'                        ; 25
         db        26,'Nepodporovanò form†t disku'                        ; 26
         db        30,'Chyba disku - sektor nenalezen'                    ; 27
         db        36,'V tisk†rnà nen° pap°r, tisk zastaven'              ; 28
         db        32,'Chyba p©i z†pisu dat na za©°zen°'                  ; 29
         db        31,'Chyba p©i áten° dat ze za©°zen°'                   ; 30
ErrTxTb0 db        44,'V®eobecn†, bl°ëe nespecifikovateln† chyba '
ErrTxTb1 db        '00'                                                   ; 31
         db        24,'Poru®eno sd°len° souborñ'                          ; 32
         db        26,'Poru®eno uzamyk†n° souborñ'                        ; 33
         db        46,'Navraüte zpàt pñvodn° disk k dokonáen° operace'    ; 34
         db        32,'Nen° volnò popisovaá souborñ FCB'                  ; 35
         db        48,'P©eteáen° vyrovn†vac° pamàti pro sd°len° souborñ'  ; 36
         db        23,'Neplatn† k¢dov† str†nka'                           ; 37
         db        25,'Neoáek†vanò konec souboru'                         ; 38
         db        25,'Nedostatek m°sta na disku'                         ; 39
         db        0                                                      ; 40
         db        0                                                      ; 41
         db        0                                                      ; 42
         db        0                                                      ; 43
         db        0                                                      ; 44
         db        0                                                      ; 45
         db        0                                                      ; 46
         db        0                                                      ; 47
         db        0                                                      ; 48
         db        0                                                      ; 49
         db        29,'S°üovò poëadavek nepodporov†n'                     ; 50
         db        26,'Vzd†lenò poá°taá nep©ij°m†'                        ; 51
         db        24,'DuplikovanÇ s°üovÇ jmÇno'                          ; 52
         db        23,'S°üovÇ jmÇno nenalezeno'                           ; 53
         db        17,'S°ü zanepr†zdnàna'                                 ; 54
         db        37,'S°üovÇ za©°zen° jië nad†le neexistuje'             ; 55
         db        39,'Omezen° povelñ s°üovÇho BIOS p©ekroáeno'           ; 56
         db        32,'Chyba hardware s°üovÇho adaptÇru'                  ; 57
         db        22,'Chybn† odpovàÉ ze s°tà'                            ; 58
         db        24,'Neoáek†van† s°üov† chyba'                          ; 59
         db        38,'Nekompatibiln° vzd†lenò s°üovò adaptÇr'            ; 60
         db        22,'Tiskov† fronta je pln†'                            ; 61
         db        47,'Nedostatek diskovÇho m°sta k vytisknut° souboru'   ; 62
         db        26,'Tisknutò soubor byl zru®en'                        ; 63
         db        25,'S°üovÇ jmÇno bylo zru®eno'                         ; 64
         db        34,'Poëadavek p©°stupu na s°ü odm°tnut'                ; 65
         db        31,'Nespr†vnò typ s°üovÇho za©°zen°'                   ; 66
         db        23,'S°üovÇ jmÇno nenalezeno'                           ; 67
         db        32,'P©ekroáeno omezen° s°üovòch jmen'                  ; 68
         db        38,'P©ekroáeno omezen° smàrñ s°üovÇho BIOS'            ; 69
         db        21,'P©echodnÇ pozastaven°'                             ; 70
         db        35,'Poëadavek pro pr†ci v s°ti nep©ijat'               ; 71
         db        42,'P©esmàrov†n° s°üovÇho za©°zen° pozastaveno'        ; 72
         db        47,'S°üovò software poëadovanÇ verze nenainstalov†n'   ; 73
         db        34,'Äinnost s°üovÇho adapteru ukonáena'                ; 74
         db        36,'Platnost p©°stupovÇho hesla ukonáena'              ; 75
         db        46,'Platnost p©°stupu pro toto p©ihl†®en° ukonáena'    ; 76
         db        37,'P©ekroáen poáet diskñ na s°üovÇm uzlu'             ; 77
         db        28,'Nep©ihl†®en do s°üovÇho uzlu'                      ; 78
         db        0                                                      ; 79
         db        19,'Soubor jië existuje'                               ; 80
         db        0                                                      ; 81
         db        22,'Adres†© nelze vytvo©it'                            ; 82
         db        0    ; (chyba INT 24h)                                 ; 83
         db        25,'P©°li® mnoho p©esmàrov†n°'                         ; 84
         db        21,'ZdvojenÇ p©esmàrov†n°'                             ; 85
         db        25,'NeplatnÇ p©°stupovÇ heslo'                         ; 86
         db        17,'Neplatnò parametr'                                 ; 87
         db        21,'Chyba s°üovÇho z†pisu'                             ; 88
         db        30,'Funkce nen° v s°ti podporovan†'                    ; 89
         db        42,'Nenainstalov†ny poëadovanÇ systÇmovÇ á†sti'        ; 90
         db        0                                                      ; 91
         db        0                                                      ; 92
         db        0                                                      ; 93
         db        0                                                      ; 94
         db        0                                                      ; 95
         db        0                                                      ; 96
         db        0                                                      ; 97
         db        0                                                      ; 98
         db        0                                                      ; 99
         db        17,'Chyba CD jednotky'                                 ; 100
         db        46,'Jednotka s CD diskem nen° p©ipravena k provozu'    ; 101
         db        37,'Pamàü EMS pro CD jednotku nep©°stupn†'             ; 102
         db        44,'CD disk nem† form†t "High Sierra"/"ISO-9660"'      ; 103
         db        25,'CD jednotka nen° uzav©ena'                         ; 104

CodeInt  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Data     SEGMENT
;˛
OldBreak db        0                        ; uschovanò p©ep°naá p©eru®en°
Old1B    dd        0                        ; pñvodn° adresa INT 1Bh
Old22    dd        0                        ; pñvodn° adresa INT 22h
Old23    dd        0                        ; pñvodn° adresa INT 23h
Old24    dd        0                        ; pñvodn° adresa INT 24h

; -----------------------------------------------------------------------------
;        obsluha áasovanÇho zobrazen° rychlòch dàjñ
; -----------------------------------------------------------------------------

OldTDis  dw        0                        ; áas posledn°ho áas. zobrazen°

; -----------------------------------------------------------------------------
;        obsluha rychlovyhled†v†n°
; -----------------------------------------------------------------------------

OldTQVw  dw        0                        ; áas posledn°ho QuickView

; -----------------------------------------------------------------------------
;        obsluha nastaven° data a áasu adres†©ñ
; -----------------------------------------------------------------------------

ParA08   db        0                        ; parametry obsluhy INT 08h
                                            ;    bit 0: 1=instalov†na obsluha

                                            ;    bit 7: 1=poëadavek QuickView

; ------ uschovanò áas a datum (zachovat po©ad° poloëek !)

OldA08T  dd        0                        ; uschovanò pñvodn° áas (setiny sekundy)
OldA08D  db        0                        ; uschovanò pñvodn° den
OldA08M  db        0                        ; uschovanò pñvodn° màs°c
OldA08R  dw        0                        ; uschovanò pñvodn° rok

; ------ poëadovanò áas a datum (zachovat po©ad° poloëek !)

NewA08T  dd        0                        ; poëadovanò áas (setiny sekundy)
NewA08D  db        0                        ; poëadovanò novò den
NewA08M  db        0                        ; poëadovanò novò màs°c
NewA08R  dw        0                        ; poëadovanò novò rok

; -----------------------------------------------------------------------------
;        p©ep°naáe
; -----------------------------------------------------------------------------

ParInt24 db        0                        ; parametry obsluhy chyb INT 24h
                                            ;    bit 0: 1=INT 24h se ignoruje
                                            ;    bit 1: 1=p©eru®en° BREAK
                                            ;    bit 2: 1=p©eru®en° ESC
                                            ;    bit 3: 1=z†kaz DOS bàhem INT 24
                                            ;    bit 4: 1=chyby se ignoruj°
                                            ;    bit 5: 1=zobrazen° bàhem INT 24
                                            ;    bit 6: 1=z†kaz p©eru®en° funkc°
                                            ;             (kritick† sekce)

; -----------------------------------------------------------------------------
;        volba obsluhy chyby INT 24h
; -----------------------------------------------------------------------------

Int24Mnu label     byte                    ;* menu obsluhy INT 24h
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        3                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        I24MnPol                 ; adresa definián° tabulky poloëek
         dw        I24MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Main                 ; á°slo str†nky velkÇ n†povàdy
         dw        I24MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        I24MnTit                 ; adresa titulu okna
         dw        I24MnExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        15                       ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        56                       ; ®°©ka
         db        9                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        HistSel                  ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

I24MnPol db        bit6,10,0,'Chyba ',1
I24MnPl3 dw        I24MnPl6
         db        bit6,7,3
I24MnPl1 db        0
I24MnPl2 dd        0
         db        '.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,8,'Opakovat'
         db        1,8,'P©eru®it'
         db        1,9,'Ignorovat'

I24MnPl6 db        8,'za©°zen°'
I24MnPl7 db        8,'disku '
I24MnPl8 db        'A:'

I24MnBlk db        0,0,0

I24MnTit db        14,'chyba za©°zen°'

HelpS    SEGMENT   BYTE PUBLIC
I24MnHlp db        17,'Opakov†n° operace'
         db        27,'P©eru®en° prov†dànÇ operace'
         db        16,'Ignorov†n° chyby'
HelpS    ENDS

I24MnExe label     dword                    ; tabulka obsluh menu
         dd        Int247                   ; opakovat
         dd        Int247                   ; p©eru®it
         dd        Int247                   ; ignorovat

Data     ENDS

         END

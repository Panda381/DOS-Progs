
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                               T E T R I X
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


Code     SEGMENT
         ASSUME    cs:Code,ds:Data

;DEBUG    EQU       1

TopVRAM  EQU       15*80+40-2*5             ; poá†teán° offset pole ve VRAM

; ------ vzorky pro kontrolu Debuggeru

;TabDeb   label     word
;         dw        100h                     ; SYMDEB
;         db        'SEGDEB'
;
;         dw        104h                     ; DEBUG 2.3
;         db        'rs 2.3'
;
;         dw        104h                     ; DEBUG 2.4
;         db        'rs 2.4'
;
;         dw        2611h
;         db        'DWORD '
;
;         dw        0b298h                   ; nàkterò TD
;         db        'CREEN '
;
;         dw        1e40h                    ; AFDPRO V1.0
;         db        'AFDPRO'
;
;         dw        0                        ; TD 1.00 aë 2.01
;         db        50h,6,1eh,33h,0c0h,8eh
;
;         dw        0                        ; SYMDEB
;         db        2eh,0c7h,6,71h,6dh,2eh
;
;         dw        0                        ; DEBUG
;         db        8ch,0c8h,8eh,0d8h,0fah,8eh
;
;         dw        -1
;
; *****************************************************************************
;                         Start programu
; -----------------------------------------------------------------------------
; *****************************************************************************

; ------ inicializace segmentñ

Start:   mov       ax,SEG Data
         mov       ds,ax                    ; datovò segment
         mov       ds:[SegPSP],es           ; segment PSP

;; ------ detekce p©°tomnosti debuggeru
;
;IfNDef   DEBUG
;
;         mov       dx,es:[0eh]              ; offset obsluhy INT 23h
;         mov       es,es:[10h]              ; segment obsluhy INT 23h
;         mov       bx,offset TabDeb         ; tabulka definic pro Debugger
;         cld
;         cli                                ; p©eru®en° zak†z†no
;         push      ds
;         push      cs
;         pop       ds
;TestDeb1:mov       si,bx                    ; adresa definice v tabulce
;         lodsw                              ; adresa identifikace debuggeru
;         cmp       ax,-1                    ; je konec tabulky ?
;         je        TestDeb3                 ; je konec tabulky
;         mov       di,ax                    ; adresa v debuggeru
;         or        ax,ax
;         jnz       TestDeb4
;         mov       di,dx                    ; adresa INT 23h
;TestDeb4:mov       cx,6                     ; poáet bajtñ ke kontrole
;         repe      cmpsb                    ; porovn†n° se vzorkem
;TestDeb2:je        TestDeb2                 ; zacyklen° programu
;         add       bx,8                     ; dal®° vzorek v tabulce
;         jmp       short TestDeb1           ; kontrola dal®°ho vzorku
;
;TestDeb3:pop       ds
;
;EndIf
         sti

;; ------ vymaz†n° £vodn° á†sti programu
;
;         push      ds
;         push      cs
;         pop       es
;         push      cs
;         pop       ds

         mov       ah,0fh

;         mov       si,offset RolTxt + 10
;         xor       di,di                    ; zaá†tek k vymaz†n°
;         mov       cx,offset MazX1
;         cld
;         rep       movsb                    ; vymaz†n° programu
;MazX1:   pop       ds

; ------ £schova aktivn°ho videom¢du

         int       10h                      ; poskytnut° aktivn°ho videom¢du
         mov       ds:[OldVMod],al          ; aktivn° videom¢d

; ------ test, zda je grafick† karta EGA/VGA

         mov       ah,12h                   ; funkce poskytnut° informac° EGA
         mov       bx,5810h                 ; podsluëba informac° o EGA
         int       10h                      ; poskytnut° informac° o EGA
         cmp       bh,2
         ja        Start2                   ; nen° karta EGA/VGA
         cmp       bl,5
         ja        Start2                   ; nen° karta EGA/VGA

; ------ nastaven° pracovn°ho grafickÇho m¢du

         mov       ax,16                    ; poëadovanò videom¢d 16
         int       10h                      ; nastaven° videom¢du 16
         mov       ah,0fh
         int       10h                      ; poskytnut° aktivn°ho videom¢du
         cmp       al,16                    ; je poëadovanò videom¢d ?
         je        Start3                   ; videom¢d nastaven OK

; ------ chyba - nen° grafick† karta EGA/VGA

Start2:  mov       ah,0fh
         int       10h
         cmp       al,7
         jne       Start21

         mov       byte ptr ds:[ParHerc],1
         mov       ax,7
         int       10h
         call      InitHerc
         jmp       short Start3

Start21: mov       dx,offset ErrCard        ; chybovò text - nen° EGA/VGA
         mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
         mov       ax,4c01h                 ; funkce n†vratu z programu
         int       21h                      ; n†vrat z programu

; ------ inicializace hodin

Start3:  call      CekInit                  ; inicializace hodin
         call      InitRnd                  ; inicializace gener†toru n†hody
         call      InitSoub                 ; inicializace jmÇna souboru
         call      CtiSoub                  ; naáten° souboru sk¢re

; ------ obsluha p©eru®en° INT 23h a INT 1Bh

         mov       ax,351bh
         int       21h
         mov       word ptr ds:[Old1b],bx
         mov       word ptr ds:[Old1b+2],es ; £schova adresy INT 1bh

         push      ds
         push      cs
         pop       ds
         mov       dx,offset Int23
         mov       ax,2523h
         int       21h                      ; instalace obsluhy INT 23h
         mov       dx,offset Int23
         mov       ax,251bh
         int       21h                      ; instalace obsluhy INT 1Bh

; ------ instalace obsluhy p©eru®en° INT 24h

         mov       dx,offset Int24
         mov       ax,2524h
         int       21h                      ; instalace obsluhy INT 24h
         pop       ds


         mov       si,offset Pal5           ; £plnà temnò displej
         call      SetPal                   ; nastaven° palet

;; ------ vymaz†n° podprogramu pro áten° souboru
;
;         push      ds
;         push      cs
;         pop       ds
;         push      cs
;         pop       es
;         mov       si,offset Demo+5
;         mov       di,offset CtiSZac
;         mov       cx,offset(CtiSKon-CtiSZac)
;         cld
;         rep       movsb
;
;; ------ vymaz†n° £vodn° á†sti
;
;         mov       di,offset MazX1
;         mov       cx,offset(MazX2-MazX1)
;         rep       movsb
;MazX2:   pop       ds

; ------ inicializace hrac° plochy - nov† hra

NovaHra:
         call      CekInit                  ; inicializace hodin
         call      Podklad
         call      DispRam
         call      InitNova
         call      DispList

         mov       byte ptr ds:[ParHra],0   ; nen° hra
         mov       byte ptr ds:[Pristi],0   ; p©°znak zobrazen° p©°®t° cihly
         call      DispNext                 ; zobrazen° z†clony

         call      Rozsvit

NovaHra1:
         mov       byte ptr ds:[DemPar],0   ; nen° demo
         call      DispHlp
         mov       cx,6
         mov       di,9*80+6*32*80+4 + 3*14*80 - 80
         mov       si,offset TextHlp5
         call      DispTxt

; ------ vstup znaku

Nova010: push      ds
         xor       ax,ax
         mov       ds,ax
         mov       bp,ds:[46ch]
         pop       ds

Nova0101:call      TestKey
         jnc       Nova0102

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         pop       ds
         sub       ax,bp
         cmp       ax,545                   ; áek† se 1/2 minuty
         jb        Nova0101
         jmp       short Nova0105

Nova0102:
         xor       ax,ax
         int       16h
         or        ax,ax
         jz        nova00
         cmp       al,27
         je        nova00
         mov       byte ptr ds:[ParHra],0   ; nen° hra

; ------ demonstrace

         cmp       al,"d"
         je        Nova0105
         cmp       al,"D"
         jne       Nova0106

Nova0105:call      Demo                     ; demonstrace
         jmp       short NovaHra1

Nova0106:cmp       al,13
         je        Nova011
         cmp       al," "
         je        Nova011

         cmp       al,"0"
         jb        Nova012
         cmp       al,"9"
         ja        Nova012

         sub       al,"0"
         mov       ds:[Uroven],al
         call      DispSkor
         jmp       short Nova011

; ------ zad†n° novÇho hr†áe

Nova012: cmp       al,"N"
         je        Nova013
         cmp       al,"n"
         jne       Nova014
Nova013: call      NovyH                    ; zad†n° novÇho hr†áe
         jmp       short NovaHra1

; ------ volba jinÇho hr†áe

Nova014: cmp       al,"H"
         je        Nova015
         cmp       al,"h"
         jne       Nova016
Nova015: call      VolHrac
         jmp       NovaHra1

Nova016: cmp       al,"Z"
         je        Nova017
         cmp       al,"z"
         jne       Nova018
Nova017: call      ZrusHr
         jmp       NovaHra1

Nova018:
         jmp       Nova010


Nova00:  jmp       s8

Nova011:
         call      GenCih
         call      GenCih                   ; generov†n° prvn° cihly
         call      IncCit                   ; zvò®en° á°taáe cihel
         call      DispCit                  ; zobrazen° á°taáe cihel
         call      DispPole

         call      DispHlpZ                 ; zobrazen° n†povàdy

         jmp       short s001

; ------ zaá†tek generov†n° jednÇ cihly

s0:      call      CekInit                  ; inicializace hodin
         call      GenCih                   ; generov†n° p©°®t° cihly
         call      IncCit                   ; zvò®en° á°taáe cihel
         call      DispCit                  ; zobrazen° á°taáe cihel

; ------ kontrola, zda je konec hry

         mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       dl,ds:[PozCih]           ; pozice cihly v poli
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         call      TestCih                  ; test novÇ cihly
         jnc       s001                     ; je je®tà moën†
         jmp       skonec                   ; konec hry

s001:
         mov       byte ptr ds:[ParHra],1   ; je hra
         call      DispNext                 ; zobrazen° p©°®t° cihly
         mov       byte ptr ds:[Padani],0   ; zru®en° p©°znaku pad†n°

         xor       bx,bx
         mov       bl,ds:[Uroven]
         mov       bl,ds:[bx+TabBod]        ; body

;         mov       al,8
;         mul       byte ptr ds:[Uroven]
;         inc       ax

         mov       word ptr ds:[Body],bx
         cmp       byte ptr ds:[Pristi],0
         je        s1
         sub       word ptr ds:[Body],5
         jnc       s1
         mov       word ptr ds:[Body],0

; ------ cyklus obsluhy jednÇ cihly - pomalÇ pad†n°

s1:      call      DispAkt                  ; zobrazen° aktivn° cihly

; ------ nastaven° rychlosti pad†n° cihly

;         mov       bx,80                    ; prodleva z†visl† na £rovni
         xor       cx,cx
         mov       cl,10
         sub       cl,ds:[Uroven]
         mov       bx,20
s101:    mov       ax,bx
         shr       ax,1
         shr       ax,1
         add       bx,ax
         shr       ax,1
         add       bx,ax
         loop      s101

; ------ áek†n° na stisk kl†vesy

s2:      mov       cx,2
         call      Cekej                    ; definovan† prodleva
s200:    call      TestKey                  ; test, zda byla kl†vesa
         jnc       s201                     ; je kl†vesa
         jmp       s3                       ; nebyla ë†dn† kl†vesa

; ------ vstup znaku z kl†vesnice

s201:    mov       ah,0
         int       16h                      ; vstup znaku z kl†vesnice
         mov       dl,ds:[PozCih]           ; pozice cihly v poli
         mov       dh,ds:[Cihla]            ; aktivn° cihla
         mov       di,ds:[AdrCih]           ; adresa ve videopamàti

; ------ p©eru®en° hry

         or        ax,ax
         jz        s20                      ; p©eru®en° Ctrl-Break
         cmp       al,27
         jne       s21                      ; nen° p©eru®en° Esc

; ------ dotaz na p©eru®en° hry

s20:     call      DispHlp
         mov       cx,4                     ; poáet ©†dkñ zbytku textu
         mov       di,9*80+6*32*80+7 + 8*80 + 3*14*80
         mov       si,offset TextHlpA
         call      DispTxt                  ; zobrazen° zbytku n†povàdy

s2002:   call      TestKey
         jc        s2003
         mov       ah,0
         int       16h
         jmp       short s2002

s2003:
         mov       ah,0
         int       16h

         cmp       al,"A"
         je        s2006
         cmp       al,"a"
         je        s2006

         call      DispHlpZ                 ; zobrazen° n†povàdy

s2004:   call      TestKey
         jc        s2005
         mov       ah,0
         int       16h
         jmp       short s2004
s2005:
         jmp       s3

s2006:   jmp       Prerus

; ------ posun cihly vlevo

s21:     cmp       al,"4"
         je        s211
         cmp       ah,4bh
         jne       s22                      ; nen° kurzor vlevo
s211:    dec       di
         dec       di
         dec       dl                       ; sn°ëen° pozice
s29x:    jmp       s29

; ------ posun cihly vpravo

s22:     cmp       al,"6"
         je        s221
         cmp       ah,4dh
         jne       s23                      ; nen° kurzor vpravo
s221:    inc       di
         inc       di
         inc       dl
         jmp       short s29x

; ------ rotace cihly

s23:     cmp       al,13
         je        s232
         cmp       al,"5"
         je        s232
         cmp       al,"8"
         je        s232
         cmp       ah,48h
         je        s232
         cmp       ah,4ch
         jne       s24                      ; nen° rotace cihly

s232:    mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       dl,ds:[PozCih]           ; pozice cihly
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         mov       di,ds:[AdrCih]           ; adresa cihly ve videopamàti
         call      Rotace                   ; proveden° rotace cihly
         jmp       short s292               ; test vòsledku operace

; ------ pad†n° cihly

s24:     cmp       al,"2"
         je        s242
         cmp       ah,50h
         je        s242
         cmp       al," "
         jne       s25
s242:    inc       byte ptr ds:[Padani]     ; p©°znak pad†n°
         jmp       short s3

; ------ zobrazen° p©°®t° cihly

s25:     cmp       al,"1"
         je        s252
         cmp       ah,4fh                   ; END 1
         jne       s26
s252:    call      NextXchg
         jmp       short s3

; ------ zvò®en° rychlosti

s26:     cmp       al,"9"
         je        s262
         cmp       ah,49h                   ; Page Up
         jne       s27

s262:    cmp       byte ptr ds:[Uroven],9
         je        s27
         inc       byte ptr ds:[Uroven]
         call      DispSkor

; ------ sn°ëen° rychlosti

s27:     cmp       al,"3"
         je        s272
         cmp       ah,51h                   ; Page Down
         jne       s28

s272:    cmp       byte ptr ds:[Uroven],0
         je        s28
         dec       byte ptr ds:[Uroven]
         call      DispSkor


s28:     cmp       al,"S"
         je        s282
         cmp       al,"s"
         jne       s284
s282:    xor       byte ptr ds:[Sound],1
         mov       al,235
         jnz       s283                     ; je zapnut
         mov       al,236                   ; je vypnut
s283:    mov       ds:[SoundChr],al
         call      DispHlpZ
         jmp       short s3

s284:
         jmp       short s3

s29:     mov       al,dh                    ; cihla
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         call      TestCih                  ; test pozice cihly
s292:    jc        s2a                      ; nepovolen† pozice cihly
         call      MazAkt                   ; vymaz†n° aktivn° cihly
         mov       ds:[RadCih],dh           ; novò ©†dek cihly
         mov       ds:[PozCih],dl           ; pozice cihly
         mov       ds:[Cihla],al            ; nov† aktivn° cihla
         mov       ds:[AdrCih],di           ; nov† adresa cihly
         call      DispAkt                  ; novÇ zobrazen° aktivn° cihly
s2a:     jmp       s200

s3:      cmp       byte ptr ds:[Padani],0   ; je p†d cihly ?
         jne       s4                       ; je p†d cihly
         dec       bx                       ; sn°ëen° á°taáe prodlevy
         jz        s4
         jmp       s2                       ; dal®° áek†n°

; ------ cihla se posune o jednu £rove§ n°ëe

s4:
         mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       dl,ds:[PozCih]           ; pozice cihly v poli
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         mov       di,ds:[AdrCih]           ; adresa ve videopamàti
         add       di,80*16
         inc       dh
         call      TestCih                  ; test novÇ pozice cihly
         jc        s5                       ; nepovolen† pozice cihly

         call      MazAkt                   ; vymaz†n° aktivn° cihly
         mov       ds:[AdrCih],di           ; nov† adresa cihly
         mov       ds:[RadCih],dh           ; novò ©†dek cihly

         cmp       byte ptr ds:[Padani],0
         jne       s43

         dec       word ptr ds:[Body]
         jns       s43
         mov       word ptr ds:[Body],0

s43:     jmp       s1

; ------ p©i dosedu je®tà chv°li áek†

s5:      cmp       byte ptr ds:[Padani],0
         jne       s52                      ; padala - neáek† se
         mov       bx,12
s51:     call      TestKey
         jnc       s53                      ; bude je®tà obsluha
         mov       cx,20
         call      Cekej                    ; chv°li prodleva
         dec       bx
         jnz       s51
         jmp       short s52

s53:     mov       bx,1
         jmp       s200                     ; obsluha kl†vesy

; ------ cihla dopadla - uloëen° do pole

s52:
         mov       ax,ds:[Body]
         add       word ptr ds:[Skore],ax
         adc       word ptr ds:[Skore+2],0
         call      DispSkor

         call      UlozCih                  ; uloëen° cihly do pole
         mov       cx,120
         call      Cekej                    ; p©°davn† prodleva

s66:     call      TestKey
         jc        s67
         mov       ah,0
         int       16h
;         or        ax,ax
;         jz        s672
;         cmp       al,27
;         je        s672
         jmp       short s66

s67:

         jmp       s0


;s672:    jmp       s8

; ------ konec hry

SKonec:
         call      UlozSkor                 ; uloëen° sk¢re do tabulky
         mov       byte ptr ds:[ParHra],0   ; nen° hra

         mov       cx,4
         mov       bx,570
         call      Ton
         call      Cekej
         mov       bx,761
         call      Ton
         call      Cekej
         mov       bx,905
         call      Ton
         call      Cekej
         mov       bx,1140
         call      Ton
         call      Cekej
         mov       bx,1522
         call      Ton
         call      Cekej
         mov       bx,1810
         call      Ton
         call      Cekej
         mov       bx,2280
         call      Ton
         call      Cekej
         call      TonOff

; ------ zobrazen° podkladu hl†®en° konce hry

         mov       di,TopVRAM+146*80+9+9*80
         mov       cx,1*2
         mov       bx,5*2
         mov       ah,15
         mov       si,10
SKonec1: call      DispBox
         push      cx
         mov       cx,20
         call      Cekej
         pop       cx
         sub       di,1+80
         inc       cx
         inc       cx
         inc       bx
         inc       bx
         dec       si
         jnz       SKonec1


         call      DispHlp
         mov       si,offset TextHlp3
         mov       di,9*80+6*32*80+4 + 4*80 + 4*14*80
         mov       cx,3
         call      DispTxt

SKonec11:call      TestKey
         jc        SKonec12

         xor       ax,ax
         int       16h
;         or        ax,ax
;         jz        s8
;         cmp       al,27
;         je        s8
         jmp       short SKonec11

SKonec12:

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       bp,ds:[46ch]             ; hodiny
         pop       ds

         mov       bx,0

SKonec2:
         mov       al,ds:[bx+ColKon]
         mov       byte ptr ds:[TextKon],al
         inc       bx
         and       bx,7

         mov       si,offset TextKon
         mov       cx,1
         mov       di,TopVRAM+146*80+7*80
         call      DispTxt

         mov       cx,100
         call      Cekej

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         pop       ds
         sub       ax,bp
         cmp       ax,545                   ; áek† se 1/2 minuty
         jae       SKonec55

         call      TestKey
         jc        SKonec2


SKonec5:
         xor       ax,ax
         int       16h
;         or        ax,ax
;         jz        s8
;         cmp       al,27
;         je        s8

Skonec55:call      TestKey
         jnc       SKonec5

; ------ p©eru®en° hry ESC

Prerus:
         mov       byte ptr ds:[ParHra],0   ; nen° hra
         call      UlozSkor                 ; uloëen° sk¢re do tabulky
         call      DispNext                 ; zobrazen° z†clony
         call      InitNova

         jmp       NovaHra1


s8:

; ------ konec - n†vrat z programu

Navrat:  mov       ax,SEG Data
         mov       ds,ax                    ; datovò segment
         call      Ztemni

; ------ n†vrat pñvodn°ho videom¢du

         mov       al,ds:[OldVMod]          ; pñvodn° vidoem¢d
         xor       ah,ah
         int       10h                      ; nastaven° pñvodn°ho videom¢du

; ------ n†vrat obsluhy INT 1Bh

         push      ds
         lds       dx,ds:[Old1b]
         mov       ax,251bh
         int       21h
         pop       ds

; ------ konec programu

         call      TonOff                   ; vypnut° zvukovÇho gener†toru
         mov       ax,4c00h
         int       21h                      ; n†vrat z programu

; -----------------------------------------------------------------------------
;        zobrazen° n†povàdy p©i h©e
; -----------------------------------------------------------------------------

DispHlpZ PROC      NEAR

         push      cx
         push      si
         push      di

         call      DispHlp
         mov       cx,1                     ; poáet ©†dkñ zbytku textu
         mov       di,9*80+6*32*80+4 + 6*80 + 3*14*80
         mov       si,offset TextHlp1
         call      DispTxt                  ; zobrazen° zbytku n†povàdy
         add       di,25*80
         call      DispTxt
         add       di,25*80
         call      DispTxt

         pop       di
         pop       si
         pop       cx
         ret

DispHlpZ ENDP

; *****************************************************************************
;
;                              Demonstrace
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        demonstrace programu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
; neuchov†v† registry
; -----------------------------------------------------------------------------

Demo     PROC      NEAR

         mov       byte ptr ds:[DemPar],1   ; p©°znak demonstrace
         mov       byte ptr ds:[ParHra],1   ; je hra

; ------ £schova nastaven°

         mov       al,ds:[Uroven]
         mov       ah,ds:[Pristi]
         push      ax
         mov       byte ptr ds:[Pristi],1
         mov       byte ptr ds:[Uroven],5
;         call      DispNext
         call      DispSkor

; ------ zobrazen° n†povàdy

         call      DispHlp
         mov       cx,4
         mov       di,9*80+6*32*80+4 + 4*14*80 + 4 - 3*80
         mov       si,offset TextHlp8
         call      DispTxt

;; ------ vytvo©en° okna pro reklamu
;
;         mov       ah,4
;         mov       bh,1
;         mov       cx,5
;         mov       di,9*80+5*32*80+56
;         call      DispPod                  ; zobrazen° z†kladn°ho podkladu
;         add       di,10*80+3
;         mov       si,offset Nadp1
;         mov       cx,1
;         call      DispTxt
;         sub       di,4*80+1
;         call      DispTxt
;
;         mov       di,9*80+6*32*80+56
;         mov       bx,4*32
;         mov       cx,5*4
;         mov       ah,7
;         call      DispBox
;
;         mov       word ptr ds:[UkazTxt],offset Text
;         mov       word ptr ds:[LinkaTxt],0

; ------ zaá†tek novÇ hry

Demo1:   call      InitNova                 ; inicializace novÇ hry
         call      GenCih                   ; generov†n° prvn° cihly

; ------ test, zda je p©eru®en° demonstrace

Demo2:   call      TestKey
         jc        Demo22
         jmp       Demo9                    ; je nàjak† kl†vesa

; ------ vygenerov†n° novÇ cihly

Demo22:
;         call      Reklama
         call      CekInit                  ; inicializace hodin
         call      GenCih                   ; generov†n° p©°®t° cihly
         call      IncCit                   ; zvò®en° á°taáe cihel
         call      DispCit                  ; zobrazen° á°taáe cihel
;         call      Reklama
         mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       dl,ds:[PozCih]           ; pozice cihly v poli
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         call      TestCih                  ; test novÇ cihly
         jc        Demo1                    ; konec hry - nov† hra
         call      DispNext                 ; zobrazen° p©°®t° cihly
         call      DispAkt                  ; zobrazen° aktivn° cihly

         mov       bl,6
Demo25:  mov       cx,15
         call      Cekej
;         call      Reklama
         dec       bl
         jnz       Demo25

;         mov       cx,160
;         call      Cekej

; ------ p©°prava ukazatelñ

         mov       word ptr ds:[DemBod],-10000 ; bodov†n° ®patnÇ
         mov       byte ptr ds:[DemRot],0   ; nen° ë†dn† rotace

Demo30:  mov       ds:[DemCih],al           ; á°slo testovanÇ cihly
         mov       ds:[DemRad],dh           ; ©†dek s cihlou

; ------ nalezen° levÇ polohy kamene p©i jednÇ rotaci

Demo3:   mov       al,ds:[DemCih]           ; testovan† cihla
         mov       dl,ds:[PozCih]           ; vòchoz° pozice cihly
         mov       dh,ds:[DemRad]           ; vòchoz° ©†dek cihly
Demo31:  dec       dl                       ; sn°ëen° pozice na ©†dku
         call      TestCih                  ; test cihly
         jnc       Demo31                   ; pozice je OK - dal®° pozice
         inc       dl                       ; n†vrat pozice
         mov       ds:[DemPoz],dl           ; testovan† pozice kamene

; ------ nalezen° nejnië®°ho ©†dku testovanÇ cihly

Demo4:   mov       al,ds:[DemCih]           ; testovan† cihla
         mov       dl,ds:[DemPoz]           ; testovan† pozice
         mov       dh,ds:[DemRad]           ; vòchoz° ©†dek cihly
Demo41:  inc       dh                       ; zvò®en° á°sla ©†dku
         call      TestCih                  ; test novÇ pozice cihly
         jnc       Demo41                   ; test dal®°ho ©†dku
         dec       dh                       ; dopadovò ©†dek

; ------ obodov†n° dosaëenÇho stavu

         call      DemBody                  ; obodov†n° dosaëenÇho vòsledku

; ------ p©i lep®°m vòsledku uloëen° sk¢re

         cmp       bx,ds:[DemBod]           ; je lep®° bodov†n° ?
         jl        Demo53                   ; je hor®° bodov†n°
         jg        Demo52                   ; je lep®° bodov†n°

         push      ax
         push      dx
         call      Random0                  ; generov†n° n†hodnÇho á°sla
         test      dx,3                     ; n†hoda - zvol° se ?
         pop       dx
         pop       ax
         jnz       Demo53                   ; nepouëije se nov† pozice

Demo52:  mov       ds:[DemBod],bx           ; bodov†n° novÇ pozice
         mov       dl,ds:[DemPoz]           ; testovan† pozice
         mov       ds:[DemPoz0],dl          ; nejlep®° pozice
         mov       bl,ds:[DemRot]           ; rotov†n° testovanÇ pozice
         mov       ds:[DemRot0],bl          ; rotov†n° nejlep®° pozice

Demo53:

; ------ posun kamene na novou testovanou pozici

         mov       al,ds:[DemCih]           ; testovan† cihla
         mov       dl,ds:[DemPoz]           ; testovan† pozice
         mov       dh,ds:[DemRad]           ; vòchoz° ©†dek cihly
         inc       dl                       ; zvò®en° pozice cihly
         call      TestCih                  ; test novÇ pozice cihly
         jc        Demo6                    ; nen° dal®° pozice na ©†dku
         mov       ds:[DemPoz],dl           ; nov† testovan† pozice
         jmp       short Demo4              ; test novÇ pozice cihly

; ------ rotace cihly pro dal®° test

Demo6:   inc       byte ptr ds:[DemRot]     ; zvò®en° á°taáe rotac°
         xor       bx,bx
         mov       bl,ds:[DemCih]           ; testovan† cihla
         mov       bl,ds:[MaxRot+bx]        ; maxim†ln° poáet rotac°
         cmp       bl,ds:[DemRot]           ; jsou jië v®echny rotace ?
         jbe       Demo8                    ; jsou jië v®echny rotace

         mov       dl,ds:[PozCih]           ; vòchoz° pozice cihly v poli
         mov       dh,ds:[RadCih]           ; vòchoz° ©†dek cihly
         mov       al,ds:[Cihla]            ; aktivn° cihla
         xor       cx,cx
         mov       cl,ds:[DemRot]           ; aktivn° poáet rotac°
         mov       di,ds:[AdrCih]           ; adresa ve videopamàti
Demo7:   call      Rotace                   ; proveden° jednÇ rotace
         loop      Demo7                    ; proveden° dal®° rotace cihly
         jc        Demo8
         jmp       Demo30                   ; dal®° test

; ------ posuny a pad†n° cihly

Demo8:   call      DemoRot                  ; proveden° rotac° cihly
         call      DemoPoz                  ; nastaven° cihly na nejlep®° pozici
         call      DemoPad                  ; p†d cihly p©i demonstraci
         call      DemoSkor                 ; sk¢re p©i demonstraci
         call      UlozCih                  ; uloëen° cihly do pole
         jmp       Demo2                    ; generov†n° novÇ cihly

; ------ inicializace hrac° plochy

Demo9:   xor       ax,ax
         int       16h

         call      TestKey
         jnc       Demo9

         pop       ax
         mov       ds:[Uroven],al
         mov       ds:[Pristi],ah

         call      InitNova                 ; inicializace novÇ hry
         mov       byte ptr ds:[ParHra],0   ; nen° hra
         call      DispNext
         call      DispSkor
         call      DispList
         mov       byte ptr ds:[DemPar],0   ; zru®en° p©°znaku demonstrace
         ret

Demo     ENDP

; -----------------------------------------------------------------------------
;        ohodnocen° dosaëenÇ pozice cihly (BX)
; -----------------------------------------------------------------------------

DemBody  PROC      NEAR

; ------ stanoven° adresy definice cihly

         mov       ah,16                    ; poáet bajtñ na cihlu
         mul       ah                       ; offset v tabulce
         add       ax,offset TabCih         ; adresa definice cihly
         mov       si,ax                    ; adresa definice cihly

; ------ vòpoáet bodov†n°

         xor       bx,bx                    ; st©adaá bodovÇho hodnocen°
         mov       ch,4                     ; poáet ©†dkñ
DemBody1:mov       cl,4                     ; poáet kamenñ na ©†dek
DemBody2:cld
         lodsb                              ; bajt definice cihly
         or        al,al                    ; je to platnò k†men ?
         jz        DemBody7                 ; nen° to platnò k†men

; ------ p©iáten° ©†dku kamene

         mov       al,dh
         xor       ah,ah
         shl       ax,1
         shl       ax,1
         shl       ax,1
         add       bx,ax

; ------ adresa v poli

         mov       al,10                    ; poáet bajtñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0                     ; p©enos
         add       ax,offset Pole
         mov       di,ax                    ; adresa v tabulce pole

; ------ test, zda n†sleduje k†men tÇto cihly

         cmp       ch,1                     ; je to posledn° ©†dek ?
         je        Dembody3                 ; nen° dal®° vlastn° k†men
         cmp       byte ptr ds:[si+3],0     ; bude dal®° vlastn° k†men ?
         jne       DemBody4                 ; je dal®° vlastn° k†men

; ------ test, zda n†sleduje dal®° k†men v poli

DemBody3:cmp       dh,19                    ; je to posledn° ©†dek ?
         je        DemBody4                 ; je to posledn° ©†dek
         cmp       byte ptr ds:[di+10],0    ; n†sleduje k†men ?
         jne       DemBody4                 ; nen†sleduje k†men - OK
         sub       bx,40                    ; sr†ëka bodñ za vzniklou d°ru
;         cmp       dh,18
;         je        DemBody4
;         cmp       byte ptr ds:[di+20],0
;         jne       DemBody4
;         sub       bx,25

; ------ test, zda je k†men vlevo

DemBody4:cmp       cl,4
         je        Dembod51
         cmp       byte ptr ds:[si-2],0
         jne       DemBod52
Dembod51:cmp       dl,0
         je        DemBod52
         cmp       byte ptr ds:[di-1],0
         jne       DemBod52
         sub       bx,6

; ------ test, zda je k†men vpravo

DemBod52:cmp       cl,1
         je        Dembod53
         cmp       byte ptr ds:[si],0
         jne       Dembod54
DemBod53:cmp       dl,9
         je        DemBod54
         cmp       byte ptr ds:[di+1],0
         jne       DemBod54
         sub       bx,6
DemBod54:

; ------ test dal®°ho kamene

DemBody7:inc       dl                       ; zvò®en° pozice na ©†dku
         dec       cl                       ; sn°ëen° á°taáe pozic
         jnz       DemBody2                 ; test dal®°ho kamene na ©†dku
         sub       dl,4                     ; n†vrat pozice
         inc       dh                       ; zvò®en° á°sla ©†dku
         dec       ch                       ; sn°ëen° á°taáe ©†dkñ
         jz        DemBody8

         jmp       DemBody1                 ; test dal®°ho ©†dku

DemBody8:
         ret

DemBody  ENDP

; -----------------------------------------------------------------------------
;        proveden° rotac° cihly p©i demonstraci
; -----------------------------------------------------------------------------

DemoRot  PROC      NEAR

         cmp       byte ptr ds:[DemRot0],0  ; je dal®° rotace ?
         je        DemoRot4                 ; nen° dal®° rotace

DemoRot2:mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       dl,ds:[PozCih]           ; souáasn† pozice cihly
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         mov       di,ds:[AdrCih]           ; adresa ve videopamàti
         call      Rotace                   ; proveden° rotace cihly
         jc        DemoRot4                 ; rotaci nelze provÇst

;         call      Reklama

         call      MazAkt                   ; vymaz†n° aktivn° cihly
         mov       ds:[Cihla],al            ; nov† aktivn° cihla
         mov       ds:[PozCih],dl           ; nov† pozice
         mov       ds:[RadCih],dh           ; novò ©†dek
         mov       ds:[AdrCih],di           ; nov† adresa ve videopamàti
         call      DispAkt                  ; novÇ zobrazen° aktivn° cihly

         call      TestKey
         jnc       DemoRot4

;         mov       cx,60
;         call      Cekej

         mov       bl,4
DemoRot5:mov       cx,15
         call      Cekej
;         call      Reklama
         dec       bl
         jnz       DemoRot5


         dec       byte ptr ds:[DemRot0]    ; sn°ëen° á°taáe rotac°
         jnz       DemoRot2                 ; dal®° rotace

DemoRot4:ret

DemoRot  ENDP

; -----------------------------------------------------------------------------
;        nastaven° pozice cihly p©i demonstraci
; -----------------------------------------------------------------------------

DemoPoz  PROC      NEAR

; ------ posun cihly na nalezenou nejlep®° pozici

DemoPoz1:mov       dl,ds:[PozCih]           ; souáasn† pozice cihly
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       di,ds:[AdrCih]           ; adresa ve videopamàti
         cmp       dl,ds:[DemPoz0]          ; dosaëeno poëadovanÇ pozice ?
         je        DemoPoz4                 ; dosaëeno poëadovanÇ pozice
         jl        DemoPoz2                 ; je posun vpravo

; ------ posun cihly o krok vlevo

         dec       dl                       ; sn°ëen° pozice
         dec       di
         dec       di                       ; sn°ëen° adresy cihly
         jmp       short DemoPoz3           ; zobrazen° cihly

; ------ posun cihly o krok vpravo

DemoPoz2:inc       dl                       ; zvò®en° pozice
         inc       di
         inc       di                       ; zvò®en° adresy cihly

; ------ proveden° kroku cihly s testem

DemoPoz3:call      TestCih                  ; test novÇ pozice cihly
         jc        DemoPoz4                 ; nepovolen† pozice cihly
;         call      Reklama
         call      MazAkt                   ; vymaz†n° aktivn° cihly
         mov       ds:[PozCih],dl           ; nov† pozice cihly
         mov       ds:[AdrCih],di           ; nov† adresa cihly
         call      DispAkt                  ; novÇ zobrazen° aktivn° cihly

         call      TestKey
         jnc       DemoPoz4

         mov       bl,2
DemoPoz5:mov       cx,15
         call      Cekej
;         call      Reklama
         dec       bl
         jnz       DemoPoz5

;         mov       cx,60
;         call      Cekej
         jmp       short DemoPoz1           ; dal®° krok cihly

DemoPoz4:ret

DemoPoz  ENDP

; -----------------------------------------------------------------------------
;        p†d cihly p©i demonstraci
; -----------------------------------------------------------------------------

DemoPad  PROC      NEAR

DemoPad1:call      DispAkt                  ; zobrazen° aktivn° cihly

         call      TestKey
         jnc       DemoPad2

;         call      Reklama
         mov       cx,15                    ; prodleva p©i pad†n° cihly
         call      Cekej                    ; prodleva
;         call      Reklama                  ; obsluha zobrazen° reklamy

         mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       dl,ds:[PozCih]           ; pozice cihly v poli
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         mov       di,ds:[AdrCih]           ; adresa ve videopamàti
         add       di,80*16                 ; nov† adresa
         inc       dh                       ; novò ©†dek
         call      TestCih                  ; test novÇ pozice cihly
         jc        DemoPad2                 ; nepovolen† pozice cihly - konec
         call      MazAkt                   ; vymaz†n° aktivn° cihly
         mov       ds:[AdrCih],di           ; nov† adresa cihly
         mov       ds:[RadCih],dh           ; novò ©†dek cihly
         jmp       short DemoPad1
DemoPad2:ret

DemoPad  ENDP

; -----------------------------------------------------------------------------
;        zvò®en° sk¢re p©i demonstraci
; -----------------------------------------------------------------------------

DemoSkor PROC      NEAR

         xor       bx,bx
         mov       bl,ds:[Uroven]
         mov       bl,ds:[bx+TabBod]        ; body

;         mov       ax,26
;         mov       al,5
;         mul       byte ptr ds:[Uroven]
;         add       ax,5

         cmp       byte ptr ds:[Pristi],0
         je        DemoSkr1
         sub       bx,5
         jnc       DemoSkr1
         xor       bx,bx
DemoSkr1:add       word ptr ds:[Skore],bx
         adc       word ptr ds:[Skore+2],0
         call      DispSkor                 ; zobrazen° novÇho sk¢re
         ret

DemoSkor ENDP


;; -----------------------------------------------------------------------------
;;        obsluha zobrazen° reklamy
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;;˛
;Reklama  PROC      NEAR
;
;         cmp       byte ptr ds:[DemPar],0
;         jne       Reklama0
;         ret
;
;Reklama0:push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;
;         push      ds
;         xor       ax,ax
;         mov       ds,ax
;         mov       ax,ds:[46ch]
;         pop       ds
;
;         mov       bx,ax
;         sub       ax,ds:[CasRekl]
;         cmp       ax,2
;         jb        Reklama9
;         mov       ds:[CasRekl],bx
;
;         mov       bx,4*32
;         mov       cx,5*2
;         mov       di,9*80+6*32*80+56
;         call      RolTxt
;
;         mov       di,9*80+10*32*80+56 - 80 ; adresa posledn° linky
;         cmp       byte ptr ds:[ParHerc],0
;         je        Reklama4                 ; nen° HERCULES
;         call      KorRAM
;         jmp       short Reklama2
;
;; ------ nastaven° z†pisovòch rovin
;
;Reklama4:mov       dx,3c4h
;         mov       al,2
;         out       dx,al
;         inc       dx
;         mov       al,7
;         out       dx,al
;
;; ------ p©°prava registrñ k zobrazen° linky
;
;Reklama2:mov       es,ds:[SegVRAM]          ; segment videopamàti
;         mov       si,ds:[UkazTxt]          ; adresa textu
;         mov       cx,20                    ; poáet znakñ
;         mov       bp,ds:[LinkaTxt]         ; zobrazen† linka
;         cld
;Reklama1:lodsb                              ; znak k zobrazen°
;
;; ------ vòpoáet adresy fontu znaku
;
;         sub       al," "                   ; znak v tabulce relativnà
;         xor       ah,ah                    ; AX = znak
;         mov       bx,ax                    ; znak
;         shl       bx,1                     ; znak * 2
;         shl       bx,1                     ; znak * 4
;         shl       bx,1                     ; znak * 8
;         sub       bx,ax                    ; znak * 7
;         shl       bx,1                     ; znak * 14
;         add       bx,bp
;         mov       al,ds:[bx+Font]          ; linka znaku
;
;; ------ uloëen° linky znaku
;
;         not       al
;         stosb                              ; uloëen° linky znaku
;         loop      Reklama1                 ; zobrazen° dal®°ho znaku
;
;; ------ zvò®en° linky pop©. adresy
;
;         inc       word ptr ds:[LinkaTxt]   ; zvò®en° ukazatele linky
;         cmp       word ptr ds:[LinkaTxt],14 ; jsou jië v®echny linky ?
;         jb        Reklama9                 ; nejsou je®tà v®echny linky
;         mov       word ptr ds:[LinkaTxt],0 ; je linka 0
;         cmp       si,offset Text0
;         jb        Reklama3
;         mov       si,offset Text
;Reklama3:mov       ds:[UkazTxt],si          ; adresa dal®°ho ©†dku textu
;
;
;Reklama9:
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;Reklama  ENDP
;
;; -----------------------------------------------------------------------------
;;        rolov†n° vò©ezu obrazovky o linku nahoru - plynouc° text
;; -----------------------------------------------------------------------------
;; VSTUP: CX=poáet slov na linku
;;        BX=vò®ka okna (poáet linek)
;;        DI=adresa ve videopamàti
;;        DS=datovò segment
;; -----------------------------------------------------------------------------
;
;RolTxt   PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;
;; ------ p©°prava registrñ
;
;         mov       es,ds:[SegVRAM]          ; segment videopamàti
;         mov       bp,80                    ; poáet bajtñ na linku
;         sub       bp,cx
;         sub       bp,cx                    ; poáet zbylòch bajtñ
;         dec       bx                       ; vò®ka okna - 1
;         cld
;
;; ------ rolov†n° pro HERCULES
;
;         cmp       byte ptr ds:[ParHerc],0
;         mov       ds,ds:[SegVRAM]          ; segment videopamàti
;         je        RolTxt1                  ; nen° HERCULES
;
;         call      KorRAM                   ; korekce adresy
;         mov       ax,cx
;         mov       si,di
;         add       si,2000h
;         jns       RolTxt4
;         and       si,7fffh
;         add       si,80
;RolTxt4: push      si
;         push      di
;         rep       movsw                    ; p©enos jednÇ linky
;         mov       cx,ax
;         pop       di
;         pop       si
;         add       si,2000h
;         jns       RolTxt5
;         and       si,7fffh
;         add       si,80
;RolTxt5: add       di,2000h
;         jns       RolTxt6
;         and       di,7fffh
;         add       di,80
;RolTxt6: dec       bx                       ; sn°ëen° á°taáe linek
;         jnz       RolTxt4                  ; p©enos dal®° linky
;         jmp       short RolTxt9
;
;; ------ nastaven° z†pisovÇ roviny
;
;RolTxt1: mov       al,2
;         mov       dx,3c4h
;         out       dx,al                    ; volba registru 2
;         inc       dx
;         mov       al,7                     ; z†pisovÇ roviny
;         out       dx,al                    ; volba z†pisovÇ roviny
;
;; ------ nastaven° átec° roviny
;
;         mov       dx,3ceh
;         mov       al,4
;         out       dx,al                    ; volba registru 4
;         inc       dx
;         mov       al,1
;         out       dx,al                    ; volba átec° roviny
;
;; ------ rolov†n° okna v jednÇ rovinà
;
;         mov       si,di
;         add       si,80                    ; adresa dal®° linky
;         mov       ax,cx
;RolTxt3: rep       movsw                    ; p©enos jednÇ linky
;         mov       cx,ax
;         add       si,bp
;         add       di,bp
;         dec       bx                       ; sn°ëen° á°taáe linek
;         jnz       RolTxt3                  ; p©enos dal®° linky
;
;; ------ n†vrat registrñ
;
;RolTxt9: pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;RolTxt   ENDP

; *****************************************************************************
;
;                   Obsluha souborñ
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        sestaven° jmÇna souboru v prost©ed°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
; neuchov†v† registry
; -----------------------------------------------------------------------------

InitSoub PROC      NEAR

         push      es

; ------ kontrola verze systÇmu

         mov       ah,30h
         int       21h                      ; poskytnut° verze systÇmu
         cmp       al,3
         jb        InitSou9                 ; n°zk† verze systÇmu

; ------ adresa zaá†tku prost©ed°

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       es,es:[2ch]              ; segment prost©ed°
         mov       word ptr ds:[AdrSoub+2],es ; segment adresy souboru
         xor       di,di

; ------ nalezen° ©etàzce cesty

         dec       di
InitSou1:inc       di
         cmp       word ptr es:[di],0
         jne       InitSou1
         inc       di
         inc       di

; ------ kontrola poátu ©etàzcñ

         cmp       word ptr es:[di],1
         jb        InitSou9
         inc       di
         inc       di
         cmp       byte ptr es:[di],0
         je        InitSou9
         mov       word ptr ds:[AdrSoub],di ; adresa jmÇna souboru

; ------ nalezen° konce jmÇna souboru

         dec       di
InitSou2:inc       di
         cmp       byte ptr es:[di],0
         jne       InitSou2

; ------ nalezen° koncovÇ teáky jmÇna

InitSou3:dec       di
         cmp       byte ptr es:[di],"\"
         je        InitSou4
         cmp       byte ptr es:[di],"."
         jne       InitSou3

; ------ n†hrada p©°pony p©°ponou DAT

         mov       word ptr es:[di+1],"AD"
         mov       word ptr es:[di+3],"T"
         jmp       short InitSou9

; ------ neplatnÇ jmÇno souboru

InitSou4:mov       word ptr ds:[AdrSoub],0  ; neplatnÇ jmÇno souboru

; ------ n†vrat registrñ

InitSou9:pop       es
         ret

InitSoub ENDP

; -----------------------------------------------------------------------------
;        naáten° souboru sk¢re
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

CtiSZac  label     near

CtiSoub  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ pokus o otev©en° souboru z prost©ed°

         cmp       word ptr ds:[AdrSoub],0  ; plat° soubor ?
         je        CtiSoub1                 ; soubor neplat°
         push      ds
         lds       dx,ds:[AdrSoub]          ; adresa souboru z prost©ed°
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         mov       bx,ax                    ; identifik†tor souboru
         pop       ds
         jnc       CtiSoub2                 ; soubor otev©en OK

; ------ pokus o otev©en° souboru v aktivn°m adres†©i

CtiSoub1:mov       dx,offset HracSoub       ; implicitn° jmÇno souboru
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
         jc        CtiSoub8                 ; nenalezen ë†dnò soubor
         mov       word ptr ds:[AdrSoub],0  ; soubor z prost©ed° jië neplat°

; ------ naáten° souboru do pamàti

CtiSoub2:mov       dx,offset ZacTab         ; tabulka hr†áñ
         mov       cx,offset(KonTab-ZacTab) ; dÇlka tabulky
         mov       ah,3fh                   ; áten° ze souboru
         int       21h                      ; naáten° tabulky do pamàti

; ------ uzav©en° souboru

         pushf
         push      ax
         mov       ah,3eh
         int       21h
         pop       ax
         popf

         jc        CtiSoub8                 ; chyba áten°
         cmp       ax,cx                    ; souhlas° poáet bajtñ ?
         jne       CtiSoub8                 ; poáet bajtñ nesouhlas°

; ------ dek¢dov†n° tabulky

         call      Dekod                    ; dek¢dov†n° tabulky
         je        CtiSoub9                 ; tabulka je platn†

; ------ soubor neplat° - vymaz†n° tabulky

CtiSoub8:mov       byte ptr ds:[Hrac],0     ; nen° ë†dnò platnò hr†á
         push      ds
         pop       es
         mov       bx,10
         mov       di,offset TabHrac
         cld
CtiSou88:mov       cx,10
         mov       al," "
         rep       stosb
         xor       ax,ax
         stosw
         stosw
         dec       bx
         jnz       CtiSou88

CtiSoub9:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CtiSoub  ENDP

CtiSKon  label     near

; -----------------------------------------------------------------------------
;        z†pis souboru sk¢re
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

ZapSoub  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ zak¢dov†n° tabulky

         call      Zakod                    ; zak¢dov†n° tabulky

; ------ pokus o otev©en° souboru z prost©ed°

         cmp       word ptr ds:[AdrSoub],0  ; plat° soubor ?
         je        ZapSoub3                 ; soubor neplat°
         push      ds
         lds       dx,ds:[AdrSoub]          ; adresa souboru z prost©ed°
         xor       cx,cx
         mov       ax,4301h
         int       21h                      ; nastaven° atributñ souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
         pop       ds
         jnc       ZapSoub4                 ; soubor vytvo©en OK

; ------ pokus o otev©en° souboru v aktivn°m adres†©i

ZapSoub3:mov       dx,offset HracSoub       ; implicitn° jmÇno souboru
         xor       cx,cx
         mov       ax,4301h
         int       21h                      ; nastaven° atributñ souboru
         mov       ah,3ch
         int       21h                      ; otev©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
         jc        ZapSoub8                 ; chyba - soubor nelze otev©°t
         mov       word ptr ds:[AdrSoub],0  ; soubor z prost©ed° jië neplat°

; ------ z†pis souboru na disk

ZapSoub4:mov       dx,offset ZacTab         ; tabulka hr†áñ
         mov       cx,offset(KonTab-ZacTab) ; dÇlka tabulky
         mov       ah,40h                   ; z†pis do souboru
         int       21h                      ; z†pis tabulky na disk

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h

; ------ zpàtnÇ dek¢dov†n° tabulky

ZapSoub8:call      Dekod

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZapSoub  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov†n° tabulky
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

Zakod    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vymaz†n° blafuj°c°ho p©°vaëku

         mov       di,offset TabBlaf        ; blafuj°c° p©°vaëek
         mov       cx,offset(KonTab-TabBlaf) ; dÇlka blafuj°c°ho p©°vaëku
         push      ds
         pop       es
         xor       al,al
         cld
         rep       stosb                    ; vymaz†n° tabulky

; ------ bàënò kontroln° souáet tabulky

         mov       si,offset TabHrac
         mov       cx,10*(10+4) + 1         ; dÇlka tabulky + hr†á
         xor       ax,ax
Zakod1:  xor       al,ds:[si]
         rol       ax,1
         inc       si
         loop      Zakod1                   ; dal®° bajt
         mov       ds:[si],ax               ; nastaven° kontroln°ho souátu

; ------ kontroln° souáet CRC tabulky

         mov       dx,-1
         mov       si,offset TabHrac        ; tabulka hr†áñ
         mov       cx,offset(KonTab-TabHrac) ; dÇlka tabulky
         call      CheckSum                 ; celkovò kontroln° souáet
         mov       ds:[ChSumm],dx           ; kontroln° souáet CRC

; ------ zak¢dov†n° tabulky

         mov       si,offset TabHrac        ; tabulka hr†áñ
         mov       bx,offset(KonTab-TabHrac) ; dÇlka tabulky celkem
         mov       cx,1                     ; bude se k¢dovat 1 bajt
Zakod2:  xor       byte ptr ds:[si],dl      ; za®ifrov†n° bajtu
         call      CheckSum                 ; posun kontroln°ho souátu
         dec       bx
         jnz       Zakod2                   ; zak¢dov†n° dal®°ho bajtu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Zakod    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° tabulky
; -----------------------------------------------------------------------------

Dekod    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ dek¢dov†n° tabulky

         mov       si,offset TabHrac        ; tabulka hr†áñ
         mov       bx,offset(KonTab-TabHrac) ; dÇlka tabulky celkem
         mov       cx,1                     ; bude se k¢dovat 1 bajt
         mov       dx,ds:[ChSumm]           ; vòchoz° hodnota kontroln°ho souátu
Dekod2:  mov       al,dl                    ; £schova dek¢duj°c°ho bajtu
         call      CheckSum                 ; posun kontroln°ho souátu
         xor       byte ptr ds:[si-1],al    ; de®ifrov†n° bajtu
         dec       bx
         jnz       Dekod2                   ; zak¢dov†n° dal®°ho bajtu

; ------ kontrola kontroln°ho souátu CRC tabulky

         mov       dx,-1
         mov       si,offset TabHrac        ; tabulka hr†áñ
         mov       cx,offset(KonTab-TabHrac) ; dÇlka tabulky
         call      CheckSum                 ; celkovò kontroln° souáet
         cmp       ds:[ChSumm],dx           ; kontroln° souáet CRC
         jne       Dekod9                   ; kontroln° souáet nesouhlas°

; ------ kontrola bàënÇho kontroln°ho souátu

         mov       si,offset TabHrac
         mov       cx,10*(10+4)+1
         xor       ax,ax
Dekod6:  xor       al,ds:[si]
         rol       ax,1
         inc       si
         loop      Dekod6
         cmp       ax,ds:[si]               ; kontrola kontroln°ho souátu

; ------ n†vrat registrñ

Dekod9:  pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Dekod    ENDP


; *****************************************************************************
;
;                          Obsluha hry
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        rotace cihly
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo cihly
;        DI=adresa cihly ve videopamàti
;        DL=pozice cihly
;        DH=©†dek cihly
;        DS=datovò segment
; VùSTUP:CY=rotaci nelze provÇst
;        AL=novÇ á°slo cihly
;        DI=nov† adresa ve videopamàti
;        DL=nov† pozice cihly
;        DH=novò ©†dek cihly
; -----------------------------------------------------------------------------

Rotace   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      si
         mov       bx,dx                    ; £schova pozice a ©†dku
         mov       si,di                    ; £schova adresy ve videopamàti

; ------ pokus o rotaci na m°stà

         call      Rotace0                  ; pokus o rotaci na m°stà
         jnc       Rotace9                  ; rotace provedena OK

         call      RotLR                    ; pokus o rotaci do stran
         jnc       Rotace9                  ; rotace provedena OK

         call      RotDwn                   ; pokus o krok dolñ
         jnc       Rotace9                  ; rotace provedena OK

         call      RotLR                    ; pokus o rotaci do stran
         jnc       Rotace9                  ; rotace provedena OK

         call      RotDwn                   ; pokus o krok dolñ
         jnc       Rotace9                  ; rotace provedena OK

         call      RotRet                   ; n†vrat registrñ - chyba

; ------ n†vrat registrñ

Rotace9: pop       si
         pop       bx
         ret

Rotace   ENDP

; -----------------------------------------------------------------------------
;        proveden° rotace na m°stà (CY=chyba)
; -----------------------------------------------------------------------------

Rotace0  PROC      NEAR

         push      bx
         mov       bl,al                    ; á°slo souáasnÇ cihly
         xor       bh,bh
         mov       al,ds:[RotCih+bx]        ; nov† aktivn° cihla
         call      TestCih                  ; test provedenÇ rotace
         jnc       Rotace01                 ; rotaci lze provÇst
         mov       al,bl                    ; p©i chybà n†vrat á°sla
Rotace01:pop       bx
         ret

Rotace0  ENDP

; -----------------------------------------------------------------------------
;        proveden° rotac° vlevo nebo vpravo (CY=nelze)
; -----------------------------------------------------------------------------

RotLR    PROC      NEAR

; ------ pokus o krok vlevo

         call      RotLft                   ; pokus o krok vlevo
         jnc       RotLR2                   ; rotace provedena OK
         call      RotLft                   ; pokus o krok vlevo
         jnc       RotLR2                   ; rotace provedena OK
         call      RotRet                   ; n†vrat registrñ

; ------ pokus o krok vpravo

         call      RotRght                  ; pokus o krok vpravo
         jnc       RotLR2                   ; rotace provedena OK
         call      RotRght                  ; pokus o krok vpravo
         jnc       RotLR2                   ; rotace provedena OK
         call      RotRet                   ; n†vrat registrñ

RotLR2:  ret

RotLR    ENDP

; -----------------------------------------------------------------------------
;        rotace s krokem dolñ
; -----------------------------------------------------------------------------

RotDwn   PROC      NEAR

         inc       dh                       ; zvò®en° á°sla ©†dku
         add       di,16*80                 ; zvò®en° adresy ve videopamàti
         call      TestCih                  ; lze posun provÇst ?
         jc        RotRet                   ; posun nelze provÇst
         call      Rotace0                  ; pokus o rotaci
         ret

RotDwn   ENDP

; -----------------------------------------------------------------------------
;        rotace s krokem vlevo
; -----------------------------------------------------------------------------

RotLft   PROC      NEAR

         dec       dl                       ; sn°ëen° pozice
         dec       di
         dec       di                       ; sn°ëen° adresy ve videopamàti
         call      TestCih                  ; lze posun provÇst ?
         jc        RotRet                   ; posun nelze provÇst - n†vrat
         call      Rotace0                  ; pokus o rotaci
         ret

RotLft   ENDP

; -----------------------------------------------------------------------------
;        rotace s krokem vpravo
; -----------------------------------------------------------------------------

RotRght  PROC      NEAR

         inc       dl                       ; zvò®en° pozice
         inc       di
         inc       di                       ; zvò®en° adresy ve videopamàti
         call      TestCih                  ; lze posun provÇst ?
         jc        RotRet                   ; posun nelze provÇst - n†vrat
         call      Rotace0                  ; pokus o rotaci
         ret

RotRght  ENDP

; -----------------------------------------------------------------------------
;        n†vrat registrñ p©i chybà
; -----------------------------------------------------------------------------

RotRet   PROC      NEAR

         mov       dx,bx                    ; n†vrat pozice a ©†dku
         mov       di,si                    ; n†vrat adresy ve videopamàti
         stc                                ; p©°znak chyby operace
         ret

RotRet   ENDP

; -----------------------------------------------------------------------------
;        uloëen° cihly do pole po dopadu
; -----------------------------------------------------------------------------

UlozCih  PROC      NEAR

; ------ adresa definice cihly

         mov       al,ds:[cihla]            ; aktivn° cihla
         xor       ah,ah
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       si,ax
         add       si,offset TabCih

; ------ cyklus uloëen° jednotlivòch kamenñ

         mov       dl,ds:[PozCih]           ; pozice cihly
         mov       dh,ds:[RadCih]           ; ©†dek cihly
         mov       bx,4                     ; poáet ©†dkñ
UlozCih1:mov       cx,4                     ; poáet pozic
UlozCih2:cld
         lodsb                              ; naáten° jednoho kamene
         or        al,al                    ; je platnò k†men ?
         jz        UlozCih3                 ; nen° to platnò k†men

; ------ uloëen° jednoho kamene do pole

         push      ax
         mov       al,10                    ; poáet kamenñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0                     ; p©enos do vy®®°ho bajtu
         mov       di,ax                    ; offset adresy kamene v poli
         pop       ax
         mov       ds:[Pole+di],al          ; uloëen° kamene do pole

; ------ p©°prava pro dal®° k†men

UlozCih3:inc       dl                       ; zvò®en° ukazatele pozice
         loop      UlozCih2                 ; uloëen° dal®°ho kamene na ©†dku
         sub       dl,4                     ; n†vrat pozice na zaá†tek
         inc       dh                       ; zvò®en° ukazatele ©†dkñ
         dec       bx                       ; sn°ëen° á°taáe ©†dkñ
         jnz       UlozCih1                 ; uloëen° dal®°ho ©†dku

; ------ vypustàn° plnòch ©†dkñ

         call      Vypust                   ; vypustàn° plnòch ©†dkñ
         call      DispPole                 ; koneánÇ zobrazen° pole
         ret

UlozCih  ENDP

; -----------------------------------------------------------------------------
;        inicializace novÇ hry
; -----------------------------------------------------------------------------

InitNova PROC      NEAR

; ------ inicializace hrac° plochy - nov† hra

         push      ds
         pop       es
         mov       di,offset Pole
         mov       cx,20*10                 ; velikost hrac° plochy
         cld
         xor       al,al
         rep       stosb

; ------ inicializace á°taáe cihel

         mov       di,offset Cihel
         xor       ax,ax                    ; mazac° slovo
         mov       cx,8
         rep       stosw

; ------ poá†teán° zobrazen° obrazovky

         mov       word ptr ds:[Skore],0
         mov       word ptr ds:[Skore+2],0
         mov       word ptr ds:[Radku],0
         call      DispSkor
         call      DispPole
         call      DispCit                  ; zobrazen° á°taáe cihel
         call      GenCih                   ; generov†n° prvn° cihly
         ret

InitNova ENDP

; -----------------------------------------------------------------------------
;        zvò®en° á°taáe cihel
; -----------------------------------------------------------------------------

IncCit   PROC      NEAR

         push      bx
         push      cx

         xor       bx,bx
         mov       bl,ds:[Cihla]            ; vygenerovan† cihla
         shl       bx,1
         inc       word ptr ds:[bx+CitCih]  ; zvò®en° á°taáe cihel
         jnz       IncCit1
         dec       word ptr ds:[bx+CitCih]

IncCit1:
         inc       word ptr ds:[Cihel]      ; zvò®en° celkovÇho á°taáe cihel
         jnz       IncCit2
         dec       word ptr ds:[Cihel]

IncCit2: cmp       word ptr ds:[Cihel],180
         jb        IncCit5

         mov       cx,7
         mov       bx,offset CitCih
IncCit3: cmp       word ptr ds:[bx],0
         je        IncCit4
         dec       word ptr ds:[bx]
         dec       word ptr ds:[Cihel]
IncCit4: inc       bx
         inc       bx
         loop      IncCit3

IncCit5:
         pop       cx
         pop       bx
         ret

IncCit   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°taáe cihel
; -----------------------------------------------------------------------------

DispCit  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ pro HERCULES nen° obsluha

         cmp       byte ptr ds:[ParHerc],0
         jne       DispCt99

; ------ zobrazen° podkladu

DispCit0:cmp       word ptr ds:[Cihel],0
         jne       DispCit1
         mov       ah,4                     ; áerven† barva
         mov       bh,1
         mov       cx,5
         mov       di,9*80+4 + 2*32*80
         call      DispPod
DispCt99:jmp       DispCit9

; ------ vymaz†n° ukazatele

DispCit1:mov       cx,20
         mov       di,9*80+4 + 2*32*80 + 5*80
         xor       ah,ah
         mov       bx,22
         call      DispBox

; ------ nastaven° z†pisu do v®ech rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z†pis do v®ech rovin
         out       dx,al                    ; nastaven° v®ech rovin

; ------ p©°prava registrñ

         xor       bx,bx                    ; ukazatel á°taáe cihel
         mov       di,9*80+4 + 2*32*80 + 5*80
         cld
         mov       es,ds:[SegVRAM]          ; segment videopamàti

; ------ nastaven° barvy á†ry

DispCit2:mov       dx,3ceh
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         inc       dx
         mov       al,bl                    ; cihla
         shr       al,1
         jc        DispCit5
         add       di,80
DispCit5:add       al,9                     ; barva
         not       al
         out       dx,al                    ; nastaven° barvy znaku
         dec       dx

; ------ nastaven° barvy podkladu

         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         mov       al,0                     ; barva podkladu
         inc       dx
         out       dx,al                    ; nastaven° barvy podkladu

; ------ vòpoáet procent cihly

         mov       dx,bx
         and       bl,not 1
         mov       ax,ds:[bx+CitCih]        ; áetnost cihly
         mov       bx,dx
         mov       cx,40*8
         mul       cx                       ; p©edn†soben°
         div       word ptr ds:[Cihel]      ; vòpoáet ukazatele cihly
         cmp       ax,8*20-4
         jbe       DispCit7
         mov       ax,8*20-4
DispCit7:mov       cx,ax                    ; ukazatel cihly
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; poáet celòch bajtñ cihly
         and       ax,7                     ; zbytek ukazatele
;         cmp       cx,20
;         jb        DispCit6
;         mov       cx,20
;         xor       ax,ax
DispCit6:mov       ah,al                    ; £schova zbytku ukazatele

; ------ uloëen° celÇ á†sti

         push      di
         mov       al,0ffh
         rep       stosb                    ; uloëen° celÇ á†sti

; ------ uloëen° necelÇ á†sti

         or        ah,ah
         jz        DispCit3
         mov       cl,8
         sub       cl,ah
         mov       al,0ffh
         shl       al,cl
         stosb
         dec       dl

DispCit3:pop       di

; ------ p©°prava pro dal®° cihlu

         add       di,80
         inc       bx
         cmp       bl,2*7
         jne       DispCit2

; ------ standardn° nastaven° registrñ barev

         mov       dx,3ceh
         mov       al,1
         out       dx,al
         mov       al,0
         inc       dx
         out       dx,al                    ; v®echny roviny podle dat

; ------ n†vrat registrñ

DispCit9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispCit  ENDP

; -----------------------------------------------------------------------------
;        zad†n° novÇho hr†áe
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
;˛
NovyH    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ nalezen° volnÇ poloëky hr†áe

         mov       cx,10
         mov       si,offset TabHrac-14     ; tabulka hr†áñ
         mov       di,9*80+56+3*14*80 - 2*14*80 + 1
         xor       bp,bp                    ; ukazatel á°sla hr†áe
NovyH1:  inc       bp                       ; zvò®en° ukazatele hr†áñ
         add       si,14
         add       di,2*14*80
         cmp       byte ptr ds:[si]," "     ; je voln† poloëka ?
         loopne    NovyH1
         je        NovyH11
         jmp       NovyH9                   ; nen° ë†dn† voln† poloëka

; ------ zobrazen° á°sla hr†áe a sk¢re 0

NovyH11: mov       word ptr ds:[si+10],0
         mov       word ptr ds:[si+12],0

         push      di
         push      si
         call      DispHlp
         mov       si,offset TextHlp7
         mov       di,9*80+6*32*80+ 5 + 7*80 + 3*14*80
         mov       cx,4
         call      DispTxt
         pop       si
         pop       di

         push      si
         xor       si,si
         mov       bx,bp
         mov       ah,0
         call      DispNum
         pop       si
         inc       di
         mov       al,"."
         call      DispCh
         add       di,16
         mov       al,"0"
         call      DispCh
         sub       di,15

; ------ zobrazen° podkladovÇho obdÇln°ku

         mov       cx,11
         mov       bx,14
         mov       ah,2
         call      DispBox

; ------ zobrazen° aktivn°ho kurzoru

         xor       bx,bx                    ; á°taá znakñ textu
NovyH2:  mov       al,"_"                   ; znak kurzoru
         mov       ah,0                     ; kurzor bude áernò
         call      DispCh                   ; zobrazen° kurzoru

; ------ zad†n° jednoho znaku

NovyH3:  xor       ax,ax
         int       16h
         or        ax,ax
         jz        NovyH7                   ; p©eru®en° Ctrl-Break
         cmp       al,27
         je        NovyH7                   ; p©eru®en° ESC

; ------ ukonáen° volby

         cmp       al,13
         je        NovyH8

; ------ zak†zanÇ znaky pro prvn° znak

         or        bx,bx                    ; je prvn° znak ?
         jnz       NovyH4                   ; nen° prvn° znak - OK
         cmp       al," "                   ; je mezera ?
         je        NovyH3                   ; mezera pro prvn° znak zak†zan†
         cmp       al,8                     ; znak zpàt ?
         je        NovyH3                   ; znak zpàt zak†zanò
         cmp       al,7fh                   ; Delete ?
         je        NovyH3                   ; Delete zak†z†n
         cmp       ax,4b00h                 ; kurzor vpravo ?
         je        NovyH3                   ; kurzor vpravo zak†zanò

; ------ vymaz†n° posledn°ho znaku

NovyH4:  cmp       al,8                     ; znak zpàt ?
         je        NovyH5                   ; znak zpàt
         cmp       al,7fh                   ; Delete ?
         je        NovyH5                   ; Delete
         cmp       ax,4b00h                 ; kurzor vpravo ?
         jne       NovyH6                   ; nen° ani kurzor vpravo
NovyH5:  mov       al,219                   ; plnÇ pol°áko
         mov       ah,2                     ; barva podkladu
         call      DispCh                   ; vymaz†n° kurzoru
         dec       si
         dec       di
         dec       bx                       ; sn°ëen° á°taáe znakñ
         mov       byte ptr ds:[si]," "     ; vymaz†n° znaku
         mov       al,219                   ; plnÇ pol°áko
         mov       ah,2                     ; barva podkladu
         call      DispCh                   ; vymaz†n° znaku
         jmp       short NovyH2             ; zobrazen° kurzoru

; ------ uloëen° znaku

NovyH6:  or        al,al
         jz        NovyH3                   ; zak†zanò znak
         cmp       al," "
         jb        NovyH3                   ; zak†zanò znak
         cmp       al,171
         ja        NovyH3                   ; zak†zanò znak
         cmp       bx,10                    ; jsou jië v®echny znaky ?
         je        NovyH3                   ; jsou jië v®echny znaky
         mov       byte ptr ds:[si],al      ; uloëen° znaku do bufferu
         push      ax
         mov       al,219                   ; plnÇ pol°áko
         mov       ah,2                     ; barva podkladu
         call      DispCh                   ; vymaz†n° kurzoru
         pop       ax
         mov       ah,0
         call      DispCh                   ; zobrazen° znaku
         inc       di
         inc       si
         inc       bx
         jmp       short NovyH2             ; zobrazen° kurzoru

; ------ p©eru®en° volby ESC

NovyH7:
         sub       si,bx                    ; n†vrat zaá†tku poloëky v tabulce
NovyH71: mov       cx,10
NovyH72: mov       byte ptr ds:[si]," "     ; zru®en° jmÇna p©i p©eru®en°
         inc       si
         loop      NovyH72
         mov       word ptr ds:[si],0
         mov       word ptr ds:[si+2],0
         jmp       short NovyH88

; ------ kontrola, zda nov† poloëka jië existuje

NovyH8:  sub       si,bx                    ; n†vrat ukazatele zaá†tku poloëky
         or        bx,bx                    ; je nàjakò znak v bufferu ?
         jz        NovyH71                  ; nen° nic v bufferu
         mov       byte ptr ds:[Hrac],0     ; p©ednastaven° ukazatele hr†áe
         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset TabHrac
NovyH82: inc       byte ptr ds:[Hrac]
         cmp       di,si
         jae       NovyH86                  ; hr†á zat°m neexistoval
         push      si
         push      di
         mov       cx,10
         cld
         repe      cmpsb                    ; porovn†n° jmen
         pop       di
         pop       si
         je        NovyH75                  ; hr†á jië existoval
         add       di,14
         jmp       short NovyH82            ; test dal®° poloëky

; ------ zad†n jië existuj°c° hr†á

NovyH75: mov       cx,10
NovyH76: mov       byte ptr ds:[si]," "     ; zru®en° jmÇna p©i p©eru®en°
         inc       si
         loop      NovyH76
         mov       word ptr ds:[si],0
         mov       word ptr ds:[si+2],0

; ------ n†vrat registrñ

NovyH86: call      ZapSoub                  ; z†pis souboru - je zmàna tabulky
NovyH88: call      DispList                 ; novÇ zobrazen° vòsledkovÇ listiny
NovyH9:  call      TestKey
         jc        NovyH70
         mov       ah,0
         int       16h
         jmp       short NovyH9
NovyH70:
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NovyH    ENDP

; -----------------------------------------------------------------------------
;        zru®en° aktivn°ho hr†áe
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

ZrusHr   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      si
         push      di
         push      es


         mov       bl,ds:[Hrac]
         or        bl,bl
         je        ZrusHr9                  ; nen° ë†dnò hr†á

         call      DispHlp
         mov       si,offset TextHlp9
         mov       di,9*80+6*32*80+5 + 2*80 + 3*14*80
         mov       cx,5
         call      DispTxt

         xor       ax,ax
         int       16h

         cmp       al,"a"
         je        ZrusHr1
         cmp       al,"A"
         jne       ZrusHr9
ZrusHr1:

; ------ adresa aktivn°ho a dal®°ho hr†áe

         mov       si,offset TabHrac        ; tabulka hr†áñ
ZrusHr2: add       si,14
         dec       bl
         jnz       ZrusHr2
         mov       di,si                    ; adresa dal®°ho hr†áe
         sub       di,14                    ; adresa aktivn°ho hr†áe

; ------ omezen° á°sla hr†áe

         mov       cx,offset TabHrac + 10*14 ; konec tabulky hr†áñ
         sub       cx,si                    ; poáet bajtñ k p©esunu
         jbe       ZrusHr3                  ; posledn° hr†á - mus° se sn°ëit
         cmp       byte ptr ds:[si]," "     ; n†sleduje dal®° hr†á ?
         jne       ZrusHr4                  ; n†sleduje dal®° hr†á
ZrusHr3: dec       byte ptr ds:[Hrac]       ; sn°ëen° á°sla hr†áe

; ------ zru®en° hr†áe

ZrusHr4: push      ds
         pop       es
         cld
         rep       movsb                    ; p©enos zbytku tabulky

; ------ vymaz†n° posledn°ho hr†áe

         mov       al," "                   ; mazac° znak
         mov       cl,10
         rep       stosb                    ; vymaz†n° jmÇna
         mov       al,0
         mov       cl,4
         rep       stosb                    ; vymaz†n° sk¢re

; ------ uloëen° aktivn°ho stavy

         call      ZapSoub                  ; uloëen° souboru na disk
         mov       byte ptr ds:[TextLis2],11
         call      DispList

ZrusHr9: mov       cx,20
         call      Cekej
         call      TestKey
         jc        ZrusHrA
         mov       ah,0
         int       16h
         jmp       short ZrusHr9
ZrusHrA:
         pop       es
         pop       di
         pop       si
         pop       bx
         pop       ax
         ret

ZrusHr   ENDP

; -----------------------------------------------------------------------------
;        volba jinÇho hr†áe
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

VolHrac  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      si
         push      di


         mov       bl,ds:[Hrac]
         or        bl,bl
         jnz       VolHrac0
         jmp       VolHrac9                 ; nen° ë†dnò hr†á

VolHrac0:call      DispHlp
         mov       si,offset TextHlp6
         mov       di,9*80+6*32*80+5 + 2*80 + 4*14*80
         mov       cx,3
         call      DispTxt

         mov       byte ptr ds:[TextLis2],14

; ------ adresa aktivn°ho hr†áe

         mov       si,offset TabHrac        ; tabulka hr†áñ
         mov       bh,ds:[Hrac]
VolHrac1:dec       bl
         jz        VolHrac2
         add       si,14
         jmp       short VolHrac1

; ------ zobrazen° novÇho hr†áe v tabulce

VolHrac2:call      DispList

; ------ áek†n° na znak z kl†vesnice

VolHrac3:xor       ax,ax
         int       16h

; ------ p©eru®en° volby ESC

         or        ax,ax
         jz        VolHrac7
         cmp       al,27
         je        VolHrac7
         cmp       al,13
         je        VolHrac7

; ------ kurzor nahoru

         cmp       ah,48h
         jne       VolHrac4
         cmp       byte ptr ds:[Hrac],1
         je        VolHrac3                 ; je jië hr†á 1
         dec       byte ptr ds:[Hrac]
         sub       si,14
         jmp       short VolHrac2

; ------ kurzor dolñ

VolHrac4:cmp       ah,50h
         jne       VolHrac5
         cmp       byte ptr ds:[Hrac],10
         je        VolHrac3                 ; je jië maxim†ln° hr†á
         cmp       byte ptr ds:[si+14]," "
         je        VolHrac3                 ; nen° dal®° hr†á
         inc       byte ptr ds:[Hrac]
         add       si,14
         jmp       short VolHrac2

; ------

VolHrac5:
         jmp       short VolHrac3

VolHrac7:mov       cx,20
         call      Cekej
         call      TestKey
         jc        VolHrc72
         mov       ah,0
         int       16h
         jmp       short VolHrac7

VolHrc72:
         cmp       bh,ds:[Hrac]
         je        VolHrac8                 ; hr†á nebyl zmànàn
         call      ZapSoub                  ; uloëen° souboru na disk
VolHrac8:mov       byte ptr ds:[TextLis2],11
         call      DispList
VolHrac9:pop       di
         pop       si
         pop       bx
         pop       ax
         ret

VolHrac  ENDP

; -----------------------------------------------------------------------------
;        uloëen° sk¢re do tabulky
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

UlozSkor PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         mov       al,14
         mul       byte ptr ds:[Hrac]
         or        ax,ax
         jz        UlozSkr4                 ; nen° ë†dnò hr†á
         add       ax,offset TabHrac-14
         mov       si,ax
         mov       ax,word ptr ds:[Skore]
         mov       dx,word ptr ds:[Skore+2]
         cmp       dx,ds:[si+12]
         jne       UlozSkr2
         cmp       ax,ds:[si+10]
UlozSkr2:jbe       UlozSkr4

         mov       ds:[si+10],ax
         mov       ds:[si+12],dx

; ------ set©°dàn° tabulky

         mov       cx,9
         mov       si,offset TabHrac + 9*14
         mov       bl,10
UlozSkr3:mov       ax,ds:[si+10]
         mov       dx,ds:[si+12]
         cmp       dx,ds:[si-2]
         jb        UlozSkr5
         ja        UlozSkr6
         cmp       ax,ds:[si-4]
         jbe       UlozSkr5

; ------ z†màna poloëek

UlozSkr6:push      si
         push      cx
         mov       cx,14
UlozSkr7:mov       al,ds:[si]
         xchg      ds:[si-14],al
         mov       ds:[si],al
         inc       si
         loop      UlozSkr7
         pop       cx
         pop       si

         cmp       bl,ds:[Hrac]
         jne       UlozSkr5
         dec       byte ptr ds:[Hrac]
         jmp       short UlozSkr5

UlozSkr8:mov       al,bl
         dec       al
         cmp       al,ds:[Hrac]
         jne       UlozSkr5
         inc       byte ptr ds:[Hrac]

UlozSkr5:sub       si,14
         dec       bl
         loop      UlozSkr3

; ------ uloëen° tabulky na disk

         call      DispList
         call      ZapSoub                  ; uloëen° souboru s novòm sk¢re

UlozSkr4:
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UlozSkor ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° plnòch ©†dkñ
; -----------------------------------------------------------------------------

Vypust   PROC      NEAR

; ------ nalezen° plnÇho ©†dku

Vypust1: push      ds
         pop       es

         xor       dh,dh                    ; ukazatel á°sla ©†dku
         mov       di,offset Pole           ; tabulka pole
         mov       bx,20                    ; poáet ©†dkñ
         cld
         xor       al,al                    ; hledanò bajt 0
Vypust2: push      di
         mov       cx,10                    ; poáet pozic
         repne     scasb                    ; kontrola, zda je ©†dek pr†zdnò
         pop       di
         jne       Vypust3                  ; nalezen plnò ©†dek
         add       di,10                    ; zvò®en° adresy v tabulce
         inc       dh                       ; zvò®en° á°sla ©†dku
         dec       bx                       ; sn°ëen° á°taáe ©†dkñ
         jnz       Vypust2                  ; test dal®°ho ©†dku
         jmp       short Vypust4            ; nenalezen plnò ©†dek

; ------ vypu®tàn° ©†dku DH

Vypust3: call      DelRow                   ; vypu®tàn° ©†dku DH
         inc       word ptr ds:[Radku]      ; zvò®en° á°taáe plnòch ©†dkñ
         call      DispSkor                 ; zobrazen° novÇho sk¢re
         jmp       short Vypust1            ; novò test plnÇho ©†dku

Vypust4: ret

Vypust   ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° ©†dku DH
; -----------------------------------------------------------------------------
; VSTUP: DH=©†dek k vypu®tàn°
;        DI=adresa ©†dku v tabulce pole
;        DS=datovò segment
; -----------------------------------------------------------------------------

DelRow   PROC      NEAR

         push      cx
         push      bx
         push      si
         push      di
         push      es


         call      DispPole

         mov       cx,10
;         call      Reklama

         push      ds
         pop       es
DelRow1:
         cld
         push      di
         push      cx
         mov       si,di
         inc       si
         mov       cl,9
         rep       movsb
         mov       byte ptr es:[di],0
         call      DispRow
;         call      DispPole

         mov       cx,12
         call      Cekej
;         call      Reklama
         mov       cx,12
         call      Cekej
;         call      Reklama

         pop       cx
         pop       di
         loop      DelRow1

         mov       cx,di
         sub       cx,offset Pole
         jbe       DelRow4
         mov       si,di
         dec       si
         add       di,9
         std
         rep       movsb

         mov       di,offset Pole
         mov       cx,10
         xor       al,al
         cld
         rep       stosb

         call      DispPole

DelRow4:
         mov       cx,3
         mov       bx,1140
         call      Ton
         call      Cekej
         mov       bx,905
         call      Ton
         call      Cekej
         mov       bx,761
         call      Ton
         call      Cekej
         mov       bx,570
         call      Ton
         call      Cekej
         call      TonOff

;         call      Reklama

         mov       si,3
DelRow8: mov       cx,15
         call      Cekej
;         call      Reklama
         dec       si
         jnz       DelRow8


         pop       es
         pop       di
         pop       si
         pop       bx
         pop       cx
         ret

DelRow   ENDP

;         dw        36485,34437,32505,30680,28958,27333 ; okt†va 0
;         dw        25799,24351,22984,21694,20477,19327
;         dw        18243,17219,16252,15340,14479,13667 ; okt†va 1
;         dw        12899,12175,11492,10847,10238,9664
;         dw        9121,8609,8126,7670,7240,6833       ; okt†va 2
;         dw        6450,6088,5746,5424,5119,4832
;         dw        4561,4305,4063,3835,3620,3417       ; okt†va 3
;         dw        3225,3044,2873,2712,2560,2416
;         dw        2280,2152,2032,1918,1810,1708       ; okt†va 4
;         dw        1612,1522,1437,1356,1280,1208
;         dw        1140,1076,1016,959,905,854          ; okt†va 5
;         dw        806,761,718,678,640,604
;         dw        570,538,508,479,452,427             ; okt†va 6
;         dw        403,380,359,339,320,302
;         dw        285,269,254,240,226,214             ; okt†va 7
;         dw        202,190,180,169,160,151
;         dw        143,135,127,120,113,107             ; okt†va 8
;         dw        101,95,90,85,80,75
;         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt†va 9

; -----------------------------------------------------------------------------
;        test novÇ pozice cihly
; -----------------------------------------------------------------------------
; VSTUP: AL=testovan† cihla
;        DL=pozice cihly na ©†dku
;        DH=©†dek cihly
;        DS=datovò segment
; VùSTUP:CY=pozice nen° povolen†
; -----------------------------------------------------------------------------

TestCih  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ vòpoáet adresy cihly v tabulce cihel

         xor       ah,ah                    ; AX = á°slo cihly
         mov       si,ax                    ; SI <- á°slo cihly
         shl       si,1
         shl       si,1
         shl       si,1
         shl       si,1                     ; SI = offset v tabulce cihel
         add       si,offset TabCih         ; adresa definice cihly

; ------ kontrola jednoho ©†dku

         mov       bx,4                     ; poáet ©†dkñ cihly
TestCih2:mov       cx,4                     ; poáet pozic cihly
TestCih3:cld
         lodsb                              ; naáten° definián°ho bajtu
         or        al,al                    ; je to platnò k†men ?
         jz        TestCih7                 ; nen° to platnò k†men

; ------ kontrola sou©adnic kamene

         cmp       dl,9                     ; maxim†ln° pozice na ©†dku
         ja        TestCih8                 ; nepovolen† pozice
         cmp       dh,19                    ; maxim†ln° ©†dek
         ja        TestCih8                 ; nepovolen† pozice

; ------ kontrola, zda je pozice v poli pr†zdn†

         mov       al,10                    ; n†sobek 10 pozic na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na offset
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0                     ; p©enos do vy®®°ho bajtu
         mov       di,ax                    ; offset v tabulce pole
         cmp       byte ptr ds:[di+Pole],0  ; je pozice voln† ?
         jne       TestCih8                 ; chyba - pozice nen° voln†

; ------ p©°prava pro dal®° k†men

TestCih7:inc       dl                       ; zvò®en° pozice kamene na ©†dku
         loop      TestCih3                 ; test dal®°ho kamene na ©†dku
         sub       dl,4                     ; n†vrat pozice na zaá†tku ©†dku
         inc       dh                       ; zvò®en° á°sla ©†dku
         dec       bx                       ; sn°ëen° á°taáe ©†dkñ
         jnz       TestCih2                 ; test dal®°ho ©†dku

; ------ kontrola probàhla OK

         clc                                ; p©°znak operace OK
         jmp       short TestCih9

; ------ zak†zan† pozice cihly

TestCih8:stc                                ; p©°znak zak†zanÇ pozice cihly

; ------ n†vrat cihly

TestCih9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TestCih  ENDP


; -----------------------------------------------------------------------------
;        generov†n° cihly
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

GenCih   PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ p©°®t° cihla bude jako souáasn† cihla

         mov       al,ds:[NextCih]          ; p©°®t° cihla
         mov       ds:[Cihla],al            ; je to aktivn° cihla

; ------ generov†n° novÇ p©°®t° cihly

         mov       ax,7                     ; poáet cihel
         call      Random                   ; generov†n° novÇ cihly
         mov       ds:[NextCih],al          ; £schova p©°®t° cihly

; ------ inicializace ukazatelñ cihly

         mov       byte ptr ds:[PozCih],3   ; pozice s cihlou v tabulce
         mov       byte ptr ds:[RadCih],-1  ; ©†dek s cihlou v tabulce
         mov       word ptr ds:[AdrCih],TopVRAM+3*2-16*80 ; poá†teán° adresa cihly

; ------ n†vrat registrñ

         pop       ax
         ret

GenCih   ENDP

; *****************************************************************************
;
;                          Obsluha zobrazen°
;
; *****************************************************************************
;˛

; -----------------------------------------------------------------------------
;        zmàna okna p©°®t° cihly
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

NextXchg PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      di

; ------ zmàna p©°znaku zobrazen°

         xor       byte ptr ds:[Pristi],1   ; zmàna p©°znaku
         jz        NextXc3                  ; je uzav©en° okna

; ------ otev©en° okna

         mov       di,110*80+13 + 8*80 + 4*7*80

         mov       ah,0                     ; barva áern†
         mov       bx,16

         mov       cx,4
NextXc1: push      cx
         mov       cx,10
         call      DispBox
         sub       di,14*80
         call      DispZacl
         add       di,8*80
         mov       cx,40
         call      Cekej
         pop       cx
         loop      NextXc1

         mov       di,110*80+13+8*80
         mov       cx,10
         call      DispBox

         mov       cx,40
         call      Cekej

         mov       di,110*80+13
         mov       cx,10
         mov       bx,52
         call      DispBox

         mov       cx,120
         call      Cekej

         jmp       short NextXc9

; ------ je uzav©en° okna

NextXc3:
         mov       di,110*80+13             ; adresa k zobrazen° z†clony
         mov       bl,16                    ; poáet linek
         mov       cx,40                    ; prodleva

         call      DispZacl
         add       di,8*80
         call      Cekej

         call      DispZacl
         add       di,7*80
         call      Cekej

         call      DispZacl
         add       di,7*80
         call      Cekej

         call      DispZacl
         add       di,7*80
         call      Cekej

         call      DispZacl
         call      Cekej

; ------ n†vrat registrñ

NextXc9: ;mov       byte ptr ds:[Pristi0],0
         call      DispNext
         pop       di
         pop       cx
         pop       bx
         ret

NextXchg ENDP

; -----------------------------------------------------------------------------
;        zobrazen° p©°®t° cihly
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispNext PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      di

         cmp       byte ptr ds:[ParHra],0   ; je hra ?
         je        DispNx00                 ; nen° hra

         cmp       byte ptr ds:[Pristi],0
         jne       DispNxt0                 ; okno je zapnuto

; ------ zobrazen° z†clony

DispNx00:mov       di,110*80+13             ; adresa k zobrazen° z†clony
         mov       bl,8                     ; poáet linek
         call      DispZacl
         add       di,8*80
         mov       cx,4
         mov       bl,7
DispNx01:call      DispZacl
         add       di,7*80
         loop      DispNx01
         mov       bl,16
         call      DispZacl

;         mov       di,110*80+13+4+18*80
;         mov       al,"?"
;         mov       ah,14                    ; barva
;         call      DispCh

;         inc       byte ptr ds:[Pristi0]

         jmp       short DispNxt9

; ------ okno pro cihlu

DispNxt0:mov       ah,0                     ; barva áern†
         mov       di,110*80+13
         mov       cx,10
         mov       bx,52
         call      DispBox

; ------ zobrazen° cihly

         mov       al,ds:[NextCih]          ; p©°®t° cihla
         mov       di,104*80+14             ; adresa cihly ve videopamàti
         cmp       al,5
         jb        DispNxt1
         ja        DispNxt2
         add       di,8*80-1
DispNxt1:inc       di
DispNxt2:
         call      DispCih                  ; zobrazen° cihly

DispNxt9:pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

DispNext ENDP

; -----------------------------------------------------------------------------
;        zobrazen° z†clony
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DI=ukl†dac° adresa
;        BL=poáet linek
; -----------------------------------------------------------------------------

DispZacl PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[SegVRAM]          ; segment videopamàti
         mov       si,offset ObrZacl        ; obraz z†clony
         cld

; ------ zobrazen° pro HERCULES

         cmp       byte ptr ds:[ParHerc],0
         je        DispZac1

         mov       si,offset ObrZacl2
         push      di
         call      KorRAM
DispZac4:lodsw                              ; vzorek
         mov       cx,5                     ; ®°©ka linky
         rep       stosw                    ; z†pis linky
         add       di,2000h-2*5
         jns       DispZac5
         and       di,7fffh
         add       di,80                    ; zaá†tek dal®° linky
DispZac5:dec       bl                       ; sn°ëen° á°taáe linek
         jnz       DispZac4                 ; zobrazen° dal®° linky
         pop       di
         jmp       short DispZac9


; ------ p©°prava registru volby rovin

DispZac1:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       bh,1                     ; rovina 1

; ------ zobrazen° jednÇ roviny

DispZac2:mov       al,bh
         out       dx,al                    ; volba roviny k z†pisu
         push      di
         push      si
         push      bx

; ------ zobrazen° jednÇ linky

DispZac3:lodsw                              ; vzorek
         mov       cx,5                     ; ®°©ka linky
         rep       stosw                    ; z†pis linky

; ------ p©°prava pro dal®° linku

         add       di,80-2*5                ; zaá†tek dal®° linky
         dec       bl                       ; sn°ëen° á°taáe linek
         jnz       DispZac3                 ; zobrazen° dal®° linky

; ------ p©°prava pro dal®° rovinu

         pop       bx
         pop       si
         pop       di
         add       si,2*16
         shl       bh,1                     ; maska pro dal®° rovinu
         cmp       bh,10h
         jne       DispZac2                 ; zobrazen° dal®° roviny

; ------ n†vrat registrñ

DispZac9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispZacl ENDP

; -----------------------------------------------------------------------------
;        zobrazen° aktivn° cihly
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispAkt  PROC      NEAR

         push      ax
         push      di

         mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       di,ds:[AdrCih]           ; adresa cihly ve videopamàti
         call      DispCih                  ; zobrazen° cihly

         pop       di
         pop       ax
         ret

DispAkt  ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° aktivn° cihly
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

MazAkt   PROC      NEAR

         push      ax
         push      di

         mov       al,ds:[Cihla]            ; aktivn° cihla
         mov       di,ds:[AdrCih]           ; adresa cihly ve videopamàti
         call      MazCih                   ; vymaz†n° cihly

         pop       di
         pop       ax
         ret

MazAkt   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° ©†dku hrac° plochy
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DH=©†dek k zobrazen°
; -----------------------------------------------------------------------------

DispRow  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       si,offset Pole           ; hrac° plocha
         mov       di,TopVRAM
         mov       cx,10
         or        dh,dh
         jz        DispRow2
DispRow1:add       di,16*80
         add       si,cx
         dec       dh
         jnz       DispRow1
DispRow2:cld
         lodsb
         call      DispKam
         inc       di
         inc       di
         loop      DispRow2

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispRow  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° hrac° plochy
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispPole PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di

         mov       si,offset Pole           ; hrac° plocha
         mov       di,TopVRAM
         mov       bx,20
DispPol1:mov       cx,10
DispPol2:cld
         lodsb
         call      DispKam
         inc       di
         inc       di
         loop      DispPol2
         add       di,16*80-20
         dec       bx
         jnz       DispPol1

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispPole ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° cihly - pouze platnÇ kameny
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        AL=á°slo cihly (v tabulce)
;        DI=offset ve videopamàti
; -----------------------------------------------------------------------------

MazCih  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ nalezen° adresy cihly

         xor       ah,ah
         mov       si,ax                    ; á°slo cihly
         shl       si,1
         shl       si,1
         shl       si,1
         shl       si,1                     ; á°slo cihly * 16
         add       si,offset TabCih         ; adresa definice cihly

; ------ vymaz†n° cihly

         mov       bx,4                     ; poáet ©†dkñ
MazCih1: mov       cx,4                     ; poáet pozic
MazCih2: cld
         lodsb
         or        al,al                    ; je platnò k†men ?
         jz        MazCih3                  ; nen° platnò k†men
         xor       al,al                    ; k†men se vymaëe
         call      DispKam                  ; zobrazen° kamene
MazCih3: inc       di
         inc       di                       ; zvò®en° adresy ve videopamàti
         loop      MazCih2                  ; zobrazen° dal®°ho kamene
         add       di,16*80-2*4             ; adresa dal®° ©ady
         dec       bx
         jnz       MazCih1                  ; zobrazen° dal®° ©ady

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

MazCih  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° cihly - pouze platnÇ kameny
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        AL=á°slo cihly (v tabulce)
;        DI=offset ve videopamàti
; -----------------------------------------------------------------------------

DispCih  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ nalezen° adresy cihly

         xor       ah,ah
         mov       si,ax                    ; á°slo cihly
         shl       si,1
         shl       si,1
         shl       si,1
         shl       si,1                     ; á°slo cihly * 16
         add       si,offset TabCih         ; adresa definice cihly

; ------ zobrazen° cihly

         mov       bx,4                     ; poáet ©†dkñ
DispCih1:mov       cx,4                     ; poáet pozic
DispCih2:cld
         lodsb
         or        al,al                    ; je platnò k†men ?
         jz        DispCih3                 ; nen° platnò k†men
         call      DispKam                  ; zobrazen° kamene
DispCih3:inc       di
         inc       di                       ; zvò®en° adresy ve videopamàti
         loop      DispCih2                 ; zobrazen° dal®°ho kamene
         add       di,16*80-2*4             ; adresa dal®° ©ady
         dec       bx
         jnz       DispCih1                 ; zobrazen° dal®° ©ady

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispCih  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kamene
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DI=adresa ve videopamàti k zobrazen° kamene (offset ve videostr†nce)
;        AL=barva kamene 0 aë 7
; -----------------------------------------------------------------------------

DispKam  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es
         mov       ah,al                    ; barva kamene 0 aë 7

; ------ p©°prava registrñ

         mov       es,ds:[SegVRAM]          ; segment videopamàti
         mov       si,offset ObrKam         ; obraz kamene
         mov       cx,16                    ; poáet linek kamene
         cld

         cmp       byte ptr ds:[ParHerc],0
         je        DispKam0

         call      KorRAM
         or        ax,ax
         jz        DispKam6

; ------ zobrazen° kamene

DispKam4:movsw                              ; p©enos jednÇ linky kamene
         add       di,2000h-2
         jns       DispKam5
         and       di,7fffh
         add       di,80                    ; adresa dal®° linky
DispKam5:loop      DispKam4                 ; zobrazen° dal®° linky
         jmp       short DispKam9

; ------ vymaz†n° kamene

DispKam6:stosw                              ; p©enos jednÇ linky kamene
         add       di,2000h-2
         jns       DispKam7
         and       di,7fffh
         add       di,80                    ; adresa dal®° linky
DispKam7:loop      DispKam6                 ; zobrazen° dal®° linky
         jmp       short DispKam9


; ------ nastaven° z†pisu do v®ech rovin

DispKam0:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z†pis do v®ech rovin
         out       dx,al                    ; nastaven° v®ech rovin

; ------ nastaven° z†kladn° barvy kamene

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ah                    ; poëadovan† barva
         out       dx,al                    ; nastaven° z†kladn° barvy kamene
         dec       dx

; ------ nastaven° volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0fh                   ; v®echny roviny podle registru 0
         test      ah,7                     ; je áern† barva ?
         jz        DispKam1                 ; je áern† barva
         mov       al,7                     ; jinak jasov† rovina podle dat
DispKam1:inc       dx
         out       dx,al                    ; volba rovin

; ------ zobrazen° kamene

DispKam3:movsw                              ; p©enos jednÇ linky kamene
         add       di,80-2                  ; adresa dal®° linky
         loop      DispKam3                 ; zobrazen° dal®° linky

; ------ standardn° nastaven° registru rovin

         xor       al,al
         out       dx,al                    ; v®echny roviny podle dat

; ------ n†vrat registrñ

DispKam9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispKam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° celÇho r†mu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispRam  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di

; ------ horn° linka

         mov       di,TopVRAM-8*80-1
         mov       cx,2*10+2
DispRam1:call      Disp1Ram
         inc       di
         loop      DispRam1

; ------ horn° linka

         mov       di,TopVRAM+20*16*80-1
         mov       cx,2*10+2
DispRam2:call      Disp1Ram
         inc       di
         loop      DispRam2

; ------ levò okraj

         mov       di,TopVRAM-1
         mov       cx,20*2
DispRam3:call      Disp1Ram
         add       di,8*80
         loop      DispRam3

; ------ pravò okraj

         mov       di,TopVRAM+2*10
         mov       cx,20*2
DispRam4:call      Disp1Ram
         add       di,8*80
         loop      DispRam4

         pop       di
         pop       cx
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho kamene r†mu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DI=adresa ve videopamàti k zobrazen° kamene (offset ve videostr†nce)
; -----------------------------------------------------------------------------

Disp1Ram PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ k zobrazen°

         mov       es,ds:[SegVRAM]          ; segment videopamàti
         mov       si,offset ObrRam         ; obraz kamene r†mu
         mov       cx,8                     ; poáet linek kamene
         cld

; ------ zobrazen° pro HERCULES

         cmp       byte ptr ds:[ParHerc],0
         je        Disp1Rm2

         call      KorRAM
Disp1Rm1:movsb                              ; p©enos jednÇ linky kamene
         add       di,2000h-1
         jns       Disp1Rm5
         and       di,7fffh
         add       di,80                    ; adresa dal®° linky
Disp1Rm5:loop      Disp1Rm1                 ; zobrazen° dal®° linky
         jmp       short Disp1Rm9

; ------ nastaven° z†pisu do v®ech rovin

Disp1Rm2:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z†pis do v®ech rovin
         out       dx,al                    ; nastaven° v®ech rovin

; ------ nastaven° barvy kamene

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,7                     ; barva - b°l†
         out       dx,al                    ; nastaven° barvy kamene
         dec       dx

; ------ nastaven° volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1000b                 ; pouze rovina 3 podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin


; ------ zobrazen° kamene

Disp1Rm3:movsb                              ; p©enos jednÇ linky kamene
         add       di,80-1                  ; adresa dal®° linky
         loop      Disp1Rm3                 ; zobrazen° dal®° linky

; ------ standardn° nastaven° registru rovin

         xor       al,al
         out       dx,al                    ; v®echny roviny podle dat

; ------ n†vrat registrñ

Disp1Rm9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

Disp1Ram ENDP

; -----------------------------------------------------------------------------
;        zobrazen° okna n†povàdy
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispHlp  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ okno n†povàdy

         mov       ah,6
         mov       bh,3
         mov       di,9*80+6*32*80+4 + 32*80
         mov       cx,5
         call      DispPod

;         mov       ah,6
;         mov       bh,4
;         mov       di,9*80+6*32*80+4
;         mov       cx,5
;         call      DispPod

; ------ zobrazen° n†povàdy

         mov       di,9*80+6*32*80+4
         mov       si,offset TextHlp        ; text n†povàdy
         mov       cx,3                     ; poáet ©†dkñ textu
         call      DispTxt                  ; zobrazen° textu n†povàdy

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispHlp  ENDP


; -----------------------------------------------------------------------------
;        zobrazen° vòsledkovÇ listiny
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispList PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ zobrazen° podkladu

         mov       ah,2
         mov       bh,10
         mov       cx,5
         mov       di,9*80+56
         call      DispPod

; ------ zobrazen° nadpisu

         mov       si,offset TextList
         mov       cx,3                     ; poáet ©†dkñ
         call      DispTxt

; ------ kontrola, zda je platnò hr†á k zobrazen°

         mov       di,9*80+56+3*14*80+1     ; ukazatel pozice na displeji
         mov       si,offset TabHrac        ; tabulka hr†áñ
         mov       dl,1                     ; ukazatel á°sla hr†áe
DispLis2:cmp       byte ptr ds:[si]," "
         je        DispLis9                 ; nen° platnò hr†á

; ------ zobrazen° podkladovÇho kurzoru

         cmp       dl,ds:[Hrac]             ; je to aktivn° hr†á ?
         jne       DispLis3                 ; nen° to aktivn° hr†á

         dec       di
         push      si
         mov       si,offset TextLis2
         cmp       byte ptr ds:[ParHerc],0
         je        DispLis5                 ; nen° Hercules
         mov       byte ptr ds:[si],7       ; pro MONO b°l† barva
DispLis5:mov       cx,1
         call      DispTxt
         pop       si
;         mov       ah,14
;         mov       cx,5*4
;         mov       bx,14
;         call      DispBox
         inc       di

; ------ zobrazen° á°sla hr†áe v tabulce

DispLis3:push      si
         mov       al,dl                    ; á°slo hr†áe
         mov       ah,0
         mov       bx,ax
         xor       si,si
         call      DispNum                  ; zobrazen° á°sla hr†áe
         pop       si

         inc       di
         mov       al,"."
         call      DispCh                   ; zobrazen° oddàlovac° teáky
         inc       di

; ------ zobrazen° jmÇna hr†áe

         mov       cx,10                    ; poáet znakñ jmÇna hr†áe
DispLis4:cld
         lodsb
         call      DispCh                   ; zobrazen° znaku jmÇna
         inc       di
         loop      DispLis4                 ; zobrazen° dal®°ho znaku jmÇna

; ------ zobrazen° sk¢re hr†áe

         cld
         lodsw
         mov       bx,ax
         lodsw
         push      si
         mov       si,ax
         add       di,5
         mov       ah,0
         call      DispNum
         pop       si

; ------ p©°prava pro dal®°ho hr†áe

         add       di,2*14*80 - 17           ; adresa dal®°ho ©†dku
         inc       dl
         cmp       dl,10
         jbe       DispLis2                 ; zobrazen° dal®°ho hr†áe

; ------ n†vrat registrñ

DispLis9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispList ENDP

; -----------------------------------------------------------------------------
;        zobrazen° sk¢re
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispSkor PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ okno sk¢re

         mov       ah,3                     ; modrozelen† barva
         mov       bh,2
         mov       cx,2
         mov       di,9*80+4 + 3*4
         call      DispPod

; ------ zobrazen° £rovnà

         mov       di,18*80+5 + 5*4-3
         xor       bx,bx
         xor       si,si
         mov       bl,ds:[Uroven]
         mov       ah,0
         call      DispNum

; ------ zobrazen° sk¢re

         add       di,14*80
         mov       bx,word ptr ds:[Skore]
         mov       si,word ptr ds:[Skore+2]
         mov       ah,0
         call      DispNum

; ------ zobrazen° poátu ©†dkñ

         add       di,14*80
         mov       bx,ds:[Radku]
         xor       si,si
         mov       ah,0
         call      DispNum

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispSkor ENDP

; -----------------------------------------------------------------------------
;        zobrazen° podkladu obrazovky
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
;˛
Podklad  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di


; ------ z†kladn° podklad

         mov       ah,4
         mov       bh,12
         mov       cx,20
         mov       di,-23*80
         call      DispPod                  ; zobrazen° z†kladn°ho podkladu


; ------ okno tabulky nejlep®°ch

         mov       ah,2
         mov       bh,10
         mov       cx,5
         mov       di,9*80+56
         call      DispPod



; ------ okno sk¢re

         mov       ah,3                     ; modrozelen† barva
         mov       bh,2
         mov       cx,5
         mov       di,9*80+4
         call      DispPod

; ------ nadpis - sk¢re

         mov       di,18*80+5
         mov       si,offset TextSkor
         mov       cx,3
         call      DispTxt


; ------ okno p©°®t° cihly

         mov       ah,1                     ; modr† barva
         mov       bh,2
         mov       di,9*80+3*32*80+4
         mov       cx,5
         call      DispPod

; ------ nadpis - p©°®t° cihla

         mov       di,9*80+3*32*80+5+16*80
         mov       si,offset TextNext
         mov       cx,2
         call      DispTxt

; ------ okno pro cihlu

         mov       ah,0                     ; barva áern†
         mov       di,110*80+13
         mov       cx,10
         mov       bx,52
         call      DispBox

; ------ okno n†povàdy

         mov       ah,6
         mov       bh,4
         mov       di,9*80+6*32*80+4
         mov       cx,5
         call      DispPod

; ------ zobrazen° n†povàdy

         mov       di,9*80+6*32*80+4
         mov       si,offset TextHlp        ; text n†povàdy
         mov       cx,3                     ; poáet ©†dkñ textu
         call      DispTxt                  ; zobrazen° textu n†povàdy

;         mov       cx,1                     ; poáet ©†dkñ zbytku textu
;         mov       di,9*80+6*32*80+4 + 6*80 + 3*14*80
;         mov       si,offset TextHlp1
;         call      DispTxt                  ; zobrazen° zbytku n†povàdy
;         add       di,25*80
;         call      DispTxt
;         add       di,25*80
;         call      DispTxt

; ------ zobrazen° licenán°ho textu

         mov       di,(350-17)*80+80-24     ; adresa k zobrazen° textu
         mov       si,offset TextLic        ; licenán° text
         cmp       byte ptr ds:[ParHerc],0
         je        Podklad3
         mov       si,offset TextLic0       ; pro Hercules
Podklad3:mov       cx,1                     ; zobraz° se 1 ©†dek textu
         call      DispTxt                  ; zobrazen° textu

; ------ zobrazen° textu o programu

         mov       di,(350-17)*80+4         ; adresa k zobrazen° textu
         mov       si,offset TextTet        ;
         cmp       byte ptr ds:[ParHerc],0
         je        Podklad4
         mov       si,offset TextTet0       ; pro Hercules
Podklad4:mov       cx,1                     ; zobraz° se 1 ©†dek textu
         call      DispTxt                  ; zobrazen° textu

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

Podklad  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° r†mu z cihel
; -----------------------------------------------------------------------------
; VSTUP: AH=barva cihly 0 aë 7
;        BH=poáet ©†dkñ cihel
;        CX=poáet cihel na ©†dku
;        DI=adresa ve videopamàti k uloëen°
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispPod  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es
         mov       es,ds:[SegVRAM]          ; segment videopamàti

         cmp       byte ptr ds:[ParHerc],0
         je        DispPod1

         or        di,di
         jns       DispPoh1
         add       di,32*80
         call      KorRAM
         sub       di,32*80/4
         jmp       short DispPoh2

DispPoh1:call      KorRAM
DispPoh2:mov       si,offset ObrCih2        ; vzor cihly - jas
         cmp       ah,4
         je        DispPoh6
         mov       si,offset ObrCih3        ; vzor cihly - jasnàj®°

; ------ zobrazen° jednoho ©†dku HERCULES

DispPoh6:mov       bl,32                    ; poáet linek na obr†zek
         push      si

; ------ p©enos jednÇ linky

DispPoh7:push      cx
         push      di
DispPoh8:movsw
         movsw
         sub       si,4
         loop      DispPoh8
         pop       di
         pop       cx

; ------ p©°prava pro dal®° linku

DispPh86:add       di,2000h
         jns       DispPh87
         and       di,7fffh
         add       di,80                    ; adresa dal®° linky
DispPh87:add       si,4                     ; adresa dal®° linky
         dec       bl                       ; sn°ëen° á°taáe linek
         jnz       DispPoh7                 ; p©enos dal®° linky

; ------ p©°prava pro dal®° ©†dek

         dec       bh                       ; sn°ëen° á°taáe dal®°ho ©†dku
         pop       si
         jnz       DispPoh6                 ; p©enos dal®°ho ©†dku
         jmp       DispPod9


; ------ nastaven° registrñ barvy

DispPod1:mov       dx,3ceh
         mov       al,0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,0fh                   ; barva bude vysv°cen†
         out       dx,al                    ; nastaven° implicitn° barvy
         dec       dx
         mov       al,1
         out       dx,al                    ; volba registru 1
         inc       dx
         mov       al,ah                    ; barva
         out       dx,al                    ; barva cihly

; ------ volba rovin k z†pisu

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,7                     ; v®echny barevnÇ roviny
         out       dx,al
         cld

; ------ £schova parametrñ

         push      di                       ; adresa zaá†tku ©†dku
         push      bx                       ; poáet ©†dkñ cihel

; ------ zobrazen° jednoho ©†dku

DispPod2:mov       si,offset ObrCih1        ; vzor cihly - barva
         mov       bl,32                    ; poáet linek na obr†zek

; ------ p©enos jednÇ linky

DispPod4:push      cx
         push      di
DispPod5:movsw
         movsw                              ; p©enos linky
         sub       si,4
         loop      DispPod5
         pop       di
         pop       cx

; ------ p©°prava pro dal®° linku

         add       di,80                    ; adresa dal®° linky
         add       si,4                     ; adresa dal®° linky
         dec       bl                       ; sn°ëen° á°taáe linek
         jnz       DispPod4                 ; p©enos dal®° linky

; ------ p©°prava pro dal®° ©†dek

         dec       bh                       ; sn°ëen° á°taáe dal®°ho ©†dku
         jnz       DispPod2                 ; p©enos dal®°ho ©†dku

; ------ n†vrat parametrñ

         pop       bx                       ; poáet ©†dkñ cihel
         pop       di                       ; adresa ve videopamàti

; ------ volba rovin k z†pisu

         mov       al,8                     ; pouze jasov† rovina
         out       dx,al

; ------ nastaven° registrñ barvy

         mov       dx,3ceh
         mov       al,1
         out       dx,al                    ; volba registru 1
         inc       dx
         mov       al,0                     ; jasov† rovina
         out       dx,al                    ; jas podle dat

; ------ zobrazen° jednoho ©†dku

DispPod6:mov       si,offset ObrCih2        ; vzor cihly - jas
         mov       bl,32                    ; poáet linek na obr†zek

; ------ p©enos jednÇ linky

DispPod7:push      cx
         push      di
DispPod8:movsw
         movsw                              ; p©enos linky
         sub       si,4
         loop      DispPod8
         pop       di
         pop       cx

; ------ p©°prava pro dal®° linku

         add       di,80                    ; adresa dal®° linky
         add       si,4                     ; adresa dal®° linky
         dec       bl                       ; sn°ëen° á°taáe linek
         jnz       DispPod7                 ; p©enos dal®° linky

; ------ p©°prava pro dal®° ©†dek

         dec       bh                       ; sn°ëen° á°taáe dal®°ho ©†dku
         jnz       DispPod6                 ; p©enos dal®°ho ©†dku

; ------ n†vrat registrñ

DispPod9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispPod  ENDP


; *****************************************************************************
;
;                   Univerz†ln° obsluha displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        zobrazen° á°sla
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        SI:BX=á°slo k zobrazen°
;        DI=offset ve videopamàti posledn° á°slice
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

         mov       bp,10
         mov       cx,ax

DispNum1:xor       dx,dx
         mov       ax,si                    ; vy®®° slovo á°sla
         div       bp                       ; vydàlen° vy®®°ho slova
         mov       si,ax                    ; novÇ vy®®° slovo
         mov       ax,bx                    ; nië®° slovo
         div       bp                       ; vydàlen° nië®°ho slova
         mov       bx,ax                    ; novÇ nië®° slovo
         mov       ax,dx                    ; zbytek dàlen°
         add       al,"0"                   ; p©evod na znak ASCII
         mov       ah,ch                    ; barva textu
         call      DispCh                   ; zobrazen° á°slice
         dec       di                       ; posun ukazatele
         mov       ax,si                    ; vy®®° slovo á°sla
         or        ax,bx                    ; je á°slo jië 0 ?
         jnz       DispNum1                 ; zobrazen° dal®°ho á°sla

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet ©†dkñ textu k zobrazen°
;        SI=text k zobrazen°
;        DI=offset ve videopamàti
;        DS=datovò segment
; VùSTUP:SI=adresa n†sleduj°c°ho textu
; -----------------------------------------------------------------------------
; Struktura textu: 0 aë 15 = nastaven° barvy textu (inicializaán° barva = 0)
;                  30 = n†vrat za zaá†tek ©†dku
;                  31 = konec ©†dku
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di

; ------ naáten° znaku textu

         xor       ah,ah                    ; inicializaán° barva = 0
DispTxt1:mov       bx,di                    ; £schova zaá†tku ©†dku
DispTxt2:cld
         lodsb                              ; naáten° bajtu textu

; ------ konec ©†dku

         cmp       al,31                    ; je konec ©†dku ?
         jne       DispTxt3                 ; nen° konec ©†dku
         dec       cx                       ; sn°ëen° á°taáe ©†dkñ
         jz        DispTxt9                 ; jsou jië v®echny ©†dky - konec
         mov       di,bx                    ; n†vrat zaá†tku ©†dku
         add       di,14*80                 ; adresa dal®°ho ©†dku
         jmp       short DispTxt1           ; zobrazen° dal®°ho ©†dku

; ------ n†vrat na zaá†tek ©†dku

DispTxt3:cmp       al,30                    ; je n†vrat na zaá†tek ©†dku ?
         jne       DispTxt4                 ; nen° n†vrat na zaá†tek ©†dku
         mov       di,bx                    ; n†vrat na zaá†tek ©†dku
         jmp       short DispTxt1           ; dal®° bajt textu

; ------ nastaven° barvy textu

DispTxt4:ja        DispTxt5                 ; je bàënò znak
         mov       ah,al                    ; nov† barva textu
         jmp       short DispTxt2           ; dal®° bajt textu

; ------ zobrazen° znaku

DispTxt5:call      DispCh                   ; zobrazen° znaku
         inc       di                       ; zvò®en° adresy ve videopamàti
         jmp       short DispTxt2           ; dal®° bajt textu

; ------ n†vrat registrñ

DispTxt9:pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho znaku
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k zobrazen°
;        AH=barva znaku
;        DI=offset ve videopamàti
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispCh   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es
         mov       ch,ah                    ; barva

; ------ adresa znaku v tabulce fontñ

         sub       al," "                   ; znak v tabulce relativnà
         xor       ah,ah                    ; AX = znak
         mov       si,ax                    ; znak
         shl       si,1                     ; znak * 2
         shl       si,1                     ; znak * 4
         shl       si,1                     ; znak * 8
         sub       si,ax                    ; znak * 7
         shl       si,1                     ; znak * 14
         add       si,offset Font           ; adresa znaku
         cld
         mov       es,ds:[SegVRAM]          ; segment videopamàti

         cmp       byte ptr ds:[ParHerc],0
         je        DispCh0

; ------ zobrazen° znaku

         call      KorRAM

         mov       ah,ch
         mov       cx,14                    ; poáet linek znaku

         cmp       ah,2
         je        DispCh4
         cmp       ah,7
         jne       DispCh7

DispCh4: lodsb                              ; bajt znaku
         or        es:[di],al
         add       di,2000h
         jns       DispCh5
         and       di,7fffh
         add       di,80                    ; adresa dal®° linky znaku
DispCh5: loop      DispCh4                  ; zobrazen° dal®° linky znaku
         jmp       short DispCh9

DispCh7: lodsb                              ; bajt znaku
         not       al
         and       es:[di],al
         add       di,2000h
         jns       DispCh8
         and       di,7fffh
         add       di,80                    ; adresa dal®° linky znaku
DispCh8: loop      DispCh7                  ; zobrazen° dal®° linky znaku
         jmp       short DispCh9



; ------ nastaven° z†pisu do v®ech rovin

DispCh0: mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z†pis do v®ech rovin
         out       dx,al                    ; nastaven° v®ech rovin

; ------ nastaven° barvy znaku

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ch                    ; poëadovan† barva znaku
         out       dx,al                    ; nastaven° barvy znaku
         dec       dx

; ------ nastaven° volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1111b                 ; v®echny roviny podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin
         dec       dx

; ------ p©ednastaven° registru bitovÇ masky

         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx

; ------ zobrazen° znaku

         mov       cx,14                    ; poáet linek znaku
DispCh1: lodsb                              ; bajt znaku
         out       dx,al                    ; nastaven° masky znaku
         xchg      al,es:[di]               ; z†pis znaku
         add       di,80                    ; adresa dal®° linky znaku
         loop      DispCh1                  ; zobrazen° dal®° linky znaku

; ------ n†vrat videoregistrñ

         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; v®echny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; v®echny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ n†vrat registrñ

DispCh9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispCh   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° obdÇln°ku
; -----------------------------------------------------------------------------
; VSTUP: AH=barva obdÇln°ku
;        DI=offset ve videopamàti
;        BX=poáet linek obÇln°ku
;        CX=®°©ka obdÇln°ku v bajtech
; -----------------------------------------------------------------------------

DispBox  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava registrñ k zobrazen°

         mov       es,ds:[SegVRAM]          ; segment videopamàti
         cld
         sti

         cmp       byte ptr ds:[ParHerc],0
         je        DispBox0


; ------ zobrazen° obdÇln°ku

         call      KorRAM
         or        ah,ah
         mov       al,0                     ; z†pisovò bajt
         jz        DispBox4
         not       al
DispBox4:push      di
         push      cx
         rep       stosb                    ; z†pis jednÇ linky
         pop       cx
         pop       di

         add       di,2000h
         jns       DispBox5
         and       di,7fffh
         add       di,80                    ; zvò®en° adresy linky
DispBox5:dec       bx                       ; sn°ëen° á°taáe linek
         jnz       DispBox4                 ; z†pis dal®° linky

         jmp       short DispBox9


; ------ nastaven° z†pisu do v®ech rovin

DispBox0:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z†pis do v®ech rovin
         out       dx,al                    ; nastaven° v®ech rovin

; ------ nastaven° barvy obdÇln°ku

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ah                    ; poëadovan† barva obdÇln°ku
         out       dx,al                    ; nastaven° barvy obdÇln°ku
         dec       dx

; ------ nastaven° volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1111b                 ; v®echny roviny podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin

; ------ zobrazen° obdÇln°ku

         mov       al,0                     ; z†pisovò bajt (nen° dñleëitò)
DispBox1:push      di
         push      cx
         rep       stosb                    ; z†pis jednÇ linky
         pop       cx
         pop       di
         add       di,80                    ; zvò®en° adresy linky
         dec       bx                       ; sn°ëen° á°taáe linek
         jnz       DispBox1                 ; z†pis dal®° linky

; ------ n†vrat registrñ

         out       dx,al                    ; v®echny roviny podle dat
DispBox9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBox  ENDP

; -----------------------------------------------------------------------------
;        korekce adresy ve videopamàti DI pro HERCULES
; -----------------------------------------------------------------------------

KorRAM   PROC      NEAR

         push      bx
         push      dx
         push      ax

         xor       dx,dx
         mov       ax,di
         mov       bx,80
         div       bx
         mov       di,dx

         xor       dx,dx
         mov       bx,4
         div       bx

         mov       bx,dx
         mov       dx,80
         mul       dx
         add       di,ax

         mov       ax,bx
         mov       dx,2000h
         mul       dx
         add       di,ax

         pop       ax
         pop       dx
         pop       bx
         ret

KorRAM   ENDP

; -----------------------------------------------------------------------------
;        ztemnàn° displeje
; -----------------------------------------------------------------------------

Ztemni   PROC      NEAR

; ------ £schova registrñ

         push      si
         push      cx
         mov       cx,20                    ; bude se áekat 20 ms

; ------ 1. ztemnàn°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal1           ; polorozsv°cenò displej
         call      SetPal                   ; nastaven° palet

; ------ 2. ztemnàn°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal2           ; ztemnàlò displej
         call      SetPal                   ; nastaven° palet

; ------ 3. ztemnàn°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal3           ; £plnà temnò displej
         call      SetPal                   ; nastaven° palet

; ------ 4. ztemnàn°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal4           ; £plnà temnò displej
         call      SetPal                   ; nastaven° palet

; ------ 5. ztemnàn°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal5           ; £plnà temnò displej
         call      SetPal                   ; nastaven° palet

; ------ n†vrat registrñ

         pop       cx
         pop       si
         ret

Ztemni   ENDP

; -----------------------------------------------------------------------------
;        rozsv°cen° displeje
; -----------------------------------------------------------------------------

Rozsvit  PROC      NEAR

; ------ £schova registrñ

         push      si
         push      cx
         mov       cx,20                    ; bude se áekat 20 ms

; ------ 1. rozsv°cen°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal4           ; ztemnàlò displej
         call      SetPal                   ; nastaven° palet

; ------ 2. rozsv°cen°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal3           ; ztemnàlò displej
         call      SetPal                   ; nastaven° palet

; ------ 3. rozsv°cen°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal2           ; ztemnàlò displej
         call      SetPal                   ; nastaven° palet

; ------ 4. rozsv°cen°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal1           ; polorozv°cenò displej
         call      SetPal                   ; nastaven° palet

; ------ 5. rozsv°cen°

         call      Cekej                    ; áek†n° na 1 impuls
         mov       si,offset Pal0           ; standardn° displej
         call      SetPal                   ; nastaven° palet

; ------ n†vrat registrñ

         pop       cx
         pop       si
         ret

Rozsvit  ENDP

; -----------------------------------------------------------------------------
;             nastaven° paletovòch registrñ DS:SI
; -----------------------------------------------------------------------------

SetPal   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

         cmp       byte ptr ds:[ParHerc],0
         jne       SetPal9

; ------ áek†n° na vertik†ln° zatemnàn°

         sti                                ; p©eru®en° povoleno
         mov       dx,3dah                  ; stavovò registr videokarty
SetPal1: in        al,dx                    ; áten° stavovÇho registru
         test      al,8                     ; je vertik†ln° impuls ?
         jnz       SetPal1                  ; áek†n° na konec synchroimpulsu
SetPal2: in        al,dx                    ; áten° stavovÇho registru
         test      al,8                     ; je vertik†ln° impuls ?
         jz        SetPal2                  ; áek†n° na vertik†ln° impuls

; ------ volba registru

         cli                                ; z†kaz p©eru®en°
         cld
         xor       ah,ah                    ; ukazatel registrñ
         mov       dx,3c0h                  ; port nastaven° palet
SetPal3: mov       al,ah                    ; paletovò registr
         out       dx,al                    ; volba paletovÇho registru

; ------ nastaven° poëadovanÇ hodnoty registru

         lodsb                              ; hodnota pro nastaven° registru
         out       dx,al                    ; nastaven° palety

; ------ p©°prava pro dal®° registr

         inc       ah                       ; zvò®en° ukazatele registrñ
         cmp       ah,10h                   ; jsou jië v®echny registry ?
         jb        SetPal3                  ; nastaven° dal®°ho registru

; ------ p©edefinov†n° paletovÇho registru pozad°

         mov       al,11h                   ; á°slo registru palety pozad°
         out       dx,al                    ; nastaven° á°sla registru
         lodsb                              ; poëadovan† paleta registru
         out       dx,al                    ; definice palety registru pozad°

; ------ zapnut° videosign†lu

         mov       al,20h                   ; hodnota pro rozsv°cen° displeje
         out       dx,al                    ; rozsv°cen° displeje
         sti                                ; p©eru®en° zase povoleno

; ------ n†vrat registrñ

SetPal9: pop       si
         pop       dx
         pop       ax
         ret

SetPal   ENDP

; *****************************************************************************
;
;                          RñznÇ procedury
;
; *****************************************************************************

;˛
; -----------------------------------------------------------------------------
;        inicializace videokarty HERCULES
; -----------------------------------------------------------------------------

InitHerc PROC      NEAR

         cli                                ; z†kaz p©eru®en°

         mov       al,3
         mov       dx,3bfh
         out       dx,al

         mov       al,2
         mov       dx,3b8h
         out       dx,al

         mov       dx,3b4h
         mov       si,offset tabinit        ; tabulka pro inicializaci
         call      inittab                  ; inicializace podle tabulky

         mov       al,0ah
         mov       dx,3b8h
         out       dx,al

         sti

         push      es
         mov       cx,4000h
         mov       ax,0b000h
         mov       ds:[SegVRAM],ax
         mov       es,ax
         xor       ax,ax
         mov       di,ax
         cld
         rep       stosw
         pop       es

         ret

InitHerc ENDP


; -----------------------------------------------------------------------------
inittab:                                  ;* inic. registrñ podle tabulky
                                            ; VSTUP: DS:SI=ukazatel tabulky
                                            ;        DX=adresa portu

         push      ax
         xor       ah,ah
         cld
inittab2:lodsb
         call      initreg                  ; inicializace registru
         inc       ah
         cmp       ah,12
         jb        inittab2                 ; dal®° registr
         pop       ax
         ret

; -----------------------------------------------------------------------------
initreg:                                  ;* inicializace jednoho registru
                                            ; VSTUP: AH=registr
                                            ;        AL=hodnota pro nastaven°
                                            ;        DX=adresa registru

         push      ax
         mov       al,ah
         out       dx,al                    ; nastaven° á°sla registru
         pop       ax
         inc       dx
         out       dx,al                    ; data pro nastaven° registru
         dec       dx
         ret

; -----------------------------------------------------------------------------
;        test znaku z kl†vesnice (CY=nen°)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si
         push      di
         push      ds
         push      es

; ------ test stavu kl†vesnice

         int       28h
         mov       ah,1
         int       16h
         clc                                ; p©°znak - je kl†vesa
         jnz       TestKey1                 ; je kl†vesa
         stc                                ; p©°znak - nen° kl†vesa

; ------ n†vrat registrñ

TestKey1:pop       es
         pop       ds
         pop       di
         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TestKey  ENDP

;; -----------------------------------------------------------------------------
;;        vstup znaku z kl†vesnice (CY=p©eru®en°)
;; -----------------------------------------------------------------------------
;
;InpCh    PROC      NEAR
;
;         xor       ax,ax
;         int       16h
;         or        ax,ax
;         stc
;         jz        InpCh9
;         cmp       al,27
;         stc
;         je        InpCh9
;         clc
;InpCh9:  ret
;
;InpCh    ENDP
;
; -----------------------------------------------------------------------------
;        zapnut° t¢novÇho gener†toru
; -----------------------------------------------------------------------------
; VSTUP: BX=dàlic° konstanta
;         dw        36485,34437,32505,30680,28958,27333 ; okt†va 0
;         dw        25799,24351,22984,21694,20477,19327
;         dw        18243,17219,16252,15340,14479,13667 ; okt†va 1
;         dw        12899,12175,11492,10847,10238,9664
;         dw        9121,8609,8126,7670,7240,6833       ; okt†va 2
;         dw        6450,6088,5746,5424,5119,4832
;         dw        4561,4305,4063,3835,3620,3417       ; okt†va 3
;         dw        3225,3044,2873,2712,2560,2416
;         dw        2280,2152,2032,1918,1810,1708       ; okt†va 4
;         dw        1612,1522,1437,1356,1280,1208
;         dw        1140,1076,1016,959,905,854          ; okt†va 5
;         dw        806,761,718,678,640,604
;         dw        570,538,508,479,452,427             ; okt†va 6
;         dw        403,380,359,339,320,302
;         dw        285,269,254,240,226,214             ; okt†va 7
;         dw        202,190,180,169,160,151
;         dw        143,135,127,120,113,107             ; okt†va 8
;         dw        101,95,90,85,80,75
;         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt†va 9
; -----------------------------------------------------------------------------

Ton      PROC      NEAR

         cmp       byte ptr ds:[Sound],0    ; je zvuk zapnut ?
         je        Ton9                     ; zvuk je vypnut
         push      ax
         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al
         in        al,[61h]
         or        al,3
         out       [61h],al
         pop       ax
Ton9:    ret

Ton      ENDP

; -----------------------------------------------------------------------------
;        vypnut° zvukovÇho gener†toru
; -----------------------------------------------------------------------------

TonOff   PROC      NEAR

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut° gener†toru
         pop       ax
         ret

TonOff   ENDP

; -----------------------------------------------------------------------------
;                         InitRnd
;                  inicializace gener†toru n†hody
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

InitRnd  PROC      NEAR

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; á°taá systÇmovÇho áasovaáe
         pop       ds
         mov       word ptr ds:[RandomR],ax ; inicializaán° konstanta
         pop       ax
         ret

InitRnd  ENDP

; -----------------------------------------------------------------------------
;                           Random
;                   gener†tor n†hodnÇho á°sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datovò segment
; VùSTUP: AX=á°slo 0 aë (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; poëadovanò rozsah
         call      Random0                  ; generov†n° n†hodnÇho á°sla DX:AX
         xchg      ax,dx                    ; AX <- n†hodnÇ á°slo
         xor       dx,dx
         div       bx
         xchg      ax,dx
Random1: pop       dx
         pop       bx
         ret

Random   ENDP

; -----------------------------------------------------------------------------

Random0  PROC      NEAR

         push      bx
         push      cx
         mov       ax,word ptr ds:[RandomR]
         mov       bx,word ptr ds:[RandomR+2]
         mov       cx,ax
         mul       word ptr cs:[RandomD]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr ds:[RandomR],ax
         mov       word ptr ds:[RandomR+2],dx
         pop       cx
         pop       bx
         ret

Random0  ENDP

; -----------------------------------------------------------------------------
;        cejchov†n° hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

CekInit  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di

         push      ds

; ------ p©°prava registrñ

         sti
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax
         xor       dx,dx                    ; DX <- 0
         mov       di,46ch

; ------ áek†n° na zaá†tek impulsu hodin

         mov       bx,ds:[di]
CekInit1:cmp       bx,ds:[di]
         je        CekInit1                 ; áek†n° na zaá†tek hodin

; ------ mà©en° áasu

         mov       bx,ds:[di]
         EVEN                               ; zarovn†n° na sudou adresu
CekInit2:add       ax,1                     ; á°taá nië®°ho slova áasu
         adc       dx,0                     ; p©enos do vy®®°ho slova
         cmp       bx,ds:[di]               ; byla zmàna ?
         je        CekInit2                 ; áek†n° na zmànu hodin

; ------ vòpoáet konstanty

         mov       bx,55                    ; dàlitel
         cmp       dx,bx                    ; p©eteáen° á°sla ?
         jb        CekInit3                 ; nen° p©eteáen° á°sla
         mov       dx,54                    ; omezen° á°sla
CekInit3:div       bx                       ; vòpoáet konstanty
         or        ax,ax                    ; je = 0 ?
         jnz       CekInit4                 ; nen° = 0
         inc       ax                       ; korekce na 1
CekInit4:
         pop       ds
         mov       ds:[Cit1ms],ax           ; konstanta hodin

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CekInit  ENDP

; -----------------------------------------------------------------------------
;        áek†n° na uplynut° zadanÇho áasu
; -----------------------------------------------------------------------------
; VSTUP: CX=poëadovan† doba v milisekund†ch
;        DS=datovò segment
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ áek†n° po zadanou dobu

         jcxz      Cekej9                   ; nen° ë†dnÇ áek†n°
         mov       di,offset Cit1ms         ; konstanta hodin
Cekej1:  xor       ax,ax                    ; nië®° slovo á°taáe hodin
         xor       dx,dx                    ; vy®®° slovo á°taáe hodin

; ------ á°t†n° doby 1 ms

         EVEN                               ; zarovn†n° na sudou adresu
Cekej2:  add       ax,1                     ; á°taá nië®°ho slova áasu
         adc       dx,0                     ; p©enos do vy®®°ho slova
         cmp       ax,ds:[di]               ; dosaëeno doby 1 ms ?
         jne       Cekej2                   ; á°t†n° doby 1 ms

         loop      Cekej1                   ; áek†n° na dal®° 1 ms

; ------ n†vrat registrñ

Cekej9:  pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 24h
; -----------------------------------------------------------------------------

Int24    PROC      FAR

         xor       al,al                    ; chyby se budou ignorovat
Int23:   iret

Int24    ENDP


; -----------------------------------------------------------------------------
;        Kontroln° souáet CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=zaá†tek bloku dat
;        CX=poáet bajtñ
;        DX=vstupn° hodnota kontroln°ho souátu
; VùSTUP:DX=vòstupn° hodnota kontroln°ho souátu
;        SI=nov† adresa dat
; -----------------------------------------------------------------------------

PUBLIC   CheckSum

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di
         jcxz      CheckSm2                 ; nejsou ë†dn† data
         mov       di,cx                    ; poáet bajtñ pro kontroln° souáet
         cld                                ; smàr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       CheckSm1                 ; dal®° bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSum ENDP

;˛
Code     ENDS

; *****************************************************************************
;
;                       Datovò segment
;
; *****************************************************************************

Data     SEGMENT


; ------ data k uloëen°

ZacTab   label     byte                     ; zaá†tek tabulky hr†áñ
ChSumm   dw        ?                        ; kontroln° souáet CRC tabulky
TabHrac  db        10 dup( 10 dup(" "), 4 dup(0)) ; tabulka hr†áñ
                                            ; (10 bajtñ jmÇno, 4 bajty sk¢re)
Hrac     db        0                        ; aktivn° hr†á (0=nen° ë†dnò)
Summ     dw        ?                        ; bàënò kontroln° souáet souboru

TabBlaf  db        244 - 2 - 10*14 - 1 - 2 dup(0) ; blafuj°c° p©°vaëek

KonTab   label     byte                     ; konec tabulky hr†áñ

; ------ obsluha souboru

AdrSoub  dd        0                        ; adresa jmÇna souboru (0=nen°)

HracSoub db        'TETRIX.DAT',0           ; soubor vòsledkovÇ listiny

; ------ text - vòsledkov† listina

TextList db        ' …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª',31
         db        ' ∫  ',1,'Po©ad° hr†áñ',0,'  ∫',31
         db        ' »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº',31

TextLis2 db        11,'≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤',31


; ------ znaky (14 linek)

Font     db        0,0,0,0,0,0,0                           ; 32  " "
         db        0,0,0,0,0,0,0                      
         db        0,0,18h,3ch,3ch,3ch,18h                 ; 33  "!"
         db        18h,0,18h,18h,0,0,0                
         db        0,66h,66h,66h,24h,0,0                   ; 34  "
         db        0,0,0,0,0,0,0                      
         db        0,0,6ch,6ch,0feh,6ch,6ch                ; 35  "#"
         db        6ch,0feh,6ch,6ch,0,0,0             
         db        18h,18h,7ch,0c6h,0c2h,0c0h,7ch          ; 36  "$"
         db        6,86h,0c6h,7ch,18h,18h,0           
         db        0,0,0,0,0c2h,0c6h,0ch                   ; 37  "%"
         db        18h,30h,66h,0c6h,0,0,0             
         db        0,0,38h,6ch,6ch,38h,76h                 ; 38  "&"
         db        0dch,0cch,0cch,76h,0,0,0           
         db        0,30h,30h,30h,60h,0,0                   ; 39  "'"
         db        0,0,0,0,0,0,0                      
         db        0,0,0ch,18h,30h,30h,30h                 ; 40  "("
         db        30h,30h,18h,0ch,0,0,0              
         db        0,0,30h,18h,0ch,0ch,0ch                 ; 41  ")"
         db        0ch,0ch,18h,30h,0,0,0              
         db        0,0,0,0,66h,3ch,0ffh                    ; 42  "*"
         db        3ch,66h,0,0,0,0,0                  
         db        0,0,0,0,18h,18h,7eh                     ; 43  "+"
         db        18h,18h,0,0,0,0,0                  
         db        0,0,0,0,0,0,0                           ; 44  ","
         db        0,18h,18h,18h,30h,0,0              
         db        0,0,0,0,0,0                             ; 45  "-"
         db        0feh,0,0,0,0,0,0,0                 
         db        0,0,0,0,0,0,0                           ; 46  "."
         db        0,0,18h,18h,0,0,0                  
         db        0,0,2,6,0ch,18h,30h                     ; 47  "/"
         db        60h,0c0h,80h,0,0,0,0               
         db        0,0,7ch,0c6h,0ceh,0deh,0f6h             ; 48  "0"
         db        0e6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,18h,38h,78h,18h,18h                 ; 49  "1"
         db        18h,18h,18h,7eh,0,0,0              
         db        0,0,7ch,0c6h,6,0ch,18h                  ; 50  "2"
         db        30h,60h,0c6h,0feh,0,0,0            
         db        0,0,7ch,0c6h,6,6,3ch                    ; 51  "3"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0,0ch,1ch,3ch,6ch,0cch                ; 52  "4"
         db        0feh,0ch,0ch,1eh,0,0,0             
         db        0,0,0feh,0c0h,0c0h,0c0h,0fch            ; 53  "5"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0,38h,60h,0c0h,0c0h,0fch              ; 54  "6"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0feh,0c6h,6,0ch,18h                 ; 55  "7"
         db        30h,30h,30h,30h,0,0,0              
         db        0,0,7ch,0c6h,0c6h,0c6h,7ch              ; 56  "8"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,7ch,0c6h,0c6h,0c6h,7eh              ; 57  "9"
         db        6,6,0ch,78h,0,0,0                  
         db        0,0,0,18h,18h,0,0                       ; 58  ":"
         db        0,18h,18h,0,0,0,0                  
         db        0,0,0,18h,18h,0,0                       ; 59  ";"
         db        0,18h,18h,30h,0,0,0                
         db        0,0,6,0ch,18h,30h,60h                   ; 60  "<"
         db        30h,18h,0ch,6,0,0,0                
         db        0,0,0,0,0,7eh,0                         ; 61  "="
         db        0,7eh,0,0,0,0,0                    
         db        0,0,60h,30h,18h,0ch,6                   ; 62  ">"
         db        0ch,18h,30h,60h,0,0,0              
         db        0,0,7ch,0c6h,0c6h,0ch,18h               ; 63  "?"
         db        18h,0,18h,18h,0,0,0                
         db        0,0,7ch,0c6h,0c6h,0deh,0deh             ; 64  "@"
         db        0deh,0dch,0c0h,7ch,0,0,0           
         db        0,0,10h,38h,6ch,0c6h,0c6h               ; 65  "A"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,0fch,66h,66h,66h,7ch                ; 66  "B"
         db        66h,66h,66h,0fch,0,0,0             
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 67  "C"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0,0f8h,6ch,66h,66h,66h                ; 68  "D"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        0,0,0feh,66h,62h,68h,78h                ; 69  "E"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,0,0feh,66h,62h,68h,78h                ; 70  "F"
         db        68h,60h,60h,0f0h,0,0,0             
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 71  "G"
         db        0deh,0c6h,66h,3ah,0,0,0            
         db        0,0,0c6h,0c6h,0c6h,0c6h,0feh            ; 72  "H"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,3ch,18h,18h,18h,18h                 ; 73  "I"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,1eh,0ch,0ch,0ch,0ch                 ; 74  "J"
         db        0ch,0cch,0cch,78h,0,0,0            
         db        0,0,0e6h,66h,6ch,6ch,78h                ; 75  "K"
         db        6ch,6ch,66h,0e6h,0,0,0             
         db        0,0,0f0h,60h,60h,60h,60h                ; 76  "L"
         db        60h,62h,66h,0feh,0,0,0             
         db        0,0,0c6h,0eeh,0feh,0feh,0d6h            ; 77  "M"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
;         db        0,0,0c6h,0e6h,0f6h,0feh,0deh            ; 78  "N"
;         db        0ceh,0c6h,0c6h,0c6h,0,0,0
         db        00000000b
         db        00000000b
         db        11000110b
         db        11100110b
         db        11110110b
         db        11111110b
         db        11011110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 79  "O"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,0fch,66h,66h,66h,7ch                ; 80  "P"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0,7ch,0c6h,0c6h,0c6h,0c6h             ; 81  "Q"
         db        0d6h,0deh,7ch,0ch,0eh,0,0          
         db        0,0,0fch,66h,66h,66h,7ch                ; 82  "R"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0,0,7ch,0c6h,0c6h,60h,38h               ; 83  "S"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        0,0,7eh,7eh,5ah,18h,18h                 ; 84  "T"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 85  "U"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 86  "V"
         db        0c6h,6ch,38h,10h,0,0,0             
         db        0,0,0c6h,0c6h,0c6h,0c6h,0d6h            ; 87  "W"
         db        0d6h,0feh,7ch,6ch,0,0,0            
         db        0,0,0c6h,0c6h,6ch,38h,38h               ; 88  "X"
         db        38h,6ch,0c6h,0c6h,0,0,0            
         db        0,0,66h,66h,66h,66h,3ch                 ; 89  "Y"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0feh,0c6h,8ch,18h,30h               ; 90  "Z"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,0,3ch,30h,30h,30h,30h                 ; 91  "["
         db        30h,30h,30h,3ch,0,0,0              
         db        0,0,80h,0c0h,0e0h,70h,38h               ; 92  "\"
         db        1ch,0eh,6,2,0,0,0                  
         db        0,0,3ch,0ch,0ch,0ch,0ch                 ; 93  "]"
         db        0ch,0ch,0ch,3ch,0,0,0              
         db        10h,38h,6ch,0c6h,0,0,0                  ; 94  "^"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,0,0                           ; 95  "_"
         db        0,0,0,0,0,0ffh,0                   
         db        30h,30h,18h,0,0,0,0                     ; 96  "`"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,78h,0ch                       ; 97  "a"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0,0e0h,60h,60h,78h,6ch                ; 98  "b"
         db        66h,66h,66h,7ch,0,0,0              
         db        0,0,0,0,0,7ch,0c6h                      ; 99  "c"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0,1ch,0ch,0ch,3ch,6ch                 ; 100 "d"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,0,0,0,7ch,0c6h                      ; 101 "e"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        0,0,38h,6ch,64h,60h,0f0h                ; 102 "f"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0,0,0,0,76h,0cch                      ; 103 "g"
         db        0cch,0cch,7ch,0ch,0cch,78h,0       
         db        0,0,0e0h,60h,60h,6ch,76h                ; 104 "h"
         db        66h,66h,66h,0e6h,0,0,0             
         db        0,0,18h,18h,0,38h,18h                   ; 105 "i"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,6,6,0,0eh,6                         ; 106 "j"
         db        6,6,6,66h,66h,3ch,0                
         db        0,0,0e0h,60h,60h,66h,6ch                ; 107 "k"
         db        78h,6ch,66h,0e6h,0,0,0             
         db        0,0,38h,18h,18h,18h,18h                 ; 108 "l"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0,0,0,0ech,0feh                     ; 109 "m"
         db        0d6h,0d6h,0d6h,0c6h,0,0,0          
         db        0,0,0,0,0,0dch,66h                      ; 110 "n"
         db        66h,66h,66h,66h,0,0,0              
         db        0,0,0,0,0,7ch,0c6h                      ; 111 "o"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0,0,0,0dch,66h                      ; 112 "p"
         db        66h,66h,7ch,60h,60h,0f0h,0         
         db        0,0,0,0,0,76h,0cch                      ; 113 "q"
         db        0cch,0cch,7ch,0ch,0ch,1eh,0        
         db        0,0,0,0,0,0dch,76h                      ; 114 "r"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0,0,0,0,7ch,0c6h                      ; 115 "s"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0,10h,30h,30h,0fch,30h                ; 116 "t"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,0,0,0,0,0cch,0cch                     ; 117 "u"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,0,0,0,66h,66h                       ; 118 "v"
         db        66h,66h,3ch,18h,0,0,0              
         db        0,0,0,0,0,0c6h,0c6h                     ; 119 "w"
         db        0d6h,0d6h,0feh,6ch,0,0,0           
         db        0,0,0,0,0,0c6h,6ch                      ; 120 "x"
         db        38h,38h,6ch,0c6h,0,0,0             
         db        0,0,0,0,0,0c6h,0c6h                     ; 121 "y"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0,0,0,0,0feh,0cch                     ; 122 "z"
         db        18h,30h,66h,0feh,0,0,0             
         db        0,0,0eh,18h,18h,18h,70h                 ; 123 "{"
         db        18h,18h,18h,0eh,0,0,0              
         db        0,0,18h,18h,18h,18h,0                   ; 124 "|"
         db        18h,18h,18h,18h,0,0,0              
         db        0,0,70h,18h,18h,18h,0eh                 ; 125 "}"
         db        18h,18h,18h,70h,0,0,0              
         db        0,0,76h,0dch,0,0,0                      ; 126 "~"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,10h,38h,6ch                     ; 127 ""
         db        0c6h,0c6h,0feh,0,0,0,0             
         db        66h,3ch,3ch,66h,0c2h,0c0h,0c0h          ; 128 "Ä"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0,0cch,0cch,0,0cch,0cch               ; 129 "Å"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 130 "Ç"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        68h,30h,1ch,0ch,0ch,3ch,6ch             ; 131 "É"
         db        0cch,0cch,0cch,7eh,0,0,0           
         db        0,0,0cch,0cch,0,78h,0ch                 ; 132 "Ñ"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0cch,78h,0f8h,6ch,66h,66h,66h           ; 133 "Ö"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        66h,3ch,7eh,7eh,5ah,18h,18h             ; 134 "Ü"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 135 "á"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 136 "à"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        66h,3ch,0feh,66h,62h,68h,78h            ; 137 "â"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,6,0f6h,64h,60h,60h,60h                ; 138 "ä"
         db        60h,62h,66h,0feh,0,0,0             
         db        0ch,18h,3ch,18h,18h,18h,18h             ; 139 "ã"
         db        18h,18h,18h,3ch,0,0,0              
         db        36h,1ch,70h,30h,30h,30h,30h             ; 140 "å"
         db        30h,30h,30h,78h,0,0,0              
         db        6h,6,74h,30h,30h,30h,30h                ; 141 "ç"
         db        30h,30h,30h,78h,0,0,0              
         db        0,0c6h,0c6h,10h,38h,6ch,0c6h            ; 142 "é"
         db        0c6h,0feh,0c6h,0c6h,0,0,0          
         db        6h,0ch,10h,38h,6ch,0c6h,0c6h            ; 143 "è"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        18h,30h,60h,0,0feh,66h,60h              ; 144 "ê"
         db        7ch,60h,66h,0feh,0,0,0             
         db        0,0,0cch,78h,0,0feh,0cch                ; 145 "ë"
         db        18h,30h,66h,0feh,0,0,0             
         db        66h,3ch,0feh,0c6h,8ch,18h,30h           ; 146 "í"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,10h,38h,6ch,0,7ch,0c6h                ; 147 "ì"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0c6h,0c6h,0,7ch,0c6h                ; 148 "î"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0ch,18h,38h,6ch,0c6h,0c6h,0c6h          ; 149 "ï"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,38h,6ch,38h,0,0cch,0cch               ; 150 "ñ"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0ch,18h,0c6h,0c6h,0c6h,0c6h,0c6h        ; 151 "ó"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0ch,18h,0,0c6h,0c6h                 ; 152 "ò"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0c6h,0c6h,38h,6ch,0c6h,0c6h           ; 153 "ô"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0c6h,0c6h,0,0c6h,0c6h,0c6h            ; 154 "ö"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        66h,3ch,7ch,0c6h,0c6h,60h,38h           ; 155 "õ"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        36h,1ch,0f0h,60h,60h,60h,60h            ; 156 "ú"
         db        60h,62h,66h,0feh,0,0,0             
         db        6h,0ch,66h,66h,66h,66h,3ch              ; 157 "ù"
         db        18h,18h,18h,3ch,0,0,0              
         db        66h,3ch,0fch,66h,66h,66h,7ch            ; 158 "û"
         db        6ch,66h,66h,0f6h,0,0,0             
         db        36h,1ch,10h,30h,30h,0fch,30h            ; 159 "ü"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,18h,30h,60h,0,78h,0ch                 ; 160 "†"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0ch,18h,30h,0,38h,18h                 ; 161 "°"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,18h,30h,60h,0,7ch,0c6h                ; 162 "¢"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,18h,30h,60h,0,0cch,0cch               ; 163 "£"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,66h,3ch,0,0dch,66h                  ; 164 "§"
         db        66h,66h,66h,66h,0,0,0              
         db        66h,3ch,0c6h,0e6h,0f6h,0feh,0deh        ; 165 "•"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,0c6h         ; 166 "¶"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        7ch,0c6h,38h,6ch,0c6h,0c6h,0c6h         ; 167 "ß"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 168 "®"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0,0cch,78h,0,0dch,76h                 ; 169 "©"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0,0ch,18h,0,0dch,76h                  ; 170 "™"
         db        66h,60h,60h,0f0h,0,0,0
         db        0ch,18h,0fch,66h,66h,66h,7ch            ; 171 "´"
         db        6ch,66h,66h,0e6h,0,0,0
         db        0,0c0h,0c0h,0c6h,0cch,0d8h,30h          ; 172 "¨"
         db        66h,0ceh,9eh,3eh,6,6,0
         db        0,0,7ch,0c6h,60h,38h,6ch                ; 173 "≠"
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0
         db        0,0,0,0,36h,6ch,0d8h                    ; 174 "Æ"
         db        6ch,36h,0,0,0,0,0
         db        0,0,0,0,0d8h,6ch,36h                    ; 175 "Ø"
         db        6ch,0d8h,0,0,0,0,0
         db        11h,44h,11h,44h,11h,44h,11h             ; 176 "∞"
         db        44h,11h,44h,11h,44h,11h,44h
         db        55h,0aah,55h,0aah,55h,0aah,55h          ; 177 "±"
         db        0aah,55h,0aah,55h,0aah,55h,0aah
         db        0ddh,77h,0ddh,77h,0ddh,77h,0ddh         ; 178 "≤"
         db        77h,0ddh,77h,0ddh,77h,0ddh,77h
         db        18h,18h,18h,18h,18h,18h,18h             ; 179 "≥"
         db        18h,18h,18h,18h,18h,18h,18h
         db        18h,18h,18h,18h,18h,18h,18h             ; 180 "¥"
         db        0f8h,18h,18h,18h,18h,18h,18h
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 181 "µ"
         db        0f8h,18h,18h,18h,18h,18h,18h
         db        36h,36h,36h,36h,36h,36h,36h             ; 182 "∂"
         db        0f6h,36h,36h,36h,36h,36h,36h
         db        0,0,0,0,0,0,0                           ; 183 "∑"
         db        0feh,36h,36h,36h,36h,36h,36h
         db        0,0,0,0,0,0f8h,18h                      ; 184 "∏"
         db        0f8h,18h,18h,18h,18h,18h,18h
         db        36h,36h,36h,36h,36h,0f6h,6              ; 185 "π"
         db        0f6h,36h,36h,36h,36h,36h,36h

;         db        36h,36h,36h,36h,36h,36h,36h             ; 186 "∫"
;         db        36h,36h,36h,36h,36h,36h,36h
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

;         db        0,0,0,0,0,0feh,6                        ; 187 "ª"
;         db        0f6h,36h,36h,36h,36h,36h,36h
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00001100b
         db        11000110b
         db        01100110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

;         db        36h,36h,36h,36h,36h,0f6h,6              ; 188 "º"
;         db        0feh,0,0,0,0,0,0
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        01100110b
         db        11000110b
         db        00001100b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        36h,36h,36h,36h,36h,36h,36h             ; 189 "Ω"
         db        0feh,0,0,0,0,0,0
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 190 "æ"
         db        0f8h,0,0,0,0,0,0
         db        0,0,0,0,0,0,0                           ; 191 "ø"
         db        0f8h,18h,18h,18h,18h,18h,18h
         db        18h,18h,18h,18h,18h,18h,18h             ; 192 "¿"
         db        1fh,0,0,0,0,0,0
         db        18h,18h,18h,18h,18h,18h,18h             ; 193 "¡"
         db        0ffh,0,0,0,0,0,0
         db        0,0,0,0,0,0,0                           ; 194 "¬"
         db        0ffh,18h,18h,18h,18h,18h,18h
         db        18h,18h,18h,18h,18h,18h,18h             ; 195 "√"
         db        1fh,18h,18h,18h,18h,18h,18h
         db        0,0,0,0,0,0,0                           ; 196 "ƒ"
         db        0ffh,0,0,0,0,0,0
         db        18h,18h,18h,18h,18h,18h,18h             ; 197 "≈"
         db        0ffh,18h,18h,18h,18h,18h,18h
         db        18h,18h,18h,18h,18h,1fh,18h             ; 198 "∆"
         db        1fh,18h,18h,18h,18h,18h,18h
         db        36h,36h,36h,36h,36h,36h,36h             ; 199 "«"
         db        37h,36h,36h,36h,36h,36h,36h
;         db        36h,36h,36h,36h,36h,37h,30h             ; 200 "»"
;         db        3fh,0,0,0,0,0,0
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110011b
         db        00110001b
         db        00011000b
         db        00001111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

;         db        0,0,0,0,0,3fh,30h                       ; 201 "…"
;         db        37h,36h,36h,36h,36h,36h,36h
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00001111b
         db        00011000b
         db        00110001b
         db        00110011b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        36h,36h,36h,36h,36h,0f7h,0              ; 202 " "
         db        0ffh,0,0,0,0,0,0
         db        0,0,0,0,0,0ffh,0                        ; 203 "À"
         db        0f7h,36h,36h,36h,36h,36h,36h
         db        36h,36h,36h,36h,36h,37h,30h             ; 204 "Ã"
         db        37h,36h,36h,36h,36h,36h,36h

;         db        0,0,0,0,0,0ffh,0                        ; 205 "Õ"
;         db        0ffh,0,0,0,0,0,0
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        36h,36h,36h,36h,36h,0f7h,0              ; 206 "Œ"
         db        0f7h,36h,36h,36h,36h,36h,36h
         db        18h,18h,18h,18h,18h,0ffh,0              ; 207 "œ"
         db        0ffh,0,0,0,0,0,0
         db        36h,36h,36h,36h,36h,36h,36h             ; 208 "–"
         db        0ffh,0,0,0,0,0,0
         db        0,0,0,0,0,0ffh,0                        ; 209 "—"
         db        0ffh,18h,18h,18h,18h,18h,18h
         db        0,0,0,0,0,0,0                           ; 210 "“"
         db        0ffh,36h,36h,36h,36h,36h,36h
         db        36h,36h,36h,36h,36h,36h,36h             ; 211 "”"
         db        3fh,0,0,0,0,0,0
         db        18h,18h,18h,18h,18h,1fh,18h             ; 212 "‘"
         db        1fh,0,0,0,0,0,0
         db        0,0,0,0,0,1fh,18h                       ; 213 "’"
         db        1fh,18h,18h,18h,18h,18h,18h
         db        0,0,0,0,0,0,0                           ; 214 "÷"
         db        3fh,36h,36h,36h,36h,36h,36h
         db        36h,36h,36h,36h,36h,36h,36h             ; 215 "◊"
         db        0ffh,36h,36h,36h,36h,36h,36h
         db        18h,18h,18h,18h,18h,0ffh,18h            ; 216 "ÿ"
         db        0ffh,18h,18h,18h,18h,18h,18h
         db        18h,18h,18h,18h,18h,18h,18h             ; 217 "Ÿ"
         db        0f8h,0,0,0,0,0,0
         db        0,0,0,0,0,0,0                           ; 218 "⁄"
         db        1fh,18h,18h,18h,18h,18h,18h
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 219 "€"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
         db        0,0,0,0,0,0,0                           ; 220 "‹"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h      ; 221 "›"
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh             ; 222 "ﬁ"
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 223 "ﬂ"
         db        0,0,0,0,0,0,0

;         db        0,0,0,0,0,76h,0dch                      ; 224 "‡"
;         db        0d8h,0d8h,0dch,76h,0,0,0
         db        00011000b
         db        00111100b
         db        01111110b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

;         db        0,0,0,0,7ch,0c6h,0fch                   ; 225 "·"
;         db        0c6h,0c6h,0fch,0c0h,0c0h,40h,0
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        01111110b
         db        00111100b
         db        00011000b

;         db        0,0,0feh,0c6h,0c6h,0c0h,0c0h            ; 226 "‚"
;         db        0c0h,0c0h,0c0h,0c0h,0,0,0
         db        00000000b
         db        00000000b
         db        00001000b
         db        00001100b
         db        00001110b
         db        11111111b
         db        11111111b
         db        00001110b
         db        00001100b
         db        00001000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

;         db        0,0,0,0,0feh,6ch,6ch                    ; 227 "„"
;         db        6ch,6ch,6ch,6ch,0,0,0
         db        00000000b
         db        00000000b
         db        00010000b
         db        00110000b
         db        01110000b
         db        11111111b
         db        11111111b
         db        01110000b
         db        00110000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

;         db        0,0,0feh,0c6h,60h,30h,18h               ; 228 "‰"
;         db        30h,60h,0c6h,0feh,0,0,0
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

;         db        0,0,0,0,0,7eh,0d8h                      ; 229 "Â"
;         db        0d8h,0d8h,0d8h,70h,0,0,0
         db        00000000b
         db        00000000b
         db        00000011b
         db        00000011b
         db        00000011b
         db        00000011b
         db        00000000b
         db        01111011b
         db        01111011b
         db        01111011b
         db        01111011b
         db        00000000b
         db        00000000b
         db        00000000b


;         db        0,0,0,0,66h,66h,66h                     ; 230 "Ê"
;         db        66h,7ch,60h,60h,0c0h,0,0
         db        00000000b
         db        00000000b
         db        11011110b
         db        11011110b
         db        11011110b
         db        11011110b
         db        00000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b


;         db        0,0,0,0,76h,0dch,18h                    ; 231 "Á"
;         db        18h,18h,18h,18h,0,0,0
         db        00000000b
         db        00000000b
         db        00000111b
         db        00001111b
         db        00011100b
         db        00011000b
         db        11111111b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000001b
         db        00000000b
         db        00000000b


;         db        0,0,7eh,18h,3ch,66h,66h                 ; 232 "Ë"
;         db        66h,3ch,18h,7eh,0,0,0
         db        00000000b
         db        00000000b
         db        11111000b
         db        11111100b
         db        00001110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00001110b
         db        11111100b
         db        11111000b
         db        00000000b
         db        00000000b


;         db        0,0,38h,6ch,0c6h,0c6h,0feh              ; 233 "È"
;         db        0c6h,0c6h,6ch,38h,0,0,0
         db        00011000b
         db        00111100b
         db        00111100b
         db        00011000b
         db        00111100b
         db        01111100b
         db        10111010b
         db        00111000b
         db        00101000b
         db        01001000b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b


;         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 234 "Í"
;         db        6ch,6ch,6ch,0eeh,0,0,0
         db        00011000b
         db        00111100b
         db        00111100b
         db        00011000b
         db        01111100b
         db        10111011b
         db        10111000b
         db        00111000b
         db        00101100b
         db        11100100b
         db        10000110b
         db        00000000b
         db        00000000b
         db        00000000b


;         db        0,0,1eh,30h,18h,0ch,3eh                 ; 235 "Î"
;         db        66h,66h,66h,3ch,0,0,0
         db        00000001b
         db        00000011b
         db        00000111b
         db        00001101b
         db        00011001b
         db        00110001b
         db        00100011b
         db        00100111b
         db        00100111b
         db        00100110b
         db        01100000b
         db        11100000b
         db        11100000b
         db        11000000b


;         db        0,0,0,0,0,7eh,0dbh                      ; 236 "Ï"
;         db        0dbh,7eh,0,0,0,0,0
         db        00000001b
         db        00000011b
         db        00000111b
         db        00001101b
         db        00011001b
         db        00110001b
         db        00100011b
         db        00100101b
         db        00100101b
         db        00100110b
         db        01100000b
         db        10100000b
         db        10100000b
         db        11000000b


;         db        0,0,3,6,7eh,0dbh,0dbh                   ; 237 "Ì"
;         db        0f3h,7eh,60h,0c0h,0,0,0
;         db        0,0,1ch,30h,60h,60h,7ch                 ; 238 "Ó"
;         db        60h,60h,30h,1ch,0,0,0
;         db        0,0,0,7ch,0c6h,0c6h,0c6h                ; 239 "Ô"
;         db        0c6h,0c6h,0c6h,0c6h,0,0,0
;         db        0,0,0,0feh,0,0,0feh                     ; 240 ""
;         db        0,0,0feh,0,0,0,0
;         db        0,0,0,18h,18h,7eh,18h                   ; 241 "Ò"
;         db        18h,0,0,0ffh,0,0,0
;         db        0,0,30h,18h,0ch,6,0ch                   ; 242 "Ú"
;         db        18h,30h,0,7eh,0,0,0
;         db        0,0,0ch,18h,30h,60h,30h                 ; 243 "Û"
;         db        18h,0ch,0,7eh,0,0,0
;         db        0,0,0eh,1bh,1bh,18h,18h                 ; 244 "Ù"
;         db        18h,18h,18h,18h,18h,18h,18h
;         db        18h,18h,18h,18h,18h,18h,18h             ; 245 "ı"
;         db        18h,0d8h,0d8h,70h,0,0,0
;         db        0,0,0,18h,18h,0,7eh                     ; 246 "ˆ"
;         db        0,18h,18h,0,0,0,0
;         db        0,0,0,0,76h,0dch,0                      ; 247 "˜"
;         db        76h,0dch,0,0,0,0,0
;         db        0,38h,6ch,6ch,38h,0,0                   ; 248 "¯"
;         db        0,0,0,0,0,0,0
;         db        0,0,0,0,0,0,18h                         ; 249 "˘"
;         db        18h,0,0,0,0,0,0
;         db        0,0,0,0,0,0,0                           ; 250 "˙"
;         db        18h,0,0,0,0,0,0
;         db        0,0fh,0ch,0ch,0ch,0ch,0ch               ; 251 "˚"
;         db        0ech,6ch,3ch,1ch,0,0,0
;         db        0,0d8h,6ch,6ch,6ch,6ch,6ch              ; 252 "¸"
;         db        0,0,0,0,0,0,0
;         db        0,70h,0d8h,30h,60h,0c8h,0f8h            ; 253 "˝"
;         db        0,0,0,0,0,0,0
;         db        0,0,0,0,7ch,7ch,7ch                     ; 254 "˛"
;         db        7ch,7ch,7ch,0,0,0,0
;         db        0,0,0,0,0,0,0                           ; 255
;         db        0,0,0,0,0,0,0

; ------ podkladov† cihla - barva

ObrCih1  db        0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
         db        0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
         db        0,0,0,1,0,0,0,1,0ffh,0ffh,0ffh,0ffh,0,20h,0,0
         db        0,20h,0,0,0,20h,0,0,0,20h,0,0,0,20h,0,0
         db        0,20h,0,0,0,20h,0,0,0,20h,0,0,0,20h,0,0
         db        0,20h,0,0,0ffh,0ffh,0ffh,0ffh,0,0,4,0,0,0,4,0
         db        0,0,4,0,0,0,4,0,0,0,4,0,0,0,4,0
         db        0,0,4,0,0,0,4,0,0,0,4,0,0ffh,0ffh,0ffh,0ffh

; ------ podkladov† cihla - jas

ObrCih2  label     byte
db       11111111b,11111111b,11111111b,11111000b
db       11111111b,11010110b,11010011b,10011000b
db       11111111b,11101011b,11111111b,11101000b
db       11111111b,10111111b,10110101b,01111000b
db       11011101b,11100110b,11111111b,11010000b
db       10111101b,11011110b,10111011b,10111000b
db       11101111b,11111111b,11110110b,11110000b
db       10111010b,11111011b,01011111b,10010000b
db       11010111b,11001111b,00110110b,10100000b
db       00000000b,00000000b,00000000b,00000000b
db       00000000b,00000000b,00000000b,00000000b
db       11111111b,00011111b,11111111b,11111111b
db       11111011b,10011011b,11011111b,11111011b
db       11111101b,00011011b,01110111b,11110111b
db       10111010b,00011111b,11111111b,10110111b
db       11111111b,00011110b,11111110b,11111110b
db       10011101b,00011101b,10111011b,11111111b
db       11111010b,00011111b,01010111b,01111011b
db       10111101b,00011101b,11011111b,11111011b
db       01101010b,00011110b,01101011b,01100110b
db       00000000b,00000000b,00000000b,00000000b
db       00000000b,00000000b,00000000b,00000000b
db       11111111b,11111111b,11100011b,11111111b
db       10111110b,11101111b,10100011b,11101110b
db       11111110b,11111111b,01100011b,01111110b
db       11101111b,11101111b,11100011b,11111111b
db       01111011b,10111110b,11100011b,10111011b
db       11011111b,11111111b,01000011b,11111110b
db       11111101b,01111011b,10100011b,10111011b
db       00111100b,11001101b,01000011b,11101101b
db       00000000b,00000000b,00000000b,00000000b
db       00000000b,00000000b,00000000b,00000000b

; ------ podkladov† cihla - HERCULES

ObrCih3  label     byte
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b
db       11111111b,11111111b,11111111b,11111111b
db       10111011b,10111011b,10111011b,10111011b
db       11111111b,11111111b,11111111b,11111111b
db       11101110b,11101110b,11101110b,11101110b


; ------ hrac° k†men

ObrKam   db        11111111b,11111110b
         db        11111111b,11111100b
         db        11010101b,01010000b
         db        11101010b,10101000b
         db        11010101b,01010000b
         db        11101010b,10101000b
         db        11010101b,01010000b
         db        11101010b,10101000b
         db        11010101b,01010000b
         db        11101010b,10101000b
         db        11010101b,01010000b
         db        11101010b,10101000b
         db        11010101b,01010000b
         db        11000000b,00000000b
         db        10000000b,00000000b
         db        00000000b,00000000b

; ------ okoln° r†m

ObrRam   db        01111011b
         db        11011111b
         db        11111111b
         db        11110111b
         db        01111111b
         db        11111101b
         db        11011111b
         db        11111111b

; ------ z†clona

ObrZacl  db        11111111b,11111111b      ; modr† rovina
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111110b,11111111b
         db        11101100b,00011111b
         db        11100000b,00000110b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b

         db        00000000b,00000000b      ; zelen† rovina
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000000b,00000000b
         db        00000001b,00000000b
         db        00010001b,00000000b
         db        00010010b,00010001b
         db        00100001b,00100001b
         db        00010010b,00010010b
         db        00010000b,00100001b
         db        00000000b,00000010b

         db        11111111b,11111111b      ; áerven† rovina
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111111b,11111111b
         db        11111101b,00011111b
         db        11110010b,00010111b
         db        00100001b,00100001b
         db        00010010b,00010010b
         db        00100000b,00100001b
         db        00000000b,00000010b

         db        11000000b,00001101b      ; jasov† rovina
         db        11100000b,00000111b
         db        01000000b,00010101b
         db        10000000b,00001110b
         db        01000000b,00000011b
         db        10100000b,00010011b
         db        11000000b,00000111b
         db        01000000b,00001010b
         db        01100000b,00000110b
         db        10000001b,00010011b
         db        11010001b,00000111b
         db        10110010b,00010111b
         db        00100001b,00100001b
         db        00010010b,00010010b
         db        00100000b,00100001b
         db        00000000b,00000010b

ObrZacl2 db        11010100b,00101101b      ; hercules
         db        11101001b,00000111b
         db        01110100b,01010101b
         db        10100001b,00101110b
         db        11010100b,01101011b
         db        11101001b,01010111b
         db        11100100b,10010111b
         db        01110001b,01001010b
         db        11100100b,00100111b
         db        10101001b,11010111b
         db        11101101b,11011111b
         db        11110010b,00010111b
         db        00100001b,00100001b
         db        00010010b,00010010b
         db        00100000b,00100001b
         db        00000000b,00000010b


Uroven   db        5                        ; aktivn° £rove§

ErrCard  db        'Program vyzaduje grafickou kartu EGA, VGA nebo Hercules !',13,10,'$'

TabCih   label     byte                     ; tabulka definic cihel

                                            ; 0: zrcadlovÇ Z - f†ze 1
         db         0, 0, 0, 0
         db         0, 9, 9, 0
         db         9, 9, 0, 0
         db         0, 0, 0, 0
                                            ; 1: Z - f†ze 1
         db         0, 0, 0, 0
         db        10,10, 0, 0
         db         0,10,10, 0
         db         0, 0, 0, 0
                                            ; 2: L - f†ze 1
         db         0, 0, 0, 0
         db        11,11,11, 0
         db        11, 0, 0, 0
         db         0, 0, 0, 0
                                            ; 3: zrcadlovÇ L - f†ze 1
         db         0, 0, 0, 0
         db        12,12,12, 0
         db         0, 0,12, 0
         db         0, 0, 0, 0
                                            ; 4: T - f†ze 1
         db         0, 0, 0, 0
         db        13,13,13, 0
         db         0,13, 0, 0
         db         0, 0, 0, 0
                                            ; 5: I - f†ze 1
         db         0, 0, 0, 0
         db        14,14,14,14
         db         0, 0, 0, 0
         db         0, 0, 0, 0
                                            ; 6: átverec
         db         0, 0, 0, 0
         db         0,15,15, 0
         db         0,15,15, 0
         db         0, 0, 0, 0
                                            ; 7: zrcadlovÇ Z - f†ze 2
         db         0, 9, 0, 0
         db         0, 9, 9, 0
         db         0, 0, 9, 0
         db         0, 0, 0, 0
                                            ; 8: Z - f†ze 2
         db         0,10, 0, 0
         db        10,10, 0, 0
         db        10, 0, 0, 0
         db         0, 0, 0, 0
                                            ; 9: L - f†ze 2
         db         0,11, 0, 0
         db         0,11, 0, 0
         db         0,11,11, 0
         db         0, 0, 0, 0
                                            ; 10: L - f†ze 3
         db         0, 0, 0, 0
         db         0, 0,11, 0
         db        11,11,11, 0
         db         0, 0, 0, 0
                                            ; 11: L - f†ze 4
         db        11,11, 0, 0
         db         0,11, 0, 0
         db         0,11, 0, 0
         db         0, 0, 0, 0
                                            ; 12: zrcadlovÇ L - f†ze 2
         db         0,12,12, 0
         db         0,12, 0, 0
         db         0,12, 0, 0
         db         0, 0, 0, 0
                                            ; 13: zrcadlovÇ L - f†ze 3
         db         0, 0, 0, 0
         db        12, 0, 0, 0
         db        12,12,12, 0
         db         0, 0, 0, 0
                                            ; 14: zrcadlovÇ L - f†ze 4
         db         0,12, 0, 0
         db         0,12, 0, 0
         db        12,12, 0, 0
         db         0, 0, 0, 0
                                            ; 15: T - f†ze 2
         db         0,13, 0, 0
         db         0,13,13, 0
         db         0,13, 0, 0
         db         0, 0, 0, 0
                                            ; 16: T - f†ze 3
         db         0, 0, 0, 0
         db         0,13, 0, 0
         db        13,13,13, 0
         db         0, 0, 0, 0
                                            ; 17: T - f†ze 4
         db         0,13, 0, 0
         db        13,13, 0, 0
         db         0,13, 0, 0
         db         0, 0, 0, 0
                                            ; 18: I - f†ze 2
         db         0, 0,14, 0
         db         0, 0,14, 0
         db         0, 0,14, 0
         db         0, 0,14, 0


                                            ; tabulka rotac° cihel
RotCih   db        7,8,9,12,15,18,6,0,1,10,11,2,13,14,3,16,17,4,5
MaxRot   db        2,2,4,4,4,2,1,2,2,4,4,4,4,4,4,4,4,4,2

; ------ definice palet

Pal0     db        0,1,2,3,4,5,6,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0 ; standard
Pal1     db        0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0
Pal2     db        0,8,10h,18h,20h,28h,30h,38h,0,1,2,3,4,5,6,7,0
Pal3     db        0,8,10h,18h,20h,28h,30h,38h,0,8,10h,18h,20h,28h,30h,38h,0
Pal4     db        0,0,0,0,0,0,0,0,0,8,10h,18h,20h,28h,30h,38h,0
Pal5     db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; temnò displej

; ------ n†povàda


TextHlp  label     byte
         db        4,' …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª',31
         db        4,' ∫    ',1,'Ovl†d†n°',4,'    ∫',31
         db        4,' »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº',31
TextHlp1 db        7,'   ﬁ€›    ﬁ€›    ﬁ€›',30
         db        4,' ',227,228,1,' 4   ',4,231,232,1,' 5   ',4,228,226,1,' 6',31
         db        7,'    ﬁ€€€€€€›  ﬁ€›',30
         db        4,'   ',225,1,' Mezera  ',4
SoundChr db        235,1,' S',31
         db        7,'   ﬁ€›    ﬁ€›    ﬁ€›',30
         db        4,' ',229,230,1,' 1    ',4,233,1,' 3',4,'    ',4,234,1,' 9',31

TextHlp3 db        1,'     Stisknàte',31
         db        '    libovolnou',31
         db        '      kl†vesu',31

TextHlp5 db        4,' 0',1,' aë ',4,'9',1,' rychlost',31
         db        4,' Mezera',1,' start hry',31
         db        4,' H',1,'      volba hr†áe',31
         db        4,' N',1,'      novò hr†á',31
         db        4,' Z',1,'      zru®it hr†áe',31
         db        4,' D',1,'      demonstrace',31

TextHlp6 db        4,224,225,1,'    zmàna hr†áe',31
         db        4,'Enter',1,' vòbàr hr†áe',31
         db        4,'Esc',1,'   p©eru®en°',31

TextHlp7 db        1,'zadejte svÇ jmÇno:',31
         db        4,227,228,1,'    zru®en° znaku',31
         db        4,'Enter',1,' konec zad†n°',31
         db        4,'Esc',1,'   p©eru®en°',31

TextHlp8 db        1,' p©eru®en°',31
         db        4,'DEMONSTRACE',31
         db        1,'libovolnou',31
         db        1,' kl†vesou',31

TextHlp9 db        1,'  Chcete opravdu',31
         db        1,' zru®it aktivn°ho',31
         db        1,' hr†áe z tabulky ?',31
         db        31
         db        4,' A',1,' = ANO, zru®it',31

TextHlpA db        1,'Chcete opravdu',31
         db        1,'p©eru®it hru ?',31
         db        31
         db        4,'    A',1,' = ANO',31

; ------ texty - sk¢re

TextSkor db        4,'Rychlost',31
         db        4,'Sk¢re',31
         db        4,'û†dkñ',31

TextNext db        14,'P©°®t°',31
         db        14,'cihla',31

; ------ licenán° text

TextLic0 db        7,'≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤',30
TextLic  db        11,'(c) Miroslav Nàmeáek',31

TextTet0 db        7,'≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤',30
TextTet  db        11,'T E T R I X   V 1.40',31

; ------ text - konec

TextKon  db        0,' K O N E C    H R Y',31
ColKon   db        0,1,9,3,11,3,9,1

Nadp1    db        0,'T  E  T  R  I  X',31
Nadp2    db        15,'T  E  T  R  I  X',31

; ------ informaán° text

;UkazTxt  dw        ?                        ; ukazatel textu (zaá†tek ©†dku)
;LinkaTxt dw        ?                        ; zobrazen† linka textu
;CasRekl  dw        ?                        ; á°taá áasu reklamy
;
;Text     label     byte
;db '                    '
;db '    GOLEM uv†d°     '
;db ' …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª  '
;db ' ∫  T E T R I X  ∫  '
;db ' »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº  '
;db ' hra z programovÇho '
;db ' bal°ku DOS Manaëer '
;db '                    '
;db '     * V1.30 *      '
;db '                    '
;db 'Hra TETRIS pat©° jië'
;db 'nàkolik  let  k nej-'
;db 'hranàj®°m   hr†m  na'
;db 'celÇm svàtà. Vzniklo'
;db 'mnoho   verz°   tÇto'
;db 'hry,  áasto kvalitou'
;db 'p©evy®uj°c°  pñvodn°'
;db 'ruskou verzi.       '
;db '                    '
;db 'Program,  kterò m†te'
;db 'nyn°   p©ed   sebou,'
;db 'vych†z°   z  pñvodn°'
;db 'ruskÇ  verze,  snaë°'
;db 'se   ale   odstranit'
;db 'jej°   nedostatky  a'
;db 'chyby.  Od   pñvodn°'
;db 'verze  se  odchyluje'
;db 'p©edev®°m v tom,  ëe'
;db 'rychlost   hry   lze'
;db 'mànit  bàhem hry dle'
;db 'vlastn°ho    uv†ëen°'
;db 'nahoru i dolñ. S t°m'
;db 'v®ak  souvis°  i pa-'
;db 't©iánà vàt®° rozd°ly'
;db 'v  bodov†n° v z†vis-'
;db 'losti   na   zvolenÇ'
;db 'rychlosti.          '
;db '                    '
;db 'Pokud se V†m program'
;db 'bude l°bit, bude n†s'
;db 'velmi tà®it, za©ad°-'
;db 'te-li si jej do Va®°'
;db 'knihovny  FREEWARE a'
;db 'SHAREWARE,     anebo'
;db 'je®tà lÇpe - darujte'
;db 'jej  i svòm  zn†mòm.'
;db 'Program mñëete volnà'
;db '®°©it  a   pouë°vat,'
;db 'nesm° v®ak bòt nijak'
;db 'modifikov†n  a nesm°'
;db 'bòt    pouë°v†n   ke'
;db 'komerán°m £áelñm bez'
;db 'souhlasu autora.    '
;db '                    '
;db 'A kdo se  V†m snaëil'
;db 'zp©°jemnit V†® volnò'
;db 'áas ?               '
;db '                    '
;db '"Tento  program  V†m'
;db 'p©in†®° firma GOLEM,'
;db 'vòrobce     programñ'
;db 'HRADBA a DOSMAN."   '
;db '                    '
;db 'Na®e adresa:        '
;db 'GOLEM, P.O. Box 66, '
;db 'Roënov pod Radho®tàm'
;db '756 61              '
;db '                    '
;db 'telefon a fax:      '
;db '(0651) 54044        '
;db '                    '
;db 'A na®e heslo:       '
;db '"Efektivnà programo-'
;db 'vat znamen†  progra-'
;db 'movat v ASSEMBLERU."'
;db '                    '
;db 'Bude n†s tà®it, kdyë'
;db 'n†m   nap°®ete  Va®e'
;db 'p©ipom°nky  k tomuto'
;db 'programu.   A  je®tà'
;db 'v°ce n†s bude tà®it,'
;db 'kdyë se u n†s budete'
;db 'informovat o dal®°ch'
;db 'produktech      na®°'
;db 'firmy.  Postaá°  n†m'
;db 'zavolat  nebo napsat'
;db 'a   my  V†m  za®leme'
;db 'informace  a  propa-'
;db 'gaán°      materi†ly'
;db 'k na®im  nejnovàj®°m'
;db 'produktñm,  p©°padnà'
;db 'tÇë   jejich  demon-'
;db 'straán°  verze.  P©i'
;db 'v°cen†sobnÇm  odbàru'
;db 'programñ poskytujeme'
;db 'vòraznÇ slevy.      '
;db '                    '
;db 'Z  na®°  nab°dky V†m'
;db 'doporuáujeme  k  po-'
;db 'v®imnut°   p©edev®°m'
;db 'program DOS Manaëer.'
;db 'Tento   program  V†m'
;db 'usnadn°        pr†ci'
;db 's poá°taáem.  Pomoc°'
;db 'jeho   oken   mñëete'
;db 'snadno nahlÇdnout do'
;db 'adres†©ñ   diskñ   a'
;db 'stiskem jednÇ kl†ve-'
;db 'sy spustit jakòkoliv'
;db 'program nebo provÇst'
;db 'jakoukoliv  operaci.'
;db 'P©itom vñbec nemus°-'
;db 'te   zn†t   operaán°'
;db 'systÇm,  program  se'
;db 'star† o v®e za  V†s.'
;db 'DOS Manaëer  pracuje'
;db 'spr†vnà  jak  na  XT'
;db 'bez  pevnÇho  disku,'
;db 'tak  i  v  s°ti.  Na'
;db 'disku i  v pamàti mu'
;db 'postaá°  jen  60 kB,'
;db 'trval† á†st p©i bàhu'
;db 'jinÇho  programu  je'
;db '3 KB. S  DOS Manaëe-'
;db 'rem obdrë°te n†rodn°'
;db 'prost©ed°  pro disp-'
;db 'lej  i  kl†vesnici a'
;db 'mnoho jinòch utilit.'
;db '                    '
;db 'Chcete-li   u®et©it,'
;db 'nab°z°me  V†m mikro-'
;db 'verzi   DOS Manaëeru'
;db 's n†zvem   MIKROMAN,'
;db 'zaji®üuj°c°    pouze'
;db 'jeho  nejz†kladnàj®°'
;db 'funkce.             '
;db '                    '
;db 'Pro  V†® poá°taá V†m'
;db 'mñëeme  d†le  nab°d-'
;db 'nout       kompletn°'
;db 'n†rodn°    prost©ed°'
;db '(áe®tina  a  sloven-'
;db '®tina)  pro displej,'
;db 'kl†vesnici i tisk†r-'
;db 'ny váetnà laserovòch'
;db 'a  to  v®e  za velmi'
;db 'n°zkÇ ceny a s mini-'
;db 'm†ln°mi   n†roky  na'
;db 'pamàü.              '
;db '                    '
;db 'Pro  p©enos dat mezi'
;db 'poá°taái V†m nab°z°-'
;db 'me  komunikaán° pro-'
;db 'gramy a to pro sÇri-'
;db 'ovò    i   paraleln°'
;db 'port.  Po paraleln°m'
;db 'portu mñëete p©enÇst'
;db 'obsah plnÇho pevnÇho'
;db 'disku 20 MB za nece-'
;db 'lòch  15 minut (dis-'
;db 'ketami   to   budete'
;db 'dàlat celò den).    '
;db '                    '
;db 'Vlastn°te-li diskety'
;db '360 KB, nainstalujte'
;db 'si    n†®    program'
;db 'FLOPPY  a  mñëete je'
;db 'pouë°vat £plnà bàënà'
;db 's kapacitou 720 KB. '
;db '                    '
;db 'Boj°te   se  virñ  ?'
;db 'S n†mi  se  nemus°te'
;db 'b†t ani Michelangela'
;db 'ani jinòch virñ.    '
;db '                    '
;db 'Boj°te se o sv† data'
;db 'a  programy ? Mñëete'
;db 'si je uzamknout hes-'
;db 'lem   nebo   kl°áem.'
;db 'Mñëete si tÇë  uzam-'
;db 'knout  celò  poá°taá'
;db 'nebo  disk  a  to  i'
;db 'proti virñm. Nab°z°-'
;db 'me tÇë  ochranu pro-'
;db 'gramñ p©ed  neopr†v-'
;db 'nànòm ®°©en°m ái de-'
;db 'k¢dov†n°m.          '
;db '                    '
;db 'P©edev®°m  pro  dàti'
;db 'p©ed®koln°ho    vàku'
;db 'jsou   uráeny   na®e'
;db 'poá°taáovÇ omalov†n-'
;db 'ky.  I  3-letÇ  d°tà'
;db 'dok†ëe program ovl†-'
;db 'dat  a  vybarvit  si'
;db 'nàkterò    z   mnoha'
;db 'obr†zkñ    nebo   si'
;db 'namalovat vlastn°.  '
;db '                    '
;db 'Jsme p©esvàdáeni, ëe'
;db 'V†s  v  na®° nab°dce'
;db 'alespo§ jeden z pro-'
;db 'duktñ zaujme a proto'
;db 'nev†hejte  a  spojte'
;db 'se s n†mi.          '
;db '                    '
;db '      *  *  *       '
;db '                    '
;db 'S pozdravem autor,  '
;db 'ing.Miroslav Nàmeáek'
;db '                    '
;db '      *  *  *       '
;db '                    '
;db '     K O N E C      '
;db '                    '
;db '                    '
;db '                    '
;db '                    '
;db '                    '
;Text0    label     byte
;
; ------ gener†tor n†hody

RandomR  dd        21510d31h                ; promànn† pro gener†tor n†hody
RandomD  dw        8405h                    ; pomocn† konstanta

tabinit  label     byte                   ;* tabulka parametrñ
         db        53                       ; 0:celkovò poáet znakñ na ©†dek-1
         db        40                       ; 1:poáet vidit. znakñ na ©†dek
         db        44                       ; 2:poá†tek horiz. zatemnàn°
         db        7                        ; 3:poáet znakñ na synchronizaci

         db        91;121                      ; 4:celk. poáet vert. ©†dkñ-1 (363)
         db        1;2                        ; 5:poáet linek + k poátu ©†dkñ
         db        88;100                      ; 6:poáet viditelnòch ©†dkñ (300)
         db        88;115                      ; 7:©†dka zpàtnÇho bàhu (345)
         db        2;1                        ; 8:1=prokl†d†n°, 2=normal
         db        3;2                        ; 9:poáet linek na znak - 1 (3)

         db        0                        ; 0a:prvn° linka kurzoru
         db        3;2                        ; 0b:koncov† linka kurzoru

; ------ tabulka bodñ

TabBod   db        2,4,8,14,22,32,44,60,80,110

; ------ pracovn° adresa videopamàti

SegVRAM  dw        0a000h                   ; segment videopamàti

ParHerc  db        0                        ; p©°znak videokarty HERCULES
Sound    db        1                        ; p©°znak zapnut° zvuku

OldVMod  db        ?                        ; pñvodn° videom¢d

Old1b    dd        ?                        ; pñvodn° adresa INT 1Bh

; ------ áasovaá

         EVEN                               ; zaá°n† na sudÇ adrese jako 0:46ch
Cit1ms   dw        ?                        ; konstanta pro dobu 1 ms

; ------ demonstrace

DemPar   db        ?                        ; p©°znak prob°haj°c° demonstrace

DemPoz   db        ?                        ; testovan† pozice kamene
DemRad   db        ?                        ; testovanò ©†dek cihly
DemRot   db        ?                        ; testovanò poáet rotac° kamene
DemCih   db        ?                        ; á°slo testovanÇ cihly

DemPoz0  db        ?                        ; nejlep®° pozice
DemRot0  db        ?                        ; poáet rotac° nejlep®° pozice
DemBod   dw        ?                        ; poáet bodñ nejlep®° pozice

; ------ informace o aktivn° cihle

ParHra   db        ?                        ; p©°znak, ëe prob°h† hra
NextCih  db        ?                        ; p©°®t° cihla
Cihla    db        ?                        ; aktivn° cihla
Padani   db        ?                        ; p©°znak rychlÇho pad†n° cihly

PozCih   db        ?                        ; pozice s cihlou
RadCih   db        ?                        ; ©†dek s cihlou

AdrCih   dw        ?                        ; adresa cihly ve videopamàti

Pristi   db        ?                        ; p©°znak zobrazen° p©°®t° cihly

SegPSP   dw        ?                        ; adresa PSP

Body     dw        ?                        ; body cihly
Skore    dd        ?                        ; á°taá sk¢re
Radku    dw        ?                        ; á°taá plnòch ©†dkñ
Pole     db        20*10 dup(?)             ; hrac° plocha

Cihel    dw        ?                        ; celkem cihel (mus° n†sledovat !)
CitCih   dw        7 dup(?)                 ; á°taáe áetnosti cihel

Data     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;        z†sobn°k
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

StackS   SEGMENT   STACK

         dw        400h dup(?)

StackS   ENDS

         END       Start

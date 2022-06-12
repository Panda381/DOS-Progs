
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         Obsluha editace objektu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        editace objektu
; -----------------------------------------------------------------------------
; VSTUP: BX=kl†vesa
; -----------------------------------------------------------------------------

Edit     PROC      NEAR

         call      PushAkt                  ; £schova aktivn°ho stavu

; ------ univerz†ln° kl†vesy (p©epnut° m¢du zobrazen°)

         mov       ax,ds:[DispMod]          ; m¢d zobrazen°
         call      JumpBX

         dw        6800h,EditAF1            ; Alt-F1 form†t zobrazen° Hex
         dw        6900h,EditAF2            ; Alt-F2 form†t zobrazen° Binar
         dw        6a00h,EditAF3            ; Alt-F3 form†t zobrazen° Byte
         dw        6b00h,EditAF4            ; Alt-F4 form†t zobrazen° Word
         dw        6c00h,EditAF5            ; Alt-F5 form†t zobrazen° textu
         dw        6d00h,EditAF6            ; Alt-F6 form†t zobrazen° adres†©e
         dw        6e00h,EditAF7            ; Alt-F7 form†t zobrazen° FAT
         dw        6f00h,EditAF8            ; Alt-F8 form†t zobrazen° PARTITION
         dw        7000h,EditAF9            ; Alt-F9 form†t zobrazen° assembleru
;         dw        7100h,EditAFA            ; Alt-F10 form†t zobrazen° CMOS

         dw        3c00h,EditF2             ; F2 - uloëen° bufferu
         dw        3d00h,EditF3             ; F3 - zaá†tek bloku
         dw        3e00h,EditF4             ; F4 - konec bloku

         dw        4100h,Hled1              ; F7 - hled†n°/n†hrada dat
         dw        260ch,HledL              ; Ctrl-L pokraáov†n° v hled†n°

         dw        0,EditAF0                ; jin† kl†vesa

; ------ F2 - uloëen° obsahu bufferu

EditF2:  call      TestBuff                 ; test bufferu, zda byl modifikov†n
         jnc       EditF204                 ; buffer nebyl modifikov†n

         mov       si,offset Modi2Mnu       ; menu - dotaz na uloëen° dat
         call      HMenu                    ; horizont†ln° menu
         call      JumpBX                   ; skok na obsluhu
         dw        1,EditF202               ; uloëen° zmàn
         dw        2,EditF206               ; navr†cen° obsahu
         dw        0,EditF204               ; jinak p©eru®en° operace

EditF202:call      WritBuff                 ; uloëen° obsahu bufferu na disk
EditF204:ret

EditF206:call      ReadBuff                 ; navr†cen° pñvodn°ho obsahu
         jnc       EditF208                 ; operace OK
         mov       ax,ds:[EditONum]         ; pñvodn° poáet bajtñ v bufferu
         mov       ds:[EditNum],ax          ; n†vrat poátu bajtñ v bufferu
         call      PopBuff                  ; n†vrat obsahu bufferu z kopie
         call      PopAkt                   ; n†vrat ukazatelñ bufferu
EditF208:call      InitMez                  ; inicializace mezn°kñ dat
         ret

; ------ F3 - zaá†tek bloku

EditF3:  mov       ax,word ptr ds:[EditAkt]
         mov       word ptr ds:[EditBBeg],ax
         mov       ax,word ptr ds:[EditAkt+2]
         mov       word ptr ds:[EditBBeg+2],ax
         ret

; ------ F4 - konec bloku

EditF4:  mov       ax,word ptr ds:[EditAkt]
         mov       dx,word ptr ds:[EditAkt+2]
         add       ax,1
         adc       dx,0
         mov       word ptr ds:[EditBEnd],ax
         mov       word ptr ds:[EditBEnd+2],dx
         ret


; ------ Alt-F1 form†t zobrazen° Hex

EditAF1: mov       bl,0
         mov       ax,bit0
         jmp       short EditAFA2

; ------ Alt-F2 form†t zobrazen° Binar

EditAF2: mov       bl,1
         mov       ax,bit1
         jmp       short EditAFA2

; ------ Alt-F3 form†t zobrazen° Byte

EditAF3: mov       bl,2
         mov       ax,bit2
         jmp       short EditAFA2

; ------ Alt-F4 form†t zobrazen° Word

EditAF4: mov       bl,3
         mov       ax,bit3
         jmp       short EditAFA2

; ------ Alt-F5 form†t zobrazen° Text

EditAF5: mov       bl,4
         mov       ax,bit4
         jmp       short EditAFA2

; ------ Alt-F6 form†t zobrazen° Adres†©

EditAF6: mov       bl,5
         mov       ax,bit5
         jmp       short EditAFA2

; ------ Alt-F7 form†t zobrazen° FAT

EditAF7: mov       bl,6
         mov       ax,bit6
         jmp       short EditAFA2

; ------ Alt-F8 form†t zobrazen° Partition

EditAF8: mov       bl,7
         mov       ax,bit7
         jmp       short EditAFA2

; ------ Alt-F9 form†t zobrazen° Assembler

EditAF9: mov       bl,8
         mov       ax,bit8
         jmp       short EditAFA2

; ------ Alt-F10 form†t zobrazen° CMOS

EditAFA: mov       bl,9
         mov       ax,bit9
EditAFA2:test      ds:[DispMod],ax          ; je pole jië aktivn° ?
         jnz       EditAFA6                 ; pole je jië aktivn°

         test      byte ptr ds:[DispMod],bit5 ; byl adres†© ?
         jz        EditAF22                 ; nebyl adres†©
         mov       byte ptr ds:[EditPole],0

EditAF22:

EditAFA3:mov       byte ptr ds:[KurzPol],0  ; kurzor na zaá†tek poloëky
         push      bx
         mov       bl,ds:[DispMod0]         ; pñvodn° m¢d zobrazen°
         mov       bh,0
         mov       ch,ds:[EditPole]         ; aktivn° editovanÇ pole
         mov       ds:[bx+TabPole],ch       ; £schova aktivn°ho pole
         pop       bx
         mov       bh,0
         mov       bh,ds:[bx+TabPole]       ; uschovanÇ aktivn° pole
         mov       ds:[EditPole],bh         ; editovanÇ pole
         and       word ptr ds:[DispMod],not bit0+bit1+bit2+bit3+bit4+bit5+bit6+bit7+bit8
         or        ds:[DispMod],ax
         mov       ds:[DispMod0],bl
         call      OpenDis                  ; otev©en° zobrazenÇho form†tu
EditAFA6:ret

; ------ £schova registrñ

EditAF0: push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
         sub       sp,24                    ; m°sto pro lok†ln° promànnÇ


         mov       ax,ds:[DispMod]          ; m¢d zobrazen°
         cld

; ------ vàtven° podle m¢du zobrazen°

         test      al,bit0                  ; HEX ?
         jz        Edit11
         call      EditH                    ; editace Hex
         jmp       short EditX

Edit11:  test      al,bit1                  ; Binar ?
         jz        Edit1
         call      EditI                    ; editace Binar
         jmp       short EditX

Edit1:   test      al,bit2                  ; BYTE ?
         jz        Edit2
         call      EditB                    ; editace BYTE
         jmp       short EditX

Edit2:   test      al,bit3                  ; WORD ?
         jz        Edit3
         call      EditW                    ; editace WORD
         jmp       short EditX

Edit3:   test      al,bit4                  ; TEXT ?
         jz        Edit4
         call      EditT                    ; editace TEXT
         jmp       short EditX

Edit4:   test      al,bit5                  ; ADRESèû ?
         jz        Edit5
         call      EditD                    ; editace adres†©e
         jmp       short EditX

Edit5:   test      al,bit6                  ; FAT ?
         jz        Edit6

         call      EditF                    ; editace FAT
         jmp       short EditX

Edit6:   test      al,bit7                  ; PARTITION ?
         jz        Edit7
         call      EditP                    ; editace PARTITION
         jmp       short EditX

Edit7:   test      ax,bit8                  ; ASSEMBLER ?
         jz        Edit8

;         mov       ax,cs:[KorAsm]           ; korekce adresy assembleru
;         sub       ax,word ptr cs:[EditTop]
;         mov       ss:[bp-20],ax
         call      EditA                    ; editace ASSEMBLER
         jmp       short EditX

Edit8:   test      ax,bit9                  ; CMOS ?
         jz        Edit9
         call      EditC                    ; editace CMOS
         jmp       short EditX

Edit9:

; ------ n†vrat registrñ

EditX:   mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Edit     ENDP

; -----------------------------------------------------------------------------
;        hled†n° dat v objektu (funkce F7)
; -----------------------------------------------------------------------------
;˛

; ------ pokraáov†n° v hled†n°

HledL:   cmp       word ptr ds:[HledNum],0
         je        Hled10
         and       byte ptr ds:[HledPar],bit6 ; ponech† se p©°znak nalezen°
         jmp       short Hled120

; ------ hled†n° dat

Hled1:   mov       si,offset HledMnu
         call      HMenu                    ; volby
         jnc       Hled11
Hled10:  ret
Hled11:  cmp       bl,7
         je        Hled10                   ; p©eru®en°
         cmp       word ptr ds:[HledNum],0  ; je nàco zad†no ?
         je        Hled10                   ; nen° nic zad†no

; ------ rozbor parametrñ hled†n°

         mov       byte ptr ds:[HledPar],0  ; nulov†n° parametrñ
Hled120: mov       word ptr ds:[HledPCN],0  ; á°taá vòskytñ hled†n°
         mov       si,offset HledPTxt
         mov       cx,ds:[HledPNum]         ; dÇlka textu parametrñ
Hled121: jcxz      Hled129                  ; nen° dal®° znak
         cld
         lodsb                              ; naáten° znaku
         dec       cx
         call      UpCase                   ; konverze na velkò znak
         cmp       al,"B"
         jne       Hled122
         or        byte ptr ds:[HledPar],bit0 ; hled†n° zpàt
Hled122: cmp       al,"L"
         jne       Hled123
         test      byte ptr ds:[HledPar],bit2
         jnz       Hled123                  ; je jië hled†n° v celÇm objektu
         or        byte ptr ds:[HledPar],bit1 ; hled†n° v bloku
Hled123: cmp       al,"G"
         jne       Hled124
         and       byte ptr ds:[HledPar],not bit1
         or        byte ptr ds:[HledPar],bit2 ; hled†n° v celÇm objektu
Hled124: cmp       al,"U"
         jne       Hled125
         or        byte ptr ds:[HledPar],bit3 ; ignorov†n° p°smen
Hled125: cmp       al,"N"
         jne       Hled126
         or        byte ptr ds:[HledPar],bit4 ; n†hrada bez dotazu
Hled126: cmp       al,"W"
         jne       Hled127
         or        byte ptr ds:[HledPar],bit5 ; z†pis bez dotazu
Hled127: call      EditGNum                 ; naáten° á°sla
         jc        Hled121                  ; nen° á°slo
         mov       ds:[HledPCN],ax          ; zadanò á°taá vòskytu
         jmp       short Hled121

; ------ test, zda je n†hrada textu

Hled129: push      ds
         pop       es
         mov       di,offset NahrMask       ; n†hrada dat
         cld
         mov       cx,ds:[HledNum]          ; dÇlka ©etàzce
         mov       al,0
         repe      scasb                    ; je nàjakò platnò bajt ?
         je        Hled13                   ; nen° platnò bajt
         or        byte ptr ds:[HledPar],bit7 ; p©°znak n†hrady dat

; ------ zaá†tek a konec bloku k prohled†n°

Hled13:  test      byte ptr ds:[HledPar],bit1 ; je prohled†v†n° v bloku ?
         jz        Hled132                  ; nen° prohled†v†n° v bloku
         mov       ax,word ptr ds:[EditBBeg] ; zaá†tek bloku LOW
         mov       dx,word ptr ds:[EditBBeg+2] ; zaá†tek bloku HIGH
         mov       cx,word ptr ds:[EditBEnd] ; konec bloku LOW
         mov       bx,word ptr ds:[EditBEnd+2] ; konec bloku HIGH
         test      byte ptr ds:[HledPar],bit6 ; je pokraáov†n° v hled†n° ?
         jz        Hled136                  ; nen° pokraáov†n° v hled†n°
         test      byte ptr ds:[HledPar],bit0 ; je hled†n° zpàt ?
         jnz       Hled131                  ; je hled†n° zpàt
         mov       ax,word ptr ds:[EditAkt]
         mov       dx,word ptr ds:[EditAkt+2]
         add       ax,1
         adc       dx,0
         jmp       short Hled136

Hled131: mov       cx,word ptr ds:[EditAkt]
         mov       bx,word ptr ds:[EditAkt+2]
         jmp       short Hled136

Hled132: xor       ax,ax                    ; zaá†tek objektu
         xor       dx,dx
         test      byte ptr ds:[HledPar],bit6 ; je pokraáov†n° v hled†n° ?
         jnz       Hled133                  ; je pokraáov†n° v hled†n°

         test      byte ptr ds:[HledPar],bit2 ; je celò objekt ?
         jnz       Hled134                  ; je celò objekt

Hled133: xor       bx,bx
         mov       cx,ds:[HledNum]          ; poáet bajtñ k hled†n°
         dec       cx
         add       cx,word ptr ds:[EditAkt] ; kurzor LOW
         adc       bx,word ptr ds:[EditAkt+2] ; kurzor HIGH
         test      byte ptr ds:[HledPar],bit0 ; je hled†n° zpàt ?
         jnz       Hled136                  ; je hled†n° zpàt

         mov       ax,word ptr ds:[EditAkt] ; kurzor LOW
         mov       dx,word ptr ds:[EditAkt+2] ; kurzor HIGH
         add       ax,1
         adc       dx,0

Hled134: mov       cx,word ptr ds:[EditMax]
         mov       bx,word ptr ds:[EditMax+2]

; ------ korekce zaá†tku a konce bloku

Hled136: sub       cx,ds:[HledNum]          ; odeáten° dÇlky ©etàzce od konce
         sbb       bx,0
         jnc       Hled137
         xor       cx,cx
         xor       bx,bx
Hled137: cmp       dx,bx
         jne       Hled138
         cmp       ax,cx
Hled138: jb        Hled139                  ; ukazatele jsou OK
         jmp       Hled8                    ; blok nen° aktivn° nebo je malò

; ------ z†màna zaá†tku a konce p©i hled†n° zpàt

Hled139: test      byte ptr ds:[HledPar],bit0 ; je hled†n° zpàt ?
         jz        Hled13A                  ; nen° hled†n° zpàt
         xchg      ax,cx
         xchg      dx,bx                    ; z†màna zaá†tku a konce
Hled13A: mov       word ptr ds:[HledABeg],ax
         mov       word ptr ds:[HledABeg+2],dx
         mov       word ptr ds:[HledAEnd],cx
         mov       word ptr ds:[HledAEnd+2],bx

; ------ konverze textu na velk† p°smena, pokud se nemaj° p°smena rozli®ovat

         test      byte ptr ds:[HledPar],bit3 ; ignoruj° se velk†/mal† p°smena ?
         jz        Hled142                  ; neignoruj° se
         mov       si,offset HledDat        ; data k vyhled†n°
         mov       di,si
         mov       cx,ds:[HledNum]
         cld
Hled141: lodsb
         call      UpCase
         stosb
         loop      Hled141

; ------ p©°prava bufferu na zaá†tku hled†n°

Hled142: mov       ax,word ptr ds:[HledABeg]
         mov       word ptr ds:[EditAkt],ax
         mov       ax,word ptr ds:[HledABeg+2]
         mov       word ptr ds:[EditAkt+2],ax
Hled143: call      NormBuff                 ; normalizace bufferu
         jnc       Hled144                  ; nen° p©eru®en°
         ret

; ------ p©°prava ukazatelñ pro prohled†n° bufferu

Hled144: call      Disp                     ; zobrazen° aktivn° str†nky
         call      KurzOff                  ; vypnut° kurzoru
         mov       es,ds:[BuffSegm]         ; segment bufferñ
         mov       di,word ptr ds:[EditAkt] ; ukazatel kurzoru LOW
         sub       di,word ptr ds:[EditBeg] ; offset od zaá†tku bufferu
         mov       cx,ds:[EditNum]          ; poáet bajtñ v bufferu
         sub       cx,ds:[HledNum]          ; rezerva pro dÇlku ©etàzce
         jbe       Hled8                    ; nezbyla ë†dn† data
         sub       cx,di                    ; zbytek dat od kurzoru
         jbe       Hled8                    ; nezbyla ë†dn† data
         add       di,ds:[BuffOff1]         ; adresa v editaán°m bufferu

; ------ nalezen° ©etàzce bez ignorov†n° velkòch/malòch p°smen

         test      byte ptr ds:[HledPar],bit3 ; ignoruj° se velk†/mal† p°smena ?
;         jnz       Hled4                    ; ignoruj° se velk†/mal† p°smena
         mov       al,ds:[HledDat]          ; data k vyhled†n°
         cld

Hled3:   test      byte ptr ds:[HledPar],bit0 ; je hled†n° zpàt ?
;         jz        Hled31                   ; je hled†n° vp©ed
;         std                                ; smàr dolñ
;         dec       di
Hled31:  repne     scasb                    ; nalezen° prvn°ho bajtu dat
         jne       Hled6                    ; ©etàzec nenalezen - dal®° blok

         push      si
         push      di
         push      cx
         mov       cx,ds:[HledNum]          ; dÇlka ©etàzce
         dec       cx
         mov       si,offset HledDat+1
         xor       ax,ax
         repe      cmpsb
         pop       cx
         pop       di
         pop       si
         je        Hled5                    ; ©etàzec nalezen OK
         jmp       short Hled6

; ------ nalezen° ©etàzce s ignorov†n°m velkòch/malòch p°smen

Hled4:


; ------ ©etàzec nalezen OK

Hled5:   dec       di
         sub       di,ds:[BuffOff1]         ; offset v editaán°m bufferu
         mov       ax,word ptr ds:[EditBeg] ; zaá†tek editaán°ho bufferu
         mov       dx,word ptr ds:[EditBeg+2]
         add       ax,di                    ; novò ukazatel kurzoru
         adc       dx,0
         mov       word ptr ds:[EditAkt],ax
         mov       word ptr ds:[EditAkt+2],dx
         or        byte ptr ds:[HledPar],bit6 ; p©°znak nalezen°
         call      NormBuff

         ret

; ------ hl†®en° - zadan† data nenalezena

Hled8:   call      PopAkt
         call      NormBuff
         call      Disp
         mov       si,offset NoFndMnu
         call      HMenu
         ret

; ------ p©°prava pro dal®° blok dat

Hled6:   sub       di,ds:[BuffOff1]         ; offset v editaán°m bufferu
         mov       ax,word ptr ds:[EditBeg] ; zaá†tek editaán°ho bufferu
         mov       dx,word ptr ds:[EditBeg+2]
         add       ax,di                    ; novò ukazatel kurzoru
         adc       dx,0
         mov       word ptr ds:[EditAkt],ax
         mov       word ptr ds:[EditAkt+2],dx

; ------ test p©eru®en° operace

         mov       ah,1
         int       16h
         jz        Hled68
         mov       ah,0
         int       16h
         or        ax,ax
         jz        Hled67
         cmp       al,27
         jne       Hled68
Hled67:  ;call      PopAkt
         call      NormBuff
         ret

Hled68:  jmp       Hled143                  ; dal®° blok dat


; -----------------------------------------------------------------------------
;        naáten° á°sla AX z textu DS:SI/CX
; -----------------------------------------------------------------------------

EditGNum PROC      NEAR

         push      bx
         push      dx

         xor       bx,bx                    ; st©adaá
         call      EditGN                   ; naáten° prvn° á°slice
         jc        EditGNm5                 ; nen° ë†dn† á°slice

EditGNm1:mov       ah,0
         push      ax
         mov       ax,10
         mul       bx
         or        dx,dx
         jz        EditGNm2
         mov       ax,-1
EditGNm2:pop       bx
         add       bx,ax
         jnc       EditGNm3
         mov       bx,-1

EditGNm3:call      EditGN                   ; dal®° á°slice
         jnc       EditGNm1                 ; je dal®° á°slice
         clc

EditGNm5:xchg      ax,bx                    ; AX <- naátenÇ á°slo
         pop       dx
         pop       bx
         ret

EditGNum ENDP

; -----------------------------------------------------------------------------
;        naáten° dekadickÇ á°slice AL z textu DS:SI/CX
; -----------------------------------------------------------------------------

EditGN   PROC      NEAR

         stc
         jcxz      EditGN4

         cld
         lodsb
         dec       cx
         sub       al,"0"
         jb        EditGN3
         cmp       al,9+1
         cmc
         jnc       EditGN4

EditGN3: dec       si
         inc       cx
EditGN4: ret

EditGN   ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du HEX
; -----------------------------------------------------------------------------
;˛
EditH    PROC      NEAR

         call      JumpBX

         dw        0f09h,EditHTb            ; tabel†tor
         dw        0f00h,EditHTb            ; zpàtnò tabel†tor
         dw        0,EditHH                 ; editace pol°

; ------ tabel†tor

EditHTb: xor       byte ptr ds:[EditPole],1 ; zmàna aktivn°ho pole
         mov       byte ptr ds:[KurzPol],0  ; kurzor na poá†tek poloëky
         ret

; ------ editace pol°

EditHH:  mov       di,16                    ; ®°©ka pol°
         cmp       byte ptr ds:[EditPole],0 ; editov†no pole HEX ?
         jne       EditHH2                  ; nen° pole HEX
         jmp       EdHex                    ; editace pole HEX

EditHH2: jmp       EdAsc                    ; editace pole ASCII

EditH    ENDP


; -----------------------------------------------------------------------------
;        editace v m¢du BINAR
; -----------------------------------------------------------------------------

EditI    PROC      NEAR

         call      JumpBX

         dw        0f09h,EditITb            ; tabel†tor
         dw        0f00h,EditIST            ; zpàtnò tabel†tor
         dw        0,EditIP                 ; editace pol°

; ------ tabel†tor

EditITb: add       byte ptr ds:[EditPole],1 ; zvò®en° á°sla pole
EditITb2:and       byte ptr ds:[EditPole],3 ; omezen° á°sla pole
         mov       byte ptr ds:[KurzPol],0  ; kurzor na poá†tek poloëky
         call      OpenDis                  ; otev©en° zobrazenÇho form†tu
         ret

; ------ zpàtnò tabel†tor

EditIST: sub       byte ptr ds:[EditPole],1 ; sn°ëen° á°sla pole
         jmp       short EditITb2

; ------ editace pol°

EditIP:  mov       di,4                     ; ®°©ka pol°

         cmp       byte ptr ds:[EditPole],0 ; editov†no bin†rn° pole ?
         jne       EditIP1                  ; nen° bin†rn° pole
         jmp       EdBin                    ; editace bin†rn°ho pole

EditIP1: cmp       byte ptr ds:[EditPole],1 ; editov†no pole HEX ?
         jne       EditIP2                  ; nen° pole HEX
         jmp       EdHex                    ; editace pole HEX

EditIP2: cmp       byte ptr ds:[EditPole],2 ; editov†no dekadickÇ pole ?
         jne       EditIP3                  ; nen° dekadickÇ pole
         jmp       EdDek                    ; editace dekadickÇho pole

EditIP3: jmp       EdAsc                    ; editace pole ASCII

EditI    ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du BYTE
; -----------------------------------------------------------------------------

EditB    PROC      NEAR

         call      JumpBX

         dw        0f09h,EditBTb            ; tabel†tor
         dw        0f00h,EditBTb            ; zpàtnò tabel†tor
         dw        0,EditBH                 ; editace pol°

; ------ tabel†tor

EditBTb: xor       byte ptr ds:[EditPole],1 ; zmàna aktivn°ho pole
         mov       byte ptr ds:[KurzPol],0  ; kurzor na poá†tek poloëky
         call      OpenDis                  ; otev©en° zobrazenÇho form†tu
         ret

; ------ editace pol°

EditBH:  mov       di,10                    ; ®°©ka pol°
         cmp       byte ptr ds:[EditPole],0 ; editov†no pole DEK ?
         jne       EditBH2                  ; nen° pole DEK
         jmp       EdDek                    ; editace pole DEK

EditBH2: jmp       EdAsc                    ; editace pole ASCII

EditB    ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du WORD
; -----------------------------------------------------------------------------

EditW    PROC      NEAR

         call      JumpBX

         dw        0f09h,EditWTb            ; tabel†tor
         dw        0f00h,EditWTb            ; zpàtnò tabel†tor
         dw        0,EditWH                 ; editace pol°

; ------ tabel†tor

EditWTb: xor       byte ptr ds:[EditPole],1 ; zmàna aktivn°ho pole
         mov       byte ptr ds:[KurzPol],0  ; kurzor na poá†tek poloëky
         call      OpenDis                  ; otev©en° zobrazenÇho form†tu
         ret

; ------ editace pol°

EditWH:  cmp       byte ptr ds:[EditPole],0 ; editov†no pole DEK ?
         jne       EditWH2                  ; nen° pole DEK
         mov       di,5                     ; ®°©ka pole WORD
         jmp       EdWrd                    ; editace pole WORD

EditWH2: mov       di,10                    ; ®°©ka pole ASCII
         jmp       EdAsc                    ; editace pole ASCII

EditW    ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du TEXT
; -----------------------------------------------------------------------------

EditT    PROC      NEAR

         call      JumpBX

         dw        4d00h,EditTRg            ; vpravo
         dw        4b00h,EditTLf            ; vlevo

         dw        0e08h,EditTBs            ; obnoven° znaku p©ed kurzorem
         dw        5300h,EditTDl            ; obnoven° znaku za kurzorem

         dw        0,EditTCh                ; vloëen° znaku

; ------ obnoven° znaku p©ed kurzorem

EditTBs: call      EditTLf                  ; kurzor vlevo
         call      GetKurz
         mov       al,es:[si+8000h]
         mov       es:[si],al               ; n†vrat znaku
EditTBs4:ret

; ------ obnoven° znaku nad kurzorem

EditTDl: call      GetKurz
         mov       al,es:[si+8000h]
         mov       es:[si],al               ; n†vrat znaku
         jmp       short EditTRg            ; kurzor vpravo

; ------ vloëen° znaku

EditTCh: mov       al,bl                    ; znak
         cmp       al,0
         je        EditTCh9                 ; neplatnò znak
         call      GetKurz                  ; poskytnut° kurzoru
         mov       es:[si],al               ; uloëen° znaku

; ------ kurzor vpravo

EditTRg: call      NextByte                 ; dal®° bajt
         jc        EditTCh9
         call      GetKurz
         cmp       word ptr es:[si-1],0a0dh ; konec ©†dku ?
         jne       EditTCh9
         call      NextByte
EditTCh9:ret

; ------ kurzor vlevo

EditTLf: call      PredByte
         jc        EditTLf4

         call      GetKurz
         cmp       byte ptr es:[si],0ah
         jne       EditTLf4
         call      PredByte
         jc        EditTLf4

         call      GetKurz
         cmp       byte ptr es:[si],0dh
         jne       EditTLf3
         ret

EditTLf3:call      NextByte
EditTLf4:ret

EditT    ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du ADRESèû
; -----------------------------------------------------------------------------

EditD    PROC      NEAR

         mov       ax,word ptr ds:[EditAkt]
         sub       ax,word ptr ds:[EditTop] ; offset od poá†tku
         mov       cx,32                    ; bajtñ na ©†dek
         xor       dx,dx
         div       cx                       ; vòpoáet ©†dku a pozice relativnà
         mov       dh,al                    ; ©†dek relativnà

         call      JumpBX

         dw        4d00h,EditDRg            ; kurzor vpravo
         dw        4b00h,EditDLf            ; kurzor vlevo
         dw        4800h,EditDUp            ; kurzor nahoru
         dw        5000h,EditDDn            ; kurzor dolñ

         dw        7300h,EditDCL            ; slovo vlevo
         dw        7400h,EditDTab           ; slovo vpravo

         dw        4700h,EditDHm            ; zaá†tek ©†dku
         dw        4f00h,EditDEn            ; konec ©†dku

         dw        5300h,EditDDl            ; zru®en° znaku za kurzorem
         dw        0e08h,EditDBs            ; zru®en° znaku p©ed kurzorem

         dw        0f09h,EditDTab           ; tabel†tor - dal®° poloëka
         dw        0f00h,EditDSTb           ; zpàtnò tabel†tor

         dw        0,EditDCh


; ------ kurzor dolñ

EditDDn: mov       cl,32                    ; offset dal®° poloëky
         call      NextPByt
         call      OpenDis
         ret

; ------ kurzor nahoru

EditDUp: mov       cl,32                    ; offset p©edchoz° poloëky
         call      PredPByt
         call      OpenDis
         ret

; ------ zaá†tek ©†dku

EditDHm: mov       cl,0                     ; offset zaá†tku ©†dku
         jmp       short EditDTb0           ; p©esun na zaá†tek ©†dku

; ------ konec ©†dku

EditDEn: mov       cl,1ah                   ; konec ©†dku
         jmp       short EditDTb0           ; p©esun na konec ©†dku

; ------ tabel†tor - dal®° pole

EditDTab:mov       bh,0
         mov       bl,dl                    ; pozice
         mov       cl,ds:[bx+KorAdrNx]      ; offset dal®°ho pole

                                          ;* datum
         cmp       cl,16h
         je        EditDT06                 ; bylo datum

                                          ;* áas
         cmp       cl,0bh
         jne       EditDT07                 ; nebyl áas

EditDT06:cmp       byte ptr ds:[EditPole],2 ; je konec pole ?
         jae       EditDT07                 ; je konec pole

         inc       byte ptr ds:[EditPole]   ; zvò®en° ukazatele pole
         jmp       short EditDTb5           ; otev©en° poloëky

EditDT07:mov       ds:[EditPole],bh         ; na zaá†tek pole

EditDTb0:
         call      SetByte                  ; nastaven° ukazatele na pozici CL
EditDTb5:call      OpenDis
EditDTb4:ret

; ------ slovo vlevo

                                          ;* atributy
EditDCL: cmp       dl,0bh                   ; atributy ?
         jne       EditDCL1                 ; nejsou atributy
         cmp       byte ptr ds:[EditPole],0
         je        EditDSTb
         mov       byte ptr ds:[EditPole],0
         ret

                                          ;* p©°pona
EditDCL1:ja        EditDCL6                 ; ani jmÇno ani p©°pona
         cmp       dl,8
         jb        EditDCL2                 ; je jmÇno
         je        EditDCL6                 ; je jië zaá†tek p©°pony
         mov       cl,8                     ; zaá†tek p©°pony
EdiDTB00:jmp       short EditDTB0           ; nastaven° na pozici

EditDCL2:cmp       dl,0
         je        EditDCL6                 ; je jië zaá†tek jmÇna
         mov       cl,0                     ; zaá†tek jmÇna
         jmp       short EdiDTB00           ; nastaven° na pozici

                                          ;* ostatn° poloëky
EditDCL6:cmp       byte ptr ds:[KurzPol],0
         je        EditDSTb
         mov       byte ptr ds:[KurzPol],0
         ret

; ------ zpàtnò tabel†tor - p©edchoz° pole

EditDSTb:mov       bh,0
         mov       bl,dl                    ; pozice

         mov       cl,ds:[bx+KorAdrPr]      ; offset p©edchoz°ho pole

                                          ;* atributy
         mov       dh,2                     ; posledn° poloëka data a áasñ
         cmp       cl,16h                   ; byly atributy ?
         je        EditDS07                 ; byly atributy

                                          ;* áas
         cmp       cl,18h                   ; byl áas ?
         je        EditDS05                 ; byl áas

                                          ;* datum
         mov       dh,0                     ; posledn° poloëka velikosti
         cmp       cl,1ch                   ; byl datum ?
         jne       EditDS07                 ; nebyl datum

EditDS05:cmp       byte ptr ds:[EditPole],0 ; je zaá†tek pole ?
         je        EditDS07                 ; je zaá†tek pole
         dec       byte ptr ds:[EditPole]   ; sn°ëen° ukazatele pole
         jmp       short EditDTb5           ; otev©en° poloëky

EditDS07:mov       ds:[EditPole],dh         ; posledn° poloëka pole
         jmp       short EdiDTb00


; ------ posun kurzoru vpravo

EditDRg: mov       bh,0
         mov       bl,dl                    ; pozice
         mov       bl,ds:[bx+KorAdrK]       ; korigovan† pozice kurzoru
         mov       bh,ds:[KurzPol]          ; kurzor v poloëce
         inc       bh

                                          ;* jmÇno a p©°pona
         cmp       dl,0ah
         ja        EditDRg3                 ; nen° jmÇno ani p©°pona
         je        EditDRg2                 ; konec p©°pony
         call      NextByte                 ; dal®° bajt
         jc        EditDRg1
         call      OpenDis
EditDRg1:ret

EditDRg2:jmp       EditDTab                 ; p©esun na dal®° poloëku

                                          ;* á°seln† poloëka
EditDRg3:cmp       bl,57                    ; atributy ?
         je        EditDRg4                 ; nen° á°seln† poloëka
         or        byte ptr ds:[Param2],bit3 ; p©°znak zah†jen° editace
         cmp       bh,ds:[EditBDel]         ; maxim†ln° poáet znakñ
         jae       EditDRg2
         cmp       bh,ds:[EditBNum]         ; je na konci textu ?
         ja        EditDRg2                 ; p©esun na dal®° poloëku
         mov       ds:[KurzPol],bh          ; zvò®en° pozice kurzoru
         ret

                                          ;* atributy
EditDRg4:cmp       byte ptr ds:[EditPole],7 ; konec pole atributñ ?
         jae       EditDRg2                 ; konec atributñ - p©esun na blok
         inc       byte ptr ds:[EditPole]   ; zvò®en° ukazatele pole
         ret

; ------ posun kurzoru vlevo

EditDLf: mov       bh,0
         mov       bl,dl                    ; pozice
         mov       bl,ds:[bx+KorAdrK]       ; korigovan† pozice kurzoru
         mov       bh,ds:[KurzPol]          ; kurzor v poloëce

                                          ;* jmÇno a p©°pona
         cmp       dl,0ah
         ja        EditDLf3                 ; nen° jmÇno ani p©°pona
         cmp       dl,0
         je        EditDLf2                 ; je zaá†tek jmÇna
         call      PredByte                 ; p©edchoz° bajt
         jc        EditDLf1
         call      OpenDis
EditDLf1:ret

                                          ;* p©esun na konec atributñ
EdiDLf22:cmp       bl,73                    ; je alokaán° blok ?
         jne       EdiDLf24                 ; nen° alokaán° blok
         mov       bh,0
         mov       bl,dl                    ; pozice
         mov       cl,ds:[bx+KorAdrPr]      ; offset p©edchoz°ho pole
         mov       byte ptr ds:[EditPole],7 ; posledn° pole atributñ
EdiDLf23:jmp       EditDTb0                 ; p©esun na pozici

                                          ;* p©esun na konec p©°pony
EdiDLf24:mov       cl,0ah                   ; offset konce p©°pony
         cmp       bl,23                    ; je velikost ?
         je        EdiDLf23                 ; je velikost

EditDLf2:jmp       EditDSTb                 ; p©esun na p©edchoz° poloëku

                                          ;* á°seln† poloëka
EditDLf3:cmp       bl,57                    ; atributy ?
         je        EditDLf4                 ; nen° á°seln† poloëka
         or        byte ptr ds:[Param2],bit3 ; p©°znak zah†jen° editace
         cmp       bh,0                     ; je poá†tek poloëky ?
         je        EdiDLf22                 ; p©edchoz° poloëka
         dec       byte ptr ds:[KurzPol]    ; sn°ëen° pozice kurzoru
         ret

                                          ;* atributy
EditDLf4:cmp       byte ptr ds:[EditPole],0 ; zaá†tek pole atributñ ?
         je        EditDLf2                 ; zaá†tek atributñ - p©esun na blok
         dec       byte ptr ds:[EditPole]   ; sn°ëen° ukazatele pole
         ret


; ------ vloëen° znaku

EditDCh: mov       ax,bx                    ; kl†vesa
         mov       bh,0
         mov       bl,dl                    ; pozice
         mov       bl,ds:[bx+KorAdrK]       ; korigovan† pozice kurzoru

         cmp       ax,0300h                 ; kl†vesa Ctrl-@
         je        EditDCh2
         cmp       al,0
         jne       EditDCh2                  ; je platnò znak
         ret

                                          ;* p©°prava registrñ
EditDCh2:call      GetKurz                  ; poskytnut° kurzoru

                                          ;* editace jmÇna a p©°pony
         cmp       dl,0ah                   ; je jmÇno nebo p©°pona ?
         ja        EditDCh3
         mov       es:[si],al               ; uloëen° znaku
EdiDCh22:jmp       EditDRg                  ; posun kurzoru

EditDCh3:cmp       bl,57
         je        EditDCh7                 ; jsou atributy

                                          ;* mezera - vymaz†n° zbytku á°sla
EditDCh4:cmp       al," "
         jne       EditDCh5
         call      InsBEdit                 ; vloëen° mezery do bufferu
         call      EditDWr                  ; z†pis á°sla do bufferu
         call      OpenDis                  ; novÇ otev©en° á°sla
         mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
         jmp       EditDTab                 ; posun kurzoru

                                          ;* editace á°sla v bufferu
EditDCh5:call      TestDek                  ; test, zda je v AL á°slice
         jnc       EditDCh6                 ; je á°slice
         ret
EditDCh6:call      InsBEdit                 ; vloëen° znaku do edit. bufferu
         call      EditDWr                  ; z†pis á°sla do bufferu
         jmp       short EdiDCh22           ; posun kurzoru

                                          ;* editace atributñ
EditDCh7:cmp       al," "                   ; mezera ?
         jne       EditDCh8                 ; nen° mezera
         mov       cl,ds:[EditPole]         ; editovanÇ pole
         mov       al,1
         shl       al,cl
         xor       byte ptr es:[si],al      ; zmàna atributu
         jmp       short EdiDCh22

                                          ;* atributy - nastaven° p°smenem
EditDCh8:;mov       bl,al                    ; £schova znaku
         ;mov       cl,5
         ;shr       bl,cl
         ;and       bl,1                     ; poëadovanò p©°znak
         ;xor       bl,1
         ;mov       bh,not 1                 ; maska
         mov       bl,1                     ; maska
         call      UpCase                   ; konverze na velkÇ p°smeno
         mov       di,offset TabAtr         ; tabulka atributñ
EdiDCh82:cmp       al,ds:[di]
         je        EdiDCh83
         shl       bl,1
         ;rol       bh,1
         inc       di
         cmp       di,offset TabAtr+8
         jne       EdiDCh82
         ret

EdiDCh83:;and       es:[si],bh
         xor        es:[si],bl               ; novò atribut
         ret

; ------ zru®en° znaku za kurzorem

EditDDl: mov       bh,0
         mov       bl,dl                    ; pozice
         mov       cl,ds:[bx+KorAdrK]       ; korigovan† pozice kurzoru
         call      GetKurz                  ; poskytnut° kurzoru

                                          ;* jmÇno, p©°pona, atributy
         cmp       dl,0ah                   ; je jmÇno nebo p©°pona ?
         jbe       EditDDl2                 ; je jmÇno nebo p©°pona
         cmp       cl,57                    ; jsou atributy ?
         jne       EditDDl3                 ; nejsou atributy
EditDDl2:call      EditDRet                 ; n†vrat pñvodn°ho obsahu poloëky
         jmp       EditDRg                  ; posun o pozici

                                          ;* á°slo - zru®en° znaku za kurzorem
EditDDl3:cmp       byte ptr ds:[EditBNum],0 ; je nàjakò znak v bufferu ?
         je        EditDDl4                 ; v bufferu nic nen°
         call      DelBEdit                 ; zru®en° znaku za kurzorem
         mov       bl,cl
         call      EditDWr                  ; uloëen° á°sla
         ret
                                          ;* á°slo - n†vrat poloëky
EditDDl4:call      EditDRet                 ; n†vrat pñvodn°ho obsahu poloëky
         jmp       EditDTab                 ; dal®° poloëka

; ------ zru®en° znaku p©ed kurzorem

EditDBs: mov       bh,0
         mov       bl,dl                    ; pozice
         mov       cl,ds:[bx+KorAdrK]       ; korigovan† pozice kurzoru
         call      GetKurz                  ; poskytnut° kurzoru

                                          ;* jmÇno, p©°pona, atributy
         cmp       dl,0ah                   ; je jmÇno nebo p©°pona ?
         jbe       EditDBs5                 ; je jmÇno nebo p©°pona
         cmp       cl,57                    ; jsou atributy ?
         je        EditDBs5                 ; jsou atributy

                                          ;* á°slo - zru®en° znaku p©ed kurzorem
EditDBs3:cmp       byte ptr ds:[KurzPol],0  ; je kurzor na zaá†tku poloëky ?
         je        EditDBs5                 ; je na zaá†tku poloëky
         dec       byte ptr ds:[KurzPol]    ; posun kurzoru
         call      DelBEdit                 ; zru®en° znaku za kurzorem
         mov       bl,cl
         call      EditDWr                  ; uloëen° á°sla
         ret

EditDBs5:mov       bx,4b00h                 ; kurzor vlevo
         call      EditD                    ; posun kurzoru vlevo

         mov       ax,word ptr ds:[EditAkt]
         sub       ax,word ptr ds:[EditTop] ; offset od poá†tku
         mov       cx,32                    ; bajtñ na ©†dek
         xor       dx,dx
         div       cx                       ; vòpoáet ©†dku a pozice relativnà
         mov       dh,al                    ; ©†dek relativnà
         call      EditDRet                 ; n†vrat pñvodn°ho obsahu poloëky
         ret

EditD    ENDP

; -----------------------------------------------------------------------------
;        n†vrat pñvodn°ho obsahu poloëky
; -----------------------------------------------------------------------------
; VSTUP: DL=offset poloëky
; niá° obsahy registrñ ES:SI
; -----------------------------------------------------------------------------

EditDRet PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©°prava registrñ

         mov       bh,0
         mov       bl,dl                    ; pozice
         mov       cl,ds:[bx+KorAdrK]       ; korigovan† pozice kurzoru
         call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       bx,8000h                 ; korekce bufferñ
         mov       ch,ds:[EditPole]         ; editovanÇ pole

; ------ jmÇno a p©°pona

         cmp       dl,0ah
         ja        EditDRt1                 ; nen° jmÇno ani p©°pona
         mov       al,es:[si+bx]            ; pñvodn° znak
         mov       es:[si],al               ; n†vrat znaku
         jmp       short EdiDRt99

; ------ atributy

EditDRt1:cmp       cl,57
         jne       EditDRt2                 ; nejsou atributy
         mov       cl,ch                    ; editovanÇ pole
         mov       ah,1
         shl       ah,cl
         mov       al,es:[si+bx]            ; pñvodn° bajt
         and       al,ah                    ; maska
         not       ah
         and       es:[si],ah               ; nulov†n° pñvodn°ho bitu
         or        es:[si],al               ; n†vrat bitu
         jmp       short EdiDRt99

; ------ n†vrat alokaán°ho bloku a velikosti

EditDRt2:mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
         cmp       cl,73
         je        EditDRt3                 ; je alokaán° blok
         cmp       cl,23
         jne       EditDRt4                 ; nen° velikost
         mov       ax,es:[si+bx+2]
         mov       es:[si+2],ax
EditDRt3:mov       ax,es:[si+bx]
         mov       es:[si],ax
         jmp       short EdiDRt99

; ------ n†vrat data - den

EditDRt4:cmp       cl,37                    ; je datum ?
         jne       EditDRt6                 ; nen° datum
         cmp       ch,0                     ; je den ?
         jne       EditDRt5                 ; nen° den
         mov       al,es:[si+bx]            ; datum LOW
         and       al,1fh                   ; pñvodn° den
         and       byte ptr es:[si],not 1fh ; zru®en° aktu†ln°ho dne
         or        es:[si],al               ; n†vrat dne
         jmp       short EdiDRt99

; ------ n†vrat data - màs°c

EditDRt5:cmp       ch,1                     ; je màs°c ?
         jne       EdiDRt54                 ; nen° màs°c
         mov       ax,es:[si+bx]            ; pñvodn° datum
         and       ax,1e0h                  ; pñvodn° màs°c
         and       word ptr es:[si],not 1e0h ; zru®en° aktu†ln°ho màs°ce
         or        es:[si],ax               ; n†vrat màs°ce
EdiDRt99:jmp       short EditDRt9

; ------ n†vrat data - rok

EdiDRt54:mov       al,es:[si+bx+1]          ; pñvodn° datum HIGH
         and       al,not 1                 ; pñvodn° rok
         and       byte ptr es:[si+1],1     ; zru®en° aktu†ln°ho roku
         or        es:[si+1],al             ; n†vrat roku
         jmp       short EditDRt9

; ------ n†vrat áasu - hodina

EditDRt6:cmp       cl,48
         jne       EditDRt7                 ; nen° áas
         cmp       ch,0
         jne       EdiDRt62                 ; nen° hodina
         mov       al,es:[si+bx+1]          ; pñvodn° áas HIGH
         and       al,not 7                 ; pñvodn° hodina
         and       byte ptr es:[si+1],7     ; nulov†n° aktu†ln° hodiny
         or        es:[si+1],al             ; n†vrat hodiny
         jmp       short EditDRt9

; ------ n†vrat áasu - minuta

EdiDRt62:cmp       ch,1
         jne       EdiDRt64                 ; nen° minuta
         mov       ax,es:[si+bx]            ; pñvodn° áas
         and       ax,7e0h                  ; pñvodn° minuta
         and       word ptr es:[si],not 7e0h ; zru®en° aktu†ln° minuty
         or        es:[si],ax               ; n†vrat minuty
         jmp       short EditDRt9

; ------ n†vrat áasu - sekunda

EdiDRt64:mov       al,es:[si+bx]            ; pñvodn° áas LOW
         and       al,1fh                   ; pñvodn° sekunda
         and       byte ptr es:[si],not 1fh ; zru®en° aktu†ln° sekundy
         or        es:[si],al               ; n†vrat pñvodn° sekundy

EditDRt7:

EditDRt9:call      OpenDis                  ; opàtovnÇ otev©en° poloëky

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditDRet ENDP

; -----------------------------------------------------------------------------
;        z†pis editovanÇho á°sla adres†©e do bufferu
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa v bufferu
;        BL=pozice na displeji
; -----------------------------------------------------------------------------

EditDWr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         mov       bh,ds:[EditPole]         ; editovanÇ pole

; ------ velikost

         cmp       bl,23
         jne       EditDWr2
         mov       bx,-1
         mov       cx,bx                    ; omezen°
         call      GetDD                    ; poskytnut° á°sla
         mov       es:[si],ax               ; á°slo LOW
         mov       es:[si+2],dx             ; á°slo HIGH
         jmp       short EdiDWr99

; ------ datum - den

EditDWr2:cmp       bl,37                    ; datum ?
         jne       EditDWr3                 ; nen° datum
         cmp       bh,0                     ; den ?
         jne       EdiDWr23                 ; nen° den

         mov       ah,31                    ; omezen°
         call      GetDB                    ; poskytnut° á°sla
         and       byte ptr es:[si],not 1fh ; nulov†n° starÇho dne
         or        es:[si],al               ; nastaven° novÇho dne
         jmp       short EdiDWr99

; ------ datum - màs°c

EdiDWr23:cmp       bh,1
         jne       EdiDWr25                 ; nen° màs°c

         mov       ah,15                    ; omezen°
         call      GetDB                    ; poskytnut° á°sla
         mov       ah,0
         mov       cl,5
         shl       ax,cl                    ; rotace na pozici
         and       word ptr es:[si],not 1e0h ; nulov†n° starÇ hodnoty
         or        es:[si],ax               ; novò màs°c
         jmp       short EdiDWr99

; ------ datum - rok

EdiDWr25:mov       cx,2107                  ; omezen°
         call      GetDW                    ; poskytnut° á°sla
         cmp       ax,200
         ja        EdiDWr26
         add       ax,1900
         cmp       ax,1980
         jae       EdiDWr26
         add       ax,100
EdiDWr26:cmp       ax,1000
         ja        EdiDWr27
         add       ax,1000
EdiDWr27:sub       ax,1980
         jnc       EdiDWr28
         xor       ax,ax
EdiDWr28:cmp       ax,127
         jbe       EdiDWr29
         mov       al,127
EdiDWr29:shl       al,1
         and       byte ptr es:[si+1],1
         or        es:[si+1],al
EdiDWr99:jmp       short EditDWr9

; ------ áas - hodina

EditDWr3:cmp       bl,48
         jne       EditDWr4                 ; nen° áas
         cmp       bh,0
         jne       EdiDWr32

         mov       ah,31                    ; omezen°
         call      GetDB                    ; poskytnut° á°sla
         mov       cl,3
         shl       al,cl
         and       byte ptr es:[si+1],7     ; zru®en° starÇ hodiny
         or        byte ptr es:[si+1],al    ; nov† hodina
         jmp       short EditDWr9

; ------ áas - minuta

EdiDWr32:cmp       bh,1
         jne       EdiDWr34

         mov       ah,63                    ; omezen°
         call      GetDB                    ; poskytnut° á°sla
         mov       ah,0
         mov       cl,5
         shl       ax,cl
         and       word ptr es:[si],not 7e0h ; zru®en° starÇ minuty
         or        es:[si],ax               ; nov† minuta
         jmp       short EditDWr9

; ------ áas - sekunda

EdiDWr34:mov       ah,63                    ; omezen°
         call      GetDB                    ; poskytnut° á°sla
         shr       al,1                     ; sekunda / 2
         and       byte ptr es:[si],not 1fh ; zru®en° starÇ sekundy
         or        es:[si],al               ; nov† sekunda
         jmp       short EditDWr9

; ------ alokaán° blok

EditDWr4:cmp       bl,73
         jne       EditDWr9
         mov       cx,-1                    ; omezen°
         call      GetDW                    ; poskytnut° á°sla
         mov       es:[si],ax               ; á°slo

; ------ n†vrat registrñ

EditDWr9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditDWr  ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du FAT
; -----------------------------------------------------------------------------
;˛
EditF    PROC      NEAR

         call      GetFPol                  ; poskytnut° parametrñ poloëky FAT
         jnc       EditF1
         call      PredByte                 ; oprava adresy
EditF1:  call      GetKurz                  ; poskytnut° adresy kurzoru

         call      JumpBX

         dw        4d00h,EditFRg            ; kurzor vpravo
         dw        4b00h,EditFLf            ; kurzor vlevo
         dw        4800h,EditFUp            ; kurzor nahoru
         dw        5000h,EditFDn            ; kurzor dolñ

         dw        7300h,EditFCL            ; slovo vlevo
         dw        7400h,EditFTb            ; slovo vpravo

         dw        4700h,EditFHm            ; zaá†tek ©†dku
         dw        4f00h,EditFEn            ; konec ©†dku

;         dw        5300h,EditDDl            ; zru®en° znaku za kurzorem
;         dw        0e08h,EditDBs            ; zru®en° znaku p©ed kurzorem

         dw        0f09h,EditFTb            ; tabel†tor
         dw        0f00h,EditFST            ; zpàtnò tabel†tor

         dw        0,EditFCh                ; znak

; ------ vloëen° znaku

EditFCh: mov       al,bl                    ; znak
         call      TestDek                  ; test, zda je v AL znak DEK
         jc        EditFCh3                 ; nen° znak DEK

                                          ;* vloëen° á°slice
         call      InsBEdit                 ; vloëen° znaku do edit. bufferu
         call      EditFWr                  ; uloëen° poloëky FAT
         jmp       EditFRg                  ; kurzor vpravo

                                          ;* vloëen° mezery
EditFCh3:cmp       al," "                   ; mezera ?
         jne       EditFCh4                 ; nen° mezera
         call      InsBEdit                 ; vloëen° mezery do bufferu
         call      EditFWr                  ; uloëen° poloëky FAT
         call      OpenDis                  ; novÇ otev©en° á°sla
         mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
         jmp       EditFTb                  ; dal®° poloëka

                                          ;* speci†ln° znaky EOF, BAD
EditFCh4:call      GetKurz
         call      UpCase                   ; konverze na velkÇ p°smeno
         mov       di,0fff7h                ; vadnò blok
         cmp       al,"B"                   ; vadnò blok ?
         je        EditFCh5                 ; vadnò blok
         mov       di,0ffffh                ; konec souboru
         cmp       al,"E"                   ; konec souboru ?
         je        EditFCh5                 ; konec souboru
         ret

                                          ;* uloëen° poloëky
EditFCh5:xor       ax,ax
         mov       bx,0ffffh                ; maska pro FAT 16
         push      cx
         mov       cl,0                     ; rotace FAT 16
         test      byte ptr ds:[Param2],bit0 ; je FAT 16 ?
         jnz       EditFCh6                 ; je FAT 16
         mov       bh,0fh                   ; maska pro FAT 12
         test      ch,1                     ; je lich† poloëka ?
         jz        EditFCh6                 ; je sud† poloëka
         mov       cl,4                     ; rotace pro lichou poloëku
EditFCh6:shl       di,cl                    ; rotace á°sla
         shl       bx,cl                    ; rotace masky
         not       bx
         and       es:[si],bx               ; zru®en° starÇ hodnoty
         or        es:[si],di               ; nov† hodnota
         pop       cx
         call      OpenDis
         jmp       EditFTb                  ; dal®° poloëka

; ------ zaá†tek ©†dku

EditFHm: mov       cl,0
         call      SetByte                  ; nastaven° ukazatele
         call      OpenDis
         ret

; ------ konec ©†dku

EditFEn: dec       cx                       ; posledn° bajt na ©†dku
         dec       cx
         call      SetByte                  ; nastaven° ukazatele
         call      OpenDis
         ret

; ------ tabel†tor, kurzor dolñ

EditFTb: mov       cl,2
         test      byte ptr ds:[Param2],bit0 ; je FAT 16 ?
         jnz       EditFDn                  ; je FAT 16
         test      ch,1                     ; je lich† poloëka ?
         jnz       EditFDn                  ; je lich† poloëka
         dec       cx                       ; jinak posun 1 bajt
EditFDn: call      NextPByt                 ; posun ukazatele
         call      OpenDis
         ret

; ------ slovo vlevo

EditFCL: cmp       byte ptr ds:[KurzPol],0
         je        EditFST                  ; nen° poá†tek poloëky
         mov       byte ptr ds:[KurzPol],0
         ret

; ------ zpàtnò tabel†tor, kurzor nahoru

EditFST: mov       cl,2
         test      byte ptr ds:[Param2],bit0 ; je FAT 16 ?
         jnz       EditFUp                  ; je FAT 16
         test      ch,1                     ; je lich† poloëka ?
         jz        EditFUp                  ; je sud† poloëka
         dec       cx                       ; jinak posun 1 bajt
EditFUp: call      PredPByt                 ; posun ukazatele
         call      OpenDis
         ret

; ------ kurzor vlevo

EditFLf: cmp       byte ptr ds:[KurzPol],0
         je        EditFST                  ; p©edchoz° poloëka
         dec       byte ptr ds:[KurzPol]
         ret

; ------ kurzor vpravo

EditFRg: or        byte ptr ds:[Param2],bit3 ; p©°znak zah†jen° editace poloëky
         mov       al,ds:[KurzPol]
         inc       ax
         cmp       al,ds:[EditBDel]
         jae       EditFTb
         cmp       al,ds:[EditBNum]
         ja        EditFTb
         mov       ds:[KurzPol],al
         ret


EditF    ENDP

; -----------------------------------------------------------------------------
;        uloëen° poloëky FAT
; -----------------------------------------------------------------------------

EditFWr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ poskytnut° zadanÇho hodnoty

         mov       cx,0fffh                 ; omezen° FAT 12
         test      byte ptr ds:[Param2],bit0 ; je FAT 16 ?
         jz        EditFWr1                 ; je FAT 12
         mov       ch,0ffh                  ; omezen° FAT 16
EditFWr1:call      GetDW                    ; poskytnut° á°sla
         mov       bx,cx                    ; maska poloëky

; ------ p©°prava parametrñ poloëky

         call      GetKurz                  ; poskytnut° kurzoru
         call      GetFPol                  ; poskytnut° parametrñ poloëky FAT
         jnc       EditFWr2                 ; adresa je OK
         dec       si                       ; oprava adresy poloëky

; ------ poáet rotac° poloëky

EditFWr2:mov       cl,0                     ; rotace pro bàënou poloëku
         test      byte ptr ds:[Param2],bit0 ; je FAT 16 ?
         jnz       EditFWr3                 ; je FAT 16
         test      ch,1                     ; je lich† poloëka FAT 12 ?
         jz        EditFWr3                 ; je sud† poloëka FAT 12
         mov       cl,4                     ; rotace pro lichou poloëku

; ------ uloëen° poloëky

EditFWr3:shl       ax,cl                    ; rotace á°sla na pozici
         shl       bx,cl                    ; rotace masky na pozici
         not       bx
         and       word ptr es:[si],bx      ; nulov†n° starÇ hodnoty
         or        es:[si],ax               ; uloëen° novÇ hodnoty

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditFWr  ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du PARTITION
; -----------------------------------------------------------------------------

EditP    PROC      NEAR

         ret

EditP    ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du ASSEMBLER
; -----------------------------------------------------------------------------

EditA    PROC      NEAR

         ret

EditA    ENDP

; -----------------------------------------------------------------------------
;        editace v m¢du CMOS
; -----------------------------------------------------------------------------

EditC    PROC      NEAR

         ret

EditC    ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                      Editace jednotlivòch pol°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        editace pole ASCII (BX=kl†vesa)
; -----------------------------------------------------------------------------

EdAsc    PROC      NEAR

         mov       byte ptr ds:[KurzPolM],0 ; koncov† pozice kurzoru
         mov       byte ptr ds:[EditBDel],1 ; dÇlka editaán°ho bufferu
         mov       byte ptr ds:[EditBNum],1 ; poáet platnòch znakñ v bufferu
         mov       ax,word ptr ds:[EditAkt] ; aktu†ln° poloha kurzoru v objektu
         mov       dx,word ptr ds:[EditAkt+2]
         mov       cx,ds:[LinNum]           ; poáet bajtñ na ©†dek

         call      JumpBX

         dw        4b00h,EdAscLf            ; vlevo LEFT
         dw        4d00h,EdAscRg            ; vpravo RIGHT
         dw        4800h,EdAscUp            ; nahoru UP
         dw        5000h,EdAscDn            ; dolñ DOWN

         dw        7300h,EdAscCL            ; slovo vlevo C-LEFT
         dw        7400h,EdAscCR            ; slovo vpravo C-RIGHT

         dw        4700h,EdAscHm            ; zaá†tek ©†dku HOME
         dw        4f00h,EdAscEn            ; konec ©†dku END
         dw        7700h,EdAscCH            ; horn° okraj C-HOME
         dw        7500h,EdAscCE            ; doln° okraj C-END

         dw        4900h,EdAscPU            ; str†nka nahoru PageUp
         dw        5100h,EdAscPD            ; str†nka dolñ PageDown
         dw        8400h,EdAscCU            ; zaá†tek objektu C-PageUp
         dw        7600h,EdAscCD            ; konec objektu C-PageDown

         dw        0e08h,EdAscBs            ; BS obnoven° znaku
         dw        5300h,EdAscDl            ; DEL obnoven° znaku

         dw        0e7fh,EdAscCB            ; p©edchoz° mod. poloëka C-BS

         dw        0,EdAscIn                ; vloëen° znaku

; ------ kurzor vlevo LEFT (p©edchoz° poloëka)

EdAscLf: cmp       byte ptr ds:[KurzPol],0
         jne       EdAscLf3
         call      PredByte                 ; posun kurzoru na p©edchoz° bajt
EdAscLf2:jc        EdAscLf5
EdAscLf3:mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
EdAscLf4:call      OpenDis                  ; otev©en° novÇ poloëky
EdAscLf5:ret

; ------ kurzor vpravo RIGHT (n†sleduj°c° poloëka)

EdAscRg: call      NextByte                 ; posun kurzoru na dal®° bajt
         jmp       short EdAscLf2           ; normalizace bufferu

; ------ kurzor nahoru UP

EdAscUp: call      PredPByt                 ; podm°nànò posun ukazatele
         jc        EdAscLf5                 ; nen° dal®° ©†dek
         jmp       short EdAscLf4           ; otev©en° novÇ poloëky

; ------ kurzor dolñ DOWN

EdAscDn: call      NextPByt                 ; podm°nànò posun ukazatele
         jnc       EdAscLf4                 ; otev©en° novÇ poloëky
         sub       ax,word ptr ds:[EditTop] ; offset kurzoru od poá†tku str†nky
         xor       dx,dx
         div       cx                       ; vòpoáet á°sla ©†dku
         inc       ax                       ; zaokrouhlen° na dal®° ©†dek
         mul       cx                       ; offset dal®°ho ©†dku
         add       ax,word ptr ds:[EditTop] ; adresa dal®°ho ©†dku
         adc       dx,word ptr ds:[EditTop+2]
         jc        EdAscDn4
         sub       ax,word ptr ds:[EditMax]
         sbb       dx,word ptr ds:[EditMax+2]
         jnc       EdAscLf5                 ; nen° dal®° ©†dek
         call      NextNByt                 ; nepodm°nànò posun ukazatele
EdAscDn4:jmp       short EdAscLf3           ; normalizace bufferu


; ------ slovo vlevo C-LEFT

EdAscCL: call      PredByte                 ; posun o 1 znak vlevo
         jc        EdAscCL4                 ; nen° dal®° bajt
EdAscCL1:call      PredByte                 ; p©edchoz° bajt
         jc        EdAscCL4                 ; nen° dal®° bajt
         call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       al,es:[si]               ; 1. znak
         mov       ah,es:[si+1]             ; 2. znak
         call      TestWord                 ; test, je-li zaá†tek slova
         jc        EdAscCL1                 ; nen° zaá†tek slova - dal®° bajt
         call      NextByte                 ; n†vrat o 1 bajt zpàt
EdAscCL4:jmp       short EdAscLf3           ; normalizace bufferu

; ------ slovo vpravo C-RIGHT

EdAscCR: call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       al,es:[si]               ; 1. znak
         mov       ah,es:[si+1]             ; 2. znak
         call      TestWord                 ; test, je-li zaá†tek slova
         jnc       EdAscCR3                 ; je zaá†tek slova - konec
         call      NextByte                 ; posun na dal®° bajt
         jnc       EdAscCR                  ; test dal®°ho bajtu
         jmp       short EdAscLf3           ; normalizace bufferu
EdAscCR3:call      NextByte                 ; posun na prvn° bajt slova
EdAscCR4:jmp       short EdAscLf3           ; normalizace bufferu


; ------ zaá†tek ©†dku HOME

EdAscHm: sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; p©epoáet na pozici na ©†dku
         mov       cx,dx                    ; poáet pozic k posunu
         jcxz      EdAscHm4                 ; je jië zaá†tek ©†dku
         call      PredNByt                 ; nepodm°nànò posun ukazatele
EdAscHm2:jmp       short EdAscCL4           ; normalizace bufferu
EdAscHm4:ret

; ------ konec ©†dku END

EdAscEn: sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; p©epoáet na pozici na ©†dku
         inc       dx                       ; pozice + 1
         sub       cx,dx                    ; poáet zbylòch pozic do konce
         jz        EdAscHm4                 ; je jië konec ©†dku
         call      NextNByt                 ; nepodm°nànò posun ukazatele
EdAscEn2:jmp       short EdAscCR4           ; normalizace bufferu

; ------ horn° okraj C-HOME

EdAscCH: sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; vòpoáet á°sla ©†dku
         sub       ax,1                     ; poáet ©†dkñ k posunu
         jbe       EdAscHm4                 ; je jië horn° okraj
EdAscCH2:call      PredPByt                 ; posun o 1 ©†dek
         jc        EdAscHm2
         dec       ax
         jnz       EdAscCH2
         jmp       short EdAscHm2           ; normalizace bufferu

; ------ doln° okraj C-END

EdAscCE: sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; vòpoáet á°sla ©†dku
         sub       ax,19                    ; - poáet ©†dkñ k posunu
         jae       EdAscHm4                 ; je jië doln° okraj
EdAscCE2:call      NextPByt                 ; posun o 1 ©†dek
         jc        EdAscEn2
         inc       ax
         jnz       EdAscCE2
EdAscCE4:jmp       short EdAscEn2           ; normalizace bufferu


; ------ str†nka nahoru PageUp

EdAscPU: add       ax,cx
         adc       dx,0
         sub       ax,word ptr ds:[EditMax]
         sbb       dx,word ptr ds:[EditMax+2]
         jc        EdAscPU1
         call      PredPByt                 ; posun o 1 ©†dek nahoru
EdAscPU1:mov       bx,20                    ; poáet ©†dkñ k posunu
         mov       ax,word ptr ds:[EditTop] ; poá†tek str†nky LOW
         mov       dx,word ptr ds:[EditTop+2] ; poá†tek str†nky HIGH
         or        dx,dx
         jnz       EdAscPU2                 ; str†nka je dostateánà od poá†tku
         div       cx                       ; vòpoáet poátu ©†dkñ od poá†tku
         cmp       ax,bx                    ; je dostateánà daleko od poá†tku ?
         jae       EdAscPU2                 ; je dostateánà daleko
         xchg      ax,bx                    ; BX <- omezen° poátu ©†dkñ
EdAscPU2:xchg      ax,bx                    ; AX <- poáet ©†dkñ k posunu
         or        ax,ax                    ; je nàjakò ©†dek ?
         jz        EdAscCU                  ; nen° ©†dek - skok na zaá†tek
         mul       cx                       ; poáet bajtñ k posunu
         sub       word ptr ds:[EditTop],ax ; posun poá†tku str†nky
         sbb       word ptr ds:[EditTop+2],dx
         sub       word ptr ds:[EditAkt],ax ; posun kurzoru
         sbb       word ptr ds:[EditAkt+2],dx
EdAscPU4:jmp       short EdAscCE4           ; normalizace bufferu

; ------ str†nka dolñ PageDown

EdAscPD: mov       byte ptr ds:[KurzPol],0  ; kurzor na poá†tek poloëky
         or        dx,dx
         jnz       EdAscPD1                 ; kurzor nen° na zaá†tku
         cmp       ax,cx
         jae       EdAscPD1                 ; kurzor nen° na prvn°m ©†dku
         call      NextPByt                 ; posun o 1 ©†dek dolñ
EdAscPD1:mov       ax,word ptr ds:[EditMax] ; velikost objektu
         mov       dx,word ptr ds:[EditMax+2]
         sub       ax,ds:[DispNum]          ; maxim†ln° poá†tek k zobrazen°
         sbb       dx,0
         jc        EdAscCD                  ; zobrazen celò objekt
         mov       bx,20                    ; poáet ©†dkñ k posunu
         cmp       dx,-1
         je        EdAscPD2
         dec       cx
         add       ax,cx                    ; zaokrouhlen° na celò ©†dek
         adc       dx,0
         inc       cx
         sub       ax,word ptr ds:[EditTop] ; vzd†lenost od poá†tku
         sbb       dx,word ptr ds:[EditTop+2]
         jc        EdAscCD                  ; chyba - poá†tek za max. koncem
         jnz       EdAscPD2                 ; poá†tek je dostateánà vzd†len
         div       cx                       ; vòpoáet poátu ©†dkñ ke konci
         cmp       ax,bx                    ; je dostateánà daleko od konce ?
         jae       EdAscPD2                 ; je dostateánà daleko
         xchg      ax,bx                    ; BX <- omezen° poátu ©†dkñ
EdAscPD2:xchg      ax,bx                    ; AX <- poáet ©†dkñ k posunu
         or        ax,ax                    ; je nàjakò ©†dek ?
         jz        EdAscCD                  ; nen° ë†dnò ©†dek - skok na konec
         mul       cx                       ; poáet bajtñ k posunu
         add       word ptr ds:[EditTop],ax ; posun poá†tku str†nky
         adc       word ptr ds:[EditTop+2],dx
         add       word ptr ds:[EditAkt],ax ; posun kurzoru
         adc       word ptr ds:[EditAkt+2],dx
EdAscPD4:jmp       short EdAscPU4

; ------ zaá†tek objektu C-PageUp

EdAscCU: mov       word ptr ds:[EditAkt],0
         mov       word ptr ds:[EditAkt+2],0
         jmp       short EdAscPU4

; ------ konec objektu C-PageDown

EdAscCD: mov       ax,word ptr ds:[EditMax]
         mov       dx,word ptr ds:[EditMax+2]
         sub       ax,1
         sbb       dx,0
         jc        EdAscCU                  ; objekt m† nulovou velikost
         mov       word ptr ds:[EditAkt],ax
         mov       word ptr ds:[EditAkt+2],dx
         jmp       short EdAscPD4


; ------ vloëen° znaku

EdAscIn: test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu do objektu ?
         jnz       EdAscIn6                 ; je z†kaz z†pisu do objektu
         call      GetKurz                  ; poskytnut° adresy kurzoru ES:SI
         xchg      ax,bx                    ; AX <- znak
         cmp       ax,300h
         je        EdAscIn4                 ; znak Ctrl-@ je povolen
         cmp       al,0
         je        EdAscIn9                 ; neplatnò znak
EdAscIn4:mov       es:[si],al               ; uloëen° znaku do bufferu
EdAscIn6:jmp       EdAscRg                  ; posun kurzoru
EdAscIn9:ret

; ------ obnoven° znaku p©ed kurzorem

EdAscBs: call      PredByte                 ; p©edchoz° znak
         jc        EdAscBs6                 ; nen° dal®° znak
         mov       byte ptr ds:[KurzPol],0  ; kurzor na poá†tek poloëky
         call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       al,es:[si+8000h]         ; pñvodn° znak
         mov       es:[si],al               ; n†vrat znaku
EdAscBs6:ret

; ------ obnoven° znaku nad kurzorem

EdAscDl: call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       al,es:[si+8000h]         ; pñvodn° znak
         mov       es:[si],al               ; n†vrat znaku
         mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
         call      OpenDis                  ; otev©en° novÇ poloëky
         jmp       short EdAscIn6           ; posun kurzoru vpravo

; ------ skok na p©edchoz° modifikovanou poloëku Ctrl-BS

EdAscCB: mov       di,word ptr ds:[EditTop+2]
         mov       cx,word ptr ds:[EditTop]
EdAscCB1:call      PredByte                 ; posun na p©edchoz° bajt
         jc        EdAscCB4                 ; nen° dal®° bajt
         call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       bl,es:[si+8000h]         ; pñvodn° znak
         cmp       bl,es:[si]               ; je zmàna znaku ?
         je        EdAscCB1                 ; nalezen° zmànànÇho znaku
EdAscCB3:jmp       EdAscLf3                 ; normalizace bufferu
EdAscCB4:mov       word ptr ds:[EditAkt],ax ; n†vrat kurzoru
         mov       word ptr ds:[EditAkt+2],dx
         mov       word ptr ds:[EditTop],cx ; n†vrat poá†tku str†nky
         mov       word ptr ds:[EditTop+2],di
         jmp       short EdAscCB3           ; normalizace bufferu

EdAsc    ENDP

; -----------------------------------------------------------------------------
;        editace hexadecim†ln°ho pole (BX=kl†vesa)
; -----------------------------------------------------------------------------
;˛
EdHex    PROC      NEAR

         mov       byte ptr ds:[KurzPolM],1 ; maxim†ln° pozice kurzoru
         mov       byte ptr ds:[EditBDel],2 ; dÇlka editaán°ho bufferu
         mov       byte ptr ds:[EditBNum],2 ; poáet platnòch znakñ v bufferu
         mov       ax,word ptr ds:[EditAkt]
         mov       dx,word ptr ds:[EditAkt+2]
         mov       cx,ds:[LinNum]           ; poáet bajtñ na ©†dek

         call      JumpBX

         dw        4b00h,EdHexLf            ; vlevo LEFT
         dw        4d00h,EdHexRg            ; vpravo RIGHT
         dw        4800h,EdAscUp            ; nahoru UP
         dw        5000h,EdAscDn            ; dolñ DOWN

         dw        7300h,EdAscLf            ; slovo vlevo C-LEFT
         dw        7400h,EdAscRg            ; slovo vpravo C-RIGHT

         dw        4700h,EdAscHm            ; zaá†tek ©†dku HOME
         dw        4f00h,EdAscEn            ; konec ©†dku END
         dw        7700h,EdAscCH            ; horn° okraj C-HOME
         dw        7500h,EdAscCE            ; doln° okraj C-END

         dw        4900h,EdAscPU            ; str†nka nahoru PageUp
         dw        5100h,EdAscPD            ; str†nka dolñ PageDown
         dw        8400h,EdAscCU            ; zaá†tek objektu C-PageUp
         dw        7600h,EdAscCD            ; konec objektu C-PageDown

         dw        0e08h,EdHexBs            ; BS obnoven° znaku
         dw        5300h,EdAscDl            ; DEL obnoven° znaku

         dw        0e7fh,EdAscCB            ; p©edchoz° mod. poloëka C-BS

         dw        0,EdHexCh                ; vloëen° znaku

; ------ obnoven° znaku p©ed kurzorem

EdHexBs: mov       cl,ds:[KurzPol]          ; pozice kurzoru
         shl       cl,1
         shl       cl,1
         jnz       EdHexBs2                 ; byla nië®° tetr†da
         call      PredByte                 ; p©edchoz° znak
         jc        EdHexBs6                 ; nen° dal®° znak
EdHexBs2:call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       al,es:[si+8000h]         ; pñvodn° znak
         mov       ah,0f0h                  ; maska ponech†vanÇ hodnoty
         shr       ah,cl
         and       es:[si],ah               ; maskov†n° ponech†vanÇ hodnoty
         not       ah
         and       al,ah                    ; maskov†n° pñvodn° hodnoty
         or        es:[si],al               ; nastaven° pñvodn° hodnoty
         xor       byte ptr ds:[KurzPol],1  ; zmàna pozice kurzoru
EdHexBs6:ret

; ------ vloëen° znaku HEX

EdHexCh: call      GetKurz                  ; poskytnut° adresy kurzoru ES:SI
         mov       al,bl                    ; znak
         call      TestHex                  ; test, zda je v AL znak HEX
         jc        EdHexBs6                 ; nen° znak HEX

         test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu do objektu ?
         jnz       EdHexRg                  ; je z†kaz z†pisu do objektu
         mov       cl,ds:[KurzPol]          ; kurzor v poloëce
         xor       cl,1
         shl       cl,1
         shl       cl,1                     ; korekce 0 nebo 4
         mov       ah,0f0h                  ; maska znaku
         shl       al,cl                    ; rotace na pozici
         shr       ah,cl
         and       es:[si],ah               ; maskov†n° starÇ tetr†dy
         or        es:[si],al               ; uloëen° novÇ hodnoty
;         jmp       short EdHexRg            ; posun kurzoru vpravo

; ------ kurzor vpravo

EdHexRg: or        byte ptr ds:[Param2],bit3 ; p©°znak zah†jen° editace
         mov       al,ds:[KurzPol]          ; kurzor v poloëce
         inc       ax                       ; posun kurzoru
         cmp       al,ds:[EditBDel]         ; je na konci poloëky ?
         jae       EdHexRg1                 ; p©esun na dal®° poloëku
         cmp       al,ds:[EditBNum]         ; je na konci textu ?
         ja        EdHexRg1                 ; p©esun na dal®° poloëku
         mov       ds:[KurzPol],al          ; nov† pozice kurzoru
         ret

EdHexRg1:call      NextByte                 ; posun kurzoru na dal®° bajt
         jc        EdHexRg6
         mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
EdHexRg4:call      OpenDis                  ; otev©en° novÇ poloëky
EdHexRg6:ret

; ------ kurzor vlevo

EdHexLf: cmp       byte ptr ds:[KurzPol],0  ; je kurzoru na poá†tku poloëky ?
         je        EdHexLf1                 ; je na poá†tku poloëky
         dec       byte ptr ds:[KurzPol]    ; posun kurzoru vlevo
         ret
EdHexLf1:call      PredByte                 ; posun kurzoru na p©edchoz° bajt
         jc        EdHexRg6                 ; neposunut
         mov       al,ds:[KurzPolM]         ; maxim†ln° pozice kurzoru
         mov       ds:[KurzPol],al          ; kurzor v poloëce
         jmp       short EdHexRg4

EdHex    ENDP

; -----------------------------------------------------------------------------
;        editace bin†rn°ho pole (BX=kl†vesa)
; -----------------------------------------------------------------------------
;˛
EdBin    PROC      NEAR

         mov       byte ptr ds:[KurzPolM],7
         mov       byte ptr ds:[EditBDel],8 ; dÇlka editaán°ho bufferu
         mov       byte ptr ds:[EditBNum],8 ; poáet platnòch znakñ v bufferu
         mov       ax,word ptr ds:[EditAkt]
         mov       dx,word ptr ds:[EditAkt+2]
         mov       cx,ds:[LinNum]           ; poáet bajtñ na ©†dek

         call      JumpBX

         dw        4b00h,EdHexLf            ; vlevo LEFT
         dw        4d00h,EdHexRg            ; vpravo RIGHT
         dw        4800h,EdAscUp            ; nahoru UP
         dw        5000h,EdAscDn            ; dolñ DOWN

         dw        7300h,EdAscLf            ; slovo vlevo C-LEFT
         dw        7400h,EdAscRg            ; slovo vpravo C-RIGHT

         dw        4700h,EdAscHm            ; zaá†tek ©†dku HOME
         dw        4f00h,EdAscEn            ; konec ©†dku END
         dw        7700h,EdAscCH            ; horn° okraj C-HOME
         dw        7500h,EdAscCE            ; doln° okraj C-END

         dw        4900h,EdAscPU            ; str†nka nahoru PageUp
         dw        5100h,EdAscPD            ; str†nka dolñ PageDown
         dw        8400h,EdAscCU            ; zaá†tek objektu C-PageUp
         dw        7600h,EdAscCD            ; konec objektu C-PageDown

         dw        0e08h,EdBinBs            ; BS obnoven° znaku
         dw        5300h,EdAscDl            ; DEL obnoven° znaku

         dw        0e7fh,EdAscCB            ; p©edchoz° mod. poloëka C-BS

         dw        0,EdBinCh                ; vloëen° znaku

; ------ obnoven° znaku p©ed kurzorem

EdBinBs: mov       cl,ds:[KurzPol]          ; pozice kurzoru
         cmp       cl,0                     ; je prvn° znak ?
         jnz       EdBinBs2                 ; nen° prvn° znak
         call      PredByte                 ; p©edchoz° znak
         jc        EdBinBs6                 ; nen° dal®° znak
EdBinBs2:call      GetKurz                  ; poskytnut° adresy kurzoru
         dec       cx
         and       cl,7
         mov       ds:[KurzPol],cl          ; nov† pozice kurzoru
         mov       al,es:[si+8000h]         ; pñvodn° znak
         mov       ah,7fh                   ; maska ponech†vanÇ hodnoty
         ror       ah,cl
         and       es:[si],ah               ; maskov†n° ponech†vanÇ hodnoty
         not       ah
         and       al,ah                    ; maskov†n° pñvodn° hodnoty
         or        es:[si],al               ; nastaven° pñvodn° hodnoty
EdBinBs6:ret

; ------ vloëen° znaku BIN

EdBinCh: call      GetKurz                  ; poskytnut° adresy kurzoru ES:SI
         mov       al,bl                    ; znak
         call      TestBin                  ; test, zda je v AL znak BIN
         jc        EdBinBs6                 ; nen° znak BIN

         test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu do objektu ?
         jnz       EdBinCh4                 ; je z†kaz z†pisu do objektu
         mov       cl,ds:[KurzPol]          ; kurzor v poloëce
         not       cl
         and       cl,7
         mov       ah,0feh                  ; maska znaku
         shl       al,cl                    ; rotace na pozici
         rol       ah,cl
         and       es:[si],ah               ; maskov†n° starÇho bitu
         or        es:[si],al               ; uloëen° novÇ hodnoty
EdBinCh4:jmp       EdHexRg                  ; posun kurzoru

EdBin    ENDP

; -----------------------------------------------------------------------------
;        editace dekadickÇho pole (BX=kl†vesa)
; -----------------------------------------------------------------------------
;˛
EdDek    PROC      NEAR

         mov       byte ptr ds:[KurzPolM],0
         mov       ax,word ptr ds:[EditAkt]
         mov       dx,word ptr ds:[EditAkt+2]
         mov       cx,ds:[LinNum]           ; poáet bajtñ na ©†dek

         call      JumpBX

         dw        4b00h,EdHexLf            ; vlevo
         dw        4d00h,EdHexRg            ; vpravo
         dw        4800h,EdAscUp            ; nahoru
         dw        5000h,EdAscDn            ; dolñ

         dw        7300h,EdAscLf            ; slovo vlevo
         dw        7400h,EdAscRg            ; slovo vpravo

         dw        4700h,EdAscHm            ; zaá†tek ©†dku HOME
         dw        4f00h,EdAscEn            ; konec ©†dku END
         dw        7700h,EdAscCH            ; horn° okraj C-HOME
         dw        7500h,EdAscCE            ; doln° okraj C-END

         dw        4900h,EdAscPU            ; str†nka nahoru PageUp
         dw        5100h,EdAscPD            ; str†nka dolñ PageDown
         dw        8400h,EdAscCU            ; zaá†tek objektu C-PageUp
         dw        7600h,EdAscCD            ; konec objektu C-PageDown

         dw        0e08h,EdDekBs            ; BS zru®en° znaku p©ed kurzorem
         dw        5300h,EdDekDl            ; DEL zru®en° znaku za kurzorem

         dw        0e7fh,EdAscCB            ; p©edchoz° mod. poloëka C-BS

         dw        0,EdDekCh                ; vloëen° znaku

; ------ zru®en° znaku p©ed kurzorem

EdDekBs: cmp       byte ptr ds:[KurzPol],0  ; je kurzor na zaá†tku poloëky ?
         je        EdDekBs4                 ; kurzor je na zaá†tku poloëky

         call      GetKurz                  ; poskytnut° adresy kurzoru
         dec       byte ptr ds:[KurzPol]    ; posun kurzoru

         test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu do objektu ?
         jnz       EdDekBs2                 ; je z†kaz z†pisu do objektu

         call      DelBEdit                 ; zru®en° znaku za kurzorem
         call      GetDB0                   ; poskytnut° á°sla z bufferu
         mov       es:[si],al               ; uloëen° á°sla
EdDekBs2:ret

EdDekBs4:call      PredByte                 ; posun kurzoru na p©edchoz° bajt
         jc        EdDekBs6                 ; neposunut
         call      GetKurz
         mov       al,es:[si+8000h]         ; pñvodn° znak
         mov       es:[si],al               ; n†vrat znaku
         call      OpenDis                  ; novÇ otev©en° poloëky
EdDekBs6:ret

; ------ vloëen° znaku

EdDekCh: call      GetKurz                  ; poskytnut° adresy kurzoru ES:SI
         mov       al,bl                    ; znak
         call      TestDek                  ; test, zda je v AL znak DEK
         jc        EdDekCh4                 ; nen° znak HEX

         test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu do objektu ?
         jnz       EdDekCh2                 ; je z†kaz z†pisu do objektu
         call      InsBEdit                 ; vloëen° znaku do edit. bufferu
         call      GetDB0                   ; poskytnut° á°sla z bufferu
         mov       es:[si],al               ; uloëen° á°sla
EdDekCh2:jmp       EdHexRg                  ; posun kurzoru

EdDekCh4:cmp       al," "                   ; mezera ?
         jne       EdDekCh9                 ; nen° mezera
         call      InsBEdit                 ; vloëen° mezery do bufferu

         call      GetDB0                   ; poskytnut° á°sla z bufferu
         mov       es:[si],al               ; uloëen° á°sla
         call      OpenDis                  ; novÇ otev©en° á°sla
         mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
         jmp       EdAscRg                  ; posun kurzoru

EdDekCh9:ret

; ------ zru®en° znaku za kurzorem

EdDekDl: call      GetKurz                  ; poskytnut° adresy kurzoru
         cmp       byte ptr ds:[EditBNum],0 ; je nàjakò znak v bufferu ?
         je        EdDekDl4                 ; v bufferu nic nen°

         test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu do objektu ?
         jnz       EdDekDl2                 ; je z†kaz z†pisu do objektu

         call      DelBEdit                 ; zru®en° znaku za kurzorem
         call      GetDB0                   ; poskytnut° á°sla z bufferu
         mov       es:[si],al               ; uloëen° á°sla
EdDekDl2:ret

EdDekDl4:jmp       EdAscDl

EdDek    ENDP

; -----------------------------------------------------------------------------
;        editace pole WORD (BX=kl†vesa)
; -----------------------------------------------------------------------------
;˛
EdWrd    PROC      NEAR

         mov       byte ptr ds:[KurzPolM],0
         mov       cx,ds:[LinNum]           ; poáet bajtñ na ©†dek
         mov       ax,word ptr ds:[EditAkt]
         mov       dx,word ptr ds:[EditAkt+2]

         call      JumpBX

         dw        4b00h,EdWrdLf            ; vlevo
         dw        4d00h,EdWrdRg            ; vpravo
         dw        4800h,EdWrdUp            ; nahoru
         dw        5000h,EdWrdDn            ; dolñ

         dw        7300h,EdWrdCL            ; slovo vlevo
         dw        7400h,EdWrdCR            ; slovo vpravo

         dw        4700h,EdWrdHm            ; zaá†tek ©†dku
         dw        4f00h,EdWrdEn            ; konec ©†dku
         dw        7700h,EdWrdCH            ; horn° okraj C-HOME
         dw        7500h,EdWrdCE            ; doln° okraj C-END

         dw        4900h,EdWrdPU            ; str†nka nahoru PageUp
         dw        5100h,EdWrdPD            ; str†nka dolñ PageDown
         dw        8400h,EdWrdCU            ; zaá†tek objektu C-PageUp
         dw        7600h,EdWrdCD            ; konec objektu C-PageDown

         dw        0e08h,EdWrdBs            ; BS zru®en° znaku p©ed kurzorem
         dw        5300h,EdWrdDl            ; DEL zru®en° znaku za kurzorem

         dw        0e7fh,EdWrdCB            ; p©edchoz° mod. poloëka C-BS

         dw        0,EdWrdIn                ; vloëen° znaku


; ------ kurzor vlevo

EdWrdLf: cmp       byte ptr ds:[KurzPol],0  ; je kurzor na poá†tku poloëky ?
         je        EdWrdLf1                 ; je na poá†tku poloëky
         dec       byte ptr ds:[KurzPol]    ; posun kurzoru
         ret
EdWrdLf1:call      PredByte                 ; posun kurzoru na p©edchoz° bajt
         jc        EdWrdLf6                 ; nen° dal®° bajt (slovo)
         call      PredByte
         call      OpenDis                  ; otev©en° poloëky dekadickÇho pole
EdWrdLf6:ret

; ------ kurzor vpravo

EdWrdRg: or        byte ptr ds:[Param2],bit3 ; p©°znak zah†jen° editace
         mov       al,ds:[KurzPol]          ; kurzor v poloëce
         inc       ax                       ; posun kurzoru
         cmp       al,ds:[EditBDel]         ; je na konci poloëky ?
         jae       EdWrdRg1                 ; p©esun na dal®° poloëku
         cmp       al,ds:[EditBNum]         ; je na konci textu ?
         ja        EdWrdRg1                 ; p©esun na dal®° poloëku
         mov       ds:[KurzPol],al          ; nov† pozice kurzoru
         ret

; ------ slovo vpravo

EdWrdCR:
EdWrdRg1:call      NextByte                 ; posun kurzoru na dal®° bajt
         jc        EdWrdRg6                 ; nen° dal®° bajt (slovo)
         call      NextByte
         jc        EdWrdRg7                 ; nen° dal®° slovo
         call      OpenDis                  ; otev©en° novÇ poloëky
EdWrdRg6:ret

EdWrdRg7:call      PredByte                 ; n†vrat bajtu, nen°-li dal®° slovo
         ret

; ------ kurzor nahoru

EdWrdUp: call      PredPByt                 ; podm°nànò posun ukazatele
         jc        EdWrdUp5                 ; nen° dal®° ©†dek
         call      OpenDis                  ; otev©en° novÇ poloëky
EdWrdUp5:ret

; ------ kurzor dolñ

EdWrdDn: call      NextPByt                 ; podm°nànò posun ukazatele
         jnc       EdWrdDn4                 ; otev©en° novÇ poloëky
         sub       ax,word ptr ds:[EditTop] ; offset kurzoru od poá†tku str†nky
         xor       dx,dx
         div       cx                       ; vòpoáet á°sla ©†dku
         inc       ax                       ; zaokrouhlen° na dal®° ©†dek
         mul       cx                       ; offset dal®°ho ©†dku
         add       ax,word ptr ds:[EditTop] ; adresa dal®°ho ©†dku
         adc       dx,word ptr ds:[EditTop+2]
         jc        EdWrdDn4
         sub       ax,word ptr ds:[EditMax]
         sbb       dx,word ptr ds:[EditMax+2]
         jnc       EdWrdDn5                 ; nen° dal®° ©†dek
EdWrdDn1:shr       cx,1
         jcxz      EdWrdDn5
EdWrdDn2:call      NextByte                 ; posun ukazatele
         jc        EdWrdDn4
         call      NextByte
         jc        EdWrdDn3
         loop      EdWrdDn2
         jmp       short EdWrdDn4
EdWrdDn3:call      PredByte                 ; n†vrat lichÇho bajtu
EdWrdDn4:call      OpenDis                  ; otev©en° novÇ poloëky
EdWrdDn5:ret


; ------ slovo vlevo

EdWrdCL: cmp       byte ptr ds:[KurzPol],0  ; je zaá†tek poloëky ?
         jne       EdWrdCL2                 ; nen° zaá†tek poloëky
         call      PredByte
         jc        EdWrdCL3
         call      PredByte
         call      OpenDis                  ; otev©en° novÇ poloëky
EdWrdCL2:mov       byte ptr ds:[KurzPol],0  ; kurzor na poá†tek poloëky
EdWrdCl3:ret



; ------ zaá†tek ©†dku

EdWrdHm: sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; p©epoáet na pozici na ©†dku
         mov       cx,dx                    ; poáet pozic k posunu
         jcxz      EdWrdHm4                 ; je jië zaá†tek ©†dku
         call      PredNByt                 ; nepodm°nànò posun ukazatele
         call      OpenDis                  ; otev©en° novÇ poloëky
EdWrdHm4:ret

; ------ konec ©†dku

EdWrdEn: shr       cx,1
         sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; p©epoáet na pozici na ©†dku
         inc       dx                       ; pozice + 1
         sub       cx,dx                    ; poáet zbylòch pozic do konce
         jmp       short EdWrdDn1

; ------ horn° okraj C-HOME

EdWrdCH: sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; vòpoáet á°sla ©†dku
         sub       ax,1                     ; poáet ©†dkñ k posunu
         jbe       EdWrdCH5                 ; je jië horn° okraj
EdWrdCH2:call      PredPByt                 ; posun o 1 ©†dek
         jc        EdWrdCH4
         dec       ax
         jnz       EdWrdCH2
EdWrdCH4:call      OpenDis                  ; otev©en° novÇ poloëky
EdWrdCH5:ret

; ------ doln° okraj C-END

EdWrdCE: sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; vòpoáet á°sla ©†dku
         sub       ax,19                    ; - poáet ©†dkñ k posunu
         jae       EdWrdCE5                 ; je jië doln° okraj
EdWrdCE2:call      NextPByt                 ; posun o 1 ©†dek
         jc        EdWrdCE4
         inc       ax
         jnz       EdWrdCE2
EdWrdCE4:call      OpenDis                  ; otev©en° novÇ poloëky
EdWrdCE5:ret


; ------ str†nka nahoru PageUp

EdWrdPU: add       ax,cx
         adc       dx,0
         sub       ax,word ptr ds:[EditMax]
         sbb       dx,word ptr ds:[EditMax+2]
         jc        EdWrdPU1
         call      PredPByt                 ; posun o 1 ©†dek nahoru
EdWrdPU1:mov       bx,20                    ; poáet ©†dkñ k posunu
         mov       ax,word ptr ds:[EditTop] ; poá†tek str†nky LOW
         mov       dx,word ptr ds:[EditTop+2] ; poá†tek str†nky HIGH
         or        dx,dx
         jnz       EdWrdPU2                 ; str†nka je dostateánà od poá†tku
         div       cx                       ; vòpoáet poátu ©†dkñ od poá†tku
         cmp       ax,bx                    ; je dostateánà daleko od poá†tku ?
         jae       EdWrdPU2                 ; je dostateánà daleko
         xchg      ax,bx                    ; BX <- omezen° poátu ©†dkñ
EdWrdPU2:xchg      ax,bx                    ; AX <- poáet ©†dkñ k posunu
         or        ax,ax                    ; je nàjakò ©†dek ?
         jz        EdWrdCU                  ; nen° ©†dek - skok na zaá†tek
         mul       cx                       ; poáet bajtñ k posunu
         sub       word ptr ds:[EditTop],ax ; posun poá†tku str†nky
         sbb       word ptr ds:[EditTop+2],dx
         sub       word ptr ds:[EditAkt],ax ; posun kurzoru
         sbb       word ptr ds:[EditAkt+2],dx
         call      OpenDis                  ; otev©en° novÇ poloëky
         ret

; ------ str†nka dolñ PageDown

EdWrdPD: or        dx,dx
         jnz       EdWrdPD1                 ; kurzor nen° na zaá†tku
         cmp       ax,cx
         jae       EdWrdPD1                 ; kurzor nen° na prvn°m ©†dku
         call      NextPByt                 ; posun o 1 ©†dek dolñ
EdWrdPD1:mov       ax,word ptr ds:[EditMax] ; velikost objektu
         mov       dx,word ptr ds:[EditMax+2]
         sub       ax,ds:[DispNum]          ; maxim†ln° poá†tek k zobrazen°
         sbb       dx,0
         jc        EdWrdCD                  ; zobrazen celò objekt
         mov       bx,20                    ; poáet ©†dkñ k posunu
         cmp       dx,-1
         je        EdWrdPD2
         dec       cx
         add       ax,cx                    ; zaokrouhlen° na celò ©†dek
         adc       dx,0
         inc       cx
         sub       ax,word ptr ds:[EditTop] ; vzd†lenost od poá†tku
         sbb       dx,word ptr ds:[EditTop+2]
         jc        EdWrdCD                  ; chyba - poá†tek za max. koncem
         jnz       EdWrdPD2                 ; poá†tek je dostateánà vzd†len
         div       cx                       ; vòpoáet poátu ©†dkñ ke konci
         cmp       ax,bx                    ; je dostateánà daleko od konce ?
         jae       EdWrdPD2                 ; je dostateánà daleko
         xchg      ax,bx                    ; BX <- omezen° poátu ©†dkñ
EdWrdPD2:xchg      ax,bx                    ; AX <- poáet ©†dkñ k posunu
         or        ax,ax                    ; je nàjakò ©†dek ?
         jz        EdWrdCD                  ; nen° ë†dnò ©†dek - skok na konec
         mul       cx                       ; poáet bajtñ k posunu
         add       word ptr ds:[EditTop],ax ; posun poá†tku str†nky
         adc       word ptr ds:[EditTop+2],dx
         add       word ptr ds:[EditAkt],ax ; posun kurzoru
         adc       word ptr ds:[EditAkt+2],dx
         call      OpenDis                  ; otev©en° poloëky
         ret

; ------ zaá†tek objektu C-PageUp

EdWrdCU: mov       word ptr ds:[EditAkt],0
         mov       word ptr ds:[EditAkt+2],0
         call      OpenDis                  ; otev©en° poloëky
         ret

; ------ konec objektu C-PageDown

EdWrdCD: mov       ax,word ptr ds:[EditMax]
         mov       dx,word ptr ds:[EditMax+2]
         mov       cx,1
         test      ax,1                     ; je lichò offset ?
         jnz       EdWrdCD1
         inc       cx                       ; bude posun o 2 bajty
EdWrdCD1:sub       ax,cx
         sbb       dx,0
         jc        EdWrdCU                  ; objekt m† nulovou velikost
         mov       word ptr ds:[EditAkt],ax
         mov       word ptr ds:[EditAkt+2],dx
         call      OpenDis                  ; otev©en° poloëky
         ret



; ------ zru®en° znaku p©ed kurzorem

EdWrdBs: cmp       byte ptr ds:[KurzPol],0  ; je kurzor na zaá†tku poloëky ?
         je        EdWrdBs4                 ; kurzor je na zaá†tku poloëky

         dec       byte ptr ds:[KurzPol]    ; posun kurzoru
EdWrdBS1:call      DelBEdit                 ; zru®en° znaku za kurzorem
EdWrdBs2:call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       cx,ds:[EditNum]          ; poáet bajtñ v bufferu
         dec       cx                       ; bez posledn°ho bajtu
         add       cx,ds:[BuffOff1]         ; adresa konce dat
         cmp       cx,si                    ; je posledn° bajt v bufferu ?
         je        EdWrdBs3                 ; je posledn° bajt v bufferu
         mov       cx,0ffffh                ; omezen° á°sla
         call      GetDW                    ; poskytnut° á°sla z bufferu
         mov       es:[si],ax               ; uloëen° á°sla
         ret

EdWrdBs3:call      GetDB0                   ; poskytnut° bajtu z bufferu
         mov       es:[si],al
         ret


EdWrdBs4:mov       cl,2
         call      PredPByt                 ; p©edchoz° bajt
         jc        EdWrdBs6
EdWrdBs5:call      GetKurz
         mov       cx,ds:[EditNum]          ; poáet bajtñ v bufferu
         dec       cx                       ; bez posledn°ho bajtu
         add       cx,ds:[BuffOff1]         ; adresa konce dat
         cmp       cx,si                    ; je posledn° bajt v bufferu ?
         je        EdWrdBs8                 ; je posledn° bajt v bufferu
         mov       ax,es:[si+8000h]         ; pñvodn° slovo
         mov       es:[si],ax               ; n†vrat slova
         call      OpenDis                  ; novÇ otev©en° poloëky
EdWrdBs6:ret

EdWrdBs8:mov       al,es:[si+8000h]         ; pñvodn° slovo
         mov       es:[si],al               ; n†vrat slova
         call      OpenDis                  ; novÇ otev©en° poloëky
EdWrdBs9:ret


; ------ vloëen° znaku

EdWrdIn: call      GetKurz                  ; poskytnut° adresy kurzoru ES:SI
         mov       al,bl                    ; znak
         call      TestDek                  ; test, zda je v AL znak DEK
         jc        EdWrdIn4                 ; nen° znak HEX

         test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu ?
         jnz       EdWrdIn2                 ; je z†kaz z†pisu
         call      InsBEdit                 ; vloëen° znaku do edit. bufferu
         call      EdWrdBS2                 ; aktualizace slova
EdWrdIn2:jmp       EdWrdRg                  ; posun kurzoru vpravo

EdWrdIn4:cmp       al," "                   ; mezera ?
         jne       EdWrdBs9                 ; nen° mezera

         test      byte ptr ds:[Param2],bit1 ; je z†kaz z†pisu ?
         jnz       EdWrdIn5                 ; je z†kaz z†pisu
         call      InsBEdit                 ; vloëen° mezery do bufferu
         call      EdWrdBS2                 ; aktualizace slova
EdWrdIn5:jmp       EdWrdCR                  ; posun kurzoru

; ------ zru®en° znaku za kurzorem

EdWrdDl: call      GetKurz                  ; poskytnut° adresy kurzoru
         cmp       byte ptr ds:[EditBNum],0 ; je nàjakò znak v bufferu ?
         je        EdWrdDl4                 ; v bufferu nic nen°

         call      DelBEdit                 ; zru®en° znaku za kurzorem
         call      EdWrdBs2                 ; aktualizace slova
         ret

EdWrdDl4:call      EdWrdBs5                 ; obnoven° slova
         jmp       short EdWrdIn5           ; posun kurzoru


; ------ skok na p©edchoz° modifikovanou poloëku Ctrl-BS

EdWrdCB: mov       di,word ptr ds:[EditTop+2]
         mov       cx,word ptr ds:[EditTop]
EdWrdCB1:call      PredByte                 ; posun na p©edchoz° bajt
         jc        EdWrdCB4                 ; nen° dal®° bajt
         call      PredByte                 ; posun na p©edchoz° slovo
         jc        EdWrdCB4                 ; nen° dal®° bajt
         call      GetKurz                  ; poskytnut° adresy kurzoru
         mov       bx,es:[si+8000h]         ; pñvodn° znak
         cmp       bx,es:[si]               ; je zmàna znaku ?
         je        EdWrdCB1                 ; nalezen° zmànànÇho znaku
EdWrdCB3:call      OpenDis                  ; novÇ otev©en° poloëky
         ret

EdWrdCB4:mov       word ptr ds:[EditAkt],ax ; n†vrat kurzoru
         mov       word ptr ds:[EditAkt+2],dx
         mov       word ptr ds:[EditTop],cx ; n†vrat poá†tku str†nky
         mov       word ptr ds:[EditTop+2],di
         jmp       short EdWrdCB3

EdWrd    ENDP

; -----------------------------------------------------------------------------
;        otev©en° zobrazenÇho form†tu (otev©en° poloëky pod kurzorem)
; -----------------------------------------------------------------------------

OpenDis  PROC      NEAR

         test      byte ptr ds:[DispMod],bit0 ; je HEX zobrazen° ?
         jz        OpenDis1                 ; nen° HEX zobrazen°
         jmp       OpenHex                  ; otev©en° HEX okna

OpenDis1:test      byte ptr ds:[DispMod],bit1 ; je bin†rn° zobrazen° ?
         jz        OpenDis2                 ; nen° bin†rn° zobrazen°
         jmp       OpenBin                  ; otev©en° bin†rn°ho okna

OpenDis2:test      byte ptr ds:[DispMod],bit2 ; je dekadickÇ zobrazen° ?
         jz        OpenDis3                 ; nen° dekadickÇ zobrazen°
         jmp       OpenDek                  ; otev©en° dekadickÇho okna

OpenDis3:test      byte ptr ds:[DispMod],bit3 ; je zobrazen° WORD ?
         jz        OpenDis4
         jmp       OpenWrd                  ; otev©en° okna WORD

OpenDis4:test      byte ptr ds:[DispMod],bit4 ; zobrazen° TEXT ?
         jz        OpenDis5
         jmp       OpenTxt                  ; otev©en° okna TEXT

OpenDis5:test      byte ptr ds:[DispMod],bit5 ; zobrazen adres†© ?
         jz        OpenDis6
         jmp       OpenAdr                  ; otev©en° okna adres†©e

OpenDis6:test      byte ptr ds:[DispMod],bit6 ; zobrazena FAT ?
         jz        OpenDis7
         jmp       OpenFat                  ; otev©en° okna FAT

OpenDis7:test      byte ptr ds:[DispMod],bit7 ; zobrazen° PARTITON
         jz        OpenDis8
         jmp       OpenPar                  ; otev©en° okna PARTITION

OpenDis8:


         ret

OpenDis  ENDP

; -----------------------------------------------------------------------------
;        otev©en° hexadecim†ln°ho okna
; -----------------------------------------------------------------------------

OpenHex  PROC      NEAR

         mov       word ptr ds:[DispNum],16*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],16  ; poáet bajtñ na zobrazenò ©†dek
         call      NormBuff                 ; normalizace bufferu
         ret

OpenHex  ENDP

; -----------------------------------------------------------------------------
;        otev©en° bin†rn°ho okna
; -----------------------------------------------------------------------------

OpenBin  PROC      NEAR

         mov       word ptr ds:[DispNum],4*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],4   ; poáet bajtñ na zobrazenò ©†dek

; ------ test, zda je dekadickÇ pole bin†rn°ho okna

         cmp       byte ptr ds:[EditPole],2 ; je dekadickÇ pole ?
         je        OpenBin2                 ; je dekadickÇ pole
         call      NormBuff                 ; normalizace bufferu
         ret

; ------ £schova registrñ

OpenBin2:push      ax
         push      cx
         push      dx
         push      si
         push      es

         call      GetKurz                  ; poskytnut° kurzoru

; ------ vòpoáet ©†dku a pozice poloëky na displeji

         mov       ax,word ptr ds:[EditAkt] ; kurzor
         sub       ax,word ptr ds:[EditTop] ; offset od zaá†tku pole
         mov       dl,al
         and       dl,3                     ; pozice relativnà
         shr       ax,1
         shr       ax,1
         mov       dh,al                    ; ©†dek relativnà
         add       dh,3                     ; korekce á°sla ©†dku
         shl       dl,1
         shl       dl,1                     ; pozice * 4
         add       dl,59                    ; poá†teán° pozice pole

; ------ pñvodn° hodnota poloëky

         mov       al,es:[si]               ; bajt

; ------ otev©en° poloëky

         mov       cl,3                     ; dÇlka poloëky
         call      OpenDB                   ; otev©en° poloëky

; ------ n†vrat registrñ

OpenBin9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OpenBin  ENDP

; -----------------------------------------------------------------------------
;        otev©en° dekadickÇho okna
; -----------------------------------------------------------------------------

OpenDek  PROC      NEAR

         mov       word ptr ds:[DispNum],10*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],10  ; poáet bajtñ na zobrazenò ©†dek

; ------ test, zda je dekadickÇ pole dekadickÇho okna

         cmp       byte ptr ds:[EditPole],0 ; je dekadickÇ pole ?
         je        OpenDek2                 ; je dekadickÇ pole
         call      NormBuff                 ; normalizace bufferu
         ret

; ------ £schova registrñ

OpenDek2:push      ax
         push      cx
         push      dx
         push      si
         push      es

         call      GetKurz                  ; poskytnut° kurzoru

; ------ vòpoáet ©†dku a pozice poloëky na displeji

         mov       ax,word ptr ds:[EditAkt] ; kurzor
         sub       ax,word ptr ds:[EditTop] ; offset od zaá†tku pole
         xor       dx,dx
         mov       cx,10
         div       cx                       ; vòpoáet ©†dku a pozice
         mov       dh,al                    ; ©†dek relativnà
         add       dh,3                     ; korekce á°sla ©†dku
         mov       al,dl
         shl       dl,1
         shl       dl,1                     ; pozice * 4
         add       dl,al                    ; pozice * 5
         cmp       al,5
         jb        OpenDek3
         add       dl,3                     ; korekce 2. á†sti
OpenDek3:add       dl,16                    ; poá†teán° pozice pole

; ------ pñvodn° hodnota poloëky

         mov       al,es:[si]               ; bajt

; ------ otev©en° poloëky

         mov       cl,3                     ; dÇlka poloëky
         call      OpenDB                   ; otev©en° poloëky

; ------ n†vrat registrñ

OpenDek9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OpenDek  ENDP

; -----------------------------------------------------------------------------
;        otev©en° okna WORD
; -----------------------------------------------------------------------------

OpenWrd  PROC      NEAR

         and       byte ptr ds:[EditTop],not 1
         mov       word ptr ds:[DispNum],10*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],10  ; poáet bajtñ na zobrazenò ©†dek

; ------ test, zda je dekadickÇ pole okna WORD

         cmp       byte ptr ds:[EditPole],0 ; je dekadickÇ pole ?
         je        OpenWrd2                 ; je dekadickÇ pole
         call      NormBuff                 ; normalizace bufferu
         ret

; ------ £schova registrñ

OpenWrd2:push      ax
         push      cx
         push      dx
         push      si
         push      es

         and       byte ptr ds:[EditAkt],not 1

         call      GetKurz                  ; poskytnut° kurzoru

; ------ vòpoáet ©†dku a pozice poloëky na displeji

         mov       ax,word ptr ds:[EditAkt] ; kurzor
         sub       ax,word ptr ds:[EditTop] ; offset od zaá†tku pole
         shr       ax,1                     ; poáet slov
         xor       dx,dx
         mov       cx,5
         div       cx                       ; vòpoáet ©†dku a pozice
         mov       dh,al                    ; ©†dek relativnà
         add       dh,3                     ; korekce á°sla ©†dku
         mov       al,10
         mul       dl                       ; pozice * 10
         mov       dl,al
         add       dl,18                    ; poá†teán° pozice pole

; ------ pñvodn° hodnota poloëky

         mov       al,es:[si]
         mov       ah,0
         mov       cx,ds:[EditNum]          ; poáet bajtñ v bufferu
         dec       cx                       ; bez posledn°ho bajtu
         add       cx,ds:[BuffOff1]         ; adresa konce dat
         cmp       cx,si                    ; je posledn° bajt v bufferu ?
         je        OpenWrd4                 ; je posledn° bajt v bufferu
         mov       ax,es:[si]               ; slovo
OpenWrd4:

; ------ otev©en° poloëky

         mov       cl,6                     ; dÇlka poloëky
         call      OpenDW                   ; otev©en° poloëky

; ------ n†vrat registrñ

OpenWrd9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OpenWrd  ENDP

; -----------------------------------------------------------------------------
;        otev©en° textovÇho okna
; -----------------------------------------------------------------------------

OpenTxt  PROC      NEAR

         mov       word ptr ds:[DispNum],78*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],78  ; poáet bajtñ na zobrazenò ©†dek
         call      NormBuff                 ; normalizace bufferu
         ret

OpenTxt  ENDP

; -----------------------------------------------------------------------------
;        otev©en° okna adres†©e
; -----------------------------------------------------------------------------

OpenAdr  PROC      NEAR

         mov       word ptr ds:[DispNum],32*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],32  ; poáet bajtñ na zobrazenò ©†dek

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         call      NormBuff

; ------ vòpoáet ©†dku a pozice poloëky na displeji

         mov       ax,word ptr ds:[EditAkt] ; kurzor
         sub       ax,word ptr ds:[EditTop] ; offset od zaá†tku pole
         mov       dl,al
         and       dl,1fh                   ; relativn° pozice
         mov       cl,5
         shr       ax,cl                    ; ©†dek
         mov       dh,al                    ; ©†dek

; ------ korekce pozice

         mov       bl,dl                    ; pozice relativnà
         mov       bh,0
         mov       cl,ds:[bx+KorAdrOp]      ; oprava adresy
         mov       ch,0

; ------ oprava ukazatele

         jcxz      OpenAdr3
OpenAdr2:call      PredByte                 ; p©edchoz° bajt
         jc        OpenAdr3
         loop      OpenAdr2
OpenAdr3:call      GetKurz                  ; adresa kurzoru

; ------ adresa poloëky na displeji

         mov       byte ptr ds:[EditBDel],0 ; zru®en° dÇlky
         mov       dl,ds:[bx+KorAdrK]       ; pozice na displeji
         add       dh,3                     ; ©†dek

; ------ otev©en° poloëky velikosti souboru

         cmp       dl,23
         jne       OpenAdr4
         mov       ax,es:[si]               ; velikost LOW
         mov       bx,es:[si+2]             ; velikost HIGH
         mov       cl,13                    ; velikost
         call      OpenDD                   ; otev©en° poloëky
         jmp       short OpenAd99

; ------ otev©en° poloëky data

OpenAdr4:cmp       dl,37
         jne       OpenAdr5                 ; nen° datum

                                          ;* den
         mov       ax,es:[si]               ; datum
         and       ax,1fh                   ; den
         mov       cl,2                     ; velikost poloëky
         cmp       byte ptr ds:[EditPole],0 ; je poloëka dne ?
         je        OpenAd46                 ; je den

                                          ;* màs°c
         mov       ax,es:[si]               ; datum
         mov       cl,5
         shr       ax,cl
         and       ax,0fh                   ; màs°c
         mov       cl,2                     ; velikost poloëky
         add       dl,3                     ; pozice
         cmp       byte ptr ds:[EditPole],1 ; je poloëka màs°ce ?
         je        OpenAd46                 ; je màs°c

                                          ;* rok
         add       dl,3                     ; pozice
         mov       al,es:[si+1]             ; datum HIGH
         shr       ax,1
         and       ax,7fh                   ; rok - 1980
         add       ax,1980                  ; rok
         mov       cl,4                     ; velikost poloëky

OpenAd46:call      OpenDW                   ; otev©en° poloëky
OpenAd99:jmp       short OpenAdr9

; ------ otev©en° poloëky áasu

OpenAdr5:cmp       dl,48
         jne       OpenAdr6                 ; nen° áas

                                          ;* hodina
         mov       al,es:[si+1]             ; áas HIGH
         mov       cl,3
         shr       al,cl                    ; hodina
         cmp       byte ptr ds:[EditPole],0 ; je poloëka hodiny ?
         je        OpenAd55                 ; je hodina

                                          ;* minuta
         add       dl,3                     ; zvò®en° pozice
         mov       ax,es:[si]               ; áas
         mov       cl,5
         shr       ax,cl                    ; minuta
         and       al,3fh                   ; minuta
         cmp       byte ptr ds:[EditPole],1 ; je poloëka minuty ?
         je        OpenAd55                 ; je minuta

                                          ;* sekunda
         add       dl,3                     ; zvò®en° pozice
         mov       al,es:[si]               ; áas LOW
         and       al,1fh                   ; sekunda / 2
         shl       al,1                     ; sekunda

OpenAd55:mov       cl,2                     ; poáet pozic
         call      OpenDB                   ; otev©en° poloëky
         jmp       short OpenAdr9

; ------ otev©en° poloëky alokaán°ho bloku

OpenAdr6:cmp       dl,73
         jne       OpenAdr8                 ; nen° alokaán° blok
         mov       ax,es:[si]               ; alokaán° blok
         mov       cl,6                     ; dÇlka poloëky
         call      OpenDW                   ; otev©en° poloëky
         jmp       short OpenAdr9

OpenAdr8:mov       ds:[KurzPol],0

; ------ n†vrat registrñ

OpenAdr9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenAdr  ENDP

; -----------------------------------------------------------------------------
;        otev©en° okna FAT
; -----------------------------------------------------------------------------

OpenFAT  PROC

         mov       word ptr ds:[DispNum],20*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],20  ; poáet bajtñ na zobrazenò ©†dek
         test      byte ptr ds:[Param2],bit0 ; je FAT 12 ?
         jnz       OpenFAT1                 ; je FAT 16
         mov       word ptr ds:[DispNum],15*21 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],15  ; poáet bajtñ na zobrazenò ©†dek

; ------ £schova registrñ

OpenFAT1:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ p©°prava parametrñ poloëky FAT

         call      GetKurz                  ; poskytnut° kurzoru
         call      GetFPol                  ; poskytnut° parametrñ poloëky FAT
         jnc       OpenFAT2                 ; adresa OK
         call      PredByte                 ; oprava adresy
         dec       si

; ------ vòpoáet pozice na displeji

OpenFAT2:mov       al,7                     ; pozic na poloëku
         mul       ch                       ; vòpoáet pozice relativnà
         add       al,8
         cmp       ch,5
         jb        OpenFT22
         add       al,2                     ; korekce pozice
OpenFT22:mov       dl,al                    ; pozice na displeji

; ------ p©°prava á°sla alokaán°ho bloku

         mov       ax,es:[si]               ; aktu†ln° slovo
         test      byte ptr ds:[Param2],bit0
         jnz       OpenFAT4                 ; je FAT 16
         test      ch,1                     ; je sud† poloëka ?
         jz        OpenFAT3                 ; je sud† poloëka FAT
         mov       cl,4
         shr       ax,cl                    ; rotace na pozici
OpenFAT3:and       ax,0fffh                 ; maska á°sla bloku pro FAT 12

; ------ otev©en° á°selnÇ poloëky

OpenFAT4:mov       cl,6                     ; dÇlka poloëky
         call      OpenDW

; ------ n†vrat registrñ

OpenFAT9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenFAT  ENDP

; -----------------------------------------------------------------------------
;        otev©en° okna PARTITION
; -----------------------------------------------------------------------------

OpenPar  PROC      NEAR

         mov       word ptr ds:[DispNum],16*4 ; poáet bajtñ na zobraz. str†nku
         mov       word ptr ds:[LinNum],16  ; poáet bajtñ na zobrazenò ©†dek
         call      NormBuff                 ; normalizace bufferu
         ret

OpenPar  ENDP

; -----------------------------------------------------------------------------
;        test, zda je v AL znak BIN (a p©evod na á°slo BIN)
; -----------------------------------------------------------------------------

TestBin  PROC      NEAR

; ------ á°slice 0 nebo 1

         cmp       al,"0"
         je        TestBin3
         cmp       al,"1"
         je        TestBin3

; ------ chyba - neplatnò znak

TestBin2:stc                                ; p©°znak neplatnÇho znaku
         ret

TestBin3:sub       al,"0"                   ; korekce na á°slo BIN
         ret

TestBin  ENDP

; -----------------------------------------------------------------------------
;        test, zda je v AL znak HEX (a p©evod na á°slo HEX)
; -----------------------------------------------------------------------------

TestHex  PROC      NEAR

; ------ á°slice 0 aë 9

         cmp       al,"0"
         jb        TestHex4
         cmp       al,"9"
         jbe       TestHex3

; ------ velkÇ p°smeno

         cmp       al,"A"
         jb        TestHex4
         cmp       al,"F"
         jbe       TestHex2

; ------ malÇ p°smeno

         cmp       al,"a"
         jb        TestHex4
         cmp       al,"f"+1
         cmc
         jc        TestHex4

; ------ p©evod znaku na á°slo

         sub       al,32                    ; korekce na velkÇ p°smeno
TestHex2:sub       al,7                     ; korekce na á°slici
TestHex3:sub       al,"0"                   ; korekce na á°slo
         ret

; ------ chyba - neplatnò znak

TestHex4:stc                                ; p©°znak - nen° znak HEX
         ret

TestHex  ENDP

; -----------------------------------------------------------------------------
;        test, zda je v AL znak DEK
; -----------------------------------------------------------------------------

TestDek  PROC      NEAR

; ------ á°slice 0 aë 9

         cmp       al,"0"
         jb        TestDek4
         cmp       al,"9"
         ja        TestDek4
         clc                                ; p©°znak znaku OK
         ret

; ------ chyba - neplatnò znak

TestDek4:stc                                ; p©°znak - nen° znak HEX
         ret

TestDek  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° adresy kurzoru ES:SI (s normalizac° bufferu)
; -----------------------------------------------------------------------------

GetKurz  PROC      NEAR

         call      NormBuff                 ; normalizace bufferu
         mov       es,ds:[BuffSegm]         ; segment bufferñ
         mov       si,word ptr ds:[EditAkt] ; kurzor v objektu
         sub       si,word ptr ds:[EditBeg] ; offset v bufferu
         add       si,ds:[BuffOff1]         ; adresa v editaán°m bufferu
         ret

GetKurz  ENDP

; -----------------------------------------------------------------------------
;        nastaven° ukazatele na offset CL (skuteánò je DL, CY=chyba)
; -----------------------------------------------------------------------------

SetByte  PROC      NEAR

         push      cx
         mov       ch,0

; ------ smàr posunu

         sub       cl,dl                    ; rozd°l offsetñ
         je        SetByte9                 ; shoda
         js        SetByte3                 ; posun dolñ

; ------ posun nahoru

         call      NextPByt                 ; posun ukazatele
         jmp       short SetByte9

; ------ posun dolñ

SetByte3:neg       cl
         call      PredPByt                 ; posun ukazatele dolñ

SetByte9:pop       cx
         ret

SetByte  ENDP

; -----------------------------------------------------------------------------
;        nepodm°nànò posun ukazatele na p©edchoz° bajt (CL krokñ, CY=chyba)
; -----------------------------------------------------------------------------

PredNByt PROC      NEAR

         push      cx
         mov       ch,0
PredNBt2:call      PredByte                 ; posun ukazatele
         jc        PredNBt3
         loop      PredNBt2
PredNBt3:pop       cx
         ret

PredNByt ENDP

; -----------------------------------------------------------------------------
;        podm°nànò posun ukazatele na p©edchoz° bajt (CL krokñ, CY=chyba)
; -----------------------------------------------------------------------------

PredPByt PROC      NEAR

         push      cx
         push      bx
         xor       bx,bx
         mov       ch,0
PredPBt2:call      PredByte                 ; posun ukazatele
         jc        PredPBt3
         inc       bx
         loop      PredPBt2
         jmp       short PredPBt6

PredPBt3:mov       cx,bx
         jcxz      PredPBt6
PredPBt4:call      NextByte
         jc        PredPBt5
         loop      PredPBt4
PredPBt5:stc

PredPBt6:pop       bx
         pop       cx
         ret

PredPByt ENDP

; -----------------------------------------------------------------------------
;        nepodm°nànò posun ukazatele na n†sleduj°c° bajt (CL krokñ, CY=chyba)
; -----------------------------------------------------------------------------

NextNByt PROC      NEAR

         push      cx
         mov       ch,0
NextNBt2:call      NextByte                 ; posun ukazatele
         jc        NextNBt3
         loop      NextNBt2
NextNBt3:pop       cx
         ret

NextNByt ENDP

; -----------------------------------------------------------------------------
;        podm°nànò posun ukazatele na n†sleduj°c° bajt (CL krokñ, CY=chyba)
; -----------------------------------------------------------------------------

NextPByt PROC      NEAR

         push      cx
         push      bx
         xor       bx,bx
         mov       ch,0
NextPBt2:call      NextByte                 ; posun ukazatele
         jc        NextPBt3
         inc       bx
         loop      NextPBt2
         jmp       short NextPBt6

NextPBt3:mov       cx,bx
         jcxz      NextPBt6
NextPBt4:call      PredByte
         jc        NextPBt5
         loop      NextPBt4
NextPBt5:stc

NextPBt6:pop       bx
         pop       cx
         ret

NextPByt ENDP

; -----------------------------------------------------------------------------
;        posun ukazatele na p©edchoz° bajt
; -----------------------------------------------------------------------------

PredByte PROC      NEAR

         push      ax
         push      dx

         mov       ax,word ptr ds:[EditAkt] ; kurzor LOW
         mov       dx,word ptr ds:[EditAkt+2] ; kurzor HIGH

         or        dx,dx
         jnz       PredByt2
         or        ax,ax
         stc
         jz        PredByt4

PredByt2:sub       ax,1
         mov       word ptr ds:[EditAkt],ax ; novò kurzor LOW
         sbb       dx,0
         mov       word ptr ds:[EditAkt+2],dx ; novò kurzor HIGH
         clc

PredByt4:pop       dx
         pop       ax
         ret

PredByte ENDP

; -----------------------------------------------------------------------------
;        posun ukazatele na dal®° bajt
; -----------------------------------------------------------------------------

NextByte PROC      NEAR

         push      ax
         push      dx

         mov       ax,word ptr ds:[EditAkt] ; kurzor LOW
         mov       dx,word ptr ds:[EditAkt+2] ; kurzor HIGH

         add       ax,1
         adc       dx,0

         jc        NextByt4
         cmp       dx,word ptr ds:[EditMax+2]
         jne       NextByt2
         cmp       ax,word ptr ds:[EditMax]
         cmc
         jc        NextByt4

NextByt2:mov       word ptr ds:[EditAkt],ax ; novò kurzor LOW
         mov       word ptr ds:[EditAkt+2],dx ; novò kurzor HIGH
         clc

NextByt4:pop       dx
         pop       ax
         ret

NextByte ENDP

; -----------------------------------------------------------------------------
;        £schova ukazatelñ objektu
; -----------------------------------------------------------------------------

PushAkt  PROC      NEAR

         push      ax

         mov       ax,word ptr ds:[EditBeg]
         mov       word ptr ds:[EditOBeg],ax
         mov       ax,word ptr ds:[EditBeg+2]
         mov       word ptr ds:[EditOBeg+2],ax

         mov       ax,ds:[EditNum]
         mov       ds:[EditONum],ax

         mov       ax,word ptr ds:[EditAkt]
         mov       word ptr ds:[EditOAkt],ax
         mov       ax,word ptr ds:[EditAkt+2]
         mov       word ptr ds:[EditOAkt+2],ax

         mov       ax,word ptr ds:[EditTop]
         mov       word ptr ds:[EditOTop],ax
         mov       ax,word ptr ds:[EditTop+2]
         mov       word ptr ds:[EditOTop+2],ax

         mov       al,ds:[KurzPol]
         mov       ds:[KurzOPol],al

         pop       ax
         ret

PushAkt  ENDP

; -----------------------------------------------------------------------------
;        n†vrat ukazatelñ objektu
; -----------------------------------------------------------------------------

PopAkt   PROC      NEAR

         push      ax

         mov       ax,word ptr ds:[EditOBeg]
         mov       word ptr ds:[EditBeg],ax
         mov       ax,word ptr ds:[EditOBeg+2]
         mov       word ptr ds:[EditBeg+2],ax

         mov       ax,ds:[EditONum]
         mov       ds:[EditNum],ax

         mov       ax,word ptr ds:[EditOAkt]
         mov       word ptr ds:[EditAkt],ax
         mov       ax,word ptr ds:[EditOAkt+2]
         mov       word ptr ds:[EditAkt+2],ax

         mov       ax,word ptr ds:[EditOTop]
         mov       word ptr ds:[EditTop],ax
         mov       ax,word ptr ds:[EditOTop+2]
         mov       word ptr ds:[EditTop+2],ax

         mov       al,ds:[KurzOPol]
         mov       ds:[KurzPol],al

         pop       ax
         ret

PopAkt   ENDP

; -----------------------------------------------------------------------------
;        test bufferu, jestli byl modifikov†n (CY=byl modifikov†n)
; -----------------------------------------------------------------------------

TestBuff PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava ukazatelñ

         mov       cx,ds:[EditNum]          ; poáet bajtñ v bufferu
         mov       si,ds:[BuffOff1]         ; SI <- editaán° buffer
         mov       di,ds:[BuffOff2]         ; DI <- referenán° buffer
         mov       es,ds:[BuffSegm]         ; adresa bufferñ
         push      es
         pop       ds                       ; DS <- adresa bufferñ

; ------ porovn†n° obsahñ bufferñ

         cld
         push      cx                       ; £schova poátu bajtñ v bufferu
         shr       cx,1                     ; polovina (slova)
         repe      cmpsw                    ; porovn†n° bufferñ
         pop       cx                       ; CX <- poáet bajtñ v bufferu
         jne       TestBuf4                 ; nen° shoda
         and       cx,1                     ; lichò bajt (pro sudò bajt je ZY)
         repe      cmpsb                    ; porovn†n° lichÇho bajtu
         je        TestBuf5                 ; buffery jsou shodnÇ
TestBuf4:stc                                ; p©°znak modifikace bufferu

; ------ n†vrat registrñ

TestBuf5:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         ret

TestBuff ENDP

; -----------------------------------------------------------------------------
;        n†vrat obsahu editaán°ho bufferu z referenán°ho bufferu
; -----------------------------------------------------------------------------

PopBuff  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         mov       cx,ds:[EditNum]          ; poáet bajtñ v editaán°m bufferu
         mov       di,ds:[BuffOff1]         ; DI <- editaán° buffer
         mov       si,ds:[BuffOff2]         ; SI <- referenán° buffer
         mov       es,ds:[BuffSegm]         ; adresa bufferñ
         push      es
         pop       ds                       ; DS <- adresa bufferñ

; ------ n†vrat obsahu editaán°ho bufferu

         shr       cx,1                     ; poáet slov v bufferu
         rep       movsw                    ; p©esun obsahu bufferu
         adc       cx,cx
         rep       movsb                    ; p©enos lichÇho bajtu

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         ret

PopBuff  ENDP

; -----------------------------------------------------------------------------
;        inicializace mezn°kñ bufferu
; -----------------------------------------------------------------------------

InitMez  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ doln° mezn°k bufferu

         mov       dx,word ptr ds:[EditBeg+2]
         mov       ax,word ptr ds:[EditBeg] ; poá†tek dat v bufferu
         push      ax
         or        ax,dx                    ; je poá†tek dat = 0 ?
         pop       ax
         jz        InitMez2                 ; poá†tek = 0, nen° spodn° hranice
         add       ax,80                    ; rezerva smàrem dolñ
         adc       dx,0                     ; p©enos HIGH
InitMez2:mov       word ptr ds:[EditAkt0],ax ; doln° mezn°k bufferu
         mov       word ptr ds:[EditAkt0+2],dx

; ------ horn° mezn°k bufferu

         mov       dx,word ptr ds:[EditBeg+2]
         mov       ax,word ptr ds:[EditBeg] ; poá†tek dat v bufferu
         add       ax,ds:[EditNum]          ; konec dat v bufferu
         adc       dx,0
         cmp       dx,word ptr ds:[EditMax+2] ; je konec dat ?
         jne       InitMez4
         cmp       ax,word ptr ds:[EditMax]
InitMez4:jae       InitMez6                 ; je konec dat
         sub       ax,DISPMAX+80            ; rezerva smàrem nahoru
         sbb       dx,0
InitMez6:mov       word ptr ds:[EditAkt1],ax ; horn° mezn°k bufferu
         mov       word ptr ds:[EditAkt1+2],dx

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

InitMez  ENDP

; -----------------------------------------------------------------------------
;        normalizace bufferu
; -----------------------------------------------------------------------------

NormBuff PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       cx,word ptr ds:[EditTop] ; poá†tek str†nky LOW
         mov       bx,word ptr ds:[EditTop+2] ; poá†tek str†nky HIGH

; ------ omezen° kurzoru

         mov       ax,word ptr ds:[EditAkt] ; poloha kurzoru LOW
         mov       dx,word ptr ds:[EditAkt+2] ; poloha kurzoru HIGH
         cmp       dx,word ptr ds:[EditMax+2]
         jne       NormBf12
         cmp       ax,word ptr ds:[EditMax]
NormBf12:jb        NormBf13
         mov       ax,word ptr ds:[EditMax]
         mov       dx,word ptr ds:[EditMax+2]
         sub       ax,1
         sbb       dx,0
         jc        NormBf13
         mov       word ptr ds:[EditAkt],ax
         mov       word ptr ds:[EditAkt+2],dx

; ------ minim†ln° adresa poá†tku

NormBf13:mov       ax,word ptr ds:[EditAkt] ; poloha kurzoru LOW
         mov       dx,word ptr ds:[EditAkt+2] ; poloha kurzoru HIGH
         sub       ax,ds:[LinNum]           ; odeáten° jednoho ©†dku
         sbb       dx,0                     ; p©enos HIGH
         jnc       NormBf22                 ; nen° p©eteáen°
         xor       ax,ax
         xor       dx,dx

; ------ kontrola kurzoru, zda je podteáen° pod poá†tek

NormBf22:cmp       dx,bx
         jne       NormBf23
         cmp       ax,cx
NormBf23:jae       NormBf24                 ; kurzor je OK
         xchg      ax,cx
         xor       ax,ax
         xchg      ax,dx
         mov       di,ds:[LinNum]
         div       di
         xchg      ax,cx
         div       di
         mul       di
         xchg      ax,cx
         mov       bx,dx
         mul       di
         add       bx,ax

; ------ maxim†ln° adresa poá†tku

NormBf24:mov       ax,word ptr ds:[EditAkt] ; poloha kurzoru LOW
         mov       dx,word ptr ds:[EditAkt+2] ; poloha kurzoru HIGH
         add       ax,ds:[LinNum]           ; odeáten° jednoho ©†dku
         adc       dx,0                     ; p©enos HIGH
         sub       ax,ds:[DispNum]          ; posun o str†nku
         sbb       dx,0
         jc        NormBf34

; ------ kontrola kurzoru, zda je p©eteáen° za konec

NormBf32:cmp       dx,bx
         jne       NormBf33
         cmp       ax,cx
NormBf33:jb        NormBf34                 ; kurzor je OK
         mov       di,ds:[LinNum]
         dec       di
         add       ax,di
         adc       dx,0
         inc       di
         xchg      ax,cx
         xor       ax,ax
         xchg      ax,dx
         div       di
         xchg      ax,cx
         div       di
         mul       di
         xchg      ax,cx
         mov       bx,dx
         mul       di
         add       bx,ax

; ------ maxim†ln° poá†tek od konce

NormBf34:mov       ax,word ptr ds:[EditMax] ; velikost objektu LOW
         mov       dx,word ptr ds:[EditMax+2] ; velikost objektu HIGH
         add       ax,ds:[LinNum]           ; odeáten° jednoho ©†dku
         adc       dx,0                     ; p©enos HIGH
         sub       ax,1
         sbb       dx,0
         sub       ax,ds:[DispNum]          ; posun o str†nku
         sbb       dx,0
         jnc       NormBf42
         xor       ax,ax
         xor       dx,dx

; ------ kontrola, zda je p©eteáen° poá†tku

NormBf42:cmp       dx,bx
         jne       NormBf43
         cmp       ax,cx
NormBf43:jae       NormBf44                 ; poá†tek je OK
         sub       cx,word ptr ds:[LinNum]  ; posun poá†tku o 1 ©†dek
         sbb       bx,0                     ; p©enos HIGH
         jnc       NormBf42
         xor       cx,cx
         xor       bx,bx

; ------ uloëen° novÇho poá†tku

NormBf44:mov       word ptr ds:[EditTop],cx
         mov       word ptr ds:[EditTop+2],bx

; ------ kontrola kurzoru, zda je t©eba posunout buffer

         mov       ax,word ptr ds:[EditTop] ; kurzor LOW
         mov       dx,word ptr ds:[EditTop+2] ; kurzor HIGH
         cmp       dx,word ptr ds:[EditAkt0+2]
         jne       NormBf51
         cmp       ax,word ptr ds:[EditAkt0]
NormBf51:jb        NormBf53                 ; kurzor je pod bufferem
         cmp       dx,word ptr ds:[EditAkt1+2]
         jne       NormBf52
         cmp       ax,word ptr ds:[EditAkt1]
NormBf52:ja        NormBf53                 ; kurzor je nad bufferem
         clc
         jmp       NormBuf9                 ; kurzor je v bufferu OK

; ------ test, zda byl buffer modifikov†n

NormBf53:call      TestBuff                 ; test bufferu, zda byl modifikov†n
         jnc       NormBuf7                 ; buffer nebyl modifikov†n

; ------ buffer byl modifikov†n - dotaz, zda se m† uloëit

         mov       si,offset ModiMnu        ; menu - dotaz na uloëen° dat
         call      HMenu                    ; horizont†ln° menu
         call      JumpBX                   ; skok na obsluhu
         dw        1,NormBf56               ; uloëen° zmàn
         dw        2,NormBuf7               ; zmàny se neuloë°
         dw        0,NormBuf8               ; jinak p©eru®en° operace

; ------ uloëen° obsahu bufferu

NormBf56:call      WritBuff                 ; uloëen° obsahu bufferu na disk
         jnc       NormBuf7
         jmp       NormBuf8                 ; chyba - p©eru®en° operace

; ------ stanoven° novÇho poá†tku bufferu

NormBuf7:mov       cx,word ptr ds:[EditTop] ; aktu†ln° kurzor LOW
         mov       ax,word ptr ds:[EditTop+2] ; aktu†ln° kurzor HIGH
         sub       cx,4000h                 ; kurzor do poloviny bufferu
         sbb       ax,0
         jnc       NormBf72
         xor       cx,cx
         xor       ax,ax
NormBf72:mov       bx,ds:[ObjBlok]          ; velikost jednoho bloku dat
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; poá†tek bufferu HIGH
         xchg      ax,cx                    ; AX <- poá†tek bufferu LOW
         div       bx                       ; poá†tek bufferu LOW
         mul       bx                       ; korigovanò poá†tek LOW
         mov       word ptr ds:[EditBeg],ax ; poá†tek bufferu LOW
         mov       word ptr ds:[EditBeg+2],dx ; poá†tek bufferu HIGH
         xchg      ax,cx                    ; AX <- poá†tek bufferu HIGH
         mul       bx                       ; korigovanò poá†tek HIGH
         add       word ptr ds:[EditBeg+2],ax ; poá†tek bufferu HIGH

; ------ naáten° novÇho obsahu bufferu

NormBf78:call      ReadBuff                 ; naáten° novÇho obsahu bufferu
         pushf
         call      InitMez                  ; inicializace mezn°kñ bufferu
         popf
         jnc       NormBuf9                 ; operace áten° OK

; ------ p©i chybà n†vrat obsahu bufferu

         mov       ax,ds:[EditONum]         ; pñvodn° poáet bajtñ v bufferu
         mov       ds:[EditNum],ax          ; n†vrat poátu bajtñ v bufferu
         call      PopBuff                  ; n†vrat obsahu bufferu z kopie

; ------ n†vrat ukazatelñ dat v bufferu

NormBuf8:call      PopAkt                   ; n†vrat ukazatelñ bufferu
         call      InitMez                  ; inicializace mezn°kñ dat
         stc                                ; p©°znak p©eru®en° operace

; ------ n†vrat registrñ

NormBuf9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NormBuff ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Obsluha editace dekadickÇho bufferu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        otev©en° poloëky - BAJT (AL=á°slo, DX=pozice na displeji, CL=dÇlka)
; -----------------------------------------------------------------------------

OpenDB   PROC      NEAR

         push      ax
         mov       ah,0
         call      OpenDW                   ; otev©en° poloëky - slovo
         pop       ax
         ret

OpenDB   ENDP

; -----------------------------------------------------------------------------
;        otev©en° poloëky - SLOVO (AX=á°slo, DX=pozice na displeji, CL=dÇlka)
; -----------------------------------------------------------------------------

OpenDW   PROC      NEAR

         push      bx
         xor       bx,bx
         call      OpenDD                   ; otev©en° poloëky - dvojslovo
         pop       bx
         ret

OpenDW   ENDP

; -----------------------------------------------------------------------------
;        otev©en° poloëky - DVOJSLOVO (BX:AX=á°slo, DX=pozice, CL=dÇlka)
; -----------------------------------------------------------------------------

OpenDD   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       byte ptr ds:[KurzPol],0  ; kurzor v poloëce
         and       byte ptr ds:[Param2],not bit3 ; p©°znak, ëe nen° editace
         mov       ds:[EditBDel],cl         ; dÇlka bufferu
;         mov       ds:[EditBPoz],dx         ; pozice k zobrazen° poloëky
;         push      ax
;         mov       al,80
;         mul       dh                       ; p©epoáet ©†dku na pozice
;         add       al,dl                    ; p©iáten° pozice na ©†dku
;         adc       ah,0
;         shl       ax,1                     ; p©evod pozice na offset ve VRAM
;         mov       ds:[EditBAdr],ax         ; adresa k zobrazen° poloëky ve VRAM
;         pop       ax
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,10                    ; z†klad á°selnÇ soustavy
         mov       ch,0                     ; CX = dÇlka bufferu

; ------ vymaz†n° bufferu

         push      ax
         mov       di,offset EditBuf        ; editaán° buffer
         inc       cx                       ; dÇlka bufferu + 1
         mov       al," "                   ; mazac° znak
         cld
         rep       stosb                    ; vymaz†n° bufferu
         pop       ax

; ------ dek¢dov†n° á°sla BX:AX (zde je CX=0 a CLD)

OpenDD2: xchg      ax,bx                    ; BX <- á°slo LOW, AX <- á°slo HIGH
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° á°sla HIGH (v DX zbytek)
         xchg      ax,bx                    ; AX <- á°slo LOW, BX <- á°slo HIGH
         div       si                       ; vydàlen° á°sla LOW

; ------ uloëen° á°sla do z†sobn°ku

         add       dl,"0"                   ; korekce na á°slici
         push      dx                       ; uloëen° á°slice do z†sobn°ku
         inc       cx                       ; zvò®en° á°taáe á°slic
         mov       dx,ax                    ; novÇ á°slo LOW
         or        dx,bx                    ; je vòsledek jië = 0 ?
         jnz       OpenDD2                  ; nen° = 0, dal®° á°slice

; ------ uloëen° á°sla do bufferu

         mov       di,offset EditBuf        ; editaán° buffer
         mov       ds:[EditBNum],cl         ; poáet platnòch znakñ v bufferu
OpenDD3: pop       ax                       ; n†vrat á°slice ze z†sobn°ku
         stosb                              ; uloëen° á°slice do bufferu
         loop      OpenDD3                  ; uloëen° dal®° á°slice

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenDD   ENDP

; -----------------------------------------------------------------------------
;        poskytnut° á°sla BYTE (AH=omezen°, AL=á°slo)
; -----------------------------------------------------------------------------

GetDB0:  mov       ah,255

GetDB    PROC      NEAR

         push      cx
         mov       cl,ah                    ; omezen° á°sla
         mov       ch,0                     ; omezen° max. 255
         call      GetDW                    ; poskytnut° á°sla WORD
         mov       ah,cl
         pop       cx
         ret

GetDB    ENDP

; -----------------------------------------------------------------------------
;        poskytnut° á°sla WORD (CX=omezen°, AX=á°slo)
; -----------------------------------------------------------------------------

GetDW    PROC      NEAR

         push      bx
         push      dx
         xor       bx,bx                    ; omezen° HIGH <- 0 (max. 65535)
         call      GetDD                    ; poskytnut° á°sla DWORD
         pop       dx
         pop       bx
         ret

GetDW    ENDP

; -----------------------------------------------------------------------------
;        poskytnut° á°sla z editaán°ho bufferu (BX:CX=omezen°, -> DX:AX=á°slo)
; -----------------------------------------------------------------------------

GetDD    PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di

; ------ p©°prava registrñ

         xor       cx,cx                    ; st©adaá LOW
         xor       bx,bx                    ; st©adaá HIGH
         mov       di,10                    ; á°seln† soustava
         mov       si,offset EditBuf        ; editaán° buffer
         cld

; ------ naáten° jednoho znaku

GetDD2:  lodsb                              ; naáten° jednoho znaku
         sub       al,"0"                   ; korekce na á°slo
         jc        GetDD7                   ; nen° platn† á°slice
         cmp       al,9
         ja        GetDD7                   ; nen° platn† á°slice
         mov       ah,0                     ; AX = nov† á°slice

; ------ vyn†soben° st©adaáe 10x

         xchg      ax,bx                    ; AX <- st©adaá HIGH, BX <- á°slo
         mul       di                       ; vyn†soben° st©adaáe HIGH
         or        dx,dx                    ; p©eteáen° ?
         jnz       GetDD6                   ; p©eteáen°
         xchg      ax,cx                    ; AX <- st©ad.LOW, CX <- st©ad.HIGH
         mul       di                       ; vyn†soben° st©adaáe LOW

; ------ p©iáten° naátenÇho á°sla

         add       ax,bx                    ; p©iáten° á°sla ke st©adaái LOW
         adc       dx,cx                    ; p©iáten° st©adaáe HIGH
         jc        GetDD6                   ; p©eteáen°
         xchg      ax,cx                    ; CX <- st©†danÇ á°slo LOW
         mov       bx,dx                    ; BX <- st©†danÇ á°slo HIGH
         jmp       short GetDD2             ; dal®° á°slice

; ------ p©eteáen° - omezen° á°sla

GetDD6:  mov       cx,-1                    ; maxim†ln° á°slo LOW
         mov       bx,cx                    ; maxim†ln° á°slo HIGH

; ------ n†vrat registrñ

GetDD7:  mov       ax,cx                    ; naátenÇ á°slo LOW
         mov       dx,bx                    ; naátenÇ á°slo HIGH
         pop       di
         pop       si
         pop       cx
         pop       bx

; ------ omezen° rozsahu á°sla

         cmp       dx,bx                    ; porovn†n° HIGH
         jne       GetDD8                   ; nen° shoda HIGH
         cmp       ax,cx                    ; porovn†n° LOW
GetDD8:  jbe       GetDD9                   ; á°slo je OK
         mov       ax,cx
         mov       dx,bx                    ; omezen° á°sla
GetDD9:  ret

GetDD    ENDP

; -----------------------------------------------------------------------------
;        zobrazen° editovanÇho bufferu (barva AH, adresa ES:DI)
; -----------------------------------------------------------------------------

DispDB   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
;         push      di
         push      ds
;         push      es

; ------ adresa ve videopamàti

         push      cs
         pop       ds
;         mov       di,ds:[EditBAdr]         ; adresa k zobrazen° poloëky
;         mov       es,ds:[SegmVRAM]         ; segment videopamàti

; ------ dek¢dov†n° poloëky

         mov       ch,0
         mov       cl,ds:[EditBDel]         ; dÇlka editaán°ho bufferu
         jcxz      DispDB4                  ; nen° poloëka
         mov       si,offset EditBuf        ; editaán° buffer
         cld
DispDB2: lodsb
         stosw
         loop      DispDB2

; ------ n†vrat registrñ

DispDB4:; pop       es
         pop       ds
;         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DispDB   ENDP

; -----------------------------------------------------------------------------
;        vloëen° znaku AL do editaán°ho bufferu na pozici kurzoru
; -----------------------------------------------------------------------------

InsBEdit PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       di,offset EditBuf        ; editaán° buffer
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ch,0
         mov       cl,ds:[EditBDel]         ; dÇlka editaán°ho bufferu

; ------ vymaz†n° bufferu p©i zah†jen° editace

         test      byte ptr ds:[Param2],bit3 ; byla editace jië zah†jena ?
         jnz       InsBEdi2                 ; editace byla jië zah†jena
         cld
         push      ax
         mov       al," "                   ; mazac° znak mezery
         rep       stosb                    ; vymaz†n° bufferu
         pop       ax
         mov       byte ptr ds:[EditBuf],al ; uloëen° novÇho znaku
         mov       byte ptr ds:[EditBNum],1 ; 1 znak v bufferu
         mov       byte ptr ds:[KurzPol],cl ; kurzor = 0
         or        byte ptr ds:[Param2],bit3 ; p©°znak zah†jen° editace
         jmp       short InsBEdi5

; ------ vloëen° znaku do bufferu

InsBEdi2:cmp       cl,ds:[EditBNum]         ; je buffer jië plnò ?
         jbe       InsBEdi3                 ; buffer je jië plnò
         inc       byte ptr ds:[EditBNum]   ; jinak zvò®en° poátu platnòch znakñ
InsBEdi3:dec       cx                       ; dÇlka editaán°ho bufferu - 1
         add       di,cx                    ; konec bufferu
         mov       si,di                    ; konec bufferu
         dec       si                       ; konec bufferu - 1
         sub       cl,ds:[KurzPol]          ; poáet zbylòch znakñ k odsunu
         std                                ; smàr dolñ
         rep       movsb                    ; odsun zbytku dat
         stosb                              ; uloëen° novÇho znaku
         cld                                ; nastaven° na standardn° hodnotu

; ------ n†vrat registrñ

InsBEdi5:pop       es
         pop       di
         pop       si
         pop       cx
         ret

InsBEdit ENDP

; -----------------------------------------------------------------------------
;        zru®en° znaku z editaán°ho bufferu (na pozici kurzoru)
; -----------------------------------------------------------------------------

DelBEdit PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         or        byte ptr ds:[Param2],bit3 ; p©°znak zah†jen° editace
         mov       cl,ds:[KurzPol]          ; kurzor
         cmp       cl,ds:[EditBNum]         ; je kurzor za textem ?
         jae       DelBEdi5                 ; kurzor je za textem
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ch,0
         mov       di,offset EditBuf        ; editaán° buffer
         add       di,cx                    ; adresa kurzoru

; ------ zru®en° znaku z bufferu

         mov       cl,ds:[EditBDel]         ; dÇlka editaán°ho bufferu
         dec       byte ptr ds:[EditBNum]   ; sn°ëen° poátu platnòch znakñ
         dec       cx                       ; dÇlka editaán°ho bufferu - 1
         sub       cl,ds:[KurzPol]          ; poáet zbylòch znakñ k p©°sunu
         mov       si,di                    ; adresa kurzoru
         inc       si                       ; znak za kurzorem
         cld                                ; smàr nahoru
         rep       movsb                    ; p©°sun zbytku dat
         mov       byte ptr es:[di]," "     ; koncov† mezera

; ------ n†vrat registrñ

DelBEdi5:pop       es
         pop       di
         pop       si
         pop       cx
         ret

DelBEdit ENDP

; -----------------------------------------------------------------------------
;        test, zda je AX zaá†tek slova (CY=nen°)
; -----------------------------------------------------------------------------

TestWord PROC      NEAR

         push      ax
         push      bx

         mov       bx,offset TabWrdCh       ; tabulka pro porovn†n° znakñ
         xlat                               ; hodnota prvn°ho znaku
         xchg      ah,al                    ; AH <- prvn° znak
         xlat                               ; hodnota druhÇho znaku
         dec       ax                       ; druhò znak - 1 (mus° bòt vàt®°)
         cmp       al,ah                    ; porovn†n° hodnot znakñ

         pop       bx
         pop       ax
         ret

TestWord ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         Obsluha zobrazen° kurzoru
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Kurz     PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
;         sub       sp,24                    ; m°sto pro lok†ln° promànnÇ

; ------ relativn° adresa kurzoru od zaá†tku str†nky

         mov       ax,word ptr ds:[EditAkt] ; kurzor v objektu
         sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky

; ------ vàtven° podle m¢du zobrazen°

         mov       bx,ds:[DispMod]          ; m¢d zobrazen°
         test      bl,bit0                  ; HEX ?
         jz        Kurz11
         call      KurzH                    ; Zobrazen° Hex
         jmp       short KurzX

Kurz11:  test      bl,bit1                  ; Binar ?
         jz        Kurz1
         call      KurzI                    ; Zobrazen° Binar
         jmp       short KurzX

Kurz1:   test      bl,bit2                  ; BYTE ?
         jz        Kurz2
         call      KurzB                    ; Zobrazen° BYTE
         jmp       short KurzX

Kurz2:   test      bl,bit3                  ; WORD ?
         jz        Kurz3
         call      KurzW                    ; Zobrazen° WORD
         jmp       short KurzX

Kurz3:   test      bl,bit4                  ; TEXT ?
         jz        Kurz4
         call      KurzT                    ; Zobrazen° TEXT
         jmp       short KurzX

Kurz4:   test      bl,bit5                  ; ADRESèû ?
         jz        Kurz5
         call      KurzD                    ; Zobrazen° adres†©e
         jmp       short KurzX

Kurz5:   test      bl,bit6                  ; FAT ?
         jz        Kurz6
         call      KurzF                    ; Zobrazen° FAT
         jmp       short KurzX

Kurz6:   test      bl,bit7                  ; PARTITION ?
         jz        Kurz7
         call      KurzP                    ; Zobrazen° PARTITION
         jmp       short KurzX

Kurz7:   test      bx,bit8                  ; ASSEMBLER ?
         jz        Kurz8

;         mov       ax,cs:[KorAsm]           ; korekce adresy assembleru
;         sub       ax,word ptr cs:[KurzTop]
;         mov       ss:[bp-20],ax
         call      KurzA                    ; Zobrazen° ASSEMBLER
         jmp       short KurzX

Kurz8:   test      bx,bit9                  ; CMOS ?
         jz        Kurz9
         call      KurzC                    ; Zobrazen° CMOS
         jmp       short KurzX

Kurz9:

; ------ n†vrat registrñ

KurzX:   mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Kurz     ENDP


; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du HEX
; -----------------------------------------------------------------------------

KurzH    PROC      NEAR

; ------ p©epoáet na pozici a ©†dek

         mov       dl,al
         and       dl,0fh                   ; pozice relativnà
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       dh,al                    ; ©†dek relativnà

; ------ korekce pozice

         add       dh,3                     ; korekce á°sla ©†dku
         cmp       byte ptr ds:[EditPole],0 ; je editovanÇ pole HEX ?
         jne       KurzH1                   ; nen° editovanÇ pole HEX
         mov       al,dl                    ; pozice relativnà
         shl       al,1                     ; pozice * 2
         add       dl,al                    ; pozice * 3
         cmp       al,4*2
         jb        KurzH12
         add       dl,1
         cmp       al,8*2
         jb        KurzH12
         add       dl,2
         cmp       al,12*2
         jb        KurzH12
         add       dl,1
KurzH12: add       dl,ds:[KurzPol]          ; p©iáten° offsetu v poloëce
         add       dl,11-63                 ; p©iáten° poá†teán° pozice
KurzH1:  add       dl,63                    ; korekce pro ASCII pole

; ------ nastaven° kurzoru

         call      SetKurz                  ; nastaven° kurzoru
         ret

KurzH    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du BINAR
; -----------------------------------------------------------------------------

KurzI    PROC      NEAR

; ------ p©epoáet na pozici a ©†dek

         mov       dl,al
         and       dl,3                     ; pozice relativnà
         shr       ax,1
         shr       ax,1
         mov       dh,al                    ; ©†dek relativnà
         add       dh,3                     ; korekce á°sla ©†dku

; ------ korekce - bin†rn° pole

         cmp       byte ptr ds:[EditPole],0 ; je editovanÇ pole HEX ?
         jne       KurzI6                   ; nen° editovanÇ pole HEX
         mov       al,dl
         shl       al,1
         shl       al,1
         shl       al,1
         add       dl,al                    ; pozice * 9
         add       dl,11
         jmp       short KurzI9

; ------ korekce - hexadecim†ln° pole

KurzI6:  cmp       byte ptr ds:[EditPole],1 ; je hexadecim†ln° pole ?
         jne       KurzI7                   ; nen° hexadecim†ln° pole
         mov       al,dl
         shl       dl,1
         add       dl,al                    ; pozice * 3
         add       dl,47
         jmp       short KurzI9

; ------ korekce - dekadickÇ pole

KurzI7:  cmp       byte ptr ds:[EditPole],2 ; je dekadickÇ pole ?
         jne       KurzI8                   ; nen° dekadickÇ pole
         shl       dl,1
         shl       dl,1                     ; pozice * 4
         add       dl,59-75                 ; poá†teán° pozice pole

; ------ korekce - ASCII pole

KurzI8:  add       dl,75                    ; korekce pro ASCII pole

; ------ nastaven° kurzoru

KurzI9:  add       dl,ds:[KurzPol]
         call      SetKurz                  ; nastaven° kurzoru
         ret

KurzI    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du BYTE
; -----------------------------------------------------------------------------

KurzB    PROC      NEAR

; ------ p©epoáet na pozici a ©†dek

         xor       dx,dx
         mov       cx,10                    ; poáet bajtñ na ©†dek
         div       cx                       ; vòpoáet pozice a ©†dku
         mov       dh,al                    ; ©†dek relativnà

; ------ korekce pozice

         add       dh,3                     ; korekce á°sla ©†dku
         cmp       byte ptr ds:[EditPole],0 ; je editovanÇ pole DEK ?
         jne       KurzB1                   ; nen° editovanÇ pole DEK
         mov       al,dl
         shl       dl,1
         shl       dl,1                     ; pozice * 4
         add       dl,al                    ; pozice * 5
         cmp       al,5
         jb        KurzB12
         add       dl,3
KurzB12: add       dl,ds:[KurzPol]          ; p©iáten° offsetu v poloëce
         add       dl,16-69                 ; p©iáten° poá†teán° pozice
KurzB1:  add       dl,69                    ; korekce pro ASCII pole

; ------ nastaven° kurzoru

         call      SetKurz                  ; nastaven° kurzoru
         ret

KurzB    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du WORD
; -----------------------------------------------------------------------------

KurzW    PROC      NEAR

         xor       dx,dx
         cmp       byte ptr ds:[EditPole],0 ; je editovanÇ pole DEK ?
         je        KurzW11                  ; je editovanÇ pole DEK

; ------ p©epoáet na pozici a ©†dek ASCII

         mov       cx,10                    ; poáet bajtñ na ©†dek
         div       cx                       ; vòpoáet pozice a ©†dku
         mov       dh,al                    ; ©†dek relativnà
         add       dl,69
         jmp       short KurzW3

; ------ p©epoáet na pozici a ©†dek

KurzW11: shr       ax,1                     ; poáet slov
         mov       cx,5                     ; poáet slov na ©†dek
         div       cx                       ; vòpoáet pozice a ©†dku
         mov       dh,al                    ; ©†dek relativnà

; ------ korekce pozice

         mov       al,10                    ; poáet pozic na poloëku
         mul       dl
         mov       dl,al                    ; pozice
KurzW12: add       dl,ds:[KurzPol]          ; p©iáten° offsetu v poloëce
         add       dl,18                    ; p©iáten° poá†teán° pozice

; ------ nastaven° kurzoru

KurzW3:  add       dh,3                     ; korekce á°sla ©†dku
         call      SetKurz                  ; nastaven° kurzoru
         ret

KurzW    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du TEXT
; -----------------------------------------------------------------------------

KurzT    PROC      NEAR

;         mov       dx,ds:[EditBPoz]
         call      SetKurz
         ret

KurzT    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du ADRESèû
; -----------------------------------------------------------------------------

KurzD    PROC      NEAR

; ------ vòpoáet relativn° pozice a ©†dku

         mov       cx,20h                   ; poáet bajtñ na ©†dek
         xor       dx,dx
         div       cx                       ; vòpoáet ©†dku a pozice
         mov       dh,al                    ; ©†dek
         add       dh,3                     ; ©†dek

; ------ korekce pozice

         mov       bl,dl                    ; pozice relativnà
         mov       bh,0
         mov       dl,ds:[bx+KorAdrK]       ; korekce pozice kurzoru
         mov       ch,ds:[EditPole]         ; editovanÇ pole

; ------ datum a áas

         cmp       dl,37                    ; datum ?
         je        KurzD1                   ; datum
         cmp       dl,48                    ; áas ?
         jne       KurzD2                   ; nen° áas
KurzD1:  cmp       ch,0                     ; je prvn° pole ?
         je        KurzD8                   ; je prvn° pole
         add       dl,3                     ; korekce pro druhÇ pole
         cmp       ch,1                     ; je druhÇ pole ?
         je        KurzD8                   ; je druhÇ pole
         add       dl,3                     ; korekce pro t©et° pole
         jmp       short KurzD8

; ------ atributy

KurzD2:  cmp       dl,57                    ; jsou atributy ?
         jne       KurzD3                   ; nejsou atributy
         add       dl,ch                    ; korekce pozice o poloëku
         add       dl,ch

KurzD3:

; ------ nastaven° pozice kurzoru

KurzD8:  add       dl,ds:[KurzPol]          ; p©iáten° kurzoru
         call      SetKurz
KurzD9:  ret

KurzD    ENDP

; -----------------------------------------------------------------------------
;        poskytnut° parametrñ aktu†ln° poloëky FAT
; -----------------------------------------------------------------------------
; VùSTUP: DH=©†dek na obrazovce
;         DL=offset kurzoru na ©†dku
;         CH=á°slo poloëky
;         CL=poáet bajtñ na ©†dek
;         CY=chybn† adresa (vyëaduje sn°ëen° adresy o 1)
; -----------------------------------------------------------------------------

GetFPol  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ offset od zaá†tku str†nky

         mov       ax,word ptr ds:[EditAkt] ; kurzor v objektu
         sub       ax,word ptr ds:[EditTop] ; offset od poá†tku str†nky

; ------ vòpoáet ©†dku a offsetu kurzoru na ©†dku

         mov       bh,ds:[Param2]
         mov       cx,20                    ; poáet bajtñ na ©†dek FAT 16
         test      bh,bit0                  ; je FAT 16 ?
         jnz       GetFPol1                 ; je FAT 16
         mov       cl,15                    ; poáet bajtñ na ©†dek FAT 12
GetFPol1:xor       dx,dx
         div       cx                       ; vòpoáet ©†dku a pozice
         mov       dh,al                    ; DH=©†dek, DL=offset
         add       dh,3                     ; ©†dek na obrazovce

; ------ vòpoáet á°sla poloëky FAT

         mov       ch,dl                    ; offset poloëky na ©†dku
         test      bh,bit0                  ; je FAT 16 ?
         jnz       GetFPol3                 ; je FAT 16
         mov       bl,dl                    ; offset poloëky na ©†dku
         mov       bh,0
         mov       ch,ds:[bx+KorFatP]       ; á°slo poloëky FAT
GetFPol3:shr       ch,1                     ; CY=chybn† adresa

; ------ n†vrat registrñ

         pop       bx
         pop       ax
         ret

GetFPol  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du FAT
; -----------------------------------------------------------------------------

KurzF    PROC      NEAR

;; ------ vòpoáet ©†dku a offsetu kurzoru na ©†dku
;
;         mov       cx,20                    ; poáet bajtñ na ©†dek FAT 16
;         test      byte ptr ds:[Param2],bit0 ; je FAT 16 ?
;         jnz       KurzF1                   ; je FAT 16
;         mov       cl,15                    ; poáet bajtñ na ©†dek FAT 12
;KurzF1:  xor       dx,dx
;         div       cx                       ; vòpoáet ©†dku a pozice
;         mov       dh,al                    ; ©†dek
;
;; ------ vòpoáet á°sla poloëky
;
;         test      byte ptr ds:[Param2],bit0 ; je FAT 16 ?
;         jnz       KurzF2                   ; je FAT 16
;         mov       al,dl                    ; offset poloëky
;         mov       ah,0
;         mov       cl,3
;         div       cl
;         mov       dl,al                    ; á°slo poloëky/2
;         shl       dl,1                     ; á°slo poloëky
;         cmp       ah,0
;         je        KurzF3
;         inc       dx
;         shl       dl,1
;KurzF2:  shr       dl,1                     ; á°slo poloëky

         call      GetFPol                  ; poskytnut° parametrñ poloëky FAT

; ------ korekce pozice

KurzF3:  mov       al,7                     ; poáet pozic na poloëku
         mul       ch                       ; offset poloëky
         mov       dl,al                    ; offset poloëky
         cmp       dl,5*7
         jb        Kurz6F2
         add       dl,2                     ; korekce pro prost©edek
Kurz6F2: add       dl,8

; ------ nastaven° pozice kurzoru

         add       dl,ds:[KurzPol]          ; p©iáten° kurzoru
;         add       dh,3                     ; ©†dek
         call      SetKurz
         ret

KurzF    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du PARTITION
; -----------------------------------------------------------------------------

KurzP    PROC      NEAR

         ret

KurzP    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du ASSEMBLER
; -----------------------------------------------------------------------------

KurzA    PROC      NEAR

         ret

KurzA    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° v m¢du CMOS
; -----------------------------------------------------------------------------

KurzC    PROC      NEAR

         ret

KurzC    ENDP

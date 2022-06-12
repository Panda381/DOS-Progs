
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

X        EQU       16                       ; posun m¢du o tetr du

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

; ------ detekce videokarty

Start:   call      DetCard                  ; detekce videokarty
         mov       al,cs:[Card]
         mov       byte ptr cs:[CardTyp],al ; pracovn¡ karta - k up©esnˆn¡
         call      DetVGA                   ; detekce videokarty VGA
         mov       ax,cs:[CardTyp]
         mov       cs:[AktCard],ax          ; ‡¡slo aktivn¡ karty

; ------ p©¡prava inicializa‡n¡ho videom¢du

         mov       ah,0fh
         int       10h                      ; poskytnut¡ videom¢du
         and       al,7fh
         cmp       al,7
         je        Start1
         cmp       al,2
         je        Start1
         mov       al,3
Start1:  mov       cs:[InitMod],al          ; inicializa‡n¡ videom¢d
         mov       byte ptr cs:[ModTAkt],al

; ------ inicializace videom¢du

Start2:  mov       ax,word ptr cs:[InitMod] ; inicializa‡n¡ videom¢d
         call      Int10P                   ; inicializace videom¢du

; ------ inicializace parametr–

Start22: call      GetPar
         cmp       word ptr cs:[SegmVRAM],0
         je        Start21
         or        byte ptr cs:[Params],bit0 ; p©¡znak vlastn¡ obsluhy displeje

; ------ zobrazen¡ r mu hlavn¡ho menu

Start21: call      Disp1Ram

; ------ zobrazen¡ nadpisu hlavn¡ho menu

         mov       dh,1                     ; © dek
         mov       si,offset TestTxt
         mov       ah,0eh
         call      DispCent                 ; zobrazen¡ nadpisu

         mov       ah,7
         mov       si,offset LicTxt
         call      DispCent                 ; zobrazen¡ Copyright

         mov       si,offset VerTxt
         call      DispCent                 ; zobrazen¡ verze

; ------ zobrazen¡ typu videokarty

         inc       dh

         mov       ax,cs:[CardTyp]          ; typ detekovan‚ videokarty
         call      GetCard                  ; poskytnut¡ adresy definice karty
         mov       al,cs:[si]               ; d‚lka textu
         push      si
         mov       si,offset CardTxt
         add       al,cs:[si]               ; celkov  d‚lka textu
         mov       dl,cs:[Pozic]            ; po‡et pozic na © dek
         sub       dl,al                    ; zbytek na okraje
         shr       dl,1                     ; po‡ te‡n¡ pozice
         mov       ah,7                     ; bˆ‘n  barva
         call      DispStr                  ; zobrazen¡ prvn¡ ‡ sti textu
         pop       si
         mov       ah,0fh
         call      DispStr                  ; zobrazen¡ druh‚ ‡ sti textu

; ------ p©¡prava k zobrazen¡ nov‚ karty

DispNew: mov       ax,cs:[AktCard]          ; aktivn¡ karta
         call      GetCard                  ; poskytnut¡ adresy karty
         mov       cs:[ModTTab],si          ; adresa definice karty
         mov       ah,0
         mov       al,cs:[si]               ; d‚lka textu n zvu karty
         inc       si                       ; za‡ tek textu n zvu karty
         add       si,ax                    ; adresa vzorku karty
         mov       al,cs:[si]               ; d‚lka vzorku karty
         inc       si                       ; za‡ tek textu vzorku karty
         add       si,ax                    ; za‡ tek polo‘ek
         mov       al,cs:[si]               ; celkov˜ po‡et polo‘ek
         inc       si                       ; adresa p©ednastaven˜ch polo‘ek
         inc       si                       ; adresa za‡ tku polo‘ek
         mov       cs:[ModTTab0],si         ; adresa za‡ tku polo‘ek karty
         mov       cs:[ModTNum],ax          ; celkov˜ po‡et polo‘ek karty
         cmp       ax,cs:[ModTAkt]          ; je kurzor OK ?
         ja        DispNew1                 ; kurzor je OK
         dec       ax
         mov       cs:[ModTAkt],ax          ; omezen¡ kurzoru

DispNew1:mov       dx,7*256+59
         mov       cl,20
         mov       ah,11
         call      DispSpc
         sub       dl,10
         mov       si,cs:[ModTTab]
         mov       ch,0
         mov       cl,cs:[si]
         inc       si
         cmp       cl,20
         jb        DispNew2
         mov       cl,20
DispNew2:mov       al,cl
         shr       al,1
         sub       dl,al
DispNew3:mov       al,cs:[si]
         inc       si
         call      Disp1Chr
         loop      DispNew3

; ------ zobrazen¡ v¨ech polo‘ek

DispAll: mov       bx,cs:[ModTTop]          ; po‡ te‡n¡ polo‘ka
         mov       cx,cs:[ModTDisp]         ; po‡et zobrazen˜ch polo‘ek
         mov       ax,cs:[ModTAkt]          ; aktivn¡ polo‘ka
         cmp       ax,bx                    ; je kurzor pod ?
         jae       DispAll1                 ; kurzor je OK
         mov       bx,ax                    ; omezen¡ po‡ tku
DispAll1:dec       cx
         sub       ax,cx                    ; minim ln¡ po‡ tek
         jnc       DispAll2
         xor       ax,ax
DispAll2:cmp       bx,ax
         jae       DispAll3
         mov       bx,ax
DispAll3:inc       cx
         mov       cs:[ModTTop],bx          ; opraven˜ po‡ tek
DispAll5:call      DispRad                  ; zobrazen¡ polo‘ky BX
         inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         loop      DispAll5                 ; zobrazen¡ dal¨¡ polo‘ky

; ------ vstup znaku z kl vesnice

Vstup:   call      KurzOff                  ; vypnut¡ kurzoru
         mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice

; ------ p©¡prava registr–

         mov       bx,cs:[ModTAkt]          ; aktivn¡ polo‘ka
         mov       cx,cs:[ModTDisp]         ; po‡et zobrazen˜ch polo‘ek
         dec       cx
         mov       dx,cs:[ModTNum]          ; celkov˜ po‡et polo‘ek

; ------ konec programu Esc nebo Ctrl-Break

         cmp       al,27
         je        Vstup100
         or        ax,ax
         jnz       Vstup101
Vstup100:jmp       Konec

; ------ kurzor dol–

Vstup101:cmp       ax,5000h
         jne       Vstup2
         inc       bx
Vstup102:cmp       bx,dx
         jb        Vstup103
         mov       bx,dx
         dec       bx
Vstup103:cmp       bx,cs:[ModTAkt]
         je        Vstup                    ; nen¡ zmˆna
         mov       cs:[ModTAkt],bx
         jmp       short DispAll            ; nov‚ zobrazen¡

; ------ kurzor nahoru

Vstup2:  cmp       ax,4800h
         jne       Vstup3
         or        bx,bx
         jz        Vstup
         dec       bx
         jmp       short Vstup102

; ------ prvn¡ polo‘ka

Vstup3:  cmp       ax,4700h
         jne       Vstup4
Vstup32: xor       bx,bx
         jmp       short Vstup102

; ------ posledn¡ polo‘ka

Vstup4:  cmp       ax,4f00h
         jne       Vstup5
         mov       bx,dx
         jmp       short Vstup102

; ------ str nka nahoru

Vstup5:  cmp       ax,4900h
         jne       Vstup6
         sub       bx,cx
         jc        Vstup32
         jmp       short Vstup102

; ------ ENTER

Vstup6:  cmp       al,13
         je        VstupE                   ; ENTER

; ------ str nka dol–

Vstup7:  cmp       ax,5100h
         jne       Vstup8
         add       bx,cx
         jmp       short Vstup102

; ------ ni‘¨¡ karta

Vstup8:  cmp       ax,4b00h
         jne       Vstup9
         mov       ax,cs:[AktCard]          ; aktivn¡ karta
         or        ax,ax
         jz        Vstup92                  ; je ji‘ prvn¡ karta
         dec       ax
Vstup82: mov       cs:[AktCard],ax          ; nov  aktivn¡ karta
         jmp       DispNew                  ; nov  aktivn¡ karta

; ------ vy¨¨¡ karta

Vstup9:  cmp       ax,4d00h
         jne       VstupA
         mov       ax,cs:[AktCard]
         inc       ax
         cmp       ax,cs:[MaxCard]
         jb        Vstup82
Vstup92: jmp       Vstup

; ------ detekce videom¢d–

VstupA:  cmp       ax,3e00h                 ; F4
         jne       Vstup92
         jmp       Detect

; ------ vymaz n¡ obrazovky

Konec:   mov       ax,word ptr cs:[InitMod] ; inicializa‡n¡ videom¢d
         int       10h                      ; inicializace videom¢du

; ------ konec programu

         int       20h

; -----------------------------------------------------------------------------
;        volba m¢du
; -----------------------------------------------------------------------------
;þ
; ------ ‡¡slo videom¢du

VstupE:  mov       bx,cs:[ModTAkt]          ; aktivn¡ polo‘ka
         call      GetPol                   ; poskytnut¡ polo‘ky
         mov       al,cs:[bx]               ; videom¢d

; ------ nastaven¡ videom¢du

         mov       bx,800                   ; rozli¨en¡ X
         mov       cx,600                   ; rozli¨en¡ Y
         mov       dx,100h                  ; po‡et barev

         mov       ah,0
         call      Int10A                   ; nastaven¡ videom¢du

         push      ax
         mov       ah,0fh
         call      Int10P
         mov       dl,al
         pop       ax
         cmp       al,dl
         je        VstupE10
         jmp       Start22

VstupE10:

         call      TestKey
         jnz       VstupE89

; ------ detekce parametr– videom¢du (nastav¡ obsluhu BIOS)

         call      GetPar                   ; detekce parametr– videom¢du

         call      TestKey
         jnz       VstupE89

; ------ zobrazen¡ r mu

;         mov       al,cs:[AktMod]
;         cmp       al,cs:[InitMod]
;         jne       VstupE12
;         cmp       word ptr cs:[SegmVRAM],0
;         je        VstupE12
;         or        byte ptr cs:[Params],bit0 ; p©¡znak vlastn¡ obsluhy displeje
;VstupE12:
         call      Disp2Ram                 ; zobrazen¡ r mu

         call      TestKey
VstupE89:jnz       VstupE88

; ------ p©¡prava k zobrazen¡ stavu

         mov       dh,1
         mov       dl,cs:[Pozic]
         shr       dl,1
         sub       dl,14

; ------ zobrazen¡ videom¢du

         mov       di,offset ModTxtT
         mov       ch,0
         mov       cl,cs:[ModVRAM]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       di,cx
         mov       si,offset TModMod
         mov       cl,cs:[AktMod]
         mov       ch,0
         mov       al,0
         call      DispPar

; ------ zobrazen¡ horizont ln¡ho rozli¨en¡

         mov       si,offset TModHor        ; text - horizont ln¡ rozli¨en¡
         mov       al,0
         mov       cl,cs:[Pozic]            ; po‡et pozic na © dek
         mov       di,offset TModHor1       ; text "pozic"
         cmp       byte ptr cs:[GrafMod],0  ; je grafick˜ m¢d ?
         je        VstupE2                  ; nen¡ grafick˜ m¢d
         mov       di,offset TModHor2       ; text "bod–"
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; po‡et bod–
VstupE2: call      DispPar

; ------ zobrazen¡ vertik ln¡ho rozli¨en¡

         mov       si,offset TModVer
         mov       al,0
         mov       cx,cs:[Vertik]
         mov       di,offset TModVer1       ; text "radku"
         cmp       byte ptr cs:[GrafMod],0  ; je grafick˜ m¢d ?
         je        VstupE3                  ; nen¡ grafick˜ m¢d
         mov       di,offset TModVer2       ; text "linek"
VstupE3: call      DispPar

; ------ zobrazen¡ po‡tu barev

         call      TestKey
VstupE88:jnz       VstupE8

         mov       si,offset TModBar
         push      dx
         mov       ah,7
         call      DispStr

         mov       ah,0fh
         mov       cx,cs:[Barev]            ; po‡et barev
         cmp       cx,1
         ja        VstupE4

         mov       si,offset TModBar1
         call      DispStr
         jmp       short VstupE5

VstupE4: call      DispWord
VstupE5: pop       dx
         inc       dh

; ------ zobrazen¡ po‡tu videostr nek

         mov       si,offset TModPag
         mov       di,offset TModNul
         mov       ch,0
         mov       cl,cs:[NumPages]         ; po‡et videostr nek
         call      DispPar                  ; zobrazen¡ parametru

; ------ zobrazen¡ adresy videopamˆti

         push      dx
         mov       si,offset TModAdr
         mov       ah,7
         call      DispStr
         mov       al,byte ptr cs:[SegmVRAM+1]
         mov       si,offset Adr1Txt
         cmp       al,0b8h
         je        VstupE61
         mov       si,offset Adr2Txt
         cmp       al,0b0h
         je        VstupE61
         mov       si,offset Adr3txt
         cmp       al,0a0h
         je        VstupE61
         mov       si,offset Adr4Txt
VstupE61:mov       ah,0fh
         call      DispStr
         pop       dx
         inc       dh

; ------ zobrazen¡ znakov˜ch font–

         call      TestKey
         jnz       VstupE8

         call      DispFont


; ------ zobrazen¡ barev (od aktu ln¡ho © dku DH)

         call      TestKey
         jnz       VstupE8

         call      DispCol

         call      KurzOff                  ; vypnut¡ kurzoru
VstupE8: mov       ah,0
         int       16h
         jmp       Start2

; -----------------------------------------------------------------------------
;        test stisku kl vesy (NZ=je)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

         push      ax
         mov       ah,1
         int       16h
         pop       ax
         ret

TestKey  ENDP

; -----------------------------------------------------------------------------
;   zobrazen¡ ‡¡seln‚ho parametru CX (SI=text 1, AL=pozic, DI=text 2)
; -----------------------------------------------------------------------------

DispPar  PROC      NEAR

         push      dx
         mov       ah,7
         call      DispStr
         mov       ah,0fh
         call      DispWord
         mov       si,di
         call      DispStr
         pop       dx
         inc       dh
         ret

DispPar  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znakov˜ch font–
; -----------------------------------------------------------------------------

DispFont PROC      NEAR

; ------ v˜po‡et pozice

         mov       dl,cs:[Pozic]
         cmp       dl,38
         jnc       DispFn1
DispFn0: ret                                ; mal˜ po‡et pozic

DispFn1: shr       dl,1                     ; st©ed
         sub       dl,16+2

; ------ v˜po‡et © dku

         mov       dh,cs:[Radku]
         cmp       dh,18
         jb        DispFn0                  ; mal˜ po‡et © dk–
         shr       dh,1
         sub       dh,4
         mov       al,dh
         shr       al,1
         sub       al,4
         jb        DispFn2
         sub       dh,al

; ------ zobrazen¡ horn¡ho okraje

DispFn2: push      dx
         mov       ah,0fh
         mov       al,"É"
         call      Disp1Chr
         mov       al,"Í"
         mov       cl,34
         call      DispMChr
         mov       al,"»"
         call      Disp1Chr
         pop       dx
         inc       dh

         call      TestKey
         jnz       DispFn0

; ------ zobrazen¡ st©edn¡ch © dk–

         mov       bl,0                     ; ukazatel znaku
DispFn3: push      dx
         mov       ah,0fh
         mov       al,"º"
         call      Disp1Chr
         mov       al," "
         call      Disp1Chr
         mov       ah,7
DispFn4: mov       al,bl
         call      Disp1Chr
         inc       bx
         test      bl,1fh
         jnz       DispFn4
         mov       ah,0fh
         mov       al," "
         call      Disp1Chr
         mov       al,"º"
         call      Disp1Chr
         pop       dx
         inc       dh
         cmp       bl,0
         jne       DispFn3

         call      TestKey
         jnz       DispFn9

; ------ zobrazen¡ spodn¡ho okraje

         push      dx
         mov       ah,0fh
         mov       al,"È"
         call      Disp1Chr
         mov       al,"Í"
         call      Disp1Chr
         mov       al," "
         mov       cl,32
         call      DispMChr
         mov       al,"Í"
         call      Disp1Chr
         mov       al,"¼"
         call      Disp1Chr
         pop       dx

         call      TestKey
         jnz       DispFn9

; ------ zobrazeni vzorku 1 v ramu

         inc       dx
         inc       dx
         mov       ax,"0"
DispFn5: call      Disp1Chr
         inc       ax
         cmp       al,"9"+1
         jne       DispFn6
         mov       al,"A"
DispFn6: inc       ah
         cmp       ah,16
         jb        DispFn5

; ------ zobrazeni vzorku v ramu

         mov       ax,"0"
DispFn7: call      Disp1Chr
         inc       ax
         cmp       al,"9"+1
         jne       DispFn8
         mov       al,"A"
DispFn8: add       ah,10h
         jnb       DispFn7

DispFn9: ret

DispFont ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ barev (od © dku DH)
; -----------------------------------------------------------------------------

DispCol  PROC      NEAR

; ------ ur‡en¡ v˜¨ky

         inc       dh
         mov       ch,cs:[Radku]            ; po‡et © dk–
         sub       ch,2
         sub       ch,dh
         ja        DispCol0
         jmp       DispCol9                 ; zbyl mal˜ po‡et © dk–

DispCol0:mov       al,ch
         shr       al,1
         sub       al,4
         jb        DispCl02
         add       dh,al
         sub       ch,al

; ------ zobrazen¡ oddˆlovac¡ ‡ ry

DispCl02:mov       dl,1
         mov       cl,cs:[Pozic]
         sub       cl,2
         mov       al,"Ä"
         mov       ah,0fh
         call      DispMChr
         inc       dh

; ------ zobrazen¡ v monochrom. a ‡ernob¡l‚m re‘imu

         mov       ax,cs:[Barev]            ; po‡et barev
         cmp       ax,2
         ja        DispCol2

DispCol1:mov       ax,word ptr cs:[Pozic]
         dec       ax
         dec       ax
         mov       cl,6
         div       cl
         mov       cl,al
         mov       ah,7
         mov       al," "
         mov       dl,1
         call      DispMChr
         mov       al,"°"
         call      DispMChr
         mov       al,"±"
         call      DispMChr
         mov       al,"²"
         call      DispMChr
         mov       al,"Û"
         call      DispMChr
         mov       ah,0fh
         call      DispMChr
         mov       cl,cs:[Pozic]
         dec       cx
         sub       cl,dl
         call      DispMChr

         call      TestKey
         jnz       DispCl14

         inc       dh
         dec       ch
         jnz       DispCol1
DispCl14:jmp       short DispCol9

; ------ zobrazen¡ v re‘imu 4 a 16 barev

DispCol2:or        ah,ah
         jnz       DispCol3                 ; je re‘im 256 barev

         xchg      ax,bx                    ; po‡et barev
         mov       ax,word ptr cs:[Pozic]
         dec       ax
         dec       ax
         div       bl                       ; po‡et pozic na barvu
         mov       cl,al                    ; po‡et pozic na barvu
         shr       ah,1
         inc       ah
         mov       dl,ah                    ; po‡ te‡n¡ pozice k zobrazen¡

DispCl22:push      dx
         mov       ah,0                     ; barva
         mov       al,"Û"
DispCl23:call      DispMChr
         inc       ah                       ; zv˜¨en¡ ‡¡sla barvy
         cmp       ah,bl
         jb        DispCl23
         pop       dx

         call      TestKey
         jnz       DispCl14

         inc       dh
         dec       ch
         jnz       DispCl22
         jmp       DispCol9

; ------ zobrazen¡ v re‘imu 256 barev

DispCol3:

         inc       ch
         mov       al,cs:[Pozic]
         dec       ax
         dec       ax
         mul       ch                       ; celkov˜ po‡et pozic
         dec       ch

         cmp       ah,0
         jne       DispCl32
         mov       ah,1
         dec       dh
         inc       ch
DispCl32:mov       cl,ah                    ; po‡et pozic na znak


         mov       ah,0
         mov       al,"Û"
         mov       bl,cs:[Pozic]
         dec       bx

DispCol4:mov       dl,1

DispCol5:push      cx
         mov       bh,bl
         sub       bh,dl
         cmp       bh,cl
         ja        DispCl52
         mov       cl,bh
DispCl52:call      DispMChr
         pop       cx

         inc       ah
         jz        DispCol6
         cmp       dl,bl
         jb        DispCol5

         call      TestKey
         jnz       DispCol9

         inc       dh
         dec       ch
         jnz       DispCol4

DispCol6:

DispCol9:ret

DispCol  ENDP

; -----------------------------------------------------------------------------
;        detekce videom¢d– karty
; -----------------------------------------------------------------------------
;þ
Detect:


         test      byte ptr cs:[Params],bit1     ; je u‘ovatelsk˜ m¢d ?
         jnz       Detect1
         or        byte ptr cs:[Params],bit1
         inc       word ptr cs:[MaxCard]
Detect1: mov       ax,cs:[MaxCard]
         dec       ax
         mov       cs:[AktCard],ax
         mov       byte ptr cs:[UserMod0],0


         mov       di,offset UserMod        ; buffer
         xor       bx,bx                    ; ukazatel ‡¡sla m¢du
Detect2: mov       ah,0
         mov       al,bl
         call      Int10A
         mov       ah,0fh
         call      Int10P
         cmp       al,bl
         jne       Detect3
         mov       cs:[di],bl
         inc       byte ptr cs:[UserMod0]

         push      di
         push      bx

         call      GetPar
         mov       al,cs:[GrafMod]
         shl       al,1
         shl       al,1
         mov       ah,byte ptr cs:[SegmVRAM+1]
         or        ah,ah
         jz        Detect21
         inc       ax
         cmp       ah,0a0h
         je        Detect21
         inc       ax
         cmp       ah,0b0h
         je        Detect21
         inc       ax
Detect21:
         mov       ch,cs:[ModVRAM]          ; m¢d videopamˆti
         mov       cl,4
         shl       ch,cl
         or        al,ch

         mov       cs:[di+1],al             ; parametry
         mov       cx,cs:[Barev]
         dec       cx
         mov       cs:[di+2],cl             ; po‡et barev
         mov       ah,cs:[NumPages]
         mov       cs:[di+3],ah             ; po‡et videostr nek
         mov       cx,word ptr cs:[Pozic]   ; po‡et pozic na © dek
         test      al,4
         jz        Detect22
         shl       cx,1
         shl       cx,1
         shl       cx,1
Detect22:mov       cs:[di+4],cx             ; horizont n¡ rozli¨en¡

;         test      al,4
;         mov       ax,word ptr cs:[Radku]   ; po‡et © dk– displeje
;         jz        Detect23
;         mul       byte ptr cs:[LinChr]
         mov       ax,cs:[Vertik]
Detect23:mov       cs:[di+6],ax             ; vertik ln¡ rozli¨en¡

         pop       bx
         pop       di

         add       di,8
Detect3: inc       bx
         cmp       bl,125
         ja        Detect4
         cmp       bl,7
         jbe       Detect32
         cmp       bl,13
         jb        Detect3

Detect32:
         jmp       Detect2


Detect4:
         jmp       Start2

; -----------------------------------------------------------------------------
;        zobrazen¡ © dku polo‘ky voleb m¢du BX
; -----------------------------------------------------------------------------
;þ
DispRad  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ © dek na displeji k zobrazen¡ polo‘ky

         mov       dh,bl                    ; ‡¡slo polo‘ky
         sub       dh,byte ptr cs:[ModTTop] ; offset od po‡ te‡n¡ polo‘ky
         add       dh,9                     ; + po‡ te‡n¡ © dek
         mov       al,dh                    ; aktu ln¡ © dek
         inc       ax
         cmp       dh,cs:[Radku]            ; p©ekro‡en konec ?
         jae       DispRad0                 ; neplatn‚ ‡¡slo © dku

; ------ kontrola ‡¡sla polo‘ky

         cmp       bx,cs:[ModTNum]
         jb        DispRad1                 ; ‡¡slo polo‘ky je OK

; ------ n hradn¡ vymaz n¡ © dku

         mov       dl,1                     ; po‡ te‡n¡ pozice
         mov       cl,78
         mov       ax,720h
         call      DispSpc                  ; vymaz n¡ © dku
DispRad0:jmp       DispRad9                 ; konec

; ------ ur‡en¡ barvy k zobrazen¡ polo‘ky

DispRad1:mov       ah,7                     ; bˆ‘n  polo‘ka
         cmp       bx,cs:[ModTAkt]          ; je to aktivn¡ polo‘ka ?
         jne       DispRad2                 ; nen¡ to aktivn¡ polo‘ka
         mov       ah,70h                   ; barva aktivn¡ polo‘ky

; ------ adresa definice polo‘ky

DispRad2:call      GetPol                   ; adresa definice polo‘ky

; ------ zobrazen¡ ‡¡sla videom¢du

         mov       dl,1                     ; po‡ te‡n¡ pozice k zobrazen¡
         mov       al,cs:[bx+0]             ; ‡¡slo videom¢du
         mov       cl,3                     ; po‡et pozic d‚lky ‡¡sla
         call      DispByte                 ; zobrazen¡ ‡¡sla (bajt)

; ------ zobrazen¡ ‡¡sla m¢du HEX

         mov       cl,2
         call      DispSpc                  ; 2 mezery
         call      DispBHex                 ; zobrazen¡ bajtu HEX
         mov       al,"h"
         call      Disp1Chr                 ; zobrazen¡ znaku "h"

; ------ zobrazen¡ pr zdn‚ho © dku pro nedefinovanou polo‘ku

         cmp       byte ptr cs:[bx+1],0     ; je polo‘ka definovan  ?
         jne       DispRd22                 ; je definovan 
         mov       si,offset ModNad0        ; nedefinovan  polo‘ka
         call      DispStr                  ; zobrazen¡ nedefinovan‚ polo‘ky
         jmp       short DispRad0

; ------ zobrazen¡ typu textov˜/grafick˜

DispRd22:mov       si,offset TextTxt        ; text "Textov˜"
         test      byte ptr cs:[bx+1],bit2  ; je grafick˜ ?
         jz        DispRad3                 ; je textov˜
         mov       si,offset GrafTxt        ; text "Grafick˜"
DispRad3:call      DispStr                  ; zobrazen¡ ©etˆzce

; ------ zobrazen¡ horizont ln¡ho rozli¨en¡

         mov       cx,cs:[bx+4]             ; horizont ln¡ rozli¨en¡
         mov       al,7
         call      DispWord                 ; zobrazen¡ horizont ln¡ho rozli¨en¡

; ------ zobrazen¡ vertik ln¡ho rozli¨en¡

         mov       cx,cs:[bx+6]             ; vertik ln¡ rozli¨en¡
         mov       al,8
         call      DispWord                 ; zobrazen¡ vertik ln¡ho rozli¨en¡

; ------ zobrazen¡ po‡tu barev

         mov       al,7                     ; po‡et pozice
         mov       cl,cs:[bx+2]             ; po‡et barev - 1
         mov       ch,0
         jcxz      DispRd42                 ; je MONO
         inc       cx                       ; po‡et barev
         call      DispWord                 ; zobrazen¡ po‡tu barev
         jmp       short DispRd44
DispRd42:mov       si,offset MonoTxt
         call      DispStr

; ------ zobrazen¡ po‡tu str nek

DispRd44:mov       al,cs:[bx+3]             ; po‡et str nek
         mov       cl,5
         call      DispByte                 ; zobrazen¡ po‡tu str nek

; ------ zobrazen¡ adresy

         mov       cl,3
         call      DispSpc
         mov       si,offset Adr1txt        ; B800h
         mov       al,cs:[bx+1]
         and       al,3
         cmp       al,3
         je        DispRad5
         mov       si,offset Adr2txt
         cmp       al,2
         je        DispRad5
         mov       si,offset Adr3txt
         cmp       al,1
         je        DispRad5
         mov       si,offset Adr4Txt
DispRad5:call      DispStr

; ------ zobrazen¡ typu m¢du

         mov       cl,cs:[bx+1]             ; parametry
         and       cx,0f0h
         shr       cx,1
         add       cx,offset ModTxtT
         mov       si,cx
         call      DispStr                  ; zobrazen¡ typu videom¢du

; ------ zobrazen¡ typu videom¢du

         mov       cl,3
         call      DispSpc

         mov       al,"G"
         test      byte ptr cs:[bx+1],bit2
         jnz       DispRad6
         mov       al,"T"
DispRad6:call      Disp1Chr
         mov       cl,1
         call      DispSpc

         mov       cx,cs:[bx+4]             ; horizont ln¡ rozli¨en¡
         mov       al,0
         call      DispWord                 ; zobrazen¡ horizont ln¡ho rozli¨en¡
         mov       al,"x"
         call      Disp1Chr
         mov       cx,cs:[bx+6]             ; vertik ln¡ rozli¨en¡
         mov       al,0
         call      DispWord                 ; zobrazen¡ vertik ln¡ho rozli¨en¡
         mov       al,"/"
         call      Disp1Chr

         mov       al,0                     ; po‡et pozice
         mov       cl,cs:[bx+2]             ; po‡et barev - 1
         mov       ch,0
         jcxz      DispRad7                 ; je MONO
         inc       cx                       ; po‡et barev
         call      DispWord                 ; zobrazen¡ po‡tu barev
         jmp       short DispRad8
DispRad7:mov       al,"M"
         call      Disp1Chr

DispRad8:mov       cl,79
         sub       cl,dl
         call      DispSpc

; ------ n vrat registr–

DispRad9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispRad  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu HEX
; -----------------------------------------------------------------------------

DispBHex PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHx
         pop       ax
                                            ; pokra‡uje DispHx

DispBHex ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku HEX
; -----------------------------------------------------------------------------

DispHx   PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,10
         jb        DispHx1
         add       al,7
DispHx1: add       al,"0"
         call      Disp1Chr
         pop       ax
         ret

DispHx   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AL (barva AH, pozice DX, d‚lka CL)
; -----------------------------------------------------------------------------

DispByte PROC      NEAR

         push      ax
         push      cx

         xchg      al,cl                    ; CL <- ‡¡slo, AL <- d‚lka
         mov       ch,0
         call      DispWord                 ; zobrazen¡ ‡¡sla

         pop       cx
         pop       ax
         ret

DispByte ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla CX (barva AH, pozice DX, d‚lka AL)
; -----------------------------------------------------------------------------

DispWord PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ p©¡prava registr–

         mov       di,dx                    ; £schova pozice k zobrazen¡
         xchg      ax,bx                    ; BH <- barva textu, BL <- d‚lka
         xchg      ax,cx                    ; AX <- ‡¡slo k zobrazen¡
         xor       cx,cx                    ; ‡¡ta‡ po‡tu ‡¡slic
         mov       si,10                    ; dˆlitel ‡¡sla

; ------ dek¢dov n¡ ‡¡sla

DispWrd1:xor       dx,dx                    ; DX <- 0
         div       si                       ; v˜po‡et jedn‚ ‡¡slice
         add       dl,"0"                   ; korekce na znak ASCII
         mov       dh,bh                    ; barva textu
         push      dx                       ; £schova ‡¡slice
         inc       cx                       ; ‡¡ta‡ ‡¡slic
         dec       bl                       ; ‡¡ta‡ pozic
         jns       DispWrd2
         inc       bl
DispWrd2:or        ax,ax                    ; je je¨tˆ ‡¡slo ?
         jnz       DispWrd1                 ; v˜po‡et dal¨¡ ‡¡slice

; ------ zobrazen¡ mezer p©ed ‡¡slem

         mov       dx,di                    ; © dek a pozice k zobrazen¡ ‡¡sla
         mov       ah,bh                    ; barva textu
         mov       al," "                   ; znak mezery
         push      cx
         mov       cl,bl                    ; po‡et zbyl˜ch mezer
         call      DispChr                  ; zobrazen¡ mezer p©ed ‡¡slem
         pop       cx

; ------ zobrazen¡ dek¢dovan‚ho ‡¡sla

DispWrd3:pop       ax
         call      Disp1Chr                 ; zobrazen¡ ‡¡slice
         loop      DispWrd3

; ------ n vrat registr– (bez DX)

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispWord ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu hlavn¡ho menu
; -----------------------------------------------------------------------------

Disp1Ram PROC      NEAR

         xor       dx,dx

         mov       ah,0fh

         mov       al,"É"
         mov       bx,"Í»"
         call      DispLink

         mov       cl,5
         call      DispSLin

         mov       si,offset ModNadp
         call      DispCent                 ; zobrazen¡ 1. © dku nadpisu

         push      dx
         mov       dl,0
         mov       cx,80
Disp1Rm1:mov       al,cs:[si]
         inc       si
         mov       ah,0fh
         cmp       al,128
         jae       Disp1Rm2
         mov       ah,11
Disp1Rm2:call      Disp1Chr
         loop      Disp1Rm1
         pop       dx
         inc       dh

         call      DispCent                 ; zobrazen¡ 3. © dku nadpisu

         mov       cl,cs:[Radku]
         sub       cl,10
         call      DispSLin

         mov       al,"È"
         mov       bx,"Í¼"
         call      DispLink

         dec       dh
         mov       dl,8
         mov       si,offset Help1Txt
         mov       ah,12
         call      DispStr

         add       dl,21
         mov       si,offset Help2Txt
         call      DispStr

         ret

Disp1Ram ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu m¢du
; -----------------------------------------------------------------------------

Disp2Ram PROC      NEAR

         xor       dx,dx

         mov       ah,0fh

         mov       al,"É"
         mov       bx,"Í»"
         call      DispLink

         call      TestKey
         jnz       Disp2Rm9

         mov       cl,cs:[Radku]
         sub       cl,2
         call      DispSLin

         call      TestKey
         jnz       Disp2Rm9

         mov       al,"È"
         mov       bx,"Í¼"
         call      DispLink

Disp2Rm9:
         ret

Disp2Ram ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ CL linek z mezer
; -----------------------------------------------------------------------------

DispSLin PROC      NEAR

         mov       al,"º"
         mov       bx," º"
         call      DispCLin
         ret

DispSLin ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ CL linek
; -----------------------------------------------------------------------------

DispCLin PROC      NEAR

         push      cx
         mov       ch,0
         jcxz      DispCLn2
DispCLn1:call      DispLink
         loop      DispCLn1
DispCLn2:pop       cx
         ret

DispCLin ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ jedn‚ linky (AH=barva, AL=1.znak, BH=2.znak, BL=3.znak)
; -----------------------------------------------------------------------------

DispLink PROC      NEAR

         push      ax
         push      dx
         push      cx

         call      Disp1Chr
         mov       cl,cs:[Pozic]            ; po‡et pozic na © dek
         dec       cx
         dec       cx                       ; vnit©n¡ d‚lka linky
         mov       al,bh                    ; druh˜ znak linky
         cmp       al," "
         jne       DispLin1
         cmp       byte ptr cs:[GrafMod],0
         je        DispLin1
;         mov       ch,cs:[AktMod]
;         cmp       ch,cs:[InitMod]
;         je        DispLin1
         add       dl,cl
         jmp       short DispLin2
DispLin1:call      DispMChr
DispLin2:mov       al,bl                    ; t©et¡ znak linky
         call      Disp1Chr

         pop       cx
         pop       dx
         pop       ax
         inc       dh
         ret

DispLink ENDP

; -----------------------------------------------------------------------------
;        detekce parametr– videom¢du (nastav¡ obsluhu BIOS)
; -----------------------------------------------------------------------------
;þ
GetPar   PROC      NEAR

         and       byte ptr cs:[ParamS],not bit0 ; obsluha BIOS

; ------ nastaven¡ str nky 0

         mov       al,0
         call      SetPage                  ; nastaven¡ videostr nky 0

; ------ aktu ln¡ videom¢d a po‡et pozic na © dek

         mov       ah,0fh
         call      Int10P
         mov       cs:[AktMod],al           ; aktu ln¡ videom¢d
         mov       cs:[Pozic],ah            ; po‡et pozic na © dek

; ------ detekce segmentu videopamˆti a textov‚ho m¢du

         call      DetSegm                  ; detekce segmentu videopamˆti a m¢du

; ------ po‡et © dk– displeje

         xor       ax,ax
         mov       ds,ax
         mov       bl,ds:[484h]             ; posledn¡ © dek
         cmp       bl,10
         jb        GetPar22
         cmp       bl,250
         ja        GetPar22
         cmp       byte ptr cs:[EgaVga],0   ; je EGA/VGA ?
         jne       GetPar23                 ; je EGA/VGA
GetPar22:mov       bl,24
GetPar23:inc       bx
         mov       cs:[Radku],bl            ; po‡et © dk– displeje

; ------ po‡et linek na znak

         mov       al,ds:[485h]
         cmp       al,3
         jbe       GetPar24
         cmp       al,64
         ja        GetPar24
         cmp       byte ptr cs:[EgaVga],0
         jne       GetPar25
GetPar24:mov       al,8
GetPar25:mov       cs:[LinChr],al           ; po‡et linek na znak

; ------ vertik ln¡ rozli¨en¡

         call      DetVert                  ; detekce vertik ln¡ho rozli¨en¡

; ------ detekce velikosti videopamˆti

         call      DetMSize                 ; detekce velikosti videopamˆti

; ------ po‡et videostr nek

         call      DetPages                 ; detekov n¡ po‡tu videostr nek

; ------ b zov  ©¡dic¡ adresa portu displeje

         mov       ax,ds:[463h]             ; adresa portu
         mov       cs:[BazePort],ax         ; adresa portu displeje

; ------ zpˆtn‚ nastaven¡ str nky 0

         mov       al,0
         call      SetPage                  ; nastaven¡ videostr nky 0
         ret

GetPar   ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ velikosti videopamˆti
; -----------------------------------------------------------------------------

DetMSize PROC      NEAR

; ------ adresa A000h - je v‘dy 64 KB

         xor       bx,bx                    ; 64 KB
         cmp       byte ptr cs:[SegmVRAM+1],0a0h
         je        DetMSiz9                 ; je EGA/VGA

; ------ ni‘¨¡ typy karet budou m¡t asi v‘dy 16 KB

         mov       bx,4000h                 ; velikost 16 KB
         cmp       byte ptr cs:[Card],4     ; je vy¨¨¡ typ karty ?
         jb        DetMSiz9                 ; je ni‘¨¡ typ karty

         mov       bh,80h                   ; jinak 32 KB

;; ------ test, zda je 32 KB
;
;         mov       si,7ef0h                 ; testovac¡ adresa
;         mov       bx,4000h                 ; velikost pamˆti
;         call      DetMSiz0                 ; test velikosti 16 KB
;

DetMSiz9:mov       cs:[MemSize],bx          ; velikost videopamˆti
         ret

DetMSize ENDP

;; -----------------------------------------------------------------------------
;;        test jedn‚ adresy ES:SI
;; -----------------------------------------------------------------------------
;
;DetMSiz0 PROC      NEAR
;
;         push      cx
;         push      dx
;         push      di
;
;         cmp       byte ptr cs:[ModVRAM],11 ; je m¢d EGA ?
;         jb        DetMSz00                 ; nen¡ m¢d EGA
;         cmp       byte ptr cs:[Card],5     ; je karta EGA nebo VGA ?
;         jb        DetMSz00                 ; nen¡ karta EGA/VGA
;
;         mov       dx,3ceh
;         mov       al,4
;         out       dx,al
;         inc       dx
;         mov       al,0
;         out       dx,al                    ; volba ‡tec¡ mapy 0
;
;         mov       dl,0c4h
;         mov       al,2
;         out       dx,al
;         inc       dx
;         mov       al,0fh
;         out       dx,al                    ; z pis do rovin 0 a‘ 3
;
;DetMSz00:
;         mov       cx,offset(Vzorky0-Vzorky)
;         mov       di,offset Vzorky
;
;         mov       ah,es:[si]
;DetMSz01:mov       al,cs:[di]
;         inc       di
;         mov       es:[si],al
;         jmp       $+2
;         cmp       al,es:[si]
;         jne       DetMSz02
;         cmp       al,es:[si]
;         jne       DetMSz02
;         cmp       al,es:[si]
;         loope     DetMSz01
;
;DetMSz02:mov       es:[di],ah
;         pop       di
;         pop       dx
;         pop       cx
;         ret
;
;DetMSiz0 ENDP
;
;Vzorky   db        2ah,55h,0aah,7eh,34h,0feh,099h,044h
;Vzorky0  label     byte

; -----------------------------------------------------------------------------
;        detekov n¡ po‡tu videostr nek
; -----------------------------------------------------------------------------

DetPages PROC      NEAR

; ------ p©ednastaven¡ d‚lky videostr nky

         xor       cx,cx
         mov       ds,cx
         mov       cx,ds:[44ch]             ; d‚lka videostr nky
         mov       cs:[DelkaPg],cx          ; d‚lka videostr nky

; ------ v˜po‡et velikosti videostr nky

         mov       ax,cs:[Vertik]           ; po‡et © dk– (linek)
         mov       dx,word ptr cs:[Pozic]   ; po‡et pozic na © dek
         mul       dx                       ; * po‡et bajt– na © dek = velikost
         or        dx,dx                    ; je v¡ce ne‘ 64 KB ?
         jz        DetPag1

DetPag0: mov       byte ptr cs:[DelkaPg],0
         mov       byte ptr cs:[NumPages],1
         ret

DetPag1: mov       dl,cs:[ModVRAM]          ; m¢d videopamˆti
         cmp       dl,0
         je        DetPag5                  ; m¢d nen¡ zn m

         sub       dl,3                     ; textov˜ m¢d ?
         jb        DetPag3                  ; textov˜ m¢d

         cmp       dl,11-3
         jae       DetPag4                  ; EGA je OK
         and       dl,3
         jz        DetPag4                  ; MCGA 1, CGA 1
         dec       dl
         jz        DetPag3                  ; MCGA 2, CGA 2
         dec       dl
         jz        DetPag2                  ; MCGA 3, CGA 3
         shl       ax,1
         jc        DetPag1
DetPag2: shl       ax,1
         jc        DetPag1
DetPag3: shl       ax,1
         jc        DetPag1
DetPag4: add       ax,0ffh
         jc        DetPag1
         and       ax,not 0ffh              ; zaokrouhlen¡
         mov       cs:[DelkaPg],ax          ; d‚lka videostr nky

; ------ v˜po‡et po‡tu videostr nek

DetPag5: xor       dx,dx
         mov       bx,cs:[MemSize]          ; velikost pamˆti
         or        bx,bx
         jnz       DetPag6
         inc       dx
DetPag6: mov       ax,bx

         push      dx
         mov       byte ptr cs:[NumPages],1 ; p©ednastaven¡ - 1 str nka
         mov       cx,cs:[DelkaPg]          ; d‚lka str nky
         cmp       cx,1
         jbe       DetPag7                  ; p©ete‡en¡
         div       cx                       ; v˜po‡et po‡tu str nek
         or        ah,ah
         jnz       DetPag7                  ; p©ete‡en¡
         or        al,al
         jz        DetPag7                  ; minim lnˆ 1 str nka
         cmp       al,8                     ; maxim ln¡ po‡et str nek
         jbe       DetPg62                  ; po‡et str nek OK
         mov       al,8                     ; omezen¡ po‡tu str nek
DetPg62: mov       cs:[NumPages],al         ; po‡et videostr nek
DetPag7: pop       dx

; ------ zpˆtn˜ v˜po‡et d‚lky videostr nky

         mov       ax,bx
         mov       cs:[DelkaPg],ax          ; d‚lka str nky
         mov       cl,cs:[NumPages]         ; po‡et str nek
         mov       ch,0
         cmp       cl,1
         jbe       DetPag8
         div       cx                       ; v˜po‡et d‚lky str nky
         mov       cs:[DelkaPg],ax          ; opraven  d‚lka str nky

DetPag8: ret

DetPages ENDP

; -----------------------------------------------------------------------------
;        test adresy ES:SI
; -----------------------------------------------------------------------------

DetPg0   PROC      NEAR

         mov       al,es:[si]

         not       al
         mov       es:[si],al
         cmp       al,es:[si]
         jne       DetPg06

         xor       al,0aah
         mov       es:[si],al
         cmp       al,es:[si]
         jne       DetPg06

         not       al
         mov       es:[si],al
         cmp       al,es:[si]
         jne       DetPg06

         xor       al,0aah
         mov       es:[si],al
         cmp       al,es:[si]

DetPg06: ret

DetPg0   ENDP

; -----------------------------------------------------------------------------
;        detekce vertik ln¡ho rozli¨en¡
; -----------------------------------------------------------------------------

DetVert  PROC      NEAR

         mov       ax,word ptr cs:[Radku]   ; po‡et © dk– celkem
         cmp       byte ptr cs:[GrafMod],0  ; je grafick˜ m¢d ?
         je        DetVert8                 ; je textov˜ m¢d

         mul       byte ptr cs:[LinChr]     ; v˜po‡et po‡tu grafick˜ch linek
         mov       cs:[Vertik],ax           ; po‡et grafick˜ch linek

         cmp       byte ptr cs:[Card],6     ; je karta VGA ?
         je        DetVert3                 ; je karta VGA

         mov       cx,10
         add       ax,9
         xor       dx,dx
         div       cx
         mul       cx                       ; zaokrouhlen¡
         jmp       short DetVert8


DetVert3:mov       ah,9
         call      ReadPort

         and       al,1fh                   ; po‡et linek na znak - 1
         inc       ax
         mov       cl,al                    ; po‡et linek na znak
         mov       ch,0

         mov       ah,12h
         call      ReadPort                 ; posledn¡ linka
         mov       dl,al

         mov       ah,7
         call      ReadPort
         mov       dh,al
         shr       dh,1
         and       dh,1
         rol       al,1
         rol       al,1
         rol       al,1
         and       al,2
         or        dh,al
         xchg      ax,dx
         inc       ax

         mul       cx

         mov       cx,cs:[Vertik]
         mov       dx,cx
         shr       dx,1
         add       dx,cx
DetVert5:cmp       ax,dx
         jb        DetVert6
         shr       ax,1
         jmp       short DetVert5

DetVert6:mov       dx,cx
         shr       dx,1
         shr       dx,1
         add       cx,dx
         cmp       ax,cx
         ja        DetVert9
         sub       cx,dx
         sub       cx,dx
         cmp       ax,cx
         jb        DetVert9

DetVert8:mov       cs:[Vertik],ax           ; up©esnˆn‚ vertik ln¡ rozli¨en¡

DetVert9:ret

DetVert  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ registru videokarty VGA ‡¡slo AH
; -----------------------------------------------------------------------------

ReadPort PROC      NEAR

         push      dx
         push      ds

         xor       dx,dx
         mov       ds,dx
         mov       dx,ds:[463h]

         pop       ds

         mov       al,ah
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         inc       dx
         in        al,dx                    ; ‡ten¡ portu

         pop       dx
         ret

ReadPort ENDP

; -----------------------------------------------------------------------------
;        detekce segmentu videopamˆti a m¢du grafiky (aktivn¡ v˜stup BIOS)
; -----------------------------------------------------------------------------

DetSegm  PROC      NEAR

; ------ nalezen¡ typu videom¢du

         mov       si,offset VzorTab - 6*2  ; tabulka vzork–
         mov       cx,offset(VzorTab0-VzorTab)/12 ; po‡et vzork– v tabulce
DetSegm2:add       si,2*6                   ; zv˜¨en¡ ukazatele v tabulce
         call      TestSegm                 ; nalezen¡ segmentu podle vzorku
         loopne    DetSegm2                 ; nenalezen - dal¨¡ vzorek

; ------ typ m¢du nenalezen

         je        DetSegm3                 ; vzorek nalezen

; ------ detekce m¢du pomoc¡ port– VGA

         cmp       byte ptr cs:[Card],6     ; je karta VGA ?
         jne       DetSgm22                 ; nen¡ karta VGA
         mov       dx,3ceh
         mov       al,6
         out       dx,al                    ; volba registru 6
         inc       dx
         in        al,dx                    ; ‡ten¡ registru 6
         mov       bx,0a000h
         test      al,bit3
         jz        DetSgm21                 ; segment pamˆti A000h
         mov       bh,0b8h
         test      al,bit2
         jnz       DetSgm21                 ; segment B800h
         mov       bh,0b0h                  ; jinak segment B000h
DetSgm21:mov       ah,al
         and       ax,100h                  ; grafick˜ m¢d
         jmp       short DetSgm23

; ------ nezn m‚ parametry

DetSgm22:mov       ax,100h                  ; jinak nezn m˜ m¢d pamˆti, grafika
         xor       bx,bx                    ; nezn m˜ segment
DetSgm23:mov       dx,16                    ; 16 barev
         jmp       short DetSegm9           ; nastaven¡ parametr–

; ------ rozli¨en¡ typu textov‚ho m¢du

DetSegm3:mov       cl,al                    ; m¢d pamˆti
         sub       cl,3                     ; je textov˜ m¢d ?
         jnc       DetSegm5                 ; je grafick˜ m¢d
         xor       dx,dx
         mov       ds,dx                    ; DS <- 0
         cmp       word ptr ds:[463h],3b4h  ; je karta MDA ?
         mov       dx,16                    ; barevn˜ textov˜ m¢d
         jne       DetSegm4                 ; nen¡ karta MDA
         mov       dx,1                     ; jinak monochrom. m¢d
DetSegm4:mov       ah,0                     ; p©¡znak grafick‚ho m¢du
         jmp       short DetSegm9           ; nastaven¡ parametr–

; ------ po‡et barev

DetSegm5:and       cl,3                     ; po‡et rotac¡ 0, 1, 2, 3
         mov       ch,1
         shl       ch,cl                    ; ‡¡slo 1, 2, 4, 8
         mov       cl,ch                    ; nov˜ po‡et rotac¡ (1, 2, 4, 8)
         mov       dx,1                     ; p©ednastaven¡
         shl       dx,cl                    ; po‡et barev (2,4,16,256)
         mov       ah,1                     ; p©¡znak grafick‚ho m¢du

         cmp       al,11                    ; je EGA m¢d ?
         jb        DetSegm9                 ; nen¡ EGA m¢d

         xor       cx,cx
         mov       ds,cx                    ; DS <- 0
         cmp       word ptr ds:[463h],3b4h  ; je karta MDA ?
         jne       DetSegm9                 ; nen¡ m¢d MONO
         mov       dx,1                     ; jinak monochrom. m¢d

         cmp       al,13
         jb        DetSegm9
         mov       al,12                    ; omezen¡ na max. 4 barvy

; ------ nastaven¡ detekovan˜ch parametr–

DetSegm9:mov       cs:[ModVRAM],al          ; m¢d videopamˆti
         mov       cs:[GrafMod],ah          ; p©¡znak grafick‚ho m¢du
         mov       cs:[SegmVRAM],bx         ; segment videopamˆti
         mov       cs:[Barev],dx            ; po‡et barev
         ret

DetSegm  ENDP


; ------ vzorky k testu videom¢du

VzorTab  label     word
VzorTxtP dw        1,Tst1TxtP,2e6ah,3a2eh,729ah,0720h ;  1 = text prokl dan˜
VzorTxtS dw        2,Tst1TxtS,2e6ah,3a2eh,729ah,0720h ;  2 = text sekven‡n¡

VzorCGA2 dw        4,Tst1CGA2,1dbh,2dbh,3dbh,020h     ;  4 = CGA 2 (4 barvy)
VzorCGA1 dw        3,Tst1CGA1,1dbh,020h,1dbh,020h     ;  3 = CGA 1 (2 barvy)
VzorCGA4 dw        5,Tst1CGA4,2dbh,5dbh,9dbh,020h     ;  5 = CGA 4 (16 barev)

VzorMCG8 dw        10,Tst1MCG8,2adbh,7edbh,0a5dbh,020h; 10 = MCGA 8 (256 barev)
VzorMCG4 dw        9,Tst1MCG4,2dbh,5dbh,9dbh,020h     ;  9 = MCGA 4 (16 barev)
VzorMCG2 dw        8,Tst1MCG2,1dbh,2dbh,3dbh,020h     ;  8 = MCGA 2 (4 barvy)

VzorCGA8 dw        6,Tst1CGA8,2adbh,7edbh,0a5dbh,020h ;  6 = CGA 8 (256 barev)

VzorEGA8 dw        14,Tst1EGA8,2adbh,7edbh,0a5dbh,020h; 14 = EGA 8 (256 barev)
VzorEGA4 dw        13,Tst1EGA4,2dbh,5dbh,0adbh,020h   ; 13 = EGA 4 (16 barev)
VzorEGA2 dw        12,Tst1EGA2,1dbh,2dbh,3dbh,020h    ; 12 = EGA 2 (4 barvy)
VzorEG32 dw        12,Tst2EGA2,1dbh,2dbh,3dbh,020h    ; 12 = EGA 2 (4 barvy)

VzorEGA1 dw        11,Tst1EGA1,1dbh,020h,1dbh,020h    ; 11 = EGA 1 (2 barvy)

VzorMCG1 dw        7,Tst1MCG1,1dbh,020h,1dbh,020h     ;  7 = MCGA 1 (2 barvy)

VzorTab0 label     word

; -----------------------------------------------------------------------------
;        nalezen¡ segmentu podle vzoru SI -> BX, ZY=nalezen, AL=typ m¢du
; -----------------------------------------------------------------------------

TestSegm PROC      NEAR

         mov       bx,0b800h
         call      Test0Sgm                 ; test segmentu
         je        TestSgm2

         mov       bh,0b0h
         call      Test0Sgm
         je        TestSgm2

         mov       bh,0a0h
         call      Test0Sgm

TestSgm2:ret

TestSegm ENDP

; -----------------------------------------------------------------------------
;        test segmentu BX vzorem SI (ZY=OK, AL=typ videom¢du)
; -----------------------------------------------------------------------------

Test0Sgm PROC      NEAR

         push      bx
         push      cx
         push      si
         push      es

         mov       es,bx                    ; adresa segmentu
         inc       si
         inc       si
         mov       bx,cs:[si]               ; adresa obsluhy testu
         mov       cx,4

Test0Sg1:inc       si
         inc       si
         mov       ax,cs:[si]               ; vzorek
         call      bx                       ; test jednoho vzorku
         loope     Test0Sg1

         pop       es
         pop       si
         pop       cx
         pop       bx
         mov       ax,cs:[si]               ; typ videom¢du
         ret

Test0Sgm ENDP

; -----------------------------------------------------------------------------
;        1: test znaku AX v textov‚m m¢du prokl dan‚m (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1TxTP PROC      NEAR

         push      dx
         xor       dx,dx
         call      Disp1Chr                 ; zobrazen¡ znaku BIOS
         cmp       ax,es:[0]                ; souhlas¡ znak ?
         pop       dx
         ret

Tst1TxtP ENDP

; -----------------------------------------------------------------------------
;        2: test znaku AX v textov‚m m¢du sekven‡n¡m (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1TxtS PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         call      Disp1Chr
         mov       ah,al
         cmp       ax,es:[0]
         pop       dx
         pop       ax
         ret

Tst1TxtS ENDP

; -----------------------------------------------------------------------------
;        3: test znaku AX v grafick‚m m¢du CGA 1 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1CGA1 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,0
         test      ah,1
         jz        Tst1CG12
         not       al
Tst1CG12:cmp       al,es:[0]
         jne       Tst1CG14
         cmp       al,es:[2000h]
Tst1CG14:pop       dx
         pop       ax
         ret

Tst1CGA1 ENDP

; -----------------------------------------------------------------------------
;        4: test znaku AX v grafick‚m m¢du CGA 2 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1CGA2 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,ah
         shl       ah,1
         shl       ah,1
         or        al,ah
         shl       ah,1
         shl       ah,1
         or        al,ah
         shl       ah,1
         shl       ah,1
         or        al,ah
         mov       ah,al
         cmp       ax,es:[0]
         jne       Tst1CG22
         cmp       ax,es:[2000h]
Tst1CG22:pop       dx
         pop       ax
         ret

Tst1CGA2 ENDP

; -----------------------------------------------------------------------------
;        5: test znaku AX v grafick‚m m¢du CGA 4 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1CGA4 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,ah
         shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1
         or        al,ah
         mov       ah,al
         cmp       ax,es:[0]
         jne       Tst1CG42
         cmp       ax,es:[2000h]
Tst1CG42:pop       dx
         pop       ax
         ret

Tst1CGA4 ENDP

; -----------------------------------------------------------------------------
;        6: test znaku AX v grafick‚m m¢du CGA 8 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1CGA8 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,ah
         cmp       ax,es:[0]
         jne       Tst1CG82
         cmp       ax,es:[2000h]
Tst1CG82:pop       dx
         pop       ax
         ret

Tst1CGA8 ENDP

; -----------------------------------------------------------------------------
;        7: test znaku AX v grafick‚m m¢du MCG 1 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1MCG1 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,0
         test      ah,1
         jz        Tst1MC12
         not       al
Tst1MC12:cmp       al,es:[0]
         pop       dx
         pop       ax
         ret

Tst1MCG1 ENDP

; -----------------------------------------------------------------------------
;        8: test znaku AX v grafick‚m m¢du MCG 2 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1MCG2 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,ah
         shl       ah,1
         shl       ah,1
         or        al,ah
         shl       ah,1
         shl       ah,1
         or        al,ah
         shl       ah,1
         shl       ah,1
         or        al,ah
         mov       ah,al
         cmp       ax,es:[0]
         pop       dx
         pop       ax
         ret

Tst1MCG2 ENDP

; -----------------------------------------------------------------------------
;        9: test znaku AX v grafick‚m m¢du MCG 4 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1MCG4 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,ah
         shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1
         or        al,ah
         mov       ah,al
         cmp       ax,es:[0]
         pop       dx
         pop       ax
         ret

Tst1MCG4 ENDP

; -----------------------------------------------------------------------------
;        10: test znaku AX v grafick‚m m¢du MCG 8 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1MCG8 PROC      NEAR

         push      ax
         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       al,ah
         cmp       ax,es:[0]
         pop       dx
         pop       ax
         ret

Tst1MCG8 ENDP

; -----------------------------------------------------------------------------
;        12: alternativn¡ test znaku AX v graf.m¢du EGA 2 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst2EGA2 PROC      NEAR

         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       dl,2

Tst2EG82:push      cx
         push      ax
         mov       ch,dl                    ; po‡et rovin k testov n¡
         mov       cl,0                     ; ukazatel ‡¡sla roviny

         mov       dx,3ceh
         mov       al,4
         out       dx,al                    ; volba registru ‡tec¡ roviny
         inc       dx
Tst2EG83:mov       al,cl                    ; ‡¡slo roviny ke ‡ten¡
         out       dx,al                    ; nastaven¡ ‡tec¡ roviny

         mov       al,es:[0]                ; ‡ten¡ bajtu z roviny
         shr       ah,1                     ; m  b˜t rovina nastavena ?
         jnc       Tst2EG84                 ; nem  b˜t nastavena
         not       al                       ; negace - bude 0
Tst2EG84:cmp       al,0                     ; je obsah roviny spr vn˜ ?
         jne       Tst2EG88                 ; obsah roviny nen¡ spr vn˜

         inc       cx
         inc       cx                       ; zv˜¨en¡ ukazatele ‡¡sla roviny
         cmp       cl,ch                    ; jsou ji‘ v¨echny roviny ?
         jne       Tst2EG83                 ; test dal¨¡ roviny
                                            ; jinak ZY=OK
Tst2EG88:pop       ax
         pop       cx
         pop       dx
         ret

Tst2EGA2 ENDP

; -----------------------------------------------------------------------------
;        11: test znaku AX v grafick‚m m¢du EGA 1 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1EGA1 PROC      NEAR

         push      dx
         xor       dx,dx
         call      Disp1Chr
;         mov       dl,1                     ; po‡et rovin k testov n¡
         jmp       short Tst1EG82

Tst1EGA1 ENDP

; -----------------------------------------------------------------------------
;        12: test znaku AX v grafick‚m m¢du EGA 2 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1EGA2 PROC      NEAR

         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       dl,2
         jmp       short Tst1EG82

Tst1EGA2 ENDP

; -----------------------------------------------------------------------------
;        13: test znaku AX v grafick‚m m¢du EGA 4 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1EGA4 PROC      NEAR

         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       dl,4
         jmp       short Tst1EG82

Tst1EGA4 ENDP

; -----------------------------------------------------------------------------
;        14: test znaku AX v grafick‚m m¢du EGA 8 (segment ES, ZY=je OK)
; -----------------------------------------------------------------------------

Tst1EGA8 PROC      NEAR

         push      dx
         xor       dx,dx
         call      Disp1Chr
         mov       dl,8

Tst1EG82:push      cx
         push      ax
         mov       ch,dl                    ; po‡et rovin k testov n¡
         mov       cl,0                     ; ukazatel ‡¡sla roviny

         mov       dx,3ceh
         mov       al,4
         out       dx,al                    ; volba registru ‡tec¡ roviny
         inc       dx
Tst1EG83:mov       al,cl                    ; ‡¡slo roviny ke ‡ten¡
         out       dx,al                    ; nastaven¡ ‡tec¡ roviny

         mov       al,es:[0]                ; ‡ten¡ bajtu z roviny
         shr       ah,1                     ; m  b˜t rovina nastavena ?
         jnc       Tst1EG84                 ; nem  b˜t nastavena
         not       al                       ; negace - bude 0
Tst1EG84:cmp       al,0                     ; je obsah roviny spr vn˜ ?
         jne       Tst1EG88                 ; obsah roviny nen¡ spr vn˜

         inc       cx                       ; zv˜¨en¡ ukazatele ‡¡sla roviny
         cmp       cl,ch                    ; jsou ji‘ v¨echny roviny ?
         jne       Tst1EG83                 ; test dal¨¡ roviny
                                            ; jinak ZY=OK

Tst1EG88:pop       ax
         pop       cx
         pop       dx
         ret

Tst1EGA8 ENDP

; -----------------------------------------------------------------------------
;        z pis ©etˆzce znak– vyst©edˆnˆ
; -----------------------------------------------------------------------------

DispCent PROC      NEAR

         push      dx
         mov       dl,cs:[Pozic]            ; po‡et pozic na © dek
         sub       dl,cs:[si]               ; zbyl˜ po‡et na okraje
         shr       dl,1                     ; po‡ te‡n¡ pozice
         call      DispStr                  ; zobrazen¡ ©etˆzce
         pop       dx
         inc       dh                       ; zv˜¨en¡ © dku
         ret

DispCent ENDP

; -----------------------------------------------------------------------------
;        z pis ©etˆ‘ce znak– CS:SI od pozice DX, barva AH (1. bajt = d‚lka)
; -----------------------------------------------------------------------------

DispStr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ zobrazen¡ textu

         mov       ch,0
         mov       cl,cs:[si]               ; d‚lka ©etˆzce
         inc       si                       ; za‡ tek textu
         jcxz      DispStr2                 ; nen¡ text
DispStr1:mov       al,cs:[si]               ; znak k zobrazen¡
         inc       si                       ; zv˜¨en¡ ukazatele textu
         call      Disp1Chr                 ; zobrazen¡ znaku
         loop      DispStr1                 ; zobrazen¡ dal¨¡ho znaku

; ------ n vrat registr–

DispStr2:pop       cx
         pop       ax
         ret

DispStr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ CL mezer
; -----------------------------------------------------------------------------

DispSpc  PROC      NEAR

         push      ax
         mov       al," "
         call      DispChr
         pop       ax
         ret

DispSpc  ENDP

; -----------------------------------------------------------------------------
;        z pis CL znak– AX na pozici DX (opakov n¡m z pisu)
; -----------------------------------------------------------------------------

DispMChr PROC      NEAR

         cmp       byte ptr cs:[GrafMod],0
         je        DispChr                  ; textov˜ m¢d
         push      cx
         mov       ch,0
         jcxz      DispMCh3
DispMCh2:call      Disp1Chr
         loop      DispMCh2
DispMCh3:pop       cx
         ret

DispMChr ENDP

; -----------------------------------------------------------------------------
;        z pis jednoho znaku AX na pozici DX
; -----------------------------------------------------------------------------

Disp1Chr PROC      NEAR

         push      cx
         mov       cl,1
         call      DispChr
         pop       cx
         ret

Disp1Chr ENDP

; -----------------------------------------------------------------------------
;        z pis znaku AX na pozici DX - po‡et CL (BIOS)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ test, zda je vlastn¡ obsluha displeje

         mov       ch,0
         test      byte ptr cs:[Params],bit0 ; je vlastn¡ obsluha displeje ?
         jnz       DispChr3                 ; je vlastn¡ obsluha displeje

; ------ nastaven¡ pozice kurzoru

         call      SetKurz                  ; nastaven¡ pozice kurzoru

; ------ z pis znaku na pozici kurzoru

         jcxz      DispChr2                 ; nejsou znaky k zobrazen¡
         mov       bl,ah                    ; barva
         mov       ah,9
         mov       bh,cs:[AktPage]          ; aktu ln¡ videostr nka
         call      Int10A                   ; z pis znaku

; ------ n vrat registr–

DispChr2:pop       cx
         pop       bx
         pop       ax
         add       dl,cl                    ; zv˜¨en¡ pozice
         ret

; ------ vlastn¡ obsluha displeje

DispChr3:push      di
         push      es
         push      ax
         mov       al,cs:[pozic]            ; po‡et pozic na © dek
         mul       dh                       ; p©epo‡et © dku na pozice
         add       al,dl                    ; p©i‡ten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset ve videopamˆti
         xchg      ax,di                    ; DI <- adresa ve videopamˆti
         mov       es,cs:[SegmVRAM]         ; segment videopamˆti
         cld
         pop       ax
         rep       stosw                    ; ulo‘en¡ znaku
         pop       es
         pop       di
         jmp       short DispChr2

DispChr  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      dx
         mov       dh,cs:[Radku]            ; © dek "za rohem"
         mov       dl,0
         call      SetKurz                  ; nastaven¡ pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice kurzoru DX
; -----------------------------------------------------------------------------

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,cs:[AktPage]          ; aktu ln¡ videostr nka
         mov       ah,2
         call      Int10A                   ; nastaven¡ pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ videostr nky AL
; -----------------------------------------------------------------------------

SetPage  PROC      NEAR

         push      ax
         mov       ah,5
         call      Int10A                   ; nastaven¡ videostr nky
         mov       cs:[AktPage],al          ; aktu ln¡ str nka
         pop       ax
         ret

SetPage  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ polo‘ky BX aktivn¡ karty -> BX
; -----------------------------------------------------------------------------

GetPol   PROC      NEAR

         push      ax
         push      si

         mov       si,cs:[ModTTab0]         ; adresa definice karty
         cmp       bl,cs:[si-1]             ; je v z kladn¡ definici ?
         jae       GetPol4                  ; nen¡ v z kladn¡ definici

         cmp       bl,8
         jb        GetPol3
         add       bl,5
GetPol3: mov       si,offset CardDef0
         jmp       short GetPol5

GetPol4: sub       bl,cs:[si-1]             ; offset v t‚to definici
GetPol5: shl       bx,1
         shl       bx,1
         shl       bx,1
         add       bx,si                    ; adresa definice polo‘ky

         pop       si
         pop       ax
         ret

GetPol   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ adresy karty AX -> SI
; -----------------------------------------------------------------------------

GetCard  PROC      NEAR

         push      ax
         push      cx

         mov       si,offset CardDef        ; tabulka definice karet
         xchg      ax,cx
         jcxz      GetCard4
GetCard2:mov       ah,0
         mov       al,cs:[si]               ; d‚lka textu jm‚na karty
         inc       si                       ; za‡ tek textu jm‚na karty
         add       si,ax                    ; adresa hledan‚ho vzorku
         mov       al,cs:[si]               ; d‚lka textu vzorku
         inc       si                       ; za‡ tek textu vzorku
         add       si,ax                    ; konec textu
         mov       al,cs:[si]               ; po‡et definovan˜ch videom¢d–
         inc       si
         sub       al,cs:[si]               ; po‡et skute‡nˆ definovan˜ch m¢d–
         inc       si
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; velikost tabulky
         add       si,ax                    ; adresa dal¨¡ karty
         loop      GetCard2                 ; nalezen¡ adresy karty

GetCard4:pop       cx
         pop       ax
         ret

GetCard  ENDP

; -----------------------------------------------------------------------------
;        detekce videokarty VGA
; -----------------------------------------------------------------------------

DetVGA   PROC      NEAR

; ------ p©¡prava registr–

         push      cs
         pop       es
         mov       ax,0c000h
         mov       ds,ax
         cld

; ------ test, zda byla karta EGA/VGA

         cmp       byte ptr cs:[Card],7
         je        DetVGA9                  ; 3270 PC
         cmp       byte ptr cs:[Card],5
         jb        DetVGA9                  ; nen¡ EGA/VGA

; ------ adresa prvn¡ polo‘ky

         mov       bx,8
DetVGA3: mov       ax,bx
         call      GetCard                  ; adresa prvn¡ karty

         push      si
         mov       di,si
         mov       ah,0
         mov       al,cs:[di]
         inc       di
         add       di,ax                    ; za‡ tek vzorku
         mov       ch,0
         mov       cl,cs:[di]               ; d‚lka vzorku
         inc       di                       ; za‡ tek textu vzorku
         xor       si,si                    ; po‡ tek k hled n¡

DetVGA4: push      si
         push      di
         push      cx

DetVGA5: lodsb
         cmp       al,"a"
         jb        DetVGA6
         cmp       al,"z"
         ja        DetVGA6
         sub       al,32                    ; konverze na velk‚ p¡smeno
DetVGA6: scasb                              ; porovn n¡ se vzorkem
         loope     DetVGA5                  ; dal¨¡ znak

         pop       cx
         pop       di
         pop       si

         je        DetVGA7                  ; vzorek nalezen
         inc       si                       ; zv˜¨en¡ adresy v pamˆti
         cmp       si,400h
         jb        DetVGA4                  ; dal¨¡ test
         or        si,si                    ; p©¡znak NZ

DetVGA7: pop       si
         jne       DetVGA8                  ; vzorek nenalezen
         mov       cs:[CardTyp],bx          ; up©esnˆn¡ typu karty
         jmp       short DetVGA9

DetVGA8: inc       bx                       ; zv˜¨en¡ ‡¡sla karty
         cmp       bx,cs:[MaxCard]          ; jsou ji‘ v¨echny karty ?
         jb        DetVGA3                  ; nejsou - test dal¨¡ karty

DetVGA9: ret

DetVGA   ENDP

; -----------------------------------------------------------------------------
;                       Detekce videokarty
; -----------------------------------------------------------------------------

DetCard  PROC      NEAR

         mov       ah,0fh
         call      Int10P
         and       al,7fh                   ; dotaz na videom¢d
         cmp       al,7                     ; je monochromatick˜ videom¢d ?
         je        DetCard5                 ; je monochromatick˜ videom¢d
                                          ;* barevn˜ re‘im - rozpozn n¡ EGA/VGA
         call      DetCard8                 ; test karet EGA/VGA
         jc        DetCard2                 ; nen¡ karta EGA/VGA
DetCard1:call      DetCardA                 ; rozli¨en¡ karet EGA/VGA
         ret
DetCard2:                                 ;* rozpozn n¡ karty PC3270
         call      DetCardP                 ; detekce karty PC3270
         jc        DetCard3                 ; nen¡ karta PC3270
         mov       byte ptr cs:[Card],7     ; je videokarta PC3270
         ret

DetCard3:                                 ;* rozpozn n¡ karet CGA/MCGA
         mov       byte ptr cs:[Card],2   ; p©ednastaven¡ karty CGA
         call      DetCardG                 ; test karty MCGA
         jc        DetCard4                 ; nen¡ karta MCGA
         mov       byte ptr cs:[Card],4     ; je karta MCGA
DetCard4:ret

DetCard5:                                 ;* monochrom. re‘im - test EGA/VGA
         call      DetCard8                 ; test karty EGA/VGA
         jnc       DetCard1                 ; je EGA/VGA - rozli¨en¡ EGA a VGA
                                          ;* test karty Hercules/MDA
         call      DetCardJ                 ; test karty Hercules
         jc        DetCard6                 ; nen¡ karta Hercules
         mov       byte ptr cs:[Card],1     ; je karta Hercules
         ret
DetCard6:                                 ;* test karty CGA (test pamˆti)
         mov       si,0b800h                ; segment videopamˆti CGA
         mov       es,si                    ; segment videopamˆti CGA
         xor       si,si                    ; po‡ te‡n¡ adresa videopamˆti CGA
         mov       ax,es:[si]               ; p–vodn¡ slovo z videopamˆti
         not       ax                       ; inverze
         not       word ptr es:[si]         ; inverze i p–vodn¡ho slova
         nop
         nop
         cmp       ax,es:[si]               ; je tam pamˆŸ RAM ?
         jne       DetCard7                 ; nen¡ pamˆŸ VRAM
         mov       byte ptr cs:[Card],2     ; je karta CGA
DetCard7:ret

DetCard8:                                 ;* test karty EGA/VGA
         mov       ax,1200h
         mov       bl,10h                   ; podslu‘ba poskytnut¡ parametr–
         mov       bh,0ffh                  ; p©ednastaven¡
         mov       cl,0fh                   ; p©ednastaven¡
         call      Int10P                   ; dotaz na EGA kartu
         cmp       cl,0ch
         jge       DetCard9                 ; nen¡ karta EGA
         cmp       bh,1
         jg        DetCard9                 ; nen¡ karta EGA
         cmp       bl,3
         jg        DetCard9                 ; nen¡ karta EGA
         mov       byte ptr cs:[EgaVga],1   ; p©¡znak karty EGA/VGA
         clc                                ; p©¡znak - je karta EGA
         ret
DetCard9:mov       byte ptr cs:[EgaVga],0   ; zru¨en¡ p©¡znaku EGA/VGA
         stc                                ; p©¡znak - nen¡ karta EGA
         ret

DetCardA:                                 ;* rozli¨en¡ karet EGA/VGA
         mov       byte ptr cs:[Card],5     ; p©ednastaven¡ EGA
         call      DetCardG                 ; test karty VGA
         jnc       DetCardB                 ; je karta VGA
         mov       bx,0c000h                ; segment s ROM VGA
         mov       es,bx                    ; segment s ROM VGA
         mov       bx,39h                   ; adresa textu "Z449"
         cmp       word ptr es:[bx],"Z4"    ; je text "Z4" ?
         jne       DetCardC                 ; nen¡ karta VGA
         cmp       word ptr es:[bx+2],"49"  ; je text "49" ?
         jne       DetCardC                 ; nen¡ karta VGA
DetCardB:mov       byte ptr cs:[Card],6     ; je karta VGA
DetCardC:ret

DetCardG:                                 ;* test karty VGA
         mov       ax,1a00h
         call      Int10P                   ; dotaz na po‡et linek na znak
         cmp       al,1ah                   ; je funkce obsluhovan  ?
         jne       DetCardI                 ; funkce nen¡ obsluhovan 
         cmp       bl,7                     ; je 7 linek na znak ?
         je        DetCardH                 ; je karta OK
         cmp       bl,8
         je        DetCardH                 ; je karta OK
         cmp       bl,11
         jb        DetCardI                 ; nen¡ karta
         cmp       bl,12
         ja        DetCardI                 ; nen¡ karta
DetCardH:clc                                ; p©¡znak - je karta
         ret
DetCardI:stc                                ; p©¡znak - nen¡ karta
         ret

DetCardJ:                                 ;* test karty Hercules
         mov       dx,03bah                 ; stavov˜ port karty
         xor       bl,bl                    ; ‡¡ta‡ doby impulsu
         in        al,dx                    ; po‡ te‡n¡ stav
         and       al,80h                   ; sign l zpˆtn‚ho bˆhu
         mov       ah,al                    ; £schova stavu registru
         mov       cx,8000h                 ; maxim ln¡ doba testu
DetCardK:                                 ;* ‡ek n¡ na zmˆnu stavu bitu 7
         in        al,dx                    ; ‡ten¡ stavov‚ho registru
         and       al,80h                   ; sign l zpˆtn‚ho bˆhu
         cmp       al,ah                    ; byla zmˆna stavu sign lu ?
         je        DetCardL                 ; nebyla zmˆna stavu sign lu
         inc       bl                       ; ‡¡ta‡ d‚lky impulsu
         cmp       bl,10                    ; je minim ln¡ doba impulsu ?
         jae       DetCardM                 ; impuls je dostate‡nˆ dlouh˜
DetCardL:loop      DetCardK                 ; dal¨¡ test impulsu
         stc                                ; p©¡znak - nen¡ karta Hercules
         ret

DetCardM:                                 ;* ‡ek n¡ na bity 5,4 -> 01
         mov       cx,8000h                 ; maxim ln¡ doba testu
DetCardN:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         and       al,30h
         cmp       al,10h
         jne       DetCardO                 ; je pouze karta MDA
         loop      DetCardN                 ; dal¨¡ test
         mov       al,2                     ; p©¡znak - je karta Hercules
         clc
         ret
DetCardO:mov       al,1                     ; p©¡znak - je karta MDA
         clc
         ret

DetCardP:                                 ;* test videokarty PC3270
         mov       al,6
         xor       cx,cx                    ; CX <- 0
         xor       dx,dx
         mov       ah,30h
         call      Int10P
         mov       ax,cx
         or        ax,dx
         jz        DetCardR                 ; nen¡ karta PC3270
         push      ds
         mov       ds,cx                    ; segment
         mov       bx,dx                    ; offset
         mov       al,ds:[bx+2]
         pop       ds
         or        al,al
         jz        DetCardQ                 ; je karta PC3270
         cmp       al,2
         jne       DetCardR                 ; nen¡ karta PC3270
DetCardQ:mov       dx,188h
         in        al,dx
         test      al,4
         jz        DetCardR                 ; nen¡ karta PC3270
         clc                                ; p©¡znak - je karta PC3270
         ret
DetCardR:stc                                ; p©¡znak - nen¡ karta PC3270
         ret

DetCard  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou v¨ech registr–
; -----------------------------------------------------------------------------

Int10A   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         call      Int10P

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Int10A   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

Int10P   PROC      NEAR

         pushf
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

Int10P   ENDP

; *****************************************************************************
;
;                             Data
;
; *****************************************************************************
;þ
Params   db        bit0                     ; parametry
                                            ;   bit 0: 1=vlastn¡ obsluha displ.
                                            ;   bit 1: 1=u‘ivat. m¢d detekov n

InitMod  db        3                        ; inicializa‡n¡ videom¢d
         db        0                        ; povel pro inicializaci displeje

Card     db        0                        ; detekovan˜ typ videokarty
                                            ; 0: nezn m  videokarta
                                            ; 1: Hercules
                                            ; 2: CGA
                                            ; 3: PCjr
                                            ; 4: MCGA
                                            ; 5: EGA
                                            ; 6: VGA
                                            ; 7: 3270 PC

CardTyp  dw        0                        ; pracovn¡ typ videokarty (up©esnˆn˜)

EgaVga   db        0                        ; p©¡znak videokarty EGA/VGA

; ------ detekovan‚ parametry videokarty

Pozic    db        80                       ; aktu ln¡ po‡et pozic na © dek
         db        0                        ; HIGH
Radku    db        25                       ; aktu ln¡ po‡et © dk–
         db        0                        ; HIGH
SegmVRAM dw        0b800h                   ; segment videopamˆti (0=nezn m˜)
MemSize  dw        0                        ; velikost bloku pamˆti (0=65 KB)
AktMod   db        3                        ; aktu ln¡ videom¢d
BazePort dw        3d4h                     ; b zov  ©¡dic¡ adresa displeje
DelkaPg  dw        2000h                    ; d‚lka videostr nky (0=65536)
GrafMod  db        1                        ; p©¡znak grafick‚ho videom¢du
AktPage  db        0                        ; aktivn¡ videostr nka
Barev    dw        16                       ; po‡et barev (1=MONO)
NumPages db        4                        ; po‡et videostr nek
LinChr   db        8                        ; po‡et linek na znak
Vertik   dw        0                        ; vertik ln¡ rozli¨en¡
ModVRAM  db        0                        ; m¢d videopamˆti
                                            ;    0 = nezn m˜
                                            ;    1 = text prokl dan˜
                                            ;    2 = text sekven‡n¡
                                            ;    3 = CGA 1 (2 barvy)
                                            ;    4 = CGA 2 (4 barvy)
                                            ;    5 = CGA 4 (16 barev)
                                            ;    6 = CGA 8 (256 barev)
                                            ;    7 = MCGA 1 (2 barvy)
                                            ;    8 = MCGA 2 (4 barvy)
                                            ;    9 = MCGA 4 (16 barev)
                                            ;   10 = MCGA 8 (256 barev)
                                            ;   11 = EGA 1 (2 barvy)
                                            ;   12 = EGA 2 (4 barvy)
                                            ;   13 = EGA 4 (16 barev)
                                            ;   14 = EGA 8 (256 barev)

ModTxtT  db        7,'       '
         db        7,' TXT-P '
         db        7,' TXT-S '
         db        7,' CGA-1 '
         db        7,' CGA-2 '
         db        7,' CGA-4 '
         db        7,' CGA-8 '
         db        7,' MCG-1 '
         db        7,' MCG-2 '
         db        7,' MCG-4 '
         db        7,' MCG-8 '
         db        7,' EGA-1 '
         db        7,' EGA-2 '
         db        7,' EGA-4 '
         db        7,' EGA-8 '

; ------ texty

TestTxt  db        29,'TEST VIDEOMODU GRAFICKE KARTY'
VerTxt   db        10,'verze 1.01'
LicTxt   db        20,'(c) Miroslav Nemecek'

CardTxt  db        22,'detekovana videokarta '

Help1Txt db        24,' F4 automaticka detekce '
Help2Txt db        19,' <- volba karty -> '

TextTxt  db        9,'    text '
GrafTxt  db        9,'  GRAFIKA'

MonoTxt  db        7,'   MONO'

Adr1txt  db        4,'B800'
Adr2txt  db        4,'B000'
Adr3txt  db        4,'A000'
Adr4txt  db        4,'  - '

TModMod  db        20,'Aktualni videomod : '
TModHor  db        20,'Horiz. rozliseni  : '
TModHor1 db        6,' pozic'
TModHor2 db        5,' bodu'
TModVer  db        20,'Vertik. rozliseni : '
TModVer1 db        6,' radku'
TModVer2 db        6,' linek'
TModBar  db        20,'Pocet barev       : '
TModBar1 db        4,'MONO'
TModPag  db        20,'Pocet videostranek: '
TModAdr  db        20,'Adresa videopameti: '
TModNul  db        0                        ; pr zdn˜ text

ModNadp  db        80,'ÌÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍËÍÍÍÍÍËÍÍÍÍËÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹'
         db           'ºVideomodºGRAF/Textº Horiz.ºVertik.ºBarevºStranºAdr.º Typ º                    º'
         db        80,'ÌÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÊÍÍÍÍÍÊÍÍÍÍÊÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹'

ModNad0  db                 70,'      -        -       -      -    -     -     -           -          '

;        db           'º  0  00h    text      40      25     16    8   B800 TXT 1    T 40x25/16       º'
;        db           'º127  7Fh  GRAFIKA   2320    1480    256   12   A000 MCG 8    G 1024x2048/256  º'


; Struktura definice karty:
;     0: (1) d‚lka textu jm‚na karty (0=konec)
;     1: (x) text jm‚na karty
;     x: (1) d‚lka textu k identifikaci karty
;        (x) text k identifikaci karty
;        (1) po‡et definovan˜ch videom¢d– celkem
;        (1) po‡et p©eddefinovan˜ch videom¢d– u z kladn¡ karty (p©eskakuj¡
;                                                    se videom¢dy 8 a‘ 12)
;
; Struktura tabulky videom¢d–:
;     0: (1) ‡¡slo videom¢du
;     1: (1) parametry (0=parametry m¢du nezn m‚)
;              bit 0 a‘ bit 1: adresa 1=A000h, 2=B000h, 3=B8000h
;              bit 2 (=4): 1=grafick˜ m¢d, 0=textov˜
;              bit 4 a‘ 7: m¢d videopamˆti
;                            0=nezn m˜
;                            1=text prokl dan˜, 2=text sekven‡n¡
;                            3=CGA 1, 4=CGA 2, 5=CGA 4, 6=CGA 8
;                            7=MCGA1, 8=MCGA2, 9=MCGA4, 10=MCGA8
;                            11=EGA1, 12=EGA2, 13=EGA4, 14=EGA8
;     2: (1) po‡et barev-1 (0=MONO)
;     3: (1) po‡et videostr nek
;     4: (2) horizont ln¡ rozli¨en¡
;     6: (2) vertik ln¡ rozli¨en¡

ModTTab  dw        CardDef                  ; adresa definice aktivn¡ karty
ModTTab0 dw        CardDef0                 ; adresa za‡ tku polo‘ek karty
AktCard  dw        0                        ; ‡¡slo aktivn¡ karty
MaxCard  dw        51                       ; celkov˜ po‡et karet

ModTTop  dw        0                        ; po‡ te‡n¡ zobrazen  polo‘ka
ModTAkt  dw        3                        ; aktivn¡ polo‘ka s kurzorem
ModTNum  dw        128                      ; celkov˜ po‡et polo‘ek
ModTDisp dw        25-10                    ; po‡et zobrazen˜ch polo‘ek

CardDef  label     byte                     ; definice karet

; ------ 0: nezn m  videokarta

         db        18,'nedefinovana karta'  ; n zev karty
         db        0                        ; text k identifikaci karty
         db        128,0                    ; po‡et videom¢d– celkem, odk zan‚

CardDef0:db        0,3+1*X,15,8             ; 0: text 40x25/16
         dw        40,25

         db        1,3+1*X,15,8             ; 1: text 40x25/16
         dw        40,25

         db        2,3+1*X,15,8             ; 2: text 80x25/16
         dw        80,25

         db        3,3+1*X,15,8             ; 3: text 80x25/16
         dw        80,25

         db        4,3+4+4*X,3,2            ; 4: grafika 320x200/4
         dw        320,200

         db        5,3+4+4*X,3,2            ; 5: grafika 320x200/4
         dw        320,200

         db        6,3+4+3*X,1,2            ; 6: grafika 640x200/2
         dw        640,200

         db        7,2+1*X,0,8              ; 7: text 80x25/MONO
         dw        80,25

         db        8,2+4+5*X,15,1           ; 8: grafika 160x200/16
         dw        160,200

         db        9,2+4+5*X,15,1           ; 9: grafika 320x200/16
         dw        320,200

         db        10,2+4+4*X,3,1           ; 10: grafika 640x200/4
         dw        640,200

         db        11,0,0,0,0,0,0,0         ; 11: intern¡
         db        12,0,0,0,0,0,0,0         ; 12: intern¡

         db        13,1+4+13*X,15,8         ; 13: grafika 320x200/16
         dw        320,200

         db        14,1+4+13*X,15,4         ; 14: grafika 640x200/16
         dw        640,200

         db        15,1+4+12*X,0,2          ; 15: grafika 640x350/2
         dw        640,350

         db        16,1+4+13*X,15,2         ; 16: grafika 640x350/16
         dw        640,350

         db        17,1+4+11*X,1,1          ; 17: grafika 640x480/2
         dw        640,480

         db        18,1+4+13*X,15,1         ; 18: grafika 640x480/16
         dw        640,480

         db        19,1+4+10*X,255,1        ; 19: grafika 320x200/256
         dw        320,200

         db        20,0,0,0,0,0,0,0         ; 20
         db        21,0,0,0,0,0,0,0         ; 21
         db        22,0,0,0,0,0,0,0         ; 22
         db        23,0,0,0,0,0,0,0         ; 23
         db        24,0,0,0,0,0,0,0         ; 24
         db        25,0,0,0,0,0,0,0         ; 25
         db        26,0,0,0,0,0,0,0         ; 26
         db        27,0,0,0,0,0,0,0         ; 27
         db        28,0,0,0,0,0,0,0         ; 28
         db        29,0,0,0,0,0,0,0         ; 29
         db        30,0,0,0,0,0,0,0         ; 30
         db        31,0,0,0,0,0,0,0         ; 31
         db        32,0,0,0,0,0,0,0         ; 32
         db        33,0,0,0,0,0,0,0         ; 33
         db        34,0,0,0,0,0,0,0         ; 34
         db        35,0,0,0,0,0,0,0         ; 35
         db        36,0,0,0,0,0,0,0         ; 36
         db        37,0,0,0,0,0,0,0         ; 37
         db        38,0,0,0,0,0,0,0         ; 38
         db        39,0,0,0,0,0,0,0         ; 39
         db        40,0,0,0,0,0,0,0         ; 40
         db        41,0,0,0,0,0,0,0         ; 41
         db        42,0,0,0,0,0,0,0         ; 42
         db        43,0,0,0,0,0,0,0         ; 43
         db        44,0,0,0,0,0,0,0         ; 44
         db        45,0,0,0,0,0,0,0         ; 45
         db        46,0,0,0,0,0,0,0         ; 46
         db        47,0,0,0,0,0,0,0         ; 47
         db        48,0,0,0,0,0,0,0         ; 48
         db        49,0,0,0,0,0,0,0         ; 49
         db        50,0,0,0,0,0,0,0         ; 50
         db        51,0,0,0,0,0,0,0         ; 51
         db        52,0,0,0,0,0,0,0         ; 52
         db        53,0,0,0,0,0,0,0         ; 53
         db        54,0,0,0,0,0,0,0         ; 54
         db        55,0,0,0,0,0,0,0         ; 55
         db        56,0,0,0,0,0,0,0         ; 56
         db        57,0,0,0,0,0,0,0         ; 57
         db        58,0,0,0,0,0,0,0         ; 58
         db        59,0,0,0,0,0,0,0         ; 59
         db        60,0,0,0,0,0,0,0         ; 60
         db        61,0,0,0,0,0,0,0         ; 61
         db        62,0,0,0,0,0,0,0         ; 62
         db        63,0,0,0,0,0,0,0         ; 63
         db        64,0,0,0,0,0,0,0         ; 64
         db        65,0,0,0,0,0,0,0         ; 65
         db        66,0,0,0,0,0,0,0         ; 66
         db        67,0,0,0,0,0,0,0         ; 67
         db        68,0,0,0,0,0,0,0         ; 68
         db        69,0,0,0,0,0,0,0         ; 69
         db        70,0,0,0,0,0,0,0         ; 70
         db        71,0,0,0,0,0,0,0         ; 71
         db        72,0,0,0,0,0,0,0         ; 72
         db        73,0,0,0,0,0,0,0         ; 73
         db        74,0,0,0,0,0,0,0         ; 74
         db        75,0,0,0,0,0,0,0         ; 75
         db        76,0,0,0,0,0,0,0         ; 76
         db        77,0,0,0,0,0,0,0         ; 77
         db        78,0,0,0,0,0,0,0         ; 78
         db        79,0,0,0,0,0,0,0         ; 79
         db        80,0,0,0,0,0,0,0         ; 80
         db        81,0,0,0,0,0,0,0         ; 81
         db        82,0,0,0,0,0,0,0         ; 82
         db        83,0,0,0,0,0,0,0         ; 83
         db        84,0,0,0,0,0,0,0         ; 84
         db        85,0,0,0,0,0,0,0         ; 85
         db        86,0,0,0,0,0,0,0         ; 86
         db        87,0,0,0,0,0,0,0         ; 87
         db        88,0,0,0,0,0,0,0         ; 88
         db        89,0,0,0,0,0,0,0         ; 89
         db        90,0,0,0,0,0,0,0         ; 90
         db        91,0,0,0,0,0,0,0         ; 91
         db        92,0,0,0,0,0,0,0         ; 92
         db        93,0,0,0,0,0,0,0         ; 93
         db        94,0,0,0,0,0,0,0         ; 94
         db        95,0,0,0,0,0,0,0         ; 95
         db        96,0,0,0,0,0,0,0         ; 96
         db        97,0,0,0,0,0,0,0         ; 97
         db        98,0,0,0,0,0,0,0         ; 98
         db        99,0,0,0,0,0,0,0         ; 99
         db        100,0,0,0,0,0,0,0        ; 100
         db        101,0,0,0,0,0,0,0        ; 101
         db        102,0,0,0,0,0,0,0        ; 102
         db        103,0,0,0,0,0,0,0        ; 103
         db        104,0,0,0,0,0,0,0        ; 104
         db        105,0,0,0,0,0,0,0        ; 105
         db        106,0,0,0,0,0,0,0        ; 106
         db        107,0,0,0,0,0,0,0        ; 107
         db        108,0,0,0,0,0,0,0        ; 108
         db        109,0,0,0,0,0,0,0        ; 109
         db        110,0,0,0,0,0,0,0        ; 110
         db        111,0,0,0,0,0,0,0        ; 111
         db        112,0,0,0,0,0,0,0        ; 112
         db        113,0,0,0,0,0,0,0        ; 113
         db        114,0,0,0,0,0,0,0        ; 114
         db        115,0,0,0,0,0,0,0        ; 115
         db        116,0,0,0,0,0,0,0        ; 116
         db        117,0,0,0,0,0,0,0        ; 117
         db        118,0,0,0,0,0,0,0        ; 118
         db        119,0,0,0,0,0,0,0        ; 119
         db        120,0,0,0,0,0,0,0        ; 120
         db        121,0,0,0,0,0,0,0        ; 121
         db        122,0,0,0,0,0,0,0        ; 122
         db        123,0,0,0,0,0,0,0        ; 123
         db        124,0,0,0,0,0,0,0        ; 124
         db        125,0,0,0,0,0,0,0        ; 125
         db        126,0,0,0,0,0,0,0        ; 126
         db        127,0,0,0,0,0,0,0        ; 127

; ------ 1: Hercules

         db        13,'Hercules, MDA'       ; n zev karty
         db        0                        ; text k identifikaci karty
         db        1,0                      ; po‡et videom¢d– celkem, odk zan‚

         db        7,2+1*X,0,1              ; 7: text 80x25/MONO
         dw        80,25

; ------ 2: CGA

         db        3,'CGA'                  ; n zev karty
         db        0                        ; text k identifikaci karty
         db        7,0                      ; po‡et videom¢d– celkem, odk zan‚

         db        0,3+1*X,15,8             ; 0: text 40x25/16
         dw        40,25

         db        1,3+1*X,15,8             ; 1: text 40x25/16
         dw        40,25

         db        2,3+1*X,15,4             ; 2: text 80x25/16
         dw        80,25

         db        3,3+1*X,15,4             ; 3: text 80x25/16
         dw        80,25

         db        4,3+4+4*X,3,1            ; 4: grafika 320x200/4
         dw        320,200

         db        5,3+4+4*X,3,1            ; 5: grafika 320x200/4
         dw        320,200

         db        6,3+4+3*X,1,1            ; 6: grafika 640x200/2
         dw        640,200

; ------ 3: PCjr

         db        4,'PCjr'                 ; n zev karty
         db        0                        ; text k identifikaci karty
         db        10,0                     ; po‡et videom¢d– celkem, odk zan‚

         db        0,3+1*X,15,8             ; 0: text 40x25/16
         dw        40,25

         db        1,3+1*X,15,8             ; 1: text 40x25/16
         dw        40,25

         db        2,3+1*X,15,4             ; 2: text 80x25/16
         dw        80,25

         db        3,3+1*X,15,4             ; 3: text 80x25/16
         dw        80,25

         db        4,3+4+4*X,3,1            ; 4: grafika 320x200/4
         dw        320,200

         db        5,3+4+4*X,3,1            ; 5: grafika 320x200/4
         dw        320,200

         db        6,3+4+3*X,1,1            ; 6: grafika 640x200/2
         dw        640,200

         db        8,2+4+5*X,15,1           ; 8: grafika 160x200/16
         dw        160,200

         db        9,2+4+5*X,15,1           ; 9: grafika 320x200/16
         dw        320,200

         db        10,2+4+4*X,3,1           ; 10: grafika 640x200/4
         dw        640,200

; ------ 4: MCGA

         db        4,'MCGA'                 ; n zev karty
         db        0                        ; text k identifikaci karty
         db        9,7                      ; po‡et videom¢d– celkem, odk zan‚

         db        17,1+4+11*X,1,1          ; 17: grafika 640x480/2
         dw        640,480

         db        19,1+4+10*X,255,1        ; 19: grafika 320x200/256
         dw        320,200

; ------ 5: EGA

         db        3,'EGA'                  ; n zev karty
         db        0                        ; text k identifikaci karty
         db        12,12                    ; po‡et videom¢d– celkem, odk zan‚

; ------ 6: VGA

         db        3,'VGA'                  ; n zev karty
         db        0                        ; text k identifikaci karty
         db        15,15                    ; po‡et videom¢d– celkem, odk zan‚

; ------ 7: 3270 PC

         db        7,'3270 PC'              ; n zev karty
         db        0                        ; text k identifikaci karty
         db        8,7                      ; po‡et videom¢d– celkem, odk zan‚

         db        48,2+4+3,1,1
         dw        720,350

; ------ Ahead B

         db        11,'Ahead B VGA'
         db        7,'AHEAD B'              ; text k identifikaci karty
         db        21,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        96,1+4+10*X,255,1
         dw        640,400

         db        97,1+4+10*X,255,1
         dw        640,480

         db        98,1+4+10*X,255,1
         dw        800,600

         db        99,1+4+10*X,255,1
         dw        1024,768

         db        106,1+4+13*X,15,1
         dw        800,600

         db        116,1+4+13*X,15,1
         dw        1024,768

; ------ Ahead System EGA2001

         db        19,'Ahead Syst. EGA2001'
         db        7,'AHEAD S'              ; text k identifikaci karty
         db        17,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        34,3+1*X,15,2
         dw        132,44

         db        35,3+1*X,15,4
         dw        132,25

         db        38,1+4+13*X,15,1
         dw        640,480

         db        80,2+1*X,0,4
         dw        132,25

         db        82,2+1*X,0,2
         dw        132,44

; ------ Allstar Peacock VGA

         db        19,'Allstar Peacock VGA'
         db        7,'ALLSTAR'              ; text k identifikaci karty
         db        21,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        34,3+1*X,15,2
         dw        132,43

         db        35,3+1*X,15,4
         dw        132,28

         db        36,3+1*X,15,4
         dw        132,25

         db        38,3+1*X,15,2
         dw        80,60

         db        41,1+4+13*X,15,1
         dw        800,600

         db        42,3+1*X,15,2
         dw        100,40

; ------ AST VGA Plus

         db        12,'AST VGA Plus'
         db        7,'AST VGA'              ; text k identifikaci karty
         db        21,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        84,3+1*X,15,2
         dw        132,43

         db        85,3+1*X,15,4
         dw        132,25

         db        88,1+4+13*X,15,1
         dw        800,600

         db        89,1+4+11*X,1,1
         dw        800,600

         db        94,1+4+10*X,255,1
         dw        640,400

         db        95,1+4+10*X,255,1
         dw        640,480

; ------ AT&T 6300

         db        13,'AT&T 6300 EGA'
         db        6,'AT&T 6'               ; text k identifikaci karty
         db        16,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        64,3+4+11*X,1,1
         dw        640,400

         db        65,3+4+13*X,15,1
         dw        640,200

         db        66,3+4+13*X,15,1
         dw        640,400

         db        72,3+4+11*X,1,1
         dw        640,400

; ------ AT&T VDC600

         db        15,'AT&T VDC600 EGA'
         db        6,'AT&T V'               ; text k identifikaci karty
         db        28,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        64,3+4+11*X,1,1
         dw        640,400

         db        66,3+4+13*X,15,1
         dw        640,400

         db        70,3+4+11*X,1,1
         dw        800,600

         db        71,3+4+13*X,15,1
         dw        800,600

         db        72,3+4+11*X,1,1
         dw        640,400

         db        84,3+1*X,15,2
         dw        132,43

         db        85,3+1*X,15,4
         dw        132,25

         db        86,2+1*X,0,2
         dw        123,43

         db        87,2+1*X,0,4
         dw        123,25

         db        88,1+4+13*X,15,1
         dw        800,600

         db        89,1+4+11*X,1,1
         dw        800,600

         db        94,1+4+10*X,255,1
         dw        640,400

         db        95,1+4+10*X,255,1
         dw        640,480

; ------ ATI EGA Wonder

         db        14,'ATI EGA Wonder'
         db        7,'ATI EGA'              ; text k identifikaci karty
         db        25,8                     ; po‡et videom¢d– celkem, odk zan‚

         db        8,3+1*X,15,4             ; 8:
         dw        132,25

         db        8,2+1*X,0,4              ; 8:
         dw        132,25

         db        13,1+4+13*X,15,8         ; 13: grafika 320x200/16
         dw        320,200

         db        14,1+4+13*X,15,4         ; 14: grafika 640x200/16
         dw        640,200

         db        15,1+4+11*X,0,2          ; 15: grafika 640x350/2
         dw        640,350

         db        16,1+4+13*X,15,2         ; 16: grafika 640x350/16
         dw        640,350

         db        17,1+4+11*X,1,1          ; 17: grafika 640x480/2
         dw        640,480

         db        18,1+4+13*X,15,1         ; 18: grafika 640x480/16
         dw        640,480

         db        35,3+1*X,15,4
         dw        132,25

         db        39,2+1*X,0,4
         dw        132,25

         db        51,3+1*X,15,2
         dw        132,44

         db        55,3+1*X,0,2
         dw        132,44

         db        51,1+4+13*X,15,1
         dw        640,480

         db        82,1+4+13*X,15,1
         dw        752,410

         db        83,1+4+13*X,15,1
         dw        800,560

         db        84,1+4+13*X,15,1
         dw        800,600

         db        88,3+1*X,15,4
         dw        80,33

; ------ ATI Prism Elite

         db        19,'ATI Prism Elite VGA'
         db        7,'ATI PRI'              ; text k identifikaci karty
         db        19,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        92,1+4+10*X,255,1
         dw        640,400

         db        93,1+4+10*X,255,1
         dw        640,480

         db        94,1+4+13*X,15,1
         dw        800,600

         db        95,1+4+13*X,15,1
         dw        1024,768

; ------ ATI VGA Wonder

         db        14,'ATI VGA Wonder'
         db        7,'ATI VGA'              ; text k identifikaci karty
         db        26,8                     ; po‡et videom¢d– celkem, odk zan‚

         db        8,3+1*X,15,4             ; 8:
         dw        132,25

         db        8,2+1*X,0,4              ; 8:
         dw        132,25

         db        13,1+4+13*X,15,8         ; 13: grafika 320x200/16
         dw        320,200

         db        14,1+4+13*X,15,4         ; 14: grafika 640x200/16
         dw        640,200

         db        15,1+4+11*X,0,2          ; 15: grafika 640x350/2
         dw        640,350

         db        16,1+4+13*X,15,2         ; 16: grafika 640x350/16
         dw        640,350

         db        17,1+4+11*X,1,1          ; 17: grafika 640x480/2
         dw        640,480

         db        18,1+4+13*X,15,1         ; 18: grafika 640x480/16
         dw        640,480

         db        19,1+4+10*X,255,1        ; 19: grafika 320x200/256
         dw        320,200

         db        84,1+4+13*X,15,1
         dw        800,600

         db        85,1+4+13*X,15,1
         dw        1024,768

         db        91,3+1*X,15,4
         dw        80,30

         db        97,1+4+10*X,255,1
         dw        640,400

         db        98,1+4+10*X,255,1
         dw        640,480

         db        99,1+4+10*X,255,1
         dw        800,600

         db        101,1+4+13*X,15,1
         dw        1024,768

         db        103,1+4+12*X,3,1
         dw        1024,768

         db        106,1+4+13*X,15,1
         dw        800,600

; ------ ATI VIP (ATI Super VGA ?)

         db        17,'ATI VIP Super VGA'
         db        7,'ATI VIP'              ; text k identifikaci karty
         db        29,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        35,3+1*X,15,4            ; OK
         dw        132,25

         db        39,2+1*X,0,4             ; OK
         dw        132,25

         db        51,3+1*X,15,2            ; OK
         dw        132,44

         db        55,2+1*X,0,2             ; OK ?
         dw        132,44

         db        83,1+4+13*X,15,1         ; OK
         dw        800,600
;         dw        800,560

         db        84,1+4+13*X,15,1         ; OK
         dw        800,600

         db        85,1+1*X,15,2
         dw        80,66

         db        88,3+1*X,15,4
         dw        80,33

         db        89,1+1*X,15,2
         dw        80,66

         db        97,1+4+10*X,255,1        ; OK
         dw        640,400

         db        98,1+4+10*X,255,1        ; OK
         dw        640,480

         db        99,1+4+10*X,255,1        ; OK
         dw        800,600

         db        101,1+4+12*X,0,1         ; OK
         dw        1024,768

         db        103,1+4+13*X,15,1         ; OK
         dw        1024,768

; ------ C&T chipset VGA (Chips and Technologies VGA) (ovˆ©eno dokumentac¡)

         db        20,'Chips & Technol. VGA'
         db        9,'CHIPS AND'            ; text k identifikaci karty
         db        24,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        96,3+1*X,15,4
         dw        132,25

         db        97,3+1*X,15,2
         dw        132,50

         db        106,1+4+13*X,15,1
         dw        800,600

         db        112,1+4+13*X,15,1
         dw        800,600

         db        114,1+4+13*X,15,1
         dw        1024,768

         db        120,1+4+10*X,255,1
         dw        640,400

         db        121,1+4+10*X,255,1
         dw        640,480

         db        122,1+4+10*X,255,1
         dw        768,576

         db        123,1+4+10*X,255,1
         dw        800,600

; ------ Cardinal

         db        12,'Cardinal VGA'
         db        8,'CARDINAL'             ; text k identifikaci karty
         db        23,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        48,1+4+10*X,255,1
         dw        800,600

         db        112,1+4+13*X,15,1
         dw        800,600

         db        113,1+4+13*X,15,1
         dw        960,720

         db        114,1+4+13*X,15,1
         dw        1024,768

         db        120,1+4+10*X,255,1
         dw        640,400

         db        121,1+4+10*X,255,1
         dw        640,480

         db        122,1+4+10*X,255,1
         dw        720,540

         db        123,1+4+10*X,255,1
         dw        800,600

; ------ Cirrus

         db        10,'Cirrus VGA'
         db        6,'CIRRUS'               ; text k identifikaci karty
         db        15,15                    ; po‡et videom¢d– celkem, odk zan‚

; ------ Compaq VGA Portable

         db        19,'Compaq VGA Portable'
         db        6,'COMPAQ'               ; text k identifikaci karty
         db        20,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        64,3+4+11*X,1,1
         dw        640,400

         db        88,1+4+13*X,15,1
         dw        800,600

         db        89,1+4+11*X,1,1
         dw        800,600

         db        94,1+4+10*X,255,1
         dw        640,400

         db        95,1+4+10*X,255,1
         dw        640,480

; ------ Corona/Cordata

         db        10,'Corona EGA'
         db        6,'CORONA'               ; text k identifikaci karty
         db        13,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        96,1+4+13*X,15,1
         dw        640,400

; ------ Dell VGA

         db        8,'Dell VGA'
         db        8,'DELL VGA'             ; text k identifikaci karty
         db        18,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        88,1+4+13*X,15,1
         dw        800,600

         db        89,1+4+11*X,1,1
         dw        800,600

         db        95,1+4+10*X,255,1
         dw        640,480

; ------ (Genoa 6400) Genoa Super VGA

         db        15,'Genoa Super VGA'
         db        6,'GENOA '               ; text k identifikaci karty
         db        53,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        39,1+4+13*X,15,1
         dw        720,512

         db        41,1+4+13*X,15,1
         dw        800,600

         db        46,1+4+10*X,255,1
         dw        640,480

         db        47,1+4+10*X,255,1
         dw        720,512

         db        48,1+4+10*X,255,1
         dw        800,600

         db        55,1+4+13*X,15,1
         dw        1024,768

         db        67,2+1*X,0,6             ; OK
         dw        80,29

         db        68,2+1*X,0,6             ; OK
         dw        80,32

         db        69,2+1*X,0,4             ; OK
         dw        80,44

         db        70,2+1*X,0,4             ; OK
         dw        132,25

         db        71,2+1*X,0,4             ; OK
         dw        132,29

         db        72,2+1*X,0,3             ; OK
         dw        132,32

         db        73,2+1*X,0,2             ; OK
         dw        132,44

         db        88,3+1*X,15,6            ; OK
         dw        80,32

         db        89,1+4+13*X,15,1         ; OK
         dw        720,512

         db        90,3+1*X,15,3            ; OK
         dw        100,42

         db        91,1+4+10*X,255,1        ; OK
         dw        640,350

         db        92,1+4+10*X,255,1        ; OK
         dw        640,480

         db        93,1+4+10*X,255,1        ; OK
         dw        720,512

         db        94,1+4+10*X,255,1        ; OK
         dw        800,600

         db        95,1+4+13*X,15,1         ; OK
         dw        1024,768

         db        96,3+1*X,15,4            ; OK
         dw        132,25

         db        97,3+1*X,15,4            ; OK
         dw        132,29

         db        98,3+1*X,15,3            ; OK
         dw        132,32

         db        99,3+1*X,15,2            ; OK
         dw        132,44

         db        100,3+1*X,15,2           ; OK
         dw        132,60

         db        106,1+4+13*X,15,1        ; OK
         dw        800,600

         db        107,3+1*X,15,2           ; OK
         dw        100,75

         db        108,1+4+10*X,255,1       ; OK
         dw        800,600

         db        114,3+1*X,15,3           ; OK
         dw        80,60

         db        115,1+4+13*X,15,1        ; OK
         dw        640,480

         db        116,3+1*X,15,3           ; OK
         dw        80,66

         db        120,3+1*X,15,2           ; OK
         dw        100,75

         db        121,1+4+13*X,15,1        ; OK
         dw        800,600

         db        124,1+4+13*X,15,1        ; OK
         dw        512,512

         db        125,1+4+10*X,255,1       ; OK
         dw        512,512

         db        126,1+4+10*X,255,1       ; OK
         dw        640,400

         db        127,1+4+12*X,3,1         ; OK
         dw        1024,768

; ------ Hewlett-Packard D1180A

         db        20,'Hewlett-Packard D118'
         db        7,'HEWLETT'              ; text k identifikaci karty
         db        20,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        84,3+1*X,15,2
         dw        132,43

         db        85,3+1*X,15,4
         dw        132,25

         db        88,1+4+13*X,15,1
         dw        800,600

         db        89,1+4+11*X,1,1
         dw        800,600

         db        95,1+4+10*X,255,1
         dw        640,480

; ------ Imtec

         db        9,'Imtec VGA'
         db        5,'IMTEC'                ; text k identifikaci karty
         db        18,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        92,1+4+10*X,255,1
         dw        640,400

         db        93,1+4+10*X,255,1
         dw        640,480

         db        95,1+4+13*X,15,1
         dw        1024,768

; ------ Lava Chrome II EGA

         db        18,'Lava Chrome II EGA'
         db        8,'LAVA CHR'            ; text k identifikaci karty
         db        24,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        20,1+4+13*X,15,4
         dw        640,200

         db        21,1+4+11*X,1,2
         dw        640,350

         db        22,1+4+13*X,15,2
         dw        640,350

         db        23,1+4+11*X,1,1
         dw        640,480

         db        24,1+4+13*X,15,1
         dw        640,480

         db        73,1+4+13*X,15,1
         dw        640,480

         db        80,3+1*X,15,4
         dw        80,34

         db        81,3+1*X,15,4
         dw        80,30

         db        82,3+1*X,15,2
         dw        80,60

         db        82,3+1*X,15,2
         dw        132,43

         db        84,3+1*X,15,4
         dw        132,25

         db        85,1+4+13*X,15,1
         dw        725,410

; ------ Logix

         db        9,'Logix VGA'
         db        5,'LOGIX'                ; text k identifikaci karty
         db        19,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        92,1+4+10*X,255,1
         dw        640,400

         db        93,1+4+10*X,255,1
         dw        640,480

         db        94,1+4+13*X,15,1
         dw        800,600

         db        95,1+4+13*X,15,1
         dw        1024,768

; ------ Maxxon

         db        10,'Maxxon VGA'
         db        6,'MAXXON'               ; text k identifikaci karty
         db        19,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        91,1+4+13*X,15,1
         dw        800,600

         db        92,1+4+10*X,255,1
         dw        640,400

         db        93,1+4+10*X,255,1
         dw        640,480

         db        95,1+4+13*X,15,1
         dw        1024,768

; ------ NSI Smart EGA+

         db        14,'NSI Smart EGA+'
         db        9,'NSI SMART'            ; text k identifikaci karty
         db        15,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        86,2+1*X,0,2
         dw        123,43

         db        87,2+1*X,0,4
         dw        123,25

         db        113,1+4+13*X,15,1
         dw        800,600

; ------ OAK Technology VGA (testov no)

         db        18,'OAK Technology VGA'
         db        9,'OAK TECHN'            ; text k identifikaci karty
         db        27,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        78,3+1*X,15,3
         dw        80,60

         db        79,3+1*X,15,2
         dw        132,60

         db        80,3+1*X,15,4
         dw        132,25

         db        81,3+1*X,15,2
         dw        132,43

         db        82,1+4+13*X,15,1
         dw        800,600

         db        83,1+4+10*X,255,1
         dw        640,480

         db        84,1+4+10*X,255,1
         dw        800,600

         db        85,1+4+13*X,15,1
         dw        1024,768

         db        86,1+4+13*X,15,1
         dw        1024,768

         db        87,1+4+13*X,15,1
         dw        768,1024

         db        90,1+4+10*X,255,1
         dw        1024,512

         db        91,1+4+10*X,255,1
         dw        1280,400

; ------ Orchid Prodesigner VGA

         db        20,'Orchid Prodesign.VGA'
         db        6,'ORCHID'               ; text k identifikaci karty
         db        26,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        34,3+1*X,15,2
         dw        132,44

         db        35,3+1*X,15,4
         dw        132,28

         db        36,3+1*X,15,4
         dw        132,25

         db        37,1+4+13*X,15,1
         dw        640,480

         db        38,3+1*X,15,2
         dw        80,60

         db        41,1+4+13*X,15,1
         dw        800,600

         db        42,3+1*X,15,2
         dw        100,40

         db        45,1+4+10*X,255,1
         dw        640,350

         db        46,1+4+10*X,255,1
         dw        640,480

         db        48,1+4+10*X,255,1
         dw        800,600

         db        55,1+4+13*X,15,1
         dw        1024,768

; ------ Paradise EGA-480 (ovˆ©eno)

         db        16,'Paradise EGA-480'
         db        10,' PEGA BIOS'          ; text k identifikaci karty
         db        24,14                    ; po‡et videom¢d– celkem, odk zan‚

         db        80,1+4+13*X,15,1
         dw        640,480

         db        81,3+1*X,15,6
         dw        80,30

         db        82,1+4+13*X,15,2
         dw        640,400

         db        83,3+1*X,15,8
         dw        80,25

         db        84,3+1*X,15,2
         dw        132,43

         db        85,3+1*X,15,4
         dw        132,25

         db        86,2+1*X,0,2
         dw        132,43

         db        87,2+1*X,0,4
         dw        132,25

         db        88,1+4+11*X,1,1
         dw        640,480

         db        89,1+4+13*X,15,1
         dw        640,480

; ------ Paradise Super VGA

         db        18,'Paradise Super VGA'
         db        8,'PARADISE'             ; text k identifikaci karty
         db        27,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        84,3+1*X,15,2            ; OK
         dw        132,43

         db        85,3+1*X,15,4            ; OK
         dw        132,25

         db        86,2+1*X,0,2             ; OK
         dw        123,43

         db        87,2+1*X,0,4             ; OK
         dw        123,25

         db        88,1+4+13*X,15,1
         dw        800,600

         db        89,1+4+11*X,1,1
         dw        800,600

         db        90,1+4+11*X,1,1
         dw        1024,768

         db        91,1+4+12*X,3,1
         dw        1024,768

         db        92,1+4+10*X,255,1
         dw        800,600

         db        93,1+4+13*X,15,1
         dw        1024,768

         db        94,1+4+10*X,255,1
         dw        640,400

         db        95,1+4+10*X,255,1
         dw        640,480

; ------ Realtek (testov no)

         db        11,'Realtek VGA'
         db        7,'REALTEK'              ; text k identifikaci karty
         db        31,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        24,3+1*X,15,6
         dw        80,30

         db        25,3+1*X,15,4
         dw        80,43

         db        26,3+1*X,15,3
         dw        80,60

         db        27,3+1*X,15,4
         dw        132,25

         db        28,3+1*X,15,4
         dw        132,30

         db        29,3+1*X,15,2
         dw        132,43

         db        30,3+1*X,15,2
         dw        132,60

         db        31,1+4+13*X,15,1
         dw        800,600

         db        32,1+4+13*X,15,1
         dw        960,720

         db        33,1+4+13*X,15,1
         dw        1024,768

         db        34,1+4+13*X,15,1
         dw        768,1024

         db        35,1+4+12*X,3,1
         dw        1024,768

         db        36,1+4+10*X,255,1
         dw        512,512

         db        37,1+4+10*X,255,1
         dw        640,400

         db        38,1+4+10*X,255,1
         dw        640,480

         db        39,1+4+10*X,255,1
         dw        800,600

; ------ SEFCO TVGA

         db        10,'SEFCO TVGA'
         db        5,'SEFCO'                ; text k identifikaci karty
         db        17,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        92,1+4+10*X,255,1
         dw        640,400

         db        93,1+4+10*X,255,1
         dw        640,480

; ------ Sigma VGA

         db        9,'Sigma VGA'
         db        5,'SIGMA'                ; text k identifikaci karty
         db        19,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        41,1+4+13*X,15,1
         dw        800,600

         db        46,1+4+10*X,255,1
         dw        640,480

         db        48,1+4+10*X,255,1
         dw        800,600

         db        55,1+4+13*X,15,1
         dw        1024,768

; ------ STB VGA

         db        7,'STB VGA'
         db        7,'STB VGA'              ; text k identifikaci karty
         db        22,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        41,1+4+13*X,15,1
         dw        800,600

         db        46,1+4+10*X,255,1
         dw        640,480

         db        48,1+4+10*X,255,1
         dw        800,600

         db        54,1+4+13*X,15,1
         dw        960,720

         db        55,1+4+13*X,15,1
         dw        1024,768

         db        56,1+4+10*X,255,1
         dw        1024,768

         db        120,1+4+10*X,255,1
         dw        640,400

; ------ Tatung VGA

         db        10,'Tatung VGA'
         db        6,'TATUNG'               ; text k identifikaci karty
         db        25,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        64,3+1*X,15,1
         dw        80,43

         db        65,3+1*X,15,4
         dw        132,25

         db        66,3+1*X,15,2
         dw        132,43

         db        67,3+1*X,15,2
         dw        80,60

         db        68,3+1*X,15,2
         dw        100,60

         db        69,3+1*X,15,4
         dw        132,28

         db        96,1+4+13*X,15,1
         dw        752,410

         db        97,1+4+13*X,15,1
         dw        720,540

         db        98,1+4+13*X,15,1
         dw        800,600

         db        102,1+4+10*X,255,1
         dw        640,400

; ------ Taxan 565 EGA

         db        13,'Taxan 565 EGA'
         db        5,'TAXAN'                ; text k identifikaci karty
         db        17,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        80,1+4+11*X,0,1
         dw        640,480

         db        84,3+1*X,15,2
         dw        132,43

         db        85,3+1*X,15,4
         dw        132,25

         db        86,2+1*X,0,2
         dw        123,43

         db        87,2+1*X,0,4
         dw        123,25

; ------ Tecmar VGA/AD

         db        13,'Tecmar VGA/AD'
         db        6,'TECMAR'               ; text k identifikaci karty
         db        24,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        20,1+4+13*X,15,2
         dw        640,400

         db        22,1+4+13*X,15,1
         dw        800,600

         db        23,3,15+1*X,4
         dw        132,25

         db        24,1+4+13*X,15,1
         dw        1024,768

         db        26,1+4+10*X,255,1
         dw        640,350

         db        27,1+4+10*X,255,1
         dw        640,400

         db        28,1+4+10*X,255,1
         dw        640,480

         db        29,1+4+10*X,255,1
         dw        800,600

         db        64,3+1*X,15,1
         dw        80,43

; ------ Toshiba 3100 AT&T

         db        17,'Toshiba 3100 AT&T'
         db        7,'TOSHIBA'              ; text k identifikaci karty
         db        13,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        116,1+4+11*X,1,1
         dw        640,400

; ------ Trident TVGA (8800, 8900, 9000) (testov no a dokumentov no TVGA 9000)

         db        17,'Trident Super VGA'
         db        7,'TRIDENT'              ; text k identifikaci karty
         db        35,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        80,3+1*X,15,6
         dw        80,30

         db        81,3+1*X,15,4
         dw        80,43

         db        82,3+1*X,15,3
         dw        80,60

         db        83,3+1*X,15,4
         dw        132,25

         db        84,3+1*X,15,4
         dw        132,30

         db        85,3+1*X,15,2
         dw        132,43

         db        86,3+1*X,15,2
         dw        132,60

         db        87,3+1*X,15,4
         dw        132,25

         db        88,3+1*X,15,4
         dw        132,30

         db        89,3+1*X,15,2
         dw        132,43

         db        90,3+1*X,15,2
         dw        132,60

         db        91,1+4+13*X,15,1
         dw        800,600

         db        92,1+4+10*X,255,1
         dw        640,400

         db        93,1+4+10*X,255,1
         dw        640,480

         db        94,1+4+10*X,255,1
         dw        800,600

         db        95,1+4+13*X,15,1
         dw        1024,768

         db        96,1+4+12*X,3,1
         dw        1024,768

         db        97,1+4+13*X,15,1
         dw        768,1024

         db        98,1+4+10*X,255,1        ; nem  TVGA 9000
         dw        1024,768

         db        106,1+4+13*X,15,1        ; nedokumentov no pro TVGA 9000
         dw        800,600

;         db        112,1+4+10*X,255,1      ; nedokumentovan‚ m¢dy - nefunguj¡
;         dw        1024,480
;
;         db        113,1+4+10*X,255,1
;         dw        1024,480
;
;         db        116,1+4+10*X,255,1
;         dw        1280,480
;
;         db        117,1+4+10*X,255,1
;         dw        1280,480
;
;         db        118,1+4+10*X,255,1
;         dw        1600,600
;
;         db        119,1+4+10*X,255,1
;         dw        1600,600

; ------ Tseng Labs EVA

         db        14,'Tseng Labs EVA'
         db        14,'TSENG LABS EVA'      ; text k identifikaci karty
         db        20,12                    ; po‡et videom¢d– celkem, odk zan‚

         db        24,2+1*X,0,2
         dw        132,44

         db        25,2+1*X,0,4
         dw        132,25

         db        26,2+1*X,0,4
         dw        132,28

         db        34,3+1*X,15,2
         dw        132,44

         db        35,3+1*X,15,4
         dw        132,25

         db        36,3+1*X,15,4
         dw        132,28

         db        37,1+4+13*X,15,1
         dw        640,480

         db        38,3+1*X,15,2
         dw        80,60

; ------ Tseng ET4000 chipset (Tseng Labs Super VGA)

         db        20,'Tseng Labs Super VGA'
         db        6,'TSENG '               ; text k identifikaci karty
         db        30,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        24,2+1*X,0,2             ; OK
         dw        132,44

         db        25,2+1*X,0,4             ; OK
         dw        132,25

         db        26,2+1*X,0,4             ; OK
         dw        132,28

         db        34,3+1*X,15,2            ; OK
         dw        132,44

         db        35,3+1*X,15,4            ; OK
         dw        132,25

         db        36,3+1*X,15,4            ; OK
         dw        132,28

         db        37,1+4+13*X,15,1
         dw        640,480

         db        38,3+1*X,15,2            ; OK
         dw        80,60

         db        41,1+4+13*X,15,1
         dw        800,600

         db        42,3+1*X,15,2            ; OK
         dw        100,40

         db        45,1+4+10*X,255,1
         dw        640,350

         db        46,1+4+10*X,255,1
         dw        640,480

         db        47,1+4+10*X,255,1
         dw        640,400

         db        48,1+4+10*X,255,1
         dw        800,600

         db        56,1+4+10*X,255,1
         dw        1024,768

; ------ VEGA VGA

         db        8,'VEGA VGA'
         db        8,'VEGA VGA'             ; text k identifikaci karty
         db        39,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        37,1+4+13*X,15,1
         dw        640,480

         db        39,1+4+13*X,15,1
         dw        720,512

         db        41,1+4+13*X,15,1
         dw        800,600

         db        45,1+4+10*X,255,1
         dw        640,350

         db        46,1+4+10*X,255,1
         dw        640,480

         db        47,1+4+10*X,255,1
         dw        720,512

         db        48,1+4+10*X,255,1
         dw        800,600

         db        54,1+4+13*X,15,1
         dw        960,720

         db        55,1+4+13*X,15,1
         dw        1024,768

         db        64,3+1*X,15,2
         dw        80,43

         db        65,3+1*X,15,4
         dw        132,25

         db        66,3+1*X,15,2
         dw        132,43

         db        67,3+1*X,15,2
         dw        80,60

         db        68,3+1*X,15,2
         dw        100,60

         db        77,3+1*X,15,4
         dw        120,25

         db        78,3+1*X,15,2
         dw        120,43

         db        79,3+1*X,15,4
         dw        132,25

         db        80,2+1*X,0,4
         dw        80,43

         db        81,2+1*X,0,4
         dw        132,25

         db        82,2+1*X,0,2
         dw        132,43

         db        94,1+4+10*X,255,1
         dw        640,400

         db        96,1+4+13*X,15,1
         dw        752,410

         db        97,1+4+13*X,15,1
         dw        720,540

         db        98,1+4+13*X,15,1
         dw        800,600

; ------ VESA standard

         db        13,'VESA standard'
         db        6,'VESA S'               ; text k identifikaci karty
         db        16,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        106,1+4+13*X,15,1
         dw        800,600

; ------ Video7 V-RAM VGA (Video7 Super VGA)

         db        16,'Video7 Super VGA'
         db        6,'VIDEO7'               ; text k identifikaci karty
         db        30,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        64,3+1*X,15,4            ; OK
         dw        80,43

         db        65,3+1*X,15,4            ; OK
         dw        132,25

         db        66,3+1*X,15,2            ; OK
         dw        132,43

         db        67,3+1*X,15,3            ; OK
         dw        80,60

         db        68,3+1*X,15,2            ; OK
         dw        100,60

         db        69,3+1*X,15,4            ; OK
         dw        132,28

         db        96,1+4+13*X,15,1
         dw        752,410

         db        97,1+4+13*X,15,1
         dw        720,540

         db        98,1+4+13*X,15,1
         dw        800,600

         db        99,1+4+11*X,1,1
         dw        1024,768

         db        100,1+4+12*X,3,1
         dw        1024,768

         db        101,1+4+13*X,15,1
         dw        1024,768

         db        102,1+4+10*X,255,1
         dw        640,400

         db        103,1+4+10*X,255,1
         dw        640,480

         db        105,1+4+10*X,255,1
         dw        720,540

; ------ Western Digital VGA (ovˆ©eno)

         db        19,'Western Digital VGA'
         db        13,'WESTERN DIGIT'
         db        31,15

         db        28,3+1*X,15,4
         dw        132,25

         db        29,3+1*X,15,2
         dw        132,44

         db        84,3+1*X,15,2
         dw        132,43

         db        85,3+1*X,15,4
         dw        132,25

         db        86,2+1*X,0,2
         dw        132,43

         db        87,2+1*X,0,4
         dw        132,25

         db        88,1+4+13*X,15,1
         dw        800,600

         db        89,1+4+11*X,1,1
         dw        800,600

         db        90,1+4+11*X,1,1
         dw        1024,768

         db        91,1+4+12*X,3,1
         dw        1024,768

         db        92,1+4+11*X,1,1
         dw        1024,768

         db        93,1+4+13*X,15,1
         dw        1024,768

         db        94,1+4+10*X,255,1
         dw        640,400

         db        95,1+4+10*X,255,1
         dw        640,480

         db        106,1+4+13*X,15,1
         dw        800,600

         db        107,1+4+12*X,0,1
         dw        800,600

; ------ Zymos Poach

         db        15,'Zymos Poach VGA'
         db        5,'ZYMOS'                ; text k identifikaci karty
         db        21,15                    ; po‡et videom¢d– celkem, odk zan‚

         db        92,1+4+10*X,255,1
         dw        640,400

         db        93,1+4+10*X,255,1
         dw        640,480

         db        94,1+4+10*X,255,1
         dw        800,600

         db        95,1+4+13*X,15,1
         dw        1024,768

         db        98,1+4+10*X,255,1
         dw        1024,768

         db        106,1+4+13*X,15,1
         dw        800,600

; ------ u‘ivatelsk˜ m¢d

         db        20,'detekovane videomody'
         db        0
UserMod0:db        0,0

UserMod  label     byte                     ; buffer k ulo‘en¡ u‘ovat. m¢d–

Code     ENDS
         END       Start

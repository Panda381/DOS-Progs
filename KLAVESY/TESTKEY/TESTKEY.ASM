
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ instalace INT 23h

Start:   mov       dx,offset INT23
         mov       ax,2523h
         int       21h

; ------ £schova INT 09h

         push      es
         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es
         pop       es

; ------ instalace INT 09h

         mov       dx,offset INT09
         mov       ax,2509h
         int       21h

; ------ inicializace videom¢du

         mov       ah,0fh
         call      Int10P
         cmp       al,7
         je        Start1
         mov       byte ptr ds:[SegmVRAM+1],0b8h ; segment videopamˆti
         cmp       al,2
         je        Start1
         cmp       al,3
         je        Start1
         mov       ax,3
         call      Int10P

; ------ po‡et © dk–

Start1:  push      ds
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[484h]
         pop       ds
         inc       ax
         cmp       al,20
         jb        Start102
         cmp       al,60
         ja        Start102
         mov       ds:[Radku],al
Start102:
         call      Clear                    ; vymaz n¡ obrazovky

         mov       ah,2
         mov       dl,0
         mov       dh,ds:[Radku]
         call      Int10P

; ------ zobrazen¡ nadpisu

         xor       dx,dx
         mov       cl,80
         mov       si,offset Nadpis
         mov       ah,7
         call      DispTxt
         mov       ah,30h
         call      DispTxt

; ------ ‡ek n¡ na p©¡chod p©eru¨en¡

         mov       dh,2                     ; po‡ te‡n¡ © dek k zobrazen¡
         call      NulKey                   ; nulov n¡ bufferu kl vesnice
Start4:  sti
         cmp       word ptr ds:[BuffEnd],offset Buffer
         je        Start4
         cli
         mov       di,offset Buffer         ; buffer parametr–

; ------ test, zda byla kl vesa ESC

         mov       al,ds:[di]               ; k¢d kl vesy
         cmp       al,81h
         je        Start52
         cmp       al,1
         jne       Start5                   ; nen¡ ESC
         dec       byte ptr ds:[KeyEsc]     ; ‡¡ta‡ ESC
         jnz       Start52

; ------ KONEC - vymaz n¡ displeje

         call      Clear

         mov       ah,2
         xor       dx,dx
         call      Int10P

; ------ n vrat INT 09h

         lds       dx,ds:[Old09]
         mov       ax,2509h
         int       21h
         int       20h

; ------ inicializace ‡¡ta‡e ESC

Start5:  mov       byte ptr ds:[KeyEsc],2   ; zru¨en¡ p©¡znaku kl vesy ESC

; ------ p©¡prava k zobrazen¡ © dku

Start52: mov       dl,0                     ; po‡ te‡n¡ pozice

; ------ rozli¨en¡ speci ln¡ho k¢du

         mov       bl," "                   ; £vodn¡ znak p©ed textem
         mov       ah,ds:[di]               ; £schova kl vesy
         mov       al,59h                   ; n hradn¡ k¢d 59h
         cmp       ah,0e0h
         je        Start53                  ; je prefix E0h
         inc       ax                       ; n hradn¡ k¢d 5Ah
         cmp       ah,0e1h
         je        Start53                  ; je prefix E1h (pause)
         inc       ax                       ; n hradn¡ k¢d 5B
         cmp       ah,0fah
         je        Start53                  ; potvrzen¡ p©¡jmu "ready"
         inc       ax                       ; n hradn¡ k¢d 5C
         cmp       ah,0feh
         je        Start53                  ; opakov n¡ vys¡l n¡ "repeat"
         inc       ax                       ; n hradn¡ k¢d 5D
         cmp       ah,0ffh
         je        Start53                  ; p©eplnˆn¡ bufferu "full"

         mov       al,ah                    ; jinak n vrat znaku

; ------ ur‡en¡ barvy znaku a znaku p©ed textem

         mov       ah,7                     ; barva bˆ‘n‚ kl vesy
         test      al,80h
         jz        Start54                  ; nen¡ uvolnˆn¡ kl vesy
         mov       bl,"*"                   ; znak pro uvolnˆn¡ kl vesy
         and       al,7fh                   ; nulov n¡ bitu uvolnˆn¡
Start53: mov       ah,6                     ; barva speci ln¡ho k¢du + uvolnˆn¡

; ------ zobrazen¡ znaku p©ed textem

Start54: push      ax
         mov       al,bl
         call      DispChr
         pop       ax

; ------ zobrazen¡ textu kl vesy

         push      ax
         cmp       al,5dh
         jbe       Start56
         mov       al,0
Start56: mov       ah,9
         mul       ah
         add       ax,offset KeyTab
         xchg      si,ax
         pop       ax
         mov       cl,9
         call      DispTxt
         call      DispCar

; ------ zobrazen¡ k¢du kl vesy

         call      DispSpc                  ; zobrazen¡ mezery
         mov       al,ds:[di]
         call      DispByte
         call      DispSpc
         call      DispCar

; ------ zobrazen¡ bufferu kl vesnice

         mov       cx,word ptr ds:[di+6]
         call      DispSWrd
         call      DispCar

; ------ vstup znaku p©es INT 16h/00h

         mov       al,0
         call      InpKey
         call      DispSWrd
         call      DispCar

; ------ vstup znaku p©es INT 16h/10h

         mov       al,10h
         call      InpKey
         call      DispSWrd                 ; podm¡nˆn‚ zobrazen¡ slova
         call      DispCar

; ------ zobrazen¡ stavu INS

         call      DispSpc
         test      byte ptr ds:[di+2],80h
         call      DispShfX
         mov       al,"I"
         test      byte ptr ds:[di+3],80h
         call      DispShft

; ------ zobrazen¡ stavu CAPS LOCK

         call      DispSpc
         call      DispSpc
         test      byte ptr ds:[di+2],40h
         call      DispShfX
         mov       al,"C"
         test      byte ptr ds:[di+3],40h
         call      DispShft

; ------ zobrazen¡ stavu NUM LOCK

         call      DispSpc
         call      DispSpc
         test      byte ptr ds:[di+2],20h
         call      DispShfX
         mov       al,"N"
         test      byte ptr ds:[di+3],20h
         call      DispShft

; ------ zobrazen¡ stavu SCROLL LOCK

         call      DispSpc
         call      DispSpc
         test      byte ptr ds:[di+2],10h
         call      DispShfX
         mov       al,"S"
         test      byte ptr ds:[di+3],10h
         call      DispShft
         call      DispCar

; ------ zobrazen¡ p©esmyka‡e ALT

         test      byte ptr ds:[di+3],2
         call      DispShfL
         test      byte ptr ds:[di+2],8
         call      DispShfH
         test      byte ptr ds:[di+4],8
         call      DispShfR
         call      DispSpc

; ------ zobrazen¡ p©esmyka‡e CTRL

         test      byte ptr ds:[di+3],1
         call      DispShfL
         test      byte ptr ds:[di+2],4
         call      DispShfH
         test      byte ptr ds:[di+4],4
         call      DispShfR
         call      DispSpc

; ------ zobrazen¡ p©esmyka‡e SHIFT

         test      byte ptr ds:[di+2],2
         call      DispShfL
         test      byte ptr ds:[di+2],3
         call      DispShfH
         test      byte ptr ds:[di+2],1
         call      DispShfR
         call      DispCar

; ------ zobrazen¡ stavu indik tor–

         mov       al,"N"
         test      byte ptr ds:[di+5],2
         call      DispShft
         mov       al,"C"
         test      byte ptr ds:[di+5],4
         call      DispShft
         mov       al,"S"
         test      byte ptr ds:[di+5],1
         call      DispShft

; ------ zobrazen¡ stavu registru [0096]

         call      DispCar
         mov       bl,ds:[di+4]
         call      DispBin

; ------ zobrazen¡ stavu registru [0097]

         call      DispCar
         mov       bl,ds:[di+5]
         call      DispBin

; ------ posun bufferu o polo‘ku

         cli
         mov       di,offset Buffer
         mov       si,offset Buffer+8
         mov       cx,ds:[BuffEnd]
         sub       cx,si
         cld
         rep       movsb
         sub       word ptr ds:[BuffEnd],8

         inc       dh

         call      NulKey
         jmp       Start4

; -----------------------------------------------------------------------------
;        vymaz n¡ obrazovky
; -----------------------------------------------------------------------------

Clear    PROC      NEAR

         push      es
         mov       al,80
         mul       byte ptr ds:[Radku]
         xchg      ax,cx
         mov       es,ds:[SegmVRAM]
         xor       di,di
         mov       ax,720h
         cld
         rep       stosw
         pop       es
         ret

Clear    ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice (DI=buffer, slu‘ba AL -> CX, CX=-1 nen¡)
; -----------------------------------------------------------------------------

InpKey   PROC      NEAR

; ------ n vrat stavu

         push      ds
         mov       cx,40h
         mov       ds,cx
         mov       cx,cs:[di+2]
         mov       ds:[17h],cx
         mov       cx,cs:[di+4]
         mov       ds:[96h],cx
         mov       cx,cs:[di+6]
         mov       ds:[1eh],cx
         call      NulKey                   ; nulov n¡ bufferu
         cmp       cx,-1
         je        InpKey4                  ; nen¡ ‘ dn  kl vesa
         mov       byte ptr ds:[1ch],20h

; ------ test, zda je p©ipravena kl vesa

         push      ax
         mov       ah,al
         or        ah,1
         int       16h
         cli
         pop       ax
         mov       cx,-1
         jz        InpKey4                  ; nen¡ p©ipravena kl vesa

; ------ vstup znaku z kl vesnice

         push      ax
         mov       ah,al
         int       16h
         cli
         xchg      ax,cx
         pop       ax

InpKey4: pop       ds
         ret

InpKey   ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ bufferu kl vesnice
; -----------------------------------------------------------------------------

NulKey   PROC      NEAR

         push      ds
         push      cx
         cli
         xor       cx,cx
         mov       ds,cx
         mov       word ptr ds:[480h],1eh
         mov       word ptr ds:[482h],3eh
         mov       word ptr ds:[41ah],1eh
         mov       word ptr ds:[41ch],1eh
         pop       cx
         pop       ds
         ret

NulKey   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu BL v bin rn¡m tvaru
; -----------------------------------------------------------------------------

DispBin  PROC      NEAR

         mov       cx,8
DispBin1:mov       al,"0"
         shl       bl,1
         jnc       DispBin2
         mov       al,"1"
DispBin2:call      DispChr
         loop      DispBin1
         ret

DispBin  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ stavu p©esmyka‡e (AL=znak, ZY=nen¡ nastaven)
; -----------------------------------------------------------------------------

DispShfL:mov       al,"L"
         jmp       short DispShft

DispShfR:mov       al,"R"
         jmp       short DispShft

DispShfH:mov       al,"*"
         jmp       short DispShft

DispShfx:mov       al,"x"

DispShft PROC      NEAR

         jnz       DispShf2                 ; p©esmyka‡ je nastaven
         mov       al," "
DispShf2:call      DispChr
         ret

DispShft ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

INT09    PROC      FAR

; ------ test, zda je INT 09h aktivn¡

         cmp       byte ptr cs:[Akt09],0
         je        INT090
         jmp       dword ptr cs:[Old09]

; ------ £schova registr–

INT090:  inc       byte ptr cs:[Akt09]
         push      ax
         push      bx
         push      di
         push      ds

; ------ p©¡prava registr–

         mov       bx,40h
         mov       ds,bx
         mov       di,cs:[BuffEnd]

; ------ test, zda je pot©eba navr tit stav

         cmp       di,offset Buffer         ; byl nˆjak˜ stav p©edt¡m ?
         je        INT092                   ; nen¡ pot©eba navracet stav

; ------ £schova sou‡asn‚ho stavu

         mov       ax,ds:[17h]
         mov       cs:[di+2],ax
         mov       ax,ds:[96h]
         mov       cs:[di+4],ax
         mov       ax,-1
         mov       bx,ds:[1ah]
         cmp       bx,ds:[1ch]
         je        INT091
         mov       ax,ds:[bx]
INT091:  mov       cs:[di+6],ax

; ------ n vrat p©edchoz¡ho stavu

         mov       ax,cs:[di+2-8]
         mov       ds:[17h],ax
         mov       ax,cs:[di+4-8]
         mov       ds:[96h],ax
INT092:  mov       bx,1eh
         mov       ds:[1ah],bx
         mov       ds:[1ch],bx

; ------ £schova stavu portu

INT093:  in        al,[60h]

; ------ vol n¡ p–vodn¡ obsluhy

         pushf
         call      dword ptr cs:[Old09]

; ------ test, zda byl navracen stav

         mov       cs:[di],al               ; £schova k¢du kl vesy
         cmp       di,offset Buffer         ; byl zmˆnˆn stav ?
         je        INT095                   ; stav nebyl mˆnˆn

; ------ £schova nov‚ho stavu s n vratem p©ede¨l‚ho

         mov       ax,cs:[di+2]
         xchg      ax,ds:[17h]
         mov       cs:[di+2],ax

         mov       ax,cs:[di+4]
         xchg      ax,ds:[96h]
         mov       cs:[di+4],ax

         mov       ax,-1
         mov       bx,ds:[1ah]
         cmp       bx,ds:[1ch]
         je        INT094
         mov       ax,ds:[bx]
INT094:  xchg      ax,cs:[di+6]

         mov       bx,1eh
         mov       ds:[1ah],bx
         mov       ds:[1ch],bx
         cmp       ax,-1
         je        INT099
         mov       ds:[bx],ax
         inc       bx
         inc       bx
         mov       ds:[1ch],bx
         jmp       short INT099

; ------ £schova sou‡asn‚ho stavu

INT095:  mov       ax,ds:[17h]
         mov       cs:[di+2],ax
         mov       ax,ds:[96h]
         mov       cs:[di+4],ax
         mov       ax,-1
         mov       bx,ds:[1ah]
         cmp       bx,ds:[1ch]
         je        INT096
         mov       ax,ds:[bx]
INT096:  mov       cs:[di+6],ax

; ------ n vrat registr–

INT099:  add       word ptr cs:[BuffEnd],8  ; posun konce bufferu
         pop       ds
         pop       di
         pop       bx
         pop       ax
         dec       byte ptr cs:[Akt09]
         iret

INT09    ENDP

Old09    dd        0
Akt09    db        0                        ; p©¡znak aktivity INT 09h

; -----------------------------------------------------------------------------
;        obsluha INT 23h
; -----------------------------------------------------------------------------

INT23    PROC      FAR

         iret

INT23    ENDP

; -----------------------------------------------------------------------------
;        podm¡nˆn‚ zobrazen¡ slova CX (je-li -1, zobraz¡ se mezery)
; -----------------------------------------------------------------------------

DispSWrd PROC      NEAR

         cmp       cx,-1
         jne       DispWord
         push      cx
         mov       cl,4
         call      DispCSpc
         pop       cx
         ret

DispSWrd ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ slova HEX (CX)
; -----------------------------------------------------------------------------

DispWord PROC      NEAR

         push      ax
         mov       al,ch
         call      DispByte
         mov       al,cl
         call      DispByte
         pop       ax
         ret

DispWord ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu HEX (AL)
; -----------------------------------------------------------------------------

DispByte PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHx
         pop       ax

DispHx:  push      ax
         and       al,0fh
         cmp       al,10
         jb        DispHx2
         add       al,7
DispHx2: add       al,"0"
         call      DispChr
         pop       ax
         ret

DispByte ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu CS:SI, d‚lka CL
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      cx
         mov       ch,0
         jcxz      DispTxt9
DispTxt2:mov       al,cs:[si]
         inc       si
         call      DispChr
         loop      DispTxt2
DispTxt9:pop       cx
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ oddˆlovac¡ ‡ ry
; -----------------------------------------------------------------------------

DispCar  PROC      NEAR

         push      ax
         mov       ax,700h + "³"
         call      DispChr
         pop       ax
         ret

DispCar  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ CL mezer
; -----------------------------------------------------------------------------

DispCSpc PROC      NEAR

         push      ax
         push      cx
         mov       ch,0
         jcxz      DispCSp3
         mov       al," "
DispCSp2:call      DispChr
         loop      DispCSp2
DispCSp3:pop       cx
         pop       ax
         ret

DispCSpc ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ mezery
; -----------------------------------------------------------------------------

DispSpc  PROC      NEAR

         push      ax
         mov       al," "
         call      DispChr
         pop       ax
         ret

DispSpc  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AX na pozici DX
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      si
         push      di
         push      cx
         push      ds
         push      es

         mov       es,cs:[SegmVRAM]
         push      es
         pop       ds

         cmp       dl,80
         jb        DispChr3
         mov       dl,0
         inc       dh
DispChr3:cmp       dh,cs:[Radku]
         jb        DispChr4

         push      ax
         mov       al,160
         mul       byte ptr cs:[Radku]
         sub       ax,3*160
         xchg      ax,cx

         mov       di,2*160
         mov       si,3*160
         cld
         rep       movsw
         mov       ax,720h
         mov       cx,160
         rep       stosw
         pop       ax

         dec       dh

DispChr4:
         xchg      ax,di
         mov       al,80
         mul       dh
         add       al,dl
         adc       ah,0
         shl       ax,1
         xchg      ax,di
         cld
         stosw

         pop       es
         pop       ds
         pop       cx
         pop       di
         pop       si
         inc       dl
         ret

DispChr  ENDP

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

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

SegmVRAM dw        0b000h                   ; segment videopamˆti

Radku    db        25                       ; po‡et © dk– displeje

KeyEsc   db        2                        ; ‡¡ta‡ kl vesy ESC

Nadpis   db        'TESTKEY V1.0 - test klavesnice; (c) Miroslav Nemecek º 2 x ESC = konec programu '
         db        ' klavesa  ³[60]³buff³IN00³IN10³INS CPS NUM SCR³ALT CTR SHF³NCS³ [0096] ³ [0097] '
;                  ' Shift    ³ 23 ³231A³    ³    ³ xI  xC  xN  xS³L R L R L R³NCS³00000001³00000000'

KeyTab   label     byte                     ; tabulka k¢d– kl ves
         db        '   -     '              ; 00
         db        '  ESC    '              ; 01
         db        '  1 !    '              ; 02
         db        '  2 @    '              ; 03
         db        '  3 #    '              ; 04
         db        '  4 $    '              ; 05
         db        '  5 %    '              ; 06
         db        '  6 ^    '              ; 07
         db        '  7 &    '              ; 08
         db        '  8 *    '              ; 09
         db        '  9 (    '              ; 0A
         db        '  0 )    '              ; 0B
         db        '  - _    '              ; 0C
         db        '  = +    '              ; 0D
         db        'BackSpace'              ; 0E
         db        '  Tab    '              ; 0F
         db        '   Q     '              ; 10
         db        '   W     '              ; 11
         db        '   E     '              ; 12
         db        '   R     '              ; 13
         db        '   T     '              ; 14
         db        '   Y     '              ; 15
         db        '   U     '              ; 16
         db        '   I     '              ; 17
         db        '   O     '              ; 18
         db        '   P     '              ; 19
         db        '  [ {    '              ; 1A
         db        '  ] }    '              ; 1B
         db        ' Enter   '              ; 1C
         db        '  Ctrl   '              ; 1D
         db        '   A     '              ; 1E
         db        '   S     '              ; 1F
         db        '   D     '              ; 20
         db        '   F     '              ; 21
         db        '   G     '              ; 22
         db        '   H     '              ; 23
         db        '   J     '              ; 24
         db        '   K     '              ; 25
         db        '   L     '              ; 26
         db        '  ; :    '              ; 27
         db        '  ',39,' "    '         ; 28
         db        '  ` ~    '              ; 28
         db        ' L-Shift '              ; 2A
         db        '  \ |    '              ; 2B
         db        '   Z     '              ; 2C
         db        '   X     '              ; 2D
         db        '   C     '              ; 2E
         db        '   V     '              ; 2F
         db        '   B     '              ; 30
         db        '   N     '              ; 31
         db        '   M     '              ; 32
         db        '  , <    '              ; 33
         db        '  . >    '              ; 34
         db        '  / ?    '              ; 35
         db        ' R-Shift '              ; 36
         db        '[*] PrScr'              ; 37
         db        '   Alt   '              ; 38
         db        ' mezera  '              ; 39
         db        'Caps Lock'              ; 3A
         db        '   F1    '              ; 3B
         db        '   F2    '              ; 3C
         db        '   F3    '              ; 3D
         db        '   F4    '              ; 3E
         db        '   F5    '              ; 3F
         db        '   F6    '              ; 40
         db        '   F7    '              ; 41
         db        '   F8    '              ; 42
         db        '   F9    '              ; 43
         db        '   F10   '              ; 44
         db        ' Num Lock'              ; 45
         db        'Scrl Lock'              ; 46
         db        '[7] Home '              ; 47
         db        '[8]nahoru'              ; 48
         db        '[9] PgUp '              ; 49
         db        '  [-]    '              ; 4A
         db        '[4] vlevo'              ; 4B
         db        '  [5]    '              ; 4C
         db        '[6]vpravo'              ; 4D
         db        '  [+]    '              ; 4E
         db        ' [1] End '              ; 4F
         db        '[2] dolu '              ; 50
         db        '[3] PgDn '              ; 51
         db        '[0] Ins  '              ; 52
         db        '[.] Del  '              ; 53
         db        ' SysRq   '              ; 54
         db        '   -     '              ; 55
         db        ' \ | EXT.'              ; 56
         db        '  F11    '              ; 57
         db        '  F12    '              ; 58
         db        '... prefx'              ; E0  -> 59
         db        '....pause'              ; E1  -> 5A
         db        '....ready'              ; FA  -> 5B
         db        '...repeat'              ; FE  -> 5C
         db        '.....full'              ; FF  -> 5D

BuffEnd  dw        Buffer                   ; ukl dac¡ adresa do bufferu
Buffer   label     byte                     ; buffer s uschovan˜m stavem

; Obsah: 0: (1) znak z portu [60h]
;        1: (1) rezerva
;        2: (1) 0040:0017
;        3: (1) 0040:0018
;        4: (1) 0040:0096
;        5: (1) 0040:0097
;        6: (2) slovo z bufferu (-1 = nen¡)

Code     ENDS
         END       Start

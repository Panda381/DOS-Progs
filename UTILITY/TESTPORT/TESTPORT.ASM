
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         call      DispTxt

; ------ detekce syst‚mov˜ch adres COM

         mov       di,offset TabCom
         xor       si,si
         cli
Start1:  push      ds
         mov       ax,40h
         mov       ds,ax
         mov       dx,ds:[si]
         inc       si
         inc       si
         pop       ds
         or        dx,dx
         jz        Start2
         call      DetCom                   ; test portu COM
Start2:  cmp       si,8
         jb        Start1

; ------ detekce standardn¡ch adres COM

         mov       dx,3f8h
         call      SrcCom
         jnc       Start22
         call      DetCom

Start22: mov       dx,2f8h
         call      SrcCom
         jnc       Start23
         call      DetCom

Start23: mov       dx,3e8h
         call      SrcCom
         jnc       Start24
         call      DetCom

Start24: mov       dx,2e8h
         call      SrcCom
         jnc       Start26
         call      DetCom

; ------ zobrazen¡ adres COM

Start26:; mov       dx,offset SerTxt
        ; call      DispTxt
;         mov       cl,ds:[NumCom]           ; po‡et port– COM
;         mov       ch,0
;         mov       dx,offset NicTxt         ; text - nen¡ ‘ dn˜ port
;         jcxz      Start38                  ; nen¡ ‘ dn˜ port
;         mov       si,offset TabCom         ; tabulka detekovan˜ch port– COM
;
;Start32: mov       ax,ds:[si]               ; adresa portu COM
;         call      DispWord
;
;         xchg      ax,dx
;         call      SrcCom
;         mov       byte ptr ds:[Com2Txt+5],"x"
;         jc        Start33
;         add       al,"1"
;         mov       ds:[Com2Txt+5],al
;Start33: mov       dx,offset Com2Txt
;         call      DispTxt
;
;         dec       cx
;         jz        Start34                  ; jsou ji‘ v¨echny porty COM
;
;         add       si,6
;         mov       dx,offset CarTxt
;         call      DispTxt
;         jmp       short Start32
;
;Start34: mov       dx,offset CrTxt          ; od© dkov n¡
;Start38: call      DispTxt

; ------ zobrazen¡ stavu port– COM

Start39:
         mov       si,offset TabCom
         mov       cl,ds:[NumCom]
         mov       ch,0

Start391:or        cx,cx
         jnz       Star3911
         jmp       Start400
Star3911:mov       byte ptr ds:[ComTxt+5],"x"
         mov       dx,ds:[si]
         call      SrcCom
         jc        Start392
         add       al,"1"
         mov       ds:[ComTxt+5],al
Start392:mov       dx,offset ComTxt
         call      DispTxt

         mov       ax,ds:[si]
         call      DispWord

         mov       al,","
         call      DispChr
         mov       al," "
         call      DispChr

         mov       al,ds:[si+4]
         and       ax,3
         add       al,5
         call      DispNum

         mov       dx,offset bitTxt
         call      DispTxt

         mov       dx,offset ParNTxt
         test      byte ptr ds:[si+4],8
         jz        Start394
         mov       dx,offset ParSTxt
         test      byte ptr ds:[si+4],10h
         jnz       Start394
         mov       dx,offset ParLTxt
Start394:call      DispTxt

         mov       dx,offset Bit1Txt
         test      byte ptr ds:[si+4],4
         jz        Start395
         mov       dx,offset Bit2Txt
         test      byte ptr ds:[si+4],3
         jnz       Start395
         mov       dx,offset Bit15Txt
Start395:call      DispTxt

         mov       ax,1
         cmp       word ptr ds:[si+2],0
         je        Start393
         cmp       word ptr ds:[si+2],1
         jne       Star3942
         mov       al,"1"
         call      DispChr
         mov       ax,15200
         jmp       short Start393
Star3942:mov       ax,0c200h
         mov       dx,1
         div       word ptr ds:[si+2]
Start393:call      DispNum

         mov       dx,offset BaudTxt
         call      DispTxt


         call      TestCom                  ; test portu COM

         mov       al,ds:[si+5]
         mov       dx,offset NeniTxt
         cmp       al,0ffh
         je        Start397
         mov       ah,0
         call      DispNum
         jmp       short Start398
Start397:call      DispTxt

Start398:
         mov       dx,offset CrTxt
         call      DispTxt
         add       si,6
         dec       cx
         jmp       Start391

; ------ detekce syst‚mov˜ch adres LPT

Start400:
         mov       di,offset TabLpt
         mov       si,8
         cli
Start4:  push      ds
         mov       ax,40h
         mov       ds,ax
         mov       dx,ds:[si]
         inc       si
         inc       si
         pop       ds
         or        dx,dx
         jz        Start41
         call      DetLpt                   ; test portu LPT
Start41: cmp       si,10h
         jb        Start4

; ------ detekce standardn¡ch adres LPT

         mov       dx,3bch
         call      SrcLpt
         jnc       Start42
         call      DetLpt

Start42: mov       dx,378h
         call      SrcLpt
         jnc       Start43
         call      DetLpt

Start43: mov       dx,278h
         call      SrcLpt
         jnc       Start46
         call      DetLpt

; ------ zobrazen¡ adres LPT

Start46:; mov       dx,offset ParTxt
        ; call      DispTxt
;         mov       cl,ds:[NumLpt]           ; po‡et port– LPT
;         mov       ch,0
;         mov       dx,offset NicTxt         ; text - nen¡ ‘ dn˜ port
;         jcxz      Start58                  ; nen¡ ‘ dn˜ port
;         mov       si,offset TabLpt         ; tabulka detekovan˜ch port– LPT
;
;Start52: cld
;         lodsw                              ; adresa portu LPT
;         call      DispWord
;
;         xchg      ax,dx
;         call      SrcLpt
;         mov       byte ptr ds:[Lpt2Txt+5],"x"
;         jc        Start53
;         add       al,"1"
;         mov       ds:[Lpt2Txt+5],al
;Start53: mov       dx,offset Lpt2Txt
;         call      DispTxt
;
;         dec       cx
;         jz        Start54                  ; jsou ji‘ v¨echny porty LPT
;
;         mov       dx,offset CarTxt
;         call      DispTxt
;         jmp       short Start52
;
;Start54: mov       dx,offset CrTxt          ; od© dkov n¡
;Start58: call      DispTxt

; ------ detekce hern¡ho portu

;         mov       dx,offset HerTxt
;         call      DispTxt

         mov       dx,201h                  ; adresa joysticku
         call      DetGame                  ; detekce hern¡ho portu

;         mov       dx,offset NicTxt
         test      al,0fh
         jz        Start79                  ; nen¡ joystick

;         push      ax
;
;         mov       dx,offset GamBTxt
;         test      al,3
;         jz        Start64                  ; je pouze joystick B
;         mov       dx,offset GamATxt
;         test      al,0ch
;         jz        Start64                  ; je jen joystick A
;         mov       dx,offset GamABTxt
;
;Start64: mov       ax,201h
;         call      DispWord                 ; zobrazen¡ adresy portu
;
;         call      DispTxt                  ; zobrazen¡ joystick–
;
;         pop       ax

; ------ zobrazen¡ stavu joystick–
;þ
         mov       byte ptr ds:[GamTxt+15],"A"
Start65: push      ax

         test      al,3
         jz        Start69                  ; nen¡ joystick

         mov       dx,offset GamTxt
         call      DispTxt

         mov       dx,offset Smer1Txt
         test      al,2
         jz        Start66                  ; pouze smˆr X
         mov       dx,offset Smer2Txt
         test      al,1
         jz        Start66                  ; pouze smˆr Y
         mov       dx,offset Smer3Txt       ; mo‘n‚ oba smˆry
Start66: call      DispTxt                  ; zobrazen¡ smˆru

         mov       dx,offset Tlac3Txt
         test      al,30h
         jz        Start67                  ; obˆ tla‡¡tka
         mov       dx,offset Tlac2Txt
         test      al,20h
         jz        Start67                  ; je tla‡¡tko 2
         mov       dx,offset Tlac1Txt
         test      al,10h
         jnz       Start68                  ; nen¡ ‘ dn‚ tla‡¡tko
Start67: call      DispTxt                  ; zobrazen¡ tla‡¡tek

Start68:
         mov       dx,offset CrTxt
         call      DispTxt

Start69: pop       ax
         shr       al,1
         shr       al,1
         inc       byte ptr ds:[GamTxt+6]
         cmp       byte ptr ds:[GamTxt+6],"B"
         jbe       Start65

Start79:
         int       20h

; -----------------------------------------------------------------------------
;        test joysticku DX (-> AL=zmˆna portu)
; -----------------------------------------------------------------------------

DetGame  PROC      NEAR

         push      ds
         xor       ax,ax
         mov       ds,ax

; ------ inicializace portu

         out       dx,al                    ; inicializace portu

; ------ ‡ek n¡ na zah jen¡ mˆ©en¡

         sti
         mov       cx,2                     ; maxim ln¡ doba
         mov       ah,0
DetGame1:mov       bx,ds:[46ch]
DetGame2:in        al,dx
         and       al,0fh
         or        ah,al
         cmp       ah,0fh
         je        DetGame3
         cmp       bx,ds:[46ch]
         je        DetGame2
         loop      DetGame1

; ------ ‡ek n¡ na konec mˆ©en¡

DetGame3:mov       cl,2                     ; maxim ln¡ doba
DetGame4:mov       bx,ds:[46ch]             ; hodiny
DetGame5:in        al,dx
         test      al,0fh
         jz        DetGame6                 ; konec mˆ©en¡
         cmp       bx,ds:[46ch]
         je        DetGame5
         loop      DetGame4

DetGame6:xor       al,ah                    ; zmˆnˆn‚ bity

         pop       ds
         ret

DetGame  ENDP

; -----------------------------------------------------------------------------
;  nalezen¡ adresy COM DX v tabulce BIOS (-> AL=‡¡slo portu 0 a‘ 3, CY=nen¡)
; -----------------------------------------------------------------------------

SrcCom   PROC      NEAR

         push      ds
         push      si

         mov       al,0
         mov       si,40h
         mov       ds,si
         xor       si,si

SrcCom2: cmp       ds:[si],dx
         je        SrcCom3
         inc       si
         inc       si
         inc       ax
         cmp       al,4
         jne       SrcCom2
         stc

SrcCom3: pop       si
         pop       ds
         ret

SrcCom   ENDP

; -----------------------------------------------------------------------------
;  nalezen¡ adresy LPT DX v tabulce BIOS (-> AL=‡¡slo portu 0 a‘ 3, CY=nen¡)
; -----------------------------------------------------------------------------

SrcLpt   PROC      NEAR

         push      ds
         push      si

         mov       al,0
         mov       si,40h
         mov       ds,si
         mov       si,8

SrcLpt2: cmp       ds:[si],dx
         je        SrcLpt3
         inc       si
         inc       si
         inc       ax
         cmp       al,4
         jne       SrcLpt2
         stc

SrcLpt3: pop       si
         pop       ds
         ret

SrcLpt   ENDP

; -----------------------------------------------------------------------------
;        detekce portu LPT (adresa DX, DI=ukl dac¡ adresa -> CY=nen¡)
; -----------------------------------------------------------------------------

DetLpt   PROC      NEAR

         cli
         mov       ds:[di],dx               ; £schova adresy portu LPT

; ------ £schova stavu portu

         in        al,dx
         mov       ah,al

; ------ test portu

         mov       al,0aah
         call      SetLpt
         jc        DetLpt9

; ------ n vrat stavu portu

         mov       al,ah
         call      SetLpt
         jc        DetLpt9

; ------ port plat¡ OK

         inc       byte ptr ds:[NumLpt]     ; ‡¡ta‡ port– LPT
         inc       di
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
DetLpt9: ret

DetLpt   ENDP

; -----------------------------------------------------------------------------
;        test jednoho bajtu LPT (CY=chyba)
; -----------------------------------------------------------------------------

SetLpt   PROC      NEAR

         push      ax

         out       dx,al
         mov       ah,al
         jmp       short $+2
         in        al,dx
         cmp       al,ah
         je        SetLpt3
         stc

SetLpt3: pop       ax
         ret

SetLpt   ENDP

; -----------------------------------------------------------------------------
;        test portu COM (ukazatel DS:SI)
; -----------------------------------------------------------------------------

TestCom  PROC      NEAR

; ------ £schova registr–

         cli
         push      cx
         push      si
         mov       ds:[UkazPort],si         ; £schova ukazatele parametr–
         mov       ax,ds:[si]               ; b zov  adresa portu
         mov       ds:[AdrPort],ax          ; adresa portu COM

; ------ £schova obsluh p©eru¨en¡

         mov       si,offset NumInt         ; ‡¡sla p©eru¨en¡
         mov       di,offset OldInt         ; tabulka k £schovˆ p©eru¨en¡
         mov       cx,9
TestCom1:cld
         lodsb
         mov       ah,35h
         int       21h                      ; adresa p©eru¨en¡
         mov       ds:[di],bx
         mov       ds:[di+2],es
         add       di,4
         loop      TestCom1

; ------ instalace obsluh p©eru¨en¡

         mov       si,offset NumInt         ; ‡¡sla p©eru¨en¡
         mov       di,offset AdrInt         ; adresy p©eru¨en¡
         mov       cx,9
TestCom2:cld
         lodsb
         mov       ah,25h
         mov       dx,ds:[di]
         inc       di
         inc       di
         int       21h
         loop      TestCom2

; ------ instalace masky p©eru¨en¡

         in        al,[21h]
         mov       ds:[OldMask2],al
         and       al,00000111b
         out       [21h],al
         in        al,[0a1h]
         mov       ds:[OldMaskA],al
         and       al,11100001b
         out       [0a1h],al

; ------ inicializace tabulek

         push      cs
         pop       es
         mov       di,offset CitInt
         cld
         mov       cx,9
         xor       ax,ax
         rep       stosw
         mov       ds:[CitDat],ax

; ------ inicializace portu

         mov       dx,ds:[AdrPort]

         add       dx,4
         mov       al,1000b
         out       dx,al                    ; 4: ©¡dic¡ registr modemu

         dec       dx
         mov       al,10000000b
         out       dx,al                    ; 3: ©¡dic¡ registr linky

         dec       dx
         dec       dx
         mov       al,0
         out       dx,al                    ; dˆlic¡ konstanta HIGH
         dec       dx
         inc       ax
         out       dx,al                    ; dˆlic¡ konstanta LOW

         add       dx,3
         mov       al,00000000b
         out       dx,al

         dec       dx
         dec       dx
         mov       al,2
         out       dx,al

         dec       dx
         mov       al,16h
         out       dx,al

; ------ ‡ek n¡ na vysl n¡ dat

TestCom4:xor       ax,ax
         mov       es,ax
         mov       cx,4

TestCm41:mov       bx,es:[46ch]
TestCm42:sti
         cmp       word ptr ds:[CitDat],800
         jae       TestCm44
         cmp       bx,es:[46ch]
         je        TestCm42
         mov       dx,ds:[AdrPort]
         mov       al,16h
         out       dx,al
         loop      TestCm41

; ------ stanoven¡ ‡¡sla p©eru¨en¡

TestCm44:mov       si,offset CitInt
         mov       cx,9
         xor       ax,ax
         mov       dx,si
TestCm45:cmp       ax,ds:[si]
         jae       TestCm46
         mov       ax,ds:[si]
         mov       dx,si
TestCm46:inc       si
         inc       si
         loop      TestCm45

         mov       si,ds:[UkazPort]
         mov       byte ptr ds:[si+5],-1
         cmp       ax,350
         jb        TestCm48
         sub       dx,offset CitInt - 2*3
         shr       dx,1
         cmp       dl,8
         jb        TestCm47
         inc       dx
TestCm47:mov       ds:[si+5],dl
TestCm48:

; ------ n vrat nastaven¡ portu

         mov       si,ds:[UkazPort]         ; ukazatel parametr–
         mov       dx,ds:[AdrPort]
         add       dx,3
         mov       al,80h
         out       dx,al
         dec       dx
         dec       dx
         mov       al,ds:[si+3]
         out       dx,al                    ; dˆli‡ka HIGH
         dec       dx
         mov       al,ds:[si+2]
         out       dx,al                    ; dˆli‡ka LOW
         add       dx,3
         mov       al,ds:[si+4]
         out       dx,al                    ; n vrat ©¡dic¡ho registru linky

; ------ n vrat masky p©eru¨en¡

         mov       al,ds:[OldMask2]
         out       [21h],al
         mov       al,ds:[OldMaskA]
         out       [0a1h],al

; ------ n vrat obsluh p©eru¨en¡

         mov       si,offset NumInt         ; ‡¡sla p©eru¨en¡
         mov       di,offset OldInt         ; p–vodn¡ p©eru¨en¡
         mov       cx,9
TestCom9:cld
         lodsb
         push      ds
         mov       dx,ds:[di]
         mov       ds,ds:[di+2]
         add       di,4
         mov       ah,25h
         int       21h
         pop       ds
         loop      TestCom9

; ------ n vrat registr–

         pop       si
         pop       cx
         ret

TestCom  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Bh
; -----------------------------------------------------------------------------

Int0B    PROC      FAR

         push      si
         mov       si,offset CitInt
         jmp       short IntCom

Int0B    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Ch
; -----------------------------------------------------------------------------

Int0C    PROC      FAR

         push      si
         mov       si,offset CitInt+2
         jmp       short IntCom

Int0C    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Dh
; -----------------------------------------------------------------------------

Int0D    PROC      FAR

         push      si
         mov       si,offset CitInt+4
         jmp       short IntCom

Int0D    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Eh
; -----------------------------------------------------------------------------

Int0E    PROC      FAR

         push      si
         mov       si,offset CitInt+6
         jmp       short IntCom

Int0E    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Fh
; -----------------------------------------------------------------------------

Int0F    PROC      FAR

         push      si
         mov       si,offset CitInt+8
         jmp       short IntCom

Int0F    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 71h
; -----------------------------------------------------------------------------

Int71    PROC      FAR

         push      si
         mov       si,offset CitInt+10
         jmp       short IntCom1

Int71    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 72h
; -----------------------------------------------------------------------------

Int72    PROC      FAR

         push      si
         mov       si,offset CitInt+12
         jmp       short IntCom1

Int72    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 73h
; -----------------------------------------------------------------------------

Int73    PROC      FAR

         push      si
         mov       si,offset CitInt+14
         jmp       short IntCom1

Int73    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 74h
; -----------------------------------------------------------------------------

Int74    PROC      FAR

         push      si
         mov       si,offset CitInt+16

Int74    ENDP

; -----------------------------------------------------------------------------
;        p©eru¨en¡ od portu COM
; -----------------------------------------------------------------------------

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡ #2

IntCom1: push      ax
         mov       al,20h
         out       [0a0h],al
         pop       ax

; ------ £schova registr–

IntCom:  push      ax
         push      dx

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡ #1

         mov       al,20h
         out       [20h],al

; ------ test, zda je p©eru¨en¡ od portu COM

IntCom3: mov       dx,cs:[AdrPort]          ; adresa portu COM
         inc       dx
         inc       dx
         in        al,dx
         and       al,7
         cmp       al,2                     ; je p©eru¨en¡ od vys¡la‡e ?
         jne       IntCom9                  ; nen¡ p©eru¨en¡ od vys¡la‡e

; ------ vysl n¡ dal¨¡ho bajtu

         dec       dx
         dec       dx
         mov       al,16h
         out       dx,al

; ------ zv˜¨en¡ ‡¡ta‡e dat

         inc       word ptr cs:[si]         ; zv˜¨en¡ ‡¡ta‡e dat
         inc       word ptr cs:[CitDat]     ; zv˜¨en¡ ‡¡ta‡e dat

; ------ n vrat registr–

IntCom9: pop       dx
         pop       ax
         pop       si
         iret

; -----------------------------------------------------------------------------
;        detekce portu COM (adresa DX, DI=ukl dac¡ adresa -> CY=nen¡)
; -----------------------------------------------------------------------------

DetCom   PROC      NEAR

         cli
         mov       ds:[di],dx               ; £schova adresy portu COM

; ------ £schova stavu registru linky

         push      dx
         add       dx,3
         in        al,dx                    ; stav registru linky
         mov       ds:[di+4],al             ; £schova registru linky
         pop       dx

; ------ test registru linky

         and       al,not 80h
         call      SetLCom
         jc        DetCom9                  ; neplatn˜ port COM

; ------ nastaven¡ registru dˆli‡ky

         or        al,80h
         call      SetLCom                  ; zapnut¡ registru dˆli‡ky
         jc        DetCom9

; ------ ‡ten¡ registru dˆli‡ky

         inc       dx
         in        al,dx
         mov       ah,al
         dec       dx
         in        al,dx
         mov       ds:[di+2],ax             ; £schova stavu dˆli‡ky

; ------ test registru dˆli‡ky

         xor       al,80h                   ; zmˆna bitu 7
         out       dx,al
         jmp       short $+2
         mov       ah,al                    ; £schova dˆli‡ky LOW
         in        al,dx
         cmp       al,ah
         stc
         jne       DetCom9                  ; nen¡ platn˜ registr dˆli‡ky
         xor       al,80h
         out       dx,al                    ; n vrat registru dˆli‡ky

; ------ n vrat ©¡dic¡ho registru linky

         mov       al,ds:[di+4]             ; p–vodn¡ registr linky
         call      SetLCom                  ; n vrat registru linky
         jc        DetCom9                  ; chyba

; ------ port COM je platn˜ - zv˜¨en¡ ukl dac¡ adresy

         inc       byte ptr ds:[NumCom]     ; ‡¡ta‡ port– COM
         add       di,6                     ; zv˜¨en¡ ukl dac¡ adresy

DetCom9: ret

DetCom   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ©¡dic¡ho registru linky COM (adresa DX) na AL -> CY chyba
; -----------------------------------------------------------------------------

SetLCom  PROC      NEAR

         push      ax
         push      dx

         add       dx,3
         out       dx,al
         mov       ah,al
         jmp       short $+2
         in        al,dx
         cmp       al,ah
         je        SetLCom3
         stc                                ; p©¡znak chyby portu

SetLCom3:pop       dx
         pop       ax
         ret

SetLCom  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         xor       cx,cx
         mov       bx,10
DispNum1:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

DispNum2:pop       ax
         add       al,"0"
         call      DispChr
         loop      DispNum2

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ slova HEX (AX)
; -----------------------------------------------------------------------------

DispWord PROC      NEAR

         call      DispWrd
         push      ax
         mov       al,"h"
         call      DispChr
         pop       ax
         ret

DispWord ENDP

DispWrd  PROC      NEAR

         push      ax
         mov       al,ah
         call      DispByte
         pop       ax

DispByte:push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHex
         pop       ax

DispHex: push      ax
         and       al,0fh
         cmp       al,10
         jb        DispHex2
         add       al,7
DispHex2:add       al,"0"
         call      DispChr
         pop       ax
         ret

DispWrd  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx

         mov       dl,al
         mov       ah,2
         int       21h

         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

NumInt   db        0bh,0ch,0dh,0eh,0fh,71h,72h,73h,74h ; ‡¡sla p©eru¨en¡
AdrInt   dw        Int0B,Int0C,Int0D,Int0E,Int0F,Int71,Int72,Int73,Int74
OldInt   dd        9 dup(0)                 ; tabulka p–vodn¡ch adres p©eru¨en¡

OldMask2 db        0                        ; uschovan  maska p©eru¨en¡ 21h
OldMaskA db        0                        ; uschovan  maska p©eru¨en¡ A1h

UkazPort dw        0                        ; ukazatel parametr– COM
AdrPort  dw        0                        ; adresa testovan‚ho portu COM
CitDat   dw        0                        ; ‡¡ta‡ vyslan˜ch dat COM
CitInt   dw        9 dup(0)                 ; ‡¡ta‡ p©eru¨en¡ IRQ 3 - 7, 9-12

UvTxt    db        'TESTPORT - test portu COM, LPT a GAME; (c) Miroslav Nemecek',13,10,'$'

;SerTxt   db        'Seriove porty COM   : $'
;ParTxt   db        'Paralelni porty LPT : $'
;HerTxt   db        'Herni port+joystick : $'

CarTxt   db        ', $'
NicTxt   db        '  -',
CrTxt    db        13,10,'$'

ComTxt   db        '  COMx: $'
LptTxt   db        '  LPTx: $'
GamTxt   db        '  JoyA: 0201h, mozny smer $'
BaudTxt  db        ' Baud, IRQ $'
BitTxt   db        ' bitu$'
NeniTxt  db        ' -$'

;Com2Txt  db        ' (COMx)$'
;Lpt2Txt  db        ' (LPTx)$'
;GamATxt  db        ' (joystick A)$'
;GamBTxt  db        ' (joystick B)$'
;GamABTxt db        ' (joysticky A a B)$'

Smer1Txt db        'X$'
Smer2Txt db        'Y$'
Smer3Txt db        'X a Y$'

Tlac1Txt db        ', stisknuto tlacitko 1$'
Tlac2Txt db        ', stisknuto tlacitko 2$'
Tlac3Txt db        ', stisknuta tlacitka 1 a 2$'

ParNTxt  db        ' bez parity, $'
ParLTxt  db        ', parita LICHA, $'
ParSTxt  db        ', parita SUDA, $'

Bit1Txt  db        '1 STOP bit, $'
Bit15Txt db        '1.5 STOP bitu, $'
Bit2Txt  db        '2 STOP bity, $'

NumCom   db        0                        ; po‡et port– COM
TabCom   db        8 dup(6 dup(0))          ; tabulka port– COM
                                            ;  0: (2) b zov  adresa portu COM
                                            ;  2: (2) dˆli‡ka
                                            ;  4: (1) ©¡dic¡ registr linky
                                            ;  5: (1) ‡¡slo IRQ (0ffh=nen¡)

NumLpt   db        0                        ; po‡et port– LPT
TabLpt   dw        7 dup(0)                 ; tabulka adres LPT

Code     ENDS
         END       Start

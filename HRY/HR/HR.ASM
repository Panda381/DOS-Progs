


Code     SEGMENT
         ASSUME    cs:code,ds:data

MaxBuff  EQU       1000h                    ; velikost diskov‚ho bufferu
Nasob08  EQU       64                       ; n sobek INT 08h (= 0.8 ms)
MaxTerX  EQU       128                      ; maxim ln¡ rozmˆr ter‚nu (1/16)
MaxObrX  EQU       14                       ; rozmˆr obr zku X (1/16)
MaxTerY  EQU       128                      ; maxim ln¡ rozmˆr ter‚nu (1/16)
MaxObrY  EQU       11                       ; rozmˆr obr zku Y (1/16)

TopVRAM  EQU       12*40+1                  ; po‡ te‡n¡ offset obr zku

Start:

; -----------------------------------------------------------------------------
;                       inicializace programu
; -----------------------------------------------------------------------------

; ------ inicializace registr–

         sti                                ; p©eru¨en¡ povoleno
         mov       ax,SEG Data              ; datov˜ segment
         mov       ds,ax                    ; datov˜ segment
         mov       ds:[SegPSP],es           ; £schova segmentu PSP

; ------ £schova aktivn¡ho videom¢du

         mov       ah,0fh
         int       10h                      ; poskytnut¡ aktivn¡ho videom¢du
         mov       ds:[OldVMod],al          ; aktivn¡ videom¢d

; ------ test, zda je grafick  karta EGA/VGA

         mov       ah,12h                   ; funkce poskytnut¡ informac¡ EGA
         mov       bx,5810h                 ; podslu‘ba informac¡ o EGA
         int       10h                      ; poskytnut¡ informac¡ o EGA
         cmp       bh,2
         ja        Start2                   ; nen¡ karta EGA/VGA
         cmp       bl,5
         ja        Start2                   ; nen¡ karta EGA/VAG

; ------ nastaven¡ pracovn¡ho grafick‚ho m¢du

         mov       ax,13                    ; po‘adovan˜ videom¢d 13
         int       10h                      ; nastaven¡ videom¢du 13
         mov       ah,0fh
         int       10h                      ; poskytnut¡ aktivn¡ho videom¢du
         cmp       al,13                    ; je po‘adovan˜ videom¢d ?
         je        Start3                   ; videom¢d nastaven OK

; ------ chyba - nen¡ grafick  karta EGA/VGA

Start2:  mov       dx,offset ErrCard        ; chybov˜ text - nen¡ EGA/VGA
         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4c01h                 ; funkce n vratu z programu
         int       21h                      ; n vrat z programu

; ------ obsluha p©eru¨en¡ INT 23h

Start3:  push      ds
         push      cs
         pop       ds
         mov       dx,offset Navrat0
         mov       ax,2523h
         int       21h                      ; instalace obsluhy INT 23h

; ------ instalace obsluhy p©eru¨en¡ INT 24h

         mov       dx,offset Int24
         mov       ax,2524h
         int       21h                      ; instalace obsluhy INT 24h

; ------ instalace obsluhy hodin INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ p–vodn¡ adresy INT 08h
         mov       word ptr cs:[Old08],bx   ; offset adresy INT 08
         mov       word ptr cs:[Old08+2],es ; segment adresy INT 08h
         mov       dx,offset Int08
         mov       ax,2508h
         int       21h                      ; instalace nov‚ obsluhy INT 08h

; ------ nastaven¡ ‡¡ta‡e INT 08h

         cli
         mov       al,36h
         out       [43h],al                 ; volba registru 0
         mov       al,LOW (8000h/(Nasob08/2)) ; ni‘¨¡ bajt dˆlic¡ konstanty
         out       [40h],al                 ; ni‘¨¡ bajt dˆli‡ky
         mov       al,HIGH (8000h/(Nasob08/2)) ; vy¨¨¡ bajt dˆlic¡ konstanty
         out       [40h],al                 ; vy¨¨¡ bajt dˆli‡ky
         sti

; ------ instalace obsluhy kl vesnice INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ p–vodn¡ adresy INT 09h
         mov       word ptr cs:[Old09],bx   ; offset adresy INT 09h
         mov       word ptr cs:[Old09+2],es ; segment adresy INT 09h
         mov       dx,offset Int09
         mov       ax,2509h
         int       21h                      ; instalace nov‚ obsluhy INT 09h

         pop       ds

; -----------------------------------------------------------------------------
;                          zobrazen¡ £vodu
; -----------------------------------------------------------------------------

; ------ zobrazen¡ £vodn¡ho textu

         mov       si,offset UvTxt
Uvod1:   cld
         lodsb
         or        al,al
         jz        Uvod2
         push      si
         mov       bx,7
         mov       ah,0eh
         int       10h
         pop       si
         jmp       short Uvod1

; ------ prvn¡ £vodn¡ obr zek

Uvod2:   mov       si,offset SoubUv1        ; prvn¡ £vodn¡ obr zek
         call      UvodKey

; ------ druh˜ £vodn¡ obr zek

         ;mov       si,offset SoubUv2        ; druh˜ £vodn¡ obr zek
         ;call      UvodKey

; ------ t©et¡ £vodn¡ obr zek
         
         mov       si,offset SoubUv3        ; t©et¡ £vodn¡ obr zek
         call      UvodKey

; ------ r m

         mov       si,offset SoubRam        ; r m
         call      UvodKey

; ------ kopie r mu do druh‚ videostr nky

         push      ds
         les       di,ds:[AdrVRAM]          ; pracovn¡ videostr nka
         lds       si,ds:[AdrVRAM]          ; pracovn¡ videostr nka
         xor       si,2000h                 ; zobrazen  videostr nka
         mov       bx,1                     ; ukazatel rovin
Uvod4:   push      si
         push      di
         call      ReadSel                  ; volba ‡tec¡ roviny
         call      WritSel                  ; volba z pisov‚ roviny
         mov       cx,40*200/2              ; d‚lka jedn‚ roviny ve slovech
         cld
         rep       movsw                    ; kopie videostr nky
         pop       di
         pop       si
         shl       bl,1                     ; z pisov  rovina
         inc       bh                       ; ‡tec¡ rovina
         cmp       bh,4                     ; jsou ji‘ v¨echny roviny ?
         jne       Uvod4                    ; kopie dal¨¡ roviny
         pop       ds



;         call      Ztemni
;         call      XPage
;         call      Rozsvit
;

; ------ otev©en¡ sc‚ny

         mov       si,offset SoubTer1
         call      OpenFile                 ; otev©en¡ souboru
         mov       es,ds:[SegTeren]         ; segment vzor– ter‚nu
         xor       di,di                    ; offset adresy
         mov       cx,8000h
CtiSc2:  call      ReadB                    ; na‡ten¡ bajtu
         jc        CtiSc3
         cld
         stosb                              ; ulo‘en¡ bajtu
         loop      CtiSc2
CtiSc3:  call      ClosFile

; ------

         mov       si,offset SoubMap1
         call      OpenFile                 ; otev©en¡ souboru
         push      ds
         pop       es                       ; datov˜ segment
         mov       di,offset TerenMap       ; offset adresy
         mov       cx,MaxTerX*MaxTerY
CtiSc4:  call      ReadB                    ; na‡ten¡ bajtu
         jc        CtiSc5
         cld
         stosb                              ; ulo‘en¡ bajtu
         loop      CtiSc4
CtiSc5:  call      ClosFile

; ------

         mov       si,offset SoubPoz1
         call      OpenFile
         mov       cx,16
ctisc53: call      readb
         jc        ctisc58
         loop      ctisc53
         mov       es,ds:[SegPozad]
         xor       di,di
         mov       cx,MaxObrX*2 * MaxObrY*16 * 4 ; po‡et bajt–
ctisc54: call      readbyte
         jc        ctisc58
         cld
         stosb
         loop      ctisc54
ctisc58: call      ClosFile




         mov       word ptr ds:[TopTeren],offset TerenMap ; mapa ter‚nu
         mov       word ptr ds:[TerenX],0
         mov       word ptr ds:[TerenY],0

ctisc6:
;         mov       cx,60
;         call      cekej

         mov       dx,3dah                  ; stavov˜ registr videokarty
cstisc62:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         test      al,8                     ; je vertik ln¡ impuls ?
         jnz       cstisc62                 ; ‡ek n¡ na konec synchroimpulsu
cstisc63:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         test      al,8                     ; je vertik ln¡ impuls ?
         jz        cstisc63                 ; ‡ek n¡ na vertik ln¡ impuls

         call      Pozadi
         call      Teren                    ; zobrazen¡ ter‚nu

;         mov       ah,8
;         int       21h

;         call      Ztemni

         mov       dx,3dah                  ; stavov˜ registr videokarty
cstisx62:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         test      al,8                     ; je vertik ln¡ impuls ?
         jnz       cstisx62                 ; ‡ek n¡ na konec synchroimpulsu
cstisx63:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         test      al,8                     ; je vertik ln¡ impuls ?
         jz        cstisx63                 ; ‡ek n¡ na vertik ln¡ impuls
         call      XPage
;         call      Rozsvit


;         call      TestKey
;         jc        ctisc6

;         call      InpKey
;         cmp       ah,4bh                   ; kurzor vlevo
;         jne       vstup1

         cmp       byte ptr cs:[TabKey+4bh],0 ; kurzor nahoru ?
         je        vstup1

         cmp       word ptr ds:[TerenX],0
         je        vstup1
         dec       word ptr ds:[TerenX]
         test      word ptr ds:[TerenX],1
         jz        vstup1
         dec       word ptr ds:[topteren]

vstup1: ; cmp       ah,4dh                   ; kurzor vpravo
        ; jne       vstup2
         cmp       byte ptr cs:[TabKey+4dh],0 ; kurzor vpravo ?
         je        vstup2


         cmp       word ptr ds:[TerenX],(MaxTerX-MaxObrX)*2
         je        vstup2
         inc       word ptr ds:[terenx]
         test      word ptr ds:[Terenx],1
         jnz       vstup2
         inc       word ptr ds:[topteren]

vstup2: ; cmp       ah,48h                   ; kurzor nahoru
        ; jne       vstup3
         cmp       byte ptr cs:[TabKey+48h],0 ; kurzor nahoru ?
         je        vstup3

         cmp       word ptr ds:[TerenY],0
         je        vstup3
         dec       word ptr ds:[TerenY]
         dec       word ptr ds:[TerenY]
         sub       word ptr ds:[topteren],MaxTerX

vstup3: ; cmp       ah,50h                   ; kurzor dol–
        ; jne       vstup4
         cmp       byte ptr cs:[TabKey+50h],0 ; kurzor dol– ?
         je        vstup4

         cmp       word ptr ds:[TerenX],(MaxTerY-MaxObrY)*2
         je        vstup4
         inc       word ptr ds:[tereny]
         inc       word ptr ds:[tereny]
         add       word ptr ds:[topteren],MaxTerX


vstup4:  mov       ax,cs:[KeyBuf]
         cmp       al,27
         je        navrat0

         jmp       ctisc6


Navrat0:
         mov       dx,offset ErrOK
Navrat:
         mov       ax,SEG Data
         mov       ds,ax                    ; datov˜ segment

; ------ n vrat p–vodn¡ho videom¢du

         push      dx
         mov       al,ds:[OldVMod]          ; p–vodn¡ vidoem¢d
         xor       ah,ah
         int       10h                      ; nastaven¡ p–vodn¡ho videom¢du

; ------ nastaven¡ ‡¡ta‡e INT 08h

         cli
         mov       al,36h
         out       [43h],al                 ; volba registru 0
         xor       al,al
         out       [40h],al                 ; ni‘¨¡ bajt dˆli‡ky
         out       [40h],al                 ; vy¨¨¡ bajt dˆli‡ky
         sti

; ------ n vrat p–vodn¡ obsluhy INT 08h

         push      ds
         lds       dx,cs:[Old08]            ; p–vodn¡ obsluha INT 08h
         mov       ax,2508h
         int       21h                      ; nastaven¡ p–vodn¡ obsluhy INT 08h

; ------ n vrat p–vodn¡ obsluhy INT 09h

         lds       dx,cs:[Old09]            ; p–vodn¡ obsluha INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat p–vodn¡ obsluhy INT 09h
         pop       ds

         pop       dx

; ------ zobrazen¡ p©¡padn‚ho chybov‚ho hl ¨en¡

         mov       ah,9
         int       21h

; ------ konec programu

         mov       ax,4c00h
         int       21h                      ; n vrat z programu

; -----------------------------------------------------------------------------
;        obsluha INT 24h
; -----------------------------------------------------------------------------

Int24    PROC      FAR

         xor       al,al                    ; chyby se budou ignorovat
         iret

Int24    ENDP

; -----------------------------------------------------------------------------
;        vstup z kl vesnice p©i zah jen¡, zobrazen¡ obr zku DS:SI
; -----------------------------------------------------------------------------

UvodKey  PROC      NEAR

         call      ReadObr                  ; na‡ten¡ obr zku

         call      InpKey                   ; vstup znaku z kl vesnice
         jne       UvodKey2
         jmp       Navrat0
UvodKey2:
         call      Ztemni
         call      xpage
         call      Rozsvit
         ret

UvodKey  ENDP

; *****************************************************************************
;
;                          Obsluha kl vesnice
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        test, zda je p©ipraven znak z kl vesnice (CY=nen¡)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

         cmp       word ptr cs:[KeyBuf],0   ; je v bufferu p©ipraven znak ?
         jnz       TestKey2                 ; v bufferu je p©ipraven znak
         stc                                ; p©¡znak chyby - nen¡ znak
TestKey2:ret

TestKey  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na znak z kl vesnice (ZY=p©eru¨en¡ ESC)
; -----------------------------------------------------------------------------

InpKey   PROC      NEAR

         sti
InpKey1: xor       ax,ax                    ; AX <- 0
         xchg      ax,cs:[KeyBuf]           ; vyjmut¡ znaku z bufferu
         or        ax,ax                    ; byl v bufferu znak ?
         jnz       InpKey2                  ; v bufferu byl platn˜ znak
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ programu
         jmp       short InpKey1            ; dal¨¡ ‡ek n¡
InpKey2: cmp       al,27                    ; je p©eru¨en¡ ESC ?
         ret

InpKey   ENDP

; -----------------------------------------------------------------------------
;        Obsluha kl vesnice INT 09h
; -----------------------------------------------------------------------------

Old09    dd        0                        ; p–vodn¡ obsluha INT 09h

;ExtKey   dw        0                        ; povolen¡ re‘imu roz¨¡©. kl vesnice
KeyBuf   dw        0                        ; buffer posledn¡ kl vesy

Int09    PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      ds

; ------ p©¡prava datov‚ho segmentu BIOS

         mov       bx,40h
         mov       ds,bx                    ; datov˜ segment BIOS

; ------ ‡ten¡ k¢du stisknut‚ kl vesy, kontrola k¢du kl vesy

         in        al,[60h]                 ; ‡ten¡ k¢du kl vesy
         mov       bx,ax                    ; k¢d kl vesy
         and       bx,7fh                   ; k¢d kl vesy bez bitu 7
         jz        Int097                   ; je k¢d 0 - nepovolen  kl vesa
         cmp       bl,59h                   ; je povolen˜ k¢d kl vesy ?
;         cmp       bl,60h                   ; je povolen˜ k¢d kl vesy ?
         jae       Int097                   ; tento k¢d kl vesy je nezn m˜

;; ------ nastaven¡ ukazatele kl vesy v bufferu
;
;         cmp       byte ptr cs:[ExtKey],0   ; je povolena roz¨¡©en  kl vesnice ?
;         je        Int093                   ; roz¨¡©en  kl vesnice nepovolena
;         test      byte ptr ds:[496h],2     ; je roz¨¡©en˜ k¢d kl vesy ?
;         jz        Int093                   ; nen¡ roz¨¡©en˜ k¢d kl vesy
;         cmp       bl,47h                   ; je kl vesa v numerick‚m poli ?
;         jb        Int092                   ; nen¡ kl vesa v numerick‚m poli
;         cmp       bl,53h                   ; max. kl vesa v num. poli
;         ja        Int092                   ; nen¡ kl vesa v numerick‚m poli
;         add       bl,60h-47h               ; posun k¢du
;         jmp       short Int093
;Int092:  cmp       bl,1ch                   ; je Enter ?
;         jne       Int0922                  ; nen¡ Enter
;         mov       bl,6fh                   ; je Enter v numerick‚m poli
;         jmp       short Int093
;Int0922: cmp       bl,1dh                   ; je Ctrl ?
;         jne       Int0923                  ; nen¡ Ctrl
;         mov       bl,6dh                   ; je prav˜ Ctrl
;         jmp       short Int093
;Int0923: cmp       bl,38h                   ; je Alt ?
;         jne       Int0924                  ; nen¡ Alt
;         mov       bl,64h                   ; je prav˜ Alt
;         jmp       short Int093
;Int0924: cmp       bl,35h                   ; je / ?
;         jne       Int0925                  ; nen¡ /
;         mov       bl,70h                   ; je [/] v numerick‚m poli
;Int0925:

; ------ rozli¨en¡ stisku a uvolnˆn¡

Int093:  mov       cs:[TabKey],bl           ; £schova k¢du posledn¡ kl vesy
         test      al,80h                   ; je stisk kl vesy ?
         jz        Int094                   ; je stisk kl vesy

; ------ je uvolnˆn¡ kl vesy

         mov       byte ptr cs:[bx+TabKey],0 ; ozna‡en¡ kl vesy za uvolnˆnou
         jmp       short Int097

; ------ je stisk kl vesy

Int094:  inc       byte ptr cs:[bx+TabKey]  ; zv˜¨en¡ ‡¡ta‡e stisku kl vesy
         jnz       Int097                   ; nen¡ p©ete‡en¡
         dec       byte ptr cs:[bx+TabKey]  ; navr t¡ se na 0ffh

; ------ standardn¡ obsluha kl vesnice

Int097:  mov       bx,ds:[1ch]              ; £schova ukl dac¡ adresy do bufferu
         pushf
         call      dword ptr cs:[Old09]     ; vol n¡ standardn¡ obsluhy BIOS

; ------ kontrola, zda je v bufferu nˆjak˜ znak

         cmp       bx,ds:[1ch]              ; zmˆnila se ukl dac¡ adresa ?
         je        Int099                   ; nezmˆnila se - nen¡ nov˜ znak

; ------ vyjmut¡ nov‚ho znaku z bufferu

         mov       ax,ds:[bx]               ; vyjmut¡ nov‚ho znaku
         mov       cs:[KeyBuf],ax           ; £schova znaku do bufferu
         mov       ds:[1ch],bx              ; n vrat ukl dac¡ adresy
         mov       ds:[1ah],bx              ; zru¨en¡ ‡tec¡ adresy

; ------ n vrat registr–

Int099:  pop       ds
         pop       bx
         pop       ax
         iret

Int09    ENDP

TabKey   label     byte                     ; tabulka p©¡znak– kl ves

         db        0                        ; 00h: poslednˆ p©ijat  kl vesa
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
         db        0                        ; 2ah: lev˜ Shift
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
         db        0                        ; 36h: prav˜ Shift
         db        0                        ; 37h: [*] Print Screen
         db        0                        ; 38h: Alt
         db        0                        ; 39h: mezern¡k
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
         db        0                        ; 50h: [2] kurzor dol–
         db        0                        ; 51h: [3] Page Down
         db        0                        ; 52h: [0] Insert
         db        0                        ; 53h: [.] Delete
         db        0                        ; 54h: (SysRq - pouze AT 84 kl ves)
         db        0                        ; 55h:
         db        0                        ; 56h: \ | (AT 102 kl ves)
         db        0                        ; 57h: F11 (AT 101 a 102 kl ves)
         db        0                        ; 58h: F12 (AT 101 a 102 kl ves)
;         db        0                        ; 59h:
;         db        0                        ; 5ah:
;         db        0                        ; 5bh:
;         db        0                        ; 5ch:
;         db        0                        ; 5dh:
;         db        0                        ; 5eh:
;         db        0                        ; 5fh:
;
;                                          ;* zde za‡¡naj¡ zdvojen‚ kl vesy
;         db        0                        ; 60h: Home
;         db        0                        ; 61h: kurzor nahoru
;         db        0                        ; 62h: Page Up
;         db        0                        ; 63h:
;         db        0                        ; 64h: kurzor vlevo
;         db        0                        ; 65h: [5]
;         db        0                        ; 66h: kurzor vpravo
;         db        0                        ; 67h:
;         db        0                        ; 68h: End
;         db        0                        ; 69h: kurzor dol–
;         db        0                        ; 6ah: Page Down
;         db        0                        ; 6bh: Insert
;         db        0                        ; 6ch: Delete
;         db        0                        ; 6dh: prav˜ Ctrl
;         db        0                        ; 6eh: prav˜ Alt
;         db        0                        ; 6fh: [Enter]
;         db        0                        ; 70h: [/]


; *****************************************************************************
;
;                             Obsluha soubor–
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;                           na‡ten¡ obr zku DS:SI
; -----------------------------------------------------------------------------

ReadObr  PROC      NEAR

         call      OpenFile                 ; otev©en¡ souboru

         mov       cx,16
ReadObr1:call      ReadB
         jc        ReadObr9
         loop      ReadObr1


         mov       bl,1
ReadObr2:
         call      WritSel                  ; volba z pisov‚ roviny

         les       di,ds:[AdrVRAM]
         mov       cx,40*200
ReadObr3:call      ReadByte
         jc        ReadObr9
         cld
         stosb
         loop      ReadObr3
         shl       bl,1                     ; maska pro dal¨¡ rovinu
         cmp       bl,10h
         jne       ReadObr2                 ; dal¨¡ rovina

ReadObr9:call      ClosFile
         ret


ReadObr  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ jednoho bajtu ze souboru
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

;         test      byte ptr ds:[Param],1    ; je komprese ?
;         jz        ReadB                    ; nen¡ komprese

; ------ na‡ten¡ bajtu po‡tu dat komprese

         cmp       byte ptr ds:[KompCit],0  ; je ‡¡ta‡ platn˜ ?
         jne       ReadByt4                 ; ‡¡ta‡ je dosud platn˜
ReadByt1:call      ReadB                    ; na‡ten¡ bajtu ‡¡ta‡e
         jc        ReadByt5                 ; chyba ‡ten¡ dat
         mov       byte ptr ds:[KompCit],al ; po‡et n sleduj¡c¡ch bajt–

; ------ p©ep¡na‡ m¢du komprese

         or        al,al                    ; je to jen p©ep¡na‡ ?
         jnz       ReadByt2                 ; nen¡ to p©ep¡na‡
         xor       byte ptr ds:[Param0],8   ; zmˆna p©¡znaku komprese
         jmp       short ReadByt1           ; nov‚ ‡ten¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

ReadByt2:and       byte ptr ds:[Param0],not 10h ; zru¨en¡ p©¡znaku komprese
         test      byte ptr ds:[Param0],8    ; je m¢d komprese ?
         jz        ReadByt3                 ; nen¡ m¢d komprese
         or        byte ptr ds:[Param0],10h  ; p©¡znak komprese
         call      ReadB                    ; na‡ten¡ bajtu k opakov n¡
         jc        ReadByt5                 ; chyba ‡ten¡ dat
         mov       ds:[KompChr],al          ; bajt k opakov n¡

; ------ zmˆna p©¡znaku m¢du komprese

ReadByt3:cmp       byte ptr ds:[KompCit],255 ; je zmˆna m¢du komprese ?
         je        ReadByt4                 ; nen¡ zmˆna m¢du komprese
         xor       byte ptr ds:[Param0],8    ; zmˆna p©¡znaku komprese

; ------ na‡ten¡ dal¨¡ho bajtu

ReadByt4:mov       al,ds:[KompChr]          ; bajt p©i opakov n¡ dat
         test      byte ptr ds:[Param0],10h  ; je opakov n¡ dat ?
         jnz       ReadByt5                 ; je opakov n¡ dat
         call      ReadB                    ; na‡ten¡ bˆ‘n‚ho bajtu dat

; ------ sn¡‘en¡ ‡¡ta‡e bajt–

ReadByt5:dec       byte ptr ds:[KompCit]    ; sn¡‘en¡ ‡¡ta‡e komprese
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ bajtu bez komprese
; -----------------------------------------------------------------------------

ReadB:   push      si
         mov       si,ds:[BuffAdr]          ; ukazatel ‡ten˜ch dat z bufferu
         cmp       si,ds:[BuffNum]           ; je ji‘ konec bufferu ?
         jb        ReadB3                   ; jsou je¨tˆ nˆjak  data v bufferu

                                          ;* na‡ten¡ dal¨¡ho bloku dat
         mov       word ptr ds:[BuffAdr],0  ; vynulov n¡ ukazatele dat

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,3fh
         mov       bx,ds:[Ident]
         mov       cx,MaxBuff
         mov       dx,offset Buffer
         int       21h                      ; na‡ten¡ bloku dat z buferu
         jc        ReadB2
         mov       ds:[BuffNum],ax           ; nov˜ po‡et bajt– v bufferu
         or        ax,ax
         jnz       ReadB2
         stc                                ; p©¡znak konce souboru

Readb2:  pop       dx
         pop       cx
         pop       bx
         pop       ax

         mov       si,0
         jc        ReadB4                   ; byla chyba ‡ten¡

ReadB3:  mov       al,ds:[si+Buffer]        ; p©e‡ten¡ bajtu z bufferu
         inc       word ptr ds:[BuffAdr]    ; zv˜¨en¡ ukazatele dat v bufferu
         clc

ReadB4:  pop        si
         ret

; -----------------------------------------------------------------------------
;                  otev©en¡ souboru DS:SI pro ‡ten¡
;             (p©i chybˆ vyp¡¨e hl ¨en¡ a ukon‡¡ program)
; -----------------------------------------------------------------------------

OpenFile PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ otev©en¡ po‘adovan‚ho souboru

         mov       dx,si                    ; adresa jm‚na souboru
         mov       ax,3d00h                 ; otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jnc       OpenFil9                 ; soubor otev©en OK

; ------ soubor nenalezen - p©enesen¡ jm‚na souboru

         mov       di,offset ErrSoub2       ; adresa k ulo‘en¡ jm‚na souboru
         push      ds
         pop       es
         cld
OpenFil2:lodsb
         stosb
         or        al,al
         jnz       OpenFil2                 ; p©enesen¡ jm‚na souboru
         dec       di

; ------ p©enesen¡ zbytku textu hl ¨en¡

         mov       si,offset ErrSoub3       ; text zbytku hl ¨en¡
         mov       cx,offset(ErrSoub4-ErrSoub3) ; d‚lka textu
         rep       movsb                    ; p©enos zbytku textu

; ------ n vrat z programu s chybou

         mov       dx,offset ErrSoub1
         jmp       Navrat                   ; konec programu

; ------ inicializace promˆnn˜ch

OpenFil9:mov       ds:[Ident],ax            ; identifik tor souboru
         mov       word ptr ds:[BuffNum],0  ; nen¡ nic v bufferu
         mov       word ptr ds:[BuffAdr],0
         mov       word ptr ds:[KompCit],0
         mov       byte ptr ds:[Param0],8

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

OpenFile ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ souboru
; -----------------------------------------------------------------------------

ClosFile PROC      NEAR

         push      ax
         push      bx
         mov       bx,ds:[Ident]
         mov       ah,3eh
         int       21h
         pop       bx
         pop       ax
         ret

ClosFile ENDP

; *****************************************************************************
;
;                         Ovl d n¡ hodin
;
; *****************************************************************************

CitInt08 dw        Nasob08                  ; ‡¡ta‡ pro INT 08h
Timer    dw        0                        ; ‡¡ta‡ ‡asu
Old08    dd        0                        ; p–vodn¡ obsluha INT 08h

; -----------------------------------------------------------------------------
;        obsluha hodin INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ zv˜¨en¡ ‡¡ta‡e ‡asu

         inc       word ptr cs:[Timer]      ; zv˜¨en¡ ‡¡ta‡e ‡asu
         jnz       Int081                   ; nen¡ je¨tˆ p©ete‡en¡
         dec       word ptr cs:[Timer]      ; n vrat hodnoty 0ffffh
Int081:

; ------ ‡¡ta‡ mikroimpuls–

         dec       word ptr cs:[CitInt08]   ; sn¡‘en¡ ‡¡ta‡e mikro‡asu
         jz        Int089                   ; dosa‘eno bˆ‘n‚ho impulsu

; ------ vlastn¡ ukon‡en¡ obsluhy INT 08h

         push      ax
         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         pop       ax
         iret

; ------ p–vodn¡ obsluha INT 08h

Int089:  mov       word ptr cs:[CitInt08],Nasob08 ; inicializace ‡¡ta‡e
         jmp       dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h

Int08    ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na CX impuls– hodin (CX=0 synchronizace)
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

         sti                                ; p©eru¨en¡ mus¡ b˜t povoleno
Cekej1:  cmp       word ptr cs:[Timer],cx   ; dosa‘eno ‡asu ?
         jb        Cekej1                   ; ‡ek n¡ na dosa‘en¡ zadan‚ho ‡asu
         mov       word ptr cs:[Timer],0    ; synchornizace hodin, nov˜ za‡ tek
         ret

Cekej    ENDP

; *****************************************************************************
;
;                            Obsluha displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu AL, pozice BX, © dek DX
; -----------------------------------------------------------------------------

Object   PROC      NEAR


         ret

Object   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ pozad¡
; -----------------------------------------------------------------------------

Pozadi   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         les       di,ds:[AdrVRAM]          ; adresa videopamˆti
         add       di,TopVRAM               ; po‡ te‡n¡ adresa
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       ds,ds:[SegPozad]         ; segment pozad¡
         xor       si,si
         mov       al,1                     ; volba roviny 1

; ------ zobrazen¡ pozad¡

Pozadi1: out       dx,al                    ; volba barevn‚ roviny
         mov       bx,MaxObrY*16            ; po‡et linek
Pozadi2: mov       cx,MaxObrX               ; po‡et slov na linku
         cld
         rep       movsw                    ; p©enos linky
         add       di,40-2*MaxObrX
         dec       bx
         jnz       Pozadi2                  ; p©enos dal¨¡ linky
         sub       di,MaxObrY*16*40
         shl       al,1
         cmp       al,10h
         jne       Pozadi1

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Pozadi   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ter‚nu
; -----------------------------------------------------------------------------

Teren    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©¡prava registr–

         les       di,ds:[AdrVRAM]          ; adresa videopamˆti
         add       di,TopVRAM               ; po‡ te‡n¡ adresa
         mov       bp,ds:[TopTeren]         ; po‡ te‡n¡ adresa definice ter‚nu
         mov       cx,MaxObrY               ; rozmˆr obr zku Y
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         cld
         test      byte ptr ds:[TerenX],1
         jz        Teren4

; ------ zobrazen¡ jednoho © dku

Teren2:  call      TerenR                   ; zobrazen¡ prav‚ poloviny prvku
         push      cx
         mov       cx,MaxObrX-1             ; rozmˆr obr zku X
Teren3:  call      TerenB                   ; zobrazen¡ jednoho prvku
         loop      Teren3                   ; zobrazen¡ dal¨¡ho prvku
         pop       cx
         call      TerenL
         add       di,16*40-MaxObrX*2       ; adresa dal¨¡ho © dku
         add       bp,MaxTerX-MaxObrX-1     ; adresa dal¨¡ho © dku
         loop      Teren2                   ; zobrazen¡ dal¨¡ho © dku
         jmp       short Teren6

; ------ zobrazen¡ ter‚nu v z kladn¡ pozici

Teren4:  push      cx
         mov       cx,MaxObrX               ; rozmˆr obr zku X
Teren5:  call      TerenB                   ; zobrazen¡ jednoho prvku
         loop      Teren5                   ; zobrazen¡ dal¨¡ho prvku
         pop       cx
         add       di,16*40-MaxObrX*2       ; adresa dal¨¡ho © dku
         add       bp,MaxTerX-MaxObrX       ; adresa dal¨¡ho © dku
         loop      Teren4                   ; zobrazen¡ dal¨¡ho © dku

; ------ n vrat registr–

Teren6:  pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

Teren    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ jednoho prvku - pln  ¨¡©ka
; -----------------------------------------------------------------------------
; VSTUP: DS:[BP]=prvek k zobrazen¡
;        ES:DI=adresa ve videopamˆti
;        DX=3c5h registr volby z pisov‚ roviny
; -----------------------------------------------------------------------------

Terenb   PROC      NEAR

; ------ adresa prvku k zobrazen¡

         mov       ah,ds:[bp]               ; ‡¡slo definice prvku ter‚nu
         or        ah,ah                    ; zobraz¡ se prvek ?
         jz        Terenb2                  ; prvek se nezobraz¡
         xor       al,al                    ; AX = prvek * 256
         shr       ax,1                     ; AX = prvek * 128
         mov       si,ax                    ; adresa prvku k zobrazen¡
         push      ds
         mov       ds,ds:[SegTeren]         ; segment s definic¡ ter‚nu

; ------ nastaven¡ z pisov‚ roviny

         mov       al,1                     ; maska rovin k z pisu
Terenb1: out       dx,al                    ; volba z pisov‚ roviny

; ------ z pis jedn‚ roviny prvku

         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         add       di,40-2
         movsw
         sub       di,15*40+2

; ------ p©¡prava k zobrazen¡ dal¨¡ roviny

         shl       al,1                     ; maska pro dal¨¡ rovinu
         cmp       al,10h
         jne       Terenb1                  ; zobrazen¡ dal¨¡ roviny
         pop       ds

; ------ p©¡prava k zobrazen¡ dal¨¡ho prvku na © dku

Terenb2: inc       di
         inc       di                       ; adresa dal¨¡ho prvku
         inc       bp                       ; zv˜¨en¡ ukazatele v mapˆ
         ret

Terenb   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ jednoho prvku - prav  polovina (vlevo)
; -----------------------------------------------------------------------------
; VSTUP: DS:[BP]=prvek k zobrazen¡
;        ES:DI=adresa ve videopamˆti
;        DX=3c5h registr volby z pisov‚ roviny
; -----------------------------------------------------------------------------

Terenr   PROC      NEAR

; ------ adresa prvku k zobrazen¡

         mov       ah,ds:[bp]               ; ‡¡slo definice prvku ter‚nu
         or        ah,ah                    ; zobraz¡ se prvek ?
         jz        Terenr2                  ; prvek se nezobraz¡
         xor       al,al                    ; AX = prvek * 256
         shr       ax,1                     ; AX = prvek * 128
         mov       si,ax                    ; adresa prvku k zobrazen¡
         push      ds
         mov       ds,ds:[SegTeren]         ; segment s definic¡ ter‚nu

; ------ nastaven¡ z pisov‚ roviny

         mov       al,1                     ; maska rovin k z pisu
Terenr1: out       dx,al                    ; volba z pisov‚ roviny

; ------ z pis jedn‚ roviny prvku

         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         add       di,40-1
         inc       si
         movsb
         sub       di,15*40+1

; ------ p©¡prava k zobrazen¡ dal¨¡ roviny

         shl       al,1                     ; maska pro dal¨¡ rovinu
         cmp       al,10h
         jne       Terenr1                  ; zobrazen¡ dal¨¡ roviny
         pop       ds

; ------ p©¡prava k zobrazen¡ dal¨¡ho prvku na © dku

Terenr2: inc       di                       ; adresa dal¨¡ho prvku
         inc       bp                       ; zv˜¨en¡ ukazatele v mapˆ
         ret

Terenr   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ jednoho prvku - lev  polovina (vpravo)
; -----------------------------------------------------------------------------
; VSTUP: DS:[BP]=prvek k zobrazen¡
;        ES:DI=adresa ve videopamˆti
;        DX=3c5h registr volby z pisov‚ roviny
; -----------------------------------------------------------------------------

Terenl   PROC      NEAR

; ------ adresa prvku k zobrazen¡

         mov       ah,ds:[bp]               ; ‡¡slo definice prvku ter‚nu
         or        ah,ah                    ; zobraz¡ se prvek ?
         jz        Terenl2                  ; prvek se nezobraz¡
         xor       al,al                    ; AX = prvek * 256
         shr       ax,1                     ; AX = prvek * 128
         mov       si,ax                    ; adresa prvku k zobrazen¡
         push      ds
         mov       ds,ds:[SegTeren]         ; segment s definic¡ ter‚nu

; ------ nastaven¡ z pisov‚ roviny

         mov       al,1                     ; maska rovin k z pisu
Terenl1: out       dx,al                    ; volba z pisov‚ roviny

; ------ z pis jedn‚ roviny prvku

         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         add       di,40-1
         movsb
         inc       si
         sub       di,15*40+1

; ------ p©¡prava k zobrazen¡ dal¨¡ roviny

         shl       al,1                     ; maska pro dal¨¡ rovinu
         cmp       al,10h
         jne       Terenl1                  ; zobrazen¡ dal¨¡ roviny
         pop       ds

; ------ p©¡prava k zobrazen¡ dal¨¡ho prvku na © dku

Terenl2: inc       di                       ; adresa dal¨¡ho prvku
         inc       bp                       ; zv˜¨en¡ ukazatele v mapˆ
         ret

Terenl   ENDP

; -----------------------------------------------------------------------------
;        ztemnˆn¡ displeje
; -----------------------------------------------------------------------------

Ztemni   PROC      NEAR

; ------ £schova registr–

         push      si
         push      cx
         mov       cx,25                    ; bude se ‡ekat asi 20 ms

; ------ 1. ztemnˆn¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal1           ; polorozsv¡cen˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 2. ztemnˆn¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal2           ; ztemnˆl˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 3. ztemnˆn¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal3           ; £plnˆ temn˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 4. ztemnˆn¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal4           ; £plnˆ temn˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 5. ztemnˆn¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal5           ; £plnˆ temn˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ n vrat registr–

         pop       cx
         pop       si
         ret

Ztemni   ENDP

; -----------------------------------------------------------------------------
;        rozsv¡cen¡ displeje
; -----------------------------------------------------------------------------

Rozsvit  PROC      NEAR

; ------ £schova registr–

         push      si
         push      cx
         mov       cx,25                    ; bude se ‡ekat asi 20 ms

; ------ 1. rozsv¡cen¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal4           ; ztemnˆl˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 2. rozsv¡cen¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal3           ; ztemnˆl˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 3. rozsv¡cen¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal2           ; ztemnˆl˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 4. rozsv¡cen¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal1           ; polorozv¡cen˜ displej
         call      SetPal                   ; nastaven¡ palet

; ------ 5. rozsv¡cen¡

         call      Cekej                    ; ‡ek n¡ na 1 impuls
         mov       si,offset Pal0           ; standardn¡ displej
         call      SetPal                   ; nastaven¡ palet

; ------ n vrat registr–

         pop       cx
         pop       si
         ret

Rozsvit  ENDP

; -----------------------------------------------------------------------------
;             nastaven¡ paletov˜ch registr– DS:SI
; -----------------------------------------------------------------------------

SetPal   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      si

; ------ ‡ek n¡ na vertik ln¡ zatemnˆn¡

         sti                                ; p©eru¨en¡ povoleno
         mov       dx,3dah                  ; stavov˜ registr videokarty
SetPal1: in        al,dx                    ; ‡ten¡ stavov‚ho registru
         test      al,8                     ; je vertik ln¡ impuls ?
         jnz       SetPal1                  ; ‡ek n¡ na konec synchroimpulsu
SetPal2: in        al,dx                    ; ‡ten¡ stavov‚ho registru
         test      al,8                     ; je vertik ln¡ impuls ?
         jz        SetPal2                  ; ‡ek n¡ na vertik ln¡ impuls

; ------ volba registru

         cli                                ; z kaz p©eru¨en¡
         cld
         xor       ah,ah                    ; ukazatel registr–
         mov       dx,3c0h                  ; port nastaven¡ palet
SetPal3: mov       al,ah                    ; paletov˜ registr
         out       dx,al                    ; volba paletov‚ho registru

; ------ nastaven¡ po‘adovan‚ hodnoty registru

         lodsb                              ; hodnota pro nastaven¡ registru
         out       dx,al                    ; nastaven¡ palety

; ------ p©¡prava pro dal¨¡ registr

         inc       ah                       ; zv˜¨en¡ ukazatele registr–
         cmp       ah,10h                   ; jsou ji‘ v¨echny registry ?
         jb        SetPal3                  ; nastaven¡ dal¨¡ho registru

; ------ p©edefinov n¡ paletov‚ho registru pozad¡

         mov       al,11h                   ; ‡¡slo registru palety pozad¡
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         lodsb                              ; po‘adovan  paleta registru
         out       dx,al                    ; definice palety registru pozad¡

; ------ zapnut¡ videosign lu

         mov       al,20h                   ; hodnota pro rozsv¡cen¡ displeje
         out       dx,al                    ; rozsv¡cen¡ displeje
         sti                                ; p©eru¨en¡ zase povoleno

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       ax
         ret

SetPal   ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ roviny pro ‡ten¡ (BH=rovina pro ‡ten¡)
; -----------------------------------------------------------------------------

ReadSel  PROC      NEAR

         push      ax
         push      dx
         mov       dx,3ceh
         mov       al,4                     ; registr 4 - ‡tec¡ rovina
         out       dx,al                    ; volba registru 4
         inc       dx
         mov       al,bh                    ; po‘adovan  rovina
         out       dx,al                    ; volba ‡tec¡ roviny
         pop       dx
         pop       ax
         ret

ReadSel  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ roviny pro z pis (BL=maska rovin pro z pis)
; -----------------------------------------------------------------------------

WritSel  PROC      NEAR

         push      ax
         push      dx
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,bl                    ; po‘adovan  rovina
         out       dx,al                    ; volba z pisov‚ roviny
         pop       dx
         pop       ax
         ret

WritSel  ENDP

; -----------------------------------------------------------------------------
;                                XPage
;                        p©epnut¡ videostr nek
; -----------------------------------------------------------------------------
; Nastav¡ pracovn¡ videostr nku jako zobrazenou videostr nku a zmˆn¡ adresu
; pracovn¡ videostr nky.
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

XPage    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ nastaven¡ ni‘¨¡ho bajtu adresy zobrazen‚ videostr nky

         mov       dx,3d4h                  ; port volby registru video©adi‡e
         mov       al,0dh                   ; registr adresy - ni‘¨¡ bajt
         out       dx,al                    ; volba registru ni‘¨¡ho bajtu
         inc       dx
         mov       al,0                     ; ni‘¨¡ bajt adresy je v‘dy 0
         out       dx,al                    ; nastaven¡ ni‘¨¡ho bajtu adresy

; ------ nastaven¡ vy¨¨¡ho bajtu adresy zobrazen‚ videostr nky

         dec       dx
         mov       al,0ch                   ; registr adresy - vy¨¨¡ bajt
         out       dx,al                    ; volba registru vy¨¨¡ho bajtu
         inc       dx
         mov       al,byte ptr ds:[OffVRAM+1] ; vy¨¨¡ bajt adresy videopamˆti
         out       dx,al                    ; nastaven¡ vy¨¨¡ho bajtu adresy

; ------ zmˆna adresy pracovn¡ videostr nky

         xor       al,20h                   ; zmˆna adresy videostr nky
         mov       byte ptr ds:[OffVRAM+1],al ; nov˜ vy¨¨¡ bajt adresy

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

XPage    ENDP




Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT

ErrCard  db        'Program vyzaduje grafickou kartu EGA nebo VGA !',13,10
ErrOK    db        '$'
ErrSoub1 db        'CHYBA - nenalezen soubor '
ErrSoub2 label     byte                     ; sem se ulo‘¡ jm‚no souboru

SoubUv1  db        'UVOD1.SCR',0
SoubUv2  db        'UVOD2.SCR',0
SoubUv3  db        'UVOD3.SCR',0
SoubRam  db        'RAM.SCR',0

SoubTer1 db        'TEREN1.DAT',0           ; definice ter‚nu - vzory
SoubMap1 db        'TEREN1.MAP',0           ; definice ter‚nu - mapa
SoubPoz1 db        'POZADI1.SCR',0          ; pozad¡ sc‚ny

ErrSoub3 db        ' !',13,10,'$'
ErrSoub4 label     byte

; ------ definice palet

Pal0     db        0,1,2,3,4,5,6,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0 ; standard
Pal1     db        0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0
Pal2     db        0,8,10h,18h,20h,28h,30h,38h,0,1,2,3,4,5,6,7,0
Pal3     db        0,8,10h,18h,20h,28h,30h,38h,0,8,10h,18h,20h,28h,30h,38h,0
Pal4     db        0,0,0,0,0,0,0,0,0,8,10h,18h,20h,28h,30h,38h,0
Pal5     db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; temn˜ displej


UvTxt    db        'Uvodni obrazovka programu.',13,10
         db        ' ---- druhy radek --------',13,10
         db        '        . . .',13,10,0


SegTeren dw        SEG TerenS               ; segment vzor– ter‚nu
SegPozad dw        SEG PozadiS              ; segment obrazu pozad¡
SegObjct dw        SEG ObjectS              ; segment objekt–

AdrVRAM  label     dword                    ; pracovn¡ adresa videopamˆti
OffVRAM  dw        2000h                    ; adresa videostr nky v pozad¡
SegVRAM  dw        0a000h                   ; segment videopamˆti


OldVMod  db        ?                        ; p–vodn¡ videom¢d
SegPSP   dw        ?                        ; segment PSP

; ------ komprese dat

Param0   db        8                        ; parametry komprese
                                            ;   bit 3: 1=bude stav komprese dat
                                            ;   bit 4: 1=nyn¡ je komprese dat

KompCit  dw        0                        ; ‡¡ta‡ pro kompresi
KompChr  db        0                        ; uschovan˜ opakovan˜ bajt komprese

; ------ obsluha souboru

Ident    dw        ?                        ; identifik tor souboru
BuffAdr  dw        ?                        ; ‡tec¡ adresa z bufferu
BuffNum  dw        ?                        ; po‡et bajt– v bufferu
Buffer   db        MaxBuff DUP(?)           ; diskov˜ buffer

; ------ definice ter‚nu

TopTeren dw        ?                        ; adresa definice po‡ tku ter‚nu
TerenX   dw        ?                        ; po‡ te‡n¡ pozice ter‚nu (1/8)
TerenY   dw        ?                        ; po‡ te‡n¡ © dek ter‚nu (1/8)
TerenMap db        MaxTerX*MaxTerY dup(?)   ; mapa ter‚nu

; ------ definice objekt–

ObjctAdr dw        256 dup(?)               ; adresy objekt–

;         db        128 dup(?)

Data     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                          Pozad¡ sc‚ny
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

PozadiS  SEGMENT   para

         db        MaxObrX*2 * MaxObrY*16 * 4 dup(?)   ; pozad¡ sc‚ny

PozadiS  ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           Vzory ter‚nu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

TerenS   SEGMENT   para

         db        256*2*16*4 dup(?)        ; buffer pro vzory ter‚nu

TerenS   ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              Objekty
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

ObjectS  SEGMENT   para

         db        256*2*16*5 dup(?)        ; buffer pro vzory objekt–

ObjectS  ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasobnik SEGMENT   stack
         dw        1024 dup(?)
Zasobnik ENDS

         END       Start

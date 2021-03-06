
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                                  ASC
;                          zad쟶쟮� ASCII znak�
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

TOPPOZ   EQU       (80-35)/2                ; po뇿te뇆� pozice okna tabulky
KORIG    EQU       5ch-103h                 ; korekce pro posun programu
HOTKEY   EQU       8200h                    ; hork� kl쟶esa (ALT-poml뇃a)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; inicializace

Ident    label     byte

Old16    dd        0                        ; p뻱odn� adresa INT 16h
Param    db        80h                      ; parametry
                                            ;   bit 0: 1=znak ur놽n k v쁲tupu
                                            ;   bit 7: v멶y 1 (pro pæznak NZ)

Povel    db        0                        ; povel pro INT 16h

AktChr   db        0                        ; aktivn� znak tabulky ASCII
         db        0                        ; SCAN k줰 kl쟶esy

AdrVRAM  dw        0                        ; adresa videopam늯i - offset
SegmVRAM dw        0b800h                   ; adresa videopam늯i - segment

InfTxt   db        ' ',0                    ; informa뇆� 찤dek
InfDTxt  db        '000',0,' Dek ',179,' ',0
InfHTxt  db        '00',0,' Hex ',179,' ',0
InfBTxt  db        '00000000',0,' Bin '
InfTxt0  label     byte

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

INT16    PROC      FAR

; ------ kontrola 눀sla operace

         test      ah,0eeh                  ; povolen� operace 0, 1, 10h, 11h
         jz        INT162                   ; je povolen� funkce
INT161:  jmp       dword ptr cs:[Old16+KORIG] ; p뻱odn� obsluha

; ------ rozli쮍n�, zda je p쯫pravena kl쟶esa

INT162:  mov       byte ptr cs:[Povel+KORIG],ah ; 즧chova 눀sla povelu
INT163:  test      byte ptr cs:[Param+KORIG],1 ; je p쯫praven� kl쟶esa ?
         jz        INT166                   ; nen� p쯫praven� kl쟶esa

; ------ n쟦radn� funkce pro p쯫praven� znak

         test      ah,1                     ; je vstup z kl쟶esnice ?
         jnz       INT164                   ; je test kl쟶esnice
         and       byte ptr cs:[Param+KORIG],not 1 ; zru쮍n� pæznaku znaku k v쁲tupu
INT164:  mov       ax,word ptr cs:[AktChr+KORIG]  ; znak p쯫praven� v bufferu
INT165:  ret       2                        ; n쟶rat

; ------ test, zda je p쯫pravena hork� kl쟶esa

INT166:  test      ah,1                     ; je vstup z kl쟶esnice ?
         jnz       INT167                   ; nen� - je test kl쟶esnice
         call      Exec16                   ; vstup znaku z kl쟶esnice
         cmp       ax,HOTKEY                ; je to hork� kl쟶esa ?
         je        INT169                   ; je hork� kl쟶esa OK
         jmp       short INT165             ; n쟶rat

INT167:  call      Exec16                   ; test p쯫praven� kl쟶esy
         jz        INT165                   ; nen� p쯫praven� 몺dn� kl쟶esa
         pushf
         cmp       ax,HOTKEY                ; je to hork� kl쟶esa ?
         je        INT168                   ; je hork� kl쟶esa OK
         popf
         jmp       short INT165             ; konec

; ------ zru쮍n� hork� kl쟶esy z bufferu

INT168:  popf
         mov       ah,cs:[Povel+KORIG]      ; povel
         and       ah,not 1
         call      Exec16                   ; vstup znaku z kl쟶esnice

; ------ obsluha tabulky

INT169:  call      EditTab                  ; obsluha tabulky
         mov       ah,cs:[Povel+KORIG]      ; p뻱odn� povel
         jmp       short INT163             ; opakov쟮� obsluhy

INT16    ENDP

; -----------------------------------------------------------------------------
;        vol쟮� obsluhy INT 16h
; -----------------------------------------------------------------------------

Exec16   PROC      NEAR

         pushf
         call      dword ptr cs:[Old16+KORIG]
         ret

Exec16   ENDP

; -----------------------------------------------------------------------------
;        editace tabulky ASCII
; -----------------------------------------------------------------------------

EditTab  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      ds

; ------ ur놽n� parametr� videom줰u

         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[449h]             ; aktu쟫n� videom줰
         mov       ah,0b0h                  ; displej Hercules
         cmp       al,7                     ; je videom줰 7 ?
         je        EditTb02
         mov       ah,0b8h                  ; displej CGA, EGA, VGA
         cmp       al,2
         je        EditTb02
         cmp       al,3
         jne       EditTb24                 ; nepovolen� videom줰
EditTb02:mov       byte ptr cs:[SegmVRAM+1+KORIG],ah ; segment videopam늯i
         mov       ax,ds:[44eh]             ; adresa videostr쟮ky
         push      cs
         pop       ds
         mov       ds:[AdrVRAM+KORIG],ax    ; adresa videopam늯i

; ------ 즧chova podkladu okna

         mov       al,0                     ; pæznak 즧chovy
         call      PushWin                  ; 즧chova obsahu okna

; ------ 놽k쟮� na stisk kl쟶esy

EditTab0:call      DispTab                  ; zobrazen� tabulky ASCII
         mov       ah,0
         call      Exec16                   ; vstup znaku z kl쟶esnice

; ------ p쯥ru쮍n� operace ESC, Ctrl-Break

         or        ax,ax
         jz        EditTab2
         cmp       al,27
         je        EditTab2                 ; p쯥ru쮍n� ESC

; ------ znak je ur놽n k v쁲tupu

         cmp       ax,HOTKEY                ; je to hork� kl쟶esa ?
         je        EditTab1                 ; je to hork� kl쟶esa - jako ENTER
         cmp       al,13                    ; je ENTER ?
         jne       EditTab3
EditTab1:or        byte ptr ds:[Param+KORIG],1 ; pæznak znaku k v쁲tupu
         mov       byte ptr ds:[AktChr+1+KORIG],0
         cmp       byte ptr ds:[AktChr+KORIG],0
         jne       EditTab2
         mov       byte ptr ds:[AktChr+1+KORIG],3 ; k줰 kl쟶esy s 0

; ------ n쟶rat registr� a okna

EditTab2:mov       al,1                     ; pæznak 즧chovy
         call      PushWin                  ; n쟶rat obsahu okna
EditTb24:pop       ds
         pop       bx
         pop       ax
         ret

; ------ editace tabulky ASCII

EditTab3:or        al,al                    ; je ædic� kl쟶esa ?
         jnz       EditTab6                 ; nen� ædic� kl쟶esa - je znak
         sub       ah,47h
         jc        EditTab7
         cmp       ah,51h-47h
         ja        EditTab7
         mov       bl,ah
         mov       bh,0
         shl       bx,1
         mov       al,ds:[AktChr+KORIG]
         call      word ptr ds:[bx+TabSkok+KORIG]
EditTab6:mov       ds:[AktChr+KORIG],al
EditTab7:jmp       short EditTab0

EditTab  ENDP

TabSkok  dw        AscHome+KORIG            ; 47h Home
         dw        AscUp+KORIG              ; 48h nahoru
         dw        AscPgUp+KORIG            ; 49h Page Up
         dw        AscRet+KORIG             ; 4ah
         dw        AscLeft+KORIG            ; 4bh vlevo
         dw        AscRet+KORIG             ; 4ch
         dw        AscRght+KORIG            ; 4dh vpravo
         dw        AscRet+KORIG             ; 4eh
         dw        AscEnd+KORIG             ; 4fh End
         dw        AscDown+KORIG            ; 50h dol�
         dw        AscPgDn+KORIG            ; 51h Page Down

; ------ za뇿tek 찤dku HOME

AscHome: and       al,0f0h
AscRet:  ret

; ------ kurzor nahoru

AscUp:   sub       al,16
         ret

; ------ horn� okraj PageUp

AscPgUp: and       al,0fh
         ret

; ------ kurzor vlevo

AscLeft: dec       ax
         ret

; ------ kurzor vpravo

AscRght: inc       ax
         ret

; ------ konec 찤dku END

AscEnd:  or        al,0fh
         ret

; ------ kurzor dol�

AscDown: add       al,16
         ret

; ------ spodn� okraj

AscPgDn: or        al,0f0h
         ret

; -----------------------------------------------------------------------------
;        zobrazen� tabulky ASCII (bez kurzoru)
; -----------------------------------------------------------------------------

DispTab  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ pæprava registr�

         push      cs
         pop       ds
         les       di,dword ptr ds:[AdrVRAM+KORIG] ; adresa videopam늯i
         add       di,TOPPOZ*2+160          ; po뇿te뇆� adresa ve videopam늯i
         mov       bl,ds:[AktChr+KORIG]     ; aktivn� znak
         cld

; ------ zobrazen� horn죋o okraje

         mov       ax,70h*256 + 218
         stosw
         mov       cx,33
         mov       al,196
         rep       stosw
         mov       al,191
         stosw
         add       di,160-35*2

; ------ dekadick� 눀slo

         mov       si,offset InfDTxt+2+KORIG
         mov       word ptr ds:[si-2],"  "
         mov       cl,10
         mov       al,bl
DispTb22:mov       ah,0
         div       cl
         add       ah,"0"
         mov       ds:[si],ah
         dec       si
         or        al,al
         jnz       DispTb22

; ------ dek줰ov쟮� hexadecim쟫n죋o 눀sla

         mov       si,offset InfHTxt+1+KORIG
         mov       cl,2
         mov       ah,bl
DispTb24:mov       al,ah
         and       al,0fh
         cmp       al,9
         jbe       DispTb25
         add       al,7
DispTb25:add       al,"0"
         mov       ds:[si],al
         dec       si
         shr       ah,1
         shr       ah,1
         shr       ah,1
         shr       ah,1
         loop      DispTb24

; ------ dek줰ov쟮� bin쟲n죋o 눀sla

         mov       si,offset InfBTxt+KORIG
         mov       cl,8
         mov       ah,bl                    ; aktivn� znak
DispTb26:mov       al,"0"
         shl       ah,1
         adc       al,0
         mov       ds:[si],al
         inc       si
         loop      DispTb26

; ------ zobrazen� informa뇆죋o 찤dku

         mov       ax,70h*256 + 179
         push      ax
         stosw
         mov       si,offset InfTxt+KORIG   ; informa뇆� 찤dek
         mov       bh,7
         mov       ah,0fh                   ; zv쁱azn늧� text
         mov       cl,offset(InfTxt0-InfTxt)-6
DispTb31:xchg      ah,bh
DispTab3:lodsb
         cmp       al,0
         je        DispTb31
         stosw
         loop      DispTab3
         pop       ax
         stosw
         add       di,160-2*35

; ------ zobrazen� jednoho 찤dku tabulky ASCII

         mov       bh,0                     ; po뇿te뇆� polo멾a
DispTab4:mov       al,179
         stosw                              ; lev� okraj
         mov       al," "
         stosw

DispTb41:mov       al,bh                    ; znak
         stosw
         mov       al," "
         stosw
         cmp       bl,bh
         jne       DispTb42
         mov       byte ptr es:[di-5],0fh
         mov       byte ptr es:[di-3],0fh
         mov       byte ptr es:[di-1],0fh
DispTb42:inc       bh
         test      bh,0fh
         jnz       DispTb41

         mov       al,179
         stosw                              ; prav� okraj
         add       di,160-2*35
         or        bh,bh
         jnz       DispTab4

; ------ spodn� okraj

         mov       al,"�"
         stosw
         mov       al,"�"
         mov       cl,8
         rep       stosw

         mov       ax,"0"
DispTb51:stosw
         inc       ax
         cmp       al,"9"+1
         jne       DispTb52
         mov       al,"A"
DispTb52:inc       ah
         cmp       al,"F"+1
         jne       DispTb51

         mov       ax,70h*256+"�"
         mov       cl,9
         rep       stosw

         mov       al,"�"
         stosw

; ------ st죒 na spodn죑 찤dku

         add       di,160-2*35+2*2
         mov       cx,33
         mov       al,7
DispTab6:inc       di
         stosb
         loop      DispTab6

; ------ st죒 vpravo od okna

         sub       di,18*160
         mov       cx,19
DispTab7:inc       di
         stosb
         inc       di
         stosb
         add       di,160-4
         loop      DispTab7

; ------ n쟶rat registr�

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispTab  ENDP

; -----------------------------------------------------------------------------
;        즧chova (AL=0) nebo n쟶rat (AL=1) obsahu obrazovky, DS=dat. segment
; -----------------------------------------------------------------------------

PushWin  PROC      NEAR

; ------ 즧chova registr�

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p쯥sun obsahu obrazovky

         lds       si,dword ptr ds:[AdrVRAM+KORIG] ; adresa videopam늯i
         mov       di,si                    ; adresa videostr쟮ky
         xor       di,2000h                 ; adresa videopam늯i k 즧chov�
         push      ds
         pop       es                       ; ES <- videopam닟
         or        al,al
         jz        PushWin1                 ; je 즧chova
         xchg      si,di                    ; z쟭늧a sm늭u
PushWin1:mov       cx,21*80                 ; po놽t slov na v삩ku okna
         cld
         rep       movsw                    ; p쯥sun bloku videopam늯i

; ------ n쟶rat registr�

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         ret

PushWin  ENDP

; *****************************************************************************
;
;                         Start a inicializace programu
;
; *****************************************************************************

; ------ zobrazen� 즪odn죋o textu

Init:    mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen� 즪odn죋o textu

; ------ p쯥sun programu n죷e

         mov       si,offset Ident
         mov       di,5ch
         mov       cx,offset(Init-Ident)
         cld
         rep       movsb

; ------ instalace INT 16h

         mov       ax,3516h
         int       21h
         mov       word ptr ds:[Old16+KORIG],bx
         mov       word ptr ds:[Old16+2+KORIG],es

         mov       dx,offset INT16+KORIG
         mov       ax,2516h
         int       21h

; ------ uvoln늧� segmentu prost쯥d�

         mov       es,ds:[2ch]              ; segment prost쯥d�
         mov       ah,49h
         int       21h                      ; uvoln늧� segmentu prost쯥d�

; ------ instalace programu

         mov       dx,offset Init+KORIG
         int       27h                      ; instalace programu

UvTxt    db        'ASCTAB V1.10 - tabulka znaku; (c) Miroslav Nemecek',13,10
         db        '  Program byl nainstalovan do pameti. Vyvolani',13,10
         db        '  tabulky ASCII znaku je mozne stiskem ALT-POMLCKA',13,10
         db        '$'

Code     ENDS
         END       Start


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                  ASC
;                          zad v n¡ ASCII znak–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

TOPPOZ   EQU       (80-35)/2                ; po‡ te‡n¡ pozice okna tabulky
KORIG    EQU       5ch-103h                 ; korekce pro posun programu
HOTKEY   EQU       8200h                    ; hork  kl vesa (ALT-poml‡ka)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; inicializace

Ident    label     byte

Old16    dd        0                        ; p–vodn¡ adresa INT 16h
Param    db        80h                      ; parametry
                                            ;   bit 0: 1=znak ur‡en k v˜stupu
                                            ;   bit 7: v‘dy 1 (pro p©¡znak NZ)

Povel    db        0                        ; povel pro INT 16h

AktChr   db        0                        ; aktivn¡ znak tabulky ASCII
         db        0                        ; SCAN k¢d kl vesy

AdrVRAM  dw        0                        ; adresa videopamˆti - offset
SegmVRAM dw        0b800h                   ; adresa videopamˆti - segment

InfTxt   db        ' ',0                    ; informa‡n¡ © dek
InfDTxt  db        '000',0,' Dek ',179,' ',0
InfHTxt  db        '00',0,' Hex ',179,' ',0
InfBTxt  db        '00000000',0,' Bin '
InfTxt0  label     byte

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

INT16    PROC      FAR

; ------ kontrola ‡¡sla operace

         test      ah,0eeh                  ; povolen‚ operace 0, 1, 10h, 11h
         jz        INT162                   ; je povolen  funkce
INT161:  jmp       dword ptr cs:[Old16+KORIG] ; p–vodn¡ obsluha

; ------ rozli¨en¡, zda je p©ipravena kl vesa

INT162:  mov       byte ptr cs:[Povel+KORIG],ah ; £schova ‡¡sla povelu
INT163:  test      byte ptr cs:[Param+KORIG],1 ; je p©ipraven  kl vesa ?
         jz        INT166                   ; nen¡ p©ipraven  kl vesa

; ------ n hradn¡ funkce pro p©ipraven˜ znak

         test      ah,1                     ; je vstup z kl vesnice ?
         jnz       INT164                   ; je test kl vesnice
         and       byte ptr cs:[Param+KORIG],not 1 ; zru¨en¡ p©¡znaku znaku k v˜stupu
INT164:  mov       ax,word ptr cs:[AktChr+KORIG]  ; znak p©ipraven˜ v bufferu
INT165:  ret       2                        ; n vrat

; ------ test, zda je p©ipravena hork  kl vesa

INT166:  test      ah,1                     ; je vstup z kl vesnice ?
         jnz       INT167                   ; nen¡ - je test kl vesnice
         call      Exec16                   ; vstup znaku z kl vesnice
         cmp       ax,HOTKEY                ; je to hork  kl vesa ?
         je        INT169                   ; je hork  kl vesa OK
         jmp       short INT165             ; n vrat

INT167:  call      Exec16                   ; test p©ipraven‚ kl vesy
         jz        INT165                   ; nen¡ p©ipraven  ‘ dn  kl vesa
         pushf
         cmp       ax,HOTKEY                ; je to hork  kl vesa ?
         je        INT168                   ; je hork  kl vesa OK
         popf
         jmp       short INT165             ; konec

; ------ zru¨en¡ hork‚ kl vesy z bufferu

INT168:  popf
         mov       ah,cs:[Povel+KORIG]      ; povel
         and       ah,not 1
         call      Exec16                   ; vstup znaku z kl vesnice

; ------ obsluha tabulky

INT169:  call      EditTab                  ; obsluha tabulky
         mov       ah,cs:[Povel+KORIG]      ; p–vodn¡ povel
         jmp       short INT163             ; opakov n¡ obsluhy

INT16    ENDP

; -----------------------------------------------------------------------------
;        vol n¡ obsluhy INT 16h
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

; ------ £schova registr–

         push      ax
         push      bx
         push      ds

; ------ ur‡en¡ parametr– videom¢du

         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[449h]             ; aktu ln¡ videom¢d
         mov       ah,0b0h                  ; displej Hercules
         cmp       al,7                     ; je videom¢d 7 ?
         je        EditTb02
         mov       ah,0b8h                  ; displej CGA, EGA, VGA
         cmp       al,2
         je        EditTb02
         cmp       al,3
         jne       EditTb24                 ; nepovolen˜ videom¢d
EditTb02:mov       byte ptr cs:[SegmVRAM+1+KORIG],ah ; segment videopamˆti
         mov       ax,ds:[44eh]             ; adresa videostr nky
         push      cs
         pop       ds
         mov       ds:[AdrVRAM+KORIG],ax    ; adresa videopamˆti

; ------ £schova podkladu okna

         mov       al,0                     ; p©¡znak £schovy
         call      PushWin                  ; £schova obsahu okna

; ------ ‡ek n¡ na stisk kl vesy

EditTab0:call      DispTab                  ; zobrazen¡ tabulky ASCII
         mov       ah,0
         call      Exec16                   ; vstup znaku z kl vesnice

; ------ p©eru¨en¡ operace ESC, Ctrl-Break

         or        ax,ax
         jz        EditTab2
         cmp       al,27
         je        EditTab2                 ; p©eru¨en¡ ESC

; ------ znak je ur‡en k v˜stupu

         cmp       ax,HOTKEY                ; je to hork  kl vesa ?
         je        EditTab1                 ; je to hork  kl vesa - jako ENTER
         cmp       al,13                    ; je ENTER ?
         jne       EditTab3
EditTab1:or        byte ptr ds:[Param+KORIG],1 ; p©¡znak znaku k v˜stupu
         mov       byte ptr ds:[AktChr+1+KORIG],0
         cmp       byte ptr ds:[AktChr+KORIG],0
         jne       EditTab2
         mov       byte ptr ds:[AktChr+1+KORIG],3 ; k¢d kl vesy s 0

; ------ n vrat registr– a okna

EditTab2:mov       al,1                     ; p©¡znak £schovy
         call      PushWin                  ; n vrat obsahu okna
EditTb24:pop       ds
         pop       bx
         pop       ax
         ret

; ------ editace tabulky ASCII

EditTab3:or        al,al                    ; je ©¡dic¡ kl vesa ?
         jnz       EditTab6                 ; nen¡ ©¡dic¡ kl vesa - je znak
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
         dw        AscDown+KORIG            ; 50h dol–
         dw        AscPgDn+KORIG            ; 51h Page Down

; ------ za‡ tek © dku HOME

AscHome: and       al,0f0h
AscRet:  ret

; ------ kurzor nahoru

AscUp:   sub       al,16
         ret

; ------ horn¡ okraj PageUp

AscPgUp: and       al,0fh
         ret

; ------ kurzor vlevo

AscLeft: dec       ax
         ret

; ------ kurzor vpravo

AscRght: inc       ax
         ret

; ------ konec © dku END

AscEnd:  or        al,0fh
         ret

; ------ kurzor dol–

AscDown: add       al,16
         ret

; ------ spodn¡ okraj

AscPgDn: or        al,0f0h
         ret

; -----------------------------------------------------------------------------
;        zobrazen¡ tabulky ASCII (bez kurzoru)
; -----------------------------------------------------------------------------

DispTab  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       ds
         les       di,dword ptr ds:[AdrVRAM+KORIG] ; adresa videopamˆti
         add       di,TOPPOZ*2+160          ; po‡ te‡n¡ adresa ve videopamˆti
         mov       bl,ds:[AktChr+KORIG]     ; aktivn¡ znak
         cld

; ------ zobrazen¡ horn¡ho okraje

         mov       ax,70h*256 + 218
         stosw
         mov       cx,33
         mov       al,196
         rep       stosw
         mov       al,191
         stosw
         add       di,160-35*2

; ------ dekadick‚ ‡¡slo

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

; ------ dek¢dov n¡ hexadecim ln¡ho ‡¡sla

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

; ------ dek¢dov n¡ bin rn¡ho ‡¡sla

         mov       si,offset InfBTxt+KORIG
         mov       cl,8
         mov       ah,bl                    ; aktivn¡ znak
DispTb26:mov       al,"0"
         shl       ah,1
         adc       al,0
         mov       ds:[si],al
         inc       si
         loop      DispTb26

; ------ zobrazen¡ informa‡n¡ho © dku

         mov       ax,70h*256 + 179
         push      ax
         stosw
         mov       si,offset InfTxt+KORIG   ; informa‡n¡ © dek
         mov       bh,7
         mov       ah,0fh                   ; zv˜raznˆn˜ text
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

; ------ zobrazen¡ jednoho © dku tabulky ASCII

         mov       bh,0                     ; po‡ te‡n¡ polo‘ka
DispTab4:mov       al,179
         stosw                              ; lev˜ okraj
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
         stosw                              ; prav˜ okraj
         add       di,160-2*35
         or        bh,bh
         jnz       DispTab4

; ------ spodn¡ okraj

         mov       al,"À"
         stosw
         mov       al,"Ä"
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

         mov       ax,70h*256+"Ä"
         mov       cl,9
         rep       stosw

         mov       al,"Ù"
         stosw

; ------ st¡n na spodn¡m © dku

         add       di,160-2*35+2*2
         mov       cx,33
         mov       al,7
DispTab6:inc       di
         stosb
         loop      DispTab6

; ------ st¡n vpravo od okna

         sub       di,18*160
         mov       cx,19
DispTab7:inc       di
         stosb
         inc       di
         stosb
         add       di,160-4
         loop      DispTab7

; ------ n vrat registr–

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
;        £schova (AL=0) nebo n vrat (AL=1) obsahu obrazovky, DS=dat. segment
; -----------------------------------------------------------------------------

PushWin  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©esun obsahu obrazovky

         lds       si,dword ptr ds:[AdrVRAM+KORIG] ; adresa videopamˆti
         mov       di,si                    ; adresa videostr nky
         xor       di,2000h                 ; adresa videopamˆti k £schovˆ
         push      ds
         pop       es                       ; ES <- videopamˆŸ
         or        al,al
         jz        PushWin1                 ; je £schova
         xchg      si,di                    ; z mˆna smˆru
PushWin1:mov       cx,21*80                 ; po‡et slov na v˜¨ku okna
         cld
         rep       movsw                    ; p©esun bloku videopamˆti

; ------ n vrat registr–

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

; ------ zobrazen¡ £vodn¡ho textu

Init:    mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ p©esun programu n¡‘e

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

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

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
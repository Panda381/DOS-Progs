
; *****************************************************************************
;
;                         DEMO ke h©e DEATHBRINGER
;
; POZOR - nˆkter‚ po‡¡ta‡e mohou bˆhem testu karty ROLAND zamrznout,
;         proto nen¡ implicitnˆ pou‘¡v na autodetekce zvukov‚ karty.
; *****************************************************************************

KONST08  EQU       23788                    ; p©ehr vac¡ konstanta INT 08h

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zmen¨en¡ velikosti modulu programu

Start:   cmp       sp,offset Buffer + 11100 ; asi tak pot©ebn  pamˆŸ
         jb        Start1                   ; nedostatek pamˆti
         mov       sp,offset Buffer + 10900
         mov       bx,(offset(Buffer-Start)+10fh+11000)/16
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ p©idˆlen‚ pamˆti
         jnc       Start2
Start1:  int       20h

; ------ p©¡prava adresy ovlada‡e v pamˆti

Start2:  mov       ax,cs
         mov       ds:[Packet+2+2],ax       ; p©¡kazov˜ © dek
         mov       ds:[Packet+6+2],ax       ; prvn¡ FCB
         mov       ds:[Packet+10+2],ax      ; druh˜ FCB
         add       ax,(offset(Buffer-Start) + 10fh)/16
         mov       ds:[Segm1],ax            ; adresa ADLIB.BIN v pamˆti
         mov       ds:[Segm2],ax
         mov       ax,ds:[2ch]
         mov       ds:[Packet],ax           ; adresa prost©ed¡

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ vstup znaku z kl vesnice

Start21: mov       ah,8
         int       21h
         cmp       al,0
         jne       Start22
         mov       ah,8
         int       21h

; ------ rozli¨en¡ kl vesy

Start22: cmp       al,13
         je        Start25                  ; automatick  detekce
         cmp       al,27
         je        Start1                   ; p©eru¨en¡
         sub       al,"0"
         jc        Start21
         je        Start28                  ; nen¡ zvuk
         cmp       al,3
         ja        Start21

; ------ instalace ur‡en‚ karty

         je        Start26                  ; TANDY
         mov       dx,offset Soubor2        ; ROLAND
         cmp       al,2
         je        Start27                  ; je ROLAND
         mov       dx,offset Soubor1        ; ADLIB
         jmp       short Start27            ; ADLIB

; ------ automatick  detekce karty

Start25: mov       dx,offset Soubor1        ; ADLIB
         call      InstMus
         jnc       Start3
         mov       dx,offset Soubor2        ; ROLAND
         call      InstMus
         jnc       Start3
Start26: mov       dx,offset Soubor3        ; TANDY
Start27: call      InstMus
         jnc       Start3
Start28: mov       word ptr ds:[((Buffer-Start)+10fh) AND not 0fh],0cbh ; RETF

; ------ £schova INT 08h

Start3:  mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es

; ------ instalace INT 08h

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ nastaven¡ hodin INT 08h

         mov       ax,KONST08
         call      Set08

; ------ start p©ehr v n¡ melodie

         mov       word ptr ds:[(((Buffer-Start)+10fh) AND not 0fh)+8],1

; ------ test, zda je karta EGA nebo VGA

         push      ds
         mov       ah,12h
         mov       bx,5610h
         int       10h
         pop       ds
         cmp       bh,1
         ja        Start4                   ; nen¡ EGA/VGA
         cmp       bl,5
         ja        Start4

; ------ grafick  demonstrace (jen pro EGA/VGA)

         push      ds
         mov       ds:[OldSP],sp
         mov       ds:[OldSS],ss
         push      ds
         pop       es
         mov       byte ptr ds:[81h],"1"    ; 1=p©¡znak displeje VGA (2=EGA)
         mov       dx,offset Intro
         mov       bx,offset Packet
         mov       ax,4b00h
         int       21h                      ; start programu INTRO
         mov       ss,cs:[OldSS]
         mov       sp,cs:[OldSP]
         pop       ds

; ------ n hradn¡ obsluha, nen¡-li grafick‚ demo

         jnc       Start5
Start4:  mov       dx,offset KlavTxt
         mov       ah,9
         int       21h
         mov       ah,0
         int       16h

; ------ stop p©ehr v n¡ melodie

Start5:  mov       word ptr ds:[(((Buffer-Start)+10fh) AND not 0fh)+8],0ffh
         call      Cek08                    ; ‡ek n¡ na p©evzet¡ povelu
         call      Cek08
         call      Cek08

; ------ n vrat hodin INT 08h

         xor       ax,ax
         call      Set08

; ------ n vrat adresy INT 08h

         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h
         int       20h

OldSP    dw        0                        ; uschovan˜ SP
OldSS    dw        0                        ; uschovan˜ SS

; -----------------------------------------------------------------------------
;        instalace ovlada‡e (jm‚no souboru DS:DX) -> CY chyba
; -----------------------------------------------------------------------------

InstMus  PROC      NEAR

; ------ v¡cen sobn˜ pokus o instalaci (SOUND BLASTER na rychl˜ch po‡¡ta‡¡ch)

         call      InstMus1
         jnc       InstMus9
         call      InstMus1
         jnc       InstMus9
         call      InstMus1
         jnc       InstMus9

; ------ otev©en¡ souboru ovlada‡e DS:DX

InstMus1:push      dx

         mov       ax,3d00h
         int       21h
         jc        InstMus8                 ; soubor nenalezen
         xchg      ax,bx

; ------ na‡ten¡ souboru do pamˆti

         mov       dx,(offset(Buffer-Start) + 10fh) AND not 0fh
         mov       cx,10000                 ; asi tak max. velikost
         mov       ah,3fh
         int       21h

; ------ uzav©en¡ souboru

         pushf
         mov       ah,3eh
         int       21h
         popf
         jc        InstMus8

; ------ test, zda je nainstalov na zvukov  karta

         sti
         push      ds
         db        9ah                      ; instrukce CALL FAR
         dw        4                        ; offset inicializace ADLIB.BIN
Segm1    dw        0                        ; adresa ADLIB.BIN v pamˆti
         pop       ds
         cmp       al,1                     ; CY = nen¡ nainstalov n

InstMus8:pop       dx
InstMus9:ret

InstMus  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na 1 impuls INT 08h
; -----------------------------------------------------------------------------

Cek08    PROC      NEAR

         sti
         mov       ax,ds:[Cit08]
Cek081:  cmp       ax,ds:[Cit08]
         je        Cek081
         ret

Cek08    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         db        9ah                      ; instrukce CALL FAR
         dw        0                        ; offset melodie ADLIB.BIN
Segm2    dw        0                        ; adresa ADLIB.BIN v pamˆti

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         add       word ptr cs:[Cit08],KONST08 ; ‡¡ta‡ hodin INT 08h
         jc        Int082
         mov       al,20h
         out       [20h],al
         pop       ax
         iret

Int082:  pop       ax
         jmp       dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h

Int08    ENDP

Cit08    dw        0                        ; ‡¡ta‡ hodin INT 08h

; -----------------------------------------------------------------------------
;        nastaven¡ hodin na AX
; -----------------------------------------------------------------------------

Set08    PROC      NEAR

         cli
         push      ax
         mov       al,36h
         out       [43h],al
         pop       ax
         out       [40h],al
         mov       al,ah
         out       [40h],al
         sti
         ret

Set08    ENDP

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

UvTxt    db        'Zvolte zvukovy vystup:',13,10
         db        '     0 ... neni zvuk',13,10
         db        '     1 ... ADLIB',13,10
         db        '     2 ... ROLAND',13,10
         db        '     3 ... TANDY',13,10
         db        ' ENTER ... automaticka detekce',13,10
         db        '   ESC ... preruseni',13,10
         db        '$'

KlavTxt  db        'Stisknete libovolnou klavesu...',13,10,'$'

Soubor1  db        'ADLIB.BIN',0
Soubor2  db        'ROLAN.BIN',0
Soubor3  db        'TANDY.BIN',0

Packet   dw        0                        ; segment prost©ed¡
         dd        80h                      ; adresa p©¡kazov‚ho © dku
         dd        5ch                      ; adresa prvn¡ho FCB
         dd        6ch                      ; adresa druh‚ho FCB

Intro    db        'INTRO.EXE',0

Old08    dd        0                        ; uschovan  adresa INT 08h

Buffer   label     byte                     ; konec programu

Code     ENDS
         END       Start

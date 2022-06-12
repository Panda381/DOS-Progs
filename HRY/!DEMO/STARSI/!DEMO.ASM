
; *****************************************************************************
;
;                         DEMO ke h©e DEATHBRINGER
;
; POZOR - nen¡-li karta ADLIB/SOUND BLASTER a je-li ©adi‡ SCSI, po‡¡ta‡ zamrzne
;         bˆhem testu p©¡tomnosti karty ROLAND (ROLAND.BIN zru¨it) !!!!
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

; ------ instalace p©ehr va‡e ADLIB
;        (u karty SOUNDBLASTER nen¡ pou‘it  metoda detekce dostate‡nˆ
;        spolehliv  a proto je tato instalace zde vol na nˆkolikr t)

         mov       dx,offset Soubor1        ; ADLIB
         call      InstMus
         jnc       Start3
         mov       dx,offset Soubor1        ; ADLIB
         call      InstMus
         jnc       Start3
         mov       dx,offset Soubor1        ; ADLIB
         call      InstMus
         jnc       Start3
         mov       dx,offset Soubor1        ; ADLIB
         call      InstMus
         jnc       Start3

; ------ instalace p©ehr va‡e ROLAND

         mov       dx,offset Soubor2        ; ROLAND
         call      InstMus
         jnc       Start3

; ------ instalace p©ehr va‡e TANDY

         mov       dx,offset Soubor3        ; TANDY
         call      InstMus
         jnc       Start3
         mov       word ptr ds:[((Buffer-Start)+10fh) AND not 0fh],0cbh ; RETF

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
         ja        Start4
         cmp       bl,5
         ja        Start4

; ------ grafick  demonstrace

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

; ------ p©i chybˆ se bude ‡ekat na kl vesu (nap©. nenalezen INTRO.EXE)

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

; ------ otev©en¡ souboru ovlada‡e DS:DX

         mov       ax,3d00h
         int       21h
         jc        InstMus9                 ; soubor nenalezen
         xchg      ax,bx

; ------ na‡ten¡ souboru do pamˆti

         mov       dx,(offset(Buffer-Start) + 10fh) AND not 0fh
         mov       cx,10000                 ; asi tak max. velikost
         mov       ah,3fh
         int       21h
         jc        InstMus9

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

; ------ test, zda je nainstalov na zvukov  karta

         sti
         push      ds
         db        9ah                      ; instrukce CALL FAR
         dw        4                        ; offset inicializace ADLIB.BIN
Segm1    dw        0                        ; adresa ADLIB.BIN v pamˆti
         pop       ds
         cmp       al,1                     ; CY = nen¡ nainstalov n

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
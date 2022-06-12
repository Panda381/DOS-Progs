
; -----------------------------------------------------------------------------
;                                   Video Streamer
;
; P©enosov  rychlost 115200 Baud, 5 bit– bez parity, 1 START bit, 1 STOP bit
;
; Horizont lnˆ:
; ------------
; hodiny 14.161 MHz = 0.56493184 us na znak
; celkem ............... 64 us / 0.56493184 us =            113 znak– (63.8 us)
; 1 bit dat ............ 8.68055556 us / 0.56493184 us =     15 znak– (8.47 us)
; zobrazen  data ....... (5+1) * 15 =                        90 znak– (50.8 us)
; zatemnˆn¡ ............ 113 - 90 =                          23 znak– (13.0 us)
; synchronizace ........ 4.6 us / 0.56493184 =                8 znak– (4.52 us)
; po‡ tek synchronizace  90 + (23-8)/2 =                     97 znak– (54.8 us)
;
; Vertik lnˆ:
; ----------
; 1 videolinka = 63.83729792 us
; celkem videolinek .... 20000/63.83729792 =              313 linek (19981 us)
; zobrazen  data =                                        288 linek (18385 us)
;    synchronizace                              5 linek, znak 16h (SYN)
;    start                                      1 linka, znak 01h (SOH)
;    ‡as za‡ tku nahr vky                       6 linek (6 znak– = 30 bit–)
;                                                  b0  a‘ b4 : sekunda/2 0 a‘ 62
;                                                  b5  a‘ b10: minuta 0 a‘ 63
;                                                  b11 a‘ b15: hodina 0 a‘ 31
;                                                  b16 a‘ b20: den 0 a‘ 31
;                                                  b21 a‘ b24: mˆs¡c 0 a‘ 15
;                                                  b25 a‘ b29: rok 1980 a‘ 2011
;    celkov  d‚lka nahr vky                     3 linky (3 znaky = 15 bit–)
;                                                  b0  a‘ b14: blok– 0 a‘ 32767
;    aktu ln¡ ‡¡slo sektoru                     2 linky (2 znaky = 10 bit–)
;                                                  b0  a‘ b7 : sektor 0 a‘ 255
;                                                  b8    : 1=kontroln¡ sektor
;                                                  b9    : 1=synchroniza‡n¡
;    aktu ln¡ ‡¡slo bloku                       3 linky (3 znaky = 15 bit–)
;                                                  b0  a‘ b14: blok 0 a‘ 32767
;    mezisou‡et CRC z hlav¡                     3 linky (3 znaky = 15 bit–)
;    data                                     256 linek (1 linka=4 bity +parita)
;                                                  celkem 128 datov˜ch bajt–
;    kontroln¡ sou‡et CRC                       3 linky (3 znaky = 15 bit–)
;    synchronizace                              6 linek, znak 16h (SYN)
; zatemnˆn¡                                                25 linek (1596 us)
; synchronizace                                             3 linky (192 us)
; po‡ tek synchronizace                                   291 linka
;
; 1 sektor = 128 bajt– (1 sn¡mek) = 20000 us = 6400 B/sek.
; 1 blok = 256 sektor– (matice 16x16), 33 sektor– kontrola = celkem 289 sektor–
;         1 blok = 32 KB = 5.78 sek. = 5669 B/sek. = 340 KB/min. = 20.4 MB/hod.
; -----------------------------------------------------------------------------

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

b0       EQU       1
b1       EQU       2
b2       EQU       4
b3       EQU       8
b4       EQU       10h
b5       EQU       20h
b6       EQU       40h
b7       EQU       80h
b8       EQU       100h
b9       EQU       200h
b10      EQU       400h
b11      EQU       800h
b12      EQU       1000h
b13      EQU       2000h
b14      EQU       4000h
b15      EQU       8000h

Start:
         cmp       byte ptr ds:[80h],1
         ja        start4

         call      InitKodT                 ; inicializace k¢dovac¡ch tabulek
         call      InitTV                   ; inicializace TV videom¢du

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti

Start3:  mov       si,offset TestBuff

Start2:  call      WritSekt                 ; z pis jednoho sektoru

         mov       aH,1
         int       16h
         jz        Start2

         mov       ah,0
         int       16h

         cmp       al,27
         jne       Start3

         mov       ax,3
         int       10h

         int       20h

; -----------------------------------------------------------------------------
;        p©¡jem
; -----------------------------------------------------------------------------

Start4:
         in        al,[21h]
         or        al,1
         out       [21h],al

         call      InitPrij

Start5:  mov       word ptr ds:[SektUkaz],offset DatBuff

Start6:  sti
         call      IntPrij

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[41ch]
         cmp       ax,ds:[41ah]
         pop       ds
         jne       start7

         cmp       word ptr cs:[SektUkaz],offset DatBuff + 128
         jb        Start6

         jmp       short Start5

Start7:  in        al,[21h]
         and       al,not 1
         out       [21h],al

         mov       ah,1
         int       16h
         jz        start8
         mov       ah,0
         int       16h
start8:
         int       20h

; -----------------------------------------------------------------------------
;        p©eru¨en¡ p©i p©¡jmu sektoru
; -----------------------------------------------------------------------------

IntPrij  PROC      NEAR

         push      ax
         push      dx

         mov       dx,cs:[AdrPort]
         add       dx,5
         in        al,dx
         test      al,1
         jz        IntPrij6

         push      si
         sub       dx,5
         in        al,dx
         mov       si,cs:[SektUkaz]
         mov       ds:[si],al
         inc       si
         mov       cs:[SektUkaz],si
         pop       si

IntPrij6:pop       dx
         pop       ax
         ret

IntPrij  ENDP

; -----------------------------------------------------------------------------
;        inicializace portu na p©¡jem
; -----------------------------------------------------------------------------

InitPrij PROC      NEAR

         push      ds
         mov       bx,ds:[Port]
         shl       bx,1
         xor       ax,ax
         mov       ds,ax
         mov       dx,ds:[bx+400h]
         pop       ds
         mov       ds:[AdrPort],dx          ; 0:

         add       dx,3                     ; 3:
         mov       al,10000000b             ; DLAB, bez parity, 1 STOP, 5 bit–
         out       dx,al

         inc       dx                       ; 4:
         mov       al,1010b
         out       dx,al                    ; ©¡dic¡ registr modemu

         sub       dx,4                     ; 0:
         mov       al,1
         out       dx,al
         inc       dx                       ; 1:
         mov       al,0
         out       dx,al

         inc       dx                       ; 2:
         inc       dx                       ; 3:
         mov       al,00000000b
         out       dx,al

         dec       dx                       ; 2:
         dec       dx                       ; 1:
         mov       al,0000b
         out       dx,al

         ret

InitPrij ENDP

; -----------------------------------------------------------------------------
;        inicializace k¢dovac¡ch tabulek
; -----------------------------------------------------------------------------

InitKodT PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ inicializace k¢dovac¡ tabulky

         xor       dx,dx                    ; DL=ukazatel k¢dovan‚ho bajtu
         xor       cx,cx                    ; CX <- 0
         mov       di,offset KodTab         ; k¢dovac¡ tabulka
         push      cs
         pop       es
         cld

; ------ START bit

InitKdT1:mov       al,-1
         mov       cl,15
         rep       stosb

; ------ ulo‘en¡ bit– bajtu

         mov       dh,dl                    ; bajt k zak¢dov n¡
         mov       ah,5                     ; po‡et bit– bajtu
InitKdT3:mov       al,-1
         shr       dh,1
         jnc       InitKdT4
         mov       al,0
InitKdT4:mov       cl,15
         rep       stosb
         dec       ah
         jnz       InitKdT3

; ------ dal¨¡ bajt

         add       di,128-6*15
         inc       dx                       ; zv˜¨en¡ ukazatele znaku
         cmp       dl,32
         jne       InitKdT1                 ; dal¨¡ bajt

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

InitKodT ENDP

; -----------------------------------------------------------------------------
;        inicializace TV videom¢du
; -----------------------------------------------------------------------------

InitTV   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ inicializace podobn‚ho videom¢du

         mov       ax,10h
         int       10h                      ; inicializace videom¢du

; ------ vypnut¡ displeje

         mov       ah,0
         call      SetOff                   ; vypnut¡ displeje

; ------ nastaven¡ registru m¢du

         mov       dx,3c4h                  ; ©¡dic¡ port
         mov       ax,100h                  ; povel - povoleno nastaven¡
         call      OutReg                   ; nastaven¡ videoregistru
         mov       ax,901h                  ; povel: 8 bod– na znak, ¨irok 
                                            ;        linka, p–len˜ takt bod–
         call      OutReg                   ; nastaven¡ videoregistru

         mov       dx,3CCh
         in        al,dx
         and       al,23h
         or        al,4                     ; negativn¡ polarita
         mov       dx,3C2h
         out       dx,al                    ; nastaven¡ ©¡dic¡ch funkc¡

         mov       dx,3C4h
         mov       ax,300h                  ; povel - z kaz nastaven¡
         call      OutReg                   ; nastaven¡ videoregistru

; ------ nastaven¡ videoregistr–

         mov       dx,3d4h
         mov       ax,11h
         call      OutReg                   ;

         mov       si,offset TabReg         ; tabulka videoregistr–
         mov       al,0                     ; ukazatel ‡¡sla registru
         mov       cx,17h
InitTV4: mov       ah,ds:[si]
         inc       si
         call      OutReg
         inc       ax
         loop      InitTV4

; ------ zapnut¡ displeje

         mov       ah,20h
         call      SetOff                   ; zapnut¡ displeje

; ------ n vrat registr–

InitTV9: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitTV   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡/zapnut¡ displeje (podle registru AH)
; -----------------------------------------------------------------------------

SetOff   PROC      NEAR

         mov       dx,3dah                  ; stavov˜ registr CGA
         in        al,dx                    ; synchronizace
         mov       dl,0bah                  ; stavov˜ registr MDA
         in        al,dx                    ; synchronizace
         mov       dl,0c0h
         mov       al,ah                    ; stav pro vypnut¡/zapnut¡
         out       dx,al                    ; vypnut¡/zapnut¡ displeje
         ret

SetOff   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ videoregistru AL na hodnotu AH
; -----------------------------------------------------------------------------

OutReg   PROC      NEAR

         out       dx,al
         inc       dx
         xchg      ah,al
         out       dx,al
         dec       dx
         xchg      ah,al
         ret

OutReg   ENDP

; -----------------------------------------------------------------------------
;        inicializace sektoru (z pis synchoniza‡n¡ch bit–)
; -----------------------------------------------------------------------------

InitSekt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di


; ------ n vrat registr–

         pop       di
         pop       cx
         pop       ax
         ret

InitSekt ENDP

; -----------------------------------------------------------------------------
;        z pis jednoho sektoru DS:SI (ES=segment videopamˆti)
; -----------------------------------------------------------------------------

WritSekt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       dx,3c4h
         mov       ax,0f02h
         call      OutReg

; ------ p©¡prava k dek¢dov n¡ sektoru

         mov       bp,288                   ; po‡et bajt– k dek¢dov n¡
         cld
         mov       di,cs:[AktPage]          ; ukl dac¡ adresa do videopamˆti
         mov       bx,si
         xor       cx,cx

; ------ z pis jednoho znaku

WritSkt2:mov       ah,ds:[bx]
         inc       bx
         and       ax,1f00h
         shr       ax,1                     ; bajt * 128
         add       ax,offset KodTab         ; k¢dovac¡ tabulka
         xchg      ax,si
         mov       cl,6*15/2
         push      ds
         push      cs
         pop       ds
         rep       movsw
         pop       ds

         dec       bp                       ; ‡¡ta‡ slov k dek¢dov n¡
         jnz       WritSkt2                 ; z pis dal¨¡ho slova

; ------ ‡ek n¡ na sn¡mkov˜ impuls

         mov       dx,3dah
WritSkt1:in        al,dx
         test      al,8
         jz        WritSkt1

; ------ p©epnut¡ videostr nky

         mov       dx,3d4h
         mov       ah,byte ptr cs:[AktPage+1]
         mov       al,0ch
         call      OutReg
         xor       byte ptr cs:[AktPage+1],80h

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritSekt ENDP

; -----------------------------------------------------------------------------
;                         InitRnd
;                  inicializace gener toru n hody
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

InitRnd  PROC      NEAR

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; ‡¡ta‡ syst‚mov‚ho ‡asova‡e
         pop       ds
         mov       word ptr ds:[RandomR],ax ; inicializa‡n¡ konstanta
         pop       ax
         ret

InitRnd  ENDP

; -----------------------------------------------------------------------------
;                           Random
;                   gener tor n hodn‚ho ‡¡sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datov˜ segment
; VSTUP: AX=‡¡slo 0 a‘ (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; po‘adovan˜ rozsah
         call      Random0                  ; generov n¡ n hodn‚ho ‡¡sla DX:AX
         xchg      ax,dx                    ; AX <- n hodn‚ ‡¡slo
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

; ------ gener tor n hody

RandomR  dd        21510d31h                ; promˆnn  pro gener tor n hody
RandomD  dw        8405h                    ; pomocn  konstanta

AktPage  dw        8000h                    ; adresa neaktivn¡ videostr nky


Port     dw        0                        ; ‡¡slo datov‚ho portu
AdrPort  dw        3f8h                     ; adresa portu COM
SektUkaz dw        offset DatBuff

TabReg   label     byte
         db        113-5                    ; 0: po‡et horizont.pozic celkem - 5
         db        90-1                     ; 1: po‡et zobrazen˜ch znak– - 1
         db        90                       ; 2: po‡ tek horizont. zatemnˆn¡
         db        ((90+23-2) AND 1fh) + b7 ; 3: konec horizont. zatemnˆn¡
         db        97                       ; 4: po‡ tek horizont. synchronizace
         db        ((97+8-1) AND 1fh) + ((90+23-2) AND 20h)*4 ; 5: konec hor.s.
         db        (313-2) AND 0ffh         ; 6: po‡et vertik. linek celkem
         db        b0+b1+b2+b3+b4           ; 7: dopl¤uj¡c¡ bity registr–
         db        0                        ; 8: prvn¡ linka po vert.zpˆt.bˆhu
         db        0+b6                     ; 9: po‡et linek na znak - 1
         db        0                        ; 0ah: prvn¡ linka kurzoru
         db        0                        ; 0bh: koncov  linka kurzoru
         db        0                        ; 0ch: po‡ t. adresa ve VRAM HIGH
         db        0                        ; 0dh: po‡ t. adresa ve VRAM LOW
         db        0                        ; 0eh: adresa kurzoru HIGH
         db        0                        ; 0fh: adresa kurzoru LOW
         db        291 AND 0ffh             ; 10h: za‡ tek vertik. synchronizace
         db        (291+3-1) AND 1fh        ; 11h: konec vertik. synchronizace
         db        (288-1) AND 0ffh         ; 12h: posledn¡ zobrazen  linka
         db        90/2                     ; 13h: p©¡rustek adresy v pamˆti
         db        31                       ; 14h: poloha podtr‘en¡
         db        (288-1) AND 0ffh         ; 15h: za‡ tek vertik. zatemnˆn¡
         db        (288+25-2) AND 0ffh      ; 16h: konec vertik. zatemnˆn¡

KodTab   db        32 dup(128 dup(?))       ; k¢dovac¡ tabulka

TestBuff label     byte                     ; buffer testovac¡ho vzorku
         db        5 dup(16h)               ; synchronizace
         db        1                        ; start
         db        1,2,3,4,5,6              ; ‡as za‡ tku nahr vky
         db        1,0,0                    ; celkov  d‚lka nahr vky (blok–)
         db        31,31                    ; ‡¡slo sektoru - synchroniza‡n¡
         db        0,0,0                    ; aktu ln¡ ‡¡slo bloku
         db        31,31,31                 ; mezisou‡et CRC
         db        128 dup(0ah,5)           ; data
         db        31,31,31                 ; kontroln¡ sou‡et CRC
         db        6 dup(16h)               ; synchronizace

DatBuff  db        50 * 128 dup(?)

Code     ENDS
         END       Start

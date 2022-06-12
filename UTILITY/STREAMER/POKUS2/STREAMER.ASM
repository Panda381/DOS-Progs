
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
; P©enosov  rychlost 115200 Baud
; 8 datov˜ch bit–, bez parity, 1 START bit, 1 STOP bit
; 86.80555556 us na bajt
; 230 bajt– celkem na sektor (19965 us)
; -----------------------------------------------------------------------------
; Struktura sektoru:
;    Sektor je organizov n do matice 11 © dk– po 20 bajtech. Posledn¡ bajt
;    v ka‘d‚m © dku je kontroln¡ a je to XOR p©edch zej¡c¡ch 19 bajt–.
;    Posledn¡ 11. © dek je kontroln¡ a je to XOR p©edch zej¡c¡ch 10 © dk–.
;    Platn  data jsou 10*19=190 bajt–, z toho prvn¡ch 10 bajt– je z hlav¡,
;    skute‡n˜ch dat je 180 bajt–.
;
;           0: (4) absolutn¡ ‡as za‡ tku nahr vky (po‡et sekund od 1.1.1980)
;           4: (2) celkov  d‚lka nahr vky v sekund ch/2 (max. 36 hodin)
;                        (0FFFFh = 36 hodin 24 minut 30 sekund a v¡ce)
;           6: (2) aktu ln¡ ‡¡slo bloku 0 a‘ 16383
;                  b14: 0=datov˜ sektor (0 a‘ 255), 1=korek‡n¡ sektor (0 a‘ 32)
;                  b15: 0=datov˜ blok, 1=adres ©ov˜ blok
;           8: (1) aktu ln¡ ‡¡slo sektoru v bloku 0 a‘ 255
;                      korek‡n¡ sektor  33 -> z vˆre‡n˜ synchroniza‡n¡ sektor
;                      korek‡n¡ sektor 255 -> po‡ te‡n¡ synchroniza‡n¡ sektor
;           9: (1) informace o dˆlen¡ blok– do skupin
;                  b0  a‘ b3 : po‡et datov˜ch blok– ve skupinˆ 1 a‘ 16
;                  b4  a‘ b7 : oddˆlovac¡ mezera mezi skupinami (2 a‘ 32 sekund)
;
;   - Po‡ te‡n¡ synchroniza‡n¡ sektor obsahuje na pozici 10: offset popisova‡e
;        prvn¡ho souboru v bloku (0ffffh = neza‡¡n  ‘ dn˜ popisova‡ souboru).
;   - Pro synchroniza‡n¡ sektory jsou n sleduj¡c¡ bajty nastaveny na 0FFh.
;
;          10: (9) zbytek prvn¡ho © dku - data
;          19: (1) kontroln¡ sou‡et XOR prvn¡ho © dku
;
;          20: (180) ostatn¡ data (9 © dk– x (19 bajt– + 1 kontroln¡))
;
;         200: (20) kontroln¡ opravn˜ © dek XOR pro data i z hlav¡
;
;         220: (2) kontroln¡ sou‡et cel‚ho sektoru CRC (i se z hlav¡m)
;
;         222: (1) £vodn¡ synchronizace 0ffh
;         223: (2) sn¡mkov  synchronizace 0ffh
;         225: (3) z vˆre‡n  synchronizace 0ffh
;         228: (1) START bajt 02h
;         229: (1) START bajt 0e5h
; -----------------------------------------------------------------------------
; Struktura bloku:
;          256 sektor– data (v matici 16*16)
;           16 kontroln¡ sektory © dk– XOR
;           16 kontroln¡ sektory sloupc– XOR
;            1 kontroln¡ sektor celkov˜ XOR
;   celkem 289 sektor– na blok
; -----------------------------------------------------------------------------
; €asov n¡:
;    1 sektor = 230 bajt– * 86.80555556 us = 19965.277779 us,  u‘ite‡n˜ch 180 B
;         efektivn¡ rychlost 9015.65217 B/sekundu, vy‘aduje pamˆŸ 224 Bajt–
;    1 blok = 289 sektor– * 19.965277779 ms = 5.76996527 s, u‘ite‡n˜ch 256 sekt.
;         rychlost 7986.18325 B/sekundu, vy‘aduje pamˆŸ 64736 Bajt–
;    1 blok p©enese 46080 B, vy‘aduje 64736 B
;      najednou se p©enesou 4 bloky, vy‘aduj¡ 262144 Bajt– pamˆti (184320 B)
;    ‡as pro 4 bloky: 23.07986108 sek., mezera asi 7 sekund, celkem 30 sekund
;    efektivn¡ rychlost = 6144 B/sek. = 368.640 KB/min = 22.118 MB/hod.
; -----------------------------------------------------------------------------
; Popisova‡ souboru:
;        0: (1) d‚lka popisova‡e
;        1: (1) atributy
;        2: (2) ‡as
;        4: (2) datum
;        6: (2) ‡¡slo po‡ te‡n¡ho aloka‡n¡ho bloku
;        8: (4) velikost (bajt–)
;       12: (2) po‡ te‡n¡ ‡¡slo bloku
;       14: (1) po‡ te‡n¡ ‡¡slo sektoru
;       15: (1) po‡ te‡n¡ offset v sektoru
;       16: (x) pln‚ jm‚no souboru ASCII (d‚lka podle bajtu d‚lky)
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

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

HI       EQU       256

UVSYNCH  EQU       60                       ; £vodn¡ synchroniza‡n¡ sektory
ZAVSYNCH EQU       30                       ; z vˆre‡n‚ synchroniza‡n¡ sektory
MINSYNCH EQU       12                       ; minim ln¡ po‡et synchroniz.sektor–

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©edefinov n¡ ukazatele z sobn¡ku

Start:   cmp       sp,offset Zasob          ; je z sobn¡k OK ?
         jb        Start1                   ; nedostatek pamˆti
         mov       sp,offset Zasob          ; p©edefinov n¡ z sobn¡ku

; ------ zmen¨en¡ bloku programu na minimum

         mov       bx,(offset(Zasob-Start)+10fh)/16 ; velikost programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu
         jnc       Start2

; ------ chyba - nedostatek pamˆti

Start1:  mov       dx,offset MemTxt
         mov       ah,9
         int       21h
         int       20h

; ------ vytvo©en¡ bufferu soubor–

Start2:  mov       bx,(289*180+15)/16       ; velikost bufferu soubor–
         mov       ah,48h
         int       21h                      ; vytvo©en¡ bufferu soubor–
         jc        Start1                   ; chyba - nedostatek pamˆti
         mov       ds:[BuffSeg],ax          ; adresa bufferu soubor–

; ------ vytvo©en¡ bufferu sektor–

         mov       bx,-1
         mov       ah,48h
         int       21h
         jnc       Start1
         mov       ah,48h
         int       21h                      ; vytvo©en¡ maxim ln¡ho bufferu
         jc        Start1                   ; nedostatek pamˆti
         cmp       bx,(289+20)*(224/16)     ; minim ln¡ velikost bufferu
         jb        Start1                   ; nedostatek pamˆti

; ------ v˜po‡et parametr– bufferu sektor–

         mov       ds:[SektBSeg],ax         ; adresa za‡ tku bufferu sektor–
         add       ax,bx                    ; adresa konce bufferu sektor–
         mov       ds:[SektESeg],ax         ; adresa konce bufferu sektor–
         xchg      ax,bx                    ; AX <- velikost bufferu sektor–
         xor       dx,dx
         mov       bx,224/16                ; velikost jednoho sektoru
         div       bx                       ; v˜po‡et po‡tu sektor–
         mov       ds:[SektMax],ax          ; maxim ln¡ po‡et sektor–
         sub       ds:[SektESeg],dx         ; oprava konce bufferu sektor–
         sub       ax,15                    ; p r sektor– rezerva
         xor       dx,dx
         mov       bx,289+2                 ; po‡et sektor– na blok (+ synch.)
         div       bx                       ; v˜po‡et po‡tu blok–
         mov       ds:[MaxDBlok],ax         ; maxim ln¡ po‡et datov˜ch blok–




         cmp       byte ptr ds:[80h],2
         jne       Start000
         jmp       Starr

Start000:
         mov       ax,ds:[SektBSeg]
         mov       ds:[SektSeg],ax

;         mov       ax,ds:[BuffSeg]
;         mov       es,ax
;         xor       di,di
;         mov       cx,289*180/2
;         cld
;         mov       ax,-1
;         rep       stosw

         call      RSoub

         call      KodBlok                  ; v˜po‡et kontroln¡ch sektor–

         call      KodSYNU                  ; k¢dov n¡ £vodn¡ho synchr. sektoru

         mov       byte ptr ds:[AktSekt],0  ; aktu ln¡ ‡¡slo sektoru
         and       byte ptr ds:[AktBlok+1],not (b14/HI) ; datov˜ sektor
         mov       cx,289
         mov       ax,ds:[BuffSeg]
         mov       es,ax
         xor       si,si
Start001:call      KodSekt
         inc       byte ptr ds:[AktSekt]
         jnz       Start002
         or        byte ptr ds:[AktBlok+1],b14/HI

Start002:add       si,180
         loop      Start001

         call      KodSYNZ                  ; k¢dov n¡ z vˆre‡n‚ho synch.sektoru

         mov       byte ptr ds:[CitByte],0
         mov       word ptr ds:[CitSekt],0

         mov       ax,ds:[SektBSeg]
         mov       ds:[SektSeg],ax

         mov       word ptr ds:[SektUkaz],0
         mov       word ptr ds:[CitSynch],UVSYNCH ; po‡et synchroniz. sektor–

         cli
         call      InitVys
         jnc       Start01
         jmp       Start12

Start01: mov       al,0ffh
         mov       dx,ds:[AdrPort]
         out       dx,al
         add       dx,5
         in        al,dx
         sti

Start02:

Start11:  sti
         call      Kurz

;         push      ds
;         xor       ax,ax
;         mov       ds,ax
;         mov       ax,ds:[41ch]
;         cmp       ax,ds:[41ah]
;         pop       ds
         cmp       byte ptr ds:[KeyBreak],0
         jne       start13                  ; p©eru¨en¡ ESC

         cmp       word ptr ds:[CitSekt],289+ZAVSYNCH
         jb        Start11

start13:
         call      DeInit                   ; odinstalov n¡ portu COM

         mov       ah,1
         int       16h
         jz        start12
         mov       ah,0
         int       16h
start12:

         int       20h

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

Kurz     PROC      NEAR

         push      ax
         push      es

         mov       ax,0b800h
         mov       es,ax
         inc       byte ptr es:[0]
         jnz       Kurz2
         inc       byte ptr es:[2]
Kurz2:   jnz       Kurz3
         inc       byte ptr es:[4]

Kurz3:
         pop       es
         pop       ax
         ret

Kurz     ENDP

; -----------------------------------------------------------------------------
;        p©¡jem
; -----------------------------------------------------------------------------
;þ
Starr:
         mov       al,ds:[82h]
         and       al,3
         mov       ds:[Param],al

         mov       ax,ds:[SektBSeg]
         mov       ds:[SektSeg],ax

         cli
         call      InitPri
         jnc       Starr01
         jmp       Starr2

Starr01: mov       dx,ds:[AdrPort]
         in        al,dx
         add       dx,5
         in        al,dx

         mov       byte ptr ds:[CitByte],-4
         mov       word ptr ds:[CitSekt],0
         mov       word ptr ds:[SektUkaz],0
         mov       word ptr ds:[CitSynch],MINSYNCH ; po‡et synchroniz. sektor–

         sti

         mov       es,ds:[SektSeg]
         xor       di,di

Starr02:

Starr1:  sti
         call      Kurz
         cmp       byte ptr ds:[KeyBreak],0
         jne       starr3                   ; p©eru¨en¡ ESC

         cmp       word ptr ds:[CitSekt],289
         jb        Starr1

Starr3:  call      DeInit

; ------ inicializace mapy vadn˜ch sektor–

         push      ds
         pop       es
         mov       di,offset ErrMap
         mov       cx,289
         mov       al,-1
         cld
         rep       stosb                    ; vymaz n¡ mapy vadn˜ch sektor–
         mov       word ptr ds:[ErrCit],289 ; po‡et vadn˜ch sektor–

; ------ dek¢dov n¡ sektor–

         mov       ax,ds:[SektBSeg]
         mov       ds:[SektSeg],ax
         mov       cx,289                   ; po‡et sektor–

Starr31: xor       ax,ax
         call      KorSekt                  ; korekce sektoru
         sbb       ax,ax                    ; -1=vadn˜ sektor, 0=OK
         cmp       bx,289                   ; je ‡¡slo sektoru OK ?
         jae       Starr314                 ; chybn‚ ‡¡slo sektoru
         cmp       byte ptr ds:[ErrMap+bx],0 ; je sektor ji‘ nastaven ?
         je        Starr314                 ; je ji‘ nastaven
         mov       byte ptr ds:[ErrMap+bx],al ; p©¡znak vadn‚ho sektoru
         inc       ax                       ; 1=OK, 0=vadn˜
         sub       word ptr ds:[ErrCit],ax  ; sn¡‘en¡ ‡¡ta‡e vadn˜ch sektor–

         sub       word ptr ds:[SektSeg],224/16 ; sn¡‘en¡ adresy sektoru
         call      DekSekt                  ; dek¢dov n¡ sektoru
Starr314:loop      Starr31                  ; dal¨¡ sektor

         call      KorBlok                  ; korekce blok– (oprava chyb)
         mov       ax,ds:[ErrCit]
         add       ds:[CitChyb],ax

         call      WSoub

         mov       dx,offset KorTxt1
         mov       ah,9
         int       21h

         mov       ax,ds:[CitKor1]
         call      DispNum

         mov       dx,offset KorTxt2
         mov       ah,9
         int       21h

         mov       ax,ds:[CitKor2]
         call      DispNum

         mov       dx,offset KorTxt3
         mov       ah,9
         int       21h

         mov       ax,ds:[CitChyb]
         call      DispNum

         mov       dx,offset KorTxt4
         mov       ah,9
         int       21h

         mov       ah,1
         int       16h
         jz        starr2
         mov       ah,0
         int       16h
Starr2:
         mov       ax,4c00h
         int       21h

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

DispNum2:pop       dx
         mov       ah,2
         add       dl,"0"
         int       21h
         loop      DispNum2

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

RSoub    PROC      NEAR

         mov       dx,offset Soubor
         mov       ax,3d00h
         int       21h
         jc        RSoub9
         mov       bx,ax

         push      ds
         mov       ax,ds:[BuffSeg]
         mov       ds,ax
         xor       dx,dx
         mov       cx,256*180
         mov       ah,3fh
         int       21h
         pop       ds

         mov       ah,3eh
         int       21h
RSoub9:  ret

RSoub    ENDP

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

WSoub    PROC      NEAR

         mov       dx,offset Soubor2
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        WSoub9
         mov       bx,ax

         push      ds
         mov       ax,ds:[BuffSeg]
         mov       ds,ax
         xor       dx,dx
         mov       cx,256*180
         mov       ah,40h
         int       21h
         pop       ds

         mov       ah,3eh
         int       21h
WSoub9:  ret

WSoub    ENDP


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           Zpracov n¡ dat
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        zak¢dov n¡ datov‚ho bloku (sestaven¡ kontroln¡ch sektor–)
; -----------------------------------------------------------------------------

KodBlok  PROC      NEAR

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

         mov       es,ds:[BuffSeg]          ; segment bufferu soubor–
         push      es
         pop       ds
         mov       di,256*180               ; ukl dac¡ adresa sektor–
         xor       cx,cx
         cld

; ------ v˜po‡et kontroln¡ch sektor– © dk–

         xor       si,si                    ; za‡ tek matice
         mov       bx,16                    ; po‡et © dk– sektor– k v˜po‡tu
KodBlok1:mov       dx,180                   ; po‡et bajt– v sektoru
KodBlok2:mov       cl,16                    ; po‡et sektor–
         mov       al,0
KodBlok3:xor       al,ds:[si]
         add       si,180                   ; bajt v dal¨¡m sektoru
         loop      KodBlok3
         stosb                              ; kontroln¡ bajt sektor– v © dku
         sub       si,16*180-1              ; adresa dal¨¡ho bajtu
         dec       dx                       ; ‡¡ta‡ bajt–
         jnz       KodBlok2                 ; dal¨¡ bajt v sektoru
         add       si,16*180-180            ; adresa dal¨¡ho © dku
         dec       bx                       ; ‡¡ta‡ © dk–
         jnz       KodBlok1                 ; v˜po‡et dal¨¡ho © dku

; ------ v˜po‡et kontroln¡ch sektor– sloupc–

         mov       dx,16*180                ; po‡et sloupc–
         xor       si,si                    ; po‡ te‡n¡ adresa matice
KodBlok4:mov       cl,16                    ; po‡et sektor– ve sloupci
         mov       al,0
KodBlok5:xor       al,ds:[si]
         add       si,16*180                ; bajt sektoru v dal¨¡m © dku
         loop      KodBlok5                 ; dal¨¡ © dek
         stosb
         sub       si,16*16*180-1           ; dal¨¡ sloupec bajt–
         dec       dx                       ; ‡¡ta‡ sloupc–
         jnz       KodBlok4                 ; dal¨¡ sloupec

; ------ koncov˜ kontroln¡ sou‡et

         mov       si,(256+16)*180          ; © dek kontroln¡ch sektor– sloupc–
         mov       dx,180                   ; po‡et bajt– v sektoru
KodBlok6:mov       cl,16                    ; po‡et sektor–
         mov       al,0
KodBlok7:xor       al,ds:[si]
         add       si,180
         loop      KodBlok7                 ; dal¨¡ sektor v © dku
         stosb
         sub       si,16*180-1              ; adresa dal¨¡ho bajtu v sektoru
         dec       dx
         jnz       KodBlok6                 ; dal¨¡ bajt v sektoru

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

KodBlok  ENDP

; -----------------------------------------------------------------------------
;        proveden¡ korekce datov‚ho bloku
; -----------------------------------------------------------------------------

KorBlok  PROC      NEAR

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

         test      byte ptr ds:[Param],b1   ; prov d¡ se korekce 2 ?
         jz        KorBlk11                 ; neprov d¡ se korekce 2

         mov       es,ds:[BuffSeg]          ; adresa bufferu soubor–
         xor       cx,cx
         cld
KorBlok1:cmp       word ptr ds:[ErrCit],0   ; jsou nˆjak‚ chyby ?
         jne       KorBlok2                 ; jsou nˆjak‚ chyby
KorBlk11:jmp       KorBlok9                 ; nejsou chyby

; ------ nalezen¡ © dku s jednou chybou

KorBlok2:mov       di,offset ErrMap+256     ; kontroln¡ sektory © dk–
         mov       si,offset ErrMap         ; mapa vadn˜ch sektor–
         mov       dl,16                    ; DL <- po‡et © dk–
KorBlk21:mov       cl,16                    ; po‡et pozic v © dku
         mov       dh,0                     ; ‡¡ta‡ chyb
KorBlk22:call      TestBlk                  ; test bloku DS:SI, je-li vadn˜
         loop      KorBlk22
         xchg      si,di
         call      TestBlk
         xchg      si,di
         cmp       dh,1                     ; je 1 chyba ?
         je        KorBlok3                 ; je 1 chyba
         dec       dl                       ; ‡¡ta‡ © dk–
         jnz       KorBlk21                 ; dal¨¡ © dek

; ------ test po‡tu chyb v kontroln¡m © dku sloupc–

         mov       si,offset ErrMap+256+16  ; kontroln¡ © dek sloupc–
         mov       cl,17                    ; po‡et sektor– ke kontrole
         mov       dh,0                     ; ‡¡ta‡ chyb
KorBlk25:call      TestBlk                  ; test bloku
         loop      KorBlk25
         mov       di,si                    ; kontroln¡ bajt + 1
         dec       si                       ; korekce na © dek+16
         cmp       dh,1                     ; je 1 chyba v kontroln¡m © dku ?
         je        KorBlok3                 ; je 1 chyba

; ------ test po‡tu chyb v kontroln¡m © dku © dk–

         mov       si,offset ErrMap+256
         mov       cl,16                    ; po‡et sektor– ke kontrole
         mov       dh,0                     ; ‡¡ta‡ chyb
KorBlk26:call      TestBlk                  ; test bloku
         loop      KorBlk26
         xchg      si,di                    ; DI <- adresa konce © dku
         mov       si,offset ErrMap+256+16+16 ; celkov˜ kontroln¡ sektor
         call      TestBlk
         xchg      si,di
         cmp       dh,1                     ; je 1 chyba ?
         jne       KorBLok4                 ; nen¡ 1 chyba-prohled v n¡ sloupc–

; ------ vodorovn  korekce sektoru (BX=vadn˜ sektor, SI=© dek+16, DI=kontrola+1)

KorBlok3:mov       byte ptr ds:[bx],0       ; zru¨en¡ p©¡znaku vadn‚ho sektoru
         sub       bx,offset ErrMap         ; ‡¡slo sektoru k opravˆ
         sub       si,offset ErrMap+16      ; ‡¡slo © dku k opravˆ
         sub       di,offset ErrMap+1       ; ‡¡slo kontroln¡ho sektoru

; ------ v˜po‡et adres sektor–

         mov       ax,180                   ; po‡et bajt– na sektor
         mul       bx
         xchg      ax,bx                    ; BX <- adresa sektoru k opravˆ
         mov       ax,180                   ; po‡et bajt– na sektor
         mul       si
         xchg      ax,si                    ; SI <- adresa © dku sektor–
         mov       ax,180                   ; po‡et bajt– na sektor
         mul       di
         xchg      ax,di                    ; DI <- adresa kontroln¡ho sektoru

; ------ proveden¡ horizont ln¡ korekce sektoru

         push      ds
         push      es
         pop       ds                       ; DS <- adresa bufferu sektor–
         mov       dx,180                   ; po‡et bajt– ke korekci
KorBlk32:mov       cl,16                    ; po‡et sektor– v © dku
         mov       al,0                     ; st©ada‡ kontroln¡ho sou‡tu
KorBlk34:xor       al,ds:[si]
         add       si,180
         loop      KorBlk34
         xor       al,ds:[di]               ; kontroln¡ sektor
         xor       ds:[bx],al               ; proveden¡ korekce
         sub       si,16*180-1              ; ukazatel sektor– v © dku
         inc       di                       ; ukazatel kontroln¡ho sektoru
         inc       bx                       ; ukazatel opravovan‚ho sektoru
         dec       dx                       ; ‡¡ta‡ bajt– v sektoru
         jnz       KorBlk32                 ; dal¨¡ bajt
         pop       ds
         dec       word ptr ds:[ErrCit]     ; sn¡‘en¡ ‡¡ta‡e chyb
         inc       word ptr ds:[CitKor2]    ; ‡¡ta‡ korekc¡ 2
         jmp       KorBlok1                 ; dal¨¡ opravy



; ------ nalezen¡ sloupce s jednou chybou

KorBlok4:mov       di,offset ErrMap+256+16  ; kontroln¡ sektory sloupc–
         mov       si,offset ErrMap         ; mapa vadn˜ch sektor–
         mov       dl,16                    ; DL <- po‡et sloupc–
KorBlk41:mov       cl,16                    ; po‡et © dk– ve sloupci
         mov       dh,0                     ; ‡¡ta‡ chyb
KorBlk42:call      TestBlk                  ; test bloku DS:SI, je-li vadn˜
         add       si,16-1                  ; adresa dal¨¡ho © dku
         loop      KorBlk42
         sub       si,16*16-1               ; za‡ tek dal¨¡ho sloupce
         xchg      si,di
         call      TestBlk
         xchg      si,di
         cmp       dh,1                     ; je 1 chyba ?
         je        KorBlok5                 ; je 1 chyba
         dec       dl                       ; ‡¡ta‡ © dk–
         jnz       KorBlk41                 ; dal¨¡ © dek
         jmp       KorBlok9                 ; opravu nelze prov‚st

; ------ vertik. korekce sektoru (BX=vadn˜ sektor, SI=sloupec+1, DI=kontrola+1)

KorBlok5:mov       byte ptr ds:[bx],0       ; zru¨en¡ p©¡znaku vadn‚ho sektoru
         sub       bx,offset ErrMap         ; ‡¡slo sektoru k opravˆ
         sub       si,offset ErrMap+1       ; ‡¡slo sloupce k opravˆ
         sub       di,offset ErrMap+1       ; ‡¡slo kontroln¡ho sektoru

; ------ v˜po‡et adres sektor–

         mov       ax,180                   ; po‡et bajt– na sektor
         mul       bx
         xchg      ax,bx                    ; BX <- adresa sektoru k opravˆ
         mov       ax,180                   ; po‡et bajt– na sektor
         mul       si
         xchg      ax,si                    ; SI <- adresa sloupce sektor–
         mov       ax,180                   ; po‡et bajt– na sektor
         mul       di
         xchg      ax,di                    ; DI <- adresa kontroln¡ho sektoru

; ------ proveden¡ vertik ln¡ korekce sektoru

         push      ds
         push      es
         pop       ds                       ; DS <- adresa bufferu sektor–
         mov       dx,180                   ; po‡et bajt– ke korekci
KorBlk52:mov       cl,16                    ; po‡et sektor– ve sloupci
         mov       al,0                     ; st©ada‡ kontroln¡ho sou‡tu
KorBlk54:xor       al,ds:[si]
         add       si,16*180
         loop      KorBlk54
         xor       al,ds:[di]               ; kontroln¡ sektor
         xor       ds:[bx],al               ; proveden¡ korekce
         sub       si,16*16*180-1           ; ukazatel sektor– ve sloupci
         inc       di                       ; ukazatel kontroln¡ho sektoru
         inc       bx                       ; ukazatel opravovan‚ho sektoru
         dec       dx                       ; ‡¡ta‡ bajt– v sektoru
         jnz       KorBlk52                 ; dal¨¡ bajt
         pop       ds
         dec       word ptr ds:[ErrCit]     ; sn¡‘en¡ ‡¡ta‡e chyb
         inc       word ptr ds:[CitKor2]    ; ‡¡ta‡ korekc¡ 2
         jmp       KorBlok1                 ; dal¨¡ opravy

; ------ n vrat registr–

KorBlok9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorBlok  ENDP

; -----------------------------------------------------------------------------
;     test bloku DS:SI, je-li vadn˜ (DH=‡¡ta‡ vadn˜ch blok–, BX=£schova SI)
; -----------------------------------------------------------------------------

TestBlk  PROC      NEAR

         cmp       byte ptr ds:[si],0
         je        TestBlk1                 ; nen¡ vadn˜
         mov       bx,si                    ; £schova adresy sektoru
         inc       dh                       ; ‡¡ta‡ chyb
TestBlk1:inc       si
         ret

TestBlk  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov n¡ sektoru ES:SI (a p©id n¡ k seznamu sektor–)
; -----------------------------------------------------------------------------

KodSekt  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ ukl dac¡ adresa sektoru

         push      si
         push      es
         mov       es,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektor–

; ------ p©enesen¡ z hlav¡ sektoru

         xor       di,di
         mov       si,offset Zahlavi        ; z hlav¡ sektoru
         mov       cx,10/2                  ; d‚lka z hlav¡ sektoru
         cld
         rep       movsw                    ; p©enesen¡ z hlav¡ sektoru

; ------ p©enesen¡ dat sektoru

         pop       ds                       ; DS <- segment dat sektoru
         pop       si
         mov       cl,9/2                   ; zbytek dat v prvn¡m © dku
         rep       movsw                    ; p©enos zbytku prvn¡ho © dku
         movsb
         mov       dx,9                     ; po‡et zbyl˜ch © dk– dat
KodSekt1:inc       di                       ; p©esko‡en¡ bajtu sou‡tu XOR
         mov       cl,19/2
         rep       movsw                    ; p©enesen¡ jednoho © dku dat
         movsb
         dec       dx                       ; ‡¡ta‡ © dk– dat
         jnz       KodSekt1                 ; p©enesen¡ dal¨¡ho © dku dat

; ------ v˜po‡et kontroln¡ho bajtu © dk– dat XOR

         push      es
         pop       ds                       ; DS <- adresa sektoru
         xor       di,di
         mov       dx,10                    ; po‡et © dk– dat se z hlav¡m
KodSekt2:mov       cl,19                    ; d‚lka jednoho © kdu
         mov       al,0                     ; v˜choz¡ hodnota sou‡tu
KodSekt3:xor       al,ds:[di]
         inc       di
         loop      KodSekt3                 ; dal¨¡ bajt © dku
         stosb                              ; ulo‘en¡ kontroln¡ho bajtu XOR
         dec       dx                       ; ‡¡ta‡ © dk–
         jnz       KodSekt2                 ; v˜po‡et dal¨¡ho © dku dat

; ------ v˜po‡et kontroln¡ho opravn‚ho © dku XOR

         xor       si,si
         mov       dx,20                    ; po‡et sloupc– dat
KodSekt4:mov       cl,10                    ; po‡et © dk– dat
         mov       al,0                     ; v˜zhoz¡ hodnota kontroln¡ho sou‡tu
KodSekt5:xor       al,ds:[si]
         add       si,20                    ; adresa dal¨¡ho © dku dat
         loop      KodSekt5                 ; bajt v dal¨¡m © dku sloupce
         stosb                              ; ulo‘en¡ kontroln¡ho bajtu XOR
         sub       si,10*20-1               ; adresa za‡ tku dal¨¡ho soupce
         dec       dx                       ; ‡¡ta‡ sloupc– dat
         jnz       KodSekt4                 ; v˜po‡et dal¨¡ho sloupce dat

; ------ v˜po‡et kontroln¡ho sou‡tu dat CRC

         xor       si,si                    ; SI <- za‡ tek dat sektoru
         mov       cx,220                   ; velikost bloku dat
         mov       dx,-1
         call      CheckSum                 ; v˜po‡et kontroln¡ho sou‡tu dat
         mov       ds:[di],dx               ; ulo‘en¡ kontroln¡ho sou‡tu dat
         mov       word ptr ds:[di+2],-1    ; synchroniza‡n¡ bajty

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

KodSekt  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov n¡ £vodn¡ho synchroniza‡n¡ho sektoru
; -----------------------------------------------------------------------------

KodSYNU  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ ukl dac¡ adresa sektoru

         mov       es,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektor–
         xor       di,di

; ------ p©enesen¡ z hlav¡ sektoru

         mov       si,offset Zahlavi        ; z hlav¡ sektoru
         mov       cx,10/2                  ; d‚lka z hlav¡ sektoru
         cld
         rep       movsw                    ; p©enesen¡ z hlav¡ sektoru

; ------ korekce polo‘ek v z hlav¡

         mov       byte ptr es:[di-2],255   ; ozna‡en¡ synchroniza‡n¡ho sektoru
         or        byte ptr es:[di-3],b14/HI ; p©¡znak korek‡n¡ho sektoru
         mov       ax,ds:[FileOffs]         ; offset prvn¡ho souboru
         stosw

; ------ vymaz n¡ zbytku sektoru

         mov       ax,-1
         mov       cx,(224-12)/2            ; d‚lka zbytku dat ve slovech
         rep       stosw                    ; vymaz n¡ zbytku sektoru

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

KodSYNU  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov n¡ z vˆre‡n‚ho synchroniza‡n¡ho sektoru
; -----------------------------------------------------------------------------

KodSYNZ  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ ukl dac¡ adresa sektoru

         mov       es,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektor–
         xor       di,di

; ------ p©enesen¡ z hlav¡ sektoru

         mov       si,offset Zahlavi        ; z hlav¡ sektoru
         mov       cx,10/2                  ; d‚lka z hlav¡ sektoru
         cld
         rep       movsw                    ; p©enesen¡ z hlav¡ sektoru

; ------ korekce polo‘ek v z hlav¡

         mov       byte ptr es:[di-2],33    ; ozna‡en¡ synchroniza‡n¡ho sektoru
         or        byte ptr es:[di-3],b14/HI ; p©¡znak korek‡n¡ho sektoru

; ------ vymaz n¡ zbytku sektoru

         mov       ax,-1
         mov       cx,(224-10)/2            ; d‚lka zbytku dat ve slovech
         rep       stosw                    ; vymaz n¡ zbytku sektoru

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

KodSYNZ  ENDP

; -----------------------------------------------------------------------------
;        korekce jednoho sektoru (CY=chyba, BX=‡¡slo sektoru)
; -----------------------------------------------------------------------------

KorSekt  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds

; ------ p©¡prava registr–

         mov       ax,ds:[SektSeg]          ; segment sektoru
         add       word ptr ds:[SektSeg],224/16 ; posun ukazatele sektor–
         mov       ds,ax

; ------ kontrola © dk– sektoru

         cld
         mov       dx,11                    ; po‡et © dk– dat
         xor       cx,cx
         xor       bx,bx                    ; BX <- 0 ‡¡ta‡ vadn˜ch © dk–
         xor       si,si
KorSekt2:mov       cl,20                    ; po‡et bajt– na © dek
         mov       ah,0
KorSekt3:lodsb
         xor       ah,al
         loop      KorSekt3
         jz        KorSekt4                 ; © dek je OK
         inc       bx                       ; ‡¡ta‡ vadn˜ch © dk–
         mov       di,si                    ; adresa konce © dku
KorSekt4:dec       dx                       ; ‡¡ta‡ © dk–
         jnz       KorSekt2                 ; kontrola dal¨¡ho © dku

; ------ test, zda je pr vˆ 1 © dek k opravˆ

         cmp       bl,1                     ; je vadn˜ 1 © dek ?
         ja        KorSekt8                 ; je v¡c vadn˜ch © dk–
         jb        KorSekt7                 ; nen¡ ‘ dn˜ vadn˜ © dek

; ------ korekce vadn‚ho © dku

         test      byte ptr cs:[Param],b0   ; prov d¡ se korekce 1 ?
         jz        KorSekt7                 ; neprov d¡ se korekce 1

         sub       di,20                    ; adresa za‡ tku © dku
         xor       si,si                    ; za‡ tek dat
         mov       dx,20                    ; po‡et sloupc– v matici
KorSekt5:mov       cl,11                    ; po‡et © dk–
         mov       ah,0
KorSekt6:lodsb
         add       si,20-1                  ; adresa dal¨¡ho © dku
         xor       ah,al
         loop      KorSekt6
         xor       ds:[di],ah               ; korekce vadn‚ho bajtu
         inc       di
         sub       si,(11*20)-1
         dec       dx
         jnz       KorSekt5
         inc       word ptr cs:[CitKor1]

; ------ ovˆ©en¡ kontroln¡ho sou‡tu

KorSekt7:mov       dx,-1
         xor       si,si
         mov       cx,220                   ; velikost bloku dat
         call      CheckSum                 ; v˜po‡et kontroln¡ho sou‡tu dat
         cmp       ds:[220],dx              ; kontrola kontroln¡ho sou‡tu dat
         je        KorSekt9

; ------ chyba

KorSekt8:stc                                ; p©¡znak chyby

; ------ ‡¡slo sektoru

KorSekt9:pushf
         mov       bh,0
         mov       bl,ds:[8]                ; aktu ln¡ ‡¡slo sektoru
         test      byte ptr ds:[7],b14/HI   ; je to korek‡n¡ sektor ?
         jz        KorSektA                 ; nen¡ to korek‡n¡ sektor
         mov       bh,1                     ; ‡¡slo korek‡n¡ho sektoru
KorSektA:popf

; ------ n vrat registr–

         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

KorSekt  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ sektoru do bufferu souboru
; -----------------------------------------------------------------------------

DekSekt  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ adresa sektoru

         mov       es,ds:[BuffSeg]          ; segment bufferu soubor–
         mov       cx,ds:[SektSeg]
         add       word ptr ds:[SektSeg],224/16
         mov       ds,cx

; ------ adresa v bufferu soubor–

         mov       ah,0
         mov       al,ds:[8]                ; aktu ln¡ ‡¡slo sektoru
         test      byte ptr ds:[7],b14/HI   ; je to korek‡n¡ sektor ?
         jz        DekSekt1                 ; nen¡ to korek‡n¡ sektor
         mov       ah,1                     ; ‡¡slo korek‡n¡ho sektoru
DekSekt1:cmp       ax,289
         jae       DekSekt8                 ; neplatn‚ ‡¡slo sektoru
         mov       cx,180                   ; d‚lka dat
         mul       cx                       ; offset sektoru
         xchg      ax,di                    ; ukl dac¡ adresa sektoru v bufferu

; ------ p©enos dat sektoru

         cld
         mov       si,10
         mov       cx,9/2
         rep       movsw
         movsb

         mov       dx,9
DekSekt2:inc       si
         mov       cl,19/2
         rep       movsw
         movsb
         dec       dx
         jnz       DekSekt2

; ------ n vrat registr–

DekSekt8:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

DekSekt  ENDP

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
;        DX=vstupn¡ hodnota kontroln¡ho sou‡tu
; VSTUP:DX=v˜stupn¡ hodnota kontroln¡ho sou‡tu
; -----------------------------------------------------------------------------

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di

         jcxz      CheckSm2                 ; nen¡ ‘ dn˜ bajt
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       CheckSm1                 ; dal¨¡ bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSum ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                        Obsluha vys¡l n¡ a p©¡jmu dat
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        inicializace portu na vys¡l n¡
; -----------------------------------------------------------------------------

InitVys  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa portu

         push      ds
         mov       bx,ds:[Port]             ; ‡¡slo portu COMn
         shl       bx,1
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[bx+400h]          ; adresa portu
         pop       ds
         or        dx,dx
         jnz       InitVys1
         stc
         jmp       InitVys8                 ; neplatn  adresa portu COM
InitVys1:mov       ds:[AdrPort],dx          ; adresa portu COM

; ------ zru¨en¡ po‘adavk– od portu

         cli
         in        al,dx                    ; zru¨en¡ p©ij¡mac¡ho bufferu
         inc       dx                       ; 1: registr povolen¡ p©eru¨en¡
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; z kaz v¨ech p©eru¨en¡
         add       dx,3                     ; 4: ©¡dic¡ registr modemu
         out       dx,al                    ; z kaz p©eru¨en¡ a sign l– modemu
         inc       dx                       ; 5: stavov˜ registr linky
         in        al,dx                    ; zru¨en¡ po‘adavk– od linky
         inc       dx                       ; 6: stavov˜ registr modemu
         in        al,dx                    ; zru¨en¡ po‘adavk– modemu

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es

; ------ £schova adresy INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es

; ------ instalace obsluhy INT 08h

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

; ------ £schova p–vodn¡ho p©eru¨en¡ COM

         call      GetICom                  ; poskytnut¡ ‡¡sla p©eru¨en¡ COM
         push      ax
         mov       ah,35h
         int       21h
         mov       word ptr ds:[OldComm],bx
         mov       word ptr ds:[OldComm+2],es
         pop       ax

; ------ instalace obsluhy p©eru¨en¡ COM

         push      ax
         mov       ah,25h
         mov       dx,offset IntVys         ; adresa obsluhy vys¡la‡e
         int       21h                      ; instalace obsluhy vys¡la‡e
         pop       ax

; ------ inicializace portu COM

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         add       dx,3                     ; 3: ©¡dic¡ registr linky
         mov       al,10000011b
         out       dx,al                    ; DLAB, 8 bit– bez parity, 1 STOP b.
         inc       dx                       ; 4: ©¡dic¡ registr modemu
         mov       al,1010b                 ; OUT2 a RTS
         out       dx,al                    ; ©¡dic¡ registr modemu
         sub       dx,4                     ; 0: registr dˆli‡ky LOW
         mov       al,1
         out       dx,al                    ; dˆlic¡ pomˆr 1
         inc       dx                       ; 1: registr dˆli‡ky HIGH
         mov       al,0
         out       dx,al
         inc       dx
         inc       dx                       ; 3: ©¡dic¡ registr linky
         mov       al,00000011b             ; 8 bit– bez parity, 1 STOP bit
         out       dx,al
         dec       dx                       ; 2:
         dec       dx                       ; 1:
         mov       al,0010b                 ; p©eru¨en¡ po vysl n¡ znaku
         out       dx,al

; ------ nastaven¡ registru p©eru¨en¡

         in        al,[21h]
         mov       ds:[OldInt],al           ; £schova masky p©eru¨en¡
         mov       al,ah
         out       [21h],al                 ; povoleno p©eru¨en¡
         clc

; ------ n vrat registr–

InitVys8:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitVys  ENDP

; -----------------------------------------------------------------------------
;        inicializace portu na p©¡jem
; -----------------------------------------------------------------------------

InitPri  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa portu

         push      ds
         mov       bx,ds:[Port]             ; ‡¡slo portu COMn
         shl       bx,1
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[bx+400h]          ; adresa portu
         pop       ds
         or        dx,dx
         jnz       InitPri1
         stc
         jmp       InitPri8                 ; neplatn  adresa portu COM
InitPri1:mov       ds:[AdrPort],dx          ; adresa portu COM

; ------ zru¨en¡ po‘adavk– od portu

         cli
         in        al,dx                    ; zru¨en¡ p©ij¡mac¡ho bufferu
         inc       dx                       ; 1: registr povolen¡ p©eru¨en¡
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; z kaz v¨ech p©eru¨en¡
         add       dx,3                     ; 4: ©¡dic¡ registr modemu
         out       dx,al                    ; z kaz p©eru¨en¡ a sign l– modemu
         inc       dx                       ; 5: stavov˜ registr linky
         in        al,dx                    ; zru¨en¡ po‘adavk– od linky
         inc       dx                       ; 6: stavov˜ registr modemu
         in        al,dx                    ; zru¨en¡ po‘adavk– modemu

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es

; ------ £schova adresy INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es

; ------ instalace obsluhy INT 08h

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

; ------ £schova p–vodn¡ho p©eru¨en¡ COM

         call      GetICom                  ; poskytnut¡ ‡¡sla p©eru¨en¡ COM
         push      ax
         mov       ah,35h
         int       21h
         mov       word ptr ds:[OldComm],bx
         mov       word ptr ds:[OldComm+2],es
         pop       ax

; ------ instalace obsluhy p©eru¨en¡ COM

         push      ax
         mov       ah,25h
         mov       dx,offset IntPri         ; adresa obsluhy p©ij¡ma‡e
         int       21h                      ; instalace obsluhy p©ij¡ma‡e
         pop       ax

; ------ inicializace portu COM

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         add       dx,3                     ; 3: ©¡dic¡ registr linky
         mov       al,10000011b
         out       dx,al                    ; DLAB, 8 bit– bez parity, 1 STOP b.
         inc       dx                       ; 4: ©¡dic¡ registr modemu
         mov       al,1010b                 ; OUT2 a RTS
         out       dx,al                    ; ©¡dic¡ registr modemu
         sub       dx,4                     ; 0: registr dˆli‡ky LOW
         mov       al,1
         out       dx,al                    ; dˆlic¡ pomˆr 1
         inc       dx                       ; 1: registr dˆli‡ky HIGH
         mov       al,0
         out       dx,al
         inc       dx
         inc       dx                       ; 3: ©¡dic¡ registr linky
         mov       al,00000011b             ; 8 bit– bez parity, 1 STOP bit
         out       dx,al
         dec       dx                       ; 2:
         dec       dx                       ; 1:
         mov       al,0101b                 ; p©eru¨en¡ p©i p©¡jmu znaku
         out       dx,al

; ------ nastaven¡ registru p©eru¨en¡

         in        al,[21h]
         mov       ds:[OldInt],al           ; £schova masky p©eru¨en¡
         mov       al,ah
         out       [21h],al                 ; povoleno p©eru¨en¡
         clc

; ------ n vrat registr–

InitPri8:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitPri  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ ‡¡sla p©eru¨en¡ (-> AL) a masky p©eru¨en¡ COM (-> AH)
; -----------------------------------------------------------------------------

GetICom  PROC      NEAR

         mov       ax,(NOT b4+b1+b0)*HI + 0ch ; COM1 a COM3
         test      byte ptr ds:[Port],b0      ; je COM1 nebo COM3 ?
         jz        GetICom2                   ; je COM1 nebo COM3
         mov       ax,(NOT b3+b1+b0)*HI + 0bh ; COM2 a COM4
GetICom2:ret

GetICom  ENDP

; -----------------------------------------------------------------------------
;        p©eru¨en¡ p©i vys¡l n¡ sektoru
; -----------------------------------------------------------------------------

IntVys   PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      ds
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       ds

; ------ prvn¡ ‡ten¡ stavov‚ho registru p©eru¨en¡

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         mov       es,ds:[SektSeg]
         inc       dx
         inc       dx
         in        al,dx                    ; stavov˜ registr p©eru¨en¡
         jmp       short IntVys2

; ------ test, zda je dal¨¡ p©eru¨en¡ od portu

IntVys1: mov       dx,ds:[AdrPort]          ; adresa portu COM
         inc       dx
         inc       dx
         in        al,dx                    ; stavov˜ registr p©eru¨en¡
         test      al,1                     ; je dal¨¡ p©eru¨en¡ ?
         jz        IntVys2
         jmp       IntVys9                  ; nen¡ dal¨¡ p©eru¨en¡

; ------ test, zda je p©eru¨en¡ p©i vys¡l n¡

IntVys2: cmp       al,2                     ; p©eru¨en¡ p©i vys¡l n¡ ?
         jne       IntVys8                  ; nen¡ p©eru¨en¡ p©i vys¡l n¡

         dec       dx
         dec       dx

; ------ zv˜¨en¡ ‡¡ta‡e bajt– sektoru

         mov       ah,ds:[CitByte]          ; ‡¡ta‡ bajt– sektoru
         inc       ah
         mov       ds:[CitByte],ah          ; nov˜ ‡¡ta‡ bajt– sektoru

; ------ test, zda jsou data sektoru

         cmp       ah,224+1                 ; jsou data sektoru ?
         jae       IntVys3                  ; nejsou data

; ------ vysl n¡ datov‚ho bajtu

         mov       bx,ds:[SektUkaz]         ; ukazatel dat sektoru
         mov       al,es:[bx]               ; bajt sektoru k vysl n¡
         inc       bx
         mov       ds:[SektUkaz],bx         ; nov˜ ukazatel dat sektoru
         jmp       short IntVys7

; ------ za‡ tek synchronizace

IntVys3: jne       IntVys4                  ; nen¡ za‡ tek synchronizace
         add       dx,4
         mov       al,1000b
         out       dx,al
         sub       dx,4

; ------ konec synchronizace

IntVys4: cmp       ah,226+1
         jne       IntVys5
         add       dx,4
         mov       al,1010b
         out       dx,al
         sub       dx,4

; ------ prvn¡ startovac¡ bajt

IntVys5: cmp       ah,228+1
         jb        IntVys6
         mov       al,2                     ; prvn¡ startovac¡ bajt
         je        IntVys7

; ------ druh˜ startovac¡ bajt

         cmp       byte ptr es:[8],33       ; je z vˆre‡n˜ synchr. sektor ?
         jne       IntVys52
         test      byte ptr es:[7],b14/HI   ; korek‡n¡ sektor ?
         jnz       IntVys57                 ; je z vˆre‡n˜ sychr. sektor

IntVys52:mov       word ptr ds:[SektUkaz],0
         cmp       word ptr ds:[CitSynch],0 ; je synchroniza‡n¡ sektor ?
         je        IntVys55                 ; nen¡ synchroniza‡n¡ sektor
         dec       word ptr ds:[CitSynch]   ; sn¡‘en¡ ‡¡ta‡e sektor–
         jmp       short IntVys56
IntVys55:add       word ptr ds:[SektSeg],224/16
         mov       es,ds:[SektSeg]
IntVys57:inc       word ptr ds:[CitSekt]    ; zv˜¨en¡ ‡¡ta‡e sektor–
IntVys56:mov       byte ptr ds:[CitByte],0  ; inicializace ‡¡ta‡e
         mov       al,0e5h                  ; druh˜ startovac¡ bajt
         jmp       short IntVys7

; ------ vysl n¡ datov‚ho bajtu

IntVys6: mov       al,0ffh
IntVys7: out       dx,al
         inc       dx
         inc       dx

; ------ zru¨en¡ stavov‚ho registru linky

IntVys8: add       dx,3                     ; 5: stavov˜ registr linky
         in        al,dx                    ; zru¨en¡ po‘adavku od reg. linky
         jmp       IntVys1            ; dal¨¡ test

; ------ n vrat registr–

IntVys9: mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         pop       es
         pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

IntVys   ENDP

; -----------------------------------------------------------------------------
;        p©eru¨en¡ p©i p©¡jmu sektoru
; -----------------------------------------------------------------------------

IntPri   PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      ds
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       ds

; ------ prvn¡ ‡ten¡ stavov‚ho registru p©eru¨en¡

         mov       dx,ds:[AdrPort]          ; adresa portu COM
         mov       es,ds:[SektSeg]
         inc       dx
         inc       dx
         in        al,dx                    ; stavov˜ registr p©eru¨en¡
         jmp       short IntPri2

; ------ test, zda je dal¨¡ p©eru¨en¡ od portu

IntPri1: mov       dx,ds:[AdrPort]          ; adresa portu COM
         inc       dx
         inc       dx
         in        al,dx                    ; stavov˜ registr p©eru¨en¡
         test      al,1                     ; je dal¨¡ p©eru¨en¡ ?
         jz        IntPri2
         jmp       IntPri9                  ; nen¡ dal¨¡ p©eru¨en¡

; ------ test, zda je p©eru¨en¡ p©i p©¡jmu

IntPri2: cmp       al,4                     ; p©eru¨en¡ p©i p©¡jmu ?
         jne       IntPri8                  ; nen¡ p©eru¨en¡ p©i p©¡jmu

; ------ p©¡jem datov‚ho bajtu

         dec       dx
         dec       dx
         in        al,dx                    ; p©¡jem bajtu
         inc       dx
         inc       dx

; ------ ‡¡ta‡ bajt– sektoru

         mov       ah,ds:[CitByte]          ; ‡¡ta‡ bajt– sektoru
         cmp       ah,222                   ; je platn˜ bajt ?
         jae       IntPri3                  ; nen¡ platn˜ bajt

; ------ p©¡jem platn‚ho bajtu sektoru

IntPri25:mov       bx,ds:[SektUkaz]         ; ukazatel dat sektoru
         mov       es:[bx],al               ; ulo‘en¡ p©ijat‚ho bajtu
         inc       bx
         mov       ds:[SektUkaz],bx         ; nov˜ ukazatel dat sektoru
         jmp       short IntPri6

; ------ p©¡jem startovac¡ho bajtu

IntPri3: cmp       ax,0fe02h                ; prvn¡ startovac¡ bajt ?
         je        IntPri6                  ; prvn¡ startovac¡ bajt
         cmp       ax,0ffe5h                ; druh˜ startovac¡ bajt ?
         je        IntPri6                  ; druh˜ startovac¡ bajt

; ------ 2 synchroniza‡n¡ bajty

         cmp       al,0ffh                  ; synchronizace ?
         jne       IntPri7                  ; nen¡ synchronizace
         cmp       ah,-2                    ; je posledn¡ bajt ?
         je        IntPri61                 ; je posledn¡ bajt - nezv˜¨¡ se

; ------ zv˜¨en¡ ‡¡ta‡e bajt– sektoru

IntPri6: inc       ah
IntPri61:mov       ds:[CitByte],ah          ; nov˜ ‡¡ta‡ bajt– sektoru
         cmp       ah,222                   ; jsou ji‘ v¨echny bajty sektoru ?
         jne       IntPri8                  ; nejsou je¨tˆ v¨echny bajty sektoru
         cmp       byte ptr ds:[CitSynch],0 ; ‡ek  se na synchroniza‡n¡ sektor ?
         je        IntPri62                 ; ne‡ek  se na synchronizaci

         cmp       byte ptr es:[8],255      ; je sektor 255 ?
         jne       IntPri66                 ; nen¡ sektor 255
         test      byte ptr es:[7],b14/HI   ; je synchroniza‡n¡ sektor ?
         jz        IntPri66                 ; nen¡ synchroniza‡n¡ sektor
         dec       byte ptr ds:[CitSynch]   ; sn¡‘en¡ ‡¡ta‡e synch. sektor–
         jmp       short IntPri66

IntPri62:cmp       byte ptr es:[8],255      ; je sektor 255 ?
         jne       IntPri64                 ; nen¡ sektor 255
         test      byte ptr es:[7],b14/HI   ; je synchroniza‡n¡ sektor ?
         jnz       IntPri66                 ; je synchroniza‡n¡ sektor

IntPri64:inc       word ptr ds:[CitSekt]    ; zv˜¨en¡ ‡¡ta‡e sektor–
         add       word ptr ds:[SektSeg],224/16
         mov       es,ds:[SektSeg]
IntPri66:mov       word ptr ds:[SektUkaz],0 ; oprava ukazatele sektoru
IntPri7: mov       byte ptr ds:[CitByte],-4 ; ‡¡ta‡ startovac¡ch bajt–

; ------ zru¨en¡ stavov‚ho registru linky

IntPri8: add       dx,3                     ; 5: stavov˜ registr linky
         in        al,dx                    ; zru¨en¡ po‘adavku od reg. linky
         jmp       IntPri1                  ; dal¨¡ test

; ------ n vrat registr–

IntPri9: mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         pop       es
         pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

IntPri   ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ port–
; -----------------------------------------------------------------------------

DeInit   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ n vrat masky p©eru¨en¡

         cli
         mov       al,ds:[OldInt]           ; p–vodn¡ maska p©eru¨en¡
         out       [21h],al                 ; n vrat masky p©eru¨en¡

; ------ z kaz p©eru¨en¡ od portu

         mov       dx,ds:[AdrPort]          ; 0: adresa portu
         in        al,dx                    ; zru¨en¡ p©ijat‚ho znaku
         inc       dx                       ; 1: ©¡dic¡ registr p©eru¨en¡
         xor       al,al                    ; v¨echna p©eru¨en¡ zak z na
         out       dx,al                    ; z kaz v¨ech p©eru¨en¡
         inc       dx                       ; 2: stavov˜ registr p©eru¨en¡
         in        al,dx                    ; zru¨en¡ stavov‚ho registru p©eru¨.
         inc       dx                       ; 3: ©¡dic¡ registr linky
         inc       dx                       ; 4: ©¡dic¡ registr modemu
         xor       al,al                    ; v¨echny sign ly vypnuty
         out       dx,al                    ; vypnut¡ v¨ech sign l– modemu
         inc       dx                       ; 5: stavov˜ registr linky
         in        al,dx                    ; zru¨en¡ stavov‚ho registru linky
         inc       dx                       ; 6: stavov˜ registr modemu
         in        al,dx                    ; zru¨en¡ stavov‚ho registru modemu

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

         mov       al,20h
         out       [20h],al

; ------ n vrat obsluhy p©eru¨en¡ od portu COM

         call      GetICom                  ; poskytnut¡ p©eru¨en¡ COM
         mov       ah,25h
         push      ds
         lds       dx,ds:[OldComm]          ; p–vodn¡ adresa INT COM
         int       21h                      ; n vrat p–vodn¡ adresy portu
         pop       ds

; ------ n vrat obsluhy p©eru¨en¡ INT 08h

         push      ds
         lds       dx,ds:[Old08]            ; p–vodn¡ adresa INT 08h
         mov       ax,2508h
         int       21h
         pop       ds

; ------ n vrat obsluhy p©eru¨en¡ INT 09h

         push      ds
         lds       dx,ds:[Old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h
         pop       ds
         sti

; ------ inicializace hodin

         call      InitClk                  ; n vrat nastaven¡ hodin

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

DeInit   ENDP

; -----------------------------------------------------------------------------
;        inicializace nastaven¡ hodin (AT)
; -----------------------------------------------------------------------------

InitClk  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ ‡ten¡ hodin syst‚mov‚ho ‡asu (AT)

         mov       dl,8ah                   ; p©ednastaven¡ na nesmysl
         mov       ah,2
         int       1ah                      ; ‡ten¡ hodin
         cmp       dl,1                     ; p©ete‡en¡ p©es p–lnoc ?
         ja        InitClk8                 ; hodiny neplat¡

; ------ n vrat p©¡znaku p©ete‡en¡ p©es p–lnoc

         jne       InitClk2                 ; nen¡ p©ete‡en¡ p©es p–lnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n vrat p©¡znaku p©ete‡en¡ p–lnoci

; ------ konverze z BCD form tu na bin rn¡

InitClk2:mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       dh,al

; ------ nastaven¡ ‡asu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven¡ syst‚mov‚ho ‡asu

; ------ n vrat registr–

InitClk8:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitClk  ENDP

; -----------------------------------------------------------------------------
;        Konverze ‡¡sla z BCD tvaru na bin rn¡
; -----------------------------------------------------------------------------

BcdBin   PROC      NEAR

         push      cx
         mov       ch,al
         and       ch,0fh
         and       al,0f0h
         mov       cl,4
         shr       al,cl
         mov       cl,10
         mul       cl
         add       al,ch
         pop       cx
         ret

BcdBin   ENDP

; -----------------------------------------------------------------------------
;        obsluha hodin INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         push      ax
         mov       al,20h
         out       [20h],al
         sti
         inc       word ptr cs:[Citac08]    ; posun ‡¡ta‡e hodin
         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha kl vesnice INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registr–

         push      ax

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         sti                                ; povolen¡ p©eru¨en¡

         push      cx

; ------ uzam‡en¡ kl vesnice

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl n¡ povelu-uzam‡en¡ kl vesnice

; ------ ‡ten¡ k¢du kl vesy

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         in        al,[60h]

; ------ test, zda je p©eru¨en¡ ESC

         cmp       al,1                     ; je stisk kl vesy ESC ?
         jne       Int099                   ; nen¡ kl vesa ESC
         mov       byte ptr cs:[KeyBreak],1 ; p©¡znak p©eru¨en¡ kl vesou BREAK

; ------ uvolnˆn¡ kl vesnice

Int099:  call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl n¡ povelu-uvolnˆn¡ kl vesnice

; ------ n vrat registr–

         pop       cx
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost kl vesnice
; -----------------------------------------------------------------------------

Cekej09  PROC      NEAR

         mov       cx,5000
Cekej091:in        al,[64h]
         test      al,b1
         loopnz    Cekej091
         ret

Cekej09  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                     data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ parametry pro komunika‡n¡ port

Port     dw        0                        ; ‡¡slo datov‚ho portu
AdrPort  dw        3f8h                     ; adresa portu COM
OldComm  dd        0                        ; p–vodn¡ adresa komunika‡n¡ho portu
Old08    dd        0                        ; p–vodn¡ adresa INT 08h
Old09    dd        0                        ; p–vodn¡ adresa INT 09h
OldInt   db        0                        ; p–vodn¡ registr p©eru¨en¡

; ------ ukazatel sektor–

VysDBlok dw        0                        ; po‡et vys¡lan˜ch datov˜ch blok–
PriDBlok dw        0                        ; po‡et p©ij¡man˜ch datov˜ch blok–
MaxDBlok dw        0                        ; maxim ln¡ po‡et datov˜ch blok–
SektBSeg dw        0                        ; adresa za‡ tku bufferu sektor–
SektESeg dw        0                        ; adresa konce bufferu sektor–
SektMax  dw        0                        ; maxim ln¡ po‡et sektor– v bufferu
SektSeg  dw        0                        ; segment aktu ln¡ho bufferu sektor–
SektUkaz dw        0                        ; ukazatel dat v aktu ln¡m sektoru
CitSekt  dw        0                        ; ‡¡ta‡ po‡tu sektor–

CitSynch dw        0                        ; ‡¡ta‡ synchroniza‡n¡ch sektor–
CitByte  db        0                        ; ‡¡ta‡ bajt– sektoru

Soubor   db        'POKUS1',0
Soubor2  db        'POKUS2',0

KeyBreak db        0                        ; p©¡znak p©eru¨en¡ z kl vesnice
Citac08  dw        0                        ; ‡¡ta‡ hodin INT 08h

; ------ z hlav¡ sektoru (10 bajt–)

         EVEN
Zahlavi  label     byte
TimeBeg  dd        0                        ; absolutn¡ ‡as za‡ tku nahr vky
TimeDel  dw        0                        ; d‚lka cel‚ nahr vky (sek.)
AktBlok  dw        0                        ; aktu ln¡ ‡¡slo bloku
AktSekt  db        0                        ; ‡¡slo aktu ln¡ho sektoru
InfBlok  db        0                        ; informace o organizaci blok–

FileOffs dw        -1                       ; offset prvn¡ho souboru v bloku

; ------ datov˜ buffer soubor– (velikost pro 1 datov˜ blok = 289*180 B)

BuffSeg  dw        0                        ; segment bufferu soubor–
BuffNum  dw        0                        ; po‡et bajt– v bufferu soubor–

; ------ mapa vadn˜ch sektor–

ErrMap   db        289 dup(-1)              ; 0=sektor je OK, -1=vadn˜ sektor
ErrCit   dw        289                      ; ‡¡ta‡ vadn˜ch sektor–

Param    db        0                        ; parametry
                                            ;  bit 0: 1=prov d¡ se korekce 1
                                            ;  bit 1: 1=prov d¡ se korekce 2

; ------ texty - mohou se po startu p©epsat z sobn¡kem

KorTxt1  db        'opravy bajtu = $'
KorTxt2  db        '     opravy sektoru = $'
KorTxt3  db        '     chyby = $'
KorTxt4  db        13,10,'$'

CitKor1  dw        0                        ; ‡¡ta‡ korekc¡ 1
CitKor2  dw        0                        ; ‡¡ta‡ korekc¡ 2
CitChyb  dw        0                        ; ‡¡ta‡ neopraviteln˜ch chyb


;UvTxt    db        'STREAMER V1.0 - Video Streamer; (c) Miroslav Nemecek',13,10,'$'
MemTxt   db        'CHYBA - nedostatek pameti ke spusteni programu !',13,10,'$'

         dw        200h dup(?)
Zasob    label     word                     ; konec z sobn¡ku

Code     ENDS

         END       Start


; *****************************************************************************
;
;                  Emul†tor diskety 360 KB v pamàti
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code

         dd        -1                       ; adresa n†sleduj°c°ho driveru
         dw        0800h                    ; atributy
         dw        offset Strateg           ; offset rutiny strategie
         dw        offset Prerus            ; offset rutiny p©eru®en°
PocDisku db        1                        ; poáet obsluhovanòch diskñ
         db        7 dup(0)                 ; rezervov†no

         db        'RAM360K V 1.00'         ; identifikace RAM-DISKu

format   db        0                        ; form†t diskety

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

AdrZahl  dd        0                        ; adresa z†hlav° za©°zen°



tabbpb   dw        offset bpb

bpb      label     byte                   ;* blok parametrñ BIOS BPB disku



SizeSekt dw        512                      ; 00h: poáet bajtñ na sektor
SizeBlok db        1                        ; 02h: poáet sektorñ na alok. blok
RezSekt  dw        1                        ; 03h: zav†dàc° a rezerv. sektory
NumFat   db        2                        ; 05h: poáet alokaán°ch tabulek FAT
MaxRoot  dw        4*16                     ; 06h: max. poáet pol. z†kl. adres.
MaxSekt  dw        720                      ; 08h: celkovò poáet sektorñ disku
Descript db        0fdh                     ; 0ah: popisovaá mÇdia
SektFat  dw        3                        ; 0bh: poáet sektorñ v jednÇ FAT
                                          ;* od DOS 3.00
SektTrck dw        9                        ; 0dh: poáet sektorñ na stopu
NumHead  dw        2                        ; 0fh: poáet hlav
HidSekt  dd        0                        ; 11h: poáet skrytòch sektorñ

; 1 BOOT
; 2*3 FAT
; 4 ROOT
; 709 data
; ----------
; 720 celkem

; -----------------------------------------------------------------------------
;        Äten° sektorñ z RAM-DISKu
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=adresa bufferu
;        DX=poá†teán° sektor ke áten°
;        CX=poáet sektorñ ke áten°
; -----------------------------------------------------------------------------
; VùSTUP:CY=chyba operace
;        CX=poáet zbylòch sektorñ
; -----------------------------------------------------------------------------

PUBLIC   ReadSekt
ReadSekt PROC      NEAR

         push      dx
         push      si
         push      di

                                          ;* vòpoáet zdrojovÇ adresy
         mov       ax,dx                    ; poá†teán° sektor
         call      GetExt                   ; vòpoáet zdrojovÇ adresy
         mov       si,ax                    ; nië®° slovo zdrojovÇ adresy

                                          ;* vòpoáet c°lovÇ adresy
         xor       dh,dh
         mov       ax,ds                    ; segment c°lovÇ adresy
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p©enos do vy®®°ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p©enos do vy®®°ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p©enos do vy®®°ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p©enos do vy®®°ho bajtu
         add       di,ax                    ; p©iáten° p©enosu ze segmentu
         adc       dh,0                     ; p©enos do vy®®°ho bajtu

         call      BlokMove                 ; áten° sektorñ

         pop       di
         pop       si
         pop       dx
         ret

ReadSekt ENDP

; -----------------------------------------------------------------------------
;        Z†pis sektorñ do RAM-DISKu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa bufferu
;        DX=poá†teán° sektor k uloëen°
;        CX=poáet sektorñ k uloëen°
; -----------------------------------------------------------------------------
; VùSTUP:CY=chyba operace
;        CX=poáet zbylòch sektorñ
; -----------------------------------------------------------------------------

PUBLIC   WritSekt
WritSekt PROC      NEAR

         push      dx
         push      si
         push      di

                                          ;* vòpoáet c°lovÇ adresy
         mov       ax,dx                    ; poá†teán° sektor
         call      GetExt                   ; vòpoáet c°lovÇ adresy
         mov       di,ax                    ; nië®° slovo c°lovÇ adresy
         mov       dh,dl                    ; vy®®° bajt c°lovÇ adresy

                                          ;* vòpoáet zdrojovÇ adresy
         xor       dl,dl
         mov       ax,ds                    ; segment zdrojovÇ adresy
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p©enos do vy®®°ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p©enos do vy®®°ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p©enos do vy®®°ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p©enos do vy®®°ho bajtu
         add       si,ax                    ; p©iáten° p©enosu ze segmentu
         adc       dl,0                     ; p©enos do vy®®°ho bajtu

         call      BlokMove                 ; z†pis sektorñ

         pop       di
         pop       si
         pop       dx
         ret

WritSekt ENDP

; -----------------------------------------------------------------------------
;        Vòpoáet adresy v roz®i©uj°c° pamàti
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo sektoru
; VùSTUP:DL:AX=adresa v roz®i©uj°c° pamàti
; -----------------------------------------------------------------------------

PUBLIC   GetExt
GetExt   PROC      NEAR

         push      cx
         push      dx
         mov       cx,512                   ; dÇlka sektoru
         mul       cx                       ; p©epoáet sektorñ na bajty
         mov       cl,dl                    ; vy®®° bajt adresy
         pop       dx
         mov       dl,cl                    ; vy®®° bajt adresy
         pop       cx
         add       ax,cs:[TopMem]           ; p©iáten° poá†tku pamàti
         adc       dl,byte ptr cs:[TopMem+2]; vy®®° bajt adresy
         ret

GetExt   ENDP

; -----------------------------------------------------------------------------
;        Tabulka popisovaáñ pro p©esun dat
; -----------------------------------------------------------------------------

GDT      label     word

                                          ;* pr†zdnò popisovaá
GDT01    dw        0                        ; 0: omezen° segmentu
GDT02    dw        0                        ; 2: nië®° slovo adresy
GDT03    db        0                        ; 4: vy®®° bajt adresy
GDT04    db        0                        ; 5: bajt p©°stupovòch pr†v
GDT05    dw        0                        ; 6: (rezervov†no)

                                          ;* popisovaá tabulky GDT
GDT11    dw        0                        ; 0: omezen° segmentu
GDT12    dw        0                        ; 2: nië®° slovo adresy
GDT13    db        0                        ; 4: vy®®° bajt adresy
GDT14    db        0                        ; 5: bajt p©°stupovòch pr†v
GDT15    dw        0                        ; 6: (rezervov†no)

                                          ;* popisovaá zdrojovÇho bloku dat
GDT21    dw        0                        ; 0: omezen° segmentu
GDT22    dw        0                        ; 2: nië®° slovo adresy
GDT23    db        0                        ; 4: vy®®° bajt adresy
GDT24    db        93h                      ; 5: bajt p©°stupovòch pr†v
GDT25    dw        0                        ; 6: (rezervov†no)

                                          ;* popisovaá c°lovÇho bloku dat
GDT31    dw        0                        ; 0: omezen° segmentu
GDT32    dw        0                        ; 2: nië®° slovo adresy
GDT33    db        0                        ; 4: vy®®° bajt adresy
GDT34    db        93h                      ; 5: bajt p©°stupovòch pr†v
GDT35    dw        0                        ; 6: (rezervov†no)

                                          ;* popisovaá program. segmentu BIOS
GDT41    dw        0                        ; 0: omezen° segmentu
GDT42    dw        0                        ; 2: nië®° slovo adresy
GDT43    db        0                        ; 4: vy®®° bajt adresy
GDT44    db        0                        ; 5: bajt p©°stupovòch pr†v
GDT45    dw        0                        ; 6: (rezervov†no)

                                          ;* popisovaá z†sobn°kovÇho segmentu
GDT51    dw        0                        ; 0: omezen° segmentu
GDT52    dw        0                        ; 2: nië®° slovo adresy
GDT53    db        0                        ; 4: vy®®° bajt adresy
GDT54    db        0                        ; 5: bajt p©°stupovòch pr†v
GDT55    dw        0                        ; 6: (rezervov†no)

GDT0     label     word                     ; konec tabulky popisovaáñ

; -----------------------------------------------------------------------------
;        P©esun bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DL:SI=zdrojov† adresa
;        DH:DI=c°lov† adresa
;        CX=poáet sektorñ k p©enosu
; VùSTUP:CY=chyba operace
;        DL:SI=zdrojov† adresa (nov† hodnota)
;        DH:DI=c°lov† adresa (nov† hodnota)
;        CX=poáet zbylòch sektorñ
; -----------------------------------------------------------------------------

PUBLIC   BlokMove
BlokMove PROC      NEAR

         clc
         jcxz      BlokMov9                 ; nen° ë†dnò sektor k p©enosu

                                          ;* omezen° poátu sektorñ
         mov       ax,127                   ; maxim†ln° poáet sektorñ k p©enosu
         cmp       ax,cx                    ; je p©°li® velkò poáet sektorñ ?
         jb        BlokMov1                 ; velkò poáet sektorñ - omezen°
         mov       ax,cx                    ; poëadovanò poáet sektorñ
BlokMov1:push      cx                       ; poáet poëadovanòch sektorñ

                                          ;* p©evod sektorñ na bajty
         xchg      ah,al                    ; sektory * 256
         add       ax,ax                    ; poáet sektorñ * 512

                                          ;* popisovaá zdrojovÇho bloku
         mov       cs:[GDT21],ax            ; omezen° zdrojovÇho bloku
         mov       cs:[GDT22],si            ; nië®° slovo zdrojovÇ adresy
         mov       cs:[GDT23],dl            ; vy®®° bajt zdrojovÇ adresy

                                          ;* popisovaá c°lovÇho bloku
         mov       cs:[GDT31],ax            ; omezen° c°lovÇho bloku
         mov       cs:[GDT32],di            ; nië®° slovo c°lovÇ adresy
         mov       cs:[GDT33],dh            ; vy®®° bajt c°lovÇ adresy

                                          ;* £schova registrñ
         push      ax                       ; £schova p©en†®enÇho poátu bajtñ
         push      dx
         push      si
         push      di
         push      es

                                          ;* p©enesen° bloku dat
         mov       cx,ax                    ; poáet bajtñ k p©esunu
         shr       cx,1                     ; poáet slov k p©enosu
         push      cs
         pop       es                       ; ES <- segment tabulky GDT
         mov       si,offset GDT            ; tabulka popisovaáñ GDT
         mov       ah,87h
         clc                                ; p©ednastaven° p©°znaku NC
         int       15h                      ; p©enos dat v chr†nànÇm m¢du

                                          ;* n†vrat obsahu registrñ
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx                       ; n†vrat p©en†®enÇho poátu bajtñ

                                          ;* test vòsledku operace
         jc        BlokMov7                 ; chyba operace
         or        ah,ah                    ; byla operace £spà®n† ?
         stc                                ; p©°znak chyby operace
         jnz       BlokMov7                 ; byla chyba operace

                                          ;* zvò®en° c°lovÇ a zdrojovÇ adresy
         add       si,cx                    ; zvò®en° zdrojovÇ adresy
         adc       dl,0                     ; p©enos do vy®®°ho bajtu
         add       di,cx                    ; zvò®en° c°lovÇ adresy
         adc       dh,0                     ; p©enos do vy®®°ho bajtu
         clc                                ; p©°znak - operace OK

BlokMov7:pop       cx                       ; n†vrat poëadovanÇho poátu sektorñ
         jc        BlokMov9                 ; byla chyba operace
         sub       cx,127                   ; odeáten° max. poátu sektorñ
         jnc       BlokMov8                 ; nebylo p©eteáen° poátu
         xor       cx,cx                    ; nezbyl ë†dnò sektor
BlokMov8:jmp       short BlokMove           ; p©enos dal®°ho bloku dat
BlokMov9:ret

BlokMove ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 15h
; -----------------------------------------------------------------------------

FreeMem  dw        0                        ; poáet zbylÇ volnÇ pamàti
TopMem   dw        0                        ; poá†teán° adresa v ext. pamàti
         db        0                        ; poá†t. adresa - vy®®° bajt
Old15    dd        0                        ; pñvodn° adresa obsluhy INT 15h

Int15    PROC      FAR

         pushf
         cmp       ah,88h                   ; je dotaz na velikost pamàti ?
         jne       Int151                   ; nen° dotaz na velikost pamàti
         popf
         mov       ax,cs:[FreeMem]          ; velikost roz®i©uj°c° pamàti
         iret

Int151:  popf
         jmp       dword ptr cs:[old15]     ; pokraáov†n° v pñvodn° obsluze

Int15    ENDP

; -----------------------------------------------------------------------------
;        Obsluha rutiny strategie
; -----------------------------------------------------------------------------

PUBLIC   Strateg
Strateg  PROC      FAR

         mov       word ptr cs:[adrzahl],bx
         mov       word ptr cs:[adrzahl+2],es
         ret

Strateg  ENDP

; -----------------------------------------------------------------------------
;        Tabulka skokñ
; -----------------------------------------------------------------------------

TabSkok  dw        offset Funkce00          ; 0  inicializace za©°zen°
         dw        offset Funkce01          ; 1  kontrola mÇdia
         dw        offset Funkce02          ; 2  vystavàn° bloku parametrñ BPB
         dw        offset Neznama           ; 3  vstup kan†lu IOCTL
         dw        offset Funkce04          ; 4  vstup - áten° z disku
         dw        offset Neznama           ; 5  (nedestruktivn° vstup)
         dw        offset Neznama           ; 6  (statut vstupu)
         dw        offset Neznama           ; 7  (vypr†zdnàn° vstupu)
         dw        offset Funkce08          ; 8  vòstup - z†pis na za©°zen°
         dw        offset Funkce08          ; 9  vòstup s verifikac°
         dw        offset Neznama           ; 0ah (statut vòstupu)
         dw        offset Neznama           ; 0bh (vypr†zdnàn° vòstupu)
         dw        offset Neznama           ; 0ch vòstup z kan†lu IOCTL
         dw        offset Ok                ; 0dh otev©en° za©°zen°
         dw        offset Ok                ; 0eh uzav©en° za©°zen°
         dw        offset Ok                ; 0fh vòmàna mÇdia

; -----------------------------------------------------------------------------
;        Obsluha rutinu p©eru®en°
; -----------------------------------------------------------------------------

PUBLIC   Prerus
Prerus   PROC      FAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         cld
         push      cs
         pop       ds
         les       bx,ds:[AdrZahl]          ; adresa z†hlav° za©°zen°
         mov       word ptr es:[bx+3],8103h ; chyba - neplatnò povel
         mov       al,es:[bx+2]             ; k¢d povelu
         cmp       al,0fh                   ; maxim†ln° povel
         ja        Prerus3                  ; chybnÇ á°slo povelu
         cbw                                ; AX <- AL á°slo povelu
         add       ax,ax                    ; á°slo povelu * 2
         mov       di,ax                    ; DI <- á°slo povelu * 2
         mov       word ptr es:[bx+3],100h  ; n†vratovò k¢d - OK
         call      word ptr ds:[di+TabSkok] ; vyvol†n° obsluhy funkce
Prerus3: pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Prerus   ENDP

; -----------------------------------------------------------------------------
;        NeobsluhovanÇ funkce
; -----------------------------------------------------------------------------

PUBLIC   Neznama
Neznama  PROC      NEAR

         mov       word ptr es:[bx+3],8103h ; chyba - neplatnò povel
Ok:      ret

Neznama  ENDP

; -----------------------------------------------------------------------------
;        Funkce 01h - kontrola vòmàny mÇdia
; -----------------------------------------------------------------------------

PUBLIC   Funkce01
Funkce01 PROC      NEAR

         mov       byte ptr es:[bx+0eh],1   ; p©°znak - mÇdium nezmànàno
         ret

Funkce01 ENDP

; -----------------------------------------------------------------------------
;        Funkce 02h - vystavàn° bloku parametrñ BIOS BPB
; -----------------------------------------------------------------------------

PUBLIC   Funkce02
Funkce02 PROC      NEAR

         mov       word ptr es:[bx+12h],offset bpb ; tabulka parametrñ BPB
         mov       word ptr es:[bx+14h],cs         ; segment tabulky BPB
         ret

Funkce02 ENDP

; -----------------------------------------------------------------------------
;        Funkce 04h - áten° z disku
; -----------------------------------------------------------------------------

PUBLIC   Funkce04
Funkce04 PROC      NEAR

         mov       cx,es:[bx+12h]           ; poáet sektorñ ke áten°
         mov       dx,es:[bx+14h]           ; poá†teán° sektor ke áten°
         push      ds
         mov       di,es:[bx+0eh]           ; offset bufferu pro naáten° dat
         mov       ds,es:[bx+10h]           ; segment bufferu pro naáten° dat
         call      ReadSekt                 ; naáten° sektorñ z disku
         pop       ds
         jnc       F042                     ; operace OK

         mov       word ptr es:[bx+12h],0   ; poáet p©enesenòch sektorñ = 0
         mov       word ptr es:[bx+3],810bh ; n†vratovò k¢d - chyba áten°

F042:    ret

Funkce04 ENDP

; -----------------------------------------------------------------------------
;        Funkce 08h, 09h - z†pis na za©°zen°
; -----------------------------------------------------------------------------

PUBLIC   Funkce08
Funkce08 PROC      NEAR

         mov       cx,es:[bx+12h]           ; poáet sektorñ k z†pisu
         mov       dx,es:[bx+14h]           ; poá†teán° sektor k z†pisu
         push      ds
         mov       si,es:[bx+0eh]           ; offset bufferu pro naáten° dat
         mov       ds,es:[bx+10h]           ; segment bufferu pro naáten° dat
         call      WritSekt                 ; z†pis sektorñ na disk
         pop       ds
         jnc       F082                     ; operace OK

         mov       word ptr es:[bx+12h],0   ; poáet p©enesenòch sektorñ = 0
         mov       word ptr es:[bx+3],810ah ; n†vratovò k¢d - chyba z†pisu

F082:    ret

Funkce08 ENDP

; -----------------------------------------------------------------------------
;        Funkce 00h - inicializace za©°zen°
; -----------------------------------------------------------------------------

PUBLIC   Funkce00
Funkce00 PROC      NEAR

         mov       si,offset UvTxt
         call      DispTxt                  ; zobrazen° £vodn°ho textu

                                          ;* kontrola velikosti pamàti
         clc                                ; p©ednastaven° NC
         mov       ah,88h
         int       15h                      ; dotaz na velikost pamàti
         jc        Fn00Err                  ; chyba (nen° obsluha funkce)
         sub       ax,40*9                  ; poáet KB pot©ebnÇ pamàti = 360
         jnc       Fn002                    ; pamàti je dostatek

                                          ;* chyba - nedostatek pamàti
Fn00Err: mov       si,offset ErrTxt         ; chybovò text
         call      DispTxt                  ; zobrazen° chybovÇho textu
         mov       byte ptr es:[bx+0dh],0   ; poáet diskñ = 0
         mov       byte ptr ds:[PocDisku],0 ; poáet diskñ = 0
         jmp       Fn009

                                          ;* nastaven° ukazatelñ pamàti
Fn002:   mov       ds:[FreeMem],ax          ; poáet zbylÇ volnÇ pamàti
         mov       dl,ah
         mov       ah,al
         xor       al,al
         add       ax,ax
         adc       dl,dl
         add       ax,ax
         adc       dl,dl
         add       dl,10h                   ; p©iáten° zaá†tku 1 MB
         mov       ds:[TopMem],ax           ; zaá†tek RAM-DISKu (nië®° slovo)
         mov       byte ptr ds:[TopMem+2],dl; zaá†tek RAM-DISKu (vy®®° slovo)

                                          ;* instalace obsluhy INT 15h
         push      ds                       ; £schova DS
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[4*15h]            ; offset INT 15h
         mov       word ptr cs:[Old15],ax   ; £schova offsetu INT 15h
         mov       ax,ds:[4*15h+2]          ; segmemt INT 15h
         mov       word ptr cs:[Old15+2],ax ; £schova segmentu INT 15h
         mov       word ptr ds:[4*15h],offset Int15 ; offset obsluhy INT 15h
         mov       word ptr ds:[4*15h+2],cs ; segment obsluhy INT 15h
         pop       ds

                                          ;* inicializace disku
         push      es
         push      cs
         pop       es
         mov       di,offset boot
         mov       cx,512
         xor       ax,ax
         cld
         rep       stosb
         pop       es


         xor       dx,dx
         mov       cx,720
Fn004:   push      cx
         mov       si,offset boot
         mov       cx,1
         call      WritSekt
         pop       cx
         inc       dx
         loop      Fn004

         mov       si,offset boot0
         mov       cx,1
         mov       dx,1
         call      WritSekt

         mov       cx,1
         mov       dx,1+3
         call      WritSekt


         mov       byte ptr es:[bx+0dh],1   ; poáet instalovanòch diskñ = 1
Fn009:   mov       word ptr es:[bx+12h],offset tabbpb ; tabulka BPB
         mov       word ptr es:[bx+14h],cs  ; segment adresy tabulky BPB
         mov       word ptr es:[bx+0eh],offset Funkce00 ; konec ovladaáe
         mov       word ptr es:[bx+10h],cs  ; segment konce ovladaáe
         ret

Funkce00 ENDP


; -----------------------------------------------------------------------------
;        Zobrazen° textu CS:SI
; -----------------------------------------------------------------------------

PUBLIC   DispTxt
DispTxt  PROC      NEAR

DispTxt1:mov       al,cs:[si]
         inc       si
         or        al,al
         jz        DispTxt2
         push      bx
         push      si
         push      es
         mov       ah,0eh
         mov       bx,7
         int       10h
         pop       es
         pop       si
         pop       bx
         jmp       short DispTxt1
DispTxt2:ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

UvTxt    db        'RAM-emulator disket V 1.0; (c) Miroslav Nemecek',13,10,0
ErrTxt   db        'Nedostatek pameti (EXTENDED) !',13,10,0

         EVEN
boot0    label     byte

         db        0fdh
         dw        0ffffh
         db        0

boot     label     byte                     ; zav†dàc° sektor disku


code     ENDS

         END

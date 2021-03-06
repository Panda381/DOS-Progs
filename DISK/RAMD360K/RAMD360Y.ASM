
; *****************************************************************************
;
;                  Emul�tor diskety 360 KB v pam�ti
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code

         dd        -1                       ; adresa n�sleduj�c�ho driveru
         dw        0800h                    ; atributy
         dw        offset Strateg           ; offset rutiny strategie
         dw        offset Prerus            ; offset rutiny p�eru�en�
PocDisku db        1                        ; po�et obsluhovan�ch disk�
         db        7 dup(0)                 ; rezervov�no

         db        'RAM360K V 1.00'         ; identifikace RAM-DISKu

format   db        0                        ; form�t diskety

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

AdrZahl  dd        0                        ; adresa z�hlav� za��zen�



tabbpb   dw        offset bpb

bpb      label     byte                   ;* blok parametr� BIOS BPB disku



SizeSekt dw        512                      ; 00h: po�et bajt� na sektor
SizeBlok db        1                        ; 02h: po�et sektor� na alok. blok
RezSekt  dw        1                        ; 03h: zav�d�c� a rezerv. sektory
NumFat   db        2                        ; 05h: po�et aloka�n�ch tabulek FAT
MaxRoot  dw        5*16                     ; 06h: max. po�et pol. z�kl. adres.
MaxSekt  dw        720                      ; 08h: celkov� po�et sektor� disku
Descript db        0fdh                     ; 0ah: popisova� m�dia
SektFat  dw        3                        ; 0bh: po�et sektor� v jedn� FAT
                                          ;* od DOS 3.00
SektTrck dw        9                        ; 0dh: po�et sektor� na stopu
NumHead  dw        2                        ; 0fh: po�et hlav
HidSekt  dd        0                        ; 11h: po�et skryt�ch sektor�

; 1 BOOT
; 2*3 FAT
; 4 ROOT
; 709 data
; ----------
; 720 celkem

; -----------------------------------------------------------------------------
;        �ten� sektor� z RAM-DISKu
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=adresa bufferu
;        DX=po��te�n� sektor ke �ten�
;        CX=po�et sektor� ke �ten�
; -----------------------------------------------------------------------------
; V�STUP:CY=chyba operace
;        CX=po�et zbyl�ch sektor�
; -----------------------------------------------------------------------------

PUBLIC   ReadSekt
ReadSekt PROC      NEAR

         push      dx
         push      si
         push      di

                                          ;* v�po�et zdrojov� adresy
         mov       ax,dx                    ; po��te�n� sektor
         call      GetExt                   ; v�po�et zdrojov� adresy
         mov       si,ax                    ; ni��� slovo zdrojov� adresy

                                          ;* v�po�et c�lov� adresy
         xor       dh,dh
         mov       ax,ds                    ; segment c�lov� adresy
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p�enos do vy���ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p�enos do vy���ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p�enos do vy���ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dh,dh                    ; p�enos do vy���ho bajtu
         add       di,ax                    ; p�i�ten� p�enosu ze segmentu
         adc       dh,0                     ; p�enos do vy���ho bajtu

         call      BlokMove                 ; �ten� sektor�

         pop       di
         pop       si
         pop       dx
         ret

ReadSekt ENDP

; -----------------------------------------------------------------------------
;        Z�pis sektor� do RAM-DISKu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa bufferu
;        DX=po��te�n� sektor k ulo�en�
;        CX=po�et sektor� k ulo�en�
; -----------------------------------------------------------------------------
; V�STUP:CY=chyba operace
;        CX=po�et zbyl�ch sektor�
; -----------------------------------------------------------------------------

PUBLIC   WritSekt
WritSekt PROC      NEAR

         push      dx
         push      si
         push      di

                                          ;* v�po�et c�lov� adresy
         mov       ax,dx                    ; po��te�n� sektor
         call      GetExt                   ; v�po�et c�lov� adresy
         mov       di,ax                    ; ni��� slovo c�lov� adresy
         mov       dh,dl                    ; vy��� bajt c�lov� adresy

                                          ;* v�po�et zdrojov� adresy
         xor       dl,dl
         mov       ax,ds                    ; segment zdrojov� adresy
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p�enos do vy���ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p�enos do vy���ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p�enos do vy���ho bajtu
         add       ax,ax                    ; segment * 2
         adc       dl,dl                    ; p�enos do vy���ho bajtu
         add       si,ax                    ; p�i�ten� p�enosu ze segmentu
         adc       dl,0                     ; p�enos do vy���ho bajtu

         call      BlokMove                 ; z�pis sektor�

         pop       di
         pop       si
         pop       dx
         ret

WritSekt ENDP

; -----------------------------------------------------------------------------
;        V�po�et adresy v roz�i�uj�c� pam�ti
; -----------------------------------------------------------------------------
; VSTUP: AX=��slo sektoru
; V�STUP:DL:AX=adresa v roz�i�uj�c� pam�ti
; -----------------------------------------------------------------------------

PUBLIC   GetExt
GetExt   PROC      NEAR

         push      cx
         push      dx
         mov       cx,512                   ; d�lka sektoru
         mul       cx                       ; p�epo�et sektor� na bajty
         mov       cl,dl                    ; vy��� bajt adresy
         pop       dx
         mov       dl,cl                    ; vy��� bajt adresy
         pop       cx
         add       ax,cs:[TopMem]           ; p�i�ten� po��tku pam�ti
         adc       dl,byte ptr cs:[TopMem+2]; vy��� bajt adresy
         ret

GetExt   ENDP

; -----------------------------------------------------------------------------
;        Tabulka popisova�� pro p�esun dat
; -----------------------------------------------------------------------------

GDT      label     word

                                          ;* pr�zdn� popisova�
GDT01    dw        0                        ; 0: omezen� segmentu
GDT02    dw        0                        ; 2: ni��� slovo adresy
GDT03    db        0                        ; 4: vy��� bajt adresy
GDT04    db        0                        ; 5: bajt p��stupov�ch pr�v
GDT05    dw        0                        ; 6: (rezervov�no)

                                          ;* popisova� tabulky GDT
GDT11    dw        0                        ; 0: omezen� segmentu
GDT12    dw        0                        ; 2: ni��� slovo adresy
GDT13    db        0                        ; 4: vy��� bajt adresy
GDT14    db        0                        ; 5: bajt p��stupov�ch pr�v
GDT15    dw        0                        ; 6: (rezervov�no)

                                          ;* popisova� zdrojov�ho bloku dat
GDT21    dw        0                        ; 0: omezen� segmentu
GDT22    dw        0                        ; 2: ni��� slovo adresy
GDT23    db        0                        ; 4: vy��� bajt adresy
GDT24    db        93h                      ; 5: bajt p��stupov�ch pr�v
GDT25    dw        0                        ; 6: (rezervov�no)

                                          ;* popisova� c�lov�ho bloku dat
GDT31    dw        0                        ; 0: omezen� segmentu
GDT32    dw        0                        ; 2: ni��� slovo adresy
GDT33    db        0                        ; 4: vy��� bajt adresy
GDT34    db        93h                      ; 5: bajt p��stupov�ch pr�v
GDT35    dw        0                        ; 6: (rezervov�no)

                                          ;* popisova� program. segmentu BIOS
GDT41    dw        0                        ; 0: omezen� segmentu
GDT42    dw        0                        ; 2: ni��� slovo adresy
GDT43    db        0                        ; 4: vy��� bajt adresy
GDT44    db        0                        ; 5: bajt p��stupov�ch pr�v
GDT45    dw        0                        ; 6: (rezervov�no)

                                          ;* popisova� z�sobn�kov�ho segmentu
GDT51    dw        0                        ; 0: omezen� segmentu
GDT52    dw        0                        ; 2: ni��� slovo adresy
GDT53    db        0                        ; 4: vy��� bajt adresy
GDT54    db        0                        ; 5: bajt p��stupov�ch pr�v
GDT55    dw        0                        ; 6: (rezervov�no)

GDT0     label     word                     ; konec tabulky popisova��

; -----------------------------------------------------------------------------
;        P�esun bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DL:SI=zdrojov� adresa
;        DH:DI=c�lov� adresa
;        CX=po�et sektor� k p�enosu
; V�STUP:CY=chyba operace
;        DL:SI=zdrojov� adresa (nov� hodnota)
;        DH:DI=c�lov� adresa (nov� hodnota)
;        CX=po�et zbyl�ch sektor�
; -----------------------------------------------------------------------------

PUBLIC   BlokMove
BlokMove PROC      NEAR

         clc
         jcxz      BlokMov9                 ; nen� ��dn� sektor k p�enosu

                                          ;* omezen� po�tu sektor�
         mov       ax,127                   ; maxim�ln� po�et sektor� k p�enosu
         cmp       ax,cx                    ; je p��li� velk� po�et sektor� ?
         jb        BlokMov1                 ; velk� po�et sektor� - omezen�
         mov       ax,cx                    ; po�adovan� po�et sektor�
BlokMov1:push      cx                       ; po�et po�adovan�ch sektor�

                                          ;* p�evod sektor� na bajty
         xchg      ah,al                    ; sektory * 256
         add       ax,ax                    ; po�et sektor� * 512

                                          ;* popisova� zdrojov�ho bloku
         mov       cs:[GDT21],ax            ; omezen� zdrojov�ho bloku
         mov       cs:[GDT22],si            ; ni��� slovo zdrojov� adresy
         mov       cs:[GDT23],dl            ; vy��� bajt zdrojov� adresy

                                          ;* popisova� c�lov�ho bloku
         mov       cs:[GDT31],ax            ; omezen� c�lov�ho bloku
         mov       cs:[GDT32],di            ; ni��� slovo c�lov� adresy
         mov       cs:[GDT33],dh            ; vy��� bajt c�lov� adresy

                                          ;* �schova registr�
         push      ax                       ; �schova p�en��en�ho po�tu bajt�
         push      dx
         push      si
         push      di
         push      es

                                          ;* p�enesen� bloku dat
         mov       cx,ax                    ; po�et bajt� k p�esunu
         shr       cx,1                     ; po�et slov k p�enosu
         push      cs
         pop       es                       ; ES <- segment tabulky GDT
         mov       si,offset GDT            ; tabulka popisova�� GDT
         mov       ah,87h
         clc                                ; p�ednastaven� p��znaku NC
         int       15h                      ; p�enos dat v chr�n�n�m m�du

                                          ;* n�vrat obsahu registr�
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx                       ; n�vrat p�en��en�ho po�tu bajt�

                                          ;* test v�sledku operace
         jc        BlokMov7                 ; chyba operace
         or        ah,ah                    ; byla operace �sp��n� ?
         stc                                ; p��znak chyby operace
         jnz       BlokMov7                 ; byla chyba operace

                                          ;* zv��en� c�lov� a zdrojov� adresy
         add       si,cx                    ; zv��en� zdrojov� adresy
         adc       dl,0                     ; p�enos do vy���ho bajtu
         add       di,cx                    ; zv��en� c�lov� adresy
         adc       dh,0                     ; p�enos do vy���ho bajtu
         clc                                ; p��znak - operace OK

BlokMov7:pop       cx                       ; n�vrat po�adovan�ho po�tu sektor�
         jc        BlokMov9                 ; byla chyba operace
         sub       cx,127                   ; ode�ten� max. po�tu sektor�
         jnc       BlokMov8                 ; nebylo p�ete�en� po�tu
         xor       cx,cx                    ; nezbyl ��dn� sektor
BlokMov8:jmp       short BlokMove           ; p�enos dal��ho bloku dat
BlokMov9:ret

BlokMove ENDP

; -----------------------------------------------------------------------------
;        Obsluha p�eru�en� INT 15h
; -----------------------------------------------------------------------------

FreeMem  dw        0                        ; po�et zbyl� voln� pam�ti
TopMem   dw        0                        ; po��te�n� adresa v ext. pam�ti
         db        0                        ; po��t. adresa - vy��� bajt
Old15    dd        0                        ; p�vodn� adresa obsluhy INT 15h

Int15    PROC      FAR

         pushf
         cmp       ah,88h                   ; je dotaz na velikost pam�ti ?
         jne       Int151                   ; nen� dotaz na velikost pam�ti
         popf
         mov       ax,cs:[FreeMem]          ; velikost roz�i�uj�c� pam�ti
         iret

Int151:  popf
         jmp       dword ptr cs:[old15]     ; pokra�ov�n� v p�vodn� obsluze

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
;        Tabulka skok�
; -----------------------------------------------------------------------------

TabSkok  dw        offset Funkce00          ; 0  inicializace za��zen�
         dw        offset Funkce01          ; 1  kontrola m�dia
         dw        offset Funkce02          ; 2  vystav�n� bloku parametr� BPB
         dw        offset Neznama           ; 3  vstup kan�lu IOCTL
         dw        offset Funkce04          ; 4  vstup - �ten� z disku
         dw        offset Neznama           ; 5  (nedestruktivn� vstup)
         dw        offset Neznama           ; 6  (statut vstupu)
         dw        offset Neznama           ; 7  (vypr�zdn�n� vstupu)
         dw        offset Funkce08          ; 8  v�stup - z�pis na za��zen�
         dw        offset Funkce08          ; 9  v�stup s verifikac�
         dw        offset Neznama           ; 0ah (statut v�stupu)
         dw        offset Neznama           ; 0bh (vypr�zdn�n� v�stupu)
         dw        offset Neznama           ; 0ch v�stup z kan�lu IOCTL
         dw        offset Ok                ; 0dh otev�en� za��zen�
         dw        offset Ok                ; 0eh uzav�en� za��zen�
         dw        offset Ok                ; 0fh v�m�na m�dia

; -----------------------------------------------------------------------------
;        Obsluha rutinu p�eru�en�
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
         les       bx,ds:[AdrZahl]          ; adresa z�hlav� za��zen�
         mov       word ptr es:[bx+3],8103h ; chyba - neplatn� povel
         mov       al,es:[bx+2]             ; k�d povelu
         cmp       al,0fh                   ; maxim�ln� povel
         ja        Prerus3                  ; chybn� ��slo povelu
         cbw                                ; AX <- AL ��slo povelu
         add       ax,ax                    ; ��slo povelu * 2
         mov       di,ax                    ; DI <- ��slo povelu * 2
         mov       word ptr es:[bx+3],100h  ; n�vratov� k�d - OK
         call      word ptr ds:[di+TabSkok] ; vyvol�n� obsluhy funkce
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
;        Neobsluhovan� funkce
; -----------------------------------------------------------------------------

PUBLIC   Neznama
Neznama  PROC      NEAR

         mov       word ptr es:[bx+3],8103h ; chyba - neplatn� povel
Ok:      ret

Neznama  ENDP

; -----------------------------------------------------------------------------
;        Funkce 01h - kontrola v�m�ny m�dia
; -----------------------------------------------------------------------------

PUBLIC   Funkce01
Funkce01 PROC      NEAR

         mov       byte ptr es:[bx+0eh],1   ; p��znak - m�dium nezm�n�no
         ret

Funkce01 ENDP

; -----------------------------------------------------------------------------
;        Funkce 02h - vystav�n� bloku parametr� BIOS BPB
; -----------------------------------------------------------------------------

PUBLIC   Funkce02
Funkce02 PROC      NEAR

         mov       word ptr es:[bx+12h],offset bpb ; tabulka parametr� BPB
         mov       word ptr es:[bx+14h],cs         ; segment tabulky BPB
         ret

Funkce02 ENDP

; -----------------------------------------------------------------------------
;        Funkce 04h - �ten� z disku
; -----------------------------------------------------------------------------

PUBLIC   Funkce04
Funkce04 PROC      NEAR

         mov       cx,es:[bx+12h]           ; po�et sektor� ke �ten�
         mov       dx,es:[bx+14h]           ; po��te�n� sektor ke �ten�
         push      ds
         mov       di,es:[bx+0eh]           ; offset bufferu pro na�ten� dat
         mov       ds,es:[bx+10h]           ; segment bufferu pro na�ten� dat
         call      ReadSekt                 ; na�ten� sektor� z disku
         pop       ds
         jnc       F042                     ; operace OK

         mov       word ptr es:[bx+12h],0   ; po�et p�enesen�ch sektor� = 0
         mov       word ptr es:[bx+3],810bh ; n�vratov� k�d - chyba �ten�

F042:    ret

Funkce04 ENDP

; -----------------------------------------------------------------------------
;        Funkce 08h, 09h - z�pis na za��zen�
; -----------------------------------------------------------------------------

PUBLIC   Funkce08
Funkce08 PROC      NEAR

         mov       cx,es:[bx+12h]           ; po�et sektor� k z�pisu
         mov       dx,es:[bx+14h]           ; po��te�n� sektor k z�pisu
         push      ds
         mov       si,es:[bx+0eh]           ; offset bufferu pro na�ten� dat
         mov       ds,es:[bx+10h]           ; segment bufferu pro na�ten� dat
         call      WritSekt                 ; z�pis sektor� na disk
         pop       ds
         jnc       F082                     ; operace OK

         mov       word ptr es:[bx+12h],0   ; po�et p�enesen�ch sektor� = 0
         mov       word ptr es:[bx+3],810ah ; n�vratov� k�d - chyba z�pisu

F082:    ret

Funkce08 ENDP

; -----------------------------------------------------------------------------
;        Funkce 00h - inicializace za��zen�
; -----------------------------------------------------------------------------

PUBLIC   Funkce00
Funkce00 PROC      NEAR

         mov       si,offset UvTxt
         call      DispTxt                  ; zobrazen� �vodn�ho textu

                                          ;* kontrola velikosti pam�ti
         clc                                ; p�ednastaven� NC
         mov       ah,88h
         int       15h                      ; dotaz na velikost pam�ti
         jc        Fn00Err                  ; chyba (nen� obsluha funkce)
         sub       ax,40*9                  ; po�et KB pot�ebn� pam�ti = 360
         jnc       Fn002                    ; pam�ti je dostatek

                                          ;* chyba - nedostatek pam�ti
Fn00Err: mov       si,offset ErrTxt         ; chybov� text
         call      DispTxt                  ; zobrazen� chybov�ho textu
         mov       byte ptr es:[bx+0dh],0   ; po�et disk� = 0
         mov       byte ptr ds:[PocDisku],0 ; po�et disk� = 0
         jmp       Fn009

                                          ;* nastaven� ukazatel� pam�ti
Fn002:   mov       ds:[FreeMem],ax          ; po�et zbyl� voln� pam�ti
         mov       dl,ah
         mov       ah,al
         xor       al,al
         add       ax,ax
         adc       dl,dl
         add       ax,ax
         adc       dl,dl
         add       dl,10h                   ; p�i�ten� za��tku 1 MB
         mov       ds:[TopMem],ax           ; za��tek RAM-DISKu (ni��� slovo)
         mov       byte ptr ds:[TopMem+2],dl; za��tek RAM-DISKu (vy��� slovo)

                                          ;* instalace obsluhy INT 15h
         push      ds                       ; �schova DS
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[4*15h]            ; offset INT 15h
         mov       word ptr cs:[Old15],ax   ; �schova offsetu INT 15h
         mov       ax,ds:[4*15h+2]          ; segmemt INT 15h
         mov       word ptr cs:[Old15+2],ax ; �schova segmentu INT 15h
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


         mov       byte ptr es:[bx+0dh],1   ; po�et instalovan�ch disk� = 1
Fn009:   mov       word ptr es:[bx+12h],offset tabbpb ; tabulka BPB
         mov       word ptr es:[bx+14h],cs  ; segment adresy tabulky BPB
         mov       word ptr es:[bx+0eh],offset Funkce00 ; konec ovlada�e
         mov       word ptr es:[bx+10h],cs  ; segment konce ovlada�e
         ret

Funkce00 ENDP


; -----------------------------------------------------------------------------
;        Zobrazen� textu CS:SI
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

boot     label     byte                     ; zav�d�c� sektor disku


code     ENDS

         END


; *****************************************************************************
;
;                           Struktura souboru ICO
;                           ---------------------
;
;    0: (22) z hlav¡ souboru
;  16h: (40) z hlav¡ obr zku
;  3Eh: (64) tabulka palet
;  7Eh: (512) data obr zku
; 27Eh: (128) maska obr zku
; 2FEh: konec
;
; Struktura z hlav¡ souboru ICO:
; -----------------------------
;    00h: (2) ........... rezervov no (mus¡ bìt = 0)
;    02h: (2) ........... typ souboru (mus¡ bìt = 1)
;    04h: (2) ........... poŸet obr zk… ikon v souboru (typicky = 1)
;    06h: (1) ........... ç¡ýka ikony v bodech (typicky 32, povoleno 16, 32, 64)
;    07h: (1) ........... vìçka ikony v bodech (typicky 32, povoleno 16, 32, 64)
;    08h: (1) ........... poŸet barev v ikonØ (typicky 16, povoleno 2, 8, 16)
;    09h: (1) ........... rezervov no (typicky = 0)
;    0Ah: (2) ........... rezervov no (typicky = 0)
;    0Ch: (2) ........... rezervov no (typicky = 0)
;    0Eh: (4) ........... velikost jednoho obr zku v bajtech, typicky:
;                 40 + 4*16 (palety) + 32*32*4/8 (data) + 32*32/8 (maska) = 744
;    12h: (4) ........... velikost tohoto z hlav¡ v bajtech (typicky 22)
;    16h: ............... n sleduje definice prvn¡ho obr zku
;
; Struktura z hlav¡ jednoho obr zku:
; ---------------------------------
;    00h: (4) ........... velikost tohoto z hlav¡ v bajtech (typicky 40)
;    04h: (4) ........... ç¡ýka a vìçka plochy obr zku (typicky 32)
;    08h: (4) ........... velikost tabulky palet v bajtech (typicky 4*16=64)
;                          (pro menç¡ poŸet barev velikost tabulky 4*8=32)
;    0Ch: (2) ........... (typicky 1)
;    0Eh: (4) ........... poŸet bit… na bod (typicky 4)
;    12h: (2) ........... (typicky 0)
;    14h: (4) ........... velikost data + maska obr zku (typicky 32*32*5/8=640)
;    18h: (4) ........... (typicky 0)
;    1Ch: (4) ........... (typicky 0)
;    20h: (4) ........... (typicky 0)
;    24h: (4) ........... (typicky 0)
;    28h: ............... n sleduje tabulka palet
;
; Struktura tabulky definice palet:
; --------------------------------
;    00h: (barev*4) ..... definice palet barev (typicky 16*4=64)
;                       (pro menç¡ poŸet barev minim ln¡ velikost 8*4=32)
;                            ka§d  barva definovan  pomoc¡ 4 bajt…:
;                                 (1) modr  slo§ka 0 a§ 255
;                                 (1) zelen  slo§ka 0 a§ 255
;                                 (1) Ÿerven  slo§ka 0 a§ 255
;                                 (1) doplåkov‚ pý¡znaky (typicky = 0)
;        Implicitn¡ definice palet WINDOWS:
;                                  0   0   0   0   ( 0: Ÿern )
;                                  0   0 128   0   ( 1: tmavØ Ÿerven )
;                                  0 128   0   0   ( 2: tmavØ zelen )
;                                  0 128 128   0   ( 3: tmavØ §lut )
;                                128   0   0   0   ( 4: tmavØ modr )
;                                128   0 128   0   ( 5: tmavØ purpurov )
;                                128 128   0   0   ( 6: tmavØ azurov )
;                                128 128 128   0   ( 7: tmavØ çed )
;                                192 192 192   0   ( 8: svØtle çed )
;                                  0   0 255   0   ( 9: svØtle Ÿerven )
;                                  0 255   0   0   (10: svØtle zelen )
;                                  0 255 255   0   (11: svØtle §lut )
;                                255   0   0   0   (12: svØtle modr )
;                                255   0 255   0   (13: svØtle purpurov )
;                                255 255   0   0   (14: svØtle azurov )
;                                255 255 255   0   (15: b¡l )
;
; Struktura dat jednoho obr zku:
; -----------------------------
;    00h: (ç¡ýka*vìçka*barev/8) ... data obr zku (typicky 32*32*4/8=512)
;                            data jsou ukl d na od spodn¡ linky zleva doprava;
;                            pro 16 barev obsahuje 1 bajt 2 body, horn¡ 4 bity
;                            jsou 1. bod (vlevo), doln¡ 4 bity 2. bod (vpravo)
;
; Struktura masky jednoho obr zku:
; -------------------------------
;   00h: (ç¡ýka*vìçka/8) .. bitov  maska obr zku (typicky 32*32/8=128)
;                            data jsou ukl d na od spodn¡ linky zleva doprava,
;                            horn¡ bity odpov¡daj¡ bod…m vlevo; je-li bit
;                            nastaven na "1", je bod pr…choz¡ pro pozad¡
; *****************************************************************************

SIRX     EQU       32                       ; ç¡ýka ikony (bod…)
VYSY     EQU       32                       ; vìçka ikony (bod…)
COLS     EQU       16                       ; poŸet barev ikony
COLSB    EQU       4                        ; poŸet bit… na bod

BufSize  EQU       800h                     ; velikost diskov‚ho bufferu
                                            ; (mus¡ bìt alespoå 1+18+3*256=786
                                            ;  pro palety)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ pýedefinov n¡ ukazatele z sobn¡ku

Start:   mov       bp,offset MemTxt         ; text - nedostatek pamØti
         cmp       sp,offset Zasobnik       ; je z sobn¡k OK ?
         call      Chyba                    ; chyba - nedostatek pamØti
         mov       sp,offset Zasobnik       ; pýedefinov n¡ z sobn¡ku

; ------ zmençen¡ segmentu programu ES

         mov       ah,4ah
         mov       bx,(offset(Zasobnik-Start)+10fh)/16 ; velikost programu
         int       21h                      ; nastaven¡ velikosti segmentu

; ------ vytvoýen¡ datov‚ho bloku

         mov       bx,-1                    ; fiktivn¡ nesmysln  velikost
         mov       ah,48h
         int       21h                      ; poskytnut¡ voln‚ pamØti
         mov       ah,48h
         int       21h                      ; pýidØlen¡ maxim ln¡ho bloku
         call      Chyba                    ; nØjak  chyba

; ------ kontrola velikosti bloku

         cmp       bx,200h                  ; minim ln¡ velikost asi tak 8 KB
         call      Chyba                    ; chyba - blok je pý¡liç malì
         mov       ds:[DatBeg],ax           ; adresa datov‚ho bufferu (zaŸ tek)
         add       ax,bx                    ; adresa konce bufferu
         mov       ds:[DatEnd],ax           ; segment konce bufferu

; ------ nastaven¡ pracovn¡ adresy DTA

         mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ textu

; ------ potvrzen¡ kl vesou MEZERA

         mov       ah,8
         int       21h                      ; vstup znaku z kl vesnice
         cmp       al," "                   ; je mezera ?
         mov       ah,4eh                   ; funkce hled n¡ soubor…
         je        Start12                  ; je mezera - start
Konec:   int       20h

; ------ vyhled n¡ prvn¡ho/dalç¡ho souboru

Start1:  mov       ah,4fh                   ; nalezen¡ dalç¡ho souboru
Start12: xor       cx,cx                    ; atributy souboru
         mov       dx,offset Soubory        ; maska soubor…
         int       21h                      ; nalezen¡ souboru
         jc        Konec                    ; nen¡ dalç¡ soubor

; ------ pý¡prava jm‚na vìstupn¡ho souboru

         cld
         push      ds
         pop       es
         mov       si,offset Soubor         ; jm‚no souboru
         mov       di,offset Soubor2        ; jm‚no vìstupn¡ho souboru
         mov       dx,di                    ; jm‚no souboru
Start13: lodsb
         stosb
         cmp       al,0
         je        Start14
         cmp       al,"."
         jne       Start13                  ; pýenesen¡ jm‚na souboru
Start14: dec       di                       ; n vrat na oddØlovac¡ teŸku/nulu

; ------ zobrazen¡ jm‚na souboru DX

         mov       word ptr ds:[di],0a0dh   ; konec ý dku
         mov       byte ptr ds:[di+2],"$"   ; oznaŸen¡ konce textu
         mov       ah,9
         int       21h                      ; zobrazen¡ jm‚na souboru

; ------ pý¡prava jm‚na vìstupn¡ho souboru (pý¡pona "ICO")

         mov       word ptr ds:[di],"I."
         mov       word ptr ds:[di+2],"OC"
         mov       byte ptr ds:[di+4],0     ; koncov  0

; ------ naŸten¡ vstupn¡ho souboru do pamØti

         call      ReadF                    ; naŸten¡ souboru

; ------ pý¡prava parametr… pro konverzi

         call      PrepKonv                 ; pý¡prava konverze

; ------ proveden¡ konverze souboru

         mov       di,offset OutBuff        ; ukl dac¡ adresa
         push      ds
         pop       es
         xor       bx,bx                    ; BH <- 0 ukazatel Y
         mov       ch,VYSY                  ; vnitýn¡ vìçka obr zku
Konv1:   mov       bl,0                     ; BL <- 0 ukazatel X
         mov       cl,SIRX                  ; vnitýn¡ ç¡ýka obr zku
Konv2:   call      Get0Bod                  ; poskytnut¡ bodu -> DL, DH, AL
         call      SetBod                   ; nastaven¡ bodu
         inc       bx
         dec       cl
         jnz       Konv2
         inc       bh
         dec       ch
         jnz       Konv1

; ------ z pis vìstupn¡ho souboru

         call      WritF                    ; z pis souboru
         jmp       Start1                   ; dalç¡ soubor

; -----------------------------------------------------------------------------
;        obsluha chyby (text BP, CY=je chyba)
; -----------------------------------------------------------------------------

Chyba    PROC      NEAR

         jc        Chyba1                   ; je chyba
         ret

Chyba1:  mov       dx,bp                    ; text chyby
         push      cs
         pop       ds                       ; DS <- segment programu
         mov       ah,9
         int       21h
         int       20h

Chyba    ENDP

; -----------------------------------------------------------------------------
;        inicializace tabulky standardn¡ch palet VGA
; -----------------------------------------------------------------------------

InitPal  PROC      NEAR

         mov       di,offset PaletVGA       ; tabulka palet VGA
         mov       cx,256
InitPal1:mov       al,0
         sub       al,cl                    ; Ÿ¡slo polo§ky 0 ...
         mov       word ptr ds:[di],0
         mov       byte ptr ds:[di+2],0

         shr       al,1                     ; modr 
         jnc       InitPal2
         mov       byte ptr ds:[di+2],42    ; modr  slo§ka

InitPal2:shr       al,1                     ; zelen 
         jnc       InitPal3
         mov       byte ptr ds:[di+1],42    ; zelen  slo§ka

InitPal3:shr       al,1                     ; Ÿerven 
         jnc       InitPal4
         mov       byte ptr ds:[di],42      ; Ÿerven  slo§ka

InitPal4:shr       al,1                     ; sekund rn¡ modr 
         jnc       InitPal5
         add       byte ptr ds:[di+2],21    ; sekund rn¡ modr  slo§ka

InitPal5:shr       al,1                     ; sekund rn¡ zelen 
         jnc       InitPal6
         add       byte ptr ds:[di+1],21    ; sekund rn¡ zelen  slo§ka

InitPal6:shr       al,1                     ; sekund rn¡ Ÿerven 
         jnc       InitPal7
         add       byte ptr ds:[di],21      ; sekund rn¡ Ÿerven  slo§ka

InitPal7:add       di,3
         loop      InitPal1
         ret

InitPal  ENDP

; *****************************************************************************
;
;                            Konverze obr zku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        pý¡prava parametr… konverze
; -----------------------------------------------------------------------------

PrepKonv PROC      NEAR

; ------ poŸet bajt… na ý dek

         mov       ax,ds:[Sirka]            ; poŸet bod… na ý dek
         test      byte ptr ds:[Param],2    ; je textovì m¢d ?
         jnz       PrepK3                   ; je textovì m¢d
         test      byte ptr ds:[Param],4    ; je paraleln¡ ulo§en¡ barev ?
         jnz       PrepK2                   ; je paraleln¡ ulo§en¡ barev
PrepK1:  add       ax,7                     ; zaokrouhlen¡
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; pýepoŸet na bajty
         jmp       short PrepK3             ; poŸet bajt… na ý dek pro EGA

PrepK2:  cmp       byte ptr ds:[Rovin],2    ; je m¢d CGA 4 barvy ?
         jb        PrepK1                   ; jsou 2 barvy
         ja        PrepK3                   ; je m¢d 8 rovin
         add       ax,3
         shr       ax,1
         shr       ax,1
PrepK3:  mov       ds:[ByteRow],ax          ; poŸet bajt… na ý dek

; ------ poŸet bajt… na rovinu

         mul       word ptr ds:[Vyska]      ; poŸet bajt… na rovinu
         or        dx,dx
         jz        PrepK4
         mov       ax,-1
PrepK4:  mov       ds:[BytePic],ax          ; poŸet bajt… na rovinu

; ------ korekce rozmØr… pro textovì m¢d

         test      byte ptr ds:[Param],2    ; je textovì m¢d ?
         jz        PrepK5                   ; nen¡ textovì m¢d
         mov       cl,3
         shl       word ptr ds:[Sirka],cl
         shl       word ptr ds:[Vyska],cl

; ------ dØlitel ve smØru X

PrepK5:  xor       dx,dx
         mov       ax,ds:[Sirka]            ; ç¡ýka obr zku
         mov       bx,SIRX                 ; vnitýn¡ ç¡ýka obr zku
         div       bx                       ; dØlitel X
         or        ax,ax
         jnz       PrepK6
         inc       ax
PrepK6:  cmp       ax,255
         jbe       PrepK7
         mov       al,255
PrepK7:  mov       ds:[DelX],al             ; dØlitel X

; ------ dØlitel ve smØru Y

         xor       dx,dx
         mov       ax,ds:[Vyska]            ; vìçka obr zku
         mov       bx,VYSY                 ; vnitýn¡ vìçka obr zku
         div       bx                       ; dØlitel Y
         or        ax,ax
         jnz       PrepK8
         inc       ax
PrepK8:  cmp       ax,255
         jbe       PrepK9
         mov       al,255
PrepK9:  mov       ds:[DelY],al             ; dØlitel Y
         ret

PrepKonv ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bodu pro obr zek
; -----------------------------------------------------------------------------
; VSTUP: BL=pozice
;        BH=linka
; VíSTUP: AL=modr  0 a§ 63
;         DL=zelen  0 a§ 63
;         DH=Ÿerven  0 a§ 63
; -----------------------------------------------------------------------------
; lok ln¡ promØnn‚: SS:[BP-2] (2) poŸet bod… celkem (dØlitel vìsledku)
;                   SS:[BP-6] (4) stýadaŸ modr‚
;                   SS:[BP-10] (4) stýadaŸ zelen‚
;                   SS:[BP-14] (4) stýadaŸ Ÿerven‚
; -----------------------------------------------------------------------------

Get0Bod  PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,14                    ; lok ln¡ promØnn‚

; ------ poŸet bod… celkem

         mov       al,ds:[DelX]             ; dØlitel X
         mul       byte ptr ds:[DelY]       ; kr t dØlitel Y
         mov       ss:[bp-2],ax             ; dØlitel celkem

; ------ nulov n¡ stýadaŸ…

         xor       ax,ax
         mov       ss:[bp-4],ax
         mov       ss:[bp-6],ax             ; modr 
         mov       ss:[bp-8],ax
         mov       ss:[bp-10],ax            ; zelen 
         mov       ss:[bp-12],ax
         mov       ss:[bp-14],ax            ; Ÿerven 

; ------ pýepoŸet souýadnic na souýadnice v obr zku

         mov       al,bl                    ; pozice
         mov       ah,0
         mul       word ptr ds:[Sirka]
         mov       cx,SIRX                 ; vnitýn¡ ç¡ýka obr zku
         div       cx                       ; pozice ve smØru X
         xchg      ax,bx                    ; BX <- pozice v obr zku SCR

         mov       al,ah                    ; linka
         mov       ah,0
         mul       word ptr ds:[Vyska]
         mov       cl,VYSY                 ; vnitýn¡ vìçka obr zku
         div       cx                       ; pozice ve smØru Y
         xchg      ax,si                    ; SI <- linka v obr zku SCR

; ------ nastý d n¡ bod…

         mov       ch,ds:[DelY]             ; dØlitel ve smØru Y
Get0Bod1:push      bx
         mov       cl,ds:[DelX]             ; dØlitel ve smØru X
Get0Bod2:call      GetBod                   ; poskytnut¡ bodu
         mov       ah,0
         add       ss:[bp-6],ax             ; modr 
         adc       ss:[bp-6+2],ah
         mov       al,dl
         add       ss:[bp-10],ax            ; zelen 
         adc       ss:[bp-10+2],ah
         mov       al,dh
         add       ss:[bp-14],ax            ; Ÿerven 
         adc       ss:[bp-14+2],ah
         inc       bx                       ; zvìçen¡ ukazatele pozice
         dec       cl                       ; Ÿ¡taŸ bod… ve smØru X
         jnz       Get0Bod2                 ; dalç¡ bod
         pop       bx
         inc       si                       ; zvìçen¡ linky
         dec       ch
         jnz       Get0Bod1                 ; dalç¡ linka

; ------ vìpoŸet pr…mØru barev

         mov       ax,ss:[bp-6]             ; modr 
         mov       dx,ss:[bp-6+2]
         div       word ptr ss:[bp-2]       ; pr…mØr modr‚
         push      ax                       ; AL = modr 

         mov       ax,ss:[bp-10]            ; zelen 
         mov       dx,ss:[bp-10+2]
         div       word ptr ss:[bp-2]       ; pr…mØr zelen‚
         push      ax                       ; AL = zelen 

         mov       ax,ss:[bp-14]            ; Ÿerven 
         mov       dx,ss:[bp-14+2]
         div       word ptr ss:[bp-2]       ; pr…mØr Ÿerven‚

         pop       dx                       ; DL = zelen 
         mov       dh,al                    ; DH <- Ÿerven 
         pop       ax                       ; AK = modr 

; ------ n vrat registr…

         mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

Get0Bod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bodu z SCR
; -----------------------------------------------------------------------------
; VSTUP: BX=pozice
;        SI=linka
; VíSTUP: AL=modr  0 a§ 63
;         DL=zelen  0 a§ 63
;         DH=Ÿerven  0 a§ 63
; -----------------------------------------------------------------------------

GetBod   PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ pý¡prava registr…

         xchg      ax,si                    ; AX <- linka v obr zku
         cmp       ax,ds:[Vyska]
         jb        GetBod01
         mov       ax,ds:[Vyska]
         dec       ax
GetBod01:cmp       bx,ds:[Sirka]
         jb        GetBod02
         mov       bx,ds:[Sirka]
         dec       bx
GetBod02:mov       ch,al                    ; linka LOW
         mov       es,ds:[DatBeg]           ; adresa bufferu
         xor       di,di                    ; adresa prvn¡ roviny

; ------ poskytnut¡ bodu v textov‚m m¢du

         test      byte ptr ds:[Param],2    ; je textovì m¢d ?
         jz        GetBod1                  ; nen¡ textovì m¢d
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; ý dek
         mul       word ptr ds:[ByteRow]    ; offset ý dku v rovinØ
         xchg      ax,si                    ; SI <- offset linky v rovinØ
         call      GetTBod                  ; poskytnut¡ textov‚ho bodu
         jmp       short GetBod6            ; konverze barvy AL

; ------ poskytnut¡ bodu v m¢du EGA 1 barva

GetBod1: mul       word ptr ds:[ByteRow]    ; offset linky v rovinØ
         xchg      ax,si                    ; SI <- offset linky v rovinØ

         cmp       byte ptr ds:[Rovin],1    ; je 1 rovina ?
         jne       GetBod12                 ; nen¡ 1 rovina
         call      GetEBod
         cmp       al,0
         je        GetBod6
         mov       al,15
         jmp       short GetBod6

; ------ poskytnut¡ bodu v m¢du CGA 4 barvy

GetBod12:test      byte ptr ds:[Param],4    ; je paraleln¡ ulo§en¡ barev ?
         jz        GetBod5                  ; nen¡ paraleln¡ ulo§en¡ barev - EGA
         cmp       byte ptr ds:[Rovin],2    ; jsou 4 barvy ?
         jne       GetBod7                  ; nejsou 4 roviny
         call      GetCBod                  ; poskytnut¡ m¢du CGA

; ------ konverze barvy CGA (AL = 0 a§ 3) na barvu EGA (0 a§ 15)

GetBod2: shl       al,1                     ; 0,2,4,6 implicitn¡ barvy
         jnz       GetBod3                  ; nen¡ Ÿern  barva
         mov       al,ds:[PaletCGA]         ; paleta CGA
         and       al,0fh                   ; barva pozad¡
         jmp       short GetBod6            ; konverze na palety VGA

GetBod3: test      byte ptr ds:[PaletCGA],20h ; je modr  slo§ka ?
         jz        GetBod4                  ; nen¡ modr  slo§ka
         inc       ax                       ; pýid n¡ modr‚ slo§ky

GetBod4: test      byte ptr ds:[PaletCGA],10h ; je intenzivn¡ popýed¡ ?
         jz        GetBod6                  ; nen¡ intenzivn¡ popýed¡
         add       al,8                     ; intenzivn¡ barva
         jmp       short GetBod6            ; konverze na palety VGA

; ------ poskytnut¡ bodu v m¢du EGA a v m¢du CGA 1 barva -> AL (0 a§ 15)

GetBod5: call      GetEBod                  ; poskytnut¡ m¢du EGA

; ------ konverze barvy v m¢du EGA (AL = 0 a§ 15) na paletu VGA (AL = 0 a§ 255)

GetBod6: mov       bl,al
         mov       bh,0                     ; BX = offset v tabulce palet
         mov       al,ds:[bx+PaletEGA]      ; odpov¡daj¡c¡ paleta
         mov       ah,ds:[PaletEG0]         ; adresace palet
         and       ah,0c0h                  ; nejvyçç¡ 2 bity adresy
         or        al,ah                    ; korekce adresy
         mov       ah,ds:[PaletEG0]
         test      ah,1                     ; plat¡ bity 4 a 5 ?
         jz        GetBod8                  ; bity 4 a 5 plat¡ OK
         and       ah,30h                   ; vyçç¡ 2 bity
         and       al,not 30h
         or        al,ah                    ; nov‚ 2 bity adresy
         jmp       short GetBod8            ; konverze na barevn‚ slo§ky

; ------ poskytnut¡ bodu v m¢du VGA 8 rovin -> AL

GetBod7: mov       al,63                    ; n hradn¡ barva - b¡l 
         mov       dx,63*256 + 63
         cmp       byte ptr ds:[Rovin],8
         jne       GetBod9                  ; jinak neplatnì bod
         call      GetVBod                  ; poskytnut¡ m¢du VGA

; ------ konverze barvy v m¢du VGA (AL = 0 a§ 255) na barevn‚ slo§ky

GetBod8: mov       ah,0
         mov       bx,ax                    ; Ÿ¡slo barvy
         shl       ax,1
         add       ax,offset PaletVGA       ; palety VGA
         add       bx,ax                    ; adresa v tabulce palet
         mov       al,ds:[bx+2]             ; modr 
         mov       dl,ds:[bx+1]             ; zelen 
         mov       dh,ds:[bx]               ; Ÿerven 

; ------ n vrat registr…

GetBod9: pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

GetBod   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bodu v textov‚m m¢du
; -----------------------------------------------------------------------------

GetTBod  PROC      NEAR

         mov       cl,bl                    ; pozice
         and       cl,7                     ; poŸet rotac¡ X

         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; pozice na ý dku
         add       di,si
         add       di,bx                    ; adresa znaku

         mov       ah,es:[di]               ; znak

         add       di,ds:[BytePic]          ; adresa roviny palet
         mov       al,es:[di]               ; barva bodu

         push      ax
         mov       al,ah                    ; znak
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1
         and       ch,7                     ; linka
         add       al,ch
         adc       ah,0                     ; linka
         xchg      ax,si
         mov       al,ds:[si+Fonty]         ; font
         shl       al,cl
         shl       al,1
         pop       ax
         jc        GetTBod4                 ; plat¡ barva popýed¡

         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; plat¡ barva pozad¡

GetTBod4:and       al,0fh
         ret

GetTBod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bodu v m¢du CGA
; -----------------------------------------------------------------------------

GetCBod  PROC      NEAR

         mov       cl,bl
         and       cl,3                     ; pozice bodu v bajtu
         shr       bx,1
         shr       bx,1                     ; offset bajtu na lince
         add       di,si                    ; adresa linky
         add       di,bx                    ; adresa bajtu
         mov       ah,es:[di]               ; bajt
         inc       cx
         shl       cx,1                     ; poŸet rotac¡ * 2
         rol       ax,cl                    ; rotace bodu
         and       al,3                     ; bod na po§adovan‚ pozici
         ret

GetCBod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bodu v m¢du EGA
; -----------------------------------------------------------------------------

GetEBod  PROC      NEAR

         mov       ch,ds:[Rovin]            ; poŸet barevnìch rovin
         mov       cl,bl
         and       cl,7                     ; offset bodu
         inc       cx
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; offset bajtu na lince
         add       di,si                    ; adresa linky
         add       di,bx                    ; adresa bajtu
         mov       bx,8000h                 ; stýadaŸ

GetEBod1:mov       al,es:[di]               ; bajt
         shl       al,cl                    ; rotace bodu do CF
         rcr       bx,1                     ; pýenos bodu do stýadaŸe

         add       di,ds:[BytePic]          ; adresa dalç¡ roviny
         jnc       GetEBod2

         mov       ax,es
         add       ax,1000h
         mov       es,ax

GetEBod2:dec       ch                       ; Ÿ¡taŸ rovin
         jnz       GetEBod1

GetEBod3:shr       bx,1
         jnc       GetEBod3                 ; dora§en¡ bit…
         xchg      ax,bx                    ; AL <- barva
         ret

GetEBod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bodu v m¢du VGA
; -----------------------------------------------------------------------------

GetVBod  PROC      NEAR

         add       si,di                    ; adresa linky
         add       si,bx                    ; adresa bodu
         mov       al,es:[si]               ; po§adovanì bod
         ret

GetVBod  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ bodu do obr zku
; -----------------------------------------------------------------------------
; VSTUP: AL=modr  0 a§ 63
;        DL=zelen  0 a§ 63
;        DH=Ÿerven  0 a§ 63
;        BL=pozice
;        BH=linka
; -----------------------------------------------------------------------------
;þ
SetBod   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ vìpoŸet adresy bajtu -> SI, rotace CL

         push      ax
         mov       ah,VYSY-1                ; poŸet linek ikony celkem
         sub       ah,bh                    ; poýad¡ linek se obr t¡
         mov       al,SIRX/2                ; poŸet bajt… na linku
         mul       ah                       ; pýepoŸet linky na bajty
         add       ax,offset OutBuff        ; adresa linky
         xchg      ax,si                    ; SI <- adresa linky
         mov       cl,bl
         and       cl,1                     ; poŸet rotac¡
         xor       cl,1
         shl       cl,1
         shl       cl,1
         mov       bh,0
         shr       bx,1
         add       si,bx                    ; adresa bajtu
         pop       ax

; ------ nalezen¡ nejbli§ç¡ barvy

         mov       di,offset OutPal         ; paleta vìstupn¡ch barev
         mov       bp,-1                    ; nalezen  nejlepç¡ vzd lenost
         mov       ah,0                     ; ukazatel Ÿ¡sla barvy
SetBod1: push      ax
         push      dx

         sub       al,ds:[di]               ; vzd lenost od modr‚
         imul      al                       ; absolutn¡ hodnota
         xchg      ax,bx                    ; BX <- £schova vzd lenosti
         inc       di

         mov       al,dl                    ; zelen 
         sub       al,ds:[di]               ; vzd lenost od zelen‚
         imul      al                       ; absolutn¡ hodnota
         add       bx,ax                    ; stýadaŸ vzd lenosti
         inc       di

         mov       al,dh                    ; Ÿerven 
         sub       al,ds:[di]               ; vzd lenost od Ÿerven‚
         imul      al                       ; absolutn¡ hodnota
         add       bx,ax                    ; stýadaŸ vzd lenosti
         inc       di

         pop       dx
         pop       ax

         cmp       bx,bp                    ; nalezena bli§ç¡ barva ?
         ja        SetBod2                  ; nen¡ to bli§ç¡ barva
         mov       bp,bx                    ; £schova vzd lenosti

         push      ax
         mov       al,0fh                   ; maska
         shl       ax,cl                    ; rotace na pozic
         not       al
         and       ds:[si],al               ; zruçen¡ star‚ hodnoty
         or        ds:[si],ah               ; nastaven¡ nov‚ hodnoty
         pop       ax

SetBod2: inc       ah                       ; zvìçen¡ ukazatele Ÿ¡sla barvy
         cmp       ah,16
         jb        SetBod1                  ; test dalç¡ barvy

; ------ n vrat registr…

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetBod   ENDP

; *****************************************************************************
;
;                       NaŸten¡ vstupn¡ho souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        naŸten¡ vstupn¡ho souboru
; -----------------------------------------------------------------------------

ReadF    PROC      NEAR

; ------ otevýen¡ vstupn¡ho souboru

         mov       dx,offset Soubor
         mov       ax,3d00h                 ; otevýen¡ pro Ÿten¡
         int       21h                      ; otevýen¡ souboru pro Ÿten¡
         mov       bp,offset ReadTxt        ; text - soubor nenalezen
         call      Chyba                    ; chyba - soubor nenalezen
         mov       ds:[InpIdnt],ax          ; identifik tor vstupn¡ho souboru

; ------ implicitn¡ palety VGA

         call      InitPal                  ; inicializace palet VGA

; ------ naŸten¡ z hlav¡ souboru

         mov       bx,ds:[InpIdnt]          ; vstupn¡ identifik tor
         mov       dx,offset Zahlavi        ; z hlav¡ souboru
         mov       cx,offset(KonHl-Zahlavi) ; velikost z hlav¡
         mov       ah,3fh
         int       21h                      ; naŸten¡ z hlav¡ souboru
         mov       bp,offset ReadTxt        ; text - chyba Ÿten¡
         call      Chyba                    ; chyba

; ------ kontrola z hlav¡ souboru

         cmp       ax,cx
         jne       ReadF1                   ; nesouhlas¡ velikost
         cmp       word ptr ds:[Sirka],0
         je        ReadF1
         cmp       word ptr ds:[Vyska],0
         je        ReadF1
         cmp       byte ptr ds:[Rovin],0
         je        ReadF1
         cmp       word ptr ds:[Ident],"CS"
         jne       ReadF1                   ; z hlav¡ nesouhlas¡
         cmp       word ptr ds:[Ident+2],1*256 + "R"
         je        ReadF2                   ; z hlav¡ je OK

; ------ chyba - neplatnì soubor SCR

ReadF1:  mov       bp,offset SCRTxt
         jmp       Chyba1

; ------ naŸten¡ koment ýe (a ignorov n¡)

ReadF2:  mov       ch,0
         mov       cl,ds:[Komentar]         ; poŸet bajt… koment ýe
         mov       si,ds:[Palet]            ; poŸet bajt… za z hlav¡m
         jcxz      ReadF21                  ; nen¡ koment ý
         mov       dx,offset Buffer         ; vstupn¡ datovì buffer
         mov       ah,3fh
         int       21h                      ; naŸten¡ koment ýe
         sub       si,cx

; ------ naŸten¡ palety CGA

ReadF21: test      byte ptr ds:[Param],10h  ; jsou palety CGA ?
         jz        ReadF22                  ; nejsou palety CGA
         mov       cl,1
         mov       dx,offset PaletCGA       ; palety CGA
         mov       ah,3fh
         int       21h                      ; naŸten¡ palety CGA
         sub       si,cx

; ------ naŸten¡ palet EGA

ReadF22: test      byte ptr ds:[Param],20h  ; jsou palety EGA ?
         jz        ReadF23                  ; nejsou palety EGA
         mov       cl,18
         mov       dx,offset PaletEGA
         mov       ah,3fh
         int       21h                      ; naŸten¡ palet EGA
         sub       si,cx

; ------ naŸten¡ palet VGA

ReadF23: test      byte ptr ds:[Param],40h  ; jsou palety VGA ?
         jz        ReadF24                  ; nejsou palety VGA
         mov       cx,3*256
         mov       dx,offset PaletVGA
         mov       ah,3fh
         int       21h                      ; naŸten¡ palet VGA
         sub       si,cx

; ------ naŸten¡ zbyku z hlav¡

ReadF24: mov       dx,offset Buffer
         cmp       si,BufSize
         jbe       ReadF25
         mov       si,offset BufSize
ReadF25: mov       cx,si
         jcxz      ReadF3
         mov       ah,3fh
         int       21h                      ; naŸten¡ zbytku z hlav¡

; ------ pý¡prava ukazatel… k naŸten¡ souboru

ReadF3:  mov       es,ds:[DatBeg]           ; zaŸ tek bufferu
         xor       di,di                    ; offset ukl dac¡ adresy
         xor       si,si                    ; Ÿtec¡ adresa z bufferu

; ------ inicializace ukazatel… komprese

         mov       word ptr ds:[KompCit],0  ; Ÿ¡taŸ komprese
         mov       word ptr ds:[KompBNum],0 ; zruçen¡ Ÿ¡taŸe bajt… v bufferu
         mov       byte ptr ds:[KompPar],1  ; nastaven¡ pý¡znaku komprese
         mov       word ptr ds:[NumBuf],0   ; v bufferu nejsou § dn  data

; ------ normalizace ukl dac¡ adresy

ReadF4:  mov       ax,di
         and       di,0fh
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       cx,es
         add       ax,cx
         mov       es,ax

; ------ test, zda je pýeteŸen¡ bufferu

         cmp       ax,ds:[DatEnd]           ; pýeteŸen¡ pamØti ?
         jb        ReadF5
         mov       bp,offset MemTxt         ; chyba - nedostatek pamØti
         jmp       Chyba1

; ------ naŸten¡ 1 bajtu

ReadF5:  call      ReadByte                 ; naŸten¡ 1 bajtu
         jc        ReadF6                   ; konec dat
         cld
         stosb                              ; ulo§en¡ bajtu do bufferu
         jmp       short ReadF4             ; dalç¡ bajt

; ------ uzavýen¡ souboru

ReadF6:  mov       ah,3eh
         int       21h

ReadF9:  ret

ReadF    ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ bajtu z bufferu SI souboru (CY=konec souboru)
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

         test      byte ptr ds:[Param],1    ; je komprese ?
         jz        ReadB                    ; nen¡ komprese

; ------ naŸten¡ bajtu poŸtu dat komprese

         cmp       word ptr ds:[KompCit],0  ; je Ÿ¡taŸ platnì ?
         jne       ReadByt4                 ; Ÿ¡taŸ je dosud platnì
ReadByt1:call      ReadB                    ; naŸten¡ bajtu Ÿ¡taŸe
         jc        ReadByt6
         mov       byte ptr ds:[KompCit],al ; poŸet n sleduj¡c¡ch bajt…

; ------ pýep¡naŸ m¢du komprese (bajt 0)

         or        al,al                    ; je to jen pýep¡naŸ ?
         jnz       ReadByt2                 ; nen¡ to pýep¡naŸ
         xor       byte ptr ds:[KompPar],1  ; zmØna pý¡znaku komprese
         jmp       short ReadByt1           ; nov‚ Ÿten¡ bajtu

; ------ naŸten¡ bajtu k opakov n¡

ReadByt2:and       byte ptr ds:[KompPar],not 2 ; zruçen¡ pý¡znaku komprese
         test      byte ptr ds:[KompPar],1  ; je m¢d komprese ?
         jz        ReadByt3                 ; nen¡ m¢d komprese
         or        byte ptr ds:[KompPar],2  ; pý¡znak komprese
         call      ReadB                    ; naŸten¡ bajtu k opakov n¡
         jc        ReadByt6
         mov       ds:[KompChar],al         ; bajt k opakov n¡

; ------ zmØna pý¡znaku m¢du komprese

ReadByt3:cmp       word ptr ds:[KompCit],255 ; je zmØna m¢du komprese ?
         je        ReadByt4                 ; nen¡ zmØna m¢du komprese
         xor       byte ptr ds:[KompPar],1  ; zmØna pý¡znaku komprese

; ------ naŸten¡ dalç¡ho bajtu

ReadByt4:mov       al,ds:[KompChar]         ; bajt pýi opakov n¡ dat
         test      byte ptr ds:[KompPar],2  ; je opakov n¡ dat ?
         jnz       ReadByt5                 ; je opakov n¡ dat
         call      ReadB                    ; naŸten¡ bØ§n‚ho bajtu dat
         jc        ReadByt6

; ------ sn¡§en¡ Ÿ¡taŸe bajt…

ReadByt5:dec       byte ptr ds:[KompCit]    ; sn¡§en¡ Ÿ¡taŸe komprese
         clc
ReadByt6:ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ bajtu z bufferu SI bez komprese (CY=konec souboru)
; -----------------------------------------------------------------------------

ReadB    PROC      NEAR

; ------ test, zda je v bufferu dalç¡ bajt

         cmp       si,ds:[NumBuf]           ; je ji§ konec bufferu ?
         jae       ReadB2                   ; je konec bufferu

; ------ naŸten¡ dalç¡ho bajtu z bufferu

ReadB3:  mov       al,ds:[si+Buffer]        ; naŸten¡ bajtu z bufferu
         inc       si                       ; zvìçen¡ ukazatele v bufferu
         clc                                ; pý¡znak platn‚ho bajtu
         ret

; ------ naŸten¡ dalç¡ho bloku dat

ReadB2:  xor       si,si                    ; novì ukazatel Ÿtec¡ adresy

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,3fh
         mov       dx,offset Buffer         ; poŸ tek bufferu
         mov       cx,BUFSIZE               ; velikost bufferu
         mov       bx,ds:[InpIdnt]          ; identifik tor souboru
         int       21h                      ; naŸten¡ bloku dat z buferu
         jc        ReadB5
         mov       ds:[NumBuf],ax           ; novì poŸet bajt… v bufferu
         or        ax,ax
         jnz       ReadB5                   ; je nØco naŸteno
         stc                                ; pý¡znak konce souboru

Readb5:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         jnc       ReadB3                   ; operace OK
         ret

ReadB    ENDP

; *****************************************************************************
;
;                         Z pis vìstupn¡ho souboru
;
; *****************************************************************************
;þ
WritF    PROC      NEAR

; ------ vytvoýen¡ vìstupn¡ho souboru

         mov       dx,offset Soubor2        ; jm‚no vìstupn¡ho souboru
         mov       ah,3ch
         xor       cx,cx                    ; atributy souboru
         int       21h                      ; vytvoýen¡ vìstupn¡ho souboru
         xchg      ax,bx                    ; BX <- identifik tor souboru
         mov       bp,offset WritTxt        ; text - chyba z pisu
         call      Chyba                    ; chyba - vìst.soubor nelze vytvoýit

; ------ z pis souboru

         mov       dx,offset Zahlavi2       ; soubor ICO
         mov       cx,offset(Zahlav20-Zahlavi2) ; d‚lka souboru
         mov       ah,40h                   ; funkce z pisu do souboru
         int       21h                      ; z pis souboru
         call      Chyba                    ; obsluha chyby

; ------ uzavýen¡ souboru

         mov       ah,3eh
         int       21h
         call      Chyba                    ; obsluha chyby
         ret

WritF    ENDP

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        fonty
; -----------------------------------------------------------------------------

Fonty    label     byte
         db        00000000b                ; 0
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01111110b                ; 1
         db        10000001b
         db        10100101b
         db        10000001b
         db        10111101b
         db        10011001b
         db        10000001b
         db        01111110b

         db        01111110b                ; 2
         db        11111111b
         db        11011011b
         db        11111111b
         db        11000011b
         db        11100111b
         db        11111111b
         db        01111110b

         db        01101100b                ; 3
         db        11111110b
         db        11111110b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b

         db        00010000b                ; 4
         db        00111000b
         db        01111100b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b

         db        00111000b                ; 5
         db        01111100b
         db        00111000b
         db        11111110b
         db        11111110b
         db        10010010b
         db        00010000b
         db        01111100b

         db        00000000b                ; 6
         db        00010000b
         db        00111000b
         db        01111100b
         db        11111110b
         db        01111100b
         db        00111000b
         db        01111100b

         db        00000000b                ; 7
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b

         db        11111111b                ; 8
         db        11111111b
         db        11100111b
         db        11000011b
         db        11000011b
         db        11100111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 9
         db        00111100b
         db        01100110b
         db        01000010b
         db        01000010b
         db        01100110b
         db        00111100b
         db        00000000b

         db        11111111b                ; 10
         db        11000011b
         db        10011001b
         db        10111101b
         db        10111101b
         db        10011001b
         db        11000011b
         db        11111111b

         db        00001111b                ; 11
         db        00000111b
         db        00001111b
         db        01111101b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b

         db        00111100b                ; 12
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00011000b

         db        00111111b                ; 13
         db        00110011b
         db        00111111b
         db        00110000b
         db        00110000b
         db        01110000b
         db        11110000b
         db        11100000b

         db        01111111b                ; 14
         db        01100011b
         db        01111111b
         db        01100011b
         db        01100011b
         db        01100111b
         db        11100110b
         db        11000000b

         db        10011001b                ; 15
         db        01011010b
         db        00111100b
         db        11100111b
         db        11100111b
         db        00111100b
         db        01011010b
         db        10011001b

         db        10000000b                ; 16
         db        11100000b
         db        11111000b
         db        11111110b
         db        11111000b
         db        11100000b
         db        10000000b
         db        00000000b

         db        00000010b                ; 17
         db        00001110b
         db        00111110b
         db        11111110b
         db        00111110b
         db        00001110b
         db        00000010b
         db        00000000b

         db        00011000b                ; 18
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b

         db        01100110b                ; 19
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        01100110b
         db        00000000b

         db        01111111b                ; 20
         db        11011011b
         db        11011011b
         db        01111011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00000000b

         db        00111110b                ; 21
         db        01100011b
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        10000110b
         db        11111100b

         db        00000000b                ; 22
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        01111110b
         db        01111110b
         db        00000000b

         db        00011000b                ; 23
         db        00111100b
         db        01111110b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        11111111b

         db        00011000b                ; 24
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        00011000b                ; 25
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b

         db        00000000b                ; 26
         db        00011000b
         db        00001100b
         db        11111110b
         db        00001100b
         db        00011000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 27
         db        00110000b
         db        01100000b
         db        11111110b
         db        01100000b
         db        00110000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 28
         db        00000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11111110b
         db        00000000b
         db        00000000b

         db        00000000b                ; 29
         db        00100100b
         db        01100110b
         db        11111111b
         db        01100110b
         db        00100100b
         db        00000000b
         db        00000000b

         db        00000000b                ; 30
         db        00011000b
         db        00111100b
         db        01111110b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b

         db        00000000b                ; 31
         db        11111111b
         db        11111111b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 32 " "
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 33 "!"
         db        00111100b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00000000b

         db        01101100b                ; 34 """
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01101100b                ; 35 "#"
         db        01101100b
         db        11111110b
         db        01101100b
         db        11111110b
         db        01101100b
         db        01101100b
         db        00000000b

         db        00011000b                ; 36 "$"
         db        01111110b
         db        11000000b
         db        01111100b
         db        00000110b
         db        11111100b
         db        00011000b
         db        00000000b

         db        00000000b                ; 37 "%"
         db        11000110b
         db        11001100b
         db        00011000b
         db        00110000b
         db        01100110b
         db        11000110b
         db        00000000b

         db        00111000b                ; 38 "&"
         db        01101100b
         db        00111000b
         db        01110110b
         db        11011100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00110000b                ; 39 "'"
         db        00110000b
         db        01100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 40 "("
         db        00110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00000000b

         db        01100000b                ; 41 ")"
         db        00110000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00000000b

         db        00000000b                ; 42 "*"
         db        01100110b
         db        00111100b
         db        11111111b
         db        00111100b
         db        01100110b
         db        00000000b
         db        00000000b

         db        00000000b                ; 43 "+"
         db        00011000b
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 44 ","
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00110000b

         db        00000000b                ; 45 "-"
         db        00000000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 46 "."
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        00000110b                ; 47 "/"
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000000b
         db        10000000b
         db        00000000b

         db        01111100b                ; 48 "0"
         db        11001110b
         db        11011110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00110000b                ; 49 "1"
         db        01110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        11111100b
         db        00000000b

         db        01111000b                ; 50 "2"
         db        11001100b
         db        00001100b
         db        00111000b
         db        01100000b
         db        11001100b
         db        11111100b
         db        00000000b

         db        01111000b                ; 51 "3"
         db        11001100b
         db        00001100b
         db        00111000b
         db        00001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00011100b                ; 52 "4"
         db        00111100b
         db        01101100b
         db        11001100b
         db        11111110b
         db        00001100b
         db        00011110b
         db        00000000b

         db        11111100b                ; 53 "5"
         db        11000000b
         db        11111000b
         db        00001100b
         db        00001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00111000b                ; 54 "6"
         db        01100000b
         db        11000000b
         db        11111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        11111100b                ; 55 "7"
         db        11001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00000000b

         db        01111000b                ; 56 "8"
         db        11001100b
         db        11001100b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        01111000b                ; 57 "9"
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        00011000b
         db        01110000b
         db        00000000b

         db        00000000b                ; 58 ":"
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        00000000b                ; 59 ";"
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00110000b

         db        00011000b                ; 60 "<"
         db        00110000b
         db        01100000b
         db        11000000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00000000b

         db        00000000b                ; 61 "="
         db        00000000b
         db        01111110b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100000b                ; 62 ">"
         db        00110000b
         db        00011000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00000000b

         db        00111100b                ; 63 "?"
         db        01100110b
         db        00001100b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00000000b

         db        01111100b                ; 64 "@"
         db        11000110b
         db        11011110b
         db        11011110b
         db        11011100b
         db        11000000b
         db        01111100b
         db        00000000b

         db        00110000b                ; 65 "A"
         db        01111000b
         db        11001100b
         db        11001100b
         db        11111100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        11111100b                ; 66 "B"
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b

         db        00111100b                ; 67 "C"
         db        01100110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        01100110b
         db        00111100b
         db        00000000b

         db        11111000b                ; 68 "D"
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b

         db        11111110b                ; 69 "E"
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        11111110b
         db        00000000b

         db        11111110b                ; 70 "F"
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00111100b                ; 71 "G"
         db        01100110b
         db        11000000b
         db        11000000b
         db        11001110b
         db        01100110b
         db        00111010b
         db        00000000b

         db        11001100b                ; 72 "H"
         db        11001100b
         db        11001100b
         db        11111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        01111000b                ; 73 "I"
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00011110b                ; 74 "J"
         db        00001100b
         db        00001100b
         db        00001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        11100110b                ; 75 "K"
         db        01100110b
         db        01101100b
         db        01111000b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b

         db        11110000b                ; 76 "L"
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        11000110b                ; 77 "M"
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        11000110b                ; 78 "N"
         db        11100110b
         db        11110110b
         db        11011110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        00111000b                ; 79 "O"
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b

         db        11111100b                ; 80 "P"
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        01111100b                ; 81 "Q"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        01111100b
         db        00001110b
         db        00000000b

         db        11111100b                ; 82 "R"
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b

         db        01111100b                ; 83 "S"
         db        11000110b
         db        11100000b
         db        01111000b
         db        00001110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        11111100b                ; 84 "T"
         db        10110100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        11001100b                ; 85 "U"
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111100b
         db        00000000b

         db        11001100b                ; 86 "V"
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00110000b
         db        00000000b

         db        11000110b                ; 87 "W"
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11111110b
         db        01101100b
         db        00000000b

         db        11000110b                ; 88 "X"
         db        11000110b
         db        01101100b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        00000000b

         db        11001100b                ; 89 "Y"
         db        11001100b
         db        11001100b
         db        01111000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        11111110b                ; 90 "Z"
         db        11000110b
         db        10001100b
         db        00011000b
         db        00110010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        01111000b                ; 91 "["
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01111000b
         db        00000000b

         db        11000000b                ; 92 "\"
         db        01100000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00000010b
         db        00000000b

         db        01111000b                ; 93 "]"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111000b
         db        00000000b

         db        00010000b                ; 94 "^"
         db        00111000b
         db        01101100b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 95 "_"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b

         db        00110000b                ; 96 "`"
         db        00110000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 97 "a"
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        11100000b                ; 98 "b"
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11011100b
         db        00000000b

         db        00000000b                ; 99 "c"
         db        00000000b
         db        01111000b
         db        11001100b
         db        11000000b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00011100b                ; 100 "d"
         db        00001100b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00000000b                ; 101 "e"
         db        00000000b
         db        01111000b
         db        11001100b
         db        11111100b
         db        11000000b
         db        01111000b
         db        00000000b

         db        00111000b                ; 102 "f"
         db        01101100b
         db        01100100b
         db        11110000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00000000b                ; 103 "g"
         db        00000000b
         db        01110110b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        11111000b

         db        11100000b                ; 104 "h"
         db        01100000b
         db        01101100b
         db        01110110b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b

         db        00110000b                ; 105 "i"
         db        00000000b
         db        01110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00001100b                ; 106 "j"
         db        00000000b
         db        00011100b
         db        00001100b
         db        00001100b
         db        11001100b
         db        11001100b
         db        01111000b

         db        11100000b                ; 107 "k"
         db        01100000b
         db        01100110b
         db        01101100b
         db        01111000b
         db        01101100b
         db        11100110b
         db        00000000b

         db        01110000b                ; 108 "l"
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00000000b                ; 109 "m"
         db        00000000b
         db        11001100b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11010110b
         db        00000000b

         db        00000000b                ; 110 "n"
         db        00000000b
         db        10111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        00000000b                ; 111 "o"
         db        00000000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00000000b                ; 112 "p"
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        11110000b

         db        00000000b                ; 113 "q"
         db        00000000b
         db        01110110b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        00011110b

         db        00000000b                ; 114 "r"
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00000000b                ; 115 "s"
         db        00000000b
         db        01111100b
         db        11000000b
         db        01110000b
         db        00011100b
         db        11111000b
         db        00000000b

         db        00010000b                ; 116 "t"
         db        00110000b
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110100b
         db        00011000b
         db        00000000b

         db        00000000b                ; 117 "u"
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00000000b                ; 118 "v"
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00110000b
         db        00000000b

         db        00000000b                ; 119 "w"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11111110b
         db        01101100b
         db        00000000b

         db        00000000b                ; 120 "x"
         db        00000000b
         db        11000110b
         db        01101100b
         db        00111000b
         db        01101100b
         db        11000110b
         db        00000000b

         db        00000000b                ; 121 "y"
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        11111000b

         db        00000000b                ; 122 "z"
         db        00000000b
         db        11111100b
         db        10011000b
         db        00110000b
         db        01100100b
         db        11111100b
         db        00000000b

         db        00011100b                ; 123 "{"
         db        00110000b
         db        00110000b
         db        11100000b
         db        00110000b
         db        00110000b
         db        00011100b
         db        00000000b

         db        00011000b                ; 124 "|"
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        11100000b                ; 125 "}"
         db        00110000b
         db        00110000b
         db        00011100b
         db        00110000b
         db        00110000b
         db        11100000b
         db        00000000b

         db        01110110b                ; 126 "~"
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 127 ""
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        00000000b

         db        01101100b                ; 128 "¬"
         db        01111110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        01100110b
         db        00111100b
         db        00000000b

         db        00000000b                ; 129 ""
         db        11001100b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00001100b                ; 130 "‚"
         db        00011000b
         db        01111000b
         db        11001100b
         db        11111100b
         db        11000000b
         db        01111000b
         db        00000000b

         db        00000011b                ; 131 "Ô"
         db        00011101b
         db        00001110b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        11001100b                ; 132 "„"
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        01101100b                ; 133 "Ò"
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b

         db        01101100b                ; 134 "›"
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        01101100b                ; 135 "Ÿ"
         db        00111000b
         db        01111000b
         db        11001100b
         db        11000000b
         db        11001100b
         db        01111000b
         db        00000000b

         db        01101100b                ; 136 "Ø"
         db        00111000b
         db        01111000b
         db        11001100b
         db        11111100b
         db        11000000b
         db        01111000b
         db        00000000b

         db        01101100b                ; 137 "·"
         db        11111110b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        11111110b
         db        00000000b

         db        00001100b                ; 138 "‘"
         db        11111000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        00001100b                ; 139 "Ö"
         db        01111000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00000011b                ; 140 "–"
         db        01110001b
         db        00110010b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00001100b                ; 141 "’"
         db        01111000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        11000110b                ; 142 "Ž"
         db        00010000b
         db        01111100b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        00001100b                ; 143 "µ"
         db        01111000b
         db        11001100b
         db        11001100b
         db        11111100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        00001100b                ; 144 ""
         db        11111110b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        11111110b
         db        00000000b

         db        01101100b                ; 145 "§"
         db        00111000b
         db        11111100b
         db        10011000b
         db        00110000b
         db        01100100b
         db        11111100b
         db        00000000b

         db        01101100b                ; 146 "¦"
         db        11111110b
         db        10001100b
         db        00011000b
         db        00110010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        01111000b                ; 147 "“"
         db        10000100b
         db        00000000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00000000b                ; 148 "”"
         db        11001100b
         db        00000000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00001100b                ; 149 "à"
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b

         db        00111000b                ; 150 "…"
         db        01101100b
         db        11111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00001100b                ; 151 "é"
         db        11011100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111100b
         db        00000000b

         db        00001100b                ; 152 "ì"
         db        00011000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        11111000b

         db        11000011b                ; 153 "™"
         db        00011000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b

         db        11001100b                ; 154 "š"
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        01101100b                ; 155 "æ"
         db        11111110b
         db        11100000b
         db        01111000b
         db        00001110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000011b                ; 156 "•"
         db        11110001b
         db        01100010b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        00001100b                ; 157 "í"
         db        11011100b
         db        11001100b
         db        01111000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        01101100b                ; 158 "ü"
         db        11111110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b

         db        00000011b                ; 159 "œ"
         db        00110001b
         db        11111110b
         db        00110000b
         db        00110000b
         db        00110100b
         db        00011000b
         db        00000000b

         db        00001100b                ; 160 " "
         db        00011000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00111000b                ; 161 "¡"
         db        00000000b
         db        01110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00001100b                ; 162 "¢"
         db        00011000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00001100b                ; 163 "£"
         db        00011000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        01101100b                ; 164 "å"
         db        00111000b
         db        10111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        01101100b                ; 165 "Õ"
         db        11111110b
         db        11110110b
         db        11011110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        00010000b                ; 166 "Þ"
         db        11101100b
         db        11011100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111100b
         db        00000000b

         db        11111110b                ; 167 "â"
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b

         db        01101100b                ; 168 "ç"
         db        00111000b
         db        01111100b
         db        11000000b
         db        01110000b
         db        00011100b
         db        11111000b
         db        00000000b

         db        01101100b                ; 169 "ý"
         db        00111000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00001100b                ; 170 "ê"
         db        00011000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00001100b                ; 171 "è"
         db        11111110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b

         db        11000011b                ; 172 "/"
         db        11000110b
         db        11001100b
         db        11011011b
         db        00110111b
         db        01101101b
         db        11001111b
         db        00000011b

         db        00111110b                ; 173 "õ"
         db        01100011b
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        10000110b
         db        11111100b

         db        00000000b                ; 174 "®"
         db        00110011b
         db        01100110b
         db        11001100b
         db        01100110b
         db        00110011b
         db        00000000b
         db        00000000b

         db        00000000b                ; 175 "¯"
         db        11001100b
         db        01100110b
         db        00110011b
         db        01100110b
         db        11001100b
         db        00000000b
         db        00000000b

         db        00100010b                ; 176 "°"
         db        10001000b
         db        00100010b
         db        10001000b
         db        00100010b
         db        10001000b
         db        00100010b
         db        10001000b

         db        01010101b                ; 177 "±"
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b

         db        11011101b                ; 178 "²"
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b

         db        00011000b                ; 179 "³"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 180 "´"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 181 "³"
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 182 "º"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 183 "»"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 184 "»"
         db        00000000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 185 "¹"
         db        00110110b
         db        11110110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 186 "º"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 187 "»"
         db        00000000b
         db        11111110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 188 "¼"
         db        00110110b
         db        11110110b
         db        00000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 189 "¼"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 190 "¼"
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 191 "¿"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 192 "À"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 193 "Á"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 194 "Â"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 195 "Ã"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 196 "Ä"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 197 "Å"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 198 "³"
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 199 "º"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 200 "È"
         db        00110110b
         db        00110111b
         db        00110000b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 201 "É"
         db        00000000b
         db        00111111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 202 "Ê"
         db        00110110b
         db        11110111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 203 "Ë"
         db        00000000b
         db        11111111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 204 "Ì"
         db        00110110b
         db        00110111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 205 "Í"
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 206 "Î"
         db        00110110b
         db        11110111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 207 "Í"
         db        00011000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 208 "Ä"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 209 "Í"
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 210 "Ä"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 211 "È"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 212 "È"
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 213 "É"
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 214 "É"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 215 "º"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 216 "Í"
         db        00011000b
         db        11111111b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 217 "Ù"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 218 "Ú"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        11111111b                ; 219 "Û"
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 220 "Ü"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        11110000b                ; 221 "Û"
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b

         db        00001111b                ; 222 "Û"
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b

         db        11111111b                ; 223 "ß"
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 224 "a"
         db        00000000b
         db        01110110b
         db        11011100b
         db        11001000b
         db        11011100b
         db        01110110b
         db        00000000b

         db        00000000b                ; 225 "á"
         db        01111000b
         db        11001100b
         db        11111000b
         db        11001100b
         db        11111000b
         db        11000000b
         db        11000000b

         db        00000000b                ; 226 "Ú"
         db        11111100b
         db        11001100b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b

         db        00000000b                ; 227 "n"
         db        00000000b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b

         db        11111100b                ; 228 "S"
         db        11001100b
         db        01100000b
         db        00110000b
         db        01100000b
         db        11001100b
         db        11111100b
         db        00000000b

         db        00000000b                ; 229 "o"
         db        00000000b
         db        01111110b
         db        11011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b

         db        00000000b                ; 230 "u"
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        11000000b

         db        00000000b                ; 231 "t"
         db        01110110b
         db        11011100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        11111100b                ; 232 "o"
         db        00110000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00110000b
         db        11111100b

         db        00111000b                ; 233 "O"
         db        01101100b
         db        11000110b
         db        11111110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b

         db        00111000b                ; 234 "O"
         db        01101100b
         db        11000110b
         db        11000110b
         db        01101100b
         db        01101100b
         db        11101110b
         db        00000000b

         db        00011100b                ; 235 "d"
         db        00110000b
         db        00011000b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00000000b                ; 236 "o"
         db        00000000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00000000b
         db        00000000b

         db        00000110b                ; 237 "0"
         db        00001100b
         db        01111110b
         db        11011011b
         db        11011011b
         db        01111110b
         db        01100000b
         db        11000000b

         db        00111000b                ; 238 "E"
         db        01100000b
         db        11000000b
         db        11111000b
         db        11000000b
         db        01100000b
         db        00111000b
         db        00000000b

         db        01111000b                ; 239 "N"
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        00000000b                ; 240 "="
         db        01111110b
         db        00000000b
         db        01111110b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b

         db        00011000b                ; 241 "+"
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        01111110b
         db        00000000b

         db        01100000b                ; 242 ">"
         db        00110000b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00000000b
         db        11111100b
         db        00000000b

         db        00011000b                ; 243 "<"
         db        00110000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00000000b
         db        11111100b
         db        00000000b

         db        00001110b                ; 244 "Ú"
         db        00011011b
         db        00011011b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 245 "Ù"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11011000b
         db        11011000b
         db        01110000b

         db        00011000b                ; 246 "ö"
         db        00011000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        00000000b                ; 247 "="
         db        01110110b
         db        11011100b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b

         db        00111000b                ; 248 "ø"
         db        01101100b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 249 "ú"
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 250 "ú"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001111b                ; 251 "o"
         db        00001100b
         db        00001100b
         db        00001100b
         db        11101100b
         db        01101100b
         db        00111100b
         db        00011100b

         db        01011000b                ; 252 "n"
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01110000b                ; 253 "2"
         db        10011000b
         db        00110000b
         db        01100000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 254
         db        00000000b
         db        00111100b
         db        00111100b
         db        00111100b
         db        00111100b
         db        00000000b
         db        00000000b

         db        00000000b                ; 255 "ÿ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

; -----------------------------------------------------------------------------
;        z hlav¡ vstupn¡ho souboru obr zku SCR
; -----------------------------------------------------------------------------

Zahlavi  label     byte                   ;* z hlav¡ souboru SCREEN (d‚lka 16 B)
Ident    db        'SCR'                    ; identifikace souboru displeje
Verze    db        1                        ; verze souboru
Sirka    dw        0                        ; ç¡ýka vìýezu (pozic, bod…)
Vyska    dw        0                        ; vìçka vìýezu (linek)
Rovin    db        0                        ; poŸet barevnìch rovin
         db        0                        ; (rezervov no)
Pozadi   db        0                        ; barva pozad¡
Komentar db        0                        ; poŸet bajt… koment ýe + informace
Palet    dw        0                        ; poŸet bajt… za z hlav¡m
VMod     db        0                        ; videom¢d displeje
Param    db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textovì videom¢d
                                            ;  bit 2: 1=paraleln¡ ulo§en¡ barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
KonHl    label     byte                     ; konec z hlav¡

; -----------------------------------------------------------------------------
;        vìstupn¡ soubor obr zku ICO
; -----------------------------------------------------------------------------

Zahlavi2 label     byte
                                           ;* z hlav¡ souboru
         dw        0                        ; (rezervov no)
         dw        1                        ; verze souboru
         dw        1                        ; poŸet obr zk… v souboru
         db        SIRX                     ; ç¡ýka ikony (bod…)
         db        VYSY                     ; vìçka ikony (bod…)
         db        COLS                     ; poŸet barev ikony
         db        0                        ; (rezervov no)
         dw        0,0                      ; (rezervov no)
         dd        40 + 4*COLS + SIRX*VYSY*COLSB/8 + SIRX*VYSY/8 ; velikost dat
         dd        22                       ; velikost z hlav¡ souboru

                                          ;* z hlav¡ obr zku
         dd        40                       ; velikost z hlav¡ obr zku
         dd        SIRX                     ; ç¡ýka a vìçka plochy obr zku
         dd        4*COLS                   ; velikost tabulky palet
         dw        1
         dd        COLSB                    ; poŸet bit… na bod
         dw        0
         dd        SIRX*VYSY*COLSB/8 + SIRX*VYSY/8 ; velikost data+maska obr zku
         dd        0,0,0,0

                                          ;* tabulka palet (poýad¡ B/G/R/0)
         db          0,  0,  0,  0          ;  0: Ÿern 
         db          0,  0,128,  0          ;  1: tmavØ Ÿerven 
         db          0,128,  0,  0          ;  2: tmavØ zelen 
         db          0,128,128,  0          ;  3: tmavØ §lut 
         db        128,  0,  0,  0          ;  4: tmavØ modr 
         db        128,  0,128,  0          ;  5: tmavØ purpurov 
         db        128,128,  0,  0          ;  6: tmavØ azurov 
         db        128,128,128,  0          ;  7: tmavØ çed 
         db        192,192,192,  0          ;  8: svØtle çed 
         db          0,  0,255,  0          ;  9: svØtle Ÿerven 
         db          0,255,  0,  0          ; 10: svØtle zelen 
         db          0,255,255,  0          ; 11: svØtle §lut 
         db        255,  0,  0,  0          ; 12: svØtle modr 
         db        255,  0,255,  0          ; 13: svØtle purpurov 
         db        255,255,  0,  0          ; 14: svØtle azurov 
         db        255,255,255,  0          ; 15: b¡l 

OutBuff  db        SIRX*VYSY*COLSB/8 dup(0) ; vìstupn¡ buffer

Maska    db        SIRX*VYSY/8 dup(0)       ; maska obr zku

Zahlav20 label     byte

OutPal   label     byte                     ; palety vìstupn¡ch barev
; ------             B   G   R

         db          0,  0,  0              ;  0: Ÿern 
         db          0,  0, 32              ;  1: tmavØ Ÿerven 
         db          0, 32,  0              ;  2: tmavØ zelen 
         db          0, 32, 32              ;  3: tmavØ §lut 
         db         32,  0,  0              ;  4: tmavØ modr 
         db         32,  0, 32              ;  5: tmavØ purpurov 
         db         32, 32,  0              ;  6: tmavØ azurov 
         db         32, 32, 32              ;  7: tmavØ çed 
         db         48, 48, 48              ;  8: svØtle çed 
         db          0,  0, 63              ;  9: svØtle Ÿerven 
         db          0, 63,  0              ; 10: svØtle zelen 
         db          0, 63, 63              ; 11: svØtle §lut 
         db         63,  0,  0              ; 12: svØtle modr 
         db         63,  0, 63              ; 13: svØtle purpurov 
         db         63, 63,  0              ; 14: svØtle azurov 
         db         63, 63, 63              ; 15: b¡l 

; -----------------------------------------------------------------------------
;        komprese
; -----------------------------------------------------------------------------

; ések shodn‚ho opakovan‚ho bajtu (komrese):
KompCit  dw        0                        ; Ÿ¡taŸ shodn‚ho bajtu
KompChar db        0                        ; znak k opakov n¡

; ések neshodnìch bajt… (nen¡ komprese):
KompBNum dw        0                        ; poŸet bajt… v kompresn¡m bufferu
KompBuff db        255 dup(0)               ; kompresn¡ buffer

; Pý¡znak £seku komprese
KompPar  db        1                        ; 1=pý¡znak kompresn¡ho m¢du

Palety   label     byte                     ; buffer k naŸten¡ palet VGA
PaletCGA db        60h                      ; paleta CGA
PaletEGA db        0,1,2,3,4,5,14h,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0
PaletEG0 db        8                        ; adresa palet EGA
PaletVGA db        256*3 dup(0)             ; palety VGA

UvTxt    db        'SCR2ICO V1.03 - konverze obrazku SCR na ICO; (c) Miroslav Nemecek',13,10
         db        13,10
         db        'Upozorneni: zkonvertuji vsechny soubory SCR v aktualnim',13,10
         db        '            adresari na soubory ICO se stejnym jmenem !',13,10
         db        13,10
         db        'Stisknete MEZERU, jina klavesa = preruseni...',13,10,'$'

PrerTxt  db        'Preruseno...',13,10,'$'

MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'
ReadTxt  db        'Chyba cteni ze vstupniho souboru SCR !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru ICO !',13,10,'$'
SCRTxt   db        'Neplatny soubor SCR !',13,10,'$'

InpIdnt  dw        0                        ; identifik tor vstupn¡ho souboru

Soubory  db        '*.SCR',0                ; specifikace soubor…

DTA      label     byte                     ; buffer DTA
         db        30 dup(0)                ; parametry souboru
Soubor   db        14 dup(0)                ; buffer jm‚na souboru
Soubor2  db        14 dup(0)                ; buffer jm‚na vìstupn¡ho souboru

; -----------------------------------------------------------------------------
;        ukazatele pro konverzi obr zku
; -----------------------------------------------------------------------------

;TopX     db        3                        ; poŸ teŸn¡ pozice X
;TopY     db        3                        ; poŸ teŸn¡ pozice Y
DelX     db        6                        ; dØlitel ve smØru X
DelY     db        6                        ; dØlitel ve smØru Y

ByteRow  dw        80                       ; poŸet bajt… na linku X
BytePic  dw        80*350                   ; poŸet bajt… na jednu rovinu barev

; -----------------------------------------------------------------------------
;        Buffery
; -----------------------------------------------------------------------------

DatBeg   dw        0                        ; segment zaŸ tku datov‚ho bufferu
DatEnd   dw        0                        ; segment konce datov‚ho bufferu

NumBuf   dw        0                        ; poŸet bajt… v bufferu
Buffer   db        BUFSIZE dup(?)           ; vstupn¡/vìstupn¡ datovì buffer

         db        200h dup(?)              ; rezerva pro z sobn¡k
Zasobnik label     byte                     ; konec z sobn¡ku

Code     ENDS
         END       Start

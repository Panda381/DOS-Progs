
SIRX     EQU       320/5                    ; ®°©ka obr†zku PIV (bodñ)
ISIRX    EQU       SIRX-6                   ; vnit©n° ®°©ka obr†zku PIV (bodñ)

VYSY     EQU       200/5                    ; vò®ka obr†zku PIC (bodñ)
IVYSY    EQU       VYSY-6                   ; vnit©n° vò®ka obr†zku PIC (bodñ)

BufSize  EQU       800h                     ; velikost diskovÇho bufferu
                                            ; (mus° bòt alespo§ 1+18+3*256=786
                                            ;  pro palety)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen° £vodn°ho textu

Start:   mov       dx,offset UvTxt          ; £vodn° text
         mov       ah,9
         int       21h

; ------ implicitn° palety VGA

         cld
         mov       di,offset PaletVGA       ; tabulka palet VGA
         mov       cx,256
Start02: mov       al,0
         sub       al,cl                    ; á°slo poloëky 0 ...

         shr       al,1                     ; modr†
         jnc       Start03
         mov       byte ptr es:[di+2],2ah   ; modr† sloëka

Start03: shr       al,1                     ; zelen†
         jnc       Start04
         mov       byte ptr es:[di+1],2ah   ; zelen† sloëka

Start04: shr       al,1                     ; áerven†
         jnc       Start05
         mov       byte ptr es:[di],2ah     ; áerven† sloëka

Start05: shr       al,1                     ; sekund†rn° modr†
         jnc       Start06
         add       byte ptr es:[di+2],15h   ; sekund†rn° modr† sloëka

Start06: shr       al,1                     ; sekund†rn° zelen†
         jnc       Start07
         add       byte ptr es:[di+1],15h   ; sekund†rn° zelen† sloëka

Start07: shr       al,1                     ; sekund†rn° áerven†
         jnc       Start08
         add       byte ptr es:[di],15h     ; sekund†rn° áerven† sloëka

Start08: add       di,3
         loop      Start02

; ------ p©°prava k dek¢dov†n° parametrñ

         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       bh,0
         mov       bl,ds:[si-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       ds:[si+bx],bh            ; oznaáen° konce p©°kazovÇho ©†dku

; ------ rozbor jmÇna vstupn°ho souboru

         call      RozbNam                  ; rozbor jmÇna vstupn°ho souboru
         jnc       Start1                   ; jmÇno zad†no OK

; ------ chyba zad†n° parametrñ - zobrazen° n†povàdy

Chyba0:  mov       dx,offset HelpTxt        ; text - n†povàda
Chyba:   mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
         int       20H

; ------ otev©en° vstupn°ho souboru

Start1:  mov       ax,3d00h                 ; otev©en° pro áten°
         int       21h                      ; otev©en° souboru pro áten°
         mov       dx,offset FndTxt         ; text - soubor nenalezen
         jc        Chyba                    ; chyba - soubor nenalezen
         mov       ds:[InpIdnt],ax          ; identifik†tor vstupn°ho souboru

; ------ rozbor jmÇna vòstupn°ho souboru

         call      RozbNam                  ; rozbor jmÇna vòstupn°ho souboru
         jc        Chyba0                   ; chyba zad†n° parametrñ

; ------ rozbor textu k zobrazen°

         call      RozbSpc                  ; vypu®tàn° mezer
         jc        Start4                   ; nen° dal®° text
         cmp       al,'"'                   ; uvozovky ?
         jne       Start2
         inc       si
Start2:  mov       ds:[AdrText],si          ; adresa textu
Start3:  call      RozbCh                   ; dal®° znak
         jc        Start4                   ; nen° dal®° znak
         cmp       al,'"'
         je        Start4                   ; konec textu
         inc       byte ptr ds:[DelText]    ; zvò®en° dÇlky textu
         jmp       short Start3

; ------ vytvo©en° vòstupn°ho souboru

Start4:  mov       ah,3ch
         xor       cx,cx                    ; atributy souboru
         int       21h                      ; vytvo©en° vòstupn°ho souboru
         mov       dx,offset CreaTxt        ; text - nelze vytvo©it
         jc        Chyba                    ; chyba - vòst.soubor nelze vytvo©it
         mov       ds:[OutIdnt],ax          ; identifik†tor vòstupn°ho souboru

; ------ p©edefinov†n° ukazatele z†sobn°ku

         mov       dx,offset MemTxt         ; text - nedostatek pamàti
         cmp       sp,offset Zasobnik       ; je z†sobn°k OK ?
         jbe       Chyba                    ; chyba - nedostatek pamàti
         mov       sp,offset Zasobnik       ; p©edefinov†n° z†sobn°ku

; ------ zmen®en° segmentu programu ES

         mov       ah,4ah
         mov       bx,(offset(Zasobnik-Start)+10fh)/16 ; velikost programu
         int       21h                      ; nastaven° velikosti segmentu
         jc        Chyba                    ; nàjak† chyba

; ------ vytvo©en° datovÇho bloku

         mov       bx,-1                    ; fiktivn° nesmysln† velikost
         mov       ah,48h
         int       21h                      ; poskytnut° volnÇ pamàti
         mov       ah,48h
         int       21h                      ; p©idàlen° maxim†ln°ho bloku
         jc        Chyba                    ; nàjak† chyba

; ------ kontrola velikosti bloku

         cmp       bx,200h                  ; minim†ln° velikost asi tak 8 KB
         jb        Chyba                    ; chyba - blok je p©°li® malò
         mov       ds:[DatBeg],ax           ; adresa datovÇho bufferu (zaá†tek)
         add       ax,bx                    ; adresa konce bufferu
         mov       ds:[DatEnd],ax           ; segment konce bufferu

; ------ naáten° vstupn°ho souboru do pamàti

         call      ReadF                    ; naáten° souboru

; ------ p©°prava parametrñ pro konverzi

         call      PrepKonv                 ; p©°prava konverze

; ------ proveden° konverze souboru

         mov       di,offset Obrazek        ; ukl†dac° adresa
         push      ds
         pop       es
         xor       bx,bx                    ; BH <- 0 ukazatel Y
         mov       ch,IVYSY                 ; vnit©n° vò®ka obr†zku
Konv1:   mov       bl,0                     ; BL <- 0 ukazatel X
         mov       cl,ISIRX                 ; vnit©n° ®°©ka obr†zku
Konv2:   call      Get0Bod                  ; poskytnut° bodu -> DL, DH, AL
         call      SetBod                   ; nastaven° bodu
         inc       bx
         dec       cl
         jnz       Konv2

         inc       bh
         dec       ch
         jnz       Konv1

; ------ dek¢dov†n° textu v obr†zku

         mov       cl,ds:[DelText]          ; dÇlka textu
         cmp       cl,(ISIRX-1)/8           ; maxim†ln° dÇlka textu
         jbe       Konv3                    ; dÇlka je OK
         mov       cl,(ISIRX-1)/8           ; omezen° dÇlky textu

Konv3:   mov       ch,0

         or        cx,cx
         jnz       Konv31
         jmp       Konv8                    ; nen° ë†dnò text

Konv31:  mov       si,ds:[AdrText]          ; adresa textu

         mov       al,cl
         shl       al,1
         shl       al,1
         shl       al,1                     ; ®°©ka textu (bodñ)

         mov       bh,IVYSY - 8 + 1         ; poá†teán° linka
         mov       bl,ISIRX                 ; maxim†ln° poá†teán° pozice
         sub       bl,al                    ; poá†teán° pozice textu

         push      bx
         push      cx

         mov       cl,8
         mov       al,63
         mov       dx,63*256 + 63           ; b°l† barva

Konv32:  call      SetBod                   ; poá†teán° sloupeáek
         inc       bh
         loop      Konv32

         pop       cx
         pop       bx
         inc       bx

Konv4:   cld
         lodsb                              ; znak k zobrazen°
         push      bx
         push      cx
         push      si

         mov       cl,8                     ; poáet linek
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1
         add       ax,offset Fonty          ; adresa znaku ve fontech
         xchg      ax,si                    ; adresa znaku

Konv5:   cld
         lodsb                              ; linka k zobrazen°

         push      cx
         mov       cl,8                     ; poáet bodñ
Konv6:   shl       al,1                     ; je bod nastaven ?
         push      ax
         mov       al,63
         mov       dx,63*256 + 63           ; b°l† barva
         jnc       Konv7                    ; bod nen° nastaven
         mov       al,15
         mov       dl,15                    ; jinak je jasnà áerven† barva

Konv7:   call      SetBod                   ; zobrazen° bodu
         inc       bx                       ; zvò®en° pozice bodu
         pop       ax
         loop      Konv6
         pop       cx

         sub       bl,8                     ; n†vrat pozice znaku
         inc       bh                       ; zvò®en° linky
         loop      Konv5                    ; dal®° linka

         pop       si
         pop       cx
         pop       bx
         add       bl,8                     ; zvò®en° pozice
         loop      Konv4                    ; dal®° znak

; ------ z†pis vòstupn°ho souboru

Konv8:   call      WritF                    ; z†pis souboru


         int       20h

; *****************************************************************************
;
;                            Konverze obr†zku
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        p©°prava parametrñ konverze
; -----------------------------------------------------------------------------

PrepKonv PROC      NEAR

; ------ poáet bajtñ na ©†dek

         mov       ax,ds:[Sirka]            ; poáet bodñ na ©†dek
         test      byte ptr ds:[Param],2    ; je textovò m¢d ?
         jnz       PrepK3                   ; je textovò m¢d
         test      byte ptr ds:[Param],4    ; je paraleln° uloëen° barev ?
         jnz       PrepK2                   ; je paraleln° uloëen° barev
PrepK1:  add       ax,7                     ; zaokrouhlen°
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na bajty
         jmp       short PrepK3             ; poáet bajtñ na ©†dek pro EGA

PrepK2:  cmp       byte ptr ds:[Rovin],2    ; je m¢d CGA 4 barvy ?
         jb        PrepK1                   ; jsou 2 barvy
         ja        PrepK3                   ; je m¢d 8 rovin
         add       ax,3
         shr       ax,1
         shr       ax,1
PrepK3:  mov       ds:[ByteRow],ax          ; poáet bajtñ na ©†dek

; ------ poáet bajtñ na rovinu

         mul       word ptr ds:[Vyska]      ; poáet bajtñ na rovinu
         or        dx,dx
         jz        PrepK4
         mov       ax,-1
PrepK4:  mov       ds:[BytePic],ax          ; poáet bajtñ na rovinu

; ------ korekce rozmàrñ pro textovò m¢d

         test      byte ptr ds:[Param],2    ; je textovò m¢d ?
         jz        PrepK5                   ; nen° textovò m¢d
         mov       cl,3
         shl       word ptr ds:[Sirka],cl
         shl       word ptr ds:[Vyska],cl

; ------ dàlitel ve smàru X

PrepK5:  xor       dx,dx
         mov       ax,ds:[Sirka]            ; ®°©ka obr†zku
         mov       bx,ISIRX                 ; vnit©n° ®°©ka obr†zku
         div       bx                       ; dàlitel X
         or        ax,ax
         jnz       PrepK6
         inc       ax
PrepK6:  cmp       ax,255
         jbe       PrepK7
         mov       al,255
PrepK7:  ;cmp       al,1
         ;jbe       PrepK72
         ;dec       ax
PrepK72: mov       ds:[DelX],al             ; dàlitel X

; ------ dàlitel ve smàru Y

         xor       dx,dx
         mov       ax,ds:[Vyska]            ; vò®ka obr†zku
         mov       bx,IVYSY                 ; vnit©n° vò®ka obr†zku
         div       bx                       ; dàlitel Y
         or        ax,ax
         jnz       PrepK8
         inc       ax
PrepK8:  cmp       ax,255
         jbe       PrepK9
         mov       al,255
PrepK9:  ;cmp       al,1
         ;jbe       PrepK92
         ;dec       ax
PrepK92: mov       ds:[DelY],al             ; dàlitel Y
         ret

PrepKonv ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bodu pro obr†zek
; -----------------------------------------------------------------------------
; VSTUP: BL=pozice
;        BH=linka
; VùSTUP: AL=modr† 0 aë 63
;         DL=zelen† 0 aë 63
;         DH=áerven† 0 aë 63
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) poáet bodñ celkem (dàlitel vòsledku)
;                   SS:[BP-6] (4) st©adaá modrÇ
;                   SS:[BP-10] (4) st©adaá zelenÇ
;                   SS:[BP-14] (4) st©adaá áervenÇ
; -----------------------------------------------------------------------------

Get0Bod  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,14                    ; lok†ln° promànnÇ

; ------ poáet bodñ celkem

         mov       al,ds:[DelX]             ; dàlitel X
         mul       byte ptr ds:[DelY]       ; kr†t dàlitel Y
         mov       ss:[bp-2],ax             ; dàlitel celkem

; ------ nulov†n° st©adaáñ

         xor       ax,ax
         mov       ss:[bp-4],ax
         mov       ss:[bp-6],ax             ; modr†
         mov       ss:[bp-8],ax
         mov       ss:[bp-10],ax            ; zelen†
         mov       ss:[bp-12],ax
         mov       ss:[bp-14],ax            ; áerven†

; ------ p©epoáet sou©adnic na sou©adnice v obr†zku

         mov       al,bl                    ; pozice
         mov       ah,0
         mul       word ptr ds:[Sirka]
         mov       cx,ISIRX                 ; vnit©n° ®°©ka obr†zku
         div       cx                       ; pozice ve smàru X
         xchg      ax,bx                    ; BX <- pozice v obr†zku SCR

         mov       al,ah                    ; linka
         mov       ah,0
         mul       word ptr ds:[Vyska]
         mov       cl,IVYSY                 ; vnit©n° vò®ka obr†zku
         div       cx                       ; pozice ve smàru Y
         xchg      ax,si                    ; SI <- linka v obr†zku SCR

; ------ nast©†d†n° bodñ

         mov       ch,ds:[DelY]             ; dàlitel ve smàru Y
Get0Bod1:push      bx
         mov       cl,ds:[DelX]             ; dàlitel ve smàru X
Get0Bod2:call      GetBod                   ; poskytnut° bodu
         mov       ah,0
         add       ss:[bp-6],ax             ; modr†
         adc       ss:[bp-6+2],ah
         mov       al,dl
         add       ss:[bp-10],ax            ; zelen†
         adc       ss:[bp-10+2],ah
         mov       al,dh
         add       ss:[bp-14],ax            ; áerven†
         adc       ss:[bp-14+2],ah
         inc       bx                       ; zvò®en° ukazatele pozice
         dec       cl                       ; á°taá bodñ ve smàru X
         jnz       Get0Bod2                 ; dal®° bod
         pop       bx
         inc       si                       ; zvò®en° linky
         dec       ch
         jnz       Get0Bod1                 ; dal®° linka

; ------ vòpoáet prñmàru barev

         mov       ax,ss:[bp-6]             ; modr†
         mov       dx,ss:[bp-6+2]
         div       word ptr ss:[bp-2]       ; prñmàr modrÇ
         push      ax                       ; AL = modr†

         mov       ax,ss:[bp-10]            ; zelen†
         mov       dx,ss:[bp-10+2]
         div       word ptr ss:[bp-2]       ; prñmàr zelenÇ
         push      ax                       ; AL = zelen†

         mov       ax,ss:[bp-14]            ; áerven†
         mov       dx,ss:[bp-14+2]
         div       word ptr ss:[bp-2]       ; prñmàr áervenÇ

         pop       dx                       ; DL = zelen†
         mov       dh,al                    ; DH <- áerven†
         pop       ax                       ; AK = modr†

; ------ n†vrat registrñ

         mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

Get0Bod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bodu z SCR
; -----------------------------------------------------------------------------
; VSTUP: BX=pozice
;        SI=linka
; VùSTUP: AL=modr† 0 aë 63
;         DL=zelen† 0 aë 63
;         DH=áerven† 0 aë 63
; -----------------------------------------------------------------------------

GetBod   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         xchg      ax,si                    ; AX <- linka v obr†zku
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
         xor       di,di                    ; adresa prvn° roviny

; ------ poskytnut° bodu v textovÇm m¢du

         test      byte ptr ds:[Param],2    ; je textovò m¢d ?
         jz        GetBod1                  ; nen° textovò m¢d
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; ©†dek
         mul       word ptr ds:[ByteRow]    ; offset ©†dku v rovinà
         xchg      ax,si                    ; SI <- offset linky v rovinà
         call      GetTBod                  ; poskytnut° textovÇho bodu
         jmp       short GetBod6            ; konverze barvy AL

; ------ poskytnut° bodu v m¢du EGA 1 barva

GetBod1: mul       word ptr ds:[ByteRow]    ; offset linky v rovinà
         xchg      ax,si                    ; SI <- offset linky v rovinà

         cmp       byte ptr ds:[Rovin],1    ; je 1 rovina ?
         jne       GetBod12                 ; nen° 1 rovina
         call      GetEBod
         cmp       al,0
         je        GetBod6
         mov       al,15
         jmp       short GetBod6

; ------ poskytnut° bodu v m¢du CGA 4 barvy

GetBod12:test      byte ptr ds:[Param],4    ; je paraleln° uloëen° barev ?
         jz        GetBod5                  ; nen° paraleln° uloëen° barev - EGA
         cmp       byte ptr ds:[Rovin],2    ; jsou 4 barvy ?
         jne       GetBod7                  ; nejsou 4 roviny
         call      GetCBod                  ; poskytnut° m¢du CGA

; ------ konverze barvy CGA (AL = 0 aë 3) na barvu EGA (0 aë 15)

GetBod2: shl       al,1                     ; 0,2,4,6 implicitn° barvy
         jnz       GetBod3                  ; nen° áern† barva
         mov       al,ds:[PaletCGA]         ; paleta CGA
         and       al,0fh                   ; barva pozad°
         jmp       short GetBod6            ; konverze na palety VGA

GetBod3: test      byte ptr ds:[PaletCGA],20h ; je modr† sloëka ?
         jz        GetBod4                  ; nen° modr† sloëka
         inc       ax                       ; p©id†n° modrÇ sloëky

GetBod4: test      byte ptr ds:[PaletCGA],10h ; je intenzivn° pop©ed° ?
         jz        GetBod6                  ; nen° intenzivn° pop©ed°
         add       al,8                     ; intenzivn° barva
         jmp       short GetBod6            ; konverze na palety VGA

; ------ poskytnut° bodu v m¢du EGA a v m¢du CGA 1 barva -> AL (0 aë 15)

GetBod5: call      GetEBod                  ; poskytnut° m¢du EGA

; ------ konverze barvy v m¢du EGA (AL = 0 aë 15) na paletu VGA (AL = 0 aë 255)

GetBod6: mov       bl,al
         mov       bh,0                     ; BX = offset v tabulce palet
         mov       al,ds:[bx+PaletEGA]      ; odpov°daj°c° paleta
         mov       ah,ds:[PaletEG0]         ; adresace palet
         and       ah,0c0h                  ; nejvy®®° 2 bity adresy
         or        al,ah                    ; korekce adresy
         mov       ah,ds:[PaletEG0]
         test      ah,1                     ; plat° bity 4 a 5 ?
         jz        GetBod8                  ; bity 4 a 5 plat° OK
         and       ah,30h                   ; vy®®° 2 bity
         and       al,not 30h
         or        al,ah                    ; novÇ 2 bity adresy
         jmp       short GetBod8            ; konverze na barevnÇ sloëky

; ------ poskytnut° bodu v m¢du VGA 8 rovin -> AL

GetBod7: mov       al,63                    ; n†hradn° barva - b°l†
         mov       dx,63*256 + 63
         cmp       byte ptr ds:[Rovin],8
         jne       GetBod9                  ; jinak neplatnò bod
         call      GetVBod                  ; poskytnut° m¢du VGA

; ------ konverze barvy v m¢du VGA (AL = 0 aë 255) na barevnÇ sloëky

GetBod8: mov       ah,0
         mov       bx,ax                    ; á°slo barvy
         shl       ax,1
         add       ax,offset PaletVGA       ; palety VGA
         add       bx,ax                    ; adresa v tabulce palet
         mov       al,ds:[bx+2]             ; modr†
         mov       dl,ds:[bx+1]             ; zelen†
         mov       dh,ds:[bx]               ; áerven†

; ------ n†vrat registrñ

GetBod9: pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

GetBod   ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bodu v textovÇm m¢du
; -----------------------------------------------------------------------------

GetTBod  PROC      NEAR

         mov       cl,bl                    ; pozice
         and       cl,7                     ; poáet rotac° X

         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; pozice na ©†dku
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
         jc        GetTBod4                 ; plat° barva pop©ed°

         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; plat° barva pozad°

GetTBod4:and       al,0fh
         ret

GetTBod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bodu v m¢du CGA
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
         shl       cx,1                     ; poáet rotac° * 2
         rol       ax,cl                    ; rotace bodu
         and       al,3                     ; bod na poëadovanÇ pozici
         ret

GetCBod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bodu v m¢du EGA
; -----------------------------------------------------------------------------

GetEBod  PROC      NEAR

         mov       ch,ds:[Rovin]            ; poáet barevnòch rovin
         mov       cl,bl
         and       cl,7                     ; offset bodu
         inc       cx
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; offset bajtu na lince
         add       di,si                    ; adresa linky
         add       di,bx                    ; adresa bajtu
         mov       bx,8000h                 ; st©adaá

GetEBod1:mov       al,es:[di]               ; bajt
         shl       al,cl                    ; rotace bodu do CF
         rcr       bx,1                     ; p©enos bodu do st©adaáe

         add       di,ds:[BytePic]          ; adresa dal®° roviny
         jnc       GetEBod2

         mov       ax,es
         add       ax,1000h
         mov       es,ax

GetEBod2:dec       ch                       ; á°taá rovin
         jnz       GetEBod1

GetEBod3:shr       bx,1
         jnc       GetEBod3                 ; doraëen° bitñ
         xchg      ax,bx                    ; AL <- barva
         ret

GetEBod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bodu v m¢du VGA
; -----------------------------------------------------------------------------

GetVBod  PROC      NEAR

         add       si,di                    ; adresa linky
         add       si,bx                    ; adresa bodu
         mov       al,es:[si]               ; poëadovanò bod
         ret

GetVBod  ENDP

; -----------------------------------------------------------------------------
;        nastaven° bodu do obr†zku
; -----------------------------------------------------------------------------
; VSTUP: AL=modr† 0 aë 63
;        DL=zelen† 0 aë 63
;        DH=áerven† 0 aë 63
;        BL=pozice
;        BH=linka
; -----------------------------------------------------------------------------
;˛
SetBod   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ vòpoáet adresy bajtu

         push      ax
         add       bl,ds:[TopX]             ; poá†tek X
         add       bh,ds:[TopY]             ; poá†tek Y
         mov       al,SIRX                  ; poáet bajtñ na linku
         mul       bh                       ; p©epoáet linky na bajty
         add       ax,offset Obrazek        ; adresa linky
         mov       bh,0
         add       ax,bx                    ; adresa bajtu
         xchg      ax,si                    ; SI <- adresa linky
         pop       ax

; ------ korekce barev

         push      cx
         mov       cx,6*256 + 6
         mul       ch
         shr       ax,cl

         push      ax                       ; modr†

         inc       ch                       ; 7
         mov       al,dl                    ; zelen†
         mul       ch
         shr       ax,cl
         mov       dl,al                    ; zelen†
         dec       ch

         mov       al,dh                    ; áerven†
         mul       ch
         shr       ax,cl                    ; áerven†

         inc       ch
         mul       ch                       ; posun áervenÇ
         add       al,dl                    ; p©id†n° zelenÇ
         adc       ah,0
         dec       ch
         mul       ch                       ; posun zelenÇ

         pop       cx
         add       al,cl                    ; p©id†n° modrÇ
         adc       ah,0

         pop       cx

; ------ nastaven° bodu

SetBod2: mov       ds:[si],al               ; nastaven° bodu

; ------ n†vrat registrñ

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
;                       Naáten° vstupn°ho souboru
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        naáten° vstupn°ho souboru
; -----------------------------------------------------------------------------

ReadF    PROC      NEAR

; ------ naáten° z†hlav° souboru

         mov       bx,ds:[InpIdnt]          ; vstupn° identifik†tor
         mov       dx,offset Zahlavi        ; z†hlav° souboru
         mov       cx,offset(KonHl-Zahlavi) ; velikost z†hlav°
         mov       ah,3fh
         int       21h                      ; naáten° z†hlav° souboru
         jc        ReadF1                   ; chyba

; ------ kontrola z†hlav° souboru

         cmp       ax,cx
         jne       ReadF1                   ; nesouhlas° velikost
         cmp       word ptr ds:[Sirka],0
         je        ReadF1
         cmp       word ptr ds:[Vyska],0
         je        ReadF1
         cmp       byte ptr ds:[Rovin],0
         je        ReadF1
         cmp       word ptr ds:[Ident],"CS"
         jne       ReadF1                   ; z†hlav° nesouhlas°
         cmp       word ptr ds:[Ident+2],1*256 + "R"
         je        ReadF2                   ; z†hlav° je OK

; ------ chyba - neplatnò soubor SCR

ReadF1:  mov       dx,offset SCRTxt
         jmp       Chyba

; ------ naáten° koment†©e (a ignorov†n°)

ReadF2:  mov       ch,0
         mov       cl,ds:[Komentar]         ; poáet bajtñ koment†©e
         mov       si,ds:[Palet]            ; poáet bajtñ za z†hlav°m
         jcxz      ReadF21                  ; nen° koment†©
         mov       dx,offset Buffer         ; vstupn° datovò buffer
         mov       ah,3fh
         int       21h                      ; naáten° koment†©e
         sub       si,cx

; ------ naáten° palety CGA

ReadF21: test      byte ptr ds:[Param],10h  ; jsou palety CGA ?
         jz        ReadF22                  ; nejsou palety CGA
         mov       cl,1
         mov       dx,offset PaletCGA       ; palety CGA
         mov       ah,3fh
         int       21h                      ; naáten° palety CGA
         sub       si,cx

; ------ naáten° palet EGA

ReadF22: test      byte ptr ds:[Param],20h  ; jsou palety EGA ?
         jz        ReadF23                  ; nejsou palety EGA
         mov       cl,18
         mov       dx,offset PaletEGA
         mov       ah,3fh
         int       21h                      ; naáten° palet EGA
         sub       si,cx

; ------ naáten° palet VGA

ReadF23: test      byte ptr ds:[Param],40h  ; jsou palety VGA ?
         jz        ReadF24                  ; nejsou palety VGA
         mov       cx,3*256
         mov       dx,offset PaletVGA
         mov       ah,3fh
         int       21h                      ; naáten° palet VGA
         sub       si,cx

; ------ naáten° zbyku z†hlav°

ReadF24: mov       dx,offset Buffer
         cmp       si,BufSize
         jbe       ReadF25
         mov       si,offset BufSize
ReadF25: mov       cx,si
         jcxz      ReadF3
         mov       ah,3fh
         int       21h                      ; naáten° zbytku z†hlav°

; ------ p©°prava ukazatelñ k naáten° souboru

ReadF3:  mov       es,ds:[DatBeg]           ; zaá†tek bufferu
         xor       di,di                    ; offset ukl†dac° adresy
         xor       si,si                    ; átec° adresa z bufferu

; ------ inicializace ukazatelñ komprese

         mov       word ptr ds:[KompCit],0  ; á°taá komprese
         mov       word ptr ds:[KompBNum],0 ; zru®en° á°taáe bajtñ v bufferu
         mov       byte ptr ds:[KompPar],1  ; nastaven° p©°znaku komprese
         mov       word ptr ds:[NumBuf],0   ; v bufferu nejsou ë†dn† data

; ------ normalizace ukl†dac° adresy

ReadF4:  mov       ax,di
         and       di,0fh
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       cx,es
         add       ax,cx
         mov       es,ax

; ------ test, zda je p©eteáen° bufferu

         cmp       ax,ds:[DatEnd]           ; p©eteáen° pamàti ?
         jb        ReadF5
         mov       dx,offset MemTxt         ; chyba - nedostatek pamàti
         jmp       Chyba

; ------ naáten° 1 bajtu

ReadF5:  call      ReadByte                 ; naáten° 1 bajtu
         jc        ReadF6                   ; konec dat
         cld
         stosb                              ; uloëen° bajtu do bufferu
         jmp       short ReadF4             ; dal®° bajt

; ------ uzav©en° souboru

ReadF6:  mov       ah,3eh
         int       21h

ReadF9:  ret

ReadF    ENDP

; -----------------------------------------------------------------------------
;        naáten° bajtu z bufferu SI souboru BX (CY=konec souboru)
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

         test      byte ptr ds:[Param],1    ; je komprese ?
         jz        ReadB                    ; nen° komprese

; ------ naáten° bajtu poátu dat komprese

         cmp       word ptr ds:[KompCit],0  ; je á°taá platnò ?
         jne       ReadByt4                 ; á°taá je dosud platnò
ReadByt1:call      ReadB                    ; naáten° bajtu á°taáe
         jc        ReadByt6
         mov       byte ptr ds:[KompCit],al ; poáet n†sleduj°c°ch bajtñ

; ------ p©ep°naá m¢du komprese (bajt 0)

         or        al,al                    ; je to jen p©ep°naá ?
         jnz       ReadByt2                 ; nen° to p©ep°naá
         xor       byte ptr ds:[KompPar],1  ; zmàna p©°znaku komprese
         jmp       short ReadByt1           ; novÇ áten° bajtu

; ------ naáten° bajtu k opakov†n°

ReadByt2:and       byte ptr ds:[KompPar],not 2 ; zru®en° p©°znaku komprese
         test      byte ptr ds:[KompPar],1  ; je m¢d komprese ?
         jz        ReadByt3                 ; nen° m¢d komprese
         or        byte ptr ds:[KompPar],2  ; p©°znak komprese
         call      ReadB                    ; naáten° bajtu k opakov†n°
         jc        ReadByt6
         mov       ds:[KompChar],al         ; bajt k opakov†n°

; ------ zmàna p©°znaku m¢du komprese

ReadByt3:cmp       word ptr ds:[KompCit],255 ; je zmàna m¢du komprese ?
         je        ReadByt4                 ; nen° zmàna m¢du komprese
         xor       byte ptr ds:[KompPar],1  ; zmàna p©°znaku komprese

; ------ naáten° dal®°ho bajtu

ReadByt4:mov       al,ds:[KompChar]         ; bajt p©i opakov†n° dat
         test      byte ptr ds:[KompPar],2  ; je opakov†n° dat ?
         jnz       ReadByt5                 ; je opakov†n° dat
         call      ReadB                    ; naáten° bàënÇho bajtu dat
         jc        ReadByt6

; ------ sn°ëen° á°taáe bajtñ

ReadByt5:dec       byte ptr ds:[KompCit]    ; sn°ëen° á°taáe komprese
         clc
ReadByt6:ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        naáten° bajtu z bufferu SI souboru BX bez komprese (CY=konec souboru)
; -----------------------------------------------------------------------------

; ------ test, zda je v bufferu dal®° bajt

ReadB:   cmp       si,ds:[NumBuf]           ; je jië konec bufferu ?
         jae       ReadB2                   ; je konec bufferu

; ------ naáten° dal®°ho bajtu z bufferu

ReadB3:  mov       al,ds:[si+Buffer]        ; naáten° bajtu z bufferu
         inc       si
         clc                                ; p©°znak platnÇho bajtu
         ret

; ------ naáten° dal®°ho bloku dat

ReadB2:  xor       si,si                    ; novò ukazatel átec° adresy

         push      ax
         push      cx
         push      dx

         mov       ah,3fh
         mov       dx,offset Buffer         ; poá†tek bufferu
         mov       cx,BUFSIZE               ; velikost bufferu
         int       21h                      ; naáten° bloku dat z buferu
         jc        ReadB5
         mov       ds:[NumBuf],ax           ; novò poáet bajtñ v bufferu
         or        ax,ax
         jnz       ReadB5                   ; je nàco naáteno
         stc                                ; p©°znak konce souboru

Readb5:  pop       dx
         pop       cx
         pop       ax
         jnc       ReadB3
         ret

; *****************************************************************************
;
;                         Uloëen° vòstupn°ho souboru
;
; *****************************************************************************
;˛
WritF    PROC      NEAR

; ------ z†pis z†hlav° do souboru

         mov       dx,offset Zahlavi2       ; z†hlav° souboru PIC
         mov       cx,offset(KonHl2-Zahlavi2) ; dÇlka z†hlav° souboru
         mov       bx,ds:[OutIdnt]          ; identifik†tor souboru
         mov       ah,40h                   ; funkce z†pisu do souboru
         int       21h                      ; z†pis z†hlav° do souboru

; ------ inicializace ukazatelñ komprese

         mov       word ptr ds:[KompCit],0  ; á°taá komprese
         mov       word ptr ds:[KompBNum],0 ; zru®en° á°taáe bajtñ v bufferu
         mov       byte ptr ds:[KompPar],1  ; nastaven° p©°znaku komprese
         mov       word ptr ds:[NumBuf],0   ; v bufferu nejsou ë†dn† data

; ------ z†pis obsahu souboru

         push      ds
         pop       es
         mov       si,offset Obrazek        ; dek¢dovanò obr†zek
         mov       di,offset Buffer         ; ukl†dac° adresa do bufferu
         mov       cx,SIRX*VYSY             ; poáet bajtñ obr†zku
WritF2:  cld
         lodsb                              ; bajt k z†pisu
         call      WritB                    ; z†pis bajtu AL
         loop      WritF2

; ------ vypr†zdnàn° bufferñ

         call      FlushQ                   ; vypr†zdnàn° bufferu shody
         call      FlushB                   ; vypr†zdnàn° bàënÇho bufferu
         call      WritBuff                 ; z†pis bufferu na disk

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h
         ret

WritF    ENDP

; -----------------------------------------------------------------------------
;        z†pis bajtu do souboru s kompres° (DI=buffer)
; -----------------------------------------------------------------------------
; Syntaxe komprese:
;    bajt - poáet n†sleduj°c°ch bajtñ dat 0 aë 255 (0=pouze p©ep°naá m¢du)
;         - kromà bajtu 255 se p©epne p©°znak komprese/data
;    za bajtem n†sleduje buÉ bajt, kterò se m† opakovat, nebo data o danÇm poátu
;    Na zaá†tku souboru je nastaven p©°znak komprese, prvn° bajt rñznò
;    od 255 tedy ud†v† poáet n†sleduj°c°ch dat v bàënÇm m¢du
; -----------------------------------------------------------------------------

WritB    PROC      NEAR

; ------ rozli®en°, zda je m¢d komprese

;         test      byte ptr ds:[Param],1    ; je komprese ?
;         jz        WritB1                   ; nen° komprese

; ------ test, zda je bajt shodnò s bajtem v á°taái shody

         cmp       al,ds:[KompChar]         ; je bajt shodnò ?
         je        WritB4                   ; bajt je shodnò
         call      FlushQ                   ; vypr†zdnàn° bufferu shody
         jc        WritB9                   ; chyba vòstupu do souboru

; ------ uloëen° bajtu do bufferu shody

WritB4:  mov       ds:[KompChar],al         ; uloëen° shodnÇho znaku
         inc       byte ptr ds:[KompCit]    ; zvò®en° á°taáe shodnòch znakñ

; ------ je-li 255 stejnòch znakñ, vypr†zdnàn° bufferu shody

         cmp       byte ptr ds:[KompCit],255; je buffer jië plnò ?
         clc                                ; p©°znak operace OK
         jne       WritB9                   ; buffer je®tà nen° plnò
         call      FlushQ                   ; vypr†zdnàn° bufferu shody
WritB9:  ret

WritB1:  jmp       WritB0                   ; z†pis bez komprese

WritB    ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° bufferu shody (DS=datovò segment, CY=chyba)
; -----------------------------------------------------------------------------

FlushQ   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ test, zda jsou nàjak† data v bufferu opakov†n°

         mov       cx,ds:[KompCit]          ; poáet shodnòch bajtñ
         jcxz      FlushQ8                  ; v bufferu nic nen°

; ------ kontrola, zda je dostateánò poáet opakovanòch bajtñ

         cmp       cl,3                     ; dostateánò poáet bajtñ ?
         jb        FlushQ5                  ; je malò poáet bajtñ

; ------ je dostateánò poáet bajtñ - vypr†zdnàn° bàënÇho bufferu

         call      FlushB                   ; vypr†zdnàn° bàënÇho bufferu
         jc        FlushQ9                  ; chyba vòstupu do souboru

; ------ p©°padnÇ p©epnut° do kompresn°ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn° m¢d ?
         jne       FlushQ3                  ; je kompresn° m¢d - OK
         mov       al,0                     ; bajt pro p©epnut° m¢du
         call      WritB0                   ; p©epnut° do kompresn°ho m¢du
         jc        FlushQ9                  ; chyba vòstupu do souboru
         inc       byte ptr ds:[KompPar]    ; p©°znak kompresn°ho m¢du

; ------ z†pis bajtu dÇlky a opakovanÇho bajtu

FlushQ3: mov       al,cl                    ; poáet opakov†n° bajtu
         call      WritB0                   ; z†pis poátu bajtñ
         jc        FlushQ9                  ; chyba vòstupu do souboru
         mov       al,ds:[KompChar]         ; opakovanò znak
         call      WritB0                   ; z†pis opakovanÇho bajtu
         jc        FlushQ9                  ; chyba vòstupu do souboru

; ------ nastaven° p©°znaku m¢du komprese

         inc       cl                       ; je 255 znakñ ?
         je        FlushQ7                  ; je 255 znakñ - m¢d se nep©epne
         dec       byte ptr ds:[KompPar]    ; p©°znak nekompresn°ho m¢du
         jmp       short FlushQ7

; ------ malò poáet bajtñ - vypr†zdnàn° p©es bàënò buffer

FlushQ5: mov       al,ds:[KompChar]         ; shodnò znak
FlushQ6: call      StorBuf                  ; uloëen° do bàënÇho bufferu
         jc        FlushQ9                  ; chyba vòstupu do souboru
         loop      FlushQ6                  ; uloëen° dal®°ho bajtu

; ------ nulov†n° bufferu shody

FlushQ7: mov       byte ptr ds:[KompCit],0  ; zru®en° á°taáe bajtñ v bufferu
FlushQ8: clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

FlushQ9: pop       cx
         pop       ax
         ret

FlushQ   ENDP

; -----------------------------------------------------------------------------
;        uloëen° bajtu AL do bàënÇho bufferu (DS=datovò segment, CY=chyba)
; -----------------------------------------------------------------------------

StorBuf  PROC      NEAR

; ------ £schova registrñ

         push      bx

; ------ uloëen° bajtu do bufferu

         mov       bx,ds:[KompBNum]         ; poáet bajtñ v kompresn°m bufferu
         mov       ds:[bx+KompBuff],al      ; uloëen° bajtu do bufferu
         inc       bx                       ; zvò®en° á°taáe bajtñ v bufferu
         mov       ds:[KompBNum],bx         ; novò poáet bajtñ v bufferu

; ------ p©i zaplnàn° bufferu jeho vypr†zdnàn°

         cmp       bl,255                   ; je buffer jië plnò ?
         pop       bx
         clc                                ; p©°znak operace OK
         jne       StorBuf2                 ; buffer je®tà nen° plnò
         call      FlushB                   ; vypr†zdnàn° bufferu

StorBuf2:ret

StorBuf  ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° bàënÇho bufferu (DS=datovò segment, CY=chyba)
; -----------------------------------------------------------------------------

FlushB   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ kontrola, zda v bufferu nàco je

         clc                                ; p©°znak operace OK
         mov       cx,ds:[KompBNum]         ; poáet bajtñ v kompresn°m bufferu
         jcxz      FlushB9                  ; v bufferu nic nen°

; ------ p©°padnÇ p©epnut° do nekompresn°ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn° m¢d ?
         je        FlushB3                  ; nen° kompresn° m¢d - OK
         mov       al,0                     ; bajt pro p©epnut° m¢du
         call      WritB0                   ; p©epnut° do norm†ln°ho m¢du
         jc        FlushB9                  ; chyba z†pisu
         dec       byte ptr ds:[KompPar]    ; p©°znak bàënÇho m¢du

; ------ vysl†n° bajtu dÇlky ©etàzce

FlushB3: mov       al,cl                    ; poáet n†sleduj°c°ch bajtñ textu
         call      WritB0                   ; vysl†n° bajtu dÇlky
         jc        FlushB9                  ; chyba z†pisu

; ------ nastaven° p©°znaku p©epnut° m¢du

         cmp       al,255                   ; je 255 bajtñ ?
         je        FlushB4                  ; je 255 znakñ - m¢d se nep©epne
         inc       byte ptr ds:[KompPar]    ; jinak p©°znak kompresn°ho m¢du

; ------ vysl†n° bufferu dat

FlushB4: mov        si,offset KompBuff      ; buffer s daty
FlushB5: cld
         lodsb                              ; bajt dat k vysl†n°
         call      WritB0                   ; vysl†n° bajtu
         jc        FlushB9                  ; chyba z†pisu
         loop      FlushB5                  ; vysl†n° dal®°ho bajtu
         mov       byte ptr ds:[KompBNum],0 ; zru®en° á°taáe bajtñ v bufferu

; ------ n†vrat registrñ

FlushB9: pop       si
         pop       cx
         pop       ax
         ret

FlushB   ENDP

; -----------------------------------------------------------------------------
;        Z†pis bajtu do diskovÇho bufferu (DS=datovò segment, CY=chyba)
; -----------------------------------------------------------------------------

WritB0   PROC      NEAR

; ------ vypr†zdnàn° bufferu, pokud je jië zaplnàn

         cmp       di,offset Buffer+BufSize ; buffer je jië zaplnàn ?
         jb        WritB2                   ; buffer je®tà nen° zaplnàn
         call      WritBuff                 ; z†pis bufferu na disk
         jc        WritB3                   ; byla chyba z†pisu

; ------ uloëen° bajtu do bufferu

WritB2:  cld
         stosb
         clc                                ; p©°znak operace OK
WritB3:  ret

WritB0   ENDP

; -----------------------------------------------------------------------------
;        Z†pis diskovÇho bufferu do souboru (DS=datovò segment, CY=chyba)
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ z†pis obsahu bufferu do souboru

         clc                                ; p©ednastaven° p©°znaku OK
         mov       cx,di                    ; poáet bajtñ v diskovÇm bufferu
         sub       cx,offset Buffer
         jcxz      WritBff2                 ; nen° ë†dnò bajt k z†pisu
         mov       ah,40h                   ; funkce z†pisu
         mov       dx,offset Buffer         ; diskovò buffer
         mov       di,dx                    ; nov† ukl†dac° adresa
         int       21h                      ; z†pis souboru
         jc        WritBff2                 ; byla chyba
         cmp       ax,cx                    ; souhlas° poáet bajtñ ?

; ------ n†vrat registrñ

WritBff2:pop       dx
         pop       cx
         pop       ax
         ret

WritBuff ENDP

; *****************************************************************************
;
;                       Rozbor zad†n° parametrñ
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        rozbor zad†n° jmÇna souboru -> DX zaá†tek jmÇna, CY=nen° nic zad†no
; -----------------------------------------------------------------------------

RozbNam  PROC      NEAR

         call      RozbSpc                  ; nalezen° zaá†tku jmÇna souboru
         jc        RozbNam4                 ; nen° nic zad†no
         mov       dx,si                    ; zaá†tek jmÇna souboru
RozbNam1:call      RozbCh                   ; naáten° znaku
         ja        RozbNam1                 ; nalezen° konce jmÇna
         jc        RozbNam2                 ; konec parametrñ
         mov       byte ptr ds:[si-1],0     ; oznaáen° konce jmÇna souboru
RozbNam2:clc
RozbNam4:ret

RozbNam  ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbCh                   ; vstup znaku z p©°kazovÇho ©†dku
         jc        RozbSpc3                 ; nen° dal®° znak
         je        RozbSpc                  ; vypu®tàn° mezery
         dec       si
RozbSpc3:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

RozbCh   PROC      NEAR

; ------ naáten° znaku

         cld
         lodsb

; ------ n†hrada tabel†toru mezerou

         cmp       al,9
         jne       RozbCh1
         mov       al," "

; ------ test, zda je konec ©†dku

RozbCh1: cmp       al," "
         jae       RozbCh3                  ; je platnò znak
         dec       si                       ; n†vrat konce ©†dku
RozbCh3: ret

RozbCh   ENDP

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************
;˛
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

         db        01101100b                ; 128 "Ä"
         db        01111110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        01100110b
         db        00111100b
         db        00000000b

         db        00000000b                ; 129 "Å"
         db        11001100b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00001100b                ; 130 "Ç"
         db        00011000b
         db        01111000b
         db        11001100b
         db        11111100b
         db        11000000b
         db        01111000b
         db        00000000b

         db        00000011b                ; 131 "É"
         db        00011101b
         db        00001110b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        11001100b                ; 132 "Ñ"
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        01101100b                ; 133 "Ö"
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b

         db        01101100b                ; 134 "Ü"
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        01101100b                ; 135 "á"
         db        00111000b
         db        01111000b
         db        11001100b
         db        11000000b
         db        11001100b
         db        01111000b
         db        00000000b

         db        01101100b                ; 136 "à"
         db        00111000b
         db        01111000b
         db        11001100b
         db        11111100b
         db        11000000b
         db        01111000b
         db        00000000b

         db        01101100b                ; 137 "â"
         db        11111110b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        11111110b
         db        00000000b

         db        00001100b                ; 138 "ä"
         db        11111000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        00001100b                ; 139 "ã"
         db        01111000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00000011b                ; 140 "å"
         db        01110001b
         db        00110010b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        00001100b                ; 141 "ç"
         db        01111000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        11000110b                ; 142 "é"
         db        00010000b
         db        01111100b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        00001100b                ; 143 "è"
         db        01111000b
         db        11001100b
         db        11001100b
         db        11111100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        00001100b                ; 144 "ê"
         db        11111110b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        11111110b
         db        00000000b

         db        01101100b                ; 145 "ë"
         db        00111000b
         db        11111100b
         db        10011000b
         db        00110000b
         db        01100100b
         db        11111100b
         db        00000000b

         db        01101100b                ; 146 "í"
         db        11111110b
         db        10001100b
         db        00011000b
         db        00110010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        01111000b                ; 147 "ì"
         db        10000100b
         db        00000000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00000000b                ; 148 "î"
         db        11001100b
         db        00000000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00001100b                ; 149 "ï"
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b

         db        00111000b                ; 150 "ñ"
         db        01101100b
         db        11111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00001100b                ; 151 "ó"
         db        11011100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111100b
         db        00000000b

         db        00001100b                ; 152 "ò"
         db        00011000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        11111000b

         db        11000011b                ; 153 "ô"
         db        00011000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b

         db        11001100b                ; 154 "ö"
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        01101100b                ; 155 "õ"
         db        11111110b
         db        11100000b
         db        01111000b
         db        00001110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000011b                ; 156 "ú"
         db        11110001b
         db        01100010b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b

         db        00001100b                ; 157 "ù"
         db        11011100b
         db        11001100b
         db        01111000b
         db        00110000b
         db        00110000b
         db        01111000b
         db        00000000b

         db        01101100b                ; 158 "û"
         db        11111110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b

         db        00000011b                ; 159 "ü"
         db        00110001b
         db        11111110b
         db        00110000b
         db        00110000b
         db        00110100b
         db        00011000b
         db        00000000b

         db        00001100b                ; 160 "†"
         db        00011000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        01110110b
         db        00000000b

         db        00111000b                ; 161 "°"
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

         db        01101100b                ; 164 "§"
         db        00111000b
         db        10111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        01101100b                ; 165 "•"
         db        11111110b
         db        11110110b
         db        11011110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        00000000b

         db        00010000b                ; 166 "¶"
         db        11101100b
         db        11011100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11111100b
         db        00000000b

         db        11111110b                ; 167 "ß"
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b

         db        01101100b                ; 168 "®"
         db        00111000b
         db        01111100b
         db        11000000b
         db        01110000b
         db        00011100b
         db        11111000b
         db        00000000b

         db        01101100b                ; 169 "©"
         db        00111000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00001100b                ; 170 "™"
         db        00011000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00001100b                ; 171 "´"
         db        11111110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b

         db        11000011b                ; 172 "¨"
         db        11000110b
         db        11001100b
         db        11011011b
         db        00110111b
         db        01101101b
         db        11001111b
         db        00000011b

         db        00111110b                ; 173 "≠"
         db        01100011b
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        10000110b
         db        11111100b

         db        00000000b                ; 174 "Æ"
         db        00110011b
         db        01100110b
         db        11001100b
         db        01100110b
         db        00110011b
         db        00000000b
         db        00000000b

         db        00000000b                ; 175 "Ø"
         db        11001100b
         db        01100110b
         db        00110011b
         db        01100110b
         db        11001100b
         db        00000000b
         db        00000000b

         db        00100010b                ; 176 "∞"
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

         db        11011101b                ; 178 "≤"
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b

         db        00011000b                ; 179 "≥"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 180 "¥"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 181 "µ"
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 182 "∂"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 183 "∑"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 184 "∏"
         db        00000000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 185 "π"
         db        00110110b
         db        11110110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 186 "∫"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 187 "ª"
         db        00000000b
         db        11111110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 188 "º"
         db        00110110b
         db        11110110b
         db        00000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 189 "Ω"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 190 "æ"
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 191 "ø"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 192 "¿"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 193 "¡"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 194 "¬"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 195 "√"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 196 "ƒ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 197 "≈"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 198 "∆"
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 199 "«"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 200 "»"
         db        00110110b
         db        00110111b
         db        00110000b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 201 "…"
         db        00000000b
         db        00111111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 202 " "
         db        00110110b
         db        11110111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 203 "À"
         db        00000000b
         db        11111111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 204 "Ã"
         db        00110110b
         db        00110111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 205 "Õ"
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 206 "Œ"
         db        00110110b
         db        11110111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 207 "œ"
         db        00011000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 208 "–"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 209 "—"
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 210 "“"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 211 "”"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 212 "‘"
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 213 "’"
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 214 "÷"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 215 "◊"
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 216 "ÿ"
         db        00011000b
         db        11111111b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 217 "Ÿ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 218 "⁄"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b

         db        11111111b                ; 219 "€"
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 220 "‹"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        11110000b                ; 221 "›"
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b

         db        00001111b                ; 222 "ﬁ"
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b

         db        11111111b                ; 223 "ﬂ"
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 224 "‡"
         db        00000000b
         db        01110110b
         db        11011100b
         db        11001000b
         db        11011100b
         db        01110110b
         db        00000000b

         db        00000000b                ; 225 "·"
         db        01111000b
         db        11001100b
         db        11111000b
         db        11001100b
         db        11111000b
         db        11000000b
         db        11000000b

         db        00000000b                ; 226 "‚"
         db        11111100b
         db        11001100b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b

         db        00000000b                ; 227 "„"
         db        00000000b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b

         db        11111100b                ; 228 "‰"
         db        11001100b
         db        01100000b
         db        00110000b
         db        01100000b
         db        11001100b
         db        11111100b
         db        00000000b

         db        00000000b                ; 229 "Â"
         db        00000000b
         db        01111110b
         db        11011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b

         db        00000000b                ; 230 "Ê"
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        11000000b

         db        00000000b                ; 231 "Á"
         db        01110110b
         db        11011100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        11111100b                ; 232 "Ë"
         db        00110000b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00110000b
         db        11111100b

         db        00111000b                ; 233 "È"
         db        01101100b
         db        11000110b
         db        11111110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b

         db        00111000b                ; 234 "Í"
         db        01101100b
         db        11000110b
         db        11000110b
         db        01101100b
         db        01101100b
         db        11101110b
         db        00000000b

         db        00011100b                ; 235 "Î"
         db        00110000b
         db        00011000b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00000000b                ; 236 "Ï"
         db        00000000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00000000b
         db        00000000b

         db        00000110b                ; 237 "Ì"
         db        00001100b
         db        01111110b
         db        11011011b
         db        11011011b
         db        01111110b
         db        01100000b
         db        11000000b

         db        00111000b                ; 238 "Ó"
         db        01100000b
         db        11000000b
         db        11111000b
         db        11000000b
         db        01100000b
         db        00111000b
         db        00000000b

         db        01111000b                ; 239 "Ô"
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        00000000b                ; 240 ""
         db        01111110b
         db        00000000b
         db        01111110b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b

         db        00011000b                ; 241 "Ò"
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        01111110b
         db        00000000b

         db        01100000b                ; 242 "Ú"
         db        00110000b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00000000b
         db        11111100b
         db        00000000b

         db        00011000b                ; 243 "Û"
         db        00110000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00000000b
         db        11111100b
         db        00000000b

         db        00001110b                ; 244 "Ù"
         db        00011011b
         db        00011011b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 245 "ı"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11011000b
         db        11011000b
         db        01110000b

         db        00011000b                ; 246 "ˆ"
         db        00011000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b

         db        00000000b                ; 247 "˜"
         db        01110110b
         db        11011100b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b

         db        00111000b                ; 248 "¯"
         db        01101100b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 249 "˘"
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 250 "˙"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001111b                ; 251 "˚"
         db        00001100b
         db        00001100b
         db        00001100b
         db        11101100b
         db        01101100b
         db        00111100b
         db        00011100b

         db        01011000b                ; 252 "¸"
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01110000b                ; 253 "˝"
         db        10011000b
         db        00110000b
         db        01100000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 254 "˛"
         db        00000000b
         db        00111100b
         db        00111100b
         db        00111100b
         db        00111100b
         db        00000000b
         db        00000000b

         db        00000000b                ; 255 "ˇ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
;˛
; -----------------------------------------------------------------------------
;        z†hlav° vstupn°ho souboru obr†zku SCR
; -----------------------------------------------------------------------------

Zahlavi  label     byte                   ;* z†hlav° souboru SCREEN (dÇlka 16 B)
Ident    db        'SCR'                    ; identifikace souboru displeje
Verze    db        1                        ; verze souboru
Sirka    dw        0                        ; ®°©ka vò©ezu (pozic, bodñ)
Vyska    dw        0                        ; vò®ka vò©ezu (linek)
Rovin    db        0                        ; poáet barevnòch rovin
         db        0                        ; (rezervov†no)
Pozadi   db        0                        ; barva pozad°
Komentar db        0                        ; poáet bajtñ koment†©e + informace
Palet    dw        0                        ; poáet bajtñ za z†hlav°m
VMod     db        0                        ; videom¢d displeje
Param    db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textovò videom¢d
                                            ;  bit 2: 1=paraleln° uloëen° barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
KonHl    label     byte                     ; konec z†hlav°

; -----------------------------------------------------------------------------
;        z†hlav° vòstupn°ho souboru obr†zku PIC
; -----------------------------------------------------------------------------

Zahlavi2 label     byte
         db        'SCR'                    ; identifikace souboru displeje
         db        1                        ; verze souboru
         dw        SIRX                     ; ®°©ka vò©ezu (pozic, bodñ)
         dw        VYSY                     ; vò®ka vò©ezu (linek)
         db        8                        ; poáet barevnòch rovin
         db        0                        ; (rezervov†no)
         db        0                        ; barva pozad°
         db        0                        ; poáet bajtñ koment†©e + informace
         dw        0                        ; poáet bajtñ za z†hlav°m
         db        13h                      ; videom¢d displeje
         db        4+1                      ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textovò videom¢d
                                            ;  bit 2: 1=paraleln° uloëen° barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
KonHl2   label     byte                     ; konec z†hlav°

; -----------------------------------------------------------------------------
;        komprese
; -----------------------------------------------------------------------------

; ósek shodnÇho opakovanÇho bajtu (komrese):
KompCit  dw        0                        ; á°taá shodnÇho bajtu
KompChar db        0                        ; znak k opakov†n°

; ósek neshodnòch bajtñ (nen° komprese):
KompBNum dw        0                        ; poáet bajtñ v kompresn°m bufferu
KompBuff db        255 dup(0)               ; kompresn° buffer

; P©°znak £seku komprese
KompPar  db        1                        ; 1=p©°znak kompresn°ho m¢du

Palety   label     byte                     ; buffer k naáten° palet VGA
PaletCGA db        60h                      ; paleta CGA
PaletEGA db        0,1,2,3,4,5,14h,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0
PaletEG0 db        8                        ; adresa palet EGA
PaletVGA db        256*3 dup(0)             ; palety VGA

UvTxt    db        'SCR2PIV V1.0 - konverze obrazku SCR na PIV; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte: SCR2PIV  vstupni_soubor.SCR  vystupni_soubor.PIV  "titulek"',13,10,'$'
FndTxt   db        'Vstupni soubor SCR nenalezen !',13,10,'$'
CreaTxt  db        'Vystupni soubor PIV nelze vytvorit !',13,10,'$'
MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'
SCRTxt   db        'Neplatny soubor SCR !',13,10,'$'

InpIdnt  dw        0                        ; identifik†tor vstupn°ho souboru
OutIdnt  dw        0                        ; identifik†tor vòstupn°ho souboru

; -----------------------------------------------------------------------------
;        ukazatele pro konverzi obr†zku
; -----------------------------------------------------------------------------

TopX     db        3                        ; poá†teán° pozice X
TopY     db        3                        ; poá†teán° pozice Y
DelX     db        6                        ; dàlitel ve smàru X
DelY     db        6                        ; dàlitel ve smàru Y

ByteRow  dw        320                      ; poáet bajtñ na linku X
BytePic  dw        320*200                  ; poáet bajtñ na jednu rovinu barev

AdrText  dw        0                        ; adresa textu
DelText  db        0                        ; dÇlka textu k zobrazen°

; -----------------------------------------------------------------------------
;        Buffery
; -----------------------------------------------------------------------------

DatBeg   dw        0                        ; adresa datovÇho bufferu souboru
DatEnd   dw        0                        ; segment konce datovÇho bufferu

NumBuf   dw        0                        ; poáet bajtñ v bufferu

Obrazek  db        SIRX*VYSY dup(-1)        ; vòstupn° obr†zek

Buffer   db        BUFSIZE dup(?)           ; vstupn°/vòstupn° datovò buffer

         db        2000h dup(0)

         db        200h dup(?)              ; rezerva pro z†sobn°k
Zasobnik label     byte                     ; konec z†sobn°ku

Code     ENDS
         END       Start

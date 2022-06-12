
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;               Konverze souborñ SCR (z programu GDEMO) na soubory PCX
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

BUFFSIZE EQU       2000h                    ; velikost jednoho bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©edefinov†n° z†sobn°ku

Start:   cmp       sp,offset Zasobnik
         jbe       Chyba
         mov       sp,offset Zasobnik

; ------ uvolnàn° alokaán°ho bloku

         mov       bx,(offset(Zasobnik-Start)+10fh)/16
         mov       ah,4ah
         int       21h
         jc        Chyba

; ------ vytvo©en° alokaán°ho bloku bufferu

         mov       bx,4000h                 ; poëadovan† pamàü 256 KB
         mov       ah,48h
         int       21h                      ; vytvo©en° bloku pamàti
         jnc       Start0

; ------ chyba pamàti

Chyba:   mov       dx,offset MemErr
         mov       ah,9
         int       21h
         int       20h

; ------ adresa bufferu 4*64 KB

Start0:  mov       ds:[Buffer],ax           ; buffer rovin
         add       ax,1000h
         mov       ds:[Buffer2],ax          ; buffer roviny 2

; ------ zobrazen° £vodn°ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ áek†n° na stisk kl†vesy

         mov       ah,0
         int       16h                      ; vstup znaku z kl†vesnice

; ------ p©eru®en° programu

         or        ax,ax                    ; Ctrl-Break ?
         jz        Start1                   ; je Ctrl-Break
         cmp       al,27                    ; je ESC ?
         jne       Start2                   ; nen° ESC
Start1:  int       20h

; ------ definice adresy DTA

Start2:  mov       dx,offset DTA
         mov       ah,1ah
         int       21h

; ------ nalezen° prvn°ho/dal®°ho souboru

         mov       dx,offset Soubory        ; specifikace souborñ SCR
         xor       cx,cx
         mov       ah,4eh
Start3:  int       21h                      ; nalezen° prvn°ho/dal®°ho souboru
         jnc       Start4                   ; nalezen soubor OK
         int       20h

; ------ otev©en° vstupn°ho souboru

Start4:  mov       ax,3d00h
         mov       dx,offset DTAName
         int       21h                      ; otev©en° souboru
         jc        Start9                   ; chyba

; ------ inicializace ukazatelñ vòstupn°ho souboru

         mov       ds:[InpIdent],ax         ; identifik†tor vstupn°ho souboru
         mov       word ptr ds:[InpNum],0   ; poáet bajtñ ve vstupn°m bufferu
         mov       word ptr ds:[InpRead],0  ; offset átec° adresy z bufferu
         mov       byte ptr ds:[SCRCit],0   ; á°taá komprese
         mov       byte ptr ds:[SCRKomp],1  ; nastaven° p©°znaku komprese

; ------ nalezen° p©°pony jmÇna souboru

         mov       si,dx                    ; SI <- jmÇno souboru
Start5:  inc       si
         cmp       byte ptr ds:[si-1],"."
         jne       Start5                   ; nalezen° oddàlovac° teáky

; ------ n†hrada p©°ponou PCX

         mov       word ptr ds:[si],"CP"
         mov       word ptr ds:[si+2],"X"

; ------ vytvo©en° vòstupn°ho souboru PCX

         mov       byte ptr ds:[MemErrP],0  ; nulov†n° p©°znaku zobrazen° hl†®en°
         xor       cx,cx                    ; atributy
         mov       ah,3ch
         int       21h                      ; vytvo©en° vòstupn°ho souboru
         mov       ds:[OutIdent],ax         ; identifik†tor vòstupn°ho souboru

; ------ zobrazen° jmÇna souboru DS:DX

         pushf
         mov       word ptr ds:[si-1],13 + 10*256
         mov       word ptr ds:[si+1],"$"
         mov       ah,9
         int       21h                      ; zobrazen° jmÇna souboru
         popf
         jnc       Start6                   ; operace OK

; ------ chyba z†pisu do souboru

         call      WHlas                    ; zobrazen° hl†®en°
         jmp       short Start8             ; chyba - dal®° soubor

; ------ inicializace ukazatelñ vòstupn°ho souboru

Start6:  mov       word ptr ds:[OutNum],0   ; poáet bajtñ ve vòstupn°m bufferu
         mov       byte ptr ds:[PCXCit],0c0h; nen° ë†dnò znak k opakov†n°

; ------ konverze souboru (SI=p©°pona jmÇna souboru !)

         call      Konvert                  ; konverze souboru

; ------ uzav©en° vòstupn°ho souboru

         mov       bx,ds:[OutIdent]         ; identifik†tor vòstupn°ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° vòstupn°ho souboru

; ------ uzav©en° vstupn°ho souboru

Start8:  mov       bx,ds:[InpIdent]         ; identifik†tor vstupn°ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° vstupn°ho souboru

; ------ p©°prava pro dal®° soubor

Start9:  mov       ah,4fh
         jmp       Start3                   ; dal®° soubor

; -----------------------------------------------------------------------------
;        konverze obr†zku
; -----------------------------------------------------------------------------

Konvert  PROC      NEAR

; ------ inicializace standardn°ch palet SCR (zbytek VGA se ponech† nedefinov†n)

         push      ds
         pop       es
         mov       si,offset StandCGA       ; standardn° palety
         mov       di,offset PalCGA         ; buffer palet
         mov       cx,1 + 18 + 3*64         ; velikost standardn°ch palet
         cld
         rep       movsb                    ; inicializace standardn°ch palet

; ------ naáten° z†hlav° souboru SCR

         mov       dx,offset SCR            ; z†hlav° SCR
         mov       cl,offset(SCR0-SCR)      ; dÇlka z†hlav°
         mov       bx,ds:[InpIdent]         ; identifik†tor vstupn°ho souboru
         mov       ah,3fh
         int       21h                      ; naáten° z†hlav° vstupn°ho souboru

; ------ naáten° koment†©e k souboru

         mov       cl,ds:[SCRKomnt]         ; dÇlka koment†©e
         mov       dx,offset Koment         ; buffer koment†©ñ
         mov       ah,3fh
         int       21h                      ; naáten° koment†©e

; ------ naáten° palety CGA

         test      byte ptr ds:[SCRParam],10h ; jsou palety CGA ?
         jz        Konv12                   ; nejsou palety CGA
         mov       dx,offset PalCGA         ; palety CGA
         mov       cl,1                     ; 1 bajt
         mov       ah,3fh
         int       21h                      ; naáten° palet CGA

; ------ naáten° palet EGA

Konv12:  test      byte ptr ds:[SCRParam],20h ; jsou palety EGA ?
         jz        Konv14                   ; nejsou palety EGA
         mov       dx,offset PalEGA         ; palety EGA
         mov       cl,18                    ; 18 bajtñ
         mov       ah,3fh
         int       21h                      ; naáten° palet EGA

; ------ naáten° palet VGA

Konv14:  test      byte ptr ds:[SCRParam],40h ; jsou palety VGA ?
         jz        Konv16                   ; nejsou palety VGA
         mov       dx,offset PalVGA         ; palety VGA
         mov       cx,3*256                 ; velikost palet
         mov       ah,3fh
         int       21h                      ; naáten° palet VGA

; ------ inicializace palet pro 16 barev (EGA) (ES=DS !)

Konv16:  mov       di,offset PCXVGA         ; buffer palet VGA
         cld
         test      byte ptr ds:[SCRParam],2 ; textovò reëim ?
         jnz       Konv162                  ; textovò reëim - jako EGA
         cmp       byte ptr ds:[SCRRovin],4 ; je 16 barev ?
         jne       Konv17                   ; nen° 16 barev
Konv162: call      InitEGA                  ; inicializace palet pro EGA
         jmp       short Konv19

; ------ inicializace palet pro 4 barvy (CGA)

Konv17:  cmp       byte ptr ds:[SCRRovin],2 ; jsou 4 barvy ?
         jne       Konv18
         call      InitCGA                  ; inicializace palet pro CGA
         jmp       short Konv19

; ------ inicializace palet VGA

Konv18:  call      InitVGA                  ; inicializace palet pro VGA

Konv19:  mov       si,offset PCXVGA
         mov       di,offset PCXEGA
         mov       cx,3*16
         cld
         rep       movsb

; ------ p©°prava rozmàrñ obr†zku

         mov       ax,ds:[SCRVyska]         ; vò®ka obr†zku (linek)
         test      byte ptr ds:[SCRParam],2 ; textovò reëim ?
         jz        Konv192                  ; nen° textovò reëim
         mov       dx,14                    ; poáet linek na ©†dek
         mul       dx                       ; p©epoáet na poáet grafickòch linek
Konv192: mov       ds:[PCXVert],ax          ; vertik†ln° rozli®itelnost
         dec       ax
         mov       ds:[PCXY2],ax            ; koncov† sou©adnice Y2
         mov       ax,ds:[SCRSirka]         ; ®°©ka obr†zku (bodñ)
         test      byte ptr ds:[SCRParam],2 ; textovò reëim ?
         jz        Konv194                  ; nen° textovò reëim
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; p©epoáet na poáet bodñ horizont†lnà
Konv194: mov       ds:[PCXHoriz],ax         ; horizont†ln° rozli®itelnost
         dec       ax
         mov       ds:[PCXX2],ax            ; koncov† sou©adnice X2
         inc       ax                       ; ®°©ka displeje

; ------ poáet bitñ na bod a poáet barevnòch rovin - m¢d EGA

         push      ax
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; ®°©ka displeje / 8
         mov       ds:[PCXByte],ax          ; poáet bajtñ na linku
         pop       ax
         mov       byte ptr ds:[PCXBits],1  ; poáet bitñ na bod pro 16 barev EGA
         mov       byte ptr ds:[PCXRovin],4 ; poáet barevnòch rovin
         cmp       byte ptr ds:[SCRRovin],4 ; je 16 barev ?
         je        Konvert3                 ; je 16 barev
         test      byte ptr ds:[SCRParam],2 ; textovò reëim ?
         jnz       Konvert3                 ; je textovò reëim

; ------ poáet bitñ na bod a poáet barevnòch rovin - m¢d MCGA

         mov       ds:[PCXByte],ax          ; poáet bajtñ na linku
         mov       byte ptr ds:[PCXRovin],1 ; poáet barevnòch rovin
         mov       byte ptr ds:[PCXBits],8  ; poáet bitñ na bod
         cmp       byte ptr ds:[SCRRovin],8 ; je 256 barev ?
         je        Konvert3                 ; je 256 barev

; ------ poáet bitñ na bod a poáet barevnòch rovin - m¢d CGA

         shr       word ptr ds:[PCXByte],1
         shr       word ptr ds:[PCXByte],1  ; ®°©ka displeje / 4
         mov       byte ptr ds:[PCXBits],2  ; poáet bitñ na bod pro 4 barvy
         cmp       byte ptr ds:[SCRRovin],2 ; jsou 4 barvy ?
         je        Konvert3                 ; jsou 4 barvy

; ------ poáet bitñ na bod a poáet barevnòch rovin - m¢d 2 barvy (mono)

         shr       word ptr ds:[PCXByte],1  ; ®°©ka displeje / 8
         mov       byte ptr ds:[PCXBits],1  ; jinak 1 bit na bod

; ------ z†pis z†hlav° souboru PCX

Konvert3:mov       dx,offset PCX            ; z†hlav° PCX
         mov       cx,offset(PCX0-PCX)      ; dÇlka z†hlav°
         mov       bx,ds:[OutIdent]         ; identifik†tor souboru
         mov       ah,40h
         int       21h                      ; z†pis z†hlav° souboru

; ------ konverze textovÇho m¢du

         test      byte ptr ds:[SCRParam],2 ; textovò reëim ?
         jz        Konv38                   ; nen° textovò reëim
         call      KonvTXT                  ; konverze v textovÇm m¢du
         jmp       short Konvert6

; ------ konverze v m¢du EGA (16 barev)

Konv38:  cmp       byte ptr ds:[PCXRovin],4 ; je EGA 16 barev ?
         jne       Konv39                   ; nen° EGA 16 barev
         call      KonvEGA                  ; konverze v m¢du EGA (16 barev)
         jmp       short Konvert6

; ------ p©ekonvertov†n° dat v ostatn°ch m¢dech
;˛
Konv39:  mov       dx,ds:[SCRVyska]         ; vò®ka obr†zku (linek)
Konvert4:mov       cx,ds:[PCXByte]          ; ®°©ka linky (bajtñ)
Konvert5:call      ReadChr
         jc        Konvert6
         call      WritChr
         loop      Konvert5
         call      WritFlsh                 ; vypr†zdnàn° st©adaáe opakov†n°
         dec       dx                       ; á°taá linek
         jnz       Konvert4

; ------ vypr†zdnàn° st©adaáe opakov†n°

Konvert6:call      WritFlsh                 ; vypr†zdnàn° st©adaáe opakov†n°

; ------ vypr†zdnàn° z†pisovÇho bufferu

         call      WritBuff                 ; z†pis vòstupn°ho bufferu

; ------ z†pis palety barev PCX

         mov       dx,offset PCXVGAX        ; tabulka palet barev
         mov       cx,3*256+1               ; velikost tabulky
         mov       bx,ds:[OutIdent]         ; identifik†tor souboru
         mov       ah,40h
         int       21h                      ; z†pis palet
Konvert9:ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        inicializace palet VGA (256 a 2 barvy) (ES:DI=ukl†dac° adresa, CLD)
; -----------------------------------------------------------------------------

InitVGA  PROC      NEAR

         xor       ax,ax                    ; ukazatel á°sla barvy
InitVGA2:call      Init0VGA                 ; inicializace barvy VGA
         inc       al                       ; zvò®en° ukazatele á°sla barvy
         jnz       InitVGA2
         ret

InitVGA  ENDP

; ------ dek¢dov†n° jednÇ barvy VGA (AL)

Init0VGA:push      ax
         push      bx

         mov       ah,0
         mov       bx,ax
         shl       ax,1
         add       bx,ax
         mov       ax,word ptr ds:[bx+PalVGA]
         shl       ax,1
         shl       ax,1
         stosw
         mov       al,ds:[bx+PalVGA+2]
         shl       al,1
         shl       al,1
         stosb

         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        inicializace palet pro EGA (16 barev) (ES:DI=ukl†dac° adresa, CLD)
; -----------------------------------------------------------------------------

InitEGA  PROC      NEAR

         mov       si,offset PalEGA         ; buffer palet EGA
         mov       cx,16                    ; poáet palet
InitEGA2:lodsb                              ; barva EGA
         call      Init0VGA                 ; inicializace barvy
         loop      InitEGA2
         ret

InitEGA  ENDP

; -----------------------------------------------------------------------------
;        inicializace palet pro CGA (4 barvy) (ES:DI=ukl†dac° adresa, CLD)
; -----------------------------------------------------------------------------

InitCGA  PROC      NEAR

         mov       bl,ds:[PalCGA]           ; palety
         and       bx,0fh
         mov       al,ds:[bx+PalEGA]        ; barva pozad°
         call      Init0VGA                 ; inicializace áernÇ barvy

         mov       bx,offset PalEGA + 2     ; zelen† barva
         test      byte ptr ds:[PalCGA],10h ; je intenzivn° barva ?
         jz        InitCGA2                 ; nen° intenzivn° barva
         add       bx,8                     ; intenzivn° barva
InitCGA2:test      byte ptr ds:[PalCGA],20h ; je modr† sloëka ?
         jz        InitCGA4                 ; nen° modr† sloëka
         inc       bx                       ; je modr† sloëka
InitCGA4:mov       al,ds:[bx]               ; zelen†
         call      Init0VGA                 ; zelen†
         mov       al,ds:[bx+2]             ; áerven†
         call      Init0VGA                 ; áerven†
         mov       al,ds:[bx+4]             ; hnàd†
         call      Init0VGA                 ; hnàd†
         ret

InitCGA  ENDP

; -----------------------------------------------------------------------------
;        konverze v m¢du EGA (16 barev)
; -----------------------------------------------------------------------------

KonvEGA  PROC      NEAR

; ------ pro m¢d EGA se obr†zek nejd©°ve celò naáte do bufferu v pamàti

         mov       bx,4                     ; poáet rovin k naáten°
         mov       ax,ds:[SCRVyska]         ; vò®ka (linek)
         mul       word ptr ds:[PCXByte]    ; poáet bajtñ na rovinu
         xchg      ax,cx                    ; CX <- poáet bajtñ na rovinu
         mov       dx,ds:[Buffer]           ; adresa prvn°ho bufferu

KonvEGA1:mov       es,dx                    ; ES <- adresa bufferu
         xor       di,di                    ; offset
         push      cx
KonvEGA2:call      ReadChr                  ; naáten° bajtu
         jc        KonvEGA3                 ; konec
         cld
         stosb                              ; uloëen° bajtu
         loop      KonvEGA2
KonvEGA3:pop       cx
         add       dx,1000h                 ; adresa dal®° roviny
         dec       bx                       ; á°taá rovin
         jnz       KonvEGA1                 ; naáten° dal®° roviny

; ------ z†pis obr†zku v m¢du EGA 16 barev

         mov       dx,ds:[SCRVyska]         ; vò®ka obr†zku (linek)
         xor       si,si                    ; ukazatel v bufferu
KonvEGA5:mov       bx,4                     ; poáet rovin
         mov       es,ds:[Buffer]           ; adresa bufferu
KonvEGA6:push      si
         mov       cx,ds:[PCXByte]          ; poáet bajtñ na linku
KonvEGA7:mov       al,es:[si]               ; bajt
         inc       si
         call      WritChr
         loop      KonvEGA7                 ; dal®° bajt
         pop       si
         call      WritFlsh                 ; vypr†zdnàn° st©adaáe opakov†n°
         mov       ax,es
         add       ax,1000h                 ; adresa dal®°ho bufferu
         mov       es,ax
         dec       bx                       ; á°taá rovin
         jnz       KonvEGA6                 ; dal®° rovina
         add       si,ds:[PCXByte]          ; adresa dal®° linky
         dec       dx                       ; á°taá linek
         jnz       KonvEGA5                 ; dal®° linka
         ret

KonvEGA  ENDP

; -----------------------------------------------------------------------------
;        konverze v textovÇm m¢du
; -----------------------------------------------------------------------------
;˛
KonvTXT  PROC      NEAR

; ------ p©°prava registrñ

         mov       ax,ds:[SCRVyska]         ; vò®ka obr†zku (©†dkñ)
         mul       word ptr ds:[SCRSirka]   ; poáet znakñ na rovinu
         xchg      ax,cx                    ; CX <- poáet znakñ k naáten°

; ------ naáten° textovÇ roviny

         push      cx
         mov       es,ds:[Buffer]           ; adresa bufferu
         xor       di,di
KonvTxt1:call      ReadChr                  ; naáten° znaku
         jc        KonvTxt2
         cld
         stosb
         loop      KonvTxt1
KonvTxt2:pop       cx

; ------ naáten° barvovÇ roviny

         mov       es,ds:[Buffer2]
         xor       di,di
KonvTxt3:call      ReadChr                  ; naáten° znaku
         jc        KonvTxt4
         cld
         stosb
         loop      KonvTxt3

; ------ p©°prava k z†pisu obr†zku

KonvTxt4:xor       si,si                    ; ukazatel znakñ v bufferu
         mov       dx,ds:[SCRVyska]         ; vò®ka (©†dkñ)

; ------ p©°prava k z†pisu jednÇ linky

KonvTxt5:push      dx
         xor       bp,bp                    ; ukazatel á°sla linky

; ------ p©°prava k z†pisu jednÇ roviny

KonvTxt6:mov       dx,4 + 256*1             ; DL <- á°taá rovin, DH <- maska roviny
KonvTxt7:push      si
         mov       cx,ds:[SCRSirka]         ; ®°©ka ©†dku (znakñ)

; ------ znak k z†pisu -> AL

KonvTxt8:mov       es,ds:[Buffer]
         mov       al,es:[si]               ; AL <- znak

; ------ bajt fontu k z†pisu -> AL

         mov       ah,14
         mul       ah                       ; offset ve fontech
         xchg      ax,di                    ; DI <- offset fontñ
         mov       al,ds:[di+bp+Fonty]      ; bajt fontu k z†pisu
         mov       bl,al                    ; BL <- £schova bajtu

; ------ barva znaku k z†pisu -> AH

         mov       es,ds:[Buffer2]          ; ES <- buffer barev
         mov       ah,es:[si]               ; AH <- barva znaku

; ------ test, zda je nastavena barva pop©ed°

         test      ah,dh                    ; nastavena barva pop©ed° ?
         jnz       KonvTxt9                 ; barva pop©ed° je nastavena
         mov       al,0                     ; nen° barva pop©ed°

; ------ test, zda je nastavena barva pozad°

KonvTxt9:shr       ah,1
         shr       ah,1
         shr       ah,1
         shr       ah,1
         test      ah,dh                    ; nastavena barva pozad° ?
         jz        KonvTxtA                 ; nen° barva pozad°
         not       bl
         or        al,bl                    ; nastaven° barvy pozad°

; ------ z†pis bajtu

KonvTxtA:call      WritChr                  ; z†pis bajtu
         inc       si                       ; zvò®en° ukazatele znakñ
         loop      KonvTxt8

; ------ p©°prava pro dal®° rovinu

         call      WritFlsh                 ; vypr†zdnàn° bufferu
         pop       si
         shl       dh,1                     ; posun masky roviny
         dec       dl                       ; á°taá rovin
         jnz       KonvTxt7                 ; dal®° rovina

; ------ p©°prava pro dal®° linku

         inc       bp                       ; zvò®en° ukazatele linek
         cmp       bp,14                    ; jsou jië v®echny linky ?
         jb        KonvTxt6                 ; z†pis dal®° linky

; ------ p©°prava pro dal®° ©†dek

         add       si,ds:[SCRSirka]         ; adresa dal®° linky
         pop       dx
         dec       dx                       ; á°taá ©†dkñ
         jnz       KonvTxt5                 ; dal®° ©†dek
         ret

KonvTXT  ENDP

; -----------------------------------------------------------------------------
;        naáten° znaku ze vstupn°ho souboru (s dekompres° SCR) -> AL (CY=konec)
; -----------------------------------------------------------------------------

ReadChr  PROC      NEAR

         test      byte ptr ds:[SCRParam],1 ; je komprese ?
         jz        ReadByte                 ; nen° komprese

; ------ naáten° bajtu poátu dat komprese

         cmp       byte ptr ds:[SCRCit],0   ; je á°taá platnò ?
         jne       ReadChr4                 ; á°taá je dosud platnò
ReadChr1:call      ReadByte                 ; naáten° bajtu á°taáe
         jc        ReadChr8                 ; konec souboru
         mov       byte ptr ds:[SCRCit],al  ; poáet n†sleduj°c°ch bajtñ

; ------ k¢d 0 = p©ep°naá m¢du komprese

         or        al,al                    ; je to jen p©ep°naá ?
         jnz       ReadChr2                 ; nen° to p©ep°naá
         xor       byte ptr ds:[SCRKomp],1  ; zmàna p©°znaku komprese
         jmp       short ReadChr1           ; novÇ áten° bajtu

; ------ naáten° bajtu k opakov†n°

ReadChr2:and       byte ptr ds:[SCRKomp],not 2 ; zru®en° p©°znaku komprese
         test      byte ptr ds:[SCRKomp],1  ; je m¢d komprese ?
         jz        ReadChr3                 ; nen° m¢d komprese
         or        byte ptr ds:[SCRKomp],2  ; p©°znak komprese
         call      ReadByte                 ; naáten° bajtu k opakov†n°
         jc        ReadChr8                 ; konec souboru
         mov       ds:[SCRChar],al          ; bajt k opakov†n°

; ------ zmàna p©°znaku m¢du komprese

ReadChr3:cmp       byte ptr ds:[SCRCit],255 ; je zmàna m¢du komprese ?
         je        ReadChr4                 ; nen° zmàna m¢du komprese
         xor       byte ptr ds:[SCRKomp],1  ; zmàna p©°znaku komprese

; ------ naáten° dal®°ho bajtu

ReadChr4:mov       al,ds:[SCRChar]          ; bajt p©i opakov†n° dat
         test      byte ptr ds:[SCRKomp],2  ; je opakov†n° dat ?
         jnz       ReadChr5                 ; je opakov†n° dat
         call      ReadByte                 ; naáten° bàënÇho bajtu dat
         jc        ReadChr8                 ; konec souboru

; ------ sn°ëen° á°taáe bajtñ

ReadChr5:dec       byte ptr ds:[SCRCit]     ; sn°ëen° á°taáe komprese
         clc
ReadChr8:ret

ReadChr  ENDP

; -----------------------------------------------------------------------------
;        naáten° bajtu ze vstupn°ho bufferu (CY=konec nebo chyba) -> AL
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

         push      si
         mov       si,ds:[InpRead]          ; offset átec° adresy z bufferu
         cmp       si,ds:[InpNum]           ; jsou nàjak† data ?
         jb        ReadByt2                 ; jsou nàjak† data

         call      ReadBuff                 ; naáten° vstupn°ho bufferu
         jc        ReadByt9                 ; nejsou data nebo chyba
         xor       si,si                    ; novò offset v bufferu

ReadByt2:mov       al,ds:[si+InpBuff]       ; naáten° znaku z bufferu
         inc       word ptr ds:[InpRead]    ; zvò®en° offsetu átec° adresy
         clc                                ; p©°znak operace OK

ReadByt9:pop       si
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        naáten° vstupn°ho bufferu (CY=konec nebo chyba)
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[InpRead],0  ; offset átec° adresy z bufferu
         mov       cx,BUFFSIZE              ; velikost bufferu
         mov       dx,offset InpBuff        ; vstupn° buffer
         mov       bx,ds:[InpIdent]         ; identifik†tor vstupn°ho souboru
         mov       ah,3fh
         int       21h                      ; naáten° dat ze vstupn°ho souboru
         jnc       ReadBuf1
         xor       ax,ax                    ; AX <- 0  nic nenaáteno
ReadBuf1:mov       ds:[InpNum],ax           ; poáet bajtñ ve vstupn°m bufferu
         cmp       ax,1                     ; bylo nàco naáteno ? (CY=nebylo)

ReadBuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        z†pis znaku AL do vòstupn°ho bufferu (s kompres° PCX)
; -----------------------------------------------------------------------------

WritChr  PROC      NEAR

         cmp       byte ptr ds:[PCXCit],0c0h ; bude prvn° bajt ?
         je        WritChr2                 ; bude prvn° bajt

         cmp       al,ds:[PCXChar]          ; je to stejnò bajt ?
         je        WritChr4                 ; je to stejnò bajt
         call      WritFlsh                 ; vypr†zdnàn° st©adaáe opakov†n°

WritChr2:mov       ds:[PCXChar],al          ; uloëen° znaku do bufferu
         inc       byte ptr ds:[PCXCit]     ; zvò®en° á°taáe opakovanòch znakñ
         jmp       short WritChr6

WritChr4:inc       byte ptr ds:[PCXCit]     ; zvò®en° á°taáe znakñ
         cmp       byte ptr ds:[PCXCit],255 ; je jië maximum ?
         jb        WritChr6                 ; nen° je®tà maximum
         call      WritFlsh                 ; vypr†zdnàn° bufferu

WritChr6:ret

WritChr  ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° vòstupn°ho st©adaáe opakov†n°
; -----------------------------------------------------------------------------

WritFlsh PROC      NEAR

         push      ax

         mov       al,ds:[PCXChar]          ; znak k vysl†n°
         mov       ah,ds:[PCXCit]           ; poáet znakñ opakov†n°

         cmp       ah,0c0h                  ; je nàjakò bajt ?
         je        WritFls4                 ; nen° ë†dnò bajt

         cmp       al,0c0h                  ; je povolenò bajt ?
         jae       WritFls1                 ; nen° povolenò bajt
         cmp       ah,0c1h                  ; je 1 bajt ?
         je        WritFls2                 ; je 1 bajt - nen° opakov†n°

WritFls1:xchg      al,ah                    ; AL <- poáet bajtñ
         call      WritByte                 ; z†pis poátu opakov†n°
         xchg      al,ah                    ; AL <- bajt
WritFls2:call      WritByte                 ; z†pis bajtu k opakov†n°

         mov       byte ptr ds:[PCXCit],0c0h ; nen° ë†dnò bajt

WritFls4:pop       ax
         ret

WritFlsh ENDP

; -----------------------------------------------------------------------------
;        z†pis bajtu do vòstupn°ho bufferu
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

         push      di
         mov       di,ds:[OutNum]           ; poáet bajtñ ve vòstupn°m bufferu
         cmp       di,BUFFSIZE              ; je buffer jië plnò ?
         jb        WritByt2                 ; buffer je®tà nen° plnò

         call      WritBuff                 ; z†pis vòstupn°ho bufferu
         xor       di,di                    ; novò ukazatel v bufferu

WritByt2:mov       ds:[di+OutBuff],al       ; uloëen° bajtu do bufferu
         inc       word ptr ds:[OutNum]     ; zvò®en° á°taáe bajtñ v bufferu

         pop       di
         ret

WritByte ENDP

; -----------------------------------------------------------------------------
;        z†pis vòstupn°ho bufferu
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       cx,ds:[OutNum]           ; poáet bajtñ ve vòstupn°m bufferu
         jcxz      WritBuf6                 ; v bufferu nejsou ë†dn† data
         mov       bx,ds:[OutIdent]         ; identifik†tor vòstupn°ho souboru
         mov       dx,offset OutBuff        ; vòstupn° buffer
         mov       ah,40h
         int       21h                      ; z†pis dat do souboru
         jc        WritBuf2
         cmp       ax,cx
         je        WritBuf4

WritBuf2:call      WHlas                    ; hl†®en° o chybà z†pisu

WritBuf4:mov       word ptr ds:[OutNum],0   ; nejsou ë†dn† data v bufferu

WritBuf6:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBuff ENDP

; -----------------------------------------------------------------------------
;        hl†®en° - chyba z†pisu do souboru
; -----------------------------------------------------------------------------

WHlas    PROC      NEAR

         push      ax
         push      dx

         cmp       byte ptr ds:[MemErrP],0  ; bylo jië hl†®en° ?
         jne       WHlas9                   ; bylo jië hl†®en°
         inc       byte ptr ds:[MemErrP]    ; p©°znak zobrazen° hl†®en°
         mov       ah,9
         mov       dx,offset WritErr        ; text hl†®en°
         int       21h                      ; zobrazen° hl†®en°

WHlas9:  pop       dx
         pop       ax
         ret

WHlas    ENDP

; *****************************************************************************
;
;                                  Data
;
; *****************************************************************************
;˛
; ------ fonty (14 linek)

Fonty    label     byte
         db        00000000b                ; 0
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 1
         db        00000000b
         db        01111110b
         db        10000001b
         db        10100101b
         db        10000001b
         db        10000001b
         db        10111101b
         db        10011001b
         db        10000001b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 2
         db        00000000b
         db        01111110b
         db        11111111b
         db        11011011b
         db        11111111b
         db        11111111b
         db        11000011b
         db        11100111b
         db        11111111b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 3
         db        00000000b
         db        00000000b
         db        01101100b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 4
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01111100b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 5
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        11100111b
         db        11100111b
         db        11100111b
         db        10011001b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 6
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        11111111b
         db        11111111b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 7
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        11111111b                ; 8
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11100111b
         db        11000011b
         db        11000011b
         db        11100111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 9
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        01000010b
         db        01000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        11111111b                ; 10
         db        11111111b
         db        11111111b
         db        11111111b
         db        11000011b
         db        10011001b
         db        10111101b
         db        10111101b
         db        10011001b
         db        11000011b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 11
         db        00000000b
         db        00011110b
         db        00001110b
         db        00011010b
         db        00110010b
         db        01111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 12
         db        00000000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 13
         db        00000000b
         db        00111111b
         db        00110011b
         db        00111111b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01110000b
         db        11110000b
         db        11100000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 14
         db        00000000b
         db        01111111b
         db        01100011b
         db        01111111b
         db        01100011b
         db        01100011b
         db        01100011b
         db        01100111b
         db        11100111b
         db        11100110b
         db        11000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 15
         db        00000000b
         db        00011000b
         db        00011000b
         db        11011011b
         db        00111100b
         db        11100111b
         db        00111100b
         db        11011011b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 16
         db        00000000b
         db        10000000b
         db        11000000b
         db        11100000b
         db        11111000b
         db        11111110b
         db        11111000b
         db        11100000b
         db        11000000b
         db        10000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 17
         db        00000000b
         db        00000010b
         db        00000110b
         db        00001110b
         db        00111110b
         db        11111110b
         db        00111110b
         db        00001110b
         db        00000110b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 18
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 19
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 20
         db        00000000b
         db        01111111b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 21
         db        01111100b
         db        11000110b
         db        01100000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00001100b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 22
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 23
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b

         db        00000000b                ; 24
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 25
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 26
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00001100b
         db        11111110b
         db        00001100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 27
         db        00000000b
         db        00000000b
         db        00000000b
         db        00110000b
         db        01100000b
         db        11111110b
         db        01100000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 28
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 29
         db        00000000b
         db        00000000b
         db        00000000b
         db        00101000b
         db        01101100b
         db        11111110b
         db        01101100b
         db        00101000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 30
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        00111000b
         db        01111100b
         db        01111100b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 31
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        01111100b
         db        01111100b
         db        00111000b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
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
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 33 "!"
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 34 """
         db        01100110b
         db        01100110b
         db        01100110b
         db        00100100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 35 "#"
         db        00000000b
         db        01101100b
         db        01101100b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11111110b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 36 "$"
         db        00011000b
         db        01111100b
         db        11000110b
         db        11000010b
         db        11000000b
         db        01111100b
         db        00000110b
         db        10000110b
         db        11000110b
         db        01111100b
         db        00011000b
         db        00011000b
         db        00000000b

         db        00000000b                ; 37 "%"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000010b
         db        11000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 38 "&"
         db        00000000b
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        01110110b
         db        11011100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 39 "'"
         db        00110000b
         db        00110000b
         db        00110000b
         db        01100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 40 "("
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 41 ")"
         db        00000000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 42 "*"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        11111111b
         db        00111100b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 43 "+"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 44 ","
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 45 "-"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 46 "."
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 47 "/"
         db        00000000b
         db        00000010b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000000b
         db        10000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 48 "0"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11001110b
         db        11011110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 49 "1"
         db        00000000b
         db        00011000b
         db        00111000b
         db        01111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 50 "2"
         db        00000000b
         db        01111100b
         db        11000110b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 51 "3"
         db        00000000b
         db        01111100b
         db        11000110b
         db        00000110b
         db        00000110b
         db        00111100b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 52 "4"
         db        00000000b
         db        00001100b
         db        00011100b
         db        00111100b
         db        01101100b
         db        11001100b
         db        11111110b
         db        00001100b
         db        00001100b
         db        00011110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 53 "5"
         db        00000000b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11111100b
         db        00001110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 54 "6"
         db        00000000b
         db        00111000b
         db        01100000b
         db        11000000b
         db        11000000b
         db        11111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 55 "7"
         db        00000000b
         db        11111110b
         db        11000110b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 56 "8"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 57 "9"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00001100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 58 ":"
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 59 ";"
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 60 "<"
         db        00000000b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 61 "="
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 62 ">"
         db        00000000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 63 "?"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        00001100b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 64 "@"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11011110b
         db        11011110b
         db        11011110b
         db        11011100b
         db        11000000b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 65 "A"
         db        00000000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 66 "B"
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 67 "C"
         db        00000000b
         db        00111100b
         db        01100110b
         db        11000010b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 68 "D"
         db        00000000b
         db        11111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 69 "E"
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 70 "F"
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 71 "G"
         db        00000000b
         db        00111100b
         db        01100110b
         db        11000010b
         db        11000000b
         db        11000000b
         db        11011110b
         db        11000110b
         db        01100110b
         db        00111010b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 72 "H"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 73 "I"
         db        00000000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 74 "J"
         db        00000000b
         db        00011110b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 75 "K"
         db        00000000b
         db        11100110b
         db        01100110b
         db        01101100b
         db        01101100b
         db        01111000b
         db        01101100b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 76 "L"
         db        00000000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 77 "M"
         db        00000000b
         db        11000110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 78 "N"
         db        00000000b
         db        11000110b
         db        11100110b
         db        11110110b
         db        11111110b
         db        11011110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 79 "O"
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 80 "P"
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 81 "Q"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11011110b
         db        01111100b
         db        00001100b
         db        00001110b
         db        00000000b
         db        00000000b

         db        00000000b                ; 82 "R"
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 83 "S"
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        01100000b
         db        00111000b
         db        00001100b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 84 "T"
         db        00000000b
         db        01111110b
         db        01111110b
         db        01011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 85 "U"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 86 "V"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 87 "W"
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        01111100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 88 "X"
         db        00000000b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00111000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 89 "Y"
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 90 "Z"
         db        00000000b
         db        11111110b
         db        11000110b
         db        10001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000010b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 91 "["
         db        00000000b
         db        00111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 92 "\"
         db        00000000b
         db        10000000b
         db        11000000b
         db        11100000b
         db        01110000b
         db        00111000b
         db        00011100b
         db        00001110b
         db        00000110b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 93 "]"
         db        00000000b
         db        00111100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00010000b                ; 94 "^"
         db        00111000b
         db        01101100b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
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
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b

         db        00110000b                ; 96 "`"
         db        00110000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 97 "a"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 98 "b"
         db        00000000b
         db        11100000b
         db        01100000b
         db        01100000b
         db        01111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 99 "c"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 100 "d"
         db        00000000b
         db        00011100b
         db        00001100b
         db        00001100b
         db        00111100b
         db        01101100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 101 "e"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 102 "f"
         db        00000000b
         db        00111000b
         db        01101100b
         db        01100100b
         db        01100000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 103 "g"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00000000b                ; 104 "h"
         db        00000000b
         db        11100000b
         db        01100000b
         db        01100000b
         db        01101100b
         db        01110110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 105 "i"
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 106 "j"
         db        00000000b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00001110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b

         db        00000000b                ; 107 "k"
         db        00000000b
         db        11100000b
         db        01100000b
         db        01100000b
         db        01100110b
         db        01101100b
         db        01111000b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 108 "l"
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 109 "m"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11101100b
         db        11111110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 110 "n"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 111 "o"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 112 "p"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00000000b                ; 113 "q"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        00001100b
         db        00011110b
         db        00000000b

         db        00000000b                ; 114 "r"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 115 "s"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        01110000b
         db        00011100b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 116 "t"
         db        00000000b
         db        00010000b
         db        00110000b
         db        00110000b
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110110b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 117 "u"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 118 "v"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 119 "w"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 120 "x"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 121 "y"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00001100b
         db        11111000b
         db        00000000b

         db        00000000b                ; 122 "z"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11001100b
         db        00011000b
         db        00110000b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 123 "{"
         db        00000000b
         db        00001110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01110000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00001110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 124 "|"
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 125 "}"
         db        00000000b
         db        01110000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00001110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 126 "~"
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 127 ""
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 128 "Ä"
         db        00111100b
         db        00111100b
         db        01100110b
         db        11000010b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 129 "Å"
         db        00000000b
         db        11001100b
         db        11001100b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 130 "Ç"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 131 "É"
         db        00000011b
         db        00011101b
         db        00001110b
         db        00001100b
         db        00111100b
         db        01101100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 132 "Ñ"
         db        00000000b
         db        11001100b
         db        11001100b
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 133 "Ö"
         db        00111100b
         db        11111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 134 "Ü"
         db        00111100b
         db        01111110b
         db        01111110b
         db        01011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 135 "á"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 136 "à"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 137 "â"
         db        00111100b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 138 "ä"
         db        00011000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 139 "ã"
         db        00011000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 140 "å"
         db        00000011b
         db        00111001b
         db        00011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 141 "ç"
         db        00011000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 142 "é"
         db        11000110b
         db        11000110b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 143 "è"
         db        00011000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 144 "ê"
         db        00011000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 145 "ë"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11111110b
         db        11001100b
         db        00011000b
         db        00110000b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 146 "í"
         db        00111100b
         db        11111110b
         db        11000110b
         db        10001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000010b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 147 "ì"
         db        00010000b
         db        00111000b
         db        01101100b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 148 "î"
         db        00000000b
         db        11000110b
         db        11000110b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 149 "ï"
         db        00011000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 150 "ñ"
         db        00111000b
         db        01101100b
         db        00111000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 151 "ó"
         db        00011000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 152 "ò"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00001100b
         db        11111000b
         db        00000000b

         db        00000000b                ; 153 "ô"
         db        11000110b
         db        11000110b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 154 "ö"
         db        11000110b
         db        11000110b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 155 "õ"
         db        00111100b
         db        01111100b
         db        11000110b
         db        11000110b
         db        01100000b
         db        00111000b
         db        00001100b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 156 "ú"
         db        00000011b
         db        11110001b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 157 "ù"
         db        00011000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 158 "û"
         db        00111100b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 159 "ü"
         db        00000011b
         db        00010001b
         db        00110010b
         db        00110000b
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110110b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 160 "†"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111000b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 161 "°"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 162 "¢"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 163 "£"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 164 "§"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 165 "•"
         db        00111100b
         db        11011110b
         db        11100110b
         db        11110110b
         db        11111110b
         db        11011110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00010000b                ; 166 "¶"
         db        00101000b
         db        11010110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01111110b                ; 167 "ß"
         db        11000011b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 168 "®"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        01110000b
         db        00011100b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 169 "©"
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 170 "™"
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 171 "´"
         db        00011000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 172 "¨"
         db        11000000b
         db        11000000b
         db        11000110b
         db        11001100b
         db        11011000b
         db        00110000b
         db        01100110b
         db        11001110b
         db        10011010b
         db        00111111b
         db        00000110b
         db        00001111b
         db        00000000b

         db        00000000b                ; 173 "≠"
         db        01111100b
         db        11000110b
         db        01100000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00001100b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00000000b                ; 174 "Æ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00110011b
         db        01100110b
         db        11001100b
         db        01100110b
         db        00110011b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 175 "Ø"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        01100110b
         db        00110011b
         db        01100110b
         db        11001100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00010001b                ; 176 "∞"
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b
         db        00010001b
         db        01000100b

         db        01010101b                ; 177 "±"
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
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
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 181 "µ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 182 "∂"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 183 "∑"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 184 "∏"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 185 "π"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
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
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 187 "ª"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 188 "º"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 189 "Ω"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 190 "æ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 191 "ø"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 192 "¿"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 193 "¡"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 194 "¬"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 195 "√"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 196 "ƒ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 197 "≈"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 198 "∆"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 199 "«"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 200 "»"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110000b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 201 "…"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 202 " "
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 203 "À"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 204 "Ã"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 205 "Õ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 206 "Œ"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 207 "œ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 208 "–"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 209 "—"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 210 "“"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 211 "”"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 212 "‘"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 213 "’"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 214 "÷"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 215 "◊"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 216 "ÿ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 217 "Ÿ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 218 "⁄"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
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
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
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
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 224 "‡"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        11011000b
         db        11011000b
         db        11011100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 225 "·"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11111100b
         db        11000110b
         db        11000110b
         db        11111100b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b

         db        00000000b                ; 226 "‚"
         db        00000000b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 227 "„"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 228 "‰"
         db        00000000b
         db        11111110b
         db        11000110b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 229 "Â"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 230 "Ê"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 231 "Á"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 232 "Ë"
         db        00000000b
         db        01111110b
         db        00011000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 233 "È"
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 234 "Í"
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11101110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 235 "Î"
         db        00000000b
         db        00011110b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00111110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 236 "Ï"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 237 "Ì"
         db        00000000b
         db        00000011b
         db        00000110b
         db        01111110b
         db        11001111b
         db        11011011b
         db        11110011b
         db        01111110b
         db        01100000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 238 "Ó"
         db        00000000b
         db        00011100b
         db        00110000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100000b
         db        01100000b
         db        00110000b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 239 "Ô"
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 240 ""
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 241 "Ò"
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 242 "Ú"
         db        00000000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 243 "Û"
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 244 "Ù"
         db        00000000b
         db        00001110b
         db        00011011b
         db        00011011b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
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
         db        00011000b
         db        00011000b
         db        00011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 246 "ˆ"
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 247 "˜"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 248 "¯"
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 249 "˘"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 250 "˙"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 251 "˚"
         db        00001111b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        11101100b
         db        01101100b
         db        00111100b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 252 "¸"
         db        11011000b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 253 "˝"
         db        01110000b
         db        10011000b
         db        00110000b
         db        01100000b
         db        11001000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 254 "˛"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        00000000b
         db        00000000b
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
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
;˛
; ------ texty

MemErrP  db        0                        ; 1=p©°znak chyby z†pisu
MemErr   db        'Nedostatek pameti !',13,10,'$'
WritErr  db        ' ... Chyba zapisu do souboru !',7,13,10,'$'

UvTxt    db        13,10
         db        'SCR2PCX v1.0 - konverze souboru SCR na PCX; (c) Miroslav Nemecek',13,10
         db        13,10
         db        ' Program zkonvertuje vsechny soubory SCR (vygenerovane programem',13,10
         db        ' GDEMO) v aktivnim adresari na soubory ve formatu PCX (existujici',13,10
         db        ' soubory budou prepsany).',13,10
         db        13,10
         db        'Stisknete libovolnou klavesu, ESC=preruseni ...',13,10
         db        13,10
         db        '$'

; ------ z†hlav° souboru SCR

SCR      label     byte                   ;* z†hlav° souboru SCREEN (dÇlka 16 B)
SCRIdent db        'SCR'                    ; identifikace souboru displeje
SCRVerze db        1                        ; verze souboru
SCRSirka dw        0                        ; ®°©ka vò©ezu (pozic, bodñ)
SCRVyska dw        0                        ; vò®ka vò©ezu (linek)
SCRRovin db        0                        ; poáet barevnòch rovin
         db        0                        ; (rezervov†no)
SCRPozad db        0                        ; barva pozad°
SCRKomnt db        0                        ; poáet bajtñ koment†©e + informace
SCRPalet dw        0                        ; poáet bajtñ za z†hlav°m
SCRVMod  db        0                        ; videom¢d displeje
SCRParam db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textovò videom¢d
                                            ;  bit 2: 1=paraleln° uloëen° barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
SCR0     label     byte                     ; konec z†hlav°

Koment   db        256 dup(0)               ; koment†© SCR
PalCGA   db        0                        ; paleta CGA
PalEGA   db        16 dup(0)                ; buffer palet EGA
PalEGA0  db        0                        ; barva pozad°
PalEGAM  db        0                        ; mapov†n° palety EGA pro VGA
PalVGA   db        3*256 dup(0)             ; buffer palet VGA

; ------ ukazatele pro dekompresi souboru SCR

SCRCit   db        0                        ; á°taá shodnÇho bajtu
SCRChar  db        0                        ; znak k opakov†n°
SCRKomp  db        1                        ; 1=p©°znak kompresn°ho m¢du
                                            ; 2=je komprese

; ------ standardn° paleta CGA

StandCGA db        10h

; ------ standardn° paleta EGA

StandEGA db        0,1,2,3,4,5,20,7         ; 0 aë 7
         db        56,57,58,59,60,61,62,63  ; 8 aë 18
         db        0                        ; pozad°
         db        0                        ; mapov†n° palet

; ------ standardn° paleta VGA

StandVGA db         0, 0, 0                 ;  0
         db         0, 0,42                 ;  1
         db         0,42, 0                 ;  2
         db         0,42,42                 ;  3
         db        42, 0, 0                 ;  4
         db        42, 0,42                 ;  5
         db        42,42, 0                 ;  6
         db        42,42,42                 ;  7
         db         0, 0,21                 ;  8
         db         0, 0,63                 ;  9
         db         0,42,21                 ; 10
         db         0,42,63                 ; 11
         db        42, 0,21                 ; 12
         db        42, 0,63                 ; 13
         db        42,42,21                 ; 14
         db        42,42,63                 ; 15

         db         0,21, 0                 ; 16
         db         0,21,42                 ; 17
         db         0,63, 0                 ; 18
         db         0,63,42                 ; 19
         db        42,21, 0                 ; 20
         db        42,21,42                 ; 21
         db        42,63, 0                 ; 22
         db        42,63,42                 ; 23
         db         0,21,21                 ; 24
         db         0,21,63                 ; 25
         db         0,63,21                 ; 26
         db         0,63,63                 ; 27
         db        42,21,21                 ; 28
         db        42,21,63                 ; 29
         db        42,63,21                 ; 30
         db        42,63,63                 ; 31

         db        21, 0, 0                 ; 32
         db        21, 0,42                 ; 33
         db        21,42, 0                 ; 34
         db        21,42,42                 ; 35
         db        63, 0, 0                 ; 36
         db        63, 0,42                 ; 37
         db        63,42, 0                 ; 38
         db        63,42,42                 ; 39
         db        21, 0,21                 ; 40
         db        21, 0,63                 ; 41
         db        21,42,21                 ; 42
         db        21,42,63                 ; 43
         db        63, 0,21                 ; 44
         db        63, 0,63                 ; 45
         db        63,42,21                 ; 46
         db        63,42,63                 ; 47

         db        21,21, 0                 ; 48
         db        21,21,42                 ; 49
         db        21,63, 0                 ; 50
         db        21,63,42                 ; 51
         db        63,21, 0                 ; 52
         db        63,21,42                 ; 53
         db        63,63, 0                 ; 54
         db        63,63,42                 ; 55
         db        21,21,21                 ; 56
         db        21,21,63                 ; 57
         db        21,63,21                 ; 58
         db        21,63,63                 ; 59
         db        63,21,21                 ; 60
         db        63,21,63                 ; 61
         db        63,63,21                 ; 62
         db        63,63,63                 ; 63

; ------ z†hlav° souboru PCX

PCX      label     byte                     ; z†hlav° souboru PCX
PCXIdent db        10                       ; 0: identifikace souboru
PCXVerze db        5                        ; 1: 5=verze 3.0 s paletou 3*256
PCXMetod db        1                        ; 2: metoda k¢dov†n° PCX
PCXBits  db        8                        ; 3: poáet bitñ/bod v jednÇ rovinà
PCXX1    dw        0                        ; 4: poá†teán° sou©adnice X1
PCXY1    dw        0                        ; 6: poá†teán° sou©adnice Y1
PCXX2    dw        319                      ; 8: koncov† sou©adnice X2
PCXY2    dw        199                      ; 10: koncov† sou©adnice Y2
PCXHoriz dw        320                      ; 12: horiz. rozli®itelnost displeje
PCXVert  dw        200                      ; 14: vert. rozli®itelnost displeje
PCXEga   db           0,   0,   0           ;        áern†
         db           0,   0,4*42           ;        modr†
         db           0,4*42,   0           ;        zelen†
         db           0,4*42,4*42           ;        modrozelen†
         db        4*42,   0,   0           ;        áerven†
         db        4*42,   0,4*42           ;        purpurov†
         db        4*42,4*21,   0           ;        hnàd†
         db        4*42,4*42,4*42           ;        b°l†
         db        4*21,4*21,4*21           ;        ®ed†
         db        4*21,4*21,4*63           ;        svàtle modr†
         db        4*21,4*63,4*21           ;        svàtle zelen†
         db        4*21,4*63,4*63           ;        svàtle modrozelen†
         db        4*63,4*21,4*21           ;        svàtle áerven†
         db        4*63,4*21,4*63           ;        svàtle purpurov†
         db        4*63,4*63,4*21           ;        ëlut†
         db        4*63,4*63,4*63           ;        svàtle b°l†
         db        0                        ; 64: ... nevyuëito
PCXRovin db        1                        ; 65: poáet barevnòch rovin
PCXByte  dw        320                      ; 66: poáet bajtñ na ©†dek obr†zku
PCXInter dw        1                        ; 68: interpretace palety barev
         db        58 dup(0)                ; 70: ... nevyuëito
PCX0     label     byte

PCXVgaX  db        12                       ; oddàlovaá palet 12
PCXVga   db        3*256 dup(0)             ; paleta barev VGA
                                            ; (1) áerven† 0 aë 255
                                            ; (1) zelen† 0 aë 255
                                            ; (1) modr† 0 aë 255

; ------ ukazatele pro kompresi souboru PCX

PCXCit   db        0c0h                     ; á°taá shodnÇho bajtu C0 ...
PCXChar  db        0                        ; opakovanò bajt

; ------ vyhled†v†n° souborñ

Soubory  db        '*.SCR',0                ; specifikace hledanòch souborñ

DTA      db        1eh dup(0)               ; buffer DTA
DTAName  db        13 dup(0)                ; buffer jmÇna souboru
         db        "......."                ; rezerva

; ------ vstupn° soubor

InpIdent dw        0                        ; identifik†tor vstupn°ho souboru
InpRead  dw        0                        ; offset átec° adresy z bufferu
InpNum   dw        0                        ; poáet bajtñ ve vstupn°m bufferu
InpBuff  db        BUFFSIZE dup(0)          ; vstupn° buffer

; ------ vòstupn° soubor

OutIdent dw        0                        ; identifik†tor vòstupn°ho souboru
OutNum   dw        0                        ; poáet bajtñ ve vòstupn°m bufferu
OutBuff  db        BUFFSIZE dup(0)          ; vòstupn° buffer

; ------ adresa bufferu rovin (4 * buffer 64 KB)

Buffer   dw        0                        ; buffer rovin
Buffer2  dw        0                        ; buffer roviny 2

; ------ z†sobn°k

         dw        200h dup(0)              ; pracovn° z†sobn°k
Zasobnik label     word

Code     ENDS
         END       Start

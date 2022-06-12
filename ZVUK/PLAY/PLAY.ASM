
; *****************************************************************************
;
;                             P©ehr†vaá melodi°
;
; *****************************************************************************

; Sluëby rezidentn°ho ovladaáe melodi°:
;    INT 16h;   VSTUP:  AX=3A40h identifik†tor sluëby
;                       BX=27ACh vstupn° identifik†tor PLAY
;                       CX=poáet t¢nñ melodie (nen°-li CX=0 ani 0FFFFh)
;                           CX=0 pouze test stavu
;                           CX=0FFFFh p©eru®en° hry, nulov†n° bufferñ
;                       ES:SI=adresa melodie (pouze nen°-li CX=0 ani 0FFFFh)
;                             t¢n: 1. bajt = á°slo t¢nu 0 aë 120 (0=prodleva)
;                                  2. bajt = dÇlka t¢nu (v 1/18 sekundy)
;               VùSTUP: AH=verze PLAY v BCD k¢du (12h = verze 1.20)
;                       AL=stav: 0=stav klidu
;                                1=buffer pr†zdnò, prob°h† posledn° t¢n
;                                2=melodie p©enesena do vyrovn†vac°ho bufferu
;                                3=zbòv† melodie k p©enesen° do bufferu
;                       BX=82D5h vòstupn° identifik†tor PLAY (= nainstalov†n)
;                       DX=adresa ovladaáe v pamàti (pouze pro intern° pot©ebu)
;   nov† definice melodie p©ep°®e p©°padnò ukazatel starÇ melodie

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       16
bit5     EQU       32
bit6     EQU       64
bit7     EQU       128

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; start a inicializace programu

Buffer   EQU       80h                      ; vyrovn†vac° buffer melodie
                                            ; nië®° bajt=t¢n, vy®®° bajt=dÇlka
         db        200h - 80h - 3 dup(0)    ; zbytek bufferu

Old08    dd        0                        ; pñvodn° adresa INT 08h
Old16    dd        0                        ; pñvodn° adresa INT 16h

RWBuf    label     word
ReadBuf  db        0                        ; átec° offset z bufferu
WritBuf  db        0                        ; z†pisovò offset do bufferu

AdrMel   dd        0                        ; adresa p©ipravenÇ melodie
CitMel   dw        0                        ; poáet zbylòch t¢nñ melodie

CitTon   db        0                        ; á°taá zbylÇ doby trv†n° t¢nu

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 16h (obsluha funkc° p©ehr†vaáe melodi°)
; -----------------------------------------------------------------------------

INT16    PROC      FAR

; ------ test, zda je sluëba PLAY

         pushf
         cmp       ax,3a40h                 ; souhlas° á°slo sluëby ?
         jne       INT161                   ; nesouhlas° á°slo sluëby
         cmp       bx,27ach                 ; souhlas° vstupn° identifik†tor ?
         je        INT162                   ; je sluëba PLAY OK

; ------ pñvodn° obsluha INT 16h

INT161:  popf
         jmp       dword ptr cs:[Old16]     ; skok na pñvodn° obsluhu INT 16h

; ------ pouze dotaz na stav ovladaáe

INT162:  popf
         jcxz      INT168                   ; pouze dotaz na stav ovladaáe

; ------ p©eru®en° hry melodie

         inc       cx                       ; je p©eru®en° hry ?
         jnz       INT163                   ; nen° p©eru®en° hry
         mov       cs:[CitMel],cx           ; zru®en° p©ipravenÇ melodie
         mov       cs:[RWBuf],cx            ; nulov†n° p©echodnÇho bufferu
         mov       cs:[CitTon],cl           ; nulov†n° á°taáe dÇlky t¢nu
         call      PlayOff                  ; vypnut° zvukovÇho gener†toru
         jmp       short INT168             ; n†vrat - test stavu

; ------ nastaven° novÇho ukazatele melodie

INT163:  dec       cx                       ; n†vrat poátu t¢nñ
         mov       word ptr cs:[AdrMel],si  ; offset adresy melodie
         mov       word ptr cs:[AdrMel+2],es ; segment adresy melodie
         mov       cs:[CitMel],cx           ; novò poáet t¢nñ
INT164:  call      NextTon                  ; p©enesen° t¢nu do bufferu
         jnc       INT164                   ; p©enos maxima t¢nñ do bufferu

; ------ test stavu PLAY

INT168:  mov       al,3                     ; p©°znak 3 - je melodie
         cmp       word ptr cs:[CitMel],0   ; zbyly nàjakÇ t¢ny melodie ?
         jne       INT169                   ; zbyly nàjakÇ t¢ny melodie
         dec       ax                       ; p©°znak 2 - pouze vyrovn†vac° buf.
         mov       ah,cs:[ReadBuf]          ; átec° adresa z bufferu
         cmp       ah,cs:[WritBuf]          ; je nàco v bufferu ?
         jne       INT169                   ; je nàco v bufferu
         dec       ax                       ; p©°znak 1 - dohr†v† posledn° t¢n
         cmp       byte ptr cs:[CitTon],0   ; dohr†v† posledn° t¢n ?
         jne       INT169                   ; dohr†v† posledn° t¢n
         dec       ax                       ; jinak p©°znak 0 - stav klidu

; ------ vòstupn° registry PLAY

INT169:  mov       ah,12h                   ; verze ovladaáe PLAY 1.20
         mov       bx,82d5h                 ; vòstupn° identifik†tor PLAY
         push      cs
         pop       dx                       ; DX <- adresa ovladaáe v pamàti
         iret                               ; n†vrat z p©eru®en°

INT16    ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° INT 08h (obsluha zvukovÇho gener†toru)
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ obsluha á°taáe doby jednoho t¢nu

         cmp       byte ptr cs:[CitTon],0   ; je á°taá doby t¢nu vynulov†n ?
         je        Int082                   ; je jië = 0 - dal®° t¢n
         dec       byte ptr cs:[CitTon]     ; sn°ëen° á°taáe doby t¢nu
         jnz       Int089                   ; dal®° áek†n°
         call      PlayOff                  ; konec t¢nu-vypnut° zvuk.gener†toru

; ------ p©enos dal®°ho t¢nu do vyrovn†vac°ho bufferu

Int082:  call      NextTon                  ; p©enos dal®°ho t¢nu do bufferu

; ------ nastaven° dal®°ho t¢nu melodie z vyrovn†vac°ho bufferu

         push      ax
         push      bx
         push      ds

         mov       bh,0
         mov       bl,cs:[ReadBuf]          ; átec° index z bufferu
         cmp       bl,cs:[WritBuf]
         je        Int087                   ; v bufferu nen° ë†dnò t¢n
         shl       bx,1                     ; index * 2 = offset
         mov       bx,cs:[bx+Buffer]        ; dal®° t¢n melodie a jeho dÇlka
         inc       byte ptr cs:[ReadBuf]    ; zvò®en° átec° adresy

         mov       cs:[CitTon],bh           ; á°taá dÇlky jednoho t¢nu
         mov       bh,0                     ; BX=á°slo t¢nu
         shl       bx,1                     ; á°slo t¢nu * 2
         mov       bx,cs:[bx+TabTon-2]      ; dàlic° konstanta t¢nu
         jz        Int087                   ; je prodleva

         mov       al,0b6h
         out       [43h],al
         mov       al,bl                    ; dàlic° konstanta LOW
         out       [42h],al
         mov       al,bh                    ; dàlic° konstanta HIGH
         out       [42h],al
         in        al,[61h]
         or        al,3                     ; zapnut° vòstupu na reproduktor
         out       [61h],al

Int087:  pop       ds
         pop       bx
         pop       ax

Int089:  jmp       dword ptr cs:[Old08]     ; pokraáov†n° v obsluze INT 08h

Int08    ENDP

; -----------------------------------------------------------------------------
;        vypnut° vòstupu na reproduktor
; -----------------------------------------------------------------------------

PlayOff  PROC      NEAR

         push      ax
         cli

; ------ vypnut° vòstupu na reproduktor

         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut° vòstupu na reproduktor

; ------ nastaven° standardn° frekvence gener†toru

         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n°ë®° bajt
         out       [42h],al                 ; konstanta - vy®®° bajt

         pop       ax
         ret

PlayOff  ENDP

; -----------------------------------------------------------------------------
;        p©enesen° t¢nu do bufferu (CY=nen° dal®° t¢n nebo buffer je plnò)
; -----------------------------------------------------------------------------

NextTon  PROC      NEAR

; ------ £schova registrñ

         cli
         push      ax
         push      bx
         push      ds

; ------ test, zda je volnÇ m°sto v bufferu

NextTon1:mov       al,cs:[WritBuf]          ; z†pisov† adresa
         inc       ax                       ; p©°®t° adresa
         cmp       al,cs:[ReadBuf]          ; je buffer plnò ?
         stc                                ; p©°znak plnÇho bufferu
         je        NextTon9                 ; buffer je jië plnò

; ------ test, zda je p©ipraven dal®° t¢n melodie

NextTon2:cmp       word ptr cs:[CitMel],0   ; je dal®° t¢n melodie ?
         stc                                ; p©°znak, ëe nen° dal®° t¢n
         je        NextTon9                 ; nen° dal®° t¢n melodie

; ------ naáten° t¢nu melodie

         lds       bx,cs:[AdrMel]           ; adresa p©ipravenÇ melodie
         mov       al,ds:[bx]               ; t¢n
         inc       bx                       ; zvò®en° ukazatele
         mov       ah,ds:[bx]               ; dÇlka
         inc       bx                       ; zvò®en° ukazatele
         mov       word ptr cs:[AdrMel],bx  ; novò offset adresy melodie
         dec       word ptr cs:[CitMel]     ; sn°ëen° á°taáe zbylòch t¢nñ

; ------ jde-li o neplatnò t¢n, naáten° dal®°ho t¢nu

         cmp       ah,0                     ; je dÇlka t¢nu = 0 ?
         je        NextTon2                 ; neplatn† dÇlka t¢nu - dal®°
         cmp       al,120                   ; maxim†ln° á°slo t¢nu
         ja        NextTon2                 ; neplatnÇ á°slo t¢nu - dal®°

; ------ uloëen° t¢nu do bufferu

         mov       bh,0
         mov       bl,cs:[WritBuf]          ; ukl†dac° adresa
         shl       bx,1                     ; adresa * 2 = offset
         mov       cs:[bx+Buffer],ax        ; uloëen° t¢nu do bufferu
         inc       byte ptr cs:[WritBuf]    ; zvò®en° ukl†dac°ho indexu
                                            ; zde je NC = p©°znak operace OK
; ------ n†vrat registrñ

NextTon9:pop       ds
         pop       bx
         pop       ax
         ret

NextTon  ENDP

; -----------------------------------------------------------------------------
;        tabulka dàlic°ch konstant t¢nñ
; -----------------------------------------------------------------------------

TabTon   label     word                     ; tabulka pro nastaven° t¢nñ
         dw        36485,34437,32505,30680,28958,27333 ; okt†va 0
         dw        25799,24351,22984,21694,20477,19327
         dw        18243,17219,16252,15340,14479,13667 ; okt†va 1
         dw        12899,12175,11492,10847,10238,9664
         dw        9121,8609,8126,7670,7240,6833       ; okt†va 2
         dw        6450,6088,5746,5424,5119,4832
         dw        4561,4305,4063,3835,3620,3417       ; okt†va 3
         dw        3225,3044,2873,2712,2560,2416
         dw        2280,2152,2032,1918,1810,1708       ; okt†va 4
         dw        1612,1522,1437,1356,1280,1208
         dw        1140,1076,1016,959,905,854          ; okt†va 5
         dw        806,761,718,678,640,604
         dw        570,538,508,479,452,427             ; okt†va 6
         dw        403,380,359,339,320,302
         dw        285,269,254,240,226,214             ; okt†va 7
         dw        202,190,180,169,160,151
         dw        143,135,127,120,113,107             ; okt†va 8
         dw        101,95,90,85,80,75
         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt†va 9

; *****************************************************************************
;
;        Start a inicializace programu
;
; *****************************************************************************

; ------ £vodn° dek¢dov†n° p©ep°naáñ

Init:    call      DekPrep                  ; dek¢dov†n° p©ep°naáñ
         jnc       Init1                    ; p©ep°naáe dek¢dov†ny OK
         mov       dx,offset HelpTxt        ; text n†povàdy
         mov       ah,9
         int       21h                      ; zobrazen° n†povàdy
         mov       ax,4c02h                 ; n†vrat s chybou
         int       21h                      ; konec programu s chybou

; ------ test stavu instalace ovladaáe

Init1:   call      TestPlay                 ; test stavu instalace PLAY
         jnc       Init2                    ; je nainstalov†n OK
         or        byte ptr ds:[Param],bit2 ; p©°znak novÇ instalace

; ------ £schova staròch adres p©eru®en°

         mov       ax,3516h
         int       21h                      ; poskytnut° adresy INT 16h
         mov       word ptr ds:[Old16],bx   ; offset pñvodn° adresy INT 16h
         mov       word ptr ds:[old16+2],es ; segment pñvodn° adresy INT 16h
         mov       ax,3508h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; offset pñvodn° adresy INT 08h
         mov       word ptr ds:[old08+2],es ; segment pñvodn° adresy INT 08h

; ------ instalace novòch obsluh p©eru®en°

         mov       dx,offset INT16
         mov       ax,2516h
         int       21h                      ; instalace obsluhy INT 16h
         mov       dx,offset INT08
         mov       ax,2508h
         int       21h                      ; instalace obsluhy INT 08h

; ------ instalace obsluhy INT 23h

Init2:   mov       ax,2523h
         mov       dx,offset INT23
         int       21h

; ------ p©eru®en° p©ede®lÇ melodie

         test      byte ptr ds:[Param],bit0 ; je p©eru®en° p©ede®lÇ melodie ?
         jz        Init3                    ; nen° p©eru®en° p©ede®lÇ melodie
         mov       cx,-1                    ; p©°znak p©eru®en° melodie
         call      IntPlay                  ; p©eru®en° melodie

; ------ p©enesen° textu v uvozovk†ch

Init3:   mov       si,ds:[AdrSoub]          ; adresa textu v uvozovk†ch
         or        si,si                    ; bylo nàco zad†no ?
         jz        Init8                    ; nebylo nic zad†no
         test      byte ptr ds:[Param],bit3 ; je text v uvozovk†ch ?
         mov       dx,si                    ; adresa jmÇna souboru
         jz        Init6                    ; nen° text v uvozovk†ch
         mov       di,offset BuffInp        ; vstupn° bufferu
         push      ds
         pop       es
         cld
Init4:   lodsb                              ; naáten° znaku
         cmp       al,'"'                   ; konec textu ?
         je        Init5                    ; konec textu
         cmp       al,0                     ; konec textu ?
         je        Init5                    ; konec textu
         stosb                              ; uloëen° znaku
         jmp       short Init4              ; dal®° znak
Init5:   sub       di,offset BuffInp        ; dÇlka textu
         mov       ds:[BuffINum],di         ; dÇlka textu
         jmp       short Init7              ; dek¢dov†n° textu

; ------ otev©en° souboru s melodi°

Init6:   mov       ax,3d00h
         int       21h                      ; otev©en° souboru
         mov       ds:[FileIdn],ax          ; identifik†tor souboru

; ------ chyba - soubor nenalezen

         jnc       Init7                    ; soubor nalezen OK
         mov       dx,offset FileTxt        ; chyba - soubor nenalezen
         mov       ah,9
         int       21h                      ; zobrazen° chybovÇho hl†®en°
         jmp       Init8                    ; konec

; ------ dek¢dov†n° souboru/textu v bufferu

Init7:   call      DekMel                   ; dek¢dov†n° melodie

; ------ áek†n° na p©enesen° melodie do bufferu

Init71:  call      TestBrk                  ; test p©eru®en°
         call      TestPlay                 ; test stavu melodie
         jc        Init72
         cmp       al,3                     ; je melodie p©enesena ?
         je        Init71                   ; áek†n° na p©enesen° melodie

; ------ z†pis zbytku melodie do bufferu

         mov       si,offset BuffDek        ; buffer s dek¢dovanou melodi°
         mov       cx,ds:[BuffDNum]         ; poáet t¢nñ v bufferu
         push      ds
         pop       es
         jcxz      Init72
         call      IntPlay                  ; z†pis melodie do bufferu

; ------ uzav©en° souboru

Init72:  test      byte ptr ds:[Param],bit3 ; je text v uvozovk†ch ?
         jnz       Init8                    ; je text v uvozovk†ch
         mov       bx,ds:[FileIdn]          ; identifik†tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ konec - áek†n° na p©enesen° melodie do bufferu

Init8:   call      TestBrk                  ; test p©eru®en°
         call      TestPlay                 ; test stavu melodie
         jc        Init81
         cmp       al,3                     ; je melodie p©enesena ?
         je        Init8                    ; áek†n° na p©enesen° melodie

; ------ áek†n° na ukonáen° hry

Init81:  test      byte ptr ds:[Param],bit1 + bit4 ; odinstal. nebo áek†n° ?
         jz        Init83                   ; nen° ani odinst. ani áek†n°
Init82:  call      TestBrk                  ; test p©eru®en°
         call      TestPlay                 ; test stavu melodie
         jc        Init83
         cmp       al,0                     ; je dokonáena melodie ?
         jne       Init82                   ; áek†n° na dokonáen° melodie

; ------ test, zda je odinstalov†n°

Init83:  test      byte ptr ds:[Param],bit1 ; je odinstalov†n° programu ?
         jnz       Init87                   ; je odinstalov†n° programu

; ------ nainstalov†n° novÇho programu

         test      byte ptr ds:[Param],bit2 ; je to nov† instalace ?
         jz        Init92                   ; nen° nov† instalace - konec
         mov       dx,offset InstTxt
         mov       ah,9
         int       21h                      ; hl†®en°, ëe byl nainstalov†n
         mov       es,ds:[2ch]              ; segment prost©ed°
         mov       ah,49h
         int       21h                      ; uvolnàn° prost©ed°
         mov       dx,offset Init           ; konec rezidentn° á†sti
         int       27h                      ; instalace

; ------ odinstalov†n° programu

Init87:  call      TestPlay                 ; poskytnut° adresy rezidentu
         jc        Init92

; ------ kontrola adres p©eru®en°

         mov       ax,3508h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       ax,es
         cmp       ax,dx                    ; kontrola adresy INT 08h
         jne       Init88                   ; nelze odinstalovat
         mov       ax,3516h
         int       21h                      ; poskytnut° adresy INT 16h
         mov       ax,es
         cmp       ax,dx                    ; kontrola adresy INT 16h
         je        Init9

; ------ chyba - nelze odinstalovat

Init88:  mov       dx,offset DI2Txt         ; chyba - nelze odinstalovat
         mov       ah,9
         int       21h                      ; zobrazen° textu chyby
         mov       ax,4c01h
         int       21h

; ------ odinstalov†n° programu

Init9:   push      ds
         lds       dx,es:[Old08]
         mov       ax,2508h
         int       21h                      ; n†vrat adresy INT 08h
         lds       dx,es:[Old16]
         mov       ax,2516h
         int       21h                      ; n†vrat adresy INT 16h
         pop       ds

; ------ uvolnàn° alokaán°ho bloku

         test      byte ptr ds:[Param],bit2 ; je nov† instalace ?
         jnz       Init92                   ; je nov† instalace
         mov       ah,49h
         int       21h                      ; uvolnàn° alokaán°ho bloku
         mov       dx,offset DI1Txt
         mov       ah,9
         int       21h                      ; zobrazen° hl†®en°
Init92:  int       20h

; -----------------------------------------------------------------------------
;        p©eru®en° programu INT 23h
; -----------------------------------------------------------------------------

INT23    PROC      FAR

         push      cs
         pop       ds

         mov       cx,-1                    ; p©°znak p©eru®en° melodie
         call      IntPlay                  ; p©eru®en° melodie
         jmp       Init8

INT23    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° melodie
; -----------------------------------------------------------------------------

DekMel   PROC      NEAR

; ------ naáten° dal®°ho znaku

DekMel1: call      InpChr                   ; naáten° dal®°ho znaku ze souboru
         jnc       DekMel2                  ; je dal®° znak
         ret                                ; n†vrat - nen° dal®° znak

; ------ zvò®en° t¢nu o pñlt¢n "#"

DekMel2: cmp       al,"#"                   ; je zvò®en° o pñlt¢n ?
         jne       DekMel30                 ; nen° zvò®en° o pñlt¢n
         inc       word ptr ds:[Krizky]     ; zvò®en° o pñlt¢n
         jmp       short DekMel1            ; dal®° znak

; ------ sn°ëen° t¢nu o pñlt¢n "B"

DekMel30:cmp       al,"B"                   ; je sn°ëen° o pñlt¢n ?
         jne       DekMel31                 ; nen° sn°ëen° o pñlt¢n
         dec       word ptr ds:[Krizky]     ; sn°ëen° o pñlt¢n
         jmp       short DekMel1            ; dal®° znak

; ------ zvò®en° o okt†vu "+"

DekMel31:cmp       al,"+"                   ; je zvò®en° o okt†vu ?
         jne       DekMel32                 ; nen° zvò®en° o okt†vu
         add       word ptr ds:[Oktava],12  ; zvò®en° o okt†vu
         jmp       short DekMel1            ; dal®° znak

; ------ sn°ëen° o okt†vu "-"

DekMel32:cmp       al,"-"                   ; je sn°ëen° o okt†vu ?
         jne       DekMel33                 ; nen° sn°ëen° o okt†vu
         sub       word ptr ds:[Oktava],12  ; sn°ëen° o okt†vu
         jmp       short DekMel1            ; dal®° znak

; ------ korekce rychlosti hry

DekMel33:cmp       al,"S"                   ; je korekce rychlosti hry ?
         jne       DekMel34
         call      InpNum                   ; vstup á°sla
         jc        DekMel11
         mov       ds:[KorDelk],al          ; korekce rychlosti hry
         jmp       short DekMel1

; ------ nastaven° okt†vy "O"

DekMel34:cmp       al,"O"                   ; je nastaven° okt†vy ?
         jne       DekMel35                 ; nen° nastaven° okt†vy
         call      InpNum                   ; vstup á°sla
         jc        DekMel11
         mov       ah,12                    ; dÇlka 1 okt†vy
         mul       ah                       ; offset okt†vy v tabulce
         mov       ds:[Oktava],ax           ; nastaven° offsetu okt†vy
DekMel11:jmp       short DekMel1            ; dal®° znak

; ------ prodleva

DekMel35:xor       cx,cx                    ; dek¢dovanÇ á°slo t¢nu
         cmp       al,"R"                   ; je prodleva ?
         je        DekMel36                 ; je prodleva

; ------ t¢n

         push      ds
         pop       es
         mov       di,offset Tony           ; tabulka jmen t¢nñ
         mov       cx,12                    ; dÇlka tabulky
         cld
         repne     scasb                    ; nalezen° t¢nu v tabulce
         jne       DekMel11                 ; t¢n nenalezen - dal®° znak
         inc       cx                       ; korekce á°sla t¢nu

; ------ stanoven° á°sla t¢nu

         add       cx,ds:[Oktava]           ; zaá†tek okt†vy
         add       cx,ds:[Krizky]           ; p©iáten° k©°ëkñ
         mov       word ptr ds:[Krizky],0   ; nulov†n° k©°ëkñ
         cmp       cx,120                   ; kontrola á°sla t¢nu
         jbe       DekMel36                 ; á°slo t¢nu je OK
         xor       cx,cx                    ; mimo rozsah - nahrazen° prodlevou

; ------ stanoven° dÇlky t¢nu

DekMel36:call      InpNum                   ; vstup dÇlky t¢nu
         jc        DekMel38                 ; nen° zad†na dÇlka t¢nu
         cmp       al,7                     ; maxim†ln° dÇlka t¢nu
         jbe       DekMel37                 ; dÇlka t¢nu je OK
         mov       al,7                     ; omezen° dÇlky t¢nu
DekMel37:push      cx
         mov       cl,al                    ; dÇlka t¢nu
         mov       al,1                     ; konstanta dÇlky
         shl       al,cl                    ; vòpoáet doby t¢nu
         mov       ds:[Delka],al            ; nastaven° dÇlky t¢nu
         pop       cx

; ------ prodlouëen° doby o pñlt¢n

DekMel38:mov       ch,ds:[Delka]            ; dÇlka t¢nu
         call      InpChr                   ; vstup dal®°ho znaku
         jc        DekMel3A                 ;
         cmp       al,"."                   ; je prodlouëen° o pñlt¢n ?
         je        DekMel39                 ; je prodlouëen° o pñlt¢n
         call      InpRet                   ; n†vrat znaku do bufferu
         jmp       short DekMel3A
DekMel39:mov       al,ch                    ; doba
         shr       al,1                     ; polovina doby
         add       ch,al                    ; prodlouëen° doby o pñlt¢n
         jc        DekMel3B                 ; p©eteáen°

; ------ korekce rychlosti hry

DekMel3A:mov       al,ch                    ; dÇlka t¢nu
         mul       byte ptr ds:[KorDelk]    ; korekce dÇlky t¢nu
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; korekce / 9
         add       ch,al                    ; p©iáten° korekce dÇlky
         jnc       DekMel3C
DekMel3B:mov       ch,255                   ; omezen° dÇlky t¢nu

; ------ vypr†zdnàn° bufferu

DekMel3C:cmp       word ptr ds:[BuffDNum],40h ; je buffer jië plnò ?
         jb        DekMel8

; ------ áek†n° na uvolnàn° bufferu

DekMel7: call      TestBrk                  ; test p©eru®en°
         call      TestPlay                 ; test stavu
         cmp       al,3                     ; je melodie p©enesena ?
         je        DekMel7                  ; áek†n° na p©enos melodie

; ------ z†pis melodie do bufferu

         push      cx
         mov       si,offset BuffDek        ; buffer s dek¢dovanou melodi°
         mov       cx,ds:[BuffDNum]         ; poáet t¢nñ v bufferu
         push      ds
         pop       es
         call      IntPlay                  ; z†pis melodie do bufferu
         mov       word ptr ds:[BuffDNum],0 ; zru®en° dat v bufferu
         pop       cx

; ------ áek†n° na p©enos melodie do bufferu

DekMl72: call      TestBrk                  ; test p©eru®en°
         call      TestPlay                 ; test stavu
         cmp       al,3                     ; je melodie p©enesena ?
         je        DekMl72                  ; áek†n° na p©enos melodie

; ------ uloëen° novÇho t¢nu do bufferu

DekMel8: mov       di,ds:[BuffDNum]
         shl       di,1
         mov       ds:[di+BuffDek],cx       ; uloëen° t¢nu do bufferu
         inc       word ptr ds:[BuffDNum]   ; zvò®en° poátu t¢nñ v bufferu
         jmp       DekMel1

DekMel   ENDP

; -----------------------------------------------------------------------------
;        vstup á°slice
; -----------------------------------------------------------------------------

InpNum   PROC      NEAR

; ------ naáten° á°slice

         call      InpChr
         jc        InpNum9
         cmp       al,"0"
         jb        InpNum8
         cmp       al,"9"
         ja        InpNum8
         sub       al,"0"
         ret

; ------ n†vrat p©i chybà

InpNum8: call      InpRet
InpNum9: stc
         ret

InpNum   ENDP

; -----------------------------------------------------------------------------
;        n†vrat znaku do bufferu
; -----------------------------------------------------------------------------

InpRet   PROC      NEAR

         mov       ds:[BuffChr],al          ; n†vrat znaku do bufferu
         ret

InpRet   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku ze souboru
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

         mov       al,0
         xchg      al,ds:[BuffChr]          ; uschovanò znak
         or        al,al                    ; byl v bufferu znak ?
         jz        InpChr0                  ; nebyl v bufferu znak
         ret

InpChr0: push      si

; ------ test, zda je v bufferu p©ipraven dal®° znak

InpChr1: mov       si,ds:[BuffIRd]          ; átec° offset z bufferu
         cmp       ds:[BuffINum],si         ; je dal®° znak ?
         ja        InpChr8                  ; je p©ipraven dal®° znak

; ------ text v uvozovk†ch - nen° dal®° znak

         test      byte ptr ds:[Param],bit3 ; je text v uvozovk†ch ?
         stc                                ; p©°znak, ëe nen° dal®° znak
         jnz       InpChr9                  ; nen° dal®° znak

; ------ naáten° dal®°ho bloku ze souboru

         xor       si,si
         mov       ds:[BuffIRd],si          ; átec° offset z bufferu

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,3fh
         mov       bx,ds:[FileIdn]          ; identifik†tor souboru
         mov       cx,offset(BuffEnd-BuffInp) ; velikost bufferu
         mov       dx,offset BuffInp        ; vstupn° buffer
         int       21h                      ; naáten° bloku dat ze souboru

         jnc       InpChr3                  ; operace OK
         xor       ax,ax                    ; chyba - nejsou ë†dn† data
InpChr3: mov       ds:[BuffINum],ax         ; poáet znakñ v bufferu
         or        ax,ax                    ; jsou nàjak† data ?

         pop       dx
         pop       cx
         pop       bx
         pop       ax

         stc
         jz        InpChr9                  ; nejsou dal®° data

; ------ naáten° dal®°ho znaku z bufferu

InpChr8: mov       al,ds:[si+BuffInp]       ; dal®° znak
         inc       word ptr ds:[BuffIRd]    ; nov† átec° adresa z bufferu
         cmp       al,"a"
         jb        InpChr82
         cmp       al,"z"
         ja        InpChr82
         sub       al,32                    ; p©evod na velkÇ p°smeno

; ------ ignorov†n° znakñ

InpChr82:cmp       al," "
         je        InpChr1                  ; mezera se ignoruje
         cmp       al,9
         je        InpChr1                  ; tabel†tor se ignoruje

; ------ pozn†mka

         cmp       al,13
         jne       InpChr83
         and       byte ptr ds:[Param],not bit5 ; zru®en° p©°znaku pozn†mky
InpChr83:test      byte ptr ds:[Param],bit5 ; je pozn†mka ?
         jnz       InpChr1                  ; je pozn†mka
         cmp       al,";"
         jne       InpChr84                 ; nen° pozn†mka
         or        byte ptr ds:[Param],bit5 ; p©°znak pozn†mky
         jmp       short InpChr1            ; dal®° znak

InpChr84:clc
InpChr9: pop       si
         ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;        test stavu PLAY (CY=nenainstalov†n) - vrac° v AL stav, DX=adresa
; -----------------------------------------------------------------------------

TestPlay PROC      NEAR

         push      bx
         push      cx

         mov       ax,3a40h                 ; identifik†tor sluëby
         mov       bx,27ach                 ; vstupn° identifik†tor
         xor       cx,cx                    ; p©°znak testu stavu
         int       16h                      ; test stavu instalace
         cmp       bx,82d5h                 ; je ovladaá nainstalov†n ?
         je        TestPla9                 ; je nainstalov†n OK
         stc                                ; p©°znak, ëe nen° instalace

TestPla9:pop       cx
         pop       bx
         ret

TestPlay ENDP

; -----------------------------------------------------------------------------
;        obsluha sluëby PLAY
; -----------------------------------------------------------------------------

IntPlay  PROC      NEAR

         push      bx
         mov       ax,3a40h                 ; identifik†tor sluëby
         mov       bx,27ach                 ; vstupn° identifik†tor
         int       16h                      ; test stavu instalace
         pop       bx
         ret

IntPlay ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° p©ep°naáñ (CY=chyba)
; -----------------------------------------------------------------------------

DekPrep  PROC      NEAR

; ------ p©°prava k dek¢dov†n° p©°kazovÇho ©†dku

         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       bh,0
         mov       bl,ds:[si-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       byte ptr ds:[si+bx],bh   ; oznaáen° konce textu

; ------ nalezen° zaá†tku jednoho parametru

DekPrep1:call      DekSpc                   ; vypu®tàn° mezer
         call      DekCh                    ; naáten° znaku
         jc        DekPrp88                 ; nen° dal®° znak
         cmp       al,"?"                   ; poëaduje se n†povàda ?
         stc                                ; p©°znak chyby
         je        DekPrep9                 ; poëaduje se n†povàda

; ------ p©eskoáen° textu v uvozovk†ch

         cmp       al,'"'                   ; jsou uvozovky ?
         jne       DekPrep3                 ; nejsou uvozovky
         cmp       word ptr ds:[AdrSoub],0  ; je jië soubor ?
         jne       DekPrep2                 ; je jië soubor
         or        byte ptr ds:[Param],bit3 ; p©°znak textu v uvozovk†ch
         mov       ds:[AdrSoub],si          ; adresa textu v uvozovk†ch
DekPrep2:call      DekCh                    ; naáten° dal®°ho znaku
         jc        DekPrp88                 ; konec textu
         cmp       al,'"'                   ; jsou p†rovÇ uvozovky ?
         jne       DekPrep2                 ; nalezen° dal®°ch uvozovek
         jmp       short DekPrep1           ; dal®° parametr

; ------ p©eskoáen° jmÇna souboru

DekPrep3:cmp       al,"/"                   ; je oddàlovaá parametrñ ?
         je        DekPrep5                 ; jsou parametry
         cmp       word ptr ds:[AdrSoub],0  ; je jië soubor ?
         jne       DekPrep4                 ; je jië soubor
         dec       si                       ; n†vrat zaá†tku jmÇna souboru
         mov       ds:[AdrSoub],si          ; adresa textu v uvozovk†ch
DekPrep4:call      DekCh                    ; naáten° dal®°ho znaku
DekPrp88:jc        DekPrep8                 ; konec textu
         jne       DekPrp42                 ; je platnò znak
         mov       byte ptr ds:[si-1],0     ; oznaáen° konce jmÇna souboru
         jmp       short DekPrep1           ; je mezera - dal®° parametr
DekPrp42:cmp       al,"/"                   ; oddàlovaá parametrñ ?
         jne       DekPrep4                 ; dal®° znak
         mov       byte ptr ds:[si-1],0     ; oznaáen° konce jmÇna souboru

; ------ naáten° znaku parametru

DekPrep5:call      DekSpc                   ; vypu®tàn° mezer
         call      DekCh                    ; naáten° znaku
         jc        DekPrep9                 ; nen° znak - to je chyba

; ------ p©evod znaku na velkÇ p°smeno

         cmp       al,"a"
         jb        DekPrep6
         cmp       al,"z"
         ja        DekPrep6
         sub       al,32                    ; p©evod na velkÇ p°smeno

; ------ parametr "/S" - p©eru®en° p©ede®lÇ melodie

DekPrep6:cmp       al,"S"                   ; je parametr "/S" ?
         jne       DekPrp62                 ; nen° parametr "/S"
         or        byte ptr ds:[Param],bit0 ; p©°znak parametru "/S"
DekPrp11:jmp       short DekPrep1           ; dek¢dov†n° dal®°ho parametru

; ------ parametr "/W" - áek†n° na ukonáen° melodie

DekPrp62:cmp       al,"W"                   ; je parametr "/W" ?
         jne       DekPrep7                 ; nen° parametr "/W"
         or        byte ptr ds:[Param],bit4 ; p©°znak parametru "/W"
         jmp       short DekPrp11           ; dek¢dov†n° dal®°ho parametru

; ------ parametr "/!" - odinstalov†n° programu

DekPrep7:cmp       al,"!"                   ; je parametr "/!" ?
         stc                                ; p©°znak chyby
         jne       DekPrep9                 ; nen° parametr "/!"
         or        byte ptr ds:[Param],bit1 ; p©°znak parametru "/!"
         jmp       short DekPrp11           ; dek¢dov†n° dal®°ho parametru

DekPrep8:clc
DekPrep9:ret

DekPrep  ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z textu
; -----------------------------------------------------------------------------

DekSpc   PROC      NEAR

         call      DekCh                    ; naáten° znaku
         jc        DekSpc2                  ; konec ©†dku
         je        DekSpc                   ; mezera - dal®° znak
         dec       si                       ; n†vrat posledn°ho znaku
DekSpc2: ret

DekSpc   ENDP

; -----------------------------------------------------------------------------
;        naáten° znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

DekCh    PROC      NEAR

         cld
         lodsb                              ; naáten° znaku

         cmp       al,9
         jne       DekCh1
         mov       al," "                   ; n†hrada tabel†toru mezerou
DekCh1:  cmp       al," "                   ; je mezera ?
         jae       DekCh2                   ; je platnò znak nebo mezera
         dec       si                       ; konec ©†dku - n†vrat znaku
         mov       byte ptr ds:[si],0       ; oznaáen° konce textu

DekCh2:  ret

DekCh    ENDP

; -----------------------------------------------------------------------------
;        test p©eru®en° DOS
; -----------------------------------------------------------------------------

TestBrk  PROC      NEAR

         sti
         push      ax
         mov       ah,0bh
         int       21h                      ; test standardn°ho vstupu
         pop       ax
         ret

TestBrk  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Param    db        0                        ; parametry
                                            ;  bit 0: 1=p©eru®en° melodie "/S"
                                            ;  bit 1: 1=odinstalov†n° prog. "/!"
                                            ;  bit 2: 1=je nov† instalace PLAY
                                            ;  bit 3: 1=je text v uvozovk†ch
                                            ;  bit 4: 1=áek†n° na ukonáen° "/W"
                                            ;  bit 5: 1=je pozn†mka

AdrSoub  dw        0                        ; adresa jmÇna souboru/textu v uvoz.

InstTxt  db        'PLAY byl nainstalovan do pameti.',13,10,'$'
DI1Txt   db        'PLAY byl odinstalovan z pameti.',13,10,'$'
DI2Txt   db        'PLAY nelze odinstalovat - odinstalujte nejdrive',13,10
         db        'programy naionstalovane po nem.',13,10,'$'

; ------ obsluha t¢nu (dek¢dov†n°)

Krizky   dw        0                        ; p©echodn† transpozice (pro t¢n)
Oktava   dw        12*4                     ; trval† transpozice
Delka    db        4                        ; dÇlka t¢nu
Tony     db        'H A G FE D C'           ; jmÇna t¢nñ
KorDelk  db        0                        ; korekce dÇlky t¢nu

; ------ dek¢dovac° buffer

BuffDNum dw        0                        ; poáet t¢nñ v dek¢dovac°m bufferu
BuffDek  dw        40h dup(0)               ; buffer k dek¢dov†n° melodie

; ------ vstupn° buffer

FileIdn  dw        0                        ; identifik†tor souboru
BuffINum dw        0                        ; poáet znakñ ve vstupn°m bufferu
BuffIRd  dw        0                        ; átec° offset ze vstupn°ho bufferu

BuffChr  db        0                        ; uschovanò znak

BuffInp  label     byte                     ; zaá†tek vstupn°ho bufferu
HelpTxt  db        'PLAY V1.20 - prehravac melodii; (c) Miroslav Nemecek',13,10
         db        'Zadejte:  soubor    - soubor s melodii',13,10
         db        '--------  "melodie" - melodie k prehrati',13,10
         db        '          /S        - preruseni predesle melodie',13,10
         db        '          /W        - cekani na ukonceni melodie',13,10
         db        '          /!        - odinstalovani z pameti',13,10
         db        13,10
         db        'Syntaxe melodie:',13,10
         db        '----------------',13,10
         db        'C,D,E,F,G,A,H,R  = tony (R=prodleva)',13,10
         db        '# pred tonem     = zvyseni nasledujiciho tonu o pulton',13,10
         db        'B pred tonem     = snizeni nasledujiciho tonu o pulton',13,10
         db        '0 az 7 za tonem  = delka tonu (plati i pro nasledujici tony)',13,10
         db        '                   zvyseni cisla o 1 odpovida zdvojnasobeni delky',13,10
         db        '+ (-) pred tonem = zvyseni (snizeni) oktavy o 1',13,10
         db        '. za tonem       = prodlouzeni tonu o polovinu (musi byt za cislici delky)',13,10
         db        'On               = nastaveni oktavy (n=0 az 9)',13,10
         db        'Sn               = korekce rychlosti hry (n=0 az 9)',13,10
         db        '                   0=bezna rychlost ... 8=polovicni rychlost',13,10
         db        ';                = komentar az do konce radku',13,10
         db        '$'

FileTxt  db        'Chybne zadani jmena souboru !',13,10,'$'

BuffEnd  label     byte                     ; konec vstupn°ho bufferu

Code     ENDS
         END       Start

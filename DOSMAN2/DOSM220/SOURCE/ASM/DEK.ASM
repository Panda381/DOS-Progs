
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                  D E K O D
;                                 dek¢dov†n°
; =============================================================================
;
;        TestWrd   - test, zda je zaá†tek slova
;        DekTTex   - dek¢dov†n° textu
;
;        GetSDate  - poskytnut° systÇmovÇho data ve tvaru souborñ
;        GetSTime  - poskytnut° systÇmovÇho áasu ve tvaru souborñ
;        DekSTime  - dek¢dov†n° aktu†ln°ho systÇmovÇho áasu do bufferu
;        DekSDate  - dek¢dov†n° aktu†ln°ho systÇmovÇho data do bufferu
;        DekDate   - dek¢dov†n° data do bufferu (rok 4 pozice)
;
;        DekNumB   - dek¢dov†n° bajtu od levÇho okraje
;        DekNumW   - dek¢dov†n° slova od levÇho okraje
;        DekNum    - dek¢dov†n° dvojslova od levÇho okraje
;        DekHWord  - dek¢dov†n° slova v HEX k¢du
;        DekHByte  - dek¢dov†n° bajtu v HEX k¢du
;        DekBByte  - dek¢dov†n° bajtu v BIN m¢du
;        Dek10Num  - dek¢dov†n° dvojslova zprava s omezen°m na 10 pozic
;        DekNumD   - dek¢dov†n° dvojslova od pravÇho okraje
;
;        TestKonc  - test koncovky á°sla (zda je "1", "2"-"4" nebo "5" a v°ce)
;        KonvFnt   - konverze n†rodn°ch znakñ v bufferu
;        KonvUpC   - konverze malòch p°smen na velk† v bufferu
;        KonvDnC   - konverze velkòch p°smen na mal† v bufferu
;
;        DekUkaz   - dek¢dov†n° ukazatele (kurzoru)
;
;        DownCase  - p©evod p°smene na malÇ p°smeno
;        UpCase    - p©evod p°smene na velkÇ p°smeno
;
;        TabTypCh (BYTE) - tabulka typñ znakñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeDek  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDek,ds:Data

; *****************************************************************************
;                               TestWrd
;                      test, zda je zaá†tek slova
; -----------------------------------------------------------------------------
; VSTUP: AL=prvn° testovanò znak
;        AH=druhò testovanò znak
; VùSTUP:CY=nen° zaá†tek slova
; *****************************************************************************

TestWrd  PROC      FAR

         push      ax
         push      bx
         push      ds

         push      cs
         pop       ds                       ; DS <- segment tabulky
         mov       bx,offset TabTypCh       ; tabulka typñ znakñ
         xlat                               ; hodnota prvn°ho znaku
         xchg      ah,al                    ; AH <- prvn° znak
         xlat                               ; hodnota druhÇho znaku
         and       ax,303h                  ; maskov†n° hodnot znakñ
         dec       ax                       ; druhò znak - 1 (mus° bòt vàt®°)
         cmp       al,ah                    ; porovn†n° hodnot znakñ

         pop       ds
         pop       bx
         pop       ax
         ret

TestWrd  ENDP

; *****************************************************************************
;                                DekTText
;                            dek¢dov†n° textu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text (zaá°n† bajtem - dÇlka textu)
;        AH=barva textu
;        ES:DI=buffer k uloëen° textu
; VùSTUP:DS:SI=adresa za textem
;        ES:DI=adresa za textem
; *****************************************************************************

DekTText PROC      FAR

         push      ax
         push      cx

         mov       ch,0
         mov       cl,ds:[si]               ; dÇlka textu
         inc       si
         jcxz      DekTTxt2                 ; dÇlka textu = 0
         cld
DekTTxt1:lodsb
         stosw
         loop      DekTTxt1

DekTTxt2:pop       cx
         pop       ax
         ret

DekTText ENDP

; *****************************************************************************
;                                 GetSDate
;                poskytnut° systÇmovÇho data ve tvaru souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:DX=systÇmovÇ datum ve tvaru souborñ
; *****************************************************************************

GetSDate PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ poskytnut° systÇmovÇho data

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         sub       cx,1980                  ; rok - 1980
         shl       cx,9-8                   ; CL <- rok*2
         xchg      dh,cl                    ; CL <- màs°c, DH <- rok (bit9 - 15)
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; CX <- màs°c (bit 5 aë bit 8)
         or        dx,cx                    ; vòslednÇ datum

; ------ n†vrat registrñ

         pop       cx
         pop       bx
         pop       ax
         ret

GetSDate ENDP

; *****************************************************************************
;                                 GetSTime
;                poskytnut° systÇmovÇho áasu ve tvaru souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:DX=systÇmovò áas ve tvaru souborñ
; *****************************************************************************

GetSTime PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ poskytnut° systÇmovÇho áasu

         mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         mov       al,cl                    ; AL <- minuta
         mov       ah,0
         mov       dl,dh                    ; DL <- sekunda
         shr       dl,1                     ; DL = sekunda / 2
         mov       cl,11-8                  ; poáet rotac°
         shl       ch,cl                    ; CH <- hodina (bit 11 aë bit 15)
         mov       dh,ch                    ; DH <- hodina (bit 11 aë bit 15)
         mov       cl,5                     ; poáet rotac°
         shl       ax,cl                    ; AX <- minuta (bit 5 aë bit 10)
         or        dx,ax                    ; p©id†n° minuty

; ------ n†vrat registrñ

         pop       cx
         pop       bx
         pop       ax
         ret

GetSTime ENDP

; *****************************************************************************
;                                  DekSTime
;                  dek¢dov†n° aktu†ln°ho systÇmovÇho áasu
; -----------------------------------------------------------------------------
; VSTUP: AH=atribut barvy
;        ES:DI=buffer (pro 8 znakñ)
;        DS=datovò segment
; VùSTUP:ES:DI=n†sleduj°c° adresa
; *****************************************************************************

DekSTime PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava registrñ

         mov       bh,ah                    ; atribut barvy textu
         mov       bl,ds:[ZnakTim]          ; znak oddàlovaáe áasu
         cld

; ------ zji®tàn° systÇmovÇho áasu (1573040 impulsñ za den = 18.20648 Hz)

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; áten° nië®° á†sti á°taáe áasu
         mov       dx,ds:[46eh]             ; áten° vy®®° á†sti á°taáe áasu
         and       dx,1fh                   ; omezen° pro p©°pad p©eteáen°
         pop       ds

; ------ áas * 65536 / 59659 -> sekunda * 20

         mov       cx,59659
         div       cx
         xchg      ax,si
         xor       ax,ax
         div       cx
         xchg      ax,si                    ; AX:SI = sekunda * 20

; ------ vòpoáet sekundy

         xor       dx,dx
         mov       cx,20
         div       cx
         xchg      ax,si
         div       cx
         mov       dx,si                    ; DX:AX = sekunda

; ------ dek¢dov†n° hodiny

         mov       cx,60*60                 ; poáet sekund na hodinu
         div       cx                       ; vòpoáet hodiny
         call      DekSTm                   ; dek¢dov†n° hodiny

; ------ oddàlovaá áasu

         xchg      ax,bx
         stosw
         xchg      ax,bx

; ------ dek¢dov†n° minuty

         xchg      ax,dx
         mov       cl,60
         div       cl
         call      DekSTm                   ; dek¢dov†n° minuty

; ------ oddàlovaá áasu

         xchg      ax,bx
         stosw
         xchg      ax,bx

; ------ dek¢dov†n° sekundy

         mov       al,ah
         call      DekSTm                   ; dek¢dov†n° sekundy

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekSTime ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° 2 á°slic áasu AL
; -----------------------------------------------------------------------------

DekSTm   PROC      NEAR

         push      ax
         aam                                ; rozdàlen° na vy®®° a nië®° á°slici
         add       ax,"00"                  ; korekce na ASCII znaky
         push      ax
         mov       al,ah                    ; des°tky
         mov       ah,bh                    ; barva
         stosw                              ; uloëen° á°slice des°tek
         pop       ax
         mov       ah,bh                    ; barva
         stosw                              ; uloëen° á°slice jednotek
         pop       ax
         ret

DekSTm   ENDP

; *****************************************************************************
;                               DekDDat0
;      dek¢dov†n° systÇmovÇho data s dnem v tòdnu bez dek¢dov†n° fontu
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        ES:DI=adresa bufferu (11 znakñ)
;        DS=datovò segment
; *****************************************************************************

DekDDat0 PROC      FAR

         push      cx
         xor       cx,cx                    ; CX <- 0
         xchg      cx,ds:[KodFntTb]         ; zru®en° adresy tabulky
         call      far ptr DekDDate         ; dek¢dov†n° data
         mov       ds:[KodFntTb],cx         ; n†vrat adresy tabulky
         pop       cx
         ret

DekDDat0 ENDP

; *****************************************************************************
;                               DekDDate
;            dek¢dov†n° systÇmovÇho data s dnem v tòdnu
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        ES:DI=adresa bufferu (11 znakñ)
;        DS=datovò segment
; *****************************************************************************

DekDDate PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ poskytnut° systÇmovÇho data

         xchg      ax,bx                    ; BH <- £schova barvy
         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         mov       ah,0
         shl       ax,1                     ; den v tòdnu * 2
         xchg      ax,bx                    ; BX <- den v tòdnu*2, AH <- barva

; ------ dek¢dov†n° dne v tòdnu

         cld
         mov       al,ds:[bx+DnyDate]       ; prvn° znak dne
         call      far ptr KonvFChr         ; konverze znaku podle k¢du
         stosw
         mov       al,ds:[bx+DnyDate+1]     ; druhò znak dne
         call      far ptr KonvFChr         ; konverze znaku podle k¢du
         stosw
         mov       al," "                   ; oddàlovac° mezera
         stosw

; ------ vòpoáet roku

         push      ax

         mov       al,100                   ; dàlitel
         xchg      ax,cx                    ; AX <- rok
         div       cl                       ; vòpoáet roku a stolet°
         mov       al,ah
         mov       ah,0
         xchg      ax,cx                    ; CX <- rok

         pop       ax

; ------ dek¢dov†n° data

         call      far ptr DekDate          ; dek¢dov†n° data

;; ------ rozli®en° form†tu data
;
;         mov       ch,"0"                   ; doplnàn° nulou
;         mov       bl,ds:[ZnakDat]          ; oddàlovac° znak data
;         cmp       byte ptr ds:[FormDat],1  ; je evropskò form†t data ?
;         jne       DekDDat3                 ; nen° evropskò form†t data
;
;; ------ evropskò form†t DEN/MâSãC
;
;         call      DekDatDn                 ; dek¢dov†n° dne
;         stosw                              ; uloëen° oddàlovac°ho znaku data
;         call      DekDatMs                 ; dek¢dov†n° màs°ce
;         jmp       short DekDDat4
;
;; ------ japonskò a americkò form†t MâSãC/DEN
;
;DekDDat3:call      DekDatMs                 ; dek¢dov†n° màs°ce
;         stosw                              ; uloëen° oddàlovac°ho znaku data
;         call      DekDatDn                 ; dek¢dov†n° dne
;DekDDat4:stosw                              ; uloëen° oddàlovac°ho znaku data

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekDDate ENDP

; *****************************************************************************
;                                DekSDate
;                        dek¢dov†n° systÇmovÇho data
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        ES:DI=adresa bufferu (10 znakñ)
;        DS=datovò segment
; *****************************************************************************

DekSDate PROC      FAR

; ------ £schova registrñ

         push      cx
         push      dx

; ------ poskytnut° systÇmovÇho data

         push      ax
         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         pop       ax

; ------ korekce roku

DekSDat1:cmp       cx,1980
         jae       DekSDat2
         mov       cx,1980
DekSDat2:cmp       cx,2999
         jbe       DekSDat3
         mov       cx,2999

; ------ dek¢dov†n° data

DekSDat3:call      far ptr DekDate          ; dek¢dov†n° systÇmovÇho data

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         ret

DekSDate ENDP

; *****************************************************************************
;                                  DekDate
;                     dek¢dov†n° data (rok 4 pozice)
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        CX=rok
;        DL=den
;        DH=màs°c
;        ES:DI=ukl†dac° adresa (10 pozic)
;        DS=datovò segment
; *****************************************************************************

DekDate  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di

; ------ form†t data

         cld
         mov       bl,ds:[ZnakDat]          ; oddàlovac° znak data
         mov       bh,ds:[FormDat]          ; form†t data (0=MDR,1=DMR,2=RMD)

; ------ evropskò form†t DEN/MâSãC/ROK

         dec       bh                       ; form†t data = 1 ?
         jnz       DekDate3                 ; nen° evropskò form†t data

         push      cx                       ; rok
         mov       ch," "                   ; doplnàn° mezerou
         call      DekDatDn                 ; dek¢dov†n° dne
         stosw                              ; uloëen° oddàlovac°ho znaku data
         call      DekDatMs                 ; dek¢dov†n° màs°ce
         jmp       short DekDate6           ; dek¢dov†n° roku

; ------ japonskò form†t ROK:MâSãC:DEN

DekDate3:dec       bh                       ; form†t data = 2 ?
         jnz       DekDate5                 ; nen° japonskò form†t data

         call      DekDatRk                 ; dek¢dov†n° roku (4 á°slice)
         stosw                              ; uloëen° oddàlovac°ho znaku data
         push      cx                       ; rok
         mov       ch,"0"                   ; dopl§uj°c° znak
         call      DekDatMs                 ; dek¢dov†n° màs°ce
         stosw                              ; uloëen° oddàlovac°ho znaku data
         call      DekDatDn                 ; dek¢dov†n° dne
         pop       cx
         jmp       short DekDate9

; ------ americkò form†t MâSãC/DEN/ROK

DekDate5:push      cx                       ; rok
         mov       ch," "                   ; dopl§uj°c° znak
         call      DekDatMs                 ; dek¢dov†n° màs°ce
         stosw                              ; uloëen° oddàlovac°ho znaku data
         call      DekDatDn                 ; dek¢dov†n° dne
DekDate6:stosw                              ; uloëen° oddàlovac°ho znaku data
         pop       cx                       ; rok
         call      DekDatRk                 ; dek¢dov†n° roku (4 á°slice)

; ------ n†vrat registrñ

DekDate9:pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

DekDate  ENDP

; -----------------------------------------------------------------------------
;                                DekDatDn
;                      dek¢dov†n° dne (2 á°slice)
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        BL=oddàlovac° znak data
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        DL=den
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
; VùSTUP:AL=oddàlovac° znak data
;        CH=dopl§uj°c° znak "0"
;        ES:DI=nov† ukl†dac° adresa
; -----------------------------------------------------------------------------

DekDatDn PROC      NEAR

         mov       al,dl                    ; den
         call      DekADT                   ; dek¢dov†n° dvojá°sl°
         mov       al,bl                    ; oddàlovac° znak data
         ret

DekDatDn ENDP

; -----------------------------------------------------------------------------
;                                DekDatMs
;                      dek¢dov†n° màs°ce (2 á°slice)
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        BL=oddàlovac° znak data
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        DH=màs°c
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
; VùSTUP:AL=oddàlovac° znak data
;        CH=dopl§uj°c° znak "0"
;        ES:DI=nov† ukl†dac° adresa
; -----------------------------------------------------------------------------

DekDatMs PROC      NEAR

         mov       al,dh                    ; màs°c
         call      DekADT                   ; dek¢dov†n° dvojá°sl°
         mov       al,bl                    ; oddàlovac° znak data
         ret

DekDatMs ENDP

; -----------------------------------------------------------------------------
;                               DekDatRk
;                      dek¢dov†n° roku (4 á°slice)
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        BL=oddàlovac° znak data
;        CX=rok
;        ES:DI=ukl†dac° adresa
; VùSTUP:AL=oddàlovac° znak data
;        ES:DI=nov† ukl†dac° adresa
; -----------------------------------------------------------------------------

DekDatRk PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx

; ------ dek¢dov†n° roku

         xchg      ax,bx                    ; BH <- barva textu
         mov       bl,0                     ; oddàlovaá ©†dñ se neukl†d†
         mov       ax,cx                    ; rok
         xor       dx,dx                    ; á°slo HIGH
         call      far ptr DekNum           ; dek¢dov†n° á°sla (4 á°slice)

; ------ oprava, je-li rok 1-m°stnÇ á°slo

         cld
         cmp       ax,10                    ; je to 1-m°stnÇ á°slo ?
         xchg      ax,bx                    ; n†vrat barvy textu AH
         jae       DekDtRk2                 ; nen° to 1-m°stnÇ á°slo
         mov       al,"0"                   ; prvn° znak bude 0
         xchg      al,es:[di-2]
         stosw                              ; odsunut° o "0"

; ------ n†vrat registrñ

DekDtRk2:pop       dx
         pop       bx
         mov       al,bl                    ; oddàlovac° znak data
         ret

DekDatRk ENDP

; -----------------------------------------------------------------------------
;                               DekADT
;                dek¢dov†n° dvojá°sl° s doplnàn°m znaku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo
;        AH=barva textu
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
; VùSTUP:ES:DI=nov† ukl†dac° adresa
;        CH=znak k doplnàn° "0"
; -----------------------------------------------------------------------------
; niá° registr AL
; -----------------------------------------------------------------------------

DekADT   PROC      NEAR

         push      dx
         push      ax
         aam                                ; rozdàlen° AL na 2 á°slice
         add       ax,"00"                  ; korekce na á°slice ASCII
         xchg      ax,dx                    ; £schova á°sla do DX
         pop       ax
         mov       al,dh                    ; vy®®° á°slice
         cmp       al,"0"                   ; je prvn° znak 0 ?
         jne       DekADT1                  ; nen° 0
         mov       al,ch                    ; n†hradn° prvn° znak
DekADT1: stosw                              ; uloëen° prvn° á°slice
         mov       al,dl                    ; druh† á°slice
         stosw                              ; uloëen° druhÇ á°slice
         mov       ch,"0"                   ; dopl§uj°c° znak "0"
         pop       dx
         ret

DekADT   ENDP

; *****************************************************************************
;                                DekNumB
;                   dek¢dov†n° á°sla (bajtu) od levÇho okraje
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo k dek¢dov†n°
;        AH=atribut barev (0=atribut barev se neukl†d†)
;        ES:DI=ukl†dac° adresa (poá†tek k uloëen° á°sla)
; VùSTUP:ES:DI=n†sleduj°c° adresa za á°slem
; *****************************************************************************

DekNumB  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ p©°prava registrñ

         mov       dh,ah                    ; barva
         mov       dl,10                    ; á°seln† soustava
         xor       cx,cx                    ; á°taá á°slic v z†sobn°ku

; ------ vòpoáet jednÇ á°slice

DekNumB1:xor       ah,ah
         div       dl                       ; vydàlen° nië®°ho slova á°sla

; ------ uloëen° novÇ á°slice

         add       ah,"0"                   ; korekce na znak ASCII
         push      ax                       ; uloëen° á°slice (v AH)
         inc       cx                       ; zvò®en° á°taáe znakñ

; ------ test, zda je je®tà nàjakÇ á°slo

         or        al,al                    ; je á°slo jië = 0 ?
         jnz       DekNumB1                 ; á°slo je®tà nen° = 0 - pokraáov†n°

; ------ uloëen° á°sla do bufferu

         cld
         or        dh,dh                    ; ukl†d† se atribut barvy ?
         jnz       DekNumB6                 ; atribut barvy se ukl†d†

DekNumB5:pop       ax                       ; n†vrat znaku á°sla
         mov       al,ah
         stosb                              ; uloëen° znaku
         loop      DekNumB5                 ; dal®° znak á°sla
         jmp       short DekNumB8

DekNumB6:pop       ax                       ; n†vrat znaku á°sla
         mov       al,ah
         mov       ah,dh                    ; barva
         stosw                              ; uloëen° znaku s atributem
         loop      DekNumB6                 ; dal®° znak á°sla

; ------ n†vrat registrñ

DekNumB8:pop       dx
         pop       cx
         pop       ax
         ret

DekNumB   ENDP

; *****************************************************************************
;                                DekNumW
;                   dek¢dov†n° á°sla (slova) od levÇho okraje
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (poá†tek k uloëen° á°sla)
;        BH=atribut barev (0=atribut barev se neukl†d†)
;        BL=znak oddàlovaáe ©†dñ (0=oddàlovaá ©†dñ se neukl†d†)
; VùSTUP:ES:DI=n†sleduj°c° adresa za á°slem
; *****************************************************************************

DekNumW  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si

; ------ p©°prava registrñ

         mov       si,10                    ; á°seln† soustava
         xor       cx,cx                    ; á°taá á°slic v z†sobn°ku

; ------ vòpoáet jednÇ á°slice

DekNumW1:xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° á°sla

; ------ uloëen° oddàlovaáe ©†dñ

         cmp       cl,3                     ; jsou tis°ce ?
         jne       DekNumW3                 ; nen° ©†d milionñ
         or        bl,bl                    ; ukl†d† se oddàlovaá ©†dñ ?
         jz        DekNumW3                 ; oddàlovaá ©†dñ se neukl†d†
         push      bx                       ; uloëen° oddàlovaáe ©†dñ
         inc       cx                       ; zvò®en° á°taáe znakñ

; ------ uloëen° novÇ á°slice

DekNumW3:mov       dh,bh                    ; barva textu
         add       dl,"0"                   ; korekce na znak ASCII
         push      dx                       ; uloëen° á°slice
         inc       cx                       ; zvò®en° á°taáe znakñ

; ------ test, zda je je®tà nàjakÇ á°slo

         or        ax,ax                    ; je á°slo jië = 0 ?
         jnz       DekNumW1                 ; á°slo je®tà nen° = 0 - pokraáov†n°

; ------ uloëen° á°sla do bufferu

         cld
         or        bh,bh                    ; ukl†d† se atribut barvy ?
         jnz       DekNumW6                 ; atribut barvy se ukl†d†

DekNumW5:pop       ax                       ; n†vrat znaku á°sla
         stosb                              ; uloëen° znaku
         loop      DekNumW5                 ; dal®° znak á°sla
         jmp       short DekNumW8

DekNumW6:pop       ax                       ; n†vrat znaku á°sla
         stosw                              ; uloëen° znaku s atributem
         loop      DekNumW6                 ; dal®° znak á°sla

; ------ n†vrat registrñ

DekNumW8:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNumW   ENDP

; *****************************************************************************
;                                DekNum
;                  Dek¢dov†n° á°sla od levÇho okraje
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (poá†tek k uloëen° á°sla)
;        BH=atribut barev (0=atribut barev se neukl†d†)
;        BL=znak oddàlovaáe ©†dñ (0=oddàlovaá ©†dñ se neukl†d†)
; VùSTUP:ES:DI=n†sleduj°c° adresa za á°slem
; *****************************************************************************

DekNum   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©°prava registrñ

         mov       bp,10                    ; á°seln† soustava
         xor       cx,cx                    ; á°taá á°slic v z†sobn°ku

; ------ vòpoáet jednÇ á°slice

DekNum1: xchg      ax,si                    ; SI <- £schova á°sla LOW
         xchg      ax,dx                    ; AX <- vy®®° slovo á°sla
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydàlen° vy®®°ho slova á°sla
         xchg      ax,si                    ; SI <- novÇ HIGH, AX <- starÇ LOW
         div       bp                       ; vydàlen° nië®°ho slova á°sla

; ------ uloëen° oddàlovaáe ©†dñ

         cmp       cl,3                     ; jsou tis°ce ?
         je        DekNum2                  ; jsou tis°ce
         cmp       cl,6+1                   ; jsou miliony ?
         jne       DekNum3                  ; nen° ©†d milionñ
DekNum2: or        bl,bl                    ; ukl†d† se oddàlovaá ©†dñ ?
         jz        DekNum3                  ; oddàlovaá ©†dñ se neukl†d†
         push      bx                       ; uloëen° oddàlovaáe ©†dñ
         inc       cx                       ; zvò®en° á°taáe znakñ

; ------ uloëen° novÇ á°slice

DekNum3: mov       dh,bh                    ; barva textu
         add       dl,"0"                   ; korekce na znak ASCII
         push      dx                       ; uloëen° á°slice
         inc       cx                       ; zvò®en° á°taáe znakñ

; ------ test, zda je je®tà nàjakÇ á°slo

         mov       dx,si                    ; DX <- n†vrat vy®®°ho slova á°sla
         or        si,ax                    ; je á°slo jië = 0 ?
         jnz       DekNum1                  ; á°slo je®tà nen° = 0 - pokraáov†n°

; ------ uloëen° á°sla do bufferu

         cld
         or        bh,bh                    ; ukl†d† se atribut barvy ?
         jnz       DekNum6                  ; atribut barvy se ukl†d†

DekNum5: pop       ax                       ; n†vrat znaku á°sla
         stosb                              ; uloëen° znaku
         loop      DekNum5                  ; dal®° znak á°sla
         jmp       short DekNum8

DekNum6: pop       ax                       ; n†vrat znaku á°sla
         stosw                              ; uloëen° znaku s atributem
         loop      DekNum6                  ; dal®° znak á°sla

; ------ n†vrat registrñ

DekNum8: pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP

; *****************************************************************************
;                                DekHWord
;                       dek¢dov†n° slova v HEX k¢du
;                     ponech†v† nastaven p©°znak CLD !
; -----------------------------------------------------------------------------
; VSTUP: AX=slovo k dek¢dov†n°
;        BH=atribut barvy (0=barva se neukl†d†)
;        ES:DI=ukl†dac° adresa k dek¢dov†n° á°sla
; *****************************************************************************

DekHWord PROC      FAR

         push      ax
         mov       al,ah
         mov       ah,bh
         call      far ptr DekHByte
         pop       ax

         push      ax
         mov       ah,bh
         call      far ptr DekHByte
         pop       ax
         ret

DekHWord ENDP

; *****************************************************************************
;                                DekHByte
;                       dek¢dov†n° bajtu v HEX k¢du
;                     ponech†v† nastaven p©°znak CLD !
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k dek¢dov†n°
;        AH=atribut barvy (0=barva se neukl†d†)
;        ES:DI=ukl†dac° adresa k dek¢dov†n° á°sla
; *****************************************************************************

DekHByte PROC      FAR

         cld
         or        ah,ah
         jnz       DekHByt2

; ------ prvn° á°slice - bez barvy

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1

         add       al,90h
         daa
         adc       al,"@"
         daa
         stosb
         pop       ax

; ------ druh† á°slice - bez barvy

         push      ax
         and       al,0fh
         add       al,90h
         daa
         adc       al,"@"
         daa
         stosb
         pop       ax
         ret

; ------ prvn° á°slice - s barvou

DekHByt2:push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1

         add       al,90h
         daa
         adc       al,"@"
         daa
         stosw
         pop       ax

; ------ druh† á°slice - s barvou

         push      ax
         and       al,0fh
         add       al,90h
         daa
         adc       al,"@"
         daa
         stosw
         pop       ax
         ret

DekHByte ENDP

; *****************************************************************************
;                                DekBByte
;                       dek¢dov†n° bajtu v bin†rn°m k¢du
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k dek¢dov†n°
;        AH=atribut barvy (0=barva se neukl†d†)
;        ES:DI=ukl†dac° adresa k dek¢dov†n° á°sla
; *****************************************************************************

DekBByte PROC      FAR

         push      ax
         push      cx

         mov       cx,8                     ; poáet bitñ
DekBByt1:mov       byte ptr es:[di],"0"     ; á°slo "0"
         shl       al,1                     ; je bit nastaven ?
         jnc       DekBByt2                 ; nen° nastaven
         inc       byte ptr es:[di]         ; á°slo "1"
DekBByt2:inc       di                       ; zvò®en° ukazatele dat
         or        ah,ah                    ; barva se ukl†d† ?
         jz        DekBByt3                 ; barva se neukl†d†
         mov       byte ptr es:[di],ah      ; uloëen° barvy
         inc       di                       ; zvò®en° ukazatele bufferu
DekBByt3:loop      DekBByt1                 ; dal®° bit

         pop       cx
         pop       ax
         ret

DekBByte ENDP

; *****************************************************************************
;                                  Dek10Num
;  dek¢dov†n° á°sla zarovnanÇho vpravo s omezen°m na 10 pozic (podm°nàn† teáka)
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (konec za á°slem)
;        BH=atribut barev (0=atribut barev se neukl†d†)
;        BL=oddàlovac° znak ©†dñ (0=oddàlovaá ©†dñ se neukl†d†)
; *****************************************************************************

Dek10Num PROC      FAR

         push      bx
         cmp       dx,5f5h                  ; je á°slo 100.000.000 a vàt®° ?
         jne       Dek10Nm2
         cmp       ax,0e100h
Dek10Nm2:jb        Dek10Nm8                 ; je á°slo nië®° neë 100.000.000

         cmp       dx,3b9ah                 ; je á°slo 1.000.000.000 a vàt®° ?
         jne       Dek10Nm3
         cmp       ax,0ca00h
Dek10Nm3:jae       Dek10Nm7                 ; je á°slo 1.000.000.000 a vy®®°

         or        bh,bh                    ; je barva ?
         jz        Dek10Nm7                 ; nen° barva
         or        bl,bl                    ; je oddàlovaá ©†dñ ?
         jz        Dek10Nm7                 ; nen° oddàlovaá ©†dñ

         mov       bl,0                     ; nen° oddàlovac° znak ©†dñ
         call      far ptr DekNumD          ; dek¢dov†n° á°sla bez teáek

         pop       bx
                                            ; ES:DI=za á°slem 123456789
         push      ax
         mov       ax,es:[di-9*2]           ; 1. á°slice
         mov       es:[di-10*2],ax

         mov       ax,es:[di-8*2]           ; 2. á°slice
         mov       es:[di-9*2],ax

         mov       ax,es:[di-7*2]           ; 3. á°slice
         mov       es:[di-8*2],ax

         mov       es:[di-7*2],bl           ; oddàlovac° teáka

         pop       ax
         ret

Dek10Nm7:mov       bl,0                     ; nen° oddàlovac° znak ©†dñ
Dek10Nm8:call      far ptr DekNumD          ; dek¢dov†n° á°sla velikosti souboru
         pop       bx
         ret

Dek10Num ENDP

; *****************************************************************************
;                                 DekNumD
;                   Dek¢dov†n° á°sla od pravÇho okraje
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (konec za á°slem)
;        BH=atribut barev (0=atribut barev se neukl†d†)
;        BL=znak oddàlovaáe ©†dñ (0=oddàlovaá ©†dñ se neukl†d†)
; *****************************************************************************

DekNumD  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       bp,10                    ; á°seln† soustava
         mov       cx,4                     ; á°taá á°slic ©†du
         or        bl,bl                    ; ukl†d† se oddàlovaá ©†du ?
         jnz       DekNumD1                 ; oddàlovaá ©†du se ukl†d†
         mov       ch,0ffh                  ; neplatnò á°taá ©†du

; ------ vòpoáet jednÇ á°slice

DekNumD1:xchg      ax,si                    ; SI <- £schova nië®°ho slova á°sla
         xchg      ax,dx                    ; AX <- vy®®° slovo á°sla
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydàlen° vy®®°ho slova á°sla
         xchg      ax,si                    ; AX <- n†vrat nië®°ho slova
         div       bp                       ; vydàlen° nië®°ho slova á°sla

; ------ uloëen° oddàlovaáe ©†dñ

         dec       cx                       ; á°taá á°slic ©†du
         jnz       DekNumD3                 ; nen° oddàlovaá ©†du
         or        bh,bh                    ; ukl†d† se atribut barev ?
         jz        DekNumD2                 ; atribut barev se neukl†d†
         dec       di                       ; posun adresy
         mov       es:[di],bh               ; uloëen° atributu barvy
DekNumD2:dec       di                       ; posun adresy
         mov       es:[di],bl               ; uloëen° oddàlovaáe tis°cñ
         mov       cl,3                     ; novò á°taá ©†du

; ------ uloëen° novÇ á°slice

DekNumD3:or        bh,bh                    ; ukl†d† se atribut barev ?
         jz        DekNumD4                 ; atribut barev se neukl†d†
         dec       di                       ; posun adresy
         mov       es:[di],bh               ; uloëen° atributu barev
DekNumD4:dec       di                       ; posun adresy
         add       dl,"0"                   ; korekce na znak ASCII
         mov       es:[di],dl               ; uloëen° á°slice

; ------ test, zda je je®tà nàjakÇ á°slo

         mov       dx,si                    ; n†vrat vy®®°ho slova á°sla
         or        si,ax                    ; je á°slo jië = 0 ?
         jnz       DekNumD1                 ; á°slo je®tà nen° = 0 - pokraáov†n°

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNumD  ENDP

; *****************************************************************************
;                                TestKonc
;                          test koncovky á°sla
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=testovanÇ á°slo
; VùSTUP:CX=0 je koncovka "1"
;        CX=1 je koncovka "2" aë "4"
;        CX=2 koncovka pro ostatn° á°sla
; *****************************************************************************

TestKonc PROC      FAR

; ====== test koncovky pro áeskou verzi

IFDEF    CESK

; ------ £schova registrñ (pouze áesk† verze)

         push      ax
         push      dx

; ------ vòpoáet posledn°ch 2 á°slic

         mov       cx,100                   ; dàlitel á°sla
         push      ax                       ; BX <- £schova á°sla LOW
         xchg      ax,dx                    ; AX <- á°slo HIGH
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; vydàlen° vy®®°ho ©†du
         pop       ax                       ; AX <- n†vrat á°sla LOW
         div       cx                       ; vydàlen° nië®°ho ©†du
         xchg      ax,dx                    ; AX <- nejnië®° 2 á°slice
         aam                                ; korekce - rozdàlen° na 2 á°slice

; ------ rozli®en° koncovky

         mov       cl,2                     ; p©°znak jinÇho á°sla
         cmp       ah,1                     ; byly des°tky ?
         je        TestKon8                 ; jsou mnoën† á°sla
         cmp       al,4                     ; je á°slice vàt®° neë "4" ?
         ja        TestKon8                 ; je á°slice vàt®° neë "4"
         cmp       al,0                     ; je á°slice "0" ?
         je        TestKon8                 ; je á°slice "0"
         dec       cx                       ; p©°znak á°sla 2,3,4
         cmp       al,1                     ; je á°slice "1" ?
         ja        TestKon8                 ; nen° "1" - je 2,3,4
         dec       cx                       ; p©°znak á°slice "1"

; ------ n†vrat registrñ

TestKon8:pop       dx
         pop       ax

ELSE

; ====== test koncovky pro slovenskou verzi

IFDEF    SLOV

         mov       cx,2                     ; p©°znak - jin† koncovka
         or        dx,dx                    ; je á°slo HIGH ?
         jnz       TestKon9                 ; je á°slo HIGH
         or        ax,ax                    ; je á°slo 0 ?
         jz        TestKon9                 ; je á°slo 0
         cmp       ax,4                     ; á°slo vàt®° neë "4" ?
         ja        TestKon9                 ; vàt®° á°slo
         dec       cx                       ; p©°znak - koncovka "2" aë "4"
         cmp       al,1                     ; je á°slo = 1 ?
         ja        TestKon9                 ; je vàt®° á°slo neë 1
         dec       cx                       ; p©°znak - koncovka "1"

ELSE

; ====== test koncovky pro ostatn° jazykovÇ verze

         mov       cx,2                     ; p©°znak - jin† koncovka
         or        dx,dx                    ; je á°slo HIGH ?
         jnz       TestKon9                 ; je á°slo HIGH
         cmp       ax,1                     ; je á°slo = 1 ?
         jne       TestKon9                 ; nen° = 1
         xor       cx,cx                    ; jinak koncovka pro "1"

ENDIF
ENDIF

TestKon9:ret

TestKonc ENDP

; *****************************************************************************
;                                 KonvFChr
;               konverze znaku Kamenickòch na aktu†ln° k¢d displeje
; -----------------------------------------------------------------------------
; VSTUP: AL=znak ke konverzi
;        DS=datovò segment
; VùSTUP: AL=konvertovanò znak
; *****************************************************************************

KonvFChr PROC      FAR

; ------ test, zda se znak k p©ek¢dov†n°

         cmp       al,128                   ; je znak k p©ek¢dov†n° ?
         jae       KonvFCh2                 ; je znak k p©ek¢dov†n°
         ret

; ------ adresa k¢dovac° tabulky -> BX

KonvFCh2:push      bx
         mov       bx,ds:[KodFntTb]         ; adresa k¢dovac° tabulky

; ------ test, zda se prov†d° konverze

         or        bx,bx                    ; prov†d° se konverze ?
         jz        KonvFCh8                 ; konverze se neprov†d°

; ------ p©ek¢dov†n° ©etàzce

         push      ds
         push      cs
         pop       ds                       ; DS <- tento segment (s tabulkou)
         sub       al,128                   ; je to n†rodn° k¢d ?
         xlat                               ; p©ek¢dov†n° znaku
         pop       ds

; ------ n†vrat registrñ

KonvFCh8:pop       bx
         ret

KonvFChr ENDP

; *****************************************************************************
;                                KonvFnt
;                             konverze fontñ
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bufferu s textem ke konverzi
;        CX=poáet bajtñ ke konverzi
;        DL=vstupn° k¢d textu (0=nedefinov†n)
;                  bit 0: 1=ASCII
;                  bit 1: 1=IBM
;                  bit 2: 1=Kamenickòch (KEYBCS2)
;                  bit 3: 1=Latin 2
;                  bit 4: 1=KOI 8
;                  bit 5: 1=WINDOWS 1250
;        DH=vòstupn° k¢d textu (0=beze zmàny)
;                  bit 0: 1=ASCII
;                  bit 1: 1=IBM
;                  bit 2: 1=Kamenickòch (KEYBCS2)
;                  bit 3: 1=Latin 2
;                  bit 4: 1=KOI 8
;                  bit 5: 1=WINDOWS 1250
; *****************************************************************************
;˛
KonvFnt  PROC      FAR

; ------ test, zda se prov†d° konverze

         jcxz      KonvFnt9                 ; nejsou data ke konverzi
         cmp       dl,bit0                  ; vstupn° k¢d ASCII nebo nezn†mò ?
         jbe       KonvFnt9                 ; vstupn° k¢d nedefinov†n
         or        dh,dh
         jz        KonvFnt9                 ; vòstupn° k¢d nezmànàn
         cmp       dl,dh                    ; vòstupn° k¢d shodnò se vstupn°m ?
         je        KonvFnt9                 ; nen° zmàna k¢du

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di
         push      ds

; ------ p©°prava registrñ

         cld
         push      cs
         pop       ds                       ; DS <- segment tabulky
         mov       ax,dx                    ; AX <- k¢dy ke konverzi
         mov       di,si                    ; DI <- adresa dat
         shr       al,1                     ; p©eskoáen° bitu 0

; ------ adresa konverzn° tabulky -> BX

KonvFnt3:mov       bx,offset KonvFntT-6*2-2 ; adresa adres tabulek
KonvFnt4:add       bx,2*6                   ; dal®° á†st
         shr       al,1
         jnc       KonvFnt4                 ; adresa podle vstupn°ho k¢du
KonvFnt5:inc       bx
         inc       bx
         shr       ah,1
         jnc       KonvFnt5
         mov       bx,ds:[bx]               ; adresa konverzn° tabulky

; ------ konverze fontñ

KonvFn72:mov       al,es:[di]               ; bajt dat
         cmp       al,128                   ; je znak > 127 ?
         jb        KonvFn74                 ; nen° znak ke konverzi
         xlat                               ; konverze znaku
KonvFn74:stosb                              ; uloëen° znaku
         loop      KonvFn72                 ; dal®° znak

; ------ n†vrat registrñ

KonvFnt8:pop       ds
         pop       di
         pop       cx
         pop       bx
         pop       ax
KonvFnt9:ret

KonvFnt  ENDP

KonvFntT label     word                     ; tabulka adres konverzn°ch tabulek
         dw        TbIBMCs0-128             ; IBM -> ASCII
         dw        0                        ; IBM -> IBM
         dw        TbIBMKam-128             ; IBM -> KAM
         dw        TbIBMLat-128             ; IBM -> LAT
         dw        TbIBMKOI-128             ; IBM -> KOI
         dw        TbIBMWin-128             ; IBM -> WIN

         dw        TbKAMCs0-128             ; KAM -> ASCII
         dw        TbKAMIBM-128             ; KAM -> IBM
         dw        0                        ; KAM -> KAM
         dw        TbKAMLat-128             ; KAM -> LAT
         dw        TbKAMKOI-128             ; KAM -> KOI
         dw        TbKAMWin-128             ; KAM -> WIN

         dw        TbLATCs0-128             ; LAT -> ASCII
         dw        TbLATIBM-128             ; LAT -> IBM
         dw        TbLATKAM-128             ; LAT -> KAM
         dw        0                        ; LAT -> LAT
         dw        TbLATKOI-128             ; LAT -> KOI
         dw        TbLATWin-128             ; LAT -> WIN

         dw        TbKOICs0-128             ; KOI -> ASCII
         dw        TbKOIIBM-128             ; KOI -> IBM
         dw        TbKOIKAM-128             ; KOI -> KAM
         dw        TbKOILat-128             ; KOI -> LAT
         dw        0                        ; KOI -> KOI
         dw        TbKOIWin-128             ; KOI -> WIN

         dw        TbWINCs0-128             ; WIN -> ASCII
         dw        TbWINIBM-128             ; WIN -> IBM
         dw        TbWINKAM-128             ; WIN -> KAM
         dw        TbWINLat-128             ; WIN -> LAT
         dw        TbWINKOI-128             ; WIN -> KOI
         dw        0                        ; WIN -> WIN

; *****************************************************************************
;                                  KonvUpC
;                      konverze malòch p°smen na velk†
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa textu ke konverzi
;        DL=souáasnò k¢d textu (0 = nekonvertuje se)
;            bit 0: ASCII
;            bit 1: IBM
;            bit 2: Kamenickòch
;            bit 3: Latin 2
;            bit 4: KOI 8
;            bit 5: WINDOWS 1250
;        CX=poáet bajtñ ke konverzi
; *****************************************************************************

KonvUpC  PROC      FAR

         jcxz      KonvUpC9                 ; nejsou ë†dn† data ke konverzi
         or        dl,dl                    ; konvertuje se ?
         jz        KonvUpC9                 ; nekonvertuje se

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di
         push      ds

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         push      cs
         pop       ds                       ; DS <- segment tabulky
         mov       di,si                    ; adresa textu

; ------ konverze textu bez diakritiky

         test      dl,bit0                  ; je k¢d ASCII ?
         jz        KonvUpC3                 ; nen° k¢d ASCII
KonvUpC1:mov       al,es:[di]               ; znak ke konverzi
         cmp       al,"a"
         jb        KonvUpC2
         cmp       al,"z"
         ja        KonvUpC2
         sub       al,32                    ; p©evod na velkÇ p°smeno
KonvUpC2:stosb                              ; uloëen° znaku
         loop      KonvUpC1                 ; konverze dal®°ho znaku
         jmp       short KonvUpC8           ; konec konverze

; ------ p©°prava konverzn° tabulky

KonvUpC3:mov       bx,offset TbIBMUpC-128   ; konverze k¢du IBM na velk† p°smena
         test      dl,bit1                  ; je k¢d IBM ?
         jnz       KonvUpC4                 ; je k¢d IBM
         mov       bx,offset TbKamUpC-128   ; konverze k¢du Kamenickòch na velk†
         test      dl,bit2                  ; je k¢d Kamenickòch ?
         jnz       KonvUpC4                 ; je k¢d Kamenickòch
         mov       bx,offset TbLatUpC-128   ; konverze k¢du Latin 2 na velk† p.
         test      dl,bit3                  ; je k¢d Latin 2 ?
         jnz       KonvUpC4                 ; je k¢d Latin 2
         mov       bx,offset TbKOIUpC-128   ; konverze k¢du KOI 8 na velk† p°sm.
         test      dl,bit4                  ; je k¢d KOI8 ?
         jnz       KonvUpC4                 ; je k¢d KOI8
         mov       bx,offset TbWinUpC-128   ; konverze k¢du WIN na velk† p°sm.

; ------ konverze textu v n†rodn°m k¢du

KonvUpC4:mov       al,es:[di]               ; znak ke konverzi
         cmp       al,"a"
         jb        KonvUpC6                 ; znak se nekonvertuje
         cmp       al,"z"
         ja        KonvUpC5
         sub       al,32                    ; p©evod na velkÇ p°smeno
KonvUpC5:cmp       al,128                   ; je n†rodn° znak ?
         jb        KonvUpC6                 ; nen° n†rodn° znak
         xlat                               ; konverze znaku podle tabulky
KonvUpC6:stosb                              ; uloëen° znaku
         loop      KonvUpC4                 ; konverze dal®°ho znaku

; ------ n†vrat registrñ

KonvUpC8:pop       ds
         pop       di
         pop       cx
         pop       bx
         pop       ax
KonvUpC9:ret

KonvUpC  ENDP

; *****************************************************************************
;                                  KonvDnC
;                      konverze velkòch p°smen na mal†
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa textu ke konverzi
;        DL=souáasnò k¢d textu (0 = nekonvertuje se)
;            bit 0: ASCII
;            bit 1: IBM
;            bit 2: Kamenickòch
;            bit 3: Latin 2
;            bit 4: KOI 8
;            bit 5: WINDOWS 1250
;        CX=poáet bajtñ ke konverzi
; *****************************************************************************

KonvDnC  PROC      FAR

         jcxz      KonvDnC9                 ; nejsou ë†dn† data ke konverzi
         or        dl,dl                    ; konvertuje se ?
         jz        KonvDnC9                 ; nekonvertuje se

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di
         pop       ds

; ------ p©°prava registrñ

         cld                                ; smàr nahoru
         push      cs
         pop       ds                       ; DS <- segment tabulky
         mov       di,si                    ; adresa textu

; ------ konverze textu bez diakritiky

         test      dl,bit0                  ; je k¢d ASCII ?
         jz        KonvDnC3                 ; nen° k¢d ASCII
KonvDnC1:mov       al,es:[di]               ; znak ke konverzi
         cmp       al,"A"
         jb        KonvDnC2
         cmp       al,"Z"
         ja        KonvDnC2
         add       al,32                    ; p©evod na malÇ p°smeno
KonvDnC2:stosb                              ; uloëen° znaku
         loop      KonvDnC1                 ; konverze dal®°ho znaku
         jmp       short KonvDnC8           ; konec konverze

; ------ p©°prava konverzn° tabulky

KonvDnC3:mov       bx,offset TbIBMDnC-128   ; konverze k¢du IBM na mal† p°smena
         test      dl,bit1                  ; je k¢d IBM ?
         jnz       KonvDnC4                 ; je k¢d IBM
         mov       bx,offset TbKamDnC-128   ; konverze k¢du Kamenickòch na mal†
         test      dl,bit2                  ; je k¢d Kamenickòch ?
         jnz       KonvDnC4                 ; je k¢d Kamenickòch
         mov       bx,offset TbLatDnC-128   ; konverze k¢du Latin 2 na mal† p.
         test      dl,bit3                  ; je k¢d Latin 2 ?
         jnz       KonvDnC4                 ; je k¢d Latin 2
         mov       bx,offset TbKOIDnC-128   ; konverze k¢du KOI 8 na mal† p°sm.
         test      dl,bit4                  ; je k¢d KOI8 ?
         jnz       KonvDnC4                 ; je k¢d KOI8
         mov       bx,offset TbWinDnC-128   ; konverze k¢du WIN na mal† p°sm.

; ------ konverze textu v n†rodn°m k¢du

KonvDnC4:mov       al,es:[di]               ; znak ke konverzi
         cmp       al,"A"
         jb        KonvDnC6                 ; znak se nekonvertuje
         cmp       al,"Z"
         ja        KonvDnC5
         add       al,32                    ; p©evod na velkÇ p°smeno
KonvDnC5:cmp       al,128                   ; je n†rodn° znak ?
         jb        KonvDnC6                 ; nen° n†rodn° znak
         xlat                               ; konverze znaku podle tabulky
KonvDnC6:stosb                              ; uloëen° znaku
         loop      KonvDnC4                 ; konverze dal®°ho znaku

; ------ n†vrat registrñ

KonvDnC8:pop       ds
         pop       di
         pop       cx
         pop       bx
         pop       ax
KonvDnC9:ret

KonvDnC  ENDP

; *****************************************************************************
;                               DekUkaz
;                       dek¢dov†n° ukazatele
; -----------------------------------------------------------------------------
; VSTUP:  AX=kurzor (jednotek)
;         BX=zobrazenò poá†tek (jednotek)
;         CX=celkov† dÇlka ukazatele (pozic)
;         DX=zobrazen† á†st (jednotek)
;         SI=celkem (jednotek)
; VùSTUP: CY=ukazatel se nemus° zobrazit (zobrazil by se celò)
;         BX=poá†tek ukazatele (pozice)
;         CX=konec ukazatele (pozice - n†sleduj°c° za ukazatelem)
;         DX=kurzor (pozice)
; *****************************************************************************
;˛
DekUkaz  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bp
         push      si
         push      di

; ------ p©°prava registrñ

         xchg      ax,bp                    ; BP <- kurzor
         mov       di,dx                    ; DI <- zobrazen† á†st

; ------ korekce velikosti celkem (jednotek)

         or        si,si                    ; minim†ln° velikost 1
         jnz       DekUkaz1                 ; velikost je OK
         inc       si                       ; omezen° na minim†lnà 1

; ------ korekce celkovÇ dÇlky ukazatele (pozic)

DekUkaz1:or        cx,cx                    ; minim†ln° dÇlka 1
         jnz       DekUkaz2                 ; dÇlka je OK
         inc       cx                       ; omezen° minim†ln° dÇlky ukazatele

; ------ korekce poá†tku (jednotek)

DekUkaz2:cmp       bx,si                    ; je p©eteáen° poá†tku ?
         jb        DekUkaz3                 ; poá†tek je OK
         mov       bx,si                    ; omezen° poá†tku
         dec       bx                       ; posledn° poloëka

; ------ korekce zobrazenÇ á†sti (jednotek)

DekUkaz3:or        di,di                    ; minim†ln° zobrazen† á†st 1
         jnz       DekUkaz4                 ; je OK
         inc       di                       ; zobrazeno minim†lnà 1

; ------ korekce konce (jednotek)

DekUkaz4:add       di,bx                    ; konec (jednotek)
         jc        DekUkaz5                 ; p©eteáen°
         cmp       di,si                    ; je p©eteáen° konce ?
         jbe       DekUkaz6                 ; konec je OK
DekUkaz5:mov       di,si                    ; omezen° konce
DekUkaz6:mov       ax,di                    ; AX <- £schova konce
         sub       ax,bx                    ; velikost zobrazenòch dat
         dec       di                       ; posledn° zobrazen† poloëka

; ------ korekce kurzoru (jednotek)

         cmp       bp,si                    ; je p©eteáen° kurzoru ?
         jb        DekUkaz7                 ; kurzor je OK
         mov       bp,si                    ; omezen° kurzoru
         dec       bp                       ; posledn° poloëka

; ------ p©epoáet kurzoru na pozice

DekUkaz7:xchg      ax,bp                    ; AX <- kurzor
         mul       cx                       ; * celkov† dÇlka (pozic)
         div       si                       ; / celkem (jednotek)
         xchg      ax,bp                    ; BP <- kurzor

; ------ p©epoáet poá†tku na pozice

         xchg      ax,bx                    ; AX <- poá†tek
         mul       cx                       ; * celkov† dÇlka (pozic)
         div       si                       ; / celkem (jednotek)
         xchg      ax,bx                    ; BX <- poá†tek

; ------ test, zda se zobraz° v®e (AX=velikost zobrazenòch jednotek)

         cmp       ax,si                    ; zobraz° se v®e ?
         cmc
         jc        DekUkaz9                 ; zobraz° se v®e

; ------ p©epoáet konce na pozice

         xchg      ax,di                    ; AX <- konec
         mul       cx                       ; * celkov† dÇlka (pozic)
         div       si                       ; / celkem (jednotek)
         inc       ax                       ; n†sleduj°c° pozice

; ------ nastaven° registrñ

         clc                                ; p©°znak - ukazatel se zobraz°
         xchg      ax,cx                    ; CX <- konec ukazatele
DekUkaz9:mov       dx,bp                    ; DX <- kurzor

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       bp
         pop       ax
         ret

DekUkaz  ENDP

; *****************************************************************************
;                               DownCase
;            P©evod AL na malÇ p°smeno (nesm° mànit p©°znak smàru !)
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k p©evodu
; VùSTUP: AL=p©evedenò znak
; *****************************************************************************

DownCase PROC      FAR

         cmp       al,"A"
         jb        DownCas1
         cmp       al,"Z"
         ja        DownCas1
         add       al,32                    ; p©evod na malÇ p°smeno
DownCas1:ret

DownCase ENDP

; *****************************************************************************
;                               UpCase
;        P©evod AL na velkÇ p°smeno (nesm° mànit p©°znak smàru !)
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k p©evodu
; VùSTUP: AL=p©evedenò znak
; *****************************************************************************

UpCase   PROC      FAR

         cmp       al,"a"
         jb        UpCase1
         cmp       al,"z"
         ja        UpCase1
         sub       al,32                    ; p©evod na velkÇ p°smeno
UpCase1: ret

UpCase   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                    Data (pozor - stejnò segment jako program !)
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; ------ tabulka typñ znakñ
; bit 0 a bit 1: hodnota znaku 1=oddàlovac° mezera, 2=pomocnò znak, 3=p°smeno
; bit 2: 1=v®echny znaky
; bit 3: 1=jmÇno souboru: "!#$%&'()*-.:?@\^_`{}~", mezera, á°sla, p°smena, > 127
; bit 4: 1=á°slo, teáka, á†rka, mezera, plus, m°nus, ":"
; bit 5: 1=HEX znaky (á°slice, A-F, mezera)
; bit 6: 1=parametry souborñ: "ASHR ashr + - D T á°slo . : / ? \"
; bit 7: 1=parametry hled†n° textu

TabTypCh label     byte
         db 32 dup(1 + bit2)                          ; 0 aë 31
         db        1 + bit2 + bit3 + bit4 + bit5 + bit6 + bit7 ; mezera
         db        2 + bit2 + bit3                    ; !
         db        2 + bit2                           ; "
         db        3 + bit2 + bit3                    ; #
         db        3 + bit2 + bit3                    ; $
         db        2 + bit2 + bit3                    ; %
         db        2 + bit2 + bit3                    ; &
         db        2 + bit2 + bit3                    ; '
         db        2 + bit2 + bit3                    ; (
         db        2 + bit2 + bit3                    ; )
         db        2 + bit2 + bit3                    ; *
         db        2 + bit2 + bit4 + bit6             ; +
         db        2 + bit2 + bit4                    ; ,
         db        2 + bit2 + bit3 + bit4 + bit6      ; -
         db        2 + bit2 + bit3 + bit4 + bit6      ; .
         db        2 + bit2 + bit6                    ; /
         db 10 dup(3 + bit2 + bit3 + bit4 + bit5 + bit6 + bit7) ; á°slice 0 aë 9
         db        2 + bit2 + bit3 + bit4 + bit6      ; :
         db        2 + bit2                           ; ;
         db        2 + bit2                           ; <
         db        2 + bit2                           ; =
         db        2 + bit2                           ; >
         db        2 + bit2 + bit3 + bit6             ; ?
         db        3 + bit2 + bit3                    ; @

         db        3 + bit2 + bit3 + bit5 + bit6      ; A
         db        3 + bit2 + bit3 + bit5 + bit7      ; B
         db        3 + bit2 + bit3 + bit5             ; C
         db        3 + bit2 + bit3 + bit5 + bit6      ; D
         db        3 + bit2 + bit3 + bit5             ; E
         db        3 + bit2 + bit3 + bit5             ; F
         db        3 + bit2 + bit3 + bit7             ; G
         db        3 + bit2 + bit3 + bit6             ; H
         db        3 + bit2 + bit3                    ; I
         db        3 + bit2 + bit3                    ; J
         db        3 + bit2 + bit3                    ; K
         db        3 + bit2 + bit3 + bit7             ; L
         db        3 + bit2 + bit3                    ; M
         db        3 + bit2 + bit3 + bit7             ; N
         db        3 + bit2 + bit3                    ; O
         db        3 + bit2 + bit3                    ; P
         db        3 + bit2 + bit3                    ; Q
         db        3 + bit2 + bit3 + bit6             ; R
         db        3 + bit2 + bit3 + bit6             ; S
         db        3 + bit2 + bit3 + bit6             ; T
         db        3 + bit2 + bit3 + bit7             ; U
         db        3 + bit2 + bit3                    ; V
         db        3 + bit2 + bit3 + bit7             ; W
         db        3 + bit2 + bit3                    ; X
         db        3 + bit2 + bit3                    ; Y
         db        3 + bit2 + bit3                    ; Z

         db        2 + bit2                           ; [
         db        2 + bit2 + bit3 + bit6             ; \
         db        2 + bit2                           ; ]
         db        2 + bit2 + bit3                    ; ^
         db        2 + bit2 + bit3                    ; _
         db        2 + bit2 + bit3                    ; `

         db        3 + bit2 + bit3 + bit5 + bit6      ; a
         db        3 + bit2 + bit3 + bit5 + bit7      ; b
         db        3 + bit2 + bit3 + bit5             ; c
         db        3 + bit2 + bit3 + bit5 + bit6      ; d
         db        3 + bit2 + bit3 + bit5             ; e
         db        3 + bit2 + bit3 + bit5             ; f
         db        3 + bit2 + bit3 + bit7             ; g
         db        3 + bit2 + bit3 + bit6             ; h
         db        3 + bit2 + bit3                    ; i
         db        3 + bit2 + bit3                    ; j
         db        3 + bit2 + bit3                    ; k
         db        3 + bit2 + bit3 + bit7             ; l
         db        3 + bit2 + bit3                    ; m
         db        3 + bit2 + bit3 + bit7             ; n
         db        3 + bit2 + bit3                    ; o
         db        3 + bit2 + bit3                    ; p
         db        3 + bit2 + bit3                    ; q
         db        3 + bit2 + bit3 + bit6             ; r
         db        3 + bit2 + bit3 + bit6             ; s
         db        3 + bit2 + bit3 + bit6             ; t
         db        3 + bit2 + bit3 + bit7             ; u
         db        3 + bit2 + bit3                    ; v
         db        3 + bit2 + bit3 + bit7             ; w
         db        3 + bit2 + bit3                    ; x
         db        3 + bit2 + bit3                    ; y
         db        3 + bit2 + bit3                    ; z
         db        2 + bit2 + bit3                    ; {
         db        2 + bit2                           ; |
         db        2 + bit2 + bit3                    ; }
         db        2 + bit2 + bit3                    ; ~
         db        2 + bit2 + bit3                    ; 
         db 112 dup(3+ bit2 + bit3)                   ; 128 aë 239
         db 16 dup(2 + bit2 + bit3)                   ; 240 aë 255

;; ------ vzorov† tabulka
;
;   db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
;   db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
;   db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
;   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du IBM na velk† p°smena

TbIBMUpC label     byte
   db        128,154,144,131,142,133,143,128,136,137,138,139,140,141,142,143
   db        144,145,146,147,153,149,150,151,152,153,154,155,156,157,158,159
   db        160,161,162,163,165,165,166,167,168,169,170,171,172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du IBM na mal† p°smena

TbIBMDnC label     byte
   db        135,129,130,131,132,133,134,135,136,137,138,139,140,141,132,134
   db        130,145,146,147,148,149,150,151,152,148,129,155,156,157,158,159
   db        160,161,162,163,164,164,166,167,168,169,170,171,172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na velk† p°smena

TbKamUpC label     byte
   db        'ÄöêÖéÖÜÄââäãúäéè'
   db        'êííßôï¶óùôöõúùûÜ'
   db        'èãïó••¶ßõû´´',172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na mal† p°smena

TbKamDnC label     byte
   db        'áÅÇÉÑÉüáààç°åçÑ†'
   db        'Çëëìî¢ñ£òîÅ®åò©ü'
   db        '†°¢£§§ñì®©™™',172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na velk† p°smena

TbLatUpC label     byte
   db        128,154,144,182,142,222,143,128,157,211,138,138,215,141,142,143
   db        144,145,145,226,153,149,149,151,151,153,154,155,155,157,158,172
   db        181,214,224,233,164,164,166,166,168,168,170,141,172,184,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,189,191
   db        192,193,194,195,196,197,198,198,200,201,202,203,204,205,206,207
   db        209,209,210,211,210,213,214,215,183,217,218,219,220,221,222,223
   db        224,225,226,227,227,213,230,230,232,233,232,235,237,237,221,239
   db        240,241,242,243,244,245,246,247,248,249,250,235,252,252,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na mal† p°smena

TbLatDnC label     byte

   db        135,129,130,131,132,133,134,135,136,137,139,139,140,171,132,134
   db        130,146,146,147,148,150,150,152,152,148,129,156,156,136,158,159
   db        160,161,162,163,165,165,167,167,169,169,170,171,159,173,174,175
   db        176,177,178,179,180,160,131,216,173,185,186,187,188,190,190,191
   db        192,193,194,195,196,197,199,199,200,201,202,203,204,205,206,207
   db        208,208,212,137,212,229,161,140,216,217,218,219,220,238,133,223
   db        162,225,147,228,228,229,231,231,234,163,234,251,236,236,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,253,253,254,255

; ------ konverzn° tabulka z k¢du KOI 8 na velk† p°smena

TbKOIUpC label     byte
   db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
   db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
   db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,225,194,227,228,229,230,199,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,214,247,248,249,250,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du KOI 8 na mal† p°smena

TbKOIDnC label     byte
   db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
   db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
   db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,193,226,195,196,197,198,231,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,246,215,216,217,218,251,252,253,254,255

; ------ konverzn° tabulka z k¢du WINDOWS 1250 na velk† p°smena

TbWINUpC label     byte
   db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
   db        144,145,146,147,148,149,150,151,152,153,138,155,140,141,142,143
   db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
   db        176,177,178,163,180,181,182,183,184,165,170,187,188,189,188,175
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,247,216,217,218,219,220,221,222,255

; ------ konverzn° tabulka z k¢du WINDOWS 1250 na mal† p°smena

TbWINDnC label     byte
   db        128,129,130,131,132,133,134,135,136,137,154,139,156,157,158,159
   db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
   db        160,161,162,179,164,185,166,167,168,169,186,171,172,173,174,191
   db        176,177,178,179,180,181,182,183,184,185,186,187,190,189,190,191
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,215,248,249,250,251,252,253,254,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

;; ------ konverzn° tabulka z k¢du CYRILIC na velk† p°smena
;
;TbCyrUpC label     byte
;   db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
;   db        144,145,146,147,153,149,150,151,152,153,154,155,156,157,158,159
;   db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        144,145,146,147,153,149,150,151,152,153,154,155,156,157,158,159
;   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255
;
;; ------ konverzn° tabulka z k¢du Cyrilic na mal† p°smena
;
;TbCyrDnC label     byte
;   db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
;   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
;   db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
;   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du IBM na k¢d ASCII (bez diakritiky)

TbIBMCS0 label     byte
   db        'CueaaaaceeeiiiAA'
   db        'E',145,146,'ooouuyOU',155,156,157,158,159
   db        'aiounN',166,167,168,169,170,171,172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d bez diakritiky

TbKamCS0 label     byte
   db        'CuedaDTceELIllAA'
   db        'EzZooOuUyOUSLYRt'
   db        'aiounNUOsrrR',172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d bez diakritiky

TbLatCS0 label     byte
   db        'CueaauccleOoiZAC'
   db        'ELlooLlSsOUTtLxc'
   db        'aiouAaZzEerzCs',174,175
   db        176,177,178,179,180,'AAES',185,186,187,188,'Zz',191
   db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,207
   db        'dDDEdNIIe',217,218,219,220,'TU',223
   db        'O',225,'ONnnSsRUrUyYt',239
   db        240,241,242,243,244,245,246,247,248,249,250,'uRr',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d bez diakritiky

TbKoiCS0 label     byte
   db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
   db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
   db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,'a',194,'cder',199,'uiullono'
   db        'oarstu',214,'eayz',219,220,221,222,223
   db        224,'A',226,'CDER',231,'UIULLONO'
   db        'OARSTU',246,'EAYZ',251,252,253,254,255

; ------ konverzn° tabulka z k¢du WINDOWS 1250 na k¢d bez diakritiky

TbWinCS0 label     byte
   db        128,129,',',159,'"','_',134,135,136,'%','S','<','S','T','Z','Z'
   db        144,'`', 39,'"','"',254,'-','-',152,153,'s','>','s','t','z','z'
   db        255,161,162,'L','$','A','|', 21,168,'c','S','Æ',170,169,'r','Z'
   db        248,241,178,'l', 39,230,227,254,184,'a','s','Ø','L','"','l','z'
   db        'R','A','A','A','A','L','C','C','C','E','E','E','E','I','I','D'
   db        'D','N','N','O','O','O','O','x','R','U','U','U','U','Y','T',225
   db        'r','a','a','a','a','l','c','c','c','e','e','e','e','i','i','d'
   db        'd','n','n','o','o','o','o',246,'r','u','u','u','u','y','t',249

;; ------ konverzn° tabulka z k¢du Cyrilic na k¢d ASCII
;
;TbCyrCS0 label     byte
;   db        'ABVGDEZZIJKLMNOP'
;   db        'RSTUFHCCSC`Y',39,'EUA'
;   db        'abvgdezzijklmnop'
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        'rstufhccsc`y',39,'eua'
;   db        240,'oEeIiYy',248,249,250,251,'O',253,254,255


; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d IBM

TbKamIBM label     byte
   db        'C',129,130,'d',132,'D','T','c','e','E','L','I','l','l',142,'A'
   db        144,'z','Z',147,148,'O','u','U','y',153,154,'S','L','Y','R','t'
   db        160,161,162,163,'n','N','U','O','s','r','r','R',172, 21,174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,205,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d IBM

TbLatIBM label     byte
   db        128,129,130,131,132,'u','c',135,'l',137,'O','o',140,'Z',142,'C'
   db        144,'L','l',147,148,'L','l','S','s',153,154,'T','t','L','x','c'
   db        160,161,162,163,'A','a','Z','z','E','e',170,'z','C','s',174,175
   db        176,177,178,179,180,'A','A','E','S',185,186,187,188,'Z','z',191
   db        192,193,194,195,196,197,'A','a',200,201,202,203,204,205,206,'x'
   db        'd','D','D','E','d','N','I','I','e',217,218,219,220,'T','U',223
   db        'O',225,'O','N','n','n','S','s','R','U','r','U','y','Y','t', 39
   db        '-','"','.',249,249, 21,246,',',248,'"',250,'u','R','r',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d IBM

TbKoiIBM label     byte
   db        128,151,138, 21,225,146,146,237,143,145,237,134,140,176,'$',149
   db        141,158,173,165,168,164,219,220,223,186,187,188,200,201,205,177
   db        240,241,242,243,244,245,246,247,248,251,253,171,172, 21,174,175
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        '⁄†¿cderƒÅ°ullîn¢'
   db        'ìÑrst£√Çayz¬',220,223,'=','≈'
   db        'øAŸCDER≥öIULLôNO'
   db        'OéRSTU¥êAYZ¡',252,249,254,255

; ------ konverzn° tabulka z k¢du WINDOWS 1250 na k¢d IBM

TbWinIBM label     byte
   db        128,129,',',159,'"','_',134,135,136,'%','S','<','S','T','Z','Z'
   db        144,'`', 39,'"','"',254,'-','-',152,153,'s','>','s','t','z','z'
   db        255,161,162,'L','$','A','|', 21,168,'c','S','Æ',170,169,'r','Z'
   db        248,241,178,'l', 39,230,227,254,184,'a','s','Ø','L','"','l','z'
   db        'R','A','A',143,142,'L','C',128,'C',144,'E','E','E','I','I','D'
   db        'D','N','N','O','O','O',153,'x','R','U','U','U',154,'Y','T',225
   db        'r',160,131,134,132,'l','c',135,'c',130,'e',137,'e',161,140,'d'
   db        'd','n','n',162,147,'o',148,246,'r','u',163,'u',129,'y','t',249

;; ------ konverzn° tabulka z k¢du Cyrilic na k¢d IBM
;
;TbCyrIBM label     byte
;   db        'ABVGDEZZIJKLMNOP'
;   db        'RSTUFHCCSC`Y',39,'EUA'
;   db        'abvgdezzijklmnop'
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        'rstufhccsc`y',39,'eua'
;   db        240,'oEeIiYy',248,249,250,251,'O','$',254,255

; ------ konverzn° tabulka z k¢du IBM na k¢d Kamenickòch

TbIBMKam label     byte
   db        'C',129,130,'a',132,'a','a','c','e','e','e','i','i','i',142,'A'
   db        144,'z','A',147,148,'o','u','u','y',153,154,'c','L','Y','P','f'
   db        160,161,162,163,'n','N','a','o','s','⁄','ø','/',172,'i',174,175
   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d Kamenickòch

TbLatKam label     byte
   db        'CÅÇaÑñccleôîiZéC'
   db        'êäçìîúåSsôöÜüLxá'
   db        '†°¢£AaíëEeøzÄsÆØ'
   db        176,177,178,179,180,'èAâS',185,186,187,188,'Zz',191
   db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,'x'
   db        'dDÖEÉ•ãIà',217,218,219,220,'T¶',223
   db        'ï',225,'ßNn§õ®´ó™öòùt',39
   db        '-".""≠ˆ,¯"',250,'Åû©',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d Kamenickòch

TbKoiKam label     byte
   db        'C','u','e',173,225,'L','A',237,'A','z',237,'a','i',176,'$','o'
   db        'i','P','i','N','s','n',219,220,223,186,187,188,200,201,205,177
   db        240,241,242,243,244,245,246,247,248,251,253,171,172, 21,174,175
   db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        '⁄†¿áÉà™ƒÅ°ñçåî§¢'
   db        'ìÑ©®ü£√Ç†òë¬',220,39,248,'≈'
   db        'øèŸÄÖâ´≥öã¶äúô•ï'
   db        'ßéûõÜó¥êèùí¡',252,'^',254,255

; ------ konverzn° tabulka z k¢du WINDOWS 1250 na k¢d Kamenickòch

TbWinKam label     byte
   db        128,129,',',131,'"','_',134,135,136,'%',155,'<','S',134,146,'Z'
   db        144,'`', 39,'"','"',254,'-','-',152,153,168,'>','s',159,145,'z'
   db        255,161,162,'L','$','A','|',173,168,'c','S','Æ','-','-','r','Z'
   db        248,241,178,'l', 39,230,227,254,184,'a','s','Ø',156,'"',140,'z'
   db        171,143,'A','A',142,138,'C','C',128,144,'E','E',137,139,'I',133
   db        'D','N',165,149,167,'O',153,'x',158,166,151,'U',154,157,'T',225
   db        170,160,'a','a',132,141,'c','c',135,130,'e','e',136,161,'i',131
   db        'd','n',164,162,147,'o',148,246,169,150,163,'u',129,152,'t',249

;; ------ konverzn° tabulka z k¢du Cyrilic na k¢d Kamenickòch
;
;TbCyrKam label     byte
;   db        'ABVGDâíZIJKLMNOP'
;   db        'RSTUFHCÄõÄ`Y',39,'Eóè'
;   db        'abvgdàëzijklmnop'
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        'rstufhcá®á`y',39,'e£†'
;   db        240,'¢Eeã°ùò',248,249,250,251,'ï',253,254,255

; ------ konverzn° tabulka z k¢du IBM na k¢d Latin 2

TbIBMLat label     byte
   db        128,129,130,131,132,'a','a',135,'e',137,'e','i',140,'i',142,'A'
   db        144,'z','A',147,148,'o','u','u','y',153,154,'c',157,'Y','P','f'
   db        160,161,162,163,'n','N','a','o','s','⁄',170,'2','4','i',174,175
   db        176,177,178,179,180,179,186,187,187,185,186,187,188,188,188,191
   db        192,193,194,195,196,197,179,186,200,201,202,203,204,205,206,205
   db        196,205,196,200,200,201,201,186,205,217,218,219,220,219,219,223
   db        'a',225,'⁄','n','S','o','u','t','o','O','O','d','o','0','E','N'
   db        '=','+','>','<',218,217,246,'=',248,250,250,'o','n','2',254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d Latin 2

TbKamLat label     byte
   db        172,'ÅÇ',212,'Ñ',210,155,159,216,183,145,214,150,146,'é',181
   db        'ê',167,166,'ìî',224,133,233,236,'ôö',230,149,237,252,156
   db        '†°¢£',229,213,222,226,231,253,234,232,'/',245,174,175
   db        176,177,178,179,180,179,186,187,187,185,186,187,188,188,188,191
   db        192,193,194,195,196,197,179,186,200,201,202,203,204,205,206,205
   db        196,205,196,200,200,201,201,186,205,217,218,219,220,219,219,223
   db        'a',225,'⁄','n','S','o','u','t','o','O','O','d','o','0','E','N'
   db        '=','+','>','<',218,217,246,'=',248,250,250,'o','n','2',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d Latin 2

TbKoiLat label     byte
   db        128,'u','e',245,225,157,'A','o','A','z','o','a',140,176,'$','o'
   db        'i','P','i','N','s','n',219,220,223,186,187,188,200,201,205,177
   db        '=','+','>','<',218,217,246,'=',248,'V','2','2','4',245,174,175
   db        'a',225,'⁄','n','S','o','u','t','o','O','O','d','o','0','E','N'
   db        '⁄','†','¿',159,212,216,234,'ƒ',129,'°',133,146,150,148,229,'¢'
   db        147,132,253,231,156,'£','√','Ç','†',236,167,'¬',243, 39,248,'≈'
   db        'ø',181,'Ÿ',172,210,183,232,'≥','ö',214,222,145,149,'ô',213,224
   db        226,142,252,230,155,233,'¥','ê',181,237,166,'¡',249,'^',254,255

; ------ konverzn° tabulka z k¢du WINDOWS 1250 na k¢d Latin 2
;˛
TbWinLat label     byte
   db        128,129,',',131,'"','_',134,135,136,'%',230,'<',151,155,166,141
   db        144,'`',239,'"',241,254,'-',240,152,153,231,'>',152,156,167,171
   db        255,243,244,157,207,164,'|',245,249,'c',184,'Æ',170,240,'r',189
   db        248,'+',242,136,239,'u',203,254,247,165,173,'Ø',149,241,150,190
   db        232,181,182,198,142,145,143,128,172,144,168,211,183,214,215,210
   db        209,227,213,224,226,138,153,158,252,222,233,235,154,237,221,225
   db        234,160,131,199,132,146,134,135,159,130,169,137,216,161,140,212
   db        208,228,229,162,147,139,148,246,253,133,163,251,129,236,238,250

;; ------ konverzn° tabulka z k¢du Cyrilic na k¢d Latin 2
;
;TbCyrLat label     byte
;   db        'ABVGD',183,166,'ZIJKLMNOP'
;   db        'RSTUFHC',172,230,172,'`Y',39,'E',233,181
;   db        'abvgd',216,167,'zijklmnop'
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        'rstufhc',159,231,159,'`y',39,'e',163,'†'
;   db        240,'¢Ee',214,'°',237,236,248,249,250,251,224,'$',254,255

; ------ konverzn° tabulka z k¢du IBM na k¢d KOI 8

TbIBMKOI label     byte
   db        128,200,215,'a',209,216,139,'c','e','e',130,'i',140,144,241,'A'
   db        144,137,134,208,205,143,'u',129,'y',237,232,'c',133,'Y',145,'f'
   db        193,201,207,213,'n','N','a','o',148,192,224,171,172,'i',174,175
   db        141,159,150,231,246,246,246,224,224,246,231,224,226,226,226,224
   db        194,251,219,214,199,223,214,214,194,192,251,219,214,199,223,251
   db        251,219,219,194,194,192,192,223,223,226,192,150,220,231,231,221
   db        176,177,178,179,180,180,180,191,191,185,186,187,188,189,190,191
   db        160,161,162,163,164,165,166,167,168,253,253,169,252,170,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d KOI 8

TbKamKoi label     byte
   db        227,200,215,196,209,228,244,195,197,229,235,233,204,203,241,225
   db        247,218,250,208,205,239,202,245,217,237,232,243,236,249,242,212
   db        193,201,207,213,206,238,234,240,211,210,198,230,172,131,174,175
   db        141,159,150,231,246,246,246,224,224,246,231,224,226,226,226,224
   db        194,251,219,214,199,223,214,214,194,192,251,219,214,199,223,251
   db        251,219,219,194,194,192,192,223,223,226,192,150,220,231,231,221
   db        176,177,178,179,180,180,180,191,191,185,186,187,188,189,190,191
   db        160,161,162,163,164,165,166,167,168,253,253,169,252,170,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d KOI 8

TbLatKoi label     byte
   db        128,200,215,'a',209,202,'c','c','l','e',237,208,'i','Z',241,'C'
   db        247,235,203,208,205,236,204,'S','s',237,232,244,212,'L','x',195
   db        193,201,207,213,'A','a',250,218,'E','e',224,'z',227,'s',174,175
   db        141,159,150,231,246,225,'A',229,'S',246,231,224,226,'Z','z',224
   db        194,251,219,214,199,223,'A','a',194,192,251,219,213,199,223,'x'
   db        'd','D',228,'E',196,238,233,'I',197,226,192,219,220,'T',234,223
   db        239,225,240,'N','n',206,243,211,230,245,198,232,217,249,'t', 39
   db        '-',252,'.',220,220,131,':',',',222,252,254,200,242,210,254,255

; ------ konverzn° tabulka z k¢du Windows 1250 na k¢d KOI 8

TbWinKoi label     byte
   db        128,129,',',131,'"','_',134,135,136,'%',243,'<','S',244,250,'Z'
   db        144,'`', 39,'"','"',254,'-','-',152,153,211,'>','s',212,218,'z'
   db        255,161,162,'L',142,'A',231,131,168,'c','S',174,199,199,'r','Z'
   db        168,161,178,'l', 39,182,179,254,184,'a','s',175,236,'"',204,'z'
   db        230,225,'A',136,241,235,'C','C',227,247,'E','E',229,233,'I',228
   db        'D','N',238,239,240,'O',237,'x',242,234,245,'U',232,249,'T',177
   db        198,193,'a',139,209,203,'c','c',195,215,'e','e',197,201,140,196
   db        'd','n',206,207,208,'o',205,166,210,202,213,'u',200,217,'t',253

;; ------ konverzn° tabulka z k¢du Cyrilic na k¢d KOI 8
;
;TbCyrKoi label     byte
;   db        'ABVGD',229,250,'ZIJKLMNOP'
;   db        'RSTUFHC',227,243,227,'`Y',39,'E',245,225
;   db        'abvgd',197,218,'zijklmnop'
;   db        141,159,150,231,246,246,246,224,224,246,231,224,226,226,226,224
;   db        194,251,219,214,199,223,214,214,194,192,251,219,214,199,223,251
;   db        251,219,219,194,194,192,192,223,223,226,192,150,220,231,231,221
;   db        'rstufhc',195,211,195,'`y',39,'e',213,193
;   db        240,207,'Ee',233,201,249,217,248,249,250,251,239,253,254,255
;

; ------ konverzn° tabulka z k¢du IBM na Windows 1250

TbIBMWin label     byte
   db        199,252,233,226,228,'a',227,231,'e',235,'e','i',238,'i',196,195
   db        201,145,146,244,246,'o','u','u','y',214,220,'c','L','Y','P',131
   db        225,237,243,250,'n','N','a','o',168,150,172,171,172,173,171,187
   db        ' ',' ',' ','|','+','+','+','+','+','+','|','+','+','+','+','+'
   db        '+','+','+','+','-','+','+','+','+','+','+','+','+','-','+','+'
   db        '+','+','+','+','+','+','+','+','+','+','+',' ',' ',' ',' ',' '
   db        224,223,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,177,155,139,244,245,247,247,176,249,250,251,252,253,149,160

; ------ konverzn° tabulka z k¢du Kamenickòch na Windows 1250

TbKamWin label     byte
   db        200,252,233,239,228,207,141,232,236,204,197,205,190,229,196,193
   db        201,158,142,244,246,211,249,218,253,214,220,138,188,221,216,157
   db        225,237,243,250,242,210,217,212,154,248,224,192,'/',167,171,187
   db        ' ',' ',' ','|','+','+','+','+','+','+','|','+','+','+','+','+'
   db        '+','+','+','+','-','+','+','+','+','+','+','+','+','-','+','+'
   db        '+','+','+','+','+','+','+','+','+','+','+',' ',' ',' ',' ',' '
   db        224,223,226,227,228,229,230,231,232,233,234,235,236,237,238,239
   db        240,177,155,139,244,245,247,247,176,249,250,251,252,253,149,160

; ------ konverzn° tabulka z k¢du Latin 2 na Windows 1250

TbLatWin label     byte
   db        199,252,233,226,228,249,230,231,179,235,213,245,238,143,196,198
   db        201,197,229,244,246,188,190,140,156,214,220,141,157,163,215,232
   db        225,237,243,250,165,185,142,158,202,234,172,159,200,186,171,187
   db        ' ',' ',' ','|','+',193,194,204,170,'+','|','+','+',175,191,'+'
   db        '+','+','+','+','-','+',195,227,'+','+','+','+','+','-','+',164
   db        240,208,207,203,239,210,205,206,236,'+','+',' ',' ',222,217,' '
   db        211,223,212,209,241,242,138,154,192,218,224,219,253,221,254,180
   db        173,148,178,161,162,167,247,184,176,168,255,251,216,248,149,160

; ------ konverzn° tabulka z k¢du KOI 8 na Windows 1250

TbKoiWin label     byte
   db        199,'u','e',167,223,'L',134,135,'A','z',138,'a',238,' ',164,'o'
   db        'i','P','!','N',148,'n',' ',' ',' ','|','+','+','+','+','-',' '
   db        '=',177,155,139,164,165,247,'=',176,169,170,171,172,167,171,187
   db        176,223,178,182,180,181,181,183,184,185,186,187,188,189,190,191
   db        '+',225,'+',232,239,236,224,'-',252,237,249,229,190,246,242,243
   db        244,228,248,154,157,250,'+',233,'a',253,158,'+',' ',' ','-','+'
   db        '+',193,'+',200,207,204,192,'|',220,205,217,197,188,214,210,211
   db        212,196,216,138,141,218,'+',201,'A',221,142,'+','n',255,149,160

;; ------ konverzn° tabulka z k¢du IBM na Cyrilic
;
;TbIBMCyr label     byte
;   db        150,227,237,160,160,160,160,230,237,241,237,168,168,168,128,128
;   db        157,167,128,174,174,174,227,227,235,142,147,150,139,155,143,228
;   db        239,245,241,238,173,141,160,174,225,218,191,'2','4',168,'<','>'
;   db        176,177,178,179,180,180,180,191,191,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        160,161,131,175,145,164,172,226,228,174,142,164,174,174,242,143
;   db        240,'+','>','<',218,217,':','=',248,249,250,251,'n','2',254,255
;
;; ------ konverzn° tabulka z k¢du ASCII na k¢d Cyrilic - mus° bòt p©e KAMEN. !!!
;
;TbAscCyr label     byte
;   db        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
;   db        16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
;   db        32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
;   db        '0123456789:;<=>?'
;   db        64,128,129,150,132,157,148,131,149,136,137,138,139,140,141,142
;   db        143,142,144,145,146,147,130,130,149,155,135,'[\]^_'
;   db        96,160,161,230,164,237,228,163,229,168,169,170,171,172,173,174
;   db        175,174,224,225,226,227,162,162,229,235,167,'{|}~',127
;
;; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d Cyrilic
;
;TbKamCyr label     byte
;   db        151,227,237,164,160,132,146,231,165,133,139,136,171,171,128,128
;   db        157,166,134,174,174,252,238,158,235,142,147,152,139,155,144,226
;   db        239,245,241,238,173,141,158,142,232,224,224,144,'4', 21,'<','>'
;   db        176,177,178,179,180,180,180,191,191,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        160,161,131,175,145,164,172,226,228,174,142,164,174,174,242,143
;   db        240,'+','>','<',218,217,':','=',248,249,250,251,'n','2',254,255
;
;; ------ konverzn° tabulka z k¢du Latin 2 na k¢d Cyrilic
;
;TbLatCyr label     byte
;   db        150,227,237,160,160,238,230,230,171,241,174,142,168,135,128,128
;   db        157,139,171,174,174,139,171,145,225,142,147,146,226,139,229,231
;   db        239,245,241,238,128,160,134,166,157,237,191,167,151,225,'<','>'
;   db        176,177,178,179,180,239,128,133,145,185,186,187,188,135,167,191
;   db        192,193,194,195,196,197,128,160,200,201,202,203,204,205,206,229
;   db        164,132,132,252,164,141,136,136,165,217,218,219,220,146,158,223
;   db        252,161,142,141,173,173,152,232,144,158,224,147,235,155,226, 39
;   db        240,'"','.','^','^', 21,':',',',248,249,250,227,144,224,254,255
;
;; ------ konverzn° tabulka z k¢du KOI 8 na k¢d Cyrilic (???)
;
;TbKoiCyr label     byte
;   db        'ABVGDâíZIJKLMNOP'
;   db        'RSTUFHCÄõÄ`Y',39,'Eóè'
;   db        'abvgdàëzijklmnop'
;   db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;   db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;   db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;   db        'rstufhcá®á`y',39,'e£†'
;   db        240,'¢Eeã°ùò',248,249,250,251,'ï',253,254,255

CodeDek  ENDS

Data     SEGMENT

DnyDate  db        'Ne'                     ; dny v tòdnu
         db        'Po'
         db        'ót'
         db        'St'
         db        'Ät'
         db        'P†'
         db        'So'

Data     ENDS
         END

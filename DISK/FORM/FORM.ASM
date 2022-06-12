

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Form†tov†n° disket
;
;        Program se doporuáuje p©ekonvertovat na EXE, aby se rezervovala
;                         za n°m pamàü asi 55 KB
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

HI       EQU       256

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
bit8     EQU       100h
bit9     EQU       200h
bit10    EQU       400h
bit11    EQU       800h
bit12    EQU       1000h
bit13    EQU       2000h
bit14    EQU       4000h
bit15    EQU       8000h

Ram1     EQU       22                       ; ®°©ka levÇho okraje v r†mu
Ram2     EQU       32                       ; ®°©ka vnit©n°ho okraje r†mu
Ram3     EQU       22                       ; ®°©ka pravÇho okraje v r†mu

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Start programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         org       100h

; ------ stanoven° poátu disketovòch jednotek

Start:   push      es
         mov       ax,823h
         call      Int13                    ; poskytnut° aktu†ln°ch parametrñ
         pop       es
         or        ax,ax                    ; je funkce platn† ?
         jne       Start01                  ; funkce nen° platn† - implicitn°
         cmp       dl,4
         ja        Start01                  ; velkò poáet diskñ - asi chyba
         mov       ds:[NumDisk],dl          ; poáet disket
         cmp       dl,0                     ; je nàjak† disketa ?
         jne       Start01                  ; je nàjak† disketa

; ------ chyba - nen° ë†dn† disketa

         mov       dx,offset NoDisk
         mov       ah,9
         int       21h                      ; chyba - nen° disketa
         int       20h

; ------ inicializace videom¢du

Start01: call      DetCard                  ; detekce videokarty
         call      InitVMod                 ; inicializace videom¢du

; ------ kontrola pamàti

         mov       al,160                   ; poáet bajtñ na ©†dek
         mul       byte ptr ds:[Radku]      ; vòpoáet dÇlky videostr†nky
         mov       cx,ax                    ; dÇlka videostr†nky
         add       ax,offset ObrBuf + 1000h + 2*18*512 ; kontrola pamàti
         cmp       ax,sp                    ; je dost pamàti
         jbe       Start02                  ; je dost pamàti

; ------ nedostatek pamàti

         mov       dx,offset MemTxt
         mov       ah,9
         int       21h
         int       20h

; ------ £schova obsahu obrazovky

Start02: push      ds
         mov       di,offset ObrBuf
         shr       cx,1                     ; poáet slov
         mov       ds:[ObrSize],cx          ; £schova velikosti vieostr†nky
         push      ds
         pop       es
         lds       si,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds

; ------ adresa diskovÇho bufferu

         mov       ax,cs
         shr       di,1
         shr       di,1
         shr       di,1
         shr       di,1
         add       ax,di
         add       ax,10
         mov       ds:[Int13Buf],ax
         and       ax,0fffh
         add       ax,18*512/16
         test      ax,0f000h
         jz        Start03
         add       word ptr ds:[Int13Buf],18*512/16

; ------ £schova kurzoru

Start03: call      GetKurz                  ; poskytnut° pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ obsluha p©eru®en°

         mov       ax,2523h
         mov       dx,offset INT23
         int       21h
         mov       ax,2524h
         mov       dx,offset INT24
         int       21h

; ------ oprava barev pro monochromatickò displej

         cmp       byte ptr ds:[AdrVRAM+3],0b8h
         je        Start1

         push      ds
         pop       es
         mov       si,offset ColMono
         mov       cx,offset(ColMono0-ColMono)
         mov       di,offset Color
         cld
         rep       movsb

; ------ volba aktivn°ho disku

Start1:  cmp       byte ptr ds:[NumDisk],1
         je        Start2                   ; je jenom 1 disk - nen° volba
         call      Podklad                  ; zobrazen° podkladu
         mov       si,offset HelpTxt1
         call      DispHelp                 ; zobrazen° n†povàdy
Start12: call      DispDisk                 ; zobrazen° volby diskñ
Start13: call      InpChr                   ; vstup znaku z kl†vesnice

         call      JumpBX

         dw        4b00h,Start14            ; kurzor vlevo
         dw        4f00h,Start15            ; End
         dw        4d00h,Start16            ; kurzor vpravo
         dw        4700h,Start17            ; Home
         dw        1bh,Main0                ; p©eru®en° ESC
         dw        0dh,Start2               ; vòbàr disku ENTER
         dw        0,Start18

                                          ;* kurzor vlevo
Start14: dec       byte ptr ds:[AktDisk]
         jns       Start12
Start15: mov       al,ds:[NumDisk]
         dec       ax
         mov       byte ptr ds:[AktDisk],al
         jmp       short Start12

                                          ;* kurzor vpravo
Start16: inc       byte ptr ds:[AktDisk]
         mov       al,ds:[NumDisk]
         cmp       al,ds:[AktDisk]
         ja        Start12
Start17: mov       byte ptr ds:[AktDisk],0
         jmp       short Start12

                                          ;* zad†n° disku znakem
Start18: sub       bl,"A"
         jb        Start13
         cmp       bl,ds:[NumDisk]
         jae       Start13
         mov       ds:[AktDisk],bl

; ------ p©ednastaven° form†tu diskety

Start2:  mov       byte ptr ds:[TypDisk],0  ; nezn†mò disk
         push      es
         mov       ax,823h
         call      Int13                    ; poskytnut° aktu†ln°ch parametrñ
         pop       es
         or        ax,ax                    ; je funkce platn† ?
         jnz       Start21                  ; funkce nen° platn† - implicitn°
         cmp       dl,4
         ja        Start21                  ; velkò poáet diskñ - asi chyba
         cmp       bl,4
         ja        Start21
         mov       ds:[TypDisk],bl
         mov       bh,0
         mov       al,ds:[bx+FormTypD]      ; p©ednastavenò form†t
         mov       ds:[AktForm],al

; ------ volba form†tu diskety

Start21: mov       ah,1
         int       16h
         jz        Start211
         call      InpChr
         jmp       short Start21

Start211:call      Podklad                  ; zobrazen° podkladu
         mov       al,ds:[AktDisk]
         add       al,"A"
         mov       ds:[HelpTx2D],al
         mov       ds:[HelpTx3D],al
         mov       ds:[HelpTx4D],al
         mov       si,offset HelpTxt2
         call      DispHelp                 ; zobrazen° n†povàdy
Start22: call      DispForm                 ; zobrazen° form†tñ disku
Start23: call      InpChr                   ; vstup znaku z kl†vesnice

         call      JumpBX

         dw        4800h,Start25            ; nahoru
         dw        4f00h,Start26            ; END
         dw        5000h,Start27            ; dolñ
         dw        4700h,Start28            ; HOME

         dw        1bh,Start24              ; p©eru®en° ESC
         dw        0dh,Start2a              ; ENTER

         dw        0,Start29

                                          ;* p©eru®en° ESC
Start24: cmp       byte ptr ds:[NumDisk],1
         je        Main0                    ; konec
         jmp       Start1                   ; volba disku

                                          ;* kurzor nahoru
Start25: dec       byte ptr ds:[AktForm]
         jnz       Start22
Start26: mov       byte ptr ds:[AktForm],7
         jmp       short Start22

                                          ;* kurzor dolñ
Start27: inc       byte ptr ds:[AktForm]
         cmp       byte ptr ds:[AktForm],7
         jbe       Start22
Start28: mov       byte ptr ds:[AktForm],1
         jmp       short Start22

                                          ;* zad†n° form†tu á°slem
Start29: sub       bl,"0"
         jbe       Start23
         cmp       bl,7
         ja        Start23
         mov       ds:[AktForm],bl
         jmp       short Start22

                                          ;* form†tov†n° diskety
Start2a: call      FormDisk                 ; form†tov†n° diskety
         jmp       Start21

; ------ n†vrat z programu

Main0:   push      cs
         pop       ds

         call      PopScr                   ; n†vrat obsahu obrazovky

         call      DeInst1e

         int       20h                      ; n†vrat z programu

PUBLIC   PopScr

; -----------------------------------------------------------------------------
;        n†vrat obsahu obrazovky
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

         push      cx
         push      si
         push      di
         push      es

         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       si,offset ObrBuf         ; buffer obrazovky
         mov       cx,ds:[ObrSize]          ; velikost videopamàti
         cld
         rep       movsw                    ; n†vrat obsahu obrazovky

         mov       dx,ds:[OldKurz]          ; pñvodn° pozice kurzoru
         call      SetKurz                  ; n†vrat pozice kurzoru

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

PopScr   ENDP



INT24    PROC      FAR

         mov       al,0
INT23:   iret

INT24    ENDP


; *****************************************************************************
;                               InpChr
;                       vstup znaku z kl†vesnice
; -----------------------------------------------------------------------------
; VùSTUP:BX=kl†vesa
; *****************************************************************************

PUBLIC   InpChr

InpChr   PROC      NEAR

         call      KurzOff

         push      ax
         mov       ah,0
         int       16h

         or        ax,ax
         jnz       InpChr0
         mov       al,1bh
InpChr0:
         cmp       al,0
         je        InpChr1
         mov       ah,0

InpChr1: cmp       al,"a"
         jb        InpChr2
         cmp       al,"z"
         ja        InpChr2
         sub       al,32                    ; korekce na velkÇ p°smeno
InpChr2: mov       bx,ax
         pop       ax

         ret

InpChr   ENDP

; *****************************************************************************
;                              FormDisk
;                        form†tov†n° diskety
; -----------------------------------------------------------------------------
;
; *****************************************************************************

PUBLIC   FormDisk

FormDisk PROC      NEAR
;˛

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         call      Inst1e                   ; instalace tabulky disk. parametrñ

; ------ stanoven° sÇriovÇho á°sla

FormDsk0:call      SetSer                   ; nastaven° sÇriovÇho á°sla

; ------ inicializace ukazatelñ

         xor       ax,ax
         mov       byte ptr ds:[AktStop],al ; ukazatel stop
         mov       byte ptr ds:[AktStran],al ; strana
         mov       word ptr ds:[AktSekt],ax ; ukazatel absolutn°ho sektoru
         and       byte ptr ds:[Priznaky],not bit0 + bit1 ; nulov†n° p©°znakñ
         mov       word ptr ds:[VolSekt],ax
         mov       word ptr ds:[BadSekt],ax
         mov       word ptr ds:[FrstChar],ax
         mov       byte ptr ds:[FillCh],0   ; plnic° znak pro form†tov†n°

; ------ text pro chybovÇ hl†®en°

         push      ds
         pop       es
         mov       al,ds:[AktForm]
         dec       ax
         mov       ah,5
         mul       ah
         mov       si,offset HelpTXFR
         add       si,ax
         mov       di,offset HelpTx3F
         mov       cx,5
         cld
         rep       movsb

; ------ nulov†n° tabulky FAT

         mov       di,offset TabFat
         mov       cx,9*512/2
         xor       ax,ax
         cld
         rep       stosw                    ; nulov†n° tabulky FAT

; ------ nalezen° adresy tabulky parametrñ

         mov       al,ds:[AktForm]          ; aktivn° form†t
         dec       ax
         mov       ah,8                     ; poáet bajtñ na popisovaá
         mul       ah                       ; offset v tabulce
         mov       si,offset ParForm        ; tabulka prametrñ
         add       si,ax                    ; adresa popisovaáe

; ------ poá†teán° pozice na obrazovce

         mov       al,ds:[Radku]            ; poáet ©†dkñ celkem
         sub       al,2
         sub       al,ds:[si]               ; odeáten° ©†dkñ na r†meáky
         shr       al,1
         mov       byte ptr ds:[pozRF+1],al ; poá†teán° ©†dek

; ------ parametry diskety

         mov       ax,1
         mov       ds:[FirstDat],ax         ; prvn° datovò blok

         mov       al,ds:[si+1]             ; max. á°slo stopy
         mov       ds:[MaxStop],al          ; maxim†ln° á°slo stopy

         mov       al,ds:[si+2]             ; maxim†ln° á°slo strany
         mov       ds:[MaxStran],al         ; maxim†ln° á°slo strany

         mov       al,ds:[si+3]             ; poáet disket
         mov       ds:[MaxSekt],al          ; poáet sektorñ

         mov       al,ds:[si+4]             ; poáet sektorñ na alokaán° blok
         mov       ds:[BBlok],al            ; poáet sektorñ na alokaán° blok

         mov       al,ds:[si+5]             ; poáet sektorñ na ROOT
         add       ds:[FirstDat],ax         ; p©iáten° sektorñ na ROOT
         mov       ds:[SektRoot],ax         ; poáet sektorñ na ROOT
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       ds:[BRoot],ax            ; poáet poloëek na ROOT

         mov       al,ds:[si+6]             ; popisovaá mÇdia
         mov       ds:[BIdent],al           ; popisovaá mÇdia

         mov       al,ds:[si+7]             ; poáet sektorñ na jednu FAT
         mov       byte ptr ds:[BNFat],al   ; poáet sektorñ na FAT
         shl       ax,1                     ; poáet sektorñ celkem na FAT
         add       ds:[FirstDat],ax         ; p©iáten° sektorñ na FAT

         mov       ah,ds:[MaxSekt]          ; maxim†ln° á°slo sektoru
         mov       byte ptr ds:[BSekt],ah   ; poáet sektorñ na stopu

         mov       al,ds:[MaxStran]         ; maxim†ln° á°slo strany
         inc       ax
         mov       byte ptr ds:[BStran],al  ; poáet stran

         mul       ah                       ; poáet stran * poáet sektorñ
         mov       ah,ds:[MaxStop]          ; maxim†ln° á°slo stopy
         inc       ah
         mul       ah                       ; celkovò poáet sektorñ
         mov       ds:[BNMax],ax            ; celkovò poáet sektorñ mÇdia

         sub       ax,ds:[FirstDat]         ; odeáten° rezervovanòch sektorñ
         mov       ds:[CelkSekt],ax         ; celkovò poáet datovòch sektorñ

; ------ roztoáen° mechaniky

         push      es
         xor       bx,bx                    ; offset adresy
         mov       es,bx                    ; ES <- 0
         mov       al,1                     ; 1 sektor staá°
         mov       ah,4                     ; funkce verifikace
         mov       cx,1                     ; v†lec a sektor
         mov       dh,0                     ; strana
         call      Int13                    ; verifikace - roztoáen° mechaniky
         pop       es

; ------ nastaven° form†tu diskety

         call      Podklad
FormDsk1:call      DispNSek                 ; zobrazen° hl†®en°
         call      ResDisk                  ; inicializaán° reset disku
         call      SetForm                  ; nastaven° form†tu diskety
         jnc       FormDsk4

; ------ chyba - neplatnò form†t nebo nen° disketa

         mov       si,offset HelpTxt3
         cmp       ah,0ch
         je        FormDsk3
FormDsk2:mov       si,offset HelpTxt4       ; text - nen° disketa
         call      DispHelp
         call      InpChr
         cmp       bl,13
         je        FormDsk1                 ; opakov†n° operace
         jmp       FormDs99                 ; konec

FormDsk3:jmp       FormDs98

; ------ zobrazen° pole pro form†tov†n°

FormDsk4:
         call      DispRF
         call      DispNSek                 ; zobrazen° hl†®en°

; ------ test, zda je p©eru®en° operace

FormDsk5:mov       ah,1
         int       16h
         jz        FormDs51
         call      InpChr
         cmp       bl,27
         jne       FormDs51
         call      UlozBad                  ; uloëen° tabulky vadnòch sektorñ
         jmp       FormDs99

; ------ aktu†ln° pozice kurzoru na displeji

FormDs51:mov       dx,ds:[PozRF]            ; pozice r†meáku
         add       dx,101h
         mov       cl,ds:[AktStop]          ; stopa
         cmp       cl,40
         jb        FormDs52
         sub       cl,40
         add       dh,6
FormDs52:add       dl,cl
         add       dh,ds:[AktStran]
         mov       ds:[AktPozF],dx          ; aktu†ln° pozice

; ------ nastaven° plnic°ho znaku pro form†tov†n°

         mov       ax,ds:[AktSekt]          ; absolutn° á°slo sektoru
         cmp       ax,ds:[FirstDat]         ; jsou jië data ?
         jb        FormDs58                 ; nejsou je®tà data
         cmp       byte ptr ds:[FillCh],0F6h ; je jië plnic° znak F6 ?
         je        FormDs57                 ; je jië plnic° znak F6
         mov       byte ptr ds:[FillCh],0F6h ; nastaven° plnic°ho znaku F6
         jmp       short FormDs58
FormDs57:or        byte ptr ds:[Priznaky],bit1 ; data jsou jë nemànn†

; ------ form†tov†n° jednÇ stopy

FormDs58:call      Format                   ; zform†tov†n° jednÇ stopy
         jnc       FormDs60
         cmp       ah,80h
         je        FormDsk2                 ; nen° disketa
         cmp       ah,3                     ; z†kaz z†pisu
         jne       FormDs60
FormDs5a:mov       si,offset HelpTxt8       ; text - ochrana proti z†pisu

         jmp       FormDs98

; ------ generov†n° datovòch sektorñ

FormDs60:push      ds
         pop       es
         mov       di,offset DataBuf        ; datovò buffer stopy
         mov       ax,ds:[AktSekt]          ; absolutn° á°slo sektoru
         mov       bx,0                     ; BL=koncovò, BH=poá†teán° sektor
         mov       dl,1                     ; ukazatel á°sla sektoru
FormDs61:call      GetSekt                  ; generov†n° sektoru
         jc        FormDs63                 ; sektor nebyl generov†n
         cmp       bh,0                     ; je jië poá†teán° sektor ?
         jne       FormDs62                 ; je jië poá†teán° sektor
         mov       bh,dl                    ; poá†teán° sektor
         mov       si,di                    ; £schova adresy
FormDs62:mov       bl,dl                    ; koncovò sektor

FormDs63:inc       dl                       ; zvò®en° ukazatele sektorñ
         inc       ax                       ; zvò®en° á°sla absolutn°ho sektoru
         add       di,512                   ; zvò®en° adresy
         cmp       dl,ds:[MaxSekt]          ; jsou jië v®echny sektory ?
         jbe       FormDs61                 ; dal®° sektor
         mov       ds:[AktSekt],ax          ; novò absolutn° sektor

; ------ z†pis datovòch sektorñ

         mov       al,bl                    ; koncovò sektor
         cmp       al,0                     ; byla nàjak† data ?
         je        FormDs66                 ; nebyla ë†dn† data
         mov       cl,bh                    ; poá†teán° sektor
         inc       ax                       ; koncovò sektor + 1
         sub       al,cl                    ; poáet sektorñ k z†pisu
         mov       bx,si                    ; adresa dat v bufferu
         call      Zapis                    ; z†pis sektorñ na disk
         jnc       FormDs66
         cmp       ah,3                     ; z†kaz z†pisu
         je        FormDs5a
         cmp       ah,80h
         jne       FormDs66

FormDs64:mov       ax,ds:[BSekt]            ; poáet sektorñ na stopu
         sub       ds:[AktSekt],ax          ; n†vrat á°sla sektoru
         jmp       FormDsk2                 ; opakov†n° operace

; ------ verifikace sektorñ

FormDs66:call      Verif                    ; verifikace stopy
         jnc       FormDs81
         cmp       ah,80h
         je        FormDs64                 ; nen° disketa
         stc

; ------ nastaven° oznaáen° operace

FormDs81:mov       bl,0                     ; p©°znak operace OK
         mov       ah,ds:[ColOK]
         mov       al,178
         jnc       FormDs82
         mov       bl,1                     ; p©°znak - chyba operace
         mov       ah,ds:[ColErr]
         mov       al,"x"
FormDs82:call      DispFCh
         cmp       word ptr ds:[FrstChar],0
         jne       FormDs83
         mov       word ptr ds:[FrstChar],ax
FormDs83:

; ------ kontrola, zda byla chyba v systemove oblasti

         cmp       bl,0                     ; byla chyba ?
         je        FormDs85                 ; nebyla chyba
         test      byte ptr ds:[Priznaky],bit0 ; ignoruj° se chyby ?
         jnz       FormDs85                 ; ignoruj° se chyby
         mov       ax,ds:[AktSekt]          ; aktu†ln° sektor
         sub       ax,ds:[BSekt]            ; poá†teán° sektor chyby
         cmp       ax,ds:[FirstDat]         ; je chyba v datovÇ oblasti ?
         jae       FormDs85                 ; nen° systÇmov† oblast

         mov       si,offset HelpTxt7
         call      DispHelp
         call      InpChr
         cmp       bl,13                    ; Enter ?
         jne       FormDs99                 ; nen° - konec
         or        byte ptr ds:[Priznaky],bit0 ; p©°znak ignorov†n° chyb
         call      DispNSek
         mov       bl,1                     ; p©°znak chyby

; ------ vyhodnocen° vòsledku operace

FormDs85:call      Zarad                    ; za©azen° novòch sektorñ

; ------ zvò®en° á°sla stopy

         mov       al,ds:[MaxStran]         ; poáet stran
         xor       byte ptr ds:[AktStran],al ; posun á°sla strany
         jnz       FormDs88                 ; je strana 1
         inc       byte ptr ds:[AktStop]    ; zvò®en° á°sla stopy
         mov       al,ds:[MaxStop]
         cmp       al,ds:[AktStop]
         jb        FormDsk9
FormDs88:jmp       FormDsk5

; ------ hl†®en° o provedenÇ operaci

FormDsk9:call      UlozBad                  ; uloëen° tabulky vadnòch sektorñ

         mov       si,offset HelpTxt6
         call      DispHelp
FormDs9a:mov       ah,1
         int       16h
         jz        FormDs9b
         call      InpChr
         jmp       short FormDs9a

FormDs9b:call      InpChr
         cmp       bl,0dh
         jne       FormDs99
         jmp       FormDsk0                 ; dal®° disketa

FormDs98:call      DispHelp
         call      InpChr

; ------ n†vrat registrñ

FormDs99:call      DeInst1e                 ; n†vrat tabulky disk. parametrñ
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FormDisk ENDP

; *****************************************************************************
;                           UlozBad
;                 uloëen° tabulky vadnòch sektorñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************
;˛
UlozBad  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ kontrola, zda byly vadnÇ bloky

         cmp       word ptr ds:[BadSekt],0  ; byly vadnÇ bloky ?
         je        UlozBad9                 ; nebyly vadnÇ bloky

; ------ pozice indik†toru

         mov       dx,ds:[PozRF]            ; pozice r†meáku
         add       dx,101h
         mov       ds:[AktPozF],dx          ; aktu†ln° pozice

; ------ p©°prava ukazatelñ

         mov       byte ptr ds:[AktStop],0  ; aktu†ln° stopa
         mov       byte ptr ds:[AktStran],0 ; aktu†ln° strana
         mov       cl,2                     ; poá†teán° sektor
         mov       dh,2                     ; á°taá tabulek FAT
         push      ds
         pop       es
         mov       al,ds:[BIdent]           ; identifik†tor
         mov       ds:[TabFat],al
         mov       word ptr ds:[TabFat+1],0ffffh

; ------ z†pis jednÇ tabulky FAT

UlozBad1:mov       dl,byte ptr ds:[BNFat]   ; poáet sektorñ v jednÇ FAT
         mov       bx,offset TabFat
UlozBad2:mov       al,ds:[MaxSekt]          ; poáet sektorñ na stopu
         inc       ax
         sub       al,cl                    ; poáet sektorñ k z†pisu
         cmp       al,dl
         jbe       UlozBad3
         mov       al,dl                    ; omezen° poátu sektorñ
UlozBad3:push      ax
         call      Zapis                    ; z†pis dat na disk
         pop       ax

; ------ dal®° stopa k z†pisu

         add       cl,al                    ; zvò®en° á°sla sektoru
         cmp       cl,ds:[MaxSekt]          ; je jië cel† stopa ?
         jbe       UlozBad4                 ; nen° je®tà cel† stopa
         mov       cl,1
         mov       ch,ds:[MaxStran]         ; maxim†ln° á°slo strany
         xor       byte ptr ds:[AktStran],ch ; zmàna á°sla strany
         jnz       UlozBad4
         inc       byte ptr ds:[AktStop]    ; zvò®en° á°sla stopy

UlozBad4:sub       dl,al                    ; sn°ëen° poátu sektorñ
         jz        UlozBad5                 ; je cel† tabulka FAT
         mov       ah,al
         mov       al,0
         shl       ax,1                     ; dÇlka uloëenòch dat
         add       bx,ax                    ; zvò®en° adresy v pamàti
         jmp       short UlozBad2           ; z†pis dal®° á†sti tabulky

; ------ dal®° tabulka k z†pisu

UlozBad5:dec       dh                       ; á°taá tabulek FAT
         jnz       UlozBad1                 ; z†pis dal®° tabulky FAT

         mov       ax,ds:[FrstChar]
         call      DispFCh                  ; n†vrat pñvodn°ho znaku

; ------ n†vrat registrñ

UlozBad9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UlozBad  ENDP

; *****************************************************************************
;                          SetSer
;                  nastaven° sÇriovÇho á°sla
; -----------------------------------------------------------------------------
;
; *****************************************************************************

SetSer   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ stanoven° systÇmovÇho áasu

         mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu

         mov       ah,0
         mov       al,dl                    ; setina sekundy 7 bitñ
         shr       al,1                     ; setina sekundy 6 bitñ

         mov       dl,0
         shr       dx,1
         shr       dx,1
         or        ax,dx                    ; sekunda 6 bitñ (p©esahuj° 4 bity)

         mov       dh,0
         mov       dl,cl                    ; minuta
         mov       cl,4                     ; poáet rotac°
         shl       dx,cl
         or        ah,dl                    ; minuty 4 bity
         mov       dl,dh                    ; minuty 2 bity

         mov       dh,ch                    ; hodina
         shl       dh,1
         shl       dh,1
         or        dl,dh                    ; hodina 5 bitñ (zbòv† 1 bit)
         mov       dh,0

         mov       ds:[BSerie+2],ax
         mov       ds:[BSerie],dx           ; v DX je 7 bitñ

; ------ stanoven° systÇmovÇho data

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data

         mov       ah,dh                    ; màs°c
         mov       cl,4
         shl       ah,cl                    ; màs°c 4 bity
         mov       dh,0
         mov       cl,7
         shl       dx,cl                    ; den 5 bitñ
         or        ax,dx                    ; màs°c + den
         or        ds:[BSerie],ax           ; + màs°c a den

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetSer   ENDP

; *****************************************************************************
;                            Zarad
;                  za©azen° novòch sektorñ
; -----------------------------------------------------------------------------
; VSTUP: BL=0 p©°znak operace OK
;        DS=datovò segment
; *****************************************************************************

PUBLIC   Zarad

Zarad    PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ za©azen° sektorñ do FAT tabulky

         mov       bh,0
         cmp       bl,0                     ; byla operace OK ?
         je        Zarad1                   ; operace byla OK
         mov       bx,0fff7h                ; oznaáen° vadnÇho sektoru
         mov       ax,ds:[AktSekt]          ; n†sleduj°c° aktu†ln° sektor
         mov       cx,ds:[BSekt]            ; poáet sektorñ
Zarad2:  dec       ax
         call      SetFat                   ; nastaven° poloëky FAT
         loop      Zarad2                   ; dal®° sektor

; ------ stanoven° celkovÇho poátu alokaán°ch blokñ

Zarad1:  mov       ax,ds:[AktSekt]          ; n†sleduj°c° aktu†ln° sektor
         sub       ax,ds:[FirstDat]         ; jsou datovÇ sektory ?
         jbe       Zarad9                   ; nejsou datovÇ sektory
         mov       bl,ds:[BBlok]            ; poáet sektorñ na blok
         xor       dx,dx
         mov       bh,0                     ; BX=poáet sektorñ na blok
         div       bx                       ; poáet alokaán°ch blokñ
         mov       cx,ax                    ; poáet alokaán°ch blokñ
         jcxz      Zarad9                   ; nen° ë†dnò alokaán° blok

; ------ spoáten° poátu alokaán°ch blokñ

         mov       si,offset TabFat+3       ; zaá†tek tabulky FAT
;         mov       word ptr ds:[CelkSekt],0 ; celkovò poáet sektorñ
         mov       word ptr ds:[VolSekt],0  ; poáet volnòch sektorñ
         mov       word ptr ds:[BadSekt],0  ; poáet vadnòch sektorñ

; ------ sudÇ á°slo bloku

Zarad3:  test      word ptr ds:[si],0fffh   ; je volnò alokaán° blok ?
         jz        Zarad4                   ; alokaán° blok je volnò
         add       ds:[BadSekt],bx          ; á°taá vadnòch sektorñ
         jmp       short Zarad5
Zarad4:  add       ds:[VolSekt],bx          ; á°taá volnòch sektorñ
Zarad5:  ;add       ds:[CelkSekt],bx         ; á°taá sektorñ celkem
         inc       si
         dec       cx                       ; á°taá blokñ
         jz        Zarad8                   ; jsou jië v®echny bloky

; ------ lichÇ á°slo bloku

         test      word ptr ds:[si],0fff0h  ; je volnò alokaán° blok ?
         jz        Zarad6                   ; alokaán° blok je volnò
         add       ds:[BadSekt],bx          ; á°taá vadnòch sektorñ
         jmp       short Zarad7
Zarad6:  add       ds:[VolSekt],bx          ; á°taá volnòch sektorñ
Zarad7:  ;add       ds:[CelkSekt],bx         ; á°taá sektorñ celkem
         inc       si
         inc       si
         loop      Zarad3                   ; dal®° blok

; ------ zobrazen° novÇho poátu sektorñ

Zarad8:  call      DispNSek                 ; zobrazen° poátu sektorñ

; ------ n†vrat registrñ

Zarad9:  pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Zarad    ENDP

; *****************************************************************************
;                               DispNSek
;                       zobrazen° poátu sektorñ
; -----------------------------------------------------------------------------
; *****************************************************************************


PUBLIC   DispNSek

DispNSek PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      di

; ------ dek¢dov†n° £daje celkovÇ kapacity

         mov       ax,ds:[CelkSekt]
         mov       di,offset HelpTx51-4
         call      DekNSekt                 ; dek¢dov†n° celkovÇ kapacity
         mov       di,offset HelpTx61-4
         call      DekNSekt

; ------ dek¢dov†n° £daje volnÇ kapacity

         mov       ax,ds:[VolSekt]
         mov       di,offset HelpTx52-4
         call      DekNSekt                 ; dek¢dov†n° volnÇ kapacity
         mov       di,offset HelpTx62-4
         call      DekNSekt

; ------ dek¢dov†n° £daje vadnÇ kapacity

         mov       ax,ds:[BadSekt]
         mov       di,offset HelpTx53-4
         call      DekNSekt                 ; dek¢dov†n° vadnÇ kapacity
         mov       di,offset HelpTx63-4
         call      DekNSekt

; ------ zobrazen° textu

         mov       si,offset HelpTxt5
         call      DispHelp

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       ax
         ret

DispNSek ENDP

; *****************************************************************************
;                               DekNSekt
;                         Dek¢dov†n° kapacity
; -----------------------------------------------------------------------------
; VSTUP: AX=poáet sektorñ
;        ES:DI=ukl†dac° adresa (pozice za á°slem)
; *****************************************************************************

PUBLIC   DekNSekt

DekNSekt PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

         mov       dx,ax                    ; poáet sektorñ

; ------ inicializaán° vymaz†n° á°sla

         push      di
         std
         dec       di
         dec       di
         mov       ax,"  "
         mov       cx,5
         rep       stosw
         pop       di

; ------ dek¢dov†n° á°sla

         mov       al,0
         mov       ah,dl
         mov       dl,dh
         mov       dh,0
         shl       ax,1
         rcl       dx,1                     ; poáet sektorñ * 512
         mov       bl,"."                   ; znak oddàlovaáe ©†dñ
         call      DekNumD                  ; dek¢dov†n° á°sla

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNSekt ENDP

; *****************************************************************************
;                           GetSekt
;            vygenerov†n° sektoru (mus° bòt p©ednastaven na 0 !)
; -----------------------------------------------------------------------------
; VSTUP: AX=absolutn° á°slo sektoru (0...)
;        ES:DI=adresa k uloëen° sektoru (512 bajtñ)
;        DS=datovò segment
; VùSTUP:CY=sektor nen° t©eba zapisovat (obsahuje konstant° znaky 0)
; *****************************************************************************

PUBLIC   GetSekt

GetSekt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di

; ------ generov†n° BOOT sektoru

         cld
         or        ax,ax                    ; je BOOT sektor ?
         jnz       GetSekt3
         mov       si,offset Boot           ; BOOT sektor
         mov       cx,offset(BootEnd-Boot)  ; dÇlka z†hlav° BOOT sektoru
         rep       movsb                    ; p©esun BOOT sektoru
         add       di,510 - offset(BootEnd-Boot) ; zbytek - vypln° se 0
         mov       ax,0aa55h                ; identifik†tor BOOT
         stosw                              ; uloëen° identifik†toru
         jmp       short GetSekt8

; ------ kontrola, zda je to prvn° sektor FAT

GetSekt3:dec       ax                       ; je to prvn° sektor FAT ?
         jz        GetSekt4                 ; je to zaá†tek prvn° tabulky FAT
         sub       ax,ds:[BNFat]            ; odeáten° sektorñ na jednu FAT
         stc
         jnz       GetSekt9                 ; nen° 1. sektor FAT

; ------ generov†n° prvn°ho sektoru FAT

GetSekt4:mov       al,ds:[BIdent]           ; popisovaá mÇdia
         stosb
         dec       word ptr es:[di]         ; dal®° slovo = 0ffffh

; ------ n†vrat registrñ

GetSekt8:clc
GetSekt9:pop       di
         pop       si
         pop       cx
         pop       ax
         ret

GetSekt  ENDP

; *****************************************************************************
;                              SetFat
;                    nastaven° poloëky v tabulce FAT
; -----------------------------------------------------------------------------
; VSTUP: AX=absolutn° á°slo sektoru
;        BX=hodnota pro nastaven°
;        DS=datovò segment
; *****************************************************************************

SetFat   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ kontrola, zda je platnÇ á°slo sektoru

         cmp       ax,ds:[BNMax]            ; kontrola max. á°sla sektoru
         jae       SetFat9                  ; velkÇ á°slo sektoru
         sub       ax,ds:[FirstDat]         ; je to datovò sektor ?
         jb        SetFat9                  ; malÇ á°slo sektoru
         inc       ax
         inc       ax                       ; zaá°n† se od bloku 2

; ------ vòpoáet á°sla alokaán°ho bloku

         mov       ch,0
         mov       cl,ds:[BBlok]            ; velikost bloku
         or        cx,cx
         jnz       SetFat2
         inc       cx
SetFat2: xor       dx,dx
         div       cx                       ; vòpoáet á°sla alokaán°ho bloku

; ------ stanoven° adresy poloëky ve FAT tabulce

         mov       cx,ax                    ; £schova á°sla bloku
         shr       ax,1                     ; á°slo bloku / 2
         add       ax,cx                    ; á°slo bloku * 1.5
         mov       si,ax                    ; offset v tabulce FAT
         add       si,offset TabFat         ; adresa v tabulce FAT

; ------ nastaven° hodnoty FAT - sud† poloëka

         and       bx,0fffh                 ; maskov†n° hodnoty k nastaven°
         mov       ax,ds:[si]
         test      cl,1                     ; je sud† poloëka ?
         jnz       SetFat3                  ; je lich† poloëka
         and       ax,0f000h                ; nulov†n° starÇ hodnoty
         jmp       short SetFat4

; ------ nastaven° hodnoty FAT - lich† poloëka

SetFat3: and       ax,0fh                   ; nulov†n° starÇ hodnoty
         mov       cl,4                     ; poáet rotac°
         shl       bx,cl                    ; rotace hodnoty na pozici
SetFat4: or        ax,bx                    ; slouáen° s novou hodnotou
         mov       ds:[si],ax               ; nastaven° novÇ hodnoty

; ------ n†vrat registrñ

SetFat9: pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetFat   ENDP

;; *****************************************************************************
;;                              GetFat
;;                 poskytnut° poloëky v tabulce FAT
;; -----------------------------------------------------------------------------
;; VSTUP: AX=absolutn° á°slo sektoru
;;        DS=datovò segment
;; VùSTUP:BX=hodnota poloëky
;;        ZY=poloëka = 0 (pouze je-li NC)
;;        CY=neplatnÇ á°slo sektoru
;; *****************************************************************************
;
;GetFat   PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;
;; ------ kontrola, zda je platnÇ á°slo sektoru
;
;         mov       bx,0ff7h                 ; oznaáen° vadnÇho bloku
;         cmp       ax,ds:[BNMax]            ; kontrola max. á°sla sektoru
;         cmc
;         jb        GetFat9                  ; velkÇ á°slo sektoru
;         sub       ax,ds:[FirstDat]         ; je to datovò sektor ?
;         jb        GetFat9                  ; malÇ á°slo sektoru
;         inc       ax
;         inc       ax                       ; zaá°n† se od bloku 2
;
;; ------ vòpoáet á°sla alokaán°ho bloku
;
;         mov       ch,0
;         mov       cl,ds:[BBlok]            ; velikost bloku
;         or        cx,cx
;         jnz       GetFat2
;         inc       cx
;GetFat2: xor       dx,dx
;         div       cx                       ; vòpoáet á°sla alokaán°ho bloku
;
;; ------ stanoven° adresy poloëky ve FAT tabulce
;
;         mov       cx,ax                    ; £schova á°sla bloku
;         shr       ax,1                     ; á°slo bloku / 2
;         add       ax,cx                    ; á°slo bloku * 1.5
;         mov       si,ax                    ; offset v tabulce FAT
;         add       si,offset TabFat         ; adresa v tabulce FAT
;
;; ------ poskytnut° hodnoty FAT
;
;         mov       bx,ds:[si]               ; hodnota z tabulky
;         test      cl,1                     ; je sud† poloëka ?
;         jz        GetFat3                  ; je sud† poloëka
;         mov       cl,4                     ; poáet rotac°
;         shr       bx,cl                    ; rotace hodnoty na pozici
;GetFat3: and       bx,0fffh                 ; nulov†n° hodnoty
;         or        bx,bx
;
;; ------ n†vrat registrñ
;
;GetFat9: pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;GetFat   ENDP

; *****************************************************************************
;                             DispFCh
;                 zobrazen° znaku na pozici form†tov†n°
; -----------------------------------------------------------------------------
; VSTUP: AX=znak
;        DS=datovò segment
; *****************************************************************************

PUBLIC   DispFCh

DispFCh  PROC      NEAR

         push      dx
         mov       dx,ds:[AktPozF]
         call      Disp1Chr
         pop       dx
         ret

DispFCh  ENDP

; *****************************************************************************
;                                DispDisk
;                          zobrazen° volby diskñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

PUBLIC   DispDisk

DispDisk PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ vòpoáet poá†teán° pozice

         mov       al,10                    ; poáet pozic na disk
         mul       byte ptr ds:[NumDisk]    ; celkov† ®°©ka volby
         mov       dl,81                    ; ®°©ka okna + 1
         sub       dl,al                    ; zbytek na okraje
         shr       dl,1                     ; poá†teán° pozice
         mov       dh,ds:[Radku]
         shr       dh,1
         sub       dh,2                     ; ©†dek k zobrazen°

; ------ zobrazen° voleb diskñ

         mov       ch,0                     ; ukazatel á°sla disku
DispDsk1:mov       ah,ds:[ColVolb]          ; bàën† barva volby
         cmp       ch,ds:[AktDisk]          ; je to aktivn° disk ?
         jne       DispDsk2                 ; nen° to aktivn° disk
         mov       ah,ds:[ColKurz]          ; jinak barva kurzoru
DispDsk2:mov       al," "
         mov       cl,4
         call      DispChr                  ; levò okraj
         mov       al,ch
         add       al,"A"                   ; korekce na znak disku
         call      Disp1Chr                 ; zobrazen° oznaáen° disku
         mov       al," "
         call      DispChr                  ; zobrazen° pravÇho okraje

; ------ p©°prava pro dal®° disk

         inc       dl
         inc       ch
         cmp       ch,ds:[NumDisk]
         jb        DispDsk1                 ; dal®° disk

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

DispDisk ENDP

; *****************************************************************************
;                            DispRF
;                  zobrazen° r†meáku form†tov†n°
; -----------------------------------------------------------------------------
; *****************************************************************************

PUBLIC   DispRf

DispRF   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©°prava registrñ

         mov       dx,ds:[PozRF]
         mov       bl,0                     ; poá†teán° á°slo stopy
DispRF1: mov       bh,0                     ; á°slo strany

; ------ zobrazen° horn°ho okraje

DispRF2: mov       ah,ds:[ColRF]            ; barva r†meáku form†tov†n°
         push      dx
         mov       al,218                   ; levò horn° roh
         call      Disp1Chr                 ; zobrazen° levÇho horn°ho rohu
         mov       al,194
         mov       cl,40
         call      DispChr                  ; zobrazen° horn° linky
         mov       al,191                   ; pravò horn° roh
         call      Disp1Chr                 ; zobrazen° pravÇho horn°ho rohu
         pop       dx
         inc       dh

; ------ zobrazen° stran

DispRF3: push      dx
         cmp       byte ptr ds:[MaxStran],0 ; je pouze jedna strana ?
         je        DispRF32                 ; je pouze jedna strana
         sub       dl,2
         mov       al,bh                    ; strana
         add       al,"0"
         call      Disp1Chr
         inc       dx
DispRF32:mov       al,179
         call      Disp1Chr                 ; levò okraj

         cmp       word ptr ds:[AktSekt],0  ; prob°h† jië operace ?
         je        DispRF33                 ; prob°h† jië operace
         add       dl,cl                    ; zvò®en° pozice
         jmp       short DispRF34
DispRF33:mov       ah,ds:[ColRFNul]
         mov       al,176
         call      DispChr                  ; zobrazen° vnit©n°ho ©†dku
DispRF34:mov       ah,ds:[ColRF]            ; barva r†meáku
         mov       al,179
         call      Disp1Chr                 ; zobrazen° pravÇho okraje
         pop       dx
         inc       dh
         inc       bh                       ; zvò®en° á°sla strany
         cmp       bh,ds:[MaxStran]         ; jsou jië v®echny strany ?
         jna       DispRF3                  ; dal®° strana

; ------ zobrazen° spodn°ho okraje

         push      dx
         mov       al,192
         call      Disp1Chr                 ; zobrazen° levÇho spodn°ho rohu
         mov       cx,804h                  ; poáet skupin
DispRF4: mov       al,197
         call      Disp1Chr                 ; zobrazen° mà©°tka
         mov       al,193
         call      DispChr
         dec       ch
         jnz       DispRF4                  ; dal®° skupina
         mov       al,217
         call      Disp1Chr                 ; zobrazen° pravÇho doln°ho rohu
         pop       dx
         inc       dh

; ------ zobrazen° á°sel stop

         push      dx
         inc       dl
         mov       cx,8                     ; poáet skupin
DispRF5: mov       al,bl                    ; á°slo stopy
         push      dx
         call      DispNum                  ; zobrazen° á°sla stopy
         pop       dx
         add       dl,5
         add       bl,5
         loop      DispRF5
         pop       dx

; ------ p©°prava k zobrazen° dal®°ho r†meáku

         add       dh,2
         cmp       bl,ds:[MaxStop]          ; jsou jië v®echny stopy ?
         jae       DispRF9
         jmp       DispRF1                  ; dal®° stopy

; ------ n†vrat registrñ

DispRF9: pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispRF   ENDP

; *****************************************************************************
;                            DispForm
;                  zobrazen° volby form†tu disket
; -----------------------------------------------------------------------------
; *****************************************************************************

PUBLIC   DispForm

DispForm PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      es

; ------ stanoven° poá†teán° pozice

         mov       dl,(80-(offset(FormVol1-FormVol0)+4))/2
         mov       dh,ds:[Radku]
         sub       dh,10
         shr       dh,1

; ------ zobrazen° voleb

         mov       si,offset FormVol0
         push      ds
         pop       es
         mov       ch,1                     ; ukazatel á°sla voleb
         mov       cl,offset(FormVol1-FormVol0)
         mov       al," "
DispFrm1:mov       ah,ds:[ColVolb]
         cmp       ch,ds:[AktForm]
         jne       DispFrm2                 ; nen° to aktivn° volba
         mov       ah,ds:[ColKurz]
DispFrm2:push      dx
         call      Disp1Chr
         call      Disp1Chr
         call      DispTxt
         call      Disp1Chr
         call      Disp1Chr
         pop       dx
         add       si,offset(FormVol1-FormVol0)
         inc       dh
         inc       ch
         cmp       ch,7
         jbe       DispFrm1

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispForm ENDP

; *****************************************************************************
;                            Podklad
;                       Zobrazen° podkladu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

PUBLIC   Podklad

Podklad  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      es

         push      ds
         pop       es

; ------ vymaz†n° podkladu

         mov       ch,ds:[Radku]            ; poáet ©†dkñ
         sub       ch,4
         mov       cl,78                    ; poáet pozic na ©†dek
         mov       al," "                   ; znak pro vymaz†n°
         mov       ah,ds:[ColRam]           ; barva podkladu
         mov       dh,3                     ; poá†teán° ©†dek
Podkl1:  mov       dl,1                     ; poá†teán° pozice
         call      DispChr                  ; vymaz†n° ©†dku
         inc       dh
         dec       ch
         jnz       Podkl1                   ; dal®° ©†dek

; ------ zobrazen° horn°ho r†mu

         mov       al,201                   ; levò roh
         mov       bl,205                   ; st©edn° linka
         mov       bh,203                   ; vnit©n° spojka
         mov       ch,187                   ; pravò roh
         mov       dh,0                     ; ©†dek
         call      Podkl0                   ; prvn° ©†dek

         mov       al,186                   ; levò roh
         mov       bl," "                   ; st©edn° linka
         mov       bh,186                   ; vnit©n° spojka
         mov       ch,186                   ; pravò roh
         mov       dh,1                     ; ©†dek
         call      Podkl0                   ; druhò ©†dek

         mov       al,204                   ; levò roh
         mov       bl,205                   ; st©edn° linka
         mov       bh,202                   ; vnit©n° spojka
         mov       ch,185                   ; pravò roh
         mov       dh,2                     ; ©†dek
         call      Podkl0                   ; t©et° ©†dek

; ------ zobrazen° textñ

         mov       ah,ds:[ColNadp]
         mov       dh,1

         mov       dl,5
         mov       si,offset Nadpis1
         mov       cl,offset(Nadpis2-Nadpis1)
         call      DispTxt

         mov       dl,31
         mov       si,offset Nadpis2
         mov       cl,offset(Nadpis3-Nadpis2)
         call      DispTxt

         mov       dl,58
         mov       si,offset Nadpis3
         mov       cl,offset(Nadpis4-Nadpis3)
         call      DispTxt

; ------ zobrazen° boán°ch okrajñ

         mov       dh,3
         mov       ch,0
         mov       cl,ds:[Radku]
         sub       cl,4
         mov       ah,ds:[ColRam]
         mov       al,186
Podkl2:  mov       dl,0
         call      Disp1Chr
         mov       dl,79
         call      Disp1Chr
         inc       dh
         loop      Podkl2

; ------ zobrazen° spodn°ho okraje

         mov       dl,0
         mov       al,200
         call      Disp1Chr
         mov       cl,78
         mov       al,205
         call      DispChr
         mov       al,188
         call      Disp1Chr

; ------ zobrazen° vnit©n° linky

         mov       dh,ds:[Radku]
         sub       dh,6
         mov       dl,0
         mov       al,204
         call      Disp1Chr
         mov       cl,78
         mov       al,205
         call      DispChr
         mov       al,185
         call      Disp1Chr

; ------ n†vrat registrñ

         pop       es
         pop       dx
         pop       cx
         pop       ax
         ret

Podklad  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° linky r†mu
; -----------------------------------------------------------------------------
; VSTUP: AH=barva
;        AL=levò roh
;        BL=st©edn° linka
;        BH=vnit©n° spojka
;        CH=pravò roh
;        DH=©†dek
; -----------------------------------------------------------------------------

Podkl0   PROC      NEAR

         mov       dl,0
         call      Disp1Chr                 ; levò roh
         mov       al,bl
         mov       cl,Ram1
         call      DispChr                  ; prvn° linka
         mov       al,bh
         call      Disp1Chr                 ; prvn° p©°áka
         mov       al,bl
         mov       cl,Ram2
         call      DispChr                  ; druh† linka
         mov       al,bh
         call      Disp1Chr                 ; druh† p©°áka
         mov       al,bl
         mov       cl,Ram3
         call      DispChr                  ; t©et° linka
         mov       al,ch
         call      Disp1Chr                 ; pravò roh
         ret

Podkl0   ENDP


; *****************************************************************************
;                             DispHelp
;                        zobrazen° n†povàdy (4 ©†dky)
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa n†povàdy
;        DS=datovò segment
; *****************************************************************************

PUBLIC   DispHelp

DispHelp PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

         push      ds
         pop       es

; ------ p©°prava registrñ

         mov       dh,ds:[Radku]
         sub       dh,5                     ; poá†teán° ©†dek
         mov       bh,4                     ; poáet ©†dkñ k zobrazen°
         mov       ah,ds:[ColHlp]           ; barva textu
         mov       ch,0

; ------ vòpoáet okrajñ textu

DispHlp1:mov       cl,78                    ; vnit©n° ®°©ka ©†dku
         sub       cl,ds:[si]               ; zbytek na okraje
         shr       cl,1                     ; polovina na okraje
         mov       bl,cl                    ; £schova okraje
         adc       bl,0                     ; lich† pozice

; ------ zobrazen° levÇho okraje

         mov       al," "
         mov       dl,1
         call      DispChr                  ; zobrazen° levÇho okraje

; ------ zobrazen° textu

         mov       cl,ds:[si]               ; dÇlka textu
         inc       si                       ; zaá†tek textu
         call      DispTxt                  ; zobrazen° textu ©†dku

; ------ zobrazen° pravÇho okraje

         mov       cl,bl                    ; pravò okraj
         mov       al," "
         call      DispChr                  ; zobrazen° pravÇho okraje

; ------ p©°prava pro dal®° ©†dek

         mov       cl,ds:[si-1]
         add       si,cx
         inc       dh
         dec       bh
         jnz       DispHlp1

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispHelp ENDP

;; *****************************************************************************
;;                Dek¢dov†n° á°sla od levÇho okraje
;; -----------------------------------------------------------------------------
;; VSTUP: DX:AX=á°slo k dek¢dov†n°
;;        ES:DI=ukl†dac° adresa (poá†tek k uloëen° á°sla)
;;        BH=atribut barev (0=atribut barev se neukl†d†)
;;        BL=znak oddàlovaáe ©†dñ (0=oddàlovaá ©†dñ se neukl†d†)
;; VùSTUP:ES:DI=n†sleduj°c° adresa za á°slem
;; *****************************************************************************
;
;DekNum   PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      bp
;
;; ------ p©°prava registrñ
;
;         mov       bp,10                    ; á°seln† soustava
;         xor       cx,cx                    ; á°taá znakñ v z†sobn°ku
;
;; ------ vòpoáet jednÇ á°slice
;
;DekNum1: mov       si,ax                    ; £schova nië®°ho slova á°sla
;         mov       ax,dx                    ; vy®®° slovo á°sla
;         xor       dx,dx                    ; DX <- 0
;         div       bp                       ; vydàlen° vy®®°ho slova á°sla
;         xchg      ax,si                    ; n†vrat nië®°ho slova
;         div       bp                       ; vydàlen° nië®°ho slova á°sla
;
;; ------ uloëen° oddàlovaáe ©†dñ
;
;         or        bl,bl                    ; ukl†d† se oddàlovaá ©†dñ ?
;         jz        DekNum3                  ; oddàlovaá ©†dñ se neukl†d†
;         cmp       cx,3                     ; jsou tis°ce ?
;         jne       DekNum2                  ; nejsou tis°ce
;         push      bx                       ; uloëen° oddàlovaáe tis°cñ
;         inc       cx                       ; zvò®en° á°taáe znakñ
;DekNum2: cmp       cx,7                     ; jsou miliony ?
;         jne       DekNum3                  ; nen° ©†d milionñ
;         push      bx                       ; uloëen° oddàlovaáe milionñ
;         inc       cx                       ; zvò®en° á°taáe znakñ
;
;; ------ uloëen° novÇ á°slice
;
;DekNum3: mov       dh,bh                    ; barva textu
;         add       dl,"0"                   ; korekce na znak ASCII
;         push      dx                       ; uloëen° á°slice
;         inc       cx                       ; zvò®en° á°taáe znakñ
;
;; ------ test, zda je je®tà nàjakÇ á°slo
;
;         mov       dx,si                    ; n†vrat vy®®°ho slova á°sla
;         or        ax,ax                    ; je á°slo jië = 0 ?
;         jnz       DekNum1                  ; á°slo je®tà nen° = 0 - pokraáov†n°
;         or        dx,dx                    ; je á°slo jië = 0 ?
;         jnz       DekNum1                  ; á°slo je®tà nen° = 0 - pokraáov†n°
;
;; ------ uloëen° á°sla do bufferu
;
;         cld
;         or        bh,bh                    ; ukl†d† se atribut barvy ?
;         jnz       DekNum6                  ; atribut barvy se ukl†d†
;
;DekNum5: pop       ax                       ; n†vrat znaku á°sla
;         stosb                              ; uloëen° znaku
;         loop      DekNum5                  ; dal®° znak á°sla
;         jmp       short DekNum8
;
;DekNum6: pop       ax                       ; n†vrat znaku á°sla
;         stosw                              ; uloëen° znaku s atributem
;         loop      DekNum6                  ; dal®° znak á°sla
;
;; ------ n†vrat registrñ
;
;DekNum8: pop       bp
;         pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;DekNum   ENDP
;


; *****************************************************************************
;                 Dek¢dov†n° á°sla od pravÇho okraje
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (konec za á°slem)
;        BL=znak oddàlovaáe ©†dñ (0=znak se neukl†d†)
; *****************************************************************************

DekNumD  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       bp,10                    ; á°seln† soustava
         xor       cx,cx                    ; á°taá platnòch á°slic

; ------ vòpoáet jednÇ á°slice

DekNumD1:mov       si,ax                    ; £schova nië®°ho slova á°sla
         mov       ax,dx                    ; vy®®° slovo á°sla
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydàlen° vy®®°ho slova á°sla
         xchg      ax,si                    ; n†vrat nië®°ho slova
         div       bp                       ; vydàlen° nië®°ho slova á°sla

; ------ uloëen° oddàlovaáe ©†dñ

         or        bl,bl                    ; ukl†d† se oddàlovaá ©†dñ ?
         jz        DekNumD3                 ; oddàlovaá ©†dñ se neukl†d†
         cmp       cx,3                     ; jsou tis°ce ?
         jne       DekNumD2                 ; nejsou tis°ce
         dec       di
         mov       es:[di],bl               ; uloëen° oddàlovaáe tis°cñ
DekNumD2:cmp       cx,6                     ; jsou miliony ?
         jne       DekNumD3                 ; nen° ©†d milionñ
         dec       di                       ; posun adresy
         mov       es:[di],bl               ; uloëen° oddàlovaáe milionñ

; ------ uloëen° novÇ á°slice

DekNumD3:dec       di
         add       dl,"0"                   ; korekce na znak ASCII
         mov       es:[di],dl               ; uloëen° á°slice
         inc       cx                       ; zvò®en° á°taáe á°slic

; ------ test, zda je je®tà nàjakÇ á°slo

         mov       dx,si                    ; n†vrat vy®®°ho slova á°sla
         or        ax,ax                    ; je á°slo jië = 0 ?
         jnz       DekNumD1                 ; á°slo je®tà nen° = 0 - pokraáov†n°
         or        dx,dx                    ; je á°slo jië = 0 ?
         jnz       DekNumD1                 ; á°slo je®tà nen° = 0 - pokraáov†n°

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNumD   ENDP

; *****************************************************************************
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol† instrukc° CALL JumpBX, za kterou n†sleduje tabulka
; skokñ. Procedura zmàn° svou n†vratovou adresu na adresu podle nalezenÇ
; poloëky v tabulce (nebo podle poloëky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z†sobn°ku slovo (n†vratov† adresa NEAR) = zaá†tek tabulky skokñ
;             stuktura tabulky: 1 slovo testovan† hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©°znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen° k¢du
; *****************************************************************************

PUBLIC   JumpBX

JumpBX   PROC      NEAR

; ------ £schova registrñ

                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen° hodnoty v tabulce

         push      cs
         pop       ds
         mov       si,ss:[bp+6]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan† hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal®° poloëky
         jmp       short JumpBX1            ; test dal®° poloëky

; ------ nastaven° n†vratovÇ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov† n†vratov† adresa

; ------ n†vrat registrñ

         pop       ds
         pop       bp
         pop       si
         ret

JumpBX   ENDP

;; *****************************************************************************
;;                               DekADTS
;;                    dek¢dov†n° dvojá°sl° s mezerou
;; -----------------------------------------------------------------------------
;; VSTUP: AL=á°slo
;;        AH=barva textu
;;        ES:DI=ukl†dac° adresa
;; *****************************************************************************
;
;DekADTS  PROC      NEAR
;
;         push      ax
;         mov       cl,10
;         xor       ah,ah
;         div       cl                       ; vòpoáet á°slic
;         mov       cx,ax                    ; £schova á°sla
;         pop       ax
;         mov       al,cl                    ; prvn° á°slice
;         add       al,"0"                   ; korekce na znak ASCII
;         cmp       al,"0"                   ; je prvn° znak 0 ?
;         jne       DekADTS1                 ; nen° 0
;         mov       al," "                   ; n†hrada mezerou
;DekADTS1:stosw                              ; uloëen° prvn° á°slice
;         mov       al,ch                    ; druhÇ á°slo
;         add       al,"0"                   ; korekce na á°slici
;         stosw                              ; uloëen° druhÇ á°slice
;         ret
;
;DekADTS  ENDP
;
;; *****************************************************************************
;;                               DekADT0
;;                    dek¢dov†n° dvojá°sl° s nulou
;; -----------------------------------------------------------------------------
;; VSTUP: AL=á°slo
;;        AH=barva textu
;;        ES:DI=ukl†dac° adresa
;; *****************************************************************************
;
;DekADT0  PROC      NEAR
;
;         push      ax
;         mov       cl,10
;         xor       ah,ah
;         div       cl                       ; vòpoáet á°slic
;         mov       cx,ax                    ; £schova á°sla
;         pop       ax
;         mov       al,cl                    ; prvn° á°slice
;         add       al,"0"                   ; korekce na znak ASCII
;         stosw                              ; uloëen° prvn° á°slice
;         mov       al,ch                    ; druhÇ á°slo
;         add       al,"0"                   ; korekce na á°slici
;         stosw                              ; uloëen° druhÇ á°slice
;         ret
;
;DekADT0  ENDP

; *****************************************************************************
;                                 Cekej
;                      áek†n° po zadanou dobu
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet impulsñ 1/18 s
; *****************************************************************************

PUBLIC   Cekej

Cekej    PROC      NEAR

         push      ax
         push      cx
         push      ds

         xor       ax,ax
         mov       ds,ax
         jcxz      Cekej3
         sti

Cekej1:  mov       ax,ds:[46ch]
Cekej2:  cmp       ax,ds:[46ch]
         je        Cekej2
         loop      Cekej1

Cekej3:  pop       ds
         pop       cx
         pop       ax
         ret

Cekej    ENDP

;; *****************************************************************************
;;                      zobrazen° textu n†povàdy
;; *****************************************************************************
;
;DispMHlp PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      es
;
;         mov       si,ds:[MnuHlp]
;
;; ------ zobrazen° £vodn° mezery
;
;         mov       ah,ds:[HelpColH]         ; barva textu n†povàdy
;         mov       al," "                   ; znak £vodn° mezery
;         mov       dl,0                     ; poá†teán° pozice textu
;         mov       dh,ds:[MaxRow]           ; posledn° ©†dek displeje
;         call      Disp1Chr                 ; zobrazen° £vodn° mezery
;
;; ------ zobrazen° textu n†povàdy
;
;         mov       cx,ds:[si]               ; offset dal®°ho textu
;         dec       cx
;         dec       cx                       ; dÇlka textu n†povàdy
;         cmp       cx,79
;         jbe       DispHTx2
;         mov       cx,79
;DispHTx2:inc       si
;         inc       si                       ; zaá†tek textu n†povàdy
;         push      ds
;         pop       es
;         call      DispTxt                  ; zobrazen° textu n†povàdy
;
;; ------ zobrazen° z†vàreánÇ mezery
;
;         mov       cx,80
;         sub       cl,dl
;         call      DispChr                  ; zobrazen° zbytku ©†dku
;
;; ------ n†vrat registrñ
;
;         pop       es
;         pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;DispMHlp ENDP
;


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Obsluha disku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; *****************************************************************************
;                            Format
;                   zform†tov†n° aktu†ln° stopy
; -----------------------------------------------------------------------------
; VùSTUP: CY=chyba
;         AH=k¢d chyby
; *****************************************************************************

PUBLIC   Format

Format   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ zobrazen° indik†toru

         mov       al,"F"
         mov       ah,ds:[ColForm]          ; barva
         call      DispFCh                  ; zobrazen° indik†toru

; ------ vymaz†n° datovÇho bufferu stopy

         test      byte ptr ds:[Priznaky],bit1 ; jsou jië data nemànn† ?
         jnz       Format0                  ; data jsou jië nemànn†
         mov       di,offset DataBuf        ; datovò buffer stopy
         push      ds
         pop       es
         mov       cx,18*512/2
         mov       al,ds:[FillCh]           ; plnic° znak pro form†tov†n°
         mov       ah,al
         cld
         rep       stosw                    ; vymaz†n° bufferu

; ------ generov†n° definián° tabulky stopy

         clc
Format0: xor       di,di
         mov       es,ds:[Int13Buf]         ; buffer pro INT 13h
         mov       dl,ds:[AktStop]          ; form†tovan† stopa
         mov       dh,ds:[AktStran]         ; aktu†ln° strana
         mov       ax,201h                  ; velikost a á°slo sektoru
         mov       ch,0
         mov       cl,ds:[Int1e+4]          ; poáet sektorñ
Format1: mov       es:[di],dx               ; á°slo v†lce a hlavy
         inc       di
         inc       di
         stosw                              ; á°slo a velikost sektoru
         inc       ax                       ; zvò®en° á°sla stopy
         loop      Format1

; ------ form†tov†n° stopy

Format2: mov       ah,5
         mov       ch,dl                    ; stopa
         mov       dh,ds:[AktStran]         ; aktu†ln° strana
         mov       al,ds:[MaxSekt]          ; poáet sektorñ
         xor       bx,bx                    ; adresa tabulky
         call      Int13                    ; form†tov†n° stopy

; ------ n†vrat registrñ

Format9: pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

Format   ENDP

; -----------------------------------------------------------------------------
;        z†pis dat na disk (AL=poáet sektorñ, CL=poá†teán° sektor, ES:BX=adresa)
; -----------------------------------------------------------------------------
; VùSTUP: CY=chyba
;         AH=k¢d chyby
; -----------------------------------------------------------------------------

PUBLIC   Zapis

Zapis    PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ zobrazen° indik†toru

         push      ax
         mov       al,"W"
         mov       ah,ds:[ColWrite]         ; barva
         call      DispFCh                  ; zobrazen° indik†toru
         pop       ax

; ------ kopie dat do bufferu

         push      ds
         push      cx

         mov       ch,al                    ; poáet sektorñ
         mov       cl,0                     ; CX=poáet slov
         mov       si,bx
         xor       di,di
         cld
         mov       ds,ds:[Int13Buf]         ; segment bufferu
         push      ds
         push      es
         pop       ds
         pop       es
         rep       movsw                    ; p©enos dat do bufferu

         pop       cx
         pop       ds

; ------ z†pis dat na disk

         xor       bx,bx
         mov       ah,3
         mov       ch,ds:[AktStop]          ; á°slo v†lce
         mov       dh,ds:[AktStran]         ; á°slo strany
         call      Int13                    ; z†pis dat na disk

; ------ n†vrat registrñ

Zapis9:  pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Zapis    ENDP

; -----------------------------------------------------------------------------
;        verifikace dat diskety
; -----------------------------------------------------------------------------
; VùSTUP: CY=chyba
;         AH=k¢d chyby
; -----------------------------------------------------------------------------

PUBLIC   Verif

Verif    PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         mov       al,"V"
         mov       ah,ds:[ColVerif]         ; barva
         call      DispFCh                  ; zobrazen° indik†toru

; ------ naáten° jednÇ stopy z disku

Verif1:  mov       es,ds:[Int13Buf]         ; buffer pro diskovÇ operace
         xor       bx,bx                    ; offset adresy
         mov       al,ds:[MaxSekt]          ; poáet sektorñ
         mov       ah,2
         mov       ch,ds:[AktStop]          ; á°slo v†lce
         mov       cl,1                     ; poá†teán° á°slo sektoru
         mov       dh,ds:[AktStran]         ; strana
         call      Int13                    ; áten° dat z disku
         jc        Verif8                   ; chyba

; ------ kontrola naátenòch dat

         push      ds
         xor       di,di
         cld
         mov       si,offset DataBuf        ; datovò buffer
         mov       ch,ds:[MaxSekt]          ; poáet sektorñ
         mov       cl,0
         repe      cmpsw                    ; porovn†n° dat
         pop       ds
         je        Verif9
         mov       ah,10h
Verif8:
         stc

; ------ n†vrat registrñ

Verif9:  pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Verif    ENDP

; -----------------------------------------------------------------------------
;        instalace obsluhy INT 1eh
; -----------------------------------------------------------------------------

PUBLIC   Inst1e

Inst1e   PROC      NEAR

         push      ax
         push      bx
         push      dx
         push      ds
         push      es

         cmp       word ptr ds:[Old1e+2],-1
         jne       Inst1e9
         mov       ax,351eh
         int       21h
         mov       word ptr ds:[Old1e],bx
         mov       word ptr ds:[Old1e+2],es
         mov       ax,251eh
         mov       dx,offset Int1e
         int       21h

Inst1e9: pop       es
         pop       ds
         pop       dx
         pop       bx
         pop       ax
         ret

Inst1e   ENDP

; -----------------------------------------------------------------------------
;        odinstalov†n° INT 1eh
; -----------------------------------------------------------------------------

PUBLIC   DeInst1e

DeInst1e PROC      NEAR

         push      ax
         push      dx

         cmp       word ptr ds:[Old1e+2],-1
         je        DeIns1e9
         push      ds
         mov       ax,251eh
         lds       dx,ds:[Old1e]
         int       21h                      ; n†vrat INT 1eh
         pop       ds
         mov       word ptr ds:[Old1e+2],-1

DeIns1e9:pop       dx
         pop       ax
         ret

DeInst1e ENDP

; *****************************************************************************
;                              SetForm
;              nastaven° form†tu diskety pro form†tov†n°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=chyba operace
;        AH=statut operace (k¢d chyby: 0ch=nezn†mò form†t, jinak=nen° disk)
; *****************************************************************************

PUBLIC   SetForm

SetForm  PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

         mov       bp,3                     ; poáet pokusñ
         mov       byte ptr ds:[Int1e+2],3  ; doba pro vypnut° motoru
;         mov       byte ptr ds:[Int1e+10],2 ; doba pro rozbàh motoru

; ------ nastaven° form†tu sluëbou 18h

SetForm2:mov       ah,18h
         mov       ch,ds:[MaxStop]          ; max. á°slo stopy
         mov       cl,ds:[MaxSekt]          ; max. poáet sektorñ
         cmp       cl,8
         jne       SetForm3
         mov       cl,9
SetForm3:call      Int13                    ; nastaven° form†tu diskety
         jnc       SetForm4
         cmp       ah,1
         je        SetForm5                 ; funkce nepodporovan†

         call      ResDisk
         dec       bp
         jnz       SetForm2                 ; dal®° pokus
         stc
         jmp       short SetForm9           ; chyba

; ------ inicializace tabulky parametrñ

SetForm4:mov       bl,cl
         mov       cx,12
         push      ds
         push      ds
         push      es
         pop       ds
         pop       es
         mov       si,di
         mov       di,offset Int1e
         rep       movsb                    ; £schova tabulky parametrñ
         pop       ds
         mov       cl,bl

SetForm5:mov       bl,cl
         mov       si,offset Int1e
         mov       byte ptr ds:[si+2],4     ; áas pro vypnut° motoru
         mov       byte ptr ds:[si+3],2     ; velikost sektoru 512 bajtñ
         mov       byte ptr ds:[si+4],bl    ; poáet sektorñ na stopu
         mov       byte ptr ds:[si+8],0     ; plnic° znak form†tov†n°
;         mov       byte ptr ds:[si+10],8    ; doba pro rozbàh motoru
         clc                                ; p©°znak operace OK

SetForm9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

SetForm  ENDP

; *****************************************************************************
;                             ResDisk
;                     reset diskovÇho systÇmu
; -----------------------------------------------------------------------------
; *****************************************************************************

PUBLIC   ResDisk

ResDisk  PROC      NEAR

         push      ax
         mov       ah,0
         call      Int13
         pop       ax
         ret

ResDisk  ENDP

; *****************************************************************************
;                                 Int13
;                obsluha disku s £schovou registrñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

PUBLIC   Int13

Int13    PROC      NEAR

         push      bp
         push      ds

         sti
         mov       dl,ds:[AktDisk]          ; aktivn° disk
         int       13h
         sti

         pop       ds
         pop       bp
         ret

Int13    ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; *****************************************************************************
;                              DispNum
;                         zobrazen° á°sla
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo
;        AH=barva
;        DH=©†dek
;        DL=pozice
; VùSTUP:DL=nov† pozice
; *****************************************************************************

PUBLIC   DispNum

DispNum  PROC      NEAR

         push      ax
         push      bx

         mov       bh,ah
         mov       bl,10
         mov       ah,0
         div       bl
         cmp       al,0
         je        DispNum2

         xchg      ah,bh
         add       al,"0"
         call      Disp1Chr
         xchg      ah,bh

DispNum2:mov       al,ah
         add       al,"0"
         mov       ah,bh
         call      Disp1Chr

         pop       bx
         pop       ax
         ret

DispNum  ENDP

;; *****************************************************************************
;;                             Clear
;;                        vymaz†n° displeje
;; -----------------------------------------------------------------------------
;; VSTUP: DS=datovò segment
;; *****************************************************************************
;
;Clear    PROC      NEAR
;
;         push      ax
;         push      cx
;         push      dx
;
;         mov       ch,ds:[Radku]            ; poáet ©†dkñ
;         mov       cl,80                    ; poáet pozic na ©†dek
;         mov       ax,720h                  ; znak pro vymaz†n°
;         mov       dh,0                     ; poá†teán° ©†dek
;
;Clear1:  mov       dl,0                     ; poá†teán° pozice
;         call      DispChr                  ; vymaz†n° ©†dku
;         inc       dh
;         dec       ch
;         jnz       Clear1                   ; dal®° ©†dek
;
;         xor       dx,dx
;         call      SetKurz                  ; nastaven° pozice kurzoru
;
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;Clear    ENDP

; *****************************************************************************
;                            KurzOff
;                        vypnut° kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

PUBLIC   KurzOff

KurzOff  PROC      NEAR

         push      dx
         mov       dl,0
         mov       dh,ds:[Radku]            ; prvn° ©†dek "za rohem"
         call      SetKurz                  ; nastaven° pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; *****************************************************************************
;                            SetKurz
;                     nastaven° pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice kurzoru
;        DH=©†dek kurzoru
;        DS=datovò segment
; *****************************************************************************

PUBLIC   SetKurz

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,2                     ; funkce - nastaven° pozice kurzoru
         call      Int10P                   ; nastaven° pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; *****************************************************************************
;                            GetKurz
;                     poskytnut° pozice kurzoru
; -----------------------------------------------------------------------------
; VùSTUP:DL=pozice kurzoru
;        DH=©†dek kurzoru
;        DS=datovò segment
; *****************************************************************************

PUBLIC   GetKurz

GetKurz  PROC      NEAR

         push      ax
         push      bx
         push      cx
         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,3                     ; funkce - poskytnut° pozice kurzoru
         call      Int10P                   ; poskytnut° pozice kurzoru
         pop       cx
         pop       bx
         pop       ax
         ret

GetKurz  ENDP

; *****************************************************************************
;                              Disp1Chr
;                    Z†pis 1 znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z†pisu (AL=znak, AH=atribut)
;         DL=pozice
;         DH=©†dek
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

PUBLIC   Disp1Chr

Disp1Chr PROC      NEAR

         push      cx
         mov       cl,1                     ; 1 znak k z†pisu
         call      DispChr                  ; z†pis 1 znaku na displej
         pop       cx
         ret

Disp1Chr ENDP

; *****************************************************************************
;                              DispChr
;                 Opakovanò z†pis znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z†pisu (AL=znak, AH=atribut)
;         CL=poáet znakñ k z†pisu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

PUBLIC   DispChr

DispChr  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispChr8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispChr8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         mov       bx,ax                    ; £schova znaku k z†pisu
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ (do konce ©†dku)

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispChr1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispChr1:les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         sti                                ; p©eru®en° povoleno
         cld                                ; smàr posunu ukazatele nahoru
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         je        DispChr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispChr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
DispChr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispChr5                 ; prob°h† vertik†ln° impuls
DispChr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispChr3                 ; je horiz. zpàtnò bàh - áek†n°
DispChr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispChr4                 ; áek†n° na horiz. zpàtnò bàh
DispChr5:mov       ax,bx                    ; znak k zobrazen°
         stosw                              ; z†pis jednoho znaku
         loop      DispChr2                 ; z†pis dal®°ho znaku

; ------ z†pis znaku bez kontroly snàëen°

DispChr6:mov       ax,bx                    ; znak k zobrazen°
         rep       stosw                    ; z†pis znaku bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispChr7:pop       es                       ; n†vrat ES
         pop       di                       ; n†vrat DI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX

DispChr8:add       dl,cl                    ; zvò®en° pozice
         ret

DispChr  ENDP


; *****************************************************************************
;                              DispTxt
;                  Zobrazen° textovÇho ©etàzce na obrazovce
; -----------------------------------------------------------------------------
; VSTUP:  AH=atribut barvy
;         CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (bez atributñ)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

PUBLIC   DispTxt

DispTxt  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispTxt8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispTxt8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ (do konce ©†dku)

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispTxt1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispTxt1:push      es                       ; £schova segmentu zdrojovÇho textu
         les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         push      ax
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti
         pop       ax

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         sti                                ; p©eru®en° povoleno
         cld                                ; smàr posunu ukazatele nahoru
         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         pop       ds                       ; segment zdrojovÇ adresy
         jcxz      DispTxt7                 ; nen° ë†dnò znak k p©enosu
         je        DispTxt6                 ; neprov†d° se kontrola snàëen°

; ------ p©enos dat s obsluhou snàëen°

DispTxt2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispTxt5                 ; prob°h† vertik†ln° impuls
DispTxt3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispTxt3                 ; je horiz. zpàtnò bàh - áek†n°
DispTxt4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispTxt4                 ; áek†n° na horiz. zpàtnò bàh
DispTxt5:lodsb                              ; naáten° znaku k zobrazen°
         stosw                              ; p©enos jednoho znaku
         loop      DispTxt2                 ; p©enos dal®°ho znaku
         jmp       short DispTxt7

; ------ p©enos dat bez kontroly snàëen°

DispTxt6:lodsb                              ; znak k zobrazen°
         stosw                              ; uloëen° znaku
         loop      DispTxt6                 ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispTxt7:pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       ax                       ; n†vrat AX

DispTxt8:add       dl,cl                    ; zvò®en° pozice
         ret

DispTxt  ENDP

; *****************************************************************************
;                              DispStr
;                 Zobrazen° textovÇho ©etàzce na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (1 znak = 2 bajty = znak a atribut)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

PUBLIC   DispStr

DispStr  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispStr8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispStr8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ do konce ©†dku

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispStr1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispStr1:push      es                       ; £schova segmentu zdrojovÇho textu
         les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         cld                                ; smàr posunu ukazatele nahoru
         sti                                ; povolen° p©eru®en°
         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         pop       ds                       ; segment zdrojovÇ adresy
         je        DispStr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispStr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

DispStr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispStr5                 ; prob°h† vertik†ln° impuls
DispStr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispStr3                 ; je horiz. zpàtnò bàh - áek†n°
DispStr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispStr4                 ; áek†n° na horiz. zpàtnò bàh
DispStr5:movsw                              ; p©enos jednoho znaku
         loop      DispStr2                 ; p©enos dal®°ho znaku

; ------ p©enos dat bez kontroly snàëen°

DispStr6:rep       movsw                    ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispStr7:pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       ax                       ; n†vrat AX

DispStr8:add       dl,cl                    ; zvò®en° pozice
         ret

DispStr  ENDP

; *****************************************************************************
;                             InitVmod
;                      Inicializace videom¢du
;             (poëaduje, aby byla rozpozn†na karta EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: CY=videom¢d byl zmànàn
;         neniá° ë†dnò registr
; *****************************************************************************

PUBLIC   InitVMod

InitVMod PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ kontrola, zda je povolenò videom¢d

         call      AktPDisp                 ; aktualizace parametrñ displeje
         cmp       al,7                     ; MDA ?
         je        InitVM5                  ; povolenò videom¢d
         cmp       al,2
         je        InitVM5                  ; CGA
         cmp       al,3
         je        InitVM5                  ; CGA

; ------ stanoven° implicitn°ho videom¢du

         int       11h                      ; poskytnut° tabulky vybaven°
         and       al,30h                   ; inicializaán° videom¢d
         cmp       al,30h                   ; videom¢d 80x25 monochrom. ?
         mov       al,7                     ; videom¢d MDA
         je        InitVM1                  ; je videom¢d MDA
         mov       al,3                     ; jinak videom¢d CGA
InitVM1: call      SetVMode                 ; nastaven° poëadovanÇho videom¢du
         stc                                ; p©°znak zmàny videom¢du

; ------ n†vrat registrñ

InitVM5: pop       ax
         ret

InitVMod ENDP

; *****************************************************************************
;                               SetVMode
;                          Nastaven° videom¢du
;                (doporuáuje se rozpozn†n° videokarty EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  AL=poëadovanò videom¢d
;         DS=datovò segment
; VùSTUP: AL=novò aktu†ln° videom¢d
;         CY=videom¢d nenastaven
;         neniá° ë†dnò registr
; *****************************************************************************

PUBLIC   SetVMode

SetVMode PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      ax                       ; £schova poëadovanÇho videom¢du

; ------ nastaven° videom¢du

         xor       ah,ah                    ; funkce nastaven° videom¢du
         call      Int10P                   ; nastaven° videom¢du
         call      AktPDisp                 ; poskytnut° aktivn°ho videom¢du
         mov       bl,al                    ; £schova aktu†ln°ho videom¢du

; ------ n†vrat registrñ, zhodnocen° vòsledku

         pop       ax                       ; n†vrat poëadovanÇho videom¢du
         xchg      al,bl                    ; AL <- novò videom¢d
         cmp       al,bl                    ; souhlas° videom¢d s poëadovanòm ?
         je        SetVMod1                 ; videom¢d nastaven OK
         stc                                ; p©°znak chyby nastaven° videom¢du
SetVMod1:pop       bx
         ret

SetVMode ENDP

; *****************************************************************************
;                               AktPDisp
;            Atualizace parametrñ displeje podle videom¢du
;
; Tato procedura pouë°v† k aktualizaci parametrñ pouze operace v pamàti,
; nepouë°v† ë†dnÇ p©eru®en°. Vyëaduje rozpozn†n° karty EGA/VGA.
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: AL=aktu†ln° videom¢d
;         neniá° ë†dnò registr
; *****************************************************************************

PUBLIC   AktPDisp

AktPDisp PROC    NEAR

; ------ £schova registrñ

         push      es
         push      bx

; ------ zji®tàn° videom¢du

         mov       bx,40h
         mov       es,bx                    ; ES <- 40h segment dat BIOS
         mov       al,es:[49h]              ; aktu†ln° videom¢d
         and       al,7fh                   ; zru®en° p©°znaku nemaz†n° displeje

; ------ zji®tàn° videostr†nky

         mov       bl,es:[62h]              ; aktivn° videostr†nka
         mov       ds:[AktPage],bl          ; £schova aktivn° videostr†nky

; ------ zji®tàn° adresy videopamàti a p©ednastaven° p©°znaku obsluhy snàëen°

         mov       byte ptr ds:[ChckSnow],0 ; zru®en° p©°znaku obsluhy snàëen°
         mov       word ptr ds:[AdrVRAM+2],0B000h ; segment videopamàti pro MDA
         cmp       al,7                     ; je videom¢d MDA ?
         je        AktParD1                 ; je videom¢d MDA
         mov       word ptr ds:[AdrVRAM+2],0B800h ; segment videopamàti pro CGA
         inc       byte ptr ds:[ChckSnow]   ; nastav. p©°znaku obsluhy snàëen°
AktParD1:mov       bx,es:[4eh]              ; poá†teán° adresa videopamàti
         mov       word ptr ds:[AdrVRAM],bx ; poá†teán° adresa videopamàti

; ------ zji®tàn° poátu ©†dkñ a up©esnàn° p©°znaku snàëen°

         mov       bl,24                    ; p©ednastaven° na 25 ©†dkñ
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA, VGA ?
         je        AktParD6                 ; nen° karta EGA/VGA
         cmp       byte ptr es:[84h],5      ; je £daj poátu ©†dkñ platnò ?
         jb        AktParD5                 ; £daj poátu ©†dkñ nen° platnò
         mov       bl,es:[84h]              ; poáet ©†dkñ displeje - 1
AktParD5:mov       bh,es:[87h]              ; p©°znak kontroly snàëen°
         shr       bh,1
         shr       bh,1
         and       bh,1                     ; p©°znak obsluhy snàëen°
         mov       ds:[ChckSnow],bh         ; nastaven° p©°znaku kontroly snàë.
AktParD6:mov       ds:[MaxRow],bl           ; maxim†ln° ©†dek na displeji
         inc       bl                       ; poáet ©†dkñ celkem
         mov       ds:[Radku],bl            ; poáet ©†dkñ celkem

; ------ zji®tàn° b†zovÇ ©°dic° adresy displeje CRT

         mov       bx,es:[63h]              ; b†zov† adresa portu ©adiáe CRT
         add       bx,6
         mov       ds:[PortCRT],bx          ; stavovò registr ©adiáe displeje

; ------ n†vrat registrñ

         pop       bx
         pop       es
         ret

AktPDisp ENDP

; *****************************************************************************
;                              DetCard
;                      detekce videokarty EGA/VGA
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
;         neniá° ë†dnò registr
; *****************************************************************************

PUBLIC   DetCard

DetCard  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ test videokarty EGA/VGA

         mov       ah,12h                   ; sluëba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut° informac° o EGA
         call      Int10P                   ; poskytnut° informac° o EGA/VGA
         mov       byte ptr ds:[EgaVga],0   ; zru®en° p©°znaku karty EGA/VGA
         cmp       bh,1                     ; kontrola navr†cenÇho m¢du displeje
         ja        DetectC1                 ; nen° to karta EGA/VGA
         cmp       bl,5                     ; maxim†lnà povolen 1 MB pamàti
         ja        DetectC1                 ; nen° to karta EGA/VGA
         mov       byte ptr ds:[EgaVga],1   ; p©°znak karty EGA/VGA

; ------ n†vrat registrñ

DetectC1:pop       cx
         pop       bx
         pop       ax
         ret

DetCard  ENDP

; *****************************************************************************
;                              Int10P
;                Vol†n° INT 10h s £schovou registrñ
; -----------------------------------------------------------------------------
;
; *****************************************************************************

PUBLIC   Int10P

Int10P   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10P   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           BOOT sektor
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

PUBLIC   Boot

Boot:    jmp       near ptr Bstart

         db        'FORM 1.2'               ; identifikace

         dw        512                      ; dÇlka sektoru
BBlok    db        2                        ; velikost bloku (sektorñ)
         dw        1                        ; poáet rezervovanòch sektorñ
         db        2                        ; poáet alok. tabulek FAT
BRoot    dw        70h                      ; max. poáet poloëek ROOT
BNMax    dw        720                      ; celkem sektorñ na mÇdiu
BIdent   db        0fdh                     ; popisovaá mÇdia
BNFat    dw        3                        ; poáet sektorñ v jednÇ FAT
BSekt    dw        9                        ; poáet sektorñ na stopu
BStran   dw        2                        ; poáet hlav disku
         dd        0                        ; skrytòch sektorñ (4-bajty)
         dd        0                        ; celkem sektorñ (4-bajty)

         db        0                        ; disk (pracovn°)
         db        0                        ; hlava (pracovn°)

         db        29h                      ; identifik†tor
BSerie   dw        0,0                      ; sÇriovÇ á°slo

         db        'NO NAME    '
         db        'FAT12   '

Bstart:  xor       ax,ax
         mov       ss,ax
         mov       sp,7c00h
         sti

         push      ss
         pop       ds
         push      ss
         pop       es

         mov       si,offset(BText-Boot)+7c00h

BDispTxt:cld
         lodsb
         or        al,al
         jz        BRet
         mov       ah,0eh
         mov       bx,7
         int       10h
         jmp       short BDispTxt

BRet:    sti
         xor       ax,ax
         int       16h

         int       19h


BText    db        13
         db        'Nesystemova disketa. Vymente ji',13,10
         db        'a stisknete libovolnou klavesu.',13,10,0

BootEnd  label     byte

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                    Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

PozRF    dw        19                       ; pozice r†meáku form†tov†n°

ColMono  label     byte
         db        7                        ; barva r†mu
         db        0fh                      ; barva nadpisñ
         db        7                        ; barva textu n†povàdy
         db        0fh                      ; barva textu voleb
         db        70h                      ; barva kurzoru
         db        07h                      ; barva r†meáku form†tov†n°
         db        7                        ; barva - pr†zdnÇ pole v r†meáku

         db        70h                      ; znaáka form†tov†n°
         db        70h                      ; znaáka verifikace
         db        70h                      ; znaáka z†pisu
         db        0fh                      ; barva OK
         db        0f0h                     ; barva chyby
ColMono0 label     byte


Color    label     byte
ColRam   db        1eh                      ; barva r†mu
ColNadp  db        1fh                      ; barva nadpisñ
ColHlp   db        1bh                      ; barva textu n†povàdy
ColVolb  db        1fh                      ; barva textu voleb
ColKurz  db        30h                      ; barva kurzoru
ColRF    db        1fh                      ; barva r†meáku form†tov†n°
ColRFNul db        7                        ; barva - pr†zdnÇ pole v r†meáku

ColForm  db        70h                      ; znaáka form†tov†n°
ColVerif db        70h                      ; znaáka verifikace
ColWrite db        70h                      ; znaáka z†pisu
ColOK    db        0ah                      ; barva OK
ColErr   db        4eh                      ; barva chyby


Nadpis1  db        'FORM verze 1.2'
Nadpis2  db        'Formatovani disket'
Nadpis3  db        '(c) Miroslav Nemecek'
Nadpis4  label     byte

HelpTxt1 db        HelpTx12-$-1
         db        'Zvolte disketovou jednotku pomoci kurzoru a ENTER,'
HelpTx12 db        HelpTx13-$-1
         db        'nebo stisknete pismeno oznacujici disketovou jednotku.'
HelpTx13 db        0
HelpTx14 db        HelpTx15-$-1
         db        'Klavesou ESC opustite program FORM.'
HelpTx15 label     byte

HelpTxt2 db        HelpTx22-$-1
         db        'Vlozte do disketove jednotky '
HelpTx2D db        'A: disketu, zvolte format'
HelpTx22 db        HelpTx23-$-1
         db        'a stisknete ENTER. Klavesou ESC se navratite k volbe disku.'
HelpTx23 db        HelpTx24-$-1
HelpTx24 db        HelpTx25-$-1
         db        'VAROVANI: VSECHNA DATA NA DISKETE BUDOU ZNICENA !'
HelpTx25 label     byte

HelpTxt3 db        0
         db        HelpTx32-$-1
         db        'Format diskety '
HelpTx3F db        ' 360K neni pro mechaniku '
HelpTx3D db        'A: povolen !'
HelpTx32 db        HelpTx33-$-1
HelpTx33 db        HelpTx34-$-1
         db        'Stisknete libovolnou klavesu ...'
HelpTx34 label     byte

HelpTxt4 db        0
         db        HelpTx43-$-1
         db        'V disketove jednotce '
HelpTx4D db        'A: neni vlozena disketa !'
HelpTx43 db        0
         db        HelpTx44-$-1
         db        'ENTER=novy pokus, jina klavesa=preruseni operace'
HelpTx44 label     byte

HelpTxt5 db        HelpTx51-$-1
         db        'celkem :          0 B  '
HelpTx51 db        HelpTx52-$-1
         db        ' volne :          0 B  '
HelpTx52 db        HelpTx53-$-1
         db        ' vadne :          0 B  '
HelpTx53 db        HelpTx54-$-1
         db        'CEKEJTE - probiha formatovani diskety (ESC=preruseni)'
HelpTx54 label     byte

HelpTxt6 db        HelpTx61-$-1
         db        'celkem :          0 B  '
HelpTx61 db        HelpTx62-$-1
         db        ' volne :          0 B  '
HelpTx62 db        HelpTx63-$-1
         db        ' vadne :          0 B  '
HelpTx63 db        HelpTx64-$-1
         db        'Formatovani ukonceno: ENTER=dalsi disketa, jina klavesa=konec'
HelpTx64 label     byte

HelpTxt7 db        HelpTx71-$-1
HelpTx71 db        HelpTx72-$-1
         db        'Chyba v systemove oblasti diskety - disketa je NEPOUZITELNA !'
HelpTx72 db        HelpTx73-$-1
HelpTx73 db        HelpTx74-$-1
         db        'ENTER=pokracovani, jina klavesa=preruseni operace'
HelpTx74 label     byte

HelpTxt8 db        HelpTx81-$-1
HelpTx81 db        HelpTx82-$-1
         db        'Disketa ma nastavenu ochranu proti zapisu !'
HelpTx82 db        HelpTx83-$-1
HelpTx83 db        HelpTx84-$-1
         db        'Stisknete libovolnou klavesu ...'
HelpTx84 label     byte


HelpTxFR label     byte
         db        ' 160K'
         db        ' 180K'
         db        ' 320K'
         db        ' 360K'
         db        ' 720K'
         db        ' 1.2M'
         db        '1.44M'

; -----------------------------------------------------------------------------
;        tabulka disketovòch parametrñ
; -----------------------------------------------------------------------------

Old1e    dd        -1                       ; pñvodn° vektor INT 1eh

Int1e    label     byte                     ; vlastn° tabulka INT 1eh
         db        0dfh                     ; bity 0 aë 3: rychlost krokov†n°
                                            ; bity 4 aë 7: áas zvednut° hlavy
         db        2                        ; bit 0: 1=je provoz DMA
                                            ; bity 1 aë 7: áas spu®tàn° hlavy
         db        37                       ; 2: vypnut° motoru v 1/18 sekundy
         db        2                        ; 3: velikost sektoru
         db        9                        ; 4: poáet sektorñ na stopu
         db        42                       ; 5: mezisekt. mezera áten°/z†pis
         db        255                      ; 6: dÇlka p©en†®enòch dat
         db        80                       ; 7: mezisekt. mezera form†tov†n°
FillCh   db        0                        ; 8: plnic° znak form†tov†n°
         db        15                       ; 9: doba ust†len° hlav v [ms]
         db        8                        ; 10: doba pro rozbàh motoru v 1/8s
         db        39                       ; 11: posledn° stopa na disku
         db        80h                      ; 12: p©enosov† rychlost

; -----------------------------------------------------------------------------
;        volby form†tñ
; -----------------------------------------------------------------------------

FormVol0 db        '(1)   160K   (SS DD: 1 strana,  8 sektoru/40 stop)'
FormVol1 db        '(2)   180K   (SS DD: 1 strana,  9 sektoru/40 stop)'
FormVol2 db        '(3)   320K   (DS DD: 2 strany,  8 sektoru/40 stop)'
FormVol3 db        '(4)   360K   (DS DD: 2 strany,  9 sektoru/40 stop)'
FormVol4 db        '(5)   720K   (DS DD: 2 strany,  9 sektoru/80 stop)'
FormVol5 db        '(6)   1.2M   (DS HD: 2 strany, 15 sektoru/80 stop)'
FormVol6 db        '(7)  1.44M   (DS HD: 2 strany, 18 sektoru/80 stop)'

; -----------------------------------------------------------------------------
;        parametry form†tñ disket
; -----------------------------------------------------------------------------
; struktura: 0: (1) celkov† vò®ka r†meákñ form†tov†n° na obrazovce
;            1: (1) maxim†ln° á°slo stopy (39 nebo 79)
;            2: (1) maxim†ln° á°slo strany (0 nebo 1)
;            3: (1) poáet sektorñ na stopu (8, 9, 15 nebo 18)
;            DOS
;            4: (1) poáet sektorñ na alokaán° blok (1 nebo 2)
;            5: (1) poáet sektorñ na ROOT (4,7,14)
;            6: (1) popisovaá mÇdia (0f9h, 0fbh, 0fch, 0fdh, 0feh, 0ffh)
;            7: (1) poáet sektorñ na jednu tabulku FAT
; -----------------------------------------------------------------------------

ParForm  label     byte
         db        4,39,0,8,   1,4,0feh,1   ; 1: 160K (320 sek, 313 blk,
         db        4,39,0,9,   1,4,0fch,2   ; 2: 180K (360 sek, 351 blk,
         db        5,39,1,8,   2,7,0ffh,1   ; 3: 320K (640 sek, 315 blk,
         db        5,39,1,9,   2,7,0fdh,2   ; 4: 360K (720 sek, 354 blk,
         db        11,79,1,9,  2,7,0f9h,3   ; 5: 720K (1440 sek, 713 blk,
         db        11,79,1,15, 1,14,0f9h,7  ; 6: 1.2M (2400 sek, 2371 blk,
         db        11,79,1,18, 1,14,0f9h,9  ; 7: 1.44M (2880 sek, 2847 blk,

; -----------------------------------------------------------------------------
;        Parametry displeje a videom¢du
; -----------------------------------------------------------------------------

         EVEN
AdrVRAM  dd        0b8000000h               ; adresa videostr†nky displeje
PortCRT  dw        3dah                     ; b†zov† adresa portu ©adiáe CRT
Radku    db        25                       ; poáet ©†dkñ celkem
MaxRow   db        24                       ; maxim†ln° ©†dek na displeji
EgaVga   db        0                        ; p©°znak, ëe je karta EGA/VGA
ChckSnow db        0                        ; p©°znak, ëe se kontroluje snàëen°
AktPage  db        0                        ; aktivn° videostr†nka

; -----------------------------------------------------------------------------
;        parametry disku
; -----------------------------------------------------------------------------

AktDisk  db        0                        ; á°slo aktivn°ho disku
AktStop  db        0                        ; aktu†ln° stopa
AktStran db        0                        ; aktu†ln° strana

NumDisk  db        2                        ; poáet disketovòch jednotek
AktForm  db        6                        ; aktivn° form†t diskety
TypDisk  db        0                        ; typ aktivn°ho disku (0=nezn†mò)

FrstChar dw        0                        ; znak prvn° stopy

Priznaky db        0                        ; p©°znaky
                                            ;  bit 0: 1=ignor. chyb systÇm.sekt.
                                            ;  bit 1: 1=data stopy se nemàn°

FormTypD db        4,4,6,5,7                ; p©ednastavenÇ form†ty

AktPozF  dw        0                        ; aktivn° pozice na displej

MaxSekt  db        9                        ; maxim†ln° á°slo sektoru
MaxStop  db        79                       ; maxim†ln° á°slo stopy
MaxStran db        1                        ; maxim†ln° á°slo strany

CelkSekt dw        0                        ; celkem datovòch sektorñ
VolSekt  dw        0                        ; volnòch datovòch sektorñ
BadSekt  dw        0                        ; poáet vadnòch sektorñ

SektRoot dw        0                        ; poáet sektorñ na ROOT
FirstDat dw        0                        ; prvn° datovò sektor absolutnà

AktSekt  dw        0                        ; aktu†ln° poá†teán° sektor stopy

NoDisk   db        'Nenalezena zadna disketova jednotka !',13,10,'$'

MemTxt   db        'CHYBA - nedostatek pameti !',13,10,'$'

TabFat   db        9*512 dup(?)             ; tabulka FAT

DataBuf  db        18*512 dup(?)            ; buffer dat jednÇ stopy

Int13Buf dw        ?                        ; adresa bufferu Int 13h

OldKurz  dw        ?                        ; uschovan† pozice kurzoru
ObrSize  dw        ?                        ; velikost bufferu obrazovky (slov)
ObrBuf   label     byte                     ; buffer obrazovky
         db        160*60 dup(?)            ; rezerva pro obrazovku
         db        2*18*512 dup(?)          ; rezerva pro INT 13h
         db        1000h dup(?)             ; rezerva pro z†sobn°k

CODE     ENDS

         END       Start

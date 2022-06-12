
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                D I S K F
;                 obsluha diskovòch za©°zen° - soubory
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeDisk SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDisk,ds:Data

; *****************************************************************************
;                                 NulDErr
;                        Nulov†n° registru diskovÇ chyby
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

NulDErr  PROC      FAR

         mov       word ptr ds:[LastErr],0
         ret

NulDErr  ENDP

; *****************************************************************************
;                               InitDPar
;                  inicializace tabulky diskovòch parametrñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: [BP-1] (1) uschovanò pñvodn° aktivn° disk
;                   [BP-2] (1) ukazatel á°sla disku
;                   [BP-4] (2) ukl†dac° adresa do tabulky diskñ
;                   [BP-44h] (40h) buffer bloku parametrñ disku
; *****************************************************************************

InitDPar PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ £schova registrñ

         mov       bp,sp
         sub       sp,44h                   ; buffer v z†sobn°ku

; ------ £schova aktivn°ho disku

         call      far ptr GetDisk         ; poskytnut° aktivn°ho disku
         cmp       al,DiskMax
         jb        InitDPr0
         mov       al,2                     ; implicitnà disk C:
InitDPr0:mov       ss:[bp-1],al             ; £schova aktivn°ho disku

; ------ p©°prava registrñ

         mov       byte ptr ss:[bp-2],0     ; ukazatel á°sla disku
         mov       word ptr ss:[bp-4],offset DiskITab ; ukl†dac° adresa do tab.
         mov       word ptr ds:[DiskNum],0  ; poáet diskñ

; ------ test, zda je disk platnò (zda lze nastavit)

InitDPr1:mov       al,ss:[bp-2]             ; á°slo disku
         mov       di,ss:[bp-4]             ; ukl†dac° adresa do tabulky
         mov       byte ptr ds:[di],0       ; neplatnò disk
         call      far ptr SetDisk         ; pokus o nastaven° disku
         jnc       InitDPr2                 ; disk je platnò
         jmp       InitDPr7                 ; dal®° disk
InitDPr2:inc       byte ptr ds:[DiskNum]    ; zvò®en° á°taáe diskñ

; ------ stanoven° atributu vòmànosti disku AL

InitDP21:cmp       byte ptr ds:[VerzeOS+1],3 ; je verze DOS 3.00 nebo vy®®° ?
         jb        InitDP22                 ; je n°zk† verze systÇmu
         xchg      ax,bx                    ; BL <- poëadovanò disk
         inc       bx                       ; korekce á°sla disku
         mov       ax,4408h
         int       21h                      ; je disk vòmànnò ?
         shl       al,1                     ; 2=pevnò disk, 0=vòmànnò disk
InitDP22:mov       byte ptr ds:[di],1       ; typ - disketa
         cmp       al,2                     ; disk A nebo B / vòmànnò disk ?
         jb        InitDP25                 ; je disk A nebo B nebo vòmànnò disk
         mov       byte ptr ds:[di],2+bit6  ; jinak z©ejmà pevnò disk

; ------ stanoven° atributu d†lkovÇho za©°zen° a SUBST (disk BL)

InitDP25:cmp       word ptr ds:[VerzeOS],3*HI+10 ; je verze DOS 3.10 nebo vy®®° ?
         jb        InitDPr3                 ; je n°zk† verze systÇmu
         xor       dx,dx                    ; DX <- 0 p©ednastaven° atributñ
         mov       ax,4409h
         int       21h                      ; je disk lok†ln° ?
         jc        InitDPr3                 ; chyba - asi neplatn† funkce

         mov       al,dh                    ; atributy disku
         test      al,bit12/HI              ; je disk lok†ln° ?
         jz        InitDP26                 ; disk je lok†ln°
         or        byte ptr ds:[DiskITbP],bit0 ; nalezen s°üovò disk
         and       byte ptr ds:[di],bit6    ; atribut pevnÇho disku
         or        byte ptr ds:[di],4+bit4+bit5 ; typ - s°üovò disk
         jmp       short InitDPr4           ; je d†lkovò disk

InitDP26:and       al,(bit12+bit13+bit15)/HI ; jen pot©ebnÇ atributy
         or        ds:[di],al               ; novÇ atributy
         test      al,bit15/HI              ; je disk SUBST ?
         jz        InitDPr3                 ; nen° SUBST
         and       byte ptr ds:[di],not bit0+bit1+bit2
         or        byte ptr ds:[di],5+bit5  ; SUBST disk (nen° diskov† editace)

; ------ detekce RAM disku

InitDPr3:cmp       word ptr ds:[VerzeOS],3*HI+20 ; minim†ln° verze 3.20
         jb        InitDPr4                 ; je n°zk† verze systÇmu
         test      byte ptr ds:[di],bit7    ; je SUBST disk ?
         jnz       InitDPr4                 ; je SUBST disk
         test      byte ptr ds:[di],bit6    ; je pevnò disk ?
         jz        InitDPr4                 ; nen° pevnò disk

         mov       dx,sp                    ; buffer v z†sobn°ku
         push      ds
         push      di
         push      ss
         pop       ds                       ; DS <- SS buffer v z†sobn°ku
         mov       si,ds                    ; SI <- DS pro OS/2
         mov       di,dx                    ; DI <- DX pro OS/2
         mov       bh,0
         mov       bl,ss:[bp-2]             ; á°slo disku
         inc       bx                       ; korekce á°sla disku
         mov       byte ptr ds:[di],bit2    ; dopl§uj°c° funkce
         mov       cx,860h                  ; podfunkce - poskytnut° parametrñ
         mov       ax,440dh
         clc                                ; p©ednastaven°
         int       21h
         pop       di
         pop       ds
         jnc       InitDPr4                 ; podporuje IOCTL
         mov       byte ptr ds:[di],3+bit6  ; je z©ejmà RAM disk

; ------ p©°prava pro dal®° disk

InitDPr4:
InitDPr7:inc       word ptr ss:[bp-4]       ; posun adresy na dal®° disk
         inc       byte ptr ss:[bp-2]       ; zvò®en° á°sla disku
         cmp       byte ptr ss:[bp-2],DiskMax ; jsou jië v®echny disky ?
         jae       InitDPr8                 ; jsou jië v®echny disky
         jmp       InitDPr1                 ; test dal®°ho disku

; ------ n†vrat pñvodn°ho aktivn°ho disku

InitDPr8:mov       al,ss:[bp-1]             ; pñvodn° aktivn° disk
         call      far ptr SetDisk         ; nastaven° pñvodn°ho aktiv. disku

; ------ pokud nebyl ani jeden disk, bude implicitnà 1 disk C:

         cmp       byte ptr ds:[DiskNum],0  ; byl alespo§ 1 disk ?
         jne       IniDPr92                 ; je alespo§ 1 disk
         inc       byte ptr ds:[DiskNum]    ; implicitn° 1 disk
         mov       byte ptr ds:[DiskITab+2],1 ; 1 disk C: (je to ale pt†kovina)

; ------ 2 disketovÇ mechaniky, je-li pouze 1 mechanika

IniDPr92:call      DetLDMap                 ; korekce mapov†n° logickòch diskñ

; ------ detekce CD-ROM disku

IniDPr94:test      byte ptr ds:[DiskITbP],bit0 ; nalezen s°üovò disk ?
         jz        InitDPr9                 ; nenalezen
         call      IniCDRom                 ; inicializace CD-ROM

; ------ blokov†n° voleb disku A: a B:

InitDPr9:and       word ptr ds:[FrmDMBlk],not bit1+bit1*HI ; disk A:,B: povolen
         and       word ptr ds:[RusDMBlk],not bit1+bit1*HI ; disk A:,B: povolen
         and       word ptr ds:[KopDMBlk],not bit1+bit1*HI ; disk A:,B: povolen
         and       word ptr ds:[KopD2Blk],not bit1+bit1*HI ; disk A:,B: povolen
         and       word ptr ds:[CmpDMBlk],not bit1+bit1*HI ; disk A:,B: povolen
         and       word ptr ds:[CmpD2Blk],not bit1+bit1*HI ; disk A:,B: povolen

         cmp       byte ptr ds:[DiskITab],0 ; je disk A: platnò ?
         jne       IniDPr96                 ; disk A: platnò
         or        byte ptr ds:[FrmDMBlk],bit1 ; z†kaz disku A:
         or        byte ptr ds:[RusDMBlk],bit1 ; z†kaz disku A:
         or        byte ptr ds:[KopDMBlk],bit1 ; z†kaz disku A:
         or        byte ptr ds:[KopD2Blk],bit1 ; z†kaz disku A:
         or        byte ptr ds:[CmpDMBlk],bit1 ; z†kaz disku A:
         or        byte ptr ds:[CmpD2Blk],bit1 ; z†kaz disku A:

IniDPr96:cmp       byte ptr ds:[DiskITab+1],0 ; je disk B: platnò ?
         jne       IniDPr98                 ; disk B: platnò
         or        byte ptr ds:[FrmDMBlk+1],bit1 ; z†kaz disku B:
         or        byte ptr ds:[RusDMBlk+1],bit1 ; z†kaz disku B:
         or        byte ptr ds:[KopDMBlk+1],bit1 ; z†kaz disku B:
         or        byte ptr ds:[KopD2Blk+1],bit1 ; z†kaz disku B:
         or        byte ptr ds:[CmpDMBlk+1],bit1 ; z†kaz disku B:
         or        byte ptr ds:[CmpD2Blk+1],bit1 ; z†kaz disku B:

; ------ n†vrat registrñ

IniDPr98:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitDPar ENDP

; -----------------------------------------------------------------------------
;        korekce mapov†n° logickòch diskñ
; -----------------------------------------------------------------------------

DetLDMap PROC      NEAR

         mov       al,byte ptr ds:[Vybaveni] ; vybaven°
         and       al,bit0+bit6+bit7        ; p©°znak disket
         cmp       al,bit0                  ; je 1 mechanika ?
         jne       DetLDMp9                 ; nen° jen 1 mechanika
         cmp       word ptr ds:[DiskITab],1+1*HI ; 2 mechaniky ?
         jne       DetLDMp9                 ; nejsou 2 mechaniky
         dec       byte ptr ds:[DiskNum]    ; sn°ëen° poátu diskñ

         mov       al,ss:[bp-1]             ; aktivn° disk
         mov       byte ptr ds:[DiskITab],0 ; 1. mechanika neplatn†
         cmp       al,1                     ; je aktivn° mechanika B: ?
         je        DetLDMp5                 ; aktivn° mechanika B:
         mov       word ptr ds:[DiskITab],1 ; 2. mechanika neplatn†
         jb        DetLDMp5                 ; aktivn° mechanika A:

         cmp       word ptr ds:[VerzeOS],3*HI+20 ; minim†ln° verze 3.20
         jb        DetLDMp9                ; je n°zk† verze systÇmu
         mov       ax,440eh
         mov       bl,1                     ; disk A:
         int       21h                      ; poskytnut° mapov†n° disku A:
         jc        DetLDMp9                 ; chyba
         cmp       al,1
         jbe       DetLDMp9                 ; mechanika A: nebo neplatn†
         mov       word ptr ds:[DiskITab],1*HI ; 1. mechanika neplatn†
         jmp       short DetLDMp9

DetLDMp5:cmp       word ptr ds:[VerzeOS],3*HI+20 ; minim†ln° verze 3.20
         jb        DetLDMp9                 ; je n°zk† verze systÇmu
         xchg      ax,bx                    ; BL <- poëadovan† mechanika
         inc       bx
         mov       ax,440fh
         int       21h                      ; nastaven° vòmàny disku

DetLDMp9:ret

DetLDMap ENDP

; -----------------------------------------------------------------------------
;        inicializace CD-ROM (vyëaduje ovladaá verze minim†lnà 2.00 !!!!)
; -----------------------------------------------------------------------------

IniCDRom PROC      NEAR

; ------ lok†ln° buffer

         sub       sp,256                   ; buffer pro naáten° diskñ

; ------ inicializace bufferu na nesmysly

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; DI <- offset bufferu
         mov       cx,256/2                 ; velikost bufferu / 2
         xor       ax,ax
         dec       ax                       ; AX <- -1
         cld
         rep       stosw                    ; vymaz†n° bufferu

; ------ naáten° seznamu CD diskñ

         mov       bx,sp                    ; BX <- offset bufferu
         mov       al,0dh                   ; funkce naáten° seznamu diskñ
         call      far ptr IntCD            ; obsluha CD-ROM

; ------ korekce oznaáen° diskñ

         mov       si,sp                    ; SI <- buffer v z†sobn°ku
         mov       bh,0
IniCDRm2:mov       bl,ss:[si]               ; BL <- á°slo disku
         inc       si                       ; zvò®en° ukazatele v bufferu
         cmp       bl,DiskMax               ; je to platnò disk ?
         jae       IniCDRm9                 ; nen° platnò disk (konec tabulky)

         mov       al,ds:[bx+DiskITab]      ; parametry disku
         and       al,bit0+bit1+bit2        ; typ disku
         cmp       al,4                     ; je to s°üovò disk ?
         jne       IniCDRm2                 ; nen° to s°üovò disk
         xor       byte ptr ds:[bx+DiskITab],4 xor 6 ; zmàna na CD-ROM disk
         or        byte ptr ds:[DiskITbP],bit1 ; je ovladaá CD-ROM
         jmp       short IniCDRm2           ; dal®° disk

; ------ n†vrat z†sobn°ku

IniCDRm9:add       sp,256
         ret

IniCDRom ENDP

; *****************************************************************************
;                               IniDSKom
;               inicializace segmentu koment†©ñ k diskñm
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------
; zniáenÇ registry: AX, BX, CX, DI, ES
; *****************************************************************************
;˛
IniDSKom PROC      FAR

; ------ vytvo©en° datovÇho bloku

;         and       byte ptr ds:[DiskInfP],not bit0+bit1+bit2+bit3 ; parametry
         call      far ptr CreatSeg         ; vytvo©en° datovÇho bloku
         jc        IniDSKm9                 ; chyba pamàti
         mov       ds:[DiskInfS],ax         ; segment datovÇho bloku

; ------ nastaven° velikosti bloku

         mov       bx,2+DiskMax+1+1         ; inicializaán° velikost bloku
         call      far ptr ModiSegS         ; nastaven° velikosti bloku
         jc        IniDSKm9                 ; chyba pamàti

; ------ adresa bufferu

         call      far ptr GetDat           ; poskytnut° adresy bufferu

; ------ inicializace ukazatelñ

         xchg      ax,bx                    ; velikost dat v bufferu
         xor       di,di
         cld
         stosw                              ; slovo velikosti bloku
         mov       cx,(DiskMax+1+1)/2       ; poáet diskñ
         xor       ax,ax
         rep       stosw                    ; inicializace koment†©ñ k diskñm
;         clc                                ; NC = operace OK

IniDSKm9:ret

IniDSKom ENDP

; *****************************************************************************
;                                 InitIDsk
;                   inicializace z konfiguraán°ho souboru
;    (buffer koment†©ñ k diskñm mus° bòt inicializov†n na pr†zdnà ©etàzce !)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************
;˛
InitIDsk PROC      FAR

; ------ nalezen° dal®°ho parametru

InitIDs1:call      far ptr NextLIni        ; dal®° ©†dek
         jnc       InitIDs2                 ; je dal®° ©†dek OK
IniIDs12:ret

InitIDs2:cmp       byte ptr es:[di],"["
         je        IniIDs12
         mov       si,di                    ; SI <- £schova adresy textu
         call      far ptr JumpPTxt

         db        6,'FLABEL'
         dw        IniIDs21

         db        7,'FVERIFY'
         dw        IniIDs24

         db        5,'FBEEP'
         dw        IniIDs25

         db        6,'FWRITE'
         dw        IniIDs26

         db        7,'EXTFORM'
         dw        IniIDs34

         db        7,'DISKEDI'
         dw        IniIDs41

         db        8,'DISKFORM'
         dw        IniIDs42

         db        7,'DISKLAB'
         dw        IniIDs43

         db        8,'DISKCOPY'
         dw        IniIDs44

         db        7,'DISKNUL'
         dw        IniIDs45

         db        7,'DISKDEL'
         dw        IniIDs46

         db        0
         dw        InitIDs7

; ------ zad†n° jmÇna disku

IniIDs21:mov       ah,not bit0
         jmp       short IniIDs28

; ------ verifikace

IniIDs24:mov       ah,not bit1
         jmp       short IniIDs28

; ------ indikace konce

IniIDs25:mov       ah,not bit2
         jmp       short IniIDs28

; ------ testovac° z†pis

IniIDs26:mov       ah,not bit3

IniIDs28:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniIDs29
         and       ds:[FormParm],ah         ; parametr vypnut
         jcxz      IniIDs29
         not       ah
         or        ds:[FormParm],ah         ; parametr zapnut
IniIDs29:jmp       InitIDs1

; ------ instalace roz®°©enòch form†tñ

IniIDs34:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniIDs29
         or        byte ptr ds:[Rez13Par],bit7 ; z†kaz instalace
         jcxz      IniIDs29                 ; je z†kaz instalace
         and       byte ptr ds:[Rez13Par],not bit7 ; instalace povolena
         jmp       short IniIDs29

; ------ povolen° editace disku

IniIDs41:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniIDs29
         or        byte ptr ds:[DMnuVBlk+1],bit0 ; z†kaz editace disku
         jcxz      IniIDs29                 ; je z†kaz editace disku
         and       byte ptr ds:[DMnuVBlk+1],not bit0 ; povolena editace disku
         jmp       short IniIDs29

; ------ povolen° form†tov†n° disket

IniIDs42:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniIDs29
         or        byte ptr ds:[DMnuVBlk+2],bit0 ; z†kaz form†tov†n° disket
         jcxz      IniIDs29
         and       byte ptr ds:[DMnuVBlk+2],not bit0 ; povoleno form†tov†n° disket
         jmp       short IniIDs29

; ------ povolen° zmàny jmÇna disku

IniIDs43:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniIDs29
         or        byte ptr ds:[DMnuVBlk+4],bit0 ; z†kaz p©ejmenov†n° disku
         jcxz      IniIDs29
         and       byte ptr ds:[DMnuVBlk+4],not bit0 ; povoleno p©ejmenov†n° disku
IniID439:jmp       short IniIDs29

; ------ povolen° kop°rov†n° disket

IniIDs44:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniID439
         or        byte ptr ds:[DMnuVBlk+5],bit0 ; z†kaz kop°rov†n° disket
         jcxz      IniID439
         and       byte ptr ds:[DMnuVBlk+5],not bit0 ; povoleno kop°rov†n° disket
         jmp       short IniID439

; ------ povolen° nulov†n° disku

IniIDs45:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniID439
         or        byte ptr ds:[DMnuVBlk+7],bit0 ; z†kaz nulov†n° disku
         jcxz      IniID439
         and       byte ptr ds:[DMnuVBlk+7],not bit0 ; povoleno nulov†n° disku
         jmp       short IniID439

; ------ povolen° ru®en° disket

IniIDs46:call      far ptr InitIPYN         ; parametr Y/N
         jc        IniID439
         or        byte ptr ds:[DMnuVBlk+9],bit0 ; z†kaz ru®en° disket
         jcxz      IniID439
         and       byte ptr ds:[DMnuVBlk+9],not bit0 ; povoleno ru®en° disket
         jmp       short IniID439

; ------ á†steán† shoda parametru

InitIDs7:mov       di,si                    ; DI <- adresa zaá†tku ©†dku
         call      far ptr JumpPShd

         db        4,'FORM'
         dw        IniIDs72

         db        4,'DISK'
         dw        IniIDs82

         db        0
         dw        InitIDs1

; ------ form†t disket "FORMx"

IniIDs72:mov       al,es:[di]               ; n†sleduj°c° znak
         sub       al,"0"                   ; konverze na á°slo mechaniky
         jbe       IniID732                 ; neplatnÇ á°slo
         cmp       al,5
         ja        IniID732                 ; neplatnÇ á°slo mechaniky
         inc       di                       ; zvò®en° ukazatele textu

; ------ adresa k uloëen° definice

         mov       ah,MAXFORM*3 + 1         ; velikost jednoho popisovaáe
         mul       ah                       ; offset v tabulce
         add       ax,offset FormTab - MAXFORM*3
         xchg      ax,si                    ; SI <- ukazatel definice form†tñ
         mov       al,ds:[si-1]             ; poáet form†tñ
         cmp       al,MAXFORM               ; maxim†ln° poáet form†tñ
         jae       IniID732                 ; je jië maxim†ln° poáet form†tñ
         mov       ah,3
         mul       ah                       ; offset novÇ poloëky
         add       ax,si
         xchg      ax,bx                    ; BX <- ukl†dac° adresa

; ------ vypu®tàn° mezer

         call      far ptr InitISpc         ; vypu®tàn° mezer
         cmp       byte ptr es:[di],"="     ; je oddàlovaá ?
         jne       IniIDs73
         inc       di
         call      far ptr InitISpc

; ------ poáet hlav

IniIDs73:call      far ptr InitIBNm         ; poáet stran
         jnc       IniID734
IniID732:jmp       InitIDs1

IniID734:cmp       al,2                     ; 2 hlavy ?
         mov       al,0                     ; 2 strany
         jae       IniIDs74                 ; jsou 2 strany
         mov       al,bit7                  ; 1 strana
IniIDs74:mov       ds:[bx+1],al             ; poáet stran

; ------ poáet stop

         call      far ptr InitICar         ; vypu®tàn° á†rky
         call      far ptr InitIBNm         ; poáet stop
         jc        IniID732                 ; chyba
         cmp       al,1                     ; minim†lnà stop
         jb        IniID732                 ; chyba
         cmp       al,99                    ; maxim†lnà stop
         ja        IniID732                 ; chyba
         or        al,bit7                  ; nestandardn° form†t
         mov       ds:[bx],al               ; poáet stop

; ------ poáet sektorñ na stopu

         call      far ptr InitICar         ; vypu®tàn° á†rky
         call      far ptr InitIBNm         ; poáet sektorñ na stopu
         jc        IniID732                 ; chyba
         cmp       al,1                     ; minim†lnà sektorñ
         jb        IniID732                 ; chyba
         cmp       al,50                    ; maxim†lnà sektorñ
         ja        IniID732                 ; chyba
         or        ds:[bx+1],al             ; poáet sektorñ na stopu

; ------ poáet poloëek ROOT

         call      far ptr InitICar         ; vypu®tàn° á†rky
         call      far ptr InitIWNm         ; poáet poloëek ROOT
         jc        IniID732                 ; chyba
         add       ax,15                    ; zaokrouhlen° nahoru
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na sektory
         jz        IniIDs78                 ; chyba
         cmp       al,512/16                ; maxim†ln° poáet sektorñ
         ja        IniIDs78                 ; chyba
         dec       ax                       ; korekce
         mov       ds:[bx+2],al             ; poáet poloëek ROOT

; ------ poáet sektorñ na blok

         call      far ptr InitICar         ; vypu®tàn° á†rky
         call      far ptr InitIBNm         ; poáet sektorñ ROOT
         jc        IniIDs78
         cmp       ax,64
         ja        IniIDs78                 ; chyba
IniIDs75:shr       ax,1
         jz        IniIDs76
         add       byte ptr ds:[bx+2],bit5
         jmp       short IniIDs75

IniIDs76:inc       byte ptr ds:[si-1]       ; form†t je platnò OK

IniIDs78:jmp       InitIDs1

; ------ bude koment†© k disku

IniIDs82:mov       al,es:[di]               ; oznaáen° disku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         sub       al,"A"
         jb        IniIDs78
         cmp       al,DiskMax
         jae       IniIDs78                 ; neplatnò disk
         inc       di
         mov       ah,0
         xchg      ax,bx                    ; BX <- á°slo disku

; ------ nalezen° zaá†tku textu -> ES:DI

         call      far ptr InitISpc
         cmp       byte ptr es:[di],"="
         jne       IniIDs83
         inc       di
         call      far ptr InitISpc

; ------ zji®tàn° dÇlky textu -> CX

IniIDs83:xor       cx,cx
         push      di
IniIDs84:cmp       byte ptr es:[di]," "
         jb        IniIDs85
         inc       cx
         inc       di
         jmp       short IniIDs84
IniIDs85:pop       di

; ------ omezen° dÇlky koment†©e -> CX

         cmp       cx,255
         jbe       IniIDs86                 ; dÇlka je OK
         mov       cx,255                   ; omezen° dÇlky koment†©e

; ------ nalezen° adresy koment†©e -> SI

IniIDs86:mov       ax,ds:[DiskInfS]
         call      far ptr GetDat
         mov       si,2
         or        bx,bx
         jz        IniIDs88
         mov       ah,0
IniIDs87:mov       al,es:[si]
         inc       si
         add       si,ax
         dec       bx
         jnz       IniIDs87

; ------ vytvo©en° m°sta v bufferu

IniIDs88:inc       si
         push      di
         mov       di,si                    ; adresa v bufferu
         mov       ax,ds:[DiskInfS]         ; segment diskovòch informac°
         push      cx
         xor       cx,cx
         xchg      cl,es:[di-1]             ; star† dÇlka koment†©e
         jcxz      IniID882
         call      far ptr DelDat
IniID882:pop       cx
         call      far ptr InsDat           ; vytvo©en° m°sta v bufferu
         pop       di
         jc        IniIDs78                 ; chyba - nedostatek pamàti
         jcxz      IniIDs78

; ------ p©enesen° textu do bufferu

         push      ds

         mov       dx,SEG CodeDek           ; segment tabulky
         mov       bx,offset TbLatKam       ; konverze Latin 2 -> Kamenickòch
         cmp       byte ptr ds:[Cod0PagK],2 ; je k¢d Latin 2 ?
         je        IniID884                 ; je k¢d Latin 2
         xor       bx,bx                    ; nen° konverze

IniID884:push      es
         call      far ptr GetDIni
         pop       ds
         mov       ds:[si-1],cl

IniIDs89:mov       al,es:[di]

         cmp       al,128                   ; je pot©eba p©ek¢dovat ?
         jb        IniID892                 ; nen° pot©eba p©ek¢dovat
         or        bx,bx                    ; je konverze ?
         jz        IniID892                 ; nen° konverze

         push      ds
         mov       ds,dx                    ; segment tabulky
         sub       al,128
         xlat                               ; konverze znaku
         pop       ds

IniID892:mov       ds:[si],al
         inc       si
         inc       di
         loop      IniIDs89
         pop       ds
         jmp       InitIDs1

InitIDsk ENDP

; *****************************************************************************
;                                 ResDisk
;                       resetov†n° diskovÇho systÇmu
; *****************************************************************************

ResDisk  PROC      FAR

         push      ax
         mov       ah,0dh
         int       21h                      ; reset diskovÇho systÇmu
         pop       ax
         ret

ResDisk  ENDP

;; *****************************************************************************
;;                               InitDKom
;;                     inicializace koment†©ñ k diskñm
;; -----------------------------------------------------------------------------
;; VSTUP: DS=datovò segment
;; *****************************************************************************
;;˛
;InitDKom PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      es
;         sub       sp,FileMax               ; buffer pro cestu
;
;; ------ vytvo©en° datovÇho bloku
;
;         and       byte ptr ds:[DiskInfP],not bit0+bit1+bit2+bit3 ; parametry
;         mov       bx,100                   ; minim†ln° velikost bloku
;         call      far ptr CreatDat         ; vytvo©en° datovÇho bloku
;         mov       ds:[DiskInfS],ax         ; segment datovÇho bloku
;         jnc       InitDKm2                 ; segment vytvo©en OK
;         or        byte ptr ds:[DiskInfP],bit2 ; p©i chybà z†kaz z†pisu
;InitDKm1:jmp       InitDKm9
;
;; ------ sestaven° cesty k souboru DISKINFO
;
;InitDKm2:push      ss
;         pop       es
;         mov       di,sp                    ; buffer v z†sobn°ku
;         mov       si,offset FileDInf       ; jmÇno souboru DISKINFO
;         call      far ptr TempFile         ; sestaven° jmÇna souboru
;
;; ------ zji®tàn° atributñ souboru
;
;         mov       si,sp                    ; text jmÇna souboru
;         call      far ptr GetAFile        ; poskytnut° atributñ souboru
;         jc        InitDKm1                 ; soubor nenalezen
;
;; ------ otev©en° souboru pro áten°
;
;         call      far ptr OpenR           ; otev©en° souboru pro áten°
;         jc        InitDKm1                 ; soubor nenalezen
;
;; ------ adresa bufferu
;
;         push      ax
;         mov       ax,ds:[DiskInfS]         ; adresa bufferu
;         call      far ptr GetDat           ; poskytnut° adresy bufferu
;         pop       ax
;         jc        InitDKm1                 ; nàjak† chyba
;
;; ------ naáten° souboru do bufferu
;
;         xchg      cx,bx                    ; CX <- velikost dat, BX <- atributy
;         dec       cx
;         dec       cx                       ; bez £vodn°ho slova dÇlky
;         dec       cx                       ; bez koncovÇho znaku CR
;         mov       di,2                     ; zaá†tek k naáten° dat
;         mov       dx,cx                    ; £schova velikosti dat
;         call      far ptr ReadFile        ; naáten° dat
;         cmp       dx,cx                    ; je soubor naáten celò ?
;         jne       InitDKm3                 ; soubor je nejsp°® naáten celò
;         or        byte ptr ds:[DiskInfP],bit2 ; p©°znak z†kazu z†pisu do soub.
;InitDKm3:inc       cx
;         inc       cx                       ; váetnà £vodn°ho slova
;         mov       si,cx                    ; konec dat v bufferu
;         inc       cx                       ; váetnà koncovÇho znaku CR
;         mov       es:[0],cx                ; velikost dat v bufferu
;         mov       byte ptr es:[si],CR      ; oznaáen° konce posledn°ho ©†dku
;
;; ------ uzav©en° souboru
;
;         call      far ptr ClosFile        ; uzav©en° souboru
;
;; ------ nastaven° p©°znakñ souboru
;
;         or        byte ptr ds:[DiskInfP],bit0 ; p©°znak naáten° souboru
;         test      bl,RO                    ; je z†kaz z†pisu do souboru ?
;         jz        InitDKm4                 ; nen° z†kaz z†pisu do souboru
;         or        byte ptr ds:[DiskInfP],bit2 ; p©°znak z†kazu z†pisu
;
;; ------ zmen®en° datovÇho bloku
;
;InitDKm4:mov       ax,ds:[DiskInfS]         ; adresa bufferu
;         mov       bx,cx                    ; velikost dat v bufferu
;         call      far ptr ModiSegS         ; zmen®en° datovÇho bloku
;
;; ------ vynulov†n° indexovÇ tabulky koment†©ñ
;
;         mov       di,offset DiskInfT       ; indexov† tabulka
;         mov       cx,DiskMax               ; poáet diskñ v tabulce
;         push      ds
;         push      es
;         push      ds
;         pop       es                       ; ES <- datovò segment
;         pop       ds                       ; DS <- segment dat
;         cld
;         xor       ax,ax
;         rep       stosw                    ; vynulov†n° tabulky
;
;; ------ p©°prava k vyhled†v†n° diskñ
;
;         mov       si,2                     ; zaá†tek dat
;         mov       cx,ds:[0]                ; velikost dat v bufferu
;         sub       cx,3                     ; poáet zbylòch dat
;         jbe       InitDKm8                 ; nejsou ë†dn† data
;
;; ------ nalezen° zaá†tku ©†dku
;
;InitDKm5:mov       dx,si                    ; £schova adresy zaá†tku ©†dku
;         jcxz      InitDKm8                 ; nen° dal®° znak
;         lodsb                              ; naáten° znaku
;         dec       cx                       ; sn°ëen° á°taáe znakñ
;         cmp       al,CR
;         je        InitDKm5                 ; pr†zdnò ©†dek se p©eskoá°
;         cmp       al,LF
;         je        InitDKm5                 ; pr†zdnò ©†dek se p©eskoá°
;
;; ------ konverze jmÇna disku na velkÇ p°smeno
;
;         cmp       al,"a"
;         jb        InitDKm6
;         cmp       al,"z"
;         ja        InitDKm6
;         sub       al,32                    ; konverze na velkÇ p°smeno
;
;; ------ test, zda je to platnÇ oznaáen° disku
;
;InitDKm6:sub       al,"A"                   ; konverze na á°slo disku
;         jc        InitDKm7                 ; nen° to platnÇ oznaáen° disku
;         cmp       al,DiskMax               ; je to platnÇ oznaáen° disku ?
;         jae       InitDKm7                 ; nen° to platnÇ oznaáen° disku
;
;; ------ test, zda n†sleduje znak ":"
;
;         jcxz      InitDKm8                 ; nen° dal®° znak
;         cmp       byte ptr ds:[si],":"     ; n†sleduje znak ":" ?
;         jne       InitDKm7                 ; nen° to platnÇ oznaáen° disku
;         and       byte ptr ds:[si-1],not 20h ; konverze na velkÇ p°smeno
;
;; ------ je platnÇ oznaáen° disku - uloëen° adresy ©†dku
;
;         mov       ah,0
;         shl       ax,1                     ; á°slo disku * 2
;         add       ax,offset DiskInfT       ; adresa v tabulce diskñ
;         xchg      ax,bx                    ; BX <- adresa v tabulce diskñ
;         cmp       word ptr es:[bx],0       ; byl jië disk nalezen ?
;         jne       InitDKm7                 ; disk jië byl nalezen
;         mov       es:[bx],dx               ; uloëen° adresy ©†dku
;
;; ------ nalezen° konce ©†dku
;
;InitDKm7:jcxz      InitDKm8                 ; nen° dal®° ©†dek
;         lodsb
;         dec       cx
;         cmp       al,CR
;         je        InitDKm5                 ; konec ©†dku - dal®° ©†dek
;         cmp       al,LF
;         jne       InitDKm7                 ; nen° konec ©†dku
;         jmp       short InitDKm5           ; dal®° ©†dek
;
;InitDKm8:pop       ds                       ; n†vrat datovÇho segmentu
;
;; ------ n†vrat registrñ
;
;InitDKm9:add       sp,FileMax               ; n†vrat SP
;         pop       es
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;InitDKom ENDP

; *****************************************************************************
;                              KonvDN
;               konverze disku na po©adovÇ á°slo v tabulce
; -----------------------------------------------------------------------------
; VSTUP: AL=disk (A:=0,..., DiskMax=historie)
;        DS=datovò segment
; VùSTUP:AL=disk relativnà v tabulce (0=prvn° disk, ...)
; *****************************************************************************

KonvDN   PROC      FAR

         push      si
         push      cx

         xor       cx,cx
         mov       cl,al                    ; poëadovanò disk

         cmp       al,DiskMax               ; je to historie ?
         mov       al,byte ptr ds:[DiskNum] ; disk historie
         jae       KonvDN9                  ; je historie

         xor       al,al
         mov       si,offset DiskITab       ; tabulka diskovòch parametrñ

; ------ nalezen° poëadovanÇho disku

         jcxz      KonvDN9                  ; je to disk A
KonvDN1: cmp       byte ptr ds:[si],0       ; je to platnò disk ?
         je        KonvDN2                  ; nen° platnò disk
         inc       ax                       ; zvò®en° á°sla disku
KonvDN2: inc       si                       ; zvò®en° adresy v tabulce
         loop      KonvDN1                  ; dal®° disk

KonvDN9: pop       cx
         pop       si
         ret

KonvDN   ENDP

; *****************************************************************************
;                            KonvND
;             konverze po©adovÇho á°sla na á°slo disku
; -----------------------------------------------------------------------------
; VSTUP: AL=disk relativnà v tabulce (0=prvn° disk, ...)
;        DS=datovò segment
; VùSTUP:AL=disk (A=0,...)
; *****************************************************************************

KonvND   PROC      FAR

         push      si
         push      cx

         xor       cx,cx
         mov       cl,al                    ; poëadovanò disk
         cmp       al,byte ptr ds:[DiskNum] ; je to platnò disk ?
         mov       al,DiskMax               ; á°slo disku historie
         jae       KonvND9                  ; je historie
         inc       cx                       ; p©ednastaven°
         mov       al,-1
         mov       si,offset DiskITab-1     ; tabulka parametrñ diskñ

; ------ nalezen° disku

KonvND1: inc       ax
         inc       si                       ; zvò®en° adresy v tabulce
         cmp       byte ptr ds:[si],0       ; je to platnò disk ?
         je        KonvND1                  ; neplatnò disk - dal®°
         loop      KonvND1                  ; dal®° disk

KonvND9: pop       cx
         pop       si
         ret

KonvND   ENDP

; *****************************************************************************
;                                TestDisk
;                  test platnosti disku (podle tabulky diskñ)
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo disku 0...
;        DS=datovò segment
; VùSTUP:CY=neplatnò disk
; *****************************************************************************

TestDisk PROC      FAR

         push      ax
         push      bx

         cmp       al,DiskMax               ; kontrola maxim†ln°ho á°sla disku
         jae       TestDsk2                 ; chybnÇ á°slo disku
         mov       ah,0
         xchg      ax,bx                    ; BX <- offset v tabulce diskñ
         cmp       byte ptr ds:[DiskITab+bx],0 ; je disk platnò ?
         jne       TestDsk3                 ; disk je platnò OK
TestDsk2:stc                                ; p©°znak chyby - disk je neplatnò

TestDsk3:pop       bx
         pop       ax
         ret

TestDisk ENDP

; *****************************************************************************
;                               AktADir
;            aktualizace aktivn°ho adres†©e podle aktivn°ho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

AktADir  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es
         push      ds

; ------ p©enesen° textu cesty

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr GetSgAdr         ; poskytnut° adresy aktivn°ho okna
         push      ds
         pop       es                       ; ES <- DS
         mov       ds,dx                    ; segment aktivn°ho okna
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         mov       es:[AktPathN],cx         ; dÇlka textu adres†©e
         mov       si,AWinDir               ; adres†© okna
         mov       di,offset AktPath        ; aktivn° adres†©
         cld
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; p©enesen° textu cesty

; ------ n†vrat registrñ

         pop       ds
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

AktADir  ENDP

; *****************************************************************************
;                                 TestDev
;               test, zda se jedn† o znakovÇ za©°zen° nebo soubor
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru nebo za©°zen°
; VùSTUP: CY=chyba nebo to je soubor
;         NC=znakovÇ za©°zen°
; *****************************************************************************

TestDev  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx

; ------ poskytnut° informac° o za©°zen°

         xchg      ax,bx                    ; BX <- identifik†tor za©°zen°
         mov       ax,4400h
         int       21h                      ; poskytnut° informac° o za©°zen°
         jc        TestDev6                 ; chyba

; ------ rozli®en°, zda se jedn† o znakovÇ za©°zen°

         cmp       dl,80h                   ; je to znakovÇ za©°zen° ?
         jb        TestDev6                 ; je to diskovÇ za©°zen°

; ------ nastaven° bin†rn°ho m¢du pro znakovÇ za©°zen°

         mov       dh,0                     ; DH <- 0
         or        dl,bit5                  ; nastaven° bin†rn°ho m¢du
         mov       ax,4401h
         int       21h                      ; nastaven° bin†rn°ho m¢du
         clc                                ; p©°znak znakovÇho za©°zen°

; ------ n†vrat registrñ

TestDev6:pop       dx
         pop       bx
         pop       ax
         ret

TestDev  ENDP

; *****************************************************************************
;                                ExisFile
;                      Test, zda soubor jië existuje
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru
;        DS=datovò segment
; VùSTUP: CY=chyba nebo soubor neexistuje
;         CX=atributy nalezenÇho souboru nebo adres†©e
; *****************************************************************************

ExisFile PROC      FAR

; ------ nalezen° zadanÇho souboru

         call      far ptr Set0DTA          ; nastaven° pracovn° adresy DTA
         mov       cx,HID+SYS+RO+ARC+DIR    ; atributy - v®echno
         call      far ptr SrcFirst         ; nalezen° souboru
         mov       cl,ds:[BuffDTA+DTAAtrib] ; atributy nalezenÇho souboru
         jc        ExisFil2                 ; chyba
         je        ExisFil2                 ; soubor nalezen OK
         stc                                ; chyba - soubor nenalezen
ExisFil2:call      far ptr SrcClose         ; uzav©en° hled†n°
         ret

ExisFile ENDP

; *****************************************************************************
;                                 SrcFirst
;                   Nalezen° prvn°ho vyhovuj°c°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: CX=atributy souboru
;        ES:SI=specifikace souboru
;        DS=datovò segment
; VùSTUP:CY=chyba (nap©. neplatnò adres†©)
;        ZY=soubor nalezen
;        NZ=soubor nenalezen
; *****************************************************************************

SrcFirst PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ uzav©en° p©°padnÇho starÇho hled†n°

         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[DTALCrea+6],ax ; áas vytvo©en° neplatnò
         mov       word ptr ds:[DTALOpen+6],ax ; áas otev©en° neplatnò
         mov       byte ptr ds:[DTALSNam],al ; zru®en° kr†tkÇho jmÇna
         mov       byte ptr ds:[DTALName],al ; zru®en° dlouhÇho jmÇna
         mov       word ptr ds:[DTALNamN],ax ; zru®en° dlouhÇho jmÇna

; ------ p©°znak, ëe nen° hled†n°

         push      si
         push      es
         les       si,ds:[DTAAdr]           ; adresa aktivn°ho DTA
         mov       word ptr es:[si+DTALIdnt],-1 ; p©°znak neotev©enÇho hled†n°
         pop       es
         pop       si

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SrcFrst9                 ; je p©eru®en° operace

; ------ obsluha hled†n° dlouhòm jmÇnem

         test      byte ptr ds:[Win95Par],bit2 ; jsou dlouh† jmÇna ?
         jnz       SrcFrst4                 ; nejsou dlouh† jmÇna
         mov       al,4eh                   ; á°slo sluëby
         call      SrcFSrc                  ; hled†n° souboru
         jnc       SrcFrs72                 ; soubor nalezen OK
         cmp       al,0                     ; je funkce podporovan† ?
         jne       SrcFrs62                 ; nen° nepodporovan†

; ------ nalezen° souboru nebo adres†©e

SrcFrst4:mov       ah,4eh                   ; funkce nalezen° souboru
SrcFrst5:push      ds
         push      es
         pop       ds                       ; segment adresy se jmÇnem souboru
         mov       dx,si                    ; offset adresy se jmÇnem souboru
         int       21h                      ; nalezen° prvn°ho souboru
         pop       ds

         push      si
         push      es
         les       si,ds:[DTAAdr]           ; adresa aktivn°ho DTA
         mov       word ptr es:[si+DTALIdnt],-1 ; nepouë°v† se dlouhÇ hled†n°
         pop       es
         pop       si

SrcFrst6:jnc       SrcFrst8                 ; operace OK - soubor nalezen

; ------ rozli®en° chyby - zda soubor nebyl nalezen nebo jin† chyba

         cmp       al,0                     ; sluëba nepodporov†na (DOS 7) ?
         je        SrcFrst7                 ; sluëba nepodporov†na
SrcFrs62:cmp       al,2                     ; soubor nenalezen ?
         je        SrcFrst7                 ; soubor nenalezen
         cmp       al,12h                   ; nejsou dal®° soubory ?
         je        SrcFrst7                 ; nen° dal®° soubor

; ------ byla nàjak† chyba (nap©. neplatnò adres†©)

         mov       ds:[LastErr],ax          ; £schova posledn°ho k¢du chyby
         stc                                ; p©°znak chyby operace
         jmp       short SrcFrst9

; ------ soubor nenalezen (k¢dy chyb 2 nebo 12h)

SrcFrst7:or        ax,ax                    ; nastaven° p©°znakñ NC, NZ
         jmp       short SrcFrst9

; ------ soubor nalezen OK

SrcFrs72:push      bx
         push      es
         les       bx,ds:[DTAAdr]           ; adresa aktivn°ho DTA
         mov       word ptr es:[bx+DTALIdnt],ax ; identifik†tor hled†n°
         pop       es
         pop       bx

SrcFrst8:xor       ax,ax                    ; nastaven° p©°znakñ NC, ZY

SrcFrst9:pop       dx
         pop       ax
         ret

SrcFirst ENDP

; *****************************************************************************
;                                  SrcNext
;                    Nalezen° dal®°ho vyhovuj°c°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=chyba
;        ZY=soubor nalezen
;        NZ=soubor nenalezen
; *****************************************************************************

SrcNext  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[DTALCrea+6],ax ; áas vytvo©en° neplatnò
         mov       word ptr ds:[DTALOpen+6],ax ; áas otev©en° neplatnò
         mov       byte ptr ds:[DTALSNam],al ; zru®en° kr†tkÇho jmÇna
         mov       byte ptr ds:[DTALName],al ; zru®en° dlouhÇho jmÇna
         mov       word ptr ds:[DTALNamN],ax ; zru®en° dlouhÇho jmÇna

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SrcFrst9                 ; je p©eru®en° operace

; ------ test, zda je hled†n° dlouhòm jmÇnem

         mov       ah,4fh                   ; funkce nalezen° dal®°ho souboru

         push      bx
         push      es
         les       bx,ds:[DTAAdr]           ; adresa aktivn°ho DTA
         cmp       word ptr es:[bx+DTALIdnt],-1 ; je hled†n° dlouhòm jmÇnem ?
         pop       es
         pop       bx
         je        SrcFrst5                 ; nen° hled†n° dlouhòm jmÇnem

; ------ hled†n° pomoc° dlouhÇho jmÇna

         mov       al,4fh                   ; á°slo sluëby
         push      bx

         push      es
         les       bx,ds:[DTAAdr]           ; adresa aktivn°ho DTA
         mov       bx,word ptr es:[bx+DTALIdnt] ; identifik†tor hled†n°
         pop       es

         call      SrcFSrc                  ; hled†n° dal®°ho souboru
         pop       bx
         jmp       short SrcFrst6           ; chyba nebo OK

SrcNext  ENDP

; ------ hled†n° dlouhÇho jmÇna, sluëba AL -> CY=chyba, AX=k¢d chyby

SrcFSrc  PROC      NEAR

         push      si
         push      di
         push      ds
         push      es

         mov       dx,si                    ; offset adresy se jmÇnem souboru
         mov       si,1                     ; poëadov†n form†t áasu MS-DOS
         stc                                ; p©ednastaven° p©°znaku chyby
         mov       ah,71h
         push      ds
         push      es
         pop       ds                       ; DS <- segment jmÇna
         pop       es                       ; ES <- datovò segment
         mov       di,offset DTALong        ; buffer pro obsluhu dlouhÇho jmÇna
         int       21h                      ; vyhled†n° souboru

         mov       byte ptr es:[DTALName-1],0 ; zru®en° dlouhÇho jmÇna

         pop       es
         pop       ds
         pop       di
         pop       si
         jc        SrcFSrc1                 ; chyba

; ------ test, zda bylo alespo§ kr†tkÇ nebo dlouhÇ jmÇno

         cmp       byte ptr ds:[DTALName],0 ; je dlouhÇ jmÇno ?
         jne       SrcFSrc2                 ; je dlouhÇ jmÇno
         mov       al,0                     ; chyba - neobsluhov†no
         stc                                ; p©°znak chyby
SrcFSrc1:jmp       SrcFSrc9

; ------ konverze novÇho form†tu na starò

SrcFSrc2:push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

         les       di,ds:[DTAAdr]           ; adresa aktivn° DTA
         mov       al,ds:[DTALAtr]          ; novÇ atributy
         mov       es:[di+DTAAtrib],al      ; starÇ atributy

         mov       ax,ds:[DTALSizL]         ; velikost souboru LOW
         mov       word ptr es:[di+DTASize],ax ; velikost souboru
         mov       ax,ds:[DTALSizL+2]
         mov       word ptr es:[di+DTASize+2],ax

         mov       ax,word ptr ds:[DTALModi] ; áas modifikace
         mov       es:[di+DTATime],ax       ; áas modifikace
         mov       ax,word ptr ds:[DTALModi+2] ; datum modifikace
         mov       es:[di+DTADate],ax       ; datum modifikace
;         mov       si,offset DTALModi       ; áas posledn° modifikace souboru
;         call      far ptr SrcFKonv         ; konverze áasu p©i hled†n°
;         mov       es:[di+DTATime],cx       ; áas
;         mov       es:[di+DTADate],dx       ; datum

; ------ p©enos kr†tkÇho jmÇna

         add       di,DTAName               ; buffer jmÇna souboru
         mov       si,offset DTALSNam       ; kr†tkÇ jmÇno souboru
         cmp       byte ptr ds:[si],0       ; je kr†tkÇ jmÇno ?
         jne       SrcFSrc3                 ; je kr†tkÇ jmÇno OK
         mov       si,offset DTALName       ; n†hrada dlouhòm jmÇnem

SrcFSrc3:mov       cx,12                    ; dÇlka jmÇna
         cld
SrcFSr32:lodsb
         call      far ptr UpCase
         stosb
         cmp       al,0
         loopne    SrcFSr32
         mov       al,0
         stosb                              ; oznaáen° konce textu

; ------ nen° to dlouhÇ jmÇno, pokud nebylo kr†tkÇ

         cmp       byte ptr ds:[DTALSNam],0 ; bylo kr†tkÇ jmÇno ?
         jne       SrcFSr36                 ; bylo kr†tkÇ jmÇno
         mov       byte ptr ds:[DTALName],0 ; zru®en° dlouhÇho jmÇna

; ------ dÇlka dlouhÇho jmÇna

SrcFSr36:mov       si,offset DTALName-1     ; dlouhÇ jmÇno
         dec       byte ptr ds:[DTALNamN]
SrcFSrc4:inc       byte ptr ds:[DTALNamN]
         inc       si
         cmp       byte ptr ds:[si],0
         jne       SrcFSrc4

         mov       al,byte ptr ds:[DTALNamN] ; dÇlka jmÇna
         mov       ds:[DTALName-1],al       ; dÇlka jmÇna pro zobrazen°

         clc                                ; p©°znak operace OK
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
SrcFSrc9:ret

SrcFSrc  ENDP

;; *****************************************************************************
;;        konverze poloëky áasu DS:SI na jednotlivÇ sloëky -> DX=datum, CX=áas
;; *****************************************************************************
;
;SrcFKonv PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;
;; ------ odeáten° vòchoz° konstanty pro 1.1.1980 (rozsah: 8 Bajtñ)
;; Poá†tek je 1.1.1601, offset by màl proto bòt 119600064000000000,
;; podle DOS ale vych†z° 119599992000000000 :
;
;         sub       word ptr ds:[si],0b000h  ; 0000
;         sbb       word ptr ds:[si+2],1e4ch ; E1CB
;         sbb       word ptr ds:[si+4],0e78fh ; E7A0
;         sbb       word ptr ds:[si+6],1a8h  ; 01A8
;         jnc       SrcFKnv2                 ; nen° podteáen°
;
;; ------ omezen° p©i podteáen°
;
;         xor       ax,ax                    ; AX <- 0
;         mov       ds:[si],ax
;         mov       ds:[si+2],ax
;         mov       ds:[si+4],ax
;         mov       ds:[si+6],ax
;
;; ------ omezen° á°sla (na asi 130 let) -> rozsah 7 bajtñ
;
;SrcFKnv2:cmp       word ptr ds:[si+6],150
;         jb        SrcFKnv3
;         mov       word ptr ds:[si+6],150
;
;; ------ vydàlen° á°sla / 10000 (tj. na 1 ms) -> rozsah m°rnà p©es 5 bajtñ)
;
;SrcFKnv3:mov       bx,10000
;
;         mov       dx,ds:[si+6]
;         mov       ax,ds:[si+4]
;         div       bx
;         mov       ds:[si+4],ax
;
;         mov       ax,ds:[si+2]
;         div       bx
;         mov       ds:[si+2],ax
;
;         mov       ax,ds:[si]
;         div       bx
;         mov       ds:[si],ax
;
;; ------ vydàlen° á°sla / 1000 (tj. na s) -> rozsah 4 bajty)
;
;         mov       bx,1000
;
;         mov       dx,ds:[si+4]
;         mov       ax,ds:[si+2]
;         div       bx
;         mov       ds:[si+2],ax
;
;         mov       ax,ds:[si]
;         div       bx
;         mov       ds:[si],ax
;
;; ------ vydàlen° á°sla / 60 (tj. na minuty) -> rozsah 4 bajty)
;
;         mov       bx,60
;
;         xor       dx,dx                    ; DX <- 0
;         mov       ax,ds:[si+2]
;         div       bx
;         mov       ds:[si+2],ax
;
;         mov       ax,ds:[si]
;         div       bx
;         mov       ds:[si],ax
;
;         push      dx                       ; £schova sekund
;
;; ------ vydàlen° á°sla / 60 (tj. na hodiny) -> rozsah 3 bajty)
;
;         xor       dx,dx                    ; DX <- 0
;         mov       ax,ds:[si+2]
;         div       bx
;         mov       ds:[si+2],ax
;
;         mov       ax,ds:[si]
;         div       bx
;
;         push      dx                       ; £schova minut
;
;; ------ vydàlen° á°sla / 24 (tj. na dny) -> rozsah 2 bajty
;
;         mov       bl,24
;
;         mov       dx,ds:[si+2]
;         div       bx
;
;         push      dx                       ; £schova hodin
;
;; ------ vòpoáet roku
;
;         xor       dx,dx
;         mov       bx,3*365+366
;         div       bx                       ; p©epoáet na áty©let°
;         shl       ax,1
;         shl       ax,1                     ; korekce na á°slo roku
;         cmp       dx,366
;         jb        SrcFKnv4
;         sub       dx,366
;         inc       ax
;
;SrcFKnv4:cmp       dx,365
;         jb        SrcFKnv5
;         sub       dx,365
;         inc       ax
;
;SrcFKnv5:cmp       dx,365
;         jb        SrcFKnv6
;         sub       dx,365
;         inc       ax
;
;SrcFKnv6:add       ax,1980
;         mov       ds:[si+6],ax             ; rok
;
;; ------ vòpoáet màs°ce a dne
;
;         mov       byte ptr ds:[si+5],0     ; á°taá á°sla màs°ce
;         mov       ah,0
;         mov       bx,offset PoctyDnu       ; tabulka poátu dnñ màs°cñ
;SrcFKnv7:mov       al,ds:[bx]               ; poáet dnñ v màs°ci
;         inc       bx                       ; zvò®en° ukazatele v tabulce
;         cmp       bx,offset PoctyDnu+2     ; je to £nor ?
;         jne       SrcFKnv8                 ; nen° to £nor
;         test      byte ptr ds:[si+6],bit0+bit1 ; je p©estupnò rok ?
;         jnz       SrcFKnv8                 ; nen° p©estupnò rok
;         inc       ax                       ; p©estupnò rok
;SrcFKnv8:inc       byte ptr ds:[si+5]       ; zvò®en° á°sla màs°ce
;         sub       dx,ax                    ; sn°ëen° poátu zbylòch dnñ
;         jae       SrcFKnv7                 ; bude dal®° màs°c
;         add       dx,ax                    ; n†vrat poátu dnñ
;         inc       dx                       ; korekce á°sla dne
;         mov       ds:[si+4],dl             ; á°slo dne
;
;; ------ uloëen° áasu
;
;         pop       ax                       ; hodina
;         mov       ds:[si+3],al             ; hodina
;         pop       ax                       ; minuta
;         mov       ds:[si+2],al             ; minuta
;         pop       ax                       ; sekunda
;         mov       ds:[si+1],al             ; sekunda
;         mov       byte ptr ds:[si],0       ; setiny sekundy
;
;; ------ p©°prava data
;
;         mov       ax,ds:[si+6]             ; rok
;         sub       ax,1980                  ; offset od roku 1980
;         mov       cl,9-5
;         shl       ax,cl                    ; posun roku
;         or        al,ds:[si+5]             ; màs°c
;         mov       cl,5
;         shl       ax,cl                    ; posun màs°ce
;         or        al,ds:[si+4]             ; den
;         xchg      ax,dx                    ; DX <- datum
;
;; ------ p©°prava áasu
;
;         mov       ah,0
;         mov       al,ds:[si+3]             ; hodina
;         mov       cl,11-5
;         shl       ax,cl                    ; posun hodiny
;         or        al,ds:[si+2]             ; minuta
;         mov       cl,5
;         shl       ax,cl                    ; posun minuty
;         mov       cl,ds:[si+1]             ; sekunda
;         shr       cl,1
;         or        al,cl                    ; sekunda
;         xchg      ax,cx                    ; CX <- áas
;
;; ------ n†vrat registrñ
;
;         pop       bx
;         pop       ax
;         ret
;
;SrcFKonv ENDP

; *****************************************************************************
;                                SrcClose
;                 Uzav©en° hled†n° (uchov†v† registr p©°znakñ !)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

SrcClose PROC      FAR

         pushf
         push      ax
         push      bx
         push      si
         push      es

         les       si,ds:[DTAAdr]           ; adresa aktivn°ho DTA
         mov       bx,-1                    ; BX <- -1 p©°znak uzav©en°
         xchg      bx,es:[si+DTALIdnt]      ; BX <- identifik†tor hled†n°
         inc       bx                       ; je hled†n° otev©eno ?
         jz        SrcClos9                 ; hled†n° nen° otev©eno
         dec       bx                       ; n†vrat á°sla identifik†toru

         xor       si,si                    ; SI <- 0
         mov       ax,71a1h
         int       21h                      ; uzav©en° hled†n°

SrcClos9:pop       es
         pop       si
         pop       bx
         pop       ax
         popf
         ret

SrcClose ENDP

; *****************************************************************************
;                              CopCErr
;               chybovÇ hl†®en° - adres†© nelze kop°rovat s†m do sebe
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace adres†©e ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace
; *****************************************************************************

CopCErr  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset CopCErrM       ; chybovÇ hl†®en° - nelze cyklicky
         jmp       short OpenREr1

CopCErr  ENDP

; *****************************************************************************
;                              RenDErr
;               chybovÇ hl†®en° - adres†© nelze p©ejmenovat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace adres†©e ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace
; *****************************************************************************

RenDErr  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset RenDErrM       ; chybovÇ hl†®en° - nelze p©ejmenovat
         jmp       short OpenREr1

RenDErr  ENDP

; *****************************************************************************
;                              CopDErPr
;           chybovÇ hl†®en° - p©episovanò soubor nelze zru®it
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************
;˛
CopDErPr PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset CopyLDPr       ; chybovÇ hl†®en° - nelze zru®it
         jmp       short OpenREr1

CopDErPr ENDP

; *****************************************************************************
;                              CopErEq
;           chybovÇ hl†®en° - kop°ruje se soubor s†m do sebe
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

CopErEq  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset CopErD1        ; chybovÇ hl†®en° - soubor s†m do sebe
         jmp       short OpenREr1

CopErEq  ENDP

; *****************************************************************************
;                              CopDErr
;           chybovÇ hl†®en° - existuje adres†© stejnÇho jmÇna
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

CopDErr  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset CopyLD1        ; chybovÇ hl†®en° - existuje adres†©
         jmp       short OpenREr1

CopDErr  ENDP

; *****************************************************************************
;                              CompWar
;           varovnÇ hl†®en° - porovn†v†n soubor s†m se sebou
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

CompWar  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset ChbCmWr        ; varovnÇ hl†®en° - s†m se sebou
         jmp       short OpenREr1

CompWar  ENDP

; *****************************************************************************
;                              CompErr
;               chybovÇ hl†®en° - porovn†vanò soubor nenalezen
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

CompErr  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset ChbCmEr        ; chybovÇho hl†®en° - soubor nenalezen
         jmp       short OpenREr1

CompErr  ENDP

; *****************************************************************************
;                              WritErr
;               chybovÇ hl†®en° - chyba z†pisu do souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

WritErr  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset ChbWrEr        ; chybovÇho hl†®en° - chyba z†pisu
         jmp       short OpenREr1

WritErr  ENDP

; *****************************************************************************
;                              ReadErr
;               chybovÇ hl†®en° - chyba áten° ze souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

ReadErr  PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset ChbReEr        ; chybovÇho hl†®en° - chyba áten°
         jmp       short OpenREr1

ReadErr  ENDP

; *****************************************************************************
;                              CreatErr
;           chybovÇ hl†®en° - soubor nelze vytvo©it
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

CreatErr PROC      FAR

; ------ £schova registrñ

         push      bx

;         mov       bl,es:[si]               ; disk
;         mov       ds:[CreaED5P],bl         ; disk

         push      si
         xor       bx,bx                    ; BX <- á°taá oddàlovaáñ "\"
CreatEr2:cmp       byte ptr es:[si],"\"
         jne       CreatEr3
         inc       bx                       ; á°taá oddàlovaáñ "\"
CreatEr3:inc       si
         cmp       byte ptr es:[si],0
         jne       CreatEr2
         pop       si

         mov       word ptr ds:[CreaED2P],offset CreaED3P ; nedostatek poloëek ROOT
         dec       bx                       ; byl pr†và 1 oddàlovaá ?
         jz        CreatEr4                 ; byl pr†và 1 oddàlovaá
         mov       word ptr ds:[CreaED2P],offset CreaED4P ; nedostatek m°sta na disku

CreatEr4:mov       bx,offset CreaED1        ; chybovÇ hl†®en° - nelze vytvo©it
         jmp       short OpenREr1

CreatErr ENDP

; *****************************************************************************
;                              OpenRErr
;               chybovÇ hl†®en° - soubor nelze otev©°t
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (jinak pokraáov†n° dal®°m souborem)
; *****************************************************************************

OpenRErr PROC      FAR

; ------ £schova registrñ

         push      bx
         mov       bx,offset ChbOpEr        ; chybovÇho hl†®en° - nelze otev©°t

OpenREr1:push      ax
         push      si
         push      di
         push      dx

; ------ p©°prava jmÇna souboru

OpenREr2:mov       di,offset ChbOpErF+1     ; buffer jmÇna souboru
OpenREr3:mov       al,es:[si]               ; p©ipravenò znak
         inc       si                       ; zvò®en° ukazatele
         cmp       al,0                     ; je konec ©etàzce ?
         je        OpenREr4                 ; je konec ©etàzce
         cmp       al,"\"                   ; je oddàlovaá cesty ?
         je        OpenREr2                 ; je oddàlovaá cesty - od zaá†tku
         cmp       al,":"                   ; je oddàlovaá disku ?
         je        OpenREr2                 ; je oddàlovaá disku - od zaá†tku
         cmp       di,offset ChbOpErF+1+12  ; maxim†ln° konec
         jae       OpenREr3                 ; znak se neuloë°
         mov       ds:[di],al               ; uloëen° znaku
         inc       di
         jmp       short OpenREr3

OpenREr4:sub       di,offset ChbOpErF+1     ; dÇlka jmÇna souboru
         xchg      ax,di
         mov       ds:[ChbOpErF],al         ; dÇlka jmÇna souboru

; ------ chybovÇ hl†®en°

         mov       si,bx                    ; menu chybovÇho hl†®en°
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        OpenREr8                 ; je p©eru®en° operace

         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jnc       OpenREr8                 ; nen° p©eru®en° operace
         call      far ptr SetEsc           ; p©°znak p©eru®en° operace

; ------ n†vrat registrñ

OpenREr8:pop       dx
         pop       di
         pop       si
         pop       ax
         pop       bx
         ret

OpenRErr ENDP

; *****************************************************************************
;                              OpenR
;                   otev©en° souboru pro áten°
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP:CY=chyba (soubor nelze otev©°t)
;        AX=identifik†tor souboru
; *****************************************************************************

OpenR    PROC      FAR

         mov       ax,3d00h                 ; otev©en° pro áten°
         jmp       short OpenRW1            ; otev©en° souboru

OpenR    ENDP

; *****************************************************************************
;                              OpenW
;                   otev©en° souboru pro z†pis
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP:CY=chyba (soubor nelze otev©°t)
;        AX=identifik†tor souboru
; *****************************************************************************

OpenW    PROC      FAR

         mov       ax,3d01h                 ; otev©en° pro z†pis
         jmp       short OpenRW1            ; otev©en° souboru

OpenW    ENDP

; *****************************************************************************
;                            OpenRW
;               otev©en° souboru pro áten° a z†pis
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP:CY=chyba (soubor nelze otev©°t)
;        AX=identifik†tor souboru
; *****************************************************************************

OpenRW   PROC      FAR

         mov       ax,3d02h                 ; otev©en° pro áten° i z†pis

; ------ otev©en° souboru

OpenRW1: cmp       byte ptr ds:[VerzeOS+1],3 ; je verze DOS 3.xx a vy®®° ?
         jb        OpenRW2                  ; je n°zk† verze systÇmu
         or        al,bit6                  ; m¢d sd°len° souborñ bez omezen°

OpenRW2: call      far ptr TestBreak        ; test p©eru®en° operace
         jc        OpenRW3                  ; je p©eru®en° operace

         push      dx
         push      ds
         push      si
         pop       dx                       ; DX <- offset jmÇna souboru
         push      es
         pop       ds                       ; DS <- segment jmÇna souboru
         int       21h                      ; otev©en° souboru
         pop       ds
         pop       dx

; ------ chyba operace

         jnc       OpenRW3                  ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

OpenRW3: ret

OpenRW   ENDP

; *****************************************************************************
;                                ShrtXFil
;                  p©evod dlouhÇho jmÇna souboru na kr†tkÇ
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=buffer s ASCIIZ dlouhòm jmÇnem souboru
;        DS=datovò segment
; VùSTUP: ES:SI=buffer naplnàn ASCIIZ kr†tkòm jmÇnem souboru
;         CX=dÇlka jmÇna souboru v bufferu (plat° i p©i chybà)
;         CY=chyba (soubor nenalezen)
; *****************************************************************************

ShrtXFil PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        ShrtXFl6                 ; je p©eru®en° operace

; ------ p©evod jmÇna souboru

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       ax,7160h                 ; funkce
         mov       cx,8001h                 ; pro SUBST bude logickÇ jmÇno
         mov       di,si                    ; DI <- buffer jmÇna souboru
         int       21h
         pop       ds

; ------ zji®tàn° dÇlka jmÇna souboru -> CX

ShrtXFl6:pushf
         mov       di,si                    ; DI <- buffer jmÇna souboru
         xor       cx,cx
         dec       cx
         mov       al,0
         cld
ShrtXFl8:inc       cx
         scasb
         jne       ShrtXFl8
         popf

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

ShrtXFil ENDP

; *****************************************************************************
;                                CreOXFil
;             vytvo©en°/otev©en° souboru s dlouhòm jmÇnem WINDOWS 95
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru
;        DS=datovò segment
; VùSTUP:AX=identifik†tor novÇho souboru
;        CY=chyba (soubor nelze vytvo©it ani otev©°t)
; *****************************************************************************

CreOXFil PROC      FAR

         push      dx
         mov       dl,11h                   ; vytvo©it/otev©°t
         jmp       short OpenXRW1

CreOXFil ENDP

; *****************************************************************************
;                                CreaXFil
;             vytvo©en°/zkr†cen° souboru s dlouhòm jmÇnem WINDOWS 95
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru
;        DS=datovò segment
; VùSTUP:AX=identifik†tor novÇho souboru
;        CY=chyba (soubor nelze vytvo©it)
; *****************************************************************************

CreaXFil PROC      FAR

         push      dx
         mov       dl,12h                   ; vytvo©it/zkr†tit
         jmp       short OpenXRW1

CreaXFil ENDP

; *****************************************************************************
;                            OpenXRW
;       otev©en° souboru pro áten° a z†pis s dlouhòm jmÇnem WINDOWS 95
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace souboru ASCIIZ
;        DS=datovò segment
; VùSTUP:CY=chyba (soubor nelze otev©°t)
;        AX=identifik†tor souboru
; *****************************************************************************

OpenXRW  PROC      FAR

         push      dx
         mov       dl,01h                   ; otev©°t jen kdyë existuje

OpenXRW1:push      bx
         push      cx

         mov       dh,0
         mov       bx,2+bit6                ; m¢d otev©en°
         xor       cx,cx                    ; atributy

; ------ otev©en° souboru

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        OpenXRW3                 ; je p©eru®en° operace

         push      ds
         push      es
         pop       ds                       ; DS <- segment jmÇna souboru
         mov       ax,716ch
         int       21h                      ; otev©en° souboru
         pop       ds

; ------ chyba operace

         jnc       OpenXRW3                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

OpenXRW3:pop       cx
         pop       bx
         pop       dx
         ret

OpenXRW  ENDP

; *****************************************************************************
;                                CreatFil
;                          vytvo©en° souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru
;        DS=datovò segment
; VùSTUP:AX=identifik†tor novÇho souboru
;        CY=chyba (soubor nelze vytvo©it)
; *****************************************************************************

CreatFil PROC      FAR

; ------ £schova registrñ

         push      cx
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        CreatFl9                 ; je p©eru®en° operace

; ------ vytvo©en° souboru

         push      ds                       ; £schova DS
         push      es
         pop       ds                       ; DS <- jmÇno souboru - segment
         xor       cx,cx                    ; atributy souboru
         mov       dx,si                    ; DX <- jmÇno souboru - offset
         mov       ah,3ch                   ; funkce vytvo©en° souboru
         int       21h                      ; vytvo©en° souboru
         pop       ds                       ; n†vrat DS

; ------ chyba operace

         jnc       CreatFl9                 ; soubor vytvo©en OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

CreatFl9:pop       dx
         pop       cx
         ret

CreatFil ENDP

; *****************************************************************************
;                              CreatTmp
;               vytvo©en° pracovn°ho p©echodnÇho souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=buffer k uloëen° specifikace souboru
;        DS=datovò segment
; VùSTUP: AX=identifik†tor novÇho souboru
;         ES:SI=jmÇno p©echodnÇho souboru (sestavenÇ v bufferu)
;         CY=chyba (soubor nelze vytvo©it)
; *****************************************************************************

CreatTmp PROC      FAR

; ------ £schova registrñ

         push      cx
         push      di
         push      es
         push      si                       ; SI mus° bòt jako posledn° !!!

; ------ nalezen° parametru TEMP

         mov       di,si                    ; DI <- buffer k uloëen° textu
         mov       cx,es                    ; CX <- segment bufferu
         mov       si,offset TempTxt        ; jmÇno parametru "TEMP"
         call      far ptr Get0Env          ; nalezen° parametru TEMP
         jc        CreatTm4                 ; parametr nenalezen

; ------ kopie parametru do bufferu

         push      ds

         push      es
         pop       ds                       ; DS <- segment ©etàzce
         mov       es,cx                    ; ES <- segment bufferu
         mov       cx,FileMax-15            ; maxim†ln° dÇlka adres†©e
         cld
CreatTm2:lodsb
         stosb                              ; p©enesen° znaku
         or        al,al                    ; je konec ©etàzce ?
         loopnz    CreatTm2                 ; p©enesen° textu adres†©e

         pop       ds

; ------ zaji®tàn° koncovÇho "\" a 0

         dec       di                       ; n†vrat na koncovou 0
         dec       di                       ; n†vrat na posledn° znak
         mov       ax,"\"                   ; AL <- "\", AH <- 0
         scasb                              ; je posledn° znak "\" ?
         jne       CreatTm3                 ; nen° koncovò znak "\"
         dec       di                       ; n†vrat na koncovò znak "\"
CreatTm3:stosw                              ; uloëen° koncovÇho "\" a 0

; ------ vytvo©en° p©echodnÇho souboru

         pop       si                       ; adresa bufferu
         push      si
         call      far ptr CreatPF          ; vytvo©en° p©echodnÇho souboru

; ------ n†vrat registrñ

CreatTm4:pop       si
         pop       es
         pop       di
         pop       cx
         jnc       CreatTm8                 ; soubor vytvo©en OK

; ------ p©°prava cesty k domovskÇmu adres†©i

         push      si
         push      di
         mov       di,si                    ; DI <- adresa bufferu
         mov       si,offset TempTxt        ; SI <- text "TEMP"
         call      far ptr TempFile         ; sestaven° cesty k souboru
         pop       di
         pop       si

 ; ----- vytvo©en° p©echodnÇho souboru

         call      far ptr CreatPF          ; vytvo©en° p©echodnÇho souboru
CreatTm8:ret

CreatTmp ENDP

; *****************************************************************************
;                                CreatPF
;                    vytvo©en° p©echodnÇho souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno adres†©e koná°c° "\" (p©°padnò soubor na konci se ignoruje)
;        DS=datovò segment
; VùSTUP:AX=identifik†tor novÇho souboru
;        ES:SI=jmÇno novÇho souboru (p©ipojeno ke jmÇnu adres†©e)
;        CY=chyba (soubor nelze vytvo©it)
; *****************************************************************************

CreatPF  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      di

; ------ nalezen° konce jmÇna adres†©e -> ES:BX

         mov       di,si                    ; DI <- ukazatel textu cesty
CreatPF1:mov       bx,di                    ; ukazatel konce adres†©e
CreatPF2:cmp       byte ptr es:[di],0       ; je konec jmÇna ?
         je        CreatPF4                 ; je konec jmÇna
         cmp       byte ptr es:[di],"\"     ; oddàlovaá cesty ?
         jne       CreatPF3                 ; nen° oddàlovaá cesty
         mov       bx,di                    ; adresa konce textu
CreatPF3:inc       di                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[di-1],":"   ; je oddàlovaá disku ?
         jne       CreatPF2                 ; nen° oddàlovaá disku
         jmp       short CreatPF1

CreatPF4:mov       word ptr es:[bx],"\"     ; oddàlovaá cesty + konec (0)

; ------ rozli®en° podle verze operaán°ho systÇmu

         cmp       word ptr ds:[VerzeOS],300h ; je verze 3.00 nebo vy®®° ?
         jae       CreatPF8                 ; verze je OK

; ------ p©°prava vlastn°ho jmÇna souboru

         mov       di,bx                    ; DI <- adresa konce cesty
         inc       di                       ; ukazatel za znak "\"
         mov       ax,"00"
         cld
         stosw
         stosw
         stosw
         stosw                              ; nyn° je ukazatel na koncovou "."
         mov       word ptr es:[di],"$."
         mov       word ptr es:[di+2],"$"

; ------ zvò®en° jmÇna souboru

CreatPF5:push      di
CreatPF6:dec       di
         inc       byte ptr es:[di]         ; zvò®en° znaku
         cmp       byte ptr es:[di],"9"
         jbe       CreatPF7
         mov       byte ptr es:[di],"0"     ; p©eteáen° na znak "0"
         jmp       short CreatPF6           ; dal®° znak
CreatPF7:pop       di

; ------ test, zda soubor existuje (poskytnut°m atributñ souboru)

         call      far ptr GetAFile         ; poskytnut° atributñ souboru
         jnc       CreatPF5                 ; soubor existuje - dal®° pokus
         mov       word ptr ds:[LastErr],0  ; zru®en° p©°znaku chyby

; ------ vytvo©en° novÇho souboru

         call      far ptr CreatFil         ; vytvo©en° souboru
         jmp       short CreatPF9

; ------ test p©eru®en° operace

CreatPF8:call      far ptr TestBreak        ; test p©eru®en° operace
         jc        CreatPF9                 ; je p©eru®en° operace

; ------ vytvo©en° p©echodnÇho souboru

         push      ds                       ; £schova DS
         push      es
         pop       ds                       ; DS <- jmÇno souboru - segment
         xor       cx,cx                    ; atributy souboru
         mov       dx,si                    ; DX <- jmÇno souboru - offset
         mov       ah,5ah                   ; funkce vytvo©en° p©echod. souboru
         int       21h                      ; vytvo©en° p©echodnÇho souboru
         pop       ds                       ; n†vrat DS

; ------ chyba operace

         jnc       CreatPF9                 ; soubor vytvo©en OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

CreatPF9:pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

CreatPF  ENDP

; *****************************************************************************
;                            SetUFile
;              nastaven° ukazatele souboru na zadanou pozici
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        DX:CX=ukazatel v souboru
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

SetUFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SetUFil2                 ; je p©eru®en° operace

; ------ nastaven° ukazatele na zadanou pozici

         xchg      cx,dx
         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,4200h                 ; funkce p©esunut° na zaá†tek
         int       21h                      ; p©esunut° ukazatele na zaá†tek

; ------ p©°padn† chyba operace

         jnc       SetUFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

SetUFil2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetUFile ENDP

; *****************************************************************************
;                               GetUFile
;                    poskytnut° ukazatele souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        DS=datovò segment
; VùSTUP:CY=chyba operace
;        DX:CX=ukazatel v souboru
; *****************************************************************************

GetUFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        GetUFil2                 ; je p©eru®en° operace

; ------ poskytnut° ukazatele

         xor       cx,cx
         xor       dx,dx
         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,4201h                 ; funkce p©esunut° na zaá†tek
         int       21h                      ; p©esunut° ukazatele na zaá†tek
         mov       cx,ax

; ------ p©°padn† chyba operace

         jnc       GetUFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

GetUFil2:pop       bx
         pop       ax
         ret

GetUFile ENDP


; *****************************************************************************
;                            ResFile
;                resetov†n° ukazatele souboru na zaá†tek
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

ResFile  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        ResFile2                 ; je p©eru®en° operace

; ------ nastaven° ukazatele na zaá†tek souboru

         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,4200h                 ; funkce p©esunut° na zaá†tek
         xor       cx,cx                    ; offset od zaá†tku HIGH = 0
         xor       dx,dx                    ; offset od zaá†tku LOW = 0
         int       21h                      ; p©esunut° ukazatele na zaá†tek

; ------ p©°padn† chyba operace

         jnc       ResFile2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

ResFile2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ResFile  ENDP

; *****************************************************************************
;                            SizeFile
;                   poskytnut° velikosti souboru
;         Ukazatel souboru nech† nastaven na konec souboru !!!
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        DS=datovò segment
; VùSTUP:BX:CX=velikost souboru
;        CY=chyba operace
; *****************************************************************************

SizeFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SizeFil2                 ; je p©eru®en° operace

; ------ poskytnut° velikosti souboru

         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,4202h                 ; funkce p©esunut° na konec souboru
         xor       cx,cx                    ; offset od konce HIGH = 0
         xor       dx,dx                    ; offset od konce LOW = 0
         int       21h                      ; p©esunut° ukazatele na konec soub.
         mov       bx,dx                    ; velikost HIGH
         mov       cx,ax                    ; velikost LOW

; ------ p©°padn† chyba operace

         jnc       SizeFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

SizeFil2:pop       dx
         pop       ax
         ret

SizeFile ENDP

; *****************************************************************************
;                               Read0Fil
;                       nucenÇ áten° dat ze souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        CX=poáet bajtñ ke áten°
;        ES:DI=adresa k naáten° dat
;        DS=datovò segment
; VùSTUP: CY=chyba operace nebo poáet naátenòch bajtñ neodpov°d†
; *****************************************************************************

Read0Fil PROC      FAR

         push      bx
         mov       bx,cx                    ; BX <- poáet poëadovanòch bajtñ
         call      far ptr ReadFile         ; naáten° dat ze souboru
         jc        Read0Fl8                 ; byla chyba operace
         cmp       bx,cx                    ; souhlas° poáet naátenòch bajtñ ?
         je        Read0Fl8                 ; poáet bajtñ souhlas° OK
         stc                                ; p©°znak chyby
Read0Fl8:pop       bx
         ret

Read0Fil ENDP

; *****************************************************************************
;                              ReadFile
;                      áten° dat ze souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        CX=poáet bajtñ ke áten°
;        ES:DI=adresa k naáten° dat
;        DS=datovò segment
; VùSTUP:CX=poáet skuteánà naátenòch bajtñ dat (p©i CY je CX=0)
;        CY=chyba operace
; *****************************************************************************

ReadFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        ReadFil1                 ; je p©eru®en° operace

; ------ naáten° bloku dat

         push      ds
         push      es
         pop       ds                       ; DS <- segment adresy bufferu
         mov       bx,ax                    ; identifik†tor souboru
         mov       ah,3fh                   ; funkce áten° ze souboru
         mov       dx,di                    ; DX <- offset adresy bufferu
         int       21h                      ; naáten° bloku dat
         pop       ds

; ------ stanoven° poátu naátenòch dat

         mov       cx,ax                    ; poáet skuteánà naátenòch dat
         jnc       ReadFil2                 ; operace probàhla OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby
ReadFil1:mov       cx,0                     ; poáet naátenòch bajtñ = 0

; ------ n†vrat registrñ

ReadFil2:pop       dx
         pop       bx
         pop       ax
         ret

ReadFile ENDP


; *****************************************************************************
;                               WritFile
;                        z†pis dat do souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        CX=poáet bajtñ k z†pisu
;        ES:SI=adresa dat k z†pisu
;        DS=datovò segment
; VùSTUP:CY=chyba operace (nap©. disk plnò)
;        CX=poáet skuteánà zapsanòch bajtñ
; *****************************************************************************

WritFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        WritFil2                 ; je p©eru®en° operace

; ------ z†pis bloku dat

         push      cx
         push      ds
         push      es
         pop       ds                       ; segment adresy bufferu
         xchg      ax,bx                    ; BX <- identifik†tor souboru
         mov       ah,40h                   ; funkce áten° ze souboru
         mov       dx,si                    ; offset adresy bufferu
         int       21h                      ; z†pis bloku dat
         pop       ds
         pop       cx

; ------ kontrola, zda operace probàhla v po©†dku

         jc        WritFil1                 ; byla chyba operace
         cmp       ax,cx                    ; byla zaps†na v®echna data ?
         jae       WritFil4                 ; zaps†no v®e OK (CX=poáet bajtñ)
         xchg      ax,cx                    ; CX <- skuteánà zapsan† data
         mov       word ptr ds:[LastErr],Err_PLny_Disk ; chyba - disk je plnò
         jmp       short WritFil3

WritFil1:mov       ds:[LastErr],ax          ; £schova k¢du chyby
WritFil2:xor       cx,cx                    ; nic se nezapsalo
WritFil3:stc                                ; p©°znak chyby operace

; ------ n†vrat registrñ

WritFil4:pop       dx
         pop       bx
         pop       ax
         ret

WritFile ENDP

; *****************************************************************************
;                                 SetDTDir
;                     nastaven° data a áasu adres†©e
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=specifikace ASCII jmÇna adres†©e
;        CX=áas adres†©e   bit 0 aë bit 4 = (sekunda/2)
;                          bit 5 aë bit 10 = minuta
;                          bit 11 aë bit 15 = hodina
;        DX=datum adres†©e bit 0 aë bit 4 = den
;                          bit 5 aë bit 8 = màs°c
;                          bit 9 aë bit 15 = (rok-1980)
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

SetDTDir PROC      FAR

; ------ test, zda je povoleno dlouhÇ jmÇno

         test      byte ptr ds:[Win95Par],bit2 ; jsou dlouh† jmÇna ?
         stc                                ; p©°znak chyby operace
         jnz       SetDTDr9                 ; nen° dlouhÇ jmÇno

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ £schova atributñ adres†©e (p©i pr†ci v s°ti se atributy zniá°)

         xchg      ax,cx                    ; AX <- poëadovanò áas adres†©e
         call      far ptr GetAFile         ; naáten° atributñ souboru
         xchg      ax,cx                    ; AX <- atributy, CX <- áas adres†©e

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SetDTDr8                 ; je p©eru®en° operace

; ------ nastaven° data a áasu adres†©e

         push      ax                       ; £schova pñvodn°ch atributñ
         push      si
         push      ds

         push      es
         pop       ds                       ; DS <- segment jmÇna souboru
         mov       di,dx                    ; DI <- poëadovanÇ datum adres†©e
         mov       dx,si                    ; DX <- offset jmÇna souboru
         mov       ax,7143h                 ; funkce nastaven° data a áasu
         mov       bl,3                     ; podfunkce - nastaven° pro adres†©
         xor       si,si                    ; SI <- 0
         int       21h                      ; nastaven° data a áasu adres†©e

         pop       ds
         pop       si
         pop       cx                       ; CX <- pñvodn° atributy adres†©e

; ------ chyba operace

         jnc       SetDTDr6                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat pñvodn°ch atributñ adres†©e CX

SetDTDr6:pushf
         call      far ptr SetAFile         ; n†vrat pñvodn°ch atributñ
         popf

; ------ n†vrat registrñ

SetDTDr8:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
SetDTDr9:ret

SetDTDir ENDP

; *****************************************************************************
;                             GetDFile
;                    poskytnut° data a áasu souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        DS=datovò segment
; VùSTUP:CY=chyba operace
;        CX=áas souboru    bit 0 aë bit 4 = (sekunda/2)
;                          bit 5 aë bit 10 = minuta
;                          bit 11 aë bit 15 = hodina
;        DX=datum souboru  bit 0 aë bit 4 = den
;                          bit 5 aë bit 8 = màs°c
;                          bit 9 aë bit 15 = (rok-1980)
; *****************************************************************************

GetDFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        GetDFil2                 ; je p©eru®en° operace

; ------ poskytnut° data a áasu souboru

         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,5700h                 ; funkce poskytnut° data a áasu
         int       21h                      ; poskytnut° data a áasu souboru

; ------ chyba operace

         jnc       GetDFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

GetDFil2:pop       bx
         pop       ax
         ret

GetDFile ENDP

; *****************************************************************************
;                             SetDFile
;                     nastaven° data a áasu souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        CX=áas souboru    bit 0 aë bit 4 = (sekunda/2)
;                          bit 5 aë bit 10 = minuta
;                          bit 11 aë bit 15 = hodina
;        DX=datum souboru  bit 0 aë bit 4 = den
;                          bit 5 aë bit 8 = màs°c
;                          bit 9 aë bit 15 = (rok-1980)
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

SetDFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SetDFil2                 ; je p©eru®en° operace

; ------ nastaven° data a áasu souboru

         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,5701h                 ; funkce nastaven° data a áasu
         int       21h                      ; nastaven° data a áasu souboru

; ------ chyba operace

         jnc       SetDFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

SetDFil2:pop       bx
         pop       ax
         ret

SetDFile ENDP

; *****************************************************************************
;                             GetAFile
;                 poskytnut° atributñ souboru/adres†©e
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru/adres†©e ASCIIZ
;        DS=datovò segment
; VùSTUP:CY=chyba operace
;        CX=atributy souboru
;              bit 0: R/O
;              bit 1: HID
;              bit 2: SYS
;              bit 3: VOL
;              bit 4: DIR
;              bit 5: ARC
; *****************************************************************************

GetAFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        GetAFil2                 ; je p©eru®en° operace

; ------ poskytnut° atributñ souboru/adres†©e

         push      ds
         push      es
         pop       ds                       ; segment jmÇna souboru
         mov       dx,si                    ; offset jmÇna souboru
         mov       ax,4300h                 ; funkce poskytnut° atributñ
         int       21h                      ; poskytnut° atributñ
         pop       ds

; ------ chyba operace

         jnc       GetAFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

GetAFil2:pop       dx
         pop       ax
         ret

GetAFile ENDP

; *****************************************************************************
;                             SetAFile
;                 nastaven° atributñ souboru/adres†©e
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru/adres†©e ASCIIZ
;        DS=datovò segment
;        CL=atributy souboru
;              bit 0: R/O
;              bit 1: HID
;              bit 2: SYS
;              bit 3: VOL
;              bit 4: DIR (zde se neprojev°)
;              bit 5: ARC
; VùSTUP:CY=chyba operace
; *****************************************************************************

SetAFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SetAFil2                 ; je p©eru®en° operace

; ------ nastaven° atributñ souboru/adres†©e

         push      ds
         push      es
         pop       ds                       ; segment jmÇna souboru
         mov       dx,si                    ; offset jmÇna souboru
         and       cl,not bit4              ; zru®en° bitu adres†©e
         mov       ch,0                     ; CH <- 0
         mov       ax,4301h                 ; funkce nastaven° atributñ
         int       21h                      ; nastaven° atributñ
         pop       ds

; ------ chyba operace

         jnc       SetAFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

SetAFil2:pop       dx
         pop       cx
         pop       ax
         ret

SetAFile ENDP

; *****************************************************************************
;                             SetXAFil
;            nastaven° atributñ souboru/adres†©e s dlouhòm jmÇnem
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru/adres†©e ASCIIZ
;        DS=datovò segment
;        CL=atributy souboru
;              bit 0: R/O
;              bit 1: HID
;              bit 2: SYS
;              bit 3: VOL
;              bit 4: DIR (zde se neprojev°)
;              bit 5: ARC
; VùSTUP:CY=chyba operace
; *****************************************************************************

SetXAFil PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SetXAFl2                 ; je p©eru®en° operace

; ------ nastaven° atributñ souboru/adres†©e

         push      ds
         push      es
         pop       ds                       ; segment jmÇna souboru
         mov       dx,si                    ; offset jmÇna souboru
         and       cl,not bit4              ; zru®en° bitu adres†©e
         mov       ch,0
         mov       ax,7143h                 ; funkce nastaven° atributñ
         mov       bl,1                     ; nastaven° atributñ
         xor       si,si                    ; SI <- 0
         int       21h                      ; nastaven° atributñ
         pop       ds

; ------ chyba operace

         jnc       SetXAFl2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

SetXAFl2:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetXAFil ENDP

; *****************************************************************************
;                                RenFile
;                          p©ejmenov†n° souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=pñvodn° jmÇno souboru k p©ejmenov†n° (ASCIIZ)
;        DX:DI=novÇ jmÇno souboru (lze i jinò adres†©, ale stejnò disk)
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

RenFile  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      es

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        RenFile2                 ; je p©eru®en° operace

; ------ p©ejmenov†n° souboru

         push      ds
         push      es
         pop       ds                       ; segment pñvodn°ho jmÇna souboru
         mov       es,dx                    ; segment novÇho jmÇna souboru
         mov       dx,si                    ; offset pñvodn°ho jmÇna souboru
         mov       ah,56h
         int       21h                      ; p©ejmenov†n° souboru
         pop       ds

; ------ chyba operace

         jnc       RenFile2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

RenFile2:pop       es
         pop       dx
         pop       ax
         ret

RenFile  ENDP

; *****************************************************************************
;                                RenXFile
;             p©ejmenov†n° souboru s dlouhòm jmÇnem WINDOWS 95
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=pñvodn° jmÇno souboru k p©ejmenov†n° (ASCIIZ)
;        DX:DI=novÇ jmÇno souboru (lze i jinò adres†©, ale stejnò disk)
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

RenXFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si
         push      es

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        RenXFil2                 ; je p©eru®en° operace

; ------ p©ejmenov†n° souboru

         push      ds
         push      es
         pop       ds                       ; segment pñvodn°ho jmÇna souboru
         mov       es,dx                    ; segment novÇho jmÇna souboru
         mov       dx,si                    ; offset pñvodn°ho jmÇna souboru
         mov       ax,7156h
         xor       si,si
         stc
         int       21h                      ; p©ejmenov†n° souboru
         pop       ds

; ------ chyba operace

         jnc       RenXFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

RenXFil2:pop       es
         pop       si
         pop       dx
         pop       ax
         ret

RenXFile ENDP

; *****************************************************************************
;                               DelDir
;                   zru®en° adres†©e (mus° bòt pr†zdnò)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno adres†©e ASCIIZ
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

DelDir   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        DelDir2                  ; je p©eru®en° operace

; ------ zru®en° adres†©e

         push      ds
         push      es
         pop       ds                       ; segment jmÇna adres†©e
         mov       dx,si                    ; offset jmÇna adres†©e
         mov       ah,3ah
         int       21h                      ; zru®en° adres†©e
         pop       ds

; ------ chyba operace

         jnc       DelDir2                  ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

DelDir2: pop       dx
         pop       ax
         ret

DelDir   ENDP

; *****************************************************************************
;                               DelFile
;                           zru®en° souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru ASCIIZ
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

DelFile  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        DelFile2                 ; je p©eru®en° operace

; ------ zru®en° souboru

         push      ds
         push      es
         pop       ds                       ; segment jmÇna souboru
         mov       dx,si                    ; offset jmÇna souboru
         mov       ah,41h
         int       21h                      ; zru®en° souboru
         pop       ds

; ------ chyba operace

         jnc       DelFile2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

DelFile2:pop       dx
         pop       ax
         ret

DelFile  ENDP

; *****************************************************************************
;                              FlshFile
;                p©echodnÇ uzav©en° souboru (vypr†zdnàn°)
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru (0 se neuzav°r†)
;        DS=datovò segment
; VùSTUP:CY=chyba operace
; *****************************************************************************

FlshFile PROC      FAR

         push      ax
         push      bx

         or        ax,ax                    ; je platnò soubor ?
         jz        FlshFil8                 ; soubor 0 se neuzav©e

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        FlshFil8                 ; je p©eru®en° operace

         xchg      ax,bx                    ; BX <- identifik†tor souboru

         cmp       word ptr ds:[VerzeOS],3*HI + 30 ; je verze 3.30 a vy®®° ?
         mov       ah,68h                   ; funkce vypr†zdàn° bufferñ souboru
         jae       FlshFil6                 ; je dostateán† verze systÇmu

         mov       ah,45h
         int       21h                      ; zdvojen° identifik†toru souboru
         jc        FlshFil7                 ; nàjak† chyba

         xchg      ax,bx                    ; zduplik. identifik†tor souboru
         mov       ah,3eh
FlshFil6:int       21h                      ; uzav©en° souboru
         jnc       FlshFil8                 ; operace OK

FlshFil7:mov       ds:[LastErr],ax          ; £schova k¢du chyby

FlshFil8:pop       bx
         pop       ax
         ret

FlshFile ENDP

; *****************************************************************************
;                              ClosFile
;                         uzav©en° souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru (0 se neuzav°r†)
;        DS=datovò segment
; VùSTUP:CY=chyba operace
;        AX=0
; *****************************************************************************

ClosFile PROC      FAR

         push      bx

         or        ax,ax                    ; je platnò soubor ?
         jz        ClosFil2                 ; soubor 0 se neuzav©e

         mov       bx,ax                    ; identifik†tor souboru
         mov       ah,3eh                   ; identifik†tor souboru
         int       21h                      ; uzav©en° souboru
         jnc       ClosFil2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

ClosFil2:pop       bx
         mov       ax,0
         ret

ClosFile ENDP

; *****************************************************************************
;                             CreaLDir
;  vytvo©en° dlouhÇho adres†©e (o v°ce stupn°ch) (mñëe posouvat segmenty !!!)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poëadovanò novò adres†© ASCIIZ (pokud jië existuje, je v®e OK)
;              (nesm° bòt v posouvatelnÇm segmentu !)
;        CL=poëadovanÇ atributy vytv†©enòch adres†©ñ (0=nenastavuj° se)
;        DS=datovò segment
; VùSTUP:CY=chyba
; *****************************************************************************

CreaLDir PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di
         mov       bl,cl                    ; poëadovanÇ atributy

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        CreaLDr9                 ; je p©eru®en° operace

; ------ test, zda poëadovanò adres†© jië existuje

         call      far ptr ExisFile         ; test, zda adres†© existuje
         jc        CreaLDr2                 ; nàjak† chyba - zat°m nevad°
         test      cl,DIR                   ; je to adres†© ?
         jnz       CreaLDr9                 ; je to adres†© - to je OK
         mov       word ptr ds:[LastErr],Err_Exst_File ; chyba - je jië soubor
         stc                                ; p©°znak chyby
         jmp       short CreaLDr9           ; je to soubor - chyba

; ------ p©eskoáen° oznaáen° disku a adres†©e ROOT

CreaLDr2:mov       di,si                    ; zaá†tek textu
         cmp       byte ptr es:[di],0       ; je nàco zad†no ?
         je        CreaLDr9                 ; nen° nic zad†no - nic se nedàje
         cmp       byte ptr es:[di+1],":"   ; je oznaáen° disku ?
         jne       CreaLDr3                 ; nen° oznaáen° disku
         inc       di
         inc       di                       ; p©eskoáen° oznaáen° disku
CreaLDr3:cmp       byte ptr es:[di],"\"     ; zaá°n† adres†©em ROOT ?
         jne       CreaLDr4                 ; nezaá°n† adres†©em ROOT
         inc       di                       ; p©eskoáen° oznaáen° ROOT

; ------ nalezen° dal®°ho oddàlovaáe adres†©e

CreaLDr4:inc       di                       ; zvò®en° ukazatele textu
         mov       al,es:[di]               ; dal®° znak
         cmp       al,0                     ; konec textu ?
         je        CreaLDr5                 ; konec textu
         cmp       al,"\"                   ; oddàlovaá adres†©e ?
         jne       CreaLDr4                 ; nen° oddàlovaá adres†©e - dal®°
CreaLDr5:mov       byte ptr es:[di],0       ; p©echodnÇ oznaáen° konce adres†©e

; ------ test, zda á†steánò adres†© jië existuje (ES:DI=uschovanò znak AL)

         call      far ptr ExisFile         ; test, zda adres†© existuje
         jc        CreaLDr7                 ; nàjak† chyba - zat°m nevad°
         test      cl,DIR                   ; je to adres†© ?
         jnz       CreaLDr8                 ; je to adres†© - to je OK
         mov       word ptr ds:[LastErr],Err_Exst_File ; chyba - je jië soubor
         stc                                ; p©°znak chyby
         jmp       short CreaLDr8           ; je to soubor - chyba

; ------ pokus o vytvo©en° á†steánÇho adres†©e (je aktualizace oken)

CreaLDr7:call      far ptr CreatDir         ; vytvo©en° adres†©e
         jc        CreaLDr8                 ; chyba

; ------ nastaven° atributñ vytvo©enÇho adres†©e

         mov       cl,bl                    ; poëadovanÇ atributy
         mov       ch,0
         jcxz      CreaLDr8                 ; atributy se nenastav° (zde je NC)
         call      far ptr SetAFile         ; nastaven° atributñ adres†©e

; ------ pokraáov†n° dal®°m podadres†©em

CreaLDr8:mov       byte ptr es:[di],al      ; n†vrat znaku
         jc        CreaLDr9                 ; byla nàjak† chyba
         cmp       al,0                     ; byl to jië konec adres†©e ?
         jne       CreaLDr4                 ; vytvo©en° dal®°ho podadres†©e

; ------ n†vrat registrñ

CreaLDr9:pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

CreaLDir ENDP

; *****************************************************************************
;                            CreatDir
;           vytvo©en° novÇho adres†©e (mñëe posouvat segmenty !!!)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poëadovanò novò adres†© (nesm° bòt v posouvatelnÇm segmentu !)
;        DS=datovò segment
; VùSTUP:CY=chyba
; *****************************************************************************

CreatDir PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        CreatDr4                 ; p©eru®en° operace BREAK

; ------ vytvo©en° poëadovanÇho adres†©e

         push      si
         pop       dx                       ; DX <- offset jmÇna adres†©e
         push      ds                       ; £schova DS
         push      es
         pop       ds                       ; DS <- segment jmÇna adres†©e
         mov       ah,39h
         int       21h                      ; vytvo©en° poëadovanÇho adres†©e
         pop       ds                       ; n†vrat DS

; ------ chyba operace

         jnc       CreatDr2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby
         jmp       short CreatDr4

; ------ aktualizace obsahñ oken

CreatDr2:call      far ptr ModAWDir         ; modifikace adres†©e/souboru ES:SI

; ------ n†vrat registrñ

CreatDr4:pop       dx
         pop       ax
         ret

CreatDir ENDP

; *****************************************************************************
;                            CreaXDir
;     vytvo©en° novÇho adres†©e s dlouhòm jmÇnem (mñëe posouvat segmenty !!!)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poëadovanò novò adres†© (nesm° bòt v posouvatelnÇm segmentu !)
;        DS=datovò segment
; VùSTUP:CY=chyba
; *****************************************************************************

CreaXDir PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        CreaXDr4                 ; p©eru®en° operace BREAK

; ------ vytvo©en° poëadovanÇho adres†©e

         mov       dx,si                    ; DX <- offset jmÇna adres†©e
         push      si
         push      ds                       ; £schova DS
         push      es
         pop       ds                       ; DS <- segment jmÇna adres†©e
         mov       ax,7139h
         xor       si,si
         stc
         int       21h                      ; vytvo©en° poëadovanÇho adres†©e
         pop       ds                       ; n†vrat DS
         pop       si

; ------ chyba operace

         jnc       CreaXDr2                 ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby
         jmp       short CreaXDr4

; ------ aktualizace obsahñ oken

CreaXDr2:call      far ptr ModAWDir         ; modifikace adres†©e/souboru ES:SI

; ------ n†vrat registrñ

CreaXDr4:pop       dx
         pop       ax
         ret

CreaXDir ENDP

; *****************************************************************************
;                             GetDisk
;                      Poskytnut° aktivn°ho disku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:AL=aktivn° disk
; *****************************************************************************

GetDisk  PROC      FAR

         push      dx
         push      ax
         mov       ah,19h                   ; funkce poskytnut° aktivn°ho disku
         int       21h                      ; poskytnut° aktivn°ho disku
         mov       dl,al                    ; á°slo aktivn°ho disku
         pop       ax
         mov       al,dl                    ; á°slo aktivn°ho disku
         pop       dx
         ret

GetDisk  ENDP

; *****************************************************************************
;                             SetDisk
;                    Nastaven° aktivn°ho disku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo poëadovanÇho disku
;        DS=datovò segment
; VùSTUP:CY=neplatnÇ á°slo disku
; *****************************************************************************

SetDisk  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         mov       dl,al                    ; poëadovanò novò disk

; ------ £schova pñvodn°ho aktivn°ho disku

         call      far ptr GetDisk         ; poskytnut° aktivn°ho disku
         mov       dh,al                    ; á°slo pñvodn°ho aktivn°ho disku

; ------ nastaven° poëadovanÇho disku

         mov       ah,0eh                   ; funkce nastaven° novÇho disku
         int       21h                      ; nastaven° novÇho disku

; ------ kontrola, zda byl disk nastaven

         call      far ptr GetDisk         ; poskytnut° aktivn°ho disku
         cmp       al,dl                    ; byl disk spr†vnà nastaven ?
         jne       SetDisk4                 ; chyba - disk nebyl nastaven

; ------ kontrola, zda je platnò disk sluëbou IOCTL

         cmp       word ptr ds:[VerzeOS],300h ; je verze systÇmu alespo§ 3.00 ?
         cmc
         jnc       SetDisk5                 ; n°zk† verze systÇmu - z©ejmà OK
         mov       bl,dl                    ; á°slo disku
         inc       bx                       ; korekce á°sla disku
         mov       ax,4408h                 ; funkce poskytnut° typu disku
         int       21h                      ; poskytnut° typu disku
         cmp       al,0fh                   ; chyba - neplatnò disk ?
         clc
         jne       SetDisk5                 ; disk je OK

; ------ neplatnò disk - navr†cen° pñvodn°ho disku

SetDisk4:mov       dl,dh                    ; pñvodn° aktivn° disk
         mov       ah,0eh                   ; funkce nastaven° aktivn°ho disku
         int       21h                      ; nastaven° pñvodn°ho aktiv. disku
         stc                                ; p©°znak chyby - neplatnò disk

; ------ n†vrat registrñ

SetDisk5:pop       dx
         pop       bx
         pop       ax
         ret

SetDisk  ENDP

; *****************************************************************************
;                            GetADir
;             poskytnut° aktivn°ho adres†©e aktivn°ho disku
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=buffer 67 B k naáten° adres†©e (s diskem)
;        DS=datovò segment
; VùSTUP:CY=chyba
;        CX=poáet bajtñ
; *****************************************************************************

GetADir  PROC      FAR

         push      ax
         call      far ptr GetDisk         ; poskytnut° aktivn°ho disku
         call      far ptr GetDir          ; poskytnut° aktivn°ho adres†©e
         pop       ax
         ret

GetADir  ENDP

; *****************************************************************************
;                            GetDir
;            poskytnut° aktivn°ho adres†©e disku (i s diskem)
; -----------------------------------------------------------------------------
; VSTUP: AL=poëadovanò disk, jehoë adres†© se m† poskytnout
;        ES:DI=adresa bufferu 67 B k naáten° adres†©e (tvar ASCIIZ s diskem)
;        DS=datovò segment
; VùSTUP:CY=chyba (neplatnò disk nebo disk nen° p©ipraven)
;        CX=poáet bajtñ textu cesty (p©i chybà CX=0)
; *****************************************************************************

GetDir   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

; ------ naáten° adres†©e

         xor       cx,cx                    ; p©ednastaven° - dÇlka textu 0
         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        GetDir3                  ; p©eru®en° operace BREAK

         push      ds                       ; £schova DS
         xchg      ax,dx                    ; DL <- poëadovanò disk
         inc       dx                       ; korekce na spr†vnou hodnotu
         push      es                       ; segment bufferu
         pop       ds                       ; segment bufferu
         mov       si,di                    ; offset bufferu
         mov       ah,47h                   ; funkce poskytnut° adres†©e
         add       si,3                     ; p©eskoáen° oznaáen° disku
         int       21h                      ; poskytnut° adres†©e zadanÇho disku
         pop       ds                       ; n†vrat DS
         jc        GetDir2                  ; chyba - adres†© neplatnò
         mov       byte ptr es:[si+63],0    ; pojistnÇ ukonáen° ©etàzce

; ------ nastaven° textu disku

         add       dl,"A"-1                 ; korekce na znak ASCII
         mov       es:[di],dl               ; oznaáen° disku
         mov       word ptr es:[di+1],"\:"  ; oddàlovaá disku

; ------ stanoven° dÇlky textu

         mov       cx,3                     ; inicializaán° dÇlka textu
GetDir1: cmp       byte ptr es:[si],0       ; konec textu ?
         je        GetDir3                  ; konec textu
         inc       cx
         inc       si
         jmp       short GetDir1

; ------ chyba operace

GetDir2: mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

GetDir3: pop       si
         pop       dx
         pop       ax
         ret

GetDir   ENDP

; *****************************************************************************
;                             SetDDir
;             nastaven° adres†©e a disku podle cesty
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poëadovanò adres†© (bez koncovÇho "\")
;        DS=datovò segment
; VùSTUP:CY=chyba
; *****************************************************************************

SetDDir  PROC      FAR

; ------ nastaven° disku podle cesty

         push      ax
         cmp       byte ptr es:[si],0       ; je vñbec nàco zad†no ?
         je        SetDDir2                 ; nen° nic zad†no
         cmp       byte ptr es:[si+1],":"   ; je zad†n disk ?
         clc                                ; p©°znak operace OK
         jne       SetDDir2                 ; nen° zad†n disk
         mov       al,es:[si]               ; poëadovanò disk
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         sub       al,"A"                   ; korekce na á°slo disku
         call      far ptr SetDisk         ; nastaven° poëadovanÇho disku
SetDDir2:pop       ax
         jc        SetDDir4                 ; chyba zad†n° disku

; ------ nastaven° cesty

         call      far ptr SetDir          ; nastaven° adres†©e disku
SetDDir4:ret

SetDDir  ENDP

; *****************************************************************************
;                             SetDir
;                     nastaven° adres†©e disku
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poëadovanò adres†© (bez koncovÇho "\")
;        DS=datovò segment
; VùSTUP:CY=chyba
; *****************************************************************************

SetDir   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        SetDir2                  ; je p©eru®en° operace

; ------ zmàna adres†©e

         push      ds
         push      es                       ; segment adres†©e
         pop       ds                       ; segment adres†©e
         cmp       byte ptr ds:[si],0       ; je nàco zad†no ?
         je        SetDir1                  ; nen° nic zad†no
         mov       dx,si                    ; offset adres†©e
         mov       ah,3bh                   ; funkce nastaven° adres†©e
         int       21h                      ; nastaven° poëadovanÇho adres†©e
SetDir1: pop       ds

; ------ chyba operace

         jnc       SetDir2                  ; operace OK
         mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ n†vrat registrñ

SetDir2: pop       dx
         pop       ax
         ret

SetDir   ENDP

; *****************************************************************************
;                            InitAPth
;                   inicializace aktivn°ho adres†©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba operace (ale to nevad°)
; -----------------------------------------------------------------------------
; zniáenÇ registry: AX, CX, DI, ES
; *****************************************************************************

InitAPth PROC      FAR

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset AktPath        ; cesta k aktivn°mu adres†©i
         call      far ptr GetDisk         ; poskytnut° aktivn°ho disku
         add       al,"A"
         mov       ah,":"
         mov       ds:[di],ax               ; inicializaán° oznaáen° disku
         mov       word ptr ds:[di+2],"\"
         mov       word ptr ds:[AktPathN],3 ; dÇlka p©i chybà
         call      far ptr GetADir         ; poskytnut° aktivn°ho adres†©e
         jc        InitAPt2                 ; chyba operace
         mov       ds:[AktPathN],cx         ; dÇlka textu adres†©e
InitAPt2:ret

InitAPth ENDP

; *****************************************************************************
;                                    InitHPth
;  inicializace domovskÇho adres†©e (vyëaduje zn†t aktivn° adres†© a verzi OS)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
; zniáenÇ registry: v®echny kromà DS
; *****************************************************************************

InitHPth PROC      FAR

; ------ kopie aktivn°ho adres†©e do domovskÇho

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,ds:[AktPathN]
         mov       ds:[HomeDirN],cx         ; dÇlka textu
         mov       si,offset AktPath        ; aktivn° adres†©
         mov       di,offset HomeDir        ; domovskò adres†©
         cld
         push      si                       ; aktivn° adres†©
         push      cx                       ; dÇlka adres†©e
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; kopie domovskÇho adres†©e
         pop       cx
         pop       si

; ------ sestaven° n†vratovÇ specifikace programu DOSMAN.EXE

         mov       di,offset DosmPath       ; n†vrat do programu DOSMAN.EXE
         rep       movsb                    ; p©enos aktivn°ho adres†©e
         mov       al,"\"
         cmp       ds:[di-1],al             ; je text ukonáen "\" ?
         je        InitHP12                 ; je ukonáen "\"
         stosb                              ; uloëen° koncovÇho "\"
InitHP12:mov       si,offset DosmName       ; jmÇno DOSMAN.EXE
         mov       cl,offset(DosmNam0-DosmName) ; dÇlka jmÇna programu
         rep       movsb                    ; p©id†n° jmÇna programu DOSMAN.EXE

; ------ adresa prost©ed°

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       ax,es:[PSP_ENV]          ; segment prost©ed°
         mov       es,ax                    ; segment prost©ed°
         cmp       ax,60h                   ; je segment prost©ed° ?
         jae       InitHPt1                 ; je prost©ed°
IntHPt99:jmp       InitHPt9                 ; nen° prost©ed°

; ------ nalezen° ©etàzce odkazu na program

InitHPt1:xor       di,di                    ; zaá†tek prost©ed°
         mov       cx,8000h                 ; maxim†ln° dÇlka prost©ed°
         xor       ax,ax                    ; hledanò konec prost©ed°
InitHPt2:inc       di                       ; zvò®en° adresy v prost©ed°
         cmp       es:[di-1],ax             ; je konec prost©ed° ?
         loopne    InitHPt2                 ; nalezen° konce prost©ed°
         inc       di                       ; adresa poátu ©etàzcñ
         cmp       word ptr es:[di],0       ; je nàjakò ©etàzec ?
         je        IntHPt99                 ; nen° ë†dnò ©etàzec
         inc       di
         inc       di                       ; zaá†tek ©etàzce

; ------ pro n°zkou verzi systÇmu dopl§kov† kontrola

         cmp       word ptr ds:[VerzeOS],300h ; je verze systÇmu alespo§ 3.00 ?
         jae       InitHP22                 ; verze systÇmu je OK
         cmp       word ptr es:[di-2],1     ; mus° bòt 1 ©etàzec
         jne       IntHPt99                 ; neplatnÇ informace
InitHP22:cmp       word ptr es:[di-2],1
         jb        IntHPt99                 ; neplatnÇ informace
         cmp       byte ptr es:[di]," "
         jbe       IntHPt99                 ; neplatnÇ informace

; ------ p©enesen° textu cesty

         mov       bp,di                    ; zaá†tek jmÇna programu
         mov       si,offset HomeDir        ; cesta k domovskÇmu adres†©i
         mov       cx,FileDMax-1            ; maxim†ln° dÇlka textu
         xor       bx,bx                    ; dÇlka textu
         mov       dx,si                    ; £schova konce cesty
InitHPt3:mov       al,es:[di]               ; znak cesty
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         mov       ds:[si],al               ; uloëen° znaku
         cmp       al,":"
         je        InitHPt4                 ; je oddàlovaá disku
         cmp       al,"\"                   ; je oddàlovaá cesty ?
         jne       InitHPt5                 ; nen° oddàlovaá cesty
InitHPt4:mov       dx,si                    ; £schova konce cesty
         mov       bx,FileDMax-1            ; maxim†ln° dÇlka textu
         sub       bx,cx                    ; £schova dÇlky textu
         mov       bp,di                    ; novò zaá†tek jmÇna programu-1
         inc       bp                       ; novò zaá†tek jmÇna programu
InitHPt5:inc       si
         inc       di
         cmp       al,0                     ; je to konec textu ?
         loopne    InitHPt3                 ; nen° konec - dal®° znak

; ------ korekce textu cesty

         cmp       bx,3                     ; je dostateán† dÇlka textu ?
         jae       InitHPt7                 ; je dostateán† dÇlka textu
         cmp       word ptr ds:[HomeDir+1],"\:" ; je to ROOT adres†© ?
         je        InitHPt6                 ; nen° to ROOT adres†©
         cmp       byte ptr ds:[HomeDir],"\" ; je zad†n ROOT ?
         jne       InitHPt7                 ; nen° ROOT
         or        bx,bx                    ; je pouze oddàlovaá ROOT ?
         jnz       InitHPt7                 ; nen° jen oddàlovaá ROOT
InitHPt6:inc       bx                       ; plat° posledn° znak "\"
         inc       dx                       ; n†sleduj°c° znak za "\"
InitHPt7:mov       si,dx                    ; adresa konce cesty
         mov       byte ptr ds:[si],0       ; konec textu cesty
         mov       ds:[HomeDirN],bx         ; dÇlka textu cesty

; ------ nen°-li zad†na pln† cesta, jej° naáten°

         push      ds
         pop       es                       ; ES <- datovò segment
         or        bx,bx                    ; je nàco zad†no ?
         jz        InitHPt8                 ; nen° nic zad†no
         cmp       word ptr ds:[HomeDir+1],"\:" ; je zad†n disk a ROOT ?
         je        InitHP82                 ; je pln† cesta - v®e je OK
         mov       si,offset HomeDir        ; sestaven† cesta
         call      far ptr SetDDir         ; nastaven° zadanÇ cesty
InitHPt8:mov       di,offset HomeDir        ; domovskò adres†©
         call      far ptr GetADir         ; poskytnut° domovskÇ cesty
         jc        InitHP81
         mov       ds:[HomeDirN],cx         ; dÇlka textu cesty
InitHP81:mov       si,offset AktPath        ; aktivn° cesta
         call      far ptr SetDDir         ; n†vrat aktivn° cesty

; ------ p©°prava n†vratovÇ cesty k DOSMAN.EXE

InitHP82:mov       si,offset HomeDir        ; domovskò adres†©
         mov       di,offset DosmPath       ; n†vratov† cesta k DOSMAN.EXE
         mov       cx,ds:[HomeDirN]
         cld
         rep       movsb                    ; p©enesen° textu cesty

         mov       al,"\"
         cmp       byte ptr ds:[di-1],al
         je        InitHP84
         stosb

InitHP84:push      ds
         mov       ds,ds:[SegPSP]           ; segment PSP
         mov       ds,ds:[PSP_ENV]          ; segment prost©ed°
         mov       si,bp
InitHP85:lodsb
         cmp       al,0
         je        InitHP86
         cmp       di,offset DosmPth0-1
         jae       InitHP86
         call      far ptr UpCase
         stosb
         jmp       short InitHP85
InitHP86:mov       al,0
         stosb
         pop       ds

InitHPt9:ret

InitHPth ENDP

; *****************************************************************************
;                               InitTPth
;      inicializace odkl†dac°ho adres†©e (vyëaduje zn†t domovskò adres†©)
;            pro domovskò adres†© mus° bòt zn†m p©echodnò adres†©
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        SI=text parametru (/Z nebo /X)
;        BP=buffer adres†©e (TempDir nebo HomeDir); DS:[BP-2] (2) dÇlka adres†©e
; -----------------------------------------------------------------------------
; zniáenÇ registry: v®echny kromà DS
; *****************************************************************************

InitTPth PROC      FAR

; ------ test, zda je zad†n parametr

         call      far ptr GetCPar          ; nalezen° parametru v p©°kaz. ©†dku
         jnc       InitTPt1
         jmp       InitTPt8                 ; domovskò adres†© nezad†n

; ------ nalezen° zaá†tku zadanÇho p©echodnÇho adres†©e

InitTPt1:mov       al,es:[di]
         inc       di
         cmp       al,TAB
         je        InitTPt1                 ; tabul†tor se p©eskoá°
         cmp       al," "
         je        InitTPt1                 ; mezera se p©eskoá°
         jb        InitTPt8                 ; konec parametrñ - nen° nic zad†no
         cmp       al,"/"
         je        InitTPt8                 ; nen° nic zad†no

; ------ zad†no "*" - bude jako datovò adres†©

         cmp       al,"*"
         je        InitTP78

; ------ p©enos textu adres†©e

         mov       si,bp                    ; buffer p©echodnÇho adres†©e
         xor       dx,dx                    ; DX <- 0 á°taá dÇlky textu
InitTPt2:cmp       dl,FileDMax-1            ; maxim†ln° dÇlka adres†©e
         jae       InitTPt3                 ; maxim†ln° dÇlka adres†©e
         mov       ds:[si],al               ; uloëen° znaku do bufferu
         inc       si                       ; zvò®en° ukl†dac° adresy
         inc       dx                       ; zvò®en° á°taáe dÇlky textu
         mov       al,es:[di]               ; dal®° znak
         inc       di
         cmp       al,"/"
         je        InitTPt3                 ; konec parametrñ
         cmp       al," "
         jae       InitTPt2                 ; platnò znak

; ------ vypu®tàn° mezer na konci textu

InitTPt3:or        dx,dx                    ; je dal®° znak ?
         jz        InitTPt4                 ; nen° dal®° znak
         dec       si
         dec       dx
         cmp       byte ptr ds:[si]," "
         je        InitTPt3
         inc       si
         inc       dx

; ------ vypu®tàn° koncovÇho znaku "\"

InitTPt4:cmp       dl,2                     ; minim†ln° dÇlka 2 znaky
         jb        InitTPt5                 ; je m†lo znakñ - nemñëe bòt "x:\"
         cmp       byte ptr ds:[si-1],"\"
         jne       InitTPt5                 ; nen° "\" na konci adres†©e
         cmp       byte ptr ds:[si-2],":"
         je        InitTPt5                 ; je to ROOT
         dec       si                       ; vypu®tàn° koncovÇho "\"

; ------ oznaáen° konce adres†©e

InitTPt5:mov       byte ptr ds:[si],0       ; oznaáen° konce adres†©e

; ------ nastaven° zadanÇho adres†©e

         push      ds
         pop       es
         mov       si,bp                    ; sestaven† cesta
         call      far ptr SetDDir         ; nastaven° zadanÇ cesty

; ------ naáten° vòslednÇho adres†©e

         mov       di,bp                    ; p©echodnò adres†©
         call      far ptr GetADir         ; poskytnut° domovskÇ cesty
         jc        InitTPt7
         mov       ds:[bp-2],cx             ; dÇlka textu cesty

; ------ n†vrat pñvodn°ho aktivn°ho adres†©e

InitTPt7:pushf
         mov       si,offset AktPath        ; aktivn° cesta
         call      far ptr SetDDir         ; n†vrat aktivn° cesty
         popf
         jnc       InitTPt9

; ------ pro domovskò adres†© bude p©i chybà jako p©echodnò adres†©

InitTP78:mov       si,offset TempDir        ; vezme se to z p©echodnÇho adres†©e
         mov       cx,ds:[TempDirN]
         cmp       bp,offset HomeDir        ; je to domovskò adres†© ?
         je        InitTP82                 ; je to domovskò adres†©

; ------ odkl†dac° adres†© je v domovskÇm adres†©i (pro HomeDir se nic nedàje)

InitTPt8:mov       si,offset HomeDir        ; domovskò adres†©
         mov       cx,ds:[HomeDirN]         ; dÇlka domovskÇho adres†©e
InitTP82:push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,bp                    ; p©echodnò adres†©
         mov       ds:[bp-2],cx             ; dÇlka p©echodnÇho adres†©e
         inc       cx                       ; váetnà koncovÇ 0
         cld
         rep       movsb                    ; kopie adres†©e

InitTPt9:ret

InitTPth ENDP

; *****************************************************************************
;                                HomeFile
;               sestaven° cesty k souboru v dom†c°m adres†©i
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=jmÇno souboru k sestaven° (prvn° bajt = dÇlka jmÇna souboru)
;        ES:DI=buffer k uloëen° specifikace souboru
;        DS=datovò segment
; VùSTUP:DI=konec textu jmÇna souboru v bufferu (koncov† 0)
; *****************************************************************************

HomeFile PROC      FAR

; ------ £schova registrñ

         push      cx

; ------ p©enesen° textu dom†c°ho adres†©e do bufferu

         push      si
         mov       cx,ds:[HomeDirN]         ; dÇlka dom†c°ho adres†©e
         mov       si,offset HomeDir        ; dom†c° adres†©e
         jmp       short TempFil0           ; inicializace adres†©e

HomeFile ENDP

; *****************************************************************************
;                                TempFile
;            sestaven° cesty k souboru v p©echodnÇmu adres†©i
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=jmÇno souboru k sestaven° (prvn° bajt = dÇlka jmÇna souboru)
;        ES:DI=buffer k uloëen° specifikace souboru
;        DS=datovò segment
; VùSTUP:DI=konec textu jmÇna souboru v bufferu (koncov† 0)
; *****************************************************************************

TempFile PROC      FAR

; ------ £schova registrñ

         push      cx

; ------ p©enesen° textu p©echodnÇho adres†©e do bufferu

         push      si
         mov       cx,ds:[TempDirN]         ; dÇlka p©echodnÇho adres†©e
         mov       si,offset TempDir        ; p©echodnò adres†©e
TempFil0:cld
         rep       movsb                    ; p©enos textu do bufferu
         pop       si

; ------ zaji®tàn° znaku "\" na konci textu p©echodnÇho adres†©e

         push      ax

         mov       al,"\"                   ; oddàlovaá adres†©ñ
         dec       di
         scasb                              ; koná° adres†© znakem "\" ?
         je        TempFil1                 ; koná° znakem "\"
         stosb                              ; oddàlovac° znak "\"

; ------ p©id†n° jmÇna souboru k textu cestu

TempFil1:push      si
         lodsb
         mov       cl,al                    ; CL <- dÇlka jmÇna souboru
         rep       movsb                    ; p©enos jmÇna souboru
         mov       es:[di],cl               ; oznaáen° konce textu
         pop       si

; ------ n†vrat registrñ

         pop       ax

         pop       cx
         ret

TempFile ENDP

; *****************************************************************************
;                               Set0DTA
;              Nastaven° standardn°ho bufferu DTA (BuffDTA)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

Set0DTA  PROC      FAR

         push      si
         push      es

         mov       si,offset BuffDTA
         push      ds
         pop       es
         call      far ptr SetDTA

         pop       es
         pop       si
         ret

Set0DTA  ENDP

; *****************************************************************************
;                                SetDTA
;                          Nastaven° adresy DTA
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa DTA
; *****************************************************************************

SetDTA   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      ds

; ------ nastaven° adresy DTA

         mov       word ptr ds:[DTAAdr],si  ; adresa aktivn° DTA - offset
         mov       word ptr ds:[DTAAdr+2],es ; adresa aktivn° DTA - segment
         push      es
         pop       ds                       ; DS <- segment adresy DTA
         mov       dx,si                    ; DX <- offset adresy DTA
         mov       ah,1ah                   ; funkce nastaven° adresy DTA
         int       21h                      ; nastaven° adresy DTA

; ------ n†vrat registrñ

         pop       ds
         pop       dx
         pop       ax
         ret

SetDTA   ENDP

; *****************************************************************************
;                           GetErr
;                   Poskytnut° k¢du posledn° chyby
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:AX=k¢d posledn° chyby
; *****************************************************************************

GetErr   PROC      FAR

; ------ zji®tàn° posledn° chyby pro nië®° verze systÇmu

         mov       ax,ds:[LastErr]          ; k¢d posledn° chyby
         cmp       word ptr ds:[VerzeOS],300h ; je verze systÇmu alespo§ 3.00 ?
         jb        GetErr2                  ; je n°zk† verze systÇmu

; ------ zji®tàn° k¢du chyby pro vy®®° verze systÇmu

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       ah,59h                   ; funkce poskytnut° k¢du chyby
         xor       bx,bx                    ; BX <- 0 identifik†tor funkce
         int       21h                      ; poskytnut° k¢du chyby

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx

; ------ pokud nen° hl†®ena chyba, pouëije se vlastn° uschovanò k¢d chyby

         or        ax,ax                    ; byla nàjak† chyba ?
         jnz       GetErr2                  ; byla nàjak† chyba
         mov       ax,ds:[LastErr]          ; k¢d posledn° chyby
GetErr2: ret

GetErr   ENDP

; *****************************************************************************
;                              NormFilL
;              normalizace jmÇna souboru v ©†dkovÇm bufferu
; - odstranàn° poá†teán°ch a koncovòch mezer, o©ez†n° dÇlky jmen, doplnàn°
;               koncovÇ nuly, p©evod na velk† p°smena
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: ES:SI=adresa bufferu LinBuff (ES=DS, SI=offset LinBuff)
;         CX=dÇlka textu
;         ZY=nen° ë†dnò znak
; *****************************************************************************

NormFilL PROC      FAR

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset LinBuff        ; SI <- ©†dkovò buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; CX <- dÇlka textu
         call      far ptr NormFile        ; normalizace bufferu
         mov       ds:[LinNum],cl           ; nov† dÇlka textu
         or        cx,cx                    ; je nàjakò znak ?
         ret

NormFilL ENDP

; *****************************************************************************
;                              NormFile
;                      normalizace jmÇna souboru
; - odstranàn° poá†teán°ch a koncovòch mezer, o©ez†n° dÇlky jmen, doplnàn°
;               koncovÇ nuly, p©evod na velk† p°smena
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru k normalizaci
;        CX=dÇlka jmÇna
; VùSTUP:CX=nov† dÇlka jmÇna
; *****************************************************************************

NormFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      si
         push      di
         push      ds

; ------ p©°prava registrñ

         cld
         push      es
         pop       ds                       ; DS <- buffer se jmÇnem souboru
         mov       bx,cx                    ; BX <- celkov† dÇlka textu
         mov       di,si                    ; zaá†tek bufferu - ukl†dac° adresa
         jcxz      NormFil9                 ; nen° ë†dnò text

; ------ vypu®tàn° poá†teán°ch mezer

NormFil1:cmp       byte ptr ds:[si]," "     ; je mezera ?
         jne       NormFil2                 ; nen° mezera
         inc       si                       ; zvò®en° ukazatele textu
         dec       bx                       ; sn°ëen° dÇlky textu
         loop      NormFil1                 ; sn°ëen° á°taáe zbylòch znakñ
         jmp       short NormFil9           ; nen° ë†dnò text

; ------ odstranàn° koncovòch mezer

NormFil2:cmp       byte ptr ds:[si+bx-1]," " ; je na konci mezera ?
         jne       NormFil3                 ; nen° mezera
         dec       bx                       ; sn°ëen° dÇlky textu
         loop      NormFil2                 ; sn°ëen° á°taáe zbylòch znakñ

; ------ p©enesen° jmÇna disku (zbòvaj°-li alespo§ 2 znaky)

NormFil3:cmp       cx,2                     ; zbyly alespo§ 2 znaky ?
         jb        NormFil4                 ; kr†tkò text - nen° disk
         cmp       byte ptr ds:[si+1],":"   ; zaá°n† text oznaáen°m disku ?
         jne       NormFil4                 ; nen° oznaáen° disku
         call      NormFil0                 ; naáten° oznaáen° disku
         stosb                              ; oznaáen° disku
         call      NormFil0                 ; naáten° oddàlovaáe ":"

; ------ uloëen° oddàlovaáe a vypu®tàn° mezer na konci jmÇna

NormFl34:cmp       byte ptr ds:[di-1]," "   ; p©edch†z° mezera ?
         jne       NormFl35                 ; nep©edch†z° mezera
         dec       di                       ; vypu®tàn° mezery
         dec       bx                       ; sn°ëen° dÇlky textu
         jmp       short NormFl34           ; dal®° znak
NormFl35:stosb                              ; uloëen° oddàlovac°ho znaku

; ------ vypu®tàn° mezer na zaá†tku jmÇna

NormFil4:jcxz      NormFl42                 ; nen° dal®° znak
         cmp       byte ptr ds:[si]," "     ; n†sleduje mezera ?
         jne       NormFl42                 ; nen†sleduje mezera
         dec       bx                       ; sn°ëen° á°taáe dÇlky textu
         call      NormFil0                 ; zru®en° znaku mezery
         jmp       short NormFil4           ; dal®° znak

; ------ p©enesen° jmÇna

NormFl42:mov       dl,8                     ; maxim†ln° dÇlka jmÇna
NormFil5:call      NormFil0                 ; naáten° dal®°ho znaku
         jc        NormFil9                 ; konec textu
         cmp       al,":"                   ; je oddàlovaá za©°zen° ?
         je        NormFil5                 ; oddàlovaá za©°zen° se ignoruje
         cmp       al,"\"                   ; oddàlovaá adres†©e - dal®° jmÇno ?
         je        NormFl34                 ; dal®° jmÇno adres†©e
         cmp       al,"."                   ; je p©°pona ?
         je        NormFl63                 ; n†sleduje p©°pona
         or        dl,dl                    ; je jië 8 znakñ jmÇna ?
         jz        NormFil6                 ; je jië 8 znakñ jmÇna - p©eskoáen°
         stosb                              ; uloëen° znaku
         dec       dx                       ; sn°ëen° á°taáe dÇlky jmÇna
         inc       bx                       ; p©ednastaven° pro platnò znak
NormFil6:dec       bx                       ; p©°padnÇ sn°ëen° dÇlky textu
         jmp       short NormFil5           ; dal®° znak jmÇna

; ------ p©enesen° p©°pony

NormFl63:stosb                              ; uloëen° znaku oddàlovaáe "."
         mov       dl,3                     ; maxim†ln° dÇlka p©°pony
NormFl64:call      NormFil0                 ; naáten° dal®°ho znaku
         jc        NormFil9                 ; konec textu
         cmp       al,":"                   ; je oddàlovaá za©°zen° ?
         je        NormFl64                 ; oddàlovaá za©°zen° se ignoruje
         cmp       al,"\"                   ; oddàlovaá adres†©e - dal®° jmÇno ?
         je        NormFl34                 ; dal®° jmÇno adres†©e
         or        dl,dl                    ; jsou jië 3 znaky p©°pony ?
         jz        NormFl68                 ; jsou jië 3 znaky - p©eskoáen°
         stosb                              ; uloëen° znaku
         dec       dx                       ; sn°ëen° á°taáe dÇlky
         inc       bx                       ; p©ednastaven° pro platnò znak
NormFl68:dec       bx                       ; p©°padnÇ sn°ëen° dÇlky textu
         jmp       short NormFl64           ; dal®° znak p©°pony

; ------ oznaáen° konce textu

NormFil9:mov       cx,bx                    ; nov† dÇlka textu
         mov       al,0                     ; koncovò znak 0
         stosb                              ; uloëen° koncovÇ 0 textu

; ------ n†vrat registrñ

         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

NormFile ENDP

; -----------------------------------------------------------------------------
;        áten° jednoho znaku p©i normalizaci jmÇna souboru
; -----------------------------------------------------------------------------

NormFil0 PROC      NEAR

; ------ naáten° znaku z bufferu

         stc                                ; p©°znak, ëe nen° dal®° znak
         jcxz      NormFl03                 ; nen° dal®° znak
         lodsb                              ; naáten° znaku z bufferu
         dec       cx                       ; sn°ëen° á°taáe znakñ
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         clc                                ; p©°znak, ëe je platnò znak
NormFl03:ret

NormFil0 ENDP

; *****************************************************************************
;                                FullFile
;                     sestaven° plnÇho jmÇna souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=buffer se jmÇnem souboru k sestaven° (mus° bòt normalizov†no)
;        CX=dÇlka jmÇna
;        DS=datovò segment
; VùSTUP:CX=nov† dÇlka jmÇna (omezeno na FileMax)
; *****************************************************************************

FullFile PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         mov       bp,sp
         mov       bx,cx                    ; dÇlka zadanÇho textu

; ------ vytvo©en° bufferu v z†sobn°ku

         inc       cx                       ; zaokrouhlen° dÇlky nahoru
         and       cl,not 1                 ; zarovn†n° na sudou dÇlku
         sub       sp,cx                    ; rezerva m°sta v z†sobn°ku

; ------ £schova textu do bufferu v z†sobn°ku

         mov       di,sp                    ; buffer v z†sobn°ku
         push      es                       ; segment bufferu
         push      ds                       ; datovò segment
         push      si                       ; adresa bufferu s textem

         push      es
         pop       ds                       ; DS <- segment bufferu s textem
         push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku
         cld
         shr       cx,1                     ; dÇlka textu ve slovech
         rep       movsw                    ; £schova textu do z†sobn°ku

         pop       di                       ; DI <- adresa bufferu s textem
         pop       ds                       ; DS <- datovò segment
         pop       es                       ; ES <- segment bufferu

; ------ inicializaán° uloëen° aktivn°ho adres†©e

         push      di                       ; adresa bufferu textu
         mov       si,offset AktPath        ; aktivn° cesta
         mov       cx,ds:[AktPathN]         ; dÇlka cesty
         push      cx                       ; dÇlka aktivn°ho adres†©e
         rep       movsb                    ; uloëen° aktivn°ho adres†©e
         pop       cx                       ; dÇlka aktivn°ho adres†©e
         pop       di                       ; adresa bufferu textu

; ------ kontrola, zda je zad†n disk

         mov       si,sp                    ; buffer v z†sobn°ku
         cmp       bx,2                     ; jsou aspo§ 2 znaky ?
         jb        FullFil2                 ; malò poáet znakñ - nen° disk
         cmp       byte ptr ss:[si+1],":"   ; je zad†n disk ?
         jne       FullFil2                 ; nen° zad†n disk

; ------ pro aktivn° disk je adres†© jië nastaven

         mov       al,ss:[si]               ; zadanò disk
         cmp       al,es:[di]               ; je to aktivn° disk ?
         je        FullFil2                 ; je to aktivn° disk

; ------ adres†© z neaktivn°ho okna

         push      ax
         push      di
         push      si
         push      ds

         mov       ax,ds:[SegmNAkt]         ; neaktivn° okno
         call      far ptr GetSgAdr         ; adresa neaktivn°ho okna
         jc        FullFil1                 ; nàjak† chyba
         mov       ds,dx                    ; DS <- adresa okna

         mov       al,ss:[si]               ; zadanò disk
         mov       si,AWinDir
         cmp       al,ds:[si]               ; souhlas° disk ?
         stc
         jne       FullFil1                 ; disk nesouhlas°

         cld
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         push      cx
         rep       movsb                    ; p©enos textu adres†©e
         pop       cx
         clc                                ; p©°znak operace OK

FullFil1:pop       ds
         pop       si
         pop       di
         pop       ax
         jnc       FullFil2                 ; adres†© je OK

; ------ pro jinò disk naáten° aktivn°ho adres†©e

         sub       al,"A"                   ; korekce na á°slo disku
         call      far ptr GetDir           ; naáten° aktivn°ho adres†©e
         jnc       FullFil2                 ; adres†© naáten OK

; ------ chyba - vytvo©en° pomocnÇho adres†©e

         add       al,"A"                   ; oznaáen° disku
         mov       ah,":"                   ; oddàlovaá oznaáen° disku
         mov       es:[di],ax               ; oznaáen° disku a ":"
         mov       byte ptr es:[di+2],"\"   ; oznaáen° ROOT
         mov       cx,3                     ; dÇlka adres†©e

; ------ p©°prava k dek¢dov†n° SS:SI/BX -> ES:DI/CX

FullFil2:push      ss
         pop       ds                       ; DS<-segment s textem k normalizaci
         cld

; ------ p©eskoáen° zad†n° disku (byl rozli®en jië d©°ve)

         cmp       bx,1                     ; je dostateán† dÇlka textu ?
         jb        FullFL22                 ; nen° nic zad†no
         je        FullFl21                 ; je pouze 1 znak - mñëe bòt ROOT
         cmp       byte ptr ds:[si+1],":"   ; je zad†n disk ?
         jne       FullFl21                 ; nebyl zad†n disk
         inc       si
         inc       si                       ; p©eskoáen° zad†n° disku
         dec       bx
         dec       bx                       ; zbylò poáet znakñ
         jz        FullFl22                 ; nezbyly ë†dnÇ znaky

; ------ rozli®en°, zda byl zad†n ROOT

FullFl21:cmp       byte ptr ds:[si],"\"     ; byl zad†n ROOT ?
         jne       FullFl22                 ; nebyl zad†n ROOT
         mov       cx,3                     ; omezen° dÇlky cesty na ROOT
         inc       si                       ; p©eskoáen° znaku "\"
         dec       bx                       ; sn°ëen° poátu znakñ

; ------ zaá†tek k dek¢dov†n°

FullFl22:add       di,cx                    ; konec cesty
         mov       al,"\"                   ; oddàlovaá
         cmp       es:[di-1],al
         je        FullFil3                 ; je jië znak "\"
         stosb                              ; uloëen° oddàlovaáe "\"
         inc       cx                       ; á°taá dÇlky

; ------ zaá†tek dek¢dov†n° jednoho podadres†©e

FullFil3:cmp       bx,1                     ; zbyly je®tà nàjakÇ znaky ?
         jb        FullFil8                 ; konec textu
         je        FullFil4                 ; posledn° znak

; ------ posun k nië®° £rovni (BX > 1)

         cmp       word ptr ds:[si],".."    ; je posun dolñ ?
         jne       FullFil4                 ; nen° nadadres†©
         inc       si
         inc       si                       ; p©eskoáen° textu ".."
         dec       bx
         dec       bx                       ; sn°ëeni á°taáe zbylòch znakñ
         cmp       cl,3                     ; je jië ROOT ?
         jbe       FullFil6                 ; je jië ROOT - nic se nemàn°
FullFl32:dec       di                       ; posun o 1 znak dolñ
         dec       cx                       ; sn°ëen° á°taáe dÇlky textu
         cmp       byte ptr es:[di-1],"\"   ; dosaëeno p©ede®lÇho podadres†©e ?
         jne       FullFl32                 ; nalezen° p©ede®lÇho podadres†©e
         jmp       short FullFil6           ; dal®° adres†©

; ------ stejn† £rove§

FullFil4:cmp       byte ptr ds:[si],"."     ; je adres†© stejnÇ £rovnà ?
         jne       FullFil5                 ; nen° adres†© "."
         inc       si                       ; p©eskoáen° znaku "."
         dec       bx                       ; sn°ëen° á°taáe zbylòch znakñ
         jmp       short FullFil6           ; dal®° adres†©

; ------ p©enesen° textu jednoho podadres†©e

FullFil5:cmp       byte ptr ds:[si],"\"     ; dosaëeno koncovÇho znaku "\" ?
         je        FullFil6                 ; je konec adres†©e
         or        bx,bx                    ; je konec textu ?
         jz        FullFil8                 ; konec textu
         lodsb                              ; naáten° znaku textu
         dec       bx                       ; sn°ëen° á°taáe zbylòch znakñ
         cmp       cl,FileMax               ; je jië maxim†ln° dÇlka cesty ?
         jae       FullFil5                 ; maxim†ln° dÇlka - znak se ignoruje
         stosb                              ; uloëen° znaku adres†©e
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
         jmp       short FullFil5           ; dal®° znak

; ------ vypu®tàn° zbylòch znakñ jednoho podadres†©e

FullFil6:or        bx,bx                    ; je jië konec textu ?
         jz        FullFil8                 ; je jië konec textu
         lodsb                              ; naáten° znaku z textu
         dec       bx                       ; sn°ëen° á°taáe zbylòch znakñ
         cmp       al,"\"                   ; nalezen dal®° oddàlovaá adres†©e ?
         jne       FullFil6                 ; nalezen° dal®°ho oddàlovaáe
         cmp       es:[di-1],al             ; byl text ukonáen znakem "\" ?
         je        FullFil7                 ; byl ukonáen znakem "\" - OK
         stosb                              ; uloëen° koncovÇho znaku "\"
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
FullFil7:jmp       short FullFil3           ; dal®° podadres†©

; ------ konec dek¢dov†n° - oprava konce (aby nebyl "\" na konci)

FullFil8:cmp       byte ptr es:[di-2],":"   ; je to ROOT ?
         je        FullFil9                 ; je ROOT - "\" zñstane
         cmp       byte ptr es:[di-1],"\"   ; koná° text znakem "\" ?
         jne       FullFil9                 ; nekoná° znakem "\" - je to OK
         dec       cx                       ; sn°ëen° dÇlky textu
         dec       di                       ; n†vrat na koncovò znak "\"
FullFil9:mov       byte ptr es:[di],0       ; oznaáen° konce textu

; ------ n†vrat registrñ

         mov       sp,bp
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

FullFile ENDP

CodeDisk ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; ------ parametry pro inicializaci

;DiskIITx db        4,'Disk'                 ; skupina parametrñ
;FormIITx db        6,'FormA1'               ; parametr form†tu 1 disku A:
;ComDskTx db        5,'DiskA'                ; koment†© k disku

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - adres†© nelze kop°rovat cyklicky
; -----------------------------------------------------------------------------
;˛
CopCErrM label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        CopCErrP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CopCErrT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        54                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

CopCErrT db        19,'cyklickÇ kop°rov†n°'

CopCErrP db        bit6,6,0,'CHYBA'
         db        bit6,43,'Adres†© ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' nelze kop°rovat s†m do sebe !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - adres†© nelze p©ejmenovat
; -----------------------------------------------------------------------------

RenDErrM label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        RenDErrP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PrejmenovaniAPresun  ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        RenDErrT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

RenDErrT db        25,'adres†© nelze p©ejmenovat'

RenDErrP db        bit6,6,0,'CHYBA'
         db        bit6,33,'Adres†© ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' nelze p©ejmenovat !'
         db        bit6,41,'(existuje jië stejnò adres†© nebo soubor)'
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - porovn†vanò soubor nenalezen
; -----------------------------------------------------------------------------

ChbCmEr  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ChbCmErP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniSouboru   ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbCmErT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbCmErT db        16,'soubor nenalezen'

ChbCmErP db        bit6,6,0,'CHYBA'
         db        bit6,36,'Porovn†vanò soubor ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' nenalezen !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;        varovnÇ hl†®en° - porovn†v†n° souboru sama se sebou
; -----------------------------------------------------------------------------

ChbCmWr  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ChbCmWrP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniSouboru   ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbCmWrT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        52                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbCmWrT db        13,'stejnò soubor'

ChbCmWrP db        bit6,9,0,'VAROVèNã'
         db        bit6,39,'Porovn†v†te soubor ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' s†m se sebou !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;        varovnÇ hl†®en° - kop°ruje se soubor s†m do sebe
; -----------------------------------------------------------------------------

CopErD1  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        CopErD1P                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CopErD1T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        48                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

CopErD1T db        13,'kopie do sebe'

CopErD1P db        bit6,9,0,'VAROVèNã'
         db        bit6,37,'Kop°rujete soubor ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' s†m do sebe !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;     chybovÇ hl†®en° - existuje adres†© stejnÇho jmÇna jako kop°rovanò soubor
; -----------------------------------------------------------------------------

CopyLD1  label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        CopyLD1P                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CopyLD1T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        6                        ; poá†teán° ©†dek okna
         db        41                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

CopyLD1P db        bit6,6,0,'CHYBA'
         db        bit6,35,'Existuje jië adres†© stejnÇho jmÇna'
         db        bit6,19,'jako soubor ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' !'
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

CopyLD1T db        16,'existuje adres†©'


; -----------------------------------------------------------------------------
;     chybovÇ hl†®en° - p©episovanò soubor nelze zru®it
; -----------------------------------------------------------------------------

CopyLDPr label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        CopyLDPP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CopyLDPT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        6                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

CopyLDPP db        bit6,6,0,'CHYBA'
         db        bit6,39,'P©episovanò soubor ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' nelze zru®it !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

CopyLDPT db        19,'soubor nelze zru®it'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba z†pisu do souboru
; -----------------------------------------------------------------------------

ChbWrEr  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ChbWrErP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuSoubory       ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbWrErT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbWrErT db        12,'chyba z†pisu'

ChbWrErP db        bit6,6,0,'CHYBA'
         db        bit6,31,'Chyba z†pisu do souboru ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba áten° ze souboru
; -----------------------------------------------------------------------------

ChbReEr  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ChbReErP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuSoubory       ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbReErT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbReErT db        11,'chyba áten°'

ChbReErP db        bit6,6,0,'CHYBA'
         db        bit6,30,'Chyba áten° ze souboru ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba vytvo©en° souboru
; -----------------------------------------------------------------------------

CreaED1  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        CreaED1P                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuSoubory       ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CreaED1T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        46                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

CreaED1T db        15,'chyba vytvo©en°'

CreaED1P db        bit6,6,0,'CHYBA'
         db        bit6,29,'Soubor ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' nelze vytvo©it !'
         db        bit6,3,1
CreaED2P dw        CreaED3P
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

CreaED3P db        33,'(p©°li® mnoho souborñ v adres†©i)'
CreaED4P db        39,'(disk plnò nebo adres†© nelze vytvo©it)'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba otev©en° souboru
; -----------------------------------------------------------------------------

ChbOpEr  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ChbOpErP                 ; zaá†tek definice poloëek menu
         dw        ChbOpErH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuSoubory       ; á°slo str†nky velkÇ n†povàdy
         dw        ChbOpErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbOpErT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbOpErT db        14,'chyba otev©en°'

ChbOpErP db        bit6,6,0,'CHYBA'
         db        bit6,28,'Soubor ',0,1
         dw        ChbOpErF                 ; jmÇno souboru
         db        0,' nelze otev©°t !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

ChbOpErF db        12,'            '

HelpS    SEGMENT   BYTE PUBLIC
ChbOpErH db        37,'Pokraáov†n° v operaci dal®°m souborem'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

ChbOpErB db        0,0

; -----------------------------------------------------------------------------
;        tabulka diskovòch informac°
; -----------------------------------------------------------------------------
;˛
DiskNum  dw        0                        ; poáet platnòch diskñ v systÇmu
DiskITbP db        0                        ; parametry diskñ
                                            ;  bit 0: 1=nalezen s°üovò/CD-ROM disk
                                            ;  bit 1: 1=nalezen CD-ROM disk

DiskITab label     byte                     ; (posledn°=historie adres†©ñ)
         db        DiskMax+1 dup(0)         ; tabulka diskovòch informac° (0=nen°)
                                            ;  bit 0 aë bit 2: typ disku
                                            ;           0=....neplatnò disk
                                            ;           1=disketov† mechanika
                                            ;           2=pevnò disk WINCHESTER
                                            ;           3=RAM disk
                                            ;           4=s°üovò disk
                                            ;           5=SUBST disk
                                            ;           6=CD ROM
                                            ;           7=
                                            ;  bit 3:
                                            ;  bit 4: 1=disk je d†lkovò
                                            ;  bit 5: 1=neumoë§uje sekt. p©°stup
                                            ;  bit 6: 1=disk je pevnò
                                            ;  bit 7: 1=disk je SUBST

; ------ obsluha diskovòch informac°

DiskInfP db        0                        ; parametry diskñ
                                            ;   bit 0:
                                                    ;   bit 1: 1=je editace ©†dku
                                            ;   bit 2:
                                            ;   bit 3: 1=buffer modifikov†n
DiskInfS dw        0                        ; segment diskovòch informac°
DiskInfA dw        0                        ; adresa zaá†tku aktivn°ho ©†dku
DiskInfK dw        0                        ; adresa kurzoru p©i editaci

; ------ pracovn° buffer DTA

DTAAdr   dd        BuffDTA                  ; adresa aktivn°ho DTA

BuffDTA  label     byte
         db        DTAMax dup(0)            ; pracovn° buffer DTA

; ------ buffer pro obsluhu dlouhÇho jmÇna souboru
; Äasy jsou ud†ny jako poáet 100ns od 1.1.1601 (zd† se, ëe to je od 02:00:00)

; Äasy lze zkonvertovat na tvar:  0: (1) 1/100 sekundy (rezervov†no, zat°m <- 0)
;                                 1: (1) sekunda
;                                 2: (1) minuta
;                                 3: (1) hodina
;                                 4: (1) den
;                                 5: (1) màs°c
;                                 6: (2) rok
; Äas modifikace je zkonvertov†n ihned p©i hled†n°.

DTALong  label     byte
DTALAtr  label     byte
         db        0,0,0,0                  ; atributy (bit 8: 1=p©echodnò)
DTALCrea label     byte
         dw        4 dup(0)                 ; áas vytvo©en° souboru
                                            ;  [DTALCrea+6] (2) =0 ... neplatnÇ
DTALOpen label     byte
         dw        4 dup(0)                 ; áas posledn°ho otev©en° souboru
                                            ;  [DTALOpen+6] (2) =0 ... neplatnÇ
DTALModi dw        4 dup(0)                 ; áas posledn° modifikace souboru
DTALSizH dw        2 dup(0)                 ; velikost souboru HIGH
DTALSizL dw        2 dup(0)                 ; velikost souboru LOW
         dw        4 dup(0)                 ; .... rezervov†no
                                          ;* posledn° bajt rezervovanÇho pole
                                          ;* je nastaven na dÇlku dlouhÇho jmÇna
                                          ;* kvñli jeho zobrazen°
DTALName label     byte
         db        260 dup(0)               ; plnÇ ASCIIZ jmÇno souboru
DTALSNam label     byte
         db        14 dup(0)                ; kr†tkÇ ASCIIZ jmÇno souboru

DTALNamN dw        0                        ; dÇlka dlouhÇho jmÇna souboru

;DTALIdnt dw        -1                       ; identifik†tor hled†n° (-1=nen°)

;DTALINul db        0,0b0h,4ch,1eh,8fh,0e7h,0a8h,1 ; áas pro 1.1.1980 v 00:00:00

; ------ aktu†ln° adres†© (dodrëet po©ad° poloëek !)

AktPathN dw        3                        ; poáet znakñ textu adres†©e
AktPath  db        'C:\',FileDMax-3 dup(0)  ; cesta k aktivn°mu adres†©i (+disk)

RootDir  db        'A:\',0

TempTxt  db        4,'TEMP'

DosmName db        'DOSMAN.EXE',0
DosmNam0 label     byte

Data     ENDS

         END

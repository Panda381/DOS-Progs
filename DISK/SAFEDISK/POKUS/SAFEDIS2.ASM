
; *****************************************************************************
;
;                                   SAFEDISK
;
;             zabezpe‡en¡ skupiny disket archivu paritni disketou
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

MAXTRACK EQU       190                      ; maxim ln¡ po‡et v lc–
MAXSEKT  EQU       48                       ; maxim ln¡ po‡et sektor– na stopu
MAXSIDE  EQU       8                        ; maxim ln¡ po‡et stran
; Pozor, aby buffer pro 1 stopu (MAXSEKT*512) nedos hl 64 KB

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
HI       EQU       256

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       si,offset UvTxt          ; £vodn¡ text
         call      StdOut                   ; zobrazen¡ £vodn¡ho textu

; ------ p©edefinov n¡ z sobn¡ku

         mov       si,offset MemTxt         ; text - chyba pamˆti
         cmp       sp,offset Zasobnik       ; kontrola konce z sobn¡ku
         jb        Chyba                    ; chyba pamˆti
         mov       sp,offset Zasobnik       ; p©edefinov n¡ ukazatele z sobn¡ku

; ------ zmen¨en¡ bloku programu (SI=text hl ¨en¡ o chybˆ pamˆti, ES=DS)

         mov       bx,(offset(Zasobnik-Start)+10fh)/16 ; velikost bloku
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu
         jc        Chyba                    ; nˆjak  chyba

; ------ vytvo©en¡ datov‚ho bloku (SI=text hl ¨en¡ o chybˆ pamˆti, ES=DS)

         mov       bx,-1                    ; BX <- nesmysl (maximum)
         mov       ah,48h
         int       21h                      ; dotaz na maxim ln¡ velikost bloku
         mov       ah,48h
         int       21h                      ; p©idˆlen¡ maxim ln¡ho bloku
         jc        Chyba                    ; nˆjak  chyba ?
         mov       ds:[BuffAdr],ax          ; adresa bufferu
         mov       ds:[BuffSize],bx         ; velikost bufferu (odstavc–)

; ------ kontrola velikosti datov‚ho bloku BX (SI=text hl ¨en¡ o chybˆ pamˆti)

         cmp       bx,2*((MAXSEKT+1)*512/16) ; minim ln¡ velikost bufferu
         jb        Chyba                    ; m lo pamˆti

; ------ stanoven¡ adresy bufferu pracovn¡ stopy

         mov       ds:[BuffDisk],ax         ; mo‘n  adresa bufferu
         and       ah,0fh                   ; offset v segmentu 64 KB
         add       ax,(MAXSEKT+1)*512/16    ; zv˜¨en¡ adresy bufferu
         test      ah,0f0h                  ; je p©ete‡en¡ 64 KB ?
         jz        Start1                   ; nen¡ p©ete‡en¡ 64 KB
         add       word ptr ds:[BuffDisk],(MAXSEKT+1)*512/16 ; p©esko‡en¡ p©elomu
         and       word ptr ds:[BuffDisk],0f000h ; zarovn n¡ adresy bufferu

; ------ rozbor p©¡kazov‚ho © dku

Start1:  call      Rozbor                   ; rozbor p©¡kazov‚ho © dku
         jnc       Start2                   ; parametry zad ny OK

; ------ chyba zad n¡ parametr– - zobrazen¡ n povˆdy

         mov       si,offset HelpTxt        ; text n povˆdy
Chyba:   call      StdOut                   ; zobrazen¡ chybov‚ho textu
         call      DIniXMS                  ; odinstalov n¡ pamˆti XMS
         call      DIniMem                  ; odinstalov n¡ p©idˆlen‚ pamˆti
         mov       ax,4c02h                 ; chyba zad n¡ parametr–
         int       21h

; ------ instalace obsluhy INT 23h

Start2:  mov       ax,2523h
         mov       dx,offset INT23
         int       21h                      ; instalace INT 23h

; ------ inicializace ovlada‡e pamˆti XMS

         call      InitXMS                  ; inicializace pamˆti XMS

; ------ nulov n¡ tabulky chyb
;
;         call      ResDisk                  ; resetov n¡ diskov‚ho syst‚mu
;         push      ds
;         pop       es                       ; ES <- datov˜ segment
;         mov       di,offset ErrMap
;         mov       cx,offset(ErrMap0-ErrMap)
;         xor       ax,ax
;         cld
;         rep       stosb                    ; vymaz n¡ tabulky

; ------ skok na obsluhu funkce

         mov       ax,ds:[Operace]          ; po‘adovan  operace
         mov       bx,offset TabOper-2      ; tabulka adres obsluh operac¡
Start4:  inc       bx
         inc       bx                       ; zv˜¨en¡ ukazatele v tabulce
         shr       ax,1                     ; je to hledan  funkce ?
         jnc       Start4                   ; nalezen¡ adresy obsluhy funkce
         call      word ptr ds:[bx]         ; skok na obsluhu funkce

; ------ © dn˜ konec programu

Start9:  ;call      DIns1E                   ; odinstalov n¡ INT 1Eh
         ;call      TempClos                 ; uzav©en¡ p©echodn‚ho souboru
         call      DIniXMS                  ; odinstalov n¡ pamˆti XMS
         call      DIniMem                  ; odinstalov n¡ p©idˆlen‚ pamˆti
         mov       ax,4c00h
         int       21h

; ------ tabulka adres obsluh jednotliv˜ch funkc¡

TabOper  label     word
         dw        Gener                    ; generov n¡ paritn¡ diskety
         dw        Obnov                    ; obnoven¡ po¨kozen‚ diskety
         dw        Modif                    ; modifikace archivu
         dw        TestT                    ; test archivu
         dw        Verif                    ; verifikace jedn‚ diskety
         dw        Ident                    ; identifikace diskety
         dw        ReadD                    ; ‡ten¡ diskety
         dw        WritD                    ; z pis diskety
         dw        CopyD                    ; kop¡rov n¡ diskety

; *****************************************************************************
;
;                     Funkce generov n¡ paritn¡ diskety
;
; *****************************************************************************
;ş
Gener    PROC      NEAR

; ------ zobrazen¡ n povˆdy

         mov       si,offset GenTxt
         call      StdOut                   ; zobrazen¡ v˜zvy k vlo‘en¡ diskety

; ------ v˜zva k vlo‘en¡ prvn¡ diskety

         mov       si,offset GenMnu1        ; menu k vlo‘en¡ prvn¡ diskety
Gener1:  call      Menu                     ; volba dal¨¡ operace
         call      JumpAL                   ; skok podle AL

         db        'D'
         dw        Gener3

         db        0
         dw        Gener2                   ; p©eru¨en¡

; ------ p©eru¨en¡ operace

Gener2:  call      Prerus                   ; dotaz na p©eru¨en¡ operace
         jnc       Gener1                   ; operace se nep©eru¨¡
         ret                                ; p©eru¨en¡ operace

; ------ "D" dal¨¡ disketa

; ------ p©ihl ¨en¡ diskety

Gener3:  call      ReadBoot                 ; inicializace diskety
         jc        Gener1                   ; p©eru¨en¡ operace


         jmp       short gener1

;
;Gener2:  call      TempOpen                 ; vytvo©en¡ p©echodn‚ho souboru
;         test      byte ptr ds:[Operace],bit1+bit4 ; je paritn¡ disketa ?
;         jz        Gener22
;         or        byte ptr ds:[Param],bit2 ; ur‡en  paritn¡ disketa
;Gener22: call      ReadBoot                 ; inicializace diskety
;         jc        Gener1                   ; opakov n¡ operace
;         call      InitDisk                 ; inicializace diskov˜ch parametr–
;
;; ------ prvn¡ disketa je paritn¡, je-li modifikace nebo obnoven¡
;
;         test      byte ptr ds:[Operace],bit1+bit4 ; je to paritn¡ disketa ?
;         jz        Gener3                   ; nen¡
;         or        byte ptr ds:[Param],bit4+bit2 ; je paritn¡ disketa
;         call      VolParit                 ; n vˆ¨t¡ pro paritn¡ disketu
;
;; ------ na‡ten¡ diskety s operac¡ XOR
;
;Gener3:  call      CtiDisk                  ; na‡ten¡ diskety s XOR
;         jnc       Gener32                  ; nen¡ p©eru¨en¡
;         test      byte ptr ds:[Param],bit2 ; je paritn¡ disketa ?
;         jnz       Gener1                   ; je paritn¡ disketa
;Gener32: and       byte ptr ds:[Param],not bit2 ; nen¡ ur‡en  paritn¡ disketa
;
;; ------ v˜zva k vlo‘en¡ dal¨¡ diskety
;
;Gener4:  mov       si,offset GenTxt2
;         mov       di,offset GenMnu2
;         call      Menu                     ; volba dal¨¡ operace
;         call      XchgDsk                  ; v˜mˆna diskety
;         jnc       Gener4
;         cmp       al,"Z"
;         je        Gener6                   ; konec
;         cmp       al,"D"
;         jne       Gener12
;
;; ------ dal¨¡ disketa - test shodnosti parametr– diskety
;
;Gener5:  call      ReadBoot
;         jc        Gener4                   ; p©eru¨en¡ operace
;         call      CompDisk                 ; porovn n¡ parametr– disku
;         jnc       Gener3                   ; na‡ten¡ dal¨¡ diskety
;
;; ------ disketa nen¡ shodn 
;
;         mov       si,offset FrmSTxt
;         mov       di,offset FrmSTxtM
;         call      Menu
;         jc        Gener4                   ; p©eru¨en¡
;         cmp       al,"O"
;         je        Gener5                   ; opakov n¡
;         jmp       short Gener4             ; p©eru¨en¡
;;         cmp       al,"N"
;;         je        Gener4                   ; n vrat
;;Gener14: jmp       short Gener12            ; p©eru¨en¡
;
;; ------ test, zda byla chyba dat p©i obnoven¡
;
;Gener6:  test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
;         jz        Gener609                 ; nen¡ obnoven¡ diskety
;         push      ds
;         pop       es
;         mov       di,offset ErrMap         ; mapa chyb
;         mov       cx,offset ErrMap0-ErrMap ; velikost mapy
;         xor       ax,ax
;         cld
;         repe      scasb                    ; test, zda byla chyba
;         je        Gener609                 ; nebyla ‘ dn  chyba
;
;; ------ v˜zva k vlo‘en¡ opravovan‚ diskety
;
;         mov       si,offset OprvTxt
;         mov       di,offset OprvMnu
;         call      Menu                     ; obsluha menu
;         cmp       al,"Z"
;         je        Gener609                 ; z pis
;         cmp       al,"D"
;         jne       Gener4                   ; nen¡ d le - p©eru¨en¡
;         call      ObnvOld                  ; obnoven¡ z p–vodn¡ diskety
;
;; ------ jsou ji‘ v¨echny diskety - v˜zva k vlo‘en¡ pr zdn‚ diskety
;
;Gener609:mov       si,offset VystTxt
;         mov       di,offset VystMnu
;         test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
;         jnz       Gener60                  ; je obnoven¡ diskety
;         mov       si,offset PartTxt
;         mov       di,offset PartMnu
;Gener60: call      Menu                     ; volba
;         jc        Gener622                 ; n vrat menu
;         call      XchgDsk                  ; v˜mˆna diskety
;         jnc       Gener609
;         cmp       al,"N"
;         je        Gener622                 ; n vrat menu
;         cmp       al,"Z"
;         jne       Gener622                 ; nen¡ z pis - je p©eru¨en¡
;
;; ------ inicializace paritn¡ diskety
;
;Gener61: test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
;         jnz       Gener611                 ; je obnoven¡ diskety
;         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa v souboru ?
;         jz        Gener611                 ; nen¡ disketa v souboru
;         or        byte ptr ds:[Param],bit4 ; je paritn¡ disketa
;         call      VolParit
;         call      ZapOutp                  ; z pis v˜stupn¡ho souboru
;         jmp       short Gener66
;
;Gener611:call      ReadBoot                 ; na‡ten¡ BOOT sektoru
;         call      CompDisk                 ; porovn n¡ parametr– disku
;         jnc       Gener62                  ; na‡ten¡ dal¨¡ diskety
;
;; ------ disketa nen¡ shodn 
;
;         mov       si,offset FrmSTxt
;         mov       di,offset FrmSTxtM
;         call      Menu
;         jc        Gener622                 ; p©eru¨en¡
;         cmp       al,"O"
;         je        Gener61                  ; opakov n¡
;;         cmp       al,"N"
;;         jne       Gener144                 ; p©eru¨en¡
;Gener622:jmp       Gener4                   ; n vrat
;
;; ------ korekce jmenovky
;
;Gener62: test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
;         jnz       Gener63                  ; je obnoven¡ diskety
;         or        byte ptr ds:[Param],bit4 ; je paritn¡ disketa
;         call      VolParit                 ; n vˆ¨t¡ pro paritn¡ disketu
;         jmp       short Gener64
;
;Gener63: call      VolObnov                 ; korekce jmenovky p©i obnoven¡
;
;; ------ z pis diskety
;
;Gener64: call      ZapDisk                  ; z pis paritn¡ diskety
;         call      TstBreak                 ; test p©eru¨en¡
;         jc        Gener622
;
;; ------ hl ¨en¡ o z pisu diskety
;
;Gener66: test      byte ptr ds:[Operace],bit1 ; je obnoven¡ ?
;         jnz       Gener7                   ; je obnoven¡ - nen¡ hl ¨en¡
;         test      byte ptr ds:[Param],bit0 ; paritn¡ disketa v souboru ?
;         jnz       Gener7
;         mov       si,offset ParitTxt
;         call      StdOutT                  ; zobrazen¡ hl ¨en¡

Gener9:  ret

Gener    ENDP

;; -----------------------------------------------------------------------------
;;        jmenovka pro paritn¡ disketu
;; -----------------------------------------------------------------------------
;
;VolParit PROC      NEAR
;
;         test      byte ptr ds:[Param],bit4 ; je paritn¡ disketa ?
;         jz        VolPari9                 ; nen¡ paritn¡ disketa
;
;         push      bx
;         push      es
;
;         push      ds
;         pop       es                       ; ES <- datov˜ segment
;         mov       bx,offset ParTxt
;         call      CopyLab                  ; kopie jmenovky do buffer–
;
;         pop       es
;         pop       bx
;
;VolPari9:ret
;
;VolParit ENDP

; *****************************************************************************
;
;                       Funkce obnoven¡ vadn‚ diskety
;
; *****************************************************************************
;ş
Obnov    PROC      NEAR

; ------ zobrazen¡ n povˆdy

         mov       si,offset ObnTxt
         call      StdOut                   ; zobrazen¡ v˜zvy k vlo‘en¡ diskety

;         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa ?
;         jz        Obnov1                   ; nen¡
;         call      TempOpen                 ; vytvo©en¡ p©echodn‚ho souboru
;         cmp       word ptr ds:[OutpIdnt],0 ; je otev©en soubor ?
;         jne       Obnov2                   ; soubor je otev©en OK
;
;; ------ potvrzen¡ operace
;
;Obnov1:  mov       si,offset ObnTxt1
;         mov       di,offset ObnMnu1
;         call      Menu                     ; volba dal¨¡ operace
;         cmp       al,"D"
;         je        Obnov2
;         call      XchgDsk                  ; v˜mˆna disku
;         jnc       Obnov1
;Obnov12: jmp       Prerus
;
;Obnov2:  jmp       Gener2

Obnov9:  ret

Obnov    ENDP

;; -----------------------------------------------------------------------------
;;        korekce jmenovky p©i obnoven¡ (neuchov v  registry)
;; -----------------------------------------------------------------------------
;
;VolObnov PROC      NEAR
;
;; ------ inicializa‡n¡ vymaz n¡ jmenovky
;
;         push      ds
;         pop       es                       ; ES <- datov˜ segment
;         mov       bx,offset MazTTxt1       ; sam‚ mezery
;         call      CopyLab                  ; kopie do buffer–
;
;; ------ inicializace jmenovky disku
;
;         mov       es,ds:[BuffDat]          ; za‡ tek datov‚ho bufferu
;         test      byte ptr ds:[Param],bit3 ; je nekompatibiln¡ BOOT ?
;         jnz       VolObn3                  ; nekompatibiln¡ BOOT
;         cmp       byte ptr es:[10h],2      ; je polo‘ka tabulek FAT ?
;         jb        VolObn3                  ; neplatn˜ BOOT
;         cmp       byte ptr es:[bx+26h-2bh],29h ; je to roz¨¡©en˜ sektor ?
;         jne       VolObn4
;         mov       bx,2bh                   ; jmenovka pro DOS 4
;VolObn1: call      TestLab                  ; test jmenovky diskety ES:BX
;         jc        VolObn3                  ; jmenovka neplat¡, asi paritn¡ disk
;
;; ------ jmenovka NO NAME je neplatn 
;
;         mov       di,bx                    ; offset adresy jmenovky
;         mov       si,offset NoNamTxt       ; jmenovka "NO NAME"
;         mov       cx,11
;         cld
;         repe      cmpsb                    ; je to jmenovka NO NAME ?
;         je        VolObn3                  ; je jmenovka NO NAME
;         call      CopyLab                  ; kopie jmenovky disku ES:BX
;VolObn3: ret
;
;; ------ zji¨tˆn¡ po‡tu sektor– ROOT
;
;VolObn4: mov       bp,es:[11h]              ; po‡et polo‘ek ROOT
;         shr       bp,1
;         shr       bp,1
;         shr       bp,1
;         shr       bp,1                     ; po‡et sektor– ROOT
;         jz        VolObn3                  ; nen¡ platn˜ ROOT
;
;; ------ zji¨tˆn¡ po‡ te‡n¡ho sektoru ROOT
;
;         mov       ax,es:[16h]              ; po‡et sektor– jedn‚ tabulky FAT
;         shl       ax,1                     ; po‡et sektor– na obˆ tabulky FAT
;         jc        VolObn3                  ; chyba
;         add       ax,es:[0eh]              ; p©i‡ten¡ rezervovan˜ch sektor–
;         jc        VolObn3
;         xchg      ax,di                    ; DI <- ‡¡slo po‡ te‡n¡ho sektoru
;
;; ------ v˜po‡et adresy po‡ tku ROOT
;
;         mov       ax,512/16                ; po‡et odstavc– na sektor
;         mul       di                       ; offset
;         add       ax,ds:[BuffDat]          ; adresa sektoru
;         xchg      ax,dx                    ; DX <- adresa sektoru
;
;; ------ test, zda je platn˜ sektor
;
;VolObn5: cmp       di,ds:[BuffMax]          ; je to platn˜ sektor ?
;         jae       VolObn3                  ; nen¡ to platn˜ sektor
;
;; ------ prohled n¡ jednoho sektoru
;
;         mov       es,dx                    ; adresa sektoru
;         xor       bx,bx                    ; offset
;         mov       cx,16                    ; po‡et polo‘ek na sektor
;VolObn6: cmp       byte ptr es:[bx],0
;         je        VolObn3                  ; konec adres ©e
;         cmp       byte ptr es:[bx],0e5h
;         je        VolObn7                  ; zru¨en  polo‘ka
;         test      byte ptr es:[bx+0bh],bit3 ; je to n vˆ¨t¡ disku ?
;         jnz       VolObn1                  ; n vˆ¨t¡ disku nalezeno OK
;VolObn7: add       bx,32                    ; adresa dal¨¡ polo‘ky
;         loop      VolObn6                  ; test dal¨¡ polo‘ky
;
;; ------ zv˜¨en¡ adresy
;
;         inc       di                       ; zv˜¨en¡ ‡¡sla sektoru
;         add       dx,512/16                ; zv˜¨en¡ adresy v pamˆti
;         jmp       short VolObn5
;
;VolObnov ENDP
;
;; -----------------------------------------------------------------------------
;;        obnoven¡ dat z p–vodn¡ vadn‚ diskety (neuchov v  registry !)
;; -----------------------------------------------------------------------------
;
;ObnvOld  PROC      NEAR
;
;         or        byte ptr ds:[Param],bit1  ; je obnovovan  disketa
;
;; ------ p©ihl ¨en¡ diskety
;
;ObnvOld1:call      ReadBoot
;         call      CompDisk                 ; porovn n¡ parametr– disku
;         jnc       ObnvOl14                 ; disketa je OK
;
;; ------ disketa nen¡ shodn  (neuchov vat nic v z sobn¡ku - vrac¡ se !)
;
;         mov       si,offset FrmSTxt
;         mov       di,offset FrmSTxtM
;         call      Menu
;         cmp       al,"O"
;         je        ObnvOld1                 ; opakov n¡
;         cmp       al,"P"
;         je        ObnvOl12
;
;         and       byte ptr ds:[Param],not bit1
;         pop       ax                       ; zru¨en¡ n vratov‚ adresy
;         jmp       Gener4                   ; n vrat
;
;ObnvOl12:jmp       Prerus                   ; p©eru¨en¡
;
;; ------ p©¡prava k operaci na‡ten¡ disku
;
;ObnvOl14:call      Inst1E                   ; instalace INT 1Eh
;
;         mov       bp,offset ErrMap         ; mapa vadn˜ch sektor–
;
;         mov       cl,1                     ; maska v mapˆ
;         mov       ch,0                     ; ukazatel ‡¡sla v lce
;ObnvOld2:mov       dh,0                     ; ukazatel ‡¡sla strany
;
;; ------ na‡ten¡ jedn‚ stopy
;
;ObnvOld3:call      ReadTrck                 ; na‡ten¡ stopy
;
;; ------ identifika‡n¡ k¢d diskety
;
;         mov       al,ch
;         or        al,dh                    ; je stopa 0/strana 0 ?
;         jnz       ObnvOld4                 ; nen¡ stopa 0/strana 0
;         call      SumEDCI                  ; identifika‡n¡ k¢d
;
;; ------ p©¡prava k modifikaci sektor–
;
;ObnvOld4:mov       al,ds:[NumSekt]          ; po‡et sektor– ve stopˆ
;         xor       si,si
;ObnvOld5:test      byte ptr ds:[bp],cl      ; je sektor vadn˜ ?
;         jz        ObnvOld6                 ; sektor nen¡ vadn˜
;
;; ------ obnoven¡ sektoru
;
;         push      si
;         push      cx
;         push      ds
;
;         xor       di,di
;         mov       es,ds:[BuffUkaz]         ; ukazatel adresy
;         mov       ds,ds:[BuffDisk]         ; segment na‡ten‚ stopy
;         mov       cx,512/2                 ; po‡et slov
;         cld
;         rep       movsw                    ; p©enos sektoru
;
;         pop       ds
;         pop       cx
;         pop       si
;
;; ------ p©¡prava pro dal¨¡ sektor
;
;ObnvOld6:shl       cl,1                     ; posun masky v mapˆ
;         jnc       ObnvOld7
;         inc       bp                       ; zv˜¨en¡ ukazatele v mapˆ
;         mov       cl,1
;
;ObnvOld7:add       si,512
;         add       word ptr ds:[BuffUkaz],512/16 ; zv˜¨en¡ ukazatele v bufferu
;         dec       word ptr ds:[BuffCit]    ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch sektor–
;         jnz       ObnvOld9                 ; jsou dal¨¡ sektory
;         call      TempWrit                 ; z pis dat do souboru
;         call      TempRead                 ; na‡ten¡ dal¨¡ho bloku dat
;ObnvOld9:dec       al                       ; ‡¡ta‡ sektor–
;         jnz       ObnvOld5                 ; dal¨¡ sektor
;
;; ------ zv˜¨en¡ ukazatele ‡¡sla strany
;
;         inc       dh                       ; zv˜¨en¡ ‡¡sla strany
;         cmp       dh,ds:[NumStran]
;         jb        ObnvOld3                 ; ‡ten¡ dal¨¡ strany
;
;; ------ zv˜¨en¡ ukazatele ‡¡sla stopy
;
;         inc       ch                       ; zv˜¨en¡ ‡¡sla stopy
;         cmp       ch,ds:[NumStop]
;         jb        ObnvOld2                 ; ‡ten¡ dal¨¡ stopy
;
;; ------ ulo‘en¡ souboru
;
;         call      TempWrit                 ; z pis dat do souboru
;         call      MazText
;         call      DIns1E
;         and       byte ptr ds:[Param],not bit1
;         ret
;
;ObnvOld  ENDP
;
;; -----------------------------------------------------------------------------
;;        test, zda je sektor CH/DH/CL v mapˆ chyb (CY=je vadn˜)
;; -----------------------------------------------------------------------------
;
;TestErrM PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;
;; ------ v˜po‡et absolutn¡ho sektoru
;
;         mov       al,ch                    ; ‡¡slo v lce
;         mul       byte ptr ds:[NumStran]   ; p©epo‡et na absolutn¡ stopu
;         add       al,dh                    ; p©i‡ten¡ strany
;         mov       dh,0
;         adc       ah,dh
;         mov       dl,ds:[NumSekt]          ; po‡et sektor– na stopu
;         mul       dx                       ; p©epo‡et na sektory
;         dec       cx                       ; korekce ‡¡sla sektoru
;         add       al,cl                    ; p©i‡ten¡ ‡¡sla sektoru
;         adc       ah,0
;
;; ------ test sektoru v mapˆ
;
;         mov       cl,al                    ; ‡¡slo abs. sektoru
;         and       cl,7                     ; offset v bajtu
;         mov       ch,1                     ; maska
;         shl       ch,cl                    ; rotace masky na pozici
;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; offset bajtu
;         xchg      ax,si
;         test      ds:[si+ErrMap],ch        ; test bitu
;         jz        TestErM2                 ; nen¡ chyba
;         stc                                ; p©¡znak chyb
;
;; ------ n vrat registr–
;
;TestErM2:pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;TestErrM ENDP

; *****************************************************************************
;
;                       Funkce modifikace paritn¡ diskety
;
; *****************************************************************************
;ş
Modif    PROC      NEAR

; ------ zobrazen¡ n povˆdy

         mov       si,offset ModTxt
         call      StdOut                   ; zobrazen¡ v˜zvy k vlo‘en¡ diskety

;         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa ?
;         jz        Modif1                   ; nen¡
;         call      TempOpen                 ; vytvo©en¡ p©echodn‚ho souboru
;         cmp       word ptr ds:[OutpIdnt],0 ; je otev©en soubor ?
;         jne       Modif2                   ; soubor je otev©en OK
;
;; ------ potvrzen¡ operace
;
;Modif1:  mov       si,offset ObnTxt1
;         mov       di,offset ObnMnu1
;         call      Menu                     ; volba dal¨¡ operace
;         cmp       al,"D"
;         je        Modif2
;         call      XchgDsk                  ; v˜mˆna disku
;         jnc       Modif1
;Modif12: jmp       Prerus
;Modif2:  jmp       Gener2

Modif9:  ret

Modif    ENDP

; *****************************************************************************
;
;                     Funkce testu v¨ech disket archivu
;
; *****************************************************************************
;ş
TestT    PROC      NEAR

; ------ zobrazen¡ n povˆdy

         mov       si,offset TstVTxt
         call      StdOut                   ; zobrazen¡ v˜zvy k vlo‘en¡ diskety

;         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa ?
;         jz        TestV1                   ; nen¡
;         call      TempOpen                 ; vytvo©en¡ p©echodn‚ho souboru
;         cmp       word ptr ds:[OutpIdnt],0 ; je otev©en soubor ?
;         jne       TestV23                  ; soubor je otev©en OK
;
;; ------ potvrzen¡ operace
;
;TestV1:  mov       si,offset ObnTxt1
;         mov       di,offset ObnMnu1
;         call      Menu
;         call      XchgDsk
;         jnc       TestV1
;         cmp       al,"D"
;         je        TestV22
;TestV2:  jmp       Prerus                   ; konec
;
;; ------ p©ihl ¨en¡ diskety
;
;TestV22: call      TempOpen                 ; vytvo©en¡ p©echodn‚ho souboru
;TestV23: or        byte ptr ds:[Param],bit2
;         call      ReadBoot                 ; inicializace diskety
;         jc        TestV1                   ; p©eru¨en¡
;         call      InitDisk                 ; inicializace diskov˜ch parametr–
;         or        byte ptr ds:[Param],bit4+bit2 ; je paritn¡ disketa
;         call      VolParit                 ; n vˆ¨t¡ pro paritn¡ disketu
;
;; ------ na‡ten¡ diskety s operac¡ XOR
;
;TestV3:  mov       word ptr ds:[UspechS],0  ; £spˆ¨nost obnoven¡ sektor–
;         call      CtiDisk                  ; na‡ten¡ diskety
;         jnc       TestV31                  ; nen¡ p©eru¨en¡
;         test      byte ptr ds:[Param],bit2 ; je paritn¡ disketa ?
;         jnz       TestV1                   ; je paritn¡ disketa
;         jmp       short TestV4             ; dal¨¡ disketa
;TestV31: and       byte ptr ds:[Param],not bit2 ; nen¡ ur‡en  paritn¡ disketa
;
;; ------ dek¢dov n¡ ‡¡sla £spˆ¨nosti
;
;         xor       ax,ax
;         cmp       word ptr ds:[NDisket],1
;         jbe       TestV32
;         mov       ax,ds:[UspechS]          ; po‡et £spˆ‡n˜ch sektor–
;         mov       cx,100
;         mul       cx                       ; po‡et sektor– * 2
;         div       word ptr ds:[CelkSkt0]   ; £spˆ¨nost
;TestV32: push      ds
;         pop       es
;         mov       di,offset DiskUsp+2
;         mov       word ptr ds:[di-2],"  "
;         call      DekNum                   ; dek¢dov n¡ £spˆ¨nosti
;
;; ------ v˜zva k vlo‘en¡ dal¨¡ diskety
;
;TestV4:  mov       si,offset TstVTxt2
;         mov       di,offset TstVMnu2
;         call      Menu                     ; volba dal¨¡ operace
;         call      XchgDsk                  ; v˜mˆna diskety
;         jnc       TestV4
;         cmp       al,"K"
;         je        TestV6                   ; konec
;         cmp       al,"D"
;         jne       TestV2
;
;; ------ dal¨¡ disketa - test shodnosti parametr– diskety
;
;TestV5:  call      ReadBoot
;         jc        TestV4                   ; p©eru¨en¡
;         call      CompDisk                 ; porovn n¡ parametr– disku
;         jnc       TestV3                   ; na‡ten¡ dal¨¡ diskety
;
;; ------ disketa nen¡ shodn 
;
;         mov       si,offset FrmSTxt
;         mov       di,offset FrmSTxtM
;         call      Menu
;         jc        TestV4                   ; p©eru¨en¡
;         cmp       al,"O"
;         je        TestV5                   ; opakov n¡
;;         cmp       al,"N"
;;         je        TestV4                   ; n vrat
;         jmp       short TestV4
;;TestV52: jmp       short TestV2             ; p©eru¨en¡
;
;; ------ jsou ji‘ v¨echny diskety - test v˜sledku testu
;
;TestV6:  mov       si,offset TstV4Txt       ; chyba dat
;         mov       ax,ds:[UspechS]
;         cmp       ax,ds:[CelkSkt0]
;         jb        TestV8
;         mov       si,offset TstV3Txt
;TestV8:  call      StdOut                   ; hl ¨en¡

TestT9:  ret

TestT    ENDP

; *****************************************************************************
;
;                        Funkce testu jedn‚ diskety
;
; *****************************************************************************
;ş
Verif    PROC      NEAR

; ------ zobrazen¡ n povˆdy

         mov       si,offset VerfTxt
         call      StdOut                   ; zobrazen¡ v˜zvy k vlo‘en¡ diskety

;Test11:  mov       si,offset IdntTxt1
;         mov       di,offset IdntMnu1
;         call      Menu
;         cmp       al,"D"
;         je        Test13
;         call      XchgDsk                  ; zmˆna mechaniky
;         jnc       Test11                   ; byl povel "M"
;         jmp       INT23
;
;; ------ p©ihl ¨en¡ diskety
;
;Test13:  call      ReadBoot                 ; inicializace diskety
;         call      InitDisk                 ; inicializace diskov˜ch parametr–
;         call      VolParit                 ; korekce jmenovky pro paritn¡ disk
;
;; ------ na‡ten¡ diskety
;
;         call      CtiDisk                  ; na‡ten¡ disku
;         jmp       short Test11

Verif9:  ret

Verif    ENDP

; *****************************************************************************
;
;                        Identifika‡n¡ k¢d jedn‚ diskety
;
; *****************************************************************************
;ş
Ident    PROC      NEAR

; ------ zobrazen¡ n povˆdy

         mov       si,offset IdntTxt
         call      StdOut                   ; zobrazen¡ v˜zvy k vlo‘en¡ diskety


;Ident1:  mov       si,offset IdntTxt1
;         mov       di,offset IdntMnu1
;         call      Menu
;         cmp       al,"D"
;         je        Ident3
;         call      XchgDsk                  ; zmˆna mechaniky
;         jnc       Ident1                   ; byl povel "M"
;         jmp       INT23
;
;; ------ inicializace diskety
;
;Ident3:  call      ReadBoot                 ; inicializace diskety
;         call      InitDisk                 ; inicializace diskov˜ch parametr–
;         call      VolParit                 ; korekce jmenovky pro paritn¡ disk
;
;; ------ na‡ten¡ stopy
;
;         mov       ch,0                     ; ukazatel ‡¡sla v lce
;         mov       dh,0                     ; ukazatel ‡¡sla strany
;         call      Inst1E                   ; instalace INT 1Eh
;         call      ReadTrck                 ; na‡ten¡ stopy
;         call      DIns1E
;
;; ------ identifika‡n¡ k¢d diskety
;
;         call      SumEDCI                  ; identifika‡n¡ k¢d
;         inc       word ptr ds:[NDisket]    ; zv˜¨en¡ ‡¡sla diskety
;         call      DekNDisk                 ; dek¢dov n¡ ‡¡sla diskety
;         mov       si,offset IdntTxt2       ; text
;         call      StdOut0                  ; zobrazen¡ textu
;         jmp       short Ident1             ; dal¨¡ disketa

Ident9:  ret

Ident    ENDP

; -----------------------------------------------------------------------------
;        funkce ‡ten¡ diskety
; -----------------------------------------------------------------------------
;ş
ReadD    PROC      NEAR

ReadD9:  ret

ReadD    ENDP

; -----------------------------------------------------------------------------
;        funkce z pisu diskety
; -----------------------------------------------------------------------------
;ş
WritD    PROC      NEAR

WritD9:  ret

WritD    ENDP

; -----------------------------------------------------------------------------
;        kop¡rov n¡ diskety
; -----------------------------------------------------------------------------
;ş
CopyD    PROC      NEAR

CopyD9:  ret

CopyD    ENDP

;; *****************************************************************************
;;
;;                       Obslu‘n‚ procedury funkc¡
;;
;; *****************************************************************************
;;ş
;; -----------------------------------------------------------------------------
;;     na‡ten¡ cel‚ diskety s funkc¡ XOR (neuchov v  registry !) (CY p©eru¨en¡)
;; -----------------------------------------------------------------------------
;
;CtiDisk  PROC      NEAR
;
;; ------ p©¡prava k operaci na‡ten¡ disku
;
;         call      Inst1E                   ; instalace INT 1Eh
;         mov       ch,0                     ; ukazatel ‡¡sla v lce
;CtiDisk2:mov       dh,0                     ; ukazatel ‡¡sla strany
;
;; ------ na‡ten¡ jedn‚ stopy
;
;CtiDisk3:call      ReadTrck                 ; na‡ten¡ stopy
;         call      TstBreak
;         jc        CtiDisk8                 ; p©eru¨en¡
;         call      SetEMap                  ; nastaven¡ mapy chyb
;
;; ------ identifika‡n¡ k¢d diskety
;
;         mov       al,ch
;         or        al,dh                    ; je stopa 0/strana 0 ?
;         jnz       CtiDisk4                 ; nen¡ stopa 0/strana 0
;         call      SumEDCI                  ; identifika‡n¡ k¢d
;
;; ------ kontroln¡ sou‡et stopy
;
;CtiDisk4:call      CheckSm0                 ; kontroln¡ sou‡et stopy
;
;; ------ proveden¡ operace XOR paritn¡ diskety s na‡ten˜mi daty
;
;         test      byte ptr ds:[Operace],bit3 ; je verifikace diskety ?
;         jnz       CtiDisk5                 ; je verifikace
;
;         xor       si,si                    ; ukazatel adresy
;         mov       al,ds:[NumSekt]          ; po‡et sektor– na stopu
;         call      XORSekt                  ; proveden¡ operace XOR
;
;; ------ identifika‡n¡ k¢d paritn¡ diskety
;
;         mov       al,ch
;         or        al,dh                    ; je stopa 0/strana 0 ?
;         jnz       CtiDisk5                 ; nen¡ stopa 0/strana 0
;
;         mov       es,ds:[BuffDat]          ; buffer stopy
;         xor       bx,bx
;         call      SetSekt                  ; nastaven¡ parametr– BOOT sektoru
;         call      SumEDCP                  ; identifika‡n¡ k¢d parit. diskety
;
;; ------ zv˜¨en¡ ukazatele ‡¡sla strany
;
;CtiDisk5:call      TestEsc                  ; test p©eru¨en¡
;         jc        CtiDisk8                 ; je p©eru¨en¡ operace
;         inc       dh                       ; zv˜¨en¡ ‡¡sla strany
;         cmp       dh,ds:[NumStran]
;         jb        CtiDisk3                 ; ‡ten¡ dal¨¡ strany
;
;; ------ zv˜¨en¡ ukazatele ‡¡sla stopy
;
;         inc       ch                       ; zv˜¨en¡ ‡¡sla stopy
;         cmp       ch,ds:[NumStop]
;         jb        CtiDisk2                 ; ‡ten¡ dal¨¡ stopy
;
;CtiDisk8:call      TempWrit                 ; z pis dat do souboru
;         call      MazText
;         call      DIns1E
;
;         call      TstBreak                 ; test p©eru¨en¡ operace
;         jc        CtiDisk9                 ; p©eru¨en¡ operace
;
;         call      TempXchg                 ; za©azen¡ diskety
;         inc       word ptr ds:[NDisket]    ; zv˜¨en¡ ‡¡sla diskety
;         call      DekNDisk                 ; dek¢dov n¡ ‡¡sla diskety
;         call      DispEDC                  ; zobrazen¡ kontroln¡ho sou‡tu
;         clc
;CtiDisk9:ret
;
;CtiDisk  ENDP
;
;; -----------------------------------------------------------------------------
;;        nastaven¡ mapy chyb podle chyb stopy CH/strana DH
;; -----------------------------------------------------------------------------
;
;SetEMap  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      di
;
;; ------ v˜po‡et absolutn¡ho sektoru
;
;         mov       al,ch                    ; stopa
;         mul       byte ptr ds:[NumStran]   ; ‡¡slo stopy absolutnˆ
;         add       al,dh                    ; p©i‡ten¡ ‡¡sla strany
;         adc       ah,0
;         mov       cl,ds:[NumSekt]          ; po‡et sektor– na stopu
;         mov       ch,0
;         mul       cx                       ; v˜po‡et absolutn¡ho sektoru
;
;; ------ adresa v mapˆ chyb
;
;         mov       cl,al
;         and       cl,7                     ; offset v bajtu
;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; offset v mapˆ
;         add       ax,offset ErrMap         ; adresa v mapˆ chyb
;         xchg      ax,di                    ; DI <- ukazatel v mapˆ chyb
;
;; ------ p©¡prava k dek¢dov n¡ mapy chyb
;
;         mov       si,offset TrckMap        ; mapa stopy
;         mov       dl,ds:[NumSekt]          ; po‡et sektor– na stopu
;         mov       ch,1                     ; maska
;         shl       ch,cl                    ; rotace masky na pozici
;
;; ------ nastaven¡ mapy
;
;SetEMap2:cmp       byte ptr ds:[si],0       ; byla chyba ?
;         je        SetEMap3                 ; nebyla chyba
;         or        byte ptr ds:[di],ch      ; nastaven¡ p©¡znaku chyby
;SetEMap3:inc       si
;         shl       ch,1
;         jnc       SetEMap4
;         mov       ch,1
;         inc       di
;SetEMap4:dec       dl
;         jnz       SetEMap2
;
;; ------ n vrat registr–
;
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;SetEMap  ENDP
;
;; -----------------------------------------------------------------------------
;;        z pis cel‚ diskety (neuchov v  registry !) -> CY p©eru¨en¡
;; -----------------------------------------------------------------------------
;
;ZapDisk  PROC      NEAR
;
;; ------ p©¡prava k z pisu diskety
;
;         call      Inst1E
;         mov       ch,0                     ; ukazatel ‡¡sla v lce
;ZapDisk2:mov       dh,0                     ; ukazatel ‡¡sla strany
;
;; ------ na‡ten¡ stopy z p©echodn‚ho souboru
;
;ZapDisk3:call      ReadTTrc                 ; na‡ten¡ stopy z p©ech. bufferu
;         mov       al,ch
;         or        al,dh                    ; je prvn¡ stopa ?
;         jnz       ZapDisk4                 ; nen¡ prvn¡ stopa
;
;; ------ korekce pro prvn¡ stopu
;
;         mov       es,ds:[BuffDisk]         ; buffer stopy
;         xor       bx,bx
;         call      SetSekt                  ; nastaven¡ parametr– BOOT sektoru
;         call      SumEDCI                  ; identifika‡n¡ k¢d
;         call      SumEDCP                  ; k¢d paritn¡ diskety
;
;; ------ kontroln¡ sou‡et diskety
;
;ZapDisk4:call      CheckSm0                 ; kontroln¡ sou‡et stopy
;
;; ------ z pis stopy na disketu
;
;         call      WritTrck                 ; z pis stopy
;         jc        ZapDisk8                 ; p©eru¨en¡ operace
;         call      TestEsc                  ; test p©eru¨en¡
;         jc        ZapDisk8                 ; je p©eru¨en¡ operace
;
;; ------ zv˜¨en¡ ukazatele ‡¡sla strany
;
;         inc       dh                       ; zv˜¨en¡ ‡¡sla strany
;         cmp       dh,ds:[NumStran]
;         jb        ZapDisk3                 ; z pis dal¨¡ strany
;
;; ------ zv˜¨en¡ ukazatele ‡¡sla stopy
;
;         inc       ch                       ; zv˜¨en¡ ‡¡sla stopy
;         cmp       ch,ds:[NumStop]
;         jb        ZapDisk2                 ; ‡ten¡ dal¨¡ stopy
;
;ZapDisk8:call      MazText
;         call      DIns1E                   ; odinstalov n¡ INT 1Eh
;
;; ------ zobrazen¡ informa‡n¡ho textu
;
;         call      TstBreak
;         jc        ZapDisk9                 ; p©eru¨en¡
;         inc       word ptr ds:[NDisket]    ; zv˜¨en¡ ‡¡sla diskety
;         call      DekNDisk                 ; dek¢dov n¡ ‡¡sla diskety
;         call      DispEDC                  ; zobrazen¡ kontroln¡ho sou‡tu
;         clc
;ZapDisk9:ret
;
;ZapDisk  ENDP
;
;; -----------------------------------------------------------------------------
;; operace XOR AL sektor– SI s bufferem (posouv  se ukazatel) DH=strana, CH=stopa
;; -----------------------------------------------------------------------------
;
;XORSekt  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      es
;
;; ------ p©¡prava registr–
;
;         mov       bl,dh                    ; strana
;         mov       bh,ch                    ; stopa
;         mov       dh,0
;         mov       dl,al                    ; po‡et sektor–
;
;; ------ proveden¡ operace XOR s jedn¡m sektorem
;
;XORSekt2:push      ds
;         cld
;         xor       di,di
;         mov       es,ds:[BuffUkaz]         ; ukazatel sektoru
;         mov       ds,ds:[BuffDisk]         ; buffer stopy
;         mov       cx,100h                  ; 256 slov
;XORSekt3:lodsw                              ; na‡ten¡ slova
;         xor       es:[di],ax               ; XOR
;         inc       di
;         inc       di
;         loop      XORSekt3                 ; dal¨¡ slovo
;         pop       ds
;
;; ------ zji¨tˆn¡, zda je sektor = 0
;
;         test      byte ptr ds:[Operace],bit2 ; je test v¨ech disket ?
;         jz        XORSekt4                 ; nen¡ test v¨ech disket
;
;         xor       ax,ax
;         or        bx,bx                    ; je BOOT stopa ?
;         jnz       XORSkt32                 ; nen¡ BOOT stopa
;         cmp       si,512+2                 ; je BOOT sektor ?
;         ja        XORSkt32                 ; nen¡ BOOT sektor
;
;         test      byte ptr ds:[Param],bit3 ; nekompatibiln¡ BOOT ?
;         jnz       XORSkt32                 ; nekompatibiln¡ BOOT
;
;         mov       es:[0bh],ax              ; po‡et bajt– na sektor
;         mov       es:[18h],ax              ; po‡et sektor– na stopu
;         mov       es:[1ah],ax              ; po‡et stran
;         mov       es:[13h],ax              ; celkov˜ po‡et sektor–
;
;XORSkt32:xor       di,di
;         mov       ch,1                     ; 256 slov
;         repe      scasw                    ; test, zda je 0
;         jne       XORSekt4                 ; sektor nen¡ = 0
;         inc       word ptr ds:[UspechS]    ; ‡¡ta‡ £spˆ¨n˜ch sektor–
;
;; ------ posun ukazatele k dal¨¡mu sektoru
;
;XORSekt4:add       word ptr ds:[BuffUkaz],512/16 ; zv˜¨en¡ ukazatele v bufferu
;         dec       word ptr ds:[BuffCit]    ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch sektor–
;         jnz       XORSekt5                 ; jsou dal¨¡ sektory
;         call      TempWrit                 ; z pis dat do souboru
;         call      TempRead                 ; na‡ten¡ dal¨¡ho bloku dat
;XORSekt5:dec       dx                       ; ‡¡ta‡ sektor–
;         jnz       XORSekt2                 ; dal¨¡ sektor
;
;; ------ n vrat registr–
;
;         pop       es
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;XORSekt  ENDP
;
;; -----------------------------------------------------------------------------
;;        inicializace diskov˜ch parametr–
;; -----------------------------------------------------------------------------
;
;InitDisk PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;
;; ------ po‡et sektor– na stopu
;
;         mov       al,ds:[NumSekt0]
;         mov       ds:[NumSekt],al          ; po‡et sektor– na stopu
;         mov       ds:[LastSekt],al         ; posledn¡ sektor na stopˆ
;
;; ------ po‡et stran disku
;
;         mov       al,ds:[NumStrn0]
;         mov       ds:[NumStran],al         ; po‡et stran disku
;
;; ------ celkem sektor–
;
;         mov       ax,ds:[CelkSkt0]
;         mov       ds:[CelkSekt],ax         ; celkem sektor–
;
;; ------ po‡et v lc– disku
;
;         mov       al,ds:[NumStop0]
;         mov       ds:[NumStop],al          ; po‡et stop
;
;; ------ n vrat registr–
;
;         pop       ax
;         ret
;
;InitDisk ENDP
;
;; -----------------------------------------------------------------------------
;;        porovn n¡ parametr– diskety (CY=nen¡ shoda)
;; -----------------------------------------------------------------------------
;
;CompDisk PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;
;; ------ po‡et sektor– na stopu
;
;         mov       al,ds:[NumSekt0]
;         cmp       al,ds:[NumSekt]          ; po‡et sektor– na stopu
;         jne       CompDsk1
;
;; ------ po‡et stran disku
;
;         mov       al,ds:[NumStrn0]
;         cmp       al,ds:[NumStran]         ; po‡et stran disku
;         jne       CompDsk1
;
;; ------ celkem sektor–
;
;         mov       ax,ds:[CelkSkt0]
;         cmp       ax,ds:[CelkSekt]         ; celkem sektor–
;         je        CompDsk2
;
;; ------ n vrat registr–
;
;CompDsk1:stc                                ; p©¡znak neshody parametr–
;CompDsk2:pop       ax
;         ret
;
;CompDisk ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ BOOT sektoru (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------
;ş
ReadBoot PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ instalace tabulky 1E

         and       byte ptr ds:[Param2],not bit3 ; BOOT je platn˜
         call      Inst1E                   ; instalace INT 1Eh

; ------ zobrazen¡ hl ¨en¡ o na‡¡t n¡ parametr– diskety

ReadBot1:mov       si,offset InitTxt        ; text "nacitam parametry"
         call      StdErrA                  ; zobrazen¡ hl ¨en¡ o na‡¡t n¡

; ------ na‡ten¡ BOOT sektoru diskety

         xor       bx,bx                    ; offset bufferu
         mov       es,ds:[BuffDisk]         ; segment bufferu
         mov       cx,1                     ; stopa=0, sektor=1
         mov       dh,0                     ; strana=0
         mov       al,1                     ; po‡et sektor–
         call      ReadSekt                 ; na‡ten¡ BOOT sektoru

; ------ vymaz n¡ hl ¨en¡ o na‡¡t n¡

         call      MazText                  ; vymaz n¡ hl ¨en¡
         jnc       ReadBot2                 ; operace OK

; ------ chyba - test, zda je p©eru¨en¡ operace

         call      TstBreak                 ; test p©eru¨en¡
         jnc       ReadBt12                 ; nen¡ p©eru¨en¡ - je chyba
ReadBt11:call      SetBreak                 ; nastaven¡ p©¡znaku p©eru¨en¡
         jmp       ReadBot9                 ; je p©eru¨en¡

; ------ vynulov n¡ sektoru p©i chybˆ

ReadBt12:mov       al,0                     ; nulovac¡ bajt
         call      NulSekt                  ; nulov n¡ sektoru
         call      SetSekt                  ; nastaven¡ parametr– BOOT sektoru

; ------ p©i chybˆ dotaz na dal¨¡ operaci

         mov       si,offset ErrBMnuM
         call      Menu                     ; volba dal¨¡ operace
         call      JumpAL                   ; skok na obsluhu

         db        'O'
         dw        ReadBot1                 ; opakov n¡

         db        'D'
         dw        ReadBot2                 ; d le

         db        0
         dw        ReadBt11                 ; p©eru¨en¡

; ------ kontrola platnosti parametr– sektoru ES:BX

ReadBot2:call      TestDisk                 ; test parametr– disku ES:BX
         jnc       ReadBot4                 ; parametry diskety jsou OK
         or        byte ptr ds:[Param],bit3 ; nekompatibiln¡ BOOT
         mov       byte ptr ds:[NumSekt0],8 ; po‡et sektor– na stopu
         mov       byte ptr ds:[NumStrn0],1 ; po‡et stran disku
         mov       word ptr ds:[CelkSkt0],8*40 ; celkem sektor–
         mov       byte ptr ds:[NumStop0],40 ; po‡et stop
;ş
;         call      MazText                  ; vymaz n¡ hl ¨en¡
;         mov       si,offset FormTxt
;         mov       di,offset FormTxtM
;         call      Menu                     ; volba
;         cmp       al,"O"
;         je        ReadBot1                 ; opakov n¡
;         jmp       short ReadBot2           ; p©eru¨en¡

; ------ vymaz n¡ buffer– jmenovky diskety

ReadBot4:push      es
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,offset MazTTxt1       ; sam‚ mezery
         call      CopyLab                  ; kopie do buffer–
         pop       es

; ------ inicializace jmenovky diskety, test paritn¡ diskety

         test      byte ptr ds:[Param2],bit3 ; nekompatibiln¡ BOOT ?
         jnz       ReadBt52                 ; je nekompatibiln¡ BOOT
         or        byte ptr ds:[Param2],bit4 ; je paritn¡ disketa
         cmp       byte ptr es:[10h],0      ; je polo‘ka tabulek FAT ?
         je        ReadBot6                 ; z©ejmˆ to je sud  paritn¡ disketa
         mov       bx,2bh                   ; jmenovka pro DOS 4
         cmp       byte ptr es:[bx+26h-2bh],29h ; je to roz¨¡©en˜ sektor ?
         je        ReadBot5                 ; je jmenovka diskety
         call      ReadLab                  ; na‡ten¡ jmenovky diskety -> BX
         jc        ReadBt52                 ; chyba, ale asi nen¡ paritn¡ disk
ReadBot5:call      TestLab                  ; test jmenovky diskety ES:BX
         jc        ReadBot6                 ; jmenovka neplat¡, asi paritn¡ disk
         call      CopyLab                  ; kopie jmenovky disku ES:BX
ReadBt52:and       byte ptr ds:[Param2],not bit4 ; z©ejmˆ nen¡ paritn¡ disketa

;; ------ jmenovka NO NAME je neplatn 
;
;ReadBot6:call      VolParit                 ; korekce pro paritn¡ disketu
;         push      ds
;         pop       es
;         mov       si,offset NoNamTxt       ; jmenovka "NO NAME"
;         mov       di,offset CtuTxt1
;         mov       cx,11
;         cld
;         repe      cmpsb                    ; je to jmenovka NO NAME ?
;         jne       ReadBot7                 ; nen¡ NO NAME
;         mov       bx,offset MazTTxt1       ; sam‚ mezery
;         call      CopyLab                  ; vymaz n¡ jmenovky
;
;; ------ inicializace ukazatel– disku

;ReadBot7:call      TstBreak
;         jc        ReadBot8                 ; p©eru¨en¡
;         call      TempRes                  ; resetov n¡ p©echodn‚ho souboru
;         call      TempRead                 ; na‡ten¡ p©echodn‚ho souboru
;         mov       word ptr ds:[EDC],-1     ; inicializa‡n¡ hodnota EDC
;         mov       word ptr ds:[EDCIdent],-1 ; identifika‡n¡ k¢d diskety
;         call      DekEDCI                  ; dek¢dov n¡ identifika‡n¡ho k¢du
;         call      DekFDsk                  ; dek¢dov n¡ form tu disku

; ------ odinstalov n¡ obsluhy (CF=p©¡znak operace)

ReadBot9:call      DIns1E                   ; odinstalov n¡ tabulky INT 1Eh

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBoot ENDP

;; -----------------------------------------------------------------------------
;;        test jmenovky disku ES:BX -> CY neplatn 
;; -----------------------------------------------------------------------------
;
;TestLab  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      si
;
;; ------ test jmenovky, zda nen¡ < 32 a zda to nejsou mal  p¡smena
;
;         mov       cx,11
;         cmp       byte ptr es:[bx]," "+1   ; prvn¡ znak nesm¡ b˜t ani mezera
;         jb        TestLab9                 ; zak zan˜ znak
;TestLab1:mov       al,es:[bx]
;         inc       bx
;         cmp       al," "
;         jb        TestLab9
;         cmp       al,"a"
;         jb        TestLab2
;         cmp       al,"z"+1
;         jb        TestLab9
;
;; ------ test jmenovky podle tabulky zak zan˜ch znak–
;
;TestLab2:mov       si,offset BlokTab        ; tabulka zak zan˜ch znak–
;TestLab3:cmp       al,cs:[si]
;         stc
;         je        TestLab9                 ; zak zan˜ znak
;         inc       si
;         cmp       byte ptr cs:[si],0
;         jne       TestLab3
;         loop      TestLab1
;;         clc                                ; p©¡znak operace OK
;
;; ------ n vrat registr–
;
;TestLab9:pop       si
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;TestLab  ENDP
;
;BlokTab  db        '"*+,./:;<=>?[\]|',0

; -----------------------------------------------------------------------------
;        kopie jmenovky ES:BX do buffer–
; -----------------------------------------------------------------------------

CopyLab  PROC      NEAR

         push      cx
         push      si
         push      di

         mov       di,offset CtuTxt1        ; "‡tu disketu"
         call      CopyLab0
         mov       di,offset ZapTxt1        ; "zapisuji disketu"
         call      CopyLab0
         mov       di,offset NactTxt1       ; "na‡tena disketa"
         call      CopyLab0
         mov       di,offset IdntTx22       ; "identifikov na disketa"
         call      CopyLab0

         pop       di
         pop       si
         pop       cx
         ret

CopyLab  ENDP

CopyLab0 PROC      NEAR

         push      ds
         push      es

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         pop       es                       ; ES <- datov˜ segment
         mov       si,bx                    ; SI <- offset vzoru jmenovky
         mov       cx,11
         cld
         rep       movsb

         pop       es
         pop       ds
         ret

CopyLab0 ENDP

;; -----------------------------------------------------------------------------
;;        na‡ten¡ jmenovky disku z ROOT
;; -----------------------------------------------------------------------------
;; VSTUP: ES=segment na‡ten‚ho BOOT sektoru
;; VSTUP: BX=offset nalezen‚ jmenovky disku
;;         CY=chyba, p©eru¨en¡ nebo jmenovka nenalezena
;; -----------------------------------------------------------------------------
;
;ReadLab  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      bp
;
;; ------ zji¨tˆn¡ po‡tu sektor– ROOT
;
;         test      byte ptr ds:[Param],bit3
;         jnz       ReadLab0                 ; neplatn˜ BOOT
;
;         mov       bp,es:[11h]              ; po‡et polo‘ek ROOT
;         shr       bp,1
;         shr       bp,1
;         shr       bp,1
;         shr       bp,1                     ; po‡et sektor– ROOT
;         jnz       ReadLab1
;ReadLab0:jmp       ReadLab8                 ; neplatn˜ po‡et polo‘ek ROOT
;
;; ------ zji¨tˆn¡ po‡ te‡n¡ho sektoru ROOT
;
;ReadLab1:cmp       byte ptr es:[10h],2      ; jsou 2 tabulky FAT ?
;         jne       ReadLab8                 ; nekompatibiln¡ disketa
;         mov       ax,es:[16h]              ; po‡et sektor– jedn‚ tabulky FAT
;         shl       ax,1                     ; po‡et sektor– na obˆ tabulky FAT
;         jc        ReadLab8                 ; chyba
;         add       ax,es:[0eh]              ; p©i‡ten¡ rezervovan˜ch sektor–
;         jc        ReadLab8
;
;; ------ kontrola p©ete‡en¡ konce ROOT p©es konec disku
;
;         mov       cx,ax
;         add       cx,bp                    ; p©i‡ten¡ po‡tu sektor– ROOT
;         jc        ReadLab8
;         cmp       cx,es:[13h]              ; kontrola p©ete‡en¡ konce disku
;         jae       ReadLab8                 ; p©ete‡en¡ konce disku
;
;; ------ p©epo‡et na ukazatele sektoru BIOS
;
;         mov       cl,ds:[NumSekt0]         ; po‡et sektor– na stopu
;         cmp       byte ptr ds:[NumStrn0],2 ; jsou 2 strany ?
;         jb        ReadLab2                 ; nejsou 2 strany
;         shl       cl,1                     ; po‡et sektor– pro 2 strany
;ReadLab2:div       cl                       ; v˜po‡et ‡¡sla v lce
;         mov       ch,al                    ; CH <- ‡¡slo v lce
;         mov       al,ah                    ; AL <- sektor na v lci
;         mov       ah,0
;         div       byte ptr ds:[NumSekt0]   ; vydˆlen¡ po‡tem sektor– na stopu
;         mov       cl,ah                    ; ‡¡slo sektoru
;         inc       cx                       ; korekce ‡¡sla sektoru
;         mov       dh,al                    ; ‡¡slo strany
;
;; ------ na‡ten¡ 1 sektoru do bufferu
;
;ReadLab3:xor       bx,bx
;         mov       al,1                     ; 1 sektor
;         call      ReadSekt                 ; na‡ten¡ 1 sektoru ROOT
;         jc        ReadLab8                 ; nˆjak  chyba
;
;; ------ prohled n¡ jednoho sektoru
;
;         mov       si,16                    ; po‡et polo‘ek na sektor
;ReadLab4:cmp       byte ptr es:[bx],0
;         je        ReadLab8                 ; konec adres ©e
;         cmp       byte ptr es:[bx],0e5h
;         je        ReadLab5                 ; zru¨en  polo‘ka
;         test      byte ptr es:[bx+0bh],bit3 ; je to n vˆ¨t¡ disku ?
;         jnz       ReadLab9                 ; n vˆ¨t¡ disku nalezeno OK
;ReadLab5:add       bx,32                    ; adresa dal¨¡ polo‘ky
;         dec       si
;         jnz       ReadLab4                 ; test dal¨¡ polo‘ky
;
;; ------ ‡¡ta‡ zbyl˜ch sektor– ROOT
;
;         dec       bp                       ; ‡¡ta‡ sektor– ROOT
;         jz        ReadLab8                 ; nen¡ dal¨¡ sektor
;
;; ------ zv˜¨en¡ ‡¡sla sektoru
;
;         inc       cx
;         cmp       cl,ds:[NumSekt0]         ; je ji‘ konec stopy ?
;         jbe       ReadLab3                 ; na‡ten¡ dal¨¡ho sektoru
;         mov       cl,1
;
;; ------ zv˜¨en¡ ‡¡sla strany
;
;         inc       dh                       ; zv˜¨en¡ ‡¡sla strany
;         cmp       dh,ds:[NumStrn0]         ; jsou ji‘ v¨echny strany ?
;         jb        ReadLab3                 ; na‡ten¡ dal¨¡ho sektoru
;         mov       dh,0
;
;; ------ zv˜¨en¡ ‡¡sla stopy
;
;         inc       ch
;         jmp       short ReadLab3
;
;; ------ n vrat registr–
;
;ReadLab8:stc
;ReadLab9:pop       bp
;         pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;ReadLab  ENDP

; -----------------------------------------------------------------------------
;        test parametr– disku ES:BX (z na‡ten‚ho BOOT sektoru) -> CY chyba
; -----------------------------------------------------------------------------

TestDisk PROC      NEAR

         push      ax
         push      cx
         push      dx

; ------ velikost sektoru

         cmp       word ptr es:[bx+0bh],512 ; po‡et bajt– na sektor
         jne       TestDsk8                 ; nespr vn  velikost sektoru

; ------ po‡et sektor– na stopu -> CX

         mov       ax,es:[bx+18h]           ; po‡et sektor– na stopu
         cmp       ax,MAXSEKT               ; maximum sektor–
         ja        TestDsk8                 ; p©¡li¨ velk˜ po‡et sektor–
         cmp       al,4                     ; minimum sektor–
         jb        TestDsk8                 ; p©¡li¨ mal˜ po‡et sektor–
         mov       ds:[NumSekt0],al         ; po‡et sektor– na stopu
         xchg      ax,cx                    ; CX <- po‡et sektor– na stopu

; ------ po‡et stran disku -> AL

         mov       ax,es:[bx+1ah]           ; po‡et stran disku
         cmp       ax,MAXSIDE               ; maximum stran
         ja        TestDsk8                 ; p©¡li¨ velk˜ po‡et stran
         cmp       al,1                     ; minimum stran
         jb        TestDsk8                 ; p©¡li¨ mal˜ po‡et stran
         mov       ds:[NumStrn0],al         ; po‡et stran disku

; ------ po‡et sektor– pro v¨echny strany -> CX

         mul       cx                       ; po‡et sektor– pro v¨echny strany
         xchg      ax,cx                    ; CX <- sektor– pro v¨echny strany

; ------ po‡et v lc– disku

         mov       ax,es:[bx+13h]           ; celkov˜ po‡et sektor–
         mov       ds:[CelkSkt0],ax         ; celkem sektor–
         add       ax,cx                    ; p©enos pro zaokrouhlen¡
         dec       ax                       ; bez 1 sektoru
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; v˜po‡et po‡tu v lc–
         cmp       ax,MAXTRACK              ; maxim ln¡ po‡et stop
         ja        TestDsk8                 ; p©¡li¨ velk˜ po‡et stop
         cmp       al,20                    ; minim ln¡ po‡et stop
         jb        TestDsk8                 ; p©¡li¨ mal˜ po‡et stop
         mov       ds:[NumStop0],al         ; po‡et stop
         jmp       short TestDsk9         ;* (zde je NC !)

; ------ chyba parametr– diskety

TestDsk8:stc                                ; p©¡znak neplatn˜ch parametr–
TestDsk9:pop       dx
         pop       cx
         pop       ax
         ret

TestDisk ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ parametr– BOOT sektoru ES:BX
; -----------------------------------------------------------------------------

SetSekt  PROC      NEAR

         push      ax

         test      byte ptr ds:[Param2],bit3 ; je BOOT platn˜ ?
         jnz       SetSekt2                 ; neplatn˜ BOOT

         mov       word ptr es:[bx+0bh],512 ; po‡et bajt– na sektor
         mov       ah,0
         mov       al,ds:[NumSekt]
         mov       es:[bx+18h],ax           ; po‡et sektor– na stopu
         mov       al,ds:[NumStran]
         mov       es:[bx+1ah],ax           ; po‡et stran
         mov       ax,ds:[CelkSekt]
         mov       es:[bx+13h],ax           ; celkov˜ po‡et sektor–

SetSekt2:pop       ax
         ret

SetSekt  ENDP

; *****************************************************************************
;
;                   Univerz ln¡ obsluha diskety
;
; *****************************************************************************
;ş
; -----------------------------------------------------------------------------
;        instalace tabulky INT 1Eh
; -----------------------------------------------------------------------------

Inst1E   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda je tabulka ji‘ nainstalov na

         test      byte ptr ds:[Param],bit6 ; je nainstalov n ?
         jnz       Inst1E4                  ; je ji‘ nainstalov n

; ------ £schova adresy INT 1Eh

         mov       ax,351eh
         int       21h                      ; poskytnut¡ adresy INT 1Eh
         mov       word ptr ds:[Old1E],bx
         mov       word ptr ds:[Old1E+2],es

; ------ p©enos tabulky do vlastn¡ho bufferu

         push      ds
         push      es
         push      ds
         pop       es                       ; ES <- datov˜ segment
         pop       ds                       ; DS <- segment tabulky
         mov       si,bx                    ; SI <- offset tabulky
         mov       di,offset Tab1E          ; vlastn¡ tabulka INT 1Eh
         mov       dx,di                    ; adresa tabulky
         mov       cx,offset(Tab1E0-Tab1E)  ; d‚lka tabulky
         cld
         rep       movsb                    ; £schova tabulky
         pop       ds

; ------ p©edefinov n¡ adresy INT 1Eh

         mov       ax,251eh
         int       21h                      ; definice adresy INT 1Eh
         or        byte ptr ds:[Param],bit6 ; p©¡znak nainstalov n¡

; ------ p©edefinov n¡ po‡tu sektor– na stopu

Inst1E4: mov       byte ptr ds:[LastSekt],MAXSEKT ; posledn¡ sektor na stopˆ
         mov       byte ptr ds:[LastTrck],MAXTRACK-1 ; posledn¡ stopa
         mov       byte ptr ds:[SektSize],2 ; velikost sektoru 512 bajt–

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Inst1E   ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ tabulky INT 1Eh (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------

DIns1E   PROC      NEAR

         pushf

         test      byte ptr ds:[Param],bit6 ; nainstalov no ?
         jz        DIns1E4                  ; INT 1Eh nen¡ nainstalov no

         push      ax
         push      dx
         push      ds

         lds       dx,ds:[Old1E]            ; p–vodn¡ adresa INT 1Eh
         mov       ax,251eh
         int       21h                      ; n vrat adresy INT 1Eh

         pop       ds
         pop       dx
         pop       ax
         and       byte ptr ds:[Param],not bit6 ; p©¡znak, ‘e nen¡ instalov no

DIns1E4: popf
         ret

DIns1E   ENDP

;; -----------------------------------------------------------------------------
;;        z pis stopy na disketu (CH=stopa, DH=strana -> CY p©eru¨en¡)
;; -----------------------------------------------------------------------------
;
;WritTrck PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      es
;
;; ------ zobrazen¡ hl ¨en¡ o z pisu stopy
;
;WritTrc1:mov       cl,1                     ; ‡¡slo po‡ te‡n¡ho sektoru
;         call      PrepN13                  ; p©¡prava ‡¡sla stopy
;         mov       si,offset ZapTxt
;         call      StdErrA                  ; zobrazen¡ hl ¨en¡
;
;; ------ z pis stopy vcelku
;
;         xor       bx,bx                    ; offset bufferu
;         mov       es,ds:[BuffDisk]         ; adresa bufferu
;         mov       al,ds:[NumSekt]          ; po‡et sektor– na stopu
;         call      WritSekt                 ; z pis dat z bufferu
;         jc        WritTrc2                 ; chyba z pisu
;
;; ------ zpˆtn‚ na‡ten¡ stopy
;
;         mov       es,ds:[BuffDskV]         ; buffer verifikovan‚ stopy
;         call      ReadSekt                 ; na‡ten¡ stopy zpˆt
;         jc        WritTrc2                 ; chyba z pisu
;
;; ------ porovn n¡ dat stopy
;
;         push      cx
;         push      ds
;         xor       si,si
;         xor       di,di
;         mov       ch,al                    ; CH <- po‡et sektor–
;         mov       cl,0
;         mov       ds,ds:[BuffDisk]         ; z pisov˜ buffer
;         cld
;         repe      cmpsw                    ; porovn n¡ dat
;         pop       ds
;         pop       cx
;         je        WritTrc8                 ; operace OK
;
;; ------ hl ¨en¡ chyby
;
;WritTrc2:call      TstBreak                 ; test p©eru¨en¡
;         jc        WritTrc8                 ; je p©eru¨en¡
;         call      MazText
;         mov       di,offset Er2WMnu
;         mov       si,offset Er2WTxt
;         call      Menu                     ; zobrazen¡ hl ¨en¡
;         jc        WritTrc8                 ; p©eru¨en¡
;         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl ¨en¡
;         cmp       al,"D"
;         je        WritTrc8                 ; dal¨¡ sektor
;         cmp       al,"S"
;         jne       WritTrc1                 ; nejsou sektory - opakov n¡
;
;; ------ p©¡prava hl ¨en¡ pro aktu ln¡ ukazatele
;
;WritTrc3:call      PrepN13                  ; p©¡prava ‡¡sla stopy
;
;; ------ z pis 1 sektoru
;
;         mov       es,ds:[BuffDisk]         ; adresa bufferu
;         mov       al,1                     ; 1 sektor
;         call      WritSekt                 ; z pis dat z bufferu
;         jc        WritTrc5                 ; chyba z pisu
;
;; ------ zpˆtn‚ na‡ten¡ sektoru
;
;         mov       es,ds:[BuffDskV]         ; buffer verifikovan‚ stopy
;         call      ReadSekt                 ; na‡ten¡ stopy zpˆt
;         jc        WritTrc5                 ; chyba z pisu
;
;; ------ porovn n¡ dat stopy
;
;         push      cx
;         push      ds
;         mov       si,bx
;         mov       di,bx
;         mov       cx,256
;         mov       ds,ds:[BuffDisk]         ; z pisov˜ buffer
;         cld
;         repe      cmpsw                    ; porovn n¡ dat
;         pop       ds
;         pop       cx
;         je        WritTrc7                 ; operace OK
;
;; ------ chyba - zobrazen¡ dotazu na dal¨¡ postup
;
;WritTrc5:call      TstBreak
;         jc        WritTrc8                 ; p©eru¨en¡
;         call      MazText
;         mov       di,offset ErrWMnu
;         mov       si,offset ErrWTxt
;         call      Menu                     ; zobrazen¡ hl ¨en¡
;         jc        WritTrc8
;         cmp       al,"D"
;         je        WritTrc7                 ; dal¨¡ sektor
;;         cmp       al,"O"
;;         jne       WritTrc6                 ; p©eru¨en¡
;         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl ¨en¡
;         jmp       short WritTrc3
;
;; ------ z pis dal¨¡ho sektoru
;
;WritTrc7:inc       cx                       ; zv˜¨en¡ ‡¡sla sektoru
;         add       bx,512                   ; zv˜¨en¡ adresy v bufferu
;         cmp       cl,ds:[NumSekt]          ; jsou ji‘ v¨echny sektory ?
;         jbe       WritTrc3                 ; dal¨¡ sektor
;
;; ------ n vrat registr–
;
;WritTrc8:pop       es
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;WritTrck ENDP
;
;; -----------------------------------------------------------------------------
;;        ‡ten¡ stopy z diskety do bufferu (CH=stopa, DH=strana -> CY=p©eru¨en¡)
;; -----------------------------------------------------------------------------
;
;ReadTrck PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      es
;
;; ------ vymaz n¡ bufferu vadn˜ch sektor–
;
;         mov       si,offset TrckMap        ; mapa stopy
;         mov       al,ds:[NumSekt]          ; po‡et sektor–
;ReadTrc1:mov       byte ptr ds:[si],0       ; ozna‡en¡ sektoru OK
;         inc       si
;         dec       al                       ; ‡¡ta‡ sektor–
;         jnz       ReadTrc1
;
;; ------ test, zda se m  stopa ‡¡st
;
;         test      byte ptr ds:[Param],bit1 ; je obnovovan  disketa ?
;         jz        ReadTrc2                 ; nen¡ obnovan  disketa
;
;         mov       cl,1
;ReadTr12:call      TestErrM                 ; test mapy chyb
;         jc        ReadTrc2                 ; je cbyba - mus¡ se na‡¡st
;         inc       cx
;         cmp       cl,ds:[NumSekt]
;         jbe       ReadTr12
;         jmp       ReadTrc8                 ; nen¡ t©eba ‡¡st
;
;; ------ zobrazen¡ hl ¨en¡ o ‡ten¡ stopy
;
;ReadTrc2:mov       es,ds:[BuffDisk]         ; adresa bufferu
;         mov       cl,1                     ; ‡¡slo po‡ te‡n¡ho sektoru
;         call      PrepN13                  ; p©¡prava ‡¡sla stopy
;         mov       si,offset CtuTxt
;         call      StdErrA                  ; zobrazen¡ hl ¨en¡
;
;; ------ na‡ten¡ 1 stopy vcelku
;
;ReadTr24:xor       bx,bx                    ; offset bufferu
;         mov       al,ds:[NumSekt]          ; po‡et sektor– na stopu
;         call      ReadSekt                 ; na‡ten¡ dat do bufferu
;         jnc       ReadTrc8                 ; operace OK
;         call      TstBreak                 ; je p©eru¨en¡ ?
;         jc        ReadTrc8                 ; je p©eru¨en¡ operace
;
;; ------ p©¡prava hl ¨en¡ pro aktu ln¡ ukazatele
;
;         mov       di,offset TrckMap        ; mapa stopy
;ReadTrc3:call      PrepN13                  ; p©¡prava ‡¡sla stopy
;
;; ------ test, zda se m  sektor ‡¡st
;
;         test      byte ptr ds:[Param],bit1 ; je obnovovan  disketa ?
;         jz        ReadTr41                 ; nen¡ obnovan  disketa
;         call      TestErrM                 ; test mapy chyb
;         jnc       ReadTrc7                 ; nen¡ cbyba - nemus¡ se na‡¡st
;
;; ------ na‡ten¡ 1 sektoru
;
;ReadTr41:mov       al,1                     ; 1 sektor
;         call      ReadSekt                 ; na‡ten¡ sektoru
;         jnc       ReadTrc7                 ; sektor na‡ten OK
;         call      TstBreak                 ; je p©eru¨en¡ ?
;         jc        ReadTrc8                 ; je p©eru¨en¡ operace
;
;; ------ nulov n¡ sektoru p©i chybˆ
;
;         mov       al,ch
;         or        al,dh                    ; je v lec 0 / strana 0 ?
;         jz        ReadTr42                 ; je v lec i stopa = 0
;         mov       al,0f6h                  ; nulovac¡ bajt
;ReadTr42:call      NulSekt                  ; vynulov n¡ obsahu sektoru ES:BX
;
;         cmp       al,0
;         jne       ReadTrc4                 ; nen¡ v lec 0, stopa 0
;         cmp       cl,1
;         jne       ReadTrc4                 ; nen¡ BOOT sektor
;         call      SetSekt                  ; nastaven¡ parametr– BOOT sektoru
;
;; ------ volba dal¨¡ operace p©i chybˆ
;
;ReadTrc4:push      di
;         mov       di,offset ErrRTxtM
;         mov       si,offset ErrRTxt
;         call      MazText                  ; vymaz n¡ © dku
;         call      Menu                     ; zobrazen¡ hl ¨en¡
;         pop       di
;         jc        ReadTrc8                 ; p©eru¨en¡
;         cmp       al,"D"
;         je        ReadTrc6                 ; dal¨¡ sektor
;         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl ¨en¡
;         jmp       short ReadTrc3           ; opakov n¡ operace
;
;; ------ sektor na‡ten s chybou
;
;ReadTrc6:dec       byte ptr ds:[di]         ; -1 = p©¡znak chyby operace
;         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl ¨en¡
;
;; ------ 1 sektor na‡ten OK
;
;ReadTrc7:inc       di                       ; ukazatel v tabulce
;         inc       cx                       ; zv˜¨en¡ ‡¡sla sektoru
;         add       bx,512                   ; zv˜¨en¡ adresy v bufferu
;         cmp       cl,ds:[NumSekt]          ; jsou ji‘ v¨echny sektory ?
;         jbe       ReadTrc3                 ; dal¨¡ sektor
;
;; ------ n vrat registr–
;
;ReadTrc8:pop       es
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;ReadTrck ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ sektoru ES:BX bajtem AL
; -----------------------------------------------------------------------------

NulSekt  PROC      NEAR

         push      ax
         push      cx
         push      di

         mov       ah,al                    ; nulovac¡ bajt
         mov       cx,512/2                 ; velikost sektoru ve slovech
         mov       di,bx
         cld
         rep       stosw                    ; vynulov n¡ sektoru

         pop       di
         pop       cx
         pop       ax
         ret

NulSekt  ENDP

; -----------------------------------------------------------------------------
;        z pis dat na disketu (2 pokusy)
; -----------------------------------------------------------------------------
; VSTUP: CH=stopa
;        CL=sektor
;        DH=strana
;        AL=po‡et sektor–
;        ES:BX=adresa bufferu
; VSTUP: CY=chyba
; -----------------------------------------------------------------------------

WritSekt PROC      NEAR

         push      ax
         mov       ah,3                     ; funkce z pisu sektor–
         jmp       short ReadSek2

WritSekt ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ dat z diskety (2 pokusy)
; -----------------------------------------------------------------------------
; VSTUP: CH=stopa
;        CL=sektor
;        DH=strana
;        AL=po‡et sektor–
;        ES:BX=adresa bufferu
; VSTUP: CY=chyba
; -----------------------------------------------------------------------------

ReadSekt PROC      NEAR

;         test      byte ptr ds:[Param],bit2 ; je ur‡en  paritn¡ disketa ?
;         jz        ReadSek1
;         cmp       word ptr ds:[OutpIdnt],0 ; je vstupn¡ soubor otev©en ?
;         jne       ReadOutp                 ; je vstupn¡ soubor otev©en

ReadSek1:push      ax
         mov       ah,2                     ; funkce ‡ten¡ sektor–
ReadSek2:push      bp
         mov       bp,2                     ; po‡et pokus–

ReadSek3:call      Int13                    ; na‡ten¡ sektor– do bufferu
         jnc       ReadSek4                 ; operace OK
         call      TstBreak                 ; je p©eru¨en¡ operace ?
         jc        ReadSek4                 ; je p©eru¨en¡ operace
         dec       bp                       ; ‡¡ta‡ pokus–
         jnz       ReadSek3                 ; dal¨¡ pokus

ReadSek4:pop       bp
         pop       ax
         ret

ReadSekt ENDP

;; ------ ‡ten¡ ze vstupn¡ho souboru
;
;ReadOutp:push      ax
;         push      bx
;         push      cx
;         push      dx
;
;; ------ p©epo‡et na absolutn¡ sektor
;
;         push      ax
;         push      bx
;
;         mov       al,ch                    ; ‡¡slo v lce
;         mul       byte ptr ds:[NumStran]   ; p©epo‡et na absolutn¡ stopu
;         add       al,dh                    ; p©i‡ten¡ strany
;         mov       dh,0
;         adc       ah,dh
;         mov       dl,ds:[NumSekt]          ; po‡et sektor– na stopu
;         mul       dx                       ; p©epo‡et na sektory
;         dec       cx                       ; korekce ‡¡sla sektoru
;         add       al,cl                    ; p©i‡ten¡ ‡¡sla sektoru
;         adc       ah,0
;
;; ------ p©epo‡et na offset v souboru
;
;         mov       ch,0
;         mov       cl,ah                    ; CX:DX = sektor*256
;         mov       dh,al
;         mov       dl,0
;         shl       dh,1
;         rcl       cl,1
;         rcl       ch,1                     ; offset v souboru
;
;; ------ nastaven¡ ukazatele v souboru
;
;         mov       ax,4200h
;         mov       bx,ds:[OutpIdnt]         ; identifik tor souboru
;         int       21h                      ; nastaven¡ ukazatele v souboru
;
;         pop       dx
;         pop       ax
;         jc        ReadOut4                 ; chyba operace
;
;; ------ stanoven¡ velikosti dat k na‡ten¡
;
;         mov       ch,al                    ; po‡et sektor–
;         mov       cl,0
;         shl       cx,1                     ; po‡et bajt– k na‡ten¡
;
;; ------ na‡ten¡ dat do bufferu
;
;         push      ds
;         push      es
;         pop       ds                       ; DS <- segment bufferu
;         mov       ah,3fh
;         int       21h                      ; na‡ten¡ dat ze souboru
;         pop       ds
;         jnc       ReadOut5
;
;; ------ chyba ‡ten¡ ze souboru
;
;ReadOut4:mov       si,offset ErrORTxt
;         jmp       Chyba
;
;; ------ n vrat registr–
;
;ReadOut5:pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;; -----------------------------------------------------------------------------
;;        p©¡prava ‡¡sla stopy pro operaci
;; -----------------------------------------------------------------------------
;
;PrepN13  PROC      NEAR
;
;         push      ax
;
;; ------ ‡¡slo v lce
;
;         mov       al,ch                    ; ‡¡slo v lce
;         aam
;         xchg      al,ah
;         add       ax,"00"
;         mov       word ptr ds:[CtuTxt2],ax ; ‡¡slo v lce
;         mov       word ptr ds:[ZapTxt2],ax ; ‡¡slo v lce
;         mov       word ptr ds:[ErrRTxt1+19],ax
;         mov       word ptr ds:[ErrWTxt1+20],ax
;         mov       word ptr ds:[Er2WTxt1+20],ax
;
;; ------ ‡¡slo strany
;
;         mov       al,dh                    ; ‡¡slo strany
;         add       al,"0"
;         mov       ds:[CtuTxt3],al
;         mov       ds:[ZapTxt3],al
;         mov       ds:[ErrRTxt1+29],al
;         mov       ds:[ErrWTxt1+30],al
;         mov       ds:[Er2WTxt1+30],al
;
;; ------ ‡¡slo sektoru
;
;         mov       al,cl
;         aam
;         xchg      al,ah
;         add       ax,"00"
;         mov       word ptr ds:[ErrRTxt1+38],ax
;         mov       word ptr ds:[ErrWTxt1+39],ax
;
;; ------ n vrat registr–
;
;         pop       ax
;         ret
;
;PrepN13  ENDP

; -----------------------------------------------------------------------------
;        reset disku
; -----------------------------------------------------------------------------

ResDisk  PROC      NEAR

         push      ax
         mov       ah,0
         call      Int13                    ; reset diskety
         pop       ax
         ret

ResDisk  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 13h s £schovou v¨ech registr– (CY=chyba / p©eru¨en¡)
;              obsluhuje chybu nep©ipraven‚ho disku a z kaz z pisu
; -----------------------------------------------------------------------------

Int13    PROC      NEAR

; ------ £schova registr–

         call      NulBreak                 ; nulov n¡ p©¡znaku p©eru¨en¡
         push      bp
         mov       bp,2                     ; ‡¡ta‡ pokus– (pro v˜mˆnu disku)

Int131:  push      ax

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ obsluha po‘adovan‚ funkce

         clc
         sti
         mov       dl,ds:[Disk]             ; ‡¡slo disku
         int       13h

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         jnc       Int133                   ; operace OK

; ------ opakov n¡ operace p©i v˜mˆnˆ diskety

         cmp       ah,6                     ; je v˜mˆna diskety ?
         jne       Int132                   ; nen¡ v˜mˆna diskety
         dec       bp                       ; ‡¡ta‡ pokus–
         jnz       Int136                   ; dal¨¡ pokus

; ------ test, zda je z kaz z pisu

Int132:  cmp       ah,3
         je        Int1332                  ; z kaz z pisu

; ------ test, zda je chyba TIME-OUT

         cmp       ah,80h                   ; chyba TIME-OUT ?
         je        Int134                   ; je chyba TIME-OUT
         stc                                ; jin  chyba

; ------ n vrat z obsluhy

Int133:  pop       ax
         pop       bp
         ret

; ------ disketa je R/O

Int1332: push      si
         mov       si,offset ErrROMnu       ; chyba R/O
         jmp       short Int1342

; ------ v mechanice nen¡ disketa

Int134:  push      si
         mov       si,offset ErrTMnu        ; chyba Time-Out

; ------ dotaz na dal¨¡ operaci

Int1342: call      MazText                  ; vymaz n¡ textu
         call      Menu                     ; zobrazen¡ textu
         pop       si
         jc        Int137                   ; p©eru¨en¡ operace
         call      StdErrO                  ; obnoven¡ textu

; ------ resetov n¡ disku a dal¨¡ pokus

Int136:  call      ResDisk                  ; resetov n¡ disku
         pop       ax
         jmp       short Int131             ; opakov n¡ operace

; ------ je p©eru¨en¡ operace BREAK

Int137:  call      SetBreak                 ; nastaven¡ p©¡znaku p©eru¨en¡
         jmp       short Int133

Int13    ENDP

; *****************************************************************************
;
;                    Obsluha zobrazen¡ a vstupu z kl vesnice
;
; *****************************************************************************
;ş
; -----------------------------------------------------------------------------
;        potvrzen¡ p©eru¨en¡ operace (CY=je p©eru¨en¡)
; -----------------------------------------------------------------------------

Prerus   PROC      NEAR

         test      byte ptr ds:[Param2],bit0 ; byl alespo¤ 1 disk ?
         stc                                ; p©¡znak p©eru¨en¡
         jz        Prerus9                  ; nebyl disk - m–‘e b˜t p©eru¨en¡

         push      ax
         push      si

         mov       si,offset PrerMnu
         call      Menu
         cmc                                ; CY=je potvrzen¡ operace

         pop       si
         pop       ax
Prerus9: ret

Prerus   ENDP

; -----------------------------------------------------------------------------
;        volba pomoc¡ menu SI -> znak AL, CY=p©eru¨en¡ "P"
; -----------------------------------------------------------------------------

Menu     PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx
         push      si
         push      di

; ------ zobrazen¡ cel‚ho © dku textu -> SI

         mov       di,si                    ; DI <- definice menu
         mov       al,ds:[si]               ; AL <- po‡et voleb celkem
         mov       ah,0
         shl       ax,1
         add       si,ax
         inc       si                       ; za‡ tek textu k zobrazen¡
         call      StdErr                   ; zobrazen¡ © dku textu

; ------ p©¡prava ukazatel– voleb

         mov       dl,1                     ; aktivn¡ volba
         mov       dh,ds:[di]               ; po‡et voleb celkem

; ------ ukazatel aktivn¡ polo‘ky DL -> BX

Menu1:   mov       bx,di                    ; BX <- za‡ tek definice menu
         add       bl,dl                    ; + aktivn¡ volba 1..
         adc       bh,0
         add       bl,dl                    ; + 2*aktivn¡ volba
         adc       bh,0
         dec       bx                       ; adresa aktivn¡ volby

; ------ zobrazen¡ kurzoru

         push      word ptr ds:[si]         ; £schova p–vodn¡ d‚lky textu
         mov       al,ds:[bx+1]             ; offset kurzoru
         mov       ds:[si],al               ; nov  d‚lka textu
         call      StdErr                   ; zobrazen¡ © dku textu
         pop       word ptr ds:[si]

; ------ ‡ek n¡ na zad n¡ kl vesy

Menu2:   call      StdIn
         jnc       Menu22                   ; nen¡ p©eru¨en¡

; ------ posledn¡ znak pro p©eru¨en¡ operace ESC

         push      bx
         mov       bl,dh                    ; BL <- po‡et voleb
         mov       bh,0
         shl       bx,1                     ; po‡et voleb * 2
         add       bx,di                    ; adresa konce voleb
         mov       al,ds:[bx-1]             ; znak posledn¡ volby
         pop       bx

; ------ potvrzen¡ aktivn¡ volby ENTER (mezera)

Menu22:  cmp       al,13
         je        Menu8                    ; potvrzen¡ volby ENTER
         cmp       al," "
         je        Menu8                    ; potvrzen¡ volby mezerou

; ------ prvn¡ polo‘ka HOME

         cmp       ax,4700h                 ; HOME
         je        Menu3

; ------ kurzor vpravo

         cmp       al,9                     ; TAB
         je        Menu32

         cmp       ax,4d00h                 ; VPRAVO
         jne       Menu4

Menu32:  inc       dx                       ; zv˜¨en¡ aktivn¡ polo‘ky
         cmp       dl,dh
         jbe       Menu1                    ; nen¡ je¨tˆ konec
Menu3:   mov       dl,1                     ; prvn¡ polo‘ka
         jmp       short Menu1

; ------ posledn¡ polo‘ka END

Menu4:   cmp       ax,4f00h                 ; END
         je        Menu5

; ------ kurzor vlevo

         cmp       ax,0f00h                 ; SHIFT-TAB
         je        Menu52
         cmp       ax,4b00h                 ; VLEVO
         jne       Menu6

Menu52:  dec       dl                       ; sn¡‘en¡ aktivn¡ polo‘ky
         jnz       Menu1
Menu5:   mov       dl,dh
         jmp       short Menu1

; ------ nalezen¡ hork‚ kl vesy AL v menu

Menu6:   push      di
         push      dx

         mov       dl,1                     ; ukazatel ‡¡sla polo‘ky
         mov       ah,dh                    ; AH <- po‡et polo‘ek
Menu62:  inc       di
         inc       di                       ; ukazatel v definici menu
         cmp       al,ds:[di-1]             ; je to hledan  kl vesa ?
         je        Menu7                    ; kl vesa nalezena OK
         inc       dx                       ; zv˜¨en¡ ukazatele ‡¡sla polo‘ky
         dec       ah                       ; ‡¡ta‡ polo‘ek
         jnz       Menu62                   ; test dal¨¡ polo‘ky

         pop       dx
         pop       di
         jmp       short Menu2              ; kl vesa nenalezena

Menu7:   pop       di
         pop       di
         jmp       short Menu82

; ------ zvolen  kl vesa - test p©eru¨en¡

Menu8:   mov       al,ds:[bx]               ; p¡smeno aktivn¡ volby
Menu82:  cmp       dl,dh                    ; je p©eru¨en¡ ?
         cmc                                ; CY = je p©eru¨en¡

; ------ vymaz n¡ © dku textu

         call      MazText                  ; vymaz n¡ © dku textu
         mov       ah,0

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       bx
         ret

Menu     ENDP

;; -----------------------------------------------------------------------------
;;        test p©eru¨en¡ operace ESC -> CY p©eru¨en¡
;; -----------------------------------------------------------------------------
;
;TestEsc  PROC      NEAR
;
;         test      byte ptr ds:[Operace],bit7 ; je £sporn˜ m¢d ?
;         jnz       TestEsc9                 ; je £sporn˜ m¢d
;
;         mov       ah,0bh
;         int       21h                      ; test kl vesnice
;         cmp       al,0
;         je        TestEsc9                 ; nen¡ p©ipraven ‘ dn˜ znak
;
;         mov       ah,8
;         int       21h                      ; vstup znaku z kl vesnice
;         cmp       al,0
;         jne       TestEsc2
;         mov       ah,8
;         int       21h
;         mov       al,0
;
;TestEsc2:cmp       al,27
;         clc
;         jne       TestEsc9                 ; nen¡ ESC
;         call      SetBreak                 ; nastaven¡ p©¡znaku p©eru¨en¡
;TestEsc9:ret
;
;TestEsc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice -> AX
; -----------------------------------------------------------------------------

StdIn    PROC      NEAR

; ------ vstup znaku z kl vesnice (s vypr zdnˆn¡m bufferu kl vesnice) -> AL

         mov       ax,0c07h
         int       21h                      ; vstup znaku z kl vesnice
         mov       ah,0

; ------ konverze na velk‚ p¡smeno

         cmp       al,"a"
         jb        StdIn3
         cmp       al,"z"
         ja        StdIn3
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ vstup SCAN k¢du ©¡dic¡ kl vesy

StdIn3:  cmp       al,0                     ; bude SCAN k¢d ?
         jne       StdIn4                   ; nebude SCAN k¢d
         mov       ah,7
         int       21h                      ; zru¨en¡ roz¨¡©en‚ kl vesy
         mov       ah,al                    ; SCAN k¢d ©¡dic¡ kl vesy
         mov       al,0

; ------ n hrada p©¡padn‚ho Ctrl-Break kl vesou ESC

StdIn4:  cmp       al,3                     ; Ctrl-C
         je        StdIn5
         or        ax,ax
         jnz       StdIn6
StdIn5:  mov       al,27

; ------ p©¡znak CY pro ESC

StdIn6:  cmp       al,27                    ; ESC
         clc
         jne       StdIn7
         stc
StdIn7:  ret

StdIn    ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ v˜stupn¡ho © dku (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------

MazText  PROC      NEAR

         pushf
         push      si
         mov       si,offset MazTTxt
         call      StdErr                   ; zobrazen¡ textu
         pop       si
         popf
         ret

MazText  ENDP

; -----------------------------------------------------------------------------
;        obnoven¡ aktu ln¡ho hl ¨en¡
; -----------------------------------------------------------------------------

StdErrO  PROC      NEAR

         push      si
         mov       si,ds:[AktHlas]          ; adresa aktu ln¡ho hl ¨en¡
         call      StdErr                   ; zobrazen¡ hl ¨en¡
         pop       si
         ret

StdErrO  ENDP

; -----------------------------------------------------------------------------
;        v˜stup textu DS:SI na standardn¡ chybov‚ za©¡zen¡ (1. slovo = d‚lka)
; -----------------------------------------------------------------------------

; ------ hl ¨en¡ s uschov n¡m adresy aktu ln¡ho hl ¨en¡ o prov dˆn‚ operaci

StdErrA: mov       ds:[AktHlas],si          ; adresa aktu ln¡ho hl ¨en¡

;         jmp       short StdErr
;
;; ------ hl ¨en¡ s p©edchoz¡m vymaz n¡ © dku
;
;StdErr0: call      MazText                  ; vymaz n¡ © dku

StdErr   PROC      NEAR

         push      bx
         mov       bx,2                     ; identifik tor za©¡zen¡ STDERR
         jmp       short StdOut1

StdErr   ENDP

;; -----------------------------------------------------------------------------
;;        v˜stup textu DS:SI do souboru protokolu (1. slovo = d‚lka)
;; -----------------------------------------------------------------------------
;
;RepOut:  push      si
;         mov       si,offset DatTxt0
;         call      RepOut0
;         pop       si
;
;RepOut0: push      bx
;         mov       bx,ds:[RepIdnt]          ; identifik tor souboru
;         or        bx,bx
;         jnz       StdOut1                  ; soubor je otev©en
;         pop       bx
;         ret

; -----------------------------------------------------------------------------
;        v˜stup textu DS:SI na standardn¡ v˜stupn¡ za©¡zen¡ (1. slovo = d‚lka)
; -----------------------------------------------------------------------------

;StdOut0: call      MazText                  ; vymaz n¡ © dku

StdOut   PROC      NEAR

         push      bx
         mov       bx,1                     ; identifik tor za©¡zen¡ STDOUT

StdOut1: push      ax
         push      cx
         push      dx

         mov       cx,ds:[si]               ; po‡et bajt– k zobrazen¡
         mov       dx,si                    ; za‡ tek textu k zobrazen¡
         inc       dx
         inc       dx
         mov       ah,40h
         int       21h                      ; zobrazen¡ textu

         pop       dx
         pop       cx
         pop       ax
         pop       bx
         ret

StdOut   ENDP

; *****************************************************************************
;
;                       Rozbor p©¡kazov‚ho © dku
;
; *****************************************************************************
;ş
; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku (neuchov v  registry, CY=chyba parametr–)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         and       bx,7fh
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku

Rozbor1: call      RozbChr                  ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         je        Rozbor1                  ; mezera - vypu¨tˆn¡
         jnc       Rozbor2                  ; nalezen platn˜ znak

; ------ konec zad n¡ - text, zda byl zad n nˆjak˜ povel

         cmp       word ptr ds:[Operace],1  ; bylo nˆco zad no ? (0=chyba)
         ret

; ------ ignorovan‚ znaky

Rozbor2: cmp       al,"/"
         je        Rozbor1                  ; ignorov n¡ znaku "/"
         cmp       al,":"
         je        Rozbor1                  ; ignorov n¡ znaku ":"
         cmp       al,"-"
         je        Rozbor1                  ; ignorov n¡ znaku "-"

; ------ zad n¡ disku "A" nebo "B"

         cmp       al,"A"
         jb        Rozbor3                  ; nen¡ ozna‡en¡ disku
         cmp       al,"B"
         ja        Rozbor3                  ; nen¡ ozna‡en¡ disku

; ------ p©¡prava ozna‡en¡ disku pro texty hl ¨en¡

         mov       ds:[DiskChr1],al         ; ozna‡en¡ mechaniky
         mov       ds:[DiskChr2],al
         mov       ds:[DiskChr3],al
         mov       ds:[DiskChr4],al
         mov       ds:[DiskChr5],al
         mov       ds:[DiskChr6],al
;         mov       ds:[DiskChr7],al
;         mov       ds:[DiskChr8],al
;         mov       ds:[DiskChr9],al
;         mov       ds:[DiskChrA],al
         mov       ds:[DiskChrT],al

; ------ ulo‘en¡ ‡¡sla disku

         sub       al,"A"                   ; ‡¡slo disku
         mov       ds:[Disk],al             ; ‡¡slo disku
         jmp       short Rozbor1

; ------ povel "G" - generov n¡ paritn¡ diskety

Rozbor3: mov       bx,bit0                  ; povel pro generov n¡ diskety
         cmp       al,"G"
         je        Rozbor5

; ------ povel "U" - obnoven¡ po¨kozen‚ diskety archivu

         mov       bl,bit1                  ; povel pro obnoven¡ diskety
         cmp       al,"U"
         je        Rozbor5

; ------ povel "M" - modifikace archivu

         mov       bl,bit2
         cmp       al,"M"
         je        Rozbor5

; ------ povel "T" - test v¨ech disket archivu

         mov       bl,bit3                  ; povel pro test disket archivu
         cmp       al,"T"
         je        Rozbor5

; ------ povel "V" - verifikace diskety

         mov       bl,bit4
         cmp       al,"V"
         je        Rozbor5

; ------ povel "I" - identifikace diskety

         mov       bl,bit5
         cmp       al,"I"
         je        Rozbor5

; ------ povel "R" - na‡ten¡ diskety

         mov       bl,bit6
         cmp       al,"R"
         je        Rozbor5

; ------ povel "W" - z pis diskety

         mov       bl,bit7
         cmp       al,"W"
         je        Rozbor5

; ------ povel "C" - kop¡rov n¡ diskety

         mov       bx,bit8
         cmp       al,"C"
         je        Rozbor5

; ------ povel "X" - z kaz pou‘¡v n¡ XMS

         cmp       al,"X"
         jne       Rozbor32
         or        byte ptr ds:[Param],bit3 ; je z kaz pou‘¡v n¡ XMS
         jmp       short Rozbor8

; ------ povel "O" - z kaz protokolu REP

Rozbor32:cmp       al,"O"
         jne       Rozbor4
         or        byte ptr ds:[Param],bit4 ; je z kaz v˜stupu protokolu
         jmp       short Rozbor8

; ------ neplatn˜ povel

Rozbor4: stc                                ; p©¡znak neplatn‚ho povelu
         ret

; ------ test, zda ji‘ byl zad n nˆjak˜ povel

Rozbor5: xchg      bx,ds:[Operace]          ; ulo‘en¡ zadan‚ho povelu
         or        bx,bx                    ; bylo ji‘ nˆco zad no ?
         jnz       Rozbor4                  ; bylo ji‘ nˆco zad no

; ------ zad n¡ souboru pro operaci ‡ten¡ nebo z pisu diskety

         test      byte ptr ds:[Operace],bit6+bit7 ; je ‡ten¡ nebo z pis ?
         jz        Rozbor8                  ; nen¡ ‡ten¡ ani z pis
         mov       di,offset Soubor         ; buffer jm‚na souboru
         call      RozbFile                 ; rozbor jm‚na souboru
         jc        Rozbor4                  ; chyba zad n¡

Rozbor8: jmp       Rozbor1                  ; dal¨¡ zad n¡

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        rozbor jm‚na souboru DS:SI do bufferu ES:DI -> CY=chyba
; -----------------------------------------------------------------------------

RozbFile PROC      NEAR

; ------ nalezen¡ za‡ tku jm‚na souboru

RozbFil1:call      RozbChr                  ; na‡ten¡ znaku
         je        RozbFil1                 ; je mezera - dal¨¡ znak
         jc        RozbFil3                 ; nen¡ dal¨¡ znak - chyba

; ------ test, zda je platn˜ znak

         cmp       al,"/"                   ; je dal¨¡ parametr ?
         jne       RozbFil4                 ; je platn˜ znak
RozbFil2:dec       si                       ; n vrat ukazatele textu
         stc                                ; p©¡znak chyby - nen¡ nic zad no
RozbFil3:ret

; ------ p©enesen¡ specifikace souboru

RozbFil4:stosb                              ; ulo‘en¡ znaku
         call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jb        RozbFil6                 ; konec jm‚na souboru
         je        RozbFil5                 ; mezera
         cmp       al,"/"                   ; dal¨¡ parametr ?
         jne       RozbFil4                 ; je platn˜ znak

; ------ ozna‡en¡ konce jm‚na souboru

RozbFil5:dec       si                       ; n vrat neplatn‚ho znaku
RozbFil6:mov       al,0
         stosb                              ; ulo‘en¡ koncov‚ 0
         clc                                ; p©¡znak operace OK
         ret

RozbFile ENDP

; -----------------------------------------------------------------------------
;    na‡ten¡ znaku z p©¡kazov‚ho © dku DS:SI -> AL, CY=nen¡ znak (nastav¡ CLD !)
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

; ------ na‡ten¡ znaku

         cld
         lodsb                              ; na‡ten¡ znaku

; ------ konverze na velk‚ p¡smeno

         cmp       al,"a"
         jb        RozbChr2
         cmp       al,"z"
         ja        RozbChr2
         sub       al,32

; ------ n hrada tabul toru mezerou

RozbChr2:cmp       al,9
         jne       RozbChr3
         mov       al," "

; ------ test, zda je platn˜ znak

RozbChr3:cmp       al," "
         jae       RozbChr4
         dec       si
RozbChr4:ret

RozbChr  ENDP

;; *****************************************************************************
;;
;;                         Obsluha p©echodn‚ho souboru
;;
;; *****************************************************************************
;;ş
;; -----------------------------------------------------------------------------
;;        za©azen¡ nov‚ diskety do v˜stupn¡ho p©echodn‚ho souboru
;; -----------------------------------------------------------------------------
;
;TempXchg PROC      NEAR
;
;         push      ax
;         push      cx
;         push      si
;
;         mov       ax,ds:[TempIdnR]
;         xchg      ax,ds:[TempIdnW]
;         mov       ds:[TempIdnR],ax
;
;         mov       si,offset TempFilR
;         mov       cx,128
;TempXch2:mov       al,ds:[si]
;         xchg      al,ds:[si+TempFilW-TempFilR]
;         mov       ds:[si],al
;         inc       si
;         loop      TempXch2
;
;         pop       si
;         pop       cx
;         pop       ax
;         ret
;
;TempXchg ENDP
;
;; -----------------------------------------------------------------------------
;;        inicializace jm‚na p©echodn‚ho souboru (neuchov v  registry !)
;; -----------------------------------------------------------------------------
;
;TempInit PROC      NEAR
;
;; ------ p©¡prava implicitn¡ho disku
;
;         mov       ah,19h
;         int       21h                      ; poskytnut¡ aktivn¡ho disku
;         cmp       al,2                     ; je disk A: nebo B: ?
;         jae       TempIni1                 ; nen¡ disk A: ani B:
;         mov       al,2                     ; implicitn¡ je disk C:
;
;; ------ ulo‘en¡ ozna‡en¡ implicitn¡ho disku
;
;TempIni1:push      ds
;         pop       es
;         mov       di,offset TempFilR       ; buffer p©echodn‚ho souboru
;         cld
;         add       al,"A"
;         mov       ah,":"
;         stosw                              ; ulo‘en¡ ozna‡en¡ disku
;
;; ------ test verze syst‚mu
;
;         mov       ah,30h
;         int       21h                      ; poskytnut¡ verze syst‚mu
;         cld
;         cmp       al,3                     ; minim ln¡ verze DOS 3.xx
;         jb        TempIni8                 ; je n¡zk  verze syst‚mu
;
;; ------ nalezen¡ ©etˆzce jm‚na programu
;
;         push      ds
;         mov       ax,ds:[2ch]              ; segment prost©ed¡
;         or        ax,ax
;         jz        TempIni7                 ; neplatn‚ prost©ed¡
;         mov       ds,ax                    ; segment prost©ed¡
;         xor       si,si
;         xor       ax,ax
;TempIni2:inc       si
;         js        TempIni7
;         cmp       ax,ds:[si-1]
;         jne       TempIni2
;         inc       si
;
;; ------ kontrola po‡tu ©etˆzc–
;
;         lodsw                              ; po‡et ©etˆzc–
;         dec       ax                       ; je 1 a v¡ce ?
;         js        TempIni7                 ; nejsou ©etˆzce
;
;; ------ kontrola disku
;
;         cmp       byte ptr ds:[si+1],":"   ; je zad n disk ?
;         jne       TempIni4                 ; nen¡ zad n disk
;         lodsb                              ; ozna‡en¡ disku
;         cmp       al,"a"
;         jb        TempIni3
;         cmp       al,"z"
;         ja        TempIni3
;         sub       al,32                    ; konverze na velk‚ p¡smeno
;TempIni3:cmp       al,"C"                   ; minim ln¡ ozna‡en¡ disku
;         jb        TempIni7                 ; neplatn˜ disk
;         cmp       al,"a"
;         jae       TempIni7                 ; neplatn˜ disk
;         mov       es:[di-2],al             ; ozna‡en¡ disku
;         inc       si                       ; p©esko‡en¡ znaku ":"
;
;; ------ p©enos cesty
;
;TempIni4:mov       dx,di                    ; £schova konce cesty
;TempIni5:lodsb                              ; na‡ten¡ znaku
;         stosb                              ; ulo‘en¡ znaku
;         cmp       di,offset TempFilR+110   ; maxim ln¡ konec cesty
;         jae       TempIni6                 ; cesta je ji‘ pln 
;         cmp       al,"\"                   ; je oddˆlova‡ cesty ?
;         je        TempIni4                 ; oddˆlova‡ cesty
;         cmp       al,"/"
;         je        TempIni4                 ; oddˆlova‡ cesty
;         cmp       al,":"
;         je        TempIni4
;         cmp       al,0
;         jne       TempIni5
;
;TempIni6:mov       di,dx                    ; konec cesty
;
;; ------ p©id n¡ jm‚na souboru SAFEDISK.$T$
;
;TempIni7:pop       ds
;
;TempIni8:mov       si,offset TempFil0
;         mov       cx,13
;         rep       movsb                    ; p©enos jm‚na souboru
;
;; ------ jm‚no souboru k z pisu
;
;         mov       si,offset TempFilR
;         sub       di,si
;         mov       cx,di                    ; d‚lka jm‚na souboru
;         push      si
;         push      cx
;         mov       di,offset TempFilW       ; soubor pro z pis
;         rep       movsb
;         mov       byte ptr ds:[di-2],"@"   ; jm‚no souboru pro z pis
;         pop       cx
;         pop       si
;
;; ------ kopie do bufferu souboru SAFEDISK.REP
;
;         mov       di,offset RepFile
;         mov       dx,di
;         rep       movsb                    ; p©enos jm‚na souboru
;         mov       word ptr ds:[di-4],"ER"
;         mov       byte ptr ds:[di-2],"P"
;
;; ------ otev©en¡ souboru SAFEDISK.REP pro z pis
;
;         mov       ax,3d01h
;         int       21h
;         jnc       TempIni9
;         mov       ah,3ch
;         xor       cx,cx
;         int       21h
;         jc        TempIniA                 ; chyba
;TempIni9:mov       ds:[RepIdnt],ax          ; identifik tor souboru
;
;; ------ nastaven¡ ukazatele v souboru na konec
;
;         xchg      ax,bx
;         xor       cx,cx
;         xor       dx,dx
;         mov       ax,4202h
;         int       21h                      ; nastaven¡ ukazatele na konec
;
;; ------ dek¢dov n¡ aktu ln¡ho data
;
;         mov       ah,2ah
;         int       21h                      ; poskytnut¡ aktu ln¡ho data
;         mov       ah,0
;         mov       al,dl                    ; den
;         mov       di,offset DatTxt + 3
;         call      DekNum                   ; dek¢dov n¡ dne
;         mov       di,offset DatTxt + 6
;         mov       al,dh
;         call      DekNum                   ; dek¢dov n¡ mˆs¡ce
;         mov       di,offset DatTxt + 11
;         xchg      ax,cx
;         call      DekNum                   ; dek¢dov n¡ roku
;
;; ------ dek¢dov n¡ aktu ln¡ho ‡asu
;
;         mov       ah,2ch
;         int       21h                      ; poskytnut¡ aktu ln¡ho ‡asu
;         mov       ah,0
;         mov       al,ch
;         mov       di,offset DatTxt + 15
;         call      DekNum                   ; dek¢dov n¡ hodiny
;         mov       al,cl
;         mov       di,offset DatTxt + 18
;         call      DekNum                   ; dek¢dov n¡ minuty
;         mov       al,dh
;         mov       di,offset DatTxt + 21
;         call      DekNum
;
;; ------ p©enesen¡ p©¡kazov‚ho © dku
;
;         mov       di,offset DatTxt1
;         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
;         mov       cl,ds:[80h]
;         and       cx,7fh
;         rep       movsb                    ; p©enos p©¡kazov‚ho © dku
;         mov       ax,0a0dh
;         stosw                              ; ulo‘en¡ CR/LF
;         sub       di,offset DatTxt+2
;         mov       ds:[DatTxt],di           ; d‚lka textu
;
;; ------ v˜stup textu
;
;         mov       si,offset DatTxt
;         call      RepOut0                  ; v˜stup textu
;
;TempIniA:ret
;
;TempInit ENDP
;
;; -----------------------------------------------------------------------------
;;        otev©en¡ p©echodn‚ho souboru
;; -----------------------------------------------------------------------------
;
;TempOpen PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      dx
;
;; ------ test, zda je soubor pro ‡ten¡ ji‘ vytvo©en
;
;         cmp       word ptr ds:[TempIdnR],0 ; je soubor ji‘ vytvo©en ?
;         jne       TempOpn4                 ; soubor je ji‘ vytvo©en
;
;; ------ otev©en¡ vstupn¡ho souboru
;
;         test      byte ptr ds:[Param],bit0 ; paritn¡ disketa v souboru ?
;         jz        TempOpn2                 ; nen¡ disketa v souboru
;         mov       dx,offset OutpFile
;         mov       ax,3d00h
;         int       21h                      ; otev©en¡ souboru pro ‡ten¡
;         jc        TempOpn2
;         mov       ds:[OutpIdnt],ax         ; identifik tor souboru
;
;; ------ vytvo©en¡ souboru pro ‡ten¡
;
;TempOpn2:mov       dx,offset TempFilR       ; jm‚no souboru pro ‡ten¡
;         mov       ah,3ch
;         xor       cx,cx                    ; CX <- 0 atributy
;         int       21h                      ; vytvo©en¡ souboru
;         jnc       TempOpn3                 ; soubor vytvo©en OK
;
;; ------ chyba - soubor nelze vytvo©it
;
;TempOp22:mov       si,offset ErrOTxt
;         jmp       Chyba
;
;; ------ ulo‘en¡ identifik toru pro ‡ten¡
;
;TempOpn3:mov       ds:[TempIdnR],ax         ; identifik tor souboru
;
;; ------ test, zda je soubor pro z pis ji‘ vytvo©en
;
;TempOpn4:cmp       word ptr ds:[TempIdnW],0 ; je soubor pro z pis ji‘ vytvo©en ?
;         jne       TempOpn9                 ; je ji‘ vytvo©en
;         mov       ax,ds:[TempIdnR]         ; soubor pro ‡ten¡
;         test      byte ptr ds:[Operace],bit7 ; je £sporn˜ m¢d ?
;         jnz       TempOpn8                 ; je £sporn˜ m¢d
;
;; ------ vytvo©en¡ souboru
;
;         mov       dx,offset TempFilW       ; jm‚no souboru pro z pis
;         mov       ah,3ch
;         xor       cx,cx                    ; CX <- 0 atributy
;         int       21h                      ; vytvo©en¡ souboru
;         jc        TempOp22                 ; chyba vytvo©en¡ souboru
;
;; ------ ulo‘en¡ identifik toru
;
;TempOpn8:mov       ds:[TempIdnW],ax         ; identifik tor souboru pro z pis
;
;; ------ n vrat registr–
;
;TempOpn9:pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;TempOpen ENDP
;
;; -----------------------------------------------------------------------------
;;        uzav©en¡ a zru¨en¡ p©echodn‚ho souboru
;; -----------------------------------------------------------------------------
;
;TempClos PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      dx
;
;; ------ test, zda je soubor pro ‡ten¡ vytvo©en
;
;         mov       bx,ds:[TempIdnR]         ; identifik tor souboru pro ‡ten¡
;         or        bx,bx                    ; je soubor vytvo©en ?
;         jz        TempCls4                 ; soubor nen¡ vytvo©en
;
;; ------ uzav©en¡ souboru
;
;         mov       ah,3eh
;         int       21h                      ; uzav©en¡ souboru
;         mov       word ptr ds:[TempIdnR],0 ; zru¨en¡ identifik toru
;         test      byte ptr ds:[Operace],bit7
;         jz        TempCls2
;         mov       word ptr ds:[TempIdnW],0
;
;; ------ zru¨en¡ souboru
;
;TempCls2:mov       dx,offset TempFilR       ; jm‚no souboru
;         mov       ah,41h
;         int       21h                      ; zru¨en¡ p©echodn‚ho souboru
;
;; ------ uzav©en¡ v˜stupn¡ho souboru
;
;TempCls4:mov       bx,ds:[OutpIdnt]
;         or        bx,bx
;         jz        TempCls5
;         mov       ah,3eh
;         int       21h                      ; uzav©en¡ souboru
;         mov       word ptr ds:[OutpIdnt],0 ; zru¨en¡ identifik toru
;
;; ------ test, zda je soubor pro z pis vytvo©en
;
;TempCls5:test      byte ptr ds:[Operace],bit7 ; je £sporn˜ m¢d ?
;         jnz       TempCls9                 ; je £sporn˜ m¢d
;         mov       bx,ds:[TempIdnW]         ; identifik tor souboru pro z pis
;         or        bx,bx                    ; je soubor vytvo©en ?
;         jz        TempCls9                 ; soubor nen¡ vytvo©en
;
;; ------ uzav©en¡ souboru
;
;         mov       ah,3eh
;         int       21h                      ; uzav©en¡ souboru
;         mov       word ptr ds:[TempIdnW],0 ; zru¨en¡ identifik toru
;
;; ------ zru¨en¡ souboru
;
;         mov       dx,offset TempFilW       ; jm‚no souboru
;         mov       ah,41h
;         int       21h                      ; zru¨en¡ p©echodn‚ho souboru
;
;; ------ n vrat registr–
;
;TempCls9:pop       dx
;         pop       bx
;         pop       ax
;         ret
;
;TempClos ENDP
;
;; -----------------------------------------------------------------------------
;;        z pis paritn¡ diskety do souboru (neuchov v  registry)
;; -----------------------------------------------------------------------------
;
;ZapOutp  PROC      NEAR
;
;; ------ uzav©en¡ p©echodn‚ho souboru
;
;         mov       bx,ds:[TempIdnR]
;         or        bx,bx
;         jz        ZapOutp2
;         mov       ah,3eh
;         int       21h
;         jc        ZapOutp6
;         mov       word ptr ds:[TempIdnR],0
;         test      byte ptr ds:[Operace],bit7
;         jz        ZapOutp2
;         mov       word ptr ds:[TempIdnW],0
;
;; ------ uzav©en¡ star‚ho souboru
;
;ZapOutp2:mov       bx,ds:[OutpIdnt]         ; identifik tor souboru
;         or        bx,bx
;         jz        ZapOutp3
;         mov       ah,3eh
;         int       21h                      ; uzav©en¡ souboru
;         jc        ZapOutp6
;         mov       word ptr ds:[OutpIdnt],0
;
;; ------ zru¨en¡ star‚ho souboru
;
;         mov       dx,offset OutpFile
;         mov       ah,41h
;         int       21h                      ; zru¨en¡ star‚ho souboru
;         jc        ZapOutp6
;
;; ------ p©ejmenov n¡ souboru
;
;ZapOutp3:push      ds
;         pop       es
;         mov       dx,offset TempFilR       ; p–vodn¡ soubor
;         mov       di,offset OutpFile       ; nov‚ jm‚no
;         mov       ah,56h
;         int       21h                      ; p©ejmenov n¡ souboru
;         jnc       ZapOutp7
;
;; ------ chyba z pisu
;
;ZapOutp6:mov       si,offset ErrOWTxt
;         jmp       Chyba
;
;; ------ otev©en¡ v˜stupn¡ho souboru pro ‡ten¡
;
;ZapOutp7:mov       dx,offset OutpFile       ; v˜stupn¡ soubor
;         mov       ax,3d00h
;         int       21h                      ; otev©en¡ pro ‡ten¡
;         jc        ZapOutp6
;         xchg      ax,bx                    ; BX <- identifik tor
;
;; ------ ur‡en¡ velikosti bufferu
;
;         mov       cx,ds:[BuffMax]          ; velikost bufferu
;         cmp       cx,120
;         jb        ZapOut72
;         mov       cx,120
;ZapOut72:mov       ch,cl
;         mov       cl,0
;         shl       cx,1                     ; max. velikost
;         mov       word ptr ds:[EDC],-1
;
;; ------ na‡ten¡ bloku dat ze souboru
;
;ZapOut74:push      ds
;         mov       ds,ds:[BuffDat]          ; datov˜ buffer
;         xor       dx,dx
;         mov       ah,3fh
;         int       21h                      ; na‡ten¡ bloku dat
;         pop       ds
;         jc        ZapOutp6
;
;; ------ p©epo‡et dat na sektory
;
;         mov       al,ah
;         shr       al,1                     ; po‡et sektor–
;         jz        ZapOut78                 ; nejsou dal¨¡ data
;
;; ------ kontroln¡ sou‡et bloku dat
;
;         push      bx
;         mov       dx,ds:[EDC]
;         mov       es,ds:[BuffDat]
;         xor       bx,bx
;         call      CheckSum
;         mov       ds:[EDC],dx
;         pop       bx
;         jmp       short ZapOut74           ; dal¨¡ blok dat
;
;; ------ uzav©en¡ souboru
;
;ZapOut78:mov       ah,3eh
;         int       21h
;
;; ------ zobrazen¡ hl ¨en¡ o operaci
;
;         mov       ax,word ptr ds:[PartTxt1]
;         mov       word ptr ds:[EDCITxt3],ax
;         mov       ax,word ptr ds:[PartTxt1+2]
;         mov       word ptr ds:[EDCITxt3+2],ax
;
;         inc       word ptr ds:[NDisket]    ; zv˜¨en¡ ‡¡sla diskety
;         call      DekNDisk                 ; dek¢dov n¡ ‡¡sla diskety
;         call      DispEDC                  ; zobrazen¡ kontroln¡ho sou‡tu
;         ret
;
;ZapOutp  ENDP
;
;; -----------------------------------------------------------------------------
;;        resetov n¡ ukazatele v p©echodn‚m souboru
;; -----------------------------------------------------------------------------
;
;TempRes  PROC      NEAR
;
;         push      ax
;         xor       ax,ax
;         mov       word ptr ds:[ReadUTmp],ax
;         mov       word ptr ds:[ReadUTmp+2],ax
;         mov       word ptr ds:[WritUTmp],ax
;         mov       word ptr ds:[WritUTmp+2],ax
;         pop       ax
;         ret
;
;TempRes  ENDP
;
;; -----------------------------------------------------------------------------
;;        z pis dat z bufferu do p©echodn‚ho souboru
;; -----------------------------------------------------------------------------
;
;TempWrit PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      bp
;
;; ------ nastaven¡ ukazatele v souboru
;
;         mov       bx,ds:[TempIdnW]         ; identifik tor souboru
;         or        bx,bx                    ; je soubor otev©en ?
;         jz        TempWrt9                 ; nen¡ otev©en
;
;         mov       ax,4200h
;         mov       dx,word ptr ds:[WritUTmp] ; z pisov˜ offset
;         mov       cx,word ptr ds:[WritUTmp+2]
;         int       21h                      ; nastaven¡ ukazatele v souboru
;         jc        TempWrt4                 ; nˆjak  chyba
;
;; ------ p©¡prava ukazatel– k operaci
;
;         mov       bp,ds:[BuffUkaz]         ; ukazatel adresy v bufferu
;         mov       dx,ds:[BuffDat]          ; za‡ tek bufferu
;         mov       ds:[BuffUkaz],dx         ; nov  ukl dac¡ adresa
;         sub       bp,dx                    ; po‡et dat k ulo‘en¡
;         jbe       TempWrt9                 ; nejsou ‘ dn  data k ulo‘en¡
;
;; ------ velikost bloku dat pro jednu operaci
;
;TempWrt2:mov       cx,120*512/16            ; asi tak velikost jednoho bloku
;         cmp       cx,bp
;         jb        TempWrt3
;         mov       cx,bp                    ; omezen¡ velikosti dat
;TempWrt3:sub       bp,cx                    ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat
;         shl       cx,1
;         shl       cx,1
;         shl       cx,1
;         shl       cx,1                     ; p©epo‡et na bajty
;
;; ------ z pis jednoho bloku dat do souboru
;
;         push      dx
;         push      ds
;         mov       ds,dx                    ; segment adresy bufferu
;         xor       dx,dx                    ; offset adresy bufferu
;         mov       ah,40h
;         int       21h                      ; z pis dat do souboru
;         pop       ds
;         pop       dx
;
;; ------ chyba z pisu do souboru
;
;         jc        TempWrt4                 ; chyba z pisu
;         cmp       ax,cx                    ; bylo zaps no v¨e ?
;         je        TempWrt5                 ; je zaps no v¨e OK
;         mov       si,offset ErrTWDTx       ; nedostatek m¡sta na disku
;         jmp       short TempWr42
;TempWrt4:mov       si,offset ErrTWTxt
;TempWr42:call      MazText                  ; vymaz n¡ © dku
;         jmp       Chyba
;
;; ------ p©¡prava pro dal¨¡ blok dat
;
;TempWrt5:add       word ptr ds:[WritUTmp],cx ; zv˜¨en¡ ukazatele v souboru
;         adc       word ptr ds:[WritUTmp+2],0
;         add       dx,120*512/16            ; zv˜¨en¡ adresy bufferu
;         or        bp,bp                    ; je dal¨¡ m¡sto ?
;         jnz       TempWrt2                 ; na‡ten¡ dal¨¡ho bloku dat
;
;; ------ n vrat registr–
;
;TempWrt9:mov       word ptr ds:[BuffCit],0  ; nezbyly ‘ dn‚ sektory
;         pop       bp
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;TempWrit ENDP
;
;; -----------------------------------------------------------------------------
;;        na‡ten¡ bufferu z p©echodn‚ho souboru
;; -----------------------------------------------------------------------------
;
;TempRead PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      di
;         push      bp
;         push      es
;
;; ------ p©¡prava k na‡ten¡ dat ze souboru
;
;         mov       dx,ds:[BuffDat]          ; za‡ tek datov‚ho bufferu
;         mov       bp,ds:[BuffMax]          ; maxim ln¡ po‡et sektor– k na‡ten¡
;         mov       ds:[BuffCit],bp          ; ‡¡ta‡ zbyl˜ch sektor– v bufferu
;         mov       ds:[BuffUkaz],dx         ; ukazatel adresy v bufferu
;
;; ------ test, zda je p©echodn˜ soubor otev©en
;
;         mov       bx,ds:[TempIdnR]         ; identifik tor souboru
;         or        bx,bx
;         jz        TempRea9                 ; soubor nen¡ otev©en
;
;; ------ nastaven¡ ukazatele v souboru
;
;         push      dx
;         mov       ax,4200h
;         mov       dx,word ptr ds:[ReadUTmp] ; ‡tec¡ offset
;         mov       cx,word ptr ds:[ReadUTmp+2]
;         int       21h                      ; nastaven¡ ukazatele v souboru
;         pop       dx
;         jc        TempRea4                 ; nˆjak  chyba
;
;; ------ stanoven¡ po‡tu sektor– pro jednu operaci
;
;TempRea2:mov       cx,120                   ; asi tak maximum pro jednu operaci
;         cmp       cx,bp
;         jb        TempRea3
;         mov       cx,bp                    ; omezen¡ po‡tu sektor–
;TempRea3:sub       bp,cx                    ; sn¡‘en¡ zbyl‚ho po‡tu sektor–
;
;; ------ inicializa‡n¡ vymaz n¡ bufferu
;
;         mov       ch,cl                    ; CH <- po‡et sektor–
;         mov       cl,0
;         push      cx                       ; po‡et slov
;         xor       ax,ax
;         xor       di,di
;         mov       es,dx                    ; adresa bufferu
;         cld
;         rep       stosw                    ; vymaz n¡ bufferu
;         pop       cx
;         shl       cx,1                     ; po‡et bajt– k na‡ten¡
;
;; ------ na‡ten¡ bloku dat
;
;         push      dx
;         push      ds
;         mov       ds,dx                    ; adresa bufferu
;         xor       dx,dx                    ; offset bufferu
;         mov       ah,3fh
;         int       21h                      ; na‡ten¡ bloku dat
;         pop       ds
;         pop       dx
;         jnc       TempRea5                 ; operace ‡ten¡ OK
;
;; ------ chyba ‡ten¡ ze souboru
;
;TempRea4:mov       si,offset ErrTRTxt
;         jmp       Chyba
;
;; ------ p©¡prava pro dal¨¡ blok dat
;
;TempRea5:add       word ptr ds:[ReadUTmp],cx ; zv˜¨en¡ ukazatele v souboru
;         adc       word ptr ds:[ReadUTmp+2],0
;         add       dx,120*512/16            ; zv˜¨en¡ adresy bufferu
;         or        bp,bp                    ; je dal¨¡ m¡sto ?
;         jnz       TempRea2                 ; na‡ten¡ dal¨¡ho bloku dat
;
;; ------ n vrat registr–
;
;TempRea9:pop       es
;         pop       bp
;         pop       di
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;TempRead ENDP
;
;; -----------------------------------------------------------------------------
;;        na‡ten¡ stopy z p©echodn‚ho souboru
;; -----------------------------------------------------------------------------
;
;ReadTTrc PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      es
;
;; ------ kopie jednoho sektoru
;
;         mov       dh,0
;         mov       dl,ds:[NumSekt]          ; po‡et sektor– na stopu
;         mov       es,ds:[BuffDisk]         ; buffer stopy
;         xor       di,di                    ; ukl dac¡ adresa do bufferu
;ReadTTr2:xor       si,si
;         push      ds
;         mov       ds,ds:[BuffUkaz]         ; ukazatel v bufferu
;         mov       cx,512/2                 ; d‚lka jednoho sektoru
;         cld
;         rep       movsw                    ; kopie sektoru
;         pop       ds
;
;; ------ posun ukazatele k dal¨¡mu sektoru
;
;         add       word ptr ds:[BuffUkaz],512/16 ; zv˜¨en¡ ukazatele v bufferu
;         dec       word ptr ds:[BuffCit]    ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch sektor–
;         jnz       ReadTTr4                 ; jsou dal¨¡ sektory
;         call      TempRead                 ; na‡ten¡ dal¨¡ho bloku dat
;ReadTTr4:dec       dx                       ; ‡¡ta‡ sektor–
;         jnz       ReadTTr2                 ; dal¨¡ sektor
;
;; ------ n vrat registr–
;
;         pop       es
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;ReadTTrc ENDP

; *****************************************************************************
;
;                                 R–zn‚
;
; *****************************************************************************
;ş
; -----------------------------------------------------------------------------
;        skok podle hodnoty AL, CS=DS ! (n vratov  adresa = tabulka skok–)
; -----------------------------------------------------------------------------

JumpAL   PROC      NEAR

; ------ £schova registr–
                                            ; SS:[BP+4] n vratov  adresa
         push      bx                       ; SS:[BP+2]
         push      bp                       ; SS:[BP+0]
         mov       bp,sp                    ; BP <- lok ln¡ promˆnn‚

; ------ adresa tabulky skok–

         mov       bx,ss:[bp+4]             ; BX <- n vratov  adresa NEAR

; ------ test, zda je ji‘ konec tabulky

JumpAL2: cmp       byte ptr ds:[bx],0       ; je ji‘ konec tabulky ?
         je        JumpAL9                  ; je ji‘ konec tabulky

; ------ test, zda to je hledan  hodnota

         cmp       al,ds:[bx]               ; je to hledan  hodnota ?
         je        JumpAL9                  ; je to hledan  hodnota

; ------ zv˜¨en¡ ukazatele v tabulce

         inc       bx
         inc       bx
         inc       bx
         jmp       short JumpAL2

; ------ nastaven¡ adresy skoku

JumpAL9: mov       bx,ds:[bx+1]             ; adresa skoku
         mov       ss:[bp+4],bx             ; nov  n vratov  adresa

; ------ n vrat registr– a skok na obsluhu funkce

         pop       bp
         pop       bx
         ret

JumpAL   ENDP

;; -----------------------------------------------------------------------------
;;        dek¢dov n¡ velikosti disku
;; -----------------------------------------------------------------------------
;
;DekFDsk  PROC      NEAR
;
;         push      di
;         mov       di,offset DFormT1
;         call      DekFDsk0
;         mov       di,offset DFormT2
;         call      DekFDsk0
;         mov       di,offset DFormT3
;         call      DekFDsk0
;         mov       di,offset DFormT4
;         call      DekFDsk0
;         pop       di
;         ret
;
;DekFDsk  ENDP
;
;DekFDsk0 PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      dx
;         push      es
;
;; ------ p©¡prava registr–
;
;         push      ds
;         pop       es
;         mov       ax,ds:[CelkSkt0]         ; celkem sektor–
;         shr       ax,1                     ; kapacita v KB
;         mov       word ptr ds:[di],"  "
;         mov       word ptr ds:[di+2],"  "
;
;; ------ dek¢dov n¡ kapacity pro kapacitu < 1 MB
;
;         cmp       ax,1000
;         jae       DekFDsk2                 ; je v¡ce ne‘ 1 MB
;         inc       di
;         inc       di
;         mov       byte ptr ds:[di+2],"K"   ; £daj v KB
;         call      DekNum                   ; dek¢dov n¡ ‡¡sla kapacity
;         jmp       short DekFDsk8
;
;; ------ dek¢dov n¡ kapacity v MB
;
;DekFDsk2:mov       byte ptr ds:[di+4],"M"   ; £daj v MB
;         xor       dx,dx
;         mov       cx,1000
;         div       cx                       ; po‡et MB
;         add       al,"0"
;         cld
;         mov       ah,"."
;         stosw                              ; ‡¡slice MB a te‡ka
;         mov       al,"0"
;         stosb
;         xor       ax,ax
;         xchg      ax,dx                    ; desetiny
;         mov       cx,10
;         div       cx                       ; stovky
;         call      DekNum                   ; dek¢dov n¡ des¡tek KB
;         cmp       byte ptr ds:[di],"0"
;         jne       DekFDsk8
;         mov       byte ptr ds:[di]," "
;
;; ------ n vrat registr–
;
;DekFDsk8:pop       es
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;DekFDsk0 ENDP
;
;; -----------------------------------------------------------------------------
;;        dek¢dov n¡ ‡¡sla diskety
;; -----------------------------------------------------------------------------
;
;DekNDisk PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      dx
;         push      di
;         push      es
;
;; ------ p©¡prava registr–
;
;         push      ds
;         pop       es                       ; ES <- datov˜ segment
;         mov       ax,ds:[NDisket]          ; ‡¡slo diskety
;         xor       dx,dx
;         mov       cx,1000                  ; omezen¡ velikosti ‡¡sla
;         div       cx
;         xchg      ax,dx                    ; AX <- ‡¡slo diskety (zarovnan‚)
;
;; ------ dek¢dov n¡ ‡¡sla diskety
;
;         mov       di,offset IdntTx21 + 2
;         call      DekNum
;         mov       di,offset NactTxt2 + 2
;         call      DekNum
;
;; ------ n vrat registr–
;
;         pop       es
;         pop       di
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;DekNDisk ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla AX do bufferu ES:DI (=n sleduj¡c¡ pozice) zpˆtnˆ -> DI
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ dek¢dov n¡ ‡¡sla

         mov       cx,10                    ; dˆlitel
DekNum1: xor       dx,dx                    ; DX <- 0
         div       cx                       ; v˜po‡et jedn‚ ‡¡slice
         add       dl,"0"                   ; ‡¡slice
         dec       di                       ; posun ukazatele v bufferu
         mov       es:[di],dl               ; ulo‘en¡ ‡¡slice
         or        ax,ax                    ; je ‡¡slo ji‘ = 0 ?
         jnz       DekNum1                  ; dal¨¡ ‡¡slice

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP

;; -----------------------------------------------------------------------------
;;        dek¢dov n¡ identifika‡n¡ho k¢du diskety
;; -----------------------------------------------------------------------------
;
;DekEDCI  PROC      NEAR
;
;         push      ax
;         push      di
;         push      es
;
;         push      ds
;         pop       es
;         mov       ax,ds:[EDCIdent]         ; identifika‡n¡ k¢d diskety
;         mov       di,offset CtuTxt4
;         call      HexWord
;         mov       di,offset ZapTxt4
;         call      HexWord
;         mov       di,offset EDCITxt2
;         call      HexWord
;         mov       di,offset EDCITxt3
;         call      HexWord
;
;         pop       es
;         pop       di
;         pop       ax
;         ret
;
;DekEDCI  ENDP
;
;; -----------------------------------------------------------------------------
;;        dek¢dov n¡ identifika‡n¡ho k¢du paritn¡ diskety
;; -----------------------------------------------------------------------------
;
;DekEDCP  PROC      NEAR
;
;         push      ax
;         push      di
;         push      es
;
;         push      ds
;         pop       es
;         mov       ax,ds:[EDCParit]         ; identifika‡n¡ k¢d diskety
;         mov       di,offset PartTxt1
;         call      HexWord
;         mov       di,offset VystTxt1
;         call      HexWord
;         mov       di,offset ZapTxt4
;         call      HexWord
;         mov       di,offset GenTxt22
;         call      HexWord
;
;         pop       es
;         pop       di
;         pop       ax
;         ret
;
;DekEDCP  ENDP
;
;; -----------------------------------------------------------------------------
;;        zobrazen¡ kontroln¡ho sou‡tu
;; -----------------------------------------------------------------------------
;
;DispEDC  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      si
;         push      di
;         push      es
;
;; ------ dek¢dov n¡ kontroln¡ho sou‡tu
;
;         push      ds
;         pop       es
;         mov       di,offset EDCTxt
;         mov       ax,ds:[EDC]              ; kontroln¡ sou‡et diskety
;         call      HexWord                  ; dek¢dov n¡ slova HEX
;
;; ------ zobrazen¡ hl ¨en¡
;
;         mov       si,offset NactTxt
;         call      StdOut
;         call      RepOut                   ; v˜stup do protokolu
;
;; ------ n vrat registr–
;
;         pop       es
;         pop       di
;         pop       si
;         pop       ax
;         ret
;
;DispEDC  ENDP
;
;; -----------------------------------------------------------------------------
;;        dek¢dov n¡ slova HEX (AX) do bufferu ES:DI
;; -----------------------------------------------------------------------------
;
;HexWord  PROC      NEAR
;
;         xchg      al,ah
;         call      HexByte                  ; dek¢dov n¡ bajtu HEX
;         xchg      al,ah
;
;HexByte: push      ax
;         shr       al,1
;         shr       al,1
;         shr       al,1
;         shr       al,1
;         call      HexChr
;         pop       ax
;
;HexChr:  push      ax
;         and       al,0fh                   ; znak
;         cmp       al,9
;         jbe       HexChr2
;         add       al,7
;HexChr2: add       al,"0"
;         cld
;         stosb
;         pop       ax
;         ret
;
;HexWord  ENDP
;
;; -----------------------------------------------------------------------------
;;        identifika‡n¡ k¢d diskety (na‡tena stopa 0, strana 0)
;; -----------------------------------------------------------------------------
;
;SumEDCI  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      dx
;         push      es
;
;; ------ identifika‡n¡ k¢d
;
;         mov       es,ds:[BuffDisk]         ; buffer stopy
;         xor       bx,bx                    ; offset stopy
;         mov       al,ds:[NumSekt]          ; po‡et sektor–
;         mov       dx,-1                    ; identifika‡n¡ k¢d diskety
;         call      CheckSum                 ; kontroln¡ sou‡et stopy
;         mov       ds:[EDCIdent],dx         ; identifika‡n¡ k¢d diskety
;         call      DekEDCI                  ; dek¢dov n¡ identifika‡n¡ho k¢du
;
;; ------ n vrat registr–
;
;         pop       es
;         pop       dx
;         pop       bx
;         pop       ax
;         ret
;
;SumEDCI  ENDP
;
;; -----------------------------------------------------------------------------
;;        identifika‡n¡ k¢d paritn¡ diskety (na‡tena stopa 0, strana 0)
;; -----------------------------------------------------------------------------
;
;SumEDCP  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      dx
;         push      es
;
;; ------ identifika‡n¡ k¢d
;
;         mov       es,ds:[BuffDat]          ; buffer stopy
;         xor       bx,bx                    ; offset stopy
;         mov       al,ds:[NumSekt]          ; po‡et sektor–
;         mov       dx,-1                    ; identifika‡n¡ k¢d diskety
;         call      CheckSum                 ; kontroln¡ sou‡et stopy
;         mov       ds:[EDCParit],dx         ; identifika‡n¡ k¢d par. diskety
;         call      DekEDCP                  ; dek¢dov n¡ identifika‡n¡ho k¢du
;
;; ------ n vrat registr–
;
;         pop       es
;         pop       dx
;         pop       bx
;         pop       ax
;         ret
;
;SumEDCP  ENDP
;
;; -----------------------------------------------------------------------------
;;        kontroln¡ sou‡et EDC cel‚ stopy
;; -----------------------------------------------------------------------------
;
;CheckSm0 PROC      NEAR
;
;         push      ax
;         push      bx
;         push      dx
;         push      es
;
;         mov       dx,ds:[EDC]              ; star  hodnota EDC
;         xor       bx,bx                    ; po‡ tek dat
;         mov       es,ds:[BuffDisk]         ; buffer na‡ten‚ stopy
;         mov       al,ds:[NumSekt]          ; po‡et sektor– na stopu
;         call      CheckSum                 ; kontroln¡ sou‡et dat
;         mov       ds:[EDC],dx              ; v˜stupn¡ hodnota EDC
;
;         pop       es
;         pop       dx
;         pop       bx
;         pop       ax
;         ret
;
;CheckSm0 ENDP
;
;; -----------------------------------------------------------------------------
;;        Kontroln¡ sou‡et EDC dat ES:BX (AL sektor–) z DX -> DX
;; -----------------------------------------------------------------------------
;
;CheckSum PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      si
;         push      di
;
;; ------ p©¡prava registr–
;
;         mov       ah,al                    ; AH <- po‡et sektor–
;         mov       al,0
;         shl       ax,1                     ; po‡et bajt– v bufferu
;         xchg      ax,di                    ; DI <- po‡et bajt–
;         mov       si,bx                    ; SI <- adresa dat
;         cld                                ; smˆr nahoru
;
;; ------ kontroln¡ sou‡et dat
;
;         push      ds
;         push      es
;         pop       ds
;
;CheckSm1:lodsb                              ; a = fgetc(fp);
;         xor       al,dh                    ; d = a ^= d;
;         mov       dh,al
;         mov       cl,4
;         shr       al,cl                    ; a >>= 4;
;         xor       al,dh                    ; d = a ^= d;
;         mov       dh,al
;         mov       cl,3
;         ror       al,cl                    ; a = (a >> 3) | (a << 5);
;         mov       ch,al                    ; f = a;
;         and       al,1fh                   ; a &= 0x1f;
;         xor       al,dl                    ; e = a ^= e;
;         mov       dl,al
;         mov       al,ch                    ; a = f;
;         ror       al,1                     ; a = (a >> 1) | (a << 7);
;         and       al,0f0h                  ; a &= 0xf0;
;         xor       al,dl                    ; e = a ^= e;
;         mov       dl,al
;         mov       al,ch                    ; a = f & 0xe0;
;         and       al,0e0h
;         xor       al,dh                    ; a ^= d;
;         mov       dh,dl                    ; d = e;
;         mov       dl,al                    ; e = a;
;
;         dec       di
;         jnz       CheckSm1                 ; dal¨¡ bajt
;         pop       ds
;
;; ------ n vrat registr–
;
;         pop       di
;         pop       si
;         pop       cx
;         pop       ax
;         ret
;
;CheckSum ENDP

; -----------------------------------------------------------------------------
;        test, zda je p©eru¨en¡ operace (CY=je p©eru¨en¡)
; -----------------------------------------------------------------------------

TstBreak PROC      NEAR

         test      byte ptr ds:[Param],bit7 ; je p©eru¨en¡ ?
         jz        TstBrea2                 ; nen¡ p©eru¨en¡
         stc                                ; p©¡znak p©eru¨en¡ operace
TstBrea2:ret

TstBreak ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ p©¡znaku p©eru¨en¡
; -----------------------------------------------------------------------------

NulBreak PROC      NEAR

         and       byte ptr ds:[Param],not bit7
         ret

NulBreak ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ p©¡znaku p©eru¨en¡ (nastavuje p©¡znak CY !)
; -----------------------------------------------------------------------------

SetBreak PROC      NEAR

         or        byte ptr ds:[Param],bit7
         stc                                ; p©¡znak p©eru¨en¡
         ret

SetBreak ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 23h
; -----------------------------------------------------------------------------

INT23    PROC      FAR

         iret

INT23    ENDP

; *****************************************************************************
;
;                            Obsluha pamˆti XMS
;
; *****************************************************************************
;ş
; -----------------------------------------------------------------------------
;        Inicializace pamˆti XMS
; -----------------------------------------------------------------------------

InitXMS  PROC      NEAR

; ------ test, zda je z kaz pou‘¡v n¡ pamˆti XMS

         test      byte ptr ds:[Param],bit3 ; je z kaz pou‘¡v n¡ XMS ?
         jz        InitXMS1                 ; nen¡ z kaz XMS
         ret                                ; je z kaz pou‘¡v n¡ pamˆti XMS

; ------ test instalace XMS

InitXMS1:mov       ax,4300h
         call      Int2F                    ; test instalace XMS
         cmp       al,80h
         jne       InitXMS4                 ; nen¡ XMS

; ------ adresa ovlada‡e XMS -> ES:BX

         mov       bx,-1                    ; BX <- -1 p©ednastaven¡ nesmyslu
         xor       ax,ax
         mov       es,ax                    ; ES <- 0 p©ednastaven¡ nesmyslu
         mov       ax,4310h
         call      Int2F                    ; adresa ovlada‡e XMS
         mov       word ptr ds:[DriveXMS],bx ; adreas vlada‡e XMS
         mov       word ptr ds:[DriveXMS+2],es

; ------ test, zda je adresa platn 

         cmp       bx,-6                    ; je offset platn˜ ?
         jae       InitXMS4                 ; adresa nen¡ platn 
         mov       ax,es                    ; AX <- segment adresy
         cmp       ax,50h                   ; je segment platn˜ ?
         jb        InitXMS4                 ; adresa nen¡ platn 

; ------ verze ovlada‡e XMS

         mov       ah,0                     ; funkce 0
         call      XMS                      ; zji¨tˆn¡ verze XMS
         mov       ds:[VerzeXMS],ax         ; verze ovlada‡e XMS (v BCD k¢du)
         cmp       ax,200h                  ; minim ln¡ verze 2.00
         jb        InitXMS4                 ; je n¡zk  verze ovlada‡e XMS

; ------ zji¨tˆn¡ voln‚ pamˆti XMS

         mov       ah,8
         mov       bl,0
         call      XMS                      ; zji¨tˆn¡ voln‚ pamˆti XMS
         or        bl,bl                    ; je operace OK ?
         jnz       InitXMS4                 ; nˆjak  chyba
         cmp       ax,40                    ; tolik pamˆti minim lnˆ
         jb        InitXMS4                 ; je m lo pamˆti

; ------ p©epo‡et voln‚ pamˆti na bajty

         push      ax
         mov       dx,1024                  ; velikost jednoho KB
         mul       dx                       ; p©epo‡et na bajty
         mov       word ptr ds:[SizeXMS],ax ; velikost voln‚ pamˆti XMS
         mov       word ptr ds:[SizeXMS+2],dx
         pop       dx                       ; DX <- po‘adovan  pamˆŸ XMS

; ------ zabr n¡ cel‚ pamˆti XMS (DX=velikost voln‚ pamˆti XMS)

         mov       ah,9
         push      dx                       ; voln  pamˆŸ v KB
         call      XMS                      ; po‘ d n¡ o celou pamˆŸ XMS
         pop       ax                       ; AX <- voln  pamˆŸ v KB
         jc        InitXMS4                 ; chyba
         mov       ds:[TabWXMSI],dx         ; identifik tor pro z pis
         mov       ds:[TabRXMSI],dx         ; identifik tor pro ‡ten¡

; ------ ovlada‡ MXS je platn˜ OK

         or        byte ptr ds:[Param],bit2 ; p©¡znak ovlada‡e XMS

; ------ hl ¨en¡ o detekov n¡ pamˆti XMS - 1. ‡ st

         mov       si,offset XMSTxt         ; text - "detekov na XMS"
         call      StdOut                   ; zobrazen¡ hl ¨en¡

; ------ dek¢dov n¡ voln‚ pamˆti AX

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset XMSTxt2        ; buffer k dek¢dov n¡ voln‚ pamˆti
         call      DekNum                   ; dek¢dov n¡ voln‚ pamˆti
         mov       ax,offset XMSTxt0        ; konec textu hl ¨en¡
         sub       ax,di                    ; velikost textu
         dec       di
         dec       di
         mov       ds:[di],ax               ; d‚lka textu hl ¨en¡

; ------ zobrazen¡ druh‚ ‡ sti hl ¨en¡

         mov       si,di                    ; SI <- za‡ tek hl ¨en¡
         call      StdOut                   ; zobrazen¡ textu hl ¨en¡
InitXMS4:ret

InitXMS  ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ pamˆti XMS
; -----------------------------------------------------------------------------

DIniXMS  PROC      NEAR

; ------ test, zda byla pamˆŸ XMS p©idˆlena

         test      byte ptr ds:[Param],bit2 ; byla pamˆŸ XMS p©idˆlena ?
         jz        DIniXMS2                 ; pamˆŸ XMS nebyla p©idˆlena

; ------ uvolnˆn¡ p©idˆlen‚ho bloku XMS

         push      ax
         push      bx
         push      dx

         mov       ah,0ah
         mov       dx,ds:[TabWXMSI]         ; identifik tor bloku
         call      XMS                      ; uvolnˆn¡ bloku

         pop       dx
         pop       bx
         pop       ax
DIniXMS2:ret

DIniXMS  ENDP

; -----------------------------------------------------------------------------
;        uvolnˆn¡ z kladn¡ pamˆti
; -----------------------------------------------------------------------------

DIniMem  PROC      NEAR

         push      ax
         push      es

         mov       ax,ds:[BuffAdr]          ; AX <- adresa bufferu
         or        ax,ax
         jz        DIniMem9
         mov       es,ax
         mov       ah,49h
         int       21h

DIniMem9:pop       es
         pop       ax
         ret

DIniMem  ENDP

;; *****************************************************************************
;;                               WritXMS
;;                       z pis dat do bloku XMS
;; -----------------------------------------------------------------------------
;; VSTUP: DX=ovlada‡ bloku XMS
;;        ES=segment dat k z pisu
;;        BX=po‡et odstavc– dat k z pisu
;;        DS=datov˜ segment
;; VSTUP: CY=chyba
;; *****************************************************************************
;
;WritXMS  PROC      FAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;
;; ------ c¡lov˜ identifik tor
;
;         mov       si,offset TabWXMS        ; tabulka popisova‡e operace XMS
;         mov       ds:[si+10],dx            ; c¡lov˜ identifik tor
;
;; ------ po‡et bajt– k z pisu
;
;         xor       ax,ax                    ; AX <- 0
;         xchg      ax,bx                    ; AX <- po‡et odstavc– dat k z pisu
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si],ax               ; po‡et bajt– k z pisu
;         mov       ds:[si+2],bx
;
;; ------ zdrojov  adresa
;
;         mov       ax,es                    ; AX <- segment dat
;         xor       bx,bx
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si+6],ax             ; zdrojov  adresa
;         mov       ds:[si+6+2],bx
;
;; ------ proveden¡ operace
;
;         mov       ah,0bh
;         push      cs
;         call      near ptr XMS             ; proveden¡ p©esunu dat
;
;; ------ n vrat registr–
;
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;WritXMS  ENDP
;
;; *****************************************************************************
;;                               ReadXMS
;;                       na‡ten¡ dat z bloku XMS
;; -----------------------------------------------------------------------------
;; VSTUP: DX=ovlada‡ bloku XMS
;;        ES=segment bufferu
;;        BX=po‡et odstavc– dat ke ‡ten¡
;;        DS=datov˜ segment
;; VSTUP: CY=chyba
;; *****************************************************************************
;
;ReadXMS  PROC      FAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;
;; ------ zdrojov˜ identifik tor
;
;         mov       si,offset TabRXMS        ; tabulka popisova‡e operace XMS
;         mov       ds:[si+4],dx             ; zdrojov˜ identifik tor
;
;; ------ po‡et bajt– k na‡ten¡
;
;         xor       ax,ax                    ; AX <- 0
;         xchg      ax,bx                    ; AX <- po‡et odstavc– dat k na‡ten¡
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si],ax               ; po‡et bajt– k na‡ten¡
;         mov       ds:[si+2],bx
;
;; ------ c¡lov  adresa
;
;         mov       ax,es                    ; AX <- segment dat
;         xor       bx,bx
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si+12],ax            ; c¡lov  adresa
;         mov       ds:[si+12+2],bx
;
;; ------ proveden¡ operace
;
;         mov       ah,0bh
;         push      cs
;         call      near ptr XMS             ; proveden¡ p©esunu dat
;
;; ------ n vrat registr–
;
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;ReadXMS  ENDP

; -----------------------------------------------------------------------------
;        vol n¡ funkce AH ovlada‡e pamˆti XMS -> CY=chyba funkce (AX=0)
; -----------------------------------------------------------------------------

XMS      PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ vol n¡ funkce XMS, test n vratov‚ho k¢du (nesm¡ b˜t AX=0)

         pushf
         call      dword ptr ds:[DriveXMS]  ; vol n¡ funkce ovlada‡e XMS
         popf
         cmp       ax,1                     ; je operace OK ?

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       cx
         ret

XMS      ENDP

; -----------------------------------------------------------------------------
;        vol n¡ INT 2Fh s £schovou registr–
; -----------------------------------------------------------------------------

Int2F    PROC      NEAR

         pushf
         push      si
         push      di
         push      ds

         int       2fh

         pop       ds
         pop       di
         pop       si
         popf
         ret

Int2F    ENDP

; *****************************************************************************
;
;                             Data
;
; *****************************************************************************
;ş
Operace  dw        0                        ; zadan  prov dˆn  operace
                                            ;   bit 0: 1=generov n¡ paritn¡ diskety
                                            ;   bit 1: 1=obnoven¡ po¨kozen‚ diskety
                                            ;   bit 2: 1=modifikace archivu
                                            ;   bit 3: 1=test archivu
                                            ;   bit 4: 1=verifikace diskety
                                            ;   bit 5: 1=identifikace diskety
                                            ;   bit 6: 1=‡ten¡ diskety
                                            ;   bit 7: 1=z pis diskety
                                            ;   bit 8: 1=kop¡rov n¡ diskety

Param    db        0                        ; parametry
                                            ;   bit 0: 1=vytvo©en soubor REP
                                            ;   bit 1: 1=vytvo©en soubor TEMP
                                            ;   bit 2: 1=p©idˆlena pamˆŸ XMS
                                            ;   bit 3: 1=z kaz pou‘¡v n¡ XMS
                                            ;   bit 4: 1=z kaz protokolu REP

                                            ;   bit 6: 1=p©edefinov no INT 1Eh
                                            ;   bit 7: 1=je p©eru¨en¡ operace

Param2   db        0                        ; parametry 2
                                            ;   bit 0: 1=na‡ten alespo¤ 1 disk
                                            ;   bit 3: 1=nekompatibiln¡ BOOT
                                            ;   bit 4: 1=je paritn¡ disketa


;Param    db        0                        ; parametry
;                                            ;   bit 0: 1=paritn¡ disketa v souboru
;                                            ;   bit 1: 1=dopl¤uje se obn. disk
;                                            ;   bit 2: 1=ur‡en  paritn¡ disketa
;                                            ;   bit 5: 1=byla ji‘ prvn¡ disketa
;
;EDC      dw        -1                       ; st©ada‡ kontroln¡ho sou‡tu diskety
;EDCIdent dw        -1                       ; identifika‡n¡ CRC diskety
;EDCParit dw        -1                       ; identifika‡n¡ CRC paritn¡ diskety

AktHlas  dw        InitTxt                  ; adresa aktu ln¡ho hl ¨en¡ diskety

;NDisket  dw        0                        ; ‡¡ta‡ ‡¡sla disket
;
;UspechS  dw        0                        ; ‡¡ta‡ nulov˜ch sektor– p©i testu

; ------ buffery

BuffAdr  dw        0                        ; adresa za‡ tku p©idˆlen‚ho bufferu
BuffSize dw        0                        ; velikost bufferu celkem (odstavc–)

BuffDisk dw        0                        ; adresa bufferu stopy pro disk. p©¡stup

;BuffDskV dw        0                        ; adresa bufferu verifikovan‚ stopy
;
;BuffDat  dw        0                        ; za‡ tek datov‚ho bufferu
;BuffUkaz dw        0                        ; ukazatel adresy v bufferu
;BuffCit  dw        0                        ; ‡¡ta‡ zbyl˜ch sektor– v bufferu
;BuffMax  dw        0                        ; maxim ln¡ po‡et sektor– v bufferu

; ------ parametry diskety

Disk     db        0                        ; ‡¡slo disku (0 nebo 1)

                                          ;* aktu ln¡ platn‚ parametry
NumStop  db        40                       ; po‡et stop
NumStran db        1                        ; po‡et stran
NumSekt  db        8                        ; po‡et sektor– na stopu
CelkSekt dw        8*1*40                   ; celkem sektor– na disku

                                          ;* parametry z¡skan‚ z diskety
NumStop0 db        40                       ; po‡et stop (na‡ten˜)
NumStrn0 db        1                        ; po‡et stran (na‡ten˜)
NumSekt0 db        8                        ; po‡et sektor– na stopu (na‡ten˜)
CelkSkt0 dw        8*1*40                   ; celkem sektor– na disku (na‡ten˜)

;; ------ p©echodn˜ soubor
;
;RepIdnt  dw        0                        ; identifik tor souboru hl ¨en¡
;OutpIdnt dw        0                        ; identifik tor v˜stupn¡ho souboru
;TempIdnR dw        0                        ; p©echodn˜ soubor pro ‡ten¡ (z pis)
;TempIdnW dw        0                        ; p©echodn˜ soubor pro z pis
;
;TempFil0 db        'SAFEDISK.$T$',0         ; p©echodn˜ soubor pro ‡ten¡ (z pis)
;                                            ;  pro ‡ten¡ koncov˜ znak $ pop©. _
;                                            ;  pro z pis p©¡pona @ pop©. %
;
;ReadUTmp dd        0                        ; ‡tec¡ ukazatel p©echodn‚ho souboru
;WritUTmp dd        0                        ; z pisov˜ ukazatel p©echod. souboru

; ------ ovlada‡ pamˆti XMS

DriveXMS dd        0                        ; adresa ovlada‡e XMS
VerzeXMS dw        0                        ; verze ovlada‡e XMS
SizeXMS  dd        0                        ; velikost voln‚ pamˆti XMS v B

; ------ tabulka pro z pis dat do XMS

TabWXMS  label     word
TabWXMSN dd        0                        ; po‡et bajt– k z pisu
         dw        0                        ; zdrojov˜ identifik tor
TabWXMSA dd        0                        ; zdrojov  adresa
TabWXMSI dw        0                        ; c¡lov˜ identifik tor
         dd        0                        ; c¡lov  adresa

; ------ tabulka pro ‡ten¡ dat z XMS

TabRXMS  label     word
TabRXMSN dd        0                        ; po‡et bajt– ke ‡ten¡
TabRXMSI dw        0                        ; zdrojov˜ identifik tor
         dd        0                        ; zdrojov  adresa
         dw        0                        ; c¡lov˜ identifik tor
TabRXMSA dd        0                        ; c¡lov  adresa

; ------ texty

UvTxt    dw        UvTxt0-UvTxt-2
         db        'SAFEDISK v1.00 - zabezpeceni archivnich disket; (c) Miroslav Nemecek',13,10
UvTxt0   label     byte
;ş
HelpTxt  dw        HelpTxt0-HelpTxt-2
         db        'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ  SAFEDISK   disk:  povel  ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»',13,10
         db        'º disk: ..... oznaceni pracovniho disku A: nebo B: (implicitne A:) º',13,10
         db        'º X ......... nepouzivat pamet XMS                                 º',13,10
         db        'º O ......... nezapisovat protokol o operaci (SAFEDISK.REP)        º',13,10
         db        'º ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ POVELY PRO SKUPINU DISKET ARCHIVU ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ º',13,10
         db        'º G ......... vygenerovani zabezpecovaci paritni diskety archivu   º',13,10
         db        'º U ......... obnoveni poskozene diskety archivu                   º',13,10
         db        'º M ......... modifikace archivu (pridani/vypusteni diskety)       º',13,10
         db        'º T ......... test zabezpeceni skupiny disket archivu              º',13,10
         db        'º ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ POVELY PRO JEDNU DISKETU ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ º',13,10
         db        'º V ......... verifikace diskety (overeni citelnosti)              º',13,10
         db        'º I ......... identifikace diskety (zobrazeni jmena a ident. kodu) º',13,10
         db        'º R soubor .. nacteni diskety do souboru (soubor bude prepsan !)   º',13,10
         db        'º W soubor .. zapis souboru na disketu (obsah bude prepsan !)      º',13,10
         db        'º C ......... kopirovani obsahu diskety v mechanice                º',13,10
         db        'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',13,10
         db        'Program  SAFEDISK  zabezpecuje diskety archivu vygenerovanim paritni',13,10
         db        'zabezpecovaci  diskety.  Paritni  disketa je bitovou logickou funkci',13,10
         db        'XOR  vsech  disket  archivu.  Po vzniku chyby na kterekoliv z disket',13,10
         db        '(casto i vice disketach soucasne) lze poskozenou disketu opet zpetne',13,10
         db        'vygenerovat  pomoci  paritni  diskety  a  vsech  zbyvajicich disket.',13,10
         db        'Do  souboru  SAFEDISK.REP  se  zapisuje  protokol o vsech operacich.',13,10
;         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  F R E E W A R E  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
HelpTxt0 label     byte

XMSTxt   dw        XMSTxt1-XMSTxt-2
         db        ' (Detekovana volna pamet XMS '
XMSTxt1  dw        0
         db        '     '
XMSTxt2  db        ' KB)',13,10
XMSTxt0  label     byte

;PrerTxt  dw        PrerTxt0-PrerTxt-2
;         db        '*PRERUSENO*',13,10
;PrerTxt0 label     byte

PrerMnu  db        2
         db        'A',25
         db        'N',32
         dw        PrerMnu0-$-2
         db        13,'Prerusit operaci ? ... (A)no, (N)e'
PrerMnu0 label     byte

MemTxt   dw        MemTxt0-MemTxt-2
         db        'CHYBA - nedostatek pameti !',13,10
MemTxt0  label     byte

;DatTxt   dw        DatTxt1-DatTxt-2
;         db        ' 0.00.   0   0:00:00 '
;DatTxt1  db        130 dup(0)
;
;DatTxt0  dw        5
;         db        5 dup(" ")

; ------ generov n¡ paritn¡ diskety

GenTxt   dw        GenTxt0-GenTxt-2
         db        'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '³            GENEROVANI zabezpecovaci paritni diskety              ³',13,10
         db        'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',13,10
         db        '³ Vkladejte postupne jednotlive diskety skupiny archivnich disket, ³',13,10
         db        '³ ktere chcete  zabezpecit  paritni  disketou.  Na  poradi a poctu ³',13,10
         db        '³ disket  nezalezi,  ale  dobre  si zaevidujte, ktere diskety tato ³',13,10
         db        '³ paritni disketa zabezpecuje (nejlepe na stitek paritni diskety), ³',13,10
         db        '³ jinak  nebude  obnoveni  disket  mozne. Je vhodne poznacit si na ³',13,10
         db        '³ diskety i jejich kontrolni soucty pro pozdejsi kontrolu  disket. ³',13,10
         db        '³ Pozor  -  vsechny  diskety  musi  mit stejny format (velikost) ! ³',13,10
         db        '³ Po vlozeni vsech disket skupiny  archivu zadejte povel "(Z)apis" ³',13,10
         db        '³ (kod za timto povelem je identifikacni kod paritni diskety).     ³',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
GenTxt0  label     byte

GenMnu1  db        3
         db        'D',27
         db        'S',36
         db        'P',46
         dw        GenMnu10-$-2
         db        13,'Vlozte disketu do '
DiskChr1 db        'A: ... (D)alsi, (S)oubor, (P)reruseni'
GenMnu10 label     byte

GenMnu2  db        4
         db        'D',27
         db        'S',36
         db        'Z',46
         db        'P',66
         dw        GenMnu20-$-2
         db        13,'Vlozte disketu do '
DiskChr2 db        'A: ... (D)alsi, (S)oubor, (Z)apis (kod='
GenMnu22 db        'FFFF), (P)reruseni'
GenMnu20 label     byte

;PartMnu  db        3
;         db        'Z',46
;         db        'N',55
;         db        'P',65
;
;PartTxt  dw        PartTxt0-PartTxt-2
;         db        13,'Bude zapsana PARITNI disketa (kod='
;PartTxt1 db        'FFFF) ... (Z)apis, (N)avrat, (P)reruseni'
;PartTxt0 label     byte
;
;ParitTxt dw        ParitTx0-ParitTxt-2
;         db        13,10
;         db        'Paritni disketa vygenerovana. Upozorneni - paritni disketu',13,10
;         db        'nelze pouzit v systemu DOS (oznacuje disketu jako vadnou).',13,10
;ParitTx0 label     byte

; ------ obnoven¡ diskety

ObnTxt   dw        ObnTxt0-ObnTxt-2
         db        'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '³                    OBNOVENI poskozene diskety                      ³',13,10
         db        'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',13,10
         db        '³ K obnoveni poskozene diskety ze skupiny disket potrebujete paritni ³',13,10
         db        '³ disketu,  kterou  byla  tato skupina zabezpecena a vsechny ostatni ³',13,10
         db        '³ diskety  ze skupiny. Postupne vkladejte nejdrive paritni disketu a ³',13,10
         db        '³ potom  vsechny  ostatni  diskety. Na zaver zvolte povel "(Z)apis", ³',13,10
         db        '³ ktery  vygeneruje  novou  opravovanou  disketu  (kod za povelem je ³',13,10
         db        '³ identifikacni kod teto diskety).                                   ³',13,10
         db        '³                                                                    ³',13,10
         db        '³ Pozn.: Pokud se behem operace objevila chyba na nektere z disket,  ³',13,10
         db        '³        obnovi se chybejici cast dat z puvodni poskozene diskety !  ³',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
ObnTxt0  label     byte

;ObnMnu1  db        3
;         db        'D',35
;         db        'M',43
;         db        'P',56
;
;ObnTxt1  dw        ObnTxt10-ObnTxt1-2
;         db        13,'Vlozte PARITNI disketu do '
;DiskChr7 db        'A: ... (D)ale, (M)echanika, (P)reruseni'
;ObnTxt10 label     byte
;
;VystMnu  db        3
;         db        'Z',47
;         db        'M',56
;         db        'P',69
;
;VystTxt  dw        VystTxt0-VystTxt-2
;         db        13,'Bude zapsana OBNOVENA disketa (kod='
;VystTxt1 db        'FFFF) ... (Z)apis, (M)echanika, (P)reruseni'
;VystTxt0 label     byte
;
;OprvMnu  db        3
;         db        'D',41
;         db        'Z',49
;         db        'P',58
;
;OprvTxt  dw        OprvTxt0-OprvTxt-2
;         db        13
;         db        'Vlozte OBNOVOVANOU disketu k doplneni: (D)ale, (Z)apis, (P)rerusit'
;OprvTxt0 label     byte

; ------ modifikace paritn¡ diskety

ModTxt   dw        ModTxt0-ModTxt-2
         db        'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '³                     MODIFIKACE paritni diskety                       ³',13,10
         db        'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',13,10
         db        '³ Tuto  funkci  pouzijte  v pripade, ze chcete pridat dalsi disketu ke ³',13,10
         db        '³ skupine  archivnich  disket nebo ze chcete nekterou disketu vypustit ³',13,10
         db        '³ (popr. vice disket). V pripade modifikace diskety ze skupiny archivu ³',13,10
         db        '³ musite  tuto  disketu nejdrive vypustit a po modifikaci opet pridat. ³',13,10
         db        '³ Mezi  operacemi pridani nebo vypusteni neni rozdil, oboji se provadi ³',13,10
         db        '³ stejnym  zpusobem.  Nejdrive  vlozte  paritni disketu, potom vsechny ³',13,10
         db        '³ diskety,  ktere  chcete  pridat  ci  vypustit.  Nakonec zvolte povel ³',13,10
         db        '³ "(Z)apis",  ktery  vygeneruje  novou  paritni disketu (muzete pouzit ³',13,10
         db        '³ puvodni disketu). Kod za povelem je identifik. kod paritni diskety.  ³',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
ModTxt0  label     byte

; ------ test celistvosti archivu

TstVTxt  dw        TstVTxt0-TstVTxt-2
         db        'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '³              TEST celistvosti skupiny disket archivu             ³',13,10
         db        'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',13,10
         db        '³ Pri  testu celistvosti skupiny disket archivu vkladejte postupne ³',13,10
         db        '³ nejdrive  paritni disketu a potom vsechny ostatni diskety, ktere ³',13,10
         db        '³ jsou  zabezpeceny touto paritni disketou. Timto testem se overi, ³',13,10
         db        '³ zda  paritni  disketa  souhlasi  s  prirazenou skupinou archivu. ³',13,10
         db        '³ Pokud  vlozite  omylem  jinou  disketu  (nebo  dvakrat stejnou), ³',13,10
         db        '³ vyradite  ji  jejim  opetovnym vlozenim. Po vlozeni vsech disket ³',13,10
         db        '³ skupiny  archivu  i  s paritni disketou zadejte povel "(K)onec". ³',13,10
         db        '³ Udaj poctu procent za povelem udava zabezpecenou cast dat.       ³',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
TstVTxt0 label     byte

;TstVMnu2 db        4
;         db        'D',27
;         db        'K',36
;         db        'M',52
;         db        'P',65
;
;TstVTxt2 dw        TstVTx20-TstVTxt2-2
;         db        13,'Vlozte disketu do '
;DiskChrA db        'A: ... (D)alsi, (K)onec ('
;DiskUsp  db        '  0%), (M)echanika, (P)reruseni'
;TstVTx20 label     byte
;
;TstV3Txt dw        TstV3Tx0-TstV3Txt-2
;         db        'Skupina archivu je zabezpecena paritni disketou na 100%.',13,10
;TstV3Tx0 label     byte
;
;TstV4Txt dw        TstV4Tx0-TstV4Txt-2
;         db        'Paritni disketa NEZABEZPECUJE testovanou skupinou archivu.',13,10
;TstV4Tx0 label     byte
;

; ------ verifikace diskety

VerfTxt  dw        VerfTxt0-VerfTxt-2
         db        'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '³                       TEST citelnosti diskety                     ³',13,10
         db        'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',13,10
         db        '³ Vkladejte diskety, ktere chcete overit na citelnost. Pri nalezeni ³',13,10
         db        '³ chyby cteni se zobrazi chybove hlaseni. Na zaver testu se zobrazi ³',13,10
         db        '³ tez   kontrolni  soucet  diskety  a  identifikacni  kod  diskety. ³',13,10
         db        '³ Poznacte  si  tyto  udaje  na  stitek  diskety  pro jeji pozdejsi ³',13,10
         db        '³ kontrolu  a  identifikaci.  Timto zpusobem je mozne kontrolovat a ³',13,10
         db        '³ identifikovat tez paritni diskety.                                ³',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
VerfTxt0 label     byte

; ------ identifika‡n¡ k¢d diskety

IdntTxt  dw        IdntTxt0-IdntTxt-2
         db        'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '³                      IDENTIFIKACNI kod diskety                    ³',13,10
         db        'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',13,10
         db        '³ Identifikacni  kod  diskety  slouzi k rychle identifikaci diskety ³',13,10
         db        '³ napr.  pri  vyhledavani diskety, pri kontrole celistvosti skupiny ³',13,10
         db        '³ disket  nebo  pri pouzivani katalogu disket. Identifikacni kod je ³',13,10
         db        '³ vytvoren  jako kontrolni soucet stopy 0 na strane 0 diskety. Neni ³',13,10
         db        '³ potreba  provadet kontrolni soucet cele diskety, pricemz vzajemne ³',13,10
         db        '³ rozpoznani  disket  je  v  praxi postacujici. Proto se doporucuje ³',13,10
         db        '³ poznacit si na disketu kontrolni soucet i identifikacni kod.      ³',13,10
         db        '³                                                                   ³',13,10
         db        '³ Pozn.: pro zrychleni operace se mechanika mezi disketami nevypina ³',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
IdntTxt0 label     byte

;IdntMnu1 db        3
;         db        'D',36
;         db        'M',45
;         db        'P',58
;
;IdntTxt1 dw        IdntTx10-IdntTxt1-2
;         db        13,'Vlozte disketu do '
;DiskChr3 db        'A: a zvolte ... (D)alsi, (M)echanika, (P)reruseni'
;IdntTx10 label     byte

IdntTxt2 dw        IdntTx20-IdntTxt2-2
IdntTx21 db        '  1 ... '
DiskChr6 db        'A:'
IdntTx22 db        '           '
         db        ' ('
DFormT1  db        '360 KB) ... identifikacni kod='
EDCITxt2 db        'FFFF',13,10
IdntTx20 label     byte

; ------ hl ¨en¡ o inicializaci parametr– diskety

InitTxt  dw        InitTxt0-InitTxt-2
         db        13,'- nacitam parametry diskety',13
InitTxt0 label     byte

; ------ hl ¨en¡ o na‡¡t n¡ diskety

CtuTxt   dw        CtuTxt0-CtuTxt-2
         db        13,'- ctu disketu  '
DiskChr3 db        'A:'
CtuTxt1  db        '           '
         db        ' ('
DFormT2  db        '360 KB, kod='
CtuTxt4  db        'FFFF) .... VALEC '
CtuTxt2  db        '00, STRANA '
CtuTxt3  db        '0',13
CtuTxt0  label     byte

; ------ hl ¨en¡ o z pisu diskety

ZapTxt   dw        ZapTxt0-ZapTxt-2
         db        13,'- zapisuji  '
DiskChr4 db        'A:'
ZapTxt1  db        '           '
         db        ' ('
DFormT3  db        '360 KB, kod='
ZapTxt4  db        'FFFF) .... VALEC '
ZapTxt2  db        '00, STRANA '
ZapTxt3  db        '0',13
ZapTxt0  label     byte

; ------ zobrazen¡ parametr– diskety

NactTxt  dw        NactTxt0-NactTxt-2
NactTxt2 db        '  1 ... '
DiskChr5 db        'A:'
NactTxt1 db        '           '
         db        ' ('
DFormT4  db        '360 KB) .... CRC='
EDCTxt   db        'FFFF, identifikacni kod='
EDCITxt3 db        'FFFF',13,10
NactTxt0 label     byte

ParTxt   db        '[-paritni-]'
NoNamTxt db        'NO NAME    '

; ------ nekompatibiln¡ form t diskety

FormTxtM db        2
         db        'D',42
         db        'P',51
         dw        FormTxt0-$-2
         db        13
         db        'CHYBA - nekompatibilni format diskety:  (D)alsi, (P)rerusit'
FormTxt0 label     byte

;; ------ form t diskety nen¡ shodn˜
;
;FrmSTxtM db        2
;         db        'O',30
;         db        'P',52
;
;FrmSTxt  dw        FrmSTxt0-FrmSTxt-2
;         db        13
;         db        'Format diskety neni shodny: (O)pakovat, (P)rerusit'
;FrmSTxt0 label     byte

; ------ chyba ‡ten¡ BOOT sektoru diskety

ErrBMnuM db        3
         db        'O',37
         db        'D',49
         db        'P',57
         dw        ErrBMnu0-$-2
         db        13
         db        'CHYBA cteni BOOT sektoru diskety:  (O)pakovat, (D)ale, (P)rerusit'
ErrBMnu0 label     byte

;; ------ chyba ‡ten¡
;
;ErrRTxtM db        3
;         db        'O',46
;         db        'D',58
;         db        'P',66
;
;ErrRTxt  dw        ErrRTxt0-ErrRTxt-2
;         db        13
;ErrRTxt1 db        'CHYBA cteni (VALEC 00/STRANA 0/SEKTOR 00):  (O)pakovat, (D)ale, (P)rerusit'
;ErrRTxt0 label     byte
;
;; ------ chyba z pisu - kr tk˜
;
;Er2WMnu  db        4
;         db        'O',37
;         db        'D',49
;         db        'S',57
;         db        'P',68
;
;Er2WTxt  dw        Er2WTxt0-Er2WTxt-2
;         db        13
;Er2WTxt1 db        'CHYBA zapisu (VALEC 00/STRANA 0):  (O)pakovat, (D)ale, (S)ektory, (P)rerusit'
;Er2WTxt0 label     byte
;
;; ------ chyba z pisu
;
;ErrWMnu  db        3
;         db        'O',47
;         db        'D',59
;         db        'P',67
;
;ErrWTxt  dw        ErrWTxt0-ErrWTxt-2
;         db        13
;ErrWTxt1 db        'CHYBA zapisu (VALEC 00/STRANA 0/SEKTOR 00):  (O)pakovat, (D)ale, (P)rerusit'
;ErrWTxt0 label     byte

; ------ v mechanice nen¡ disketa

ErrTMnu  db        2
         db        'O',33
         db        'P',45
         dw        ErrTMnu0-$-2
         db        13
         db        'V mechanice '
DiskChrT db        'A: neni disketa !  (O)pakovat, (P)rerusit'
ErrTMnu0 label     byte

; ------ disketa chr nˆna proti z pisu

ErrROMnu db        2
         db        'O',35
         db        'P',47
         dw        ErrROMn0-$-2
         db        13
         db        'Disketa chranena proti zapisu !  (O)pakovat, (P)rerusit'
ErrROMn0 label     byte

;; ------ hl ¨en¡ pro p©echodn˜ soubor
;
;ErrOTxt  dw        ErrOTxt0-ErrOTxt-2
;         db        'CHYBA - nelze vytvorit prechodny soubor !',13,10
;ErrOTxt0 label     byte
;
;ErrTRTxt dw        ErrTRTx0-ErrTRTxt-2
;         db        'CHYBA cteni z prechodneho souboru !',13,10
;ErrTRTx0 label     byte
;
;ErrORTxt dw        ErrTRTx0-ErrTRTxt-2
;         db        'CHYBA cteni ze souboru paritni diskety !',13,10
;ErrORTx0 label     byte
;
;ErrTWTxt dw        ErrTWTx0-ErrTWTxt-2
;         db        'CHYBA zapisu do prechodneho souboru !',13,10
;ErrTWTx0 label     byte
;
;ErrTWDTx dw        ErrTWDT0-ErrTWDTx-2
;         db        'CHYBA zapisu do prechodneho souboru - nedostatek mista na disku !',13,10
;ErrTWDT0 label     byte
;
;ErrOWTxt dw        ErrTWTx0-ErrTWTxt-2
;         db        'CHYBA zapisu do souboru paritni diskety !',13,10
;ErrOWTx0 label     byte

MazTTxt  dw        80                       ; text pro vymaz n¡ © dku
         db        13
MazTTxt1 db        78 dup(" "), 13          ; - t‚‘ jako pr zdn  jmenovka

; ------ tabulky (zachovat sudou adresu !)

         EVEN                               ; zarovn n¡ kv–li z sobn¡ku
Old1E    dd        ?                        ; p–vodn¡ adresa INT 1Eh

Tab1E    label     byte                     ; tabulka INT 1Eh
         db        ?                        ; 0: krokov n¡ motoru
         db        ?                        ; 1: spu¨tˆn¡ p©¡tlaku hlavy
MotorOff db        ?                        ; 2: ‡as pro vypnut¡ motoru
SektSize db        ?                        ; 3: velikost sektoru
LastSekt db        ?                        ; 4: posledn¡ sektor na stopˆ
         db        ?                        ; 5: mezisektorov  mezera ‡ten¡
         db        ?                        ; 6: d‚lka p©en ¨en˜ch dat
         db        ?                        ; 7: mezisektorov  mezera form t.
         db        ?                        ; 8: pln¡c¡ znak form tov n¡
         db        ?                        ; 9: ‡as pro ust len¡ hlav
         db        ?                        ; 10: ‡as pro spu¨tˆn¡ motoru
LastTrck db        ?                        ; (11: posledn¡ stopa)
         db        ?                        ; (12: p©enosov  rychlost)
         db        ?                        ;  ... zarovn n¡ na sudou adresu
Tab1E0   label     byte

;TrckMap  db        (MAXSEKT+1) AND (NOT 1) dup(?) ; mapa sektor– stopy (0=OK)

;ErrMap   db        ((MAXTRACK*MAXSEKT*MAXSIDE+16)/8) AND (NOT 1) dup(?) ; mapa vadn˜ch sektor–
;ErrMap0  label     byte

;RepFile  db        128 dup(?)               ; soubor hl ¨en¡
;OutpFile db        128 dup(?)               ; jm‚no v˜stupn¡ho souboru
;TempFilR db        128 dup(?)               ; p©echodn˜ soubor - ‡ten¡ (i z pis)
;TempFilW db        128 dup(?)               ; p©echodn˜ soubor - z pis

Soubor   db        128 dup(?)               ; zadan˜ soubor pro ‡ten¡ nebo z pis

         dw        200h dup(?)              ; z sobn¡k
Zasobnik label     word                     ; konec z sobn¡ku

Code     ENDS
         END       Start

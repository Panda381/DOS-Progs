Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

MAXTRACK EQU       180                      ; maxim ln¡ poŸet stop
MAXSEKT  EQU       48                       ; maxim ln¡ poŸet sektor… na stopu
MAXSIDE  EQU       2                        ; maxim ln¡ poŸet stran
; Pozor, aby buffer pro 1 stopu (MAXSEKT*512) nedos hl 32 KB !

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

; ------ inicializace programu

Start:   cmp       byte ptr ds:[80h],0
         je        Start1
         call      TempInit                 ; inicializace pýechodn‚ho souboru
Start1:  call      Inst1E                   ; instalace 1Eh
         call      DIns1E                   ; odinstalov n¡ 1Eh

; ------ rozbor pý¡kazov‚ho ý dku

         call      Rozbor                   ; rozbor pý¡kazov‚ho ý dku
         pushf
         push      si
         mov       si,offset UvTxt          ; £vodn¡ text
         call      StdOutT                  ; zobrazen¡ £vodn¡ho textu
         pop       si
         popf
         jnc       Start2                   ; parametry zad ny OK

; ------ chyba - zobrazen¡ n povØdy

         mov       si,offset Help2Txt
         call      RepOut
         mov       si,offset HelpTxt        ; text n povØdy
         jmp       short Chyba1

Prerus:  call      MazText
         mov       si,offset PrerTxt
         call      RepOut
         jmp       short INT23

Chyba:   call      MazText                  ; vymaz n¡ textu
         call      RepOut
Chyba1:  call      StdOut                   ; zobrazen¡ chybov‚ho textu

INT23:   call      DIns1E                   ; odinstalov n¡ INT 1Eh
         call      TempClos                 ; uzavýen¡ pýechodn‚ho souboru
         mov       ax,4c01h
         int       21h

; ------ pýedefinov n¡ z sobn¡ku

Start2:  mov       si,offset MemTxt         ; text - chyba pamØti
         cmp       sp,offset Zasobnik       ; kontrola konce z sobn¡ku
         jb        Chyba                    ; chyba pamØti
         mov       sp,offset Zasobnik       ; pýedefinov n¡ ukazatele z sobn¡ku

; ------ zmençen¡ bloku programu

         push      cs
         pop       es                       ; ES <- segment PSP
         mov       bx,(offset(Zasobnik-Start)+10fh)/16
         mov       ah,4ah
         int       21h                      ; zmençen¡ bloku programu
         jc        Chyba                    ; nØjak  chyba

; ------ vytvoýen¡ datov‚ho bloku

         mov       bx,-1
         mov       ah,48h
         int       21h                      ; dotaz na maxim ln¡ velikost bloku
         mov       ah,48h
         int       21h                      ; pýidØlen¡ maxim ln¡ho bloku
         jc        Chyba                    ; nØjak  chyba

; ------ kontrola velikosti datov‚ho bloku

         cmp       bx,4*(MAXSEKT*512/16)+ 4*512/16 ; minim ln¡ velikost bufferu
         jb        Chyba                    ; m lo pamØti
         mov       ds:[BuffBeg],ax          ; adresa bufferu
         add       bx,ax                    ; adresa konce bufferu

; ------ stanoven¡ adresy bufferu pracovn¡ stopy

         mov       ds:[BuffDisk],ax         ; mo§n  adresa bufferu
         and       ah,0fh                   ; offset v segmentu 64 KB
         add       ax,MAXSEKT*512/16        ; zvìçen¡ adresy bufferu
         test      ah,0f0h                  ; je pýeteŸen¡ 64 KB ?
         jz        Start22                  ; nen¡ pýeteŸen¡ 64 KB
         add       word ptr ds:[BuffDisk],MAXSEKT*512/16 ; jin  adresa bufferu

; ------ stanoven¡ adresy bufferu verifikovan‚ stopy

Start22: mov       ax,ds:[BuffDisk]         ; adresa bufferu pracovn¡ stopy
         add       ax,MAXSEKT*512/16        ; adresa bufferu verifikovan‚ stopy
         mov       ds:[BuffDskV],ax         ; mo§n  adresa bufferu
         and       ah,0fh                   ; offset v segmentu 64 KB
         add       ax,MAXSEKT*512/16        ; zvìçen¡ adresy bufferu
         test      ah,0f0h                  ; je pýeteŸen¡ 64 KB ?
         jz        Start24                  ; nen¡ pýeteŸen¡ 64 KB
         add       word ptr ds:[BuffDskV],MAXSEKT*512/16 ; jin  adresa bufferu

; ------ adresa datov‚ho bufferu

Start24: mov       ax,ds:[BuffDskV]         ; adresa diskov‚ho bufferu
         add       ax,MAXSEKT*512/16        ; adresa datov‚ho bufferu
         mov       ds:[BuffDat],ax          ; adresa datov‚ho bufferu

; ------ maxim ln¡ poŸet sektor… v bufferu

         sub       bx,ax                    ; velikost zbytku bufferu
         mov       cl,5                     ; poŸet rotac¡
         shr       bx,cl                    ; poŸet sektor…
         mov       ds:[BuffMax],bx          ; maxim ln¡ poŸet sektor… v bufferu

; ------ pýedefinov n¡ obsluhy INT 23h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h                      ; definice adresy INT 23h

; ------ nulov n¡ tabulky chyb

         call      ResDisk                  ; resetov n¡ diskov‚ho syst‚mu
         push      ds
         pop       es                       ; ES <- datovì segment
         mov       di,offset ErrMap
         mov       cx,offset(ErrMap0-ErrMap)
         xor       ax,ax
         cld
         rep       stosb                    ; vymaz n¡ tabulky

; ------ funkce vygenerov n¡ paritn¡ diskety

         test      byte ptr ds:[Operace],bit0 ; je generov n¡ diskety ?
         jz        Start3                   ; nen¡ generov n¡ diskety
         call      Gener                    ; generov n¡ paritn¡ diskety
         jmp       short Start9

; ------ funkce obnoven¡ poçkozen‚ diskety

Start3:  test      byte ptr ds:[Operace],bit1 ; je obnoven¡ poçkozen‚ diskety ?
         jz        Start4
         call      Obnov                    ; obnoven¡ vadn‚ diskety
         jmp       short Start9

; ------ funkce testu vçech disket archivu

Start4:  test      byte ptr ds:[Operace],bit2 ; je test vçech disket ?
         jz        Start5
         call      TestV                    ; test vçech disket archivu
         jmp       short Start9

; ------ funkce testu jedn‚ diskety archivu

Start5:  test      byte ptr ds:[Operace],bit3 ; je test jedn‚ diskety ?
         jz        Start6
         call      Test1                    ; test jedn‚ diskety
         jmp       short Start9

; ------ funkce modifikace paritn¡ diskety

Start6:  test      byte ptr ds:[Operace],bit4 ; je modifikace paritn¡ diskety ?
         jz        Start7
         call      Modif                    ; modifikace diskety
         jmp       short Start9

; ------ funkce identifikaŸn¡ho k¢du diskety

Start7:  test      byte ptr ds:[Operace],bit5 ; idnentifikaŸn¡ k¢d diskety ?
         jz        Start8
         call      Ident                    ; idnetifikaŸn¡ k¢d diskety
;         jmp       short Start9

Start8:

; ------ ý dnì konec programu

Start9:  call      DIns1E                   ; odinstalov n¡ INT 1Eh
         call      TempClos                 ; uzavýen¡ pýechodn‚ho souboru
         mov       ax,4c00h
         int       21h

; *****************************************************************************
;
;                     Funkce generov n¡ paritn¡ diskety
;
; *****************************************************************************
;þ
Gener    PROC      NEAR

; ------ zobrazen¡ n povØdy

         mov       si,offset GenTxt
         call      StdOutT                  ; zobrazen¡ vìzvy k vlo§en¡ diskety

; ------ potvrzen¡ operace

Gener1:  mov       si,offset GenTxt1
         mov       di,offset GenMnu1
         call      Menu                     ; volba dalç¡ operace
         cmp       al,"D"
         je        Gener2
         call      XchgDsk                  ; vìmØna disku
         jnc       Gener1
Gener12: jmp       Prerus

; ------ pýihl çen¡ diskety

Gener2:  call      TempOpen                 ; vytvoýen¡ pýechodn‚ho souboru
         test      byte ptr ds:[Operace],bit1+bit4 ; je paritn¡ disketa ?
         jz        Gener22
         or        byte ptr ds:[Param],bit2 ; urŸen  paritn¡ disketa
Gener22: call      ReadBoot                 ; inicializace diskety
         jc        Gener1                   ; opakov n¡ operace
         call      InitDisk                 ; inicializace diskovìch parametr…

; ------ prvn¡ disketa je paritn¡, je-li modifikace nebo obnoven¡

         test      byte ptr ds:[Operace],bit1+bit4 ; je to paritn¡ disketa ?
         jz        Gener3                   ; nen¡
         or        byte ptr ds:[Param],bit4+bit2 ; je paritn¡ disketa
         call      VolParit                 ; n vØçt¡ pro paritn¡ disketu

; ------ naŸten¡ diskety s operac¡ XOR

Gener3:  call      CtiDisk                  ; naŸten¡ diskety s XOR
         jnc       Gener32                  ; nen¡ pýeruçen¡
         test      byte ptr ds:[Param],bit2 ; je paritn¡ disketa ?
         jnz       Gener1                   ; je paritn¡ disketa
Gener32: and       byte ptr ds:[Param],not bit2 ; nen¡ urŸen  paritn¡ disketa

; ------ vìzva k vlo§en¡ dalç¡ diskety

Gener4:  mov       si,offset GenTxt2
         mov       di,offset GenMnu2
         call      Menu                     ; volba dalç¡ operace
         call      XchgDsk                  ; vìmØna diskety
         jnc       Gener4
         cmp       al,"Z"
         je        Gener6                   ; konec
         cmp       al,"D"
         jne       Gener12

; ------ dalç¡ disketa - test shodnosti parametr… diskety

Gener5:  call      ReadBoot
         jc        Gener4                   ; pýeruçen¡ operace
         call      CompDisk                 ; porovn n¡ parametr… disku
         jnc       Gener3                   ; naŸten¡ dalç¡ diskety

; ------ disketa nen¡ shodn 

         mov       si,offset FrmSTxt
         mov       di,offset FrmSTxtM
         call      Menu
         jc        Gener4                   ; pýeruçen¡
         cmp       al,"O"
         je        Gener5                   ; opakov n¡
         jmp       short Gener4             ; pýeruçen¡
;         cmp       al,"N"
;         je        Gener4                   ; n vrat
;Gener14: jmp       short Gener12            ; pýeruçen¡

; ------ test, zda byla chyba dat pýi obnoven¡

Gener6:  test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
         jz        Gener609                 ; nen¡ obnoven¡ diskety
         push      ds
         pop       es
         mov       di,offset ErrMap         ; mapa chyb
         mov       cx,offset ErrMap0-ErrMap ; velikost mapy
         xor       ax,ax
         cld
         repe      scasb                    ; test, zda byla chyba
         je        Gener609                 ; nebyla § dn  chyba

; ------ vìzva k vlo§en¡ opravovan‚ diskety

         mov       si,offset OprvTxt
         mov       di,offset OprvMnu
         call      Menu                     ; obsluha menu
         cmp       al,"Z"
         je        Gener609                 ; z pis
         cmp       al,"D"
         jne       Gener4                   ; nen¡ d le - pýeruçen¡
         call      ObnvOld                  ; obnoven¡ z p…vodn¡ diskety

; ------ jsou ji§ vçechny diskety - vìzva k vlo§en¡ pr zdn‚ diskety

Gener609:mov       si,offset VystTxt
         mov       di,offset VystMnu
         test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
         jnz       Gener60                  ; je obnoven¡ diskety
         mov       si,offset PartTxt
         mov       di,offset PartMnu
Gener60: call      Menu                     ; volba
         jc        Gener622                 ; n vrat menu
         call      XchgDsk                  ; vìmØna diskety
         jnc       Gener609
         cmp       al,"N"
         je        Gener622                 ; n vrat menu
         cmp       al,"Z"
         jne       Gener622                 ; nen¡ z pis - je pýeruçen¡

; ------ inicializace paritn¡ diskety

Gener61: test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
         jnz       Gener611                 ; je obnoven¡ diskety
         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa v souboru ?
         jz        Gener611                 ; nen¡ disketa v souboru
         or        byte ptr ds:[Param],bit4 ; je paritn¡ disketa
         call      VolParit
         call      ZapOutp                  ; z pis vìstupn¡ho souboru
         jmp       short Gener66

Gener611:call      ReadBoot                 ; naŸten¡ BOOT sektoru
         call      CompDisk                 ; porovn n¡ parametr… disku
         jnc       Gener62                  ; naŸten¡ dalç¡ diskety

; ------ disketa nen¡ shodn 

         mov       si,offset FrmSTxt
         mov       di,offset FrmSTxtM
         call      Menu
         jc        Gener622                 ; pýeruçen¡
         cmp       al,"O"
         je        Gener61                  ; opakov n¡
;         cmp       al,"N"
;         jne       Gener144                 ; pýeruçen¡
Gener622:jmp       Gener4                   ; n vrat

; ------ korekce jmenovky

Gener62: test      byte ptr ds:[Operace],bit1 ; je obnoven¡ diskety ?
         jnz       Gener63                  ; je obnoven¡ diskety
         or        byte ptr ds:[Param],bit4 ; je paritn¡ disketa
         call      VolParit                 ; n vØçt¡ pro paritn¡ disketu
         jmp       short Gener64

Gener63: call      VolObnov                 ; korekce jmenovky pýi obnoven¡

; ------ z pis diskety

Gener64: call      ZapDisk                  ; z pis paritn¡ diskety
         call      TstBreak                 ; test pýeruçen¡
         jc        Gener622

; ------ hl çen¡ o z pisu diskety

Gener66: test      byte ptr ds:[Operace],bit1 ; je obnoven¡ ?
         jnz       Gener7                   ; je obnoven¡ - nen¡ hl çen¡
         test      byte ptr ds:[Param],bit0 ; paritn¡ disketa v souboru ?
         jnz       Gener7
         mov       si,offset ParitTxt
         call      StdOutT                  ; zobrazen¡ hl çen¡
Gener7:  ret

Gener    ENDP

; -----------------------------------------------------------------------------
;        jmenovka pro paritn¡ disketu
; -----------------------------------------------------------------------------

VolParit PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je paritn¡ disketa ?
         jz        VolPari9                 ; nen¡ paritn¡ disketa

         push      bx
         push      es

         push      ds
         pop       es                       ; ES <- datovì segment
         mov       bx,offset ParTxt
         call      CopyLab                  ; kopie jmenovky do buffer…

         pop       es
         pop       bx

VolPari9:ret

VolParit ENDP

; *****************************************************************************
;
;                       Funkce obnoven¡ vadn‚ diskety
;
; *****************************************************************************
;þ
Obnov    PROC      NEAR

; ------ zobrazen¡ £vodn¡ vìzvy

         mov       si,offset ObnTxt
         call      StdOutT                  ; zobrazen¡ vìzvy k vlo§en¡ diskety

         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa ?
         jz        Obnov1                   ; nen¡
         call      TempOpen                 ; vytvoýen¡ pýechodn‚ho souboru
         cmp       word ptr ds:[OutpIdnt],0 ; je otevýen soubor ?
         jne       Obnov2                   ; soubor je otevýen OK

; ------ potvrzen¡ operace

Obnov1:  mov       si,offset ObnTxt1
         mov       di,offset ObnMnu1
         call      Menu                     ; volba dalç¡ operace
         cmp       al,"D"
         je        Obnov2
         call      XchgDsk                  ; vìmØna disku
         jnc       Obnov1
Obnov12: jmp       Prerus

Obnov2:  jmp       Gener2

Obnov    ENDP

; -----------------------------------------------------------------------------
;        korekce jmenovky pýi obnoven¡ (neuchov v  registry)
; -----------------------------------------------------------------------------

VolObnov PROC      NEAR

; ------ inicializaŸn¡ vymaz n¡ jmenovky

         push      ds
         pop       es                       ; ES <- datovì segment
         mov       bx,offset MazTTxt1       ; sam‚ mezery
         call      CopyLab                  ; kopie do buffer…

; ------ inicializace jmenovky disku

         mov       es,ds:[BuffDat]          ; zaŸ tek datov‚ho bufferu
         test      byte ptr ds:[Param],bit3 ; je nekompatibiln¡ BOOT ?
         jnz       VolObn3                  ; nekompatibiln¡ BOOT
         cmp       byte ptr es:[10h],2      ; je polo§ka tabulek FAT ?
         jb        VolObn3                  ; neplatnì BOOT
         cmp       byte ptr es:[bx+26h-2bh],29h ; je to rozç¡ýenì sektor ?
         jne       VolObn4
         mov       bx,2bh                   ; jmenovka pro DOS 4
VolObn1: call      TestLab                  ; test jmenovky diskety ES:BX
         jc        VolObn3                  ; jmenovka neplat¡, asi paritn¡ disk

; ------ jmenovka NO NAME je neplatn 

         mov       di,bx                    ; offset adresy jmenovky
         mov       si,offset NoNamTxt       ; jmenovka "NO NAME"
         mov       cx,11
         cld
         repe      cmpsb                    ; je to jmenovka NO NAME ?
         je        VolObn3                  ; je jmenovka NO NAME
         call      CopyLab                  ; kopie jmenovky disku ES:BX
VolObn3: ret

; ------ zjiçtØn¡ poŸtu sektor… ROOT

VolObn4: mov       bp,es:[11h]              ; poŸet polo§ek ROOT
         shr       bp,1
         shr       bp,1
         shr       bp,1
         shr       bp,1                     ; poŸet sektor… ROOT
         jz        VolObn3                  ; nen¡ platnì ROOT

; ------ zjiçtØn¡ poŸ teŸn¡ho sektoru ROOT

         mov       ax,es:[16h]              ; poŸet sektor… jedn‚ tabulky FAT
         shl       ax,1                     ; poŸet sektor… na obØ tabulky FAT
         jc        VolObn3                  ; chyba
         add       ax,es:[0eh]              ; pýiŸten¡ rezervovanìch sektor…
         jc        VolObn3
         xchg      ax,di                    ; DI <- Ÿ¡slo poŸ teŸn¡ho sektoru

; ------ vìpoŸet adresy poŸ tku ROOT

         mov       ax,512/16                ; poŸet odstavc… na sektor
         mul       di                       ; offset
         add       ax,ds:[BuffDat]          ; adresa sektoru
         xchg      ax,dx                    ; DX <- adresa sektoru

; ------ test, zda je platnì sektor

VolObn5: cmp       di,ds:[BuffMax]          ; je to platnì sektor ?
         jae       VolObn3                  ; nen¡ to platnì sektor

; ------ prohled n¡ jednoho sektoru

         mov       es,dx                    ; adresa sektoru
         xor       bx,bx                    ; offset
         mov       cx,16                    ; poŸet polo§ek na sektor
VolObn6: cmp       byte ptr es:[bx],0
         je        VolObn3                  ; konec adres ýe
         cmp       byte ptr es:[bx],0e5h
         je        VolObn7                  ; zruçen  polo§ka
         test      byte ptr es:[bx+0bh],bit3 ; je to n vØçt¡ disku ?
         jnz       VolObn1                  ; n vØçt¡ disku nalezeno OK
VolObn7: add       bx,32                    ; adresa dalç¡ polo§ky
         loop      VolObn6                  ; test dalç¡ polo§ky

; ------ zvìçen¡ adresy

         inc       di                       ; zvìçen¡ Ÿ¡sla sektoru
         add       dx,512/16                ; zvìçen¡ adresy v pamØti
         jmp       short VolObn5

VolObnov ENDP

; -----------------------------------------------------------------------------
;        obnoven¡ dat z p…vodn¡ vadn‚ diskety (neuchov v  registry !)
; -----------------------------------------------------------------------------

ObnvOld  PROC      NEAR

         or        byte ptr ds:[Param],bit1  ; je obnovovan  disketa

; ------ pýihl çen¡ diskety

ObnvOld1:call      ReadBoot
         call      CompDisk                 ; porovn n¡ parametr… disku
         jnc       ObnvOl14                 ; disketa je OK

; ------ disketa nen¡ shodn  (neuchov vat nic v z sobn¡ku - vrac¡ se !)

         mov       si,offset FrmSTxt
         mov       di,offset FrmSTxtM
         call      Menu
         cmp       al,"O"
         je        ObnvOld1                 ; opakov n¡
         cmp       al,"P"
         je        ObnvOl12

         and       byte ptr ds:[Param],not bit1
         pop       ax                       ; zruçen¡ n vratov‚ adresy
         jmp       Gener4                   ; n vrat

ObnvOl12:jmp       Prerus                   ; pýeruçen¡

; ------ pý¡prava k operaci naŸten¡ disku

ObnvOl14:call      Inst1E                   ; instalace INT 1Eh

         mov       bp,offset ErrMap         ; mapa vadnìch sektor…

         mov       cl,1                     ; maska v mapØ
         mov       ch,0                     ; ukazatel Ÿ¡sla v lce
ObnvOld2:mov       dh,0                     ; ukazatel Ÿ¡sla strany

; ------ naŸten¡ jedn‚ stopy

ObnvOld3:call      ReadTrck                 ; naŸten¡ stopy

; ------ identifikaŸn¡ k¢d diskety

         mov       al,ch
         or        al,dh                    ; je stopa 0/strana 0 ?
         jnz       ObnvOld4                 ; nen¡ stopa 0/strana 0
         call      SumEDCI                  ; identifikaŸn¡ k¢d

; ------ pý¡prava k modifikaci sektor…

ObnvOld4:mov       al,ds:[NumSekt]          ; poŸet sektor… ve stopØ
         xor       si,si
ObnvOld5:test      byte ptr ds:[bp],cl      ; je sektor vadnì ?
         jz        ObnvOld6                 ; sektor nen¡ vadnì

; ------ obnoven¡ sektoru

         push      si
         push      cx
         push      ds

         xor       di,di
         mov       es,ds:[BuffUkaz]         ; ukazatel adresy
         mov       ds,ds:[BuffDisk]         ; segment naŸten‚ stopy
         mov       cx,512/2                 ; poŸet slov
         cld
         rep       movsw                    ; pýenos sektoru

         pop       ds
         pop       cx
         pop       si

; ------ pý¡prava pro dalç¡ sektor

ObnvOld6:shl       cl,1                     ; posun masky v mapØ
         jnc       ObnvOld7
         inc       bp                       ; zvìçen¡ ukazatele v mapØ
         mov       cl,1

ObnvOld7:add       si,512
         add       word ptr ds:[BuffUkaz],512/16 ; zvìçen¡ ukazatele v bufferu
         dec       word ptr ds:[BuffCit]    ; sn¡§en¡ Ÿ¡taŸe zbylìch sektor…
         jnz       ObnvOld9                 ; jsou dalç¡ sektory
         call      TempWrit                 ; z pis dat do souboru
         call      TempRead                 ; naŸten¡ dalç¡ho bloku dat
ObnvOld9:dec       al                       ; Ÿ¡taŸ sektor…
         jnz       ObnvOld5                 ; dalç¡ sektor

; ------ zvìçen¡ ukazatele Ÿ¡sla strany

         inc       dh                       ; zvìçen¡ Ÿ¡sla strany
         cmp       dh,ds:[NumStran]
         jb        ObnvOld3                 ; Ÿten¡ dalç¡ strany

; ------ zvìçen¡ ukazatele Ÿ¡sla stopy

         inc       ch                       ; zvìçen¡ Ÿ¡sla stopy
         cmp       ch,ds:[NumStop]
         jb        ObnvOld2                 ; Ÿten¡ dalç¡ stopy

; ------ ulo§en¡ souboru

         call      TempWrit                 ; z pis dat do souboru
         call      MazText
         call      DIns1E
         and       byte ptr ds:[Param],not bit1
         ret

ObnvOld  ENDP

; -----------------------------------------------------------------------------
;        test, zda je sektor CH/DH/CL v mapØ chyb (CY=je vadnì)
; -----------------------------------------------------------------------------

TestErrM PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      si

; ------ vìpoŸet absolutn¡ho sektoru

         mov       al,ch                    ; Ÿ¡slo v lce
         mul       byte ptr ds:[NumStran]   ; pýepoŸet na absolutn¡ stopu
         add       al,dh                    ; pýiŸten¡ strany
         mov       dh,0
         adc       ah,dh
         mov       dl,ds:[NumSekt]          ; poŸet sektor… na stopu
         mul       dx                       ; pýepoŸet na sektory
         dec       cx                       ; korekce Ÿ¡sla sektoru
         add       al,cl                    ; pýiŸten¡ Ÿ¡sla sektoru
         adc       ah,0

; ------ test sektoru v mapØ

         mov       cl,al                    ; Ÿ¡slo abs. sektoru
         and       cl,7                     ; offset v bajtu
         mov       ch,1                     ; maska
         shl       ch,cl                    ; rotace masky na pozici
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; offset bajtu
         xchg      ax,si
         test      ds:[si+ErrMap],ch        ; test bitu
         jz        TestErM2                 ; nen¡ chyba
         stc                                ; pý¡znak chyb

; ------ n vrat registr…

TestErM2:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

TestErrM ENDP

; *****************************************************************************
;
;                       Funkce modifikace paritn¡ diskety
;
; *****************************************************************************
;þ
Modif    PROC      NEAR

; ------ zobrazen¡ n povØdy

         mov       si,offset ModTxt
         call      StdOutT                  ; zobrazen¡ vìzvy k vlo§en¡ diskety

         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa ?
         jz        Modif1                   ; nen¡
         call      TempOpen                 ; vytvoýen¡ pýechodn‚ho souboru
         cmp       word ptr ds:[OutpIdnt],0 ; je otevýen soubor ?
         jne       Modif2                   ; soubor je otevýen OK

; ------ potvrzen¡ operace

Modif1:  mov       si,offset ObnTxt1
         mov       di,offset ObnMnu1
         call      Menu                     ; volba dalç¡ operace
         cmp       al,"D"
         je        Modif2
         call      XchgDsk                  ; vìmØna disku
         jnc       Modif1
Modif12: jmp       Prerus
Modif2:  jmp       Gener2

Modif    ENDP

; *****************************************************************************
;
;                     Funkce testu vçech disket archivu
;
; *****************************************************************************
;þ
TestV    PROC      NEAR

; ------ zobrazen¡ n povØdy

         mov       si,offset TstVTxt
         call      StdOutT                  ; zobrazen¡ vìzvy k vlo§en¡ diskety

         test      byte ptr ds:[Param],bit0 ; je paritn¡ disketa ?
         jz        TestV1                   ; nen¡
         call      TempOpen                 ; vytvoýen¡ pýechodn‚ho souboru
         cmp       word ptr ds:[OutpIdnt],0 ; je otevýen soubor ?
         jne       TestV23                  ; soubor je otevýen OK

; ------ potvrzen¡ operace

TestV1:  mov       si,offset ObnTxt1
         mov       di,offset ObnMnu1
         call      Menu
         call      XchgDsk
         jnc       TestV1
         cmp       al,"D"
         je        TestV22
TestV2:  jmp       Prerus                   ; konec

; ------ pýihl çen¡ diskety

TestV22: call      TempOpen                 ; vytvoýen¡ pýechodn‚ho souboru
TestV23: or        byte ptr ds:[Param],bit2
         call      ReadBoot                 ; inicializace diskety
         jc        TestV1                   ; pýeruçen¡
         call      InitDisk                 ; inicializace diskovìch parametr…
         or        byte ptr ds:[Param],bit4+bit2 ; je paritn¡ disketa
         call      VolParit                 ; n vØçt¡ pro paritn¡ disketu

; ------ naŸten¡ diskety s operac¡ XOR

TestV3:  mov       word ptr ds:[UspechS],0  ; £spØçnost obnoven¡ sektor…
         call      CtiDisk                  ; naŸten¡ diskety
         jnc       TestV31                  ; nen¡ pýeruçen¡
         test      byte ptr ds:[Param],bit2 ; je paritn¡ disketa ?
         jnz       TestV1                   ; je paritn¡ disketa
         jmp       short TestV4             ; dalç¡ disketa
TestV31: and       byte ptr ds:[Param],not bit2 ; nen¡ urŸen  paritn¡ disketa

; ------ dek¢dov n¡ Ÿ¡sla £spØçnosti

         xor       ax,ax
         cmp       word ptr ds:[NDisket],1
         jbe       TestV32
         mov       ax,ds:[UspechS]          ; poŸet £spØŸnìch sektor…
         mov       cx,100
         mul       cx                       ; poŸet sektor… * 2
         div       word ptr ds:[CelkSkt0]   ; £spØçnost
TestV32: push      ds
         pop       es
         mov       di,offset DiskUsp+2
         mov       word ptr ds:[di-2],"  "
         call      DekNum                   ; dek¢dov n¡ £spØçnosti

; ------ vìzva k vlo§en¡ dalç¡ diskety

TestV4:  mov       si,offset TstVTxt2
         mov       di,offset TstVMnu2
         call      Menu                     ; volba dalç¡ operace
         call      XchgDsk                  ; vìmØna diskety
         jnc       TestV4
         cmp       al,"K"
         je        TestV6                   ; konec
         cmp       al,"D"
         jne       TestV2

; ------ dalç¡ disketa - test shodnosti parametr… diskety

TestV5:  call      ReadBoot
         jc        TestV4                   ; pýeruçen¡
         call      CompDisk                 ; porovn n¡ parametr… disku
         jnc       TestV3                   ; naŸten¡ dalç¡ diskety

; ------ disketa nen¡ shodn 

         mov       si,offset FrmSTxt
         mov       di,offset FrmSTxtM
         call      Menu
         jc        TestV4                   ; pýeruçen¡
         cmp       al,"O"
         je        TestV5                   ; opakov n¡
;         cmp       al,"N"
;         je        TestV4                   ; n vrat
         jmp       short TestV4
;TestV52: jmp       short TestV2             ; pýeruçen¡

; ------ jsou ji§ vçechny diskety - test vìsledku testu

TestV6:  mov       si,offset TstV4Txt       ; chyba dat
         mov       ax,ds:[UspechS]
         cmp       ax,ds:[CelkSkt0]
         jb        TestV8
         mov       si,offset TstV3Txt
TestV8:  call      StdOut                   ; hl çen¡
         ret

TestV    ENDP

; *****************************************************************************
;
;                        Funkce testu jedn‚ diskety
;
; *****************************************************************************
;þ
Test1    PROC      NEAR

; ------ zobrazen¡ £vodn¡ vìzvy

         mov       si,offset Tst1Txt
         call      StdOutT                  ; zobrazen¡ vìzvy k vlo§en¡ diskety
Test11:  mov       si,offset IdntTxt1
         mov       di,offset IdntMnu1
         call      Menu
         cmp       al,"D"
         je        Test13
         call      XchgDsk                  ; zmØna mechaniky
         jnc       Test11                   ; byl povel "M"
         jmp       INT23

; ------ pýihl çen¡ diskety

Test13:  call      ReadBoot                 ; inicializace diskety
         call      InitDisk                 ; inicializace diskovìch parametr…
         call      VolParit                 ; korekce jmenovky pro paritn¡ disk

; ------ naŸten¡ diskety

         call      CtiDisk                  ; naŸten¡ disku
         jmp       short Test11

Test19:  ret

Test1    ENDP

; *****************************************************************************
;
;                        IdentifikaŸn¡ k¢d jedn‚ diskety
;
; *****************************************************************************
;þ
Ident    PROC      NEAR

; ------ zobrazen¡ £vodn¡ vìzvy

         mov       si,offset IdntTxt
         call      StdOutT                  ; zobrazen¡ vìzvy k vlo§en¡ diskety
Ident1:  mov       si,offset IdntTxt1
         mov       di,offset IdntMnu1
         call      Menu
         cmp       al,"D"
         je        Ident3
         call      XchgDsk                  ; zmØna mechaniky
         jnc       Ident1                   ; byl povel "M"
         jmp       INT23

; ------ inicializace diskety

Ident3:  call      ReadBoot                 ; inicializace diskety
         call      InitDisk                 ; inicializace diskovìch parametr…
         call      VolParit                 ; korekce jmenovky pro paritn¡ disk

; ------ naŸten¡ stopy

         mov       ch,0                     ; ukazatel Ÿ¡sla v lce
         mov       dh,0                     ; ukazatel Ÿ¡sla strany
         call      Inst1E                   ; instalace INT 1Eh
         call      ReadTrck                 ; naŸten¡ stopy
         call      DIns1E

; ------ identifikaŸn¡ k¢d diskety

         call      SumEDCI                  ; identifikaŸn¡ k¢d
         inc       word ptr ds:[NDisket]    ; zvìçen¡ Ÿ¡sla diskety
         call      DekNDisk                 ; dek¢dov n¡ Ÿ¡sla diskety
         mov       si,offset IdntTxt2       ; text
         call      StdOut0                  ; zobrazen¡ textu
         jmp       short Ident1             ; dalç¡ disketa

Ident    ENDP

; *****************************************************************************
;
;                       Obslu§n‚ procedury funkc¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;     naŸten¡ cel‚ diskety s funkc¡ XOR (neuchov v  registry !) (CY pýeruçen¡)
; -----------------------------------------------------------------------------

CtiDisk  PROC      NEAR

; ------ pý¡prava k operaci naŸten¡ disku

         call      Inst1E                   ; instalace INT 1Eh
         mov       ch,0                     ; ukazatel Ÿ¡sla v lce
CtiDisk2:mov       dh,0                     ; ukazatel Ÿ¡sla strany

; ------ naŸten¡ jedn‚ stopy

CtiDisk3:call      ReadTrck                 ; naŸten¡ stopy
         call      TstBreak
         jc        CtiDisk8                 ; pýeruçen¡
         call      SetEMap                  ; nastaven¡ mapy chyb

; ------ identifikaŸn¡ k¢d diskety

         mov       al,ch
         or        al,dh                    ; je stopa 0/strana 0 ?
         jnz       CtiDisk4                 ; nen¡ stopa 0/strana 0
         call      SumEDCI                  ; identifikaŸn¡ k¢d

; ------ kontroln¡ souŸet stopy

CtiDisk4:call      CheckSm0                 ; kontroln¡ souŸet stopy

; ------ proveden¡ operace XOR paritn¡ diskety s naŸtenìmi daty

         test      byte ptr ds:[Operace],bit3 ; je verifikace diskety ?
         jnz       CtiDisk5                 ; je verifikace

         xor       si,si                    ; ukazatel adresy
         mov       al,ds:[NumSekt]          ; poŸet sektor… na stopu
         call      XORSekt                  ; proveden¡ operace XOR

; ------ identifikaŸn¡ k¢d paritn¡ diskety

         mov       al,ch
         or        al,dh                    ; je stopa 0/strana 0 ?
         jnz       CtiDisk5                 ; nen¡ stopa 0/strana 0

         mov       es,ds:[BuffDat]          ; buffer stopy
         xor       bx,bx
         call      SetSekt                  ; nastaven¡ parametr… BOOT sektoru
         call      SumEDCP                  ; identifikaŸn¡ k¢d parit. diskety

; ------ zvìçen¡ ukazatele Ÿ¡sla strany

CtiDisk5:call      TestEsc                  ; test pýeruçen¡
         jc        CtiDisk8                 ; je pýeruçen¡ operace
         inc       dh                       ; zvìçen¡ Ÿ¡sla strany
         cmp       dh,ds:[NumStran]
         jb        CtiDisk3                 ; Ÿten¡ dalç¡ strany

; ------ zvìçen¡ ukazatele Ÿ¡sla stopy

         inc       ch                       ; zvìçen¡ Ÿ¡sla stopy
         cmp       ch,ds:[NumStop]
         jb        CtiDisk2                 ; Ÿten¡ dalç¡ stopy

CtiDisk8:call      TempWrit                 ; z pis dat do souboru
         call      MazText
         call      DIns1E

         call      TstBreak                 ; test pýeruçen¡ operace
         jc        CtiDisk9                 ; pýeruçen¡ operace

         call      TempXchg                 ; zaýazen¡ diskety
         inc       word ptr ds:[NDisket]    ; zvìçen¡ Ÿ¡sla diskety
         call      DekNDisk                 ; dek¢dov n¡ Ÿ¡sla diskety
         call      DispEDC                  ; zobrazen¡ kontroln¡ho souŸtu
         clc
CtiDisk9:ret

CtiDisk  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ mapy chyb podle chyb stopy CH/strana DH
; -----------------------------------------------------------------------------

SetEMap  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ vìpoŸet absolutn¡ho sektoru

         mov       al,ch                    ; stopa
         mul       byte ptr ds:[NumStran]   ; Ÿ¡slo stopy absolutnØ
         add       al,dh                    ; pýiŸten¡ Ÿ¡sla strany
         adc       ah,0
         mov       cl,ds:[NumSekt]          ; poŸet sektor… na stopu
         mov       ch,0
         mul       cx                       ; vìpoŸet absolutn¡ho sektoru

; ------ adresa v mapØ chyb

         mov       cl,al
         and       cl,7                     ; offset v bajtu
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; offset v mapØ
         add       ax,offset ErrMap         ; adresa v mapØ chyb
         xchg      ax,di                    ; DI <- ukazatel v mapØ chyb

; ------ pý¡prava k dek¢dov n¡ mapy chyb

         mov       si,offset TrckMap        ; mapa stopy
         mov       dl,ds:[NumSekt]          ; poŸet sektor… na stopu
         mov       ch,1                     ; maska
         shl       ch,cl                    ; rotace masky na pozici

; ------ nastaven¡ mapy

SetEMap2:cmp       byte ptr ds:[si],0       ; byla chyba ?
         je        SetEMap3                 ; nebyla chyba
         or        byte ptr ds:[di],ch      ; nastaven¡ pý¡znaku chyby
SetEMap3:inc       si
         shl       ch,1
         jnc       SetEMap4
         mov       ch,1
         inc       di
SetEMap4:dec       dl
         jnz       SetEMap2

; ------ n vrat registr…

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

SetEMap  ENDP

; -----------------------------------------------------------------------------
;        z pis cel‚ diskety (neuchov v  registry !) -> CY pýeruçen¡
; -----------------------------------------------------------------------------

ZapDisk  PROC      NEAR

; ------ pý¡prava k z pisu diskety

         call      Inst1E
         mov       ch,0                     ; ukazatel Ÿ¡sla v lce
ZapDisk2:mov       dh,0                     ; ukazatel Ÿ¡sla strany

; ------ naŸten¡ stopy z pýechodn‚ho souboru

ZapDisk3:call      ReadTTrc                 ; naŸten¡ stopy z pýech. bufferu
         mov       al,ch
         or        al,dh                    ; je prvn¡ stopa ?
         jnz       ZapDisk4                 ; nen¡ prvn¡ stopa

; ------ korekce pro prvn¡ stopu

         mov       es,ds:[BuffDisk]         ; buffer stopy
         xor       bx,bx
         call      SetSekt                  ; nastaven¡ parametr… BOOT sektoru
         call      SumEDCI                  ; identifikaŸn¡ k¢d
         call      SumEDCP                  ; k¢d paritn¡ diskety

; ------ kontroln¡ souŸet diskety

ZapDisk4:call      CheckSm0                 ; kontroln¡ souŸet stopy

; ------ z pis stopy na disketu

         call      WritTrck                 ; z pis stopy
         jc        ZapDisk8                 ; pýeruçen¡ operace
         call      TestEsc                  ; test pýeruçen¡
         jc        ZapDisk8                 ; je pýeruçen¡ operace

; ------ zvìçen¡ ukazatele Ÿ¡sla strany

         inc       dh                       ; zvìçen¡ Ÿ¡sla strany
         cmp       dh,ds:[NumStran]
         jb        ZapDisk3                 ; z pis dalç¡ strany

; ------ zvìçen¡ ukazatele Ÿ¡sla stopy

         inc       ch                       ; zvìçen¡ Ÿ¡sla stopy
         cmp       ch,ds:[NumStop]
         jb        ZapDisk2                 ; Ÿten¡ dalç¡ stopy

ZapDisk8:call      MazText
         call      DIns1E                   ; odinstalov n¡ INT 1Eh

; ------ zobrazen¡ informaŸn¡ho textu

         call      TstBreak
         jc        ZapDisk9                 ; pýeruçen¡
         inc       word ptr ds:[NDisket]    ; zvìçen¡ Ÿ¡sla diskety
         call      DekNDisk                 ; dek¢dov n¡ Ÿ¡sla diskety
         call      DispEDC                  ; zobrazen¡ kontroln¡ho souŸtu
         clc
ZapDisk9:ret

ZapDisk  ENDP

; -----------------------------------------------------------------------------
; operace XOR AL sektor… SI s bufferem (posouv  se ukazatel) DH=strana, CH=stopa
; -----------------------------------------------------------------------------

XORSekt  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ pý¡prava registr…

         mov       bl,dh                    ; strana
         mov       bh,ch                    ; stopa
         mov       dh,0
         mov       dl,al                    ; poŸet sektor…

; ------ proveden¡ operace XOR s jedn¡m sektorem

XORSekt2:push      ds
         cld
         xor       di,di
         mov       es,ds:[BuffUkaz]         ; ukazatel sektoru
         mov       ds,ds:[BuffDisk]         ; buffer stopy
         mov       cx,100h                  ; 256 slov
XORSekt3:lodsw                              ; naŸten¡ slova
         xor       es:[di],ax               ; XOR
         inc       di
         inc       di
         loop      XORSekt3                 ; dalç¡ slovo
         pop       ds

; ------ zjiçtØn¡, zda je sektor = 0

         test      byte ptr ds:[Operace],bit2 ; je test vçech disket ?
         jz        XORSekt4                 ; nen¡ test vçech disket

         xor       ax,ax
         or        bx,bx                    ; je BOOT stopa ?
         jnz       XORSkt32                 ; nen¡ BOOT stopa
         cmp       si,512+2                 ; je BOOT sektor ?
         ja        XORSkt32                 ; nen¡ BOOT sektor

         test      byte ptr ds:[Param],bit3 ; nekompatibiln¡ BOOT ?
         jnz       XORSkt32                 ; nekompatibiln¡ BOOT

         mov       es:[0bh],ax              ; poŸet bajt… na sektor
         mov       es:[18h],ax              ; poŸet sektor… na stopu
         mov       es:[1ah],ax              ; poŸet stran
         mov       es:[13h],ax              ; celkovì poŸet sektor…

XORSkt32:xor       di,di
         mov       ch,1                     ; 256 slov
         repe      scasw                    ; test, zda je 0
         jne       XORSekt4                 ; sektor nen¡ = 0
         inc       word ptr ds:[UspechS]    ; Ÿ¡taŸ £spØçnìch sektor…

; ------ posun ukazatele k dalç¡mu sektoru

XORSekt4:add       word ptr ds:[BuffUkaz],512/16 ; zvìçen¡ ukazatele v bufferu
         dec       word ptr ds:[BuffCit]    ; sn¡§en¡ Ÿ¡taŸe zbylìch sektor…
         jnz       XORSekt5                 ; jsou dalç¡ sektory
         call      TempWrit                 ; z pis dat do souboru
         call      TempRead                 ; naŸten¡ dalç¡ho bloku dat
XORSekt5:dec       dx                       ; Ÿ¡taŸ sektor…
         jnz       XORSekt2                 ; dalç¡ sektor

; ------ n vrat registr…

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

XORSekt  ENDP

; -----------------------------------------------------------------------------
;        inicializace diskovìch parametr…
; -----------------------------------------------------------------------------

InitDisk PROC      NEAR

; ------ £schova registr…

         push      ax

; ------ poŸet sektor… na stopu

         mov       al,ds:[NumSekt0]
         mov       ds:[NumSekt],al          ; poŸet sektor… na stopu
         mov       ds:[LastSekt],al         ; posledn¡ sektor na stopØ

; ------ poŸet stran disku

         mov       al,ds:[NumStrn0]
         mov       ds:[NumStran],al         ; poŸet stran disku

; ------ celkem sektor…

         mov       ax,ds:[CelkSkt0]
         mov       ds:[CelkSekt],ax         ; celkem sektor…

; ------ poŸet v lc… disku

         mov       al,ds:[NumStop0]
         mov       ds:[NumStop],al          ; poŸet stop

; ------ n vrat registr…

         pop       ax
         ret

InitDisk ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ parametr… diskety (CY=nen¡ shoda)
; -----------------------------------------------------------------------------

CompDisk PROC      NEAR

; ------ £schova registr…

         push      ax

; ------ poŸet sektor… na stopu

         mov       al,ds:[NumSekt0]
         cmp       al,ds:[NumSekt]          ; poŸet sektor… na stopu
         jne       CompDsk1

; ------ poŸet stran disku

         mov       al,ds:[NumStrn0]
         cmp       al,ds:[NumStran]         ; poŸet stran disku
         jne       CompDsk1

; ------ celkem sektor…

         mov       ax,ds:[CelkSkt0]
         cmp       ax,ds:[CelkSekt]         ; celkem sektor…
         je        CompDsk2

; ------ n vrat registr…

CompDsk1:stc                                ; pý¡znak neshody parametr…
CompDsk2:pop       ax
         ret

CompDisk ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ BOOT sektoru (CY=pýeruçen¡)
; -----------------------------------------------------------------------------
;þ
ReadBoot PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ instalace tabulky 1E

         call      Inst1E                   ; instalace INT 1Eh

; ------ zobrazen¡ hl çen¡ o naŸ¡t n¡ parametr… diskety

ReadBot1:mov       si,offset InitTxt
         call      StdErrA                  ; zobrazen¡ hl çen¡ o naŸ¡t n¡

; ------ naŸten¡ BOOT sektoru diskety

         xor       bx,bx                    ; offset bufferu
         mov       es,ds:[BuffDisk]         ; segment bufferu
         mov       cx,1                     ; stopa=0, sektor=1
         mov       dh,0                     ; strana=0
         mov       al,1                     ; poŸet sektor…
         call      ReadSekt                 ; naŸten¡ BOOT sektoru
         jnc       ReadBot3                 ; operace OK
         call      TstBreak                 ; test pýeruçen¡
         jnc       ReadBt12
         jmp       ReadBot8
;         jc        ReadBot8                 ; pýeruçen¡ operace

; ------ vynulov n¡ sektoru pýi chybØ

ReadBt12:call      MazText                  ; vymaz n¡ hl çen¡
         mov       al,0                     ; nulovac¡ bajt
         call      NulSekt                  ; nulov n¡ sektoru
         call      SetSekt                  ; nastaven¡ parametr… BOOT sektoru

; ------ pýi chybØ dotaz na dalç¡ operaci

         mov       si,offset ErrBTxt
         mov       di,offset ErrBTxtM
         call      Menu                     ; volba dalç¡ operace
         cmp       al,"O"
         je        ReadBot1                 ; opakov n¡ operace
         cmp       al,"D"
         je        ReadBt22                 ; d le, cbyba se ignoruje
ReadBot2:jmp       Prerus                   ; konec programu

; ------ kontrola platnosti parametr… sektoru

ReadBt22:call      StdErrO                  ; obnoven¡ aktu ln¡ho hl çen¡
ReadBot3:and       byte ptr ds:[Param],not bit3
         call      TestDisk                 ; test parametr… disku
         jnc       ReadBot4                 ; parametry diskety jsou OK

         or        byte ptr ds:[Param],bit3 ; nekompatibiln¡ BOOT

         mov       byte ptr ds:[NumSekt0],8 ; poŸet sektor… na stopu
         mov       byte ptr ds:[NumStrn0],1 ; poŸet stran disku
         mov       word ptr ds:[CelkSkt0],8*40 ; celkem sektor…
         mov       byte ptr ds:[NumStop0],40 ; poŸet stop

;         call      MazText                  ; vymaz n¡ hl çen¡
;         mov       si,offset FormTxt
;         mov       di,offset FormTxtM
;         call      Menu                     ; volba
;         cmp       al,"O"
;         je        ReadBot1                 ; opakov n¡
;         jmp       short ReadBot2           ; pýeruçen¡

; ------ vymaz n¡ bufferu jmenovky diskety

ReadBot4:push      es
         push      ds
         pop       es                       ; ES <- datovì segment
         mov       bx,offset MazTTxt1       ; sam‚ mezery
         call      CopyLab                  ; kopie do buffer…
         pop       es

; ------ inicializace jmenovky disky, test paritn¡ diskety

         test      byte ptr ds:[Param],bit3 ; nekompatibiln¡ BOOT ?
         jnz       ReadBt52                 ; je nekompatibiln¡ BOOT
         or        byte ptr ds:[Param],bit4 ; je paritn¡ disketa
         cmp       byte ptr es:[10h],0      ; je polo§ka tabulek FAT ?
         je        ReadBot6                 ; zýejmØ to je sud  paritn¡ disketa
         mov       bx,2bh                   ; jmenovka pro DOS 4
         cmp       byte ptr es:[bx+26h-2bh],29h ; je to rozç¡ýenì sektor ?
         je        ReadBot5                 ; je jmenovka diskety
         call      ReadLab                  ; naŸten¡ jmenovky diskety -> BX
         jc        ReadBt52                 ; chyba, ale asi nen¡ paritn¡ disk
ReadBot5:call      TestLab                  ; test jmenovky diskety ES:BX
         jc        ReadBot6                 ; jmenovka neplat¡, asi paritn¡ disk
         call      CopyLab                  ; kopie jmenovky disku ES:BX
ReadBt52:and       byte ptr ds:[Param],not bit4 ; zýejmØ nen¡ paritn¡ disketa

; ------ jmenovka NO NAME je neplatn 

ReadBot6:call      VolParit                 ; korekce pro paritn¡ disketu
         push      ds
         pop       es
         mov       si,offset NoNamTxt       ; jmenovka "NO NAME"
         mov       di,offset CtuTxt1
         mov       cx,11
         cld
         repe      cmpsb                    ; je to jmenovka NO NAME ?
         jne       ReadBot7                 ; nen¡ NO NAME
         mov       bx,offset MazTTxt1       ; sam‚ mezery
         call      CopyLab                  ; vymaz n¡ jmenovky

; ------ inicializace ukazatel… disku

ReadBot7:call      TstBreak
         jc        ReadBot8                 ; pýeruçen¡
         call      TempRes                  ; resetov n¡ pýechodn‚ho souboru
         call      TempRead                 ; naŸten¡ pýechodn‚ho souboru
         mov       word ptr ds:[EDC],-1     ; inicializaŸn¡ hodnota EDC
         mov       word ptr ds:[EDCIdent],-1 ; identifikaŸn¡ k¢d diskety
         call      DekEDCI                  ; dek¢dov n¡ identifikaŸn¡ho k¢du
         call      MazText                  ; vymaz n¡ ý dku hl çen¡
         call      DIns1E                   ; odinstalov n¡ tabulky INT 1Eh
         call      DekFDsk                  ; dek¢dov n¡ form tu disku

; ------ n vrat registr…

ReadBot8:call      TstBreak                 ; test pýeruçen¡
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBoot ENDP

; -----------------------------------------------------------------------------
;        test jmenovky disku ES:BX -> CY neplatn 
; -----------------------------------------------------------------------------

TestLab  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      si

; ------ test jmenovky, zda nen¡ < 32 a zda to nejsou mal  p¡smena

         mov       cx,11
         cmp       byte ptr es:[bx]," "+1   ; prvn¡ znak nesm¡ bìt ani mezera
         jb        TestLab9                 ; zak zanì znak
TestLab1:mov       al,es:[bx]
         inc       bx
         cmp       al," "
         jb        TestLab9
         cmp       al,"a"
         jb        TestLab2
         cmp       al,"z"+1
         jb        TestLab9

; ------ test jmenovky podle tabulky zak zanìch znak…

TestLab2:mov       si,offset BlokTab        ; tabulka zak zanìch znak…
TestLab3:cmp       al,cs:[si]
         stc
         je        TestLab9                 ; zak zanì znak
         inc       si
         cmp       byte ptr cs:[si],0
         jne       TestLab3
         loop      TestLab1
;         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

TestLab9:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

TestLab  ENDP

BlokTab  db        '"*+,./:;<=>?[\]|',0

; -----------------------------------------------------------------------------
;        kopie jmenovky ES:BX do buffer…
; -----------------------------------------------------------------------------

CopyLab  PROC      NEAR

         push      di
         mov       di,offset CtuTxt1
         call      CopyLab0
         mov       di,offset ZapTxt1
         call      CopyLab0
         mov       di,offset NactTxt1
         call      CopyLab0
         mov       di,offset IdntTx22
         call      CopyLab0
         pop       di
         ret

CopyLab  ENDP

CopyLab0:push      cx
         push      si
         push      ds
         push      es

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         pop       es                       ; ES <- datovì segment
         mov       si,bx                    ; SI <- offset vzoru jmenovky
         mov       cx,11
         cld
         rep       movsb

         pop       es
         pop       ds
         pop       si
         pop       cx
         ret

; -----------------------------------------------------------------------------
;        naŸten¡ jmenovky disku z ROOT
; -----------------------------------------------------------------------------
; VSTUP: ES=segment naŸten‚ho BOOT sektoru
; VíSTUP: BX=offset nalezen‚ jmenovky disku
;         CY=chyba, pýeruçen¡ nebo jmenovka nenalezena
; -----------------------------------------------------------------------------

ReadLab  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ zjiçtØn¡ poŸtu sektor… ROOT

         test      byte ptr ds:[Param],bit3
         jnz       ReadLab0                 ; neplatnì BOOT

         mov       bp,es:[11h]              ; poŸet polo§ek ROOT
         shr       bp,1
         shr       bp,1
         shr       bp,1
         shr       bp,1                     ; poŸet sektor… ROOT
         jnz       ReadLab1
ReadLab0:jmp       ReadLab8                 ; neplatnì poŸet polo§ek ROOT

; ------ zjiçtØn¡ poŸ teŸn¡ho sektoru ROOT

ReadLab1:cmp       byte ptr es:[10h],2      ; jsou 2 tabulky FAT ?
         jne       ReadLab8                 ; nekompatibiln¡ disketa
         mov       ax,es:[16h]              ; poŸet sektor… jedn‚ tabulky FAT
         shl       ax,1                     ; poŸet sektor… na obØ tabulky FAT
         jc        ReadLab8                 ; chyba
         add       ax,es:[0eh]              ; pýiŸten¡ rezervovanìch sektor…
         jc        ReadLab8

; ------ kontrola pýeteŸen¡ konce ROOT pýes konec disku

         mov       cx,ax
         add       cx,bp                    ; pýiŸten¡ poŸtu sektor… ROOT
         jc        ReadLab8
         cmp       cx,es:[13h]              ; kontrola pýeteŸen¡ konce disku
         jae       ReadLab8                 ; pýeteŸen¡ konce disku

; ------ pýepoŸet na ukazatele sektoru BIOS

         mov       cl,ds:[NumSekt0]         ; poŸet sektor… na stopu
         cmp       byte ptr ds:[NumStrn0],2 ; jsou 2 strany ?
         jb        ReadLab2                 ; nejsou 2 strany
         shl       cl,1                     ; poŸet sektor… pro 2 strany
ReadLab2:div       cl                       ; vìpoŸet Ÿ¡sla v lce
         mov       ch,al                    ; CH <- Ÿ¡slo v lce
         mov       al,ah                    ; AL <- sektor na v lci
         mov       ah,0
         div       byte ptr ds:[NumSekt0]   ; vydØlen¡ poŸtem sektor… na stopu
         mov       cl,ah                    ; Ÿ¡slo sektoru
         inc       cx                       ; korekce Ÿ¡sla sektoru
         mov       dh,al                    ; Ÿ¡slo strany

; ------ naŸten¡ 1 sektoru do bufferu

ReadLab3:xor       bx,bx
         mov       al,1                     ; 1 sektor
         call      ReadSekt                 ; naŸten¡ 1 sektoru ROOT
         jc        ReadLab8                 ; nØjak  chyba

; ------ prohled n¡ jednoho sektoru

         mov       si,16                    ; poŸet polo§ek na sektor
ReadLab4:cmp       byte ptr es:[bx],0
         je        ReadLab8                 ; konec adres ýe
         cmp       byte ptr es:[bx],0e5h
         je        ReadLab5                 ; zruçen  polo§ka
         test      byte ptr es:[bx+0bh],bit3 ; je to n vØçt¡ disku ?
         jnz       ReadLab9                 ; n vØçt¡ disku nalezeno OK
ReadLab5:add       bx,32                    ; adresa dalç¡ polo§ky
         dec       si
         jnz       ReadLab4                 ; test dalç¡ polo§ky

; ------ Ÿ¡taŸ zbylìch sektor… ROOT

         dec       bp                       ; Ÿ¡taŸ sektor… ROOT
         jz        ReadLab8                 ; nen¡ dalç¡ sektor

; ------ zvìçen¡ Ÿ¡sla sektoru

         inc       cx
         cmp       cl,ds:[NumSekt0]         ; je ji§ konec stopy ?
         jbe       ReadLab3                 ; naŸten¡ dalç¡ho sektoru
         mov       cl,1

; ------ zvìçen¡ Ÿ¡sla strany

         inc       dh                       ; zvìçen¡ Ÿ¡sla strany
         cmp       dh,ds:[NumStrn0]         ; jsou ji§ vçechny strany ?
         jb        ReadLab3                 ; naŸten¡ dalç¡ho sektoru
         mov       dh,0

; ------ zvìçen¡ Ÿ¡sla stopy

         inc       ch
         jmp       short ReadLab3

; ------ n vrat registr…

ReadLab8:stc
ReadLab9:pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

ReadLab  ENDP

; -----------------------------------------------------------------------------
;        test parametr… disku ES:BX (z naŸten‚ho BOOT sektoru) -> CY chyba
; -----------------------------------------------------------------------------

TestDisk PROC      NEAR

         push      ax
         push      cx
         push      dx

; ------ velikost sektoru

         cmp       word ptr es:[bx+0bh],512 ; poŸet bajt… na sektor
         jne       TestDsk8

; ------ poŸet sektor… na stopu

         mov       ax,es:[bx+18h]           ; poŸet sektor… na stopu
         cmp       ax,MAXSEKT               ; maximum sektor…
         ja        TestDsk8
         cmp       al,6                     ; minimum sektor…
         jb        TestDsk8
         mov       ds:[NumSekt0],al         ; poŸet sektor… na stopu
         xchg      ax,cx                    ; CX <- poŸet sektor… na stopu

; ------ poŸet stran disku

         mov       ax,es:[bx+1ah]           ; poŸet stran disku
         cmp       ax,2                     ; maximum stran
         ja        TestDsk8
         cmp       al,1                     ; minimum stran
         jb        TestDsk8
         mov       ds:[NumStrn0],al         ; poŸet stran disku
         je        TestDsk3                 ; je 1 strana
         shl       cx,1                     ; poŸet sektor… pro 2 strany

; ------ poŸet v lc… disku

TestDsk3:mov       ax,es:[bx+13h]           ; celkovì poŸet sektor…
         mov       ds:[CelkSkt0],ax         ; celkem sektor…
         add       ax,cx                    ; pýenos pro zaokrouhlen¡
         dec       ax
         xor       dx,dx
         div       cx                       ; vìpoŸet poŸtu v lc…
         cmp       ax,MAXTRACK              ; maxim ln¡ poŸet stop
         ja        TestDsk8
         cmp       al,35                    ; minim ln¡ poŸet stop
         jb        TestDsk8
         mov       ds:[NumStop0],al         ; poŸet stop
         jmp       short TestDsk9

; ------ chyba parametr… diskety

TestDsk8:stc
TestDsk9:pop       dx
         pop       cx
         pop       ax
         ret

TestDisk ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ parametr… BOOT sektoru ES:BX
; -----------------------------------------------------------------------------

SetSekt  PROC      NEAR

         push      ax

         test      byte ptr ds:[Param],bit3
         jnz       SetSekt2                 ; neplatnì BOOT

         mov       word ptr es:[bx+0bh],512 ; poŸet bajt… na sektor
         mov       ah,0
         mov       al,ds:[NumSekt]
         mov       es:[bx+18h],ax           ; poŸet sektor… na stopu
         mov       al,ds:[NumStran]
         mov       es:[bx+1ah],ax           ; poŸet stran
         mov       ax,ds:[CelkSekt]
         mov       es:[bx+13h],ax           ; celkovì poŸet sektor…

SetSekt2:pop       ax
         ret

SetSekt  ENDP

; *****************************************************************************
;
;                   Univerz ln¡ obsluha diskety
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        instalace tabulky INT 1Eh
; -----------------------------------------------------------------------------

Inst1E   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda je tabulka ji§ nainstalov na

         test      byte ptr ds:[Param],bit6 ; je nainstalov n ?
         jnz       Inst1E4                  ; je ji§ nainstalov n

; ------ £schova adresy INT 1Eh

         mov       ax,351eh
         int       21h                      ; poskytnut¡ adresy INT 1Eh
         mov       word ptr ds:[Old1E],bx
         mov       word ptr ds:[Old1E+2],es

; ------ pýenos tabulky do vlastn¡ho bufferu

         push      ds
         push      es
         push      ds
         pop       es                       ; ES <- datovì segment
         pop       ds                       ; DS <- segment tabulky
         mov       si,bx                    ; SI <- offset tabulky
         mov       di,offset Tab1E          ; vlastn¡ tabulka INT 1Eh
         mov       dx,di                    ; adresa tabulky
         mov       cx,offset(Tab1E0-Tab1E)  ; d‚lka tabulky
         cld
         rep       movsb                    ; £schova tabulky
         pop       ds

; ------ pýedefinov n¡ adresy INT 1Eh

         mov       ax,251eh
         int       21h                      ; definice adresy INT 1Eh
         or        byte ptr ds:[Param],bit6 ; pý¡znak nainstalov n¡

; ------ pýedefinov n¡ poŸtu sektor… na stopu

Inst1E4: mov       al,ds:[NumSekt]          ; poŸet sektor… na stopu
         mov       ds:[LastSekt],al         ; posledn¡ sektor na stopØ
         mov       byte ptr ds:[SektSize],2 ; velikost sektoru 512 bajt…

; ------ n vrat registr…

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
;        odinstalov n¡ tabulky INT 1Eh
; -----------------------------------------------------------------------------

DIns1E   PROC      NEAR

         test      byte ptr ds:[Param],bit6 ; nainstalov no ?
         jz        DIns1E4                  ; INT 1Eh nen¡ nainstalov no

         push      ax
         push      dx
         push      ds

         lds       dx,ds:[Old1E]
         mov       ax,251eh
         int       21h                      ; n vrat adresy INT 1Eh

         pop       ds
         pop       dx
         pop       ax
         and       byte ptr ds:[Param],not bit6 ; pý¡znak, §e nen¡ instalov no
DIns1E4: ret

DIns1E   ENDP

; -----------------------------------------------------------------------------
;        z pis stopy na disketu (CH=stopa, DH=strana -> CY pýeruçen¡)
; -----------------------------------------------------------------------------

WritTrck PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ zobrazen¡ hl çen¡ o z pisu stopy

WritTrc1:mov       cl,1                     ; Ÿ¡slo poŸ teŸn¡ho sektoru
         call      PrepN13                  ; pý¡prava Ÿ¡sla stopy
         mov       si,offset ZapTxt
         call      StdErrA                  ; zobrazen¡ hl çen¡

; ------ z pis stopy vcelku

         xor       bx,bx                    ; offset bufferu
         mov       es,ds:[BuffDisk]         ; adresa bufferu
         mov       al,ds:[NumSekt]          ; poŸet sektor… na stopu
         call      WritSekt                 ; z pis dat z bufferu
         jc        WritTrc2                 ; chyba z pisu

; ------ zpØtn‚ naŸten¡ stopy

         mov       es,ds:[BuffDskV]         ; buffer verifikovan‚ stopy
         call      ReadSekt                 ; naŸten¡ stopy zpØt
         jc        WritTrc2                 ; chyba z pisu

; ------ porovn n¡ dat stopy

         push      cx
         push      ds
         xor       si,si
         xor       di,di
         mov       ch,al                    ; CH <- poŸet sektor…
         mov       cl,0
         mov       ds,ds:[BuffDisk]         ; z pisovì buffer
         cld
         repe      cmpsw                    ; porovn n¡ dat
         pop       ds
         pop       cx
         je        WritTrc8                 ; operace OK

; ------ hl çen¡ chyby

WritTrc2:call      TstBreak                 ; test pýeruçen¡
         jc        WritTrc8                 ; je pýeruçen¡
         call      MazText
         mov       di,offset Er2WMnu
         mov       si,offset Er2WTxt
         call      Menu                     ; zobrazen¡ hl çen¡
         jc        WritTrc8                 ; pýeruçen¡
         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl çen¡
         cmp       al,"D"
         je        WritTrc8                 ; dalç¡ sektor
         cmp       al,"S"
         jne       WritTrc1                 ; nejsou sektory - opakov n¡

; ------ pý¡prava hl çen¡ pro aktu ln¡ ukazatele

WritTrc3:call      PrepN13                  ; pý¡prava Ÿ¡sla stopy

; ------ z pis 1 sektoru

         mov       es,ds:[BuffDisk]         ; adresa bufferu
         mov       al,1                     ; 1 sektor
         call      WritSekt                 ; z pis dat z bufferu
         jc        WritTrc5                 ; chyba z pisu

; ------ zpØtn‚ naŸten¡ sektoru

         mov       es,ds:[BuffDskV]         ; buffer verifikovan‚ stopy
         call      ReadSekt                 ; naŸten¡ stopy zpØt
         jc        WritTrc5                 ; chyba z pisu

; ------ porovn n¡ dat stopy

         push      cx
         push      ds
         mov       si,bx
         mov       di,bx
         mov       cx,256
         mov       ds,ds:[BuffDisk]         ; z pisovì buffer
         cld
         repe      cmpsw                    ; porovn n¡ dat
         pop       ds
         pop       cx
         je        WritTrc7                 ; operace OK

; ------ chyba - zobrazen¡ dotazu na dalç¡ postup

WritTrc5:call      TstBreak
         jc        WritTrc8                 ; pýeruçen¡
         call      MazText
         mov       di,offset ErrWMnu
         mov       si,offset ErrWTxt
         call      Menu                     ; zobrazen¡ hl çen¡
         jc        WritTrc8
         cmp       al,"D"
         je        WritTrc7                 ; dalç¡ sektor
;         cmp       al,"O"
;         jne       WritTrc6                 ; pýeruçen¡
         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl çen¡
         jmp       short WritTrc3

; ------ z pis dalç¡ho sektoru

WritTrc7:inc       cx                       ; zvìçen¡ Ÿ¡sla sektoru
         add       bx,512                   ; zvìçen¡ adresy v bufferu
         cmp       cl,ds:[NumSekt]          ; jsou ji§ vçechny sektory ?
         jbe       WritTrc3                 ; dalç¡ sektor

; ------ n vrat registr…

WritTrc8:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritTrck ENDP

; -----------------------------------------------------------------------------
;        Ÿten¡ stopy z diskety do bufferu (CH=stopa, DH=strana -> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

ReadTrck PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vymaz n¡ bufferu vadnìch sektor…

         mov       si,offset TrckMap        ; mapa stopy
         mov       al,ds:[NumSekt]          ; poŸet sektor…
ReadTrc1:mov       byte ptr ds:[si],0       ; oznaŸen¡ sektoru OK
         inc       si
         dec       al                       ; Ÿ¡taŸ sektor…
         jnz       ReadTrc1

; ------ test, zda se m  stopa Ÿ¡st

         test      byte ptr ds:[Param],bit1 ; je obnovovan  disketa ?
         jz        ReadTrc2                 ; nen¡ obnovan  disketa

         mov       cl,1
ReadTr12:call      TestErrM                 ; test mapy chyb
         jc        ReadTrc2                 ; je cbyba - mus¡ se naŸ¡st
         inc       cx
         cmp       cl,ds:[NumSekt]
         jbe       ReadTr12
         jmp       ReadTrc8                 ; nen¡ týeba Ÿ¡st

; ------ zobrazen¡ hl çen¡ o Ÿten¡ stopy

ReadTrc2:mov       es,ds:[BuffDisk]         ; adresa bufferu
         mov       cl,1                     ; Ÿ¡slo poŸ teŸn¡ho sektoru
         call      PrepN13                  ; pý¡prava Ÿ¡sla stopy
         mov       si,offset CtuTxt
         call      StdErrA                  ; zobrazen¡ hl çen¡

; ------ naŸten¡ 1 stopy vcelku

ReadTr24:xor       bx,bx                    ; offset bufferu
         mov       al,ds:[NumSekt]          ; poŸet sektor… na stopu
         call      ReadSekt                 ; naŸten¡ dat do bufferu
         jnc       ReadTrc8                 ; operace OK
         call      TstBreak                 ; je pýeruçen¡ ?
         jc        ReadTrc8                 ; je pýeruçen¡ operace

; ------ pý¡prava hl çen¡ pro aktu ln¡ ukazatele

         mov       di,offset TrckMap        ; mapa stopy
ReadTrc3:call      PrepN13                  ; pý¡prava Ÿ¡sla stopy

; ------ test, zda se m  sektor Ÿ¡st

         test      byte ptr ds:[Param],bit1 ; je obnovovan  disketa ?
         jz        ReadTr41                 ; nen¡ obnovan  disketa
         call      TestErrM                 ; test mapy chyb
         jnc       ReadTrc7                 ; nen¡ cbyba - nemus¡ se naŸ¡st

; ------ naŸten¡ 1 sektoru

ReadTr41:mov       al,1                     ; 1 sektor
         call      ReadSekt                 ; naŸten¡ sektoru
         jnc       ReadTrc7                 ; sektor naŸten OK
         call      TstBreak                 ; je pýeruçen¡ ?
         jc        ReadTrc8                 ; je pýeruçen¡ operace

; ------ nulov n¡ sektoru pýi chybØ

         mov       al,ch
         or        al,dh                    ; je v lec 0 / strana 0 ?
         jz        ReadTr42                 ; je v lec i stopa = 0
         mov       al,0f6h                  ; nulovac¡ bajt
ReadTr42:call      NulSekt                  ; vynulov n¡ obsahu sektoru ES:BX

         cmp       al,0
         jne       ReadTrc4                 ; nen¡ v lec 0, stopa 0
         cmp       cl,1
         jne       ReadTrc4                 ; nen¡ BOOT sektor
         call      SetSekt                  ; nastaven¡ parametr… BOOT sektoru

; ------ volba dalç¡ operace pýi chybØ

ReadTrc4:push      di
         mov       di,offset ErrRTxtM
         mov       si,offset ErrRTxt
         call      MazText                  ; vymaz n¡ ý dku
         call      Menu                     ; zobrazen¡ hl çen¡
         pop       di
         jc        ReadTrc8                 ; pýeruçen¡
         cmp       al,"D"
         je        ReadTrc6                 ; dalç¡ sektor
         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl çen¡
         jmp       short ReadTrc3           ; opakov n¡ operace

; ------ sektor naŸten s chybou

ReadTrc6:dec       byte ptr ds:[di]         ; -1 = pý¡znak chyby operace
         call      StdErrO                  ; obnoven¡ aktu ln¡ho hl çen¡

; ------ 1 sektor naŸten OK

ReadTrc7:inc       di                       ; ukazatel v tabulce
         inc       cx                       ; zvìçen¡ Ÿ¡sla sektoru
         add       bx,512                   ; zvìçen¡ adresy v bufferu
         cmp       cl,ds:[NumSekt]          ; jsou ji§ vçechny sektory ?
         jbe       ReadTrc3                 ; dalç¡ sektor

; ------ n vrat registr…

ReadTrc8:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadTrck ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ sektoru ES:BX bajtem AL
; -----------------------------------------------------------------------------

NulSekt  PROC      NEAR

         push      ax
         push      cx
         push      di

         mov       ah,al
         mov       cx,512/2
         mov       di,bx
         cld
         rep       stosw

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
;        AL=poŸet sektor…
;        ES:BX=adresa bufferu
; VíSTUP: CY=chyba
; -----------------------------------------------------------------------------

WritSekt PROC      NEAR

         push      ax
         mov       ah,3
         jmp       short ReadSek2

WritSekt ENDP

; -----------------------------------------------------------------------------
;        Ÿten¡ dat z diskety (2 pokusy)
; -----------------------------------------------------------------------------
; VSTUP: CH=stopa
;        CL=sektor
;        DH=strana
;        AL=poŸet sektor…
;        ES:BX=adresa bufferu
; VíSTUP: CY=chyba
; -----------------------------------------------------------------------------

ReadSekt PROC      NEAR

         test      byte ptr ds:[Param],bit2 ; je urŸen  paritn¡ disketa ?
         jz        ReadSek1
         cmp       word ptr ds:[OutpIdnt],0 ; je vstupn¡ soubor otevýen ?
         jne       ReadOutp                 ; je vstupn¡ soubor otevýen

ReadSek1:push      ax
         mov       ah,2                     ; funkce Ÿten¡ sektor…

ReadSek2:push      bp
         mov       bp,2                     ; poŸet pokus…
ReadSek3:call      Int13                    ; naŸten¡ sektor… do bufferu
         jnc       ReadSek4
         dec       bp                       ; Ÿ¡taŸ pokus…
         jnz       ReadSek3
ReadSek4:pop       bp
         pop       ax
         ret

ReadSekt ENDP

; ------ Ÿten¡ ze vstupn¡ho souboru

ReadOutp:push      ax
         push      bx
         push      cx
         push      dx

; ------ pýepoŸet na absolutn¡ sektor

         push      ax
         push      bx

         mov       al,ch                    ; Ÿ¡slo v lce
         mul       byte ptr ds:[NumStran]   ; pýepoŸet na absolutn¡ stopu
         add       al,dh                    ; pýiŸten¡ strany
         mov       dh,0
         adc       ah,dh
         mov       dl,ds:[NumSekt]          ; poŸet sektor… na stopu
         mul       dx                       ; pýepoŸet na sektory
         dec       cx                       ; korekce Ÿ¡sla sektoru
         add       al,cl                    ; pýiŸten¡ Ÿ¡sla sektoru
         adc       ah,0

; ------ pýepoŸet na offset v souboru

         mov       ch,0
         mov       cl,ah                    ; CX:DX = sektor*256
         mov       dh,al
         mov       dl,0
         shl       dh,1
         rcl       cl,1
         rcl       ch,1                     ; offset v souboru

; ------ nastaven¡ ukazatele v souboru

         mov       ax,4200h
         mov       bx,ds:[OutpIdnt]         ; identifik tor souboru
         int       21h                      ; nastaven¡ ukazatele v souboru

         pop       dx
         pop       ax
         jc        ReadOut4                 ; chyba operace

; ------ stanoven¡ velikosti dat k naŸten¡

         mov       ch,al                    ; poŸet sektor…
         mov       cl,0
         shl       cx,1                     ; poŸet bajt… k naŸten¡

; ------ naŸten¡ dat do bufferu

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       ah,3fh
         int       21h                      ; naŸten¡ dat ze souboru
         pop       ds
         jnc       ReadOut5

; ------ chyba Ÿten¡ ze souboru

ReadOut4:mov       si,offset ErrORTxt
         jmp       Chyba

; ------ n vrat registr…

ReadOut5:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        pý¡prava Ÿ¡sla stopy pro operaci
; -----------------------------------------------------------------------------

PrepN13  PROC      NEAR

         push      ax

; ------ Ÿ¡slo v lce

         mov       al,ch                    ; Ÿ¡slo v lce
         aam
         xchg      al,ah
         add       ax,"00"
         mov       word ptr ds:[CtuTxt2],ax ; Ÿ¡slo v lce
         mov       word ptr ds:[ZapTxt2],ax ; Ÿ¡slo v lce
         mov       word ptr ds:[ErrRTxt1+19],ax
         mov       word ptr ds:[ErrWTxt1+20],ax
         mov       word ptr ds:[Er2WTxt1+20],ax

; ------ Ÿ¡slo strany

         mov       al,dh                    ; Ÿ¡slo strany
         add       al,"0"
         mov       ds:[CtuTxt3],al
         mov       ds:[ZapTxt3],al
         mov       ds:[ErrRTxt1+29],al
         mov       ds:[ErrWTxt1+30],al
         mov       ds:[Er2WTxt1+30],al

; ------ Ÿ¡slo sektoru

         mov       al,cl
         aam
         xchg      al,ah
         add       ax,"00"
         mov       word ptr ds:[ErrRTxt1+38],ax
         mov       word ptr ds:[ErrWTxt1+39],ax

; ------ n vrat registr…

         pop       ax
         ret

PrepN13  ENDP

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
;        obsluha INT 13h s £schovou vçech registr… (CY=chyba nebo pýeruçen¡)
; -----------------------------------------------------------------------------

Int13    PROC      NEAR

; ------ £schova registr…

         push      bp
         mov       bp,2                     ; Ÿ¡taŸ pokus…

Int131:  push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ obsluha po§adovan‚ funkce

         clc
         sti
         mov       dl,ds:[Disk]             ; Ÿ¡slo disku
         int       13h

; ------ n vrat registr…

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         jnc       Int133                   ; operace OK

; ------ opakov n¡ operace pýi vìmØnØ diskety

         cmp       ah,6                     ; je vìmØna diskety ?
         jne       Int132                   ; nen¡ vìmØna diskety
         dec       bp                       ; Ÿ¡taŸ pokus…
         jnz       Int136                   ; dalç¡ pokus

; ------ test, zda je z kaz z pisu

Int132:  cmp       ah,3
         je        Int1332                  ; z kaz z pisu

; ------ test, zda je chyba TIME-OUT

         cmp       ah,80h                   ; chyba TIME-OUT ?
         je        Int134                   ; nen¡ chyba TIME-OUT
         stc
Int133:  pop       ax
         pop       bp
         ret

; ------ disketa je R/O

Int1332: push      si
         push      di
         mov       si,offset ErrROTxt
         mov       di,offset ErrROMnu
         jmp       short Int1342

; ------ dotaz na dalç¡ operaci

Int134:  push      si
         push      di
         mov       si,offset ErrTTxt
         mov       di,offset ErrTMnu
Int1342: call      MazText                  ; vymaz n¡ textu
         call      Menu                     ; zobrazen¡ textu
         pop       di
         pop       si
         jc        Int137                   ; pýeruçen¡ operace
         call      StdErrO                  ; obnoven¡ textu

Int136:  call      ResDisk                  ; resetov n¡ disku
         pop       ax
         jmp       short Int131             ; opakov n¡ operace

; ------ pýeruçen¡ operace

Int137:  call      SetBreak                 ; pý¡znak pýeruçen¡ operace
         jmp       short Int133

Int13    ENDP

; *****************************************************************************
;
;                    Obsluha zobrazen¡ a vstupu z kl vesnice
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        volba pomoc¡ menu (text SI, definice DI -> znak AX, CY=pýeruçen¡ "P")
; -----------------------------------------------------------------------------

Menu     PROC      NEAR

; ------ £schova registr…

         push      dx
         push      bx

; ------ zobrazen¡ cel‚ho ý dku textu

         call      NulBreak                 ; nulov n¡ pý¡znaku pýeruçen¡
         mov       dl,1                     ; aktivn¡ volba
         mov       dh,ds:[di]               ; poŸet voleb celkem
         call      StdErr                   ; zobrazen¡ ý dku textu

; ------ ukazatel aktivn¡ polo§ky

Menu1:   mov       bx,di
         add       bl,dl
         adc       bh,0
         add       bl,dl
         adc       bh,0
         dec       bx

; ------ zobrazen¡ kurzoru

         push      word ptr ds:[si]         ; £schova p…vodn¡ d‚lky textu
         mov       al,ds:[bx+1]             ; offset kurzoru
         mov       ds:[si],al               ; nov  d‚lka textu
         call      StdErr                   ; zobrazen¡ ý dku textu
         pop       word ptr ds:[si]

; ------ Ÿek n¡ na zad n¡ kl vesy

Menu2:   call      StdIn
         jnc       Menu22                   ; nen¡ pýeruçen¡
         mov       al,"P"                   ; volba pýeruçen¡ menu

; ------ potvrzen¡ aktivn¡ volby ENTER (mezera)

Menu22:  cmp       al,13
         je        Menu8                    ; potvrzen¡ volby ENTER
         cmp       al," "
         je        Menu8                    ; potvrzen¡ volby mezerou

; ------ prvn¡ polo§ka HOME

         cmp       ax,4700h
         je        Menu3

; ------ kurzor vpravo

         cmp       al,9
         je        Menu32
         cmp       ax,4d00h
         jne       Menu4
Menu32:  inc       dx                       ; zvìçen¡ aktivn¡ polo§ky
         cmp       dl,dh
         jbe       Menu1                    ; nen¡ jeçtØ konec
Menu3:   mov       dl,1                     ; prvn¡ polo§ka
         jmp       short Menu1

; ------ posledn¡ polo§ka END

Menu4:   cmp       ax,4f00h
         je        Menu5

; ------ kurzor vlevo

         cmp       ax,0f00h
         je        Menu52
         cmp       ax,4b00h
         jne       Menu6
Menu52:  dec       dl                       ; sn¡§en¡ aktivn¡ polo§ky
         jnz       Menu1
Menu5:   mov       dl,dh
         jmp       short Menu1

; ------ nalezen¡ hork‚ kl vesy v menu

Menu6:   push      di
         push      dx
         mov       dl,1
Menu62:  inc       di
         inc       di
         cmp       al,ds:[di-1]
         je        Menu7                    ; kl vesa nalezena OK
         dec       dh
         jnz       Menu62
         pop       dx
         pop       di
         jmp       short Menu2              ; kl vesa nenalezena

Menu7:   pop       dx
         pop       di
         jmp       short Menu82

; ------ zvolen  kl vesa

Menu8:   mov       al,ds:[bx]               ; p¡smeno aktivn¡ volby
Menu82:  cmp       al,"P"
         clc
         jne       Menu9
         call      SetBreak                 ; nastaven¡ pý¡znaku pýeruçen¡

; ------ vymaz n¡ ý dku textu

Menu9:   call      MazText                  ; vymaz n¡ ý dku textu
         mov       ah,0

; ------ n vrat registr…

         pop       bx
         pop       dx
         ret

Menu     ENDP

; -----------------------------------------------------------------------------
;        test pýeruçen¡ operace ESC -> CY pýeruçen¡
; -----------------------------------------------------------------------------

TestEsc  PROC      NEAR

         test      byte ptr ds:[Operace],bit7 ; je £spornì m¢d ?
         jnz       TestEsc9                 ; je £spornì m¢d

         mov       ah,0bh
         int       21h                      ; test kl vesnice
         cmp       al,0
         je        TestEsc9                 ; nen¡ pýipraven § dnì znak

         mov       ah,8
         int       21h                      ; vstup znaku z kl vesnice
         cmp       al,0
         jne       TestEsc2
         mov       ah,8
         int       21h
         mov       al,0

TestEsc2:cmp       al,27
         clc
         jne       TestEsc9                 ; nen¡ ESC
         call      SetBreak                 ; nastaven¡ pý¡znaku pýeruçen¡
TestEsc9:ret

TestEsc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice -> AX
; -----------------------------------------------------------------------------

StdIn    PROC      NEAR

; ------ vypr zdnØn¡ bufferu kl vesnice

         push      dx
         mov       ax,0c06h
         mov       dl,0ffh
         int       21h                      ; vypr zdnØn¡ bufferu kl vesnice
         pop       dx

; ------ test znaku z kl vesnice

StdIn1:  mov       ah,0bh
         int       21h                      ; test znaku z kl vesnice
         cmp       al,0
         jne       StdIn2                   ; je pýipraven znak z kl vesnice

; ------ obsluha vyp¡n n¡ mechaniky

         test      byte ptr ds:[Operace],bit5 ; je identifikace disket ?
         jz        StdIn1                   ; nen¡ identifikace disket
         push      es
         xor       ax,ax
         mov       es,ax
         mov       al,ds:[MotorOff]         ; Ÿas pro vypnut¡ motoru
         mov       es:[440h],al             ; Ÿ¡taŸ pro vypnut¡ motoru
         pop       es
         jmp       short StdIn1

; ------ vstup znaku z kl vesnice

StdIn2:  mov       ah,8
         int       21h                      ; vstup znaku z kl vesnice
         mov       ah,0

; ------ konverze na velk‚ p¡smeno

         cmp       al,"a"
         jb        StdIn3
         cmp       al,"z"
         ja        StdIn3
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ vstup SCAN k¢du ý¡dic¡ kl vesy

StdIn3:  cmp       al,0
         jne       StdIn4
         mov       ah,8
         int       21h                      ; zruçen¡ rozç¡ýen‚ kl vesy
         mov       ah,al                    ; SCAN k¢d ý¡dic¡ kl vesy
         mov       al,0

; ------ n hrada pý¡padn‚ho Ctrl-Break kl vesou ESC

StdIn4:  cmp       al,3                     ; Ctrl-C
         je        StdIn5
         or        ax,ax
         jnz       StdIn6
StdIn5:  mov       al,27

; ------ pý¡znak CY pro ESC

StdIn6:  cmp       al,27                    ; ESC
         clc
         jne       StdIn7
         stc
StdIn7:  ret

StdIn    ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ vìstupn¡ho ý dku (uchov v  registr pý¡znak… !)
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
;        obnoven¡ aktu ln¡ho hl çen¡
; -----------------------------------------------------------------------------

StdErrO  PROC      NEAR

         push      si
         mov       si,ds:[AktHlas]          ; adresa aktu ln¡ho hl çen¡
         call      StdErr                   ; zobrazen¡ hl çen¡
         pop       si
         ret

StdErrO  ENDP

; -----------------------------------------------------------------------------
;        vìstup textu DS:SI na standardn¡ chybov‚ zaý¡zen¡ (1. slovo = d‚lka)
; -----------------------------------------------------------------------------

; ------ hl çen¡ s uschov n¡m adresy aktu ln¡ho hl çen¡ o prov dØn‚ operaci

StdErrA: mov       ds:[AktHlas],si          ; adresa aktu ln¡ho hl çen¡
         jmp       short StdErr

; ------ hl çen¡ s pýedchoz¡m vymaz n¡ ý dku

StdErr0: call      MazText                  ; vymaz n¡ ý dku

StdErr   PROC      NEAR

         push      bx
         mov       bx,2                     ; identifik tor zaý¡zen¡ STDERR
         jmp       short StdOut1

StdErr   ENDP

; -----------------------------------------------------------------------------
;        vìstup textu DS:SI do souboru protokolu (1. slovo = d‚lka)
; -----------------------------------------------------------------------------

RepOut:  push      si
         mov       si,offset DatTxt0
         call      RepOut0
         pop       si

RepOut0: push      bx
         mov       bx,ds:[RepIdnt]          ; identifik tor souboru
         or        bx,bx
         jnz       StdOut1                  ; soubor je otevýen
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        vìstup textu DS:SI na standardn¡ vìstupn¡ zaý¡zen¡ (1. slovo = d‚lka)
; -----------------------------------------------------------------------------

StdOut0: call      MazText                  ; vymaz n¡ ý dku
         jmp       short StdOut

StdOutT: test      byte ptr ds:[Operace],bit6 ; je tichì m¢d ?
         jnz       StdOut5                  ; je tichì m¢d

StdOut   PROC      NEAR

         push      bx
         mov       bx,1                     ; identifik tor zaý¡zen¡ STDOUT

StdOut1: push      ax
         push      cx
         push      dx

         mov       cx,ds:[si]               ; poŸet bajt… k zobrazen¡
         mov       dx,si                    ; zaŸ tek textu k zobrazen¡
         inc       dx
         inc       dx
         mov       ah,40h
         int       21h                      ; zobrazen¡ textu

         pop       dx
         pop       cx
         pop       ax
         pop       bx
StdOut5: ret

StdOut   ENDP

; *****************************************************************************
;
;                       Rozbor pý¡kazov‚ho ý dku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        rozbor pý¡kazov‚ho ý dku (neuchov v  registry, CY=chyba parametr…)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ pý¡prava pý¡kazov‚ho ý dku

         mov       si,81h                   ; zaŸ tek pý¡kazov‚ho ý dku
         mov       bh,0
         mov       bl,ds:[si-1]             ; d‚lka pý¡kazov‚ho ý dku
         and       bl,7fh
         mov       ds:[si+bx],bh            ; oznaŸen¡ konce pý¡kazov‚ho ý dku

; ------ naŸten¡ znaku z pý¡kazov‚ho ý dku

Rozbor1: call      RozbChr                  ; naŸten¡ znaku z pý¡kazov‚ho ý dku
         je        Rozbor1                  ; mezera - vypuçtØn¡
         jnc       Rozbor12
         jmp       Rozbor7                  ; konec textu
Rozbor12:cmp       al,"{"
         je        Rozbor1                  ; ignorov n¡ znaku "{"
         cmp       al,"|"
         je        Rozbor1                  ; ignorov n¡ znaku "|"
         cmp       al,"}"
         je        Rozbor1                  ; ignorov n¡ znaku "}"
         cmp       al,"/"
         je        Rozbor1                  ; ignorov n¡ znaku "/"
         cmp       al,":"
         je        Rozbor1                  ; ignorov n¡ znaku ":"
         cmp       al,"-"
         je        Rozbor1                  ; ignorov n¡ znaku "-"

; ------ zad n¡ disku

         cmp       al,"A"
         jb        Rozbor2                  ; nen¡ oznaŸen¡ disku
         cmp       al,"B"
         ja        Rozbor2                  ; nen¡ oznaŸen¡ disku
         sub       al,"A"                   ; Ÿ¡slo disku
         mov       ds:[Disk],al             ; Ÿ¡slo disku
         call      DekTDisk                 ; pý¡prava oznaŸen¡ disku
         jmp       short Rozbor1

; ------ povel "G" - generov n¡ paritn¡ diskety

Rozbor2: cmp       al,"G"
         jne       Rozbor3
         or        bh,bit0                  ; pý¡znak zad n¡ parametru "G"
         jmp       short Rozbor1

; ------ povel "R" - obnoven¡ poçkozen‚ diskety archivu

Rozbor3: cmp       al,"R"
         jne       Rozbor4
         or        bh,bit1                  ; pý¡znak zad n¡ parametru "R"
Rozbor11:jmp       short Rozbor1

; ------ povel "T" - test vçech disket archivu

Rozbor4: cmp       al,"T"
         jne       Rozbor5
         or        bh,bit2                  ; pý¡znak zad n¡ parametru "T"
         jmp       short Rozbor11

; ------ povel "V" - verifikace diskety

Rozbor5: cmp       al,"V"
         jne       Rozbor6
         or        bh,bit3                  ; pý¡znak zad n¡ parametru "V"
         jmp       short Rozbor11

; ------ povel "M" - modifikace paritn¡ diskety

Rozbor6: cmp       al,"M"
         jne       Rozbor62
         or        bh,bit4                  ; pý¡znak zad n¡ parametru "M"
         jmp       short Rozbor11

; ------ povel "Q" - tichì m¢d

Rozbor62:cmp       al,"Q"
         jne       Rozbor63
         or        bh,bit6                  ; pý¡znak zad n¡ parametru "Q"
         jmp       short Rozbor11

; ------ povel "I" - identifikaŸn¡ k¢d

Rozbor63:cmp       al,"I"
         jne       Rozbor64
         or        bh,bit5
         jmp       short Rozbor11

; ------ povel "F" - paritn¡ disketa ulo§ena v souboru

Rozbor64:cmp       al,"F"
         jne       Rozbor65
         call      RozbFil                  ; rozbor jm‚na souboru
         jc        Rozbor8                  ; chyba zad n¡
         or        byte ptr ds:[Param],bit0 ; pý¡znak paritn¡ diskety v souboru
         jmp       short Rozbor11

; ------ povel "S" - £spornì m¢d (1 pýechodnì soubor)

Rozbor65:cmp       al,"S"
         jne       Rozbor8
         or        bh,bit7
         jmp       short Rozbor11

; ------ test, zda byl zad n disk i povel

Rozbor7: call      DekTDisk                 ; pý¡prava oznaŸen¡ disku
         mov       al,bh
         mov       ds:[Operace],al          ; po§adovan  operace
         and       al,not bit6+bit7
         cmp       al,bit0
         je        Rozbor9
         cmp       al,bit1
         je        Rozbor9
         cmp       al,bit2
         je        Rozbor9
         cmp       al,bit3
         je        Rozbor9
         cmp       al,bit4
         je        Rozbor9
         cmp       al,bit5
         je        Rozbor9
Rozbor8: stc
Rozbor9: ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        rozbor jm‚na souboru (CY=chyba)
; -----------------------------------------------------------------------------

RozbFil  PROC      NEAR

; ------ nalezen¡ zaŸ tku jm‚na souboru

RozbFil1:call      RozbChr                  ; naŸten¡ znaku
         je        RozbFil1                 ; je mezera
         jc        RozbFil9

; ------ pýenesen¡ specifikace souboru

         push      ds
         pop       es
         mov       di,offset OutpFile
         cld
RozbFil2:stosb
         call      RozbChr
         ja        RozbFil2
         mov       al,0
         stosb
         sub       di,offset OutpFile

; ------ kopie do jm‚na pýechodn‚ho souboru pro Ÿten¡

         push      si
         mov       cx,di
         mov       si,offset OutpFile
         mov       di,offset TempFilR
         push      si
         push      cx
         rep       movsb                    ; kopie jm‚na souboru
         pop       cx
         pop       si

; ------ zmØna jm‚na pýechodn‚ho souboru

         dec       di                       ; n vrat na 0
         dec       di                       ; n vrat na posledn¡ p¡smeno
         cmp       byte ptr ds:[di],"."
         jne       RozbFil3
         dec       di
RozbFil3:mov       al,"$"
         cmp       al,ds:[di]
         jne       RozbFil4
         mov       al,"_"
RozbFil4:mov       ds:[di],al               ; zmØna jm‚na

; ------ kopie do jm‚na pýechodn‚ho souboru pro z pis

         mov       di,offset TempFilW
         rep       movsb                    ; kopie jm‚na souboru

; ------ zmØna jm‚na pýechodn‚ho souboru

         dec       di                       ; n vrat na 0
         dec       di                       ; n vrat na posledn¡ p¡smeno
         cmp       byte ptr ds:[di],"."
         jne       RozbFil5
         dec       di
RozbFil5:mov       al,"@"
         cmp       al,ds:[di]
         jne       RozbFil6
         mov       al,"%"
RozbFil6:mov       ds:[di],al               ; zmØna jm‚na

         pop       si
         clc
RozbFil9:ret

RozbFil  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ znaku z pý¡kazov‚ho ý dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

; ------ naŸten¡ znaku

         cld
         lodsb

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

; ------ test, zda je platnì znak

RozbChr3:cmp       al," "
         jae       RozbChr4
         dec       si
RozbChr4:ret

RozbChr  ENDP

; *****************************************************************************
;
;                         Obsluha pýechodn‚ho souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zaýazen¡ nov‚ diskety do vìstupn¡ho pýechodn‚ho souboru
; -----------------------------------------------------------------------------

TempXchg PROC      NEAR

         push      ax
         push      cx
         push      si

         mov       ax,ds:[TempIdnR]
         xchg      ax,ds:[TempIdnW]
         mov       ds:[TempIdnR],ax

         mov       si,offset TempFilR
         mov       cx,128
TempXch2:mov       al,ds:[si]
         xchg      al,ds:[si+TempFilW-TempFilR]
         mov       ds:[si],al
         inc       si
         loop      TempXch2

         pop       si
         pop       cx
         pop       ax
         ret

TempXchg ENDP

; -----------------------------------------------------------------------------
;        inicializace jm‚na pýechodn‚ho souboru (neuchov v  registry !)
; -----------------------------------------------------------------------------

TempInit PROC      NEAR

; ------ pý¡prava implicitn¡ho disku

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         cmp       al,2                     ; je disk A: nebo B: ?
         jae       TempIni1                 ; nen¡ disk A: ani B:
         mov       al,2                     ; implicitn¡ je disk C:

; ------ ulo§en¡ oznaŸen¡ implicitn¡ho disku

TempIni1:push      ds
         pop       es
         mov       di,offset TempFilR       ; buffer pýechodn‚ho souboru
         cld
         add       al,"A"
         mov       ah,":"
         stosw                              ; ulo§en¡ oznaŸen¡ disku

; ------ test verze syst‚mu

         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cld
         cmp       al,3                     ; minim ln¡ verze DOS 3.xx
         jb        TempIni8                 ; je n¡zk  verze syst‚mu

; ------ nalezen¡ ýetØzce jm‚na programu

         push      ds
         mov       ax,ds:[2ch]              ; segment prostýed¡
         or        ax,ax
         jz        TempIni7                 ; neplatn‚ prostýed¡
         mov       ds,ax                    ; segment prostýed¡
         xor       si,si
         xor       ax,ax
TempIni2:inc       si
         js        TempIni7
         cmp       ax,ds:[si-1]
         jne       TempIni2
         inc       si

; ------ kontrola poŸtu ýetØzc…

         lodsw                              ; poŸet ýetØzc…
         dec       ax                       ; je 1 a v¡ce ?
         js        TempIni7                 ; nejsou ýetØzce

; ------ kontrola disku

         cmp       byte ptr ds:[si+1],":"   ; je zad n disk ?
         jne       TempIni4                 ; nen¡ zad n disk
         lodsb                              ; oznaŸen¡ disku
         cmp       al,"a"
         jb        TempIni3
         cmp       al,"z"
         ja        TempIni3
         sub       al,32                    ; konverze na velk‚ p¡smeno
TempIni3:cmp       al,"C"                   ; minim ln¡ oznaŸen¡ disku
         jb        TempIni7                 ; neplatnì disk
         cmp       al,"a"
         jae       TempIni7                 ; neplatnì disk
         mov       es:[di-2],al             ; oznaŸen¡ disku
         inc       si                       ; pýeskoŸen¡ znaku ":"

; ------ pýenos cesty

TempIni4:mov       dx,di                    ; £schova konce cesty
TempIni5:lodsb                              ; naŸten¡ znaku
         stosb                              ; ulo§en¡ znaku
         cmp       di,offset TempFilR+110   ; maxim ln¡ konec cesty
         jae       TempIni6                 ; cesta je ji§ pln 
         cmp       al,"\"                   ; je oddØlovaŸ cesty ?
         je        TempIni4                 ; oddØlovaŸ cesty
         cmp       al,"/"
         je        TempIni4                 ; oddØlovaŸ cesty
         cmp       al,":"
         je        TempIni4
         cmp       al,0
         jne       TempIni5

TempIni6:mov       di,dx                    ; konec cesty

; ------ pýid n¡ jm‚na souboru SAFEDISK.$T$

TempIni7:pop       ds

TempIni8:mov       si,offset TempFil0
         mov       cx,13
         rep       movsb                    ; pýenos jm‚na souboru

; ------ jm‚no souboru k z pisu

         mov       si,offset TempFilR
         sub       di,si
         mov       cx,di                    ; d‚lka jm‚na souboru
         push      si
         push      cx
         mov       di,offset TempFilW       ; soubor pro z pis
         rep       movsb
         mov       byte ptr ds:[di-2],"@"   ; jm‚no souboru pro z pis
         pop       cx
         pop       si

; ------ kopie do bufferu souboru SAFEDISK.REP

         mov       di,offset RepFile
         mov       dx,di
         rep       movsb                    ; pýenos jm‚na souboru
         mov       word ptr ds:[di-4],"ER"
         mov       byte ptr ds:[di-2],"P"

; ------ otevýen¡ souboru SAFEDISK.REP pro z pis

         mov       ax,3d01h
         int       21h
         jnc       TempIni9
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        TempIniA                 ; chyba
TempIni9:mov       ds:[RepIdnt],ax          ; identifik tor souboru

; ------ nastaven¡ ukazatele v souboru na konec

         xchg      ax,bx
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h                      ; nastaven¡ ukazatele na konec

; ------ dek¢dov n¡ aktu ln¡ho data

         mov       ah,2ah
         int       21h                      ; poskytnut¡ aktu ln¡ho data
         mov       ah,0
         mov       al,dl                    ; den
         mov       di,offset DatTxt + 3
         call      DekNum                   ; dek¢dov n¡ dne
         mov       di,offset DatTxt + 6
         mov       al,dh
         call      DekNum                   ; dek¢dov n¡ mØs¡ce
         mov       di,offset DatTxt + 11
         xchg      ax,cx
         call      DekNum                   ; dek¢dov n¡ roku

; ------ dek¢dov n¡ aktu ln¡ho Ÿasu

         mov       ah,2ch
         int       21h                      ; poskytnut¡ aktu ln¡ho Ÿasu
         mov       ah,0
         mov       al,ch
         mov       di,offset DatTxt + 15
         call      DekNum                   ; dek¢dov n¡ hodiny
         mov       al,cl
         mov       di,offset DatTxt + 18
         call      DekNum                   ; dek¢dov n¡ minuty
         mov       al,dh
         mov       di,offset DatTxt + 21
         call      DekNum

; ------ pýenesen¡ pý¡kazov‚ho ý dku

         mov       di,offset DatTxt1
         mov       si,81h                   ; zaŸ tek pý¡kazov‚ho ý dku
         mov       cl,ds:[80h]
         and       cx,7fh
         rep       movsb                    ; pýenos pý¡kazov‚ho ý dku
         mov       ax,0a0dh
         stosw                              ; ulo§en¡ CR/LF
         sub       di,offset DatTxt+2
         mov       ds:[DatTxt],di           ; d‚lka textu

; ------ vìstup textu

         mov       si,offset DatTxt
         call      RepOut0                  ; vìstup textu

TempIniA:ret

TempInit ENDP

; -----------------------------------------------------------------------------
;        otevýen¡ pýechodn‚ho souboru
; -----------------------------------------------------------------------------

TempOpen PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx

; ------ test, zda je soubor pro Ÿten¡ ji§ vytvoýen

         cmp       word ptr ds:[TempIdnR],0 ; je soubor ji§ vytvoýen ?
         jne       TempOpn4                 ; soubor je ji§ vytvoýen

; ------ otevýen¡ vstupn¡ho souboru

         test      byte ptr ds:[Param],bit0 ; paritn¡ disketa v souboru ?
         jz        TempOpn2                 ; nen¡ disketa v souboru
         mov       dx,offset OutpFile
         mov       ax,3d00h
         int       21h                      ; otevýen¡ souboru pro Ÿten¡
         jc        TempOpn2
         mov       ds:[OutpIdnt],ax         ; identifik tor souboru

; ------ vytvoýen¡ souboru pro Ÿten¡

TempOpn2:mov       dx,offset TempFilR       ; jm‚no souboru pro Ÿten¡
         mov       ah,3ch
         xor       cx,cx                    ; CX <- 0 atributy
         int       21h                      ; vytvoýen¡ souboru
         jnc       TempOpn3                 ; soubor vytvoýen OK

; ------ chyba - soubor nelze vytvoýit

TempOp22:mov       si,offset ErrOTxt
         jmp       Chyba

; ------ ulo§en¡ identifik toru pro Ÿten¡

TempOpn3:mov       ds:[TempIdnR],ax         ; identifik tor souboru

; ------ test, zda je soubor pro z pis ji§ vytvoýen

TempOpn4:cmp       word ptr ds:[TempIdnW],0 ; je soubor pro z pis ji§ vytvoýen ?
         jne       TempOpn9                 ; je ji§ vytvoýen
         mov       ax,ds:[TempIdnR]         ; soubor pro Ÿten¡
         test      byte ptr ds:[Operace],bit7 ; je £spornì m¢d ?
         jnz       TempOpn8                 ; je £spornì m¢d

; ------ vytvoýen¡ souboru

         mov       dx,offset TempFilW       ; jm‚no souboru pro z pis
         mov       ah,3ch
         xor       cx,cx                    ; CX <- 0 atributy
         int       21h                      ; vytvoýen¡ souboru
         jc        TempOp22                 ; chyba vytvoýen¡ souboru

; ------ ulo§en¡ identifik toru

TempOpn8:mov       ds:[TempIdnW],ax         ; identifik tor souboru pro z pis

; ------ n vrat registr…

TempOpn9:pop       dx
         pop       cx
         pop       ax
         ret

TempOpen ENDP

; -----------------------------------------------------------------------------
;        uzavýen¡ a zruçen¡ pýechodn‚ho souboru
; -----------------------------------------------------------------------------

TempClos PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      dx

; ------ test, zda je soubor pro Ÿten¡ vytvoýen

         mov       bx,ds:[TempIdnR]         ; identifik tor souboru pro Ÿten¡
         or        bx,bx                    ; je soubor vytvoýen ?
         jz        TempCls4                 ; soubor nen¡ vytvoýen

; ------ uzavýen¡ souboru

         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru
         mov       word ptr ds:[TempIdnR],0 ; zruçen¡ identifik toru
         test      byte ptr ds:[Operace],bit7
         jz        TempCls2
         mov       word ptr ds:[TempIdnW],0

; ------ zruçen¡ souboru

TempCls2:mov       dx,offset TempFilR       ; jm‚no souboru
         mov       ah,41h
         int       21h                      ; zruçen¡ pýechodn‚ho souboru

; ------ uzavýen¡ vìstupn¡ho souboru

TempCls4:mov       bx,ds:[OutpIdnt]
         or        bx,bx
         jz        TempCls5
         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru
         mov       word ptr ds:[OutpIdnt],0 ; zruçen¡ identifik toru

; ------ test, zda je soubor pro z pis vytvoýen

TempCls5:test      byte ptr ds:[Operace],bit7 ; je £spornì m¢d ?
         jnz       TempCls9                 ; je £spornì m¢d
         mov       bx,ds:[TempIdnW]         ; identifik tor souboru pro z pis
         or        bx,bx                    ; je soubor vytvoýen ?
         jz        TempCls9                 ; soubor nen¡ vytvoýen

; ------ uzavýen¡ souboru

         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru
         mov       word ptr ds:[TempIdnW],0 ; zruçen¡ identifik toru

; ------ zruçen¡ souboru

         mov       dx,offset TempFilW       ; jm‚no souboru
         mov       ah,41h
         int       21h                      ; zruçen¡ pýechodn‚ho souboru

; ------ n vrat registr…

TempCls9:pop       dx
         pop       bx
         pop       ax
         ret

TempClos ENDP

; -----------------------------------------------------------------------------
;        z pis paritn¡ diskety do souboru (neuchov v  registry)
; -----------------------------------------------------------------------------

ZapOutp  PROC      NEAR

; ------ uzavýen¡ pýechodn‚ho souboru

         mov       bx,ds:[TempIdnR]
         or        bx,bx
         jz        ZapOutp2
         mov       ah,3eh
         int       21h
         jc        ZapOutp6
         mov       word ptr ds:[TempIdnR],0
         test      byte ptr ds:[Operace],bit7
         jz        ZapOutp2
         mov       word ptr ds:[TempIdnW],0

; ------ uzavýen¡ star‚ho souboru

ZapOutp2:mov       bx,ds:[OutpIdnt]         ; identifik tor souboru
         or        bx,bx
         jz        ZapOutp3
         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru
         jc        ZapOutp6
         mov       word ptr ds:[OutpIdnt],0

; ------ zruçen¡ star‚ho souboru

         mov       dx,offset OutpFile
         mov       ah,41h
         int       21h                      ; zruçen¡ star‚ho souboru
         jc        ZapOutp6

; ------ pýejmenov n¡ souboru

ZapOutp3:push      ds
         pop       es
         mov       dx,offset TempFilR       ; p…vodn¡ soubor
         mov       di,offset OutpFile       ; nov‚ jm‚no
         mov       ah,56h
         int       21h                      ; pýejmenov n¡ souboru
         jnc       ZapOutp7

; ------ chyba z pisu

ZapOutp6:mov       si,offset ErrOWTxt
         jmp       Chyba

; ------ otevýen¡ vìstupn¡ho souboru pro Ÿten¡

ZapOutp7:mov       dx,offset OutpFile       ; vìstupn¡ soubor
         mov       ax,3d00h
         int       21h                      ; otevýen¡ pro Ÿten¡
         jc        ZapOutp6
         xchg      ax,bx                    ; BX <- identifik tor

; ------ urŸen¡ velikosti bufferu

         mov       cx,ds:[BuffMax]          ; velikost bufferu
         cmp       cx,120
         jb        ZapOut72
         mov       cx,120
ZapOut72:mov       ch,cl
         mov       cl,0
         shl       cx,1                     ; max. velikost
         mov       word ptr ds:[EDC],-1

; ------ naŸten¡ bloku dat ze souboru

ZapOut74:push      ds
         mov       ds,ds:[BuffDat]          ; datovì buffer
         xor       dx,dx
         mov       ah,3fh
         int       21h                      ; naŸten¡ bloku dat
         pop       ds
         jc        ZapOutp6

; ------ pýepoŸet dat na sektory

         mov       al,ah
         shr       al,1                     ; poŸet sektor…
         jz        ZapOut78                 ; nejsou dalç¡ data

; ------ kontroln¡ souŸet bloku dat

         push      bx
         mov       dx,ds:[EDC]
         mov       es,ds:[BuffDat]
         xor       bx,bx
         call      CheckSum
         mov       ds:[EDC],dx
         pop       bx
         jmp       short ZapOut74           ; dalç¡ blok dat

; ------ uzavýen¡ souboru

ZapOut78:mov       ah,3eh
         int       21h

; ------ zobrazen¡ hl çen¡ o operaci

         mov       ax,word ptr ds:[PartTxt1]
         mov       word ptr ds:[EDCITxt3],ax
         mov       ax,word ptr ds:[PartTxt1+2]
         mov       word ptr ds:[EDCITxt3+2],ax

         inc       word ptr ds:[NDisket]    ; zvìçen¡ Ÿ¡sla diskety
         call      DekNDisk                 ; dek¢dov n¡ Ÿ¡sla diskety
         call      DispEDC                  ; zobrazen¡ kontroln¡ho souŸtu
         ret

ZapOutp  ENDP

; -----------------------------------------------------------------------------
;        resetov n¡ ukazatele v pýechodn‚m souboru
; -----------------------------------------------------------------------------

TempRes  PROC      NEAR

         push      ax
         xor       ax,ax
         mov       word ptr ds:[ReadUTmp],ax
         mov       word ptr ds:[ReadUTmp+2],ax
         mov       word ptr ds:[WritUTmp],ax
         mov       word ptr ds:[WritUTmp+2],ax
         pop       ax
         ret

TempRes  ENDP

; -----------------------------------------------------------------------------
;        z pis dat z bufferu do pýechodn‚ho souboru
; -----------------------------------------------------------------------------

TempWrit PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp

; ------ nastaven¡ ukazatele v souboru

         mov       bx,ds:[TempIdnW]         ; identifik tor souboru
         or        bx,bx                    ; je soubor otevýen ?
         jz        TempWrt9                 ; nen¡ otevýen

         mov       ax,4200h
         mov       dx,word ptr ds:[WritUTmp] ; z pisovì offset
         mov       cx,word ptr ds:[WritUTmp+2]
         int       21h                      ; nastaven¡ ukazatele v souboru
         jc        TempWrt4                 ; nØjak  chyba

; ------ pý¡prava ukazatel… k operaci

         mov       bp,ds:[BuffUkaz]         ; ukazatel adresy v bufferu
         mov       dx,ds:[BuffDat]          ; zaŸ tek bufferu
         mov       ds:[BuffUkaz],dx         ; nov  ukl dac¡ adresa
         sub       bp,dx                    ; poŸet dat k ulo§en¡
         jbe       TempWrt9                 ; nejsou § dn  data k ulo§en¡

; ------ velikost bloku dat pro jednu operaci

TempWrt2:mov       cx,120*512/16            ; asi tak velikost jednoho bloku
         cmp       cx,bp
         jb        TempWrt3
         mov       cx,bp                    ; omezen¡ velikosti dat
TempWrt3:sub       bp,cx                    ; sn¡§en¡ Ÿ¡taŸe zbylìch dat
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; pýepoŸet na bajty

; ------ z pis jednoho bloku dat do souboru

         push      dx
         push      ds
         mov       ds,dx                    ; segment adresy bufferu
         xor       dx,dx                    ; offset adresy bufferu
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         pop       ds
         pop       dx

; ------ chyba z pisu do souboru

         jc        TempWrt4                 ; chyba z pisu
         cmp       ax,cx                    ; bylo zaps no vçe ?
         je        TempWrt5                 ; je zaps no vçe OK
         mov       si,offset ErrTWDTx       ; nedostatek m¡sta na disku
         jmp       short TempWr42
TempWrt4:mov       si,offset ErrTWTxt
TempWr42:call      MazText                  ; vymaz n¡ ý dku
         jmp       Chyba

; ------ pý¡prava pro dalç¡ blok dat

TempWrt5:add       word ptr ds:[WritUTmp],cx ; zvìçen¡ ukazatele v souboru
         adc       word ptr ds:[WritUTmp+2],0
         add       dx,120*512/16            ; zvìçen¡ adresy bufferu
         or        bp,bp                    ; je dalç¡ m¡sto ?
         jnz       TempWrt2                 ; naŸten¡ dalç¡ho bloku dat

; ------ n vrat registr…

TempWrt9:mov       word ptr ds:[BuffCit],0  ; nezbyly § dn‚ sektory
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TempWrit ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ bufferu z pýechodn‚ho souboru
; -----------------------------------------------------------------------------

TempRead PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp
         push      es

; ------ pý¡prava k naŸten¡ dat ze souboru

         mov       dx,ds:[BuffDat]          ; zaŸ tek datov‚ho bufferu
         mov       bp,ds:[BuffMax]          ; maxim ln¡ poŸet sektor… k naŸten¡
         mov       ds:[BuffCit],bp          ; Ÿ¡taŸ zbylìch sektor… v bufferu
         mov       ds:[BuffUkaz],dx         ; ukazatel adresy v bufferu

; ------ test, zda je pýechodnì soubor otevýen

         mov       bx,ds:[TempIdnR]         ; identifik tor souboru
         or        bx,bx
         jz        TempRea9                 ; soubor nen¡ otevýen

; ------ nastaven¡ ukazatele v souboru

         push      dx
         mov       ax,4200h
         mov       dx,word ptr ds:[ReadUTmp] ; Ÿtec¡ offset
         mov       cx,word ptr ds:[ReadUTmp+2]
         int       21h                      ; nastaven¡ ukazatele v souboru
         pop       dx
         jc        TempRea4                 ; nØjak  chyba

; ------ stanoven¡ poŸtu sektor… pro jednu operaci

TempRea2:mov       cx,120                   ; asi tak maximum pro jednu operaci
         cmp       cx,bp
         jb        TempRea3
         mov       cx,bp                    ; omezen¡ poŸtu sektor…
TempRea3:sub       bp,cx                    ; sn¡§en¡ zbyl‚ho poŸtu sektor…

; ------ inicializaŸn¡ vymaz n¡ bufferu

         mov       ch,cl                    ; CH <- poŸet sektor…
         mov       cl,0
         push      cx                       ; poŸet slov
         xor       ax,ax
         xor       di,di
         mov       es,dx                    ; adresa bufferu
         cld
         rep       stosw                    ; vymaz n¡ bufferu
         pop       cx
         shl       cx,1                     ; poŸet bajt… k naŸten¡

; ------ naŸten¡ bloku dat

         push      dx
         push      ds
         mov       ds,dx                    ; adresa bufferu
         xor       dx,dx                    ; offset bufferu
         mov       ah,3fh
         int       21h                      ; naŸten¡ bloku dat
         pop       ds
         pop       dx
         jnc       TempRea5                 ; operace Ÿten¡ OK

; ------ chyba Ÿten¡ ze souboru

TempRea4:mov       si,offset ErrTRTxt
         jmp       Chyba

; ------ pý¡prava pro dalç¡ blok dat

TempRea5:add       word ptr ds:[ReadUTmp],cx ; zvìçen¡ ukazatele v souboru
         adc       word ptr ds:[ReadUTmp+2],0
         add       dx,120*512/16            ; zvìçen¡ adresy bufferu
         or        bp,bp                    ; je dalç¡ m¡sto ?
         jnz       TempRea2                 ; naŸten¡ dalç¡ho bloku dat

; ------ n vrat registr…

TempRea9:pop       es
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TempRead ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ stopy z pýechodn‚ho souboru
; -----------------------------------------------------------------------------

ReadTTrc PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ kopie jednoho sektoru

         mov       dh,0
         mov       dl,ds:[NumSekt]          ; poŸet sektor… na stopu
         mov       es,ds:[BuffDisk]         ; buffer stopy
         xor       di,di                    ; ukl dac¡ adresa do bufferu
ReadTTr2:xor       si,si
         push      ds
         mov       ds,ds:[BuffUkaz]         ; ukazatel v bufferu
         mov       cx,512/2                 ; d‚lka jednoho sektoru
         cld
         rep       movsw                    ; kopie sektoru
         pop       ds

; ------ posun ukazatele k dalç¡mu sektoru

         add       word ptr ds:[BuffUkaz],512/16 ; zvìçen¡ ukazatele v bufferu
         dec       word ptr ds:[BuffCit]    ; sn¡§en¡ Ÿ¡taŸe zbylìch sektor…
         jnz       ReadTTr4                 ; jsou dalç¡ sektory
         call      TempRead                 ; naŸten¡ dalç¡ho bloku dat
ReadTTr4:dec       dx                       ; Ÿ¡taŸ sektor…
         jnz       ReadTTr2                 ; dalç¡ sektor

; ------ n vrat registr…

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

ReadTTrc ENDP

; *****************************************************************************
;
;                                 R…zn‚
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zmØna disku, je-li kl vesa "M" (CY=nebyla kl vesa "M")
; -----------------------------------------------------------------------------

XchgDsk  PROC      NEAR

         cmp       al,"M"                   ; je kl vesa "M" ?
         je        XchgDsk2
         stc
         ret

XchgDsk2:xor       byte ptr ds:[Disk],1     ; zmØna disku
         test      byte ptr ds:[Operace],bit5 ; je identifikace disket ?
         jz        DekTDisk                 ; nen¡ identifikace

         push      ax
         push      cx
         push      dx

         mov       al,ds:[Disk]             ; Ÿ¡slo disku
         mov       cl,al                    ; Ÿ¡slo disku
         mov       ah,10h
         shl       ah,cl                    ; rotace bitu pro zapnut¡ motoru
         or        al,ah
         or        al,4                     ; ýadiŸ uvolnØn, nen¡ pýeruçen¡
         mov       dx,3f2h
         out       dx,al                    ; pýepnut¡ motor…

         pop       dx
         pop       cx
         pop       ax
                                            ; pokraŸuje dek¢dov n¡ oznaŸen¡ !
XchgDsk  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ oznaŸen¡ disku (mus¡ n sledovat za XchgDsk !)
; -----------------------------------------------------------------------------

DekTDisk PROC      NEAR

         push      ax
         mov       al,ds:[Disk]
         add       al,"A"
         mov       ds:[DiskChr1],al         ; oznaŸen¡ mechaniky
         mov       ds:[DiskChr2],al
         mov       ds:[DiskChr3],al
         mov       ds:[DiskChr4],al
         mov       ds:[DiskChr5],al
         mov       ds:[DiskChr6],al
         mov       ds:[DiskChr7],al
         mov       ds:[DiskChr8],al
         mov       ds:[DiskChr9],al
         mov       ds:[DiskChrA],al
         pop       ax
         clc
         ret

DekTDisk ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ velikosti disku
; -----------------------------------------------------------------------------

DekFDsk  PROC      NEAR

         push      di
         mov       di,offset DFormT1
         call      DekFDsk0
         mov       di,offset DFormT2
         call      DekFDsk0
         mov       di,offset DFormT3
         call      DekFDsk0
         mov       di,offset DFormT4
         call      DekFDsk0
         pop       di
         ret

DekFDsk  ENDP

DekFDsk0 PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      es

; ------ pý¡prava registr…

         push      ds
         pop       es
         mov       ax,ds:[CelkSkt0]         ; celkem sektor…
         shr       ax,1                     ; kapacita v KB
         mov       word ptr ds:[di],"  "
         mov       word ptr ds:[di+2],"  "

; ------ dek¢dov n¡ kapacity pro kapacitu < 1 MB

         cmp       ax,1000
         jae       DekFDsk2                 ; je v¡ce ne§ 1 MB
         inc       di
         inc       di
         mov       byte ptr ds:[di+2],"K"   ; £daj v KB
         call      DekNum                   ; dek¢dov n¡ Ÿ¡sla kapacity
         jmp       short DekFDsk8

; ------ dek¢dov n¡ kapacity v MB

DekFDsk2:mov       byte ptr ds:[di+4],"M"   ; £daj v MB
         xor       dx,dx
         mov       cx,1000
         div       cx                       ; poŸet MB
         add       al,"0"
         cld
         mov       ah,"."
         stosw                              ; Ÿ¡slice MB a teŸka
         mov       al,"0"
         stosb
         xor       ax,ax
         xchg      ax,dx                    ; desetiny
         mov       cx,10
         div       cx                       ; stovky
         call      DekNum                   ; dek¢dov n¡ des¡tek KB
         cmp       byte ptr ds:[di],"0"
         jne       DekFDsk8
         mov       byte ptr ds:[di]," "

; ------ n vrat registr…

DekFDsk8:pop       es
         pop       dx
         pop       cx
         pop       ax
         ret

DekFDsk0 ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ Ÿ¡sla diskety
; -----------------------------------------------------------------------------

DekNDisk PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ pý¡prava registr…

         push      ds
         pop       es                       ; ES <- datovì segment
         mov       ax,ds:[NDisket]          ; Ÿ¡slo diskety
         xor       dx,dx
         mov       cx,1000                  ; omezen¡ velikosti Ÿ¡sla
         div       cx
         xchg      ax,dx                    ; AX <- Ÿ¡slo diskety (zarovnan‚)

; ------ dek¢dov n¡ Ÿ¡sla diskety

         mov       di,offset IdntTx21 + 2
         call      DekNum
         mov       di,offset NactTxt2 + 2
         call      DekNum

; ------ n vrat registr…

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

DekNDisk ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ Ÿ¡sla AX do bufferu ES:DI zpØtnØ
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      di

; ------ dek¢dov n¡ Ÿ¡sla

         mov       cx,10
DekNum1: xor       dx,dx
         div       cx                       ; vìpoŸet Ÿ¡slice
         add       dl,"0"                   ; Ÿ¡slice
         mov       es:[di],dl
         dec       di
         or        ax,ax                    ; je Ÿ¡slo ji§ = 0 ?
         jnz       DekNum1                  ; dalç¡ Ÿ¡slice

; ------ n vrat registr…

         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ identifikaŸn¡ho k¢du diskety
; -----------------------------------------------------------------------------

DekEDCI  PROC      NEAR

         push      ax
         push      di
         push      es

         push      ds
         pop       es
         mov       ax,ds:[EDCIdent]         ; identifikaŸn¡ k¢d diskety
         mov       di,offset CtuTxt4
         call      HexWord
         mov       di,offset ZapTxt4
         call      HexWord
         mov       di,offset EDCITxt2
         call      HexWord
         mov       di,offset EDCITxt3
         call      HexWord

         pop       es
         pop       di
         pop       ax
         ret

DekEDCI  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ identifikaŸn¡ho k¢du paritn¡ diskety
; -----------------------------------------------------------------------------

DekEDCP  PROC      NEAR

         push      ax
         push      di
         push      es

         push      ds
         pop       es
         mov       ax,ds:[EDCParit]         ; identifikaŸn¡ k¢d diskety
         mov       di,offset PartTxt1
         call      HexWord
         mov       di,offset VystTxt1
         call      HexWord
         mov       di,offset ZapTxt4
         call      HexWord
         mov       di,offset GenTxt22
         call      HexWord

         pop       es
         pop       di
         pop       ax
         ret

DekEDCP  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kontroln¡ho souŸtu
; -----------------------------------------------------------------------------

DispEDC  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      si
         push      di
         push      es

; ------ dek¢dov n¡ kontroln¡ho souŸtu

         push      ds
         pop       es
         mov       di,offset EDCTxt
         mov       ax,ds:[EDC]              ; kontroln¡ souŸet diskety
         call      HexWord                  ; dek¢dov n¡ slova HEX

; ------ zobrazen¡ hl çen¡

         mov       si,offset NactTxt
         call      StdOut
         call      RepOut                   ; vìstup do protokolu

; ------ n vrat registr…

         pop       es
         pop       di
         pop       si
         pop       ax
         ret

DispEDC  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ slova HEX (AX) do bufferu ES:DI
; -----------------------------------------------------------------------------

HexWord  PROC      NEAR

         xchg      al,ah
         call      HexByte                  ; dek¢dov n¡ bajtu HEX
         xchg      al,ah

HexByte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      HexChr
         pop       ax

HexChr:  push      ax
         and       al,0fh                   ; znak
         cmp       al,9
         jbe       HexChr2
         add       al,7
HexChr2: add       al,"0"
         cld
         stosb
         pop       ax
         ret

HexWord  ENDP

; -----------------------------------------------------------------------------
;        identifikaŸn¡ k¢d diskety (naŸtena stopa 0, strana 0)
; -----------------------------------------------------------------------------

SumEDCI  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      dx
         push      es

; ------ identifikaŸn¡ k¢d

         mov       es,ds:[BuffDisk]         ; buffer stopy
         xor       bx,bx                    ; offset stopy
         mov       al,ds:[NumSekt]          ; poŸet sektor…
         mov       dx,-1                    ; identifikaŸn¡ k¢d diskety
         call      CheckSum                 ; kontroln¡ souŸet stopy
         mov       ds:[EDCIdent],dx         ; identifikaŸn¡ k¢d diskety
         call      DekEDCI                  ; dek¢dov n¡ identifikaŸn¡ho k¢du

; ------ n vrat registr…

         pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

SumEDCI  ENDP

; -----------------------------------------------------------------------------
;        identifikaŸn¡ k¢d paritn¡ diskety (naŸtena stopa 0, strana 0)
; -----------------------------------------------------------------------------

SumEDCP  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      dx
         push      es

; ------ identifikaŸn¡ k¢d

         mov       es,ds:[BuffDat]          ; buffer stopy
         xor       bx,bx                    ; offset stopy
         mov       al,ds:[NumSekt]          ; poŸet sektor…
         mov       dx,-1                    ; identifikaŸn¡ k¢d diskety
         call      CheckSum                 ; kontroln¡ souŸet stopy
         mov       ds:[EDCParit],dx         ; identifikaŸn¡ k¢d par. diskety
         call      DekEDCP                  ; dek¢dov n¡ identifikaŸn¡ho k¢du

; ------ n vrat registr…

         pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

SumEDCP  ENDP

; -----------------------------------------------------------------------------
;        kontroln¡ souŸet EDC cel‚ stopy
; -----------------------------------------------------------------------------

CheckSm0 PROC      NEAR

         push      ax
         push      bx
         push      dx
         push      es

         mov       dx,ds:[EDC]              ; star  hodnota EDC
         xor       bx,bx                    ; poŸ tek dat
         mov       es,ds:[BuffDisk]         ; buffer naŸten‚ stopy
         mov       al,ds:[NumSekt]          ; poŸet sektor… na stopu
         call      CheckSum                 ; kontroln¡ souŸet dat
         mov       ds:[EDC],dx              ; vìstupn¡ hodnota EDC

         pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

CheckSm0 ENDP

; -----------------------------------------------------------------------------
;        Kontroln¡ souŸet EDC dat ES:BX (AL sektor…) z DX -> DX
; -----------------------------------------------------------------------------

CheckSum PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      si
         push      di

; ------ pý¡prava registr…

         mov       ah,al                    ; AH <- poŸet sektor…
         mov       al,0
         shl       ax,1                     ; poŸet bajt… v bufferu
         xchg      ax,di                    ; DI <- poŸet bajt…
         mov       si,bx                    ; SI <- adresa dat
         cld                                ; smØr nahoru

; ------ kontroln¡ souŸet dat

         push      ds
         push      es
         pop       ds

CheckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       CheckSm1                 ; dalç¡ bajt
         pop       ds

; ------ n vrat registr…

         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

CheckSum ENDP

; -----------------------------------------------------------------------------
;        test, zda je pýeruçen¡ operace (CY=je pýeruçen¡)
; -----------------------------------------------------------------------------

TstBreak PROC      NEAR

         test      byte ptr ds:[Param],bit7 ; je pýeruçen¡ ?
         jz        TstBrea2                 ; nen¡ pýeruçen¡
         stc                                ; pý¡znak pýeruçen¡ operace
TstBrea2:ret

TstBreak ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ pý¡znaku pýeruçen¡
; -----------------------------------------------------------------------------

NulBreak PROC      NEAR

         and       byte ptr ds:[Param],not bit7
         ret

NulBreak ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pý¡znaku pýeruçen¡ (nastavuje pý¡znak CY !)
; -----------------------------------------------------------------------------

SetBreak PROC      NEAR

         or        byte ptr ds:[Param],bit7
         stc                                ; pý¡znak pýeruçen¡
         ret

SetBreak ENDP

; *****************************************************************************
;
;                             Data
;
; *****************************************************************************
;þ
Operace  db        0                        ; prov dØn  operace
                                            ;   bit 0: 1=gener. paritn¡ diskety
                                            ;   bit 1: 1=obnoven¡ arch. diskety
                                            ;   bit 2: 1=test vçech disket
                                            ;   bit 3: 1=verifikace diskety
                                            ;   bit 4: 1=modifikace paritn¡ diskety
                                            ;   bit 5: 1=zobrazen¡ ident. k¢du
                                            ;   bit 6: 1=tichì m¢d
                                            ;   bit 7: 1=£spornì m¢d (1 soubor)

Param    db        0                        ; parametry
                                            ;   bit 0: 1=paritn¡ disketa v souboru
                                            ;   bit 1: 1=doplåuje se obn. disk
                                            ;   bit 2: 1=urŸen  paritn¡ disketa
                                            ;   bit 3: 1=nekompatibiln¡ BOOT
                                            ;   bit 4: 1=je paritn¡ disketa
                                            ;   bit 5: 1=byla ji§ prvn¡ disketa
                                            ;   bit 6: 1=pýedefinov no INT 1Eh
                                            ;   bit 7: 1=je pýeruçen¡ operace

EDC      dw        -1                       ; stýadaŸ kontroln¡ho souŸtu diskety
EDCIdent dw        -1                       ; identifikaŸn¡ CRC diskety
EDCParit dw        -1                       ; identifikaŸn¡ CRC paritn¡ diskety

AktHlas  dw        InitTxt                  ; adresa aktu ln¡ho hl çen¡ diskety

NDisket  dw        0                        ; Ÿ¡taŸ Ÿ¡sla disket

UspechS  dw        0                        ; Ÿ¡taŸ nulovìch sektor… pýi testu

; ------ buffery

BuffBeg  dw        0                        ; adresa zaŸ tku bufferu

BuffDisk dw        0                        ; adresa bufferu pracovn¡ stopy
BuffDskV dw        0                        ; adresa bufferu verifikovan‚ stopy

BuffDat  dw        0                        ; zaŸ tek datov‚ho bufferu
BuffUkaz dw        0                        ; ukazatel adresy v bufferu
BuffCit  dw        0                        ; Ÿ¡taŸ zbylìch sektor… v bufferu
BuffMax  dw        0                        ; maxim ln¡ poŸet sektor… v bufferu

; ------ parametry diskety

Disk     db        0                        ; Ÿ¡slo disku

NumStop  db        40                       ; poŸet stop
NumStran db        2                        ; poŸet stran
NumSekt  db        9                        ; poŸet sektor… na stopu
CelkSekt dw        9*2*40                   ; celkem sektor… na disku

NumStop0 db        40                       ; poŸet stop (naŸtenì)
NumStrn0 db        2                        ; poŸet stran (naŸtenì)
NumSekt0 db        9                        ; poŸet sektor… na stopu (naŸtenì)
CelkSkt0 dw        9*2*40                   ; celkem sektor… na disku (naŸtenì)

; ------ pýechodnì soubor

RepIdnt  dw        0                        ; identifik tor souboru hl çen¡
OutpIdnt dw        0                        ; identifik tor vìstupn¡ho souboru
TempIdnR dw        0                        ; pýechodnì soubor pro Ÿten¡ (z pis)
TempIdnW dw        0                        ; pýechodnì soubor pro z pis

TempFil0 db        'SAFEDISK.$T$',0         ; pýechodnì soubor pro Ÿten¡ (z pis)
                                            ;  pro Ÿten¡ koncovì znak $ popý. _
                                            ;  pro z pis pý¡pona @ popý. %

ReadUTmp dd        0                        ; Ÿtec¡ ukazatel pýechodn‚ho souboru
WritUTmp dd        0                        ; z pisovì ukazatel pýechod. souboru

; ------ texty

UvTxt    dw        UvTxt0-UvTxt-2
         db        'SAFEDISK V1.00 - zabezpeceni archivnich disket; (c) Miroslav Nemecek',13,10
UvTxt0   label     byte

HelpTxt  dw        HelpTxt0-HelpTxt-2
         db        13,10
         db        'Zadejte:  SAFEDISK  [ A: | B: ] { G | R | M | T | V | I } [ Q ] [ F soubor ]',13,10
         db        '           A: (B:) .... operace se provadi v mechanice A: (B:)',13,10
         db        '           G .......... vygenerovani zabezpecovaci paritni diskety',13,10
         db        '           R .......... obnoveni poskozene diskety archivu',13,10
         db        '           M .......... modifikace paritni diskety (pridani/vypusteni diskety)',13,10
         db        '           T .......... test celistvosti skupiny disket archivu',13,10
         db        '           V .......... verifikace a kontrolni soucet diskety',13,10
         db        '           I .......... zobrazeni identifikacniho kodu diskety',13,10
         db        '           Q .......... tichy mod, potlaceni zobrazeni napovedy',13,10
         db        '           S .......... usporny mod (mene bezpecny - 1 prechodny soubor)',13,10
         db        '           F soubor ... paritni disketa ulozena v zadanem souboru',13,10
         db        13,10
         db        '     Program  SAFEDISK zabezpecuje diskety archivu vygenerovanim paritni',13,10
         db        '     zabezpecovaci  diskety.  Paritni disketa je bitovou logickou funkci',13,10
         db        '     XOR  vsech  disket  archivu. Po vzniku chyby na kterekoliv z disket',13,10
         db        '     (nebo i vice disketach soucasne) lze poskozenou disketu opet zpetne',13,10
         db        '     vygenerovat pomoci paritni diskety a vsech zbyvajicich disket.',13,10
         db        '     Do souboru SAFEDISK.REP se zapisuje protokol o vsech operacich.',13,10
         db        13,10
HelpTxt0 label     byte

PrerTxt  dw        PrerTxt0-PrerTxt-2
         db        '*PRERUSENO*',13,10
PrerTxt0 label     byte

Help2Txt dw        Help2Tx0-Help2Txt-2
         db        'Chyba zadani parametru !',13,10
Help2Tx0 label     byte

MemTxt   dw        MemTxt0-MemTxt-2
         db        'CHYBA - nedostatek pameti !',13,10
MemTxt0  label     byte

DatTxt   dw        DatTxt1-DatTxt-2
         db        ' 0.00.   0   0:00:00 '
DatTxt1  db        130 dup(0)

DatTxt0  dw        5
         db        5 dup(" ")

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
         db        'M',36
         db        'P',49

GenTxt1  dw        GenTxt10-GenTxt1-2
         db        13,'Vlozte disketu do '
DiskChr1 db        'A: ... (D)alsi, (M)echanika, (P)reruseni'
GenTxt10 label     byte

GenMnu2  db        4
         db        'D',27
         db        'Z',36
         db        'M',56
         db        'P',69

GenTxt2  dw        GenTxt20-GenTxt2-2
         db        13,'Vlozte disketu do '
DiskChr8 db        'A: ... (D)alsi, (Z)apis (kod='
GenTxt22 db        'FFFF), (M)echanika, (P)reruseni'
GenTxt20 label     byte

PartMnu  db        3
         db        'Z',46
         db        'N',55
         db        'P',65

PartTxt  dw        PartTxt0-PartTxt-2
         db        13,'Bude zapsana PARITNI disketa (kod='
PartTxt1 db        'FFFF) ... (Z)apis, (N)avrat, (P)reruseni'
PartTxt0 label     byte

ParitTxt dw        ParitTx0-ParitTxt-2
         db        13,10
         db        'Paritni disketa vygenerovana. Upozorneni - paritni disketu',13,10
         db        'nelze pouzit v systemu DOS (oznacuje disketu jako vadnou).',13,10
ParitTx0 label     byte

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

ObnMnu1  db        3
         db        'D',35
         db        'M',43
         db        'P',56

ObnTxt1  dw        ObnTxt10-ObnTxt1-2
         db        13,'Vlozte PARITNI disketu do '
DiskChr7 db        'A: ... (D)ale, (M)echanika, (P)reruseni'
ObnTxt10 label     byte

VystMnu  db        3
         db        'Z',47
         db        'M',56
         db        'P',69

VystTxt  dw        VystTxt0-VystTxt-2
         db        13,'Bude zapsana OBNOVENA disketa (kod='
VystTxt1 db        'FFFF) ... (Z)apis, (M)echanika, (P)reruseni'
VystTxt0 label     byte

OprvMnu  db        3
         db        'D',41
         db        'Z',49
         db        'P',58

OprvTxt  dw        OprvTxt0-OprvTxt-2
         db        13
         db        'Vlozte OBNOVOVANOU disketu k doplneni: (D)ale, (Z)apis, (P)rerusit'
OprvTxt0 label     byte

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

; ------ verifikace diskety

Tst1Txt  dw        Tst1Txt0-Tst1Txt-2
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
Tst1Txt0 label     byte

; ------ identifikaŸn¡ k¢d diskety

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

IdntMnu1 db        3
         db        'D',36
         db        'M',45
         db        'P',58

IdntTxt1 dw        IdntTx10-IdntTxt1-2
         db        13,'Vlozte disketu do '
DiskChr3 db        'A: a zvolte ... (D)alsi, (M)echanika, (P)reruseni'
IdntTx10 label     byte

IdntTxt2 dw        IdntTx20-IdntTxt2-2
IdntTx21 db        '  1 ... '
DiskChr9 db        'A:'
IdntTx22 db        '           '
         db        ' ('
DFormT1  db        '360 KB) ... identifikacni kod='
EDCITxt2 db        'FFFF',13,10
IdntTx20 label     byte

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

TstVMnu2 db        4
         db        'D',27
         db        'K',36
         db        'M',52
         db        'P',65

TstVTxt2 dw        TstVTx20-TstVTxt2-2
         db        13,'Vlozte disketu do '
DiskChrA db        'A: ... (D)alsi, (K)onec ('
DiskUsp  db        '  0%), (M)echanika, (P)reruseni'
TstVTx20 label     byte

TstV3Txt dw        TstV3Tx0-TstV3Txt-2
         db        'Skupina archivu je zabezpecena paritni disketou na 100%.',13,10
TstV3Tx0 label     byte

TstV4Txt dw        TstV4Tx0-TstV4Txt-2
         db        'Paritni disketa NEZABEZPECUJE testovanou skupinou archivu.',13,10
TstV4Tx0 label     byte

; ------ hl çen¡ o inicializaci parametr… diskety

InitTxt  dw        InitTxt0-InitTxt-2
         db        13,'- inicializuji parametry diskety...',13
InitTxt0 label     byte

; ------ hl çen¡ o naŸ¡t n¡ diskety

CtuTxt   dw        CtuTxt0-CtuTxt-2
         db        13,'- ctu disketu  '
DiskChr4 db        'A:'
CtuTxt1  db        '           '
         db        ' ('
DFormT2  db        '360 KB, kod='
CtuTxt4  db        'FFFF) .... VALEC '
CtuTxt2  db        '00, STRANA '
CtuTxt3  db        '0',13
CtuTxt0  label     byte

; ------ hl çen¡ o z pisu diskety

ZapTxt   dw        ZapTxt0-ZapTxt-2
         db        13,'- zapisuji  '
DiskChr6 db        'A:'
ZapTxt1  db        '           '
         db        ' ('
DFormT3  db        '360 KB, kod='
ZapTxt4  db        'FFFF) .... VALEC '
ZapTxt2  db        '00, STRANA '
ZapTxt3  db        '0',13
ZapTxt0  label     byte

; ------ zobrazen¡ parametr… diskety

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

;; ------ nekompatibiln¡ form t diskety
;
;FormTxtM db        2
;         db        'O',42
;         db        'P',54
;
;FormTxt  dw        FormTxt0-FormTxt-2
;         db        13
;         db        'CHYBA - nekompatibilni format diskety:  (O)pakovat, (P)rerusit'
;FormTxt0 label     byte

; ------ form t diskety nen¡ shodnì

FrmSTxtM db        2
         db        'O',30
         db        'P',52

FrmSTxt  dw        FrmSTxt0-FrmSTxt-2
         db        13
         db        'Format diskety neni shodny: (O)pakovat, (P)rerusit'
FrmSTxt0 label     byte

; ------ chyba Ÿten¡ BOOT sektoru diskety

ErrBTxtM db        3
         db        'O',37
         db        'D',49
         db        'P',57

ErrBTxt  dw        ErrBTxt0-ErrBTxt-2
         db        13
         db        'CHYBA cteni BOOT sektoru diskety:  (O)pakovat, (D)ale, (P)rerusit'
ErrBTxt0 label     byte

; ------ chyba Ÿten¡

ErrRTxtM db        3
         db        'O',46
         db        'D',58
         db        'P',66

ErrRTxt  dw        ErrRTxt0-ErrRTxt-2
         db        13
ErrRTxt1 db        'CHYBA cteni (VALEC 00/STRANA 0/SEKTOR 00):  (O)pakovat, (D)ale, (P)rerusit'
ErrRTxt0 label     byte

; ------ chyba z pisu - kr tkì

Er2WMnu  db        4
         db        'O',37
         db        'D',49
         db        'S',57
         db        'P',68

Er2WTxt  dw        Er2WTxt0-Er2WTxt-2
         db        13
Er2WTxt1 db        'CHYBA zapisu (VALEC 00/STRANA 0):  (O)pakovat, (D)ale, (S)ektory, (P)rerusit'
Er2WTxt0 label     byte

; ------ chyba z pisu

ErrWMnu  db        3
         db        'O',47
         db        'D',59
         db        'P',67

ErrWTxt  dw        ErrWTxt0-ErrWTxt-2
         db        13
ErrWTxt1 db        'CHYBA zapisu (VALEC 00/STRANA 0/SEKTOR 00):  (O)pakovat, (D)ale, (P)rerusit'
ErrWTxt0 label     byte

; ------ v mechanice nen¡ disketa

ErrTMnu  db        2
         db        'O',33
         db        'P',45

ErrTTxt  dw        ErrTTxt0-ErrTTxt-2
         db        13
         db        'V mechanice '
DiskChr2 db        'A: neni disketa !  (O)pakovat, (P)rerusit'
ErrTTxt0 label     byte

; ------ disketa chr nØna proti z pisu

ErrROMnu db        2
         db        'O',35
         db        'P',47

ErrROTxt dw        ErrROTx0-ErrROTxt-2
         db        13
         db        'Disketa chranena proti zapisu !  (O)pakovat, (P)rerusit'
ErrROTx0 label     byte

; ------ hl çen¡ pro pýechodnì soubor

ErrOTxt  dw        ErrOTxt0-ErrOTxt-2
         db        'CHYBA - nelze vytvorit prechodny soubor !',13,10
ErrOTxt0 label     byte

ErrTRTxt dw        ErrTRTx0-ErrTRTxt-2
         db        'CHYBA cteni z prechodneho souboru !',13,10
ErrTRTx0 label     byte

ErrORTxt dw        ErrTRTx0-ErrTRTxt-2
         db        'CHYBA cteni ze souboru paritni diskety !',13,10
ErrORTx0 label     byte

ErrTWTxt dw        ErrTWTx0-ErrTWTxt-2
         db        'CHYBA zapisu do prechodneho souboru !',13,10
ErrTWTx0 label     byte

ErrTWDTx dw        ErrTWDT0-ErrTWDTx-2
         db        'CHYBA zapisu do prechodneho souboru - nedostatek mista na disku !',13,10
ErrTWDT0 label     byte

ErrOWTxt dw        ErrTWTx0-ErrTWTxt-2
         db        'CHYBA zapisu do souboru paritni diskety !',13,10
ErrOWTx0 label     byte

MazTTxt  dw        80                       ; text pro vymaz n¡ ý dku
         db        13
MazTTxt1 db        78 dup(" "), 13          ; - t‚§ jako pr zdn  jmenovka

; ------ tabulky (zachovat sudou adresu !)

         EVEN                               ; zarovn n¡ kv…li z sobn¡ku

Old1E    dd        ?                        ; p…vodn¡ adresa INT 1Eh

Tab1E    label     byte                     ; tabulka INT 1Eh
         db        ?                        ; 0: krokov n¡ motoru
         db        ?                        ; 1: spuçtØn¡ pý¡tlaku hlavy
MotorOff db        ?                        ; 2: Ÿas pro vypnut¡ motoru
SektSize db        ?                        ; 3: velikost sektoru
LastSekt db        ?                        ; 4: posledn¡ sektor na stopØ
         db        ?                        ; 5: mezisektorov  mezera Ÿten¡
         db        ?                        ; 6: d‚lka pýen çenìch dat
         db        ?                        ; 7: mezisektorov  mezera form t.
         db        ?                        ; 8: pln¡c¡ znak form tov n¡
         db        ?                        ; 9: Ÿas pro ust len¡ hlav
         db        ?                        ; 10: Ÿas pro spuçtØn¡ motoru
         db        ?                        ; (11: posledn¡ stopa)
         db        ?                        ; (12: pýenosov  rychlost)
         db        ?                        ;  ... zarovn n¡ na sudou adresu
Tab1E0   label     byte

TrckMap  db        (MAXSEKT+1) AND (NOT 1) dup(?) ; mapa sektor… stopy (0=OK)

ErrMap   db        ((MAXTRACK*MAXSEKT*MAXSIDE+16)/8) AND (NOT 1) dup(?) ; mapa vadnìch sektor…
ErrMap0  label     byte

RepFile  db        128 dup(?)               ; soubor hl çen¡
OutpFile db        128 dup(?)               ; jm‚no vìstupn¡ho souboru
TempFilR db        128 dup(?)               ; pýechodnì soubor - Ÿten¡ (i z pis)
TempFilW db        128 dup(?)               ; pýechodnì soubor - z pis

         dw        200h dup(?)              ; z sobn¡k
Zasobnik label     word                     ; konec z sobn¡ku

Code     ENDS
         END       Start

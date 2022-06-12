
; *****************************************************************************
;
;                               G M E N U
;
;                           Grafick‚ menu - VGA
;
; *****************************************************************************

SIRX     EQU       320/5                    ; ¨¡©ka ikony (64 bod–)
VYSY     EQU       200/5                    ; v˜¨ka ikony (40 bod–)

BuffSize EQU       5000                     ; velikost bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ kontrola pamˆti

Start:   cmp       sp,offset Konec + 200h   ; je dost pamˆti ?
         jae       Start2                   ; pamˆŸ je OK

; ------ chyba pamˆti

         mov       dx,offset MemTxt
Start1:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4cffh
         int       21h

; ------ £schova videom¢du

Start2:  mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         mov       ds:[OldVMod],al          ; £schova videom¢du

; ------ inicializace videom¢du

         mov       ax,13h
         call      Int10                    ; inicializace videom¢du
         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         mov       dx,offset CardTxt        ; text - chyba karty
         cmp       al,13h                   ; je ji‘ videom¢d OK ?
         jne       Start1                   ; chyba grafick‚ karty

; ------ inicializace palet

         push      ds
         pop       es
         mov       di,offset Palety
         xor       bx,bx                    ; BH = zelen , BL = ‡erven 
         mov       al,0                     ; AL = modr 
         cld
         mov       cx,31
Start21: mov       ds:[di],bx               ; ‡erven  a zelen 
         inc       di
         inc       di
         stosb                              ; modr 
         dec       cx
         jnz       Start22

         mov       word ptr ds:[di],63*256 + 63
         inc       di
         inc       di
         mov       byte ptr ds:[di],63
         inc       di

Start22: add       al,10
         cmp       al,60
         jb        Start21
         mov       al,0
         add       bh,9
         cmp       bh,63
         jb        Start21
         mov       bh,0
         add       bl,10
         cmp       bl,60
         jb        Start21

         mov       al,63
         mov       cx,3*3
         rep       stosb

         mov       dx,offset Palety
         mov       cx,256
         xor       bx,bx
         mov       ax,1012h
         call      Int10                    ; nastaven¡ palet VGA

; ------ instalace INT 23h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h

; ------ instalace INT 24h

         mov       dx,offset INT24
         mov       ax,2524h
         int       21h

; ------ inicializace domovsk‚ho adres ©e

         mov       ds,ds:[2ch]              ; segment prost©ed¡
         xor       si,si
         xor       ax,ax
         cld
Start23: inc       si
         cmp       ax,ds:[si-1]
         jne       Start23
         add       si,3                     ; za‡ tek textu cesty
         mov       di,offset Soubor
Start24: mov       dx,di                    ; £schova konce cesty
Start25: lodsb
         stosb
         cmp       al,":"
         je        Start24                  ; oddˆlova‡ disku
         cmp       al,"\"                   ; oddˆlova‡ cesty ?
         je        Start24                  ; oddˆlova‡ cesty
         cmp       al,0
         jne       Start25                  ; dal¨¡ znak
         push      cs
         pop       ds                       ; DS <- CS
         mov       di,dx
         mov       si,offset Soubor0
         mov       cx,offset(Soubor1-Soubor0)
         rep       movsb                    ; p©enos jm‚na souboru
         sub       di,7
         mov       ds:[AdrSoub],di          ; adresa konce ‡¡sel souboru

; ------ vymaz n¡ obrazovky

Start3:  mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamˆti
         mov       cx,320*200/2
         mov       ax,31*256 + 31           ; b¡l  barva
         xor       di,di
         rep       stosw                    ; vymaz n¡ obrazovky

; ------ zobrazen¡ v¨ech obr zk–

         mov       bx,1                     ; ‡¡ta‡ soubor–
Start4:  call      ReadFile
         jc        Start48                  ; chyba p©¡stupu k souboru
         call      DispFile                 ; zobrazen¡ souboru
         mov       byte ptr ds:[bx+MapFil-1],1 ; p©¡znak, ‘e je soubor
         cmp       byte ptr ds:[Kurzor],-1  ; byl ji‘ kurzor ?
         jne       Start48                  ; byl ji‘ kurzor
         mov       ds:[Kurzor],bx           ; pozice kurzoru
Start48: inc       bx                       ; zv˜¨en¡ ukazatele soubor–
         cmp       bl,5*5                   ; jsou ji‘ v¨echny soubory ?
         jbe       Start4                   ; dal¨¡ soubor

; ------ chyba - nebyl ‘ dn˜ soubor

         cmp       byte ptr ds:[Kurzor],-1  ; byl nˆjak˜ soubor ?
         jne       Start49                  ; byl nˆjak˜ soubor
         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du
         mov       dx,offset FndTxt         ; chyba - nebyl soubor
         jmp       Start1                   ; chyba

; ------ instalace my¨i

Start49: call      InitMous                 ; inicializace my¨i

; ------ zobrazen¡ kurzoru

Start5:  call      DispKur                  ; zobrazen¡ kurzoru
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       bp,ds:[46ch]             ; syst‚mov˜ ‡asova‡
         pop       ds

; ------ obsluha blik n¡ kurzoru

Start52: sti
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; syst‚mov˜ ‡asova‡
         pop       ds
         sub       ax,bp                    ; uplynul˜ ‡as
         cmp       ax,3                     ; asi tak rychlost blik n¡
         jae       Start5                   ; zmˆna kurzoru

; ------ test, zda je tla‡¡tko my¨i

         test      byte ptr ds:[ParMouse],1 ; je my¨ nainstalov na ?
         jz        Start58                  ; my¨ nen¡ nainstalov na
         mov       al,3
         call      Mouse                    ; poskytnut¡ pozice my¨i
         test      bl,3                     ; je lev‚ nebo prav‚ tla‡¡tko ?
         jz        Start58                  ; nen¡ ‘ dn‚ tla‡¡tko
         mov       ax,11bh                  ; n hradn¡ kl vesa ESC
         test      bl,2                     ; je prav‚ tla‡¡tko ?
         jnz       Start6                   ; je prav‚ tla‡¡tko - jako ESC

; ------ v˜po‡et sou©adnic my¨i

         xor       ax,ax
         xchg      ax,dx                    ; AX <- © dek
         mov       bx,VYSY                  ; po‡et linek na © dek
         div       bx                       ; p©epo‡et linek na © dek
         mov       bl,5                     ; po‡et pozic na © dek
         mul       bl                       ; v˜po‡et kurzoru
         xchg      ax,bx                    ; BX <- kurzor
         xchg      ax,cx                    ; AX <- pozice
         xor       dx,dx
         mov       cx,SIRX                  ; po‡et bod– na linku
         div       cx                       ; v˜po‡et pozice
         add       bx,ax                    ; BX <- kurzor
         inc       bx                       ; korekce kurzoru
         cmp       byte ptr ds:[bx+MapFil-1],0 ; je to platn  pozice ?
         je        Start58                  ; nen¡ to platn  pozice
         call      KurzOff                  ; vypnut¡ kurzoru
         mov       byte ptr ds:[Kurzor],bl  ; nov  pozice kurzoru
         call      DispKur                  ; zapnut¡ kurzoru
         jmp       Start9                   ; konec voleb

; ------ ‡ek n¡ na stisk kl vesy

Start58: mov       ah,0bh
         int       21h                      ; test p©ipravenosti kl vesy
         or        al,al                    ; je p©ipraven znak z kl vesnice ?
         jz        Start52                  ; nen¡ p©ipraven znak z kl vesnice

; ------ vstup znaku z kl vesnice

         mov       ah,8
         int       21h                      ; vstup znaku z kl vesnice
         mov       ah,0
         cmp       al,0                     ; je roz¨¡©en˜ k¢d kl vesy ?
         jne       Start6                   ; nen¡ roz¨¡©en˜ k¢d kl vesy
         mov       ah,8
         int       21h                      ; vstup SCAN k¢du kl vesy
         mov       ah,al
         mov       al,0

; ------ p©¡prava parametr– kurzoru

Start6:  mov       bx,ds:[Kurzor]           ; sou‡asn˜ kurzor
         push      ax
         mov       ax,bx                    ; AX <- kurzor
         dec       ax                       ; korekce kurzoru
         mov       dl,5                     ; po‡et pozic na © dek
         div       dl                       ; v˜po‡et © dku a pozice
         mov       al,ah                    ; AL <- pozice
         xchg      ax,dx                    ; DL, DH <- pozice
         pop       ax

; ------ kurzor vpravo

         cmp       ax,4d00h
         jne       Start61
         call      KurzNxt                  ; nalezen¡ dal¨¡ho kurzoru
Start60: jnc       Start602
         jmp       Start52                  ; n vrat
Start602:call      KurzOff                  ; vypnut¡ kurzoru
         mov       byte ptr ds:[Kurzor],bl  ; nov  pozice kurzoru
         jmp       Start5

; ------ kurzor vlevo

Start61: cmp       ax,4b00h
         jne       Start62
         call      KurzPred                 ; nalezen¡ p©ede¨l‚ho kurzoru
         jmp       short Start60

; ------ prvn¡ polo‘ka HOME

Start62: cmp       ax,4700h
         jne       Start63
         call      KurzPred                 ; nalezen¡ p©ede¨l‚ pozice
         jc        Start60                  ; nen¡ dal¨¡ pozice
Start622:call      KurzPred
         jnc       Start622                 ; nalezen¡ prvn¡ pozice
         clc
         jmp       short Start60

; ------ posledn¡ polo‘ka END

Start63: cmp       ax,4f00h
         jne       Start64
         call      KurzNxt                  ; nalezen¡ dal¨¡ pozice
         jc        Start60                  ; nen¡ dal¨¡ pozice
Start632:call      KurzNxt
         jnc       Start632                 ; nalezen¡ posledn¡ pozice
         clc
         jmp       short Start60

; ------ © dek dol–

Start64: cmp       ax,5000h
         jne       Start65
Start642:add       bx,5                     ; adresa dal¨¡ho © dku
         cmp       bx,5*5+1                 ; je ji‘ konec ?
         cmc
         jc        Start60                  ; je ji‘ konec
         call      SrcKurz                  ; nalezen¡ bl¡zk‚ho kurzoru
         jc        Start642                 ; nen¡ - dal¨¡ © dek
         jmp       short Start60

; ------ © dek nahoru

Start65: cmp       ax,4800h
         jne       Start66
Start652:sub       bx,5
         jc        Start60                  ; konec
         stc
         je        Start60                  ; konec
         call      SrcKurz                  ; nalezen¡ bl¡zk‚ho kurzoru
         jc        Start652                 ; nen¡ - dal¨¡ © dek
         jmp       short Start60

; ------ ukon‡en¡ volby ENTER

Start66: cmp       al,13
         je        Start9                   ; konec volby ENTER

; ------ p©eru¨en¡ volby ESC

         cmp       al,27
         je        INT23                    ; p©eru¨en¡ volby ESC
         jmp       Start52                  ; dal¨¡ kl vesa

; ------ p©eru¨en¡ programu Ctrl-Break

INT23:   mov       byte ptr ds:[Kurzor],-2  ; p©¡znak p©eru¨en¡ programu

; ------ n vrat videom¢du

Start9:  call      MouseOff                 ; vypnut¡ kurzoru my¨i
         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du

; ------ n vrat z programu

         mov       al,byte ptr ds:[Kurzor]  ; n vratov˜ k¢d
         mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        obsluha INT 24h
; -----------------------------------------------------------------------------

Int24    PROC      FAR

         mov       al,0
         iret

Int24    ENDP

; -----------------------------------------------------------------------------
;        instalace my¨i
; -----------------------------------------------------------------------------

InitMous PROC      NEAR

; ------ test adresy INT 33h

         mov       ax,3533h
         int       21h                      ; poskytnut¡ adresy INT 33h
         cmp       bx,-2
         je        IniMous9                 ; chyba
         mov       ax,es
         cmp       ax,70h
         jb        IniMous9

; ------ test instalace my¨i

         xor       ax,ax
         call      Mouse
         inc       ax
         jnz       IniMous9                 ; nen¡ my¨
         or        byte ptr ds:[ParMouse],1 ; p©¡znak instalace my¨i

; ------ definice okna pro my¨

         xor       cx,cx
         mov       dx,640-1
         mov       al,7
         call      Mouse
         xor       cx,cx
         mov       dx,200-1
         mov       al,8
         call      Mouse

; ------ definice obr zku my¨i

         mov       al,9
         xor       bx,bx
         xor       cx,cx
         mov       dx,offset KurzMous       ; obr zek kurzoru my¨i
         push      ds
         pop       es
         call      Mouse

; ------ definice polohy kurzoru my¨i

         mov       cx,640/2
         mov       dx,200/2
         mov       al,4
         call      Mouse                    ; nastaven¡ pozice kurzoru my¨i

; ------ zapnut¡ kurzoru my¨i

         call      MouseOn                  ; zapnut¡ kurzoru my¨i

IniMous9:ret

InitMous ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOn  PROC      NEAR

         test      byte ptr ds:[ParMouse],1 ; je my¨ nainstalov na ?
         jz        MouseOn2                 ; my¨ nen¡ nainstalov na
         push      ax
         mov       al,1
         call      Mouse                    ; zapnut¡ kurzoru
         pop       ax
MouseOn2:ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

         test      byte ptr ds:[ParMouse],1 ; je my¨ nainstalov na ?
         jz        MouseOf2                 ; my¨ nen¡ nainstalov na
         push      ax
         mov       al,2
         call      Mouse                    ; zapnut¡ kurzoru
         pop       ax
MouseOf2:ret

MouseOff ENDP

; -----------------------------------------------------------------------------
;        obsluha my¨i
; -----------------------------------------------------------------------------

Mouse    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         sti
         mov       ah,0
         int       33h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Mouse    ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ nejbli‘¨¡ho kurzoru BX (DL,DH=pozice, CY=nen¡)
; -----------------------------------------------------------------------------

SrcKurz  PROC      NEAR

         push      ax
         push      dx
         push      bx

; ------ test pozice pod kurzorem

         mov       ax,bx                    ; AX <- pozice kurzoru
         cmp       byte ptr ds:[bx+MapFil-1],0
         jne       SrcKurz8                 ; je pozice OK

; ------ test pozice p©ed kurzorem

SrcKurz2:or        dl,dl                    ; je ji‘ po‡ tek © dku ?
         jz        SrcKurz3                 ; je ji‘ po‡ tek © dku
         dec       bx
         dec       dx
         cmp       byte ptr ds:[bx+MapFil-1],0
         jne       SrcKurz8

; ------ test pozice za kurzorem

SrcKurz3:cmp       dh,4
         jae       SrcKurz4                 ; je ji‘ konec © dku
         xchg      ax,bx
         inc       dh
         inc       bx
         cmp       byte ptr ds:[bx+MapFil-1],0
         jne       SrcKurz8
         xchg      ax,bx

; ------ test, zda je dal¨¡ pozice

SrcKurz4:or        dl,dl
         jnz       SrcKurz2
         cmp       dh,4
         jb        SrcKurz2

         pop       bx
         pop       dx
         pop       ax
         stc
         ret

; ------ pozice nalezena OK

SrcKurz8:add       sp,2
         pop       dx
         pop       ax
         clc
         ret

SrcKurz  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ dal¨¡ho kurzoru BX (CY=nen¡)
; -----------------------------------------------------------------------------

KurzNxt  PROC      NEAR

         push      bx
KurzNxt1:cmp       bx,offset 5*5
         jae       KurzNxt3
         inc       bx
         cmp       byte ptr ds:[bx+MapFil-1],0
         je        KurzNxt1

         add       sp,2
         clc
         ret

KurzNxt3:pop       bx
         stc
         ret

KurzNxt  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ p©ede¨l‚ho kurzoru BX (CY=nen¡)
; -----------------------------------------------------------------------------

KurzPred PROC      NEAR

         push      bx
KurzPre1:dec       bx
         jnz       KurzPre2
         pop       bx
         stc
         ret

KurzPre2:cmp       byte ptr ds:[bx+MapFil-1],0
         je        KurzPre1
         add       sp,2
         clc
         ret

KurzPred ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         cmp       byte ptr ds:[ParKurz],0  ; je kurzor zapnut ?
         jne       DispKur                  ; kurzor je zapnut
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru
; -----------------------------------------------------------------------------

DispKur  PROC      NEAR

         call      MouseOff                 ; vypnut¡ kurzoru my¨i

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ adresa kurzoru ve videopamˆti

         mov       ax,ds:[Kurzor]           ; AX <- ‡¡slo kurzoru
         dec       ax                       ; korekce ‡¡sla souboru
         mov       bl,5                     ; dˆlitel
         div       bl                       ; v˜po‡et © dku a pozice
         mov       bh,0
         mov       bl,al                    ; £schova © dku
         mov       al,SIRX                  ; ¨¡©ka obr zku v bajtech
         mul       ah                       ; v˜po‡et po‡ te‡n¡ho offsetu
         xchg      ax,di                    ; DI <- po‡ te‡n¡ offset
         mov       ax,320*VYSY              ; po‡et bajt– na © dek
         mul       bx                       ; p©epo‡et © dk– na offset
         add       di,ax                    ; DI <- po‡ te‡n¡ adresa obr zku
         mov       ax,0a000h
         mov       es,ax

; ------ horn¡ linka

         push      di
         mov       cl,SIRX
         call      InvVGAH                  ; horizont ln¡ linka
         add       di,2*320+2
         mov       cl,SIRX-4
         call      InvVGAH
         pop       di

; ------ lev˜ okraj

         push      di
         add       di,320
         mov       cl,VYSY-2
         call      InvVGAV
         add       di,2*320+2
         mov       cl,VYSY-6
         call      InvVGAV
         pop       di

; ------ prav˜ okraj

         push      di
         add       di,320 + SIRX-1
         mov       cl,VYSY-2
         call      InvVGAV
         add       di,2*320-2
         mov       cl,VYSY-6
         call      InvVGAV
         pop       di

; ------ doln¡ linka

         add       di,(VYSY-1)*320
         mov       cl,SIRX
         call      InvVGAH
         sub       di,2*320-2
         mov       cl,SIRX-4
         call      InvVGAH

; ------ zmˆna p©¡znaku kurzoru

         xor       byte ptr ds:[ParKurz],1  ; zmˆna p©¡znaku kurzoru

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax

         call      MouseOn                  ; zapnut¡ kurzoru my¨i
         ret

DispKur  ENDP

; -----------------------------------------------------------------------------
;  inverze horizont ln¡ linky (ES:DI=adresa, CX=d‚lka, BH=maska L, BL=maska R)
; -----------------------------------------------------------------------------

InvVGAH  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      di

         cli                                ; z kaz p©eru¨en¡
         mov       ch,0

InvVGAH1:xor       byte ptr es:[di],31
         inc       di
         loop      InvVGAH1

         sti                                ; povolen¡ p©eru¨en¡

         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

InvVGAH  ENDP

; -----------------------------------------------------------------------------
;        inverze vertik ln¡ linky (ES:DI=adresa, CX=v˜¨ka, BH=maska)
; -----------------------------------------------------------------------------

InvVGAV  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      di
         mov       ch,0

         cli                                ; z kaz p©eru¨en¡
                                          ;* volba z pisov˜ch rovin
InvVGAV1:xor       byte ptr es:[di],31
         add       di,320
         loop      InvVGAV1
                                          ;* nastaven¡ z pisov‚ho m¢du
         sti                                ; povolen¡ p©eru¨en¡

         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

InvVGAV  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ souboru BX do bufferu
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ p©¡prava ‡¡sla souboru

         xchg      ax,bx
         mov       bx,ds:[AdrSoub]          ; adresa ‡¡sla souboru
         aam
         add       ax,"00"
         xchg      al,ah
         mov       ds:[bx],ax               ; ‡¡slo souboru ASCII

; ------ otev©en¡ souboru pro ‡ten¡

         mov       dx,offset Soubor         ; zadan˜ soubor k zobrazen¡
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        ReadFil3                 ; chyba - soubor nenalezen
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ na‡ten¡ souboru do bufferu

         mov       dx,offset Buffer         ; adresa bufferu
         mov       cx,BuffSize              ; velikost bufferu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do pamˆti

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

; ------ n vrat registr–

ReadFil3:pop       bx
         ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ souboru BX
; -----------------------------------------------------------------------------

DispFile PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ ukl dac¡ adresa do videopamˆti

         xchg      ax,bx                    ; AX <- ‡¡slo souboru
         dec       ax                       ; korekce ‡¡sla souboru
         mov       bl,5                     ; dˆlitel
         div       bl                       ; v˜po‡et © dku a pozice
         mov       bh,0
         mov       bl,al                    ; £schova © dku
         mov       al,SIRX                  ; ¨¡©ka obr zku v bajtech
         mul       ah                       ; v˜po‡et po‡ te‡n¡ho offsetu
         xchg      ax,di                    ; DI <- po‡ te‡n¡ offset
         mov       ax,320*VYSY              ; po‡et bajt– na © dek
         mul       bx                       ; p©epo‡et © dk– na offset
         add       di,ax                    ; DI <- po‡ te‡n¡ adresa obr zku
         mov       ax,0a000h
         mov       es,ax

; ------ inicializace ukazatel–

         mov       si,offset Buffer+16      ; za‡ tek dat
         mov       word ptr ds:[KompCit],0  ; ‡¡ta‡ komprese
         mov       word ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       byte ptr ds:[KompPar],1  ; nastaven¡ p©¡znaku komprese

; ------ inicializace lok ln¡ch promˆnn˜ch

         cld
         call      DispVGA                  ; obsluha zobrazen¡

; ------ n vrat registr–

DispFil9:pop       bx
         ret

DispFile ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ v m¢du VGA (DS:SI=ukazatel v bufferu; CLD)
; -----------------------------------------------------------------------------

DispVGA  PROC      NEAR

;; ------ volba z pisov‚ roviny
;
;         mov       bl,1                     ; ‡¡slo po‡ te‡n¡ roviny 0
;DispVGA1:mov       dx,3c4h
;         mov       al,2                     ; registr volby ‡tec¡ roviny
;         out       dx,al                    ; volba registru ‡¡sla roviny 2
;         inc       dx
;         mov       al,bl                    ; ‡¡slo z pisov‚ roviny
;         out       dx,al                    ; nastaven¡ ‡¡sla roviny ke ‡ten¡

; ------ na‡ten¡ jedn‚ roviny

DispVGA2:push      di
         mov       dx,VYSY                   ; po‡et linek
DispVGA3:mov       cx,SIRX
DispVGA4:call      ReadByte
         cmp       al,31
         jbe       DispVGA5
         inc       al
         jnz       DispVGA5
         mov       al,31
DispVGA5:stosb
         loop      DispVGA4
         add       di,320-SIRX
         dec       dx
         jnz       DispVGA3
         pop       di

; ------ p©¡prava pro dal¨¡ rovinu barev

;         shl       bl,1
;         cmp       bl,10h                   ; jsou ji‘ v¨echny barevn‚ roviny ?
;         jne       DispVGA1                 ; ulo‘en¡ dal¨¡ barevn‚ roviny

DispVGA9:ret

DispVGA  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bajtu z bufferu souboru DS:SI (CLD)
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

; ------ na‡ten¡ bajtu po‡tu dat komprese

         cmp       byte ptr ds:[KompCit],0  ; je ‡¡ta‡ platn˜ ?
         jne       ReadByt4                 ; ‡¡ta‡ je dosud platn˜
ReadByt1:lodsb                              ; na‡ten¡ bajtu ‡¡ta‡e
         mov       byte ptr ds:[KompCit],al ; po‡et n sleduj¡c¡ch bajt–

; ------ p©ep¡na‡ m¢du komprese

         or        al,al                    ; je to jen p©ep¡na‡ ?
         jnz       ReadByt2                 ; nen¡ to p©ep¡na‡
         xor       byte ptr ds:[KompPar],1  ; zmˆna p©¡znaku komprese
         jmp       short ReadByt1           ; nov‚ ‡ten¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

ReadByt2:and       byte ptr ds:[KompPar],not 2 ; zru¨en¡ p©¡znaku komprese
         test      byte ptr ds:[KompPar],1  ; je m¢d komprese ?
         jz        ReadByt3                 ; nen¡ m¢d komprese
         or        byte ptr ds:[KompPar],2  ; p©¡znak komprese
         lodsb                              ; na‡ten¡ bajtu k opakov n¡
         mov       ds:[KompChar],al         ; bajt k opakov n¡

; ------ zmˆna p©¡znaku m¢du komprese

ReadByt3:cmp       byte ptr ds:[KompCit],255 ; je zmˆna m¢du komprese ?
         je        ReadByt4                 ; nen¡ zmˆna m¢du komprese
         xor       byte ptr ds:[KompPar],1  ; zmˆna p©¡znaku komprese

; ------ na‡ten¡ dal¨¡ho bajtu

ReadByt4:mov       al,ds:[KompChar]         ; bajt p©i opakov n¡ dat
         test      byte ptr ds:[KompPar],2  ; je opakov n¡ dat ?
         jnz       ReadByt5                 ; je opakov n¡ dat
         lodsb                              ; na‡ten¡ bˆ‘n‚ho bajtu dat

; ------ sn¡‘en¡ ‡¡ta‡e bajt–

ReadByt5:dec       byte ptr ds:[KompCit]    ; sn¡‘en¡ ‡¡ta‡e komprese
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

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

Int10    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

KurzMous dw        0000000001111111b        ; obr zek kurzoru my¨i
         dw        0000000011111111b
         dw        0000000111111111b
         dw        0000001111111111b
         dw        0000000111111111b
         dw        0000000011111111b
         dw        0001000001111111b
         dw        0011100000111111b
         dw        0111110000011111b
         dw        1111111000001111b
         dw        1111111100000111b
         dw        1111111110000011b
         dw        1111111111000001b
         dw        1111111111100011b
         dw        1111111111110111b
         dw        1111111111111111b

         dw        0000000000000000b
         dw        0111111000000000b
         dw        0111110000000000b
         dw        0111100000000000b
         dw        0111110000000000b
         dw        0110111000000000b
         dw        0100011100000000b
         dw        0000001110000000b
         dw        0000000111000000b
         dw        0000000011100000b
         dw        0000000001110000b
         dw        0000000000111000b
         dw        0000000000011100b
         dw        0000000000001000b
         dw        0000000000000000b
         dw        0000000000000000b

MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'
CardTxt  db        'Chyba - neni graficka karta VGA !',13,10,'$'
FndTxt   db        'Chyba - nenalezen zadny soubor ikony !',13,10,'$'

; —sek shodn‚ho opakovan‚ho bajtu (komrese):
KompCit  dw        0                        ; ‡¡ta‡ shodn‚ho bajtu
KompChar db        0                        ; znak k opakov n¡

; —sek neshodn˜ch bajt– (nen¡ komprese):
KompBNum dw        0                        ; po‡et bajt– v kompresn¡m bufferu
KompBuff db        255 dup(0)               ; kompresn¡ buffer

; P©¡znak £seku komprese
KompPar  db        1                        ; 1=p©¡znak kompresn¡ho m¢du

MapFil   db        5*5 dup(0)               ; tabulka p©¡znak– platn˜ch soubor–

ParMouse db        0                        ; parametry my¨i
                                            ;   bit 0: 1=my¨ nainstalov na

ParKurz  db        0                        ; 1=p©¡znak zapnut¡ kurzoru

Kurzor   dw        -1                       ; aktivn¡ kurzor (254=p©eru¨en¡ ESC)

OldVMod  db        3                        ; uschovan˜ p–vodn¡ videom¢d

AdrSoub  dw        0                        ; adresa ‡¡sla souboru

Soubor0  db        'GMENU_01.PIV',0         ; jm‚no souboru
Soubor1  label     byte
Soubor   db        'A:\',64+14 dup(?)       ; buffer pro adres © a soubor

Buffer   db        BuffSize dup(?)          ; buffer pro na‡ten¡ souboru

Palety   db        3*256 dup(?)             ; buffer palet

Konec    label     byte                     ; konec programu

Code     ENDS
         END       Start

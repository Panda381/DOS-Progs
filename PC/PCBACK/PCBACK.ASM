
bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       ds:[si+bx],bh
         mov       dx,offset HelpTxt        ; text n povˆdy

; ------ dek¢dov n¡ p©¡kazov‚ho © dku

Rozbor1: call      RozbChr                  ; na‡ten¡ znaku
         jnc       Rozbor11
         jmp       Rozbor8

; ------ parametr "!" - n vrat

Rozbor11:cmp       al,"!"
         jne       Rozbor4
         call      RozbChr                  ; dal¨¡ znak
         jc        RozbChyb                 ; chyba zad n¡ parametr–

; ------ parametr "!C" - n vrat obsahu CMOS

         cmp       al,"C"
         jne       Rozbor2
         and       byte ptr ds:[Param],not bit0
         or        byte ptr ds:[Param],bit1 ; p©¡znak n vratu CMOS
         jmp       short Rozbor1

; ------ parametr "!M" - n vrat obsahu MBOOT

Rozbor2: cmp       al,"M"
         jne       RozbChyb
         and       byte ptr ds:[Param],not bit2
         or        byte ptr ds:[Param],bit3 ; p©¡znak n vratu MBOOT
Rozbor22:jmp       short Rozbor1

; ------ parametr "*" - detekce parametr– pevn‚ho disku

Rozbor4: cmp       al,"*"
         jne       Rozbor43
         call      RozbChr                  ; dal¨¡ znak
         jnc       Rozbor40
RozbChyb:jmp       Chyba

Rozbor40:cmp       al,"C"
         jne       Rozbor41
         or        byte ptr ds:[Param],bit5 ; detekce parametr– C:
         jmp       short Rozbor42

Rozbor41:cmp       al,"D"
         jne       RozbChyb
         or        byte ptr ds:[Param],bit6 ; detekce parametr– D:
Rozbor42:call      RozbChr                  ; dal¨¡ znak
         jc        Rozbor8
         cmp       al,"0"
         jb        Rozbor11
         cmp       al,"4"
         ja        Rozbor11
         mov       byte ptr ds:[TestPar],0  ; nen¡ test
Rozbr422:sub       al,"0"
         xchg      ax,cx
         mov       al,bit0
         shl       al,cl
         or        byte ptr ds:[TestPar],al ; pou‘it˜ test
         call      RozbChr                  ; dal¨¡ znak
         jc        Rozbor8
         cmp       al,"0"
         jb        Rozbor11
         cmp       al,"4"
         ja        Rozbor11
         jmp       short Rozbr422

; ------ parametr "C" - £schova CMOS

Rozbor43:cmp       al,"C"
         jne       Rozbor5
         and       byte ptr ds:[Param],not bit1
         or        byte ptr ds:[Param],bit0 ; p©¡znak £schovy CMOS
         jmp       short Rozbor22

; ------ parametr "M" - £schova MBOOT

Rozbor5: cmp       al,"M"
         jne       Rozbor6
         and       byte ptr ds:[Param],not bit3
         or        byte ptr ds:[Param],bit2 ; p©¡znak £schovy MBOOT
         jmp       short Rozbor22

; ------ parametr "W" - operace bez varovani

Rozbor6: cmp       al,"W"
;         jne       Rozbor7
         jne       Chyba
         or        byte ptr ds:[Param],bit7 ; operace bez varov n¡
         jmp       short Rozbor22

; ------ parametr "R" - rekonstrukce MBOOT

;Rozbor7: cmp       al,"R"
;         jne       Chyba
;         or        byte ptr ds:[Param],bit4 ; rekonstrukce MBOOT
;         jmp       short Rozbor1

; ------ test, zda bylo nˆco zad no

Rozbor8: test      byte ptr ds:[Param],bit0+bit1+bit2+bit3+bit4+bit5+bit6
         jnz       Rozbor9                  ; bylo nˆco zad no OK

; ------ chyba

Chyba:   call      DispTxt                  ; zobrazen¡ textu chyby DX
Chyba0:  int       20h

; ------ £vodn¡ test voln‚ pamˆti (pro CMOS)

Rozbor9: mov       ax,256                   ; po‘adovan  voln  pamˆŸ pro CMOS
         call      MemTest                  ; test voln‚ pamˆti

; ------ p©¡prava bufferu pro diskov‚ operace

         test      byte ptr ds:[Param],bit2+bit3+bit4+bit5+bit6
         jz        Back0                    ; nen¡ operace s disketm
         call      InitSekt                 ; inicializace bufferu

; ------ £schova pamˆti CMOS

Back0:   test      byte ptr ds:[Param],bit0 ; je £schova pamˆti CMOS ?
         jz        Back1                    ; nen¡ £schova pamˆti CMOS
         call      GCmos                    ; £schova pamˆti CMOS

; ------ n vrat pamˆti CMOS

Back1:   test      byte ptr ds:[Param],bit1 ; je n vrat pamˆti CMOS ?
         jz        Back2                    ; nen¡ n vrat pamˆti CMOS
         call      SCmos                    ; n vrat pamˆti CMOS

; ------ £schova MBOOT

Back2:   test      byte ptr ds:[Param],bit2 ; je £schova MBOOT ?
         jz        Back3                    ; nen¡ £schova MBOOT
         call      GMBot                    ; £schova MBOOT

; ------ n vrat MBOOT

Back3:   test      byte ptr ds:[Param],bit3 ; je n vrat MBOOT ?
         jz        Back4                    ; nen¡ n vrat MBOOT
         call      SMBot                    ; n vrat MBOOT

; ------ rekonstrukce MBOOT

Back4:   test      byte ptr ds:[Param],bit4 ; je rekonstrukce MBOOT ?
         jz        Back5                    ; nen¡ rekonstrukce MBOOT
         call      RMBot                    ; rekonstrukce MBOOT

; ------ detekce parametr– pevn‚ho disku C:

Back5:   test      byte ptr ds:[Param],bit5 ; detekce parametr– disku C: ?
         jz        Back6
         call      DetParD                  ; detekce parametr– pevn‚ho disku C:

; ------ detekce parametr– pevn‚ho disku D:

Back6:   test      byte ptr ds:[Param],bit6 ; detekce parametr– disku D: ?
         jz        Back7
         mov       byte ptr ds:[Disk],81h   ; ‡¡slo pevn‚ho disku D:
         call      DetParD                  ; detekce parametr– pevn‚ho disku D:

Back7:
         int       20h

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku DS:SI
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

; ------ na‡ten¡ znaku

         cld
         lodsb                              ; na‡ten¡ znaku

; ------ vypu¨tˆn¡ mezer a tabel tor–

         cmp       al,9
         je        RozbChr                  ; znak TAB se ignoruje
         cmp       al," "
         je        RozbChr                  ; mezera se ignoruje
         cmp       al,"/"
         je        RozbChr

; ------ konverze na velk‚ p¡smeno

         cmp       al,"a"
         jb        RozbChr2
         cmp       al,"z"
         ja        RozbChr2
         sub       al,32

; ------ test, zda je platn˜ znak

RozbChr2:cmp       al," "
         jae       RozbChr3                 ; je platn˜ znak
         dec       si                       ; n vrat ukazatele znak–
RozbChr3:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax

         mov       ah,9
         int       21h

         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        test voln‚ pamˆti (AX=po‘adovan  voln  pamˆŸ v bajtech)
; -----------------------------------------------------------------------------

MemTest  PROC      NEAR

         push      ax
         add       ax,offset Buffer + 200h  ; adresa konce bufferu + rezerva
         jc        MemTest2                 ; nedostatek pamˆti
         cmp       ax,sp                    ; je dost pamˆti ?
         jb        MemTest3                 ; pamˆŸ je OK

MemTest2:mov       dx,offset MemTxt         ; chyba - nedostatek pamˆti
         jmp       Chyba

MemTest3:pop       ax
         ret

MemTest  ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ souboru DS:DX pro ‡ten¡ (SI=text -> BX=identifik tor)
; -----------------------------------------------------------------------------

OpenFil  PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ otev©en¡ souboru

         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         xchg      ax,bx                    ; BX <- identifik tor
         jnc       OpenFil9                 ; soubor otev©en OK

; ------ zobrazen¡ textu chyby a konec

         mov       dx,si                    ; DX <- text chyby
         call      DispTxt                  ; £vodn¡ ‡ st hl ¨en¡
         mov       dx,offset NeniSoub
         jmp       Chyba

; ------ n vrat registr–

OpenFil9:pop       ax
         ret

OpenFil  ENDP

; -----------------------------------------------------------------------------
;       vytvo©en¡ c¡lov‚ho souboru DS:DX (SI=potvrzen¡ -> BX=ident., CY chyba)
; -----------------------------------------------------------------------------

CreatFil PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ nastaven¡ adresy DTA

         push      dx
         mov       dx,80h                   ; pracovn¡ adresa DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA
         pop       dx

; ------ test, zda soubor ji‘ existuje

         mov       cx,1 + 2 + 4 + 16 + 32   ; atributy souboru
         mov       ah,4eh
         int       21h                      ; test, zda soubor ji‘ existuje
         jc        CreatFl3                 ; soubor nenalezen

; ------ v˜zva, zda m  b˜t soubor p©eps n

         test      byte ptr ds:[Param],bit7 ; je varov n¡ ?
         jnz       CreatFl3                 ; nen¡ varov n¡
         push      dx
         mov       dx,si                    ; text v˜zvy
         call      DispTxt                  ; zobrazen¡ textu
         mov       dx,offset ExisSoub       ; druh  ‡ st textu
         call      Varov                    ; varov n¡, ‘e bude p©eps n
         pop       dx

; ------ vytvo©en¡ souboru

CreatFl3:xor       cx,cx                    ; atributy souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ souboru
         xchg      ax,bx                    ; BX <- identifik tor

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         ret

CreatFil ENDP

; -----------------------------------------------------------------------------
;        varov n¡ p©ed proveden¡m operace (text DS:DX)
; -----------------------------------------------------------------------------

Varov    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ test, zda je operace bez varov n¡

         test      byte ptr ds:[Param],bit7 ; je varov n¡ ?
         jnz       Varov9                   ; nen¡ varov n¡

; ------ zobrazen¡ textu v˜zvy

         call      DispTxt                  ; zobrazen¡ textu varov n¡

; ------ zobrazen¡ n povˆdy ke kl ves m

         mov       dx,offset EscTxt
         call      DispTxt

; ------ ‡ek n¡ na znak z kl vesnice

         mov       ah,8
         int       21h                      ; vstup znaku z kl vesnice
         or        al,al                    ; bude SCAN k¢d ?
         jnz       Varov2                   ; nebude SCAN k¢d
         mov       ah,8
         int       21h                      ; vstup SCAN k¢du
         mov       al,13                    ; n hrada kl vesou ENTER

; ------ od© dkov n¡ textu

Varov2:  mov       dx,offset CRTxt          ; text od© dkov n¡
         call      DispTxt                  ; zobrazen¡ textu od© dkov n¡

; ------ p©eru¨en¡ programu

         cmp       al,3
         je        Varov4                   ; je Ctrl-C
         cmp       al,27
         jne       Varov9                   ; nen¡ ESC
Varov4:  jmp       Chyba0                   ; konec programu (p©eru¨en¡)

; ------ n vrat registr–

Varov9:  pop       dx
         pop       ax
         ret

Varov    ENDP

; *****************************************************************************
;
;                           £schova pamˆti CMOS
;
; *****************************************************************************
;þ
GCmos    PROC      NEAR

; ------ na‡ten¡ pamˆti CMOS do bufferu

         mov       di,offset Buffer         ; adresa bufferu
         mov       ah,0                     ; ukazatel adresy pamˆti
GCmos1:  call      RdCmos                   ; na‡ten¡ bajtu z pamˆti CMOS
         sti
         cld
         stosb                              ; ulo‘en¡ bajtu do bufferu
         inc       ah                       ; zv˜¨en¡ ukazatele adresy CMOS
         jnz       GCmos1                   ; dal¨¡ bajt
         call      RdCmos                   ; normov n¡ adresy CMOS, NMI=zap
         sti

; ------ otev©en¡ souboru pro £schovu pamˆti CMOS

         mov       dx,offset SoubCMOS       ; jm‚no souboru CMOS.BIN
         mov       si,offset ExisCSou       ; text v˜zvy
         call      CreatFil                 ; vytvo©en¡ souboru
         jnc       GCmos3                   ; operace OK

; ------ chyba z pisu do souboru

GCmos2:  mov       dx,offset ErrWCSou
         jmp       Chyba

; ------ z pis dat do souboru

GCmos3:  mov       dx,offset Buffer         ; buffer s daty CMOS
         mov       cx,256                   ; po‡et bajt– v bufferu
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         jc        GCmos2                   ; chyba z pisu
         cmp       ax,cx
         jne       GCmos2                   ; chyba z pisu

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         jc        GCmos2

; ------ hl ¨en¡ o proveden¡ operace

         mov       dx,offset OKWCSou
         call      DispTxt
         ret

GCmos    ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ bajtu z CMOS (adresa AH -> bajt AL)
; -----------------------------------------------------------------------------

RdCmos   PROC      NEAR

         cli
         push      ax
         mov       al,ah                    ; adresa bajtu z CMOS
         out       [70h],al                 ; nastaven¡ adresy pro ‡ten¡
         jmp       short $+2                ; mal  prodleva
         jmp       short $+2                ; mal  prodleva
         pop       ax
         in        al,[71h]                 ; data na adrese v CMOS
         ret

RdCmos   ENDP

; *****************************************************************************
;
;                              n vrat pamˆti CMOS
;
; *****************************************************************************
;þ
SCmos    PROC      NEAR

; ------ otev©en¡ souboru s CMOS

         mov       dx,offset SoubCMOS       ; soubor CMOS
         mov       si,offset ExisCSou       ; hl ¨en¡
         call      OpenFil                  ; otev©en¡ souboru pro ‡ten¡

; ------ na‡ten¡ souboru do bufferu

         mov       dx,offset Buffer         ; buffer
         mov       cx,256                   ; velikost souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do bufferu
         jnc       SCmos2                   ; soubor na‡ten OK

; ------ chyba

SCmos1:  mov       dx,offset ErrRCSou
         jmp       Chyba

; ------ uzav©en¡ souboru

SCmos2:  cmp       ax,cx
         jne       SCmos1                   ; soubor nen¡ cel˜
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         jc        SCmos1

; ------ varov n¡ p©ed z pisem do CMOS

         mov       dx,offset RecCmos        ; varov n¡ p©ed z pisem
         call      Varov                    ; varov n¡ p©ed z pisem do CMOS

; ------ test velikosti pamˆti CMOS

         call      TestCmos                 ; test velikosti pamˆti CMOS

; ------ navr cen¡ obsahu pamˆti CMOS

         mov       si,offset Buffer+10h     ; buffer s obsahem CMOS
         mov       cx,ds:[SizCmos]          ; velikost pamˆti CMOS
         sub       cx,10h                   ; bez rezervovan˜ch dat
         mov       ah,10h                   ; po‡ te‡n¡ adresa v CMOS
SCmos6:  cld
         lodsb                              ; bajt k z pisu
         call      WrCmos                   ; z pis bajtu do pamˆti CMOS
         sti
         inc       ah                       ; zv˜¨en¡ ukazatele adresy
         loop      SCmos6                   ; z pis dal¨¡ho bajtu
         mov       ah,0                     ; adresa 0
         call      RdCmos                   ; normov n¡ adresy CMOS, NMI=zap
         sti

; ------ hl ¨en¡ o proveden¡ operace

         mov       dx,offset OKRCmos
         call      DispTxt                  ; zobrazen¡ textu hl ¨en¡ - ‡ st 1
         cmp       byte ptr ds:[SizCmos],64 ; je velikost pamˆti CMOS = 64 B ?
         mov       dx,offset OKRCmos1       ; 64 bajt–
         je        SCmos8                   ; pamˆŸ CMOS je 64 bajt–
         mov       dx,offset OKRCmos2       ; 128 bajt–
         ja        SCmos8                   ; pamˆŸ CMOS je 128 bajt–
         mov       dx,offset OKRCmos3       ; 256 bajt–
SCmos8:  call      DispTxt                  ; zobrazen¡ velikosti CMOS
         mov       dx,offset OKRCmos0       ; zbytek textu
         call      DispTxt                  ; zobrazen¡ zbytku textu
         ret

SCmos    ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu do CMOS (adresa AH, bajt AL)
; -----------------------------------------------------------------------------

WrCmos   PROC      NEAR

         cli
         push      ax
         mov       al,ah                    ; adresa bajtu z CMOS
         out       [70h],al                 ; nastaven¡ adresy pro z pis
         jmp       short $+2                ; mal  prodleva
         jmp       short $+2                ; mal  prodleva
         pop       ax
         out       [71h],al                 ; data na adresu v CMOS
         ret

WrCmos   ENDP

; -----------------------------------------------------------------------------
;        test velikosti pamˆti CMOS
; -----------------------------------------------------------------------------

TestCmos PROC      NEAR

; ------ £schova registr–

         push      dx

; ------ test, zda je pamˆŸ alespo¤ 64 bajt–

         mov       dx,10h + 256*(12h)       ; adresy 1 a 2 jsou za sebou
         call      TstCms                   ; test pamˆti CMOS
         jnc       TstCmos2                 ; pamˆŸ CMOS je OK

; ------ chyba z pisu do pamˆti CMOS

         mov       dx,offset ErrWCmos
         jmp       Chyba

; ------ test, zda je pamˆŸ alespo¤ 128 bajt–

TstCmos2:mov       dx,10h + 256*(10h+64)    ; adresy 1 a 2 k testov n¡
         call      TstCms                   ; test jedn‚ adresy CMOS
         jc        TstCmos9                 ; nen¡ pamˆŸ 128 bajt–
         mov       byte ptr ds:[SizCmos],128 ; je nejm‚nˆ 128 bajt–

; ------ test, zda je pamˆŸ 256 bajt–

         mov       dh,10h+128               ; adresa 2 k testov n¡
         call      TstCms                   ; test jedn‚ adresy CMOS
         jc        TstCmos9                 ; nen¡ pamˆŸ 256 bajt–
         mov       word ptr ds:[SizCmos],256 ; je pamˆŸ 256 bajt–

; ------ n vrat registr–

TstCmos9:pop       dx
         ret

TestCmos ENDP

; -----------------------------------------------------------------------------
;        test adres CMOS DL (ni‘¨¡) a DH (vy¨¨¡), zda jsou platn‚ (CY=nejsou)
; -----------------------------------------------------------------------------

TstCms   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ £schova p–vodn¡ho obsahu adres

         mov       ah,dl                    ; ni‘¨¡ adresa
         call      RdCmos                   ; na‡ten¡ bajtu LOW
         xchg      ax,bx                    ; BL <- £schova bajtu LOW
         mov       ah,dh                    ; vy¨¨¡ adresa
         call      RdCmos                   ; na‡ten¡ bajtu HIGH
         mov       bh,al                    ; BH <- £schova bajtu HIGH

; ------ test z pisem inverze vzorku HIGH

         mov       cx,bx                    ; p–vodn¡ vzorek
         not       ch                       ; inverze vzorku HIGH
         call      Tst1Cms                  ; test vzorku
         jc        TstCms9                  ; chyba

; ------ test z pisem inverze vzorku LOW i HIGH

         not       cl                       ; inverze vzorku LOW
         call      Tst1Cms                  ; test vzorku
         jc        TstCms9                  ; chyba

; ------ test z pisem inverze vzorku LOW

         not       ch                       ; n vrat vzorku HIGH
         call      Tst1Cms                  ; test vzorku
         jc        TstCms9                  ; chyba

; ------ test z pisem n hodn‚ho vzorku 1

         mov       cx,2a5eh
         call      Tst1Cms                  ; test vzorku
         jc        TstCms9                  ; chyba

; ------ test z pisem n hodn‚ho vzorku 2

         mov       cx,0e37ch
         call      Tst1Cms                  ; test vzorku

; ------ n vrat p–vodn¡ho obsahu adres

TstCms9: pushf
         mov       cx,bx                    ; CX <- p–vodn¡ obsah pamˆti
         call      Tst1Cms                  ; n vrat obsahu pamˆti
         popf

; ------ n vrat registr–

         pop       cx
         pop       bx
         pop       ax
         sti
         ret

TstCms   ENDP

; -----------------------------------------------------------------------------
;        test vzorku CX adres DX pamˆti CMOS (CY=chyba)
; -----------------------------------------------------------------------------

Tst1Cms  PROC      NEAR

; ------ z pis vzork–

         mov       ah,dl                    ; adresa LOW
         mov       al,cl                    ; data LOW
         call      WrCmos                   ; z pis vzorku LOW
         mov       ah,dh                    ; adresa HIGH
         mov       al,ch                    ; data HIGH
         call      WrCmos                   ; z pis vzorku HIGH

; ------ test vzork–

         mov       ah,dl                    ; adresa LOW
         call      RdCmos                   ; na‡ten¡ vzorku LOW
         cmp       al,cl                    ; souhlas¡ obsah LOW ?
         jne       Tst1Cms2                 ; obsah LOW nesouhlas¡
         mov       ah,dh                    ; adresa HIGH
         call      RdCmos                   ; na‡ten¡ vzorku HIGH
         cmp       al,ch                    ; souhlas¡ vzorek HIGH ?
         je        Tst1Cms3                 ; vzorek souhlas¡ OK
Tst1Cms2:stc                                ; chyba
Tst1Cms3:ret

Tst1Cms  ENDP

; *****************************************************************************
;
;                         £schova sektoru MBOOT
;
; *****************************************************************************
;þ
GMBot    PROC      NEAR

; ------ na‡ten¡ MBOOT sektoru

         call      ReadMBot                 ; na‡ten¡ MBOOT sektoru
         jnc       GMBot1

; ------ chyba ‡ten¡ MBOOT sektoru

         mov       dx,offset ErrRMSek
         jmp       Chyba

; ------ otev©en¡ souboru pro £schovu sektoru MBOOT

GMBot1:  mov       dx,offset SoubMBot       ; jm‚no souboru MBOOT.BIN
         mov       si,offset ExisMSou       ; text v˜zvy
         call      CreatFil                 ; vytvo©en¡ souboru
         jnc       GMBot3                   ; operace OK

; ------ chyba z pisu do souboru

GMBot2:  mov       dx,offset ErrWMSou
         jmp       Chyba

; ------ z pis dat do souboru

GMBot3:  mov       dx,ds:[BuffBoot]         ; buffer s daty MBOOT
         mov       cx,512                   ; po‡et bajt– v bufferu
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         jc        GMBot2                   ; chyba z pisu
         cmp       ax,cx
         jne       GMBot2                   ; chyba z pisu

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         jc        GMBot2

; ------ hl ¨en¡ o proveden¡ operace

         mov       dx,offset OKWMSou
         call      DispTxt
         ret

GMBot    ENDP

; *****************************************************************************
;
;                          n vrat sektoru MBOOT
;
; *****************************************************************************
;þ
SMBot    PROC      NEAR

; ------ £vodn¡ na‡ten¡ MBOOT sektoru (kdyby byl n hodou vˆt¨¡)

         call      ReadMBot                 ; na‡ten¡ p–vodn¡ho MBOOT sektoru

; ------ otev©en¡ souboru s MBOOT

         mov       dx,offset SoubMBot       ; soubor MBOOT
         mov       si,offset ExisMSou       ; hl ¨en¡
         call      OpenFil                  ; otev©en¡ souboru pro ‡ten¡

; ------ na‡ten¡ souboru do bufferu

         mov       dx,ds:[BuffBoot]         ; buffer
         mov       cx,512                   ; velikost souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do bufferu
         jnc       SMBot2                   ; soubor na‡ten OK

; ------ chyba

SMBot1:  mov       dx,offset ErrRMSou
         jmp       Chyba

; ------ uzav©en¡ souboru

SMBot2:  cmp       ax,cx
         jne       SMBot1                   ; soubor nen¡ cel˜
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         jc        SMBot1

; ------ varov n¡ p©ed z pisem do MBOOT

         mov       dx,offset RecMBot        ; varov n¡ p©ed z pisem
         call      Varov                    ; varov n¡ p©ed z pisem do MBOOT

; ------ navr cen¡ obsahu MBOOT sektoru

         mov       bp,3                     ; po‡et pokus–
SMBot3:  call      WritMBot                 ; z pis MBOOT sektoru na disk
         jc        SMBot4                   ; chyba operace

; ------ verifikace sektoru

         call      VerfMBot                 ; verifikace sektoru
         jnc       SMBot5                   ; operace OK

; ------ opakov n¡ operace z pisu

         dec       bp                       ; ‡¡ta‡ pokus–
         jnz       SMBot3                   ; dal¨¡ pokus

; ------ chyba z pisu do MBOOT sektoru

SMBot4:  mov       dx,offset ErrWMSek
         jmp       Chyba

; ------ hl ¨en¡ o proveden¡ operace

SMBot5:  mov       dx,offset OKRMBot
         call      DispTxt                  ; zobrazen¡ textu hl ¨en¡
         ret

SMBot    ENDP

; *****************************************************************************
;
;                      rekonstrukce sektoru MBOOT
;
; *****************************************************************************
;þ
RMBot    PROC      NEAR




         ret

RMBot    ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ MBOOT sektoru
; -----------------------------------------------------------------------------

ReadMBot PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx

; ------ na‡ten¡ MBOOT sektoru

         mov       cx,1                     ; v lec 0, sektor 1
         mov       dh,0                     ; hlava 0
         call      ReadSekt                 ; na‡ten¡ MBOOT sektoru

; ------ n vrat registr–

         pop       dx
         pop       cx
         ret

ReadMBot ENDP

; -----------------------------------------------------------------------------
;        z pis MBOOT sektoru
; -----------------------------------------------------------------------------

WritMBot PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx

; ------ na‡ten¡ MBOOT sektoru

         mov       cx,1                     ; v lec 0, sektor 1
         mov       dh,0                     ; hlava 0
         call      WritSekt                 ; z pis MBOOT sektoru

; ------ n vrat registr–

         pop       dx
         pop       cx
         ret

WritMBot ENDP

; -----------------------------------------------------------------------------
;        verifikace MBOOT sektoru
; -----------------------------------------------------------------------------

VerfMBot PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx

; ------ na‡ten¡ MBOOT sektoru

         mov       cx,1                     ; v lec 0, sektor 1
         mov       dh,0                     ; hlava 0
         call      VerfSekt                 ; verifikace MBOOT sektoru

; ------ n vrat registr–

         pop       dx
         pop       cx
         ret

VerfMBot ENDP

; -----------------------------------------------------------------------------
;        verifikace 1 sektoru od sektoru CX/strana DH
; -----------------------------------------------------------------------------

VerfSekt PROC      NEAR

         push      ax

         mov       ax,401h
         jmp       short ReadSek2

VerfSekt ENDP

; -----------------------------------------------------------------------------
;        z pis 1 sektoru od sektoru CX/strana DH
; -----------------------------------------------------------------------------

WritSekt PROC      NEAR

         push      ax

         mov       ax,301h
         jmp       short ReadSek2

WritSekt ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ 1 sektoru od sektoru CX/strana DH
; -----------------------------------------------------------------------------

ReadSekt PROC      NEAR

         push      ax

         mov       ax,201h                  ; povel pro ‡ten¡

ReadSek2:push      bx
         push      dx
;         push      bp

         mov       dl,ds:[Disk]             ; pracovn¡ disk
         mov       bx,ds:[BuffBoot]         ; adresa bufferu
;         mov       bp,2                     ; po‡et pokus–

ReadSek3:call      Int13                    ; obsluha operace
;         jnc       ReadSek4                 ; operace OK
;         dec       bp                       ; ‡¡ta‡ pokus–
;         jnz       ReadSek3                 ; dal¨¡ pokus

ReadSek4:;pop       bp
         pop       dx
         pop       bx

         pop       ax
         ret

ReadSekt ENDP

; -----------------------------------------------------------------------------
;        operace INT 13h (CY=chyba)
; -----------------------------------------------------------------------------

Int13    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ proveden¡ operace

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
         pop       ax
         ret

Int13    ENDP

; -----------------------------------------------------------------------------
;        inicializace bufferu pro operaci s diskem
; -----------------------------------------------------------------------------

InitSekt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ kontrola voln‚ pamˆti

         mov       word ptr ds:[BuffBoot],offset Buffer ; adresa bufferu
         mov       ax,1030h                 ; asi tak velikost sektoru
         call      MemTest                  ; test voln‚ pamˆti

; ------ p©¡prava adresy bufferu

         mov       ax,cs                    ; segment programu
         mov       cl,4
         shl       ax,cl                    ; offset programu v segmentu
         add       ax,offset(Buffer-Start)+100h ; offset bufferu v segmentu
         cmp       ax,-816h                 ; je dost m¡sta ?
         jb        InitSek2                 ; je dost m¡sta
         sub       word ptr ds:[BuffBoot],ax ; posun adresy bufferu

; ------ n vrat registr–

InitSek2:pop       cx
         pop       bx
         pop       ax
         ret

InitSekt ENDP

; *****************************************************************************
;
;                        Detekce parametr– pevn‚ho disku
;
; *****************************************************************************
;þ
DetParD  PROC      NEAR

; ------ zobrazen¡ £vodn¡ho textu

         mov       al,ds:[Disk]             ; disk
         and       al,7fh
         add       al,"C"
         mov       ds:[ParDTxt1],al         ; ozna‡en¡ disku
         mov       dx,offset ParDTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ detekce parametr– pomoc¡ BIOS

         test      byte ptr ds:[TestPar],bit0
         jz        DetParD0                 ; nen¡ detekce pomoc¡ BIOS
         call      DetDBios                 ; detekce pomoc¡ BIOS
         jnc       DetPrD36                 ; parametry jsou OK

; ------ na‡ten¡ MBOOT sektoru

DetParD0:test      byte ptr ds:[TestPar],bit0+bit1+bit2+bit4
         jz        DetParD2                 ; nen¡ pot©eba ‡¡st disk
         call      ReadMBot                 ; na‡ten¡ MBOOT sektoru
         jnc       DetParD2                 ; sektor na‡ten OK

; ------ chyba - neplatn˜ disk

DetParD1:mov       dx,offset ParDTxN        ; neplatn˜ disk
         jmp       Chyba

; ------ p©¡prava tabulky odd¡l– z MBOOT sektoru

DetParD2:test      byte ptr ds:[TestPar],bit1 ; povolen test MBOOT ?
         jz        DetPrD42                 ; nen¡ povolen test MBOOT
         call      GetMBoot                 ; na‡ten¡ tabulky odd¡l– disku
         jc        DetPrD42                 ; MBOOT sektor neplatn˜

; ------ detekce parametr– z BOOT sektor–

         mov       si,offset TabPart+3*16   ; tabulka odd¡l– disku (konec)
DetParD3:mov       ax,ds:[si+0ch]
         or        ax,ds:[si+0eh]           ; je to platn˜ odd¡l ?
         jz        DetParD4                 ; nen¡ to platn˜ odd¡l
         cmp       byte ptr ds:[si+4],0
         je        DetParD4                 ; nezn m˜ syst‚m

; ------ na‡ten¡ BOOT sektoru ze za‡ tku odd¡lu

         mov       cx,ds:[si+2]             ; sektor a v lec za‡ tku odd¡lu
         jcxz      DetParD4                 ; nen¡ platn˜ £daj
         mov       dh,ds:[si+1]             ; hlava za‡ tku odd¡lu
         call      ReadSekt                 ; na‡ten¡ BOOT sektoru odd¡lu
         jc        DetParD4                 ; chyba

; ------ detekce parametr– z BOOT sektoru

         call      DetBoot                  ; detekce parametr– z BOOT sektoru
         jc        DetParD4                 ; chyba
DetPrD36:jmp       DetParD8                 ; parametry detekov ny OK

; ------ dal¨¡ odd¡l disku

DetParD4:sub       si,16                    ; adresa dal¨¡ho odd¡lu
         cmp       si,offset TabPart
         jae       DetParD3                 ; dal¨¡ odd¡l

; ------ na‡ten¡ BOOT sektoru ze strany 1 stopy 0

DetPrD42:test      byte ptr ds:[TestPar],bit2 ; povolen test BOOT ?
         jz        DetParD6                 ; nepovolen test BOOT
         mov       cx,1                     ; v lec 0, sektor 1
         mov       dh,1                     ; strana 1
         call      ReadSekt                 ; na‡ten¡ BOOT sektoru
         jc        DetParD5                 ; chyba
         call      DetBoot                  ; detekce parametr– z BOOT sektoru
         jnc       DetPrD36                 ; parametry detekov ny OK

; ------ na‡ten¡ BOOT sektoru ze strany 0 stropy 0 sektoru 2

DetParD5:mov       cx,2                     ; v lec 0, sektor 2
         mov       dh,0                     ; strana 0
         call      ReadSekt                 ; na‡ten¡ BOOT sektoru
         jc        DetParD6                 ; chyba
         call      DetBoot                  ; detekce parametr– z BOOT sektoru
         jnc       DetPrD36                 ; parametry detekov ny OK

; ------ na‡ten¡ AT-BUS sektoru

DetParD6:test      byte ptr ds:[TestPar],bit3 ; povolen test AT-BUS ?
         jz        DetParD7                 ; nepovolen test AT-BUS
         call      GetATBus                 ; na‡ten¡ AT-BUS sektoru
         jc        DetParD7                 ; chyba

; ------ detekce parametr– z AT-BUS

         call      DetATBus                 ; detekce parametr– z AT-BUS
         jnc       DetPrD36                 ; parametry detekov ny OK

; ------ zji¨tˆn¡ po‡tu sektor– na stopu

DetParD7:test      byte ptr ds:[TestPar],bit4
         jz        DetPrD77
         call      DetSekt                  ; detekov n¡ po‡tu sektor– na stopu

; ------ zji¨tˆn¡ po‡tu stran disku

DetPrD72:call      DetStran                 ; detekce po‡tu stran disku

; ------ zji¨tˆn¡ po‡tu stop disku

DetPrD74:call      DetStop                  ; detekce po‡tu stop disku

; ------ v˜po‡et celkov‚ho po‡tu sektor– disku

DetPrD76:call      GetSektC                 ; po‡et sektor– disku celkem
         jnc       DetParD8                 ; operace OK
DetPrD77:mov       dx,offset ParDTxN2
         jmp       Chyba                    ; chyba - nelze ur‡it

; ------ parametry detekov ny OK - zobrazen¡ parametr–

DetParD8:mov       si,offset ParDTxP1
         xor       dx,dx
         mov       ax,ds:[Sektoru]          ; po‡et sektor– na stopu
         call      DispPar                  ; zobrazen¡ parametru

; ------ po‡et hlav

         mov       si,offset ParDTxP2
         mov       ax,ds:[Stran]            ; po‡et stran
         call      DispPar                  ; zobrazen¡ parametru

; ------ po‡et v lc–

         mov       si,offset ParDTxP3
         mov       ax,ds:[Valcu]            ; po‡et v lc–
         call      DispPar                  ; zobrazen¡ parametru

; ------ po‡et sektor– celkem

         mov       si,offset ParDTxP4
         mov       ax,word ptr ds:[SektCelk]
         mov       dx,word ptr ds:[SektCelk+2]
         call      DispPar

; ------ kapacita disku (v MB)
                                            ; sektor– = kapacita/2^9
         shr       dx,1
         rcr       ax,1                     ; kapacita v KB
         mov       di,10000                 ; dˆlitel pro zaokrouhlen¡
         add       ax,5000                  ; trochu zaokrouhlen¡
         adc       dx,0
         jc        DetPrD84
         cmp       dx,di
         jb        DetParD9
DetPrD84:mov       dx,10000-1
DetParD9:div       di
         mov       di,10
         mul       di                       ; kapacita v MB zaokrouhlen  na 10MB
         mov       si,offset ParDTxP5
         call      DispPar

         mov       dx,offset CRTxt
         call      DispTxt
         ret

DetParD  ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ parametr– z BIOS (CY=chyba)
; -----------------------------------------------------------------------------

DetDBios PROC      NEAR

         push      ds
         push      es

         xor       cx,cx
         mov       dl,ds:[Disk]             ; ‡¡slo pevn‚ho disku
         mov       ah,8
         stc
         int       13h                      ; poskytnut¡ parametr– disku

         pop       es
         pop       ds

         jc        DetDBio9                 ; chyba

         mov       al,ch                    ; maxim ln¡ hodnota pro v lce
         mov       ah,cl
         rol       ah,1
         rol       ah,1
         and       ax,3ffh
         stc
         jz        DetDBio9
         inc       ax                       ; po‡et ud van˜ch v lc–
         inc       ax                       ; BIOS ponech v  1 v lec voln˜ ?
         mov       ds:[Valcu],ax            ; po‡et v lc–

         and       cx,3fh                   ; po‡et sektor–
         mov       ds:[Sektoru],cx          ; po‡et sektor–

         mov       al,dh
         mov       ah,0
         inc       ax
         mov       ds:[Stran],ax            ; po‡et stran

         call      GetSektC                 ; po‡et sektor– disku celkem

DetDBio9:ret

DetDBios ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ po‡tu stop
; -----------------------------------------------------------------------------

DetStop  PROC      NEAR

         xor       cx,cx                    ; v˜choz¡ stopa
         mov       bx,64                    ; asi tak p©¡rustek
DetStop1:add       cx,bx                    ; zv˜¨en¡ ‡¡sla stopy
         call      Det1Stop                 ; test jedn‚ stopy
         jnc       DetStop1                 ; stopa je zat¡m platn 
         sub       cx,bx                    ; n vrat ‡¡sla stopy
         shr       bx,1                     ; polovi‡n¡ p©¡rustek
         shr       bx,1
         shr       bx,1
         jnz       DetStop1
         inc       cx                       ; n sleduj¡c¡ stopa
         mov       ds:[Valcu],cx            ; po‡et v lc– disku
         ret

DetStop  ENDP

; -----------------------------------------------------------------------------
;        test 1 stopy CX (CY=neplatn )
; -----------------------------------------------------------------------------

Det1Stop PROC      NEAR

         push      cx
         push      dx

         cmp       cx,1024                  ; maxim ln¡ ‡¡slo stopy
         cmc
         jc        Det1Stp2                 ; neplatn‚ ‡¡slo stopy

         mov       dh,byte ptr ds:[Stran]   ; po‡et stran
         dec       dh                       ; posledn¡ strana
         xchg      ch,cl
         ror       cl,1
         ror       cl,1
         or        cl,byte ptr ds:[Sektoru] ; posledn¡ sektor na stopˆ
         call      ReadSekt                 ; test sektoru

Det1Stp2:pop       dx
         pop       cx
         ret

Det1Stop ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ po‡tu stran
; -----------------------------------------------------------------------------

DetStran PROC      NEAR

; ------ nalezen¡ maxim ln¡ strany

         mov       word ptr ds:[Stran],0    ; po‡et stran
         mov       cx,1                     ; v lec 0, sektor 1
         mov       dh,0                     ; strana 0
DetStrn1:call      ReadSekt                 ; test sektoru
         jc        DetStrn9                 ; nen¡ dal¨¡ strana - konec
         inc       word ptr ds:[Stran]      ; zv˜¨en¡ ‡¡ta‡e stran
         inc       dh                       ; zv˜¨en¡ ‡¡sla strany
         jnz       DetStrn1                 ; dal¨¡ strana

; ------ porovn n¡ s vedlej¨¡m v lcem

         mov       ch,0                     ; v lec 0
         call      Det1Strn
DetStrn2:mov       ds:[Stran],ax            ; po‡et stran
         mov       bx,5                     ; po‡et nutn˜ch shod
DetStrn3:inc       ch                       ; zv˜¨en¡ ‡¡sla stopy
         cmp       ch,20
         ja        DetStrn4
         call      Det1Strn
         cmp       ax,ds:[Stran]
         jne       DetStrn2
         dec       bx                       ; ‡¡ta‡ nutn˜ch shod
         jnz       DetStrn3                 ; dal¨¡ nutn  shoda

; ------ porovn n¡ se za‡ tkem v lce

DetStrn4:cmp       al,255
         jne       DetStrn9

         mov       ch,0
         call      Det2Strn
DetStrn6:mov       ds:[Stran],ax
         mov       bx,5                     ; po‡et nutn˜ch shod
DetStrn7:inc       ch
         cmp       ch,20
         ja        DetStrn9
         call      Det2Strn
         cmp       ax,ds:[Stran]
         jne       DetStrn6
         dec       bx                       ; ‡¡ta‡ nutn˜ch shod
         jnz       DetStrn7                 ; dal¨¡ nutn  shoda

DetStrn9:ret

DetStran ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ stran porovn n¡m (v lec CH) -> AX
; -----------------------------------------------------------------------------

Det1Strn PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx

; ------ p©¡prava k testu

         mov       cl,1                     ; po‡ te‡n¡ sektor
         mov       dx,0                     ; DH=testovan , DL=referen‡n¡ strana
         mov       bx,cx                    ; BX <- v˜choz¡ sektor a v lec
         inc       bh                       ; BH <- dal¨¡ v lec
Det1Str1:xor       ax,ax                    ; ‡¡ta‡ sektor–

; ------ test jedn‚ strany

Det1Str2:call      DetTest                  ; test jedn‚ strany
         jc        Det1Str9                 ; chyba
         jne       Det1Str6                 ; sektory nejsou shodn‚
         or        dh,dh                    ; strana 0 se netestuje
         jz        Det1Str6                 ; sektory nejsou shodn‚

; ------ test stopy, zda je shodn 

         push      bx
         push      cx

Det1Str3:inc       cx                       ; zv˜¨en¡ ukazatele sektor–
         cmp       cl,byte ptr ds:[Sektoru]
         ja        Det1Str5                 ; nen¡ dal¨¡ sektor
         inc       bx                       ; zv˜¨en¡ ‡¡sla referen‡n¡ho sekt.
         call      DetTest                  ; test dal¨¡ho sektoru
         jc        Det1Str5                 ; nen¡ dal¨¡ sektor
         je        Det1Str3                 ; stopy jsou shodn‚
         stc                                ; p©¡znak - nen¡ shoda

Det1Str5:pop       cx
         pop       bx
         jnc       Det1Str9                 ; stopy jsou shodn‚

; ------ strana je OK

Det1Str6:inc       ax                       ; zv˜¨en¡ ‡¡ta‡e platn˜ch stran
         inc       dh                       ; zv˜¨en¡ ukazatele ‡¡sla strany
         jnz       Det1Str2                 ; test dal¨¡ strany
         dec       ax                       ; omezen¡ po‡tu stran

; ------ n vrat registr–

Det1Str9:pop       dx
         pop       cx
         pop       bx
         ret

Det1Strn ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ stran porovn n¡m s prvn¡ stranou (v lec CH) -> AX
; -----------------------------------------------------------------------------

Det2Strn PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx

; ------ p©¡prava k testu

         mov       cl,1                     ; po‡ te‡n¡ sektor
         mov       dx,0                     ; DH=testovan , DL=referen‡n¡ strana
         mov       bx,cx                    ; BX <- v˜choz¡ sektor a v lec
         jmp       Det1Str1

Det2Strn ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ po‡tu sektor– na stopˆ
; -----------------------------------------------------------------------------

DetSekt  PROC      NEAR

; ------ nalezen¡ maxim ln¡ho sektoru

         mov       word ptr ds:[Sektoru],0  ; po‡et sektor– na stopu
         mov       cx,1                     ; v lec 0, sektor 1
         mov       dh,0                     ; strana 0
DetSekt1:call      ReadSekt                 ; test sektoru
         jc        DetSekt9                 ; nen¡ dal¨¡ sektor - konec
         inc       word ptr ds:[Sektoru]    ; zv˜¨en¡ ‡¡ta‡e sektor–
         inc       cx                       ; zv˜¨en¡ ‡¡sla sektoru
         cmp       cl,64
         jb        DetSekt1                 ; dal¨¡ sektor

; ------ porovn n¡ s vedlej¨¡ stopou

         mov       ch,0                     ; v lec 0
         call      Det1Sekt
DetSekt2:mov       ds:[Sektoru],ax          ; po‡et sektor–
         mov       bx,5                     ; po‡et nutn˜ch shod
DetSekt3:inc       ch
         cmp       ch,20
         ja        DetSekt9
         call      Det1Sekt
         cmp       ax,ds:[Sektoru]
         jne       DetSekt2
         dec       bx                       ; ‡¡ta‡ nutn˜ch shod
         jnz       DetSekt3                 ; dal¨¡ nutn  shoda

DetSekt9:ret

DetSekt  ENDP

; -----------------------------------------------------------------------------
;        detekov n¡ sektor– porovn n¡m (v lec CH) -> AX
; -----------------------------------------------------------------------------

Det1Sekt PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx

; ------ p©¡prava k testu

         mov       cl,1                     ; po‡ te‡n¡ sektor
         xor       ax,ax                    ; ‡¡ta‡ sektor–
         mov       dx,1                     ; DH=testovan , DL=referen‡n¡ strana
         mov       bx,cx                    ; BX <- v˜choz¡ sektor a v lec

; ------ test jednoho sektoru

Det1Sek2:call      DetTest                  ; test jednoho sektoru
         jc        Det1Sek9                 ; chyba
         jne       Det1Sek6                 ; sektory nejsou shodn‚
         cmp       cl,10                    ; asi tak minim ln¡ po‡et sektor–
         jbe       Det1Sek6                 ; to je je¨tˆ m lo sektor–

; ------ test ostatn¡ch sektor–, zda jsou shodn‚

         push      bx
         push      cx

Det1Sek3:inc       cx                       ; zv˜¨en¡ ukazatele sektor–
         cmp       cl,64
         jae       Det1Sek5                 ; nen¡ dal¨¡ sektor
         inc       bx                       ; zv˜¨en¡ ‡¡sla referen‡n¡ho sekt.
         call      DetTest                  ; test dal¨¡ho sektoru
         jc        Det1Sek5                 ; nen¡ dal¨¡ sektor
         je        Det1Sek3                 ; sektory jsou shodn‚
         stc                                ; p©¡znak - nen¡ shoda

Det1Sek5:pop       cx
         pop       bx
         jnc       Det1Sek9                 ; sektory jsou shodn‚

; ------ sektor je OK

Det1Sek6:inc       ax                       ; zv˜¨en¡ ‡¡ta‡e platn˜ch sektor–
         inc       cx                       ; zv˜¨en¡ ukazatele ‡¡sla sektoru
         cmp       cl,64
         jb        Det1Sek2                 ; test dal¨¡ho sektoru
         dec       ax                       ; omezen¡ po‡tu sektor–

; ------ n vrat registr–

Det1Sek9:pop       dx
         pop       cx
         pop       bx
         ret

Det1Sekt ENDP

; -----------------------------------------------------------------------------
;        test sektor– p©i detekci
; -----------------------------------------------------------------------------
; VSTUP: CX=testovan˜ sektor a v lec
;        DH=testovan  strana
;        BX=referen‡n¡ sektor a v lec
;        DL=referen‡n¡ strana
; VSTUP: CY=testovan˜ sektor neplatn˜ (ZF nedefinov n)
;         ZY=testovan˜ a referen‡n¡ sektor jsou shodn‚
; -----------------------------------------------------------------------------

DetTest  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ na‡ten¡ testovan‚ho sektoru

         call      ReadSekt                 ; na‡ten¡ sektoru do bufferu
         jc        DetTest9                 ; sektor nena‡ten

; ------ £schova testovan‚ho sektoru do bufferu

         mov       si,ds:[BuffBoot]         ; adresa bufferu sektoru
         mov       di,offset BuffATB        ; buffer AT-BUS
         mov       cx,256                   ; velikost sektoru (ve slovech)
         cld
         rep       movsw                    ; £schova referen‡n¡ho sektoru

; ------ na‡ten¡ referen‡n¡ho sektoru

         mov       cx,bx                    ; CX <- referen‡n¡ sektor a v lec
         mov       dh,dl                    ; DH <- referen‡n¡ strana
         call      ReadSekt                 ; na‡ten¡ referen‡n¡ho sektoru
         jnc       DetTest4                 ; sektor na‡ten OK
         or        cx,cx                    ; p©¡znak - sektor nen¡ shodn˜
         jmp       short DetTest9

; ------ porovn n¡ testovan‚ho a referen‡n¡ho sektoru

DetTest4:mov       si,ds:[BuffBoot]         ; adresa bufferu sektoru
         mov       di,offset BuffATB        ; buffer AT-BUS
         mov       cx,256                   ; velikost sektoru (ve slovech)
         cld
         rep       cmpsw                    ; porovn n¡ sektor–
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

DetTest9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DetTest  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ parametru DX:AX (text SI)
; -----------------------------------------------------------------------------

DispPar  PROC      NEAR

         push      dx
         mov       dx,si
         call      DispTxt
         pop       dx
                                            ; pokra‡uje zobrazen¡ ‡¡sla !!!!

DispPar  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla DX:AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ dek¢dov n¡ ‡¡sla do bufferu

         mov       si,10                    ; dˆlitel ‡¡sla
         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic v z sobn¡ku
DispNum1:xchg      ax,bx                    ; BX <- £schova ‡¡sla LOW
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- ‡¡slo HIGH, DX <- 0
         div       si                       ; vydˆlen¡ ‡¡sla HIGH
         xchg      ax,bx                    ; AX <- ‡¡slo LOW, BX <- nov‚ HIGH
         div       si                       ; vydˆlen¡ ‡¡sla LOW
         add       dl,"0"                   ; ‡¡slice
         push      dx                       ; £schova ‡¡slice do z sobn¡ku
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e ‡¡slic
         mov       dx,bx                    ; DX <- ‡¡slo HIGH
         or        bx,ax                    ; je ‡¡slo ji‘ = 0 ?
         jnz       DispNum1                 ; dal¨¡ ‡¡slice

; ------ zobrazen¡ ‡¡sla

DispNum2:pop       ax
         call      DispChr                  ; zobrazen¡ ‡¡slice
         loop      DispNum2

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      cx
         push      dx
         xchg      ax,dx
         mov       ah,2
         int       21h
         pop       dx
         pop       cx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        Na‡ten¡ tabulky z MBOOT (CY=neplatn˜ MBOOT sektor)
; -----------------------------------------------------------------------------

GetMBoot PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di

; ------ £schova tabulky odd¡l–

         mov       si,ds:[BuffBoot]
         add       si,1beh
         mov       cx,4*16/2                ; velikost tabulky
         mov       di,offset TabPart
         cld
         rep       movsw                    ; £schova tabulky odd¡l– disku

; ------ test, zda je to platn˜ MBOOT sektor

         cmp       word ptr ds:[si],0aa55h  ; je to zav dˆc¡ sektor ?
         jne       GetMBot8                 ; nen¡ to zav dˆc¡ sektor

; ------ test tabulky odd¡l– disku

         mov       si,offset TabPart        ; tabulka odd¡l– disku
GetMBot2:test      byte ptr ds:[si],7fh     ; je to platn˜ p©¡znak ?
         jnz       GetMBot8                 ; nen¡ platn˜ p©¡znak
         add       si,16                    ; dal¨¡ odd¡l
         cmp       si,offset TabPart+4*16
         jb        GetMBot2
         jmp       short GetMBot9           ; tabulka je OK

; ------ n vrat registr–

GetMBot8:stc                                ; p©¡znak chyby
GetMBot9:pop       di
         pop       si
         pop       cx
         ret

GetMBoot ENDP

; -----------------------------------------------------------------------------
;        Detekce parametr– disku z BOOT (CY=neplatn‚ parametry)
; -----------------------------------------------------------------------------

DetBoot  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ test, zda je BOOT sektor platn˜

         mov       si,ds:[BuffBoot]         ; adresa BOOT sektoru
         cmp       word ptr ds:[si+510],0aa55h ; je to platn˜ BOOT sektor ?
         jne       DetBoot2                 ; BOOT sektor nen¡ platn˜

; ------ test instrukce skoku na za‡ tku sektoru

         cmp       byte ptr ds:[si],0e9h    ; instrukce JMP NEAR
         jne       DetBoot1
         cmp       word ptr ds:[si+1],1bh
         jb        DetBoot2                 ; p©¡li¨ mal˜ offset skoku
         cmp       word ptr ds:[si+1],600h
         jb        DetBoot3                 ; offset skoku je OK

DetBoot1:cmp       byte ptr ds:[si],0ebh    ; instrukce JMP SHORT
         jne       DetBoot2                 ; nespr vn  instrukce
         cmp       byte ptr ds:[si+1],1ch
         jae       DetBoot3                 ; offset skoku je OK
DetBoot2:jmp       DetBoot8

; ------ kontrola velikosti sektoru

DetBoot3:mov       ax,ds:[si+0bh]           ; velikost sektoru
         cmp       ax,32                    ; minim ln¡ velikost sektoru
         jb        DetBoot2                 ; mal˜ sektor
         call      TestBin                  ; test sektoru
         jc        DetBoot2                 ; chybn˜ sektor

; ------ kontrola po‡tu sektor– na blok

         mov       al,ds:[si+0dh]           ; po‡et sektor– na blok
         mov       ah,0
         call      TestBin                  ; test sektoru
         jc        DetBoot2                 ; chybn˜ po‡et sektor–

; ------ kontrola po‡tu sektor– p©ed FAT

         cmp       word ptr ds:[si+0eh],0   ; po‡et sektor– p©ed FAT
         je        DetBoot2                 ; chybn˜ po‡et rezervovan˜ch sekt.

; ------ kontrola po‡tu tabulek FAT

         cmp       byte ptr ds:[si+10h],0
         je        DetBoot2                 ; cbybn˜ po‡et tabulek FAT

; ------ po‡et sektor– na stopu

         mov       ax,ds:[si+18h]           ; po‡et sektor– na stopu
         or        ah,ah
         jnz       DetBoot2                 ; velk˜ po‡et sektor–
         or        al,al
         jz        DetBoot2                 ; mal˜ po‡et sektor–
         mov       ds:[Sektoru],ax          ; po‡et sektor– na stopu

; ------ po‡et stran disku

         mov       ax,ds:[si+1ah]           ; po‡et stran disku
         or        ah,ah
         jnz       DetBoot2                 ; velk˜ po‡et sektor–
         or        al,al
         jz        DetBoot2                 ; mal˜ po‡et sektor–
         mov       ds:[Stran],ax            ; po‡et stran disku
         mul       byte ptr ds:[Sektoru]    ; po‡et sektor– na v lec
         xchg      ax,di                    ; DI <- po‡et sektor– na v lec

; ------ celkov˜ po‡et sektor– disku

         mov       ax,ds:[si+13h]           ; celkov˜ po‡et sektor– odd¡lu
         xor       dx,dx                    ; po‡et sektor– HIGH
         or        ax,ax                    ; je po‡et sektor– = 0 ?
         jnz       DetBoot5                 ; po‡et sektor– je platn˜
         cmp       byte ptr ds:[si+26h],29h ; roz¨¡©en¡ form t ?
         jne       DetBoot8
         mov       ax,ds:[si+20h]           ; po‡et sektor– 2-slovn¡
         mov       dx,ds:[si+22h]

; ------ p©i‡ten¡ skryt˜ch sektor–

DetBoot5:mov       cx,ds:[si+1ch]           ; skryt˜ch sektor– LOW
         xor       bx,bx                    ; skryt˜ch sektor– HIGH
         cmp       byte ptr ds:[si+26h],29h ; roz¨¡©en¡ form t ?
         jne       DetBot52                 ; nen¡ roz¨¡©en˜ form t
         mov       bx,ds:[si+1eh]           ; skryt˜ch sektor– HIGH
DetBot52:or        bx,bx
         jnz       DetBoot6
         jcxz      DetBoot8                 ; nespr vn˜ £daj
DetBoot6:add       ax,cx                    ; AX <- cektor– celkem LOW
         adc       dx,bx                    ; DX <- sektor– celkem HIGH

; ------ v˜po‡et po‡tu v lc– disku

         dec       di                       ; sektor– na v lec - 1
         add       ax,di                    ; zarovn n¡ nahoru
         adc       dx,0
         jc        DetBoot8                 ; p©ete‡en¡
         inc       di
         cmp       dx,di                    ; p©ete‡en¡ ?
         jae       DetBoot8                 ; p©ete‡en¡ ‡¡sla
         div       di                       ; v˜po‡et po‡tu v lc–
         inc       ax                       ; 1 v lec BIOS ponech v  rezervn¡ ?
         jz        DetBoot8                 ; chyba
         mov       ds:[Valcu],ax            ; po‡et v lc– disku

; ------ v˜po‡et celkov‚ho po‡tu sektor–

         call      GetSektC                 ; po‡et sektor– disku celkem
         jnc       DetBoot9

; ------ n vrat registr–

DetBoot8:stc                                ; p©¡znak chyby
DetBoot9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DetBoot  ENDP

; -----------------------------------------------------------------------------
;        test, zda ‡¡slo AX je bin rn¡ (n sobek 2) -> CY nen¡
; -----------------------------------------------------------------------------

TestBin  PROC      NEAR

         push      ax
         or        ax,ax                    ; je ‡¡slo = 0 ?
         jz        TestBin4                 ; nen¡ platn‚ ‡¡slo
TestBin1:shr       ax,1
         jnc       TestBin1                 ; nalezen¡ bitu "1"
         clc                                ; nen¡ chyba
         jz        TestBin4                 ; ‡¡slo je OK
TestBin3:stc                                ; chyba - nen¡ bin rn¡
TestBin4:pop       ax
         ret

TestBin  ENDP

; -----------------------------------------------------------------------------
;        v˜po‡et celkov‚ho po‡tu sektor– disku (CY=chyba)
; -----------------------------------------------------------------------------

GetSektC PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ v˜po‡et celkov‚ho po‡tu sektor–

         mov       ax,ds:[Stran]            ; po‡et stran disku
         mul       word ptr ds:[Sektoru]    ; * po‡et sektor– na stopu
         xchg      ax,bx                    ; BX <- £schova sektor– LOW
         xchg      ax,dx                    ; AX <- sektor– HIGH
         mul       word ptr ds:[Valcu]
         or        dx,dx
         jnz       GetSktC8                 ; p©ete‡en¡
         xchg      ax,bx                    ; AX <- sektor– LOW
         mul       word ptr ds:[Valcu]
         add       dx,bx                    ; sektor– HIGH
         jc        GetSktC8
         mov       word ptr ds:[SektCelk],ax ; po‡et sektor– LOW
         mov       word ptr ds:[SektCelk+2],dx
         or        ax,dx
         jnz       GetSktC9
GetSktC8:stc

; ------ n vrat registr–

GetSktC9:pop       dx
         pop       bx
         pop       ax
         ret

GetSektC ENDP

; -----------------------------------------------------------------------------
;        detekce parametr– z AT-BUS (CY=chyba)
; -----------------------------------------------------------------------------
;þ
DetATBus PROC      NEAR

         push      ax
         push      dx
         push      si

; ------ po‡et sektor– na stopu

         mov       si,offset BuffATB        ; buffer informac¡
         mov       ax,ds:[si+12]            ; po‡et sektor– na stopu
         or        ax,ax
         jz        DetATBs8
         cmp       ax,64
         jae       DetATBs8
         mov       ds:[Sektoru],ax          ; po‡et sektor– na stopu

; ------ po‡et stran disku

         mov       ax,ds:[si+6]             ; po‡et hlav disku
         or        ax,ax
         jz        DetATBs8
         or        ah,ah
         jnz       DetATBs8
         mov       ds:[Stran],ax            ; po‡et stran disku

; ------ po‡et v lc– disku

         mov       ax,ds:[si+2]             ; po‡et v lc– pevn‚ho disku
         or        ax,ax
         jz        DetATBs2
         cmp       ax,1024
         jb        DetATBs3

DetATBs2:mov       ax,ds:[si+4]             ; po‡et v lc– v˜mˆnn‚ho disku
         or        ax,ax
         jz        DetATBs8
         cmp       ax,1024
         jae       DetATBs8

DetATBs3:mov       ds:[Valcu],ax            ; po‡et v lc– disku

; ------ v˜po‡et po‡tu sektor– celkem

         call      GetSektC                 ; po‡et sektor– disku celkem
         jnc       DetATBs9

; ------ n vrat registr–

DetATBs8:stc                                ; p©¡znak chyby
DetATBs9:pop       si
         pop       dx
         pop       ax
         ret

DetATBus ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ informa‡n¡ho sektoru AT-BUS (CY=chyba)
; -----------------------------------------------------------------------------

GetATBus PROC      NEAR

; ------ adresa portu ©adi‡e disku

         mov       dx,1f0h                  ; port disku C:
;         test      byte ptr ds:[Disk],bit0  ; je disk C: ?
;         jz        GetATBs1                 ; je disk C:
;         mov       dl,70h                   ; port disku D:
GetATBs1:mov       ds:[DiskPort],dx         ; adresa portu ©adi‡e disku

; ------ ‡ek n¡ na p©ipravenost ©adi‡e disku

         call      WaitDBus                 ; ‡ek n¡ na p©ipravenost ©adi‡e
         jc        GetATBs8                 ; chyba TIME-OUT

; ------ volba disku

         add       dl,6
         mov       al,ds:[Disk]             ; ‡¡slo disku
         mov       cl,4
         shl       al,cl                    ; bit 4 <- ‡¡slo disku
         or        al,bit7+bit5             ; je ECC a sektor 512 bajt–
         out       dx,al                    ; volba disku
         jmp       short $+2

; ------ vysl n¡ povelu pro na‡ten¡ informac¡ o disku AT-BUS

         inc       dx                       ; port 1F7h
         mov       al,0ech
         out       dx,al                    ; povel pro na‡ten¡ informac¡
         jmp       short $+2

; ------ ‡ek n¡ na p©ipravenost dat

         call      WaitDReq                 ; ‡ek n¡ na p©ipravenost dat
         jc        GetATBs8                 ; chyba TIME-OUT

; ------ na‡ten¡ informa‡n¡ho sektoru

         sub       dl,7                     ; datov˜ port
         mov       di,offset BuffATB        ; buffer AT-BUS
         mov       cx,256                   ; po‡et slov k na‡ten¡ (512 bajt–)
         cld
         cli
GetATBs6:in        ax,dx                    ; na‡ten¡ slova dat
         stosw
         loop      GetATBs6
         sti

; ------ test, zda je sektor platn˜ (=zda je konstanta)

         mov       di,offset BuffATB        ; buffer AT-BUS
         mov       cx,512                   ; velikost dat v bufferu
         mov       al,es:[di]               ; prvn¡ bajt dat
         repe      scasb                    ; test, zda je konstanta
         stc                                ; p©¡znak chyby
         je        GetATBs8                 ; je konstanta - chyba
         clc                                ; operace OK

; ------ n vrat registr–

GetATBs8:ret

GetATBus ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost ©adi‡e disku (CY=chyba)
; -----------------------------------------------------------------------------

WaitDBus PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

; ------ p©¡prava registr–

         mov       dx,ds:[DiskPort]         ; port disku
         add       dx,7                     ; stavov˜ port
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       cx,5                     ; po‡et impuls– hodin

; ------ ‡ek n¡ na p©ipravenost ©adi‡e

WaitDBs2:mov       bx,ds:[46ch]             ; ‡asova‡
WaitDBs3:sti
         in        al,dx                    ; na‡ten¡ stavov‚ho registru
         test      al,bit7                  ; je ©adi‡ p©ipraven ?
         jz        WaitDBs9                 ; ©adi‡ je p©ipravena
         cmp       bx,ds:[46ch]             ; je impuls hodin ?
         je        WaitDBs3                 ; nen¡ impuls hodin
         loop      WaitDBs2                 ; dal¨¡ ‡ek n¡
         stc                                ; chyba TIME-OUT

; ------ n vrat registr–

WaitDBs9:pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WaitDBus ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na po‘adavek dat disku (CY=chyba)
; -----------------------------------------------------------------------------

WaitDReq PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

; ------ p©¡prava registr–

         mov       dx,ds:[DiskPort]         ; port disku
         add       dx,7                     ; stavov˜ port
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       cx,3                     ; po‡et impuls– hodin

; ------ ‡ek n¡ na p©ipravenost dat

WaitDRq2:mov       bx,ds:[46ch]             ; ‡asova‡
WaitDRq3:sti
         in        al,dx                    ; na‡ten¡ stavov‚ho registru
         test      al,bit3                  ; jsou data p©ipravena ?
         jnz       WaitDRq9                 ; data jsou p©ipravena
         cmp       bx,ds:[46ch]             ; je impuls hodin ?
         je        WaitDRq3                 ; nen¡ impuls hodin
         loop      WaitDRq2                 ; dal¨¡ ‡ek n¡
         stc                                ; chyba TIME-OUT

; ------ n vrat registr–

WaitDRq9:pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WaitDReq ENDP

; *****************************************************************************
;
;                                      data
;
; *****************************************************************************
;þ
SoubCMOS db        'CMOS.BIN',0
SoubMBOT db        'MBOOT.BIN',0

ExisCSou db        'Soubor CMOS$'
ExisMSou db        'Soubor MBOOT$'

ExisSoub db        '.BIN jiz existuje a bude prepsan novym obsahem !$'
NeniSoub db        '.BIN nenalezen !',13,10,'$'

RecCmos  db        'VAROVANI - obsah pameti CMOS bude navracen ze souboru CMOS.BIN !$'
RecMBot  db        'VAROVANI - obsah sektoru MBOOT pevneho disku',13,10
         db        '           bude navracen ze souboru MBOOT.BIN !$'

EscTxt   db        13,10,'   Esc=preruseni operace, jina klavesa=pokracovani: $'

ErrWCSou db        'Chyba zapisu do souboru CMOS.BIN !',13,10,'$'
ErrWMSou db        'Chyba zapisu do souboru MBOOT.BIN !',13,10,'$'
ErrWCmos db        'Chyba zapisu do pameti CMOS !',13,10,'$'
ErrWMSek db        'Chyba zapisu sektoru MBOOT na disk !',13,10,'$'

ErrRCSou db        'Chyba cteni ze souboru CMOS.BIN !',13,10,'$'
ErrRMSek db        'Chyba cteni MBOOT sektoru z disku !',13,10,'$'
ErrRMSou db        'Chyba cteni ze souboru MBOOT.BIN !',13,10,'$'

OKWCSou  db        'Obsah pameti CMOS ulozen do souboru CMOS.BIN.',13,10,'$'

OKRCmos  db        'Obsah pameti CMOS ($'
OKRCmos1 db        '64$'
OKRCmos2 db        '128$'
OKRCmos3 db        '256$'
OKRCmos0 db        ' bajtu) byl navracen ze souboru CMOS.BIN.',13,10
         db        '   K aktualizaci nastaveni CMOS je nyni treba provest',13,10
         db        '   tvrdy RESET pocitace pomoci tlacitka RESET...',13,10,'$'

OKWMSou  db        'Obsah MBOOT sektoru pevneho disku ulozen do souboru MBOOT.BIN.',13,10,'$'
OKRMBot  db        'Obsah MBOOT sektoru pevneho disku byl navracen ze souboru MBOOT.BIN.',13,10,'$'

Param    db        0                        ; parametry
                                            ;  bit 0: 1=£schova pamˆti CMOS
                                            ;  bit 1: 1=n vrat pamˆti CMOS
                                            ;  bit 2: 1=£schova MBOOT
                                            ;  bit 3: 1=n vrat MBOOT
                                            ;  bit 4: 1=rekonstrukce MBOOT
                                            ;  bit 5: 1=detekce parametr– C:
                                            ;  bit 6: 1=detekce parametr– D:
                                            ;  bit 7: 1=operaci bez varovani

TestPar  db        bit1+bit2+bit3+bit4      ; zvolen‚ testy
                                            ;   bit 0: BIOS
                                            ;   bit 1: MBOOT
                                            ;   bit 2: BOOT
                                            ;   bit 3: AT-BUS
                                            ;   bit 4: test ‡itelnosti

SizCmos  dw        64                       ; velikost pamˆti CMOS

MemTxt   db        'Nedostatek pameti k provedeni operace !',13,10,'$'
UvTxt    db        'PCBACK V1.03 - zalohovani konfigurace PC; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte:   C ..... uschova obsahu CMOS do souboru CMOS.BIN',13,10
         db        '           !C .... navrat obsahu CMOS ze souboru CMOS.BIN',13,10
         db        '           M ..... uschova sektoru MBOOT do souboru MBOOT.BIN',13,10
         db        '           !M .... navrat sektoru MBOOT ze souboru MBOOT.BIN',13,10
         db        '           *C .... detekce parametru pevneho disku C:',13,10
         db        '           *D .... detekce parametru pevneho disku D:',13,10
         db        '                   - uvedenim cislic 0 az 4 za parametrem lze',13,10
         db        '                     urcit pouzite testy (implicitne "*C1234"):',13,10
         db        '                              0 = aktualni informace BIOS',13,10
         db        '                              1 = pouzit MASTER BOOT',13,10
         db        '                              2 = pouzit DOS BOOT',13,10
         db        '                              3 = pouzity informace AT-BUS',13,10
         db        '                              4 = pouzit test citelnosti',13,10
;         db        '           R ..... rekonstrukce zniceneho (zavirovaneho) MBOOT sektoru',13,10
         db        '           W ..... provest operaci bez dalsiho varovani'
CRTxt    db        13,10
NulTxt   db        '$'


Disk     db        80h                      ; ‡¡slo pevn‚ho disku

ParDTxt  db        13,10,'Parametry pevneho disku '
ParDTxt1 db        'C:',13,10
         db        '--------------------------',13,10
         db        'testuji... $'

ParDTxN  db        13,'disk nenainstalovan',13,10,'$'
ParDTxN2 db        13,'parametry nelze urcit',13,10,'$'

ParDTxP1 db        13,' pocet sektoru : $'
ParDTxP2 db        13,10,'    pocet hlav : $'
ParDTxP3 db        13,10,'   pocet valcu : $'
ParDTxP4 db        13,10,'sektoru celkem : $'
ParDTxP5 db        13,10,' kapacita [MB] : $'

Sektoru  dw        0                        ; po‡et sektor– na stopu
Stran    dw        0                        ; po‡et stran disku
Valcu    dw        0                        ; po‡et v lc– disku
SektCelk dd        0                        ; po‡et sektor– celkem
BajtSekt dw        512                      ; po‡et bajt– na sektor

DiskPort dw        1f0h                     ; port ©adi‡e disku
BuffBoot dw        Buffer                   ; adresa bufferu pro sektor

TabPart  db        4*10h dup(?)             ; tabulka odd¡l– disku

; Struktura informac¡ AT-BUS:
;
;         0: (2) konfigurace
;         2: (2) po‡et v lc– pevn‚ho disku
;         4: (2) po‡et v lc– v˜mˆnn‚ho disku
;         6: (2) po‡et hlav disku
;         8: (2) po‡et bajt– na stopu
;        10: (2) po‡et bajt– na sektor
;        12: (2) po‡et sektor– na stopu
;        14: (2) data 1
;        16: (2) data 2
;        18: (2) data 3
;        20: (20) s‚riov‚ ‡¡slo (text ASCII doplnˆn˜ mezerami)
;        40: (2) typ ©adi‡e pevn‚ho disku
;        42: (2) velikost bufferu
;        44: (2) po‡et ECC bajt–
;        46: (8) verze ©adi‡e disku (text ASCII doplnˆn˜ mezerami)
;        54: (40) model disku (text ASCII doplnˆn˜ mezerami)
;        94: (2) sektor na interrupt
;        96: (2)
;        98: (2) ochrana z pisu

BuffATB  db        512 dup(?)               ; buffer AT-BUS, pomocn˜ buffer

Buffer   db        512 dup(?)               ; buffer pro operace

Code     ENDS
         END       Start

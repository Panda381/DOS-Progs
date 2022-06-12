
Code     SEGMENT
         ASSUME    cs:Code,ds:Data

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

TAB      EQU       9
CR       EQU       13
LF       EQU       10

InpBSize EQU       1000h                    ; velikost vstupn¡ho bufferu
OutBSize EQU       1000h                    ; velikost v˜stupn¡ho bufferu
LabBSize EQU       0c000h                   ; velikost bufferu n vˆ¨t¡

MaxOutB  EQU       8                        ; maxim ln¡ po‡et v˜stupn¡ch bajt–

; V cel‚m programu plat¡, ‘e DS=ES=datov˜ segment !

; ------ inicializace registr–

Start:   mov       ax,SEG Data
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       ds:[SegPSP],es           ; adresa segmentu PSP

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ rozbor p©¡kazov‚ho © dku

         call      Rozbor                   ; rozbor p©¡kazov‚ho © dku
         jnc       Start1                   ; zad n¡ OK
         mov       dx,offset HelpTxt        ; text n povˆdy
Chyba:   call      ClosFile                 ; uzav©en¡ v¨ech soubor–
         call      DispTxt                  ; zobrazen¡ textu chyby
         mov       ax,4c01h
         int       21h

; ------ otev©en¡ vstupn¡ho souboru

Start1:  mov       dx,offset InpSoub        ; jm‚no vstupn¡ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ vstupn¡ho souboru
         mov       dx,offset InpErr         ; text - soubor nenalezen
         jc        Chyba                    ; nenalezen
         mov       ds:[InpIdnt],ax          ; identifik tor vstupn¡ho souboru

; ------ vytvo©en¡ v˜stupn¡ho souboru

         mov       dx,offset OutSoub        ; jm‚no v˜stupn¡ho souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         mov       dx,offset WritErr        ; text - chyba z pisu
         jc        Chyba                    ; nelze vytvo©it
         mov       ds:[OutIdnt],ax          ; identifik tor v˜stupn¡ho souboru

; ------ vytvo©en¡ souboru v˜pisu

         test      byte ptr ds:[Param],bit2 ; je v˜pis ?
         jz        Start2                   ; nen¡ v˜pis
         mov       dx,offset LstSoub        ; jm‚no souboru v˜pisu
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ souboru v˜pisu
         mov       dx,offset ListErr        ; text - chyba z pisu
         jc        Chyba                    ; nelze vytvo©it
         mov       ds:[LstIdnt],ax          ; identifik tor souboru v˜pisu

; ------ p©¡prava jm‚na vstupn¡ho souboru

Start2:  mov       si,offset InpSoub
Start22: mov       dx,si
Start23: cmp       byte ptr ds:[si],0
         je        Start26
         inc       si
         cmp       byte ptr ds:[si-1],"\"
         je        Start22
         cmp       byte ptr ds:[si-1],":"
         je        Start22
         jmp       short Start23
Start26: mov       byte ptr ds:[si],'$'
         mov       ds:[InpSoub0],dx         ; adresa jm‚na souboru pro v˜pis



         push      ds
         pop       es


; ------ p©eklad - prvn¡ pr–chod

         call      Assm                     ; p©eklad - prvn¡ pr–chod

; ------ p©eklad - druh˜ pr–chod

         or        byte ptr ds:[Param],bit7 ; p©¡znak druh‚ho pr–chodu
         call      Assm                     ; p©eklad - druh˜ pr–chod

; ------ uzav©en¡ v¨ech soubor–

         call      ClosFile                 ; uzav©en¡ v¨ech soubor–

; ------ p©ekl dan˜ soubor

         mov       dx,offset PreklTxt
         call      DispTxt
         mov       dx,ds:[InpSoub0]
         call      DispTxt
         call      DispCR

; ------ zobrazen¡ po‡tu chyb

         mov       dx,offset ChybTxt
         call      DispTxt
         mov       ax,ds:[CitChyb]          ; po‡et chyb
         or        ax,ax
         jnz       Start85
         mov       dx,offset ZadnaTxt
         call      DispTxt
         jmp       short Start86
Start85: call      DispNum
Start86: call      DispCR

; ------ zobrazen¡ voln‚ pamˆti

         mov       dx,offset VolnaTxt
         call      DispTxt
         mov       ax,LabBSize              ; velikost bufferu symbol–
         sub       ax,ds:[LabBuffS]         ; velikost bufferu symbol–
         call      DispNum
         mov       al," "
         call      DispChr
         mov       al,"B"
         call      DispChr
         call      DispCR

; ------ konec OK

         mov       ax,4c00h
         int       21h

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
;        od© dkov n¡ textu
; -----------------------------------------------------------------------------

DispCR   PROC      NEAR

         push      dx
         mov       dx,offset CRTxt
         call      DispTxt
         pop       dx
         ret

DispCR   ENDP

; -----------------------------------------------------------------------------
;        z pis ‡¡sla AX do bufferu ES:DI
; -----------------------------------------------------------------------------

ZapNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ dek¢dov n¡ ‡¡sla do z sobn¡ku

         xor       cx,cx                    ; ‡¡ta‡ znak–
         mov       bx,10
ZapNum2: xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       ZapNum2

; ------ ulo‘en¡ ‡¡sla

         cld
ZapNum3: pop       ax
         add       al,"0"
         stosb
         loop      ZapNum3

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZapNum   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ dek¢dov n¡ ‡¡sla do z sobn¡ku

         xor       cx,cx                    ; ‡¡ta‡ znak–
         mov       bx,10
DispNum2:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum2

; ------ zobrazen¡ ‡¡sla

DispNum3:pop       ax
         add       al,"0"
         call      DispChr
         loop      DispNum3

; ------ n vrat registr–

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
         push      dx

         mov       dl,al
         mov       ah,2
         int       21h

         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ v¨ech soubor–
; -----------------------------------------------------------------------------

ClosFile PROC      NEAR

         push      ax
         push      bx
         mov       bx,ds:[InpIdnt]          ; identifik tor vstupn¡ho souboru
         call      Clos0Fil                 ; uzav©en¡ vstupn¡ho souboru
         mov       bx,ds:[OutIdnt]          ; identifik tor v˜stupn¡ho souboru
         call      Clos0Fil                 ; uzav©en¡ v˜stupn¡ho souboru
         mov       bx,ds:[LstIdnt]          ; identifik tor souboru v˜pisu
         call      Clos0Fil                 ; uzav©en¡ souboru v˜pisu
         pop       bx
         pop       ax
         ret

Clos0Fil:or        bx,bx
         jz        Clos0Fl2
         mov       ah,3eh
         int       21h
Clos0Fl2:ret

ClosFile ENDP

; *****************************************************************************
;
;                              P©eklad
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        p©eklad
; -----------------------------------------------------------------------------

Assm     PROC      NEAR

; ------ resetov n¡ vstupn¡ho souboru

         mov       bx,ds:[InpIdnt]          ; identifik tor vstupn¡ho souboru
         mov       ax,4200h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; resetov n¡ vstupn¡ho souboru
         mov       word ptr ds:[InpBuffR],offset InpBuff ; ‡tec¡ adresa z bufferu
         mov       word ptr ds:[InpBuffE],offset InpBuff ; konec dat v bufferu
         mov       word ptr ds:[InpCitac],0 ; ‡¡ta‡ vstupn¡ch © dk–

; ------ p©¡prava ukazatel– k dek¢dov n¡ programu

         mov       word ptr ds:[Pointer],100h ; ukazatel programu
         mov       word ptr ds:[RadixN],10  ; ‡¡seln  soustava

; ------ p©¡prava jednoho © dku k dek¢dov n¡

Assm1:   call      NulORad                  ; vypr zdnˆn¡ v˜stupn¡ho © dku
         call      ReadIRad                 ; na‡ten¡ vstupn¡ho © dku
         jnc       Assm2                    ; nen¡ je¨tˆ konec souboru
         jmp       Assm9                    ; konec souboru

; ------ vypu¨tˆn¡ mezer ze za‡ tku © dku

Assm2:   call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        Assm1                    ; nen¡ nic - dal¨¡ © dek

; ------ dek¢dov n¡ symbolu

Assm3:   call      DekSymb                  ; dek¢dov n¡ symbolu
         jnc       Assm4                    ; OK

Assm32:  mov       dx,offset PovelErr       ; text - nezn m˜ povel
Assm33:  xor       bx,bx                    ; nen¡ druh˜ text
Assm34:  call      DispErr                  ; zobrazen¡ chyby
         jmp       short Assm1

; ------ pokus o p©eklad jako k¢d instrukce

Assm4:   call      SrcInst                  ; vyhled n¡ k¢du instrukce
         jnc       Assm6                    ; je to instrukce OK

; ------ test, zda je to n vˆ¨t¡

         cmp       byte ptr ds:[si],":"     ; je to n vˆ¨t¡ ?
         jne       Assm5                    ; nen¡ to n vˆ¨t¡
         inc       si                       ; p©esko‡en¡ znaku ":"

; ------ definice n vˆ¨t¡

Assm42:  mov       ax,ds:[Pointer]          ; aktu ln¡ ukazatel
         call      DefSym                   ; definice symbolu

; ------ vypu¨tˆn¡ mezer

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        Assm1                    ; nen¡ dal¨¡ text

; ------ dek¢dov n¡ dal¨¡ho symbolu

         call      DekSymb                  ; dek¢dov n¡ dal¨¡ho symbolu
         jc        Assm32                   ; nezn m˜ povel

; ------ dek¢dov n¡ jako instrukce

         call      SrcInst                  ; vyhled n¡ k¢du instrukce
         jnc       Assm6                    ; je to instrukce OK
         jmp       short Assm32             ; nezn m˜ povel

; ------ nezn m‚ n vˆ¨t¡ bez ":" - test dal¨¡ho povelu

Assm5:   call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        Assm32                   ; to je chyba
         call      DekSymb                  ; dek¢dov n¡ dal¨¡ho symbolu
         jc        Assm32                   ; chyba
         call      SrcInst                  ; vyhled n¡ k¢du instrukce
         jc        Assm32                   ; chyba
         mov       si,offset InpRadek       ; buffer vstupn¡ho © dku
         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         call      DekSymb                  ; dek¢dov n¡ symbolu
         jmp       short Assm42             ; dek¢dov n¡ symbolu

; ------ nalezen k¢d instrukce AX - test, zda nen sleduje ":"

Assm6:   cmp       byte ptr ds:[si],":"     ; m  to b˜t jako n vˆ¨t¡ ?
         jne       Assm62

; ------ chyba - rezervovan‚ slovo jako n vˆ¨t¡

         mov       dx,offset RezerErr
         mov       bx,offset SymTxt
         jmp       short Assm34

; ------ ulo‘en¡ k¢du 1-bajtov‚ instrukce

Assm62:  or        ah,ah                    ; je 1-bajtov  instrukce ?
         jnz       Assm64                   ; nen¡ 1-bajtov  instrukce
         call      WritOChr                 ; z pis bajtu
         jmp       short Assm1

; ------ skok na obsluhu k¢du

Assm64:  jmp       ax                       ; skok na obsluhu povelu

; ------ vypr zdnˆn¡ v˜stupn¡ho bufferu

Assm9:   call      NulORad                  ; vypr zdnˆn¡ v˜stupn¡ho © dku
         call      WritOBuf                 ; vypr zdnˆn¡ v˜stupn¡ho bufferu
         ret

Assm     ENDP

;; -----------------------------------------------------------------------------
;;        ADC
;; -----------------------------------------------------------------------------
;;þ
;; ------ na‡ten¡ prvn¡ho operandu
;
;AADC:    call      DekOper                  ; na‡ten¡ prvn¡ho operandu
;         jc        ALD0                     ; chyba - m lo operand–
;         xchg      ax,bx                    ; BL <- k¢d prvn¡ho opreandu
;         mov       dx,cx                    ; DX <- parametr prvn¡ho operandu
;
; ------ na‡ten¡ druh‚ho operandu
;






; -----------------------------------------------------------------------------
;        LD R2,a   LD (R2),A  LD (a),HL  LD (a),A  LD R,d  LD A,(R2)  LD HL,(a)
;        LD A,(a)  LD R,R
; -----------------------------------------------------------------------------
;þ
; ------ na‡ten¡ prvn¡ho operandu

ALD:     call      DekOper                  ; na‡ten¡ prvn¡ho operandu
         jc        ALD0                     ; chyba - m lo operand–
         xchg      ax,bx                    ; BL <- k¢d prvn¡ho operandu
         mov       dx,cx                    ; DX <- parametr prvn¡ho operandu

; ------ na‡ten¡ druh‚ho operandu

         call      DekOper                  ; na‡ten¡ druh‚ho operandu
         mov       bh,al                    ; BH <- k¢d druh‚ho operandu
         mov       ax,bx                    ; AX <- parametry operand–
         jnc       ALD1                     ; druh˜ operand na‡ten OK

; ------ chyba - zad no m lo operand– instrukce

ALD0:    mov       dx,offset NeOprErr       ; text - chybˆj¡c¡ operand
         call      DispErr0
ALD09:   jmp       Assm1

; ------ prvn¡ operand je registr 1 bajt

ALD1:    cmp       al,7
         ja        ALD4                     ; nen¡ operand 1 bajt
         shl       al,1
         shl       al,1
         shl       al,1                     ; prvn¡ operand * 8

; ------ druh˜ operand je tak‚ registr 1 bajt

         cmp       ah,7
         ja        ALD2

; ------ z pis k¢du instrukce

         or        al,ah                    ; sestaven¡ k¢du instrukce
         or        al,40h
         call      WritOChr                 ; z pis k¢du instrukce

; ------ z pis offsetu z prvn¡ho operandu

         or        dh,dh                    ; byl prefix v prvn¡m operandu ?
         jz        ALD12                    ; nebyl prefix
         cmp       bl,6                     ; byl (HL) ?
         jne       ALD12                    ; nebyl
         mov       al,dl                    ; offset instrukce
         call      WritOChr                 ; z pis offsetu

; ------ z pis offsetu z druh‚ho operandu

ALD12:   or        ch,ch                    ; byl prefix v druh‚m operandu ?
         jz        ALD09                    ; nebyl
         cmp       bh,6                     ; byl (HL) ?
         jne       ALD09                    ; nebyl
ALD13:   mov       al,cl
ALD14:   call      WritOChr                 ; z pis bajtu
         jmp       short ALD09

; ------ druh˜ operand je ‡¡slo

ALD2:    cmp       ah,80h
         jne       ALD3                     ; nen¡ ‡¡slo
         or        al,6                     ; sestaven¡ k¢du instrukce
         call      WritOChr                 ; z pis k¢du instrukce

; ------ z pis offsetu z prvn¡ho operandu

         or        dh,dh                    ; byl prefix v prvn¡m operandu ?
         jz        ALD13                    ; nebyl prefix
         cmp       bl,6                     ; byl (HL) ?
         jne       ALD13                    ; nebyl
         mov       al,dl                    ; offset instrukce
         call      WritOChr                 ; z pis offsetu
         jmp       short ALD13

; ------ druh˜ operand je adresa, prvn¡ operand mus¡ b˜t A

ALD3:    cmp       bl,7                     ; byl A ?
         jne       ALD54                    ; nespr vn˜ operand
         cmp       ah,81h
         jne       ALD34
         mov       al,32h
         jmp       short ALD14

; ------ jinak mus¡ b˜t prvn¡ operand A a druh˜ (DE) nebo (BC)

ALD34:   mov       al,ah                    ; druh˜ operand
         sub       al,60h                   ; je (DE) ?
         jb        ALD54                    ; nespr vn˜ operand
         cmp       al,10h
         ja        ALD54                    ; nespr vn˜ operand
         or        al,0ah
         jmp       short ALD14              ; z pis k¢du instrukce

; ------ prvn¡ operand je dvojregistr

ALD4:    cmp       al,40h
         ja        ALD6

; ------ druh˜ operand je ‡¡slo

         cmp       ah,80h
         jne       ALD5

; ------ z pis k¢du instrukce a adresy

         sub       al,10h-1                 ; k¢du instrukce
ALD44:   call      WritOChr                 ; z pis k¢du instrukce
         xchg      ax,cx
         call      WritOChr
         mov       al,ah
ALD46:   jmp       short ALD14

; ------ druh˜ operand je adresa (prvn¡ operand je HL)

ALD5:    cmp       ah,81h
         jne       ALD54
         cmp       bl,30h
         jne       ALD52
         mov       al,2ah
         jmp       short ALD44

; ------ prvn¡ operand BC, DE, SP

ALD52:   cmp       bl,10h
         jb        ALD54
         cmp       bl,40h
         ja        ALD54
         mov       al,0edh
         call      WritOChr                 ; z pis prefixu
         mov       al,bl
         add       al,4bh                   ; k¢d instrukce
         jmp       short ALD44

ALD54:   jmp       short ALD8

; ------ prvn¡ operand je (BC) nebo (DE)

ALD6:    cmp       al,70h
         ja        ALD7

; ------ druh˜ operand mus¡ b˜t A

         cmp       ah,7
         jne       ALD8

; ------ ulo‘en¡ k¢du instrukce

         sub       al,60h-2
         jmp       short ALD46

; ------ prvn¡ operand je adresa

ALD7:    cmp       al,81h
         jne       ALD8

; ------ druh˜ operand je HL

         mov       cx,dx                    ; CX <- prvn¡ operand
         cmp       ah,30h
         jne       ALD74
         mov       al,22h
         jmp       short ALD44

; ------ druh˜ operand je A

ALD74:   cmp       ah,7
         jne       ALD76
         mov       al,32h
         jmp       short ALD44

; ------ druh˜ operand je BC, DE, SP

ALD76:   cmp       ah,10h
         jb        ALD8
         cmp       ah,40h
         ja        ALD8
         mov       al,0edh
         call      WritOChr                 ; z pis prefixu
         mov       al,ah
         add       al,43h
         jmp       short ALD44

; ------ chyba - nepovolen  kombinace operand–

ALD8:    mov       dx,offset NeKomErr       ; text - nepovolen  kombinace
         call      DispErr0
ALD9:    jmp       Assm1

; -----------------------------------------------------------------------------
;        JR c,e      JR e
; -----------------------------------------------------------------------------

; ------ dek¢dov n¡ podm¡nky

AJR:     mov       bx,si                    ; £schova adresy
         call      ReadCond                 ; na‡ten¡ podm¡nky
         jc        AJR7                     ; nen¡ podm¡nka

; ------ test podm¡nky

         cmp       al,20h                   ; kontrola podm¡nky
         jb        AJR4                     ; podm¡nka je OK
         mov       dx,offset NeConErr       ; text - nepovolen  podm¡nka
         call      DispErr0                 ; zobrazen¡ hl ¨en¡
         jmp       short AJR7

; ------ stanoven¡ k¢du instrukce

AJR4:    or        al,20h
         jmp       short ADJNZ1

; ------ je instrukce JR e

AJR7:    mov       si,bx                    ; n vrat ukazatele textu
         mov       al,18h
         jmp       short ADJNZ1

; -----------------------------------------------------------------------------
;        DJNZ e
; -----------------------------------------------------------------------------
;þ
ADJNZ:   mov       al,10h                   ; k¢d povelu
ADJNZ1:  call      WritOChr                 ; z pis bajtu do bufferu

; ------ p©¡prava adresy

         call      DekVyraz                 ; dek¢dov n¡ adresy
         jc        ADJNZ22

; ------ offset skoku

         mov       dx,ds:[OutAdr]           ; adresa po‡ tku © dku
         inc       dx
         inc       dx                       ; n sleduj¡c¡ adresa
         sub       ax,dx                    ; offset skoku

; ------ kontrola rozsahu skoku

         cmp       ax,127                   ; maxim ln¡ skok
         jg        ADJNZ2                   ; p©ete‡en¡
         cmp       ax,-128                  ; minim ln¡ skok
         jge       ADJNZ3                   ; skok je OK

; ------ je p©ete‡en¡ skoku

         neg       ax                       ; oprava polarity
ADJNZ2:  sub       ax,127                   ; p©ete‡en¡ skoku
         mov       di,offset RelErr0        ; buffer k dek¢dov n¡ ‡¡sla
         call      ZapNum                   ; dek¢dov n¡ ‡¡sla do bufferu
         cld
         mov       al," "
         stosb
         mov       al,"B"
         stosb
         mov       al,"$"
         stosb
         mov       dx,offset RelErr
         call      DispErr0                 ; hl ¨en¡ o p©ete‡en¡ skoku
ADJNZ22: xor       ax,ax                    ; n hradn¡ offset skoku

; ------ z pis offsetu skoku

ADJNZ3:  call      WritOChr                 ; z pis offsetu skoku
         jmp       Assm1

; -----------------------------------------------------------------------------
;        CALL c,a      CALL a
; -----------------------------------------------------------------------------

; ------ dek¢dov n¡ podm¡nky

ACALL:   call      ReadCond                 ; na‡ten¡ podm¡nky
         jc        ACALL5                   ; nen¡ podm¡nka

; ------ sestaven¡ k¢du instrukce

         add       al,0c4h
         jmp       short ACALL6

; ------ z pis k¢du instrukce

ACALL5:  mov       al,0cdh                  ; je CALL a
ACALL6:  call      WritOChr                 ; z pis k¢du instrukce

; ------ z pis adresy instrukce CALL

ACALL7:  call      DekVyraz                 ; dek¢dov n¡ adresy skoku
         call      WritOChr                 ; z pis bajtu LOW
         mov       al,ah
         call      WritOChr                 ; z pis bajtu HIGH
         jmp       Assm1

; -----------------------------------------------------------------------------
;        JP c,a      JP a
; -----------------------------------------------------------------------------

; ------ na‡ten¡ podm¡nky

AJP:     call      ReadCond                 ; na‡ten¡ podm¡nky
         jc        AJP2                     ; nen¡ podm¡nka

; ------ k¢d operace

         add       al,0c2h
         jmp       short AJP6

; ------ dek¢dov n¡ operandu, nen¡-li podm¡nka

AJP2:    call      DekOper                  ; dek¢dov n¡ operandu
         jc        AJP5                     ; chyba - nen¡ operand

; ------ operand je (HL)

         cmp       al,6
         je        AJP3
         cmp       al,30h
         jne       AJP4
AJP3:    mov       al,0e9h
         jmp       short AJP8               ; z pis k¢du instrukce

; ------ operand je v˜raz

AJP4:    cmp       al,80h                   ; je v˜raz ?
         jne       AJP5                     ; nepovolen˜ operand
         push      cx
         mov       al,0c3h
         call      WritOChr                 ; z pis k¢du instrukce
         pop       ax
         jmp       short AJP7

; ------ nen¡ operand instrukce

AJP5:    mov       dx,offset NeOprErr
         call      DispErr0                 ; chyba - nen¡ operand

; ------ z pis k¢du instrukce JP

         mov       al,0c3h                  ; je JP a
AJP6:    call      WritOChr                 ; z pis k¢du instrukce

; ------ z pis adresy instrukce JP

         call      DekVyraz                 ; dek¢dov n¡ adresy skoku
AJP7:    call      WritOChr                 ; z pis bajtu LOW
         mov       al,ah
AJP8:    call      WritOChr                 ; z pis bajtu HIGH
         jmp       Assm1

; -----------------------------------------------------------------------------
;        dek¢dov n¡ jednoho operandu instrukce (ulo‘¡ prefix IX, IY)
; -----------------------------------------------------------------------------
; VSTUP: AL=k¢d operandu (CY=chyba)
;               0 = B
;               1 = C
;               2 = D
;               3 = E
;               4 = H, XH, YH
;               5 = L, XL, YL
;               6 = (HL), (IX+e), (IY+e)
;               7 = A
;             10h = BC
;             20h = DE
;             30h = HL, IX, IY
;             40h = SP
;             50h = AF
;             60h = (BC)
;             70h = (DE)
;             80h = v˜raz
;             81h = (v˜raz)
;         CH=prefix instrukce IX,IY (0=nen¡)
;         CL=offset instrukce IX, IY
;         CX=hodnota v˜razu
; -----------------------------------------------------------------------------
;þ
DekOper  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx
         push      di
         xor       cx,cx                    ; nen¡ prefix

; ------ vypu¨tˆn¡ mezer

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jnc       DekOpr10
DekOper0:jmp       DekOper9                 ; chyba

; ------ test, zda je z vorka

DekOpr10:call      ReadILft                 ; vypu¨tˆn¡ lev‚ z vorky
         jc        DekOper4                 ; nen¡ z vorka

; ------ vypu¨tˆn¡ mezer za z vorkou

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        DekOper0                 ; chyba
         mov       bx,si                    ; BX <- £schova adresy

; ------ dek¢dov n¡ symbolu

         call      DekSymb                  ; dek¢dov n¡ symbolu
         jc        DekOper2                 ; nen¡ platn˜ symbol

; ------ nalezen¡ operandu v tabulce

         mov       di,offset TabReg         ; tabulka registr–
         call      GetSymb                  ; nalezen¡ symbolu v tabulce
         jc        DekOper2                 ; symbol nenalezen

; ------ kontrola oper toru (povoleno HL, IX, IY, BC a DE)

         mov       ch,ah                    ; prefix instrukce
         add       al,60h-10h               ; korekce
         cmp       al,60h
         je        DekOper1                 ; BC povoleno
         cmp       al,70h
         je        DekOper1                 ; DE povoleno
         cmp       al,80h
         stc
         jne       DekOper9                 ; chyba - nepovolen˜ operand

; ------ na‡ten¡ offsetu IX, IY

         or        ch,ch                    ; je prefix IX, IY ?
         jz        DekOpr14                 ; nen¡ prefix
         call      DekVyraz                 ; dek¢dov n¡ v˜razu
         jc        DekOper9                 ; chyba
         cmp       ax,127
         jg        DekOpr11
         cmp       ax,-128
         jge       DekOpr12

; ------ p©ete‡en¡ indexu

DekOpr11:mov       dx,offset PretErr        ; chyba p©ete‡en¡
         call      DispErr0                 ; zobrazen¡ chyby
DekOpr12:mov       cl,al                    ; offset instrukce
DekOpr14:mov       al,6                     ; instrukce (HL)

; ------ test prav‚ z vorky

DekOper1:call      ReadIRgh                 ; test prav‚ z vorky
         jc        DekOper9                 ; nen¡ prav  z vorka
         jmp       short DekOper8           ; vypu¨tˆn¡ ‡ rky

; ------ nen¡ registr - na‡ten¡ v˜razu

DekOper2:mov       si,bx                    ; n vrat ukazatele textu
         call      DekVyraz                 ; na‡ten¡ v˜razu
         jc        DekOper9                 ; chyba
         xchg      ax,cx                    ; CX <- hodnota v˜razu
         mov       al,81h                   ; je v˜raz v z vorce
         jmp       short DekOper1           ; test z vorky

; ------ nen¡ z vorka

DekOper4:mov       bx,si                    ; BX <- £schova adresy

; ------ dek¢dov n¡ symbolu

         call      DekSymb                  ; dek¢dov n¡ symbolu
         jc        DekOper6                 ; nen¡ platn˜ symbol

; ------ nalezen¡ operandu v tabulce

         mov       di,offset TabReg         ; tabulka registr–
         call      GetSymb                  ; nalezen¡ symbolu v tabulce
         mov       ch,ah                    ; prefix instrukce
         jnc       DekOper8                 ; symbol nalezen OK

; ------ nen¡ registr - na‡ten¡ v˜razu

DekOper6:mov       si,bx                    ; n vrat ukazatele textu
         call      DekVyraz                 ; na‡ten¡ v˜razu
         jc        DekOper9                 ; chyba
         xchg      ax,cx                    ; CX <- hodnota v˜razu
         mov       al,80h                   ; je v˜raz

; ------ ulo‘en¡ prefixu instrukce pro IX a IY

DekOper8:cmp       al,80h
         jae       DekOpr82                 ; nen¡ prefix
         or        ch,ch                    ; je prefix ?
         jz        DekOpr82                 ; nen¡ prefix
         push      ax
         mov       al,ch                    ; prefix
         call      WritOChr                 ; ulo‘en¡ prefixu
         pop       ax

; ------ vypu¨tˆn¡ ‡ rky za operandem

DekOpr82:call      ReadICar                 ; vypu¨tˆn¡ ‡ rky za operandem
         clc

; ------ n vrat registr–

DekOper9:pop       di
         pop       dx
         pop       bx
         ret

DekOper  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ v˜razu -> AX (CY=chyba)
; -----------------------------------------------------------------------------

DekVyraz PROC      NEAR

         push      bx
         push      cx

; ------ vypu¨tˆn¡ mezer na za‡ tku v˜razu

         xor       cx,cx                    ; CX <- p©¡znak, ‘e nebylo ‡¡slo
         xor       bx,bx                    ; st©ada‡ ‡¡sla
         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        DekVyrz9                 ; chyba

; ------ vypu¨tˆn¡ mezer p©ed dal¨¡m ‡¡slem

DekVyrz1:call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        DekVyrz8                 ; konec v˜razu

; ------ test, zda n sleduje znak "+"

         cmp       byte ptr ds:[si],"+"
         jne       DekVyrz3
DekVyrz2:inc       si                       ; p©esko‡en¡ znaku "+"

; ------ vypu¨tˆn¡ mezer za znam‚nkem

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        DekVyrz9                 ; chyb¡ operand

; ------ test, zda n sleduje znam‚nko "+"

         cmp       byte ptr ds:[si],"+"
         je        DekVyrz2                 ; vypu¨tˆn¡ znam‚nka "+"

; ------ test, zda n sleduje znam‚nko "-"

         cmp       byte ptr ds:[si],"-"
         je        DekVyrz4                 ; zmˆna znam‚nka ‡¡sla

; ------ na‡ten¡ ‡¡sla

DekVrz22:call      DekVMul                  ; na‡ten¡ ‡¡sla
         jc        DekVyrz9                 ; chyba
         inc       cx                       ; p©¡znak platn‚ho ‡¡sla
         add       bx,ax                    ; p©i‡ten¡ ‡¡sla ke st©ada‡i
         jmp       short DekVyrz1           ; dal¨¡ operand

; ------ test, zda n sleduje znak "-"

DekVyrz3:cmp       byte ptr ds:[si],"-"     ; n sleduje znam‚nko "-" ?
         jne       DekVyrz5                 ; nen¡ ani znam‚nko "-"
DekVyrz4:inc       si                       ; p©esko‡en¡ znam‚nka "-"

; ------ vypu¨tˆn¡ mezer za znam‚nkem

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        DekVyrz9                 ; chyb¡ operand

; ------ test, zda n sleduje znam‚nko "+"

         cmp       byte ptr ds:[si],"+"
         je        DekVyrz4                 ; vypu¨tˆn¡ znam‚nka "+"

; ------ test, zda n sleduje znam‚nko "-"

         cmp       byte ptr ds:[si],"-"
         je        DekVyrz2                 ; zmˆna znam‚nka ‡¡sla

; ------ na‡ten¡ ‡¡sla

         call      DekVMul                  ; na‡ten¡ ‡¡sla
         jc        DekVyrz9                 ; chyba
         inc       cx                       ; p©¡znak platn‚ho ‡¡sla
         sub       bx,ax                    ; ode‡ten¡ ‡¡sla od st©ada‡e
         jmp       short DekVyrz1           ; dal¨¡ operand

; ------ na‡ten¡ ‡¡sla, pokud je¨tˆ nebylo nic

DekVyrz5:jcxz      DekVrz22                 ; na‡ten¡ ‡¡sla (je¨tˆ nic nebylo)

; ------ n vrat registr–

DekVyrz8:clc
DekVyrz9:xchg      ax,bx                    ; AX <- na‡¡tan  hodnota
         pop       cx
         pop       bx
         ret

DekVyraz ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla s n soben¡m a dˆlen¡m  -> AX
; -----------------------------------------------------------------------------

DekVMul  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx

; ------ na‡ten¡ prvn¡ho operandu

         call      DekCisl                  ; na‡ten¡ prvn¡ho operandu
         jc        DekVMul9                 ; chyba
         xchg      ax,bx                    ; BX <- £schova prvn¡ho operandu

; ------ vypu¨tˆn¡ n sleduj¡c¡ch mezer

DekVMul1:call      ReadISpc                 ; vypu¨tˆn¡ dal¨¡ch mezer
         jc        DekVMul8                 ; konec v˜razu

; ------ test, zda n sleduje znak "*"

         cmp       byte ptr ds:[si],"*"
         jne       DekVMul3
         inc       si                       ; p©esko‡en¡ znaku "*"

; ------ vypu¨tˆn¡ mezer po druh˜ operand

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        DekVMul9                 ; to je chyba

; ------ na‡ten¡ druh‚ho operandu

         call      DekCisl                  ; na‡ten¡ druh‚ho operandu
         jc        DekVMul9                 ; chyba

; ------ vyn soben¡ operand–

         mul       bx                       ; vyn soben¡ operand–
         xchg      ax,bx                    ; BX <- nov  hodnota st©ada‡e

; ------ test, zda je p©ete‡en¡ ‡¡sla

         or        dx,dx                    ; je p©ete‡en¡ ‡¡sla ?
         jz        DekVMul1                 ; nen¡ p©ete‡en¡ ‡¡sla

; ------ chyba p©ete‡en¡ v˜razu

DekVMul2:mov       dx,offset PretErr
         call      DispErr0                 ; chybov‚ hl ¨en¡
         stc
         jmp       short DekVMul9

; ------ test, zda n sleduje znak "/"

DekVMul3:cmp       byte ptr ds:[si],"/"     ; n sleduje znak "/" ?
         jne       DekVMul8                 ; nen sleduje znak "/"
         inc       si                       ; p©esko‡en¡ znaku "/"

; ------ vypu¨tˆn¡ mezer po druh˜ operand

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         jc        DekVMul9                 ; to je chyba

; ------ na‡ten¡ druh‚ho operandu

         call      DekCisl                  ; na‡ten¡ druh‚ho operandu
         jc        DekVMul9                 ; chyba

; ------ test, zda bude p©ete‡en¡ ‡¡sla

         or        ax,ax                    ; je dˆlen¡ nulou ?
         jz        DekVMul2                 ; p©ete‡en¡
         xor       dx,dx                    ; DX <- 0
         xchg      ax,bx                    ; AX <- st©ada‡, BX <- 2. operand

; ------ vydˆlen¡ operand–

         div       bx                       ; vydˆlen¡ operand–
         xchg      ax,bx                    ; BX <- nov  hodnota st©ada‡e
         jmp       short DekVMul1

; ------ n vrat registr–

DekVMul8:clc
DekVMul9:xchg      ax,bx                    ; AX <- na‡ten‚ ‡¡slo
         pop       dx
         pop       bx
         ret

DekVMul  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ jednoho ‡¡sla -> AX (symbol nebo konstanta), CY=chyba
; -----------------------------------------------------------------------------

DekCisl  PROC      NEAR

; ------ test, zda je p©ipraven znak "("

         call      ReadILft                 ; test lev‚ z vorky
         jc        DekCisl1                 ; nen¡ p©ipraven znak "("

; ------ dek¢dov n¡ v˜razu v z vorce

         call      DekVyraz                 ; dek¢dov n¡ v˜razu v z vorce
         jc        DekCisl9                 ; chyba

; ------ test, zda je ukon‡ovac¡ znak ")"

         call      ReadIRgh                 ; test prav‚ z vorky
         jmp       short DekCisl9

; ------ test, zda je p©ipraven znak uvozovek

DekCisl1:mov       ah,ds:[si]               ; p©ipraven˜ znak
         cmp       ah,'"'
         je        DekCisl2
         cmp       ah,"'"
         jne       DekCisl3
DekCisl2:inc       si                       ; p©esko‡en¡ znaku uvozovek

; ------ na‡ten¡ prvn¡ho znaku v˜razu

         call      ReadIChr                 ; na‡ten¡ prvn¡ho znaku
         jc        DekCisl9                 ; chyba

; ------ test, zda je konec v˜razu

         cmp       ah,ds:[si]               ; n sleduj¡ uvozovky ?
         mov       ah,0
         je        DekCisl9                 ; n sleduj¡ uvozovky - je konec

; ------ na‡ten¡ dal¨¡ho znaku v˜razu

         mov       ah,al                    ; AH <- prvn¡ znak
         call      ReadIChr                 ; na‡ten¡ dal¨¡ho znaku
         jc        DekCisl9                 ; chyba

; ------ test, zda n sleduje znak uvozovek

         cmp       byte ptr ds:[si],'"'
         je        DekCsl22
         cmp       byte ptr ds:[si],"'"
         stc
         jne       DekCisl9
DekCsl22:inc       si                       ; p©esko‡en¡ znaku uvozovek
         clc
         jmp       short DekCisl9

; ------ £schova registr–

DekCisl3:push      dx
         push      di

; ------ test, zda je p©ipraven znak ‡¡slice

         mov       al,ds:[si]               ; p©ipraven˜ znak
         cmp       al,"0"
         jb        DekCisl5
         cmp       al,"9"
         ja        DekCisl5

; ------ na‡ten¡ ‡¡sla

         call      DekNum                   ; na‡ten¡ ‡¡sla
         jnc       DekCisl8                 ; ‡¡slo je OK
         mov       dx,offset PretErr        ; text - p©ete‡en¡ v˜razu
         jmp       short DekCisl7

; ------ na‡ten¡ symbolu

DekCisl5:call      DekSymb                  ; dek¢dov n¡ symbolu
         mov       dx,offset NeDefErr       ; text - nedefinovan˜ symbol
         jc        DekCisl7                 ; chyba
         call      SrcSym                   ; vyhled n¡ symbolu
         jnc       DekCisl8                 ; symbol nalezen OK
         test      byte ptr ds:[Param],bit7 ; je druh˜ pr–chod ?
         jz        DekCisl8                 ; nen¡ je¨tˆ druh˜ pr–chod

; ------ chyba

DekCisl7:call      DispErr0                 ; zobrazen¡ hl ¨en¡
         xor       ax,ax                    ; n hradn¡ hodnota ‡¡sla
         stc                                ; p©¡znak chyby

; ------ n vrat registr–

DekCisl8:pop       di
         pop       dx
DekCisl9:ret

DekCisl  ENDP

;; -----------------------------------------------------------------------------
;;        nalezen¡ 2-registr– 1 -> AX (CY=nen¡)
;; -----------------------------------------------------------------------------
;
;Src2Reg1 PROC      NEAR
;
;         push      di
;         mov       di,offset Tab2Reg1
;         jmp       short SrcCond2
;
;Src2Reg1 ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ podm¡nky -> AX (CY=nen¡)
; -----------------------------------------------------------------------------

ReadCond PROC      NEAR

; ------ £schova registr–

         push      bx
         push      di

; ------ vypu¨tˆn¡ mezer

         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         mov       bx,si                    ; BX <- £schova adresy
         jc        ReadCnd9                 ; chyba

; ------ dek¢dov n¡ symbolu

         call      DekSymb                  ; dek¢dov n¡ symbolu
         jc        ReadCnd9                 ; nen¡ symbol

; ------ nalezen¡ podm¡nky v tabulce

         mov       di,offset TabCond        ; tabulka podm¡nek
         call      GetSymb                  ; nalezen¡ podm¡nky
         jc        ReadCnd9                 ; podm¡nka nenalezena

; ------ vypu¨tˆn¡ ‡ rky

ReadCnd8:call      ReadICar                 ; na‡ten¡ ‡ rky
         mov       bx,si                    ; ukazatel plat¡
         clc                                ; operace OK

; ------ n vrat registr–

ReadCnd9:mov       si,bx
         pop       di
         pop       bx
         ret

ReadCond ENDP

; -----------------------------------------------------------------------------
; vyhled n¡ symbolu v tabulce -> hodnota AX, adresa DI, CY=nen¡ (AX=0, DI=konec)
; -----------------------------------------------------------------------------

SrcSym   PROC      NEAR

         mov       di,offset LabBuff        ; buffer symbol–
                                           ;* n sleduje GetSymb !

SrcSym   ENDP

; -----------------------------------------------------------------------------
; nalezen¡ symbolu v tabulce DI -> AX=hodnota,DI=adresa (CY=nen¡,AX=0,DI=konec)
; -----------------------------------------------------------------------------

GetSymb  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      si

; ------ porovn n¡ d‚lky symbolu

         cld
         mov       ch,0
GetSym2: mov       cl,ds:[di]               ; d‚lka instrukce
         jcxz      GetSym8
         mov       ax,cx                    ; AX <- d‚lka instrukce
         inc       di
         mov       bx,di                    ; BX <- £schova za‡ tku instrukce
         cmp       cl,byte ptr ds:[SymTxtN] ; souhlas¡ d‚lka symbolu ?
         jne       GetSym5                  ; nesouhlas¡ d‚lka

; ------ porovn n¡ textu symbolu

         mov       si,offset SymTxt         ; text symbolu
         repe      cmpsb                    ; porovn n¡ textu symbolu
         jne       GetSym5

; ------ symbol nalezen

         mov       ax,ds:[di]               ; instrukce
         mov       di,bx
         dec       di
         jmp       short GetSym9            ; NC

; ------ adresa dal¨¡ho symbolu

GetSym5: add       bx,ax
         inc       bx
         inc       bx
         mov       di,bx
         jmp       short GetSym2            ; dal¨¡ instrukce

; ------ n vrat registr–

GetSym8: xor       ax,ax                    ; nenalezeno
         stc                                ; p©¡znak chyby
GetSym9: pop       si
         pop       cx
         pop       bx
         ret

GetSymb  ENDP

; -----------------------------------------------------------------------------
;        vyhled n¡ jm‚na instrukce -> AX (CY=nenalezen)
; -----------------------------------------------------------------------------

SrcInst  PROC      NEAR

         push      di
         mov       di,offset TabInst        ; tabulka instrukc¡
         call      GetSymb                  ; nalezen¡ instrukce
         pop       di
         ret

SrcInst  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ © dku s chybou DX
; -----------------------------------------------------------------------------
;þ
DispErr0:push      bx
         xor       bx,bx
         call      DispErr
         pop       bx
         ret

DispErr  PROC      NEAR

         test      byte ptr ds:[Param],bit7 ; je druh˜ pr–chod ?
         jz        DispErr4                 ; je prvn¡ pr–chod

         inc       word ptr ds:[CitChyb]    ; ‡¡ta‡ chyb
         push      ax
         push      dx

         mov       dx,offset ChybaTxt
         call      DispTxt
         mov       dx,ds:[InpSoub0]
         call      DispTxt
         mov       al,"("
         call      DispChr
         mov       ax,ds:[InpCitac]         ; ‡¡slo vstupn¡ho © dku
         call      DispNum                  ; zobrazen¡ ‡¡sla © dku
         mov       al,")"
         call      DispChr
         mov       al," "
         call      DispChr

         pop       dx
         pop       ax

         call      DispTxt

         push      dx
         or        bx,bx                    ; je druh  ‡ st hl ¨en¡ ?
         jz        DispErr3
         mov       dx,bx
         call      DispTxt                  ; druh  ‡ st hl ¨en¡
DispErr3:call      DispCR
         mov       dx,offset InpRadek
         call      DispTxt
         pop       dx

DispErr4:ret

DispErr  ENDP

; -----------------------------------------------------------------------------
;        definice symbolu na hodnotu AX
; -----------------------------------------------------------------------------

DefSym   PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di

; ------ vyhled n¡ symbolu v tabulce

         push      ax
         call      SrcSym                   ; vyhled n¡ symbolu
         pop       ax
         jnc       DefSym4                  ; symbol nalezen OK

; ------ kontrola nov‚ velikosti bufferu

         mov       cx,di                    ; CX <- adresa konce dat
         add       cx,ds:[SymTxtN]          ; nov˜ konec bufferu
         cmp       cx,offset LabBuff + LabBSize-1 ; je p©ete‡en¡ bufferu ?
         jbe       DefSym2                  ; nen¡ p©ete‡en¡ bufferu

; ------ chyba p©ete‡en¡ bufferu symbol–

         mov       dx,offset LabErr         ; text - p©ete‡en¡ tabulky symbol–
         jmp       Chyba

; ------ vytvo©en¡ nov‚ho symbolu

DefSym2: cld
         mov       cx,ds:[SymTxtN]          ; d‚lka symbolu
         mov       ds:[di],cl               ; d‚lka symbolu
         inc       di
         mov       si,offset SymTxt         ; text symbolu
         rep       movsb                    ; p©enesen¡ textu symbolu
         stosw                              ; ulo‘en¡ hodnoty symbolu
         mov       byte ptr ds:[di],0       ; ozna‡en¡ konce tabulky

; ------ nov  velikost bufferu

         sub       di,offset LabBuff        ; nov˜ po‡et bajt– v bufferu
         mov       ds:[LabBuffS],di         ; nov  velikost bufferu
         inc       word ptr ds:[LabBuffN]   ; nov˜ po‡et symbol– v bufferu
         jmp       short DefSym5

; ------ p©edefinov n¡ existuj¡c¡ho symbolu

DefSym4: mov       ch,0
         mov       cl,ds:[di]               ; d‚lka textu symbolu
         inc       di
         add       di,cx                    ; adresa hodnoty symbolu
         mov       ds:[di],ax               ; hodnota symbolu

; ------ n vrat registr–

DefSym5: pop       di
         pop       si
         pop       cx
         ret

DefSym   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla -> AX (CY=p©ete‡en¡ ‡¡sla nebo chybn˜ znak)
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      di
         push      bp

; ------ stanoven¡ ‡¡seln‚ soustavy

         push      si                       ; £schova ukazatele textu
         mov       al,0
         dec       si
DekNum1: inc       si                       ; p©esko‡en¡ platn‚ho znaku
         mov       ah,al                    ; AH <- £schova minul‚ho znaku
         mov       al,ds:[si]               ; dal¨¡ p©ipraven˜ znak
         cmp       al,"0"
         jb        DekNum2                  ; nen¡ platn˜ znak
         cmp       al,"9"
         jbe       DekNum1                  ; je ‡¡slice - dal¨¡ znak
         call      UpCase                   ; konverze na velk‚ p¡smeno
         cmp       al,"A"
         jb        DekNum2                  ; neplatn˜ znak
         cmp       al,"Z"
         jbe       DekNum1                  ; je asi platn˜ znak - dal¨¡ znak

DekNum2: mov       al,ah                    ; AL <- minul˜ znak
         mov       cx,si                    ; CX <- adresa konce ‡¡sla
         dec       cx                       ; bez znaku p©ep¡na‡e soustavy
         mov       bx,8
         cmp       al,"O"
         je        DekNum3                  ; oktalov  soustava
         cmp       al,"Q"
         je        DekNum3                  ; oktalov  soustava
         mov       bl,16
         cmp       al,"H"
         je        DekNum3                  ; hexadecim ln¡ soustava
         mov       bl,2
         cmp       al,"B"
         je        DekNum3                  ; bin rn¡ soustava
         mov       bl,10
         cmp       al,"D"
         je        DekNum3                  ; dekadick  soustava
         inc       cx                       ; minul˜ znak plat¡
         mov       bl,byte ptr ds:[RadixN]  ; implicitn¡ ‡¡seln  soustava
DekNum3: mov       di,si                    ; SI <- £schova adresy konce textu
         pop       si
         sub       cx,si                    ; d‚lka textu (znak–)

; ------ p©¡prava st©ada‡e

         xor       bp,bp                    ; BP <- 0 st©ada‡ ‡¡sla
         jcxz      DekNum9                  ; nen¡ ‘ dn˜ znak (?)

; ------ na‡ten¡ znaku k dek¢dov n¡

DekNum4: call      ReadICUp                 ; na‡ten¡ dal¨¡ho znaku
         mov       ah,0

; ------ ¨estn ctkov  soustava "X"

         cmp       al,"X"
         jne       DekNum5
         mov       bl,16                    ; hexadecim ln¡ soustava
         jmp       short DekNum7            ; dal¨¡ ‡¡slice

; ------ konverze na ‡¡slo

DekNum5: cmp       al,"A"
         jb        DekNum6
         sub       al,7                     ; korekce pro ASCII znak
DekNum6: sub       al,"0"

; ------ kontrola ‡¡sla

         cmp       al,bl                    ; je ‡¡slo OK ?
         cmc
         jc        DekNum9                  ; chyba zad n¡ ‡¡sla

; ------ p©id n¡ ‡¡sla ke st©ada‡i

         push      ax
         xchg      ax,bp                    ; AX <- st©ada‡ ‡¡sla
         mul       bx                       ; st©ada‡ * ‡¡seln  soustava
         pop       bp
         add       bp,ax                    ; p©i‡ten¡ ‡¡sla ke st©ada‡i
         adc       dx,dx                    ; je p©ete‡en¡ ?
         stc
         jnz       DekNum9                  ; je p©ete‡en¡ ‡¡sla

; ------ dal¨¡ znak

DekNum7: loop      DekNum4                  ; dal¨¡ znak
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

DekNum9: xchg      ax,bp                    ; AX <- na‡ten‚ ‡¡slo
         pop       bp
         pop       di
         pop       cx
         pop       bx
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        p©¡prava symbolu do bufferu (nen¡ to ‡¡slo; -> CY=nen¡ symbol)
; -----------------------------------------------------------------------------

DekSymb  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di
         mov       di,offset SymTxt         ; buffer jm‚na symbolu

; ------ test prvn¡ho znaku, zda nen¡ ‡¡slice

         mov       al,ds:[si]               ; p©ipraven˜ znak
         cmp       al,"0"
         jb        DekSymb2
         cmp       al,"9"
         jbe       DekSymb8

; ------ na‡ten¡ znaku

DekSymb2:call      ReadICUp                 ; na‡ten¡ znaku z © dku
         jc        DekSymb9                 ; nen¡ dal¨¡ znak

; ------ kontrola platnosti znaku

DekSymb3:cmp       al,"$"
         je        DekSymb6
         cmp       al,"?"
         je        DekSymb6
         cmp       al,"@"
         je        DekSymb6
         cmp       al,"_"
         je        DekSymb6
         cmp       al,"."
         je        DekSymb6
         cmp       al,"0"
         jb        DekSymb8
         cmp       al,"9"
         jbe       DekSymb6                 ; ‡¡slice je platn 
         cmp       al,"A"
         jb        DekSymb8
         cmp       al,"Z"
         ja        DekSymb8

; ------ ulo‘en¡ znaku do bufferu

DekSymb6:stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short DekSymb2           ; dal¨¡ znak

; ------ n vrat registr–

DekSymb8:dec       si                       ; n vrat znaku
DekSymb9:mov       byte ptr ds:[di],"$"     ; ozna‡en¡ konce symbolu
         sub       di,offset SymTxt
         mov       ds:[SymTxtN],di          ; d‚lka jm‚na symbolu
         cmp       byte ptr ds:[SymTxtN],1  ; je symbol ?
         pop       di
         pop       ax
         ret

DekSymb  ENDP

; *****************************************************************************
;
;                            Obsluha soubor–
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        na‡ten¡ lev‚ z vorky (CY=nen¡)
; -----------------------------------------------------------------------------

ReadILft PROC      NEAR

         push      ax
         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         cmp       al,"("                   ; je lev  z vorka ?
         jmp       short ReadICr1

ReadILft ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ prav‚ z vorky (CY=nen¡)
; -----------------------------------------------------------------------------

ReadIRgh PROC      NEAR

         push      ax
         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         cmp       al,")"                   ; je prav  z vorka ?
         jmp       short ReadICr1

ReadIRgh ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ ‡ rky (CY=nen¡)
; -----------------------------------------------------------------------------

ReadICar PROC      NEAR

         push      ax
         call      ReadISpc                 ; vypu¨tˆn¡ mezer
         cmp       al,","                   ; n sleduje ‡ rka ?
ReadICr1:pop       ax
         stc                                ; p©¡znak - nen¡ ‡ rka
         jne       ReadICr2                 ; nen sleduje ‡ rka
         clc                                ; p©¡znak, ‘e je ‡ rka
         inc       si                       ; p©esko‡en¡ oddˆlovac¡ ‡ rky
ReadICr2:ret

ReadICar ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer ze vstupn¡ho © dku DS:SI
; -----------------------------------------------------------------------------

ReadISpc PROC      NEAR

ReadISp1:call      ReadIChr                 ; na‡ten¡ znaku
         jc        ReadISp3                 ; je konec © dku
         je        ReadISp1                 ; je mezera - vypu¨tˆn¡
         dec       si                       ; n vrat platn‚ho znaku
         cmp       al,";"                   ; je pozn mka ?
         stc
         je        ReadISp3                 ; je pozn mka - konec © dku
         clc                                ; p©¡znak platn‚ho znaku
ReadISp3:ret

ReadISpc ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku ze vstupn¡ho © dku s konverz¡ na velk‚ p¡smeno
; -----------------------------------------------------------------------------

ReadICUp PROC      NEAR

         call      ReadIChr                 ; na‡ten¡ znaku
         jbe       ReadICU4                 ; konec nebo mezera
         cmp       al,"a"
         jb        ReadICU3
         cmp       al,"z"
         ja        ReadICU3
         sub       al,32                    ; konverze na velk‚ p¡smeno
ReadICU3:or        al,al
ReadICU4:ret

ReadICUp ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku ze vstupn¡ho © dku DS:SI (CY=konec © dku, ZY=mezera)
; -----------------------------------------------------------------------------

ReadIChr PROC      NEAR

; ------ na‡ten¡ znaku z bufferu

         cld
         lodsb                              ; na‡ten¡ znaku z bufferu

; ------ test, zda je platn˜ znak

         cmp       al," "                   ; je mezera ?
         jae       ReadICh2                 ; je platn˜ znak nebo mezera
         dec       si                       ; n vrat konce © dku
ReadICh2:ret

ReadIChr ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ dal¨¡ho © dku ze vstupn¡ho souboru (-> CY konec souboru)
; -----------------------------------------------------------------------------

ReadIRad PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      di

; ------ p©¡prava registr–

         mov       di,offset InpRadek       ; buffer vstupn¡ho © dku
ReadIRd1:mov       si,ds:[InpBuffR]         ; ‡tec¡ adresa z bufferu
         mov       dx,ds:[InpBuffE]         ; adresa konce dat v bufferu
         cld

; ------ test, zda jsou p©ipravena dal¨¡ data

ReadIRd2:cmp       si,dx                    ; jsou p©ipravena dal¨¡ data ?
         jb        ReadIRd3                 ; jsou p©ipravena dal¨¡ data
         call      ReadIBuf                 ; na‡ten¡ vstupn¡ho bufferu
         jnc       ReadIRd1                 ; operace OK
         cld
         cmp       di,offset InpRadek+1     ; bylo nˆco na‡teno ?
         jb        ReadIRd9                 ; nebylo nic na‡teno
         jmp       short ReadIRd6           ; tento © dek je¨tˆ plat¡

; ------ na‡ten¡ jednoho znaku z bufferu

ReadIRd3:lodsb                              ; na‡ten¡ znaku z bufferu

; ------ n hrada tabul toru mezerou

         cmp       al,TAB
         jne       ReadIRd4
         mov       al," "                   ; n hrada tabul toru mezerou

; ------ test, zda je konec © dku LF

ReadIRd4:cmp       al,LF                    ; je konec © dku LF ?
         je        ReadIRd6                 ; je konec © dku LF

; ------ jin‚ znaky < 32 se ignoruj¡

         cmp       al," "                   ; je platn˜ znak ?
         jb        ReadIRd2                 ; neplatn‚ znaky se ignoruj¡

; ------ test, zda lze znak ulo‘it

         cmp       di,offset InpRadek+254   ; je je¨tˆ m¡sto ?
         jae       ReadIRd2                 ; nen¡ m¡sto k ulo‘en¡ dat
         stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short ReadIRd2           ; dal¨¡ znak

; ------ ulo‘en¡ ukon‡en¡ © dku CR/LF

ReadIRd6:mov       ax,CR + LF*HI
         stosw                              ; ulo‘en¡ ukon‡en¡ © dku CR/LF
         mov       byte ptr ds:[di],"$"

; ------ d‚lka dat © dku

         inc       word ptr ds:[InpCitac]   ; ‡¡ta‡ vstupn¡ch © dk–
         sub       di,offset InpRadek
         mov       ds:[InpRadN],di          ; d‚lka © dku
                                            ; zde je NC !
; ------ n vrat registr–

ReadIRd9:mov       ds:[InpBuffR],si         ; nov  ‡tec¡ adresa z bufferu
         pop       di
         pop       dx
         pop       ax
         mov       si,offset InpRadek       ; buffer vstupn¡ho © dku
         ret

ReadIRad ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu vstupn¡ho bufferu (-> CY konec souboru)
; -----------------------------------------------------------------------------

ReadIBuf PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ na‡ten¡ obsahu bufferu

         mov       dx,offset InpBuff        ; vstupn¡ buffer
         mov       cx,InpBSize              ; velikost vstupn¡ho bufferu
         mov       ah,3fh
         mov       bx,ds:[InpIdnt]          ; identifik tor vstupn¡ho souboru
         int       21h                      ; na‡ten¡ vstupn¡ho bufferu
         jc        ReadIBf8                 ; chyba

; ------ nov˜ ukazatel dat

         mov       ds:[InpBuffR],dx         ; ‡tec¡ adresa z bufferu
         add       dx,ax                    ; adresa konce dat
         mov       ds:[InpBuffE],dx         ; adresa konce dat
         or        ax,ax                    ; bylo nˆco na‡teno ?
         jnz       ReadIBf3                 ; bylo nˆco na‡teno
         stc                                ; p©¡znak konce dat

; ------ n vrat registr–

ReadIBf3:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; ------ chyba ‡ten¡ ze souboru

ReadIBf8:mov       dx,offset ReadErr        ; text - chyba ‡ten¡
ReadIBf9:jmp       Chyba

ReadIBuf ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------

WritOBuf PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ z pis obsahu bufferu

         test      byte ptr ds:[Param],bit7 ; je druh˜ pr–chod ?
         jz        WritOBf4                 ; je prvn¡ pr–chod

         mov       dx,offset OutBuff        ; v˜stupn¡ buffer
         mov       cx,ds:[OutBuffN]         ; po‡et bajt– v bufferu
         mov       bx,ds:[OutIdnt]          ; identifik tor souboru
         mov       ah,40h
         int       21h                      ; z pis dat do souboru

; ------ posun ukazatel– dat

         mov       dx,offset WritErr        ; text - chyba z pisu
         jc        ReadIBf9                 ; chyba z pisu
         cmp       ax,cx                    ; bylo zaps no v¨e ?
         jne       ReadIBf9                 ; chyba z pisu
WritOBf4:mov       word ptr ds:[OutBuffN],0 ; v bufferu nejsou ‘ dn  data

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritOBuf ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu v˜stupn¡ho © dku -> DI nov  adresa
; -----------------------------------------------------------------------------

WritORad PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di

; ------ p©¡prava registr–

         mov       si,offset OutRadek       ; buffer v˜stupn¡ho © dku
         mov       cx,ds:[OutRadN]          ; po‡et bajt– ve v˜stupn¡m © dku
         jcxz      WritORd9                 ; nejsou ‘ dn  data v © dku
WritORd2:mov       di,ds:[OutBuffN]         ; po‡et bajt– ve v˜stupn¡m bufferu
         add       di,offset OutBuff        ; ukl dac¡ adresa do bufferu
         cld

; ------ test, zda je v bufferu voln‚ m¡sto

WritORd4:cmp       di,offset OutBuff+OutBSize ; je voln‚ m¡sto ?
         jb        WritORd5                 ; je je¨tˆ voln‚ m¡sto
         call      WritOBuf                 ; z pis bufferu do souboru
         jmp       short WritORd2

; ------ p©enos jednoho bajtu

WritORd5:movsb                              ; p©enos jednoho bajtu do bufferu
         inc       word ptr ds:[OutBuffN]   ; zv˜¨en¡ po‡tu bajt– v bufferu
         loop      WritORd4                 ; dal¨¡ bajt
         mov       ds:[OutRadN],cx          ; nov˜ po‡et bajt– v bufferu

; ------ n vrat registr–

WritORd9:or        byte ptr ds:[Param],bit6 ; byl 1. © dek
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

WritORad ENDP

; -----------------------------------------------------------------------------
;        z pis znaku AL do v˜stupn¡ho © dkov‚ho bufferu
; -----------------------------------------------------------------------------

WritOChr PROC      NEAR

; ------ £schova registr–

         push      di

; ------ test, zda je buffer ji‘ pln˜

         mov       di,ds:[OutRadN]          ; po‡et bajt– v bufferu
         cmp       di,MaxOutB               ; je buffer ji‘ pln˜ ?
         jb        WritOCh2                 ; buffer je¨tˆ nen¡ pln˜

; ------ vypr zdnˆn¡ v˜stupn¡ho bufferu

         call      WritORad                 ; z pis obsahu © dku
         xor       di,di                    ; nov˜ po‡et bajt– v bufferu

; ------ ulo‘en¡ znaku do bufferu

WritOCh2:mov       ds:[di+OutRadek],al      ; ulo‘en¡ znaku do bufferu
         inc       di
         mov       ds:[OutRadN],di          ; nov˜ po‡et bajt– v bufferu
         inc       word ptr ds:[Pointer]    ; zv˜¨en¡ ukazatele adresy

; ------ n vrat registr–

         pop       di
         ret

WritOChr ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ v˜stupn¡ho © dkov‚ho bufferu
; -----------------------------------------------------------------------------

NulORad  PROC      NEAR

         call      WritORad                 ; z pis obsahu v˜stupn¡ho © dku
         and       byte ptr ds:[Param],not bit6 ; nebyl 1. © dek
         push      ax
         mov       ax,ds:[Pointer]          ; ukazatel programu
         mov       ds:[OutAdr],ax           ; po‡ te‡n¡ adresa © dku
         pop       ax
         ret

NulORad  ENDP

; *****************************************************************************
;
;                       Rozbor p©¡kazov‚ho © dku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,es:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       es:[si+bx],bh            ; ozna‡en¡ konce p©¡kaz. © dku
         push      ds
         pop       es                       ; ES <- datov˜ segment
         cld

; ------ nalezen¡ prvn¡ho znaku

Rozbor1: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jnc       Rozbor3                  ; je nˆjak˜ znak

; ------ konec p©¡kazov‚ho © dku

         test      byte ptr ds:[Param],bit0 ; zad n vstupn¡ soubor ?
         jnz       Rozbor2                  ; v˜stupn¡ soubor zad n OK
         stc                                ; chyba - nezad n soubor
Rozbor2: ret

; ------ test, zda je parametr

Rozbor3: cmp       al,","
         je        Rozbor1                  ; oddˆlovac¡ ‡ rky se vypust¡
         cmp       al,"/"                   ; je to parametr ?
         je        Rozbor4                  ; je to parametr

; ------ test, zda byl zad n vstupn¡ soubor

         test      byte ptr ds:[Param],bit0 ; byl ji‘ zad n vstupn¡ soubor ?
         jnz       Rozbor32                 ; vstupn¡ soubor ji‘ byl zad n

; ------ zad n¡ vstupn¡ho souboru

         mov       di,offset InpSoub        ; vstupn¡ soubor
         call      RozbFil                  ; zad n¡ vstupn¡ho souboru
         jc        Rozbor2                  ; nˆjak  chyba
         or        byte ptr ds:[Param],bit0 ; zad n vstupn¡ soubor
         mov       ax,"M."                  ; implicitn¡ p©¡pona "MAC"
         mov       dx,"CA"
         call      ImplExt                  ; vytvo©en¡ implicitn¡ p©¡pony

; ------ sestaven¡ jm‚na v˜stupn¡ho souboru

         mov       bx,offset InpSoub        ; vstupn¡ soubor
         mov       di,offset OutSoub        ; v˜stupn¡ soubor
         mov       ax,"C."                  ; implicitn¡ p©¡pona "COM"
         mov       dx,"MO"
         call      CopyExt                  ; sestaven¡ jm‚na v˜stupn¡ho souboru
         jmp       short Rozbor34           ; sestaven¡ jm‚na souboru v˜pisu

; ------ test, zda byl zad n v˜stupn¡ soubor

Rozbor32:test      byte ptr ds:[Param],bit1 ; byl zad n v˜stupn¡ soubor ?
         jnz       Rozbor36                 ; v˜stupn¡ soubor byl zad n

; ------ zad n¡ v˜stupn¡ho souboru

         mov       di,offset OutSoub        ; v˜stupn¡ soubor
         call      RozbFil                  ; zad n¡ vstupn¡ho souboru
         jc        Rozbor2                  ; nˆjak  chyba
         or        byte ptr ds:[Param],bit1 ; zad n v˜stupn¡ soubor
         mov       ax,"C."                  ; implicitn¡ p©¡pona "COM"
         mov       dx,"MO"
         call      ImplExt                  ; vytvo©en¡ implicitn¡ p©¡pony

; ------ sestaven¡ jm‚na souboru v˜pisu

Rozbor34:mov       bx,offset OutSoub        ; v˜stupn¡ soubor
         mov       di,offset LstSoub        ; soubor v˜pisu
         mov       ax,"L."                  ; implicitn¡ p©¡pona "LST"
         mov       dx,"TS"
         call      CopyExt                  ; sestaven¡ jm‚na v˜stupn¡ho souboru
Rozbor35:jmp       short Rozbor1            ; sestaven¡ jm‚na souboru v˜pisu

; ------ zad n¡ souboru v˜pisu

Rozbor36:mov       di,offset LstSoub        ; soubor v˜pisu
         call      RozbFil                  ; zad n¡ vstupn¡ho souboru
         jc        Rozbor2                  ; nˆjak  chyba
         mov       ax,"L."                  ; implicitn¡ p©¡pona "LST"
         mov       dx,"TS"
         call      ImplExt                  ; vytvo©en¡ implicitn¡ p©¡pony
Rozbor38:or        byte ptr ds:[Param],bit2 ; p©¡znak, ‘e se prov d¡ v˜pis
         jmp       short Rozbor35

; ------ vypu¨tˆn¡ znaku "/"

Rozbor4: call      RozbChr                  ; vypu¨tˆn¡ znaku "/"

; ------ na‡ten¡ znaku parametru

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ znaku
         jc        Rozbor9                  ; nen¡ dal¨¡ znak

; ------ parametr "/L"

         cmp       al,"L"
         je        Rozbor38                 ; prov d¡ se v˜pis

; ------ parametr "/86"

         cmp       al,"8"
         jne       Rozbor5
         call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jc        Rozbor9
         cmp       al,"6"
         jne       Rozbor9
         or        byte ptr ds:[Param],bit3 ; v˜stupn¡ k¢d 8086
         jmp       short Rozbor35

; ------ parametr "/Dsym[=n]"

Rozbor5: cmp       al,"D"
         jne       Rozbor6


         jmp       short Rozbor35

Rozbor6:



Rozbor9: stc
         ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ jm‚na souboru SI do bufferu ES:DI (-> ES:DI koncov  0)
; -----------------------------------------------------------------------------

RozbFil  PROC      NEAR

; ------ vypu¨tˆn¡ mezer p©ed jm‚nem soubor

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        RozbFil9                 ; konec p©¡kazov‚ho © dku

; ------ kontrola prvn¡ho znaku jm‚na souboru

         cmp       al,"/"
         je        RozbFil8
         cmp       al,"?"
         je        RozbFil8
         cmp       al,"*"
         je        RozbFil8

; ------ na‡ten¡ znaku jm‚na souboru

RozbFil2:call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jb        RozbFil7                 ; konec textu

; ------ test, zda je platn˜ znak

         je        RozbFil6                 ; oddˆlovac¡ mezera
         cmp       al,"/"
         je        RozbFil6                 ; znak parametru

; ------ ulo‘en¡ znaku do bufferu

         stosb
         jmp       short RozbFil2           ; dal¨¡ znak

; ------ ozna‡en¡ konce textu

RozbFil6:dec       si                       ; n vrat n sleduj¡c¡ho znaku
RozbFil7:mov       al,0                     ; ukon‡ovac¡ 0
         stosb                              ; ulo‘en¡ ukon‡ovac¡ho znaku 0
         dec       di                       ; n vrat na koncovou 0
         clc                                ; p©¡znak operace OK
         ret

RozbFil8:stc
RozbFil9:ret

RozbFil  ENDP

; -----------------------------------------------------------------------------
;        implicitn¡ p©¡pona DX:AX souboru DS:DI
; -----------------------------------------------------------------------------

ImplExt  PROC      NEAR

; ------ test, zda je zad na p©¡pona

         mov       bx,di                    ; BX <- adresa konce jm‚na souboru
ImplExt1:dec       bx                       ; sn¡‘en¡ ukazatele textu
         cmp       byte ptr ds:[bx],"."     ; je oddˆlovac¡ te‡ka p©¡pony ?
         je        ImplExt9                 ; byla zad na p©¡pona
         cmp       byte ptr ds:[bx],0       ; je ji‘ za‡ tek jm‚na souboru ?
         je        ImplExt6                 ; je ji‘ za‡ tek jm‚na souboru
         cmp       byte ptr ds:[bx],":"
         je        ImplExt6
         cmp       byte ptr ds:[bx],"\"     ; je oddˆlova‡ cesty ?
         jne       ImplExt1                 ; vyhled n¡ oddˆlovac¡ te‡ky

; ------ p©¡pona nenalezena

ImplExt6:stosw                              ; te‡ka a 1. znak p©¡pony
         xchg      ax,dx
         stosw                              ; 2. a 3. znak p©¡pony
         mov       al,0
         stosb                              ; ukon‡ovac¡ 0
ImplExt9:ret

ImplExt  ENDP

; -----------------------------------------------------------------------------
;        kopie jm‚na souboru DS:BX do bufferu ES:DI s p©¡ponou DX:AX
; -----------------------------------------------------------------------------

CopyExt  PROC      NEAR

; ------ kopie jm‚na souboru

         push      ax
CopyExt1:mov       al,ds:[bx]
         inc       bx
         stosb
         cmp       al,0
         jne       CopyExt1
         pop       ax

; ------ nalezen¡ p©¡pony

CopyExt2:dec       di
         cmp       ds:[di],al
         jne       CopyExt2

; ------ ulo‘en¡ implicitn¡ p©¡pony

         stosw
         xchg      ax,dx
         stosw
         mov       al,0
         stosb
         ret

CopyExt  ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku SI
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

RozbSpc1:call      RozbChr                  ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         jc        RozbSpc4                 ; konec p©¡kazov‚ho © dku
         je        RozbSpc1                 ; mezera
         dec       si                       ; n vrat platn‚ho znaku
RozbSpc4:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku SI
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

         push      ds
         mov       ds,ds:[SegPSP]           ; segment PSP

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku

         lodsb                              ; na‡ten¡ znaku

; ------ n hrada tabul toru mezerou

         cmp       al,TAB
         jne       RozbChr2                 ; nen¡ tabul tor
         mov       al," "                   ; n hrada mezerou

; ------ konverze na velk‚ p¡smeno

RozbChr2:call      UpCase                   ; konverze na velk‚ p¡smeno

; ------ test, zda je platn˜ znak

         cmp       al," "                   ; je to platn˜ znak ?
         jae       RozbChr4                 ; je to platn˜ znak nebo mezera
         dec       si                       ; n vrat znaku konce © dku
RozbChr4:pop       ds
         ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        konverze znaku AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

Code     ENDS

; *****************************************************************************
;
;                                   Data
;
; *****************************************************************************
;þ
Data     SEGMENT

SegPSP   dw        0                        ; adresa segmentu PSP

Param    db        0                        ; parametry
                                            ;   bit 0: 1=zad n vstupn¡ soubor
                                            ;   bit 1: 1=zad n v˜stupn¡ soubor
                                            ;   bit 2: 1=prov d¡ se v˜pis LST
                                            ;   bit 3: 1=v˜stupn¡ k¢d 8086
                                            ;   bit 6: 1=1.v˜stupn¡ © dek zaps n
                                            ;   bit 7: 1=je druh˜ pr–chod

UvTxt    db        13,10,'MAC80 V1.0 - prekladac kodu Z80; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte:   vstup [vystup [vypis]] [/L] [/Dsym[=n]] [/86]',13,10
         db        '        vstup ........ jmeno vstupniho souboru (pripona implicitne MAC)',13,10
         db        '        vystup ....... jmeno vystupniho souboru (pripona implicitne COM)',13,10
         db        '        vypis ........ jmeno souboru vypisu (pripona implicitne LST)',13,10
         db        '        /L ........... provadi se vypis prekladu (do souboru LST)',13,10
         db        '        /Dsym[=n] .... definice symbolu sym (popr. nastaveni na cislo n)',13,10
         db        '        /86 .......... vystupni kod v kodu procesoru 8086 (IBM PC)',13,10
         db        '$'

InpErr   db        'Chyba - vstupni soubor nenalezen !',13,10,'$'
ReadErr  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'
WritErr  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
ListErr  db        'Chyba zapisu do souboru vypisu !',13,10,'$'
LabErr   db        'Chyba preteceni tabulky symbolu !',13,10,'$'

ChybaTxt db        '**CHYBA** $'

PovelErr db        'neznamy povel$'
RezerErr db        'rezervovane slovo pouzito jako navesti: $'
RelErr   db        'preteceni relativniho skoku o '
RelErr0  db        '      B$'
PretErr  db        'preteceni hodnoty vyrazu$'
NeDefErr db        'nedefinovany symbol ve vyrazu$'
NeVyrErr db        'nezadan vyraz$'
NeConErr db        'nepovolena podminka$'
NeOprErr db        'zadano malo operandu instrukce$'
NeKomErr db        'nepovolena kombinace operandu$'

PreklTxt db        13,10,'   Prekladany soubor     : $'
ChybTxt  db        '   Pocet zavaznych chyb  : $'
VolnaTxt db        '   Zbyvajici volna pamet : $'
ZadnaTxt db        'zadna$'
CrTxt    db        13,10,'$'

; ------ tabulka n zv– instrukc¡ (podtabulky mus¡ m¡t vˆt¨¡ offset ne‘ 255 !)

TabInst  label     byte
         db        3,'ADC'
         dw        1;AADC

         db        3,'ADD'
         dw        9

         db        3,'AND'
         dw        0a0h

         db        3,'BIT'
         dw        0cbh

         db        4,'CALL'
         dw        ACALL

         db        3,'CCF'
         dw        3fh

         db        3,'CPD'
         dw        0edh

         db        4,'CPDR'
         dw        0edh

         db        3,'CPI'
         dw        0edh

         db        4,'CPIR'
         dw        0edh

         db        2,'CP'
         dw        0b8h

         db        3,'CPL'
         dw        2fh

         db        3,'DAA'
         dw        27h

         db        3,'DEC'
         dw        5

         db        2,'DI'
         dw        0f3h

         db        4,'DJNZ'
         dw        ADJNZ

         db        2,'EI'
         dw        0fbh

         db        2,'EX'
         dw        8

         db        3,'EXX'
         dw        0d9h

         db        4,'HALT'
         dw        76h

         db        2,'IM'
         dw        0edh

         db        3,'INC'
         dw        3

         db        3,'IND'
         dw        0edh

         db        4,'INDR'
         dw        0edh

         db        2,'IN'
         dw        0dbh

         db        3,'INI'
         dw        0edh

         db        4,'INIR'
         dw        0edh

         db        2,'JP'
         dw        AJP

         db        2,'JR'
         dw        AJR

         db        4,'LDDR'
         dw        0edh

         db        3,'LDD'
         dw        0edh

         db        2,'LD'
         dw        ALD

         db        3,'LDI'
         dw        0edh

         db        4,'LDIR'
         dw        0edh

         db        3,'NEG'
         dw        0edh

         db        3,'NOP'
         dw        0

         db        2,'OR'
         dw        0b0h

         db        4,'OTDR'
         dw        0edh

         db        4,'OTIR'
         dw        0edh

         db        3,'OUT'
         dw        0d3h

         db        4,'OUTD'
         dw        0edh

         db        4,'OUTI'
         dw        0edh

         db        3,'POP'
         dw        0c1h

         db        4,'PUSH'
         dw        0c5h

         db        3,'RES'
         dw        0cbh

         db        3,'RET'
         dw        0c9h

         db        4,'RETI'
         dw        0edh

         db        4,'RETN'
         dw        0edh

         db        3,'RLA'
         dw        17h

         db        3,'RLC'
         dw        0cbh

         db        4,'RLCA'
         dw        7

         db        2,'RL'
         dw        0cbh

         db        3,'RLD'
         dw        0edh

         db        3,'RRA'
         dw        1fh

         db        3,'RRC'
         dw        0cbh

         db        4,'RRCA'
         dw        0fh

         db        2,'RR'
         dw        0cbh

         db        3,'RRD'
         dw        0edh

         db        3,'RST'
         dw        0c7h

         db        3,'SBC'
         dw        98h

         db        3,'SCF'
         dw        37h

         db        3,'SET'
         dw        0cbh

         db        3,'SLA'
         dw        0cbh

         db        3,'SLI'
         dw        0cbh

         db        3,'SRA'
         dw        0cbh

         db        3,'SRL'
         dw        0cbh

         db        3,'SUB'
         dw        90h

         db        3,'XOR'
         dw        0a8h

; ------ direktivy

         db        6,'$EJECT'
         dw        0

         db        8,'$INCLUDE'
         dw        0

         db        6,'$TITLE'
         dw        0

         db        5,'.8080'
         dw        0

         db        8,'.COMMENT'
         dw        0

         db        5,'.CREF'
         dw        0

         db        8,'.DEPHASE'
         dw        0

         db        5,'.LALL'
         dw        0

         db        5,'.LIST'
         dw        0

         db        6,'.PHASE'
         dw        0

         db        7,'.PRINTX'
         dw        0

         db        6,'.RADIX'
         dw        0

         db        8,'.REQUEST'
         dw        0

         db        5,'.SALL'
         dw        0

         db        5,'.XALL'
         dw        0

         db        6,'.XCREF'
         dw        0

         db        6,'.XLIST'
         dw        0

         db        4,'.Z80'
         dw        0

         db        4,'ASEG'
         dw        0

         db        6,'COMMON'
         dw        0

         db        4,'COND'
         dw        0

         db        4,'CSEG'
         dw        0

         db        2,'DB'
         dw        0

         db        2,'DC'
         dw        0

         db        4,'DEFB'
         dw        0

         db        4,'DEFL'
         dw        0

         db        4,'DEFM'
         dw        0

         db        4,'DEFS'
         dw        0

         db        4,'DEFW'
         dw        0

         db        2,'DS'
         dw        0

         db        4,'DSEG'
         dw        0

         db        2,'DW'
         dw        0

         db        4,'ELSE'
         dw        0

         db        3,'END'
         dw        0

         db        4,'ENDC'
         dw        0

         db        5,'ENDIF'
         dw        0

         db        4,'ENDM'
         dw        0

         db        5,'ENTRY'
         dw        0

         db        3,'EQU'
         dw        0

         db        5,'EXITM'
         dw        0

         db        3,'EXT'
         dw        0

         db        8,'EXTERNAL'
         dw        0

         db        5,'EXTRN'
         dw        0

         db        6,'GLOBAL'
         dw        0

         db        2,'IF'
         dw        0

         db        3,'IF1'
         dw        0

         db        3,'IF2'
         dw        0

         db        3,'IFB'
         dw        0

         db        5,'IFDEF'
         dw        0

         db        3,'IFE'
         dw        0

         db        3,'IFF'
         dw        0

         db        4,'IFNB'
         dw        0

         db        6,'IFNDEF'
         dw        0

         db        3,'IFT'
         dw        0

         db        7,'INCLUDE'
         dw        0

         db        3,'IRP'
         dw        0

         db        4,'IRPC'
         dw        0

         db        4,'LALL'
         dw        0

         db        5,'LOCAL'
         dw        0

         db        6,'MACLIB'
         dw        0

         db        5,'MACRO'
         dw        0

         db        4,'NAME'
         dw        0

         db        3,'ORG'
         dw        0

         db        4,'PAGE'
         dw        0

         db        6,'PUBLIC'
         dw        0

         db        4,'REPT'
         dw        0

         db        3,'SET'
         dw        0

         db        6,'SUBTTL'
         dw        0

         db        5,'TITLE'
         dw        0

         db        0

; ------ tabulka podm¡nek

TabCond  label     byte
         db        2,'NZ'
         dw        0

         db        1,'Z'
         dw        8

         db        2,'NC'
         dw        10h

         db        1,'C'
         dw        18h

         db        2,'PO'
         dw        20h

         db        2,'PE'
         dw        28h

         db        1,'P'
         dw        30h

         db        1,'M'
         dw        38h

         db        0

; ------ tabulka registr–

TabReg   label     byte
         db        1,'B'
         dw        0

         db        1,'C'
         dw        1

         db        1,'D'
         dw        2

         db        1,'E'
         dw        3

         db        1,'H'
         dw        4

         db        2,'XH'
         dw        4+0ddh*HI

         db        3,'IXH'
         dw        4+0ddh*HI

         db        2,'YH'
         dw        4+0fdh*HI

         db        3,'IYH'
         dw        4+0fdh*HI

         db        1,'L'
         dw        5

         db        2,'XL'
         dw        5+0ddh*HI

         db        3,'IXL'
         dw        5+0ddh*HI

         db        2,'YL'
         dw        5+0fdh*HI

         db        3,'IYL'
         dw        5+0fdh*HI

         db        1,'A'
         dw        7

         db        2,'BC'
         dw        10h

         db        2,'DE'
         dw        20h

         db        2,'HL'
         dw        30h

         db        2,'IX'
         dw        30h+0ddh*HI

         db        2,'IY'
         dw        30h+0fdh*HI

         db        2,'SP'
         dw        40h

         db        2,'AF'
         dw        50h

         db        0

; ------ ukazatele p©ekladu

RadixN   dw        10                       ; ‡¡seln  soustava
Pointer  dw        100h                     ; ukazatel adresy p©ekladu

SymTxtN  dw        0                        ; d‚lka textu symbolu
SymTxt   db        256 dup(0)               ; buffer jm‚na symbolu

; ------ buffer vstupn¡ho © dku

InpRadN  dw        0                        ; d‚lka vstupn¡ho © dku s CR/LF
InpRadek db        256+1 dup(0)             ; buffer vstupn¡ho © dku (s CR/LF+'$')
InpCitac dw        0                        ; ‡¡ta‡ vstupn¡ch © dk–
CitChyb  dw        0                        ; ‡¡ta‡ chyb

; ------ buffer v˜stupn¡ho © dku

OutAdr   dw        100h                     ; po‡ te‡n¡ adresa dat v˜stup. © dku
OutRadN  dw        0                        ; po‡et bajt– v˜stupn¡ho © dku
OutRadek db        MaxOutB dup(0)           ; buffer v˜stupn¡ho © dku

; ------ definice soubor– (p©ed za‡ tkem jmen soubor– mus¡ b˜t p©i startu 0)

InpIdnt  dw        0                        ; identifik tor vstupn¡ho souboru
OutIdnt  dw        0                        ; identifik tor v˜stupn¡ho souboru
LstIdnt  dw        0                        ; identifik tor souboru v˜pisu
InpSoub0 dw        InpSoub                  ; adresa jm‚na vstupn¡ho souboru
InpSoub  db        128 dup(0)               ; vstupn¡ soubor (0=nezad n)
OutSoub  db        128 dup(0)               ; v˜stupn¡ soubor (0=nezad n)
LstSoub  db        128 dup(0)               ; soubor v˜pisu

; ------ vstupn¡ a v˜stupn¡ buffery

InpBuffE dw        InpBuff                  ; adresa konce vstupn¡ho bufferu
InpBuffR dw        InpBuff                  ; ‡tec¡ adresa z bufferu
InpBuff  db        InpBSize dup(0)          ; vstupn¡ buffer

OutBuffN dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu
OutBuff  db        OutBSize dup(0)          ; v˜stupn¡ buffer

; ------ buffer n vˆ¨t¡
; Struktura bufferu:
;     0: (1) d‚lka jm‚na n vˆ¨t¡ (0=konec tabulky)
;     1: (x) text jm‚na n vˆ¨t¡
;   1+x: (2) hodnota n vˆ¨t¡

LabBuffN dw        0                        ; po‡et n vˆ¨t¡ v bufferu
LabBuffS dw        0                        ; velikost bufferu n vˆ¨t¡ (bajt–)
LabBuff  db        0,LabBSize-1 dup(?)      ; buffer n vˆ¨t¡

Data     ENDS

; *****************************************************************************
;
;                                Z sobn¡k
;
; *****************************************************************************

Zasob    SEGMENT   Stack 'STACK'
         db        4000h dup(?)
Zasob    ENDS

         END       Start

COMMENT %

========================================================================

                               G E N M A C

 program pro generov†n° zdrojovÇho textu pro M80 ze souboru typu .COM

========================================================================
%

code     SEGMENT   page
         ASSUME    cs:code,ds:code,ss:code

pocpoz   equ       80                       ; poáet pozic na ©†dek

         org       100h

start:                                      ; hlavn° tàlo programu

                                            ; vytvo©en° FCB souborñ
         mov       sp,offset stack
         mov       dx,offset txtuv          ; £vodn° text
         mov       ah,9
         int       21h                      ; tisk £vodn°ho textu
         mov       si,5ch                   ; offset FCB1
         mov       al,[si+1]                ; prvn° znak jmÇna souboru
         cmp       al,32                    ; je mezera ?
         jz        gen1                     ; chyba - nen° zad†n soubor
         mov       al,[si+9]                ; prvn° znak typu souboru
         cmp       al," "                   ; je mezera ?
         jz        gen2                     ; je mezera - OK
         mov       ax,[si+9]                ; prvn° dva znaky typu souboru
         cmp       ax,"OC"                  ; jsou znaky "CO" ?
         jz        gen2                     ; jsou znaky "CO" - OK
gen1:    mov       dx,offset txter1         ; text Chyba zad†n°
         mov       ah,9
         int       21h                      ; vòpis chybovÇho textu
errend:  mov       ax,4c01h                 ; chybovò n†vrat
         int       21h
gen2:    mov       di,offset fcbcom         ; FCB zdrojovÇho souboru
         mov       cx,8                     ; poáet bajtñ FCB
         rep       movsb                    ; p©enos jmÇna zdrojovÇho souboru
         mov       si,5ch
         mov       di,offset fcbpar         ; FCB souboru parametrñ
         mov       cx,8
         rep       movsb                    ; p©enos jmÇna souboru parametrñ
         mov       si,5ch
         mov       di,offset fcbmac         ; FCB vòstupn°ho souboru
         mov       cx,8
         rep       movsb                    ; p©enos jmÇna vòstupn°ho souboru

                                            ; obsluha naáten° souboru COM
         mov       bx,offset adrend         ; konec programu
         mov       [adrcom],bx              ; adresa zaá†tku programu COM
         mov       [adrDTA],bx              ; ukl†dac° adresa DTA
         mov       bx,offset fcbcom         ; FCB souboru COM
         mov       [adrfcb],bx              ; adresa FCB souboru COM
         call      loaddt                   ; naáten° programu COM
         jnc       gen3                     ; naáten° bez chyby
         mov       dx,offset txter2         ; chybovÇ hl†®en° "Chyba zdrojovÇho souboru [.COM] !"
         mov       ah,9
         int       21h                      ; vòpis chybovÇho hl†®en°
         jmp       errend                   ; chybovò konec

gen3:                                       ; vytvo©en° vektoru programu
         mov       bx,[adrDTA]              ; konec za souborem COM
         mov       [adrvek],bx              ; zaá†tek vektoru programu
         push      bx                       ; zaá†tek vetkoru programu
         mov       dx,[adrcom]
         sub       bx,dx                    ; dÇlka souboru COM
         shr       bx,1
         shr       bx,1
         shr       bx,1
         inc       bx
         inc       bx
         inc       bx
         inc       bx                       ; dÇlka/8 + 4
         pop       dx                       ; zaá†tek vektoru programu
         push      bx                       ; dÇlka tabulky vektorñ
         add       bx,dx                    ; koneán† adresa vektoru
         mov       [adrpar],bx              ; zaá†tek tabulky parametrñ
         add       bx,80h
         call      tstend                   ; test konce pamàti
         jnc       gen4                     ; test OK
         jmp       errend                   ; p©i chybà pamàti konec
gen4:    mov       si,[adrvek]              ; zaá†tek vektoru programu
         mov       di,si
         inc       di
         mov       byte ptr [si],0
         pop       cx                       ; dÇlka vektoru programu
         add       cx,80h                   ; vymaz†n° i zaá†tku tabulky parametrñ
         rep       movsb                    ; vymaz†n° vektoru programu

                                            ; naáten° souboru parametrñ programu
         mov       bx,[adrvek]              ; adresa zaá†tku vektoru programu
         mov       [adrdta],bx              ; adresa pro naáten° souboru PAR
         mov       bx,offset fcbpar         ; FCB souboru parametrñ PAR
         mov       [adrfcb],bx              ; FCB souboru k naáten°
         call      loaddt                   ; naáten° souboru parametrñ PAR
         mov       bx,[adrdta]              ; konec tabulky parametrñ
         mov       [adrtop],bx              ; adresa konce volnÇ pamàti
         jc        gen5                     ; soubor nenalezen - novò soubor
         mov       dx,[adrpar]              ; zaá†tek tabulky parametrñ
         cmp       bx,dx                    ; obsahuje soubor alespo§ vektor ?
         jnc       gen6                     ; je vàt®°
         mov       dx,offset txter3         ; text chyby souboru parametrñ
         mov       ah,9
         int       21h
         jmp       errend                   ; chybovò n†vrat

                                            ; vytvo©en° souboru parametrñ
gen5:   ; mov       dx,offset fcbpar         ; soubor nenalezen
        ; mov       ah,22
        ; int       21h                      ; zaloëen° novÇho souboru
        ; mov       dx,offset fcbpar         ; FCB souboru PAR
        ; mov       ah,16
        ; int       21h                      ; uzav©en° souboru PAR
        ; mov       bx,[adrpar]
        ; push      bx
        ; add       bx,80h
        ; mov       [adrtop],bx              ; adresa volnÇ pamàti
        ; call      tstend                   ; test konce pamàti
        ; pop       bx
        ; jnc       gen6                     ; pamàü OK
        ; jmp       errend                   ; chyba pamàti
        ;
                                            ; zaá†tek cyklu obsluhy programu
gen6:    mov       bx,[adrcom]              ; adresa zaá†tku programu COM
         mov       [rdadr],bx               ; átec° adresa pro listov†n°
         call      adrlog                   ; p©evod na logickou adresu
         mov       bp,bx                    ; BP = b†zov† adresa instrukce
gen7:    mov       dx,offset txtuv2         ; £vodn° nab°dka
         mov       ah,9
         int       21h                      ; tisk £vodn° nab°dky
         mov       dx,offset txtuv3         ; text "Voln† pamàü :"
         mov       ah,9
         int       21h                      ; tisk "Voln† pamàü :"
         mov       bx,[6]                   ; konec volnÇ pamàti
         sub       bx,[adrtop]              ; zaá†tek volnÇ pamàti
         call      tskwrh                   ; tisk volnÇ pamàti (slovo HEX)
         call      tskcr                    ; od©†dkov†n°
         call      tskcr                    ; od©†dkov†n°
vstup:   mov       sp,offset stack          ; z†sobn°k
         call      inpclr                   ; vymaz†n° vstupn°ho ©†dku
         mov       dx,offset txtpov         ; text "POVEL:"
         call      tstext                   ; tisk POVEL:
         mov       al,1                     
         call      inptx1                   ; vstup prikazoveho retezce
;         jp        z,genb
;         call      rdznk
;         jc        vstup
;         cmp a     l,"L"
;         jp        z,inadr
;         cmp a     l,"E"
;         jp        z,vstpen
;         cmp       al,"P"
;         jp        z,vstpag
;         cmp       al,"A"
;         jp        z,vsta
;         cmp       al,"T"
;         jp        z,vstb
;         cmp       al,3
;         jp        z,vstpez
;         cmp       al,"D"
;         jp        z,datas
;         cmp       al,"C"
;         jp        z,coms
;         cmp       al,"H"
;         jp        z,hexs
;         cmp       al,"I"
;         jp        z,isos
;         cmp       al,";"
;         jp        z,vstta
;         cmp       al,"*"
;         jp        z,vsttb
;         cmp       al," "
;         jp        z,gen7
;         jr        vstup

          jmp       errend

pagel    db        0         ; dxl          ka stranky

comment %

vstpag:   mov  dx,txtpag
          call tstext
          mov  al,4
          call inptx1
          call rdword
          jp   c,vstup
          mov  al,h
          or   al,a
          jp   nz,vstup
          mov  al,l
          mov  [pagel],a
          jmp  vstup
txtpag    db   "    Delka stranky [HEX] : $",160


prvst0:   push bx             ; pridxleni poznamky:HL adresa,
          push dx
          mov  [labpri],a
          call txtask
          inc  bx
          push cx
          mov  b,0
          jc   prvst2
          mov  dx,inpbff+2
prvst1:   mov  al,[bx]
          and  al,7fh
          mov  [dx],a
          inc  b
          bit  7,[bx]
          inc  bx
          inc  dx
          jz   prvst1
prvst2:   mov  al,b
          mov  [inpbff+1],a
          pop  cx
          pop  dx
          pop  bx
          ret


vstta:    call inadre
          jp   c,vstup
          mov  dx,txttxt
          call tstext
          mov  al,1fh
          call prvst0
          mov  al,255
          call inptx1
          dxc  dx
          inc  c
          mov  al,1fh
          mov  [dx],a
vstta1:   call pridtx
          jmp  vstup


vsttb:    call inadre
          jp   c,vstup
          mov  dx,txttxt
          call tstext
          mov  al,1eh
          call prvst0
          mov  al,255
          call inptx1
          dxc  dx
          inc  c
          mov  al,1eh
          mov  [dx],a
vsttb1:   call pridtx
          jmp  vstup



hexs:     call inadre
          jp   c,vstup
          push bx
          mov  dx,inpbff+1
          mov  c,1
          mov  al,1dh
          mov  [dx],a
          call pridtx
          mov  bx,[adrpar]
          mov  [adrpr5],bx
          pop  bx
          mov  dx,inpbff+2
          mov  al,80h
          mov  [dx],a
          dxc  dx
          mov  al,1ch
          mov  [dx],a
          mov  c,2
          call pridtx
          jmp  vstup

isos:     call inadre
          jp   c,vstup
          mov  dx,inpbff+1
          mov  c,1
          mov  al,1ch
          mov  [dx],a
          push bx
          call pridtx
          mov  bx,[adrpar]
          mov  [adrpr5],bx
          pop  bx
          mov  dx,inpbff+2
          mov  al,80h
          mov  [dx],a
          dxc  dx
          mov  al,1dh
          mov  [dx],a
          mov  c,2
          call pridtx
          jmp  vstup



datas:    call inadre
          jp   c,vstup
          call adrfyz
          xor  al,a
          call setbit
          jmp  vstup

coms:     call inadre
          jp   c,vstup
          call adrfyz
          clc
          call setbit
          jmp  vstup

inadre:   mov  dx,txtadr
          call tstext
          mov  al,10
          call inptx1
          clc
          ret  z   
          call rdadre
          ret  c
          xor  al,a
          ret

vstb:     call inadre
          jp   c,vstup
          call adrfyz
          call tskcr
          call gentra
          jmp  vstup

badznk:   push cx
          push bx
          push dx
          mov  b,0
badzn1:   mov  e,0ffh
          push cx
          mov  ah,6
          int  21h
          pop  cx
          loop badzn1
          pop  dx
          pop  bx
          pop  cx
          ret

vsta:     call inadre
          jp   c,vstup
          mov  dx,txtnav
          call tstext
          mov  al,6
          call inptx1
          push bx
          push dx
          push cx
          call labbxd
          pop  cx
          pop  dx
          pop  bx
          jc   vsta1        ; bxaseni NAVESTI EXISTUJE
          push dx
          call inpclr
          call badznk
          mov  bx,txter8
          call tsktxt
          pop  bx
          push cx
          mov  b,c
vsta6:    mov  al,[bx]
          inc  bx
          call tskznk
          loop vsta6
          pop  cx
          mov  bx,txter9
          call tsktxt
          call badznk
          mov  al,1
          call inptx1
          jmp  vstup
vsta1:    call pridlb
          jmp  vstup
pridlb:   mov  al,h
          or   al,l
          ret  z
          push bx             ; pridxleni navesti:HL adresa,
          call labask         ; DE - adr.navesti, C - pocet znaku
          jc   pridl2
          push cx
          push dx             ; adresa navesti
          push bx             ; adresa zaznamu
          pop  dx
          dxc  dx
          dxc  dx             ; zacatek zaznamu
pridl1:   bit  7,[bx]
          inc  bx
          jz   pridl1
          push bx             ; nasledujici zaznam
          push dx
          ex   dx,bx
          mov  bx,[adrtop]
          or   al,a
          scx  bx,dx
          push bx
          pop  cx
          pop  dx
          pop  bx
          jz   pridl3
          jnc  pridld
pridl3:   mov  cx,4
pridld:   ldir
          mov  [adrtop],dx
          pop  dx
          pop  cx
pridl2:   pop  bx
          mov  al,c
          or   al,a
          ret  z
          push cx        ; pocet znaku
          push dx        ; adresa navesti
          ex   dx,bx     ; v DE adresa
          mov  bx,[adrpar]
pridl4:   mov  al,[bx]
          inc  bx
          or   al,[bx]
          inc  bx
          jz   pridl7
          dxc  bx
          mov  al,d
          cmp  al,[bx]
          jnz  pridl5
          dxc  bx
          mov  al,e
          cmp  al,[bx]
          inc  bx
pridl5:   inc  bx
          jc   pridl7
pridl6:   bit  7,[bx]
          inc  bx
          jz   pridl6
          jr   pridl4
pridl7:   push cx        ; v C pocet znaku
          push dx        ; v DE adresa
          push bx        ; v HL adresa mista ve vektoru
          pop  dx
          dxc  dx
          dxc  dx        ; zacatek zaznamu navesti
          mov  b,0
          add  bx,cx     ; nova adresa zaznamu
          push dx
          push bx
          mov  bx,[adrtop]
          or   al,a
          scx  bx,dx
          push bx
          pop  cx        ; v BC pocet bytu k presunuti
          pop  dx        ; nova adresa zaznamu
          pop  bx        ; stara adresa zaznamu
          jz   pridlc
          jnc  pridla
pridlc:   mov  cx,4
pridla:   add  bx,cx
          dxc  bx
          ex   dx,bx
          add  bx,cx
          call tstend
          jp   c,vstup
          mov  [adrtop],bx
          dxc  bx
          ex   dx,bx
          lddr
          inc  bx
pridl9:   pop  dx        ; adresa
          mov  [bx],e
          inc  bx
          mov  [bx],d
          inc  bx
          pop  cx        ; pocet znaku
          pop  dx        ; adresa navesti
          ex   dx,bx
          mov  b,0
          ldir
          ex   dx,bx
          dxc  bx
          set  7,[bx]
          inc  bx
          pop  cx
          or   al,a
          ret

pridtx:   mov  al,h
          or   al,l
          ret  z
          push bx             ; pridxleni poznamky:HL adresa,
          mov  al,[dx]
          mov  [labpri],a
          call txtask         ; DE - adr.poznamky, C - pocet znaku
          jc   pridt2
          push cx             ; vypusteni stareho zaznamu
          push dx             ; adresa navesti
          push bx             ; adresa zaznamu
          pop  dx
          dxc  dx
          dxc  dx             ; zacatek zaznamu
pridt1:   bit  7,[bx]
          inc  bx
          jz   pridt1
          push bx             ; nasledujici zaznam
          push dx
          ex   dx,bx
          mov  bx,[adrtop]
          or   al,a
          scx  bx,dx
          push bx
          pop  cx
          pop  dx
          pop  bx
          jz   pridt3
          jnc  pridtd
pridt3:   mov  cx,4
pridtd:   ldir
          mov  [adrtop],dx
          pop  dx
          pop  cx
pridt2:   pop  bx
          mov  al,c
          cmp  al,2
          ret  c
          push cx        ; pocet znaku
          push dx        ; adresa navesti
          ex   dx,bx     ; v DE adresa
          mov  bx,[adrpar]
pridt4:   mov  al,[bx]
          inc  bx
          or   al,[bx]
          inc  bx
          jz   pridt7
          dxc  bx
          mov  al,d
          cmp  al,[bx]
          jnz  pridt5
          dxc  bx
          mov  al,e
          cmp  al,[bx]
          inc  bx
pridt5:   inc  bx
          jc   pridt7
pridt6:   bit  7,[bx]
          inc  bx
          jz   pridt6
          jr   pridt4
pridt7:   push cx        ; v C pocet znaku
          push dx        ; v DE adresa
          push bx        ; v HL adresa mista ve vektoru
          pop  dx
          dxc  dx
          dxc  dx        ; zacatek zaznamu textu
          mov  b,0
          add  bx,cx     ; nova adresa zaznamu
          push dx
          push bx
          mov  bx,[adrtop]
          or   al,a
          scx  bx,dx
          push bx
          pop  cx        ; v BC pocet bytu k presunuti
          pop  dx        ; nova adresa zaznamu
          pop  bx        ; stara adresa zaznamu
          jz   pridtc
          jnc  pridta
pridtc:   mov  cx,4
pridta:   add  bx,cx
          dxc  bx
          ex   dx,bx
          add  bx,cx
          mov  [adrtop],bx
          dxc  bx
          ex   dx,bx
          lddr
          inc  bx
pridt9:   pop  dx        ; adresa
          mov  [bx],e
          inc  bx
          mov  [bx],d
          inc  bx
          pop  cx        ; pocet znaku
          pop  dx        ; adresa textu
          ex   dx,bx
          mov  b,0
          ldir
          ex   dx,bx
          dxc  bx
          set  7,[bx]
          inc  bx
          pop  cx
          or   al,a
          ret

txtask:   mov  al,h
          or   al,l
          clc
          ret  z
          push dx        ; dotaz na text podle adresy
          push cx
          push bx
          ex   dx,bx
          mov  bx,[adrpar]
txtas1:   push dx
          mov  dx,[adrtop]
          cmp  bx,dx
          pop  dx
          jnc  txtas4
          mov  al,[bx]
          inc  bx
          or   al,[bx]
          dxc  bx
          jz   txtas4
          mov  al,e
          cmp  al,[bx]
          inc  bx
          jnz  txtas2
          mov  al,d
          cmp  al,[bx]
          inc  bx
          jnz  txtas3
          mov  al,[bx]
          mov  b,a
          mov  al,[labpri]
          cmp  al,b
          jnz  txtas3
txtas5:   or   al,a
          pop  dx
          pop  cx
          pop  dx
          ret
txtas2:   inc  bx
txtas3:   bit  7,[bx]
          inc  bx
          jz   txtas3
          jr   txtas1
txtas4:   pop  bx
          pop  cx
          pop  dx
          clc
          ret





labpri    db   1eh            ; priznak pro bxedani navesti
txten     db   "     Konec ? [A=ano] : $"
txtzru    db   "     Zrusit ??!! [A=ano] : $"

txter8    db   15h,"Navesti $",160
txter9    db   " jiz existuje ! $",160
adtrs     db   13,10,10,"Cekejte, probiha trasovani programu !",13,10,"$"
adtr2     db   13,10,10,"Cekejte, probiha zaznam programu !",13,10,"$"
txttr4    db   "    Tisknout v abs.kodu ? [A=ano] : $"

gentra:   push bx
          pop  si             ; adresa programu v HL a IX
          mov  dx,0
          push dx
gent1:    call rdbit          ; trasovani programu
          jp   c,gent5        ; snizeni adres - bylo trasovano
          clc
          call setbit         ; nastaveni priznaku 
          push bx
          call longb
          pop  bx
          mov  al,[bx]         ; byte instrukce
          cmp  al,0c9h
          jp   z,gent5        ; snizeni adres - RET
          cmp  al,0e9h
          jp   z,gent5        ; snizeni adres - JP [HL]
          cmp  al,0edh
          jnz  gentc1
          inc  bx
          mov  al,[bx]
          dxc  bx
          and  al,0f7h
          cmp  al,45h
          jp   z,gent5        ; snizeni adres - RETN,RETI
          and  al,0c7h
          cmp  al,43h
          jp   z,gentc3       ; adresa DDW
          jmp  gent10
gentc1:   cmp  al,0c3h
          jp   z,gent3        ; nova adresa  - JP a
          cmp  al,0cdh
          jp   z,gent2        ; zvyseni adres - CALL a
          cmp  al,10h
          jp   z,gent6        ; zvyseni adres - DJNZ e
          cmp  al,18h
          jp   z,gent4        ; nova adresa - JR e
          cmp  al,0ddh
          jz   gentcd
          cmp  al,0fdh
          jnz  gentce
gentcd:   inc  bx
          mov  al,[bx]
          dxc  bx
          cmp  al,21h
          jp   z,gentc4
          jmp  gent10
gentce:   and  al,0f7h
          cmp  al,32h
          jp   z,gentc2       ; adresa DDB
          cmp  al,22h
          jp   z,gentc3       ; adresa DDW
          and  al,0e7h
          cmp  al,20h
          jp   z,gent6        ; zvyseni adres - JR podm,e
          and  al,0c7h
          cmp  al,0c2h           ; zvyseni adres - JP podm,a
          jp   z,gent2
          cmp  al,0c4h
          jp   z,gent2        ; zvyseni adres - CALL podm,a
          mov  al,[bx]
          and  al,0cfh
          cmp  al,1
          jp   z,gentc4       ; adresa DTB
gent10:   inc  bx
          inc  si
          loop gent10
          jmp  gent1
gentc2:   mov  dx,adrddb
          jr   gentc5
gentc3:   mov  dx,adrddw
          jr   gentc5
gentc4:   mov  dx,adrdtb
gentc5:   push bx
          push cx
          mov  l,[si+1]
          mov  h,[si+2]
          call adrfyz
          jc   gentc6
          call adrlog
          mov  c,6
          call nastl
gentc6:   pop  cx
          pop  bx
          jmp  gent10




gent6:    inc  bx             ; zvyseni adres relativne
          loop gent6
          push bx
gent4:    push si             ; nova adresa relativne
          pop  bx
          mov  e,[si+1]
          mov  d,0
          inc  bx
          inc  bx
          add  bx,dx
          bit  7,e
          jz   gent41
          dxc  h
gent41:   push bx
          pop  si
          push bx
          call adrlog
          jp   c,gent5
          mov  dx,adrlbl
          call nastl
          pop  bx
          jmp  gent1
gent2:    inc  bx             ; zvyseni adres
          loop gent2
          push bx
gent3:    mov  l,[si+1]       ; nova adresa
          mov  h,[si+2]
          call adrfyz
          jc   gent5
          push bx
          call adrlog
          mov  dx,adrlbl
          call nastl
          pop  bx
          push bx
          pop  si
          jmp  gent1
gent50:   pop  bx
gent5:    pop  bx             ; snizeni adres
          push bx
          pop  si
          mov  al,h
          or   al,l
          jp   nz,gent1
          ret

adrlbl    db   4,"lab000$"
adrdtb    db   4,"tbl000$"
adrddb    db   4,"byt000$"
adrddw    db   4,"wrd000$"
pozn1     dw   0              ; poznamka k adrese - nadpis
pozn2     dw   0              ; poznamka k insrukci




nastl:    mov  al,h
          or   al,l
          ret  z
          push cx             ; nastavi navesti v DE na adresu HL
          push bx
          push dx
          mov  al,[dx]
          mov  c,a
          inc  dx
          call labask
          pop  dx
          pop  bx
          jnc  nastle
          push bx
nastl0:   push dx
          mov  al,[dx]
          inc  dx
          inc  dx
          inc  dx
          inc  dx
          mov  c,a
          cmp  al,5
          jz   nastk1
          cmp  al,4
          jz   nastm1
          or   al,a
          inc  dx
          inc  dx
          mov  al,[dx]
          inc  a
          cmp  al,":"
          ccf  
          jnc  nastl1
          mov  al,"0"
nastl1:   mov  [dx],a
          dxc  dx
          mov  al,[dx]
          adc  a,0
          cmp  al,":"
          ccf
          jnc  nastl2
          mov  al,"0"
nastl2:   mov  [dx],a
          dxc  dx
          mov  al,[dx]
          adc  a,0
          mov  [dx],a
          mov  c,6
nastl3:   dxc  dx
          dxc  dx
          dxc  dx
          dxc  dx
          mov  al,c
          mov  [dx],a
          inc  dx
          call labbxd
          pop  dx
          jnc  nastl0
          pop  bx
          mov  al,[dx]
          inc  dx
          mov  c,a
          call pridlb
nastle:   pop  cx
          ret
          
nastk1:   inc  dx
          mov  al,[dx]
          inc  a
          cmp  al,":"
          ccf
          jnc  nastk2
          mov  al,"0"
nastk2:   mov  [dx],a
          dxc  dx
          mov  al,[dx]
          adc  a,0
          cmp  al,":"
          ccf
          mov  c,5
          jnc  nastk3
          mov  al,"1"
          mov  c,6
nastk3:   mov  [dx],a
          jmp  nastl3
nastm1:   mov  al,[dx]
          inc  a
          cmp  al,":"
          mov  c,4
          jc   nastm2
          mov  al,"1"
          mov  c,5
nastm2:   mov  [dx],a
          jmp  nastl3


rdadre:   call outsp
          ret  c
          cmp  al,"."
          jz   rdadrg
          cmp  al,"0"
          ret  c
          call labbxd
          jnc  rdadrf
          call rdword
          ret  c
rdadrf:   mov  [zaznad],bx
rdadrg:   mov  bx,[zaznad]
          ret

zaznad:   dw   0

txtz80    db   ".z8","0"+128
txtequ    db   "eq","u"+128
txtend    db   "en","d"+128
txtor1    db   "org",160
vsss0     db   0





vstpez:   mov  dx,txtzru
          call tstext
          mov  al,1
          call inptx1
          jp   z,vstup
          call rdznk
          cmp  al,"A"
          jp   z,0
          jmp  vstup

vstpen:   mov  dx,txten       ; ukonceni prace
          call tstext
          mov  al,1
          call inptx1
          jp   z,vstup
          call rdznk
          cmp  al,"A"
          jp   nz,vstup
          xor  al,a
          mov  [vsss0],a
          mov  dx,txttr4
          call tstext
          mov  al,1
          call inptx1
          call tskcr
          call rdznk
          cmp  al,3
          jp   z,vstup
          cmp  al,"A"
          jnz  vsss3
          mov  al,1
          mov  [vsss0],a
vsss3:    mov  ah,13
          int  21h
          mov  bx,[adrvek]    ; zaznam vektoru parametru
          mov  [adrDTA],bx
          mov  dx,fcbpar
          mov  ah,19
          int  21h              ; zruseni stareho souboru
          mov  bx,0
          mov  [fcbpar+32],bx
          mov  dx,fcbpar
          mov  ah,22
          int  21h              ; zalozeni noveho souboru
vstpe1:   mov  dx,[adrDTA]
          mov  ah,26
          int  21h              ; nastaveni adresy DTA
          mov  dx,fcbpar
          mov  ah,21
          int  21h              ; zapis sektoru
          or   al,a
          jp   nz,vstpee
          mov  bx,[adrDTA]
          mov  cx,80h
          add  bx,cx
          mov  [adrDTA],bx
          mov  dx,[adrtop]
          cmp  bx,dx
          jc   vstpe1
          mov  dx,fcbpar
          mov  ah,16
          int  21h              ; uzavreni souboru PAR
          mov  dx,adtr2
          call tstext
          mov  dx,fcbmac
          mov  ah,19
          int  21h              ; zruseni stareho souboru
          mov  dx,fcbmac
          mov  ah,22
          int  21h              ; zalozeni noveho souboru
          mov  bx,80h
          mov  [adrDTA],bx
          xor  al,a
          mov  [uklcit],a
          mov  [tskzn0],a
          mov  [fcbmac+12],a
          mov  [fcbmac+32],a
          mov  dx,80h
          mov  ah,26
          int  21h
          ;mov  bx,tbtab2
          ;mov  [tablad+1],bx
          mov  bx,fcbmac
          mov  [adrfcb],bx
          mov  bx,[adrcom]
          mov  [rdadr],bx
          mov  bx,[adrpar]
          mov  [nxtadr],bx
          mov  [adrpr5],bx
          mov  al,1dh
          mov  [prizn5],a
          call tskcr
          mov  al,8
          call tabul0
          mov  bx,txtz80
          call tsktxt
          call tskcr
          call tskcr
          mov  al,8
          call tabul0
          mov  bx,txtor1
          call tsktxt
          mov  al,5
          call tabul0
          mov  bx,[base]
          call tskcis
          mov  al,1
          mov  [tskzn0],a
          mov  bx,[base]
          call tskwrd
          xor  al,a
          mov  [tskzn0],a
          call tskcr
          call tskcr
sgeno:    mov  bx,0
          mov  [pozn1],bx
          mov  [pozn2],bx
          mov  bx,[rdadr]     ; vypis pameti
          mov  dx,[adrvek]
          cmp  bx,dx
          jp   nc,vstpek
          call inpzn0
          cmp  al,3
          jp   z,vstp2e
sgen1:    mov  al,[prizn3]
          or   al,a
          jz   sgeng
          xor  al,a
          mov  [prizn3],a
          mov  bx,txtodd
          call tsktxt
          call tskcr
sgeng:    mov  bx,[rdadr]
          push bx
          call tskspc
          call adrlog
          mov  al,[vsss0]
          or   al,a
          jz   sgss1
          push bx
          call tskwrd

          mov  al,1
          mov  [tskzn0],a
          rept 4
          mov  al,8
          call tskznk
          endm
          call tskwrd
          xor  al,a
          mov  [tskzn0],a

          mov  al,":"
          call tskznk
          mov  al,5
          call tabul0
          mov  bx,[rdadr]
          call rdbit
          jnc  sgss3
          call longb
          mov  bx,[rdadr]
sgss4:    mov  al,[bx]
          inc  bx
          call tskbyt
          call tskspc
          loop sgss4
sgss3:    mov  al,12
          call tabul0
          pop  bx
sgss1:    call labnxt
          jc   sgeng1
          call tsktxt
sgss2:    mov  al,":"
          call tskznk
sgeng1:   pop  bx
          push bx
          call adrlog
          mov  al,1eh
          mov  [labpri],a
          call txtask
          jc   sgent2
          inc  bx             ; tisk poznamky k adrese
          mov  al,17
          call tabul0
          mov  al,";"
          call tskznk
          call tskspc
          call tsktxt
          call tskcr
          mov  al,[vsss0]
          or   al,a
          jz   sgent2
          mov  al,17
          call tabul0
sgent2:   pop  bx
          mov  al,8
          call tabul0
          push bx
          pop  si             ; adresa pro preklad
          call rdbit
          jp   c,sgenm
sgen3a:   push bx             ; tisk dat
          mov  bx,txtdb
          call tsktxt
          mov  al,5
          call tabul0
          pop  bx
          mov  al,[bx]
          call testas
          jc   sgens        ; tisk DB v ASCII
          mov  al,34
          call tskznk
sgens2:   mov  al,[bx]
          call testas
          jc   sgens4
          inc  bx
          mov  [rdadr],bx
sgens5:   call tskznk
          cmp  al,"$"
          jz   sgens4
          call rdbit
          jc   sgens4
          push bx
          call adrlog
          call labnxt
          pop  bx
          jnc  sgens4
          mov  al,[pozice]
          cmp  al,pocpoz-4
          jnc  sgens4
          cmp  al,pocpoz-15
          jc   sgens2
          mov  al,[bx]
          cmp  al,32
          jnz  sgens2
sgens4:   mov  al,34
          call tskznk
          jmp  sgenr
sgenn:    mov  al,[bx]         ; tisk DB v HEX
          call testas
          jp   nc,sgenr
          mov  al,","
          call tskznk
sgens:    mov  al,[bx]
          inc  bx
          mov  [rdadr],bx
sgens1:   push bx
          mov  l,a
          mov  h,0
          call tskcis
          pop  bx
          call rdbit
          jp   c,sgenr
          push bx
          call adrlog
          call labnxt
          pop  bx
          jp   nc,sgenr
          mov  al,[pozice]
          cmp  al,pocpoz-8
          jc   sgenn
          jmp  sgenr
sgenm:    call longb
          mov  bx,[rdadr]
          push bx
          mov  bx,[nxtadr]
          push bx
          mov  bx,[rdadr]
          push cx
          jr   sgenm2
sgenm1:   push bx
          call adrlog
          call labnxt
          pop  bx
          jnc  sgenm3
          push bx
          call rdbit
          pop  bx
          jnc  sgenm2
sgenm3:   pop  cx
          pop  bx
          mov  [nxtadr],bx
          pop  bx
          jmp  sgen3a
sgenm2:   inc  bx
          loop sgenm1
          mov  [rdadr],bx
          pop  cx
          pop  bx
          mov  [nxtadr],bx
          pop  bx
          push bx
sgena2:   pop  bx
          push si
          call disas
          pop  bx
          jc   sgenc
sgenr:    push bx
          call adrlog
          mov  al,1fh
          mov  [labpri],a
          call txtask
          jnc  sgenr1
          mov  bx,[pozn2]
          mov  al,h
          or   al,l
          jz   sgenr2
          mov  al,1eh
          mov  [labpri],a
          call txtask
          jc   sgenr2
sgenr1:   inc  bx
          mov  al,12
          call tabul0
          mov  al,";"
          call tskznk
          call tskspc
          call tsktxt
sgenr2:   pop  bx
          call tskcr
          jc   sgenc
          jmp  sgeno
sgenc:    mov  dx,txter6
          mov  ah,9
          int  21h
sgenf:    jmp  vstup


          jmp  0
vstpee:   mov  dx,txter4
          call tstext
vstp2e:   mov  al,1
          mov  [tskzn0],a
          xor  al,a
          mov  [vsss0],a
          ;mov  bx,tbtab1
          ;mov  [tablad+1],bx
          mov  dx,fcbpar
          mov  ah,16
          int  21h
          mov  dx,fcbmac
          mov  ah,16
          int  21h
          jmp  vstup
vstpek:   call tskcr
          call tskcr
          call tskcr
          mov  bx,0
          mov  [rdadr],bx
          mov  bx,[adrpar]
          mov  [nxtadr],bx
vstpk2:   mov  bx,[rdadr]
          push bx
          inc  bx
          mov  [rdadr],bx
          mov  al,h
          or   al,l
          pop  bx
          jz   vstpk3
          call labnxt
          jc   vstpk2
          push bx
          mov  bx,[rdadr]
          call adrfyz
          jc   vstpk4
          mov  al,";"
          call tskznk
          call tskspc
vstpk4:   pop  bx
          call tsktxt
          mov  al,":"
          call tskznk
          mov  al,10
          call tabul0
          mov  bx,txtst1
          call tsktxt
          mov  bx,[rdadr]
          call tskcis
          call tskcr
          jr   vstpk2
vstpk3:   call tskcr
          mov  al,8
          call tabul0
          mov  bx,txtend
          call tsktxt
          mov  al,5
          call tabul0
          mov  bx,[base]
          call tsklb
          call tskcr
          mov  al,1ah
          call tskznk
          mov  dx,fcbmac
          mov  ah,21
          int  21h              ; zapis posledniho sektoru
          mov  dx,fcbmac
          mov  ah,16
          int  21h              ; uzavreni souboru
          jmp  0

txtst1    db   "set",160







inadr:    call inadre
          jp   c,vstup
          push bx
          call adrfyz
          pop  dx
          jp   c,vstup
          push dx
          pop  si
          mov  [rdadr],bx
          call inpclr
          call tskcr
genb:     mov  al,[pagel]
          mov  b,a
          mov  bx,[adrpar]
          mov  [nxtadr],bx
          mov  [adrpr5],bx
          mov  al,1dh
          mov  [prizn5],a
          call inpclr
geno:     mov  bx,0           ; vypis pameti
          mov  [pozn1],bx
          mov  [pozn2],bx
          mov  bx,[rdadr]
          mov  dx,[adrvek]
          cmp  bx,dx
          jp   nc,vstup
          call inpzn0
          jp   nz,vstup
          push cx
          mov  al,[prizn3]
          or   al,a
          jz   geng
          xor  al,a
          mov  [prizn3],a
          mov  bx,txtodd
          call tsktxt
          call tskcr
geng:     mov  bx,[rdadr]
          call adrlog
          call tskwrd
          mov  al,":"
          call tskznk
          mov  al,5
          call tabul0
          mov  bx,[rdadr]
          push bx
          pop  si             ; adresa pro preklad
          call rdbit
          jp   c,genm
geng3a:   push bx             ; vypis DB
          mov  al,17
          call tabul0
          ;mov  al,"|"
          ;call tskznk
          ;call tabul
          call adrlog
          call labnxt
          jc   genet
          call tsktxt
          mov  al,":"
          call tskznk
genet:    mov  al,8
          call tabul0
          push bx
          push si
          pop  bx
          call adrlog
          mov  al,1eh
          mov  [labpri],a
          call txtask
          jc   genet2
          inc  bx
          mov  al,17
          call tabul0
          mov  al,";"
          call tskznk
          call tskspc
          call tsktxt
          call tskcr
          mov  al,25
          call tabul0
          ;mov  al,"|"
          ;call tskznk
genet2:   pop  bx
          mov  bx,txtdb
          call tsktxt
          mov  al,5
          call tabul0
          mov  b,8
          pop  bx
          mov  al,[bx]
          call testas
          jc   gens         ; tisk DB v ASCII
          mov  al,34
          call tskznk
gens2:    mov  al,[bx]
          call testas
          jc   gens4
          inc  bx
          mov  [rdadr],bx
gens5:    call tskznk
          cmp  al,"$"
          jz   gens4
          call rdbit
          jc   gens4
          push bx
          call adrlog
          call labnxt
          pop  bx
          jnc  gens4
          mov  al,[pozice]
          cmp  al,pocpoz-4
          jnc  gens4
          cmp  al,pocpoz-15
          jc   gens2
          mov  al,[bx]
          cmp  al,32
          jnz  gens2
gens4:    mov  al,34
          call tskznk
          jmp  genr
genn:     mov  al,[bx]         ; tisk DB v HEX kodu
          call testas
          jp   nc,genr
          mov  al,","
          call tskznk
gens:     mov  al,[bx]
          inc  bx
          mov  [rdadr],bx
gens1:    push bx
          mov  l,a
          mov  h,0
          call tskcis
          pop  bx
          call rdbit
          jp   c,genr
          push bx
          call adrlog
          call labnxt
          pop  bx
          jp   nc,genr
          loop genn
          jmp  genr
genm:     call longb          ; dxlka instrukce
          mov  bx,[rdadr]
          push bx
          mov  bx,[nxtadr]
          push bx
          mov  bx,[rdadr]
          push cx
          call adrlog
          jr   genm2
genm1:    push bx
          call labnxt
          pop  bx
          jnc  genm3
          push bx
          call adrfyz
          call rdbit
          pop  bx
          jnc  genm2
genm3:    pop  cx
          pop  bx
          mov  [nxtadr],bx
          pop  bx
          jmp  geng3a
genm2:    inc  bx
          loop genm1
          pop  cx
          pop  bx
          mov  [nxtadr],bx
          pop  bx
;          push bx
          push cx
gend:     mov  al,[bx]
          inc  bx
          call tskbyt
          call tskspc
          loop gend           ; tisk bytu instrukce
          mov  al,12
          call tabul0
          pop  cx
;          pop  bx
;          mov  al,"["
;          call tskznk
;geni:     mov  al,[bx]
;          inc  bx
;          cmp  al,20h
;          jc   genj
;          cmp  al,7fh
;          jc   genk
;genj:     mov  al,32
;genk:     call tskznk
;          loop geni
;          mov  al,"]"
;          call tskznk
          mov  [rdadr],bx
;          call tabul
          ;mov  al,"|"
          ;call tskznk
          push si
          pop  bx
          call adrlog
          call labnxt
          jc   genla
          call tsktxt
          mov  al,":"
          call tskznk
genla:    mov  al,8
          call tabul0
          push bx
          push si
          pop  bx
          call adrlog
          mov  al,1eh
          mov  [labpri],a
          call txtask
          jc   genla2
          inc  bx
          mov  al,17
          call tabul0
          mov  al,";"
          call tskznk
          call tskspc
          call tsktxt
          call tskcr
          mov  al,25
          call tabul0
          ;mov  al,"|"
          ;call tskznk
genla2:   pop  bx
          push si
          call disas
          pop  bx
          jc   genc
genr:     push bx
          call adrlog
          mov  al,1fh
          mov  [labpri],a
          call txtask
          jnc  genr1
          mov  bx,[pozn2]
          mov  al,h
          or   al,l
          jz   genr2
          mov  al,1eh
          mov  [labpri],a
          call txtask
          jc   genr2
genr1:    inc  bx
          mov  al,12
          call tabul0
          mov  al,";"
          call tskznk
          call tskspc
          call tsktxt
genr2:    pop  bx
          call tskcr
          jc   genc
          pop  cx
          mov  al,b
          or   al,a
          jp   z,geno
          dxc  b
          jp   nz,geno
          jmp  vstup
genc:     mov  dx,txter6
          mov  ah,9
          int  21h
          pop  cx
genf:          

          jmp  vstup

labbxd:                       ; nalezeni navesti podle jmena
                              ; v DE adresa jmena navesti
          push bx             ; v C pocet znaku navesti
          mov  bx,[adrpar]
labbx1:   push dx
          mov  dx,[adrtop]
          cmp  bx,dx
          jnc  labbx4
          mov  e,[bx]
          inc  bx
          mov  d,[bx]
          inc  bx
          mov  al,e
          or   al,d
          jz   labbx4
          ex   dx,bx
          ex   [sp],bx        ; ulozeni prectene adresy
          ex   dx,bx
          push cx
          push dx        ; zasobnik - adresa;pocet znaku;adresa navesti
labbx5:   mov  al,c
          or   al,a
          jz   labbx6
          mov  al,[dx]
          inc  dx
          dxc  c
          cmp  al,32
          jz   labbx6
          bit  7,[bx]
          jnz  labbx7
          cmp  al,[bx]
          inc  bx
          jz   labbx5
          jr   labbx6
labbx7:   or   al,128
          cmp  al,[bx]
          jnz  labbx6
          call rdznk
          jc   labbx8
          cmp  al,33
          jnc  labbx6
labbx8:   pop  bx
          pop  bx
          pop  bx
          inc  sp
          inc  sp
          or   al,a
          ret
labbx6:   pop  dx
          pop  cx
          inc  sp
          inc  sp
labbx3:   bit  7,[bx]
          inc  bx
          jz   labbx3
          jr   labbx1
labbx4:   pop  dx
          pop  bx
          clc
          ret


labask:   push dx        ; nalezeni navesti podle adresy
          push bx
          ex   dx,bx
          mov  bx,[adrpar]
labas1:   push dx
          mov  dx,[adrtop]
          cmp  bx,dx
          pop  dx
          jnc  labas4
          mov  al,[bx]
          inc  bx
          or   al,[bx]
          dxc  bx
          jz   labas4
          mov  al,e
          cmp  al,[bx]
          inc  bx
          jnz  labas2
          mov  al,d
          cmp  al,[bx]
          inc  bx
          jnz  labas3
          mov  al,[bx]
          cmp  al,32
          jc   labas3
          or   al,a
          pop  dx
          pop  dx
          ret
labas2:   inc  bx
labas3:   bit  7,[bx]
          inc  bx
          jz   labas3
          jr   labas1
labas4:   pop  bx
          pop  dx
          clc
          ret

nxtadr:   dw   0         ; adresa dalsiho navesti


labnxt:   push dx        ; nalezeni dalsiho navesti podle adresy v HL
          push bx
          ex   dx,bx
          mov  bx,[nxtadr]
labnx1:   push dx
          mov  dx,[adrtop]
          cmp  bx,dx
          pop  dx
          jnc  labnx4
          mov  al,[bx]
          inc  bx
          or   al,[bx]
          jz   labnx4
          mov  al,d
          cmp  al,[bx]
          jz   labnx5
          jnc  labnx2
          jr   labnx4
labnx5:   mov  al,e
          dxc  bx
          cmp  al,[bx]
          inc  bx
          inc  bx
          jz   labnx6
          jnc  labnx3
          jr   labnx4
labnx6:   mov  al,[bx]
          cmp  al,32
          jc   labnx3
          or   al,a
          pop  dx
          pop  dx
          ret
labnx2:   inc  bx
labnx3:   bit  7,[bx]
          inc  bx
          jz   labnx3
          mov  [nxtadr],bx
          jr   labnx1
labnx4:   pop  bx
          pop  dx
          clc
          ret

%

inpclr:  push      ax                       ; vymaz†n° vstupn°ho ©†dku
         push      cx
         push      dx
         mov       dl,13                    ; zaá†tek ©†dku
         mov       ah,2
         int       21h                      ; nastaven° na zaá†tek ©†dku
         mov       cx,pocpoz-2              ; poáet pozic ©†dku
inpclr1: mov       ah,2
         mov       dl,32                    ; znak mezery
         int       21h                      ; zobrazen° mezery
         loop      inpclr1                  ; dal®° mezera
         mov       dl,13                    ; zaá†tek ©†dku
         mov       ah,2
         int       21h
         pop       dx
         pop       cx
         pop       ax
         ret


inptxt:  mov       al,255                   ; poáet znakñ vstupn°ho bufferu

                                            ; vstup textu
                                            ; VSTUP:  AL=max. poáet znakñ
                                            ; VùSTUP: DX=adresa bufferu
                                            ;         AL=poáet zadanòch znakñ
inptx1:  push      bx
         mov       bx,offset inpbff
         inc       al
         mov       [bx],al                  ; max. poáet znakñ
         mov       dx,bx
         mov       ah,10
         int       21h                      ; vstup textu
         mov       al,[bx+1]
         or        al,al
         pop       bx
         ret

comment %


outzn0:   push bx
          push cx
          push dx
          push ax
          mov  e,a
          mov  ah,6
          int  21h
          pop  ax
          pop  dx
          pop  cx
          pop  bx
          ret

inpzn0:   push cx
          push dx
          push bx
          mov  ah,6
          mov  e,255
          int  21h
          or   al,a
          pop  bx
          pop  dx
          pop  cx
          ret
inpzn5:   push cx
          push dx
          push bx
          mov  ah,11
          int  21h
          or   al,a
          pop  bx
          pop  dx
          pop  cx
          ret
%

adrlog:                                     ; p©epoáet fyzickÇ adresy na logickou
                                            ; VSTUP: BX=fyzick† adresa COM
                                            ; VùSTUP:BX=logick† adresa COM
         push      dx
         mov       dx,[adrcom]              ; zaá†tek souboru COM v pamàti
         sub       bx,dx                    ; offset v souboru COM
         mov       dx,[base]                ; b†zov† adresa souboru COM
         add       bx,dx                    ; p©epoáten† logick† adresa v souboru
         cmp       bx,dx
         jc        adrlg2                   ; adresa pod b†zovou adresou programu
         push      bx                       ; logick† adresa
         mov       bx,[adrvek]              ; konec souboru COM v pamàti
         sub       bx,[adrcom]              ; zaá†tek souboru COM v pamàti
         add       dx,bx                    ; vòpoáet logickÇ adresy konce
         pop       bx                       ; logick† adresa
         cmp       bx,dx
         cmc
adrlg2:  pop       dx                       ; p©°znak CF - adresa mimo program
         ret       

tstext:  push      dx                       ; tisk textu v DX
         push      ax
         mov       ah,9
         int       21h                      ; tisk textu
         pop       ax
         pop       dx
         ret       

comment %


adrfyz:   push dx             ; prepocet logicke adresy na fyzickou
          mov  dx,[base]
          or   al,a
          scx  bx,dx
          mov  dx,[adrcom]
          add  bx,dx
          cmp  bx,dx
          jc   adrfz2
          mov  dx,[adrvek]
          cmp  bx,dx
          ccf
adrfz2:   pop  dx        ; priznak CY - adresa mimo program
          ret


citbuf    ds   1         ; citac bufferu
ukbuff    ds   2         ; ukazatel text.bufferu
txtodd    db   "; ......................................................$"

adrpr5    dw   0         ; adresa ukazatele ASCII
prizn5    dw   0         ; priznak ASCII




testas:   mov  al,[bx]
          cmp  al,32
          ret  c
          cmp  al,7fh
          ccf
          ret  c
          cmp  al,34
          clc
          ret  z

ascnxt:   push dx        ; zjisteni priznaku ASCII
          push bx
          call adrlog
          ex   dx,bx
          mov  bx,[adrpr5]
ascnx1:   push dx
          mov  dx,[adrtop]
          cmp  bx,dx
          pop  dx
          jnc  ascnx4
          mov  al,[bx]
          inc  bx
          or   al,[bx]
          jz   ascnx4
          mov  al,d
          cmp  al,[bx]
          jz   ascnx5
          jnc  ascnx2
          jr   ascnx4
ascnx5:   mov  al,e
          dxc  bx
          cmp  al,[bx]
          inc  bx
          inc  bx
          jz   ascnx6
          jp   nc,ascnx3
          jr   ascnx4
ascnx6:   mov  al,[bx]
          cmp  al,1ch
          jz   ascnx7
          cmp  al,1bh
          jz   ascnx7
          cmp  al,1dh
          jp   nz,ascnx3
ascnx7:   mov  [prizn5],a
          dxc  bx
          dxc  bx
          mov  [adrpr5],bx
          jr   ascnx4

ascnx2:   inc  bx
ascnx3:   mov  al,[bx]
          cmp  al,1ch
          jz   ascnx9
          cmp  al,1dh
          jz   ascnx9
          cmp  al,1bh
          jnz  ascnx8
ascnx9:   mov  [prizn5],a
ascnx8:   bit  7,[bx]
          inc  bx
          jz   ascnx8
          mov  [adrpr5],bx
          jr   ascnx1
ascnx4:   pop  bx
          pop  dx
          mov  al,[prizn5]
          cmp  al,1dh
          clc
          mov  al,[bx]
          ret  nz
          mov  al,[bx]
          or   al,a
          ret







rdbit:    push bx             ; precteni bitu z HL do CY
          push cx
          push dx
          mov  dx,[adrcom]    ; zacatek programu
          or   al,a
          scx  bx,dx          ; relativni adresa
          mov  al,l
          and  al,7
          mov  b,a
          sra  h
          rcr  l
          sra  h
          rcr  l
          sra  h
          rcr  l
          mov  dx,[adrvek]
          add  bx,dx          ; prvek vektoru
          mov  al,[bx]
          inc  b
rdbit1:   rrca
          loop rdbit1
          pop  dx
          pop  cx
          pop  bx
          ret

setbit:   push bx             ; nastaveni bitu HL na CY
          push cx
          push dx
          push ax
          mov  dx,[adrcom]    ; zacatek programu
          or   al,a
          scx  bx,dx          ; relativni adresa
          mov  al,l
          and  al,7
          inc  a
          mov  b,a
          mov  c,a
          sra  h
          rcr  l
          sra  h
          rcr  l
          sra  h
          rcr  l
          mov  dx,[adrvek]
          add  bx,dx          ; prvek vektoru
          mov  al,[bx]
          or   al,a
stbit1:   rra
          loop stbit1
          mov  b,a
          pop  ax
          mov  al,b
          mov  b,c
rdbit2:   rla
          loop rdbit2
          mov  [bx],a
          pop  dx
          pop  cx
          pop  bx
          ret
   
%
txtuv2    db   13,10,"N A B ã D K A  : ",13,10,10
          db   "T - trasov†n° programu",13,10
          db   "L - vòpis programu",13,10
          db   "<ET>dal®° str†nka programu",13,10
          db   "P - nastaven° dÇlky str†nky",13,10
          db   "A - nastaven° n†và®t° assembleru",13,10
          db   "D - p©°znak dat",13,10
          db   "C - p©°znak instrukce",13,10
          db   "H - p©°znak dat HEX",13,10
          db   "I - p©°znak  dat ISO-ASCII",13,10
          db   "* - pozn†mka k adrese",13,10
          db   "; - pozn†mka k instrukci",13,10
          db   "E - ukonáen° editace",13,10
          db   "^C- p©eru®en° editace bez uloëen° parametrñ",13,10
          db   "? - vòpis nab°dky",13,10
          db   13,10,"$"

txtuv3    db   "Voln† pamàü : $"
txtpov    db   "Povel : $"
txtadr    db   "       Adresa : $"
txtnaz    db   "       JmÇno : $"
txtnav    db   "       N†và®t° : $"
txttxt    db   "       Text: $"
          db   0,0,0,0
inpbff    db   255,1
          db   "?",13
          db   255 dup (0)
adrcom    dw   adrend    ; adresa zacatku ulozeneho programu
adrvek    dw   adrend    ; adresa vektoru programu
adrpar    dw   adrend    ; adresa zacatku tabulky parametru
adrtop    dw   adrend    ; adresa konce tabulky parametru
pocchb    dw   0         ; pocet chyb v parametrech
adrDTA    dw   80h       ; adresa DTA pro ukladani dat
adrfcb    dw   fcbmac    ; adresa FCB pro vystup dat
ukladr    dw   80h       ; ukladaci adresa pro vystup dat
uklcit    db   0         ; citac ukladanych dat
rdadr     dw   adrend    ; cteci adresa programu
prizn1    db   0         ; priznak prefsiu DD,FD
prizn2    db   0         ; priznak prefsiu ED,CB
prizn3    db   0         ; priznak oddxlovace
;tbtab1    db   0,7,20,27,29,37,42,54,64,70  ; tabulatory
;tbtab2    db   1,11,16,31,36,41,51,61,71,80
pozice    db   0         ; pozice
lastab    db   0         ; stary tabelator

comment %
tabul:    push cx
          mov  c,a
          mov  al,8
          call tabul0
          mov  al,c
          pop  cx
          ret

tabul0:   push cx
          mov  b,a
          mov  al,[lastab]
          add  a,b
          mov  [lastab],a
          mov  b,a
tabul1:   mov  al,[pozice]
          cmp  al,b
          jnc  tabul2
          mov  al,32
          call tskznk
          jr   tabul1
tabul2:   pop  cx
          ret          

;tabul:    push ax        ; tabulator
;          push bx
;          push cx
;tablad:   mov  bx,tbtab1
;          mov  b,10
;          mov  al,[pozice]
;tabul1:   cmp  al,[bx]
;          inc  bx
;          jc   tabul2
;          loop tabul1
;tabul3:   pop  cx
;          pop  bx
;          pop  ax
;          ret
;tabul2:   dxc  bx
;tabul4:   mov  al,32
;          call tskznk
;          mov  al,[pozice]
;          cmp  al,[bx]
;          jc   tabul4
;          jr   tabul3



longb:    mov  b,4
          mov  al,[bx]
          inc  bx
          cmp  al,0ddh
          jz   longdd
          cmp  al,0fdh
          jz   longdd
          cmp  al,0edh
          jz   longed
          cmp  al,0cbh
          jz   longcb
          dxc  bx
          dxc  b
          cmp  al,0c3h
          ret  z
          cmp  al,0cdh
          ret  z
          and  al,0cfh
          cmp  al,1
          ret  z
          mov  al,[bx]
          dxc  b
          dxc  b
          and  al,0f7h
          ret  z
          inc  b
          cmp  al,0d3h
          ret  z
          inc  b
          and  al,0e7h
          cmp  al,22h
          ret  z
          and  al,0c7h
          cmp  al,0c2h
          ret  z
          cmp  al,0c4h
          ret  z
          dxc  b
          or   al,a
          ret  z
          cmp  al,6
          ret  z
          cmp  al,0c6h
          ret  z
          dxc  b
          ret
longdd:   mov  al,[bx]
          cmp  al,0edh
          jz   longed
          cmp  al,0cbh
          jz   longce
          cmp  al,36h
          ret  z
          cmp  al,21h
          ret  z
          cmp  al,22h
          ret  z
          cmp  al,2ah
          ret  z
          dxc  b
          cmp  al,34h
          ret  z
          cmp  al,35h
          ret  z
          and  al,0f8h
          cmp  al,70h
          ret  z
          mov  al,[bx]
          and  al,0c7h
          cmp  al,46h
          ret  z
          cmp  al,86h
          ret  z
          dxc  b
          ret

longdx:   inc  b
longed:   mov  al,[bx]
          and  al,0c7h
          cmp  al,43h
          ret  z
longcb:   dxc  b
          dxc  b
          ret
longce:   inc  bx
          inc  bx
          mov  al,[bx]
          and  al,7
          cmp  al,6
          ret  z
          dxc  b
          ret

%

loaddt:                                     ; naáten° souboru s pouëit°m FCB
         mov       dx,[adrfcb]              ; poëadovanò soubor
         mov       ah,15                    ; funkce otev©en° souboru
         int       21h                      ; otev©en° souboru
         inc       al                       ; byl soubor nalezen ?
         jnz       loadd1                   ; soubor nalezen
         stc                                ; chyba otev©en° souboru - nenalezen
         ret                                ; n†vrat p©i chybà - soubor nenalezen
loadd1:  mov       dx,[adrDTA]              ; ukl†dac° adresa DTA
         mov       ah,26                    ; funkce nastaven° adresy DTA
         int       21h                      ; nastaven° adresy DTA
         mov       bx,[adrDTA]              ; ukl†dac° adresa dat
         mov       cx,80h                   ; dÇlka sektoru
         add       bx,cx                    ; BX - nov† adresa konce
         call      tstend                   ; test p©ekroáen° konce pamàti
         jnc       loadd2                   ; pokraáov†n°
         jmp       errend                   ; chybovò konec
loadd2:  push      bx                       ; p©°®t° ukl†dac° adresa DTA
         mov       dx,[adrfcb]              ; FCB poëadovanÇho souboru
         mov       ah,20                    ; funkce sekvenán°ho áten° souboru
         int       21h                      ; sekvenán° áten° jednoho sektoru
         pop       bx                       ; p©°st° ukl†dac° adresa DTA
         or        al,al                    ; bylo áten° £spà®nÇ ?
         jz        loadd3                   ; áten° bylo £spà®nÇ - dal®° sektor
         mov       dx,[adrfcb]              ; FCB poëadovanÇho souboru
         mov       ah,16                    ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru
         xor       al,al                    ; n†vratovò k¢d - operace £spà®n†
         ret
loadd3:  mov       [adrDTA],bx              ; nastaven° novÇ ukl†dac° adresy DTA
         jmp       short loadd1             ; naáten° dal®°ho sektoru souboru


tstend:                                     ; test p©ekroáen° konce pamàti
                                            ; VSTUP: BX - poëadovanò konec pamàti
         push      dx
         mov       dx,offset adrend         ; konec programu
         cmp       bx,dx                    ; je pod koncem programu (p©ekroáen° segmentu) ?
         jc        tstend1                  ; pod koncem programu - chyba
         mov       dx,ds:[6]                ; konec volnÇ pamàti
         cmp       bx,dx                    ; porovn†n° konce pamàti
         jnc       tstend1                  ; nad koncem pamàti - chyba
         pop       dx
         clc                                ; p©°znak nep©ekroáen° konce pamàti
         ret
tstend1: push      ax
         mov       dx,offset txter5         ; chybovÇ hl†®en°
         mov       ah,9                     ; funkce tisku textu DOS
         int       21h                      ; tisk chybovÇho hl†®en°
         pop       ax
         pop       dx
         stc                                ; p©°znak chyby pamàti
         ret
comment %


disas:    mov  bx,tab0
          push si
          pop  di
          xor  al,a
          mov  [prizn1],a
          mov  [prizn2],a
          mov  al,[si+0]
          cmp  al,0c3h
          jz   disas0
          cmp  al,0c9h
          jz   disas0
          cmp  al,18h
          jz   disas0
          cmp  al,0e9h
          jnz  disas1
disas0:   mov  [prizn3],a
disas1:   cmp  al,0ddh
          jz   disas2
          cmp  al,0fdh
          jnz  disas3
disas2:   mov  [prizn1],a
          inc  si
          mov  al,[si+0]
          cmp  al,0e9h
          jnz  disas3
          mov  [prizn3],a
disas3:   cmp  al,0edh
          jnz  disas4
          mov  bx,tabed
          mov  [prizn2],a
          mov  al,[si+1]
          cmp  al,45h
          jz   disash
          cmp  al,4dh
          jnz  disas5
disash:   mov  [prizn3],a
          jr   disas5
disas4:   cmp  al,0cbh
          jnz  disas6
          mov  bx,tacxb
          mov  [prizn2],a
          mov  al,[prizn1]
          or   al,a
          jz   disas5
          inc  si
disas5:   inc  si
disas6:   mov  b,[bx]         ; nastaveni poctu bloku
          inc  bx
disas7:   push cx
          mov  b,[bx]         ; nastaveni poctu slov
          inc  bx
          mov  al,[si+0]
          and  al,[bx]           ; maskovani
          inc  bx
disas8:   cmp  al,[bx]
          inc  bx
          jz   disasc       ; nalezeno
disas9:   bit  7,[bx]
          inc  bx
          jz   disas9       ; konec slova
          loop disas8         ; dalsi slovo
          pop  cx
          loop disas7         ; dalsi blok
          mov  dx,txtdb
          call tsktxt
          ret  c
          mov  al,";"
          call tskznk
          ret  c
          mov  al,"?"
          call tskznk
          ret  c
          call tskznk
          ret
disasc:   pop  cx
          call tskkod
          ret

tskkod:   mov  al,[bx]
          and  al,7fh
          cmp  al,33
          jnc  tskkd2
          push bx
          mov  bx,tbskok
          add  a,a
          add  a,l
          mov  l,a
          jnc  tskkd1
          inc  h
tskkd1:   mov  al,[bx]
          inc  bx
          mov  h,[bx]
          mov  l,a
          call jpbx
          pop  bx
          jr   tskkd5
tskkd2:   call tskznk
          ret  c
tskkd5:   mov  al,[bx]
          inc  bx
          and  al,128
          jz   tskkod
          xor  al, a
tskkdx:   ret

jpbx:     jmp  [bx]

txtbx     db   "h","l"+128
txtdd     db   "i","x"+128
txtfd     db   "i","y"+128
txtbx1    db   "[bx","]"+128
txtdd1    db   "[si",8,"]"+128
txtfd1    db   "[di",8,"]"+128
txtbx2    db   "[bx","]"+128
txtdd2    db   "[si",9,"]"+128
txtfd2    db   "[di",9,"]"+128

tbskb     db   8,7
          db   0,"b"+128
          db   1,"c"+128
          db   2,"d"+128
          db   3,"e"+128
          db   4,"h"+128
          db   5,"l"+128
          db   6,93h
          db   7,"a"+128
tbskc     db   8,38h
          db   0,"b"+128
          db   8,"c"+128
          db   10h,"d"+128
          db   18h,"e"+128
          db   20h,"h"+128
          db   28h,"l"+128
          db   30h,93h
          db   38h,"a"+128
tbskd     db   4,30h
          db   0,"b","c"+128
          db   10h,"d","e"+128
          db   20h,92h
          db   30h,"s","p"+128
tbske     db   4,30h
          db   0,"b","c"+128
          db   10h,"d","e"+128
          db   20h,92h
          db   30h,"a","f"+128
tbskf     db   8,38h
          db   0,"n","z"+128
          db   8,"z"+128
          db   10h,"n","c"+128
          db   18h,"c"+128
          db   20h,"p","o"+128
          db   28h,"p","e"+128
          db   30h,"p"+128
          db   38h,"m"+128
tbskb1    db   8,38h
          db   0,"add a",","+128
          db   8,"adc a",","+128
          db   10h,"sub",0a0h
          db   18h,"scx a",","+128
          db   20h,"and",0a0h
          db   28h,"xor",0a0h
          db   30h,"or",0a0h
          db   38h,"cp",0a0h
tbskb6    db   4,18h
          db   0,"i"+128
          db   8,"d"+128
          db   10h,"i","r"+128
          db   18h,"d","r"+128

tbskb7:   db   "inc",0a0h
tbskb8:   db   "dxc",0a0h


skokb7:   mov  bx,tbskb7
          jmp  tskkod
skokb8:   mov  bx,tbskb8
          jmp  tskkod


skokb0:   mov  al,[si+0]
          and  al,38h
skokc0:   mov  l,a
          mov  h,0
          jmp  tskcis

skokb5:   mov  al,[si+0]
          and  al,38h
          rrca
          rrca
          rrca
          jr   skokc0


skokb2:   mov  al,[prizn1]
          or   al,a
          mov  bx,txtbx
          jp   z,tskkod
          cmp  al,0ddh
          mov  bx,txtdd
          jp   z,tskkod
          cmp  al,0fdh
          mov  bx,txtfd
          jp   z,tskkod
          or   al,a
          ret



skokb3:   mov  al,[prizn1]
          or   al,a
          mov  bx,txtbx1
          jp   z,tskkod
          cmp  al,0ddh
          mov  bx,txtdd1
          jp   z,tskkod
          cmp  al,0fdh
          mov  bx,txtfd1
          jp   z,tskkod
          or   al,a
          ret

skokb4:   mov  al,[prizn1]
          or   al,a
          mov  bx,txtbx2
          jp   z,tskkod
          cmp  al,0ddh
          mov  bx,txtdd2
          jp   z,tskkod
          cmp  al,0fdh
          mov  bx,txtfd2
          jp   z,tskkod
          or   al,a
          ret
          jp   z,tskkod
          cmp  al,0fdh
          mov  bx,txtfd2
          jp   z,tskkod
          or   al,a
          ret

     

skokb:    mov  bx,tbskb
          jr   tskreg
skokc:    mov  bx,tbskc
          jr   tskreg
skokd:    mov  bx,tbskd
          jr   tskreg
skoke:    mov  bx,tbske
          jr   tskreg
skokf:    mov  bx,tbskf
          jr   tskreg
skokb1:   mov  bx,tbskb1
          jr   tskreg
skokb6:   mov  bx,tbskb6

tskreg:   mov  b,[bx]         ; nastaveni poctu slov
          inc  bx
          mov  al,[si+0]
          and  al,[bx]           ; maskovani
          inc  bx
tskr01:   cmp  al,[bx]
          inc  bx
          jp   z,tskkod       ; nalezeno
tskr02:   bit  7,[bx]
          inc  bx
          jz   tskr02       ; konec slova
          loop tskr01         ; dalsi slovo
          clc
          ret

tbskok:   dw   tskkdx    ; 0
          dw   skok1     ; 1  adresa programu LBL...
          dw   skok2     ; 2  adresa tabulky DTB...
          dw   skok3     ; 3  adresa bytu DDB...
          dw   skok4     ; 4  adresa slova DDW...
          dw   skok5     ; 5  relativni adresa LBL...
          dw   skok6     ; 6  data1 [OR d]
          dw   skok7     ; 7  data 2 [LD [HL],d]
          dw   skok8     ; 8  indxx 1 [LD A,[IX+d]]
          dw   skok9     ; 9  indxx 2 [RES 4,[IX+d]]
          dw   skoka     ; a  port
          dw   skokb     ; b  registr 1
          dw   skokc     ; c  registr 2
          dw   skokd     ; d  dvojregistr 1
          dw   skoke     ; e  dvojregistr 2
          dw   skokf     ; f  podminka
          dw   skokb0    ; 10 adresa RST
          dw   skokb1    ; 11 aritmet. operace
          dw   skokb2    ; 12 registr HL
          dw   skokb3    ; 13 registr [HL]
          dw   skokb4    ; 14 registr RES [IX+e]
          dw   skokb5    ; 15 cislo bitu
          dw   skokb6    ; 16 parametr LDIR
          dw   skokb7    ; 17 INC 
          dw   skokb8    ; 18 DEC 
          dw   tskkdx    ; 19
          dw   tskkdx    ; 1a
          dw   tskkdx    ; 1b
          dw   tskkdx    ; 1c
          dw   tskkdx    ; 1d
          dw   tskkdx    ; 1e
          dw   tskkdx    ; 1f
          dw   tabul     ; 20 tabulator

          


skoka:    mov  l,[si+1]
          mov  h,0
          jmp  tskcis
skok9:    mov  l,[si-1]
          jr   skok83
skok8:    mov  l,[si+1]
skok83:   mov  h,0
          bit  7,l
          mov  al,"+"
          jnz  skok81
skok82:   call tskznk
          ret  c
          jmp  tskcis
skok81:   mov  al,l
          neg
          mov  l,a
          mov  al,"-"
          jr   skok82
 
skok7:    mov  l,[si+1]
          mov  h,0
          mov  al,[prizn1]
          or   al,a
          jz   tskcia
          mov  al,[si+0]
          cmp  al,36h
          jnz  tskcia
          mov  l,[si+2]
          jr   tskcia
       
skok6:    mov  l,[si+1]
          mov  h,0
tskcia:   mov  al,h
          or   al,a
          jp   nz,tskcis
          mov  al,l
          push bx
          push si
          pop  bx
          inc  bx
          call testas+1
          pop  bx
          jp   c,tskcis
          mov  al,34
          call tskznk
          mov  al,l
          call tskznk
          mov  al,34
          jmp  tskznk


skok5:    push si
          pop  bx
          inc  bx
          inc  bx
          mov  dx,[adrcom]
          or   al,a
          scx  bx,dx
          mov  dx,[base]
          add  bx,dx
          mov  e,[si+1]
          mov  d,0
          add  bx,dx
          bit  7,e
          jz   tsklb
          dxc  h
          jr   tsklb

skok4:
skok3:
skok2:
skok1:    mov  l,[si+1]
          mov  h,[si+2]
tsklb:    push bx
          mov  al,1eh
          mov  [labpri],a
          call txtask
          pop  bx
          jc   tsklb1
          mov  [pozn2],bx
tsklb1:   ;mov  al,[vsss0]
          ;or   al,a
          ;jp   nz,tskwrd
          call labask
          jp   nc,tsktxt
tskcis:   mov  al,h
          and  al,0f0h
          jz   tskcs2
          cmp  al,0a0h
          jc   tskcs1
          xor  al,a
          call tskhex
          ret  c
tskcs1:   call tskwrd
tskcs0:   ret  c
          mov  al,"h"
          jmp  tskznk
tskcs2:   mov  al,h
          and  al,0fh
          jz   tskcs4
          cmp  al,0ah
          jc   tskcs3
          xor  al,a
          call tskhex
          ret  c
tskcs3:   mov  al,h
          and  al,0fh
tskcs7:   call tskhex
          ret  c
tskcs8:   mov  al,l
          call tskbyt
          jr   tskcs0
tskcs4:   mov  al,l
          and  al,0f0h
          jz   tskcs5
          cmp  al,0a0h
          jc   tskcs8
          xor  al,a
          jr   tskcs7
tskcs5:   mov  al,l
          and  al,0fh
          cmp  al,0ah
          jc   tskcs6
          xor  al,a
          call tskhex
          ret  c
tskcs6:   mov  al,l
          and  al,0fh
          call tskhex
          ret  c
          cmp  al,10
          ccf
          ret  nc
          mov  al,"h"
          jmp  tskznk

txtdb     db   "d","b"+128



tab0      db   4                        ; pocet bloku
          db   37,0ffh
          db   0,"nop",160           ; NOP
          db   10h,"loop ",85h          ; DJNZ
          db   20h,"jr nz,",85h         ; JR NZ,e
          db   30h,"jr nc,",85h         ; JR NC,e
          db   2,"ld [cx],","a"+128     ; LD [BC],A
          db   12h,"ld [dx],","a"+128   ; LD [DE],A
          db   22h,"ld [",4,"],",92h    ; LD [a],HL
          db   32h,"ld [",3,"],","a"+128; LD [a],A
          db   7,"rlca",160          ; RLCA
          db   17h,"rla",160         ; RLA
          db   27h,"daa",160         ; DAA
          db   37h,"clc",160         ; SCF
          db   8,"ex ax,ax","'"+128     ; EX AF,AF'
          db   18h,"jr ",85h            ; JR e
          db   28h,"jr z,",85h          ; JR Z,e
          db   38h,"jr c,",85h          ; JR C,e
          db   10,"ld a,[cx","]"+128    ; LD A,[BC]
          db   1ah,"ld a,[dx","]"+128   ; LD A,[DE]
          db   2ah,"ld ",12h,",[",4,"]"+128  ; LD HL,[a]
          db   3ah,"ld a,[",3,"]"+128   ; LD A,[a]
          db   0fh,"rrca",160        ; RRCA
          db   1fh,"rra",160         ; RRA
          db   2fh,"cpl",160         ; CPL
          db   3fh,"ccf",160         ; CCF
          db   76h,"halt",160        ; HALT
          db   0c3h,"jmp",81h           ; JP a
          db   0d3h,"out [",10,"],","a"+128  ; OUT [d],A
          db   0e3h,"ex [sp],",92h      ; EX [SP],HL
          db   0f3h,"di",160         ; DI
          db   0c9h,"ret",160        ; RET
          db   0d9h,"exx",160        ; EXX
          db   0e9h,"jmp[",12h,"]"+128  ; JP [HL]
          db   0f9h,"ld sp,",92h        ; LD SP,HL
          db   0dbh,"in a,[",10,"]"+128 ; IN A,[d]
          db   0ebh,"ex dx,",92h         ; EX DE,HL
          db   0fbh,"ei",160         ; EI
          db   0cdh,"call ",81h         ; CALL a

          db   2,0c0h
          db   40h,"ld ",12,",",8bh     ; LD r2,r1
          db   80h,11h,8bh              ; arop r1

          db   6,0cfh
          db   1,"ld ",13,",",82h       ; LD drg1,a
          db   3,17h,8dh                ; INC drg1
          db   9,"add ",12h,",",8dh     ; ADD HL,drg1
          db   0bh,18h,8dh              ; DEC drg1
          db   0c1h,"pop ",8eh          ; POP drg2
          db   0c5h,"push ",8eh         ; PUSH drg2
          
          db   8,0c7h
          db   4,17h,8ch                ; INC rg2 
          db   5,18h,8ch                ; DEC rg2
          db   6,"ld ",12,",",87h       ; LD rg2,d
          db   0c0h,"ret ",8fh          ; RET podm
          db   0c2h,"jmp",15,",",81h    ; JP podm,a
          db   0c4h,"call ",15,",",81h  ; CALL podm,a
          db   0c6h,11h,86h             ; arop d
          db   0c7h,"rst ",90h          ; RST adr


tabed     db   4
          db   12,0ffh
          db   44h,"neg",160
          db   45h,"retn",160
          db   46h,"im ","0"+128
          db   56h,"im ","1"+128
          db   47h,"ld i,","a"+128
          db   57h,"ld a,","i"+128
          db   67h,"rrd",160
          db   4dh,"reti",160
          db   5eh,"im ","2"+128
          db   4fh,"ld r,","a"+128
          db   5fh,"ld a,","r"+128
          db   6fh,"rld",160
          
          db   2,0c7h
          db   40h,"in ",12,",[c","]"+128
          db   41h,"out [c],",8ch

          db   4,0cfh
          db   42h,"scx bx,",8dh
          db   4ah,"adc bx,",8dh
          db   43h,"ld [",4,"],",8dh
          db   4bh,"ld ",0dh,",[",4,"]"+128

          db   4,0e7h
          db   0a0h,"ld",16h,160
          db   0a1h,"cp",16h,160
          db   0a2h,"in",16h,160
          db   0a3h,"ot",16h,160

tacxb     db   4
          db   8,0ffh
          db   6,"rlc ",94h
          db   0eh,"rrc ",94h
          db   16h,"rl ",94h
          db   1eh,"rcr",94h
          db   26h,"sla ",94h
          db   2eh,"sra ",94h
          db   36h,"sli ",94h
          db   3eh,"shr ",94h

          db   3,0c7h
          db   46h,"bit ",15h,",",94h
          db   86h,"res ",15h,",",94h
          db   0c6h,"set ",15h,",",94h

          db   8,0f8h
          db   0,"rlc ",8bh
          db   8,"rrc ",8bh
          db   10h,"rl ",8bh
          db   18h,"rcr",8bh
          db   20h,"sla ",8bh
          db   28h,"sra ",8bh
          db   30h,"sli ",8bh
          db   38h,"shr ",8bh

          db   3,0c0h
          db   40h,"bit ",15h,",",8bh
          db   80h,"res ",15h,",",8bh
          db   0c0h,"set ",15h,",",8bh

%
tskspc:  push      ax                       ; tisk mezery
         mov       al,32                    
         call      tskznk                   
tsksp1:  jc        tskspe                   
         pop       ax                       
         or        al,al
         ret                                
tskspe:  pop       ax                       
         stc
         ret                                

;tsktxt:  push      bx
;         push      dx
;         push      cx
;tsktx1:  mov       al,[bx]
;         cmp       al,"$"
;         jz        tsktx3
;         bit       7,a
;         jz        tsktx4
;         and       al,07fh
;         call      tskznk
;         jr        tsktx2
;tsktx4:  call      tskznk
;         jc        tsktx2
;         inc       bx
;         jr        tsktx1
;tsktx3:  xor       al,a
;tsktx2:  pop       cx
;         pop       dx
;         pop       bx
;         ret

tskcr:    push     ax                       ; tisk novÇho ©†dku
          mov      al,13
          call     tskznk
          jc       tskspe
          mov      al,10
          call     tskznk
          jmp      short tsksp1

tskwrh:   call     tskwrd
          jc       tskwrh1
          mov      al,"H"
          call     tskznk
tskwrh1:  ret

tskbth:   call     tskbyt
          jc       tskwrh1
          mov      al,"H"
          call     tskznk
          ret


tskwrd:  push      ax                       ; tisk slova HEX v BX
         mov       al,bh
         call      tskbyt                   ; tisk bajtu v AL
         jc        tskhx2                   ; chyba
         mov       al,bl
         call      tskbyt                   ; tisk bajtu v AL
         jc        tskhx2                   ; chyba
         pop       ax                       
         or        al,al                    ; zru®en° p©°znaku C
         ret                                

tskbyt:  push      ax                       ; tisk bajtu HEX v AL
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1
         call      tskhex                   ; tisk znaku v AL v HEX form†tu
         jc        tskhx2                   ; chyba
         pop       ax                       

tskhex:  push      ax                       ; tisk znaku HEX
         and       al,0fh
         add       al,"0"
         cmp       al,":"                   
         jc        tskhx1                   
         add       al,27h
tskhx1:  call      tskznk                   
         jc        tskhx2                   
         pop       ax                       
         or        al,al
         ret                                
tskhx2:  pop       ax                       
         clc
         ret                                

tskznk:
         push      ax
         push      dx
         mov       dl,al                    ; znak k vòstupu
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

comment %

tskznk:   push bx
          push cx
          push dx
          push si
          push di
tskzn0    db   1         ; instrukce LD BC,data [pro vetveni programu]
          jr   tskzn1
          push ax
          cmp  al,9
          jnz  tskzes
tskza5:   mov  al,32
          call tskznk
          mov  al,[pozice]
          and  al,7
          jnz  tskza5
          pop  ax
          jr   tskza2
tskzes:   mov  ah,6
          mov  e,a
          int  21h         ; tisk znaku na konzole
          pop  ax
          call pozznk
tskza2:   or   al,a
          jr   tskzne
tskzn1:   push ax
          mov  al,[uklcit]
          cmp  al,128
          jc   tskzn3
          mov  dx,[adrfcb]
          mov  ah,21
          int  21h         ; zapis sektoru
          or   al,a
          jz   tskzn2
          mov  dx,txter4
          mov  ah,9
          int  21h         ; bxaseni DISK PLNY
          jmp  vstup
tskzn2:   mov  bx,80h
          mov  [ukladr],bx
          xor  al,a
          mov  [uklcit],a
          mov  dx,81h
          mov  cx,7fh
          mov  [bx],a
          ldir           ; vymazani sektoru
tskzn3:   inc  a
          mov  [uklcit],a
          pop  ax
          mov  bx,[ukladr]
          mov  [bx],a
          inc  bx
          mov  [ukladr],bx
          call pozznk
          or   al,a
tskzne:   pop  di
          pop  si
          pop  dx
          pop  cx
          pop  bx
          ret

pozznk:   push ax
          cmp  al,8
          jnz  pozzn1
pozzn0:   mov  al,[pozice]
          or   al,a
          jz   pozzne
          dxc  a
          mov  [pozice],a
          jr   pozzne
pozzn1:   cmp  al,9
          jnz  pozzn2
          mov  al,[pozice]
          and  al,0f8h
          add  a,8
          jr   pozzn6
pozzn2:   cmp  al,12
          jz   pozzn4
          cmp  al,13
          jz   pozzn4
          cmp  al,24
          jz   pozzn4
          cmp  al,07fh
          jz   pozzn0
          mov  al,[pozice]
          inc  a
pozzn6:   cmp  al,pocpoz
          jc   pozzn5
pozzn4:   xor  al,a
          mov  [lastab],a
pozzn5:   mov  [pozice],a
pozzne:   pop  ax
          ret



rdjmen:   call outsp          ; podprogram pro cteni jmena souboru
          call rdznk
          ret  c
          mov  b,al           ; ulozeni prvniho znaku
          call rdznk
          dxc  dx
          inc  c
          inc  bx
;          jc   rdjmn0
          cmp  al,":"
          mov  al,b
          jnz  rdjmn1
          dxc  dx
          inc  c
          cmp  al,"A"
          ret  c
          cmp  al,"E"
          ccf
          ret  c
          inc  dx
          dxc  c
          inc  dx
          dxc  c
          dxc  bx
          sub  al,"@"
          mov  [bx],a
          inc  bx
          call outsp
rdjmn0:   call rdznk
          ret  c
rdjmn1:   dxc  dx
          inc  c
          cmp  al,","
          clc
          ret  z
          inc  dx
          dxc  c
          mov  b,7
          mov  [bx],a
          inc  bx
rdjmn2:   call rdznk
          ccf
          ret  nc
          dxc  dx
          inc  c
          cmp  al,","
          ret  z
          cmp  al," "
          ret  z
          inc  dx
          dxc  c
          cmp  al,"."
          jz   rdjmn3
          mov  [bx],a
          inc  bx
          loop rdjmn2
          jr   rdjmn4
rdjmn3:   inc  bx
          loop rdjmn3
rdjmn4:   mov  b,3
rdjmn5:   call rdznk
          jc   rdjmn6
          dxc  dx
          inc  c
          cmp  al,","
          jz   rdjmn6
          cmp  al," "
          jz   rdjmn6
          inc  dx
          dxc  c
          mov  [bx],a
          inc  bx
          loop rdjmn5
          or   al,a
          ret
rdjmn6:   mov  [bx],32
          inc  bx
          loop rdjmn6
          or   al,a
          ret

rdword:   mov  b,0
          mov  bx,0
          call rdhex
          ret  c
rdwrd1:   mov  l,a
          inc  b
          call rdhex
          ccf   
          ret  nc
          add  bx,bx
          add  bx,bx
          add  bx,bx
          add  bx,bx
          or   al,l
          jr   rdwrd1

rdhex:    call rdznk
          ret  c
          inc  c
          dxc  dx
          cmp  al,"0"
          ret  c
          cmp  al,"G"
          ccf
          ret  c
          cmp  al,":"
          jc   rdhex1
          cmp  al,"A"
          ret  c
rdhex1:   inc  dx
          dxc  c
          sub  al,"0"
          cmp  al,10
          jc   rdhex2
          sub  al,7
rdhex2:   or   al,a
          ret


rdznk:    mov  al,c       ; precteni znaku z textoveho bufferu
          or   al,a
          clc
          ret  z
          mov  al,[dx]
          inc  dx
          dxc  c
          cmp  al,61h
          jc   rdznk1
          cmp  al,7ah
          jnc  rdznk1
          sub  al,20h
rdznk1:   or   al,a
          ret

outsp:    call rdznk     ; vypousteni mezer z bufferu
          ret  c
          cmp  al," "
          jz   outsp
          dxc  dx
          inc  c
          or   al,a
          ret
%

txtuv     db   13,10,10," ***** GENMAC  V1.0  TESLA Roënov ***** ",13,10
          db   "Gener†tor zdrojovÇho textu pro procesor Z-80",13,10,10,"$"
txter1    db   13,10,"Zadejte:    GENMAC <jmÇno souboru>",13,10
          db   "(v aktu†ln°m adres†©i, p©°pona automaticky COM !)",13,10,10,"$"
txter2    db   13,10,"Zdrojovò soubor (.COM) nenalezen !",13,10,"$"
txter3    db   13,10,"Soubor parametrñ (.PAR) je chybnò !",13,10,"$"
txter4    db   13,10,"Disk je plnò !",13,10,"$"
txter5    db   13,10,"Lituji, nen° dostatek volnÇ pamàti !",13,10,"$",128
txter6    db   13,10,"error data",13,10,"$"

fcbcom    db   0              ; cislo stanice
          db   "        "     ; jmeno zdrojoveho programu
          db   "COM"          ; typ souboru
          db   0              ; cast souboru EX
          db   0,0
          db   0              ; pocet zaznamu souboru
          db   0,0,0,0,0,0,0,0; cisla bloku
          db   0,0,0,0,0,0,0,0
          db   0              ; cislo zaznamu NR
          db   0,0,0          ; absolutni cislo zaznamu
          
fcbpar    db   0              ; cislo stanice
          db   "        "     ; jmeno souboru parametru
          db   "PAR"          ; typ souboru
          db   0              ; cast souboru EX
          db   0,0
          db   0              ; pocet zaznamu souboru
          db   0,0,0,0,0,0,0,0; cisla bloku
          db   0,0,0,0,0,0,0,0
          db   0              ; cislo zaznamu NR
          db   0,0,0          ; absolutni cislo zaznamu

fcbmac    db   0              ; cislo stanice
          db   "        "     ; jmeno textoveho souboru
          db   "MAC"          ; typ souboru
          db   0              ; cast souboru EX
          db   0,0
          db   0              ; pocet zaznamu souboru
          db   0,0,0,0,0,0,0,0; cisla bloku
          db   0,0,0,0,0,0,0,0
          db   0              ; cislo zaznamu NR
          db   0,0,0          ; absolutni cislo zaznamu



;         mov       ah,4ch                   ; ukonáen° programu
;         int       21h

         db        256 dup(0)
stack:   db        10

base      dw   100h      ; b†zov† adresa programu

adrend:

code     ENDS

;------------------------------------------------------------------------------
;                             Datovò segment
;------------------------------------------------------------------------------

data     SEGMENT

data     ENDS


         END       start               ; startovac° adresa

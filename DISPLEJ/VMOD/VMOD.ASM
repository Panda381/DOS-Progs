
; *****************************************************************************
;
;                            Videom¢d displeje
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h
vmode:
                                          ;* dek¢dov†n° á°sla videom¢du
         mov       si,81h                   ; zaá†tek p©°kaz. ©†dku
         xor       bx,bx
         mov       bl,ds:[si-1]             ; poáet zadanòch znakñ
         mov       byte ptr ds:[si+bx],0    ; konec zadanÇho parametru
vmode1:  call      inpchar                  ; vstup znaku z p©°kaz. ©†dku
         jc        zobraz                   ; je konec ©†dku - nic nezad†no
         cmp       al," "
         jbe       vmode1                   ; vypu®tàn° oddàlovac°ch znakñ
         mov       dx,offset texthlp        ; text n†povàdy
         cmp       al,"?"                   ; je poëadavek n†povàdy ?
         je        navrat2                  ; zobrazen° n†povàdy
         dec       si                       ; n†vrat prvn°ho znaku
                                          ;* vstup á°sla novÇho videom¢du
         xor       bh,bh                    ; naá°tanÇ á°slo
inpnum1: call      inpchar                  ; test p©ipravenÇho znaku
         jc        inpnum2                  ; je konec ©†dku
         cmp       al,"9"
         ja        inpnum2                  ; nen° á°slice
         sub       al,"0"
         jb        inpnum2                  ; nen° á°slice
         xchg      al,bh
         mov       ah,10
         mul       ah
         add       bh,al
         jmp       short inpnum1            ; dal®° znak
inpnum2:                                  ;* nastaven° novÇho videom¢du
         mov       al,bh                    ; naátenò parametr
         xor       ah,ah
         int       10h                      ; inicializace videom¢du
         jmp       short navrat
zobraz:                                   ;* zobrazen° á°sla videom¢du
         mov       dx,offset text
         mov       ah,9
         int       21h                      ; text "Aktivn° videom¢d:"
         mov       ah,0fh
         int       10h                      ; poskytnut° aktivn°ho videom¢du
         and       al,7fh                   ; zru®en° bitu 7
zobraz2: mov       bl,100
         call      zobrazn                  ; zobrazen° stovek á°sla
         mov       bl,10
         call      zobrazn                  ; zobrazen° des°tek á°sla
         add       al,"0"
         mov       dl,al
         mov       ah,2
         int       21h                      ; zobrazen° jednotek á°sla m¢du
         mov       dx,offset text2          ; zobrazen° zbytku textu

navrat2: mov       ah,9
         int       21h
navrat:  mov       ah,0fh
         int       10h
         and       al,7fh                   ; zru®en° bitu 7
         mov       ah,4ch                   ; ukonáen° programu
         int       21h

; -----------------------------------------------------------------------------
zobrazn:                                  ;* zobrazen° jednÇ á°slice á°sla
         xor       ah,ah
zobrazn1:inc       ah
         sub       al,bl
         jnc       zobrazn1
         add       al,bl
         dec       ah
         jz        zobrazn2
         push      ax
         mov       dl,ah
         add       dl,"0"
         mov       ah,2
         int       21h
         pop       ax
zobrazn2:ret
; -----------------------------------------------------------------------------
inpchar:                                  ;* vstup znaku
                                            ; VùSTUP: AL=znak
                                            ;         CY=nen° dal®° znak

         mov       al,ds:[si]
         or        al,al
         stc
         jz        inpchar2                 ; konec textu
         inc       si
         or        al,al
inpchar2:ret
; -----------------------------------------------------------------------------
;                                  Data
; -----------------------------------------------------------------------------
text     db        'Aktivni videomod = $'
text2    db        '; (?=informace)',13,10,'$'

texthlp  db        '    VMOD V1.10 - videomod displeje    ',13,10
         db        '⁄ƒƒƒ¬ƒƒƒ(c) Miroslav Nemecekƒƒƒƒƒƒƒƒƒø',13,10
         db        '≥mod≥typ ≥rozlis.≥ barev ≥graf. karta≥',13,10
         db        '√ƒƒƒ≈ƒƒƒƒ≈ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¥',13,10
         db        '≥ 0 ≥Text≥ 40x25 ≥16 sede≥    CGA    ≥',13,10
         db        '≥ 1 ≥Text≥ 40x25 ≥  16   ≥CGA,EGA,VGA≥',13,10
         db        '≥ 2 ≥Text≥ 80x25 ≥16 sede≥    CGA    ≥',13,10
         db        '≥ 3 ≥Text≥ 80x25 ≥  16   ≥CGA,EGA,VGA≥',13,10
         db        '≥ 4 ≥Graf≥320x200≥   4   ≥CGA,EGA,VGA≥',13,10
         db        '≥ 5 ≥Graf≥320x200≥ 4 sede≥    CGA    ≥',13,10
         db        '≥ 6 ≥Graf≥640x200≥   2   ≥CGA,EGA,VGA≥',13,10
         db        '≥ 7 ≥Text≥ 80x25 ≥ mono. ≥MDA,EGA,VGA≥',13,10
         db        '≥ 8 ≥Graf≥160x200≥  16   ≥    PCjr   ≥',13,10
         db        '≥ 9 ≥Graf≥320x200≥  16   ≥    PCjr   ≥',13,10
         db        '≥10 ≥Graf≥640x200≥   4   ≥    PCjr   ≥',13,10
         db        '≥13 ≥Graf≥320x200≥  16   ≥  EGA,VGA  ≥',13,10
         db        '≥14 ≥Graf≥640x200≥  16   ≥  EGA,VGA  ≥',13,10
         db        '≥15 ≥Graf≥640x350≥ mono. ≥  EGA,VGA  ≥',13,10
         db        '≥16 ≥Graf≥640x350≥  16   ≥  EGA,VGA  ≥',13,10
         db        '≥17 ≥Graf≥640x480≥   2   ≥    VGA    ≥',13,10
         db        '≥18 ≥Graf≥640x480≥  16   ≥    VGA    ≥',13,10
         db        '≥19 ≥Graf≥320x200≥  256  ≥    VGA    ≥',13,10
         db        '¿ƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒŸ',13,10
         db        '$'

code     ENDS
         END       vmode                    ; startovac° adresa

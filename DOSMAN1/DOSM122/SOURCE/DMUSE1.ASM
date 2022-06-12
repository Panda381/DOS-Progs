
; modul DMUSE1.ASM 

; *****************************************************************************
;
;                    
;
; *****************************************************************************

extrn    editnum:word,editseg:byte
extrn    editmax:word,topseged:word,segend:word,topseg:word,seznseg:word
extrn    seznseg0:byte,bufwin:byte,parnum:byte,citdek:byte,citnum:byte
extrn    outtxt:near,upperkam:byte,upperlat:byte,prevcs:byte,config:byte
extrn    textvy11:byte,textvy12:byte

code     segment   public
         assume    cs:code,ds:code

; -----------------------------------------------------------------------------
;                              konverze znakñ
; -----------------------------------------------------------------------------
public   konvfnt
konvfnt:                                  ;* konverze fontu znakñ
                                            ; VSTUP/VùSTUP: AL=znak

         pushf
         push      bx
         push      ds
         push      cs
         pop       ds
         test      byte ptr ds:[config],3
         jz        konvfnt2                 ; nen° p©evod fontu
         cmp       al,128                   ; nejmen®° znak
         jb        konvfnt2                 ; je men®°
         cmp       al,171                   ; nejvàt®° znak
         ja        konvfnt2                 ; je vàt®°
         sub       al,128                   ; offset v tabulce
         add       al,al
         lea       bx,[prevcs]              ; tabulka pro p©evod
         test      byte ptr ds:[config],1   ; je vypnut° áe®tiny ?
         jnz       konvfnt1                 ; je vypnut° áe®tiny
         inc       bx                       ; je LATIN 2
konvfnt1:xlat                               ; p©evod znaku
konvfnt2:pop       ds
         pop       bx
         popf
         ret

; -----------------------------------------------------------------------------
public   lowcase0
lowcase0:                                 ; VSTUP: AL=znak k p©evodu

         cmp       al,"A"                   ; je znak men®° neë "A" ?
         jb        lowcas8                  ; nen° velkÇ p°smeno
         cmp       al,"Z"                   ; je znak vàt®° neë "Z" ?
         ja        lowcas8                  ; nen° velkÇ p°smeno
         add       al,32                    ; korekce na malÇ p°smeno
lowcas8: ret


public   lowcase
lowcase:                                  ;* p©evod znaku na malÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"A"                   ; je znak men®° neë "A" ?
         jb        lowca5                   ; nen° velkÇ p°smeno
         cmp       al,"Z"                   ; je znak vàt®° neë "Z" ?
         ja        lowca1                   ; nen° velkÇ p°smeno
         add       al,32                    ; korekce na malÇ p°smeno
         ret

lowca1:  or        al,al
         jns       lowca5
         test      byte ptr cs:[config],1   ; je vypnut° áe®tiny ?
         jnz       lowca4                   ; je vypnut° áe®tiny
         push      bx
         lea       bx,[upperlat-2]          ; p©evodn° tabulka LATIN 2
         test      byte ptr cs:[config],2   ; je LATIN 2 ?
         jnz       lowca2                   ; je k¢d LATIN 2
         lea       bx,[upperkam-2]          ; p©evodn° tabulka KAMENICKùCH
lowca2:  add       bx,2                     ; zvò®en° adresy v tabulce
         cmp       byte ptr cs:[bx],0       ; je konec tabulky ?
         je        lowca3                   ; je konec tabulky
         cmp       cs:[bx+1],al             ; je hledanò znak ?
         jne       lowca2                   ; test dal®°ho znaku
         mov       al,cs:[bx]               ; p©evedenò znak
lowca3:  pop       bx
lowca4:  or        al,al
lowca5:  ret

; -----------------------------------------------------------------------------
public   highcase0
highcase0:                                ;* korekce AL na velkÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"a"                   ; je znak men®° neë "a" ?
         jb        highcas8                 ; nen° malÇ p°smeno
         cmp       al,"z"                   ; je znak vàt®° neë "z" ?
         ja        highcas8                 ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
highcas8:ret


public   highcase
highcase:                                 ;* korekce AL na velkÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"a"                   ; je znak men®° neë "a" ?
         jb        highc5                   ; nen° malÇ p°smeno
         cmp       al,"z"                   ; je znak vàt®° neë "z" ?
         ja        highc1                   ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
         ret

highc1:  test      byte ptr cs:[config],1   ; je vypnut° áe®tiny ?
         jnz       highc4                   ; je vypnut° áe®tiny
         push      bx
         lea       bx,[upperlat-2]          ; p©evodn° tabulka LATIN 2
         test      byte ptr cs:[config],2   ; je LATIN 2 ?
         jnz       highc2                   ; je k¢d LATIN 2
         lea       bx,[upperkam-2]          ; p©evodn° tabulka KAMENICKùCH
highc2:  add       bx,2                     ; zvò®en° adresy v tabulce
         cmp       byte ptr cs:[bx],0       ; je konec tabulky ?
         je        highc3                   ; je konec tabulky
         cmp       cs:[bx],al               ; je hledanò znak ?
         jne       highc2                   ; test dal®°ho znaku
         mov       al,cs:[bx+1]             ; p©evedenò znak
highc3:  pop       bx
highc4:  or        al,al
highc5:  ret

; -----------------------------------------------------------------------------
public   transtxt
transtxt:                                   ; p©enos textu ASCIIZ
                                            ; VSTUP: DS:SI -> ES:DI
                                            ; VùSTUP: ES:DI - koncov† 0

         push      ax                       ; £schova AX
transt1: lodsb                              ; naáten° znaku k p©enosu
         stosb                              ; uloëen° znaku na vòstup
         or        al,al                    ; byl to jië koncovò bajt 0 ?
         jnz       transt1                  ; nebyla je®tà koncov† 0 - dal®°
         dec       di                       ; n†vrat ukazatele na posledn° 0
         pop       ax                       ; n†vrat AX
         ret

; -----------------------------------------------------------------------------
public   comptxt
comptxt:                                    ; porovn†n° textñ ASCIIZ
                                            ; VSTUP: DS:SI -> ES:DI
                                            ; VùSTUP: ZY=je shoda ©etàzcñ

         push      si
         push      di
         push      ax                       ; £schova AX
compt1:  cmpsb                              ; porovn†n° znakñ
         jne       compt2                   ; nen° shoda znakñ
         cmp       byte ptr ds:[si-1],0     ; byl to jië konec ?
         jne       compt1                   ; nen° konec - dal®° znak
compt2:  pop       ax                       ; n†vrat AX
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   setkonc
setkonc:                                    ; z†pis koncovky "y", "ñ"
                                            ; VSTUP: DS:SI=text á°sla
                                            ;        ES:DI=ukl†dac° adresa
         push      ax
         call      testkonc                 ; test koncovky á°sla
         or        al,al
         jz        endli3                   ; je á°slo 1
         mov       si,offset textvy11       ; koncovka á°sla 2,3,4
         dec       al
         jz        endli2                   ; je á°slo 2,3,4
         mov       si,offset textvy12       ; kocovka ostatn°ch á°sel
endli2:  call      transtxt                 ; uloëen° koncovky
endli3:  pop       ax
         ret

public   testkonc
testkonc:                                   ; test koncovky á°sla
                                            ; VSTUP: DS:SI=text á°sla
                                            ; VùSTUP: AL=0 je koncovka pro "1"
                                            ;         AL=1 koncovka pro 2,3,4
                                            ;         AL=2 ostatn° á°sla

         push      dx
         push      si
         mov       dx,"00"                  ; posledn° 2 á°slice
testkon1:call      readtest                 ; naáten° prvn°/dal®° á°slice
         jc        testkon2                 ; nen° jië dal®° á°slice
         mov       dh,dl                    ; p©edposledn° á°slice
         mov       dl,al                    ; posledn° á°slice
IFDEF    slov
         call      readtest                 ; naáten° dal®° á°slice
         mov       al,2                     ; p©°znak jinÇho á°sla
         jnc       testkon3                 ; je v°ce á°slic
ELSE
         jmp       short testkon1           ; naáten° dal®° á°slice
ENDIF
testkon2:mov       al,2                     ; p©°znak jinÇho á°sla
         cmp       dh,"1"                   ; byly des°tky ?
         je        testkon3                 ; jsou mnoën† á°sla
         cmp       dl,"4"                   ; je á°slice vàt®° neë "4" ?
         ja        testkon3                 ; je á°slice vàt®° neë "4"
         cmp       dl,"0"                   ; je á°slice "0" ?
         je        testkon3                 ; je á°slice "0"
         dec       al                       ; p©°znak á°sla 2,3,4
         cmp       dl,"1"                   ; je á°slice "1" ?
         jne       testkon3                 ; nen° "1" - je 2,3,4
         dec       al                       ; p©°znak á°slice "1"
testkon3:pop       si
         pop       dx
         ret

public   readtest
readtest:                                   ; áten° á°slice p©i testu
                                            ; VùSTUP: CY=nen° platn† á°slice

         lodsb                              ; naáten° dal®° á°slice
         cmp       al,"."                   ; je oddàlovac° teáka ?
         je        readtest
         or        al,al                    ; je jië konec textu ?
         stc
         jz        readtst1
         cmp       al,"0"                   ; je á°slice ?
         jb        readtst1                 ; nen° á°slice
         cmp       al,"9"+1                 ; je á°slice ?
         cmc                                ; CY=nen° á°slice
readtst1:ret

; -----------------------------------------------------------------------------
public   center
center:                                     ; centrov†n° textu ASCIIZ
                                            ; VSTUP: DS:SI=adresa textu
                                            ;        CL=max. ®°©ka ©†dku
                                            ;        DL=pozice kurzoru na ©†dku
                                            ; VùSTUP: CL=offset zaá†tku textu
                                            ;         DL=nov† pozice kurzoru

         push      ax                       ; £schova AX
         push      si                       ; £schova SI
center1: lodsb                              ; naáten° znaku z bufferu
         or        al,al                    ; je konec textu ?
         jz        center2                  ; je jië konec textu
         cmp       al,31                    ; je konec ©†dku ?
         je        center2                  ; je konec ©†dku
         jb        center1                  ; je ©°dic° znak <31 - dal®° znak
         dec       cl                       ; sn°ëen° á°taáe znakñ
         jnz       center1                  ; nen° je®tà 0 - dal®° znak
center2: shr       cl,1                     ; CL/2 - offset od zaá†tku
         add       dl,cl                    ; zvò®en° pozice kurzoru
         pop       si                       ; n†vrat SI
         pop       ax                       ; n†vrat AX
         ret
; -----------------------------------------------------------------------------
public   lensi0
lensi0:                                   ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:SI
                                            ; VSTUP: DS:SI=adresa ©etàzce
                                            ; VùSTUP: AX=dÇlka ©etàzce
                                            ;         ZY=©etàzec je nulovò

         push      si
         xor       ax,ax                    ; á°taá dÇlky ©etàzce
lensi01: cmp       byte ptr ds:[si],0       ; je jië konec ©etàzce ?
         je        lensi04                  ; je konec ©etàzce
         inc       si                       ; zvò®en° ukazatele textu
         inc       al                       ; zvò®en° á°taáe dÇlky
         jnz       lensi01                  ; dal®° znak
         dec       al                       ; omezen° na 255
lensi04: or        al,al
         pop       si
         ret
; -----------------------------------------------------------------------------
public   lensi
lensi:                                    ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:SI
                                            ; VSTUP: DS:SI=adresa ©etàzce
                                            ; VùSTUP: AL=dÇlka ©etàzce
                                            ;         CY=p©eteáen° (AL=255)

         push      si
         xor       ax,ax                    ; nejvàt®° nalezen† dÇlka
lens1:   cmp       byte ptr ds:[si],0       ; je jië konec ©etàzce ?
         je        lens3                    ; je konec ©etàzce
         inc       si                       ; zvò®en° ukazatele textu
         cmp       byte ptr ds:[si-1],31    ; je konec ©†dku ?
         jb        lens1                    ; je ©°dic° znak - ignorov†n°
         jne       lens2                    ; nen° konec ©†dku
         cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lens11                   ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lens11:  xor       ah,ah                    ; nov† hodnota á°taáe dÇlky
         jmp       short lens1
lens2:   inc       ah                       ; zvò®en° á°taáe znakñ ©etàzce
         jnz       lens1                    ; test dal®°ho znaku
         dec       ah                       ; AH <- 255 p©eteáen° textu
         mov       al,ah
         stc                                ; p©°znak p©eteáen°
lens3:   cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lens4                    ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lens4:   pop       si
         ret
; -----------------------------------------------------------------------------
public   lendi

lendi:                                    ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:DI
                                            ; VSTUP: ES:DI=adresa ©etàzce
                                            ; VùSTUP: AL=dÇlka ©etàzce
                                            ;         CY=p©eteáen° (AL=255)

         push      di
         xor       ax,ax                    ; nejvàt®° nalezen† dÇlka
lend1:   cmp       byte ptr ds:[di],0       ; je jië konec ©etàzce ?
         je        lend3                    ; je konec ©etàzce
         inc       di                       ; zvò®en° ukazatele textu
         cmp       byte ptr ds:[di-1],31    ; je konec ©†dku ?
         jb        lend1                    ; je ©°dic° znak - ignorov†n°
         jne       lend2                    ; nen° konec ©†dku
         cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lend11                   ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lend11:  xor       ah,ah                    ; nov† hodnota á°taáe dÇlky
         jmp       short lend1
lend2:   inc       ah                       ; zvò®en° á°taáe znakñ ©etàzce
         jnz       lend1                    ; test dal®°ho znaku
         dec       ah                       ; AH <- 255 p©eteáen° textu
         mov       al,ah
         stc                                ; p©°znak p©eteáen°
lend3:   cmp       ah,al                    ; je vàt®° neë nalezenò ©†dek ?
         jbe       lend4                    ; nen° vàt®°
         mov       al,ah                    ; nov† nalezen† dÇlka
lend4:   pop       di
         ret
; -----------------------------------------------------------------------------
;                            Zobrazen° á°sel
; -----------------------------------------------------------------------------
public   tisknm2s,tisknm20,tisknm21
tisknm2s:                                   ; tisk á°sla 2 á°slice s mezerami
                                            ; VSTUP: AL=á°slo
                                            ;        DX=pozice

         call      setspc                   ; nastaven° m¢du tisku mezer
         jmp       short tisknm21

tisknm20:                                   ; tisk á°sla 2 á°slice s nulami
                                            ; VSTUP: AL=á°slo
                                            ;        DX=pozice

         call      setnul                   ; nastaven° m¢du tisku mezer
tisknm21:push      di
         push      si
         push      bx
         push      cx
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         push      dx                       ; pozice
         mov       di,offset bufwin         ; tiskovò buffer
         xor       ah,ah
         call      deknum2                  ; dek¢dov†n° á°sla 2 á°slice
         pop       dx                       ; pozice
         mov       si,offset bufwin         ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         call      setfre                   ; volnò form†t tisku á°sla
         pop       es
         pop       ds
         pop       cx
         pop       bx
         pop       si
         pop       di
         ret

; -----------------------------------------------------------------------------
public   tisknm0
tisknm0:                                    ; tisk á°sla 10 á°slic zarov. vpravo
                                            ; VSTUP: BX:AX=á°slo
                                            ;        DX=pozice

         push      di
         push      si
         push      ds
         push      es
         push      cs
         pop       ds
         push      cs
         pop       es
         push      dx                       ; pozice
         call      setspc                   ; nastaven° m¢du tisku mezer
         mov       dx,bx                    ; vy®®° slovo á°sla
         mov       di,offset bufwin         ; tiskovò buffer
         call      deknumx                  ; p©ek¢dov†n° á°sla s omezen°m
         pop       dx                       ; pozice
         mov       si,offset bufwin         ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         call      setfre                   ; volnò form†t tisku á°sla
         pop       es
         pop       ds
         pop       si
         pop       di
         ret

; -----------------------------------------------------------------------------
public   setspc,setnul,setfre
setspc:                                   ;* zapnut° tisku mezer p©ed á°slem

         and       byte ptr cs:[parnum],0fdh ; vypnut° tisku nul
         or        byte ptr cs:[parnum],2   ; zapnut° tisku mezer
         ret


setnul:                                   ;* zapnut° tisku nul p©ed á°slem

         and       byte ptr cs:[parnum],0fbh ; vypnut° tisku mezer
         or        byte ptr cs:[parnum],4   ; zapnut° tisku nul
         ret


setfre:                                   ;* zapnut° volnÇho form†tu á°sla

         and       byte ptr cs:[parnum],0f9h ; vypnut° tisku mezer a nul
         ret

; -----------------------------------------------------------------------------
public   deknumx,deknmx1,deknmx2,deknmx3,deknmx4
deknumx:                                    ; p©ek¢dov†n° á°sla s omezen°m
                                            ; VSTUP: (DX:)AX=á°slo k p©ek¢dov†n°
                                            ;        ES:DI=adr. k uloëen° textu
                                            ; VùSTUP: AL=poáet znakñ ©etàzce
                                            ; zniáenÇ registry: AX,BX,CX,DX

         cmp       dx,5f5h                  ; vy®®° slovo á°sla 100 000 000
         jne       deknmx1                  ; nen° shoda
         cmp       ax,0e100h                ; nië®° slovo á°sla 100 000 000
deknmx1: jnb       deknmx2                  ; je á°slo 100 000 000 nebo vy®®°
         jmp       deknum8                  ; dek¢dov†n° á°sla 8 á°slic

deknmx2: cmp       dx,3b9ah                 ; vy®®° slovo á°sla 1000 000 000
         jne       deknmx3                  ; nen° shoda
         cmp       ax,0ca00h                ; nië®° slovo á°sla 1000 000 000
deknmx3: jnb       deknmx4                  ; je á°slo 1000 000 000 nebo vy®®°
         or        byte ptr cs:[parnum],10h ; z†kaz tisku teáku tis°cñ
         call      deknum9                  ; dek¢dov†n° á°sla 9 á°slic
         and       byte ptr cs:[parnum],0efh; povolen° tisku teáky tis°cñ
         ret

deknmx4: or        byte ptr cs:[parnum],1   ; z†kaz tisku teáek
         call      deknum0                  ; dek¢dov†n° á°sla 10 á°slic
         and       byte ptr cs:[parnum],0feh ; povolen° tisku teáek
         ret

; -----------------------------------------------------------------------------
public   deknum,deknum0,deknum9,deknum8,deknum7,deknum6,deknum5,deknum4
public   deknum41,deknum3,deknum2
deknum:                                   ;* p©evod á°sla na dekadickÇ á°slo
                                            ; VSTUP: (DX:)AX=á°slo k p©ek¢dov†n°
                                            ;        ES:DI=adr. k uloëen° textu
                                            ; VùSTUP: AL=poáet znakñ ©etàzce
                                            ; zniáenÇ registry: AX,BX,CX,DX

deknum0:                                  ;* dek¢dov†n° 10 á°slic
         mov       bx,3b9ah                 ; vy®®° slovo á°sla 1000 000 000
         mov       cx,0ca00h                ; nië®° slovo á°sla 1000 000 000
         call      deknm0                   ; dek¢dov†n° 1 á°slice
deknum9:                                  ;* dek¢dov†n° 9 á°slic
         mov       bx,5f5h                  ; vy®®° slovo á°sla 100 000 000
         mov       cx,0e100h                ; nië®° slovo á°sla 100 000 000
         call      deknm0                   ; dek¢dov†n° 1 á°slice
deknum8:                                  ;* dek¢dov†n° 8 á°slic
         mov       bl,98h                   ; vy®®° slovo á°sla 10 000 000
         mov       cx,9680h                 ; nië®° slovo á°sla 10 000 000
         call      deknm02                  ; dek¢dov†n° 1 á°slice
deknum7:                                  ;* dek¢dov†n° 7 á°slic
         mov       bl,0fh                   ; vy®®° slovo á°sla 1 000 000
         mov       cx,4240h                 ; nië®° slovo á°sla 1 000 000
         call      deknm02                  ; dek¢dov†n° 1 á°slice
         call      deknm8                   ; oddàlovac° teáka
deknum6:                                  ;* dek¢dov†n° 6 á°slic
         mov       bl,1                     ; vy®®° slovo á°sla 100 000
         mov       cx,86a0h                 ; nië®° slovo á°sla 100 000
         call      deknm02                  ; dek¢dov†n° 1 á°slice
deknum5:                                  ;* dek¢dov†n° 5 á°slic
         mov       cx,10000                 ; nië®° slovo á°sla 10 000
         call      deknm01                  ; dek¢dov†n° 1 á°slice
deknum4:                                  ;* dek¢dov†n° 4 á°slic
         mov       cx,1000                  ; nië®° slovo á°sla 1 000
         call      deknm00                  ; dek¢dov†n° 1 á°slice
         test      byte ptr cs:[parnum],10h ; je z†kaz tisku tis°cñ ?
         jz        deknum41                 ; nen° z†kaz tisku tis°cñ
         or        byte ptr cs:[parnum],8   ; p©echodnò z†kaz tisku teáky
deknum41:call      deknm8                   ; oddàlovac° teáka
deknum3:                                  ;* dek¢dov†n° 3 á°slic
         mov       cx,100                   ; nië®° slovo á°sla 100
         call      deknm00                  ; dek¢dov†n° 1 á°slice
deknum2:                                  ;* dek¢dov†n° 2 á°slic
         mov       cx,10                    ; nië®° slovo á°sla 10
         call      deknm00                  ; dek¢dov†n° 1 á°slice
                                          ;* dek¢dov†n° 1 á°slice
         add       al,"0"                   ; korekce na á°slici
         stosb                              ; uloëen° posledn° á°slice
         xor       al,al
         stosb                              ; uloëen° ukonáovac°ho bajtu 0
         dec       di                       ; ukazatel na posledn° bajt 0
         and       byte ptr cs:[parnum],0f7h; zru®en° p©echodnÇho z†kazu teáky
         xchg      al,cs:[citdek]           ; vynulov†n° á°taáe á°slic
         inc       al                       ; poáet znakñ dek¢dovanÇho textu
         ret

public   deknm00,deknm01,deknm02,deknm0,deknm1,deknm2,deknm21,deknm3

                                          ;* dek¢dov†n° á°slice 32-bit. á°sla
                                            ; VSTUP: DX:AX=á°slo
                                            ;        BX:CX=dàlitel á°sla
                                            ;        ES:DI=adr. k uloëen° textu

deknm00: xor       dx,dx                    ; DX <- 0
deknm01: xor       bl,bl                    ; BL <- 0
deknm02: xor       bh,bh                    ; BH <- 0
deknm0:  mov       byte ptr cs:[citnum],2fh ; inicializace á°taáe á°slice
deknm1:  inc       byte ptr cs:[citnum]     ; zvò®en° á°taáe á°slice
         sub       ax,cx                    ; odeáten° nië®°ho slova á°sla
         sbb       dx,bx                    ; odeáten° vy®®°ho slova á°sla
         jnc       deknm1                   ; nen° je®tà p©eteáen°
         add       ax,cx                    ; n†vrat nië®°ho slova á°sla
         adc       dx,bx                    ; n†vrat vy®®°ho slova á°sla
         cmp       byte ptr cs:[citnum],"0" ; je á°slice 0 ?
         jne       deknm2                   ; nen° á°slice 0 - dek¢dov†n°
         cmp       byte ptr cs:[citdek],0   ; byla jië nàjak† á°slice ?
         jne       deknm2                   ; byla jië nàjak† á°slice
         test      byte ptr cs:[parnum],4   ; je tisku nul ?
         jnz       deknm2                   ; je tisk nul
         mov       byte ptr cs:[citnum]," " ; n†hradn° znak mezery
         test      byte ptr cs:[parnum],2   ; je tisk mezer ?
         jz        deknm3                   ; nen° tisk mezer
         jmp       short deknm21
deknm2:  inc       byte ptr cs:[citdek]     ; zvò®en° á°taáe á°slic
deknm21: push      ax                       ; £schova AX
         mov       al,cs:[citnum]           ; dek¢dovan† á°slice
         stosb                              ; uloëen° á°slice
         pop       ax                       ; n†vrat AX
deknm3:  ret

public   deknm8,deknm81,deknm9
deknm8:
         push      ax
         mov       al,"."                   ; oddàlovac° teáka
         test      byte ptr cs:[parnum],9   ; je povolenò tisk teáky ?
         jnz       deknm9                   ; tisk nen° povolenò
         cmp       byte ptr cs:[citdek],0   ; byla jië platn† á°slice ?
         jne       deknm81                  ; byla jië platn† á°slice
         test      byte ptr cs:[parnum],3   ; je volnò form†t ?
         jz        deknm9                   ; je volnò form†t
         test      byte ptr cs:[parnum],4   ; je tisk nul ?
         jnz       deknm81                  ; je tisk nul
         mov       al," "                   ; n†hradn° oddàlovac° mezera
deknm81: mov       byte ptr es:[di],al      ; oddàlovac° znak
         inc       di                       ; zvò®en° ukl†dac° adresy
         cmp       byte ptr cs:[citdek],0   ; je jië nàjak† á°slice ?
         je        deknm9                   ; nen° je®tà ë†dn† á°slice
         inc       byte ptr cs:[citdek]     ; zvò®en° á°taáe á°slic (znakñ)
deknm9:  pop       ax
         ret

; -----------------------------------------------------------------------------
;                        Obsluha segmentace pamàti
; -----------------------------------------------------------------------------
public   iniedis
iniedis:                                  ;* inicializace segmentu editoru
                                            ; VùSTUP: CY=nen° voln† pamàü
         push      bx
         push      ax
         mov       word ptr cs:[editnum],0  ; zru®en° obsahu pamàti
         call      createseg                ; vytvo©en° novÇho segmentu
         jc        iniedis2                 ; nen° voln† poloëka
         mov       cs:[editseg],al          ; uloëen° á°sla segmentu
         call      getmax                   ; poskytnut° max. velikosti segmentu
         jc        iniedis2                 ; nen° voln† pamàü
         mov       cs:[editmax],bx          ; maxim†ln° velikost bufferu
         call      modiseg                  ; modifikace segmentu na max. velik.
iniedis2:pop       ax
         pop       bx
         ret
; -----------------------------------------------------------------------------
public   aktedis
aktedis:                                  ;* aktual. segmentu s edit. soub.
                                            ; VùSTUP: DS=adresa segmentu
         pushf
         push      bx
         push      ax
         mov       al,cs:[editseg]          ; segment se souborem
;         or        al,al                    ; je segment definovanò ?
;         jz        aktedis1                 ; nen° definovanò
         call      getseg                   ; poskytnut° adresy segmentu
         mov       cs:[topseged],bx         ; adresa segmentu editoru
aktedis1:pop       ax
         pop       bx
         popf
         ret
; -----------------------------------------------------------------------------
public   deledis
deledis:                                  ;* zru®en° segmentu s edit. soub.

         push      ax
         mov       al,cs:[editseg]          ; segment se souborem
         call      delseg                   ; poskytnut° adresy segmentu
         mov       byte ptr cs:[editseg],0  ; zru®en° segmentu
         mov       word ptr cs:[editnum],0  ; zru®en° obsahu pamàti
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   getmax

getmax:                                   ;* poskytnut° maxim.velikosti segmentu
                                            ; VùSTUP: BX=maxim. velikost segm.
                                            ;         CY=segment < 16 B

         push      cx
         mov       bx,ds:[segend]           ; segment konce pamàti
         sub       bx,2                     ; rezerva
         sub       bx,ds:[topseg]           ; voln† pamàü
         jnc       getmax1                  ; nen° p©eteáen°
         xor       bx,bx                    ; BX <- 0 (nen° pamàü)
getmax1: cmp       bx,0fe0h                 ; je vàt®° neë 64 KB ?
         jb        getmax2                  ; nen° vàt®° neë 64 KB
         mov       bx,0fe0h                 ; omezen° na 64 KB
getmax2: mov       cl,4
         shl       bx,cl                    ; voln† kapacita (v bajtech)
         cmp       bx,10h                   ; porovn†n° s minim†ln° velikost°
         pop       cx
         ret
; -----------------------------------------------------------------------------
public   createseg

createseg:                                ;* vytvo©en° novÇho segmentu dat
                                            ; VùSTUP: AL=á°slo p©idàl. segmentu
                                            ;         CY=nen° voln† poloëka

         push      cx
         push      bx                       ; £schova BX
         xor       al,al                    ; á°taá poloëek
         mov       bx,offset seznseg        ; adresa seznamu segmentñ
         mov       cx,offset seznseg0       ; konec seznamu
         sub       cx,bx                    ; dÇlka seznamu
         shr       cx,1                     ; poáet poloëek v seznamu
creats1: cmp       word ptr cs:[bx],0       ; je voln† poloëka ?
         jz        creats2                  ; nalezena voln† poloëka
         inc       al                       ; zvò®en° á°sla poloëky
         add       bx,2                     ; zvò®en° adresy v tabulce
         loop      creats1                  ; test dal®° poloëky
         stc                                ; p©°znak chyby - nen° ë†dn† voln†
         jmp       short creats3            ; n†vrat s chybou
creats2: mov       cx,cs:[topseg]           ; segment zaá†tku volnÇ pamàti
         mov       cs:[bx],cx               ; nastaven° novÇho segmentu
         mov       bx,1                     ; minim†ln° dÇlka segmentu
         call      modiseg                  ; modifikace velikosti segmentu
creats3: pop       bx                       ; n†vrat BX
         pop       cx                       ; n†vrat
         ret

; -----------------------------------------------------------------------------
public   delseg

delseg:                                   ;* zru®en° poloëky segmentu
                                            ; VSTUP: AL=á°slo ru®enÇho segmentu

         push      bx                       ; £schova BX
         xor       bx,bx                    ; novò konec segmentu = 0
         call      modiseg0                 ; modifikace segmentu na 0
         mov       bl,al                    ; á°slo ru®enÇho segmentu
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky segmentu
         mov       word ptr cs:[bx],0       ; vynulov†n° poloëky
         pop       bx                       ; n†vrat BX
         ret

; -----------------------------------------------------------------------------
public   getseg

getseg:                                   ;* poskytnut° adresy segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: BX=adresa segmentu

         xor       bh,bh                    ; BH <- 0
         mov       bl,al                    ; á°slo segmentu v tabulce
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky v seznamu
         mov       bx,cs:[bx]               ; p©eáten° adresy segmentu
         ret

; -----------------------------------------------------------------------------
public   getssize

getssize:                                 ;* poskytnut° velikosti segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: BX=velikost segmentu
         push      ax
         push      dx
         call      getseg                   ; poskytnut° adresy segmentu
         mov       dx,bx                    ; £schova adresy segmentu
         call      nextseg                  ; nalezen° n†sleduj°c°ho segmentu
         mov       bx,cs:[topseg]           ; segment zaá†tku volnÇ pamàti
         jc        getssiz2                 ; nenalezen dal®° segment
         call      getseg                   ; poskytnut° adresy segmentu
getssiz2:sub       bx,dx                    ; velikost segmentu (odstavcñ)
         add       bx,bx
         add       bx,bx
         add       bx,bx
         add       bx,bx                    ; skuteán† dÇlka segmentu
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   nextseg

nextseg:                                  ;* nalezen° n†sleduj°c°ho segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: AL=n†sled. segment (CN)
                                            ;         CY=nen° jië dal®° segment

         push      bx
         push      cx
         push      dx
         push      si
         call      getseg                   ; poskytnut° adresy segmentu BX
         lea       si,[seznseg]             ; seznam segmentñ
         xor       ah,ah                    ; á°taá á°sla poloëky
         mov       dx,0ffffh                ; vòchoz° minim†ln° adresa segmentu
         mov       cx,offset seznseg0       ; konec seznamu
         sub       cx,offset seznseg        ; dÇlka seznamu
         shr       cx,1                     ; poáet poloëek v seznamu
nextseg1:cmp       cs:[si],dx               ; je vàt®° poloëka neë nalezen† ?
         jae       nextseg2                 ; nen° to men®° poloëka
         cmp       cs:[si],bx               ; je z†rove§ vàt®° neë testovan† ?
         jbe       nextseg2                 ; nen° vàt®°
         mov       dx,cs:[si]               ; nov† nejblië®° poloëka
         mov       al,ah                    ; novÇ á°slo segmentu
nextseg2:add       si,2                     ; zvò®en° ukazatele v bufferu
         inc       ah                       ; zvò®en° á°sla segmentu
         loop      nextseg1                 ; testov†n° dal®° poloëky
         cmp       dx,0ffffh                ; byla nalezena nàjak† poloëka ?
         cmc                                ; CY=poloëka nenalezena
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   predseg

predseg:                                  ;* nalezen° p©edch†zej°c°ho segmentu
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: AL=p©edch†z. segment (CN)
                                            ;         CY=nen° jië dal®° segment

         push      bx
         push      cx
         push      dx
         push      si
         call      getseg                   ; poskytnut° adresy segmentu
         lea       si,[seznseg]             ; seznam segmentñ
         xor       ah,ah                    ; ukazatel á°sla poloëky
         xor       dx,dx                    ; vòchoz° minim†ln° adresa segmentu
         mov       cx,offset seznseg0       ; konec seznamu
         sub       cx,offset seznseg        ; dÇlka seznamu
         shr       cx,1                     ; poáet poloëek v seznamu
predseg1:cmp       cs:[si],dx               ; je men®° poloëka neë nalezen† ?
         jbe       predseg2                 ; nen° to vàt®° poloëka
         cmp       cs:[si],bx               ; je z†rove§ men®° neë testovan† ?
         jae       predseg2                 ; nen° men®°
         mov       dx,cs:[si]               ; nov† nejblië®° poloëka
         mov       al,ah
predseg2:add       si,2                     ; zvò®en° ukazatele v bufferu
         inc       ah
         loop      predseg1                 ; testov†n° dal®° poloëky
         cmp       dx,1                     ; byla nalezena nàjak† poloëka ?
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   modiseg,modiseg0

modiseg:                                  ;* modifikace segmentu s ochranou
         push      bx
         or        bx,bx
         jnz       modisg01
         inc       bx                       ; rezerva
modisg01:call      modiseg0
         pop       bx
         ret

modiseg0:                                 ;* modifikace velikosti segmentu
                                          ;* (prov†d° se po n†sobc°ch 256 B)
                                            ; VSTUP: AL=á°slo segmentu
                                            ;        BX=nov† velikost segmentu
                                            ; VùSTUP: CY=nedostatek pamàti
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         add       bx,255                   ; zaokrouhlen° na n†sobek 256
         jnc       modisegc                 ; nen° p©eteáen°
         jmp       modisega                 ; p©eteáen°
modisegc:xor       bl,bl                    ; BL <- 0; zñstane pouze vy®®° bajt
         mov       dx,bx                    ; poëadovan† velikost segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         sub       bx,dx                    ; porovn†n° vy®®°ch slov velikost°
         mov       dx,bx                    ; £schova posunu
         ja        modiseg1                 ; poëadov†no sn°ëen° velikosti
         jc        modiseg4                 ; poëadov†no zvò®en° velikosti
         jmp       modiseg9                 ; zmàny jsou v ©†du 256 bajtñ
modiseg1:                                 ;* je sn°ëen° velikosti segmentu
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; posun segmentñ v odstavc°ch
modiseg2:call      nextseg                  ; n†sleduj°c° segment
         jnc       modiseg8                 ; je je®tà dal®° segment
         sub       word ptr cs:[topseg],dx  ; sn°ëen° zaá†tku volnÇ pamàti
         jmp       modiseg9                 ; nen° jië dal®° segment
modiseg8:call      getseg                   ; poskytnut° adresy segmentu
         mov       cx,bx                    ; £schova adresy segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         xchg      cx,bx                    ; BX<-adresa segmentu, CX<-velikost
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         mov       ds,bx                    ; souáasn† adresa segmentu
         sub       bx,dx                    ; nov† adresa segmentu (sn°ëen†)
         mov       es,bx                    ; nov† adresa segmentu (sn°ëen†)
         xor       si,si                    ; offset zdrojovÇ adresy
         xor       di,di                    ; offset c°lovÇ adresy
         rep       movsb                    ; p©enos obsahu segmentu
         pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         mov       bl,al                    ; á°slo segmentu
         xor       bh,bh                    ; BH <- 0
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky segmentu
         sub       word ptr cs:[bx],dx      ; sn°ëen° adresy segmentu
         jmp       short modiseg2           ; p©esun dal®°ho segmentu

modiseg4:                                 ;* je zvò®en° velikosti segmentu
         neg       dx                       ; posun segmentu
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; posun segmentñ v odstavc°ch
                                          ;* zjist° se, kolik segmentñ n†sleduje
         xor       cx,cx                    ; á°taá zbylòch segmentñ
modiseg5:inc       cx                       ; zvò®en° á°taáe segmentñ
         call      nextseg                  ; n†sleduj°c° segment
         jnc       modiseg5                 ; nalezen° posledn°ho segmentu
         dec       cx                       ; poáet n†sleduj°c°ch segmentñ
                                          ;* nastaven° novÇho konce pamàti
modiseg6:push      ax                       ; £schova á°sla segmentu
         push      cx                       ; £schova á°taáe segmentñ
         call      getseg                   ; poskytnut° adresy segmentu
         mov       cx,bx                    ; adresa segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         xchg      cx,bx                    ; BX<-adresa segmentu, CX<-velikost
         mov       ax,cx                    ; velikost segmentu
         add       ax,15                    ; zaokrouhlen° na odstavec
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; velikost segmentu v odstavc°ch
         add       ax,bx                    ; pñvodn° adresa konce segmentu
         add       ax,dx                    ; nov† adresa konce segmentu
         cmp       ax,cs:[segend]           ; kontrola p©ekroáen° konce
         ja        modisg61                 ; p©ekroáen° konce pamàti
         mov       cs:[topseg],ax           ; novò zaá†tek volnÇ pamàti
modisg61:pop       cx
         pop       ax
         jbe       modiseg7                 ; nen° je®tà p©ekroáen° konce
         stc                                ; p©°znak chyby
         jmp       short modisega           ; n†vrat s chybou
                                          ;* p©esunut° v®ech segmentñ
modiseg7:jcxz      modiseg9                 ; nen†sleduje ë†dnò segment
         push      cx                       ; á°taá segmentñ
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         call      getseg                   ; poskytnut° adresy segmentu
         mov       cx,bx                    ; adresa segmentu
         call      getssize                 ; poskytnut° velikosti segmentu
         xchg      cx,bx                    ; BX<-adresa segmentu, CX<-velikost
         mov       ds,bx                    ; souáasn† adresa segmentu
         add       bx,dx                    ; nov† adresa segmentu (zvò®en†)
         mov       es,bx                    ; nov† adresa segmentu
         mov       si,cx                    ; dÇlka segmentu
         dec       si                       ; offset posledn°ho bajtu
         mov       di,si                    ; offset posledn°ho bajtu
         std                                ; smàr p©enosu dolñ
         rep       movsb                    ; posun obsahu segmentu
         cld                                ; smàr p©enosu nahoru
         pop       es
         pop       ds
         pop       cx
         mov       bl,al                    ; á°slo segmentu
         xor       bh,bh                    ; BH <- 0
         add       bx,bx                    ; á°slo segmentu * 2
         add       bx,offset seznseg        ; adresa poloëky segmentu
         add       word ptr cs:[bx],dx      ; zvò®en° adresy segmentu
         call      predseg                  ; á°slo p©edch†zej°c°ho segmentu
         loop      modiseg7                 ; p©esun dal®°ho segmentu
modiseg9:clc                                ; p©°znak - operace OK
modisega:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      aktedis                  ; aktualizace segmentu editoru
         ret

; *****************************************************************************
;
;                      Podprogramy pro diskovÇ operace
;
; *****************************************************************************
public   loadpath
loadpath:                                 ;* naáten° cesty aktivn°ho adres†©e
                                            ; VSTUP: ES:DI=ukl†dac° adresa

         push      ax                       ; £schova AX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         mov       ah,19h                   ; funkce poskytnut° aktivn°ho disku
         int       21h                      ; poskytnut° aktivn°ho disku
         inc       al                       ; á°slo disku + 1
         mov       dl,al                    ; £schova á°sla disku
         add       al,40h                   ; korekce disku na znak ASCII
         stosb                              ; uloëen° oznaáen° disku
         mov       ax,"\:"                  ; text ":\"
         stosw                              ; uloëen° textu ":\"
         mov       si,di                    ; zaá†tek oznaáen° cesty
         xor       al,al
         stosb
         push      es                       ; ES -> stack
         pop       ds                       ; DS <- ES segment s bufferem
         mov       ah,47h                   ; funkce poskytnut° aktiv. adres†©e
         int       21h                      ; poskytnut° aktivn°ho adres†©e
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       ax                       ; n†vrat AX
         ret

; -----------------------------------------------------------------------------
public   aktdir
aktdir:                                   ;* nastaven° aktivn°ho adres†©e
                                            ; VSTUP: DS:SI=p©°stupov† cesta
                                            ; VùSTUP: NZ=diskov† chyba
                                            ;         CY=adres†© nenalezen

         push      dx                       ; £schova DX
         push      ax                       ; £schova AX
         cmp       byte ptr ds:[si],0       ; je zad†n adres†© ?
         je        aktdir2                  ; adres†© nen° zad†n
         cmp       byte ptr ds:[si+1],":"   ; je ud†n disk ?
         jne       aktdir1                  ; nen° ud†n disk
         mov       al,ds:[si]               ; oznaáen° disku
         call      highcase                 ; p©evod na velkÇ p°smeno
         sub       al,"A"                   ; p©evod na á°slo disku
         mov       dl,al                    ; poëadovanò disk
         mov       ah,0eh                   ; funkce nastaven° disku
         int       21h                      ; nastaven° aktivn°ho disku
         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         cmp       al,dl                    ; souhlas° nastavenò disk ?
         stc
         jne       aktdir2                  ; chyba zad†n° disku
         cmp       byte ptr ds:[si+2],0     ; je zad†n adres†© ?
         je        aktdir2                  ; nen° zad†n adres†© - OK
aktdir1: cmp       byte ptr ds:[si],0       ; je zad†n adres†© ?
         je        aktdir2                  ; nen° zad†n adres†© - OK
         mov       dx,si                    ; p©°stupov† cesta k adres†©i
         mov       ah,3bh                   ; funkce nastaven° aktiv. adres†©e
         int       21h                      ; nastaven° aktivn°ho adres†©e
aktdir2: pop       ax                       ; n†vrat AX
         pop       dx                       ; n†vrat DX
         ret

; -----------------------------------------------------------------------------
public   dekfile
dekfile:                                    ; zak¢dov†n° jmÇna souboru
                                            ; VSTUP: DS:SI -> ES:DI
         push      cx
         push      bx
         push      si
         lodsb                              ; atributy poloëky
         mov       bl,al                    ; £schova atributñ poloëky
         mov       cx,8
dekfil1: lodsb
         test      bl,16h                   ; je adres†© nebo skrytò/systÇmovò ?
         jnz       dekfl11                  ; je adres†© nebo skrytò/systÇmovò
         call      lowcase0                 ; p©evod na malÇ p°smeno
dekfl11: and       bl,0f9h                  ; zru®en° atributñ SYS/HID
         stosb
         loop      dekfil1
         mov       cl,8                     ; poáet znakñ jmÇna = 8
dekfil7: dec       di
         cmp       byte ptr es:[di]," "     ; je mezera ?
         je        dekfil7                  ; vypu®tàn° koncovòch mezer
         inc       di                       ; n†vrat pozice
         cmp       byte ptr ds:[si-8],"."   ; je adres†© ?
         je        dekfil4                  ; neplat° teáka za jmÇnem
         cmp       word ptr ds:[si],"  "    ; je p©°pona ?
         jne       dekfilb                  ; je p©°pona
         cmp       byte ptr ds:[si+2]," "   ; je p©°pona ?
         je        dekfil4                  ; nen° p©°pona
dekfilb: mov       al,"."
         stosb
dekfil4: mov       cl,3
dekfil3: lodsb
         test      bl,16h                   ; je adres†© nebo skrytò/systÇmovò ?
         jnz       dekfl31                  ; je adres†© nebo skrytò/systÇmovò
         call      lowcase0                 ; p©evod na malÇ p°smeno
dekfl31: and       bl,0f9h                  ; zru®en° atributñ SYS/HID
         stosb
         loop      dekfil3
dekfil5: mov       cl,11                    ; max. poáet znakñ k vypu®tàn°
dekfil8: dec       di
         cmp       byte ptr es:[di]," "     ; je mezera ?
         je        dekfil8                  ; vypu®tàn° koncovòch mezer
         inc       di                       ; n†vrat pozice
         mov       byte ptr es:[di],0       ; koncovò bajt 0
         pop       si
         pop       bx
         pop       cx
         ret


code     ends

         end

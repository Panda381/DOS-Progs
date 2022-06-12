
; modul DOSM.ASM - hlavn° á†st programu

; *****************************************************************************
;
;                          Hlavn° á†st programu
;
; *****************************************************************************
code     segment   public
         assume    cs:code,ds:code

extrn    deinit:near,storecnf:near,datarez:byte,execx:near,segrez:word
extrn    parrez:byte,init:near,old22:dword

public   main,mainx,konec0

         include   dos0use.asm              ; z†kladn° ovl†d†n° programu

main:                                     ;* hlavn° obsluha programu
         call      uziv                     ; hlavn° program - povely
mainx:                                    ;* proveden° p©°kazu, n†vrat
         call      deinit                   ; odinstalov†n° programu
         call      storecnf                 ; uloëen° konfigurace

         or        byte ptr cs:[parrez],2   ; p©°znak opakovanÇho startu

         or        al,al                    ; je operace OK ?
         jnz       konec0                   ; nen° operace OK
                                          ;* zobrazen° p©°kazu
         push      cs
         pop       ds                       ; DS <- CS
         mov       es,ds:[segrez]           ; segment rezidentn°ch dat
         push      ax
         cmp       byte ptr es:[80h],2      ; je nàjakò p©°kaz ?
         jb        mainx2                   ; nen° ë†dnò p©°kaz
ifndef   demo
         or        dx,dx                    ; m† se text zobrazit ?
         jz        mainx2                   ; text se nem† zobrazit
endif
         call      getakt                   ; poskytnut° aktivn°ho okna
         mov       si,ds:[bp+4]             ; adresa cesty
mainx1:  lodsb
         or        al,al
         jz        mainx3
         call      mainout                  ; zobrazen° znaku
         jmp       short mainx1
mainx3:  mov       al,">"
         call      mainout
         mov       cl,es:[80h]              ; dÇlka textu
         xor       ch,ch
         sub       cl,2
         mov       si,83h                   ; text p©°kazu
         jcxz      mainx7                   ; nen° ë†dnò znak p©°kazu
mainx4:  mov       al,es:[si]
         inc       si
         call      mainout                  ; vòstup znaku
         loop      mainx4
mainx5:
         mov       al,13
         call      mainout
         mov       al,10
         call      mainout
mainx2:                                   ;* p©enesen° dat na rezidentn° modul
         test      byte ptr cs:[flags],8    ; je rezidentn° reëim ?
         jz        mainx8                   ; nen° rezidentn° reëim
         or        byte ptr cs:[parrez],1   ; p©°znak rezidentn°ho reëimu
         jmp       short mainx6             ; je rezidentn° provoz
mainx8:  lea       di,[datarez]             ; zaá†tek rezidentn°ch dat
         lea       si,[inidata]             ; zaá†tek inicializaán°ch dat
         lea       cx,[inidend]             ; konec inicializaán°ch dat
         sub       cx,si                    ; dÇlka inicializaán°ch dat
         rep       movsb                    ; uloëen° rezidentn°ch dat
mainx6:  mov       ax,es                    ; segment pro uloëen° dat
         mov       bx,cs                    ; tento segment
         cmp       ax,bx                    ; je tento segment ?
         pop       ax                       ; AL=n†vratovò k¢d
         jne       konec0                   ; je jië v pamàti

         jmp       execx                    ; proveden° povelu v p©°kaz. ©†dku

konec0:                                   ;* konec programu (AL=n†vratovò k¢d)
         mov       ax,2522h
         lds       dx,cs:[old22]
         int       21h                      ; n†vrat obsluhy INT 22h
         mov       ah,4ch                   ; funkce pro n†vrat z programu
         int       21h                      ; ukonáen° programu

mainx7:  mov       ds:[80h],ch              ; vynulov†n° p©°kazu
         jmp       init                     ; nov† inicializace programu

public   mainout
mainout:                                  ;* vòstup znaku
                                            ; VSTUP: AL=znak
         push      dx
         push      ax
         mov       dl,al
         mov       ah,2
         int       21h
;         int       29h
         pop       ax
         pop       dx
         ret

public   prodldem
prodldem:                                 ;* prodleva pro DEMO
IFDEF    demo
         pushf
         push      cx
         push      bx
         mov       bh,3
prodld2: xor       cx,cx
         loop      $
         dec       bh
         jnz       prodld2
         pop       bx
         pop       cx
         popf
ENDIF
         ret

; *****************************************************************************
;
;                    ZnakovÇ vstupnà/vòstupn° podprogramy
;
; *****************************************************************************
public   flushkey

flushkey:                                 ;* vypr†zdnàn° bufferu kl†vesnice

         push      ax
         push      cx
         xor       cx,cx                    ; maxim†ln° poáet cyklñ
flk1:    call      testkey                  ; test stavu kl†vesnice
         jz        flk2                     ; nen° p©ipraven dal®° znak
         call      inpkey                   ; vstup znaku z kl†vesnice
         loop      flk1                     ; vypr†zdnàn° dal®°ho znaku
flk2:    pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   inpkeyf

inpkeyf:                                 ;* vstup znaku s vyprazd§ov†n°m
                                            ; VSTUP: SI=tabulka n†povàdy
                                            ; VùSTUP: AX=znak

         push      cx
         xor       ax,ax                    ; AX <- 0 nulov†n° bufferu
         xchg      ax,cs:[edikey]           ; vyjmut° znaku z bufferu
         or        ax,ax                    ; je nàjak† kl†vesa ?
         jnz       inpkey5                  ; byla nàjak† kl†vesa
inpkey4: call      modihlp                  ; modifikace zobrazen° n†povàdy
;         call      testalt
;         jnz       inpkey8                  ; kl†vesa ALT je stisknuta
;         mov       byte ptr cs:[numsrc],0   ; zru®en° bufferu znakñ
inpkey8: call      testkey                  ; je p©ipraven znak ?
         jz        inpkey4                  ; áek†n° na p©°chod znaku
         call      inpkey                   ; vstup znaku z kl†vesnice
inpkey5: mov       cx,ax                    ; £schova znaku
inpkey6: call      testkey                  ; test p©ipravenÇ kl†vesy
         jz        inpkey7                  ; nen° p©ipraven ë†dnò znak
         cmp       ax,cx                    ; je stejnò znak ?
         jne       inpkey7                  ; nen° stejnò znak
         call      inpkey                   ; vypr†zdnàn° bufferu kl†vesnice
         mov       cs:[edikey],ax           ; £schova znaku
         jmp       short inpkey6            ; dal®° znak
inpkey7: mov       ax,cx                    ; n†vrat znaku
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   testkey

testkey:                                  ;* test kl†vesnice, zda p©i®el znak
                                            ; VùSTUP: NZ=znak je p©ipraven
                                            ;         AX=znak

;         mov       ax,cs:[edikeym]
;         or        ax,ax
;         jnz       inpkey3                  ; je p©ipraven znak
         mov       ah,cs:[keystat]          ; k¢d pro áten° stavu kl†vesnice
         jmp       short inpkey0            ; áten° stavu kl†vesnice

; -----------------------------------------------------------------------------
public   inpkey

inpkey:                                  ;* vstup znaku z kl†vesnice
                                           ; VùSTUP: AX=znak

;         call      testkey                  ; je p©ipraven znak ?
;         je        inpkey                   ; áek†n° na p©°chod znaku
;         xor       ax,ax
;         xchg      ax,cs:[edikeym]          ; znak od my®i
;         or        ax,ax
;         jnz       inpkey3                  ; byl znak v bufferu my®i
         mov       ah,cs:[keyinp]           ; k¢d pro áten° znaku z kl†vesnice
inpkey0: int       16h                      ; áten° znaku z kl†vesnice
         pushf
         or        ah,ah                    ; je k¢d kl†vesy s Alt ?
         je        inpkey2                  ; je k¢d s Alt
         cmp       al,0e0h                  ; je ©°dic° k¢d s E0 ?
         je        inpkey1                  ; je ©°dic° k¢d s E0
         cmp       al,0f0h                  ; je ©°dic° k¢d s F0 ?
         jne       inpkey2                  ; nen° ©°dic° k¢d s F0
inpkey1: xor       al,al                    ; normalizace na k¢d 00
inpkey2: popf
inpkey3: ret

; -----------------------------------------------------------------------------
public   mouseon

mouseon:                                  ;* zapnut° zobrazen° my®i

         ret

; -----------------------------------------------------------------------------
public   mouseoff

mouseoff:                                 ;* vypnut° zobrazen° my®i

         ret

; -----------------------------------------------------------------------------
public   mouseget

; Pouëit° tlaá°tek:  levÇ=veden° kurzoru, pravÇ=ESC,oznaáen°


mouseget:                                 ;* poskytnut° stavu my®i
                                            ; VùSTUP:BX=funkce
                                            ;           0=nen° ë†dnÇ tlaá°tko
                                            ;           1=levÇ tlaá°tko drë°
                                            ;           2=pravÇ tlaá°tko drë°
                                            ;           3=st©edn° tlaá°tko drë°
                                            ;           4=levÇ tlaá°tko 1x
                                            ;           5=pravÇ tlaá°tko 1x
                                            ;           6=st©edn° tlaá°tko 1x
                                            ;           7=levÇ tlaá°tko 2x
                                            ;           8=pravÇ tlaá°tko 2x
                                            ;           9=st©edn° tlaá°tko 2x
                                            ;          10=uvolnàn° levÇho tlaá.
                                            ;          11=uvolnàn° pravÇho tlaá.
                                            ;          12=uvolnàn° prost©. tlaá.
                                            ;        ZY=nen° ë†dnÇ tlaá°tko

         xor       bx,bx
         ret

; -----------------------------------------------------------------------------
public   mousemen

mousemen:                                 ;* funkán° kl†vesy s my®°
                                            ; VSTUP: BL=k¢d tlaá°tek
                                            ; VùSTUP: AX=k¢d funkán° kl†vesy
                                            ;         CY=nen° funkán° kl†vesa


         xor       ax,ax
         stc
         ret

; -----------------------------------------------------------------------------
public   kurzout

kurzout:                                  ;* vypnut° zobrazen° kurzoru

         pushf
         push      ax
         push      cx
         push      dx
         xor       al,al
         call      getdispl                 ; poáet ©†dkñ displeje
         inc       dh                       ; ©†dek za rohem
         xor       dl,dl
         call      outch1                   ; nastaven° pozice kurzoru
         pop       dx
         pop       cx
         pop       ax
         popf
         ret

; -----------------------------------------------------------------------------
public   outhexw,outhexb

outhexw:                                  ;* zobrazen° slova HEX
                                            ; VSTUP: AX=slovo k zobrazen°
                                            ;        DX=pozice
         push      ax
         mov       al,ah
         call      outhexb                  ; zobrazen° vy®®°ho bajtu
         pop       ax

outhexb:                                  ;* zobrazen° bajtu HEX
                                            ; VSTUP: AL=bajt k zobrazen°
                                            ;        DX=pozice
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      outhexch
         pop       ax

outhexch:push      ax
         and       al,0fh
         cmp       al,10
         jb        outhxch1
         add       al,7
outhxch1:add       al,"0"
         call      outch1
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   outch1,outch10

outch1:                                   ;* vòstup 1 znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        AL=ASCII znak

         push      cx                       ; £schova CX
         mov       cx,1                     ; poáet - 1 znak
         call      outch                    ; zobrazen° 1 znaku
         pop       cx                       ; n†vrat CX
         ret

outch10:                                  ;* vòstup 1 znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        AL=ASCII znak

         push      cx                       ; £schova CX
         mov       cx,1                     ; poáet - 1 znak
         call      outch0                   ; zobrazen° 1 znaku
         pop       cx                       ; n†vrat CX
         ret

; -----------------------------------------------------------------------------
public   outch01,outch011

outch01:                                  ;* vòstup znaku na displej VRAM
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        BL=atribut barvy

         push      cx
         push      dx
         push      es
         cmp       dl,79                    ; je p©ekroáena pozice ?
         ja        outch011                 ; pozice p©ekroáena
         cmp       dh,cs:[displ]            ; je p©ekroáen ©†dek ?
         ja        outch011                 ; ©†dek p©ekroáen
         les       di,dword ptr cs:[adrvram]; adresa zaá†tku VRAM
         push      ax
         mov       al,80
         mul       dh
         xor       dh,dh
         add       ax,dx
         add       ax,ax
         add       di,ax
         pop       ax
         mov       ah,bl
         rep       stosw
outch011:pop       es
         pop       dx
         pop       cx
         ret


public   outch02

outch02:                                  ;* vòstup znaku na displej BIOS
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        BL=atribut barvy

         push      cx
         push      dx
         mov       bh,cs:[aktpage]          ; aktivn° str†nka
         and       bh,1
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         push      ax
         push      cx
         push      bx
         int       10h                      ; nastaven° pozice kurzoru
         pop       bx
         pop       cx
         pop       ax
         jcxz      outch022
         mov       ah,9                     ; funkce z†pisu znaku s atributem
         int       10h                      ; z†pis znaku
outch022:pop       dx
         pop       cx
         ret


public   outch,outch0,setout

outch:                                    ;* vòstup znaku na displej (- ©°dic°)
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        DS=datovò segment

         cmp       al,32                    ; je nastaven° atributu ?
         jae       outch0                   ; nen° nastaven° atributu - tisk
         push      ax                       ; £schova AX (znak k tisku)
         push      bx                       ; £schova BX
         push      cx
         push      dx
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      bp                       ; £schova BP
         or        al,al                    ; je pouze nastaven° kurzoru ?
         jz        outch12                  ; je nastaven° kurzoru
         xor       ah,ah                    ; AH <- 0
         mov       si,offset col1-1         ; tabulka barev
         add       si,ax                    ; adresa barvy
         mov       al,cs:[si]               ; naáten° barvy
         mov       cs:[color],al            ; nastaven° atributu barvy
         jmp       short outch13            ; n†vrat z obsluhy
                                          ;* nastaven° kurzoru
outch12: mov       bh,cs:[aktpage]          ; aktivn° videostr†nka
         and       bh,1
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         int       10h                      ; nastaven° pozice kurzoru
outch13: pop       bp                       ; n†vrat BP
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx
         pop       cx
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX (znak k tisku)
         ret

outch0:                                   ;* vòstup znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        DS=datovò segment

         push      es
         push      bx                       ; £schova BX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      bp                       ; £schova BP
         push      ax                       ; £schova AX (znak k tisku)
         mov       bl,cs:[color]            ; aktivn° barva (atribut)
setout:  call      outch01                  ; vòstup znaku
         add       dl,cl                    ; zvò®en° pozice kurzoru
         pop       ax                       ; n†vrat AX (znak k tisku)
         pop       bp                       ; n†vrat BP
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       bx                       ; n†vrat BX
         pop       es
         ret

; -----------------------------------------------------------------------------
public   outtxt

outtxt:                                   ;* vòstup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datovò segment)
         push      ax
outtxt0: lodsb                              ; naáten° znaku k tisku
         or        al,al                    ; je koncovò bajt 0 ?
         jz        outtx1                   ; je koncovò bajt 0 - konec
         cmp       al,31                    ; je konec ©†dku ?
         je        outtx1                   ; je konec ©†dku
         call      outch1                   ; tisk 1 znaku
         jmp       short outtxt0            ; tisk dal®°ho znaku
outtx1:  pop       ax
         ret

; -----------------------------------------------------------------------------
public   outtx0

outtx0:                                   ;* vòstup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datovò segment)

         push      ax
outtx2:  lodsb                              ; naáten° znaku k tisku
         or        al,al                    ; je koncovò bajt 0 ?
         jz        outtx3                   ; je koncovò bajt 0 - konec
         cmp       al,31                    ; je konec ©†dku ?
         je        outtx3                   ; je konec ©†dku
         call      outch10                  ; tisk 1 znaku
         jmp       short outtx2             ; tisk dal®°ho znaku
outtx3:  pop       ax
         ret

; -----------------------------------------------------------------------------
public   wrolldown,wrollup

wrollup:                                  ;* rolov†n° okna nahoru
                                            ; VSTUP: BP=ukazatel okna
                                            ;        AL=poáet ©†dek k rolov†n°

         call      testaktw                 ; je okno aktivn° ?
         jnc       wrollup0                 ; okno je aktivn°
         ret

wrolldown:                                ;* rolov†n° okna dolñ
                                            ; VSTUP: BP=ukazatel okna
                                            ;        AL=poáet ©†dek k rolov†n°
         call      testaktw                 ; je okno aktivn° ?
         jnc       wrolldn0                 ; okno je aktivn°
         ret

wrollup0:                                 ;* rolov†n° okna nahoru
         push      ax
         mov       ah,6                     ; rolov†n° okna nahoru
         jmp       short wrolldn1           ; rolov†n° okna


wrolldn0:                                 ;* rolov†n° okna dolñ
         push      ax
         mov       ah,7                     ; rolov†n° dolñ
wrolldn1:call      wrolldnup                ; rolov†n° okna
         pop       ax
         ret


wrolldnup:                                ;* rolov†n° okna
                                            ; VSTUP: AH=7 dolñ
                                            ;        AH=6 nahoru

         push      bp
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         call      mouseoff                 ; vypnut° my®i
         mov       cl,ds:[bp+3]             ; poá†teán° pozice okna
         mov       dl,cl
         add       dl,39
         mov       bh,ds:[col1]
         mov       ch,4
         call      getendl                  ; poskytnut° posledn°ho ©†dku
         dec       dh
         int       10h
         call      mouseon                  ; zapnut° my®i
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   getdispcx

getdispcx:                                ;* áten° á°sla posledn°ho ©†dku
                                            ; VùSTUP: CX=á°slo posledn°ho ©†dku
         xor       cx,cx
         mov       cl,cs:[displ]
         ret

; -----------------------------------------------------------------------------
public   getdispl

getdispl:                                 ;* áten° á°sla posledn°ho ©†dku
                                            ; VùSTUP: DH=á°slo posledn°ho ©†dku
         mov       dh,cs:[displ]
         ret

; -----------------------------------------------------------------------------
public   getpocl

getpocl:                                  ;* poskytnut° poátu ©†dkñ bez n†povàdy
                                            ; VùSTUP: CX=poáet ©†dkñ
         xor       cx,cx
         mov       cl,cs:[displ]
         call      testakth                 ; je n†povàda aktivn° ?
         jc        getpocl2                 ; n†povàda nen° aktivn°
         dec       cx                       ; sn°ëen° poátu ©†dkñ
getpocl2:ret

; -----------------------------------------------------------------------------
public   getendl

getendl:                                  ;* áten° á°sla ©†dku konce okna
                                            ; VùSTUP: DH=á°slo ©†dku konce okna

         call      getdispl                 ; poskytnut° á°sla posledn°ho ©†dku
         dec       dh
         call      testakth                 ; je n†povàda aktivn° ?
         jc        getend2                  ; n†povàda nen° aktivn°
         dec       dh                       ; sn°ëen° á°sla ©†dku
getend2: ret

; -----------------------------------------------------------------------------
public   getnuml

getnuml:                                  ;* áten° poátu ©†dkñ souborñ
                                            ; VùSTUP: CX=poáet ©†dkñ se soubory

         push      dx
         call      getendl                  ; á°slo posledn°ho ©†dku okna
         xor       cx,cx
         mov       cl,dh
         sub       cl,4                     ; odeáten° okrajñ okna
         pop       dx
         ret

; -----------------------------------------------------------------------------
public   getnumf

getnumf:                                  ;* zji®tàn° poátu souborñ na displeji
                                            ; VùSTUP: CX=poáet souborñ v oknà

         call      getnuml                  ; zji®tàn° poátu ©†dkñ souborñ
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jz        getnumf1                 ; je plnÇ zobrazen° okna
         push      ax
         mov       ax,cx
         add       cx,ax
         add       cx,ax
         pop       ax
getnumf1:ret

; -----------------------------------------------------------------------------
public   testsetwn

testsetwn:                                ;* test nastaven° neaktivn°ho okna
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: ZY=je plnÇ zobrazen° okna
         push      bp
         call      getnakt
         call      testsetw
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   testsetw

testsetw:                                 ;* test nastaven° okna
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: ZY=je plnÇ zobrazen° okna

         test      byte ptr cs:[bp+29],1    ; je trojsloupcovÇ zobrazen° ?
         ret

; -----------------------------------------------------------------------------
public   testakth

testakth:                                 ;* test, zda je n†povàda aktivn°
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: CY=n†povàda nen° aktivn°

         test      byte ptr cs:[flags],4    ; je n†povàda aktivn° ?
         jnz       testakth1                ; n†povàda je aktivn°
         stc                                ; p©°znak - n†povàda nen° aktivn°
testakth1:ret

; -----------------------------------------------------------------------------
public   testaktwn

testaktwn:                                ;* test, zda je neaktivn° okno zapnutÇ
                                            ; VùSTUP: CY=okno je vypnutÇ
         push      bp
         call      getnakt                  ; poskytnut° neatkivn°ho okna
         call      testaktw                 ; test, jestli je okno zapnutÇ
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   testaktw

testaktw:                                 ;* test, zda je okno zapnutÇ
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: CY=okno je vypnutÇ

         test      byte ptr cs:[flags],2    ; jsou vypnuta obà okna ?
         jnz       testaktw1                ; obà okna jsou vypnuta
         test      byte ptr cs:[bp+0],1     ; p©°znak okna
         jnz       testaktw2                ; okno je zapnutÇ
testaktw1:stc                               ; p©°znak - okno je vypnutÇ
testaktw2:ret

; -----------------------------------------------------------------------------
public   getakt

getakt:                                   ;* poskytnut° adresy aktivn°ho okna
                                            ; VùSTUP: BP=adresa tabulky okna

         test      byte ptr cs:[flags],1    ; je aktivn° levÇ okno ?
         lea       bp,[tabl]                ; adresa levÇho okna
         jnz       getakt1                  ; je levÇ okno
         lea       bp,[tabr]                ; adresa pravÇho okna
getakt1: ret

; -----------------------------------------------------------------------------
public   getnakt

getnakt:                                  ;* poskytnut° adresy neaktivn°ho okna
                                            ; VùSTUP: BP=adresa tabulky okna

         test      byte ptr cs:[flags],1    ; je aktivn° levÇ okno ?
         lea       bp,[tabl]                ; adresa levÇho okna
         jz        getnakt1                 ; je pravÇ okno
         lea       bp,[tabr]                ; adresa pravÇho okna
getnakt1:ret

; -----------------------------------------------------------------------------
public   testakt

testakt:                                  ;* test, zda jde o aktivn° okno
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; VùSTUP: ZY=je aktivn°
         push      ax
         push      bp
         call      getakt                   ; nastaven° adresy aktivn°ho okna
         mov       ax,bp                    ; adresa aktivn°ho okna
         pop       bp
         cmp       ax,bp                    ; je to aktivn° okno ?
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   testexe

testexe:                                  ;* test, zda je soubor EXE, COM, BAT
                                            ; VSTUP: DS:SI=adresa poloëky
                                            ; VùSTUP: ZY=je spustitelnò program

         push      di
         push      es
         push      cs
         pop       es
         lea       di,[extent]              ; tabulka extentñ
         call      testexe0                 ; test p©°pony EXE
         je        testexe3                 ; p©°pona nalezena
         call      testexe0                 ; test p©°pony COM
         je        testexe3                 ; p©°pona nalezena
         call      testexe0                 ; test p©°pony BAT
testexe3:pop       es
         pop       di
         ret

testexe0:                                 ;* test, zda je p©°pona ES:DI
                                            ; VSTUP: BP=adresa parametrñ okna
                                            ;        DS:SI=adresa poloëky
                                            ;        ES:DI=adresa p©°pony

         push      di
         push      si
         push      ds
         add       si,9                     ; adresa p©°pony souboru
         cmpsw
         jne       testexe1
         cmpsb
testexe1:pop       ds
         pop       si
         pop       di
         pushf
         add       di,3                     ; adresa n†sleduj°c° p©°pony
         popf
         ret

; -----------------------------------------------------------------------------
;                        Obsluha segmentace pamàti
; -----------------------------------------------------------------------------
public   createseg

createseg:                                ;* vytvo©en° novÇho segmentu dat
                                            ; VùSTUP: AL=á°slo p©idàl. segmentu
                                            ;         CY=nen° voln† poloëka

         push      cx
         push      bx                       ; £schova BX
         xor       al,al                    ; á°taá poloëek
         lea       bx,cs:[seznseg]          ; adresa seznamu segmentñ
         mov       cx,offset(seznseg0-seznseg)/2 ; poáet poloëek v seznamu
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
public   maxsize
maxsize:                                  ;* nastaven° maxim†ln° velikosti segm.
                                            ; VSTUP: AL=á°slo segmentu
                                            ; VùSTUP: BX=velikost segmentu

         mov       bx,cs:[segend]           ; segment konce pamàti
         sub       bx,cs:[topseg]           ; velikost volnÇ pamàti
         jbe       maxsize2
         cmp       bx,0effh
         jb        maxsize1
         mov       bx,0effh
maxsize1:shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1
         call      modiseg                  ; modifikace segmentu
maxsize2:call      getssize                 ; poskytnut° velikosti segmentu
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
         mov       cx,offset(seznseg0-seznseg)/2 ; poáet poloëek v seznamu
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
         mov       cx,offset(seznseg0-seznseg)/2 ; poáet poloëek v seznamu
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
         xor       bl,bl                    ; BL <- 0; zñstane pouze vy®®° bajt
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
         xchg      cx,bx                    ; BX<-adresa semgentu, CX<-velikost
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
         ret

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


;         push      bx
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;         call      dword ptr cs:[countryh]  ; p©evod znaku na velkÇ p°smeno
;         pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         mov       bl,al
;         pop       ax
;         mov       al,bl
;         pop       bx
;         ret

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
testkon1:call      readtest                 ; naáten° dal®° á°slice
         jc        testkon2                 ; nen° jië dal®° á°slice
         mov       dh,dl                    ; p©edposledn° á°slice
         mov       dl,al                    ; posledn° á°slice
         jmp       short testkon1           ; naáten° dal®° á°slice
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
         call      lowcase                  ; p©evod na malÇ p°smeno
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
         call      lowcase                  ; p©evod na malÇ p°smeno
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
public   aktdir,aktdir1,aktdir2

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


         include   dos0dat.asm              ; data programu

public   endshell
endshell label     word                      ; adresa konce programu

code     ends

         END

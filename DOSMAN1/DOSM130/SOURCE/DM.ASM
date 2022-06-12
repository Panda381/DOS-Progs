
; modul DOSM.ASM - hlavn° á†st programu

; *****************************************************************************
;
;                          Hlavn° á†st programu
;
; *****************************************************************************
code     segment   public
         assume    cs:code,ds:code

upver    label     near                     ; p©ep°naá pro vy®®° verzi

extrn    deinit:near,storecnf:near,datarez:byte,execx:near,segrez:word
extrn    parrez:byte,conf2e:byte,init:near,old22:dword,loadpath:near
extrn    aktdir:near,dekfile:near,iniedis:near,aktedis:near,deledis:near
extrn    getmax:near,createseg:near,delseg:near,getseg:near,getssize:near
extrn    nextseg:near,predseg:near,modiseg:near,tisknm2s:near,tisknm20:near
extrn    tisknm0:near,setspc:near,setnul:near,setfre:near,deknumx:near
extrn    deknum:near,deknum0:near,deknum9:near,deknum8:near,deknum7:near
extrn    deknum6:near,deknum5:near,deknum4:near,deknum3:near,deknum2:near
extrn    center:near,lensi0:near,lensi:near,lendi:near,konvfnt:near
extrn    lowcase0:near,lowcase:near,highcase0:near,highcase:near,transtxt:near
extrn    comptxt:near,setkonc:near,testkonc:near

public   main,mainx,konec0

         include   dmuse.asm                ; z†kladn° ovl†d†n° programu

main:                                     ;* hlavn° obsluha programu
         sti
         call      uziv                     ; hlavn° program - povely
mainx:                                    ;* proveden° p©°kazu, n†vrat
         sti
         call      deinit                   ; odinstalov†n° programu
         call      storecnf                 ; uloëen° konfigurace

         push      ax
         or        byte ptr cs:[parrez],2   ; p©°znak opakovanÇho startu
         mov       al,cs:[conf2]
         mov       cs:[conf2e],al
         pop       ax

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
         sti
         int       28h                      ; obsluha áek†n° na kl†vesnici
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
inpkey0: sti
         int       16h                      ; áten° znaku z kl†vesnice
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

         push      ax
         mov       ax,1
mouseon0:pushf
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         test      byte ptr cs:[config],40h ; je my® instalov†na ?
         jz        mouseon1                 ; my® nen° instalov†na
         sti
         int       33h                      ; zapnut° zobrazen° my®i
mouseon1:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         popf
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   mouseoff

mouseoff:                                 ;* vypnut° zobrazen° my®i

         push      ax
         mov       ax,2
         jmp       short mouseon0

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
         test      byte ptr cs:[config],40h ; je my® instalov†na ?
         jz        mousegt1                 ; my® nen° instalov†na

         pushf
         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       ax,3
         sti
         int       33h                      ; poskytnut° pozice my®i
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; pozice / 8
         mov       byte ptr cs:[mousepoz],cl ; pozice na displeji
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; ©†dek / 8
         mov       byte ptr cs:[mousepoz+1],dl ; ©†dek s kurzorem my®i
                                          ;* zji®tàn° tlaá°tek
         test      bl,4                     ; je st©edn° tlaá°tko ?
         jz        mousegt2                 ; nen° st©edn° tlaá°tko
         or        bl,3                     ; nastaven° obou tlaá°tek
mousegt2:and       bl,3                     ; ponech†n° stavu tlaá°tek
         mov       bh,cs:[citmouse]         ; á°taá my®i
         test      bl,2                     ; je pravÇ tlaá°tko ?
         jnz       mousegt6                 ; je pravÇ tlaá°tko
         or        byte ptr cs:[insmouse],1 ; p©°znak, ëe nastaven° nen° uráeno
mousegt6:                                 ;* byla zmàna ?
         cmp       bl,cs:[mousedat]         ; je zmàna tlaá°tek ?
         je        mousegt3                 ; nen° zmàna stavu tlaá°tek
                                          ;* je zmàna tlaá°tek
         ja        mousegt4                 ; nen° uvolnàn° tlaá°tek
                                          ;* je uvolnàn° tlaá°tka
         xchg      bl,cs:[mousedat]         ; n†vrat uvolnànÇho tlaá°tka
         add       bl,9                     ; korekce na k¢d uvolnàn°
         jmp       short mousegt3
mousegt4:                                 ;* je stisknuto dal®° tlaá°tko
         mov       byte ptr cs:[citmouse],6 ; á°taá my®i 1/3 sekundy
         mov       cs:[mousedat],bl         ; uloëen° novÇho stavu tlaá°tek
         add       bl,3                     ; k¢dy pro prvn° stisk
                                          ;* test druhÇho stisku
         or        bh,bh                    ; je prvn° stisk ?
         je        mousegt3                 ; je prvn° stisk
         add       bl,3                     ; k¢dy pro druhò stisk
mousegt3:xor       bh,bh                  ;* nen° zmàna tlaá°tek
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         popf
mousegt1:
         ;cmp       bl,4
         ;jb        mousegt5
         ;cmp       bl,7
         ;jae       mousegt5
         ;cmp       byte ptr cs:[citmouse],3
         ;jb        mousegt5
         ;xor       bl,bl
;mousegt5:
         or        bx,bx
         ret

; -----------------------------------------------------------------------------
public   mousemen

mousemen:                                 ;* funkán° kl†vesy s my®°
                                            ; VSTUP: BL=k¢d tlaá°tek
                                            ; VùSTUP: AX=k¢d funkán° kl†vesy
                                            ;         CY=nen° funkán° kl†vesa


         xor       ax,ax
         push      dx
         call      testakth                 ; je n†povàda aktivn° ?
         jc        mousemn1                 ; n†povàda nen° aktivn°
         mov       dx,cs:[mousepoz]         ; pozice kurzoru my®i
         cmp       dh,cs:[displ]            ; je ©†dek s n†povàdou ?
         jb        mousemn1                 ; nen° ©†dek s n†povàdou
         cmp       bl,11                    ; je stisk pravÇho tlaá°tka ?
         je        mousemn3                 ; je stisk pravÇho tlaá°tka
         mov       dh,40h                   ; p©°znka n†povàdy se SHIFT
         cmp       bl,12                    ; je stisk prost©edn°ho tlaá°tka ?
         je        mousemn4                 ; je volba SHIFT
         cmp       bl,10                    ; je stisk levÇho tlaá°tka ?
         stc
         jne       mousemn1

         mov       dh,cs:[flags]            ; p©°znaky
         and       dh,0c0h                  ; stav p©esmykaáñ
         or        dh,dh
         mov       ax,3b00h                 ; k¢d kl†vesy F1
         jz        mousemn2                 ; je z†kladn° n†povàda
mousemn4:mov       ah,54h                   ; n†povàda se SHIFT
         cmp       dh,40h
         je        mousemn2                 ; je n†povàda se SHIFT
         mov       ah,5eh                   ; n†povàda s CTRL
         cmp       dh,80h
         je        mousemn2                 ; je n†povàda s CTRL
mousemn3:mov       ah,68h                   ; n†povàda s ALT
mousemn2:shr       dl,1
         shr       dl,1
         shr       dl,1                     ; pozice / 8
         add       ah,dl                    ; k¢d fukán° kl†vesy
mousemn1:pop       dx
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
setout:  call      outch02                  ; vòstup znaku (nastavenò ovladaá)
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


         include   dmdat.asm                ; data programu

public   endshell
endshell label     word                      ; adresa konce programu

code     ends

         END

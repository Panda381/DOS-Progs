
; modul DOSM.ASM - hlavn� ��st programu

; *****************************************************************************
;
;                          Hlavn� ��st programu
;
; *****************************************************************************
code     segment   public
         assume    cs:code,ds:code

upver    label     near                     ; p�ep�na� pro vy��� verzi

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

         include   dmuse.asm                ; z�kladn� ovl�d�n� programu

main:                                     ;* hlavn� obsluha programu
         sti
         call      uziv                     ; hlavn� program - povely
mainx:                                    ;* proveden� p��kazu, n�vrat
         sti
         call      deinit                   ; odinstalov�n� programu
         call      storecnf                 ; ulo�en� konfigurace

         push      ax
         or        byte ptr cs:[parrez],2   ; p��znak opakovan�ho startu
         mov       al,cs:[conf2]
         mov       cs:[conf2e],al
         pop       ax

         or        al,al                    ; je operace OK ?
         jnz       konec0                   ; nen� operace OK
                                          ;* zobrazen� p��kazu
         push      cs
         pop       ds                       ; DS <- CS
         mov       es,ds:[segrez]           ; segment rezidentn�ch dat
         push      ax
         cmp       byte ptr es:[80h],2      ; je n�jak� p��kaz ?
         jb        mainx2                   ; nen� ��dn� p��kaz
ifndef   demo
         or        dx,dx                    ; m� se text zobrazit ?
         jz        mainx2                   ; text se nem� zobrazit
endif
         call      getakt                   ; poskytnut� aktivn�ho okna
         mov       si,ds:[bp+4]             ; adresa cesty
mainx1:  lodsb
         or        al,al
         jz        mainx3
         call      mainout                  ; zobrazen� znaku
         jmp       short mainx1
mainx3:  mov       al,">"
         call      mainout
         mov       cl,es:[80h]              ; d�lka textu
         xor       ch,ch
         sub       cl,2
         mov       si,83h                   ; text p��kazu
         jcxz      mainx7                   ; nen� ��dn� znak p��kazu
mainx4:  mov       al,es:[si]
         inc       si
         call      mainout                  ; v�stup znaku
         loop      mainx4
mainx5:
         mov       al,13
         call      mainout
         mov       al,10
         call      mainout
mainx2:                                   ;* p�enesen� dat na rezidentn� modul
         test      byte ptr cs:[flags],8    ; je rezidentn� re�im ?
         jz        mainx8                   ; nen� rezidentn� re�im
         or        byte ptr cs:[parrez],1   ; p��znak rezidentn�ho re�imu
         jmp       short mainx6             ; je rezidentn� provoz
mainx8:  lea       di,[datarez]             ; za��tek rezidentn�ch dat
         lea       si,[inidata]             ; za��tek inicializa�n�ch dat
         lea       cx,[inidend]             ; konec inicializa�n�ch dat
         sub       cx,si                    ; d�lka inicializa�n�ch dat
         rep       movsb                    ; ulo�en� rezidentn�ch dat
mainx6:  mov       ax,es                    ; segment pro ulo�en� dat
         mov       bx,cs                    ; tento segment
         cmp       ax,bx                    ; je tento segment ?
         pop       ax                       ; AL=n�vratov� k�d
         jne       konec0                   ; je ji� v pam�ti

         jmp       execx                    ; proveden� povelu v p��kaz. ��dku

konec0:                                   ;* konec programu (AL=n�vratov� k�d)
         mov       ax,2522h
         lds       dx,cs:[old22]
         int       21h                      ; n�vrat obsluhy INT 22h
         mov       ah,4ch                   ; funkce pro n�vrat z programu
         int       21h                      ; ukon�en� programu

mainx7:  mov       ds:[80h],ch              ; vynulov�n� p��kazu
         jmp       init                     ; nov� inicializace programu

public   mainout
mainout:                                  ;* v�stup znaku
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
;                    Znakov� vstupn�/v�stupn� podprogramy
;
; *****************************************************************************
public   flushkey

flushkey:                                 ;* vypr�zdn�n� bufferu kl�vesnice

         push      ax
         push      cx
         xor       cx,cx                    ; maxim�ln� po�et cykl�
flk1:    call      testkey                  ; test stavu kl�vesnice
         jz        flk2                     ; nen� p�ipraven dal�� znak
         call      inpkey                   ; vstup znaku z kl�vesnice
         loop      flk1                     ; vypr�zdn�n� dal��ho znaku
flk2:    pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   inpkeyf

inpkeyf:                                 ;* vstup znaku s vyprazd�ov�n�m
                                            ; VSTUP: SI=tabulka n�pov�dy
                                            ; V�STUP: AX=znak

         push      cx
         xor       ax,ax                    ; AX <- 0 nulov�n� bufferu
         xchg      ax,cs:[edikey]           ; vyjmut� znaku z bufferu
         or        ax,ax                    ; je n�jak� kl�vesa ?
         jnz       inpkey5                  ; byla n�jak� kl�vesa
inpkey4: call      modihlp                  ; modifikace zobrazen� n�pov�dy
;         call      testalt
;         jnz       inpkey8                  ; kl�vesa ALT je stisknuta
;         mov       byte ptr cs:[numsrc],0   ; zru�en� bufferu znak�
inpkey8: call      testkey                  ; je p�ipraven znak ?
         jz        inpkey4                  ; �ek�n� na p��chod znaku
         call      inpkey                   ; vstup znaku z kl�vesnice
inpkey5: mov       cx,ax                    ; �schova znaku
inpkey6: call      testkey                  ; test p�ipraven� kl�vesy
         jz        inpkey7                  ; nen� p�ipraven ��dn� znak
         cmp       ax,cx                    ; je stejn� znak ?
         jne       inpkey7                  ; nen� stejn� znak
         call      inpkey                   ; vypr�zdn�n� bufferu kl�vesnice
         mov       cs:[edikey],ax           ; �schova znaku
         jmp       short inpkey6            ; dal�� znak
inpkey7: mov       ax,cx                    ; n�vrat znaku
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   testkey

testkey:                                  ;* test kl�vesnice, zda p�i�el znak
                                            ; V�STUP: NZ=znak je p�ipraven
                                            ;         AX=znak

;         mov       ax,cs:[edikeym]
;         or        ax,ax
;         jnz       inpkey3                  ; je p�ipraven znak
         sti
         int       28h                      ; obsluha �ek�n� na kl�vesnici
         mov       ah,cs:[keystat]          ; k�d pro �ten� stavu kl�vesnice
         jmp       short inpkey0            ; �ten� stavu kl�vesnice

; -----------------------------------------------------------------------------
public   inpkey

inpkey:                                  ;* vstup znaku z kl�vesnice
                                           ; V�STUP: AX=znak

;         call      testkey                  ; je p�ipraven znak ?
;         je        inpkey                   ; �ek�n� na p��chod znaku
;         xor       ax,ax
;         xchg      ax,cs:[edikeym]          ; znak od my�i
;         or        ax,ax
;         jnz       inpkey3                  ; byl znak v bufferu my�i
         mov       ah,cs:[keyinp]           ; k�d pro �ten� znaku z kl�vesnice
inpkey0: sti
         int       16h                      ; �ten� znaku z kl�vesnice
         pushf
         or        ah,ah                    ; je k�d kl�vesy s Alt ?
         je        inpkey2                  ; je k�d s Alt
         cmp       al,0e0h                  ; je ��dic� k�d s E0 ?
         je        inpkey1                  ; je ��dic� k�d s E0
         cmp       al,0f0h                  ; je ��dic� k�d s F0 ?
         jne       inpkey2                  ; nen� ��dic� k�d s F0
inpkey1: xor       al,al                    ; normalizace na k�d 00
inpkey2: popf
inpkey3: ret

; -----------------------------------------------------------------------------
public   mouseon

mouseon:                                  ;* zapnut� zobrazen� my�i

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
         test      byte ptr cs:[config],40h ; je my� instalov�na ?
         jz        mouseon1                 ; my� nen� instalov�na
         sti
         int       33h                      ; zapnut� zobrazen� my�i
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

mouseoff:                                 ;* vypnut� zobrazen� my�i

         push      ax
         mov       ax,2
         jmp       short mouseon0

; -----------------------------------------------------------------------------
public   mouseget

; Pou�it� tla��tek:  lev�=veden� kurzoru, prav�=ESC,ozna�en�


mouseget:                                 ;* poskytnut� stavu my�i
                                            ; V�STUP:BX=funkce
                                            ;           0=nen� ��dn� tla��tko
                                            ;           1=lev� tla��tko dr��
                                            ;           2=prav� tla��tko dr��
                                            ;           3=st�edn� tla��tko dr��
                                            ;           4=lev� tla��tko 1x
                                            ;           5=prav� tla��tko 1x
                                            ;           6=st�edn� tla��tko 1x
                                            ;           7=lev� tla��tko 2x
                                            ;           8=prav� tla��tko 2x
                                            ;           9=st�edn� tla��tko 2x
                                            ;          10=uvoln�n� lev�ho tla�.
                                            ;          11=uvoln�n� prav�ho tla�.
                                            ;          12=uvoln�n� prost�. tla�.
                                            ;        ZY=nen� ��dn� tla��tko

         xor       bx,bx
         test      byte ptr cs:[config],40h ; je my� instalov�na ?
         jz        mousegt1                 ; my� nen� instalov�na

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
         int       33h                      ; poskytnut� pozice my�i
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; pozice / 8
         mov       byte ptr cs:[mousepoz],cl ; pozice na displeji
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; ��dek / 8
         mov       byte ptr cs:[mousepoz+1],dl ; ��dek s kurzorem my�i
                                          ;* zji�t�n� tla��tek
         test      bl,4                     ; je st�edn� tla��tko ?
         jz        mousegt2                 ; nen� st�edn� tla��tko
         or        bl,3                     ; nastaven� obou tla��tek
mousegt2:and       bl,3                     ; ponech�n� stavu tla��tek
         mov       bh,cs:[citmouse]         ; ��ta� my�i
         test      bl,2                     ; je prav� tla��tko ?
         jnz       mousegt6                 ; je prav� tla��tko
         or        byte ptr cs:[insmouse],1 ; p��znak, �e nastaven� nen� ur�eno
mousegt6:                                 ;* byla zm�na ?
         cmp       bl,cs:[mousedat]         ; je zm�na tla��tek ?
         je        mousegt3                 ; nen� zm�na stavu tla��tek
                                          ;* je zm�na tla��tek
         ja        mousegt4                 ; nen� uvoln�n� tla��tek
                                          ;* je uvoln�n� tla��tka
         xchg      bl,cs:[mousedat]         ; n�vrat uvoln�n�ho tla��tka
         add       bl,9                     ; korekce na k�d uvoln�n�
         jmp       short mousegt3
mousegt4:                                 ;* je stisknuto dal�� tla��tko
         mov       byte ptr cs:[citmouse],6 ; ��ta� my�i 1/3 sekundy
         mov       cs:[mousedat],bl         ; ulo�en� nov�ho stavu tla��tek
         add       bl,3                     ; k�dy pro prvn� stisk
                                          ;* test druh�ho stisku
         or        bh,bh                    ; je prvn� stisk ?
         je        mousegt3                 ; je prvn� stisk
         add       bl,3                     ; k�dy pro druh� stisk
mousegt3:xor       bh,bh                  ;* nen� zm�na tla��tek
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

mousemen:                                 ;* funk�n� kl�vesy s my��
                                            ; VSTUP: BL=k�d tla��tek
                                            ; V�STUP: AX=k�d funk�n� kl�vesy
                                            ;         CY=nen� funk�n� kl�vesa


         xor       ax,ax
         push      dx
         call      testakth                 ; je n�pov�da aktivn� ?
         jc        mousemn1                 ; n�pov�da nen� aktivn�
         mov       dx,cs:[mousepoz]         ; pozice kurzoru my�i
         cmp       dh,cs:[displ]            ; je ��dek s n�pov�dou ?
         jb        mousemn1                 ; nen� ��dek s n�pov�dou
         cmp       bl,11                    ; je stisk prav�ho tla��tka ?
         je        mousemn3                 ; je stisk prav�ho tla��tka
         mov       dh,40h                   ; p��znka n�pov�dy se SHIFT
         cmp       bl,12                    ; je stisk prost�edn�ho tla��tka ?
         je        mousemn4                 ; je volba SHIFT
         cmp       bl,10                    ; je stisk lev�ho tla��tka ?
         stc
         jne       mousemn1

         mov       dh,cs:[flags]            ; p��znaky
         and       dh,0c0h                  ; stav p�esmyka��
         or        dh,dh
         mov       ax,3b00h                 ; k�d kl�vesy F1
         jz        mousemn2                 ; je z�kladn� n�pov�da
mousemn4:mov       ah,54h                   ; n�pov�da se SHIFT
         cmp       dh,40h
         je        mousemn2                 ; je n�pov�da se SHIFT
         mov       ah,5eh                   ; n�pov�da s CTRL
         cmp       dh,80h
         je        mousemn2                 ; je n�pov�da s CTRL
mousemn3:mov       ah,68h                   ; n�pov�da s ALT
mousemn2:shr       dl,1
         shr       dl,1
         shr       dl,1                     ; pozice / 8
         add       ah,dl                    ; k�d fuk�n� kl�vesy
mousemn1:pop       dx
         ret

; -----------------------------------------------------------------------------
public   kurzout

kurzout:                                  ;* vypnut� zobrazen� kurzoru

         pushf
         push      ax
         push      cx
         push      dx
         xor       al,al
         call      getdispl                 ; po�et ��dk� displeje
         inc       dh                       ; ��dek za rohem
         xor       dl,dl
         call      outch1                   ; nastaven� pozice kurzoru
         pop       dx
         pop       cx
         pop       ax
         popf
         ret

; -----------------------------------------------------------------------------
public   outhexw,outhexb

outhexw:                                  ;* zobrazen� slova HEX
                                            ; VSTUP: AX=slovo k zobrazen�
                                            ;        DX=pozice
         push      ax
         mov       al,ah
         call      outhexb                  ; zobrazen� vy���ho bajtu
         pop       ax

outhexb:                                  ;* zobrazen� bajtu HEX
                                            ; VSTUP: AL=bajt k zobrazen�
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

outch1:                                   ;* v�stup 1 znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        AL=ASCII znak

         push      cx                       ; �schova CX
         mov       cx,1                     ; po�et - 1 znak
         call      outch                    ; zobrazen� 1 znaku
         pop       cx                       ; n�vrat CX
         ret

outch10:                                  ;* v�stup 1 znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        AL=ASCII znak

         push      cx                       ; �schova CX
         mov       cx,1                     ; po�et - 1 znak
         call      outch0                   ; zobrazen� 1 znaku
         pop       cx                       ; n�vrat CX
         ret

; -----------------------------------------------------------------------------
public   outch01,outch011

outch01:                                  ;* v�stup znaku na displej VRAM
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=po�et znak�
                                            ;        AL=ASCII znak
                                            ;        BL=atribut barvy

         push      cx
         push      dx
         push      es
         cmp       dl,79                    ; je p�ekro�ena pozice ?
         ja        outch011                 ; pozice p�ekro�ena
         cmp       dh,cs:[displ]            ; je p�ekro�en ��dek ?
         ja        outch011                 ; ��dek p�ekro�en
         les       di,dword ptr cs:[adrvram]; adresa za��tku VRAM
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

outch02:                                  ;* v�stup znaku na displej BIOS
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=po�et znak�
                                            ;        AL=ASCII znak
                                            ;        BL=atribut barvy

         push      cx
         push      dx
         mov       bh,cs:[aktpage]          ; aktivn� str�nka
         and       bh,1
         mov       ah,2                     ; funkce nastaven� pozice kurzoru
         push      ax
         push      cx
         push      bx
         int       10h                      ; nastaven� pozice kurzoru
         pop       bx
         pop       cx
         pop       ax
         jcxz      outch022
         mov       ah,9                     ; funkce z�pisu znaku s atributem
         int       10h                      ; z�pis znaku
outch022:pop       dx
         pop       cx
         ret


public   outch,outch0,setout

outch:                                    ;* v�stup znaku na displej (- ��dic�)
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=po�et znak�
                                            ;        AL=ASCII znak
                                            ;        DS=datov� segment

         cmp       al,32                    ; je nastaven� atributu ?
         jae       outch0                   ; nen� nastaven� atributu - tisk
         push      ax                       ; �schova AX (znak k tisku)
         push      bx                       ; �schova BX
         push      cx
         push      dx
         push      si                       ; �schova SI
         push      di                       ; �schova DI
         push      bp                       ; �schova BP
         or        al,al                    ; je pouze nastaven� kurzoru ?
         jz        outch12                  ; je nastaven� kurzoru
         xor       ah,ah                    ; AH <- 0
         mov       si,offset col1-1         ; tabulka barev
         add       si,ax                    ; adresa barvy
         mov       al,cs:[si]               ; na�ten� barvy
         mov       cs:[color],al            ; nastaven� atributu barvy
         jmp       short outch13            ; n�vrat z obsluhy
                                          ;* nastaven� kurzoru
outch12: mov       bh,cs:[aktpage]          ; aktivn� videostr�nka
         and       bh,1
         mov       ah,2                     ; funkce nastaven� pozice kurzoru
         int       10h                      ; nastaven� pozice kurzoru
outch13: pop       bp                       ; n�vrat BP
         pop       di                       ; n�vrat DI
         pop       si                       ; n�vrat SI
         pop       dx
         pop       cx
         pop       bx                       ; n�vrat BX
         pop       ax                       ; n�vrat AX (znak k tisku)
         ret

outch0:                                   ;* v�stup znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=po�et znak�
                                            ;        AL=ASCII znak
                                            ;        DS=datov� segment

         push      es
         push      bx                       ; �schova BX
         push      si                       ; �schova SI
         push      di                       ; �schova DI
         push      bp                       ; �schova BP
         push      ax                       ; �schova AX (znak k tisku)
         mov       bl,cs:[color]            ; aktivn� barva (atribut)
setout:  call      outch02                  ; v�stup znaku (nastaven� ovlada�)
         add       dl,cl                    ; zv��en� pozice kurzoru
         pop       ax                       ; n�vrat AX (znak k tisku)
         pop       bp                       ; n�vrat BP
         pop       di                       ; n�vrat DI
         pop       si                       ; n�vrat SI
         pop       bx                       ; n�vrat BX
         pop       es
         ret

; -----------------------------------------------------------------------------
public   outtxt

outtxt:                                   ;* v�stup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datov� segment)
         push      ax
outtxt0: lodsb                              ; na�ten� znaku k tisku
         or        al,al                    ; je koncov� bajt 0 ?
         jz        outtx1                   ; je koncov� bajt 0 - konec
         cmp       al,31                    ; je konec ��dku ?
         je        outtx1                   ; je konec ��dku
         call      outch1                   ; tisk 1 znaku
         jmp       short outtxt0            ; tisk dal��ho znaku
outtx1:  pop       ax
         ret

; -----------------------------------------------------------------------------
public   outtx0

outtx0:                                   ;* v�stup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datov� segment)

         push      ax
outtx2:  lodsb                              ; na�ten� znaku k tisku
         or        al,al                    ; je koncov� bajt 0 ?
         jz        outtx3                   ; je koncov� bajt 0 - konec
         cmp       al,31                    ; je konec ��dku ?
         je        outtx3                   ; je konec ��dku
         call      outch10                  ; tisk 1 znaku
         jmp       short outtx2             ; tisk dal��ho znaku
outtx3:  pop       ax
         ret

; -----------------------------------------------------------------------------
public   wrolldown,wrollup

wrollup:                                  ;* rolov�n� okna nahoru
                                            ; VSTUP: BP=ukazatel okna
                                            ;        AL=po�et ��dek k rolov�n�

         call      testaktw                 ; je okno aktivn� ?
         jnc       wrollup0                 ; okno je aktivn�
         ret

wrolldown:                                ;* rolov�n� okna dol�
                                            ; VSTUP: BP=ukazatel okna
                                            ;        AL=po�et ��dek k rolov�n�
         call      testaktw                 ; je okno aktivn� ?
         jnc       wrolldn0                 ; okno je aktivn�
         ret

wrollup0:                                 ;* rolov�n� okna nahoru
         push      ax
         mov       ah,6                     ; rolov�n� okna nahoru
         jmp       short wrolldn1           ; rolov�n� okna


wrolldn0:                                 ;* rolov�n� okna dol�
         push      ax
         mov       ah,7                     ; rolov�n� dol�
wrolldn1:call      wrolldnup                ; rolov�n� okna
         pop       ax
         ret


wrolldnup:                                ;* rolov�n� okna
                                            ; VSTUP: AH=7 dol�
                                            ;        AH=6 nahoru

         push      bp
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         call      mouseoff                 ; vypnut� my�i
         mov       cl,ds:[bp+3]             ; po��te�n� pozice okna
         mov       dl,cl
         add       dl,39
         mov       bh,ds:[col1]
         mov       ch,4
         call      getendl                  ; poskytnut� posledn�ho ��dku
         dec       dh
         int       10h
         call      mouseon                  ; zapnut� my�i
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   getdispcx

getdispcx:                                ;* �ten� ��sla posledn�ho ��dku
                                            ; V�STUP: CX=��slo posledn�ho ��dku
         xor       cx,cx
         mov       cl,cs:[displ]
         ret

; -----------------------------------------------------------------------------
public   getdispl

getdispl:                                 ;* �ten� ��sla posledn�ho ��dku
                                            ; V�STUP: DH=��slo posledn�ho ��dku
         mov       dh,cs:[displ]
         ret

; -----------------------------------------------------------------------------
public   getpocl

getpocl:                                  ;* poskytnut� po�tu ��dk� bez n�pov�dy
                                            ; V�STUP: CX=po�et ��dk�
         xor       cx,cx
         mov       cl,cs:[displ]
         call      testakth                 ; je n�pov�da aktivn� ?
         jc        getpocl2                 ; n�pov�da nen� aktivn�
         dec       cx                       ; sn��en� po�tu ��dk�
getpocl2:ret

; -----------------------------------------------------------------------------
public   getendl

getendl:                                  ;* �ten� ��sla ��dku konce okna
                                            ; V�STUP: DH=��slo ��dku konce okna

         call      getdispl                 ; poskytnut� ��sla posledn�ho ��dku
         dec       dh
         call      testakth                 ; je n�pov�da aktivn� ?
         jc        getend2                  ; n�pov�da nen� aktivn�
         dec       dh                       ; sn��en� ��sla ��dku
getend2: ret

; -----------------------------------------------------------------------------
public   getnuml

getnuml:                                  ;* �ten� po�tu ��dk� soubor�
                                            ; V�STUP: CX=po�et ��dk� se soubory

         push      dx
         call      getendl                  ; ��slo posledn�ho ��dku okna
         xor       cx,cx
         mov       cl,dh
         sub       cl,4                     ; ode�ten� okraj� okna
         pop       dx
         ret

; -----------------------------------------------------------------------------
public   getnumf

getnumf:                                  ;* zji�t�n� po�tu soubor� na displeji
                                            ; V�STUP: CX=po�et soubor� v okn�

         call      getnuml                  ; zji�t�n� po�tu ��dk� soubor�
         call      testsetw                 ; je pln� zobrazen� okna ?
         jz        getnumf1                 ; je pln� zobrazen� okna
         push      ax
         mov       ax,cx
         add       cx,ax
         add       cx,ax
         pop       ax
getnumf1:ret

; -----------------------------------------------------------------------------
public   testsetwn

testsetwn:                                ;* test nastaven� neaktivn�ho okna
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; V�STUP: ZY=je pln� zobrazen� okna
         push      bp
         call      getnakt
         call      testsetw
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   testsetw

testsetw:                                 ;* test nastaven� okna
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; V�STUP: ZY=je pln� zobrazen� okna

         test      byte ptr cs:[bp+29],1    ; je trojsloupcov� zobrazen� ?
         ret

; -----------------------------------------------------------------------------
public   testakth

testakth:                                 ;* test, zda je n�pov�da aktivn�
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; V�STUP: CY=n�pov�da nen� aktivn�

         test      byte ptr cs:[flags],4    ; je n�pov�da aktivn� ?
         jnz       testakth1                ; n�pov�da je aktivn�
         stc                                ; p��znak - n�pov�da nen� aktivn�
testakth1:ret

; -----------------------------------------------------------------------------
public   testaktwn

testaktwn:                                ;* test, zda je neaktivn� okno zapnut�
                                            ; V�STUP: CY=okno je vypnut�
         push      bp
         call      getnakt                  ; poskytnut� neatkivn�ho okna
         call      testaktw                 ; test, jestli je okno zapnut�
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   testaktw

testaktw:                                 ;* test, zda je okno zapnut�
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; V�STUP: CY=okno je vypnut�

         test      byte ptr cs:[flags],2    ; jsou vypnuta ob� okna ?
         jnz       testaktw1                ; ob� okna jsou vypnuta
         test      byte ptr cs:[bp+0],1     ; p��znak okna
         jnz       testaktw2                ; okno je zapnut�
testaktw1:stc                               ; p��znak - okno je vypnut�
testaktw2:ret

; -----------------------------------------------------------------------------
public   getakt

getakt:                                   ;* poskytnut� adresy aktivn�ho okna
                                            ; V�STUP: BP=adresa tabulky okna

         test      byte ptr cs:[flags],1    ; je aktivn� lev� okno ?
         lea       bp,[tabl]                ; adresa lev�ho okna
         jnz       getakt1                  ; je lev� okno
         lea       bp,[tabr]                ; adresa prav�ho okna
getakt1: ret

; -----------------------------------------------------------------------------
public   getnakt

getnakt:                                  ;* poskytnut� adresy neaktivn�ho okna
                                            ; V�STUP: BP=adresa tabulky okna

         test      byte ptr cs:[flags],1    ; je aktivn� lev� okno ?
         lea       bp,[tabl]                ; adresa lev�ho okna
         jz        getnakt1                 ; je prav� okno
         lea       bp,[tabr]                ; adresa prav�ho okna
getnakt1:ret

; -----------------------------------------------------------------------------
public   testakt

testakt:                                  ;* test, zda jde o aktivn� okno
                                            ; VSTUP: BP=adresa tabulky okna
                                            ; V�STUP: ZY=je aktivn�
         push      ax
         push      bp
         call      getakt                   ; nastaven� adresy aktivn�ho okna
         mov       ax,bp                    ; adresa aktivn�ho okna
         pop       bp
         cmp       ax,bp                    ; je to aktivn� okno ?
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   testexe

testexe:                                  ;* test, zda je soubor EXE, COM, BAT
                                            ; VSTUP: DS:SI=adresa polo�ky
                                            ; V�STUP: ZY=je spustiteln� program

         push      di
         push      es
         push      cs
         pop       es
         lea       di,[extent]              ; tabulka extent�
         call      testexe0                 ; test p��pony EXE
         je        testexe3                 ; p��pona nalezena
         call      testexe0                 ; test p��pony COM
         je        testexe3                 ; p��pona nalezena
         call      testexe0                 ; test p��pony BAT
testexe3:pop       es
         pop       di
         ret

testexe0:                                 ;* test, zda je p��pona ES:DI
                                            ; VSTUP: BP=adresa parametr� okna
                                            ;        DS:SI=adresa polo�ky
                                            ;        ES:DI=adresa p��pony

         push      di
         push      si
         push      ds
         add       si,9                     ; adresa p��pony souboru
         cmpsw
         jne       testexe1
         cmpsb
testexe1:pop       ds
         pop       si
         pop       di
         pushf
         add       di,3                     ; adresa n�sleduj�c� p��pony
         popf
         ret


         include   dmdat.asm                ; data programu

public   endshell
endshell label     word                      ; adresa konce programu

code     ends

         END


; *****************************************************************************
;                   H E S L O  (gener�tor souboru HESLO.SYS)
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
start:
         push      cs
         pop       ds                       ; DS <- CS
         jmp       short Heslo1

navrat2: mov       ax,4c01h                 ; n�vrat - nen� nic zad�no
         int       21h

heslo1:                                   ;* zobrazen� v�zvy ke vstupu
         mov       si,offset zadtxt         ; text v�zvy k zad�n�
         call      houttxt                  ; zobrazen� textu v�zvy
                                          ;* zad�n� textu hesla
         ASSUME    ds:heslosys

         mov       si,SEG heslosys          ; segment modulu HESLO.SYS
         mov       ds,si                    ; nastaven� segmentu
                                          ;* zak�dov�n� text� k v�pisu
         mov       si,offset uvtxt          ; �vodn� text
         mov       cx,offset(konec-uvtxt)   ; d�lka text�
heslo4:  xor       byte ptr ds:[si],63h     ; zak�dov�n� znaku
         inc       si                       ; zv��en� ukazatele textu
         loop      heslo4                   ; dal�� znak


                                          ;* zad�n� textu hesla
         mov       si,ds:[heslo]            ; adresa hesla v modulu HESLO.SYS
         call      hinptxt                  ; zad�n� textu hesla
         jc        navrat2                  ; p�eru�en� programu

         mov       ds:[delka],cx            ; nastaven� d�lky hesla
         mov       al,13
         call      houtch                   ; od��dkov�n� textu
         mov       al,10
         call      houtch
         jcxz      navrat2                  ; nen� text - n�vrat OK
; !!!!!
         add       cx,800                   ; nafouknut� souboru HESLO.SYS
; !!!!!

                                          ;* dotaz, zda m� b�t heslo p�i startu
         push      si
         push      ax

         push      ds
         push      cs
         pop       ds
         mov       si,offset strttxt
         call      houttxt
         pop       ds

         call      hinpch
         cmp       al,13
         jne       heslo54
         or        byte ptr ds:[parint],2   ; p��znak dotazu na heslo
heslo54: pop       ax
         pop       si


                                          ;* zad�n� hork� kl�vesy
         push      si
         push      cx
         push      ds
         push      cs
         pop       ds
         lea       si,[zadhot]
         call      houttxt                  ; zobrazen� textu v�zvy

         xor       ax,ax
         mov       ds,ax
         push      word ptr ds:[472h]       ; �schova p��znaku RESET
         mov       word ptr ds:[472h],21A9h ; p�echodn� vypnut� funkce z�mku
         mov       ax,ds:[24h]
         mov       word ptr cs:[hold09],ax
         mov       ax,ds:[26h]
         mov       word ptr cs:[hold09+2],ax
         mov       word ptr ds:[24h],offset hint09
         mov       word ptr ds:[26h],cs
         sti
heslo7:  test      byte ptr cs:[hparint],1
         jz        heslo7                   ; �ek�n� na zad�n� kl�vesy
         pop       word ptr ds:[472h]       ; n�vrat p��znaku RESET
         mov       ax,word ptr cs:[hold09]
         mov       ds:[24h],ax
         mov       ax,word ptr cs:[hold09+2]
         mov       ds:[26h],ax

         pop       ds
         pop       cx
         pop       si
                                          ;* zak�dov�n� zadan�ho hesla
         push      si
         push      cx
heslo2:  xor       byte ptr ds:[si],0ffh    ; p�ek�dov�n� znaku hesla
         inc       si                       ; zv��en� ukazatele v textu
         loop      heslo2                   ; dal�� znak
         pop       cx
         pop       si
         add       cx,si                    ; d�lka nov�ho souboru
         jc        error                    ; chyba - p��li� velk� soubor
                                          ;* vytvo�en� souboru
         ASSUME    ds:code
         push      cx                       ; �schova d�lky souboru HESLO.SYS
         push      ds                       ; segment se souborem HESLO.SYS
         push      cs
         pop       ds                       ; DS <- CS
                                          ;* nastaven� norm�ln�ch atribut�
         mov       ax,4301h                 ; funkce nastaven� atribut� souboru
         lea       dx,[soubor]              ; specifikace souboru
         xor       cx,cx                    ; atributy - norm�ln� soubor
         int       21h                      ; zru�en� atribut� HID, SYS a R/O
                                          ;* vytvo�en� nov�ho souboru
         mov       ah,3ch                   ; funkce vytvo�en� souboru
         lea       dx,[soubor]              ; specifikace souboru
         xor       cx,cx                    ; atributy - norm�ln� soubor
         int       21h                      ; otev�en� souboru
         pop       ds                       ; n�vrat segmentu se souborem
         pop       cx                       ; n�vrat d�lky souboru HESLO.SYS
         jc        error                    ; chyba vytvo�en� souboru
         mov       bx,ax                    ; identifik�tor souboru
                                          ;* z�pis souboru na disk
         mov       ah,40h
         xor       dx,dx                    ; offset dat k z�pisu = 0
         int       21h                      ; z�pis souboru na disk
         jc        error                    ; chyba z�pisu souboru na disk
         cmp       ax,cx                    ; byl soubor zaps�n cel� ?
         je        heslo3                   ; operace OK - pokra�ov�n�
                                          ;* chybov� hl��en�
error:   lea       si,[herrtxt]
         push      cs
         pop       ds
         call      houttxt                  ; zobrazen� textu hl��en�
         mov       ax,4c02h                 ; n�vratov� k�d - chyba souboru
         int       21h

heslo3:                                   ;* uzav�en� souboru
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru
                                          ;* nastaven� atribut� souboru
         push      cs
         pop       ds
         mov       ax,4301h                 ; funkce nastaven� atribut�
         mov       cx,7                     ; po�adovan� atributy HID, SYS a R/O
         lea       dx,[soubor]              ; specifikace souboru
         int       21h                      ; nastaven� atribut� souboru

         mov       ah,0fh
         int       10h                      ; poskytnut� videom�du
         xor       ah,ah
         int       10h                      ; vymaz�n� displeje
                                          ;* zobrazen� z�v�re�n�ho textu
         lea       si,[zavtxt]              ; z�v�re�n� text
         call      houttxt                  ; zobrazen� prvn� ��sti textu
         mov       ah,19h
         int       21h                      ; poskytnut� aktivn�ho disku
                                          ;* zobrazen� disku
         add       al,"A"                   ; korekce na znak ASCII
         call      houtch                   ; zobrazen� ozna�en� disku
         mov       al,":"                   ; znak odd�lova�e
         call      houtch                   ; zobrazen� odd�lova�e za jm�nem
         mov       al,"\"
         call      houtch                   ; zobrazen� �vodn�ho odd�lova�e
                                          ;* zobrazen� cesty
         mov       ah,47h
         lea       si,[zavtxt]              ; buffer k ulo�en� cesty
         xor       dl,dl                    ; je aktivn� disk
         int       21h                      ; poskytnut� aktivn�ho adres��e
         cmp       byte ptr ds:[si],0       ; je z�kladn� adres�� ?
         je        heslo5                   ; je ji� z�kladn� adres��
         call      houttxt                  ; zobrazen� aktivn�ho adres��e
         mov       al,"\"                   ; odd�lova� cesty
         call      houtch                   ; zobrazen� odd�lova�e cesty
heslo5:  lea       si,[soubor]              ; jm�no souboru
         call      houttxt                  ; zobrazen� jm�na souboru
         lea       si,[herrtxt0]            ; text od��dkov�n�
         call      houttxt                  ; od��dkov�n� textu
         mov       ax,4c00h                 ; n�vratov� k�d - OK
         int       21h

; ------------------------- vstup textu z kl�vesnice --------------------------
hinptxt:                                  ;* vstup textu z kl�vesnice
                                            ; VSTUP: DS:SI=ukl�dac� adresa
                                            ; V�STUP: CX=po�et zadan�ch znak�
                                            ;         CY=p�eru�en� programu

         push      si
         xor       cx,cx                    ; ��ta� zadan�ch znak�
hinptxt1:call      hinpch                   ; vstup znaku z kl�vesnice
         or        ax,ax
         jz        hinptxt4                 ; p�eru�en� programu CTRL-BREAK
         cmp       al,27
         je        hinptxt4                 ; p�eru�en� programu ESC
         cmp       al,13                    ; je <Enter> ?
         je        hinptxt3                 ; je <Enter>
         cmp       al,8                     ; je <BS> ?
         je        hinptxt2                 ; je <BS>
         cmp       al,0
         je        hinptxt1                 ; ��dic� kl�vesa neplat�

         mov       ds:[si],al               ; ulo�en� nov�ho znaku
         inc       cx                       ; zv��en� ��ta�e znak�
         inc       si                       ; zv��en� ukl�dac� adresy
         call      houtch                   ; zobrazen� zadan�ho znaku
         jmp       short hinptxt1           ; vstup dal��ho znaku

                                          ;* zru�en� znaku
hinptxt2:jcxz      hinptxt1                 ; v bufferu nen� ��dn� znak
         call      houtbs                   ; vymaz�n� p�edchoz�ho znaku
         dec       cx                       ; sn��en� znak� v bufferu
         dec       si                       ; sn��en� ukazatele v bufferu
         jmp       short hinptxt1           ; vstup dal��ho znaku

hinptxt4:stc                                ; p��znak p�eru�en�
hinptxt3:pop       si
         ret
; ------------------------- vstup znaku z kl�vesnice --------------------------
hinpch:                                   ;* vstup znaku z kl�vesnice
                                            ; V�STUP: AX=k�d kl�vesy
         xor       ax,ax
         int       16h                      ; vstup znaku
         cmp       al,"a"
         jb        hinpch2                  ; je men�� ne� "a" - nen� mal� p�sm.
         cmp       al,"z"
         ja        hinpch2                  ; je v�t�� ne� "z" - nen� mal� p�sm.
         sub       al,32                    ; korekce na velk� p�smeno
hinpch2: ret
; ------------------------- v�stup textu na displej ---------------------------
houttxt:                                  ;* v�stup textu na displej
                                            ; VSTUP: DS:SI=adresa textu

         cld
         lodsb                              ; na�ten� znaku k zobrazen�
         or        al,al                    ; je ji� konec textu ?
         jz        houttxt1                 ; je konec textu
         call      houtch                   ; zobrazen� znaku
         jmp       short houttxt            ; zobrazen� dal��ho znaku
houttxt1:ret
; -------------------------- vymmaz�n� znaku ----------------------------------
houtbs:                                   ;* vymaz�n� p�edchoz�ho znaku
         push      ax
         mov       al,8
         call      houtch                   ; posun kurzoru vlevo <BS>
         mov       al," "
         call      houtch                   ; vymaz�n� posledn�ho znaku
         mov       al,8
         call      houtch                   ; posun kurzoru zp�t vlevo
         pop       ax
         ret
; ------------------------- v�stup znaku na displej ---------------------------
houtch:                                   ;* v�stup znaku na displej
                                            ; VSTUP: AL=znak k zobrazen�

         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen�
         mov       ah,2
         int       21h                      ; zobrazen� znaku
         pop       dx
         pop       ax
         ret

; -------------------------- obsluha INT 09h ----------------------------------
hint09:                                   ;* obsluha p�eru�en� INT 09h

         push      ax
         push      bx
         push      dx
         push      ds
         mov       bx,40h
         mov       ds,bx                    ; segment s daty
         mov       bx,ds:[1ch]              ; ukl�dac� adresa do bufferu
         pushf
         call      dword ptr cs:[hold09]    ; vol�n� p�vodn� obsluhy INT 09h
         cmp       bx,ds:[1ch]              ; byla ulo�ena n�jak� kl�vesa ?
         je        hint092                  ; nebyla ��dn� kl�vesa

         test      byte ptr cs:[hparint],1  ; byla kl�vesa ji� zad�na ?
         jnz       hint092                  ; kl�vesa ji� byla zad�na
                                          ;* ulo�en� hork� kl�vesy
         or        byte ptr cs:[hparint],1  ; p��znak zad�n� k�du kl�vesy
         mov       ds:[1ch],bx              ; zru�en� hork� kl�vesy z bufferu
         mov       ax,ds:[bx]               ; k�d hork� kl�vesy
         mov       dl,ds:[17h]              ; p�esmyka�e
         and       dl,0fh                   ; p�esmyka�e
         mov       bx,SEG heslosys
         mov       ds,bx
         ASSUME    ds:heslosys
         mov       ds:[hotkey],ax           ; ulo�en� k�du hork� kl�vesy
         mov       ds:[hotswc],dl           ; p�esmyka�e

hint092: pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

; ------------------------------ data -----------------------------------------
;�
hparint  db        0                        ; bit 0: 1=hork� kl�vesa byla zad�na
hold09   dd        0                        ; p�vodn� adresa INT 09h
soubor   db        'HESLO.SYS',0            ; specifikace souboru

herrtxt  db        7,13,10,'Chyba - nelze vytvorit soubor HESLO.SYS !'
herrtxt0 db        13,10,0

zadtxt   db        'HESLO V1.10 - uzamykani pocitace; (c) Miroslav Nemecek',13,10
         db        'Zadejte text hesla: ',0

strttxt  db        'Dotaz na heslo pri startu pocitace (Enter=ANO, jinak=NE) ? ',0

zadhot   db        13,10,'Stisknete klavesu pro prechodne uzamceni pocitace: ',0

zavtxt   db        13,10,'Nove vygenerovany soubor HESLO.SYS zaclente',13,10
         db        'do systemoveho souboru CONFIG.SYS zapisem :',13,10
         db        ' DEVICE=',0

code     ENDS

zasob    SEGMENT   stack
         dw        200 dup(?)
zasob    ENDS


; *****************************************************************************
;                          H E S L O   (modul HESLO.SYS)
; *****************************************************************************
heslosys SEGMENT   page                     ; p�elo�eno jako HESLO.SYS
         ASSUME    cs:heslosys,ds:heslosys
; ------------------------- z�hlav� ovlada�e za��zen� -------------------------
         dd        -1                       ; adresa na n�sleduj�c� za��zen�
         dw        0c000h                   ; atributy - znakov� za��zen�
         dw        offset strateg           ; adresa obsluhy strategie za��zen�
         dw        offset prerus            ; adresa obsluhy p�eru�en� za��zen�
         db        '___HESLO'               ; jm�no za��zen� - nem� jm�no
; ------------------------------ data, adresy ---------------------------------
adrdev   dd        0                        ; adresa z�hlav� po�adavku za��zen�
heslo    dw        offset konec             ; adresa hesla (=konec programu)
delka    dw        0                        ; d�lka hesla
hotswc   db        0                        ; p�esmyka�e hork� kl�vesy
hotkey   dw        01f0h                    ; hork� kl�vesa
old09    dd        0                        ; p�vodn� adresa INT 09h
parint   db        0                        ; bit 0: 1=program je zamknut
                                            ; bit 1: 1=heslo p�i startu po��ta�e
; ------------------------------- strategie -----------------------------------
strateg  PROC      FAR                    ;* obsluha rutiny STRATEGIE
         mov       word ptr cs:[adrdev],bx  ; offset adresy z�hlav� po�adavku
         mov       word ptr cs:[adrdev+2],es; segment adresy z�hlav� po�adavku
         ret
strateg  ENDP
; ------------------------------- p�eru�en� -----------------------------------
prerus   PROC      FAR                    ;* obsluha rutiny P�ERU�EN�
         pushf                              ; �schova p��znakov�ho registru
         push      ax                       ; �schova AX
         push      bx                       ; �schova BX
         push      cx                       ; �schova CX
         push      dx                       ; �schova DX
         push      si                       ; �schova SI
         push      di                       ; �schova DI
         push      bp                       ; �schova BP
         push      ds                       ; �schova DS
         push      es                       ; �schova ES
         push      cs
         pop       ds                       ; DS <- CS
                                          ;* kontrola ��sla funkce
         les       di,ds:[adrdev]           ; adresa po�adavku za��zen�
         mov       bl,es:[di+2]             ; k�d povelu
         or        bl,bl                    ; kontrola maxim�ln�ho ��sla povelu
         mov       ax,8103h                 ; k�d chyby - nezn�m� povel
         jnz       prerusa                  ; chyba - nezn�m� povel

                                          ;* rozli�en�, zda m� b�t heslo zad�no
         test      byte ptr ds:[parint],2   ; m� b�t heslo zad�no ?
         jz        prerus99                 ; heslo nem� b�t zad�no

                                          ;* inicializace - vstup hesla
         lea       si,[uvtxt]               ; �vodn� text
         call      outtxt                   ; zobrazen� �vodn�ho textu
         mov       bx,ds:[heslo]            ; adresa hesla
         mov       si,bx                    ; adresa hesla
         add       si,ds:[delka]            ; za��tek bufferu pro vstup textu
         call      inptxt                   ; vstup textu hesla
         call      cmpall                   ; nalezen� hesla v textu
         jnc       prerus9                  ; heslo nalezeno OK
         lea       si,[errtxt]              ; chybov� text
         call      outtxt                   ; zobrazen� chybov�ho textu
prerus2: jmp       short prerus2            ; zablokov�n� po��ta�e

prerus9: lea       si,[oktxt]               ; text OK
         call      outtxt                   ; zobrazen� textu O.K.
prerus99:lea       ax,[konec]               ; konec programu
         add       ax,ds:[delka]            ; konec programu s heslem
         add       ax,15                    ; rezerva za heslem
         mov       es:[di+0eh],ax           ; konec rezid. modulu
         mov       word ptr es:[di+10h],cs  ; segment konce
         mov       byte ptr es:[di+13],0    ; po�et nainstalovan�ch disk� = 0

                                          ;* instalace obsluhy INT 09h
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[24h]
         mov       word ptr cs:[old09],ax
         mov       ax,ds:[26h]
         mov       word ptr cs:[old09+2],ax
         mov       word ptr ds:[24h],offset int09
         mov       word ptr ds:[26h],cs

         mov       ax,0100h                 ; n�vratov� k�d
prerusa: mov       es:[di+3],ax             ; nastaven� stavov�ho slova

         pop       es                       ; n�vrat ES
         pop       ds                       ; n�vrat DS
         pop       bp                       ; n�vrat BP
         pop       di                       ; n�vrat DI
         pop       si                       ; n�vrat SI
         pop       dx                       ; n�vrat DX
         pop       cx                       ; n�vrat CX
         pop       bx                       ; n�vrat BX
         pop       ax                       ; n�vrat AX
         popf                               ; n�vrat p��znakov�ho registru
         ret
prerus   ENDP
; ------------------------ INT 09h - obsluha INT 09h --------------------------
int09:                                    ;* obsluha INT 09h - zamykac� kl�vesa

         push      ax
         push      bx
         push      ds
         mov       bx,40h
         mov       ds,bx                    ; segment s daty
         mov       bx,ds:[1ch]              ; ukl�dac� adresa do bufferu
         pushf
         call      dword ptr cs:[old09]     ; vol�n� p�vodn� obsluhy INT 09h
         cmp       bx,ds:[1ch]              ; byla ulo�ena n�jak� kl�vesa ?
         je        int092                   ; nebyla ��dn� kl�vesa
         mov       ax,cs:[hotkey]           ; hork� kl�vesa
         cmp       ds:[bx],ax               ; je hork� kl�vesa ?
         jne       int092                   ; nen� hork� kl�vesa
         mov       al,ds:[17h]              ; p�esmyka�e
         and       al,0fh                   ; stav p�esmyka��
         cmp       al,cs:[hotswc]           ; stejn� p�esmyka�e ?
         jne       int092                   ; nen� shoda p�esmyka��

         test      byte ptr cs:[parint],1   ; je program zamknut ?
         jnz       int092                   ; program je ji� zamknut
         cmp       word ptr ds:[72h],21A9h  ; je p�echodn� vypnut� z�mku ?
         je        int092                   ; je p�echodn� vypnut� z�mku

         or        byte ptr cs:[parint],1   ; p��znak uzam�en� programu
         mov       ds:[1ch],bx              ; zru�en� hork� kl�vesy z bufferu
         mov       byte ptr ds:[100h],1     ; fale�n� p��znak obsluhy PrtScr

         call      beep                     ; p�pnut�
         call      beep                     ; p�pnut�
         call      beep                     ; p�pnut�
         call      beep                     ; p�pnut�
         call      beep                     ; p�pnut�
         call      beep                     ; p�pnut�
         call      zamek                    ; uzamknut� programu
         and       byte ptr cs:[parint],not 1 ; zru�en� p��znaku zamknut� prog.
         call      beep
         call      beep
         call      beep
         mov       byte ptr ds:[100h],0     ; zru�en� p��znaku obsluhy PrtScr

int092:  pop       ds
         pop       bx
         pop       ax
int05:                                    ;* p�echodn� obsluha INT 05h (PrtScr)
         iret

; --------------------------- p�pnut� -----------------------------------------
beep:                                     ;* p�pnut�

         push      ax
         push      cx
         mov       cx,10000
;         mov       al,0b6h                  ; povel pro nastaven� kan�lu 2
;         out       [43h],al                 ; nastaven� kan�lu 2
;         mov       al,60                    ; ni��� bajt d�li�ky
;         out       [42h],al                 ; nastaven� ni���ho bajtu d�li�ky
;         mov       al,2                     ; vy��� bajt d�li�ky
;         out       [42h],al                 ; nastaven� vy���ho bajtu d�li�ky
         in        al,[61h]
         push      ax
         or        al,3                     ; zapnut� reproduktoru
         out       [61h],al
         loop      $                        ; �ek�n� po zadanou d�lku t�nu
         pop       ax                       ; n�vrat nastaven� portu
         out       [61h],al
         mov       cx,500
         loop      $                        ; prodleva mezi t�ny
         pop       cx
         pop       ax
         ret

; ---------------------------- uzamknut� programu ----------------------------
zamek:                                    ;* uzamknut� programu
         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         sti
zamek0:                                   ;* vynulov�n� bufferu
         mov       ah,1
         int       16h                      ; dotaz na statut bufferu
         jz        zamek1                   ; buffer je ji� vynulov�n
         call      inpch                    ; vyjmut� znaku z bufferu
         jmp       short zamek0             ; dal�� znak
zamek1:                                   ;* za��tek zad�v�n� hesla
         mov       si,ds:[heslo]            ; adresa hesla
         mov       cx,ds:[delka]            ; d�lka hesla
         jcxz      zamek6                   ; nen� ��dn� znak hesla
zamek3:  call      inpch                    ; vstup znak
         not       al                       ; negace znaku
         cmp       ds:[si],al               ; je spr�vn� znak ?
         jne       zamek1                   ; nen� spr�vn� znak
         inc       si                       ; zv��en� ukazatele hesla
         loop      zamek3                   ; vstup dal��ho znaku
zamek6:
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

; -------------------------- nalezen� hesla v textu ---------------------------
cmpall:                                   ;* nalezen� hesla v textu
                                            ; VSTUP: DS:SI=zadan� text hesla
                                            ;        DS:BX=zak�dovan� heslo
                                            ;        CX=po�et zadan�ch znak�
                                            ; V�STUP: CY=heslo nenalezeno

         sub       cx,ds:[delka]            ; je zadan� text men�� ?
         jb        cmpall2                  ; zadan� text je men��
         inc       cx                       ; po�et test� shody
cmpall1: call      cmptxt                   ; porovn�n� text�
         je        cmpall2                  ; text nalezen
         inc       si                       ; zv��en� adresy v bufferu
         loop      cmpall1                  ; dal�� test textu
         stc                                ; p��znak - text nenalezen
cmpall2: ret
; -------------------------- porovn�n� text� ----------------------------------
cmptxt:                                   ;* porovn�n� text� v bufferech
                                            ; VSTUP: DS:SI=zadan� text
                                            ;        DS:BX=zak�dovan� heslo
                                            ; V�STUP: ZY=je shoda jmen

         push      si                       ; zadan� text
         push      bx                       ; porovn�van� text
         push      cx
         mov       cx,ds:[delka]            ; d�lka hesla
         or        cx,cx
         jz        cmptxt2                  ; nen� ��dn� znak hesla
         cld
cmptxt1: lodsb                              ; na�ten� zadan�ho znaku
         inc       bx                       ; zv��en� ukazatele reference
         not       al
         cmp       al,ds:[bx-1]             ; porovn�n� se zak�dovan�m znakem
         loopz     cmptxt1                  ; test dal��ho znaku
cmptxt2: pop       cx
         pop       bx
         pop       si
         ret
; ------------------------- vstup textu z kl�vesnice --------------------------
inptxt:                                   ;* vstup textu z kl�vesnice
                                            ; VSTUP: DS:SI=ukl�dac� adresa
                                            ; V�STUP: CX=po�et zadan�ch znak�

         push      si
         xor       cx,cx                    ; ��ta� zadan�ch znak�
inptxt1: call      inpch                    ; vstup znaku z kl�vesnice
         cmp       al,13                    ; je <Enter> ?
         je        inptxt3                  ; je <Enter>
         cmp       al,8                     ; je <BS> ?
         je        inptxt2                  ; je <BS>
         cmp       al,27
         je        inptxt1
         cmp       al,0
         je        inptxt1

         mov       ds:[si],al               ; ulo�en� nov�ho znaku
         inc       cx                       ; zv��en� ��ta�e znak�
         inc       si                       ; zv��en� ukl�dac� adresy
         mov       al,"*"                   ; n�hradn� znak "*"
         call      outch                    ; zobrazen� n�hradn�ho znaku "*"
         jmp       short inptxt1            ; vstup dal��ho znaku
inptxt2: jcxz      inptxt1                  ; v bufferu nen� ��dn� znak
         call      outbs                    ; vymaz�n� p�edchoz�ho znaku
         dec       cx                       ; sn��en� znak� v bufferu
         dec       si                       ; sn��en� ukazatele v bufferu
         jmp       short inptxt1            ; vstup dal��ho znaku
inptxt3: jcxz      inptxt5                  ; nen� zad�n ��dn� text
         push      cx
inptxt4: call      outbs                    ; vymaz�n� posledn�ho znaku "*"
         loop      inptxt4
         pop       cx
inptxt5: pop       si
         ret
; ------------------------- vstup znaku z kl�vesnice --------------------------
inpch:                                    ;* vstup znaku z kl�vesnice
                                            ; V�STUP: AX=k�d kl�vesy
         xor       ax,ax
         int       16h                      ; vstup znaku
         cmp       al,"a"
         jb        inpch2                   ; je men�� ne� "a" - nen� mal� p�sm.
         cmp       al,"z"
         ja        inpch2                   ; je v�t�� ne� "z" - nen� mal� p�sm.
         sub       al,32                    ; korekce na velk� p�smeno
inpch2:  ret
; ------------------------- v�stup textu na displej ---------------------------
outtxt:                                   ;* v�stup textu na displej
                                            ; VSTUP: DS:SI=adresa textu

         cld
         lodsb                              ; na�ten� znaku k zobrazen�
         xor       al,63h                   ; rozk�dov�n� znaku
         or        al,al                    ; je ji� konec textu ?
         jz        outtxt1                  ; je konec textu
         call      outch                    ; zobrazen� znaku
         jmp       short outtxt             ; zobrazen� dal��ho znaku
outtxt1: ret
; -------------------------- vymmaz�n� znaku ----------------------------------
outbs:                                    ;* vymaz�n� p�edchoz�ho znaku
         push      ax
         mov       al,8
         call      outch                    ; posun kurzoru vlevo <BS>
         mov       al," "
         call      outch                    ; vymaz�n� posledn�ho znaku
         mov       al,8
         call      outch                    ; posun kurzoru zp�t vlevo
         pop       ax
         ret
; ------------------------- v�stup znaku na displej ---------------------------
outch:                                    ;* v�stup znaku na displej
                                            ; VSTUP: AL=znak k zobrazen�
         push      ax
         push      bx
         push      cx
         push      si
         mov       ah,0eh                   ; funkce zobrazen� znaku
         mov       bx,7                     ; str�nka 0, atributy b�l� na �ern�
         int       10h                      ; zobrazen� znaku na displeji
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
uvtxt    db        'HESLO: ',0
errtxt   db        ' ..... CHYBA !',7,13,10,0
oktxt    db        ' O.K. ',13,10,0
; -----------------------------------------------------------------------------
konec    label     near                     ; konec rezidentn� ��sti
                                          ;* zde se ulo�� heslo
heslosys ends

rezerva  segment
         db        0ffffh dup(?)            ; rezerva pro heslo
rezerva  ends

         end       start

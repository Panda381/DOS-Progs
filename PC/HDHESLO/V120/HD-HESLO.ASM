
; *****************************************************************************
;                   H E S L O  (gener†tor souboru HESLO.SYS)
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
start:
         push      cs
         pop       ds                       ; DS <- CS
         jmp       short Heslo1

navrat2: mov       ax,4c01h                 ; n†vrat - nen° nic zad†no
         int       21h

heslo1:                                   ;* zobrazen° vòzvy ke vstupu
         mov       si,offset zadtxt         ; text vòzvy k zad†n°
         call      houttxt                  ; zobrazen° textu vòzvy
                                          ;* zad†n° textu hesla
         ASSUME    ds:heslosys

         mov       si,SEG heslosys          ; segment modulu HESLO.SYS
         mov       ds,si                    ; nastaven° segmentu
                                          ;* zak¢dov†n° textñ k vòpisu
         mov       si,offset uvtxt          ; £vodn° text
         mov       cx,offset(konec-uvtxt)   ; dÇlka textñ
heslo4:  xor       byte ptr ds:[si],63h     ; zak¢dov†n° znaku
         inc       si                       ; zvò®en° ukazatele textu
         loop      heslo4                   ; dal®° znak


                                          ;* zad†n° textu hesla
         mov       si,ds:[heslo]            ; adresa hesla v modulu HESLO.SYS
         call      hinptxt                  ; zad†n° textu hesla
         jc        navrat2                  ; p©eru®en° programu

         mov       ds:[delka],cx            ; nastaven° dÇlky hesla
         mov       al,13
         call      houtch                   ; od©†dkov†n° textu
         mov       al,10
         call      houtch
         jcxz      navrat2                  ; nen° text - n†vrat OK
; !!!!!
         add       cx,800                   ; nafouknut° souboru HESLO.SYS
; !!!!!

                                          ;* dotaz, zda m† bòt heslo p©i startu
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
         or        byte ptr ds:[parint],2   ; p©°znak dotazu na heslo

         push      ds
         push      cs
         pop       ds
         mov       si,offset parktxt
         call      Houttxt
         pop       ds

         call      hinpch
         cmp       al,13
         jne       heslo54
         or        byte ptr ds:[parint],4 ; p©°znak parkov†n° p©ed heslem

heslo54: pop       ax
         pop       si




                                          ;* zad†n° horkÇ kl†vesy
         push      si
         push      cx
         push      ds
         push      cs
         pop       ds
         lea       si,[zadhot]
         call      houttxt                  ; zobrazen° textu vòzvy

         xor       ax,ax
         mov       ds,ax
         push      word ptr ds:[472h]       ; £schova p©°znaku RESET
         mov       word ptr ds:[472h],21A9h ; p©echodnÇ vypnut° funkce z†mku
         mov       ax,ds:[24h]
         mov       word ptr cs:[hold09],ax
         mov       ax,ds:[26h]
         mov       word ptr cs:[hold09+2],ax
         mov       word ptr ds:[24h],offset hint09
         mov       word ptr ds:[26h],cs
         sti
heslo7:  test      byte ptr cs:[hparint],1
         jz        heslo7                   ; áek†n° na zad†n° kl†vesy
         pop       word ptr ds:[472h]       ; n†vrat p©°znaku RESET
         mov       ax,word ptr cs:[hold09]
         mov       ds:[24h],ax
         mov       ax,word ptr cs:[hold09+2]
         mov       ds:[26h],ax

         pop       ds
         pop       cx
         pop       si
                                          ;* zak¢dov†n° zadanÇho hesla
         push      si
         push      cx
heslo2:  xor       byte ptr ds:[si],0ffh    ; p©ek¢dov†n° znaku hesla
         inc       si                       ; zvò®en° ukazatele v textu
         loop      heslo2                   ; dal®° znak
         pop       cx
         pop       si
         add       cx,si                    ; dÇlka novÇho souboru
         jc        error                    ; chyba - p©°li® velkò soubor
                                          ;* vytvo©en° souboru
         ASSUME    ds:code
         push      cx                       ; £schova dÇlky souboru HESLO.SYS
         push      ds                       ; segment se souborem HESLO.SYS
         push      cs
         pop       ds                       ; DS <- CS
                                          ;* nastaven° norm†ln°ch atributñ
         mov       ax,4301h                 ; funkce nastaven° atributñ souboru
         lea       dx,[soubor]              ; specifikace souboru
         xor       cx,cx                    ; atributy - norm†ln° soubor
         int       21h                      ; zru®en° atributñ HID, SYS a R/O
                                          ;* vytvo©en° novÇho souboru
         mov       ah,3ch                   ; funkce vytvo©en° souboru
         lea       dx,[soubor]              ; specifikace souboru
         xor       cx,cx                    ; atributy - norm†ln° soubor
         int       21h                      ; otev©en° souboru
         pop       ds                       ; n†vrat segmentu se souborem
         pop       cx                       ; n†vrat dÇlky souboru HESLO.SYS
         jc        error                    ; chyba vytvo©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
                                          ;* z†pis souboru na disk
         mov       ah,40h
         xor       dx,dx                    ; offset dat k z†pisu = 0
         int       21h                      ; z†pis souboru na disk
         jc        error                    ; chyba z†pisu souboru na disk
         cmp       ax,cx                    ; byl soubor zaps†n celò ?
         je        heslo3                   ; operace OK - pokraáov†n°
                                          ;* chybovÇ hl†®en°
error:   lea       si,[herrtxt]
         push      cs
         pop       ds
         call      houttxt                  ; zobrazen° textu hl†®en°
         mov       ax,4c02h                 ; n†vratovò k¢d - chyba souboru
         int       21h

heslo3:                                   ;* uzav©en° souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
                                          ;* nastaven° atributñ souboru
         push      cs
         pop       ds
         mov       ax,4301h                 ; funkce nastaven° atributñ
         mov       cx,7                     ; poëadovanÇ atributy HID, SYS a R/O
         lea       dx,[soubor]              ; specifikace souboru
         int       21h                      ; nastaven° atributñ souboru

         mov       ah,0fh
         int       10h                      ; poskytnut° videom¢du
         xor       ah,ah
         int       10h                      ; vymaz†n° displeje
                                          ;* zobrazen° z†vàreánÇho textu
         lea       si,[zavtxt]              ; z†vàreánò text
         call      houttxt                  ; zobrazen° prvn° á†sti textu
         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
                                          ;* zobrazen° disku
         add       al,"A"                   ; korekce na znak ASCII
         call      houtch                   ; zobrazen° oznaáen° disku
         mov       al,":"                   ; znak oddàlovaáe
         call      houtch                   ; zobrazen° oddàlovaáe za jmÇnem
         mov       al,"\"
         call      houtch                   ; zobrazen° £vodn°ho oddàlovaáe
                                          ;* zobrazen° cesty
         mov       ah,47h
         lea       si,[zavtxt]              ; buffer k uloëen° cesty
         xor       dl,dl                    ; je aktivn° disk
         int       21h                      ; poskytnut° aktivn°ho adres†©e
         cmp       byte ptr ds:[si],0       ; je z†kladn° adres†© ?
         je        heslo5                   ; je jië z†kladn° adres†©
         call      houttxt                  ; zobrazen° aktivn°ho adres†©e
         mov       al,"\"                   ; oddàlovaá cesty
         call      houtch                   ; zobrazen° oddàlovaáe cesty
heslo5:  lea       si,[soubor]              ; jmÇno souboru
         call      houttxt                  ; zobrazen° jmÇna souboru
         lea       si,[herrtxt0]            ; text od©†dkov†n°
         call      houttxt                  ; od©†dkov†n° textu
         mov       ax,4c00h                 ; n†vratovò k¢d - OK
         int       21h

; ------------------------- vstup textu z kl†vesnice --------------------------
hinptxt:                                  ;* vstup textu z kl†vesnice
                                            ; VSTUP: DS:SI=ukl†dac° adresa
                                            ; VùSTUP: CX=poáet zadanòch znakñ
                                            ;         CY=p©eru®en° programu

         push      si
         xor       cx,cx                    ; á°taá zadanòch znakñ
hinptxt1:call      hinpch                   ; vstup znaku z kl†vesnice
         or        ax,ax
         jz        hinptxt4                 ; p©eru®en° programu CTRL-BREAK
         cmp       al,27
         je        hinptxt4                 ; p©eru®en° programu ESC
         cmp       al,13                    ; je <Enter> ?
         je        hinptxt3                 ; je <Enter>
         cmp       al,8                     ; je <BS> ?
         je        hinptxt2                 ; je <BS>
         cmp       al,0
         je        hinptxt1                 ; ©°dic° kl†vesa neplat°

         mov       ds:[si],al               ; uloëen° novÇho znaku
         inc       cx                       ; zvò®en° á°taáe znakñ
         inc       si                       ; zvò®en° ukl†dac° adresy
         call      houtch                   ; zobrazen° zadanÇho znaku
         jmp       short hinptxt1           ; vstup dal®°ho znaku

                                          ;* zru®en° znaku
hinptxt2:jcxz      hinptxt1                 ; v bufferu nen° ë†dnò znak
         call      houtbs                   ; vymaz†n° p©edchoz°ho znaku
         dec       cx                       ; sn°ëen° znakñ v bufferu
         dec       si                       ; sn°ëen° ukazatele v bufferu
         jmp       short hinptxt1           ; vstup dal®°ho znaku

hinptxt4:stc                                ; p©°znak p©eru®en°
hinptxt3:pop       si
         ret
; ------------------------- vstup znaku z kl†vesnice --------------------------
hinpch:                                   ;* vstup znaku z kl†vesnice
                                            ; VùSTUP: AX=k¢d kl†vesy
         xor       ax,ax
         int       16h                      ; vstup znaku
         cmp       al,"a"
         jb        hinpch2                  ; je men®° neë "a" - nen° malÇ p°sm.
         cmp       al,"z"
         ja        hinpch2                  ; je vàt®° neë "z" - nen° malÇ p°sm.
         sub       al,32                    ; korekce na velkÇ p°smeno
hinpch2: ret
; ------------------------- vòstup textu na displej ---------------------------
houttxt:                                  ;* vòstup textu na displej
                                            ; VSTUP: DS:SI=adresa textu

         cld
         lodsb                              ; naáten° znaku k zobrazen°
         or        al,al                    ; je jië konec textu ?
         jz        houttxt1                 ; je konec textu
         call      houtch                   ; zobrazen° znaku
         jmp       short houttxt            ; zobrazen° dal®°ho znaku
houttxt1:ret
; -------------------------- vymmaz†n° znaku ----------------------------------
houtbs:                                   ;* vymaz†n° p©edchoz°ho znaku
         push      ax
         mov       al,8
         call      houtch                   ; posun kurzoru vlevo <BS>
         mov       al," "
         call      houtch                   ; vymaz†n° posledn°ho znaku
         mov       al,8
         call      houtch                   ; posun kurzoru zpàt vlevo
         pop       ax
         ret
; ------------------------- vòstup znaku na displej ---------------------------
houtch:                                   ;* vòstup znaku na displej
                                            ; VSTUP: AL=znak k zobrazen°

         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen°
         mov       ah,2
         int       21h                      ; zobrazen° znaku
         pop       dx
         pop       ax
         ret

; -------------------------- obsluha INT 09h ----------------------------------
hint09:                                   ;* obsluha p©eru®en° INT 09h

         push      ax
         push      bx
         push      dx
         push      ds
         mov       bx,40h
         mov       ds,bx                    ; segment s daty
         mov       bx,ds:[1ch]              ; ukl†dac° adresa do bufferu
         pushf
         call      dword ptr cs:[hold09]    ; vol†n° pñvodn° obsluhy INT 09h
         cmp       bx,ds:[1ch]              ; byla uloëena nàjak† kl†vesa ?
         je        hint092                  ; nebyla ë†dn† kl†vesa

         test      byte ptr cs:[hparint],1  ; byla kl†vesa jië zad†na ?
         jnz       hint092                  ; kl†vesa jië byla zad†na
                                          ;* uloëen° horkÇ kl†vesy
         or        byte ptr cs:[hparint],1  ; p©°znak zad†n° k¢du kl†vesy
         mov       ds:[1ch],bx              ; zru®en° horkÇ kl†vesy z bufferu
         mov       ax,ds:[bx]               ; k¢d horkÇ kl†vesy
         mov       dl,ds:[17h]              ; p©esmykaáe
         and       dl,0fh                   ; p©esmykaáe
         mov       bx,SEG heslosys
         mov       ds,bx
         ASSUME    ds:heslosys
         mov       ds:[hotkey],ax           ; uloëen° k¢du horkÇ kl†vesy
         mov       ds:[hotswc],dl           ; p©esmykaáe

hint092: pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

; ------------------------------ data -----------------------------------------
;˛
hparint  db        0                        ; bit 0: 1=hork† kl†vesa byla zad†na
hold09   dd        0                        ; pñvodn° adresa INT 09h
soubor   db        'HESLO.SYS',0            ; specifikace souboru

herrtxt  db        7,13,10,'Chyba - nelze vytvorit soubor HESLO.SYS !'
herrtxt0 db        13,10,0

zadtxt   db        'HESLO V1.20 - uzamykani pocitace; (c) Miroslav Nemecek',13,10
         db        'Zadejte text hesla: ',0

strttxt  db        'Dotaz na heslo pri startu pocitace (Enter=ANO, jinak=NE) ? ',0
parktxt  db        13,10,'Parkovat disk pred zadanim hesla (Enter=ANO, jinak=NE) ? ',0

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
heslosys SEGMENT   page                     ; p©eloëeno jako HESLO.SYS
         ASSUME    cs:heslosys,ds:heslosys
; ------------------------- z†hlav° ovladaáe za©°zen° -------------------------
         dd        -1                       ; adresa na n†sleduj°c° za©°zen°
         dw        0c000h                   ; atributy - znakovÇ za©°zen°
         dw        offset strateg           ; adresa obsluhy strategie za©°zen°
         dw        offset prerus            ; adresa obsluhy p©eru®en° za©°zen°
         db        '___HESLO'               ; jmÇno za©°zen° - nem† jmÇno
; ------------------------------ data, adresy ---------------------------------
adrdev   dd        0                        ; adresa z†hlav° poëadavku za©°zen°
heslo    dw        offset konec             ; adresa hesla (=konec programu)
delka    dw        0                        ; dÇlka hesla
hotswc   db        0                        ; p©esmykaáe horkÇ kl†vesy
hotkey   dw        01f0h                    ; hork† kl†vesa
old09    dd        0                        ; pñvodn° adresa INT 09h
parint   db        0                        ; bit 0: 1=program je zamknut
                                            ; bit 1: 1=heslo p©i startu poá°taáe
                                            ; bit 2: 1=parkov†n° p©ed heslem
; ------------------------------- strategie -----------------------------------
strateg  PROC      FAR                    ;* obsluha rutiny STRATEGIE
         mov       word ptr cs:[adrdev],bx  ; offset adresy z†hlav° poëadavku
         mov       word ptr cs:[adrdev+2],es; segment adresy z†hlav° poëadavku
         ret
strateg  ENDP
; ------------------------------- p©eru®en° -----------------------------------
prerus   PROC      FAR                    ;* obsluha rutiny PûERUõENã
         pushf                              ; £schova p©°znakovÇho registru
         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      bp                       ; £schova BP
         push      ds                       ; £schova DS
         push      es                       ; £schova ES

         push      cs
         pop       ds                       ; DS <- CS
                                          ;* kontrola á°sla funkce
         les       di,ds:[adrdev]           ; adresa poëadavku za©°zen°
         mov       bl,es:[di+2]             ; k¢d povelu
         or        bl,bl                    ; kontrola maxim†ln°ho á°sla povelu
         mov       ax,8103h                 ; k¢d chyby - nezn†mò povel
         jnz       prerusa                  ; chyba - nezn†mò povel

                                          ;* rozli®en°, zda m† bòt heslo zad†no
         test      byte ptr ds:[parint],2   ; m† bòt heslo zad†no ?
         jz        prerus99                 ; heslo nem† bòt zad†no

         test      byte ptr ds:[parint],4   ; maj° se parkovat disky ?
         jz        prerus13                 ; nemaj°
         call      Parkuj                   ; zaparkov†n° pevnòch diskñ
prerus13:
                                          ;* inicializace - vstup hesla
         lea       si,[uvtxt]               ; £vodn° text
         call      outtxt                   ; zobrazen° £vodn°ho textu
         mov       bx,ds:[heslo]            ; adresa hesla
         mov       si,bx                    ; adresa hesla
         add       si,ds:[delka]            ; zaá†tek bufferu pro vstup textu
         call      inptxt                   ; vstup textu hesla
         call      cmpall                   ; nalezen° hesla v textu
         jnc       prerus9                  ; heslo nalezeno OK
         lea       si,[errtxt]              ; chybovò text
         call      outtxt                   ; zobrazen° chybovÇho textu
prerus2: jmp       short prerus2            ; zablokov†n° poá°taáe

prerus9: lea       si,[oktxt]               ; text OK
         call      outtxt                   ; zobrazen° textu O.K.
prerus99:lea       ax,[konec]               ; konec programu
         add       ax,ds:[delka]            ; konec programu s heslem
         add       ax,15                    ; rezerva za heslem
         mov       es:[di+0eh],ax           ; konec rezid. modulu
         mov       word ptr es:[di+10h],cs  ; segment konce
         mov       byte ptr es:[di+13],0    ; poáet nainstalovanòch diskñ = 0

                                          ;* instalace obsluhy INT 09h
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[24h]
         mov       word ptr cs:[old09],ax
         mov       ax,ds:[26h]
         mov       word ptr cs:[old09+2],ax
         mov       word ptr ds:[24h],offset int09
         mov       word ptr ds:[26h],cs

         mov       ax,0100h                 ; n†vratovò k¢d
prerusa: mov       es:[di+3],ax             ; nastaven° stavovÇho slova

         pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       bp                       ; n†vrat BP
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX
         popf                               ; n†vrat p©°znakovÇho registru
         ret
prerus   ENDP
; ------------------------ INT 09h - obsluha INT 09h --------------------------
int09:                                    ;* obsluha INT 09h - zamykac° kl†vesa

         push      ax
         push      bx
         push      ds
         mov       bx,40h
         mov       ds,bx                    ; segment s daty
         mov       bx,ds:[1ch]              ; ukl†dac° adresa do bufferu
         pushf
         call      dword ptr cs:[old09]     ; vol†n° pñvodn° obsluhy INT 09h
         cmp       bx,ds:[1ch]              ; byla uloëena nàjak† kl†vesa ?
         je        int092                   ; nebyla ë†dn† kl†vesa
         mov       ax,cs:[hotkey]           ; hork† kl†vesa
         cmp       ds:[bx],ax               ; je hork† kl†vesa ?
         jne       int092                   ; nen° hork† kl†vesa
         mov       al,ds:[17h]              ; p©esmykaáe
         and       al,0fh                   ; stav p©esmykaáñ
         cmp       al,cs:[hotswc]           ; stejnÇ p©esmykaáe ?
         jne       int092                   ; nen° shoda p©esmykaáñ

         test      byte ptr cs:[parint],1   ; je program zamknut ?
         jnz       int092                   ; program je jië zamknut
         cmp       word ptr ds:[72h],21A9h  ; je p©echodnÇ vypnut° z†mku ?
         je        int092                   ; je p©echodnÇ vypnut° z†mku

         or        byte ptr cs:[parint],1   ; p©°znak uzamáen° programu
         mov       ds:[1ch],bx              ; zru®en° horkÇ kl†vesy z bufferu
         mov       byte ptr ds:[100h],1     ; fale®nò p©°znak obsluhy PrtScr

         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      zamek                    ; uzamknut° programu
         and       byte ptr cs:[parint],not 1 ; zru®en° p©°znaku zamknut° prog.
         call      beep
         call      beep
         call      beep
         mov       byte ptr ds:[100h],0     ; zru®en° p©°znaku obsluhy PrtScr

int092:  pop       ds
         pop       bx
         pop       ax
int05:                                    ;* p©echodn† obsluha INT 05h (PrtScr)
         iret

; --------------------------- p°pnut° -----------------------------------------
beep:                                     ;* p°pnut°

         push      ax
         push      cx
         mov       cx,10000
;         mov       al,0b6h                  ; povel pro nastaven° kan†lu 2
;         out       [43h],al                 ; nastaven° kan†lu 2
;         mov       al,60                    ; nië®° bajt dàliáky
;         out       [42h],al                 ; nastaven° nië®°ho bajtu dàliáky
;         mov       al,2                     ; vy®®° bajt dàliáky
;         out       [42h],al                 ; nastaven° vy®®°ho bajtu dàliáky
         in        al,[61h]
         push      ax
         or        al,3                     ; zapnut° reproduktoru
         out       [61h],al
         loop      $                        ; áek†n° po zadanou dÇlku t¢nu
         pop       ax                       ; n†vrat nastaven° portu
         out       [61h],al
         mov       cx,500
         loop      $                        ; prodleva mezi t¢ny
         pop       cx
         pop       ax
         ret

; ---------------------------- uzamknut° programu ----------------------------
zamek:                                    ;* uzamknut° programu
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
zamek0:                                   ;* vynulov†n° bufferu
         mov       ah,1
         int       16h                      ; dotaz na statut bufferu
         jz        zamek1                   ; buffer je jië vynulov†n
         call      inpch                    ; vyjmut° znaku z bufferu
         jmp       short zamek0             ; dal®° znak
zamek1:                                   ;* zaá†tek zad†v†n° hesla
         mov       si,ds:[heslo]            ; adresa hesla
         mov       cx,ds:[delka]            ; dÇlka hesla
         jcxz      zamek6                   ; nen° ë†dnò znak hesla
zamek3:  call      inpch                    ; vstup znak
         not       al                       ; negace znaku
         cmp       ds:[si],al               ; je spr†vnò znak ?
         jne       zamek1                   ; nen° spr†vnò znak
         inc       si                       ; zvò®en° ukazatele hesla
         loop      zamek3                   ; vstup dal®°ho znaku
zamek6:
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

; -------------------------- nalezen° hesla v textu ---------------------------
cmpall:                                   ;* nalezen° hesla v textu
                                            ; VSTUP: DS:SI=zadanò text hesla
                                            ;        DS:BX=zak¢dovanÇ heslo
                                            ;        CX=poáet zadanòch znakñ
                                            ; VùSTUP: CY=heslo nenalezeno

         sub       cx,ds:[delka]            ; je zadanò text men®° ?
         jb        cmpall2                  ; zadanò text je men®°
         inc       cx                       ; poáet testñ shody
cmpall1: call      cmptxt                   ; porovn†n° textñ
         je        cmpall2                  ; text nalezen
         inc       si                       ; zvò®en° adresy v bufferu
         loop      cmpall1                  ; dal®° test textu
         stc                                ; p©°znak - text nenalezen
cmpall2: ret
; -------------------------- porovn†n° textñ ----------------------------------
cmptxt:                                   ;* porovn†n° textñ v bufferech
                                            ; VSTUP: DS:SI=zadanò text
                                            ;        DS:BX=zak¢dovanÇ heslo
                                            ; VùSTUP: ZY=je shoda jmen

         push      si                       ; zadanò text
         push      bx                       ; porovn†vanò text
         push      cx
         mov       cx,ds:[delka]            ; dÇlka hesla
         or        cx,cx
         jz        cmptxt2                  ; nen° ë†dnò znak hesla
         cld
cmptxt1: lodsb                              ; naáten° zadanÇho znaku
         inc       bx                       ; zvò®en° ukazatele reference
         not       al
         cmp       al,ds:[bx-1]             ; porovn†n° se zak¢dovanòm znakem
         loopz     cmptxt1                  ; test dal®°ho znaku
cmptxt2: pop       cx
         pop       bx
         pop       si
         ret
; ------------------------- vstup textu z kl†vesnice --------------------------
inptxt:                                   ;* vstup textu z kl†vesnice
                                            ; VSTUP: DS:SI=ukl†dac° adresa
                                            ; VùSTUP: CX=poáet zadanòch znakñ

         push      si
         xor       cx,cx                    ; á°taá zadanòch znakñ
inptxt1: call      inpch                    ; vstup znaku z kl†vesnice
         cmp       al,13                    ; je <Enter> ?
         je        inptxt3                  ; je <Enter>
         cmp       al,8                     ; je <BS> ?
         je        inptxt2                  ; je <BS>
         cmp       al,27
         je        inptxt1
         cmp       al,0
         je        inptxt1

         mov       ds:[si],al               ; uloëen° novÇho znaku
         inc       cx                       ; zvò®en° á°taáe znakñ
         inc       si                       ; zvò®en° ukl†dac° adresy
         mov       al,"*"                   ; n†hradn° znak "*"
         call      outch                    ; zobrazen° n†hradn°ho znaku "*"
         jmp       short inptxt1            ; vstup dal®°ho znaku
inptxt2: jcxz      inptxt1                  ; v bufferu nen° ë†dnò znak
         call      outbs                    ; vymaz†n° p©edchoz°ho znaku
         dec       cx                       ; sn°ëen° znakñ v bufferu
         dec       si                       ; sn°ëen° ukazatele v bufferu
         jmp       short inptxt1            ; vstup dal®°ho znaku
inptxt3: jcxz      inptxt5                  ; nen° zad†n ë†dnò text
         push      cx
inptxt4: call      outbs                    ; vymaz†n° posledn°ho znaku "*"
         loop      inptxt4
         pop       cx
inptxt5: pop       si
         ret
; ------------------------- vstup znaku z kl†vesnice --------------------------
inpch:                                    ;* vstup znaku z kl†vesnice
                                            ; VùSTUP: AX=k¢d kl†vesy
         xor       ax,ax
         int       16h                      ; vstup znaku
         cmp       al,"a"
         jb        inpch2                   ; je men®° neë "a" - nen° malÇ p°sm.
         cmp       al,"z"
         ja        inpch2                   ; je vàt®° neë "z" - nen° malÇ p°sm.
         sub       al,32                    ; korekce na velkÇ p°smeno
inpch2:  ret
; ------------------------- vòstup textu na displej ---------------------------
outtxt:                                   ;* vòstup textu na displej
                                            ; VSTUP: DS:SI=adresa textu

         cld
         lodsb                              ; naáten° znaku k zobrazen°
         xor       al,63h                   ; rozk¢dov†n° znaku
         or        al,al                    ; je jië konec textu ?
         jz        outtxt1                  ; je konec textu
         call      outch                    ; zobrazen° znaku
         jmp       short outtxt             ; zobrazen° dal®°ho znaku
outtxt1: ret
; -------------------------- vymmaz†n° znaku ----------------------------------
outbs:                                    ;* vymaz†n° p©edchoz°ho znaku
         push      ax
         mov       al,8
         call      outch                    ; posun kurzoru vlevo <BS>
         mov       al," "
         call      outch                    ; vymaz†n° posledn°ho znaku
         mov       al,8
         call      outch                    ; posun kurzoru zpàt vlevo
         pop       ax
         ret
; ------------------------- vòstup znaku na displej ---------------------------
outch:                                    ;* vòstup znaku na displej
                                            ; VSTUP: AL=znak k zobrazen°
         push      ax
         push      bx
         push      cx
         push      si
         mov       ah,0eh                   ; funkce zobrazen° znaku
         mov       bx,7                     ; str†nka 0, atributy b°l† na áernÇ
         int       10h                      ; zobrazen° znaku na displeji
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

; *****************************************************************************
;
;                         Parkov†n° pevnòch diskñ
;
; *****************************************************************************

Parkuj   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
                                          ;* reset diskovÇho systÇmu
         mov       ah,0dh
         int       21h                      ; reset diskovÇho systÇmu DOS
                                          ;* z°sk†n° poátu diskñ
         mov       ah,8
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         int       13h                      ; poskytnut° poátu diskñ
         jc        Parkuj9                  ; chyba - nen° ë†dnò pevnò disk
         and       dx,3                     ; poáet pevnòch diskñ
         jz        Parkuj9                  ; nen° ani 1 pevnò disk
         mov       ds:[disku],dl            ; £schova poátu pevnòch diskñ
         dec       dx                       ; je 1 pevnò disk ?
         jz        getd0                    ; je pouze 1 pevnò disk
                                          ;* zji®tàn° parkovac° stopy disku 1
         mov       dl,81h                   ; á°slo pevnÇho disku 1
         mov       bx,118h                  ; offset adresy INT 46h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 1
         mov       ds:[parkc1],dx           ; parkovac° stopa disku 1
getd0:                                    ;* zji®tàn° parkovac° stopy disku 0
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,104h                  ; offset adresy INT 41h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 0
         mov       ds:[parkc0],dx           ; parkovac° stopa disku 0
                                          ;* test spr†vnosti stop
         mov       ax,ds:[parkc0]           ; parkovac° stopa disku 0
         or        ax,ds:[parkc1]           ; je alespo§ 1 pevnò disk ?
         jz        Parkuj9                  ; nen° ë†dnò pevnò disk

                                          ;* zaparkov†n° diskñ
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,ds:[parkc0]           ; parkovac° stopa disku 0
         call      park                     ; zaparkov†n° pevnÇho disku 0
         inc       dx                       ; á°slo pevnÇho disku 1
         mov       bx,ds:[parkc1]           ; parkovac° stopa disku 1
         call      park                     ; zaparkov†n° pevnÇho disku 1

; ------ n†vrat registrñ

Parkuj9: pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Parkuj   ENDP

; -----------------------------------------------------------------------------
getdisk:                                  ;* zji®tàn° parkovac° stopy
                                            ; VSTUP: DL=á°slo disku
                                            ;        BX=offset ukazatele tabulky
                                            ; VùSTUP: DX=parkovac° stopa disku
         push      es
         xor       ax,ax
         mov       es,ax                    ; segment 0
         mov       al,dl                    ; £schova á°sla disku
         les       bx,es:[bx]               ; adresa tabulky popisovaáe
         mov       dx,es:[bx]               ; poáet v†lcñ disku
         dec       dx                       ; á°slo posledn° stopy
         call      testat                   ; je poá°taá AT ?
         jc        getdisk2                 ; nen° poá°taá AT
         mov       dx,es:[bx+0ch]           ; parkovac° z¢na pevnÇho disku
getdisk2:or        dx,dx                    ; je platn† stopa ?
         jnz       getdisk4                 ; je platn† stopa

         mov       dl,al                    ; á°slo disku
         mov       ah,8
         int       13h                      ; poskytnut° posledn° stopy
         jc        getdisk4                 ; nen° platnò disk
         xchg      ch,cl                    ; CL <- nië®° bajt á°sla stopy
         rol       ch,1
         rol       ch,1                     ; bity 8 a 9 á°sla stopy
         and       ch,3                     ; bity 8 a 9 á°sla stopy
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; bity 10 a 11 á°sla stopy
         and       dh,0ch                   ; bity 10 a 11 á°sla stopy
         xor       dl,dl
         or        dx,cx                    ; DX = á°slo posledn° stopy
         inc       dx                       ; DX = á°slo parkovac° stopy

getdisk4:pop       es
         ret
; -----------------------------------------------------------------------------
park:                                     ;* zaparkov†n° jednoho pevnÇho disku
                                            ; VSTUP: DL=á°slo disku
                                            ;        BX=á°slo stopy

         or        bx,bx                    ; je disk zad†n ?
         jz        park2                    ; neplatnò disk
         push      dx
         xor       ax,ax
         int       13h                      ; reset disku
         pop       dx
         mov       cx,5                     ; poáet pokusñ o parkov†n°
park1:   push      bx
         push      cx
         push      dx

         mov       ch,bl                    ; nië®° bajt á°sla v†lce
         mov       cl,bh                    ; vy®®° bajt á°sla v†lce
         ror       cl,1
         ror       cl,1                     ; bity 8 a 9 do bitñ 6 a 7
         and       cl,0c0h                  ; ponech† bity 6 a 7 (= 8 a 9)
         inc       cl                       ; -> sektor 1
         mov       dh,bh                    ; vy®®° bajt á°sla v†lce
         shl       dh,1
         shl       dh,1
         shl       dh,1
         shl       dh,1                     ; bity 10 a 11 do bitñ 6 a 7
         and       dh,0c0h                  ; ponech† bity 6 a 7 (= 10 a 11)
         mov       ah,0ch                   ; funkce vystaven° hlav
         int       13h                      ; vystaven° na parkovac° stopu

         pop       dx
         pop       cx
         pop       bx
         loop      park1                    ; novÇ zaparkov†n° disku
park2:   ret
; -----------------------------------------------------------------------------
testat:                                   ;* je poá°taá AT ?
                                            ; VùSTUP: CY=nen° AT
         push      ax
         push      ds
         mov       ax,0f000h                ; segment modulu BIOS
         mov       ds,ax                    ; segment modulu BIOS
         cmp       byte ptr ds:[0fffeh],0fch; je AT nebo XT-286 ?
         je        testat2                  ; je AT nebo XT-286
         stc                                ; p©°znak, ëe nen° AT
testat2: pop       ds
         pop       ax
         ret

parkc0   dw        0                        ; parkovac° stopa disku 0
parkc1   dw        0                        ; parkovac° stopa disku 1

disku    db        0                        ; poáet pevnòch diskñ

; -----------------------------------------------------------------------------
uvtxt    db        'HESLO: ',0
errtxt   db        ' ..... CHYBA !',7,13,10,0
oktxt    db        ' O.K. ',13,10,0
; -----------------------------------------------------------------------------
konec    label     near                     ; konec rezidentn° á†sti
                                          ;* zde se uloë° heslo
heslosys ends

rezerva  segment
         db        0ffffh dup(?)            ; rezerva pro heslo
rezerva  ends

         end       start

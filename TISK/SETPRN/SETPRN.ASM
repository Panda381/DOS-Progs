
; *****************************************************************************
;
;                 Vòstup inicializaán°ho souboru na tisk†rnu
;
;  Syntaxe souboru:
;        # soubor  - vno©enò soubor
;        {...}     - pozn†mka
;        ;...      - pozn†mka (po konec ©†dku)
;        "..."     - ASCII text
;        !         - nahrad° se znakem ESC (k¢d 27)
;        ?         - nahrad° se znakem FS (k¢d 28)
;        /         - nahrad° se znaky CR a LF (od©†dkov†n°)
;        $         - bude n†sledovat znak v hexadecim†ln°m k¢du
;        á°slo     - dekadick† hodnota bajtu k vysl†n°
;        ostatn°   - znak se vytiskne nezmànànà
;
; *****************************************************************************
code     segment
         ASSUME    cs:code,ds:code
         org       100h
start:
         mov       dx,offset uvtxt
         call      outtxt                   ; zobrazen° £vodn°ho textu
                                          ;* inicializace tisk†rny
         mov       bx,4                     ; identifik†tor tisk†rny
         mov       ax,4400h
         int       21h                      ; poskytnut° informac° o za©°zen°
         jc        start2                   ; chyba za©°zen°
         xor       dh,dh
         or        dl,20h                   ; nastaven° bin†rn°ho m¢du
         mov       ax,4401h
         int       21h                      ; nastaven° informac° o za©°zen°
         jnc       start1

start2:  mov       dx,offset errtxt2
         call      outtxt                   ; chyba tisk†rny
         int       20h

start1:
         mov       si,81h                   ; zaá†tek parametrñ
         xor       cx,cx
         mov       cl,ds:[80h]              ; poáet zadanòch znakñ

         call      soub                     ; dek¢dov†n° souboru DS:SI

         call      writebuf                 ; vypr†zdnàn° bufferu

         int       20h
; -----------------------------------------------------------------------------
dekod:                                    ;* dek¢dov†n° dat v pamàti DS:SI (CX)

dekod1:  call      outspc                   ; ignorov†n° oddàlovaáñ
         jc        dekod82                  ; konec textu
         cmp       al,"#"                   ; je vloëenò soubor ?
         jne       dekod3                   ; nen° vloëenò soubor

                                          ;* vloëenò soubor
         inc       si                       ; p©eskoáen° znaku "#"
         dec       cx
         push      bx                       ; £schova identifik†toru
         call      soub                     ; dek¢dov†n° dal®°ho souboru
         pop       bx                       ; n†vrat identifik†toru
         jc        dekod9                   ; chyba operace
         push      cx
         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h                      ; ukazatel na zaá†tek souboru
         mov       dx,offset diskbuf        ; vstupn° buffer
         mov       cx,0e000h
         sub       cx,dx                    ; maxim†ln° poáet znakñ
         mov       ah,3fh
         int       21h                      ; naáten° souboru do pamàti
         pop       cx
         jc        dekod9
         jmp       short dekod1             ; dek¢dov†n° dal®°ho znaku

                                          ;* ignorov†n° pozn†mky
dekod3:  cmp       al,"{"                   ; je pozn†mka ?
         jne       dekod5                   ; nen° pozn†mka
dekod4:  call      readch                   ; áten° dal®°ho znaku
dekod82: jc        dekod8                   ; konec textu
         cmp       al,"}"                   ; konec pozn†mky ?
         jne       dekod4                   ; nalezen° konce pozn†mky
         jmp       short dekod1             ; dal®° dek¢dov†n°

                                          ;* vysl†n° textu
dekod5:  cmp       al,'"'                   ; je text ?
         jne       dekod7                   ; nen° text
         inc       si                       ; p©eskoáen° znaku "
         dec       cx
dekod6:  call      readch                   ; áten° dal®°ho znaku
         jc        dekod8                   ; konec textu
         cmp       al,'"'                   ; je konec textu ?
         je        dekod1                   ; je konec textu
         call      writechar                ; je konec textu
         jc        dekod9                   ; chyba operace
         jmp       short dekod6             ; dak®° znak

                                          ;* dek¢dov†n° á°sla bajtu
dekod7:  call      readch
         jc        dekod8
         cmp       al,"?"                   ; je FS ?
         jne       dekod76
         mov       al,28
         jmp       short dekod73            ; vysl†n° znaku FS
dekod76: cmp       al,"!"                   ; je ESC ?
         jne       dekod72
         mov       al,27
         jmp       short dekod73            ; vysl†n° znaku ESC
dekod72: cmp       al,"/"                   ; je od©†dkov†n° ?
         jne       dekod74
         mov       al,13
         call      writechar                ; znak CR
         jc        dekod8
         mov       al,10
         jmp       short dekod73            ; znak LF
dekod74: cmp       al,";"
         je        dekoda                   ; je pozn†mka
         cmp       al,"$"
         je        dekodh                   ; je znak v HEX k¢du
         cmp       al,"0"
         jb        dekod73                  ; nen° á°slice
         cmp       al,"9"
         ja        dekod73                  ; nen° á°slice
         dec       si
         inc       cx
         call      readbyte                 ; áten° bajtu
dekod73: call      writechar                ; z†pis bajtu
         jnc       dekod10

dekod8:  clc
dekod9:  ret

dekoda:  call      readch                   ; áten° dal®°ho znaku
         jc        dekod8                   ; konec textu
         cmp       al,10                    ; konec pozn†mky ?
         jne       dekoda                   ; nalezen° konce pozn†mky
dekod10: jmp       dekod1                   ; dal®° dek¢dov†n°

dekodh:                                   ;* áten° znaku v HEX k¢du
         call      readhex                  ; áten° znaku v HEX k¢du
         jmp       short dekod73

; -----------------------------------------------------------------------------
soub:                                     ;* dek¢dov†n° souboru DS:SI (CX)

                                          ;* p©°prava jmÇna souboru
         call      outspc                   ; nalezen° zaá†tku jmÇna souboru
         jc        souberr                  ; chyba zad†n° souboru
         mov       dx,si                    ; zaá†tek jmÇna souboru
soub2:   call      readch                   ; naáten° dal®°ho znaku
         jb        soub3                    ; konec textu
         jnz       soub2                    ; nen° oddàlovaá - dal®° znak
         dec       si                       ; n†vrat znaku oddàlovaáe
         inc       cx                       ; n†vrat á°taáe znakñ
soub3:   mov       byte ptr ds:[si],0       ; oznaáen° konce jmÇna souboru
                                          ; otev©en° souboru
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        souberr                  ; chyba souboru (nenalezen)
         mov       bx,ax                    ; identifik†tor souboru

                                          ;* naáten° souboru do pamàti
         push      bx
         push      cx
         push      si
         mov       dx,offset diskbuf        ; vstupn° buffer
         mov       cx,0e000h
         sub       cx,dx                    ; maxim†ln° poáet znakñ
         mov       ah,3fh
         int       21h                      ; naáten° souboru do pamàti
         jc        soub5                    ; chyba operace
         mov       cx,ax                    ; poáet bajtñ v bufferu
         mov       si,offset diskbuf        ; zaá†tek diskovÇho bufferu
         call      dekod                    ; dek¢dov†n° textu
soub5:   pop       si
         pop       cx
         pop       bx

soub6:   pushf
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         popf
         jnc       soubret

souberr: mov       dx,offset errtxt1        ; text "Vstupni soubor nenalezen"
         call      outtxt
         stc                                ; chyba operace
soubret: ret

; -----------------------------------------------------------------------------
writechar:                                ;* z†pis znaku na tisk†rnu
                                            ; VSTUP: AL=znak k z†pisu
                                            ; VùSTUP: CY=chyba
         push      ax
         push      di
         mov       di,ds:[outnum]           ; poáet bajtñ v bufferu
         cmp       di,128                   ; je buffer jië plnò ?
         jb        writech2                 ; buffer je®tà nen° plnò
         call      writebuf                 ; vypr†zdnàn° bufferu
         jc        writech3                 ; chyba operace
         xor       di,di                    ; novò poáet bajtñ = 0
writech2:mov       ds:[di+outbuf],al        ; z†pis bajtu do bufferu
         inc       di                       ; zvò®en° ukazatele bufferu
         mov       ds:[outnum],di           ; £schova novÇho poátu bajtñ
         clc
writech3:pop       di
         pop       ax
         ret
; -----------------------------------------------------------------------------
writebuf:                                 ;* z†pis vòstupn°ho bufferu
                                            ; VùSTUP: CY=chyba z†pisu

         push      ax
         push      bx
         push      cx
         push      dx
         clc
         mov       cx,ds:[outnum]           ; poáet bajtñ v bufferu
         jcxz      writebf3                 ; nen° z†dnò bajt k z†pisu
         mov       bx,4                     ; identifik†tor tiskovÇho za©°zen°
         mov       dx,offset outbuf         ; vòstupn° buffer
         mov       ah,40h
         int       21h                      ; z†pis na tiskovÇ za©°zen°
         mov       word ptr ds:[outnum],0   ; vynulov†n° bufferu
writebf3:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
readhex:                                  ;* áten° bajtu v HEX k¢du
         push      dx
         xor       dx,dx
readhex1:call      readch
         jc        readhex4
         cmp       al,"a"
         jb        readhex5
         cmp       al,"z"
         ja        readhex5
         sub       al,32                    ; p©evod na velkÇ p°smeno
readhex5:sub       al,"0"
         jb        readhex3
         cmp       al,9
         jbe       readhex2
         sub       al,7
         cmp       al,9
         jbe       readhex3
         cmp       al,15
         ja        readhex3
readhex2:shl       dl,1
         shl       dl,1
         shl       dl,1
         shl       dl,1
         or        dl,al
         jmp       short readhex1
readhex3:dec       si
         inc       cx
readhex4:mov       al,dl
         pop       dx
         ret
; -----------------------------------------------------------------------------
readbyte:                                 ;* áten° bajtu
         push      dx
         xor       dx,dx
readbyt1:call      readch
         jc        readbyt4
         sub       al,"0"
         jb        readbyt3
         cmp       al,9
         ja        readbyt3
         mov       dh,al
         mov       al,10
         mul       dl
         add       al,dh
         mov       dl,al
         jmp       short readbyt1
readbyt3:dec       si
         inc       cx
readbyt4:mov       al,dl
         pop       dx
         ret
; -----------------------------------------------------------------------------
outspc:                                   ;* p©eskoáen° mezer
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ;        CX=poáet zbylòch znakñ
                                            ; VùSTUP:AL=n†sleduj°c° znak
                                            ;        CY=konec textu

         call      readch                   ; áten° dal®°ho znaku
         jc        outspc2                  ; konec textu
         jz        outspc                   ; je oddàlovaá - dal®° znak
         dec       si                       ; n†vrat p©eátenÇho znaku
         inc       cx
outspc2: ret
; -----------------------------------------------------------------------------
readch:                                   ;* áten° znaku z bufferu textu
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ;        CX=poáet zbylòch znakñ
                                            ; VùSTUP:AL=znak
                                            ;        CY=konec textu
                                            ;        ZY=je oddàlovaá

         xor       al,al
         stc                                ; p©°znak konce textu
         jcxz      readch2                  ; nen° dal®° znak - konec
         lodsb                              ; naáten° dal®°ho znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al," "
         je        readch2                  ; je mezera
         cmp       al,9
         je        readch2                  ; je tabel†tor
         cmp       al,10
         je        readch2                  ; je LF
         cmp       al,13
         je        readch2                  ; je CR
         or        al,al                    ; p©°znak NC, NZ
readch2: ret
; -----------------------------------------------------------------------------
outtxt:                                   ;* zobrazen° textu DS:DX
         push      ax
         push      dx
         push      si
         mov       si,dx
outtxt1: lodsb                              ; naáten° znaku k zobrazen°
         or        al,al
         jz        outtxt2                  ; je konec textu
         mov       dl,al                    ; znak k zobrazen°
         mov       ah,2
         int       21h                      ; zobrazen° znaku
         jmp       short outtxt1
outtxt2: pop       si
         pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
uvtxt    db        'SETPRN V1.10 - nastaveni tiskarny; (c) Miroslav Nemecek',13,10,0

errtxt1  db        'Definicni soubor pro tiskarnu nenalezen !',13,10,0

errtxt2  db        'Chyba vystupu na tiskarnu !',13,10,0

outnum   dw        0                        ; poáet znakñ ve vòstupn°m bufferu
outbuf   db        128 dup(0)               ; vòstupn° buffer

diskbuf  label     byte                     ; diskovò buffer

code     ends
         end       start

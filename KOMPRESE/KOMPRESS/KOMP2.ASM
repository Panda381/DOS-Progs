COMMENT %
              Pakov†n° souboru do form†tu KOMP (.PAK)
        %

;------------------------------------------------------------------------------
;                             Programovò segment
;------------------------------------------------------------------------------


buffersize equ     1000h                    ; velikost cyklickÇho bufferu
matchlimit equ     18                       ; maxim†ln° dÇlka shody
threshold  equ     2                        ; max. dÇlka shody pro k¢dov†n°

textbuf  equ       offset konec
konec0   equ       textbuf+buffersize+matchlimit ; konec dat


code     SEGMENT   page
         ASSUME    cs:code,ds:code

         org       100h                     ; zaá†tek programu COM

komp:                                       ; hlavn° tàlo programu
                                          ;* inicializace vlastn°ho z†sobn°ku
         cld                                ; smàr posunu ukazatele nahoru
         cli                                ; z†kaz p©eru®en°
         mov       word ptr [stack],sp      ; £schova ukazatele z†sobn°ku
         mov       word ptr [stack+2],ss    ; £schova segmentu ukazatele z†sob.
         mov       ax,cs                    ; segment programu
         mov       ss,ax                    ; segment programu
         mov       sp,offset stack          ; vlastn° z†sobn°k
         sti                                ; povolen° p©eru®en°
                                          ;* zde se uvoln° pamàü programu
         mov       bx,konec0                ; adresa konce p©idàlenÇ pamàti
         shr       bx,1                     ; BX / 2
         shr       bx,1                     ; BX / 4
         shr       bx,1                     ; BX / 8
         shr       bx,1                     ; BX / 16 - dÇlka programu
         inc       bx                       ; zaokrouhlen° dÇlky pamàti
         mov       ah,4ah                   ; funkce modifikace pamàti
         int       21h                      ; modifikace (uvolnàn°) pamàti
         jc        dekomp7                  ; chyba uvolnàn° pamàti
                                          ;* p©idàlen° bufferñ pro soubory
         mov       bx,0ffffh                ; poëadavek na p©idàlen° maxima RAM
         mov       ah,48h                   ; poëadavek na p©idàlen° pamàti
         int       21h                      ; poskytnut° maxim. volnÇ RAM
         shr       bx,1                     ; polovina volnÇ pamàti
         dec       bx
         mov       ah,48h                   ; funkce p©idàlen° pamàti
         int       21h                      ; p©idàlen° pamàti pro vstupn° buf.
         jc        dekomp7                  ; chyba p©idàlen° pamàti
         mov       ds:[segbuff1],ax         ; segment bufferu 1 (vstupn° soubor)
         mov       ah,48h                   ; funkce p©idàlen° pamàti
         int       21h                      ; p©idàlen° pamàti pro vòstupn° buf.
         jc        dekomp7                  ; chyba p©idàlen° pamàti
         mov       ds:[segbuff2],ax         ; segment buff. 2 (vòstupn° soubor)
         mov       word ptr ds:[writbyte+2],ax ; segment buff.2 (vòstupn° soubor)
         xor       dx,dx
         shl       bx,1                     ; BX * 2
         rcl       dx,1
         shl       bx,1                     ; BX * 4
         rcl       dx,1
         shl       bx,1                     ; BX * 8
         rcl       dx,1
         shl       bx,1                     ; BX * 16
         rcl       dx,1
         mov       word ptr ds:[delbuff1],bx ; dÇlka bufferu 1 (vstupn° soubor)
         mov       word ptr ds:[delbuff1+2],dx
         mov       word ptr ds:[delbuff2],bx ; dÇlka bufferu 2 (vòstupn° soubor)
         mov       word ptr ds:[delbuff2+2],dx
         or        bx,dx                    ; je alespo§ nàjakò buffer ?
         jnz       dekomp6                  ; buffer OK

                                          ;* chyba p©idàlen° pamàti
dekomp7: mov       dx,offset err2           ; chybovÇ hl†®en°
         mov       ah,9
         int       21h                      ; tisk chybovÇho hl†®en°
         mov       al,3                     ; n†vratovò k¢d - chyba RAM
         jmp       navrat                   ; n†vrat z programu

                                          ;* rozk¢dov†n° p©°kazovÇho ©†dku
dekomp6: mov       si,81h                   ; p©°kazovò ©†dek
         xor       cx,cx                    ; cx <- 0000
         mov       cl,ds:[80h]              ; poáet zadanòch znakñ
         jcxz      dekomp8                  ; nen° zad†n ë†dnò parametr - chyba
                                          ;* rozk¢dov†n° jmÇna vstupn°ho souboru
         mov       di,offset jmeno1         ; jmÇno vstupn°ho souboru
dekomp1: lodsb                              ; znak zad†n°
         cmp       al,20h                   ; je mezera nebo ©°dic° znak ?
         ja        dekomp3                  ; je platnò znak - p©enos
dekomp2: loop      dekomp1                  ; vypustàn° dal®°ho znaku
                                          ;* chyba zad†n° souborñ
dekomp8: mov       dx,offset uvtxt          ; £vodn° text
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn°ho textu
         mov       al,1                     ; ukonáen° programu s chybou
         jmp       short navrat             ; n†vrat z programu

dekomp3: stosb                              ; uloëen° platnÇho znaku
         lodsb                              ; naáten° dal®°ho znaku
         cmp       al,20h                   ; je platnò znak ?
         jna       dekomp4                  ; nen° platnò znak - konec jmÇna
         loop      dekomp3                  ; p©enos dal®°ho platnÇho znaku
dekomp4: xor       al,al                    ; koncovò znak '0'
         stosb                              ; uloëen° koncovÇho znaku jmÇna
         dec       si                       ; n†vrat ukazatele p©°kaz. ©†dku
         jcxz      dekomp8                  ; nen° zad†n dal®° parametr - chyba
                                          ;* rozk¢dov†n° jmÇna vòstupn°ho soub.
         mov       di,offset jmeno2         ; jmÇno vòstupn°ho souboru
dekom10: lodsb                              ; znak zad†n°
         cmp       al,20h                   ; je mezera nebo ©°dic° znak ?
         ja        dekom30                  ; je platnò znak - p©enos
dekom20: loop      dekom10                  ; vypustàn° dal®°ho znaku
         jmp       short dekomp8            ; nen° zad†n ë†dnò vòstupn° soubor
dekom30: stosb                              ; uloëen° platnÇho znaku
         lodsb                              ; naáten° dal®°ho znaku
         cmp       al,20h                   ; je platnò znak ?
         jna       dekom40                  ; nen° platnò znak - konec jmÇna
         loop      dekom30                  ; p©enos dal®°ho platnÇho znaku
dekom40: xor       al,al                    ; koncovò znak '0'
         stosb                              ; uloëen° koncovÇho znaku jmÇna
                                          ;* otev©en° vstupn°ho souboru
         mov       dx,offset jmeno1         ; vstupn° soubor
         mov       ah,3dh                   ; otev©en° souboru
         mov       al,0                     ; otev©en° pro áten°
         int       21h                      ; otev©en° souboru
         jnc       dekom91                  ; soubor otev©en OK
                                          ;* chyba vstupn°ho souboru
dekom5:  mov       dx,offset err1           ; chyba otev©en° souboru
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk chybovÇho textu
         mov       al,2                     ; k¢d chyby pro n†vrat
         jmp       short navrat             ; n†vrat z programu s chybou
dekom91:                                  ;* vytvo©en° vòstupn°ho souboru
         mov       [idents1],ax             ; identifik†tor vstupn°ho souboru
         mov       dx,offset jmeno2         ; vòstupn° soubor
         mov       ah,4eh                   ; nalezen° souboru
         mov       cx,0                     ; atributy souboru
         int       21h                      ; nalezen° souboru
         jnc       dek02                    ; soubor existuje - chyba
         mov       dx,offset jmeno2         ; vòstupn° soubor
         mov       ah,3ch                   ; vytvo©en° souboru
         mov       cx,0                     ; atributy souboru
         int       21h                      ; otev©en° souboru
         jnc       soubok                   ; soubory otev©eny OK
                                          ;* chyba vòstupn°ho souboru
dek02:   mov       dx,offset err3           ; chyba vòstupn°ho souboru
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk chybovÇho hl†®en°
         mov       al,4                     ; chybovò k¢d
         jmp       short navrat             ; n†vrat s chybou


                                          ;* n†vrat z programu
navrat:  push      ax                       ; £schova n†vratovÇho k¢du
         mov       ax,ds:[segbuff1]         ; segment bufferu vstupn°ho souboru
         mov       es,ax                    ; segment bufferu dat
         or        ax,ax                    ; je buffer p©idàlen ?
         jz        navr1                    ; nen° definov†n ë†dnò buffer
         mov       ah,49h                   ; funkce uvolnàn° pamàti
         int       21h                      ; uvolnàn° p©idàlenÇ pamàti
navr1:   mov       ax,ds:[segbuff2]         ; segment bufferu vòstupn°ho souboru
         mov       es,ax                    ; segment bufferu dat
         or        ax,ax                    ; je buffer p©idàlen ?
         jz        navr2                    ; nen° definov†n ë†dnò buffer
         mov       ah,49h                   ; funkce uvolnàn° pamàti
         int       21h                      ; uvolnàn° p©idàlenÇ pamàti
navr2:   mov       bx,ds:[idents1]          ; identifik†tor vstupn°ho souboru
         or        bx,bx                    ; je vstupn° soubor otev©en ?
         jz        navr3                    ; vstupn° soubor nen° otev©en
         mov       ah,3eh                   ; funkce uzav©en° identifik†toru
         int       21h                      ; uzav©en° identifik†toru souboru
navr3:   mov       bx,ds:[idents2]          ; identifik†tor vòstupn°ho souboru
         or        bx,bx                    ; je vòstupn° soubor otev©en ?
         jz        navr4                    ; vòstupn° soubor nen° otev©en
         mov       ah,3eh                   ; funkce uzav©en° identifik†toru
         int       21h                      ; uzav©en° identifik†toru souboru
navr4:   pop       ax                       ; AL=n†vratovò k¢d
         cli                                ; z†kaz p©eru®en°
         mov       sp,word ptr ds:[stack]   ; n†vrat ukazatele z†sobn°ku
         mov       ss,word ptr ds:[stack+2] ; n†vrat segmentu ukazatele z†sob.
         sti                                ; povolen° p©eru®en°
         mov       ah,4ch                   ; funkce n†vratu
         int       21h                      ; ukonáen° programu


soubok:                                   ;* soubory otev©eny OK
         mov       [idents2],ax             ; identifik†tor vòstupn°ho souboru
         jmp       encode                   ; zak¢dov†n° souboru
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop

; -----------------------------------------------------------------------------
;                       rozpakov†n° souboru
; -----------------------------------------------------------------------------

count    dw        1000                     ; á°taá pro tisk
matchposit dw      0                        ; poloha shody
matchlen dw        0                        ; dÇlka shody
len      dw        0                        ; dÇlka naátenÇ posloupnosti
r        dw        textbuf+buffersize-matchlimit ; adresa ke zpracov†n° dat
s        dw        textbuf                  ; adresa k ukl†d†n° dat (zaá. buf.)
mask     db        1                        ; maska
bufptr   dw        1                        ; á°taá bajtñ v bufferu k¢du
codebuf  db        17 dup(0)                ; buffer k¢du
                                            ; prvn° bajt je n†và®t° 8 bitñ:
                                            ; "1"=nek¢dovanò znak (1 bajt)
                                            ; "0"=k¢d <pozice;dÇlka> (2 bajty)
                                            ; n†sleduje 8 bajtñ/slov k¢du

encode:                                     ; zak¢dov†n° souboru
                                            ; pouëit° registrñ:
                                            ;  DS:SI=adresa ke zpracov†n° dat
                                            ;  ES:DI=adresa k ukl†d†n° dat

         mov       di,textbuf               ; zaá†tek bufferu
         mov       cx,buffersize-matchlimit ; velikost bufferu
         mov       al,20h                   ; znak mezery pro inicializaci
         rep       stosb                    ; naplnàn° bufferu mezerami
                                          ;* naáten° jednÇ dÇlky dat
         mov       si,di                    ; adresa ke zpracov†n° dat
         mov       cx,matchlimit            ; poáet bajtñ k naáten°
encode1: call      readb                    ; naáten° bajtu dat
         jc        encode2                  ; nejsou dal®° data
         stosb                              ; uloëen° bajtu dat
         inc       word ptr [len]           ; zvò®en° dÇlky naátenÇ posloupnosti
         loop      encode1                  ; naáten° dal®°ho bajtu
encode2: mov       di,textbuf               ; adresa k ukl†d†n° - zaá. bufferu
         cmp       word ptr ds:[len],0      ; jsou naátena nàjak† data ?
         jnz       encode4                  ; byla naátena nàjak† data
encode3: stc                                ; p©°znak vypr†zdnàn° bufferu
         call      writeb                   ; vypr†zdnàn° bufferu
         jmp       navrat                   ; n†vrat z programu

encode4:                                  ;* zaá†tek cyklu - zak¢dov†n° dat
         call      findstr                  ; nalezen° ©etàzce dat DS:SI
                                          ;* omezen° dÇlky shody na konci soub.
         mov       ax,ds:[len]              ; dÇlka naátenòch dat
         cmp       ax,ds:[matchlen]         ; dÇlka nalezenÇ shody
         jnb       encode5                  ; dÇlka nen° men®° neë dÇlka shody
         mov       [matchlen],ax            ; omezen° dÇlky shody na dÇlku dat
encode5:                                  ;* rozhodnut°, zda jsou kompres. data
         cmp       word ptr [matchlen],threshold ; kontrola minim. poátu bajtñ
         ja        encode6                  ; shoda je dostateánà dlouh†
                                          ;* shoda kr†tk† - p©enos 1 bajtu dat
         mov       word ptr [matchlen],1    ; vy®le se 1 bajt
         mov       al,ds:[mask]             ; maska
         or        ds:[codebuf],al          ; nastaven° masky
         lodsb                              ; naáten° bajtu ke zpracov†n°
         dec       si                       ; n†vrat zdrojovÇ adresy
         mov       bx,ds:[bufptr]           ; ukazatel v bufferu k¢du
         mov       [bx+codebuf],al          ; uloëen° do bufferu k¢du
         inc       word ptr [bufptr]        ; zvò®en° ukazatele v bufferu
         jmp       encode7                  ; pokraáov†n° v k¢dov†n°
encode6:                                  ;* shoda dostateán† - zak¢dov†n° ©et.
         mov       al,byte ptr ds:[matchposit] ; nië®° bajt polohy shody
         mov       bx,ds:[bufptr]           ; ukazatel v bufferu k¢du
         mov       [bx+codebuf],al          ; uloëen° bajtu polohy do bufferu
         mov       al,byte ptr ds:[matchposit+1] ; vy®®° bajt polohy shody
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1                     ; rotace o 4 bity vlevo
         mov       ah,byte ptr ds:[matchlen] ; dÇlka shody
         sub       ah,threshold+1           ; odeáten° minim†ln°ho poátu
         or        al,ah                    ; druhò bajt k¢du
         mov       [bx+codebuf+1],al        ; uloëen° bajtu dÇlky do bufferu
         add       word ptr [bufptr],2      ; zvò®en° ukazatele v bufferu
encode7:                                  ;* rotace masky - dal®° k¢d
         shl       byte ptr ds:[mask],1     ; rotace masky o bit vlevo
         cmp       byte ptr ds:[mask],0     ; je maska = 0 ?
         jne       encode9                  ; maska nen° = 0
                                          ;* je jië 8 k¢dñ - vypr†zdnàn° bufferu
         push      si                       ; £schova adresy ke zpracov†n°
         mov       si,offset codebuf        ; zaá†tek bufferu k¢du
         mov       cx,ds:[bufptr]           ; poáet dat v bufferu
encode8: lodsb                              ; bajt z bufferu k¢du
         clc                                ; p©°znak - z†pis bajtu na vòstup
         call      writeb                   ; z†pis bajtu do souboru
         loop      encode8                  ; dal®° bajt
         pop       si                       ; n†vrat adresy ke zpracov†n°
         mov       byte ptr ds:[codebuf],0  ; nulov†n° n†và®t° k¢du
         mov       byte ptr ds:[mask],1     ; nastaven° masky
         mov       word ptr ds:[bufptr],1   ; nastaven° ukazatele bufferu k¢du
                                          ;* naáten° dal®°ch dat ze souboru
encode9: mov       cx,ds:[matchlen]         ; dÇlka shody = poáet bajtñ v buff.
         add       si,cx                    ; zvò®en° adresy ke zpracov†n°
         cmp       si,textbuf+buffersize    ; byl p©ekroáen konec bufferu ?
         jb        encodea                  ; konec bufferu je®tà nep©ekroáen
         sub       si,buffersize            ; p©evod na zaá†tek bufferu
encodea: call      readb                    ; áten° bajtu ze souboru
         jnc       encodeb                  ; jsou dal®° data
         dec       word ptr ds:[len]        ; sn°ëen° poátu naátenòch dat
encodeb: stosb                              ; uloëen° bajtu do bufferu
         cmp       di,textbuf+matchlimit+1  ;
         jnb       encodec                  ; nen° men®°
         push      di
         add       di,buffersize-1          ; adresa kopie bufferu
         stosb                              ; duplik. uloëen° bajtu do bufferu
         pop       di                       ; n†vrat ukazatele k ukl†d†n°
encodec: cmp       di,textbuf+buffersize    ; je jië dosaëeno konce bufferu ?
         jb        encoded                  ; nep©esahuje je®tà konec bufferu
         sub       di,buffersize            ; zaá†tek kruhovÇho bufferu
encoded: loop      encodea                  ; naáten° dal®°ho bajtu dat

         dec       word ptr [count]
         jne       encodeg
         mov       dl,"."
         mov       ah,2
         int       21h
         mov       word ptr [count],1000

encodeg:
         cmp       word ptr ds:[len],1      ; bylo je®tà nàco naáteno ?
         jl        encodee                  ; nejsou dal®° data - konec
         jmp       encode4                  ; dal®° zpracov†n°

encodee:
         mov       si,offset codebuf        ; zaá†tek bufferu k¢du
         mov       cx,ds:[bufptr]           ; poáet dat v bufferu
encodef: lodsb                              ; bajt z bufferu k¢du
         clc
         call      writeb                   ; z†pis bajtu do souboru
         loop      encodef                  ; dal®° bajt
         jmp       encode3                  ; konec

findstr:                                    ; nalezen° ©etàzce DS:SI
         mov       word ptr ds:[matchlen],0 ; vòchoz° dÇlka shody = 0
         push      di                       ; £schova adresy k ukl†d†n°
         mov       di,textbuf-1             ; zaá†tek kruhovÇho bufferu
         mov       cx,buffersize            ; velikost bufferu
findst0: inc       di                       ; n†sleduj°c° ©etàzec
         mov       al,ds:[si]               ; bajt k nalezen°
         repnz     scasb                    ; nalezen° shodnÇho bajtu
         jnz       findst8                  ; nejsou nalezena dal®° data
         dec       di                       ; n†vrat adresy textu
         push      cx                       ; £schova CX (á°taá dat)
         push      di                       ; £schova DI (testovanò ©etàzec)
         push      si                       ; £schova SI (hledanò ©etàzec)
         mov       cx,matchlimit            ; max. poáet porovn†vanòch bajtñ
         rep       cmpsb                    ; kontrola shody ©etàzcñ
         pop       si                       ; n†vrat SI (hledanò ©etàzec)
         pop       di                       ; n†vrat DI (testovanò ©etàzec)
         mov       ax,matchlimit            ; max. poáet porovn†vanòch bajtñ
         sub       ax,cx                    ; poáet shodnòch bajtñ
         pop       cx                       ; n†vrat CX (á°taá dat)
         cmp       ax,ds:[matchlen]         ; porovn†n° s jië nalezenou shodou
         jng       findst0                  ; shoda nen° vàt®° - dal®° ©etàzec
         cmp       di,si                    ; je pod hledanòm ©etàzcem ?
         jb        findst1                  ; nalezenò ©etàzec je pod hledanòm
         push      si                       ; £schova SI (hledanò ©etàzec)
         add       si,matchlimit            ; konec hledanÇho ©etàzce
         cmp       di,si                    ; je nad hledanòm ©etàzcem ?
         pop       si                       ; n†vrat SI (hledanò ©etàzec)
         jb        findst0                  ; je v oblasti hledanÇho ©etàzce
findst1: mov       ds:[matchlen],ax         ; nov† dÇlka nalezenÇho ©etàzce
         push      di
         sub       di,textbuf
         mov       ds:[matchposit],di       ; nov† adresa nalezenÇho ©etàzce
         pop       di
         jmp       findst0                  ; hled†n° dal®°ho ©etàzce
findst8: pop       di                       ; n†vrat adresy k ukl†d†n° dat
         ret




; -----------------------------------------------------------------------------


readb:                                      ; áten° bajtu ze souboru
                                            ; VùSTUP: AL=bajt (pokud CN)
                                            ;         CY=nejsou dal®° data

         cmp       word ptr cs:[pocbyte1],0 ; jsou nàjak† data v bufferu ?
         jne       readb1                   ; jsou dal®° data
         cmp       word ptr cs:[pocbyte1+2],0 ; jsou nàjak† data v bufferu ?
         jne       readb1                   ; jsou dal®° data
                                           ;* naáten° dat do bufferu
         call      readbuf                  ; áten° bloku 64KB
         jc        readb2                   ; chyba áten°
readb3:  call      readbuf                  ; áten° dal®°ho bloku 64KB
         jnc       readb3                   ; naáten° dal®°ch dat
         mov       word ptr ds:[readbyte],0 ; offset adresy átenÇho bajtu
         mov       ax,ds:[segbuff1]         ; segment adresy átenÇho bajtu
         mov       word ptr ds:[readbyte+2],ax ; segment adresy átenÇho bajtu
                                          ;* p©eáten° bajtu z bufferu
readb1:  push      si                       ; £schova SI
         push      ds                       ; £schova DS
         lds       si,ds:[readbyte]         ; adresa ke áten° bajtu
         cld                                ; smàr posunu ukazatele nahoru
         lodsb                              ; naáten° dal®°ho bajtu dat
         pop       ds                       ; n†vrat DS
         pop       si                       ; n†vrat SI
         inc       word ptr ds:[readbyte]   ; zvò®en° átec° adresy bajtu
         jnz       readb10                  ; nen° p©eteáen° p©es okraj segmentu
         add       word ptr ds:[readbyte+2],1000h ; zvò®en° adresy segmentu
readb10: sub       word ptr ds:[pocbyte1],1 ; sn°ëen° poátu uloëenòch bajtñ
         jnc       readb11                  ; nen° p©enos
         dec       word ptr ds:[pocbyte1+2] ; p©enos do vy®®°ho slova
readb11: clc                                ; p©°znak - áten° OK
readb2:  ret

readbuf:                                    ; naáten° dat 64KB ze vstup. souboru
                                            ; VùSTUP: CY=nelze á°st dal®° data

         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       ax,word ptr ds:[delbuff1] ; dÇlka bufferu vstupn°ho souboru
         sub       ax,word ptr ds:[pocbyte1] ; vòpoáet volnÇho m°sta
         mov       cx,ax                    ; poáet volnòch bajtñ
         mov       ax,word ptr ds:[delbuff1+2] ; dÇlka bufferu - vy®®° slovo
         sbb       ax,word ptr ds:[pocbyte1+2] ; vy®®° slovo poátu bajtñ
         jz        readb6                   ; nen° vàt®° neë FFFFh bajtñ
         mov       cx,0ffffh                ; n†hradn° poáet bajtñ ke áten°
readb6:  jcxz      readb8                   ; chyba - nen° volnÇ m°sto
         push      ds                       ; £schova DS
         lds       dx,ds:[pocbyte1]         ; poáet bajtñ v bufferu
         mov       ax,dx                    ; nië®° slovo poátu bajtñ
         mov       bx,ds                    ; vy®®° slovo poátu bajtñ
         and       dx,0fh                   ; korekce do jednoho odstavce
         shr       bx,1                     ; BX/2
         rcr       ax,1
         shr       bx,1                     ; BX/4
         rcr       ax,1
         shr       bx,1                     ; BX/8
         rcr       ax,1
         shr       bx,1                     ; BX/16 - poáet odstavcñ
         rcr       ax,1
         add       ax,cs:[segbuff1]         ; poá†teán° segment bufferu
         mov       ds,ax                    ; segment zaá†tku dat
         mov       bx,cs:[idents1]          ; identifik†tor vstupn°ho souboru
         mov       ah,3fh                   ; funkce áten° ze souboru
         int       21h                      ; naáten° dat z bufferu
         pop       ds
         jnc       readb7                   ; áten° ze souboru OK
         jmp       dekom5                   ; chyba vstupn°ho souboru
readb7:  add       word ptr [pocbyte1],ax   ; zvò®en° poátu bajtñ
         adc       word ptr [pocbyte1+2],0  ; p©iáten° p©enosu
         or        ax,ax                    ; jsou naátena nàjak† data ?
         jnz       readb9                   ; jsou naátena data
readb8:  stc                                ; p©°znak - nejsou dal®° data
readb9:  pop       dx
         pop       cx
         pop       bx
         ret


                                          ; * vstupn° soubor
jmeno1   db        128 dup(0)               ; jmÇno vstupn°ho souboru
idents1  dw        0                        ; identifikace zdrojovÇho souboru
readbyte dd        0                        ; adresa ke áten° bajtu
segbuff1 dw        0                        ; adresa datovÇho bufferu 1 (segm.)
pocbyte1 dd        0                        ; poáet bajtñ v bufferu vstup.soub.
delbuff1 dd        0                        ; dÇlka datovÇho bufferu vstup.soub.


writeb:                                     ; z†pis bajtu do souboru
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;        CY=vypr†zdnàn° bufferu
                                            ; VùSTUP: CY=chyba z†pisu do souboru

                                          ;* z†pis bajtu do bufferu
         push      ax
         jc        writb4                   ; vypr†zdnàn° bufferu
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         les       di,ds:[writbyte]         ; adresa k z†pisu bajtu
         cld                                ; smàr posunu ukazatele nahoru
         stosb                              ; uloëen° dal®°ho bajtu dat
         pop       es                       ; n†vrat ES
         pop       di                       ; n†vrat DI
         inc       word ptr ds:[writbyte]   ; zvò®en° ukl†dac° adresy bajtu
         jnz       writb10                  ; nen° p©eteáen° p©es okraj segmentu
         add       word ptr ds:[writbyte+2],1000h ; zvò®en° adresy segmentu
writb10: add       word ptr ds:[pocbyte2],1 ; zvò®en° poátu uloëenòch bajtñ
         jnc       writb11                  ; nen° p©enos
         inc       word ptr ds:[pocbyte2+2] ; p©enos do vy®®°ho slova
writb11:
         mov       ax,word ptr ds:[pocbyte2+2] ; vy®®° slovo poátu bajtñ
         cmp       ax,word ptr ds:[delbuff2+2] ; kontrola s dÇlkou bufferu
         jne       writb12                  ; nen° shoda
         mov       ax,word ptr ds:[pocbyte2] ; nië®° slovo poátu bajtñ
         cmp       ax,word ptr ds:[delbuff2] ; kontrola s dÇlkou bufferu
writb12: jc        writb5                   ; buffer je®tà nen° zaplnàn
writb4:                                   ;* uloëen° dat z bufferu
         mov       word ptr ds:[writbyte],0 ; offset adresy zapisovanÇho bajtu
         mov       ax,ds:[segbuff2]         ; segment adresy zapisovanÇho bajtu
         mov       word ptr ds:[writbyte+2],ax ; segment adresy zapisov. bajtu
         call      writbuf                  ; z†pis bloku 64KB
         jc        writb2                   ; chyba z†pisu
writb3:  call      writbuf                  ; z†pis dal®°ho bloku 64KB
         jnc       writb3                   ; z†pis dal®°ch dat
         mov       word ptr ds:[writbyte],0 ; offset adresy zapisovanÇho bajtu
         mov       ax,ds:[segbuff2]         ; segment adresy zapisovanÇho bajtu
         mov       word ptr ds:[writbyte+2],ax ; segment adresy zapisov. bajtu
writb5:  clc                                ; p©°znak - z†pis OK
writb2:  pop       ax
         ret



writbuf:                                    ; z†pis dat 64KB do vòstup. souboru
                                            ; VùSTUP: CY=nelze zapsat dal®° data

         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       cx,word ptr ds:[pocbyte2] ; poáet bajtñ v bufferu
         cmp       word ptr ds:[pocbyte2+2],0 ; vy®®° slovo poátu bajtñ
         jz        writb6                   ; nen° vàt®° neë FFFFh bajtñ
         mov       cx,0ffffh                ; n†hradn° poáet bajtñ ke áten°
writb6:  jcxz      writb8                   ; chyba - nejsou dal®° data
         push      ds                       ; £schova DS
         lds       dx,ds:[writbyte]         ; adresa dat k z†pisu
         mov       bx,dx                    ; nië®° slovo adresy
         and       dx,0fh                   ; korekce do jednoho odstavce
         shr       bx,1                     ; BX/2
         shr       bx,1                     ; BX/4
         shr       bx,1                     ; BX/8
         shr       bx,1                     ; BX/16 - poáet odstavcñ
         mov       ax,ds                    ; segment adresy
         add       ax,bx                    ; p©iáten° p©enosu z offsetu
         mov       ds,ax                    ; segment zaá†tku dat
         mov       bx,cs:[idents2]          ; identifik†tor vòstupn°ho souboru
         mov       ah,40h                   ; funkce z†pis do souboru
         int       21h                      ; z†pis dat do bufferu
         pop       ds
         jc        writb9                   ; chyba z†pisu do souboru
         add       word ptr [writbyte],ax   ; zvò®en° adresy
         jnc       writb7                   ; nen° p©enos
         add       word ptr [writbyte+2],1000h ; p©iáten° p©enosu do segmentu
writb7:  sub       word ptr [pocbyte2],ax   ; sn°ëen° poátu bajtñ v bufferu
         sbb       word ptr [pocbyte2+2],0  ; p©enos do vy®®°ho slova
         or        ax,ax                    ; byla zaps†na nàjak† data ?
         jnz       writb9                   ; byla zaps†na nàjak† data
writb8:  stc                                ; p©°znak - nelze provÇst z†pis
writb9:  pop       dx
         pop       cx
         pop       bx
         ret




                                          ; * vòstupn° soubor
jmeno2   db        128 dup(0)               ; jmÇno vòstupn°ho souboru
idents2  dw        0                        ; identifikace c°lovÇho souboru
writbyte dd        0                        ; adresa k z†pisu bajtu
segbuff2 dw        0                        ; adresa datovÇho bufferu 2 (segm.)
pocbyte2 dd        0                        ; poáet bajtñ v bufferu vòstup.soub.
delbuff2 dd        0                        ; dÇlka datovÇho bufferu vòst.soub.

uvtxt    db        'Pakov†n° souboru: KOMP <vstup.soub.> <vòstup.soub.>'
         db        13,10,'$'

err1     db        'Vstupn° soubor nenalezen nebo chyba áten° !',13,10,'$'

err2     db        'Chyba p©idàlen° pamàti !',13,10,'$'

err3     db        'Vòstupn° soubor jië existuje nebo chyba z†pisu !',13,10,'$'

         dw        256 dup(0)               ; z†sobn°k
stack    dd        0                        ; vlastn° z†sobn°k


konec:                                      ; konec programu

; Buffer (um°stàn za programem)

; textbuf    db      buffersize+matchlimit dup(?) ; cyklickò buffer

code     ENDS

         END       komp                     ; startovac° adresa

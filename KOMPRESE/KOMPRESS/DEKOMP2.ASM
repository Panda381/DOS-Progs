COMMENT %
              Rozpakov n¡ souboru z form tu programu KOMP.COM
        %

;------------------------------------------------------------------------------
;                             Programov˜ segment
;------------------------------------------------------------------------------


buffersize equ     1000h                    ; velikost cyklick‚ho bufferu
matchlimit equ     18                       ; maxim ln¡ d‚lka shody
threshold  equ     2                        ; max. d‚lka shody pro k¢dov n¡

textbuf  equ       offset konec
konec0   equ       textbuf+buffersize+matchlimit ; konec dat


code     SEGMENT   page
         ASSUME    cs:code,ds:code,ss:code

         org       100h                     ; za‡ tek programu COM

dekomp:                                     ; hlavn¡ tˆlo programu
                                          ;* inicializace vlastn¡ho z sobn¡ku
         cld                                ; smˆr posunu ukazatele nahoru
         cli                                ; z kaz p©eru¨en¡
         mov       word ptr [stack],sp      ; £schova ukazatele z sobn¡ku
         mov       word ptr [stack+2],ss    ; £schova segmentu ukazatele z sob.
         mov       ax,cs                    ; segment programu
         mov       ss,ax                    ; segment programu
         mov       sp,offset stack          ; vlastn¡ z sobn¡k
         sti                                ; povolen¡ p©eru¨en¡
                                          ;* zde se uvoln¡ pamˆŸ programu
         mov       bx,konec0                ; adresa konce p©idˆlen‚ pamˆti
         shr       bx,1                     ; BX / 2
         shr       bx,1                     ; BX / 4
         shr       bx,1                     ; BX / 8
         shr       bx,1                     ; BX / 16 - d‚lka programu
         inc       bx                       ; zaokrouhlen¡ d‚lky pamˆti
         mov       ah,4ah                   ; funkce modifikace pamˆti
         int       21h                      ; modifikace (uvolnˆn¡) pamˆti
         jc        dekomp7                  ; chyba uvolnˆn¡ pamˆti
                                          ;* p©idˆlen¡ buffer– pro soubory
         mov       bx,0ffffh                ; po‘adavek na p©idˆlen¡ maxima RAM
         mov       ah,48h                   ; po‘adavek na p©idˆlen¡ pamˆti
         int       21h                      ; poskytnut¡ maxim. voln‚ RAM
         shr       bx,1                     ; polovina voln‚ pamˆti
         dec       bx
         mov       ah,48h                   ; funkce p©idˆlen¡ pamˆti
         int       21h                      ; p©idˆlen¡ pamˆti pro vstupn¡ buf.
         jc        dekomp7                  ; chyba p©idˆlen¡ pamˆti
         mov       ds:[segbuff1],ax         ; segment bufferu 1 (vstupn¡ soubor)
         mov       ah,48h                   ; funkce p©idˆlen¡ pamˆti
         int       21h                      ; p©idˆlen¡ pamˆti pro v˜stupn¡ buf.
         jc        dekomp7                  ; chyba p©idˆlen¡ pamˆti
         mov       ds:[segbuff2],ax         ; segment buff. 2 (v˜stupn¡ soubor)
         mov       word ptr ds:[writbyte+2],ax ; segment buff.2 (v˜stupn¡ soubor)
         xor       dx,dx
         shl       bx,1                     ; BX * 2
         rcl       dx,1
         shl       bx,1                     ; BX * 4
         rcl       dx,1
         shl       bx,1                     ; BX * 8
         rcl       dx,1
         shl       bx,1                     ; BX * 16
         rcl       dx,1
         mov       word ptr ds:[delbuff1],bx ; d‚lka bufferu 1 (vstupn¡ soubor)
         mov       word ptr ds:[delbuff1+2],dx
         mov       word ptr ds:[delbuff2],bx ; d‚lka bufferu 2 (v˜stupn¡ soubor)
         mov       word ptr ds:[delbuff2+2],dx
         or        bx,dx                    ; je alespo¤ nˆjak˜ buffer ?
         jnz       dekomp6                  ; buffer OK

                                          ;* chyba p©idˆlen¡ pamˆti
dekomp7: mov       dx,offset err2           ; chybov‚ hl ¨en¡
         mov       ah,9
         int       21h                      ; tisk chybov‚ho hl ¨en¡
         mov       al,3                     ; n vratov˜ k¢d - chyba RAM
         jmp       navrat                   ; n vrat z programu

                                          ;* rozk¢dov n¡ p©¡kazov‚ho © dku
dekomp6: mov       si,81h                   ; p©¡kazov˜ © dek
         xor       cx,cx                    ; cx <- 0000
         mov       cl,ds:[80h]              ; po‡et zadan˜ch znak–
         jcxz      dekomp8                  ; nen¡ zad n ‘ dn˜ parametr - chyba
                                          ;* rozk¢dov n¡ jm‚na vstupn¡ho souboru
         mov       di,offset jmeno1         ; jm‚no vstupn¡ho souboru
dekomp1: lodsb                              ; znak zad n¡
         cmp       al,20h                   ; je mezera nebo ©¡dic¡ znak ?
         ja        dekomp3                  ; je platn˜ znak - p©enos
dekomp2: loop      dekomp1                  ; vypustˆn¡ dal¨¡ho znaku
                                          ;* chyba zad n¡ soubor–
dekomp8: mov       dx,offset uvtxt          ; £vodn¡ text
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn¡ho textu
         mov       al,1                     ; ukon‡en¡ programu s chybou
         jmp       short navrat             ; n vrat z programu

dekomp3: stosb                              ; ulo‘en¡ platn‚ho znaku
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         cmp       al,20h                   ; je platn˜ znak ?
         jna       dekomp4                  ; nen¡ platn˜ znak - konec jm‚na
         loop      dekomp3                  ; p©enos dal¨¡ho platn‚ho znaku
dekomp4: xor       al,al                    ; koncov˜ znak '0'
         stosb                              ; ulo‘en¡ koncov‚ho znaku jm‚na
         dec       si                       ; n vrat ukazatele p©¡kaz. © dku
         jcxz      dekomp8                  ; nen¡ zad n dal¨¡ parametr - chyba
                                          ;* rozk¢dov n¡ jm‚na v˜stupn¡ho soub.
         mov       di,offset jmeno2         ; jm‚no v˜stupn¡ho souboru
dekom10: lodsb                              ; znak zad n¡
         cmp       al,20h                   ; je mezera nebo ©¡dic¡ znak ?
         ja        dekom30                  ; je platn˜ znak - p©enos
dekom20: loop      dekom10                  ; vypustˆn¡ dal¨¡ho znaku
         jmp       short dekomp8            ; nen¡ zad n ‘ dn˜ v˜stupn¡ soubor
dekom30: stosb                              ; ulo‘en¡ platn‚ho znaku
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         cmp       al,20h                   ; je platn˜ znak ?
         jna       dekom40                  ; nen¡ platn˜ znak - konec jm‚na
         loop      dekom30                  ; p©enos dal¨¡ho platn‚ho znaku
dekom40: xor       al,al                    ; koncov˜ znak '0'
         stosb                              ; ulo‘en¡ koncov‚ho znaku jm‚na
                                          ;* otev©en¡ vstupn¡ho souboru
         mov       dx,offset jmeno1         ; vstupn¡ soubor
         mov       ah,3dh                   ; otev©en¡ souboru
         mov       al,0                     ; otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ souboru
         jnc       dekom91                  ; soubor otev©en OK
                                          ;* chyba vstupn¡ho souboru
dekom5:  mov       dx,offset err1           ; chyba otev©en¡ souboru
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk chybov‚ho textu
         mov       al,2                     ; k¢d chyby pro n vrat
         jmp       short navrat             ; n vrat z programu s chybou
dekom91:                                  ;* vytvo©en¡ v˜stupn¡ho souboru
         mov       [idents1],ax             ; identifik tor vstupn¡ho souboru
         mov       dx,offset jmeno2         ; v˜stupn¡ soubor
         mov       ah,4eh                   ; nalezen¡ souboru
         mov       cx,0                     ; atributy souboru
         int       21h                      ; nalezen¡ souboru
         jnc       dek02                    ; soubor existuje - chyba
         mov       dx,offset jmeno2         ; v˜stupn¡ soubor
         mov       ah,3ch                   ; vytvo©en¡ souboru
         mov       cx,0                     ; atributy souboru
         int       21h                      ; otev©en¡ souboru
         jnc       soubok                   ; soubory otev©eny OK
                                          ;* chyba v˜stupn¡ho souboru
dek02:   mov       dx,offset err3           ; chyba v˜stupn¡ho souboru
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk chybov‚ho hl ¨en¡
         mov       al,4                     ; chybov˜ k¢d
         jmp       short navrat             ; n vrat s chybou


                                          ;* n vrat z programu
navrat:  push      ax                       ; £schova n vratov‚ho k¢du
         mov       ax,ds:[segbuff1]         ; segment bufferu vstupn¡ho souboru
         mov       es,ax                    ; segment bufferu dat
         or        ax,ax                    ; je buffer p©idˆlen ?
         jz        navr1                    ; nen¡ definov n ‘ dn˜ buffer
         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ p©idˆlen‚ pamˆti
navr1:   mov       ax,ds:[segbuff2]         ; segment bufferu v˜stupn¡ho souboru
         mov       es,ax                    ; segment bufferu dat
         or        ax,ax                    ; je buffer p©idˆlen ?
         jz        navr2                    ; nen¡ definov n ‘ dn˜ buffer
         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ p©idˆlen‚ pamˆti
navr2:   mov       bx,ds:[idents1]          ; identifik tor vstupn¡ho souboru
         or        bx,bx                    ; je vstupn¡ soubor otev©en ?
         jz        navr3                    ; vstupn¡ soubor nen¡ otev©en
         mov       ah,3eh                   ; funkce uzav©en¡ identifik toru
         int       21h                      ; uzav©en¡ identifik toru souboru
navr3:   mov       bx,ds:[idents2]          ; identifik tor v˜stupn¡ho souboru
         or        bx,bx                    ; je v˜stupn¡ soubor otev©en ?
         jz        navr4                    ; v˜stupn¡ soubor nen¡ otev©en
         mov       ah,3eh                   ; funkce uzav©en¡ identifik toru
         int       21h                      ; uzav©en¡ identifik toru souboru
navr4:   pop       ax                       ; AL=n vratov˜ k¢d
         cli                                ; z kaz p©eru¨en¡
         mov       sp,word ptr ds:[stack]   ; n vrat ukazatele z sobn¡ku
         mov       ss,word ptr ds:[stack+2] ; n vrat segmentu ukazatele z sob.
         sti                                ; povolen¡ p©eru¨en¡
         mov       ah,4ch                   ; funkce n vratu
         int       21h                      ; ukon‡en¡ programu


soubok:                                   ;* soubory otev©eny OK
         mov       [idents2],ax             ; identifik tor v˜stupn¡ho souboru
         jmp       soub001
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop

; -----------------------------------------------------------------------------
;                       rozpakov n¡ souboru
; -----------------------------------------------------------------------------

delka      db      0
pozice     dw      0
r          dw      buffersize-matchlimit    ; konec kruhov‚ho bufferu
flags      dw      0                        ; registr p©¡znak–

soub001:                                    ; rozpakov n¡ souboru
         push      cs
         pop       es
         push      cs
         pop       ds
         mov       cx,buffersize-matchlimit ; d‚lka kruhov‚ho bufferu
         mov       di,textbuf               ; za‡ tek kruhov‚ho bufferu
         mov       al," "                   ; znak k vymaz n¡
         rep       stosb                    ; vymaz n¡ kruhov‚ho bufferu

soub003: mov       ax,ds:[flags]            ; registr p©¡znak–
         shr       ax,1                     ; rotace registru o bit vpravo
         mov       ds:[flags],ax            ; ulo‘en¡ registru p©¡znak–
         test      ax,100h                  ; je registr p©¡znak– platn˜ ?
         jnz       soub004                  ; registr p©¡znak– je¨tˆ plat¡

         call      readb                    ; na‡ten¡ registru p©¡znak–
         jc        soub0020                 ; chyba ‡ten¡
         mov       byte ptr ds:[flags],al   ; ulo‘en¡ registru p©¡znak–
         mov       byte ptr ds:[flags+1],0ffh ; bity ‡¡ta‡e do 8

soub004: test      byte ptr ds:[flags],1    ; je kompresovan˜ bajt ?
         jnz       soub006                  ; nen¡ kompresovan˜ bajt

         call      readb                    ; na‡ten¡ ‡¡sla I
         jc        soub0020                 ; chyba ‡ten¡
         xor       dx,dx                    ; DX <- 0000
         mov       dl,al                    ; £schova ‡¡sla I (‡ st pozice)
         call      readb                    ; na‡ten¡ d‚lky dat
         jc        soub0020                 ; chyba ‡ten¡
         xor       ah,ah                    ; AH <- 0
         mov       cx,ax                    ; £schova d‚lky dat
         and       cl,0fh                   ; d‚lka 0 a‘ 15
         mov       ds:[delka],cl            ; d‚lka polo‘ky
         add       cl,threshold+1           ; skute‡n  d‚lka dat + 1
         and       al,0f0h                  ; vy¨¨¡ 4 bity z d‚lky
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; nejvy¨¨¡ 4 bity plohy
         or        ax,dx                    ; slou‡en¡ s ni‘¨¡mi bity pozice
         mov       dx,ax                    ; pozice dat v kruhov‚m bufferu
         mov       ds:[pozice],ax           ; pozice polo‘ky v bufferu
                                          ;* z pis kompresovan‚ polo‘ky
soub005:
         and       dx,buffersize-1          ; maska pozice v bufferu
         mov       si,textbuf               ; za‡ tek kruhov‚ho bufferu
         add       si,dx                    ; pozice znaku v bufferu
         lodsb                              ; p©e‡ten¡ znaku z bufferu
         call      writeb                   ; z pis znaku do souboru
soub0020:jc        soub002                  ; chyba z pisu souboru
         mov       di,ds:[r]                ; ukl dac¡ adresa do bufferu
         add       di,textbuf               ; za‡ tek kruhov‚ho bufferu
         stosb                              ; ulo‘en¡ zapsan‚ho znaku
         mov       ax,ds:[r]                ; ukl dac¡ adresa do bufferu
         inc       ax                       ; zv˜¨en¡ ukl dac¡ adresy
         and       ax,buffersize-1          ; maskov n¡ ukl dac¡ adresy
         mov       ds:[r],ax                ; nov  hodnota ukl dac¡ adresy
         loop      soub005                  ; p©enos dal¨¡ho bajtu
         jmp       soub007

                                          ;* z pis nezkompresovan‚ polo‘ky
soub006:
         call      readb                    ; ‡ten¡ bajtu k p©enosu
         jc        soub002                  ; chyba ‡ten¡ - konec
         call      writeb                   ; z pis bajtu na v˜stup
         jc        soub002                  ; chyba z pisu
         mov       di,ds:[r]                ; ukl dac¡ adresa do bufferu
         add       di,textbuf               ; za‡ tek kruhov‚ho bufferu
         stosb                              ; ulo‘en¡ znaku
         mov       ax,ds:[r]                ; ukl dac¡ adresa do bufferu
         inc       ax                       ; zv˜¨en¡ ukl dac¡ adresy
         and       ax,buffersize-1          ; maskov n¡ ukl dac¡ adresy
         mov       ds:[r],ax                ; nov  hodnota ukl dac¡ adresy
soub007:
         jmp       soub003

soub002: stc
         call      writeb
         jmp       navrat


; -----------------------------------------------------------------------------


readb:                                      ; ‡ten¡ bajtu ze souboru
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;         CY=nejsou dal¨¡ data

         cmp       word ptr cs:[pocbyte1],0 ; jsou nˆjak  data v bufferu ?
         jne       readb1                   ; jsou dal¨¡ data
         cmp       word ptr cs:[pocbyte1+2],0 ; jsou nˆjak  data v bufferu ?
         jne       readb1                   ; jsou dal¨¡ data
                                           ;* na‡ten¡ dat do bufferu
         call      readbuf                  ; ‡ten¡ bloku 64KB
         jc        readb2                   ; chyba ‡ten¡
readb3:  call      readbuf                  ; ‡ten¡ dal¨¡ho bloku 64KB
         jnc       readb3                   ; na‡ten¡ dal¨¡ch dat
         mov       word ptr ds:[readbyte],0 ; offset adresy ‡ten‚ho bajtu
         mov       ax,ds:[segbuff1]         ; segment adresy ‡ten‚ho bajtu
         mov       word ptr ds:[readbyte+2],ax ; segment adresy ‡ten‚ho bajtu
                                          ;* p©e‡ten¡ bajtu z bufferu
readb1:  push      si                       ; £schova SI
         push      ds                       ; £schova DS
         lds       si,ds:[readbyte]         ; adresa ke ‡ten¡ bajtu
         cld                                ; smˆr posunu ukazatele nahoru
         lodsb                              ; na‡ten¡ dal¨¡ho bajtu dat
         pop       ds                       ; n vrat DS
         pop       si                       ; n vrat SI
         inc       word ptr ds:[readbyte]   ; zv˜¨en¡ ‡tec¡ adresy bajtu
         jnz       readb10                  ; nen¡ p©ete‡en¡ p©es okraj segmentu
         add       word ptr ds:[readbyte+2],1000h ; zv˜¨en¡ adresy segmentu
readb10: sub       word ptr ds:[pocbyte1],1 ; sn¡‘en¡ po‡tu ulo‘en˜ch bajt–
         jnc       readb11                  ; nen¡ p©enos
         dec       word ptr ds:[pocbyte1+2] ; p©enos do vy¨¨¡ho slova
readb11: clc                                ; p©¡znak - ‡ten¡ OK
readb2:  ret

readbuf:                                    ; na‡ten¡ dat 64KB ze vstup. souboru
                                            ; VSTUP: CY=nelze ‡¡st dal¨¡ data

         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       ax,word ptr ds:[delbuff1] ; d‚lka bufferu vstupn¡ho souboru
         sub       ax,word ptr ds:[pocbyte1] ; v˜po‡et voln‚ho m¡sta
         mov       cx,ax                    ; po‡et voln˜ch bajt–
         mov       ax,word ptr ds:[delbuff1+2] ; d‚lka bufferu - vy¨¨¡ slovo
         sbb       ax,word ptr ds:[pocbyte1+2] ; vy¨¨¡ slovo po‡tu bajt–
         jz        readb6                   ; nen¡ vˆt¨¡ ne‘ FFFFh bajt–
         mov       cx,0ffffh                ; n hradn¡ po‡et bajt– ke ‡ten¡
readb6:  jcxz      readb8                   ; chyba - nen¡ voln‚ m¡sto
         push      ds                       ; £schova DS
         lds       dx,ds:[pocbyte1]         ; po‡et bajt– v bufferu
         mov       ax,dx                    ; ni‘¨¡ slovo po‡tu bajt–
         mov       bx,ds                    ; vy¨¨¡ slovo po‡tu bajt–
         and       dx,0fh                   ; korekce do jednoho odstavce
         shr       bx,1                     ; BX/2
         rcr       ax,1
         shr       bx,1                     ; BX/4
         rcr       ax,1
         shr       bx,1                     ; BX/8
         rcr       ax,1
         shr       bx,1                     ; BX/16 - po‡et odstavc–
         rcr       ax,1
         add       ax,cs:[segbuff1]         ; po‡ te‡n¡ segment bufferu
         mov       ds,ax                    ; segment za‡ tku dat
         mov       bx,cs:[idents1]          ; identifik tor vstupn¡ho souboru
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         int       21h                      ; na‡ten¡ dat z bufferu
         pop       ds
         jnc       readb7                   ; ‡ten¡ ze souboru OK
         jmp       dekom5                   ; chyba vstupn¡ho souboru
readb7:  add       word ptr [pocbyte1],ax   ; zv˜¨en¡ po‡tu bajt–
         adc       word ptr [pocbyte1+2],0  ; p©i‡ten¡ p©enosu
         or        ax,ax                    ; jsou na‡tena nˆjak  data ?
         jnz       readb9                   ; jsou na‡tena data
readb8:  stc                                ; p©¡znak - nejsou dal¨¡ data
readb9:  pop       dx
         pop       cx
         pop       bx
         ret


                                          ; * vstupn¡ soubor
jmeno1   db        128 dup(0)               ; jm‚no vstupn¡ho souboru
idents1  dw        0                        ; identifikace zdrojov‚ho souboru
readbyte dd        0                        ; adresa ke ‡ten¡ bajtu
segbuff1 dw        0                        ; adresa datov‚ho bufferu 1 (segm.)
pocbyte1 dd        0                        ; po‡et bajt– v bufferu vstup.soub.
delbuff1 dd        0                        ; d‚lka datov‚ho bufferu vstup.soub.


writeb:                                     ; z pis bajtu do souboru
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;        CY=vypr zdnˆn¡ bufferu
                                            ; VSTUP: CY=chyba z pisu do souboru

                                          ;* z pis bajtu do bufferu
         push      ax
         jc        writb4                   ; vypr zdnˆn¡ bufferu
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         les       di,ds:[writbyte]         ; adresa k z pisu bajtu
         cld                                ; smˆr posunu ukazatele nahoru
         stosb                              ; ulo‘en¡ dal¨¡ho bajtu dat
         pop       es                       ; n vrat ES
         pop       di                       ; n vrat DI
         inc       word ptr ds:[writbyte]   ; zv˜¨en¡ ukl dac¡ adresy bajtu
         jnz       writb10                  ; nen¡ p©ete‡en¡ p©es okraj segmentu
         add       word ptr ds:[writbyte+2],1000h ; zv˜¨en¡ adresy segmentu
writb10: add       word ptr ds:[pocbyte2],1 ; zv˜¨en¡ po‡tu ulo‘en˜ch bajt–
         jnc       writb11                  ; nen¡ p©enos
         inc       word ptr ds:[pocbyte2+2] ; p©enos do vy¨¨¡ho slova
writb11:
         mov       ax,word ptr ds:[pocbyte2+2] ; vy¨¨¡ slovo po‡tu bajt–
         cmp       ax,word ptr ds:[delbuff2+2] ; kontrola s d‚lkou bufferu
         jne       writb12                  ; nen¡ shoda
         mov       ax,word ptr ds:[pocbyte2] ; ni‘¨¡ slovo po‡tu bajt–
         cmp       ax,word ptr ds:[delbuff2] ; kontrola s d‚lkou bufferu
writb12: jc        writb5                   ; buffer je¨tˆ nen¡ zaplnˆn
writb4:                                   ;* ulo‘en¡ dat z bufferu
         mov       word ptr ds:[writbyte],0 ; offset adresy zapisovan‚ho bajtu
         mov       ax,ds:[segbuff2]         ; segment adresy zapisovan‚ho bajtu
         mov       word ptr ds:[writbyte+2],ax ; segment adresy zapisov. bajtu
         call      writbuf                  ; z pis bloku 64KB
         jc        writb2                   ; chyba z pisu
writb3:  call      writbuf                  ; z pis dal¨¡ho bloku 64KB
         jnc       writb3                   ; z pis dal¨¡ch dat
         mov       word ptr ds:[writbyte],0 ; offset adresy zapisovan‚ho bajtu
         mov       ax,ds:[segbuff2]         ; segment adresy zapisovan‚ho bajtu
         mov       word ptr ds:[writbyte+2],ax ; segment adresy zapisov. bajtu
writb5:  clc                                ; p©¡znak - z pis OK
writb2:  pop       ax
         ret



writbuf:                                    ; z pis dat 64KB do v˜stup. souboru
                                            ; VSTUP: CY=nelze zapsat dal¨¡ data

         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       cx,word ptr ds:[pocbyte2] ; po‡et bajt– v bufferu
         cmp       word ptr ds:[pocbyte2+2],0 ; vy¨¨¡ slovo po‡tu bajt–
         jz        writb6                   ; nen¡ vˆt¨¡ ne‘ FFFFh bajt–
         mov       cx,0ffffh                ; n hradn¡ po‡et bajt– ke ‡ten¡
writb6:  jcxz      writb8                   ; chyba - nejsou dal¨¡ data
         push      ds                       ; £schova DS
         lds       dx,ds:[writbyte]         ; adresa dat k z pisu
         mov       bx,dx                    ; ni‘¨¡ slovo adresy
         and       dx,0fh                   ; korekce do jednoho odstavce
         shr       bx,1                     ; BX/2
         shr       bx,1                     ; BX/4
         shr       bx,1                     ; BX/8
         shr       bx,1                     ; BX/16 - po‡et odstavc–
         mov       ax,ds                    ; segment adresy
         add       ax,bx                    ; p©i‡ten¡ p©enosu z offsetu
         mov       ds,ax                    ; segment za‡ tku dat
         mov       bx,cs:[idents2]          ; identifik tor v˜stupn¡ho souboru
         mov       ah,40h                   ; funkce z pis do souboru
         int       21h                      ; z pis dat do bufferu
         pop       ds
         jc        writb9                   ; chyba z pisu do souboru
         add       word ptr [writbyte],ax   ; zv˜¨en¡ adresy
         jnc       writb7                   ; nen¡ p©enos
         add       word ptr [writbyte+2],1000h ; p©i‡ten¡ p©enosu do segmentu
writb7:  sub       word ptr [pocbyte2],ax   ; sn¡‘en¡ po‡tu bajt– v bufferu
         sbb       word ptr [pocbyte2+2],0  ; p©enos do vy¨¨¡ho slova
         or        ax,ax                    ; byla zaps na nˆjak  data ?
         jnz       writb9                   ; byla zaps na nˆjak  data
writb8:  stc                                ; p©¡znak - nelze prov‚st z pis
writb9:  pop       dx
         pop       cx
         pop       bx
         ret




                                          ; * v˜stupn¡ soubor
jmeno2   db        128 dup(0)               ; jm‚no v˜stupn¡ho souboru
idents2  dw        0                        ; identifikace c¡lov‚ho souboru
writbyte dd        0                        ; adresa k z pisu bajtu
segbuff2 dw        0                        ; adresa datov‚ho bufferu 2 (segm.)
pocbyte2 dd        0                        ; po‡et bajt– v bufferu v˜stup.soub.
delbuff2 dd        0                        ; d‚lka datov‚ho bufferu v˜st.soub.

uvtxt    db        'Rozpakov n¡ souboru: DEKOMP <vstup.soub.> <v˜stup.soub.>'
         db        13,10,'$'

err1     db        'Vstupn¡ soubor nenalezen nebo chyba ‡ten¡ !',13,10,'$'

err2     db        'Chyba p©idˆlen¡ pamˆti !',13,10,'$'

err3     db        'V˜stupn¡ soubor ji‘ existuje nebo chyba z pisu !',13,10,'$'

         dw        256 dup(0)               ; z sobn¡k
stack    dd        0                        ; vlastn¡ z sobn¡k


konec:                                      ; konec programu

; Buffer (um¡stˆn za programem)

; textbuf    db      buffersize+matchlimit dup(?) ; cyklick˜ buffer

code     ENDS

         END       dekomp                   ; startovac¡ adresa

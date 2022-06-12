  
; *****************************************************************************
;
;                                GEMIPAL
;
;                     ovlada‡ TV PAL pro videokartu VGA
;
; *****************************************************************************

Zasob    SEGMENT   STACK
Zasob    ENDS

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ test, zda je program ji‘ nainstalov n

Start:   mov       ax,1402h
         int       10h                      ; test instalace programu

; ------ poskytnut¡ adresy aktivn¡ho PSP

         push      ax
         mov       ah,62h
         int       21h                      ; poskytnut¡ adresy PSP
         mov       ds,bx                    ; adresa aktivn¡ho PSP
         pop       ax

; ------ program je ji‘ nainstalov n ?

         cmp       al,14h                   ; je program nainstalov n ?
         jne       l_0044                   ; nen¡ nainstalov n

; ------ parametr "/U" - odinstalov n¡ ovlada‡e

         cmp       byte ptr ds:[80h],3      ; jsou 3 znaky ?
         jne       l_002D                   ; nejsou 3 znaky
         cmp       byte ptr ds:[82h],"/"
         jne       l_002D
         cmp       byte ptr ds:[83h],"u"
         je        l_0030
         cmp       byte ptr ds:[83h],"U"
         je        l_0030
l_002D:  jmp       l_0108                   ; nainstalov n a nen¡ odinstalov n¡

; ------ odinstalov n¡ programu

l_0030:  mov       ax,1401h
         int       10h                      ; povel pro odinstalov n¡ programu
         mov       es,ax                    ; adresa prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku prost©ed¡
         mov       es,bx                    ; segment rezidentn¡ho programu
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ aloka‡n¡ho bloku programu
         jmp       l_00FB

; ------ parametr "/X" - zapnut¡ m¢du TV z p©¡kazov‚ho © dku

l_0044:  cmp       byte ptr ds:[80h],3      ; jsou 3 znaky ?
         jne       l_0066                   ; nen¡ zad n parametr "/X"
         cmp       byte ptr ds:[82h],"/"
         jne       l_0066
         cmp       byte ptr ds:[83h],"x"
         je        l_0060
         cmp       byte ptr ds:[83h],"X"
         jne       l_0066
l_0060:  mov       byte ptr cs:[d_04D0],1   ; 1=p©¡znak zapnut¡ m¢du TV

; ------ p©¡prava parametr–

l_0066:  mov       cs:[d_01D6],bx           ; adresa PSP
         mov       ax,ds:[2Ch]              ; segment prost©ed¡
         mov       cs:[d_01D8],ax           ; segment prost©ed¡

; ------ £schova adresy INT 09h

         mov       al,9
         call      l_0135                   ; poskytnut¡ adresy INT ‡¡slo AL
         mov       cs:[d_01CE],bx           ; p–vodn¡ adresa INT 09h
         mov       word ptr cs:[d_01CE+2],es

; ------ £schova adresy INT 10h

         mov       al,10h
         call      l_0135                   ; poskytnut¡ adresy INT ‡¡slo AL
         mov       cs:[d_01D2],bx           ; p–vodn¡ adresa INT 10h
         mov       word ptr cs:[d_01D2+2],es

; ------ p©¡prava k prohled n¡ segmentu BIOS VGA

         mov       ax,cs
         mov       ds,ax                    ; DS <- CS tabulk vzork–
         mov       ax,0C000h                ; segment BIOS VGA
         mov       es,ax                    ; ES <- segment BIOS VGA
         mov       si,offset d_01DC         ; tabulka adres vzork–
         mov       cx,7                     ; po‡et vzork– k vyhled n¡

; ------ nalezen¡ vzorku v ROM BIOS

l_009F:  push      si
         push      cx
         mov       si,[si]                  ; adresa vzorku
         mov       cx,[si]                  ; d‚lka vzorku
         mov       bx,[si+2]                ; adresa ovlada‡e VGA
         add       si,3                     ; adresa vzorku
         call      l_0141                   ; nalezen¡ vzorku v ROM BIOS
         jnz       l_00B5                   ; vzorek nenalezen
         mov       cs:[d_01DA],bx           ; ‡¡slo typu VGA
l_00B5:  pop       cx
         pop       si
         cmp       word ptr cs:[d_01DA],0   ; nalezen zn m˜ typ VGA ?
         jne       l_00C6                   ; nalezen zn m˜ typ VGA
         add       si,2                     ; ukazatel adres
         loop      l_009F                   ; hled n¡ dal¨¡ho vzorku
         jmp       short l_00DE

; ------ karta "TSENG"

l_00C6:  cmp       word ptr cs:[d_01DA],1   ; ‡¡slo typu VGA
         jne       l_00D3
         call      l_015F                   ; rozli¨en¡ typu TSENG
         jmp       short l_00DE

; ------ karta "TRIDENT"

l_00D3:  cmp       word ptr cs:[d_01DA],3   ; ‡¡slo typu VGA
         jne       l_00DE
         call      l_0195                   ; rozli¨en¡ typu karty TRIDENT

; ------ instalace programu do pamˆti

l_00DE:  mov       dx,offset int_09         ; adresa obsluhy INT 09h
         mov       al,9
         call      l_013A                   ; instalace obsluhy INT 09h
         mov       dx,offset l_04D5         ; adresa obsluhy INT 10h
         mov       al,10h
         call      l_013A                   ; instalace obsluhy INT 10h
         call      l_0B9F                   ; modifikace parametr– podle videokarty
         call      l_01B1                   ; zobrazen¡ £vodn¡ho textu
         mov       dx,200h                  ; d‚lka programu v odstavc¡ch
         mov       ah,31h
         int       21h                      ; instalace programu do pamˆti

; ------ hl ¨en¡ o odinstalov n¡ programu

l_00FB:  mov       ax,cs
         mov       ds,ax                    ; DS <- CS
         mov       dx,offset d_0231         ; text p©i odinstalov n¡
         mov       ah,9
         int       21h                      ; zobrazen¡ textu
         jmp       short l_010B             ; konec programu

; ------ obnoven¡ videom¢du a zobrazen¡ n povˆdy

l_0108:  call      l_01B1                   ; zobrazen¡ £vodn¡ho textu

; ------ konec programu

l_010B:  mov       ah,4Ch
         int       21h

; -----------------------------------------------------------------------------
;        ovˆ©en¡, zda je v pamˆti tento program
; -----------------------------------------------------------------------------

l_010f   PROC      NEAR

         mov       al,10h
         call      l_011E                   ; kontrola vektoru INT 10h
         jz        l_011D
         mov       al,9
         call      l_011E                   ; kontrola vektoru INT 09h
         jz        l_011D
l_011D:  ret

l_010f   ENDP

; -----------------------------------------------------------------------------
;       test, zda vektor p©eru¨en¡ pat©¡ tomuto programu (identifik tor "PCV")
; -----------------------------------------------------------------------------

l_011E   PROC      near

         call      l_0135                   ; poskytnut¡ adresy INT ‡¡slo AL
         cmp       byte ptr es:[bx-3],"P"
         jne       l_0134
         cmp       byte ptr es:[bx-2],"C"
         jne       l_0134
         cmp       byte ptr es:[bx-1],"V"
l_0134:  ret

l_011E   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ adresy INT ‡¡slo AL
; -----------------------------------------------------------------------------

l_0135   PROC      near

         mov       ah,35h
         int       21h
         ret

l_0135   ENDP

; -----------------------------------------------------------------------------
;        instalace ovlada‡e INT ‡¡slo AL
; -----------------------------------------------------------------------------

l_013A   PROC      near

         push      cs
         pop       ds
         mov       ah,25h
         int       21h
         ret

l_013A   ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ vzorku v ROM BIOS (SI=vzorek, CX=d‚lka)
; -----------------------------------------------------------------------------

l_0141   PROC      near

         xor       di,di                    ; po‡ tek v ROM BIOS k prohled n¡
         push      bx
         mov       bx,cx                    ; £schova d‚lky vzorku
l_0146:  push      si
         mov       cx,bx                    ; d‚lka vzorku
l_0149:  mov       al,es:[di]               ; znak z ROM BIOS
         inc       di
         or        al,20h                   ; p©evod na mal‚ p¡smeno
         inc       si
         cmp       al,[si]                  ; porovn n¡ znaku vzorku
         loopz     l_0149                   ; porovn n¡ dal¨¡ho znaku vzorku
         pop       si
         jcxz      l_015D                   ; shoda vzorku
         cmp       di,200h                  ; bude se je¨tˆ porovn vat ?
         jbe       l_0146                   ; dal¨¡ test
l_015D:  pop       bx
         ret

l_0141   ENDP

; -----------------------------------------------------------------------------
;        rozli¨en¡ typu karty TSENG
; -----------------------------------------------------------------------------

l_015F   PROC      near

; ------ rozli¨en¡ adresace port– CGA/MDA

         mov       dx,3CCh
         in        al,dx
         mov       dx,3D4h                  ; port CGA
         test      al,1                     ; je adresace CGA ?
         jnz       l_016D                   ; je adresace CGA
         mov       dx,3B4h                  ; adresace MDA

; ------ test registru 33h

l_016D:  mov       al,33h
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         push      ax                       ; £schova nastaven¡ registru
         xor       ah,0Fh
         mov       bx,ax
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       word ptr cs:[d_01DA],1   ; ‡¡slo typu VGA - TSENG 1
         cmp       ah,bh
         jne       l_0190
         mov       word ptr cs:[d_01DA],2   ; ‡¡slo typu VGA - TSENG 2
l_0190:  pop       ax
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         ret

l_015F   ENDP

; -----------------------------------------------------------------------------
;        rozli¨en¡ typu karty TRIDENT
; -----------------------------------------------------------------------------

l_0195   PROC      near

         mov       dx,3C4h
         mov       al,0Bh                   ; reg. 0bh - po‡ te‡n¡ linka kurzoru
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       word ptr cs:[d_01DA],3   ; ‡¡slo typu VGA
         cmp       ah,3                     ; po‡ te‡n¡ linka = 3 ?
         jb        l_01B0
         mov       word ptr cs:[d_01DA],4   ; ‡¡slo typu VGA = TRIDENT 2
l_01B0:  ret

l_0195   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ £vodn¡ho textu
; -----------------------------------------------------------------------------

l_01B1   PROC      near

; ------ inicializace videom¢du

         mov       ax,3
         int       10h                      ; inicializace videom¢du

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,0                     ; po‡ te‡n¡ © dek a pozice
         mov       bx,70h                   ; BH=str nka, BL=barva textu
         mov       cx,cs:[d_04CB]           ; po‡et znak– k zobrazen¡
         mov       ax,cs
         mov       es,ax                    ; ES <- CS
         mov       bp,offset d_0258         ; text k zobrazen¡
         mov       ax,1301h
         int       10h                      ; zobrazen¡ £vodn¡ho textu
         ret

l_01B1   ENDP

d_01CE   dw        0                        ; p–vodn¡ adresa INT 09h
         dw        0
d_01D2   dw        0                        ; p–vodn¡ adresa INT 10h
         dw        0
d_01D6   dw        0                        ; adresa PSP
d_01D8   dw        0                        ; segment prost©ed¡
d_01DA   dw        0                        ; ‡¡slo typu VGA

; ------ tabulka adres vzork– VGA (pro prohled n¡ ROM BIOS)

d_01DC   dw        d_01ea
         dw        d_01f3
         dw        d_01fe
         dw        d_020a
         dw        d_0215
         dw        d_021c
         dw        d_0227

; ------ tabulka vzork– VGA (pro prohled n¡ ROM BIOS)

d_01ea   dw        5,1
         db        'tseng'

d_01f3   dw        7,3
         db        'trident'

d_01fe   dw        8,5
         db        'paradise'

d_020a   dw        7,5
         db        'western'

d_0215   dw        3,6
         db        'oak'

d_021c   dw        7,7
         db        'realtek'

d_0227   dw        6,8
         db        'cirrus'

d_0231   db        10,13,34 dup(" "),10,13,'$'   ; text p©i odinstalov n¡

; ------ £vodn¡ text k zobrazen¡

d_0258   db        'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»',10,13
         db        'º                    PAL   TSR Driver  Ver 3.0        º',10,13
         db        'º                                      03/04/92       º',10,13
         db        'ºMODE SWITCH KEY :  ALT_BACKSPACE (ALT_',11h,'ÄÄ)           º',10,13
         db        'ºUTILITY HOT KEY :                                    º',10,13
         db        'º Screen Shift Up        ===> ALT_Up-Arrow    (ALT_',18h,') º',10,13
         db        'º Screen Shift Down      ===> ALT_Down-Arrow  (ALT_',19h,') º',10,13
         db        'º Screen Shift Left      ===> ALT_Left-Arrow  (ALT_',1bh,') º',10,13
         db        'º Screen Shift Right     ===> ALT_Right-Arrow (ALT_',1ah,') º',10,13
         db        'º Call for help message  ===> ALT_H                   º',10,13
         db        'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',10,13
d_02580  label     byte

d_04CB   dw        offset(d_02580-d_0258)   ; d‚lka £vodn¡ho textu k zobrazen¡

         db        0
d_04CE   dw        0                        ; segment 0
d_04D0   db        0                        ; 1=p©¡znak zapnut¡ m¢du TV
d_04D1   db        0                        ; 1=p©¡znak prokl dan‚ho videom¢du
d_04D2   db        0                        ; 1=p©¡znak prob¡haj¡c¡ funkce AH=10h
d_04D3   db        0                        ; 1=p©¡znak prob¡haj¡c¡ fce PALETY
d_04D4   db        0                        ; 1=p©echodn‚ blokov n¡ bˆhem AH=0eh

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

; ====== slu‘ba 0 - inicializace videom¢du

l_04D5:  cmp       ah,0                     ; inicializace videom¢du ?
         je        l_04DD                   ; je inicializace videom¢du
         jmp       short l_0540
         nop

l_04DD:  inc       byte ptr cs:[d_04D2]     ; 1=p©¡znak prob¡haj¡c¡ funkce AH=10h
         cmp       byte ptr cs:[d_04D0],0   ; 1=p©¡znak zapnut¡ m¢du TV
         je        l_0521                   ; nen¡ zapnut m¢d TV
         mov       byte ptr cs:[d_04D1],0   ; 1=p©¡znak prokl dan‚ho videom¢du
         mov       word ptr cs:[d_0D31],0   ; odchylka synchron. v horiz. smˆru
         mov       word ptr cs:[d_0D33],0   ; odchylka synchron. ve vert. smˆru

         push      bx
         push      ax
         and       al,7Fh                   ; po‘adovan˜ videom¢d
         cmp       al,13h                   ;
         je        l_0510
         cmp       al,0Fh
         jb        l_0510
         mov       byte ptr cs:[d_04D1],1   ; 1=p©¡znak prokl dan‚ho videom¢du

; ------ pro textov‚ videom¢dy nastaven¡ vertik ln¡ho rozli¨en¡ 200 linek

l_0510:  cmp       al,3                     ; je textov˜ videom¢d ?
         ja        l_051F                   ; nen¡ textov˜ videom¢d
         mov       ax,1200h
         mov       bl,30h                   ; slu‘ba - nastaven¡ po‡tu linek
         pushf     
         call      dword ptr cs:d_01D2      ; nastaven¡ rozli¨en¡ 200 linek
l_051F:  pop       ax
         pop       bx

; ------ inicializace videom¢du

l_0521:  push      ax
         pushf     
         call      dword ptr cs:d_01D2      ; inicializace videom¢du
         pop       ax

; ------ p©enastaven¡ videoregistr–

         cmp       byte ptr cs:[d_04D0],0   ; 1=p©¡znak zapnut¡ m¢du TV
         je        l_053A
         call      l_0611                   ; nastaven¡ videoregistr– karty VGA
         dec       byte ptr cs:[d_04D2]     ; 1=p©¡znak prob¡haj¡c¡ funkce AH=10h
         iret      

l_053A:  dec       byte ptr cs:[d_04D2]     ; 1=p©¡znak prob¡haj¡c¡ funkce AH=10h
         iret      

; ====== slu‘ba 1 - nastaven¡ velikosti kurzoru

l_0540:  cmp       ah,1                     ; nastaven¡ velikosti kurzoru ?
         jne       l_0551                   ; nen¡ nastaven¡ velikosti kurzoru
         cmp       byte ptr cs:[d_04D0],0   ; 1=p©¡znak zapnut¡ m¢du TV
         je        l_0551                   ; nen¡ zapnut m¢d TV
         call      l_05AA                   ; nastaven¡ rozmˆr– kurzoru v TV
         iret      

; ====== slu‘ba 0eh - v˜stup znaku na displej

l_0551:  cmp       ah,0Eh                   ; v˜stup znaku na displej ?
         jne       l_0569                   ; nen¡
         mov       byte ptr cs:[d_04D4],1   ; 1=p©echodn‚ blokov n¡ bˆhem AH=0eh
         pushf
         call      dword ptr cs:d_01D2      ; v˜stup znaku na displej
         mov       byte ptr cs:[d_04D4],0   ; 1=p©echodn‚ blokov n¡ bˆhem AH=0eh
         iret      

; ======

l_0569:  cmp       ah,0Bh                   ; nastaven¡ palet CGA ?
         je        l_0582                   ; nastaven¡ palet CGA
         cmp       ah,10h                   ; nastaven¡ palet EGA ?
         je        l_0582                   ; nastaven¡ palet EGA
         cmp       ah,11h                   ; p©edefinov n¡ znak– EGA ?
         je        l_0582                   ; p©edefinov n¡ znak– EGA
         cmp       ah,12h                   ; roz¨¡©en‚ funkce VGA ?
         je        l_0582                   ; roz¨¡©en‚ funkce VGA
         cmp       ah,1Ch                   ; £schova/navr cen¡ stavu VGA ?
         jne       l_0593                   ; nen¡ £schova/navr cen¡ stavu

; ------ r–zn‚ funkce - palety, stav VGA

l_0582:  inc       byte ptr cs:[d_04D3]     ; 1=p©¡znak prob¡haj¡c¡ fce PALETY
         pushf     
         call      dword ptr cs:[d_01D2]    ; p–vodn¡ adresa INT 10h
         dec       byte ptr cs:[d_04D3]     ; 1=p©¡znak prob¡haj¡c¡ fce PALETY
         iret      

; ------ zvl ¨tn¡ funkce - odinstalov n¡ ovlada‡e

l_0593:  cmp       ax,1401h                 ; po‘adavek odinstalov n¡ ?
         jne       l_059B                   ; nen¡ odinstalov n¡
         jmp       short l_05E1             ; odinstalov n¡ ovlada‡e
         nop

; ------ zvl ¨tn¡ funkce - dotaz na instalaci ovlada‡e

l_059B:  cmp       ax,1402h                 ; je funkce dotazu na instalaci ?
         jne       l_05A3                   ; nen¡ dotaz na instalaci
         jmp       short l_060D             ; dotaz na instalaci ovlada‡e
         nop

; ------ proveden¡ po‘adovan‚ funkce

l_05A3:  pushf
         call      dword ptr cs:d_01D2      ; p–vodn¡ po‘adovan  funkce INT 10h
         iret      

; -----------------------------------------------------------------------------
;        nastaven¡ velikosti kurzoru v m¢du TV
; -----------------------------------------------------------------------------

l_05AA   PROC      near

; ------ £schova registr–

         push      ds
         push      dx
         push      cx
         push      ax

; ------ p©¡prava registr–

         mov       ds,cs:[d_04CE]           ; segment 0
         mov       dx,ds:[463h]             ; b zov  ©¡dic¡ adresa displeje
         mov       al,0Ah                   ; ‡¡slo registru

; ------ omezen¡ velikosti kurzoru

         cmp       ch,30                    ; maxim ln¡
         jbe       l_05C3
         mov       cx,1E00h                 ; omezen¡ na maxim ln¡ velikost
         jmp       short l_05D0             ; nastaven¡ rozmˆr– kurzoru

; ------ velikost kurzoru podle p©ep¡na‡e INSERT

l_05C3:  test      byte ptr ds:[417h],80h   ; je INSERT ?
         mov       cx,607h                  ; nen¡ INSERT - mal˜ kurzor
         jz        l_05D0
         mov       cx,7                     ; je INSERT - vˆt¨¡ kurzor

; ------ nastaven¡ rozmˆr– kurzoru

l_05D0:  mov       ah,ch                    ; po‡ tek kurzoru
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         inc       al
         mov       ah,cl                    ; konec kurzoru
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

; ------ n vrat registr–

         pop       ax
         pop       cx
         pop       dx
         pop       ds
         ret

l_05AA   ENDP

; -----------------------------------------------------------------------------
;        funkce odinstalov n¡ ovlada‡e
; -----------------------------------------------------------------------------

l_05E1:  cli
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0

; ------ n vrat adresy INT 09h

         mov       ax,word ptr cs:[d_01CE+2] ; segment INT 09h
         mov       ds:[26h],ax              ; n vrat segmentu adresy INT 09h
         mov       ax,cs:[d_01CE]           ; offset INT 09h
         mov       ds:[24h],ax              ; n vrat offsetu adresy INT 09h

; ------ n vrat adresy INT 10h

         mov       ax,word ptr cs:[d_01D2+2]; p–vodn¡ adresa INT 10h
         mov       ds:[42h],ax
         mov       ax,cs:[d_01D2]           ; p–vodn¡ adresa INT 10h
         mov       ds:[40h],ax
         mov       bx,cs:[d_01D8]           ; segment prost©ed¡
         mov       ax,cs:[d_01D6]           ; adresa PSP
         sti       
         iret

; -----------------------------------------------------------------------------
;        funkce dotazu na instalaci programu
; -----------------------------------------------------------------------------

l_060D:  mov       ax,1414h                 ; p©¡znak nainstalov n¡ programu
         iret      

; -----------------------------------------------------------------------------
;        nastaven¡ videoregistr– karty VGA
; -----------------------------------------------------------------------------
;þ
l_0611   PROC      near

; ------ £schova registr–

         cli
         push      es
         push      ds
         push      di
         push      dx
         push      bx
         push      ax

; ------ p©¡prava segmentov˜ch registr–

         xor       bx,bx
         mov       ds,bx                    ; DS <- 0
         mov       bx,cs
         mov       es,bx                    ; ES <- CS

; ------ nastaven¡ videoregistr– karty VGA

         and       byte ptr ds:[417h],7Fh   ; zru¨en¡ p©¡znaku INSERT
         cmp       al,ds:[449h]             ; mˆn¡ se videom¢d ?
         je        l_0634                   ; videom¢d se nemˆn¡
         mov       al,ds:[449h]             ; aktu ln¡ videom¢d
         mov       byte ptr cs:[d_04D1],0   ; 1=p©¡znak prokl dan‚ho videom¢du
l_0634:  xor       ah,ah
         mov       bx,ax                    ; ‡¡slo videom¢du
         cmp       al,7
         je        l_064E                   ; videm¢d 7 se neobsluhuje
         mov       di,cs:[d_01DA]           ; ‡¡slo typu VGA
         shl       di,1
         call      l_0B71                   ; vypnut¡ videosign lu
         call      word ptr cs:d_0656[di]   ; nastaven¡ videoregistr– karty VGA
         call      l_0B60                   ; zapnut¡ videosign lu

; ------ n vrat registr–

l_064E:  pop       ax
         pop       bx
         pop       dx
         pop       di
         pop       ds
         pop       es
         sti       
         ret

l_0611   ENDP

; ------ tabulka adres obsluh pro nastaven¡ videoregistr– karty VGA

d_0656   dw        offset l_0698            ; 0  nezn m  VGA
d_0658   dw        offset l_06E3            ; 1: TSENG 1
d_065A   dw        offset l_0777            ; 2: TSENG 2
d_065C   dw        offset l_081A            ; 3: TRIDENT 1
d_065E   dw        offset l_087B            ; 4: TRIDENT 2
d_0660   dw        offset l_0929            ; 5: PARADISE, WESTERN
d_0662   dw        offset l_098B            ; 6: OAK
d_0664   dw        offset l_0A24            ; 7: REALTEK
d_0666   dw        offset l_0AD5            ; 8: CIRRUS

; -----------------------------------------------------------------------------
;        adresa DI tabulky registr– videom¢du AL
; -----------------------------------------------------------------------------

l_0668   PROC      near

         xor       ah,ah
         mov       di,offset d_1026         ; tabulky registr– videom¢du
         mov       bx,0Fh                   ; po‡et bajt– na tabulku
         mul       bx
         add       di,ax                    ; adresa tabulky registr–
         ret

l_0668   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ©¡dic¡ch registr– VGA
; -----------------------------------------------------------------------------

l_0675   PROC      near

; ------ nastaven¡ ¨¡©ky vertik ln¡ho zpˆtn‚ho bˆhu na 0

         mov       dx,ds:[463h]             ; b zov  ©¡dic¡ adresa (3d4h, 3b4h)
         mov       ax,11h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

; ------ nastaven¡ ostatn¡ch ©¡dic¡ch registr–

         mov       bx,700h                  ; nastaven¡ registr– 0 a‘ 7
         call      l_0B50                   ; nast.reg.BL-BH portu DX na ES:DI
         mov       bx,909h                  ; nastaven¡ registru 9
         call      l_0B50                   ; nast.reg.BL-BH portu DX na ES:DI
         mov       bx,1310h                 ; nastaven¡ registr– 10h a‘ 13h
         call      l_0B50                   ; nast.reg.BL-BH portu DX na ES:DI
         mov       bx,1615h                 ; nastaven¡ registr– 15h a‘ 16h
         call      l_0B50                   ; nast.reg.BL-BH portu DX na ES:DI
         ret

l_0675   ENDP

; -----------------------------------------------------------------------------
;        0: nastaven¡ videoregistr– nezn m‚ karty VGA
; -----------------------------------------------------------------------------

l_0698   PROC      near

; ------ adresa tabulky registr– videom¢du

         cmp       al,13h                   ; je obsluhovan˜ videom¢d ?
         ja        l_06CE                   ; nen¡ obsluhovan˜ videom¢d
         mov       al,cs:d_06CF[bx]         ; ‡¡slo videom¢du
         call      l_0668                   ; adresa tabulky registr– videom¢du

; ------ nastaven¡ registr– m¢du

         mov       dx,3C4h                  ; ©¡dic¡ port
         mov       ax,100h                  ; povel - povoleno nastaven¡
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

         mov       ax,901h                  ; povel: 8 bod– na znak, ¨irok 
                                            ;        linka, p–len˜ takt bod–
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

         mov       dx,3CCh
         in        al,dx
         and       al,23h
         or        al,4                     ; negativn¡ polarita
         mov       dx,3C2h
         out       dx,al                    ; nastaven¡ ©¡dic¡ch funkc¡

         mov       dx,3C4h
         mov       ax,300h                  ; povel - z kaz nastaven¡
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

; ------ nastaven¡ ©¡dic¡ch registr– synchronizac¡

         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky

l_06CE:  ret

l_0698   ENDP

; ------ 0: ‡¡sla tabulek registr– videom¢du karty VGA standard

d_06CF   db        10h                      ; 00h: text 40x25/16
         db        10h                      ; 01h: text 40x25/16
         db        11h                      ; 02h: text 80x25/16
         db        11h                      ; 03h: text 80x25/16
         db        12h                      ; 04h: graf 320x200/4
         db        12h                      ; 05h: graf 320x200/4
         db        13h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        14h                      ; 0dh: graf 320x200/16
         db        15h                      ; 0eh: graf 640x200/16
         db        16h                      ; 0fh: graf 640x350/2
         db        16h                      ; 10h: graf 640x350/16
         db        17h                      ; 11h: graf 640x480/2
         db        17h                      ; 12h: graf 640x480/16
         db        18h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        1: nastaven¡ videoregistr– karty TSENG 1
; -----------------------------------------------------------------------------

l_06E3   PROC      near

; ------ adresa defini‡n¡ tabulky registr–

         mov       di,offset d_11CA
         cmp       al,2Eh
         je        l_06F9
         cmp       al,13h
         jbe       l_06F1
         jmp       short l_0762
         db        90h
l_06F1:  mov       al,cs:d_0763[bx]         ; ‡¡slo videom¢du
         call      l_0668                   ; adresa tabulky registr– videom¢du


l_06F9:  mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         cmp       byte ptr ds:[449h],13h
         jae       l_0711
         mov       ax,901h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         jmp       short l_0734
l_0711:            
         mov       dx,ds:[463h]
         mov       al,11h
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         and       ah,7Fh
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       dx,3C4h
         mov       al,7
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,40h           ; '@'
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,101h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
l_0734:            
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         or        al,4
         mov       dx,3C2h
         out       dx,al
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky
         cmp       cs:d_04D1,0              ; 1=p©¡znak prokl dan‚ho videom¢du
         je        l_0762                   ; nen¡ prokl dan˜ videom¢d
         mov       al,25h           ; '%'
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,80h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

l_0762:            
         ret
l_06E3   ENDP      

; ------ 1: ‡¡sla tabulek registr– videom¢du karty TSENG 1

d_0763   db        00h                      ; 00h: text 40x25/16
         db        00h                      ; 01h: text 40x25/16
         db        11h                      ; 02h: text 80x25/16
         db        11h                      ; 03h: text 80x25/16
         db        02h                      ; 04h: graf 320x200/4
         db        02h                      ; 05h: graf 320x200/4
         db        13h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        04h                      ; 0dh: graf 320x200/16
         db        15h                      ; 0eh: graf 640x200/16
         db        0ch                      ; 0fh: graf 640x350/2
         db        0ch                      ; 10h: graf 640x350/16
         db        0dh                      ; 11h: graf 640x480/2
         db        0dh                      ; 12h: graf 640x480/16
         db        18h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        2: nastaven¡ videoregistr– karty TSENG 2
; -----------------------------------------------------------------------------

l_0777   PROC      near

         mov       di,offset d_11D9
         cmp       al,2Eh           ; '.'
         je        l_078D
         cmp       al,13h
         jbe       l_0785
         jmp       l_0805
l_0785:            
         mov       al,cs:d_0806[bx]
         call      l_0668                   ; adresa tabulky registr– videom¢du
l_078D:            
         mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         cmp       byte ptr ds:0449h,13h
         jae       l_07AF
         mov       ax,901h
         cmp       byte ptr ds:0449h,6
         jne       l_07AA
         mov       ax,0D01h
l_07AA:            
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         jmp       short l_07CF
l_07AF:            
         mov       ax,101h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       al,3
         mov       dx,3BFh
         out       dx,al
         mov       al,0A0h
         mov       dx,3D8h
         out       dx,al
         mov       dx,3C4h
         mov       al,7
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,0C0h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
l_07CF:            
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         or        al,4
         mov       dx,3C2h
         out       dx,al
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky
         cmp       byte ptr ds:0449h,6
         jne       l_07F7
         mov       ax,1413h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
l_07F7:            
         cmp       cs:d_04D1,0              ; 1=p©¡znak prokl dan‚ho videom¢du
         je        l_0805
         mov       ax,8035h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

l_0805:            
         ret
l_0777   ENDP      

; ------ 2: ‡¡sla tabulek registr– videom¢du karty TSENG 2

d_0806   db        00h                      ; 00h: text 40x25/16
         db        00h                      ; 01h: text 40x25/16
         db        01h                      ; 02h: text 80x25/16
         db        01h                      ; 03h: text 80x25/16
         db        02h                      ; 04h: graf 320x200/4
         db        02h                      ; 05h: graf 320x200/4
         db        03h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        04h                      ; 0dh: graf 320x200/16
         db        05h                      ; 0eh: graf 640x200/16
         db        0eh                      ; 0fh: graf 640x350/2
         db        0eh                      ; 10h: graf 640x350/16
         db        0fh                      ; 11h: graf 640x480/2
         db        0fh                      ; 12h: graf 640x480/16
         db        08h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        3: nastaven¡ videoregistr– karty TRIDENT
; -----------------------------------------------------------------------------

l_081A   PROC      near
         cmp       al,13h
         jbe       l_0821
         jmp       short l_0866
         db        90h
l_0821:            
         mov       al,cs:d_0867[bx]
         call      l_0668                   ; adresa tabulky registr– videom¢du
         mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,901h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         or        al,4
         mov       dx,3C2h
         out       dx,al
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky
         cmp       cs:d_04D1,0              ; 1=p©¡znak prokl dan‚ho videom¢du
         je        l_0866
         mov       al,1Eh
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,4
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

l_0866:            
         ret
l_081A   ENDP      

; ------ 3: ‡¡sla tabulek registr– videom¢du karty TRIDENT 1

d_0867   db        10h                      ; 00h: text 40x25/16
         db        10h                      ; 01h: text 40x25/16
         db        11h                      ; 02h: text 80x25/16
         db        11h                      ; 03h: text 80x25/16
         db        12h                      ; 04h: graf 320x200/4
         db        12h                      ; 05h: graf 320x200/4
         db        13h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        14h                      ; 0dh: graf 320x200/16
         db        15h                      ; 0eh: graf 640x200/16
         db        16h                      ; 0fh: graf 640x350/2
         db        16h                      ; 10h: graf 640x350/16
         db        17h                      ; 11h: graf 640x480/2
         db        17h                      ; 12h: graf 640x480/16
         db        18h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        4: nastaven¡ videoregistr– karty TRIDENT 2
; -----------------------------------------------------------------------------

l_087B   PROC      near
         mov       di,offset d_11E8
         cmp       al,5Ch           ; '\'
         je        l_0898
         mov       di,offset d_11F7
         cmp       al,5Dh           ; ']'
         je        l_0898
         cmp       al,13h
         jbe       l_0890
         jmp       l_0914
l_0890:            
         mov       al,cs:d_0915[bx]
         call      l_0668                   ; adresa tabulky registr– videom¢du
l_0898:            
         mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         cmp       byte ptr ds:0449h,13h
         jae       l_08CC
         mov       ax,901h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         cmp       byte ptr ds:0449h,1
         jbe       l_08D2
         cmp       byte ptr ds:0449h,4
         jb        l_08DD
         cmp       byte ptr ds:0449h,5
         jbe       l_08D2
         cmp       byte ptr ds:0449h,0Dh
         je        l_08D2
         jmp       short l_08DD
l_08CC:            
         mov       ax,101h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
l_08D2:            
         mov       al,0Dh
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,2
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
l_08DD:            
         mov       al,2Bh           ; '+'
         cmp       byte ptr ds:0449h,13h
         ja        l_08EE
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         or        al,4
l_08EE:            
         mov       dx,3C2h
         out       dx,al
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky
         cmp       cs:d_04D1,0              ; 1=p©¡znak prokl dan‚ho videom¢du
         je        l_0914
         mov       al,1Eh
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,4
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

l_0914:            
         ret
l_087B   ENDP      

; ------ 4: ‡¡sla tabulek registr– videom¢du karty TRIDENT 2

d_0915   db        19h                      ; 00h: text 40x25/16
         db        19h                      ; 01h: text 40x25/16
         db        11h                      ; 02h: text 80x25/16
         db        11h                      ; 03h: text 80x25/16
         db        1ah                      ; 04h: graf 320x200/4
         db        1ah                      ; 05h: graf 320x200/4
         db        13h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        1bh                      ; 0dh: graf 320x200/16
         db        15h                      ; 0eh: graf 640x200/16
         db        16h                      ; 0fh: graf 640x350/2
         db        16h                      ; 10h: graf 640x350/16
         db        17h                      ; 11h: graf 640x480/2
         db        17h                      ; 12h: graf 640x480/16
         db        18h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        5: nastaven¡ videoregistr– karty PARADISE, WESTERN
; -----------------------------------------------------------------------------

l_0929   PROC      near
         cmp       al,13h
         jbe       l_0930
         jmp       short l_0976
         db        90h
l_0930:            
         mov       al,cs:d_0977[bx]
         call      l_0668                   ; adresa tabulky registr– videom¢du
         mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,901h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         or        al,4
         mov       dx,3C2h
         out       dx,al
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky
         cmp       cs:d_04D1,0              ; 1=p©¡znak prokl dan‚ho videom¢du
         je        l_0976
         mov       ax,252Ch
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,242Dh
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

l_0976:            
         ret
l_0929   ENDP      

; ------ 5: ‡¡sla tabulek registr– videom¢du karty PARADISE, WESTERN

d_0977   db        00h                      ; 00h: text 40x25/16
         db        00h                      ; 01h: text 40x25/16
         db        11h                      ; 02h: text 80x25/16
         db        11h                      ; 03h: text 80x25/16
         db        02h                      ; 04h: graf 320x200/4
         db        02h                      ; 05h: graf 320x200/4
         db        13h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        04h                      ; 0dh: graf 320x200/16
         db        15h                      ; 0eh: graf 640x200/16
         db        0ch                      ; 0fh: graf 640x350/2
         db        0ch                      ; 10h: graf 640x350/16
         db        0dh                      ; 11h: graf 640x480/2
         db        0dh                      ; 12h: graf 640x480/16
         db        18h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        6: nastaven¡ videoregistr– karty OAK
; -----------------------------------------------------------------------------

l_098B   PROC      near
         mov       di,offset d_1206
         cmp       al,53h           ; 'S'
         je        l_09A1
         cmp       al,13h
         jbe       l_0999
         jmp       short l_0A0F
         db        90h
l_0999:            
         mov       al,cs:d_0A10[bx]
         call      l_0668                   ; adresa tabulky registr– videom¢du
l_09A1:            
         mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,901h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         mov       dx,3C2h
         cmp       byte ptr ds:0449h,1
         jbe       l_09D5
         cmp       byte ptr ds:0449h,4
         jb        l_09E6
         cmp       byte ptr ds:0449h,5
         jbe       l_09D5
         cmp       byte ptr ds:0449h,0Dh
         jne       l_09E6
l_09D5:            
         out       dx,al
         mov       dx,3DEh
         mov       al,0Dh
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,20h           ; ' '
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         jmp       short l_09E9
l_09E6:            
         or        al,4
         out       dx,al
l_09E9:            
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky
         cmp       cs:d_04D1,0              ; 1=p©¡znak prokl dan‚ho videom¢du
         je        l_0A0F
         mov       dx,3DEh
         mov       ax,8014h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,2F15h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

l_0A0F:            
         ret
l_098B   ENDP      

; ------ 6: ‡¡sla tabulek registr– videom¢du karty OAK

d_0a10   db        19h                      ; 00h: text 40x25/16
         db        19h                      ; 01h: text 40x25/16
         db        11h                      ; 02h: text 80x25/16
         db        11h                      ; 03h: text 80x25/16
         db        1ah                      ; 04h: graf 320x200/4
         db        1ah                      ; 05h: graf 320x200/4
         db        13h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        1bh                      ; 0dh: graf 320x200/16
         db        15h                      ; 0eh: graf 640x200/16
         db        0ch                      ; 0fh: graf 640x350/2
         db        0ch                      ; 10h: graf 640x350/16
         db        0dh                      ; 11h: graf 640x480/2
         db        0dh                      ; 12h: graf 640x480/16
         db        18h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        7: nastaven¡ videoregistr– karty REALTEK
; -----------------------------------------------------------------------------

l_0A24   PROC      near
         mov       di,offset d_1215
         cmp       al,25h           ; '%'
         je        l_0A41
         mov       di,offset d_1224
         cmp       al,26h           ; '&'
         je        l_0A41
         cmp       al,13h
         jbe       l_0A39
         jmp       l_0AC0
l_0A39:            
         mov       al,cs:d_0AC1[bx]
         call      l_0668                   ; adresa tabulky registr– videom¢du
l_0A41:            
         mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         cmp       byte ptr ds:0449h,13h
         jae       l_0A75
         mov       ax,901h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         cmp       byte ptr ds:0449h,1
         jbe       l_0A7B
         cmp       byte ptr ds:0449h,4
         jb        l_0A89
         cmp       byte ptr ds:0449h,5
         jbe       l_0A7B
         cmp       byte ptr ds:0449h,0Dh
         je        l_0A7B
         jmp       short l_0A89
l_0A75:            
         mov       ax,101h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
l_0A7B:            
         mov       dx,3CEh
         mov       al,0Bh
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,2
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
l_0A89:            
         mov       al,2Bh           ; '+'
         cmp       byte ptr ds:0449h,13h
         ja        l_0A9A
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         or        al,4
l_0A9A:            
         mov       dx,3C2h
         out       dx,al
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky
         cmp       cs:d_04D1,0              ; 1=p©¡znak prokl dan‚ho videom¢du
         je        l_0AC0
         mov       al,19h
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,1
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

l_0AC0:            
         ret
l_0A24   ENDP      

; ------ 7: ‡¡sla tabulek registr– videom¢du karty REALTEK

d_0ac1   db        19h                      ; 00h: text 40x25/16
         db        19h                      ; 01h: text 40x25/16
         db        11h                      ; 02h: text 80x25/16
         db        11h                      ; 03h: text 80x25/16
         db        1ah                      ; 04h: graf 320x200/4
         db        1ah                      ; 05h: graf 320x200/4
         db        13h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        1bh                      ; 0dh: graf 320x200/16
         db        15h                      ; 0eh: graf 640x200/16
         db        16h                      ; 0fh: graf 640x350/2
         db        16h                      ; 10h: graf 640x350/16
         db        17h                      ; 11h: graf 640x480/2
         db        17h                      ; 12h: graf 640x480/16
         db        18h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        8: nastaven¡ videoregistr– karty CIRRUS
; -----------------------------------------------------------------------------

l_0AD5   PROC      near
         cmp       al,13h
         jbe       l_0ADC
         jmp       short l_0B3B
         db        90h
l_0ADC:            
         mov       al,cs:d_0B3C[bx]
         call      l_0668                   ; adresa tabulky registr– videom¢du
         mov       dx,3C4h
         mov       ax,100h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,901h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       dx,3CCh
         in        al,dx
         and       al,23h           ; '#'
         mov       dx,3C2h
         cmp       byte ptr ds:0449h,1
         jbe       l_0B18
         cmp       byte ptr ds:0449h,4
         jb        l_0B29
         cmp       byte ptr ds:0449h,5
         jbe       l_0B18
         cmp       byte ptr ds:0449h,0Dh
         jne       l_0B29
l_0B18:            
         out       dx,al
         mov       dx,3C4h
         mov       al,0A4h
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         and       ah,0E3h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         jmp       short l_0B2C
l_0B29:            
         or        al,4
         out       dx,al
l_0B2C:            
         mov       dx,3C4h
         mov       ax,300h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0675                   ; nastaven¡ ©¡dic¡ch registr– VGA
         call      l_0CAC                   ; n vrat posunu obrazovky

l_0B3B:            
         ret
l_0AD5   ENDP      

; ------ 8: ‡¡sla tabulek registr– videom¢du karty CIRRUS

d_0b3c   db        09h                      ; 00h: text 40x25/16
         db        09h                      ; 01h: text 40x25/16
         db        01h                      ; 02h: text 80x25/16
         db        01h                      ; 03h: text 80x25/16
         db        0ah                      ; 04h: graf 320x200/4
         db        0ah                      ; 05h: graf 320x200/4
         db        03h                      ; 06h: graf 640x200/2
         db        00h                      ; 07h: text 80x25/16
         db        00h                      ; 08h: ----
         db        00h                      ; 09h: ----
         db        00h                      ; 0ah: ----
         db        00h                      ; 0bh: ----
         db        00h                      ; 0ch: ----
         db        0bh                      ; 0dh: graf 320x200/16
         db        05h                      ; 0eh: graf 640x200/16
         db        06h                      ; 0fh: graf 640x350/2
         db        06h                      ; 10h: graf 640x350/16
         db        07h                      ; 11h: graf 640x480/2
         db        07h                      ; 12h: graf 640x480/16
         db        08h                      ; 13h: graf 320x200/256

; -----------------------------------------------------------------------------
;        nastaven¡ registr– BL a‘ BH portu DX podle tabulky ES:DI
; -----------------------------------------------------------------------------

l_0B50   PROC      near

         mov       al,bl                    ; ‡¡slo prvn¡ho registru
         mov       ah,es:[di]               ; hodnota k nastaven¡
         inc       di                       ; zv˜¨en¡ ukazatele
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         inc       bl                       ; zv˜¨en¡ ‡¡sla registru
         cmp       bl,bh                    ; je posledn¡ registr ?
         jbe       l_0B50                   ; nastaven¡ dal¨¡ho registru
         ret

l_0B50   ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ videosign lu
; -----------------------------------------------------------------------------

l_0B60   PROC      near

         push      ax
         mov       dx,3DAh                  ; stavov˜ registr CGA
         in        al,dx                    ; synchronizace
         mov       dx,3BAh                  ; stavov˜ registr MDA
         in        al,dx                    ; synchronizace
         mov       dx,3C0h                  
         mov       al,20h                   
         out       dx,al                    ; zapnut¡ videosign lu
         pop       ax
         ret

l_0B60   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ videosign lu
; -----------------------------------------------------------------------------

l_0B71   PROC      near

         push      ax
         mov       dx,3DAh                  ; stavov˜ registr CGA
         in        al,dx                    ; synchronizace
         mov       dx,3BAh                  ; stavov˜ registr MDA
         in        al,dx                    ; synchronizace
         mov       dx,3C0h
         mov       al,0
         out       dx,al                    ; vypnut¡ videosign lu
         pop       ax
         ret

l_0B71   ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ m¢du TV
; -----------------------------------------------------------------------------

l_0B82   PROC      near

         cli
         mov       byte ptr cs:[d_04D0],1   ; 1=p©¡znak zapnut¡ m¢du TV
         sti       
         ret

l_0B82   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ m¢du TV
; -----------------------------------------------------------------------------

l_0B8B   PROC      near

         cli
         mov       byte ptr cs:[d_04D0],0   ; p©¡znak vypnut¡ m¢du TV
         sti       
         mov       ax,1202h
         mov       bl,30h                   ; podslu‘ba nastaven¡ linek
         pushf     
         call      dword ptr cs:d_01D2      ; nastaven¡ m¢du 480 linek
         ret

l_0B8B   ENDP

; -----------------------------------------------------------------------------
;        modifikace parametr– podle typu videokarty
; -----------------------------------------------------------------------------

l_0B9F   PROC      near

         mov       si,offset d_0C50         ; parametry podle videom¢du
         mov       di,cs:[d_01DA]           ; ‡¡slo typu VGA
         shl       di,1                     ; ‡¡slo typu * 2
         mov       di,cs:[d_0C3E+di]        ; adresa parametr– videokarty
         mov       bx,offset d_0C2C         ; tabulka parametr– videokarty
         mov       cx,9                     ; po‡et parametr– k modifikaci
l_0BB4:  push      di
         push      bx
         mov       bx,cs:[bx]               ;
         mov       al,cs:[bx+di]            ; ‡¡slo povolen‚ho videom¢du
         call      l_0668                   ; adresa tabulky registr– videom¢du
         call      l_0C71                   ; p©enos parametr–
         pop       bx
         pop       di
         add       bx,2
         loop      l_0BB4

         cmp       word ptr cs:[d_01DA],0   ; ‡¡slo typu VGA
         je        l_0C2B
         cmp       word ptr cs:[d_01DA],1   ; ‡¡slo typu VGA
         jne       l_0BE1
         mov       di,offset d_11CA
         call      l_0C71
         jmp       short l_0C2B
l_0BE1:            
         cmp       cs:d_01DA,2              ; ‡¡slo typu VGA
         jne       l_0BF1
         mov       di,offset d_11D9
         call      l_0C71
         jmp       short l_0C2B
l_0BF1:            
         cmp       cs:d_01DA,4              ; ‡¡slo typu VGA
         jne       l_0C07
         mov       di,offset d_11E8
         call      l_0C71
         mov       di,offset d_11F7
         call      l_0C71
         jmp       short l_0C2B
l_0C07:            
         cmp       cs:d_01DA,6              ; ‡¡slo typu VGA
         jne       l_0C17
         mov       di,offset d_1206
         call      l_0C71
         jmp       short l_0C2B
l_0C17:            
         cmp       cs:d_01DA,7              ; ‡¡slo typu VGA
         jne       l_0C2B
         mov       di,offset d_1215
         call      l_0C71
         mov       di,offset d_1224
         call      l_0C71

l_0C2B:            
         ret
l_0B9F   ENDP      

; ------ tabulka parametr– aktu ln¡ videokarty VGA

d_0C2C   db        0
         db         00h, 03h, 00h, 04h, 00h, 06h
         db         00h, 0Dh, 00h, 0Eh, 00h, 10h
         db         00h, 12h, 00h, 13h, 00h

; ------ tabulka adres tabulek parametr– podle typu videokarty

d_0C3E   dw        d_06CF                   ; 0: nezn m  VGA
         dw        d_0763                   ; 1: TSENG 1
         dw        d_0806                   ; 2: TSENG 2
         dw        d_0867                   ; 3: TRIDENT
         dw        d_0915                   ; 4: TRIDENT 2
         dw        d_0977                   ; 5: PARADISE, WESTERN
         dw        d_0a10                   ; 6: OAK
         dw        d_0ac1                   ; 7: REALTEK
         dw        d_0b3c                   ; 8: CIRRUS

d_0c50   db        11*3 dup(0)              ; tabulky k £schovˆ parametr– m¢du
                                            ; (11 tabulek po 3 bajtech)
                                            ;  0: 0,1,7,8,9,0ah,0bh,0ch
                                            ;  1: 2,3
                                            ;  2: 4,5
                                            ;  3: 6
                                            ;  4: 0dh
                                            ;  5: 0eh
                                            ;  6: 0fh,10h
                                            ;  7: 11h,12h
                                            ;  8: 13h
                                            ;  9: ostatn¡
                                            ; 10: 5dh, 26h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                  SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

l_0C71   PROC      near

         mov       al,cs:[di+4]
         mov       cs:[si],al
         inc       si
         mov       al,cs:[di+9]
         mov       cs:[si],al
         inc       si
         mov       al,cs:[di+7]
         mov       cs:[si],al
         inc       si
         ret

l_0C71   ENDP

; -----------------------------------------------------------------------------
;        £schova posunu obrazovky
; -----------------------------------------------------------------------------

l_0C8A   PROC      near

         call      l_0CCE                   ; adresa k £schovˆ param. videom¢du
         mov       dx,ds:[463h]
         mov       al,4
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       cs:[si],ah
         mov       al,10h
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       cs:[si+1],ah
         mov       al,7
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       cs:[si+2],ah
         ret

l_0C8A   ENDP

; -----------------------------------------------------------------------------
;        n vrat posunu obrazovky
; -----------------------------------------------------------------------------

l_0CAC   PROC      near

         call      l_0CCE                   ; adresa k £schovˆ param. videom¢du
         mov       dx,ds:[463h]             ; port displeje
         mov       al,4
         mov       ah,cs:[si]
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       al,10h
         mov       ah,cs:[si+1]
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       al,7
         mov       ah,cs:[si+2]
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         ret

l_0CAC   ENDP

; -----------------------------------------------------------------------------
;        adresa k £schovˆ posunu obrazovky podle videom¢du
; -----------------------------------------------------------------------------

l_0CCE   PROC      near

; ------ stanoven¡ ‡¡sla polo‘ky v tabulce

         mov       si,offset d_0C50         ; tabulka k £schovˆ posunu
         mov       ax,9                     ; ‡¡slo polo‘ky pro nestand. m¢d
         cmp       byte ptr ds:[449h],13h   ; je obsluhovan˜ videom¢d ?
         ja        l_0CE8                   ; nen¡ standardn¡ videom¢d
         mov       bl,ds:[449h]             ; videom¢d
         xor       bh,bh
         mov       al,cs:[d_0D1B+bx]        ; ‡¡slo polo‘ky v tabulce
         xor       ah,ah

; ------ adresa polo‘ky v tabulce

l_0CE8:  mov       bx,3                     ; po‡et bajt–
         mul       bx
         add       si,ax                    ; adresa polo‘ky v tabulce

; ------ videom¢d 5dh

         cmp       byte ptr ds:[449h],13h   ; obsluhovan˜ videom¢d ?
         jbe       l_0D1A                   ; videom¢d je OK
         cmp       word ptr cs:[d_01DA],4   ; ‡¡slo typu VGA = 4 ?
         jne       l_0D08
         cmp       byte ptr ds:[449h],5Dh   ; videom¢d 5dh ?
         jne       l_0D1A                   ; nen¡
         add       si,3                     ; adresa videom¢du 5dh

; ------ videom¢d 26h

l_0D08:  cmp       word ptr cs:[d_01DA],7   ; ‡¡slo typu VGA
         jne       l_0D1A
         cmp       byte ptr ds:0449h,26h    ; videom¢d 26h ?
         jne       l_0D1A
         add       si,3                     ; adresa videom¢du 26h

l_0D1A:  ret

l_0CCE   ENDP

; ------ konverzn¡ tabulka ‡¡sla videom¢du na ‡¡slo tabulky k £schovˆ parametr–

d_0D1B   db        0,0                      ; 0,1
         db        1,1                      ; 2,3
         db        2,2                      ; 4,5
         db        3                        ; 6
         db        0,0,0,0,0,0              ; 7,8,9,0ah,0bh,0ch
         db        4                        ; 0dh
         db        5                        ; 0eh
         db        6,6                      ; 0fh,10h
         db        7,7                      ; 11h,12h
         db        8                        ; 13h

         db        0

d_0D30   db        0                        ; 1=p©¡znak prob¡h n¡ posunu displ.
d_0D31   dw        0                        ; odchylka synchron. v horiz. smˆru
d_0D33   dw        0                        ; odchylka synchron. ve vert. smˆru

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

int_09   proc      far

; ------ test, zda je p©esmyka‡ ALT-

         push      ds
         mov       ds,cs:[d_04CE]           ; segment 0
         test      byte ptr ds:[417h],8     ; je kl vesa ALT ?
         pop       ds
         jnz       l_0D48
l_0D43:  jmp       dword ptr cs:[d_01CE]    ; pokra‡ov n¡ p–vodn¡ obsluhou

; ------ blokov n¡ bˆhem obsluhy funkc¡ INT 10h

l_0D48:  cmp       byte ptr cs:[d_04D2],0   ; 1=p©¡znak prob¡haj¡c¡ funkce AH=10h
         jne       l_0D43                   ; prob¡h  obsluha funkce 10h
         cmp       byte ptr cs:[d_04D4],0   ; 1=p©echodn‚ blokov n¡ bˆhem AH=0eh
         jne       l_0D43                   ; prob¡h  obsluha funkce 0eh
         test      byte ptr cs:[d_0D30],0FFh ; 1=p©¡znak prob¡h n¡ posunu displ.
         jnz       l_0D43

; ------ obsluha kl vesy ALT-BACK_SPACE

         push      bx
         push      ax
         in        al,[60h]                 ; ‡ten¡ k¢du kl vesy
         cmp       al,0Eh                   ; kl vesa BACK_SPACE ?
         jne       l_0D6B                   ; nen¡ BACK_SPACE
         jmp       short l_0DD5             ; je kl vesa BACK_SPACE
         db        90h

; ------ obsluha kl vesy ALT-R

l_0D6B:  cmp       al,13h                   ; je kl vesa R ?
         jne       l_0D72                   ; nen¡ kl vesa R
         jmp       l_0ECD                   ; obsluha kl vesy ALT-R

; ------ rozli¨en¡ kl ves pro posun displeje

l_0D72:  xor       bx,bx                    ; 0=nahoru
         cmp       al,48h                   ; je kurzor nahoru ?
         je        l_0D8B                   ; je kurzor nahoru
         inc       bx                       ; 1=dol–
         cmp       al,50h                   ; je kurzor dol– ?
         je        l_0D8B                   ; je kurzor dol–
         inc       bx                       ; 2=vlevo
         cmp       al,4Bh                   ; je kurzor vlevo ?
         je        l_0D8B                   ; je kurzor vlevo
         inc       bx                       ; 3=vpravo
         cmp       al,4Dh                   ; je kurzor vpravo ?
         je        l_0D8B                   ; je kurzor vpravo
l_0D87:  pop       ax
         pop       bx
         jmp       short l_0D43             ; pokra‡ov n¡ p–vodn¡ obsluhy

; ------ p©¡prava k posunu displeje

l_0D8B:  cli
         call      l_0F28                   ; uvolnˆn¡ ©adi‡e kl vesnice
         test      cs:[d_04D0],0FFh         ; 1=p©¡znak zapnut¡ m¢du TV
         jz        l_0D87                   ; nen¡ TV - ‘ dn  funkce
         mov       byte ptr cs:[d_0D30],1   ; 1=p©¡znak prob¡h n¡ posunu displ.
         push      ds
         push      si
         push      dx
         push      cx
         mov       ds,cs:[d_04CE]           ; segment 0
         mov       dx,ds:[463h]             ; b zov  ©¡dic¡ adresa displeje
         mov       cx,1                     ; smˆr posunu kladn˜
         test      bx,1                     ; je smˆr kladn˜ ?
         jz        l_0DB5
         neg       cx                       ; smˆr posunu z porn˜

; ------ posun displeje

l_0DB5:  call      l_0F39                   ; vert. a horiz. synchronizace
         shl       bx,1
         call      word ptr cs:[d_0DCD+bx]  ; nastaven¡ polohy displeje
         mov       byte ptr cs:[d_0D30],0   ; 1=p©¡znak prob¡h n¡ posunu displ.

; ------ n vrat registr–

         pop       cx
         pop       dx
         pop       si
         pop       ds
         pop       ax
         pop       bx
         sti       
         iret      

int_09   endp

d_0DCD   dw        offset l_0F50            ; vertik ln¡ posun displeje
d_0DCF   dw        offset l_0F50            ; vertik ln¡ posun displeje
d_0DD1   dw        offset l_0FD1            ; horizont ln¡ posun displeje
d_0DD3   dw        offset l_0FD1            ; horizont ln¡ posun displeje

; -----------------------------------------------------------------------------
;        obsluha kl vesy BACK_SPACE
; -----------------------------------------------------------------------------

l_0DD5:  cli
         call      l_0F28                   ; uvolnˆn¡ ©adi‡e kl vesnice
         mov       byte ptr cs:[d_0D30],1   ; 1=p©¡znak prob¡h n¡ posunu displ.

; ------ £schova registr–

         push      es
         push      ds
         push      si
         push      di
         push      dx
         push      cx

; ------ £schova stavu ovlada‡e my¨i

         mov       ax,cs
         mov       es,ax                    ; ES <- CS
         mov       dx,offset d_1233         ; buffer k £schovˆ stavu ovlad. my¨i
         mov       ax,16h
         int       33h                      ; uschov n¡ stavu ovlada‡e my¨i

; ------ zmˆna m¢du TV

         xor       byte ptr cs:[d_04D0],1   ; zmˆna p©¡znaku zapnut¡ m¢du TV
         cmp       byte ptr cs:[d_04D0],0   ; 1=p©¡znak zapnut¡ m¢du TV
         je        l_0E04                   ; nen¡ m¢d TV
         call      l_0B82                   ; zapnut¡ m¢du TV
         jmp       short l_0E07
l_0E04:  call      l_0B8B                   ; vypnut¡ m¢du TV

; ------ £schova adresy videostr nky, pozic a velikosti kurzoru

l_0E07:  xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       si,44Eh
         mov       ax,cs
         mov       es,ax                    ; ES <- CS
         mov       di,offset d_0EAF         ; buffer k £schovˆ parametr–
         mov       cx,12h
         rep       movsb                    ; £schova parametr–

; ------ £schova ‡¡sla aktivn¡ str nky a bajtu stavu displeje

         mov       si,462h
         movsb                              ; £schova ‡¡sla aktivn¡ str nky
         mov       si,487h
         movsb                              ; £schova bajtu stavu displeje

; ------ £schova adresy kurzoru

         mov       dx,ds:[463h]             ; b zov  ©¡dic¡ adresa displeje
         mov       al,0Eh                   ; registr 0eh -
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       cs:[d_0EC3],ax           ; adresa kurzoru HIGH
         mov       al,0Fh
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       cs:[d_0EC5],ax           ; adresa kurzoru LOW

; ------ £schova registru 18h

         mov       al,18h
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         mov       cs:[d_0EC7],ax           ; £schova registru 18h

; ------ inicializace videom¢du

         mov       al,ds:[489h]             ; stavov˜ bajt m¢du VGA
         and       al,8                     ; p©¡znak mo‘n˜ch stand. palet
         push      ax
         or        byte ptr ds:[489h],8     ; z kaz standardn¡ch palet
         mov       al,ds:[449h]             ; videom¢d
         or        al,80h                   ; p©¡znak nemazat displej
         xor       ah,ah
         int       10h                      ; inicializace videom¢du
         pop       ax
         and       byte ptr ds:[489h],not 8 ; povolen¡ standardn¡ch palet
         or        ds:[489h],al             ; n vrat stavov‚ho bajtu

; ------ n vrat registru 18h

         mov       dx,ds:[463h]             ; ©¡dic¡ registr
         mov       ax,cs:[d_0EC7]           ; uschovan˜ registr 18h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

; ------ n vrat adresy kurzoru

         mov       ax,cs:[d_0EC5]           ; uschovan  pozice kurzoru LOW
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       ax,cs:[d_0EC3]           ; uschovan  pozice kurzoru HIGH
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH

; ------ n vrat adresy videostr nky, pozic a velikosti kurzoru

         mov       ax,cs
         mov       ds,ax                    ; DS <- CS
         mov       si,offset d_0EAF         ; tabulka s uschovan˜mi parametry
         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       di,44Eh                  ; adresa parametr–
         mov       cx,12h
         rep       movsb                    ; n vrat parametr–

; ------ n vrat ‡¡sla aktivn¡ str nky a bajtu stavu displeje

         mov       di,462h
         movsb     
         mov       di,487h
         movsb     

; ------ n vrat stavu ovlada‡e my¨i

         mov       ax,cs
         mov       es,ax                    ; ES <- CS
         mov       dx,offset d_1233
         mov       ax,17h
         int       33h                      ; n vrat stavu ovlada‡e my¨i

; ------ n vrat registr–

         mov       byte ptr cs:[d_0D30],0   ; 1=p©¡znak prob¡h n¡ posunu displ.
         pop       cx
         pop       dx
         pop       di
         pop       si
         pop       ds
         pop       es
         pop       ax
         pop       bx
         sti       
         iret      

d_0EAF   db        20 dup (0)               ; buffer k £schovˆ parametr– displ.
d_0EC3   dw        0                        ; uschovan  adresa kurzoru HIGH
d_0EC5   dw        0                        ; uschovan  adresa kurzoru LOW
d_0EC7   dw        0                        ; £schova registru 18h
         db        0, 0, 0, 0

; -----------------------------------------------------------------------------
;        obsluha kl vesy ALT-R
; -----------------------------------------------------------------------------

l_0ECD:  cli
         call      l_0F28                   ; uvolnˆn¡ ©adi‡e kl vesnice
         test      cs:d_04D0,0FFh           ; 1=p©¡znak zapnut¡ m¢du TV
         jnz       l_0EDC                   ; m¢d TV je zapnut
         jmp       l_0D87

; ------ £schova registr–

l_0EDC:  push      ds
         push      si
         push      di
         push      dx
         push      cx

; ------ inicializace ukazatel– a registr–

         mov       byte ptr cs:[d_0D30],1   ; 1=p©¡znak prob¡h n¡ posunu displ.
         mov       word ptr cs:[d_0D31],0   ; odchylka synchron. v horiz. smˆru
         mov       word ptr cs:[d_0D33],0   ; odchylka synchron. ve vert. smˆru
         call      l_0B9F                   ; modifikace parametr– podle videokarty
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         call      l_0CAC                   ; n vrat posunu obrazovky
         mov       byte ptr cs:[d_0D30],0   ; 1=p©¡znak prob¡h n¡ posunu displ.

; ------ n vrat registr–

         pop       cx
         pop       dx
         pop       di
         pop       si
         pop       ds
         pop       ax
         pop       bx
         sti       
         iret      

; -----------------------------------------------------------------------------
;        nastaven¡ registru AL na hodnotu AH
; -----------------------------------------------------------------------------

l_0F0E   PROC      near

         out       dx,al                    ; nastaven¡ ‡¡sla registru
         jmp       short $+2                ; prodleva
         inc       dx
         xchg      al,ah
         out       dx,al                    ; nastaven¡ hodnoty registru
         jmp       short $+2                ; prodleva
         xchg      al,ah                    ; n vrat registr–
         dec       dx                       ; n vrat adresy portu
         ret

l_0F0E   ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ registru AL (hodnota do AH)
; -----------------------------------------------------------------------------

l_0F1B   PROC      near

         out       dx,al                    ; po‘adovan˜ registr
         jmp       short $+2                ; prodleva
         inc       dx
         mov       ah,al                    ; £schova ‡¡sla registru
         in        al,dx                    ; ‡ten¡ stavu registru
         jmp       short $+2                ; prodleva
         dec       dx
         xchg      al,ah                    ; n vrat registru
         ret

l_0F1B   ENDP

; -----------------------------------------------------------------------------
;        uvolnˆn¡ ©adi‡e kl vesnice
; -----------------------------------------------------------------------------

l_0F28   PROC      near

         in        al,[61h]                 ; stav portu 61h
         mov       ah,al
         or        al,80h
         out       61h,al                   ; impuls pro uvolnˆn¡ kl vesnice
         xchg      al,ah
         out       61h,al
         mov       al,20h
         out       20h,al                   ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         ret

l_0F28   ENDP

; -----------------------------------------------------------------------------
;        vert. a horiz. synchronizace
; -----------------------------------------------------------------------------

l_0F39   PROC      near

         mov       al,11h                   ; registr - vert. synchronizace
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         and       ah,7Fh
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       al,3                     ; registr - horiz. synchronizace
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         or        ah,80h
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         ret

l_0F39   ENDP

; -----------------------------------------------------------------------------
;        vertik ln¡ posun displeje (o CX)
; -----------------------------------------------------------------------------

l_0F50   PROC      near

; ------ ‡ten¡ sou‡asn‚ho nastaven¡ za‡ tku vertik ln¡ho zpˆtn‚ho bˆhu

         mov       al,10h                   ; registr 10h - za‡. vert. zpˆt.bˆhu
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         xor       bh,bh
         mov       bl,ah                    ; za‡ tek vertik ln¡ho zpˆtn‚ho bˆhu
         mov       al,7                     ; registr 7 - dopl¤kov‚ bity
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         test      ah,4                     ;
         jz        l_0F66
         or        bh,10h                   ; bit 8 registru
l_0F66:  test      ah,80h
         jz        l_0F6E
         or        bh,20h                   ; bit 9 registru

; ------ posun registru dan˜m smˆrem

l_0F6E:  add       bx,cx                    ; posun ve vertik ln¡m smˆru
         and       ah,7Bh                   ; nulov n¡ bit– registru 10h
         test      bh,20h                   ; je p©enos ?
         jz        l_0F7B
         or        ah,80h                   ; nastaven bit 9
l_0F7B:  test      bh,10h                   ; je p©enos
         jz        l_0F83
         or        ah,4                     ; nastaven bit 8

; ------ omezen¡ rozsahu posunu

l_0F83:  or        cx,cx                    ; byl posun nahoru ?
         js        l_0FA6                   ; byl posun nahoru
         test      word ptr cs:[d_0D33],8000h ; je ji‘ z porn  pozice ?
         jz        l_0F97                   ;
         add       cs:[d_0D33],cx           ; odchylka synchron. ve vert. smˆru
         jmp       short l_0FC3

l_0F97:  cmp       cs:[d_0D33],20h          ; odchylka synchron. ve vert. smˆru
         ja        l_0FD0
         add       cs:[d_0D33],cx           ; odchylka synchron. ve vert. smˆru
         jmp       short l_0FC3

l_0FA6:  test      cs:d_0D33,8000h          ; odchylka synchron. ve vert. smˆru
         jnz       l_0FB6
         add       cs:d_0D33,cx             ; odchylka synchron. ve vert. smˆru
         jmp       short l_0FC3

l_0FB6:  cmp       cs:d_0D33,0FFF5h         ; odchylka synchron. ve vert. smˆru
         jb        l_0FD0
         add       cs:d_0D33,cx             ; odchylka synchron. ve vert. smˆru

; ------ nov‚ nastaven¡ registr–

l_0FC3:  call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         mov       al,10h                   ; registr 10h
         mov       ah,bl
         call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0C8A                   ; £schova posunu obrazovky

l_0FD0:  ret

l_0F50   ENDP

; -----------------------------------------------------------------------------
;        horizont ln¡ posun displeje (o CX)
; -----------------------------------------------------------------------------

l_0FD1   PROC      near

; ------ ‡ten¡ sou‡asn‚ho nastaven¡ za‡ tku horizont ln¡ho zpˆtn‚ho bˆhu

         mov       al,4
         call      l_0F1B                   ; ‡ten¡ registru AL (hodnota do AH)
         xor       bh,bh
         mov       bl,ah                    ; sou‡asn  horiz. synchronizace

; ------ omezen¡ posunu

         add       bx,cx                    ; posun pozice
         mov       ah,bl
         or        cx,cx
         js        l_1001                   ; posun vlevo
         test      cs:d_0D31,8000h          ; odchylka synchron. v horiz. smˆru ;
         jz        l_0FF2
         add       cs:d_0D31,cx             ; odchylka synchron. v horiz. smˆru
         jmp       short l_101E

l_0FF2:  cmp       cs:d_0D31,8              ; odchylka synchron. v horiz. smˆru
         ja        l_1024
         add       cs:d_0D31,cx             ; odchylka synchron. v horiz. smˆru
         jmp       short l_101E

l_1001:  test      cs:d_0D31,8000h          ; odchylka synchron. v horiz. smˆru
         jnz       l_1011
         add       cs:d_0D31,cx             ; odchylka synchron. v horiz. smˆru
         jmp       short l_101E

l_1011:  cmp       cs:d_0D31,0FFFBh         ; odchylka synchron. v horiz. smˆru
         jb        l_1024
         add       cs:d_0D31,cx             ; odchylka synchron. v horiz. smˆru

; ------ nov‚ nastaven¡ registr–

l_101E:  call      l_0F0E                   ; nastaven¡ registru AL na hodnotu AH
         call      l_0C8A                   ; £schova posunu obrazovky

l_1024:  ret

l_0FD1   ENDP

         db        0

; -----------------------------------------------------------------------------
;        tabulka ©¡dic¡ch registr– videom¢du
; -----------------------------------------------------------------------------
; Struktura:  (8) registry 0 a‘ 7
;             (1) registr 9
;             (4) registr 10h a‘ 13h
;             (2) registr 15h a 16h
; -----------------------------------------------------------------------------

d_1026   label     byte

; 0: 7-0ch (nepovolen˜ m¢d: v¨echny karty), 0,1 (40x25/16: TSENG1,TSENG2,PARADISE,WESTERN)
d_1026   db        06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 047h, 0FBh,013h,0C7h,014h, 0F8h,005h

; 1: 2,3 (text 80x25/16: TSENG2,CIRRUS)
d_1035   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 047h, 0FAh,013h,0C7h,028h, 0F8h,005h

; 2: 4,5 (graf 320x200/4: TSENG1,TSENG2,PARADISE,WESTERN)
d_1044   db        06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 041h, 0FBh,013h,0C7h,014h, 0F8h,005h

; 3: 6 (graf 640x200/2: TSENG2, CIRRUS)
d_1053   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 041h, 0FAh,013h,0C7h,028h, 0F8h,005h

; 4: 0dh (graf 320x200/16: TSENG1,TSENG2,PARADISE,WESTERN)
d_1062   db        06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,013h,0C7h,014h, 0F8h,005h

; 5: 0eh (graf 640x200/16: TSENG2,CIRRUS)
d_1071   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FAh,013h,0C7h,028h, 0F8h,005h

; 6: 0fh,10h (graf 640x350/16(2): CIRRUS)
d_1080   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F0h,019h,0AEh,050h, 0EBh,0FBh

; 7: 11h,12h (graf 640x480/16(2): CIRRUS)
d_108f   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Eh,017h,0EFh,050h, 00Ah,019h

; 8: 13h (graf 320x200/256: TSENG2,CIRRUS)
d_109e   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FAh,093h,0C7h,028h, 0F8h,005h

; 9: 0,1 (text 40x25/16: CIRRUS)
d_10ad   db        034h,027h,028h,095h,02Fh,0B3h,036h,011h, 047h, 0FAh,005h,0C7h,014h, 0DAh,0E6h

; 0ah: 4,5 (graf 320x200/4: CIRRUS)
d_10bc   db        034h,027h,028h,095h,02Fh,093h,036h,011h, 041h, 0FAh,005h,0C7h,014h, 0DAh,0E6h

; 0bh: 0dh (graf 320x200/16: CIRRUS)
d_10cb   db        034h,027h,028h,095h,02Fh,093h,036h,011h, 040h, 0FAh,005h,0C7h,014h, 0DAh,0E6h

; 0ch: 0fh,10h (graf 640x350/16(2): TSENG1,PARADISE,WESTERN,OAK)
d_10da   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F1h,019h,0AEh,028h, 0EBh,0FBh

; 0dh: 11h,12h (graf 640x480/16(2): TSENG1,PARADISE,WESTERN,OAK)
d_10e9   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,028h, 00Ah,019h

; 0eh: 0fh,10h (graf 640x350/16(2): TSENG2)
d_10f8   db        06Ch,04Fh,050h,08Eh,05Bh,083h,06Bh,03Eh, 040h, 0E5h,005h,05Eh,028h, 0D6h,003h

; 0fh: 11h,12h (graf 640x480/16(2): TSENG2)
d_1107   db        06Ch,04Fh,050h,08Eh,05Bh,083h,06Bh,0BAh, 040h, 01Ch,008h,0DFh,028h, 0FFh,004h

; 10h: 0,1 (text 40x25/16: stand.,TRIDENT1)
d_1116   db        06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 047h, 0FCh,013h,0C7h,014h, 0F8h,005h

; 11h: 2,3 (text 80x25/16: stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK)
d_1125   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 047h, 0FBh,013h,0C7h,028h, 0F8h,005h

; 12h: 4,5 (graf 320x200/4: stand.,TRIDENT1)
d_1134   db        06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 041h, 0FCh,013h,0C7h,014h, 0F8h,005h

; 13h: 6 (graf 640x200/2: stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK)
d_1143   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 041h, 0FBh,013h,0C7h,028h, 0F8h,005h

; 14h: 0dh (graf 320x200/16: stand.,TRIDENT1)
d_1152   db        06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 040h, 0FCh,013h,0C7h,014h, 0F8h,005h

; 15h: 0eh (graf 640x200/16: stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK)
d_1161   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,013h,0C7h,028h, 0F8h,005h

; 16h: 0fh,10h (graf 640x350/16(2): stand.,TRIDENT1,TRIDENT2,REALTEK)
d_1170   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F1h,019h,0AEh,050h, 0EBh,0FBh

; 17h: 11h,12h (graf 640x480/16(2): stand.,TRIDENT1,TRIDENT2,REALTEK)
d_117f   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,050h, 00Ah,019h

; 18h: 13h (graf 320x200/256: stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK)
d_118e   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,093h,0C7h,028h, 0F8h,005h

; 19h: 0,1 (text 40x25/16: TRIDENT2,OAK,REALTEK)
d_119d   db        034h,027h,028h,095h,02Fh,0B3h,036h,011h, 047h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

; 1ah: 4,5 (graf 320x200/4: TRIDENT2,OAK,REALTEK)
d_11ac   db        034h,027h,028h,095h,02Fh,093h,036h,011h, 041h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

; 1bh: 0dh (graf 320x200/16: TRIDENT2,OAK,REALTEK)
d_11bb   db        034h,027h,028h,095h,02Fh,093h,036h,011h, 040h, 0FBh,005h,0C7h,014h, 0DAh,0E6h

; 1ch: 2eh (TSENG1)
d_11ca   db        06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,028h, 00Ah,019h

; 1dh:
d_11d9   db        06Ch,04Fh,050h,08Eh,05Bh,083h,06Bh,0BAh, 040h, 01Ch,008h,0DFh,050h, 0FFh,004h

; 1eh:
d_11e8   db        0C6h,09Fh,0A1h,08Ch,0A2h,096h,036h,011h, 040h, 0FCh,00Ah,0C7h,0A0h, 0CFh,0DBh

; 1fh:
d_11f7   db        0C6h,09Fh,0A1h,08Ch,09Fh,093h,036h,015h, 040h, 010h,004h,0EFh,0A0h, 0F6h,001h

; 20h:
d_1206   db        06Bh,04Fh,050h,08Eh,05Ah,083h,036h,01Dh, 040h, 00Dh,017h,0EFh,028h, 00Ah,019h

; 21h:
d_1215   db        0C6h,09Fh,0A1h,08Ch,09Fh,093h,036h,011h, 040h, 0FCh,00Ah,0C7h,0A0h, 0CFh,0DBh

; 22h:
d_1224   db        0C6h,09Fh,0A1h,08Ch,09Fh,093h,036h,015h, 040h, 00Fh,004h,0EFh,0A0h, 0F6h,001h

;ÚÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ¿
;³   ³  0,1  ³  2,3  ³  4,5  ³   6   ³  0dh  ³  0eh  ³0fh,10h³11h,12h³  13h  ³ostatn¡³
;³   ³ 40x25 ³ 80x25 ³320x200³320x640³320x200³640x200³640x350³640x480³320x200³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 0 ³108,52 ³  108  ³108,52 ³  108  ³108,52 ³  108  ³  108  ³  108  ³  108  ³  108  ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 1 ³  39   ³  79   ³  39   ³  79   ³  39   ³  79   ³  79   ³  79   ³  79   ³  39   ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 2 ³  40   ³  80   ³  40   ³  80   ³  40   ³  80   ³  80   ³  80   ³  80   ³  40   ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 3 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³ 14+b7 ³
;³   ³ 21+b7 ³       ³ 21+b7 ³       ³ 21+b7 ³       ³       ³       ³       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 4 ³ 91,47 ³   91  ³ 91,47 ³   91  ³ 91,47 ³   91  ³   91  ³   91  ³   91  ³   91  ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 5 ³  3+b7 ³  3+b7 ³  3+b7 ³  3+b7 ³  3+b7 ³  3+b7 ³  3+b7 ³  3+b7 ³  3+b7 ³  3+b7 ³
;³   ³19+b5+b7       ³ 19+b7 ³       ³ 19+b7 ³       ³       ³       ³       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 6 ³54(310)³54(310)³54(310)³54(310)³54(310)³54(310)³54(310)³54(310)³54(310)³54(310)³
;³   ³       ³       ³       ³       ³       ³       ³107    ³107    ³       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 7 ³ b0+b4 ³ b0+b4 ³ b0+b4 ³ b0+b4 ³ b0+b4 ³ b0+b4 ³ b0+b4 ³b0+b4+ ³ b0+b4 ³ b0+b4 ³
;³   ³       ³       ³       ³       ³       ³       ³b1+b2+ ³ +b6+b7³       ³       ³
;³   ³       ³       ³       ³       ³       ³       ³+b3+b4+³b1+b3+ ³       ³       ³
;³   ³       ³       ³       ³       ³       ³       ³  +b5  ³+b4+b5+³       ³       ³
;³   ³       ³       ³       ³       ³       ³       ³       ³  +b7  ³       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³ 9 ³ 7+b6  ³ 7+b6  ³ 1+b6  ³ 1+b6  ³ 0+b6  ³ 0+b6  ³ 0+b6  ³ 0+b6  ³ 0+b6  ³ 7+b6  ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³10h³ 250   ³ 250   ³ 250   ³ 250   ³ 250   ³ 250   ³240    ³14(526)³ 250   ³  251  ³
;³   ³ 251   ³ 251   ³ 251   ³ 251   ³ 251   ³ 251   ³241    ³15(527)³ 251   ³       ³
;³   ³ 252   ³       ³ 252   ³       ³ 252   ³       ³229(485)28(540)³       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³11h³  3+b4 ³  3+b4 ³  3+b4 ³  3+b4 ³  3+b4 ³  3+b4 ³  9+b4 ³  7+b4 ³3+b4+b7³  3+b4 ³
;³   ³   5   ³       ³   5   ³       ³   5   ³       ³   5   ³   8   ³       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³12h³  199  ³  199  ³  199  ³  199  ³  199  ³  199  ³  174  ³239(751)  199  ³  199  ³
;³   ³       ³       ³       ³       ³       ³       ³  350  ³223(479)       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³13h³  20   ³  40   ³  20   ³  40   ³  20   ³  40   ³ 80,40 ³ 80,40 ³  40   ³  20   ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³15h³  248  ³  248  ³  248  ³  248  ³  248  ³  248  ³  235  ³10(266)³  248  ³  248  ³
;³   ³  218  ³       ³  218  ³       ³  218  ³       ³214(470)  255  ³       ³       ³
;ÃÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ´
;³16h³ 5,e6h ³   5   ³ 5,e6h ³   5   ³ 5,e6h ³   5   ³ fbh,3 ³ 19h,4 ³   5   ³   5   ³
;ÀÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÙ

; -----------------------------------------------------------------------------
; 0,1 (text 40x25/16)
; stand.,TRIDENT1:                  06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 047h, 0FCh,013h,0C7h,014h, 0F8h,005h
; TSENG1,TSENG2,PARADISE,WESTERN:   06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 047h, 0FBh,013h,0C7h,014h, 0F8h,005h
; TRIDENT2,OAK,REALTEK:             034h,027h,028h,095h,02Fh,0B3h,036h,011h, 047h, 0FBh,005h,0C7h,014h, 0DAh,0E6h
; CIRRUS:                           034h,027h,028h,095h,02Fh,0B3h,036h,011h, 047h, 0FAh,005h,0C7h,014h, 0DAh,0E6h
; -----------------------------------------------------------------------------
; 2,3 (text 80x25/16)
; stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK:
;                                   06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 047h, 0FBh,013h,0C7h,028h, 0F8h,005h
; TSENG2,CIRRUS:                    06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 047h, 0FAh,013h,0C7h,028h, 0F8h,005h
; -----------------------------------------------------------------------------
; 4,5 (graf 320x200/4)
; stand.,TRIDENT1:                  06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 041h, 0FCh,013h,0C7h,014h, 0F8h,005h
; TSENG1,TSENG2,PARADISE,WESTERN:   06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 041h, 0FBh,013h,0C7h,014h, 0F8h,005h
; TRIDENT2,OAK,REALTEK:             034h,027h,028h,095h,02Fh,093h,036h,011h, 041h, 0FBh,005h,0C7h,014h, 0DAh,0E6h
; CIRRUS:                           034h,027h,028h,095h,02Fh,093h,036h,011h, 041h, 0FAh,005h,0C7h,014h, 0DAh,0E6h
; -----------------------------------------------------------------------------
; 6 (graf 640x200/2)
; stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK:
;                                   06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 041h, 0FBh,013h,0C7h,028h, 0F8h,005h
; TSENG2, CIRRUS:                   06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 041h, 0FAh,013h,0C7h,028h, 0F8h,005h
; -----------------------------------------------------------------------------
; 0dh (graf 320x200/16)
; stand.,TRIDENT1:                  06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 040h, 0FCh,013h,0C7h,014h, 0F8h,005h
; TSENG1,TSENG2,PARADISE,WESTERN:   06Ch,027h,028h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,013h,0C7h,014h, 0F8h,005h
; TRIDENT2,OAK,REALTEK:             034h,027h,028h,095h,02Fh,093h,036h,011h, 040h, 0FBh,005h,0C7h,014h, 0DAh,0E6h
; CIRRUS:                           034h,027h,028h,095h,02Fh,093h,036h,011h, 040h, 0FAh,005h,0C7h,014h, 0DAh,0E6h
; -----------------------------------------------------------------------------
; 0eh (graf 640x200/16)
; stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK:
;                                   06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,013h,0C7h,028h, 0F8h,005h
; TSENG2,CIRRUS:                    06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FAh,013h,0C7h,028h, 0F8h,005h
; -----------------------------------------------------------------------------
; 0fh,10h (graf 640x350/16(2))
; stand.,TRIDENT1,TRIDENT2,REALTEK: 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F1h,019h,0AEh,050h, 0EBh,0FBh
; TSENG1,PARADISE,WESTERN,OAK:      06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F1h,019h,0AEh,028h, 0EBh,0FBh
; TSENG2:                           06Ch,04Fh,050h,08Eh,05Bh,083h,06Bh,03Eh, 040h, 0E5h,005h,05Eh,028h, 0D6h,003h
; CIRRUS:                           06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0F0h,019h,0AEh,050h, 0EBh,0FBh
; -----------------------------------------------------------------------------
; 11h,12h (graf 640x480/16(2))
; stand.,TRIDENT1,TRIDENT2,REALTEK: 06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,050h, 00Ah,019h
; TSENG1,PARADISE,WESTERN,OAK:      06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,028h, 00Ah,019h
; TSENG2:                           06Ch,04Fh,050h,08Eh,05Bh,083h,06Bh,0BAh, 040h, 01Ch,008h,0DFh,028h, 0FFh,004h
; CIRRUS:                           06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Eh,017h,0EFh,050h, 00Ah,019h
; -----------------------------------------------------------------------------
; 13h (graf 320x200/256)
; stand.,TSENG1,TRIDENT1,TRIDENT2,PARADISE,WESTERN,OAK,REALTEK:
;                                   06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FBh,093h,0C7h,028h, 0F8h,005h
; TSENG2,CIRRUS:                    06Ch,04Fh,050h,08Eh,05Bh,083h,036h,011h, 040h, 0FAh,093h,0C7h,028h, 0F8h,005h
; -----------------------------------------------------------------------------
; 1ch:                              06Ch,04Fh,050h,08Eh,05Bh,083h,036h,01Dh, 040h, 00Fh,017h,0EFh,028h, 00Ah,019h
; 1dh:                              06Ch,04Fh,050h,08Eh,05Bh,083h,06Bh,0BAh, 040h, 01Ch,008h,0DFh,050h, 0FFh,004h
; 1eh:                              0C6h,09Fh,0A1h,08Ch,0A2h,096h,036h,011h, 040h, 0FCh,00Ah,0C7h,0A0h, 0CFh,0DBh
; 1fh:                              0C6h,09Fh,0A1h,08Ch,09Fh,093h,036h,015h, 040h, 010h,004h,0EFh,0A0h, 0F6h,001h
; 20h:                              06Bh,04Fh,050h,08Eh,05Ah,083h,036h,01Dh, 040h, 00Dh,017h,0EFh,028h, 00Ah,019h
; 21h:                              0C6h,09Fh,0A1h,08Ch,09Fh,093h,036h,011h, 040h, 0FCh,00Ah,0C7h,0A0h, 0CFh,0DBh
; 22h:                              0C6h,09Fh,0A1h,08Ch,09Fh,093h,036h,015h, 040h, 00Fh,004h,0EFh,0A0h, 0F6h,001h

d_1233   dw        256 dup (0)              ; buffer k £schovˆ stavu ovlad. my¨i

Code     ends

         end       start

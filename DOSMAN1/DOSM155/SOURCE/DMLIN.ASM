
; modul DOSMLIN.ASM - editace © dku textu

; *****************************************************************************
;
;                          Editace © dky
;
; *****************************************************************************
extrn    color:byte,outch0:near,outch1:near,testshft:near,inpkey:near
extrn    mouseon:near,mouseoff:near,mouseget:near

code     segment   public
         assume    cs:code,ds:code

public   obrlin

obrlin:                                   ;* zobrazen¡ editovan‚ho © dku
                                            ; VSTUP: CS:BP=tabulka definice

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es
         push      ds
         call      mouseoff                 ; vypnut¡ my¨i
         mov       dx,cs:[bp+12]            ; po‡ te‡n¡ pozice na displeji
         xor       ch,ch                    ; CH <- 0
         mov       cl,cs:[bp+14]            ; ¨¡©ka zobrazen‚ho textu
         mov       al,cs:[bp+15]            ; atribut pro zobrazen¡ © dku
         mov       cs:[color],al            ; nastaven¡ barvy textu
         lds       di,cs:[bp+0]             ; adresa bufferu s textem
         add       di,cs:[bp+10]            ; za‡ tek zobrazen‚ho textu
         mov       bx,cs:[bp+6]             ; skute‡n˜ po‡et znak– v bufferu
         sub       bx,cs:[bp+10]            ; po‡et znak– do zbytku © dku
         jnc       obrlin1
         xor       bx,bx                    ; nezobraz¡ se ‘ dn˜ znak
obrlin1: xchg      si,di
         jcxz      obrlin4                  ; nen¡ ‘ dn˜ znak na © dku
obrlin2: or        bx,bx                    ; je tisknuteln˜ znak ?
         mov       al," "                   ; n hradn¡ znak mezery
         jz        obrlin3                  ; znak se netiskne
         lodsb                              ; znak k zobrazen¡
         dec       bx                       ; sn¡‘en¡ ‡¡ta‡e znak–
obrlin3: push      cx
         mov       cx,1
         call      outch0                   ; zobrazen¡ znaku
         pop       cx
         loop      obrlin2                  ; zobrazen¡ dal¨¡ho znaku
obrlin4: call      mouseon                  ; zapnut¡ my¨i
         pop       ds
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

public   kurzlin

kurzlin:                                  ;* zobrazen¡ kurzoru na © dku
                                            ; VSTUP: CS:BP=tabulka definice

         push      ax
         push      dx
         mov       ax,cs:[bp+8]             ; pozice kurzoru v bufferu
         sub       ax,cs:[bp+10]            ; offset od za‡ tku zobraz. textu
         add       al,cs:[bp+12]            ; v˜po‡et pozice na displeji
         mov       dl,al                    ; pozice na displeji
         mov       dh,cs:[bp+13]            ; © dek na displeji
         xor       al,al                    ; funkce nastaven¡ pozice kurzoru
         call      outch1                   ; nastaven¡ pozice kurzoru
         pop       dx
         pop       ax
         ret

public   edilin

edilin:                                   ;* editace p©¡kazov‚ho © dku
                                            ; VSTUP: CS:BP=tabulka definice
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         lds       si,cs:[bp+0]             ; adresa bufferu textu
         mov       dx,cs:[bp+8]             ; pozice kurzoru v © dku
         mov       cx,cs:[bp+18]            ; © dkov˜ kurzor
         xor       di,di                    ; p©¡znak - © dek nebyl modifikov n
         or        ax,ax                    ; je 0000 (normalizace)
         jz        edilin4                  ; je normalizace parametr–
         or        ah,ah                    ; je k¢d s Alt ?
         je        edilin3                  ; je k¢d s Alt
         cmp       ax,0300h                 ; je znak Ctrl-@ ?
         je        edilin3                  ; je Ctrl-@
         cmp       al,32                    ; je znak ASCII ?
         jc        edilin2                  ; nen¡ k¢d ASCII
         cmp       al,7fh                   ; je kl vesa ^BS ?
         je        edilin2                  ; je kl vesa ^BS
edilin3: call      charlin                  ; vlo‘en¡ znaku do © dku
         jmp       short edilin4
edilin2: lea       bx,[skoklin]             ; tabulka skok– pro editaci © dku
         call      skokax                   ; proveden¡ skoku do obsluhy AX
         jc        edilin5                  ; nen¡ obsluhovan  kl vesa
edilin4: mov       cs:[bp+8],dx             ; nov  pozice kurzoru v © dku
         mov       cs:[bp+18],cx            ; © dkov˜ kurzoru
         call      normkur                  ; normalizace kurzoru
         or        di,di                    ; byl © dek modifikov n ?
         jz        edilin6                  ; © dek nebyl modifikov n
         call      obrlin                   ; zobrazen¡ editovan‚ho © dku
edilin6: call      kurzlin                  ; nastaven¡ pozice kurzoru
edilin7: call      normrol                  ; normalizace rolov n¡
         clc
edilin5: pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

public   normrol

normrol:                                  ;* normalizace rolov n¡
         push      ax
         push      bx
         push      cx
         push      dx
         mov       ax,cs:[bp+18]            ; pozice kurzoru
         mov       bx,cs:[bp+20]            ; za‡ tek rolov n¡
         mov       cl,cs:[bp+22]            ; po‡et © dk– na okno
         xor       ch,ch                    ; CH <- 0
         mov       dx,cs:[bp+16]            ; celkov˜ po‡et © dk–
         cmp       bx,dx                    ; kontrola p©ete‡en¡ prvn¡ho © dku
         jb        normrl0                  ; nen¡ p©ekro‡en posledn¡ © dek
         mov       bx,dx
         dec       bx
         mov       cs:[bp+20],bx            ; nov˜ po‡ te‡n¡ © dek
normrl0: cmp       ax,dx                    ; kontrola p©ete‡en¡ kurzoru © dku
         jb        normrl1                  ; nen¡ p©ekro‡en posledn¡ © dek
         mov       ax,dx
         dec       ax
         jns       normrl7
         xor       ax,ax
normrl7: mov       cs:[bp+18],ax            ; nov  pozice kurzoru
normrl1: sub       dx,cx                    ; maxim ln¡ za‡ tek okna
         jbe       normrl3                  ; je mal˜ po‡et © dk–
                                          ;* ohrani‡en¡ shora
         sub       ax,1                     ; rezerva na horn¡m okraji
         jbe       normrl3                  ; je © dek 5 nebo men¨¡
         cmp       ax,bx                    ; je nad horn¡m okrajem ?
         jb        normrl4                  ; je nad horn¡m okrajem
                                          ;* obrani‡en¡ zdola
         add       ax,3                     ; n vrat pozice + okraj 1 © dek
         sub       ax,cx                    ; korekce pokud je pod doln¡m okr.
         jbe       normrl2                  ; nen¡ je¨tˆ pod doln¡m okrajem
         cmp       ax,bx                    ; je pod doln¡m okrajem ?
         jnb       normrl4                  ; je pod doln¡m okrajem
normrl2: mov       ax,bx
         jmp       short normrl4            ; je konec okna
normrl3: xor       ax,ax                    ; n hradn¡ za‡ tek okna
         xor       dx,dx
normrl4: cmp       ax,dx                    ; je p©ekro‡en maxim ln¡ za‡ tek ?
         jbe       normrl6                  ; nen¡ p©ekro‡en maxim ln¡ za‡ tek
         mov       ax,dx                    ; maxim ln¡ za‡ tek
normrl6: mov       cs:[bp+20],ax            ; nastaven¡ nov‚ho za‡ tku
normrl5: pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret



public   normkur

normkur:                                  ;* normalizace kurzoru
                                            ; VSTUP: DX=pozice kurzoru
         push      ax
         push      bx
         push      cx
         push      dx
         mov       ax,cs:[bp+8]             ; pozice kurzoru
         mov       bx,cs:[bp+10]            ; za‡ tek zobrazen‚ho © dku
         mov       cl,cs:[bp+14]            ; d‚lka © dku
         xor       ch,ch                    ; CH <- 0
         mov       dx,cs:[bp+6]             ; po‡et znak– v bufferu
         inc       dx
         sub       dx,cx                    ; maxim ln¡ za‡ tek © dku
         jbe       normkur3                 ; je kr tk˜ © dek
                                          ;* ohrani‡en¡ z lev‚ strany
         sub       ax,5                     ; rezerva na lev‚m okraji
         jbe       normkur3                 ; je pozice 5 nebo men¨¡
         cmp       ax,bx                    ; je p©ed lev˜m okrajem ?
         jb        normkur4                 ; je p©ed lev˜m okrajem
                                          ;* obrani‡en¡ z prav‚ strany
         add       ax,10                    ; n vrat pozice + okraj 5 znak–
         sub       ax,cx                    ; korekce pokud je na prav‚m okraji
         jbe       normkur2                 ; nen¡ je¨tˆ za prav˜m okrajem
         cmp       ax,bx                    ; je za prav˜m okrajem ?
         jnb       normkur4                 ; je za prav˜m okrajem
normkur2:mov       ax,bx
         jmp       short normkur4           ; je konec © dku
normkur3:xor       ax,ax                    ; n hradn¡ za‡ tek textu
         xor       dx,dx
normkur4:cmp       ax,dx                    ; je p©ekro‡en maxim ln¡ za‡ tek ?
         jbe       normkur6                 ; nen¡ p©ekro‡en maxim ln¡ za‡ tek
         mov       ax,dx                    ; maxim ln¡ za‡ tek
normkur6:
         cmp       ax,cs:[bp+10]            ; byla zmˆna po‡ tku © dku ?
         je        normkur5                 ; nebyla zmˆna po‡ tku © dku
         inc       di                       ; p©¡znak - © dek byl modifikov n
         mov       cs:[bp+10],ax            ; nastaven¡ nov‚ho za‡ tku
normkur5:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret



public   skokax

skokax:                                   ;* skok podle registru AX
                                            ; VSTUP: AX=hodnota pro vˆtven¡
                                            ;        CS:BX=tabulka pro vˆtven¡
                                            ;  ©¡dic¡ k¢d odd¡lu tabulky:
                                            ;    0 = je konec tabulky
                                            ;    bit 7: 1=testuje se slovo AX
                                            ;           0=testuje se bajt AL/AH
                                            ;             bit 6: 0=test AL
                                            ;             bit 6: 1=test AH
                                            ;    ostatn¡ bity: po‡et k¢d– odd¡lu

         push      cx                       ; £schova CX
         push      ax
                                          ;* za‡ tek hled n¡ v odd¡lu tabulky
skokax1: pop       ax                       ; n vrat k¢du pro porovn n¡
         push      ax                       ; £schova k¢du pro porovn n¡
         mov       cl,cs:[bx]               ; na‡ten¡ ©¡dic¡ho k¢du odd¡lu
         inc       bx                       ; zv˜¨en¡ ukazatele tabulky
         or        cl,cl                    ; je ji‘ konec cel‚ tabulky ?
         je        skokax9                  ; je konec tabulky - chyba
         mov       ch,cl                    ; £schova ©¡dic¡ho bajtu
         and       cl,7fh                   ; vynulov n¡ bitu 7
         jz        skokax1                  ; nen¡ ‘ dn˜ k¢d
         test      ch,80h                   ; testuje se slovo AX ?
         jnz       skokax5                  ; testuje se slovo AX
                                          ;* testuje se bajt
         and       cl,3fh                   ; vynulov n¡ i bitu 6
         jz        skokax1                  ; nen¡ ‘ dn˜ k¢d
         test      ch,40h                   ; testuje se bajt AH ?
         jz        skokax2                  ; testuje se bajt AL
         xchg      ah,al                    ; AL <- AH
skokax2: xor       ch,ch                    ; CH <- 0
skokax3: inc       bx                       ; p©esko‡en¡ k¢du pro porovn n¡
         cmp       al,cs:[bx-1]             ; test bajtu AL
         je        skokax4                  ; k¢d nalezen - skok do obsluhy
         add       bx,2                     ; p©esko‡en¡ adresy obsluhy a k¢du
         loop      skokax3                  ; test dal¨¡ polo‘ky
         jmp       short skokax1            ; k¢d nenalezen - dal¨¡
skokax4:                                  ;* skok do obsluhy
         pop       ax
         pop       cx
         push      cs:[skokax42]            ; n vratov  adresa do bufferu
         push      cs:[bx]                  ; adresa skoku do obsluhy
         xor       bx,bx                    ; BX <- 0
         ret                                ; skok do obsluhy
skokax41:clc                                ; p©¡znak - k¢d nalezen
         ret

skokax42 dw        offset skokax41          ; adresa pro n vrat

                                          ;* testuje se slovo AX
skokax5: xor       ch,ch                    ; CH <- 0
skokax6: add       bx,2                     ; p©esko‡en¡ k¢du pro porovn n¡
         cmp       ax,cs:[bx-2]             ; test slova AX
         je        skokax4                  ; skok do obsluhy
         add       bx,2                     ; p©esko‡en¡ adresy obsluhy
         loop      skokax6                  ; test dal¨¡ polo‘ky
         jmp       short skokax1
skokax9: pop       ax
         pop       cx
         stc                                ; p©¡znak - k¢d nenalezen
         ret


public   skoklin

skoklin  label     word                     ; tabulka skok– pro editaci © dku
         db        00h+17                   ; testuje se AL, po‡et k¢d–
         db        01h                      ; slovo vlevo ^A
         dw        offset leftwlin
         db        03h                      ; str nka dol–
         dw        offset pgdnrol
         db        04h                      ; kurzor vpravo ^D
         dw        offset rightlin
         db        05h                      ; kurzor nahoru ^E
         dw        offset uprol
         db        06h                      ; slovo vpravo ^F
         dw        offset rghtwlin
         db        07h                      ; maz n¡ znaku vlevo ^G
         dw        offset delchlin
         db        08h                      ; maz n¡ znaku vlevo BS, ^H
         dw        offset bschlin
         db        10h                      ; vlo‘en¡ znaku ^P
         dw        offset speclin
         db        12h                      ; str nka nahoru ^R
         dw        offset pguprol
         db        13h                      ; kurzor vlevo ^S
         dw        offset leftlin
         db        14h                      ; maz n¡ slova vpravo ^T
         dw        offset delwlin
         db        18h                      ; kurzor dol– ^X
         dw        offset downrol
         db        19h                      ; vymaz n¡ © dky ^Y
         dw        offset delllin
         db        17h                      ; posun nahoru ^W
         dw        offset moveup
         db        1ah                      ; posun dol– ^Z
         dw        offset movedown
         db        1fh                      ; z mˆna dvou znak– ^-
         dw        offset xchgch
         db        7fh                      ; maz n¡ slova vlevo ^BS
         dw        offset bswlin

         db        40h+18                   ; testuje se AH, po‡et k¢d–
         db        4bh                      ; kurzor vlevo LEFFT
         dw        offset leftlin
         db        4dh                      ; kurzor vpravo RIGHT
         dw        offset rightlin
         db        47h                      ; HOME
         dw        offset homelin
         db        4fh                      ; END
         dw        offset endlin
         db        53h                      ; DELETE
         dw        offset delchlin
         db        74h                      ; slovo vpravo ^RIGHT
         dw        offset rghtwlin
         db        73h                      ; slovo vlevo ^LEFT
         dw        offset leftwlin
         db        93h                      ; maz n¡ slova vpravo ^DELETE
         dw        offset delwlin
         db        48h                      ; kurzor nahoru UP
         dw        offset uprol
         db        50h                      ; kurzor dol– DOWN
         dw        offset downrol
         db        77h                      ; horn¡ okraj ^HOME
         dw        offset homerol
         db        75h                      ; doln¡ okraj ^END
         dw        offset endrol
         db        49h                      ; o str nku nahoru PAGEUP
         dw        offset pguprol
         db        51h                      ; o str nku dol– PAGEDONW
         dw        offset pgdnrol
         db        84h                      ; prvn¡ polo‘ka ^PAGEUP
         dw        offset cpguprol
         db        76h                      ; posledn¡ polo‘ka ^PAGEDOWN
         dw        offset cpgdnrol
         db        8dh                      ; 6 © dk– nahoru ^UP
         dw        offset cuprol
         db        91h                      ; 6 © dk– dol– ^DOWN
         dw        offset cdownrol

         db        0                        ; konec tabulky


public   leftlin

leftlin:                                  ;* posun kurzoru vlevo
         or        dx,dx                    ; je kurzor ji‘ na za‡ tku ?
         je        leftlin1                 ; kurzor je ji‘ na za‡ tku © dku
         dec       dx                       ; sn¡‘en¡ pozice kurzoru
         call      testshft                 ; test stisku kl vesy Shift
         jz        leftlin1                 ; kl vesa Shift nen¡ stisknuta
         inc       di                       ; p©¡znak - © dek modifikov n
         dec       word ptr cs:[bp+10]      ; posun © dku vpravo
         jns       leftlin1                 ; nen¡ je¨tˆ p©ekro‡en¡ za‡ tku
         dec       di                       ; n vrat p©¡znaku modifikace © dku
         inc       word ptr cs:[bp+10]      ; n vrat za‡ tku © dku
leftlin1:ret


public   rightlin

rightlin:                                 ;* posun kurzoru vpravo
         cmp       dx,cs:[bp+6]             ; kontrola posledn¡ pozice
         jae       rightln1                 ; je ji‘ posledn¡ pozice
         inc       dx                       ; zv˜¨en¡ pozice kurzoru
         call      testshft                 ; test stisku kl vesy Shift
         jz        rightln1                 ; kl vesa Shift nen¡ stisknuta
         inc       di                       ; p©¡znak - © dek modifikov n
         inc       word ptr cs:[bp+10]      ; posun © dku vlevo
rightln1:ret


public   delllin

delllin:                                  ;* vymaz n¡ cel‚ho © dku
         xor       dx,dx                    ; prvn¡ pozice na © dku
         mov       cs:[bp+6],dx             ; zru¨en¡ znak– v bufferu
         inc       di                       ; p©¡znak - © dek modifikov n
         ret

public   homelin
                                          ;* posun na prvn¡ pozici © dku
homelin: xor       dx,dx                    ; prvn¡ pozice na © dku
         ret


public   endlin
                                          ;* posun na posledn¡ pozici © dku
endlin:  mov       dx,cs:[bp+6]             ; nov  pozice za koncem © dku
         ret


public   leftwlin
                                          ;* posun kurzoru vlevo
leftwlin:or        dx,dx                    ; je kurzor ji‘ na za‡ tku ?
         je        lftwlin2                 ; kurzor je ji‘ na za‡ tku © dku
         call      testchl                  ; je oddˆlovac¡ znak ?
         jnc       lftwlin1                 ; je platn˜ znak
         call      leftlin                  ; sn¡‘en¡ pozice kurzoru
         jmp       short leftwlin           ; nalezen¡ platn‚ho znaku
lftwlin1:or        dx,dx                    ; je kurzor ji‘ na za‡ tku ?
         je        lftwlin2                 ; kurzor je ji‘ na za‡ tku © dku
         call      testchl                  ; je oddˆlovac¡ znak ?
         jc        lftwlin2                 ; je oddˆlovac¡ znak
         call      leftlin                  ; sn¡‘en¡ pozice kurzoru
         jmp       short lftwlin1           ; nalezen¡ za‡ tku slova
lftwlin2:ret



public   rghtwlin
                                          ;* posun o slovo vpravo
rghtwlin:cmp       dx,cs:[bp+6]             ; kontrola posledn¡ pozice
         jae       rghtwln2                 ; je ji‘ posledn¡ pozice
         call      testch                   ; je oddˆlovac¡ znak ?
         jc        rghtwln1                 ; je oddˆlovac¡ znak
         call      rightlin                 ; zv˜¨en¡ pozice kurzoru
         jmp       short rghtwlin           ; nalezen¡ konce slova
rghtwln1:cmp       dx,cs:[bp+6]             ; kontrola posledn¡ pozice
         jae       rghtwln2                 ; je ji‘ posledn¡ pozice
         call      testch                   ; je oddˆlovac¡ znak ?
         jnc       rghtwln2                 ; je platn˜ znak
         call      rightlin                 ; zv˜¨en¡ pozice kurzoru
         jmp       short rghtwln1           ; nalezen¡ za‡ tku slova
rghtwln2:ret



public   bswlin
                                          ;* maz n¡ slova vlevo
bswlin:  or        dx,dx                    ; je kurzor ji‘ na za‡ tku ?
         je        bswlin2                  ; kurzor je ji‘ na za‡ tku © dku
         call      testchl                  ; test znaku p©ed kurzorem
         jnc       bswlin1                  ; je platn˜ znak
         call      bschlin                  ; maz n¡ znaku vlevo
         jmp       short bswlin             ; vymaz n¡ oddˆlova‡–
bswlin1: or        dx,dx                    ; je kurzor ji‘ na za‡ tku ?
         je        bswlin2                  ; kurzor je ji‘ na za‡ tku © dku
         call      testchl                  ; test znaku p©ed pozic¡ kurzoru
         jc        bswlin2                  ; je oddˆlova‡
         call      bschlin                  ; maz n¡ znaku vlevo
         jmp       short bswlin1            ; vymaz n¡ platn˜ch znak–
bswlin2: ret



public   delwlin
                                          ;* maz n¡ slova vpravo
delwlin: cmp       dx,cs:[bp+6]             ; kontrola posledn¡ pozice
         jae       delwlin2                 ; je ji‘ posledn¡ pozice
         call      testch                   ; test znaku
         jc        delwlin1                 ; je oddˆlovac¡ znak
         call      delchlin                 ; maz n¡ znaku nad kurzorem
         jmp       short delwlin            ; vymaz n¡ platn˜ch znak–
delwlin1:cmp       dx,cs:[bp+6]             ; kontrola posledn¡ pozice
         jae       delwlin2                 ; je ji‘ posledn¡ pozice
         call      testch                   ; test znaku p©ed pozic¡ kurzoru
         jnc       delwlin2                 ; je platn˜ znak
         call      delchlin                 ; maz n¡ znaku nad kurzorem
         jmp       short delwlin1           ; vymaz n¡ oddˆlova‡–
delwlin2:ret



public   bschlin,delchlin
                                          ;* maz n¡ znaku vlevo
bschlin: or        dx,dx                    ; je kurzor ji‘ na za‡ tku ?
         je        delchln2                 ; kurzor je ji‘ na za‡ tku © dku
         call      leftlin                  ; sn¡‘en¡ pozice kurzoru

                                          ;* zru¨en¡ znaku nad kurzorem
delchlin:push      ax
         push      bx
         push      cx
         push      si
         mov       cx,cs:[bp+6]             ; skute‡n˜ po‡et znak– v © dku
         sub       cx,dx                    ; po‡et znak– do zbytku © dku
         jbe       delchln1                 ; je na konci © dku
         push      di
         dec       cx                       ; po‡et znak– - 1
         add       si,dx                    ; pozice kurzoru v bufferu
         mov       di,si                    ; nov˜ za‡ tek textu
         inc       si                       ; star˜ za‡ tek textu v bufferu
         rep       movsb                    ; posun textu o pozici
         dec       word ptr cs:[bp+6]       ; sn¡‘en¡ po‡tu znak– v © dku
         pop       di
         inc       di                       ; p©¡znak - © dek byl modifikov n
delchln1:pop       si
         pop       cx
         pop       bx
         pop       ax
delchln2:ret


public   xchgch

xchgch:                                   ;* z mˆna dvou znak– ^-
         push      dx                       ; pozice kurzoru
         push      si
         inc       dx
         cmp       dx,cs:[bp+6]             ; kontrola max. pozice
         jae       xchgch2                  ; kurzor je na konci © dku
         dec       dx
         add       si,dx                    ; adresa kurzoru v bufferu
         mov       ax,ds:[si]               ; dva znaky z textu
         xchg      ah,al                    ; z mˆna znak–
         mov       ds:[si],ax               ; ulo‘en¡ znak–
         inc       di                       ; p©¡znak - © dek byl modifikov n
xchgch2: pop       si
         pop       dx
         ret


public   speclin

speclin:                                  ;* vlo‘en¡ zvl ¨tn¡ho znaku

         xor       ax,ax
         int       16h                      ; vstup znaku z kl vesnice
;         call      inpkey                   ; vstup znaku z kl vesnice

public   charlin

charlin:                                  ;* vlo‘en¡ znaku AL do © dku

         push      ax
         push      bx
         push      cx
         push      si
         mov       cx,cs:[bp+6]             ; skute‡n˜ po‡et znak– v © dku
         cmp       cx,cs:[bp+4]             ; je ji‘ dosa‘eno max. po‡tu znak– ?
         jae       charlin4                 ; znak se do © dku ji‘ nevejde

         push      di
         add       si,dx                    ; pozice kurzoru v bufferu
         sub       cx,dx                    ; po‡et znak– do zbytku © dku
         add       si,cx                    ; nov˜ konec textu v bufferu
         mov       di,si
         dec       si                       ; star˜ konec textu v bufferu
         std                                ; smˆr dol–
         rep       movsb                    ; posun textu o pozici
         cld                                ; smˆr nahoru
         stosb                              ; vlo‘en¡ znaku
         inc       dx                       ; zv˜¨en¡ pozice kurzoru
         inc       word ptr cs:[bp+6]       ; zv˜¨en¡ po‡tu znak– v © dku
         pop       di
         inc       di                       ; p©¡znak - © dek byl modifikov n
charlin4:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret


public   testchl,testch,testchar

testchl:                                  ;* test znaku p©ed pozic¡ kurzoru
         push      si                       ; adresa bufferu
         add       si,dx                    ; adresa znaku v bufferu
         mov       al,ds:[si-1]             ; testovan˜ znak z bufferu
         pop       si
         jmp       short testchar

testch:                                   ;* test znaku v bufferu
         push      si                       ; adresa bufferu
         add       si,dx                    ; adresa znaku v bufferu
         mov       al,ds:[si]               ; testovan˜ znak z bufferu
         pop       si

testchar:                                 ;* test znaku, zda je oddˆlovac¡
                                            ; VSTUP: AL=znak
                                            ; VSTUP: CY=je oddˆlovac¡ znak

         cmp       al," "+1
         jb        testch6

;         cmp       al," "
;         je        testch5
;         cmp       al,9
;         je        testch5
         cmp       al,"\"
         je        testch5
;         cmp       al":"
;         je        testch5
         cmp       al,"."
         je        testch5
         stc
testch5: cmc
testch6: ret

;         cmp       al,"!"
;         je        testch5
;         cmp       al,"#"
;         je        testch5
;         cmp       al,"$"
;         je        testch5
;         cmp       al,"%"
;         je        testch5
;         cmp       al,"*"
;         je        testch5
;         cmp       al,"0"
;         jb        testch6
;         cmp       al,"9"+1
;         jb        testch5
;         cmp       al,"@"
;         jb        testch6
;         cmp       al,"Z"+1
;         jb        testch5
;         cmp       al,"a"
;         jb        testch6
;         cmp       al,"z"+1
;         jb        testch5
;         cmp       al,128
;         jb        testch6
;testch5: clc                                ; p©¡znak - nen¡ oddˆlovac¡ znak
;         ret
;testch6: stc                                ; p©¡znak - je oddˆlovac¡ znak
;         ret

; -----------------------------------------------------------------------------
public   uprol

uprol:                                    ;* posun o © dek nahoru
         or        cx,cx                    ; je ji‘ prvn¡ © dek ?
         je        uprol1                   ; je ji‘ prvn¡ © dek
         dec       cx                       ; posun kurzoru nahoru
         call      testshft                 ; test stisku kl vesy Shift
         jz        uprol1                   ; kl vesa Shift nen¡ stisknuta
movedown:dec       word ptr cs:[bp+20]      ; posun okna dol–
         jns       uprol1                   ; nen¡ je¨tˆ p©ekro‡en¡ okraje
         inc       word ptr cs:[bp+20]      ; n vrat za‡ tku okna
uprol1:  ret


public   downrol

downrol:                                  ;* posun o © dek dol–
         cmp       cx,cs:[bp+16]            ; kontrola posledn¡ho © dku
         jae       downrol1                 ; je ji‘ posledn¡ © dek
         inc       cx
         call      testshft                 ; test stisku kl vesy Shift
         jz        downrol1                 ; kl vesa Shift nen¡ stisknuta
moveup:  inc       word ptr cs:[bp+20]      ; posun okna nahoru
downrol1:ret


public   homerol
                                          ;* posun na prvn¡ © dek okna
homerol: mov       cx,cs:[bp+20]            ; prvn¡ © dek okna
         inc       cx
         ret


public   endrol
                                          ;* posun na posledn¡ © dek okna
endrol:  mov       cx,cs:[bp+20]            ; prvn¡ © dek okna
         add       cl,cs:[bp+22]            ; p©i‡ten¡ po‡tu © dk–
         adc       ch,0                     ; CX=posledn¡ © dek+1
         sub       cx,2                     ; ‡¡slo posledn¡ho © dku
         jnc       endrol1                  ; nen¡ podte‡en¡
         inc       cx                       ; n vrat ‡¡sla posledn¡ho © dku
         jns       endrol1
         inc       cx
endrol1: ret


public   pguprol
                                          ;* posun o str nku nahoru
pguprol: push      ax
         xor       ah,ah
         mov       al,cs:[bp+22]            ; po‡et zobrazen˜ch © dk–
         sub       ax,1                     ; po‡et © dk– - 1
         sub       cx,ax                    ; posun o obrazovku nahoru
         jnc       pguprol1                 ; nen¡ podte‡en¡ za‡ tku
         xor       cx,cx                    ; je prvn¡ © dek
pguprol1:sub       cs:[bp+20],ax            ; posun zobrazen‚ho okna
         jnc       pguprol2                 ; nen¡ podte‡en¡
         mov       word ptr cs:[bp+20],0    ; prvn¡ © dek = 0
pguprol2:pop       ax
         ret


public   pgdnrol
                                          ;* posun o str nku dol–
pgdnrol: push      ax
         xor       ah,ah
         mov       al,cs:[bp+22]            ; po‡et zobrazen˜ch © dk–
         sub       ax,1                     ; po‡et © dk– - 1
         add       cx,ax                    ; posun o obrazovku dol–
         add       cs:[bp+20],ax            ; posun zobrazen‚ho okna
         pop       ax
         ret


public   cpguprol
                                          ;* posun na prvn¡ polo‘ku
cpguprol:xor       cx,cx                    ; ‡¡slo prvn¡ polo‘ky
         ret


public   cpgdnrol
                                          ;* posun na posledn¡ polo‘ku
cpgdnrol:mov       cx,cs:[bp+16]            ; nov  pozice za koncem © dku
         or        cx,cx
         jz        cpgdnrl1
         dec       cx
cpgdnrl1:ret


public   cuprol
                                          ;* posun o 6 © dek nahoru
cuprol:  push      ax
         push      dx
         mov       dx,6                     ; po‡et posuv–
cuprol1: call      uprol                    ; posun o © dku nahoru
         dec       dx
         jnz       cuprol1                  ; posun o dal¨¡ © dku
         pop       dx
         pop       ax
         ret


public   cdownrol
                                          ;* posun o 6 © dek dol–
cdownrol:push      ax
         push      dx
         mov       dx,6                     ; po‡et posuv–
cdnrol1: call      downrol                  ; posun o © dek dol–
         dec       dx
         jnz       cdnrol1                  ; posun o dal¨¡ © dek
         pop       dx
         pop       ax
         ret


code     ends

         end

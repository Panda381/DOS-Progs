
; Impulsy:        110 ms < "0" < 165 ms
;                 220 ms < "1" < 275 ms

; -----------------------------------------------------------------------------
; Stanice sly®itelnÇ v Evropà:
; ---------------------------
;  DCF77 - Mainfligen (SRN)
;  HBG - Prangins (õvòcarsko)
;  MSF - Rugby (Velk† Brit†nie)
;  OMA - Liblice (ÄR) (viz AR 1976 a 1979)
;
; Vys°laá DCF je um°stàn v Mainfligenu pobl°ë Frankfurtu nad Mohanem (SRN).
; Vys°laá vys°l† na kmitoátu 77.5 kHz a m† vòkon 27 kW. Nep©esnost £daje
; je 2 * 10^-13 za 100 dn°. Sekundov† znaáka je vytvo©ena zmen®en°m amplitudy
; nosnÇ na 25 % na zaá†tku kaëdÇ sekundy. DÇlka sekundovÇ znaáky je buÉ 100 ms
; (="0") nebo 200 ms (="1"). Bàhem kaëdÇ minuty je odvys°l†na £pln† áasov†
; informace mezi 20. aë 58. sekundou - tj. st©edoevropskò áas, platnò pro
; n†sleduj°c° minutu souáasnà s datem. Zaá†tek p©enosu zaá°n† ve 20. sekundà
; kaëdÇ minuty odvys°l†n°m sekundovÇ znaáky "1". V®echny £daje jsou p©en†®eny
; v BCD k¢du (od nejnië®°ch bitñ a od nejnië®°ch á°slic). ódaje minut jsou
; odvys°l†ny mezi 21. aë 27. sekundou (4 + 3 bity). V 28. sekundà je vys°l†n
; paritn° bit pro minuty (sud† parita). ódaje hodin jsou vys°l†ny mezi
; 29. aë 34. sekundou (4 + 2 bity), ve 35. sekundà je vys°l†n paritn° bit pro
; hodiny. Mezi 36. aë 41. sekundou je vys°l†n den (4 + 2 bity), mezi
; 42. aë 44. sekundou je vys°l†n den v tòdnu (3 bity, 0=nedàle), mezi 45.
; aë 49. sekundou je vys°l†n màs°c a mezi 50. aë 57. sekundou je vys°l†n
; rok (4 + 4 bity, pouze 2 posledn° á°slice bez stolet°). V 58. sekundà
; je vys°l†n paritn° bit pro datum. Zaá†tek minuty se synchronizuje
; vyhodnocen°m minutovÇ znaáky, kter† je vytvo©ena chybàj°c° sekundovou
; znaákou v 59. sekundà. Vys°laá DCF77 je v chodu nep©etrëità kromà
; kaëdÇho druhÇho £terò v màs°ci mezi 5. a 9. hodinou (prob°h† technick†
; £drëba).
; -----------------------------------------------------------------------------
; Port COM: vòstup DTR (pin 20) = +12V   (+ nap†jen° DCF)
;           vòstup RTS (pin  4) = -12V   (- nap†jen° DCF)
;           vstup  CTS (pin  5) = impuls -12V -> +12V
;           zem    GND (pin  7) = 0V     (zem DCF)
; -----------------------------------------------------------------------------

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

HI       EQU       256

KORIG    EQU       5ch - 103h               ; korekce pro posun adres

KLICFN   EQU       2bh*HI + "?"             ; kl°á funkce a dotazu
KLIC1    EQU       'DC'                     ; identifikaán° kl°á 1 (BX)
KLIC2    EQU       'F7'                     ; identifikaán° kl°á 2 (CX)
KLIC3    EQU       '7'                      ; identifikaán° kl°á 3 (DH)
                                            ; DL=posledn° á°slice po©adovÇho
                                            ;    á°sla licenán°ho á°sla
KLICOK   EQU       'OK'                     ; odpovàdn° kl°á (AX)


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

RezBeg   label     byte                     ; zaá†tek rezidentn° á†sti

Ident    db        'F'                      ; identifikace v pamàti
                                           ;* pouë°v† se tÇë 1.znak z lic.á°sla!
Licence  db        '7000013752'             ; licenán° á°slo "XXXXX-XXXXX"
                                            ;   0: identifikace DCF77 = "7"
                                            ;   1 aë 4: po©adovÇ á°slo 1 aë 9999
                                            ;           (0=neinicializov†no)
                                            ;   5: verze programu
                                            ;   6: rozli®en° "0"/"1" (=3)
                                            ;   7: poáet zav†dàc°ch bitñ - 13 (=7)
                                            ;   8: korekce áasu v 1/18 sek. (=5)
                                            ;   9: doplnàk kontroln°ho souátu
                                            ;      p©ede®lòch á°slic na 5 (MOD 10)
                                            ; - posledn° á°slice po©adovÇho á°sla
                                            ;  se pouë°v† k identifikaci v pamàti
                                            ;  (s v°ce á°sly mñëe bòt v°ce driverñ)
                                            ; - souáet v®ech á°slic (=á°slo 5)
                                            ;   p©edstavuje poáet bitñ na màs°c

Old08    dd        342343242                ; uschovan† adresa INT 08h
Old21    dd        453453443                ; uschovan† adresa INT 21h
Old28    dd        45454                    ; pñvodn° adresa obsluhy INT 28h
Aktiv21  dd        53454343                 ; adresa p©°znaku aktivity DOS (-1=nen°)
ErrDOS   dd        154353454                ; adresa p©°znaku obsluhy chyby DOS

Port     db        -1                       ; á°slo portu 0 aë 3 (-1=vypnuto)
OutPort  dw        23423                    ; adresa vòstupn°ho portu

Param    db        bit4                     ; parametry
                                            ;   bit 0: 1=je sign†l
                                            ;   bit 1: 1=bylo 1. naáten° áasu
                                            ;   bit 2: 1=byla korekce áasu
                                            ;   bit 3: 1=je impuls
                                            ;   bit 4: 1=áek† se na min. znaáku
                                            ;   bit 5: 1=poëadavek nastaven° DOS
                                            ;   bit 6: 1=áek† se na START bit
                                            ;   bit 7: 1=áek† se na paritn° bit

MinutaL  db        0                        ; minuta posledn° korekce áasu
HodinaL  db        0                        ; hodina posledn° korekce áasu
CitSek   db        0                        ; á°taá ubàhlÇ sekundy 0 aë 59

LoadBit  db        20                       ; á°taá startovac°ch bitñ
Ukaz     dw        offset Zprava+KORIG      ; ukazatel zpr†vy
UkazBit  db        7                        ; poáet bitñ k naáten°

Parita   db        0                        ; st©adaá parity

Korekce  dw        0                        ; á°taá korekce 55 ms

Setina   db        0                        ; setina sekundy
Sekunda  db        0                        ; sekunda

Zprava   label     byte                     ; zpr†va (data BCD/bitñ/min/max)
Minuta   db        80h,7+bit7,0,59          ; minuta (+ parita)
Hodina   db        80h,6+bit7,0,23          ; hodina (+ parita)
Den      db        80h,6,1,31               ; den
Tyden    db        80h,3,1,7                ; den v tòdnu (1 aë 7 = PO aë NE)
Mesic    db        80h,4,1,12               ; màs°c (poáet bitñ neplatnò !)
;Mesic    db        80h,5,1,12               ; màs°c
Rok      db        80h,8+bit7,0,99          ; rok bez stolet° (+ parita)

Zprava0  label     byte                     ; posledn° poloëka

Uschova  db        6*4 dup(2ah)             ; £schova zpr†vy

CitacImp dw        0                        ; á°taá dÇlky impulsu
CitacMez dw        0                        ; á°taá dÇlky mezery

CitNext  dw        1                        ; á°taá do p©°®t°ho áten° (65543-2731)
                                            ; (1 hodina - p©edbàh 60+60+30 sekund)

MinNext  dw        62812                    ; interval p©°®t° aktualizace - 2731

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ á°t†n° korekce pro nastaven° áasu

         inc       word ptr cs:[Korekce+KORIG] ; á°t†n° korekce p©i p©°jmu

; ------ á°t†n° p©°®t°ho áten°

         dec       word ptr cs:[CitNext+KORIG] ; á°t†n° doby do p©°®t°ho áten°
         jnz       Int080                   ; doby je®tà nen° dosaëeno
         inc       word ptr cs:[CitNext+KORIG] ; n†vrat á°taáe

; ------ test, zda je obsluha zapnuta

         cmp       byte ptr cs:[Port+KORIG],-1 ; je funkce vypnuta ?
         je        Int080                   ; funkce je vypnuta
         test      byte ptr cs:[Param+KORIG],bit5 ; poëadavek DOS ?
         jz        Int081                   ; funkce nen° vypnuta
Int080:  jmp       dword ptr cs:[Old08+KORIG] ; pñvodn° obsluha INT 08h

; ------ pñvodn° obsluha INT 08h

Int081:  pushf
         call      dword ptr cs:[Old08+KORIG] ; pñvodn° obsluha INT 08h

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         push      cs
         pop       ds                       ; DS <- datovò segment
         push      cs
         pop       es                       ; ES <- datovò segment

; ------ vysl†n° sign†lu na port

         mov       dx,ds:[OutPort+KORIG]    ; vòstupn° port
         mov       al,bit0+bit3
         out       dx,al                    ; nastaven° sign†lñ

; ------ naáten° stavu portu

         inc       dx
         inc       dx                       ; vstupn° port
         in        al,dx                    ; naáten° stavu portu
         test      al,bit4                  ; je impuls ?
         jz        Int082                   ; nen° impuls

; ------ je impuls (p©°p. konec mezery)

         test      byte ptr ds:[Param+KORIG],bit3 ; je jië impuls ?
         jz        Int0812                  ; nebyl impuls
Int0810A:inc       word ptr ds:[CitacImp+KORIG] ; á°t†n° dÇlky impulsu
         cmp       word ptr ds:[CitacImp+KORIG],9 ; asi tak maxim†ln° impuls
         jb        Int0810
         dec       word ptr ds:[CitacImp+KORIG] ; omezen° dÇlky impulsu
         and       byte ptr ds:[Param+KORIG],not bit0 ; p©°znak, ëe nen° sign†l
Int0810: jmp       Int086

Int0812: or        byte ptr ds:[Param+KORIG],bit0 ; p©°znak, ëe je sign†l
         mov       ax,ds:[CitacMez+KORIG]   ; á°taá mezery
         cmp       ax,11                    ; minim†ln° dÇlka mezery
         jb        Int0822A                 ; p©°li® kr†tk† mezera
         mov       word ptr ds:[CitacImp+KORIG],0 ; nulov†n° á°taáe impulsu
         or        byte ptr ds:[Param+KORIG],bit3 ; p©°znak impulsu

; ------ p©i®la minutov† znaáka

         cmp       ax,30                    ; asi tak minutov† znaáka
         jb        Int0810                  ; nen° minutov† znaáka
         cmp       ax,39                    ; asi tak maximum
         ja        Int08121                 ; p©°li® dlouh† mezera - znovu
         and       byte ptr ds:[Param+KORIG],not bit4 ; konec áek†n° na znaáku
         jmp       Int088             ; zah†jen° p©°jmu

Int08121:and       byte ptr ds:[Param+KORIG],not bit0 ; p©°znak, ëe nen° sign†l
         jmp       Int0872                  ; mal† mezera - chyba

; ------ je mezera (p©°p. konec impulsu)

Int082:  test      byte ptr ds:[Param+KORIG],bit3 ; je jië mezera ?
         jnz       Int0822                  ; nebyla mezera
Int0822A:inc       word ptr ds:[CitacMez+KORIG] ; á°t†n° dÇlky mezery
         cmp       word ptr ds:[CitacMez+KORIG],50 ; asi tak maxim†ln° mezera
         jb        Int0810
         dec       word ptr ds:[CitacMez+KORIG] ; omezen° dÇlky mezery
         and       byte ptr ds:[Param+KORIG],not bit0 ; p©°znak, ëe nen° sign†l
         jmp       short Int0810

Int0822: or        byte ptr ds:[Param+KORIG],bit0 ; p©°znak, ëe je sign†l
         mov       ax,ds:[CitacImp+KORIG]   ; á°taá impulsu
         or        ax,ax                    ; minim†ln° dÇlka impulsu
         jz        Int0810A                 ; impuls p©°li® kr†tkò
         mov       word ptr ds:[CitacMez+KORIG],0 ; nulov†n° á°taáe mezery
         and       byte ptr ds:[Param+KORIG],not bit3 ; p©°znak mezery

; ------ p©°li® dlouhò impuls je chyba

         cmp       ax,5                     ; asi tak maximum
         jae       Int08121                 ; p©°li® dlouhò impuls - chyba

; ------ rozli®en° logickÇ hodnoty impulsu

         add       al,"0"
         cmp       al,ds:[Licence+KORIG+6]  ; (=3) je "1" ?
         mov       al,0
         jb        Int0823
         inc       ax
Int0823: inc       byte ptr ds:[CitSek+KORIG] ; á°taá ubàhlÇ sekundy

; ------ á°t†n° zav†dàc°ch bitñ

         cmp       byte ptr ds:[LoadBit+KORIG],0 ; jsou zav†dàc° bity ?
         je        Int0824                  ; nejsou zav†dàc° bity
         or        byte ptr ds:[Param+KORIG],bit6 ; áek† se na START bit
         dec       byte ptr ds:[LoadBit+KORIG] ; á°t†n° zav†dàc°ch bitñ
         cmp       byte ptr ds:[LoadBit+KORIG],6 ; tolik bitñ se neporovn†v†
         jb        Int08232                 ; je jië m†lo bitñ
         cmp       al,0                     ; je "0" ?
         jne       Int08250                 ; chyba
Int08232:jmp       Int086

; ------ START bit

Int0824: test      byte ptr ds:[Param+KORIG],bit6 ; áek† se na START bit ?
         jz        Int0825                  ; neáek† se na START bit
         and       byte ptr ds:[Param+KORIG],not bit6 ; zru®en° p©°znaku
         cmp       al,1                     ; je START bit ?
         jne       Int08250                 ; chyba p©°jmu
         jmp       Int086                   ; je START bit OK

Int08244:jmp       Int08259                 ; neáek† se na paritn° bit

; ------ naáten° paritn°ho bitu

Int0825: mov       bx,ds:[Ukaz+KORIG]

         xor       byte ptr ds:[Parita+KORIG],al ; á°t†n° bitu parity
         test      byte ptr ds:[Param+KORIG],bit7 ; áek† se na paritn° bit ?
         jz        Int08244                 ; neáek† se na paritn° bit

         and       byte ptr ds:[Param+KORIG],not bit7 ; zru®en° p©°znaku
         cmp       byte ptr ds:[Parita+KORIG],0 ; je parita OK ?
         je        Int08251
Int08250:jmp       Int087                  ; chyba parity

; ------ test, zda je jië konec

Int08251:cmp       bx,offset Zprava0+KORIG  ; je jië konec ?
         jae       Int08252
         jmp       Int086                   ; nen° je®tà konec

; ------ porovn†n°, je-li ovà©ovac° áten°

Int08252:test      byte ptr ds:[Param+KORIG],bit1 ; je to prvn° áten° ?
         jz        Int08257                 ; je to prvn° áten°

         mov       si,offset Zprava+KORIG   ; naáten† zpr†va
         mov       di,offset Uschova+KORIG  ; buffer £schovy
         mov       cx,offset(Zprava0-Zprava) ; dÇlka zpr†vy
         cld
         repe      cmpsb                    ; porovn†n° zpr†vy
         jne       Int08257                 ; porovn†n° nesouhlas° - znovu uvà©it

; ------ je ovà©en° OK - nastaven° áasu

         mov       byte ptr ds:[Sekunda+KORIG],0
         mov       byte ptr ds:[Setina+KORIG],0

         mov       ah,0
         mov       al,ds:[Licence+8+KORIG]  ; dodateán† korekce "5"
         add       ax,-36+3 - "5"           ; tolik impulsñ po zaá†tek minuty
         add       ax,ds:[CitacImp+KORIG]   ; odeáten° uplynulÇho áasu
         mov       word ptr ds:[Korekce+KORIG],ax ; doba do nastaven° áasu
         or        byte ptr ds:[Param+KORIG],bit5 ; poëadavek nastaven° DOS
         jmp       Int087                   ; p©°jem dal®° zpr†vy

; ------ p©°prava pro opakov†n° p©°jmu

Int08257:or        byte ptr ds:[Param+KORIG],bit1 ; bude ovà©ovac° áten°
         inc       byte ptr ds:[Minuta+KORIG] ; p©ednastaven° minuty + 1
         cmp       byte ptr ds:[Minuta+KORIG],60
         jb        Int08258
         mov       byte ptr ds:[Minuta+KORIG],0
         inc       byte ptr ds:[Hodina+KORIG]
Int08258:mov       si,offset Zprava+KORIG   ; naáten† zpr†va
         mov       di,offset Uschova+KORIG  ; buffer £schovy
         mov       cx,offset(Zprava0-Zprava) ; dÇlka zpr†vy
         cld
         rep       movsb                    ; £schova zpr†vy
         jmp       Int0872                  ; p©°jem dal®° zpr†vy

; ------ naáten° bitu do á°sla

Int08259:shr       al,1                     ; bit do CF
         rcr       byte ptr ds:[bx],1       ; rotace do á°sla
         dec       byte ptr ds:[UkazBit+KORIG] ; á°taá bitñ
         jnz       Int086                   ; bude dal®° bit

; ------ rotace á°sla na pozici

         mov       al,ds:[bx+1]             ; poëadovanò poáet bitñ
         and       al,0fh                   ; poëadovanò poáet bitñ
         cmp       al,7                     ; je velkò poáet bitñ (=rok) ?
         ja        Int08262                 ; je velkò poáet bitñ (=rok)
Int0826: shr       byte ptr ds:[bx],1
         jnc       Int0826

; ------ konverze á°sla na bin†rn° tvar

Int08262:mov       al,ds:[bx]               ; naáten† hodnota
         mov       ah,al
         mov       cl,4
         shr       ah,cl
         and       ax,0f0fh
         aad
         mov       ds:[bx],al

; ------ kontrola p©eteáen° á°sla

         cmp       al,ds:[bx+2]             ; minim†ln° hodnota
         jb        Int087                   ; podteáen°
         cmp       al,ds:[bx+3]             ; maxim†ln° hodnota
         ja        Int087                   ; p©eteáen°

; ------ test, zda bude paritn° bit

         test      byte ptr ds:[bx+1],bit7  ; bude paritn° bit ?
         jz        Int0827                  ; nebude paritn° bit
         or        byte ptr ds:[Param+KORIG],bit7 ; bude paritn° bit

; ------ zvò®en° ukazatele dat

Int0827: add       bx,4
         mov       ds:[Ukaz+KORIG],bx       ; novò ukazatel dat

; ------ test, zda je jië konec

         cmp       bx,offset Zprava0+KORIG  ; je jië konec ?
         jae       Int086                   ; je jië konec
         mov       byte ptr ds:[bx],80h     ; p©°prava st©adaáe dat
         mov       al,ds:[bx+1]             ; poáet bitñ
         and       al,not bit7              ; nulov†n° p©°znaku parity
         mov       ds:[UkazBit+KORIG],al    ; ukazatel bitñ

; ------ nulov†n° p©i áek†n° na minutovou znaáku

Int086:  test      byte ptr ds:[Param+KORIG],bit4 ; áek† se na znaáku ?
         jz        Int089                   ; neáek† se na znaáku
         jmp       short Int088             ; áek† se

; ------ CHYBA - inicializace naá°t†n° dat na zaá†tek

Int087:  and       byte ptr ds:[Param+KORIG],not bit1 ; bude 1. áten°
Int0872: or        byte ptr ds:[Param+KORIG],bit4 ; áek† se na minutovou znaáku
Int088:  mov       word ptr ds:[Ukaz+KORIG],offset Zprava+KORIG ; inicializace ukazatele
         mov       byte ptr ds:[UkazBit+KORIG],7 ; á°taá bitñ k naáten° - minuta
         mov       byte ptr ds:[CitSek+KORIG],0 ; á°taá ubàhlÇ sekundy
         mov       al,ds:[Licence+7+KORIG]  ; poáet zav†dàc°ch bitñ - 13 ("7")
         add       al,20-"7"
         mov       ds:[LoadBit+KORIG],al    ; á°taá zav†dàc°ch bitñ
         mov       byte ptr ds:[Parita+KORIG],0  ; st©adaá parity
         test      byte ptr ds:[Param+KORIG],bit5 ; je nastaven° DOS ?
         jnz       Int089                   ; je nastaven° DOS
         mov       byte ptr ds:[Minuta+KORIG],80h ; minuta neplatn†

; ------ n†vrat registrñ

Int089:  pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 21h
; -----------------------------------------------------------------------------

Int21    PROC      FAR

; ------ test instalace

         pushf
         cmp       ax,KLICFN                ; funkán° kl°á
         jne       Int212
         cmp       bx,KLIC1                 ; identifikaán° kl°á 1
         jne       Int212
         cmp       cx,KLIC2                 ; identifikaán° kl°á 2
         jne       Int212
         cmp       dh,KLIC3                 ; identifikaán° kl°á 3
         jne       Int212
         cmp       dl,cs:[Licence+KORIG+4]  ; posledn° á°slice licence
         jne       Int212
         mov       ax,KLICOK                ; odpovàdn° kl°á
         push      cs
         pop       es                       ; ES <- segment programu
         popf
         iret

Int212:  popf

; ------ obsluha INT 21h

         call      IntDOS                   ; obsluha p©°stupu k DOS
         jmp       dword ptr cs:[Old21+KORIG] ; pokraáov†n° pñvodn° obsluhou

Int21    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

         call      IntDOS                   ; obsluha p©°stupu k DOS
         jmp       dword ptr cs:[Old28+KORIG] ; pokraáov†n° pñvodn° obsluhou

Int28    ENDP

; -----------------------------------------------------------------------------
;        obsluha p©°stupu k DOS
; -----------------------------------------------------------------------------

IntDOS   PROC      NEAR

; ------ test, zda m† bòt obsluha áasu DOS

         pushf
         cmp       word ptr cs:[Korekce+KORIG],8000h
         jae       IntDOS0                  ; nen° je®tà dosaëeno áasu
         test      byte ptr cs:[Param+KORIG],bit5 ; poëadavek obsluhy DOS ?
         jnz       IntDOS1                  ; je poëadavek obsluhy DOS
IntDOS0: jmp       IntDOS9                  ; nen° poëadov†na obsluha DOS

; ------ test p©°znaku aktivity DOS

IntDOS1: push      ds
         push      bx
         lds       bx,cs:[Aktiv21+KORIG]    ; adresa p©°znaku aktivity DOS
         cmp       bx,-1                    ; je adresa definov†na ?
         je        IntDOS2                  ; nen° definov†na
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn° ?
IntDOS2: pop       bx
         pop       ds
         jne       IntDOS0                  ; DOS je aktivn°

; ------ test p©°znaku obsluhy chyby DOS

         push      ds
         push      bx
         lds       bx,cs:[ErrDOS+KORIG]     ; adresa p©°znaku obsluhy chyby DOS
         cmp       bx,-1                    ; je adresa definov†na ?
         je        IntDOS3                  ; nen° definov†na
         cmp       byte ptr ds:[bx],0       ; je chyba DOS aktivn° ?
IntDOS3: pop       bx
         pop       ds
         jne       IntDOS0                  ; obsluha chyby DOS je aktivn°

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds                       ; DS <- CS

; ------ korekce áasu

         mov       ax,ds:[Korekce+KORIG]    ; korekce áasu
         cmp       ax,30*18                 ; maxim†ln° prodleva 30 sekund
         jbe       IntDOS4                  ; je to OK
         jmp       IntDOS8                  ; to je jië p©°li® dlouho

IntDOS4: mov       cx,100
         mul       cx
         mov       cl,18
         div       cx                       ; p©epoáet na 1/100 sekund
                                          ;* zde je AX maxim†lnà 3000
         add       al,ds:[Setina+KORIG]     ; p©iáten° 1/100 sekund
         adc       ah,0
         mov       cl,100
         div       cl                       ; p©epoáet na sekundy a setiny
         mov       ds:[Setina+KORIG],ah     ; setina sekundy
         add       ds:[Sekunda+KORIG],al    ; korekce sekund
         cmp       byte ptr ds:[Sekunda+KORIG],60
         jb        IntDOS5
         sub       byte ptr ds:[Sekunda+KORIG],60
         inc       byte ptr ds:[Minuta+KORIG] ; korekce minut (p©eteáen° ignoruje)

; ------ nastaven° áasu DOS

IntDOS5: mov       ch,ds:[Hodina+KORIG]     ; hodina
         mov       cl,ds:[Minuta+KORIG]     ; minuta
         mov       dh,ds:[Sekunda+KORIG]    ; sekunda
         mov       dl,ds:[Setina+KORIG]     ; setina sekundy
         mov       ah,2dh
         call      Int21P                   ; nastaven° systÇmovÇho áasu
         cmp       al,0                     ; byl áas OK ?
         jne       IntDOS8                  ; nebyl spr†vnò áas

; ------ nastaven° data DOS

IntDOS6: mov       cl,ds:[Rok+KORIG]        ; rok bez stolet°
         mov       ch,0

         add       cx,1900
         cmp       cx,1980
         jae       IntDOS7
         add       cx,100

IntDOS7: mov       dh,ds:[Mesic+KORIG]      ; màs°c
         mov       dl,ds:[Den+KORIG]        ; den
         mov       ah,2bh
         call      Int21P                   ; nastaven° systÇmovÇho data
         cmp       al,0                     ; bylo datum OK ?
         jne       IntDOS8                  ; nebylo spr†vnÇ datum

         mov       ah,ds:[Hodina+KORIG]     ; hodina
         mov       al,ds:[Minuta+KORIG]     ; minuta
         mov       ds:[HodinaL+KORIG],ah    ; naposledy proveden† korekce
         mov       ds:[MinutaL+KORIG],al    ; naposledy proveden† korekce
         or        byte ptr ds:[Param+KORIG],bit2 ; p©°znak proveden° korekce
         mov       ax,ds:[MinNext+KORIG]    ; interval (62812)
         mov       word ptr ds:[CitNext+KORIG],ax ; á°taá do p©°®t° korekce

IntDOS8: and       byte ptr ds:[Param+KORIG],not bit5 ; zru®en° poëadavku
         mov       byte ptr ds:[Minuta+KORIG],80h ; minuta neplatn†

; ------ n†vrat registrñ

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
IntDOS9: popf
         ret

IntDOS   ENDP

; -----------------------------------------------------------------------------
;        vol†n° funkce DOS (DS=CS !)
; -----------------------------------------------------------------------------

Int21P   PROC      NEAR

         pushf
         call      dword ptr ds:[Old21+KORIG]
         ret

Int21P   ENDP

RezEnd   label     byte                     ; konec rezidentn°ho modulu

; *****************************************************************************
;
;                          Start a instalace programu
;
; *****************************************************************************
;˛
; ------ naáten° adres obsluh p©eru®en°

Instal:  call      GetInt                   ; naáten° adres p©eru®en°

; ------ £schova p©°kazovÇho ©†dku do bufferu

         push      ds
         pop       es                       ; ES <- DS
         mov       si,81h                   ; p©°kazovò ©†dek
         mov       cl,ds:[si-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       ch,0
         and       cl,7fh                   ; pojistka proti p©eteáen°
         mov       di,offset ComLine        ; buffer p©°kazovÇho ©†dku
         cld
         rep       movsb                    ; £schova p©°kazovÇho ©†dku
         mov       al,0                     ; koncov† nula
         stosb                              ; oznaáen° konce p©°kazovÇho ©†dku

; ------ posun programu n°ëe (ES=DS, CLD !)

         mov       si,offset RezBeg         ; zaá†tek rezidentn°ho modulu
         mov       di,offset RezBeg + KORIG ; novò zaá†tek rezidentn°ho modulu
         mov       cx,offset(RezEnd-RezBeg) ; dÇlka rezidentn°ho modulu
         rep       movsb                    ; p©esun programu n°ëe

; ------ kontroln° souáet licenán°ho á°sla -> poáet bitñ na màs°c

         mov       si,offset Licence+KORIG
         mov       cl,10
         push      cx
         mov       ah,0
Instal02:add       al,ds:[si]
         inc       si
         adc       ah,0
         loop      Instal02                 ; k souátu je p©iáteno 480 (=10*"0")
         pop       cx
         div       cl
         mov       ds:[Mesic+KORIG+1],ah    ; poëadovanò poáet bitñ = 5

; ------ test, je-li program rezidentn° (DS=ES !)

         mov       ax,KLICFN                ; kl°á funkce a dotazu
         mov       bx,KLIC1                 ; identifikaán° kl°á 1
         mov       cx,KLIC2                 ; identifikaán° kl°á 2
         mov       dh,KLIC3                 ; identifikaán° kl°á 3
         mov       dl,ds:[Licence+KORIG+4]  ; posledn° á°slice licence
         int       21h                      ; test instalace
         cmp       ax,KLICOK                ; odpovàdn° kl°á
         jne       Instal1                  ; program nen° rezidentn°
         cmp       word ptr es:[Ident+KORIG],"7F" ; souhlas° identifikace ?
         je        Instal2                  ; program je rezidentn° OK

Instal1: push      cs
         pop       es                       ; ES <- segment tohoto programu
         and       byte ptr ds:[InstPar],not bit0 ; nen° rezidentn°

; ------ naáten° znaku z p©°kazovÇho ©†dku (ES=rezidentn° segment)

Instal2: mov       si,offset ComLine        ; buffer p©°kazovÇho ©†dku
Instal22:call      RozbChr                  ; naáten° znaku
         jc        Instal5                  ; nen° dal®° znak

; ------ odinstalov†n° programu z pamàti

         cmp       al,"!"                   ; odinstalov†n° ?
         jne       Instal3                  ; nen° odinstalov†n°
         jmp       OdInst                   ; odinstalov†n° programu

; ------ okamëit† aktualizace áasu

Instal3: cmp       al,"A"
         jne       Instal32                 ; nen° aktualizace
         mov       word ptr es:[CitNext+KORIG],1 ; zru®en° áek†n°
;         or        byte ptr ds:[InstPar],bit3 ; okamëit† aktualizace
         jmp       short Instal22

; ------ opakovanÇ zobrazov†n°

Instal32:cmp       al,"D"
         jne       Instal33
         or        byte ptr ds:[InstPar],bit2 ; opakovanÇ zobrazov†n°
         jmp       short Instal22

; ------ interval pro opakov†n°

Instal33:cmp       al,"I"
         jne       Instal36
         call      RozbNum

         mov       dx,1092
         mul       dx                       ; p©epoáet na impulsy
         sub       ax,2731                  ; bez 150 sekund
         ja        Instal34
         mov       ax,1
Instal34:mov       es:[MinNext+KORIG],ax    ; p©°®t° aktualizace
         jmp       short Instal22

; ------ vypnut° funkce

Instal36:cmp       al,"0"
         jne       Instal4
         or        byte ptr ds:[InstPar],bit1 ; zad†no á°slo portu
         mov       byte ptr es:[Port+KORIG],-1 ; vypnut° funkce
         jmp       short Instal22

; ------ zad†n° á°sla portu

Instal4: sub       al,"1"
         jb        Chyba00
         cmp       al,3
         ja        Chyba00
         or        byte ptr ds:[InstPar],bit1 ; zad†no á°slo portu
         call      InstPort                 ; instalace portu AL
         jc        ChybaX                   ; chyba - port neexistuje
         jmp       short Instal22

Chyba00: jmp       Chyba0

ChybaX:  jmp       Chyba

; ------ nainstalov†n° programu

Instal5: test      byte ptr ds:[InstPar],bit0 ; je jië nainstalov†n ?
         jnz       Instal6                  ; je jië nainstalov†n
         test      byte ptr ds:[InstPar],bit1 ; m† bòt instalace ?
         jz        Chyba0                   ; nezad†na instalace - chyba
         jmp       Inst                     ; instalace programu

; ------ pouze zobrazen° stavu

Instal6: cmp       byte ptr es:[Port+KORIG],-1 ; funkce vypnuta ?
         je        Instal62                 ; funkce vypnuta

         test      byte ptr ds:[InstPar],bit2 ; opakovanÇ zobrazov†n° ?
         jnz       Instal7                  ; je opakovanÇ zobrazov†n°
Instal62:call      DispUv                   ; zobrazen° £vodn°ho textu
         call      DispStav                 ; zobrazen° stavu
         int       20h

; ------ opakovanÇ zobrazov†n° stavu

Instal7: push      ds
         push      es

         mov       ah,0fh
         int       10h
         cmp       al,7
         je        Instal72
         mov       al,3
Instal72:mov       ah,0
         int       10h                      ; vymaz†n° obrazovky

         pop       es
         pop       ds

Instal74:
;test      byte ptr ds:[InstPar],bit3 ; okamzita aktualizace ?
;         jz        Instal75                 ; neni
;         mov       word ptr es:[CitNext+KORIG],1 ; zru®en° áek†n°

Instal75:mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu -> DX

         push      dx                       ; £schova sekund + setin

         push      ds
         push      es

         xor       dx,dx
         mov       ah,2
         mov       bh,0
         int       10h                      ; kurzor na poá†tek obrazovky

         pop       es
         pop       ds

         call      DispStav

         pop       si                       ; SI <- uschovanÇ sekundy + setiny

Instal76:mov       ah,2ch
         int       21h
         cmp       dx,si
         jne       Instal78
         mov       ah,1
         int       16h
         jz        Instal76

Instal78:mov       ah,1
         int       16h
         jz        Instal74                 ; áek†n° na stisk kl†vesy

         mov       ah,0
         int       16h
         int       20h

; ------ hl†®en° chyby

Chyba0:  call      DispUv                   ; zobrazen° £vodn°ho textu
         mov       dx,offset HelpTxt        ; chybovÇ hl†®en°
Chyba:   call      DispTxt                  ; zobrazen° chyby
         int       20h

; -----------------------------------------------------------------------------
;        zobrazen° £vodn°ho texty (mus° uchovat ES)
; -----------------------------------------------------------------------------

DispUv   PROC      NEAR

         push      es
         push      ds
         pop       es
         mov       si,offset Licence+KORIG  ; licenán° á°slo
         mov       di,offset UvTxt1
         cld
         mov       cx,5
         rep       movsb                    ; p©enos á°sla - 1. á†st
         inc       di
         mov       cl,5
         rep       movsb                    ; p©enos á°sla - 2. á†st

         mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen° £vodn°ho textu
         pop       es
         ret

DispUv   ENDP

; -----------------------------------------------------------------------------
;                            instalace programu
; -----------------------------------------------------------------------------

; ------ hl†®en° o nainstalov†n°

Inst:    call      DispUv                   ; zobrazen° £vodn°ho textu
         mov       dx,offset InstTxt
         call      DispTxt                  ; hl†®en° o nainstalov†n°

; ------ instalace obsluh INT 08h, INT 21h a INT 28h

         mov       ax,2508h
         mov       dx,offset INT08+KORIG
         int       21h                      ; instalace INT 08h

         mov       ax,2521h
         mov       dx,offset INT21+KORIG
         int       21h                      ; instalace INT 21h

         mov       ax,2528h
         mov       dx,offset INT28+KORIG
         int       21h                      ; instalace INT 28h

; ------ uvolnàn° segmentu prost©ed°

         mov       es,ds:[2ch]              ; segment prost©ed°
         mov       ah,49h
         int       21h                      ; uvolnàn° segmentu prost©ed°

; ------ instalace programu

         mov       dx,offset RezEnd+KORIG   ; konec rezidentn°ho modulu
         int       27h                      ; instalace do pamàti

; -----------------------------------------------------------------------------
;        naáten° adres p©eru®en°
; -----------------------------------------------------------------------------

GetInt   PROC      NEAR

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; £schova INT 08h
         mov       word ptr ds:[Old08+2],es

; ------ £schova adresy INT 21h

         mov       ax,3521h
         int       21h                      ; poskytnut° adresy INT 21h
         mov       word ptr ds:[Old21],bx   ; £schova INT 21h
         mov       word ptr ds:[Old21+2],es

; ------ £schova adresy INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut° adresy INT 28h
         mov       word ptr ds:[Old28],bx
         mov       word ptr ds:[Old28+2],es

; ------ instalace p©°znaku aktivity DOS

         mov       bx,-1                    ; BX <- 0ffffh nepovolen† hodnota
         mov       es,bx                    ; ES <- 0ffffh nepovolen† hodnota
         mov       ah,34h
         int       21h                      ; poskytnut° p©°znaku aktivity DOS
         mov       ax,es
         inc       ax                       ; m† ES povolenou hodnotu ?
         jnz       GetInt2                  ; ES je definov†no OK
         mov       bx,es                    ; ES i BX maj° hodnotu 0ffffh
GetInt2: mov       word ptr ds:[Aktiv21],bx ; adresa p©°znaku aktivity DOS
         mov       word ptr ds:[Aktiv21+2],es ; segment p©°znaku aktivity DOS

; ------ instalace p©°znaku obsluhy chyby DOS

         push      ds
         mov       si,-1                    ; SI <- 0ffffh nepovolen† hodnota
         mov       ds,si                    ; DS <- 0ffffh nepovolen† hodnota
         mov       ax,5d06h
         int       21h                      ; poskytnut° p©°znaku chyby DOS
         jnc       GetInt4                  ; operace OK
         mov       si,-1                    ; adresa je neplatn†
GetInt4: mov       ax,ds                    ; segment adresy
         inc       ax                       ; m† DS povolenou hodnotu ?
         jnz       GetInt6                  ; DS je definov†no OK
         mov       si,ds                    ; DS i SI maj° hodnotu 0ffffh
GetInt6: dec       ax                       ; n†vrat DS
         pop       ds
         mov       word ptr ds:[ErrDOS],si  ; adresa p©°znaku aktivity DOS
         mov       word ptr ds:[ErrDOS+2],ax ; segment p©°znaku aktivity DOS
         ret

GetInt   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° stavu programu (ES=rezidentn° segment)
; -----------------------------------------------------------------------------

DispStav PROC      NEAR

; ------ program je neaktivn°

         cmp       byte ptr es:[Port+KORIG],-1 ; funkce vypnuta ?
         jne       DispStv0
         mov       dx,offset NeAktTxt       ; program neaktivn°
         call      DispTxt
         ret

; ------ p©°prava á°sla portu

DispStv0:mov       al,es:[Port+KORIG]       ; á°slo portu
         add       al,"1"
         mov       byte ptr ds:[LastTxt1],al ; á°slo portu

; ------ stav sign†lu

         mov       si,offset LastTx28       ; je áek†n°
         cmp       word ptr es:[CitNext+KORIG],1 ; prob°h† naá°t†n° ?
         ja        DispStv1                 ; neprob°h† naá°t†n°
         mov       si,offset LastTx24       ; je p©°jem
         test      byte ptr es:[Param+KORIG],bit0 ; je sign†l ?
         jnz       DispStv1                 ; je sign†l OK
         mov       si,offset LastTx26       ; nen° p©°jem
DispStv1:mov       di,offset LastTxt2
         push      es
         push      ds
         pop       es                       ; ES <- DS
         cld
         movsw
         movsw
         movsw
         movsw
         pop       es

         mov       byte ptr ds:[LastTx22]," " ; jen° impuls
         mov       dx,es:[OutPort+KORIG]    ; vòstupn° port
         inc       dx
         inc       dx                       ; vstupn° port
         in        al,dx                    ; naáten° stavu portu
         test      al,bit4                  ; je impuls ?
         jz        DispStv2                 ; nen° impuls
         mov       byte ptr ds:[LastTx22],"*" ; p©°znak sign†lu

; ------ zobrazen° ©†dku s á°slem portu COM

DispStv2:mov       dx,offset PrijCOM
         call      DispTxt                  ; zobrazen° textu

; ------ rozli®en° naá°t†n°/ovà©en°

         mov       si,offset LastTx54       ; text "naáten°"
         test      byte ptr es:[Param+KORIG],bit1 ; je to ovà©en° ?
         jz        DispSt22                 ; je to prvn° naá°t†n°
         mov       si,offset LastTx52       ; text "ovà©en°"

DispSt22:mov       di,offset LastTxt5+4     ; text "naáten°"
         mov       cx,7                     ; dÇlka textu
         push      es
         push      ds
         pop       es
         cld
         rep       movsb                    ; p©enos textu
         pop       es

; ------ procento naá°t†n°

         mov       al,es:[CitSek+KORIG]
         cmp       al,59
         jbe       DispStv3
         mov       al,59
DispStv3:mov       ah,100
         mul       ah
         mov       cl,60
         div       cl
         mov       di,offset LastTxt5
         call      DispStvB                 ; dek¢dov†n° procent

; ------ aktu†ln° ukazatele

         mov       si,offset Hodina+KORIG
         mov       di,offset LastTxt4
         call      DispStvA                 ; dek¢dov†n° hodiny
         mov       si,offset Minuta+KORIG
         call      DispStvA                 ; dek¢dov†n° minuty
         mov       si,offset Den+KORIG
         call      DispStvA                 ; dek¢dov†n° dne
         mov       si,offset Mesic+KORIG
         call      DispStvA                 ; dek¢dov†n° màs°ce

         inc       di
         inc       di                       ; zaá†tek roku ve stolet°
         push      si
         call      DispStvA                 ; dek¢dov†n° roku ve stolet°
         pop       si

         mov       word ptr ds:[di-5],"--"  ; rok nen° naáten

         cmp       si,es:[Ukaz+KORIG]       ; je jië rok naáten ?
         jae       DispStv4                 ; rok je®tà nen° naáten

         mov       word ptr ds:[di-5],"91"  ; bude stolet° 19xx
         cmp       byte ptr ds:[di-3],"8"   ; je rok 8x a v°ce ?
         jae       DispStv4                 ; je to stolet° 19xx
         mov       word ptr ds:[di-5],"02"  ; jinak je to stolet° 2000

; ------ test, zda se nastavuje áas

DispStv4:mov       dx,offset LastTx72
         test      byte ptr es:[Param+KORIG],bit5 ; je nastavov†n° áasu ?
         jnz       DispStv5                 ; je nastavov†n° áasu

; ------ test, zda prob°h† naá°t†n°

         mov       dx,offset LastTxt3       ; text - stav naá°t†n°
         cmp       word ptr es:[CitNext+KORIG],1 ; prob°h† naá°t†n° ?
         jbe       DispStv5                 ; prob°h† naá°t†n° OK

; ------ zobrazen° p©°®t° aktualizace áasu

         mov       ax,es:[CitNext+KORIG]    ; á°taá do aktualizace áasu
         xor       dx,dx                    ; DX <- 0
         mov       cx,18                    ; asi tak poáet impulsñ na sekundu
         div       cx                       ; vòpoáet poátu zbòvaj°c°ch sekund
         add       ax,150+15                ; oprava
;˛
         push      ax                       ; £schova poátu sekund
         mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         pop       ax
         add       al,dh                    ; p©iáten° sekund
         adc       ah,0
         mov       bl,60                    ; poáet sekund na minutu
         div       bl                       ; p©epoáet na sekundy a minuty
         add       al,cl                    ; p©iáten° minut
         mov       ah,0
         div       bl                       ; p©epoáet na hodiny a minuty
         add       al,ch                    ; p©iáten° hodiny
         cmp       al,23                    ; je p©eteáen° ?
         jbe       DispSt42                 ; nen° p©eteáen°
         sub       al,24                    ; oprava hodiny

DispSt42:mov       di,offset LastTxt7
         push      ax
         call      DispStvB                 ; dek¢dov†n° hodiny
         pop       ax
         mov       al,ah                    ; minuta
         call      DispStvB

         mov       dx,offset LastTxt6       ; text - p©°®t° aktualizace
DispStv5:call      DispTxt                  ; zobrazen° stavu naá°t†n°

; ------ áas posledn°ho p©°jmu

         test      byte ptr es:[Param+KORIG],bit2 ; byla korekce ?
         jz        DispStv6                 ; nebyla korekce

         mov       al,es:[HodinaL+KORIG]    ; hodina p©°jmu
         mov       di,offset LastTxt9
         call      DispStvB
         mov       al,es:[MinutaL+KORIG]    ; minuta p©°jmu
         call      DispStvB

; ------ aktu†ln° áas a datum

DispStv6:mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         mov       di,offset LastTxt0
         mov       al,ch                    ; hodina
         call      DispStvB
         mov       al,cl                    ; minuta
         call      DispStvB
         mov       al,dh                    ; sekunda
         call      DispStvB
         mov       al,dl                    ; setina
         call      DispStvB

         mov       ah,2ah
         int       21h

         push      ax

         mov       al,dl                    ; den
         call      DispStvB
         mov       al,dh                    ; màs°c
         call      DispStvB
         mov       al,100
         xchg      ax,cx
         div       cl

         push      ax
         call      DispStvB                 ; stolet°
         pop       ax

         dec       di
         mov       al,ah
         call      DispStvB                 ; rok

         mov       dx,offset LastTxt8
         call      DispTxt                  ; zobrazen° aktu†ln°ho áasu a data

         pop       ax

         mov       ah,10
         mul       ah
         add       ax,offset LastTxtD
         xchg      ax,dx
         call      DispTxt                  ; zobrazen° dne v tòdnu
         ret

DispStav ENDP

; ------ dek¢dov†n° á°sla es:[si] (resp. AL) do ds:[di]

DispStvA:cld
         mov       word ptr ds:[di],"--"
         cmp       si,es:[Ukaz+KORIG]       ; je to jië naátenò £daj ?
         jae       DispStvC                 ; nen° to je®tà naátenò £daj
         mov       al,es:[si]               ; poëadovanò bajt

DispStvB:aam                                ; korekce na 2 á°slice
         or        ax,"00"                  ; korekce na ASCII
         xchg      al,ah                    ; oprava po©ad° bajtñ
         mov       ds:[di],ax               ; uloëen° á°sla

DispStvC:add       di,3                     ; zvò®en° ukl†dac° adresy
         add       si,4                     ; zvò®en° átec° adresy
         ret

; -----------------------------------------------------------------------------
;        odinstalov†n° programu (ES=rezidentn° segment)
; -----------------------------------------------------------------------------

; ------ test, zda je program rezidentn°

OdInst:  mov       dx,offset NeniTxt        ; nen° nainstalov†n
         test      byte ptr ds:[InstPar],bit0 ; je program rezidentn° ?
         jz        OdInst6                  ; program nen° rezidentn°

; ------ test segmentñ INT 08h, INT 21h a INT 28h

         mov       dx,offset NelzeTxt       ; hl†®en° - nelze odinstalovat
         mov       ax,es                    ; AX <- rezidentn° segment
         cmp       ax,word ptr ds:[Old08+KORIG+2] ; souhlas° INT 08h ?
         jne       OdInst6                  ; nesouhlas°
         cmp       ax,word ptr ds:[Old21+KORIG+2] ; souhlas° INT 21h ?
         jne       OdInst6                  ; nesouhlas°
         cmp       ax,word ptr ds:[Old28+KORIG+2] ; souhlas° INT 28h ?
         jne       OdInst6                  ; nesouhlas°

; ------ n†vrat adresy INT 08h, INT 21h a INT 28h

         push      ds
         mov       ax,2508h
         lds       dx,es:[Old08+KORIG]      ; pñvodn° adresa INT 08h
         int       21h                      ; n†vrat adresy INT 08h
         mov       ax,2521h
         lds       dx,es:[Old21+KORIG]      ; pñvodn° adresa INT 21h
         int       21h                      ; n†vrat adresy INT 21h
         mov       ax,2528h
         lds       dx,es:[Old28+KORIG]      ; pñvodn° adresa INT 28h
         int       21h                      ; n†vrat adresy INT 28h
         pop       ds

; ------ zru®en° segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnàn° segmentu programu
         mov       dx,offset DInsTxt        ; hl†®en° o odinstalov†n°
OdInst6: jmp       Chyba

; -----------------------------------------------------------------------------
;        instalace portu AL (ES=rezidentn° segment)
; -----------------------------------------------------------------------------

InstPort PROC      NEAR

; ------ p©°prava textu pro hl†®en°

         add       ds:[NeniCOM1],al         ; p©°prava textu pro hl†®en° pro COM

; ------ adresa portu -> BX

         push      ds
         mov       bx,40h
         mov       ds,bx                    ; ES <- 40h
         mov       bl,al                    ; BX <- á°slo portu COM/LPT
         shl       bx,1
         mov       bx,ds:[bx]               ; adresa portu COM
         pop       ds

; ------ test, zda je port platnò

         or        bx,bx                    ; je port platnò ?
         jnz       InstPrt2                 ; port je platnò OK
         mov       dx,offset NeniCOM        ; text pro COM
         stc                                ; p©°znak chyby
         ret

; ------ instalace portu COM

InstPrt2:mov       es:[Port+KORIG],al       ; á°slo portu COM
         add       bx,4                     ; ©°dic° registr modemu
         mov       es:[OutPort+KORIG],bx    ; vòstupn° port
         clc                                ; p©°znak operace OK
         ret

InstPort ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla z p©°kazovÇho ©†dku -> AX
; -----------------------------------------------------------------------------

RozbNum  PROC      NEAR

         push      bx
         push      dx

         xor       bx,bx
RozbNum1:call      RozbChr                  ; naáten° dal®°ho znaku
         jc        RozbNum9                 ; nen° dal®° znak
         sub       al,"0"
         jb        RozbNum8
         cmp       al,9
         ja        RozbNum8

         push      ax
         mov       ax,10
         mul       bx
         pop       bx
         mov       bh,0
         add       bx,ax

         cmp       byte ptr ds:[si],"0"
         jb        RozbNum9
         jmp       short RozbNum1

RozbNum8:dec       si

RozbNum9:xchg      ax,bx
         pop       dx
         pop       bx
         ret

RozbNum  ENDP

; -----------------------------------------------------------------------------
;        naáten° znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

RozbChr1:cmp       byte ptr ds:[si],0       ; konec textu ?
         stc                                ; p©°znak, ëe nen° dal®° znak
         je        RozbChr3                 ; konec textu
         cld
         lodsb                              ; naáten° znaku
         cmp       al," "                   ; je mezera nebo tabul†tor ?
         jbe       RozbChr1                 ; mezera nebo tabul†tor se ignoruje
         cmp       al,"/"                   ; oddàlovaá parametrñ ?
         je        RozbChr1                 ; oddàlovaá parametrñ se ignoruje
         cmp       al,"-"                   ; oddàlovaá parametrñ ?
         je        RozbChr1                 ; oddàlovaá parametrñ se ignoruje

         cmp       al,"a"
         jb        RozbChr2
         cmp       al,"z"
         ja        RozbChr2
         sub       al,32
RozbChr2:clc                                ; p©°znak operace OK

RozbChr3:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h                      ; zobrazen° textu DS:DX
         pop       ax
         ret

DispTxt  ENDP

; *****************************************************************************
;
;                                   data
;
; *****************************************************************************
;˛
InstPar  db        bit0                     ; parametry
                                            ;   bit 0: 1=je rezident
                                            ;   bit 1: 1=zad†no á°slo portu
                                            ;            nebo vypnut° funkce
                                            ;   bit 2: 1=opakovanÇ zobrazen°
                                            ;    (bit 3: 1=okamzita aktualizace)

UvTxt    db        13,10
         db        '                     €ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€',13,10
         db        '                     € *                               * €∞∞',13,10
         db        '                     €     (c)  P H O B O S   s.r.o.     €∞∞',13,10
         db        '                     €    ÀÕÕª …ÕÕª ÀÕÕª    …ÕÕª …ÕÕª    €∞∞',13,10
         db        '                     €    ∫  ∫ ∫    ÃÕ   ÕÕ    Œ    Œ    €∞∞',13,10
         db        '                     €     ÕÕº »ÕÕº                      €∞∞',13,10
         db        '                     €             verze 1.0             €∞∞',13,10
         db        '                     €                                   €∞∞',13,10
         db        '                     € *     (c)  Miroslav Nemecek     * €∞∞',13,10
         db        '                     €‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€∞∞',13,10
         db        '                       ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞',13,10
         db        '                              licence: '
UvTxt1   db        '00000-00000',13,10
         db        '$'

HelpTxt  db  13,10,'Zadejte: /0 ........ funkce vypnuta',13,10
         db        '         /1 az /4 .. cislo portu COM s prijimacem DCF 77',13,10
         db        '         /A ........ okamzite nacitani casu (bez cekani)',13,10
         db        '         /I minut .. interval pristi aktualizace (minut, impl. 60)',13,10
         db        '         /D ........ opakovane zobrazeni aktualniho stavu',13,10
         db        '         /! ........ odinstalovani programu z pameti',13,10
         db        'Bez zadani parametru se zobrazi stav nacitani.',13,10
         db        '$'

NeAktTxt db        13,10,'Program je nyni NEAKTIVNI.',13,10,'$'

; ------ texty pro zobrazen° stavu - ©†dky mus° zachov†vat dÇlku, aby
;        p©i opakovanÇm vòpisu nezñst†vala star† informace !

LastTx24 db        '(PRIJEM)'
LastTx26 db        '(------)'
LastTx28 db        '        '

PrijCOM  db        13,10,'Pouzity port COM'
LastTxt1 db        '1: '
LastTxt2 db        '(PRIJEM) '
LastTx22 db        ' ',13,10,'$'

LastTx52 db        'OVERENI'
LastTx54 db        'nacteni'

LastTxt3 db        'Aktualni stav '                ; ƒƒø 14 + 18 + 12 = 44
LastTxt4 db        '--:--/--.--.---- ('            ;   ≥
LastTxt5 db        '00% nacteni)',13,10,'$'        ;   ≥©†dky mus° m°t
                                                   ;   ≥stejnou dÇlku !
LastTxt6 db        'Pristi aktualizace casu v '    ;   ≥
LastTxt7 db        '--:--             '            ;   ≥ 26 + 18 = 44
         db        13,10,'$'                       ;   ≥
                                                   ;   ≥
LastTx72 db        'Nastavuji novy aktualni '      ;   ≥ 24 + 20 = 44
         db        'cas ....            '          ;   ≥
         db        13,10,'$'                       ; ƒƒŸ


LastTxt8 db        'Posledni aktualizace casu v '
LastTxt9 db        '--:--',13,10,'Aktualni cas '
LastTxt0 db        '00:00:00,00/00.00.0000 $'

LastTxtD db        'nedele ',13,10,'$'
         db        'pondeli',13,10,'$'
         db        'utery  ',13,10,'$'
         db        'streda ',13,10,'$'
         db        'ctvrtek',13,10,'$'
         db        'patek  ',13,10,'$'
         db        'sobota ',13,10,'$'

NeniCOM  db        13,10,'Port COM'
NeniCOM1 db        '1: neni v pocitaci nainstalovan !',13,10,'$'

NeniTxt  db        13,10,'Program nelze odinstalovat, neni nainstalovan !',13,10,'$'
NelzeTxt db        13,10,'Program nelze odinstalovat, nutno odinstalovat',13,10
         db        'nejdrive programy nainstalovane pozdeji !',13,10,'$'
DInsTxt  db        13,10,'Program byl odinstalovan z pameti.',13,10,'$'
InstTxt  db        13,10,'Program byl nainstalovan do pameti.',13,10,'$'

ComLine  db        128 dup(0)               ; uschovanò p©°kazovò ©†dek

Code     ENDS
         END       Start

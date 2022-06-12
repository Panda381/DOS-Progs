
; Impulsy:        110 ms < "0" < 165 ms
;                 220 ms < "1" < 275 ms

; -----------------------------------------------------------------------------
; Stanice sly¨iteln‚ v Evropˆ:
; ---------------------------
;  DCF77 - Mainfligen (SRN)
;  HBG - Prangins (›v˜carsko)
;  MSF - Rugby (Velk  Brit nie)
;  OMA - Liblice (€R) (viz AR 1976 a 1979)
;
; Vys¡la‡ DCF je um¡stˆn v Mainfligenu pobl¡‘ Frankfurtu nad Mohanem (SRN).
; Vys¡la‡ vys¡l  na kmito‡tu 77.5 kHz a m  v˜kon 27 kW. Nep©esnost £daje
; je 2 * 10^-13 za 100 dn¡. Sekundov  zna‡ka je vytvo©ena zmen¨en¡m amplitudy
; nosn‚ na 25 % na za‡ tku ka‘d‚ sekundy. D‚lka sekundov‚ zna‡ky je buƒ 100 ms
; (="0") nebo 200 ms (="1"). Bˆhem ka‘d‚ minuty je odvys¡l na £pln  ‡asov 
; informace mezi 20. a‘ 58. sekundou - tj. st©edoevropsk˜ ‡as, platn˜ pro
; n sleduj¡c¡ minutu sou‡asnˆ s datem. Za‡ tek p©enosu za‡¡n  ve 20. sekundˆ
; ka‘d‚ minuty odvys¡l n¡m sekundov‚ zna‡ky "1". V¨echny £daje jsou p©en ¨eny
; v BCD k¢du (od nejni‘¨¡ch bit– a od nejni‘¨¡ch ‡¡slic). —daje minut jsou
; odvys¡l ny mezi 21. a‘ 27. sekundou (4 + 3 bity). V 28. sekundˆ je vys¡l n
; paritn¡ bit pro minuty (sud  parita). —daje hodin jsou vys¡l ny mezi
; 29. a‘ 34. sekundou (4 + 2 bity), ve 35. sekundˆ je vys¡l n paritn¡ bit pro
; hodiny. Mezi 36. a‘ 41. sekundou je vys¡l n den (4 + 2 bity), mezi
; 42. a‘ 44. sekundou je vys¡l n den v t˜dnu (3 bity, 0=nedˆle), mezi 45.
; a‘ 49. sekundou je vys¡l n mˆs¡c a mezi 50. a‘ 57. sekundou je vys¡l n
; rok (4 + 4 bity, pouze 2 posledn¡ ‡¡slice bez stolet¡). V 58. sekundˆ
; je vys¡l n paritn¡ bit pro datum. Za‡ tek minuty se synchronizuje
; vyhodnocen¡m minutov‚ zna‡ky, kter  je vytvo©ena chybˆj¡c¡ sekundovou
; zna‡kou v 59. sekundˆ. Vys¡la‡ DCF77 je v chodu nep©etr‘itˆ kromˆ
; ka‘d‚ho druh‚ho £ter˜ v mˆs¡ci mezi 5. a 9. hodinou (prob¡h  technick 
; £dr‘ba).
; -----------------------------------------------------------------------------
; Port COM: v˜stup DTR (pin 20) = +12V   (+ nap jen¡ DCF)
;           v˜stup RTS (pin  4) = -12V   (- nap jen¡ DCF)
;           vstup  CTS (pin  5) = impuls -12V -> +12V
;           zem    GND (pin  7) = 0V     (zem DCF)
; Port LPT: v˜stup SLCT (pin 17) = 0V (zem pro DCF, p©i aktivaci tisk rny
;                                      se zmˆn¡ na 5V, DCF se tak odpoj¡)
;           v˜stup STROBE (pin 1) = 5V (nap jen¡ DCF - zapojit p©es diodu,
;                                      m–‘e m¡t opa‡n‚ napˆt¡ ne‘ SLCT !)
;           v˜stup AUTO LINEFEED (pin 14) = 5V (pos¡len¡ STROBE - p©es diodu)
;           vstup BUSY (pin 11) = impuls 5V -> 0V (sp¡nat p©es tranzistor
;                                                  a diodu)
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

KLICFN   EQU       2bh*HI + "?"             ; kl¡‡ funkce a dotazu
KLIC1    EQU       'DC'                     ; identifika‡n¡ kl¡‡ 1 (BX)
KLIC2    EQU       'F7'                     ; identifika‡n¡ kl¡‡ 2 (CX)
KLIC3    EQU       '7?'                     ; identifika‡n¡ kl¡‡ 3 (DX)
KLICOK   EQU       'OK'                     ; odpovˆdn¡ kl¡‡ (AX)


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

RezBeg   label     byte                     ; za‡ tek rezidentn¡ ‡ sti

Ident    db        'F7'                     ; identifikace v pamˆti

Old08    dd        0                        ; uschovan  adresa INT 08h
Old21    dd        0                        ; uschovan  adresa INT 21h
Old28    dd        0                        ; p–vodn¡ adresa obsluhy INT 28h
Aktiv21  dd        0                        ; adresa p©¡znaku aktivity DOS (-1=nen¡)
ErrDOS   dd        0                        ; adresa p©¡znaku obsluhy chyby DOS

Port     dw        0                        ; ‡¡slo portu 0 a‘ 3 (COM, LPT)

OutPort  dw        0                        ; adresa v˜stupn¡ho portu
OutByte  db        0                        ; hodnota pro v˜stup

InpPort  dw        0                        ; adresa vstupn¡ho portu
InpMask  db        0                        ; maska pro vstup dat
InpByte  db        0                        ; po‘adovan  hodnota pro impuls

Param    db        bit1+bit4                ; parametry
                                            ;   bit 0: 0=COM, 1=LPT
                                            ;   bit 1: 1=funkce vypnuta
                                            ;   bit 2: 1=byla korekce ‡asu
                                            ;   bit 3: 1=je impuls
                                            ;   bit 4: 1=‡ek  se na min. zna‡ku
                                            ;   bit 5: 1=po‘adavek nastaven¡ DOS
                                            ;   bit 6: 1=‡ek  se na START bit
                                            ;   bit 7: 1=‡ek  se na paritn¡ bit

;CitOK    db        0                        ; ‡¡ta‡ dat pro operaci OK

SekundaL db        0                        ; sekunda posledn¡ korekce ‡asu
MinutaL  db        0                        ; minuta posledn¡ korekce ‡asu
HodinaL  db        0                        ; hodina posledn¡ korekce ‡asu

BitL     db        0                        ; naposledy p©ijat˜ bit
CitSek   db        0                        ; ‡¡ta‡ ubˆhl‚ sekundy 0 a‘ 59

LoadBit  db        20                       ; ‡¡ta‡ startovac¡ch bit–
Ukaz     dw        offset Zprava+KORIG      ; ukazatel zpr vy
UkazBit  db        7                        ; po‡et bit– k na‡ten¡

Parita   db        0                        ; st©ada‡ parity

Korekce  dw        0                        ; ‡¡ta‡ korekce 55 ms
Setina   db        0                        ; setina sekundy
Sekunda  db        0                        ; sekunda

Zprava   label     byte                     ; zpr va (data BCD/bit–/min/max)
Minuta   db        80h,7+bit7,0,59          ; minuta (+ parita)
Hodina   db        80h,6+bit7,0,23          ; hodina (+ parita)
Den      db        80h,6,1,31               ; den
Tyden    db        80h,3,1,7                ; den v t˜dnu (1 a‘ 7 = PO a‘ NE)
Mesic    db        80h,5,1,12               ; mˆs¡c
Rok      db        80h,8+bit7,0,99          ; rok bez stolet¡ (+ parita)
Zprava0  label     byte                     ; posledn¡ polo‘ka

CitCteni db        0                        ; ‡¡ta‡ proveden˜ch ‡ten¡ OK
CitMax   db        2                        ; po‡et po‘adovan˜ch ‡ten¡

Uschova  db        6*4 dup(0)               ; £schova zpr vy

CitacImp dw        0                        ; ‡¡ta‡ d‚lky impulsu
CitacMez dw        0                        ; ‡¡ta‡ d‚lky mezery

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ ‡¡t n¡ korekce pro nastaven¡ ‡asu

         inc       word ptr cs:[Korekce+KORIG] ; ‡¡t n¡ korekce p©i p©¡jmu

; ------ test, zda je obsluha zapnuta

         test      byte ptr cs:[Param+KORIG],bit1+bit5 ; funkce vypnuta/DOS ?
         jz        Int081                   ; funkce nen¡ vypnuta
         jmp       dword ptr cs:[Old08+KORIG] ; p–vodn¡ obsluha INT 08h

; ------ p–vodn¡ obsluha INT 08h

Int081:  pushf
         call      dword ptr cs:[Old08+KORIG] ; p–vodn¡ obsluha INT 08h

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         push      cs
         pop       ds                       ; DS <- datov˜ segment
         push      cs
         pop       es                       ; ES <- datov˜ segment

; ------ vysl n¡ sign lu na port

         mov       dx,ds:[OutPort+KORIG]    ; v˜stupn¡ port
         mov       al,ds:[OutByte+KORIG]
         out       dx,al                    ; nastaven¡ sign l–

; ------ na‡ten¡ stavu portu

         mov       dx,ds:[InpPort+KORIG]    ; vstupn¡ port
         in        al,dx                    ; na‡ten¡ stavu portu
         and       al,ds:[InpMask+KORIG]    ; maskov n¡
         cmp       al,ds:[InpByte+KORIG]    ; je impuls ?
         jne       Int082                   ; nen¡ impuls

; ------ je impuls (p©¡p. konec mezery)

         test      byte ptr ds:[Param+KORIG],bit3 ; je ji‘ impuls ?
         jz        Int0812                  ; nebyl impuls
Int0810A:inc       word ptr ds:[CitacImp+KORIG] ; ‡¡t n¡ d‚lky impulsu
Int0810: jmp       Int086

Int0812: mov       ax,ds:[CitacMez+KORIG]   ; ‡¡ta‡ mezery
         cmp       ax,11                    ; minim ln¡ d‚lka mezery
         jb        Int0822A                 ; p©¡li¨ kr tk  mezera
         mov       word ptr ds:[CitacImp+KORIG],0 ; nulov n¡ ‡¡ta‡e impulsu
         or        byte ptr ds:[Param+KORIG],bit3 ; p©¡znak impulsu

; ------ p©i¨la minutov  zna‡ka

         cmp       ax,30                    ; asi tak minutov  zna‡ka
         jb        Int0810                  ; nen¡ minutov  zna‡ka
         cmp       ax,39                    ; asi tak maximum
         ja        Int08121                 ; p©¡li¨ dlouh  mezera - znovu
         and       byte ptr ds:[Param+KORIG],not bit4 ; konec ‡ek n¡ na zna‡ku
         jmp       Int088             ; zah jen¡ p©¡jmu

Int08121:jmp       Int0872                  ; mal  mezera - chyba

; ------ je mezera (p©¡p. konec impulsu)

Int082:  test      byte ptr ds:[Param+KORIG],bit3 ; je ji‘ mezera ?
         jnz       Int0822                  ; nebyla mezera
Int0822A:inc       word ptr ds:[CitacMez+KORIG] ; ‡¡t n¡ d‚lky mezery
         jmp       short Int0810

Int0822: mov       ax,ds:[CitacImp+KORIG]   ; ‡¡ta‡ impulsu
         or        ax,ax                    ; minim ln¡ d‚lka impulsu
         jz        Int0810A                 ; impuls p©¡li¨ kr tk˜
         mov       word ptr ds:[CitacMez+KORIG],0 ; nulov n¡ ‡¡ta‡e mezery
         and       byte ptr ds:[Param+KORIG],not bit3 ; p©¡znak mezery

; ------ p©¡li¨ dlouh˜ impuls je chyba

         cmp       ax,5                     ; asi tak maximum
         jae       Int08121                 ; p©¡li¨ dlouh˜ impuls - chyba

; ------ rozli¨en¡ logick‚ hodnoty impulsu

         cmp       ax,3                     ; je "1" ?
         mov       al,0
         jb        Int0823
         inc       ax
Int0823: mov       ds:[BitL+KORIG],al       ; £schova bitu
         inc       byte ptr ds:[CitSek+KORIG] ; ‡¡ta‡ ubˆhl‚ sekundy

; ------ ‡¡t n¡ zav dˆc¡ch bit–

         cmp       byte ptr ds:[LoadBit+KORIG],0 ; jsou zav dˆc¡ bity ?
         je        Int0824                  ; nejsou zav dˆc¡ bity
         or        byte ptr ds:[Param+KORIG],bit6 ; ‡ek  se na START bit
         dec       byte ptr ds:[LoadBit+KORIG] ; ‡¡t n¡ zav dˆc¡ch bit–
         cmp       byte ptr ds:[LoadBit+KORIG],6 ; tolik bit– se neporovn v 
         jb        Int0810                  ; je ji‘ m lo bit–
         cmp       al,0                     ; je "0" ?
         jne       Int08250                 ; chyba
         jmp       short Int0810

; ------ START bit

Int0824: test      byte ptr ds:[Param+KORIG],bit6 ; ‡ek  se na START bit ?
         jz        Int0825                  ; ne‡ek  se na START bit
         and       byte ptr ds:[Param+KORIG],not bit6 ; zru¨en¡ p©¡znaku
         cmp       al,1                     ; je START bit ?
         jne       Int08250                 ; chyba p©¡jmu
         jmp       Int086                   ; je START bit OK

Int08244:jmp       Int08259                 ; ne‡ek  se na paritn¡ bit

; ------ na‡ten¡ paritn¡ho bitu

Int0825: mov       bx,ds:[Ukaz+KORIG]

         xor       byte ptr ds:[Parita+KORIG],al ; ‡¡t n¡ bitu parity
         test      byte ptr ds:[Param+KORIG],bit7 ; ‡ek  se na paritn¡ bit ?
         jz        Int08244                 ; ne‡ek  se na paritn¡ bit

         and       byte ptr ds:[Param+KORIG],not bit7 ; zru¨en¡ p©¡znaku
         cmp       byte ptr ds:[Parita+KORIG],0 ; je parita OK ?
         je        Int08251
Int08250:jmp       Int087                  ; chyba parity

; ------ test, zda je ji‘ konec

Int08251:cmp       bx,offset Zprava0+KORIG  ; je ji‘ konec ?
         jae       Int08252
         jmp       Int086                   ; nen¡ je¨tˆ konec

Int08252:cmp       byte ptr ds:[CitCteni+KORIG],0 ; je to prvn¡ ‡ten¡ ?
         je        Int08257                 ; je to prvn¡ ‡ten¡ - neporovn v  se

         mov       si,offset Zprava+KORIG   ; na‡ten  zpr va
         mov       di,offset Uschova+KORIG  ; buffer £schovy
         mov       cx,offset(Zprava0-Zprava) ; d‚lka zpr vy
         cld
         repe      cmpsb                    ; porovn n¡ zpr vy
         jne       Int08257                 ; porovn n¡ nesouhlas¡

         inc       byte ptr ds:[CitCteni+KORIG] ; zv˜¨en¡ ‡¡ta‡e ‡ten¡, je-li OK
         mov       al,ds:[CitCteni+KORIG]   ; ‡¡ta‡ ‡ten¡
         cmp       al,ds:[CitMax+KORIG]     ; jsou ji‘ v¨echny pokusy ?
         jb        Int08258                 ; nejsou je¨tˆ v¨echny pokusy

         mov       byte ptr ds:[CitCteni+KORIG],0 ; nulov n¡ ‡¡ta‡e
         mov       byte ptr ds:[Sekunda+KORIG],0
         mov       byte ptr ds:[Setina+KORIG],0

         mov       ax,-36+3                 ; tolik impuls– po za‡ tek minuty
         add       ax,ds:[CitacImp+KORIG]   ; ode‡ten¡ uplynul‚ho ‡asu
         mov       word ptr ds:[Korekce+KORIG],ax ; doba do nastaven¡ ‡asu

         or        byte ptr ds:[Param+KORIG],bit5 ; po‘adavek nastaven¡ DOS
         inc       byte ptr ds:[CitMax+KORIG] ; zv˜¨en¡ ‡¡ta‡e max. pokus–
         cmp       byte ptr ds:[CitMax+KORIG],4 ; maximum
         jbe       Int0872                  ; je to OK
         dec       byte ptr ds:[CitMax+KORIG] ; omezen¡
         jmp       short Int0872            ; dal¨¡ bit

Int08257:mov       byte ptr ds:[CitCteni+KORIG],1 ; nulov n¡ ‡¡ta‡e
Int08258:inc       byte ptr ds:[Minuta+KORIG] ; p©ednastaven¡ minuty + 1
         mov       si,offset Zprava+KORIG   ; na‡ten  zpr va
         mov       di,offset Uschova+KORIG  ; buffer £schovy
         mov       cx,offset(Zprava0-Zprava) ; d‚lka zpr vy
         cld
         rep       movsb                    ; £schova zpr vy
         jmp       Int0872                  ; p©¡jem dal¨¡ zpr vy

; ------ na‡ten¡ bitu do ‡¡sla

Int08259:shr       al,1                     ; bit do CF
         rcr       byte ptr ds:[bx],1       ; rotace do ‡¡sla
         dec       byte ptr ds:[UkazBit+KORIG] ; ‡¡ta‡ bit–
         jnz       Int086                   ; bude dal¨¡ bit

; ------ rotace ‡¡sla na pozici

         cmp       byte ptr ds:[bx+1],8+bit7 ; je to rok ?
         je        Int08262                 ; je to rok
Int0826: shr       byte ptr ds:[bx],1
         jnc       Int0826

; ------ konverze ‡¡sla na bin rn¡ tvar

Int08262:mov       al,ds:[bx]               ; na‡ten  hodnota
         mov       ah,al
         mov       cl,4
         shr       ah,cl
         and       ax,0f0fh
         aad
         mov       ds:[bx],al

; ------ kontrola p©ete‡en¡ ‡¡sla

         cmp       al,ds:[bx+2]             ; minim ln¡ hodnota
         jb        Int087                   ; podte‡en¡
         cmp       al,ds:[bx+3]             ; maxim ln¡ hodnota
         ja        Int087                   ; p©ete‡en¡

; ------ test, zda bude paritn¡ bit

         test      byte ptr ds:[bx+1],bit7  ; bude paritn¡ bit ?
         jz        Int0827                  ; nebude paritn¡ bit
         or        byte ptr ds:[Param+KORIG],bit7 ; bude paritn¡ bit

; ------ zv˜¨en¡ ukazatele dat

Int0827: add       bx,4
         mov       ds:[Ukaz+KORIG],bx       ; nov˜ ukazatel dat

; ------ test, zda je ji‘ konec

         cmp       bx,offset Zprava0+KORIG  ; je ji‘ konec ?
         jae       Int086                   ; je ji‘ konec
         mov       byte ptr ds:[bx],80h     ; p©¡prava st©ada‡e dat
         mov       al,ds:[bx+1]             ; po‡et bit–
         and       al,not bit7              ; nulov n¡ p©¡znaku parity
         mov       ds:[UkazBit+KORIG],al    ; ukazatel bit–

; ------ nulov n¡ p©i ‡ek n¡ na minutovou zna‡ku

Int086:  test      byte ptr ds:[Param+KORIG],bit4 ; ‡ek  se na zna‡ku ?
         jz        Int089                   ; ne‡ek  se na zna‡ku
         jmp       short Int088             ; ‡ek  se

; ------ CHYBA - inicializace na‡¡t n¡ dat na za‡ tek

Int087:  mov       byte ptr ds:[CitCteni+KORIG],0 ; nulov n¡ ‡¡ta‡e
Int0872: or        byte ptr ds:[Param+KORIG],bit4 ; ‡ek  se na minutovou zna‡ku
Int088:  mov       word ptr ds:[Ukaz+KORIG],offset Zprava+KORIG ; inicializace ukazatele
         mov       byte ptr ds:[UkazBit+KORIG],7 ; ‡¡ta‡ bit– k na‡ten¡ - minuta
         mov       byte ptr ds:[CitSek+KORIG],0 ; ‡¡ta‡ ubˆhl‚ sekundy
         mov       byte ptr ds:[LoadBit+KORIG],20 ; ‡¡ta‡ zav dˆc¡ch bit–
         mov       byte ptr ds:[Parita+KORIG],0  ; st©ada‡ parity
         test      byte ptr ds:[Param+KORIG],bit5 ; je nastaven¡ DOS ?
         jnz       Int089                   ; je nastaven¡ DOS
         mov       byte ptr ds:[Minuta+KORIG],80h ; minuta neplatn 

; ------ n vrat registr–

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
         cmp       ax,KLICFN                ; funk‡n¡ kl¡‡
         jne       Int212
         cmp       bx,KLIC1                 ; identifika‡n¡ kl¡‡ 1
         jne       Int212
         cmp       cx,KLIC2                 ; identifika‡n¡ kl¡‡ 2
         jne       Int212
         cmp       dx,KLIC3                 ; identifika‡n¡ kl¡‡ 3
         jne       Int212
         mov       ax,KLICOK                ; odpovˆdn¡ kl¡‡
         push      cs
         pop       es                       ; ES <- segment programu
         popf
         iret

Int212:  popf

; ------ obsluha INT 21h

         call      IntDOS                   ; obsluha p©¡stupu k DOS
         jmp       dword ptr cs:[Old21+KORIG] ; pokra‡ov n¡ p–vodn¡ obsluhou

Int21    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

         call      IntDOS                   ; obsluha p©¡stupu k DOS
         jmp       dword ptr cs:[Old28+KORIG] ; pokra‡ov n¡ p–vodn¡ obsluhou

Int28    ENDP

; -----------------------------------------------------------------------------
;        obsluha p©¡stupu k DOS
; -----------------------------------------------------------------------------

IntDOS   PROC      NEAR

; ------ test, zda m  b˜t obsluha ‡asu DOS

         pushf
         cmp       word ptr cs:[Korekce+KORIG],8000h
         jae       IntDOS0
         test      byte ptr cs:[Param+KORIG],bit5 ; po‘adavek obsluhy DOS ?
         jnz       IntDOS1                  ; je po‘adavek obsluhy DOS
IntDOS0: jmp       IntDOS9                  ; nen¡ po‘adov na obsluha DOS

; ------ test p©¡znaku aktivity DOS

IntDOS1: push      ds
         push      bx
         lds       bx,cs:[Aktiv21+KORIG]    ; adresa p©¡znaku aktivity DOS
         cmp       bx,-1                    ; je adresa definov na ?
         je        IntDOS2                  ; nen¡ definov na
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn¡ ?
IntDOS2: pop       bx
         pop       ds
         jne       IntDOS0                  ; DOS je aktivn¡

; ------ test p©¡znaku obsluhy chyby DOS

         push      ds
         push      bx
         lds       bx,cs:[ErrDOS+KORIG]     ; adresa p©¡znaku obsluhy chyby DOS
         cmp       bx,-1                    ; je adresa definov na ?
         je        IntDOS3                  ; nen¡ definov na
         cmp       byte ptr ds:[bx],0       ; je chyba DOS aktivn¡ ?
IntDOS3: pop       bx
         pop       ds
         jne       IntDOS0                  ; obsluha chyby DOS je aktivn¡

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds                       ; DS <- CS


; ------ korekce ‡asu

         mov       ax,ds:[Korekce+KORIG]    ; korekce ‡asu
         cmp       ax,30*18                 ; maxim ln¡ prodleva 30 sekund
         ja        IntDOS8                  ; to je ji‘ p©¡li¨ dlouho
         mov       cx,100
         mul       cx
         mov       cl,18
         div       cx                       ; p©epo‡et na 1/100 sekund
                                          ;* zde je AX maxim lnˆ 3000
         add       al,ds:[Setina+KORIG]     ; p©i‡ten¡ 1/100 sekund
         adc       ah,0
         mov       cl,100
         div       cl                       ; p©epo‡et na sekundy a setiny
         mov       ds:[Setina+KORIG],ah     ; setina sekundy
         add       ds:[Sekunda+KORIG],al    ; korekce sekund
         cmp       byte ptr ds:[Sekunda+KORIG],60
         jb        IntDOS5
         sub       byte ptr ds:[Sekunda+KORIG],60
         inc       byte ptr ds:[Minuta+KORIG] ; korekce minut (p©ete‡en¡ ignoruje)

; ------ nastaven¡ ‡asu DOS

IntDOS5: mov       ch,ds:[Hodina+KORIG]     ; hodina
         mov       cl,ds:[Minuta+KORIG]     ; minuta
         mov       dh,ds:[Sekunda+KORIG]    ; sekunda
         mov       dl,ds:[Setina+KORIG]     ; setina sekundy
         mov       ah,2dh
         call      Int21P                   ; nastaven¡ syst‚mov‚ho ‡asu
         cmp       al,0                     ; byl ‡as OK ?
         jne       IntDOS6                  ; nebyl spr vn˜ ‡as
         mov       ds:[HodinaL+KORIG],ch    ; naposledy proveden  korekce
         mov       ds:[MinutaL+KORIG],cl    ; naposledy proveden  korekce
         mov       ds:[SekundaL+KORIG],dh   ; naposledu proveden  korekce
         or        byte ptr ds:[Param+KORIG],bit2 ; p©¡znak proveden¡ korekce

; ------ nastaven¡ data DOS

IntDOS6: mov       cl,ds:[Rok+KORIG]        ; rok bez stolet¡
         mov       ch,0

         add       cx,1900
         cmp       cx,1980
         jae       IntDOS7
         add       cx,100

IntDOS7: mov       dh,ds:[Mesic+KORIG]      ; mˆs¡c
         mov       dl,ds:[Den+KORIG]        ; den
         mov       ah,2bh
         call      Int21P                   ; nastaven¡ syst‚mov‚ho data

IntDOS8: and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ po‘adavku
         mov       byte ptr ds:[Minuta+KORIG],80h ; minuta neplatn 

; ------ n vrat registr–

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
IntDOS9: popf
         ret

IntDOS   ENDP

; -----------------------------------------------------------------------------
;        vol n¡ funkce DOS (DS=CS !)
; -----------------------------------------------------------------------------

Int21P   PROC      NEAR

         pushf
         call      dword ptr ds:[Old21+KORIG]
         ret

Int21P   ENDP

RezEnd   label     byte                     ; konec rezidentn¡ho modulu

; *****************************************************************************
;
;                          Start a instalace programu
;
; *****************************************************************************
;þ
; ------ zobrazen¡ £vodn¡ho textu

Instal:  mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ na‡ten¡ adres obsluh p©eru¨en¡

         call      GetInt                   ; na‡ten¡ adres p©eru¨en¡

; ------ £schova p©¡kazov‚ho © dku do bufferu

         push      ds
         pop       es                       ; ES <- DS
         mov       si,81h                   ; p©¡kazov˜ © dek
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         and       cl,7fh                   ; pojistka proti p©ete‡en¡
         mov       di,offset ComLine        ; buffer p©¡kazov‚ho © dku
         cld
         rep       movsb                    ; £schova p©¡kazov‚ho © dku
         mov       al,0                     ; koncov  nula
         stosb                              ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ posun programu n¡‘e (ES=DS)

         mov       si,offset RezBeg         ; za‡ tek rezidentn¡ho modulu
         mov       di,offset RezBeg + KORIG ; nov˜ za‡ tek rezidentn¡ho modulu
         mov       cx,offset(RezEnd-RezBeg) ; d‚lka rezidentn¡ho modulu
         rep       movsb                    ; p©esun programu n¡‘e

; ------ test, je-li program rezidentn¡ (DS=ES !)

         mov       ax,KLICFN                ; kl¡‡ funkce a dotazu
         mov       bx,KLIC1                 ; identifika‡n¡ kl¡‡ 1
         mov       cx,KLIC2                 ; identifika‡n¡ kl¡‡ 2
         mov       dx,KLIC3                 ; identifika‡n¡ kl¡‡ 3
         int       21h                      ; test instalace
         cmp       ax,KLICOK                ; odpovˆdn¡ kl¡‡
         jne       Instal1                  ; program nen¡ rezidentn¡
         cmp       word ptr es:[Ident+KORIG],"7F" ; souhlas¡ identifikace ?
         je        Instal2                  ; program je rezidentn¡ OK

Instal1: push      cs
         pop       es                       ; ES <- segment tohoto programu
         and       byte ptr ds:[InstPar],not bit0 ; nen¡ rezidentn¡

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku (ES=rezidentn¡ segment)

Instal2: mov       si,offset ComLine        ; buffer p©¡kazov‚ho © dku
         call      RozbChr                  ; na‡ten¡ znaku
         jc        Instal5                  ; nen¡ dal¨¡ znak

; ------ odinstalov n¡ programu z pamˆti

         cmp       al,"!"                   ; odinstalov n¡ ?
         jne       Instal3                  ; nen¡ odinstalov n¡
         jmp       OdInst                   ; odinstalov n¡ programu

; ------ vypnut¡ funkce

Instal3: cmp       al,"0"
         jne       Instal4
         or        byte ptr ds:[InstPar],bit1 ; zad no ‡¡slo portu
         or        byte ptr es:[Param+KORIG],bit1 ; vypnut¡ funkce
         jmp       short Instal5

; ------ zad n¡ ‡¡sla portu

Instal4: sub       al,"1"
         jb        Chyba0
         cmp       al,7
         ja        Chyba0
         or        byte ptr ds:[InstPar],bit1 ; zad no ‡¡slo portu
         call      InstPort                 ; instalace portu AL
         jc        Chyba                    ; chyba - port neexistuje

; ------ nainstalov n¡ programu

Instal5: test      byte ptr ds:[InstPar],bit0 ; je ji‘ nainstalov n ?
         jnz       Instal6                  ; je ji‘ nainstalov n
         test      byte ptr ds:[InstPar],bit1 ; m  b˜t instalace ?
         jz        Chyba0                   ; nezad na instalace - chyba
         jmp       Inst                     ; instalace programu

; ------ pouze zobrazen¡ stavu

Instal6: call      DispStav                 ; zobrazen¡ stavu
         int       20h

; ------ hl ¨en¡ chyby

Chyba0:  mov       dx,offset HelpTxt        ; chybov‚ hl ¨en¡
Chyba:   call      DispTxt                  ; zobrazen¡ chyby
         int       20h

; -----------------------------------------------------------------------------
;                            instalace programu
; -----------------------------------------------------------------------------

; ------ hl ¨en¡ o nainstalov n¡

Inst:    mov       dx,offset InstTxt
         call      DispTxt                  ; hl ¨en¡ o nainstalov n¡

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

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ instalace programu

         mov       dx,offset RezEnd+KORIG   ; konec rezidentn¡ho modulu
         int       27h                      ; instalace do pamˆti

; -----------------------------------------------------------------------------
;        na‡ten¡ adres p©eru¨en¡
; -----------------------------------------------------------------------------

GetInt   PROC      NEAR

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; £schova INT 08h
         mov       word ptr ds:[Old08+2],es

; ------ £schova adresy INT 21h

         mov       ax,3521h
         int       21h                      ; poskytnut¡ adresy INT 21h
         mov       word ptr ds:[Old21],bx   ; £schova INT 21h
         mov       word ptr ds:[Old21+2],es

; ------ £schova adresy INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       word ptr ds:[Old28],bx
         mov       word ptr ds:[Old28+2],es

; ------ instalace p©¡znaku aktivity DOS

         mov       bx,-1                    ; BX <- 0ffffh nepovolen  hodnota
         mov       es,bx                    ; ES <- 0ffffh nepovolen  hodnota
         mov       ah,34h
         int       21h                      ; poskytnut¡ p©¡znaku aktivity DOS
         mov       ax,es
         inc       ax                       ; m  ES povolenou hodnotu ?
         jnz       GetInt2                  ; ES je definov no OK
         mov       bx,es                    ; ES i BX maj¡ hodnotu 0ffffh
GetInt2: mov       word ptr ds:[Aktiv21],bx ; adresa p©¡znaku aktivity DOS
         mov       word ptr ds:[Aktiv21+2],es ; segment p©¡znaku aktivity DOS

; ------ instalace p©¡znaku obsluhy chyby DOS

         push      ds
         mov       si,-1                    ; SI <- 0ffffh nepovolen  hodnota
         mov       ds,si                    ; DS <- 0ffffh nepovolen  hodnota
         mov       ax,5d06h
         int       21h                      ; poskytnut¡ p©¡znaku chyby DOS
         jnc       GetInt4                  ; operace OK
         mov       si,-1                    ; adresa je neplatn 
GetInt4: mov       ax,ds                    ; segment adresy
         inc       ax                       ; m  DS povolenou hodnotu ?
         jnz       GetInt6                  ; DS je definov no OK
         mov       si,ds                    ; DS i SI maj¡ hodnotu 0ffffh
GetInt6: dec       ax                       ; n vrat DS
         pop       ds
         mov       word ptr ds:[ErrDOS],si  ; adresa p©¡znaku aktivity DOS
         mov       word ptr ds:[ErrDOS+2],ax ; segment p©¡znaku aktivity DOS
         ret

GetInt   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ stavu programu (ES=rezidentn¡ segment)
; -----------------------------------------------------------------------------

DispStav PROC      NEAR

; ------ program je neaktivn¡

         test      byte ptr es:[Param+KORIG],bit1 ; funkce vypnuta ?
         jz        DispStv0
         mov       dx,offset NeAktTxt       ; program neaktivn¡
         call      DispTxt
         ret

; ------ typ portu

DispStv0:mov       dx,offset PrijCOM        ; port COM
         test      byte ptr es:[Param+KORIG],bit0 ; je port COM ?
         jz        DispStv1                 ; je port COM
         mov       dx,offset PrijLPT        ; jinak port LPT
DispStv1:call      DispTxt                  ; zobrazen¡ typu portu

; ------ po‡et ‡ten¡ OK

         mov       al,es:[CitCteni+KORIG]   ; ‡¡ta‡ proveden˜ch ‡ten¡
         add       al,"0"                   ; korekce na znak ASCII
         mov       ds:[LastTxt4],al         ; po‡et proveden˜ch ‡ten¡
         mov       al,es:[CitMax+KORIG]     ; po‡et po‘adovan˜ch ‡ten¡
         add       al,"0"                   ; korekce na znak ASCII
         mov       ds:[LastTxt4+4],al       ; po‡et po‘adovan˜ch ‡ten¡

; ------ p©¡prava ‡¡sla portu

         mov       al,byte ptr es:[Port+KORIG] ; ‡¡slo portu
         add       byte ptr ds:[LastTxt],al ; ‡¡slo portu

; ------ stav sign lu

         mov       al,"_"                   ; nen¡ impuls
         test      byte ptr es:[Param+KORIG],bit3 ; je impuls ?
         jz        DispStv2                 ; nen¡ impuls
         mov       al,"*"                   ; je impuls
DispStv2:mov       ds:[LastTxt1],al         ; stav impulsu
         mov       al,es:[BitL+KORIG]
         add       al,"0"
         mov       ds:[LastTxt1+3],al

         mov       al,es:[CitSek+KORIG]
         cmp       al,59
         jbe       DispStv3
         mov       al,59
DispStv3:mov       ah,100
         mul       ah
         mov       cl,60
         div       cl
         aam
         add       ax,"00"
         xchg      al,ah
         mov       word ptr ds:[LastTxt3],ax ; procenta

; ------ aktu ln¡ ukazatele

         mov       si,offset Hodina+KORIG
         mov       di,offset LastTxt2
         call      DispStvA
         mov       si,offset Minuta+KORIG
         call      DispStvA
         mov       si,offset Den+KORIG
         call      DispStvA
         mov       si,offset Mesic+KORIG
         call      DispStvA

         inc       di
         inc       di
         push      si
         call      DispStvA
         pop       si
         cmp       si,es:[Ukaz+KORIG]
         jae       DispStv5

         mov       word ptr ds:[di-5],"91"
         cmp       byte ptr ds:[di-3],"8"
         jae       DispStv5
         mov       word ptr ds:[di-5],"02"

; ------ ‡as posledn¡ho p©¡jmu

DispStv5:test      byte ptr es:[Param+KORIG],bit2 ; byla korekce ?
         jz        DispStv6                 ; nebyla korekce

         mov       al,es:[HodinaL+KORIG]    ; hodina p©¡jmu
         mov       di,offset LastTxt0
         call      DispStvB
         mov       al,es:[MinutaL+KORIG]    ; minuta p©¡jmu
         call      DispStvB
         mov       al,es:[SekundaL+KORIG]    ; minuta p©¡jmu
         call      DispStvB

; ------ aktu ln¡ ‡as

DispStv6:mov       di,offset LastTxt5
         mov       ah,2ch
         int       21h                      ; poskytnut¡u syst‚mov‚ho ‡asu
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
         mov       al,dh                    ; mˆs¡c
         call      DispStvB
         mov       al,100
         xchg      ax,cx
         div       cl
         push      ax
         call      DispStvB                 ; stolet¡
         pop       ax
         dec       di
         mov       al,ah
         call      DispStvB                 ; rok

         mov       dx,offset LastTxt        ; posledn¡ p©ijat˜ ‡as
         call      DispTxt

         pop       ax
         mov       ah,10
         mul       ah
         add       ax,offset LastTxtD
         xchg      ax,dx
         call      DispTxt

         ret

DispStav ENDP

DispStvA:cld
         cmp       si,es:[Ukaz+KORIG]
         jae       DispStvC
         mov       al,es:[si]
DispStvB:aam
         or        ax,"00"
         xchg      al,ah
         mov       ds:[di],ax

DispStvC:add       di,3
         add       si,4
         ret

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu (ES=rezidentn¡ segment)
; -----------------------------------------------------------------------------

; ------ test, zda je program rezidentn¡

OdInst:  mov       dx,offset NeniTxt        ; nen¡ nainstalov n
         test      byte ptr ds:[InstPar],bit0 ; je program rezidentn¡ ?
         jz        OdInst6                  ; program nen¡ rezidentn¡

; ------ test segment– INT 08h, INT 21h a INT 28h

         mov       dx,offset NelzeTxt       ; hl ¨en¡ - nelze odinstalovat
         mov       ax,es                    ; AX <- rezidentn¡ segment
         cmp       ax,word ptr ds:[Old08+KORIG+2] ; souhlas¡ INT 08h ?
         jne       OdInst6                  ; nesouhlas¡
         cmp       ax,word ptr ds:[Old21+KORIG+2] ; souhlas¡ INT 21h ?
         jne       OdInst6                  ; nesouhlas¡
         cmp       ax,word ptr ds:[Old28+KORIG+2] ; souhlas¡ INT 28h ?
         jne       OdInst6                  ; nesouhlas¡

; ------ n vrat adresy INT 08h, INT 21h a INT 28h

         push      ds
         mov       ax,2508h
         lds       dx,es:[Old08+KORIG]      ; p–vodn¡ adresa INT 08h
         int       21h                      ; n vrat adresy INT 08h
         mov       ax,2521h
         lds       dx,es:[Old21+KORIG]      ; p–vodn¡ adresa INT 21h
         int       21h                      ; n vrat adresy INT 21h
         mov       ax,2528h
         lds       dx,es:[Old28+KORIG]      ; p–vodn¡ adresa INT 28h
         int       21h                      ; n vrat adresy INT 28h
         pop       ds

; ------ zru¨en¡ segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu programu
         mov       dx,offset DInsTxt        ; hl ¨en¡ o odinstalov n¡
OdInst6: jmp       Chyba

; -----------------------------------------------------------------------------
;        instalace portu AL (ES=rezidentn¡ segment)
; -----------------------------------------------------------------------------

InstPort PROC      NEAR

; ------ p©¡prava textu pro hl ¨en¡

         add       ds:[NeniCOM1],al         ; p©¡prava textu pro hl ¨en¡ pro COM
         add       ds:[NeniLPT1],al         ; p©¡prava textu

; ------ adresa portu -> BX

         push      es
         mov       bx,40h
         mov       es,bx                    ; ES <- 40h
         mov       bl,al                    ; BX <- ‡¡slo portu COM/LPT
         shl       bx,1
         mov       bx,es:[bx]               ; adresa portu COM/LPT
         pop       es

; ------ test, zda je port platn˜

         or        bx,bx                    ; je port platn˜ ?
         jnz       InstPrt2                 ; port je platn˜ OK
         mov       dx,offset NeniCOM        ; text pro COM
         cmp       al,4                     ; je zad n COM ?
         jb        InstPrt1                 ; je zad n COM
         mov       dx,offset NeniLPT        ; text pro LPT
InstPrt1:stc                                ; p©¡znak chyby
         ret

; ------ rozli¨en¡, zda je COM nebo LPT

InstPrt2:cmp       al,4                     ; je zad n COM ?
         jae       InstPrt5                 ; je zad n LPT

; ------ instalace portu COM

         mov       byte ptr es:[Port+KORIG],al ; ‡¡slo portu COM
         and       byte ptr es:[Param+KORIG],not bit0 ; je port COM
         add       bx,4                     ; ©¡dic¡ registr modemu
         mov       es:[OutPort+KORIG],bx    ; v˜stupn¡ port
         mov       byte ptr es:[OutByte+KORIG],9 ; v˜stupn¡ bajt
         inc       bx
         inc       bx                       ; stavov˜ registr modemu
         mov       es:[InpPort+KORIG],bx    ; vstupn¡ port
         mov       byte ptr es:[InpMask+KORIG],bit4 ; vstupn¡ maska
         mov       byte ptr es:[InpByte+KORIG],bit4 ; po‘adovan  hodnota
         jmp       short InstPrt8

; ------ instalace portu LPT

InstPrt5:sub       al,4                     ; korekce ‡¡sla portu
         mov       byte ptr es:[Port+KORIG],al ; ‡¡slo portu LPT
         or        byte ptr es:[Param+KORIG],bit0 ; je port LPT
         inc       bx                       ; stavov˜ registr LPT
         mov       es:[InpPort+KORIG],bx    ; vstupn¡ port
         mov       byte ptr es:[InpMask+KORIG],bit7 ; vstupn¡ maska
         mov       byte ptr es:[InpByte+KORIG],bit7 ; po‘adovan  hodnota
         inc       bx                       ; ©¡dic¡ registr LPT
         mov       es:[OutPort+KORIG],bx    ; v˜stupn¡ port
         mov       byte ptr es:[OutByte+KORIG],7 ; v˜stupn¡ bajt

InstPrt8:and       byte ptr es:[Param+KORIG],not bit1 ; zapnut¡ funkce
;         clc                                ; p©¡znak operace OK
         ret

InstPort ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

RozbChr1:cmp       byte ptr ds:[si],0       ; konec textu ?
         stc                                ; p©¡znak, ‘e nen¡ dal¨¡ znak
         je        RozbChr3                 ; konec textu
         cld
         lodsb                              ; na‡ten¡ znaku
         cmp       al," "                   ; je mezera nebo tabul tor ?
         jbe       RozbChr1                 ; mezera nebo tabul tor se ignoruje
         cmp       al,"/"                   ; oddˆlova‡ parametr– ?
         je        RozbChr1                 ; oddˆlova‡ parametr– se ignoruje
         cmp       al,"-"                   ; oddˆlova‡ parametr– ?
         je        RozbChr1                 ; oddˆlova‡ parametr– se ignoruje
         clc                                ; p©¡znak operace OK

RozbChr3:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h                      ; zobrazen¡ textu DS:DX
         pop       ax
         ret

DispTxt  ENDP

; *****************************************************************************
;
;                                   data
;
; *****************************************************************************
;þ
InstPar  db        bit0                     ; parametry
                                            ;   bit 0: 1=je rezident
                                            ;   bit 1: 1=zad no ‡¡slo portu
                                            ;            nebo vypnut¡ funkce

UvTxt    db        'DCF77 v0.82 - prijimac hodin DCF77; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Parametry programu:   0 .......... funkce vypnuta',13,10
         db        '                      1 az 4 ..... instalace pro port COM 1 az 4',13,10
         db        '                      5 az 8 ..... instalace pro port LPT 1 az 4',13,10
         db        '                      ! .......... odinstalovani programu z pameti',13,10
         db        'Bez zadani parametru se zobrazi stav (je-li program nainstalovan).',13,10
         db        '$'

NeAktTxt db        'Program je nyni NEAKTIVNI.',13,10,'$'

PrijCOM  db        'Aktivni port COM$'
PrijLPT  db        'Aktivni port LPT$'

LastTxt  db        '1: (stav signalu "'
LastTxt1 db        '_" 0)',13,10,'Aktualni stav nacitani casu '
LastTxt2 db        '--:--/--.--.---- ('
LastTxt3 db        '00%, nacteno '
LastTxt4 db        '0 z 2)',13,10,'Posledni aktualizace casu v '
LastTxt0 db        '--:--:--',13,10,'Aktualni cas '
LastTxt5 db        '00:00:00,00/00.00.0000 $'

PrisTxt1 db        'Pristi aktualizace casu za '
PrisTxt2 db        '00 minut.',13,10,'$'

LastTxtD db        'nedele',13,10,'$$'
         db        'pondeli',13,10,'$'
         db        'utery',13,10,'$$$'
         db        'streda',13,10,'$$'
         db        'ctvrtek',13,10,'$'
         db        'patek',13,10,'$$$'
         db        'sobota',13,10,'$$'

NeniCOM  db        'Port COM'
NeniCOM1 db        '1: neni v pocitaci pritomen !',13,10,'$'

NeniLPT  db        'Port LPT'
NeniLPT1 db        '-: neni v pocitaci pritomen !',13,10,'$'

NeniTxt  db        'Program nelze odinstalovat, neni nainstalovan !',13,10,'$'
NelzeTxt db        'Program nelze odinstalovat, nutno odinstalovat',13,10
         db        'nejdrive programy nainstalovane pozdeji !',13,10,'$'
DInsTxt  db        'Program byl odinstalovan z pameti.',13,10,'$'

InstTxt  db        'Program byl nainstalovan do pameti.',13,10,'$'

ComLine  db        128 dup(?)               ; uschovan˜ p©¡kazov˜ © dek

Code     ENDS
         END       Start

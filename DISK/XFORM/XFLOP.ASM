
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                XFLOP.ASM
;                          (c) Miroslav Nàmeáek
;                   Ovladaá roz®°©enòch form†tñ disket.
;
; Tento program lze po p©ekladu spustit jako program typu COM nebo jej um°stit
; jako BOOT sektor diskety (je nutno ov®em p©epsat z†hlav° parametrñ diskety).
; Lze jej tÇë zaálenit do zdrojovÇho textu programu - v tom p©°padà se uvede:
;
; NOCOM   EQU       1                        ; p©°znak pro p©eklad jako INCLUDE
; INCLUDE XFLOP.ASM                          ; vno©en° souboru XFLOP.ASM
;
; Jako program COM se program p©eloë° pomoc° p©°kazñ:
;
;  TASM XFLOP
;  TLINK XFLOP,XFLOP.COM /t
;
; Vòslednò program XFLOP.COM mus° m°t po p©ekladu velikost 512 bajtñ !
; Program XFLOP.COM lze spustit se zad†n°m parametru "1" nebo "2".
;
; Pozn.: Antivirov† kontrola BIOS kontroluje BOOT sektor, jestli se neprov†d°
;        modifikace adresy DS:[413h] (velikost pamàti v KB), proto je zde
;        tato operace skryt† adresov†n°m s SI.
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


IFNDEF   NOCOM

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

ENDIF

; -----------------------------------------------------------------------------
;        data BOOT sektoru (inicializaánà nastaveny parametry diskety 1.2 MB)
; -----------------------------------------------------------------------------

BootBeg  label     byte                     ; zaá†tek BOOT sektoru

         jmp       BootInit                 ; start a inicializace programu

IFDEF    DEMO
BootOEM  db        'XFORM1D0'               ; identifikace
ELSE

IFDEF    SHARE
BootOEM  db        'XFORM1S0'               ; identifikace
ELSE
BootOEM  db        'XFORM1.0'               ; identifikace
ENDIF

ENDIF

BootBytS dw        512                      ; dÇlka sektoru
BootClst db        1                        ; poáet sektorñ na alokaán° blok
BootRezS dw        1                        ; poáet rezervovanòch sektorñ
BootFATN db        2                        ; poáet alok. tabulek FAT
BootRoot dw        224                      ; maxim†ln° poáet poloëek ROOT
BootSumS dw        80*15*2                  ; celkovò poáet sektorñ disku
BootMedD db        0f9h                     ; popisovaá mÇdia
BootFATS dw        7                        ; poáet sektorñ na FAT
BootSekt dw        15                       ; poáet sektorñ na stopu
BootSide dw        2                        ; poáet stran disku
BootHidS dd        0                        ; skrytòch sektorñ (2 nebo 4 bajty)
BootSumM dd        0                        ; celkem sektorñ (4 bajty)

BootDisk db        0                        ; disk (pracovn°)
BootHead db        0                        ; hlava (pracovn°)

Boot29   db        29h                      ; identifik†tor
BootSerN dd        0                        ; sÇriovÇ á°slo disku

BootLabl db        'NO NAME    '            ; n†và®t° disku
BootLab0 label     byte                     ; adresa konce n†và®t° disku
BootFATT db        'FAT12   '               ; typ FAT

; -----------------------------------------------------------------------------
;        text vòzvy k instalaci
; Nep©emisüovat jinam - mus° bòt p©ed BootIntX, aby tam skonáil registr SI !
; -----------------------------------------------------------------------------

BootTxt  db        13,10
         db        'Ovladac rozsirenych formatu disket - zvolte:',13,10
         db        ' [1]  = instalace',13,10
         db        ' [2]  = instalace se zamenou mechanik A a B',13,10
         db        'jinak = nic se neinstaluje',13,10
         db        0

; -----------------------------------------------------------------------------
;        obsluha INT 13h - z†màna diskñ
; -----------------------------------------------------------------------------

BootIntX PROC      FAR

; ------ test, zda to je disketa A: nebo B:

         cmp       dl,1                     ; maxim†ln° á°slo diskety
         ja        BootExec                 ; pokraáov†n° pñvodn° obsluhou

; ------ pro funkci 8 nen° pot©eba n†vrat

         cmp       ah,8                     ; funkce poskytnut° parametrñ ?
         je        BootInt1                 ; nebude se prov†dàt n†vrat

; ------ obsluha poëadovanÇ funkce

         push      dx                       ; £schova á°sla disku
         pushf
         push      cs
         call      near ptr BootInt1        ; obsluha poëadovanÇ funkce
         pop       dx                       ; n†vrat pñvodn°ho á°sla disku
         ret       2

; ------ z†màna disketovòch mechanik A: a B:

BootInt1:xor       dl,1                     ; z†màna disketovòch mechanik

BootIntX ENDP
                                          ;* pokraáuje BootIntY !

; -----------------------------------------------------------------------------
;        obsluha INT 13h - zvò®enÇ form†ty disket
; -----------------------------------------------------------------------------

BootIntY PROC      FAR

; ------ kontrola, zda to je mechanika A: nebo B:

         cmp       dl,1                     ; maxim†ln° á°slo diskety
         ja        BootExec                 ; pokraáov†n° pñvodn° obsluhou

; ------ kontrola, zda je funkce 2 aë 4 (áten°, z†pis, verifikace)

         cmp       ah,4
         ja        BootExec                 ; nen° funkce 2 aë 4
         cmp       ah,2
         jb        BootExec                 ; nen° funkce 2 aë 4

; ------ £schova registrñ

         push      es
         push      cx
         push      bx
         push      ax

; ------ zvò®en° poátu sektorñ na stopu

         xor       bx,bx                    ; BX <- 0
         mov       es,bx                    ; ES <- 0
         les       bx,es:[bx+4*1eh]         ; adresa tabulky INT 1Eh
         mov       byte ptr es:[bx+4],46    ; zvò®en° poátu sektorñ na stopu

; ------ inicializace registrñ na data BIOS

         mov       bx,40h                   ; BX <- 40h
         mov       es,bx                    ; ES <- 40h

; ------ test, zda je mÇdium jië uráeno

         add       bl,dl                    ; korekce na á°slo disku
         test      byte ptr es:[bx-40h+90h],10h ; je mÇdium jië uráeno ?
         jnz       BootInt8                 ; je jië uráeno

; ------ mÇdium uráeno

         or        byte ptr es:[bx-40h+90h],10h ; teÉ jië je uráeno

; ------ test, zda je rychlost nastavena OK (nyn° je ES=40h, BX=40h aë 41h)

         mov       cx,200h                  ; CH <- stopa, CL <- sektor
BootInt3:inc       cx                       ; CL <- zvò®en° á°sla sektoru
         mov       ax,401h                  ; verifikace 1 sektoru
         push      bx                       ; £schova offsetu v BIOS
         push      cx                       ; £schova stopy a sektoru
         push      dx                       ; £schova disku a strany
         pushf                              ; simulace instrukce INT ...
         push      cs                       ; simulace instrukce CALL FAR ...
         call      BootExec                 ; verifikace sektoru
         pop       dx                       ; n†vrat disku a strany
         pop       cx                       ; n†vrat stopy a sektoru
         pop       bx                       ; n†vrat offsety v BIOS
         jnc       Bootint8                 ; rychlost detekov†na OK

; ------ chyba vòmàny mÇdia nebo disk nep©ipraven - okamëitÇ ukonáen°

         cmp       ah,6
         je        BootInt9                 ; vòmàna diskety
         or        ah,ah                    ; chyba 80h ?
         js        BootInt9                 ; mechanika nep©ipravena

; ------ zvò®en° rychlosti (cyklus 500 > 300 > 250 > 1000)

         add       byte ptr es:[bx-40h+90h],40h ; zvò®en° rychlosti
         test      cl,3                     ; je sektor 4 nebo 8 ?
         jnz       BootInt3                 ; nen° sektor 4 ani 8

; ------ zmàna krokov†n° (p©i sektorech 4 a 8) (dvojitÇ a jednoduchÇ)
; Krokov†n° se màn° aë po zmàn†ch rychlosti, aby po©†d nevystavovala mechanika

         xor       byte ptr es:[bx-40h+90h],20h ; zmàna krokov†n°
         cmp       cl,8                     ; je jië maximum testñ ?
         jb        BootInt3                 ; nen° je®tà maximum testñ

; ------ mÇdium neuráeno

         and       byte ptr es:[bx-40h+90h],not 10h ; mÇdium neuráeno

; ------ n†vrat registrñ

BootInt8:pop       ax
         pop       bx
         pop       cx
         pop       es

; ------ pokraáov†n° pñvodn° obsluhou

BootExec:db        0eah                     ; instrukce JMP FAR
BootOld  dd        0                        ; pñvodn° adresa INT 13h

; ------ n†vrat p©i chybà 6 (vòmàna diskety) a 80h (nen° vloëena disketa)

BootInt9:and       byte ptr es:[bx-40h+90h],not 10h ; mÇdium neuráeno
         pop       bx                       ; ponech† se reg. AX - chybovò k¢d
         pop       bx
         pop       cx
         pop       es
         stc                                ; p©°znak chyby
         ret       2                        ; tento n†vrat pouë°v† i BIOS

BootIntY ENDP

BootREnd label     byte                     ; konec rezidentn°ho modulu

; -----------------------------------------------------------------------------
;        start a inicializace programu
; -----------------------------------------------------------------------------

; ------ rozli®en°, zda je BOOT nebo COM

BootInit:mov       ax,cs                    ; AX <- CS
         or        ax,ax                    ; je to BOOT sektor ?
         jnz       BootInC                  ; je jako COM

; -----------------------------------------------------------------------------
;        instalace jako BOOT
;   Nyn° je celò zavadàá na adrese 0:7C00h !!!
; -----------------------------------------------------------------------------

; ------ p©edefinov†n° z†sobn°ku (p©ed BOOT sektor)

         mov       si,413h                  ; offset velikosti pamàti v KB
         mov       ds,ax                    ; DS <- 0
         mov       ss,ax                    ; SS <- 0
         mov       sp,7c00h                 ; offset z†sobn°ku p©ed programem

; ------ adresa rezidentu (nepouë°vat mov ax,ds:[413h] - antiviry !) -> ES:DI

         dec       word ptr ds:[si]         ; sn°ëen° velikosti pamàti o 1 KB
         mov       di,ds:[si]               ; aktu†ln° velikost pamàti v KB
         mov       cl,6                     ; CL <- poáet rotac° pro p©epoáet
         shl       di,cl                    ; p©epoáet KB na odstavce
         mov       es,di                    ; ES <- segment rezidentu
         xor       di,di                    ; DI <- offset rezidentu

; ------ volba operace (zde je AL = 0 a DS=CS)

         call      BootInst                 ; volba instalace

; ------ n†vrat velikosti pamàti p©i p©eru®en° (je nastaven CY, CS=0)

         adc       word ptr cs:[413h],0     ; p©i p©eru®en° CY n†vrat pamàti

; ------ pokraáov†n° v zav†dàn° systÇmu

         int       19h
         hlt                                ; to jen pro jistotu, ale nen° t©eba

; -----------------------------------------------------------------------------
;        instalace jako COM
; -----------------------------------------------------------------------------

; ------ adresa k p©esunu (ES=CS, DS=CS !)

BootInC: mov       di,5ch                   ; adresa k p©esunu

; ------ nalezen° znaku v p©°kazovÇm ©†dku

         mov       si,81h                   ; buffer p©°kazovÇho ©†dku
         cld
BootInC2:lodsb                              ; naáten° znaku z p©°kazovÇho ©†dku
         cmp       al," "                   ; je oddàlovac° mezera ?
         je        BootInC2                 ; oddàlovac° mezera - dal®° znak

; ------ volba operace

         call      BootInst                 ; volba instalace
         jnc       BootInC4                 ; instaluje se OK
         int       20h                      ; p©eru®en° programu

; ------ uvolnàn° segmentu prost©ed° (DS=CS !)

BootInC4:mov       es,ds:[2ch]              ; segment prost©ed°
         mov       ah,49h
         int       21h                      ; uvolnàn° segmentu prost©ed°

; ------ instalace programu do pamàti (DI=adresa konce rezidentu !)

         mov       dx,di                    ; konec programu
         int       27h                      ; instalace

; -----------------------------------------------------------------------------
; instalace obsluhy INT 13h (AL=znak, ES:DI=zaá†tek rezidentu) -> CY=p©eru®en°
; -----------------------------------------------------------------------------
; VSTUP: AL=znak z p©°kazovÇho ©†dku (pro BOOT sektor je AL=0)
;        ES:DI=adresa k uloëen° rezidentn° obsluhy
;        DS=CS
; VùSTUP: ES:DI=adresa konce p©enesenÇho rezidentu
;         DS=CS (pouze pro NC = operace OK)
;         CY=p©eru®en° instalace
; -----------------------------------------------------------------------------

BootInst PROC      NEAR

; ------ zobrazen° textu

         push      ax                       ; £schova znaku z p©°kaz. ©†dku

         call      BootIns2                 ; n†vratov† adresa do z†sobn°ku
BootIns2:pop       si                       ; SI <- adresa BootIns2
         sub       si,offset(BootIns2-BootTxt) ; adresa textu
BootIns4:cld
         lodsb
         or        al,al
         jz        BootIns6
         push      si                       ; (instrukci lze asi zru®it)
         mov       ah,0eh
         mov       bx,7
         int       10h
         pop       si                       ; (instrukci lze asi zru®it)
         jmp       short BootIns4

BootIns6:pop       ax                       ; znak z p©°kazovÇho ©†dku

; ------ áek†n° na stisk kl†vesy (SI=adresa zaá†tku INT 13h)

         cmp       al," "                   ; byl zad†n nàjakò znak ?
         ja        BootIns7                 ; byl zad†n nàjakò znak
         xor       ax,ax
         int       16h                      ; vstup znaku z kl†vesnice

; ------ segment vektorñ p©eru®en°

BootIns7:xor       bx,bx
         mov       ds,bx                    ; DS <- 0

; ------ test, zda bude instalace volbou "1" nebo "2"

         cmp       al,"2"+1
         cmc
         jc        BootIns9                 ; nespr†vn† volba
         cmp       al,"1"
         jb        BootIns9                 ; nespr†vn† volba

; ------ £schova pñvodn° adresy INT 13h (tady je ZY=je instalace 1 !)

         mov       ax,ds:[bx+4*13h]         ; offset adresy INT 13h
         mov       word ptr cs:[si+BootOld-BootIntX],ax ; £schova offsetu adresy
         mov       ax,ds:[bx+4*13h+2]       ; segment adresy INT 13h
         mov       word ptr cs:[si+BootOld-BootIntX+2],ax ; £schova segmentu

; ------ instalace novÇ obsluhy INT 13h

         mov       ds:[bx+4*13h],di         ; offset rezidentu
         mov       ds:[bx+4*13h+2],es       ; segment rezidentu

; ------ instalace pro volby "1" - roz®°©enÇ form†ty

         mov       cx,offset(BootREnd-BootIntX) ; dÇlka dat k p©esunu
         ja        BootIns8                 ; byla volba "2" - z†màna mechanik
         add       si,offset(BootIntY-BootIntX)
         mov       cl,offset(BootREnd-BootIntY)

; ------ p©enesen° rezidentn° á†sti (zde je NC !)

BootIns8:cld
         push      cs
         pop       ds                       ; DS <- CS
         rep       movsb                    ; posun programu dolñ
BootIns9:ret

BootInst ENDP

;         db        0 dup(0)                ; doplnàk na 512 B

BootIdnt dw        0aa55h                   ; p©°znak BOOT sektoru

BootEnd  label     byte                     ; konec BOOT sektoru


IFNDEF   NOCOM

Code     ENDS
                                          ;* p©i p©ekladu jako COM hl†s°
                                          ;* varov†n°, ëe je otev©en† podm°nka
                                          ;* - to se mus° ignorovat
         END       BootBeg
ENDIF

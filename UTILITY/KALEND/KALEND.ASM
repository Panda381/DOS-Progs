
; P©¡kazov˜ © dek:
;      /! - odinstalov n¡ z pamˆti
;      /I - nespou¨t¡ se interaktivn¡ m¢d (pouze instalace/odinstalov n¡)
;      /D - zpˆtn˜ p©eklad souboru KALEND.DAT do textov‚ho tvaru KALEND.ASC
;      /A - p©eklad textov‚ho souboru KALEND.ASC do souboru KALEND.DAT

MAXDENH  EQU       255   ; 278              ; maxim ln¡ den HIGH
MAXDENL  EQU       65535 ; 43125            ; maxim ln¡ den LOW

DiskBSiz EQU       200h                     ; velikost diskov‚ho bufferu

ADRTIME  EQU       5ch                      ; adresa za‡ tku tabulky ud lost¡
MAXTIME  EQU       (103h-ADRTIME)/2         ; maxim ln¡ po‡et ud lost¡ (=83)
ADRTIME0 EQU       ADRTIME+2*MAXTIME        ; adresa konce tabulky

MaxLDiar EQU       53                       ; maxim ln¡ d‚lka © dku di ©e
MaxLNot  EQU       24                       ; maxim ln¡ d‚lka © dku pozn mky

code     segment
         ASSUME    cs:code,ds:code
         ORG       100h

Start:   jmp       Init                     ; start programu

Old08    dd        0                        ; p–vodn¡ adresa INT 08h
Old09    dd        0                        ; p–vodn¡ adresa INT 09h
Old16    dd        0                        ; p–vodn¡ adresa INT 16h

UkazTime dw        ADRTIME                  ; ukazatel v tabulce ud lost¡

CitPip   db        0                        ; ‡¡ta‡ signalizace (0=nen¡)
CitInt   db        0                        ; ‡¡ta‡ p©eru¨en¡ kl vesnic¡

; -----------------------------------------------------------------------------
;        obsluha INT 16h - test instalace programu
; -----------------------------------------------------------------------------

INT16    PROC      FAR

         cmp       ax,257ah                 ; identifik tor 1
         jne       INT162                   ; nen¡ test instalace
         cmp       bx,8a3dh                 ; identifik tor 2
         jne       INT162                   ; nen¡ test instalace
         mov       bx,4a76h                 ; v˜stupn¡ identifik tor
         push      cs
         pop       es                       ; ES <- segment programu
         iret                               ; n vrat z obsluhy INT 16h

INT162:  jmp       dword ptr cs:[Old16]     ; pokra‡ov n¡ p–vodn¡ obsluhou

INT16    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h - zvukov  signalizace
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      es

         push      cs
         pop       ds                       ; DS <- CS
         xor       ax,ax
         mov       es,ax                    ; ES <- 0

; ------ v˜po‡et aktu ln¡ho ‡asu

         mov       ax,es:[46ch]             ; ‡¡ta‡ ‡asu LOW
         mov       dl,es:[46ch+2]           ; ‡¡ta‡ ‡asu HIGH
         mov       dh,0
         mov       cl,4                     ; po‡et rotac¡
         shl       dx,cl                    ; vy¨¨¡ slovo * 16
         mov       bx,ax                    ; ni‘¨¡ slovo ‡¡ta‡e ‡asu
         mov       cl,12
         shr       bx,cl                    ; nejvy¨¨¡ 4 bity ni‘¨¡ho slova
         add       dx,bx                    ; p©enos 4 bit– do vy¨¨¡ho slova
         mov       cl,4
         shl       ax,cl                    ; ni‘¨¡ slovo * 16
         mov       bx,17478
         div       bx                       ; ‡¡ta‡ ‡asu / 1092.375

; ------ test, zda je ‡as k indikaci

         mov       si,ds:[UkazTime]         ; ukazatel v bufferu
         cmp       ax,ds:[si]               ; je ‡as k indikaci ?
         jne       INT082                   ; nen¡
         mov       byte ptr ds:[CitPip],8   ; ‡¡ta‡ indikace
         mov       byte ptr ds:[CitInt],58  ; doba pro p©eru¨en¡ kl vesnic¡ (4x)
         mov       word ptr ds:[si],-1      ; zru¨en¡ ‡asu z tabulky

; ------ zv˜¨en¡ ukazatele v tabulce

INT082:  inc       si
         inc       si
         cmp       si,ADRTIME0              ; je konec ?
         jb        INT083                   ; nen¡ konec
         mov       si,ADRTIME               ; za‡ tek tabulky
INT083:  mov       ds:[UkazTime],si         ; nov˜ ukazatel v tabulce

; ------ ‡¡t n¡ doby pro p©eru¨en¡ od kl vesnice

         cmp       byte ptr ds:[CitInt],0   ; ‡¡t  se doba pro p©eru¨en¡ INT 9 ?
         je        INT0832                  ; ne‡¡t  se
         dec       byte ptr ds:[CitInt]     ; sn¡‘en¡ ‡¡ta‡e p©eru¨en¡ INT 09h

; ------ ‡¡t n¡ doby zvukov‚ signalizace

INT0832: mov       ah,ds:[CitPip]           ; ‡¡ta‡ zvukov‚ signalizace
         cmp       ah,0                     ; po‘aduje se obsluha ?
         je        INT089                   ; nepo‘aduje se obsluha
         dec       ah                       ; sn¡‘en¡ ‡¡ta‡e
         jnz       INT084                   ; nen¡ pr–chod nulou
         mov       ah,16                    ; inicializace na v˜choz¡ hodnotu
INT084:  mov       ds:[CitPip],ah           ; ulo‘en¡ nov‚ho stavu ‡¡ta‡e

; ------ rozli¨en¡ stavu zvuk/ticho

         test      ah,1001b                 ; je prodleva ?
         jnz       INT085                   ; je prodleva

; ------ zapnut¡ v˜stupu na reproduktor

         in        al,[61h]                 ; sou‡asn˜ v˜stup na reproduktor
         or        al,3                     ; zapnut¡ v˜stupu
         out       [61h],al

; ------ nastaven¡ ‡¡ta‡e reproduktoru

         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,3                     ; konstanta
         out       [42h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [42h],al                 ; konstanta - vy¨¨¡ bajt
         jmp       short INT089

; ------ vypnut¡ v˜stupu na reproduktor

INT085:  call      Ton0                     ; vypnut¡ reproduktoru

; ------ n vrat registr–

INT089:  pop       es
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         jmp       dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h

INT08    ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ zvukov‚ho gener toru
; -----------------------------------------------------------------------------

Ton0     PROC      NEAR

; ------ vypnut¡ v˜stupu na reproduktor

         in        al,[61h]                 ; sou‡asn˜ stav v˜stupu na reprod.
         and       al,not 3                 ; vypnut¡ v˜stupu
         out       [61h],al

; ------ standardn¡ nastaven¡ ‡¡ta‡e reproduktoru

         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [42h],al                 ; konstanta - vy¨¨¡ bajt
         ret

Ton0     ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

INT09    PROC      FAR

; ------ test, zda bude p©eru¨en zvukov˜ v˜stup

         cmp       byte ptr cs:[CitPip],0   ; prob¡h  zvukov˜ v˜stup ?
         je        INT093                   ; neprob¡h  zvukov˜ v˜stup
         cmp       byte ptr cs:[CitInt],0   ; je povoleno p©eru¨en¡ kl vesnic¡ ?
         jne       INT093                   ; nen¡ povoleno p©eru¨en¡

; ------ vypnut¡ zvukov‚ho v˜stupu

         push      ax
         call      Ton0                     ; vypnut¡ v˜stupu na reproduktor
         mov       byte ptr cs:[CitPip],0   ; zru¨en¡ p©¡znaku indikace
         pop       ax

INT093:  jmp       dword ptr cs:[Old09]     ; p–vodn¡ obsluha INT 09h

INT09    ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                start programu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ zobrazen¡ £vodn¡ho textu

Init:    mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ kontrola pamˆti

         cmp       sp,offset Zasob          ; je dost pamˆti ?
         jae       Init2                    ; je dost pamˆti

; ------ chyba - nedostatek pamˆti

Init1:   mov       dx,offset MemTxt
Init11:  mov       ah,9
         int       21h                      ; chyba - nedostatek pamˆti
         mov       ax,4c01h
         int       21h

; ------ zmen¨en¡ bloku programu na minimum

Init2:   mov       sp,offset Zasob          ; p©edefinov n¡ z sobn¡ku
         mov       bx,offset(Zasob-Start+10fh)/16 ; velikost programu (odstavc–)
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ aloka‡n¡ho bloku
         jc        Init1                    ; nˆjak  chyba

; ------ vytvo©en¡ datov‚ho bloku pro ud losti

         mov       bx,0fffh                 ; velikost bloku 65 KB
         mov       ah,48h
         int       21h                      ; vytvo©en¡ datov‚ho bloku
;         jnc       Init3                    ; blok vytvo©en OK
;         mov       ah,48h
;         int       21h                      ; vytvo©en¡ men¨¡ho bloku
         jc        Init1                    ; chyba - nedostatek pamˆti
;Init3:   cmp       bx,200h                  ; minim ln¡ velikost bufferu
;         jb        Init1                    ; nedostatek pamˆti
         mov       ds:[DatSegm],ax          ; adresa datov‚ho bloku
;         mov       cl,4                     ; po‡et rotac¡
;         shl       bx,cl                    ; p©evod velikosti na bajty
;         dec       bx                       ; 1 bajt rezerva
;         mov       ds:[DatSize],bx          ; velikost datov‚ho bloku

; ------ rozbor p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       ch,0
         mov       cl,ds:[si-1]             ; po‡et znak– v p©¡kaz. © dku
         cld
         mov       dx,offset HlpTxt         ; n povˆda
Init4:   jcxz      Init5                    ; konec p©¡kazov‚ho © dku
         lodsb                              ; na‡ten¡ znaku z p©¡kaz. © dku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al,13                    ; konec p©¡kaz. © dku ?
         je        Init5                    ; konec p©¡kazov‚ho © dku
         cmp       al," "                   ; oddˆlovac¡ znak ?
         jbe       Init4                    ; oddˆlovac¡ znak se ignoruje
         cmp       al,"/"                   ; oddˆlova‡ parametr– ?
         je        Init4                    ; oddˆlova‡ parametr– se ignoruje
         call      UpCase                   ; p©evod na velk‚ p¡smeno
         cmp       al,"!"                   ; odinstalov n¡ ?
         jne       Init41                   ; nen¡ odinstalov n¡
         or        byte ptr ds:[Param],1    ; po‘adov no odinstalov n¡
         jmp       short Init4              ; dal¨¡ znak

Init41:  cmp       al,"I"                   ; instalace bez interakt. m¢du ?
         jne       Init42                   ; nen¡ instalace bez interakt.
         or        byte ptr ds:[Param],2    ; po‘adavek instalace
         jmp       short Init4              ; dal¨¡ znak

Init42:  cmp       al,"D"                   ; je zpˆtn˜ p©eklad ?
         jne       Init43                   ; nen¡ zpˆtn˜ p©eklad
         or        byte ptr ds:[Param2],2   ; po‘adavek zpˆtn‚ho p©ekladu
         jmp       short Init4

Init43:  cmp       al,"A"                   ; je p©eklad ?
         jne       Init11                   ; chyba zad n¡
         or        byte ptr ds:[Param2],1   ; po‘adavek p©ekladu
         jmp       short Init4

; ------ p©eklad datov‚ho souboru

Init5:   test      byte ptr ds:[Param2],1+2 ; je p©eklad ?
         jz        Init5x9                  ; nen¡ p©eklad
         call      SoubInit                 ; inicializace datov‚ho souboru
         test      byte ptr ds:[Param2],2   ; je zpˆtn˜ p©eklad ?
         jnz       Init5x1                  ; je zpˆtn˜ p©eklad
         call      Assm                     ; p©eklad souboru
         jmp       short Init5x2
Init5x1: call      DAss                     ; zpˆtn˜ p©eklad souboru
Init5x2: mov       al,0                     ; OK
         jnc       Init5x3
         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho hl ¨en¡
         mov       al,1                     ; chyba p©ekladu
Init5x3: mov       ah,4ch
         int       21h                      ; konec programu

; ------ test instalace programu

Init5x9: mov       ax,257ah                 ; identifik tor 1
         mov       bx,8a3dh                 ; identifik tor 2
         int       16h                      ; test instalace programu KALEND
         push      cs
         pop       ds
         cmp       bx,4a76h                 ; je v˜stupn¡ idnetifik tor ?
         je        Init50                   ; program je nainstalov n
         push      cs
         pop       es                       ; ES <- CS (nen¡ nainstalov n)
         or        byte ptr ds:[Param],40h  ; p©¡znak prvn¡ instalace programu
Init50:  mov       ds:[RezSegm],es          ; rezidentn¡ segment

; ------ test, zda je prvn¡ instalace

         test      byte ptr ds:[Param],40h  ; je prvn¡ instalace ?
         jz        Init502                  ; nen¡ prvn¡ instalace

; ------ vymaz n¡ tabulky bud¡ku

         push      cs
         pop       es
         mov       di,ADRTIME               ; adresa tabulky ud lost¡
         mov       cx,MAXTIME               ; po‡et polo‘ek v tabulce ud lost¡
         mov       ax,-1                    ; nulovac¡ slovo
         cld
         rep       stosw                    ; vymaz n¡ tabulky

; ------ £schova adres INT

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx   ; £schova INT 08h
         mov       word ptr ds:[Old08+2],es
         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx   ; £schova INT 09h
         mov       word ptr ds:[Old09+2],es
         mov       ax,3516h
         int       21h
         mov       word ptr ds:[Old16],bx   ; £schova INT 16h
         mov       word ptr ds:[Old16+2],es

; ------ instalace INT

         mov       dx,offset INT08
         mov       ax,2508h
         int       21h                      ; instalace INT 08h
         mov       dx,offset INT09
         mov       ax,2509h
         int       21h                      ; instalace INT 09h
         mov       dx,offset INT16
         mov       ax,2516h
         int       21h                      ; instalace INT 16h

; ------ inicializace datov‚ho souboru

Init502: call      SoubInit                 ; inicializace datov‚ho souboru

; ------ aktualizace bud¡ku

         call      AktBud                   ; aktualizace bud¡ku

; ------ nen¡-li interaktivn¡ m¢d, je hned konec

         test      byte ptr ds:[Param],2    ; je interaktivn¡ m¢d ?
         jz        Init51
         jmp       Konec1                   ; nen¡ interaktivn¡ m¢d - konec

; ------ inicializace videom¢du

Init51:  call      DetCard                  ; detekce videokarty
         call      InitVMod                 ; inicializace videom¢du
         mov       ah,0
         mov       al,ds:[Radku]            ; po‡et © dk– celkem
         sub       al,3                     ; ode‡ten¡ okraj– a n povˆdy
         mov       byte ptr ds:[DiarRad],al ; po‡et © dk– na di ©
         sub       al,9+1                   ; ode‡ten¡ kalend ©e a okraje
         mov       byte ptr ds:[NotRad],al  ; po‡et vnit©n¡ch © dk– pozn mky

; ------ vytvo©en¡ bufferu pro obrazovku

         mov       al,80                    ; po‡et znak– na © dek
         mul       byte ptr ds:[Radku]      ; v˜po‡et d‚lky videostr nky
         mov       cl,3
         mov       bx,ax                    ; d‚lka videostr nky (slov)
         add       bx,7                     ; zaokrouhlen¡
         shr       bx,cl                    ; p©epo‡et na odstavce
         mov       ah,48h
         int       21h                      ; vytvo©en¡ bufferu obrazovky
         jnc       Init52                   ; operace OK
         mov       ah,48h
         int       21h                      ; alespo¤ men¨¡ blok
         jnc       Init52
         xor       bx,bx
         xor       ax,ax

; ------ £schova obsahu obrazovky

Init52:  shl       bx,cl                    ; p©epo‡et na slova
         push      ds
         mov       ds:[ObrSegm],ax          ; adresa bufferu
         mov       ds:[ObrSize],bx          ; £schova velikosti videostr nky
         mov       cx,bx                    ; d‚lka videostr nky (slov)
         xor       di,di                    ; ukl dac¡ adresa
         mov       es,ax                    ; adresa bufferu
         lds       si,ds:[AdrVRAM]          ; adresa videopamˆti
         cld
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds

; ------ £schova kurzoru

         call      GetKurz                  ; poskytnut¡ pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ oprava barev pro monochromatick˜ displej

         cmp       byte ptr ds:[AdrVRAM+3],0b8h
         je        Init54

         mov       byte ptr ds:[Barva2],70h
         mov       byte ptr ds:[Barva3],7
         mov       byte ptr ds:[Barva4],0fh
         mov       byte ptr ds:[Barva32],7
         mov       byte ptr ds:[Barva42],0fh
         mov       byte ptr ds:[Barva5],7

; ------ zji¨tˆn¡ aktu ln¡ho data

Init54:  mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data
         mov       ds:[ADen],dl             ; aktu ln¡ den
         mov       ds:[AMesic],dh           ; aktu ln¡ mˆs¡c
         mov       ds:[ARok],cx             ; aktu ln¡ rok
         mov       bx,dx                    ; den a mˆs¡c
         call      KonvDatN                 ; konverze na absolutn¡ den
         mov       word ptr ds:[Den],ax     ; den LOW
         mov       word ptr ds:[Den+2],dx   ; den HIGH

; ------ zobrazen¡ a obsluha kalend ©e

         jmp       Kalend                   ; obsluha kalend ©e

; -----------------------------------------------------------------------------
;        ukon‡en¡ programu - interaktivn¡ m¢d
; -----------------------------------------------------------------------------

Konec:   call      PopScr                   ; n vrat obsahu obrazovky

; ------ zru¨en¡ obrazov‚ho segmentu

         mov       ax,ds:[ObrSegm]
         or        ax,ax
         jz        Konec1                   ; nen¡ vytvo©en
         mov       es,ax
         mov       ah,49h
         int       21h                      ; zru¨en¡ bufferu obrazovky

; -----------------------------------------------------------------------------
;        konec programu - nen¡ interaktivn¡ m¢d
; -----------------------------------------------------------------------------

; ------ zru¨en¡ aloka‡n¡ho bloku prost©ed¡

Konec1:  mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; zru¨en¡ bloku prost©ed¡

; ------ zru¨en¡ datov‚ho bloku

         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       ah,49h
         int       21h                      ; zru¨en¡ datov‚ho segmentu

; ------ po‘aduje se odinstalov n¡ programu

         test      byte ptr ds:[Param],1    ; po‘aduje se odinstalov n¡ ?
         jz        Konec3                   ; nen¡ odinstalov n¡ programu
         test      byte ptr ds:[Param],40h  ; je prvn¡ instalace programu ?
         jnz       Konec22                  ; je prvn¡ instalace programu

; ------ odinstalov n¡ programu v pamˆti

         call      TestInst                 ; test mo‘nosti odinstalov n¡
         jnc       Konec21                  ; program je mo‘no odinstalovat OK

                                          ;* chyba - nelze odinstalovat
         mov       dx,offset DInsTxt2       ; text - nelze odinstalovat
         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho hl ¨en¡
         mov       ax,4c01h
         int       21h

                                          ;* odinstalov n¡ rezidentn¡ho programu
Konec21: call      DeInst                   ; odinstalov n¡ vektor– p©eru¨en¡
         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku programu
         mov       dx,offset DInsTxt        ; text - odinstalov n OK
         mov       ah,9
         int       21h
         mov       ax,4c00h
         int       21h

                                          ;* odinstalov n¡ tohoto programu
Konec22: call      DeInst                   ; odinstalov n¡ programu
         mov       ax,4c00h
         int       21h

; ------ instalace programu do pamˆti

Konec3:  test      byte ptr ds:[Param],40h  ; je prvn¡ instalace programu ?
         jnz       Konec4                   ; je prvn¡ instalace programu
         mov       ax,4c00h
         int       21h

Konec4:  mov       dx,offset Init
         int       27h                      ; instalace programu

; -----------------------------------------------------------------------------
;        test instalace, zda lze program odinstalovat (CY=nelze)
; -----------------------------------------------------------------------------

TestInst PROC      NEAR

         mov       dx,ds:[RezSegm]          ; rezidentn¡ segment

; ------ kontrola INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       ax,es
         cmp       ax,dx                    ; souhlas¡ adresa ?
         jne       TestIns8                 ; adresa nesouhlas¡

; ------ kontrola INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       ax,es
         cmp       ax,dx                    ; souhlas¡ adresa ?
         jne       TestIns8                 ; adresa nesouhlas¡

; ------ kontrola INT 16h

         mov       ax,3516h
         int       21h                      ; poskytnut¡ adresy INT 16h
         mov       ax,es
         cmp       ax,dx                    ; souhlas¡ adresa ?
         je        TestIns9                 ; adresa souhlas¡ OK

TestIns8:stc
TestIns9:ret

TestInst ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu
; -----------------------------------------------------------------------------

DeInst   PROC      NEAR

         push      ds
         mov       es,ds:[RezSegm]          ; rezidentn¡ segment

; ------ n vrat INT 08h

         lds       dx,es:[OLD08]
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h

; ------ n vrat INT 09h

         lds       dx,es:[OLD09]
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h

; ------ n vrat INT 16h

         lds       dx,es:[OLD16]
         mov       ax,2516h
         int       21h                      ; n vrat adresy INT 16h

         pop       ds
         ret

DeInst   ENDP

; -----------------------------------------------------------------------------
;        aktualizace bud¡ku
; -----------------------------------------------------------------------------

AktBud   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ zji¨tˆn¡ aktu ln¡ho data

         mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data
         mov       ds:[ADen],dl             ; aktu ln¡ den
         mov       ds:[AMesic],dh           ; aktu ln¡ mˆs¡c
         mov       ds:[ARok],cx             ; aktu ln¡ rok
         mov       bx,dx                    ; den a mˆs¡c
         call      KonvDatN                 ; konverze na absolutn¡ den

; ------ nalezen¡ aktu ln¡ho dne

         call      SrcDen                   ; nalezen¡ dne
         jnc       AktBud2                  ; den nalezen OK
         xor       di,di                    ; p©¡znak - nen¡ den
AktBud2: mov       ds:[ADenAdr],di          ; adresa aktu ln¡ho dne

; ------ nalezen¡ dal¨¡ho dne

         add       ax,1                     ; ‡¡slo dal¨¡ho dne
         adc       dx,0                     ; p©enos
         call      SrcDen                   ; nalezen¡ dal¨¡ho dne
         jnc       AktBud3                  ; den nalezen OK
         xor       di,di                    ; p©¡znak - nen¡ den
AktBud3: mov       ds:[ADenAdr2],di         ; adresa dal¨¡ho dne

; ------ zji¨tˆn¡ aktu ln¡ho ‡asu (v minut ch absolutnˆ)

         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[46ch]             ; ‡¡ta‡ ‡asu LOW
         mov       dl,es:[46ch+2]           ; ‡¡ta‡ ‡asu HIGH
         mov       dh,0
         mov       cl,4                     ; po‡et rotac¡
         shl       dx,cl                    ; vy¨¨¡ slovo * 16
         mov       bx,ax                    ; ni‘¨¡ slovo ‡¡ta‡e ‡asu
         mov       cl,12
         shr       bx,cl                    ; nejvy¨¨¡ 4 bity ni‘¨¡ho slova
         add       dx,bx                    ; p©enos 4 bit– do vy¨¨¡ho slova
         mov       cl,4
         shl       ax,cl                    ; ni‘¨¡ slovo * 16
         mov       bx,17478
         div       bx                       ; ‡¡ta‡ ‡asu / 1092.375
         mov       dx,ax                    ; aktu ln¡ ‡as v minut ch

; ------ dek¢dov n¡ aktu ln¡ho dne

         mov       di,ADRTIME               ; tabulka ‡as–
         mov       es,ds:[RezSegm]          ; rezidentn¡ segment
         mov       si,ds:[ADenAdr]          ; adresa aktivn¡ho dne
         push      ds
         mov       ds,ds:[DatSegm]          ; datov˜ segment
         or        si,si                    ; je aktivn¡ den definov n ?
         jz        AktBud6                  ; aktivn¡ den nen¡ definov n
         mov       bx,si                    ; adresa aktivn¡ho dne
         add       bx,ds:[si]               ; adresa konce definice dne
         add       si,5                     ; adresa prvn¡ pozn mky
         cld
AktBud4: cmp       si,bx                    ; jsou v¨echny pozn mky ?
         jae       AktBud6                  ; jsou ji‘ v¨echny pozn mky
         call      AktBGet                  ; poskytnut¡ ‡asu pro bud¡k
         jc        AktBud5                  ; neplatn˜ ‡as bud¡ku
         cmp       ax,dx                    ; je pozdˆj¨¡ ‡as OK ?
         jle       AktBud5                  ; ‡as se nebude ukl dat
         cmp       di,ADRTIME0              ; je ji‘ konec tabulky ?
         jae       AktBud6                  ; je konec tabulky
         stosw                              ; ulo‘en¡ ‡asu bud¡ku
AktBud5: lodsb                              ; d‚lka pozn mky
         mov       ah,0
         add       si,ax                    ; adresa dal¨¡ pozn mky
         jnc       AktBud4                  ; dal¨¡ pozn mka
AktBud6: pop       ds

; ------ dek¢dov n¡ dal¨¡ho dne

         mov       si,ds:[ADenAdr2]         ; adresa dal¨¡ho dne
         push      ds
         mov       ds,ds:[DatSegm]          ; datov˜ segment
         or        si,si                    ; je aktivn¡ den definov n ?
         jz        AktBud66                 ; aktivn¡ den nen¡ definov n
         mov       bx,si                    ; adresa aktivn¡ho dne
         add       bx,ds:[si]               ; adresa konce definice dne
         add       si,5                     ; adresa prvn¡ pozn mky
         cld
AktBud64:cmp       si,bx                    ; jsou v¨echny pozn mky ?
         jae       AktBud66                 ; jsou ji‘ v¨echny pozn mky
         call      AktBGet                  ; poskytnut¡ ‡asu pro bud¡k
         jc        AktBud65                 ; neplatn˜ ‡as bud¡ku
         cmp       ax,dx                    ; je d©¡vˆj¨¡ ‡as OK ?
         jge       AktBud65                 ; ‡as se nebude ukl dat
         cmp       di,ADRTIME0              ; je ji‘ konec tabulky ?
         jae       AktBud66                 ; je konec tabulky
         or        ax,ax
         jns       AktBd644
         add       ax,24*60
AktBd644:stosw                              ; ulo‘en¡ ‡asu bud¡ku
AktBud65:lodsb                              ; d‚lka pozn mky
         mov       ah,0
         add       si,ax                    ; adresa dal¨¡ pozn mky
         jnc       AktBud64                 ; dal¨¡ pozn mka
AktBud66:pop       ds

; ------ vymaz n¡ zbytku tabulky

         mov       cx,ADRTIME0
         sub       cx,di
         jbe       AktBud9
         shr       cx,1                     ; d‚lka zbytku tabulky (slov)
         mov       ax,-1                    ; nulovac¡ slovo
         rep       stosw                    ; vymaz n¡ zbytku tabulky

; ------ n vrat registr–

AktBud9: pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

AktBud   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ ‡asu pro bud¡k
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel definice dne
; VSTUP:AX=‡as bud¡ku
;        CY=nen¡ bud¡k
; -----------------------------------------------------------------------------

AktBGet  PROC      NEAR

         lodsw                              ; ‡as akce
         mov       cl,6                     ; po‡et rotac¡
         shr       ax,cl                    ; rotace hodiny na m¡sto
         and       al,31                    ; hodina
         mov       ah,60                    ; po‡et minut na hodinu
         mul       ah                       ; p©epo‡et hodiny na minuty
         mov       cx,ds:[si-2]             ; ‡as akce
         and       cl,3fh                   ; minuta
         add       al,cl                    ; p©i‡ten¡ minuty
         adc       ah,0                     ; p©enos HIGH
         mov       cl,11-8                  ; po‡et rotac¡
         shr       ch,cl                    ; bud¡k
         cmp       ch,31                    ; je bud¡k zapnut ?
         stc                                ; p©¡znak vypnut¡ bud¡ku
         je        AktBGet9                 ; bud¡k je vypnut
         sub       al,ch                    ; ode‡ten¡ ‡asu bud¡ku
         sbb       ah,0                     ; p©enos HIGH
AktBGet5:clc                                ; p©¡znak operace OK
AktBGet9:ret

AktBGet  ENDP

; -----------------------------------------------------------------------------
;        zpˆtn˜ p©eklad souboru KALEND.DAT do textov‚ho tvaru KALEND.ASC
; -----------------------------------------------------------------------------

DAss     PROC      NEAR

; ------ vytvo©en¡ v˜stupn¡ho souboru

         mov       dx,offset SoubAsc        ; jm‚no v˜stupn¡ho souboru
         xor       cx,cx
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         jnc       DAss1
         jmp       DAss8                    ; chyba
DAss1:   mov       ds:[DiskIdnt],ax         ; identifik tor souboru

; ------ p©¡prava k z pisu pozn mek

         mov       ds,ds:[DatSegm]          ; datov˜ segment ud lost¡
         mov       si,8                     ; za‡ tek prvn¡ pozn mky
         mov       di,ds:[si-2]             ; offset konec pozn mek
         add       di,6                     ; adresa konce pozn mek

; ------ z pis pozn mek

DAss2:   cmp       si,di                    ; je ji‘ konec ?
         jae       DAss3                    ; konec pozn mek
         mov       al," "
         call      DAsChr                   ; oddˆlovac¡ mezera
         jc        DAss7
         call      DAsTxt                   ; z pis textu pozn mky
         jc        DAss7
         jmp       short DAss2              ; z pis dal¨¡ pozn mky

; ------ nalezen¡ prvn¡ho dne

DAss3:   push      ds
         push      cs
         pop       ds
         xor       ax,ax                    ; hledan˜ den LOW
         xor       dl,dl                    ; hledan˜
         call      SrcDen
         pop       ds
         jnc       DAss34

; ------ nalezen¡ dal¨¡ho dne

DAss32:  push      ds
         push      cs
         pop       ds
         call      NxtDen                   ; dal¨¡ den
         pop       ds
         cmc
         jnc       DAss7                    ; konec

; ------ £schova ‡¡sla dne

DAss34:  mov       bp,ax
         mov       ah,dl

; ------ p©¡prava ‡¡sla dne

DAss4:   push      ax

         mov       si,di                    ; adresa definice dne
         mov       cx,ds:[si]               ; offset konec
         mov       ax,ds:[si+2]             ; ‡¡slo dne LOW
         mov       dl,ds:[si+4]             ; ‡¡slo dne HIGH
         add       di,cx                    ; adresa konce dne
         push      ds
         push      cs
         pop       ds
         mov       dh,0
         call      KonvNDat                 ; konverze abs. dne na datum
         pop       ds

         pop       ax

         add       si,5
         xor       dx,dx                    ; ‡as

; ------ z pis © dku (DX=‡as, CX=rok, BH=mˆs¡c, BL=den, SI=polo‘ka, DI=konec)

                                          ;* datum
DAss5:   call      DAsDen                   ; z pis ozna‡en¡ dne
         jc        DAss7
         call      DAsSpc                   ; oddˆlovac¡ mezera
         jc        DAss7

                                          ;* ‡as
         mov       al,"*"                   ; p©¡znak pokra‡ov n¡ pozn mky
         cmp       byte ptr ds:[si],0ffh    ; je pokra‡ov n¡ pozn mky ?
         je        DAss52                   ; je pokra‡ov n¡ pozn mky
         mov       al," "                   ; oddˆlova‡ pozn mky
         mov       dx,ds:[si]               ; nov˜ ‡as
DAss52:  call      DAsTim                   ; z pis ozna‡en¡ ‡asu
         jc        DAss7
         inc       si
         inc       si                       ; adresa textu
         call      DAsChr
         jc        DAss7

                                          ;* text pozn mky
         call      DAsTxt                   ; zobrazen¡ textu pozn mky
         jc        DAss7

; ------ p©¡prava dal¨¡ pozn mky

         cmp       si,di                    ; konec ?
         jb        DAss5                    ; dal¨¡ pozn mka

         mov       dl,ah
         mov       ax,bp

         jmp       short DAss32             ; dal¨¡ den

; ------ uzav©en¡ souboru

DAss7:   push      cs
         pop       ds
         jc        DAss75

         mov       cx,ds:[DiskBNum]         ; po‡et bajt– v bufferu
         jcxz      DAss75
         mov       ah,40h
         mov       dx,offset DiskBuf
         mov       bx,ds:[DiskIdnt]         ; idnetifik tor souboru
         int       21h                      ; z pis zbytku bufferu

DAss75:  pushf
         mov       ah,3eh
         int       21h
         popf
         jnc       DAss9

DAss8:   mov       dx,offset WritTxt        ; text - chyba z pisu
         stc

DAss9:   push      cs
         pop       ds
         ret

DAss     ENDP

; -----------------------------------------------------------------------------
;        z pis dne RRRR/MM/DD (RRRR=CX, MM=BH, DD=BL)
; -----------------------------------------------------------------------------

DAsDen   PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ dek¢dov n¡ roku

         mov       ax,cx                    ; rok
         call      DAs4Nm                   ; dek¢dov n¡ roku
         jc        DAsDen9                  ; chyba

; ------ oddˆlova‡ mezi mˆs¡cem a rokem

         mov       al,"."
         call      DAsChr
         jc        DAsDen9                  ; chyba

; ------ dek¢dov n¡ ‡¡sla mˆs¡ce

         mov       al,bh                    ; mˆs¡c
         call      DAsNm                    ; dek¢dov n¡ mˆs¡ce
         jc        DAsDen9                  ; chyba

; ------ oddˆlova‡ mezi dnem a mˆs¡cem

         mov       al,"."
         call      DAsChr
         jc        DAsDen9                  ; chyba

; ------ dek¢dov n¡ dne v mˆs¡ci

         mov       al,bl                    ; den
         call      DAsNm                    ; dek¢dov n¡ dne

; ------ n vrat registr–

DAsDen9: pop       ax
         ret

DAsDen   ENDP

; -----------------------------------------------------------------------------
;        z pis ‡asu HH:MM (DX=‡as)
; -----------------------------------------------------------------------------

DAsTim   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ zobrazen¡ hodiny

         mov       cl,6
         mov       ax,dx
         shr       ax,cl
         and       al,1fh
         call      DAsNm                    ; zobrazen¡ hodiny
         jc        DAsTim9

; ------ oddˆlova‡

         mov       al,":"
         call      DAsChr
         jc        DAsTim9

; ------ minuta

         mov       al,dl
         and       al,3fh
         call      DAsNm                    ; zobrazen¡ hodiny
         jc        DAsTim9

; ------ zobrazen¡ bud¡ku

         mov       al,dh
         mov       cl,3
         shr       al,cl
         and       al,1fh                   ; bud¡k
         cmp       al,1fh
         jne       DAsTim3

         call      DAsSpc
         jc        DAsTim9
         call      DAsSpc
         jc        DAsTim9
         call      DAsSpc
         jmp       short DAsTim9

DAsTim3: push      ax
         mov       al,"/"
         call      DAsChr
         pop       ax
         jc        DAsTim9
         call      DAsNm

; ------ n vrat registr–

DAsTim9: pop       cx
         pop       ax
         ret

DAsTim   ENDP

; -----------------------------------------------------------------------------
;        z pis ‡¡sla AX (4 ‡¡slice)
; -----------------------------------------------------------------------------

DAs4Nm   PROC      NEAR

         cmp       ax,10000
         jb        DAs4Nm2
         mov       ax,9999
DAs4Nm2: cmp       ax,1000
         jae       DAs4Nm9
         call      DAsNul

         cmp       ax,100
         jae       DAs4Nm9
         call      DAsNul

         cmp       ax,10
         jae       DAs4Nm9
         call      DAsNul

DAs4Nm9: call      DAsNum
         ret

DAs4Nm   ENDP

; -----------------------------------------------------------------------------
;        z pis ‡¡sla AL (2 ‡¡slice)
; -----------------------------------------------------------------------------

DAsNm    PROC      NEAR

         push      ax
         cmp       al,10
         jae       DAsNm22
         call      DAsNul
DAsNm22: mov       ah,0
         call      DAsNum
         pop       ax
         ret

DAsNm    ENDP

; -----------------------------------------------------------------------------
;        z pis ‡¡sla AX
; -----------------------------------------------------------------------------

DAsNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©¡prava registr–

         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic
         mov       bx,10                    ; dˆlitel

; ------ dek¢dov n¡ ‡¡sla

DAsNum1: xor       dx,dx
         div       bx                       ; v˜po‡et jedn‚ ‡¡slice
         add       dl,"0"                   ; korekce na ASCII znak
         push      dx                       ; £schova ‡¡slice
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e ‡¡slic
         or        ax,ax                    ; je ji‘ 0 ?
         jnz       DAsNum1                  ; dek¢dov n¡ dal¨¡ ‡¡slice

; ------ zobrazen¡ ‡¡sla

DAsNum2: pop       ax
         call      DAsChr                   ; z pis znaku
         jc        DAsNum3                  ; chyba
         loop      DAsNum2                  ; dal¨¡ ‡¡slice
         jmp       short DAsNum5

; ------ p©i chybˆ zru¨en¡ ostatn¡ch ‡¡slic

DAsNum3: push      ax
DAsNum4: pop       ax
         loop      DAsNum4

; ------ n vrat registr–

DAsNum5: pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DAsNum   ENDP

; -----------------------------------------------------------------------------
;        z pis konce © dku CR/LF
; -----------------------------------------------------------------------------

DAsCR    PROC      NEAR

         push      ax

         mov       al,13
         call      DAsChr                   ; z pis CR
         jc        DAsCr3

         mov       al,10
         call      DAsChr                   ; z pis LF

DAsCr3:  pop       ax
         ret

DAsCR    ENDP

; -----------------------------------------------------------------------------
;        z pis textu pozn mky DS:SI
; -----------------------------------------------------------------------------

DAsTxt   PROC      NEAR

         push      ax
         push      cx

         mov       ch,0
         mov       cl,ds:[si]               ; d‚lka pozn mky
         inc       si                       ; za‡ tek textu pozn mky
         jcxz      DAsTxt3                  ; pr zdn˜ © dek
DAsTxt2: cld
         lodsb                              ; na‡ten¡ znaku z bufferu
         call      DAsChr                   ; z pis znaku na v˜stup
         jc        DAsTxt5
         loop      DAsTxt2                  ; dal¨¡ znak

DAsTxt3: call      DAsCR                    ; z pis CR/LF

DAsTxt5: pop       cx
         pop       ax
         ret

DAsTxt   ENDP

; -----------------------------------------------------------------------------
;        z pis znaku mezery
; -----------------------------------------------------------------------------

DAsSpc   PROC      NEAR

         push      ax
         mov       al," "
         call      DAsChr
         pop       ax
         ret

DAsSpc   ENDP

; -----------------------------------------------------------------------------
;        z pis znaku nuly
; -----------------------------------------------------------------------------

DAsNul   PROC      NEAR

         push      ax
         mov       al,"0"
         call      DAsChr
         pop       ax
         ret

DAsNul   ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL do diskov‚ho bufferu
; -----------------------------------------------------------------------------

DAsChr   PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ test, zda je buffer ji‘ pln˜

         mov       bx,cs:[DiskBNum]         ; po‡et bajt– v bufferu
         cmp       bx,DiskBSiz              ; je buffer pln˜ ?
         jb        DAsChr4                  ; nen¡ je¨tˆ pln˜

; ------ ulo‘en¡ bufferu na disk

         push      ax
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds
         mov       dx,offset DiskBuf        ; buffer
         mov       cx,bx                    ; po‡et bajt– v bufferu
         mov       ah,40h
         mov       bx,ds:[DiskIdnt]         ; identifik tor souboru
         int       21h                      ; z pis bufferu na disk
         jc        DAsChr3                  ; chyba z pisu
         cmp       ax,cx                    ; bylo zaps no v¨e ?

DAsChr3: pop       ds
         pop       dx
         pop       cx
         pop       ax
         jc        DAsChr5

; ------ ulo‘en¡ bajtu do bufferu

         xor       bx,bx
DAsChr4: mov       cs:[bx+DiskBuf],al       ; ulo‘en¡ znaku
         inc       bx
         mov       cs:[DiskBNum],bx         ; nov˜ po‡et znak–
         clc

; ------ n vrat registr–

DAsChr5: pop       bx
         ret

DAsChr   ENDP

; -----------------------------------------------------------------------------
;        p©eklad KALEND.ASC do KALEND.DAT
; -----------------------------------------------------------------------------
;þ
Assm     PROC      NEAR

         push      ds
         pop       es

; ------ inicilalizace souboru v bufferu

         push      es
         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,6
         cld
         mov       ax,2
         stosw                              ; offset za‡ tku definice dn–
         mov       ds:[NotEnd],di           ; adresa konce pozn mek
         xor       ax,ax
         stosw                              ; ozna‡en¡ konce dat
         mov       word ptr ds:[NotNum],0   ; nen¡ © dek pozn mky
         mov       ds:[DatNum],di           ; po‡et bajt– v bufferu
         pop       es

; ------ otev©en¡ vstupn¡ho souboru

         mov       dx,offset SoubAsc        ; jm‚no vstupn¡ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ vstupn¡ho souboru
         mov       dx,offset ReadTxt
         jc        Assm9
         mov       ds:[DiskIdnt],ax         ; identifik tor souboru

; ------ na‡ten¡ jednoho © dku

Assm2:   call      AssmLine                 ; ‡ten¡ jednoho © dku
         jc        Assm7                    ; konec souboru

; ------ rozli¨en¡ typu © dku podle prvn¡ho znaku

         mov       si,offset EditBuf        ; edita‡n¡ buffer
         cld
         lodsb                              ; prvn¡ znak textu

; ------ dek¢dov n¡ © dku pozn mky

         cmp       al," "                   ; je pozn mka ?
         jne       Assm4                    ; nen¡ pozn mka
         call      AssmNot                  ; ulo‘en¡ © dku pozn mky
         jmp       short Assm2              ; dek¢dov n¡ dal¨¡ho © dku

; ------ dek¢dov n¡ © dku di ©e

Assm4:   call      AssmDia                  ; ulo‘en¡ © dku di ©e
         jmp       short Assm2

; ------ vytvo©en¡ souboru

Assm7:   mov       dx,offset Soubor         ; jm‚no datov‚ho souboru
         xor       cx,cx
         mov       ah,3ch
         int       21h                      ; otev©en¡ souboru
         mov       dx,offset WritTxt
         jc        Assm9                    ; chyba - soubor nelze vytvo©it
         mov       bx,ax                    ; identifik tor souboru

; ------ z pis souboru

         push      ds
         xor       dx,dx
         mov       cx,ds:[DatNum]           ; po‡et bajt– v souboru
         mov       ah,40h
         mov       ds,ds:[DatSegm]          ; segment dat
         int       21h                      ; ulo‘en¡ souboru
         pop       ds
         mov       dx,offset WritTxt
         jc        Assm9                    ; chyba - soubor nelze vytvo©it
         cmp       ax,cx
         jb        Assm9

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h
         clc
Assm9:   ret

Assm     ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ © dku di ©e
; -----------------------------------------------------------------------------

AssmDia  PROC      NEAR

; ------ p©¡prava registr–

         mov       si,offset EditBuf        ; edita‡n¡ buffer
         mov       bx,101h                  ; p©¡prava dne a mˆs¡ce
         cld

; ------ dek¢dov n¡ roku

         call      AssmNum                  ; dek¢dov n¡ ‡¡sla roku
         mov       cx,ax                    ; na‡ten¡ rok
         cmp       byte ptr ds:[si],"."
         jne       AssmDia5
         inc       si

; ------ dek¢dov n¡ mˆs¡ce

         call      AssmNum                  ; dek¢dov n¡ ‡¡sla mˆs¡ce
         mov       bh,al                    ; ‡¡slo mˆs¡ce
         cmp       byte ptr ds:[si],"."
         jne       AssmDia5
         inc       si

; ------ dek¢dov n¡ dne

         call      AssmNum                  ; dek¢dov n¡ ‡¡sla dne
         mov       bl,al                    ; ‡¡slo dne

; ------ inicializace parametr– dne

AssmDia5:call      KonvDatN                 ; konverze data na absolutn¡ den
         mov       word ptr ds:[Den],ax     ; den LOW
         mov       word ptr ds:[Den+2],dx   ; den HIGH
         call      SrcDen                   ; nalezen¡ dne
         mov       ds:[ADenAdr],di          ; adresa aktu ln¡ho dne
         mov       ds:[DenAdr],di           ; adresa nalezen‚ho dne
         call      InitDiar                 ; inicializace parametr– dne

; ------ vypu¨tˆn¡ data

AssmDia6:mov       cx,si
         mov       si,offset EditBuf
         sub       cx,si
         jbe       AssmDi64
AssmDi62:call      AssmDel
         loop      AssmDi62

; ------ vypu¨tˆn¡ oddˆlovac¡ mezery

AssmDi64:cmp       byte ptr ds:[si]," "
         jne       AssmDi65
         call      AssmDel
         jmp       short AssmDi64

; ------ oprava £daje ‡asu

AssmDi65:call      AssmTst                  ; zaji¨tˆn¡ 2 ‡¡slic - hodina
         mov       al,":"
         call      AssmTCh                  ; zaji¨tˆn¡ znaku ":"
         call      AssmTst                  ; zaji¨tˆn¡ 2 ‡¡slic - minuta

         cmp       byte ptr ds:[si],"/"
         jne       AssmDi66
         inc       si
         call      AssmTst                  ; 2 ‡¡slice bud¡ku
         jmp       short AssmDi68

AssmDi66:mov       al," "
         call      AssmTCh                  ; zaji¨tˆn¡ 1. mezery
         call      AssmTCh                  ; zaji¨tˆn¡ 2. mezery
         call      AssmTCh                  ; zaji¨tˆn¡ 3. mezery

; ------ oprava, je-li to pozn mka

AssmDi68:cmp       byte ptr ds:[si],"*"
         jne       AssmDi82
         mov       ax,"  "
         mov       ds:[si-8],ax
         mov       ds:[si-6],ax
         mov       ds:[si-4],ax
         mov       ds:[si-2],ax
         mov       ds:[si],al

AssmDi82:mov       al," "
         call      AssmTCh                  ; zaji¨tˆn¡ mezery

; ------ ulo‘en¡ © dku do souboru

AssmDi84:mov       cx,ds:[DiaNum]
         mov       ds:[DiaAkt],cx           ; aktivn¡ polo‘ka
         call      CreatDia                 ; vytvo©en¡ nov‚ho © dku
         jc        AssmDia9                 ; nedostatek pamˆti
         call      StorDiar                 ; ulo‘en¡ © dku do definice
AssmDia9:ret

AssmDia  ENDP

; -----------------------------------------------------------------------------
;        zaji¨tˆn¡ znaku AL
; -----------------------------------------------------------------------------

AssmTCh  PROC      NEAR

         cmp       al,ds:[si]
         je        AssmTCh3
         call      AssmIns
AssmTCh3:inc       si
         ret

AssmTCh  ENDP

; -----------------------------------------------------------------------------
;        normalizace 2 ‡¡slic SI
; -----------------------------------------------------------------------------

AssmTst  PROC      NEAR

         mov       al,ds:[si]
         sub       al,"0"
         cmp       al,10
         jb        AssmTst2
         mov       al,"0"
         call      AssmIns

AssmTst2:mov       al,ds:[si+1]
         sub       al,"0"
         cmp       al,10
         jb        AssmTst3
         mov       al,"0"
         call      AssmIns

AssmTst3:inc       si
         inc       si
         ret

AssmTst  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ ‡¡sla
; -----------------------------------------------------------------------------

AssmNum  PROC      NEAR

         push      bx
         push      dx

         xor       bx,bx
AssmNum1:cmp       byte ptr ds:[si],"0"
         jb        AssmNum9
         cmp       byte ptr ds:[si],"9"
         ja        AssmNum9
         mov       ax,10
         mul       bx
         xchg      ax,bx
         cld
         lodsb
         sub       al,"0"
         mov       ah,0
         add       bx,ax
         jmp       short AssmNum1

AssmNum9:xchg      ax,bx
         pop       dx
         pop       bx
         ret

AssmNum  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ © dku pozn mky
; -----------------------------------------------------------------------------

AssmNot  PROC      NEAR

; ------ £schova registr–

         push      si

; ------ vypu¨tˆn¡ £vodn¡ mezery

         mov       si,offset EditBuf
         call      AssmDel

; ------ ulo‘en¡ pozn mky do souboru

         mov       si,ds:[NotNum]           ; po‡et © dk–
         mov       ds:[NotAkt],si           ; je to nov˜ aktivn¡ © dek
         call      StorNot                  ; ulo‘en¡ pozn mky do souboru

; ------ n vrat registr–

         pop       si
         ret

AssmNot  ENDP

; -----------------------------------------------------------------------------
;        vlo‘en¡ znaku AL do bufferu SI
; -----------------------------------------------------------------------------

AssmIns  PROC      NEAR

         push      cx
         push      si
         push      di

         mov       di,offset EditBuf + 79
         mov       cx,di
         sub       cx,si
         jbe       AssmIns9
         mov       si,di
         dec       si
         std
         rep       movsb
         stosb

AssmIns9:pop       di
         pop       si
         pop       cx
         ret

AssmIns  ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ znaku z bufferu SI
; -----------------------------------------------------------------------------

AssmDel  PROC      NEAR

         push      cx
         push      si
         push      di

         mov       cx,offset EditBuf + 80
         sub       cx,si
         mov       di,si
         inc       si
         cld
         rep       movsb

         pop       di
         pop       si
         pop       cx
         ret

AssmDel  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho © dku textu do edita‡n¡ho bufferu
; -----------------------------------------------------------------------------

AssmLine PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di

; ------ inicializa‡n¡ vymaz n¡ bufferu

         mov       di,offset EditBuf        ; edita‡n¡ buffer
         mov       cx,80/2                  ; d‚lka bufferu (slov)
         mov       ax,"  "                  ; mazac¡ slovo
         cld
         rep       stosw                    ; vymaz n¡ bufferu

; ------ p©¡prava registr–

         mov       cx,80                    ; max. d‚lka © dku
         sub       di,cx                    ; za‡ tek bufferu

; ------ na‡ten¡ prvn¡ho znaku

AssmLin1:call      AssmCh                   ; na‡ten¡ prvn¡ho znaku
         jc        AssmLin9                 ; nen¡ ‘ dn˜ znak
         cmp       al,10                    ; je pr zdn˜ © dek ?
         je        AssmLin1                 ; pr zdn˜ © dek se ignoruje

; ------ na‡ten¡ textu © dku

AssmLin2:cld
         stosb                              ; ulo‘en¡ znaku do bufferu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jz        AssmLin5                 ; buffer je ji‘ pln˜
         call      AssmCh                   ; na‡ten¡ dal¨¡ho znaku © dku
         jc        AssmLin7                 ; konec textu
         cmp       al,10                    ; konec © dku ?
         je        AssmLin7                 ; konec © dku
         jmp       short AssmLin2           ; ulo‘en¡ znaku

; ------ ignorov n¡ zbytku © dku

AssmLin5:call      AssmCh                   ; na‡ten¡ dal¨¡ho znaku
         jc        AssmLin7                 ; nen¡ dal¨¡ znak
         cmp       al,10
         jne       AssmLin5                 ; vypu¨tˆn¡ textu po LF
AssmLin7:clc

; ------ n vrat registr–

AssmLin9:pop       di
         pop       cx
         pop       ax
         ret

AssmLine ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ znaku z bufferu (CR se ignoruje)
; -----------------------------------------------------------------------------

AssmCh   PROC      NEAR

         push      bx
AssmCh1: mov       bx,ds:[DiskBRd]          ; ‡tec¡ adresa z bufferu
         cmp       bx,ds:[DiskBNum]         ; je dal¨¡ bajt ?
         jb        AssmCh7                  ; je dal¨¡ bajt

         push      ax
         push      cx
         push      dx

         mov       dx,offset DiskBuf
         mov       cx,DiskBSiz
         mov       bx,ds:[DiskIdnt]
         mov       ah,3fh
         int       21h                      ; ‡ten¡ bloku dat ze souboru
         jnc       AssmCh4
         xor       ax,ax
AssmCh4: mov       ds:[DiskBNum],ax         ; nov˜ po‡et bajt– v bufferu
         or        ax,ax                    ; jsou data ?

         pop       dx
         pop       cx
         pop       ax

         stc
         jz        AssmCh9                  ; nejsou dal¨¡ data
         xor       bx,bx                    ; nov  ‡tec¡ adresa

AssmCh7: mov       al,ds:[DiskBuf+bx]       ; znak z bufferu
         inc       bx                       ; zv˜¨en¡ ‡tec¡ adresy
         mov       ds:[DiskBRd],bx          ; nov  ‡tec¡ adresa
         cmp       al,13
         je        AssmCh1                  ; CR se ignoruje
         cmp       al,26
         je        AssmCh1                  ; EOF se ignoruje
         clc
AssmCh9: pop       bx
         ret

AssmCh   ENDP

; -----------------------------------------------------------------------------
;        Obsluha kalend ©e
; -----------------------------------------------------------------------------
;þ
Kalend:  mov       byte ptr ds:[WAkt],1     ; je aktivn¡ kalend ©
         mov       ax,word ptr ds:[Den]     ; aktivn¡ den LOW
         mov       dx,word ptr ds:[Den+2]   ; aktivn¡ den HIGH
         call      SrcDen                   ; nalezen¡ dne v bufferu
         mov       ds:[DenAdr],di           ; adresa nalezen‚ho dne
Kalend03:mov       word ptr ds:[DiaTop],0   ; po‡ te‡n¡ © dek di ©e
         mov       word ptr ds:[DiaAkt],0   ; aktivn¡ © dek di ©e
         call      InitDiar                 ; inicializace parametr– di ©e
         call      DispAll                  ; zobrazen¡ obrazovky

; ------ vstup znaku z kl vesnice

Kalend1: call      InpChr                   ; vstup z kl vesnice

         push      bx
         mov       ax,word ptr ds:[Den]
         mov       dx,word ptr ds:[Den+2]
         call      KonvNDat                 ; konverze na datum
         mov       dx,bx                    ; mˆs¡c a den
         pop       bx

         call      JumpBX                   ; skok na funkci

         dw        4b00h,KalLeft            ; vlevo - o den m‚nˆ
         dw        4d00h,KalRght            ; vpravo - o den v¡ce
         dw        4800h,KalUp              ; nahoru - o t˜den
         dw        5000h,KalDwn             ; dol– - o t˜den
         dw        4700h,KalHome            ; HOME - za‡ tek mˆs¡ce
         dw        4f00h,KalXEnd            ; END - konec mˆs¡ce
         dw        4900h,KalPgUp            ; Page Up - o mˆs¡c m‚nˆ
         dw        5100h,KalPgDn            ; Page Down - o mˆs¡c v¡ce
         dw        8400h,KalCPgUp           ; ^Page Up - o rok m‚nˆ
         dw        7600h,KalCPgDn           ; ^Page Down - o rok v¡ce
         dw        7700h,KalCHome           ; ^Home - za‡ tek roku
         dw        7500h,KalCEnd            ; ^End - konec roku
         dw        7300h,KalCPre            ; ^left p©ede¨l  pozn mka
         dw        7400h,KalCNxt            ; ^rght n sleduj¡c¡ pozn mka
         dw        5300h,KalDel             ; zru¨en¡ dn–

         dw        0f09h,Diar               ; tabel tor - di ©
         dw        0f00h,Notes              ; Shift-Tab pozn mky
         dw        11bh,Konec               ; konec programu
         dw        1c0dh,Diar               ; ENTER di ©
         dw        0,Kalend1                ; neobslou‘en  kl vesa

; ------ aktualizace pro nov˜ den

KalNovy: jmp       Kalend

; ------ vlevo - o den m‚nˆ

KalLeft: mov       cx,1
KalLeft1:sub       word ptr ds:[Den],cx     ; sn¡‘en¡ data
         sbb       word ptr ds:[Den+2],0    ; p©enod HIGH
         jnc       KalLeft4                 ; bylo to OK
KalLeft2:mov       word ptr ds:[Den],0      ; omezen¡ na den 0
         mov       word ptr ds:[Den+2],0
KalLeft4:jmp       short KalNovy            ; aktualizace pro nov˜ den

; ------ vpravo - o den v¡ce

KalRght: mov       cx,1
KalRght1:add       word ptr ds:[Den],cx     ; zv˜¨en¡ data
         adc       word ptr ds:[Den+2],0    ; p©enos HIGH
         jc        KalRght3
         cmp       word ptr ds:[Den+2],MAXDENH ; maxim ln¡ den HIGH
         jne       KalRght2
         cmp       word ptr ds:[Den],MAXDENL ; maxim ln¡ den LOW
KalRght2:jbe       KalRght4                 ; den je OK
KalRght3:mov       word ptr ds:[Den],MAXDENL ; omezen¡ na maxim ln¡ den
         mov       word ptr ds:[Den+2],MAXDENH
KalRght4:jmp       short KalNovy            ; aktualizace pro nov˜ den

; ------ nahoru - o t˜den m‚nˆ

KalUp:   mov       cx,7                     ; po‡et dn– k posunu
         jmp       short KalLeft1

; ------ dol– - o t˜den v¡ce

KalDwn:  mov       cx,7                     ; po‡et dn– k posunu
         jmp       short KalRght1

; ------ HOME - prvn¡ den v mˆs¡ci

KalHome: xor       cx,cx
         mov       cl,dl                    ; den v mˆs¡ci
         dec       cx                       ; po‡et dn– - 1
         jmp       short KalLeft1

; ------ END - posledn¡ den v mˆs¡ci

KalXEnd: xor       cx,cx
         mov       cl,ah                    ; po‡et dn– v mˆs¡ci
         sub       cl,dl                    ; zbytek do konce mˆs¡ce
KalEnd2: jmp       short KalRght1

; ------ PageUp - o mˆs¡c m‚nˆ

KalPgUp: mov       bx,dx                    ; mˆs¡c a den
         dec       bh                       ; posun mˆs¡ce
         jnz       KalPgUp1                 ; nebyl to leden
         mov       bh,12                    ; n hrada prosincem
         sub       cx,1                     ; sn¡‘en¡ roku
         jc        KalHome                  ; je rok 0
KalPgUp1:call      MesicGet                 ; po‡et dn– v p©ede¨l‚m mˆs¡ci
         xor       cx,cx
         mov       cl,al                    ; to bude p©¡¨t¡ posun
         cmp       cl,dl                    ; je men¨¡ po‡et dn– ?
         jae       KalLeft1                 ; je to OK
         mov       cl,dl                    ; jinak zv˜¨en¡
KalPgUp2:jmp       short KalLeft1

; ------ PageDown - o mˆs¡c v¡ce

KalPgDn: mov       bx,dx                    ; mˆs¡c a den
         mov       dh,ah                    ; po‡et dn–
         inc       bh                       ; posun mˆs¡ce
         cmp       bh,12
         jbe       KalPgDn2                 ; mˆs¡c OK
         mov       bh,1
         inc       cx                       ; zv˜¨en¡ roku
KalPgDn2:call      MesicGet                 ; po‡et dn– v dal¨¡m mˆs¡ci
         xor       cx,cx
         mov       cl,dh                    ; posun
         cmp       dl,al
         jbe       KalEnd2                  ; posun OK
         sub       dl,al
         sub       cl,dl                    ; sn¡‘en¡ posunu
         jmp       short KalEnd2

; ------ ^PageUp - o rok m‚nˆ

KalCPgUp:jcxz      KalCHome                 ; je ji‘ rok 0
         cmp       dh,2                     ; je leden nebo £nor ?
         ja        KalCPgU1
         dec       cx
KalCPgU1:call      RokGet
KalCPgU2:mov       cx,ax
         cmp       dh,2
         jne       KalPgUp2
         cmp       dl,29
         jne       KalPgUp2
         inc       cx                       ; oprava pro 29.£nora
KalCPgU4:jmp       short KalPgUp2

; ------ ^PageDown - o rok v¡ce

KalCPgDn:cmp       dh,2
         jbe       KalCPgD1
         inc       cx
KalCPgD1:call      RokGet
KalCPgD2:mov       cx,ax
         cmp       dh,2
         jne       KalEnd2
         cmp       dl,29
         jne       KalEnd2
         dec       cx                       ; oprava pro 29.£nora
KalCPgD4:jmp       short KalEnd2

; ------ ^Home - za‡ tek roku

KalCHome:mov       bh,dh
         xor       dh,dh
         dec       dx                       ; DX = posun v mˆs¡ci
KalCHom1:dec       bh
         jz        KalCHom2
         call      MesicGet
         add       dx,ax
         jmp       short KalCHom1

KalCHom2:mov       cx,dx
         jmp       short KalCPgU4

; ------ ^End - konec roku

KalCEnd: sub       ah,dl                    ; po‡et zbyl˜ch dn–
         mov       bh,dh                    ; mˆs¡c
         mov       dl,ah
         xor       dh,dh
KalCEnd1:inc       bh
         cmp       bh,12
         ja        KalCEnd2
         call      MesicGet
         add       dx,ax
         jmp       short KalCEnd1

KalCEnd2:mov       cx,dx
         jmp       short KalCPgD4

; ------ p©ede¨l  pozn mka

KalCPre: mov       ax,word ptr ds:[Den]     ; aktivn¡ den LOW
         mov       dl,byte ptr ds:[Den+2]   ; aktivn¡ den HIGH
         call      PreDen                   ; nalezen¡ p©ede¨l‚ pozn mky
KalCPre2:jc        KalCPre3                 ; den nenalezen
         mov       word ptr ds:[Den],ax     ; nalezen˜ den LOW
         mov       byte ptr ds:[Den+2],dl   ; nalezen˜ den HIGH
         mov       ds:[DenAdr],di           ; adresa nalezen‚ho dne
KalCPre3:jmp       Kalend03

; ------ dal¨¡ pozn mka

KalCNxt: mov       ax,word ptr ds:[Den]     ; aktivn¡ den LOW
         mov       dl,byte ptr ds:[Den+2]   ; aktivn¡ den HIGH
         call      NxtDen                   ; nalezen¡ dal¨¡ pozn mky
         jmp       short KalCPre2

; ------ zru¨en¡ dn–

                                          ;* zobrazen¡ textu v˜zvy
KalDel:  or        byte ptr ds:[Param],80h  ; p©¡znak ru¨en¡
         call      DispHlp

                                          ;* vypr zdnˆn¡ kl vesnice
KalDel1: mov       ah,1
         int       16h
         jz        KalDel2
         mov       ah,0
         int       16h
         jmp       short KalDel1

                                          ;* vstup znaku z kl vesnice
KalDel2: call      InpChr                   ; ‡ek n¡ na stisk kl vesy
         mov       al,bl
         call      UpCase                   ; p©evod na velk‚ p¡smeno
         cmp       al,"A"                   ; je potvrzen¡ ?
         jne       KalDel9                  ; nen¡ potvrzen¡

                                          ;* zru¨en¡ star¨¡ch dn–
KalDel3: push      es
         mov       ax,word ptr ds:[Den]     ; aktivn¡ den LOW
         mov       dx,word ptr ds:[Den+2]   ; aktivn¡ den HIGH
         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,6
         mov       cx,es:[di]               ; offset prvn¡ho dne
KalDel4: add       di,cx                    ; adresa prvn¡ho/dal¨¡ho dne
KalDel5: mov       cx,es:[di]               ; d‚lka definice dne
         jcxz      KalDel7                  ; konec dat
         cmp       dl,es:[di+4]             ; je spr vn‚ ‡¡slo dne HIGH ?
         jb        KalDel4                  ; nen¡ n¡z¨¡ den
         ja        KalDel6                  ; je ni‘¨¡ den
         cmp       ax,es:[di+2]             ; je spr vn‚ ‡¡slo dne LOW ?
         jbe       KalDel4                  ; nen¡ n¡z¨¡ den - dal¨¡ den
KalDel6: call      DelDat                   ; zru¨en¡ definice dne
         jc        KalDel7                  ; nˆjak  chyba
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace
         jmp       short KalDel5            ; kontrola dal¨¡ho dne
KalDel7: call      UlozSoub                 ; ulo‘en¡ souboru
         pop       es

KalDel9: and       byte ptr ds:[Param],not 80h ; zru¨en¡ p©¡znaku ru¨en¡
         jmp       Kalend

; -----------------------------------------------------------------------------
;        obsluha di ©e
; -----------------------------------------------------------------------------
;þ

; ------ vytvo©en¡ definice dne

Diar:    mov       byte ptr ds:[WAkt],2     ; je aktivn¡ di ©
         call      InitDiar                 ; inicializace di ©e
         mov       byte ptr ds:[EditKur],0  ; po‡ te‡n¡ pozice kurzoru
         mov       word ptr ds:[DiaTop],0   ; prvn¡ zobrazen˜ © dek
         mov       word ptr ds:[DiaAkt],0   ; aktivn¡ © dek s kurzorem

; ------ zah jen¡ editace © dku

Diar0:   call      LoadDiar                 ; na‡ten¡ editovan‚ho © dku
         call      DispAll                  ; zobrazen¡ obrazovky

; ------ vstup znaku z kl vesnice

Diar1:   call      DispHlp                  ; zobrazen¡ textu n povˆdy
         call      InpChr                   ; vstup znaku z kl vesnice
         call      JumpBX                   ; skok na funkci

         dw        0f09h,Diar3              ; TAB pozn mky
         dw        0f00h,Diar4              ; Shift-TAB kalend ©
         dw        11bh,Diar4               ; skok na kalend ©
         dw        1c0dh,DiaEnt             ; ENTER - nov˜ © dek
         dw        5200h,DiaIns             ; INSERT - zalo‘en¡ nov‚ polo‘ky
         dw        5000h,DiaDwn             ; kurzor dol–
         dw        4800h,DiaUp              ; kurzor nahoru
         dw        4900h,DiaPgUp            ; str nka nahoru
         dw        8400h,DiaHome            ; za‡ tek ^Page Up
         dw        5100h,DiaPgDn            ; str nka dol–
         dw        7600h,DiaEnd             ; konec ^Page Down
         dw        1519h,DiaDell            ; zru¨en¡ © dku
         dw        1c0ah,Diar0              ; Ctrl-ENTER obnoven¡ © dku

         dw        0,Diar2                  ; neobslou‘en  kl vesa

; ------ editace © dku

Diar2:   cmp       word ptr ds:[DiaNum],0   ; je nˆjak  polo‘ka ?
         jne       Diar22                   ; je nˆjak  polo‘ka

                                          ;* zalo‘en¡ nov‚ho © dku
         xor       cx,cx                    ; ‡¡slo aktivn¡ho © dku
         call      CreatDia                 ; vytvo©en¡ polo‘ky di ©e CX
         jc        Diar29                   ; nedostatek pamˆti
         mov       byte ptr ds:[EditKur],cl ; pozice kurzoru na © dku
         mov       ds:[DiaAkt],cx           ; nov˜ aktivn¡ © dek
         mov       ds:[DiaTop],cx           ; ‡¡slo prvn¡ho © dku
         call      LoadDiar                 ; na‡ten¡ editovan‚ho © dku
         call      DispAll                  ; zobrazen¡ obrazovky

                                          ;* z konce © dku p©echod na nov˜ © dek
Diar22:  call      EditLine                 ; editace © dku

         cmp       byte ptr ds:[EditKur],MaxLDiar ; kurzor na konci © dku ?
         jb        Diar27                   ; kurzor je OK
         call      StorDiar                 ; ulo‘en¡ editovan‚ho © dku
         mov       cx,ds:[DiaAkt]           ; ‡¡slo aktivn¡ho © dku
         cmp       cx,ds:[DiaNum]           ; je to platn˜ © dek ?
         jae       Diar23                   ; nen¡ to platn˜ © dek
         inc       cx                       ; jinak zv˜¨en¡ ‡¡sla © dku
Diar23:  call      CreatDia                 ; vytvo©en¡ polo‘ky di ©e CX
         jc        Diar29                   ; nedostatek pamˆti
         mov       byte ptr ds:[EditKur],9  ; pozice kurzoru na © dku
         mov       ds:[DiaAkt],cx           ; nov˜ aktivn¡ © dek
         mov       ax,ds:[DiarRad]          ; po‡et © dk– di ©e
         dec       ax                       ; po‡et © dk– - 1
         sub       cx,ax                    ; ‡¡slo maxim ln¡ho po‡ tku
         jnc       Diar24                   ; nen¡ p©ete‡en¡
         xor       cx,cx                    ; omezen¡ po‡ tku
Diar24:  cmp       cx,ds:[DiaTop]           ; je p©ete‡en¡ po‡ tku ?
         jb        Diar25                   ; po‡ tek je OK
         mov       ds:[DiaTop],cx           ; omezen¡ po‡ tku
Diar25:  call      LoadDiar                 ; na‡ten¡ editovan‚ho © dku
         call      DispAll                  ; zobrazen¡ obrazovky

Diar27:
Diar29:  jmp       Diar1

; ------ TAB - pozn mky

Diar3:   call      StorDiar                 ; ulo‘en¡ editovan‚ho © dku
         call      UlozSoub                 ; ulo‘en¡ souboru
         jmp       Notes

; ------ SHIFT-TAB, ESC - kalend ©

Diar4:   call      StorDiar                 ; ulo‘en¡ editovan‚ho © dku
         call      UlozSoub                 ; ulo‘en¡ souboru
         jmp       Kalend

; ------ ENTER - zalo‘en¡ nov‚ polo‘ky

DiaEnt:  call      StorDiar                 ; ulo‘en¡ editovan‚ho © dku
         mov       cx,ds:[DiaAkt]           ; aktivn¡ © dek di ©e
         cmp       cx,ds:[DiaNum]           ; je to platn˜ © dek ?
         jae       DiaEnt2                  ; nen¡ to platn˜ © dek
         inc       cx                       ; jinak zv˜¨en¡ ‡¡sla © dku
DiaEnt2: call      CreatDia                 ; vytvo©en¡ polo‘ky di ©e CX
         jc        Diar29                   ; nedostatek pamˆti
         mov       byte ptr ds:[EditKur],0  ; pozice kurzoru na © dku
         mov       ax,cx                    ; aktivn¡ polo‘ka
         jmp       short DiaDwn2            ; zah jen¡ editace © dku

; ------ INSERT - zalo‘en¡ nov‚ polo‘ky

DiaIns:  call      StorDiar                 ; ulo‘en¡ editovan‚ho © dku
         mov       cx,ds:[DiaAkt]           ; aktivn¡ © dek
         jmp       short DiaEnt2            ; zalo‘en¡ nov‚ polo‘ky

; ------ za‡ tek HOME

DiaHome: mov       cx,-1
         jmp       short DiaUp1

; ------ str nka nahoru

DiaPgUp: mov       cx,ds:[DiarRad]          ; po‡et © dk– di ©e
         dec       cx
         jmp       short DiaUp1

; ------ kurzor nahoru

DiaUp:   mov       cx,1                     ; po‡et © dk–
DiaUp1:  call      StorDiar                 ; ulo‘en¡ editovan‚ho © dku
         mov       ax,ds:[DiaAkt]           ; aktivn¡ © dek
         or        ax,ax                    ; je ji‘ © dek 0 ?
         jnz       DiaUp2                   ; nen¡ je¨tˆ © dek 0
DiaUp13: jmp       Diar1                    ; ‘ dn  operace
DiaUp2:  sub       ax,cx                    ; sn¡‘en¡ ‡¡sla © dku
         jnc       DiaUp3                   ; nen¡ podte‡en¡
         xor       ax,ax
DiaUp3:  mov       ds:[DiaAkt],ax           ; nov˜ aktivn¡ © dek
         cmp       ax,ds:[DiaTop]           ; je nad prvn¡m © dkem ?
         jae       DiaUp6                   ; prvn¡ © dek je OK
         mov       ds:[DiaTop],ax           ; oprava prvn¡ho © dku
DiaUp6:  jmp       Diar0

; ------ konec

DiaEnd:  mov       cx,-1
         jmp       short DiaDwn1

; ------ str nka dol–

DiaPgDn: mov       cx,ds:[DiarRad]          ; po‡et © dk– di ©e
         dec       cx
         jmp       short DiaDwn1

; ------ kurzor dol–

DiaDwn:  mov       cx,1                     ; po‡et © dk–
DiaDwn1: call      StorDiar                 ; ulo‘en¡ editovan‚ho © dku
         cmp       word ptr ds:[DiaNum],0   ; je nˆjak˜ © dek ?
         je        DiaUp13                  ; nen¡ ‘ dn˜ © dek
         mov       ax,ds:[DiaAkt]           ; aktivn¡ © dek
         add       ax,cx                    ; posun aktivn¡ho © dku
         jc        DiaDwn14                 ; p©ete‡en¡
         cmp       ax,ds:[DiaNum]           ; je p©ete‡en¡ konce ?
         jb        DiaDwn2                  ; ‡¡slo © dku je OK
DiaDwn14:mov       ax,ds:[DiaNum]           ; po‡et © dk–
         dec       ax                       ; ‡¡slo posledn¡ho © dku
DiaDwn2: mov       ds:[DiaAkt],ax           ; nov˜ aktivn¡ © dek
         mov       cx,ds:[DiarRad]          ; po‡et © dk– di ©e
         dec       cx                       ; po‡et © dk– - 1
         sub       ax,cx                    ; ‡¡slo maxim ln¡ho po‡ tku
         jnc       DiaDwn3                  ; nen¡ p©ete‡en¡
         xor       ax,ax                    ; omezen¡ po‡ tku
DiaDwn3: cmp       ax,ds:[DiaTop]           ; je p©ete‡en¡ po‡ tku ?
         jb        DiaDwn4                  ; po‡ tek je OK
         mov       ds:[DiaTop],ax           ; omezen¡ po‡ tku
DiaDwn4: jmp       short DiaUp6

; ------ zru¨en¡ © dku

DiaDell: cmp       word ptr ds:[DiaNum],0
         je        DiaDel4
         mov       cx,ds:[DiaAkt]           ; aktivn¡ © dek
         call      DelDiar                  ; zru¨en¡ © dku CX
         cmp       cx,ds:[DiaNum]           ; je za koncem ?
         jb        DiaDel4                  ; je OK
         cmp       word ptr ds:[DiaNum],0
         je        DiaDel4
         dec       word ptr ds:[DiaAkt]     ; sn¡‘en¡ ‡¡sla © dku
         dec       cx
         cmp       cx,ds:[DiaTop]
         jae       DiaDel4
         mov       ds:[DiaTop],cx
DiaDel4: jmp       Diar0

; -----------------------------------------------------------------------------
;        inicializace di ©e
; -----------------------------------------------------------------------------

InitDiar PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ inicializace ukazatel–

         and       byte ptr ds:[Param],not 20h  ; zru¨en¡ p©¡znaku modifikace
         mov       word ptr ds:[DiaNum],0   ; po‡et © dk– di ©e
         mov       word ptr ds:[DiaAkt],0   ; aktivn¡ © dek
         mov       word ptr ds:[DiaTop],0   ; prvn¡ zobrazen¡ © dek

; ------ adresa definice dne

         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,ds:[DenAdr]
         or        di,di
         jz        InitDia9
         cmp       word ptr es:[di],0       ; je platn˜ den ?
         je        InitDia9                 ; den nen¡
         or        byte ptr ds:[Param],20h  ; p©¡znak, ‘e je platn˜ den

; ------ spo‡ten¡ © dk– celkem

InitDia2:xor       cx,cx                    ; ‡¡ta‡ © dk–
         mov       si,di                    ; adresa definice dne
         mov       bx,di                    ; adresa definice dne
         add       bx,es:[di]               ; adresa definice dal¨¡ho dne
         add       si,5                     ; adresa prvn¡ pozn mky
         mov       ah,0
         cld
InitDia3:cmp       si,bx                    ; jsou ji‘ v¨echny pozn mky ?
         jae       InitDia4                 ; jsou ji‘ v¨echny pozn mky
         inc       cx                       ; ‡¡ta‡ © dk– pozn mek
         inc       si
         inc       si
         mov       al,es:[si]               ; d‚lka pozn mky
         inc       si
         add       si,ax                    ; adresa dal¨¡ pozn mky
         jmp       short InitDia3           ; dal¨¡ pozn mka
InitDia4:mov       ds:[DiaNum],cx           ; po‡et © dk– dne di ©e

; ------ n vrat registr–

InitDia9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

InitDiar ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ textu akce
; -----------------------------------------------------------------------------

LoadDiar PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ inicializa‡n¡ vymaz n¡ bufferu

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ds,ds:[DatSegm]          ; datov˜ segment
         mov       di,offset EditBuf        ; edita‡n¡ buffer
         mov       cx,80/2                  ; max. d‚lka bufferu
         cld
         mov       ax,"  "                  ; mazac¡ znak mezery
         rep       stosw                    ; vymaz n¡ bufferu

; ------ test, zda je platn˜ © dek

         mov       cx,es:[DiaAkt]           ; aktivn¡ © dek pozn mky
         cmp       cx,es:[DiaNum]           ; kontrola ‡¡sla © dku pozn mky
         jae       LoadDia9                 ; neplatn‚ ‡¡slo © dku

; ------ nalezen¡ aktivn¡ho © dku

         cld
         mov       ah,0
         mov       si,es:[DenAdr]           ; adresa aktivn¡ho dne v bufferu
         add       si,5                     ; adresa prvn¡ pozn mky
         jcxz      LoadDia2                 ; je to prvn¡ pozn mka
LoadDia1:inc       si
         inc       si
         lodsb                              ; d‚lka textu poozn mky
         add       si,ax                    ; adresa dal¨¡ pozn mky
         loop      LoadDia1                 ; dal¨¡ pozn mka

; ------ dek¢dov n¡ © dku

LoadDia2:mov       di,offset EditBuf        ; edita‡n¡ buffer
         call      DekDiar                  ; dek¢dov n¡ © dku di ©e

; ------ n vrat registr–

LoadDia9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

LoadDiar ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ textu di ©e
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice © dku di ©e
;        ES:DI=buffer di ©e (MAXLDIAR znak–)
; -----------------------------------------------------------------------------

DekDiar  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di

; ------ dek¢dov n¡ pokra‡ov n¡ pozn mky

         cld
         mov       ax,ds:[si]               ; ‡as za‡ tku akce
         cmp       al,0ffh                  ; je pokra‡ov n¡ pozn mky ?
         jne       DekDiar1                 ; nen¡ pokra‡ov n¡ pozn mky
         inc       si
         inc       si
         mov       al," "                   ; mezera k vymaz n¡
         mov       cx,9
         rep       stosb                    ; vymaz n¡ ‡asu
         jmp       short DekDiar5

; ------ dek¢dov n¡ hodiny za‡ tku akce

DekDiar1:mov       cl,6                     ; po‡et rotac¡
         shr       ax,cl                    ; rotace hodiny
         and       ax,1fh                   ; maska hodiny
         mov       cl,10                    ; dˆlitel
         div       cl                       ; v˜po‡et ‡¡slic
         add       ax,"00"                  ; korekce na ASCII ‡¡slice
         cmp       al,"0"                   ; je prvn¡ ‡¡slice "0" ?
         jne       DekDiar2                 ; nen¡ "0"
         mov       al," "                   ; n hrada prvn¡ nuly mezerou
DekDiar2:stosw                              ; ulo‘en¡ ‡¡slic hodiny
         mov       al,":"
         stosb                              ; oddˆlovac¡ dvojte‡ka

; ------ dek¢dov n¡ minuty za‡ tku akce

         mov       al,ds:[si]               ; ‡as za‡ tku akce
         and       ax,3fh                   ; minuta za‡ tku akce
         mov       cl,10                    ; dˆlitel
         div       cl                       ; v˜po‡et ‡¡slic
         add       ax,"00"                  ; korekce na ASCII ‡¡slice
         stosw                              ; ulo‘en¡ ‡¡slic minuty

; ------ dek¢dov n¡ bud¡ku

         mov       al,"/"                   ; oddˆlova‡
         stosb                              ; ulo‘en¡ oddˆlova‡e
         lodsw                              ; ‡as za‡ tku akce
         mov       cl,11                    ; po‡et rotac¡
         shr       ax,cl                    ; rotace ‡asu indikace
         cmp       al,31                    ; je bud¡k zapnut ?
         jne       DekDiar3                 ; je zapnut
         mov       ax,"  "
         dec       di
         stosb                              ; vymaz n¡ indik toru
         jmp       short DekDiar4
DekDiar3:mov       cl,10                    ; dˆlitel
         div       cl                       ; v˜po‡et ‡¡slic
         add       ax,"00"                  ; korekce na ASCII znaky
         cmp       al,"0"
         jne       DekDiar4
         mov       al,ah                    ; ni‘¨¡ ‡¡slice
         mov       ah," "
DekDiar4:stosw                              ; ulo‘en¡ ‡asu bud¡ku
         mov       al," "
         stosb                              ; oddˆlovac¡ mezera

; ------ p©enesen¡ © dku do bufferu

DekDiar5:lodsb                              ; na‡ten¡ bajtu d‚lky
         mov       ah,0
         xchg      ax,cx                    ; CX <- d‚lka textu pozn mky
         mov       ax,80-9                  ; maxim ln¡ d‚lka zbytku © dku
         cmp       cl,al                    ; maxim ln¡ d‚lka textu
         jbe       DekDiar6                 ; d‚lka textu je OK
         mov       cl,al                    ; omezen¡ d‚lky textu
DekDiar6:sub       ax,cx                    ; zbytek © dku
         rep       movsb                    ; p©enesen¡ pozn mky do bufferu

; ------ vymaz n¡ zbytku © dku

         xchg      ax,cx                    ; d‚lka zbytku © dku
         mov       al," "                   ; mazac¡ znak mezery
         rep       stosb                    ; vymaz n¡ zbytku © dku

; ------ n vrat registr–

         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DekDiar  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ editovan‚ho © dku di ©e (CY=nedostatek pamˆti)
; -----------------------------------------------------------------------------

StorDiar PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda je nˆjak˜ © dek

         cmp       word ptr ds:[DiaNum],0   ; je nˆjak˜ © dek ?
         jne       StorDia0                 ; je nˆjak˜ © dek
StorDi02:jmp       StorDia9                 ; nen¡ ‘ dn˜ © dek

; ------ nalezen¡ aktivn¡ho © dku

StorDia0:cld
         mov       cx,ds:[DiaAkt]           ; aktivn¡ © dek pozn mky
         cmp       cx,ds:[DiaNum]
         jae       StorDi02                 ; nen¡ platn˜ © dek pozn mky
         mov       ah,0
         mov       di,ds:[DenAdr]           ; adresa aktivn¡ho dne v bufferu
         mov       bx,di                    ; £schova adresy dne
         mov       es,ds:[DatSegm]          ; adresa bufferu
         add       di,5                     ; adresa prvn¡ pozn mky
         jcxz      StorDia2                 ; je to prvn¡ pozn mka
StorDia1:inc       di
         inc       di
         mov       al,es:[di]               ; d‚lka textu pozn mky
         inc       di
         add       di,ax                    ; adresa dal¨¡ pozn mky
         loop      StorDia1                 ; dal¨¡ pozn mka

; ------ sestaven¡ slova ‡as–

StorDia2:mov       si,offset EditBuf        ; edita‡n¡ buffer - hodina
         mov       dx,-1                    ; p©ednastaven¡ - pokra‡. pozn mky
         call      GetDNum                  ; poskytnut¡ ‡¡sla
         jc        StorDi32                 ; nen¡ zad na hodina - pozn mka
         cmp       al,23                    ; maxim ln¡ ‡¡slo pro hodinu
         jbe       StorDi22                 ; hodina je OK
         mov       al,23                    ; omezen¡ hodiny
StorDi22:mov       cl,6
         mov       ah,0
         shl       ax,cl                    ; rotace hodiny na m¡sto
         mov       dx,ax                    ; st©ada‡ slova
         mov       si,offset EditBuf+3      ; minuta
         call      GetDNum                  ; poskytnut¡ ‡¡sla
         cmp       al,59                    ; maxim ln¡ minuta
         jbe       StorDi23                 ; minuta je OK
         mov       al,59                    ; omezen¡ minuty
StorDi23:or        dl,al                    ; minuta
         mov       si,offset EditBuf+6      ; bud¡k
         call      GetDNum                  ; bud¡k
         jc        StorDi25                 ; bud¡k vypnut
         cmp       al,30                    ; maxim ln¡ hodnota bud¡ku
         jbe       StorDia3                 ; £daj je OK
         mov       al,30                    ; omezen¡ £daje
         jmp       short StorDia3
StorDi25:mov       al,31                    ; n hradn¡ hodnota - bud¡k vypnut
StorDia3:mov       cl,11                    ; po‡et rotac¡
         shl       ax,cl                    ; rotace ‡asu buzen¡ na m¡sto
         or        dx,ax                    ; p©id n¡ ‡asu bud¡ku

; ------ ulo‘en¡ slova ‡as–

StorDi32:cmp       es:[di],dx               ; byl ‡as zmˆnˆn ?
         je        StorDia4                 ; ‡as nebyl zmˆnˆn
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace kalend ©e
         mov       es:[di],dx               ; ulo‘en¡ zadan‚ho ‡asu

; ------ stanoven¡ d‚lky zadan‚ho textu

StorDia4:inc       di
         inc       di
         mov       si,MaxLDiar-9            ; maxim ln¡ d‚lka pozn mky
StorDia5:cmp       byte ptr ds:[si+EditBuf+9-1]," " ; je konec textu ?
         jne       StorDia6                 ; nalezen konec textu
         dec       si                       ; sn¡‘en¡ ukazatele textu
         jnz       StorDia5                 ; dal¨¡ znak

; ------ rozli¨en¡, zda se © dek zkr t¡ nebo prodlou‘¡

StorDia6:mov       al,es:[di]               ; d‚lka pozn mky
         mov       ah,0                     ; AX = d‚lka textu v bufferu
         mov       cx,si                    ; d‚lka zadan‚ho textu
         sub       cx,ax                    ; rozd¡l d‚lek
         ja        StorDia8                 ; text je del¨¡ - vlo‘en¡ dat
         jb        StorDia7                 ; text je krat¨¡ - zru¨en¡ dat

; ------ p©i shodˆ porovn n¡ text–, zda byla zmˆna

         mov       cx,si                    ; d‚lka pozn mky
         jcxz      StorDia9                 ; texty jsou shodn‚
         mov       si,offset EditBuf+9      ; text z bufferu
         cld
         push      cx
         push      di
         inc       di
         repe      cmpsb                    ; porovn n¡ text–
         pop       di
         pop       si                       ; n vrat d‚lky
         je        StorDia9                 ; shoda - nic se neukl d 
         jmp       short StorDi88           ; p©enesen¡ textu do bufferu

; ------ zru¨en¡ dat z bufferu

StorDia7:neg       cx                       ; rozd¡l d‚lek
         call      DelDat                   ; zru¨en¡ dat z bufferu
         jc        StorDia9                 ; nˆjak  chyba
         sub       es:[bx],cx               ; sn¡‘en¡ d‚lky dne
         jmp       short StorDi88           ; p©enesen¡ textu pozn mky

; ------ vlo‘en¡ dat do bufferu

StorDia8:call      InsDat                   ; vlo‘en¡ dat
         jc        StorDia9                 ; chyba - p©ete‡en¡ bufferu
         add       es:[bx],cx               ; zv˜¨en¡ d‚lky dne

; ------ p©enesen¡ textu do bufferu

StorDi88:cld
         mov       ax,si                    ; d‚lka nov‚ pozn mky
         stosb                              ; ulo‘en¡ d‚lky pozn mky
         mov       cx,si                    ; d‚lka textu pozn mky
         mov       si,offset EditBuf+9      ; edita‡n¡ buffer
         rep       movsb                    ; p©enesen¡ textu pozn mky
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace kalend ©e

; ------ n vrat registr–

StorDia9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StorDiar ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ ‡¡sla z edita‡n¡ho bufferu (CY=nezad no)
; -----------------------------------------------------------------------------

GetDNum  PROC      NEAR

; ------ £schova registr–

         push      bx
         xor       bx,bx                    ; st©ada‡ ‡¡sla

; ------ kontrola, zda je ‡¡slo zad no

         mov       ax,ds:[si]               ; prvn¡ a druh˜ znak z bufferu
         cmp       ax,"  "                  ; je ‡¡slo zad no ?
         stc                                ; p©¡znak, ‘e nen¡ ‡¡slo zad no
         je        GetDNum9                 ; ‡¡slo nen¡ zad no

; ------ na‡ten¡ prvn¡ ‡¡slice

         sub       al,"0"                   ; korekce znaku na ‡¡slo
         jb        GetDNum1                 ; neplatn˜ znak
         mov       bl,al                    ; prvn¡ ‡¡slice

; ------ na‡ten¡ druh‚ ‡¡slice

GetDNum1:mov       al,ds:[si+1]             ; dal¨¡ ‡¡slice
         sub       al,"0"                   ; korekce ‡¡slice na ‡¡slo
         jb        GetDNum2                 ; ‡¡slo je neplatn‚
         xchg      ax,bx
         mov       ah,10
         mul       ah                       ; vyn soben¡ prvn¡ ‡¡slice
         add       al,bl                    ; sou‡et ‡¡slic
         xchg      ax,bx

GetDNum2:clc                                ; p©¡znak operace OK
GetDNum9:mov       ax,bx                    ; na‡ten‚ ‡¡slo
         pop       bx
         ret

GetDNum  ENDP

; -----------------------------------------------------------------------------
;        vytvo©en¡ aktivn¡ho dne (pokud nen¡ vytvo©en) CY=nedostatek pamˆti
; -----------------------------------------------------------------------------

CreatDen PROC      NEAR

; ------ £schova registr–

         push      cx
         push      di
         push      es

; ------ adresa dne

         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,ds:[DenAdr]           ; adresa dne
         cmp       word ptr es:[di],0       ; je den definov n ?
         jne       CreatDn9                 ; den je definov n OK

; ------ vytvo©en¡ definice dne

         mov       cx,5                     ; d‚lka jednoho dne
         call      InsDat                   ; vytvo©en¡ nov‚ho dne
         jc        CreatDn9                 ; chyba - nedostatek pamˆti
         mov       word ptr es:[di],cx      ; offset dal¨¡ho dne
         mov       cx,word ptr ds:[Den]     ; aktu ln¡ den LOW
         mov       es:[di+2],cx             ; ‡¡slo dne LOW
         mov       cx,word ptr ds:[Den+2]   ; aktu ln¡ den HIGH
         mov       es:[di+4],cl             ; ‡¡slo dne HIGH
         or        byte ptr ds:[Param],20h+4 ; p©¡znak vytvo©en¡ definice dne

; ------ n vrat registr–

CreatDn9:pop       es
         pop       di
         pop       cx
         ret

CreatDen ENDP

; -----------------------------------------------------------------------------
;        vytvo©en¡ polo‘ky aktivn¡ho dne CX (CY=nedostatek pamˆti)
; -----------------------------------------------------------------------------

CreatDia PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ vytvo©en¡ aktivn¡ho dne

         call      CreatDen                 ; vytvo©en¡ aktivn¡ho dne
         jc        CreatDi9                 ; nedostatek pamˆti

; ------ omezen¡ ‡¡sla polo‘ky

         cmp       cx,ds:[DiaNum]           ; p©ekro‡en po‡et © dk– ?
         jbe       CreatDi2                 ; po‡et © dk– je OK
         mov       cx,ds:[DiaNum]           ; omezen¡ na posledn¡ © dek

; ------ nalezen¡ adresy polo‘ky

CreatDi2:mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,ds:[DenAdr]           ; adresa aktivn¡ho dne v bufferu
         mov       si,di                    ; £schova adresy dne
         add       di,5                     ; adresa prvn¡ pozn mky
         mov       ah,0
         jcxz      CreatDi4                 ; je prvn¡ polo‘ka
CreatDi3:inc       di
         inc       di
         mov       al,es:[di]               ; d‚lka textu pozn mky
         inc       di
         add       di,ax                    ; adresa dal¨¡ pozn mky
         loop      CreatDi3                 ; nalezen¡ dal¨¡ho © dku

; ------ vytvo©en¡ nov‚ polo‘ky

CreatDi4:mov       cx,3                     ; d‚lka nov‚ polo‘ky
         call      InsDat                   ; vlo‘en¡ 3 bajt–
         jc        CreatDi9                 ; chyba - nedostatek pamˆti

; ------ inicializace polo‘ky

         cld
         mov       ax,-1                    ; inicializa‡n¡ slovo - neplatn 
;         mov       ax,1111100000000000b     ; inicializa‡n¡ slovo
         stosw                              ; ‡as
         mov       al,0
         stosb                              ; d‚lka textu pozn mky = 0
         add       es:[si],cx               ; zv˜¨en¡ offsetu dal¨¡ho dne
         inc       word ptr ds:[DiaNum]     ; zv˜¨en¡ po‡tu polo‘ek dne
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace
;         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

CreatDi9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

CreatDia ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ polo‘ky aktivn¡ho dne CX
; -----------------------------------------------------------------------------

DelDiar  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ kontrola ‡¡sla polo‘ky

         cmp       cx,ds:[DiaNum]           ; p©ekro‡en po‡et © dk– ?
         jae       DelDiar9                 ; chybn‚ ‡¡slo © dku

; ------ nalezen¡ adresy polo‘ky

         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,ds:[DenAdr]           ; adresa aktivn¡ho dne v bufferu
         mov       si,di                    ; £schova adresy dne
         add       di,5                     ; adresa prvn¡ pozn mky
         mov       ah,0
         jcxz      DelDiar4                 ; je prvn¡ polo‘ka
DelDiar3:inc       di
         inc       di
         mov       al,es:[di]               ; d‚lka textu pozn mky
         inc       di
         add       di,ax                    ; adresa dal¨¡ pozn mky
         loop      DelDiar3                 ; nalezen¡ dal¨¡ho © dku

; ------ zru¨en¡ polo‘ky

DelDiar4:mov       cl,es:[di+2]             ; d‚lka textu pozn mky
         mov       ch,0
         add       cx,3                     ; korekce d‚lky
         call      DelDat                   ; zru¨en¡ © dku
         jc        DelDiar9

; ------ oprava ukazatel–

         sub       es:[si],cx               ; sn¡‘en¡ d‚lky dne
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace
         dec       word ptr ds:[DiaNum]     ; sn¡‘en¡ po‡tu © dk–
         jnz       DelDiar9                 ; nejsou je¨tˆ v¨echny © dky

; ------ zru¨en¡ definice dne

         mov       di,si                    ; adresa definice dne
         mov       cx,es:[di]               ; d‚lka definice dne
         call      DelDat                   ; zru¨en¡ definice dne
         and       byte ptr ds:[Param],not 20h ; zru¨en¡ p©¡znaku vytvo©en¡ dne

; ------ n vrat registr–

DelDiar9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DelDiar ENDP

; -----------------------------------------------------------------------------
;   nalezen¡ dne DL:AX (CY=nenalezen, DI=adresa dne v bufferu nebo konce dat)
; -----------------------------------------------------------------------------

SrcDen   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ds

; ------ p©¡prava registr–

         mov       ds,ds:[DatSegm]          ; datov˜ segment
         mov       di,6
         xor       bx,bx                    ; 0=p©¡znak konce dat

; ------ adresa definice dal¨¡ho dne

SrcDen1: add       di,ds:[di]               ; adresa dal¨¡ho dne
         cmp       ds:[di],bx               ; je konec dat ?
         stc                                ; p©¡znak nenalezen¡ dne
         je        SrcDen9                  ; konec - den nenalezen

; ------ porovn n¡, zda je to hledan˜ den

         cmp       word ptr ds:[di+2],ax    ; souhlas¡ ‡¡slo dne LOW ?
         jne       SrcDen1                  ; nesouhlas¡ - dal¨¡ den
         cmp       byte ptr ds:[di+4],dl    ; souhlas¡ ‡¡slo dne HIGH ?
         jne       SrcDen1                  ; nesouhlas¡ - dal¨¡ den

; ------ n vrat registr–

SrcDen9: pop       ds
         pop       bx
         ret

SrcDen   ENDP

; -----------------------------------------------------------------------------
;    nalezen¡ p©ede¨l‚ho dne DL:AX (CY=nenalezen, DI=adresa dne v bufferu)
; -----------------------------------------------------------------------------

PreDen   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      si
         push      ds

; ------ p©¡prava registr–

         mov       ds,ds:[DatSegm]          ; datov˜ segment
         mov       di,6                     ; adresa prvn¡ho dne
         mov       dh,0                     ; nalezen˜ den HIGH
         xor       cx,cx                    ; nalezen˜ den LOW
         xor       bx,bx                    ; BX <- 0
         xor       si,si                    ; p©¡znak - den nenalezen

; ------ adresa definice dal¨¡ho dne

PreDen1: add       di,ds:[di]               ; adresa dal¨¡ho dne
         cmp       word ptr ds:[di],bx      ; je konec dat ?
         je        PreDen8                  ; konec dat

; ------ porovn n¡, zda je to ni‘¨¡ den ne‘ aktu ln¡

         cmp       byte ptr ds:[di+4],dl    ; je ni‘¨¡ den HIGH ?
         ja        PreDen1                  ; nen¡ ni‘¨¡ den
         jb        PreDen2                  ; je ni‘¨¡ den OK
         cmp       word ptr ds:[di+2],ax    ; je ni‘¨¡ den LOW ?
         jae       PreDen1                  ; nen¡ ni‘¨¡ den

; ------ porovn n¡, zda je vy¨¨¡ den ne‘ dosud nalezen˜

PreDen2: cmp       ds:[di+4],dh             ; je bli‘¨¡ den HIGH ?
         jb        PreDen1                  ; nen¡ to bli‘¨¡ den
         ja        PreDen3                  ; je to bli‘¨¡ den
         cmp       ds:[di+2],cx             ; je bli‘¨¡ den LOW ?
         jb        PreDen1                  ; nen¡ to bli‘¨¡ den

; ------ je ni‘¨¡ a bli‘¨¡ den - £schova dne

PreDen3: mov       dh,ds:[di+4]             ; £schova dne HIGH
         mov       cx,ds:[di+2]             ; £schova dne LOW
         mov       si,di                    ; £schova adresy dne v bufferu
         jmp       short PreDen1

; ------ adresa nalezen‚ho dne

PreDen8: or        si,si                    ; byl den nalezen ?
         stc                                ; p©¡znak nenalezen¡ dne
         je        PreDen9                  ; den nenalezen
         mov       dl,dh                    ; nalezen˜ den HIGH
         mov       dh,0
         mov       ax,cx                    ; nalezen˜ den LOW
         mov       di,si                    ; adresa nalezen‚ho dne
         clc

; ------ n vrat registr–

PreDen9: pop       ds
         pop       si
         pop       cx
         pop       bx
         ret

PreDen   ENDP

; -----------------------------------------------------------------------------
;    nalezen¡ dal¨¡ho dne DL:AX (CY=nenalezen, DI=adresa dne v bufferu)
; -----------------------------------------------------------------------------

NxtDen   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      si
         push      ds

; ------ p©¡prava registr–

         mov       ds,ds:[DatSegm]          ; datov˜ segment
         mov       di,6                     ; adresa prvn¡ho dne
         mov       dh,-1                    ; nalezen˜ den HIGH
         mov       cx,-1                    ; nalezen˜ den LOW
         xor       bx,bx                    ; BX <- 0
         xor       si,si                    ; p©¡znak - den nenalezen

; ------ adresa definice dal¨¡ho dne

NxtDen1: add       di,ds:[di]               ; adresa dal¨¡ho dne
         cmp       word ptr ds:[di],bx      ; je konec dat ?
         je        NxtDen8                  ; konec dat

; ------ porovn n¡, zda je to vy¨¨¡ den ne‘ aktu ln¡

         cmp       byte ptr ds:[di+4],dl    ; je vy¨¨¡ den HIGH ?
         jb        NxtDen1                  ; nen¡ vy¨¨¡ den
         ja        NxtDen2                  ; je vy¨¨¡ den OK
         cmp       word ptr ds:[di+2],ax    ; je vy¨¨¡ den LOW ?
         jbe       NxtDen1                  ; nen¡ vy¨¨¡ den

; ------ porovn n¡, zda je ni‘¨¡ den ne‘ dosud nalezen˜

NxtDen2: cmp       ds:[di+4],dh             ; je bli‘¨¡ den HIGH ?
         ja        NxtDen1                  ; nen¡ to bli‘¨¡ den
         jb        NxtDen3                  ; je to bli‘¨¡ den
         cmp       ds:[di+2],cx             ; je bli‘¨¡ den LOW ?
         ja        NxtDen1                  ; nen¡ to bli‘¨¡ den

; ------ je vy¨¨¡ a bli‘¨¡ den - £schova dne

NxtDen3: mov       dh,ds:[di+4]             ; £schova dne HIGH
         mov       cx,ds:[di+2]             ; £schova dne LOW
         mov       si,di                    ; £schova adresy dne v bufferu
         jmp       short NxtDen1

; ------ adresa nalezen‚ho dne

NxtDen8: or        si,si                    ; byl den nalezen ?
         stc                                ; p©¡znak nenalezen¡ dne
         jz        NxtDen9                  ; den nenalezen
         mov       dl,dh                    ; nalezen˜ den HIGH
         mov       dh,0
         mov       ax,cx                    ; nalezen˜ den LOW
         mov       di,si                    ; adresa nalezen‚ho dne
         clc

; ------ n vrat registr–

NxtDen9: pop       ds
         pop       si
         pop       cx
         pop       bx
         ret

NxtDen   ENDP

; -----------------------------------------------------------------------------
;        obsluha pozn mek
; -----------------------------------------------------------------------------

Notes:   mov       byte ptr ds:[WAkt],3     ; aktivn¡ pozn mky
         mov       al,ds:[NotKur]           ; uschovan˜ kurzor pozn mek
         mov       ds:[EditKur],al          ; kurzor na © dku
         mov       word ptr ds:[DiaTop],0
         mov       word ptr ds:[DiaAkt],0
Notes0:  call      LoadNot                  ; na‡ten¡ textu pozn mky
         call      DispAll                  ; zobrazen¡ obrazovky

; ------ vstup znaku z kl vesnice

Notes1:  call      InpChr                   ; vstup znaku z kl vesnice
         call      JumpBX                   ; skok na funkci

         dw        0f09h,Notes3             ; TAB kalend ©
         dw        0f00h,Notes4             ; Shift-TAB di ©
         dw        11bh,Notes3              ; ESC - skok na kalend ©
         dw        1c0ah,Notes              ; Ctrl-ENTER obnoven¡ © dku
         dw        4800h,Notes5             ; o © dek nahoru
         dw        4900h,Notes51            ; o str nku nahoru Page Up
         dw        8400h,Notes52            ; za‡ tek ^Page Up
         dw        5000h,Notes6             ; o © dek dol–
         dw        5100h,Notes61            ; o str nku dol– Page Down
         dw        7600h,Notes62            ; konec ^Page Down
         dw        1c0dh,Notes7             ; ENTER dal¨¡ © dek
         dw        5200h,Notes8             ; INSERT - vlo‘en¡ © dku
         dw        1519h,Notes9             ; ^Y zru¨en¡ © dku

         dw        0,Notes2                 ; neobslou‘en  kl vesa

; ------ vlo‘en¡ znaku do © dku

Notes2:  call      EditLine                 ; editace © dku

         cmp       byte ptr ds:[EditKur],MaxLNot ; je konec © dku ?
         jb        Notes24                  ; nen¡ konec © dku
         call      StorNot                  ; ulo‘en¡ © dku
         mov       cx,ds:[NotAkt]           ; aktivn¡ © dek
         inc       cx                       ; ‡¡slo dal¨¡ho © dku
         call      NewNot                   ; vytvo©en¡ nov‚ho © dku
         jc        Notes11                  ; nedostatek pamˆti
         mov       byte ptr ds:[EditKur],0  ; kurzor na za‡ tek © dku
         mov       ds:[NotAkt],cx
         mov       ax,ds:[NotRad]
         dec       ax
         sub       cx,ax
         jnc       Notes22
         xor       cx,cx
Notes22: cmp       cx,ds:[NotTop]
         jbe       Notes23
         mov       ds:[NotTop],cx
Notes23: call      LoadNot                  ; na‡ten¡ textu pozn mky
         call      DispAll                  ; zobrazen¡ obrazovky

Notes24:
Notes11: jmp       short Notes1

; ------ opu¨tˆn¡ pozn mek ESC, TAB

Notes3:  call      StorNot                  ; ulo‘en¡ pozn mky
         call      UlozSoub                 ; ulo‘en¡ souboru
         mov       al,ds:[EditKur]          ; kurzor na © dku
         mov       ds:[NotKur],al           ; £schova kurzoru pozn mek
         jmp       Kalend

; ------ opu¨tˆn¡ pozn mek Shift-TAB

Notes4:  call      StorNot                  ; ulo‘en¡ pozn mky
         call      UlozSoub                 ; ulo‘en¡ souboru
         mov       al,ds:[EditKur]          ; kurzor na © dku
         mov       ds:[NotKur],al           ; £schova kurzoru pozn mek
         jmp       Diar

; ------ o © dek nahoru

Notes5:  mov       cx,1                     ; po‡et © dk–
         jmp       short Notes54

; ------ o str nku nahoru

Notes51: mov       cx,ds:[NotRad]
         dec       cx
         jmp       short Notes54

; ------ za‡ tek

Notes52: mov       cx,-1

Notes54: call      StorNot                  ; ulo‘en¡ pozn mky
;         cmp       word ptr ds:[NotAkt],0
;         je        Notes11
Notes55: mov       ax,ds:[NotAkt]
         or        ax,ax
         jz        Notes57
         dec       ax
         mov       ds:[NotAkt],ax
         cmp       ax,ds:[NotTop]
         jae       Notes56
         mov       ds:[NotTop],ax
Notes56: loop      Notes55

Notes57: jmp       Notes0

; ------ o © dek dol–

Notes6:  mov       cx,1                     ; po‡et © dk–
         jmp       short Notes64

; ------ o str nku dol–

Notes61: mov       cx,ds:[NotRad]
         dec       cx
         mov       ax,ds:[NotAkt]
         add       ax,cx
         cmp       ax,ds:[NotNum]
         jb        Notes64

; ------ konec

Notes62: mov       cx,ds:[NotNum]
         sub       cx,ds:[NotAkt]
         je        Notes11
         dec       cx
         jz        Notes11

Notes64: call      StorNot
Notes65: mov       ax,ds:[NotAkt]
         inc       ax
         cmp       ax,ds:[NotNum]
         ja        Notes57
         mov       ds:[NotAkt],ax
         mov       bx,ds:[NotRad]
         dec       bx
         sub       ax,bx
         jae       Notes66
         xor       ax,ax
Notes66: cmp       ax,ds:[NotTop]
         jbe       Notes67
         mov       ds:[NotTop],ax
Notes67: loop      Notes65
         jmp       short Notes57

; ------ ENTER nov˜ © dek

Notes7:  call      StorNot                  ; ulo‘en¡ © dku
         mov       cx,ds:[NotAkt]           ; aktivn¡ © dek
         inc       cx                       ; ‡¡slo dal¨¡ho © dku
         call      NewNot                   ; vytvo©en¡ nov‚ho © dku
         jc        Notes57                  ; nedostatek pamˆti
         mov       byte ptr ds:[EditKur],0  ; kurzor na za‡ tek © dku
         jmp       short Notes6             ; posun o © dek dol–

; ------ INSERT - vlo‘en¡ © dku

Notes8:  call      StorNot                  ; vlo‘en¡ © dku
         mov       cx,ds:[NotAkt]           ; aktivn¡ © dek
         call      NewNot                   ; vytvo©en¡ dal¨¡ho © dku
         jmp       short Notes57

; ------ ^Y - zru¨en¡ © dku

Notes9:  mov       cx,ds:[NotAkt]           ; aktivn¡ © dek
         call      DelNot                   ; zru¨en¡ © dku
         jmp       short Notes57

; -----------------------------------------------------------------------------
;        Vlo‘en¡ nov‚ho © dku CX (CY=nedostatek pamˆti)
; -----------------------------------------------------------------------------

NewNot   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      es

; ------ kontrola ‡¡sla © dku

         cmp       ds:[NotNum],cx           ; je platn‚ ‡¡slo © dku ?
         jb        NewNot9                  ; neplatn‚ ‡¡slo © dku

; ------ nalezen¡ adresy © dku

         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,8                     ; adresa prvn¡ho © dku
         mov       ah,0
         cld
         jcxz      NewNot4                  ; je © dek 0
NewNot3: mov       al,es:[di]               ; na‡ten¡ bajtu d‚lky
         inc       di                       ; zv˜¨en¡ ukazatele
         add       di,ax                    ; adresa dal¨¡ho © dku
         loop      NewNot3                  ; nalezen¡ adresy © dku

; ------ vytvo©en¡ m¡sta pro dal¨¡ © dek

NewNot4: mov       cx,1                     ; po‡et bajt– k vlo‘en¡
         call      InsDat                   ; vlo‘en¡ bajtu do souboru
         jc        NewNot9                  ; nedostatek pamˆti
         add       word ptr ds:[NotEnd],cx  ; posun konce pozn mek
         add       word ptr ds:[DenAdr],cx  ; zv˜¨en¡ adresy aktivn¡ho dne

; ------ inicializace © dku

         inc       word ptr es:[6]          ; zv˜¨en¡ d‚lky pozn mek
         inc       word ptr ds:[NotNum]     ; zv˜¨en¡ ‡¡ta‡e © dk–
         mov       byte ptr es:[di],0       ; d‚lka © dku = 0
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace kalend ©e
;         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

NewNot9: pop       es
         pop       di
         pop       cx
         pop       ax
         ret

NewNot   ENDP

; -----------------------------------------------------------------------------
;        Zru¨en¡ © dku CX
; -----------------------------------------------------------------------------

DelNot   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      es

; ------ kontrola ‡¡sla © dku

         cmp       cx,ds:[NotNum]           ; je platn‚ ‡¡slo © dku ?
         cmc
         jb        DelNot9                  ; neplatn‚ ‡¡slo © dku

; ------ nalezen¡ adresy © dku

         mov       es,ds:[DatSegm]          ; datov˜ segment
         mov       di,8                     ; adresa prvn¡ho © dku
         mov       ah,0
         cld
         jcxz      DelNot4                  ; je © dek 0
DelNot3: mov       al,es:[di]               ; na‡ten¡ bajtu d‚lky
         inc       di                       ; zv˜¨en¡ ukazatele
         add       di,ax                    ; adresa dal¨¡ho © dku
         loop      DelNot3                  ; nalezen¡ adresy © dku

; ------ zru¨en¡ © dku

DelNot4: mov       cl,es:[di]               ; d‚lka © dku
         inc       cx                       ; d‚lka © dku + bajt d‚lky
         call      DelDat                   ; zru¨en¡ © dku ze souboru
         jc        DelNot9                  ; nˆjak  chyba

; ------ inicializace ukazatel–

         sub       word ptr ds:[DenAdr],cx  ; sn¡‘en¡ adresy aktivn¡ho dne
         sub       word ptr ds:[NotEnd],cx  ; posun konce pozn mek
         sub       word ptr es:[6],cx       ; sn¡‘en¡ d‚lky pozn mek
         dec       word ptr ds:[NotNum]     ; sn¡‘en¡ ‡¡ta‡e © dk–
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace kalend ©e
;         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

DelNot9: pop       es
         pop       di
         pop       cx
         pop       ax
         ret

DelNot   ENDP

; -----------------------------------------------------------------------------
;        nov‚ zobrazen¡ obrazovky
; -----------------------------------------------------------------------------

DispAll  PROC      NEAR

         call      DispKal                  ; zobrazen¡ kalend ©e
         call      DispNot
         call      DispDiar
         cmp       byte ptr ds:[WAkt],1     ; je aktivn¡ kalend © ?
         jne       DispAll1                 ; nen¡ aktivn¡ kalend ©
         call      KurzOff                  ; vypnut¡ kurzoru pro kalend ©
         jmp       short DispAll2
DispAll1:call      DispLine
DispAll2:call      DispHlp                  ; zobrazen¡ n povˆdy
         ret

DispAll  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ n povˆdy
; -----------------------------------------------------------------------------

DispHlp  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      es

; ------ zji¨tˆn¡ textu

         mov       si,offset HelpTxt8       ; text - ru¨en¡ dn–
         test      byte ptr ds:[Param],80h  ; ‡ek  se na potvrzen¡ ru¨en¡ ?
         jnz       DispHlp3                 ; je ru¨en¡
         mov       al,ds:[WAkt]             ; aktivn¡ okno
         mov       ah,ds:[EditKur]          ; kurzor

         mov       si,offset HelpTxt1       ; n povˆda ke kalend ©i
         cmp       al,1                     ; je kalend © ?
         je        DispHlp3                 ; zobrazen¡ textu n povˆdy

         mov       si,offset HelpTxt2       ; n povˆda k pozn mk m
         cmp       al,3                     ; je aktivn¡ z pisn¡k ?
         je        DispHlp3                 ; je aktivn¡ z pisn¡k

         mov       si,offset HelpTxt7       ; n povˆda - di © bˆ‘n˜ text
         cmp       ah,9                     ; je aktivn¡ bˆ‘n˜ text ?
         jae       DispHlp3                 ; je bˆ‘n˜ text
         cmp       word ptr ds:[DiaNum],0   ; je nˆjak˜ © dek ?
         je        DispHlp3                 ; nen¡ ‘ dn˜ © dek

         mov       si,offset HelpTxt3       ; n povˆda k zad n¡ hodiny
         cmp       ah,1                     ; je zad n¡ hodiny ?
         jbe       DispHlp3                 ; je zad n¡ hodiny

         mov       si,offset HelpTxt4       ; n povˆda k zad n¡ minuty
         cmp       ah,4                     ; je zad n¡ minuty ?
         jbe       DispHlp3                 ; je zad n¡ minuty
         mov       si,offset HelpTxt5       ; n povˆda - prvn¡ znak

; ------ zobrazen¡ textu n povˆdy

DispHlp3:push      ds
         pop       es                       ; ES <- DS
         mov       cl,80                    ; d‚lka textu n povˆdy
         mov       dl,0                     ; po‡ te‡n¡ pozice
         mov       dh,ds:[MaxRow]           ; posledn¡ © dek na displeji
         mov       ah,ds:[Barva5]           ; barva textu n povˆdy
         call      DispTxt                  ; zobrazen¡ textu n povˆdy

; ------ n vrat registr–

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispHlp  ENDP

; -----------------------------------------------------------------------------
;        inicializace datov‚ho souboru (CY=nedostatek pamˆti)
; -----------------------------------------------------------------------------

SoubInit PROC      NEAR

; ------ kontrola verze syst‚mu

         push      ds
         pop       es                       ; ES <- DS
         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cmp       al,3
         jb        SoubIni5                 ; n¡zk  verze syst‚mu

; ------ kontrola, zda je platn‚ prost©ed¡

         mov       cx,ds:[2ch]              ; segment prost©ed¡
         jcxz      SoubIni5                 ; nen¡ platn‚ prost©ed¡

; ------ p©¡prava k prohled v n¡ prost©ed¡

         push      ds
         mov       ds,cx                    ; adresa prost©ed¡
         xor       si,si                    ; po‡ te‡n¡ ukazatel
         mov       cx,7fffh                 ; max. velikost prost©ed¡

; ------ nalezen¡ jm‚na souboru v prost©ed¡

         xor       ax,ax                    ; hledan‚ slovo
SoubIni2:inc       si                       ; dal¨¡ bajt
         cmp       word ptr ds:[si-1],ax    ; je konec prost©ed¡ ?
         loopne    SoubIni2                 ; nalezen¡ konce prost©ed¡
         add       si,3                     ; za‡ tek jm‚na souboru

; ------ p©enesen¡ jm‚na do bufferu

         mov       di,offset Soubor         ; buffer jm‚na souboru
         mov       cx,128                   ; max. d‚lka jm‚na
         cld
SoubIni3:lodsb                              ; na‡ten¡ znaku
         call      UpCase                   ; p©evod na velk‚ p¡smeno
         stosb                              ; ulo‘en¡ znaku do bufferu
         cmp       al,0                     ; je konec jm‚na ?
         loopne    SoubIni3                 ; p©enos dal¨¡ho znaku
         pop       ds                       ; DS <- datov˜ segment

; ------ nalezen¡ konce cesty

SoubIni5:mov       si,offset Soubor         ; buffer se souborem
         cld
SoubIni6:mov       di,si                    ; £schova konce cesty
SoubIni7:lodsb                              ; na‡ten¡ znaku
         cmp       al,"\"                   ; oddˆlova‡ cesty ?
         je        SoubIni6                 ; oddˆlova‡ cesty - nov˜ konec
         cmp       al,":"                   ; oddˆlova‡ disku ?
         je        SoubIni6                 ; oddˆlova‡ disku - nov˜ konec
         cmp       al,0                     ; konec textu ?
         jne       SoubIni7                 ; nen¡ konec textu - dal¨¡ znak

; ------ p©id n¡ jm‚na datov‚ho souboru

         mov       si,offset Soub
         mov       cx,11                    ; d‚lka jm‚na
         rep       movsb                    ; p©enesen¡ jm‚na souboru

; ------ otev©en¡ souboru

         mov       dx,offset Soubor
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         jnc       SoubIn72                 ; OK
         jmp       SoubIni8                 ; nenalezen
SoubIn72:mov       bx,ax                    ; identifik tor souboru

; ------ na‡ten¡ souboru do pamˆti

         push      ds
         mov       cx,ds:[DatSize]          ; velikost bufferu
;         inc       cx                       ; o 1 bajt v¡ce pro test p©ete‡en¡
         xor       dx,dx                    ; offset
         mov       ds,ds:[DatSegm]          ; adresa bufferu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do bufferu
         pop       ds
         jnc       SoubIn73                 ; ‡ten¡ OK
         xor       ax,ax
SoubIn73:mov       ds:[DatNum],ax           ; po‡et na‡ten˜ch bajt–
;         cmp       ax,cx                    ; byl buffer p©eplnˆn ?
;         jb        SoubI731                 ; bylo na‡teno m‚nˆ dat
;         stc
;         jmp       SoubIni9                 ; p©eplnˆn¡ bufferu

; ------ uzav©en¡ souboru

SoubI731:mov       ah,3eh
         int       21h

; ------ kontrola z hlav¡ souboru

         push      ds
         mov       ds,ds:[DatSegm]
         cmp       word ptr ds:[0],"ID"
         jne       SoubIn75
         cmp       word ptr ds:[2],"RA"
         jne       SoubIn75

; ------ maxim ln¡ konec pozn mek a konec dat

         mov       si,6
         mov       dx,cs:[DatSize]          ; velikost bufferu
         dec       dx
         dec       dx                       ; maxim ln¡ offset konec pozn mek
         mov       bx,8                     ; za‡ tek pozn mek
         cmp       word ptr ds:[si],2       ; jsou pozn mky ?
         jbe       SoubI732                 ; nejsou pozn mky
         mov       bx,si                    ; offset za‡ tku definice dn–
         add       bx,ds:[si]               ; konec pozn mek
         jc        SoubI733                 ; p©ete‡en¡ konec - omezen¡
         cmp       bx,dx
         jbe       SoubI734                 ; konec je OK
SoubI733:mov       bx,dx                    ; omezen¡ konce pozn mek
SoubI732:mov       ax,bx                    ; konec pozn mek
         sub       ax,si                    ; offset dat
         mov       ds:[si],ax               ; opraven˜ za‡ tek dat

; ------ spo‡ten¡ © dk– pozn mek (pouze cel‚ pozn mky)

SoubI734:inc       si
         inc       si                       ; za‡ tek pozn mek
         xor       cx,cx                    ; ‡¡ta‡ © dk– pozn mek
         cld
         mov       ah,0
         mov       di,si                    ; £schova konce pozn mek
SoubIn74:cmp       si,bx
         jae       SoubI742                 ; je konec pozn mek
         lodsb                              ; na‡ten¡ d‚lky pozn mky
         add       si,ax                    ; adresa dal¨¡ pozn mky
         jc        SoubI742                 ; p©ete‡en¡
         cmp       si,bx                    ; je p©ete‡en¡ ?
         ja        SoubI742                 ; je p©ete‡en¡ konce
         mov       di,si                    ; adresa nov‚ pozn mky
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e pozn mek
         jb        SoubIn74                 ; dal¨¡ pozn mka
SoubI742:mov       cs:[NotEnd],di           ; adresa konce pozn mek
         mov       cs:[NotNum],cx           ; po‡et pozn mek

; ------ ovˆ©en¡ adres definic dn–

SoubI744:cmp       word ptr ds:[bx],0       ; konec ?
         je        SoubI748                 ; konec
         cmp       bx,dx                    ; je ji‘ konec ?
         jae       SoubI748                 ; konec
         mov       ax,bx                    ; sou‡asn  adresa
         add       ax,ds:[bx]               ; nov  definice
         jc        SoubI748                 ; p©ete‡en¡
         cmp       ax,dx                    ; p©ete‡en¡ konec ?
         ja        SoubI748                 ; p©ete‡en¡ konec
         mov       bx,ax                    ; nov  adresa
         jmp       short SoubI744           ; test dal¨¡ definice
SoubI748:mov       word ptr ds:[bx],0       ; ozna‡en¡ posledn¡ pozn mky
         inc       bx
         inc       bx
         mov       cs:[DatNum],bx           ; po‡et bajt– v bufferu

         xor       ax,ax                    ; p©¡znak operace OK

SoubIn75:pop       ds
         je        SoubIni9                 ; soubor je OK

; ------ neplatn˜ soubor - inicializace bufferu (vyvol v  se jako procedura !)

SoubIni8:push      es
         mov       es,ds:[DatSegm]          ; datov˜ segment
         xor       di,di
         cld
         mov       ax,"ID"                  ; text "DI"
         stosw
         mov       ax,"RA"                  ; text "AR"
         stosw
         xor       ax,ax
         stosw                              ; slovo p©¡znak– (rezervov no)
         mov       ax,3
         stosw                              ; offset za‡ tku definice dn–
         xor       ax,ax
         stosb                              ; prvn¡ © dek pozn mky - pr zdn˜
         mov       ds:[NotEnd],di           ; adresa konce pozn mek
         stosw                              ; ozna‡en¡ konce dat
         mov       word ptr ds:[NotNum],1   ; je 1 © dek pozn mky
         mov       ds:[DatNum],di           ; po‡et bajt– v bufferu
         pop       es

         clc                                ; p©¡znak operace OK

SoubIni9:ret

SoubInit ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ datov‚ho souboru
; -----------------------------------------------------------------------------

UlozSoub PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ test, zda byl soubor modifikov n

         test      byte ptr ds:[Param],4    ; byl modifikov n ?
         jz        UlozSou9                 ; nebyl modifikov n

; ------ otev©en¡ souboru

         mov       dx,offset Soubor
         xor       cx,cx
         mov       ah,3ch
         int       21h                      ; otev©en¡ souboru
         jc        UlozSou9                 ; chyba - soubor nelze vytvo©it
         mov       bx,ax                    ; identifik tor souboru

; ------ z pis souboru

         push      ds
         xor       dx,dx
         mov       cx,ds:[DatNum]           ; po‡et bajt– v souboru
         mov       ah,40h
         mov       ds,ds:[DatSegm]          ; segment dat
         int       21h                      ; ulo‘en¡ souboru
         pop       ds

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h
         and       byte ptr ds:[Param],not 4 ; zru¨en¡ p©¡znaku modifikace
         call      AktBud                   ; aktualizace bud¡ku

; ------ n vrat registr–

UlozSou9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UlozSoub ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ pozn mky z bufferu - zah jen¡ editace
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

LoadNot  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ inicializa‡n¡ vymaz n¡ edita‡n¡ho bufferu

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ds,ds:[DatSegm]          ; datov˜ segment
         mov       di,offset EditBuf        ; edita‡n¡ buffer
         mov       cx,80                    ; max. d‚lka bufferu
         cld
         mov       al," "                   ; mazac¡ znak mezery
         rep       stosb                    ; vymaz n¡ bufferu

; ------ test, zda je platn˜ © dek

         mov       cx,es:[NotAkt]           ; aktivn¡ © dek pozn mky
         cmp       cx,es:[NotNum]           ; kontrola ‡¡sla © dku pozn mky
         jae       LoadNot9                 ; neplatn‚ ‡¡slo © dku

; ------ nalezen¡ aktivn¡ho © dku

         mov       si,8                     ; adresa prvn¡ho © dku
         mov       ah,0
         jcxz      LoadNot3                 ; je to prvn¡ © dek
         cld
LoadNot1:lodsb                              ; na‡ten¡ bajtu d‚lky
         add       si,ax                    ; zv˜¨en¡ adresy na dal¨¡ © dek
         loop      LoadNot1                 ; dal¨¡ © dek

; ------ p©enesen¡ © dku do bufferu

LoadNot3:lodsb                              ; na‡ten¡ bajtu d‚lky
         xchg      ax,cx                    ; CX <- d‚lka textu pozn mky
         cmp       cl,80                    ; maxim ln¡ d‚lka textu
         jbe       LoadNot4                 ; d‚lka textu je OK
         mov       cl,80                    ; omezen¡ d‚lky textu
LoadNot4:mov       di,offset EditBuf        ; edita‡n¡ buffer
         rep       movsb                    ; p©enesen¡ pozn mky do bufferu

; ------ n vrat registr–

LoadNot9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

LoadNot  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ aktivn¡ho © dku pozn mky do bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP:CY=p©ete‡en¡ bufferu
; -----------------------------------------------------------------------------

StorNot  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ stanoven¡ d‚lky textu

         mov       es,ds:[DatSegm]          ; adresa datov‚ho bufferu
         mov       bx,MaxLNot               ; maxim ln¡ d‚lka pozn mky
StorNot1:cmp       byte ptr ds:[bx+EditBuf-1]," " ; je konec textu ?
         jne       StorNot2                 ; nalezen konec textu
         dec       bx                       ; sn¡‘en¡ ukazatele textu
         jnz       StorNot1                 ; dal¨¡ znak

; ------ kontrola ‡¡sla aktivn¡ho © dku

StorNot2:mov       cx,ds:[NotAkt]           ; aktivn¡ © dek s pozn mkou
         cmp       ds:[NotNum],cx           ; je platn‚ ‡¡slo © dku ?
         jb        StorNot9                 ; neplatn‚ ‡¡slo © dku

; ------ je nov˜ © dek

         ja        StorNot3                 ; nen¡ nov˜ © dek
;         mov       di,6                     ; offset za‡ tku definice dn–
;         add       di,es:[di]               ; adresa konce pozn mek
         mov       di,ds:[NotEnd]           ; adresa konce pozn mek
         mov       cx,bx                    ; d‚lka textu
         inc       cx                       ; + 1 bajt d‚lky
         call      InsDat                   ; vlo‘en¡ dat
         jc        StorNot9                 ; chyba - p©ete‡en¡ bufferu
         inc       word ptr ds:[NotNum]     ; zv˜¨en¡ ‡¡ta‡e © dk–
         jmp       short StorNt72           ; p©id n¡ textu

; ------ nalezen¡ aktivn¡ho © dku v souboru

StorNot3:mov       di,8                     ; adresa prvn¡ pozn mky
         mov       ah,0
         jcxz      StorNot5                 ; je © dek 0
StorNot4:mov       al,es:[di]               ; d‚lka pozn mky
         inc       di                       ; zv˜¨en¡ ukazatele
         add       di,ax                    ; p©i‡ten¡ pozn mky
         loop      StorNot4                 ; dal¨¡ © dek

; ------ rozli¨en¡, zda se © dek zkr t¡ nebo prodlou‘¡

StorNot5:mov       al,es:[di]               ; d‚lka pozn mky
         mov       cx,bx                    ; d‚lka editovan‚ho textu
         sub       cx,ax                    ; rozd¡l d‚lek
         ja        StorNot7                 ; text je del¨¡ - vlo‘en¡ dat
         jb        StorNot6                 ; text je krat¨¡ - zru¨en¡ dat

; ------ p©i shodˆ porovn n¡ text–, zda byla zmˆna

         mov       cx,bx                    ; d‚lka pozn mky
         jcxz      StorNot9                 ; texty jsou shodn‚
         mov       si,offset EditBuf        ; text z bufferu
         cld
         push      di
         inc       di
         repe      cmpsb                    ; porovn n¡ text–
         pop       di
         je        StorNot9                 ; shoda - nic se neukl d 
         jmp       short StorNot8           ; p©enesen¡ textu do bufferu

; ------ zru¨en¡ dat z bufferu

StorNot6:neg       cx                       ; rozd¡l d‚lek
         call      DelDat                   ; zru¨en¡ dat z bufferu
         jc        StorNot9
         sub       word ptr ds:[DenAdr],cx  ; sn¡‘en¡ adresy aktivn¡ho dne
         sub       word ptr ds:[NotEnd],cx  ; posun konce pozn mek
         sub       es:[6],cx                ; sn¡‘en¡ offsetu akc¡
         jmp       short StorNot8           ; p©enesen¡ textu pozn mky

; ------ vlo‘en¡ dat do bufferu

StorNot7:call      InsDat                   ; vlo‘en¡ dat
         jc        StorNot9                 ; chyba - p©ete‡en¡ bufferu
StorNt72:add       word ptr ds:[DenAdr],cx  ; zv˜¨en¡ adresy aktivn¡ho dne
         add       word ptr ds:[NotEnd],cx  ; posun konce pozn mek
         add       es:[6],cx                ; zv˜¨en¡ offsetu akc¡

; ------ p©enesen¡ textu do bufferu

StorNot8:cld
         mov       ax,bx                    ; d‚lka nov‚ pozn mky
         stosb                              ; ulo‘en¡ d‚lky pozn mky
         mov       si,offset EditBuf        ; edita‡n¡ buffer
         mov       cx,bx                    ; d‚lka textu pozn mky
         rep       movsb                    ; p©enesen¡ textu pozn mky
         or        byte ptr ds:[Param],4    ; p©¡znak modifikace kalend ©e

; ------ n vrat registr–

StorNot9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

StorNot  ENDP

; -----------------------------------------------------------------------------
;        vlo‘en¡ dat do bufferu (vytvo©en¡ m¡sta)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa v bufferu k vlo‘en¡ dat
;        CX=po‡et bajt– k vlo‘en¡
;        DS=datov˜ segment
; VSTUP:CY=p©ete‡en¡ bufferu
; -----------------------------------------------------------------------------

InsDat   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      ds

; ------ kontrola p©ete‡en¡ dat v bufferu

         mov       ax,ds:[DatNum]           ; p–vodn¡ po‡et bajt– v bufferu
         mov       si,cx                    ; po‡et bajt– k vlo‘en¡
         add       si,ax                    ; p©i‡ten¡ dat v bufferu
         jc        InsDat9                  ; p©ete‡en¡ 64 KB
         cmp       ds:[DatSize],si          ; kontrola konce bufferu
         jb        InsDat9                  ; p©ete‡en¡ velikosti bufferu
         sub       ax,di                    ; po‡et bajt– k odsunu
         jc        InsDat9                  ; chyba - adresa je za koncem dat
         mov       ds:[DatNum],si           ; nov˜ po‡et bajt– v bufferu

; ------ odsun dat

InsDat2: xchg      ax,cx                    ; CX <- po‡et bajt– k odsunu
         dec       si                       ; posledn¡ bajt dat
         mov       di,si                    ; nov˜ konec dat
         sub       si,ax                    ; star˜ konec dat
         push      es
         pop       ds                       ; DS <- ES segment bufferu
         std
         rep       movsb                    ; odsun dat v bufferu
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

InsDat9: pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

InsDat   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ dat z bufferu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa dat ke zru¨en¡
;        CX=po‡et bajt– ke zru¨en¡ (po‡et bajt– se omez¡ do konce bufferu)
;        DS=datov˜ segment
; VSTUP:CY=chybn  adresa
; -----------------------------------------------------------------------------

DelDat   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      si
         push      di
         push      ds

; ------ v˜po‡et po‡tu zbyl˜ch bajt–

         mov       ax,ds:[DatNum]           ; po‡et bajt– v bufferu
         sub       ax,di                    ; po‡et zbyl˜ch bajt– v bufferu
         jbe       DelDat9                  ; nejsou ‘ dn  data nebo p©ete‡en¡

; ------ omezen¡ po‡tu bajt– ke zru¨en¡

         cmp       ax,cx                    ; je po‡et bajt– OK ?
         ja        DelDat2                  ; po‡et bajt– je OK
         mov       cx,ax                    ; omezen¡ po‡tu bajt– ke zru¨en¡
DelDat2:

; ------ p©¡sun zbytku dat

DelDat3: sub       word ptr ds:[DatNum],cx  ; sn¡‘en¡ velikosti dat
         push      cx
         mov       si,di                    ; adresa dat ke zru¨en¡
         add       si,cx                    ; za‡ tek dat k p©¡sunu
         xchg      ax,cx                    ; CX <- zbyl  data
         sub       cx,ax                    ; po‡et bajt– k p©¡sunu
         cld
         push      es
         pop       ds
         rep       movsb                    ; p©¡sun zbytku dat
         pop       cx
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

DelDat9: pop       ds
         pop       di
         pop       si
         pop       ax
         ret

DelDat   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                   Zobrazen¡ kalend ©e
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;þ

; ------ zad n¡ znaku

EditTim: cmp       bl," "
         je        EditTim2
         cmp       bl,"9"
         ja        EditTim1
         cmp       bl,"0"
         jae       EditTim2
EditTim1:mov       al,9                     ; po‡ tek © dku
         mov       si,offset EditBuf+9
         jmp       EditLin7                 ; editace znaku

; ------ vlo‘en¡ znaku do © dku

EditTim2:mov       ds:[si],bl               ; vlo‘en¡ znaku do © dku

; ------ oprava oddˆlova‡e ‡asu

         cmp       word ptr ds:[EditBuf],"  " ; je zad na hodina ?
         mov       byte ptr ds:[EditBuf+2],":" ; oddˆlova‡ ‡asu
         jne       EditTim3                 ; je zad n ‡as
         mov       word ptr ds:[EditBuf+2],"  "
         mov       word ptr ds:[EditBuf+4],"  "
         mov       word ptr ds:[EditBuf+6],"  "

; ------ oprava indik toru pro ‡as bud¡ku

EditTim3:cmp       word ptr ds:[EditBuf+6],"  " ; je zad n ‡as bud¡ku ?
         mov       byte ptr ds:[EditBuf+5]," "   ; ozna‡en¡ vypnut¡ bud¡ku
         je        EditTRgh                 ; bud¡k je vypnut
         mov       byte ptr ds:[EditBuf+5],"/" ; ozna‡en¡ zapnut¡ bud¡ku

; ------ o pozici vpravo

EditTRgh:inc       ax
         cmp       al,2
         je        EditTRgh
         cmp       al,5
         je        EditTRgh
         cmp       al,8
         je        EditTRgh
         cmp       word ptr ds:[EditBuf],"  " ; je zad na hodina ?
         jne       EditLi89                 ; je zad na hodina
         cmp       al,2
         jb        EditLi89                 ; kurzor na hodinˆ - OK
         cmp       al,8
         jb        EditTRgh                 ; zak zan  pozice
EditLi89:jmp       EditRgh2

; ------ o pozici vlevo

EditTLft:or        al,al
         jz        EditLi89
EditTLf2:dec       ax
         cmp       al,2
         je        EditTLf2
         cmp       al,5
         je        EditTLf2
         cmp       al,8
         je        EditTLf2
         cmp       word ptr ds:[EditBuf],"  " ; je zad na hodina ?
         jne       EditLi89                 ; je zad na hodina
         cmp       al,2
         jae       EditTLft
         jmp       short EditLi89

; ------ konec

EditTEnd:mov       al,9
EditLi87:jmp       short EditLi89

; ------ za‡ tek

EditTHom:mov       al,0
         jmp       short EditLi87

; ------ o slovo vpravo

EditTCRg:cmp       word ptr ds:[EditBuf],"  " ; je zad na hodina ?
         je        EditTEnd                 ; nen¡ zad na hodina
         inc       ax
         cmp       al,3
         je        EditLi89
         cmp       al,6
         je        EditLi89
         cmp       al,9
         je        EditLi89
         jmp       short EditTCRg

; ------ o slovo vlevo

EditTCLf:cmp       word ptr ds:[EditBuf],"  " ; je zad na hodina ?
         je        EditTHom                 ; nen¡ zad na hodina
         cmp       al,0
         je        EditLi89
EditTCL2:dec       ax
         cmp       al,0
         je        EditLi89
         cmp       al,3
         je        EditLi89
         cmp       al,6
         je        EditLi89
         jmp       short EditTCL2

; -----------------------------------------------------------------------------
;        editace © dku (BX=kl vesa)
; -----------------------------------------------------------------------------

EditLine PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ skok na funkci

         push      ds
         pop       es
         mov       ah,0
         mov       al,ds:[EditKur]          ; kurzor na © dku
         mov       dh,0                     ; po‡ te‡n¡ pozice
         mov       dl,MAXLNOT               ; max. d‚lka © dku pozn mek
         cmp       byte ptr ds:[WAkt],2     ; je di © ?
         jne       EditLi11                 ; nen¡ di ©
         mov       dl,MAXLDIAR              ; max. d‚lka © dku di ©e
         mov       dh,9                     ; po‡ te‡n¡ pozice
EditLi11:
         mov       si,offset EditBuf        ; edita‡n¡ buffer
         add       si,ax                    ; adresa znaku v bufferu

; ------ test, zda je editace ‡asu

         cmp       al,9
         jae       EditLi12                 ; nen¡ editace ‡asu
         cmp       byte ptr ds:[WAkt],2     ; je di © ?
         jne       EditLi12                 ; nen¡ di ©

; ------ skok na obsluhu funkce editace hodin

         call      JumpBX

         dw        4b00h,EditTLft           ; o pozici vlevo
         dw        4d00h,EditTRgh           ; posun kurzoru vpravo
         dw        4700h,EditTHom           ; za‡ tek © dku
         dw        4f00h,EditTEnd           ; konec © dku
         dw        7300h,EditTCLf           ; slovo vlevo
         dw        7400h,EditTCRg           ; slovo vpravo

         dw        0e7fh,EditTCLf           ; o slovo vlevo
         dw        0e08h,EditTLft           ; BS o znak vlevo

         dw        0,EditTim                ; neobslou‘en  kl vesa

; ------ obsluha bˆ‘n‚ho textu

EditLi12:call      JumpBX

         dw        4b00h,EditLeft           ; o pozici vlevo
         dw        4d00h,EditRght           ; posun kurzoru vpravo
         dw        4700h,EditHome           ; za‡ tek © dku
         dw        4f00h,EditEnd            ; konec © dku
         dw        7300h,EditCLft           ; slovo vlevo
         dw        7400h,EditCRgh           ; slovo vpravo

         dw        0e08h,EditBS             ; BS zru¨en¡ znaku p©ed kurzorem
         dw        5300h,EditDel            ; zru¨en¡ znaku za kurzorem
         dw        1414h,EditCT             ; zru¨en¡ slova za kurzorem
         dw        0e7fh,EditCBS            ; zru¨en¡ slova p©ed kurzorem

         dw        0,EditLin7               ; neobslou‘en  kl vesa

; ------ test, zda je platn˜ znak ASCII

EditLin7:cmp       bx,300h
         je        EditLi72
         cmp       bl,0                     ; je ASCII znak ?
         je        EditLin9                 ; nen¡ ASCII znak

; ------ vlo‘en¡ znaku

EditLi72:
EditLi76:mov       cx,80-1                  ; d‚lka edita‡n¡ho bufferu - 1
         sub       cx,ax                    ; zbytek textu v bufferu - 1
         mov       di,offset EditBuf+79     ; edita‡n¡ buffer
         mov       si,di
         dec       si
         std
         rep       movsb
         mov       ds:[di],bl
         inc       dx                       ; povoleno o 1 znak nav¡c

; ------ posun kurzoru o pozici vpravo

EditRght:inc       ax                       ; zv˜¨en¡ kurzoru na © dku
         cmp       al,dl                    ; je kurzor na konci © dku ?
         jge       EditLin8                 ; je na konci © dku
EditRgh2:mov       ds:[EditKur],al          ; nov  pozice kurzoru

; ------ nov‚ zobrazen¡ © dku

EditLin8:call      DispLine                 ; nov‚ zobrazen¡ © dku

; ------ n vrat registr–

EditLin9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditLine ENDP


; ------ o pozici vlevo

EditLeft:cmp       al,0
         je        EditLin8
         dec       ax                       ; sn¡‘en¡ pozice kurzoru
         cmp       al,dh
         jae       EditRgh2
         mov       al,7
         cmp       word ptr ds:[EditBuf],"  " ; zad na hodina ?
         jne       EditRgh2                 ; zad na hodina
         mov       al,1                     ; konec hodiny
         jmp       short EditRgh2

; ------ za‡ tek © dku HOME

EditHome:cmp       al,dh
         mov       al,dh                    ; za‡ tek © dku
         jne       EditRgh2
         mov       al,0
         jmp       short EditRgh2

; ------ konec © dku END

EditEnd: mov       al,dl
         dec       ax                       ; posledn¡ znak na © dku
         mov       si,offset EditBuf        ; edita‡n¡ buffer
         add       si,ax                    ; posledn¡ znak v bufferu
         cmp       byte ptr ds:[si]," "     ; je nˆjak˜ znak ?
         jne       EditRgh2                 ; je nˆjak˜ znak - plat¡
EditEnd2:cmp       byte ptr ds:[si-1]," "   ; je konec © dku ?
         jne       EditRgh2                 ; je konec © dku
         dec       si                       ; sn¡‘en¡ adresy v © dku
         dec       ax                       ; sn¡‘en¡ ukazatele kurzoru
         cmp       al,dh
         jne       EditEnd2                 ; test dal¨¡ pozice
         jmp       short EditRgh2

; ------ zru¨en¡ znaku p©ed kurzorem

EditBS:  cmp       al,dh                    ; je za‡ tek © dku ?
         je        EditRgh2                 ; je za‡ tek © dku
         dec       ax                       ; sn¡‘en¡ ukazatele © dku

; ------ zru¨en¡ znaku za kurzorem

EditDel: call      EDelCh                   ; zru¨en¡ znaku za kurzorem
EditDel3:jmp       short EditRgh2

; ------ posun o slovo vlevo

EditCLft:cmp       al,dh                    ; je ji‘ za‡ tek © dku ?
         jne       EditCLf2                 ; nen¡ za‡ tek © dku
         cmp       al,0
         je        EditDel3                 ; je ji‘ za‡ tek © dku
         jmp       EditTCLf

EditCLf2:dec       si
         dec       al
         jz        EditDel3
         cmp       al,dh
         je        EditDel3
         mov       cx,ds:[si-1]             ; p©ede¨l˜ a tento znak
         call      TestOdd                  ; test, zda je za‡ tek slova
         jc        EditDel3                 ; je za‡ tek slova
         jmp       short EditCLf2           ; dal¨¡ znak

; ------ posun o slovo vpravo

EditCRgh:cmp       al,dl
         je        EditEnd
         inc       si                       ; zv˜¨en¡ adresy
         inc       ax                       ; zv˜¨en¡ ukazatele
         mov       cx,ds:[si-1]             ; p©ede¨l˜ a tento znak
         call      TestOdd                  ; test, zda je za‡ tek slova
         jnc       EditCRgh                 ; nen¡ za‡ tek - dal¨¡ posun
         jmp       short EditDel3           ; je za‡ tek slova

; ------ zru¨en¡ slova za kurzorem

EditCT:  mov       bx,80                    ; max. po‡et pokus–
EditCT2: mov       cx,ds:[si]               ; dal¨¡ 2 znaky
         call      TestOdd                  ; test, zda bude za‡ tek slova
         jc        EditDel                  ; zru¨en¡ posledn¡ho znaku
         call      EDelCh                   ; zru¨en¡ znaku za kurzorem
         dec       bx                       ; ‡¡ta‡ pokus–
         jnz       EditCT2                  ; dal¨¡ pokus
         jmp       short EditDel3

; ------ zru¨en¡ slova p©ed kurzorem

EditCBS: cmp       al,dh                    ; je za‡ tek © dku ?
         je        EditDel3
EditCBS2:dec       si                       ; sn¡‘en¡ adresy
         dec       al                       ; sn¡‘en¡ ukazatele
         mov       cx,ds:[si-1]             ; p©ede¨l˜ a tento znak
         call      EDelCh                   ; zru¨en¡ znaku
         cmp       al,dh                    ; je za‡ tek © dku ?
         je        EditDel3                 ; je za‡ tek © dku
         call      TestOdd                  ; test, zda je za‡ tek slova
         jc        EditDel3                 ; byl za‡ tek
         jmp       short EditCBS2

; -----------------------------------------------------------------------------
;        zru¨en¡ znaku na pozici AL
; -----------------------------------------------------------------------------

EDelCh   PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      es

; ------ zru¨en¡ znaku nad kurzorem

         push      ds
         pop       es
         mov       ch,0
         mov       cl,al                    ; pozice ukazatele
         mov       si,offset EditBuf        ; edita‡n¡ buffer
         add       si,cx                    ; adresa znaku v bufferu
         neg       cx
         add       cx,79                    ; po‡et zbyl˜ch znak– v bufferu - 1
         mov       di,si
         inc       si
         cld
         rep       movsb                    ; p©¡sun zbytku dat
         mov       byte ptr ds:[di]," "     ; nov˜ konec - mezera

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

EDelCh   ENDP

; -----------------------------------------------------------------------------
;     test znak– CH,CL zda je za‡ tek slova (CY=je za‡ tek slova, ZY=je st©ed)
; -----------------------------------------------------------------------------

TestOdd  PROC      NEAR

         push      ax
         mov       al,cl
         call      KonvOdd                  ; konverze 1. znaku na oddˆlova‡
         mov       ah,al
         mov       al,ch
         call      KonvOdd                  ; konverze 2. znaku na oddˆlova‡
         cmp       ah,al                    ; je za‡ tek slova ?
         pop       ax
         ret

TestOdd  ENDP

; -----------------------------------------------------------------------------
;                                  KonvOdd
;                          konverze znaku na oddˆlova‡
; -----------------------------------------------------------------------------
; VSTUP: AL=znak
; VSTUP:AL=hodnota znaku (0=mezera, 1=jin˜ znak, 2=p¡smeno)
; -----------------------------------------------------------------------------

KonvOdd  PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ 0: mezera

         mov       bl,0                     ; 0=mezera
         cmp       al," "
         je        KonvOdd9                 ; je mezera

; ------ 2: mal‚ p¡smeno

         mov       bl,2                     ; p¡smeno
         cmp       al,"a"
         jb        KonvOdd3                 ; nen¡ mal‚ p¡smeno
         cmp       al,"z"
         jbe       KonvOdd9                 ; je mal‚ p¡smeno

; ------ 2: velk‚ p¡smeno

KonvOdd3:cmp       al,"A"
         jb        KonvOdd4                 ; nen¡ velk‚ p¡smeno
         cmp       al,"Z"
         jbe       KonvOdd9                 ; velk‚ p¡smeno

; ------ 2: ‡¡slice

KonvOdd4:cmp       al,"0"
         jb        KonvOdd5
         cmp       al,"9"
         jbe       KonvOdd9                 ; ‡¡slice

; ------ 2: jin‚ textov‚ znaky

KonvOdd5:cmp       al,"_"
         je        KonvOdd9                 ; podtr‘¡tko
         cmp       al,"*"
         je        KonvOdd9
         cmp       al,"?"
         je        KonvOdd9

; ------ 1: ostatn¡ znaky

         mov       bl,1                     ; jinak jin˜ znak

; ------ n vrat registr–

KonvOdd9:mov       al,bl                    ; hodnota znaku
         pop       bx
         ret

KonvOdd  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ editovan‚ho © dku
; -----------------------------------------------------------------------------

DispLine PROC      NEAR

; ------ test, zda je editovan˜ © dek zobrazen

         cmp       byte ptr ds:[WAkt],1     ; je zobrazen kalend © ?
         jne       DispLin1                 ; nen¡ zobrazen kalend ©
         ret

; ------ £schova registr–

DispLin1:push      ax
         push      cx
         push      dx
         push      si
         push      es

; ------ po‡ te‡n¡ pozice okna

         mov       dx,1*256 + 26            ; po‡ te‡n¡ pozice di ©e
         mov       cl,MaxLDiar              ; d‚lka © dku di ©e
         mov       ah,byte ptr ds:[DiaAkt]
         sub       ah,byte ptr ds:[DiaTop]

         cmp       byte ptr ds:[WAkt],2     ; je di © ?
         je        DispLin2                 ; je di ©

         mov       dx,11*256 + 1            ; po‡ te‡n¡ pozice pozn mek
         mov       cl,MaxLNot               ; d‚lka © dku pozn mek
         mov       ah,byte ptr ds:[NotAkt]
         sub       ah,byte ptr ds:[NotTop]

; ------ zobrazen¡ editovan‚ho © dku

DispLin2:add       dh,ah                    ; © dek na obrazovce
         mov       si,offset EditBuf        ; edita‡n¡ buffer
         mov       ah,ds:[Barva3]           ; barva kurzoru
         push      ds
         pop       es
         call      DispTxt                  ; zobrazen¡ editovan‚ho © dku

; ------ zobrazen¡ kurzoru

         cmp       byte ptr ds:[WAkt],2     ; je aktivn¡ di © ?
         jne       DispLin4                 ; nen¡ aktivn¡ di ©
         cmp       word ptr ds:[DiaNum],0   ; je nˆjak˜ © dek ?
         jne       DispLin4                 ; je nˆjak˜ © dek
         call      KurzOff                  ; vypnut¡ kurzoru
         jmp       short DispLin6
DispLin4:sub       dl,cl                    ; n vrat po‡ te‡n¡ pozice © dku
         add       dl,ds:[EditKur]          ; pozice kurzoru
         call      SetKurz                  ; nastaven¡ pozice kurzoru

; ------ n vrat registr–

DispLin6:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispLine ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ kalend ©e
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) ukazatel © dku na obrazovce
;                   SS:[BP-2] (1) skute‡n˜ den v mˆs¡ci pro zobrazen¡
;                   SS:[BP-3] (1) aktu ln¡ mˆs¡c
;                   SS:[BP-4] (1) aktu ln¡ den
;                   SS:[BP-5] (1) po‡et dn– v mˆs¡ci
;                   SS:[BP-6] (1) den v t˜dnu
;                   SS:[BP-8] (2) rok
;                   SS:[BP-9] (1) ukazatel dne v mˆs¡ci
; -----------------------------------------------------------------------------

DispKal  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ vytvo©en¡ bufferu v z sobn¡ku

         sub       sp,2*26 + 10

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       byte ptr ss:[bp-1],3 ; © dek na obrazovce
         push      ss
         pop       es

; ------ stanoven¡ dne, mˆs¡ce a roku

         mov       ax,word ptr ds:[Den]
         mov       dx,word ptr ds:[Den+2]
         call      KonvNDat                 ; konverze na datum
         mov       ss:[bp-8],cx             ; rok
         mov       ss:[bp-6],ax             ; den v t˜dnu a po‡et dn– mˆs¡ce
         mov       ss:[bp-4],bx             ; den a mˆs¡c

; ------ skute‡n˜ den pro zobrazen˜ ukazatele

         mov       ah,80h                   ; den je neplatn˜
         cmp       cx,ds:[ARok]             ; je skute‡n˜ rok ?
         jne       DispKal0                 ; nen¡ skute‡n˜ rok
         cmp       bh,ds:[AMesic]           ; je skute‡n˜ mˆs¡c ?
         jne       DispKal0                 ; nen¡ skute‡n˜ mˆs¡c
         mov       ah,ds:[ADen]             ; skute‡n˜ den v mˆs¡ci
DispKal0:mov       ss:[bp-2],ah             ; skute‡n˜ den v mˆs¡ci

; ------ stanoven¡ prvn¡ho dne v t˜dnu

         xor       ah,ah
         add       al,7*5+1                 ; posun ke kladn‚mu ‡¡slu
         sub       al,bl                    ; ode‡ten¡ dne
         mov       bl,7                     ; po‡et dn– v t˜dnu
         div       bl                       ; v˜po‡et 1.dne
         neg       ah
         inc       ah
         mov       ss:[bp-9],ah             ; ukazatel dne v mˆs¡ci

; ------ dek¢dov n¡ horn¡ho © dku kalend ©e

         mov       di,sp                    ; buffer v z sobn¡ku
         cld
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva
         mov       al,218                   ; lev˜ horn¡ roh
         stosw                              ; ulo‘en¡ lev‚ho horn¡ho rohu
         mov       al,196                   ; vodorovn  linka
         mov       cx,7                     ; d‚lka linky
         rep       stosw                    ; ulo‘en¡ vodorovn‚ linky
         mov       cl,offset(KalNdp0-KalNdp) ; d‚lka textu
         mov       si,offset KalNdp         ; text nadpisu
         cmp       byte ptr ds:[WAkt],1     ; je aktivn¡ kalend © ?
         jne       DispKal1                 ; nen¡ aktivn¡
         mov       ah,ds:[Barva3]           ; barva kurzoru
DispKal1:lodsb
         stosw
         loop      DispKal1                 ; dek¢dov n¡ textu kalend ©e
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva
         mov       al,196
         mov       cl,7
         rep       stosw                    ; zbytek ‡ ry
         mov       al,194
         stosw                              ; prav˜ okraj

; ------ zobrazen¡ horn¡ho © dku kalend ©e

         mov       si,sp                    ; buffer s textem
         xor       dx,dx                    ; pozice a © dek
         mov       cl,26                    ; d‚lka © dku
         call      DispStr                  ; zobrazen¡ horn¡ho okraje

; ------ dek¢dov n¡ mˆs¡ce a roku

         mov       di,sp                    ; buffer v z sobn¡ku
         cld
         mov       ch,0
         mov       cl,ss:[bp-3]             ; mˆs¡c
         mov       si,offset Mesice         ; tabulka mˆs¡c–
DispKal2:dec       cx
         jz        DispKal3                 ; mˆs¡c nalezen
         add       si,ds:[si]               ; adresa dal¨¡ho mˆs¡ce
         jmp       short DispKal2           ; dal¨¡ mˆs¡c
DispKal3:mov       cx,ds:[si]               ; d‚lka textu mˆs¡ce
         inc       si
         inc       si
         dec       cx
         dec       cx
         mov       ah,ds:[Barva2]           ; barva textu
DispKal4:lodsb
         stosw
         loop      DispKal4
         mov       al," "
         stosw
         mov       bh,ah                    ; barva
         mov       ax,ss:[bp-8]             ; rok
         mov       bl,0                     ; oddˆlova‡ © d– nen¡
         call      DekNumW                  ; dek¢dov n¡ ‡¡sla roku

; ------ zobrazen¡ mˆs¡ce a roku

         mov       bx,di                    ; adresa konce textu
         sub       bx,sp                    ; d‚lka textu * 2
         shr       bx,1                     ; d‚lka textu (znak–)
         push      bx                       ; £schova d‚lky textu
         mov       dx,100h                  ; pozice a © dek
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         mov       al,179                   ; lev˜ okraj
         call      Disp1Chr                 ; zobrazen¡ lev‚ho okraje
         mov       cl,24                    ; vnit©n¡ ¨¡©ka
         sub       cl,bl                    ; zbytek na okraje
         shr       cl,1                     ; lev  mezera
         mov       bl,cl                    ; £schova prav‚ho okraje
         adc       bl,0                     ; lich  mezera vpravo
         mov       al," "                   ; mezera
         call      DispChr                  ; lev  oddˆlovac¡ mezera
         pop       cx                       ; d‚lka textu
         mov       si,sp
         call      DispStr                  ; zobrazen¡ textu mˆs¡ce a roku
         mov       cl,bl                    ; prav˜ okraj
         call      DispChr                  ; prav  mezera
         mov       al,179                   ; prav˜ okraj
         call      Disp1Chr                 ; zobrazen¡ prav‚ho okraje

; ------ zobrazen¡ nadpisu - dny v t˜dnu

         mov       si,offset DnyNadp        ; text nadpisu
         mov       cx,offset(DnyNadp0-DnyNadp)-2 ; d‚lka textu
         mov       di,sp                    ; buffer v z sobn¡ku
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva
         mov       dh,ds:[Barva2]           ; zv˜raznˆn  barva
         cld
DispKl51:lodsb
         cmp       al,0
         jne       DispKl52
         xchg      ah,dh
         jmp       short DispKl51
DispKl52:stosw
         loop      DispKl51
         mov       cl,offset(DnyNadp0-DnyNadp)-2 ; d‚lka textu
         mov       si,sp
         mov       dx,200h
         call      DispStr

; ------ inicializa‡n¡ vymaz n¡ © dku pro dek¢dov n¡ dn– mˆs¡ce

DispKal6:mov       di,sp                    ; buffer © dku
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         cld
         mov       al,179                   ; lev˜ okraj
         stosw                              ; ulo‘en¡ lev‚ho okraje
         mov       al," "                   ; mezera
         mov       cx,24
         rep       stosw                    ; ulo‘en¡ mezery
         mov       al,179                   ; prav˜ okraj
         stosw                              ; ulo‘en¡ prav‚ho okraje

; ------ p©¡prava k dek¢dov n¡ dn– mˆs¡ce

DispKl61:mov       al,ss:[bp-9]             ; ukazatel dne v mˆs¡ci
         mov       cx,7                     ; po‡et dn–
         mov       di,sp                    ; buffer k dek¢dov n¡ dn–
         add       di,3*2                   ; za‡ tek k dek¢dov n¡

; ------ ur‡en¡ barvy ‡¡sla dne

DispKl62:mov       ah,ds:[Barva1]           ; bˆ‘n  barva
         mov       dh,ds:[Barva32]          ; kurzor
         cmp       cl,1                     ; je nedˆle ?
         jne       DispKl63                 ; nen¡ nedˆle
         mov       ah,ds:[Barva2]           ; bˆ‘n  barva vysv¡cen 
         mov       dh,ds:[Barva42]          ; kurzor zv˜raznˆn˜

; ------ dek¢dov n¡ ‡¡sla dne v mˆs¡ci

DispKl63:cmp       al,1                     ; je platn‚ ‡¡slo ?
         jl        DispKl64                 ; nen¡ platn‚ ‡¡slo
         cmp       al,ss:[bp-5]             ; je za koncem mˆs¡ce ?
         jg        DispKl64                 ; je za koncem mˆs¡ce
         call      DekRNum                  ; dek¢dov n¡ ‡¡sla mˆs¡ce

; ------ oprava barvy pro kurzor

DispKl64:cmp       al,ss:[bp-4]             ; je to aktu ln¡ den ?
         jne       DispKl65                 ; nen¡ to aktu ln¡ den
         mov       ah,ds:[Barva32]
         mov       es:[di-1],ah             ; oprava barvy
         mov       es:[di+1],dh
         mov       es:[di+3],dh
         mov       es:[di+5],ah

; ------ indik tory skute‡n‚ho dne

DispKl65:cmp       al,ss:[bp-2]             ; je skute‡n˜ den v mˆs¡ci ?
         jne       DispKl66                 ; nen¡ skute‡n˜ den v mˆs¡ci
         mov       byte ptr es:[di-2],"<"   ; lev˜ indik tor
         mov       byte ptr es:[di+4],">"   ; prav˜ indik tor

; ------ p©¡prava pro dal¨¡ den v t˜dnu

DispKl66:inc       al                       ; zv˜¨en¡ ‡¡sla dne
         add       di,3*2                   ; zv˜¨en¡ adresy v bufferu
         loop      DispKl62                 ; dek¢dov n¡ dal¨¡ho dne
         mov       ss:[bp-9],al             ; nov˜ ukazatel dne v mˆs¡ci

; ------ zobrazen¡ jednoho © dku se dny

         mov       si,sp                    ; adresa bufferu s textem
         mov       cl,26                    ; d‚lka © dku
         mov       dh,ss:[bp-1]             ; © dek
         mov       dl,0
         call      DispStr                  ; zobrazen¡ © dku
         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dku

; ------ p©¡prava pro dal¨¡ © dek

         mov       al,ss:[bp-9]             ; ukazatel data
         cmp       al,36                    ; jsou ji‘ v¨echny dny ?
         ja        DispKal7
         jmp       DispKal6                 ; zobrazen¡ dal¨¡ch dn–

; ------ inicializace © dku pro absolutn¡ ‡¡slo dne

DispKal7:mov       di,sp                    ; buffer
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva
         mov       si,offset KalDen
         mov       cx,offset(KalDen0-KalDen)
         cld
DispKl72:lodsb
         stosw
         loop      DispKl72

; ------ dek¢dov n¡ absolutn¡ho ‡¡slo dne

         mov       di,sp                    ; buffer v z sobn¡ku
         add       di,8*2                   ; p©esko‡en¡ textu "Den:"
         mov       bh,ah                    ; barva textu
         mov       bl,0                     ; oddˆlova‡ © d– nen¡
         mov       ax,word ptr ds:[Den]     ; abolutn¡ ‡¡slo dne
         mov       dx,word ptr ds:[Den+2]
         add       ax,1                     ; korekce ‡¡sla dne
         adc       dx,0
         call      DekNum                   ; dek¢dov n¡ ‡¡sla dne

; ------ zobrazen¡ absolutn¡ho ‡¡sla dne

         mov       si,sp
         mov       cl,26
         mov       dx,9*256                 ; © dek a pozice
         call      DispStr                  ; zobrazen¡ © dku

; ------ n vrat registr–

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispKal  ENDP

; -----------------------------------------------------------------------------
;                  Zobrazen¡ pozn mky
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) ukazatel © dku na obrazovce
;                   SS:[BP-2] (1) ‡¡ta‡ © dk– k zobrazen¡
;                   SS:[BP-4] (2) ‡¡ta‡ © dk– pozn mek
;                   SS:[BP-6] (2) adresa © dku pozn mky
;                   SS:[BP-8] (2) ‡¡ta‡ aktivn¡ho © dku
; -----------------------------------------------------------------------------

DispNot  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ vytvo©en¡ bufferu v z sobn¡ku

         sub       sp,2*(MaxLNot+2) + 8

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       al,byte ptr ds:[NotRad]  ; po‡et © dk– pozn mky
         mov       ah,11                    ; © dek na obrazovce
         mov       ss:[bp-2],ax             ; ukazatel a ‡¡ta‡ © dk–
         push      ss
         pop       es

; ------ nalezen¡ adresy © dku pozn mky

         mov       cx,ds:[NotTop]           ; ‡¡slo prvn¡ho © dku pozn mek
         xor       ax,ax
         cmp       byte ptr ds:[WAkt],3     ; je aktivn¡ z pisn¡k ?
         jne       DispNt10                 ; nen¡ aktivn¡ z pisn¡k
         mov       ax,ds:[NotAkt]           ; aktivn¡ © dek
         sub       ax,cx                    ; oprava o prvn¡ © dek
         inc       ax                       ; p©ednastaven¡
DispNt10:mov       ss:[bp-8],ax             ; ‡¡ta‡ aktivn¡ho © dku
         mov       ax,ds:[NotNum]           ; po‡et © dk– pozn mek
         sub       ax,cx                    ; zbyl˜ po‡et © dk–
         mov       ss:[bp-4],ax             ; ‡¡ta‡ © dk– pozn mek
         mov       si,8                     ; adresa prvn¡ho © dku
         jcxz      DispNt13                 ; je © dek 0
         push      ds
         mov       ds,ds:[DatSegm]          ; adresa segmentu
         mov       ah,0
         cld
DispNt11:lodsb                              ; d‚lka textu
         add       si,ax                    ; adresa dal¨¡ho © dku
         loop      DispNt11                 ; dal¨¡ © dek
         pop       ds
DispNt13:mov       ss:[bp-6],si             ; adresa © dku pozn mky

; ------ dek¢dov n¡ oddˆlovac¡ ‡ ry

         mov       di,sp                    ; buffer
         cld
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva
         mov       al,195                   ; lev˜ okraj
         stosw                              ; ulo‘en¡ lev‚ho okraje
         mov       al,196                   ; vodorovn  ‡ ra
         mov       cx,7                     ; d‚lka lev‚ ‡ ry
         rep       stosw                    ; ulo‘en¡ lev‚ ‡ ry
         mov       cl,9
         mov       si,offset PamNdp         ; text nadpisu
         cmp       byte ptr ds:[WAkt],3     ; je aktivn¡ z pisn¡k ?
         jne       DispNot2
         mov       ah,ds:[Barva3]           ; je aktivn¡
DispNot2:lodsb
         stosw
         loop      DispNot2                 ; dek¢dov n¡ textu
         mov       ah,ds:[Barva1]           ; zase bˆ‘n  barva
         mov       al,196                   ; vodorovn  ‡ ra
         mov       cl,8
         rep       stosw                    ; prav  ‡ ra
         mov       al,180
         stosw                              ; prav˜ okraj

; ------ zobrazen¡ oddˆlovac¡ ‡ ry

         mov       si,sp                    ; text v bufferu
         mov       dx,0a00h                 ; © dek a pozice
         mov       cl,MaxLNot+2             ; d‚lka textu
         call      DispStr                  ; zobrazen¡ © dku

; ------ p©¡prava barvy © dku pozn mky

DispNot5:mov       dh,ds:[Barva1]           ; bˆ‘n  barva textu
         mov       ah,dh
         dec       word ptr ss:[bp-8]       ; ‡¡ta‡ aktivn¡ho © dku
         jnz       DispNot6                 ; nen¡ aktivn¡ © dek
         cmp       byte ptr ds:[WAkt],3     ; je aktivn¡ z pisn¡k ?
         jne       DispNot6                 ; nen¡ aktivn¡
         mov       dh,ds:[Barva3]           ; barva kurzoru

; ------ vymaz n¡ © dku pozn mky

DispNot6:cld
         mov       di,sp
         mov       al,179
         stosw
         xchg      ax,dx
         mov       al," "
         mov       cx,24
         rep       stosw
         mov       al,179
         xchg      ax,dx
         stosw
         xchg      ax,dx

; ------ test, zda je dal¨¡ © dek k dek¢dov n¡

         cmp       word ptr ds:[bp-4],0     ; je dal¨¡ © dek pozn mky ?
         je        DispNot8                 ; nen¡ dal¨¡ © dek pozn mky
         dec       word ptr ds:[bp-4]       ; sn¡‘en¡ ‡¡ta‡e © dk– pozn mek

; ------ dek¢dov n¡ textu pozn mky

         mov       di,sp
         add       di,2
         mov       si,ss:[bp-6]             ; adresa © dku
         push      ds
         mov       ds,ds:[DatSegm]          ; adresa segmentu
         mov       ch,0
         mov       cl,ds:[si]
         inc       si
         inc       cx
         add       ss:[bp-6],cx             ; adresa dal¨¡ho © dku
         dec       cx
         jz        DispNt72
         cmp       cl,MaxLNot
         jb        DispNot7
         mov       cl,MaxLNot               ; omezen¡ d‚lky textu
DispNot7:lodsb
         stosw
         loop      DispNot7
DispNt72:pop       ds

; ------ zobrazen¡ © dku s pozn mkou

DispNot8:mov       si,sp
         mov       dl,0
         mov       dh,ss:[bp-1]             ; © dek na obrazovce
         mov       cl,26                    ; d‚lka © dku
         call      DispStr                  ; zobrazen¡ © dku

; ------ p©¡prava pro dal¨¡ © dek

         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ © dku na obrazovce
         dec       byte ptr ss:[bp-2]       ; ‡¡ta‡ © dk– k zobrazen¡
         jnz       DispNot5                 ; dek¢dov n¡ dal¨¡ho © dku

; ------ dek¢dov n¡ spodn¡ho © dku

         cld
         mov       di,sp                    ; buffer v z sobn¡ku
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         mov       al,192                   ; lev˜ spodn¡ okraj
         stosw                              ; ulo‘en¡ lev‚ho spodn¡ho okraje
         mov       cx,MaxLNot               ; vnit©n¡ d‚lka © dku
         mov       al,196                   ; vodorovn  linka
         rep       stosw                    ; ulo‘en¡ vodorovn‚ linky
         mov       al,193                   ; prav˜ okraj
         stosw                              ; ulo‘en¡ prav‚ho okraje

; ------ zobrazen¡ spodn¡ho okraje

         mov       si,sp
         mov       dl,0
         mov       dh,ss:[bp-1]             ; © dek na obrazovce
         mov       cl,26                    ; d‚lka okraje
         call      DispStr                  ; zobrazen¡ spodn¡ho okraje

; ------ n vrat registr–

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNot  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ rozvrhu
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) ukazatel © dku na obrazovce
;                   SS:[BP-2] (1) ‡¡ta‡ © dk– k zobrazen¡
;                   SS:[BP-3] (1) aktu ln¡ mˆs¡c
;                   SS:[BP-4] (1) aktu ln¡ den
;                   SS:[BP-5] (1) po‡et dn– v mˆs¡ci
;                   SS:[BP-6] (1) den v t˜dnu
;                   SS:[BP-8] (2) rok
;                   SS:[BP-10] (2) adresa v bufferu
;                   SS:[BP-12] (2) ‡¡ta‡ © dk– v bufferu
;                   SS:[BP-14] (2) ‡¡ta‡ aktivn¡ho © dku
; -----------------------------------------------------------------------------
;þ
DispDiar PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ vytvo©en¡ bufferu v z sobn¡ku

         sub       sp,2*80 + 14

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       ah,1                     ; © dek na obrazovce
         mov       al,byte ptr ds:[DiarRad] ; po‡et © dk– na di ©
         mov       ss:[bp-2],ax             ; © dek na obrazovce a po‡et © dk–
         mov       cx,ds:[DiaTop]           ; po‡ te‡n¡ © dek
         mov       ax,ds:[DiaNum]           ; po‡et © dk– di ©e celkem
         sub       ax,cx                    ; po‡et zbyl˜ch © dk– di ©e
         mov       ss:[bp-12],ax            ; ‡¡ta‡ © dk– v bufferu
         jz        DispDi01                 ; nen¡ ‘ dn˜ © dek
         mov       ax,ds:[DiaAkt]           ; aktivn¡ © dek
         sub       ax,cx                    ; aktivn¡ © dek relativnˆ
         inc       ax                       ; p©ednastaven¡ ‡¡sla © dku
         cmp       byte ptr ds:[WAkt],2     ; je aktivn¡ di © ?
         je        DispDi01                 ; je aktivn¡ di ©
         xor       ax,ax                    ; nen¡ kurzor
DispDi01:mov       ss:[bp-14],ax            ; ‡¡ta‡ aktivn¡ho © dku

; ------ nalezen¡ adresy prvn¡ho © dku

         mov       ah,0
         mov       es,ds:[DatSegm]          ; adresa bufferu
         mov       si,ds:[DenAdr]           ; adresa aktivn¡ho dne
         add       si,5                     ; adresa prvn¡ pozn mky
         jcxz      DispDi08                 ; je zobrazen prvn¡ © dek
DispDi02:inc       si
         inc       si
         mov       al,es:[si]               ; d‚lka textu pozn mky
         inc       si
         add       si,ax                    ; adresa dal¨¡ho © dku
         loop      DispDi02                 ; dal¨¡ © dek
DispDi08:mov       ss:[bp-10],si            ; adresa © dku v bufferu

; ------ stanoven¡ dne, mˆs¡ce a roku

         mov       ax,word ptr ds:[Den]
         mov       dx,word ptr ds:[Den+2]
         call      KonvNDat                 ; konverze na datum
         mov       ss:[bp-8],cx             ; rok
         mov       ss:[bp-6],ax             ; den v t˜dnu a po‡et dn– mˆs¡ce
         mov       ss:[bp-4],bx             ; den a mˆs¡c

; ------ p©¡prava barvy nadpisu

         mov       ah,ds:[Barva1]           ; bˆ‘n  barva nadpisu
         mov       dh,ds:[Barva2]           ; zv˜raznˆn  barva nadpisu
         cmp       byte ptr ds:[WAkt],2     ; je aktivn¡ di © ?
         jne       DispDia1                 ; nen¡ aktivn¡ di ©
         mov       ah,ds:[Barva3]           ; bˆ‘n˜ kurzor
         mov       dh,ds:[Barva4]           ; zv˜raznˆn˜ kurzor

; ------ dek¢dov n¡ textu "Denn¡ rozvrh na"

DispDia1:cld
         mov       si,offset DenNdp         ; nadpis
         mov       di,sp
         push      ss
         pop       es
         mov       cx,offset(DenNdp0-DenNdp) ; d‚lka textu
DispDia2:lodsb
         stosw
         loop      DispDia2

; ------ adresa textu dne v t˜dnu

         mov       si,offset Tyden0         ; tabulka n zv– dn– v t˜dnu
         mov       ch,0
         mov       cl,ss:[bp-6]             ; den v t˜dnu
         jcxz      DispDia4                 ; je to pondˆl¡
DispDia3:add       si,ds:[si]               ; adresa dal¨¡ho textu
         loop      DispDia3                 ; nalezen¡ adresy textu

; ------ dek¢dov n¡ dne v t˜dnu

DispDia4:lodsw                              ; d‚lka textu
         dec       ax
         dec       ax
         xchg      ax,cx                    ; CX <- d‚lka textu
         mov       ah,dh                    ; zv˜raznˆn  barva
DispDia5:lodsb
         stosw
         loop      DispDia5                 ; dal¨¡ znak textu

; ------ oddˆlovac¡ mezera

         mov       al,","
         stosw
         mov       al," "
         stosw

; ------ dek¢dov n¡ dne v mˆs¡ci

         mov       al,ss:[bp-4]             ; aktu ln¡ den v mˆs¡ci
         call      DekNumB                  ; dek¢dov n¡ dne v mˆs¡ci
         mov       al,"."                   ; oddˆlovac¡ te‡ka
         cld
         stosw                              ; ulo‘en¡ oddˆlovac¡ te‡ky

; ------ nalezen¡ adresy textu mˆs¡ce

         mov       si,offset Mesice0        ; tabulka text– mˆs¡c–
         mov       ch,0
         mov       cl,ss:[bp-3]             ; mˆs¡c
         dec       cx
         jz        DispDia7                 ; je leden
DispDia6:add       si,ds:[si]               ; adresa dal¨¡ho textu
         loop      DispDia6                 ; dal¨¡ text

; ------ dek¢dov n¡ textu mˆs¡ce

DispDia7:lodsw                              ; d‚lka textu
         dec       ax
         dec       ax
         xchg      ax,cx                    ; CX <- d‚lka textu
         mov       ah,dh                    ; barva textu
DispDia8:lodsb
         stosw
         loop      DispDia8
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera

; ------ dek¢dov n¡ roku

         push      ax
         mov       ax,ss:[bp-8]             ; aktu ln¡ rok
         xor       bl,bl                    ; nen¡ oddˆlovac¡ te‡ka
         mov       bh,dh                    ; barva textu
         call      DekNumW                  ; dek¢dov n¡ roku
         pop       ax

; ------ z vˆre‡n  mezera

         mov       al," "
         cld
         stosw                              ; oddˆlovac¡ mezera

; ------ ur‡en¡ d‚lky textu

         mov       bx,di                    ; konec textu
         sub       bx,sp                    ; po‡et bajt– v bufferu
         shr       bx,1                     ; po‡et znak– v bufferu

; ------ v˜po‡et okraj–

         mov       cl,53                    ; vnit©n¡ ¨¡©ka okna
         sub       cl,bl                    ; zbytek na okraje
         shr       cl,1                     ; lev˜ okraj
         mov       ch,cl
         adc       ch,0                     ; prav˜ okraj

; ------ zobrazen¡ lev‚ho okraje

         mov       al,196                   ; vodorovn  ‡ ra
         mov       dx,26                    ; po‡ te‡n¡ pozice linky
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         call      DispChr                  ; zobrazen¡ lev‚ho okraje

; ------ zobrazen¡ textu nadpisu

         mov       si,sp                    ; buffer s textem
         mov       cl,bl                    ; d‚lka textu
         call      DispStr                  ; zobrazen¡ textu

; ------ zobrazen¡ prav‚ho okraje

         mov       cl,ch                    ; prav˜ okraj
         call      DispChr                  ; zobrazen¡ prav‚ho okraje

; ------ zobrazen¡ prav‚ho horn¡ho rohu

         mov       al,191                   ; prav˜ horn¡ roh
         call      Disp1Chr                 ; zobrazen¡ lev‚ho horn¡ho rohu

; ------ ur‡en¡ barvy © dku

DispDia9:mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         dec       word ptr ss:[bp-14]      ; ‡¡ta‡ aktivn¡ho © dku
         jnz       DispDi91                 ; nen¡ aktivn¡ © dek
         mov       ah,ds:[Barva3]           ; barva textu s kurzorem

; ------ vymaz n¡ pr zdn‚ho © dku

DispDi91:mov       di,sp                    ; adresa bufferu v z sobn¡ku
         cmp       word ptr ss:[bp-12],0    ; je dal¨¡ © dek v bufferu ?
         jne       DispDi92                 ; je dal¨¡ © dek
         mov       al," "                   ; mazac¡ znak mezery
         mov       cx,MaxLDiar              ; d‚lka © dku
         cld
         rep       stosb                    ; vymaz n¡ © dku
         jmp       short DispDi93

; ------ dek¢dov n¡ textu © dku

DispDi92:push      ds
         mov       ds,ds:[DatSegm]          ; datov˜ segment
         mov       si,ss:[bp-10]            ; adresa © dku v bufferu
         call      DekDiar                  ; dek¢dov n¡ textu © dku di ©e

; ------ adresa dal¨¡ho © dku v bufferu

         inc       si
         inc       si
         mov       ch,0
         mov       cl,ds:[si]               ; d‚lka textu
         inc       si
         add       si,cx                    ; adresa dal¨¡ho © dku
         mov       ss:[bp-10],si            ; adresa dal¨¡ho © dku
         pop       ds
         dec       word ptr ss:[bp-12]      ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch © dk–

; ------ zobrazen¡ © dku di ©e

DispDi93:mov       si,sp                    ; buffer v z sobn¡ku
         mov       dl,26                    ; po‡ te‡n¡ pozice
         mov       cl,MaxLDiar              ; d‚lka textu © dku
         mov       dh,ss:[bp-1]             ; ukazatel © dku na obrazovce
         call      DispTxt                  ; zobrazen¡ © dku

; ------ zobrazen¡ koncov‚ho znaku

         mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         mov       al,179                   ; prav˜ okraj
         call      Disp1Chr                 ; zobrazen¡ koncov‚ho znaku

; ------ p©¡prava pro dal¨¡ © dek

         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dku
         dec       byte ptr ss:[bp-2]       ; ‡¡ta‡ © dk– k zobrazen¡
         jz        DispDi99                 ; jsou ji‘ v¨echny © dky
         jmp       DispDia9                 ; dek¢dov n¡ dal¨¡ho © dku

; ------ zobrazen¡ spodn¡ho okraje

DispDi99:mov       dl,26                    ; pozice k zobrazen¡
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         mov       al,196                   ; vodorovn  ‡ ra
         mov       dh,ss:[bp-1]             ; ukazatel © dku na obrazovce
         mov       cl,53-10-1               ; d‚lka linky (bez ‡asu)
         call      DispChr                  ; zobrazen¡ vodorovn‚ linky
         add       dl,10                    ; p©esko‡en¡ £daje ‡asu
         call      Disp1Chr                 ; dopl¤uj¡c¡ mezera
         mov       al,217                   ; prav˜ doln¡ roh
         call      Disp1Chr                 ; zobrazen¡ prav‚ho doln¡ho rohu

; ------ n vrat registr–

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispDiar ENDP

; *****************************************************************************
;                            DispTime
;                  zobrazen¡ aktu ln¡ho syst‚mov‚ho ‡asu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

DispTime PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ buffer v z sobn¡ku

         mov       bp,sp
         sub       sp,2*10

; ------ dek¢dov n¡ £daje ‡asu

         mov       di,sp
         push      ss
         pop       es
         cld
         mov       ah,ds:[Barva1]           ; bˆ‘n  barva textu
         mov       al," "
         stosw                              ; lev  mezera
         call      DekSTime                 ; dek¢dov n¡ syst‚mov‚ho ‡asu
         cld
         stosw                              ; prav  mezera

; ------ zobrazen¡ syst‚mov‚ho ‡asu

         mov       dl,80-10-2               ; pozice k zobrazen¡
         mov       dh,ds:[MaxRow]           ; posledn¡ © dek displeje
         dec       dh                       ; p©edposledn¡ © dek displeje
         mov       si,sp                    ; buffer v z sobn¡ku
         mov       cl,10                    ; d‚lka textu
         call      DispStr                  ; zobrazen¡ £daje ‡asu

; ------ n vrat registr–

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTime ENDP

; *****************************************************************************
;                               DekSTime
;             dek¢dov n¡ aktu ln¡ho syst‚mov‚ho ‡asu
; -----------------------------------------------------------------------------
; VSTUP: AH=atribut barvy
;        ES:DI=buffer (pro 8 znak–)
; VSTUP:ES:DI=n sleduj¡c¡ adresa
; *****************************************************************************

DekSTime PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         mov       ch,ah                    ; atribut barvy textu
         cld

; ------ zji¨tˆn¡ syst‚mov‚ho ‡asu

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[046ch]            ; ‡ten¡ ni‘¨¡ ‡ sti ‡¡ta‡e ‡asu
         mov       dx,ds:[046eh]            ; ‡ten¡ vy¨¨¡ ‡ sti ‡¡ta‡e ‡asu
         pop       ds

; ------ dek¢dov n¡

         mov       cl,4                     ; po‡et rotac¡
         shl       dx,cl                    ; vy¨¨¡ slovo * 16
         mov       bx,ax                    ; ni‘¨¡ slovo ‡¡ta‡e ‡asu
         mov       cl,12
         shr       bx,cl                    ; nejvy¨¨¡ 4 bity ni‘¨¡ho slova
         add       dx,bx                    ; p©enos 4 bit– do vy¨¨¡ho slova
         mov       cl,4
         shl       ax,cl                    ; ni‘¨¡ slovo * 16
         mov       bx,17478
         div       bx                       ; ‡¡ta‡ ‡asu / 1092.375
         push      dx                       ; £schova zbytku v minutˆ
         mov       bx,60                    ; po‡et minut v hodinˆ
         xor       dx,dx                    ; DX <- 0, AX=po‡et minut
         div       bx                       ; v˜po‡et hodiny a minuty
         push      dx                       ; £schova minuty
         mov       dx,69                    ; po‡ te‡n¡ pozice textu

; ------ ulo‘en¡ £daje hodin

         cld
         aam                                ; korekce na BCD k¢d
         add       ax,"00"                  ; korekce na ASCII k¢d
         xchg      ah,al                    ; AL <- des¡tky hodin
         push      ax
         mov       ah,ch                    ; barva textu
         stosw                              ; des¡tky hodin
         pop       ax
         mov       al,ah                    ; jednotky hodin
         mov       ah,ch                    ; barva textu
         stosw                              ; jednotky hodin
         mov       al,":"                   ; oddˆlovac¡ znak
         stosw                              ; ulo‘en¡ oddˆlovac¡ho znaku

; ------ ulo‘en¡ £daje minut

         pop       ax                       ; n vrat minut
         aam                                ; korekce na BCD k¢d
         add       ax,"00"                  ; korekce na BCD k¢d
         xchg      ah,al                    ; AL <- des¡tky minut
         push      ax
         mov       ah,ch                    ; barva textu
         stosw                              ; des¡tky minut
         pop       ax
         mov       al,ah                    ; jednotky minut
         mov       ah,ch                    ; barva textu
         stosw                              ; jednotky minut
         mov       al,":"                   ; oddˆlovac¡ znak
         stosw                              ; oddˆlovac¡ znak

; ------ dek¢dov n¡ £daje sekund

         pop       ax                       ; n vrat zbytku do 1 minuty
         mov       bx,60                    ; po‡et sekund v minutˆ
         mul       bx                       ; v˜po‡et po‡tu sekund a setin
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; v˜po‡et po‡tu sekund

; ------ zobrazen¡ £daje sekund

         aam                                ; korekce na BCD k¢d
         add       ax,"00"                  ; korekce na ASCII k¢d
         xchg      ah,al
         push      ax
         mov       ah,ch                    ; barva textu
         stosw                              ; des¡tky sekund
         pop       ax
         mov       al,ah
         mov       ah,ch                    ; barva textu
         stosw                              ; jednotky sekund

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekSTime ENDP

; *****************************************************************************
;        Dek¢dov n¡ ‡¡sla (bajt)
; -----------------------------------------------------------------------------
; VSTUP: AL=‡¡slo k dek¢dov n¡
;        AH=atribut barvy
;        ES:DI=ukl dac¡ adresa
; *****************************************************************************

DekNumB  PROC      NEAR

         push      ax
         push      bx
         push      dx

         mov       bh,ah                    ; atribut barvy
         mov       ah,0                     ; AX=‡¡slo k dek¢dov n¡
         xor       dx,dx
         call      DekNum                   ; dek¢dov n¡ ‡¡sla

         pop       dx
         pop       bx
         pop       ax
         ret

DekNumB  ENDP

; *****************************************************************************
;                  Dek¢dov n¡ ‡¡sla (slovo)
; -----------------------------------------------------------------------------
; VSTUP: AX=‡¡slo k dek¢dov n¡
;        ES:DI=ukl dac¡ adresa
;        BL=znak oddˆlova‡e © d– po 3 znac¡ch (0=nen¡ oddˆlova‡)
;        BH=atribut barev
; *****************************************************************************

DekNumW  PROC      NEAR

         push      dx
         xor       dx,dx
         call      DekNum
         pop       dx
         ret

DekNumW  ENDP

; *****************************************************************************
;                        Dek¢dov n¡ ‡¡sla
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo k dek¢dov n¡
;        ES:DI=ukl dac¡ adresa (po‡ tek k ulo‘en¡ ‡¡sla)
;        BL=znak oddˆlova‡e © d– po 3 znac¡ch (0=nen¡ oddˆlova‡)
;        BH=atribut barev
; *****************************************************************************

DekNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©¡prava registr–

         mov       bp,10                    ; ‡¡seln  soustava
         xor       cx,cx                    ; CH=‡¡ta‡ © du, CL=‡¡ta‡ znak–

; ------ v˜po‡et jedn‚ ‡¡slice

DekNum1: mov       si,ax                    ; £schova ni‘¨¡ho slova ‡¡sla
         mov       ax,dx                    ; vy¨¨¡ slovo ‡¡sla
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydˆlen¡ vy¨¨¡ho slova ‡¡sla
         xchg      ax,si                    ; n vrat ni‘¨¡ho slova, £schova HIGH
         div       bp                       ; vydˆlen¡ ni‘¨¡ho slova ‡¡sla

; ------ ulo‘en¡ oddˆlova‡e © d–

         cmp       bl,0                     ; je oddˆlova‡ ?
         je        DekNum3                  ; nen¡ oddˆlova‡ © d–
         cmp       ch,3                     ; jsou tis¡ce ?
         jne       DekNum2                  ; nen¡ © d tis¡c–
         push      bx                       ; ulo‘en¡ oddˆlova‡e tis¡c–
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–
DekNum2: cmp       ch,6                     ; jsou miliony ?
         jne       DekNum3                  ; nen¡ © d milion–
         push      bx                       ; ulo‘en¡ oddˆlova‡e milion–
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–

; ------ ulo‘en¡ nov‚ ‡¡slice

DekNum3: add       dl,"0"                   ; korekce na znak ASCII
         mov       dh,bh                    ; atribut barvy
         push      dx                       ; ulo‘en¡ ‡¡slice
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–
         inc       ch                       ; zv˜¨en¡ ‡¡ta‡e © du

; ------ test, zda je je¨tˆ nˆjak‚ ‡¡slo

         mov       dx,si                    ; n vrat vy¨¨¡ho slova ‡¡sla
         or        si,ax                    ; je ‡¡slo ji‘ = 0 ?
         jnz       DekNum1                  ; ‡¡slo je¨tˆ nen¡ = 0 - pokra‡ov n¡

; ------ ulo‘en¡ ‡¡sla do bufferu

         cld
         mov       ch,0
DekNum6: pop       ax
         stosw                              ; ulo‘en¡ znaku s atributem
         loop      DekNum6

; ------ n vrat registr–

DekNum8: pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP


; *****************************************************************************
;                               DekRNum
;                    dek¢dov n¡ dvoj‡¡sl¡ s mezerou
; -----------------------------------------------------------------------------
; VSTUP: AL=‡¡slo
;        AH=barva textu
;        ES:DI=ukl dac¡ adresa
; *****************************************************************************

DekRNum  PROC      NEAR

         push      cx
         push      ax
         push      di

         push      ax
         mov       cl,10
         xor       ah,ah
         div       cl                       ; v˜po‡et ‡¡slic
         mov       cx,ax                    ; £schova ‡¡sla
         pop       ax
         mov       al,cl                    ; prvn¡ ‡¡slice
         add       al,"0"                   ; korekce na znak ASCII
         cmp       al,"0"                   ; je prvn¡ znak 0 ?
         jne       DekRNum1                 ; nen¡ 0
         mov       al," "                   ; n hrada mezerou
DekRNum1:stosw                              ; ulo‘en¡ prvn¡ ‡¡slice
         mov       al,ch                    ; druh‚ ‡¡slo
         add       al,"0"                   ; korekce na ‡¡slici
         stosw                              ; ulo‘en¡ druh‚ ‡¡slice

         pop       di
         pop       ax
         pop       cx
         ret

DekRNum  ENDP

; *****************************************************************************
;                               DekR0Num
;                    dek¢dov n¡ dvoj‡¡sl¡ s nulou
; -----------------------------------------------------------------------------
; VSTUP: AL=‡¡slo
;        AH=barva textu
;        ES:DI=ukl dac¡ adresa
; *****************************************************************************

DekR0Num PROC      NEAR

         push      cx
         push      ax
         push      di

         push      ax
         mov       cl,10
         xor       ah,ah
         div       cl                       ; v˜po‡et ‡¡slic
         mov       cx,ax                    ; £schova ‡¡sla
         pop       ax
         mov       al,cl                    ; prvn¡ ‡¡slice
         add       al,"0"                   ; korekce na znak ASCII
         stosw                              ; ulo‘en¡ prvn¡ ‡¡slice
         mov       al,ch                    ; druh‚ ‡¡slo
         add       al,"0"                   ; korekce na ‡¡slici
         stosw                              ; ulo‘en¡ druh‚ ‡¡slice

         pop       di
         pop       ax
         pop       cx
         ret

DekR0Num ENDP

; *****************************************************************************
;                            KonvDatN
;                     p©evod data na po‡et dn–
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
;        BH=mˆs¡c
;        BL=den
; VSTUP:DX:AX=den absolutnˆ
; *****************************************************************************

KonvDatN PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      si

; ------ p©¡prava registr– a p©i‡ten¡ dne

         xor       dx,dx                    ; ni‘¨¡ slovo st©ada‡e
         xor       si,si                    ; vy¨¨¡ slovo st©ada‡e
         mov       dl,bl                    ; den
         dec       dl                       ; korekce (0...)

; ------ p©i‡ten¡ mˆs¡c–

KonvDtN1:dec       bh                       ; sn¡‘en¡ ukazatele mˆs¡ce
         jz        KonvDtN2                 ; byly ji‘ v¨echny mˆs¡ce
         call      MesicGet                 ; stanoven¡ po‡tu dn– v mˆs¡ci
         add       dx,ax                    ; p©i‡ten¡ po‡tu dn– v mˆs¡ci
         jmp       short KonvDtN1           ; dal¨¡ mˆs¡c

; ------ p©i‡ten¡ let

KonvDtN2:sub       cx,1                     ; sn¡‘en¡ ukazatele rok–
         jc        KonvDtN3                 ; byly ji‘ v¨echny roky
         cmp       cx,1979
         jne       KonvDtN4

         add       dx,word ptr ds:[Den0]
         adc       si,word ptr ds:[Den0+2]
         jmp       short KonvDtN3

KonvDtN4:call      RokGet                   ; stanoven¡ po‡tu dn– v roce
         add       dx,ax                    ; p©i‡ten¡ po‡tu dn– v roce
         adc       si,0                     ; p©enos do vy¨¨¡ho slova
         jmp       short KonvDtN2           ; dal¨¡ rok

; ------ n vrat registr–

KonvDtN3:mov       ax,dx                    ; den absolutnˆ LOW
         mov       dx,si                    ; den absolutnˆ HIGH
         pop       si
         pop       cx
         pop       bx
         ret

KonvDatN ENDP

; *****************************************************************************
;                              KonvNDat
;                  p©evod absolutn¡ho dne na datum
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=den absolutnˆ
; VSTUP:AL=den v t˜dnu (0...)
;        AH=po‡et dn– v mˆs¡ci
;        BH=mˆs¡c
;        BL=den
;        CX=rok
; *****************************************************************************

KonvNDat PROC      NEAR

; ------ £schova registr–

         push      dx
         push      si
         push      di
         push      bp

; ------ p©¡prava registr–

         mov       bp,dx                    ; den HIGH
         mov       di,ax                    ; den LOW
         mov       si,dx                    ; den HIGH
         mov       dx,ax                    ; den LOW
         xor       cx,cx                    ; CX <- 0

; ------ ode‡ten¡ stolet¡

KonvNDt1:call      StoGet                   ; stanoven¡ po‡tu dn– ve stolet¡
         sub       dx,ax                    ; stolet¡ dosa‘eno ?
         sbb       si,0                     ; p©enos do vy¨¨¡ho slova
         jc        KonvNDt2                 ; stolet¡ dosa‘eno OK
         add       cx,100                   ; zv˜¨en¡ ukazatele roku o 100 let
         jmp       short KonvNDt1           ; p©evod dal¨¡ho stolet¡
KonvNDt2:add       dx,ax                    ; n vrat stolet¡
         adc       si,0                     ; p©enos do vy¨¨¡ho slova

; ------ ode‡ten¡ rok– ve stolet¡

KonvNDt3:call      RokGet                   ; stanoven¡ po‡tu dn– v roce
         sub       dx,ax                    ; roku dosa‘eno ?
         sbb       si,0                     ; p©enos do vy¨¨¡ho slova
         jc        KonvNDt4                 ; rok je nastaven OK
         inc       cx                       ; zv˜¨en¡ ukazatele roku
         jmp       short KonvNDt3           ; p©evod dal¨¡ho roku
KonvNDt4:add       dx,ax                    ; n vrat roku
         adc       si,0                     ; p©enos do vy¨¨¡ho slova

; ------ ode‡ten¡ mˆs¡ce

         xor       bx,bx                    ; p©ednastaven¡ mˆs¡ce a dne
KonvNDt5:inc       bh                       ; zv˜¨en¡ ‡¡sla mˆs¡ce
         call      MesicGet                 ; stanoven¡ po‡tu dn– v mˆs¡ci
         sub       dx,ax                    ; je mˆs¡c nalezen ?
         sbb       si,0                     ; p©enos do vy¨¨¡ho slova
         jnc       KonvNDt5                 ; p©evod dal¨¡ho mˆs¡ce
         add       dx,ax                    ; n vrat mˆs¡ce

; ------ stanoven¡ dne

         inc       dl                       ; den v mˆs¡ci
         mov       bl,dl                    ; den v mˆs¡ci

; ------ v˜po‡et dne v t˜dnu

         push      bx
         push      ax

         mov       dx,bp                    ; den HIGH
         mov       ax,di                    ; den LOW
         add       ax,3                     ; korekce pro spr vn˜ den
         adc       dx,0                     ; p©enod do vy¨¨¡ho slova
         mov       bx,7                     ; po‡et dn– v t˜dnu

         push      ax                       ; den LOW
         mov       ax,dx                    ; den HIGH
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; dˆlen¡ vy¨¨¡ho slova
         pop       ax                       ; den LOW
         div       bx                       ; v˜po‡et dne v t˜dnu
         mov       al,dl                    ; den v t˜dnu

         pop       bx                       ; n vrat po‡tu dn– v mˆs¡ci
         mov       ah,bl                    ; po‡et dn– v mˆs¡ci
         pop       bx

; ------ n vrat registr–

         pop       bp
         pop       di
         pop       si
         pop       dx
         ret

KonvNDat ENDP

; -----------------------------------------------------------------------------
;                     stanoven¡ po‡tu dn– v mˆs¡ci
; -----------------------------------------------------------------------------
; VSTUP: BH=mˆs¡c
;        CX=rok
;        DS=datov˜ segment
; VSTUP:AX=po‡et dn–
; -----------------------------------------------------------------------------

MesicGet PROC      NEAR

         push      bx

; ------ v prosinci 1582 je 28 dn–

         cmp       cx,1582                  ; je rok 1582 ?
         jne       MesicGt1                 ; nen¡ rok 1582
         mov       ax,28                    ; je 28 dn– v prosinci
         cmp       bh,12                    ; je prosinec ?
         je        MesicGt2                 ; je prosinec 1582

; ------ po‡et dn– v mˆs¡ci

MesicGt1:mov       bl,bh                    ; mˆs¡c
         xor       bh,bh                    ; BX=mˆs¡c
         mov       al,ds:[bx+PoctyDnu-1]    ; po‡et dn– v mˆs¡ci
         cbw                                ; po‡et dn– v mˆs¡ci
         cmp       bl,2                     ; je to £nor ?
         jne       MesicGt2                 ; nen¡ £nor
         call      RokTest                  ; test p©estupnosti roku
         jnc       MesicGt2                 ; rok nen¡ p©estupn˜
         inc       ax                       ; po‡et dn– v £noru = 29

MesicGt2:pop       bx
         ret

MesicGet ENDP

; -----------------------------------------------------------------------------
;                     stanoven¡ po‡tu dn– v roce
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
; VSTUP:AX=po‡et dn–
; -----------------------------------------------------------------------------

RokGet   PROC      NEAR

; ------ po‡et dn– v roce 1582

         mov       ax,365-3                 ; po‡et dn– v roce 1582
         cmp       cx,1582                  ; je rok 1582 ?
         je        RokGet1                  ;

; ------ po‡et dn– podle p©estupnosti roku

         mov       ax,365                   ; po‡et dn– v nep©estupn‚m roce
         call      RokTest                  ; test p©estupnosti roku
         jnc       RokGet1                  ; rok nen¡ p©estupn˜
         inc       ax                       ; po‡et dn– v p©estup. roce 366
RokGet1: ret

RokGet   ENDP

; -----------------------------------------------------------------------------
;                    test p©estupnosti roku
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
; VSTUP:CY=je p©estupn˜ rok
; -----------------------------------------------------------------------------

RokTest  PROC      NEAR

; ------ test, zda rok je n sobkem 4

         test      cl,3                     ; je p©estupn˜ rok ?
         jnz       RokTest3                 ; nen¡ p©estupn˜ rok

; ------ p©ed rokem 1600 je p©estupn‚ v‘dy

         cmp       cx,1600                  ; je p©ed rokem 1600 ?
         jb        RokTest3                 ; p©ed 1600 p©estupn‚ v‘dy

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ test, zda je stolet¡ n sobkem 4

         mov       bx,100                   ; stolet¡
         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         div       bx                       ; v˜po‡et stolet¡
         or        dx,dx                    ; je stolet¡ ?
         jnz       RokTest1                 ; nen¡ stolet¡ - je p©estupn˜
         test      ax,3                     ; je stolet¡ dˆliteln‚ 4 ?
         jnz       RokTest2                 ; nen¡ dˆliteln‚ - nen¡ p©estupn‚

; ------ n vrat registr–

RokTest1:stc                                ; p©¡znak p©estupn‚ho roku
RokTest2:pop       dx
         pop       bx
         pop       ax

RokTest3:ret

RokTest  ENDP

; -----------------------------------------------------------------------------
;                      stanoven¡ po‡tu dn– ve stolet¡
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (kon‡¡c¡ 00 - stolet¡)
; VSTUP:AX=po‡et dn– ve stolet¡ (od roku CX po rok CX+99)
; -----------------------------------------------------------------------------

StoGet   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx

; ------ v˜po‡et ‡¡sla stolet¡

         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         mov       bx,100                   ; po‡et let ve stolet¡
         div       bx                       ; v˜po‡et stolet¡

; ------ po‡et let ve stolet¡ 15xx

         cmp       ax,15                    ; je stolet¡ 15 ?
         jne       StoGet1                  ; nen¡ stolet¡ 15
         mov       ax,25*366+75*365-3       ; zkr cen‚ p©estupn‚ stolet¡
         jmp       short StoGet3

; ------ stolet¡ p©ed 1582 je p©estupn‚ v‘dy

StoGet1: cmp       cx,1600                  ; je p©ed rokem 1600 ?
         jb        StoGet2                  ; je p©ed 1600 - p©estupn‚ v‘dy

; ------ po‡et let podle p©estupnosti stolet¡

         test      al,3                     ; je stolet¡ dˆliteln‚ 4 ?
         mov       ax,24*366+76*365         ; nep©estupn‚ stolet¡
         jnz       StoGet3                  ; stolet¡ nen¡ p©estupn‚
StoGet2: mov       ax,25*366+75*365         ; stolet¡ je p©estupn‚

; ------ n vrat registr–

StoGet3: pop       dx
         pop       bx
         ret

StoGet   ENDP

; -----------------------------------------------------------------------------
;        p©evod znaku AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; -----------------------------------------------------------------------------
;                                 InpChr
;                        vstup znaku z kl vesnice
; -----------------------------------------------------------------------------
; VSTUP: BX=k¢d kl vesy
;         CY=p©eru¨en¡ ESC, BREAK
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

         push      ax

; ------ zobrazen¡ ‡asu

InpChr0: mov       ah,1
         int       16h                      ; test stavu kl vesnice
         jnz       InpChr03                 ; je p©ipraven  kl vesa
         call      DispTime                 ; zobrazen¡ ‡asu
         jmp       short InpChr0            ; ‡ek n¡ na stisk kl vesy

; ------ vstup znaku z kl vesnice

InpChr03:mov       ah,0
         int       16h

; ------ obnoven¡ obsahu obrazovky Ctrl-O

         cmp       ax,180fh                 ; je Ctrl-O ?
         jne       InpChr04                 ; nen¡ Ctrl-O
         call      PopScr                   ; obnoven¡ obsahu obrazovky
         mov       ah,0
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         call      DispAll                  ; obnoven¡ obsahu obrazovky
         jmp       short InpChr0            ; nov˜ vstup znaku z kl vesnice

; ------ n hrada kl vesy Ctrl-Break kl vesou Esc

InpChr04:or        ax,ax
         jnz       InpChr1
         mov       ax,11bh                  ; n hrada Ctrl-Break znakem ESC

; ------ pro kl vesu ESC p©¡znak p©eru¨en¡ CY

InpChr1: cmp       al,1bh
         clc
         jne       InpChr2
         stc                                ; p©¡znak p©eru¨en¡ Esc, Break

InpChr2: mov       bx,ax
         pop       ax
         ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol  instrukc¡ CALL JumpBX, za kterou n sleduje tabulka
; skok–. Procedura zmˆn¡ svou n vratovou adresu na adresu podle nalezen‚
; polo‘ky v tabulce (nebo podle polo‘ky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z sobn¡ku slovo (n vratov  adresa NEAR) = za‡ tek tabulky skok–
;             stuktura tabulky: 1 slovo testovan  hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©¡znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen¡ k¢du
; -----------------------------------------------------------------------------

JumpBX   PROC      NEAR

; ------ £schova registr–

                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen¡ hodnoty v tabulce

         push      cs
         pop       ds
         mov       si,ss:[bp+6]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan  hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal¨¡ polo‘ky
         jmp       short JumpBX1            ; test dal¨¡ polo‘ky

; ------ nastaven¡ n vratov‚ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov  n vratov  adresa

; ------ n vrat registr–

         pop       ds
         pop       bp
         pop       si
         ret

JumpBX   ENDP


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Obsluha displeje
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;þ

; -----------------------------------------------------------------------------
;        n vrat obsahu obrazovky
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

         push      cx
         push      si
         push      di
         push      es

         push      ds
         les       di,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       cx,ds:[ObrSize]          ; velikost videopamˆti
         xor       si,si
         mov       ds,ds:[ObrSegm]          ; adresa bufferu
         cld
         rep       movsw                    ; n vrat obsahu obrazovky
         pop       ds

         mov       dx,ds:[OldKurz]          ; p–vodn¡ pozice kurzoru
         call      SetKurz                  ; n vrat pozice kurzoru

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

PopScr   ENDP

; *****************************************************************************
;                            KurzOff
;                        vypnut¡ kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

KurzOff  PROC      NEAR

         push      dx
         mov       dl,0
         mov       dh,ds:[Radku]            ; prvn¡ © dek "za rohem"
         call      SetKurz                  ; nastaven¡ pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; *****************************************************************************
;                            SetKurz
;                     nastaven¡ pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice kurzoru
;        DH=© dek kurzoru
;        DS=datov˜ segment
; *****************************************************************************

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,ds:[AktPage]          ; aktivn¡ videostr nka
         mov       ah,2                     ; funkce - nastaven¡ pozice kurzoru
         call      Int10P                   ; nastaven¡ pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; *****************************************************************************
;                            GetKurz
;                     poskytnut¡ pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP:DL=pozice kurzoru
;        DH=© dek kurzoru
;        DS=datov˜ segment
; *****************************************************************************

GetKurz  PROC      NEAR

         push      ax
         push      bx
         push      cx
         mov       bh,ds:[AktPage]          ; aktivn¡ videostr nka
         mov       ah,3                     ; funkce - poskytnut¡ pozice kurzoru
         call      Int10P                   ; poskytnut¡ pozice kurzoru
         pop       cx
         pop       bx
         pop       ax
         ret

GetKurz  ENDP

; *****************************************************************************
;                              Disp1Chr
;                    Z pis 1 znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z pisu (AL=znak, AH=atribut)
;         DL=pozice
;         DH=© dek
;         DS=datov˜ segment
; VSTUP: DL=nov  pozice
; *****************************************************************************

Disp1Chr PROC      NEAR

         push      cx
         mov       cl,1                     ; 1 znak k z pisu
         call      DispChr                  ; z pis 1 znaku na displej
         pop       cx
         ret

Disp1Chr ENDP

; *****************************************************************************
;                              DispChr
;                 Opakovan˜ z pis znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z pisu (AL=znak, AH=atribut)
;         CL=po‡et znak– k z pisu
;         DL=po‡ te‡n¡ pozice
;         DH=po‡ te‡n¡ © dek
;         DS=datov˜ segment
; VSTUP: DL=nov  pozice
; *****************************************************************************

DispChr  PROC      NEAR

; ------ kontrola maxim ln¡ pozice

         cmp       dl,79                    ; kontrola maxim ln¡ pozice
         ja        DispChr8                 ; pozice p©ekro‡ena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim ln¡ho © dku
         ja        DispChr8                 ; © dek p©ekro‡en

; ------ £schova registr–

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         mov       bx,ax                    ; £schova znaku k z pisu
         xor       ch,ch                    ; CX = po‡et znak–

; ------ omezen¡ po‡tu znak– (do konce © dku)

         mov       al,80                    ; po‡et pozic na © dku
         sub       al,dl                    ; zbyl˜ po‡et mo‘n˜ch pozic
         cmp       al,cl                    ; p©ekro‡en po‡et znak– ?
         jae       DispChr1                 ; nen¡ p©ekro‡en po‡et znak–
         mov       cl,al                    ; omezen¡ po‡tu znak–

; ------ v˜po‡et adresy ve videopamˆti

DispChr1:les       di,ds:[AdrVRAM]          ; adresa za‡ tku VRAM
         mov       al,80                    ; po‡et znak– na © dek
         mul       dh                       ; p©epo‡et © dk– na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©i‡ten¡ pozice
         shl       ax,1                     ; * 2 = offset ve videostr nce
         add       di,ax                    ; adresa ve videopamˆti

; ------ p©¡prava dat; zji¨tˆn¡, zda se kontroluje snˆ‘en¡

         sti                                ; p©eru¨en¡ povoleno
         cld                                ; smˆr posunu ukazatele nahoru
         cmp       byte ptr ds:[ChckSnow],0 ; prov d¡ se kontrola snˆ‘en¡ ?
         je        DispChr6                 ; neprov d¡ se kontrola snˆ‘en¡
         jcxz      DispChr7                 ; nen¡ ‘ dn˜ znak k p©enosu

; ------ p©enos dat s obsluhou snˆ‘en¡

         mov       dx,ds:[PortCRT]          ; stavov˜ registr ©adi‡e displeje
DispChr2:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         test      al,8                     ; prob¡h  vertik ln¡ impuls ?
         jnz       DispChr5                 ; prob¡h  vertik ln¡ impuls
DispChr3:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horizont ln¡ho zpˆtn‚ho bˆhu
         jc        DispChr3                 ; je horiz. zpˆtn˜ bˆh - ‡ek n¡
DispChr4:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horiz. zpˆtn‚ho bˆhu
         jnc       DispChr4                 ; ‡ek n¡ na horiz. zpˆtn˜ bˆh
DispChr5:mov       ax,bx                    ; znak k zobrazen¡
         stosw                              ; z pis jednoho znaku
         loop      DispChr2                 ; z pis dal¨¡ho znaku

; ------ z pis znaku bez kontroly snˆ‘en¡

DispChr6:mov       ax,bx                    ; znak k zobrazen¡
         rep       stosw                    ; z pis znaku bez kontroly snˆ‘en¡

; ------ n vrat registr–, konec

DispChr7:pop       es                       ; n vrat ES
         pop       di                       ; n vrat DI
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
         pop       bx                       ; n vrat BX
         pop       ax                       ; n vrat AX

DispChr8:add       dl,cl                    ; zv˜¨en¡ pozice
         ret

DispChr  ENDP

; *****************************************************************************
;                              DispTxt
;                  Zobrazen¡ textov‚ho ©etˆzce na obrazovce
; -----------------------------------------------------------------------------
; VSTUP:  AH=atribut barvy
;         CL=po‡et znak– textu
;         DL=po‡ te‡n¡ pozice
;         DH=po‡ te‡n¡ © dek
;         DS=datov˜ segment
;         ES:SI=adresa textov‚ho ©etˆzce (bez atribut–)
; VSTUP: DL=nov  pozice
; *****************************************************************************

DispTxt  PROC      NEAR

; ------ kontrola maxim ln¡ pozice

         cmp       dl,79                    ; kontrola maxim ln¡ pozice
         ja        DispTxt8                 ; pozice p©ekro‡ena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim ln¡ho © dku
         ja        DispTxt8                 ; © dek p©ekro‡en

; ------ £schova registr–

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = po‡et znak–

; ------ omezen¡ po‡tu znak– (do konce © dku)

         mov       al,80                    ; po‡et pozic na © dku
         sub       al,dl                    ; zbyl˜ po‡et mo‘n˜ch pozic
         cmp       al,cl                    ; p©ekro‡en po‡et znak– ?
         jae       DispTxt1                 ; nen¡ p©ekro‡en po‡et znak–
         mov       cl,al                    ; omezen¡ po‡tu znak–

; ------ v˜po‡et adresy ve videopamˆti

DispTxt1:push      es                       ; £schova segmentu zdrojov‚ho textu
         les       di,ds:[AdrVRAM]          ; adresa za‡ tku VRAM
         push      ax
         mov       al,80                    ; po‡et znak– na © dek
         mul       dh                       ; p©epo‡et © dk– na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©i‡ten¡ pozice
         shl       ax,1                     ; * 2 = offset ve videostr nce
         add       di,ax                    ; adresa ve videopamˆti
         pop       ax

; ------ p©¡prava dat; zji¨tˆn¡, zda se kontroluje snˆ‘en¡

         sti                                ; p©eru¨en¡ povoleno
         cld                                ; smˆr posunu ukazatele nahoru
         mov       dx,ds:[PortCRT]          ; stavov˜ registr ©adi‡e displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov d¡ se kontrola snˆ‘en¡ ?
         pop       ds                       ; segment zdrojov‚ adresy
         jcxz      DispTxt7                 ; nen¡ ‘ dn˜ znak k p©enosu
         je        DispTxt6                 ; neprov d¡ se kontrola snˆ‘en¡

; ------ p©enos dat s obsluhou snˆ‘en¡

DispTxt2:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         test      al,8                     ; prob¡h  vertik ln¡ impuls ?
         jnz       DispTxt5                 ; prob¡h  vertik ln¡ impuls
DispTxt3:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horizont ln¡ho zpˆtn‚ho bˆhu
         jc        DispTxt3                 ; je horiz. zpˆtn˜ bˆh - ‡ek n¡
DispTxt4:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horiz. zpˆtn‚ho bˆhu
         jnc       DispTxt4                 ; ‡ek n¡ na horiz. zpˆtn˜ bˆh
DispTxt5:lodsb                              ; na‡ten¡ znaku k zobrazen¡
         stosw                              ; p©enos jednoho znaku
         loop      DispTxt2                 ; p©enos dal¨¡ho znaku
         jmp       short DispTxt7

; ------ p©enos dat bez kontroly snˆ‘en¡

DispTxt6:lodsb                              ; znak k zobrazen¡
         stosw                              ; ulo‘en¡ znaku
         loop      DispTxt6                 ; p©enos dat bez kontroly snˆ‘en¡

; ------ n vrat registr–, konec

DispTxt7:pop       es                       ; n vrat ES
         pop       ds                       ; n vrat DS
         pop       di                       ; n vrat DI
         pop       si                       ; n vrat SI
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
         pop       ax                       ; n vrat AX

DispTxt8:add       dl,cl                    ; zv˜¨en¡ pozice
         ret

DispTxt  ENDP

; *****************************************************************************
;                              DispStr
;                 Zobrazen¡ textov‚ho ©etˆzce na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  CL=po‡et znak– textu
;         DL=po‡ te‡n¡ pozice
;         DH=po‡ te‡n¡ © dek
;         DS=datov˜ segment
;         ES:SI=adresa textov‚ho ©etˆzce (1 znak = 2 bajty = znak a atribut)
; VSTUP: DL=nov  pozice
; *****************************************************************************

DispStr  PROC      NEAR

; ------ kontrola maxim ln¡ pozice

         cmp       dl,79                    ; kontrola maxim ln¡ pozice
         ja        DispStr8                 ; pozice p©ekro‡ena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim ln¡ho © dku
         ja        DispStr8                 ; © dek p©ekro‡en

; ------ £schova registr–

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = po‡et znak–

; ------ omezen¡ po‡tu znak– do konce © dku

         mov       al,80                    ; po‡et pozic na © dku
         sub       al,dl                    ; zbyl˜ po‡et mo‘n˜ch pozic
         cmp       al,cl                    ; p©ekro‡en po‡et znak– ?
         jae       DispStr1                 ; nen¡ p©ekro‡en po‡et znak–
         mov       cl,al                    ; omezen¡ po‡tu znak–

; ------ v˜po‡et adresy ve videopamˆti

DispStr1:push      es                       ; £schova segmentu zdrojov‚ho textu
         les       di,ds:[AdrVRAM]          ; adresa za‡ tku VRAM
         mov       al,80                    ; po‡et znak– na © dek
         mul       dh                       ; p©epo‡et © dk– na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©i‡ten¡ pozice
         shl       ax,1                     ; * 2 = offset ve videostr nce
         add       di,ax                    ; adresa ve videopamˆti

; ------ p©¡prava dat; zji¨tˆn¡, zda se kontroluje snˆ‘en¡

         cld                                ; smˆr posunu ukazatele nahoru
         sti                                ; povolen¡ p©eru¨en¡
         mov       dx,ds:[PortCRT]          ; stavov˜ registr ©adi‡e displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov d¡ se kontrola snˆ‘en¡ ?
         pop       ds                       ; segment zdrojov‚ adresy
         je        DispStr6                 ; neprov d¡ se kontrola snˆ‘en¡
         jcxz      DispStr7                 ; nen¡ ‘ dn˜ znak k p©enosu

; ------ p©enos dat s obsluhou snˆ‘en¡

DispStr2:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         test      al,8                     ; prob¡h  vertik ln¡ impuls ?
         jnz       DispStr5                 ; prob¡h  vertik ln¡ impuls
DispStr3:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horizont ln¡ho zpˆtn‚ho bˆhu
         jc        DispStr3                 ; je horiz. zpˆtn˜ bˆh - ‡ek n¡
DispStr4:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horiz. zpˆtn‚ho bˆhu
         jnc       DispStr4                 ; ‡ek n¡ na horiz. zpˆtn˜ bˆh
DispStr5:movsw                              ; p©enos jednoho znaku
         loop      DispStr2                 ; p©enos dal¨¡ho znaku

; ------ p©enos dat bez kontroly snˆ‘en¡

DispStr6:rep       movsw                    ; p©enos dat bez kontroly snˆ‘en¡

; ------ n vrat registr–, konec

DispStr7:pop       es                       ; n vrat ES
         pop       ds                       ; n vrat DS
         pop       di                       ; n vrat DI
         pop       si                       ; n vrat SI
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
         pop       ax                       ; n vrat AX

DispStr8:add       dl,cl                    ; zv˜¨en¡ pozice
         ret

DispStr  ENDP

; *****************************************************************************
;                             InitVmod
;                      Inicializace videom¢du
;             (po‘aduje, aby byla rozpozn na karta EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datov˜ segment
; VSTUP: CY=videom¢d byl zmˆnˆn
;         neni‡¡ ‘ dn˜ registr
; *****************************************************************************

InitVMod PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ kontrola, zda je povolen˜ videom¢d

         call      AktPDisp                 ; aktualizace parametr– displeje
         cmp       al,7                     ; MDA ?
         je        InitVM5                  ; povolen˜ videom¢d
         cmp       al,2
         je        InitVM5                  ; CGA
         cmp       al,3
         je        InitVM5                  ; CGA

; ------ stanoven¡ implicitn¡ho videom¢du

         int       11h                      ; poskytnut¡ tabulky vybaven¡
         and       al,30h                   ; inicializa‡n¡ videom¢d
         cmp       al,30h                   ; videom¢d 80x25 monochrom. ?
         mov       al,7                     ; videom¢d MDA
         je        InitVM1                  ; je videom¢d MDA
         mov       al,3                     ; jinak videom¢d CGA
InitVM1: call      SetVMode                 ; nastaven¡ po‘adovan‚ho videom¢du
         stc                                ; p©¡znak zmˆny videom¢du

; ------ n vrat registr–

InitVM5: pop       ax
         ret

InitVMod ENDP

; *****************************************************************************
;                               SetVMode
;                          Nastaven¡ videom¢du
;                (doporu‡uje se rozpozn n¡ videokarty EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  AL=po‘adovan˜ videom¢d
;         DS=datov˜ segment
; VSTUP: AL=nov˜ aktu ln¡ videom¢d
;         CY=videom¢d nenastaven
;         neni‡¡ ‘ dn˜ registr
; *****************************************************************************

SetVMode PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ax                       ; £schova po‘adovan‚ho videom¢du

; ------ nastaven¡ videom¢du

         xor       ah,ah                    ; funkce nastaven¡ videom¢du
         call      Int10P                   ; nastaven¡ videom¢du
         call      AktPDisp                 ; poskytnut¡ aktivn¡ho videom¢du
         mov       bl,al                    ; £schova aktu ln¡ho videom¢du

; ------ n vrat registr–, zhodnocen¡ v˜sledku

         pop       ax                       ; n vrat po‘adovan‚ho videom¢du
         xchg      al,bl                    ; AL <- nov˜ videom¢d
         cmp       al,bl                    ; souhlas¡ videom¢d s po‘adovan˜m ?
         je        SetVMod1                 ; videom¢d nastaven OK
         stc                                ; p©¡znak chyby nastaven¡ videom¢du
SetVMod1:pop       bx
         ret

SetVMode ENDP

; *****************************************************************************
;                               AktPDisp
;            Atualizace parametr– displeje podle videom¢du
;
; Tato procedura pou‘¡v  k aktualizaci parametr– pouze operace v pamˆti,
; nepou‘¡v  ‘ dn‚ p©eru¨en¡. Vy‘aduje rozpozn n¡ karty EGA/VGA.
; -----------------------------------------------------------------------------
; VSTUP:  DS=datov˜ segment
; VSTUP: AL=aktu ln¡ videom¢d
;         neni‡¡ ‘ dn˜ registr
; *****************************************************************************

AktPDisp PROC    NEAR

; ------ £schova registr–

         push      es
         push      bx

; ------ zji¨tˆn¡ videom¢du

         mov       bx,40h
         mov       es,bx                    ; ES <- 40h segment dat BIOS
         mov       al,es:[49h]              ; aktu ln¡ videom¢d
         and       al,7fh                   ; zru¨en¡ p©¡znaku nemaz n¡ displeje

; ------ zji¨tˆn¡ videostr nky

         mov       bl,es:[62h]              ; aktivn¡ videostr nka
         mov       ds:[AktPage],bl          ; £schova aktivn¡ videostr nky

; ------ zji¨tˆn¡ adresy videopamˆti a p©ednastaven¡ p©¡znaku obsluhy snˆ‘en¡

         mov       byte ptr ds:[ChckSnow],0 ; zru¨en¡ p©¡znaku obsluhy snˆ‘en¡
         mov       word ptr ds:[AdrVRAM+2],0B000h ; segment videopamˆti pro MDA
         cmp       al,7                     ; je videom¢d MDA ?
         je        AktParD1                 ; je videom¢d MDA
         mov       word ptr ds:[AdrVRAM+2],0B800h ; segment videopamˆti pro CGA
         inc       byte ptr ds:[ChckSnow]   ; nastav. p©¡znaku obsluhy snˆ‘en¡
AktParD1:mov       bx,es:[4eh]              ; po‡ te‡n¡ adresa videopamˆti
         mov       word ptr ds:[AdrVRAM],bx ; po‡ te‡n¡ adresa videopamˆti

; ------ zji¨tˆn¡ po‡tu © dk– a up©esnˆn¡ p©¡znaku snˆ‘en¡

         mov       bl,24                    ; p©ednastaven¡ na 25 © dk–
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA, VGA ?
         je        AktParD6                 ; nen¡ karta EGA/VGA
         cmp       byte ptr es:[84h],5      ; je £daj po‡tu © dk– platn˜ ?
         jb        AktParD5                 ; £daj po‡tu © dk– nen¡ platn˜
         mov       bl,es:[84h]              ; po‡et © dk– displeje - 1
AktParD5:mov       bh,es:[87h]              ; p©¡znak kontroly snˆ‘en¡
         shr       bh,1
         shr       bh,1
         and       bh,1                     ; p©¡znak obsluhy snˆ‘en¡
         mov       ds:[ChckSnow],bh         ; nastaven¡ p©¡znaku kontroly snˆ‘.
AktParD6:mov       ds:[MaxRow],bl           ; maxim ln¡ © dek na displeji
         inc       bl                       ; po‡et © dk– celkem
         mov       ds:[Radku],bl            ; po‡et © dk– celkem

; ------ zji¨tˆn¡ b zov‚ ©¡dic¡ adresy displeje CRT

         mov       bx,es:[63h]              ; b zov  adresa portu ©adi‡e CRT
         add       bx,6
         mov       ds:[PortCRT],bx          ; stavov˜ registr ©adi‡e displeje

; ------ n vrat registr–

         pop       bx
         pop       es
         ret

AktPDisp ENDP

; *****************************************************************************
;                              DetCard
;                      detekce videokarty EGA/VGA
; -----------------------------------------------------------------------------
; VSTUP:  DS=datov˜ segment
;         neni‡¡ ‘ dn˜ registr
; *****************************************************************************

DetCard  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ test videokarty EGA/VGA

         mov       ah,12h                   ; slu‘ba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut¡ informac¡ o EGA
         call      Int10P                   ; poskytnut¡ informac¡ o EGA/VGA
         mov       byte ptr ds:[EgaVga],0   ; zru¨en¡ p©¡znaku karty EGA/VGA
         cmp       bh,1                     ; kontrola navr cen‚ho m¢du displeje
         ja        DetectC1                 ; nen¡ to karta EGA/VGA
         cmp       bl,5                     ; maxim lnˆ povolen 1 MB pamˆti
         ja        DetectC1                 ; nen¡ to karta EGA/VGA
         mov       byte ptr ds:[EgaVga],1   ; p©¡znak karty EGA/VGA

; ------ n vrat registr–

DetectC1:pop       cx
         pop       bx
         pop       ax
         ret

DetCard  ENDP

; *****************************************************************************
;                              Int10P
;                Vol n¡ INT 10h s £schovou registr–
; -----------------------------------------------------------------------------
;
; *****************************************************************************

Int10P   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10P   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                 data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


RezSegm  dw        0                        ; segment rezidentn¡ho modulu

Param    db        0                        ; parametry
                                            ;  bit 0: 1=odinstalov n¡ programu
                                            ;  bit 1: 1=nen¡ interaktivn¡ m¢d
                                            ;  bit 2: 1=kalend © byl modifikov n
                                            ;  bit 3: 1=historie modifikov na
                                            ;  bit 4:
                                            ;  bit 5: 1=aktivn¡ den vytvo©en
                                            ;  bit 6: 1=je prvn¡ instalace
                                            ;  bit 7: 1=je ru¨en¡ dn–

Param2   db        0                        ; parametry 2
                                            ;  bit 0: 1=po‘aduje se p©eklad
                                            ;  bit 1: 1=m  b˜t zpˆtn˜ p©eklad

Soub     db        'KALEND.DAT',0           ; jm‚no
Soubor   db        128+11 dup(0)            ; buffer jm‚na souboru
SoubAsc  db        'KALEND.ASC',0           ; jm‚no textov‚ho dat. souboru

; -----------------------------------------------------------------------------
;        editace © dku
; -----------------------------------------------------------------------------

EditBuf  db        80 dup(" ")              ; edita‡n¡ buffer
         db        "    "                   ; zdroj koncov‚ mezery + rezerva
EditKur  db        0                        ; pozice kurzoru na edit. © dku

; -----------------------------------------------------------------------------
;        Parametry displeje a videom¢du
; -----------------------------------------------------------------------------

         EVEN
AdrVRAM  dd        0b8000000h               ; adresa videostr nky displeje
PortCRT  dw        3dah                     ; b zov  adresa portu ©adi‡e CRT
Radku    db        25                       ; po‡et © dk– celkem
MaxRow   db        24                       ; maxim ln¡ © dek na displeji
EgaVga   db        0                        ; p©¡znak, ‘e je karta EGA/VGA
ChckSnow db        0                        ; p©¡znak, ‘e se kontroluje snˆ‘en¡
AktPage  db        0                        ; aktivn¡ videostr nka

DiarRad  dw        0                        ; po‡et © dk– na di ©
NotRad   dw        0                        ; po‡et © dk– na pozn mky

WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
ReadTxt  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'
;SyntTxt  db        '-------------- Chyba syntaxe datoveho souboru ! --------------',13,10
;         db        'Radek zacinajici mezerou predstavuje radek pro pole "PAMATUJ".',13,10
;         db        'Ostatni radky jsou povazovany za radky pro pole "DENNI ROZVRH"',13,10
;         db        'se syntaxi zapisu:  RRRR.MM.DD HH:MM text',13,10
;         db        '(RRRR - rok, MM - mesic, DD - den, HH - hodina, MM - minuta)',13,10
;         db        'Uvedenim znaku "*" namisto mezery mezi udajem casu a textem',13,10
;         db        'se radek povazuje za pokracovani textu predesleho radku.',13,10
;         db        '$'

UvTxt    db        'KALEND V1.11 - kalendar; (c) Miroslav Nemecek',13,10,'$'
DInsTxt  db        'Program byl odinstalovan z pameti.',13,10,'$'
DInsTxt2 db        'Program nelze odinstalovat !',13,10
         db        'Odinstalujte nejdrive programy nainstalovane po nem !',13,10,'$'
HlpTxt   db        'Zadejte: /! - odinstalovani programu z pameti',13,10
         db        '         /I - nespousti se interaktivni mod',13,10
         db        '         /A - preklad KALEND.ASC do KALEND.DAT',13,10
         db        '         /D - zpetny preklad KALEND.DAT do KALEND.ASC',13,10
         db        '$'
MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'

HelpTxt1 db        ' ESC=konec ³ ENTER,TAB=denni rozvrh ³ SHIFT-TAB=pamatuj ³ DELETE=zrus stare dny '
HelpTxt2 db        ' ESC,TAB=kalendar ³ SHIFT-TAB=denni rozvrh ³ INS=novy radek ³ CTRL-Y=zrus radek '
HelpTxt3 db        ' ESC=kalendar ³ Zadejte hodinu zacatku akce 0 az 23                             '
HelpTxt4 db        ' ESC=kalendar ³ Zadejte minutu zacatku akce 0 az 59                             '
HelpTxt5 db        ' ESC=kalendar ³ Zadejte 0 az 30 minut signalizace pred zacatkem; MEZERA=vypnuti '

HelpTxt7 db        ' ESC=kalendar ³ TAB=pamatuj ³ INS, ENTER=novy radek ³ CTRL-Y=zrus radek         '
HelpTxt8 db        ' VAROVANI: Zrusim vsechny rozvrhy starsi nez nastavene datum !  Potvrdte "A"... '

; Struktura dat:
;      (4) identifik tor "DIAR"
;      (2) p©¡znaky (rezervov no, zat¡m nastaveno na 0)
;      (2) offset za‡ tku definice dn–
;          jeden © dek pozn mky: (1) d‚lka textu © dku pozn mku
;                                (x) text © dku pozn mky
;      (2) offset definice dal¨¡ho dne (0=konec dat)
;      (3) absolutn¡ ‡¡slo dne
;          jedna pozn mka dne:  (2)      1. bajt = 0ffh - pokra‡ov n¡ pozn mky
;                                   bit 0 a‘ bit 5: minuta za‡ tku akce
;                                   bit 6 a‘ bit 10: hodina za‡ tku akce
;                                   bit 11 a‘ bit 15: indikace (0 - 30 minut)
;                                                      31=nen¡ indikace
;                               (1) d‚lka textu pozn mky
;                               (x) text pozn mky (max. 255 znak–)

ObrSegm  dw        0                        ; segment s uschovanou obrazovkou
ObrSize  dw        0                        ; velikost bufferu obrazovky (slov)
OldKurz  dw        0                        ; uschovan  pozice kurzoru

DatSegm  dw        0                        ; datov˜ segment ud lost¡
DatSize  dw        0ffefh                   ; velikost datov‚ho segmentu
DatNum   dw        0                        ; po‡et bajt– v datov‚m segmentu

NotEnd   dw        0                        ; adresa konce pozn mek
NotNum   dw        0                        ; po‡et © dk– pozn mek
NotTop   dw        0                        ; ‡¡slo prvn¡ho © dku pozn mek
NotAkt   dw        0                        ; aktivn¡ © dek s pozn mkou
NotKur   db        0                        ; uschovan˜ kurzor pozn mek

DiaNum   dw        0                        ; po‡et © dk– aktivn¡ho dne di ©e
DiaTop   dw        0                        ; ‡¡slo prvn¡ho © dku di ©e
DiaAkt   dw        0                        ; ‡¡slo aktivn¡ho © dku di ©e

Barva1   db        70h                      ; z kladn¡ barva okna
Barva2   db        74h                      ; vysv¡cen  barva okna
Barva3   db        30h                      ; barva kurzoru
Barva4   db        34h                      ; vysv¡cen˜ kurzor
Barva5   db        30h                      ; barva textu n povˆdy

Barva32  db        7                        ; barva kurzoru kalend ©e
Barva42  db        8+4                      ; vysv¡cen  barva kurzoru kalend ©e

WAkt     db        1                        ; aktivn¡ podokno
                                            ;   1=kalend ©
                                            ;   2=di ©
                                            ;   3=z pisn¡k

ADen     db        0                        ; aktu ln¡ den
AMesic   db        0                        ; aktu ln¡ mˆs¡c
ARok     dw        0                        ; aktu ln¡ rok
ADenAdr  dw        0                        ; adresa aktu ln¡ho dne
ADenAdr2 dw        0                        ; adresa dal¨¡ho dne

DenAdr   dw        0                        ; adresa aktivn¡ho dne v bufferu

Den      dd        0                        ; aktu ln¡ den
Den0     dd        723189                   ; den 1.1.1980

; ------ po‡ty dn– v mˆs¡c¡ch roku

PoctyDnu db        31                       ; leden
         db        28                       ; £nor
         db        31                       ; b©ezen
         db        30                       ; duben
         db        31                       ; kvˆten
         db        30                       ; ‡erven
         db        31                       ; ‡ervenec
         db        31                       ; spren
         db        30                       ; z ©¡
         db        31                       ; ©¡jen
         db        30                       ; listopad
         db        31                       ; prosinec

DnyNadp  db        179,'  Po Ut St Ct Pa So ',0,'Ne',0,'  ',179
DnyNadp0 label     byte

KalNdp   db        ' Kalendar '
KalNdp0  label     byte

KalDen   db        179,'  Den:                  ',179
KalDen0  label     byte

DenNdp   db        ' Denni rozvrh na '
DenNdp0  label     byte

PamNdp   db        ' Pamatuj '

; ------ mˆs¡ce

Mesice   dw        5+2
         db        'leden'
         dw        4+2
         db        'unor'
         dw        6+2
         db        'brezen'
         dw        5+2
         db        'duben'
         dw        6+2
         db        'kveten'
         dw        6+2
         db        'cerven'
         dw        8+2
         db        'cervenec'
         dw        5+2
         db        'srpen'
         dw        4+2
         db        'zari'
         dw        5+2
         db        'rijen'
         dw        8+2
         db        'listopad'
         dw        8+2
         db        'prosinec'

Mesice0  dw        5+2
         db        'ledna'
         dw        5+2
         db        'unora'
         dw        6+2
         db        'brezna'
         dw        5+2
         db        'dubna'
         dw        6+2
         db        'kvetna'
         dw        6+2
         db        'cervna'
         dw        8+2
         db        'cervence'
         dw        5+2
         db        'srpna'
         dw        4+2
         db        'zari'
         dw        5+2
         db        'rijna'
         dw        9+2
         db        'listopadu'
         dw        8+2
         db        'prosince'

Tyden0   dw        7+2
         db        'pondeli'
         dw        5+2
         db        'utery'
         dw        6+2
         db        'stredu'
         dw        7+2
         db        'ctvrtek'
         dw        5+2
         db        'patek'
         dw        6+2
         db        'sobotu'
         dw        6+2
         db        'nedeli'

; ------ diskov˜ bufferu

DiskIdnt dw        0                        ; identifik tor souboru
DiskBRd  dw        0                        ; ‡tec¡ adresa z diskov‚ho bufferu
DiskBNum dw        0                        ; po‡et bajt– v disk. bufferu
DiskBuf  db        DiskBSiz dup(?)          ; diskov˜ buffer

         dw        400h dup(?)              ; z sobn¡k
Zasob    label     word

Code     ENDS
         END       Start

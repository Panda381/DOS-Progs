
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

DELKTAB  EQU       offset(InitTRT0-InitTRT) ; d‚lka jedn‚ tabulky registr–

; ------ kl¡‡e pro identifikaci rezidentn¡ho programu

KLIC1    EQU       0434h                    ; kl¡‡ 1 (AX)
KLIC2    EQU       5A36h                    ; kl¡‡ 2 (BX)
KLIC3    EQU       0A63Eh                   ; kl¡‡ 3 (CX)
KLIC4    EQU       2E31h                    ; kl¡‡ 4 (DX)
KLIC5    EQU       6F05h                    ; kl¡‡ 5 (BX v˜stup)

; ------ v¨eobecn‚ konstanty

b0       EQU       1
b1       EQU       2
b2       EQU       4
b3       EQU       8
b4       EQU       10h
b5       EQU       20h
b6       EQU       40h
b7       EQU       80h
b8       EQU       100h
b9       EQU       200h
b10      EQU       400h
b11      EQU       800h
b12      EQU       1000h
b13      EQU       2000h
b14      EQU       4000h
b15      EQU       8000h

HI       EQU       256

KORIG    EQU       5ch-103h                 ; korekce adres programu

; -----------------------------------------------------------------------------
;        za‡ tek programu
; -----------------------------------------------------------------------------

Start:   jmp       Instal                   ; instalace programu

RezidBeg label     byte                     ; za‡ tek rezidentn¡ho programu

Old10    dd        0                        ; p–vodn¡ adresa INT 10h

Param    db        0                        ; parametry
                                            ;  bit 0: 1=aktivn¡ TV m¢d
; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      FAR

; ------ test instalace programu

         cmp       ax,KLIC1
         jne       Int101
         cmp       bx,KLIC2
         jne       Int101
         cmp       cx,KLIC3
         jne       Int101
         cmp       dx,KLIC4
         jne       Int101
         push      cs
         pop       es                       ; ES <- rezidentn¡ segment
         mov       bx,KLIC5
         iret

; ------ test, zda je zapnut televizn¡ m¢d

Int100:  jmp       dword ptr cs:[Old10+KORIG]
Int101:  test      byte ptr cs:[Param+KORIG],b0 ; je zapnut TV m¢d ?
         jz        Int100                   ; nen¡ zapnut TV m¢d

; ------ test, zda se mˆn¡ videom¢d

         cmp       ah,0
         jne       Int100

; ------ inicializace videom¢du

         call      Exec10                   ; inicializace videom¢du

; ------ inicializace videoregistr– pro TV videom¢d

         call      InitVReg                 ; inicializace registr– TV videom¢du
Int109:  iret

Int10    ENDP

; -----------------------------------------------------------------------------
;        vol n¡ funkce INT 10h
; -----------------------------------------------------------------------------

Exec10   PROC      NEAR

         pushf
         call      dword ptr cs:[Old10+KORIG]
         ret

Exec10   ENDP

; -----------------------------------------------------------------------------
;        inicializace videoregistr–
; -----------------------------------------------------------------------------

InitVReg PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ p©¡prava registr–

         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         push      cs
         pop       ds                       ; DS <- CS
         cld
         cli

; ------ kontrola ‡¡sla videom¢du

         mov       bl,es:[449h]
         and       bl,7fh
         cmp       bl,6
         jbe       initVRg3
InitVRg2:jmp       InitVRg9

; ------ stanoven¡ ‡¡sla tabulky

InitVRg3:mov       bh,0
         mov       ah,ds:[bx+TabInit+KORIG]  ; ‡¡slo tabulky

; ------ adresa defini‡n¡ tabulky

         mov       al,DELKTAB               ; d‚lka tabulky registr–
         mul       ah                       ; offset v tabulce
         add       ax,offset InitTRT+KORIG  ; adresa tabulky
         xchg      ax,si                    ; SI <- adresa tabulky registr–

; ------ nastaven¡ registr– CRT

         mov       dx,3d4h
         mov       ah,0
InitVRg5:lodsb
         call      SetCRT
InitVRg6:inc       ah
         cmp       ah,8
         jb        InitVRg5
         je        InitVRg6
         cmp       ah,0ch
         jb        InitVRg5
         cmp       ah,10h
         jb        InitVRg6
         cmp       ah,16h
         jbe       InitVRg5

; ------ n vrat registr–

InitVRg9:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitVReg ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registru AH ©adi‡e CRT na AL (adresa DX)
; -----------------------------------------------------------------------------

SetCRT   PROC      NEAR

         xchg      al,ah
         out       dx,al
         xchg      al,ah
         inc       dx
         jmp       short $+2
         out       dx,al
         dec       dx
         ret

SetCRT   ENDP

TabInit  label     byte                     ; tabulka pro inicializaci
         db        0                        ; 00h: text 40x25/16
         db        0                        ; 01h: text 40x25/16
         db        1                        ; 02h: text 80x25/16
         db        1                        ; 03h: text 80x25/16
         db        2                        ; 04h: graf 320x200/4
         db        2                        ; 05h: graf 320x200/4
         db        3                        ; 06h: graf 640x200/2

InitTRT  label     byte

; ------ 0: 0, 1 (text 40x25/16)

         db        55                       ; 0: po‡et horiz. pozic celkem - 5
         db        39                       ; 1: po‡et zobrazen˜ch znak– - 1
         db        43                       ; 2: po‡ tek horizont l. zatemnˆn¡
         db        ((43+10) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnˆn¡
         db        47                       ; 4: po‡ tek horiz. synchronizace
         db        (47+4) AND 1fh           ; 5: konec hor.synchr.
         db        (312-1) AND 0ffh         ; 6: po‡et vertik. linek celkem - 1
         db        b0+b4                    ; 7: dopl¤uj¡c¡ bity registr–
         db        7                        ; 9: po‡et linek na znak - 1
         db        7                        ; 0Ah: po‡ te‡n¡ linka kurzoru
         db        7                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: za‡ tek vertik. synchronizace
         db        ((252+4) AND 0fh)+b4+b5  ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: p©¡rustek adresy v pamˆti/2
         db        31                       ; 14h: podtr‘en¡ MDA
         db        244-1                    ; 15h: za‡ tek vertik l. zatemnˆn¡-1
         db        (244+25) AND 1fh         ; 16h: konec vertik ln¡ho zatemnˆn¡
InitTRT0 label     byte

; ------ 1: 2, 3 (text 80x25/16)
;þ
;0.56493186
         db        112 ;111                 ; 0: po‡et horiz. pozic celkem
         db        80  ;79                  ; 1: po‡et zobrazen˜ch znak–
         db        90  ;85                  ; 2: po‡ tek horiz. zatemnˆn¡
         db        32  ;((85+21) AND 1fh)+b7; 3: konec horiz. zatemnˆn¡
         db        90  ;90                  ; 4: po‡ tek horiz. synchronizace
         db        0a2h;(90+8) AND 1fh      ; 5: konec hor. synchr.
         db        287 AND 0ffh ;(312-1) AND 0ffh ; 6: po‡et vertik. linek celkem - 1
         db        b2+b3+b4 ;b0+b4          ; 7: dopl¤uj¡c¡ bity registr–
         db        119 ;7                   ; 9: po‡et linek na znak - 1
         db        6   ;7                   ; 0Ah: po‡ te‡n¡ linka kurzoru
         db        7   ;7                   ; 0Bh: koncov  linka kurzoru
         db        284 AND 0ffh ;252        ; 10h: za‡ tek vertik. synchronizace
         db        30h ;((252+4) AND 0fh)+b4+b5  ; 11h: d‚lka vertik. synchronizace
         db        281 AND 0ffh ;199        ; 12h: posledn¡ zobrazen  linka
         db        40  ;40                  ; 13h: p©¡rustek adresy v pamˆti/2
         db        31  ;31                  ; 14h: podtr‘en¡ MDA
         db        243 ;244-1               ; 15h: za‡ tek vertik l. zatemnˆn¡-1
         db        0dh ;(244+25) AND 1fh    ; 16h: konec vertik ln¡ho zatemnˆn¡

; ------ 2: 4, 5: (grafika 320x200/4)

         db        55                       ; 0: po‡et horiz. pozic celkem - 5
         db        39                       ; 1: po‡et zobrazen˜ch znak– - 1
         db        43                       ; 2: po‡ tek horizont l. zatemnˆn¡
         db        ((43+10) AND 1fh)+b7     ; 3: konec horizont ln¡ho zatemnˆn¡
         db        46                       ; 4: po‡ tek horiz. synchronizace
         db        (46+4) AND 1fh           ; 5: konec hor.synchr.
         db        (312-1) AND 0ffh         ; 6: po‡et vertik. linek celkem - 2
         db        b0+b4                    ; 7: dopl¤uj¡c¡ bity registr–
         db        1                        ; 9: po‡et linek na znak - 1
         db        1                        ; 0Ah: po‡ te‡n¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: za‡ tek vertik. synchronizace
         db        ((252+4) AND 0fh)+b4+b5  ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        20                       ; 13h: p©¡rustek adresy v pamˆti/2
         db        0                        ; 14h: podtr‘en¡ MDA
         db        244-1                    ; 15h: za‡ tek vertik l. zatemnˆn¡
         db        (244+25) AND 1fh         ; 16h: konec vertik ln¡ho zatemnˆn¡

; ------ 3: 6 (graf 640x200/2)

         db        111                      ; 0: po‡et horiz. pozic celkem - 5
         db        79                       ; 1: po‡et zobrazen˜ch znak– - 1
         db        85                       ; 2: po‡ tek horiz. zatemnˆn¡
         db        ((85+21) AND 1fh)+b7     ; 3: ¨¡©ka horiz. zatemnˆn¡
         db        90                       ; 4: po‡ tek horiz. synchronizace
         db        (90+8) AND 1fh           ; 5: ¨¡©ka hor.synchr.
         db        (312-1) AND 0ffh         ; 6: po‡et vertik. linek celkem - 2
         db        b0+b4                    ; 7: dopl¤uj¡c¡ bity registr–
         db        1                        ; 9: po‡et linek na znak - 1
         db        1                        ; 0Ah: po‡ te‡n¡ linka kurzoru
         db        0                        ; 0Bh: koncov  linka kurzoru
         db        252                      ; 10h: za‡ tek vertik. synchronizace
         db        ((252+4) AND 0fh)+b4+b5  ; 11h: d‚lka vertik. synchronizace
         db        199                      ; 12h: posledn¡ zobrazen  linka
         db        40                       ; 13h: p©¡rustek adresy v pamˆti/2
         db        0                        ; 14h: podtr‘en¡ MDA
         db        244-1                    ; 15h: za‡ tek vertik l. zatemnˆn¡
         db        (244+25) AND 1fh         ; 16h: konec vertik ln¡ho zatemnˆn¡

RezidEnd label     byte                     ; konec rezidentn¡ho programu

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Instalace programu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ £schova p©¡kazov‚ho © dku

Instal:  mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       di,offset Command        ; buffer p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld
         rep       movsb                    ; p©enos textu do bufferu
         mov       ds:[di],ch               ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ posun rezidentn¡ho programu dol–

         mov       si,offset RezidBeg       ; za‡ tek rezidentn¡ho programu
         mov       di,offset RezidBeg+KORIG ; nov  adresa
         mov       cx,offset(RezidEnd-RezidBeg+1)/2 ; d‚lka programu (slov)
         rep       movsw                    ; posun programu dol–

; ------ instalace INT 23h

         mov       dx,offset INt23
         mov       ax,2523h
         int       21h

; ------ test, zda je program ji‘ nainstalov n

         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         mov       dx,KLIC4
         int       10h                      ; test instalace programu
         cmp       bx,KLIC5                 ; je program nainstalov n ?
         je        Instal1                  ; je nainstalov n
         push      cs
         pop       es                       ; ES <- CS
         or        byte ptr ds:[ParamI],b0  ; p©¡znak prvn¡ instalace programu
Instal1: mov       ds:[RezSegm],es          ; rezidentn¡ segment

; ------ rozbor zad n¡ parametr–

         call      Rozbor                   ; rozbor zad n¡ parametr–
         jnc       Instal2                  ; zad n¡ parametr– OK

; ------ chyba

         mov       dx,offset HelpTxt        ; text n povˆdy
Chyba:   push      dx
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         pop       dx
         mov       ah,9
         int       21h                      ; zobrazen¡ textu chyby
         int       20h

; ------ p©einstalov n¡ videom¢du

Instal2: test      byte ptr ds:[ParamI],b2
         jz        Instal30
         call      ReInit                   ; p©einstalov n¡ videom¢du

; ------ test, zda m  b˜t program odinstalov n

Instal30:test      byte ptr ds:[ParamI],b1  ; po‘adov no odinstalov n¡ ?
         jz        Instal4                  ; nen¡ po‘adov no odinstalov n¡

; ------ test, zda je program nainstalov n

         mov       dx,offset NebylTxt       ; text - nebyl nainstalovan
         test      byte ptr ds:[ParamI],b0  ; je to prvn¡ instalace ?
         jnz       Chyba                    ; je prvn¡ instalace - konec

; ------ test, zda lze program odinstalovat

         call      TestDIns                 ; test odinstalov n¡ programu
         mov       dx,offset NelzeTxt
         jc        Chyba                    ; chyba - nelze odinstalovat

; ------ odinstalov n¡ programu

         call      OdInst                   ; odinstalov n¡
         mov       dx,offset OdInsTxt
         jmp       short Chyba

; ------ test, zda m  b˜t program nainstalov n

Instal4: test      byte ptr ds:[ParamI],b0  ; je to prvn¡ instalace ?
         mov       dx,offset NicTxt
         jz        Chyba                    ; nen¡ to prvn¡ instalace

; ------ instalace INT 10h

         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       word ptr ds:[Old10+KORIG],bx
         mov       word ptr ds:[Old10+KORIG+2],es
         mov       dx,offset Int10 + KORIG  ; obsluha INT 10h
         mov       ax,2510h
         int       21h                      ; instalace obsluhy INT 10h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ inicializace videom¢du

         call      InitVMod                 ; inicializace videom¢du

; ------ instalace programu do pamˆti

         mov       dx,offset Instal + KORIG
         int       27h                      ; instalace programu do pamˆti

Int23:   iret

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu ES
; -----------------------------------------------------------------------------

OdInst   PROC      NEAR

         push      ds
         lds       dx,es:[Old10+KORIG]      ; p–vodn¡ adresa INT 10h
         mov       ax,2510h
         int       21h                      ; n vrat adresy INT 10h
         pop       ds

         test      byte ptr es:[Param+KORIG],b0; je TV m¢d ?
         jz        OdInst2                  ; nen¡ TV m¢d

         call      ReInit

OdInst2: mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku pamˆti programu
         ret

OdInst   ENDP

; -----------------------------------------------------------------------------
;        test, zda lze program ES odinstalovat
; -----------------------------------------------------------------------------

TestDIns PROC      NEAR

; ------ test, zda program lze odinstalovat

         push      es
         mov       cx,es
         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       ax,es                    ; segment adresy INT 10h
         cmp       ax,cx                    ; je to rezidentn¡ program ?
         pop       es
         je        TestDIn2
         stc
TestDIn2:ret

TestDIns ENDP

; -----------------------------------------------------------------------------
;        p©einstalov n¡ videom¢du
; -----------------------------------------------------------------------------

ReInit   PROC      NEAR

         push      ds
         push      es

         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[488h],not 0fh
         or        byte ptr ds:[488h],9
         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h                      ; inicializace videom¢du

         pop       es
         pop       ds
         ret

ReInit   ENDP

; *****************************************************************************
;
;                         Rozbor zad n¡ parametr–
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        rozbor zad n¡ parametr– (DS=datov˜ segment, ES=rezidentn¡ program)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ nalezen¡ platn‚ho znaku

         mov       si,offset Command
Rozbor1: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ znaku
         jnc       Rozbor2
         clc                                ; p©¡znak zad n¡ parametr– OK
         ret
Rozbor2: cmp       al,"/"
         je        Rozbor1                  ; znak "/" se ignoruje

; ------ parametr "A" - zapnut¡ televizn¡ho m¢du

Rozbor3: cmp       al,"A"
         jne       Rozbor4
         or        byte ptr es:[Param+KORIG],b0 ; zapnut¡ m¢du TV
         or        byte ptr ds:[ParamI],b2  ; po‘adavek reinicializace
         jmp       short Rozbor1            ; dal¨¡ parametr

; ------ parametr "N" - vypnut¡ televizn¡ho m¢du

Rozbor4: cmp       al,"N"
         jne       Rozbor5
         and       byte ptr es:[Param+KORIG],not b0 ; vypnut¡ m¢du TV
         or        byte ptr ds:[ParamI],b2  ; po‘adavek reinicializace
         jmp       short Rozbor1

; ------ parametr "!" - odinstalov n¡ programu

Rozbor5: cmp       al,"!"
         jne       Rozbor6
         or        byte ptr ds:[ParamI],b1  ; povel pro odinstalov n¡
         jmp       short Rozbor1

Rozbor6:
Rozbor7:
         stc                                ; p©¡znak chyby zad n¡ parametr–
         ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         jc        RozbSpc2                 ; konec textu
         je        RozbSpc                  ; mezera
         dec       si
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

; ------ na‡ten¡ znaku

         cld
         lodsb

; ------ n hrada tabel toru mezerou

         cmp       al,9
         jne       RozbChr1
         mov       al," "                   ; n hrada tabel toru mezerou

; ------ konverze na velk‚ p¡smeno

RozbChr1:cmp       al,"a"
         jb        RozbChr2
         cmp       al,"z"
         ja        RozbChr2
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ test, zda je konec textu

RozbChr2:cmp       al," "
         jae       RozbChr3
         dec       si
RozbChr3:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        inicializace videom¢du
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

; ------ p©edefinov n¡ videom¢du

         call      ReInit

; ------ hl ¨en¡ o instalaci programu

         mov       ax,1301h
         mov       bx,70h                   ; barva textu a str nka
         mov       cx,offset(InstTxt0-InstTxt) ; d‚lka textu
         xor       dx,dx                    ; po‡ te‡n¡ pozice a © dek
         mov       bp,offset InstTxt        ; text k zobrazen¡
         push      cs
         pop       es
         int       10h                      ; zobrazen¡ £vodn¡ho textu
         ret

InitVMod ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                    data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ

RezSegm  dw        0                        ; segment rezidentn¡ho programu

ParamI   db        0                        ; parametry pro inicializaci
                                            ;  bit 0: 1=je prvn¡ instalace
                                            ;  bit 1: 1=po‘adov no odinstalov n¡
                                            ;  bit 2: 1=nutn  reinicialice m¢du

UvTxt    db        'TVMODCGA V1.0 - televizni emulator pro CGA; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte: A .... zapnuti televizniho modu (emulator aktivni)',13,10
         db        '         N .... vypnuti televizniho modu (emulator neaktivni)',13,10
         db        '         ! .... odinstalovani programu z pameti',13,10
NicTxt   db        '$'

NebylTxt db        'TVMODCGA nebyl dosud nainstalovan !',13,10,'$'
NelzeTxt db        'TVMODCGA nelze odinstalovat ! Odinstalujte',13,10
         db        'nejdrive programy nainstalovane po nem.',13,10,'$'
OdInsTxt db        'TVMODCGA byl odinstalovan z pameti.',13,10,'$'

InstTxt  db        13,10
         db        ' ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» ',13,10
         db        ' º           TVMODCGA V1.0          º ',13,10
         db        ' º televizni emulator pro kartu CGA º ',13,10
         db        ' º       (c) Miroslav Nemecek       º ',13,10
         db        ' ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ ',13,10
InstTxt0 label     byte

Command  db        128 dup(?)               ; buffer p©¡kazov‚ho © dku

Code     ENDS
         END       Start

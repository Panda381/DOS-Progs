
; *****************************************************************************
;
;              Emul tor grafick‚ karty CGA pro kartu Hercules
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

emucga:  jmp       instal                   ; instalace programu

parint   db        4                        ; p©¡znaky p©eru¨en¡
                                            ;  bit 0,1: po‡et blok– po 2000h
                                            ;  bit 2: (1=simulace text. m¢du)
                                            ;  bit 3:
                                            ;  bit 4: 1=emul tor je neaktivn¡
                                            ;  bit 5: 1=kop¡rov n¡ zak zan‚
                                            ;  bit 6: 1=prob¡h  kop¡rov n¡
                                            ;  bit 7: 1=neprokl dan  grafika

old08    dd        0                        ; adresa p–vodn¡ obsluhy INT 08h
old10    dd        0                        ; adresa p–vodn¡ obsluhy INT 10h

adrcop   dw        2000h                    ; cyklick  adresa pro operace
numcop   dw        400h                     ; po‡et kop¡rovan˜ch slov

tabint11 dd        00400010h                ; adresa tabulky vybaven¡

tabinitp label     byte                   ;* tabulka parametr– - prokl dan  g.
         db        53                       ; 0:celkov˜ po‡et znak– na © dek-1
         db        40                       ; 1:po‡et vidit. znak– na © dek
         db        44                       ; 2:po‡ tek horiz. zatemnˆn¡
         db        7                        ; 3:po‡et znak– na synchronizaci

         db        121                      ; 4:celk. po‡et vert. © dk–-1 (363)
         db        2                        ; 5:po‡et linek + k po‡tu © dk–
         db        100                      ; 6:po‡et viditeln˜ch © dk– (300)
         db        115                      ; 7:© dka zpˆtn‚ho bˆhu (345)
         db        2                        ; 8:1=prokl d n¡, 2=normal
         db        2                        ; 9:po‡et linek na znak - 1 (3)

         db        0                        ; 0a:prvn¡ linka kurzoru
         db        2                        ; 0b:koncov  linka kurzoru


tabinitn label     byte                   ;* tabulka parametr– - neprokl dan  g.
         db        53                       ; 0:celkov˜ po‡et znak– na © dek-1
         db        40                       ; 1:po‡et vidit. znak– na © dek
         db        44                       ; 2:po‡ tek horiz. zatemnˆn¡
         db        7                        ; 3:po‡et znak– na synchronizaci

         db        127                      ; 4:celk. po‡et vert. © dk–-1 (364)
         db        2                        ; 5:po‡et linek + k po‡tu © dk–
         db        100                      ; 6:po‡et viditeln˜ch © dk– (200)
         db        116                      ; 7:© dka zpˆtn‚ho bˆhu (346)
         db        2                        ; 8:1=prokl d n¡, 2=normal
         db        1                        ; 9:po‡et linek na znak - 1

         db        0                        ; 0a:prvn¡ linka kurzoru
         db        2                        ; 0b:koncov  linka kurzoru

; -----------------------------------------------------------------------------
;                 Obsluha ‡asova‡e - kop¡rov n¡ videopamˆti
; -----------------------------------------------------------------------------

int08:                                    ;* obsluha INT 08h

         pushf
         call      dword ptr cs:[old08]     ; p–vodn¡ obsluha INT 08h
         test      byte ptr cs:[parint],70h ; prob¡h  kop¡rov n¡/je z kaz ?
         jz        int085                   ; neprob¡h  kop¡rov n¡, nen¡ z kaz
         iret

                                          ;* obsluha kop¡rov n¡
int085:  or        byte ptr cs:[parint],40h ; nastaven¡ p©¡znaku kop¡rov n¡
         sti                                ; povolen¡ p©eru¨en¡
         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         cmp       byte ptr es:[449h],3     ; je m¢d displeje CGA ?
         jbe       int089                   ; je m¢d displeje CGA
         cmp       byte ptr es:[449h],7
         je        int089                   ; je textov˜ videom¢d MDA

                                          ;* obsluha grafick‚ho displeje CGA
         mov       ax,0b800h                ; segment videopamˆti CGA
         mov       es,ax                    ; ES <- B800h
         mov       ds,ax                    ; DS <- B800h

         mov       cl,cs:[parint]           ; po‡et blok– 2000h
         and       cx,3                     ; po‡et blok– 2000H
         inc       cx                       ; po‡et blok– + 1
int082:  push      cx
         mov       si,cs:[adrcop]           ; adresa pro operaci
         mov       di,si
         add       di,2000h                 ; ukl dac¡ adresa
         mov       cx,cs:[numcop]           ; po‡et bajt– k p©esunu
         jcxz      int083                   ; nen¡ ‘ dn˜ bajt k p©esunu
         cld                                ; smˆr nahoru
         rep       movsw                    ; p©enos displeje
         cmp       si,4000h                 ; je ji‘ konec videopamˆti ?
         jb        int083                   ; nen¡ je¨tˆ konec videopamˆti
         mov       si,2000h                 ; p©esun na za‡ tek videopamˆti
int083:  mov       cs:[adrcop],si           ; zpˆtn‚ ulo‘en¡ nov‚ adresy
         pop       cx                       ; ‡¡ta‡ blok–
         loop      int082                   ; dal¨¡ blok
int089:  pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax

         and       byte ptr cs:[parint],not 40h ; zru¨en¡ p©¡znaku kop¡rov n¡
         iret

; -----------------------------------------------------------------------------
;                     Vymaz n¡ grafick‚/textov‚ videopamˆti
; -----------------------------------------------------------------------------
clearcga:                                 ;* vymaz n¡ videopamˆti CGA
         push      cx
         push      ax
         push      di
         push      es
         mov       cx,4000h
         mov       ax,0b800h
         mov       es,ax
         xor       ax,ax
         mov       di,ax
         cld
         rep       stosw
         pop       es
         pop       di
         pop       ax
         pop       cx
         ret

clearhgc:                                 ;* vymaz n¡ videopamˆti HGC
         push      cx
         push      ax
         push      di
         push      es
         mov       cx,4000h
         mov       ax,0b000h
         mov       es,ax
         xor       di,di
         mov       ax,0f20h                 ; mazac¡ znak (mezera)
         cld
         rep       stosw
         pop       es
         pop       di
         pop       ax
         pop       cx
         ret

; -----------------------------------------------------------------------------
;                      Inicializace video©adi‡e
; -----------------------------------------------------------------------------

inithgc:                                  ;* inicializace video©adi‡e
         cli                                ; z kaz p©eru¨en¡
         push      ax
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds

         mov       al,3
         mov       dx,3bfh
         out       dx,al

         mov       al,2
         mov       dx,3b8h
         out       dx,al

         mov       dx,3b4h
         mov       si,offset tabinitp       ; tabulka pro inicializaci - prokl.
         test      byte ptr cs:[parint],80h ; je prokl dan  grafika ?
         jz        inithgc1                 ; je prokl dan  grafika
         mov       si,offset tabinitn       ; tabulka pro inicializaci - nepr.
inithgc1:
         call      inittab                  ; inicializace podle tabulky

         mov       al,8ah
         mov       dx,3b8h
         out       dx,al

         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
inittab:                                  ;* inic. registr– podle tabulky
                                            ; VSTUP: DS:SI=ukazatel tabulky
                                            ;        DX=adresa portu

         push      ax
         xor       ah,ah
         cld
inittab2:lodsb
         call      initreg                  ; inicializace registru
         inc       ah
         cmp       ah,12
         jb        inittab2                 ; dal¨¡ registr
         pop       ax
         ret

; -----------------------------------------------------------------------------
initreg:                                  ;* inicializace jednoho registru
                                            ; VSTUP: AH=registr
                                            ;        AL=hodnota pro nastaven¡
                                            ;        DX=adresa registru

         push      ax
         mov       al,ah
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         pop       ax
         inc       dx
         out       dx,al                    ; data pro nastaven¡ registru
         dec       dx
         ret

; -----------------------------------------------------------------------------
;                             Obsluha INT 10h
; -----------------------------------------------------------------------------
int100:                                   ;* vol n¡ p–vodn¡ obsluhy INT 10h
         pushf
         call      dword ptr cs:[old10]     ; vol n¡ p–vodn¡ obsluhy INT 10h
         ret


inittc:                                   ;* inicializace text. videom¢du CGA
         cli
         push      es
         push      ds
         push      dx
         push      cx
         push      ax
         push      di
         push      si

         push      ax
         lds       si,cs:[tabint11]         ; adresa tabulky vybaven¡
         or        byte ptr ds:[si],30h     ; p©¡nak videom¢du 80x25 mono
         xor       al,al
         mov       dx,3bfh
         out       dx,al
         mov       ax,7
         call      int100                   ; nastaven¡ videom¢du 7
         pop       ax
                                          ;* p©epnut¡ na videom¢d CGA
         lds       si,cs:[tabint11]         ; adresa tabulky vybaven¡
         mov       ds:[49h],al              ; nov˜ videom¢d

         mov       al,ds:[si]               ; bajt vybaven¡
         and       al,0efh
         or        al,20h                   ; nastaven¡ barevn‚ho videom¢du
         mov       ds:[si],al               ; nov  hodnota vybaven¡

;         mov       word ptr ds:[63h],3b4h
;         xor       al,al
         mov       al,3
         mov       dx,3bfh
         out       dx,al                    ; p©epnut¡ do textov‚ho m¢du

         mov       al,ds:[65h]
         or        al,80h
;         mov       al,088h
         mov       ds:[65h],al
         mov       dx,3b8h
         out       dx,al

         mov       cx,4000h
         mov       ax,0b800h
         mov       es,ax
         xor       di,di
         mov       ax,0f20h                 ; mazac¡ znak (mezera)
         cld
         rep       stosw

         cmp       byte ptr ds:[49h],2
         jae       inittc4
                                          ;* videom¢d 40 znak–
         mov       word ptr ds:[4ah],40     ; po‡et pozic na © dek
         mov       word ptr ds:[4ch],1000h   ; d‚lka bufferu

         mov       dx,3b4h
         mov       al,1
         out       dx,al                    ; nastaven¡ registru 1
         inc       dx                       ; port dat registru
         mov       al,40
         out       dx,al                    ; po‡et znak– na © dek

         dec       dx
         mov       al,2
         out       dx,al                    ; nastaven¡ registru 2
         inc       dx
         mov       al,70
         out       dx,al                    ; po‡ tek synchonizace

         mov       al,ds:[65h]
         and       al,not 1
         mov       ds:[65h],al
         mov       dx,3b8h
         out       dx,al                    ; re‘im 40 znak–
inittc4:
         pop       si
         pop       di
         pop       ax
         pop       cx
         pop       dx
         pop       ds
         pop       es
         sti
         iret


int10:                                    ;* obsluha INT 10h

                                          ;* dotaz na instalaci
         cmp       ah,12h                   ; je dotaz na instalaci ?
         jne       int101                   ; nen¡ dotaz na instalaci
         cmp       bx,6543h                 ; je dotaz na instalaci ?
         jne       int101                   ; nen¡ dotaz na instalaci
         mov       bx,3456h                 ; identifikace, ‘e je nainstalov n
         push      cs
         pop       es                       ; ES <- CS segment rezidentn¡ ‡ sti
         iret

                                          ;* test, zda je nastaven¡ videom¢du
int101:  test      byte ptr cs:[parint],10h ; je emul tor neaktivn¡ ?
         jnz       int107                   ; je neaktivn¡
         or        ah,ah                    ; je inicializace ?
         jz        int105                   ; je inicializace videom¢du
int107:  call      int100                   ; p–vodn¡ obsluha INT 10h
         iret

                                          ;* rozvˆtven¡ podle videom¢du
int105:  cmp       al,7                     ; je standardn¡ videom¢d MDA ?
         je        inittxt                  ; inicializace MDA
         cmp       al,3                     ; je CGA m¢d ?
         ja        int106                   ; je grafick˜ videom¢d
         jmp       inittc                   ; je CGA textov˜ m¢d

int106:                                   ;* inicializace grafick‚ho m¢du
         push      ds
         push      si

         push      ax
         cli                                ; z kaz p©eru¨en¡
         lds       si,cs:[tabint11]         ; adresa tabulky vybaven¡
         mov       al,ds:[si]               ; bajt vybaven¡
         and       al,not 10h
         or        al,20h                   ; nastaven¡ barevn‚ho videom¢du
         mov       ds:[si],al               ; nov  hodnota vybaven¡
         call      inithgc                  ; inicializace video©adi‡e
         sti
         pop       ax

         call      int100                   ; nastaven¡ grafick‚ho m¢du

         push      ax
         push      bx
         mov       ah,0bh
         xor       bx,bx
         call      int100                   ; inicializace palet displeje
         call      clearhgc                 ; vymaz n¡ videopamˆti HGC
         call      clearcga                 ; vymaz n¡ videopamˆti CGA
         xor       ax,ax
         mov       ds,ax
         mov       word ptr ds:[463h],3b4h  ; nastaven¡ b zov‚ ©¡dic¡ adresy
         pop       bx
         pop       ax

         pop       si
         pop       ds
         sti
         iret


inittxt:                                  ;* inicializace text. videom¢du MDA
         cli
         push      ds
         push      dx
         push      ax
         push      si

         lds       si,cs:[tabint11]         ; adresa tabulky vybaven¡
         or        byte ptr ds:[si],30h     ; p©¡nak videom¢du 80x25 mono
         xor       al,al
         mov       dx,3bfh
         out       dx,al

         mov       ax,7
         call      int100                   ; nastaven¡ videom¢du 7
         call      clearhgc                 ; vymaz n¡ videopamˆti HGC

         pop       si
         pop       ax
         pop       dx
         pop       ds
         sti
         iret


; *****************************************************************************
;
;                       instalace programu
;
; *****************************************************************************

instal:
                                          ;* nalezen¡ segmentu rezidentn¡ ‡ sti
         push      cs
         pop       es                       ; p©ednastaven¡ ES <- CS
         mov       ah,12h
         mov       bx,6543h                 ; identifikace dotazu na instalaci
         int       10h                      ; dotaz, zda je ji‘ instalov n
         cmp       bx,3456h                 ; je nainstalov n ?
         je        instal1                  ; je nainstalov n
         push      cs
         pop       es                       ; jinak ES <- CS

instal1:                                  ;* dek¢dov n¡ zadan˜ch parametr–
         mov       cl,es:[parint]           ; sou‡asn‚ nastaven¡ parametr–
         push      cx
         call      dekpar                   ; dek¢dov n¡ parametr–
         pop       cx
         jnc       instal2                  ; parametry zad ny OK

                                          ;* chyba zad n¡ parametr–, n povˆda
         mov       dx,offset texthlp        ; text n povˆdy
         call      zobrtxt                  ; zobrazen¡ n povˆdy
         int       20h                      ; ukon‡en¡ programu

instal2:                                  ;* test, zda je instalace
         mov       ax,es                    ; segment rezidentn¡ ‡ sti
         mov       bx,cs                    ; segment tohoto programu
         cmp       ax,bx                    ; je rezidentn¡ ‡ st ?
         je        instal4                  ; je to prvn¡ instalace

                                          ;* p©edefinov n¡ vidoem¢du
         mov       al,es:[parint]           ; sou‡asn‚ nastaven¡ parametr–
         and       al,0f0h                  ; nov‚ parametry programu
         and       cl,0f0h                  ; star‚ parametry programu
         cmp       al,cl                    ; byla zmˆna parametr– ?
         je        instal22                 ; nebyla zmˆna parametr–

                                          ;* p©einstalov n¡ videom¢du
         mov       ah,0fh
         int       10h                      ; poskytnut¡ aktivn¡ho videom¢du
         and       ax,7fh                   ; zru¨en¡ p©¡znaku nemazat displej
         int       10h                      ; p©enastaven¡ videom¢du

instal22:                                 ;* je rezidentn¡ - zobrazen¡ stavu
         mov       dx,offset textakt        ; text - je aktivn¡
         test      byte ptr es:[parint],10h ; je emul tor aktivn¡ ?
         jz        instal3                  ; emul tor je aktivn¡
         mov       dx,offset textnakt       ; text - je neaktivn¡
instal3: call      zobrtxt                  ; zobrazen¡ informace o aktivitˆ
         int       20h


instal4:                                  ;* prvn¡ instalace emul toru

         mov       al,3
         mov       dx,3bfh
         out       dx,al                    ; nastaven¡ ????

                                          ;* instalace INT 08h
         push      es
         mov       ax,3508h
         int       21h                      ; poskytnut¡ p–vodn¡ adresy INT 08h
         mov       word ptr ds:[old08],bx   ; £schova offsetu INT 08h
         mov       word ptr ds:[old08+2],es ; £schova segmentu INT 08h
         mov       dx,offset int08          ; adresa vlastn¡ obsluhy INT 08h
         mov       ax,2508h
         int       21h                      ; instalace vlastn¡ obsluhy INT 08h
         pop       es

                                          ;* instalace INT 10h
         push      es
         mov       ax,3510h
         int       21h                      ; poskytnut¡ p–vodn¡ adresy INT 10h
         mov       word ptr ds:[old10],bx   ; £schova offsetu INT 10h
         mov       word ptr ds:[old10+2],es ; £schova segmentu INT 10h
         mov       dx,offset int10          ; adresa vlastn¡ obsluhy INT 10h
         mov       ax,2510h                 
         int       21h                      ; instalace vlastn¡ obsluhy INT 10h
         pop       es

                                          ;* nastav. p©¡znaku barevn‚ho displeje
;         push      ds
;         lds       si,cs:[tabint11]         ; adresa tabulky vybaven¡
;         mov       al,ds:[si]               ; ‡ten¡ tabulky vybaven¡
;         and       al,not 10h
;         or        al,20h                   ; nastaven¡ p©¡znaku 80x25 barevn˜
;         mov       ds:[si],al
;         pop       ds

                                          ;* p©einstalov n¡ videom¢du
         mov       ah,0fh
         int       10h                      ; poskytnut¡ aktivn¡ho videom¢du
         and       ax,7fh                   ; zru¨en¡ p©¡znaku nemazat displej
         int       10h                      ; p©enastaven¡ videom¢du

         mov       dx,offset textinst       ; text - byl nainstalov n
         call      zobrtxt                  ; zobrazen¡ hl ¨en¡ o instalaci
         mov       dx,offset instal         ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace jako rezidentn¡


zobrtxt:                                  ;* zobrazen¡ textu (hl ¨en¡)
         push      dx
         mov       dx,offset uvtxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         pop       dx                       ; adresa po‘adovan‚ho textu
         mov       ah,9
         int       21h                      ; zobrazen¡ po‘adovan‚ho textu
         ret



dekpar:                                   ;* dek¢dov n¡ parametr–

         mov       si,81h                   ; p©¡kazov˜ © dek
         xor       bx,bx
         mov       bl,ds:[si-1]             ; po‡et znak–
         mov       byte ptr ds:[si+bx],0    ; konec textu

dekpar1: call      dekpch                   ; ‡ten¡ znaku
         jnc       dekpar8                  ; je platn˜ znak
         clc
         ret

dekpar8: cmp       al," "
         jbe       dekpar1                  ; je oddˆlova‡
         cmp       al,"/"
         je        dekpar1                  ; je oddˆlova‡ parametr–

                                          ;* parametr "/D"
         cmp       al,"D"
         jne       dekpar3
         test      byte ptr es:[parint],10h ; je emul tor aktivn¡ ?
         jnz       dekpar1                  ; je ji‘ neaktivn¡

         or        byte ptr es:[parint],10h ; deaktivace emul toru
         cli
         push      si
         push      ds
         push      es

         lds       si,cs:[tabint11]         ; adresa tabulky vybaven¡
         or        byte ptr ds:[si],30h     ; p©¡nak videom¢du 80x25 mono
         xor       al,al
         mov       dx,3bfh
         out       dx,al

         mov       ax,7
         int       10h                      ; nastaven¡ videom¢du 7
         call      clearhgc                 ; vymaz n¡ videopamˆti HGC

         pop       es
         pop       ds
         pop       si
         sti

         jmp       short dekpar1            ; dal¨¡ parametr

                                          ;* parametr "/A"
dekpar3: cmp       al,"A"
         jne       dekpar4
         and       byte ptr es:[parint],not 10h ; aktivace emul toru
         jmp       short dekpar1            ; dal¨¡ parametr

                                          ;* parametr "/E"
dekpar4: cmp       al,"E"
         jne       dekpar5
dekpara: and       byte ptr es:[parint],not 80h ; prokl dan  grafika
         and       byte ptr es:[parint],not 30h ; povolen¡ kop¡rov n¡, aktivace
dekpard: jmp       short dekpar1

                                          ;* parametr "/N"
dekpar5: cmp       al,"N"
         jne       dekpar6
         or        byte ptr es:[parint],80h ; neprokl dan  grafika
dekpar2: or        byte ptr es:[parint],20h ; z kaz kop¡rov n¡
         and       byte ptr es:[parint],not 10h ; aktivace emul toru
         jmp       short dekpard

                                          ;* parametr "/Bn"
dekpar6: cmp       al,"B"
         jne       dekpar7                  ; nen¡ parametr "/Bn"
         call      inpnum                   ; vstup ‡¡sla
         jc        dekpar7                  ; chyba zad n¡ ‡¡sla
         jz        dekpar2                  ; z kaz kop¡rov n¡ dat
         call      setblok                  ; nastaven¡ velikosti bloku
         jmp       short dekpara            ; dal¨¡ parametr

dekpar7:
         stc                                ; p©¡znak chyby parametru
         ret

                                          ;* ‡ten¡ platn‚ho znaku
dekpch:  mov       al,ds:[si]
         or        al,al
         stc
         jz        dekpch2
         inc       si
         cmp       al,"a"
         jb        dekpch1
         cmp       al,"z"
         ja        dekpch1
         sub       al,32
dekpch1: clc
dekpch2: ret


inpnum:                                   ;* vstup ‡¡sla -> AL
                                            ; v˜stup: CY=nen¡ ‡¡slo
                                            ;         ZY=je 0

         mov       al,ds:[si]
         sub       al,"0"
         jb        inpnum2
         cmp       al,10
         cmc
         jb        inpnum2
         inc       si
         or        al,al
inpnum2: ret

setblok:                                  ;* nastaven¡ bloku (AL)
         mov       cl,al                    ; konstanta pro p©enos bloku
         mov       ax,40h                   ; 64 bajt–
         shl       ax,cl                    ; rotace na 80h a‘ 8000h

         push      ax
         mov       cl,14
         shr       ax,cl                    ; po‡et blok– 2000h
         and       byte ptr es:[parint],not 3 ; zru¨en¡ po‡tu blok–
         or        byte ptr es:[parint],al  ; nastaven¡ po‡tu blok– 2000h
         pop       ax

         cmp       ax,2000h
         jb        setblok1
         mov       ax,2000h
setblok1:shr       ax,1                     ; p©evod na slova
         mov       es:[numcop],ax           ; po‡et kop¡rovan˜ch slov
         ret


uvtxt    db        'EMUCGA V1.10 - emulator CGA pro Hercules; (c) Miroslav Nemecek',13,10,'$'

textinst db        'Emulator CGA byl nainstalovan (?=napoveda).',13,10,'$'

textakt  db        'Emulator CGA je aktivni.',13,10,'$'

textnakt db        'Emulator CGA je neaktivni.',13,10,'$'

texthlp  db        'Zadejte: /A  - aktivace emulatoru',13,10
         db        '         /D  - deaktivace emulatoru',13,10
         db        '         /E  - expandovana grafika (prokladana)',13,10
         db        '         /N  - normalni grafika (snimkovani CGA)',13,10
         db        '         /Bn - blok dat kopirovany najednou (0...9)',13,10
         db        '             (0=vypnuto,1=80h bajtu...9=8000h bajtu)',13,10
         db        'Standardne: EMUCGA /A /E /B5',13,10
         db        '$'

code     ENDS
         END       emucga

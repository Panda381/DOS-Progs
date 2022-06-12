; P©ehr v  konstantn¡ soubor CITY.FLI.
; Vytvo©¡ si 64k buffer a ‡te tak, aby v nˆm po© d bylo 65536-1 bajt–.
; Nen¡ vy©e¨en  prodleva mezi obr zky.
.286
code     segment
         assume    cs:code, ds:code

         org       100h
start:
         cld
         mov  sp,offset KonZasob

; ------ Zji¨tˆn¡ nastaven‚ho videom¢du
         mov  ah,0Fh                        ; Zji¨tˆn¡ aktu ln¡ho videom¢du
         int  10h
         mov  OldVMod,al                    ; —schova ‡¡sla videom¢du

; ------ Kotrola 80286
;        Sem doplnit kontrolovac¡ rutinu, kdy‘ je XT, tak volat chybu ChConfig

; ------ Zmen¨en¡ segmentu programu na minimum
         mov  ah,4Ah                        ; Zmen¨en¡ bloku pamˆti
         mov  bx,offset KonPrg
         shr  bx,4
         inc  bx
         int  21h
         mov  dx,offset ChPrPam             ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby

; ------ Alokov n¡ pamˆti pro ‡tec¡ buffer
         mov  ah,48h                        ; Alokov n¡ pamˆti
         mov  bx,1000h                      ; 64k
         int  21h
         mov  dx,offset ChNePam             ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby
         mov  RBuf,ax                       ; —schova p©idˆlen‚ho segmentu

; ------ Nastaven¡ videom¢du
         mov  ax,13h                        ; Videom¢d 320x200/256
         int  10h
         mov  ah,0Fh                        ; Kontrola nastaven‚ho videom¢du
         int  10h
         mov  dx,offset ChConfig            ; Chybov‚ hl ¨en¡ (nen¡ VGA)
         cmp  al,13h                        ; Byl nastaven videom¢d 320x200/256?
         call ChybaNE                       ; O¨et©en¡ p©¡padn‚ chyby

; ------------------------------------------------------------------------------

; ------ Otev©en¡ souboru pro ‡ten¡
         mov  ax,3D00h                      ; Otev©en¡ pro ‡ten¡
         mov  dx,offset JmSou               ; Jm‚no souboru
         int  21h
         mov  dx,offset ChSouNen            ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby
         mov  Handle,ax

; ------ €ten¡ hlavi‡ky souboru
         mov  bx,ax                         ; Handle souboru
         mov  ah,3Fh                        ; €ten¡ ze souboru
         mov  cx,80h                        ; D‚lka ‡ten˜ch dat
         mov  ds,RBuf                       ; Segment ‡tec¡ho bufferu
         xor  dx,dx                         ; Offset ‡tec¡ho bufferu
         int  21h                           ; €ten¡ z hlav¡
         mov  dx,offset ChCtSou             ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby

; ------ Kontrola typu souboru
         cmp  word ptr ds:[4],0AF11h        ; Zna‡ka FLI souboru
         mov  dx,offset ChNeFLI             ; Chybov‚ hl ¨en¡
         call CHybaNE                       ; Chyba - nen¡ FLI

         cmp  word ptr ds:[6],0             ; Po‡et obr zk– v souboru = 0?
         call ChybaE                        ; Chyba - to asi nebude FLI

         cmp  word ptr ds:[8],320           ; Je ¨¡©ka 320?
         call CHybaNE                       ; Chyba - nen¡ FLI 320x200
         cmp  word ptr ds:[10],200          ; Je v˜¨ka 200?
         call CHybaNE                       ; Chyba - nen¡ FLI 320x200

; ------ Kontrola velikosti souboru
         mov  ax,4202h                      ; Seek na konec souboru + CX:DX
         xor  cx,cx
         mov  dx,cx
         int  21h
         mov  cx,dx
         mov  dx,offset ChSeekSo            ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby

         mov  dx,offset ChPoskSo
         cmp  ax,ds:[0]
         call ChybaNE                       ; Souhlas¡ velikost?
         cmp  cx,ds:[2]
         call ChybaNE                       ; Souhlas¡ velikost?

; ==============================================================================
; ------ Z hlav¡ souboru
;        dd   D‚lka souboru v bajtech
;        dw   0AF11h - Identifik tor FLI form tu
;        dw   Po‡et obr zk– v souboru
;        dw   Rozmˆr obrazovky X
;        dw   Rozmˆr obrazovky Y
;        dd   Identifik tor programu, ve kter‚m byl soubor vytvo©en
;        dw   Prodleva mezi obr zky *10 ms (5 = 20 obr zk– za sekundu)
;        db   110 dup (?) - Koment ©, kopyrajt nebo podobnˆ

; ------ P©evzet¡ parametr– z hlavi‡ky
         mov  ax,ds:[16]                    ; Rychlost p©ehr v n¡
         mov  cs:Rychlost,ax                ; —schova rychlosti
         mov  ax,ds:[6]                     ; Po‡et obr zk– v souboru
         mov  cs:PocObrVS,ax                ; —schova po‡tu obr zk–

         mov  ax,0A000h
         mov  es,ax

; ------------------------------------------------------------------------------


; ------ P©ehr v n¡ od za‡ tku
; ------ Seek na prvn¡ obr zek
Play00:  mov  ax,4200h                      ; Seek na za‡ tek souboru + CX:DX
         xor  cx,cx
         mov  dx,80h                        ; Za‡ tek prvn¡ho paketu
         int  21h
         mov  cx,dx
         mov  dx,offset ChSeekSo            ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby
         or   cx,cx
         call ChybaNE                       ; CX<>0 -> Chyba
         cmp  ax,80h
         call ChybaNE                       ; AX<>80h -> Chyba

; ------ Inicializace bufferov˜ch promˆnn˜ch
         mov  cs:KonecSou,0                 ; Nulov n¡ p©¡znaku konce souboru
         mov  cs:ZacDatVB,1                 ; Za‡ tek dat v bufferu = 1
         mov  cs:KonDatVB,1                 ; Konec dat v bufferu = 1

         mov  cs:AktObrVS,0                 ; Nulov n¡ po‡¡tadla obr zk–

; ------ Jeden obr zek
; ------ Kontrola stisku kl vesy (=Konec)
Play01:  mov  ah,1
         int  16h
         jnz  Konec00                       ; Byla stisknuta kl vesa?

; ------ Zpracov n¡ paketu
         call CtiBuf                        ; Na‡ten¡ bloku dat do bufferu
         call Pauza                         ; Pauza po vykreslen¡ obrazovky
;         call WaitZat                       ; €ek n¡ na zatemnˆn¡
         call ZprPaket                      ; Zpracov n¡ paketu

         inc  cs:AktObrVS                   ; Aktualizace po‡¡tadla obr zk–
         mov  ax,cs:AktObrVS
         cmp  ax,cs:PocObrVS                ; U‘ byl posledn¡?
         jb   Play01                        ; Ne, zpracuj dal¨¡

         jmp  short Play00                  ; Kreslen¡ znovu od za‡ tku


; ------------------------------------------------------------------------------

; ------ Uzav©en¡ souboru
Konec00: mov  ah,3Eh                        ; Uzav©en¡ souboru
         mov  bx,cs:Handle                  ; Handle souboru
         int  21h

; ------ Uvolnˆn¡ alokovan‚ pamˆti
         mov  ah,49h                        ; Uvolnˆn¡ pamˆti
         mov  es,cs:RBuf                    ; Segment ‡tec¡ho bufferu
         int  21h

; ------ Konec programu
         mov  ax,4C00h                      ; Konec, chybov˜ k¢d = 0
         int  21h

; ==============================================================================
; Zpracov n¡ jednoho paketu na za‡ tku dat v bufferu
; ==============================================================================

; ==============================================================================
; ------ Paket
;        dd   D‚lka paketu v bajtech
;        dw   0F1FAh - Identifik tor FLI paketu
;        dw   Po‡et superblok– v paketu
;        dw   0,0,0,0
;
;        ??   Superblok 1
;        ??   Superblok 2
;             ...
;        ??   Superblok N

ZprPaket:push ax
         push bx
         push cx
         push dx
         push si
         push di

         mov  si,cs:ZacDatVB                ; SI<- Za‡ tek dat v bufferu
         lodsw                              ; AX<- D‚lka paketu
         add  cs:ZacDatVB,ax                ; Posun za‡ tku dat za tento paket

; ------ Kontrola d‚lky paketu do 64k
         lodsw
         or   ax,ax
         mov  dx,offset ChDlPakt            ; Chybov‚ hl ¨en¡
         call ChybaNE                       ; O¨et©en¡ p©¡padn‚ chyby

; ------ Kontrola, zda je to FLI paket
         lodsw
         cmp  ax,0F1FAh
         mov  dx,offset ChFLIPak            ; Chybov‚ hl ¨en¡
         call ChybaNE                       ; O¨et©en¡ p©¡padn‚ chyby

; ------ Zpracov n¡ paketu
         lodsw                              ; AX<- Po‡et superblok– v paketu
         or   ax,ax                         ; Je nˆjak˜ superblok?
         jnz  ZpPa00
         jmp  ZpPa90                        ; Nen¡ ‘ dn˜ superblok

ZpPa00:  mov  cx,ax                         ; CX<- Po‡et superblok– v paketu
         add  si,8                          ; SI<- Za‡ tek superbloku

; ------ Zpracov n¡ jednoho superbloku
;        dd   D‚lka superbloku v bajtech
;        dw   Typ superbloku
;        ??   Data podle typu superbloku

ZpPa01:  push cx
         push si
         add  si,4                          ; SI<- ^Typ superbloku
         lodsw                              ; AX<- Typ superbloku

; ------------------------------------------------------------------------------
; ------ Superblok palety 0Bh
         cmp  ax,0Bh                        ; Je to superblok palety?
         jne  ZpPa0C00                      ; Nen¡

;        dd   D‚lka superbloku v bajtech
;        dw   Typ superbloku 0Bh = Definice palety
;        dw   1
;        db   Prvn¡ p©edefinovan  barva
;        db   Po‡et barev k p©edefinov n¡ (0 = v¨ech 256)
;        ??   Paleta RGB 3*6 bit–

; ------ P©¡prava po‡¡tadel
         add  si,2                          ; SI<- Prvn¡ p©edefinov van  barva
         lodsw                              ; AX<- Prvn¡ barva, po‡et
         xor  ch,ch
         mov  cl,ah                         ; CX<- Po‡et p©edefinov van˜ch barev
         or   cl,cl                         ; P©evod 0 -> 256
         jne  ZpPa0B01                      ; Nep©edefinovat v¨echny?
         inc  ch                            ; P©edefinovat v¨echny
ZpPa0B01:mov  dx,cx
         shl  cx,1
         add  cx,dx                         ; CX<= CX*3 (3 slo‘ky na barvu)

; ------ Definice palety
         mov  dx,3C8h                       ; DX<- Index palety
         out  dx,al                         ; Prvn¡ p©edefinovan  barva
         inc  dl                            ; DX<- Data palety

;ZpPa0B02:lodsb                              ; Bajt palety
;         shr  al,2                          ; Korekce na 6 bit–
;         out  dx,al
;         loop ZpPa0B02                      ; Zpracov n¡ dal¨¡ slo‘ky
         rep  outsb                         ; Nastaven¡ palety
         jmp  short ZpPa80                  ; Superblok zpracov n

; ------------------------------------------------------------------------------
; ------ Superblok delta - obr zku 0Ch
ZpPa0C00:cmp  ax,0Ch                        ; Je to superblok obr zku 0Ch?
         jne  ZpPa0F00                      ; Nen¡

;        dd   D‚lka superbloku v bajtech
;        dw   Typ superbloku 0Ch = Delta - obr zek
;        dw   Po‡ te‡n¡ linka na obrazovce
;        dw   Po‡et linek
;        ??   ž dek 1
;        ??   ž dek 2
;             ...
;        ??   ž dek N

         push bp
         lodsw                              ; Po‡ te‡n¡ linka na obrazovce
         mul  cs:Trista20                   ; AX<= Za‡ tek ve VRAM
         mov  bp,ax                         ; BX<- Za‡ tek prvn¡ho kreslen‚ho © dku
         lodsw                              ; Po‡et linek
         mov  dx,ax                         ; Po‡¡tadlo linek
         xor  ch,ch                         ; P©¡prava po‡¡tadla opakov n¡
         xor  ah,ah                         ; P©¡prava p©evodn¡ku mezer

; ------ Jeden © dek
;        db   Po‡et blok– na © dku
;        ??   Blok1
;        ??   Blok2
;             ...
;        ??   BlokN
ZpPa0C01:lodsb                              ; Po‡et blok– na © dku
         or   al,al                         ; Nen¡ ‘ dn˜ blok?
         jz   ZpPa0C05
         mov  bl,al                         ; BL = Po‡¡tadlo blok–
         mov  di,bp                         ; DI<- Za‡ tek nov‚ho © dku

; ------ Jeden blok
;        db   Mezera (po‡et bod–, kter‚ nebudou modifikov ny)
;        db   D‚lka:   1..127 -> Po‡et bajt– nekomprimovan˜ch dat
;                    128..255 -> Doplnˆk (0-X) k po‡tu opakov n¡
;                                n sleduj¡c¡ho bajtu
;        ??   Data
ZpPa0C02:lodsb                              ; Mezera
         add  di,ax                         ; P©esko‡en¡ nezpracov van˜ch dat na obrazovce
         lodsb                              ; Po‡et dat
         mov  cl,al                         ; CX<- Po‡et dat
         cmp  al,80h                        ; Budou nekomprimovan  data?
         jb   ZpPa0C03

; ------ Opakuj¡c¡-se barva
         neg  cl                            ; CX<- Po‡et opakov n¡
         lodsb                              ; Opakuj¡c¡-se barva
         rep  stosb                         ; Vykreslen¡ barvy
         jmp  short ZpPa0C04

; ------ Nekomprimovan  data
ZpPa0C03:rep  movsb                         ; P©enos dat

ZpPa0C04:dec  bl                            ; Po‡¡tadlo blok– na © dku
         jnz  ZpPa0C02                      ; Zpracov n¡ dal¨¡ho bloku

ZpPa0C05:add  bp,320                        ; BP<= Za‡ tek dal¨¡ho © dku
         dec  dx                            ; Po‡¡tadlo © dk–
         jnz  ZpPa0C01

         pop  bp
         jmp  short ZpPa80                  ; Superblok zpracov n


; ------------------------------------------------------------------------------
; ------ Superblok celoobrazovkov‚ho obr zku 0Fh
ZpPa0F00:cmp  ax,0Fh                        ; Je to superblok obr zku 0Fh?
         jne  ZpPaErrB                      ; Nen¡

;        dd   D‚lka superbloku v bajtech
;        dw   Typ superbloku 0Fh = Celoobrazovkov˜ obr zek
;        ??   200 © dk– komprimovan˜ch dat

         mov  dx,200                        ; DX = Po‡¡tadlo © dk–
         xor  di,di                         ; DI<- Ukazatel do VRAM
         xor  ch,ch                         ; P©¡prava po‡¡tadla dat


; ------ Jeden © dek
;        db   Po‡et blok– na © dku
;        ??   Blok1
;        ??   Blok2
;             ...
;        ??   BlokN
ZpPa0F01:lodsb                              ; Po‡et blok– na © dku
         mov  ah,al                         ; AH<- Po‡et blok– na © dku


; ------ Jeden blok
;        db   D‚lka:   1..127 -> Po‡et opakov n¡ n sleduj¡c¡ho bajtu
;                    128..255 -> Doplnˆk (0-X) k po‡tu bajt–
;                                nekomprimovan˜ch dat
;        ??   Data
ZpPa0F02:lodsb                              ; Po‡et dat
         mov  cl,al                         ; CX<- po‡et dat
         cmp  al,80h                        ; Bude opakov n¡?
         jb   ZpPa0F03

; ------ Nekomprimovan  data
         neg  cl                            ; CX<- po‡et nekomprimovan˜ch dat
         rep  movsb                         ; P©enos dat
         jmp  short ZpPa0F04

; ------ Opakuj¡c¡-se barva
ZpPa0F03:lodsb                              ; AL<- Opakuj¡c¡-se barva
         rep  stosb                         ; Vykreslen¡ barvy

ZpPa0F04:dec  ah                            ; Po‡¡tadlo blok– na © dku
         jnz  ZpPa0F02                      ; Zpracov n¡ dal¨¡ho bloku

         dec  dx                            ; Po‡¡tadlo © dk–
         jnz  ZpPa0F01
         jmp  short ZpPa80                  ; Superblok zpracov n


; ------------------------------------------------------------------------------
; ------ Nezn m˜ superblok
ZpPaErrB:mov  dx,offset ChNeznSB            ; Chybov‚ hl ¨en¡
         jmp  Chyba01                       ; Chyba


; ------ Jeden superblok byl zpracov n
ZpPa80:  pop  si                            ; SI<- ^Zpracovan˜ superblok
         add  si,[si]                       ; SI<- Dal¨¡ superblok
         pop  cx                            ; Po‡¡tadlo superblok–
         dec  cx
         jz   ZpPa90                        ; U‘ nen¡ ‘ dn˜ superblok?
         jmp  ZpPa01                        ; Zpracuj dal¨¡ superblok

; ------ V¨echny superbloky byly zpracov ny
ZpPa90:



         pop  di
         pop  si
         pop  dx
         pop  cx
         pop  bx
         pop  ax
         ret


; ==============================================================================
; Pauza po vykreslen¡ obrazovky
; ==============================================================================
Pauza:   push ax
         push es

         push 0
         pop  es

         mov  ax,es:[46Ch]
;         add  ax,2
Pa01:    cmp  ax,es:[46Ch]
         je   Pa01

         pop  es
         pop  ax
         ret


; ==============================================================================
; €ek n¡ na zatem¤ovac¡ impuls
; ------------------------------------------------------------------------------
; Ni‡¡:  ax,dx
; ==============================================================================
WaitZat: mov  dx,3DAh
WaZa01:  in   al,dx
         test al,8
         jz   WaZa01
         ret


; ------------------------------------------------------------------------------
; Na‡ten¡ bloku dat do bufferu (co se vejde)
; ------------------------------------------------------------------------------
; Vstup: DS=Segment bufferu
; ------------------------------------------------------------------------------
CtiBuf:  push ax
         push bx
         push cx
         push dx

         mov  ah,3Fh                        ; €ten¡ dat
         mov  bx,cs:Handle                  ; Handle souboru

         mov  dx,cs:KonDatVB                ; Adresa konce dat v bufferu
         cmp  dx,cs:ZacDatVB
         jae  CtBu10

; ------ Konec < Za‡ tek, ‡¡st jen Za‡ tek - Konec - 1
         mov  cx,cs:ZacDatVB
         sub  cx,dx
         dec  cx                            ; CX<= D‚lka ‡ten˜ch dat
         int  21h
         jmp  short CtBu12                  ; Aktualizace promˆnn˜ch atd.
;         mov  dx,offset ChCtSou             ; Chybov‚ hl ¨en¡
;         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby
;         add  cs:KonDatVB,ax                ; Posun konce dat v bufferu
;         cmp  ax,cx                         ; Bylo na‡teno, co mˆlo b˜t?
;         je   CtBu99                        ; Ani, toŸ v¨e
;         mov  cs:KonecSou,1                 ; Ne, to je konec souboru
;         jmp  short CtBu99

; ------ Konec >= Za‡ tek, ‡¡st do konce bufferu a pak od 0 do za‡ tku dat
; ------ €ten¡ ‡ sti do konce bufferu
CTbu10:  mov  cx,dx
         neg  cx                            ; CX<= M¡sto do konce bufferu
         int  21h
         mov  dx,offset ChCtSou             ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby
         add  cs:KonDatVB,ax                ; Posun konce dat v bufferu
         cmp  ax,cx                         ; Bylo na‡teno, co mˆlo b˜t?
         je   CtBu11
         mov  cs:KonecSou,1                 ; Ne, to je konec souboru
         jmp  short CtBu99

; ------ €ten¡ ‡ sti do za‡ tku dat v bufferu
CtBu11:  mov  ah,3Fh                        ; €ten¡ dat
         mov  cx,cs:ZacDatVB
         dec  cx
         xor  dx,dx
         int  21h
CtBu12:  mov  dx,offset ChCtSou             ; Chybov‚ hl ¨en¡
         call Chyba                         ; O¨et©en¡ p©¡padn‚ chyby
         add  cs:KonDatVB,ax                ; Posun konce dat v bufferu
         cmp  ax,cx                         ; Bylo na‡teno, co mˆlo b˜t?
         je   CtBu99                        ; Ano, toŸ v¨e
         mov  cs:KonecSou,1                 ; Ne, to je konec souboru

CtBu99:  pop  dx
         pop  cx
         pop  bx
         pop  ax
         ret


; ==============================================================================
; O¨et©en¡ chyb, hl ¨en¡ na CS:DX
; ==============================================================================
ChybaB:
ChybaC:
Chyba:   jc   Chyba01
         ret
ChybaAE:
ChybaNB:
ChybaNC: jnc  Chyba01
         ret
ChybaZ:
ChybaE:  jz   Chyba01
         ret
ChybaNZ:
ChybaNE: jnz  Chyba01
         ret

Chyba01: push cs
         pop  ds

; ------ Nastaven¡ p–vodn¡ho videom¢du
         mov  al,OldVMod
         xor  ah,ah
         int  10h

; ------ V˜pis chybov‚ho hl ¨en¡
         mov  ah,9
         int  21h
         mov  ah,9
         mov  dx,offset ChybaT9
         int  21h

; ------ Uzav©en¡ souboru
         cmp  Handle,0                      ; Byl ji‘ soubor otev©en
         je   Chyba89                       ; Nebyl, net©eba zav¡rat
         mov  ah,3Eh                        ; Zav©en¡ souboru
         mov  bx,Handle
         int  21h

; ------ Uvolnˆn¡ alokovan‚ pamˆti
Chyba89: cmp  RBuf,0                        ; Byl ji‘ buffer alokov n
         je   Chyba99                       ; Nebyl, net©eba uvol¤ovat
         mov  ah,49h                        ; Uvolnˆn¡ pamˆti
         mov  es,RBuf
         int  21h

; ------ Konec s chyb. k¢dem = 2
Chyba99: mov  ax,4C02h
         int  21h

OldVMod  db   3                             ; P–vodn¡ videom¢d


; ------ Chybov  hl ¨en¡
ChybaT9  db   '!',13,10,7,'$'
ChConfig db   'Program pot©ebuje k ‡innosti procesor 80286 nebo vy¨¨¡ a grafickou kartu VGA$'
ChPrPam  db   'Chyba MEM:SETBLK$'
ChNePam  db   'Nedostatek pamˆti$'
ChSouNen db   'Soubor FLI nenalezen$'
ChCtSou  db   'Chyba ‡ten¡ FLI souboru$'
ChNeFLI  db   'Soubor nen¡ form tu FLI 320x200/256$'
ChSeekSo db   'Chyba nastaven¡ pozice v souboru$'
ChPoskSo db   'D‚lka souboru nesouhlas¡ - patrnˆ je po¨kozen, nebo nen¡ FLI$'

ChDlPakt db   'Paket p©esahuje 64kB$'
ChFLIPak db   'Paket nen¡ FLI$'
ChNeznSB db   'Nezn m˜ typ superbloku$'

Trista20 dw   320                           ; Konstanta - ¨¡©ka obrazovky

RBuf     dw   0                             ; Segment ‡tec¡ho bufferu

JmSou    db   'CITY.FLI',0
Handle   dw   0                             ; Handle souboru

Rychlost dw   0                             ; Rychlost p©ehr v n¡ souboru
PocObrVS dw   0                             ; Po‡et obr zk– v souboru
AktObrVS dw   0                             ; Aktu ln¡ obr zek v souboru

ZacDatVB dw   0                             ; Offset za‡ tku dat v bufferu
KonDatVB dw   0                             ; Offset konce dat v bufferu
KonecSou db   0

; ------ Z sobn¡k
         even
Zasob    db   512 dup (0)                   ; Z sobn¡k
KonZasob label word


KonPrg:                                     ; N vˆ¨t¡ konce programu

code     ends
         end  start

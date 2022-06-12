
bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

GLOBAL   SCR                                ; obr zky
TOPSCR   EQU       offset SCR + 16 + 3*256  ; po‡ tek obr zk– objekt–

HI       EQU       100h

; ------ pozice na obrazovce

OBZOR    EQU       66                       ; po‡et linek na obzor (obloha+poho©¡)

MAXOBJ   EQU       300                       ; maxim ln¡ po‡et objekt–
MAXFAZE  EQU       20                       ; maxim ln¡ po‡et f z¡ objektu

; ------ barvy

OBLOHA   EQU       11                       ; obloha

; ------ popisova‡ objektu

ObjStruc STRUC

ObjTyp   db        ?                        ; typ objektu
                                            ;     0 = nic
                                            ;     1 = raketa
                                            ;     2 = disk
                                            ;     3 =
                                            ;     4 = velk‚ UFO
                                            ;     5 = st©ela
                                            ;     6 = kosmick  loƒ
                                            ;     7 =
                                            ;     8 =
                                            ;     9 =
ObjX     dw        ?                        ; sou©adnice objektu X
ObjY     dw        ?                        ; sou©adnice objektu Y
ObjFaze  db        ?                        ; velikost objektu (f ze)
ObjDX    dw        ?                        ; p©¡rustek sou©adnice X
ObjDY    dw        ?                        ; p©¡rustek sou©adnice Y
ObjPar   db        ?                        ; parametry objektu
                                            ;    bit 3: 1=smˆr pohybu vlevo
                                            ;    bit 7: 1=objekt obslou‘en
ObjPohyb dw        ?                        ; ukazatel pohybu objektu (0=nen¡)
ObjStack dw        ?                        ; £schova adresy pro podprogram

ObjStruc ENDS

ObjSumm  EQU       size ObjStruc            ; velikost jedn‚ polo‘ky


Code     SEGMENT
         ASSUME    cs:Code,ds:Data
         ORG       0

; ------ inicializace registr–

Start:   mov       ax,SEG Data
         mov       ds,ax                    ; DS <- datov˜ segment

; ------ £schova aktivn¡ho videom¢du

         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         mov       ds:[OldVMod],al          ; £schova videom¢du

; ------ instalace programu (obsluhy p©eru¨en¡)

         call      Instal                   ; instalace obsluh p©eru¨en¡

; ------ inicializace videom¢du

         call      InitVMod                 ; inicializace videom¢du

; ------ inicializace ukazatel–

         call      SoundOff                 ; vypnut¡ zvukov‚ho gener toru




; ------ inicializace nov‚ hry

Start2:  call      InitHra                  ; inicializace nov‚ hry
         call      Clear                    ; vymaz n¡ videopamˆti




; ------ inicializace nov‚ho sektoru

Start3:  call      InitSekt                 ; inicializace nov‚ho sektoru

         call      Clear                    ; vymaz n¡ videopamˆti
         call      DispPoz                  ; zobrazen¡ pozad¡ sc‚ny
         call      DispZiv                  ; zobrazen¡ po‡tu ‘ivot–
         call      DispPal                  ; zobrazen¡ zbyl‚ho paliva

         mov       ax,6 + 5*HI
         mov       dx,20
         mov       bx,10
         mov       cl,1                     ; pohyb - lev˜ sloup
;         call      CreatObj

;         mov       ax,6 + 2*HI
;         mov       bx,50
;         mov       dx,50
;         call      CreatObj
;         mov       ax,6 + 3*HI
;         mov       bx,30
;         mov       dx,110
;         call      CreatObj
;         mov       ax,6 + 4*HI
;         mov       bx,10
;         mov       dx,130
;         call      CreatObj
;         mov       ax,6 + 5*HI
;         mov       bx,0
;         mov       dx,160
;         call      CreatObj


; ------ synchronizace
;þ
Start6:  call      WaitTim                  ; ‡ek n¡ na impuls hodin
         mov       dx,ds:[PortCRT]
Start61: sti
         in        al,dx
         test      al,bit3
         jz        Start61                  ; ‡ek n¡ na vertik ln¡ zpˆtn˜ bˆh

; ------ vymaz n¡ star˜ch obr zk–

         call      MazLet                   ; vymaz n¡ obr zku letadla
         call      MazObj                   ; vymaz n¡ v¨ech objekt–

; ------ posun a zobrazen¡ zemˆ

         call      PosunZem                 ; obsluha pohybu zemˆ

; ------ zobrazen¡ nov˜ch obr zk–

         call      PosunObj                 ; obsluha pohybu objekt–
         call      PosunLet                 ; obsluha pohybu letadla
         call      GenStrel                 ; generov n¡ st©el


         call      DispObj                  ; zobrazen¡ v¨ech objekt–

         call      PlaySnd                  ; obsluha hry melodie

; ------ test, zda je p©eru¨en¡ hry ESC

         test      byte ptr ds:[Keys],bit7  ; je ESC ?
         jnz       Start9                   ; p©eru¨en¡ ESC
         jmp       Start6                   ; nen¡ p©eru¨en¡
Start9:

; ------ odinstalov n¡ programu

Int23:   call      DInstal                  ; odinstalov n¡ programu

; ------ n vrat videom¢du (a vymaz n¡ obrazovky)

         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du

; ------ vypnut¡ zvukov‚ho gener toru

         call      SoundOff                 ; vypnut¡ zvukov‚ho gener toru

; ------ n vrat z programu

         mov       ax,4c00h
         int       21h

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                          Obsluha zobrazen¡ ‡ st¡
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        generov n¡ nov‚ st©ely
; -----------------------------------------------------------------------------

GenStrel PROC      NEAR

; ------ test, zda m–‘e b˜t nov  st©ela

         test      byte ptr ds:[Keys],bit4+bit5+bit6 ; je st©¡len¡ ?
         jnz       GenStrl1                 ; je st©¡len¡
         mov       byte ptr ds:[DelStrel],0 ; ‡¡ta‡ prodlevy mezi st©elami
         ret

GenStrl1:cmp       byte ptr ds:[DelStrel],0 ; je dal¨¡ st©ela ?
         je        GenStrl2                 ; m–‘e b˜t dal¨¡ st©ela
         dec       byte ptr ds:[DelStrel]   ; ‡¡ta‡ generov n¡ st©el
         ret

GenStrl2:mov       byte ptr ds:[DelStrel],2 ; nastaven¡ ‡¡ta‡e st©el

; ------ vytvo©en¡ objektu st©ely

         mov       ax,5 + 5*HI              ; ‡¡slo objektu - st©ela
         mov       dx,ds:[RaketaX]          ; sou©adnice rakety X
         add       dx,32-46/2               ; pozice X st©ely = st©ed rakety
         mov       bx,ds:[RaketaY]          ; sou©adnice rakety Y
         add       bx,5
         mov       cl,0                     ; pohyb st©ely
         call      CreatObj                 ; vytvo©en¡ objektu st©ely
         jc        GenStrl8
         mov       word ptr ds:[si+ObjDX],200 ; p©¡rustek sou©adnice X

; ------ zvukov  indikace st©ely

GenStrl8:mov       al,1                     ; ‡¡slo melodie - st©¡len¡
         call      InitSnd                  ; inicializace zvuku
         ret

GenStrel ENDP

; -----------------------------------------------------------------------------
;        vytvo©en¡ objektu AL (f ze AH), linka BX, pozice DX, pohyb CL -> DS:SI (CY=nen¡ m¡sto)
; -----------------------------------------------------------------------------

CreatObj PROC      NEAR

; ------ nalezen¡ voln‚ho popisova‡e objekt–

         mov       si,offset TabObj-ObjSumm ; tabulka objekt–
CreatOb2:add       si,ObjSumm               ; adresa dal¨¡ polo‘ky
         cmp       si,offset TabObj0        ; je ji‘ konec tabulky ?
         cmc
         jc        CreatOb9                 ; je konec tabulky
         cmp       byte ptr ds:[si+ObjTyp],0 ; je polo‘ka voln  ?
         jne       CreatOb2                 ; nalezen¡ voln‚ polo‘ky

; ------ ulo‘en¡ parametr– objektu

         mov       ds:[si+ObjTyp],al        ; typ objektu
         mov       ds:[si+ObjFaze],ah
         mov       byte ptr ds:[si+ObjPar],0 ; parametry objektu
         mov       ds:[si+ObjX],dx          ; sou©adnice objektu X
         mov       word ptr ds:[si+ObjDX],0 ; p©¡rustek sou©adnice X
         mov       ds:[si+ObjY],bx          ; sou©adnice objektu Y
         mov       word ptr ds:[si+ObjDY],0 ; p©¡rustek sou©adnice Y

         push      bx
         mov       bl,cl                    ; BL <- ‡¡slo pohybu
         mov       bh,0
         shl       bx,1
         mov       bx,ds:[bx+AdrPohyb]      ; adresa pohybu
         mov       ds:[si+ObjPohyb],bx      ; adresa pohybu objektu
         pop       bx
         clc                                ; p©¡znak operace OK
CreatOb9:ret

CreatObj ENDP

; -----------------------------------------------------------------------------
;        obsluha pohybu letadla
; -----------------------------------------------------------------------------

PosunLet PROC      NEAR

; ------ posun vlevo

         mov       ax,ds:[RaketaX]          ; poloha rakety X
         test      byte ptr ds:[Keys],bit0  ; vlevo
         jz        PosunLt4
         sub       ax,8                     ; sn¡‘en¡ polohy rakety X
         cmp       ax,-2
         jge       PosunLt4                 ; pozice je OK
         mov       ax,-2                    ; omezen¡ minim ln¡ pozice

; ------ posun vpravo

PosunLt4:test      byte ptr ds:[Keys],bit1  ; vpravo
         jz        PosunLt5
         add       ax,8                     ; zv˜¨en¡ polohy rakety X
         cmp       ax,320-64                ; maxim ln¡ pozice
         jbe       PosunLt5                 ; pozice je OK
         mov       ax,320-64                ; omezen¡ pozice X
PosunLt5:mov       ds:[RaketaX],ax          ; nov  pozice X

; ------ nahoru = zv˜¨en¡ v˜¨ky, zrychlen¡ letu

         test      byte ptr ds:[Keys],bit2  ; nahoru
         jz        PosunLt6                 ; nen¡ nahoru
         mov       ax,ds:[RaketaY]          ; v˜¨ka Y
         dec       ax
         dec       ax                       ; posun nahoru
         cmp       al,56                    ; maxim ln¡ v˜¨ka
         jb        PosnLt54                 ; je ji‘ maxim ln¡ v˜¨ka
         mov       ds:[RaketaY],ax          ; nov  v˜¨ka
         jmp       short PosunLt6

PosnLt54:mov       ax,ds:[Rychlost]         ; aktu ln¡ rychlost letu
         inc       ax                       ; zv˜¨en¡ rychlosti
         cmp       ax,100                   ; maxim ln¡ rychlost
         jbe       PosnLt56                 ; rychlost je OK
         mov       ax,100                   ; omezen¡ rychlosti
PosnLt56:mov       ds:[Rychlost],ax         ; nov  rychlost

; ------ dol– = sn¡‘en¡ v˜¨ky, zpomalen¡ letu

PosunLt6:test      byte ptr ds:[Keys],bit3  ; dol–
         jz        PosunLt7                 ; nen¡ dol–

         mov       ax,ds:[RaketaY]          ; v˜¨ka Y
         inc       ax
         inc       ax                       ; posun dol–
         cmp       al,96                    ; maxim ln¡ v˜¨ka
         jae       PosnLt64                 ; je ji‘ minim ln¡ v˜¨ka
         mov       ds:[RaketaY],ax          ; nov  v˜¨ka
         jmp       short PosunLt7

PosnLt64:mov       ax,ds:[Rychlost]         ; aktu ln¡ rychlost letu
         dec       ax                       ; sn¡‘en¡ rychlosti
         cmp       ax,10                    ; minim ln¡ rychlost
         jae       PosnLt66
         mov       ax,10                    ; omezen¡ rychlosti
PosnLt66:mov       ds:[Rychlost],ax         ; nov  rychlost

; ------ zobrazen¡ letadla na nov‚ pozici

PosunLt7:call      DispLet                  ; zobrazen¡ letadla
         ret

PosunLet ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ letadla
; -----------------------------------------------------------------------------

DispLet  PROC      NEAR

; ------ zobrazen¡ st¡nu

         test      byte ptr ds:[ParamS],bit0 ; je zobrazena zemˆ ?
         jz        DispLet2                 ; nen¡ zobrazena zemˆ
         mov       dx,ds:[RaketaX]          ; poloha letadla X
         mov       bx,116                   ; poloha k zobrazen¡ st¡nu
         mov       ax,1 + 4*HI              ; objekt = raketa, f ze = st¡n
         call      DispObr                  ; zobrazen¡ obr zku

; ------ zobrazen¡ letadla

DispLet2:mov       ax,1 + 3*HI              ; letadlo vlevo
         test      byte ptr ds:[Keys],bit0  ; vlevo ?
         jnz       DispLet6                 ; vlevo
         mov       ah,2                     ; vpravo
         test      byte ptr ds:[Keys],bit1  ; vpravo ?
         jnz       DispLet6                 ; vpravo

         test      byte ptr ds:[Keys],bit2  ; nahoru ?
         jz        DispLet3                 ; nen¡ nahoru
         cmp       word ptr ds:[Rychlost],100 ; je maxim ln¡ rychlost ?
         jae       DispLet5
         mov       ah,0                     ; nahoru
         jmp       short DispLet6

DispLet3:test      byte ptr ds:[Keys],bit3  ; dol– ?
         jz        DispLet5                 ; nen¡ dol–
         cmp       word ptr ds:[Rychlost],10 ; minim ln¡ rychlost
         jbe       DispLet5                 ; je minim ln¡ rychlost
         mov       ah,1                     ; dol–
         jmp       short DispLet6

DispLet5:xor       bx,bx
         mov       es,bx
         mov       ah,1                     ; dol–
         test      byte ptr es:[46ch],bit0  ; asi tak 8 x za sekundu
         jz        DispLet6
         mov       ah,0                     ; nahoru

DispLet6:mov       bx,ds:[RaketaY]          ; poloha letadla Y
         mov       dx,ds:[RaketaX]          ; poloha letadla X
         call      DispObr                  ; zobrazen¡ obr zku
         ret

DispLet  ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ letadla
; -----------------------------------------------------------------------------

MazLet   PROC      NEAR

; ------ vymaz n¡ st¡nu

         test      byte ptr ds:[ParamS],bit0 ; je zobrazena zemˆ ?
         jz        MazLet4                  ; nen¡ zobrazena zemˆ
         mov       dx,ds:[RaketaX]          ; poloha letadla X
         mov       bx,116                   ; poloha k zobrazen¡ st¡nu
         mov       ax,1 + 4*HI              ; objekt = raketa, f ze = st¡n
         call      MazObr                   ; vymaz n¡ obr zku

; ------ vymaz n¡ letadla

MazLet4: mov       bx,ds:[RaketaY]          ; poloha letadla Y
         mov       dx,ds:[RaketaX]          ; poloha letadla X
         mov       ax,1 + 0*HI              ; objekt = raketa nahoru
         call      MazObr                   ; vymaz n¡ obr zku
         ret

MazLet   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu AL, f ze AH, linka BX, pozice DX
; -----------------------------------------------------------------------------

DispObr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         add       bx,OBZOR                 ; posun ‡¡sla linky

; ------ rozmˆry a adresa obr zku -> CX, SI

         push      ax
         mov       ah,0
         shl       ax,1                     ; objekt * 2
         xchg      ax,si                    ; SI <- offset v tabulce objekt–
         mov       si,ds:[si+DefObr-2]      ; adresa definice objektu
         pop       ax
         mov       al,ah                    ; AL <- ‡¡slo f ze
         mov       ah,0
         shl       ax,1
         shl       ax,1                     ; f ze * 4
         add       si,ax                    ; adresa definice objektu
         mov       cx,ds:[si]               ; ¨¡©ka a v˜¨ka obr zku
         mov       si,ds:[si+2]             ; adresa obr zku

; ------ omezen¡ v˜¨ky obr zku

         mov       ax,200                   ; maxim ln¡ linka
         sub       ax,bx                    ; zbyl˜ po‡et linek
         jbe       DispObr9                 ; neplatn‚ ‡¡slo linky
         cmp       al,ch                    ; je v˜¨ka OK ?
         jae       DispObr1                 ; v˜¨ka je OK
         mov       ch,al                    ; omezen¡ v˜¨ky obr zku

; ------ kontrola ¨¡©ky obr zku

DispObr1:mov       ax,320                   ; maxim ln¡ pozice
         sub       ax,dx                    ; zbyl˜ po‡et pozic
         jle       DispObr9                 ; neplatn  pozice
         or        ah,ah
         jnz       DispObr2                 ; zb˜v  dost m¡sta
         cmp       al,cl                    ; kontrola maxim ln¡ ¨¡©ky
         jae       DispObr2                 ; zb˜v  dost m¡sta
         mov       cl,al                    ; omezen¡ ¨¡©ky obr zku

; ------ korekce p©i podte‡en¡ po‡ tku vlevo

DispObr2:or        dx,dx                    ; je podte‡en¡ ?
         jns       DispObr3                 ; nen¡ podte‡en¡
         neg       dx                       ; posun po‡ tku
         add       si,dx                    ; korekce po‡ te‡n¡ adresy
         or        dh,dh
         jnz       DispObr9                 ; je p©¡li¨ vlevo
         sub       cl,dl                    ; sn¡‘en¡ ¨¡©ky o korekci
         jbe       DispObr9                 ; nic nezbylo
         xor       dx,dx                    ; nebude posun

; ------ adresa ve videopamˆti -> ES:DI

DispObr3:shl       bx,1
         mov       di,ds:[bx+AdrVLine]      ; adresa ve videopamˆti
         mov       es,ds:[SegmVRam]         ; segment videopamˆti
         mov       ax,SEG SCR
         mov       ds,ax
         add       di,dx                    ; p©i‡ten¡ pozice

; ------ zobrazen¡ obr zku

         cld
DispObr4:push      cx
         push      si
         push      di
         mov       ch,0
DispObr5:lodsb                              ; bajt k zobrazen¡
         or        al,al                    ; je ‡ern  ?
         jz        DispObr6                 ; nen¡ ‡ern 
         stosb                              ; ulo‘en¡ bodu
         dec       di
DispObr6:inc       di
         loop      DispObr5                 ; dal¨¡ bod
         pop       di
         pop       si
         pop       cx
         add       si,320                   ; posun adresy obr zku
         add       di,320                   ; posun ukl dac¡ adresy
         dec       ch                       ; ‡¡ta‡ linek
         jnz       DispObr4                 ; zobrazen¡ dal¨¡ linky

; ------ n vrat registr–

DispObr9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispObr  ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ objektu AL, f ze AH, linka BX, pozice DX
; -----------------------------------------------------------------------------

MazObr   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         add       bx,OBZOR                 ; posun ‡¡sla linky

; ------ rozmˆry obr zku -> CX

         push      ax
         mov       ah,0
         shl       ax,1                     ; objekt * 2
         xchg      ax,si                    ; SI <- offset v tabulce objekt–
         mov       si,ds:[si+DefObr-2]      ; adresa definice objektu
         pop       ax
         mov       al,ah                    ; AL <- ‡¡slo f ze
         mov       ah,0
         shl       ax,1
         shl       ax,1                     ; f ze * 4
         add       si,ax                    ; adresa definice objektu
         mov       cx,ds:[si]               ; ¨¡©ka a v˜¨ka obr zku

; ------ omezen¡ v˜¨ky obr zku

         mov       ax,200                   ; maxim ln¡ linka
         sub       ax,bx                    ; zbyl˜ po‡et linek
         jbe       MazObr9                  ; neplatn‚ ‡¡slo linky
         cmp       al,ch                    ; je v˜¨ka OK ?
         jae       MazObr1                  ; v˜¨ka je OK
         mov       ch,al                    ; omezen¡ v˜¨ky obr zku

; ------ kontrola ¨¡©ky obr zku

MazObr1: mov       ax,320                   ; maxim ln¡ pozice
         sub       ax,dx                    ; zbyl˜ po‡et pozic
         jle       MazObr9                  ; neplatn  pozice
         or        ah,ah
         jnz       MazObr2                  ; zb˜v  dost m¡sta
         cmp       al,cl                    ; kontrola maxim ln¡ ¨¡©ky
         jae       MazObr2                  ; zb˜v  dost m¡sta
         mov       cl,al                    ; omezen¡ ¨¡©ky obr zku

; ------ korekce p©i podte‡en¡ po‡ tku vlevo

MazObr2: or        dx,dx                    ; je podte‡en¡ ?
         jns       MazObr3                  ; nen¡ podte‡en¡
         neg       dx                       ; posun po‡ tku
         or        dh,dh
         jnz       MazObr9                  ; je p©¡li¨ vlevo
         sub       cl,dl                    ; sn¡‘en¡ ¨¡©ky o korekci
         jbe       MazObr9                  ; nic nezbylo
         xor       dx,dx                    ; nebude posun

; ------ adresa ve videopamˆti -> ES:DI

MazObr3: shl       bx,1
         mov       di,ds:[bx+AdrVLine]      ; adresa ve videopamˆti
         mov       es,ds:[SegmVRam]         ; segment videopamˆti
         add       di,dx                    ; p©i‡ten¡ pozice

; ------ vymaz n¡ obr zku

         cld
MazObr4: push      cx
         push      di
         mov       ch,0
         mov       ax,ds:[bx+VzorZem-2*OBZOR] ; vzorek
         inc       bx
         inc       bx
         shr       cx,1
         rep       stosw                    ; vymaz n¡ linky
         adc       cx,cx
         rep       stosb
         pop       di
         pop       cx
         add       di,320                   ; posun ukl dac¡ adresy
         dec       ch                       ; ‡¡ta‡ linek
         jnz       MazObr4                  ; vymaz n¡ dal¨¡ linky

; ------ n vrat registr–

MazObr9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MazObr   ENDP

; -----------------------------------------------------------------------------
;        obsluha pohybu objekt–
; -----------------------------------------------------------------------------
;þ
PosunObj PROC      NEAR

; ------ test, zda je objekt platn˜

         mov       si,offset TabObj         ; tabulka objekt–
         mov       cx,MAXOBJ                ; max. po‡et objekt–
PosunOb2:mov       al,ds:[si+ObjTyp]        ; typ objektu
         cmp       al,0                     ; je objekt platn˜ ?
         je        PosunOb9                 ; objekt nen¡ platn˜

; ------ ‡ek n¡ na pohyb ve smˆru Y

PosunOb3:cmp       word ptr ds:[si+ObjDY],0 ; je pohyb ve smˆru Y ?
         jne       PosunOb4                 ; je pohyb ve smˆru Y
         push      si
         push      cx
         call      Pohyb                    ; pohyb objektu DS:SI
         pop       cx
         pop       si
         jmp       short PosunOb2           ; dal¨¡ pohyb

; ------ stanoven¡ rychlosti pohybu -> BX

PosunOb4:mov       ax,9
         sub       al,ds:[si+ObjFaze]       ; zbyl˜ po‡et f z¡
         mul       word ptr ds:[Rychlost]   ; * rychlost letu
         shl       ax,1                     ; rychlost pohybu
         xchg      ax,bx                    ; BX <- rychlost pohybu







; ------ p©¡prava pro dal¨¡ objekt

PosunOb9:add       si,ObjSumm               ; adresa dal¨¡ho objektu
         loop      PosunOb2
         ret

PosunObj ENDP

; -----------------------------------------------------------------------------
;        posun objektu v jednom smˆru
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
;        pohyb objektu DS:SI (neuchov v  registry)
; -----------------------------------------------------------------------------
; bit 7 = 0: zmˆna sou©adnic
;                            bit 0 a‘ bit 6 = p©¡rustek sou©adnice Y
;     n sleduje stavov˜ bajt pro X a velikost:
;                            bit 0: 1=zv˜¨en¡ p©¡rustku X; 0=sn¡‘en¡ p©¡rustku X
;                            bit 1: 1=zv˜¨en¡ f ze objektu; 0=sn¡‘en¡ f ze objektu
;                            bit 2: 1=smˆr posunu Y dol–, 0=smˆr nahoru
;                            bit 3: 1=smˆr posunu X vpravo, 0=smˆr vlevo
;                            bit 4: 1=zmˆna p©¡rustku sou©adnice X
;                            bit 5: 1=zmˆna f ze objektu
;                            bit 6: 1=m  b˜t posun ve smˆru Y (smˆr bit 2)
;                            bit 7: 1=m  b˜t posun ve smˆru X (smˆr bit 3)
; bit 7 = 1: ©¡dic¡ povel
;            bit 0 a‘ bit 6 = povel:
;                  0 = nastaven¡ nov‚ho offsetu ukazatele akc¡ (n sleduje slovo offsetu)
;                  1 = nastaven¡ typu objektu (n sleduje bajt typu objektu)
;                  2 = konec pohybu
;                  3 = vol n¡ podprogramu (£schova ukazatele, n sleduje slovo)
;                  4 = n vrat z podprogramu (n vrat ukazatele)
;                  5 = nastaven¡ p©¡rustku sou©adnice X (n sleduje bajt p©¡rustku X)
;                  6 = test proletˆn¡ rakety branou
;                  7 = generov n¡ nov‚ho pohybu objektu 17 nebo 18
; -----------------------------------------------------------------------------

Pohyb    PROC      NEAR

; ------ test, zda je platn  adresa

Pohyb0:  cmp       word ptr ds:[si+ObjPohyb],0 ; je pohyb ?
         jne       Pohyb1                   ; je pohyb OK
         ret                                ; nen¡ pohyb

; ------ prvn¡ bajt pohybu

Pohyb1:  call      PohybChr                 ; na‡ten¡ bajtu pohybu

; ------ obsluha funkce

         test      al,bit7                  ; je funkce ?
         jz        Pohyb2                   ; nen¡ funkce
         and       al,not bit7              ; nulov n¡ p©¡znaku
         cmp       al,7
         ja        Pohyb1                   ; chyba
         mov       ah,0
         shl       ax,1
         xchg      ax,bx                    ; BX <- offset v tabulce skok–
         call      word ptr cs:[PohybT+bx]  ; skok na obsluhu funkce
         jmp       short Pohyb0

; ------ p©¡rustek sou©adnice Y

Pohyb2:  mov       ah,0
         mov       ds:[si+ObjDY],ax         ; p©¡rustek sou©adnice Y

; ------ na‡ten¡ p©¡znakov‚ho bajtu objektu

         call      PohybChr                 ; na‡ten¡ p©¡znak–

; ------ zmˆna f ze objektu

         test      al,bit5                  ; je zmˆna f ze objektu ?
         jz        Pohyb4                   ; nen¡ zmˆna f ze objektu
         test      al,bit1                  ; je zv˜¨en¡ f ze objektu ?
         jz        Pohyb3                   ; nen¡ zv˜¨en¡ f ze objektu
         inc       byte ptr ds:[si+ObjFaze] ; zv˜¨en¡ f ze objektu
         cmp       byte ptr ds:[si+ObjFaze],10 ; je p©ekro‡en¡ max. f ze ?
         jb        Pohyb4                   ; f ze je OK
Pohyb3:  dec       byte ptr ds:[si+ObjFaze] ; sn¡‘en¡ f ze objektu
         jns       Pohyb4                   ; f ze je OK
         inc       byte ptr ds:[si+ObjFaze] ; minim ln¡ ‡¡slo f ze

; ------ zmˆna p©¡rustku X

Pohyb4:  test      al,bit4                  ; je zmˆna p©¡rustku sou©adnice X ?
         jz        Pohyb9                   ; nen¡ zmˆna p©¡rustku sou©adnice X
         test      al,bit0                  ; je zv˜¨en¡ p©¡rustku X ?
         jz        Pohyb5                   ; nen¡ zv˜¨en¡
         add       word ptr ds:[si+ObjDX],10 ; zv˜¨en¡ p©¡rustku X
         jmp       short Pohyb9
Pohyb5:  sub       word ptr ds:[si+ObjDX],10 ; sn¡‘en¡ p©¡rustku X
Pohyb9:  ret

Pohyb    ENDP

; ------ na‡ten¡ dal¨¡ho bajtu pohybu objektu DS:SI -> AL

PohybChr:push      bx
         mov       bx,ds:[si+ObjPohyb]      ; ukazatel pohybu
         mov       al,ds:[bx]               ; na‡ten¡ bajtu
         inc       word ptr ds:[si+ObjPohyb] ; zv˜¨en¡ ukazatele pohybu
         pop       bx
         ret

; ------ tabulka obsluh funkc¡

PohybT   label     word
         dw        PohTJmp                  ; 0: skok na adresu
         dw        PohTTyp                  ; 1: nastaven¡ typu objektu
         dw        PohTEnd                  ; 2: konec pohybu
         dw        PohTCal                  ; 3: vol n¡ podprogramu
         dw        PohTRet                  ; 4: n vrat z podprogramu
         dw        PohTDX                   ; 5: nastaven¡ p©¡rustku X
         dw        PohTBra                  ; 6: test proletˆn¡ branou
         dw        PohTNew                  ; 7: generov n¡ nov‚ho objektu

; ------ 3: vol n¡ podprogramu (n sleduje skok !)

PohTCal: mov       ax,ds:[si+ObjPohyb]      ; aktu ln¡ ukazatel pohyb–
         inc       ax
         inc       ax                       ; p©esko‡en¡ adresy skoku
         mov       ds:[si+ObjStack],ax      ; £schova ukazatele pohybu
                                          ;* n sleduje skok na adresu !!!
; ------ 0: skok na adresu

PohTJmp: call      PohybChr                 ; na‡ten¡ adresy LOW
         mov       al,ah
         call      PohybChr                 ; na‡ten¡ adresy HIGH
         xchg      al,ah                    ; AL <- LOW, AH <- HIGH
         mov       ds:[si+ObjPohyb],ax      ; nov˜ ukazatel pohyb–
         ret

; ------ 1: nastaven¡ typu objektu

PohTTyp: call      PohybChr                 ; na‡ten¡ typu objektu
         mov       ds:[si+ObjTyp],al        ; nov˜ typ objektu
         ret

; ------ 2: konec pohybu

PohTEnd: mov       byte ptr ds:[si+ObjTyp],0 ; p©¡znak zru¨en¡ objektu
         mov       word ptr ds:[si+ObjPohyb],0 ; zru¨en¡ ukazatele pohybu
         ret

; ------ 4: n vrat z podprogramu

PohTRet: mov       ax,ds:[si+ObjStack]      ; uschovan˜ ukazatel
         mov       ds:[si+ObjPohyb],ax      ; n vrat ukazatele
         ret

; ------ 5: nastaven¡ p©¡rustku X

PohTDX:  call      PohybChr                 ; na‡ten¡ p©¡rustku X
         mov       ah,0
         shl       ax,1
         mov       ds:[si+ObjDX],ax         ; p©¡rustek sou©adnice X
         ret

; ------ 6: test proletˆn¡ branou

PohTBra:

         ret

; ------ 7: generov n¡ nov‚ho objektu 17 nebo 18

PohTNew:

         mov       al,17
         call      CreatObj
         ret


; -----------------------------------------------------------------------------
;        vymaz n¡ v¨ech objekt–
; -----------------------------------------------------------------------------

MazObj   PROC      NEAR

         mov       si,offset TabObj         ; tabulka objekt–
         mov       cx,MAXOBJ                ; max. po‡et objekt–
MazObj2: mov       al,ds:[si+ObjTyp]        ; typ objektu
         cmp       al,0                     ; je platn˜ objekt ?
         je        MazObj3                  ; nen¡ platn˜ objekt
         mov       ah,ds:[si+ObjFaze]       ; f ze objektu
         mov       bx,ds:[si+ObjY]          ; linka
         mov       dx,ds:[si+ObjX]          ; pozice
         call      MazObr                   ; vymaz n¡ obr zku

MazObj3: add       si,ObjSumm               ; adresa dal¨¡ho objektu
         loop      MazObj2
         ret

MazObj   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ v¨ech objekt–
; -----------------------------------------------------------------------------

DispObj  PROC      NEAR

         mov       si,offset TabObj         ; tabulka objekt–
         mov       cx,MAXOBJ                ; max. po‡et objekt–
DispObj2:mov       al,ds:[si+ObjTyp]        ; typ objektu
         cmp       al,0                     ; je platn˜ objekt ?
         je        DispObj3                 ; nen¡ platn˜ objekt
         mov       ah,ds:[si+ObjFaze]       ; f ze objektu
         mov       bx,ds:[si+ObjY]          ; linka
         mov       dx,ds:[si+ObjX]          ; pozice
         call      DispObr                  ; zobrazen¡ obr zku

DispObj3:add       si,ObjSumm               ; adresa dal¨¡ho objektu
         loop      DispObj2
         ret

DispObj  ENDP

; -----------------------------------------------------------------------------
;        obsluha posunu zemˆ
; -----------------------------------------------------------------------------

PosunZem PROC      NEAR

; ------ test, zda se zemˆ zobraz¡

         test      byte ptr ds:[ParamS],bit0 ; zobraz¡ se pozad¡ sc‚ny ?
         jnz       PosunZm1                 ; zobraz¡ se pozad¡ sc‚ny
         ret

; ------ definice naposledy zobrazen‚ f ze linek

PosunZm1:mov       ax,ds:[FazeZem]          ; posledn¡ f ze zemˆ
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; f ze * 8
         add       ax,offset LinkyZem       ; tabulka ‡¡sel linek
         xchg      ax,si                    ; SI <- adresa definice linek

; ------ vymaz n¡ star˜ch linek

         mov       cx,8                     ; po‡et linek
PosunZm2:cld
         lodsb                              ; ‡¡slo linky
         mov       ah,al                    ; z–st v  barva podkladu
         call      DispLZem                 ; vymaz n¡ linky zemˆ
         loop      PosunZm2                 ; dal¨¡ linka

; ------ posun vzd lenosti zemˆ

         mov       ax,ds:[Rychlost]         ; rychlost letu
         mov       dx,ds:[VzdalZem]         ; dosud uletˆn  vzd lenost zemˆ
         add       ax,dx                    ; novˆ uletˆn  vzd lenost
         mov       ds:[VzdalZem],ax         ; nov  vzd lenost

; ------ v˜po‡et nov‚ f ze pohybu zemˆ

         mov       cl,5                     ; po‡et rotac¡
         sar       ax,cl                    ; nov  vzd lenost / 32
         sar       dx,cl                    ; star  vzd lenost / 32
         sub       ax,dx                    ; p©¡rustek uletˆn‚ vzd lenosti
         add       ax,ds:[FazeZem]          ; nov  f ze zemˆ
PosunZm4:cmp       ax,13                    ; p©ekro‡ena f ze posunu ?
         jb        PosunZm5                 ; nen¡ p©ekro‡ena f ze
         sub       ax,13                    ; oprava k 0 dol–
         jmp       short PosunZm4           ; nov˜ test
PosunZm5:mov       ds:[FazeZem],ax          ; nov  f ze zemˆ

; ------ definice nov‚ f ze linek

         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; f ze * 8
         add       ax,offset LinkyZem       ; tabulka ‡¡sel linek
         xchg      ax,si                    ; SI <- adresa definice linek

; ------ zobrazen¡ nov˜ch linek

         mov       cx,8                     ; po‡et linek
PosunZm6:cld
         lodsb                              ; ‡¡slo linky
         mov       ah,al                    ; barva podkladu
         add       ah,6                     ; posun barvy linky
         call      DispLZem                 ; zobrazen¡ linky zemˆ
         loop      PosunZm6                 ; dal¨¡ linka
         ret

PosunZem ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ linky zemˆ AL s barvou linky AH
; -----------------------------------------------------------------------------

DispLZem PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ adresa linky ve videopamˆti

         mov       bl,al                    ; BL <- po‘adovan  linka
         mov       bh,0
         add       bx,OBZOR                 ; posun o linky obzoru
         cmp       bx,200
         jae       DispLZm9
         shl       bx,1
         mov       di,ds:[bx+AdrVLine]      ; adresa videolinky

; ------ barva linky

         cmp       ah,200-OBZOR
         jb        DispLZm6
         mov       ah,200-OBZOR-1
DispLZm6:mov       bl,ah                    ; po‘adovan  barva linky
         mov       bh,0
         shl       bx,1                     ; offset v tabulce vzor–
         mov       ax,ds:[bx+VzorZem]       ; vzorek k ulo‘en¡

; ------ z pis linky

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       cx,320/2                 ; d‚lka linky
         cld
         rep       stosw                    ; zobrazen¡ linky

; ------ n vrat registr–

DispLZm9:pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

DispLZem ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ pozad¡ sc‚ny a podkladu
; -----------------------------------------------------------------------------

DispPoz  PROC      NEAR

; ------ test, zda se pozad¡ sc‚ny zobraz¡

         test      byte ptr ds:[ParamS],bit0 ; zobraz¡ se pozad¡ sc‚ny ?
         jnz       DispPoz1                 ; zobraz¡ se pozad¡ sc‚ny
         ret

; ------ zobrazen¡ poho©¡

DispPoz1:mov       es,ds:[SegmVRAM]
         xor       di,di
         cld
         push      ds
         mov       cx,OBZOR * 320/2         ; po‡et linek na poho©¡
         mov       si,TOPSCR
         mov       ax,SEG SCR
         mov       ds,ax
         rep       movsw                    ; p©enos obr zku poho©¡
         pop       ds

; ------ zobrazen¡ podkladu (zemˆ)

         mov       si,offset VzorZem        ; vzorek zemˆ
         mov       dx,200-OBZOR
DispPoz2:lodsw
         mov       cx,320/2
         rep       stosw
         dec       dx
         jnz       DispPoz2

; ------ zobrazen¡ tov rny (kromˆ prvn¡ sc‚ny)








         ret

DispPoz  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ po‡tu ‘ivot–
; -----------------------------------------------------------------------------

DispZiv  PROC      NEAR


         ret

DispZiv  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ z soby paliva
; -----------------------------------------------------------------------------

DispPal  PROC      NEAR


         ret

DispPal  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Zvukov˜ gener tor
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        inicializace zvuku
; -----------------------------------------------------------------------------
; VSTUP: AL=‡¡slo zvuku
;                 0=z sah disku
;                 1=st©¡len¡
;                 2=v˜buch rakety (letadla)
;                 3=vygenerovan  bomba
;                 4=vygenerovan  bomba br ny
;                 5=v˜buch
;                 6=doch z¡ palivo
;                 7=v˜buch nep©¡tele
;                 8=proletˆn¡ branou
;                 9=dal¨¡ ‘ivot p©i zv˜¨en¡ sk¢re o 2000
;                10=v˜buch nep© telsk‚ kosmick‚ lodi
;                11=konec v˜buchu nep© telsk‚ kosmick‚ lodi
; -----------------------------------------------------------------------------

InitSnd  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ adresa po‘adovan‚ melodie

         mov       ah,0
         shl       ax,1                     ; ‡¡slo melodie * 2
         xchg      ax,bx                    ; offset adresy melodie
         mov       bx,ds:[bx+TabSnd]        ; adresa melodie

; ------ stanoven¡ priority melodie

         mov       ax,ds:[bx]               ; priorita po‘adovan‚ melodie
         cmp       ax,ds:[LevSnd]           ; m  vy¨¨¡ prioritu ?
         jb        InitSnd9                 ; m  ni‘¨¡ prioritu - ignoruje se

; ------ zapnut¡ zvukov‚ho v˜stupu

         in        al,[61h]
         or        al,bit0+bit1             ; zapnut¡ zvukov‚ho v˜stupu
         out       [61h],al

; ------ nastaven¡ frekvence prvn¡ho t¢nu

         mov       al,0b6h
         out       [43h],al                 ; ©¡dic¡ slovo dˆli‡ky
         mov       ax,ds:[bx+2]             ; dˆlic¡ konstanta
         out       [42h],al
         mov       al,ah
         out       [42h],al                 ; nastaven¡ frekvence

; ------ nastaven¡ d‚lky t¢nu

         mov       ax,ds:[bx+4]             ; d‚lka prvn¡ho t¢nu
         mov       ds:[CitSnd],ax           ; d‚lka t¢nu

; ------ nastaven¡ ukazatele melodie (adresa)

         add       bx,6                     ; adresa dal¨¡ho t¢nu
         mov       ds:[AdrSnd],bx           ; adresa dal¨¡ho t¢nu

; ------ n vrat registr–

InitSnd9:pop       cx
         pop       bx
         pop       ax
         ret

InitSnd  ENDP

; -----------------------------------------------------------------------------
;        obsluha hry zvuk–
; -----------------------------------------------------------------------------

PlaySnd  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ ‡¡t n¡ d‚lky t¢nu

         cmp       word ptr ds:[CitSnd],0   ; je konec t¢nu ?
         je        PlaySnd9                 ; je konec t¢nu
         dec       word ptr ds:[CitSnd]     ; ‡¡ta‡ d‚lky t¢nu
         jnz       PlaySnd9                 ; t¢n je¨tˆ pokra‡uje

; ------ nastaven¡ frekvence nov‚ho t¢nu

         mov       bx,ds:[AdrSnd]           ; ukazatel melodie
         mov       ax,ds:[bx]               ; frekvence t¢nu
         out       [42h],al
         mov       al,ah
         out       [42h],al

; ------ nastaven¡ d‚lky t¢nu

         mov       ax,ds:[bx+2]             ; d‚lka t¢nu
         mov       ds:[CitSnd],ax           ; ‡¡ta‡ d‚lky t¢nu (0=konec)

; ------ posun ukazatele melodie

         add       bx,4                     ; zv˜¨en¡ adresy
         mov       ds:[AdrSnd],bx           ; nov  adresa
         cmp       word ptr ds:[CitSnd],0   ; je konec melodie ?
         jne       PlaySnd9                 ; nen¡ je¨tˆ konec melodie

; ------ vypnut¡ zvukov‚ho gener toru

         mov       word ptr ds:[LevSnd],0   ; priorita = ‘ dn  melodie
         in        al,[61h]
         and       al,not bit0+bit1         ; vypnut¡ zvuk. gener toru
         out       [61h],al

; ------ n vrat registr–

PlaySnd9:pop       cx
         pop       bx
         pop       ax
         ret

PlaySnd  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ zvukov‚ho gener toru
; -----------------------------------------------------------------------------

SoundOff PROC      NEAR

         push      ax
         in        al,[61h]
         and       al,not bit0+bit1         ; vypnut¡ zvukov‚ho gener toru
         out       [61h],al
         pop       ax
         ret

SoundOff ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              Instalace
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        instalace programu
; -----------------------------------------------------------------------------

Instal   PROC      NEAR

; ------ instalace obsluhy p©eru¨en¡ INT 23h

         mov       ax,2523h
         mov       dx,offset Int23
         push      ds
         push      cs
         pop       ds
         int       21h
         pop       ds

; ------ £schova adresy INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es

; ------ instalace obsluhy INT 09h

         mov       ax,2509h
         mov       dx,offset Int09
         push      ds
         push      cs
         pop       ds                       ; DS <- programov˜ segment
         int       21h
         pop       ds
         ret

Instal   ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu
; -----------------------------------------------------------------------------

DInstal  PROC      NEAR

         push      ds
         lds       dx,ds:[Old09]
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h
         pop       ds
         ret

DInstal  ENDP

; -----------------------------------------------------------------------------
;        inicializace videom¢du
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

; ------ inicializace videom¢du VGA

         mov       ax,13h
         call      Int10

; ------ inicializace palet VGA (z obr zku SCR)

         mov       ax,SEG SCR
         mov       es,ax
         mov       dx,offset SCR+16         ; tabulka palet v segmentu SCR
         xor       bx,bx                    ; prvn¡ barva
         mov       cx,256                   ; po‡et definovan˜ch barev
         mov       ax,1012h
         call      Int10                    ; p©edefinov n¡ palet VGA

; ------ p©¡prava tabulky vzork– zemˆ

         push      ds
         pop       es                       ; ES <- datov˜ segment
         push      ds
         mov       ax,SEG SCR
         mov       ds,ax
         mov       di,offset VzorZem        ; vzorky zemˆ
         mov       cx,200-OBZOR             ; po‡et linek zemˆ
         mov       si,TOPSCR + 320*OBZOR    ; vzorky zemˆ
         cld
InitVMd2:movsw
         add       si,320-2
         loop      InitVMd2
         pop       ds

; ------ p©¡prava k sestaven¡ adres videolinek

         push      ds
         pop       es
         mov       di,offset AdrVLine
         mov       cx,200                   ; po‡et linek
         xor       ax,ax
         cld

; ------ adresy videolinek pro VGA

InitVMd7:stosw
         add       ax,320
         loop      InitVMd7
         ret

InitVMod ENDP

; -----------------------------------------------------------------------------
;        inicializace nov‚ hry
; -----------------------------------------------------------------------------
;þ
InitHra  PROC      NEAR

         xor       ax,ax
         mov       word ptr ds:[Skore],ax   ; aktu ln¡ sk¢re
         mov       word ptr ds:[Skore+2],ax
         mov       byte ptr ds:[Zivoty],3   ; po‡et ‘ivot–
         mov       byte ptr ds:[Scena],0    ; ‡¡slo sc‚ny
         mov       byte ptr ds:[Sektor],0   ; ‡¡slo sektoru
         mov       word ptr ds:[SkorZiv],2000 ; ‡¡ta‡ sk¢re pro zv˜¨en¡ ‘ivota

         ret

InitHra  ENDP

; -----------------------------------------------------------------------------
;        inicializace nov‚ho sektoru
; -----------------------------------------------------------------------------

InitSekt PROC      NEAR

         mov       word ptr ds:[Palivo],-1  ; palivo na maximum
         mov       word ptr ds:[FazeZem],0  ; f ze posunu zemˆ
         mov       word ptr ds:[VzdalZem],0 ; uletˆn  vzd lenost zemˆ
         mov       word ptr ds:[Rychlost],50 ; rychlost letu
         mov       word ptr ds:[RaketaX],(320-64)/2
         mov       word ptr ds:[RaketaY],92
         mov       byte ptr ds:[DelStrel],0 ; ‡¡ta‡ prodlevy mezi st©elami
         ret

InitSekt ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      ds
         push      es

; ------ £schova ukl dac¡ adresy do bufferu kl vesnice

         mov       ax,SEG Data
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       ax,40h
         mov       es,ax                    ; ES <- segment BIOS
         mov       bx,es:[1ch]              ; ukl dac¡ adresa do bufferu

; ------ ‡ten¡ k¢du kl vesy

         in        al,[60h]                 ; ‡ten¡ k¢du kl vesy

; ------ kl vesa "S" - zmˆna p©¡znaku zvuku

         cmp       al,1fh
         jne       Int091
         xor       byte ptr ds:[Param],bit0 ; zmˆna p©¡znaku zvuku

; ------ p©¡prava registr–

Int091:  mov       cx,bit0                  ; CL <- bit0, CH <- 0
         shl       al,1                     ; CF <- bit7 (p©¡znak uvolnˆn¡)
         rcl       ch,1                     ; CH (bit0) <- p©¡znak uvolnˆn¡

; ------ rozli¨en¡ kl ves (kurzory, mezera, Ctrl-, Alt- a Esc)

         mov       ah,not bit1              ; nulov n¡ "vpravo"
         cmp       al,4bh*2
         je        Int092                   ; vlevo
         shl       cx,1                     ; pozice = bit1
         mov       ah,not bit0              ; nulov n¡ "vlevo"
         cmp       al,4dh*2
         je        Int092                   ; vpravo
         shl       cx,1                     ; pozice = bit2
         mov       ah,not bit3              ; nulov n¡ "dol–"
         cmp       al,48h*2
         je        Int092                   ; nahoru
         shl       cx,1                     ; pozice = bit3
         mov       ah,not bit2              ; nulov n¡ "nahoru"
         cmp       al,50h*2
         je        Int092                   ; dol–
         shl       cx,1                     ; pozice = bit4
         mov       ah,0ffh                  ; nic se nenuluje
         cmp       al,39h*2
         je        Int092                   ; mezera
         shl       cx,1                     ; pozice = bit5
         cmp       al,1dh*2
         je        Int092                   ; Ctrl-
         shl       cx,1                     ; pozice = bit6
         cmp       al,38h*2
         je        Int092                   ; Alt-
         shl       cx,1                     ; pozice = bit7
         cmp       al,44h
         je        Int092                   ; F10 (jako ESC)
         cmp       al,1*2
         jne       Int093                   ; Esc

Int092:  and       ds:[Keys],ah             ; nulov n¡ paraleln¡ kl vesy
         or        ds:[Keys],cl             ; nastaven¡ p©¡znaku stisku kl vesy
         xor       ds:[Keys],ch             ; p©i uvolnˆn¡ vynulov n¡ p©¡znaku
         or        ds:[Keys0],cl            ; £schova
         xor       ds:[Keys0],ch            ; £schova

         or        ch,ch                    ; je uvolnˆn¡ ?
         jz        Int093                   ; nen¡ uvolnˆn¡
         not       ah
         and       ah,ds:[Keys0]            ; uschovan  paraleln¡ kl vesa
         or        ds:[Keys],ah             ; n vrat uschovan‚ho stavu kl vesy

; ------ vol n¡ p–vodn¡ obsluhy kl vesnice

Int093:  pushf
         call      dword ptr ds:[Old09]     ; p–vodn¡ obsluha kl vesnice
         mov       es:[1ch],bx              ; zru¨en¡ kl vesy z bufferu

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       cx
         pop       bx
         pop       ax
         iret

Int09    ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       Univerz ln¡ obsluha displeje
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;                  vymaz n¡ obrazovky
; -----------------------------------------------------------------------------

Clear    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      es

; ------ vymaz n¡ videopamˆti VGA

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       cx,320*200/2
         xor       ax,ax
         rep       stosw

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

Clear    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

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

Int10    ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na impuls hodin
; -----------------------------------------------------------------------------

WaitTim  PROC      NEAR

         push      ax
         push      es

         xor       ax,ax
         mov       es,ax
         mov       ax,ds:[OldTim]           ; uschovan˜ stav hodin
WaitTim2:sti
         cmp       ax,es:[46ch]             ; je zmˆna hodin ?
         je        WaitTim2                 ; ‡ek n¡ na impuls hodin
         mov       ax,es:[46ch]
         mov       ds:[OldTim],ax           ; £schova nov‚ho stavu hodin

         pop       es
         pop       ax
         ret

WaitTim  ENDP

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                  Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               Zvuky
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ obsluha zvuk–

LevSnd   dw        0                        ; ukazatel priority zvuku
CitSnd   dw        0                        ; ‡¡ta‡ d‚lky jednoho t¢nu zvuku
AdrSnd   dw        0                        ; ukazatel adresy zvuku

TabSnd   label     word                     ; tabulka adres melodi¡
         dw        Snd0                     ;  0=z sah disku
         dw        Snd1                     ;  1=st©¡len¡
         dw        Snd2                     ;  2=v˜buch rakety (letadla)
         dw        Snd3                     ;  3=vygenerovan  bomba
         dw        Snd4                     ;  4=vygenerovan  bomba br ny
         dw        Snd5                     ;  5=v˜buch
         dw        Snd6                     ;  6=doch z¡ palivo
         dw        Snd7                     ;  7=v˜buch nep©¡tele
         dw        Snd8                     ;  8=proletˆn¡ branou
         dw        Snd9                     ;  9=dal¨¡ ‘ivot p©i zv˜¨en¡ sk¢re o 2000
         dw        Snd10                    ; 10=v˜buch nep© telsk‚ kosmick‚ lodi
         dw        Snd11                    ; 11=konec v˜buchu nep© telsk‚ kosmick‚ lodi

Snd0     dw        100
         dw        7d0h,1
         dw        1f40h,1
         dw        2710h,1
         dw        1f40h,1
         dw        2710h,1
         dw        1f40h,1
         dw        2710h,1
         dw        0,0

Snd1     dw        100                      ; st©¡len¡
         dw        2300,1
         dw        3500,1
         dw        3230,1
         dw        5320,1
         dw        4700,1
         dw        4900,1
;         dw        8000,1
;         dw        10000,1
;         dw        12000,1
         dw        0,0

Snd2     dw        100
         dw        7530h,1
         dw        2710h,2
         dw        9c40h,3
         dw        36b0h,4
         dw        32c8h,3
         dw        2ee0h,2
         dw        0ea60h,5
         dw        0,0

         dw        0,0

Snd3     dw        90
         dw        0d6d8h,4
         dw        0,0

Snd4     dw        90
         dw        0c350h,4
         dw        0,0

Snd5     dw        90
         dw        1f4h,1
         dw        1388h,1
         dw        0,0

Snd6     dw        100
         dw        7d0h,3
         dw        0,0

Snd7     dw        80
         dw        3e8h,1
         dw        0,1
         dw        3e8h,1
         dw        0,0

         dw        0,0

Snd8     dw        80
         dw        3e8h,1
         dw        320h,1
         dw        258h,1
         dw        0,0

         dw        0,0

Snd9     dw        70
         dw        2710h,1
         dw        2328h,1
         dw        1f40h,1
         dw        1b58h,1
         dw        1770h,1
         dw        1388h,1
         dw        0fa0h,1,0bb8h,1,7d0h,1,3e8h,1,1f4h,1,3e8h,1,7d0h,1,0bb8h,1,0fa0h
         dw        1,1388h,1,1770h,1,1b58h,1,1f40h,1,2328h,1,3e8h,0,0

Snd10    dw        90,12ch,1,3e8h,1,7d0h,1,1388h,1,4e20h,2,3e8h,1,514h,1,640h
         dw        1,960h,1,15b3h,1,8235h,3,7d0h,1,0fa0h,1,1388h,1,1f40h,1,8235h,3,0,0

Snd11    dw        90,4e20h,5,7d0h,1,2328h,5,0,0

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           Pohyby
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ definice pohyb–

AdrPohyb label     word                     ; tabulka adres pohyb– objekt–

         dw        PohStrel                 ; 0 st©ela z rakety
         dw        PohLBran                 ; 1 lev˜ sloup br ny
         dw        PohRBran                 ; 2 prav˜ sloup br ny
         dw        dae65-1                  ; 3 kosmick  loƒ 0 (je zemˆ), disk 0
         dw        dae6d-1                  ; 4 kosmick  loƒ 1 (je zemˆ), disk 1
         dw        dae75-1                  ; 5 kosmick  loƒ 2 (je zemˆ), disk 2
         dw        dae7d-1                  ; 6 kosmick  loƒ 3 (je zemˆ), disk 3

         dw        dae83-1                  ; 7 v˜buch disku, UFO
         dw        dae9d-1                  ; 8 v˜buch disku, UFO
         dw        dae8b-1                  ; 9 v˜buch rakety
         dw        dae9e-1                  ; 10 velk‚ UFO
         dw        daec0-1                  ; 11
         dw        daee2-1                  ; 12 bomba kosmick‚ lodi, UFO
         dw        daeef-1                  ; 13 bomba br ny (vlevo)
         dw        daef4-1                  ; 14 bomba br ny (vpravo)

         dw        daef9-1                  ; 15 kosmick  loƒ 0 (nen¡ zemˆ)
         dw        daf30-1                  ; 16 kosmick  loƒ 1 (nen¡ zemˆ)
         dw        daf69-1                  ; 17 ... dal¨¡ pohyb
         dw        daf80-1                  ; 18 ... dal¨¡ pohyb

         dw        daf97-1                  ; 19 hvˆzda vpravo 0
         dw        daf9c-1                  ; 20 hvˆzda vpravo 1
         dw        dafa3-1                  ; 21 hvˆzda vpravo 2
         dw        dafaa-1                  ; 22 hvˆzda vpravo 3
         dw        dafaf-1                  ; 23 hvˆzda vpravo 4
         dw        dafb6-1                  ; 24 hvˆzda vpravo 5

         dw        dafbd-1                  ; 25 hvˆzda vlevo 0
         dw        dafc2-1                  ; 26 hvˆzda vlevo 1
         dw        dafc9-1                  ; 27 hvˆzda vlevo 2
         dw        dafd0-1                  ; 28 hvˆzda vlevo 3
         dw        dafd5-1                  ; 29 hvˆzda vlevo 4
         dw        dafdc-1                  ; 30 hvˆzda vlevo 5

         dw        dafe3-1                  ; 31 ?
         dw        daff2-1                  ; 32 ?
         dw        db001-1                  ; 33 ?
         dw        db010-1                  ; 34 ?
         dw        db01f-1                  ; 35 ?
         dw        db024-1                  ; 36 ?
         dw        db033-1                  ; 37 ?
         dw        db042-1                  ; 38 ?

; ------ akce objekt–

; bit 7 = 0:  bit 0 a‘ bit 6 = p©¡rustek sou©adnice Y
;     n sleduje stavov˜ bajt:
;                            bit 0: 1=zv˜¨en¡ p©¡rustku X; 0=sn¡‘en¡ p©¡rustku X
;                            bit 1: 1=zmen¨en¡ objektu; 0=zvˆt¨en¡ objektu
;                            bit 2: 1=smˆr posunu Y dol–, 0=smˆr nahoru
;                            bit 3: 1=smˆr posunu X vpravo, 0=smˆr vlevo
;                            bit 4: 1=zmˆna p©¡rustku sou©adnice X
;                            bit 5: 1=zmˆna velikosti objektu
;                            bit 6: 1=m  b˜t posun ve smˆru Y (smˆr bit 2)
;                            bit 7: 1=m  b˜t posun ve smˆru X (smˆr bit 3)
; bit 7 = 1:  bit 0 a‘ bit 6 = povel
;                  0 = nastaven¡ nov‚ho offsetu ukazatele akc¡ (n sleduje slovo offsetu)
;                  1 = nastaven¡ typu objektu (n sleduje bajt typu objektu)
;                  2 = konec pohybu - zru¨en¡ objektu
;                  3 = vol n¡ podprogramu (£schova sou‡asn‚ho ukazatele, n sleduje slovo)
;                  4 = n vrat z podprogramu (n vrat sou‡asn‚ho ukazatele)
;                  5 = nastaven¡ p©¡rustku sou©adnice X (n sleduje bajt p©¡rustku X)
;                  6 = test proletˆn¡ rakety branou
;                  7 = generov n¡ nov‚ho pohybu objektu 17 nebo 18

PohStrel label     byte                     ; 0: st©ela z rakety

         db        24                       ; rychlost Y
         db        bit6                     ; posun ve smˆru Y nahoru
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        PohStrl2                 ; .... adresa
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        PohStrl2                 ; .... adresa
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        PohStrl2                 ; .... adresa
         db        bit7 + 2                 ; konec pohybu - zru¨en¡ objektu

PohStrl2 label     byte
         db        bit4                     ;
         db        72h
         db        4,40h                    ; p©¡rustek Y, posun Y nahoru
         db        4,40h                    ; p©¡rustek Y, posun Y nahoru
         db        bit7 + 4                 ; n vrat z podprogramu


PohLBran label     byte                     ; 1: lev˜ sloup br ny
         db        2                        ; rychlost Y
         db        bit2+bit5+bit6           ; zmen¨en¡, posun dol–
         db        1                        ; rychlost Y
         db        bit2+bit5+bit6           ; zmen¨en¡, posun dol–
         db        1
         db        bit2+bit6+bit7           ; posun dol– vlevo
         db        3
         db        bit2+bit6                ; posun dol–
         db        1
         db        bit2+bit6+bit7           ; posun dol– vlevo
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db179                    ; ... (adresa)
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db179                    ; ... (adresa)
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db179                    ; ... (adresa)
         db        2
         db        bit2+bit6                ; posun dol–
         db        1
         db        bit2+bit5+bit6           ; zmen¨en¡, posun dol–
         db        1
         db        bit2+bit6+bit7           ; posun dol– vlevo
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db180                    ; ... (adresa)
         db        2
         db        bit2+bit6                ; posun dol–
         db        1
         db        bit2+bit6                ; posun dol–
         db        1
         db        bit2+bit6+bit7           ; posun dol– vlevo
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db179                    ; ... (adresa)
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db184                    ; ... (adresa)
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db179                    ; ... (adresa)
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db180                    ; ... (adresa)
         db        bit7 + 6                 ; test proletˆn¡ rakety branou
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db179                    ; ... (adresa)
         db        bit7 + 3                 ; vol n¡ podprogramu
         dw        db180                    ; ... (adresa)
         db        40
         db        bit2+bit6+bit7           ; posun dol– vlevo
         db        bit7 + 2                 ; konec pohybu - zru¨en¡ sloupu


PohRBran label     byte                     ; 2: prav˜ sloup br ny

db 002h,064h,001h,064h,001h ;AE20
db 0CCh,003h,044h,001h,0CCh,083h,089h,0B1h,083h,089h,0B1h,083h,089h,0B1h,002h,044h ;AE30
db 001h,064h,001h,0CCh,083h,090h,0B1h,002h,044h,001h,044h,001h,0CCh,083h,089h,0B1h ;AE40
db 083h,094h,0B1h,083h,089h,0B1h,083h,090h,0B1h,086h,083h,089h,0B1h,083h,090h,0B1h ;AE50
db 028h,0CCh,082h,070h,040h


dae65    label     byte                     ; 3: kosmick  loƒ 0 (je zemˆ), disk 0
db 083h,029h,0B1h,083h,040h,0B1h,070h,040h

dae6d    label     byte                     ; 4: kosmick  loƒ 1 (je zemˆ), disk 1
db 083h,029h,0B1h ;AE60
db 083h,068h,0B1h,070h,040h

dae75    label     byte                     ; 5: kosmick  loƒ 2 (je zemˆ), disk 2
db 083h,051h,0B1h,083h,068h,0B1h,070h,040h

dae7d    label     byte                     ; 6: kosmick  loƒ 3 (je zemˆ), disk 3
db 083h,051h,0B1h ;AE70
db 083h,040h,0B1h

dae83    label     byte                     ; 7: v˜buch disku, UFO
db 081h,007h,085h,010h,005h,000h,005h,020h

dae8b    label     byte                     ; 9 v˜buch rakety
db 085h,010h,005h,0A8h,005h ;AE80
db 022h,005h,022h,005h,0AAh,005h,022h,005h,022h,005h,022h,005h,022h

dae9d    label     byte                     ; 8: v˜buch disku, UFO
db 082h

dae9e    label     byte                     ; 10: velk‚ UFO
db 004h,0C4h ;AE90
db 004h,0E4h,001h,020h,083h,01Ah,0B1h,010h,0C4h,001h,020h,083h,08Fh,0B0h,010h,0CCh ;AEA0
db 008h,0ECh,001h,020h,083h,0DCh,0B0h,020h,0C4h,001h,020h,083h,051h,0B0h,07Fh,0CCh ;AEB0

daec0    label     byte                     ; 11:
db 004h,0CCh,004h,0ECh,001h,020h,083h,0AEh,0B0h,010h,0CCh,001h,020h,083h,0FBh,0B0h ;AEC0
db 010h,0C4h,008h,0E4h,001h,020h,083h,070h,0B0h,020h,0CCh,001h,020h,083h,0BDh,0B0h ;AED0
db 07Fh,0C4h

daee2    label     byte                     ; 12: bomba kosmick‚ lodi, UFO
db 083h,0E8h,0AEh,080h,0E2h,0AEh,004h,0C4h,004h,064h,008h,064h,084h

daeef    label     byte                     ; 13: bomba br ny (vlevo)
         db 07Fh ;AEE0
         db 080h
         db        bit7 + 0
         dw        daeef


daef4    label     byte
         db 07Fh,088h                           ; 14: bomba br ny (vpravo)
         db        bit7 + 0
         dw        daef4

daef9    label     byte                     ; 15: kosmick  loƒ 0 (nen¡ zemˆ)
db 008h,040h,010h,0BAh,008h,040h,008h ;AEF0
db 0C0h,048h,080h,008h,040h,010h,0B2h,008h,040h,008h,0C8h,048h,0BAh,008h,0C8h,004h ;AF00
db 050h,004h,0C0h,010h,0A2h,002h,0C0h,002h,0FAh,008h,080h,002h,0C8h,002h,072h,002h ;AF10
db 080h,002h,0C0h,002h,0EAh,002h,080h,002h,0E2h,008h,088h,008h,080h,008h,088h,087h ;AF20

daf30    label     byte                     ; 16: kosmick  loƒ 1 (nen¡ zemˆ)
db 008h,040h,010h,0C0h,010h,0B2h,008h,040h,008h,0C8h,048h,088h,008h,040h,010h,0BAh ;AF30
db 008h,040h,008h,0C0h,048h,0B2h,008h,0C0h,004h,050h,004h,0C8h,010h,0AAh,002h,0C8h ;AF40
db 002h,0F2h,008h,088h,002h,0C0h,002h,072h,002h,088h,002h,0C8h,002h,0E2h,002h,088h ;AF50
db 002h,0EAh,008h,080h,008h,088h,008h,080h,087h

daf69    label     byte                     ; 17: ... dal¨¡ pohyb
db 002h,0ECh,010h,0A0h,004h,0FDh,010h ;AF60
db 088h,004h,0E4h,020h,080h,008h,0FDh,020h,0A8h,008h,0E4h,040h,0A0h,07Fh,0DDh,082h ;AF70

daf80    label     byte                     ; 18: ... dal¨¡ pohyb
db 002h,0E4h,010h,0A8h,004h,0F5h,010h,080h,004h,0ECh,020h,088h,008h,0F5h,020h,0A0h ;AF80
db 008h,0ECh,040h,0A8h,07Fh,0D5h,082h

daf97    label     byte                     ; 19: hvˆzda vpravo 0
db 07Fh,040h
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        daf97                    ; nov  adresa pohybu

daf9c    label     byte                     ; 20: hvˆzda vpravo 1
db 001h,040h,001h,0C8h ;AF90
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        daf9c                    ; nov  adresa pohybu



dafa3    label     byte                     ; 21: hvˆzda vpravo 2
db 001h,088h,001h,0C8h
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafa3

dafaa    label     byte                     ; 22: hvˆzda vpravo 3
db 07Fh,088h
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafaa

dafaf    label     byte                     ; 23: hvˆzda vpravo 4
db 001h ;AFA0
db 088h,001h,0CCh
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafaf


dafb6    label     byte                     ; 24: hvˆzda vpravo 5
db 001h,044h,001h,0CCh
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafb6


dafbd    label     byte                     ; 25: hvˆzda vlevo 0
db 07Fh,044h    ;AFB0
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafbd


dafc2    label     byte                     ; 26: hvˆzda vlevo 1
db 001h,044h,001h,0C4h
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafc2


dafc9    label     byte                     ; 27: hvˆzda vlevo 2
db 001h,080h,001h,0C4h
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafc9


dafd0    label     byte                     ; 28: hvˆzda vlevo 3
db 07Fh,080h
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafd0


dafd5    label     byte                     ; 29: hvˆzda vlevo 4
db 001h,080h,001h,0C0h
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafd5


dafdc    label     byte                     ; 30: hvˆzda vlevo 5
db 001h,040h,001h,0C0h ;AFD0
         db        bit7 + 0                 ; povel pro opakov n¡ pohybu
         dw        dafdc


dafe3    label     byte                     ; 31 ?
db 081h,004h,083h,0EBh,0AFh,080h,0E3h,0AFh,004h,0C0h,004h,060h,008h ;AFE0
db 060h,084h

daff2    label     byte                     ; 32 ?
db 081h,004h,083h,0FAh,0AFh,080h,0F2h,0AFh,004h,0C0h,004h,0E8h,008h,0E8h ;AFF0
db 084h

db001    label     byte                     ; 33 ?
db 081h,004h,083h,009h,0B0h,080h,001h,0B0h,004h,088h,004h,0A8h,008h,0A8h,084h ;B000

db010    label     byte                     ; 34 ?
db 081h,004h,083h,018h,0B0h,080h,010h,0B0h,004h,0CCh,004h,0ECh,008h,0ECh,084h

db01f    label     byte                     ; 35 ?
db 081h ;B010
db 004h,080h,0E2h,0AEh

db024    label     byte                     ; 36 ?
db 081h,004h,083h,02Ch,0B0h,080h,024h,0B0h,004h,0C4h,004h,0E4h ;B020
db 008h,0E4h,084h

db033    label     byte                     ; 37 ?
db 081h,004h,083h,03Bh,0B0h,080h,033h,0B0h,004h,080h,004h,0A0h,008h ;B030
db 0A0h,084h

db042    label     byte                     ; 38 ?
db 081h,004h,083h,04Ah,0B0h,080h,042h,0B0h,004h,0C0h,004h,0E4h,008h,0E4h ;B040
db 084h,004h,0C8h,00Ah,040h,009h,0C8h,004h,040h,00Bh,0C8h,003h,088h,002h,0C8h,007h ;B050
db 0A8h,002h,0CCh,003h,088h,00Bh,0CCh,004h,044h,009h,0CCh,00Ah,044h,004h,0CCh,084h ;B060
db 003h,0C8h,004h,040h,005h,0C8h,004h,040h,002h,0C8h,002h,040h,009h,0C8h,009h,0A8h ;B070
db 009h,0CCh,002h,044h,002h,0CCh,004h,044h,005h,0CCh,004h,044h,003h,0CCh,084h,002h ;B080
db 0C8h,003h,040h,002h,0C8h,002h,040h,003h,0C8h,002h,040h,005h,0C8h,006h,0A8h,005h ;B090
db 0CCh,002h,044h,003h,0CCh,002h,044h,002h,0CCh,003h,044h,002h,0CCh,084h,002h,0C8h ;B0A0
db 002h,040h,004h,0C8h,004h,088h,004h,0CCh,002h,044h,002h,0CCh,084h,004h,0C0h,00Ah ;B0B0
db 040h,009h,0C0h,004h,040h,00Bh,0C0h,003h,080h,002h,0C0h,007h,0A0h,002h,0C4h,003h ;B0C0
db 080h,00Bh,0C4h,004h,044h,009h,0C4h,00Ah,044h,004h,0C4h,084h,003h,0C0h,004h,040h ;B0D0
db 005h,0C0h,004h,040h,002h,0C0h,002h,040h,009h,0C0h,009h,0A0h,009h,0C4h,002h,044h ;B0E0
db 002h,0C4h,004h,044h,005h,0C4h,004h,044h,003h,0C4h,084h,002h,0C4h,003h,040h,002h ;B0F0
db 0C0h,002h,040h,003h,0C0h,002h,040h,005h,0C0h,006h,0A0h,005h,0C4h,002h,044h,003h ;B100
db 0C4h,002h,044h,002h,0C4h,003h,044h,002h,0C4h,084h,002h,0C0h,002h,040h,004h,0C0h ;B110
db 004h,080h,004h,0C4h,002h,044h,002h,0C4h,084h,010h,0C8h,010h,0C8h,010h,0EAh,010h ;B120
db 062h,010h,062h,010h,072h,010h,072h,010h,072h,008h,072h,008h,062h,010h,080h,084h ;B130
db 008h,064h,008h,075h,010h,075h,010h,0FDh,010h,0FDh,010h,0ECh,010h,064h,030h,0E4h ;B140
db 082h,010h,0C0h,010h,0C0h,010h,0E2h,010h,062h,010h,062h,010h,072h,010h,072h,010h ;B150
db 072h,008h,072h,008h,062h,010h,088h,084h,008h,064h,008h,075h,010h,075h,010h,0F5h ;B160
db 010h,0F5h,010h,0E4h,010h,064h,030h,0ECh,082h                                    ;B170

db179    db        003h,064h,001h,0C4h,080h,084h,0B1h ;B170
db180    db        003h,044h,001h,0C4h
db184    db        003h,044h,001h,0C4h,084h,003h,064h,001h,0CCh,080h,094h,0B1h ;B180
db 003h,044h,001h,0CCh,003h,044h,001h,0CCh,084h,000h,000h,000h,000h,000h           ;B190

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               Obr zky
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ adresy definice obr zk– (f ze: (1) ¨¡©ka, (1) v˜¨ka, (2) adresa)

DefObr   label     word
         dw        ObrRaket                 ; 1: raketa
         dw        0                        ; 2:
         dw        0                        ; 3:
         dw        0                        ; 4:
         dw        ObrStrel                 ; 5: st©ela
         dw        ObrBran                  ; 6: br na

; ------ raketa

ObrRaket label     word
         dw        32*HI + 64,TOPSCR + 100*320+3  ; 0: raketa nahoru
         dw        32*HI + 64,TOPSCR + 67*320+3   ; 1: raketa dol–
         dw        32*HI + 64,TOPSCR + 100*320+68 ; 2: raketa vpravo
         dw        32*HI + 64,TOPSCR + 67*320+68  ; 3: raketa vlevo
         dw        16*HI + 64,TOPSCR + 133*320+3  ; 4: st¡n
         dw        0,0                            ; 5:
         dw        0,0                            ; 6:
         dw        0,0                            ; 7:
         dw        0,0                            ; 8:

; ------ st©ely

ObrStrel label     word
         dw        0,0                           ; 0
         dw        8*HI + 46,TOPSCR + 66*320+133 ; 1:
         dw        8*HI + 46,TOPSCR + 72*320+133 ; 2:
         dw        8*HI + 46,TOPSCR + 78*320+133 ; 3:
         dw        8*HI + 46,TOPSCR + 85*320+133 ; 4:
         dw        8*HI + 46,TOPSCR + 92*320+133 ; 5:
         dw        0,0                           ; 6:
         dw        0,0                           ; 7:
         dw        0,0                           ; 8:

; ------ br ny

ObrBran  label     word
         dw        0,0                            ; 0:
         dw        32*HI + 24,TOPSCR + 67*320+184 ; 1:
         dw        32*HI + 24,TOPSCR + 67*320+209 ; 2:
         dw        32*HI + 24,TOPSCR + 67*320+234 ; 3:
         dw        32*HI + 24,TOPSCR + 67*320+259 ; 4:
         dw        32*HI + 24,TOPSCR + 67*320+284 ; 5:
         dw        0,0                            ; 6:
         dw        0,0                            ; 7:
         dw        0,0                            ; 8:

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            R–zn  data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ displej

OldVMod  db        3                        ; uschovan˜ p–vodn¡ videom¢d
Old09    dd        0                        ; p–vodn¡ adresa INT 09h
OldTim   dw        0                        ; uschovan˜ stav hodin

SegmVRAM dw        0a000h                   ; segment videopamˆti


; ------ definice aktivn¡ sc‚ny (sektoru)

ParamS   db        bit0                     ; parametry sektoru
                                            ;   bit 0: 1=zobraz¡ se pozad¡ a zem

Param    db        bit0                     ; parametry
                                            ;   bit 0: 1=zvuk zapnut ("S")

Card     db        0                        ; videokarta
                                            ;   bit 0: 1=Hercules
                                            ;   bit 1: 1=CGA
                                            ;   bit 2: 1=EGA
                                            ;   bit 3: 1=VGA

Keys0    db        0                        ; stisknut‚ kl vesy (£schova)
                                            ;   bit 0: 1=vlevo
                                            ;   bit 1: 1=vpravo
                                            ;   bit 2: 1=nahoru
                                            ;   bit 3: 1=dol–
                                            ;   bit 4: 1=mezera
                                            ;   bit 5: 1=Ctrl-
                                            ;   bit 6: 1=Alt-
                                            ;   bit 7: 1=ESC (a F10)

Keys     db        0                        ; stisknut‚ kl vesy
                                            ;   bit 0: 1=vlevo
                                            ;   bit 1: 1=vpravo
                                            ;   bit 2: 1=nahoru
                                            ;   bit 3: 1=dol–
                                            ;   bit 4: 1=mezera
                                            ;   bit 5: 1=Ctrl-
                                            ;   bit 6: 1=Alt-
                                            ;   bit 7: 1=ESC (a F10)


FazeZem  dw        0                        ; f ze posunu zemˆ (0 a‘ 12)
VzdalZem dw        0                        ; uletˆn  vzd lenost zemˆ
LinkyZem label     byte                     ; ‡¡sla linek zemˆ (13 f z¡*8 linek)
         db        4,11,20,31,47,72,106,255 ; 0
         db        4,11,20,32,48,74,109,255 ; 1
         db        5,12,21,33,50,76,112,255 ; 2
         db        5,12,21,34,52,78,115,255 ; 3
         db        1,6,13,22,35,54,80,118   ; 4
         db        1,6,13,23,36,56,82,121   ; 5
         db        1,7,14,24,37,58,85,124   ; 6
         db        2,7,14,25,38,60,88,127   ; 7
         db        2,8,15,26,39,62,91,130   ; 8
         db        2,8,16,27,40,64,94,133   ; 9
         db        3,9,17,28,41,66,97,136   ; 10
         db        3,9,18,29,43,68,100,139  ; 11
         db        3,10,19,30,45,70,103,143 ; 12

Palivo   dw        -1                       ; z soba paliva
Rychlost dw        30                       ; rychlost letu
SkorZiv  dw        2000                     ; ‡¡ta‡ skore pro zv˜¨en¡ ‘ivota
Zivoty   db        3                        ; po‡et ‘ivot–
Scena    db        0                        ; ‡¡slo sc‚ny
Sektor   db        0                        ; ‡¡slo sektoru
DelStrel db        0                        ; ‡¡ta‡ prodlevy mezi st©elami

PortCRT  dw        3dah                     ; port ©adi‡e obrazovky CRT

RaketaX  dw        (320-64)/2               ; poloha rakety X
RaketaY  dw        92                       ; poloha rakety Y

Skore    dd        0                        ; ‡¡ta‡ aktu ln¡ho sk¢re
MaxSkore dd        5000                     ; dosa‘en‚ maxim ln¡ sk¢re

; ------ tabulka definic objekt– ve sc‚nˆ

TabObj   db        ObjSumm*MAXOBJ dup(0)    ; definice objekt–
TabObj0  label     byte                     ; (konec tabulky)

; ------ definice vzork– pro zem

VzorZem  dw        200-OBZOR dup(?)         ; definice vzork– pro zem

; ------ adresy videolinek

AdrVLine dw        200 dup(?)               ; tabulka adres videolinek

Data     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                  Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasob    SEGMENT   'STACK' STACK
         dw        200h dup(?)
Zasob    ENDS
         END       Start

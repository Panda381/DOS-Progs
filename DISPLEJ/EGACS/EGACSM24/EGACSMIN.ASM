
; *****************************************************************************
;
;                              EGACSmin
;              Instalace ‡esk˜ch znak– na displej EGA/VGA Mini
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal                   ; instalace programu

                                            ; identifika‡n¡ text
Ident    db        'EGACSmin V2.42'
Ident0   label     byte

SegRez   dw        0                        ; segment rezidentn¡ ‡ sti
Old10    dd        0                        ; p–vodn¡ adresa obsluhy INT 10h

FontTab  db        1                        ; ‡¡slo tabulky font–
                                            ;   0=bez font–
                                            ;   1=Kamenick˜ch
                                            ;   2=Latin 2
                                            ;   3=KOI 8

AdrSt8   dd        0                        ; adresa standardn¡ho fontu 8x8
AdrSt14  dd        0                        ; adresa standardn¡ho fontu 8x14
AdrSt16  dd        0                        ; adresa stand. fontu 8x16
AdrSt19  dd        0                        ; adresa stand. fontu 8x19
AdrSt190 dd        0                        ; adresa stand. fontu 8x19 zv˜raz.

RegMap   db        0                        ; nastaven¡ registru pro mapov n¡

; -----------------------------------------------------------------------------
;        vol n¡ p–vodn¡ obsluhy INT 10h
; -----------------------------------------------------------------------------

Int10I   PROC      NEAR

         pushf                              ; simulace isntrukce INT xx
         call      dword ptr cs:[Old10]     ; nastaven¡ nov‚ho videom¢du
         ret

Int10I   ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      FAR

; ------ test, zda je dotaz na instalaci

         cmp       ah,12h                   ; funkce dotazu na instalaci ?
         jne       Int101                   ; nen¡ dotaz na instalaci
         cmp       bx,3e10h                 ; je dotaz na instalaci ?
         jne       Int102                   ; nen¡ identifikace dotazu

; ------ ovˆ©en¡, zda p©i¨el po‘adavek opravdu od EGACSmin

         push      si
         push      di
         push      cx
         push      ds
         cld
         push      cs
         pop       ds                       ; segment tohoto modulu
         mov       si,offset Ident          ; za‡ tek identifika‡n¡ho textu
         mov       di,si                    ; adresa identifika‡n¡ho textu
         mov       cx,offset(Ident0-Ident)  ; d‚lka identifika‡n¡ho textu
         repe      cmpsb                    ; je to tento program ?
         jne       Int100                   ; nen¡ to tento program
         mov       es:[SegRez],cs           ; segment rezidentn¡ho modulu
Int100:  pop       ds
         pop       cx
         pop       di
         pop       si

; ------ rozli¨en¡, zda se maj¡ p©einstalovat fonty

Int101:  or        ah,ah                    ; je nastaven¡ m¢du displeje ?
         jz        int103                   ; je nastaven¡ videom¢du
         cmp       ah,11h                   ; je slu‘ba obsluhy font– ?
         jne       int102                   ; nen¡ operace s fonty

; ------ kontrola, zda je nastaven¡ font– slu‘by 11h

         test      al,0fh                   ; jsou u‘iv. fonty nebo informace ?
         jz        Int102                   ; u‘ivatelsk‚ fonty nebo informace
         cmp       al,3                     ; je nastaven¡ bloku font– ?
         jne       Int103                   ; nen¡ nastaven¡ bloku
;         mov       bl,0
Int102:  jmp       dword ptr cs:[Old10]     ; skok na p–vodn¡ obsluhu INT 10h

; ------ fonty se p©einstaluj¡

Int103:  call      Int10I                   ; vol n¡ p–vodn¡ po‘adovan‚ funkce

;         push      ax
;         push      dx
;         mov       dx,3c4h
;         mov       al,3
;         out       dx,al
;         inc       dx
;         mov       al,0
;         out       dx,al
;         pop       dx
;         pop       ax

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

; ------ stanoven¡ adresy defini‡n¡ tabulky font–

         cmp       byte ptr cs:[FontTab],0  ; je nˆjak˜ font ?
         je        Int109                   ; funkce je vypnuta
         mov       bp,offset TabKoi         ; tabulka definice fontu

; ------ kontrola, zda je textov˜ videom¢d

         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0 datov˜ segment BIOS
         mov       al,ds:[449h]             ; aktu ln¡ videom¢d
         and       al,7fh                   ; zru¨en¡ p©¡znaku nemaz n¡ displeje
         mov       ah,0eh                   ; registr mapov n¡ pro CGA
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         jbe       Int104                   ; je textov˜ m¢d CGA - OK
         cmp       al,85                    ; videom¢d "Paradise VGA" ?
         je        Int104                   ; textov˜ videom¢d OK
         cmp       al,7                     ; je videom¢d MDA ?
         jne       Int109                   ; nen¡ textov˜ videom¢d
         mov       ah,0ah                   ; registr mapov n¡ pro MDA
Int104:  mov       cs:[RegMap],ah           ; £schova registru pro mapov n¡

; ------ nastaven¡ video©adi‡e do re‘imu definice znak–

         call      InitRegF                 ; inicializace registr– pro fonty

; ------ stanoven¡ adresy fontu podle po‡tu linek na znak

         mov       cx,ds:[485h]             ; po‡et linek na znak
         mov       bx,offset Font8          ; font 8x8
         lds       si,cs:[AdrSt8]           ; standardn¡ font 8x8
         cmp       cx,8                     ; je font 8x8 ?
         je        Int105                   ; je font 8x8
         mov       bx,offset Font14         ; font 8x14 a 8x16
         lds       si,cs:[Adrst14]          ; standardn¡ font 8x14
         cmp       cx,14
         je        Int105                   ; je font 8x14
         lds       si,cs:[Adrst16]          ; standardn¡ font 8x16
         cmp       cx,16
         je        Int105
         lds       si,cs:[Adrst19]          ; standardn¡ font 8x19
         cmp       cx,19
         jne       Int106                   ; nen¡ ani font 8x16

; ------ p©edefinov n¡ font–

Int105:  mov       word ptr cs:[PrevCh44+2],0 ; z kladn¡ blok
         push      bp
         call      Defin                    ; definov n¡ n rodn¡ch font–
         pop       bp
         cmp       cx,19
         jne       Int106
         lds       si,cs:[Adrst190]         ; font 8x19 zv˜raznˆn˜
         mov       word ptr cs:[PrevCh44+2],32*256
         call      Defin

; ------ zpˆtn‚ nastaven¡ videom¢du

Int106:  call      InitRegT                 ; inicializace registr– pro text

; ------ n vrat registr–

Int109:  pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int10    ENDP

; -----------------------------------------------------------------------------
;        p©edefinov n¡ n rodn¡ch font–
; -----------------------------------------------------------------------------
; VSTUP: CS:BP=defini‡n¡ tabulka k¢du
;        CS:BX=vlastn¡ fonty
;        CX=po‡et linek na znak
;        DS:SI=standardn¡ fonty
; -----------------------------------------------------------------------------

Defin    PROC      NEAR

         mov       ax,0a000h                ; segment videopamˆti
         mov       es,ax                    ; segment videopamˆti
         mov       dh,80h                   ; po‡ te‡n¡ ukazatel znak–

; ------ test konce tabulky

Tabel1:  mov       ax,cs:[bp]               ; definice z tabulky
         add       bp,2                     ; zv˜¨en¡ ukazatele
         or        ax,ax                    ; je konec tabulky ?
         jnz       Tabel2                   ; nen¡ je¨tˆ konec tabulky
         ret

; ------ proveden¡ skoku

Tabel2:  push      ax
         and       al,7                     ; d‚lka skoku
         add       dh,al                    ; zv˜¨en¡ ‡¡sla znaku
         pop       ax

; ------ p©evod znaku

         shr       al,1
         shr       al,1
         shr       al,1                     ; ‡¡slo fontu (0 a‘ 31)
         mov       dl,ah                    ; standardn¡ znak
         call      PrevCh                   ; p©evod znaku
         inc       dh                       ; zv˜¨en¡ ukazatele
         jmp       short Tabel1             ; dal¨¡ font

Defin    ENDP

; -----------------------------------------------------------------------------
;     P©evod znaku
; -----------------------------------------------------------------------------
; VSTUP: ES=segment videopamˆti
;        DS:SI=standardn¡ fonty
;        CS:BX=vlastn¡ fonty
;        CX=po‡et linek na znak
;        DL=standardn¡ znak
;        DH=m¡sto k ulo‘en¡
;        AL=‡¡slo fontu 0 a‘ 31
;        ES=segment k ulo‘en¡ znak–
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, DI
; -----------------------------------------------------------------------------

PrevCh   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         cld                                ; smˆr nahoru

; ------ adresa vlastn¡ho fontu

Prevch0: dec       al
         js        Prevch4                  ; font nalezen
         push      ax
         mov       al,cs:[bx]               ; definice fontu
         inc       bx
         and       ax,0fh                   ; d‚lka fontu
         add       bx,ax                    ; zv˜¨en¡ adresy fontu
         pop       ax
         jmp       short Prevch0            ; dal¨¡ font

; ------ adresa m¡sta ulo‘en¡ znaku ES:DI

Prevch4: mov       al,32                    ; po‡et bajt– na znak ve fontech
         mul       dh                       ; offset ve videopamˆti
         mov       di,ax                    ; adresa znaku ve videopamˆti
PrevCh44:add       di,1234h                 ; korekce pro blok

; ------ adresa standardn¡ho fontu DS:SI

         mov       al,cl                    ; po‡et linek na znak
         mul       dl                       ; offset v tabulce stand. znak–
         add       si,ax                    ; adresa v tabulce stand. znak–

; ------ po‡ te‡n¡ a koncov  linka fontu

         mov       dl,cs:[bx]               ; po‡ te‡n¡ linka a d‚lka
         inc       bx                       ; zv˜¨en¡ adresy
         mov       dh,dl                    ; kopie do DH
         and       dl,0fh                   ; DL=d‚lka 0 a‘ 15
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; DH=po‡ te‡n¡ linka 0 a‘ 15

; ------ korekce pro fonty 16x8 a 19x8

         cmp       cl,14
         jbe       Prevch5

         cmp       cl,19
         jb        Prevch55
         or        dh,dh
         jz        PrevCh55
         add       dh,2
         cmp       dh,8
         jbe       Prevch55
         inc       dh
Prevch55:cmp       dh,8
         jb        Prevch5                  ; je v horn¡ polovinˆ
         add       dh,2                     ; zv˜¨en¡ pozice

; ------ korekce horn¡ch linek pro 8x8

Prevch5: or        dl,dl                    ; je nˆjak˜ font ?
         jz        Prevch8                  ; nen¡ ‘ dn˜ font - nen¡ korekce
         cmp       dh,4                     ; je font dole ?
         jae       Prevch8                  ; je font dole - nen¡ korekce
         inc       si
         mov       ax,100h                  ; korekce pro font 8x8
         cmp       cl,8                     ; je font 8x8 ?
         je        Prevch7                  ; nen¡ font 8x8
         dec       si
Prevch8: mov       ah,-1                    ; nen¡ korekce pro ostatn¡ znaky

; ------ p©evod jednoho znaku

Prevch1: lodsb                              ; bajt standardn¡ho fontu
         dec       ah                       ; korekce pro fonty 8x8
         jnz       Prevch7                  ; nen¡ prvn¡ bajt
         or        al,ds:[si-2]             ; + bajt z p©ede¨l‚ linky
Prevch7: dec       dh                       ; ‡¡ta‡ po‡ te‡n¡ linky
         jns       Prevch2                  ; je pod po‡ te‡n¡ linkou
         dec       dl                       ; ‡¡ta‡ po‡tu linek
         js        Prevch2                  ; je nad koncovou linkou
         or        al,cs:[bx]               ; slou‡en¡ s vlatn¡m znakem

         cmp       byte ptr cs:[PrevCh44+3],0
         je        PrevCh22
         push      dx
         mov       dl,cs:[bx]
         shl       dl,1
         or        al,dl
         pop       dx
Prevch22:

         inc       bx                       ; zv˜¨en¡ adresy vlastn¡ho fontu
Prevch2: stosb                              ; ulo‘en¡ do videopamˆti
         loop      Prevch1                  ; dal¨¡ bajt

; ------ n vrat registr–

Prevch3: pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

PrevCh   ENDP

; -----------------------------------------------------------------------------
;     Inicializace registr– videokarty na re‘im definice font–
; -----------------------------------------------------------------------------

InitRegF PROC      NEAR

         mov       cl,4                     ; nastaven¡ mapov n¡ pro fonty
         mov       bx,407h                  ; BH=roviny, BL=prokl d n¡
         jmp       short InitReg            ; inicializace registr–

InitRegF ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty na textov˜ videom¢d
; -----------------------------------------------------------------------------

InitRegT PROC      NEAR

         mov       cl,cs:[RegMap]           ; registr pro mapov n¡
         mov       bx,303h                  ; BH=roviny, BL=prokl d n¡

InitRegT ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty
; -----------------------------------------------------------------------------
; VSTUP: BH=nastaven¡ rovin
;        BL=nastaven¡ prokl d n¡
;        CL=nastaven¡ mapov n¡
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, DX
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ volba rovin pro z pis (maska)

         mov       dx,3c4h                  ; b zov  adresa 03c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,bh                    ; roviny
         out       dx,al
         dec       dx                       ; nastaven¡ rovin pro z pis

; ------ nastav. prokl d n¡ bajt– sud /lich 

         mov       al,4
         out       dx,al
         inc       dx
         mov       al,bl                    ; prokl d n¡
         out       dx,al                    ; nastaven¡ prokl d n¡ bajt–

; ------ nastaven¡ mapov n¡ videopamˆti

         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         out       dx,al
         inc       dx
         mov       al,cl                    ; nastaven¡ mapov n¡
         out       dx,al                    ; registr 6: mapov n¡ videopamˆti
         ret

InitReg  ENDP

; *****************************************************************************
;                              Tabulky
; *****************************************************************************

font8    label     byte                     ; fonty 8x8
         db        2,0ch,18h                ; carv: ‡ rka pro velk  p¡smena
         db        2,0ch,18h                ; carm: ‡ rka pro mal  p¡smena
         db        2,3,3                    ; carp: ‡ rka po prav‚ stranˆ
         db        2,30h,18h                ; zcarv: zpˆtn  ‡ rka pro velk  p¡s.
         db        2,30h,18h                ; zcarm: zpˆtn  ‡ rka pro mal  p¡sm.
         db        2,6ch,38h                ; hacv: h ‡ek pro velk  p¡smena
         db        2,6ch,38h                ; hacm: h ‡ek pro mal  p¡smena
         db        2,5,6                    ; hacp: h ‡ek po prav‚ stranˆ
         db        3,10h,28h,10h            ; krov: krou‘ek nad velk˜m "U"
         db        3,38h,6ch,38h            ; krom: krou‘ek nad mal˜m "u"
         db        1,0feh                   ; strv: st©¡¨ka nad velk˜m p¡smenem
         db        32h,30h,0c0h             ; skrl: p©e¨krtnut¡ vlevo
         db        32h,18h,60h              ; skrs: p©e¨krtnut¡ uprost©ed
         db        12h,6,18h                ; skrp: p©e¨krtnut¡ vpravo
         db        2,66h,0cch               ; dvov: dvoj‡ rka nad velk˜m p¡sm.
         db        2,66h,0cch               ; dvom: dvoj‡ rka nad mal˜m p¡sm.
         db        62h,8,0eh                ; patr: pati‡ka vpravo
         db        62h,10h,1ch              ; pats: pati‡ka uprost©ed
         db        62h,18h,38h              ; ocap: oc sek uprost©ed
         db        1,18h                    ; tecv: te‡ka nad velk˜m p¡smenem
         db        1,18h                    ; tecm: te‡ka nad mal˜m p¡smenem
         db        2,0c6h,7ch               ; misv: miska nad velk˜m p¡smenem
         db        2,0c6h,7ch               ; mism: miska nad mal˜m p¡smenem
         db        7,0c6h,7ch,0c6h,0c6h,0c6h,7ch,0c6h ; spc1: rubl
         db        1,66h                    ; dvot: dvojte‡ka
         db        0                        ; nofn: konec tabulky


font14   label     byte                     ; fonty 8x14 a 8x16
         db        2,0ch,18h                ; carv: ‡ rka pro velk  p¡smena
         db        13h,0ch,18h,30h          ; carm: ‡ rka pro mal  p¡smena
         db        3,3,3,2                  ; carp: ‡ rka po prav‚ stranˆ
         db        2,30h,18h                ; zcarv: zpˆtn  ‡ rka pro velk  p¡s.
         db        13h,30h,18h,0ch          ; zcarm: zpˆtn  ‡ rka pro mal  p¡sm.
         db        3,66h,3ch,18h            ; hacv: h ‡ek pro velk  p¡smena
         db        13h,66h,3ch,18h          ; hacm: h ‡ek pro mal  p¡smena
         db        3,1bh,0eh,8              ; hacp: h ‡ek po prav‚ stranˆ
         db        3,10h,28h,10h            ; krov: krou‘ek nad velk˜m "U"
         db        13h,38h,6ch,38h          ; krom: krou‘ek nad mal˜m "u"
         db        2,7eh,0c3h               ; strv: st©¡¨ka nad velk˜m p¡smenem
         db        52h,30h,0c0h             ; skrl: p©e¨krtnut¡ vlevo
         db        52h,0ch,30h              ; skrs: p©e¨krtnut¡ uprost©ed
         db        32h,6,18h                ; skrp: p©e¨krtnut¡ vpravo
         db        2,33h,66h                ; dvov: dvoj‡ rka nad velk˜m p¡sm.
         db        22h,33h,66h              ; dvom: dvoj‡ rka nad mal˜m p¡sm.
         db        094h,8,8,8,0eh           ; patr: pati‡ka vpravo
         db        094h,10h,10h,10h,1ch     ; pats: pati‡ka uprost©ed
         db        0a4h,18h,18h,0ch,38h     ; ocap: oc sek uprost©ed
         db        2,18h,18h                ; tecv: te‡ka nad velk˜m p¡smenem
         db        22h,18h,18h              ; tecm: te‡ka nad mal˜m p¡smenem
         db        2,0c6h,7ch               ; misv: miska nad velk˜m p¡smenem
         db        22h,0c6h,7ch             ; mism: miska nad mal˜m p¡smenem
         db        47h,0c6h,7ch,0c6h,0c6h,0c6h,7ch,0c6h ; spc1: rubl
         db        1,66h                    ; dvot: dvojte‡ka
         db        0                        ; nofn: konec tabulky

carv     equ       00h                      ; ‡ rka pro velk  p¡smena
carm     equ       08h                      ; ‡ rka pro mal  p¡smena
carp     equ       10h                      ; ‡ rka po prav‚ stranˆ
zcarv    equ       18h                      ; zpˆtn  ‡ rka pro velk  p¡smena
zcarm    equ       20h                      ; zpˆtn  ‡ rka pro mal  p¡smena
hacv     equ       28h                      ; h ‡ek pro velk  p¡smena
hacm     equ       30h                      ; h ‡ek pro mal  p¡smena
hacp     equ       38h                      ; h ‡ek po prav‚ stranˆ
krov     equ       40h                      ; krou‘ek nad velk˜m "U"
krom     equ       48h                      ; krou‘ek nad mal˜m "u"
strv     equ       50h                      ; st©¡¨ka nad velk˜m p¡smenem
skrl     equ       58h                      ; p©e¨krnut¡ vlevo
skrs     equ       60h                      ; p©e¨krtnut¡ uprost©ed
skrp     equ       68h                      ; p©e¨krtnut¡ vpravo
dvov     equ       70h                      ; dvoj‡ rka nad velk˜m p¡smenem
dvom     equ       78h                      ; dvoj‡ rka nad mal˜m p¡smenem
patr     equ       80h                      ; pati‡ka vpravo
pats     equ       88h                      ; pati‡ka uprost©ed
ocap     equ       90h                      ; oc sek uprost©ed
tecv     equ       98h                      ; te‡ka nad velk˜m p¡smenem
tecm     equ       0a0h                     ; te‡ka nad mal˜m p¡smenem
misv     equ       0a8h                     ; miska nad velk˜m p¡smenem
mism     equ       0b0h                     ; miska nad mal˜m p¡smenem
spc1     equ       0b8h                     ; speci ln¡ znak - rubl
dvot     equ       0c0h                     ; dvojte‡ka

nofn     equ       0c8h                     ; konec tabulky


TabKoi   label     byte                     ; defini‡n¡ tabulka KOI 8
         db        nofn+1,151               ; "u" se zpˆtnou ‡ rkou
         db        nofn,138                 ; "e" se zpˆtnou ‡ rkou
         db        nofn,21                  ; paragraf
         db        nofn,225                 ; beta
         db        nofn,156                 ; libra
         db        nofn,146                 ; "A" ve vichru
         db        nofn,237                 ; ¨krtnut‚ nekone‡no
         db        nofn,143                 ; "A" s krou‘kem
         db        nofn,145                 ; "z" pokroucen‚
         db        nofn,237                 ; ¨krtnut‚ nekone‡no
         db        nofn,134                 ; "a" s krou‘kem
         db        nofn+1,176               ; "°"
         db        spc1,' '                 ; rubl
         db        nofn,149                 ; "o" se zpˆtnou ‡ rkou
         db        nofn,141                 ; "i" se zpˆtnou ‡ rkou
         db        nofn,158                 ; "Pt"
         db        nofn,173                 ; obr cen˜ vyk©i‡n¡k
         db        nofn,165                 ; "N" s vlnovkou
         db        nofn,168                 ; obr cen˜ otazn¡k
         db        nofn,164                 ; "n" s vlnovkou
         db        nofn,219                 ; "Û"
         db        nofn,220                 ; "Ü"
         db        nofn,223                 ; "ß"
         db        nofn,186                 ; "º"
         db        nofn,187                 ; "»"
         db        nofn,188                 ; "¼"
         db        nofn,200                 ; "È"
         db        nofn,201                 ; "É"
         db        nofn,205                 ; "Í"
         db        nofn,177                 ; "±"
         db        nofn,240                 ; "ð"
         db        nofn,241                 ; "ñ"
         db        nofn,242                 ; "ò"
         db        nofn,243                 ; "ó"
         db        nofn,244                 ; "ô"
         db        nofn,245                 ; "õ"
         db        nofn,246                 ; "ö"
         db        nofn,247                 ; "÷"
         db        nofn,248                 ; "ø"
         db        nofn,251                 ; "û"
         db        nofn,253                 ; "ý"
         db        nofn,171                 ; polovina
         db        nofn,172                 ; ‡tvrtina
         db        nofn,21                  ; paragraf
         db        nofn+2,224               ; "à"
         db        nofn,225                 ; "á"
         db        nofn,226                 ; "â"
         db        nofn,227                 ; "ã"
         db        nofn,228                 ; "ä"
         db        nofn,229                 ; "å"
         db        nofn,230                 ; "æ"
         db        nofn,231                 ; "ç"
         db        nofn,232                 ; "è"
         db        nofn,233                 ; "é"
         db        nofn,234                 ; "ê"
         db        nofn,235                 ; "ë"
         db        nofn,236                 ; "ì"
         db        nofn,237                 ; "í"
         db        nofn,238                 ; "î"
         db        nofn,239                 ; "ï"
         db        nofn,218                 ; "Ú"
         db        nofn,160                 ; " "
         db        nofn,192                 ; "À"
         db        hacm,'c'                 ; "c" s h ‡kem
         db        hacv,'d'                 ; "d" s h ‡kem
         db        hacm,'e'                 ; "e" s h ‡kem
         db        carm,'r'                 ; "r" s ‡ rkou
         db        nofn,196                 ; "Ä"
         db        nofn,129                 ; ""
         db        nofn,161                 ; "¡"
         db        krom,'u'                 ; "u" s krou‘kem
         db        carp,'l'                 ; "l" s ‡ rkou
         db        hacp,'l'                 ; "l" s h ‡kem
         db        nofn,148                 ; "o" s dvojte‡kou
         db        hacm,'n'                 ; "n" s h ‡kem
         db        nofn,162                 ; "o" s ‡ rkou
         db        nofn,147                 ; "o" se st©¡¨kou
         db        nofn,132                 ; "a" s dvojte‡kou
         db        hacm,'r'                 ; "r" s h ‡kem
         db        hacm,'s'                 ; "s" s h ‡kem
         db        hacp,'t'                 ; "t" s h ‡kem
         db        nofn,163                 ; "u" s ‡ rkou
         db        nofn,195                 ; "Ã"
         db        nofn,130                 ; "e" s ‡ rkou
         db        nofn,133                 ; "a" se zpˆtnou ‡ rkou
         db        carm,'y'                 ; "y" s ‡ rkou
         db        hacm,'z'                 ; "z" s h ‡kem
         db        nofn,194                 ; "Â"
         db        nofn,220                 ; "Ü"
         db        nofn,223                 ; "ß"
         db        nofn,205                 ; "Í"
         db        nofn,197                 ; "Å"
         db        nofn,191                 ; "¿"
         db        carv,'A'                 ; "A" s ‡ rkou
         db        nofn,217                 ; "Ù"
         db        hacv,'C'                 ; "C" s h ‡kem
         db        hacv,'D'                 ; "D" s h ‡kem
         db        hacv,'E'                 ; "E" s h ‡kem
         db        carv,'R'                 ; "R" s ‡ rkou
         db        nofn,179                 ; "³"
         db        nofn,154                 ; "š"
         db        carv,'I'                 ; "I" s ‡ rkou
         db        krov,'U'                 ; "U" s krou‘kem
         db        carp,'L'                 ; "L" s ‡ rkou
         db        hacp,'L'                 ; "L" s h ‡kem
         db        nofn,153                 ; "O" s dvojte‡kou
         db        hacv,'N'                 ; "N" s h ‡kem
         db        carv,'O'                 ; "O" s ‡ rkou
         db        strv,'O'                 ; "O" se st©¡¨kou
         db        nofn,142                 ; "A" s dvojte‡kou
         db        hacv,'R'                 ; "R" s h ‡kem
         db        hacv,'S'                 ; "S" s h ‡kem
         db        hacv,'T'                 ; "T" s h ‡kem
         db        carv,'U'                 ; "U" s ‡ rkou
         db        nofn,180                 ; "´"
         db        carv,'E'                 ; "E" s ‡ rkou
         db        zcarv,'A'                ; "A" se zpˆtnou ‡ rkou
         db        carv,'Y'                 ; "Y" s ‡ rkou
         db        hacv,'Z'                 ; "Z s h ‡kem
         db        nofn,193                 ; "Á"
         db        nofn,252                 ; "ü"
         db        nofn,250                 ; "ú"
         dw        0
TabKoi0  label     byte

; *****************************************************************************
;                         Instalace programu
; *****************************************************************************


Instal:  mov       ds:[SegRez],ds           ; segment tohoto programu

; ------ nalezen¡ syst‚mov‚ promˆnn‚ CSKOD

         mov       es,ds:[2ch]              ; segment prost©ed¡
         xor       di,di                    ; ukazatel prost©ed¡
         xor       al,al                    ; AL <- 0
Inst12:  cmp       byte ptr es:[di],0       ; konec prost©ed¡ ?
         je        Inst19                   ; konec prost©ed¡
         mov       cx,6                     ; d‚lka textu CSKOD=
         mov       si,offset SetCSKod       ; text CSKOD=
         call      Srovnej                  ; porovn n¡ textu
         je        Inst14                   ; promˆnn  byla nalezena

; ------ nalezen¡ dal¨¡ promˆnn‚

         cld
         mov       ch,80h                   ; max. d‚lka = 32 KB
         repne     scasb                    ; nalezen¡ dal¨¡ promˆnn‚
         jmp       short Inst12             ; test dal¨¡ promˆnn‚

; ------ rozli¨en¡ nastaven‚ho k¢du

Inst14:  add       di,6                     ; adresa za‡ tku parametru
         mov       si,offset SetKod         ; za‡ tek tabulky k¢d–
Inst16:  mov       cx,3                     ; d‚lka textu
         call      Srovnej                  ; porovn n¡ text–
         je        Inst18                   ; k¢d nalezen
         add       si,3                     ; dal¨¡ k¢d
         inc       ax                       ; dal¨¡ k¢d
         cmp       al,3                     ; maxim ln¡ k¢d
         jbe       Inst16                   ; test dal¨¡ho k¢du
         jmp       short Inst19             ; k¢d nenalezen

; ------ k¢d byl nalezen

Inst18:  mov       byte ptr ds:[FontTab],al ; implicitn¡ k¢d

; ------ test, zda je program ji‘ nainstalov n, test karty EGA/VGA

Inst19:  push      cs
         pop       es
         mov       ah,12h                   ; funkce informac¡ EGA
         mov       bx,3e10h                 ; podfunkce - test instalace
         int       10h                      ; informace o kartˆ EGA
         cmp       bl,6                     ; kontrola navr cen‚ho £daje
         jb        Instal1                  ; je displej EGA/VGA

; ------ chyba - nen¡ karta EGA/VGA

         mov       dx,offset ErrTxt         ; chyba - nen¡ karta EGA/VGA
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

Instal1: push      cs
         pop       ds                       ; DS <- CS
         mov       es,ds:[SegRez]           ; segment rezidentn¡ ‡ sti
         mov       dx,offset Help           ; n povˆda
         mov       si,81h                   ; za‡ tek textu
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak– zad n¡
         cld                                ; smˆr nahoru

; ------ vypu¨tˆn¡ oddˆlova‡– (mezer a tabel tor–)

Instal3: jcxz      Instal6                  ; nen¡ ji‘ dal¨¡ znak
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; oddˆlovac¡ znak ?
         jbe       Instal3                  ; je oddˆlovac¡ znak - p©esko‡en¡
         cmp       al,"/"
         je        Instal3                  ; oddˆlova‡ parametr– - vypu¨tˆn¡
         or        al,20h                   ; p©evod na mal‚ p¡smeno

; ------ parametr /K - k¢d Kamenick˜ch

         cmp       al,"k"                   ; k¢d Kamenick˜ch ?
         jne       Instal4                  ; nen¡ k¢d Kamenick˜ch
         mov       byte ptr es:[FontTab],1  ; k¢d Kamenick˜ch
         jmp       short Instal3            ; dal¨¡ znak

; ------ parametr /L - k¢d Latin 2

Instal4: cmp       al,"l"                   ; k¢d Latin 2 ?
         jne       Instal5                  ; nen¡ k¢d Latin 2
         mov       byte ptr es:[FontTab],2  ; k¢d Latin 2
         jmp       short Instal3            ; dal¨¡ znak

; ------ parametr /I - k¢d KOI 8

Instal5: cmp       al,"i"                   ; k¢d KOI 8 ?
         jne       Instal52                 ; nen¡ k¢d KOI 8
         mov       byte ptr es:[FontTab],3  ; k¢d KOI 8
         jmp       short Instal3            ; dal¨¡ znak

; ------ parametr /0 - vypnut¡ font–

Instal52:cmp       al,"0"                   ; vypnut¡ obsluhy ?
         jne       Instal53
         mov       byte ptr es:[FontTab],0  ; standardn¡ k¢d IBM
         jmp       short Instal3            ; dal¨¡ znak

; ------ parametr /! - odinstalov n¡ z pamˆti

Instal53:cmp       al,"!"                   ; odinstalov n¡ ?
         jne       Chyba                    ; chyba zad n¡
         mov       word ptr ds:[OdIns],1    ; p©¡znak odinstalov n¡
         jmp       short Instal3

; ------ kontrola, zda je to prvn¡ instalace

Instal6: mov       ax,cs
         cmp       ax,ds:[SegRez]           ; je program nainstalovan˜ ?
         je        Instal7                  ; je to prvn¡ instalace

; ------ nem -li b˜t odinstalov n¡ pouze zobrazen¡ informa‡n¡ho textu

         cmp       byte ptr ds:[OdIns],0    ; m  b˜t odinstalov n¡ ?
         je        Inst67                   ; nem  b˜t odinstalov n¡ - konec

; ------ kontrola, zda lze odinstalovat

         mov       ax,3510h                 ; funkce poskytnut¡ INT 10h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       dx,offset ErrDIns        ; text - nelze odinstalovat
         cmp       bx,offset Int10          ; je offset INT 10h ?
         jne       Inst66                   ; chyba - nelze odinstalovat
         mov       ax,es                    ; segment INT 10h
         cmp       ax,ds:[SegRez]           ; je segment OK ?
         jne       Inst66                   ; nelze odinstalovat

; ------ n vrat vektoru p©eru¨en¡ INT 10h

         mov       es,ds:[SegRez]           ; sezidentn¡ segment
         push      ds
         lds       dx,es:[Old10]            ; p–vodn¡ adresa INT 10h
         mov       ax,2510h                 ; funkce nastaven¡ vektoru p©eru¨en¡
         int       21h                      ; n vrat vektoru p©eru¨en¡ INT 10h
         pop       ds

; ------ uvolnˆn¡ segmentu pamˆti

         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ bloku pamˆti

; ------ hl ¨en¡ o odinstalov n¡ programu

         mov       dx,offset DInsTxt        ; text - byl odinstalov n
Inst66:  mov       ah,9
         int       21h                      ; zobrazen¡ textu
         int       20h                      ; konec programu

; ------ zobrazen¡ informa‡n¡ho textu, konec

Inst67:  call      Inform                   ; zobrazen¡ informa‡n¡ho textu
Inst68:  int       20h                      ; konec programu

; ------ prvn¡ instalace - nelze odinstalovat

Instal7: mov       dx,offset ErrDIn2        ; text - nebyl nainstalov n
         cmp       byte ptr ds:[OdIns],0    ; po‘adov no odinstalov n¡ ?
         jne       Inst66                   ; po‘adov no odinstalov n¡

; ------ zji¨tˆn¡ adres syst‚mov˜ch font–

         mov       di,offset Adrst8         ; adresy syst‚mov˜ch font–
         mov       bh,3                     ; fonty 8x8
         call      DetFont                  ; detekce fontu 8x8
         mov       bh,2                     ; fonty 8x14
         call      DetFont                  ; detekce fontu 8x14
         mov       bh,6                     ; font 8x16
         call      DetFont                  ; detekce fontu 8x16
         mov       bh,8                     ; font 8x19
         call      DetFont                  ; detekce fontu 8x19
         mov       bh,12                    ; font 8x19 zv˜raznˆn˜
         call      DetFont                  ; detekce fontu 8x19 zv˜raz.

; ------ £schova p–vodn¡ adresy INT 10h

         push      es
         mov       ax,3510h                 ; funkce poskytnut¡ adresy INT 10h
         int       21h
         mov       word ptr ds:[Old10],bx   ; £schova offsetu INT 10h
         mov       word ptr ds:[Old10+2],es ; £schova segmentu INT 10h

; ------ instalace nov‚ obsluhy INT 10h

         mov       dx,offset Int10          ; vlastn¡ obsluha INT 10h
         mov       ax,2510h
         int       21h                      ; instalace vlastn¡ obsluhy INT 10h

; ------ uvolnˆn¡ pamˆŸov‚ho bloku segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ bloku pamˆti
         pop       es

; ------ zobrazen¡ informa‡n¡ho textu

         call      Inform                   ; zobrazen¡ informa‡n¡ho textu

; ------ instalace programu

         mov       dx,offset Instal         ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu

; -----------------------------------------------------------------------------
;        porovn n¡ vzoru s textem v prost©ed¡
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel textu v prost©ed¡
;        DS:SI=ukazatel vzorov‚ho textu (velk  p¡smena)
;        CX=po‡et znak– k porovn n¡
; VSTUP:ZY=text souhlas¡
; -----------------------------------------------------------------------------
; zni‡en‚ registry: CX
; -----------------------------------------------------------------------------

Srovnej  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      si
         push      di

; ------ porovn n¡ text–

         cld
Srovn1:  mov       al,es:[di]               ; znak z prost©ed¡
         cmp       al,"a"
         jb        Srovn2                   ; nen¡ mal‚ p¡smeno
         cmp       al,"z"
         ja        Srovn2                   ; nen¡ mal‚ p¡smeno
         and       al,not 20h               ; korekce na velk‚ p¡smeno
Srovn2:  cmp       al,ds:[si]               ; porovn n¡ se vzorem
         jne       Srovn9                   ; nesouhlas¡
         inc       di
         inc       si
         loop      Srovn1                   ; porovn n¡ dal¨¡ho znaku
         cmp       al,al                    ; nastaven¡ p©¡znaku shody

; ------ n vrat registr–

Srovn9:  pop       di
         pop       si
         pop       ax
         ret

Srovnej  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ informa‡n¡ho textu (ES=segment EGACSmin)
; -----------------------------------------------------------------------------

Inform   PROC      NEAR

; ------ stanoven¡ adresy font–

         xor       ax,ax
         mov       al,es:[FontTab]          ; ‡¡slo tabulky font–
         mov       si,offset TabKam         ; ‡e¨tina Kamenick˜ch
         mov       cx,offset(TabKam0-TabKam) ; d‚lka tabulky
         dec       ax                       ; je ‡e¨tina Kamenick˜ch ?
         jz        Inform1                  ; ‡e¨tina Kamenick˜ch
         mov       si,offset TabLat         ; ‡e¨tina Latin 2
         mov       cx,offset(TabLat0-TabLat) ; d‚lka tabulky
         dec       ax                       ; je ‡e¨tina Latin 2 ?
         jz        Inform1                  ; je ‡e¨tina Latin 2
         mov       si,offset TabKoi         ; jinak KOI 8
         mov       cx,offset(TabKoi0-TabKoi) ; d‚lka tabulky

; ------ p©enos tabulky font–

Inform1: cld
         mov       di,offset TabKoi
         rep       movsb                    ; p©enos tabulky

; ------ £schova videom¢du

         push      es                       ; segment aktivn¡ho EGACSmin
         mov       ah,0fh
         int       10h                      ; dotaz na sou‡asn˜ videom¢d
         mov       cs:[OldVMod],al
         push      ax                       ; £schova videom¢du

; ------ £schova pozice kurzoru

         mov       ah,3
         int       10h                      ; poskytnut¡ pozice kurzoru
         pop       ax                       ; n vrat aktivn¡ho videom¢du
         push      dx                       ; £schova pozice kurzoru

; ------ p©edefinov n¡ videom¢du

         or        al,80h                   ; displej se nema‘e
         xor       ah,ah
         int       10h                      ; nov‚ nastaven¡ videom¢du

; ------ zru¨en¡ p©¡znaku nemazat displej

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[449h],not 80h ; zru¨en¡ p©¡znaku nemazat displej
         and       byte ptr ds:[487h],not 80h ; zru¨en¡ p©¡znaku nemazat displej
         pop       ds

; ------ n vrat pozice kurzoru

         pop       dx                       ; n vrat pozice kurzoru
         mov       ah,2
         int       10h                      ; n vrat pozice kurzoru

; ------ pro LCD p©edefinov n¡

         mov       ax,1130h
         mov       bl,4
         int       10h
         cmp       cx,19
         jne       Infor23
         mov       al,cs:[OldVMod]
         xor       ah,ah
         int       10h

; ------ zobrazen¡ £vodn¡ ‡ sti informa‡n¡ho textu

Infor23: pop       es
         mov       dx,offset UvTxt          ; prvn¡ ‡ st textu
         mov       ah,9
         int       21h                      ; zobrazen¡ prvn¡ ‡ sti textu

; ------ rozli¨en¡ druh‚ ‡ sti informa‡n¡ho textu

         xor       ax,ax
         mov       al,es:[FontTab]          ; ‡¡slo tabulky font–
         mov       dx,offset UvTxtK         ; ‡e¨tina Kamenick˜ch
         dec       ax                       ; je ‡e¨tina Kamenick˜ch ?
         jz        Inform2                  ; ‡e¨tina Kamenick˜ch
         mov       dx,offset UvTxtL         ; ‡e¨tina Latin 2
         dec       ax                       ; je ‡e¨tina Latin 2 ?
         jz        Inform2                  ; je ‡e¨tina Latin 2
         mov       dx,offset UvTxtI         ; ‡e¨tina KOI 8
         dec       ax                       ; je ‡e¨tina KOI 8 ?
         jz        Inform2                  ; je ‡e¨tina KOI 8
         mov       dx,offset UvTxt0         ; ‡e¨tina vypnuta

; ------ zobrazen¡ druh‚ ‡ sti informa‡n¡ho textu

Inform2: mov       ah,9
         int       21h                      ; zobrazen¡ druh‚ ‡ sti textu
         ret

Inform   ENDP

; -----------------------------------------------------------------------------
;        detekce syst‚mov‚ho fontu
; -----------------------------------------------------------------------------
; VSTUP: BH=slu‘ba ke zji¨tˆn¡ ukazatele
;        ES:DI=ukl dac¡ adresa k ulo‘en¡ adresy
; VSTUP:ES:DI=nov  ukl dac¡ adresa
; -----------------------------------------------------------------------------

DetFont  PROC      NEAR

; ------ zji¨tˆn¡ adresy syst‚mov‚ tabulky font–

         push      di
         push      es
         mov       ax,1130h
         int       10h                      ; informace o fontech
         mov       ax,es                    ; segment font–
         pop       es
         pop       di

; ------ ulo‘en¡ z¡skan‚ adresy font–

         cld                                ; smˆr ulo‘en¡ nahoru
         xchg      ax,bp                    ; offset adresy
         stosw                              ; ulo‘en¡ offsetu adresy
         xchg      ax,bp                    ; segment adresy
         stosw                              ; ulo‘en¡ segmentu adresy
         ret

DetFont  ENDP

; -----------------------------------------------------------------------------
;        data instala‡n¡ ‡ sti programu
; -----------------------------------------------------------------------------

OdIns    db        0                        ; 1=p©¡znak odinstalov n¡

OldVMod  db        0

SetCSKod db        'CSKOD='
SetKod   db        'IBM'
         db        'KAM'
         db        'LAT'
         db        'KOI'

ErrTxt   db        'Neni karta EGA/VGA !',13,10,'$'

Help     db        'Zadejte:/K=Kamenickych',13,10
         db        9,'/L=Latin 2',13,10
         db        9,'/I=KOI 8',13,10
         db        9,'/0=IBM',13,10
         db        9,'/!=odinstalovani',13,10
         db        '$'

UvTxt    db        'EGACSmin V2.42 - CS fonty, $'
UvTxtK   db        'k¢d Kamenick˜ch; (c) M.Nˆme‡ek',13,10,'$'
UvTxtL   db        'k¢d Latin 2; (c) M.NØmeŸek',13,10,'$'
UvTxtI   db        'kÏd KOI 8; (c) M.NÅmeÃek',13,10,'$'
UvTxt0   db        'k¢d IBM; (c) M.Nemecek',13,10,'$'

DInsTxt  db        'EGACSmin byl odinstalovan.',13,10,'$'
ErrDIns  db        'EGACSmin nelze odinstalovat !',13,10,'$'
ErrDIn2  db        'EGACSmin nebyl dosud nainstalovan !',13,10,'$'

TabKam   label     byte                     ; defini‡n¡ tabulka Kamenick˜ch

         db        hacv,'C'                 ; "C" s h ‡kem
         db        carm+1,'e'               ; "e" s ‡ rkou
         db        hacv,'d'                 ; "d" s h ‡kem
         db        hacv+1,'D'               ; "D" s h ‡kem
         db        hacv,'T'                 ; "T" s h ‡kem
         db        hacm,'c'                 ; "c" s h ‡kem
         db        hacm,'e'                 ; "e" s h ‡kem
         db        hacv,'E'                 ; "E" s h ‡kem
         db        carp,'L'                 ; "L" s ‡ rkou
         db        carv,'I'                 ; "I" s ‡ rkou
         db        hacp,'l'                 ; "l" s h ‡kem
         db        carp,'l'                 ; "l" s ‡ rkou
         db        carv+1,'A'               ; "A" s ‡ rkou
         db        carv,'E'                 ; "E" s ‡ rkou
         db        hacm,'z'                 ; "z" s h ‡kem
         db        hacv,'Z'                 ; "Z" s h ‡kem
         db        carv+2,'O'               ; "O" s ‡ rkou
         db        krom,'u'                 ; "u" s krou‘kem
         db        carv,'U'                 ; "U" s ‡ rkou
         db        carm,'y'                 ; "y" s ‡ rkou
         db        hacv+2,'S'               ; "S" s h ‡kem
         db        hacp,'L'                 ; "L" s h ‡kem
         db        carv,'Y'                 ; "Y" s ‡ rkou
         db        hacv,'R'                 ; "R" s h ‡kem
         db        hacp,'t'                 ; "t" s h ‡kem
         db        carm,'a'                 ; "a" s ‡ rkou
         db        carm+1,'o'               ; "o" s ‡ rkou
         db        carm,'u'                 ; "u" s ‡ rkou
         db        hacm,'n'                 ; "n" s h ‡kem
         db        hacv,'N'                 ; "N" s h ‡kem
         db        krov,'U'                 ; "U" s krou‘kem
         db        strv,'O'                 ; "O" se st©¡¨kou
         db        hacm,'s'                 ; "s" s h ‡kem
         db        hacm,'r'                 ; "r" s h ‡kem
         db        carm,'r'                 ; "r" s ‡ rkou
         db        carv,'R'                 ; "R" s ‡ rkou
         db        nofn+1,21                ; paragraf
         dw        0

TabKam0  label     byte


TabLat   label     byte                     ; defini‡n¡ tabulka Latin 2

         db        carm+2,'e'               ; "e" s ‡ rkou
         db        krom+2,'u'               ; "u" s kou‘kem
         db        carm,'c'                 ; "c" s ‡ rkou
         db        ocap,'c'                 ; "c" s oc skem
         db        skrs,'l'                 ; "l" p©e¨krtnut‚
         db        dvov+1,'O'               ; "O" s dvoj‡ rkou
         db        dvom,'o'                 ; "o" s dvoj‡ rkou
         db        carv+1,'Z'               ; "Z" s ‡ rkou
         db        carv+1,'C'               ; "C" s ‡ rkou
         db        carv,'E'                 ; "E" s ‡ rkou
         db        carp,'L'                 ; "L" s ‡ rkou
         db        carp,'l'                 ; "l" s ‡ rkou
         db        hacp+2,'L'               ; "L" s h ‡kem
         db        hacp,'l'                 ; "l" s h ‡kem
         db        carv,'S'                 ; "S" s ‡ rkou
         db        carm,'s'                 ; "s" s ‡ rkou
         db        hacv+2,'T'               ; "T" s h ‡kem
         db        hacp,'t'                 ; "t" s h ‡kem
         db        skrl,'L'                 ; "L" p©e¨krtnut‚
         db        nofn,'x'                 ; p©e¨krtnut¡
         db        hacm,'c'                 ; "c" s h ‡kem
         db        carm,'a'                 ; "a" s ‡ rkou
         db        carm+1,'o'               ; "o" s ‡ rkou
         db        carm,'u'                 ; "u" s ‡ rkou
         db        patr,'A'                 ; "A" s pati‡kou
         db        pats,'a'                 ; "a" s pati‡kou
         db        hacv,'Z'                 ; "Z" s h ‡kem
         db        hacm,'z'                 ; "z" s h ‡kem
         db        pats,'E'                 ; "E" s pati‡kou
         db        pats,'e'                 ; "e" s pati‡kou
         db        carm+1,'z'               ; "z" s ‡ rkou
         db        hacv,'C'                 ; "C" s h ‡kem
         db        ocap,'s'                 ; "s" s oc skem
         db        carv+7,'A'               ; "A" s ‡ rkou
         db        strv,'A'                 ; "A" se st©¡¨kou
         db        hacv,'E'                 ; "E" s h ‡kem
         db        ocap,'S'                 ; "S" s oc skem
         db        tecv+4,'Z'               ; "Z" s te‡kou
         db        tecm,'z'                 ; "z" s te‡kou
         db        misv+7,'A'               ; "A" s miskou
         db        mism,'a'                 ; "a" s miskou
         db        spc1+7,' '               ; rubl
         db        skrp,'d'                 ; "d" p©e¨krtnut‚
         db        skrl,'D'                 ; "D" p©e¨krtnut‚
         db        hacv,'D'                 ; "D" s h ‡kem
         db        dvot,'E'                 ; "E" dvojte‡ka
         db        hacv,'d'                 ; "d" s h ‡kem
         db        hacv,'N'                 ; "N" s h ‡kem
         db        carv,'I'                 ; "I" s ‡ rkou
         db        strv,'I'                 ; "I" se st©¡¨kou
         db        hacm,'e'                 ; "e" s h ‡kem
         db        ocap+4,'T'               ; "T" s oc skem
         db        krov,'U'                 ; "U" s krou‘kem
         db        carv+1,'O'               ; "O" s ‡ rkou
         db        strv+1,'O'               ; "O" se st©¡¨kou
         db        carv,'N'                 ; "N" s ‡ rkou
         db        carm,'n'                 ; "n" s ‡ rkou
         db        hacm,'n'                 ; "n" s h ‡kem
         db        hacv,'S'                 ; "S" s h ‡kem
         db        hacm,'s'                 ; "s" s h ‡kem
         db        carv,'R'                 ; "R" s ‡ rkou
         db        carv,'U'                 ; "U" s ‡ rkou
         db        carm,'r'                 ; "r" s ‡ rkou
         db        dvov,'U'                 ; "U" s dvoj‡ rkou
         db        carm,'y'                 ; "y" s ‡ rkou
         db        carv,'Y'                 ; "Y" s ‡ rkou
         db        ocap,'t'                 ; "t" s oc skem
         db        carm,' '                 ; ‡ rka vpravo
         db        nofn,'-'                 ; poml‡ka
         db        dvom,' '                 ; dvoj‡ rka
         db        pats,' '                 ; pati‡ka
         db        hacm,' '                 ; h ‡ek
         db        mism,' '                 ; miska
         db        nofn,21                  ; paragraf
         db        ocap+1,' '               ; oc sek
         db        krom,' '                 ; krou‘ek
         db        dvot,' '                 ; dvojte‡ka
         db        dvom+1,'u'               ; "u" s dvoj‡ rkou
         db        hacv,'R'                 ; "R" s h ‡kem
         db        hacm,'r'                 ; "r" s h ‡kem
         dw        0

TabLat0  label     byte

Code     ENDS
         END       Start

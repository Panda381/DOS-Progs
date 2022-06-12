
KLIC1    EQU       0f6eh                    ; kl¡‡ 1 (AX)
KLIC2    EQU       0a6e3h                   ; kl¡‡ 2 (BX)
KLIC3    EQU       5e4dh                    ; kl¡‡ 3 (CX)
KLIC4    EQU       33eah                    ; kl¡‡ 4 (CX v˜stup)

; *****************************************************************************
;
;                                 EGACS
;              Instalace ‡esk˜ch znak– na displej EGA/VGA
;
; *****************************************************************************

KORIG    EQU       5ch-103h                 ; korekce adresy

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal                   ; instalace programu

ZacRez   label     near                     ; za‡ tek rezidentn¡ ‡ sti

Old10    dd        0                        ; p–vodn¡ adresa obsluhy INT 10h

FontTab  db        1                        ; ‡¡slo tabulky font–
                                            ;   0=bez font–
                                            ;   1=Kamenick˜ch
                                            ;   2=Latin 2
                                            ;   3=KOI 8
                                            ;   4=ISO 8859/2

RegMap   db        0                        ; nastaven¡ registru pro mapov n¡

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      FAR

; ------ test instalace programu

         pushf
         cmp       ax,KLIC1
         jne       Int101
         cmp       bx,KLIC2
         jne       Int101
         cmp       cx,KLIC3
         jne       Int101
         call      dword ptr cs:[Old10+KORIG] ; vol n¡ p–vodn¡ funkce
         push      cs
         pop       es
         mov       cx,KLIC4                 ; v˜stupn¡ identifik tor
         iret

; ------ kontrola, zda je funkce zapnuta

Int101:  cmp       byte ptr cs:[FontTab+KORIG],0 ; je nˆjak˜ font ?
         je        Int102                   ; funkce je vypnuta

; ------ rozli¨en¡, zda se maj¡ p©einstalovat fonty

         or        ah,ah                    ; je nastaven¡ m¢du displeje ?
         jz        Int103                   ; je nastaven¡ videom¢du
         cmp       ax,4f02h                 ; je nastaven¡ m¢du VESA ?
         je        Int103                   ; je nastaven¡ m¢du VESA
         cmp       ah,11h                   ; je slu‘ba obsluhy font– ?
         jne       Int102                   ; nen¡ operace s fonty

; ------ kontrola, zda je nastaven¡ font– slu‘by 11h

         test      al,0fh                   ; jsou u‘iv. fonty nebo informace ?
         jz        Int102                   ; u‘ivatelsk‚ fonty nebo informace
         cmp       al,3                     ; je nastaven¡ bloku font– ?
         jne       Int103                   ; nen¡ nastaven¡ bloku
Int102:  popf
         jmp       dword ptr cs:[Old10+KORIG]; skok na p–vodn¡ obsluhu INT 10h

; ------ fonty se p©einstaluj¡

Int103:  call      dword ptr cs:[Old10+KORIG] ; vol n¡ p–vodn¡ funkce

; ------ £schova registr–

Int1032: push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ kontrola, zda je standardn¡ textov˜ videom¢d

         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0 datov˜ segment BIOS
         mov       al,ds:[449h]             ; aktu ln¡ videom¢d
         and       al,7fh                   ; zru¨en¡ p©¡znaku nemaz n¡ displeje
         mov       ah,0eh                   ; registr mapov n¡ pro CGA
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         jbe       Int104                   ; je textov˜ m¢d CGA - OK
         mov       ah,0ah                   ; registr mapov n¡ pro MDA
         cmp       al,7                     ; je videom¢d MDA ?
         je        Int104                   ; je videom¢d MDA
         cmp       al,19
         jbe       Int109                   ; je standardn¡ grafick˜ m¢d

; ------ test, zda je textov˜ m¢d SVGA

         mov       dx,3ceh
         mov       al,6
         out       dx,al                    ; ©¡dic¡ registr
         inc       dx
         in        al,dx
         mov       ah,al                    ; £schova registru m¢du
         and       al,0fh
         cmp       al,0eh                   ; textov˜ m¢d CGA
         je        Int104                   ; je textov˜ m¢d CGA
         cmp       al,0ah                   ; textov˜ m¢d MDA
         jne       Int109                   ; nen¡ textov˜ m¢d
Int104:  mov       cs:[RegMap+KORIG],ah     ; £schova registru pro mapov n¡

; ------ nastaven¡ video©adi‡e do re‘imu definice znak–

         call      InitRegF                 ; inicializace registr– pro fonty

; ------ stanoven¡ adresy fontu podle po‡tu linek na znak

         mov       cx,ds:[485h]             ; po‡et linek na znak
         mov       bx,offset Font8+KORIG    ; font 8x8
         cmp       cx,10
         jbe       Int105                   ; je mal˜ po‡et linek na znak
         mov       bx,offset Font14+KORIG   ; font pro vˆt¨¡ znaky

; ------ p©edefinov n¡ font–

Int105:  call      Defin                    ; definov n¡ n rodn¡ch font–

; ------ zpˆtn‚ nastaven¡ videom¢du

         call      InitRegT                 ; inicializace registr– pro text

; ------ n vrat registr–

Int109:  pop       es
         pop       ds
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
; VSTUP: CS:BX=vlastn¡ fonty
;        CX=po‡et linek na znak
; -----------------------------------------------------------------------------

Defin    PROC      NEAR

         mov       si,offset TabISO+KORIG   ; tabulka definice fontu
         mov       ax,0a000h                ; segment videopamˆti
         mov       es,ax                    ; segment videopamˆti
         mov       ds,ax
         mov       dh,80h                   ; po‡ te‡n¡ ukazatel znak–

; ------ test konce tabulky

Tabel1:  mov       ax,cs:[si]               ; definice z tabulky
         inc       si
         inc       si
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
; VSTUP: ES,DS=segment videopamˆti
;        CS:BX=vlastn¡ fonty
;        DL=standardn¡ znak
;        DH=m¡sto k ulo‘en¡
;        AL=‡¡slo fontu 0 a‘ 31
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, DI
; -----------------------------------------------------------------------------

PrevCh   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         mov       ah,0
         cld                                ; smˆr nahoru

; ------ adresa vlastn¡ho fontu

Prevch0: dec       ax
         js        Prevch4                  ; font nalezen
         push      ax
         mov       al,cs:[bx]               ; definice fontu
         inc       bx
         and       al,0fh                   ; d‚lka fontu
         add       bx,ax                    ; zv˜¨en¡ adresy fontu
         pop       ax
         jmp       short Prevch0            ; dal¨¡ font

; ------ adresa m¡sta ulo‘en¡ znaku ES:DI

Prevch4: mov       al,32                    ; po‡et bajt– na znak ve fontech
         mul       dh                       ; offset ve videopamˆti
         xchg      ax,di                    ; adresa znaku ve videopamˆti

; ------ adresa standardn¡ho fontu DS:SI

         mov       al,32                    ; po‡et linek na znak
         mul       dl                       ; offset v tabulce stand. znak–
         xchg      ax,si                    ; adresa standardn¡ho znaku

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

         mov       cx,32                    ; po‡et linek k p©evodu
Prevch1: lodsb                              ; bajt standardn¡ho fontu
         dec       ah                       ; korekce pro fonty 8x8
         jnz       Prevch7                  ; nen¡ prvn¡ bajt
         or        al,ds:[si-2]             ; + bajt z p©ede¨l‚ linky
Prevch7: dec       dh                       ; ‡¡ta‡ po‡ te‡n¡ linky
         jns       Prevch2                  ; je pod po‡ te‡n¡ linkou
         dec       dl                       ; ‡¡ta‡ po‡tu linek
         js        Prevch2                  ; je nad koncovou linkou
         or        al,cs:[bx]               ; slou‡en¡ s vlatn¡m znakem
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

         mov       ah,2                     ; ‡tec¡ rovina
         mov       cx,4                     ; nastaven¡ mapov n¡ pro fonty
         mov       bx,407h                  ; BH=roviny, BL=prokl d n¡
         jmp       short InitReg            ; inicializace registr–

InitRegF ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty na textov˜ videom¢d
; -----------------------------------------------------------------------------

InitRegT PROC      NEAR

         mov       ah,0                     ; ‡tec¡ rovina
         mov       cl,cs:[RegMap+KORIG]     ; registr pro mapov n¡
         mov       ch,10h                   ; registr m¢du - prokl d n¡
         mov       bx,303h                  ; BH=roviny, BL=prokl d n¡

InitRegT ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty
; -----------------------------------------------------------------------------
; VSTUP: AH=‡tec¡ rovina (0=text, 1=atributy, 2=fonty)
;        BH=roviny k z pisu (bit 0 = text, bit 1 = atributy, bit 2 = fonty)
;        BL=nastaven¡ prokl d n¡ (3=je prokl d n¡ rovin, 7=sekven‡n¡ adresy)
;        CL=nastaven¡ mapov n¡ (04h=A000h, 0Ah=B000h, 0Eh=B800h)
;        CH=registr m¢du (0=sekven‡n¡ adresov n¡, 10h=prokl dan‚ adresov n¡)
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, DX
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ volba rovin pro z pis (maska)

         mov       dx,3c4h                  ; b zov  adresa 03c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,bh                    ; roviny k z pisu
         out       dx,al                    ; nastaven¡ rovin pro z pis

; ------ nastav. prokl d n¡ bajt– sud /lich 

         dec       dx
         mov       al,4
         out       dx,al                    ; volba registru 4
         inc       dx
         mov       al,bl                    ; prokl d n¡
         out       dx,al                    ; nastaven¡ prokl d n¡ bajt–

; ------ nastaven¡ mapov n¡ videopamˆti (adresa)

         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         out       dx,al                    ; volba registru 6
         inc       dx
         mov       al,cl                    ; nastaven¡ mapov n¡
         out       dx,al                    ; nastaven¡ mapov n¡ videopamˆti

; ------ nastaven¡ registru m¢du (‡ten¡ i z pis - M•D 0)

         dec       dx
         mov       al,5
         out       dx,al                    ; volba registru 5
         inc       dx
         mov       al,ch                    ; registr m¢du
         out       dx,al

; ------ volba roviny pro ‡ten¡

         dec       dx
         mov       al,4
         out       dx,al                    ; volba registru 4
         inc       dx
         mov       al,ah                    ; rovina ke ‡ten¡
         out       dx,al                    ; nastaven¡ roviny ke ‡ten¡
         ret

InitReg  ENDP

; *****************************************************************************
;                              Tabulky
; *****************************************************************************
;þ
font8    label     byte                     ; fonty 8x8
         db        2,0ch,18h                ; carv: ‡ rka pro velk  p¡smena
         db        2,0ch,18h                ; carm: ‡ rka pro mal  p¡smena
         db        2,3,3                    ; carp: ‡ rka po prav‚ stranˆ
         db        2,30h,18h                ; zcarv: zpˆtn  ‡ rka pro velk  p¡s.
         db        2,30h,18h                ; zcarm: zpˆtn  ‡ rka pro mal  p¡sm.
         db        2,6ch,38h                ; hacv: h ‡ek pro velk  p¡smena
         db        2,6ch,38h                ; hacm: h ‡ek pro mal  p¡smena
         db        3,3,1,2                  ; hacp: h ‡ek po prav‚ stranˆ
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
         db        4,3,3,1,2                ; hacp: h ‡ek po prav‚ stranˆ
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

TabISO   label     byte                     ; defini‡n¡ tabulka KOI 8
         db        nofn,218                 ; 128: "Ú"
         db        nofn,191                 ; 129: "¿"
         db        nofn,192                 ; 130: "À"
         db        nofn,217                 ; 131: "Ù"
         db        nofn,194                 ; 132: "Â"
         db        nofn,180                 ; 133: "´"
         db        nofn,193                 ; 134: "Á"
         db        nofn,195                 ; 135: "Ã"
         db        nofn,197                 ; 136: "Å"
         db        nofn,179                 ; 137: "³"
         db        nofn,196                 ; 138: "Ä"
         db        nofn,176                 ; 139: "°"
         db        nofn,' '                 ; 140: " "
         db        nofn,177                 ; 141: "±"
         db        nofn,178                 ; 142: "²"
         db        nofn,219                 ; 143: "Û"
         db        nofn,223                 ; 144: "ß"
         db        nofn,220                 ; 145: "Ü"
         db        nofn,174                 ; 146: "®"  ???
         db        nofn,'x'                 ; 147: "x"  ???
         db        nofn,'-'                 ; 148: "-"  ???
         db        nofn,254                 ; 149: "þ"
         db        nofn,' '                 ; 150: " "
         db        nofn,' '                 ; 151: " "
         db        nofn,' '                 ; 152: " "
         db        nofn,' '                 ; 153: " "
         db        nofn,' '                 ; 154: " "
         db        nofn,' '                 ; 155: " "
         db        nofn,' '                 ; 156: " "
         db        nofn,' '                 ; 157: " "
         db        nofn,' '                 ; 158: " "
         db        nofn,' '                 ; 159: " "
         db        nofn,' '                 ; 160: " "
         db        patr,'A'                 ; 161: "A" s pati‡kou
         db        misv,' '                 ; 162: miska nad velk˜m p¡smenem
         db        skrl,'L'                 ; 163: "L" p©e¨krtnut‚
         db        spc1,' '                 ; 164: rubl
         db        hacp,'L'                 ; 165: "L" s h ‡kem
         db        carv,'S'                 ; 166: "S" s ‡ rkou
         db        nofn,21                  ; 167: paragraf
         db        dvot,' '                 ; 168: dvojte‡ka nad znakem
         db        hacv,'S'                 ; 169: "S" s h ‡kem
         db        ocap,'S'                 ; 170: "S" s oc skem
         db        hacv,'T'                 ; 171: "T" s h ‡kem
         db        carv,'Z'                 ; 172: "Z" s ‡ rkou
         db        nofn,' '                 ; 173: " "
         db        hacv,'Z'                 ; 174: "Z" s h ‡kem
         db        tecv,'Z'                 ; 175: "Z" s te‡kou
         db        nofn,248                 ; 176: "ø"
         db        pats,'a'                 ; 177: "a" s pati‡kou
         db        pats,' '                 ; 178: pati‡ka
         db        skrs,'l'                 ; 179: "l" p©e¨krtnut‚
         db        carm,' '                 ; 180: ‡ rka vpravo
         db        hacp,'l'                 ; 181: "l" s h ‡kem
         db        carm,'s'                 ; 182: "s" s ‡ rkou
         db        hacm,' '                 ; 183: h ‡ek nad mal˜m p¡smenem
         db        ocap,' '                 ; 184: oc sek
         db        hacm,'s'                 ; 185: "s" s h ‡kem
         db        ocap,'s'                 ; 186: "s" s oc skem
         db        hacp,'t'                 ; 187: "t" s h ‡kem
         db        carm,'z'                 ; 188: "z" s ‡ rkou
         db        dvom,' '                 ; 189: dvoj‡ rka
         db        hacm,'z'                 ; 190: "z" s h ‡kem
         db        tecm,'z'                 ; 191: "z" s te‡kou
         db        carv,'R'                 ; 192: "R" s ‡ rkou
         db        carv,'A'                 ; 193: "A" s ‡ rkou
         db        strv,'A'                 ; 194: "A" se st©¡¨kou
         db        misv,'A'                 ; 195: "A" s miskou
         db        dvot,'A'                 ; 196: "A" s dvojte‡kou
         db        carv,'L'                 ; 197: "L" s ‡ rkou
         db        carv,'C'                 ; 198: "C" s ‡ rkou
         db        ocap,'C'                 ; 199: "C" s oc skem
         db        hacv,'C'                 ; 200: "C" s h ‡kem
         db        carv,'E'                 ; 201: "E" s ‡ rkou
         db        pats,'E'                 ; 202: "E" s pati‡kou
         db        dvot,'E'                 ; 203: "E" s dvojte‡kou
         db        hacv,'E'                 ; 204: "E" s h ‡kem
         db        carv,'I'                 ; 205: "I" s ‡ rkou
         db        strv,'I'                 ; 206: "I" se st©¡¨kou
         db        hacv,'D'                 ; 207: "D" s h ‡kem
         db        skrl,'D'                 ; 208: "D" p©e¨krtnut‚
         db        carv,'N'                 ; 209: "N" s ‡ rkou
         db        hacv,'N'                 ; 210: "N" s h ‡kem
         db        carv,'O'                 ; 211: "O" s ‡ rkou
         db        strv,'O'                 ; 212: "O" se st©¡¨kou
         db        dvov,'O'                 ; 213: "O" s dvoj‡ rkou
         db        dvot,'O'                 ; 214: "O" s dvojte‡kou
         db        nofn,'x'                 ; 215: p©e¨krtnut¡
         db        hacv,'R'                 ; 216: "R" s h ‡kem
         db        krov,'U'                 ; 217: "U" s krou‘kem
         db        carv,'U'                 ; 218: "U" s ‡ rkou
         db        dvov,'U'                 ; 219: "U" s dvoj‡ rkou
         db        dvot,'U'                 ; 220: "U" s dvojte‡kou
         db        carv,'Y'                 ; 221: "Y" s ‡ rkou
         db        ocap,'T'                 ; 222: "T" s oc skem
         db        nofn,'á'                 ; 223: "á" - beta
         db        carm,'r'                 ; 224: "r" s ‡ rkou
         db        carm,'a'                 ; 225: " "
         db        strv,'a'                 ; 226: "a" se st©¡¨kou
         db        mism,'a'                 ; 227: "a" s miskou
         db        dvot,'a'                 ; 228: "a" s dvojte‡kou
         db        carv,'l'                 ; 229: "l" s ‡ rkou
         db        carm,'c'                 ; 230: "c" s ‡ rkou
         db        ocap,'c'                 ; 231: "c" s oc skem
         db        hacm,'c'                 ; 232: "c" s h ‡kem
         db        carm,'e'                 ; 233: "e" s ‡ rkou
         db        pats,'e'                 ; 234: "e" s pati‡kou
         db        dvot,'e'                 ; 235: "e" s dvojte‡kou
         db        hacm,'e'                 ; 236: "e" s h ‡kem
         db        carm,'i'                 ; 237: "¡"
         db        strv,'i'                 ; 238: "i" se st©¡¨kou
         db        hacp,'d'                 ; 239: "d" s h ‡kem
         db        skrp,'d'                 ; 240: "d" p©e¨krtnut‚
         db        carm,'n'                 ; 241: "n" s ‡ rkou
         db        hacm,'n'                 ; 242: "n" s h ‡kem
         db        carm,'o'                 ; 243: "o" s ‡ rkou
         db        strv,'o'                 ; 244: "o" se st©¡¨kou
         db        dvom,'o'                 ; 245: "o" s dvoj‡ rkou
         db        dvot,'o'                 ; 246: "o" s dvojte‡kou
         db        nofn,':'                 ; 247: "ö"
         db        hacm,'r'                 ; 248: "r" s h ‡kem
         db        krom,'u'                 ; 249: "u" s krou‘kem
         db        carm,'u'                 ; 250: "u" s ‡ rkou
         db        dvom,'u'                 ; 251: "u" s dvoj‡ rkou
         db        dvot,'u'                 ; 252: "u" s dvojte‡kou
         db        carm,'y'                 ; 253: "y" s ‡ rkou
         db        ocap,'t'                 ; 254: "t" s oc skem
         db        tecv,' '                 ; 255: te‡ka nad velk˜m p¡smenem
         dw        0

TabISO0  label     byte

; *****************************************************************************
;                         Instalace programu
; *****************************************************************************
;þ
; ------ instalace INT 23h

Instal:  mov       dx,offset Int23          ; obsluha INT 23h
         mov       ax,2523h
         int       21h                      ; instalace obsluhy INT 23h

; ------ £schova p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       di,offset Command        ; buffer p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld
         rep       movsb                    ; £scova p©¡kazov‚ho © dku
         mov       ds:[di],ch               ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ posun programu dol–

         mov       si,offset ZacRez         ; star˜ za‡ tek rezidentn¡ ‡ sti
         mov       di,offset ZacRez+KORIG   ; nov˜ za‡ tek rezidentn¡ ‡ sti
         mov       cx,offset(Instal-ZacRez) ; d‚lka rezidentn¡ ‡ sti
         rep       movsb                    ; posun programu dol–

; ------ test, zda je program ji‘ nainstalov n

         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         int       10h                      ; test instalace programu
         cmp       cx,KLIC4
         je        Inst11                   ; program je jiz nainstalovan
         push      cs
         pop       es
         or        byte ptr ds:[ParamIns],1 ; p©¡znak prvn¡ instalace
Inst11:  mov       ds:[SegRez],es           ; rezidentn¡ segment

; ------ test karty EGA/VGA

         mov       ah,12h                   ; funkce informac¡ EGA
         mov       bx,3e10h                 ; podfunkce - test instalace
         int       10h                      ; informace o kartˆ EGA
         cmp       bh,1
         ja        Chyba1                   ; nen¡ karta EGA/VGA
         cmp       bl,6                     ; kontrola navr cen‚ho £daje
         jb        Instal1                  ; je displej EGA/VGA

; ------ chyba - nen¡ karta EGA/VGA

Chyba1:  mov       dx,offset ErrTxt         ; chyba - nen¡ karta EGA/VGA

; ------ zobrazen¡ £vodn¡ho textu a chybov‚ho hl ¨en¡

Chyba:   push      dx
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         pop       dx

         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho hl ¨en¡
         int       20h

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

Instal1: mov       es,ds:[SegRez]           ; segment rezidentn¡ ‡ sti
         mov       si,offset Command        ; za‡ tek p©¡kazov‚ho © dku

; ------ nalezen¡ za‡ tku parametru

Instal3: call      ParSpc                   ; vypu¨tˆn¡ mezer
         jc        Instal6                  ; konec parametr–
         call      ParChr
         cmp       al,"/"
         je        Instal3                  ; ignorov n¡ znaku "/"
         cmp       al,"-"
         je        Instal3                  ; ignorov n¡ znaku "-"
         call      Param                    ; dek¢dov n¡ parametru
         mov       dx,offset HelpTxt        ; text n povˆdy
         jc        Chyba                    ; chyba zad n¡ parametr–

; ------ test, zda se po‘aduje odinstalov n¡ programu

Instal6: test      byte ptr ds:[ParamIns],2 ; po‘aduje se odinstalov n¡ ?
         jz        Instal7                  ; nepo‘aduje se odinstalov n¡

; ------ test, zda je nainstalov n

         mov       dx,offset NeniTxt        ; text - nen¡ nainstalov n
         test      byte ptr ds:[ParamIns],1 ; je to prvn¡ instalace ?
         jnz       Chyba                    ; chyba - nebyl dosud nainstalov n

; ------ test, zda lze odinstalovat

         mov       ax,3510h
         int       21h                      ; poskytnut¡ adresy INT 10h
         mov       dx,offset NelzeTxt       ; text - nelze odinstalovat
         mov       ax,es
         cmp       ax,ds:[SegRez]           ; souhlas¡ adresa ?
         jne       Chyba                    ; chyba - nelze odinstalovat

; ------ n vrat vektoru INT 10h

         push      ds
         lds       dx,es:[Old10+KORIG]      ; p–vodn¡ adresa INT 10h
         mov       ax,2510h
         int       21h                      ; n vrat adresy INT 10h
         pop       ds

; ------ uvolnˆn¡ segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu ES

; ------ hl ¨en¡ o odinstalov n¡

         mov       dx,offset OdInsTxt       ; text - byl odinstalov n
         jmp       short Chyba              ; hl ¨en¡ o odindstalov n¡

; ------ kontrola, zda je to prvn¡ instalace

Instal7: test      byte ptr ds:[ParamIns],1 ; je to prvn¡ instalace ?
         jnz       Instal8                  ; je to prvn¡ instalace
         call      Inform                   ; inicializace videom¢du + hl ¨en¡
         int       20h                      ; jinak konec

; ------ £schova p–vodn¡ adresy INT 10h

Instal8: push      es
         mov       ax,3510h
         int       21h
         mov       word ptr ds:[Old10+KORIG],bx ; £schova offsetu INT 10h
         mov       word ptr ds:[Old10+2+KORIG],es ; £schova segmentu INT 10h

; ------ instalace nov‚ obsluhy INT 10h

         mov       dx,offset Int10+KORIG    ; vlastn¡ obsluha INT 10h
         mov       ax,2510h
         int       21h                      ; instalace vlastn¡ obsluhy INT 10h

; ------ uvolnˆn¡ pamˆŸov‚ho bloku segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h                   ; funkce uvolnˆn¡ pamˆti
         int       21h                      ; uvolnˆn¡ bloku pamˆti
         pop       es

; ------ inicializace videom¢du

         or        byte ptr ds:[ParamIns],4 ; p©¡znak zmˆny k¢du
         call      Inform                   ; inicializace videom¢du + hl ¨en¡

; ------ instalace programu

         mov       dx,offset Instal         ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu

; -----------------------------------------------------------------------------
;        obsluha INT 23h
; -----------------------------------------------------------------------------

Int23    PROC      FAR

         iret

Int23    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ jednoho parametru AL
; -----------------------------------------------------------------------------

Param    PROC      NEAR

; ------ parametr "K" - k¢d Kamenick˜ch

         mov       ah,1                     ; ‡¡slo k¢du Kamenick˜ch
         cmp       al,"K"                   ; k¢d Kamenick˜ch ?
         je        Param1                   ; je k¢d Kamenick˜ch

; ------ parametr "L" - k¢d Latin 2

         mov       ah,2                     ; ‡¡slo k¢du Latin 2
         cmp       al,"L"                   ; k¢d Latin 2 ?
         je        Param1                   ; je k¢d Latin 2

; ------ parametr "I" - k¢d KOI 8

         mov       ah,3                     ; ‡¡slo k¢du KOI 8
         cmp       al,"I"                   ; k¢d KOI 8 ?
         je        Param1                   ; je k¢d KOI 8

; ------ parametr "O" - k¢d ISO 8859/2

         mov       ah,4                     ; ‡¡slo k¢du ISO 8859/2
         cmp       al,"O"                   ; k¢d ISO 8859/2
         je        Param1                   ; je k¢d ISO 8859/2

; ------ parametr "0" - vypnut¡ font–

         mov       ah,0                     ; ‡¡slo k¢du IBM
         cmp       al,"0"                   ; vypnut¡ obsluhy ?
         jne       Param2                   ; nen¡ vypnut¡ funkce

; ------ nastaven¡ ‡¡sla po‘adovan‚ho fontu

Param1:  cmp       byte ptr es:[FontTab+KORIG],ah ; mˆn¡ se k¢d ?
         je        Param12                  ; k¢d se nemˆn¡
         or        byte ptr ds:[ParamIns],4 ; p©¡znak zmˆny k¢du
         mov       es:[FontTab+KORIG],ah    ; nastaven¡ ‡¡sla k¢du
Param12: clc
         ret

; ------ parametr "!" - odinstalov n¡ z pamˆti

Param2:  cmp       al,"!"                   ; odinstalov n¡ ?
         jne       Param3                   ; chyba zad n¡
         or        byte ptr ds:[ParamIns],2 ; p©¡znak odinstalov n¡
         ret

Param3:  stc                                ; p©¡znak chyby
         ret

Param    ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr
         jc        ParSpc2
         je        ParSpc
         dec       si
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

         cld
         lodsb
         cmp       al,"a"
         jb        ParChr1
         cmp       al,"z"
         ja        ParChr1
         sub       al,32
ParChr1: cmp       al,9
         jne       ParChr2
         mov       al," "
ParChr2: cmp       al," "
         jae       ParChr3
         dec       si
ParChr3: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ informa‡n¡ho textu (ES=segment programu)
; -----------------------------------------------------------------------------

Inform   PROC      NEAR

; ------ test, zda byla zmˆna k¢du

         test      byte ptr ds:[ParamIns],4 ; byla zmˆna k¢du ?
         jz        Inform2                  ; nebyla zmˆna k¢du

; ------ stanoven¡ adresy font–

         mov       ah,0
         mov       al,es:[FontTab+KORIG]    ; ‡¡slo tabulky font–
         mov       si,offset TabKam         ; ‡e¨tina Kamenick˜ch
         dec       ax                       ; je ‡e¨tina Kamenick˜ch ?
         jz        Inform1                  ; ‡e¨tina Kamenick˜ch
         mov       si,offset TabLat         ; ‡e¨tina Latin 2
         dec       ax                       ; je ‡e¨tina Latin 2 ?
         jz        Inform1                  ; je ‡e¨tina Latin 2
         mov       si,offset TabKoi         ; ‡e¨tina KOI 8
         dec       ax                       ; je ‡e¨tina KOI 8 ?
         jz        Inform1                  ; je ‡e¨tina KOI 8
         mov       si,offset TabISO+KORIG   ; jinak ISO 8859/2

; ------ p©enos tabulky font–

Inform1: cld
         mov       cx,offset(TabISO0-TabISO) ; d‚lka tabulky
         mov       di,offset TabISO+KORIG
         rep       movsb                    ; p©enos tabulky

; ------ prvn¡ instalace videom¢du

         test      byte ptr ds:[ParamIns],1 ; je prvn¡ instalace ?
         jz        Inform12                 ; nen¡ prvn¡ instalace

         pushf
         push      cs
         call      near ptr Int1032+KORIG   ; instalace font–
         jmp       short Inform2

; ------ p©einstalov n¡ videom¢du

Inform12:push      es
         mov       ah,0fh
         int       10h                      ; poskytnut¡ aktivn¡ho videom¢du
         mov       ah,0
         int       10h                      ; p©einstalov n¡ videom¢du
         pop       es

; ------ zobrazen¡ £vodn¡ho textu

Inform2: mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ hl ¨en¡, ‘e byl nainstalov n

         test      byte ptr ds:[ParamIns],1 ; je prvn¡ instalace ?
         jz        Inform3                  ; nen¡ prvn¡ instalace
         mov       dx,offset InstTxt        ; text - byl nainstalov n
         mov       ah,9
         int       21h                      ; hl ¨en¡ o nainstalov n¡ programu

; ------ zobrazen¡ hl ¨en¡ o aktivn¡m k¢du

Inform3: mov       ah,0
         mov       al,es:[FontTab+KORIG]    ; ‡¡slo tabulky font–
         mov       dx,offset UvTxtK         ; ‡e¨tina Kamenick˜ch
         dec       ax                       ; je ‡e¨tina Kamenick˜ch ?
         jz        Inform4                  ; ‡e¨tina Kamenick˜ch
         mov       dx,offset UvTxtL         ; ‡e¨tina Latin 2
         dec       ax                       ; je ‡e¨tina Latin 2 ?
         jz        Inform4                  ; je ‡e¨tina Latin 2
         mov       dx,offset UvTxtI         ; ‡e¨tina KOI 8
         dec       ax                       ; je ‡e¨tina KOI 8 ?
         jz        Inform4                  ; je ‡e¨tina KOI 8
         mov       dx,offset UvTxtO         ; ‡e¨tina ISO 8859/2
         dec       ax                       ; je ‡e¨tina ISO 8859/2 ?
         jz        Inform4                  ; je ‡e¨tina ISO 8859/2
         mov       dx,offset UvTxt0         ; ‡e¨tina vypnuta
Inform4: mov       ah,9
         int       21h                      ; zobrazen¡ textu o stavu
         ret

Inform   ENDP

; -----------------------------------------------------------------------------
;                                  data
; -----------------------------------------------------------------------------
;þ

SegRez   dw        0                        ; sezidentn¡ segment

ParamIns db        0                        ; parametry pro instalaci
                                            ;   bit 0: 1=je prvn¡ instalace
                                            ;   bit 1: 1=po‘adavek odinstalov n¡
                                            ;   bit 2: 1=byla zmˆna k¢du

ErrTxt   db        'Neni nainstalovana karta EGA/VGA !',13,10,'$'

HelpTxt  db        'Zadejte: K ...... kod Kamenickych (KEYBCS2)',13,10
         db        '         L ...... kod Latin 2',13,10
         db        '         I ...... kod KOI 8',13,10
         db        '         O ...... kod ISO 8859/2',13,10
         db        '         0 ...... kod IBM',13,10
         db        '         ! ...... odinstalovani z pameti',13,10
         db        '$'

UvTxt    db        'EGACS V3.20 - CS fonty pro EGA/VGA; (c) Miroslav Nemecek',13,10,'$'

InstTxt  db        'EGACS byl nainstalovan: $'

UvTxtK   db        'Aktivn¡ k¢d Kamenick˜ch.',13,10,'$'
UvTxtL   db        'Aktivn¡ k¢d Latin 2.',13,10,'$'
UvTxtI   db        'AktivnÉ kÏd KOI 8.',13,10,'$'
UvTxtO   db        'Aktivní kód ISO 8859/2.',13,10,'$'
UvTxt0   db        'Aktivni kod IBM.',13,10,'$'

OdInsTxt db        'EGACS byl odinstalovan z pameti.',13,10,'$'
NelzeTxt db        'EGACS nelze odinstalovat !',13,10,'$'
NeniTxt  db        'EGACS nebyl dosud nainstalovan !',13,10,'$'

TabKam   label     byte                     ; defini‡n¡ tabulka Kamenick˜ch

         db        hacv,'C'                 ; "C" s h ‡kem
         db        carm+1,'e'               ; "e" s ‡ rkou
         db        hacp,'d'                 ; "d" s h ‡kem
         db        hacv+1,'D'               ; "D" s h ‡kem
         db        hacv,'T'                 ; "T" s h ‡kem
         db        hacm,'c'                 ; "c" s h ‡kem
         db        hacm,'e'                 ; "e" s h ‡kem
         db        hacv,'E'                 ; "E" s h ‡kem
         db        carv,'L'                 ; "L" s ‡ rkou
         db        carv,'I'                 ; "I" s ‡ rkou
         db        hacp,'l'                 ; "l" s h ‡kem
         db        carv,'l'                 ; "l" s ‡ rkou
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
         db        carv,'L'                 ; "L" s ‡ rkou
         db        carv,'l'                 ; "l" s ‡ rkou
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
         db        hacp,'d'                 ; "d" s h ‡kem
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

TabKoi   label     byte                     ; defini‡n¡ tabulka KOI 8
         db        nofn+1,151               ; 129: "u" se zpˆtnou ‡ rkou
         db        nofn,138                 ; 130: "e" se zpˆtnou ‡ rkou
         db        nofn,21                  ; 131: paragraf
         db        nofn,225                 ; 132: beta
         db        nofn,156                 ; 133: libra
         db        nofn,146                 ; 134: "A" ve vichru
         db        nofn,237                 ; 135: ¨krtnut‚ nekone‡no
         db        nofn,143                 ; 136: "A" s krou‘kem
         db        nofn,145                 ; 137: "z" pokroucen‚
         db        nofn,237                 ; 138: ¨krtnut‚ nekone‡no
         db        krom,'a'                 ; 139: "a" s krou‘kem
         db        nofn+1,176               ; 141: "°"
         db        spc1,' '                 ; 142: rubl
         db        nofn,149                 ; 143: "o" se zpˆtnou ‡ rkou
         db        zcarm,'i'                ; 144: "i" se zpˆtnou ‡ rkou
         db        nofn,158                 ; 145: "Pt"
         db        nofn,173                 ; 146: obr cen˜ vyk©i‡n¡k
         db        nofn,165                 ; 147: "N" s vlnovkou
         db        nofn,168                 ; 148: obr cen˜ otazn¡k
         db        nofn,164                 ; 149: "n" s vlnovkou
         db        nofn,219                 ; 150: "Û"
         db        nofn,220                 ; 151: "Ü"
         db        nofn,223                 ; 152: "ß"
         db        nofn,186                 ; 153: "º"
         db        nofn,187                 ; 154: "»"
         db        nofn,188                 ; 155: "¼"
         db        nofn,200                 ; 156: "È"
         db        nofn,201                 ; 157: "É"
         db        nofn,205                 ; 158: "Í"
         db        nofn,177                 ; 159: "±"
         db        nofn,240                 ; 160: "ð"
         db        nofn,241                 ; 161: "ñ"
         db        nofn,242                 ; 162: "ò"
         db        nofn,243                 ; 163: "ó"
         db        nofn,244                 ; 164: "ô"
         db        nofn,245                 ; 165: "õ"
         db        nofn,246                 ; 166: "ö"
         db        nofn,247                 ; 167: "÷"
         db        nofn,248                 ; 168: "ø"
         db        nofn,251                 ; 169: "û"
         db        nofn,253                 ; 170: "ý"
         db        nofn+2,21                ; 173: paragraf
         db        nofn+2,224               ; 176: "à"
         db        nofn,225                 ; 177: "á"
         db        nofn,226                 ; 178: "â"
         db        nofn,227                 ; 179: "ã"
         db        nofn,228                 ; 180: "ä"
         db        nofn,229                 ; 181: "å"
         db        nofn,230                 ; 182: "æ"
         db        nofn,231                 ; 183: "ç"
         db        nofn,232                 ; 184: "è"
         db        nofn,233                 ; 185: "é"
         db        nofn,234                 ; 186: "ê"
         db        nofn,235                 ; 187: "ë"
         db        nofn,236                 ; 188: "ì"
         db        nofn,237                 ; 189: "í"
         db        nofn,238                 ; 190: "î"
         db        nofn,239                 ; 191: "ï"
         db        nofn,'+'                 ; 192: "Ú"
         db        carm,'a'                 ; 193: " "
         db        nofn,'+'                 ; 194: "À"
         db        hacm,'c'                 ; 195: "c" s h ‡kem
         db        hacp,'d'                 ; 196: "d" s h ‡kem
         db        hacm,'e'                 ; 197: "e" s h ‡kem
         db        carm,'r'                 ; 198: "r" s ‡ rkou
         db        nofn,'-'                 ; 199: "Ä"
         db        dvot,'u'                 ; 200: ""
         db        carm,'i'                 ; 201: "¡"
         db        krom,'u'                 ; 202: "u" s krou‘kem
         db        carv,'l'                 ; 203: "l" s ‡ rkou
         db        hacp,'l'                 ; 204: "l" s h ‡kem
         db        dvot,'o'                 ; 205: "o" s dvojte‡kou
         db        hacm,'n'                 ; 206: "n" s h ‡kem
         db        carm,'o'                 ; 207: "o" s ‡ rkou
         db        strv,'o'                 ; 208: "o" se st©¡¨kou
         db        dvot,'a'                 ; 209: "a" s dvojte‡kou
         db        hacm,'r'                 ; 210: "r" s h ‡kem
         db        hacm,'s'                 ; 211: "s" s h ‡kem
         db        hacp,'t'                 ; 212: "t" s h ‡kem
         db        carm,'u'                 ; 213: "u" s ‡ rkou
         db        nofn,'+'                 ; 214: "Ã"
         db        carm,'e'                 ; 215: "e" s ‡ rkou
         db        zcarm,'a'                ; 216: "a" se zpˆtnou ‡ rkou
         db        carm,'y'                 ; 217: "y" s ‡ rkou
         db        hacm,'z'                 ; 218: "z" s h ‡kem
         db        nofn,'+'                 ; 219: "Â"
         db        nofn+1,223               ; 221: "ß"
         db        nofn,'='                 ; 222: "Í"
         db        nofn,'+'                 ; 223: "Å"
         db        nofn,'+'                 ; 224: "¿"
         db        carv,'A'                 ; 225: "A" s ‡ rkou
         db        nofn,'+'                 ; 226: "Ù"
         db        hacv,'C'                 ; 227: "C" s h ‡kem
         db        hacv,'D'                 ; 228: "D" s h ‡kem
         db        hacv,'E'                 ; 229: "E" s h ‡kem
         db        carv,'R'                 ; 230: "R" s ‡ rkou
         db        nofn,'|'                 ; 231: "³"
         db        dvot,'U'                 ; 232: "š"
         db        carv,'I'                 ; 233: "I" s ‡ rkou
         db        krov,'U'                 ; 234: "U" s krou‘kem
         db        carv,'L'                 ; 235: "L" s ‡ rkou
         db        hacp,'L'                 ; 236: "L" s h ‡kem
         db        dvot,'O'                 ; 237: "O" s dvojte‡kou
         db        hacv,'N'                 ; 238: "N" s h ‡kem
         db        carv,'O'                 ; 239: "O" s ‡ rkou
         db        strv,'O'                 ; 240: "O" se st©¡¨kou
         db        dvot,'A'                 ; 241: "A" s dvojte‡kou
         db        hacv,'R'                 ; 242: "R" s h ‡kem
         db        hacv,'S'                 ; 243: "S" s h ‡kem
         db        hacv,'T'                 ; 244: "T" s h ‡kem
         db        carv,'U'                 ; 245: "U" s ‡ rkou
         db        nofn,'+'                 ; 246: "´"
         db        carv,'E'                 ; 247: "E" s ‡ rkou
         db        zcarv,'A'                ; 248: "A" se zpˆtnou ‡ rkou
         db        carv,'Y'                 ; 249: "Y" s ‡ rkou
         db        hacv,'Z'                 ; 250: "Z s h ‡kem
         db        nofn,'+'                 ; 251: "Á"
         db        nofn+1,'.'
         dw        0
TabKoi0  label     byte

Command  db        128 dup(0)               ; buffer p©¡kazov‚ho © dku

Code     ENDS
         END       Start

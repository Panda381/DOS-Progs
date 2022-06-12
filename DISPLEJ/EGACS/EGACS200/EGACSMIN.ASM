
; *****************************************************************************
;              Instalace ‡esk˜ch znak– na displej EGA/VGA Mini
; *****************************************************************************
code     segment
         assume    cs:code,ds:code
         org       100h

start:   jmp       instal                   ; instalace programu

adrtab   dw        offset tabkam            ; adresa defini‡n¡ tabulky k¢du
                                            ;  (0=vypnuto)

adrst8   dd        0                        ; adresa standardn¡ho fontu 8x8
adrst14  dd        0                        ; adresa standardn¡ho fontu 8x14
adrst16  dd        0                        ; adresa standardn¡ho fontu 8x16

old10    dd        0                        ; p–vodn¡ adresa obsluhy INT 10h
regmap   db        0                        ; nastaven¡ registru pro mapov n¡

identtop label     byte                     ; za‡ tek identifikace
; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 10h
; -----------------------------------------------------------------------------
public   int10i
int10i:                                   ;* vol n¡ p–vodn¡ obsluhy INT 10h
         pushf                              ; simulace isntrukce INT xx
         call      dword ptr cs:[old10]     ; nastaven¡ nov‚ho videom¢du
         ret
; -----------------------------------------------------------------------------
public   int10
int10:                                      ; obsluha displeje INT 10h

         cmp       ax,1130h                 ; funkce informac¡ o fontech ?
         jne       int101                   ; nejsou informace o fontech
         cmp       bx,5678h                 ; identifikace dotazu ?
         jne       int101                   ; nen¡ identifikace dotazu
         call      int10i                   ; proveden¡ obsluhy
         push      cs
         pop       es                       ; segment rezidentn¡ ‡ sti
         iret

int101:  or        ah,ah                    ; je nastaven¡ m¢du displeje ?
         jz        int103                   ; je nastaven¡ videom¢du
         cmp       ah,11h                   ; je slu‘ba obsluhy font– ?
         jne       int102                   ; nen¡ operace s fonty
                                          ;* je slu‘ba 11h - nastaven¡ font–
         test      al,0fh                   ; jsou u‘iv. fonty nebo informace ?
         jz        int102                   ; u‘ivatelsk‚ fonty nebo informace
         cmp       al,3                     ; je nastaven¡ bloku font– ?
         jne       int103                   ; nen¡ nastaven¡ bloku
int102:  jmp       dword ptr cs:[old10]     ; skok na p–vodn¡ obsluhu INT 10h

int103:                                   ;* nastaven¡ ‡esk‚ho videom¢du
         call      int10i                   ; vol n¡ po‘adovan‚ funkce
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,cs:[adrtab]           ; adresa defini‡n¡ tabulky
         or        bp,bp                    ; je funkce vypnuta ?
         jz        int109                   ; funkce je vypnuta
                                          ;* kontrola videom¢du
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0 datov˜ segment BIOS
         mov       al,ds:[449h]             ; aktu ln¡ videom¢d
         and       al,7fh                   ; zru¨en¡ p©¡znaku nemaz n¡ displeje
         mov       ah,0eh                   ; registr mapov n¡ pro CGA
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         jbe       int104                   ; je textov˜ m¢d CGA - OK
         cmp       al,7                     ; je videom¢d MDA ?
         jne       int109                   ; nen¡ textov˜ videom¢d
         mov       ah,0ah                   ; registr mapov n¡ pro MDA
int104:  mov       cs:[regmap],ah           ; £schova registru pro mapov n¡
                                          ;* nastaven¡ videom¢du pro definice
         call      initregf                 ; inicializace registr– pro fonty
                                          ;* nalezen¡ adresy fontu
         xor       cx,cx                    ; CH <- 0
         mov       cl,ds:[485h]             ; po‡et linek na znak
         mov       bx,offset font8          ; font 8x8
         lds       si,cs:[adrst8]           ; standardn¡ font 8x8
         cmp       cl,8                     ; je font 8x8 ?
         je        int105                   ; je font 8x8
         mov       bx,offset font14         ; font 8x14 a 8x16
         lds       si,cs:[adrst14]          ; standardn¡ font 8x14
         cmp       cl,14
         je        int105                   ; je font 8x14
         lds       si,cs:[adrst16]          ; standardn¡ font 8x16
int105:
                                          ;* p©edefinov n¡ font–
         call      defin                    ; definov n¡ n rodn¡ch font–
                                          ;* zpˆtn‚ nastaven¡ videom¢du
         call      initregt                 ; inicializace registr– pro text
int109:
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

; -----------------------------------------------------------------------------
public   defin
defin:                                    ;* definov n¡ n rodn¡ch font–
                                            ; VSTUP: CS:BP=defini‡n¡ tabulka
                                            ;        CS:BX=vlastn¡ fonty
                                            ;        CX=po‡et linek na znak
                                            ;        DS:SI=standardn¡ fonty

         mov       dh,80h                   ; po‡ te‡n¡ ukazatel znak–
         mov       ax,0a000h                ; segment videopamˆti
         mov       es,ax                    ; segment videopamˆti

                                          ;* test konce tabulky
tabel1:  mov       ax,cs:[bp]               ; definice z tabulky
         add       bp,2                     ; zv˜¨en¡ ukazatele
         or        ax,ax                    ; je konec tabulky ?
         jnz       tabel2                   ; nen¡ je¨tˆ konec tabulky
         ret

                                          ;* proveden¡ skoku
tabel2:  push      ax
         and       al,7                     ; d‚lka skoku
         add       dh,al                    ; zv˜¨en¡ ‡¡sla znaku
         pop       ax
                                          ;* p©evod znaku
         shr       al,1
         shr       al,1
         shr       al,1                     ; ‡¡slo fontu
         mov       dl,ah                    ; standardn¡ znak
         call      prevch                   ; p©evod znaku
         inc       dh                       ; zv˜¨en¡ ukazatele
         jmp       short tabel1             ; dal¨¡ font

; -----------------------------------------------------------------------------
;     P©evod znaku
; -----------------------------------------------------------------------------
                                            ; VSTUP: ES=segment videopamˆti
                                            ;        DS:SI=standardn¡ fonty
                                            ;        CS:BX=vlastn¡ fonty
                                            ;        CX=po‡et linek na znak
                                            ;        DL=standardn¡ znak
                                            ;        DH=m¡sto k ulo‘en¡
                                            ;        AL=‡¡slo fontu 0 a‘ 15
                                            ; zni‡en‚ registry: AX,DI
prevch:  push      bx
         push      cx
         push      dx
         push      si
         cld                                ; smˆr nahoru

                                          ;* adresa vlastn¡ho fontu
prevch0: dec       al
         js        prevch4                  ; font nalezen
         push      ax
         mov       al,cs:[bx]               ; definice fontu
         inc       bx
         and       ax,0fh                   ; d‚lka fontu
         add       bx,ax                    ; zv˜¨en¡ adresy fontu
         pop       ax
         jmp       short prevch0            ; dal¨¡ font
prevch4:
                                          ;* adresa m¡sta ulo‘en¡ ES:DI
         mov       al,32                    ; po‡et bajt– na znak ve fontech
         mul       dh                       ; offset ve videopamˆti
         mov       di,ax                    ; adresa znaku ve videopamˆti

                                          ;* adresa standardn¡ho fontu DS:SI
         mov       al,cl                    ; po‡et linek na znak
         mul       dl                       ; offset v tabulce stand. znak–
         add       si,ax                    ; adresa v tabulce stand. znak–

                                          ;* po‡ te‡n¡ a koncov  linka fontu
         mov       dl,cs:[bx]               ; po‡ te‡n¡ linka a d‚lka
         inc       bx                       ; zv˜¨en¡ adresy
         mov       dh,dl                    ; kopie do DH
         and       dl,0fh                   ; DL=d‚lka 0 a‘ 15
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; DH=po‡ te‡n¡ linka 0 a‘ 15
                                          ;* korekce pro font 16x8
         cmp       cl,14
         jbe       prevch5
         cmp       dh,8
         jb        prevch5                  ; je v horn¡ polovinˆ
         add       dh,2                     ; zv˜¨en¡ pozice
prevch5:
                                          ;* korekce horn¡ch linek pro 8x8
         or        dl,dl                    ; je nˆjak˜ font ?
         jz        prevch8                  ; nen¡ ‘ dn˜ font - nen¡ korekce
         cmp       dh,4                     ; je font dole ?
         jae       prevch8                  ; je font dole - nen¡ korekce
         inc       si
         mov       ax,100h                  ; korekce pro font 8x8
         cmp       cl,8                     ; je font 8x8 ?
         je        prevch7                  ; nen¡ font 8x8
         dec       si
prevch8: mov       ah,-1                    ; nen¡ korekce pro ostatn¡ znaky
                                          ;* p©evod jednoho znaku
prevch1: lodsb                              ; bajt standardn¡ho fontu
         dec       ah                       ; korekce pro fonty 8x8
         jnz       prevch7                  ; nen¡ prvn¡ bajt
         or        al,ds:[si-2]             ; + bajt z p©ede¨l‚ linky
prevch7: dec       dh                       ; ‡¡ta‡ po‡ te‡n¡ linky
         jns       prevch2                  ; je pod po‡ te‡n¡ linkou
         dec       dl                       ; ‡¡ta‡ po‡tu linek
         js        prevch2                  ; je nad koncovou linkou
         or        al,cs:[bx]               ; slou‡en¡ s vlatn¡m znakem
         inc       bx                       ; zv˜¨en¡ adresy vlastn¡ho fontu
prevch2: stosb                              ; ulo‘en¡ do videopamˆti
         loop      prevch1                  ; dal¨¡ bajt
prevch3:
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;     Inicializace registr– videokarty
; -----------------------------------------------------------------------------
initregf:                                 ;* inicializace registr– pro fonty
         mov       cl,4                     ; nastaven¡ mapov n¡ pro fonty
         mov       bx,407h                  ; BH=roviny, BL=prokl d n¡
         jmp       short initreg            ; inicializace registr–

initregt:                                 ;* inicializace registr– na text. m¢d
         mov       cl,cs:[regmap]           ; registr pro mapov n¡
         mov       bx,303h                  ; BH=roviny, BL=prokl d n¡

initreg:                                  ;* inicializace registr– videokarty
                                            ; VSTUP: BH=nastaven¡ rovin
                                            ;        BL=nastaven¡ prokl d n¡
                                            ;        CL=nastaven¡ mapov n¡

                                          ;* volba rovin pro z pis (maska)
         mov       dx,3c4h                  ; b zov  adresa 03c4h
         mov       al,2
         mov       ah,bh                    ; roviny
         out       dx,ax                    ; nastaven¡ rovin pro z pis
                                          ;* nastav. prokl d n¡ bajt– sud /lich 
         mov       al,4
         mov       ah,bl                    ; prokl d n¡
         out       dx,ax                    ; nastaven¡ prokl d n¡ bajt–
                                          ;* nastaven¡ mapov n¡ videopamˆti
         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         mov       ah,cl                    ; nastaven¡ mapov n¡
         out       dx,ax                    ; registr 6: mapov n¡ videopamˆti
         ret

; *****************************************************************************
;                              Tabulky
; *****************************************************************************

font8    label     byte                     ; fonty 8x8
         db        2,0ch,18h                ; carv: ‡ rka pro velk  p¡smena
         db        2,0ch,18h                ; carm: ‡ rka pro mal  p¡smena
         db        2,3,3                    ; carp: ‡ rka po prav‚ stranˆ
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
         db        7,0c6h,0c6h,7ch,6ch,7ch,0c6h,0c6h ; spc1: k©¡‘ s d¡rou
         db        1,66h                    ; dvot: dvojte‡ka
         db        0                        ; nofn: konec tabulky


font14   label     byte                     ; fonty 8x14 a 8x16
         db        2,0ch,18h                ; carv: ‡ rka pro velk  p¡smena
         db        13h,0ch,18h,30h          ; carm: ‡ rka pro mal  p¡smena
         db        3,3,3,2                  ; carp: ‡ rka po prav‚ stranˆ
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
         db        47h,0c6h,0c6h,7ch,6ch,7ch,0c6h,0c6h ; spc1: k©¡‘ s d¡rou
         db        1,66h                    ; dvot: dvojte‡ka
         db        0                        ; nofn: konec tabulky

carv     equ       00h                      ; ‡ rka pro velk  p¡smena
carm     equ       08h                      ; ‡ rka pro mal  p¡smena
carp     equ       10h                      ; ‡ rka po prav‚ stranˆ
hacv     equ       18h                      ; h ‡ek pro velk  p¡smena
hacm     equ       20h                      ; h ‡ek pro mal  p¡smena
hacp     equ       28h                      ; h ‡ek po prav‚ stranˆ
krov     equ       30h                      ; krou‘ek nad velk˜m "U"
krom     equ       38h                      ; krou‘ek nad mal˜m "u"
strv     equ       40h                      ; st©¡¨ka nad velk˜m p¡smenem
skrl     equ       48h                      ; p©e¨krnut¡ vlevo
skrs     equ       50h                      ; p©e¨krtnut¡ uprost©ed
skrp     equ       58h                      ; p©e¨krtnut¡ vpravo
dvov     equ       60h                      ; dvoj‡ rka nad velk˜m p¡smenem
dvom     equ       68h                      ; dvoj‡ rka nad mal˜m p¡smenem
patr     equ       70h                      ; pati‡ka vpravo
pats     equ       78h                      ; pati‡ka uprost©ed
ocap     equ       80h                      ; oc sek uprost©ed
tecv     equ       88h                      ; te‡ka nad velk˜m p¡smenem
tecm     equ       90h                      ; te‡ka nad mal˜m p¡smenem
misv     equ       98h                      ; miska nad velk˜m p¡smenem
mism     equ       0a0h                     ; miska nad mal˜m p¡smenem
spc1     equ       0a8h                     ; speci ln¡ znak - k©¡‘ s d¡rou
dvot     equ       0b0h                     ; dvojte‡ka

nofn     equ       0b8h                     ; konec tabulky


tabkam   label     byte                     ; defini‡n¡ tabulka Kamenick˜ch

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

tablat   label     byte                     ; defini‡n¡ tabulka Latin 2

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
         db        spc1+7,' '               ; k©¡‘ s d¡rou
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

identend label     byte                     ; konec identifikace

endrez   label     near                     ; konec rezidentn¡ ‡ sti
; *****************************************************************************
;                         Instalace programu
; *****************************************************************************
public   instal
instal:
                                          ;* test, zda je karta EGA/VGA
         mov       ah,12h
         mov       bl,10h
         int       10h
         cmp       bl,10h
         jne       instal1                  ; je displej EGA/VGA

                                          ;* chyba - nen¡ karta EGA/VGA
         mov       dx,offset errtxt         ; chyba - nen¡ karta EGA/VGA
chyba:   mov       ah,9
         int       21h
         int       20h

                                          ;* kontrola, zda je ji‘ nainstalov n
instal1: mov       ax,1130h
         mov       bx,5678h
         int       10h                      ; dotaz na rezidentn¡ instalaci
         mov       si,offset identtop       ; za‡ tek identifikace
         mov       di,si
         mov       cx,offset(identend-identtop) ; d‚lka identifikace
         cld
         repe      cmpsb                    ; porovn n¡ identifika‡n¡ ‡ sti
         je        instal2                  ; je nainstalov n
         push      cs
         pop       es                       ; nen¡ nainstalov n

                                          ;* rozk¢dov n¡ zad n¡
instal2: push      cs
         pop       ds
         mov       dx,offset help           ; n povˆda
         mov       si,81h                   ; za‡ tek textu
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak– zad n¡
instal3: jcxz      instal6                  ; nen¡ ji‘ dal¨¡ znak
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; oddˆlovac¡ znak ?
         jbe       instal3                  ; je oddˆlovac¡ znak
         cmp       al,"/"                   ; je parametr ?
         jne       chyba                    ; chyba zad n¡
         jcxz      chyba                    ; chyba zad n¡
         lodsb                              ; znak parametru
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         or        al,20h                   ; p©evod na mal‚ p¡smeno
         cmp       al,"k"                   ; k¢d Kamenick˜ch ?
         jne       instal4                  ; nen¡ k¢d Kamenick˜ch
         mov       word ptr es:[adrtab],offset tabkam ; k¢d Kamenick˜ch
         jmp       short instal3            ; dal¨¡ znak
instal4: cmp       al,"l"                   ; k¢d Latin 2 ?
         jne       instal5                  ; nen¡ k¢d Latin 2
         mov       word ptr es:[adrtab],offset tablat ; k¢d Latin 2
         jmp       short instal3            ; dal¨¡ znak
instal5: cmp       al,"0"                   ; vypnut¡ obsluhy ?
         jne       chyba                    ; chyba zad n¡
         mov       word ptr es:[adrtab],0   ; standardn¡ k¢d IBM
         jmp       short instal3            ; dal¨¡ znak

instal6:                                  ;* je to prvn¡ instalace programu ?
         mov       ax,es
         mov       bx,cs
         cmp       ax,bx                    ; je program nainstalovan˜ ?
         je        instal7                  ; nen¡ je¨tˆ nainstalovan˜

         call      inform                   ; zobrazen¡ informa‡n¡ho textu
         int       20h                      ; konec programu

                                          ;* zji¨tˆn¡ adres syst‚mov˜ch font–
instal7:
         mov       di,offset adrst8         ; adresy syst‚mov˜ch font–
         mov       bh,3                     ; fonty 8x8
         call      detfont                  ; detekce fontu 8x8
         mov       bh,2                     ; fonty 8x14
         call      detfont                  ; detekce fontu 8x14
         mov       bh,6                     ; fonty 8x16
         call      detfont                  ; detekce fontu 8x16
                                          ;* instalace ovlada‡e displeje EGACS
         mov       ax,3510h
         int       21h
         mov       word ptr ds:[old10],bx
         mov       word ptr ds:[old10+2],es
         mov       dx,offset int10
         mov       ax,2510h
         int       21h
         push      cs
         pop       es

         call      inform                   ; zobrazen¡ informa‡n¡ho textu

         mov       bx,cs                    ; tento segment
         mov       ax,ds:[2ch]              ; segment prost©ed¡
         dec       ax
         mov       ds,ax                    ; z hlav¡ prost©ed¡
         cmp       bx,ds:[1]                ; je vlastn¡kem tento program ?
         jne       instal8                  ; nen¡
         mov       word ptr ds:[1],0        ; zru¨en¡ vlastn¡ka bloku
instal8:
         mov       dx,offset endrez         ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu

inform:                                   ;* zobrazen¡ informace o fontech

         push      es
                                          ;* £schova pozice kurzoru
         mov       ah,0fh
         int       10h                      ; dotaz na sou‡asn˜ videom¢d
         push      ax                       ; £schova videom¢du
         mov       ah,3
         int       10h                      ; poskytnut¡ pozice kurzoru
         pop       ax                       ; n vrat aktivn¡ho videom¢du
         push      dx                       ; £schova pozice kurzoru
                                          ;* p©edefinov n¡ videom¢du
         or        al,80h                   ; displej se nema‘e
         xor       ah,ah
         int       10h                      ; nov‚ nastaven¡ videom¢du
                                          ;* zru¨en¡ p©¡znaku maz n¡ displeje
         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[449h],not 80h ; zru¨en¡ p©¡znaku nemazat displej
         and       byte ptr ds:[487h],not 80h ; zru¨en¡ p©¡znaku nemazat displej
         pop       ds
                                          ;* n vrat pozice kurzoru
         pop       dx                       ; n vrat pozice kurzoru
         mov       ah,2
         int       10h                      ; n vrat pozice kurzoru

         pop       es
                                          ;* zobrazen¡ informa‡n¡ho textu
         mov       dx,offset uvtxt          ; prvn¡ ‡ st textu
         mov       ah,9
         int       21h                      ; zobrazen¡ prvn¡ ‡ sti textu
         mov       dx,offset uvtxtk         ; ‡e¨tina Kamenick˜ch
         cmp       word ptr es:[adrtab],offset tabkam ; je ‡e¨tina Kamenick˜ch ?
         je        inform2                  ; ‡e¨tina Kamenick˜ch
         mov       dx,offset uvtxtl         ; ‡e¨tina Latin 2
         cmp       word ptr es:[adrtab],offset tablat ; je ‡e¨tina Latin 2 ?
         je        inform2                  ; je ‡e¨tina Latin 2
         mov       dx,offset uvtxt0         ; ‡e¨tina vypnuta
inform2: mov       ah,9
         int       21h                      ; zobrazen¡ druh‚ ‡ sti textu
         ret

                                          ;* detekce fontu
                                            ; VSTUP: ES:DI=ukl dac¡ adresa
                                            ;        BH=slu‘ba ke zji¨tˆn¡ ukaz.
detfont: push      di
         push      es
         mov       ax,1130h
         int       10h                      ; informace o fontech
         mov       ax,es                    ; segment font–
         pop       es
         pop       di

         xchg      ax,bp
         stosw                              ; ulo‘en¡ offsetu adresy
         xchg      ax,bp
         stosw                              ; ulo‘en¡ segmentu adresy
         ret

errtxt   db        'Nen¡ karta EGA/VGA !',13,10,'$'

help     db        'Zadejte:/K=kod Kamenickych',13,10
         db        9,'/L=Latin 2',13,10
         db        9,'/0=IBM',13,10
         db        '$'

uvtxt    db        'CS fonty EGA/VGA Mini - k¢d $'
uvtxtk   db        'Kamenick˜ch; (c) M.Nˆme‡ek',13,10,'$'
uvtxtl   db        'Latin 2; (c) M.NØmeŸek',13,10,'$'
uvtxt0   db        'IBM; (c) M.Nemecek',13,10,'$'


code     ends
         end       start


; *****************************************************************************
;               Instalace ‡esk˜ch znak– na displej EGA/VGA V2.00
; *****************************************************************************
code     segment
         assume    cs:code,ds:code
         org       100h

identtop label     byte                     ; za‡ tek identifikace programu

start:   jmp       instal                   ; instalace programu


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
                                          ;* je dotaz na instalaci ?
         cmp       ax,1130h                 ; funkce informac¡ o fontech ?
         jne       int101                   ; nejsou informace o fontech
         cmp       bx,5678h                 ; identifikace dotazu ?
         jne       int101                   ; nen¡ identifikace dotazu
         call      int10i                   ; proveden¡ obsluhy
         push      cs
         pop       es                       ; segment rezidentn¡ ‡ sti
         iret

int101:  cmp       byte ptr cs:[disable],0  ; je obsluha povolen  ?
         jne       int102                   ; obsluha je zak zan 
         or        ah,ah                    ; je nastaven¡ m¢du displeje ?
         jz        int103                   ; je nastaven¡ videom¢du
         cmp       ah,11h
         jne       int102                   ; nen¡ operace s fonty
                                          ;* je slu‘ba 11h - nastaven¡ font–
         cmp       al,1
         je        int103                   ; na‡ten¡ fontu 8x14
         cmp       al,2
         je        int103                   ; na‡ten¡ fontu 8x8
         cmp       al,4
         je        int103                   ; na‡ten¡ fontu 8x16
         cmp       al,11h
         je        int103                   ; na‡ten¡ fontu 8x14
         cmp       al,12h
         je        int103                   ; na‡ten¡ fontu 8x8
         cmp       al,14h
         je        int103                   ; na‡ten¡ fontu 8x16
         cmp       al,22h
         je        int103                   ; na‡ten¡ graf. fontu 8x14
         cmp       al,23h
         je        int103                   ; na‡ten¡ graf. fontu 8x8
         cmp       al,24h
         je        int103                   ; na‡ten¡ graf. fontu 8x16
int102:  jmp       dword ptr cs:[old10]     ; skok na p–vodn¡ obsluhu INT 10h

int103:                                   ;* nastaven¡ ‡esk‚ho videom¢du
         inc       byte ptr cs:[disable]    ; blokov n¡ funkce
         call      int10i                   ; vol n¡ po‘adovan‚ funkce
         sti                                ; povolen¡ p©eru¨en¡
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es


         xor       ax,ax
         mov       ds,ax                    ; DS <- 0 datov˜ segment BIOS
         push      cs
         pop       es                       ; ES <- CS tento segment programu

                                          ;* £schova nastaven¡ displeje
         mov       ah,0fh
         call      int10i                   ; poskytnut¡ aktivn¡ str nky
         mov       ah,3
         call      int10i                   ; ‡ten¡ pozice a velikosti kurzoru
         push      cx                       ; £schova rozmˆr– kurzoru
         push      bx                       ; £schova aktivn¡ str nky
         push      dx                       ; £schova pozice kurzoru
         push      word ptr ds:[44ch]       ; £schova velikosti bufferu


         mov       bh,ds:[485h]             ; po‡et linek na znak
         call      loadfont                 ; na‡ten¡ standardn¡ho fontu
         jc        int109                   ; font nen¡ definov n

         call      defin                    ; definov n¡ n rodn¡ch font–
         jc        int109                   ; font nen¡ definov n

                                          ;* nastaven¡ pro textov˜ m¢d
         mov       al,10h                   ; p©¡kaz pro na‡ten¡ u‘iv. font–
         mov       cx,256                   ; po‡et znak–
         xor       dx,dx                    ; offset za‡ tku tabulky

                                          ;* je textov˜ m¢d ?
         mov       ah,ds:[449h]             ; aktivn¡ videom¢d
         and       ah,7fh
         cmp       ah,3
         jbe       int10d                   ; je textov˜ m¢d
         cmp       ah,7
         je        int10d                   ; je MDA m¢d

                                          ;* je grafick˜ videom¢d
         mov       cx,cs:[adrbuff]          ; adresa bufferu
         add       cx,128*8                 ; povolovina bufferu
         mov       ds:[7ch],cx              ; fonty pro INT 1fh
         mov       word ptr ds:[7ch+2],cs
         xor       cx,cx
         mov       cl,bh                    ; po‡et linek na znak
         mov       dl,ds:[484h]             ; ‡¡slo posledn¡ho © dku
         inc       dl                       ; po‡et © dk–
         mov       al,21h

                                          ;* definice font–
int10d:  mov       ah,11h
         xor       bl,bl                    ; blok fontu 0, po‡et © dk– v DL
         mov       bp,cs:[adrbuff]          ; adresa bufferu s fontem
         call      int10i                   ; na‡ten¡ u‘ivatelsk˜ch font–
int109:
                                          ;* navr cen¡ parametr– displeje
         pop       word ptr ds:[44ch]       ; £schova velikosti bufferu
         pop       dx                       ; n vrat pozice kurzoru
         pop       bx                       ; n vrat aktivn¡ str nky
         mov       ah,2
         call      int10i                   ; n vrat pozice kurzoru
         pop       cx                       ; n vrat velikosti kurzoru
         mov       ah,1
         call      int10i                   ; n vrat rozmˆr– kurzoru

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         dec       byte ptr cs:[disable]     ; povolen¡ obsluhy
         iret

; -----------------------------------------------------------------------------
public   loadfont
                                          ;* na‡ten¡ standardn¡ho fontu
                                            ; VSTUP: BH=po‡et linek na znak
                                            ;        ES=tento segment
                                            ; VSTUP: CY=font nen¡ definov n
                                            ;         SI=adresa vlastn¡ho fontu

                                          ;* nalezen¡ tabulky fontu
loadfont:mov       si,offset fonty          ; tabulky font–
         mov       cx,4                     ; po‡et mo‘n˜ch font–
loadfnt1:cmp       cs:[si],bh               ; souhlas¡ po‡et linek na znak ?
         je        loadfnt2                 ; po‘adovan˜ font nalezen
         add       si,7                     ; adresa dal¨¡ tabulky
         loop      loadfnt1                 ; test dal¨¡ho fontu
         stc                                ; p©¡znak chyby - font nenalezen
         ret

                                          ;* tabulka nalezena - na‡ten¡
loadfnt2:push      ds
         push      si
         xor       cx,cx
         mov       ch,bh                    ; d‚lka tabulky
         shr       cx,1                     ; d‚lka tabulky / 2
         lds       si,cs:[si+1]             ; adresa syst‚mov‚ho fontu
         mov       di,cs:[adrbuff]          ; buffer k na‡ten¡ fontu
         cld
         rep       movsw                    ; p©enos fontu do bufferu
         pop       si
         pop       ds
         mov       si,cs:[si+5]             ; adresa vlastn¡ho fontu
         clc                                ; p©¡znak operace OK
         ret

; -----------------------------------------------------------------------------
public   defin
defin:                                    ;* definov n¡ n rodn¡ch font–
                                            ; VSTUP: SI=offset adresy fontu
                                            ;        ES=tento segment
                                            ;        BH=po‡et bajt– na znak
                                            ; VSTUP: CY=k¢d nen¡ definov n

         push      bx
         push      ds
         push      cs
         pop       ds

         mov       di,cs:[adrbuff]          ; buffer s fonty
         xor       cx,cx                    ; CX <- 0
         mov       cl,bh                    ; po‡et bajt– na znak

                                          ;* adresa defini‡n¡ tabulky
         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[font]             ; ‡¡slo fontu
         cmp       bl,4                     ; je font vˆt¨¡ ne‘ 4 ?
         cmc                                ; CY = chyba
         jb        defin5                   ; nepovolen‚ ‡¡slo fontu
         add       bx,bx                    ; ‡¡slo fontu * 2
         add       bx,offset tables         ; adresa defini‡n¡ tabulky
         mov       bx,ds:[bx]               ; adresa defini‡n¡ tabulky

                                          ;* test konce tabulky
defin1:  mov       al,cs:[bx]               ; povel z defini‡n¡ tabulky
         inc       bx                       ; zv˜¨en¡ ukazatele v defin. tabulce
         or        al,al                    ; je konec tabulky ?
         jz        defin5                   ; konec tabulky

                                          ;* p©esko‡en¡ znak–
         js        defin2                   ; je p©enos znaku
         mul       cl                       ; p©¡rustek adresy
         add       di,ax                    ; zv˜¨en¡ adresy o AL znak–
         jmp       short defin1             ; dal¨¡ bajt

                                          ;* p©enos znaku z vlastn¡ tabulky
defin2:  and       al,7fh
         mul       cl                       ; v˜po‡et offsetu v tabulce
         push      si
         add       si,ax                    ; po‡ te‡n¡ adresa znaku v tabulce
         push      cx
         cld
         rep       movsb                    ; p©enesen¡ znaku
         pop       cx
         pop       si                       ; n vrat adresy tabulky font–
         jmp       short defin1             ; dal¨¡ bajt

defin5:  pop       ds
         pop       bx
         ret

identend label     byte                     ; konec identifikace

; ******************** p©edefinovateln‚ tabulky, data *************************

old10    dd        0                        ; p–vodn¡ adresa obsluhy INT 10h

adrbuff  dw        0                        ; adresa bufferu

font     db        0                        ; ‡¡slo fontu (0ffh=standardn¡)
                                            ;       0 = Kamenick˜ch
                                            ;       1 = Latin 2
                                            ;       2 = KOI 8
disable  db        0                        ; blokov n¡ funkce (0=povoleno)


fonty    label     byte                   ;* adresy font–
         db        8                        ; po‡et linek na znak = 8
         dd        0                        ; adresa standardn¡ho fontu 8x8
         dw        offset font8             ; adresa vlastn¡ho fontu 8x8

         db        14                       ; po‡et linek na znak = 14
         dd        0                        ; adresa standardn¡ho fontu 8x14
         dw        offset font14            ; adresa vlastn¡ho fontu 8x14

tabfnt16 db        16                       ; po‡et linek na znak = 16
         dd        0                        ; adresa standardn¡ho fontu 8x16
         dw        offset font16            ; adresa vlastn¡ho fontu 8x16

         db        0
         dd        0                        ; rezerva
         dw        0                        ; rezerva

tables   label     byte                     ; defini‡n¡ tabulky font–
         dw        offset tabkam            ; tabulka Kamenick˜ch
         dw        offset tablat            ; tabulka Latin 2
         dw        offset tabkoi            ; tabulka KOI 8
         dw        0                        ; rezerva


; Definice struktury fontu (defini‡n¡ tabulka):
;
;  00000000b - konec tabulky
;  0xxxxxxxb - p©esko‡en¡ xxxxxxxb znak– (1 a‘ 127)
;  1xxxxxxxb - pou‘ije se znak xxxxxxxb z vlastn¡ tabulky (0 a‘ 127)


tabkam   label     byte                     ; defini‡n¡ tabulka Kamenick˜ch

         db        127
         db        1
         db        xc3                      ; 128 "€"
         db        2
         db        xd2                      ; 131 "ƒ"
         db        1
         db        xd1                      ; 133 "…"
         db        xt1                      ; 134 "†"
         db        xc4                      ; 135 "‡"
         db        xe3                      ; 136 "ˆ"
         db        xe2                      ; 137 "‰"
         db        xl1                      ; 138 "œ"
         db        xi1                      ; 139 "‹"
         db        xl4                      ; 140 "Œ"
         db        xl2                      ; 141 ""
         db        1
         db        xa1                      ; 143 ""
         db        xe1                      ; 144 ""
         db        xz4                      ; 145 "‘"
         db        xz3                      ; 146 "’"
         db        2
         db        xo1                      ; 149 "•"
         db        xu3                      ; 150 "–"
         db        xu1                      ; 151 "—"
         db        xy2                      ; 152 "˜"
         db        2
         db        xs3                      ; 155 "›"
         db        xl3                      ; 156 "œ"
         db        xy1                      ; 157 ""
         db        xr3                      ; 158 "ž"
         db        xt2                      ; 159 "Ÿ"
         db        4
         db        xn4                      ; 164 "¤"
         db        xn3                      ; 165 "¥"
         db        xu2                      ; 166 "¦"
         db        xo2                      ; 167 "§"
         db        xs4                      ; 168 "¨"
         db        xr4                      ; 169 "©"
         db        xr2                      ; 170 "ª"
         db        xr1                      ; 171 "«"
         db        1
         db        xx1                      ; 173 "­" paragraf

         db        0                        ; konec tabulky

tablat   label     byte                     ; defini‡n¡ tabulka Latin 2

         db        127
         db        6
         db        xu3                      ; 133 "–" s krou‘kem
         db        xc2                      ; 134 "c" s ‡ rkou
         db        1
         db        xl6                      ; 136 "l" p©e¨krtnut‚
         db        1
         db        xo3                      ; 138 "O" se 2 ‡ rkama
         db        xo4                      ; 139 "o" se 2 ‡ rkama
         db        1
         db        xz1                      ; 140 "Z" s ‡ rkou
         db        1
         db        xc1                      ; 143 "C" s ‡ rkou
         db        xe1                      ; 144 "E" s ‡ rkou
         db        xl1                      ; 145 "L" s ‡ rkou
         db        xl2                      ; 146 "l" s ‡ rkou
         db        2
         db        xl3                      ; 149 "L" s h ‡kem
         db        xl4                      ; 150 "l" s h ‡kem
         db        xs1                      ; 151 "S" s ‡ rkou
         db        xs2                      ; 152 "s" s ‡ rkou
         db        2
         db        xt1                      ; 155 "T" s h ‡kem
         db        xt2                      ; 156 "t" s h ‡kem
         db        xl5                      ; 157 "L" p©e¨krtnut‚
         db        xx2                      ; 158 p©e¨krtnut¡
         db        xc4                      ; 159 "c" s h ‡kem
         db        4
         db        xa5                      ; 164 "A" s no‘i‡kou
         db        xa6                      ; 165 "a" s no‘i‡kou
         db        xz3                      ; 166 "Z" s h ‡kem
         db        xz4                      ; 167 "z" s h ‡kem
         db        xe5                      ; 168 "E" s no‘i‡kou
         db        xe6                      ; 169 "e" s no‘i‡kou
         db        1
         db        xz2                      ; 171 "z" s ‡ rkou
         db        xc3                      ; 172 "C" s h ‡kem
         db        xs6                      ; 173 "s" s oc skem
         db        7
         db        xa1                      ; 181 "A" s ‡ rkou
         db        xa4                      ; 182 "A" se st©¡¨kou
         db        xe2                      ; 183 "E" s h ‡kem
         db        xs5                      ; 184 "S" s oc skem
         db        4
         db        xz5                      ; 189 "Z" s te‡kou
         db        xz6                      ; 190 "z" s te‡kou
         db        7
         db        xa2                      ; 198 "A" s h ‡kem
         db        xa3                      ; 199 "a" s h ‡kem
         db        7
         db        xx3                      ; 207 "x" s d¡rou
         db        xd4                      ; 208 "d" p©e¨krtnut‚
         db        xd3                      ; 209 "D" p©e¨krtnut‚
         db        xd1                      ; 210 "D" s h ‡kem
         db        xe4                      ; 211 "E" p©ehlasovan‚
         db        xd2                      ; 212 "d" s h ‡kem
         db        xn3                      ; 213 "N" s h ‡kem
         db        xi1                      ; 214 "I" s ‡ rkou
         db        xi2                      ; 215 "I" se st©¡¨kou
         db        xe3                      ; 216 "e" s h ‡kem
         db        4
         db        xt3                      ; 221 "T" s oc skem
         db        xu2                      ; 222 "U" s krou‘kem
         db        1
         db        xo1                      ; 224 "O" s ‡ rkou
         db        1
         db        xo2                      ; 226 "O" se st©¡¨kou
         db        xn1                      ; 227 "N" s ‡ rkou
         db        xn2                      ; 228 "n" s ‡ rkou
         db        xn4                      ; 229 "n" s h ‡kem
         db        xs3                      ; 230 "S" s h ‡kem
         db        xs4                      ; 231 "s" s h ‡kem
         db        xr1                      ; 232 "R" s ‡ rkou
         db        xu1                      ; 233 "U" s ‡ rkou
         db        xr2                      ; 234 "r" s ‡ rkou
         db        xu4                      ; 235 "U" se 2 ‡ rkama
         db        xy2                      ; 236 "y" s ‡ rkou
         db        xy1                      ; 237 "Y" s ‡ rkou
         db        xt4                      ; 238 "t" s oc skem
         db        xx4                      ; 239 "'" ‡ rka vpravo
         db        xx5                      ; 240 "-" kr tk  poml‡ka
         db        xx6                      ; 241 " 2 ‡ rky
         db        xx7                      ; 242 no‘i‡ka
         db        xx8                      ; 243 h ‡ek
         db        xx9                      ; 244 miska
         db        xx1                      ; 245 "­" paragraf
         db        1
         db        xxa                      ; 247 oc sek
         db        1
         db        xxb                      ; 249 p©ehlasov n¡
         db        1
         db        xu5                      ; 251 "u" se 2 ‡ rkama
         db        xr3                      ; 252 "R" s h ‡kem
         db        xr4                      ; 253 "r" s h ‡kem

         db        0                        ; konec tabulky

tabkoi   label     byte                     ; defini‡n¡ tabulka KOI 8

         db        0                        ; konec tabulky



font8    label     byte                     ; fonty 8x8
         db        13h,3bh,6ch,0c6h,0feh,0c6h,0c6h,0       ; 0: "" s ‡ rkou
xa1      equ       ($-font8)/8 + 7fh
         db        7ch,38h,6ch,0c6h,0feh,0c6h,0c6h,0       ; 2: "A" s h ‡kem
xa2      equ       ($-font8)/8 + 7fh
         db        6ch,38h,7ch,6,7eh,0c6h,7eh,0            ; 3: "a" s h ‡kem
xa3      equ       ($-font8)/8 + 7fh
         db        7ch,38h,6ch,0c6h,0feh,0c6h,0c6h,0       ; 6: "A" se st©¡¨kou
xa4      equ       ($-font8)/8 + 7fh
         db        38h,6ch,0c6h,0c6h,0feh,0c6h,0ceh,0ch    ; 8: "A" s no‘i‡kou
xa5      equ       ($-font8)/8 + 7fh
         db        0,0,7ch,6,7eh,0c6h,7eh,18h              ; 9: "a" s no‘i‡kou
xa6      equ       ($-font8)/8 + 7fh
         db        6,3ch,66h,0c0h,0c0h,66h,3ch,0           ; 10: "C" s ‡ rkou
xc1      equ       ($-font8)/8 + 7fh
         db        6,0ch,7ch,0c6h,0c0h,0c6h,7ch,0          ; 11: "c" s ‡ rkou
xc2      equ       ($-font8)/8 + 7fh
         db        66h,3ch,66h,0c0h,0c0h,66h,3ch,0         ; 12: "€" s h ‡kem
xc3      equ       ($-font8)/8 + 7fh
         db        66h,3ch,7ch,0c6h,0c0h,0c6h,7ch,0        ; 13: "‡" s h ‡kem
xc4      equ       ($-font8)/8 + 7fh
         db        0cch,78h,0f8h,0cch,0c6h,0cch,0f8h,0     ; 16: "…" s h ‡kem
xd1      equ       ($-font8)/8 + 7fh
         db        96h,66h,6,7eh,0c6h,0c6h,7eh,0           ; 17: "ƒ" s h ‡kem
xd2      equ       ($-font8)/8 + 7fh
         db        0f8h,06ch,066h,076h,0e6h,06ch,0f8h,0    ; 18: "D" p©e¨krnut‚
xd3      equ       ($-font8)/8 + 7fh
         db        6,0fh,6,7eh,0c6h,0c6h,7eh,0             ; 19: "d" p©e¨krtnut‚
xd4      equ       ($-font8)/8 + 7fh
         db        0ch,18h,7eh,60h,78h,60h,7eh,0           ; 20: "" s ‡ rkou
xe1      equ       ($-font8)/8 + 7fh
         db        0cch,78h,0fch,0c0h,0f0h,0c0h,0fch,0     ; 22: "‰" s h ‡kem
xe2      equ       ($-font8)/8 + 7fh
         db        66h,3ch,7ch,0c6h,0feh,0c0h,7ch,0        ; 23: "ˆ" s h ‡kem
xe3      equ       ($-font8)/8 + 7fh
         db        66h,0,0feh,0c0h,0f8h,0c0h,0feh,0        ; 24: "E" p©ehlasovan‚
xe4      equ       ($-font8)/8 + 7fh
         db        0feh,0c0h,0c0h,0f8h,0c0h,0c0h,0feh,0ch  ; 26: "E" s no‘i‡kou
xe5      equ       ($-font8)/8 + 7fh
         db        0,0,7ch,0c6h,0feh,0c0h,7ch,0ch          ; 27: "e" s no‘i‡kou
xe6      equ       ($-font8)/8 + 7fh
         db        0ch,18h,3ch,18h,18h,18h,3ch,0           ; 28: "‹" s ‡ rkou
xi1      equ       ($-font8)/8 + 7fh
         db        7eh,0c3h,3ch,18h,18h,18h,3ch,0          ; 30: "I" se st©¡¨kou
xi2      equ       ($-font8)/8 + 7fh
         db        3ch,66h,18h,18h,18h,18h,18h,0           ; 31: "i" se st©¡¨kou
xi3      equ       ($-font8)/8 + 7fh
         db        0cch,0cch,0d8h,0c0h,0c0h,0c0h,0feh,0    ; 32: "Š" s ‡ rkou
xl1      equ       ($-font8)/8 + 7fh
         db        1bh,1bh,18h,18h,18h,18h,18h,0           ; 33: "" s ‡ rkou
xl2      equ       ($-font8)/8 + 7fh
         db        0dbh,0ceh,0c0h,0c0h,0c0h,0c0h,0feh,0    ; 34: "œ" s h ‡kem
xl3      equ       ($-font8)/8 + 7fh
         db        35h,32h,30h,30h,30h,30h,30h,0           ; 35: "Œ" s h ‡kem
xl4      equ       ($-font8)/8 + 7fh
         db        0f0h,060h,060h,070h,0e0h,062h,0feh,0    ; 36: "L" p©e¨krtnut‚
xl5      equ       ($-font8)/8 + 7fh
         db        18h,18h,18h,1ch,38h,18h,18h,0           ; 37: "l" p©e¨ktnut‚
xl6      equ       ($-font8)/8 + 7fh
         db        0deh,0e6h,0f6h,0deh,0ceh,0c6h,0c6h,0    ; 38: "N" s ‡ rkou
xn1      equ       ($-font8)/8 + 7fh
         db        06h,0ch,0fch,0c6h,0c6h,0c6h,0c6h,0      ; 39: "n" s ‡ rkou
xn2      equ       ($-font8)/8 + 7fh
         db        66h,3ch,0e6h,0f6h,0deh,0ceh,0c6h,0      ; 40: "¥" s h ‡kem
xn3      equ       ($-font8)/8 + 7fh
         db        6ch,38h,0fch,0c6h,0c6h,0c6h,0c6h,0      ; 41: "¤" s h ‡kem
xn4      equ       ($-font8)/8 + 7fh
         db        3h,3bh,6ch,0c6h,0c6h,6ch,38h,0          ; 42: "•" s ‡ rkou
xo1      equ       ($-font8)/8 + 7fh
         db        7ch,82h,38h,6ch,0c6h,6ch,38h,0          ; 44: "§" se st©¡¨kou
xo2      equ       ($-font8)/8 + 7fh
         db        66h,38h,6ch,0c6h,0c6h,6ch,38h,0         ; 48: "O" se 2 ‡ rkami
xo3      equ       ($-font8)/8 + 7fh
         db        66h,0,7ch,0c6h,0c6h,0c6h,7ch,0          ; 49: "o" se 2 ‡ rkami
xo4      equ       ($-font8)/8 + 7fh
         db        18h,30h,0fch,0c6h,0fch,0c6h,0c6h,0      ; 50: "«" s ‡ rkou
xr1      equ       ($-font8)/8 + 7fh
         db        18h,30h,0dch,0e6h,0c0h,0c0h,0c0h,0      ; 51: "ª" s ‡ rkou
xr2      equ       ($-font8)/8 + 7fh
         db        0cch,78h,0fch,0c6h,0fch,0c6h,0c6h,0     ; 52: "ž" s h ‡kem
xr3      equ       ($-font8)/8 + 7fh
         db        0cch,78h,0fch,0c6h,0c0h,0c0h,0c0h,0     ; 53: "©" s h ‡kem
xr4      equ       ($-font8)/8 + 7fh
         db        0ch,7eh,0c0h,7ch,6,0c6h,7ch,0           ; 54: "S" s ‡ rkou
xs1      equ       ($-font8)/8 + 7fh
         db        06h,0ch,7eh,0c0h,7ch,6,0fch,0           ; 55: "s" s ‡ rkou
xs2      equ       ($-font8)/8 + 7fh
         db        24h,7eh,0c0h,7ch,6,0c6h,7ch,0           ; 56: "›" s h ‡kem
xs3      equ       ($-font8)/8 + 7fh
         db        66h,3ch,7eh,0c0h,7ch,6,0fch,0           ; 57: "¨" s h ‡kem
xs4      equ       ($-font8)/8 + 7fh
         db        7ch,0c6h,0c0h,7ch,6,0c6h,7ch,0ch        ; 58: "S" s oc skem
xs5      equ       ($-font8)/8 + 7fh
         db        0,0,7ch,0c0h,7ch,6,0fch,0ch             ; 59: "s" s oc skem
xs6      equ       ($-font8)/8 + 7fh
         db        66h,3ch,7eh,18h,18h,18h,18h,0           ; 60: "†" s h ‡kem
xt1      equ       ($-font8)/8 + 7fh
         db        66h,66h,0f4h,60h,60h,66h,3ch,0          ; 61: "Ÿ" s h ‡kem
xt2      equ       ($-font8)/8 + 7fh
         db        0fch,30h,30h,30h,30h,30h,38h,8          ; 62: "T" s oc skem
xt3      equ       ($-font8)/8 + 7fh
         db        60h,60h,0fch,60h,60h,66h,3ch,0ch        ; 63: "t" s oc skem
xt4      equ       ($-font8)/8 + 7fh
         db        0ch,0dah,0c6h,0c6h,0c6h,0c6h,7ch,0      ; 64: "—" s ‡ rkou
xu1      equ       ($-font8)/8 + 7fh
         db        18h,0a4h,0dah,0c6h,0c6h,0c6h,7ch,0      ; 66: "¦" s krou‘kem
xu2      equ       ($-font8)/8 + 7fh
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,7eh,0        ; 67: "–" s krou‘kem
xu3      equ       ($-font8)/8 + 7fh
         db        0c6h,0,0c6h,0c6h,0c6h,0c6h,7ch,0        ; 70: "U" se 2 ‡ rkami
xu4      equ       ($-font8)/8 + 7fh
         db        0c6h,0,0c6h,0c6h,0c6h,0c6h,7eh,0        ; 71: "u" se 2 ‡ rkami
xu5      equ       ($-font8)/8 + 7fh
         db        0ch,5ah,66h,3ch,18h,18h,18h,0           ; 72: "" s ‡ rkou
xy1      equ       ($-font8)/8 + 7fh
         db        0ch,18h,0c6h,0c6h,0c6h,7eh,6,0fch       ; 73: "˜" s ‡ rkou
xy2      equ       ($-font8)/8 + 7fh
         db        0ch,0feh,0ch,18h,30h,60h,0feh,0         ; 74: "Z" s ‡ rkou
xz1      equ       ($-font8)/8 + 7fh
         db        6,0ch,7eh,0ch,18h,30h,7eh,0             ; 75: "z" s ‡ rkou
xz2      equ       ($-font8)/8 + 7fh
         db        6ch,0feh,0ch,18h,30h,60h,0feh,0         ; 76: "’" s h ‡kem
xz3      equ       ($-font8)/8 + 7fh
         db        66h,3ch,7eh,0ch,18h,30h,7eh,0           ; 77: "‘" s h ‡kem
xz4      equ       ($-font8)/8 + 7fh
         db        0ch,0feh,0ch,18h,30h,60h,0feh,0         ; 78: "Z" s te‡kou
xz5      equ       ($-font8)/8 + 7fh
         db        0ch,0,7eh,0ch,18h,30h,7eh,0             ; 79: "z" s te‡kou
xz6      equ       ($-font8)/8 + 7fh
         db        3ch,60h,38h,6ch,6ch,38h,0ch,78h         ; 80: "­" paragraf
xx1      equ       ($-font8)/8 + 7fh
         db        0,0,0c6h,6ch,38h,6ch,0c6h,0             ; 81: "x" p©e¨krtnut¡
xx2      equ       ($-font8)/8 + 7fh
         db        0,0,0c6h,7ch,48h,7ch,0c6h,0             ; 82: "x" x s d¡rou
xx3      equ       ($-font8)/8 + 7fh
         db        0ch,18h,30h,0,0,0,0,0                   ; 83: "'" ‡ rka vpravo
xx4      equ       ($-font8)/8 + 7fh
         db        0,0,0,70h,0,0,0,0                       ; 84: "-" kr tk  poml‡ka
xx5      equ       ($-font8)/8 + 7fh
         db        33h,66h,0cch,0,0,0,0,0                  ; 85: " 2 ‡ rky
xx6      equ       ($-font8)/8 + 7fh
         db        0,0,0,0,30h,30h,3ch,0                   ; 86: pati‡ka
xx7      equ       ($-font8)/8 + 7fh
         db        0,66h,3ch,0,0,0,0,0                     ; 87: h ‡ek
xx8      equ       ($-font8)/8 + 7fh
         db        0,0c6h,7ch,0,0,0,0,0                    ; 88: miska
xx9      equ       ($-font8)/8 + 7fh
         db        0,0,0,0,0,30h,18h,70h                   ; 89: oc sek
xxa      equ       ($-font8)/8 + 7fh
         db        0,66h,0,0,0,0,0,0                       ; 91: " " p©ehlasov n¡
xxb      equ       ($-font8)/8 + 7fh

font14   label     byte                     ; fonty 8x14
db        3,6,10h,38h,6ch,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0,0,0        ; 0: "" s ‡ rkou
db        0c6h,06ch,10h,38h,6ch,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0,0,0  ; 2: "A" s h ‡kem
db        0,0,0c6h,7ch,0,78h,0ch,7ch,0cch,0cch,76h,0,0,0             ; 3: "a" s h ‡kem
db        7ch,0c6h,10h,38h,6ch,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0,0,0   ; 6: "A" se st©¡¨kou
db        0,0,10h,38h,6ch,0c6h,0c6h,0feh,0c6h,0c6h,0ceh,8,0eh,0      ; 8: "A" s no‘i‡kou
db        0,0,0,0,0,78h,0ch,7ch,0cch,0cch,76h,10h,1ch,0              ; 9: "a" s no‘i‡kou
db        6,0ch,3ch,66h,0c2h,0c0h,0c0h,0c0h,0c2h,66h,3ch,0,0,0       ; 10: "C" s ‡ rkou
db        0,0ch,18h,30h,0,7ch,0c6h,0c0h,0c0h,0c6h,7ch,0,0,0          ; 11: "c" s ‡ rkou
db        66h,3ch,3ch,66h,0c2h,0c0h,0c0h,0c0h,0c2h,66h,3ch,0,0,0     ; 12: "€" s h ‡kem
db        0,0,66h,3ch,0,7ch,0c6h,0c0h,0c0h,0c6h,7ch,0,0,0            ; 13: "‡" s h ‡kem
db        0cch,78h,0f8h,6ch,66h,66h,66h,66h,66h,6ch,0f8h,0,0,0       ; 16: "…" s h ‡kem
db        6ch,38h,1ch,0ch,0ch,3ch,6ch,0cch,0cch,0cch,7eh,0,0,0       ; 17: "ƒ" s h ‡kem
db        0,0,0f8h,6ch,66h,66h,76h,0e6h,66h,6ch,0f8h,0,0,0           ; 18: "D" p©e¨krnut‚
db        0,0,0ch,1eh,0ch,3ch,6ch,0cch,0cch,0cch,76h,0,0,0           ; 19: "d" p©e¨krtnut‚
db        0ch,18h,0feh,66h,62h,68h,78h,68h,62h,66h,0feh,0,0,0        ; 20: "" s ‡ rkou
db        66h,3ch,0feh,66h,62h,68h,78h,68h,62h,66h,0feh,0,0,0        ; 22: "‰" s h ‡kem
db        0,0,66h,3ch,0,7ch,0c6h,0feh,0c0h,0c6h,7ch,0,0,0            ; 23: "ˆ" s h ‡kem
db        66h,0,0feh,66h,62h,68h,78h,68h,62h,66h,0feh,0,0,0          ; 24: "E" p©ehlasovan‚
db        0,0,0feh,66h,62h,68h,78h,68h,62h,66h,0feh,10h,1ch,0        ; 26: "E" s no‘i‡kou
db        0,0,0,0,0,7ch,0c6h,0feh,0c0h,0c6h,7ch,10h,1ch,0            ; 27: "e" s no‘i‡kou
db        0ch,18h,3ch,18h,18h,18h,18h,18h,18h,18h,3ch,0,0,0          ; 28: "‹" s ‡ rkou
db        3ch,66h,0,3ch,18h,18h,18h,18h,18h,18h,3ch,0,0,0            ; 30: "I" se st©¡¨kou
db        0,18h,3ch,66h,0,38h,18h,18h,18h,18h,3ch,0,0,0              ; 31: "i" se st©¡¨kou
db        0,6,0f6h,64h,60h,60h,60h,60h,62h,66h,0feh,0,0,0            ; 32: "Š" s ‡ rkou
db        6h,6,74h,30h,30h,30h,30h,30h,30h,30h,78h,0,0,0             ; 33: "" s ‡ rkou
db        36h,1ch,0f0h,60h,60h,60h,60h,60h,62h,66h,0feh,0,0,0        ; 34: "œ" s h ‡kem
db        36h,1ch,70h,30h,30h,30h,30h,30h,30h,30h,78h,0,0,0          ; 35: "Œ" s h ‡kem
db        0,0,0f0h,60h,60h,70h,0e0h,060h,62h,66h,0feh,0,0,0          ; 36: "L" p©e¨krtnut‚
db        0,0,38h,18h,18h,1ch,38h,18h,18h,18h,3ch,0,0,0              ; 37: "l" p©e¨ktnut‚
db        0ch,18h,0c6h,0e6h,0f6h,0feh,0deh,0ceh,0c6h,0c6h,0c6h,0,0,0 ; 38: "N" s ‡ rkou
db        0,0ch,18h,30h,0,0dch,66h,66h,66h,66h,66h,0,0,0             ; 39: "n" s ‡ rkou
db        0cch,78h,0c6h,0e6h,0f6h,0feh,0deh,0ceh,0c6h,0c6h,0c6h,0,0,0; 40: "¥" s h ‡kem
db        0,0,66h,3ch,0,0dch,66h,66h,66h,66h,66h,0,0,0               ; 41: "¤" s h ‡kem
db        6,0ch,38h,6ch,0c6h,0c6h,0c6h,0c6h,0c6h,6ch,38h,0,0,0       ; 42: "•" s ‡ rkou
db        7ch,0c6h,38h,6ch,0c6h,0c6h,0c6h,0c6h,0c6h,6ch,38h,0,0,0    ; 44: "§" se st©¡¨kou
db        63h,0c6h,0,38h,6ch,0c6h,0c6h,0c6h,0c6h,6ch,38h,0,0,0       ; 48: "O" se 2 ‡ rkami
db        0,33h,066h,0cch,0,7ch,0c6h,0c6h,0c6h,0c6h,7ch,0,0,0        ; 49: "o" se 2 ‡ rkami
db        0ch,18h,0fch,66h,66h,66h,7ch,6ch,66h,66h,0e6h,0,0,0        ; 50: "«" s ‡ rkou
db        0,6,0ch,18h,0,0dch,76h,66h,60h,60h,0f0h,0,0,0              ; 51: "ª" s ‡ rkou
db        66h,3ch,0fch,66h,66h,66h,7ch,6ch,66h,66h,0f6h,0,0,0        ; 52: "ž" s h ‡kem
db        0,0,0cch,78h,0,0dch,76h,66h,60h,60h,0f0h,0,0,0             ; 53: "©" s h ‡kem
db        0ch,18h,7ch,0c6h,0c6h,60h,38h,0ch,0c6h,0c6h,7ch,0,0,0      ; 54: "S" s ‡ rkou
db        0,0ch,18h,30h,0,7ch,0c6h,70h,1ch,0c6h,7ch,0,0,0            ; 55: "s" s ‡ rkou
db        66h,3ch,7ch,0c6h,0c6h,60h,38h,0ch,0c6h,0c6h,7ch,0,0,0      ; 56: "›" s h ‡kem
db        0,0,66h,3ch,0,7ch,0c6h,70h,1ch,0c6h,7ch,0,0,0              ; 57: "¨" s h ‡kem
db        0,0,7ch,0c6h,0c6h,60h,38h,0ch,0c6h,0c6h,7ch,18h,0ch,38h    ; 58: "S" s oc skem
db        0,0,0,0,0,7ch,0c6h,70h,1ch,0c6h,7ch,18h,0ch,38h            ; 59: "s" s oc skem
db        66h,3ch,7eh,7eh,5ah,18h,18h,18h,18h,18h,3ch,0,0,0          ; 60: "†" s h ‡kem
db        36h,1ch,10h,30h,30h,0fch,30h,30h,30h,36h,1ch,0,0,0         ; 61: "Ÿ" s h ‡kem
db        0,0,7eh,7eh,5ah,18h,18h,18h,18h,18h,3ch,18h,0ch,38h        ; 62: "T" s oc skem
db        0,0,10h,30h,30h,0fch,30h,30h,30h,36h,1ch,18h,0ch,38h       ; 63: "t" s oc skem
db        0ch,18h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,7ch,0,0,0  ; 64: "—" s ‡ rkou
db        3ch,66h,3ch,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,7ch,0,0,0   ; 66: "¦" s krou‘kem
db        0,38h,6ch,38h,0,0cch,0cch,0cch,0cch,0cch,76h,0,0,0         ; 67: "–" s krou‘kem
db        33h,66h,0,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,7ch,0,0,0     ; 70: "U" se 2 ‡ rkami
db        0,33h,66h,0cch,0,0cch,0cch,0cch,0cch,0cch,76h,0,0,0        ; 71: "u" se 2 ‡ rkami
db        0ch,18h,66h,66h,66h,66h,3ch,18h,18h,18h,3ch,0,0,0          ; 72: "" s ‡ rkou
db        0,6,0ch,18h,0,0c6h,0c6h,0c6h,0c6h,7eh,6,0ch,0f8h,0         ; 73: "˜" s ‡ rkou
db        0ch,18h,0feh,0c6h,8ch,18h,30h,60h,0c2h,0c6h,0feh,0,0,0     ; 74: "Z" s ‡ rkou
db        0,0ch,18h,30h,0,0feh,0cch,18h,30h,66h,0feh,0,0,0           ; 75: "z" s ‡ rkou
db        66h,3ch,0feh,0c6h,8ch,18h,30h,60h,0c2h,0c6h,0feh,0,0,0     ; 76: "’" s h ‡kem
db        0,0,0cch,78h,0,0feh,0cch,18h,30h,66h,0feh,0,0,0            ; 77: "‘" s h ‡kem
db        18h,18h,0feh,0c6h,8ch,18h,30h,60h,0c2h,0c6h,0feh,0,0,0     ; 78: "Z" s te‡kou
db        0,0,30h,30h,0,0feh,0cch,18h,30h,66h,0feh,0,0,0             ; 79: "z" s te‡kou
db        0,0,7ch,0c6h,60h,38h,6ch,0c6h,6ch,38h,0ch,0c6h,7ch,0       ; 80: "­" paragraf
db        0,0,0,0,0,0c6h,6ch,38h,38h,6ch,0c6h,0,0,0                  ; 81: "x" p©e¨krtnut¡
db        0,0,0,0c6h,0c6h,7ch,6ch,7ch,0c6h,0c6h,0,0,0,0              ; 82: "x" x s d¡rou
db        0,0ch,18h,30h,0,0,0,0,0,0,0,0,0,0                          ; 83: "'" ‡ rka vpravo
db        0,0,0,0,0,0,0f0h,0,0,0,0,0,0,0                             ; 84: "-" kr tk  poml‡ka
db        0,0,066h,0cch,0,0,0,0,0,0,0,0,0,0                          ; 85: " 2 ‡ rky
db        0,0,0,0,0,0,0,0,0,0,10h,10h,1ch,0                          ; 86: pati‡ka
db        0,6ch,38h,10h,0,0,0,0,0,0,0,0,0,0                          ; 87: h ‡ek
db        0,066h,3ch,0,0,0,0,0,0,0,0,0,0,0                           ; 88: miska
db        0,0,0,0,0,0,0,0,0,0,0,18h,0ch,38h                          ; 89: oc sek
db        0,0,66h,66h,0,0,0,0,0,0,0,0,0,0                            ; 91: "ù" p©ehlasov n¡


font16   label     byte

db 6,0ch,10h,38h,6Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,0,0,0,0      ; 0: "" s ‡ rkou
db 0c6h,7ch,10h,38h,6Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,0,0,0,0   ; 2: "A" s h ‡kem
db 0,0,0c6h,7ch,0,78h,0Ch,7Ch,0CCh,0CCh,0CCh,76h,0,0,0,0             ; 3: "a" s h ‡kem
db 7ch,0c6h,10h,38h,6Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,0,0,0,0   ; 6: "A" se st©¡¨kou
db 0,0,10h,38h,6Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0Ceh,8,0eh,0,0      ; 8: "A" s no‘i‡kou
db 0,0,0,0,0,78h,0Ch,7Ch,0CCh,0CCh,0CCh,76h,10h,1ch,0,0              ; 9: "a" s no‘i‡kou
db 6,0ch,3Ch,66h,0C2h,0C0h,0C0h,0C0h,0C0h,0C2h,66h,3Ch,0,0,0,0       ; 10: "C" s ‡ rkou
db 0,0ch,18h,30h,0,7Ch,0C6h,0C0h,0C0h,0C0h,0C6h,7Ch,0,0,0,0          ; 11: "c" s ‡ rkou
db 66h,3ch,3ch,66h,0c2h,0c0h,0C0h,0C0h,0C0h,0C2h,66h,3Ch,0,0,0,0     ; 12: "€" s h ‡kem
db 0,66h,3ch,18h,0,7Ch,0C6h,0C0h,0C0h,0C0h,0C6h,7Ch,0,0,0,0          ; 13: "‡" s h ‡kem
db 0cch,78h,0F8h,6Ch,66h,66h,66h,66h,66h,66h,6Ch,0F8h,0,0,0,0        ; 16: "…" s h ‡kem
db 66h,3ch,0,1Ch,0Ch,3Ch,6Ch,0CCh,0CCh,0CCh,0CCh,76h,0,0,0,0         ; 17: "ƒ" s h ‡kem
db 0,0,0F8h,6Ch,66h,66h,76h,0e6h,66h,66h,6Ch,0F8h,0,0,0,0            ; 18: "D" p©e¨krnut‚
db 0,0,0Ch,1eh,0Ch,3Ch,6Ch,0CCh,0CCh,0CCh,0CCh,76h,0,0,0,0           ; 19: "d" p©e¨krtnut‚
db 0ch,18h,0FEh,66h,62h,68h,78h,68h,60h,62h,66h,0FEh,0,0,0,0         ; 20: "" s ‡ rkou
db 66h,3ch,0FEh,66h,62h,68h,78h,68h,60h,62h,66h,0FEh,0,0,0,0         ; 22: "‰" s h ‡kem
db 0,66h,3ch,18h,0,7Ch,0C6h,0FEh,0C0h,0C0h,0C6h,7Ch,0,0,0,0          ; 23: "ˆ" s h ‡kem
db 0c6h,0,0FEh,66h,62h,68h,78h,68h,60h,62h,66h,0FEh,0,0,0,0          ; 24: "E" p©ehlasovan‚
db 0,0,0FEh,66h,62h,68h,78h,68h,60h,62h,66h,0FEh,10h,1ch,0,0         ; 26: "E" s no‘i‡kou
db 0,0,0,0,0,7Ch,0C6h,0FEh,0C0h,0C0h,0C6h,7Ch,10h,1ch,0,0            ; 27: "e" s no‘i‡kou
db 0ch,18h,0,3ch,18h,18h,18h,18h,18h,18h,18h,3Ch,0,0,0,0             ; 28: "‹" s ‡ rkou
db 7eh,0c3h,3Ch,18h,18h,18h,18h,18h,18h,18h,18h,3Ch,0,0,0,0          ; 30: "I" se st©¡¨kou
db 0,18h,3Ch,66h,0,38h,18h,18h,18h,18h,18h,3Ch,0,0,0,0               ; 31: "i" se st©¡¨kou
db 6,6,0F4h,60h,60h,60h,60h,60h,60h,62h,66h,0FEh,0,0,0,0             ; 32: "Š" s ‡ rkou
db 3,3,72h,30h,30h,30h,30h,30h,30h,30h,30h,78h,0,0,0,0               ; 33: "" s ‡ rkou
db 1bh,0eh,0F4h,60h,60h,60h,60h,60h,60h,62h,66h,0FEh,0,0,0,0         ; 34: "œ" s h ‡kem
db 33h,1eh,70h,30h,30h,30h,30h,30h,30h,30h,30h,78h,0,0,0,0           ; 35: "Œ" s h ‡kem
db 0,0,0F0h,60h,60h,60h,70h,0e0h,60h,62h,66h,0FEh,0,0,0,0            ; 36: "L" p©e¨krtnut‚
db 0,0,38h,18h,18h,18h,1ch,38h,18h,18h,18h,3Ch,0,0,0,0               ; 37: "l" p©e¨ktnut‚
db 0ch,18h,0c6h,0E6h,0F6h,0FEh,0DEh,0CEh,0C6h,0C6h,0C6h,0C6h,0,0,0,0 ; 38: "N" s ‡ rkou
db 0,6,0ch,18h,0,0DCh,66h,66h,66h,66h,66h,66h,0,0,0,0                ; 39: "n" s ‡ rkou
db 6ch,38h,0c6h,0E6h,0F6h,0FEh,0DEh,0CEh,0C6h,0C6h,0C6h,0C6h,0,0,0,0 ; 40: "¥" s h ‡kem
db 0,66h,3ch,18h,0,0DCh,66h,66h,66h,66h,66h,66h,0,0,0,0              ; 41: "¤" s h ‡kem
db 0ch,18h,0,7ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,7Ch,0,0,0,0      ; 42: "•" s ‡ rkou
db 7ch,0c6h,0,7ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,7Ch,0,0,0,0     ; 44: "§" se st©¡¨kou
db 66h,0cch,0,7ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,7Ch,0,0,0,0     ; 48: "O" se 2 ‡ rkami
db 0,66h,0cch,0,0,7Ch,0C6h,0C6h,0C6h,0C6h,0C6h,7Ch,0,0,0,0           ; 49: "o" se 2 ‡ rkami
db 0ch,18h,0FCh,66h,66h,66h,7Ch,6Ch,66h,66h,66h,0E6h,0,0,0,0         ; 50: "«" s ‡ rkou
db 0,6,0ch,18h,0,0DCh,76h,66h,60h,60h,60h,0F0h,0,0,0,0               ; 51: "ª" s ‡ rkou
db 0cch,78h,0FCh,66h,66h,66h,7Ch,6Ch,66h,66h,66h,0E6h,0,0,0,0        ; 52: "ž" s h ‡kem
db 0,66h,3ch,18h,0,0DCh,76h,66h,60h,60h,60h,0F0h,0,0,0,0             ; 53: "©" s h ‡kem
db 0ch,18h,7Ch,0C6h,0C6h,60h,38h,0Ch,6,0C6h,0C6h,7Ch,0,0,0,0         ; 54: "S" s ‡ rkou
db 0,6,0ch,18h,0,7Ch,0C6h,60h,38h,0Ch,0C6h,7Ch,0,0,0,0               ; 55: "s" s ‡ rkou
db 66h,3ch,7Ch,0C6h,0C6h,60h,38h,0Ch,6,0C6h,0C6h,7Ch,0,0,0,0         ; 56: "›" s h ‡kem
db 0,66h,3ch,18h,0,7Ch,0C6h,60h,38h,0Ch,0C6h,7Ch,0,0,0,0             ; 57: "¨" s h ‡kem
db 0,0,7Ch,0C6h,0C6h,60h,38h,0Ch,6,0C6h,0C6h,7Ch,18h,0ch,78h,0       ; 58: "S" s oc skem
db 0,0,0,0,0,7Ch,0C6h,60h,38h,0Ch,0C6h,7Ch,18h,0ch,78h,0             ; 59: "s" s oc skem
db 66h,3ch,7Eh,7Eh,5Ah,18h,18h,18h,18h,18h,18h,3Ch,0,0,0,0           ; 62: "T" s h ‡kem
db 1bh,0eh,14h,30h,30h,0FCh,30h,30h,30h,30h,36h,1Ch,0,0,0,0          ; 61: "t" s h ‡kem
db 0,0,7Eh,7Eh,5Ah,18h,18h,18h,18h,18h,18h,3Ch,18h,0ch,78h,0         ; 62: "T" s oc skem
db 0,0,10h,30h,30h,0FCh,30h,30h,30h,30h,36h,1Ch,18h,0ch,78h,0        ; 63: "t" s oc skem
db 0ch,18h,0,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,7Ch,0,0,0,0     ; 64: "—" s ‡ rkou
db 38h,6ch,38h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,7Ch,0,0,0,0   ; 66: "¦" s krou‘kem
db 0,38h,6ch,38h,0,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,76h,0,0,0,0         ; 67: "–" s krou‘kem
db 63h,0c6h,0,0C6h,0c6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,7Ch,0,0,0,0    ; 70: "U" se 2 ‡ rkami
db 0,33h,66h,0cch,0,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,76h,0,0,0,0        ; 71: "u" se 2 ‡ rkami
db 0ch,18h,66h,66h,66h,66h,3Ch,18h,18h,18h,18h,3Ch,0,0,0,0           ; 72: "" s ‡ rkou
db 0,6,0ch,18h,0,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,7Eh,6,0Ch,0F8h,0      ; 73: "˜" s ‡ rkou
db 0ch,18h,0FEh,0C6h,86h,0Ch,18h,30h,60h,0C2h,0C6h,0FEh,0,0,0,0      ; 74: "Z" s ‡ rkou
db 0,6,0ch,18h,0,0FEh,0CCh,18h,30h,60h,0C6h,0FEh,0,0,0,0             ; 75: "z" s ‡ rkou
db 0cch,78h,0FEh,0C6h,86h,0Ch,18h,30h,60h,0C2h,0C6h,0FEh,0,0,0,0     ; 76: "’" s h ‡kem
db 0,66h,3ch,18h,0,0FEh,0CCh,18h,30h,60h,0C6h,0FEh,0,0,0,0           ; 77: "‘" s h ‡kem
db 18h,18h,0FEh,0C6h,86h,0Ch,18h,30h,60h,0C2h,0C6h,0FEh,0,0,0,0      ; 78: "Z" s te‡kou
db 0,0,18h,18h,0,0FEh,0CCh,18h,30h,60h,0C6h,0FEh,0,0,0,0             ; 79: "z" s te‡kou
db 0,7Ch,0C6h,60h,38h,6Ch,0C6h,0C6h,6Ch,38h,0Ch,0C6h,7Ch,0,0,0       ; 80: "­" paragraf
db 0,0,0,0c6h,0c6h,6ch,6Ch,38h,38h,6Ch,6ch,0c6h,0c6h,0,0,0           ; 81: "x" p©e¨krtnut¡
db 0,0,0,0c6h,0c6h,7ch,6ch,7ch,0c6h,0c6h,0,0,0,0,0,0                 ; 82: "x" x s d¡rou
db 0,6,0ch,18h,0,0,0,0,0,0,0,0,0,0,0,0                               ; 83: "'" ‡ rka vpravo
db 0,0,0,0,0,3ch,0,0,0,0,0,0,0,0,0,0                                 ; 84: "-" kr tk  poml‡ka
db 0,33h,66h,0cch,0,0,0,0,0,0,0,0,0,0,0,0                            ; 85: " 2 ‡ rky
db 0,0,0,0,0,0,0,0,0,0,0,10h,10h,1ch,0,0                             ; 86: pati‡ka
db 0,0cch,78h,30h,0,0,0,0,0,0,0,0,0,0,0,0                            ; 87: h ‡ek
db 0,0c6h,7ch,0,0,0,0,0,0,0,0,0,0,0,0,0                              ; 88: miska
db 0,0,0,0,0,0,0,0,0,0,0,0,18h,0ch,78h,0                             ; 89: oc sek
db 0,0c6h,0c6h,0,0,0,0,0,0,0,0,0,0,0,0,0                             ; 91: "ù" p©ehlasov n¡


endrez   label     near                     ; konec rezidentn¡ ‡ sti

; *****************************************************************************
;                         Instalace programu
; *****************************************************************************

errtxt   db        'Nen¡ nainstalov na karta EGA/VGA !',13,10,'$'

help     db        'CS fonty EGA/VGA: /K=kod Kamenickych, /L=Latin 2, '
         db        '/0=IBM',13,10,'$'


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

         add       di,3
         xchg      ax,bp
         stosw                              ; ulo‘en¡ offsetu adresy
         xchg      ax,bp
         stosw                              ; ulo‘en¡ segmentu adresy
         ret


TestVGA:                                  ;* test karty VGA
                                            ; VSTUP: CY=nen¡ karta VGA
         mov       ax,1a00h
         int       10h                      ; dotaz na po‡et linek na znak
         cmp       al,1ah                   ; je funkce obsluhovan  ?
         jne       DetCardH                 ; funkce nen¡ obsluhovan 
         cmp       bl,7                     ; je 7 linek na znak ?
         je        DetCardC                 ; je karta VGA
         cmp       bl,8
         je        DetCardC                 ; je karta VGA
DetCardH:                                 ;* nen¡ karta VGA
         push      es
         mov       bx,0c000h                ; segment s ROM VGA
         mov       es,bx                    ; segment s ROM VGA
         mov       bx,39h                   ; adresa textu "Z449"
         cmp       word ptr es:[bx],"Z4"    ; je text "Z4" ?
         jne       DetCardD                 ; nen¡ karta VGA
         cmp       word ptr es:[bx+2],"49"  ; je text "49" ?
DetCardD:pop       es
         je        DetCardC                 ; je karta VGA
         stc
DetCardC:ret


public   instal
instal:
                                          ;* test, zda je karta EGA/VGA
         mov       ah,12h
         mov       bl,10h
         int       10h
         jc        error                    ; nen¡ displej EGA/VGA
         cmp       bl,10h
         jne       instal1                  ; je displej EGA/VGA

                                          ;* chyba - nen¡ karta EGA/VGA
error:   lea       dx,[errtxt]              ; chyba - nen¡ karta EGA/VGA
navrat:  mov       ah,9
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
         mov       cl,ds:[80h]              ; po‡et znak– zad n¡
instal3: jcxz      instal6
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; oddˆlovac¡ znak ?
         jbe       instal3                  ; je oddˆlovac¡ znak
         cmp       al,"/"                   ; je parametr ?
         jne       navrat                   ; chyba zad n¡
         jcxz      navrat                   ; chyba zad n¡
         lodsb                              ; znak parametru
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         or        al,20h                   ; p©evod na mal‚ p¡smeno
         cmp       al,"k"                   ; k¢d Kamenick˜ch ?
         jne       instal4                  ; nen¡ k¢d Kamenick˜ch
         mov       byte ptr es:[font],0     ; k¢d Kamenick˜ch
         jmp       short instal3            ; dal¨¡ znak
instal4: cmp       al,"l"                   ; k¢d Latin 2 ?
         jne       instal5                  ; nen¡ k¢d Latin 2
         mov       byte ptr es:[font],1     ; k¢d Latin 2
         jmp       short instal3            ; dal¨¡ znak
instal5: cmp       al,"0"                   ; vypnut¡ obsluhy ?
         jne       navrat                   ; chyba zad n¡
         mov       byte ptr es:[font],-1    ; standardn¡ k¢d IBM
         jmp       short instal3            ; dal¨¡ znak

instal6:                                  ;* je to prvn¡ instalace programu ?
         mov       ax,es
         mov       bx,cs
         cmp       ax,bx                    ; je program nainstalovan˜ ?
         je        instal7                  ; nen¡ je¨tˆ nainstalovan˜

         mov       bp,offset instaluj
         call      inform                   ; zobrazen¡ informa‡n¡ho textu
         int       20h                      ; konec programu

                                          ;* zji¨tˆn¡ adres syst‚mov˜ch font–
instal7:
         mov       di,offset fonty+1-3      ; adresy syst‚mov˜ch font–
         mov       bh,3                     ; fonty 8x8
         call      detfont                  ; detekce fontu 8x8
         mov       bh,2                     ; fonty 8x14
         call      detfont                  ; detekce fontu 8x14

         push      es
         push      di
         call      testvga                  ; je karta VGA ?
         pop       di
         pop       es
         jc        instalc                  ; nen¡ karta VGA
                                          ;* je karta VGA
         mov       bh,6                     ; fonty 8x16
         call      detfont                  ; detekce fontu 8x16
         mov       dx,offset endrez + 256*16 ; konec pro VGA kartu
         mov       bx,offset endrez         ; za‡ tek bufferu pro VGA kartu
         jmp       short instalb
                                          ;* nen¡ karta VGA
instalc: mov       dx,offset font16 + 256*14 ; konec pro EGA kartu
         mov       bx,offset font16         ; za‡ tek bufferu pro EGA kartu
         mov       byte ptr cs:[tabfnt16],0 ; zru¨en¡ fontu 8x16

instalb: mov       cs:[adrbuff],bx          ; nastaven¡ adresy za‡ tku bufferu

                                          ;* je pot©eba p©esouvat ?
         lea       bp,[instaluj]            ; star˜ za‡ tek instala‡n¡ ‡ sti
         cmp       bp,dx                    ; je konec pod instala‡n¡ ‡ st¡ ?
         jnb       instaluj                 ; nen¡ t©eba p©esouvat

                                          ;* je dost m¡sta ?
         mov       di,dx
         add       di,(koneci-instaluj)+512 ; nov˜ konec programu s rezervou
         cmp       sp,di                    ; je dost m¡sta v pamˆti ?
         jb        instaluj                 ; v pamˆti nen¡ dost m¡sta

                                          ;* p©esun se provede
         push      cs
         pop       es
         mov       bp,dx                    ; konec rezidentn¡ ‡ sti
         add       bp,16+15+4               ; nov˜ za‡ tek programu
         mov       si,offset koneci-1       ; star˜ konec programu
         lea       di,[bp+(koneci-instaluj)-1]; nov˜ konec programu
         mov       cx,offset(koneci-instaluj) ; d‚lka programu
         std                                ; smˆr nahoru
         rep       movsb                    ; p©enesen¡ programu nahoru
         cld                                ; n vrat smˆru
         clc                                ; p©¡znak - p©esun OK
         push      bp                       ; startovac¡ adresa
         ret                                ; skok do programu


; -------------------------- instala‡n¡ ‡ st programu -------------------------

public   instaluj
instaluj:                                 ;* instalace obsluh p©eru¨en¡
         pushf
         push      dx
         mov       ax,3510h
         int       21h
         mov       word ptr ds:[old10],bx
         mov       word ptr ds:[old10+2],es
         mov       dx,offset int10
         mov       ax,2510h
         int       21h
         pop       dx
         push      cs
         pop       es
         popf
         jc        instali                  ; instalace bez inicializace



         push      dx                       ; konec rezidentn¡ ‡ sti
         call      inform
         pop       dx
instali: int       27h                      ; instalace programu



inform:                                   ;* zobrazen¡ informace o fontech


                                          ;* £schova pozice kurzoru
         push      bp
         push      es
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
         pop       bp


         lea       dx,[bp+(uvtxt-instaluj)] ; prvn¡ ‡ st textu
         mov       ah,9
         int       21h                      ; zobrazen¡ prvn¡ ‡ sti textu
         lea       dx,[bp+(uvtxtk-instaluj)]; ‡e¨tina Kamenick˜ch
         cmp       byte ptr es:[font],0     ; je ‡e¨tina Kamenick˜ch ?
         je        inform2                  ; ‡e¨tina Kamenick˜ch
         lea       dx,[bp+(uvtxtl-instaluj)]; ‡e¨tina Latin 2
         cmp       byte ptr es:[font],1     ; je ‡e¨tina Latin 2 ?
         je        inform2                  ; je ‡e¨tina Latin 2
         lea       dx,[bp+(uvtxt0-instaluj)]; ‡e¨tina vypnuta
inform2: mov       ah,9
         int       21h                      ; zobrazen¡ druh‚ ‡ sti textu
         ret



uvtxt    db        'CS fonty EGA/VGA V2.0 - k¢d $'

uvtxtk   db        'Kamenick˜ch; (c) Miroslav Nˆme‡ek',13,10,'$'
uvtxtl   db        'Latin 2; (c) Miroslav NØmeŸek',13,10,'$'
uvtxt0   db        'IBM; (c) Miroslav Nemecek',13,10,'$'



koneci:                                   ;* konec instalace



code     ends
         end       start

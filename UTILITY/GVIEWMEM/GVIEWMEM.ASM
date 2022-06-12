
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ test, zda je dost pamˆti

Start:   mov       dx,offset MemTxt         ; text - nedostatek pamˆti
         cmp       sp,offset KonecPrg + 200h ; konec programu + rezerva z sob.
         jb        Chyba0                   ; chyba - nedostatek pamˆti

; ------ test, zda je videokarta VGA

         mov       ax,1a00h
         int       10h                      ; poskytnut¡ kombinace displeje
         cmp       al,1ah                   ; je slu‘ba podporovan  ?
         jne       Chyba                    ; slu‘ba nen¡ podporovan  - nen¡ VGA

; ------ nastaven¡ videom¢du 13h 320x200/256 barev

         mov       ax,13h
         int       10h                      ; nastaven¡ videom¢d 13h

; ------ test, zda se videom¢d nastavil

         mov       ah,0fh
         int       10h                      ; dotaz na nastaven˜ videom¢d
         cmp       al,13h                   ; nastavil se videom¢d ?
         je        Start1                   ; videom¢d je OK

; ------ chyba - nen¡ karta VGA

Chyba:   mov       dx,offset ErrTxt
Chyba0:  push      cs
         pop       ds                       ; DS<-CS (nˆkter‚ Hercules ni‡¡ DS)
         mov       ah,9
         int       21h
         int       20h

; ------ inicializace palet displeje

Start1:  call      InitPal                  ; inicializace palet displeje

; ------ p©¡prava adresy k zobrazen¡

         mov       ax,cs                    ; AX <- segment tohoto programu
         and       al,not 0fh               ; zarovn n¡ na 256 bajt–
         mov       ds:[Adresa],ax           ; adresa k zobrazen¡
         not       ax
         mov       ds:[OldAdr],ax           ; adresa nen¡ zobrazena

; ------ zobrazen¡ mapy barev

         cld
         mov       di,10*320 + 320 - 20
         mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamˆti
         mov       ch,0

Start11: stosb
         mov       es:[di+320-1],al

         inc       ax
         test      al,3
         jnz       Start14
         inc       di

Start14: test      al,0fh
         jnz       Start11
         add       di,2*320 - 16 - 4
         test      al,30h
         jnz       Start11
         add       di,320
         test      al,0f0h
         jnz       Start11

; ------ zobrazen¡ oblasti pamˆti

Start2:  mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamˆti
         mov       dx,ds:[Adresa]           ; segment adresy k zobrazen¡
         mov       bx,200                   ; po‡et linek k zobrazen¡
         cld
         mov       di,32+1                  ; adresa k ukl d n¡
         mov       ch,0                     ; CH <- 0

Start3:  xor       si,si                    ; SI <- offset v segmentu pamˆti
         xor       ax,ax
         or        dl,dl                    ; je odstavec 1000h ?
         jnz       Start31
         mov       ax,31*256+31
Start31: stosb
         stosw
         stosw
         stosw
         mov       ds,dx                    ; DS <- segment adresy
         mov       cl,256/2                 ; po‡et slov k p©esunu
         rep       movsw                    ; p©esun jedn‚ linky dat
         add       dx,16                    ; posun adresy o linku
         add       di,320-256-7
         dec       bx                       ; ‡¡ta‡ linek k zobrazen¡
         jnz       Start3                   ; zobrazen¡ dal¨¡ linky

         push      cs
         pop       ds                       ; DS <- segment programu

; ------ test, zda byly adresy zmˆnˆny (to aby zobrazen¡ neblikalo)

         mov       dx,ds:[Adresa]           ; adresa k zobrazen¡
         cmp       dx,ds:[OldAdr]           ; je adresa ji‘ zobrazena ?
         je        Start6                   ; adresa se nezmˆnila
         mov       ds:[OldAdr],dx           ; £schova adresy

; ------ vymaz n¡ sloupe‡ku adres

         xor       di,di
         mov       bx,200
         xor       ax,ax                    ; AX <- 0 nulovac¡ slovo
Start32: mov       cl,32/2                  ; po‡et slov k vymaz n¡
         rep       stosw                    ; vymaz n¡ jedn‚ linky
         add       di,320-32
         dec       bx
         jnz       Start32

; ------ stanoven¡ adresy prvn¡ zobrazen‚ adresy

         add       dx,3*256/16-16           ; minim ln¡ adresa
         mov       di,-320                  ; po‡ te‡n¡ adresa ve videopamˆti
Start34: add       dx,16                    ; zv˜¨en¡ ukazatele adresy
         add       di,320                   ; zv˜¨en¡ adresy v pamˆti
         test      dl,0f0h                  ; je odstavec 1000h ?
         jnz       Start34                  ; nen¡ odstavec - posun o linku

; ------ zobrazen¡ adresy

Start35: mov       al,dh                    ; bajt HIGH
         call      HexByte                  ; zobrazen¡ bajtu HEX
         mov       al,dl                    ; bajt LOW
         call      HexByte                  ; zobrazen¡ bajtu LOW

; ------ p©¡prava pro dal¨¡ adresu

         add       di,16*320-4*8
         jc        Start6
         inc       dh
         cmp       di,200*320-8*320
         jbe       Start35

; ------ ‡ek n¡ na stisk kl vesy

Start6:  mov       ah,1
         int       16h
         jnz       Start61
         jmp       Start2
Start61: mov       ah,0
         int       16h

; ------ posun o linku nahoru (k ni‘¨¡m adres m)

         cmp       ax,4800h
         jne       Start62
         sub       word ptr ds:[Adresa],16
         jmp       short Start6

; ------ posun o linku dol– (k vy¨¨¡m adres m)

Start62: cmp       ax,5000h
         jne       Start63
         add       word ptr ds:[Adresa],16
         jmp       short Start6

; ------ posun o str nku nahoru (k ni‘¨¡m adres m)

Start63: cmp       ax,4900h
         jne       Start64
         sub       word ptr ds:[Adresa],16*16*12
         jmp       short Start6

; ------ posun o str nku dol– (k vy¨¨¡m adres m)

Start64: cmp       ax,5100h
         jne       Start65
         add       word ptr ds:[Adresa],16*16*12
         jmp       short Start6

; ------ p©eru¨en¡ programu

Start65: or        ax,ax                    ; je kl vesa Ctrl-Break ?
         jz        Konec                    ; je kl vesa Ctrl-Break
         cmp       al,27                    ; je kl vesa ESC ?
         jne       Start6                   ; nen¡ kl vesa ESC

; ------ nastaven¡ textov‚ho videom¢du

Konec:   mov       ax,3
         int       10h                      ; nastaven¡ text. m¢du 3

; ------ zobrazen¡ z vˆre‡n‚ho textu

         push      cs
         pop       ds
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h
         int       20h


; -----------------------------------------------------------------------------
;        dek¢dov n¡ bajtu AL v HEX k¢du (ukl dac¡ adresa ES:DI)
; -----------------------------------------------------------------------------

HexByte  PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      HexChr
         pop       ax

HexChr:  push      ax
         push      bx
         push      cx
         push      si

         cld
         and       ax,0fh
         shl       ax,1
         shl       ax,1
         shl       ax,1
         add       ax,offset Fonty
         xchg      ax,si                    ; SI <- adresa znaku

         mov       cx,8                     ; po‡et linek k dek¢dov n¡
HexChr1: lodsb
         mov       ah,al
         mov       bx,8
HexChr2: shl       ah,1
         mov       al,0
         jnc       HexChr3
         mov       al,31
HexChr3: stosb
         dec       bx
         jnz       HexChr2
         add       di,320-8
         loop      HexChr1

         pop       si
         pop       cx
         pop       bx
         pop       ax
         sub       di,8*320-8
         ret

HexByte  ENDP

; -----------------------------------------------------------------------------
;                    inicializace univerz ln¡ch palet
; -----------------------------------------------------------------------------
; Tato definice palet je pou‘iteln  jako univerz ln¡ definice palet - jednotliv‚
; barvy jsou rovnomˆrnˆ rozlo‘eny a lze je jednodu¨e vyj d©it. Proto je tato
; definice vhodn  nap©. pro konverzi z TRUE COLOR barev.
;
; jednotliv‚ slo‘ky barev maj¡ hodnoty:
;        ‡erven  .... (0 a‘ 5) * 10 ...... 0, 10, 20, 30, 40, 50
;        zelen  ..... (0 a‘ 6) *  9 ...... 0,  9, 18, 27, 36, 45, 54
;        modr  ...... (0 a‘ 5) * 10 ...... 0, 10, 20, 30, 40, 50
;
; ‡¡slo barvy = ‡erven  + 6*(zelen  + 7*modr )   (v˜sledek > 30 -> v˜sledek + 1)
;             (‡erven  = 0 a‘ 5, zelen  = 0 a‘ 6, modr  = 0 a‘ 5)
;
; Barvy ‡¡slo 253 a 254 (pop©. 255) nejsou vyu‘ity.
;
; Ovlada‡e my¨i zpravidla pou‘¡vaj¡ k zobrazen¡ kurzoru barvy 0 (‡ern ) a 31
; (b¡l ), nˆkter‚ 255 (b¡l ). Proto je barva ‡¡slo 31 p©esko‡ena a rezervov na
; k zobrazen¡ b¡l‚ barvy. P©i pou‘it¡ je nutno prov dˆt korekci pro barvy > 30
; ode‡ten¡m nebo p©i‡ten¡ 1 k ‡¡slu barvy.
; -----------------------------------------------------------------------------

InitPal  PROC      NEAR

; ====== standardn¡ sada palet - bajt 255 je ‡ern˜ (oblast mezi ROM)

         mov       bx,255                   ; hodnota pro 255
         xor       cx,cx
         xor       dx,dx
         mov       ax,1010h
         int       10h                      ; nastaven¡ palet pro barvu 255
         ret


;; ====== univerz ln¡ sada palet
;
;; ------ p©¡prava registr– k sestaven¡ tabulky palet
;
;         push      ds
;         pop       es                       ; ES <- segment programu
;         mov       di,offset Palety
;         xor       bx,bx                    ; BH = zelen , BL = ‡erven 
;         mov       al,0                     ; AL = modr 
;         cld
;         mov       cx,31                    ; ‡¡ta‡ pro p©esko‡en¡ b¡l‚ barvy
;
;; ------ ulo‘en¡ palet jednoho bodu
;
;InitPal1:mov       ds:[di],bx               ; BL=‡erven , BH=zelen 
;         inc       di
;         inc       di
;         stosb                              ; modr 
;
;; ------ ‡¡t n¡ pro b¡lou barvu (‡¡slo 31)
;
;         dec       cx
;         jnz       InitPal2
;         mov       word ptr ds:[di],63*256 + 63
;         inc       di
;         inc       di
;         mov       byte ptr ds:[di],63
;         inc       di
;
;; ------ ‡¡t n¡ ‡erven‚ barvy (nejni‘¨¡ v ha)
;
;InitPal2:add       al,10
;         cmp       al,60
;         jb        InitPal1
;         mov       al,0
;
;; ------ ‡¡t n¡ zelen‚ barvy (st©edn¡ v ha)
;
;         add       bh,9
;         cmp       bh,63
;         jb        InitPal1
;         mov       bh,0
;
;; ------ ‡¡t n¡ modr‚ barvy (nejvy¨¨¡ v ha)
;
;         add       bl,10
;         cmp       bl,60
;         jb        InitPal1
;
;; ------ inicializace zbyl˜ch 3 barev na b¡lou
;
;         mov       al,63
;         mov       cx,3*3
;         rep       stosb
;
;; ------ nastaven¡ palet na displej
;
;         mov       dx,offset Palety         ; tabulka definice palet
;         mov       ch,1                     ; po‡et barev = 256 (CL=0 !)
;         xor       bx,bx                    ; BX <- 0
;         mov       ax,1012h
;         int       10h                      ; nastaven¡ palet VGA
;         ret

InitPal  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Fonty    label     byte
         db        01111100b                ; 48 "0"
         db        11001110b
         db        11011110b
         db        11110110b
         db        11100110b
         db        11000110b
         db        01111100b
         db        00000000b

         db        00110000b                ; 49 "1"
         db        01110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        11111100b
         db        00000000b

         db        01111000b                ; 50 "2"
         db        11001100b
         db        00001100b
         db        00111000b
         db        01100000b
         db        11001100b
         db        11111100b
         db        00000000b

         db        01111000b                ; 51 "3"
         db        11001100b
         db        00001100b
         db        00111000b
         db        00001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00011100b                ; 52 "4"
         db        00111100b
         db        01101100b
         db        11001100b
         db        11111110b
         db        00001100b
         db        00011110b
         db        00000000b

         db        11111100b                ; 53 "5"
         db        11000000b
         db        11111000b
         db        00001100b
         db        00001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00111000b                ; 54 "6"
         db        01100000b
         db        11000000b
         db        11111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        11111100b                ; 55 "7"
         db        11001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00000000b

         db        01111000b                ; 56 "8"
         db        11001100b
         db        11001100b
         db        01111000b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        01111000b                ; 57 "9"
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        00011000b
         db        01110000b
         db        00000000b

         db        00110000b                ; 65 "A"
         db        01111000b
         db        11001100b
         db        11001100b
         db        11111100b
         db        11001100b
         db        11001100b
         db        00000000b

         db        11111100b                ; 66 "B"
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b

         db        00111100b                ; 67 "C"
         db        01100110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        01100110b
         db        00111100b
         db        00000000b

         db        11111000b                ; 68 "D"
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b

         db        11111110b                ; 69 "E"
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100010b
         db        11111110b
         db        00000000b

         db        11111110b                ; 70 "F"
         db        01100010b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        11110000b
         db        00000000b

MemTxt   db        'Nedostatek pameti !',13,10,'$'
ErrTxt   db        'Lituji, program vyzaduje grafickou kartu VGA !',13,10,'$'

UvTxt    db        'GVIEWMEM V1.0 - graficky prohlizec pamet; Miroslav Nemecek 1994',13,10
         db        'Tento program je PUBLIC DOMAIN - lze volne sirit i modifikovat.',13,10,'$'

Adresa   dw        ?                        ; aktu ln¡ adresa po‡ tku
OldAdr   dw        ?                        ; uschovan˜ star˜ po‡ tek

Palety   db        3*256 dup(?)             ; buffer palet

KonecPrg label     byte                     ; konec programu (pro test pamˆti)

Code     ENDS
         END       Start

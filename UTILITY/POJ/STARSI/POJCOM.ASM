
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

KODJMP   EQU       0E9h                     ; k¢d instrukce JMP NEAR
KODPAX   EQU       50h                      ; k¢d instrukce PUSH AX
KODPBX   EQU       53h                      ; k¢d instrukce PUSH BX

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ p©edefinov n¡ z sobn¡ku

         mov       dx,offset MemTxt         ; text - nedostatek pamˆti
         cmp       sp,offset KONEC + 100h
         jb        Start1                   ; chyba - nedostatek pamˆti
         mov       sp,offset KONEC + 100h   ; nov˜ konec z sobn¡ku

; ------ zmen¨en¡ velikosti programu na minimum

         mov       bx,(offset(KONEC-Start)+10fh+100h)/16 ; d‚lka programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ velikosti programu
         jc        Start1                   ; chyba pamˆti

; ------ vytvo©en¡ datov‚ho bufferu

         mov       bx,1000h                 ; velikost bloku 64 KB
         mov       ah,48h
         int       21h                      ; vytvo©en¡ datov‚ho bufferu
         jc        Start1                   ; chyba - nedostatek pamˆti
         mov       ds:[SoubSegm],ax         ; adresa datov‚ho bufferu

; ------ p©¡prava k dek¢dov n¡ zadan‚ho parametru

         mov       si,81h                   ; za‡ tek textu parametru
         mov       bl,ds:[si-1]             ; po‡et znak– zadan‚ho parametru
         and       bl,7fh                   ; ochrana proti chybˆ zad n¡
         mov       bh,0
         mov       byte ptr ds:[si+bx],0    ; ozna‡en¡ konce textu v bufferu

; ------ nalezen¡ za‡ tku jm‚na souboru

         call      ParSpc                   ; vypu¨tˆn¡ mezer ze za‡ tku textu
         jnc       Start2                   ; je zad n nˆjak˜ text OK

; ------ chyba - nen¡ nic zad no

Start0:  mov       dx,offset HelpTxt        ; text n povˆdy
Start1:  mov       ah,9
         int       21h                      ; zobrazen¡ textu n povˆdy
         mov       ax,4c01h
         int       21h

; ------ nalezen¡ konce jm‚na souboru

Start2:  mov       dx,si                    ; £schova za‡ tku jm‚na souboru
Start3:  call      ParChr                   ; na‡ten¡ znaku parametru
         jc        Start4                   ; konec textu parametru
         jne       Start3                   ; nen¡ mezera
         mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce textu

; ------ otev©en¡ souboru k ochr nˆn¡

Start4:  mov       ax,3d02h
         int       21h                      ; otev©en¡ souboru
         jc        Start0                   ; chyba - soubor nenalezen
         mov       bx,ax                    ; identifik tor souboru

; ------ na‡ten¡ souboru do datov‚ho bufferu

         push      ds
         mov       ds,ds:[SoubSegm]         ; datov˜ buffer
         mov       cx,0ffffh
         xor       dx,dx
         mov       ah,3fh
         mov       word ptr ds:[0],20cdh    ; p©ednastaven¡ INT 20h
         int       21h                      ; na‡ten¡ souboru do pamˆti
         mov       cl,ds:[0]                ; prvn¡ bajt programu
         mov       si,ds:[1]                ; 2. a 3. bajt programu
         pop       ds
         jc        Start0                   ; nˆjak  chyba
         mov       ds:[SoubSize],ax         ; velikost souboru

; ------ £schova za‡ tku programu

         mov       es,ds:[SoubSegm]         ; datov˜ buffer
         mov       byte ptr ds:[PojOld],cl  ; prvn¡ bajt programu
         mov       word ptr ds:[PojOld+1],si ; 2. a 3. bajt programu

; ------ kontrola, zda je program EXE

         mov       dx,offset SizTxt
         cmp       word ptr ds:[PojOld],"MZ"
         je        Start1
         cmp       word ptr ds:[PojOld],"ZM"
         je        Start1

; ------ kontrola velikosti souboru

         cmp       ax,offset(PojBeg-PojEnd)-200h ; asi tak maxim ln¡ velikost
         jae       Start1                   ; nelze ochr nit pojistkou

; ------ kontrola, zda je instrukce JMP NEAR

         cmp       cl,KODJMP                ; je instrukce JMP NEAR ?
         jne       Start5                   ; nen¡ instrukce JMP NEAR

; ------ kontrola, zda je to pojistka

         sub       si,2
         jc        Start5                   ; neplatn˜ skok
         cmp       word ptr es:[si],"JP"    ; je pojistka ?
         jne       Start5                   ; nen¡ pojistka
         cmp       byte ptr es:[si+5],KODPAX ; je PUSH AX ?
         jne       Start5                   ; nen¡ pojistka
         cmp       byte ptr es:[si+6],KODPBX ; je PUSH BX ?
         jne       Start5                   ; nen¡ pojistka

; ------ chyba - program je ji‘ ochr nˆn pojistkou

Start47: mov       dx,offset PojTxt
Start48: jmp       Start1                   ; zobrazen¡ chybov‚ho hl ¨en¡

; ------ resetov n¡ ukazatele v souboru

Start5:  xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele na za‡ tek

; ------ relokace adres v zavadˆ‡i

         mov       ax,ds:[SoubSize]         ; velikost souboru
         inc       ax                       ; zaokrouhlen¡
         and       ax,not 1                 ; zarovn n¡ na slovo
         mov       cx,ax
         mov       byte ptr es:[0],KODJMP   ; k¢d instrukce JMP NEAR
         add       cx,2
         mov       word ptr es:[1],cx       ; offset skoku
         mov       cx,ax
         add       word ptr ds:[PojDelk2+1],cx ; d‚lka programu v bajtech
         shr       cx,1                     ; d‚lka programu ve slovech
         add       word ptr ds:[PojDelk1+1],cx ; d‚lka programu ve slovech
         sub       ax,offset(PojIdn-Start)  ; korekce adres
         add       word ptr ds:[PojS2+1],ax
         add       word ptr ds:[PojS7+3],ax
         add       word ptr ds:[PojS8+1],ax
         sub       word ptr ds:[PojJMPSt+1],ax

; ------ p©enesen¡ zavadˆ‡e do bufferu

         cld
         mov       di,ds:[SoubSize]         ; velikost
         test      di,1
         jz        Start52
         mov       al,0
         stosb                              ; zarovn n¡ na sudou adresu
Start52: mov       si,offset PojBeg
         mov       cx,offset(PojEnd-PojBeg)/2 ; d‚lka zavadˆ‡e ve slovech
         rep       movsw                    ; p©enos zavadˆ‡e do bufferu
;         mov       ds:[SoubSize],di         ; nov  velikost souboru

; ------ v˜po‡et kontroln¡ho sou‡tu souboru

Start6:  push      ds
         mov       cx,di                    ; velikost souboru
         mov       ds,ds:[SoubSegm]
         xor       si,si
         shr       cx,1                     ; velikost souboru ve slovech
         mov       dx,cx                    ; v˜choz¡ hodnota CRC
         dec       cx                       ; kromˆ posledn¡ho slova
         cld
Start62: lodsw                              ; na‡ten¡ slova
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©i‡ten¡ slova
         loop      Start62                  ; dal¨¡ slovo
         rol       dx,1                     ; rotace
         mov       ds:[si],dx               ; kontroln¡ sou‡et

; ------ ulo‘en¡ souboru na disk

         xor       dx,dx
         mov       cx,di                    ; velikost souboru
         mov       ah,40h
         int       21h                      ; z pis souboru na disk
         pop       ds
         jnc       Start9

; ------ chyba

         mov       dx,offset SizTxt
         jmp       Start1

; ------ uzav©en¡ souboru

Start9:  mov       ah,3eh
         int       21h

         int       20h

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         jc        ParSpc3                  ; nen¡ dal¨¡ znak
         je        ParSpc                   ; mezera - vypu¨tˆn¡
         dec       si                       ; n vrat posledn¡ho znaku
ParSpc3: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku DS:SI
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku

         cld
         lodsb                              ; na‡ten¡ znaku z p©¡kazov‚ho © dku

; ------ n hrada tabel toru mezerou

         cmp       al,9
         jne       ParChr1                  ; nen¡ znak tabel toru
         mov       al," "                   ; n hrada tabel toru mezerou

; ------ test, zda je konec © dku

ParChr1: cmp       al," "                   ; je platn˜ znak ?
         jae       ParChr2                  ; je platn˜ znak nebo mezera
         dec       si                       ; n vrat ukazatele textu
         mov       byte ptr ds:[si],0       ; ozna‡en¡ konce textu

ParChr2: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'POJCOM V1.0 - pojistka programu COM; (c) Miroslav Nemecek',13,10,'$'
MemTxt   db        'Nedostatek pameti !',13,10,'$'
HelpTxt  db        'Zadejte platne jmeno souboru COM !',13,10,'$'
PojTxt   db        'Program je jiz chranen pojistkou !',13,10,'$'
SizTxt   db        'Program nelze ochranit pojistkou !',13,10,'$'

SoubSegm dw        0                        ; segment se souborem
;SoubIdn  dw        0                        ; identifik tor souboru
SoubSize dw        0                        ; velikost souboru

;þ

; *****************************************************************************
;
;                                Pojistka
;                        (mus¡ m¡t sudou d‚lku !)
;
; *****************************************************************************

PojBeg   label     byte                     ; za‡ tek pojistky

PojIdn   db        'PJ'                     ; identifik tor pojistky

; !!!!!!!!
PojOld   db        0,0,0                    ; p–vodn¡ za‡ tek programu

; ------ £schova registr–

PojStart:push      ax                       ;Ä¿tyto 2 instrukce = identifikace !
         push      bx                       ;ÄÙ

         push      cx
         push      dx
         push      si
         push      di

         mov       di,100h                  ; konstanta 100h

; ------ kontroln¡ sou‡et programu s pojistkou

; !!!!!!!
PojDelk1:mov       cx,offset(PojEnd-PojBeg)/2 ; d‚lka programu s pojist.(slov)
         mov       si,di                    ; po‡ te‡n¡ adresa programu
         mov       dx,cx                    ; v˜choz¡ hodnota CRC
         cld
PojS1:   lodsw                              ; na‡ten¡ slova
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©i‡ten¡ slova
         loop      PojS1                    ; dal¨¡ slovo
         jz        PojS3                    ; kontroln¡ sou‡et je OK

; ------ chyba - program je po¨kozen

; !!!!!!!
PojS2:   mov       dx,offset PojText1       ; text - program je po¨kozen
         mov       ah,9
         int       21h
         mov       ax,4cfeh
         int       21h                      ; n vrat programu s chybou

; ------ kontrola verze syst‚mu

PojS3:   mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cmp       al,3                     ; je verze syst‚mu alespo¤ 3.00 ?
         jb        PojS7                    ; je n¡zk  verze syst‚mu

; ------ p©¡prava k nalezen¡ cesty

         mov       cx,ds:[2ch]              ; segment prost©ed¡
         jcxz      PojS7                    ; nen¡ prost©ed¡
         push      ds                       ; £schova DS
         mov       ds,cx                    ; segment prost©ed¡
         xor       ax,ax                    ; hledan‚ slovo
         xor       si,si                    ; za‡ tek prost©ed¡

; ------ nalezen¡ textu jm‚na souboru

PojS4:   inc       si                       ; zv˜¨en¡ ukazatele v prost©ed¡
         cmp       ds:[si-1],ax             ; konec prost©ed¡ ?
         jne       PojS4                    ; nalezen¡ konce prost©ed¡
         mov       cx,3                     ; po‡et bajt– ke ‡ten¡
         add       si,cx                    ; za‡ tek jm‚na souboru

; ------ otev©en¡ souboru

         mov       dx,si                    ; adresa textu jm‚na souboru
         mov       ah,3dh
         int       21h                      ; otev©en¡ souboru
         pop       ds                       ; n vrat DS
         jc        PojS7                    ; chyba otev©en¡ souboru
         xchg      ax,bx                    ; identifik tor souboru

; ------ na‡ten¡ za‡ tku souboru

         mov       ah,3fh
         mov       dx,di                    ; za‡ tek programu 100h
         int       21h                      ; na‡ten¡ za‡ tku souboru

; ------ stanoven¡ velikosti souboru

         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; vystaven¡ ukazatele na konec

; ------ kontrola velikosti souboru

; !!!!!!!!
PojDelk2:cmp       ax,offset(PojEnd-PojBeg) ; d‚lka programu s pojistkou
         jne       PojS2                    ; velikost nesouhlas¡

; ------ uzav©en¡ souboru

PojS6:   mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ kontrola za‡ tku souboru

; !!!!!!!!
PojS7:   cmp       word ptr ds:[di+1],offset PojStart-103h ; souhlas¡ offs. skoku ?
         jne       PojS2                    ; nesouhlas¡ offset skoku

; ------ n vrat za‡ tku programu

; !!!!!!!!
PojS8:   mov       si,offset PojOld         ; p–vodn¡ za‡ tek programu
         cld
         movsb
         movsw

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; !!!!!!!!
PojJMPSt:jmp       near ptr Start           ; start programu

PojText1 db        13,'Program POSKOZEN !',13,7,10,'$'

PojCRC   dw        0                        ; kontroln¡ sou‡et programu+pojistka

PojEnd   label     byte                     ; konec pojistky

         EVEN
KONEC    label     near                     ; celkov˜ konec programu

Code     ENDS
         END       Start

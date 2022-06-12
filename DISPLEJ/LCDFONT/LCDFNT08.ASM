
code     segment
         assume    cs:code,ds:code
         org       100h

start:   jmp       instal

old10    dd        0

Int100:  jmp       dword ptr cs:[Old10]

; ------ kontrola, zda je funkce, kter† by mohla fonty p©edefinovat

int10:   cmp       ax,1130h
         je        Int100                   ; je jenom dotaz na stav
         cmp       ah,11h
         je        Int101                   ; je zmàna fontñ
         cmp       ah,0
         jne       Int100

Int101:  pushf
         call      dword ptr cs:[Old10]     ; obsluha pñvodn° funkce

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ kontrola, zda je teÉ font 8 x 8

         xor       ax,ax
         mov       ds,ax
         cmp       word ptr ds:[485h],8     ; je nov† vò®ka znaku 8 linek ?
         jne       Int102                   ; nen° to tento font 8 x 8

; ------ £schova polohy a velikosti kurzoru

         mov       ah,0fh
         pushf
         call      dword ptr cs:[Old10]     ; poskytnut° aktivn° str†nky
         mov       ah,3
         pushf
         call      dword ptr cs:[Old10]     ; poskytnut° informac° o kurzoru
         push      cx                       ; £schova rozmàrñ kurzoru
         push      dx                       ; £schova pozice kurzoru
         push      bx                       ; £schova videostr†nky
         push      word ptr ds:[44ch]       ; £schova velikosti bufferu

; ------ p©°prava registrñ pro textovò videom¢d

         mov       bh,8                     ; 8 bajtñ na znak
         mov       bl,0                     ; blok 0
         mov       cx,256                   ; celkovò poáet znakñ
         mov       dx,0                     ; offset tabulky znakñ

; ------ p©edefinov†n° grafickÇho m¢du

         mov       al,10h                   ; funkce pro textovò m¢d
         mov       ah,ds:[449h]             ; videom¢d
         and       ah,7fh                   ; zru®en° bitu 7
         cmp       ah,7
         je        Int103                   ; je textovò m¢d
         cmp       ah,3
         jbe       Int103                   ; je textovò m¢d

         mov       al,21h                   ; funkce definice graf. fontñ
         mov       cx,8                     ; poáet bajtñ na znak
         mov       dl,ds:[484h]             ; á°slo posledn°ho ©†dku
         inc       dl                       ; poáet ©†dkñ celkem

; ------ p©edefinov†n° fontñ

Int103:  push      cs
         pop       es
         mov       bp,offset fonty
         mov       ah,11h
         pushf
         call      dword ptr cs:[Old10]

; ------ p©edefinov†n° ukazatele INT 43h

         mov       word ptr ds:[10ch],offset fonty
         mov       ds:[10eh],cs

; ------ n†vrat velikosti a pozice kurzoru

         pop       word ptr ds:[44ch]       ; £schova velikosti bufferu
         pop       bx                       ; n†vrat videostr†nky
         pop       dx                       ; pñvodn° pozice kurzoru
         mov       ah,2
         pushf
         call      dword ptr cs:[Old10]     ; n†vrat pozice kurzoru
         pop       cx                       ; pñvodn° velikost kurzoru
         mov       ah,1
         pushf
         call      dword ptr cs:[Old10]     ; n†vrat velikosti kurzoru

; ------ n†vrat registrñ

Int102:  pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret


fonty:

db 064h,044h,038h,000h,060h,092h,00ch,000h  ; 0
db 0Aah,082h,082h,0Bah,092h,082h,082h,07ch  ; 1
db 0D6h,0Feh,0Feh,0C6h,0Eeh,0Feh,0Feh,07ch  ; 2
db 06Ch,0FEh,0FEh,0FEh,0FEh,07Ch,038h,010h  ; 3
db 010h,038h,07Ch,0FEh,07Ch,038h,010h,000h  ; 4
db 038h,010h,0c6h,0Eeh,0c6h,010h,010h,038h  ; 5
db 038h,07ch,0Feh,0Feh,07ch,010h,010h,038h  ; 6
db 000h,000h,018h,03Ch,03Ch,018h,000h,000h  ; 7
db 0FFh,0E7h,0C3h,0C3h,0E7h,0FFh,0FFh,0FFh  ; 8
db 03Ch,042h,042h,042h,042h,03Ch,000h,000h  ; 9
db 0C3h,0bdh,0BDh,0BDh,0bdh,0C3h,0FFh,0FFh  ; 10
db 012h,078h,084h,084h,084h,084h,084h,078h  ; 11
db 082h,082h,082h,07Ch,010h,010h,07Ch,010h  ; 12
db 020h,020h,020h,020h,0e0h,0e0h,0e0h,000h  ; 13
db 042h,042h,042h,042h,046h,0c6h,0c6h,0C0h  ; 14
db 0d6h,038h,0Eeh,038h,0d6h,010h,010h,000h  ; 15
db 0F0h,0F8h,0Feh,0F8h,0F0h,0E0h,0C0h,080h  ; 16
db 01Eh,03Eh,0fEh,03Eh,01Eh,00Eh,006h,002h  ; 17
db 092h,010h,010h,010h,010h,092h,054h,038h  ; 18
db 044h,044h,044h,044h,000h,000h,044h,044h  ; 19
db 092h,072h,012h,012h,012h,012h,012h,012h  ; 20
db 038h,044h,082h,082h,044h,038h,004h,002h  ; 21
db 000h,000h,000h,0FEh,0FEh,0FEh,0FEh,000h  ; 22
db 010h,010h,010h,092h,054h,038h,010h,0FEh  ; 23
db 010h,010h,010h,010h,010h,010h,010h,010h  ; 24
db 010h,010h,010h,010h,010h,092h,054h,038h  ; 25
db 008h,004h,0FEh,004h,008h,010h,000h,000h  ; 26
db 020h,040h,0FEh,040h,020h,010h,000h,000h  ; 27
db 080h,080h,080h,080h,0FEh,000h,000h,000h  ; 28
db 028h,044h,0FEh,044h,028h,000h,000h,000h  ; 29
db 038h,038h,07Ch,07Ch,0FEh,0FEh,000h,000h  ; 30
db 0FEh,07Ch,07Ch,038h,038h,010h,000h,000h  ; 31
db 000h,000h,000h,000h,000h,000h,000h,000h  ; mezera
db 038h,010h,010h,010h,000h,000h,010h,010h  ; !
db 000h,000h,000h,000h,000h,000h,000h,000h  ; "
db 07Eh,024h,024h,024h,07Eh,024h,024h,000h  ; #
db 090h,090h,07Ch,012h,012h,012h,092h,07Ch  ; $
db 0a2h,044h,008h,010h,020h,044h,08ah,004h  ; %
db 044h,038h,032h,04ch,088h,088h,08Ch,076h  ; &
db 000h,000h,000h,000h,000h,000h,000h,000h  ; '
db 040h,040h,040h,040h,040h,020h,010h,00ch  ; (
db 004h,004h,004h,004h,004h,008h,010h,060h  ; )
db 042h,024h,018h,0Ffh,018h,024h,042h,000h  ; *
db 010h,010h,010h,0feh,010h,010h,010h,000h  ; +
db 000h,000h,000h,000h,010h,010h,010h,010h  ; ,
db 000h,000h,000h,0fEh,000h,000h,000h,000h  ; -
db 000h,000h,000h,000h,000h,000h,010h,010h  ; .
db 008h,008h,010h,010h,020h,020h,040h,040h  ; /
db 07ch,086h,08ah,092h,0a2h,0c2h,07ch,000h  ; 0
db 018h,028h,008h,008h,008h,008h,01ch,000h  ; 1
db 07ch,082h,004h,018h,020h,042h,0feh,000h  ; 2
db 07ch,082h,002h,01ch,002h,082h,07ch,000h  ; 3
db 014h,024h,044h,084h,0FEh,004h,004h,000h  ; 4
db 0feh,080h,0fch,002h,002h,082h,07ch,000h  ; 5
db 01ch,020h,040h,0fch,082h,082h,07ch,000h  ; 6
db 0feh,082h,004h,008h,010h,020h,020h,000h  ; 7
db 07ch,082h,082h,07ch,082h,082h,07ch,000h  ; 8
db 07ch,082h,082h,07eh,002h,002h,07ch,000h  ; 9
db 000h,010h,010h,000h,000h,010h,010h,000h  ; :
db 000h,010h,010h,000h,000h,010h,010h,020h  ; ;
db 008h,010h,020h,040h,020h,010h,008h,000h  ; <
db 000h,0fEh,000h,000h,0fEh,000h,000h,000h  ; =
db 020h,010h,008h,004h,008h,010h,020h,000h  ; >
db 078h,084h,008h,010h,010h,000h,010h,000h  ; ?
db 07ch,082h,092h,092h,09Ch,080h,07Ch,000h  ; @
db 010h,028h,044h,082h,0feh,082h,082h,000h  ; A
db 0fch,042h,042h,07ch,042h,042h,0fch,000h  ; B
db 07ch,082h,080h,080h,080h,082h,07ch,000h  ; C
db 0fch,042h,042h,042h,042h,042h,0fch,000h  ; D
db 0feh,042h,040h,078h,040h,042h,0feh,000h  ; E
db 0feh,042h,040h,078h,040h,040h,0e0h,000h  ; F
db 07ch,082h,080h,080h,08eh,082h,07ch,000h  ; G
db 082h,082h,082h,0feh,082h,082h,082h,000h  ; H
db 038h,010h,010h,010h,010h,010h,038h,000h  ; I
db 00eh,004h,004h,004h,004h,084h,078h,000h  ; J
db 082h,084h,088h,0f0h,088h,084h,082h,000h  ; K
db 0e0h,040h,040h,040h,040h,042h,0feh,000h  ; L
db 082h,0c6h,0aah,092h,082h,082h,082h,000h  ; M
db 082h,0c2h,0a2h,092h,08ah,086h,082h,000h  ; N
db 07ch,082h,082h,082h,082h,082h,07ch,000h  ; O
db 0fch,042h,042h,07ch,040h,040h,0e0h,000h  ; P
db 07ch,082h,082h,082h,092h,08ah,07ch,002h  ; Q
db 0fch,042h,042h,07ch,048h,044h,042h,000h  ; R
db 07ch,082h,080h,07ch,002h,082h,07ch,000h  ; S
db 07eh,010h,010h,010h,010h,010h,010h,000h  ; T
db 082h,082h,082h,082h,082h,082h,07ch,000h  ; U
db 082h,082h,082h,082h,044h,028h,010h,000h  ; V
db 082h,082h,082h,092h,092h,0aah,044h,000h  ; W
db 082h,044h,028h,010h,028h,044h,082h,000h  ; X
db 082h,082h,044h,028h,010h,010h,010h,000h  ; Y
db 0feh,084h,008h,010h,020h,042h,0feh,000h  ; Z
db 038h,020h,020h,020h,020h,020h,038h,000h  ; [
db 080h,040h,020h,010h,008h,004h,002h,000h  ; \
db 01ch,004h,004h,004h,004h,004h,01ch,000h  ; ]
db 010h,028h,000h,000h,000h,000h,000h,000h  ; ^
db 000h,000h,000h,000h,000h,000h,000h,0ffh  ; _
db 000h,020h,010h,000h,000h,000h,000h,000h  ; `
db 000h,000h,078h,004h,07ch,084h,07ah,000h  ; a
db 0c0h,040h,07ch,042h,042h,062h,0dch,000h  ; b
db 000h,000h,07ch,082h,080h,082h,07ch,000h  ; c
db 00Ch,004h,07ch,084h,084h,08ch,076h,000h  ; d
db 000h,000h,07ch,082h,0feh,080h,07ch,000h  ; e
db 038h,040h,0e0h,040h,040h,040h,0e0h,000h  ; f
db 000h,000h,07ah,084h,084h,07ch,004h,078h  ; g
db 0c0h,040h,07ch,042h,042h,042h,0c2h,000h  ; h
db 010h,000h,030h,010h,010h,010h,038h,000h  ; i
db 004h,000h,00ch,004h,004h,004h,044h,038h  ; j
db 0c0h,040h,042h,044h,078h,044h,0c2h,000h  ; k
db 030h,010h,010h,010h,010h,010h,038h,000h  ; l
db 000h,000h,0ech,092h,092h,092h,092h,000h  ; m
db 000h,000h,0dch,062h,042h,042h,042h,000h  ; n
db 000h,000h,07ch,082h,082h,082h,07ch,000h  ; o
db 000h,000h,0fch,042h,042h,07ch,040h,0e0h  ; p
db 000h,000h,07eh,084h,084h,07ch,004h,00eh  ; q
db 000h,000h,09ch,062h,040h,040h,0e0h,000h  ; r
db 000h,000h,07eh,080h,07Ch,002h,0fch,000h  ; s
db 020h,020h,0fch,020h,020h,022h,01ch,000h  ; t
db 000h,000h,084h,084h,084h,084h,07ah,000h  ; u
db 000h,000h,082h,082h,044h,028h,010h,000h  ; v
db 000h,000h,082h,082h,092h,0aah,044h,000h  ; w
db 000h,000h,082h,044h,038h,044h,082h,000h  ; x
db 000h,000h,082h,082h,082h,07eh,002h,07ch  ; y
db 000h,000h,0feh,004h,038h,040h,0feh,000h  ; z
db 00ch,010h,010h,060h,010h,010h,00ch,000h  ; {
db 010h,010h,010h,000h,010h,010h,010h,000h  ; |
db 060h,010h,010h,00ch,010h,010h,060h,000h  ; }
db 032h,04ch,000h,000h,000h,000h,000h,000h  ; ~
db 000h,010h,028h,044h,082h,082h,0feh,000h  ; 

Fonty2:
db 048h,07ch,082h,080h,080h,082h,07ch,000h  ; Ä
db 044h,000h,084h,084h,084h,084h,07ah,000h  ; Å
db 008h,010h,07ch,082h,0feh,080h,07ch,000h  ; Ç
db 00ah,006h,07ch,084h,084h,08ch,076h,000h  ; É
db 044h,000h,078h,004h,07ch,084h,07ah,000h  ; Ñ
db 048h,0fch,042h,042h,042h,042h,0fch,000h  ; Ö
db 048h,07eh,010h,010h,010h,010h,010h,000h  ; Ü
db 044h,038h,07ch,082h,080h,082h,07ch,000h  ; á
db 044h,038h,07ch,082h,0feh,080h,07ch,000h  ; à
db 048h,0feh,040h,078h,040h,042h,0feh,000h  ; â
db 0e2h,042h,040h,040h,040h,042h,0feh,000h  ; ä
db 01ch,038h,010h,010h,010h,010h,038h,000h  ; ã
db 036h,012h,010h,010h,010h,010h,038h,000h  ; å
db 032h,012h,010h,010h,010h,010h,038h,000h  ; ç
db 092h,028h,044h,082h,0feh,082h,082h,000h  ; é
db 012h,02ah,044h,082h,0feh,082h,082h,000h  ; è
db 01ch,0feh,040h,078h,040h,042h,0feh,000h  ; ê
db 044h,038h,0feh,004h,038h,040h,0feh,000h  ; ë
db 044h,0feh,008h,010h,020h,042h,0feh,000h  ; í
db 07ch,000h,07ch,082h,082h,082h,07ch,000h  ; ì
db 044h,000h,07ch,082h,082h,082h,07ch,000h  ; î
db 006h,07ch,082h,082h,082h,082h,07ch,000h  ; ï
db 010h,028h,094h,084h,084h,084h,07ah,000h  ; ñ
db 008h,092h,082h,082h,082h,082h,07ch,000h  ; ó
db 008h,010h,082h,082h,082h,07eh,002h,07ch  ; ò
db 082h,07ch,082h,082h,082h,082h,07ch,000h  ; ô
db 082h,000h,082h,082h,082h,082h,07ch,000h  ; ö
db 044h,07ch,080h,07ch,002h,082h,07ch,000h  ; õ
db 0eah,044h,040h,040h,040h,042h,0feh,000h  ; ú
db 092h,092h,044h,028h,010h,010h,010h,000h  ; ù
db 044h,0fch,042h,07ch,048h,044h,042h,000h  ; û
db 02ah,024h,0fch,020h,020h,022h,01ch,000h  ; ü
db 008h,010h,078h,004h,07ch,084h,07ah,000h  ; †
db 01ch,000h,030h,010h,010h,010h,038h,000h  ; °
db 008h,010h,07ch,082h,082h,082h,07ch,000h  ; ¢
db 008h,010h,084h,084h,084h,084h,07ah,000h  ; £
db 044h,038h,0dch,062h,042h,042h,042h,000h  ; §
db 0aah,0d2h,0a2h,092h,08ah,086h,082h,000h  ; •
db 018h,09ah,082h,082h,082h,082h,07ch,000h  ; ¶
db 0feh,07ch,082h,082h,082h,082h,07ch,000h  ; ß
db 044h,038h,07eh,080h,07Ch,002h,0fch,000h  ; ®
db 044h,038h,09ch,062h,040h,040h,0e0h,000h  ; ©
db 008h,010h,09ch,062h,040h,040h,0e0h,000h  ; ™
db 01ch,0fch,042h,07ch,048h,044h,042h,000h  ; ´
db 044h,008h,012h,026h,04ah,092h,03Eh,002h  ; ¨
db 000h,010h,010h,010h,038h,038h,038h,010h  ; ≠
db 000h,022h,044h,088h,044h,022h,000h,000h  ; Æ
db 000h,088h,044h,022h,044h,088h,000h,000h  ; Ø
db 044h,011h,044h,011h,044h,011h,044h,011h  ; ∞
db 0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h  ; ±
db 077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh  ; ≤
db 010h,010h,010h,010h,010h,010h,010h,010h  ; ≥
db 010h,010h,0F0h,010h,010h,010h,010h,010h  ; ¥
db 010h,0F0h,010h,010h,0F0h,010h,010h,010h  ; µ
db 024h,024h,0E4h,024h,024h,024h,024h,024h  ; ∂
db 000h,000h,0F0h,048h,024h,024h,024h,024h  ; ∑ …ÕÀÕª
db 000h,080h,040h,020h,010h,090h,050h,030h  ; ∏ ∫ ∫ ∫
db 024h,0E4h,004h,004h,0E4h,024h,024h,024h  ; π ÃÕŒÕπ
db 024h,024h,024h,024h,024h,024h,024h,024h  ; ∫ »Õ Õº
db 000h,0c0h,020h,010h,088h,044h,024h,024h  ; ª ⁄ƒ¬ƒø
db 044h,088h,010h,020h,0c0h,000h,000h,000h  ; º ≥ ≥ ≥
db 024h,048h,0f0h,000h,000h,000h,000h,000h  ; Ω √ƒ≈ƒ¥
db 090h,010h,020h,040h,080h,000h,000h,000h  ; æ ¿ƒ¡ƒŸ
db 000h,000h,080h,040h,020h,010h,010h,010h  ; ø ’Õ—Õ∏
db 008h,004h,003h,000h,000h,000h,000h,000h  ; ¿ ≥ ≥ ≥
db 010h,010h,0FFh,000h,000h,000h,000h,000h  ; ¡ ∆ÕÿÕµ
db 000h,000h,0FFh,010h,010h,010h,010h,010h  ; ¬ ‘ÕœÕæ
db 010h,010h,01Fh,010h,010h,010h,010h,010h  ; √ ÷ƒ“ƒ∑
db 000h,000h,0FFh,000h,000h,000h,000h,000h  ; ƒ ∫ ∫ ∫
db 010h,010h,0FFh,010h,010h,010h,010h,010h  ; ≈ «ƒ◊ƒ∂
db 010h,01Fh,010h,010h,01Fh,010h,010h,010h  ; ∆ ”ƒ–ƒΩ
db 024h,024h,027h,024h,024h,024h,024h,024h  ; «
db 022h,011h,008h,004h,003h,000h,000h,000h  ; »
db 000h,003h,004h,008h,011h,022h,024h,024h  ; …
db 024h,0E7h,000h,000h,0FFh,000h,000h,000h  ;  
db 000h,0FFh,000h,000h,0E7h,024h,024h,024h  ; À
db 024h,027h,020h,020h,027h,024h,024h,024h  ; Ã
db 000h,0FFh,000h,000h,0FFh,000h,000h,000h  ; Õ
db 024h,0E7h,000h,000h,0E7h,024h,024h,024h  ; Œ
db 010h,0FFh,000h,000h,0FFh,000h,000h,000h  ; œ
db 024h,024h,0FFh,000h,000h,000h,000h,000h  ; –
db 000h,0FFh,000h,000h,0FFh,010h,010h,010h  ; —
db 000h,000h,0FFh,024h,024h,024h,024h,024h  ; “
db 024h,012h,00fh,000h,000h,000h,000h,000h  ; ”
db 012h,011h,008h,004h,003h,000h,000h,000h  ; ‘
db 000h,003h,004h,008h,011h,012h,014h,018h  ; ’
db 000h,000h,00fh,012h,024h,024h,024h,024h  ; ÷
db 024h,024h,0FFh,024h,024h,024h,024h,024h  ; ◊
db 010h,0FFh,010h,010h,0FFh,010h,010h,010h  ; ÿ
db 020h,040h,080h,000h,000h,000h,000h,000h  ; Ÿ
db 000h,000h,003h,004h,008h,010h,010h,010h  ; ⁄
db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh  ; €
db 000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh  ; ‹
db 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h  ; ›
db 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh  ; ﬁ
db 0FFh,0FFh,000h,000h,000h,000h,000h,000h  ; ﬂ
db 072h,08ch,088h,088h,088h,088h,08ch,072h  ; ‡
db 088h,090h,088h,084h,082h,082h,082h,08Ch  ; ·
db 080h,080h,080h,080h,080h,080h,080h,080h  ; ‚
db 044h,044h,044h,044h,044h,044h,044h,044h  ; „
db 020h,010h,008h,010h,020h,040h,082h,0FEh  ; ‰
db 07Ch,090h,088h,088h,088h,088h,088h,070h  ; Â
db 042h,042h,042h,042h,042h,07Ch,040h,040h  ; Ê
db 09Ch,008h,008h,008h,008h,008h,008h,006h  ; Á
db 044h,082h,082h,082h,044h,038h,010h,010h  ; Ë
db 082h,082h,0BAh,082h,082h,082h,044h,038h  ; È
db 082h,082h,082h,044h,028h,028h,0AAh,0EEh  ; Í
db 010h,038h,044h,042h,042h,042h,042h,03Ch  ; Î
db 06Ch,092h,092h,092h,092h,06ch,000h,000h  ; Ï
db 06ch,09ah,092h,092h,0b2h,06ch,040h,040h  ; Ì
db 080h,080h,0fEh,080h,080h,040h,03Eh,000h  ; Ó
db 082h,082h,082h,082h,082h,082h,082h,082h  ; Ô
db 0FEh,000h,000h,0FEh,000h,000h,0FEh,000h  ; 
db 010h,07ch,010h,010h,000h,000h,07ch,000h  ; Ò
db 008h,004h,008h,010h,020h,040h,000h,0feh  ; Ú
db 020h,040h,020h,010h,008h,004h,000h,0feh  ; Û
db 010h,010h,010h,010h,010h,010h,010h,010h  ; Ù
db 010h,010h,010h,010h,090h,090h,060h,000h  ; ı
db 010h,010h,000h,07ch,000h,010h,010h,000h  ; ˆ
db 000h,076h,0DCh,000h,076h,0DCh,000h,000h  ; ˜
db 000h,000h,000h,000h,000h,000h,000h,000h  ; ¯
db 000h,000h,018h,018h,000h,000h,000h,000h  ; ˘
db 000h,000h,000h,010h,000h,000h,000h,000h  ; ˙
db 008h,008h,088h,048h,028h,018h,008h,000h  ; ˚
db 024h,024h,000h,000h,000h,000h,000h,000h  ; ¸
db 048h,078h,000h,000h,000h,000h,000h,000h  ; ˝
db 07Ch,07Ch,07Ch,07Ch,07Ch,07Ch,000h,000h  ; ˛
db 082h,09ah,0a2h,0a2h,09ah,082h,044h,038h  ; 255

; -----------------------------------------------------------------------------
;                    Instalace fontñ rezidentnà
; -----------------------------------------------------------------------------

Instal:  mov       ax,3510h
         int       21h
         mov       word ptr ds:[Old10],bx
         mov       word ptr ds:[Old10+2],es
         mov       dx,offset Int10
         mov       ax,2510h
         int       21h

         mov       ax,251fh
         mov       dx,offset Fonty2
         int       21h                      ; definice grafickòch fontñ 8 x 8

         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h                      ; inicializace videom¢du

         mov       dx,offset uvtxt
         mov       ah,9
         int       21h

         mov       dx,offset Instal
         int       27h

uvtxt    db        'LCDFNT08 V1.10 - fonty LCD 8 linek; (c) Miroslav Nemecek',13,10,'$'

code     ends
         end       start

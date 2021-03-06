
code     segment
         assume    cs:code,ds:code
         org       100h

start:   jmp       instal

old10    dd        0

Int100:  jmp       dword ptr cs:[Old10]

; ------ kontrola, zda je funkce, kter� by mohla fonty p�edefinovat

int10:   cmp       ax,1130h
         je        Int100                   ; je jenom dotaz na stav
         cmp       ah,11h
         je        Int101                   ; je zm�na font�
         cmp       ah,0
         jne       Int100

Int101:  pushf
         call      dword ptr cs:[Old10]     ; obsluha p�vodn� funkce

; ------ �schova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ kontrola, zda je te� font 8 x 14

         xor       ax,ax
         mov       ds,ax
         cmp       word ptr ds:[485h],14    ; je nov� v��ka znaku 14 linek ?
         jne       Int102                   ; nen� to tento font 8 x 14

; ------ �schova polohy a velikosti kurzoru

         mov       ah,0fh
         pushf
         call      dword ptr cs:[Old10]     ; poskytnut� aktivn� str�nky
         mov       ah,3
         pushf
         call      dword ptr cs:[Old10]     ; poskytnut� informac� o kurzoru
         push      cx                       ; �schova rozm�r� kurzoru
         push      dx                       ; �schova pozice kurzoru
         push      bx                       ; �schova videostr�nky
         push      word ptr ds:[44ch]       ; �schova velikosti bufferu

; ------ p��prava registr� pro textov� videom�d

         mov       bh,14                    ; 14 bajt� na znak
         mov       bl,0                     ; blok 0
         mov       cx,256                   ; celkov� po�et znak�
         mov       dx,0                     ; offset tabulky znak�

; ------ p�edefinov�n� grafick�ho m�du

         mov       al,10h                   ; funkce pro textov� m�d
         mov       ah,ds:[449h]             ; videom�d
         and       ah,7fh                   ; zru�en� bitu 7
         cmp       ah,7
         je        Int103                   ; je textov� m�d
         cmp       ah,3
         jbe       Int103                   ; je textov� m�d

         mov       al,21h                   ; funkce definice graf. font�
         mov       cx,14                    ; po�et bajt� na znak
         mov       dl,ds:[484h]             ; ��slo posledn�ho ��dku
         inc       dl                       ; po�et ��dk� celkem

; ------ p�edefinov�n� font�

Int103:  push      cs
         pop       es
         mov       bp,offset fonty
         mov       ah,11h
         pushf
         call      dword ptr cs:[Old10]

; ------ p�edefinov�n� ukazatele INT 43h

         mov       word ptr ds:[10ch],offset fonty
         mov       ds:[10eh],cs

; ------ n�vrat velikosti a pozice kurzoru

         pop       word ptr ds:[44ch]       ; �schova velikosti bufferu
         pop       bx                       ; n�vrat videostr�nky
         pop       dx                       ; p�vodn� pozice kurzoru
         mov       ah,2
         pushf
         call      dword ptr cs:[Old10]     ; n�vrat pozice kurzoru
         pop       cx                       ; p�vodn� velikost kurzoru
         mov       ah,1
         pushf
         call      dword ptr cs:[Old10]     ; n�vrat velikosti kurzoru

; ------ n�vrat registr�

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

db 038h,044h,04ch,054h,064h,044h,038h,000h,060h,092h,00ch,000h,000h,000h  ; 0
db 000h,000h,07ch,082h,0Aah,082h,082h,0Bah,092h,082h,082h,07ch,000h,000h  ; 1
db 000h,000h,07ch,0Feh,0D6h,0Feh,0Feh,0C6h,0Eeh,0Feh,0Feh,07ch,000h,000h  ; 2
db 000h,000h,000h,000h,06Ch,0FEh,0FEh,0FEh,0FEh,07Ch,038h,010h,000h,000h  ; 3
db 000h,000h,000h,000h,010h,038h,07Ch,0FEh,07Ch,038h,010h,000h,000h,000h  ; 4
db 000h,000h,000h,038h,038h,010h,0c6h,0Eeh,0c6h,010h,010h,038h,000h,000h  ; 5
db 000h,000h,000h,010h,038h,07ch,0Feh,0Feh,07ch,010h,010h,038h,000h,000h  ; 6
db 000h,000h,000h,000h,000h,000h,018h,03Ch,03Ch,018h,000h,000h,000h,000h  ; 7
db 0FFh,0FFh,0FFh,0FFh,0FFh,0E7h,0C3h,0C3h,0E7h,0FFh,0FFh,0FFh,0FFh,0FFh  ; 8
db 000h,000h,000h,000h,03Ch,042h,042h,042h,042h,03Ch,000h,000h,000h,000h  ; 9
db 0FFh,0FFh,0FFh,0FFh,0C3h,0bdh,0BDh,0BDh,0bdh,0C3h,0FFh,0FFh,0FFh,0FFh  ; 10
db 000h,01Eh,00Eh,00Ah,012h,078h,084h,084h,084h,084h,084h,078h,000h,000h  ; 11
db 000h,000h,07Ch,082h,082h,082h,082h,07Ch,010h,010h,07Ch,010h,010h,000h  ; 12
db 000h,03Fh,021h,03Fh,020h,020h,020h,020h,0e0h,0e0h,0e0h,000h,000h,000h  ; 13
db 000h,07eh,042h,07eh,042h,042h,042h,042h,046h,0c6h,0c6h,0C0h,000h,000h  ; 14
db 000h,000h,010h,010h,0d6h,038h,0Eeh,038h,0d6h,010h,010h,000h,000h,000h  ; 15
db 000h,080h,0C0h,0E0h,0F0h,0F8h,0Feh,0F8h,0F0h,0E0h,0C0h,080h,000h,000h  ; 16
db 000h,002h,006h,00Eh,01Eh,03Eh,0fEh,03Eh,01Eh,00Eh,006h,002h,000h,000h  ; 17
db 000h,010h,038h,054h,092h,010h,010h,010h,010h,092h,054h,038h,010h,000h  ; 18
db 000h,044h,044h,044h,044h,044h,044h,044h,000h,000h,044h,044h,000h,000h  ; 19
db 000h,07Fh,092h,092h,092h,072h,012h,012h,012h,012h,012h,012h,000h,000h  ; 20
db 07ch,082h,080h,040h,038h,044h,082h,082h,044h,038h,004h,002h,082h,07ch  ; 21
db 000h,000h,000h,000h,000h,000h,000h,0FEh,0FEh,0FEh,0FEh,000h,000h,000h  ; 22
db 010h,038h,054h,092h,010h,010h,010h,092h,054h,038h,010h,0FEh,000h,000h  ; 23
db 010h,038h,054h,092h,010h,010h,010h,010h,010h,010h,010h,010h,000h,000h  ; 24
db 000h,010h,010h,010h,010h,010h,010h,010h,010h,092h,054h,038h,010h,000h  ; 25
db 000h,000h,000h,010h,008h,004h,0FEh,004h,008h,010h,000h,000h,000h,000h  ; 26
db 000h,000h,000h,010h,020h,040h,0FEh,040h,020h,010h,000h,000h,000h,000h  ; 27
db 000h,000h,000h,000h,080h,080h,080h,080h,0FEh,000h,000h,000h,000h,000h  ; 28
db 000h,000h,000h,000h,028h,044h,0FEh,044h,028h,000h,000h,000h,000h,000h  ; 29
db 000h,000h,000h,010h,038h,038h,07Ch,07Ch,0FEh,0FEh,000h,000h,000h,000h  ; 30
db 000h,000h,000h,0FEh,0FEh,07Ch,07Ch,038h,038h,010h,000h,000h,000h,000h  ; 31
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ; mezera
db 000h,010h,038h,038h,038h,010h,010h,010h,000h,000h,010h,010h,000h,000h  ; !
db 044h,044h,044h,044h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ; "
db 000h,000h,024h,024h,07Eh,024h,024h,024h,07Eh,024h,024h,000h,000h,000h  ; #
db 000h,010h,07Ch,092h,090h,090h,07Ch,012h,012h,012h,092h,07Ch,010h,000h  ; $
db 000h,000h,000h,040h,0a2h,044h,008h,010h,020h,044h,08ah,004h,000h,000h  ; %
db 000h,000h,038h,044h,044h,038h,032h,04ch,088h,088h,08Ch,076h,000h,000h  ; &
db 010h,010h,010h,020h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ; '
db 000h,00ch,010h,020h,040h,040h,040h,040h,040h,020h,010h,00ch,000h,000h  ; (
db 000h,060h,010h,008h,004h,004h,004h,004h,004h,008h,010h,060h,000h,000h  ; )
db 000h,000h,000h,000h,042h,024h,018h,0Ffh,018h,024h,042h,000h,000h,000h  ; *
db 000h,000h,000h,000h,010h,010h,010h,0feh,010h,010h,010h,000h,000h,000h  ; +
db 000h,000h,000h,000h,000h,000h,000h,000h,010h,010h,010h,010h,020h,000h  ; ,
db 000h,000h,000h,000h,000h,000h,000h,0fEh,000h,000h,000h,000h,000h,000h  ; -
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,010h,010h,000h,000h  ; .
db 002h,002h,004h,004h,008h,008h,010h,010h,020h,020h,040h,040h,080h,080h  ; /
db 000h,038h,044h,082h,082h,08ah,092h,0a2h,082h,082h,044h,038h,000h,000h  ; 0
db 000h,008h,018h,028h,048h,008h,008h,008h,008h,008h,008h,03Eh,000h,000h  ; 1
db 000h,07Ch,082h,002h,002h,004h,008h,010h,020h,042h,082h,0FEh,000h,000h  ; 2
db 000h,07ch,082h,002h,002h,002h,01ch,002h,002h,002h,082h,07ch,000h,000h  ; 3
db 000h,004h,00ch,014h,024h,044h,084h,084h,0FEh,004h,004h,01Eh,000h,000h  ; 4
db 000h,0FEh,080h,080h,080h,0FCh,002h,002h,002h,002h,082h,07Ch,000h,000h  ; 5
db 000h,03ch,040h,080h,080h,0FCh,082h,082h,082h,082h,082h,07Ch,000h,000h  ; 6
db 000h,0FEh,082h,002h,002h,004h,008h,010h,020h,020h,020h,020h,000h,000h  ; 7
db 000h,07Ch,082h,082h,082h,082h,07ch,082h,082h,082h,082h,07Ch,000h,000h  ; 8
db 000h,07Ch,082h,082h,082h,082h,07Eh,002h,002h,002h,004h,078h,000h,000h  ; 9
db 000h,000h,000h,010h,010h,000h,000h,000h,010h,010h,000h,000h,000h,000h  ; :
db 000h,000h,000h,010h,010h,000h,000h,000h,010h,010h,010h,020h,000h,000h  ; ;
db 000h,002h,004h,008h,010h,020h,040h,020h,010h,008h,004h,002h,000h,000h  ; <
db 000h,000h,000h,000h,000h,0fEh,000h,000h,0fEh,000h,000h,000h,000h,000h  ; =
db 000h,040h,020h,010h,008h,004h,002h,004h,008h,010h,020h,040h,000h,000h  ; >
db 000h,07Ch,082h,002h,004h,008h,010h,010h,000h,000h,010h,010h,000h,000h  ; ?
db 000h,07Ch,082h,082h,082h,09ah,092h,092h,09Ch,080h,07Ch,000h,000h,000h  ; @
db 000h,010h,028h,044h,082h,082h,082h,0feh,082h,082h,082h,082h,000h,000h  ; A
db 000h,0FCh,042h,042h,042h,042h,07Ch,042h,042h,042h,042h,0FCh,000h,000h  ; B
db 000h,038h,044h,082h,080h,080h,080h,080h,080h,082h,044h,038h,000h,000h  ; C
db 000h,0F8h,044h,042h,042h,042h,042h,042h,042h,042h,044h,0F8h,000h,000h  ; D
db 000h,0FEh,042h,042h,040h,048h,078h,048h,040h,042h,042h,0FEh,000h,000h  ; E
db 000h,0FEh,042h,042h,040h,048h,078h,048h,040h,040h,040h,0F0h,000h,000h  ; F
db 000h,038h,044h,082h,080h,080h,09Eh,082h,082h,082h,044h,038h,000h,000h  ; G
db 000h,082h,082h,082h,082h,082h,0FEh,082h,082h,082h,082h,082h,000h,000h  ; H
db 000h,038h,010h,010h,010h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; I
db 000h,01Eh,004h,004h,004h,004h,004h,004h,004h,084h,084h,078h,000h,000h  ; J
db 000h,082h,084h,088h,090h,0a0h,0c0h,0a0h,090h,088h,084h,082h,000h,000h  ; K
db 000h,0E0h,040h,040h,040h,040h,040h,040h,040h,042h,042h,0FEh,000h,000h  ; L
db 000h,082h,0c6h,0AAh,092h,082h,082h,082h,082h,082h,082h,082h,000h,000h  ; M
db 000h,0c2h,0c2h,0a2h,0a2h,092h,092h,08ah,08ah,086h,086h,082h,000h,000h  ; N
db 000h,07Ch,082h,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; O
db 000h,0FCh,042h,042h,042h,042h,07Ch,040h,040h,040h,040h,0F0h,000h,000h  ; P
db 000h,07Ch,082h,082h,082h,082h,082h,082h,082h,092h,08ah,07Ch,004h,002h  ; Q
db 000h,0FCh,042h,042h,042h,042h,07Ch,048h,044h,042h,042h,0e2h,000h,000h  ; R
db 000h,07Ch,082h,082h,080h,040h,038h,004h,002h,082h,082h,07Ch,000h,000h  ; S
db 000h,0FEh,092h,092h,010h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; T
db 000h,082h,082h,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; U
db 000h,082h,082h,082h,082h,082h,082h,082h,082h,044h,028h,010h,000h,000h  ; V
db 000h,082h,082h,082h,082h,082h,092h,092h,092h,092h,0aah,044h,000h,000h  ; W
db 000h,082h,082h,044h,044h,028h,038h,028h,044h,044h,082h,082h,000h,000h  ; X
db 000h,082h,082h,082h,044h,028h,010h,010h,010h,010h,010h,038h,000h,000h  ; Y
db 000h,0FEh,082h,082h,004h,008h,010h,020h,040h,082h,082h,0FEh,000h,000h  ; Z
db 000h,03Ch,020h,020h,020h,020h,020h,020h,020h,020h,020h,03Ch,000h,000h  ; [
db 000h,080h,040h,040h,020h,020h,010h,010h,008h,008h,004h,004h,002h,000h  ; \
db 000h,03Ch,004h,004h,004h,004h,004h,004h,004h,004h,004h,03Ch,000h,000h  ; ]
db 010h,028h,044h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ; ^
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h  ; _
db 010h,010h,010h,008h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ; `
db 000h,000h,000h,000h,078h,004h,004h,07Ch,084h,084h,084h,07ah,000h,000h  ; a
db 000h,0C0h,040h,040h,07ch,042h,042h,042h,042h,042h,042h,07ch,000h,000h  ; b
db 000h,000h,000h,000h,07Ch,082h,080h,080h,080h,080h,082h,07Ch,000h,000h  ; c
db 000h,01Ch,004h,004h,07Ch,084h,084h,084h,084h,084h,084h,07ah,000h,000h  ; d
db 000h,000h,000h,000h,07Ch,082h,082h,0FEh,080h,080h,082h,07Ch,000h,000h  ; e
db 000h,038h,044h,040h,040h,0E0h,040h,040h,040h,040h,040h,0E0h,000h,000h  ; f
db 000h,000h,000h,000h,07ah,084h,084h,084h,084h,084h,07Ch,004h,004h,078h  ; g
db 000h,0C0h,040h,040h,05Ch,062h,042h,042h,042h,042h,042h,0C2h,000h,000h  ; h
db 000h,010h,010h,000h,030h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; i
db 000h,002h,002h,000h,00Eh,002h,002h,002h,002h,002h,002h,042h,042h,03Ch  ; j
db 000h,0C0h,040h,040h,042h,044h,048h,070h,070h,048h,044h,0C2h,000h,000h  ; k
db 000h,030h,010h,010h,010h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; l
db 000h,000h,000h,000h,0ECh,092h,092h,092h,092h,092h,092h,092h,000h,000h  ; m
db 000h,000h,000h,000h,0DCh,062h,042h,042h,042h,042h,042h,042h,000h,000h  ; n
db 000h,000h,000h,000h,07Ch,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; o
db 000h,000h,000h,000h,0DCh,062h,042h,042h,042h,042h,07Ch,040h,040h,0E0h  ; p
db 000h,000h,000h,000h,076h,08ch,084h,084h,084h,084h,07Ch,004h,004h,00Eh  ; q
db 000h,000h,000h,000h,09Ch,062h,040h,040h,040h,040h,040h,0E0h,000h,000h  ; r
db 000h,000h,000h,000h,07Ch,082h,080h,070h,01Ch,002h,082h,07Ch,000h,000h  ; s
db 000h,020h,020h,020h,0FCh,020h,020h,020h,020h,020h,022h,01Ch,000h,000h  ; t
db 000h,000h,000h,000h,084h,084h,084h,084h,084h,084h,084h,07ah,000h,000h  ; u
db 000h,000h,000h,000h,082h,082h,082h,082h,082h,044h,028h,010h,000h,000h  ; v
db 000h,000h,000h,000h,082h,082h,082h,092h,092h,092h,092h,06Ch,000h,000h  ; w
db 000h,000h,000h,000h,082h,082h,044h,028h,010h,028h,044h,082h,000h,000h  ; x
db 000h,000h,000h,000h,082h,082h,082h,082h,082h,082h,07Eh,002h,004h,0F8h  ; y
db 000h,000h,000h,000h,0FEh,082h,004h,008h,010h,020h,042h,0FEh,000h,000h  ; z
db 000h,00Eh,010h,010h,010h,010h,060h,010h,010h,010h,010h,010h,00eh,000h  ; {
db 000h,010h,010h,010h,010h,010h,000h,010h,010h,010h,010h,010h,000h,000h  ; |
db 000h,070h,008h,008h,008h,008h,006h,008h,008h,008h,008h,070h,000h,000h  ; }
db 064h,098h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ; ~
db 000h,000h,000h,010h,028h,044h,082h,082h,082h,0FEh,000h,000h,000h,000h  ; 
db 044h,038h,038h,044h,082h,080h,080h,080h,080h,082h,044h,038h,000h,000h  ; �
db 000h,084h,084h,000h,084h,084h,084h,084h,084h,084h,084h,07ah,000h,000h  ; �
db 008h,010h,020h,000h,07Ch,082h,082h,0FEh,080h,080h,082h,07Ch,000h,000h  ; �
db 001h,01dh,005h,004h,07Ch,084h,084h,084h,084h,084h,084h,07ah,000h,000h  ; �
db 000h,044h,044h,000h,078h,004h,004h,07Ch,084h,084h,084h,07ah,000h,000h  ; �
db 044h,038h,0f8h,044h,042h,042h,042h,042h,042h,042h,044h,0F8h,000h,000h  ; �
db 044h,038h,0feh,092h,092h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; �
db 044h,028h,010h,000h,07Ch,082h,080h,080h,080h,080h,082h,07Ch,000h,000h  ; �
db 044h,028h,010h,000h,07Ch,082h,082h,0FEh,080h,080h,082h,07Ch,000h,000h  ; �
db 044h,038h,0feh,042h,040h,048h,078h,048h,040h,042h,042h,0FEh,000h,000h  ; �
db 002h,0E2h,044h,040h,040h,040h,040h,040h,040h,042h,042h,0FEh,000h,000h  ; �
db 008h,010h,038h,010h,010h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; �
db 00ah,034h,010h,010h,010h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; �
db 002h,032h,012h,010h,010h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; �
db 044h,010h,028h,044h,082h,082h,082h,0feh,082h,082h,082h,082h,000h,000h  ; �
db 002h,012h,028h,044h,082h,082h,082h,0feh,082h,082h,082h,082h,000h,000h  ; �
db 008h,010h,0feh,042h,040h,048h,078h,048h,040h,042h,042h,0FEh,000h,000h  ; �
db 044h,028h,010h,000h,0FEh,082h,004h,008h,010h,020h,042h,0FEh,000h,000h  ; �
db 044h,038h,0feh,082h,082h,004h,008h,010h,020h,042h,082h,0FEh,000h,000h  ; �
db 010h,028h,044h,000h,07Ch,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 000h,044h,044h,000h,07Ch,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 008h,010h,07ch,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 038h,044h,038h,000h,084h,084h,084h,084h,084h,084h,084h,07ah,000h,000h  ; �
db 008h,092h,082h,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 004h,008h,010h,000h,082h,082h,082h,082h,082h,082h,07Eh,002h,004h,0F8h  ; �
db 044h,000h,07ch,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 044h,000h,082h,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 044h,038h,07ch,082h,080h,040h,038h,004h,002h,082h,082h,07Ch,000h,000h  ; �
db 014h,0E8h,040h,040h,040h,040h,040h,040h,040h,042h,042h,0FEh,000h,000h  ; �
db 010h,092h,082h,082h,044h,028h,010h,010h,010h,010h,010h,038h,000h,000h  ; �
db 044h,038h,0fch,042h,042h,042h,042h,07ch,048h,044h,042h,0e2h,000h,000h  ; �
db 00ah,024h,020h,020h,0FCh,020h,020h,020h,020h,020h,022h,01Ch,000h,000h  ; �
db 004h,008h,010h,000h,078h,004h,004h,07Ch,084h,084h,084h,07ah,000h,000h  ; �
db 004h,008h,010h,000h,030h,010h,010h,010h,010h,010h,010h,038h,000h,000h  ; �
db 004h,008h,010h,000h,07Ch,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 004h,008h,010h,000h,084h,084h,084h,084h,084h,084h,084h,07ah,000h,000h  ; �
db 044h,028h,010h,000h,0DCh,062h,042h,042h,042h,042h,042h,042h,000h,000h  ; �
db 028h,0d2h,0c2h,0a2h,0a2h,092h,092h,08ah,08ah,086h,086h,082h,000h,000h  ; �
db 038h,044h,038h,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 0feh,000h,07ch,082h,082h,082h,082h,082h,082h,082h,082h,07Ch,000h,000h  ; �
db 044h,028h,010h,000h,07Ch,082h,080h,070h,01Ch,002h,082h,07Ch,000h,000h  ; �
db 044h,028h,010h,000h,09Ch,062h,040h,040h,040h,040h,040h,0E0h,000h,000h  ; �
db 004h,008h,010h,000h,09Ch,062h,040h,040h,040h,040h,040h,0E0h,000h,000h  ; �
db 008h,010h,0fch,042h,042h,042h,042h,07ch,048h,044h,042h,0e2h,000h,000h  ; �
db 040h,0C0h,040h,042h,044h,008h,012h,026h,04ah,092h,03Eh,002h,002h,000h  ; �
db 000h,010h,010h,000h,000h,010h,010h,010h,038h,038h,038h,010h,000h,000h  ; �
db 000h,000h,000h,000h,000h,022h,044h,088h,044h,022h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,088h,044h,022h,044h,088h,000h,000h,000h,000h  ; �
db 044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h  ; �
db 0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h  ; �
db 077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh  ; �
db 010h,010h,010h,010h,010h,010h,010h,010h,010h,010h,010h,010h,010h,010h  ; �
db 010h,010h,010h,010h,010h,010h,0F0h,010h,010h,010h,010h,010h,010h,010h  ; �
db 010h,010h,010h,010h,010h,0F0h,010h,010h,0F0h,010h,010h,010h,010h,010h  ; �
db 024h,024h,024h,024h,024h,024h,0E4h,024h,024h,024h,024h,024h,024h,024h  ; �
db 000h,000h,000h,000h,000h,000h,0F0h,048h,024h,024h,024h,024h,024h,024h  ; � ���ͻ
db 000h,000h,000h,000h,000h,080h,040h,020h,010h,090h,050h,030h,010h,010h  ; � � � �
db 024h,024h,024h,024h,024h,0E4h,004h,004h,0E4h,024h,024h,024h,024h,024h  ; � ���͹
db 024h,024h,024h,024h,024h,024h,024h,024h,024h,024h,024h,024h,024h,024h  ; � ���ͼ
db 000h,000h,000h,000h,000h,0c0h,020h,010h,088h,044h,024h,024h,024h,024h  ; � ���Ŀ
db 024h,024h,024h,024h,044h,088h,010h,020h,0c0h,000h,000h,000h,000h,000h  ; � � � �
db 024h,024h,024h,024h,024h,048h,0f0h,000h,000h,000h,000h,000h,000h,000h  ; � ���Ĵ
db 010h,010h,030h,050h,090h,010h,020h,040h,080h,000h,000h,000h,000h,000h  ; � �����
db 000h,000h,000h,000h,000h,000h,080h,040h,020h,010h,010h,010h,010h,010h  ; � ���͸
db 010h,010h,010h,010h,008h,004h,003h,000h,000h,000h,000h,000h,000h,000h  ; � � � �
db 010h,010h,010h,010h,010h,010h,0FFh,000h,000h,000h,000h,000h,000h,000h  ; � ���͵
db 000h,000h,000h,000h,000h,000h,0FFh,010h,010h,010h,010h,010h,010h,010h  ; � ���;
db 010h,010h,010h,010h,010h,010h,01Fh,010h,010h,010h,010h,010h,010h,010h  ; � ���ķ
db 000h,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h  ; � � � �
db 010h,010h,010h,010h,010h,010h,0FFh,010h,010h,010h,010h,010h,010h,010h  ; � ���Ķ
db 010h,010h,010h,010h,010h,01Fh,010h,010h,01Fh,010h,010h,010h,010h,010h  ; � ���Ľ
db 024h,024h,024h,024h,024h,024h,027h,024h,024h,024h,024h,024h,024h,024h  ; �
db 024h,024h,024h,024h,022h,011h,008h,004h,003h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,003h,004h,008h,011h,022h,024h,024h,024h,024h  ; �
db 024h,024h,024h,024h,024h,0E7h,000h,000h,0FFh,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,0FFh,000h,000h,0E7h,024h,024h,024h,024h,024h  ; �
db 024h,024h,024h,024h,024h,027h,020h,020h,027h,024h,024h,024h,024h,024h  ; �
db 000h,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,000h,000h,000h,000h  ; �
db 024h,024h,024h,024h,024h,0E7h,000h,000h,0E7h,024h,024h,024h,024h,024h  ; �
db 010h,010h,010h,010h,010h,0FFh,000h,000h,0FFh,000h,000h,000h,000h,000h  ; �
db 024h,024h,024h,024h,024h,024h,0FFh,000h,000h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,0FFh,000h,000h,0FFh,010h,010h,010h,010h,010h  ; �
db 000h,000h,000h,000h,000h,000h,0FFh,024h,024h,024h,024h,024h,024h,024h  ; �
db 024h,024h,024h,024h,024h,012h,00fh,000h,000h,000h,000h,000h,000h,000h  ; �
db 010h,010h,018h,014h,012h,011h,008h,004h,003h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,003h,004h,008h,011h,012h,014h,018h,010h,010h  ; �
db 000h,000h,000h,000h,000h,000h,00fh,012h,024h,024h,024h,024h,024h,024h  ; �
db 024h,024h,024h,024h,024h,024h,0FFh,024h,024h,024h,024h,024h,024h,024h  ; �
db 010h,010h,010h,010h,010h,0FFh,010h,010h,0FFh,010h,010h,010h,010h,010h  ; �
db 010h,010h,010h,010h,020h,040h,080h,000h,000h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,000h,003h,004h,008h,010h,010h,010h,010h,010h  ; �
db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh  ; �
db 000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh  ; �
db 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h  ; �
db 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh  ; �
db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,072h,08ch,088h,088h,088h,088h,08ch,072h,000h,000h  ; �
db 000h,078h,084h,084h,088h,090h,088h,084h,082h,082h,082h,08Ch,000h,000h  ; �
db 000h,0FEh,082h,082h,080h,080h,080h,080h,080h,080h,080h,080h,000h,000h  ; �
db 000h,000h,000h,0FEh,044h,044h,044h,044h,044h,044h,044h,044h,000h,000h  ; �
db 000h,0FEh,082h,040h,020h,010h,008h,010h,020h,040h,082h,0FEh,000h,000h  ; �
db 000h,000h,000h,002h,07Ch,090h,088h,088h,088h,088h,088h,070h,000h,000h  ; �
db 000h,000h,000h,042h,042h,042h,042h,042h,042h,07Ch,040h,040h,080h,000h  ; �
db 000h,000h,000h,062h,09Ch,008h,008h,008h,008h,008h,008h,006h,000h,000h  ; �
db 0feh,010h,010h,038h,044h,082h,082h,082h,044h,038h,010h,010h,0FEh,000h  ; �
db 000h,038h,044h,082h,082h,082h,0BAh,082h,082h,082h,044h,038h,000h,000h  ; �
db 000h,038h,044h,082h,082h,082h,082h,044h,028h,028h,0AAh,0EEh,000h,000h  ; �
db 000h,01Eh,020h,020h,010h,038h,044h,042h,042h,042h,042h,03Ch,000h,000h  ; �
db 000h,000h,000h,000h,06Ch,092h,092h,092h,092h,06ch,000h,000h,000h,000h  ; �
db 002h,002h,004h,004h,06ch,09ah,092h,092h,0b2h,06ch,040h,040h,080h,080h  ; �
db 000h,000h,03eh,040h,080h,080h,0fEh,080h,080h,040h,03Eh,000h,000h,000h  ; �
db 000h,000h,038h,044h,082h,082h,082h,082h,082h,082h,082h,082h,000h,000h  ; �
db 000h,000h,000h,000h,0FEh,000h,000h,0FEh,000h,000h,0FEh,000h,000h,000h  ; �
db 000h,000h,000h,010h,010h,07ch,010h,010h,000h,000h,07ch,000h,000h,000h  ; �
db 000h,040h,020h,010h,008h,004h,008h,010h,020h,040h,000h,0feh,000h,000h  ; �
db 000h,004h,008h,010h,020h,040h,020h,010h,008h,004h,000h,0feh,000h,000h  ; �
db 000h,00ch,012h,012h,010h,010h,010h,010h,010h,010h,010h,010h,010h,010h  ; �
db 010h,010h,010h,010h,010h,010h,010h,010h,090h,090h,060h,000h,000h,000h  ; �
db 000h,000h,000h,000h,010h,010h,000h,07ch,000h,010h,010h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,076h,0DCh,000h,076h,0DCh,000h,000h,000h,000h  ; �
db 038h,044h,044h,038h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,000h,018h,018h,000h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,000h,000h,000h,000h,010h,000h,000h,000h,000h,000h,000h  ; �
db 00Fh,008h,008h,008h,008h,008h,088h,048h,028h,018h,008h,000h,000h,000h  ; �
db 068h,034h,024h,024h,024h,024h,000h,000h,000h,000h,000h,000h,000h,000h  ; �
db 030h,048h,010h,020h,048h,078h,000h,000h,000h,000h,000h,000h,000h,000h  ; �
db 000h,000h,000h,07Ch,07Ch,07Ch,07Ch,07Ch,07Ch,07Ch,000h,000h,000h,000h  ; �
db 000h,000h,038h,044h,082h,09ah,0a2h,0a2h,09ah,082h,044h,038h,000h,000h  ; 255

; -----------------------------------------------------------------------------
;                    Instalace font� rezidentn�
; -----------------------------------------------------------------------------

Instal:
         mov       ax,3510h
         int       21h
         mov       word ptr ds:[Old10],bx
         mov       word ptr ds:[Old10+2],es
         mov       dx,offset Int10
         mov       ax,2510h
         int       21h

         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h

         mov       dx,offset uvtxt
         mov       ah,9
         int       21h

         mov       dx,offset Instal
         int       27h

uvtxt    db        'LCDFNT14 V1.10 - fonty LCD 14 linek; (c) Miroslav Nemecek',13,10,'$'

code     ends
         end       start

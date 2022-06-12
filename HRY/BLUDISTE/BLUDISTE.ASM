
code     segment
         assume    cs:code,ds:code
         org       100h

bludiste:

; ------ inicializace programu
                                          ;* inicializace gener toru n hody
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; syst‚mov˜ ‡asova‡
         pop       ds
         mov       word ptr ds:[randomr],ax ; inicializace gener toru n hody

; ------ inicializace videom¢du
                                          ;* zji¨tˆn¡ videom¢du
         mov       ah,0fh
         int       10h
         mov       ds:[VMod],al             ; p–vodn¡ videom¢d
         cmp       al,7
         je        blud1
         mov       word ptr ds:[VRAM],0b800h
         mov       byte ptr ds:[byteline],80
         mov       al,1                     ; po‘adovan˜ videom¢d 40x25 barevn˜
blud1:   mov       ah,0
         int       10h                      ; inicializace videom¢du

; ------ start nov‚ hry - vykreslen¡ bludi¨tˆ

gener:   mov       si,offset mapa1
         call      random0
         and       dx,1fh
         cmp       dx,22
         jae       gener
         mov       ax,offset(mapa2-mapa1)
         mul       dx
         add       si,ax

         mov       cx,23                    ; po‡et © dk–
         mov       dx,100h                  ; po‡ te‡n¡ pozice
gener2:  push      cx
         push      dx
         mov       cx,5                     ; po‡et bajt–
gener3:  push      cx
         mov       cx,8                     ; po‡et bit–
         mov       bl,ds:[si]
         inc       si
gener4:  shl       bl,1
         mov       ax,word ptr ds:[znakv0]  ; voln‚ pole nezobrazen‚
         jnc       gener5                   ; pole je voln‚
         mov       ax,word ptr ds:[znakp0]  ; obsazen‚ pole nezobrazen‚
gener5:  call      writech                  ; z pis znaku na displej
         loop      gener4
         pop       cx
         loop      gener3                   ; dal¨¡ bajt
         pop       dx
         pop       cx
         inc       dh                       ; zv˜¨en¡ ‡¡sla © dku
         loop      gener2                   ; dal¨¡ © dek

; ------ vykreslen¡ r mu bludi¨tˆ

ram:     xor       dx,dx                    ; po‡ te‡n¡ pozice r mu
         mov       ax,word ptr ds:[znakram] ; znak r mu
         call      linkaram                 ; zobrazen¡ horn¡ linky r mu
         inc       dh                       ; 2. © dek na displeji
         mov       cx,23                    ; po‡et vnit©n¡ch © dk–
ram1:    xor       dl,dl                    ; po‡ te‡n¡ pozice na © dku
         call      writech                  ; z pis lev‚ho okraje r mu
         add       dl,38                    ; zv˜¨en¡ pozice na prav˜ okraj
         call      writech                  ; z pis prav‚ho okraje r mu
         inc       dh                       ; zv˜¨en¡ ‡¡sla © dku
         loop      ram1                     ; zobrazen¡ dal¨¡ho © dku
         call      linkaram                 ; zobrazen¡ doln¡ linky r mu

; ------ inicializace p©i za‡ tku hry

         mov       dx,2*256
         mov       ds:[pozice],dx           ; v˜choz¡ pozice
         inc       dl
         mov       ax,word ptr ds:[znakv0]
         call      writech
         mov       dx,22*256+38             ; pozice v prav‚m doln¡m rohu
         call      writech
         mov       ax,word ptr ds:[znakcil] ; c¡lov˜ znak
         call      writech                  ; zobrazen¡ c¡lov‚ho znaku

; ------ ‡ek n¡ na stisk kl vesy
                                          ;* zobrazen¡ hr ‡e
vstup:   mov       ax,word ptr ds:[znakh0]  ; znak hr ‡e 1
         test      word ptr ds:[citackur],2000h ; jak  je barva kurzoru ?
         jz        vstup1                   ; je 1. barva
         mov       ax,word ptr ds:[znakh1]  ; znak hr ‡e 2
vstup1:  mov       dx,ds:[pozice]           ; pozice hr ‡e na displeji
         call      writech                  ; zobrazen¡ znaku hr ‡e
         call      kurzout                  ; vypnut¡ zobrazen¡ kurzoru
                                          ;* test stisku kl vesy
vstup2:  inc       word ptr ds:[citackur]   ; zv˜¨en¡ ‡¡ta‡e kurzoru
         test      word ptr ds:[citackur],1fffh ; je zmˆna barvy ?
         jz        vstup                    ; je zmˆna barvy
         int       28h                      ; obsluha rezidentn¡ch funkc¡ DOS
         mov       ah,1                     ; funkce testu stavu kl vesnice
         int       16h                      ; test p©ipravenosti znaku
         jz        vstup2                   ; nen¡ p©ipraven ‘ dn˜ znak
         xor       ax,ax                    ; slu‘ba ‡ten¡ k¢du znaku
         int       16h                      ; ‡ten¡ znaku z kl vesnice

; ------ obsluha posunu hr ‡e
                                         ;* obsluha p©eru¨en¡ hry
         cmp       al,3                     ; je ^C ?
         je        posun1                   ; je ^C - p©eru¨en¡ hry
         or        ax,ax                    ; je Ctrl-Break ?
         jz        posun1                   ; je Ctrl-Break - p©eru¨en¡ hry
         cmp       al,27                    ; je kl vesa ESC ?
         jne       posun2                   ; nen¡ kl vesa ESC
posun1:  mov       al,ds:[vmod]             ; p–vodn¡ videom¢d
         xor       ah,ah                    ; AH <- 0 funce nastaven¡ videom¢du
         int       10h                      ; n vrat videom¢du

         mov       dx,offset ZavTxt
         mov       ah,9
         int       21h

         int       20h                      ; ukon‡en¡ programu

                                          ;* posun o pozici vlevo
posun2:  mov       dx,ds:[pozice]           ; pozice hr ‡e na displeji
         or        dl,dl                    ; je v˜choz¡ pozice ?
         jz        posun3                   ; je vychoz¡ pozice
         cmp       ah,4bh                   ; je kurzor vlevo ?
         jne       posun3                   ; nen¡ kurzor vlevo
         dec       dl                       ; sn¡‘en¡ pozice na © dku
                                          ;* posun o pozici vpravo
posun3:  cmp       ah,4dh                   ; je kurzor vpravo ?
         jne       posun4                   ; nen¡ kurzor vpravo
         inc       dl                       ; sv˜¨en¡ pozice
                                          ;* posun o © dek nahoru
posun4:  cmp       ah,48h                   ; je kurzor nahoru ?
         jne       posun5                   ; nen¡ kurzor nahoru
         dec       dh                       ; zv˜¨en¡ ‡¡sla © dku
                                          ;* posun o © dek dol–
posun5:  cmp       ah,50h                   ; je kurzor dol– ?
         jne       posun6                   ; nen¡ kurzor dol–
         inc       dh                       ; zv˜¨en¡ ‡¡sla © dku
posun6:                                   ;* kontrola nov‚ pozice
         call      testch                   ; test znaku na nov‚ pozici
         jc        vstup                    ; nen¡ pr zdn‚ pol¡‡ko

; ------ nov  pozice je platn  - proveden¡ posunu

posun8:
         push      ax
         push      dx                       ; £schova nov‚ pozice
         mov       ax,word ptr ds:[znakv1]  ; voln‚ pole zobrazen‚
         mov       dx,ds:[pozice]           ; p–vodn¡ pozice hr ‡e
         call      writech                  ; vymaz n¡ p–vodn¡ pozice
         pop       dx                       ; n vrat nov‚ pozice
         pop       ax

         mov       ds:[pozice],dx           ; nastaven¡ nov‚ pozice hr ‡e

; ------ kontrola, zda je dosa‘eno c¡le

         cmp       ax,word ptr ds:[znakcil] ; je c¡lov˜ znak ?
         jne       okoli                    ; nen¡ c¡lov˜ znak

         mov       dx,101h
         mov       cx,23
ukvse1:  push      cx
         push      dx
         mov       cx,38
ukvse2:  call      ukaz
         inc       dl
         loop      ukvse2
         pop       dx
         pop       cx
         inc       dh
         loop      ukvse1

                                          ;* je c¡l
         mov       dx,10                    ; pozice pro zobrazen¡ textu
         mov       si,offset ciltxt         ; c¡lov˜ text
         mov       ah,ds:[barvacil]         ; barva c¡lov‚ho textu
         call      writetxt
         call      kurzout
         xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         jmp       gener                    ; nov  hra

; ------ zobrazen¡ okoln¡ch pol¡‡ek
okoli:
         dec       dl
         call      ukaz                     ; zviditelnˆn¡ pol¡‡ka vlevo
         add       dl,2
         call      ukaz                     ; zviditelnˆn¡ pol¡‡ka vpravo
         dec       dl
         dec       dh
         call      ukaz                     ; zviditelnˆn¡ pol¡‡ka naho©e
         add       dh,2
         call      ukaz                     ; zviditelnˆn¡ pol¡‡ka dole
         jmp       vstup                    ; vstup dal¨¡ho povelu

; -------

ukaz:                                     ;* zviditelnˆn¡ pol¡‡ka DX

         push      dx
         cmp       dl,39
         jae       ukaz4                    ; nepovolen  pozice
         call      readch                   ; ‡ten¡ znaku na pozici DX
         cmp       ax,word ptr cs:[znakv0]  ; je voln‚ pol¡‡ko nezobrazen‚ ?
         jne       ukaz2                    ; nen¡ voln‚ pol¡‡ko nezobrazen‚
         mov       ax,word ptr cs:[znakv1]  ; n hrada zobrazen˜m voln˜m znakem
         jmp       short ukaz3              ; zobrazen¡ znaku
ukaz2:   cmp       ax,word ptr cs:[znakp0]  ; je pln‚ pol¡‡ko nezobrazen‚ ?
         jne       ukaz4                    ; nen¡ pln‚ pol¡‡ko nezobrazen‚
         mov       ax,word ptr cs:[znakp1]  ; n hrada zobrazen˜m pln˜m znakem
ukaz3:   call      writech                  ; zobrazen¡ znaku
ukaz4:   pop       dx
         ret


linkaram:push      cx
         xor       dl,dl
         mov       cx,40
         call      writechr
         pop       cx
         ret


testch:                                   ;* test znaku na pozici DX
         call      readch
         cmp       word ptr ds:[znakv0],ax  ; je voln‚ pole nezobrazen‚ ?
         je        testch3                  ; je voln‚ pole nezobrazen‚
         cmp       word ptr ds:[znakv1],ax  ; je voln‚ pole zobrazen‚ ?
         je        testch3                  ; je voln‚ pole zobrazen‚
         cmp       word ptr ds:[znakcil],ax ; je voln‚ pole zobrazen‚ ?
         je        testch3                  ; je voln‚ pole zobrazen‚
         stc                                ; p©¡znak - nen¡ voln‚ pole
testch3: ret



readch:                                   ;* ‡ten¡ znaku z pozice DX
         push      dx
         push      si
         push      ds

         mov       al,ds:[byteline]
         mul       dh                       ; p©epo‡et © dk– na bajty
         mov       dh,0
         add       ax,dx
         add       ax,dx                    ; p©i‡ten¡ pozice
         mov       si,ax                    ; adresa ve videopamˆti

         mov       ds,ds:[VRAM]             ; segment videopamˆti
         cld
         lodsw

         pop       ds
         pop       si
         pop       dx
         ret


writetxt:                                 ;* z pis textu DS:SI od pozice DX
         push      si
         push      ax
writtxt2:lodsb
         or        al,al
         jz        writtxt3
         call      writech
         jmp       short writtxt2
writtxt3:pop       ax
         pop       si
         ret



writech:                                  ;* z pis znaku AX na pozici DX
         push      cx
         mov       cx,1
         call      writechr
         pop       cx
         inc       dl
         ret

writechr:                                 ;* opakovan˜ z pis znaku na pozici DX
         push      cx
         push      dx
         push      di
         push      es

         push      ax
         mov       al,ds:[byteline]
         mul       dh                       ; p©epo‡et © dk– na bajty
         mov       dh,0
         add       ax,dx
         add       ax,dx                    ; p©i‡ten¡ pozice
         mov       di,ax                    ; adresa ve videopamˆti
         pop       ax

         mov       es,ds:[VRAM]             ; segment videopamˆti
         cld
         rep       stosw

         pop       es
         pop       di
         pop       dx
         pop       cx
         ret


kurzout:
         push      dx
         mov       dx,25*256
         call      gotoxy
         pop       dx
         ret


gotoxy:                                   ;* nastaven¡ pozice kurzoru
         push      ax
         push      bx
         push      dx
         xor       bx,bx
         mov       ah,2
         call      int10
         pop       dx
         pop       bx
         pop       ax
         ret


int10:                                    ;* obsluha INT 10h
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
         ret


random0  proc      near

         push      ax
         push      bx
         push      cx

         mov       ax,word ptr cs:[randomr]
         mov       bx,word ptr cs:[randomr+2]
         mov       cx,ax
         mul       word ptr cs:[randomd]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr cs:[randomr],ax
         mov       word ptr cs:[randomr+2],dx

         pop       cx
         pop       bx
         pop       ax
         ret

random0  endp

randomd  dw        8405h

zavtxt   db        'BLUDISTE - (c) Miroslav Nemecek 1993',13,10
         db        '   GEMA Soft Roznov pod Radhostem',13,10
         db        '            - FREEWARE -',13,10
         db        '$'

ciltxt   db        ' B L A H O P R E J I ',0
barvacil db        8eh

VRAM     dw        0b000h                   ; segment videopamˆti
byteline db        160                      ; po‡et bajt– na © dek

vmod     db        0                        ; uschovan˜ videom¢d

znaky    label     word
znakram  db        176,19h                  ; r m bludi¨tˆ
znakv0   db        " ",7                    ; voln‚ pole nezobrazen‚
znakv1   db        176,2                    ; voln‚ pole zobrazen‚
znakp0   db        " ",0                    ; pln‚ pole nezobrazen‚
znakp1   db        178,12                   ; pln‚ pole zobrazen‚
znakh0   db        1,14                     ; znak hr ‡e 1
znakh1   db        2,14                     ; znak hr ‡e 2
znakcil  db        5,10                     ; c¡lov˜ znak

randomr  dd        12345678h

pozice   dw        0                        ; aktu ln¡ pozice
citackur dw        0                        ; ‡¡ta‡ kurzoru

mapa     label     byte                     ; mapa bludi¨tˆ
                                            ;  1=voln‚ pole nezobrazen‚
                                            ;  2=voln‚ pole zobrazen‚
                                            ;  3=pln‚ pole nezobrazen‚
                                            ;  4=pln‚ pole zobrazen‚


mapa1    label     byte
         db        00000001b,11111111b,11111111b,00010000b,00000000b ; 1
         db        00001000b,00000000b,00000001b,00001010b,00000000b ; 2
         db        00001000b,00001111b,01111001b,00001001b,00000000b ; 3
         db        00001000b,00000000b,00001001b,00001000b,10000000b ; 4
         db        00001011b,00110000b,00000100b,00000000b,01000000b ; 5
         db        00001000b,00100111b,11110111b,11111000b,00100000b ; 6
         db        00001000b,00100100b,00000000b,00001000b,00010000b ; 7
         db        00000000b,00100100b,01111111b,00001000b,00001000b ; 8
         db        01111100b,00100000b,00000000b,11101001b,11111000b ; 9
         db        00000000b,00100100b,00001110b,00000000b,00001010b ; 10
         db        00000000b,11100111b,11111111b,11111111b,11001010b ; 11
         db        00000000b,00000100b,00010000b,00000000b,00001010b ; 12
         db        00111110b,00000100b,00010001b,11111111b,10010010b ; 13
         db        00100010b,11111100b,00010010b,00000000b,00010100b ; 14
         db        00100011b,10000000b,00010011b,11111111b,11110100b ; 15
         db        00111000b,10100000b,00010000b,00000000b,00010100b ; 16
         db        00001001b,00100010b,00010000b,00111111b,00100000b ; 17
         db        00001001b,00100010b,00010000b,00000001b,01001110b ; 18
         db        00001001b,11100010b,00011111b,11110001b,01010010b ; 19
         db        00001001b,00000010b,00011000b,00010001b,10010000b ; 20
         db        00000001b,00000010b,00011011b,00010000b,01000100b ; 21
         db        00000000b,00111110b,00000011b,11110001b,01111100b ; 22
         db        00000000b,00000000b,00011111b,00000001b,00000100b ; 23

mapa2    label     byte
         db        00100000b,10001001b,00000000b,01010101b,00000100b ; 1
         db        00100000b,10001001b,00000100b,01010101b,00000100b ; 2
         db        00101010b,10001001b,00000100b,01010101b,00000100b ; 3
         db        00101010b,10101001b,00010100b,01010001b,01110100b ; 4
         db        00101010b,10101001b,00010100b,00010101b,01010100b ; 5
         db        00101010b,10101001b,00010100b,01010101b,01010100b ; 6
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 7
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 8
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 9
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 10
         db        00101010b,10101001b,10010100b,00010101b,01010100b ; 11
         db        00101010b,10101001b,10010000b,01010101b,01010100b ; 12
         db        00101010b,10101001b,10010010b,01010101b,01010100b ; 13
         db        00101010b,10101001b,10010010b,01000101b,01010100b ; 14
         db        00101010b,10101001b,00010010b,01010101b,01010100b ; 15
         db        00101010b,10101001b,01010010b,01010101b,01010000b ; 16
         db        00101011b,10101001b,01010010b,00010101b,01010100b ; 17
         db        00101010b,00101001b,01000010b,00010101b,01010100b ; 18
         db        00101010b,00101001b,01100010b,01010100b,01010100b ; 19
         db        00101010b,00101001b,00100010b,01011101b,01010110b ; 20
         db        00101000b,00101001b,00100010b,01110101b,01010100b ; 21
         db        00001000b,00100001b,00100000b,01000111b,11011100b ; 22
         db        00001000b,00100000b,00100000b,00000000b,00000000b ; 23

mapa3    label     byte
         db        00001000b,00000000b,00011100b,01110100b,00000000b ; 1
         db        00001000b,11111111b,11110000b,00000100b,00000000b ; 2
         db        01000000b,00000000b,00000000b,01111111b,01111110b ; 3
         db        01011111b,11111111b,11111000b,01000000b,00000010b ; 4
         db        01000000b,00000000b,00001000b,01001110b,00000010b ; 5
         db        01000000b,00000000b,00001000b,01000010b,00000010b ; 6
         db        01000111b,11111111b,00001000b,01000010b,00000010b ; 7
         db        01000100b,00000001b,00001000b,01000010b,00000010b ; 8
         db        01000100b,11111001b,00001000b,01000010b,00000010b ; 9
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 10
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 11
         db        01000100b,10101001b,00001000b,01111110b,00000010b ; 12
         db        01000100b,10101001b,00001000b,00000000b,00111110b ; 13
         db        01000100b,10101001b,00001000b,00000000b,00100000b ; 14
         db        01000100b,10101001b,00001111b,11110000b,00100000b ; 15
         db        01000100b,10101001b,00000000b,00010000b,00100111b ; 16
         db        01000100b,10101001b,00000111b,00010000b,00100100b ; 17
         db        01000100b,10101001b,00000100b,00010000b,00100100b ; 18
         db        01000100b,10100001b,00000100b,00010000b,00100100b ; 19
         db        01000100b,10111111b,01111100b,00011111b,00100100b ; 20
         db        01100100b,10000000b,00000000b,00000000b,00000100b ; 21
         db        00001100b,11111111b,11111111b,11111111b,11111100b ; 22
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 23

mapa4    label     byte
         db        00001000b,00000000b,00011100b,01110100b,00000000b ; 1
         db        00001000b,11111111b,11110000b,00000100b,00000000b ; 2
         db        01000000b,00000000b,00000000b,01111111b,01111110b ; 3
         db        01011111b,11111111b,11111000b,01000000b,00000010b ; 4
         db        01000000b,00000000b,00001000b,01001110b,00000010b ; 5
         db        01000000b,00000000b,00001000b,01000010b,00000010b ; 6
         db        01000111b,11111111b,00001000b,01000010b,00000010b ; 7
         db        01000100b,00000001b,00001000b,01000010b,00000010b ; 8
         db        01000100b,11111001b,00001000b,01000010b,00000010b ; 9
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 10
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 11
         db        01000100b,10101001b,00001000b,01111110b,00000010b ; 12
         db        01000100b,10101001b,00001000b,00000000b,00111110b ; 13
         db        01000100b,10101001b,00001000b,00000000b,00100000b ; 14
         db        01000100b,10101001b,00001111b,11110000b,00100000b ; 15
         db        01000100b,10101001b,00000000b,00010000b,00100101b ; 16
         db        01000100b,10101001b,00000111b,00010000b,00100100b ; 17
         db        01000100b,10101001b,00000100b,00010000b,00100100b ; 18
         db        01000100b,10100001b,00000100b,00010000b,00100100b ; 19
         db        01000100b,10111111b,01111100b,00011111b,00100100b ; 20
         db        01100100b,10000000b,00000000b,00000000b,00000100b ; 21
         db        00001100b,11111111b,11111111b,11111111b,11111111b ; 22
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 23


mapa5    label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000001b,00000000b,00000000b,00000000b,00000000b ; 2
         db        00001001b,00000000b,00000000b,00000000b,00000000b ; 3
         db        00001001b,00001000b,00000000b,00000000b,00000000b ; 4
         db        00001001b,00001000b,00000000b,00000000b,01000000b ; 5
         db        00001001b,00001000b,00000000b,01000000b,01001000b ; 6
         db        00001001b,00001000b,00000000b,01000000b,01001000b ; 7
         db        00001001b,00001000b,00100000b,01000000b,01001000b ; 8
         db        00001001b,00001000b,00100000b,01000000b,01001000b ; 9
         db        11111111b,11111111b,11101111b,11111111b,11111111b ; 10
         db        00000000b,00000000b,00000000b,00000001b,00000000b ; 11
         db        00000000b,00000000b,00000111b,11111111b,00100000b ; 12
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 13
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 14
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 15
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 16
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 17
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 18
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 19
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 20
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 21
         db        00000000b,00000000b,00000000b,00000000b,00100000b ; 22
         db        00000000b,00000000b,00000000b,00000000b,00100000b ; 23

mapa6    label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 2
         db        00000111b,11111111b,11111111b,00000000b,00000000b ; 3
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 4
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 5
         db        00000100b,00111111b,11111111b,11111111b,11111111b ; 6
         db        00000100b,00100000b,00000000b,00000000b,00000000b ; 7
         db        00000100b,00100000b,00000000b,00000000b,00000000b ; 8
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 9
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 10
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 11
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 12
         db        00000100b,00100000b,00000100b,11111111b,11111111b ; 13
         db        00000100b,00100000b,00000100b,10000000b,00000000b ; 14
         db        00000100b,00100000b,00000100b,10011111b,11111110b ; 15
         db        00000100b,00100000b,00000100b,10010000b,00000000b ; 16
         db        00000100b,00100000b,00000100b,10010111b,11111100b ; 17
         db        00000100b,00100000b,00000100b,10010100b,00000000b ; 18
         db        00000100b,00100000b,00000100b,10010100b,11111110b ; 19
         db        00000100b,00000000b,00000100b,00010100b,10000000b ; 20
         db        00000100b,00000000b,00000100b,01010100b,10011100b ; 21
         db        00000100b,00000000b,00000100b,01010100b,10010000b ; 22
         db        00000100b,00000000b,00000000b,01000100b,00010000b ; 23

mapa7    label     byte
         db        00000000b,01100000b,10000100b,00000000b,00000000b ; 1
         db        00000000b,00110000b,10000100b,00000001b,00000000b ; 2
         db        00000000b,00010000b,10000100b,00000011b,00000111b ; 3
         db        01100000b,00000000b,00000000b,00000010b,00001100b ; 4
         db        00111000b,00000111b,11101111b,11110000b,00011000b ; 5
         db        00001110b,00011100b,00000000b,00011100b,00010000b ; 6
         db        00000000b,01110000b,00000000b,00000111b,00110000b ; 7
         db        00000000b,11000000b,00000000b,00000000b,01000000b ; 8
         db        00000001b,00000111b,10000000b,11110000b,10000000b ; 9
         db        00000001b,00000100b,10000000b,10010000b,10000000b ; 10
         db        11111001b,00000111b,10000000b,11110000b,10000000b ; 11
         db        00000001b,00000000b,00000000b,00000000b,10111111b ; 12
         db        00000001b,00000000b,00000000b,00000000b,10000000b ; 13
         db        00000001b,00000000b,00000000b,00000001b,00000000b ; 14
         db        00000001b,00000000b,00000000b,00000001b,00000000b ; 15
         db        00000000b,11000000b,11111111b,00000011b,00000000b ; 16
         db        00000010b,01111000b,00000000b,00000110b,11110000b ; 17
         db        00000110b,00011100b,00000000b,00111100b,00011000b ; 18
         db        00001100b,00000111b,11110111b,11100000b,00001100b ; 19
         db        00011000b,00000000b,00000000b,00000010b,00000000b ; 20
         db        00110000b,00011000b,00001000b,00000001b,00000000b ; 21
         db        00000000b,00110000b,00001000b,00000000b,10000000b ; 22
         db        00000000b,01100000b,00001000b,00000000b,10000000b ; 23

mapa8    label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 2
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 3
         db        00000000b,00011111b,11111100b,00000000b,00000000b ; 4
         db        01111111b,10010000b,00000100b,00011111b,11111110b ; 5
         db        01000000b,10010000b,00000111b,10010000b,00000010b ; 6
         db        01000000b,11010000b,00000100b,10010000b,00000010b ; 7
         db        01000000b,01011111b,11111100b,10010000b,00000010b ; 8
         db        01000000b,01000000b,00000100b,10010000b,00000010b ; 9
         db        01111111b,11000000b,00111111b,11111111b,11111110b ; 10
         db        00000000b,00000000b,00100000b,00001000b,00000000b ; 11
         db        01111111b,00011111b,11100000b,00001000b,11111110b ; 12
         db        01000001b,00010000b,00100000b,00001000b,10000010b ; 13
         db        01000001b,00010000b,00111111b,11111000b,11111110b ; 14
         db        01000001b,00010000b,00100000b,00000000b,00000000b ; 15
         db        01111111b,00011111b,11100000b,00000111b,11111100b ; 16
         db        00000000b,00000000b,00000000b,00000100b,00000111b ; 17
         db        00000000b,11111111b,11100000b,00000100b,00000100b ; 18
         db        00000000b,10000000b,00111111b,11000111b,11111100b ; 19
         db        00000000b,10000000b,00101000b,01000000b,00000000b ; 20
         db        00000000b,10000000b,00101000b,01111110b,00111100b ; 21
         db        00000000b,11111111b,11101111b,11100010b,00100100b ; 22
         db        00000000b,00000000b,00000000b,00111110b,00111100b ; 23

mapa9    label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000000b,00000000b,00111111b,11001101b,10000000b ; 2
         db        00000000b,00000000b,01100000b,01101000b,10000000b ; 3
         db        00000000b,00000000b,11000000b,00111000b,10000000b ; 4
         db        00000000b,00000000b,10000000b,00011000b,10000000b ; 5
         db        00000000b,00000011b,00000000b,00001100b,10000000b ; 6
         db        00000000b,00000110b,00000000b,00000100b,10000000b ; 7
         db        00000000b,00001100b,00000000b,00000001b,10000000b ; 8
         db        00000000b,00011000b,00000000b,00000001b,10000000b ; 9
         db        00000000b,00110000b,00000000b,00000000b,10000000b ; 10
         db        00000000b,01100000b,00000000b,00000000b,11000000b ; 11
         db        00000000b,01000000b,00000000b,00000000b,01100000b ; 12
         db        00000000b,11001111b,11111000b,00000000b,00100000b ; 13
         db        00000001b,00001000b,00001000b,00000000b,00100000b ; 14
         db        00000011b,00001000b,00001000b,11101111b,00100000b ; 15
         db        00000110b,00001000b,00001000b,10000001b,00100000b ; 16
         db        00000100b,00001111b,11111000b,10000001b,00100000b ; 17
         db        00000100b,00000000b,00000000b,10000001b,00100000b ; 18
         db        00000100b,00000000b,00000000b,10000001b,00100000b ; 19
         db        00000100b,00000000b,00000000b,10000001b,00111111b ; 20
         db        00000100b,00000000b,00000000b,10000001b,00100000b ; 21
         db        00000100b,00000000b,00000000b,10000001b,11100000b ; 22
         db        00000100b,00000000b,00000000b,10000000b,00000000b ; 23


mapa10   label     byte
         db        00001000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00001000b,00011100b,00000000b,00100001b,11111110b ; 2
         db        00001000b,00000011b,11100000b,00100000b,00000010b ; 3
         db        00001000b,00000000b,00111111b,00100000b,00000010b ; 4
         db        00001000b,00000000b,00000001b,00100000b,00000010b ; 5
         db        00001000b,00000000b,00000001b,00100000b,11111110b ; 6
         db        00001000b,00000000b,00000001b,00101000b,00000000b ; 7
         db        00001000b,00000000b,00000001b,00101111b,00000000b ; 8
         db        00001000b,00000000b,00001111b,00101000b,00000000b ; 9
         db        00001000b,00000000b,00001000b,00101001b,11111110b ; 10
         db        00001000b,00000000b,00001000b,00101000b,00000010b ; 11
         db        00001000b,00000000b,00001111b,00101000b,00000010b ; 12
         db        00001000b,00000000b,00000001b,00101111b,00000010b ; 13
         db        00001000b,00000000b,00000111b,00101000b,00000010b ; 14
         db        00001000b,00000000b,00000100b,00101011b,11111110b ; 15
         db        00001000b,00000000b,00000100b,00101000b,00100000b ; 16
         db        00001000b,00000000b,00000111b,00101000b,00100100b ; 17
         db        00000000b,00000000b,00000001b,00101000b,00000100b ; 18
         db        11111111b,11111111b,00000001b,11101111b,11111111b ; 19
         db        00000000b,00000000b,00000000b,00001000b,00000000b ; 20
         db        00111111b,11111111b,11111111b,11111000b,00111100b ; 21
         db        00000000b,00000000b,00000000b,00000000b,00100000b ; 22
         db        00000000b,00000000b,00000000b,00000000b,00100000b ; 23

mapa11   label     byte
         db        00111111b,11111111b,11111111b,11111111b,11111111b ; 1
         db        00001000b,10001000b,10001000b,10001000b,10001010b ; 2
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 3
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 4
         db        00100010b,00100010b,00100010b,00100010b,00100010b ; 5
         db        00111111b,11111111b,11111111b,11111111b,11111111b ; 6
         db        00001000b,10001000b,10001000b,10001000b,10001010b ; 7
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 8
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 9
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 10
         db        00100010b,00100010b,00100010b,00100010b,00100010b ; 11
         db        00111111b,11111111b,11111111b,11111111b,11111111b ; 12
         db        00001000b,10001000b,10001000b,10001000b,10001000b ; 13
         db        00101010b,10101010b,10101010b,10101010b,10101000b ; 14
         db        00101010b,10101010b,10101010b,10101010b,10101000b ; 15
         db        00100010b,00100010b,00100010b,00100010b,00100000b ; 16
         db        00111111b,11111111b,11111111b,11111111b,11111100b ; 17
         db        00001000b,10001000b,10001000b,10001000b,10001100b ; 18
         db        00101010b,10101010b,10101010b,10101010b,10101100b ; 19
         db        00100010b,00100010b,00100010b,00100010b,00100100b ; 20
         db        00111111b,11111111b,11111111b,11111111b,11111100b ; 21
         db        00100010b,00100010b,00100010b,00100010b,00100100b ; 22
         db        00001000b,10001000b,10001000b,10001000b,10001100b ; 23

mapa12   label     byte
         db        00000001b,11111111b,11111111b,00010000b,00000000b ; 1
         db        00001000b,00000000b,00000001b,00001010b,00000000b ; 2
         db        00001000b,00001111b,01111001b,00001001b,00000000b ; 3
         db        00001000b,00000000b,00001001b,00001000b,10000000b ; 4
         db        00001011b,00110000b,00000100b,00000000b,01000000b ; 5
         db        00001000b,00100111b,11110111b,11111000b,00100000b ; 6
         db        00001000b,00100100b,00000000b,00001000b,00010000b ; 7
         db        00000000b,00100100b,01111111b,00001000b,00001000b ; 8
         db        01111100b,00100000b,00000000b,11101001b,11111000b ; 9
         db        00000000b,00100100b,00001110b,00000000b,00001010b ; 10
         db        00000000b,11100111b,11111111b,11111111b,11001010b ; 11
         db        00000000b,00000100b,00010000b,00000000b,00001010b ; 12
         db        00111110b,00000100b,00010001b,11111111b,10010010b ; 13
         db        00100010b,11111100b,00010010b,00000000b,00010100b ; 14
         db        00100011b,10000000b,00010011b,11111111b,11110100b ; 15
         db        00111000b,10100000b,00010000b,00000000b,00010100b ; 16
         db        00001001b,00100010b,00010000b,00111111b,00100000b ; 17
         db        00001001b,00100010b,00010000b,00000001b,01001110b ; 18
         db        00001001b,11100010b,00011111b,11110001b,01010010b ; 19
         db        00001001b,00000010b,00011000b,00010001b,10010000b ; 20
         db        00000001b,00000010b,00011011b,00010000b,01000100b ; 21
         db        00000000b,00111110b,00000011b,11110001b,01111100b ; 22
         db        00000000b,00000000b,00011111b,00000001b,00000100b ; 23

mapa13   label     byte
         db        00100000b,10001001b,00000000b,01010101b,00000100b ; 1
         db        00100000b,10001001b,00000100b,01010101b,00000100b ; 2
         db        00101010b,10001001b,00000100b,01010101b,00000100b ; 3
         db        00101010b,10101001b,00010100b,01010001b,01110100b ; 4
         db        00101010b,10101001b,00010100b,00010101b,01010100b ; 5
         db        00101010b,10101001b,00010100b,01010101b,01010100b ; 6
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 7
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 8
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 9
         db        00101010b,10101001b,10010100b,01010101b,01010100b ; 10
         db        00101010b,10101001b,10010100b,00010101b,01010100b ; 11
         db        00101010b,10101001b,10010000b,01010101b,01010100b ; 12
         db        00101010b,10101001b,10010010b,01010101b,01010100b ; 13
         db        00101010b,10101001b,10010010b,01000101b,01010100b ; 14
         db        00101010b,10101001b,00010010b,01010101b,01010100b ; 15
         db        00101010b,10101001b,01010010b,01010101b,01010000b ; 16
         db        00101011b,10101001b,01010010b,00010101b,01010100b ; 17
         db        00101010b,00101001b,01000010b,00010101b,01010100b ; 18
         db        00101010b,00101001b,01100010b,01010100b,01010100b ; 19
         db        00101010b,00101001b,00100010b,01011101b,01010110b ; 20
         db        00101000b,00101001b,00100010b,01110101b,01010100b ; 21
         db        00001000b,00100001b,00100000b,01000111b,11011100b ; 22
         db        00001000b,00100000b,00100000b,00000000b,00000000b ; 23

mapa14   label     byte
         db        00001000b,00000000b,00011100b,01110100b,00000000b ; 1
         db        00001000b,11111111b,11110000b,00000100b,00000000b ; 2
         db        01000000b,00000000b,00000000b,01111111b,01111110b ; 3
         db        01011111b,11111111b,11111000b,01000000b,00000010b ; 4
         db        01000000b,00000000b,00001000b,01001110b,00000010b ; 5
         db        01000000b,00000000b,00001000b,01000010b,00000010b ; 6
         db        01000111b,11111111b,00001000b,01000010b,00000010b ; 7
         db        01000100b,00000001b,00001000b,01000010b,00000010b ; 8
         db        01000100b,11111001b,00001000b,01000010b,00000010b ; 9
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 10
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 11
         db        01000100b,10101001b,00001000b,01111110b,00000010b ; 12
         db        01000100b,10101001b,00001000b,00000000b,00111110b ; 13
         db        01000100b,10101001b,00001000b,00000000b,00100000b ; 14
         db        01000100b,10101001b,00001111b,11110000b,00100000b ; 15
         db        01000100b,10101001b,00000000b,00010000b,00100111b ; 16
         db        01000100b,10101001b,00000111b,00010000b,00100100b ; 17
         db        01000100b,10101001b,00000100b,00010000b,00100100b ; 18
         db        01000100b,10100001b,00000100b,00010000b,00100100b ; 19
         db        01000100b,10111111b,01111100b,00011111b,00100100b ; 20
         db        01100100b,10000000b,00000000b,00000000b,00000100b ; 21
         db        00001100b,11111111b,11111111b,11111111b,11111100b ; 22
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 23

mapa15   label     byte
         db        00001000b,00000000b,00011100b,01110100b,00000000b ; 1
         db        00001000b,11111111b,11110000b,00000100b,00000000b ; 2
         db        01000000b,00000000b,00000000b,01111111b,01111110b ; 3
         db        01011111b,11111111b,11111000b,01000000b,00000010b ; 4
         db        01000000b,00000000b,00001000b,01001110b,00000010b ; 5
         db        01000000b,00000000b,00001000b,01000010b,00000010b ; 6
         db        01000111b,11111111b,00001000b,01000010b,00000010b ; 7
         db        01000100b,00000001b,00001000b,01000010b,00000010b ; 8
         db        01000100b,11111001b,00001000b,01000010b,00000010b ; 9
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 10
         db        01000100b,10001001b,00001000b,01000010b,00000010b ; 11
         db        01000100b,10101001b,00001000b,01111110b,00000010b ; 12
         db        01000100b,10101001b,00001000b,00000000b,00111110b ; 13
         db        01000100b,10101001b,00001000b,00000000b,00100000b ; 14
         db        01000100b,10101001b,00001111b,11110000b,00100000b ; 15
         db        01000100b,10101001b,00000000b,00010000b,00100101b ; 16
         db        01000100b,10101001b,00000111b,00010000b,00100100b ; 17
         db        01000100b,10101001b,00000100b,00010000b,00100100b ; 18
         db        01000100b,10100001b,00000100b,00010000b,00100100b ; 19
         db        01000100b,10111111b,01111100b,00011111b,00100100b ; 20
         db        01100100b,10000000b,00000000b,00000000b,00000100b ; 21
         db        00001100b,11111111b,11111111b,11111111b,11111111b ; 22
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 23


mapa16   label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000001b,00000000b,00000000b,00000000b,00000000b ; 2
         db        00001001b,00000000b,00000000b,00000000b,00000000b ; 3
         db        00001001b,00001000b,00000000b,00000000b,00000000b ; 4
         db        00001001b,00001000b,00000000b,00000000b,01000000b ; 5
         db        00001001b,00001000b,00000000b,01000000b,01001000b ; 6
         db        00001001b,00001000b,00000000b,01000000b,01001000b ; 7
         db        00001001b,00001000b,00100000b,01000000b,01001000b ; 8
         db        00001001b,00001000b,00100000b,01000000b,01001000b ; 9
         db        11111111b,11111111b,11101111b,11111111b,11111111b ; 10
         db        00000000b,00000000b,00000000b,00000001b,00000000b ; 11
         db        00000000b,00000000b,00000111b,11111111b,00100000b ; 12
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 13
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 14
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 15
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 16
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 17
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 18
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 19
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 20
         db        00000000b,00000000b,00000000b,00000001b,00100000b ; 21
         db        00000000b,00000000b,00000000b,00000000b,00100000b ; 22
         db        00000000b,00000000b,00000000b,00000000b,00100000b ; 23

mapa17   label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 2
         db        00000111b,11111111b,11111111b,00000000b,00000000b ; 3
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 4
         db        00000100b,00000000b,00000000b,00000000b,00000000b ; 5
         db        00000100b,00111111b,11111111b,11111111b,11111111b ; 6
         db        00000100b,00100000b,00000000b,00000000b,00000000b ; 7
         db        00000100b,00100000b,00000000b,00000000b,00000000b ; 8
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 9
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 10
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 11
         db        00000100b,00100000b,00000100b,00000000b,00000000b ; 12
         db        00000100b,00100000b,00000100b,11111111b,11111111b ; 13
         db        00000100b,00100000b,00000100b,10000000b,00000000b ; 14
         db        00000100b,00100000b,00000100b,10011111b,11111110b ; 15
         db        00000100b,00100000b,00000100b,10010000b,00000000b ; 16
         db        00000100b,00100000b,00000100b,10010111b,11111100b ; 17
         db        00000100b,00100000b,00000100b,10010100b,00000000b ; 18
         db        00000100b,00100000b,00000100b,10010100b,11111110b ; 19
         db        00000100b,00000000b,00000100b,00010100b,10000000b ; 20
         db        00000100b,00000000b,00000100b,01010100b,10011100b ; 21
         db        00000100b,00000000b,00000100b,01010100b,10010000b ; 22
         db        00000100b,00000000b,00000000b,01000100b,00010000b ; 23

mapa18   label     byte
         db        00000000b,01100000b,10000100b,00000000b,00000000b ; 1
         db        00000000b,00110000b,10000100b,00000001b,00000000b ; 2
         db        00000000b,00010000b,10000100b,00000011b,00000111b ; 3
         db        01100000b,00000000b,00000000b,00000010b,00001100b ; 4
         db        00111000b,00000111b,11101111b,11110000b,00011000b ; 5
         db        00001110b,00011100b,00000000b,00011100b,00010000b ; 6
         db        00000000b,01110000b,00000000b,00000111b,00110000b ; 7
         db        00000000b,11000000b,00000000b,00000000b,01000000b ; 8
         db        00000001b,00000111b,10000000b,11110000b,10000000b ; 9
         db        00000001b,00000100b,10000000b,10010000b,10000000b ; 10
         db        11111001b,00000111b,10000000b,11110000b,10000000b ; 11
         db        00000001b,00000000b,00000000b,00000000b,10111111b ; 12
         db        00000001b,00000000b,00000000b,00000000b,10000000b ; 13
         db        00000001b,00000000b,00000000b,00000001b,00000000b ; 14
         db        00000001b,00000000b,00000000b,00000001b,00000000b ; 15
         db        00000000b,11000000b,11111111b,00000011b,00000000b ; 16
         db        00000010b,01111000b,00000000b,00000110b,11110000b ; 17
         db        00000110b,00011100b,00000000b,00111100b,00011000b ; 18
         db        00001100b,00000111b,11110111b,11100000b,00001100b ; 19
         db        00011000b,00000000b,00000000b,00000010b,00000000b ; 20
         db        00110000b,00011000b,00001000b,00000001b,00000000b ; 21
         db        00000000b,00110000b,00001000b,00000000b,10000000b ; 22
         db        00000000b,01100000b,00001000b,00000000b,10000000b ; 23

mapa19   label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 2
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 3
         db        00000000b,00011111b,11111100b,00000000b,00000000b ; 4
         db        01111111b,10010000b,00000100b,00011111b,11111110b ; 5
         db        01000000b,10010000b,00000111b,10010000b,00000010b ; 6
         db        01000000b,11010000b,00000100b,10010000b,00000010b ; 7
         db        01000000b,01011111b,11111100b,10010000b,00000010b ; 8
         db        01000000b,01000000b,00000100b,10010000b,00000010b ; 9
         db        01111111b,11000000b,00111111b,11111111b,11111110b ; 10
         db        00000000b,00000000b,00100000b,00001000b,00000000b ; 11
         db        01111111b,00011111b,11100000b,00001000b,11111110b ; 12
         db        01000001b,00010000b,00100000b,00001000b,10000010b ; 13
         db        01000001b,00010000b,00111111b,11111000b,11111110b ; 14
         db        01000001b,00010000b,00100000b,00000000b,00000000b ; 15
         db        01111111b,00011111b,11100000b,00000111b,11111100b ; 16
         db        00000000b,00000000b,00000000b,00000100b,00000111b ; 17
         db        00000000b,11111111b,11100000b,00000100b,00000100b ; 18
         db        00000000b,10000000b,00111111b,11000111b,11111100b ; 19
         db        00000000b,10000000b,00101000b,01000000b,00000000b ; 20
         db        00000000b,10000000b,00101000b,01111110b,00111100b ; 21
         db        00000000b,11111111b,11101111b,11100010b,00100100b ; 22
         db        00000000b,00000000b,00000000b,00111110b,00111100b ; 23

mapa20   label     byte
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00000000b,00000000b,00111111b,11001101b,10000000b ; 2
         db        00000000b,00000000b,01100000b,01101000b,10000000b ; 3
         db        00000000b,00000000b,11000000b,00111000b,10000000b ; 4
         db        00000000b,00000000b,10000000b,00011000b,10000000b ; 5
         db        00000000b,00000011b,00000000b,00001100b,10000000b ; 6
         db        00000000b,00000110b,00000000b,00000100b,10000000b ; 7
         db        00000000b,00001100b,00000000b,00000001b,10000000b ; 8
         db        00000000b,00011000b,00000000b,00000001b,10000000b ; 9
         db        00000000b,00110000b,00000000b,00000000b,10000000b ; 10
         db        00000000b,01100000b,00000000b,00000000b,11000000b ; 11
         db        00000000b,01000000b,00000000b,00000000b,01100000b ; 12
         db        00000000b,11001111b,11111000b,00000000b,00100000b ; 13
         db        00000001b,00001000b,00001000b,00000000b,00100000b ; 14
         db        00000011b,00001000b,00001000b,11111111b,00100000b ; 15
         db        00000110b,00001000b,00001000b,10000001b,00100000b ; 16
         db        00000100b,00001111b,11111000b,10000001b,00100000b ; 17
         db        00000100b,00000000b,00000000b,10000001b,00100000b ; 18
         db        00000100b,00000000b,00000000b,10000001b,00100000b ; 19
         db        00000100b,00000000b,00000000b,10000001b,00111101b ; 20
         db        00000100b,00000000b,00000000b,10000001b,00100000b ; 21
         db        00000111b,11111111b,11111111b,10000001b,11101110b ; 22
         db        00000000b,00000000b,00000000b,00000001b,00000000b ; 23


mapa21   label     byte
         db        00001000b,00000000b,00000000b,00000000b,00000000b ; 1
         db        00001000b,00011100b,00000000b,00100001b,11111110b ; 2
         db        00001000b,00000011b,11100000b,00100000b,00000010b ; 3
         db        00001000b,00000000b,00111111b,00100000b,00000010b ; 4
         db        00001000b,00000000b,00000001b,00100000b,00000010b ; 5
         db        00001000b,00000000b,00000001b,00100000b,11111110b ; 6
         db        00001000b,00000000b,00000001b,00101000b,00000000b ; 7
         db        00001000b,00000000b,00000001b,00101111b,00000000b ; 8
         db        00001000b,00000000b,00001111b,00101000b,00000000b ; 9
         db        00001000b,00000000b,00001000b,00101001b,11111110b ; 10
         db        00001000b,00000000b,00001000b,00101000b,00000010b ; 11
         db        00001000b,00000000b,00001111b,00101000b,00000010b ; 12
         db        00001000b,00000000b,00000001b,00101111b,00000010b ; 13
         db        00001000b,00000000b,00000111b,00101000b,00000010b ; 14
         db        00001000b,00000000b,00000100b,00101011b,11111110b ; 15
         db        00001000b,00000000b,00000100b,00101000b,00100000b ; 16
         db        00001000b,00000000b,00000111b,00101000b,00100100b ; 17
         db        00000000b,00000000b,00000001b,00101000b,00000100b ; 18
         db        11111111b,11111111b,00000001b,11101111b,11111111b ; 19
         db        00000000b,00000000b,00000000b,00000000b,00000000b ; 20
         db        00111111b,11111111b,11111111b,11111000b,00111100b ; 21
         db        00000000b,00000000b,00000000b,00001000b,00100000b ; 22
         db        00000000b,00000000b,00000000b,00001000b,00100000b ; 23

mapa22   label     byte
         db        00111111b,11111111b,11111111b,11111111b,11111111b ; 1
         db        00001000b,10001000b,10001000b,10001000b,10001010b ; 2
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 3
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 4
         db        00100010b,00100010b,00100010b,00100010b,00100010b ; 5
         db        00111111b,11111111b,11111111b,11111111b,11111111b ; 6
         db        00001000b,10001000b,10001000b,10001000b,10001010b ; 7
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 8
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 9
         db        00101010b,10101010b,10101010b,10101010b,10101010b ; 10
         db        00100000b,00000000b,00000000b,00000000b,00000000b ; 11
         db        00111111b,11111111b,11111111b,11111111b,11111101b ; 12
         db        00001000b,10001000b,10001000b,10001000b,10001000b ; 13
         db        00101010b,10101010b,10101010b,10101010b,10101000b ; 14
         db        00101010b,10101010b,10101010b,10101010b,10101000b ; 15
         db        00100010b,00100010b,00100010b,00100010b,00101000b ; 16
         db        00111111b,11111111b,11111111b,11111111b,11111100b ; 17
         db        00001000b,10001000b,10001000b,10001000b,10001100b ; 18
         db        00101010b,10101010b,10101010b,10101010b,10101100b ; 19
         db        00100010b,00100010b,00100010b,00100010b,00100100b ; 20
         db        00111111b,11111111b,11111111b,11111111b,11111100b ; 21
         db        00100010b,00100010b,00100010b,00100010b,00100100b ; 22
         db        00001000b,10001000b,10001000b,10001000b,10001100b ; 23


code     ends
         end       bludiste

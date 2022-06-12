
code     segment
         ASSUME    cs:code,ds:code

         org       100h

start:
         mov       ax,3
         int       10h
         mov       dx,2500h
         mov       ah,2
         int       10h
input0:  call      clear
         call      zobrall

input:   xor       ah,ah
         int       16h
         cmp       al,27
         je        konec
         cmp       ax,5100h
         jne       input1
         add       word ptr ds:[pocrad],22
         jmp       short input0
input1:  cmp       ax,4900h
         jne       input2
         sub       word ptr ds:[pocrad],22
input11: jnc       input0
         mov       word ptr ds:[pocrad],0
         jmp       short input0
input2:  cmp       ax,5000h
         jne       input3
         inc       word ptr ds:[pocrad]
         mov       al,1
         call      moveup
         jmp       short input
input3:  cmp       ax,4800h
         jne       input4
         sub       word ptr ds:[pocrad],1
         jc        input31
         mov       al,1
         call      movedn
         jmp       short input
input31: mov       word ptr ds:[pocrad],0
         jmp       short input

input4:

         jmp       short input

konec:   mov       ah,4ch
         int       21h




movedn:                                   ;* pohyb okna dolñ
                                            ; VSTUP: AL=poáet ©†dkñ
         call      rolldn
         push      cx
         push      dx
         mov       cl,al                    ; poáet ©†dkñ
         xor       ch,ch
         jcxz      movedn2
         xor       dh,dh
movedn1: call      zobrad                   ; zobrazen° ©†dku
         inc       dh
         loop      movedn1
movedn2: pop       dx
         pop       cx
         ret


rolldn:                                   ;* rolov†n° obrazovky dolñ
                                            ; VSTUP: AL=poáet ©†dek k rolov†n°
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       ah,7
         mov       bh,70h                   ; atribut barvy
         xor       cx,cx
         mov       dx,24*256+79
         int       10h
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret




moveup:                                   ;* pohyb okna nahoru
                                            ; VSTUP: AL=poáet ©†dkñ
         call      rollup
         push      cx
         push      dx
         mov       cl,al                    ; poáet ©†dkñ
         xor       ch,ch
         jcxz      moveup2
         mov       dh,24
moveup1: call      zobrad                   ; zobrazen° ©†dku
         dec       dh
         loop      moveup1
moveup2: pop       dx
         pop       cx
         ret


rollup:                                   ;* rolov†n° obrazovky nahoru
                                            ; VSTUP: AL=poáet ©†dek k rolov†n°
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       ah,6
         mov       bh,70h                   ; atribut barvy
         xor       cx,cx
         mov       dx,24*256+79
         int       10h
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret



public   clear

clear:                                    ;* vymaz†n° obrazovky
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

         xor       dx,dx
         mov       cx,25*256
         mov       al," "
         mov       bl,70h
         call      outchr

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


public   zobrall

zobrall:                                  ;* zobrazen° v®ech znakñ
         mov       dx,1                     ; poá†teán° pozice
         mov       cx,25
zobrall1:call      zobrad
         inc       dh
         loop      zobrall1
         ret


public   zobrad

zobrad:                                   ;* zobrazen° ©†dku displeje
                                            ; VSTUP: DH=©†dek k zobrazen°
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
                                          ;* vòpoáet poá†teán°ho znaku
         xor       dl,dl
         push      dx
         mov       ax,ds:[pocrad]           ; poá†teán° zobrazenò ©†dek
         xchg      dl,dh
         add       ax,dx                    ; absolutn° á°slo ©†dku
         mov       cl,ds:[pocety]           ; poáet linek znaku
         add       cl,3
         shr       cl,1                     ; poáet ©†dkñ na znak
         div       cl                       ; á°slo ©†dku znaku
         push      ax
         mov       cl,ds:[znakux]           ; poáet znakñ na ©†dek
         mul       cl                       ; vòpoáet á°sla znaku v tabulce
         add       al,ds:[minch]            ; minim†ln° znak
         pop       bx
         pop       dx
         or        ah,ah
         jnz       zobrad3
         inc       dl                       ; pozice 1
                                          ;* zobrazen° jednoho znaku
zobrad0: or        bh,bh
         jnz       zobrad1
         push      bx
         push      dx                       ; poá†teán° pozice zobrazen° znaku
         mov       bl,74h
         call      outchar                  ; zobrazen° orientaán°ho znaku
         mov       bl,70h
         inc       dl
         call      outcis                   ; zobrazen° á°sla
         pop       dx
         jmp       short zobrad2
zobrad1: push      bx
         dec       bh
         add       bh,bh
         call      zobrlin                  ; zobrazen° linky
zobrad2: pop       bx
         add       dl,ds:[pocetx]
         inc       dl
         inc       al
         loopnz    zobrad0
zobrad3: pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


public   zobrlin

zobrlin:                                  ;* zobrazen° 2 linek znaku
                                            ; VSTUP: AL=znak
                                            ;        BH=á°slo linky
                                            ;        DX=poá†teán° pozice linky
                                            ; VùSTUP: BH=á°slo dal®° linky
                                            ;         DX=pozice dal®° linky

         cmp       dh,24                    ; je p©ekroáeno á°slo ©†dku ?
         ja        zobrli5
         push      ax
         push      bx
         push      cx
         push      dx
         xor       bl,bl                    ; á°slo prvn°ho bodu na lince
         mov       cl,ds:[pocetx]           ; poáet bodñ na lince
zobrli1: push      ax                       ; znak k zobrazen°
         call      getbod                   ; poskytnut° nastaven° bodu
         inc       bh
         or        al,al
         pop       ax
         push      ax
         jnz       zobrli2                  ; je vyplnànò bod
                                          ;* horn° bod nen° nastavenò
         call      getbod
         or        al,al
         mov       al,220
         jnz       zobrli4                  ; je nastavenò spodn° bod
         mov       al,32                    ; nen° nastaven ë†dnò bod
         jmp       short zobrli4
zobrli2:                                  ;* horn° bod je nastavenò
         call      getbod
         or        al,al
         mov       al,219
         jnz       zobrli4                  ; jsou nastavenÇ oba body
         mov       al,223                   ; je nastaven jen horn° bod
zobrli4: dec       bh
         push      bx
         mov       bl,0ch                   ; barva znaku
;         mov       bl,14
         call      outchar                  ; zobrazen° znaku
         pop       bx
         pop       ax
         inc       bl                       ; zvò®en° á°sla bodu
         loop      zobrli1
         pop       dx
         pop       cx
         pop       bx
         pop       ax
zobrli5: ret



public   getbod

getbod:                                   ;* poskytnut° nastaven° bodu
                                            ; VSTUP: AL=znak
                                            ;        BH=©†dek
                                            ;        BL=pozice
                                            ; VùSTUP: AL=nastaven° bodu 0,1
                                            ;         CY=neplatnÇ zad†n°

         push      cx
         push      si
         call      getadr                   ; poskytnut° adresy bodu
         mov       al,0                     ; n†hrada, pokud je chyba
         jc        getbod1                  ; chyba zad†n°
         lodsb                              ; naáten° bajtu znaku
         shr       al,cl                    ; rotace bitu
         and       al,1                     ; stav nastaven° bitu znaku
getbod1: pop       si
         pop       cx
         ret

public   getadr

getadr:                                   ;* poskytnut° adresy bodu
                                            ; VSTUP: AL=znak
                                            ;        BH=©†dek
                                            ;        BL=pozice
                                            ; VùSTUP: DS:SI=adresa bajtu
                                            ;         CL=pozice bitu
                                            ;         CY=neplatnÇ zad†n°
         push      ax
         push      bx
         push      di
                                          ;* kontrola zad†n° znaku
         cmp       al,ds:[maxch]            ; kontrola maxim†ln°ho znaku
         je        getadr1
         cmc
         jc        getadr3                  ; je velkò znak - chyba
getadr1:                                  ;* kontrola zad†n° ©†dku a pozice
         sub       al,ds:[minch]            ; kontrola minim†ln°ho znaku
         jc        getadr3                  ; je malò znak - chyba
         cmp       bl,ds:[pocetx]           ; kontrola á°sla pozice
         cmc
         jc        getadr3                  ; velk† pozice
         cmp       bh,ds:[pocety]           ; kontrola á°sla ©†dku
         cmc
         jc        getadr3                  ; velkÇ á°slo linky
                                          ;* zji®tàn° adresy znaku
         mov       ah,ds:[delkach]          ; poáet bajtñ na znak
         mul       ah                       ; vòpoáet offsetu v tabulce
         add       ax,ds:[adrfont]          ; vòpoáet adresy znaku v tabulce
                                          ;* naáten° parametrñ z mapy fontu
         push      ax                       ; adresa znaku v tabulce
         mov       al,bh                    ; poëadovan† linka
         xor       bh,bh                    ; BH <- 0
         mov       ah,ds:[pocetx]           ; poáet bodñ na linku
         mul       ah                       ; offset zaá†tku ©†dku (v bodech)
         add       ax,bx                    ; á°slo bodu v tabulce
         add       ax,ax                    ; offset v tabulce
         add       ax,ds:[adrmap]           ; adresa v mapà fontu
         mov       si,ax                    ; adresa v mapà fontu
         lodsb                              ; naáten° offsetu bajtu znaku
         mov       bl,al                    ; offset bajtu v tabulce
         lodsb                              ; pozice bitu
         mov       cl,al                    ; pozice bitu v bajtu
         pop       ax                       ; adresa znaku v tabulce
         add       ax,bx                    ; pozice bajtu v tabulce
         mov       si,ax                    ; adresa bajtu v tabulce
         clc
getadr3: pop       di
         pop       bx
         pop       ax
         ret

public   outcis

outcis:                                   ;* vòstup á°sla AL na displej
                                            ; VSTUP: DX=pozice
                                            ;        AL=á°slo
                                            ;        BL=atribut

         push      ax
         push      cx
         mov       ch,10
         xor       ah,ah
         div       ch
         mov       cl,ah                    ; jednotky á°sla
         xor       ah,ah
         div       ch
         mov       ch,ah                    ; des°tky á°sla
         call      outnum                   ; zobrazen° á°slice stovek
         mov       al,ch
         call      outnum                   ; zobrazen° des°tek
         mov       al,cl                    ; jednotky
         call      outnum                   ; zobrazen° jednotek
         pop       cx
         pop       ax
         ret

outnum:                                   ;* zobrazen° á°slice AL
                                            ; VSTUP: DX=pozice
                                            ;        AL=á°slice
                                            ;        BL=atribut
         push      ax
         add       al,"0"
         call      outchar
         pop       ax
         ret


outtxt:  lodsb
         or        al,al
         jz        outtx0
         call      outchar
         jmp       short outtxt
outtx0:  ret







public   outchar

outchar:                                  ;* vòstup znaku na displej
                                            ; VSTUP: DX=pozice
                                            ;        AL=znak
                                            ;        BL=atribut
         push      cx
         mov       cx,1
         call      outchr
         pop       cx
         ret

outchr:
         push      ax
         push      cx
         push      dx
         push      es
         cmp       dl,79                    ; je p©ekroáena pozice ?
         ja        outch011                 ; pozice p©ekroáena
         cmp       dh,24                    ; je p©ekroáen ©†dek ?
         ja        outch011                 ; ©†dek p©ekroáen
         mov       di,0b800h
         mov       es,di
         xor       di,di                    ; adresa zaá†tku VRAM
         push      ax
         mov       al,80
         mul       dh
         xor       dh,dh
         add       ax,dx
         add       ax,ax
         add       di,ax
         pop       ax
         mov       ah,bl
         cmp       al,127
         je        outch013
         cmp       al," "
         jae       outch012
outch013:mov       al," "
outch012:rep       stosw
outch011:pop       es
         pop       dx
         pop       cx
         pop       ax
         inc       dl                       ; zvò®en° pozice
         ret



;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;                                          ;* nastaven° pozice
;         push      bx
;         push      ax
;         mov       ah,2
;         xor       bh,bh
;         int       10h
;         pop       ax
;         pop       bx
;                                          ;* zobrazen° znaku
;         mov       ah,9
;         xor       bh,bh
;         mov       cx,1
;         int       10h
;
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         inc       dl                       ; zvò®en° pozice
;         ret

public   minch,maxch,delkach,pocetx,pocety,adrmap,adrfont


adrmap   dw        offset mapa              ; adresa definián° mapy
adrfont  dw        offset tabznk            ; adresa fontu

pocrad   dw        0                        ; á°slo poá†teán°ho zobraz. ©†dku
znakux   db        13                       ; poáet znakñ v horizont. smàru
znakuy   db        5                        ; poáet znakñ ve vertik†ln°m smàru


minch    db        0                        ; prvn° znak v tabulce
maxch    db        255                      ; maxim†ln° znak v tabulce
delkach  db        5                        ; poáet bajtñ na znak
pocetx   db        5                        ; poáet bodñ na lince (®°©ka znaku)
pocety   db        7                        ; poáet linek (vò®ka znaku)


public   mapa

mapa     label     byte                     ; mapa pro nastaven° bodñ
                                          ;* struktura: offset bajtu, bit.pozice
         db        0,4,0,3,0,2,0,1,0,0      ; ©†dek 0
         db        1,7,1,6,1,5,1,4,1,3      ; ©†dek 1
         db        1,2,1,1,1,0,2,7,2,6      ; ©†dek 2
         db        2,4,2,3,2,2,2,1,2,0      ; ©†dek 3
         db        3,7,3,6,3,5,3,4,3,3      ; ©†dek 4
         db        3,2,3,1,3,0,4,7,4,6      ; ©†dek 5
         db        4,4,4,3,4,2,4,1,4,0      ; ©†dek 6

public   tabznk

tabznk:                                     ; tabulka gener†toru znakñ
                                            ;   kaëdò znak 5 bajtñ, organizace:
;
; struktura znaku:    7   6   5   4   3   2   1   0
;                   ⁄ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒø
; 0                 ≥   ≥   ≥   ≥0/0≥0/1≥0/2≥0/3≥0/4≥
;                   ¿ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒŸ
;                   ⁄ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒø
; 1                 ≥1/0≥1/1≥1/2≥1/3≥1/4≥2/0≥2/1≥2/2≥
;                   ¿ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒŸ
;                   ⁄ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒø
; 2                 ≥2/3≥2/4≥   ≥3/0≥3/1≥3/2≥3/3≥3/4≥
;                   ¿ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒŸ
;                   ⁄ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒø
; 3                 ≥4/0≥4/1≥4/2≥4/3≥4/4≥5/0≥5/1≥5/2≥
;                   ¿ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒŸ
;                   ⁄ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒ¬ƒƒƒø
; 4                 ≥5/3≥5/4≥   ≥6/0≥6/1≥6/2≥6/3≥6/4≥
;                   ¿ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒ¡ƒƒƒŸ

         db        16*5 dup(0)

                                          ;* zde zaá°n† tabulka fontñ v BDT
         db        15h,55h,4ah,0aah,95h     ; 16
         db        0ah,0aah,95h,55h,4ah     ; 17
         db        2,23h,2,74h,8dh          ; 18 ("†")
         db        0ah,23h,91h,84h,4eh      ; 19 ("á")
         db        7,18h,8eh,94h,8dh        ; 20 ("É")
         db        2,23h,91h,0fch,0eh       ; 21 ("Ç")
         db        0ah,23h,91h,0fch,0eh     ; 22 ("à")
         db        6,3,4,21h,0eh            ; 23 ("°")
         db        0ah,25h,99h,8ch,51h      ; 24 ("§")
         db        2,23h,91h,8ch,4eh        ; 25 ("¢")
         db        0ah,25h,99h,84h,10h      ; 26 ("©")
         db        0ah,23h,0d0h,70h,5eh     ; 27 ("®")
         db        1fh,0ffh,0dfh,0ffh,0dfh  ; 28
         db        4,21h,4,0abh,84h         ; 29
         db        0,20h,9fh,11h,0          ; 30
         db        0,22h,1fh,41h,0          ; 31
         db        0,0,0,0,0                ; 32 " "
         db        4,21h,4,20h,4            ; 33 "!"
         db        0ah,52h,80h,0,0          ; 34 """
         db        0ah,57h,0cah,0fah,8ah    ; 35 "#"
         db        4,7dh,0eh,2fh,84h        ; 36 "$"
         db        18h,0c8h,84h,44h,0c3h    ; 37 "%"
         db        4,52h,8ch,0ach,8dh       ; 38 "&"
         db        4,22h,0,0,0              ; 39 "'"
         db        2,22h,8,41h,2            ; 40 "("
         db        8,20h,82h,11h,8          ; 41 ")"
         db        0,25h,4eh,0a9h,0         ; 42 "*"
         db        0,21h,1fh,21h,0          ; 43 "+"
         db        0,0,0ch,62h,10h          ; 44 ","
         db        0,0,1fh,0,0              ; 45 "-"
         db        0,0,0,3,0ch              ; 46 "."
         db        0,8,84h,44h,0            ; 47 "/"
         db        0eh,8ch,0d5h,0cch,4eh    ; 48 "0"
         db        4,61h,4,21h,0eh          ; 49 "1"
         db        0eh,88h,46h,44h,1fh      ; 50 "2"
         db        0eh,88h,46h,0ch,4eh      ; 51 "3"
         db        2,32h,92h,0f8h,82h       ; 52 "4"
         db        1fh,87h,81h,0ch,4eh      ; 53 "5"
         db        7,44h,1eh,8ch,4eh        ; 54 "6"
         db        1fh,8,84h,42h,8          ; 55 "7"
         db        0eh,8ch,4eh,8ch,4eh      ; 56 "8"
         db        0eh,8ch,4fh,8,9ch        ; 57 "9"
         db        0,63h,0,63h,0            ; 58 "0"
         db        0,1,0,21h,8              ; 59 ";"
         db        2,22h,10h,41h,2          ; 60 "<"
         db        0,7,0c0h,0f8h,0          ; 61 "="
         db        8,20h,81h,11h,8          ; 62 ">"
         db        0eh,88h,42h,20h,4        ; 63 "?"
         db        0eh,8ch,0d5h,0bch,0eh    ; 64 "@"
         db        4,54h,51h,0fch,51h       ; 65 "A"
         db        1eh,8ch,5eh,8ch,5eh      ; 66 "B"
         db        0eh,8ch,10h,84h,4eh      ; 67 "C"
         db        1eh,4ah,49h,4ah,5eh      ; 68 "D"
         db        1fh,84h,1eh,84h,1fh      ; 69 "E"
         db        1fh,84h,1eh,84h,10h      ; 70 "F"
         db        0eh,84h,17h,8ch,4eh      ; 71 "G"
         db        11h,8ch,5fh,8ch,51h      ; 72 "H"
         db        0eh,21h,4,21h,0eh        ; 73 "I"
         db        1,8,41h,0ch,4eh          ; 74 "J"
         db        11h,95h,18h,0a4h,91h     ; 75 "K"
         db        10h,84h,10h,84h,1fh      ; 76 "L"
         db        11h,0ddh,55h,8ch,51h     ; 77 "M"
         db        11h,8eh,55h,9ch,51h      ; 78 "N"
         db        0eh,8ch,51h,8ch,4eh      ; 79 "O"
         db        1eh,8ch,5eh,84h,10h      ; 80 "P"
         db        0eh,8ch,51h,0ach,8dh     ; 81 "Q"
         db        1eh,8ch,5eh,0a4h,91h     ; 82 "R"
         db        0eh,8ch,0eh,0ch,4eh      ; 83 "S"
         db        1fh,21h,4,21h,4          ; 84 "T"
         db        11h,8ch,51h,8ch,4eh      ; 85 "U"
         db        11h,8ch,4ah,51h,4        ; 86 "V"
         db        11h,8ch,55h,0adh,4ah     ; 87 "W"
         db        11h,8ah,84h,54h,51h      ; 88 "X"
         db        11h,8ah,84h,21h,4        ; 89 "Y"
         db        1fh,8,84h,44h,1fh        ; 90 "Z"
         db        1ch,84h,10h,84h,1ch      ; 91 "["
         db        0,82h,4,10h,40h          ; 92 "\"
         db        7,8,41h,8,47h            ; 93 "]"
         db        4,75h,44h,21h,4          ; 94 "^"
         db        0,0,0,0,1fh              ; 95 "_"
         db        0dh,57h,8,42h,46h        ; 96 "`" ("ü")
         db        0,3,2,74h,8dh            ; 97 "a"
         db        18h,42h,0eh,4ah,56h      ; 98 "b"
         db        0,3,91h,84h,4eh          ; 99 "c"
         db        6,10h,8eh,94h,8dh        ; 100 "d"
         db        0,3,91h,0fch,0eh         ; 101 "e"
         db        4,52h,1ch,42h,1ch        ; 102 "f"
         db        0,6ch,92h,70h,9ch        ; 103 "g"
         db        18h,42h,8dh,4ah,59h      ; 104 "h"
         db        4,3,4,21h,0eh            ; 105 "i"
         db        2,0,82h,94h,8ch          ; 106 "j"
         db        18h,42h,4ah,62h,99h      ; 107 "k"
         db        0ch,21h,4,21h,0eh        ; 108 "l"
         db        0,6,95h,0adh,55h         ; 109 "m"
         db        0,5,99h,8ch,51h          ; 110 "n"
         db        0,3,91h,8ch,4eh          ; 111 "o"
         db        0,7,91h,8fh,90h          ; 112 "p"
         db        0,3,0d1h,8bh,0c1h        ; 113 "q"
         db        0,5,99h,84h,10h          ; 114 "r"
         db        0,3,0d0h,70h,5eh         ; 115 "s"
         db        8,47h,8,42h,46h          ; 116 "t"
         db        0,4,51h,8ch,4eh          ; 117 "u"
         db        0,4,51h,8ah,84h          ; 118 "v"
         db        0,4,51h,0adh,4ah         ; 119 "w"
         db        0,4,4ah,22h,91h          ; 120 "x"
         db        0,4,51h,78h,5eh          ; 121 "y"
         db        0,7,0c2h,22h,1fh         ; 122 "z"
         db        2,24h,51h,8ch,4fh        ; 123 "{" ("£")
         db        4,55h,51h,8ch,4fh        ; 124 "|" ("ñ")
         db        2,24h,51h,78h,5eh        ; 125 "}" ("ò")
         db        0ah,27h,0c2h,22h,1fh     ; 126 "~" ("ë")
         db        0eh,3,91h,8ch,4eh        ; 127 "" ("ì")

         db        128*5 dup(0)


code     ends

         end       start

; ------------------------- pñvodn° tabulka -----------------------------------
  15h,55h,4ah,0aah,95h     ; 16
  0ah,0aah,95h,55h,4ah     ; 17
  1fh,0,0,0,0              ; 18
  0,0f8h,0,0,0             ; 19
  0,7,0c0h,0,0             ; 20
  0,0,0,0f8h,0             ; 21
  0,0,0,7,0c0h             ; 22
  10h,84h,10h,84h,10h      ; 23
  8,42h,8,42h,8            ; 24
  4,21h,4,21h,4            ; 25
  2,10h,82h,10h,82h        ; 26
  1,8,41h,8,41h            ; 27
  1fh,0ffh,0dfh,0ffh,0dfh  ; 28
  4,21h,4,0abh,84h         ; 29
  0,20h,9fh,11h,0          ; 30
  0,22h,1fh,41h,0          ; 31
  0,0,0,0,0                ; 32 " "
  4,21h,4,20h,4            ; 33 "!"
  0ah,52h,80h,0,0          ; 34 """
  0ah,57h,0cah,0fah,8ah    ; 35 "#"
  0,8bh,8ah,74h,40h        ; 36 "$"
  18h,0c8h,84h,44h,0c3h    ; 37 "%"
  4,52h,8ch,0ach,8dh       ; 38 "&"
  4,22h,0,0,0              ; 39 "'"
  2,22h,8,41h,2            ; 40 "("
  8,20h,82h,11h,8          ; 41 ")"
  0,25h,4eh,0a9h,0         ; 42 "*"
  0,21h,1fh,21h,0          ; 43 "+"
  0,0,0ch,62h,10h          ; 44 ","
  0,0,1fh,0,0              ; 45 "-"
  0,0,0,3,0ch              ; 46 "."
  0,8,84h,44h,0            ; 47 "/"
  0eh,8ch,0d5h,0cch,4eh    ; 48 "0"
  4,61h,4,21h,0eh          ; 49 "1"
  0eh,88h,46h,44h,1fh      ; 50 "2"
  1fh,8,86h,0ch,4eh        ; 51 "3"
  2,32h,92h,0f8h,82h       ; 52 "4"
  1fh,87h,81h,0ch,4eh      ; 53 "5"
  7,44h,1eh,8ch,4eh        ; 54 "6"
  1fh,8,84h,42h,8          ; 55 "7"
  0eh,8ch,4eh,8ch,4eh      ; 56 "8"
  0eh,8ch,4fh,8,9ch        ; 57 "9"
  0,63h,0,63h,0            ; 58 "0"
  0,1,0,21h,8              ; 59 ";"
  2,22h,10h,41h,2          ; 60 "<"
  0,7,0c0h,0f8h,0          ; 61 "="
  8,20h,81h,11h,8          ; 62 ">"
  0eh,88h,42h,20h,4        ; 63 "?"
  0eh,8ch,0d5h,0bch,0eh    ; 64 "@"
  4,54h,51h,0fch,51h       ; 65 "A"
  1eh,8ch,5eh,8ch,5eh      ; 66 "B"
  0eh,8ch,10h,84h,4eh      ; 67 "C"
  1eh,4ah,49h,4ah,5eh      ; 68 "D"
  1fh,84h,1eh,84h,1fh      ; 69 "E"
  1fh,84h,1eh,84h,10h      ; 70 "F"
  0eh,84h,17h,8ch,4eh      ; 71 "G"
  11h,8ch,5fh,8ch,51h      ; 72 "H"
  0eh,21h,4,21h,0eh        ; 73 "I"
  1,8,41h,0ch,4eh          ; 74 "J"
  11h,95h,18h,0a4h,91h     ; 75 "K"
  10h,84h,10h,84h,1fh      ; 76 "L"
  11h,0ddh,55h,8ch,51h     ; 77 "M"
  11h,8eh,55h,9ch,51h      ; 78 "N"
  0eh,8ch,51h,8ch,4eh      ; 79 "O"
  1eh,8ch,5eh,84h,10h      ; 80 "P"
  0eh,8ch,51h,0ach,8dh     ; 81 "Q"
  1eh,8ch,5eh,0a4h,91h     ; 82 "R"
  0eh,8ch,0eh,0ch,4eh      ; 83 "S"
  1fh,21h,4,21h,4          ; 84 "T"
  11h,8ch,51h,8ch,4eh      ; 85 "U"
  11h,8ch,4ah,51h,4        ; 86 "V"
  11h,8ch,55h,0adh,4ah     ; 87 "W"
  11h,8ah,84h,54h,51h      ; 88 "X"
  11h,8ah,84h,21h,4        ; 89 "Y"
  1fh,8,84h,44h,1fh        ; 90 "Z"
  1ch,84h,10h,84h,1ch      ; 91 "["
  0,82h,4,10h,40h          ; 92 "\"
  7,8,41h,8,47h            ; 93 "]"
  4,75h,44h,21h,4          ; 94 "^"
  0,0,0,0,1fh              ; 95 "_"
  12h,0adh,5dh,0adh,52h    ; 96 "`"
  4,54h,51h,0fch,51h       ; 97 "a"
  1fh,84h,1eh,8ch,5eh      ; 98 "b"
  12h,94h,92h,97h,0c1h     ; 99 "c"
  0eh,52h,8ah,57h,0d1h     ; 100 "d"
  1fh,84h,1eh,84h,1fh      ; 101 "e"
  4,0fdh,55h,0afh,0c4h     ; 102 "f"
  1fh,8ch,10h,84h,10h      ; 103 "g"
  11h,8ah,84h,54h,51h      ; 104 "h"
  11h,8ch,0d5h,0cch,51h    ; 105 "i"
  0eh,4,53h,0aeh,51h       ; 106 "j"
  11h,95h,18h,0a4h,91h     ; 107 "k"
  7,4ah,49h,4ah,51h        ; 108 "l"
  11h,0ddh,55h,8ch,51h     ; 109 "m"
  11h,8ch,5fh,8ch,51h      ; 110 "n"
  0eh,8ch,51h,8ch,4eh      ; 111 "o"
  1fh,8ch,51h,8ch,51h      ; 112 "p"
  0fh,8ch,4fh,2ah,51h      ; 113 "q"
  1eh,8ch,5eh,84h,10h      ; 114 "r"
  0eh,8ch,10h,84h,4eh      ; 115 "s"
  1fh,21h,4,21h,4          ; 116 "t"
  11h,8ch,4ah,22h,10h      ; 117 "u"
  11h,0adh,4eh,0adh,51h    ; 118 "v"
  1eh,8ch,5eh,8ch,5eh      ; 119 "w"
  10h,87h,91h,8ch,5eh      ; 120 "x"
  11h,8ch,59h,0adh,59h     ; 121 "y"
  0eh,88h,46h,0ch,4eh      ; 122 "z"
  11h,0adh,55h,0adh,5fh    ; 123 "{"
  1ch,10h,4fh,8,9ch        ; 124 "|"
  15h,0adh,55h,0afh,0c1h   ; 125 "}"
  11h,8ch,5fh,8,41h        ; 126 "~"
  1ch,0a1h,6,29h,46h       ; 127 ""

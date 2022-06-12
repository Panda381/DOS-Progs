
code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h
start:                                      ; hlavn¡ tˆlo programu
         mov       ah,12h
         mov       bl,10h
         int       10h                      ; informace o EGA
         cmp       bl,6
         jae       error                    ; nen¡ nainstalov na karta EGA
                                          ;* dek¢dov n¡ jedn‚ palety
         mov       si,81h                   ; za‡ tek p©¡kaz. © dku
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et zadan˜ch znak–
         cmp       cl,1
         jbe       error2                   ; je mal˜ po‡et znak–
         xor       bl,bl                    ; ‡¡ta‡ paletov˜ch registr–
setpl2:                                   ;* je zadan˜ parametr ?
         call      outspc                   ; test p©ipraven‚ho znaku
         mov       al,0                     ; n vratov˜ k¢d (= OK)
         jc        navrat                   ; je konec textu
         je        setpl5                   ; je oddˆlovac¡ ‡ rka
         call      inpnum                   ; vstup ‡¡sla palety
         call      setpal                   ; nastaven¡ paletov‚ho registru
setpl5:  call      outspc
         mov       al,0
         jc        navrat
         inc       si
         dec       cx
         inc       bl                       ; zv˜¨en¡ ukazatele registr– palet
         jmp       short setpl2             ; dal¨¡ parametr


error2:  lea       dx,[errtxt2]
         jmp       short error1             ; zobrazen¡ chybov‚ho textu 2

error:   lea       dx,[errtxt]
error1:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       al,1                     ; n vratov˜ k¢d
navrat:  mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h


outspc:                                   ;* vypu¨tˆn¡ mezer
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ;        CX=‡¡ta‡ znak–
                                            ; VSTUP: AL=p©ipraven˜ znak
                                            ;         CY=nen¡ dal¨¡ znak
                                            ;         ZY=je oddˆlovac¡ ‡ rka

         call      testch                   ; test znaku
         jbe       outspc2                  ; je konec © dku nebo ‡ rka
         cmp       al,32                    ; je oddˆlovac¡ mezera ?
         ja        outspc2                  ; je platn˜ znak
         inc       si                       ; zv˜¨en¡ adresy v textu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jmp       short outspc             ; dal¨¡ znak
outspc2: ret


inpnum:                                   ;* vstup ‡¡sla z parametru
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ;        CX=‡¡ta‡ znak–
                                            ; VSTUP: BH=na‡ten˜ parametr

         xor       bh,bh                    ; na‡¡tan‚ ‡¡slo
inpnum1: call      testch                   ; test p©ipraven‚ho znaku
         jbe       inpnum2                  ; je oddˆlova‡ nebo konec © dku
         cmp       al,"9"
         ja        inpnum2
         sub       al,"0"
         jb        inpnum2
         inc       si
         dec       cx
         xchg      al,bh
         mov       ah,10
         mul       ah
         add       al,bh
         mov       bh,al
         jmp       short inpnum1
inpnum2: ret



testch:                                   ;* test zad n¡ znaku
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ;        CX=‡¡ta‡ znak–
                                            ; VSTUP: AL=p©ipraven˜ znak
                                            ;         CY=nen¡ dal¨¡ znak
                                            ;         ZY=je oddˆlovac¡ ‡ rka

         stc                                ; p©¡znak konce textu
         jcxz      testch2                  ; nen¡ dal¨¡ znak
         mov       al,ds:[si]               ; p©ipraven˜ znak
         cmp       al,","                   ; je oddˆlovac¡ ‡ rka ?
         clc                                ; nulov n¡ p©¡znaku CF
testch2: ret


setpal:                                   ;* nastaven¡ palety
                                            ; VSTUP: BL=‡¡slo registru
                                            ;        BH=hodnota pro nastaven¡

         push      ax
         push      bx
         push      cx
         push      si
         mov       ax,1000h
         cmp       bl,10h                   ; je barva okol¡ ?
         jb        setpal2                  ; je paleta okol¡
         inc       al                       ; slu‘ba nastaven¡ barvy okol¡
setpal2: int       10h                      ; nastaven¡ palety
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret


errtxt   db        'Neni nainstalovana karta EGA !',13,10,'$'

errtxt2  db        'SETPAL V1.10 - palety displeje EGA/VGA; (c) M. Nemecek',13,10
         db        'Pr.: SETPAL 0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63,0',13,10
         db        '  ÚÄÄÄbarevna slozkaÄÄÄÄÂÄintenzita jasuÄÂÄhodnotaÄ¿',13,10
         db        '  ³       modra         ³       2/3      ³    1    ³',13,10
         db        '  ³      zelena         ³       2/3      ³    2    ³',13,10
         db        '  ³      cervena        ³       2/3      ³    4    ³',13,10
         db        '  ³  sekundarni modra   ³       1/3      ³    8    ³',13,10
         db        '  ³  sekundarni zelena  ³       1/3      ³   16    ³',13,10
         db        '  ³ sekundardni cervena ³       1/3      ³   32    ³',13,10
         db        '  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ',13,10
         db        'Vysledna hodnota pro nastaveni paletoveho registru se',13,10
         db        '  ziska souctem hodnot jednotlivych barevnych slozek.',13,10
         db        '  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄstandardni nastaveniÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
         db        '  ³  0 :=  0 cerna     ³  8 := 56 seda             ³',13,10
         db        '  ³  1 :=  1 modra     ³  9 := 57 svetle modra     ³',13,10
         db        '  ³  2 :=  2 zelena    ³ 10 := 58 svetle zelena    ³',13,10
         db        '  ³  3 :=  3 tyrkysova ³ 11 := 59 svetle tyrkysova ³',13,10
         db        '  ³  4 :=  4 cervena   ³ 12 := 60 svetle cervena   ³',13,10
         db        '  ³  5 :=  5 purpurova ³ 13 := 61 svetle purpurova ³',13,10
         db        '  ³  6 := 20 hneda     ³ 14 := 62 zluta            ³',13,10
         db        '  ³  7 :=  7 bila      ³ 15 := 63 jasne bila       ³',13,10
         db        '  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄokoli := 0 cernaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
         db        '$'


code     ENDS
         END       start               ; startovac¡ adresa

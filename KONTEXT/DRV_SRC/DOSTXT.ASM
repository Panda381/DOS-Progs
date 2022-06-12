;      *****  Textovò driver karty ega pro program kontext.com  *****
;              po p©ekladu od adresy 0 m† soubor jmÇno egatxt.ovl

code     SEGMENT   page
         ASSUME    cs:code,ds:code

start:                                      ; vstup do driveru

displej  proc      far
                                            ; vyvol†n° podprogramu,
                                            ;  jehoë á°slo je v BX
         push      ds
         mov       dx,cs
         mov       ds,dx                    ; datovò segment = program. segment
         shl       bx,1
         call      [bx+adrsub]              ; vyvol†n° podprogramu podle tabulky
         pop       ds
         ret
displej  endp


tabega   db        0,3,6,0deh,2ah,8,0deh,30h,0eh,0deh,38h
karta    db        'EGA'

invmsk   db        0                        ; maska znakñ (pro inverzi)
whide    db        0                        ; p©°znak dvojn†sobnÇho znaku
mode     db        0                        ; reëim obrazovky (1,2,3)
vyska    db        0                        ; poáet linek na ©†dek

normal   db        0 ;(1*16+11)             ; barva norm†ln°ho textu

invert   db        0 ;(11*16+1)             ; barva textu menu

cara     db        0 ;(6*16+11)             ; barva okraje (hnàd†)
zvyraz   db        0 ;(16+14)               ; zvòraznànÇ p°smo (ëlutÇ)
sikme    db        0 ;(16+10)               ; ®ikmÇ p°smo (zelen†)
podtrz   db        0 ;(16+13)               ; podtrëenÇ p°smo (fialov†)
jine     db        0 ;(16+15)               ; jinÇ kombinace typñ (b°l†)

                                            ; ADRESY PODPROGRAM¶
adrsub   dw        offset fnc00             ; funkce 00 - vòstup znaku
         dw        offset fnc01             ; funkce 01 - kurzor, maz†n°
         dw        offset fnc02             ; funkce 02 - rolov†n° nahoru
         dw        offset fnc03             ; funkce 03 - rolov†n° dolñ
         dw        offset fnc04             ; funkce 04 - pravò okraj (á†ra)
         dw        offset fnc05             ; funkce 05 - inicializace parametrñ
         dw        offset fnc06             ; funkce 06 - nastaven° text. m¢du
         dw        offset fnc07             ; funkce 07 - adr. n†povàdy (ES:SI)
         dw        offset fnc08             ; funkce 08 - adr. chybovòch hl†®en°
         dw        offset fnc09             ; funkce 09 - rozdàlov†n° slov
         dw        offset fnc10             ; funkce 10 - dek¢dov†n° k¢du kl†ves
         dw        offset fnc11             ; funkce 11 - vòpis k¢du kl†vesy



                                            ; FUNKCE 00 - vòstup znaku

                                            ; SS:BP = ukazatel parametrñ znaku
                                            ;   +4 = ©†dek znaku
                                            ;   +6 = pozice znaku na ©†dku
                                            ;   +8 = znak k vòstupu
                                            ; AH = m¢d znaku
                                            ;   01 = nadsazenÇ p°smo
                                            ;   02 = podsazenÇ p°smo
                                            ;   04 = ®ikmÇ p°smo
                                            ;   08 = podtrëenò text
                                            ;   10 = zvòraznànÇ p°smo
                                            ;   20 = inverzn° p°smo

fnc00:
         cld
         mov       ch,ah                    ; m¢d znaku
         mov       ax,[bp+4]                ; ©†dek znaku
         mov       bx,80
         mul       bx                       ; offset zaá†tku ©†dku
         mov       bx,[bp+6]                ; pozice znaku na ©†dku
         dec       bx
         cmp       bx,0
         jl        fnc009                   ; je z†porn† pozice
         cmp       bx,80
         jnc       fnc009                   ; je velk† pozice
         add       ax,bx                    ; poáet znakñ od zaá†tku obrazovky
         add       ax,ax                    ; offset znaku ve VRAM
         mov       di,ax
         push      es
         mov       ax,0b800h                ; segment VRAM
         mov       es,ax
         mov       ax,[bp+8]                ; znak k vòstupu
         cmp       al,255                   ; je znak dvojn†sobnÇ ®°©ky ?
         jnz       fnc003                   ; nen°
         mov       al,22                    ; znak silnÇho podtrhov†tka
fnc003:  stosb                              ; uloëen° znaku k vòstupu
         mov       al,ds:[invert]           ; inverzn° p°smo
         test      ch,20h                   ; inverzn° p°smo ?
         jnz       fnc001                   ; je inverzn° p°smo
;         cmp       bx,79
;         jnz       fnc002
;         cmp       word ptr [bp+4],0        ; je prvn° ©†dek ?
;         jz        fnc001                   ; je prvn° ©†dek
fnc002:  mov       al,ds:[zvyraz]           ; zvòraznànÇ p°smo
         test      ch,10h
         jnz       fnc001                   ; je zvòraznànÇ p°smo
         mov       al,ds:[sikme]            ; ®ikmÇ p°smo
         test      ch,4
         jnz       fnc001
         mov       al,ds:[podtrz]           ; podtrëenò text
         test      ch,8
         jnz       fnc001
         mov       al,ds:[jine]
         or        ch,ch
         jnz       fnc001                   ; jsou nàjakà atributy
         mov       al,ds:[normal]           ; barva norm†ln°ho textu
fnc001:  stosb                              ; nastaven° atributu znaku
         pop       es
fnc009:  ret

                                            ; FUNKCE 01 - kurzor a maz†n°

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = parametr pro z†pis okna
                                            ;          = 0 norm†ln° okno
                                            ;          = 1 invertovanÇ okno
                                            ;          = 2 kurzor
                                            ;    + 6 = koneánò ©†dek
                                            ;    + 8 = koneán† pozice
                                            ;    +10 = poá†teán° ©†dek
                                            ;    +12 = poá†teán° pozice

fnc01:
         cld
         mov       ax,[bp+10]               ; poá†teán° ©†dek okna
         mov       bx,[bp+6]                ; koneánò ©†dek
         cmp       ax,bx                    ; koneánò ©†dek
         jbe       fnc01d1
         cmp       byte ptr [bp+4],2
         jnz       fnc01d1
         dec       ax
         mov       bx,ax
fnc01d1: mov       di,ax
         shl       di,1
         shl       di,1
         add       di,ax                    ; DI = AX * 5
         shl       di,1
         shl       di,1
         shl       di,1
         shl       di,1                     ; DI = offset zaá†tku ©†dku
         sub       bx,ax
         inc       bx
         mov       ax,[bp+12]               ; poá†teán° pozice
         or        ax,ax
         jg        fnc01a1                  ; je kladn† pozice
         mov       ax,1
fnc01a1: mov       cx,[bp+8]                ; koneán† pozice na ©†dku
         cmp       cx,80
         jng       fnc010r
         mov       cx,80
fnc010r: dec       ax                       ; poá†teán° pozice
         sub       cx,ax                    ; ®°©ka okna (pozic)
         jng       fnc011                   ; ®°©ka okna nen° kladn†
         add       di,ax                    ; offset zaá†tku okna
         add       di,di                    ; adresa zaá†tku okna ve VRAM
fnc0103: push      es
         mov       ax,0b800h                ; segment VRAM
         mov       es,ax
;         mov       ah,2*16+1               ; z†kladn° barva textu
         cmp       byte ptr [bp+4],1        ; parametr
         ja        fnc0107                  ; je kurzor
         mov       ah,ds:[normal]           ; je norm†ln° text
         jc        fnc010a                  ; je inverzn° text
         mov       ah,ds:[invert]           ; inverzn° text
;         mov       ah,7
;         mov       cx,20
;         mov       bx,3
fnc010a: mov       al,32
fnc0104: push      di
         push      cx
         rep       stosw
         pop       cx
         pop       di
         add       di,160
         dec       bx
         jnz       fnc0104
         pop       es
         ret

fnc0107:
fnc010:  push      di
         push      cx                       ; á°taá znakñ na ©†dek
fnc0102: inc       di
         mov       al,es:[di]               ; nastavenò atribut
         not       al
         cmp       [mode],3                 ; reëim 16 barev
         jz        fnc0106
         cmp       [mode],2                 ; reëim 8 barev
         jz        fnc01e1
         not       al
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1
fnc01e1: and       al,7fh
fnc0106: stosb
         dec       cx
         jnz       fnc0102
;         rep       stosw                    ; vymaz†n° ©†dku
         pop       cx
         pop       di
         add       di,160
         dec       bx                       ; á°taá ©†dkñ
         jnz       fnc010                   ; dal®° ©†dek
         pop       es
fnc011:  ret

                                            ; FUNKCE 02 - rolov†n° okna nahoru

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = koneánò ©†dek rolov†n°
                                            ;    + 6 = koneán† pozice
                                            ;    + 8 = poá†teán° ©†dek k rol.
                                            ;    +10 = poá†teán° pozice okna

fnc02:   ; ret

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         sub       ax,[bp+8]                ; poá†teán° ©†dek k rol.-poáet ©†dkñ
         jz        fnc029                   ; nen° ë†dnò ©†dek - konec
         mov       bx,ax                    ; poáet ©†dkñ k rolov†n°
         mov       ax,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         mov       cx,160
         mul       cx                       ; poá†teán° adresa poá†t. ©†dku
         mov       si,ax                    ; poá†teán° adresa poá†t. ©†dku
         mov       di,ax                    ; adresa n†sleduj°c°ho ©†dku
         add       si,160
         mov       ax,[bp+10]               ; poá†teán° pozice okna
         dec       ax
         add       di,ax                    ; poá†teán° adresa
         add       di,ax
         add       si,ax
         add       si,ax
         mov       cx,[bp+6]                ; koneán† pozice
         sub       cx,ax                    ; poáet pozic okna k rolov†n°
         add       cx,cx
         push      es
         push      ds
         mov       ax,0b800h                ; segment displeje
         mov       es,ax
         mov       ds,ax
         cld                                ; p©enos nahoru
fnc022:  push      si
         push      di
         push      cx
         repnz     movsb
         pop       cx
         pop       di
         pop       si
         add       di,160
         add       si,160
         dec       bx
         jnz       fnc022
         pop       ds
         pop       es
fnc029:  ret






                                            ; FUNKCE 03 - rolov†n° okna dolñ

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = koneánò ©†dek rolov†n°
                                            ;    + 6 = koneán† pozice okna
                                            ;    + 8 = poá†teán° ©†dek k rol.
                                            ;    +10 = poá†teán° pozice okna


fnc03:   ; ret

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         sub       ax,[bp+8]                ; poá†teán° ©†dek k rol.-poáet ©†dkñ
         jz        fnc039                   ; nen° ë†dnò ©†dek - konec
         mov       bx,ax                    ; poáet ©†dkñ k rolov†n°
         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       cx,160
         mul       cx                       ; poá†teán° adresa koneánÇho ©†dku
         mov       si,ax                    ; poá†teán° adresa koneánÇho ©†dku
         mov       di,ax                    ; adresa n†sleduj°c°ho ©†dku
         add       di,160
         mov       ax,[bp+10]               ; poá†teán° pozice okna
         dec       ax
         add       di,ax                    ; poá†teán° adresa
         add       di,ax
         add       si,ax
         add       si,ax
         mov       cx,[bp+6]                ; koneán† pozice
         sub       cx,ax                    ; poáet pozic okna k rolov†n°
         add       cx,cx
         push      es
         push      ds
         mov       ax,0b800h                ; segment displeje
         mov       es,ax
         mov       ds,ax
         cld                                ; p©enos nahoru
fnc032:  sub       di,160
         sub       si,160
         push      si
         push      di
         push      cx
         repnz     movsb
         pop       cx
         pop       di
         pop       si
         dec       bx
         jnz       fnc032
         pop       ds
         pop       es
fnc039:  ret





                                            ; FUNKCE 04 - pravò okraj (á†ra)

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = k¢d á†ry
                                            ;    + 6 = koneánò ©†dek
                                            ;    + 8 = poá†teán° ©†dek
                                            ;    +10 = pozice á†ry

fnc04:
         cld
         mov       si,[bp+10]               ; pozice á†ry
         dec       si
         jl        fnc042                   ; z†porn† pozice
         cmp       si,word ptr 79
         ja        fnc042
         mov       ax,[bp+6]                ; koneánò ©†dek
         mov       di,[bp+8]                ; poá†teán° ©†dek
         sub       ax,di
         inc       ax                       ; poáet ©†dkñ
         mov       cx,ax                    ; poáet ©†dkñ
         mov       ax,80
         mul       di
         mov       di,ax
         add       di,si
         add       di,di
         push      es
         mov       ax,0b800h
         mov       es,ax
         mov       dl,ds:[cara]             ; barva okraje
         mov       dh,ds:[normal]           ; barva norm†ln°ho textu
fnc041:  mov       al,es:[di+1]
         cmp       al,dl
         mov       al,dl
         jnz       fnc043
         mov       al,dh
fnc043:  mov       es:[di+1],al
         add       di,160
         loop      fnc041
         pop       es
fnc042:  ret


                                            ; FUNKCE 05 - inicializace parametrñ

                                            ; SS:BP = ukazatel parametrñ znaku
                                            ;   +4 = barva podkladu
                                            ;   +6 = barva p°sma
                                            ;   +8 = reëim obrazovky (©†dkov†n°)

fnc05:
         mov       al,[bp+8]
         mov       [mode],al
         cld
         mov       ax,[bp+4]                ; barva podkladu
         mov       bx,[bp+6]                ; barva p°sma
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1
         and       bl,0fh
         or        al,bl
         cmp       [mode],3                 ; 16 barev
         jz        fnc053
         cmp       [mode],2                 ; 8 barev
         jz        fnc056
         and       al,77h
fnc056:  and       al,7fh
fnc053:  mov       bl,al
         mov       [normal],al              ; nastaven° barvy norm†ln°ho textu
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1
         cmp       [mode],2                 ; displej CGA
         jnz       fnc054
         and       al,7fh
fnc054:  mov       [invert],al
         cmp       [mode],1                 ; displej MONO
         jnz       fnc055
         mov       [zvyraz],al
         mov       [sikme],al
         mov       [podtrz],al
         mov       [jine],al
         jmp       short fnc051
fnc055:  and       bl,0f0h
         mov       al,bl
         or        al,14
         mov       [zvyraz],al              ; zvòraznànÇ p°smo
         mov       al,bl
         or        al,10
         mov       [sikme],al               ; ®ikmÇ p°smo
         mov       al,bl
         or        al,13
         mov       [podtrz],al              ; podtrëenÇ p°smo
         mov       al,bl
         or        al,15
         mov       [jine],al                ; jinÇ p°smo
         and       al,70h
         cmp       al,50h
         mov       al,7
         jnc       fnc051
         mov       al,70h
fnc051:  mov       [cara],al                ; barva á†ry okraje

         mov       ah,15
         int       10h                      ; poskytnut° videom¢du
         cmp       al,3
         jz        fnc052                   ; videom¢d je nastaven
         mov       ax,3
         int       10h                      ; nastaven° videom¢du
fnc052:  mov       bh,[bp+4]
         cmp       [mode],3                 ; 16 barev
         jz        fnc057
         and       bh,7
fnc057:  mov       ax,1001h
         int       10h                      ; nastaven° okol° obrazovky
         mov       ax,1003h
         mov       bl,0
         int       10h                      ; nastaven° atributu s jasem
         mov       dx,25*256+80
         mov       ah,2
         mov       bh,0
         int       10h                      ; nastaven° kurzoru mimo obrazovku
         mov       ax,80
         mov       si,offset karta
         mov       bx,1
         mov       cx,25
         ret


                                            ; FUNKCE 06 - nastaven° tex. m¢du
fnc06:   mov       ax,3
         int       10h                      ; nastaven° textovÇho m¢du 80x25
         ret

                                            ; slovn°k 1
slov1    db        'ANA ANI ABE ALTR EINI DEST GEI INI INS '
         db        'NACHT UNIV ZEITEN ZEITU ',0ffh

                                            ; slovn°k 2
slov2    db        'AB AN AUF AUS NACH UN VER VOR ',0ffh

                                            ; slovn°k 3
slov3    db        'ALT ALP BETT BERG DES EIN ERD ERNST FETT FEST '
         db        'GELD HAUS KREUZ LANG LEIT MACHT MAUS MENSCH NORD '
         db        'NéCHST NETZ OBER OST REIT RöCK SCHUL SPIEL SöD '
         db        'TEST TIEF VOLL WACHS WASCH WEIT WETT WEG WEST ',0ffh

                                            ; slovn°k 4
slov4    db        'DURCH LETZTEND SPORT TRANS ',0ffh

                                            ; slovn°k 5
slov5    db        'DORT HOCH ZEIT öBER ',0ffh

                                            ; slovn°k 6
slov6    db        'CHA CURS DAR EMPF ENT HIN HER KOMP MIT SYN ',0ffh

                                            ; slovn°k 7
slov7    db        'ABL ABR ALLEIN ANEI ANER ANORD ANS AT BEEH BEEI '
         db        'BEEN BEERD BEIRR BEOB BEUN BEUR ER GE IN KOOR '
         db        'OKT UM UR ZUGABE ',0ffh

                                            ; slovn°k 8
slov8    db        'AI AU AY EI EU EY éU ',0ffh

                                            ; slovn°k 9
slov9    db        'EA Eé Eô Eö II Ié Iô Iö OA OE UE UI UU ',0ffh

                                            ; slovn°k 10
slov10   db        'BL BR CH DR FL FR GL GR KL KN KR PFL PH PF '
         db        'PL PR SCHL SCHM SCHN SCHR SCHW STR SPR SCH '
         db        'SP ST TH TR ZW ',0ffh

                                            ; slovn°k 11
slov11   db        'BS B CHTS CHS CHT CKT CH CK D FF FS F GS G '
         db        'HRS HL HM HN HR HT H KT K LBST LSCH LCH LFS '
         db        'LKS LTS LB LD LF LG LK LL LP LS LT L '
         db        'MPF MTS MM MP MT M NSCH NGS NDS NST ND NN NF '
         db        'NG NK NS NT NZ N PF PP PT P '
         db        'RSCH RCH RKT RST RB RD RF RG RK RM RN RS RT '
         db        'RZ R SCH ST S TSCH TZT TS TT TZ T XT Z '
         db        '· ',0ffh

                                            ; slovn°k 12
slov12   db        'EITS IONS LLGE NSGE UNGS ',0ffh

                                            ; slovn°k 13
slov13   db        'HAUS HEIT LICH LADE LAND LER LIG LOS PHA PREIS '
         db        'PUNKT RAND RAUM RECHT RECHN REICH RIG ROUT '
         db        'RUF ',0ffh

                                            ; slovn°k 14
slov14   db        'AUS AUF AUGE AUTO AMT ART AB ARZT ARBEIT AKT '
         db        'ALGO ANALY ANDER ANF ANGAB ANGEB ANL ANOR '
         db        'ANSA ANTEIL ANWA ANWEN ANZAHL ANZEIG ANTW '
         db        'APFEL AFRI AMERI ADR APP ARGU EBENE ECK EDITO '
         db        'EIN EFF EURO ELEM ENERG ENTW EIMER ERDA '
         db        'ERGEBN ERFA ERLEB ERFO ERHAL ERKENN ETW EXP '
         db        'INDU INF INH INS IMP OBER ORDN ORDEN OPER ORGA '
         db        'ORIENT ORT UHR UMBRU UNFALL UNTER UMSATZ '
         db        'URLAUB URSACH URTEIL éRZT éNDER éMT ôFFN '
         db        'ôKO öB ',0ffh

b0aa4    db        0                        ; povolen† dÇlka ©†dku
b0aa5    dw        0                        ; adresa p©evodn° tabulky znakñ
w0aa7    dw        0
                                            ; test, zda jde o oddàlovac° znak
                                            ; vstup:  DS:[BX+DI] = ukaz. textu
                                            ;         ES:[CS:[B0AA5]] p©ev.tab.
                                            ; vòstup: ZF = 0 je oddàlovac° znak

tst04:   mov       ah,4
         jmp       short tst401

                                            ; test, zda jde o ©°d°c° znak
                                            ; vstup:  DS:[BX+DI] = ukaz. textu
                                            ;         ES:[CS:[B0AA5]] p©ev.tab.
                                            ; vòstup: ZF = 0 je ©°d°c° znak

tst40:   mov       ah,40h
tst401:  mov       al,[bx+di]               ; znak z textu k otestov†n°
         push      bx
         mov       bx,cs:[b0aa5]            ; adresa tabulky oddàlovac°ch znakñ
         db        26h
         xlat                               ; transformace podle tab. ES:BX
         test      ah,al
         pop       bx
         ret

                                            ; nalezen° zaá†tku slova v textu
                                            ; vstup:  DS:[BX+DI] = ukaz.textu

endwrd:  dec       bx                       ; ukazatel textu
endwrd1: inc       bx
         call      tst40                    ; test, zda jde o ©°d°c° znak
         jnz       endwrd2                  ; je ©°d°c° znak - konec
         test      al,4                     ; jde o oddàlovac° znak slova ?
         jnz       endwrd1                  ; je oddàlovac° znak slova - dal®°
endwrd2: ret

                                            ; nalezen° slova ve slovn°ku

                                            ; vstup:  CS:[SI] = ukazatel tabulky
                                            ;         DS:[BX+DI] = ukaz. textu
                                            ; vòstup: AX = dÇlka shodnÇho slova
                                            ;         (AX = 0,ZF = 0 nenalezeno)

srcwrd:  mov       ah,32                    ; oddàlovac° znak slov (mezera)
srcwrd1: mov       al,cs:[si]               ; prvn° znak slova z tabulky
         cmp       al,[bx+di]               ; porovn†n° se znakem v textu
         ja        srcwrd5                  ; znak v tabulce vàt®° - nenalezeno
         jc        srcwrd3                  ; znak v tabulce men®° - dal®° slovo
         push      bx                       ; (shoda prvn°ho znaku) ukaz. textu
srcwrd2: inc       bx                       ; ukazatel zkoumanÇho textu
         inc       si                       ; ukazatel slovn°ku
         mov       al,cs:[si]               ; dal®° znak ze slovn°ku
         cmp       al,ah                    ; je mezera (konec slova) ?
         jz        srcwrd4                  ; je mezera = konec slova
         cmp       al,[bx+di]               ; porovn†n° dal®°ho znaku slova
         jz        srcwrd2                  ; shoda - dal®° znak
         pop       bx                       ; (nen° shoda) ukazatel textu
srcwrd3: inc       si                       ; nalezen° dal®°ho slova v tabulce
         cmp       ah,cs:[si]               ; je oddàlovac° mezera ?
         jnz       srcwrd3                  ; je®tà ne - dal®° znak v tabulce
         inc       si
         jmp       short srcwrd1            ; test dal®°ho slova
srcwrd4: mov       ax,bx                    ; slova se shoduj°
         pop       bx                       ; adresa slova ve slovn°ku
         sub       ax,bx                    ; dÇlka nalezenÇho slova
         ret
srcwrd5: xor       ax,ax                    ; slovo nenalezeno - konec (dÇlka 0)
         ret


lab0af5: push      bx                       ; adresa textu
         add       bx,ax                    ; adresa konce slabiky (rozdàlit)
         push      bx                       ; adresa konce slabiky
         call      endwrd                   ; nalezen° konce slova v textu
         mov       ax,bx                    ; konec slova v textu
         pop       bx                       ; adresa konce slabiky
         jz        lab0af51                 ; je jië konec ©†dku
         sub       ax,bx                    ; poáet znakñ do konec slova
         cmp       al,1                     ; dÇlka zbylÇ á†sti slova
         jna       lab0af52                 ; nen° jië ë†dnò znak
         push      ax                       ; dÇlka zbylÇ á†sti slova
         mov       si,offset slov10         ; slovn°k 10
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         pop       si                       ; dÇlka zbylÇ á†sti slova
         cmp       ax,si                    ; nalezeno stejnà dlouhÇ slovo ?
         jz        lab0af52                 ; je celÇ slovo
         xor       ax,ax                    
lab0af51:pop       bx                       
         ret                                
lab0af52:pop       si                       
lab0af53:cmp       bl,cs:[b0aa4]             ; povolen† dÇlka ©†dku
         jnc       lab0af55                  ; p©ekroáen okraj ©†dku
         inc       dx                       
         cmp       dx,bx                    
         mov       dx,bx                    
         jz        lab0af54                 
         mov       cs:[w0aa7],bx
lab0af54:ret                                
lab0af55:jmp       fnc097

                                            ;
lab0b2f: mov       si,offset slov1          ; slovn°k 1 - nelze rozdàlit
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jnz       lab0b2f5                 ; slovo nalezeno - konec
lab0b2f1:mov       si,offset slov2          ; slovn°k 2 - lze rozdàlit
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b2f2                 ; slovo nenalezeno - slovn°k 3
         call      lab0af5                 
         jnz       lab0b2f1                
lab0b2f2:mov       si,offset slov3          ; slovn°k 3
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b2f3                
         mov       si,di                   
         add       si,ax                   
         cmp       byte ptr [bx+si],"E"     ; je znak "E" ?
         jnz       lab0b2f4                
lab0b2f3:mov       si,offset slov4          ; slovn°k 4
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,5                    
         jnz       lab0b2f4                
         mov       si,offset slov5          ; slovn°k 5
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,4                    
         jnz       lab0b2f4                
         mov       si,offset slov6          ; slovn°k 6
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,3                    
         jnz       lab0b2f4                
         mov       si,offset slov7          ; slovn°k 7
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,2                    
         jz        lab0b2f5                
lab0b2f4:call      lab0af5                 
lab0b2f5:ret

lab0b85: mov       ax,bx                   
         sub       ax,cx                   
         cmp       ax,2                    
         xchg      bx,cx                   
         jc        lab0b853                
         jz        lab0b851                
         mov       si,offset slov8          ; slovn°k 8
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b851                
         inc       bx                      
         jmp       short lab0b852          
lab0b851:mov       si,offset slov9          ; slovn°k 9
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b853                
         cmp       byte ptr [bx+di-1],"Q"   ; je znak "Q" ?
         jz        lab0b853                
lab0b852:inc       bx                      
         call      lab0af53                
lab0b853:xchg      bx,cx                   
         ret       

lab0bb2: cmp       bx,cx
         jz        lab0bb27
         push      bx
         push      dx
         mov       dx,bx
         dec       dx
         mov       bx,cx
         dec       bx
lab0bb21:inc       bx
         cmp       bx,dx
         jz        lab0bb22
         mov       si,offset slov10         ; slovn°k 10
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0bb21
         add       ax,bx
         dec       ax
         cmp       ax,dx
         jnz       lab0bb21
         cmp       byte ptr [bx+di-1],"C"   ; byl p©edchoz° znak "C" ?
         jz        lab0bb21
lab0bb22:xchg      bx,cx
         mov       si,offset slov11         ; slovn°k 11
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         add       bx,ax
         xchg      bx,cx
         cmp       bx,cx
         jnc       lab0bb26
         mov       dx,bx
lab0bb23:mov       si,offset slov12         ; slovn°k 12
         push      bx
         sub       bx,4
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         pop       bx
         jz        lab0bb24
         cmp       byte ptr cs:[w0aa7],0
         jnz       lab0bb26
lab0bb24:call      tst40                    ; test, zda jde o ©°d°c° znak
         mov       si,offset slov14         ; slovn°k 14
         jnz       lab0bb25
         mov       si,offset slov13         ; slovn°k 13
lab0bb25:call      srcwrd                   ; nalezen° slova ve slovn°ku
         jnz       lab0bb26
         inc       bx
         cmp       bx,cx
         jna       lab0bb23
         mov       bx,dx
lab0bb26:pop       dx
         call      lab0af53
         pop       bx
lab0bb27:ret

                                            ; FUNKCE 09 - rozdàlov†n° slov
                                            ; vstup:  DS = datovò segment textu
                                            ;         CX = pozice v ©†dku

fnc09:   mov       [w0aa7],0
         mov       [b0aa4],al               ; povolen† dÇlka ©†dku
         mov       [b0aa5],si               ; adresa transformaán° tabulky znakñ
         pop       dx                       ; n†vratov† adresa programu
         pop       ds                       ; datovò segment textu
         push      ds                       ; datovò segment textu
         push      dx                       ; n†vratov† adresa programu
         push      bp                       
         mov       bp,sp                    
fnc091:  mov       bx,cx                    ; aktu†ln° pozice v ©†dku
         dec       bx                       
fnc092:  inc       bx                       ; dal®° znak
         cmp       bl,cs:[b0aa4]            ; povolen† dÇlka ©†dku
         jnc       fnc097                   ; p©ekroáen okraj ©†dku - konec
         call      tst04                    ; test, zda jde o oddàlovac° znak
         jz        fnc092                   ; nenalezeno - dal®°
         mov       cx,bx                    ; nov† pozice rozdàlen° slova
         dec       bx                       
fnc093:  inc       bx                       
         call      tst04                    ; test, zda jde o oddàlovac° znak
         jnz       fnc093                   ; nalezeno - dal®° pokus
         xchg      bx,cx                    
         mov       ax,cx                    
         sub       ax,bx                    
         cmp       ax,4                     
         jc        fnc091                   
         mov       dx,bx                    
         call      lab0b2f                  
         call      endwrd                   ; nalezen° zaá†tku slova v textu
         jz        fnc091                   
         push      cx                       
fnc094:  mov       cx,bx                    
         dec       bx                       
fnc095:  inc       bx                       
         call      tst40                    ; test, zda jde o ©°d°c° znak
         jnz       fnc095                   
         call      lab0b85                  
         mov       cx,bx                    
         call      endwrd                   ; nalezen° zaá†tku slova v textu
         jz        fnc096                   
         call      lab0bb2                  
         jmp       short fnc094             
fnc096:  pop       cx                       
         jmp       short fnc091             
fnc097:  mov       ax,cs:[w0aa7]            
         mov       sp,bp                    
         pop       bp                       
         ret                                


                                            ; tabulka pro p©ek¢dov†n° kl†ves

tabkey   db        0c1h,1eh                 ; ALT A
         db        0c2h,30h                 ; ALT B
         db        0c3h,2eh                 ; ALT C
         db        0c4h,20h                 ; ALT D
         db        0c5h,12h                 ; ALT E
         db        0c6h,21h                 ; ALT F
         db        0c7h,22h                 ; ALT G
         db        0c8h,23h                 ; ALT H
         db        0c9h,17h                 ; ALT I
         db        0cah,24h                 ; ALT J
         db        0cbh,25h                 ; ALT K
         db        0cch,26h                 ; ALT L
         db        0cdh,32h                 ; ALT M
         db        0ceh,31h                 ; ALT N
         db        0cfh,18h                 ; ALT O
         db        0d0h,19h                 ; ALT P
         db        0d1h,10h                 ; ALT Q
         db        0d2h,13h                 ; ALT R
         db        0d3h,1fh                 ; ALT S
         db        0d4h,14h                 ; ALT T
         db        0d5h,16h                 ; ALT U
         db        0d6h,2fh                 ; ALT V
         db        0d7h,11h                 ; ALT W
         db        0d8h,2dh                 ; ALT X
         db        0d9h,15h                 ; ALT Y
         db        0dah,2ch                 ; ALT Z
         db        0f0h,81h                 ; ALT 0
         db        0f1h,78h                 ; ALT 1
         db        0f2h,79h                 ; ALT 2
         db        0f3h,7ah                 ; ALT 3
         db        0f4h,7bh                 ; ALT 4
         db        0f5h,7ch                 ; ALT 5
         db        0f6h,7dh                 ; ALT 6
         db        0f7h,7eh                 ; ALT 7
         db        0f8h,7fh                 ; ALT 8
         db        0f9h,80h                 ; ALT 9
         db        1bh,3bh                  ; F1
         db        1ch,3ch                  ; F2
         db        1dh,3dh                  ; F3
         db        1eh,3eh                  ; F4
         db        1fh,3fh                  ; F5
         db        20h,40h                  ; F6
         db        21h,41h                  ; F7
         db        22h,42h                  ; F8
         db        23h,43h                  ; F9
         db        24h,44h                  ; F10
         db        5bh,54h                  ; SHIFT F1
         db        5ch,55h                  ; SHIFT F2
         db        5dh,56h                  ; SHIFT F3
         db        5eh,57h                  ; SHIFT F4
         db        5fh,58h                  ; SHIFT F5
         db        60h,59h                  ; SHIFT F6
         db        61h,5ah                  ; SHIFT F7
         db        62h,5bh                  ; SHIFT F8
         db        63h,5ch                  ; SHIFT F9
         db        64h,5dh                  ; SHIFT F10
         db        9bh,5eh                  ; CTRL F1
         db        9ch,5fh                  ; CTRL F2
         db        9dh,60h                  ; CTRL F3
         db        9eh,61h                  ; CTRL F4
         db        9fh,62h                  ; CTRL F5
         db        0a0h,63h                 ; CTRL F6
         db        0a1h,64h                 ; CTRL F7
         db        0a2h,65h                 ; CTRL F8
         db        0a3h,66h                 ; CTRL F9
         db        0a4h,67h                 ; CTRL F10
         db        0dbh,68h                 ; ALT F1
         db        0dch,69h                 ; ALT F2
         db        0ddh,6ah                 ; ALT F3
         db        0deh,6bh                 ; ALT F4
         db        0dfh,6ch                 ; ALT F5
         db        0e0h,6dh                 ; ALT F6
         db        0e1h,6eh                 ; ALT F7
         db        0e2h,6fh                 ; ALT F8
         db        0e3h,70h                 ; ALT F9
         db        0e4h,71h                 ; ALT F10
         db        0a5h,73h                 ; CTRL <-
         db        0a6h,74h                 ; CTRL ->
         db        0a7h,77h                 ; CTRL HOME
         db        0a8h,75h                 ; CTRL END
         db        0a9h,84h                 ; CTRL PGUP
         db        0aah,76h                 ; CTRL PGDN
         db        6bh,0fh                  ; SHIFT TAB
         db        0,0                      


tabshf   db        6                        ; dÇlka jednÇ poloëky
         db        0,'     '                ; 00h
         db        5,'SHIFT'                ; 40h
         db        4,'CTRL '                ; 80h
         db        3,'ALT  '                ; C0h
         db        0ffh                     

tabhome  db        5                        ; dÇlka jednÇ poloëky
         db        2,'<-  '                 ; 25h
         db        2,'->  '                 ; 26h
         db        4,'HOME'                 ; 27h
         db        3,'END '                 ; 28h
         db        4,'PGUP'                 ; 29h
         db        4,'PGDN'                 ; 2Ah
         db        3,'TAB '                 ; 2Bh
         db        0ffh                     

tabfn    db        4                        ; dÇlka jednÇ poloëky
         db        2,'F1 '                  ; 1Bh
         db        2,'F2 '                  ; 1Ch
         db        2,'F3 '                  ; 1Dh
         db        2,'F4 '                  ; 1Eh
         db        2,'F5 '                  ; 1Fh
         db        2,'F6 '                  ; 20h
         db        2,'F7 '                  ; 21h
         db        2,'F8 '                  ; 22h
         db        2,'F9 '                  ; 23h
         db        3,'F10'                  ; 24h
         db        0ffh                     

                                            ; p©evod textu na velk† p°smena

                                            ; vstup:  ES:SI = ukazatel na text
                                            ;         BL = nejmen®° znak
                                            ; vòstup: ES:[BX+SI] = zaá†tek textu
                                            ;         CX = poáet znakñ textu
                                            ;         CF=0,ZF=0 je konec textu
                                            ;         CF=0,ZF=1 nen° je®tà konec

upper:   xor       cx,cx                    ; vynulov†n° á°taáe znakñ
upper1:  cmp       bl,es:[si]               ; porovn†n° znaku s BL
         ja        upper6                   ; znak je men®° neë BL - konec
         cmp       byte ptr es:[bx+si]," "  ; je mezera ?
         jnz       upper2                   ; nen° - konec hled†n°
         inc       bx                       ; dal®° pozice
         jmp       short upper1             ; dal®° znak
upper2:  push      bx                       
upper3:  cmp       bl,es:[si]               ; kontrola koncovÇho znaku
         ja        upper5                   ; znak je men®° neë BL - konec
         mov       al,es:[bx+si]            ; p©eáten° znaku k p©ek¢dov†n°
         cmp       al," "                   ; je mezera ?
         jz        upper5                   ; je mezera - konec
         cmp       al,"|"                   ; "|"
         jz        upper5                   ; je znak "|" - konec
         cmp       al,"a"                   ; "a"
         jc        upper4                   ; je znak men®° neë "a"
         and       al,0dfh                  ; p©evod na velkÇ p°smeno
         mov       es:[bx+si],al            ; uloëen° p©evedenÇho znaku
upper4:  inc       bx                       ; dal®° znak
         inc       cx                       ; zvò®en° á°taáe nalezenòch znakñ
         jmp       upper3                   ; p©evod dal®°ho znaku na velkò
upper5:  pop       bx                       
upper6:  ret                                

                                            ; nalezen° textovÇ poloëky v tabulce

                                            ; vstup:  ES:[BX+SI] ukazatel textu
                                            ;         DS:DI = ukazatel tabulky
                                            ;         CX = dÇlka hled. textu
                                            ; vòstup: ES:[BX+SI] nov† pozice
                                            ;         DL = po©ad. á°slo poloëky
                                            ;         AX = dÇlka poloëky tabulky

srctab:  mov       al,[di]                  ; p©eáten° dÇlky jednÇ poloëky
         mov       ah,0                     
         inc       di                       ; ukazatel tabulky - prvn° poloëka
         xor       dl,dl                    ; á°taá poloëek
srctab1: inc       dx                       ; zvò®en° á°taáe poloëek
         cmp       cl,[di]                  ; porovn†n° dÇlky textu
         jnz       srctab4                  ; nesouhlas° - dal®° poloëka
         push      ax                       ; dÇlka jednÇ poloëky
         push      bx                       ; ukazatel textu
         push      cx                       ; dÇlka textu
         push      di                       ; ukazatel tabulky
         inc       di                       ; prvn° znak poloëky
srctab2: mov       al,es:[bx+si]            ; zkoumanò znak
         cmp       al,[di]                  ; porovn†n° se znakem z tabulky
         jnz       srctab3                  ; nesouhlas° - dal®° poloëka
         inc       bx                       ; zvò®en° ukazatele textu
         inc       di                       ; zvò®en° ukazatele tabulky
         loop      srctab2                  ; dal®° znak k testu
         pop       di                       ; ukazatel tabulky - nalezeno
         pop       cx                       ; dÇlka textu
         pop       ax                       ; zru®en° pñvodn° pozice textu BX
         pop       ax                       ; dÇlka jednÇ poloëky
         or        dl,dl                    ; po©adovÇ á°slo poloëky
         ret                                
srctab3: pop       di                       ; ukazatel tabulky
         pop       cx                       ; dÇlka textu
         pop       bx                       ; ukazatel zkoumanÇho textu
         pop       ax                       ; dÇlka jednÇ poloëky
srctab4: add       di,ax                    ; adresa dal®° poloëky
         cmp       byte ptr [di],0ffh       ; je koncovò znak tabulky ?
         jnz       srctab1                  ; nen° je®tà konec
         xor       dl,dl                    ; nenalezen - á°slo poloëky = 0
         ret                                


                                            ; FUNKCE 10 - dek¢dov†n° kl†vesy

                                            ; vstup:  ES:SI = ukazatel textu
                                            ; vòstup: ES:SI = nov† pozice
                                            ;         AX = k¢d kl†vesy

fnc10:   mov       bx,1                     ; koncovò znak = 00
         call      upper                    ; p©evod textu na velk† p°smena
         jcxz      fnc106                   ; je jië konec textu
         mov       di,offset tabshf         ; tabulka kl†ves SHIFT,CTRL,ALT
         call      srctab                   ; nalezen° textovÇ poloëky v tabulce
         mov       dh,dl                    ; po©adovÇ á°slo poloëky - £schova
         jz        fnc103                   ; text nebyl nalezen
         dec       dh                       ; po©ad. á°slo poloëky - 1
         call      upper                    ; p©evod textu na velk† p°smena
         jcxz      fnc106                   ; je jië konec textu
         cmp       cx,1                     ; je pouze jeden znak ?
         jnz       fnc102                   ; nen° pr†và jeden znak
         mov       al,es:[bx+si]            ; znak k p©ek¢dov†n°
         cmp       al,"@"                   ; = "@"
         jc        fnc101                   ; men®° neë "@"
         cmp       al,"Z"                   ; = "Z"
         ja        fnc106                   ; vàt®° neë "Z"
         sub       al,40h                   ; p©evod na ©°d°c° znak
fnc101:  mov       dl,al                    ; p©ek¢dovanò znak
         jmp       short fnc104             
fnc102:  mov       di,offset tabhome        ; tabulka ©°d°c°ch kl†ves HOME,...
         call      srctab                   ; nalezen° textovÇ poloëky v tabulce
         jz        fnc103                   ; poloëka nenalezena
         add       dl,24h                   ; korekce
         jmp       short fnc104
fnc103:  mov       di,offset tabfn          ; tabulka funkán°ch kl†ves Fn
         call      srctab                   ; nalezen° textovÇ poloëky v tabulce
         jz        fnc106                   ; nenalezena
         add       dl,1ah                   ; korekce
fnc104:  ror       dh,1                     
         ror       dh,1                     
         or        dl,dh                    ; kl†vesy SHIFT,.. jako bity 6 a 7
         mov       di,offset tabkey         ; tabulka pro dek¢dov†n° k¢dñ kl†ves
fnc105:  mov       al,[di]                  ; k¢d kl†vesy
         inc       di                       
         inc       di                       
         or        al,al                    ; je posledn° k¢d ?
         jz        fnc106                   ; k¢d kl†vesy nenalezen
         cmp       al,dl                    ; porovn†n° s hledanòm k¢dem
         jnz       fnc105                   ; dal®° pokus
         dec       di                       
         mov       al,[di]                  ; p©ek¢dov†n° k¢du kl†vesy
         mov       ah,0                     
         ret                                
fnc106:  xor       ax,ax                    ; k¢d kl†vesy nenalezen
         ret                                

                                            ; vòpis k¢du kl†vesy

                                            ; vstup:  CS:SI tabulka kl†ves
                                            ;         DL = po©ad. á°slo kl†vesy
                                            ;         DS:[BX+DI] = vòst. buffer
                                            ;         CH = 0
                                            ; vòstup: DS:[BX+DI] = nov† pozice

outkey:  push      ax                       
         mov       al,cs:[si]               ; dÇlka jednÇ poloëky v tabulce
         mul       dl                       ; rel. adresa poloëky v tabulce
         add       si,ax                    ; adresa poloëky v tabulce
         inc       si                       
         mov       cl,cs:[si]               ; dÇlka textu v poloëce
         jcxz      outkey2                  
outkey1: inc       si                       ; znak poloëky textu kl†vesy
         inc       bx                       ; ukazatel vòstupn°ho textu
         mov       al,cs:[si]               ; p©eáten° znaku poloëky
         mov       [bx+di],al               ; uloëen° do bufferu
         loop      outkey1                  ; dal®° znak
         inc       bx                       ; n†sleduj°c° pozice
         mov       byte ptr [bx+di]," "     ; oddàlovac° mezera
outkey2: pop       ax                       
         ret                                

adrtab   dw        offset tabkey            ; ukazatel dek¢dovac° tabulky kl†ves


                                            ; FUNKCE 11 - vòpis k¢du kl†vesy

                                            ; vstup:  DS:[BX+DI] = vòst. buffer
                                            ;         AX = k¢d kl†vesy
                                            ; vòstup: DS:[BX+DI] = nov† adresa

fnc11:   mov       dx,ax                    ; k¢d kl†vesy
         xor       cx,cx                    ; á°taá znakñ
         mov       bx,[adrtab]              ; ukazatel dek¢dovac° tabulky kl†ves
         inc       bx                       ; dal®° kl†vesa
fnc111:  mov       al,[bx]                  ; k¢d kl†vesy
         or        al,al                    ; je ukonáovac° znak 00 ?
         jnz       fnc112                   ; nen° je®tà konec
         mov       [adrtab],offset tabkey   ; nastav. zaá. dek¢d. tabulky kl†ves
         mov       es,dx
         mov       es:[di],ch               ;
         ret       
fnc112:  push      si                       ; ukazatel tabulky kl†ves
fnc113:  mov       ah,es:[si]               ; k¢d kl†vesy
         or        ah,ah
         jz        fnc114                   ; je jië posledn°
         cmp       al,ah                    ; porovn†n° s hledanou kl†vesou
         jz        fnc115                   ; je nalezen k¢d kl†vesy
         inc       si                       ; dal®° kl†vesa
         mov       cl,es:[si]               ;
         inc       cx
         add       si,cx                    ; adresa n†sleduj°c°ho textu
         jmp       short fnc113             ; novò pokus
fnc114:  pop       si
         inc       bx
         inc       bx
         jmp       short fnc111
fnc115:  inc       bx
         mov       [adrtab],bx              ; nov† adresa ukazatele tabulky
         mov       al,[bx-2]                ; k¢d kl†vesy
         inc       si
         pop       bx
         push      si
         push      dx
         pop       ds
         xor       bx,bx
         mov       dl,al
         and       dl,0c0h
         rol       dl,1
         rol       dl,1
         mov       si,offset tabshf         ; tabulka kl†ves SHIFT,CTRL,ALT
         call      outkey                   ; vòpis k¢du kl†vesy
         mov       dl,al
         and       dl,3fh
         cmp       dl,1ah
         ja        fnc116
         add       dl,40h
         inc       bx
         mov       [bx+di],dl
         jmp       short fnc119
fnc116:  cmp       dl,24h
         ja        fnc117
         sub       dl,1bh
         mov       si,offset tabfn          ; tabulka funkán°ch kl†ves
         call      outkey                   ; vòpis k¢du kl†vesy
         jmp       short fnc119
fnc117:  cmp       dl,2bh                   ; znak "+"
         ja        fnc118
         sub       dl,25h
         mov       si,offset tabhome        ; tabulka ©°d°c°ch kl†ves
         call      outkey                   ; vòpis k¢du kl†vesy
         jmp       short fnc119
fnc118:  inc       bx
         mov       [bx+di],dl
fnc119:  cmp       bx,9
         ja        fnc11a
         inc       bx
         mov       byte ptr [bx+di]," "     ; oddàlovac° znak mezery
         jmp       short fnc119
fnc11a:  inc       bx
         mov       byte ptr [bx+di],"|"     ; znak "|"
         pop       si
         mov       cl,es:[si]
fnc11b:  inc       si
         mov       al,es:[si]               ; p©eáten° znaku k vyti®tàn°
         inc       bx
         cmp       al," "
         jnc       fnc11c                   ; nen° ©°d°c° znak
         mov       byte ptr [bx+di],"^"     ; uloëen° znaku "^" (znak s CTRL-)
         inc       bx                       ; zvò®en° ukazatele
         or        al,40h                   ; p©evod znaku na tisknutelnò znak
fnc11c:  mov       [bx+di],al               ; uloëen° znaku
         loop      fnc11b                   ; p©evod dal®°ho znaku
         inc       bx
         mov       byte ptr [bx+di],"|"     ; znak "|"
         mov       [di],bl
         ret       

tab01    db        1,27
         db        1,'P',18,17,'$$',15
         db        ' Povely s CTRL- ',31
         db        2,'$Kurzor...$ '
         db        4,'$Obrazovka...$'
         db        5,'$Zvl†®tn°...$',31
         db        ' S vlevo',2,'(',0fbh,')'
         db        4,'C str†nka dolñ'
         db        5,'B  form†tuj',31
         db        ' X dolñ',3,'(',0f9h,')'
         db        6,'(PgDn)',13,'odstavec',31
         db        ' D vpravo (',0fah,')'
         db        4,'R str†nka nahoru'
         db        3,'L pokraáuj',31
         db        ' E nahoru (',0f8h,')'
         db        6,'(PgUp)',13,'v hled†n°',31
         db        ' A slovo vlevo'
         db        3,'Z ©†dek dolñ'
         db        7,'M konec odstavce',31
         db        ' F slovo vpravo'
         db        2,'W ©†dek nahoru'
         db        7,'<Enter>',31
         db        ' I na dal®°'
         db        25,'N vloëen°',31
         db        3,'tabel†tor'
         db        6,'$Podmenu...$'
         db        8,'©†dku',31
         db        17,'J info/displej'
         db        5,'V vkl†d†n°',31
         db        2,'$Maz†n°...$'
         db        4,'K blok/soubor'
         db        8,'zap/vyp',31
         db        ' G znaku nad'
         db        5,'O form†tov†n°/'
         db        7,'<Insert>',31
         db        3,'kurzorem'
         db        8,'nastavov†n°'
         db        6,'\ roz®°©. znaky',31
         db        ' H znaku vlevo'
         db        3,'P typy p°sma'
         db        7,'- z†màna dvou',31
         db        ' T slova vpravo'
         db        2,'Q p©esuny kurzoru/'
         db        4,'znakñ',31
         db        ' Y ©†dku'
         db        11,'hled†n°/z†màna'
         db        3,'],6 text.buffer'
         db        0

tab02    db        0,58
         db        1,'P',16,11,' CTRL J ',31
         db        ' B',2,'©†dky displeje',31
         db        ' C',2,'barvy displeje',31
         db        ' F',2,'blik†n° zap/vyp',31
         db        ' H',2,'pomoc zap/vyp',31
         db        ' -------------------',31
         db        ' G',2,'graf.editor ',31
         db        ' I',2,'pracovn° prostor',31
         db        ' D',2,'z†pis data  ',31
         db        ' T',2,'z†pis áasu',31
         db        ' K',2,'kalend†©/hodiny',31
         db        ' -------------------',31
         db        ' R',2,'vòpoáty v textu',31
         db        ' S',2,'sloupc. souáty',31
         db        ' M',2,'prñmàr      '
         db        0

tab03    db        0,35
         db        1,'P',14,14,'$$'
         db        17,' CTRL K ',31
         db        17,'$Blok....$',31
         db        ' B',2,'oznaáen° zaá†tku'
         db        6,'C',2,'kop°rov†n° ',31
         db        ' K',2,'oznaáen° konce'
         db        8,'V',2,'p©esunut°',31
         db        ' N',2,'sloupcovò blok'
         db        8,'Y',2,'maz†n°',31
         db        ' H',2,'zobrazen° zap/vyp'
         db        5,'R',2,'áten°',31
         db        ' T',2,'zmàna p°sma'
         db        11,'W',2,'uloëen°',31
         db        ' G',2,'p©enos z'
         db        ' jinÇho prac.prostoru',31
         db        ' ------------------------------------------',31
         db        ' D',2,'menu soub.'
         db        12,'E',2,'maz†n° textu',31
         db        ' P',2,'menu tisku'
         db        12,'L',2,'áten° textu',31
         db        '1-5 zmàna prac.prostoru'
         db        3,'S',2,'uloëen° textu',31
         db        ' Q',2,'ukonáen° KonTextu'
         db        5,'X',2,'start programu'
         db        0

tab04    db        0,23
         db        1,'P',15,24,'$$'
         db        20,' CTRL O ',31
         db        3,'$P©ep°naáe zap/vyp'
         db        8,'Form†tov†n°$',31
         db        ' J',2,'zarovn†v†n°'
         db        11,'B',2,'po konec textu',31
         db        ' H',2,'dàlen° slov'
         db        11,'C',2,'centrov†n° ©†dku',31
         db        ' Q',2,'dàlen° s dotazem'
         db        6,'Z',2,'dvousloupcovÇ form†t.',31
         db        ' V',2,'autom.tabel†tor',31
         db        ' M',2,'<Enter>=kon.odst.'
         db        9,'$Nastav.str†nky$',31
         db        ' P',2,'zobrazen° str†nky'
         db        5,'I',2,'menu line†lu ©†dku',31
         db        ' T',2,'zobrazen° line†lu'
         db        5,'F',2,'pravò okraj->konec ©†dku',31
         db        ' N',2,'nedokumentn° m¢d'
         db        6,'L',2,'levò okraj ->pozice kurzoru',31
         db        26,'R',2,'pravò okraj->pozice kurzoru',31
         db        26,'S',2,'poáet ©†dkñ na str†nku',31
         db        ' A',2,'zaá†tek odstavce',2,0f0h
         db        3,'E',2,'zobrazen° z†hlav°/paty',31
         db        ' U',2,'neform†tovat',6,0ffh
         db        3,'O',2,'blok jako z†hlav°/pata'
         db        0

tab05    db        0,59
         db        1,'P',9,10,' CTRL P ',31
         db        ' N=norm†ln°',31
         db        ' F=zvòraznànÇ',31
         db        ' U=podtrëenÇ',31
         db        ' K=kurz°va',31
         db        ' B=®irokÇ',31
         db        ' H=nadsazenÇ',31
         db        ' T=podsazenÇ'
         db        0,0,0,0,0,0,0,0

tab06    db        0,39
         db        1,'P',13,30,' CTRL Q ',31
         db        ' A',2,'hled†n°/z†màna'
         db        4,'F',2,'hled†n°',31
         db        ' M',2,'nastav.znaáky'
         db        5,'T',2,'makrokl†vesy',31
         db        ' L',2,'navr†cen° posledn°ch zmàn   ',31
         db        10,'$Pozice kurzoru...$',31
         db        ' S',2,'zaá†tek ©†dku'
         db        6,'D',2,'konec ©†dku',31
         db        ' E',2,'horn° okraj'
         db        8,'X',2,'doln° okraj',31
         db        ' R',2,'zaá†t.textu'
         db        8,'C',2,'konec textu',31
         db        ' B',2,'zaá†t.bloku'
         db        8,'K',2,'konec bloku',31
         db        ' P',2,'znaáka'
         db        13,'Z',2,'pozice',31
         db        14,'$Maz†n°...$',31
         db        ' H',2,'po zaá†tek ©†dku'
         db        3,'Y',2,'po konec ©†dku'
         db        0,0

tab07    db        1,52
         db        1,'P',10,16,' CTRL JC ',31,31
         db        2,'--- Nastaven° barev ---',31
         db        ' Zadejte á°slo barvy nebo',31
         db        ' zvolte <Enter>=beze zmàny',31,31
         db        ' Barva p°sma (0..15):',31
         db        ' Barva okol° (0..15):'
         db        0

tab08    db        1,54
         db        1,'P',13,13,' CTRL JI ',31,31
         db        ' - Pracovn° prostor : - ',31
         db        '$obsah             ©†dkñ$',31
         db        31,31,31,31,31,31
         db        ' text :'
         db        7,'bajtñ vol.',31
         db        ' makra:'
         db        7,'bajtñ vol.'
         db        0

tab09    db        1,49
         db        1,'P',16,19,' CTRL JK ',31
         db        31,31,31
         db        2,'PO',2,'óT',2,'ST',2,'ÄT',2,'Pè',2,'SO',2,'NE',31
         db        ' ============================',31
         db        31,31,31,31,31,31
         db        ' ============================',31
         db        1,0fbh,2,'p©edch.'
         db        2,0fah,' n†sled.  màs°c',31
         db        1,0f9h,2,'p©edch.',2,0f8h,' n†sled.  rok '
         db        0

tab10    db        1,61
         db        1,'P',17,8,' CTRL KD ',31
         db        ' áti text  ',31
         db        ' uloë text     ',31
         db        ' áti blok   ',31
         db        ' uloë blok      ',31
         db        ' zru® soubor  ',31
         db        ' p©ejmenuj soubor',31
         db        ' kop°ruj soubor',31
         db        ' start programu ',31
         db        ' uloë nastaven°',31
         db        ' konec KonTextu ',31
         db        ' ----------------',31
         db        ' form†t KonText',31
         db        ' form†t Layout',31
         db        ' form†t ASCII',31
         db        ' z†loha BAK '
         db        0

tab11    db        0,52
         db        1,'P',3,'a'
         db        0

tab12    db        1,52
         db        1,'P',11,31
         db        4,'-- tisk textu   --',31
         db        2,'  Zadejte á°sla nebo     ',31
         db        '   <Enter> = ë†dn† zmàna ',31,31
         db        ' prvn° str†nka:  ',5,'1',31
         db        ' koneán† str†nka:',31
         db        ' prvn° á°slo strany:',2,'1',31
         db        ' exempl†©ñ:',11,'1'
         db        0

tab13    db        1,55
         db        1,'P',7,13,' CTRL KP ',31,31
         db        ' - prob°h† tisk textu -',31,31
         db        9,'d†le',31
         db        9,'p©eru®en°'
         db        0

tab14    db        1,25
         db        6,'6',14,16,' CTRL KQ ',31,31
         db        3,'T°mto povelem ukoná°te',31
         db        ' KonText a navr†t°te se zpàt',31
         db        2,'do operaán°ho systÇmu !!!',31,31
         db        2,'Stisknàte <Enter> = konec',31
         db        3,'nebo <Esc> = pokraáuj'
         ; db        0

tab15    db        0,58
         db        1,'P',7,10,' CTRL OE ',31
         db        '  ',31
         db        'Jako blok se zobraz°:',31,31
         db        4,'K = z†hlav°',31
         db        4,'F = pata '
         db        0

tab16    db        0,53
         db        1,'P',15,14,' CTRL OI ',31
         db        2,'-- Tabel†tory/okraje --',31,31
         db        2,0fah,3,'kurzor vpravo',31
         db        2,0fbh,3,'kurzor vlevo',31
         db        ' End',2,'...k pravÇmu okraji',31
         db        ' Home ...k levÇmu okraji',31
         db        2,'L',3,'levò okraj',31
         db        2,'R',3,'pravò okraj',31
         db        ' Tab',2,'nastav/zru® tabel.',31
         db        2,'#',3,'dekadickò tabel†tor',31
         db        ' Del',2,'ru®en°/n†vrat tabel.',31
         db        ' Ret',2,'ukonáen° volby',31
         db        ' Esc',2,'p©eru®en° volby'
         db        0,0,0,0,0

tab17    db        0,58
         db        1,'P',7,10,' CTRL OO ',31,31
         db        ' Blok se uloë° jako: ',31,31
         db        4,'K = z†hlav° ',31
         db        4,'F = pata   '
         db        0

tab18    db        1,46
         db        1,'P',11,22,' CTRL OS ',31,31
         db        '   Zadejte novÇ nastaven° nebo  ',31
         db        2,'stisknàte <Enter>=beze zmàny: ',31,31
         db        ' ©†dkñ na str†nku (4..99):',31
         db        ' z toho: z†hlav°  (0..10):',31
         db        7,'  pata   ',2,'(0..10):',31,31
         db        ' rozteá ©†dkñ :',9,'cm'
         db        0

tab19    db        1,25
         db        4,'6',14,17,' CTRL OZ ',31,31
         db        3,'Tento povel zform†tuje',31
         db        4,'text na tÇto stranà',31
         db        4,'dvousloupcovà. NovÇ',31
         db        3,'form†tov†n° jië nad†le',31
         db        7,'nebude moënÇ !',31
         db        10,'Zvolte: ',31
         db        5,'<Enter> = potvrzen° ',31
         db        2,'<Esc> = p©eru®en° povelu'
         db        0,0,0,0,0,0,0

tab20    db        0,58
         db        1,'P',9,10,' VOLBY ',31
         db        ' B',2,'zpàtnò smàr     ',31
         db        ' G',2,'v celÇm textu   ',31
         db        ' L',2,'v celÇm bloku   ',31
         db        ' W',2,'pouze celÇ slovo',31
         db        ' U',2,'nerozli®uje velk†',31
         db        4,'a mal† p°smena'
         db        0,0,0

tab21    db        1,27
         db        7,'6',13,31
         db        2,' Text v prac.prost.',31
         db        2,'nebude uloëen na disk !',31,31
         db        3,'<Enter>=pokraáov†n°',31
         db        5,'<Esc>=p©eru®en°'
         db        0

tab22    db        1,34
         db        1,'P',15,28,' Zvl†®tn° znaky'
         db        0

tab23    db        1,25
         db        4,'6',13,19,' SETUP ',31,31
         db        ' Tato volba zpñsob°, ëe p©i',31
         db        '  dal®°m spu®tàn° KonTextu',31
         db        2,'bude opàt pouëito stejnÇ',31
         db        3,'nastaven° parametrñ.',31,31
         db        3,'Zvolte <Enter>=uloëen°',31
         db        4,'nebo <Esc>=p©eru®en°.'
         db        0

tab24    db        0,50
         db        1,'P',8,18,' CTRL KN ',31,31
         db        3,'Nastaven° sloupc.bloku:',31,31
         db        ' B',2,'zaá†tek (levò horn° roh)',31
         db        ' K',2,'konec (pravò doln° roh) '
         db        0

tab25    db        1,50
         db        1,'P',10,31
         db        5,'--- SÇriovò tisk --',31
         db        ' Pros°m, zadejte novou volbu',31
         db        ' nebo <Enter> = beze zmàny:',31,31
         db        ' Dat. prostor',4,'(1..5):',31
         db        ' P©eform†tov†n° ',2,'(J/N):',31
         db        0

tab26    db        1,30
         db        7,'3',13,31
         db        ' SÇriovò tisk-pauza',31
         db        ' pro',2,'vòmànu pap°ru',31,31
         db        ' pokraá. = <Enter>,',31
         db        2,'p©eru®. = <ESC>'
         db        0

tab27    db        1,1
         db        1,21,12,31
         db        ' zaá†tek textu',31
         db        ' konec textu',31
         db        ' zaá†tek bloku',31
         db        ' konec bloku',31
         db        ' na znaáku',31
         db        ' nastaven° znaáky',31
         db        ' na danou pozici',31
         db        ' vyhled†n° textu',31
         db        ' hled†n°/z†màna',31
         db        ' pokraá.hled./z†m.'
         db        0

tab28    db        1,3
         db        1,21,9,31
         db        ' slova vpravo',31
         db        ' po kurzor',31
         db        ' od kurzoru',31
         db        ' maz†n° ©†dku ',31
         db        ' maz†n° bloku ',31
         db        ' obnoven° zmàn',31
         db        ' celÇho textu   '
         db        0

tab29    db        1,12
         db        1,29,14,31
         db        ' zaá†tek bloku',31
         db        ' konec bloku  ',31
         db        ' sloupc.blok ',0dah,0c4h,' ',31
         db        ' sloupc.blok',2,0c4h,0d9h,31
         db        ' maz†n°',31
         db        ' p©em°stàn°',31
         db        ' kop°rov†n°',31
         db        ' p©enos',31
         db        ' áten°',31
         db        ' uloëen°',31
         db        ' zmàna p°sma',31
         db        ' oznaáen°'
         db        0

tab30    db        1,19
         db        1,'%',9,31
         db        ' norm†ln°',31
         db        ' zvòraznànÇ',31
         db        ' podtrëenÇ',31
         db        ' kurz°va',31
         db        ' ®irokÇ',31
         db        ' nadsazenÇ',31
         db        ' podsazenÇ'
         db        0

tab31    db        1,26
         db        1,'.',14,31
         db        ' po konec odst.',31
         db        ' po konec textu',31
         db        ' dvousloupcovà',31
         db        ' centruj ©†dek',31
         db        ' zarovn†v†n°',31
         db        ' rozdàlov†n°',31
         db        ' s dotazem',31
         db        ' auto-tabel†tor',31
         db        ' <Enter>=odstavec',31
         db        ' zaá.odstavce',4,0f0h,31
         db        ' konec odstavce',2,0f1h,31
         db        ' neform†tovat',4,0ffh
         db        0

tab32    db        1,32
         db        1,38h,14,31
         db        ' ©†dkñ na str†nku',31
         db        ' menu line†lu ©†dkñ',31
         db        ' levò okrajÆkurzor',31
         db        ' pravò okrajÆkurzor',31
         db        ' pravò okrajÆkonec ©†d.',31
         db        ' zobrazen° z†hlav°',31
         db        ' zobrazen° paty',31
         db        ' blok jako z†hlav°',31
         db        ' blok jako pata',31
         db        ' zobraz.str†nkov†n°',31
         db        ' zobr.line†lu ©†dku',31
         db        ' nedokumentn° m¢d '
         db        0

tab33    db        1,43
         db        1,'=',8,31
         db        ' 2 barvy',31
         db        ' 8/16 barev',31
         db        ' 16 barev',31
         db        ' zmàna barev  ',31
         db        ' n†povàda',31
         db        ' blik†n° kurz.'
         db        0

tab34    db        1,51
         db        1,'E',14,31
         db        ' prac. prostor',31
         db        ' text do bufferu',31
         db        ' text z bufferu',31
         db        ' z†pis áasu',31
         db        ' z†pis data  ',31
         db        ' kalend†©',31
         db        ' grafickò editor',31
         db        ' zvl†®tn° znaky',31
         db        ' makrokl†vesy',31
         db        ' kalkul†tor',31
         db        ' sloupc. souáet',31
         db        ' prñmàr    '
         db        0

tab35    db        1,59
         db        1,77,15,6,' CTRL KP ',31
         db        ' tisk textu',31
         db        ' sÇriovò tisk',31
         db        ' áten° instalace',31
         db        ' zmàna instalace',31
         db        ' ---------------',31
         db        ' vy®®° kvalita',31
         db        ' p°smo Elite ',31
         db        ' £zkÇ p°smo ',31
         db        ' proporcion†ln°',31
         db        ' dvoj. p©etisk',31
         db        ' hustÇ ©†dkov.',31
         db        ' samostat.list',31
         db        ' vòmàna pap°ru'
         db        0


tabhlp   dw        offset tab01
         dw        offset tab02
         dw        offset tab03
         dw        offset tab04
         dw        offset tab05
         dw        offset tab06
         dw        offset tab07
         dw        offset tab08
         dw        offset tab09
         dw        offset tab10
         dw        offset tab11
         dw        offset tab12
         dw        offset tab13
         dw        offset tab14
         dw        offset tab15
         dw        offset tab16
         dw        offset tab17
         dw        offset tab18
         dw        offset tab19
         dw        offset tab20
         dw        offset tab21
         dw        offset tab22
         dw        offset tab23
         dw        offset tab24
         dw        offset tab25
         dw        offset tab26
         dw        offset tab27
         dw        offset tab28
         dw        offset tab29
         dw        offset tab30
         dw        offset tab31
         dw        offset tab32
         dw        offset tab33
         dw        offset tab34
         dw        offset tab35

                                            ; funkce 07 - adresa n†povàdy ES:SI
fnc07:   mov       bx,[bp+4]
         shl       bx,1
         mov       si,[bx+tabhlp]
         push      ds
         pop       es
         ret

taberr   db        1,'Soubor nebyl nalezen',0
         db        2,'Äten° souboru nen° moënÇ.....',0
         db        3,'Z†pis souboru nen° moënò.........',0
         db        4,'Poëadovanò adres†© nenalezen..',0
         db        5,'Nedostatek m°sta v pamàti',0
         db        6,' P©ekroáen maxim†ln° poáet ©†dkñ ',0
         db        7,34,'  nebyl nalezen ',0
         db        8,' û†dek je moc dlouhò ',0
         db        9,' NepovolenÇ zad†n° ',0
         db        10,'  Nen° oznaáen ë†dnò blok ',0
         db        11,' Pamàü makrokl†ves je pln†',0
         db        12,'    Tisk†rna nen° v provozu ',0
         db        13,'   Chybnò form†t dat',0
         db        15,'Soubor s t°mto jmÇnem jië existuje v prac.pr.',0
         db        16,'Zdrojovò a c°lovò s. jsou identickÇ',0
         db        17,'Prostor @ nen° dosud vytistàn.',0
         db        18,' Sloupcovò blok nemñëe bòt zaps†n do jednoho'
         db           ' souboru ',0
         db        19,'Nen° oznaáen ë†dnò sloupcovò blok',0
         db        20,'   Kurzor se mus° nach†zet vpravo od pravÇho'
         db           ' okraje ',0
         db        21,' Nen° soubor EXE ani COM ',0
         db        50,'Nepovolenò mat.vòraz ',0
         db        51,'P©eteá. des. teáky',0
         db        52,'Dàlen° nulou       ',0
         db        53,'Chybnò argum. ',0
         db        54,'Chyba argumen.',0
         db        99,'Intern° chyba  ',0
         db        100,'Disketov† mechanika nepracuje',0
         db        153,'Neoáek†vanò konec soub',0
         db        196,'P©eteá. Integer',0
         db        240,' Disketa je p©eplnàna',0
         db        241,'NepovolenÇ jmÇno soub.',0
         db        0,'Nezn†m† chyba      ',0

                                            ; FUNKCE 08 - adresa chybovòch hl†®en°

fnc08:   mov       si,offset taberr         ; tabulka hl†®en°
         push      ds                       ; nastaven° ES = DS
         pop       es
         ret

code     ENDS

         end       start

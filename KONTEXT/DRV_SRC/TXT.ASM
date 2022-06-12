

; ****************************************************************************
;              Textovò driver displeje pro program kontext.com
;              po p©ekladu od adresy 0 m† soubor jmÇno txt.ovl
; ****************************************************************************

code     SEGMENT   page
         ASSUME    cs:code,ds:code

         ORG       0

start:                                      ; vstup do driveru

displej  proc      far
                                            ; vyvol†n° podprogramu,
                                            ;  jehoë á°slo je v BX
         push      ds
         mov       dx,cs
         mov       ds,dx                    ; datovò segment = program. segment
         shl       bx,1
         call      word ptr ds:[bx+adrsub]  ; vyvol†n° podprogramu podle tabulky
         pop       ds
         ret
displej  endp


tabtxt   db        0
         db        3                        ; poáet fontñ
         db        6
         dw        konectxt
         db        8
         dw        konectxt
         db        14
         dw        konectxt

karta    db        'TXT'

invmsk   db        0                        ; maska znakñ (pro inverzi)
whide    db        0                        ; p©°znak dvojn†sobnÇho znaku
mode     db        0                        ; reëim obrazovky (1,2,3)
vyska    db        0                        ; poáet linek na ©†dek

; -----------------------------------------------------------------------------
;                         Parametry displeje
; -----------------------------------------------------------------------------
public   VideoCard,CheckSnow,AktVmod,TextVMOD,Monochr,AktPage,AdrVRAM,MaxRow
public   MaxCol,PortCRT

VideoCard db       ?                        ; typ videokarty
                                            ;     0=nezn†mò typ
                                            ;     1=CGA
                                            ;     2=Mono CGA
                                            ;     3=EGA
                                            ;     4=EGA 64kB
                                            ;     5=EGA Mono
                                            ;    (6=IBM8514)
                                            ;     7=Hercules
                                            ;    (8=ATT400)
                                            ;     9=VGA
                                            ;   (10=PC3270)
CheckSnow db       ?                        ; p©°znak, ëe se kontroluje snàëen°
AktVmod  db        ?                        ; aktu†ln° videom¢d
TextVMOD db        ?                        ; p©°znak textovÇho videom¢du
Monochr  db        ?                        ; p©°znak monochromatickÇho displeje
AktPage  db        ?                        ; aktu†ln° videostr†nka
AdrVRAM  dd        ?                        ; adresa videostr†nky displeje
MaxCol   db        ?                        ; maxim†ln° pozice na ©†dku
Pozic    dw        ?                        ; poáet pozic na ©†dek
MaxRow   db        ?                        ; maxim†ln° ©†dek na displeji
PortCRT  dw        ?                        ; b†zov† adresa portu ©adiáe CRT



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
                                            ;   40 = rozdàlovac° znamÇnko
                                            ;   80 = dvojn†sobn† ®°©ka znaku

fnc00:
         cld
         mov       ch,ah                    ; m¢d znaku
         mov       ax,[bp+4]                ; ©†dek znaku
         mov       bx,ds:[Pozic]            ; poáet pozic na ©†dek
         mul       bx                       ; offset zaá†tku ©†dku
         mov       bx,[bp+6]                ; pozice znaku na ©†dku
         dec       bx
         cmp       bx,0
         jl        fnc009                   ; je z†porn† pozice
         cmp       bx,ds:[Pozic]
         jnc       fnc009                   ; je velk† pozice
         add       ax,bx                    ; poáet znakñ od zaá†tku obrazovky
         add       ax,ax                    ; offset znaku ve VRAM
         mov       di,ax
         add       di,word ptr ds:[AdrVRAM] ; offset poá†tku str†nky
         push      es
         mov       es,word ptr ds:[AdrVRAM+2] ; segment VRAM
         mov       ax,[bp+8]                ; znak k vòstupu
         cmp       al,255                   ; je znak dvojn†sobnÇ ®°©ky ?
         jnz       fnc003                   ; nen°
         mov       al,22                    ; znak silnÇho podtrhov†tka
fnc003:  stosb                              ; uloëen° znaku k vòstupu
         mov       al,ds:[invert]           ; inverzn° p°smo
         test      ch,20h                   ; inverzn° p°smo ?
         jnz       fnc001                   ; je inverzn° p°smo
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
         jnz       fnc001                   ; jsou nàjakÇ atributy
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
         add       di,word ptr ds:[AdrVRAM]
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
         cmp       cx,ds:[Pozic]
         jng       fnc010r
         mov       cx,ds:[Pozic]
fnc010r: dec       ax                       ; poá†teán° pozice
         sub       cx,ax                    ; ®°©ka okna (pozic)
         jng       fnc011                   ; ®°©ka okna nen° kladn†
         add       di,ax                    ; offset zaá†tku okna
         add       di,di                    ; adresa zaá†tku okna ve VRAM
fnc0103: push      es
         mov       es,word ptr ds:[AdrVRAM+2]; segment VRAM
         cmp       byte ptr [bp+4],1        ; parametr
         ja        fnc0107                  ; je kurzor
         mov       ah,ds:[normal]           ; je norm†ln° text
         jc        fnc010a                  ; je inverzn° text
         mov       ah,ds:[invert]           ; inverzn° text
fnc010a: mov       al,32
fnc0104: push      di
         push      cx
         cld
         rep       stosw
         pop       cx
         pop       di
         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
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
         call      TestEga
         jnc       fnc0106
         cmp       byte ptr ds:[Monochr],0
         je        fnc01e1
         not       al
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1
fnc01e1: and       al,7fh
fnc0106: stosb
         dec       cx
         jnz       fnc0102
         pop       cx
         pop       di
         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
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
         mov       cx,ds:[Pozic]
         add       cx,cx
         mul       cx                       ; poá†teán° adresa poá†t. ©†dku
         mov       si,ax                    ; poá†teán° adresa poá†t. ©†dku
         mov       di,ax                    ; adresa n†sleduj°c°ho ©†dku
         add       si,ds:[Pozic]
         add       si,ds:[Pozic]
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
         add       si,word ptr ds:[AdrVRAM]
         add       di,word ptr ds:[AdrVRAM]
         mov       ax,word ptr ds:[AdrVRAM+2] ; segment displeje
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
         add       di,cs:[Pozic]
         add       di,cs:[Pozic]
         add       si,cs:[Pozic]
         add       si,cs:[Pozic]
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
         mov       cx,ds:[Pozic]
         add       cx,cx
         mul       cx                       ; poá†teán° adresa koneánÇho ©†dku
         mov       si,ax                    ; poá†teán° adresa koneánÇho ©†dku
         mov       di,ax                    ; adresa n†sleduj°c°ho ©†dku
         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
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
         add       si,word ptr ds:[AdrVRAM]
         add       di,word ptr ds:[AdrVRAM]
         mov       ax,word ptr ds:[AdrVRAM+2] ; segment displeje
         mov       es,ax
         mov       ds,ax
         cld                                ; p©enos nahoru
fnc032:
         sub       di,cs:[Pozic]
         sub       di,cs:[Pozic]
         sub       si,cs:[Pozic]
         sub       si,cs:[Pozic]
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
         cmp       si,ds:[Pozic]
         jae       fnc042
         mov       ax,[bp+6]                ; koneánò ©†dek
         mov       di,[bp+8]                ; poá†teán° ©†dek
         sub       ax,di
         inc       ax                       ; poáet ©†dkñ
         mov       cx,ax                    ; poáet ©†dkñ
         mov       ax,ds:[Pozic]
         mul       di
         mov       di,ax
         add       di,si
         add       di,di
         push      es
         mov       ax,word ptr ds:[AdrVRAM+2]
         mov       es,ax
         add       di,word ptr ds:[AdrVRAM]
         mov       dl,ds:[cara]             ; barva okraje
         mov       dh,ds:[normal]           ; barva norm†ln°ho textu
fnc041:  mov       al,es:[di+1]
         cmp       al,dl
         mov       al,dl
         jnz       fnc043
         mov       al,dh
fnc043:  mov       es:[di+1],al
         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
         loop      fnc041
         pop       es
fnc042:  ret


                                            ; FUNKCE 05 - inicializace parametrñ

                                            ; SS:BP = ukazatel parametrñ znaku
                                            ;   +4 = barva podkladu
                                            ;   +6 = barva p°sma
                                            ;   +8 = reëim obrazovky (©†dkov†n°)

fnc05:
         cmp       byte ptr ds:[VideoCard],0 ; je karta jië rozpozn†na ?
         jnz       fnc0501                  ; karta je jië rozpozn†na
         call      DetectCard               ; detekce videokarty
fnc0501:
         call      SetTextVMode             ; nastaven° textovÇho videom¢du

         mov       al,[bp+8]
         mov       [mode],al                ; poëadovanò m¢d
         cld
                                          ;* nastaven° norm†ln° barvy textu
         mov       ax,[bp+4]                ; barva podkladu
         mov       bx,[bp+6]                ; barva p°sma
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1                     ; p©°prava barvy podkladu
         and       bl,0fh                   ; barva p°sma
         or        al,bl                    ; zadan† barva textu
         mov       bl,al
         push      ax
         call      TestEga                  ; je karta EGA ?
         jnc       fnc0502                  ; je karta EGA
         and       al,7fh                   ; zru®en° p©°znaku blik†n°
fnc0502: mov       [normal],al              ; nastaven° barvy norm†ln°ho textu
         pop       ax
                                          ;* nastaven° invertovanÇ barvy
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1
         call      TestEga                  ; je karta EGA ?
         jnc       fnc0503                  ; je karta EGA
         and       al,7fh                   ; zru®en° p©°znaku blik†n°
fnc0503: mov       [invert],al

                                          ;* nastaven° ostatn°ch barev
         mov       [zvyraz],al
         mov       [sikme],al
         mov       [podtrz],al
         mov       [jine],al
         cmp       byte ptr ds:[Monochr],0  ; je monochromatickò displej ?
         jne       fnc051                   ; je monochromatickò displej
         and       bl,0f0h
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

                                          ;* nastaven° barvy á†ry
fnc051:  mov       al,ds:[normal]
         xor       al,77h                   ; negace barvy
         mov       [cara],al                ; barva á†ry okraje
                                          ;* nastaven° videom¢du
         call      TestEga                  ; je karta EGA ?
         jc        fnc05a                   ; nen° karta EGA

                                          ;* nastaven° m¢du EGA/VGA
fnc052:  mov       ax,1111h
         cmp       byte ptr ds:[mode],2
         je        fnc058
         mov       al,12h
         cmp       byte ptr ds:[mode],3
         jne       fnc059
fnc058:  xor       bx,bx
         int       10h                      ; nastaven° hust®°ho ©†dkov†n°
fnc059:  mov       ax,1003h
         mov       bl,0                     ; p©°znak - intezivn° podklad
         int       10h                      ; nastaven° atributu s jasem
         mov       bh,[bp+4]                ; barva podkladu
         mov       ax,1001h
         int       10h                      ; nastaven° okol° obrazovky

fnc05a:                                   ;* nastaven° parametrñ displeje
         call      AktParDisp               ; aktualizace parametrñ displeje
         call      KurzOff                  ; vypnut° zobrazen° kurzoru
         xor       cx,cx
         mov       cl,ds:[MaxRow]           ; maxim†ln° ©†dek na displeji
         xor       ax,ax
         mov       al,ds:[MaxCol]           ; posledn° znak na ©†dku
         inc       ax                       ; poáet znakñ na ©†dek
         mov       ds:[Pozic],ax
         mov       si,offset karta          ; identifikaán° text karty
         mov       bx,1                     ; poáet linek na ©†dek
         ret


                                            ; FUNKCE 06 - nastaven° tex. m¢du
fnc06:   jmp       SetTextVMode             ; nastaven° textovÇho m¢du

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

tab01:                                      ; povely s CTRL-
         db        1
         db        27
         db        1
         db        80
         db        18
         db        17,'$$',15
         db        ' Povely s CTRL- ',31
         db        2,'$Kurzor...$ '
         db        4,'$Obrazovka...$'
         db        5,'$Zvl†®tn°...$',31
         db        ' S vlevo',2,'(',0fbh,')'
         db        4,'C str†nka dolñ'
         db        5,'B form†tuj',31
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
         db        6,'\ zvl†®tn° znaky',31
         db        ' H znaku vlevo'
         db        3,'P typy p°sma'
         db        7,'- z†màna znakñ',31
         db        ' T slova vpravo'
         db        2,'Q p©esuny kurzoru/'
         db        1,'] text do buff.',31
         db        ' Y ©†dku'
         db        11,'hled†n°/z†màna'
         db        3,'^ text z buff.'
         db        0

tab02:                                      ; ^J
         db        0
         db        58
         db        1
         db        80
         db        16
         db        11,' CTRL J ',31
         db        ' B',2,'©†dky displeje',31
         db        ' C',2,'barvy displeje',31
         db        ' F',2,'blik†n° zap/vyp',31
         db        ' H',2,'pomoc zap/vyp',31
         db        ' -------------------',31
         db        ' G',2,'graf.editor',31
         db        ' I',2,'pracovn° prostor',31
         db        ' D',2,'z†pis data',31
         db        ' T',2,'z†pis áasu',31
         db        ' K',2,'kalend†©/hodiny',31
         db        ' -------------------',31
         db        ' R',2,'vòpoáty v textu',31
         db        ' S',2,'sloupcovÇ souáty',31
         db        ' M',2,'sloupcovò prñmàr'
         db        0

tab03:                                      ; ^K
         db        0
         db        35
         db        1
         db        80
         db        14
         db        14,'$$'
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
         db        ' jinÇho pracovn°ho prostoru',31
         db        ' ------------------------------------------',31
         db        ' D',2,'menu souboru'
         db        10,'E',2,'maz†n° textu',31
         db        ' P',2,'menu tisku'
         db        12,'L',2,'áten° textu',31
         db        '1-5 zmàna prac. prostoru'
         db        2,'S',2,'uloëen° textu',31
         db        ' Q',2,'ukonáen° KonTextu'
         db        5,'X',2,'start programu'
         db        0

tab04:                                      ; ^O
         db        0
         db        23
         db        1
         db        80
         db        15
         db        24,'$$'
         db        20,' CTRL O ',31
         db        3,'$P©ep°naáe zap/vyp'
         db        8,'Form†tov†n°$',31
         db        ' J',2,'zarovn†v†n°'
         db        11,'B',2,'form†t. po konec textu',31
         db        ' H',2,'dàlen° slov'
         db        11,'C',2,'centrov†n° ©†dku',31
         db        ' Q',2,'dàlen° s dotazem'
         db        6,'Z',2,'dvousloupcovÇ form†tov†n°',31
         db        ' V',2,'automat.tabel†tor',31
         db        ' M',2,'<Enter>=kon.odst.'
         db        7,'$Nastaven° str†nky$',31
         db        ' P',2,'zobrazen° str†nky'
         db        5,'I',2,'menu line†lu ©†dku',31
         db        ' T',2,'zobrazen° line†lu'
         db        5,'F',2,'pravò okraj=konec ©†dku',31
         db        ' N',2,'nedokumentn° m¢d'
         db        6,'L',2,'levò okraj=pozice kurzoru',31
         db        26,'R',2,'pravò okraj=pozice kurzoru',31
         db        26,'S',2,'poáet ©†dkñ na str†nku',31
         db        ' A',2,'zaá†tek odstavce',2,0f0h
         db        3,'E',2,'zobrazen° z†hlav°/paty',31
         db        ' U',2,'neform†tovat',6,0ffh
         db        3,'O',2,'blok jako z†hlav°/pata'
         db        0

tab05:                                      ; ^P
         db        0
         db        59
         db        1
         db        80
         db        9
         db        10,' CTRL P ',31
         db        ' N=norm†ln°',31
         db        ' F=zvòraznànÇ',31
         db        ' U=podtrëenÇ',31
         db        ' K=kurz°va',31
         db        ' B=®irokÇ',31
         db        ' H=nadsazenÇ',31
         db        ' T=podsazenÇ'
         db        0,0,0,0,0,0,0,0

tab06:                                      ; ^Q
         db        0
         db        39
         db        1
         db        80
         db        13
         db        30,' CTRL Q ',31
         db        ' A',2,'hled†n°/z†màna'
         db        5,'F',2,'hled†n°',31
         db        ' M',2,'nastaven° znaáky'
         db        3,'T',2,'makrokl†vesy',31
         db        ' L',2,'navr†cen° posledn°ch zmàn   ',31
         db        10,'$Pozice kurzoru...$',31
         db        ' S',2,'zaá†tek ©†dku'
         db        6,'D',2,'konec ©†dku',31
         db        ' E',2,'horn° okraj'
         db        8,'X',2,'doln° okraj',31
         db        ' R',2,'zaá†tek textu'
         db        6,'C',2,'konec textu',31
         db        ' B',2,'zaá†tek bloku'
         db        6,'K',2,'konec bloku',31
         db        ' P',2,'na znaáku'
         db        10,'Z',2,'pozice',31
         db        14,'$Maz†n°...$',31
         db        ' H',2,'po zaá†tek ©†dku'
         db        3,'Y',2,'po konec ©†dku'
         db        0,0

tab07:                                      ; ^JC
         db        1
         db        52
         db        1
         db        80
         db        10
         db        16,' CTRL JC ',31,31
         db        2,'--- Nastaven° barev ---',31
         db        ' Zadejte á°slo barvy nebo',31
         db        ' zvolte <Enter>=beze zmàny',31,31
         db        ' Barva p°sma (0..15):',31
         db        ' Barva okol° (0..15):'
         db        0

tab08:                                      ; ^JI
         db        1
         db        54
         db        1
         db        80
         db        13
         db        13,' CTRL JI ',31,31
         db        ' - Pracovn° prostor : - ',31
         db        '$   obsah          ©†dkñ$',31
         db        31,31,31,31,31,31
         db        ' text :'
         db        7,'B volnòch',31
         db        ' makra:'
         db        7,'B volnòch'
         db        0

tab09:                                      ; ^JK
         db        1
         db        49
         db        1
         db        80
         db        16
         db        19,' CTRL JK ',31
         db        31,31,31
         db        2,'PO',2,'óT',2,'ST',2,'ÄT',2,'Pè',2,'SO',2,'NE',31
         db        ' ============================',31
         db        31,31,31,31,31,31
         db        ' ============================',31
         db        1,0fbh,2,'p©edch.'
         db        2,0fah,' n†sled.  màs°c',31
         db        1,0f9h,2,'p©edch.',2,0f8h,' n†sled.  rok '
         db        0

tab10:                                      ; ^KD
         db        1
         db        61
         db        1
         db        80
         db        17
         db        8,' CTRL KD ',31
         db        ' áti text',31
         db        ' uloë text',31
         db        ' áti blok',31
         db        ' uloë blok',31
         db        ' zru® soubor',31
         db        ' p©ejmenuj soubor',31
         db        ' kop°ruj soubor',31
         db        ' start programu',31
         db        ' uloë nastaven°',31
         db        ' konec KonTextu',31
         db        ' ----------------',31
         db        ' form†t KonText',31
         db        ' form†t Layout',31
         db        ' form†t ASCII',31
         db        ' z†loha BAK'
         db        0

tab11:
         db        0
         db        52
         db        1
         db        80
         db        3
         db        'a'
         db        0

tab12:                                      ; zad†n° str†nek k tisku
         db        1
         db        52
         db        1
         db        80
         db        11
         db        31
         db        4,'-- tisk textu   --',31
         db        2,'  Zadejte á°sla nebo     ',31
         db        '   <Enter> = ë†dn† zmàna ',31,31
         db        ' prvn° str†nka:  ',5,'1',31
         db        ' koneán† str†nka:',31
         db        ' prvn° á°slo strany:',2,'1',31
         db        ' exempl†©ñ:',11,'1'
         db        0

tab13:                                      ; ^KP
         db        1
         db        55
         db        1
         db        80
         db        7
         db        13,' CTRL KP ',31,31
         db        ' - prob°h† tisk textu -',31,31
         db        9,'d†le',31
         db        9,'p©eru®en°'
         db        0

tab14:                                      ; ^KQ
         db        1
         db        25
         db        6
         db        54
         db        14
         db        16,' CTRL KQ ',31,31
         db        3,'T°mto povelem ukoná°te',31
         db        ' KonText a navr†t°te se zpàt',31
         db        2,'do operaán°ho systÇmu !!!',31,31
         db        2,'Stisknàte <Enter> = konec',31
         db        3,'nebo <Esc> = pokraáuj'
         db        0

tab15:                                      ; ^OE
         db        0
         db        58
         db        1
         db        80
         db        7
         db        10,' CTRL OE ',31
         db        31
         db        'Jako blok se zobraz°:',31,31
         db        4,'K = z†hlav°',31
         db        4,'F = pata '
         db        0

tab16:                                      ; ^OI
         db        0
         db        53
         db        1
         db        80
         db        15
         db        14,' CTRL OI ',31
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
         db        0

tab17:                                      ; ^OO
         db        0
         db        58
         db        1
         db        80
         db        7
         db        10,' CTRL OO ',31,31
         db        ' Blok se uloë° jako: ',31,31
         db        4,'K = z†hlav° ',31
         db        4,'F = pata'
         db        0

tab18:                                      ; ^OS
         db        1
         db        46
         db        1
         db        80
         db        11
         db        22,' CTRL OS ',31,31
         db        '   Zadejte novÇ nastaven° nebo',31
         db        2,'stisknàte <Enter>=beze zmàny: ',31,31
         db        ' ©†dkñ na str†nku (4..99):',31
         db        ' z toho: z†hlav°  (0..10):',31
         db        7,'  pata   ',2,'(0..10):',31,31
         db        ' rozteá ©†dkñ :',9,'cm'
         db        0

tab19:                                      ; ^OZ
         db        1
         db        25
         db        4
         db        54
         db        14
         db        17,' CTRL OZ ',31,31
         db        3,'Tento povel zform†tuje',31
         db        4,'text na tÇto stranà',31
         db        4,'dvousloupcovà. NovÇ',31
         db        3,'form†tov†n° jië nad†le',31
         db        7,'nebude moënÇ !',31
         db        10,'Zvolte:',31
         db        5,'<Enter> = potvrzen°',31
         db        2,'<Esc> = p©eru®en° povelu'
         db        0

tab20:                                      ; volby pro hled†n°
         db        0
         db        58
         db        1
         db        80
         db        9
         db        10,' VOLBY ',31
         db        ' B',2,'zpàtnò smàr',31
         db        ' G',2,'v celÇm textu',31
         db        ' L',2,'v celÇm bloku',31
         db        ' W',2,'pouze celÇ slovo',31
         db        ' U',2,'nerozli®uje velk†',31
         db        4,'a mal† p°smena'
         db        0

tab21:                                      ; hl†®en° - Text nebude uloëen
         db        1
         db        27
         db        7
         db        54
         db        13
         db        31
         db        2,' Text v prac.prost.',31
         db        2,'nebude uloëen na disk !',31,31
         db        3,'<Enter>=pokraáov†n°',31
         db        5,'<Esc>=p©eru®en°'
         db        0

tab22:                                      ; zvl†®tn° znaky
         db        1
         db        34
         db        1
         db        80
         db        15
         db        28,' Zvl†®tn° znaky '
         db        0

tab23:                                      ; hl†®en° SETUP
         db        1
         db        25
         db        4
         db        54
         db        13
         db        19,' SETUP ',31,31
         db        ' Tato volba zpñsob°, ëe p©i',31
         db        2,'dal®°m spu®tàn° KonTextu',31
         db        2,'bude opàt pouëito stejnÇ',31
         db        3,'nastaven° parametrñ.',31,31
         db        3,'Zvolte <Enter>=uloëen°',31
         db        4,'nebo <Esc>=p©eru®en°.'
         db        0

tab24:                                      ; CTRL-KN
         db        0
         db        50
         db        1
         db        80
         db        8
         db        18,' CTRL KN ',31,31
         db        3,'Nastaven° sloupc.bloku:',31,31
         db        ' B',2,'zaá†tek (levò horn° roh)',31
         db        ' K',2,'konec (pravò doln° roh) '
         db        0

tab25:                                      ; sÇriovò tisk
         db        1
         db        50
         db        1
         db        80
         db        10
         db        31
         db        5,'--- SÇriovò tisk --',31
         db        ' Pros°m, zadejte novou volbu',31
         db        2,'nebo <Enter> = beze zmàny:',31,31
         db        ' Datovò prostor',2,'(1..5):',31
         db        ' P©eform†tov†n° ',2,'(J/N):',31
         db        0

tab26:                                      ; pauza sÇriovÇho tisku
         db        1
         db        30
         db        7
         db        51
         db        13
         db        31
         db        ' SÇriovò tisk-pauza',31
         db        ' pro',2,'vòmànu pap°ru',31,31
         db        ' pokraáov†n° = <Enter> ,',31
         db        4,'p©eru®en° = <ESC>'
         db        0

tab27:                                      ; volba KURZOR
         db        1
         db        1
         db        1
         db        21
         db        12
         db        31
         db        ' zaá†tek textu',31
         db        ' konec textu',31
         db        ' zaá†tek bloku',31
         db        ' konec bloku',31
         db        ' na znaáku',31
         db        ' nastaven° znaáky',31
         db        ' na danou pozici',31
         db        ' vyhled†n° textu',31
         db        ' hled†n°/z†màna',31
         db        ' dal®° hled†n°'
         db        0

tab28:                                      ; volba MAZèNã
         db        1
         db        3
         db        1
         db        21
         db        9
         db        31
         db        ' slovo vpravo',31
         db        ' po kurzor',31
         db        ' od kurzoru',31
         db        ' celò ©†dek',31
         db        ' celò blok',31
         db        ' obnoven° zmàn',31
         db        ' celò text'
         db        0

tab29:                                      ; volba BLOK
         db        1
         db        12
         db        1
         db        29
         db        14
         db        31
         db        ' zaá†tek bloku',31
         db        ' konec bloku',31
         db        ' sloupc.blok ',0dah,0c4h,31
         db        ' sloupc.blok',2,0c4h,0d9h,31
         db        ' maz†n°',31
         db        ' p©em°stàn°',31
         db        ' kop°rov†n°',31
         db        ' p©enos z prost.',31
         db        ' áten° z disku',31
         db        ' uloëen° na disk',31
         db        ' zmàna p°sma',31
         db        ' oznaáen° bloku'
         db        0

tab30:                                      ; volba PãSMO
         db        1
         db        19
         db        1
         db        37
         db        9
         db        31
         db        ' norm†ln°',31
         db        ' zvòraznànÇ',31
         db        ' podtrëenÇ',31
         db        ' kurz°va',31
         db        ' ®irokÇ',31
         db        ' nadsazenÇ',31
         db        ' podsazenÇ'
         db        0

tab31:                                      ; volba FORMèT.
         db        1
         db        26
         db        1
         db        46
         db        14
         db        31
         db        ' po konec odstav.',31
         db        ' po konec textu',31
         db        ' dvousloupcovà',31
         db        ' centruj ©†dek',31
         db        ' zarovn†v†n°',31
         db        ' rozdàlov†n°',31
         db        ' s dotazem',31
         db        ' auto-tabel†tor',31
         db        ' <Enter>=odstavec',31
         db        ' zaá†t. odstavce ',0f0h,31
         db        ' konec odstavce',2,0f1h,31
         db        ' neform†tovat',4,0ffh
         db        0

tab32:                                      ; volba STRèNKA
         db        1
         db        32
         db        1
         db        56
         db        14
         db        31
         db        ' ©†dkñ na str†nku',31
         db        ' menu line†lu ©†dkñ',31
         db        ' levò okraj=kurzor',31
         db        ' pravò okraj=kurzor',31
         db        ' pravò okraj=konec ©†d.',31
         db        ' zobrazen° z†hlav°',31
         db        ' zobrazen° paty',31
         db        ' blok jako z†hlav°',31
         db        ' blok jako pata',31
         db        ' zobraz. str†nkov†n°',31
         db        ' zobr. line†lu ©†dku',31
         db        ' nedokumentn° m¢d'
         db        0

tab33:                                      ; volba DISPLEJ
         db        1
         db        43
         db        1
         db        61
         db        8
         db        31
         db        ' 25 ©†dkñ',31
         db        ' 28 ©†dkñ (VGA)',31
         db        ' 43/50 ©†dkñ',31
         db        ' zmàna barev',31
         db        ' n†povàda',31
         db        ' blik†n° kurz.'
         db        0

tab34:                                      ; volba EXTRA
         db        1
         db        51
         db        1
         db        69
         db        14
         db        31
         db        ' prac. prostor',31
         db        ' text do bufferu',31
         db        ' text z bufferu',31
         db        ' z†pis áasu',31
         db        ' z†pis data',31
         db        ' kalend†©',31
         db        ' grafickò editor',31
         db        ' zvl†®tn° znaky',31
         db        ' makrokl†vesy',31
         db        ' kalkul†tor',31
         db        ' sloupc. souáet',31
         db        ' sloupc. prñmàr'
         db        0

tab35:                                      ; volba TISK, ^KP
         db        1
         db        59
         db        1
         db        77
         db        15
         db        6,' CTRL KP ',31
         db        ' tisk textu',31
         db        ' sÇriovò tisk',31
         db        ' áten° instalace',31
         db        ' zmàna instalace',31
         db        ' ---------------',31
         db        ' vy®®° kvalita',31
         db        ' p°smo Elite',31
         db        ' £zkÇ p°smo',31
         db        ' proporcion†l.',31
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

taberr:                                     ; tabulka chybovòch hl†®en°
         db        1,'Soubor nebyl nalezen',0
         db        2,'Äten° souboru nen° moënÇ',0
         db        3,'Z†pis do souboru nen° moënò',0
         db        4,'Poëadovanò adres†© nenalezen',0
         db        5,'Nedostatek m°sta v pamàti',0
         db        6,'P©ekroáen maxim†ln° poáet ©†dkñ',0
         db        7,'" nebyl nalezen',0
         db        8,'û†dek je moc dlouhò',0
         db        9,'NepovolenÇ zad†n°',0
         db        10,'Nen° oznaáen ë†dnò blok',0
         db        11,'Pamàü makrokl†ves je pln†',0
         db        12,'Tisk†rna nen° v provozu',0
         db        13,'Chybnò form†t dat',0
         db        15,'Soubor s t°mto jmÇnem jië existuje',0
         db        16,'Zdrojovò a c°lovò soubor jsou identickÇ',0
         db        17,'Prostor @ nen° dosud vytistàn.',0
         db        18,'Sloupcovò blok nemñëe bòt zaps†n do souboru',0
         db        19,'Nen° oznaáen ë†dnò sloupcovò blok',0
         db        20,'Kurzor se mus° nach†zet vpravo od pravÇho okraje',0
         db        21,'Mus° bòt zad†n soubor EXE nebo COM',0
         db        50,'Nepovolenò matematickò vòraz',0
         db        51,'P©eteáen° desetinnÇ teáky',0
         db        52,'Dàlen° nulou',0
         db        53,'Chybnò argument',0
         db        54,'Chyba argumentu',0
         db        99,'Intern° chyba',0
         db        100,'Disketov† mechanika nepracuje',0
         db        153,'Neoáek†vanò konec souboru',0
         db        196,'P©eteáen° á°sla Integer',0
         db        240,'Disk je plnò',0
         db        241,'NepovolenÇ jmÇno souboru',0
         db        0,'Bl°ëe neuráiteln† chyba',0

                                            ; FUNKCE 08 - adresa chybovòch hl†®en°

fnc08:   mov       si,offset taberr         ; tabulka hl†®en°
         push      ds                       ; nastaven° ES = DS
         pop       es
         ret


; *****************************************************************************
;                              ClearWind
;                            Vymaz†n° okna
; -----------------------------------------------------------------------------
; VSTUP:  AX=mazac° znak
;         DL=poá†teán° pozice okna
;         DH=poá†teán° ©†dek okna
;         CL=®°©ka okna (v pozic°ch)
;         CH=vò®ka okna (v ©†dc°ch)
;         DS=datovò segment
; *****************************************************************************

PUBLIC   ClearWind
ClearWind PROC     NEAR

         or        cl,cl                    ; je ®°©ka = 0 ?
         jz        ClrWind3                 ; ®°©ka = 0 (nezobraz° se nic)
         or        ch,ch                    ; je vò®ka okna = 0 ?
         jz        ClrWind3                 ; vò®ka = 0 (nezobraz° se nic)

; ------ Cyklus zobrazen° jednoho ©†dku

         push      cx                       ; £schova rozmàrñ okna
         push      dx                       ; £schova poá†teán° pozice okna
ClrWind1:push      cx                       ; £schova á°taáe ©†dkñ
         push      dx                       ; £schova poá†teán° pozice ©†dku
         xor       ch,ch                    ; CX = poáet znakñ na ©†dek okna
         call      OutChar                  ; zobrazen° ©†dku okna
         pop       dx                       ; n†vrat poá†teán° pozice ©†dku
         pop       cx                       ; n†vrat á°taáe ©†dkñ
         inc       dh                       ; zvò®en° á°sla ©†dku
         dec       ch                       ; sn°ëen° á°taáe ©†dkñ
         jnz       ClrWind1                 ; zobrazen° dal®°ho ©†dku
         pop       dx                       ; n†vrat poá†teán° pozice okna
         pop       cx                       ; n†vrat rozmàrñ okna

ClrWind3:ret

ClearWind ENDP

; *****************************************************************************
;                              KurzOff
;             Vypnut° kurzoru (nastaven° pozice mimo displej)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; *****************************************************************************

PUBLIC   KurzOff
KurzOff  PROC    NEAR

         push      dx
         xor       dx,dx
         mov       dh,ds:[MaxRow]           ; maxim†ln° ©†dek
         inc       dh                       ; ©†dek o 1 vy®®°
         call      SetKurzPos               ; nastaven° pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP



; *****************************************************************************
;                              SetKurzPos
;                       Nastaven° pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP:  DH=©†dek
;         DL=pozice
;         DS=datovò segment
; *****************************************************************************

PUBLIC   SetKurzPos
SetKurzPos PROC    NEAR

         push      ax
         push      bx
         mov       ah,2
         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         call      Int10P                   ; nastaven° pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurzPos ENDP


; *****************************************************************************
;                              Out1Char
;                  Zobrazen° jednoho znaku na obrazovce
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k zobrazen°
;         DH=©†dek
;         DL=pozice
;         DS=datovò segment
; *****************************************************************************

PUBLIC   Out1Char
Out1Char PROC      NEAR

         push      cx
         mov       cx,1
         call      OutChar                  ; zobrazen° znaku
         pop       cx
         ret

Out1Char ENDP


; *****************************************************************************
;                              OutChar
;                     Zobrazen° znaku na obrazovce
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k zobrazen°
;         CX=poáet znakñ k zobrazen°
;         DH=©†dek
;         DL=pozice
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

PUBLIC   OutChar
OutChar  PROC      NEAR
         cmp       dl,ds:[MaxCol]           ; kontrola maxim†ln° pozice
         ja        outchar2                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        outchar2                 ; ©†dek p©ekroáen

         push      cx
         push      dx
         push      di
         push      es

         les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         push      ax
         xor       ax,ax
         mov       al,ds:[MaxCol]           ; maxim†ln° pozice na ©†dku
         inc       al                       ; poáet pozic na ©†dku
                                          ;* omezen° poátu znakñ
         push      ax                       ; £schova poátu pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       ax,cx                    ; p©ekroáen poáet znakñ ?
         jae       OutChar1                 ; nen° p©ekroáen poáet znakñ
         mov       cx,ax                    ; omezen° poátu znakñ
OutChar1:pop       ax
                                          ;* vòpoáet adresy ve videopamàti
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh
         add       ax,dx
         add       ax,ax
         add       di,ax
         pop       ax

         call      WriteScreen              ; z†pis znakñ na obrazovku
         pop       es
         pop       di
         pop       dx
         add       dl,cl                    ; zvò®en° pozice
         pop       cx

OutChar2:ret

OutChar  ENDP


; *****************************************************************************
;                             ReadScreen
;                      Äten° znaku z obrazovky
; -----------------------------------------------------------------------------
; VSTUP:  ES:SI=átec° adresa z videopamàti
;         DS=datovò segment
; VùSTUP: AX=naátenò znak
;         ES:SI=nov† átec° adresa
; *****************************************************************************

PUBLIC   ReadScreen
ReadScreen PROC    NEAR

         pushf
         cld                                ; smàr nahoru
         push      dx
         mov       dx,ds:[PortCRT]          ; b†zov† adresa ©adiáe displeje
         add       dx,6                     ; stavovò registr
         test      byte ptr ds:[CheckSnow],1 ; prov†d° se kontrola snàëen° ?
         push      ds
         push      es
         push      es
         pop       ds
         jz        ReadScr6                 ; neprov†d° se kontrola snàëen°

; ------ Äten° znaku s kontrolou snàëen°

ReadScr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        ReadScr2                 ; je horiz. zpàtnò bàh - áek†n°
         cli                                ; z†kaz p©eru®en°
ReadScr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       ReadScr4                 ; áek†n° na horiz. zpàtnò bàh

ReadScr6:lodsw                              ; áten° znaku z videopamàti
         sti                                ; povolen° p©eru®en°
         pop       es
         pop       ds
         pop       dx
         popf
         ret

ReadScreen ENDP



; *****************************************************************************
;                            WriteScreen
;                      Z†pis znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  CX=poáet znakñ k z†pisu
;         AX=znak k z†pisu
;         ES:DI=ukl†dac° adresa ve videopamàti
;         DS=datovò segment
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

PUBLIC   WriteScreen
WriteScreen PROC   NEAR

         pushf
         push      cx
         cld                                ; smàr nahoru
         test      byte ptr ds:[CheckSnow],1 ; prov†d° se kontrola snàëen° ?
         jz        WritScr6                 ; neprov†d° se kontrola snàëen°
         jcxz      WritScr6                ; nen° ë†dnò znak k z†pisu

; ------ Z†pis znaku s kontrolou snàëen°

         push      ax
         push      bx
         push      dx
         mov       bx,ax                    ; znak k z†pisu
         mov       dx,ds:[PortCRT]          ; b†zov† adresa ©adiáe displeje
         add       dx,6                     ; stavovò registr
WritScr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        WritScr2                 ; je horiz. zpàtnò bàh - áek†n°
         cli                                ; z†kaz p©eru®en°
WritScr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       WritScr4                 ; áek†n° na horiz. zpàtnò bàh
         mov       ax,bx                    ; znak k z†pisu
         stosw                              ; z†pis jednoho znaku
         sti                                ; povolen° p©eru®en°
         loop      WritScr2                 ; p©enos dal®°ho znaku
         pop       dx
         pop       bx
         pop       ax

WritScr6:rep      stosw                    ; z†pis znaku bez kontroly snàëen°
         pop       cx
         popf
         ret

WriteScreen ENDP



; *****************************************************************************
;                             MoveScreen
;                    P©enos ©etàzce z/do obrazovky
; -----------------------------------------------------------------------------
; VSTUP:  CX=poáet znakñ k p©enesen°
;         DF=smàr p©enosu nastaven dolñ nebo nahoru
;         BX:SI=zdrojov† adresa ©etàzce
;         DX:DI=c°lov† adresa ©etàzce
;         DS=datovò segment
; *****************************************************************************

PUBLIC   MoveScreen
MoveScreen PROC    NEAR

         pushf
         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds                       ; £schova DS
         push      es
         jcxz      MoveScr6                 ; nen° ë†dnò znak k p©enosu

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         mov       es,dx                    ; segment c°lovÇ adresy
         mov       dx,ds:[PortCRT]          ; b†zov† adresa ©adiáe displeje
         add       dx,6                     ; stavovò registr
         test      byte ptr ds:[CheckSnow],1 ; prov†d° se kontrola snàëen° ?
         mov       ds,bx                    ; segment zdrojovÇ adresy
         je        MoveScr5                 ; neprov†d° se kontrola snàëen°

; ------ p©enos dat s obsluhou snàëen°

MoveScr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        MoveScr2                 ; je horiz. zpàtnò bàh - áek†n°
         cli                                ; z†kaz p©eru®en°
MoveScr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       MoveScr4                 ; áek†n° na horiz. zpàtnò bàh
         movsw                              ; p©enos jednoho znaku
         sti                                ; povolen° p©eru®en°
         loop      MoveScr2                 ; p©enos dal®°ho znaku

; ------ p©enos dat bez kontroly snàëen°

MoveScr5:rep       movsw                    ; p©enos dat bez kontroly snàëen°

MoveScr6:pop       es
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         popf
         ret

MoveScreen ENDP


; *****************************************************************************
;                             TestTextVMode
;                      Test, zda je textovò videom¢d
;                    (vyëaduje rozpozn†n° videokarty)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: AL=aktu†ln° videom¢d
;         CY=nen° textovò videom¢d
;
; ZniáenÇ registry: AH
; *****************************************************************************

PUBLIC   TestTextVMode
TestTextVMode PROC NEAR
; ------ Test, zda je textovò videom¢d jië nastaven

         call      AktParDisp               ; aktualizace parametrñ displeje
         cmp       al,7                     ; videom¢d MDA
         je        TestTxt2                 ; je nastaven textovò videom¢d MDA
         cmp       al,4
         cmc
TestTxt2:ret
TestTextVMode ENDP

; *****************************************************************************
;                             SetTextVMode
;                      Nastaven° textovÇho videom¢du
;                    (vyëaduje rozpozn†n° videokarty)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: AL=novò aktu†ln° videom¢d
;         CY=videom¢d nen° moënÇ nastavit
;
; ZniáenÇ registry: AH
; *****************************************************************************

PUBLIC   SetTextVmode
SetTextVmode PROC NEAR

; ------ Zji®tàn° poëadovanÇho videom¢du

;         call      TestTextVMode
;         jc        SetText0                 ; nen° textovò videom¢d
;         cmp       al,7
;         je        SetText4
;         cmp       al,3
;         je        SetText4
;         cmp       al,2
;         je        SetText4

SetText0:int       11h                      ; poskytnut° tabulky vybaven°
         and       al,30h                   ; inicializaán° videom¢d
         mov       ah,7                     ; videom¢d MDA
         cmp       al,30h                   ; videom¢d 80x25 monochrom. ?
         je        SetText2                 ; inic. videom¢d 80x25 monochrom.
         mov       ah,3                     ; videom¢d CGA 80x25
         cmp       al,20h                   ; videom¢d 80x25 barevnò ?
         je        SetText1                 ; inic. videom¢d 80x25 barevnò
         mov       ah,1                     ; videom¢d 40x25 barevnò
SetText1:xor       ah,ds:[Monochr]          ; zmàna pro monochrom. displeje
SetText2:mov       al,ah                    ; poëadovanò videom¢d

; ------ Nastaven° videom¢du

SetText4:call      SetVideoMode             ; nastaven° poëadovanÇho videom¢du
SetText3:ret

SetTextVmode ENDP


; *****************************************************************************
;                             SetVideoMode
;                          Nastaven° videom¢du
;                    (vyëaduje rozpozn†n° videokarty)
; -----------------------------------------------------------------------------
; VSTUP:  AL=poëadovanò videom¢d
;         DS=datovò segment
; VùSTUP: AL=novò aktu†ln° videom¢d
;         CY=videom¢d nenastaven
;
; ZniáenÇ registry: AH
; *****************************************************************************

PUBLIC   SetVideoMode
SetVideoMode PROC  NEAR

         push      bx
         push      ax                       ; £schova poëadovanÇho videom¢du
         xor       ah,ah                    ; funkce nastaven° videom¢du
         call      Int10P                   ; nastaven° videom¢du
         call      AktParDisp               ; poskytnut° aktivn°ho videom¢du
         mov       bl,al                    ; £schova aktu†ln°ho videom¢du
         pop       ax                       ; n†vrat poëadovanÇho videom¢du
         xchg      al,bl                    ; AL <- novò videom¢d
         cmp       al,bl                    ; souhlas° videom¢d s poëadovanòm ?
         je        SetVMod1                 ; videom¢d nastaven OK
         stc                                ; p©°znak chyby nastaven° videom¢du
SetVMod1:pop       bx
         ret

SetVideoMode ENDP

; *****************************************************************************
;                               AktParDisp
;            Atualizace parametrñ displeje, poskytnut° videom¢du
;                    (vyëaduje rozpozn†n° karty EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: AL=aktu†ln° videom¢d
;
; ZniáenÇ registry: AH
; *****************************************************************************

PUBLIC   AktParDisp
AktParDisp PROC NEAR

         push      es
         push      bx
         push      dx

         mov       ax,40h
         mov       es,ax                    ; ES <- 40h segment dat BIOS

; ------ Zji®tàn° videom¢du

         mov       al,es:[49h]              ; aktu†ln° videom¢d
         and       al,7fh                   ; zru®en° p©°znaku nemaz†n° displeje
         mov       ds:[AktVmod],al          ; aktu†ln° videom¢d

; ------ Zji®tàn° adresy videopamàti a detekce p©°znaku obsluhy snàëen°

         mov       byte ptr ds:[CheckSnow],0 ; zru®en° p©°znaku obsluhy snàëen°
         mov       bx,0A000h                ; segment videopamàti pro EGA/VGA
         cmp       al,11                    ; je grafickò videom¢d EGA/VGA ?
         jae       AktParD1                 ; je grafickò videom¢d EGA/VGA
         mov       bx,0B000h                ; segment videopamàti pro MDA a PCjr
         cmp       al,7                     ; je videom¢d MDA nebo PCjr ?
         jae       AktParD1                 ; je videom¢d MDA nebo PCjr
         mov       bx,0B800h                ; segment videopamàti pro m¢dy CGA
         mov       byte ptr ds:[CheckSnow],1 ; nastav. p©°znaku obsluhy snàëen°
AktParD1:mov       word ptr ds:[AdrVRAM+2],bx ; adresa segmentu videopamàti
         mov       bx,es:[4eh]              ; poá†teán° adresa videopamàti
         mov       word ptr ds:[AdrVRAM],bx ; poá†teán° adresa videopamàti

; ------ Detekce monochromatickÇho videom¢du

         xor       bl,bl                    ; p©°znak - nen° monochrom. videom¢d
         cmp       al,15                    ; je videom¢d EGA 640x350/2 ?
         je        AktParD2                 ; je videom¢d EGA 640x350/2 (mono)
         cmp       al,7                     ; je barevnò grafickò videom¢d ?
         ja        AktParD3                 ; nen° monochromatickò videom¢d
         mov       bl,al                    ; £schova videom¢du
         cmp       bl,4                     ; je videom¢d 4 a vy®®° ?
         jae       AktParD3                 ; nen° textovò videom¢d CGA
AktParD2:xor       bl,1                     ; zmàna p©°znakovÇho bitu 0
AktParD3:and       bl,1                     ; ponech† p©°znakovò bit 0
         mov       ds:[Monochr],bl          ; nastaven° p©°znaku monochrom. m¢du

; ------ Detekce textovÇho videom¢du

         mov       bl,1                     ; p©°znak textovÇho videom¢du
         cmp       al,7                     ; je textovò videom¢d MDA ?
         je        AktParD4                 ; je textovò videom¢d MDA
         cmp       al,3                     ; je textovò videom¢d CGA ?
         jbe       AktParD4                 ; je textovò videom¢d CGA
         xor       bl,bl                    ; p©°znak grafickÇho vidoem¢du
AktParD4:mov       ds:[TextVMOD],bl         ; nastaven° p©°znaku textovÇho m¢du

; ------ Zji®tàn° aktu†ln° videostr†nky

         mov       bl,es:[62h]              ; aktivn° str†nka displeje
         mov       ds:[AktPage],bl          ; aktivn° str†nka displeje

; ------ Zji®tàn° posledn° pozice na ©†dku

         mov       bl,es:[4ah]              ; poáet pozic na ©†dek
         dec       bl                       ; posledn° pozice na ©†dku
         mov       ds:[MaxCol],bl           ; posledn° pozice na ©†dku

; ------ Zji®tàn° posledn°ho ©†dku na displeji a up©esnàn° p©°znaku snàëen°

         mov       bx,24                    ; p©ednastaven° na 25 ©†dkñ
         mov       dl,ds:[VideoCard]        ; videokarta
         cmp       dl,9                     ; je karta VGA ?
         je        AktParD5                 ; je karta VGA
         cmp       dl,5
         ja        AktParD6                 ; nen° karta EGA
         cmp       dl,3
         jb        AktParD6                 ; nen° karta EGA
AktParD5:mov       bl,es:[84h]              ; poáet ©†dkñ displeje - 1
         mov       dl,es:[87h]              ; p©°znak kontroly snàëen°
         shr       dl,1
         shr       dl,1
         and       dl,1
         mov       ds:[CheckSnow],dl        ; nastaven° p©°znaku kontroly snàë.
AktParD6:mov       ds:[MaxRow],bl           ; maxim†ln° ©†dek na displeji

; ------ Zji®tàn° b†zovÇ ©°dic° adresy displeje CRT

         mov       bx,es:[63h]              ; b†zov† adresa portu ©adiáe CRT
         mov       ds:[PortCRT],bx          ; b†zov† adresa portu ©adiáe CRT

         pop       dx
         pop       bx
         pop       es
         ret

AktParDisp ENDP


; *****************************************************************************
;                               DetectCard
;              Detekce videokarty - rozpozn†n° typu videokarty
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
;
; VùSTUP: AX=1: CGA
;            2: MCGA
;            3: EGA
;            4: EGA 64kB
;            5: EGA Mono
;           (6: IBM8514)
;            7: Hercules
;           (8: ATT400)
;            9: VGA
;           10: PC3270
; *****************************************************************************

PUBLIC   DetectCard
DetectCard PROC NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         call      DetCard0                 ; detekce videokarty
         xor       ax,ax
         mov       al,ds:[VideoCard]        ; detekovan† videokarta
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret
DetectCard ENDP

; -----------------------------------------------------------------------------
DetCard0:
         mov       ah,0fh
         call      Int10P                   ; dotaz na videom¢d
         cmp       al,7                     ; je monochromatickò videom¢d ?
         je        DetCard5                 ; je monochromatickò videom¢d

; ------ je barevnò reëim - rozpozn†n° EGA/VGA

         call      DetCard8                 ; test karet EGA/VGA
         jc        DetCard2                 ; nen° karta EGA/VGA
DetCard1:call      DetCardA                 ; rozli®en° karet EGA/VGA
         ret
DetCard2:                                 ;* rozpozn†n° karty PC3270
         call      DetCardP                 ; detekce karty PC3270
         jc        DetCard3                 ; nen° karta PC3270
         mov       byte ptr ds:[VideoCard],10; je videokarta PC3270
         ret

DetCard3:                                 ;* rozpozn†n° karet CGA/MCGA
         mov       byte ptr ds:[VideoCard],1; p©ednastaven° karty CGA
         call      DetCardG                 ; test karty MCGA
         jc        DetCard4                 ; nen° karta MCGA
         mov       byte ptr ds:[VideoCard],2; je karta MCGA
DetCard4:ret

DetCard5:                                 ;* monochrom. reëim - test EGA/VGA
         call      DetCard8                 ; test karty EGA/VGA
         jnc       DetCard1                 ; je EGA/VGA - rozli®en° EGA a VGA
                                          ;* test karty Hercules/MDA
         call      DetCardJ                 ; test karty Hercules
         jc        DetCard6                 ; nen° karta Hercules
         mov       byte ptr ds:[VideoCard],7; je karta Hercules
         ret
DetCard6:                                 ;* test karty CGA (test pamàti)
         mov       si,0b800h                ; segment videopamàti CGA
         mov       es,si                    ; segment videopamàti CGA
         xor       si,si                    ; poá†teán° adresa videopamàti CGA
         mov       ax,es:[si]               ; pñvodn° slovo z videopamàti
         not       ax                       ; inverze
         not       word ptr es:[si]         ; inverze i pñvodn°ho slova
         nop
         nop
         cmp       ax,es:[si]               ; je tam pamàü RAM ?
         jne       DetCard7                 ; nen° pamàü VRAM
         mov       byte ptr ds:[VideoCard],1; je karta CGA
DetCard7:ret
; -----------------------------------------------------------------------------
DetCard8:                                 ;* test karty EGA/VGA
         mov       ax,1200h
         mov       bl,10h                   ; podsluëba poskytnut° parametrñ
         mov       bh,0ffh                  ; p©ednastaven°
         mov       cl,0fh                   ; p©ednastaven°
         call      Int10P                   ; dotaz na EGA kartu
         cmp       cl,0ch
         jge       DetCard9                 ; nen° karta EGA
         cmp       bh,1
         jg        DetCard9                 ; nen° karta EGA
         cmp       bl,3
         jg        DetCard9                 ; nen° karta EGA
         clc                                ; p©°znak - je karta EGA
         ret
DetCard9:stc                                ; p©°znak - nen° karta EGA
         ret
; -----------------------------------------------------------------------------
DetCardA:                                 ;* rozli®en° karet EGA/VGA
         mov       byte ptr ds:[VideoCard],4; p©ednastaven° karty EGA64
         cmp       bh,1                     ; je monochromatickò m¢d ?
         je        DetCardD                 ; je monochromatickò m¢d
         call      DetCardE                 ; test karty EGA 64
         jnc       DetCardC                 ; je karta EGA 64
         or        bl,bl                    ; je EGA 64 ?
         jz        DetCardC                 ; je EGA 64
         mov       byte ptr ds:[VideoCard],3; p©ednastaven° karty EGA
         call      DetCardG                 ; test karty VGA
         jnc       DetCardB                 ; je karta VGA
         mov       bx,0c000h                ; segment s ROM VGA
         mov       es,bx                    ; segment s ROM VGA
         mov       bx,39h                   ; adresa textu "Z449"
         cmp       word ptr es:[bx],"Z4"    ; je text "Z4" ?
         jne       DetCardC                 ; nen° karta VGA
         cmp       word ptr es:[bx+2],"49"  ; je text "49" ?
         jne       DetCardC                 ; nen° karta VGA
DetCardB:mov       byte ptr ds:[VideoCard],9; je karta VGA
DetCardC:ret
DetCardD:mov       byte ptr ds:[VideoCard],5; je karta EGA Mono
         ret

DetCardE:                                 ;* test karty EGA 64
         cmp       cl,2
         jb        DetCardT                 ; je karta EGA 64
         cmp       cl,6
         jb        DetCardF                 ; nen° karta EGA 64
         cmp       cl,8
DetCardT:cmc
DetCardF:ret
; -----------------------------------------------------------------------------
DetCardG:                                 ;* test karty VGA
         mov       ax,1a00h
         call      Int10P                   ; dotaz na poáet linek na znak
         cmp       al,1ah                   ; je funkce obsluhovan† ?
         jne       DetCardI                 ; funkce nen° obsluhovan†
         cmp       bl,7                     ; je 7 linek na znak ?
         je        DetCardH                 ; je karta OK
         cmp       bl,8
         je        DetCardH                 ; je karta OK
         cmp       bl,11
         jb        DetCardI                 ; nen° karta
         cmp       bl,12
         ja        DetCardI                 ; nen° karta
DetCardH:clc                                ; p©°znak - je karta
         ret
DetCardI:stc                                ; p©°znak - nen° karta
         ret
; -----------------------------------------------------------------------------
DetCardJ:                                 ;* test karty Hercules
         mov       dx,03bah                 ; stavovò port karty
         xor       bl,bl                    ; á°taá doby impulsu
         in        al,dx                    ; poá†teán° stav
         and       al,80h                   ; sign†l zpàtnÇho bàhu
         mov       ah,al                    ; £schova stavu registru
         mov       cx,8000h                 ; maxim†ln° doba testu
DetCardK:                                 ;* áek†n° na zmànu stavu bitu 7
         in        al,dx                    ; áten° stavovÇho registru
         and       al,80h                   ; sign†l zpàtnÇho bàhu
         cmp       al,ah                    ; byla zmàna stavu sign†lu ?
         je        DetCardL                 ; nebyla zmàna stavu sign†lu
         inc       bl                       ; á°taá dÇlky impulsu
         cmp       bl,10                    ; je minim†ln° doba impulsu ?
         jae       DetCardM                 ; impuls je dostateánà dlouhò
DetCardL:loop      DetCardK                 ; dal®° test impulsu
         stc                                ; p©°znak - nen° karta Hercules
         ret

DetCardM:                                 ;* áek†n° na bity 5,4 -> 01
         mov       cx,8000h                 ; maxim†ln° doba testu
DetCardN:in        al,dx                    ; áten° stavovÇho registru
         and       al,30h
         cmp       al,10h
         jne       DetCardO                 ; je pouze karta MDA
         loop      DetCardN                 ; dal®° test
         mov       al,2                     ; p©°znak - je karta Hercules
         clc
         ret
DetCardO:mov       al,1                     ; p©°znak - je karta MDA
         clc
         ret
; -----------------------------------------------------------------------------
DetCardP:                                 ;* test videokarty PC3270
         mov       al,6
         xor       cx,cx                    ; CX <- 0
         xor       dx,dx
         mov       ah,30h
         call      Int10P
         mov       ax,cx
         or        ax,dx
         jz        DetCardR                 ; nen° karta PC3270
         push      ds
         mov       ds,cx                    ; segment
         mov       bx,dx                    ; offset
         mov       al,ds:[bx+2]
         pop       ds
         or        al,al
         jz        DetCardQ                 ; je karta PC3270
         cmp       al,2
         jne       DetCardR                 ; nen° karta PC3270
DetCardQ:mov       dx,188h
         in        al,dx
         test      al,4
         jz        DetCardR                 ; nen° karta PC3270
         clc                                ; p©°znak - je karta PC3270
         ret
DetCardR:stc                                ; p©°znak - nen° karta PC3270
         ret

; -----------------------------------------------------------------------------
;        Test, zda je karta EGA
; -----------------------------------------------------------------------------
TestEga:
         push      ax
         mov       al,cs:[VideoCard]
         cmp       al,9
         je        TestEga2
         cmp       al,5
         je        TestEga2
         cmp       al,4
         je        TestEga2
         cmp       al,3
         je        TestEga2
         stc
TestEga2:pop       ax
         ret

; -----------------------------------------------------------------------------
;            Vol†n° INT 10h s £schovou registrñ SI,DI,BP,DS a ES
; -----------------------------------------------------------------------------
Int10P PROC NEAR
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
Int10P ENDP
; -----------------------------------------------------------------------------




konectxt label     near

code     ENDS

         end       start


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                         DCFA v 1.0 - verze s ASCII komunikac¡
;                               nastaven¡ p©esn‚ho ‡asu
;
; Nen¡-li nutn  v˜zva k vysl n¡ ‡asu, nen¡ pot©eba vys¡lac¡ sign l zapojovat.
; Program pracuje bez ohledu na vys¡l n¡ v˜zvy
;
; Jako parametr p©i spu¨tˆn¡ programu se zad v  ‡¡slo 1 a‘ 4 = ‡¡slo portu COM.
;
; Komunika‡n¡ port COM mus¡ b˜t nastaven na po‘adovan‚ p©enosov‚ parametry
; (p©¡kazem MODE nebo MODE+SETCOM).
;
; Na portu COM posta‡¡ p©ipojit pouze p©ij¡mac¡ sign l (a p©¡p. vys¡lac¡),
; na ostatn¡ch sign lech nez le‘¡.
;
; P©i p©enosu se pou‘¡vaj¡ pouze nejni‘¨¡ 4 bity dat, ostatn¡ bity se ignoruj¡.
; Lze proto pou‘¡t nap©. 5-bitov˜ p©enos nebo data transponovat (nap©. OR 30h).
;
; Program navrac¡ n vratov˜ k¢d 1 p©i chybˆ, 0 p©i operaci OK
; -----------------------------------------------------------------------------
; Ovl d n¡ editoru KONTEXT:
;
;   Ctrl-F1 .......... zdrojov˜ text programu DCFA (ASCII komunikace)
;                         F10 ... ulo‘en¡ textu na disk (+ ENTER = konec)
;   Ctrl-F2 .......... zdrojov˜ text programu DCFB (bin rn¡ komunikace)
;                         F10 ... ulo‘en¡ textu na disk (+ ENTER = konec)
;   Ctrl-F3 .......... n povˆda k port–m COM
;   Ctrl-F4 .......... n povˆda k ovl d n¡ data a ‡asu pomoc¡ DOS
;   Alt-F8 ........... nastaven¡ zna‡ky v textu
;   Alt-F9/Alt-F10 ... p©ede¨l /n sleduj¡c¡ zna‡ka
;   ESC .............. menu programu KONTEXT
;   F9 ............... definice makrokl vesy programu KONTEXT
; -----------------------------------------------------------------------------
;
;                            Komunika‡n¡ protokol
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                 program:               ³       jednotka zdroje ‡asu:        ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ vys¡l  na COM znaky v˜zvy (nap©. "?"), ³ dokon‡uje p©ede¨l‚ vys¡l n¡,       ³
;³ ‡ek  na oddˆlovac¡ znak (cokoliv jin‚ho³ p©¡padn‚ po‘adavky v˜zvy ignoruje  ³
;³ ne‘ ‡¡slice)                           ³                                    ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ do‡kal se oddˆlovac¡ho znaku           ³ vy¨le oddˆlovac¡ znak (nap©. "=")  ³
;³                                        ³ jako za‡ tek dal¨¡ zpr vy          ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ vys¡l  na COM znaky v˜zvy (nap©. "?"), ³ znaky v˜zvy bˆhem vys¡l n¡         ³
;³ ‡ek  na prvn¡ platnou ‡¡slici          ³ ignoruje                           ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ p©ij¡m  zpr vu - 14 ‡¡slic             ³ vys¡l  zpr vu - 14 ‡¡slic          ³
;³ v po©ad¡ RRRRMMDDhhmmss                ³ v po©ad¡ RRRRMMDDhhmmss            ³
;³       (RRRR=rok/MM=mˆs¡c/DD=den/hh=hodina/mm=minuta/ss=sekunda)             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;      P©i neplatn‚ zpr vˆ se pokou¨¡ o nov˜ p©enos a‘ do doby TIME-OUT
;
; Program vys¡l  znaky v˜zvy bˆhem p©enosu neust le (pro p©¡pad ztr ty spojen¡
; uprost©ed zpr vy). To m–‘e vyu‘¡t jednotka zdroje ‡asu k aktivaci vys¡l n¡
; jednotliv˜ch znak– p©i p©enosu. Tento zp–sob bude nutno pou‘¡t u rezidentn¡
; verze programu - program bude moct p©ij¡mat nejrychleji 18 bajt– za sekundu,
; znaky v˜zvy by proto mohly b˜t pou‘ity jako potvrzen¡ p©ipravenosti k p©¡jmu
; dal¨¡ho znaku.
; -----------------------------------------------------------------------------
;
;              Zapojen¡ nulov‚ho modemu (pro tuto aplikaci nen¡
;               pot©eba zapojovat sign ly RTS->CTS a DTR->DSR)
;
;   Canon         Canon                    Canon
;   9 pin        25 pin                   25 pin
;  ÉÍÍÍÍ»        ÉÍÍÍÍ»                   ÉÍÍÍÍ»
;  º  5 ÇÄÄÄÄÄ   º  7 ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶  7 º  GND   zem 0 V
;  º  2 ÇÄÄÄÄÄ   º  3 ÇÄÄÄÄÄÄÄÄ\ /ÄÄÄÄÄÄÄÄ¶  3 º  RxD   p©ij¡man  data
;  º  3 ÇÄÄÄÄÄ   º  2 ÇÄÄÄÄÄÄÄÄ/ \ÄÄÄÄÄÄÄÄ¶  2 º  TxD   vys¡lan  data
;  º  7 ÇÄÄ¿     º  4 ÇÄÄ¿             ÚÄÄ¶  4 º  RTS   ‘ dost vys¡la‡e
;  º  8 Ç<ÄÙ     º  5 Ç<ÄÙ             ÀÄ>¶  5 º  CTS   vys¡l n¡ povoleno
;  º  6 Ç<Ä¿     º  6 Ç<Ä¿             ÚÄ>¶  6 º  DSR   p©enos povolen
;  º  4 ÇÄÄÙ     º 20 ÇÄÄÙ             ÀÄÄ¶ 20 º  DTR   kan l p©ipraven
;  º  9 º        º 22 º                   º 22 º  RI    v˜zva
;  º  1 º        º  8 º                   º  8 º  DCD   £rove¤ sign lu
;  ÈÍÍÍÍ¼        ÈÍÍÍÍ¼                   ÈÍÍÍÍ¼
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; ------ nastaven¡ parametr– programu

VYZVA    EQU       "?"                      ; znak v˜zvy pro vysl n¡ zpr vy

TIMEOUT  EQU       2 * 18                   ; TIME-OUT p©¡jmu (v 1/18 sekundy)
                                            ; (povolen˜ rozsah 1 a‘ 65534)
                                            ; (lze p©eru¨it t‚‘ Ctrl-Break)

; V cel‚m programu se uchov v  CS=DS=ES !

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ rozbor p©¡kazov‚ho © dku (mus¡ b˜t nic nebo znak "1" a‘ "4")

Start:   mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka zadan‚ho textu
         mov       ch,0
         cld
Rozbor1: mov       al,0                     ; implicitn¡ port COM 1
         jcxz      Rozbor2                  ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         cmp       al," "                   ; mezera nebo ©¡dic¡ znak ?
         jbe       Rozbor1                  ; mezera nebo tabul tor se ignoruje
         mov       ds:[TOutTxt1],al         ; ozna‡en¡ portu COM
         mov       ds:[COMTxt1],al          ; ozna‡en¡ portu COM
         sub       al,"1"                   ; korekce na ‡¡slo portu
         cmp       al,3                     ; je platn‚ ‡¡slo portu COM ?
         jbe       Rozbor2                  ; je to platn‚ ‡¡slo portu COM

; ------ chyba zad n¡ parametr– - zobrazen¡ n povˆdy

         mov       dx,offset HelpTxt        ; text n povˆdy
Chyba:   mov       ah,9
         int       21h                      ; zobrazen¡ textu n povˆdy
         mov       ax,4c01h
         int       21h                      ; konec programu s chybou 1

; ------ adresa portu COM (AL=‡¡slo portu COM 0 a‘ 3)

Rozbor2: push      ds
         mov       ah,0                     ; AX = ‡¡slo portu COM 0 a‘ 3
         xchg      ax,bx                    ; BX <- ‡¡slo portu COM 0 a‘ 3
         shl       bx,1                     ; offset v tabulce BIOS
         mov       ax,40h
         mov       ds,ax                    ; DS <- datov˜ segment BIOS
         mov       ax,ds:[bx]               ; adresa portu COM
         or        ax,ax                    ; je port COM platn˜ ?
         pop       ds
         mov       dx,offset COMTxt         ; text - port neplatn˜
         jz        Chyba                    ; port COM nen¡ platn˜
         mov       ds:[AdrPort],ax          ; adresa portu COM

; ------ p©¡prava po‡ te‡n¡ho ‡asu pro TIME-OUT

         call      GetBTime                 ; na‡ten¡ ‡¡ta‡e ‡asu BIOS
         mov       word ptr ds:[OldBTime],ax ; £schova po‡ te‡n¡ho ‡asu LOW
         mov       word ptr ds:[OldBTime+2],dx ; £schova po‡ te‡n¡ho ‡asu HIGH

; ------ ‡ek n¡ na oddˆlovac¡ znak

Prijem1: call      InpCChr                  ; p©¡jem znaku
         cmp       al,10                    ; je oddˆlovac¡ znak ?
         jb        Prijem1                  ; ‡ek n¡ na oddˆlovac¡ znak

; ------ vypu¨tˆn¡ dal¨¡ch oddˆlovac¡ch znak–

Prijem2: call      InpCChr                  ; p©¡jem znaku
         cmp       al,10                    ; je to platn˜ znak ?
         jae       Prijem2                  ; ‡ek n¡ na platn˜ znak
         call      RetCChr                  ; navr cen¡ znaku do bufferu
         mov       word ptr ds:[AdrTOut],offset StruTxt ; bude chyba struktury

; ------ p©¡jem zpr vy

         mov       si,offset TabDat         ; tabulka dat k p©¡jmu
Prijem3: mov       cx,ds:[si+6]             ; po‡et ‡¡slic polo‘ky
         call      InpCNum                  ; na‡ten¡ ‡¡sla
         jc        Prijem1                  ; chyba
         cmp       ax,ds:[si+2]             ; minim ln¡ hodnota polo‘ky
         jb        Prijem1                  ; chyba
         cmp       ax,ds:[si+4]             ; maxim ln¡ hodnota polo‘ky
         ja        Prijem1                  ; chyba
         mov       ds:[si],ax               ; ulo‘en¡ na‡ten‚ hodnoty
         add       si,8                     ; dal¨¡ polo‘ka
         cmp       si,offset TabDat0        ; je konec tabulky ?
         jb        Prijem3                  ; nen¡ je¨tˆ konec tabulky

; ------ nastaven¡ syst‚mov‚ho ‡asu

         mov       ah,2dh                   ; slu‘ba pro nastaven¡ ‡asu
         mov       ch,byte ptr ds:[Hodina]  ; hodina
         mov       cl,byte ptr ds:[Minuta]  ; minuta
         mov       dh,byte ptr ds:[Sekunda] ; sekunda
         mov       dl,0                     ; setina sekundy
         int       21h                      ; nastaven¡ syst‚mov‚ho ‡asu
         cmp       al,0
         jne       Prijem1                  ; chyba - neplatn˜ ‡as

; ------ nastaven¡ syst‚mov‚ho data

         mov       ah,2bh                   ; slu‘ba pro nastaven¡ data
         mov       cx,ds:[Rok]              ; rok
         mov       dh,byte ptr ds:[Mesic]   ; mˆs¡c
         mov       dl,byte ptr ds:[Den]     ; den
         int       21h                      ; nastaven¡ syst‚mov‚ho data
         cmp       al,0
         jne       Prijem1                  ; chyba - neplatn‚ datum

; ------ p©¡prava dne pro hl ¨en¡

         mov       al,byte ptr ds:[Den]     ; nastaven˜ den
         mov       di,offset DatTxtD        ; den
         call      DekNm                    ; dek¢dov n¡ ‡¡sla dne

; ------ p©¡prava mˆs¡ce pro hl ¨en¡

         mov       al,byte ptr ds:[Mesic]   ; nastaven˜ mˆs¡c
         mov       di,offset DatTxtM        ; mˆs¡c
         call      DekNm                    ; dek¢dov n¡ ‡¡sla mˆs¡ce

; ------ p©¡prava roku pro hl ¨en¡

         mov       ax,ds:[Rok]              ; nastaven˜ rok
         mov       cl,100
         div       cl                       ; rozdˆlen¡ na stolet¡ a rok
         mov       di,offset DatTxtR        ; rok - stolet¡
         call      DekNm                    ; dek¢dov n¡ stolet¡ roku
         xchg      al,ah
         mov       di,offset DatTxtR+2      ; rok
         call      DekNm                    ; dek¢dov n¡ roku

; ------ p©¡prava hodiny pro hl ¨en¡

         mov       al,byte ptr ds:[Hodina]  ; nastaven  hodina
         mov       di,offset DatTxtH        ; hodina
         call      DekNm                    ; dek¢dov n¡ ‡¡sla hodiny

; ------ p©¡prava minuty pro hl ¨en¡

         mov       al,byte ptr ds:[Minuta]  ; nastaven  minuta
         mov       di,offset DatTxtMI       ; minuta
         call      DekNm                    ; dek¢dov n¡ ‡¡sla minuty

; ------ p©¡prava sekundy pro hl ¨en¡

         mov       al,byte ptr ds:[Sekunda] ; nastaven  sekunda
         mov       di,offset DatTxtS        ; sekunda
         call      DekNm                    ; dek¢dov n¡ ‡¡sla sekundy

; ------ zobrazen¡ hl ¨en¡ o nastaven¡ data a ‡asu

         mov       dx,offset DatTxt         ; text hl ¨en¡
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡

; ------ konec programu

         mov       ax,4c00h                 ; n vratov˜ k¢d 0 = operace OK
         int       21h

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla AL pro hl ¨en¡ do bufferu DS:DI
; -----------------------------------------------------------------------------

DekNm    PROC      NEAR

         push      ax
         aam                                ; rozdˆlen¡ na ‡¡slice
         or        ax,"00"                  ; korekce na ASCII ‡¡slice
         mov       ds:[di+1],al             ; ni‘¨¡ ‡¡slice
         cmp       ah,"0"                   ; je to platn  ‡¡slice ?
         je        DekNm2                   ; je to nev˜znamn  nula
         mov       ds:[di],ah               ; ulo‘en¡ vy¨¨¡ ‡¡slice
DekNm2:  pop       ax
         ret

DekNm    ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla z portu COM
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        CX=po‡et ‡¡slic k na‡ten¡
; VSTUP: AX=na‡ten‚ ‡¡slo
;         CY=nep©ijata platn  ‡¡slice
; -----------------------------------------------------------------------------

InpCNum  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         xor       bx,bx                    ; BX <- 0 st©ada‡ ‡¡sla

; ------ na‡ten¡ ‡¡sla

InpCNum2:call      InpCNm                   ; na‡ten¡ jedn‚ ‡¡slice
         jc        InpCNum9                 ; chyba - p©ijat neplatn˜ znak
         mov       ah,0                     ; AX = p©ijat  ‡¡slice
         xchg      ax,bx                    ; AX <- st©ada‡, BX <- ‡¡slice
         mov       dx,10                    ; n sobitel © du
         mul       dx                       ; st©ada‡ * 10
         add       bx,ax                    ; st©ada‡ + ‡¡slice
         loop      InpCNum2                 ; na‡ten¡ dal¨¡ ‡¡slice

         clc                                ; p©¡znak operace OK
         xchg      ax,bx                    ; AX <- na‡ten‚ ‡¡slo

; ------ n vrat registr–

InpCNum9:pop       dx
         pop       cx
         pop       bx
         ret

InpCNum  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡slice z portu COM
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: AL=na‡ten  ‡¡slice bin rnˆ
;         CY=nep©ijata platn  ‡¡slice
; -----------------------------------------------------------------------------

InpCNm   PROC      NEAR

         call      InpCChr                  ; p©¡jem znaku z portu COM
         cmp       al,10                    ; je to platn  ‡¡slice ?
         cmc
         jnc       InpCNm2                  ; je to platn  ‡¡slice
         call      RetCChr                  ; navr cen¡ znaku do bufferu
InpCNm2: ret

InpCNm   ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ neplatn‚ho p©ijat‚ho znaku do bufferu (uchov v  p©¡znaky)
; -----------------------------------------------------------------------------

RetCChr  PROC      NEAR

         mov       ds:[BuffChr],al          ; navr cen¡ znaku do bufferu
         ret

RetCChr  ENDP

; -----------------------------------------------------------------------------
;        p©¡jem znaku z portu COM (4 bity)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: AL=p©ijat˜ znak z COM (bity 4, 5, 6 a 7 jsou vynulovan‚)
;         neuchov v  obsah registru AH !
; -----------------------------------------------------------------------------

InpCChr  PROC      NEAR

; ------ £schova registr–

         push      dx

; ------ na‡ten¡ znaku z bufferu

         mov       al,-1                    ; p©¡znak neplatnosti znaku
         xchg      al,ds:[BuffChr]          ; na‡ten¡ znaku z bufferu
         cmp       al,-1                    ; je znak z bufferu platn˜ ?
         jne       InpCChr8                 ; znak z bufferu je platn˜

; ------ obsluha TIME-OUT

         mov       dx,ds:[AdrPort]          ; adresa portu COM
InpCChr2:call      TestTOut                 ; test TIME-OUT

; ------ na‡ten¡ stavov‚ho registru COM

         add       dx,5                     ; stavov˜ registr linky
         in        al,dx                    ; na‡ten¡ stavov‚ho registru
         sub       dx,5                     ; datov˜ registr COM
         mov       ah,al                    ; AH <- £schova stavov‚ho registru

; ------ test, zda je vys¡lac¡ registr COM pr zdn˜

         test      al,20h                   ; je vys¡lac¡ registr pr zdn˜ ?
         jz        InpCChr4                 ; vys¡lac¡ registr nen¡ pr zdn˜

; ------ vysl n¡ znaku v˜zvy na port

         mov       al,VYZVA                 ; znak v˜zvy pro vysl n¡ zpr vy
         out       dx,al                    ; vysl n¡ znaku na port COM

; ------ test, zda je p©ijat nˆjak˜ znak

InpCChr4:test      ah,1                     ; je p©ipraven znak ?
         jz        InpCChr2                 ; znak nen¡ p©ipraven

; ------ na‡ten¡ p©ijat‚ho znaku

         in        al,dx                    ; na‡ten¡ p©ijat‚ho znaku z COM
         and       al,1111b                 ; nulov n¡ nepot©ebn˜ch bit–

; ------ n vrat registr–

InpCChr8:pop       dx
         ret

InpCChr  ENDP

; -----------------------------------------------------------------------------
;        test p©ete‡en¡ TIME-OUT (p©i TIME-OUT se program p©eru¨¡)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        uchov v  registr p©¡znak– !
; -----------------------------------------------------------------------------

TestTOut PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax
         push      dx

; ------ test u‘ivatelsk‚ho p©eru¨en¡ z kl vesnice Ctrl-Break

         sti                                ; p©eru¨en¡ mus¡ b˜t povoleno
         mov       ah,0bh
         int       21h                      ; obsluha p©eru¨en¡ Ctrl-Break

; ------ uplynul˜ ‡as od po‡ tku bˆhu programu

         call      GetBTime                 ; na‡ten¡ syst‚mov‚ho ‡¡ta‡e ‡asu
         sub       ax,word ptr ds:[OldBTime] ; dosud uplynul˜ ‡as
         sbb       dx,word ptr ds:[OldBTime+2]
         jnc       TestTOu2                 ; nen¡ p©ete‡en¡ p©es p–lnoc

; ------ oprava p©i p©echodu p©es p–lnoc

         mov       word ptr ds:[OldBTime],0 ; inicializace po‡ te‡n¡ho ‡asu
         mov       word ptr ds:[OldBTime+2],0
         call      GetBTime                 ; na‡ten¡ nov‚ho ‡asu

; ------ kontrola, zda ji‘ ubˆhl ‡as pro TIME-OUT

TestTOu2:or        dx,dx                    ; je p©ete‡en¡ ‡asu ?
         jnz       TestTOu4                 ; je p©ete‡en¡ ‡asu
         cmp       ax,TIMEOUT+1             ; ‡as pro TIME-OUT
         jb        TestTOu9                 ; nen¡ je¨tˆ TIME-OUT

; ------ je TIME-OUT p©¡jmu zpr vy

TestTOu4:mov       dx,ds:[AdrTOut]          ; text hl ¨en¡ chyby
         jmp       Chyba                    ; chybov˜ n vrat z programu

; ------ n vrat registr–

TestTOu9:pop       dx
         pop       ax
         popf
         ret

TestTOut ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡asu ze syst‚mov‚ho ‡¡ta‡e BIOS
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=syst‚mov˜ ‡¡ta‡ ‡asu BIOS (‡¡t  po p©¡rustc¡ch asi 55 ms)
; -----------------------------------------------------------------------------

GetBTime PROC      NEAR

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; syst‚mov˜ ‡¡ta‡ ‡asu LOW
         mov       dx,ds:[46ch+2]           ; syst‚mov˜ ‡¡ta‡ ‡asu HIGH
         pop       ds
         ret

GetBTime ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

AdrTOut  dw        TOutTxt                  ; adresa hl ¨en¡ pro TIME-OUT

HelpTxt  db        'DCFA v1.0 - nastaveni presneho casu; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr programu cislo portu COM 1 az 4 !',13,10
         db        '$'

TOutTxt  db        'Chyba TIME-OUT: Zkontrolujte pripojeni jednotky casu k portu COM'
TOutTxt1 db        '1: !',13,10,'$'
StruTxt  db        'Chyba TIME-OUT: Chybna struktura dat od jednotky casu !',13,10,'$'
COMTxt   db        'Zvoleny port COM'
COMTxt1  db        '1: neni pritomen !',13,10,'$'

; ------ text pro hl ¨en¡ p©i operaci OK

DatTxt   db        'Datum: '
DatTxtD  db        ' 1.'
DatTxtM  db        ' 1.'
DatTxtR  db        '0000, cas: '
DatTxtH  db        ' 1:'
DatTxtMI db        '00:'
DatTxtS  db        '00'
         db        13,10,'$'

; ------ data k na‡ten¡ (zachovat po©ad¡ !)
; Struktura jedn‚ polo‘ky (d‚lka polo‘ky 8 bajt–):
;            0: (2) na‡ten  hodnota
;            2: (2) minim ln¡ hodnota
;            4: (2) maxim ln¡ hodnota
;            6: (2) po‡et ‡¡slic polo‘ky

TabDat   label     byte
Rok      dw        0,1980,2100,4            ; rok
Mesic    dw        0,1,12,2                 ; mˆs¡c
Den      dw        0,1,31,2                 ; den
Hodina   dw        0,0,23,2                 ; hodina
Minuta   dw        0,0,59,2                 ; minuta
Sekunda  dw        0,0,59,2                 ; sekunda
TabDat0  label     byte

OldBTime dd        0                        ; uschovan˜ ‡as po‡ tku pro TIME-OUT

AdrPort  dw        0                        ; adresa portu COM
BuffChr  db        -1                       ; uschovan˜ navr cen˜ p©ijat˜ znak
                                            ;   -1 = p©¡znak, ‘e nen¡ znak

Code     ENDS
         END       Start

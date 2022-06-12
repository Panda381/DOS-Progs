
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                          QTIME v 1.0 (c) Miroslav Nˆme‡ek
;                             nastaven¡ p©esn‚ho ‡asu
;
; Pozn mka: Je nutn  aktivace vys¡l n¡ ‡asu ? Klidnˆ by to mohlo vys¡lat
;           nep©etr‘itˆ bez v˜zvy - u¨et©il by se vys¡lac¡ dr t
;           (programu je to jedno)
;
; Jsou na‡¡t ny i setiny sekundy kv–li kompatibilitˆ s p©¡padn˜mi p©¡¨t¡mi
; verzemi ‡asov‚ jednotky - posta‡¡, kdy‘ se budou vys¡lat 2 nuly.
; -----------------------------------------------------------------------------
; Ovl d n¡ editoru KONTEXT:
;
;   Ctrl-F1 .......... zdrojov˜ text programu QTIME
;                         F10 ... ulo‘en¡ textu na disk (+ ENTER = konec)
;   Ctrl-F2 .......... n povˆda k port–m COM
;   Ctrl-F3 .......... n povˆda k ovl d n¡ data a ‡asu pomoc¡ DOS
;   Alt-F8 ........... nastaven¡ zna‡ky v textu
;   Alt-F9/Alt-F10 ... p©ede¨l /n sleduj¡c¡ zna‡ka
;   ESC .............. menu programu KONTEXT
;   F9 ............... definice makrokl vesy programu KONTEXT
; -----------------------------------------------------------------------------
; Komunika‡n¡ protokol:
;
;   1.- Program vys¡l  na port COM znak v˜zvy VYZVA (nap©. "?") a‘
;       do chv¡le, dokud nep©ijme synchroniza‡n¡ znak SYNCHRO (nap©. "=")
;   2.- Ignoruje p©¡padn‚ dal¨¡ znaky "SYNCHRO".
;   3.- P©ij¡m  text zpr vy - 16 ‡¡slic v po©ad¡:   RRRRMMDDhhmmssxx
;        (RRRR=rok/MM=mˆs¡c/DD=den/hh=hodina/mm=minuta/ss=sekunda/xx=setina)
;   5.- P©i neplatn‚ zpr vˆ se pokou¨¡ o nov˜ p©enos a‘ do doby TIME-OUT
;
; Komunika‡n¡ znaky jsou voleny tak, ‘e je lze k¢dovat 4-bitovˆ (je mo‘n‚ pou‘¡t
; p©enos i pomoc¡ 4 bit– paraleln¡ho portu).
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; ------ nastaven¡ parametr– programu

VYZVA    EQU       "?"                      ; znak v˜zvy pro vysl n¡ zpr vy
SYNCHRO  EQU       "="                      ; synchroniza‡n¡ znak p©ed zpr vou
                                            ; (je mo‘n‚ vyslat i v¡ce ne‘ 1)

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

; ------ adresa portu COM

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
         sub       ax,1                     ; mal  korekce pro p©¡pad, ‘e ‡¡ta‡
         sbb       dx,0                     ;   je zastaven a cykluje +1-1+1-1
         mov       word ptr ds:[OldBTime],ax ; £schova po‡ te‡n¡ho ‡asu LOW
         mov       word ptr ds:[OldBTime+2],dx ; £schova po‡ te‡n¡ho ‡asu HIGH

; ------ obsluha TIME-OUT

Prijem1: call      TestTOut                 ; test TIME-OUT

; ------ test, zda je

Prijem2:












; ------ vysl n¡ v˜zvy k vysl n¡ zpr vy

Prijem1: mov       al,VYZVA                 ; znak v˜zvy k vysl n¡
         call      OutCChr                  ; vysl n¡ znaku v˜zvy na port

; ------ ‡ek n¡ na synchroniza‡n¡ znak

         call      InpCChr                  ; p©¡jem znaku
         cmp       al,SYNCHRO               ; je synchroniza‡n¡ znak ?
         jne       Prijem1                  ; ‡ek n¡ na synchroniza‡n¡ znak

; ------ vypu¨tˆn¡ dal¨¡ch synchroni


; ------ p©¡jem dat

         mov       si,offset TabDat         ; tabulka dat k p©¡jmu
Prijem2: mov       cx,ds:[si+6]             ; po‡et ‡¡slic polo‘ky
         call      InpCNum                  ; na‡ten¡ ‡¡sla
         jc        Prijem1                  ; chyba
         cmp       ax,ds:[si+2]             ; minim ln¡ hodnota polo‘ky
         jb        Prijem1                  ; chyba
         cmp       ax,ds:[si+4]             ; maxim ln¡ hodnota polo‘ky
         ja        Prijem1                  ; chyba
         mov       ds:[si],ax               ; ulo‘en¡ na‡ten‚ hodnoty
         add       si,8                     ; dal¨¡ polo‘ka
         cmp       si,offset TabDat0        ; je konec tabulky ?
         jb        Prijem2                  ; nen¡ je¨tˆ konec tabulky

; ------ nastaven¡ syst‚mov‚ho ‡asu (je p©ed datem, aby to bylo p©esnˆji)

         mov       ah,2ch                   ; slu‘ba pro nastaven¡ ‡asu
         mov       ch,byte ptr ds:[Hodina]  ; hodina
         mov       cl,byte ptr ds:[Minuta]  ; minuta
         mov       dh,byte ptr ds:[Sekunda] ; sekunda
         mov       dl,byte ptr ds:[Setina]  ; setina sekundy
         int       21h                      ; nastaven¡ syst‚mov‚ho ‡asu

; ------ nastaven¡ syst‚mov‚ho data

         mov       ah,2bh                   ; slu‘ba pro nastaven¡ data
         mov       cx,ds:[Rok]              ; rok
         mov       dh,byte ptr ds:[Mesic]   ; mˆs¡c
         mov       dl,byte ptr ds:[Den]     ; den
         int       21h                      ; nastaven¡ syst‚mov‚ho data

; ------ konec programu

         mov       ax,4c00h                 ; n vratov˜ k¢d 0 = operace OK
         int       21h

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
         cmp       al,"0"                   ; je to platn  ‡¡slice ?
         jb        InpCNm2                  ; nen¡ to platn  ‡¡slice
         cmp       al,"9"                   ; je to platn  ‡¡slice ?
         ja        InpCNm2                  ; nen¡ to platn  ‡¡slice
         sub       al,"0"                   ; korekce na bin rn¡ ‡¡slici
         ret

InpCNm2: call      RetCChr                  ; navr cen¡ znaku do bufferu
         stc                                ; p©¡znak - neplatn  ‡¡slice
         ret

InpCNm   ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ neplatn‚ho p©ijat‚ho znaku do bufferu
; -----------------------------------------------------------------------------

RetCChr  PROC      NEAR

         mov       ds:[BuffChr],al          ; navr cen¡ znaku do bufferu
         ret

RetCChr  ENDP

; -----------------------------------------------------------------------------
;        p©¡jem znaku z portu COM (5 bit–)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: AL=p©ijat˜ znak z COM (bity 5, 6 a 7 jsou vynulovan‚)
;         neuchov v  obsah registru AH !
; -----------------------------------------------------------------------------

InpCChr  PROC      NEAR

; ------ £schova registr–

         push      dx

; ------ na‡ten¡ znaku z bufferu

         mov       al,0                     ; p©¡znak neplatnosti znaku
         xchg      al,ds:[BuffChr]          ; na‡ten¡ znaku z bufferu
         or        al,al                    ; je znak z bufferu platn˜ ?
         jnz       InpCChr8                 ; znak z bufferu je platn˜

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
         and       al,3fh                   ; maskov n¡ p©¡p. paritn¡ch bit–

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

TestTOu4:mov       dx,offset TOutTxt        ; text hl ¨en¡ chyby
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

HelpTxt  db        'QTIME v1.0 - nastaveni presneho casu; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr programu cislo portu COM 1 az 4 !',13,10
         db        '$'

TOutTxt  db        'Chyba TIME-OUT: Zkontrolujte pripojeni jednotky k portu COM'
TOutTxt1 db        '1: !',13,10,'$'
COMTxt   db        'Zvoleny port COM'
COMTxt1  db        '1: neni pritomen !',13,10,'$'

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
Minuta   dw        0,0,63,2                 ; minuta
Sekunda  dw        0,0,63,2                 ; sekunda
Setina   dw        0,0,99,2                 ; setina sekundy
TabDat0  label     byte

OldBTime dd        0                        ; uschovan˜ ‡as po‡ tku pro TIME-OUT

AdrPort  dw        0                        ; adresa portu COM
BuffChr  db        0                        ; uschovan˜ navr cen˜ p©ijat˜ znak

Code     ENDS
         END       Start

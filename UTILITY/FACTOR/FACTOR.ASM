
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                  FACTOR v1.0
;                             (c) Miroslav Nˆme‡ek
;
; Program po‡¡t  faktori l zadan‚ho ‡¡sla N. Faktori l N! je n sobek ‡¡sel
; 1*2*3*4*5*6* .... *(N-2)*(N-1)*N. N soben¡ se v programu prov d¡ zdola
; (od nejni‘¨¡ch ‡¡sel) radˆji ne‘ shora, aby ‡¡slo bylo del¨¡ dobu krat¨¡.
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

MAXBUFF  EQU       17000                    ; velikost bufferu pro v˜po‡et

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©¡prava k na‡ten¡ parametru

Start:   mov       si,81h                   ; SI <- za‡ tek p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; CX <- d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld

; ------ na‡ten¡ znaku parametru

Start1:  jcxz      Start2                   ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–

; ------ mezera a tabul tor se ignoruje

         cmp       al," "                   ; je mezera nebo tabul tor ?
         jbe       Start1                   ; nezera a tabul tor se ignoruje

; ------ konverze na ‡¡slo

         sub       al,"0"                   ; konverze na ‡¡slo
         jb        Chyba                    ; chybn˜ znak
         cmp       al,9
         ja        Chyba                    ; nen¡ platn  ‡¡slice

; ------ vyn soben¡ st©ada‡e zadan‚ho ‡¡sla 10x

         push      ax
         mov       ax,10                    ; n sobek
         mul       word ptr ds:[Cislo]      ; vyn soben¡ st©ada‡e ‡¡sla * 10
         pop       bx                       ; BL <- na‡ten‚ ‡¡slo
         mov       bh,0                     ; BX <- na‡ten‚ ‡¡slo
         add       ax,bx                    ; p©i‡ten¡ ‡¡slice ke st©ada‡i
         mov       ds:[Cislo],ax            ; ulo‘en¡ nov‚ho ‡¡sla

; ------ test p©ete‡en¡ zadan‚ho ‡¡sla

         adc       dx,dx                    ; je p©ete‡en¡ zad n¡ ‡¡sla ?
         jz        Start1                   ; zad n¡ je zat¡m OK

; ------ chyba zad n¡ ‡¡sla

Chyba:   mov       dx,offset HelpTxt        ; text chyby
Chyba2:  mov       ah,9
         int       21h                      ; zobrazen¡ textu chyby
         int       20h

; ------ test platnosti zad n¡ ‡¡sla

Start2:  cmp       word ptr ds:[Cislo],0    ; bylo nˆco zad no ?
         je        Chyba                    ; nebylo nic zad no
         cmp       word ptr ds:[Cislo],11300 ; zad no platn‚ ‡¡slo ?
         ja        Chyba                    ; p©ete‡en¡

; ------ zobrazen¡ indik toru operace

Start3:  call      Indik                    ; zobrazen¡ indik toru operace

; ------ zv˜¨en¡ ‡¡sla n sobku

         inc       word ptr ds:[Nasobek]    ; zv˜¨en¡ n sobku ‡¡sla
         dec       word ptr ds:[Cislo]      ; sn¡‘en¡ ‡¡ta‡e ‡¡sel
         jz        Start6                   ; nen¡ dal¨¡ ‡¡slo

; ------ p©¡prava k vyn soben¡ st©ada‡e dal¨¡m ‡¡slem (DS=ES=CS !)

         mov       bx,ds:[Nasobek]          ; n sobek ‡¡sla
         mov       cx,ds:[Platne]           ; po‡et platn˜ch slov ve st©ada‡i
         mov       si,offset Buffer         ; buffer ‡¡sla
         mov       di,si                    ; DI <- buffer ‡¡sla
         xor       bp,bp                    ; BP <- 0 nen¡ p©enos
         cld                                ; smˆr nahoru

; ------ vyn soben¡ st©ada‡e ‡¡slem n sobku

Start4:  lodsw                              ; na‡ten¡ ‡¡sla ze st©ada‡e
         mul       bx                       ; vyn soben¡ n sobkem
         add       ax,bp                    ; p©enos z p©ede¨l‚ho n soben¡
         adc       dx,0                     ; p©enos
         stosw                              ; ulo‘en¡ n sobku
         mov       bp,dx                    ; BP <- £schova p©enosu
         loop      Start4                   ; dal¨¡ slovo

; ------ zv˜¨en¡ d‚lky ‡¡sla

         or        dx,dx                    ; zbyl nˆjak˜ p©enos ‡¡sla ?
         jz        Start3                   ; nezbyl p©enos - dal¨¡ n sobek
         xchg      ax,dx                    ; AX <- p©enos
         stosw                              ; ulo‘en¡ p©enosu
         inc       word ptr ds:[Platne]     ; zv˜¨en¡ po‡tu platn˜ch slov

; ------ test p©ete‡en¡ bufferu

         cmp       word ptr ds:[Platne],MAXBUFF/2 ; je p©ete‡en¡ bufferu ?
         jbe       Start3                   ; nen¡ je¨tˆ p©ete‡en¡
Start5:  mov       dx,offset PretTxt        ; text hl ¨en¡
         jmp       short Chyba2             ; chyba p©ete‡en¡

; ------ p©¡prava k dek¢dov n¡ ‡¡sla do tiskov‚ho bufferu

Start6:  mov       di,offset BuffTsk0-1     ; konec tiskov‚ho bufferu - 1

; ------ zobrazen¡ indik toru operace

Start7:  call      Indik                    ; zobrazen¡ indik toru

; ------ p©¡prava k vydˆlen¡ ‡¡sla v bufferu ‡¡slem 10

         mov       cx,ds:[Platne]           ; po‡et platn˜ch slov ve st©ada‡i
         mov       si,offset Buffer-2       ; buffer s ‡¡slem
         add       si,cx
         add       si,cx                    ; posledn¡ slovo v bufferu
         xor       dx,dx                    ; DX <- 0 nen¡ zbytek
         mov       bx,10                    ; dˆlitel ‡¡sla

; ------ zkr cen¡ ‡¡sla

         cmp       word ptr ds:[si],0       ; je posledn¡ slovo = 0 ?
         jne       Start8                   ; nen¡ = 0
         dec       si
         dec       si                       ; sn¡‘en¡ adresy konce
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e d‚lky
         dec       word ptr ds:[Platne]     ; sn¡‘en¡ platn‚ d‚lky ‡¡sla
         jz        Start9                   ; nen¡ ji‘ ‡¡slo

; ------ vydˆlen¡ ‡¡sla ‡¡slem 10

Start8:  std                                ; smˆr dol–
         push      di
         mov       di,si                    ; DI <- t‚‘ ukl dac¡ adresa
Start82: lodsw                              ; na‡ten¡ slova
         div       bx                       ; vydˆlen¡ ‡¡slem 10
         stosw                              ; ulo‘en¡ pod¡lu
         loop      Start82                  ; dal¨¡ slovo
         pop       di

; ------ ulo‘en¡ ‡¡slice do bufferu ‡¡sla (nastaven smˆr dol– STD)

         xchg      ax,dx                    ; AX <- zbytek po dˆlen¡
         add       al,"0"                   ; konverze na ASCII znak
         stosb                              ; ulo‘en¡ znaku do bufferu
         cmp       di,offset BuffTisk       ; je p©ete‡en¡ bufferu ?
         jae       Start7                   ; nen¡ p©ete‡en¡ - dal¨¡ ‡¡slice
         jmp       short Start5             ; je p©ete‡en¡ bufferu

; ------ zobrazen¡ v˜sledku

Start9:  inc       di                       ; n vrat na za‡ tek ‡¡sla
         mov       dx,di                    ; DX <- text ‡¡sla
         mov       ah,9
         int       21h                      ; zobrazen¡ ‡¡sla
         int       20h

; -----------------------------------------------------------------------------
;        obsluha zobrazen¡ indik toru operace (t‚‘ pro p©eru¨en¡ Ctrl-Break)
; -----------------------------------------------------------------------------

Indik    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      es

; ------ zji¨tˆn¡ ubˆhl‚ho ‡asu

         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[46ch]             ; syst‚mov˜ ‡asova‡
         sub       ax,ds:[IndikTim]         ; ubˆhl˜ ‡as

; ------ test, zda je pot©eba zobrazit indik tor

         cmp       ax,2                     ; po‡et impuls– ‡asova‡e
         jbe       Indik9                   ; nen¡ je¨tˆ pot©eba zobrazen¡
         add       ds:[IndikTim],ax         ; £schova nov‚ho ‡asova‡e

; ------ test p©eru¨en¡ operace Ctrl-Break

         mov       ah,0bh
         int       21h                      ; test kl vesnice pro Ctrl-Break

; ------ zobrazen¡ indik toru operace (na chybov‚ za©¡zen¡ kv–li p©esmˆrov n¡)

         push      bx
         push      cx
         push      dx

         mov       dx,offset IndikTxt       ; text indik toru
         mov       ah,40h                   ; funkce z pisu
         mov       cx,3                     ; 3 znaky
         mov       bx,2                     ; identifik tor chybov‚ho za©¡zen¡
         int       21h                      ; zobrazen¡ indik toru

         pop       dx
         pop       cx
         pop       bx

; ------ posun indik toru pro p©¡¨tˆ

         mov       al,ds:[IndikTxt+1]       ; sou‡asn˜ znak indik toru

         mov       ah,"-"
         cmp       al,"/"
         je        Indik4

         mov       ah,"\"
         cmp       al,"-"
         je        Indik4

         mov       ah,"|"
         cmp       al,"\"
         je        Indik4

         mov       ah,"/"

Indik4:  mov       ds:[IndikTxt+1],ah       ; nov˜ znak indik toru

; ------ n vrat registr–

Indik9:  pop       es
         pop       ax
         ret

Indik    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Cislo    dw        0                        ; zadan‚ ‡¡slo k n soben¡
Nasobek  dw        1                        ; n sobek ‡¡sla

Platne   dw        1                        ; po‡et platn˜ch slov ve st©ada‡i

IndikTxt db        13,'/',13                ; indik tor operace
IndikTim dw        0                        ; uschovan˜ ‡as minul‚ indikace

PretTxt  db        'Preteceni !',13,10,'$'

HelpTxt  db        'FACTOR v1.0 - vypocet faktorialu; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr cislo 1 az 11300 k vypoctu !',13,10
         db        'Prikaz "FACTOR cislo > soubor" ulozi vysledek do souboru.',13,10
         db        '$'

Buffer   db        1,MAXBUFF-1 dup(0),0,0   ; buffer st©ada‡e ‡¡sla (+2 rezerva)
BuffTisk db        (MAXBUFF*25)/10 dup(0)   ; buffer pro dek¢dov n¡ ‡¡sla
BuffTsk0 db        13,10,'$'

Code     ENDS
         END       Start

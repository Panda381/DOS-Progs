
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                                  FACTOR v1.0
;                             (c) Miroslav N늤e놽k
;
; Program po눀t� faktori쟫 zadan괿o 눀sla N. Faktori쟫 N! je n쟳obek 눀sel
; 1*2*3*4*5*6* .... *(N-2)*(N-1)*N. N쟳oben� se v programu prov쟡� zdola
; (od nejni뫅죅h 눀sel) rad늞i ne� shora, aby 눀slo bylo delÆ dobu kratÆ.
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

MAXBUFF  EQU       17000                    ; velikost bufferu pro v쁯o놽t

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ pæprava k na뇍en� parametru

Start:   mov       si,81h                   ; SI <- za뇿tek pækazov괿o 찤dku
         mov       cl,ds:[si-1]             ; CX <- d굃ka pækazov괿o 찤dku
         mov       ch,0
         cld

; ------ na뇍en� znaku parametru

Start1:  jcxz      Start2                   ; nen� dalÆ znak
         lodsb                              ; na뇍en� znaku
         dec       cx                       ; sn죷en� 눀ta놽 znak�

; ------ mezera a tabul쟴or se ignoruje

         cmp       al," "                   ; je mezera nebo tabul쟴or ?
         jbe       Start1                   ; nezera a tabul쟴or se ignoruje

; ------ konverze na 눀slo

         sub       al,"0"                   ; konverze na 눀slo
         jb        Chyba                    ; chybn� znak
         cmp       al,9
         ja        Chyba                    ; nen� platn� 눀slice

; ------ vyn쟳oben� st쯠da놽 zadan괿o 눀sla 10x

         push      ax
         mov       ax,10                    ; n쟳obek
         mul       word ptr ds:[Cislo]      ; vyn쟳oben� st쯠da놽 눀sla * 10
         pop       bx                       ; BL <- na뇍en� 눀slo
         mov       bh,0                     ; BX <- na뇍en� 눀slo
         add       ax,bx                    ; p쯫뇍en� 눀slice ke st쯠da뇁
         mov       ds:[Cislo],ax            ; ulo멷n� nov괿o 눀sla

; ------ test p쯥te놽n� zadan괿o 눀sla

         adc       dx,dx                    ; je p쯥te놽n� zad쟮� 눀sla ?
         jz        Start1                   ; zad쟮� je zat죑 OK

; ------ chyba zad쟮� 눀sla

Chyba:   mov       dx,offset HelpTxt        ; text chyby
Chyba2:  mov       ah,9
         int       21h                      ; zobrazen� textu chyby
         int       20h

; ------ test platnosti zad쟮� 눀sla

Start2:  cmp       word ptr ds:[Cislo],0    ; bylo n늓o zad쟮o ?
         je        Chyba                    ; nebylo nic zad쟮o
         cmp       word ptr ds:[Cislo],11300 ; zad쟮o platn� 눀slo ?
         ja        Chyba                    ; p쯥te놽n�

; ------ zobrazen� indik쟴oru operace

Start3:  call      Indik                    ; zobrazen� indik쟴oru operace

; ------ zv삩en� 눀sla n쟳obku

         inc       word ptr ds:[Nasobek]    ; zv삩en� n쟳obku 눀sla
         dec       word ptr ds:[Cislo]      ; sn죷en� 눀ta놽 눀sel
         jz        Start6                   ; nen� dalÆ 눀slo

; ------ pæprava k vyn쟳oben� st쯠da놽 dalÆm 눀slem (DS=ES=CS !)

         mov       bx,ds:[Nasobek]          ; n쟳obek 눀sla
         mov       cx,ds:[Platne]           ; po놽t platn쁟h slov ve st쯠da뇁
         mov       si,offset Buffer         ; buffer 눀sla
         mov       di,si                    ; DI <- buffer 눀sla
         xor       bp,bp                    ; BP <- 0 nen� p쯥nos
         cld                                ; sm늭 nahoru

; ------ vyn쟳oben� st쯠da놽 눀slem n쟳obku

Start4:  lodsw                              ; na뇍en� 눀sla ze st쯠da놽
         mul       bx                       ; vyn쟳oben� n쟳obkem
         add       ax,bp                    ; p쯥nos z p쯥de쮔괿o n쟳oben�
         adc       dx,0                     ; p쯥nos
         stosw                              ; ulo멷n� n쟳obku
         mov       bp,dx                    ; BP <- 즧chova p쯥nosu
         loop      Start4                   ; dalÆ slovo

; ------ zv삩en� d굃ky 눀sla

         or        dx,dx                    ; zbyl n늞ak� p쯥nos 눀sla ?
         jz        Start3                   ; nezbyl p쯥nos - dalÆ n쟳obek
         xchg      ax,dx                    ; AX <- p쯥nos
         stosw                              ; ulo멷n� p쯥nosu
         inc       word ptr ds:[Platne]     ; zv삩en� po뇍u platn쁟h slov

; ------ test p쯥te놽n� bufferu

         cmp       word ptr ds:[Platne],MAXBUFF/2 ; je p쯥te놽n� bufferu ?
         jbe       Start3                   ; nen� je쮝� p쯥te놽n�
Start5:  mov       dx,offset PretTxt        ; text hl젴en�
         jmp       short Chyba2             ; chyba p쯥te놽n�

; ------ pæprava k dek줰ov쟮� 눀sla do tiskov괿o bufferu

Start6:  mov       di,offset BuffTsk0-1     ; konec tiskov괿o bufferu - 1

; ------ zobrazen� indik쟴oru operace

Start7:  call      Indik                    ; zobrazen� indik쟴oru

; ------ pæprava k vyd늢en� 눀sla v bufferu 눀slem 10

         mov       cx,ds:[Platne]           ; po놽t platn쁟h slov ve st쯠da뇁
         mov       si,offset Buffer-2       ; buffer s 눀slem
         add       si,cx
         add       si,cx                    ; posledn� slovo v bufferu
         xor       dx,dx                    ; DX <- 0 nen� zbytek
         mov       bx,10                    ; d늢itel 눀sla

; ------ zkr쟠en� 눀sla

         cmp       word ptr ds:[si],0       ; je posledn� slovo = 0 ?
         jne       Start8                   ; nen� = 0
         dec       si
         dec       si                       ; sn죷en� adresy konce
         dec       cx                       ; sn죷en� 눀ta놽 d굃ky
         dec       word ptr ds:[Platne]     ; sn죷en� platn� d굃ky 눀sla
         jz        Start9                   ; nen� ji� 눀slo

; ------ vyd늢en� 눀sla 눀slem 10

Start8:  std                                ; sm늭 dol�
         push      di
         mov       di,si                    ; DI <- t굫 ukl쟡ac� adresa
Start82: lodsw                              ; na뇍en� slova
         div       bx                       ; vyd늢en� 눀slem 10
         stosw                              ; ulo멷n� pod죐u
         loop      Start82                  ; dalÆ slovo
         pop       di

; ------ ulo멷n� 눀slice do bufferu 눀sla (nastaven sm늭 dol� STD)

         xchg      ax,dx                    ; AX <- zbytek po d늢en�
         add       al,"0"                   ; konverze na ASCII znak
         stosb                              ; ulo멷n� znaku do bufferu
         cmp       di,offset BuffTisk       ; je p쯥te놽n� bufferu ?
         jae       Start7                   ; nen� p쯥te놽n� - dalÆ 눀slice
         jmp       short Start5             ; je p쯥te놽n� bufferu

; ------ zobrazen� v쁲ledku

Start9:  inc       di                       ; n쟶rat na za뇿tek 눀sla
         mov       dx,di                    ; DX <- text 눀sla
         mov       ah,9
         int       21h                      ; zobrazen� 눀sla
         int       20h

; -----------------------------------------------------------------------------
;        obsluha zobrazen� indik쟴oru operace (t굫 pro p쯥ru쮍n� Ctrl-Break)
; -----------------------------------------------------------------------------

Indik    PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      es

; ------ zji쮝늧� ub늜l괿o 놹su

         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[46ch]             ; syst굆ov� 놹sova�
         sub       ax,ds:[IndikTim]         ; ub늜l� 놹s

; ------ test, zda je pot쯥ba zobrazit indik쟴or

         cmp       ax,2                     ; po놽t impuls� 놹sova놽
         jbe       Indik9                   ; nen� je쮝� pot쯥ba zobrazen�
         add       ds:[IndikTim],ax         ; 즧chova nov괿o 놹sova놽

; ------ test p쯥ru쮍n� operace Ctrl-Break

         mov       ah,0bh
         int       21h                      ; test kl쟶esnice pro Ctrl-Break

; ------ zobrazen� indik쟴oru operace (na chybov� zaæzen� kv뻦i p쯥sm늭ov쟮�)

         push      bx
         push      cx
         push      dx

         mov       dx,offset IndikTxt       ; text indik쟴oru
         mov       ah,40h                   ; funkce z쟰isu
         mov       cx,3                     ; 3 znaky
         mov       bx,2                     ; identifik쟴or chybov괿o zaæzen�
         int       21h                      ; zobrazen� indik쟴oru

         pop       dx
         pop       cx
         pop       bx

; ------ posun indik쟴oru pro pæ쮝�

         mov       al,ds:[IndikTxt+1]       ; sou놹sn� znak indik쟴oru

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

Indik4:  mov       ds:[IndikTxt+1],ah       ; nov� znak indik쟴oru

; ------ n쟶rat registr�

Indik9:  pop       es
         pop       ax
         ret

Indik    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Cislo    dw        0                        ; zadan� 눀slo k n쟳oben�
Nasobek  dw        1                        ; n쟳obek 눀sla

Platne   dw        1                        ; po놽t platn쁟h slov ve st쯠da뇁

IndikTxt db        13,'/',13                ; indik쟴or operace
IndikTim dw        0                        ; uschovan� 놹s minul� indikace

PretTxt  db        'Preteceni !',13,10,'$'

HelpTxt  db        'FACTOR v1.0 - vypocet faktorialu; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr cislo 1 az 11300 k vypoctu !',13,10
         db        'Prikaz "FACTOR cislo > soubor" ulozi vysledek do souboru.',13,10
         db        '$'

Buffer   db        1,MAXBUFF-1 dup(0),0,0   ; buffer st쯠da놽 눀sla (+2 rezerva)
BuffTisk db        (MAXBUFF*25)/10 dup(0)   ; buffer pro dek줰ov쟮� 눀sla
BuffTsk0 db        13,10,'$'

Code     ENDS
         END       Start

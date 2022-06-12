
; *****************************************************************************
;
;                       T R A N S   -   C O M   0
;
;                 P©enos soubor– p©es s‚riov˜ port - ©¡dic¡ sign ly
;
; *****************************************************************************

path     equ       offset aktpath           ; pracovn¡ adres ©
path0    equ       path + 70                ; p–vodn¡ aktu ln¡ adres ©
konec    equ       path0 + 70               ; konec programu


code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

Start:
                                          ;* ur‡en¡ bloku pamˆti
         mov       bx,cs
         mov       ax,konec
         add       ax,15
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; offset konce programu
         add       ax,bx                    ; segment za koncem programu
         mov       ds:[segbuf],ax           ; segment datov‚ho bufferu

                                          ;* kontrola voln‚ pamˆti
         add       ax,1800h                 ; po‘adovan˜ segment konce pamˆti
         cmp       ax,ds:[2]                ; je dostate‡n  pamˆŸ ?
         jbe       Start0                   ; je dostatek pamˆti

                                          ;* nedostatek pamˆti
         mov       si,offset memtxt         ; text - chyba pamˆti
         call      DispTxt                  ; zobrazen¡ textu chyby
         mov       ax,4c01h
         int       21h                      ; n vrat s chybou

                                          ;* inicializace z sobn¡ku
Start0:  sub       ax,1000h                 ; segment pro z sobn¡k
         mov       ss,ax                    ; segment z sobn¡ku
         mov       sp,0fff0h                ; offset konce z sobn¡ku

                                          ;* instalace obsluhy INT 09h
         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[old09+2],es
         mov       ax,2509h
         mov       dx,offset int09
         int       21h                      ; instalace obsluhy INT 09h

                                          ;* zobrazen¡ £vodn¡ho textu
         mov       si,offset uvtxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

                                          ;* £schova aktivn¡ho adres ©e
         mov       si,path0+1               ; buffer pro £schovu akt. adres ©e
         mov       byte ptr ds:[si-1],"\"   ; inicializa‡n¡ znak adres ©e
         mov       ah,47h                   ; AH <- 47h
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e

                                          ;* definice obsluhy p©eru¨en¡ INT 23h
         mov       ax,2523h                 ; vektor p©eru¨en¡ Ctrl-Break
         mov       dx,offset Start9         ; obsluha p©eru¨en¡ INT 23h
         int       21h                      ; definice obsluhy p©eru¨en¡ INT 23h

                                          ;* na‡ten¡ aktivn¡ho adres ©e
         mov       si,path                  ; pracovn¡ adres ©
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         mov       ah,47h                   ; AH <- 47h
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e

                                          ;* ozna‡en¡ aktivn¡ho disku
         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         add       al,"A"                   ; korekce na p¡smeno ASCII
         mov       ds:[aktdisk],al          ; nastaven¡ ozna‡en¡ disku

; ------ dek¢dov n¡ zad n¡ z p©¡kazov‚ho © dku

                                          ;* p©¡prava registr– pro rozbor
         cld                                ; smˆr posunu ukazatele nahoru
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[80h]              ; d‚lka p©¡kazov‚ho © dku

                                          ;* test jednoho znaku z textu
Start1:  jcxz      Start4                   ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak– textu
         cmp       al,13                    ; je konec © dku CR ?
         je        Start4                   ; konec © dku
         cmp       al,9                     ; je tabel tor ?
         je        Start1                   ; je tabel tor - dal¨¡ znak
         cmp       al," "                   ; je mezera ?
         je        Start1                   ; je mezera - dal¨¡ znak

                                          ;* kontrola, zda je vys¡l n¡ soubor–
         cmp       al,"!"                   ; je vys¡l n¡ soubor– ?
         jne       Start2                   ; nen¡ vys¡l n¡ soubor–
         mov       byte ptr ds:[setvys],1   ; p©¡znak, ‘e je vys¡l n¡ soubor–
         mov       byte ptr ds:[subdirs],1  ; budou podadres ©e
         jmp       short Start1             ; dal¨¡ znak

                                          ;* kontrola, zda je vys¡l n¡ "*"
Start2:
         cmp       al,"*"                   ; je vys¡l n¡ soubor– ?
         jne       Start24                  ; nen¡ vys¡l n¡ soubor–
         mov       byte ptr ds:[setvys],1   ; p©¡znak, ‘e je vys¡l n¡ soubor–
         jmp       short Start1             ; dal¨¡ znak

                                          ;* kontrola, zda je ‡¡slo portu
start24: cmp       al,"1"                   ; je port LPT ?
         jb        Start22                  ; nen¡ platn‚ ‡¡slo portu LPT
         cmp       al,"4"                   ; je port LPT ?
         ja        Start22                  ; nen¡ platn‚ ‡¡slo portu LPT

                                          ;* platn‚ ozna‡en¡ portu LPT
         mov       ds:[porttxt0],al         ; port LPT pro zobrazen¡ chyby
         mov       ds:[vystxt0],al          ; port LPT pro vys¡l n¡
         mov       ds:[prijtxt0],al         ; port LPT pro p©ij¡m n¡
         jmp       short Start1             ; dal¨¡ znak

                                          ;* chybn‚ zad n¡ parametr–
Start22: mov       si,offset errtxt         ; chybov˜ text - chyba zad n¡
Start3:  jmp       Starta                   ; nen¡ platn‚ ‡¡slo portu LPT


; ------ p©¡prava ‡¡sla portu a inicializace portu LPT

                                          ;* test, zda je port LPT definov n
Start4:  xor       bx,bx                    ; BX <- 0
         push      ds                       ; £schova DS
         mov       ds,bx                    ; DS <- 0 segment dat BIOS
         mov       bl,cs:[porttxt0]         ; komunika‡n¡ port LPT
         sub       bl,"1"                   ; korekce na ‡¡slo portu LPT
         add       bx,bx                    ; ‡¡slo portu * 2
         mov       dx,ds:[bx+400h]          ; adresa portu COM
         pop       ds
         mov       ds:[adrport],dx          ; £schova adresy portu
         or        dx,dx                    ; je port nainstalov n ?
         mov       si,offset PortTxt        ; chybov˜ text - port nenainstalov n
         jz        Start3                   ; port nen¡ nainstalov n
         add       dx,3                     ; ©¡dic¡ registr linky
         mov       al,7                     ; 8 bit– bez parity
         out       dx,al                    ; inicializace ©¡dic¡ho registru

; ------ rozli¨en¡, zda je p©¡jem nebo vys¡l n¡

         cmp       byte ptr ds:[setvys],0   ; je p©¡jem soubor– ?
         je        Start6                   ; je p©¡jem soubor–

                                          ;* je vys¡l n¡ soubor–
         mov       si,offset vystxt         ; text pro vys¡l n¡
         call      DispTxt                  ; zobrazen¡ informace o vys¡l n¡

         call      SendDir                  ; vysl n¡ obsahu adres ©e

         mov       al,"Q"                   ; povel k p©eru¨en¡ spojen¡
         xor       cx,cx                    ; nejsou ‘ dn  data
         call      WritTxt                  ; vysl n¡ povelu pro ukon‡en¡

         jmp       short start8

                                          ;* je p©¡jem soubor–
Start6:  mov       si,offset prijtxt        ; text pro p©¡jem soubor–
         call      DispTxt                  ; zobrazen¡ informace o p©¡jmu

Start66: call      ReadTxt
         cmp       al,"D"                   ; zmˆna adres ©e ?
         jne       Start67
         call      ReadDir                  ; nastaven¡ nov‚ho adres ©e
         jc        StartEnd                 ; chyba nastaven¡ adres ©e
         jmp       short Start66

Start67:
         cmp       al,"O"                   ; je otev©en¡ souboru ?
         jne       Start68

         call      OpenFile                 ; otev©en¡ souboru
         jc        StartEnd                 ; chyba operace otev©en¡ souboru
         jmp       short Start66

Start68:
         cmp       al,"C"                   ; je uzav©en¡ souboru ?
         jne       Start69

         call      ClosFile
         jc        StartEnd                 ; chyba uzav©en¡ souboru
         jmp       short Start66

Start69:
         cmp       al,"W"
         jne       Start6a

         call      WritDat
         jc        StartEnd                 ; chyba operace z pisu
         jmp       short Start66

Start6a:
         cmp       al,"Q"                   ; p©eru¨en¡
         je        StartEnd                 ; ukon‡en¡ p©enosu

         jmp       start66



Start8:
         xor       al,al                    ; n vratov˜ k¢d pro operaci OK
         jmp       short StartEnd           ; n vrat z programu

                                          ;* p©eru¨en¡ operace INT 23h
Start9:  mov       si,offset BreakTxt       ; text p©eru¨en¡
Starta:  push      cs
         pop       ds
                                          ;* zabr nˆn¡ opakovan‚mu hl ¨en¡
         mov       ax,2523h                 ; vektor p©eru¨en¡ Ctrl-Break
         mov       dx,offset StartEnd       ; nov  obsluha p©eru¨en¡ INT 23h
         int       21h                      ; definice obsluhy p©eru¨en¡ INT 23h
                                          ;* zobrazen¡ chybov‚ho hl ¨en¡
         call      DispTxt                  ; zobrazen¡ textu
         mov       al,1                     ; n vratov˜ k¢d pro p©eru¨en¡

StartEnd:
         push      cs
         pop       ds

         mov       ax,ds:[citfile]          ; po‡et p©enesen˜ch soubor–
         mov       si,offset CRTxt-1        ; konec textu k ulo‘en¡ ‡¡sla
         call      DekNum                   ; dek¢dov n¡ ‡¡sla AX
         mov       si,offset PocetTxt       ; text - po‡et soubor–
         call      DispTxt                  ; zobrazen¡ textu

         push      ax                       ; £schova n vratov‚ho k¢du
         mov       dx,path0                 ; p–vodn¡ adres ©
         mov       ah,3bh
         int       21h                      ; n vrat p–vodn¡ho adres ©e

                                          ;* n vrat obsluhy INT 09h
         lds       dx,ds:[old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat adresy obsluhy INT 09h

         pop       ax                       ; n vrat n vratov‚ho k¢du

         mov       ah,4ch
         int       21h

int09:   push      bx
         push      ds
         mov       bx,40h
         mov       ds,bx
         mov       bx,ds:[1ch]
         pushf
         call      dword ptr cs:[old09]     ; p–vodn¡ obsluha INT 09h

         cmp       bx,ds:[1ch]
         je        int092
         mov       byte ptr cs:[parbreak],1 ; p©¡znak stisku kl vesy
int092:  pop       ds
         pop       bx
         iret

; -----------------------------------------------------------------------------
;        Zobrazen¡ jm‚na pracovn¡ho souboru DS:SI
; -----------------------------------------------------------------------------

ZobrFile PROC      NEAR

         push      ax
         push      si
         push      si
         push      ds
         push      cs
         pop       ds
         mov       si,offset aktdisk        ; aktu ln¡ disk a adres ©
         call      DispTxt                  ; zobrazen¡ textu disku
         mov       al,"\"
         cmp       ds:[si-2],al             ; byl posledn¡ znak "\" ?
         je        ZobrFil2                 ; posledn¡ znak byl "\"
         call      DispChar                 ; zobrazen¡ oddˆlovac¡ho znaku "\"
ZobrFil2:pop       ds
         pop       si
         call      DispTxt                  ; zobrazen¡ jm‚na souboru


         pop       si
         pop       ax
         ret

ZobrFile ENDP


; -----------------------------------------------------------------------------
;        Vysl n¡ obsahu aktivn¡ho adres ©e
; -----------------------------------------------------------------------------

PUBLIC   SendDir
SendDir  PROC      NEAR

                                          ;* £schova registr–
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es

                                          ;* na‡ten¡ aktivn¡ho adres ©e
         mov       si,path                  ; pracovn¡ adres ©
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         mov       ah,47h                   ; AH <- 47h
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e
         mov       si,offset dirtxt         ; chyba p©¡stupu k adres ©i
         jnc       Senddir0
         jmp       SendDira                 ; chyba na‡ten¡ adres ©e

                                          ;* nastaven¡ pracovn¡ adresy DTA
Senddir0:mov       dx,80h                   ; adresa pracovn¡ DTA
         mov       ah,1ah                   ; AH <- 1ah
         int       21h                      ; nastaven¡ DTA na adresu 80h

                                          ;* nalezen¡ prvn¡ho souboru v adres ©i
         mov       dx,offset all            ; specifikace - v¨echny soubory
         mov       cx,37h                   ; atributy - v¨echny soubory
         mov       ah,4eh                   ; AH <- 4eh
SendDir1:int       21h                      ; nalezen¡ prvn¡ho/dal¨¡ho souboru
         cmc
         jnc       SendDir9                 ; nenalezen dal¨¡ soubor

                                          ;* ignorov n¡ adres ©– s te‡kou
         cmp       word ptr ds:[9eh],"."    ; je adres © "." ?
         je        SendDir2                 ; je adres © "." - dal¨¡ adres ©
         cmp       word ptr ds:[9eh],".."   ; je adres © ".." ?
         je        SendDir2                 ; je adres © ".." - dal¨¡ adres ©

                                          ;* vysl n¡ souboru
         test      byte ptr ds:[95h],10h    ; byl nalezen adres © ?
         jnz       SendDir3                 ; byl nalezen adres ©
         call      SendFile                 ; vysl n¡ nalezen‚ho souboru
         jc        SendDir9                 ; chyba vysl n¡ souboru

SendDir2:mov       ah,4fh                   ; AH <- 4fh nalezen¡ dal¨¡ho souboru
         jmp       short SendDir1           ; nalezen¡ dal¨¡ho souboru

                                          ;* bude vysl n¡ podadres ©e

                                          ;* £schova tabulky DTA
SendDir3:cmp       byte ptr ds:[subdirs],0  ; lze vys¡lat podadres ©e ?
         je        SendDir2                 ; podadres ©e se nevys¡laj¡
         mov       cx,22                    ; po‡et slov k £schovˆ
         mov       si,80h                   ; za‡ tek tabulky k £schovˆ
         cld                                ; smˆr nahoru
SendDir4:lodsw                              ; na‡ten¡ slova z tabulky DTA
         push      ax                       ; £schova slova do z sobn¡ku
         loop      SendDir4                 ; £schova dal¨¡ho slova do z sobn¡ku

                                          ;* nastaven¡ nov‚ho aktivn¡ho adres ©e
         push      dx                       ; £schova DX
         mov       dx,9eh                   ; jm‚no nalezen‚ho adres ©e
         call      ChngDir                  ; zmˆna adres ©e
         jc        SendDir7                 ; chyba nastaven¡ adres ©e

                                          ;* vysl n¡ obsahu nov‚ho adres ©e
         call      SendDir                  ; vysl n¡ obsahu aktivn¡ho adres ©e
         jc        SendDir7                 ; byla chyba operace

                                          ;* n vrat p–vodn¡ho adres ©e
         mov       dx,offset subdir         ; specifikace podadres ©e
         call      ChngDir                  ; n vrat p–vodn¡ho adres ©e
         jc        SendDir7                 ; byla chyba operace

                                          ;* opˆtovn‚ na‡ten¡ aktivn¡ho adres ©e
         mov       si,path                  ; pracovn¡ adres ©
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         mov       ah,47h                   ; AH <- 47h
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e
         jnc       SendDir7                 ; operace OK

         mov       si,offset dirtxt         ; chyba p©¡stupu k adres ©i
         call      DispTxt

                                          ;* n vrat tabulky DTA
SendDir7:pop       dx                       ; n vrat DX

         pushf
         pop       si

         mov       cx,22                    ; po‡et slov k navr cen¡
         mov       di,80h+42                ; konec tabulky DTA
         std                                ; smˆr dol–
SendDir8:pop       ax                       ; n vrat slova ze z sobn¡ku
         stosw                              ; n vrat slova do tabulky DTA
         loop      SendDir8                 ; n vrat dal¨¡ho slova ze z sobn¡ku

         push      si
         popf

         jc        SendDir9                 ; byla chyba operace

         jmp       short SendDir2           ; nalezen¡ dal¨¡ho souboru

SendDira:call      DispTxt                  ; zobrazen¡ textu chyby
         stc                                ; p©¡znak chyby operace

SendDir9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SendDir  ENDP

; -----------------------------------------------------------------------------
;        Z pis dat do souboru
; -----------------------------------------------------------------------------

PUBLIC   WritDat

WritDat  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      ds

         mov       bx,cs:[ident]
         or        bx,bx
         jz        WritDat2

         mov       ds,cs:[segbuf]           ; segment s na‡ten˜m jm‚nem souboru
         xor       dx,dx                    ; offset specifikace souboru
         mov       cx,word ptr cs:[bufchar+1]
         mov       si,dx                    ; adresa dat v bufferu
         call      CheckSum                 ; kontroln¡ sou‡et bloku dat

         mov       ah,40h
         int       21h                      ; z pis do souboru
         mov       si,offset writetxt       ; chyba z pisu
         jc        WritDat1                 ; chyba z pisu
         cmp       ax,cx                    ; je disk pln˜ ?
         je        WritDat2                 ; z pis OK
         mov       si,offset fulltxt        ; disk je pln˜

                                          ;* chyba operace z pisu
WritDat1:call      DispTxt                  ; zobrazen¡ textu chyby

                                          ;* uzav©en¡ a zru¨en¡ souboru
         mov       ah,3eh
         int       21h
         push      cs
         pop       ds
         mov       ah,41h
         mov       dx,offset jmeno
         int       21h                      ; zru¨en¡ souboru

         stc                                ; p©¡znak chyby

WritDat2:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

WritDat  ENDP

; -----------------------------------------------------------------------------
;        Otev©en¡ souboru p©ijat‚ho jm‚na
; -----------------------------------------------------------------------------
; VSTUP: CY=chyba otev©en¡ souboru
; -----------------------------------------------------------------------------

PUBLIC   OpenFile

OpenFile PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         cmp       word ptr ds:[ident],0    ; je ji‘ soubor otev©en ?
         jne       OpenFil2                 ; nˆjak˜ soubor je ji‘ otev©en

                                          ;* £schova na‡ten˜ch parametr–
         push      cs
         pop       es
         mov       ds,cs:[segbuf]           ; segment s na‡ten˜m jm‚nem souboru
         xor       si,si
         mov       di,offset atrib
         cld
         mov       cx,22
         rep       movsb

                                          ;* nulov n¡ atribut– (existuje-li)
         push      cs
         pop       ds
         mov       dx,offset jmeno          ; offset specifikace souboru
         mov       ax,4301h
         xor       cx,cx                    ; po‘adovan‚ atributy
         int       21h                      ; nastaven¡ atribut– souboru

                                          ;* vytvo©en¡ souboru (neexistuje-li)
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ souboru
         jc        OpenFil1                 ; soubor nelze otev©¡t

         mov       ds:[ident],ax            ; identifik tor souboru
         mov       word ptr ds:[sum],-1     ; inicializace kontroln¡ho sou‡tu

         mov       si,offset jmeno          ; jm‚no souboru
         call      ZobrFile                 ; zobrazen¡ jm‚na souboru
         clc
         jmp       short OpenFil2

                                          ;* je chyba operace
OpenFil1:mov       si,offset opentxt        ; text - chyba otev©en¡ souboru
         call      DispTxt                  ; zobrazen¡ chybov‚ho textu
         stc

OpenFil2:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OpenFile ENDP

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
; -----------------------------------------------------------------------------

PUBLIC   CheckSum

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di

         jcxz      CheckSm2                 ; nen¡ ‘ dn˜ bajt
         mov       dx,cs:[sum]              ; ‡¡ta‡ kontroln¡ho sou‡tu
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
;         rol       dx,1
;         xor       dl,al

         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;


;         loop      CheckSm1

         dec       di
         jnz       CheckSm1                 ; dal¨¡ bajt
         mov       cs:[sum],dx              ; ‡¡ta‡ kontroln¡ho sou‡tu

CheckSm2:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

CheckSum ENDP

; -----------------------------------------------------------------------------
;        Uzav©en¡ souboru p©ijat‚ho jm‚na
; -----------------------------------------------------------------------------

PUBLIC   ClosFile

ClosFile PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds

         mov       bx,ds:[ident]
         or        bx,bx
         jz        ClosFil4

                                          ;* nastaven¡ data a ‡asu souboru
         mov       cx,ds:[cas]              ; ‡as souboru
         mov       dx,ds:[datum]            ; datum souboru
         mov       ax,5701h
         int       21h                      ; nastaven¡ data a ‡asu souboru
         mov       si,offset clostxt        ; text chyby uzav©en¡ souboru
         jc        ClosFil3                 ; chyba uzav©en¡ souboru

                                          ;* uzav©en¡ souboru
         mov       ah,3eh
         int       21h
         jc        ClosFil3                 ; chyba uzav©en¡ souboru

         mov       dx,offset jmeno
         mov       ax,4301h
         xor       cx,cx
         mov       cl,ds:[atrib]            ; atributy souboru
         int       21h                      ; nastaven¡ atribut– souboru

         mov       word ptr ds:[ident],0
         jc        ClosFil3                 ; chyba p©i nastaven¡ atribut–

                                          ;* kontrola kontroln¡ho sou‡tu
         push      ds
         mov       ax,ds:[sum]              ; vypo‡ten˜ kontroln¡ sou‡et
         mov       ds,ds:[segbuf]           ; segment s na‡ten˜m adres ©em
         cmp       ax,ds:[0]                ; je kontroln¡ sou‡et OK ?
         pop       ds
         mov       si,offset chsumtxt       ; text - chyba p©enosu souboru
         stc
         jne       ClosFil3                 ; chyba kontroln¡ho sou‡tu
         clc                                ; p©¡znak operace OK

ClosFil2:inc       word ptr ds:[citfile]    ; zv˜¨en¡ ‡¡ta‡e p©enesen˜ch soubor–

                                          ;* od© dkov n¡
ClosFil3:push      si
         mov       si,offset CRTxt          ; text od© dkov n¡
         call      DispTxt                  ; od© dkov n¡ textu
         pop       si
         jnc       ClosFil4                 ; operace OK

         call      DispTxt                  ; zobrazen¡ textu chyby


ClosFil4:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ClosFile ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ p©ijat‚ho adres ©e
; -----------------------------------------------------------------------------

PUBLIC   ReadDir

ReadDir  PROC      NEAR

         push      ax
         push      dx
         push      si
         push      ds

                                          ;* vytvo©en¡ adres ©e (neexistuje-li)
         mov       ds,cs:[segbuf]           ; segment s na‡ten˜m adres ©em
         xor       dx,dx                    ; offset specifikace adres ©e
         mov       ah,39h                   ; AH <- 39h
         int       21h                      ; vytvo©en¡ adres ©e

                                          ;* nastaven¡ nov‚ho adres ©e
         mov       ah,3bh                   ; AH <- 3bh
         int       21h                      ; nastaven¡ nov‚ho aktiv. adres ©e
         jc        ReadDir1                 ; chyba nastaven¡ adres ©e

                                          ;* na‡ten¡ aktivn¡ho adres ©e
         push      cs
         pop       ds
         mov       si,path                  ; pracovn¡ adres ©
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         mov       ah,47h                   ; AH <- 47h
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e
         jnc       ReadDir2                 ; adres © OK

                                          ;* chyba p©¡stupu k adres ©i
ReadDir1:mov       si,offset dirtxt
         call      DispTxt

ReadDir2:pop       ds
         pop       si
         pop       dx
         pop       ax
         ret

ReadDir  ENDP

; -----------------------------------------------------------------------------
;        Zmˆna aktivn¡ho adres ©e na DS:DX (13 znak–)
; -----------------------------------------------------------------------------

PUBLIC   ChngDir

ChngDir  PROC      NEAR

         mov       ah,3bh                   ; AH <- 3bh
         int       21h                      ; nastaven¡ nov‚ho aktiv. adres ©e
         jnc       ChngDir1                 ; adres © nastaven OK

                                          ;* chyba nastaven¡ adres ©e
         mov       si,offset dirtxt         ; chyba p©¡stupu k adres ©i
         call      DispTxt                  ; zobrazen¡ textu chyby
         ret


                                          ;* vysl n¡ adres ©e na port LPT
ChngDir1:mov       al,"D"                   ; p©¡kaz - zmˆna adres ©e
         mov       cx,13                    ; d‚lka zpr vy - 13 znak–
         mov       si,dx                    ; adresa adres ©e
         call      WritTxt                  ; vysl n¡ zpr vy
         clc
         ret

ChngDir  ENDP

; -----------------------------------------------------------------------------
;        Vysl n¡ nalezen‚ho souboru z aktivn¡ho adres ©e
; -----------------------------------------------------------------------------
; VSTUP: CY=byla chyba operace
; -----------------------------------------------------------------------------

PUBLIC   SendFile

SendFile PROC      NEAR

                                          ;* zobrazen¡ informace o souboru
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds

         push      cs
         pop       ds
         mov       word ptr ds:[sum],-1     ; inicializace kontroln¡ho sou‡tu

         mov       si,9eh
         call      ZobrFile                 ; zobrazen¡ p©en ¨en‚ho souboru

                                          ;* povel pro otev©en¡ souboru
         mov       si,95h                   ; atributy, ‡as, datum a jm‚no
         mov       al,"O"                   ; povel pro otev©en¡ souboru
         mov       cx,22                    ; d‚lka jm‚na souboru a atribut–
         call      WritTxt                  ; vysl n¡ povelu k vytvo©en¡ soub.

                                          ;* otev©en¡ souboru
         mov       dx,9eh                   ; jm‚no souboru
         mov       ax,3d00h                 ; otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         mov       ds:[ident],ax            ; identifik tor souboru
         mov       si,offset opentxt        ; text chyby otev©en¡ souboru
         jc        SendFil5                 ; chyba otev©en¡ souboru

                                          ;* na‡ten¡ bloku dat
SendFil2:push      ds
         mov       bx,ds:[ident]
         mov       ds,ds:[segbuf]
         xor       dx,dx
         mov       cx,0fff0h
         mov       ah,3fh
         int       21h
         pop       ds
         mov       si,offset readxtxt       ; text - chyba ‡ten¡ ze souboru
         jc        SendFil4                 ; chyba ‡ten¡ souboru
         mov       cx,ax
         jcxz      SendFil4                 ; nejsou dal¨¡ data

         push      ds
         mov       ds,ds:[segbuf]
         xor       si,si
         call      CheckSum                 ; kontroln¡ sou‡et bloku dat
         mov       al,"W"
         call      WritTxt
         pop       ds
         jmp       short SendFil2

SendFil4:                                  ;* uzav©en¡ souboru
         pushf
         mov       bx,ds:[ident]
         mov       ah,3eh
         int       21h

                                          ;* povel pro uzav©en¡ souboru
         mov       al,ds:[95h]              ; atributy souboru
         mov       ds:[atrib],al
         mov       ax,ds:[98h]              ; datum souboru
         mov       ds:[datum],ax
         mov       ax,ds:[96h]              ; ‡as souboru
         mov       ds:[cas],ax

         push      si
         mov       si,offset sum            ; kontroln¡ sou‡et
         mov       cx,2                     ; 2 bajty - kontroln¡ sou‡et
         mov       al,"C"                   ; povel k uzav©en¡ souboru
         call      WritTxt                  ; vysl n¡ povelu pro uzav©en¡ soub.
         pop       si

         popf
         jc        SendFil5                 ; byla chyba operace

                                          ;* ‡¡ta‡ p©enesen˜ch soubor–
         inc       word ptr ds:[citfile]    ; zv˜¨en¡ ‡¡ta‡e p©enesen˜ch soubor–

                                          ;* od© dkov n¡ textu
SendFil5:push      si                       ; £schova adresy textu chyby
         mov       si,offset CRTxt          ; text od© dkov n¡
         call      DispTxt                  ; od© dkov n¡ textu
         pop       si                       ; n vrat adresy textu chyby
         jnc       SendFil6                 ; nebyla chyba operace

                                          ;* zobrazen¡ textu chyby
         call      DispTxt                  ; text chyby

SendFil6:pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SendFile ENDP

; -----------------------------------------------------------------------------
;        V˜stup zpr vy (s povelem) na port COM
; -----------------------------------------------------------------------------
; VSTUP: AL=identifik tor zpr vy
;        DS:SI=adresa obsahu zpr vy
;        CX=po‡et bajt– k vysl n¡
; VSTUP:DS:SI=nov  adresa po vysl n¡ dat
; -----------------------------------------------------------------------------

PUBLIC   WritTxt

WritTxt  PROC      NEAR

                                          ;* vysl n¡ z hlav¡ zpr vy
         push      ax
         push      dx
         mov       dx,cs:[adrport]          ; adresa portu
         in        al,dx                    ; p©¡jem p©ijat‚ho bajtu
         in        al,dx                    ; p©¡jem p©ijat‚ho bajtu
         in        al,dx                    ; p©¡jem p©ijat‚ho bajtu
         pop       dx
         pop       ax

         push      cx
         push      si
         push      ds
         push      cs
         pop       ds
         mov       ds:[povel],al            ; povel
         mov       word ptr ds:[povel+1],cx ; po‡et bajt– zpr vy
         mov       cx,12
         mov       si,offset identif0       ; z hlav¡ zpr vy
         call      WritCOM                  ; vysl n¡ zpr vy na port COM
         pop       ds
         pop       si
         pop       cx
         call      WritCOM                  ; vysl n¡ obsahu zpr vy
         ret

WritTxt  ENDP

; -----------------------------------------------------------------------------
;        V˜stup bloku dat z pamˆti na port COM
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa bloku dat
;        CX=po‡et bajt– k vysl n¡
; VSTUP:DS:SI=nov  adresa po vysl n¡ dat
; -----------------------------------------------------------------------------

;WritLP14:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short WritLP12           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;WritLP24:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short WritLP22           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;WritLP34:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short WritLP32           ; dal¨¡ ‡ek n¡ na p©ipravenost
;


PUBLIC   WritCOM
WritCOM  PROC      NEAR

                                          ;* £schova registr–
         push      ax
         push      bx
         push      cx
         push      dx
         push      di

         mov       di,cx                    ; po‡et bajt– k vys¡l n¡
         or        di,di                    ; jsou nˆjak  data ?
         jz        WritCOM6                 ; nejsou ‘ dn  data

WritCOM1:                                 ;* ‡ek n¡ na potvrzen¡ p©ipravenosti
         xor       cx,cx                    ; doba pro ‡ek n¡
         mov       dx,cs:[adrport]          ; adresa portu
         add       dx,5                     ; stavov˜ registr linky
WritCOM2:in        al,dx
         test      al,1                     ; byla p©ijata data ?
         loopz     WritCOM2                 ; ‡ek n¡ na p©¡jem dat
         jnz       WritCOM3                 ; byl p©ijat datov˜ bajt

         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡
         jmp       short WritCOM1           ; opakov n¡ ‡ek n¡ na p©¡jem v˜zvy

                                          ;* test p©eru¨en¡
WritCOM3:
         mov       dx,cs:[adrport]          ; adresa portu
         in        al,dx                    ; p©¡jem p©ijat‚ho bajtu
         in        al,dx                    ; p©¡jem p©ijat‚ho bajtu
         in        al,dx                    ; p©¡jem p©ijat‚ho bajtu
WritCOM7:cmp       byte ptr cs:[parbreak],0 ; byla stisknuta kl vesa ?
         je        WritCOM4                 ; nebyl stisk kl vesy

         mov       byte ptr cs:[parbreak],0 ; zru¨en¡ p©¡znaku stisku kl vesy
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡

                                          ;* ‡ek n¡ na p©ipravenost portu
WritCOM4:xor       cx,cx                    ; doba pro ‡ek n¡
         mov       dx,cs:[adrport]          ; adresa portu
         add       dx,5                     ; stavov˜ registr linky
WritCOM5:in        al,dx
         and       al,60h
         cmp       al,60h                   ; je p©ipraven k vys¡l n¡ ?
         loopne    WritCOM5                 ; ‡ek n¡ na p©ipravenost vys¡la‡e
         jne       WritCOM7                 ; ‡ek n¡ na p©ipravenost

                                          ;* vysl n¡ znaku
         mov       al,ds:[si]               ; znak k vysl n¡
         sub       dx,5
         out       dx,al                    ; vysl n¡ znaku

                                          ;* zv˜¨en¡ ukazatel– bloku
         inc       si                       ; zv˜¨en¡ ukazatele bajt–
         dec       di                       ; ‡¡ta‡ bajt–
         jnz       WritCOM1                 ; je je¨tˆ dal¨¡ bajt

                                          ;* n vrat registr–
WritCOM6:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritCOM  ENDP


;
;
;                                          ;* inicializace registr–
;         mov       di,cx                    ; po‡et bajt– k vysl n¡
;         or        di,di
;         jnz       WritLP00
;         jmp       WritLPT6
;
;WritLP00:mov       dx,cs:[adrport]          ; adresa portu LPT
;         add       dx,4                     ; v˜stupn¡ registr
;
;
;                                          ;* vysl n¡ bitu 0 bajtu
;WritLP11:mov       bh,ds:[si]               ; bajt k vysl n¡
;         mov       al,bh
;         and       al,1
;         shl       al,1
;         out       dx,al                    ; bit 0
;         or        al,1                     ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (1)
;WritLP12:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP13:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopz     WritLP13                 ; ‡ek n¡ na bit 1
;         jcxz      WritLP14                 ; byl TIME-OUT
;         sub       dx,2
;
;
;                                          ;* vysl n¡ bitu 1 bajtu
;WritLP21:mov       al,bh                    ; bajt k vysl n¡
;         shr       bh,1
;         and       al,2
;         or        al,1
;         out       dx,al                    ; bit 1
;         and       al,not 1                 ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (0)
;WritLP22:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP23:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopnz    WritLP23                 ; ‡ek n¡ na bit 0
;         jcxz      WritLP24                 ; byl TIME-OUT
;         sub       dx,2
;
;
;                                          ;* vysl n¡ bitu 2 bajtu
;WritLP31:mov       al,bh                    ; bajt k vysl n¡
;         shr       bh,1
;         and       al,2
;         out       dx,al                    ; bit 0
;         or        al,1                     ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (1)
;WritLP32:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP33:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopz     WritLP33                 ; ‡ek n¡ na bit 2
;         jcxz      WritLP34                 ; byl TIME-OUT
;         sub       dx,2
;
;
;                                          ;* vysl n¡ bitu 3 bajtu
;WritLP41:mov       al,bh                    ; bajt k vysl n¡
;         shr       bh,1
;         and       al,2
;         or        al,1
;         out       dx,al                    ; bit 3
;         and       al,not 1                 ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (0)
;WritLP42:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP43:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopnz    WritLP43                 ; ‡ek n¡ na bit 0
;         jcxz      WritLP44                 ; byl TIME-OUT
;         sub       dx,2
;
;
;                                          ;* vysl n¡ bitu 4 bajtu
;WritLP51:mov       al,bh                    ; bajt k vysl n¡
;         shr       bh,1
;         and       al,2
;         out       dx,al                    ; bit 4
;         or        al,1                     ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (1)
;WritLP52:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP53:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopz     WritLP53                 ; ‡ek n¡ na bit 1
;         jcxz      WritLP54                 ; byl TIME-OUT
;         sub       dx,2
;
;
;                                          ;* vysl n¡ bitu 5 bajtu
;WritLP61:mov       al,bh                    ; bajt k vysl n¡
;         shr       bh,1
;         and       al,2
;         or        al,1
;         out       dx,al                    ; bit 5
;         and       al,not 1                 ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (0)
;WritLP62:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP63:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopnz    WritLP63                 ; ‡ek n¡ na bit 0
;         jcxz      WritLP64                 ; byl TIME-OUT
;         sub       dx,2
;
;
;                                          ;* vysl n¡ bitu 6 bajtu
;WritLP71:mov       al,bh                    ; bajt k vysl n¡
;         shr       bh,1
;         and       al,2
;         out       dx,al                    ; bit 6
;         or        al,1                     ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (1)
;WritLP72:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP73:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopz     WritLP73                 ; ‡ek n¡ na bit 1
;         jcxz      WritLP74                 ; byl TIME-OUT
;         sub       dx,2
;
;
;                                          ;* vysl n¡ bitu 7 bajtu
;WritLP81:mov       al,bh                    ; bajt k vysl n¡
;         and       al,2
;         or        al,1
;         out       dx,al                    ; bit 7
;         and       al,not 1                 ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu
;         add       dx,2                     ; stavov˜ registr
;
;                                          ;* ‡ek n¡ na potvrzen¡ (0)
;WritLP82:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
;WritLP83:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,20h
;         loopnz    WritLP83                 ; ‡ek n¡ na bit 0
;         jcxz      WritLP84                 ; byl TIME-OUT
;         sub       dx,2
;
;                                          ;* zv˜¨en¡ ukazatel– bloku
;         inc       si                       ; zv˜¨en¡ ukazatele bajt–
;         dec       di                       ; ‡¡ta‡ bajt–
;         jz        WritLPT6
;         jmp       WritLP11                 ; je je¨tˆ dal¨¡ bajt
;
;                                          ;* n vrat registr–
;WritLPT6:pop       di
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;WritCOM  ENDP
;
;; -----------------------------------------------------------------------------
;
;WritLP44:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       WritLP42                 ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;
;
;WritLP54:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short WritLP52           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;WritLP64:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short WritLP62           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;WritLP74:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short WritLP72           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;WritLP84:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short WritLP82           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;
;
;
; -----------------------------------------------------------------------------
;        P©¡jem zpr vy z portu LPT
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa za‡ tku zpr vy
;         AL=povel
;         CX=d‚lka zpr vy
; -----------------------------------------------------------------------------

PUBLIC   ReadTxt
ReadTxt  PROC      NEAR

                                          ;* £schova registr–
         push      di
         push      ds

         push      cs
         pop       es
         push      cs
         pop       ds

                                          ;* ‡ek n¡ na p©¡jem z hlav¡
ReadTxt1:mov       si,offset identif        ; text identifikace

                                          ;* p©¡jem a kontrola 1 znaku
ReadTxt2:mov       di,offset bufchar        ; buffer pro p©¡jem bajtu
         mov       cx,1                     ; 1 bajt k p©¡jmu
         call      ReadCOM                  ; p©¡jem 1 znaku
         mov       al,ds:[bufchar]          ; p©ijat˜ bajt
         cmp       ds:[si],al               ; porovn n¡ 1 znaku identifikace
         jne       ReadTxt1                 ; nen¡ shoda - znovu

                                          ;* zv˜¨en¡ ukazatele identifik toru
         inc       si                       ; zv˜¨en¡ ukazatele identifikace
         cmp       si,offset povel          ; byla cel  identifikace ?
         jb        ReadTxt2                 ; nebyla je¨tˆ cel  identifikace

                                          ;* p©¡jem povelu a d‚lky zpr vy
         mov       di,offset bufchar        ; buffer pro p©¡jem z hlav¡
         mov       cx,3                     ; 3 bajty k p©¡jmu
         call      ReadCOM                  ; p©¡jem 3 bajt– z hlav¡ zpr vy

                                          ;* p©¡jem obsahu zpr vy
         mov       cx,word ptr ds:[bufchar+1] ; d‚lka zpr vy
         xor       di,di                    ; offset ukl dac¡ adresy = 0
         mov       es,ds:[segbuf]           ; segment datov‚ho bufferu
         call      ReadCOM                  ; p©¡jem obsahu zpr vy

                                          ;* nastaven¡ registr–
         xor       si,si                    ; offset za‡ tku zpr vy
         mov       al,ds:[bufchar]          ; povel zpr vy
         mov       cx,word ptr ds:[bufchar+1] ; d‚lka zpr vy

         pop       ds
         pop       di
         ret

ReadTxt  ENDP

; -----------------------------------------------------------------------------
;        P©¡jem bloku dat z portu COM od adresy ES:DI
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa k ulo‘en¡ bloku dat
;        CX=po‡et bajt– k p©¡jmu
; VSTUP:ES:DI=nov  ukl dac¡ adresa dat
; -----------------------------------------------------------------------------

PUBLIC   ReadCOM
ReadCOM  PROC      NEAR

                                          ;* £schova registr–
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         jcxz      ReadCOM6                 ; nen¡ ‘ dn˜ bajt k p©¡jmu

                                          ;* inicializace registr–
         mov       si,cx                    ; po‡et bajt– k p©¡jmu
         cli

                                          ;* ‡ek n¡ na p©¡jem bajtu
ReadCOM1:xor       cx,cx                    ; doba pro ‡ek n¡
         mov       dx,cs:[adrport]          ; adresa portu COM
         add       dx,5                     ; stavov˜ registr linky

ReadCOM2:
         in        al,dx                    ; ‡ten¡ stavov‚ho registru linky
         test      al,1
         jnz       ReadCOM3

         and       al,60h
         cmp       al,60h                   ; je vys¡la‡ pr zdn˜ ?
         jne       ReadCM22                 ; nˆco se vys¡l 
         sti
         sub       dx,5
         cli
         out       dx,al                    ; v˜zva k vys¡l n¡
         add       dx,5                     ; stavov˜ registr linky
ReadCM22:in        al,dx
         test      al,1                     ; byl p©ijat bajt ?
         loopz     ReadCOM2                 ; ‡ek n¡ na p©¡jem bajtu
         jnz       ReadCOM3                 ; byl p©ijat bajt

                                          ;* test p©eru¨en¡
         sti
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡
         cli
         jmp       short ReadCOM1           ; dal¨¡ ‡ek n¡ na p©¡jem

                                          ;* byl p©ijat datov˜ bajt
ReadCOM3:cmp       byte ptr cs:[parbreak],0 ; byla stisknuta kl vesa ?
         je        ReadCOM5                 ; nebyl stisk kl vesy

         mov       byte ptr cs:[parbreak],0 ; zru¨en¡ p©¡znaku stisku kl vesy
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡

ReadCOM5:mov       dx,cs:[adrport]
         in        al,dx                    ; p©¡jem bajtu
         mov       es:[di],al               ; ulo‘en¡ p©ijat‚ho bajtu

                                          ;* dal¨¡ bajt
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         dec       si                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       ReadCOM1                 ; p©¡jem dal¨¡ho bajtu
         sti

                                          ;* n vrat registr–
ReadCOM6:
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadCOM  ENDP


;
;                                          ;* ‡ek n¡ na stav bitu 0 (v klidu = 1)
;ReadLPT1:mov       ch,10                    ; doba pro TIME-OUT (asi 5000)
;         inc       dx                       ; vstupn¡ port LPT
;ReadLPT2:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,bh                    ; test bitu 7
;         loopnz    ReadLPT2                 ; ‡ek n¡ na bit 0
;         dec       dx                       ; v˜stupn¡ port LPT
;         jcxz      ReadLPT7                 ; byl TIME-OUT p©¡jmu
;
;                                          ;* potvrzen¡ p©¡jmu tetr dy
;         mov       bl,al                    ; £schova ni‘¨¡ tetr dy znaku
;         or        al,bh                    ; nastaven¡ strobovac¡ho bitu
;         out       dx,al                    ; potvrzen¡ p©¡jmu
;
;                                          ;* £schova ni‘¨¡ tetr dy znaku
;         shr       bl,1                     ; BL >> 1 (bity 2 a‘ 5)
;         shr       bl,1                     ; BL >> 1 (bity 1 a‘ 4)
;         shr       bl,1                     ; BL >> 1 (bity 0 a‘ 3)
;
;                                          ;* ‡ek n¡ na stav bitu 1
;ReadLPT3:mov       ch,10                    ; doba pro TIME-OUT (asi 5000)
;         inc       dx                       ; vstupn¡ port LPT
;ReadLPT4:in        al,dx                    ; ‡ten¡ stavu portu
;         test      al,bh                    ; test bity 7
;         loopz     ReadLPT4                 ; ‡ek n¡ na bit 1
;         dec       dx                       ; v˜stupn¡ port LPT
;         jcxz      ReadLPT8                 ; byl TIME-OUT p©¡jmu
;
;                                          ;* potvrzen¡ p©¡jmu
;         xor       al,bh                    ; nulov n¡ strobovac¡ho bitu
;         out       dx,al                    ; potvrzen¡ p©¡jmu
;
;                                          ;* sestaven¡ bajtu
;         add       al,al                    ; rotace na spr vnou pozici
;         and       al,0f0h                  ; vy¨¨¡ tetr da bajtu
;         or        al,bl                    ; slou‡en¡ s ni‘¨¡ tetr dou znaku
;
;                                          ;* ulo‘en¡ p©ijat‚ho bajtu
;         stosb                              ; ulo‘en¡ bajtu
;         dec       si                       ; sn¡‘en¡ ‡¡ta‡e bajt–
;         jnz       ReadLPT1                 ; p©¡jem dal¨¡ho bajtu
;
;                                          ;* n vrat registr–
;ReadCOM6:pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;ReadCOM  ENDP
;
;; -----------------------------------------------------------------------------
;
;                                          ;* ‡ek n¡ na p©ipravenost 0
;ReadLPT7:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short ReadLPT1           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
;                                          ;* ‡ek n¡ na p©ipravenost 1
;ReadLPT8:mov       ah,0bh                   ; AH <- 0bh
;         int       21h                      ; test stavu p©eru¨en¡ BREAK
;         jmp       short ReadLPT3           ; dal¨¡ ‡ek n¡ na p©ipravenost
;
; -----------------------------------------------------------------------------
;        Zobrazen¡ textu CS:SI
; -----------------------------------------------------------------------------

PUBLIC   DispTxt

DispTxt  PROC      NEAR

         pushf
         push      ax
         cld
DispTxt1:mov       al,cs:[si]               ; znak k zobrazen¡
         inc       si                       ; zv˜¨en¡ ukazatele textu
         or        al,al                    ; je konec textu ?
         jz        DispTxt2                 ; je konec textu
         call      DispChar                 ; zobrazen¡ znaku
         jmp       short DispTxt1           ; dal¨¡ znak k zobrazen¡
DispTxt2:pop       ax
         popf
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ ‡¡sla AX od adresu CS:SI dol–
; -----------------------------------------------------------------------------

PUBLIC   DekNum
DekNum   PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si

DekNum1: xor       dx,dx                    ; DX:AX = ‡¡slo
         mov       cx,10                    ; dˆlitel
         div       cx                       ; v˜po‡et ‡¡slice
         add       dl,"0"                   ; korekce na ‡¡slici
         mov       cs:[si],dl               ; ulo‘en¡ ‡¡slice
         dec       si                       ; sn¡‘en¡ ukazatele textu
         or        ax,ax                    ; je je¨tˆ dal¨¡ ‡¡slo ?
         jnz       DekNum1                  ; je je¨tˆ ‡¡slo
         mov       byte ptr cs:[si]," "     ; £vodn¡ mezera

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ znaku
; -----------------------------------------------------------------------------

PUBLIC   DispChar

DispChar PROC      NEAR

         push      ax
         push      dx
         mov       ah,2
         mov       dl,al                    ; znak k zobrazen¡
         int       21h                      ; zobrazen¡ znaku
         pop       dx
         pop       ax
         ret

DispChar ENDP

; -----------------------------------------------------------------------------
;                                 DATA
; -----------------------------------------------------------------------------

uvtxt    db        'TransCOM V1.00; (c) Miroslav Nemecek',13,10
         db        '------------------------------------',13,10,0

errtxt   db        '1 az 4 = cislo portu COM',13,10
         db        '*      = bude vyslan aktivni adresar',13,10
         db        '!      = bude vyslan aktiv. adresar s podaresari',13,10
         db        'neni-li zadan * ani ! bude prijem',13,10,0

old09    dd        0                        ; p–vodn¡ adresa INT 09h
parbreak db        0                        ; p©¡znak stisku kl vesy

porttxt  db        'Port COM'
porttxt0 db        '1 neni nainstalovan !',13,10,0

vystxt   db        'Vysilam soubory na port COM'
vystxt0  db        '1 ......',13,10,13,10,0

prijtxt  db        'Prijimam soubory z portu COM'
prijtxt0 db        '1 .....',13,10,13,10,0

memtxt   db        'Nedostatek pameti !',13,10,0

opentxt  db        7,'Chyba otevreni souboru !',13,10,0
writetxt db        ' ... CHYBA !',13,10,7,'Chyba zapisu do souboru !',13,10,0
readxtxt db        7,'Chyba cteni ze souboru !',13,10,0
dirtxt   db        7,'Chyba pristupu k adresari !',13,10,0
fulltxt  db        ' ... CHYBA !',13,10,7,'Disk je plny !',13,10,0
clostxt  db        7,'Chyba uzavreni souboru !',13,10,0
chsumtxt db        7,'Chyba pri prenosu souboru !',13,10,0

BreakTxt db        'Prenos prerusen ...',13,10,0
PocetTxt db        'Pocet prenesenych souboru .........'
CRTxt    db        13,10,0

sum      dw        -1                       ; ‡¡ta‡ kontroln¡ho sou‡tu souboru

subdirs  db        0                        ; p©¡znak vys¡l n¡ podadres ©–

ident    dw        0                        ; identifik tor otev©en‚ho souboru

all      db        '*.*',0                  ; specifikace - v¨echny soubory
subdir   db        '..',0                   ; specifikace podadres ©e

identif0 db        '****'                   ; synchroniza‡n¡ data
identif  db        'Trans'                  ; identifik tor z hlav¡ zpr vy
povel    db        3 dup(0)                 ; buffer pro povel a d‚lku dat
bufchar  db        3 dup(0)                 ; buffer pro p©¡jem povelu

                                          ;* £schova p©¡znak– souboru
atrib    db        0                        ; atributy souboru
cas      dw        0                        ; ‡as souboru
datum    dw        0                        ; datum souboru
         dd        0                        ; rezerva pro velikost souboru
jmeno    db        13 dup(0)                ; jm‚no souboru

setvys   db        0                        ; 1=p©¡znak vys¡l n¡ soubor–
adrport  dw        0                        ; adresa portu COM
segbuf   dw        0                        ; segment datov‚ho bufferu
citfile  dw        0                        ; ‡¡ta‡ p©enesen˜ch soubor–

aktdisk  db        'A:\'                    ; aktivn¡ disk, za‡ tek cesty
aktpath  label     byte                     ; aktu ln¡ adres ©

code     ENDS
         END       Start

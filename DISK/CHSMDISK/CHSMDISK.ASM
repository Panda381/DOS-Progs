
Code     segment
         assume    cs:code,ds:code
         org       100H

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ definice INT 23h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h                      ; p©edefinov n¡ INT 23h

; ------ p©edefinov n¡ z sobn¡ku

         cmp       sp,offset Zasob          ; kontrola konce z sobn¡ku
         jb        Start2                   ; chyba - nedostatek pamˆti
         mov       sp,offset Zasob          ; p©edefinov n¡ z sobn¡ku

; ------ zmen¨en¡ programu na minimum

         mov       ah,4ah
         mov       bx,(offset(Zasob-Start)+10fh)/16 ; velikost programu
         int       21h                      ; zmen¨en¡ bloku programu
         jnc       Start4                   ; operace OK

; ------ chyba pamˆti

Start2:  mov       dx,offset MemTxt
Start3:  mov       ah,9
         int       21h

; ------ chybov˜ n vrat

         mov       ax,4c02h
         int       21h                      ; n vrat s chybou

; ------ vytvo©en¡ datov‚ho bufferu

Start4:  mov       ah,48h
         mov       bx,0fffh                 ; velikost datov‚ho bufferu
         int       21h                      ; vytvo©en¡ datov‚ho bufferu
         jnc       Start5                   ; buffer vytvo©en OK
         mov       ah,48h
         int       21h                      ; druh˜ poku so vytvo©en¡ bufferu
         jc        Start2                   ; chyba pamˆti
Start5:  mov       ds:[BuffSegm],ax         ; adresa bufferu
         mov       cl,4                     ; po‡et rotac¡
         shl       bx,cl                    ; p©epo‡et na bajty
         mov       ds:[BuffSize],bx         ; velikost bufferu

; ------ p©ednastaven¡ aktivn¡ho disku

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         mov       ds:[Disk],al             ; aktivn¡ disk

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bh,0
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       byte ptr ds:[bx+si],0    ; ozna‡en¡ konce textu

; ------ nalezen¡ ozna‡en¡ disku

         mov       dx,offset HelpTxt        ; text n povˆdy
         call      ParSpc                   ; nalezen¡ za‡ tku parametru
         jc        Start6                   ; nen¡ nic zad no
         cmp       byte ptr ds:[si+1],":"   ; je to ozna‡en¡ disku ?
         jne       Start56                  ; disk nen¡ zad n
         call      ParChr                   ; na‡ten¡ znaku
         sub       al,"A"                   ; konverze na ‡¡slo disku
         mov       ds:[Disk],al             ; ozna‡en¡ disku

; ------ kontrola zad n¡

         cmp       al,32                    ; je ‡¡slo disku ?
         jae       Start3                   ; chyba zad n¡
         call      ParChr                   ; zru¨en¡ znaku ":"

; ------ na‡ten¡ ozna‡en¡ HEX

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jc        Start6                   ; nen¡ nic dal¨¡ho zad no
Start56: call      ParHex                   ; na‡ten¡ parametru HEX
Start33: jc        Start3                   ; chyba zad n¡
         mov       ds:[Soucet],ax           ; p©edpokl dan˜ kontroln¡ sou‡et
         or        byte ptr ds:[Param],1    ; p©¡znak zad n¡ sou‡tu
         call      ParSpc                   ; je je¨tˆ nˆco zad no ?
         cmc
         jc        Start33                  ; chyba - je je¨tˆ nˆco zad no

; ------ stanoven¡ informac¡ o disku

Start6:  call      InitI25                  ; stanoven¡ informac¡ o disku
         jc        Start33                  ; nˆjak  chyba

; ------ hl ¨en¡ o zpracovan‚ ‡ sti

Start7:  sti                                ; p©eru¨en¡ povoleno
         call      DispKur                  ; zobrazen¡ kurzoru operace

; ------ po‡et sektor– ke ‡ten¡

         mov       ax,word ptr ds:[UkazSekt] ; ukazatel sektor– LOW
         mov       dx,word ptr ds:[UkazSekt+2] ; ukazatel sektor– HIGH
         mov       cx,word ptr ds:[MaxSekt] ; po‡et sektor– disku LOW
         mov       bx,word ptr ds:[MaxSekt+2] ; po‡et sektor– disku HIGH
         sub       cx,ax                    ; zbyl‚ sektory LOW
         sbb       bx,dx                    ; zbyl‚ sektory HIGH
         jc        Start8                   ; p©ete‡en¡

; ------ omezen¡ po‡tu sektor–

         jz        Start72                  ; nen¡ v¡ce sektor– ne‘ 0ffffh
         mov       cx,0ffffh                ; omezen¡ po‡tu sektor–
Start72: cmp       cx,ds:[BuffSekt]         ; vejdou se do bufferu ?
         jbe       Start73                  ; po‡et sektor– je OK
         mov       cx,ds:[BuffSekt]         ; omezen¡ po‡tu sektor–
Start73: jcxz      Start8                   ; je ji‘ cel˜ disk

; ------ na‡ten¡ dal¨¡ho bloku sektor– z disku

         call      ReadSekt                 ; ‡ten¡ dal¨¡ho bloku dat
         mov       dx,offset ReadTxt        ; text - chyba ‡ten¡
         jc        Start33                  ; chyba ‡ten¡ dat z disku

; ------ zv˜¨en¡ ukazatele sektor–

         add       word ptr ds:[UkazSekt],cx ; zv˜¨en¡ ukazatele sektor– LOW
         adc       word ptr ds:[UkazSekt+2],0 ; p©enos HIGH

; ------ v˜po‡et kontroln¡ho sou‡tu sektor–

         mov       ax,ds:[SektSize]         ; po‡et bajt– na sektor
         mul       cx                       ; v˜po‡et d‚lky dat v bajtech
         mov       cx,ax                    ; po‡et bajt– ke kontroln¡mu sou‡tu
         mov       dx,ds:[Soucet0]          ; po‡¡tan˜ kontroln¡ sou‡et
         xor       si,si                    ; za‡ tek dat
         push      ds
         mov       ds,ds:[BuffSegm]         ; adresa bufferu
         call      CheckSum                 ; kontroln¡ sou‡et bloku dat
         pop       ds
         mov       ds:[Soucet0],dx          ; pokra‡ov n¡ kontroln¡ho sou‡tu

; ------ test p©eru¨en¡ programu

         mov       ah,0bh
         int       21h
         cmp       al,0ffh
         jne       Start7                   ; nen¡ p©ipraven znak
         mov       ah,08h
         int       21h
         cmp       al,27
         jne       Start7                   ; nen¡ p©eru¨en¡

INT23:   push      cs
         pop       ds
         call      ClrKur                   ; vymaz n¡ kurzoru
         mov       al,3                     ; p©¡znak p©eru¨en¡
         jmp       short Start9             ; konec

; ------ zobrazen¡ v˜sledku

Start8:  call      ClrKur                   ; vymaz n¡ kurzoru
         mov       al,ds:[Disk]             ; disk
         add       ds:[SoucTxt1],al         ; ozna‡en¡ disku
         mov       ax,ds:[Soucet0]          ; vypo‡¡tan˜ kontroln¡ sou‡et
         mov       di,offset SoucTxt2
         call      DekWord                  ; dek¢dov n¡ ‡¡sla kontr. sou‡tu
         mov       dx,offset SoucTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ v˜sledku
         test      byte ptr ds:[Param],1    ; zad n kontroln¡ sou‡et ?
         jz        Start89                  ; nezad n

; ------ test, zda kontroln¡ sou‡et souhlas¡

         mov       ax,ds:[Soucet0]
         cmp       ax,ds:[Soucet]           ; souhlas¡ kontroln¡ sou‡et ?
         je        Start84                  ; souhlas¡ OK

         mov       dx,offset Souc4Txt
         mov       ah,9
         int       21h                      ; CRC nesouhlas¡
         mov       al,1
         jmp       short Start9

Start84: mov       dx,offset Souc3Txt
         mov       ah,9
         int       21h                      ; CRC souhlas¡

Start89: mov       al,0                     ; operace OK
Start9:  mov       ah,4ch
         int       21h

; *****************************************************************************
;
;                             Kontroln¡ sou‡et
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
;        DX=vstupn¡ hodnota kontroln¡ho sou‡tu
; VSTUP:DX=v˜stupn¡ hodnota kontroln¡ho sou‡tu
; -----------------------------------------------------------------------------

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di
         jcxz      CheckSm2                 ; nen¡ ‘ dn˜ bajt
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
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

         dec       di
         jnz       CheckSm1                 ; dal¨¡ bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSum ENDP


; *****************************************************************************
;
;                              Obsluha disku
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        na‡ten¡ CX sektor– do datov‚ho bufferu (od za‡ tku)
; -----------------------------------------------------------------------------
; VSTUP: CX=po‡et sektor– ke ‡ten¡
;        DX:AX=po‡ te‡n¡ sektor
;        DS=datov˜ segment
; VSTUP:CY=chyba operace
; -----------------------------------------------------------------------------

ReadSekt PROC      NEAR

; ------ £schova registr–

         push      bp
         mov       bp,2                     ; po‡et pokus– o na‡ten¡ dat

ReadSek1:push      ax
         push      bx
         push      cx
         push      dx
         push      ds

; ------ standardn¡ obsluha INT 25h

         test      byte ptr ds:[Param],2    ; je obsluha paketem ?
         jnz       ReadSek2                 ; je obsluha paketem
         mov       dx,ax                    ; ‡¡slo sektoru ke ‡ten¡
         mov       al,ds:[Disk]             ; ‡¡slo disku
         mov       ds,ds:[BuffSegm]         ; adresa datov‚ho bufferu
         xor       bx,bx                    ; po‡ te‡n¡ offset k na‡ten¡ dat
         jmp       short ReadSek4           ; na‡ten¡ dat

; ------ obsluha INT 25h paketem

ReadSek2:mov       bx,offset Paket          ; adresa paketu
         mov       ds:[bx],ax               ; ‡¡slo sektoru LOW
         mov       ds:[bx+2],dx             ; ‡¡slo sektoru HIGH
         mov       ds:[bx+4],cx             ; po‡et sektor–
         mov       word ptr ds:[bx+6],0     ; adresa bufferu LOW
         mov       ax,ds:[BuffSegm]         ; adresa bufferu
         mov       ds:[bx+8],ax             ; adresa bufferu HIGH
         mov       cx,-1                    ; p©¡znak obsluhy paketem
         mov       al,ds:[Disk]             ; ‡¡slo disku

; ------ na‡ten¡ sektor– do bufferu

ReadSek4:mov       cs:[Zasobnik],sp         ; £schova ukazatele z sobn¡ku
         int       25h                      ; proveden¡ operace ‡ten¡ dat
         mov       sp,cs:[Zasobnik]         ; n vrat z sobn¡ku

; ------ n vrat registr–

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; ------ p©¡padn‚ opakov n¡ operace p©i chybˆ

         jnc       ReadSek5                 ; operace dopadka OK
         dec       bp                       ; ‡¡ta‡ pokus–
         jnc       ReadSek1                 ; opakov n¡ operace

ReadSek5:pop       bp
         ret

ReadSekt ENDP

; -----------------------------------------------------------------------------
;        inicializace obsluhy INT 25h
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP:CY=neplatn˜ disk nebo nekompatibiln¡ syst‚m
;        DX=text chybov‚ho hl ¨en¡
; -----------------------------------------------------------------------------

InitI25  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      ds

; ------ poskytnut¡ tabulky parametr– disku

         and       byte ptr ds:[Param],not 2 ; zru¨en¡ p©¡znaku obsluhy paketem
         mov       dl,ds:[disk]             ; disk
         mov       ch,dl                    ; £schova ‡¡sla disku
         inc       dx                       ; ‡¡slo po‘adovan‚ho disku
         mov       ax,32ffh
         int       21h                      ; poskytnut¡ bloku parametr– disku

; ------ test spr vnosti disku

         mov       dx,offset DiskTxt        ; text - chybn‚ zad n¡ disku
         cmp       al,0ffh                  ; je chyba ?
         je        InitI254                 ; je chyba - neplatn˜ disk
         mov       dx,offset SystTxt        ; text - nekompatibiln¡ syst‚m
         cmp       ch,ds:[bx]               ; souhlas¡ ‡¡slo disku ?
         jne       InitI254                 ; ‡¡slo disku nesouhlas¡ - chyba
         pop       cx                       ; CX <- DS
         push      cx
         mov       ax,ds
         cmp       ax,cx                    ; zmˆnil se DS ?
         je        InitI254                 ; DS se nezmˆnil - chyba

; ------ celkov˜ po‡et sektor–

         mov       ax,ds:[bx+0dh]           ; max. ‡¡slo aloka‡n¡ho bloku
         dec       ax                       ; po‡et aloka‡n¡ch blok–
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[bx+4]             ; maxim ln¡ ‡¡slo sektoru v bloku
         inc       cx                       ; po‡et sektor– v aloka‡n¡m bloku
         mul       cx                       ; v˜po‡et po‡tu sektor– dat celkem
         add       ax,ds:[bx+0bh]           ; p©i‡ten¡ rezervovan˜ch sektor–
         adc       dx,0                     ; p©enos
         mov       word ptr cs:[MaxSekt],ax ; po‡et sektor– disku celkem LOW
         mov       word ptr cs:[MaxSekt+2],dx ; po‡et sektor– disku celkem HIGH
         jz        InitI253                 ; po‡et sektor– nen¡ vˆt¨¡ ne‘ ffffh
         or        byte ptr cs:[Param],2    ; p©¡znak obsluhy INT 25h paketem

; ------ velikost sektoru

InitI253:mov       bx,ds:[bx+2]             ; po‡et bajt– na sektor
         mov       cs:[SektSize],bx         ; velikost sektoru
         or        bx,bx
         mov       dx,offset SystTxt        ; text - nekompatibiln¡ syst‚m
         jz        InitI254                 ; chybn  velikost sektoru
         mov       ax,cs:[BuffSize]         ; velikost bufferu
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; po‡et sektor– v bufferu
         mov       cs:[BuffSekt],ax         ; po‡et sektor– v bufferu
         or        ax,ax                    ; je nˆjak˜ sektor ?
         jnz       InitI255                 ; je alespo¤ 1 sektor v bufferu - OK
         mov       dx,offset MemTxt         ; text - nedostatek pamˆti
InitI254:stc                                ; p©¡znak chyby

; ------ n vrat registr–

InitI255:pop       ds
         pop       cx
         pop       bx
         pop       ax
         ret

InitI25  ENDP

; *****************************************************************************
;
;                           Obsluha zobrazen¡
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        vymaz n¡ kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

ClrKur   PROC      NEAR

         push      ax
         push      cx
         push      di
         push      es

         push      ds
         pop       es
         mov       di,offset HlasTxt+1
         mov       cx,offset(HlasTxtX-HlasTxt)-2
         mov       al," "
         cld
         rep       stosb
         mov       al,13
         stosb

         mov       ah,9
         mov       dx,offset HlasTxt
         int       21h

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

ClrKur   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru operace
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

DispKur  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ v˜po‡et pozice kurzoru

         mov       ax,word ptr ds:[UkazSekt] ; sektor LOW
         mov       dx,word ptr ds:[UkazSekt+2] ; sektor HIGH
         call      PozKur                   ; v˜po‡et pozice kurzoru

; ------ dek¢dov n¡ procent operace

         mov       ax,di
         mov       cl,10
         div       cl
         add       ah,"0"
         mov       ds:[HlasTxt0+1],ah       ; jednotky procent
         add       al,"0"
         cmp       al,"0"
         je        DispKur1
         mov       ds:[HlasTxt0],al

; ------ z pis znaku kurzoru

DispKur1:mov       al,178                   ; znak kurzoru
         mov       cx,si
         mov       di,offset Kurz+1
         sub       cx,di                    ; d‚lka kurzoru
         push      ds
         pop       es
         cld
         rep       stosb                    ; z pis kurzoru

; ------ dek¢dov n¡ pr–bˆ‘n‚ho kontroln¡ho sou‡tu

         mov       ax,ds:[Soucet0]          ; kontroln¡ sou‡et
         mov       di,offset Souc
         call      DekWord                  ; dek¢dov n¡ slova

; ------ zobrazen¡ hl ¨en¡ o pr–bˆhu operace

         mov       dx,offset HlasTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispKur  ENDP

; -----------------------------------------------------------------------------
;        v˜po‡et pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo sektoru
; VSTUP:SI=adresa kurzoru v bufferu
;        DI=procenta operace 0 a‘ 99
; -----------------------------------------------------------------------------

PozKur   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ normalizace ukazatel–

         mov       bx,word ptr ds:[MaxSekt+2] ; po‡et sektor– HIGH
         mov       cx,word ptr ds:[MaxSekt] ; po‡et sektor– LOW
PozKur1: mov       di,dx
         or        di,bx                    ; je HIGH = 0 ?
         jz        PozKur2                  ; registry jsou OK
         shr       dx,1
         rcr       ax,1
         shr       bx,1
         rcr       cx,1
         jmp       short PozKur1

; ------ v˜po‡et adresy ukazatele

PozKur2: cmp       ax,cx
         jb        PozKur3
         mov       ax,cx
         jcxz      PozKur4
         dec       ax                       ; omezen¡ na posledn¡ sektor
PozKur3: mov       bx,100                   ; po‡et procent max.
         mul       bx                       ; p©edvyn soben¡ 100x
         div       cx                       ; v˜po‡et procent
PozKur4: mov       di,ax                    ; procenta operace
         mov       si,ax                    ; offset kurzoru
         shr       si,1
         shr       si,1                     ; ukazatel
         add       si,offset kurz+1         ; adresa kurzoru

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PozKur   ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ ‡¡sla HEX
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl dac¡ adresa textu
; -----------------------------------------------------------------------------

DekWord  PROC      NEAR

         xchg      ah,al                    ; AL <- vy¨¨¡ bajt slova
         call      DekByte                  ; dek¢dov n¡ vy¨¨¡ho bajtu slova
         xchg      ah,al                    ; AL <- ni‘¨¡ bajt slova

; ------ dek¢dov n¡ bajtu AL v HEX form tu

DekByte: push      ax                       ; £schova bajtu k dek¢dov n¡
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1                     ; nastaven¡ vy¨¨¡ tetr dy
         call      DekHex                   ; dek¢dov n¡ ni‘¨¡ tetr dy bajtu
         pop       ax                       ; n vrat bajtu k zobrazen¡

; ------ dek¢dov n¡ tetr dy AL v HEX form tu

DekHex:  push      ax
         and       al,0fh                   ; maska ni‘¨¡ tetr dy
         add       al,"0"                   ; korekce na ASCII znak
         cmp       al,"9"                   ; je p¡smeno ?
         jbe       DekHex2                  ; je ‡¡slice - OK
         add       al,7                     ; korekce na p¡smeno
DekHex2: cld
         stosb                              ; ulo‘en¡ znaku do bufferu
         pop       ax
         ret

DekWord  ENDP

; *****************************************************************************
;
;                          Rozbor p©¡kazov‚ho © dku
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla HEX
; -----------------------------------------------------------------------------

ParHex   PROC      NEAR

         push      dx
         xor       dx,dx                    ; st©ada‡ ‡¡sla
         call      ParSpc                   ; vypu¨tˆn¡ mezer
         call      ParHx                    ; prvn¡ znak HEX
         jc        ParHex3                  ; chyba
ParHex1: shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         or        dl,al
         call      ParHx                    ; dal¨¡ znak
         jnc       ParHex1
         clc                                ; operace OK

ParHex3: xchg      ax,dx
         pop       dx
         ret

ParHex   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho znaku HEX
; -----------------------------------------------------------------------------

ParHx    PROC      NEAR

         call      ParChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        ParHx3                   ; nen¡ dal¨¡ znak
         cmp       al,"0"
         jb        ParHx3                   ; nen¡ platn˜ znak
         cmp       al,"9"+1
         jb        ParHx1                   ; znak je OK
         cmp       al,"A"
         jb        ParHx2                   ; nen¡ platn˜ znak
         cmp       al,"F"
         ja        ParHx2                   ; nen¡ platn˜ znak
         sub       al,7

ParHx1:  sub       al,"0"                   ; korekce na ‡¡slo
         ret

ParHx2:  dec       si                       ; n vrat znaku
         stc                                ; p©¡znak chyby
ParHx3:  ret

ParHx    ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         jc        ParSpc2                  ; konec textu
         je        ParSpc                   ; mezera - vypu¨tˆn¡
         dec       si                       ; n vrat znaky
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku

         cld
         lodsb                              ; na‡ten¡ znaku z p©¡kaz. © dku
         cmp       al,"["
         je        ParChr
         cmp       al,"]"
         je        ParChr

; ------ n hrada tabel toru mezerou

         cmp       al,9                     ; je tabel tor ?
         jne       ParChr1                  ; nen¡ tabel tor
         mov       al," "                   ; n hrada tabel toru mezerou

; ------ konverze na velk‚ p¡smeno

ParChr1: cmp       al,"a"
         jb        ParChr2
         cmp       al,"z"
         ja        ParChr2
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ kontrola, zda je konec © dku

ParChr2: cmp       al," "                   ; je konec © dku ?
         jae       ParChr3                  ; nen¡ konec © dku
         dec       si                       ; n vrat znaku
         mov       byte ptr ds:[si],0       ; ozna‡en¡ konce textu
ParChr3: ret

ParChr   ENDP

; *****************************************************************************
;
;                                 Data
;
; *****************************************************************************

UvTxt    db        'CHSMDISK V1.0 - kontrolni soucet disku; (c) Miroslav Nemecek',13,10,'$'
MemTxt   db        'Chyba - nedostatek pameti !',7,13,10,'$'
DiskTxt  db        'Chybne zadani disku !',13,10,'$'
SystTxt  db        'Nekompatibilni operacni system !',13,10,'$'
ReadTxt  db        'Chyba cteni dat z disku !',13,10,'$'

HelpTxt  db        'Zadejte: CHSMDISK  [disk:] [CRC]',13,10
         db        '           disk:  oznaceni disku ke kontrole',13,10
         db        '           CRC    predpokladany kontrolni soucet',13,10
         db        '$'

HlasTxt  db        13,'Zpracovano '
HlasTxt0 db        ' 0%  '
Kurz     db        '[ . . . . . . . . . . . . ]   CRC='
Souc     db        'FFFF $'
HlasTxtX label     near
         db        '$'

SoucTxt  db        'Kontrolni soucet disku '
SoucTxt1 db        'A: je '
SoucTxt2 db        'FFFF.',13,10,'$'

Souc3Txt db        'Kontrolni soucet souhlasi.',13,10,'$'
Souc4txt db        'Kontrolni soucet NESOUHLASI ! ',7,13,10,'$'

Param    db        0                        ; parametry
                                            ;   bit 0: 1=zad n kontroln¡ sou‡et
                                            ;   bit 1: 1=obsluha INT 25h paketem

UkazSekt dd        0                        ; ukazatel ‡ten˜ch sektor–

Soucet0  dw        -1                       ; po‡¡tan˜ kontroln¡ sou‡et

Soucet   dw        ?                        ; p©edpokl dan˜ kontroln¡ sou‡et


Disk     db        ?                        ; ‡¡slo disku

MaxSekt  dd        ?                        ; celkov˜ po‡et sektor– disku
SektSize dw        ?                        ; po‡et bajt– na sektor
BuffSekt dw        ?                        ; maxim ln¡ po‡et sektor– v bufferu

Zasobnik dw        ?                        ; £schova ukazatele z sobn¡ku

BuffSegm dw        ?                        ; adresa datov‚ho bufferu
BuffSize dw        ?                        ; velikost bufferu (bajt–)

Paket    label     word                     ; datov˜ paket pro ‡ten¡ sektor–
PaketSiz dd        ?                        ; ‡¡slo sektoru
PaketNum dw        ?                        ; po‡et sektor–
PaketAdr dd        ?                        ; adresa k na‡ten¡ sektor–

         dw        100h dup(?)              ; z sobn¡k
Zasob    label     byte                     ; konec z sobn¡ku

Code     ends
         end       start

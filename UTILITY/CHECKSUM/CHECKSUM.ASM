
; *****************************************************************************
;
;                         C H E C K  -  S U M
;
;              Kontroln¡ sou‡et soubor– v aktivn¡m adres ©i
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

Start:

; ------ £schova aktivn¡ho disku

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         mov       ds:[homdisk],al          ; £schova aktivn¡ho disku

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         xor       bx,bx
         mov       bl,ds:[80h]              ; d‚lka p©¡kazov‚ho © dku
         mov       byte ptr ds:[bx+81h],0   ; ozna‡en¡ konce textu parametr–

; ------ nalezen¡ za‡ tku textu parametru

Param1:  mov       al,ds:[si]               ; znak z p©¡kazov‚ho © dku
         cmp       al," "
         jb        Param2                   ; nen¡ nic zad no
         inc       si
         cmp       al," "
         jbe       Param1
         dec       si                       ; n vrat prvn¡ho znaku

; ------ test, zda je zad n¡ disku

         cmp       byte ptr ds:[si+1],":"   ; je to zad n¡ disku ?
         jne       Param2                   ; nen¡ zad n disk

; ------ nastaven¡ po‘adovan‚ho disku

         dec       al
         and       al,1fh                   ; ‡¡slo disku
         mov       dl,al                    ; nov˜ disk
         mov       ah,0eh
         int       21h                      ; nastaven¡ nov‚ho disku
         inc       si                       ; p©esko‡en¡ jm‚na disku
         inc       si                       ; p©esko‡en¡ znaku ":"

; ------ £schova p–vodn¡ho adres ©e

Param2:  push      si
         mov       si,offset homdir         ; buffer k £schovˆ adres ©e
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         mov       ah,47h
         int       21h                      ; £schova p–vodn¡ho adres ©e
         pop       si

; ------ definice obsluhy p©eru¨en¡ INT 23h

         mov       ax,2523h                 ; vektor p©eru¨en¡ Ctrl-Break
         mov       dx,offset Start9         ; obsluha p©eru¨en¡ INT 23h
         int       21h                      ; definice obsluhy p©eru¨en¡ INT 23h

; ------ nalezen¡ koncov‚ho lom¡tka "\"

         mov       dx,si                    ; za‡ tek zadan‚ cesty
Param3:  mov       di,si                    ; konec cesty (za posledn¡m "\")
Param4:  mov       al,ds:[si]               ; dal¨¡ znak z textu
         cmp       al," "                   ; konec textu ?
         jb        Param5                   ; nen¡ nic zad no
         inc       si
         cmp       al,"\"                   ; bylo oddˆlovac¡ lom¡tko ?
         je        Param3                   ; bylo lom¡tko - nov˜ konec
         cmp       al," "                   ; je konec textu ?
         jne       Param4                   ; nen¡ konec textu

; ------ nastaven¡ po‘adovan‚ho adres ©e

Param5:  cmp       dx,di                    ; bylo nalezeno nˆjak‚ lom¡tko ?
         je        Param6                   ; nebylo ‘ dn‚ lom¡tko
         mov       ax,di
         sub       ax,dx
         dec       ax
         jnz       Param52
         mov       dx,offset RootDir        ; z kladn¡ adres ©
Param52: mov       byte ptr ds:[di-1],0     ; ozna‡en¡ konce cesty
         mov       ah,3bh
         int       21h                      ; nastaven¡ nov‚ho adres ©e

; ------ £schova masky soubor–

Param6:  cmp       byte ptr ds:[di]," "     ; je platn˜ znak ?
         jbe       Param8                   ; soubor nezad n - v¨echny soubory
         cld
         mov       si,di                    ; zadan  maska
         mov       di,offset all
Param7:  lodsb
         stosb
         cmp       al," "
         ja        Param7                   ; byl to platn˜ znak
         mov       byte ptr ds:[di-1],0     ; ozna‡en¡ konce specifikace

; ------ zobrazen¡ £vodn¡ho textu

Param8:  mov       si,offset uvtxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ na‡ten¡ aktivn¡ho adres ©e

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         add       al,"A"                   ; korekce na znak ASCII
         mov       ds:[aktdisk],al          ; ozna‡en¡ aktivn¡ho disku
         mov       si,offset aktdisk0       ; buffer k na‡ten¡ adres ©e
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         mov       ah,47h
         int       21h                      ; poskytnut¡ aktivn¡ho adres ©e

; ------ stanoven¡ d‚lky textu adres ©e

         mov       di,offset aktdisk        ; aktu ln¡ adres ©
         mov       cx,56                    ; d‚lka © dku
         xor       al,al
         cld
         repne     scasb                    ; nalezen¡ konce textu
         shr       cx,1                     ; po‡et mezer zleva
         jcxz      Start1                   ; nen¡ ‘ dn  mezera

; ------ zobrazen¡ £vodn¡ch mezer p©ed textem adres ©e

Start0:  mov       al," "
         call      DispChar                 ; zobrazen¡ £vodn¡ mezery
         loop      Start0

; ------ zobrazen¡ aktivn¡ho adres ©e

Start1:  mov       si,offset aktdisk        ; aktivn¡ adres ©
         call      DispTxt                  ; zobrazen¡ aktivn¡ho adres ©e
         call      DispCr                   ; od© dkov n¡ textu
         call      DispCr                   ; od© dkov n¡ textu

; ------ nastaven¡ pracovn¡ adresy DTA

         mov       dx,80h
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nalezen¡ prvn¡ho souboru

         mov       di,offset buffer         ; adresa k ulo‘en¡ jm‚na souboru
         mov       dx,offset all            ; specifikace soubor–
         mov       cx,37h                   ; atributy - v¨echny soubory
         mov       ah,4eh                   ; AH <- 4eh
Start2:  int       21h                      ; nalezen¡ prvn¡ho/dal¨¡ho souboru
         jc        Start3                   ; nen¡ dal¨¡ soubor

; ------ adres © se neukl d 

         mov       ah,4fh
         test      byte ptr ds:[95h],10h    ; je to adres © ?
         jnz       Start2                   ; je to adres © - dal¨¡ soubor

; ------ ulo‘en¡ souboru do seznamu

         call      StoreFil                 ; ulo‘en¡ souboru do bufferu
         mov       ah,4fh
         jmp       short Start2             ; dal¨¡ soubor

; ------ dek¢dov n¡ jm‚na jednoho souboru

Start3:  mov       si,offset buffer         ; adresa za‡ tku seznamu
         cmp       si,di
         je        Start6                   ; nen¡ ‘ dn˜ soubor
Start4:  push      si
         push      di
         call      DekName                  ; dek¢dov n¡ jm‚na souboru

; ------ nalezen¡ souboru

         mov       dx,offset all            ; jm‚no souboru
         mov       cx,37h                   ; atributy - v¨echny soubory
         mov       ah,4eh
         int       21h                      ; nalezen¡ souboru
         jc        Start5

; ------ zobrazen¡ informac¡ o souboru

         inc       word ptr ds:[souboru]    ; zv˜¨en¡ ‡¡ta‡e soubor–
         call      DispFile                 ; zobrazen¡ nalezen‚ho souboru
         call      SumFile                  ; kontroln¡ sou‡et souboru
         call      DispCr                   ; od© dkov n¡ textu

; ------ p©¡prava pro dal¨¡ soubor

Start5:  pop       di
         pop       si
         add       si,11                    ; zv˜¨en¡ adresy v bufferu jmen
         cmp       si,di                    ; je ji‘ konec bufferu ?
         jb        Start4                   ; nen¡ je¨tˆ konec bufferu

; ------ zobrazen¡ z vˆre‡n˜ch informac¡

Start6:  mov       si,offset uvtxt2         ; koncov  ‡ ra
         call      DispTxt                  ; zobrazen¡ koncov‚ ‡ ry

; ------ dek¢dov n¡ po‡tu soubor–

         mov       di,offset celkem + 11    ; adresa k ulo‘en¡ po‡tu soubor–
         mov       ax,ds:[souboru]          ; po‡et nalezen˜ch soubor–
         call      DekNum0                  ; dek¢dov n¡ po‡tu soubor–

; ------ dek¢dov n¡ sou‡tu velikost¡

         mov       ax,word ptr ds:[soucet]  ; ni‘¨¡ slovo sou‡tu velikost¡
         mov       dx,word ptr ds:[soucet+2]; vy¨¨¡ slovo sou‡tu velikost¡
         mov       di,offset celkem + 21    ; adresa k ulo‘en¡ sou‡tu velikost¡
         call      DekNum                   ; dek¢dov n¡ sou‡tu velikost¡

; ------ zobrazen¡ koncov‚ho textu

         mov       si,offset celkem
         call      DispTxt

; ------ zobrazen¡ kontroln¡ho sou‡tu

         mov       ax,ds:[chsumc]           ; celkov˜ kontroln¡ sou‡et soubor–
         call      DispWord                 ; zobrazen¡ kontroln¡ho sou‡tu
         call      DispCr                   ; od© dkov n¡ textu

; ------ konec programu

Start9:  push      cs
         pop       ds
         mov       ah,3bh
         mov       dx,offset homdir0        ; p–vodn¡ adres ©
         int       21h                      ; n vrat p–vodn¡ho adres ©e
         mov       dl,ds:[homdisk]          ; p–vodn¡ disk
         mov       ah,0eh
         int       21h                      ; n vrat p–vodn¡ho disku
         int       20h

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ jm‚na souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=soubor ve vnit©n¡m tvaru
; -----------------------------------------------------------------------------

DekName  PROC      NEAR

         push      ax
         push      cx
         push      si
         push      di
         cld
                                          ;* jm‚no souboru pro zobrazen¡
         mov       di,offset soubor         ; jm‚no souboru
         push      si
         mov       cx,8
         rep       movsb                    ; p©enos jm‚na souboru
         mov       al," "
         stosb                              ; oddˆlovac¡ mezera
         mov       cl,3
         rep       movsb
         pop       si

                                          ;* dek¢dov n¡ jm‚na souboru
         mov       di,offset all            ; buffer k ulo‘en¡ rozboru
         mov       cx,8                     ; d‚lka jm‚na souboru
         push      si
DekName1:lodsb
         cmp       al," "
         je        DekName2
         stosb
         loop      DekName1
DekName2:mov       al,"."
         stosb
         pop       si
         add       si,8

                                          ;* dek¢dov n¡ p©¡pony souboru
         mov       cx,3                     ; d‚lka p©¡pony souboru
DekName3:lodsb
         cmp       al," "
         je        DekName4
         stosb
         loop      DekName3
DekName4:xor       al,al
         stosb

         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DekName  ENDP

; -----------------------------------------------------------------------------
;        Ulo‘en¡ jm‚na souboru do bufferu (DI=konec seznamu)
; -----------------------------------------------------------------------------

StoreFil PROC      NEAR

; ------ dek¢dov n¡ jm‚na souboru

         push      di                       ; £schova konce seznamu
         mov       di,offset soubor         ; buffer k ulo‘en¡ jm‚na
         mov       si,9eh
         mov       cx,8                     ; d‚lka jm‚na souboru
         call      StoreNm                  ; ulo‘en¡ jm‚na do bufferu
         cmp       byte ptr ds:[si],"."     ; je oddˆlovac¡ te‡ka ?
         jne       StoreFl2                 ; nen¡ oddˆlovac¡ te‡ka
         inc       si                       ; p©esko‡en¡ oddˆlovac¡ te‡ky
StoreFl2:mov       cx,3                     ; d‚lka p©¡pony souboru
         call      StoreNm                  ; ulo‘en¡ p©¡pony souboru
         pop       di

; ------ nalezen¡ m¡sta k ulo‘en¡ souboru

         mov       si,offset soubor         ; jm‚no souboru
         mov       bx,offset buffer         ; za‡ tek bufferu
         call      SrcName                  ; nalezen¡ jm‚na v seznamu

; ------ vytvo©en¡ m¡sta pro soubor

         push      di
         push      si

         std
         mov       si,di                    ; konec seznamu
         mov       cx,di                    ; konec seznamu
         add       di,10                    ; nov˜ konec seznamu
         dec       si
         sub       cx,bx                    ; d‚lka zbytku dat k odsunu
         rep       movsb                    ; odsun zbyl˜ch dat

         cld
         pop       si
         pop       di

; ------ ulo‘en¡ nov‚ho souboru

         push      di
         mov       di,bx                    ; adresa pro nov˜ soubor
         mov       cx,11                    ; d‚lka jm‚na
         rep       movsb                    ; p©enos jm‚na nov‚ho souboru
         pop       di
         add       di,11                    ; nov˜ konec seznamu
         ret

StoreFil ENDP

; -----------------------------------------------------------------------------

StoreNm:
                                          ;* ulo‘en¡ ‡ sti jm‚na
                                            ; VSTUP: CX=po‡et znak– k ulo‘en¡
                                            ;        ES:DI=ukl dac¡ adresa
                                            ;        DS:SI=jm‚no souboru
         push      ax
         cld
StoreNm1:lodsb
         or        al,al
         jz        StoreNm3                 ; je konec textu
         cmp       al,"."
         jne       StoreNm4                 ; nen¡ oddˆlovac¡ te‡ka
StoreNm3:dec       si                       ; n vrat posledn¡ho znaku
         mov       al," "                   ; n hradn¡ znak mezery
StoreNm4:stosb
         loop      StoreNm1                 ; dal¨¡ znak
StoreNm2:pop       ax
         ret

; -----------------------------------------------------------------------------
;        Nalezen¡ souboru v seznamu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=hledan˜ soubor
;        ES:BX=za‡ tek seznamu
;        ES:DI=konec seznamu
; -----------------------------------------------------------------------------
; VSTUP:ES:BX=m¡sto k ulo‘en¡ souboru
; -----------------------------------------------------------------------------

PUBLIC   SrcName
SrcName  PROC      NEAR

; ------ £schova registr–

         push      dx
         push      di
         mov       dx,di                    ; konec seznamu
         mov       di,bx                    ; za‡ tek seznamu

; ------ kontrola, zda je ji‘ konec seznamu

SrcName1:cmp       di,dx                    ; je ji‘ konec seznamu ?
         jae       SrcName3                 ; je ji‘ konec seznamu

; ------ porovn n¡ jm‚na souboru

         call      CmpName                  ; je spr vn‚ m¡sto v seznamu ?
         jbe       SrcName3                 ; m¡sto nalezeno

; ------ dal¨¡ polo‘ka v seznamu

         add       di,11                    ; zv˜¨en¡ adresy v bufferu
         jmp       short SrcName1           ; dal¨¡ soubor

; ------ n vrat registr–

SrcName3:mov       bx,di                    ; adresa k ulo‘en¡ souboru
         pop       di
         pop       dx
         ret

SrcName  ENDP

; -----------------------------------------------------------------------------
;        Porovn n¡ jmen soubor– DS:SI a ES:DI
; -----------------------------------------------------------------------------

PUBLIC   CmpName
CmpName  PROC      NEAR

         push      cx
         push      si
         push      di
         cld
         mov       cx,11                    ; d‚lka jm‚na s p©¡ponou
         repe      cmpsb                    ; porovn n¡ jmen soubor–
         pop       di
         pop       si
         pop       cx
         ret

CmpName  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ informac¡ o souboru
; -----------------------------------------------------------------------------

DispFile PROC      NEAR

         push      di
                                          ;* vymaz n¡ ‡¡sla velikosti souboru
         mov       al," "                   ; mazac¡ mezera
         mov       di,offset soubor+12      ; za‡ tek k vymaz n¡
         mov       cx,9                     ; d‚lka textu - 1
         cld
         rep       stosb                    ; vymaz n¡ informa‡n¡ho textu

                                          ;* dek¢dov n¡ velikosti souboru
         mov       ax,ds:[9ah]              ; ni‘¨¡ slovo velikosti souboru
         mov       dx,ds:[9ch]              ; vy¨¨¡ slovo velikosti souboru
         add       word ptr ds:[soucet],ax  ; p©i‡ten¡ ni‘¨¡ho slova velikosti
         adc       word ptr ds:[soucet+2],dx ; p©i‡ten¡ vy¨¨¡ho slova velikosti
         call      DekNum                   ; dek¢dov n¡ ‡¡sla DX:AX

                                          ;* dek¢dov n¡ data souboru
         mov       di,offset soubor + 24    ; za‡ tek k ulo‘en¡ data
         mov       ax,ds:[98h]              ; datum souboru
         call      DekDatum                 ; dek¢dov n¡ data souboru

                                          ;* dek¢dov n¡ ‡asu souboru
         mov       di,offset soubor + 36    ; za‡ tek k ulo‘en¡ ‡asu
         mov       ax,ds:[96h]              ; ‡as souboru
         call      DekCas                   ; dek¢dov n¡ ‡asu souboru

                                          ;* dek¢dov n¡ atribut– souboru
         mov       di,offset soubor + 46    ; za‡ tek k ulo‘en¡ atribut–
         mov       al,ds:[95h]              ; atributy souboru
         call      DekAtrib                 ; dek¢dov n¡ atribut– souboru


         mov       si,offset soubor         ; informace o souboru
         call      DispTxt                  ; zobrazen¡ informac¡ o souboru

         pop       di
         ret

DispFile ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ atribut– souboru
; -----------------------------------------------------------------------------
; VSTUP: AL=atributy souboru
;        DS:DI=ukl dac¡ adresa textu
; -----------------------------------------------------------------------------

PUBLIC   DekAtrib
DekAtrib PROC      NEAR

         push      ax
         push      bx

         mov       bl,al                    ; atributy souboru
         mov       al,"A"                   ; archivn¡ atribut
         call      DekAtr4                  ; dek¢dov n¡ atributu ARC
         add       bl,bl
         add       bl,bl
         mov       al,"S"
         call      DekAtr4
         mov       al,"H"
         call      DekAtr4
         mov       al,"R"
         call      DekAtr4

         pop       bx
         pop       ax
         ret

DekAtrib ENDP

; -----------------------------------------------------------------------------

DekAtr4: test      bl,20h                   ; je atributu nastaven ?
         jnz       DekAtr5                  ; atribut je nastaven
         mov       al,"."                   ; atribut nen¡ nastaven
DekAtr5: mov       ds:[di],al               ; ulo‘en¡ znaku atributu
         inc       di                       ; zv˜¨en¡ ukazatele textu
         add       bl,bl                    ; posun atributu vlevo
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ data souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=datum souboru
;        DS:DI=ukl dac¡ adresa textu
; -----------------------------------------------------------------------------

PUBLIC   DekDatum
DekDatum PROC      NEAR

         push      cx
         push      di

                                          ;* dek¢dov n¡ dne data
         push      ax
         and       al,1fh                   ; den
         call      DekNm2s                  ; dek¢dov n¡ data s mezerou
         pop       ax

                                          ;* dek¢dov n¡ mˆs¡ce data
         push      ax
         mov       cl,5                     ; po‡et rotac¡
         shr       ax,cl
         and       al,0fh                   ; mˆs¡c
         call      DekNm20                  ; dek¢dov n¡ mˆs¡ce s nulou
         inc       di
         pop       ax

                                          ;* dek¢dov n¡ roku data
         push      ax
         mov       cl,9                     ; po‡et rotac¡
         shr       ax,cl
         and       ax,7fh                   ; rok od 1980
         add       ax,1980                  ; korekce na spr vn˜ rok
         add       di,3
         call      DekNum0                  ; dek¢dov n¡ ‡¡sla AX
         pop       ax

         pop       di
         pop       cx
         ret

DekDatum ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ ‡asu souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=‡as souboru
;        DS:DI=ukl dac¡ adresa textu
; -----------------------------------------------------------------------------

PUBLIC   DekCas
DekCas   PROC      NEAR

         push      cx
         push      di

                                          ;* dek¢dov n¡ hodiny ‡asu
         push      ax
         mov       cl,11
         shr       ax,cl                    ; hodina
         call      DekNm2s                  ; dek¢dov n¡ hodiny s mezerou
         pop       ax

                                          ;* dek¢dov n¡ minuty ‡asu
         push      ax
         mov       cl,5                     ; po‡et rotac¡
         shr       ax,cl
         and       al,3fh                   ; minuta
         call      DekNm20                  ; dek¢dov n¡ minuty s nulou
         inc       di                       ; p©esko‡en¡ dvojte‡ky
         pop       ax

                                          ;* dek¢dov n¡ sekundy ‡asu
         push      ax
         and       al,1fh
         add       al,al                    ; sekunda * 2
         call      DekNm20                  ; dek¢dov n¡ sekundy
         pop       ax

         pop       di
         pop       cx
         ret

DekCas   ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ ‡¡sla AL s mezerou
; -----------------------------------------------------------------------------

PUBLIC   DekNm2s

DekNm2s  PROC      NEAR

         push      ax
         mov       byte ptr ds:[di]," "
         inc       di
         push      di
         xor       ah,ah
         call      DekNum0
         pop       di
         inc       di
         inc       di
         pop       ax
         ret

DekNm2s  ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ ‡¡sla AL s nulou
; -----------------------------------------------------------------------------

PUBLIC   DekNm20

DekNm20  PROC      NEAR

         push      ax
         mov       byte ptr ds:[di],"0"
         inc       di
         push      di
         xor       ah,ah
         call      DekNum0
         pop       di
         inc       di
         pop       ax
         ret

DekNm20  ENDP

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=datov˜ buffer
; -----------------------------------------------------------------------------

SumFile  PROC      NEAR

         mov       word ptr ds:[chsum],-1   ; inicializa‡n¡ slovo

                                          ;* otev©en¡ souboru
         mov       dx,offset all            ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        SumFile8                 ; chyba otev©en¡ souboru
         mov       bx,ax                    ; identifik tor souboru

                                          ;* ‡ten¡ bloku dat do pamˆti
SumFile2:mov       dx,di                    ; buffer pro ‡ten¡
         mov       cx,0e000h                ; konec pamˆti
         sub       cx,dx                    ; maxim ln¡ velikost dat k na‡ten¡
         mov       ah,3fh                   ; AH <- 3fh
         int       21h                      ; na‡ten¡ bloku dat
         jc        SumFile7                 ; chyba ‡ten¡

                                          ;* kontrola konce souboru
         mov       cx,ax                    ; po‡et na‡ten˜ch bajt–
         jcxz      SumFile7                 ; je konec souboru

                                          ;* kontroln¡ sou‡et bloku dat
         mov       dx,ds:[chsum]            ; kontroln¡ sou‡et
         mov       si,di                    ; za‡ tek bloku na‡ten˜ch dat
         call      CheckSum                 ; kontroln¡ sou‡et dat
         mov       ds:[chsum],dx            ; nov  hodnota kontr. sou‡tu

                                          ;* celkov˜ kontroln¡ sou‡et
         mov       dx,ds:[chsumc]           ; celkov˜ kontroln¡ sou‡et
         mov       si,di                    ; za‡ tek bloku na‡ten˜ch dat
         call      CheckSum                 ; kontroln¡ sou‡et dat
         mov       ds:[chsumc],dx           ; nov  hodnota celk. kontr. sou‡tu

         jmp       short SumFile2           ; dal¨¡ blok dat

                                          ;* uzav©en¡ souboru
SumFile7:mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

SumFile8:
         mov       ax,ds:[chsum]            ; kontroln¡ sou‡et souboru
         call      DispWord                 ; zobrazen¡ kontroln¡ho sou‡tu

         ret

SumFile  ENDP

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
;        DX=vstupn¡ hodnota kontroln¡ho sou‡tu
; VSTUP:DX=v˜stupn¡ hodnota kontroln¡ho sou‡tu
; -----------------------------------------------------------------------------

PUBLIC   CheckSum

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

; -----------------------------------------------------------------------------
;        Od© dkov n¡ textu
; -----------------------------------------------------------------------------

PUBLIC   DispCr

DispCr   PROC      NEAR

         push      si
         mov       si,offset CrTxt
         call      DispTxt                  ; zobrazen¡ textu od© dkov n¡
         pop       si
         ret

DispCr   ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ textu DS:SI
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
DispTxt1:cld
         lodsb                              ; znak k zobrazen¡
         or        al,al                    ; je konec textu ?
         jz        DispTxt2                 ; je konec textu
         call      DispChar                 ; zobrazen¡ znaku
         jmp       short DispTxt1           ; dal¨¡ znak k zobrazen¡
DispTxt2:pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ ‡¡sla DX:AX od adresu DS:DI dol–
; -----------------------------------------------------------------------------

PUBLIC   DekNum0

DekNum0  PROC      NEAR

         push      dx
         xor       dx,dx
         call      DekNum
         pop       dx
         ret

DekNum0  ENDP

PUBLIC   DekNum
DekNum   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         mov       cx,10                    ; dˆlitel pro dekadick˜ z klad

                                          ;* v˜po‡et jedn‚ ‡¡slice
DekNum1: mov       bx,ax                    ; £schova ni‘¨¡ho slova
         mov       ax,dx                    ; vy¨¨¡ slovo ‡¡sla
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; pod¡l z vy¨¨¡ho slova
         xchg      ax,bx                    ; £schova nov‚ho vy¨¨¡ho slova
         div       cx                       ; pod¡l z ni‘¨¡ho slova
         add       dl,"0"                   ; korekce na ‡¡slici
         mov       ds:[di],dl               ; ulo‘en¡ ‡¡slice
         mov       dx,bx                    ; n vrat nov‚ho vy¨¨¡ho slova
         dec       di                       ; sn¡‘en¡ ukazatele textu
         or        ax,ax                    ; je je¨tˆ dal¨¡ ‡¡slo ?
         jnz       DekNum1                  ; je je¨tˆ ‡¡slo
         or        dx,dx                    ; je je¨tˆ ‡¡slo ?
         jnz       DekNum1                  ; je je¨tˆ ‡¡slo

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ slova ve form tu HEX
; -----------------------------------------------------------------------------

PUBLIC   DispWord

DispWord PROC      NEAR

         xchg      ah,al                    ; AL <- vy¨¨¡ bajt slova
         call      DispByte                 ; zobrazen¡ vy¨¨¡ho bajtu slova
         xchg      ah,al                    ; AL <- ni‘¨¡ bajt slova

                                          ;* zobrazen¡ bajtu AL v HEX form tu
DispByte:push      ax                       ; £schova bajtu k zobrazen¡
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1                     ; nastaven¡ vy¨¨¡ tetr dy
         call      DispHex                  ; zobrazen¡ ni‘¨¡ tetr dy bajtu
         pop       ax                       ; n vrat bajtu k zobrazen¡

                                          ;* zobrazen¡ tetr dy AL v HEX form tu
DispHex: push      ax
         and       al,0fh                   ; maska ni‘¨¡ tetr dy
         add       al,"0"                   ; korekce na ASCII znak
         cmp       al,"9"                   ; je p¡smeno ?
         jbe       DispHex2                 ; je ‡¡slice - OK
         add       al,7                     ; korekce na p¡smeno
DispHex2:call      DispChar                 ; zobrazen¡ znaku HEX
         pop       ax
         ret

DispWord ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ znaku
; -----------------------------------------------------------------------------

DispChar PROC      NEAR

         push      ax
         push      dx
                                          ;* nov˜ © dek CR
         cmp       al,13
         jne       DispChr1                 ; nen¡ CR
         mov       byte ptr ds:[pozice],0   ; nulov n¡ pozice na © dku
         jmp       short DispChr2

                                          ;* posun o © dek nezvy¨uje pozici
DispChr1:cmp       al,10                    ; je LF ?
         je        DispChr2                 ; je LF
         inc       byte ptr ds:[pozice]     ; zv˜¨en¡ pozice na © dku

DispChr2:mov       ah,2
         mov       dl,al                    ; znak k zobrazen¡
         int       21h                      ; zobrazen¡ znaku

         pop       dx
         pop       ax
         ret

DispChar ENDP

; -----------------------------------------------------------------------------
;                                 DATA
; -----------------------------------------------------------------------------

uvtxt    db        'CheckSum V 1.10 - kontrolni soucet; (c) Miroslav Nemecek'
         db        13,10
uvtxt2   db        '--------------------------------------------------------'
CrTxt    db        13,10,0

soubor   db        '???????? ???0000000000  00.00.0000  00:00:00  ASHR  ',0

celkem   db        'Celkem:                                             ',0

                                          ;* maska zadan˜ch soubor–
all      db        '*.*',0                  ; specifikace - v¨echny soubory
         db        0,0,0,0,0,0,0,0,0        ; zbytek bufferu pro jm‚no

chsum    dw        -1                       ; kontroln¡ sou‡et souboru
chsumc   dw        -1                       ; celkov˜ kontroln¡ sou‡et
souboru  dw        0                        ; celkem soubor–
soucet   dd        0                        ; sou‡et velikost¡ soubor–

pozice   db        0                        ; ukazatel pozice kurzoru na © dku

adrdat   dw        0                        ; adresa bufferu pro ‡ten¡ dat

homdisk  db        0                        ; p–vodn¡ disk
homdir0  db        '\'                      ; inicializa‡n¡ znak adres ©e
homdir   db        70 dup(0)                ; p–vodn¡ adres ©

RootDir  db        '\',0

aktdisk  db        'A:\'
aktdisk0 label     byte                     ; zde se na‡te adres ©

buffer   db        0e000h dup(0)            ; buffer ke ‡ten¡ adres ©e a soubor–

code     ENDS
         END       Start

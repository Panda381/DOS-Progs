
; V cel‚m programu se dodr‘uje DS=ES=CS

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©¡prava p©¡kazov‚ho © dku

Start:   mov       si,81h
         mov       bl,ds:[si-1]
         mov       bh,0
         mov       ds:[si+bx],bh

; ------ test, zda jsou parametry

Start1:  call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jnc       Start18
Start12: jmp       Start5                   ; nejsou parametry

Start18: cmp       al,"?"
         jne       Start19
         jmp       Start4                   ; n povˆda

Start19: cmp       al,"/"
         jne       Start12                  ; nejsou parametry

; ------ na‡ten¡ parametru

Start2:  call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ znaku
         jc        Start49                  ; nen¡ dal¨¡ znak
         cmp       al,"/"
         je        Start2

; ------ parametr "/L" - v˜pis nastaven¡

         cmp       al,"L"
         jne       Start21
         push      si
         call      ParList                  ; v˜pis parametr–
         pop       si
         jmp       short Start2

; ------ parametr "/S" vyhled n¡ textu

Start21: cmp       al,"S"
         jne       Start22
         call      RozbDat                  ; rozbor dat
         jc        Start2                   ; nen¡ nic zad no
         push      si
         call      ParSrch                  ; vyhled n¡ textu
         pop       si
         jmp       short Start244

; ------ zobrazen¡ dat

Start22: cmp       al,"H"
         jne       Start23
         call      RozbHNm0                 ; zad n¡ offsetu
         push      si
         call      ZobrDat                  ; zobrazen¡ dat
         pop       si
         jmp       short Start244

; ------ parametr "/T" - text v˜pisu

Start23: cmp       al,"T"
         jne       Start24
         mov       di,offset SoubText
         call      RozbFile                 ; rozbor jm‚na souboru
         jc        Start4                   ; chyba- zobrazen¡ n povˆdy
         call      ReadText                 ; na‡ten¡ textu koment ©e
         jc        Start49                  ; chyba
         jmp       short Start242           ; ulo‘en¡ programu

; ------ parametr "/F" - jm‚no modifikovan‚ho programu

Start24: cmp       al,"F"
         jne       Start25
         mov       di,offset ModiSoub       ; buffer jm‚na souboru
         call      RozbFile                 ; rozbor jm‚na souboru
Start242:call      WritProg                 ; z pis programu
Start244:jc        Start49                  ; chyba z pisu
Start246:jmp       short Start2

; ------ parametr "/V" - verifikace dat

Start25: cmp       al,"V"
         jne       Start26
         call      RozbHNm0                 ; zad n¡ offsetu
         jc        Start246
         call      RozbDat                  ; na‡ten¡ dat
         push      si
         call      Verif                    ; na‡ten¡ verifikace
         pop       si
         jmp       short Start242

; ------ parametr "/W" - z pis dat

Start26: cmp       al,"W"
         jne       Start4                   ; chyba
         call      RozbHNm0                 ; zad n¡ offsetu
         jc        Start246
         call      RozbDat                  ; na‡ten¡ dat
         push      si
         call      Zapis                    ; na‡ten¡ parametr– z pisu
         pop       si
         jmp       short Start242

; ------ zobrazen¡ textu n povˆdy

Start4:  mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
Start49: int       20h


; ====== modifikace souboru

; ------ £vodn¡ hl ¨en¡

Start5:  call      DispHlas                 ; zobrazen¡ £vodn¡ho hl ¨en¡

; ------ ‡ek n¡ na kl vesu

         mov       ax,0c08h
         int       21h

; ------ test, zda je p©eru¨en¡ programu

         cmp       al,27
         jne       Start6
Start52: int       20h

; ------ otev©en¡ modifikovan‚ho souboru

Start6:  mov       dx,offset ModiSoub
         cmp       byte ptr ds:[ModiSoub],0 ; je soubor ?
         je        Start52                  ; soubor nezad n
         mov       ax,3d02h
         int       21h
         xchg      ax,bx
         jnc       Start62

; ------ chyba otev©en¡ souboru

         call      OpenErr
         int       20h

; ------ test, zda je konec tabulky

Start62: mov       si,offset TabKod         ; tabulka k¢d–
Start64: cmp       si,ds:[AdrHlas]          ; je konec tabulky ?
         jae       Start7                   ; konec tabulky

; ------ nastaven¡ ukazatele v souboru

         mov       ax,ds:[si]
         mov       dx,ds:[si+2]
         test      dh,80h
         jnz       Start69                  ; nen¡ verifikace
         call      SetUFile                 ; nastaven¡ ukazatele v souboru

; ------ na‡ten¡ dat ze souboru

         mov       dx,offset DatBuff        ; datov˜ buffer
         mov       cl,ds:[si+4]             ; po‡et dat k na‡ten¡
         mov       ch,0
         mov       ah,3fh
         int       21h                      ; na‡ten¡ dat
         jc        Start68                  ; chyba
         cmp       ax,cx
         jne       Start68

; ------ porovn n¡ dat

         push      si
         cld
         mov       di,dx                    ; na‡ten  data
         add       si,5                     ; za‡ tek dat
         repe      cmpsb                    ; porovn n¡ dat
         pop       si
         je        Start69                  ; je to OK

; ------ chyba - nen¡ platn˜ soubor

Start68: mov       dx,offset VerifTxt
         call      DispTxt
         int       20h

; ------ nalezen¡ dal¨¡ polo‘ky k verifikaci

Start69: call      NextKod                  ; adresa dal¨¡ polo‘ky
         jnc       Start64

; ------ £schova data (-> DI) a ‡asu souboru (-> BP)

Start7:  mov       ax,5700h
         int       21h                      ; poskytnut¡ data a ‡asu
         mov       di,dx                    ; datum
         mov       bp,cx                    ; ‡as

; ------ test, zda je konec tabulky

         mov       si,offset TabKod         ; tabulka k¢d–
Start74: cmp       si,ds:[AdrHlas]          ; je konec tabulky ?
         jae       Start9                   ; konec tabulky

; ------ nastaven¡ ukazatele v souboru

         mov       ax,ds:[si]
         mov       dx,ds:[si+2]
         test      dh,80h
         jz        Start79                  ; nen¡ z pis
         and       dh,not 80h
         call      SetUFile                 ; nastaven¡ ukazatele v souboru

; ------ z pis dat do souboru

         mov       dx,si                    ; datov˜ buffer
         add       dx,5
         mov       cl,ds:[si+4]             ; po‡et dat k z pisu
         mov       ch,0
         mov       ah,40h
         int       21h                      ; na‡ten¡ dat
         jc        Start78                  ; chyba
         cmp       ax,cx
         je        Start79

; ------ chyba z pisu

Start78: mov       dx,offset WritTxt
         call      DispTxt
         stc
         jmp       short Start9

; ------ nalezen¡ dal¨¡ polo‘ky k verifikaci

Start79: call      NextKod                  ; adresa dal¨¡ polo‘ky
         jnc       Start74
         clc

; ------ n vrat data (DI) a ‡asu souboru (BP)

Start9:  pushf

         mov       ax,5701h
         mov       dx,di                    ; datum
         mov       cx,bp                    ; ‡as
         int       21h                      ; nastaven¡ data a ‡asu

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

         popf
         jc        StartA

         mov       dx,offset OKTxt
         call      DispTxt

StartA:  int       20h

; -----------------------------------------------------------------------------
;        parametry pro z pis
; -----------------------------------------------------------------------------

Zapis    PROC      NEAR

; ------ zru¨en¡ star‚ polo‘ky

         mov       dx,word ptr ds:[DatOffs+2]
         or        dh,80h                   ; p©¡znak z pisu
         jmp       short Verif1

Zapis    ENDP

; -----------------------------------------------------------------------------
;        parametr pro verifikaci
; -----------------------------------------------------------------------------
;þ
Verif    PROC      NEAR

; ------ zru¨en¡ star‚ polo‘ky

         mov       dx,word ptr ds:[DatOffs+2]
         and       dh,not 80h               ; p©¡znak verifikace
Verif1:  mov       ax,word ptr ds:[DatOffs]
         call      SrcKod                   ; nalezen¡ polo‘ky -> SI
         jc        Verif2                   ; polo‘ka nenalezena
         call      DelKod                   ; zru¨en¡ polo‘ky

; ------ vytvo©en¡ m¡sta pro novou polo‘ku (adresa SI)

Verif2:  mov       cx,ds:[DatNum]           ; po‡et vkl dan˜ch bajt–
         jcxz      Verif9                   ; nejsou ‘ dn  data
         push      cx
         add       cx,5                     ; v‡etnˆ z hlav¡
         call      InsDat                   ; vytvo©en¡ m¡sta
         pop       cx
         jc        Verif9

; ------ ulo‘en¡ offsetu

         mov       di,si                    ; DI <- nov  polo‘ka
         cld
         stosw                              ; offset LOW
         xchg      ax,dx
         stosw                              ; offset HIGH

; ------ p©enesen¡ dat

         mov       al,cl
         stosb                              ; d‚lka dat
         mov       si,offset DatBuff
         rep       movsb                    ; p©enesen¡ dat

Verif9:  ret

Verif    ENDP

; -----------------------------------------------------------------------------
;        vyhled n¡ offsetu DX:AX (bit15=z pis) -> DS:SI (NC=nalezen stejn˜ offset)
; -----------------------------------------------------------------------------

SrcKod   PROC      NEAR

; ------ test konce tabulky

         mov       si,offset TabKod         ; tabulka k¢d–
SrcKod1: cmp       si,ds:[AdrHlas]          ; je konec tabulky ?
         jae       SrcKod7                  ; je konec tabulky

; ------ porovn n¡ offset– bez kontroly p©¡znaku

         push      ax
         push      dx
         mov       ax,ds:[si+2]
         and       ah,not 80h
         and       dh,not 80h
         cmp       dx,ax
         pop       dx
         pop       ax
         jne       SrcKod2
         cmp       ax,ds:[si]

; ------ nalezen vy¨¨¡ offset - m¡sto plat¡ OK

SrcKod2: jb        SrcKod7                  ; nalezen vy¨¨¡ offset - konec
         je        SrcKod4                  ; nalezena stejn  polo‘ka

; ------ nalezen ni‘¨¡ offset - hled n¡ dal¨¡ polo‘ky

SrcKod3: call      NextKod                  ; dal¨¡ polo‘ka
         jmp       short SrcKod1            ; test dal¨¡ polo‘ky

; ------ nalezen  stejn˜ offset - porovn n¡ p©¡znak–

SrcKod4: cmp       dh,ds:[si+2+1]           ; porovn n¡ p©¡znak–
         je        SrcKod8                  ; nalezen stejn˜ offset OK
         ja        SrcKod3                  ; z pis p©ed verifikac¡ - dal¨¡

SrcKod7: stc                                ; p©¡znak - nenalezen stejn˜ offset
SrcKod8: ret

SrcKod   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ polo‘ky z tabulky DS:SI
; -----------------------------------------------------------------------------

DelKod   PROC      NEAR

         push      cx
         mov       cx,si
         call      NextKod                  ; dal¨¡ polo‘ka
         jc        DelKod2                  ; nen¡ dal¨¡ polo‘ka

         sub       si,cx                    ; d‚lka dal¨¡ polo‘ky
         xchg      si,cx
         call      DelDat                   ; zru¨en¡ dal¨¡ polo‘ky

DelKod2: pop       cx
         ret

DelKod   ENDP

; -----------------------------------------------------------------------------
;        vytvo©en¡ m¡sta pro data DS:SI/CX bajt– (DS=ES !, CY=chyba)
; -----------------------------------------------------------------------------

InsDat   PROC      NEAR

         push      ax
         push      cx
         push      si
         push      di

         mov       ax,ds:[AdrKonec]
         add       ax,200h
         add       ax,cx
         jc        InsDat9
         cmp       sp,ax
         jc        InsDat9

         add       ds:[AdrHlas],cx          ; oprava adresy textu
         mov       ax,ds:[AdrKonec]         ; adresa konce
         sub       ax,si                    ; velikost zbytku dat
         add       ds:[AdrKonec],cx         ; oprava adresy konce

         add       si,ax                    ; sou‡asn˜ konec
         dec       si                       ; posledn¡ bajt dat
         mov       di,si                    ; DI <- star˜ konec
         add       di,cx                    ; nov˜ konec dat

         std
         xchg      ax,cx                    ; CX <- d‚lka dat k odsunu
         rep       movsb                    ; odsun dat
         clc

InsDat9: pop       di
         pop       si
         pop       cx
         pop       ax
         ret

InsDat   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ dat z tabulky DS:SI/CX bajt– (DS=ES !)
; -----------------------------------------------------------------------------

DelDat   PROC      NEAR

         push      cx
         push      si
         push      di

         sub       ds:[AdrHlas],cx          ; oprava adresy textu hl ¨en¡
         mov       di,si                    ; za‡ tek dat k ru¨en¡
         add       si,cx                    ; za‡ tek zbytku dat
         mov       cx,ds:[AdrKonec]         ; konec dat
         sub       cx,si                    ; d‚lka zbytku dat

         cld
         rep       movsb                    ; p©¡sun zbytku dat
         mov       ds:[AdrKonec],di         ; nov˜ konec dat

         pop       di
         pop       si
         pop       cx
         ret

DelDat   ENDP

; -----------------------------------------------------------------------------
;        dal¨¡ polo‘ka v tabulce DS:SI (CY=nen¡)
; -----------------------------------------------------------------------------

NextKod  PROC      NEAR

         cmp       si,ds:[AdrHlas]
         cmc
         jc        NextKod9

         push      ax
         add       si,4
         cld
         lodsb
         mov       ah,0
         add       si,ax
         pop       ax
;         clc
NextKod9:ret

NextKod  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ dat offsetu DX:AX (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------

ZobrDat  PROC      NEAR

; ------ otev©en¡ souboru

         mov       dx,offset ModiSoub
         mov       ax,3d00h
         int       21h
         xchg      ax,bx
         jnc       ZobrDat2

; ------ chyba otev©en¡ souboru

ZobrDat1:call      OpenErr
         ret

; ------ nastaven¡ ukazatele v souboru CX:DX

ZobrDat2:call      SetUFil0                 ; nastaven¡ ukazatele dat

; ------ na‡ten¡ dat

         mov       dx,offset DatBuff        ; buffer
         mov       cx,128
         mov       ah,3fh
         int       21h
         jnc       ZobrDat3
         xor       ax,ax
ZobrDat3:add       ax,dx                    ; adresa konce dat
         xchg      ax,bp                    ; BP <- adresa konce dat
         mov       si,dx                    ; ukazatel dat v bufferu

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

; ------ test, zda je konec dat

ZobrDat4:cmp       si,bp
         jb        ZobrDat5
         ret                                ; (zde je NC)

; ------ zobrazen¡ adresy

ZobrDat5:mov       ax,word ptr ds:[DatOffs]
         mov       dx,word ptr ds:[DatOffs+2]
         call      DispHDw
         add       word ptr ds:[DatOffs],16 ; zv˜¨en¡ ukazatele dat
         adc       word ptr ds:[DatOffs+2],0

; ------ zobrazen¡ dat HEX

         push      si
         mov       cx,16
ZobrDat6:call      DispSpc

         cmp       si,bp
         jb        ZobrDat7
         mov       al,"-"
         call      DispChr
         call      DispChr
         jmp       short ZobrDat8

ZobrDat7:cld
         lodsb
         call      DispHByt

ZobrDat8:dec       cx
         test      cl,3
         jnz       ZobrDt82
         call      DispSpc
ZobrDt82:cmp       cl,8
         jne       ZobrDt84
         mov       al,"-"
         call      DispChr
ZobrDt84:inc       cx
         loop      ZobrDat6

         pop       si

; ------ zobrazen¡ dat ASCII

         call      DispSpc

         mov       cx,16
ZobrDt86:cmp       si,bp
         jae       ZobrDt88
         cld
         lodsb
         cmp       al," "
         jae       ZobrDt87
         mov       al,"."
ZobrDt87:call      DispChr
         loop      ZobrDt86

ZobrDt88:call      DispCR                   ; od© dkov n¡
         jmp       short ZobrDat4

ZobrDat  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ definice textu v˜pisu (CY=chyba)
; -----------------------------------------------------------------------------

ReadText PROC      NEAR

; ------ otev©en¡ souboru

         mov       ax,3d00h
         mov       dx,offset SoubText
         int       21h                      ; otev©en¡ souboru
         jc        ReadTxt8                 ; chyba
         xchg      ax,bx

; ------ na‡ten¡ souboru

         mov       dx,ds:[AdrHlas]          ; adresa hl ¨en¡
         mov       cx,sp                    ; z sobn¡k
         sub       cx,200h                  ; asi takov  rezerva
         sub       cx,dx                    ; voln‚ m¡sto
         jc        ReadTxt7                 ; to jen pro jistotu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru
         jc        ReadTxt7

; ------ nov  velikost textu

         add       ax,dx
         mov       ds:[AdrKonec],ax         ; nov˜ konec dat
                                           ;* zde je NC
; ------ uzav©en¡ souboru

ReadTxt7:pushf
         mov       ah,3eh
         int       21h
         popf
         jnc       ReadTxt9

; ------ chybn˜ soubor

ReadTxt8:mov       dx,offset CtiTxt
         call      DispTxt
         stc
ReadTxt9:ret

ReadText ENDP

; -----------------------------------------------------------------------------
;        v˜pis parametr–
; -----------------------------------------------------------------------------
;þ
ParList  PROC      NEAR

; ------ zobrazen¡ textu £vodn¡ho hl ¨en¡

         mov       dx,offset HlasHlas
         call      DispTxt
         call      DispHlas                 ; zobrazen¡ hl ¨en¡

; ------ zobrazen¡ jm‚na souboru

         mov       dx,offset HlasSoub
         call      DispTxt
         call      DispModi                 ; zobrazen¡ jm‚na souboru

; ------ nadpis - modifika‡n¡ tabulka

         mov       dx,offset HlasMod
         call      DispTxt

; ------ test, zda je dal¨¡ polo‘ka

         mov       si,offset TabKod         ; tabulka k¢d–
ParList3:cmp       si,ds:[AdrHlas]          ; konec ?
         jb        ParList4                 ; nen¡ je¨tˆ konec
         ret

; ------ zobrazen¡ £vodn¡ho textu

ParList4:mov       dx,offset HlasZTxt       ; z pis
         test      byte ptr ds:[si+3],80h
         jnz       ParList5                 ; je z pis
         mov       dx,offset HlasVTxt       ; verifikace
ParList5:call      DispTxt

; ------ zobrazen¡ offsetu v souboru

         mov       ax,ds:[si]
         mov       dx,ds:[si+2]
         and       dh,not 80h
         call      DispHDw

; ------ zobrazen¡ dat

         mov       ch,0
         mov       cl,ds:[si+4]
         add       si,5
         jcxz      ParList7
         call      DispSpc
ParList6:call      DispSpc
         cld
         lodsb
         call      DispHByt
         loop      ParList6

; ------ konec © dku

ParList7:call      DispCR
         jmp       short ParList3

ParList  ENDP

; -----------------------------------------------------------------------------
;        vyhled n¡ dat v souboru (CY=p©eru¨en¡) (DS=ES !)
; -----------------------------------------------------------------------------

ParSrch  PROC      NEAR

         mov       word ptr ds:[DatOffs],0  ; offset v souboru
         mov       word ptr ds:[DatOffs+2],0

; ------ otev©en¡ souboru

         mov       dx,offset ModiSoub
         mov       ax,3d00h
         int       21h
         xchg      ax,bx
         jnc       ParSrch2

; ------ chyba otev©en¡ souboru

ParSrch1:call      OpenErr
         ret

; ------ nastaven¡ ukazatele v souboru

ParSrch2:call      SetUFil0                 ; nastaven¡ ukazatele dat

; ------ na‡ten¡ bufferu -> CX po‡et bajt–

         mov       cx,sp
         sub       cx,200h
         mov       dx,ds:[AdrKonec]         ; adresa bufferu
         sub       cx,dx                    ; velikost bufferu
         jbe       ParSrch9
         mov       ah,3fh
         int       21h                      ; na‡ten¡ bufferu
         jc        ParSrch9
         xchg      ax,cx
         jcxz      ParSrch9
         mov       si,dx                    ; SI <- ukazatel dat

; ------ po‡et ©etˆzc– k hled n¡ -> CX

         sub       cx,ds:[DatNum]           ; po‡et ©etˆzc– k hled n¡ - 1
         jb        ParSrch9                 ; m lo dat
         inc       cx                       ; po‡et ©etˆzc– k hled n¡
         cld

; ------ porovn n¡ dat na jedn‚ adrese

ParSrch3:push      si
         push      cx
         mov       di,offset DatBuff        ; buffer dat
         mov       cx,ds:[DatNum]           ; d‚lka ©etˆzce
         repe      cmpsb                    ; porovn n¡ ©etˆzc–
         pop       cx
         pop       si
         jne       ParSrch4                 ; ©etˆzec nesouhlas¡

; ------ v˜pis adresy ©etˆzce

         xor       dx,dx
         mov       ax,si
         sub       ax,ds:[AdrKonec]
         add       ax,word ptr ds:[DatOffs]
         adc       dx,word ptr ds:[DatOffs+2]
         call      DispHDw

; ------ v˜pis dat

         call      DispSpc
         call      DispDat                  ; v˜pis dat
         call      DispCR                   ; od© dkov n¡

; ------ p©¡prava pro dal¨¡ adresu

         cld
ParSrch4:inc       si                       ; zv˜¨en¡ ukazatele dat
         loop      ParSrch3                 ; test dal¨¡ho ©etˆzce

; ------ posun ukazatele v souboru

         sub       si,ds:[AdrKonec]
         add       word ptr ds:[DatOffs],si ; zv˜¨en¡ ukazatele v souboru
         adc       word ptr ds:[DatOffs+2],0
         jmp       short ParSrch2           ; test dal¨¡ho bloku

; ------ uzav©en¡ souboru

ParSrch9:mov       ah,3eh
         int       21h
         ret

ParSrch  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ukazatele v souboru BX na offset DX:AX
; -----------------------------------------------------------------------------

SetUFil0 PROC      NEAR

         push      ax
         push      dx

         mov       ax,word ptr ds:[DatOffs] ; offset ukazatele
         mov       dx,word ptr ds:[DatOffs+2]
         call      SetUFile

         pop       dx
         pop       ax
         ret

SetUFil0 ENDP

SetUFile PROC      NEAR

         push      ax
         push      cx
         push      dx

         xchg      ax,dx                    ; AX <- HIGH, DX <- LOW
         xchg      ax,cx                    ; CX <- HIGH
         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele dat

         pop       dx
         pop       cx
         pop       ax
         ret

SetUFile ENDP

; -----------------------------------------------------------------------------
;        hl ¨en¡ - nenalezen soubor k modifikaci
; -----------------------------------------------------------------------------

OpenErr  PROC      NEAR

         mov       dx,offset OpenTxt
         call      DispTxt
         call      DispModi                 ; zobrazen¡ jm‚na souboru
         mov       dx,offset CRXTxt
         call      DispTxt
         stc
         ret

OpenErr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ dat z bufferu
; -----------------------------------------------------------------------------

DispDat  PROC      NEAR

         push      ax
         push      cx
         push      si

         mov       si,offset DatBuff
         mov       cx,ds:[DatNum]
DispDat2:mov       al," "
         call      DispChr
         cld
         lodsb
         call      DispHByt
         loop      DispDat2

         pop       si
         pop       cx
         pop       ax
         ret

DispDat  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ £vodn¡ho hl ¨en¡
; -----------------------------------------------------------------------------

DispHlas PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,ds:[AdrHlas]
         mov       bx,1
         mov       cx,ds:[AdrKonec]         ; adresa konce dat
         sub       cx,dx                    ; d‚lka textu
         mov       ah,40h
         int       21h                      ; zobrazen¡ textu hl ¨en¡

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispHlas ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ jm‚na modifikovan‚ho souboru
; -----------------------------------------------------------------------------

DispModi PROC      NEAR

         push      ax
         push      si

         mov       si,offset ModiSoub       ; jm‚no souboru
DispMod1:cld
         lodsb
         cmp       al," "
         jbe       DispMod2
         call      DispChr
         jmp       short DispMod1

DispMod2:pop       si
         pop       ax
         ret

DispModi ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ dvojslova HEX DX:AX
; -----------------------------------------------------------------------------

DispHDw  PROC      NEAR

         xchg      ax,dx
         call      DispHWrd
         xchg      ax,dx
         push      ax
         mov       al,":"
         call      DispChr
         pop       ax

DispHDw  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ slova HEX AX
; -----------------------------------------------------------------------------

DispHWrd PROC      NEAR

         xchg      al,ah
         call      DispHByt
         xchg      al,ah

DispHWrd ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu HEX AL
; -----------------------------------------------------------------------------

DispHByt PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHx
         pop       ax

DispHByt ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku HEX
; -----------------------------------------------------------------------------

DispHx   PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,9
         jbe       DispHx2
         add       al,7
DispHx2: add       al,"0"
         call      DispChr
         pop       ax
         ret

DispHx   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ od© dkov n¡
; -----------------------------------------------------------------------------

DispCR   PROC      NEAR

         push      ax
         mov       al,13
         call      DispChr
         mov       al,10
         call      DispChr
         pop       ax
         ret

DispCR   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ mezery
; -----------------------------------------------------------------------------

DispSpc  PROC      NEAR

         push      ax
         mov       al," "
         call      DispChr
         pop       ax
         ret

DispSpc  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx

         xchg      ax,dx                    ; DL <- znak k zobrazen¡
         mov       ah,2
         int       21h

         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        rozbor dat DS:SI (CY=nen¡ nic zad no, DS=ES)
; -----------------------------------------------------------------------------

RozbDat  PROC      NEAR

         mov       di,offset DatBuff        ; datov˜ buffer
RozbDat2:call      RozbHNum                 ; na‡ten¡ ‡¡sla
         jc        RozbDat9

RozbDat3:stosb
         mov       al,ah
         mov       ah,dl
         mov       dl,dh

         or        dh,ah
         or        dh,al
         mov       dh,0
         jnz       RozbDat3
         jmp       short RozbDat2

RozbDat9:sub       di,offset DatBuff
         mov       ds:[DatNum],di
         cmp       di,1                     ; je nˆco zad no ?
         ret

RozbDat  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla HEX DS:SI -> DX:AX
; -----------------------------------------------------------------------------

RozbHNm0:call      RozbHNum
         mov       word ptr ds:[DatOffs],ax
         mov       word ptr ds:[DatOffs+2],dx
         ret

RozbHNum PROC      NEAR

         call      RozbSpc
         jc        RozbHNm9

         push      bx

         xor       bx,bx                    ; st©ada‡ LOW
         xor       dx,dx                    ; st©ada‡ HIGH

         call      RozbHx
         jc        RozbHNm8

RozbHNm4:shl       bx,1
         rcl       dx,1
         shl       bx,1
         rcl       dx,1
         shl       bx,1
         rcl       dx,1
         shl       bx,1
         rcl       dx,1

         or        bl,al

         call      RozbHx
         jnc       RozbHNm4

         clc

RozbHNm8:xchg      ax,bx
         pop       bx
RozbHNm9:ret

RozbHNum ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku HEX -> AL
; -----------------------------------------------------------------------------

RozbHx   PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku
         jc        RozbHx9

         cmp       al,"X"
         je        RozbHx
         cmp       al,"$"
         je        RozbHx
         cmp       al,"#"
         je        RozbHx

         cmp       al,"0"
         jb        RozbHx8
         cmp       al,"9"
         jbe       RozbHx4
         cmp       al,"A"
         jb        RozbHx8
         cmp       al,"F"
         ja        RozbHx8

         sub       al,7
RozbHx4: sub       al,"0"
         ret

RozbHx8: dec       si
         stc
RozbHx9: ret

RozbHx   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jm‚na souboru do bufferu ES:DI (CY=chyba)
; -----------------------------------------------------------------------------

RozbFile PROC      NEAR

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        RozbFil9
         cmp       al,"/"
         stc
         je        RozbFil9

RozbFil2:call      RozbChr
         jc        RozbFil5
         je        RozbFil4
         cmp       al,"/"
         je        RozbFil4
         stosb
         jmp       short RozbFil2

RozbFil4:dec       si
RozbFil5:clc
RozbFil9:mov       byte ptr ds:[di],0       ; ozna‡en¡ konce jm‚na souboru
         ret

RozbFile ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku
         jc        RozbSpc2                 ; konec dat
         je        RozbSpc                  ; vypu¨tˆn¡ mezery

         cmp       al,";"
         je        RozbSpc
         cmp       al,","
         je        RozbSpc
         cmp       al,"."
         je        RozbSpc
         cmp       al,":"
         je        RozbSpc

         clc
         dec       si
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku DS:SI -> AL (CY=konec)
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

         cld
         lodsb
         cmp       al,9
         jne       RozbChr2
         mov       al," "

RozbChr2:cmp       al,"a"
         jb        RozbChr3
         cmp       al,"z"
         ja        RozbChr3
         sub       al,32

RozbChr3:cmp       al," "
         jae       RozbChr4
         dec       si

RozbChr4:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        z pis programu (CY=chyba z pisu) (uchov v  SI !)
; -----------------------------------------------------------------------------

WritProg PROC      NEAR

; ------ vytvo©en¡ programu z prost©ed¡

         mov       ah,30h
         int       21h
         cmp       al,3
         jb        WritPrg5                 ; n¡zk  verze syst‚mu

         mov       ax,ds:[2ch]              ; segment prost©ed¡
         cmp       ax,60h
         jb        WritPrg5

         push      ds
         xor       bx,bx
         mov       ds,ax

WritPrg2:inc       bx
         cmp       word ptr ds:[bx-1],0
         jne       WritPrg2

         inc       bx
         inc       bx
         inc       bx
         mov       dx,bx
         mov       ah,3ch
         xor       cx,cx
         int       21h
         pop       ds
         jnc       WritPrg6                 ; soubor vytvo©en OK

; ------ vytvo©en¡ v˜stupn¡ho souboru

WritPrg5:mov       dx,offset Program        ; jm‚no programu
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ programu
         jc        WritPrg8                 ; chyba
WritPrg6:xchg      ax,bx

; ------ z pis souboru

         mov       dx,offset Start          ; za‡ tek programu
         mov       cx,ds:[AdrKonec]         ; adresa konce
         sub       cx,dx                    ; d‚lka dat
         mov       ah,40h
         int       21h                      ; z pis programu
         jc        WritPrg7                 ; chyba
         cmp       ax,cx

; ------ uzav©en¡ souboru

WritPrg7:pushf
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         popf
         jnc       WritPrg9

; ------ hl ¨en¡ - chyba z pisu

WritPrg8:mov       dx,offset ZapTxt         ; chyba z pisu
         call      DispTxt
         stc
WritPrg9:ret

WritProg ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Program  db        '!CRACK.COM',0

HelpTxt  db        13,10
         db        '!CRACK v1.0 - modifikace souboru; (c) Miroslav Nemecek (FREEWARE !)',13,10
         db        13,10
         db        '  Program !CRACK je prostredek ke snadne modifikaci souboru a programu',13,10
         db        '  podle modifikacni tabulky. Tato tabulka je uchovana uvnitr programu.',13,10
         db        '  Je ji mozne definovat pomoci dale uvedenych parametru. Po kazde zmene',13,10
         db        '  tabulky je ulozen na disk novy soubor !CRACK.COM. Po provedeni vsech',13,10
         db        '  zmen lze program !CRACK.COM zkomprimovat a ochranit atributem R/O.',13,10
         db        13,10
         db        '     /L ............... vypis aktualniho nastaveni programu',13,10
         db        '     /S data .......... vyhledani dat v modifikovanem souboru',13,10
         db        '     /H offset ........ zobrazeni 128 bajtu ze zadaneho offsetu',13,10
         db        '     /T soubor ........ soubor s textem hlaseni pri spusteni',13,10
         db        '     /F soubor ........ specifikace modifikovaneho souboru (programu)',13,10
         db        '     /V offset data ... provede se overeni dat na zadanem offsetu',13,10
         db        '     /W offset data ... provede se zapis dat na zadany offset',13,10
         db        13,10
         db        'Offsety a data jsou v HEX kodu, jako data lze zadat i vice bajtu. Pri nezadani',13,10
         db        'zadnych dat se definice zrusi. Po spusteni programu bez parametru se zobrazi',13,10
         db        'hlaseni - parametr /T. Je-li stisknuta jina klavesa nez ESC nebo Ctrl-Break ',13,10
         db        'otevre se soubor (parametr /F), overi se data podle parametru /V a pri shode',13,10
         db        'se zapisou data podle parametru /W.',13,10
         db        13,10
         db        '>>> Tento program je FREEWARE - lze jej neomezene volne sirit a pouzivat. <<<',13,10
         db        '$'

OpenTxt  db        'CHYBA - nelze otevrit soubor $'
WritTxt  db        'CHYBA zapisu do modifikovaneho souboru !',13,10,'$'

OKTxt    db        'Modifikovany soubor upraven O.K.',13,10,'$'

ZapTxt   db        'CHYBA zapisu modifikovaneho programu !CRACK.COM'
CRXTxt   db        ' !',13,10,'$'

CtiTxt   db        'CHYBA - zadany soubor s textem hlaseni nenalezen !',13,10,'$'

HlasHlas db        13,10
         db        'Uvodni hlaseni pri spusteni programu:',13,10
         db        '------------------------------------',13,10
         db        '$'

HlasSoub db        13,10
         db        'Jmeno modifikovaneho souboru/programu:',13,10
         db        '-------------------------------------',13,10
         db        '$'

HlasMod  db        13,10,13,10
         db        'Seznam provadenych verifikaci a zapisu:',13,10
         db        '--------------------------------------',13,10
         db        '$'

VerifTxt db        'Modifikovany soubor neni platny nebo je jiz upraven !',13,10,'$'

HlasVTxt db        'overeni: $'
HlasZTxt db        '  ZAPIS: $'

DatOffs  dd        0                        ; ukazatel offsetu v souboru

DatNum   dw        0                        ; po‡et bajt– v bufferu dat
DatBuff  db        128 dup(0)               ; buffer dat k hled n¡/verifikaci/z pisu

SoubText db        128 dup(0)               ; jm‚no souboru, buffer textu
ModiSoub db        128 dup(0)               ; specifikace modifikovan‚ho souboru

AdrHlas  dw        UvHlas                   ; adresa hl ¨en¡, t‚‘ konec tabulky
AdrKonec dw        UvHlas0                  ; adresa konce programu

TabKod   label     byte                     ; tabulka k¢d– k verifikaci a modifikaci
; Struktura:
;        (4)       offset v souboru (15 bit–)
;                     bit 15: 0=je verifikace, 1=je z pis
;        (1)       po‡et bajt– dat
;        (x)       data
;
; Po©ad¡ - set©¡dˆno podle offset–, verifikace je p©ed z pisem

UvHlas   db        'Zadejte "/?" k zobrazeni napovedy k pouziti programu !CRACK.',13,10
         db        'Stisknete libovolnou klavesu...',13,10
UvHlas0  label     byte

Code     ENDS
         END       Start
